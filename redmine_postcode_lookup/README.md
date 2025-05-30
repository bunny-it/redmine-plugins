# Redmine Postcode Lookup Plugin

This plugin provides automatic lookup of Swiss municipalities (Ort) and cantons (Kanton) based on postal codes (PLZ) for contact forms in Redmine. It also supports reverse lookup: automatically filling PLZ and Kanton when only the city name is entered.

## Features

### Automatic Address Completion
- **PLZ Input**: When a user enters a Swiss postal code and leaves the field (blur) or presses a key (keyup)
- **Auto-fill**: Automatically populates the Ort (city) and Kanton (canton) fields
- **Multi-language**: Works with both German and English field labels/placeholders

### Reverse Lookup (NEW)
- **Ort Input**: When a user enters a Swiss city name and leaves the field (blur)
- **Auto-fill**: Automatically populates the PLZ (postal code) and Kanton (canton) fields
- **Smart Matching**: Uses exact match first, then case-insensitive, then partial matching
- **Conditional**: Only triggers if PLZ field is empty (prevents conflicts)

### Field Detection
The plugin detects address fields using multiple methods:
1. **Placeholder text**: Looks for placeholders containing "PLZ", "Ort", "Kanton" (German) or "Postcode", "City", "Region" (English)
2. **Field names**: Fallback to field names containing "postcode", "city", "region"
3. **Label text**: Backward compatibility with label-based detection

### Database
- Uses the `chzip` table with Swiss postal code data
- Contains 3000+ Swiss postal codes with corresponding municipalities and cantons

## Installation

1. **Place the plugin** in your Redmine plugins directory
2. **Ensure database** contains the `chzip` table with Swiss postal code data
3. **Restart Redmine** to load the plugin

## Usage

### In Contact Forms
1. Navigate to a contact creation or edit form
2. **Forward Lookup**: Enter a Swiss postal code (e.g., 8001) in the PLZ field → Ort and Kanton will be auto-filled
3. **Reverse Lookup**: Enter a Swiss city name (e.g., "Zürich") in the Ort field → PLZ and Kanton will be auto-filled

### API Endpoints
The plugin provides two public API endpoints:

#### Forward Lookup
- **URL**: `/postcode_lookup/{postcode}`
- **Method**: GET
- **Response**: JSON with `municipality` and `region` fields
- **Example**: `/postcode_lookup/8001` returns `{"municipality":"Zürich","region":"ZH"}`

#### Reverse Lookup
- **URL**: `/city_lookup/{city}`
- **Method**: GET
- **Response**: JSON with `postcode`, `region`, and `municipality` fields
- **Example**: `/city_lookup/Zürich` returns `{"postcode":"8001","region":"ZH","municipality":"Zürich"}`

## Technical Details

### Authentication
- Both lookup endpoints are publicly accessible (no authentication required)
- This allows AJAX calls from contact forms to work without login issues

### Database Schema
```sql
CREATE TABLE chzip (
  zip INT PRIMARY KEY,
  cty VARCHAR(255),  -- Municipality/City
  reg VARCHAR(255)   -- Region/Canton
);
```

### JavaScript Integration
- Automatically loads on pages with contact forms
- Uses jQuery for DOM manipulation and AJAX calls
- Graceful fallback if fields are not found
- Prevents conflicts between forward and reverse lookup

### Reverse Lookup Logic
1. **Exact Match**: Tries to find exact city name match
2. **Case-Insensitive**: If no exact match, tries case-insensitive search
3. **Partial Match**: If still no match, tries partial matching (starts with)
4. **Conditional Execution**: Only runs if PLZ field is empty to prevent conflicts

## License

This plugin is licensed under the MIT License. 