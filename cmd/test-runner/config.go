package main

import (
	"fmt"
	"os"
	"time"

	"gopkg.in/yaml.v3"
)

// Config represents the complete test configuration
type Config struct {
	Profiles   map[string]Profile `yaml:"profiles"`
	Validation Validation         `yaml:"validation"`
	Server     ServerConfig       `yaml:"server"`
	Reporting  ReportingConfig    `yaml:"reporting"`
}

// Profile represents a test profile with multiple models
type Profile struct {
	Timeout time.Duration `yaml:"timeout"`
	Models  []ModelTest   `yaml:"models"`
}

// ModelTest represents a single model test configuration
type ModelTest struct {
	Name              string        `yaml:"name"`
	Prompts           []string      `yaml:"prompts"`
	MinResponseTokens int           `yaml:"min_response_tokens"`
	MaxResponseTokens int           `yaml:"max_response_tokens"`
	Timeout           time.Duration `yaml:"timeout"`
}

// Validation represents validation rules
type Validation struct {
	GPURequired        bool           `yaml:"gpu_required"`
	SingleGPUPreferred bool           `yaml:"single_gpu_preferred"`
	CheckPatterns      CheckPatterns  `yaml:"check_patterns"`
}

// CheckPatterns defines log patterns to match
type CheckPatterns struct {
	Success []string `yaml:"success"`
	Failure []string `yaml:"failure"`
	Warning []string `yaml:"warning"`
}

// ServerConfig represents server configuration
type ServerConfig struct {
	Host                string        `yaml:"host"`
	Port                int           `yaml:"port"`
	StartupTimeout      time.Duration `yaml:"startup_timeout"`
	HealthCheckInterval time.Duration `yaml:"health_check_interval"`
	HealthCheckEndpoint string        `yaml:"health_check_endpoint"`
}

// ReportingConfig represents reporting configuration
type ReportingConfig struct {
	Formats          []string `yaml:"formats"`
	IncludeLogs      bool     `yaml:"include_logs"`
	LogExcerptLines  int      `yaml:"log_excerpt_lines"`
}

// LoadConfig loads and validates a test configuration from a YAML file
func LoadConfig(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("failed to read config file: %w", err)
	}

	var config Config
	if err := yaml.Unmarshal(data, &config); err != nil {
		return nil, fmt.Errorf("failed to parse config YAML: %w", err)
	}

	// Set defaults
	if config.Server.Host == "" {
		config.Server.Host = "localhost"
	}
	if config.Server.Port == 0 {
		config.Server.Port = 11434
	}
	if config.Server.StartupTimeout == 0 {
		config.Server.StartupTimeout = 30 * time.Second
	}
	if config.Server.HealthCheckInterval == 0 {
		config.Server.HealthCheckInterval = 1 * time.Second
	}
	if config.Server.HealthCheckEndpoint == "" {
		config.Server.HealthCheckEndpoint = "/api/tags"
	}
	if config.Reporting.LogExcerptLines == 0 {
		config.Reporting.LogExcerptLines = 50
	}
	if len(config.Reporting.Formats) == 0 {
		config.Reporting.Formats = []string{"json"}
	}

	// Validate config
	if err := validateConfig(&config); err != nil {
		return nil, fmt.Errorf("invalid config: %w", err)
	}

	return &config, nil
}

// validateConfig validates the loaded configuration
func validateConfig(config *Config) error {
	if len(config.Profiles) == 0 {
		return fmt.Errorf("no profiles defined in config")
	}

	for profileName, profile := range config.Profiles {
		if len(profile.Models) == 0 {
			return fmt.Errorf("profile %q has no models defined", profileName)
		}

		for i, model := range profile.Models {
			if model.Name == "" {
				return fmt.Errorf("profile %q model %d has no name", profileName, i)
			}
			if len(model.Prompts) == 0 {
				return fmt.Errorf("profile %q model %q has no prompts", profileName, model.Name)
			}
			if model.Timeout == 0 {
				return fmt.Errorf("profile %q model %q has no timeout", profileName, model.Name)
			}
		}

		if profile.Timeout == 0 {
			return fmt.Errorf("profile %q has no timeout", profileName)
		}
	}

	return nil
}

// GetProfile returns a specific profile by name
func (c *Config) GetProfile(name string) (*Profile, error) {
	profile, ok := c.Profiles[name]
	if !ok {
		return nil, fmt.Errorf("profile %q not found", name)
	}
	return &profile, nil
}

// ListProfiles returns a list of all profile names
func (c *Config) ListProfiles() []string {
	profiles := make([]string, 0, len(c.Profiles))
	for name := range c.Profiles {
		profiles = append(profiles, name)
	}
	return profiles
}
