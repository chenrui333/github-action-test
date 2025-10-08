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

The workflow will fail if any Dockerfile is not properly formatted. To fix formatting issues, run `make fmt` locally and commit the changes.
