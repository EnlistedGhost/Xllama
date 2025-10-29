package ggml

import (
	"fmt"
	"log/slog"
	"strings"
)

// FileType is the Go equivalent to llama_ftype used for gguf file typing
type FileType uint32

const (
	FileTypeF32 FileType = iota
	FileTypeF16
	fileTypeQ4_0
	fileTypeQ4_1
	fileTypeMXFP4 // originally fileTypeQ4_1_F16 // unused by GGML
	fileTypeQ4_2  // unused by GGML
	fileTypeQ4_3  // unused by GGML
	FileTypeQ8_0
	fileTypeQ5_0
	fileTypeQ5_1
	fileTypeQ2_K
	fileTypeQ3_K_S
	fileTypeQ3_K_M
	fileTypeQ3_K_L
	FileTypeQ4_K_S
	FileTypeQ4_K_M
	fileTypeQ5_K_S
	fileTypeQ5_K_M
	fileTypeQ6_K
	fileTypeIQ2_XXS
	fileTypeIQ2_XS
	fileTypeQ2_K_S
	fileTypeIQ3_XS
	fileTypeIQ3_XXS
	fileTypeIQ1_S
	fileTypeIQ4_NL
	fileTypeIQ3_S
	fileTypeIQ3_M
	fileTypeIQ2_S
	fileTypeIQ2_M
	fileTypeIQ4_XS
	fileTypeIQ1_M
	FileTypeBF16
	fileTypeQ4_0_4_4 // unused by GGML
	fileTypeQ4_0_4_8 // unused by GGML
	fileTypeQ4_0_8_8 // unused by GGML
	fileTypeTQ1_0
	fileTypeTQ2_0

	FileTypeUnknown = 1024
)

// ParseFileType parses the provided GGUF file type
// Only Ollama supported types are considered valid
func ParseFileType(s string) (FileType, error) {
	switch s {
	case "F32":
		return FileTypeF32, nil
	case "F16":
		return FileTypeF16, nil
	case "Q8_0":
		return FileTypeQ8_0, nil
	case "Q4_K_S":
		return FileTypeQ4_K_S, nil
	case "Q4_K_M", "Q4_K":
		return FileTypeQ4_K_M, nil
	case "BF16":
		return FileTypeBF16, nil
	default:
		supportedFileTypes := []FileType{
			FileTypeF32,
			FileTypeF16,
			FileTypeQ4_K_S,
			FileTypeQ4_K_M,
			FileTypeQ8_0,
			// fsggml.FileTypeBF16, // TODO
		}
		strs := make([]string, len(supportedFileTypes))
		for i := range supportedFileTypes {
			strs[i] = supportedFileTypes[i].String()
		}

		return FileTypeUnknown, fmt.Errorf("unsupported quantization type %s - supported types are %s", s, strings.Join(strs, ", "))
	}
}

func (t FileType) String() string {
	// Note: this routine will return a broader set of file types for existing models
	switch t {
	case FileTypeF32:
		return "F32"
	case FileTypeF16:
		return "F16"
	case fileTypeQ4_0:
		return "Q4_0"
	case fileTypeQ4_1:
		return "Q4_1"
	case fileTypeMXFP4:
		return "MXFP4"
	case FileTypeQ8_0:
		return "Q8_0"
	case fileTypeQ5_0:
		return "Q5_0"
	case fileTypeQ5_1:
		return "Q5_1"
	case fileTypeQ2_K:
		return "Q2_K"
	case fileTypeQ3_K_S:
		return "Q3_K_S"
	case fileTypeQ3_K_M:
		return "Q3_K_M"
	case fileTypeQ3_K_L:
		return "Q3_K_L"
	case FileTypeQ4_K_S:
		return "Q4_K_S"
	case FileTypeQ4_K_M:
		return "Q4_K_M"
	case fileTypeQ5_K_S:
		return "Q5_K_S"
	case fileTypeQ5_K_M:
		return "Q5_K_M"
	case fileTypeQ6_K:
		return "Q6_K"
	case fileTypeQ2_K_S:
		return "Q2_K_S"
	case FileTypeBF16:
		return "BF16"
	default:
		return "unknown"
	}
}

func (t FileType) Value() uint32 {
	return uint32(t)
}

func (ftype FileType) ToTensorType() TensorType {
	switch ftype {
	case FileTypeF32:
		return TensorTypeF32
	case FileTypeF16:
		return TensorTypeF16
	case fileTypeQ4_0:
		return TensorTypeQ4_0
	case fileTypeQ4_1:
		return TensorTypeQ4_1
	case fileTypeMXFP4:
		return TensorTypeMXFP4 // Formerly unused tensorTypeQ4_2
	case FileTypeQ8_0:
		return TensorTypeQ8_0
	case fileTypeQ5_0:
		return TensorTypeQ5_0
	case fileTypeQ5_1:
		return TensorTypeQ5_1
	case fileTypeQ2_K:
		return TensorTypeQ2_K
	case fileTypeQ3_K_S:
		return TensorTypeQ3_K
	case fileTypeQ3_K_M:
		return TensorTypeQ3_K
	case fileTypeQ3_K_L:
		return TensorTypeQ3_K
	case FileTypeQ4_K_S:
		return TensorTypeQ4_K
	case FileTypeQ4_K_M:
		return TensorTypeQ4_K
	case fileTypeQ5_K_S:
		return TensorTypeQ5_K
	case fileTypeQ5_K_M:
		return TensorTypeQ5_K
	case fileTypeQ6_K:
		return TensorTypeQ6_K
	case fileTypeQ2_K_S:
		return TensorTypeQ2_K
	case FileTypeBF16:
		return TensorTypeBF16
	default:
		slog.Warn("unsupported file type", "type", ftype)
		return 0 // F32
	}
}

// TensorType is equivalent to ggml_type for individual tensor types
// Note: these are not the same as FileType
type TensorType uint32

const (
	TensorTypeF32 TensorType = 0
	TensorTypeF16            = 1
	TensorTypeQ4_0           = 2
	TensorTypeQ4_1           = 3
	// 4 = Q4_2 removed
	// 5 = Q4_3 removed
	TensorTypeQ5_0           = 6
	TensorTypeQ5_1           = 7
	TensorTypeQ8_0           = 8
	TensorTypeQ8_1           = 9
	TensorTypeQ2_K           = 10
	TensorTypeQ3_K           = 11
	TensorTypeQ4_K           = 12
	TensorTypeQ5_K           = 13
	TensorTypeQ6_K           = 14
	TensorTypeQ8_K           = 15
	tensorTypeIQ2_XXS        = 16 // not supported by ollama
	tensorTypeIQ2_XS         = 17 // not supported by ollama
	tensorTypeIQ3_XXS        = 18 // not supported by ollama
	tensorTypeIQ1_S          = 19 // not supported by ollama
	tensorTypeIQ4_NL         = 20 // not supported by ollama
	tensorTypeIQ3_S          = 21 // not supported by ollama
	tensorTypeIQ2_S          = 22 // not supported by ollama
	tensorTypeIQ4_XS         = 23 // not supported by ollama
	TensorTypeI8             = 24
	TensorTypeI16            = 25
	TensorTypeI32            = 26
	TensorTypeI64            = 27
	TensorTypeF64            = 28
	tensorTypeIQ1_M          = 29 // not supported by ollama
	TensorTypeBF16           = 30
	// 31-33 = Q4_0 variants removed
	tensorTypeTQ1_0          = 34 // not supported by ollama
	tensorTypeTQ2_0          = 35 // not supported by ollama
	// 36-38 = IQ4_NL variants removed
	TensorTypeMXFP4          = 39
)

// ParseFileType parses the provided GGUF file type
// Only Ollama supported types are considered valid
func ParseTensorType(s string) (TensorType, error) {
	switch s {
	case "F32":
		return TensorTypeF32, nil
	case "F16":
		return TensorTypeF16, nil
	case "Q4_0":
		return TensorTypeQ4_0, nil
	case "Q4_1":
		return TensorTypeQ4_1, nil
	case "Q5_0":
		return TensorTypeQ5_0, nil
	case "Q5_1":
		return TensorTypeQ5_1, nil
	case "Q8_0":
		return TensorTypeQ8_0, nil
	case "Q8_1":
		return TensorTypeQ8_1, nil
	case "Q2_K":
		return TensorTypeQ2_K, nil
	case "Q3_K":
		return TensorTypeQ3_K, nil
	case "Q4_K":
		return TensorTypeQ4_K, nil
	case "Q5_K":
		return TensorTypeQ5_K, nil
	case "Q6_K":
		return TensorTypeQ6_K, nil
	case "Q8_K":
		return TensorTypeQ8_K, nil
	case "F64":
		return TensorTypeF64, nil
	case "BF16":
		return TensorTypeBF16, nil
	case "MXFP4":
		return TensorTypeMXFP4, nil
	default:
		return 0, fmt.Errorf("unsupported quantization type %s", s)
	}
}

func (t TensorType) IsQuantized() bool {
	switch t {
	case TensorTypeF32, TensorTypeF16, TensorTypeBF16:
		return false
	default:
		return true
	}
}

func (t TensorType) RowSize(ne uint64) uint64 {
	return t.TypeSize() * ne / t.BlockSize()
}

func (t TensorType) String() string {
	switch t {
	case TensorTypeF32:
		return "F32"
	case TensorTypeF16:
		return "F16"
	case TensorTypeQ4_0:
		return "Q4_0"
	case TensorTypeQ4_1:
		return "Q4_1"
	case TensorTypeQ5_0:
		return "Q5_0"
	case TensorTypeQ5_1:
		return "Q5_1"
	case TensorTypeQ8_0:
		return "Q8_0"
	case TensorTypeQ8_1:
		return "Q8_1"
	case TensorTypeQ2_K:
		return "Q2_K"
	case TensorTypeQ3_K:
		return "Q3_K"
	case TensorTypeQ4_K:
		return "Q4_K"
	case TensorTypeQ5_K:
		return "Q5_K"
	case TensorTypeQ6_K:
		return "Q6_K"
	case TensorTypeQ8_K:
		return "Q8_K"
	case TensorTypeF64:
		return "F64"
	case TensorTypeBF16:
		return "BF16"
	case TensorTypeMXFP4:
		return "MXFP4"
	default:
		return "unknown"
	}
}
