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
