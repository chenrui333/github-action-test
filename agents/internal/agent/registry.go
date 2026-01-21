package agent

import (
	"fmt"
	"sync"
)

// Registry manages task registration and retrieval.
type Registry struct {
	mu    sync.RWMutex
	tasks map[string]Task
}

// NewRegistry creates a new task registry.
func NewRegistry() *Registry {
	return &Registry{
		tasks: make(map[string]Task),
	}
}

// Register adds a task to the registry.
func (r *Registry) Register(task Task) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.tasks[task.Name()] = task
}

// Get retrieves a task by name.
func (r *Registry) Get(name string) (Task, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	task, ok := r.tasks[name]
	if !ok {
		return nil, fmt.Errorf("task not found: %s", name)
	}
	return task, nil
}

// List returns all registered task names.
func (r *Registry) List() []string {
	r.mu.RLock()
	defer r.mu.RUnlock()
	names := make([]string, 0, len(r.tasks))
	for name := range r.tasks {
		names = append(names, name)
	}
	return names
}
