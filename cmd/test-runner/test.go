package main

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

// TestResult represents the result of a model test
type TestResult struct {
	ModelName    string        `json:"model_name"`
	Status       TestStatus    `json:"status"`
	StartTime    time.Time     `json:"start_time"`
	EndTime      time.Time     `json:"end_time"`
	Duration     time.Duration `json:"duration"`
	PromptTests  []PromptTest  `json:"prompt_tests"`
	ErrorMessage string        `json:"error_message,omitempty"`
	Warnings     []string      `json:"warnings,omitempty"`
}

// TestStatus represents the status of a test
type TestStatus string

const (
	StatusPassed TestStatus = "PASSED"
	StatusFailed TestStatus = "FAILED"
	StatusSkipped TestStatus = "SKIPPED"
)

// PromptTest represents the result of a single prompt test
type PromptTest struct {
	Prompt           string        `json:"prompt"`
	Response         string        `json:"response"`
	ResponseTokens   int           `json:"response_tokens"`
	Duration         time.Duration `json:"duration"`
	Status           TestStatus    `json:"status"`
	ErrorMessage     string        `json:"error_message,omitempty"`
}

// ModelTester runs tests for models
type ModelTester struct {
	serverURL  string
	httpClient *http.Client
}

// NewModelTester creates a new model tester
func NewModelTester(serverURL string) *ModelTester {
	return &ModelTester{
		serverURL: serverURL,
		httpClient: &http.Client{
			Timeout: 5 * time.Minute, // Long timeout for model operations
		},
	}
}

// TestModel runs all tests for a single model
func (t *ModelTester) TestModel(ctx context.Context, modelTest ModelTest) TestResult {
	result := TestResult{
		ModelName:   modelTest.Name,
		StartTime:   time.Now(),
		Status:      StatusPassed,
		PromptTests: make([]PromptTest, 0),
	}

	// Pull model first
	fmt.Printf("Pulling model %s...\n", modelTest.Name)
	if err := t.pullModel(ctx, modelTest.Name); err != nil {
		result.Status = StatusFailed
		result.ErrorMessage = fmt.Sprintf("Failed to pull model: %v", err)
		result.EndTime = time.Now()
		result.Duration = result.EndTime.Sub(result.StartTime)
		return result
	}
	fmt.Printf("Model %s pulled successfully\n", modelTest.Name)

	// Run each prompt test
	for i, prompt := range modelTest.Prompts {
		fmt.Printf("Testing prompt %d/%d for %s\n", i+1, len(modelTest.Prompts), modelTest.Name)

		promptTest := t.testPrompt(ctx, modelTest.Name, prompt, modelTest.Timeout)
		result.PromptTests = append(result.PromptTests, promptTest)

		// Update overall status based on prompt test result
		if promptTest.Status == StatusFailed {
			result.Status = StatusFailed
		}
	}

	result.EndTime = time.Now()
	result.Duration = result.EndTime.Sub(result.StartTime)

	fmt.Printf("Model %s test completed: %s\n", modelTest.Name, result.Status)
	return result
}

// pullModel pulls a model using the Ollama API
func (t *ModelTester) pullModel(ctx context.Context, modelName string) error {
	url := t.serverURL + "/api/pull"

	reqBody := map[string]interface{}{
		"name": modelName,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return fmt.Errorf("failed to marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := t.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("pull failed with status %d: %s", resp.StatusCode, string(body))
	}

	// Read response stream (pull progress)
	scanner := bufio.NewScanner(resp.Body)
	for scanner.Scan() {
		var progress map[string]interface{}
		if err := json.Unmarshal(scanner.Bytes(), &progress); err != nil {
			continue
		}
		// Could print progress here if verbose mode is enabled
	}

	return nil
}

// testPrompt tests a single prompt
func (t *ModelTester) testPrompt(ctx context.Context, modelName, prompt string, timeout time.Duration) PromptTest {
	result := PromptTest{
		Prompt: prompt,
		Status: StatusPassed,
	}

	startTime := time.Now()

	// Create context with timeout
	testCtx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()

	// Call chat API
	response, err := t.chat(testCtx, modelName, prompt)
	if err != nil {
		result.Status = StatusFailed
		result.ErrorMessage = err.Error()
		result.Duration = time.Since(startTime)
		return result
	}

	result.Response = response
	result.ResponseTokens = estimateTokens(response)
	result.Duration = time.Since(startTime)

	return result
}

// chat sends a chat request to the ollama API
func (t *ModelTester) chat(ctx context.Context, modelName, prompt string) (string, error) {
	url := t.serverURL + "/api/generate"

	reqBody := map[string]interface{}{
		"model":  modelName,
		"prompt": prompt,
		"stream": false,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return "", fmt.Errorf("failed to marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return "", fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := t.httpClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("chat failed with status %d: %s", resp.StatusCode, string(body))
	}

	var response struct {
		Response string `json:"response"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&response); err != nil {
		return "", fmt.Errorf("failed to decode response: %w", err)
	}

	return response.Response, nil
}

// estimateTokens estimates the number of tokens in a text
// This is a rough approximation
func estimateTokens(text string) int {
	// Rough estimate: 1 token ≈ 4 characters on average
	words := strings.Fields(text)
	return len(words)
}
