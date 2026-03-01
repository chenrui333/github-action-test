package tasks

import (
	"context"
	"encoding/json"
	"fmt"
	"os"

	"github.com/chenrui333/github-action-test/agents/internal/util"
)

// RepoDispatchTask triggers a repository_dispatch event via GitHub API.
type RepoDispatchTask struct{}

// Name returns the task name.
func (r *RepoDispatchTask) Name() string {
	return "repo_dispatch"
}

// Run executes the repository dispatch.
func (r *RepoDispatchTask) Run(ctx context.Context, params map[string]any) error {
	// Required parameters
	eventType, ok := params["event_type"].(string)
	if !ok || eventType == "" {
		eventType = "trigger-event"
	}

	owner, ok := params["owner"].(string)
	if !ok || owner == "" {
		owner = "chenrui333"
	}

	repo, ok := params["repo"].(string)
	if !ok || repo == "" {
		repo = "github-action-test"
	}

	// Optional client payload
	payload := make(map[string]any)
	if p, ok := params["client_payload"].(map[string]any); ok {
		payload = p
	}

	// Get GitHub token from environment
	token := os.Getenv("GITHUB_TOKEN")
	if token == "" {
		return fmt.Errorf("GITHUB_TOKEN environment variable not set")
	}

	// Build JSON payload
	payloadJSON, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal payload: %w", err)
	}

	requestBody := fmt.Sprintf(`{"event_type":"%s","client_payload":%s}`, eventType, string(payloadJSON))

	// Execute curl command
	cmd := fmt.Sprintf(
		`curl -X POST -u "%s:%s" -H "Accept: application/vnd.github.everest-preview+json" -H "Content-Type: application/json" https://api.github.com/repos/%s/%s/dispatches --data '%s'`,
		owner, token, owner, repo, requestBody,
	)

	fmt.Printf("Triggering repository_dispatch event: %s\n", eventType)
	output, err := util.RunShell(ctx, cmd)
	if err != nil {
		return fmt.Errorf("repository dispatch failed: %w", err)
	}

	if output != "" {
		fmt.Println(output)
	}
	fmt.Println("Repository dispatch triggered successfully")
	return nil
}
