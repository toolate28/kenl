#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# ATOM+SAGE Documentation PDF Generator
# Converts markdown documentation to professional PDFs using pandoc
#───────────────────────────────────────────────────────────────────────────────

set -euo pipefail

VERSION="1.0.0"

# Check for pandoc
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc not found"
    echo ""
    echo "Install pandoc:"
    echo "  # On Bazzite/Fedora:"
    echo "  rpm-ostree install pandoc texlive"
    echo "  systemctl reboot"
    echo ""
    echo "  # Or in distrobox:"
    echo "  sudo apt-get install pandoc texlive-xelatex"
    exit 1
fi

echo "════════════════════════════════════════════════════════════"
echo "  ATOM+SAGE PDF Generator v${VERSION}"
echo "════════════════════════════════════════════════════════════"
echo ""

OUTPUT_DIR="./pdfs"
mkdir -p "$OUTPUT_DIR"

# Generate User Manual PDF
echo "[1/4] Generating User Manual PDF..."
if pandoc docs/USER_MANUAL.md -o "${OUTPUT_DIR}/ATOM-SAGE-User-Manual.pdf" \
    --pdf-engine=xelatex \
    --variable geometry:a4paper \
    --variable geometry:margin=2cm \
    --variable fontsize=11pt \
    --variable documentclass=article \
    --toc \
    --toc-depth=3 \
    --number-sections \
    --highlight-style=tango \
    2>&1 | grep -v "WARNING"; then
    echo "✓ Created: ${OUTPUT_DIR}/ATOM-SAGE-User-Manual.pdf"
else
    echo "✗ Failed to generate User Manual PDF"
fi

# Generate Validation Study PDF
echo "[2/4] Generating Validation Study PDF..."
if pandoc docs/VALIDATION_COMPLETE.md -o "${OUTPUT_DIR}/ATOM-SAGE-Validation-Study.pdf" \
    --pdf-engine=xelatex \
    --variable geometry:a4paper \
    --variable geometry:margin=2cm \
    --variable fontsize=11pt \
    --toc \
    --highlight-style=tango \
    2>&1 | grep -v "WARNING"; then
    echo "✓ Created: ${OUTPUT_DIR}/ATOM-SAGE-Validation-Study.pdf"
else
    echo "✗ Failed to generate Validation Study PDF"
fi

# Generate Getting Started PDF
echo "[3/4] Generating Getting Started PDF..."
if pandoc docs/GETTING_STARTED.md -o "${OUTPUT_DIR}/ATOM-SAGE-Getting-Started.pdf" \
    --pdf-engine=xelatex \
    --variable geometry:a4paper \
    --variable geometry:margin=2cm \
    --variable fontsize=11pt \
    --toc \
    --highlight-style=tango \
    2>&1 | grep -v "WARNING"; then
    echo "✓ Created: ${OUTPUT_DIR}/ATOM-SAGE-Getting-Started.pdf"
else
    echo "✗ Failed to generate Getting Started PDF"
fi

# Generate Quick Reference PDF
echo "[4/4] Generating Quick Reference PDF..."
if pandoc docs/QUICK_REFERENCE.md -o "${OUTPUT_DIR}/ATOM-SAGE-Quick-Reference.pdf" \
    --pdf-engine=xelatex \
    --variable geometry:a4paper \
    --variable geometry:margin=1cm \
    --variable fontsize=10pt \
    --highlight-style=tango \
    2>&1 | grep -v "WARNING"; then
    echo "✓ Created: ${OUTPUT_DIR}/ATOM-SAGE-Quick-Reference.pdf"
else
    echo "✗ Failed to generate Quick Reference PDF"
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  PDF Generation Complete"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Generated PDFs:"
ls -lh "$OUTPUT_DIR"/*.pdf 2>/dev/null || echo "No PDFs generated"
echo ""
echo "Total size: $(du -sh "$OUTPUT_DIR" | cut -f1)"
echo ""
echo "PDFs saved to: $OUTPUT_DIR/"
