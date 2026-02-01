---
name: nano-pdf
description: Edit PDFs with natural-language instructions using the nano-pdf CLI.
homepage: https://pypi.org/project/nano-pdf/
metadata: {"openclaw":{"emoji":"📄","requires":{"bins":["nano-pdf"]},"install":[{"id":"uv","kind":"uv","package":"nano-pdf","bins":["nano-pdf"],"label":"Install nano-pdf (uv)"}]}}
---

# nano-pdf

Use `nano-pdf` to apply edits to a specific page in a PDF using a natural-language instruction.

## Quick start

```bash
# Edit a specific page
nano-pdf edit deck.pdf 1 "Change the title to 'Q3 Results' and fix the typo in the subtitle"

# Page numbers are 0-based or 1-based depending on the tool's version/config
# If the result looks off by one, retry with the other.
```

## Installation

```bash
# Using uv (recommended)
uv pip install nano-pdf

# Or using pip
pip install nano-pdf
```

## Usage

### Basic Editing

```bash
# Edit page 0 (first page)
nano-pdf edit document.pdf 0 "Change the title to 'Annual Report 2025'"

# Edit page 5
nano-pdf edit document.pdf 5 "Update the date to December 2024"

# Add text to header
nano-pdf edit document.pdf 0 "Add 'Confidential' to the top right corner"
```

### Notes

- Page numbers are typically 0-based (first page is 0)
- Always sanity-check the output PDF before sending it out
- The tool uses AI to understand natural language instructions
- Works best with clear, specific instructions

## Examples

```bash
# Fix typos
nano-pdf edit report.pdf 2 "Fix the spelling mistake in the second paragraph"

# Update numbers
nano-pdf edit invoice.pdf 0 "Change the invoice number from INV-001 to INV-2024-001"

# Add watermark
nano-pdf edit document.pdf 0 "Add 'DRAFT' watermark diagonally across the page"
```
