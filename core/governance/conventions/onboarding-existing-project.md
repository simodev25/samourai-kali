# Onboarding an Existing Project to Samourai

> **Audience:** Engineers and tech leads adopting Samourai in an existing project.
>
> **Goal:** Step-by-step guide to set up the minimum viable Samourai configuration, with clear distinction between mandatory and optional artifacts.

---

<!-- TOC -->
* [Onboarding an Existing Project to Samourai](#onboarding-an-existing-project-to-samourai)
  * [Getting Samourai](#getting-samourai)
    * [Keeping Samourai Updated](#keeping-samourai-updated)
  * [Prerequisites](#prerequisites)
  * [Artifact Checklist](#artifact-checklist)
  * [Choose Your Setup Path](#choose-your-setup-path)
  * [Automated Bootstrap](#automated-bootstrap)
  * [Manual Setup (Step-by-Step)](#manual-setup-step-by-step)
    * [Step 1: Mandatory Artifacts](#step-1-mandatory-artifacts)
    * [1.1 `.samourai/AGENTS.md` and root `AGENTS.md`](#11-samouraiagentsmd-and-root-agentsmd)
    * [1.2 `.samourai/ai/agent/pm-instructions.md`](#12-aiagentpm-instructionsmd)
      * [Mandatory Sections](#mandatory-sections)
      * [Recommended Extensions](#recommended-extensions)
      * [What NOT to include](#what-not-to-include)
      * [Example: GitHub Issues (Minimal)](#example-github-issues-minimal)
      * [Example: Jira (with common extensions)](#example-jira-with-common-extensions)
      * [Example: Local Markdown Backlog (Git-native)](#example-local-markdown-backlog-git-native)
    * [1.3 `.samourai/docai/documentation-handbook.md`](#13-docdocumentation-handbookmd)
  * [Step 2: Recommended Artifacts (Optional)](#step-2-recommended-artifacts-optional)
    * [2.1 `.samourai/docai/00-index.md` — Documentation Landing Page](#21-doc00-indexmd--documentation-landing-page)
    * [2.2 `.samourai/docai/overview/` — Project Overview](#22-docoverview--project-overview)
    * [2.3 `.samourai/docai/spec/features/` — Feature Specifications](#23-docspecfeatures--feature-specifications)
    * [2.4 `.samourai/core/templates/` — Document Templates](#24-samouraicoretemplates--document-templates)
    * [2.5 `.samourai/core/decisions/` — Decision Record Kit](#25-samouraicoredecisions--decision-record-kit)
    * [2.6 `.samourai/docai/guides/` — Project-Specific Guides](#26-docguides--project-specific-guides)
  * [Step 3: Decision Records Setup](#step-3-decision-records-setup)
  * [Step 4: First Change Walkthrough](#step-4-first-change-walkthrough)
    * [Using Autopilot (Recommended)](#using-autopilot-recommended)
    * [Using Manual Commands](#using-manual-commands)
  * [Troubleshooting](#troubleshooting)
    * ["Agent can't find my issue tracker"](#agent-cant-find-my-issue-tracker)
    * ["Templates are not being used"](#templates-are-not-being-used)
    * ["Decision records workflow doesn't work"](#decision-records-workflow-doesnt-work)
    * ["Change artifacts are in the wrong location"](#change-artifacts-are-in-the-wrong-location)
    * ["Agents reference files that don't exist"](#agents-reference-files-that-dont-exist)
    * ["PM agent can't read or update tickets" / MCP tracker setup](#pm-agent-cant-read-or-update-tickets--mcp-tracker-setup)
  * [Related Guides](#related-guides)
<!-- TOC -->

## Getting Samourai

Install the Samourai kit into a project from the kit repository:

```bash
./scripts/install-samourai.sh --target /path/to/project --editor opencode
```

For VS Code/Copilot:

```bash
./scripts/install-samourai.sh --target /path/to/project --editor vscode
```

This installs reusable Samourai resources under `.samourai/core/**` and installs the selected editor adapter.

> **Tip:** Use `--dry-run` to preview changes before applying them. To remove installed files later, run `scripts/uninstall-samourai.sh --target /path/to/project`.

### Keeping Samourai Updated

Re-run the installer with `--force` to update managed Samourai artifacts:

```bash
./scripts/install-samourai.sh --target /path/to/project --editor opencode --force
```

The installer records updated paths in `.samourai/install/overwritten-files.txt`.

---

## Prerequisites

Before starting, ensure you have:

- A **git repository** for your project
- A supported editor adapter: OpenCode or VS Code/Copilot
- AI provider or editor account credentials required by the selected editor
- Basic familiarity with Samourai concepts (see [Agents & Commands Guide](opencode-agents-and-commands-guide.md))
- Access to your team's issue tracker (GitHub Issues or Jira)

> **What to expect:**
> - **Automated bootstrap:** ~15 minutes (scan + interview + review)
> - **Manual setup:** ~30 minutes (copy files, configure tracker, create stubs)
> - **First change (full 10-phase workflow):** ~1 hour
> - **Ongoing changes:** 15-30 minutes each (agents handle most phases automatically)

---

## Artifact Checklist

Samourai is both a framework you adopt **and** a system that uses itself. Some artifacts are reusable kit resources, while others must be written specifically for your project. Use this table to plan your setup:

| Artifact | Path | Action | Notes |
|----------|------|--------|-------|
| **Mandatory** | | | |
| Project instructions | `.samourai/AGENTS.md` + root `AGENTS.md` entrypoint | Generate during bootstrap | Customize project description, repo structure, key references |
| PM instructions | `.samourai/ai/agent/pm-instructions.md` | Generate during bootstrap | Customize for your tracker |
| Documentation handbook | `.samourai/docai/documentation-handbook.md` | Generate when needed | Keep project-specific documentation conventions here |
| **Recommended** | | | |
| Documentation index | `.samourai/docai/00-index.md` | Generate during bootstrap | Update links to match your docs |
| Document templates | `.samourai/core/templates/` | Auto-installed | 7 reusable templates — agents read at runtime |
| Decision records kit | `.samourai/core/decisions/` | Auto-installed | README.md + 00-index.md stubs used as setup references |
| AI rules index | `.samourai/ai/rules/README.md` | Auto-installed, customize | Add project-specific rules to routing table |
| Samourai guides | `.samourai/core/governance/conventions/` | Auto-installed | Framework guides — change lifecycle, conventions, etc. |
| **Optional (create as needed)** | | | |
| Project overview | `.samourai/docai/overview/` | Create & customize | North star, architecture, glossary |
| Feature specs | `.samourai/docai/spec/features/` | Create & customize | Current-truth feature descriptions |
| Coding rules | `.samourai/ai/rules/<topic>.md` | Create & customize | Language/framework-specific coding standards |
| Testing strategy | `.samourai/ai/rules/testing-strategy.md` | Create & customize | Required before `@test-plan-writer` can run |
| Project guides | `.samourai/docai/guides/` | Create & customize | Dev setup, debugging, deployment, etc. |

> **Decision management:** All decisions (architecture, product, technical, business, operational) go in `.samourai/docai/decisions/` — see the [Decision Records Management Guide](decision-records-management.md).

---

## Choose Your Setup Path

> **Automated (recommended):** Run `/bootstrap` and the `@bootstrapper` agent will scan your repo, ask targeted questions, and generate all required artifacts with your approval. Takes ~15 minutes.
>
> **Manual (full control):** Follow Steps 1-5 below to set up each artifact individually. Takes ~30 minutes.
>
> **Skip to:** [Automated Bootstrap](#automated-bootstrap) | [Manual Setup](#manual-setup-step-by-step)

---

## Automated Bootstrap

```
/bootstrap
```

The `@bootstrapper` agent will:

1. **Scan** your repo structure, tech stack, and existing docs
2. **Assess** what it can infer vs. what needs your input
3. **Interview** you with targeted questions (~3-7 per round)
4. **Draft** all required Samourai artifacts for your review
5. **Write** final artifacts upon your approval

After bootstrap completes, jump to [First Change Walkthrough](#step-4-first-change-walkthrough) to validate your setup.

---

## Manual Setup (Step-by-Step)

### Step 1: Mandatory Artifacts

These three files are **required** for Samourai to function. Without them, agents cannot orchestrate changes.

### 1.1 `.samourai/AGENTS.md` and root `AGENTS.md`

`.samourai/AGENTS.md` is the project-specific instruction file. It tells agents what your project is, how the delivery process works, and where to find everything.

The root `AGENTS.md` is a small compatibility entrypoint for tools that auto-discover that filename. It should point readers to `.samourai/AGENTS.md`.

**Setup:**

1. Generate `.samourai/AGENTS.md` during bootstrap from the target project context
2. Generate root `AGENTS.md` as a short pointer to `.samourai/AGENTS.md`
3. Customize or approve the generated sections for your project:
   - **"What this repo is"** — describe your project, not Samourai
   - **"Repo structure"** — match your actual directory layout
   - **"Key references"** — update paths to your project's docs
4. Generate the **Delivery process**, **Agent team**, and **Commands** sections from installed Samourai capabilities
5. Update agent/command counts if you add custom agents

**Key content:**

- Project description and purpose
- Delivery process overview (10-phase workflow)
- Agent team inventory
- Commands table
- Repo structure tree
- Key references table

### 1.2 `.samourai/ai/agent/pm-instructions.md`

Configures the `@pm` agent for your specific issue tracker and workflow.

> **What goes here:** PM instructions contain ONLY information that is specific to your project and tracker. Do not repeat the standard Samourai change lifecycle (that lives in `.samourai/core/governance/conventions/change-lifecycle.md`). The goal is a lean file: the less you repeat, the less drifts.

#### Mandatory Sections

| Section | Purpose |
|---------|---------|
| **Tracker Configuration** | Which tracker is canonical (GitHub Issues / Jira / local markdown backlog), connection details, project keys |
| **Workflow States Mapping** | How Samourai lifecycle phases map to your tracker's statuses or labels |
| **Label Taxonomy** | Which labels the PM agent should use — at minimum `change` for all Samourai-managed items |
| **Backlog Source of Truth** | Explicit statement of where the backlog lives to prevent duplicate sources |

#### Recommended Extensions

| Extension | When to add | Example |
|-----------|------------|---------|
| **Issue Validation Checklist** | When tickets often start without enough context | "Check labels are set, status is not Blocked, epic context is read" |
| **Priority & Selection Rules** | When PM needs to auto-select the next issue | "In-progress takes precedence, then `priority:high`, then oldest" |
| **Quality Gate References** | When repo has specific scripts to run before PR/MR | "Run `scripts/quality-gates.sh` via `@runner`" |
| **Blocking Question Workflow** | When human approval gates exist | "Add comment with question, assign to human, set `blocked` label, STOP" |
| **Multi-Repo Coordination** | When changes span multiple repos | "Use `todo-<repo>`/`done-<repo>` labels; see inventory table" |
| **Definition of Ready (DoR)** | When tickets need pre-conditions before work starts | 5-9 point checklist: AC defined, dependencies identified, etc. |
| **Estimation Methodology** | When team uses story points or T-shirt sizing | "Fibonacci scale (1-89), split at 100+, triangulate against reference stories" |
| **PR/MR Workflow Customizations** | When merge process has repo-specific steps | "Squash-only merge, i18n completeness check before MR, human-only merge" |
| **Decision Documentation** | When product decisions need formal records | "Delegate to `@architect`; use PDRs in `.samourai/docai/decisions/`" |

#### What NOT to include

- Do not repeat the standard Samourai change lifecycle — reference `.samourai/core/governance/conventions/change-lifecycle.md`
- Do not embed build/test commands — those belong in quality gate scripts or the project README
- Do not duplicate content across repos — if 5 repos share identical tracker config, extract it into a shared file
- Do not include volatile delivery schedules or backlogs — use separate planning docs
- Do not embed tool bug workarounds — document those in tool docs or fix them upstream

#### Example: GitHub Issues (Minimal)

```markdown
# PM Instructions

## Tracker Configuration

tracker: github
owner: <your-github-org-or-username>
repo: <your-repo-name>

## Workflow Mapping

| Phase | GitHub Label | Notes |
|-------|-------------|-------|
| Planning started | `in-progress` | Applied when PM begins work |
| Ready for review | `review` | Applied when PR is ready |
| Done | (close issue) | Issue closed after merge |

## Labels

- `change` — all changes managed by Samourai
- `bug`, `feature`, `docs` — issue type labels
- `priority:high`, `priority:medium`, `priority:low` — priority levels

## Backlog Source of Truth

GitHub Issues is the only backlog. Do not create or rely on local backlog files.

## Conventions

- workItemRef format: `GH-<number>` (e.g., `GH-123`)
- Branch naming: `<type>/GH-<number>/<slug>`
```

#### Example: Jira (with common extensions)

```markdown
# PM Instructions

## Tracker Configuration

tracker: jira
project_key: <YOUR-PROJECT-KEY>
base_url: https://<your-domain>.atlassian.net

## Workflow Mapping

| Phase | Jira Status | Transition ID | Notes |
|-------|-------------|---------------|-------|
| Planning started | In Progress | 21 | |
| Spec/Plan/Tests created | In Progress | — | No transition needed |
| Delivery started | In Progress | — | |
| Ready for review | In Review | 31 | |
| Done | Done | 41 | |
| Blocked | Blocked | 51 | Set when waiting on human input |

## Labels

- `change` — all changes managed by Samourai
- `todo-<repo-name>`, `done-<repo-name>` — per-repo tracking (for multi-repo setups)

## Backlog Source of Truth

Jira is the canonical backlog. Query: project = <KEY> AND labels = "change" AND status != Done ORDER BY priority DESC, created ASC

## Issue Validation Checklist

Before starting any issue:
1. Verify `change` label is applied
2. Check status is not `Blocked`
3. Read parent epic (if any) for wider context
4. Confirm acceptance criteria exist in description

## Conventions

- workItemRef format: `<PROJECT>-<number>` (e.g., `PDEV-123`)
- Branch naming: `<type>/<PROJECT>-<number>/<slug>`
```

#### Example: Local Markdown Backlog (Git-native)

For solo developers or small teams without an external tracker, Samourai supports a fully Git-managed backlog. The backlog table tracks order and status; the actual content lives in structured files.

**Directory structure:**

```
.samourai/docai/planning/
├── backlog.md                              # Active backlog (order + status)
├── archive/
│   └── backlog-2026-03-01.md               # Archived completed items
└── epics/
    ├── EPIC-1--onboarding-flow/
    │   ├── EPIC-1--onboarding-flow.md       # Epic overview: goals, scope, success criteria
    │   ├── STORY-1--user-registration.md    # Story detail: AC, context, notes
    │   ├── STORY-2--email-verification.md
    │   └── BUG-3--signup-validation.md
    └── EPIC-2--payment-integration/
        ├── EPIC-2--payment-integration.md
        ├── STORY-4--stripe-checkout.md
        └── STORY-5--invoice-generation.md
```

**How it works:**

- **`backlog.md`** is the single view of active work — a lightweight table with delivery order, status, and priority. It does NOT contain requirements or acceptance criteria.
- **Epic folders** (`.samourai/docai/planning/epics/<EPIC-ID>--<slug>/`) hold the real content: an epic document describing overall goals, and individual story/bug files with full descriptions, AC, and context.
- **Planning a new epic** starts by creating the epic folder and document, then breaking it into stories with their own files, then adding rows to `backlog.md`.
- **Archiving**: periodically move completed items from `backlog.md` to `.samourai/docai/planning/archive/backlog-<YYYY-MM-DD>.md` to keep the active backlog focused. Archive when the done section exceeds ~20 items or at sprint/milestone boundaries.

```markdown
# PM Instructions

## Tracker Configuration

tracker: local
backlog_file: .samourai/docai/planning/backlog.md
epics_dir: .samourai/docai/planning/epics
archive_dir: .samourai/docai/planning/archive

## Backlog File Format

The backlog is an ordered table. Top item = highest priority. The PM delivers
items top-to-bottom unless dependencies require reordering.

| # | ID | Title | Status | Priority | Labels | Epic |
|---|-----|-------|--------|----------|--------|------|
| 1 | STORY-1 | User registration | todo | high | feature | EPIC-1 |
| 2 | STORY-2 | Email verification | todo | high | feature | EPIC-1 |
| 3 | BUG-3 | Signup validation error | todo | high | bug | EPIC-1 |
| 4 | STORY-4 | Stripe checkout | todo | medium | feature | EPIC-2 |

Status values: `todo`, `in-progress`, `review`, `done`, `blocked`

## Work Item Documentation

Each story or bug has a dedicated file in its epic folder:
- Path: `.samourai/docai/planning/epics/<EPIC-ID>--<slug>/<ID>--<slug>.md`
- Contains: description, acceptance criteria, context, dependencies, notes
- The backlog table links to these files by ID — the file is the source of truth
  for requirements, the table row is the source of truth for status and order.

Epic documents describe the overall goal, success criteria, and scope.
Stories reference their parent epic for context.

## Workflow Mapping

| Phase | Backlog Status |
|-------|---------------|
| Planning started | in-progress |
| Ready for review | review |
| Done | done |
| Blocked | blocked |

## Backlog Archiving

When the backlog accumulates more than ~20 completed items (or at milestone
boundaries), archive them:
1. Cut all `done` rows from `backlog.md`
2. Paste into `.samourai/docai/planning/archive/backlog-<YYYY-MM-DD>.md`
3. Keep epic folders intact (they are the permanent record)

## Labels

- feature, bug, docs, infra, tech-debt

## Conventions

- workItemRef format: `STORY-<number>` or `BUG-<number>`
- Epic ID format: `EPIC-<number>`
- Branch naming: `<type>/STORY-<number>/<slug>`
- Numbering is sequential across all types (STORY-1, STORY-2, BUG-3, STORY-4...)
```

> **Tip:** Start minimal. You can always add extensions later as your workflow matures. The leanest effective PM instructions file is ~30 lines; the richest is ~300 lines.

### 1.3 `.samourai/docai/documentation-handbook.md`

The canonical documentation standard for the target project. Generate it during bootstrap when the repository needs shared documentation rules.

**Setup:**

1. Create `.samourai/docai/documentation-handbook.md` in your project root
2. Keep it project-specific and concise
3. Use it to align agents and humans on documentation conventions

---

## Step 2: Recommended Artifacts (Optional)

> **Note:** The kit installer provides reusable resources under `.samourai/core/**`. Project-owned docs below should be generated only when they are useful for the target repository.

These artifacts improve the Samourai experience but are not strictly required. Set them up incrementally as your project grows.

### 2.1 `.samourai/docai/00-index.md` — Documentation Landing Page

A table of contents for your project's documentation. Helps humans and agents navigate.

**Setup:** Copy from Samourai and update links to match your project's actual docs.

### 2.2 `.samourai/docai/overview/` — Project Overview

High-level project context:

- `01-north-star.md` — Vision, mission, and product direction
- `02-roadmap.md` — High-level phases and milestones
- `architecture-overview.md` — System architecture diagrams
- `glossary.md` — Terms and acronyms used in the project

### 2.3 `.samourai/docai/spec/features/` — Feature Specifications

Current-truth descriptions of your system's features. Use `.samourai/core/templates/feature-spec-template.md` as the structural guide.

### 2.4 `.samourai/core/templates/` — Document Templates

**Auto-installed** by the Samourai installer.

The installer copies reusable Samourai templates into `.samourai/core/templates/`:

- `change-spec-template.md`
- `decision-record-template.md`
- `feature-spec-template.md`
- `test-spec-template.md`
- `test-plan-template.md`
- `implementation-plan-template.md`
- `north-star-template.md`

Agents read these at runtime to guide document structure.

### 2.5 `.samourai/core/decisions/` — Decision Record Kit

**Auto-installed** by the Samourai installer.

The installer copies reusable decision-record setup references into `.samourai/core/decisions/`:

1. `.samourai/core/decisions/README.md`
2. `.samourai/core/decisions/00-index.md`
3. See [Decision Records Management Guide](decision-records-management.md) for the full standard

### 2.6 `.samourai/docai/guides/` — Project-Specific Guides

Add guides as needed:

- Local development setup
- Debugging procedures
- Testing strategy
- Deployment workflows

---

## Step 3: Decision Records Setup

If your project makes architectural, product, or technical decisions, set up decision records:

1. Create `.samourai/docai/decisions/` directory with project-specific `README.md` and `00-index.md`
2. Read the [Decision Records Management Guide](decision-records-management.md) for:
   - Decision types (ADR, PDR, TDR, BDR, ODR)
   - Naming convention (`<TYPE>-<zeroPad4>-<slug>.md`)
   - Lifecycle (Proposed → Under Review → Accepted)
   - Governance (who proposes, reviews, accepts)
3. Use `/plan-decision` + `/write-decision` to create your first decision record

---

## Step 4: First Change Walkthrough

Once your mandatory artifacts are in place, try running the full 10-phase workflow on a real change:

### Using Autopilot (Recommended)

```
@pm deliver change GH-1
```

The `@pm` agent will orchestrate all 10 phases:

1. **Clarify scope** — PM reads the ticket and cross-checks against system spec
2. **Specification** — `@spec-writer` creates the change spec
3. **Test planning** — `@test-plan-writer` creates the test plan
4. **Delivery planning** — `@plan-writer` creates the implementation plan
5. **Delivery** — `@coder` executes the plan phases
6. **System spec update** — `@doc-syncer` reconciles docs
7. **Review** — `@reviewer` audits against spec/plan
8. **Quality gates** — `@runner` runs builds/tests/lint
9. **DoD check** — PM verifies all criteria met
10. **PR creation** — `@pr-manager` creates the PR

### Using Manual Commands

```
/plan-change GH-1
/write-spec GH-1
/write-test-plan GH-1
/write-plan GH-1
/run-plan GH-1
/review GH-1
/sync-docs GH-1
/check
/pr
```

---

## Troubleshooting

### "Agent can't find my issue tracker"

Ensure `.samourai/ai/agent/pm-instructions.md` exists and has the correct tracker configuration. The `@pm` agent reads this file first.

### "Templates are not being used"

Verify `.samourai/core/templates/` exists and contains the template files. Agents fall back to embedded defaults if templates are absent — this is expected behavior, not an error.

### "Decision records workflow doesn't work"

Ensure `.samourai/docai/decisions/` directory exists. The `@architect` agent writes decision records there. See [Decision Records Management Guide](decision-records-management.md).

### "Change artifacts are in the wrong location"

Check `.samourai/AGENTS.md` for the correct folder pattern: `.samourai/docai/changes/YYYY-MM/YYYY-MM-DD--<workItemRef>--<slug>/`. The `@pm` agent creates this structure automatically.

### "Agents reference files that don't exist"

Run a fresh Samourai onboarding — some referenced directories (like `.samourai/docai/overview/`, `.samourai/docai/spec/`) need to be created. Create them with README.md stubs and populate incrementally.

### "PM agent can't read or update tickets" / MCP tracker setup

The `@pm` and `@pr-manager` agents need MCP (Model Context Protocol) access to your issue tracker to read tickets, update statuses, and enrich PR descriptions. Other agents do **not** need tracker access.

**Best practice: disable tracker MCP globally, enable per agent.**

This follows the principle of least privilege — only agents that need tracker access get it. This prevents other agents from accidentally modifying tickets.

**GitHub Issues setup** (in `.opencode/opencode.jsonc`):

```jsonc
{
  "mcp": {
    "github-mcp": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-github"],
      "environment": {
        // Settings → Developer Settings → Personal access tokens (classic)
        // Permissions: repo, read:org, user
        "GITHUB_PERSONAL_ACCESS_TOKEN": "{env:GITHUB_API_TOKEN}"
      },
      "enabled": true
    }
  },
  "tools": {
    "github*": false          // disabled globally for all agents
  },
  "agent": {
    "pm": {
      "tools": {
        "github*": true       // PM can read/update issues
      }
    },
    "pr-manager": {
      "tools": {
        "github*": true       // PR manager reads tickets for context
      }
    }
  }
}
```

**Jira setup** (in `~/.config/opencode/opencode.jsonc` — global, or per-project):

```jsonc
{
  "mcp": {
    "jira-mcp": {
      "type": "local",
      "command": ["uvx", "mcp-atlassian"],
      "environment": {
        "JIRA_URL": "https://<your-domain>.atlassian.net/",
        "JIRA_USERNAME": "{env:JIRA_USERNAME}",
        "JIRA_API_TOKEN": "{env:JIRA_API_TOKEN}"
      },
      "timeout": 60000
    }
  },
  "tools": {
    "jira*": false            // disabled globally
  },
  "agent": {
    "pm": {
      "tools": {
        "jira*": true         // PM can read/update Jira issues
      }
    },
    "pr-manager": {
      "tools": {
        "jira*": true         // PR manager reads tickets for context
      }
    }
  }
}
```

**Key points:**

- **Global vs project config:** MCP servers can be declared in the global config (`~/.config/opencode/opencode.jsonc`) and shared across projects, or per-project in `.opencode/opencode.jsonc`. Tool permissions (`"tools"` and `"agent"` blocks) are always per-project.
- **Multiple Jira instances:** If you work across multiple Jira instances, declare each with a unique MCP name (e.g., `jira-projecta-mcp`, `jira-projectb-mcp`) in the global config. Each can have different credentials and URLs.
- **Why `@pr-manager` needs access:** It reads ticket descriptions and comments to enrich PR descriptions with the "why" behind changes. Without MCP access, PRs will still be created but without ticket context.
- **Environment variables:** Store API tokens in environment variables (e.g., `GITHUB_API_TOKEN`, `JIRA_API_TOKEN`), not directly in config files. OpenCode resolves `{env:VAR_NAME}` at runtime.
- **Verification:** Run `@pm deliver change <ref>` — if the PM agent can read the ticket, MCP is working. If you see "MCP tools unavailable" warnings, check your config and token setup.

---

## Related Guides

| Guide | Description |
|-------|-------------|
| [Change Lifecycle](change-lifecycle.md) | Detailed 10-phase delivery workflow |
| [Change Convention](unified-change-convention-tracker-agnostic-specification.md) | Naming, folders, branches |
| [Agents & Commands Guide](opencode-agents-and-commands-guide.md) | How to use agents and commands |
| [Tools Convention](tools-convention.md) | Standard for building CLI tools |
| `.samourai/docai/documentation-handbook.md` | Repository documentation standard |
| [Decision Records Management](decision-records-management.md) | Decision record types, lifecycle, governance |
