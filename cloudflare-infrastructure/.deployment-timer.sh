#!/bin/bash
# Deployment Timer - Track actual deployment times
# ATOM: ATOM-TIMER-20251116-001
# Usage: Source this file at the start of deployment

# Initialize timing
export DEPLOYMENT_START=$(date +%s)
export STEP_START=$(date +%s)
export CURRENT_STEP=0

# Timer functions
step_complete() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    STEP_END=$(date +%s)
    STEP_DURATION=$((STEP_END - STEP_START))

    echo "Step $CURRENT_STEP completed in $((STEP_DURATION / 60))m $((STEP_DURATION % 60))s"
    echo "$(date -Iseconds),Step $CURRENT_STEP,$STEP_DURATION" >> .deployment-times.csv

    # Reset for next step
    STEP_START=$(date +%s)
}

deployment_complete() {
    DEPLOYMENT_END=$(date +%s)
    TOTAL_DURATION=$((DEPLOYMENT_END - DEPLOYMENT_START))

    echo ""
    echo "═══════════════════════════════════════════"
    echo "  Deployment Complete!"
    echo "═══════════════════════════════════════════"
    echo "Total time: $((TOTAL_DURATION / 60))m $((TOTAL_DURATION % 60))s"
    echo ""

    # Update assumptions file
    if [ -f .assumptions.md ]; then
        echo "" >> .assumptions.md
        echo "## First Deployment Results ($(date +%Y-%m-%d))" >> .assumptions.md
        echo "" >> .assumptions.md
        echo "Total deployment time: $((TOTAL_DURATION / 60)) minutes $((TOTAL_DURATION % 60)) seconds" >> .assumptions.md
        echo "" >> .assumptions.md
        echo "Step-by-step breakdown:" >> .assumptions.md
        echo '```' >> .assumptions.md
        cat .deployment-times.csv >> .assumptions.md
        echo '```' >> .assumptions.md
    fi

    # Log to ATOM
    echo "ATOM-DEPLOY-COMPLETE-$(date +%Y%m%d)-001: First deployment completed in $((TOTAL_DURATION / 60))m" >> ~/.kenl/atom-trail.log
}

# Initialize CSV
echo "timestamp,step,duration_seconds" > .deployment-times.csv

echo "⏱️  Deployment timer started. Use 'step_complete' after each step."
