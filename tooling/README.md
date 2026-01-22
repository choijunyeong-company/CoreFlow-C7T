# CoreFlow Xcode Templates

Xcode file templates for quickly scaffolding CoreFlow features.

## Installation

Run the install script:

```bash
./install-xcode-template.sh
```

This will install templates to `~/Library/Developer/Xcode/Templates/File Templates/CoreFlow/`.

## Usage

1. In Xcode, select **File → New → File...** (or press ⌘N)
2. Scroll down to find **CoreFlow** section
3. Select **CoreFlow** template
4. Enter your feature name (e.g., "Login", "Settings", "Profile")
5. Check/uncheck **Owns Screen** based on your needs

## Template Variants

### Default (Owns Screen)
Creates a full feature with:
- `{FeatureName}Core.swift` - State management (Action, State, reduce)
- `{FeatureName}Screen.swift` - UI layer (UIViewController)
- `{FeatureName}Flow.swift` - Composition root (creates Core + Screen)

### ScreenLess
Creates a coordinator-only feature with:
- `{FeatureName}Core.swift` - Routing only (no state management)
- `{FeatureName}Flow.swift` - Composition root (creates Core only)

Use ScreenLess for flows that only coordinate child flows without their own UI.

## Uninstall

To remove the templates:

```bash
rm -rf ~/Library/Developer/Xcode/Templates/File\ Templates/CoreFlow
```
