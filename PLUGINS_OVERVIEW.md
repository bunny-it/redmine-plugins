# Redmine Plugins Overview

This document provides an overview of all installed Redmine plugins and their functionality.

## Plugin Index

### 1. **redmine_contact_validation**
- **Purpose**: Validates required fields for Contact model
- **Required Fields**: 
  - Nachname (last_name)
  - Ort (city)
  - Kanton (region) 
  - PLZ (postcode)
- **Scope**: Global - applies to all contacts
- **Files**: 
  - `contact_validation_patch.rb` - Main validation logic
  - `lib/redmine_contact_validation/hooks/views_contacts_hook.rb` - UI enhancements

### 2. **redmine_contacts**
- **Purpose**: Core CRM functionality for managing contacts and deals
- **Features**:
  - Contact management with addresses, phone numbers, emails
  - Deal tracking with categories and probabilities
  - Import/export functionality
  - Calendar views
  - Custom field support
- **Files**: Extensive plugin with models, views, controllers, and helpers

### 3. **redmine_household_validation** ⚠️ **FIXED**
- **Purpose**: Validates household member fields for specific projects
- **Required Fields** (when applicable):
  - Anzahl Frauen im Haushalt (Custom Field ID: 8)
  - Anzahl Männer im Haushalt (Custom Field ID: 9)
  - Anzahl Kinder im Haushalt (Custom Field ID: 10)
- **Scope**: Project-specific - only applies to:
  - `fallbearbeitung` project
  - `beratung` project
  - And their subprojects
- **Recent Fix**: 
  - Added project-based validation to prevent errors in irrelevant projects
  - **CRITICAL FIX**: Prevents validation from running when only adding comments/notes
  - Only validates when custom fields are available for the tracker
  - Fixes "Haushalt" validation errors when saving comments

### 4. **redmine_journal_updated_date** ⚠️ **UPDATED**
- **Purpose**: Replaces relative date text with absolute dates in journal entries
- **Target Patterns**:
  - "vor X Tagen aktualisiert" → "am DD.MM.YYYY aktualisiert"
  - "vor etwa X Monaten aktualisiert" → "am DD.MM.YYYY aktualisiert"
  - Various other German relative date patterns
- **Scope**: Issue pages and journal entries
- **Recent Fix**: Enhanced pattern matching, fallback logic, and DOM mutation detection

### 5. **redmine_more_previews**
- **Purpose**: Provides preview functionality for various file types
- **Supported Formats**: Documents, images, archives, etc.
- **Features**: 
  - Multiple converter engines (cliff, libre, maggie, mark, etc.)
  - Inline and iframe preview modes
  - Asset handling for previews

### 6. **redmine_postcode_lookup**
- **Purpose**: Postcode lookup and validation functionality
- **Features**: Address autocomplete based on postal codes
- **Files**: Controllers, models, and views for postcode management

### 7. **redmine_spent_time**
- **Purpose**: Time tracking and reporting functionality
- **Features**:
  - Time entry management
  - Reporting by date ranges
  - User-specific time tracking
  - Project-based time analysis

### 8. **redmine_swiss_localization**
- **Purpose**: Swiss-specific localization settings
- **Features**: Swiss German language support and formatting

### 9. **redmine_view_customizations** ⚠️ **UPDATED**
- **Purpose**: Various UI customizations and enhancements
- **Features**:
  - Reorders project tabs (Overview, Issues, Contacts)
  - Shows absolute timestamps in author lines
  - Moves Thema/Unterthema fields to top of issue form
  - Restores contact autocomplete functionality
- **Recent Fix**: Added conflict prevention with journal date plugin

## Recent Bug Fixes (December 2024)

### Issue 1: Inconsistent Date Display
**Problem**: Some journal entries showed relative dates ("vor 1 Monat") while others showed absolute dates.

**Solution**: Enhanced the `redmine_journal_updated_date` plugin with:
- More comprehensive pattern matching (covers "etwa", "her", weeks, months, years)
- Fallback logic when title attributes are missing
- DOM mutation observer for dynamically loaded content
- Better conflict prevention with other plugins

### Issue 2: Required Fields in Wrong Projects
**Problem**: Household validation fields were required in all projects, including "Kommunikation" where they don't exist.

**Solution**: Updated `redmine_household_validation` plugin to:
- Only validate in specific projects (`fallbearbeitung`, `beratung`)
- Check parent projects (for subprojects)
- **CRITICAL**: Skip validation when only adding comments/notes to existing issues
- Skip validation when household custom fields aren't available for the tracker
- Log validation decisions for debugging

**Issue Fixed**: The validation was incorrectly triggering when users saved comments on any issue, even when the household fields weren't relevant. Now it only validates when creating/updating actual issue data.

## Installation Status

All plugins are currently **ACTIVE** and **LOADED** in the Redmine 6.0.5 instance.

## Configuration Notes

1. **Custom Field IDs**: The household validation plugin uses hardcoded custom field IDs (8, 9, 10). Update these in `household_patch.rb` if field IDs change.

2. **Project Identifiers**: The household validation uses project identifiers (`fallbearbeitung`, `beratung`). Update the `allowed_project_identifiers` array if more projects need this validation.

3. **JavaScript Timing**: Both date-related plugins use periodic checks and mutation observers to handle dynamically loaded content.

## Maintenance

- **Log Monitoring**: Check Rails logs for validation messages and plugin loading confirmations
- **JavaScript Console**: Use browser dev tools to monitor date replacement in real-time
- **Plugin Updates**: Restart Redmine container after any plugin modifications

---

*Last Updated: December 17, 2024*
*Redmine Version: 6.0.5*
*Environment: Docker Container* 