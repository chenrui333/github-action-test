package agent

import (
	"context"
	"testing"
)

// MockTask is a simple task for testing
type MockTask struct {
	name string
}

func (m *MockTask) Name() string {
	return m.name
}

func (m *MockTask) Run(ctx context.Context, params map[string]any) error {
	return nil
}

func TestRegistry(t *testing.T) {
	registry := NewRegistry()

	// Test registration
	task1 := &MockTask{name: "task1"}
	task2 := &MockTask{name: "task2"}
	registry.Register(task1)
	registry.Register(task2)

	// Test retrieval
	retrieved, err := registry.Get("task1")
	if err != nil {
		t.Fatalf("Failed to get task1: %v", err)
	}
	if retrieved.Name() != "task1" {
		t.Errorf("Expected task name 'task1', got '%s'", retrieved.Name())
	}

	// Test not found
	_, err = registry.Get("nonexistent")
	if err == nil {
		t.Error("Expected error for nonexistent task, got nil")
	}

	// Test list
	names := registry.List()
	if len(names) != 2 {
		t.Errorf("Expected 2 tasks, got %d", len(names))
	}
}
