# Copilot Instructions for github-action-test

## Repository Overview

This repository is used for testing GitHub Actions and related automation workflows. It includes:

- **GitHub Actions workflows** in `.github/workflows/` for CI/CD, testing, and automation
- **Hurl test files** in `hurl/` for HTTP API testing
- **Agents framework** in `agents/` - a Go-based CLI tool for automated tasks
- **Docker container** with various tools (Terraform, conftest, Go tools)

## Development Guidelines

### Code Style

- **Go**: Follow idiomatic Go style, use `gofmt` and `goimports`
- **YAML**: Use consistent 2-space indentation
- **Shell scripts**: Use `#!/bin/bash` and `set -e` for error handling

### Testing

- Run existing tests before making changes
- Add tests for new functionality when appropriate
- Use Hurl for HTTP API testing

### Workflows

- Keep workflows focused and single-purpose
- Use pinned action versions with SHA comments
- Include `permissions:` blocks with minimal required permissions
- Use `continue-on-error: true` sparingly and document why

### Agents Framework

The `agents/` directory contains a lightweight Go-based task execution framework:

- **Core types**: Task interface, Planner, Registry, Runner
- **Built-in tasks**: hurl (run site checks), repo_dispatch (trigger events), archive (Wayback Machine)
- **YAML plans**: Define multi-step execution plans in YAML
- **CLI**: `agents -plan <file>` to execute plans, `agents -list` to see available tasks

When extending the agents framework:
- Keep it dependency-light (currently only uses `gopkg.in/yaml.v3`)
- Follow the Task interface for new tasks
- Add sample plans in `testdata/` for testing
- Update the CLI help and documentation

### Docker

- The Dockerfile uses a pinned golang:1.25 base image
- Tools are installed in versioned directories for easy updates
- The agents binary is built and installed at `/usr/local/bin/agents`

## Common Tasks

### Building the agents CLI

```bash
cd agents
go build -o bin/agents ./cmd/agents
```

### Running a plan

```bash
cd agents
./bin/agents -plan testdata/sample-plan.yaml
```

### Testing Hurl files

```bash
hurl --retry 5 --test --glob "hurl/chenrui.dev/*.hurl"
```

## Best Practices

1. **Minimal changes**: Make the smallest possible change to achieve the goal
2. **Test first**: Run existing tests to understand current state
3. **Incremental progress**: Make small commits with clear messages
4. **Documentation**: Update relevant docs when adding features
5. **Security**: Never commit secrets, use GitHub secrets for sensitive data
