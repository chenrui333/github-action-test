package plan

import (
	"testing"
)

func TestYAMLPlanner(t *testing.T) {
	planner := NewYAMLPlanner()

	yamlData := []byte(`
- task: hurl
  params:
    glob: "*.hurl"
    retries: 5
- task: archive
  params:
    url: "https://example.com"
`)

	steps, err := planner.FromYAML(yamlData)
	if err != nil {
		t.Fatalf("Failed to parse YAML: %v", err)
	}

	if len(steps) != 2 {
		t.Errorf("Expected 2 steps, got %d", len(steps))
	}

	if steps[0].Task != "hurl" {
		t.Errorf("Expected first task to be 'hurl', got '%s'", steps[0].Task)
	}

	if steps[1].Task != "archive" {
		t.Errorf("Expected second task to be 'archive', got '%s'", steps[1].Task)
	}

	// Check params
	if glob, ok := steps[0].Params["glob"].(string); !ok || glob != "*.hurl" {
		t.Errorf("Expected glob param to be '*.hurl', got '%v'", steps[0].Params["glob"])
	}

	if retries, ok := steps[0].Params["retries"].(int); !ok || retries != 5 {
		t.Errorf("Expected retries param to be 5, got '%v'", steps[0].Params["retries"])
	}
}

func TestYAMLPlannerFromFile(t *testing.T) {
	planner := NewYAMLPlanner()

	// Test with the sample plan file
	steps, err := planner.FromFile("../../testdata/sample-plan.yaml")
	if err != nil {
		t.Fatalf("Failed to load sample plan: %v", err)
	}

	if len(steps) < 1 {
		t.Errorf("Expected at least 1 step in sample plan, got %d", len(steps))
	}
}
