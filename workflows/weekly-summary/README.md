# Weekly GitHub Summary Workflow (n8n)

This workflow automatically generates a professional, narrative summary of a GitHub repository's activity over the past week using the Claude API and delivers it via multiple channels.

## Features
- **Trigger**: Weekly cron job (Fridays at 5 PM).
- **Data Collection**: Fetches commits, closed issues, and merged PRs from the GitHub API.
- **AI Narrative Engine**: Uses `claude-sonnet-4-20250514` with a sophisticated "DevRel" prompt to synthesize activity into a readable narrative.
- **Multilingual**: Supports English, French, and other languages via configuration.
- **Multi-Channel Delivery**:
  - 💬 **Discord**: Posts a summary to your Discord channel.
  - 💬 **Slack**: Posts a summary to your Slack workspace.
  - 🎫 **GitHub Issues**: Automatically creates a "Weekly Summary" issue in the repository for archival and discussion.

## Setup Instructions (5 Steps)

1. **Import Workflow**: Open n8n and import the `workflow.json` file.
2. **Configure Credentials**: 
   - Add your **GitHub PAT** (with `repo` scope).
   - Add your **Anthropic API Key**.
3. **Set Variables**: In the "Set Variables" node, update:
   - `REPO_OWNER`: The owner of the repo.
   - `REPO_NAME`: The name of the repo.
   - `LANGUAGE`: `EN`, `FR`, `ES`, etc.
   - `DISCORD_WEBHOOK_URL`: Your Discord channel webhook.
   - `SLACK_WEBHOOK_URL`: Your Slack channel webhook.
4. **Test Connection**: Manually trigger the "GitHub Commits" node to ensure your PAT is working.
5. **Enable Workflow**: Toggle the workflow to "Active".

## Configuration Variables
| Variable | Description |
| --- | --- |
| `REPO_OWNER` | GitHub username or organization name. |
| `REPO_NAME` | Repository name. |
| `LANGUAGE` | Language for the summary (e.g., `EN` or `FR`). |
| `DISCORD_WEBHOOK_URL` | The URL for Discord webhook delivery. |
| `SLACK_WEBHOOK_URL` | The URL for Slack webhook delivery. |
| `CREATE_GITHUB_ISSUE` | Set to `true` to enable automatic issue creation. |

## Workflow Structure
The workflow uses a parallel architecture to fetch data from different GitHub endpoints, formats a structured prompt for Claude, and then branches out to multiple delivery nodes simultaneously.
