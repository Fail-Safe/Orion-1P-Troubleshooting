# Result Summary

## Executor Details

### User Information and Date

- **Name / GitHub User**: RichieB2B
- **Orion Forum Profile**: https://orionfeedback.org/u/RichieB
- **Execution Date**: 2025-12-16

### Hardware Information

- **Model Name**: MacBook Pro
- **Model Identifier**: MacBookPro18,2
- **Chip**: Apple M1 Max
- **Memory**: 64 GB

### Software Information

- **macOS Version**: macOS 26.2 (25C56)
- **Orion Version**: 1.0.0 (139)
- **1Password Extension Type**: Chrome
- **1Password Extension Version**: 8.10.46.26

## Test Results

### Automated Focus Test Results

- **Timestamp:** 2025-12-16T19:56:20.577Z
- **Browser:** Orion
- **Test Mode:** extended

| Metric | Value |
|--------|-------|
| Overall Average | 8ms |
| Range | 5ms - 26ms |
| Std Deviation | 3.7ms |
| Cold Start (iter 1) | 17ms |
| Warm (iter 2+) | 8ms |
| Measurements | 30 |

**Per-Iteration Results:**

| Iteration | Field | Time | Status |
|-----------|-------|------|--------|
| #1 | username | 15ms | ✓ Fast |
| #1 | password | 26ms | ✓ Fast |
| #1 | email | 12ms | ✓ Fast |
| #2 | username | 5ms | ✓ Fast |
| #2 | password | 9ms | ✓ Fast |
| #2 | email | 9ms | ✓ Fast |
| #3 | username | 7ms | ✓ Fast |
| #3 | password | 6ms | ✓ Fast |
| #3 | email | 6ms | ✓ Fast |
| #4 | username | 7ms | ✓ Fast |
| #4 | password | 8ms | ✓ Fast |
| #4 | email | 9ms | ✓ Fast |
| #5 | username | 9ms | ✓ Fast |
| #5 | password | 10ms | ✓ Fast |
| #5 | email | 7ms | ✓ Fast |
| #6 | username | 7ms | ✓ Fast |
| #6 | password | 9ms | ✓ Fast |
| #6 | email | 8ms | ✓ Fast |
| #7 | username | 12ms | ✓ Fast |
| #7 | password | 11ms | ✓ Fast |
| #7 | email | 8ms | ✓ Fast |
| #8 | username | 10ms | ✓ Fast |
| #8 | password | 8ms | ✓ Fast |
| #8 | email | 7ms | ✓ Fast |
| #9 | username | 6ms | ✓ Fast |
| #9 | password | 5ms | ✓ Fast |
| #9 | email | 7ms | ✓ Fast |
| #10 | username | 7ms | ✓ Fast |
| #10 | password | 9ms | ✓ Fast |
| #10 | email | 8ms | ✓ Fast |

### Automated Focus Test Results

- **Timestamp:** 2025-12-16T20:06:44.793Z
- **Browser:** Safari
- **Test Mode:** extended

| Metric | Value |
|--------|-------|
| Overall Average | 9ms |
| Range | 1ms - 91ms |
| Std Deviation | 15.6ms |
| Cold Start (iter 1) | 40ms |
| Warm (iter 2+) | 6ms |
| Measurements | 30 |

**Per-Iteration Results:**

| Iteration | Field | Time | Status |
|-----------|-------|------|--------|
| #1 | username | 1ms | ✓ Fast |
| #1 | password | 91ms | ~ OK |
| #1 | email | 29ms | ✓ Fast |
| #2 | username | 8ms | ✓ Fast |
| #2 | password | 7ms | ✓ Fast |
| #2 | email | 6ms | ✓ Fast |
| #3 | username | 6ms | ✓ Fast |
| #3 | password | 6ms | ✓ Fast |
| #3 | email | 7ms | ✓ Fast |
| #4 | username | 7ms | ✓ Fast |
| #4 | password | 6ms | ✓ Fast |
| #4 | email | 6ms | ✓ Fast |
| #5 | username | 7ms | ✓ Fast |
| #5 | password | 7ms | ✓ Fast |
| #5 | email | 6ms | ✓ Fast |
| #6 | username | 10ms | ✓ Fast |
| #6 | password | 8ms | ✓ Fast |
| #6 | email | 7ms | ✓ Fast |
| #7 | username | 6ms | ✓ Fast |
| #7 | password | 7ms | ✓ Fast |
| #7 | email | 5ms | ✓ Fast |
| #8 | username | 6ms | ✓ Fast |
| #8 | password | 7ms | ✓ Fast |
| #8 | email | 6ms | ✓ Fast |
| #9 | username | 5ms | ✓ Fast |
| #9 | password | 6ms | ✓ Fast |
| #9 | email | 5ms | ✓ Fast |
| #10 | username | 5ms | ✓ Fast |
| #10 | password | 6ms | ✓ Fast |
| #10 | email | 6ms | ✓ Fast |

### Mini Speedometer Results

- **Timestamp:** 2025-12-16T20:13:19.058Z
- **Browser:** Safari 26.2

| Run | Iterations | Total Time | Avg/Iter | Score |
|-----|------------|------------|----------|-------|
| #1 | 50 | 4073ms | 80.7ms | 12.39 ops/sec |

**Summary:** 12.39 ops/sec avg (range: 12.39 - 12.39)

### Mini Speedometer Results

- **Timestamp:** 2025-12-16T20:12:11.896Z
- **Browser:** Orion 26.0

| Run | Iterations | Total Time | Avg/Iter | Score |
|-----|------------|------------|----------|-------|
| #1 | 50 | 2562ms | 51.12ms | 19.56 ops/sec |

**Summary:** 19.56 ops/sec avg (range: 19.56 - 19.56)

# Additional Observertions

I came across these tests because 1Password in Orion was giving me massive
performance problems. Of course the solved themselves before running these
tests as the results show.

