package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"
)

const (
	defaultConfigPath = "test/config/models.yaml"
	defaultOllamaBin  = "./ollama"
	defaultLogPath    = "ollama.log"
	defaultOutputPath = "test-report"
)

func main() {
	// Define subcommands
	runCmd := flag.NewFlagSet("run", flag.ExitOnError)
	validateCmd := flag.NewFlagSet("validate", flag.ExitOnError)
	listCmd := flag.NewFlagSet("list", flag.ExitOnError)

	// Run command flags
	runConfig := runCmd.String("config", defaultConfigPath, "Path to test configuration file")
	runProfile := runCmd.String("profile", "quick", "Test profile to run")
	runOllamaBin := runCmd.String("ollama-bin", defaultOllamaBin, "Path to ollama binary")
	runOutput := runCmd.String("output", defaultOutputPath, "Output path for test report")
	runVerbose := runCmd.Bool("verbose", false, "Enable verbose logging")
	runKeepModels := runCmd.Bool("keep-models", false, "Don't delete models after test")

	// Validate command flags
	validateConfigPath := validateCmd.String("config", defaultConfigPath, "Path to test configuration file")

	// List command flags
	listConfig := listCmd.String("config", defaultConfigPath, "Path to test configuration file")

	// Parse command
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	switch os.Args[1] {
	case "run":
		runCmd.Parse(os.Args[2:])
		os.Exit(runTests(*runConfig, *runProfile, *runOllamaBin, *runOutput, *runVerbose, *runKeepModels))
	case "validate":
		validateCmd.Parse(os.Args[2:])
		os.Exit(validateConfigFile(*validateConfigPath))
	case "list":
		listCmd.Parse(os.Args[2:])
		os.Exit(listProfiles(*listConfig))
	case "-h", "--help", "help":
		printUsage()
		os.Exit(0)
	default:
		fmt.Printf("Unknown command: %s\n\n", os.Args[1])
		printUsage()
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Println("Tesla K80 Test Runner")
	fmt.Println("\nUsage:")
	fmt.Println("  test-runner <command> [flags]")
	fmt.Println("\nCommands:")
	fmt.Println("  run        Run tests")
	fmt.Println("  validate   Validate configuration file")
	fmt.Println("  list       List available test profiles")
	fmt.Println("  help       Show this help message")
	fmt.Println("\nRun 'test-runner <command> -h' for command-specific help")
}

func runTests(configPath, profileName, ollamaBin, outputPath string, verbose, keepModels bool) int {
	// Load config
	config, err := LoadConfig(configPath)
	if err != nil {
		fmt.Printf("Error loading config: %v\n", err)
		return 1
	}

	// Get profile
	profile, err := config.GetProfile(profileName)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		fmt.Printf("Available profiles: %v\n", config.ListProfiles())
		return 1
	}

	fmt.Printf("Running test profile: %s\n", profileName)
	fmt.Printf("Models to test: %d\n", len(profile.Models))
	fmt.Printf("Ollama binary: %s\n", ollamaBin)
	fmt.Println()

	// Setup context with cancellation
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Handle Ctrl+C
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-sigChan
		fmt.Println("\n\nInterrupt received, shutting down...")
		cancel()
	}()

	// Start server
	logPath := defaultLogPath
	server := NewServer(config.Server, ollamaBin)

	fmt.Println("Starting ollama server...")
	if err := server.Start(ctx, logPath); err != nil {
		fmt.Printf("Error starting server: %v\n", err)
		return 1
	}
	defer func() {
		fmt.Println("\nStopping server...")
		server.Stop()
	}()

	// Start log monitor
	monitor, err := NewLogMonitor(logPath, config.Validation.CheckPatterns)
	if err != nil {
		fmt.Printf("Error creating log monitor: %v\n", err)
		return 1
	}

	monitorCtx, monitorCancel := context.WithCancel(ctx)
	defer monitorCancel()

	go func() {
		if err := monitor.Start(monitorCtx); err != nil && err != context.Canceled {
			if verbose {
				fmt.Printf("Log monitor error: %v\n", err)
			}
		}
	}()

	// Wait a moment for log monitor to initialize
	time.Sleep(500 * time.Millisecond)

	// Run tests
	startTime := time.Now()
	tester := NewModelTester(server.BaseURL())
	validator := NewValidator(config.Validation, monitor, verbose)

	results := make([]TestResult, 0, len(profile.Models))

	for i, modelTest := range profile.Models {
		fmt.Printf("\n[%d/%d] Testing model: %s\n", i+1, len(profile.Models), modelTest.Name)
		fmt.Println(strings.Repeat("-", 60))

		// Don't reset monitor - we want to keep GPU detection events from server startup
		// monitor.Reset()

		// Run test
		result := tester.TestModel(ctx, modelTest)

		// Validate result
		validator.ValidateResult(&result)

		results = append(results, result)

		fmt.Printf("Result: %s\n", result.Status)
		if result.ErrorMessage != "" {
			fmt.Printf("Error: %s\n", result.ErrorMessage)
		}
	}

	endTime := time.Now()

	// Generate report
	reporter := NewReporter(config.Reporting, monitor)
	report, err := reporter.GenerateReport(results, startTime, endTime)
	if err != nil {
		fmt.Printf("Error generating report: %v\n", err)
		return 1
	}

	// Save report
	if err := reporter.SaveReport(report, outputPath); err != nil {
		fmt.Printf("Error saving report: %v\n", err)
		return 1
	}

	// Print summary
	reporter.PrintSummary(report)

	// Return exit code based on test results
	if report.Summary.Failed > 0 {
		return 1
	}
	return 0
}

func validateConfigFile(configPath string) int {
	fmt.Printf("Validating configuration: %s\n", configPath)

	config, err := LoadConfig(configPath)
	if err != nil {
		fmt.Printf("❌ Configuration is invalid: %v\n", err)
		return 1
	}

	fmt.Printf("✅ Configuration is valid\n")
	fmt.Printf("Profiles found: %d\n", len(config.Profiles))

	for profileName, profile := range config.Profiles {
		fmt.Printf("  - %s: %d models, timeout %s\n", profileName, len(profile.Models), profile.Timeout)
	}

	return 0
}

func listProfiles(configPath string) int {
	config, err := LoadConfig(configPath)
	if err != nil {
		fmt.Printf("Error loading config: %v\n", err)
		return 1
	}

	fmt.Println("Available test profiles:")
	fmt.Println()

	for _, profileName := range config.ListProfiles() {
		profile, _ := config.GetProfile(profileName)
		fmt.Printf("Profile: %s\n", profileName)
		fmt.Printf("  Timeout: %s\n", profile.Timeout)
		fmt.Printf("  Models: %d\n", len(profile.Models))
		for _, model := range profile.Models {
			fmt.Printf("    - %s (%d prompts)\n", model.Name, len(model.Prompts))
		}
		fmt.Println()
	}

	return 0
}
