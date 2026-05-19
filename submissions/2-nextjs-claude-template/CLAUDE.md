# CLAUDE.md — Next.js + SQLite SaaS Template

## Project Overview
This is a Next.js SaaS application with SQLite (via better-sqlite3 or drizzle-orm), authentication, and subscription billing.

## Tech Stack
- **Framework**: Next.js 15 (App Router)
- **Database**: SQLite via Drizzle ORM
- **Auth**: NextAuth.js / Auth.js v5
- **Payments**: Stripe
- **CSS**: Tailwind CSS v4
- **Deployment**: Vercel + Turso (SQLite edge)
- **Language**: TypeScript strict mode

## Commands
- `npm run dev` — Start dev server
- `npm run build` — Type-check + build
- `npm run lint` — ESLint + Prettier check
- `npm run test` — Vitest
- `npm run db:push` — Push schema to SQLite
- `npm run db:studio` — Open Drizzle Studio
- `npm run db:seed` — Seed sample data
- `npm run typecheck` — tsc --noEmit

## Project Structure
```
src/
  app/          # App router pages & API routes
  components/  # Shared React components
  db/          # Drizzle schema, migrations, client
  lib/         # Utilities, helpers, config
  actions/     # Server actions
  webhooks/    # Stripe/webhook handlers
```

## Code Conventions

### Database Schema
- Place all tables in `src/db/schema/`
- Use `sqliteTable` from drizzle-orm/sqlite-core
- Every table gets `id: integer().primaryKey({ autoIncrement: true })` and `timestamps` helper
- Use ` relations` from drizzle-orm for joins

### API Routes
- App Router route handlers in `src/app/api/`
- Validate with Zod on every public endpoint
- Return `NextResponse<APIResponse<T>>` — always wrap in `{ success, data, error }`

### Server Actions
- Co-locate with page components
- Prefix: `action_<name>`
- Server-validate all inputs with Zod
- Revalidate paths with `revalidatePath()` on mutations

### React Components
- Server components by default; add `"use client"` only when needed
- Props typed with `interface` (not `type`)
- Use `cn()` from `clsx` + `tailwind-merge` for className merging

## Git Workflow
- Branch: `feat/*`, `fix/*`, `chore/*`
- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- Commits must pass `npm run typecheck && npm run lint && npm run test`

## Environment Variables (required)
```
DATABASE_URL=file:./data/dev.db
AUTH_SECRET=
AUTH_GITHUB_ID=
AUTH_GITHUB_SECRET=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=
```

## When I ask you to...
- "Add a new page" → create in `src/app/<route>/page.tsx` with server component
- "Add a DB table" → create schema in `src/db/schema/`, export from `src/db/schema/index.ts`, run `db:push`
- "Create an API route" → `src/app/api/<name>/route.ts` with GET/POST handlers
- "Fix type errors" → run `npm run typecheck` first, fix all strict TS issues
