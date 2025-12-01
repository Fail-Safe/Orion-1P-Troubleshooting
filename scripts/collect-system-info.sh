#!/bin/bash
#
# Orion + 1Password Troubleshooting - System Info Collector
#
# This script collects hardware and software information needed for
# reporting issues with 1Password extension performance in Orion Browser.
#
# Usage: ./collect-system-info.sh
#

echo "=============================================="
echo "  Orion + 1Password System Info Collector"
echo "=============================================="
echo ""

echo "=========================================="
echo "  FORMATTED OUTPUT (copy below this line)"
echo "=========================================="
echo ""

# --- Hardware Information ---
echo "### Hardware Information"
echo ""

# Get hardware details
MODEL_NAME=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/.*: //')
MODEL_ID=$(system_profiler SPHardwareDataType | grep "Model Identifier" | sed 's/.*: //')
CHIP=$(system_profiler SPHardwareDataType | grep "Chip" | sed 's/.*: //')
MEMORY=$(system_profiler SPHardwareDataType | grep "Memory" | sed 's/.*: //')

echo "- **Model Name**: $MODEL_NAME"
echo "- **Model Identifier**: $MODEL_ID"
echo "- **Chip**: $CHIP"
echo "- **Memory**: $MEMORY"
echo ""

# --- Software Information ---
echo "### Software Information"
echo ""

# macOS Version
MACOS_VER="macOS $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
echo "- **macOS Version**: $MACOS_VER"

# Orion Version - check multiple possible locations
ORION_VERSION=""
ORION_APP=""

if [ -d "/Applications/Orion.app" ]; then
	ORION_APP="/Applications/Orion.app"
elif [ -d "/Applications/Orion RC.app" ]; then
	ORION_APP="/Applications/Orion RC.app"
elif [ -d "/Applications/Orion Beta.app" ]; then
	ORION_APP="/Applications/Orion Beta.app"
fi

if [ -n "$ORION_APP" ]; then
	SHORT_VER=$(defaults read "$ORION_APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)
	BUILD_VER=$(defaults read "$ORION_APP/Contents/Info.plist" CFBundleVersion 2>/dev/null)
	if [ -n "$SHORT_VER" ] && [ -n "$BUILD_VER" ]; then
		ORION_VERSION="$SHORT_VER ($BUILD_VER)"
	fi
fi

if [ -n "$ORION_VERSION" ]; then
	echo "- **Orion Version**: $ORION_VERSION"
else
	echo "- **Orion Version**: ⚠️ Orion not found in /Applications"
fi

# 1Password Extension - check both Chrome and Firefox extensions
# Chrome extension ID for 1Password: aeblfdkhhhdcdjpifhhbdiojplfjncoa
# Firefox extension ID varies

ONEPASS_TYPE=""
ONEPASS_VERSION=""

# Determine Orion support folder
ORION_SUPPORT=""
if [ -d ~/Library/Application\ Support/Orion ]; then
	ORION_SUPPORT=~/Library/Application\ Support/Orion
elif [ -d ~/Library/Application\ Support/Orion\ RC ]; then
	ORION_SUPPORT=~/Library/Application\ Support/Orion\ RC
elif [ -d ~/Library/Application\ Support/Orion\ Beta ]; then
	ORION_SUPPORT=~/Library/Application\ Support/Orion\ Beta
fi

if [ -n "$ORION_SUPPORT" ]; then
	# Check for Chrome 1Password extension
	CHROME_1P="$ORION_SUPPORT/Defaults/Extensions/aeblfdkhhhdcdjpifhhbdiojplfjncoa"
	if [ -d "$CHROME_1P" ]; then
		MANIFEST="$CHROME_1P/manifest.json"
		if [ -f "$MANIFEST" ]; then
			ONEPASS_TYPE="Chrome"
			ONEPASS_VERSION=$(grep '"version"' "$MANIFEST" | head -1 | sed 's/.*: "//;s/".*//')
		fi
	fi

	# If not found, search for Firefox 1Password extension
	if [ -z "$ONEPASS_VERSION" ]; then
		# Firefox extensions are in a different location with different IDs
		FF_MANIFEST=$(find "$ORION_SUPPORT" -name "manifest.json" -exec grep -l "1Password" {} \; 2>/dev/null | head -1)
		if [ -n "$FF_MANIFEST" ]; then
			ONEPASS_TYPE="Firefox"
			ONEPASS_VERSION=$(grep '"version"' "$FF_MANIFEST" | head -1 | sed 's/.*: "//;s/".*//')
		fi
	fi
fi

if [ -n "$ONEPASS_VERSION" ]; then
	echo "- **1Password Extension Type**: $ONEPASS_TYPE"
	echo "- **1Password Extension Version**: $ONEPASS_VERSION"
else
	echo "- **1Password Extension Type**: ⚠️ Not found"
	echo "- **1Password Extension Version**: ⚠️ Not found"
fi

echo ""
echo "=========================================="
echo ""
echo -e "${GREEN}Done! Copy the formatted output above into your results file.${NC}"
echo ""
