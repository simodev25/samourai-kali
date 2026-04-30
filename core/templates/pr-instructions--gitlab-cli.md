# PR Instructions Template — GitLab CLI

Copy this file to `.samourai/ai/agent/pr-instructions.md` and adapt values.

## Platform

- type: gitlab
- tool: glab CLI

## Required operations mapping

- Check auth: `glab auth status`
- List open MRs for branch: `glab mr list --state opened --source-branch <branch>`
- View MR: `glab mr view <iid>`
- Create MR: `glab mr create --source-branch <branch> --target-branch <base> --title <title> --description-file <bodyFile>`
- Update MR: `glab mr update <iid> --title <title> --description-file <bodyFile> --target-branch <base>`
