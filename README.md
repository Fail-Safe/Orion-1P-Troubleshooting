# 1Password + Orion Browser Test Suite

This repository contains test pages and tools to help diagnose and measure the performance issues between 1Password and Orion Browser.

## Quick Start

1. **Start the local test server:**
   ```bash
   ./start-server.sh
   ```
   This launches a minimal HTTP server on http://localhost:8080

2. **Open the test suite** in your browser:
   - http://localhost:8080/

3. **Run the Automated Focus Test** (recommended):
   - Click "Extended Test (10 runs)"
   - Wait for completion and click "Download JSON"
   - Test in multiple browsers for comparison

4. **Record your results** using the template:
   ```bash
   cp test-results/TEMPLATE.md test-results/YourUsername.results.md
   ```

---

## Contributing Results

When sharing your results:
1. Copy `test-results/TEMPLATE.md` to `test-results/YourUsername.results.md`
2. Run `./scripts/collect-system-info.sh` and paste the output
3. Export JSON from test pages, drop into `./test-processor/`
4. Run `./scripts/process-test-results.sh` and paste the formatted output
5. Add any additional observations

---

### Alternative Server Options

If you prefer not to use the Swift server:
```bash
# Python (if installed)
cd test-pages && python3 -m http.server 8080

# Node.js (if installed)
cd test-pages && npx serve -p 8080
```

---

## Test Pages

All test pages are located in the `test-pages/` directory.

### 1. `automated-focus-test.html` ⭐ Recommended

**Purpose:** Automated test that measures the delay between focusing an input field and when it's ready to receive keystrokes.

**What it tests:**
- Cold start performance (first focus after page load)
- Warm performance (subsequent focuses)
- Consistency across multiple iterations
- Username, password, and email input fields

**Modes:**
- **Standard (5 runs):** Quick test with 15 measurements
- **Extended (10 runs):** More thorough test with 30 measurements and a pause between batches

**How to use:**
1. Open in Orion with 1Password enabled
2. Click "Extended Test (10 runs)"
3. Wait for completion and click "Download JSON"
4. Repeat in other browsers (Safari, Brave, etc.) for comparison

---

### 2. `mini-speedometer.html`
**Purpose:** A simplified benchmark that creates multiple iframes with input fields to simulate Speedometer 3.1's behavior.

**What it tests:**
- Performance impact of repeated iframe creation with inputs
- Measures how 1Password script injection affects rendering speed
- Operations per second (higher is better)

**How to use:**
1. Click "Run Benchmark"
2. Wait for completion and click "Download JSON"
3. Repeat in other browsers for comparison

---

## Testing Protocol

### Basic Comparison Test
1. **Orion + 1Password enabled:**
   - Run both test pages
   - Export JSON results

2. **Safari + 1Password enabled:**
   - Run both test pages
   - Export JSON results

3. **Another browser (Brave, Edge, Firefox, etc.) + 1Password enabled:**
   - Run both test pages
   - Export JSON results

### What to Look For

#### In `automated-focus-test.html`:
- **Cold Start > 100ms** indicates a problem (Orion typically shows 100-200ms, others show 10-15ms)
- **Warm performance** should be fast across all browsers (< 20ms)
- Large gap between cold and warm suggests script initialization overhead

#### In `mini-speedometer.html`:
- Compare scores between browsers
- Lower scores in Orion vs other browsers indicate performance overhead

---

## Running Locally

Serve the test pages from the project root:

```bash
# Using Swift (no dependencies, macOS only)
./scripts/serve.swift

# Using Python
python3 -m http.server 8080 -d test-pages

# Using Node.js
npx serve test-pages
```

Then visit `http://localhost:8080/` in your browser.

---

## Project Structure

```
Orion-1P-Troubleshooting/
├── README.md
├── .github/
│   └── copilot-instructions.md    # Background info on the issue
├── scripts/
│   ├── collect-system-info.sh     # System info collector script
│   ├── process-test-results.sh    # JSON to Markdown processor
│   └── serve.swift                # Minimal web server (no dependencies)
├── test-pages/
│   ├── index.html                 # Test suite landing page
│   ├── automated-focus-test.html  # Input focus timing (recommended)
│   └── mini-speedometer.html      # Simplified benchmark
├── test-processor/                # Drop exported JSON files here
│   └── README.md
└── test-results/
    ├── TEMPLATE.md                # Results template
    └── *.results.md               # Individual test results
```
