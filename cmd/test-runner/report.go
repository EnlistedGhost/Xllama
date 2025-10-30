package main

import (
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"time"
)

// TestReport represents the complete test report
type TestReport struct {
	Summary      Summary        `json:"summary"`
	Results      []TestResult   `json:"results"`
	LogExcerpts  map[string][]string `json:"log_excerpts,omitempty"`
	StartTime    time.Time      `json:"start_time"`
	EndTime      time.Time      `json:"end_time"`
	TotalDuration time.Duration `json:"total_duration"`
}

// Summary represents test summary statistics
type Summary struct {
	TotalTests  int `json:"total_tests"`
	Passed      int `json:"passed"`
	Failed      int `json:"failed"`
	Skipped     int `json:"skipped"`
	TotalPrompts int `json:"total_prompts"`
}

// Reporter generates test reports
type Reporter struct {
	config      ReportingConfig
	logMonitor  *LogMonitor
}

// NewReporter creates a new reporter
func NewReporter(config ReportingConfig, logMonitor *LogMonitor) *Reporter {
	return &Reporter{
		config:     config,
		logMonitor: logMonitor,
	}
}

// GenerateReport generates a complete test report
func (r *Reporter) GenerateReport(results []TestResult, startTime, endTime time.Time) (*TestReport, error) {
	report := &TestReport{
		Results:       results,
		StartTime:     startTime,
		EndTime:       endTime,
		TotalDuration: endTime.Sub(startTime),
	}

	// Calculate summary
	report.Summary = r.calculateSummary(results)

	// Add log excerpts for failed tests if configured
	if r.config.IncludeLogs && r.logMonitor != nil {
		report.LogExcerpts = make(map[string][]string)
		for _, result := range results {
			if result.Status == StatusFailed {
				excerpt, err := r.logMonitor.GetLogExcerpt(r.config.LogExcerptLines)
				if err == nil {
					report.LogExcerpts[result.ModelName] = excerpt
				}
			}
		}
	}

	return report, nil
}

// calculateSummary calculates summary statistics
func (r *Reporter) calculateSummary(results []TestResult) Summary {
	summary := Summary{
		TotalTests: len(results),
	}

	for _, result := range results {
		switch result.Status {
		case StatusPassed:
			summary.Passed++
		case StatusFailed:
			summary.Failed++
		case StatusSkipped:
			summary.Skipped++
		}
		summary.TotalPrompts += len(result.PromptTests)
	}

	return summary
}

// SaveReport saves the report in configured formats
func (r *Reporter) SaveReport(report *TestReport, outputPath string) error {
	for _, format := range r.config.Formats {
		switch format {
		case "json":
			if err := r.saveJSON(report, outputPath+".json"); err != nil {
				return fmt.Errorf("failed to save JSON report: %w", err)
			}
		case "markdown":
			if err := r.saveMarkdown(report, outputPath+".md"); err != nil {
				return fmt.Errorf("failed to save Markdown report: %w", err)
			}
		default:
			fmt.Printf("Warning: unknown report format %q\n", format)
		}
	}
	return nil
}

// saveJSON saves the report as JSON
func (r *Reporter) saveJSON(report *TestReport, path string) error {
	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()

	encoder := json.NewEncoder(file)
	encoder.SetIndent("", "  ")
	if err := encoder.Encode(report); err != nil {
		return err
	}

	fmt.Printf("JSON report saved to: %s\n", path)
	return nil
}

// saveMarkdown saves the report as Markdown
func (r *Reporter) saveMarkdown(report *TestReport, path string) error {
	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()

	var sb strings.Builder

	// Title and summary
	sb.WriteString("# Tesla K80 Test Report\n\n")
	sb.WriteString(fmt.Sprintf("**Generated:** %s\n\n", time.Now().Format(time.RFC3339)))
	sb.WriteString(fmt.Sprintf("**Duration:** %s\n\n", report.TotalDuration.Round(time.Second)))

	// Summary table
	sb.WriteString("## Summary\n\n")
	sb.WriteString("| Metric | Count |\n")
	sb.WriteString("|--------|-------|\n")
	sb.WriteString(fmt.Sprintf("| Total Tests | %d |\n", report.Summary.TotalTests))
	sb.WriteString(fmt.Sprintf("| Passed | %d |\n", report.Summary.Passed))
	sb.WriteString(fmt.Sprintf("| Failed | %d |\n", report.Summary.Failed))
	sb.WriteString(fmt.Sprintf("| Skipped | %d |\n", report.Summary.Skipped))
	sb.WriteString(fmt.Sprintf("| Total Prompts | %d |\n\n", report.Summary.TotalPrompts))

	// Results
	sb.WriteString("## Test Results\n\n")
	for _, result := range report.Results {
		r.writeModelResult(&sb, result)
	}

	// Log excerpts
	if len(report.LogExcerpts) > 0 {
		sb.WriteString("## Log Excerpts\n\n")
		for modelName, excerpt := range report.LogExcerpts {
			sb.WriteString(fmt.Sprintf("### %s\n\n", modelName))
			sb.WriteString("```\n")
			for _, line := range excerpt {
				sb.WriteString(line + "\n")
			}
			sb.WriteString("```\n\n")
		}
	}

	if _, err := file.WriteString(sb.String()); err != nil {
		return err
	}

	fmt.Printf("Markdown report saved to: %s\n", path)
	return nil
}

// writeModelResult writes a model result to the markdown builder
func (r *Reporter) writeModelResult(sb *strings.Builder, result TestResult) {
	statusEmoji := "✅"
	if result.Status == StatusFailed {
		statusEmoji = "❌"
	} else if result.Status == StatusSkipped {
		statusEmoji = "⏭️"
	}

	sb.WriteString(fmt.Sprintf("### %s %s\n\n", statusEmoji, result.ModelName))
	sb.WriteString(fmt.Sprintf("**Status:** %s\n\n", result.Status))
	sb.WriteString(fmt.Sprintf("**Duration:** %s\n\n", result.Duration.Round(time.Millisecond)))

	if result.ErrorMessage != "" {
		sb.WriteString(fmt.Sprintf("**Error:** %s\n\n", result.ErrorMessage))
	}

	if len(result.Warnings) > 0 {
		sb.WriteString("**Warnings:**\n")
		for _, warning := range result.Warnings {
			sb.WriteString(fmt.Sprintf("- %s\n", warning))
		}
		sb.WriteString("\n")
	}

	// Prompt tests
	if len(result.PromptTests) > 0 {
		sb.WriteString("**Prompt Tests:**\n\n")
		for i, prompt := range result.PromptTests {
			promptStatus := "✅"
			if prompt.Status == StatusFailed {
				promptStatus = "❌"
			}
			sb.WriteString(fmt.Sprintf("%d. %s **Prompt:** %s\n", i+1, promptStatus, prompt.Prompt))
			sb.WriteString(fmt.Sprintf("   - **Duration:** %s\n", prompt.Duration.Round(time.Millisecond)))
			sb.WriteString(fmt.Sprintf("   - **Response Tokens:** %d\n", prompt.ResponseTokens))
			if prompt.ErrorMessage != "" {
				sb.WriteString(fmt.Sprintf("   - **Error:** %s\n", prompt.ErrorMessage))
			}
			if prompt.Response != "" && len(prompt.Response) < 200 {
				sb.WriteString(fmt.Sprintf("   - **Response:** %s\n", prompt.Response))
			}
			sb.WriteString("\n")
		}
	}

	sb.WriteString("---\n\n")
}

// PrintSummary prints a summary to stdout
func (r *Reporter) PrintSummary(report *TestReport) {
	fmt.Println("\n" + strings.Repeat("=", 60))
	fmt.Println("TEST SUMMARY")
	fmt.Println(strings.Repeat("=", 60))
	fmt.Printf("Total Tests:    %d\n", report.Summary.TotalTests)
	fmt.Printf("Passed:         %d\n", report.Summary.Passed)
	fmt.Printf("Failed:         %d\n", report.Summary.Failed)
	fmt.Printf("Skipped:        %d\n", report.Summary.Skipped)
	fmt.Printf("Total Prompts:  %d\n", report.Summary.TotalPrompts)
	fmt.Printf("Duration:       %s\n", report.TotalDuration.Round(time.Second))
	fmt.Println(strings.Repeat("=", 60))

	if report.Summary.Failed > 0 {
		fmt.Println("\nFAILED TESTS:")
		for _, result := range report.Results {
			if result.Status == StatusFailed {
				fmt.Printf("  ❌ %s: %s\n", result.ModelName, result.ErrorMessage)
			}
		}
	}

	fmt.Println()
}
