package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"time"
)

// Server manages the ollama server lifecycle
type Server struct {
	config     ServerConfig
	ollamaBin  string
	logFile    *os.File
	cmd        *exec.Cmd
	baseURL    string
}

// NewServer creates a new server manager
func NewServer(config ServerConfig, ollamaBin string) *Server {
	baseURL := fmt.Sprintf("http://%s:%d", config.Host, config.Port)
	return &Server{
		config:    config,
		ollamaBin: ollamaBin,
		baseURL:   baseURL,
	}
}

// Start starts the ollama server
func (s *Server) Start(ctx context.Context, logPath string) error {
	// Create log file
	logFile, err := os.Create(logPath)
	if err != nil {
		return fmt.Errorf("failed to create log file: %w", err)
	}
	s.logFile = logFile

	// Resolve ollama binary path
	binPath, err := filepath.Abs(s.ollamaBin)
	if err != nil {
		return fmt.Errorf("failed to resolve ollama binary path: %w", err)
	}

	// Check if binary exists
	if _, err := os.Stat(binPath); err != nil {
		return fmt.Errorf("ollama binary not found at %s: %w", binPath, err)
	}

	// Create command
	s.cmd = exec.CommandContext(ctx, binPath, "serve")
	s.cmd.Stdout = logFile
	s.cmd.Stderr = logFile

	// Set working directory to binary location
	s.cmd.Dir = filepath.Dir(binPath)

	// Start server
	if err := s.cmd.Start(); err != nil {
		logFile.Close()
		return fmt.Errorf("failed to start ollama server: %w", err)
	}

	fmt.Printf("Started ollama server (PID: %d)\n", s.cmd.Process.Pid)
	fmt.Printf("Server logs: %s\n", logPath)

	// Wait for server to be ready
	if err := s.WaitForReady(ctx); err != nil {
		s.Stop()
		return fmt.Errorf("server failed to become ready: %w", err)
	}

	fmt.Printf("Server is ready at %s\n", s.baseURL)
	return nil
}

// WaitForReady waits for the server to be ready
func (s *Server) WaitForReady(ctx context.Context) error {
	healthURL := s.baseURL + s.config.HealthCheckEndpoint

	timeout := time.After(s.config.StartupTimeout)
	ticker := time.NewTicker(s.config.HealthCheckInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-timeout:
			return fmt.Errorf("timeout waiting for server to be ready")
		case <-ticker.C:
			req, err := http.NewRequestWithContext(ctx, "GET", healthURL, nil)
			if err != nil {
				continue
			}

			resp, err := http.DefaultClient.Do(req)
			if err != nil {
				continue
			}
			resp.Body.Close()

			if resp.StatusCode == http.StatusOK {
				return nil
			}
		}
	}
}

// Stop stops the ollama server
func (s *Server) Stop() error {
	var errs []error

	// Stop the process
	if s.cmd != nil && s.cmd.Process != nil {
		fmt.Printf("Stopping ollama server (PID: %d)\n", s.cmd.Process.Pid)

		// Try graceful shutdown first
		if err := s.cmd.Process.Signal(os.Interrupt); err != nil {
			errs = append(errs, fmt.Errorf("failed to send interrupt signal: %w", err))
		}

		// Wait for process to exit (with timeout)
		done := make(chan error, 1)
		go func() {
			done <- s.cmd.Wait()
		}()

		select {
		case <-time.After(10 * time.Second):
			// Force kill if graceful shutdown times out
			if err := s.cmd.Process.Kill(); err != nil {
				errs = append(errs, fmt.Errorf("failed to kill process: %w", err))
			}
			<-done // Wait for process to actually die
		case err := <-done:
			if err != nil && err.Error() != "signal: interrupt" {
				errs = append(errs, fmt.Errorf("process exited with error: %w", err))
			}
		}
	}

	// Close log file
	if s.logFile != nil {
		if err := s.logFile.Close(); err != nil {
			errs = append(errs, fmt.Errorf("failed to close log file: %w", err))
		}
	}

	if len(errs) > 0 {
		return fmt.Errorf("errors during shutdown: %v", errs)
	}

	fmt.Println("Server stopped successfully")
	return nil
}

// BaseURL returns the server base URL
func (s *Server) BaseURL() string {
	return s.baseURL
}

// IsRunning returns true if the server is running
func (s *Server) IsRunning() bool {
	return s.cmd != nil && s.cmd.Process != nil
}
