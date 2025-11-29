package agent

import "context"

// Task defines the interface for executable tasks.
type Task interface {
	Name() string
	Run(ctx context.Context, params map[string]any) error
}

// Planner defines the interface for loading and parsing execution plans.
type Planner interface {
	FromYAML([]byte) ([]ExecStep, error)
}

// ExecStep represents a single step in an execution plan.
type ExecStep struct {
	Task   string         `yaml:"task"`
	Params map[string]any `yaml:"params"`
}
