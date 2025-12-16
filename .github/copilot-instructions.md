# Orion Browser and 1Password Integration Issues

## Development Notes

> **Schema Versioning:** The test page JSON exports include a `schemaVersion` field (currently `1`). If you modify the JSON structure (add/remove/rename fields, change data types, etc.), **increment the schema version** in both:
> - `test-pages/automated-focus-test.html`
> - `test-pages/mini-speedometer.html`
>
> Then update `scripts/process-test-results.sh` to handle the new version.

## Problem Statement

Users have reported issues when trying to use 1Password with the Orion Browser. The integration is not as seamless and quick as what is experienced in other browsers like Brave, Firefox, or even Safari. This has led to frustration among users who rely on 1Password for password management and autofill capabilities.

## Orion Browser Overview

Orion Browser is a privacy-focused web browser that emphasizes user security and minimal data collection. It offers features such as ad-blocking, tracker blocking, and a clean user interface. It is based on WebKit, similar to Safari, but has its own unique architecture and design choices. It supports extensions, both Firefox and Chrome style.

Orion's source code is closed-source. From an end-user perspective, testing is limited to that which can be performed directly within the browser environment (and via Dev Tools), without access to internal implementation details.

## 1Password Overview

1Password is a popular password manager that helps users securely store and manage their passwords, credit card information, and other sensitive data. It offers features like autofill, password generation, and secure sharing. 1Password integrates with various web browsers to provide a seamless experience for users when logging into websites or filling out forms.

## Integration Issues

### 1. Autofill Delays
Users have reported that the autofill feature of 1Password is slower in Orion compared to other browsers. This delay can lead to a less efficient user experience.

### 2. Input Field Focus Delay
When an input field is focused for the first time with 1Password enabled, there is a significant delay before the input can actually receive typed text. Subsequent focuses of the same input work fine. This is an Orion-specific issue—Safari with the same 1Password extension does not exhibit this behavior.

**Symptoms:**
- Clicking on an input field shows visual focus (e.g., border changes) but typing is blocked until after the delay
- Dropdown menus on forms exhibit lag when clicked
- On some sites (e.g., kagi.com), users experience beachball cursors before they can type
- Azure DevOps PR comment fields are particularly affected since the `<input>` is replaced with a `<textarea>` on focus, triggering the delay repeatedly

### 3. Significant Performance Impact (Speedometer 3.1 Benchmarks)
- **Without 1Password**: ~18.0 score (or higher depending on hardware)
- **With 1Password enabled**: ~8.0-14.0 score
- **Comparison**: Brave with 1Password enabled achieves ~27.6 on the same hardware

### 4. High CPU Usage
When the 1Password Chrome extension is enabled, a `chrome-extension://...` process appears in Activity Monitor using upwards of 100% CPU during page rendering/benchmarks.

## Technical Analysis

### How 1Password Works
The 1Password extension injects a JavaScript file (`injected.js`, ~360 kB, ~17,260 lines) into every page containing `<input>` elements (and possibly other form-related HTML elements/CSS selectors).

- On typical websites, `injected.js` is loaded only a few times (e.g., once on Amazon, three times on Walmart, twice on Reddit)
- On benchmark sites like Speedometer 3.1, it may be injected 200+ times due to sub-pages with input elements

### Suspected Root Cause: Script Caching Difference
In Brave, all injections of `injected.js` are initiated by a single script (`inject-content-scripts.js`) using incrementing VMs, suggesting the parsed script is cached and held in memory for efficient re-execution.

In Orion, the same `injected.js` is initiated by dozens of different initiators, suggesting the ~360 kB script may be re-parsed and re-interpreted each time rather than being cached.

### Extension Variant Behavior
- **Chrome extension**: Exhibits the slowdown
- **Firefox extension**: Behaves identically to Chrome version (same slowdown and lag)
- **Safari extension**: Also slow in Orion, despite being "blazing fast" in native Safari

This suggests the issue is with how Orion handles extension script injection/execution, not with the specific extension variant.

## Status
This issue is tagged as **Planned** on the [Orion feedback tracker](https://orionfeedback.org/d/11099-speed-decline-with-1password-extension).

## Reproduction Steps
1. Open macOS Activity Monitor to CPU page, sort by % CPU descending
2. Disable all extensions in Orion
3. Visit https://browserbench.org/Speedometer3.1/ and run test
4. Note absence of `chrome-extension://...` process and record score (~18+)
5. Enable only the 1Password Chrome extension
6. Refresh and run Speedometer test again
7. Note presence of `chrome-extension://...` process with high CPU usage
8. Record score (~8-14)

## Environment
- Orion versions affected: 0.99.133-beta through 1.0.0 (139-rc)
- WebKit versions: 621.1.2.111.4, 623.1.8.0.0
- macOS: Sequoia 15.x and Tahoe 26.x
- Hardware: Various Macs (performance impact may vary by CPU model and RAM)

## Preliminary Test Findings (December 2025)

> ⚠️ **Note:** These findings are preliminary and require further testing to confirm they hold true across different hardware configurations, Orion versions, and usage scenarios.

### Extended Automated Focus Test Results (10 iterations)

A reliable automated test was created that focuses inputs programmatically without DOM manipulation. The test runs 10 iterations in two batches of 5, with a 5-second pause between batches to measure consistency.

#### Complete Browser Comparison

| Browser | Cold Start | Warm | Overall Avg | Range | Consistency |
|---------|-----------|------|-------------|-------|-------------|
| **Opera** | 11ms | 3.3ms | 4.1ms | 2-14ms | ✓ Excellent |
| **Brave** | 11ms | 4.0ms | 4.7ms | 3-12ms | ✓ Excellent |
| **Edge** | 11ms | 3.8ms | 4.5ms | 3-15ms | ✓ Excellent |
| **Firefox** | 14ms | 6.8ms | 7.5ms | 3-17ms | ✓ Excellent |
| **Safari** | 42ms | 11.5ms | 14.6ms | 8-52ms | ~ Good |
| **Orion** | **143ms** | 7.3ms | 20.9ms | 3-159ms | ⚠️ Variable |

#### Cold Start Ranking (Best to Worst)
1. 🥇 Opera/Brave/Edge: ~11ms
2. 🥈 Firefox: 14ms
3. 🥉 Safari: 42ms
4. ❌ **Orion: 143ms** (10-13x slower than Chromium browsers)

#### Warm Performance Ranking
1. 🥇 Opera: 3.3ms
2. 🥇 Edge: 3.8ms
3. 🥇 Brave: 4.0ms
4. 🥈 Firefox: 6.8ms
5. 🥈 **Orion: 7.3ms** ← Actually competitive!
6. 🥉 Safari: 11.5ms

### Key Findings

1. **Orion's cold start is 10-13x slower than Chromium browsers** (143ms vs 11ms)
2. **Orion's cold start is 3.4x slower than Safari** (143ms vs 42ms) - same WebKit engine!
3. **Orion's warm performance is competitive** - actually faster than Safari (7.3ms vs 11.5ms)
4. **The problem is definitively cold start / script initialization**
5. **No degradation over time** - batch 2 performance matches batch 1

### Orion Cold Start Breakdown (Iteration 1)

| Field | Time |
|-------|------|
| Username | 115ms |
| Password | 159ms |
| Email | 155ms |
| **Average** | **143ms** |

### What This Proves

1. **The performance issue is real and measurable** - Orion's 143ms cold start vs Brave's 11ms is a 13x difference
2. **The delay is on first focus only** - Subsequent focuses on the same page are fast (~7ms)
3. **1Password's code runs fine in Orion** - Warm performance proves the extension itself is not the problem
4. **The script caching hypothesis is strongly supported** - If Orion re-parses `injected.js` (~360kB) on each page load rather than using cached bytecode, this explains the 130ms+ cold start overhead
5. **Safari comparison proves it's Orion-specific** - Same WebKit, same 1Password extension, but Safari is 3.4x faster on cold start

### Perception Thresholds
- **< 50ms** = Imperceptible (feels instant) ← All Chromium browsers
- **50-100ms** = Barely noticeable
- **100-200ms** = Noticeable lag ← **Orion falls here**
- **> 200ms** = Feels sluggish

At ~143ms cold start, users experience a perceptible delay every time they click a login field on a new page in Orion.

### Browser Detection

Orion can be programmatically detected via JavaScript globals it exposes:
- `window.OrionInternals`
- `window.kagi`
- `window.KAGI`

This allows automated tests to correctly identify Orion vs Safari (which share the same WebKit user agent string).

### Areas for Further Investigation

- [ ] Test on different Mac hardware (M1, M2, Intel) to see if delays scale with CPU
- [ ] Test with other complex extensions to see if the issue is 1Password-specific or affects all extensions
- [ ] Profile JavaScript execution in Orion's DevTools to identify specific bottlenecks
- [x] Compare Safari (native) with same 1Password extension to isolate WebKit vs Orion differences - **DONE: Confirms Orion-specific issue**
- [ ] Test with 1Password disabled to establish baseline focus event timing

