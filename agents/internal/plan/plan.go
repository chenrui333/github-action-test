package plan

import (
	"fmt"
	"os"

	"github.com/chenrui333/github-action-test/agents/internal/agent"
	"gopkg.in/yaml.v3"
)

// YAMLPlanner implements the Planner interface for YAML-based plans.
type YAMLPlanner struct{}

// NewYAMLPlanner creates a new YAML planner.
func NewYAMLPlanner() *YAMLPlanner {
	return &YAMLPlanner{}
}

// FromYAML parses a YAML byte array into execution steps.
func (p *YAMLPlanner) FromYAML(data []byte) ([]agent.ExecStep, error) {
	var steps []agent.ExecStep
	if err := yaml.Unmarshal(data, &steps); err != nil {
		return nil, fmt.Errorf("failed to parse YAML: %w", err)
	}
	return steps, nil
}

// FromFile loads and parses a YAML plan from a file.
func (p *YAMLPlanner) FromFile(filename string) ([]agent.ExecStep, error) {
	data, err := os.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to read file: %w", err)
	}
	return p.FromYAML(data)
}
