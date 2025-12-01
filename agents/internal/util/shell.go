package util

import (
	"context"
	"fmt"
	"os/exec"
	"strings"
)

// RunCommand executes a shell command and returns output or error.
func RunCommand(ctx context.Context, name string, args ...string) (string, error) {
	cmd := exec.CommandContext(ctx, name, args...)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return string(output), fmt.Errorf("command failed: %w\noutput: %s", err, string(output))
	}
	return strings.TrimSpace(string(output)), nil
}

// RunShell executes a shell command string using sh -c.
func RunShell(ctx context.Context, command string) (string, error) {
	return RunCommand(ctx, "sh", "-c", command)
}
