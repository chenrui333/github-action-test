# github action test

## Dockerfile Formatting

This repository uses [dockerfmt](https://github.com/reteps/dockerfmt) to maintain consistent Dockerfile formatting.

### Local Development

#### Install dockerfmt

```bash
go install github.com/reteps/dockerfmt@latest
```

#### Format Dockerfiles

To format all Dockerfiles in the repository:

```bash
make fmt
```

#### Check Formatting

To check if Dockerfiles are properly formatted:

```bash
make lint
```

### Pre-commit Hook (Optional)

To automatically format Dockerfiles before committing, install and configure pre-commit:

```bash
# Install pre-commit (if not already installed)
pip install pre-commit

# Install the hooks
pre-commit install

# Run manually on all files (optional)
pre-commit run --all-files
```

### CI Integration

The repository includes a GitHub Actions workflow (`.github/workflows/lint.yml`) that automatically checks Dockerfile formatting on:
- Pushes to `main` branch
- Pull requests

**Auto-formatting:** If any Dockerfile is not properly formatted, the workflow will:
1. Automatically format the files using `dockerfmt`
2. Commit the changes to the PR with the message "chore: format Dockerfiles with dockerfmt"
3. Push the changes back to the branch

This means you don't need to manually fix formatting issues - the bot will do it for you!
