package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"regexp"
	"sync"
	"time"
)

// LogEvent represents a significant event found in logs
type LogEvent struct {
	Timestamp time.Time
	Line      string
	Type      EventType
	Message   string
}

// EventType represents the type of log event
type EventType int

const (
	EventInfo EventType = iota
	EventSuccess
	EventWarning
	EventError
)

func (e EventType) String() string {
	switch e {
	case EventInfo:
		return "INFO"
	case EventSuccess:
		return "SUCCESS"
	case EventWarning:
		return "WARNING"
	case EventError:
		return "ERROR"
	default:
		return "UNKNOWN"
	}
}

// LogMonitor monitors log files for important events
type LogMonitor struct {
	logPath        string
	patterns       CheckPatterns
	events         []LogEvent
	mu             sync.RWMutex
	successRegexps []*regexp.Regexp
	failureRegexps []*regexp.Regexp
	warningRegexps []*regexp.Regexp
}

// NewLogMonitor creates a new log monitor
func NewLogMonitor(logPath string, patterns CheckPatterns) (*LogMonitor, error) {
	monitor := &LogMonitor{
		logPath:  logPath,
		patterns: patterns,
		events:   make([]LogEvent, 0),
	}

	// Compile regex patterns
	var err error
	monitor.successRegexps, err = compilePatterns(patterns.Success)
	if err != nil {
		return nil, fmt.Errorf("failed to compile success patterns: %w", err)
	}

	monitor.failureRegexps, err = compilePatterns(patterns.Failure)
	if err != nil {
		return nil, fmt.Errorf("failed to compile failure patterns: %w", err)
	}

	monitor.warningRegexps, err = compilePatterns(patterns.Warning)
	if err != nil {
		return nil, fmt.Errorf("failed to compile warning patterns: %w", err)
	}

	return monitor, nil
}

// compilePatterns compiles a list of pattern strings into regexps
func compilePatterns(patterns []string) ([]*regexp.Regexp, error) {
	regexps := make([]*regexp.Regexp, len(patterns))
	for i, pattern := range patterns {
		re, err := regexp.Compile(pattern)
		if err != nil {
			return nil, fmt.Errorf("invalid pattern %q: %w", pattern, err)
		}
		regexps[i] = re
	}
	return regexps, nil
}

// Start starts monitoring the log file
func (m *LogMonitor) Start(ctx context.Context) error {
	file, err := os.Open(m.logPath)
	if err != nil {
		return fmt.Errorf("failed to open log file: %w", err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	// Use a larger buffer for long log lines
	buf := make([]byte, 0, 64*1024)
	scanner.Buffer(buf, 1024*1024)

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		default:
			if !scanner.Scan() {
				// No more lines, wait a bit and retry
				time.Sleep(100 * time.Millisecond)
				continue
			}

			line := scanner.Text()
			m.processLine(line)
		}
	}
}

// processLine processes a single log line
func (m *LogMonitor) processLine(line string) {
	event := LogEvent{
		Timestamp: time.Now(),
		Line:      line,
		Type:      EventInfo,
	}

	// Check for failure patterns (highest priority)
	for _, re := range m.failureRegexps {
		if re.MatchString(line) {
			event.Type = EventError
			event.Message = fmt.Sprintf("Failure pattern matched: %s", re.String())
			m.addEvent(event)
			return
		}
	}

	// Check for warning patterns
	for _, re := range m.warningRegexps {
		if re.MatchString(line) {
			event.Type = EventWarning
			event.Message = fmt.Sprintf("Warning pattern matched: %s", re.String())
			m.addEvent(event)
			return
		}
	}

	// Check for success patterns
	for _, re := range m.successRegexps {
		if re.MatchString(line) {
			event.Type = EventSuccess
			event.Message = fmt.Sprintf("Success pattern matched: %s", re.String())
			m.addEvent(event)
			return
		}
	}
}

// addEvent adds an event to the event list
func (m *LogMonitor) addEvent(event LogEvent) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.events = append(m.events, event)
}

// GetEvents returns all events of a specific type
func (m *LogMonitor) GetEvents(eventType EventType) []LogEvent {
	m.mu.RLock()
	defer m.mu.RUnlock()

	filtered := make([]LogEvent, 0)
	for _, event := range m.events {
		if event.Type == eventType {
			filtered = append(filtered, event)
		}
	}
	return filtered
}

// GetAllEvents returns all events
func (m *LogMonitor) GetAllEvents() []LogEvent {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return append([]LogEvent{}, m.events...)
}

// HasErrors returns true if any error events were detected
func (m *LogMonitor) HasErrors() bool {
	return len(m.GetEvents(EventError)) > 0
}

// HasWarnings returns true if any warning events were detected
func (m *LogMonitor) HasWarnings() bool {
	return len(m.GetEvents(EventWarning)) > 0
}

// GetLogExcerpt returns the last N lines from the log file
func (m *LogMonitor) GetLogExcerpt(lines int) ([]string, error) {
	file, err := os.Open(m.logPath)
	if err != nil {
		return nil, fmt.Errorf("failed to open log file: %w", err)
	}
	defer file.Close()

	// Read all lines
	allLines := make([]string, 0)
	scanner := bufio.NewScanner(file)
	buf := make([]byte, 0, 64*1024)
	scanner.Buffer(buf, 1024*1024)

	for scanner.Scan() {
		allLines = append(allLines, scanner.Text())
	}

	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("error reading log file: %w", err)
	}

	// Return last N lines
	if len(allLines) <= lines {
		return allLines, nil
	}
	return allLines[len(allLines)-lines:], nil
}

// Reset clears all collected events
func (m *LogMonitor) Reset() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.events = make([]LogEvent, 0)
}
