#!/bin/bash
# Pipeline continuous improvement test loop
# Triggers pipeline via webhook, waits for completion, checks output quality
# Usage: ./pipeline-test-loop.sh [max_iterations]

set -euo pipefail

MAX_ITER=${1:-5}
WEBHOOK_URL="http://localhost:5678/webhook/meeting-audio"
VAULT="/home/ai_admin/MrPte Vault"
QUEUE_STATE="$HOME/.local/share/trace/pipeline_queue.json"
DONE_DIR="/srv/transcribe/pipeline_done"
REPORT_FILE="/home/ai_admin/Projects/n8n-workflows/scripts/test-report.md"
LOG_DIR="/home/ai_admin/Projects/n8n-workflows/scripts/test-logs"
mkdir -p "$LOG_DIR"

# Test audio: 37-min "Delivery Readiness Weekly" (shorter, faster iteration)
TEST_PAYLOAD='{
  "file_id": "CQACAgQAAxkBAAIG-Gm8HUcKl9S5-_QbGuGTzXIdqYtIAAIpIQACCjXgUQdYS6QeMJvgOgQ",
  "chat_id": "1502389483",
  "bot_token": "8699271183:AAF6LJ1GjgYcpNiJVcDEQmHZ3GmsLRlAaUU",
  "meeting_name": "TEST Delivery Readiness Weekly",
  "participants": ["Rantala Petri", "Rita Päivi", "Hahtola Jaakko", "Kuivaniemi Aku", "Syvänen Sirpa", "Äijälä Heidi"],
  "date": "2026-03-18",
  "start_time": "14:00",
  "end_time": "14:37",
  "context": ""
}'

# Quality checks on minutes output
check_quality() {
    local file="$1"
    local iter="$2"
    local issues=0
    local checks_passed=0
    local total_checks=7
    local log="$LOG_DIR/iter-${iter}.log"

    echo "=== Quality Check: iteration $iter ===" > "$log"
    echo "File: $file" >> "$log"
    echo "" >> "$log"

    # Check 1: No 999999 in topic names or headings
    if grep -q '### 999999\|^- \*\*999999' "$file" 2>/dev/null; then
        echo "FAIL: 999999 sentinel leaked as topic name" >> "$log"
        issues=$((issues + 1))
    else
        echo "PASS: No 999999 sentinel in topic names" >> "$log"
        checks_passed=$((checks_passed + 1))
    fi

    # Check 2: No duplicate speaker mappings comment mentions first participant as SPEAKER_00
    local speaker_map
    speaker_map=$(grep -o '<!-- Speaker map: [^>]*-->' "$file" 2>/dev/null || echo "")
    if [ -n "$speaker_map" ]; then
        echo "INFO: $speaker_map" >> "$log"
        # Count unique names in speaker map
        local dupes
        dupes=$(echo "$speaker_map" | grep -oP '= \K[^,>]+' | sort | uniq -d | head -5)
        if [ -n "$dupes" ]; then
            echo "INFO: Duplicate speaker mappings detected: $dupes" >> "$log"
            # Check if merged clusters note is present
            if echo "$speaker_map" | grep -q 'Merged clusters'; then
                echo "PASS: Dedup note present for merged clusters" >> "$log"
                checks_passed=$((checks_passed + 1))
            else
                echo "FAIL: Duplicate mappings but no dedup note" >> "$log"
                issues=$((issues + 1))
            fi
        else
            echo "PASS: No duplicate speaker mappings" >> "$log"
            checks_passed=$((checks_passed + 1))
        fi
    else
        echo "WARN: No speaker map comment found" >> "$log"
        issues=$((issues + 1))
    fi

    # Check 3: Names in Lastname Firstname order (no "Petri Rantala", "Päivi Rita" etc)
    if grep -qP '\[\[(?:Petri|Päivi|Jaakko|Aku|Sirpa|Heidi) [A-ZÄÖÅ]' "$file" 2>/dev/null; then
        echo "FAIL: Names in Firstname Lastname order detected" >> "$log"
        issues=$((issues + 1))
    else
        echo "PASS: All wikilinked names in Lastname Firstname order" >> "$log"
        checks_passed=$((checks_passed + 1))
    fi

    # Check 4: No instruction echoing
    if grep -qiP 'Write ONE sentence|use EXACT format|REPLACE this instruction|List 3-[57] concrete|Attribute key points to' "$file" 2>/dev/null; then
        echo "FAIL: Instruction text echoed in output" >> "$log"
        issues=$((issues + 1))
    else
        echo "PASS: No instruction echoing detected" >> "$log"
        checks_passed=$((checks_passed + 1))
    fi

    # Check 5: Action items have correct format
    local ap_count
    ap_count=$(grep -c '^\- \[ \] \*\*\*Action Point:\*\*\*' "$file" 2>/dev/null || echo "0")
    if [ "$ap_count" -gt 0 ]; then
        echo "PASS: $ap_count action items with correct format" >> "$log"
        checks_passed=$((checks_passed + 1))
    else
        echo "WARN: No action items found (may be legitimate)" >> "$log"
        checks_passed=$((checks_passed + 1))  # Not a failure
    fi

    # Check 6: Executive style check — count "X noted that" / "X confirmed that" patterns
    local verbose_count
    verbose_count=$(grep -cP '\b\w+ (?:noted|confirmed|raised|emphasized|explained|clarified|expressed|observed|predicted|reported) that\b' "$file" 2>/dev/null || echo "0")
    if [ "$verbose_count" -gt 10 ]; then
        echo "FAIL: Too many attribution patterns ($verbose_count) — not executive level" >> "$log"
        issues=$((issues + 1))
    else
        echo "PASS: Attribution level OK ($verbose_count patterns)" >> "$log"
        checks_passed=$((checks_passed + 1))
    fi

    # Check 7: Multiple topics (not single "Full Meeting")
    local topic_count
    topic_count=$(grep -c '^### ' "$file" 2>/dev/null || echo "0")
    if [ "$topic_count" -lt 2 ]; then
        echo "FAIL: Only $topic_count topic(s) — segmentation may have failed" >> "$log"
        issues=$((issues + 1))
    else
        echo "PASS: $topic_count topics segmented" >> "$log"
        checks_passed=$((checks_passed + 1))
    fi

    echo "" >> "$log"
    echo "RESULT: $checks_passed/$total_checks passed, $issues issues" >> "$log"
    cat "$log"
    return $issues
}

# Wait for pipeline completion (polls queue state)
wait_for_completion() {
    local timeout=5400  # 90 min max
    local elapsed=0
    local interval=30

    while [ $elapsed -lt $timeout ]; do
        local active
        active=$(python3 -c "import json;d=json.load(open('$QUEUE_STATE'));print('yes' if d.get('active') else 'no')" 2>/dev/null || echo "yes")
        if [ "$active" = "no" ]; then
            return 0
        fi
        sleep $interval
        elapsed=$((elapsed + interval))
        local mins=$((elapsed / 60))
        echo "  Waiting... ${mins}m elapsed"
    done
    echo "TIMEOUT after ${timeout}s"
    return 1
}

# Main loop
echo "# Pipeline Test Loop Report" > "$REPORT_FILE"
echo "Started: $(date '+%Y-%m-%d %H:%M:%S %Z')" >> "$REPORT_FILE"
echo "Max iterations: $MAX_ITER" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

for i in $(seq 1 "$MAX_ITER"); do
    echo ""
    echo "========================================="
    echo "ITERATION $i of $MAX_ITER"
    echo "========================================="
    START_TIME=$(date +%s)

    # Check if queue is clear
    active=$(python3 -c "import json;d=json.load(open('$QUEUE_STATE'));print('yes' if d.get('active') else 'no')" 2>/dev/null || echo "no")
    if [ "$active" = "yes" ]; then
        echo "Queue busy, waiting for current pipeline..."
        wait_for_completion
    fi

    # Delete previous test output
    rm -f "$VAULT/100 - Meeting minutes/2026-03-18 TEST Delivery Readiness Weekly.md"
    rm -f "$VAULT/101 - Meeting Intelligence Reports/2026-03-18 TEST Delivery Readiness Weekly - Intelligence Report.md"
    rm -f "$VAULT/102 - Meeting Extracts/2026-03-18 TEST Delivery Readiness Weekly - Key Items.md"

    # Trigger pipeline
    echo "Triggering pipeline..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "$TEST_PAYLOAD")

    if [ "$HTTP_CODE" != "200" ]; then
        echo "ERROR: Webhook returned $HTTP_CODE"
        echo "## Iteration $i — WEBHOOK FAILED ($HTTP_CODE)" >> "$REPORT_FILE"
        continue
    fi
    echo "Webhook OK ($HTTP_CODE). Waiting for completion..."

    # Wait a moment for queue to pick it up
    sleep 5

    # Wait for completion
    if ! wait_for_completion; then
        echo "## Iteration $i — TIMEOUT" >> "$REPORT_FILE"
        continue
    fi

    END_TIME=$(date +%s)
    DURATION=$(( (END_TIME - START_TIME) / 60 ))
    echo "Pipeline completed in ~${DURATION} min"

    # Check output
    MINUTES_FILE="$VAULT/100 - Meeting minutes/2026-03-18 TEST Delivery Readiness Weekly.md"
    if [ ! -f "$MINUTES_FILE" ]; then
        echo "ERROR: Minutes file not created!"
        echo "## Iteration $i — NO OUTPUT (${DURATION}m)" >> "$REPORT_FILE"
        continue
    fi

    echo ""
    echo "--- Quality Check ---"
    ISSUES=0
    check_quality "$MINUTES_FILE" "$i" || ISSUES=$?

    # Write to report
    echo "## Iteration $i — ${ISSUES} issues (${DURATION}m)" >> "$REPORT_FILE"
    cat "$LOG_DIR/iter-${i}.log" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Copy output for comparison
    cp "$MINUTES_FILE" "$LOG_DIR/minutes-iter-${i}.md"

    INTEL_FILE="$VAULT/101 - Meeting Intelligence Reports/2026-03-18 TEST Delivery Readiness Weekly - Intelligence Report.md"
    [ -f "$INTEL_FILE" ] && cp "$INTEL_FILE" "$LOG_DIR/intel-iter-${i}.md"

    EXTRACT_FILE="$VAULT/102 - Meeting Extracts/2026-03-18 TEST Delivery Readiness Weekly - Key Items.md"
    [ -f "$EXTRACT_FILE" ] && cp "$EXTRACT_FILE" "$LOG_DIR/extract-iter-${i}.md"

    if [ "$ISSUES" -eq 0 ]; then
        echo ""
        echo "ALL CHECKS PASSED! Pipeline quality validated."
        echo "" >> "$REPORT_FILE"
        echo "## RESULT: ALL CHECKS PASSED at iteration $i" >> "$REPORT_FILE"
        break
    fi

    echo ""
    echo "$ISSUES issue(s) remain. Will continue to next iteration."
done

echo "" >> "$REPORT_FILE"
echo "Completed: $(date '+%Y-%m-%d %H:%M:%S %Z')" >> "$REPORT_FILE"
echo ""
echo "Report saved to: $REPORT_FILE"
cat "$REPORT_FILE"
