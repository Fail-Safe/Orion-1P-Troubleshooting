# Result Summary

## Executor Details

### User Information and Date

- **Name / GitHub User**: darsnack
- **Orion Forum Profile**: https://orionfeedback.org/u/darsnack
- **Execution Date**: 2026-01-07

### Hardware Information

<!-- Run: ./scripts/collect-system-info.sh and paste the output -->

- **Model Name**: MacBook Pro
- **Model Identifier**: MacBookPro18,3
- **Chip**: Apple M1 Pro
- **Memory**: 16 GB

### Software Information

- **macOS Version**: macOS 26.1 (25B78)
- **Orion Version**: 1.0.0 (139)
- **1Password Extension Type**: Chrome
- **1Password Extension Version**: 8.11.18.36

<!-- End of ./scripts/collect-system-info.sh output -->

## Test Results

<!--
To generate formatted results:
1. Export JSON files from each test page (click "Export Results")
2. Drop the JSON files into ./test-processor/
3. Run: ./scripts/process-test-results.sh
4. Copy and paste the formatted output below
-->

<!-- Paste output from process-test-results.sh below this line -->
==============================================
  Test Results Processor
==============================================

Found files:
  ./test-processor/focus-timing-orion-2026-01-07-1310.json
  ./test-processor/focus-timing-safari-2026-01-07-1309.json
  ./test-processor/focus-timing-firefox-2026-01-07-1312.json

==========================================
  FORMATTED OUTPUT (copy below this line)
==========================================

### Automated Focus Test Results

- **Timestamp:** 2026-01-07T13:10:51.790Z
- **Browser:** Orion
- **Test Mode:** extended

| Metric | Value |
|--------|-------|
| Overall Average | 24ms |
| Range | 3ms - 184ms |
| Std Deviation | 52.4ms |
| Cold Start (iter 1) | 181ms |
| Warm (iter 2+) | 6ms |
| Measurements | 30 |

**Per-Iteration Results:**

| Iteration | Field | Time | Status |
|-----------|-------|------|--------|
| #1 | username | 183ms | ⚠️ Slow |
| #1 | password | 176ms | ⚠️ Slow |
| #1 | email | 184ms | ⚠️ Slow |
| #2 | username | 8ms | ✓ Fast |
| #2 | password | 7ms | ✓ Fast |
| #2 | email | 8ms | ✓ Fast |
| #3 | username | 9ms | ✓ Fast |
| #3 | password | 7ms | ✓ Fast |
| #3 | email | 7ms | ✓ Fast |
| #4 | username | 10ms | ✓ Fast |
| #4 | password | 9ms | ✓ Fast |
| #4 | email | 10ms | ✓ Fast |
| #5 | username | 7ms | ✓ Fast |
| #5 | password | 5ms | ✓ Fast |
| #5 | email | 4ms | ✓ Fast |
| #6 | username | 8ms | ✓ Fast |
| #6 | password | 4ms | ✓ Fast |
| #6 | email | 9ms | ✓ Fast |
| #7 | username | 7ms | ✓ Fast |
| #7 | password | 4ms | ✓ Fast |
| #7 | email | 4ms | ✓ Fast |
| #8 | username | 6ms | ✓ Fast |
| #8 | password | 4ms | ✓ Fast |
| #8 | email | 7ms | ✓ Fast |
| #9 | username | 7ms | ✓ Fast |
| #9 | password | 6ms | ✓ Fast |
| #9 | email | 5ms | ✓ Fast |
| #10 | username | 9ms | ✓ Fast |
| #10 | password | 5ms | ✓ Fast |
| #10 | email | 3ms | ✓ Fast |

### Automated Focus Test Results

- **Timestamp:** 2026-01-07T13:09:00.496Z
- **Browser:** Safari
- **Test Mode:** extended

| Metric | Value |
|--------|-------|
| Overall Average | 11ms |
| Range | 3ms - 88ms |
| Std Deviation | 15.5ms |
| Cold Start (iter 1) | 49ms |
| Warm (iter 2+) | 6ms |
| Measurements | 30 |

**Per-Iteration Results:**

| Iteration | Field | Time | Status |
|-----------|-------|------|--------|
| #1 | username | 88ms | ~ OK |
| #1 | password | 37ms | ✓ Fast |
| #1 | email | 22ms | ✓ Fast |
| #2 | username | 6ms | ✓ Fast |
| #2 | password | 7ms | ✓ Fast |
| #2 | email | 8ms | ✓ Fast |
| #3 | username | 3ms | ✓ Fast |
| #3 | password | 7ms | ✓ Fast |
| #3 | email | 10ms | ✓ Fast |
| #4 | username | 7ms | ✓ Fast |
| #4 | password | 6ms | ✓ Fast |
| #4 | email | 6ms | ✓ Fast |
| #5 | username | 8ms | ✓ Fast |
| #5 | password | 9ms | ✓ Fast |
| #5 | email | 6ms | ✓ Fast |
| #6 | username | 6ms | ✓ Fast |
| #6 | password | 7ms | ✓ Fast |
| #6 | email | 6ms | ✓ Fast |
| #7 | username | 7ms | ✓ Fast |
| #7 | password | 5ms | ✓ Fast |
| #7 | email | 7ms | ✓ Fast |
| #8 | username | 9ms | ✓ Fast |
| #8 | password | 7ms | ✓ Fast |
| #8 | email | 9ms | ✓ Fast |
| #9 | username | 5ms | ✓ Fast |
| #9 | password | 7ms | ✓ Fast |
| #9 | email | 6ms | ✓ Fast |
| #10 | username | 6ms | ✓ Fast |
| #10 | password | 6ms | ✓ Fast |
| #10 | email | 9ms | ✓ Fast |

### Automated Focus Test Results

- **Timestamp:** 2026-01-07T13:12:11.240Z
- **Browser:** Firefox
- **Test Mode:** extended

| Metric | Value |
|--------|-------|
| Overall Average | 10ms |
| Range | 1ms - 61ms |
| Std Deviation | 12.4ms |
| Cold Start (iter 1) | 25ms |
| Warm (iter 2+) | 8ms |
| Measurements | 30 |

**Per-Iteration Results:**

| Iteration | Field | Time | Status |
|-----------|-------|------|--------|
| #1 | username | 41ms | ✓ Fast |
| #1 | password | 22ms | ✓ Fast |
| #1 | email | 13ms | ✓ Fast |
| #2 | username | 2ms | ✓ Fast |
| #2 | password | 10ms | ✓ Fast |
| #2 | email | 11ms | ✓ Fast |
| #3 | username | 9ms | ✓ Fast |
| #3 | password | 8ms | ✓ Fast |
| #3 | email | 7ms | ✓ Fast |
| #4 | username | 25ms | ✓ Fast |
| #4 | password | 5ms | ✓ Fast |
| #4 | email | 6ms | ✓ Fast |
| #5 | username | 6ms | ✓ Fast |
| #5 | password | 2ms | ✓ Fast |
| #5 | email | 5ms | ✓ Fast |
| #6 | username | 1ms | ✓ Fast |
| #6 | password | 2ms | ✓ Fast |
| #6 | email | 61ms | ~ OK |
| #7 | username | 17ms | ✓ Fast |
| #7 | password | 7ms | ✓ Fast |
| #7 | email | 5ms | ✓ Fast |
| #8 | username | 4ms | ✓ Fast |
| #8 | password | 1ms | ✓ Fast |
| #8 | email | 2ms | ✓ Fast |
| #9 | username | 8ms | ✓ Fast |
| #9 | password | 7ms | ✓ Fast |
| #9 | email | 10ms | ✓ Fast |
| #10 | username | 5ms | ✓ Fast |
| #10 | password | 7ms | ✓ Fast |
| #10 | email | 3ms | ✓ Fast |

==========================================
