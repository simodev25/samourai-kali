---
#
description: Execute quality gates, fix any issues found, and create a single high-quality Conventional Commit summarizing all changes made.
agent: fixer
subtask: true
---

Before starting, discover generated project skills in `.opencode/skills/project/**/SKILL.md`, select up to 2 relevant to build/test/ci/debug, and apply them as local constraints.
Report `project_skills_applied` in the final summary (or an empty list if none).

Before starting, read `.samourai/ai/agent/project-profile.md` when present and apply it to the correction strategy:
- TMA: minimal fix, regression protection, preserve existing behavior.
- Build: preserve feature intent, coverage, and release readiness.
- Guide: fix clarity, accuracy, links, and audience fit.
- Mix: classify the failure and apply the matching mode.
Report `project_profile_applied` in the final summary (or `none` if absent).

Run quality gates and make sure everything is fine.
If you find any issues then systematically fix them.
If project specifies fast quality gates check the first execute only those.
Once fast quality gates are passed then proceed to run the full quality gates and fix any issues found.
Finally, create a single high-quality Conventional Commit with a clear message summarizing all changes made to fix the
issues by delegating entirely to the @committer agent.
