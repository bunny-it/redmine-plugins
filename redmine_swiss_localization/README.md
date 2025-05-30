# Redmine Swiss Localization Plugin

This plugin provides Swiss-specific German localization for Redmine, customizing terminology to match Swiss conventions.

## Features

### Terminology Changes
- **Tracker** → **Leistungsart** (Service type)
- **Subject** → **Betreff** (Subject)
- **Due Date** → **Frist** (Deadline)
- **Company** → **Organisation** (Organization)
- **Region** → **Kanton** (Canton)
- **Postcode** → **PLZ** (Swiss postal code format)

### Address Format
- Uses Swiss address conventions with "Kanton" instead of "Region"
- Uses "PLZ" instead of "Postcode" for postal codes

## Installation

1. **Place the plugin** in your Redmine plugins directory
2. **Restart Redmine** to load the plugin
3. **Set language** to German (de) in Redmine settings

## Usage

Once installed and Redmine is set to German language, the Swiss terminology will automatically be used throughout the interface.

## Customizations

The plugin modifies the following German translations:
- Field labels for trackers, subjects, and dates
- Contact and address field labels
- Company/organization terminology

## License

This plugin is licensed under the MIT License. 