package main

import (
	"fmt"
	"strings"
)

// Validator validates test results against configuration
type Validator struct {
	config     Validation
	logMonitor *LogMonitor
}

// NewValidator creates a new validator
func NewValidator(config Validation, logMonitor *LogMonitor) *Validator {
	return &Validator{
		config:     config,
		logMonitor: logMonitor,
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
	// Already failed, skip
	if prompt.Status == StatusFailed {
		return
	}

	// Check if response is empty
	if strings.TrimSpace(prompt.Response) == "" {
		prompt.Status = StatusFailed
		prompt.ErrorMessage = "Response is empty"
		return
	}

	// Check token count
	if prompt.ResponseTokens < 1 {
		prompt.Status = StatusFailed
		prompt.ErrorMessage = "Response has no tokens"
		return
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
