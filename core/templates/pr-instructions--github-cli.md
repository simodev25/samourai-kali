# PR Instructions Template — GitHub CLI

Copy this file to `.samourai/ai/agent/pr-instructions.md` and adapt values.

## Platform

- type: github
- tool: gh CLI

## Required operations mapping

- Check auth: `gh auth status`
- List open PRs for branch: `gh pr list --state open --head <branch> --json number,url,baseRefName,headRefName,updatedAt`
- View PR: `gh pr view <number> --json number,url,title,body,baseRefName,headRefName`
- Create PR: `gh pr create --base <base> --head <branch> --title <title> --body-file <bodyFile>`
- Update PR: `gh pr edit <number> --title <title> --body-file <bodyFile> --base <base>`
