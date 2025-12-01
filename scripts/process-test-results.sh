#!/bin/bash
#
# Orion + 1Password Troubleshooting - Test Results Processor
#
# This script parses JSON files exported from the test pages and generates
# consistently formatted Markdown output for your results file.
#
# Usage:
#   ./scripts/process-test-results.sh
#   ./scripts/process-test-results.sh ./test-processor
#
# Drop your exported JSON files into ./test-processor/ then run this script.
#

set -e

# Default directory
PROCESSOR_DIR="${1:-./test-processor}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}=============================================="
echo "  Test Results Processor"
echo -e "==============================================${NC}"
echo ""

# Check if jq is installed
if ! command -v jq &>/dev/null; then
	echo -e "${RED}Error: 'jq' is required but not installed.${NC}"
	echo "Install it with: brew install jq"
	exit 1
fi

# Check if directory exists
if [ ! -d "$PROCESSOR_DIR" ]; then
	echo -e "${RED}Error: Directory '$PROCESSOR_DIR' not found.${NC}"
	exit 1
fi

# Find JSON files
FOCUS_TIMING_FILES=$(find "$PROCESSOR_DIR" -name "focus-timing*.json" 2>/dev/null)
MINI_SPEEDOMETER_FILES=$(find "$PROCESSOR_DIR" -name "mini-speedometer*.json" 2>/dev/null)

if [ -z "$FOCUS_TIMING_FILES" ] && [ -z "$MINI_SPEEDOMETER_FILES" ]; then
	echo -e "${YELLOW}No JSON files found in $PROCESSOR_DIR${NC}"
	echo ""
	echo "Expected files:"
	echo "  - focus-timing-*.json (from automated-focus-test.html)"
	echo "  - mini-speedometer-*.json (from mini-speedometer.html)"
	echo ""
	echo "Export these files from the test pages and place them in $PROCESSOR_DIR"
	exit 0
fi

echo -e "${GREEN}Found files:${NC}"
[ -n "$FOCUS_TIMING_FILES" ] && echo "$FOCUS_TIMING_FILES" | sed 's/^/  /'
[ -n "$MINI_SPEEDOMETER_FILES" ] && echo "$MINI_SPEEDOMETER_FILES" | sed 's/^/  /'
echo ""

# Process Focus Timing files (from automated-focus-test.html)
process_focus_timing() {
	local file="$1"
	echo "### Automated Focus Test Results"
	echo ""

	# Check schema version
	local schema_version=$(jq -r '.schemaVersion // 0' "$file")
	if [ "$schema_version" -eq 0 ]; then
		echo -e "${YELLOW}Warning: No schema version found (legacy format)${NC}" >&2
	elif [ "$schema_version" -gt 1 ]; then
		echo -e "${YELLOW}Warning: Schema version $schema_version is newer than supported (v1)${NC}" >&2
	fi

	# Get metadata
	local timestamp=$(jq -r '.timestamp // "unknown"' "$file")
	local browser=$(jq -r '.browser // "unknown"' "$file")
	local test_mode=$(jq -r '.testMode // "standard"' "$file")

	echo "- **Timestamp:** $timestamp"
	echo "- **Browser:** $browser"
	echo "- **Test Mode:** $test_mode"
	echo ""

	# Get summary stats
	local has_summary=$(jq 'has("summary") and .summary != null' "$file")

	if [ "$has_summary" = "true" ]; then
		local avg=$(jq -r '.summary.average // 0 | floor' "$file")
		local min=$(jq -r '.summary.min // 0 | floor' "$file")
		local max=$(jq -r '.summary.max // 0 | floor' "$file")
		local std_dev=$(jq -r '.summary.stdDev // 0 | . * 10 | floor | . / 10' "$file")
		local count=$(jq -r '.summary.count // 0' "$file")
		local cold_avg=$(jq -r '.summary.coldAvg // null | if . then floor else "N/A" end' "$file")
		local warm_avg=$(jq -r '.summary.warmAvg // null | if . then floor else "N/A" end' "$file")

		echo "| Metric | Value |"
		echo "|--------|-------|"
		echo "| Overall Average | ${avg}ms |"
		echo "| Range | ${min}ms - ${max}ms |"
		echo "| Std Deviation | ${std_dev}ms |"
		echo "| Cold Start (iter 1) | ${cold_avg}ms |"
		echo "| Warm (iter 2+) | ${warm_avg}ms |"
		echo "| Measurements | $count |"
		echo ""
	fi

	# Per-iteration breakdown
	echo "**Per-Iteration Results:**"
	echo ""
	echo "| Iteration | Field | Time | Status |"
	echo "|-----------|-------|------|--------|"

	jq -r '.results[] | "| #\(.iteration) | \(.field) | \(if .timeout then "timeout" else "\(.elapsed | floor)ms" end) | \(if .timeout then "⚠️ Timeout" elif .elapsed < 50 then "✓ Fast" elif .elapsed < 150 then "~ OK" else "⚠️ Slow" end) |"' "$file" 2>/dev/null || echo "| (no results) | - | - | - |"

	echo ""
}

# Process Mini Speedometer files
process_mini_speedometer() {
	local file="$1"
	echo "### Mini Speedometer Results"
	echo ""

	# Check schema version
	local schema_version=$(jq -r '.schemaVersion // 0' "$file")
	if [ "$schema_version" -eq 0 ]; then
		echo -e "${YELLOW}Warning: No schema version found (legacy format)${NC}" >&2
	elif [ "$schema_version" -gt 1 ]; then
		echo -e "${YELLOW}Warning: Schema version $schema_version is newer than supported (v1)${NC}" >&2
	fi

	# Get metadata
	local timestamp=$(jq -r '.timestamp // "unknown"' "$file")
	local browser=$(jq -r '.browser // "unknown"' "$file")
	local browser_version=$(jq -r '.browserVersion // ""' "$file")

	echo "- **Timestamp:** $timestamp"
	echo "- **Browser:** $browser $browser_version"
	echo ""

	# Process runs
	local run_count=$(jq '.runs | length' "$file")

	if [ "$run_count" -gt 0 ]; then
		echo "| Run | Iterations | Total Time | Avg/Iter | Score |"
		echo "|-----|------------|------------|----------|-------|"

		jq -r '.runs[] | "| #\(.runNumber) | \(.iterations) | \(.totalTime)ms | \(.avgTime)ms | \(.score) ops/sec |"' "$file"

		echo ""

		# Summary - try new format first, fall back to calculating from runs
		local avg_score=$(jq -r 'if .summary.avgScore then .summary.avgScore else ([.runs[].score] | add / length | . * 100 | floor / 100) end' "$file")
		local min_score=$(jq -r 'if .summary.minScore then .summary.minScore else ([.runs[].score] | min) end' "$file")
		local max_score=$(jq -r 'if .summary.maxScore then .summary.maxScore else ([.runs[].score] | max) end' "$file")

		echo "**Summary:** ${avg_score} ops/sec avg (range: ${min_score} - ${max_score})"
		echo ""
	fi
}

# Process all files
echo "=========================================="
echo "  FORMATTED OUTPUT (copy below this line)"
echo "=========================================="
echo ""

for file in $FOCUS_TIMING_FILES; do
	process_focus_timing "$file"
done

for file in $MINI_SPEEDOMETER_FILES; do
	process_mini_speedometer "$file"
done

echo "=========================================="
echo ""
echo -e "${GREEN}Done! Copy the formatted output above into your results file.${NC}"
echo ""
