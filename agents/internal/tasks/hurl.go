package tasks

import (
	"context"
	"fmt"

	"github.com/chenrui333/github-action-test/agents/internal/util"
)

// HurlTask runs Hurl tests with configurable glob pattern and retries.
type HurlTask struct{}

// Name returns the task name.
func (h *HurlTask) Name() string {
	return "hurl"
}

// Run executes the Hurl tests.
func (h *HurlTask) Run(ctx context.Context, params map[string]any) error {
	// Default values
	glob := "hurl/chenrui.dev/*.hurl"
	retries := 3

	// Parse parameters
	if g, ok := params["glob"].(string); ok {
		glob = g
	}
	if r, ok := params["retries"].(int); ok {
		retries = r
	}
	if r, ok := params["retries"].(float64); ok {
		retries = int(r)
	}

	// Build command
	cmd := fmt.Sprintf("hurl --retry %d --test --glob \"%s\"", retries, glob)

	fmt.Printf("Executing: %s\n", cmd)
	output, err := util.RunShell(ctx, cmd)
	if err != nil {
		return fmt.Errorf("hurl test failed: %w", err)
	}

	fmt.Println(output)
	return nil
}
