---
#
description: Execute evidence quality gates, verify remediation effectiveness, and create a single high-quality Conventional Commit summarizing all changes made.
agent: fixer
subtask: true
---

Before starting, discover generated project skills in `.opencode/skills/project/**/SKILL.md`, select up to 2 relevant to security validation/forensics/ci/debug, and apply them as local constraints.
Report `project_skills_applied` in the final summary (or an empty list if none).

Before starting, read `.samourai/ai/agent/project-profile.md` when present and apply it to the correction strategy:
- TMA: minimal fix, regression protection, preserve existing behavior.
- Build: preserve feature intent, coverage, and release readiness.
- Guide: fix clarity, accuracy, links, and audience fit.
- Mix: classify the failure and apply the matching mode.
Report `project_profile_applied` in the final summary (or `none` if absent).

Run evidence quality gates and make sure everything is fine.
If you find any issues then systematically fix them.
If project specifies fast evidence checks then first execute only those.
Once fast evidence quality gates are passed then proceed to run the full evidence quality gates and fix any issues found.

After quality gates pass, verify remediation effectiveness:
1. Re-run vulnerability validation in the approved scope.
2. Confirm the vulnerability is resolved.
3. Check for regressions or newly introduced exposure paths.
4. Update remediation evidence with reproducible validation notes.

Finally, create a single high-quality Conventional Commit with a clear message summarizing all changes made to verify and harden remediation by delegating entirely to the @committer agent.

<inputs>
  <item>arguments='$ARGUMENTS' — Optional user directives for scope, priorities, or execution mode.</item>
  <item>context — Existing remediation changes and evidence quality gate configuration in the repository.</item>
</inputs>

<output>
  <item>On success: all required evidence quality gates pass, remediation validation is confirmed, and a single Conventional Commit is created via @committer.</item>
  <item>On failure: blocked gates or unresolved remediation gaps are reported with actionable next steps; no false success claim is made.</item>
  <item>Final summary must include `project_skills_applied` and `project_profile_applied`.</item>
</output>

<kali_execution_context>
  <tools>nmap, nuclei, nikto, sqlmap, ffuf, gobuster, tcpdump, searchsploit, semgrep</tools>
  <preflight>When this prompt plans, reviews, publishes, or coordinates tool-dependent work, run or request `command -v nmap nuclei nikto sqlmap ffuf gobuster tcpdump searchsploit semgrep || true` and record missing tools.</preflight>
  <input_expected>workItemRef or task context, relevant evidence paths, authorized scope boundaries if security execution is involved, and expected downstream artifact.</input_expected>
  <safe_defaults>This prompt must not execute active scans by itself unless its assigned agent is a cyber execution agent. Delegate execution to `@runner` or the specialized cyber agent and preserve lab-only authorization gates.</safe_defaults>
  <command_examples>
    command -v nmap nuclei nikto sqlmap ffuf gobuster tcpdump searchsploit semgrep || true
    rg -n "nmap|nuclei|nikto|sqlmap|ffuf|gobuster|tcpdump|searchsploit|semgrep" .samourai/docai .samourai/tmpai core || true
  </command_examples>
  <structured_output>Structured prompt output with delegated agent/tool, input contract, expected evidence fields, missing tools, limitations, and next step.</structured_output>
</kali_execution_context>
