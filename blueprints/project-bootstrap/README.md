# Lab Bootstrap Blueprint

## Role

This blueprint initializes a security lab with baseline Samourai instructions: lab context, agent conventions, target environment references, and engagement guardrails.

## When To Use

- When onboarding an existing security lab repository.
- After installing the kit into a new cybersecurity target lab.
- When `.samourai/AGENTS.md` must be created or realigned for lab operations.

## Expected Files

- `project-bootstrap.blueprint.yaml`: generation contract.
- `AGENTS.template.md`: project-instructions template.

## Minimal Example

```text
Generate .samourai/AGENTS.md for a web security lab using
blueprints/project-bootstrap/project-bootstrap.blueprint.yaml.
```
