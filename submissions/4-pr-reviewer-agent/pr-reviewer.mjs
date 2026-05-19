#!/usr/bin/env node
// Agent: PR Reviewer — Claude Code sub-agent that reviews a PR and posts a structured comment
// Usage: node pr-reviewer.mjs --repo owner/repo --pr 42 [--token ghp_xxx]
// Or set: GITHUB_TOKEN environment variable

import { execSync } from "child_process";
import fs from "fs";
import path from "path";

const args = process.argv.slice(2);
const repoIndex = args.indexOf("--repo");
const prIndex = args.indexOf("--pr");
const tokenIndex = args.indexOf("--token");

const REPO = repoIndex !== -1 ? args[repoIndex + 1] : process.env.GITHUB_REPOSITORY;
const PR_NUMBER = prIndex !== -1 ? args[prIndex + 1] : null;
const GITHUB_TOKEN = tokenIndex !== -1 ? args[tokenIndex + 1] : process.env.GITHUB_TOKEN;

if (!REPO || !PR_NUMBER) {
  console.error("Usage: node pr-reviewer.mjs --repo owner/repo --pr <number> [--token ghp_xxx]");
  process.exit(1);
}

if (!GITHUB_TOKEN) {
  console.error("GITHUB_TOKEN is required");
  process.exit(1);
}

const GITHUB_API = "https://api.github.com";

async function api(path, options = {}) {
  const url = `${GITHUB_API}${path}`;
  const res = await fetch(url, {
    headers: {
      Authorization: `token ${GITHUB_TOKEN}`,
      Accept: "application/vnd.github.v3+json",
      ...options.headers,
    },
    ...options,
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`API error ${res.status}: ${text}`);
  }
  return res.json();
}

async function getPRDiff() {
  const url = `${GITHUB_API}/repos/${REPO}/pulls/${PR_NUMBER}`;
  const res = await fetch(url, {
    headers: {
      Authorization: `token ${GITHUB_TOKEN}`,
      Accept: "application/vnd.github.v3.diff",
    },
  });
  if (!res.ok) throw new Error(`Diff fetch failed: ${res.status}`);
  return res.text();
}

async function getPRFiles() {
  return api(`/repos/${REPO}/pulls/${PR_NUMBER}/files`);
}

async function getPRCommits() {
  return api(`/repos/${REPO}/pulls/${PR_NUMBER}/commits`);
}

async function postReviewComment(body, event = "COMMENT") {
  return api(`/repos/${REPO}/pulls/${PR_NUMBER}/reviews`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ body, event }),
  });
}

async function analyzePR() {
  console.log(`🔍 Reviewing PR #${PR_NUMBER} in ${REPO}...`);

  const [pr, files, commits, diff] = await Promise.all([
    api(`/repos/${REPO}/pulls/${PR_NUMBER}`),
    getPRFiles(),
    getPRCommits(),
    getPRDiff(),
  ]);

  const totalChanges = files.reduce((sum, f) => sum + (f.additions || 0) + (f.deletions || 0), 0);
  const totalAdditions = files.reduce((sum, f) => sum + (f.additions || 0), 0);
  const totalDeletions = files.reduce((sum, f) => sum + (f.deletions || 0), 0);

  const issues = [];
  const suggestions = [];
  let overallScore = 5;

  // Check file count
  if (files.length > 20) {
    issues.push(`⚠️ Large PR: ${files.length} files changed. Consider splitting into smaller PRs.`);
    overallScore -= 1;
  }

  // Check for missing tests
  const hasTestChanges = files.some(
    (f) => f.filename.includes("test") || f.filename.includes("spec") || f.filename.includes("__tests__")
  );
  if (!hasTestChanges && totalChanges > 50) {
    suggestions.push("🧪 No test files found. Consider adding tests for this change.");
    overallScore -= 1;
  }

  // Check for debug artifacts
  for (const f of files) {
    if (f.patch && (f.patch.includes("console.log(") || f.patch.includes("debugger"))) {
      suggestions.push(`🔧 Remove debug statements in \`${f.filename}\``);
    }
  }

  // Check commit hygiene
  const hasMergeCommits = commits.some((c) => c.commit.message.startsWith("Merge"));
  if (hasMergeCommits) {
    suggestions.push("🔀 Contains merge commits. Consider rebasing instead.");
    overallScore -= 1;
  }

  // Check branch naming
  const branchName = pr.head.ref;
  if (!/^(feat|fix|chore|docs|refactor|test)\//.test(branchName)) {
    suggestions.push(`📛 Branch name "${branchName}" doesn't follow conventional naming (feat/, fix/, chore/, etc.)`);
    overallScore -= 1;
  }

  const review = `
## 🤖 AI PR Review — #${PR_NUMBER}

**Title:** ${pr.title}
**Branch:** \`${pr.head.ref}\` → \`${pr.base.ref}\`
**Author:** ${pr.user.login}
**Files:** ${files.length} | **+${totalAdditions}/-${totalDeletions}** | **${commits.length} commits**

---

### 📊 Overall Score: ${"⭐".repeat(Math.max(1, overallScore))}${"☆".repeat(Math.max(0, 5 - overallScore))} (${overallScore}/5)

---

${issues.length ? "### ⚠️ Issues\n" + issues.map((i) => `- ${i}`).join("\n") + "\n---\n" : ""}

${suggestions.length ? "### 💡 Suggestions\n" + suggestions.map((s) => `- ${s}`).join("\n") + "\n---\n" : ""}

### 📁 Files Changed
| File | Status | +/- |
|------|--------|-----|
${files
  .slice(0, 30)
  .map((f) => `| \`${f.filename}\` | ${f.status} | +${f.additions}/-${f.deletions} |`)
  .join("\n")}

${files.length > 30 ? `\n_...and ${files.length - 30} more files_\n` : ""}

### 💬 Summary
${pr.body ? pr.body.slice(0, 500) : "_No description provided._"}

---

_Reviewed by Claude Code PR Reviewer Agent · ${new Date().toISOString()}_
`;

  console.log(review);

  console.log("\n📤 Posting review comment...");
  await postReviewComment(review);
  console.log("✅ Review posted successfully!");
}

analyzePR().catch((err) => {
  console.error("❌ Review failed:", err.message);
  process.exit(1);
});
