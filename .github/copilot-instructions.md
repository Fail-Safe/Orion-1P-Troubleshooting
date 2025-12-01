# Orion Browser and 1Password Integration Issues

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
This issue is tagged as **Planned** on the Orion feedback tracker.

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

### Simple Focus Test Results

A simple, non-automated test was created to measure real-world user experience: the time from clicking an input field to when 1Password's button appears. This test uses no DOM manipulation and mimics actual user behavior.

#### Test Results

| Browser | Username Field | Password Field | Email Field | Average |
|---------|----------------|----------------|-------------|---------|
| **Brave** | 1-8ms | 2-8ms | 1-5ms | **~4ms** |
| **Orion** | 185ms | 127ms | 127ms | **~146ms** |

**Key Finding:** Orion is approximately **36x slower** than Brave for 1Password to respond to input focus events.

#### Perception Thresholds
- **< 50ms** = Imperceptible (feels instant)
- **50-100ms** = Barely noticeable
- **100-200ms** = Noticeable lag ← **Orion falls here**
- **> 200ms** = Feels sluggish

At ~146ms average, users experience a perceptible delay every time they click a login field in Orion, which accumulates into the "sluggish" feeling reported by users.

### Automated Focus Test Results (Cold vs Warm)

A more reliable automated test was created that focuses inputs programmatically without DOM manipulation. This revealed a critical **cold start vs warm** pattern:

#### Raw Results (3 iterations each)

| Browser | Iteration 1 (Cold) | Iteration 2 (Warm) | Iteration 3 (Warm) | Overall Avg |
|---------|-------------------|-------------------|-------------------|-------------|
| **Brave** | 11ms | 6ms | 6ms | **7.7ms** |
| **Opera** | 17ms | 4ms | 4ms | **8.4ms** |
| **Edge** | 17ms | 5ms | 4ms | **8.7ms** |
| **Firefox** | 18ms | 4ms | 6ms | **9.2ms** |
| **Safari 26.1** | 41ms | 14ms | 12ms | **22.3ms** |
| **Orion** | 131ms | 8ms | 9ms | **49.1ms** |

#### Cold Start Penalty Analysis

| Browser | Cold Start | Warm | Cold Start Penalty |
|---------|------------|------|-------------------|
| **Brave** | ~11ms | ~6ms | +5ms |
| **Safari** | ~41ms | ~13ms | +28ms |
| **Orion** | ~131ms | ~8ms | **+123ms** |

**Key Findings:**

1. **Orion's warm performance matches Brave** - Once 1Password has initialized for a page, Orion is just as fast (~8ms vs ~6ms)
2. **The problem is cold start** - Orion takes ~131ms on the first focus, vs Safari's ~41ms and Brave's ~11ms
3. **This is Orion-specific, not WebKit** - Safari (same WebKit engine) is only 3.7x slower on cold start, but Orion is **12x slower** than Brave
4. **Every page load triggers cold start** - Users experience the 130ms delay on every new page with login forms

This strongly supports the hypothesis that Orion is not caching parsed/compiled extension scripts the way Brave and Safari do.

### Automated Test Observations

Automated tests that manipulate the DOM (removing/recreating forms and 1Password elements) produced misleading results:

- **Brave:** Showed extreme event loop blocking (40-60 second delays) that doesn't match real-world experience
- **Orion:** Showed consistent ~120ms delays with minimal event loop blocking

The automated test appears to trigger pathological behavior in Brave's 1Password extension handling, making it unsuitable for browser comparison. However, the ~120ms measurement for Orion was consistent with the simple focus test results.

### What This Suggests

1. **The performance issue is real and measurable** - Orion's ~131ms cold start vs Brave's ~11ms is a 12x difference
2. **The delay is on first focus only** - Subsequent focuses on the same page are fast (~8ms)
3. **Event loop blocking is NOT the cause** - Orion's JavaScript thread is not blocked; the delay is in 1Password's script execution itself
4. **The script caching hypothesis is strongly supported** - If Orion re-parses `injected.js` on each page load rather than using cached bytecode, this explains the ~120ms cold start overhead
5. **Safari comparison proves it's Orion-specific** - Same WebKit, same 1Password extension, but Safari is 3x faster on cold start

### Areas for Further Investigation

- [ ] Test on different Mac hardware (M1, M2, Intel) to see if delays scale with CPU
- [ ] Test with other complex extensions to see if the issue is 1Password-specific or affects all extensions
- [ ] Profile JavaScript execution in Orion's DevTools to identify specific bottlenecks
- [x] Compare Safari (native) with same 1Password extension to isolate WebKit vs Orion differences - **DONE: Confirms Orion-specific issue**
- [ ] Test with 1Password disabled to establish baseline focus event timing

