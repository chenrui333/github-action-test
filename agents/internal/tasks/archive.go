package tasks

import (
	"context"
	"fmt"

	"github.com/chenrui333/github-action-test/agents/internal/util"
)

// ArchiveTask archives a URL to the Wayback Machine.
type ArchiveTask struct{}

// Name returns the task name.
func (a *ArchiveTask) Name() string {
	return "archive"
}

// Run executes the archive operation.
func (a *ArchiveTask) Run(ctx context.Context, params map[string]any) error {
	// Required parameter
	url, ok := params["url"].(string)
	if !ok || url == "" {
		return fmt.Errorf("url parameter is required")
	}

	// Wayback Machine save API endpoint
	saveURL := fmt.Sprintf("https://web.archive.org/save/%s", url)

	// Execute curl command to trigger archival
	cmd := fmt.Sprintf(`curl -s -o /dev/null -w "%%{http_code}" "%s"`, saveURL)

	fmt.Printf("Archiving URL to Wayback Machine: %s\n", url)
	output, err := util.RunShell(ctx, cmd)
	if err != nil {
		return fmt.Errorf("archive request failed: %w", err)
	}

	// Check HTTP status code
	fmt.Printf("Archive request completed with status: %s\n", output)
	return nil
}
