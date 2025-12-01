# Agents - Task Execution Framework

A lightweight, extensible Go framework for running automated tasks via YAML-based execution plans.

## Features

- **Task Interface**: Simple interface for creating executable tasks
- **Registry Pattern**: Register and manage tasks by name
- **Sequential Execution**: Run tasks in order, stop on first failure
- **YAML Plans**: Define multi-step execution plans in YAML
- **Built-in Tasks**:
  - `hurl`: Run Hurl HTTP tests with configurable patterns and retries
  - `repo_dispatch`: Trigger GitHub repository_dispatch events
  - `archive`: Archive URLs to the Wayback Machine

## Building

```bash
go build -o bin/agents ./cmd/agents
```

## Usage

### List available tasks

```bash
./bin/agents -list
```

### Execute a plan

```bash
./bin/agents -plan testdata/sample-plan.yaml
```

## Creating Plans

Plans are YAML files with a list of tasks and their parameters:

```yaml
- task: hurl
  params:
    glob: "hurl/chenrui.dev/*.hurl"
    retries: 5

- task: archive
  params:
    url: "https://example.com"

- task: repo_dispatch
  params:
    event_type: "trigger-event"
    owner: "myorg"
    repo: "myrepo"
    client_payload:
      key: "value"
```

## Task Parameters

### hurl

- `glob` (string, default: `"hurl/chenrui.dev/*.hurl"`): File pattern for Hurl test files
- `retries` (int, default: `3`): Number of retries for failed requests

### archive

- `url` (string, required): URL to archive to the Wayback Machine

### repo_dispatch

- `event_type` (string, default: `"trigger-event"`): GitHub event type
- `owner` (string, default: `"chenrui333"`): Repository owner
- `repo` (string, default: `"github-action-test"`): Repository name
- `client_payload` (map, optional): Custom payload data

**Note**: `repo_dispatch` requires the `GITHUB_TOKEN` environment variable.

## Architecture

```
agents/
├── cmd/agents/          # CLI entry point
├── internal/
│   ├── agent/          # Core types (Task, Registry, Runner)
│   ├── tasks/          # Built-in task implementations
│   ├── plan/           # YAML plan parser
│   └── util/           # Utilities (shell execution)
└── testdata/           # Sample plans
```

## Adding New Tasks

1. Create a new file in `internal/tasks/`
2. Implement the `Task` interface:
   ```go
   type MyTask struct{}
   
   func (t *MyTask) Name() string {
       return "mytask"
   }
   
   func (t *MyTask) Run(ctx context.Context, params map[string]any) error {
       // Implementation
       return nil
   }
   ```
3. Register the task in `cmd/agents/main.go`:
   ```go
   registry.Register(&tasks.MyTask{})
   ```
