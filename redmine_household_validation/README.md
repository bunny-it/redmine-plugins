# Redmine Household Validation Plugin

This plugin adds a validation to the Contact model in Redmine, ensuring that at least one of the three household member fields (Anzahl Frauen im Haushalt, Anzahl Männer im Haushalt, Anzahl Kinder im Haushalt) is filled.

## Installation

1. **Clone or download the plugin** into your Redmine plugins directory:
   ```
   cd /path/to/redmine/plugins
   git clone https://github.com/yourusername/redmine_household_validation.git
   ```

2. **Restart Redmine** to load the plugin.

## Configuration

- **Custom Field IDs**: Open `lib/contact_patch.rb` and replace the custom field IDs (1, 2, 3) with the actual IDs for your installation.

## Usage

Once installed and configured, the validation will automatically run when creating or updating a Contact. If all three household member fields are empty, an error message will be displayed.

## License

This plugin is licensed under the MIT License. 