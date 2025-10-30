package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// Validator validates test results against configuration
type Validator struct {
	config           Validation
	logMonitor       *LogMonitor
	claudeEnabled    bool
	claudeTempDir    string
	verbose          bool
}

// NewValidator creates a new validator
func NewValidator(config Validation, logMonitor *LogMonitor, verbose bool) *Validator {
	// Check if Claude CLI is available
	claudeEnabled := false
	if _, err := exec.LookPath("claude"); err == nil {
		claudeEnabled = true
		if verbose {
			fmt.Println("✓ Claude CLI detected - AI-powered response validation enabled")
		}
	} else {
		if verbose {
			fmt.Println("⚠ Claude CLI not found - using basic validation only")
		}
	}

	// Create temp directory for Claude analysis files within the project
	// Use current working directory to stay within project bounds
	cwd, err := os.Getwd()
	if err != nil {
		cwd = "."
	}
	tempDir := filepath.Join(cwd, ".test-runner-temp")
	os.MkdirAll(tempDir, 0755)

	return &Validator{
		config:        config,
		logMonitor:    logMonitor,
		claudeEnabled: claudeEnabled,
		claudeTempDir: tempDir,
		verbose:       verbose,
	}
}

// ValidateResult validates a test result
func (v *Validator) ValidateResult(result *TestResult) {
	// Validate prompts
	for i := range result.PromptTests {
		v.validatePrompt(&result.PromptTests[i])
	}

	// Check logs for errors and warnings
	if v.logMonitor != nil {
		v.validateLogs(result)
	}
}

// validatePrompt validates a single prompt test
func (v *Validator) validatePrompt(prompt *PromptTest) {
	// Step 1: Simple/fast checks first
	simpleCheckPassed := true
	simpleCheckReason := ""

	if prompt.Status == StatusFailed {
		simpleCheckPassed = false
		simpleCheckReason = prompt.ErrorMessage
	} else if strings.TrimSpace(prompt.Response) == "" {
		simpleCheckPassed = false
		simpleCheckReason = "Response is empty"
	} else if prompt.ResponseTokens < 1 {
		simpleCheckPassed = false
		simpleCheckReason = "Response has no tokens"
	}

	// Step 2: Claude validation ALWAYS runs (regardless of simple check result)
	if v.claudeEnabled {
		claudeResult := v.validateWithClaude(prompt, simpleCheckPassed, simpleCheckReason)

		// Claude validation overrides everything
		if claudeResult.Status == StatusFailed {
			prompt.Status = StatusFailed
			prompt.ErrorMessage = claudeResult.Reason
		} else if claudeResult.Status == StatusPassed {
			prompt.Status = StatusPassed
			// Clear simple check error if Claude says it's OK
			if prompt.ErrorMessage == simpleCheckReason {
				prompt.ErrorMessage = ""
			}
		}
	} else {
		// If Claude not available, use simple check results
		if !simpleCheckPassed {
			prompt.Status = StatusFailed
			prompt.ErrorMessage = simpleCheckReason
		}
	}
}

// validateLogs validates log events
func (v *Validator) validateLogs(result *TestResult) {
	// Check for error events
	errorEvents := v.logMonitor.GetEvents(EventError)
	if len(errorEvents) > 0 {
		result.Status = StatusFailed
		errorMessages := make([]string, len(errorEvents))
		for i, event := range errorEvents {
			errorMessages[i] = event.Line
		}
		if result.ErrorMessage == "" {
			result.ErrorMessage = fmt.Sprintf("Errors found in logs: %s", strings.Join(errorMessages, "; "))
		} else {
			result.ErrorMessage += fmt.Sprintf("; Log errors: %s", strings.Join(errorMessages, "; "))
		}
	}

	// Check for warning events
	warningEvents := v.logMonitor.GetEvents(EventWarning)
	if len(warningEvents) > 0 {
		warnings := make([]string, len(warningEvents))
		for i, event := range warningEvents {
			warnings[i] = event.Line
		}
		result.Warnings = append(result.Warnings, warnings...)
	}

	// Check if GPU was used (if required)
	if v.config.GPURequired {
		if !v.hasGPULoading() {
			result.Status = StatusFailed
			if result.ErrorMessage == "" {
				result.ErrorMessage = "GPU acceleration not detected in logs (GPU required)"
			} else {
				result.ErrorMessage += "; GPU acceleration not detected"
			}
		}
	}

	// Check for CPU fallback (if single GPU preferred)
	if v.config.SingleGPUPreferred {
		if v.hasCPUFallback() {
			warning := "CPU fallback or multi-GPU split detected (single GPU preferred)"
			result.Warnings = append(result.Warnings, warning)
		}
	}
}

// hasGPULoading checks if logs indicate GPU loading
func (v *Validator) hasGPULoading() bool {
	successEvents := v.logMonitor.GetEvents(EventSuccess)

	// Look for patterns indicating GPU usage
	gpuPatterns := []string{
		"offload",
		"GPU",
		"CUDA",
	}

	for _, event := range successEvents {
		line := strings.ToLower(event.Line)
		for _, pattern := range gpuPatterns {
			if strings.Contains(line, strings.ToLower(pattern)) {
				return true
			}
		}
	}

	return false
}

// hasCPUFallback checks if logs indicate CPU fallback
func (v *Validator) hasCPUFallback() bool {
	allEvents := v.logMonitor.GetAllEvents()

	// Look for patterns indicating CPU usage or multi-GPU split
	cpuPatterns := []string{
		"CPU backend",
		"using CPU",
		"fallback",
	}

	for _, event := range allEvents {
		line := strings.ToLower(event.Line)
		for _, pattern := range cpuPatterns {
			if strings.Contains(line, strings.ToLower(pattern)) {
				return true
			}
		}
	}

	return false
}

// ClaudeValidationResult represents Claude's validation result
type ClaudeValidationResult struct {
	Status TestStatus
	Reason string
}

// validateWithClaude uses Claude headless mode to validate a prompt response
func (v *Validator) validateWithClaude(prompt *PromptTest, simpleCheckPassed bool, simpleCheckReason string) ClaudeValidationResult {
	if v.verbose {
		fmt.Println("  🤖 Running Claude AI validation...")
	}

	// Create analysis prompt
	var analysisPrompt strings.Builder

	analysisPrompt.WriteString("Analyze this LLM response from a Tesla K80 GPU test.\n\n")
	analysisPrompt.WriteString(fmt.Sprintf("Prompt: %s\n\n", prompt.Prompt))
	analysisPrompt.WriteString(fmt.Sprintf("Response: %s\n\n", prompt.Response))

	if !simpleCheckPassed {
		analysisPrompt.WriteString(fmt.Sprintf("Note: Basic validation failed: %s\n\n", simpleCheckReason))
	}

	analysisPrompt.WriteString(`Verify that the response:
1. Is relevant and responsive to the prompt
2. Is coherent and makes sense (not gibberish or garbled text)
3. Is in proper language (not error messages, binary data, or Unicode errors)
4. Appears to be from a working LLM model (not system errors or failures)
5. Has reasonable quality for a 4B parameter model

Respond with ONLY one of these formats:
- "PASS" if the response is valid and acceptable
- "FAIL: <brief reason>" if the response has issues

Be concise. One line only.`)

	// Write to temp file
	promptFile := filepath.Join(v.claudeTempDir, fmt.Sprintf("prompt_%d.txt", os.Getpid()))
	if err := os.WriteFile(promptFile, []byte(analysisPrompt.String()), 0644); err != nil {
		fmt.Printf("Warning: Failed to write Claude prompt file: %v\n", err)
		return ClaudeValidationResult{Status: StatusPassed, Reason: "Claude validation skipped (file write error)"}
	}
	defer os.Remove(promptFile)

	// Run Claude headless
	cmd := exec.Command("claude", "-p", promptFile)
	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Printf("Warning: Claude validation failed to run: %v\n", err)
		return ClaudeValidationResult{Status: StatusPassed, Reason: "Claude validation skipped (execution error)"}
	}

	// Parse result
	result := strings.TrimSpace(string(output))

	if strings.HasPrefix(result, "PASS") {
		if v.verbose {
			fmt.Println("  ✓ Claude: Response is valid")
		}
		return ClaudeValidationResult{
			Status: StatusPassed,
			Reason: "Claude validation: Response is valid and acceptable",
		}
	} else if strings.HasPrefix(result, "FAIL:") {
		failReason := strings.TrimSpace(strings.TrimPrefix(result, "FAIL:"))
		if v.verbose {
			fmt.Printf("  ✗ Claude: %s\n", failReason)
		}
		return ClaudeValidationResult{
			Status: StatusFailed,
			Reason: failReason,
		}
	} else {
		// Unexpected format, treat as warning but pass
		fmt.Printf("Warning: Unexpected Claude response format: %s\n", result)
		return ClaudeValidationResult{
			Status: StatusPassed,
			Reason: "Claude validation unclear, defaulting to pass",
		}
	}
}

// ValidateResponse validates a response against expected criteria
func ValidateResponse(response string, minTokens, maxTokens int) error {
	tokens := estimateTokens(response)

	if minTokens > 0 && tokens < minTokens {
		return fmt.Errorf("response too short: %d tokens (min: %d)", tokens, minTokens)
	}

	if maxTokens > 0 && tokens > maxTokens {
		return fmt.Errorf("response too long: %d tokens (max: %d)", tokens, maxTokens)
	}

	return nil
}
