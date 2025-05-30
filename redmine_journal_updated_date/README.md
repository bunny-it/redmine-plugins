# Redmine Journal Updated Date Plugin

This plugin replaces relative date text like "vor 7 Tagen bearbeitet" with absolute dates in journal entries (ticket comments/updates) in Redmine.

## Features

### Absolute Date Display
- **Automatic Detection**: Automatically detects text containing "bearbeitet" (edited) in journal entries
- **Date Replacement**: Replaces relative dates like "vor 7 Tagen bearbeitet" with absolute dates like "bearbeitet am 20.05.2025"
- **Tooltip Integration**: Extracts the actual date from HTML title attributes (hover tooltips)
- **German Localization**: Works with German date formats (DD.MM.YYYY)
- **Real-time Updates**: Continuously monitors for new content and updates dates accordingly

### Display Format
The relative date text is replaced with absolute dates:
- **Before**: "vor 7 Tagen bearbeitet"
- **After**: "bearbeitet am 20.05.2025"

## Technical Details

### Implementation
- Uses JavaScript hooks to scan and replace text content
- Extracts actual dates from HTML title attributes
- Handles various relative date patterns (Tagen, Stunden, Minuten)
- Runs on page load, AJAX completion, and periodically for dynamic content
- Works with both text nodes and element content

### Pattern Matching
The plugin recognizes and replaces these patterns:
- "vor X Tag bearbeitet"
- "vor X Tagen bearbeitet" 
- "vor X Stunde bearbeitet"
- "vor X Stunden bearbeitet"
- "vor X Minute bearbeitet"
- "vor X Minuten bearbeitet"

### Compatibility
- Works with Redmine 6.x
- Compatible with existing journal functionality
- Does not interfere with other plugins
- Preserves original tooltip functionality

## Installation

The plugin is automatically loaded when Redmine starts. No additional configuration is required.

## Files Structure

```
plugins/redmine_journal_updated_date/
├── init.rb                                    # Plugin initialization
├── lib/
│   ├── redmine_journal_updated_date.rb       # Main library
│   └── redmine_journal_updated_date/
│       └── hooks/
│           └── journal_hooks.rb               # View hooks for JavaScript injection
└── README.md                                  # This file
```

## Usage

The plugin works automatically on all issue pages. When viewing an issue with journal entries that contain relative date text like "vor X Tagen bearbeitet", the plugin will:

1. Detect the relative date text
2. Find the corresponding absolute date in the HTML title attribute
3. Replace the relative text with the absolute date
4. Continue monitoring for new content

## Examples

### Before Plugin
- "Von Zoe von Streng vor 7 Tagen aktualisiert"

### After Plugin  
- "Von Zoe von Streng bearbeitet am 20.05.2025"

## Author

Created by Assistant for Redmine 6 integration. 