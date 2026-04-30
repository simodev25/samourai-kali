# GitHub Blueprint

## Role

This blueprint structures a GitHub Pull Request and its review.

## When To Use

- Before creating a PR.
- To standardize PR descriptions.
- To prepare a review without publishing automatically.
- To flag PRs tied to security advisories.

## Expected Files

- `github-pr.blueprint.yaml`: PR contract.
- `pr-review.template.md`: review or PR description template.

## Security Advisory Note

Set `security_advisory: true` in the blueprint input when the PR contains vulnerability-sensitive content so the generated review marks it as security-sensitive.

## Minimal Example

```text
Prepare a PR description for branch feat/search-pagination.
```
