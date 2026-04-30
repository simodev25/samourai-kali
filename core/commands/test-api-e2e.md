---
description: Run security scanning/security audit workflows through the repository's configured scan command(s).
agent: runner
---

<purpose>
Run this repository's security scans and return a concise summary with runner log pointers.

Scans may include network, web, static analysis, and code security checks. Docker or Compose may be part of a project's setup, but Docker is not required by this command unless the resolved project command uses it.
</purpose>

<command>
User invocation:
  /test-api-e2e [quick|standard|thorough|<target>] [--dry-run]

Examples:
/test-api-e2e
/test-api-e2e quick
/test-api-e2e standard
/test-api-e2e thorough
/test-api-e2e web
/test-api-e2e --dry-run
</command>

<inputs>
<arguments>$ARGUMENTS</arguments>

<parsing>
- `profile` = first positional token among `quick`, `standard`, `thorough`, or any custom target string.
- `--dry-run` = resolve and print the command without executing it.
- Unknown flags must produce `NEEDS_INPUT` with the supported usage.
  </parsing>
  </inputs>

<resolution>
Resolve security scan command(s) from repository root in this order:

1. Explicit project instruction:
   - Read `.samourai/AGENTS.md` (or root `AGENTS.md` as compatibility entrypoint).
   - Read `.samourai/ai/rules/testing-strategy.md` if present.
   - Prefer a command explicitly described as security scan, vuln scan, SAST, DAST, or recon scan.

2. Auto-discover common scan tools (when present in PATH or project scripts):
   - `nmap`
   - `nikto`
   - `sqlmap`
   - `semgrep`
   - `bandit`

3. `package.json` scripts, in priority order:
   - `scan:security`
   - `security:scan`
   - `scan`
   - `test:security`

   Use the package manager implied by lockfiles:
   - `pnpm-lock.yaml` → `pnpm run <script>`
   - `yarn.lock` → `yarn <script>`
   - `bun.lockb` or `bun.lock` → `bun run <script>`
   - otherwise → `npm run <script>`

4. `Makefile` targets, in priority order:
   - `scan-security`
   - `security-scan`
   - `scan`

   Use `make <target>`.

If no command or toolset is discoverable, STOP with:

```text
NEEDS_INPUT: no security scan command found
Define one in `.samourai/AGENTS.md`, root `AGENTS.md`, `.samourai/ai/rules/testing-strategy.md`, package.json, Makefile, or install one of: nmap, nikto, sqlmap, semgrep, bandit.
Usage: /test-api-e2e [quick|standard|thorough|<target>] [--dry-run]
```
</resolution>

<scan_profiles>
Apply scan profile selection to resolved command(s):

- `quick`: lightweight checks (e.g., fast semgrep/bandit rules, narrow nmap profile)
- `standard`: balanced baseline checks (default if omitted)
- `thorough`: deep checks with broader coverage and longer runtime

If a resolved command does not support explicit profile flags, map profile behavior by choosing tool presets or command subsets.
If profile mapping is ambiguous, STOP with `NEEDS_INPUT` and show the resolved base command(s).
</scan_profiles>

<argument_application>
After resolving base command(s):

- `<target>`: append or pass through only when the resolved tool has a standard target/filter form:
  - npm/pnpm/yarn/bun scripts: append `-- <target>`
  - semgrep: append `--include <target>` or project-supported equivalent
  - bandit: append target path/module
  - nmap/nikto/sqlmap: append target host/url/parameter only when explicitly supported
- If applying target is ambiguous, STOP with `NEEDS_INPUT` and show resolved command(s).
  </argument_application>

<dry_run>
If `--dry-run` is present:

1. Print `DRY_RUN`.
2. Print the resolved command(s).
3. Print the resolution source(s), such as `auto-discovered tool semgrep`.
4. Do not execute the command.
</dry_run>

<behavior>
- Run from repository root.
- Delegate execution to `@runner` by executing the exact resolved command(s).
- Save logs under `.samourai/tmpai/run-logs-runner/<YYYY-MM-DD>/` per runner rules.
- Report:
  - exact command(s)
  - resolution source(s)
  - scan profile
  - exit code
  - duration
  - log path(s)
  - top failure signal, if any
- Do not modify repository files.
- Do not fix failures.
- If the command fails, recommend `/check-fix` or `@fixer` for remediation.
</behavior>

<output>
Successful run:
- Status: SUCCESS
- Command(s): `<resolved command(s)>`
- Resolution source(s): `<source(s)>`
- Scan profile: `<quick|standard|thorough>`
- Artifacts: runner log/cmd/meta paths
- Summary: concise pass signal

Failed run:
- Status: FAILED
- Command(s): `<resolved command(s)>`
- Resolution source(s): `<source(s)>`
- Scan profile: `<quick|standard|thorough>`
- Artifacts: runner log/cmd/meta paths
- Top failure signal: first useful error snippet
- Next step: `/check-fix` or `@fixer`
</output>
