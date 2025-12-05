#!/usr/bin/env bash
set -euo pipefail

#
# Agent Documentation Sink Cleanup
# ATOM: ATOM-SCRIPT-20251205-008
# Purpose: Automated archival of agent-generated documentation with spot-check audit
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MODE="${1:-preview}"
AGE_DAYS="${2:-90}"
COUNTER_FILE=".sink-counter"
ARCHIVE_BASE=".archive/sessions"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize counter if missing
initialize_counter() {
    if [ ! -f "$COUNTER_FILE" ]; then
        cat > "$COUNTER_FILE" <<EOF
LAST_CLEANUP=$(date +%Y-%m-%d)
FILE_COUNT=$(find . -maxdepth 1 -name "*.md" -type f | wc -l)
ARCHIVABLE_COUNT=0
CLEANUP_THRESHOLD=50
EOF
        echo -e "${GREEN}✅ Initialized sink counter${NC}"
    fi
}

# Update counter
update_counter() {
    local file_count archivable_count
    file_count=$(find . -maxdepth 1 -name "*.md" -type f | wc -l)
    archivable_count=$(find . -maxdepth 1 \( -name "ATOM-*.md" -o -name "SESSION-*.md" -o -name "*-analysis*.md" -o -name "*-assessment*.md" -o -name "*-comparison*.md" \) -type f | wc -l)
    
    # Preserve CLEANUP_THRESHOLD if it exists
    local threshold=50
    if [ -f "$COUNTER_FILE" ]; then
        threshold=$(grep "CLEANUP_THRESHOLD" "$COUNTER_FILE" | cut -d= -f2)
    fi
    
    cat > "$COUNTER_FILE" <<EOF
LAST_CLEANUP=$(date +%Y-%m-%d)
FILE_COUNT=$file_count
ARCHIVABLE_COUNT=$archivable_count
CLEANUP_THRESHOLD=$threshold
EOF
}

# Check if cleanup is needed
check_threshold() {
    source "$COUNTER_FILE" 2>/dev/null || true
    local current_count
    current_count=$(find . -maxdepth 1 -name "*.md" -type f | wc -l)
    
    echo -e "${BLUE}📊 Sink Status:${NC}"
    echo "  Total files: $current_count"
    echo "  Archivable files: ${ARCHIVABLE_COUNT:-0}"
    echo "  Threshold: ${CLEANUP_THRESHOLD:-50}"
    echo "  Last cleanup: ${LAST_CLEANUP:-never}"
    echo ""
    
    if [ "$current_count" -gt "${CLEANUP_THRESHOLD:-50}" ]; then
        echo -e "${YELLOW}⚠️  Cleanup recommended (${current_count} > ${CLEANUP_THRESHOLD:-50})${NC}"
        return 0
    else
        echo -e "${GREEN}✅ Within threshold${NC}"
        return 1
    fi
}

# Preview mode - show what would be archived
preview_mode() {
    echo -e "${BLUE}📋 Preview Mode - Files eligible for archive (>${AGE_DAYS} days old):${NC}"
    echo ""
    
    local count=0
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            local age_days
            age_days=$(( ($(date +%s) - $(stat -c %Y "$file")) / 86400 ))
            echo "  - $file (${age_days} days old)"
            ((count++))
        fi
    done < <(find . -maxdepth 1 \( -name "ATOM-*.md" -o -name "SESSION-*.md" -o -name "*-analysis*.md" -o -name "*-assessment*.md" \) -type f -mtime +${AGE_DAYS})
    
    echo ""
    echo -e "${BLUE}Total eligible: ${count} files${NC}"
    echo ""
    echo -e "${YELLOW}Anchored files (never archived):${NC}"
    echo "  - CURRENT-STATE.md"
    echo "  - RECENT-WORK.md"
    echo "  - NEXT-STEPS.md"
    echo "  - QUICK-REFERENCE.md"
    echo "  - AI-AGENT-SYSTEM.md"
    echo "  - DOCUMENTATION-PATHWAYS.md"
    echo "  - README.md"
    echo "  - (any file without ATOM/date pattern)"
}

# Audit mode - random 2% spot check
audit_mode() {
    echo -e "${BLUE}🔍 Audit Mode - Random 2% sample for manual review:${NC}"
    echo ""
    
    local files
    mapfile -t files < <(find . -maxdepth 1 \( -name "ATOM-*.md" -o -name "SESSION-*.md" \) -type f -mtime +${AGE_DAYS})
    
    local total=${#files[@]}
    local sample_size=$(( total * 2 / 100 ))
    [ "$sample_size" -lt 1 ] && sample_size=1
    
    if [ "$total" -eq 0 ]; then
        echo -e "${GREEN}✅ No files eligible for archival${NC}"
        return 0
    fi
    
    echo "Total eligible files: $total"
    echo "Sample size (2%): $sample_size"
    echo ""
    
    # Random sample
    for file in $(printf '%s\n' "${files[@]}" | shuf -n "$sample_size"); do
        echo "---"
        echo -e "${YELLOW}File: $file${NC}"
        local age_days
        age_days=$(( ($(date +%s) - $(stat -c %Y "$file")) / 86400 ))
        echo "Age: ${age_days} days"
        echo "Size: $(stat -c %s "$file") bytes"
        echo "First 5 lines:"
        head -5 "$file" | sed 's/^/  /'
        echo ""
    done
    
    echo "---"
    echo ""
    echo -e "${YELLOW}Review complete. Proceed with archival? Run:${NC}"
    echo "  ./cleanup-sink.sh execute"
}

# Execute mode - perform actual archival
execute_mode() {
    echo -e "${BLUE}🗂️  Execute Mode - Archiving files...${NC}"
    echo ""
    
    # Create archive directory
    local archive_dir="${ARCHIVE_BASE}/$(date +%Y-%m)"
    mkdir -p "$archive_dir"
    
    local count=0
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            echo "  Archiving: $file"
            mv "$file" "$archive_dir/"
            ((count++))
        fi
    done < <(find . -maxdepth 1 \( -name "ATOM-*.md" -o -name "SESSION-*.md" -o -name "*-analysis*.md" -o -name "*-assessment*.md" \) -type f -mtime +${AGE_DAYS})
    
    if [ "$count" -gt 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Archived ${count} files to ${archive_dir}${NC}"
        
        # Update counter
        update_counter
        echo -e "${GREEN}✅ Updated sink counter${NC}"
        
        # Create archive index
        cat > "${archive_dir}/INDEX.md" <<EOF
# Archived Session Documents

**Archive Date:** $(date +%Y-%m-%d)
**Files Archived:** $count
**Source:** claude-landing/

## Files

$(ls -1 "$archive_dir"/*.md | xargs -n1 basename | sed 's/^/- /')

---

**Restore:** To restore any file, move it back to claude-landing/
\`\`\`bash
mv ${archive_dir}/<filename> ../../../
\`\`\`
EOF
        echo -e "${GREEN}✅ Created archive index${NC}"
    else
        echo -e "${YELLOW}No files to archive${NC}"
    fi
}

# Main
main() {
    initialize_counter
    
    case "$MODE" in
        preview)
            check_threshold || true
            preview_mode
            ;;
        audit)
            check_threshold || true
            audit_mode
            ;;
        execute)
            execute_mode
            ;;
        check)
            check_threshold
            ;;
        *)
            echo -e "${RED}❌ Unknown mode: $MODE${NC}"
            echo ""
            echo "Usage: $0 [mode] [age_days]"
            echo ""
            echo "Modes:"
            echo "  preview  - Show files eligible for archive (default)"
            echo "  audit    - Random 2% spot check for review"
            echo "  execute  - Perform actual archival"
            echo "  check    - Check if cleanup is needed"
            echo ""
            echo "Examples:"
            echo "  $0 preview          # Show eligible files (90+ days old)"
            echo "  $0 preview 60       # Show eligible files (60+ days old)"
            echo "  $0 audit            # Spot check random sample"
            echo "  $0 execute          # Archive files"
            exit 1
            ;;
    esac
}

main
