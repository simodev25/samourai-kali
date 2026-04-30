# PR Instructions Template — GitHub MCP

Copy this file to `.samourai/ai/agent/pr-instructions.md` and adapt values.

## Platform

- type: github
- tool: github MCP operations

## Required operations mapping

- Check auth: verify MCP server is enabled and token env is configured.
- List open PRs for branch: use GitHub MCP pull request listing filtered by head branch.
- View PR: use GitHub MCP get pull request details.
- Create PR: use GitHub MCP create pull request operation.
- Update PR: use GitHub MCP update pull request operation.
- Publish comments: use GitHub MCP issue/review comment operations.
