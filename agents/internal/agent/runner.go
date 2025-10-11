package agent

import (
	"context"
	"fmt"
)

// Runner executes a sequence of task steps.
type Runner struct {
	registry *Registry
}

// NewRunner creates a new task runner with the given registry.
func NewRunner(registry *Registry) *Runner {
	return &Runner{
		registry: registry,
	}
}

// Run executes the given steps sequentially, stopping on first error.
func (r *Runner) Run(ctx context.Context, steps []ExecStep) error {
	for i, step := range steps {
		task, err := r.registry.Get(step.Task)
		if err != nil {
			return fmt.Errorf("step %d: %w", i+1, err)
		}

		fmt.Printf("Running step %d: %s\n", i+1, task.Name())
		if err := task.Run(ctx, step.Params); err != nil {
			return fmt.Errorf("step %d (%s) failed: %w", i+1, task.Name(), err)
		}
		fmt.Printf("Step %d completed successfully\n", i+1)
	}
	return nil
}
