# modules/KENL Document Archive

**ATOM-CFG-20251105-021**

This directory contains archived documentation organized by date.

## Archive Structure

```
.archive/
├── 2025-11-02/  # Early project documentation
├── 2025-11-05/  # Pre-rebase documentation
└── README.md    # This file
```

## Document Status Definitions

- **active**: Current, in-use documentation
- **archive**: Historical reference, content superseded or integrated elsewhere
- **superseded**: Replaced by newer version (see `superseded_by` field)

## Registry

See `../.kenl/document-registry.json` for complete document metadata.

## Retrieval

To restore archived documents:
```bash
cp .archive/YYYY-MM-DD/filename.md ./
```

## ATOM Trail

All archive operations are logged with ATOM tags for traceability.
