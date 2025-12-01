package main

import (
	"context"
	"flag"
	"fmt"
	"os"

	"github.com/chenrui333/github-action-test/agents/internal/agent"
	"github.com/chenrui333/github-action-test/agents/internal/plan"
	"github.com/chenrui333/github-action-test/agents/internal/tasks"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	var (
		planFile  = flag.String("plan", "", "Path to YAML plan file")
		listTasks = flag.Bool("list", false, "List available tasks")
	)
	flag.Parse()

	// Initialize registry and register tasks
	registry := agent.NewRegistry()
	registry.Register(&tasks.HurlTask{})
	registry.Register(&tasks.RepoDispatchTask{})
	registry.Register(&tasks.ArchiveTask{})

	// Handle list command
	if *listTasks {
		fmt.Println("Available tasks:")
		for _, name := range registry.List() {
			fmt.Printf("  - %s\n", name)
		}
		return nil
	}

	// Require plan file
	if *planFile == "" {
		return fmt.Errorf("plan file is required (use -plan flag)")
	}

	// Load and parse plan
	planner := plan.NewYAMLPlanner()
	steps, err := planner.FromFile(*planFile)
	if err != nil {
		return fmt.Errorf("failed to load plan: %w", err)
	}

	fmt.Printf("Loaded plan with %d step(s)\n", len(steps))

	// Execute plan
	runner := agent.NewRunner(registry)
	ctx := context.Background()
	if err := runner.Run(ctx, steps); err != nil {
		return fmt.Errorf("execution failed: %w", err)
	}

	fmt.Println("All steps completed successfully")
	return nil
}
