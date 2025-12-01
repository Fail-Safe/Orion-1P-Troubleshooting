# Test Processor

Drop your exported JSON files from the test pages here, then run:

```bash
./scripts/process-test-results.sh
```

## Expected Files

- `focus-timing-*.json` - Exported from `automated-focus-test.html`
- `mini-speedometer-*.json` - Exported from `mini-speedometer.html`

The script will parse these files and output formatted Markdown tables that you can copy into your results file.
