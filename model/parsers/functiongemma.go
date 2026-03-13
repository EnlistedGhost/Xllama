package parsers

import (
	"strings"

	"github.com/ollama/ollama/api"
	"github.com/ollama/ollama/tools"
)

type FunctionGemmaParser struct {
	tools  []api.Tool
	parser *tools.Parser
}

func (p *FunctionGemmaParser) Init(t []api.Tool, _ *api.Message) []api.Tool {
	p.tools = t
	p.parser = tools.NewParserWithTag(t, "<start_function_call>call:")
	return t
}

func (p *FunctionGemmaParser) Add(s string, done bool) (content string, thinking string, calls []api.ToolCall, err error) {
	// Strip end tags from the content before parsing
	s = strings.ReplaceAll(s, "<end_function_call>", "")

	toolCalls, content := p.parser.Add(s)
	if done && len(toolCalls) == 0 {
		content += p.parser.Content()
	}
	return content, "", toolCalls, nil
}

func (p *FunctionGemmaParser) HasToolSupport() bool {
	return true
}

func (p *FunctionGemmaParser) HasThinkingSupport() bool {
	return false
}
