# Redmine Contact Validation Plugin

This plugin adds validation to the Contact model in Redmine, modifies the address display format, adds the "Neues Ticket" button to contact views, and provides visual indicators for required fields.

## Features

### Required Field Indicators
Visual red stars (*) are dynamically added to required fields in the "New Contact" form using JavaScript:
- **Vorname** (First name) - red star indicator
- **Nachname** (Last name) - red star indicator  
- **PLZ** (Postal code) - red star indicator and placeholder text
- **Ort** (City) - red star indicator and placeholder text
- **Kanton** (Region) - red star indicator and placeholder text
- **HTML5 required attribute** - Browser-level validation for all required fields

### Validation
Required fields for contacts:
- **Nachname** (Last name) - required
- **Ort** (City) - required  
- **Kanton** (Canton/Region) - required
- **PLZ** (Postal code) - required

### Address Display Format
- **Form Order**: PLZ field appears before Ort field in contact forms
- **Display Format**: Addresses are shown as "PLZ Ort" (e.g., "8001 Zürich")
- **Consistent Formatting**: Both form display and address output use the same format

### Contextual Actions
- **"Neues Ticket" Button**: Adds a "New Ticket" button to contact detail pages
- **Proper Integration**: Button appears in the contextual menu area

## Technical Implementation

### JavaScript-Based Field Indicators
- Uses view hooks to inject JavaScript on contact pages
- Dynamically adds required field indicators after page load
- Handles both static forms and dynamic content updates
- Supports company/person toggle functionality

### Model Validation
- Patches the Contact model to add server-side validation
- Ensures data integrity at the database level
- Provides user-friendly error messages

### View Overrides
- Custom contextual menu for "Neues Ticket" button
- Maintains compatibility with existing contact functionality

## Files Structure

```
plugins/redmine_contact_validation/
├── init.rb                                           # Plugin initialization
├── contact_validation_patch.rb                       # Contact model patches
├── lib/
│   ├── redmine_contact_validation.rb                 # Main library
│   └── redmine_contact_validation/
│       └── hooks/
│           └── views_contacts_hook.rb                 # View hooks for JavaScript injection
├── app/
│   └── views/
│       └── contacts/
│           └── _contextual.html.erb                  # Contextual menu override
└── README.md                                         # This file
```

## Installation

The plugin is automatically loaded when Redmine starts. No additional configuration is required.

## Usage

### Contact Creation
1. Navigate to "New Contact" in any project
2. Required fields will be marked with red asterisks (*)
3. Browser validation will prevent submission if required fields are empty
4. Server-side validation provides additional data integrity

### Address Display
- Addresses in contact lists and details show as "PLZ Ort" format
- Form fields are ordered with PLZ before Ort for better user experience

### Ticket Creation
- Use the "Neues Ticket" button on contact detail pages to create related tickets
- Button integrates seamlessly with existing Redmine functionality

## Compatibility

- Works with Redmine 6.x
- Compatible with redmine_contacts plugin
- Does not interfere with other contact-related plugins

## Author

Created by Assistant for Redmine 6 integration with redmine_contacts plugin. 