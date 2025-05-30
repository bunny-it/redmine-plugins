# Redmine Plugins Collection

A comprehensive collection of specialized Redmine plugins designed for Swiss NGO operations, particularly tailored for social services and contact management workflows.

## Acknowledgments

This plugin collection builds upon the foundational work of **Lorenz Schori** ([@znerol](https://github.com/znerol) on GitHub), who authored the initial versions of these plugins.

### Client Organization

These plugins have been developed and customized for the **UFS (Unabhängige Fachstelle für Sozialhilfe)**, a Swiss non-governmental organization providing independent social welfare consulting services. Learn more about their mission and services at: **[sozialhilfeberatung.ch](https://sozialhilfeberatung.ch)**

---

## Plugin Overview

This collection includes 9 specialized Redmine plugins that enhance contact management, user experience, and Swiss-specific functionality:

### 🏢 Contact Management Plugins
- **[redmine_contacts](#redmine_contacts)** - Core contact and CRM functionality
- **[redmine_contact_validation](#redmine_contact_validation)** - Contact form validation and UX improvements
- **[redmine_household_validation](#redmine_household_validation)** - Household composition validation

### 🇨🇭 Swiss Localization & Data
- **[redmine_swiss_localization](#redmine_swiss_localization)** - Swiss German terminology customization
- **[redmine_postcode_lookup](#redmine_postcode_lookup)** - Swiss postal code and municipality lookup

### ⏰ User Experience Enhancements
- **[redmine_journal_updated_date](#redmine_journal_updated_date)** - Absolute date display in journals
- **[redmine_spent_time](#redmine_spent_time)** - Enhanced time tracking interface
- **[redmine_view_customizations](#redmine_view_customizations)** - Custom view modifications

### 📄 File Management
- **[redmine_more_previews](#redmine_more_previews)** - Enhanced file preview capabilities

---

## System Requirements

### Redmine Compatibility
- **Redmine 4.x - 6.x** (most plugins)
- **Ruby 2.6+**
- **Rails 5.2+**

### External Dependencies
- **LibreOffice** (for redmine_more_previews document conversion)
- **ImageMagick** (for redmine_more_previews image processing)
- **Pandoc** (optional, for redmine_more_previews markdown support)

---

## Installation

### 1. Clone the Repository
```bash
cd /path/to/redmine/plugins
git clone https://github.com/your-username/redmine-plugins.git
```

### 2. Install Individual Plugins
Each plugin can be installed independently. Copy the desired plugin directories to your Redmine plugins folder:

```bash
# Example: Install contact management plugins
cp -r redmine-plugins/redmine_contacts /path/to/redmine/plugins/
cp -r redmine-plugins/redmine_contact_validation /path/to/redmine/plugins/
cp -r redmine-plugins/redmine_swiss_localization /path/to/redmine/plugins/
```

### 3. Install Dependencies
```bash
cd /path/to/redmine
bundle install --without development test
```

### 4. Run Plugin Migrations
```bash
# For plugins that require database changes
rake redmine:plugins:migrate RAILS_ENV=production
```

### 5. Restart Redmine
```bash
# Example for Apache
sudo systemctl restart apache2

# Or for standalone server
sudo systemctl restart redmine
```

---

## Plugin Documentation

## redmine_contacts

**Core contact and customer relationship management functionality for Redmine.**

### Features
- Complete contact management with companies and individuals
- Deal tracking and pipeline management
- Contact-issue associations
- Project-contact relationships
- Tags and categorization
- Advanced search and filtering
- REST API support

### Database Tables
- `contacts` - Contact information
- `deals` - Sales/service deals
- `contacts_deals` - Contact-deal associations
- `contacts_issues` - Contact-issue associations
- `contacts_projects` - Contact-project associations
- `deal_categories`, `deal_statuses` - Deal classification
- `notes`, `tags`, `taggings` - Additional metadata

### API Endpoints
- **GET** `/contacts.json` - List contacts
- **POST** `/contacts.json` - Create contact
- **GET** `/projects/<project_id>/deal_categories.json` - List deal categories
- **POST** `/projects/<project_id>/deal_categories.json` - Create deal category

---

## redmine_contact_validation

**Enhanced contact form validation with Swiss-specific UX improvements.**

### Features
- **Required Field Validation**: Server-side validation for critical contact fields
- **Visual Indicators**: Red asterisks (*) for required fields using JavaScript
- **Address Format**: Swiss-style "PLZ Ort" address display
- **Quick Actions**: "Neues Ticket" button on contact detail pages
- **Form Optimization**: PLZ field positioned before Ort field

### Required Fields
- Nachname (Last name)
- PLZ (Postal code)
- Ort (City)
- Kanton (Canton)

### Technical Implementation
- JavaScript-based visual indicators
- Model patches for server-side validation
- Custom view hooks for form enhancement
- Contextual menu customization

---

## redmine_swiss_localization

**Swiss German terminology customization for Redmine interface.**

### Terminology Changes
| English/German | Swiss German |
|----------------|--------------|
| Tracker | Leistungsart |
| Subject | Betreff |
| Due Date | Frist |
| Company | Organisation |
| Region | Kanton |
| Postcode | PLZ |

### Usage
1. Install the plugin
2. Set Redmine language to German (de)
3. Swiss terminology automatically applies

---

## redmine_postcode_lookup

**Automatic Swiss address completion using postal codes and city names.**

### Features
- **Forward Lookup**: Enter PLZ → Auto-fill Ort and Kanton
- **Reverse Lookup**: Enter Ort → Auto-fill PLZ and Kanton
- **Smart Matching**: Exact, case-insensitive, and partial matching
- **Multi-language**: Supports German and English field labels
- **Public API**: RESTful endpoints for address lookup

### API Endpoints
- **GET** `/postcode_lookup/{postcode}` - Get city and canton by postal code
- **GET** `/city_lookup/{city}` - Get postal code and canton by city name

### Database Requirements
Requires `chzip` table with Swiss postal code data:
```sql
CREATE TABLE chzip (
  zip INT PRIMARY KEY,
  cty VARCHAR(255),  -- Municipality/City
  reg VARCHAR(255)   -- Region/Canton
);
```

---

## redmine_journal_updated_date

**Converts relative date displays to absolute dates in issue journals.**

### Features
- **Automatic Detection**: Finds relative date text like "vor 7 Tagen bearbeitet"
- **Absolute Conversion**: Replaces with "bearbeitet am 20.05.2025"
- **Real-time Updates**: Monitors dynamic content changes
- **German Localization**: Works with German date formats (DD.MM.YYYY)
- **Tooltip Integration**: Extracts dates from HTML title attributes

### Pattern Recognition
- "vor X Tag/Tagen bearbeitet"
- "vor X Stunde/Stunden bearbeitet"
- "vor X Minute/Minuten bearbeitet"

---

## redmine_spent_time

**Enhanced time tracking interface with comfortable entry and query forms.**

### Features
- **User-friendly Interface**: Simplified time entry forms
- **Advanced Queries**: Flexible filtering and reporting
- **Bulk Operations**: Modify and delete multiple entries
- **Weekend Support**: Allow time entries on weekends
- **Custom Fields**: Support for custom time entry fields
- **Notifications**: Email notifications for time entry changes

### Permissions
- **View spent time**: Access to plugin main page
- **View others spent time**: See team member time entries
- **View every project spent time**: Global time tracking visibility

### Supported Languages
Catalonian, English, French, German, Hungarian, Italian, Japanese, Polish, Portuguese, Russian, Simplified Chinese, Spanish

---

## redmine_household_validation

**Validation for household composition fields in contact forms.**

### Features
- **Household Validation**: Ensures at least one household member field is filled
- **Custom Field Integration**: Works with custom fields for household data
- **Error Handling**: User-friendly validation messages

### Configuration
Update custom field IDs in `lib/contact_patch.rb`:
- Anzahl Frauen im Haushalt (Number of women in household)
- Anzahl Männer im Haushalt (Number of men in household)
- Anzahl Kinder im Haushalt (Number of children in household)

---

## redmine_view_customizations

**Custom view modifications and interface enhancements.**

### Features
- Custom templates and layouts
- Interface modifications for specific workflows
- Project-specific view customizations

---

## redmine_more_previews

**Comprehensive file preview system with multiple format support.**

### Features
- **Universal Preview**: Supports 50+ file formats
- **Multiple Converters**: PDF, HTML, image, and text conversion
- **Sub-plugins**: Modular architecture with specialized converters

### Supported Converters
- **Libre**: LibreOffice-based conversion (.doc, .docx, .xls, .xlsx, .ppt, .pptx, etc.)
- **Cliff**: Email file preview (.eml, .mime)
- **Mark**: Markdown and markup conversion (.md, .textile, .html)
- **Peek**: PDF preview with ImageMagick
- **Zippy**: Archive file browsing (.zip, .tar, .tgz)
- **Maggie**: Image format conversion and scaling
- **Pass**: HTML passthrough
- **Vince**: vCard preview (.vcf)

### Configuration
Access via Administration → Plugins → Redmine More Previews Configuration
- Choose embed vs iframe display
- Enable preview caching
- Activate specific sub-plugins
- Configure file extension handling

---

## Configuration

### Plugin-Specific Settings

#### redmine_contacts
1. Go to Administration → Plugins → Redmine Contacts
2. Configure CRM settings, deal statuses, and permissions
3. Set up project-contact associations

#### redmine_more_previews
1. Navigate to Administration → Plugins → Redmine More Previews Configuration
2. Enable desired file format converters
3. Configure caching and display options

#### redmine_postcode_lookup
Ensure Swiss postal code data is imported into the `chzip` table.

### Permissions Configuration
Visit Administration → Roles and permissions to configure:
- Contact viewing and editing permissions
- Time tracking permissions
- File preview permissions

---

## Troubleshooting

### Common Issues

#### Plugin Not Loading
```bash
# Check plugin status
rake redmine:plugins RAILS_ENV=production

# Clear cache
rake tmp:cache:clear RAILS_ENV=production
```

#### Database Migration Errors
```bash
# Reset plugin migrations
rake redmine:plugins:migrate NAME=plugin_name VERSION=0 RAILS_ENV=production
rake redmine:plugins:migrate NAME=plugin_name RAILS_ENV=production
```

#### Missing Dependencies
```bash
# Install missing gems
bundle install
```

### LibreOffice Issues (redmine_more_previews)
```bash
# Test LibreOffice accessibility
soffice --version

# Ensure soffice is in PATH
which soffice
```

### Swiss Postal Code Data
If postcode lookup isn't working, verify the `chzip` table contains Swiss postal code data with correct column names (`zip`, `cty`, `reg`).

---

## Development

### Contributing
1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit a pull request

### Plugin Development
Each plugin follows standard Redmine plugin structure:
```
plugin_name/
├── init.rb                    # Plugin initialization
├── app/                       # Views, controllers, models
├── lib/                       # Libraries and patches
├── config/                    # Configuration files
├── assets/                    # CSS, JavaScript, images
├── test/                      # Test files
└── README.md                  # Plugin documentation
```

### Testing
```bash
# Run plugin tests
bundle exec rake test:plugins RAILS_ENV=test

# Run specific plugin tests
bundle exec rake test TEST="plugins/plugin_name/test/**/*_test.rb" RAILS_ENV=test
```

---

## Support

### Issue Reporting
- Create issues in the project's GitHub repository
- Include Redmine version, Ruby version, and error logs
- Provide steps to reproduce problems

### Community
- Redmine Plugin Directory
- Redmine Community Forums
- Plugin-specific documentation

---

## License

Individual plugins may have different licenses. Please refer to each plugin's LICENSE file for specific terms. Most plugins in this collection are licensed under:
- **MIT License** (majority)
- **Apache License 2.0** (redmine_spent_time)
- **GPL compatible licenses**

---

## Changelog

### Recent Updates
- **2025**: Updated for Redmine 6.x compatibility
- **2024**: Enhanced Swiss localization features
- **2024**: Improved contact validation and UX
- **2023**: Added household validation functionality

For detailed changelogs, see individual plugin README files.

---

## Related Resources

### UFS Organization
- **Website**: [sozialhilfeberatung.ch](https://sozialhilfeberatung.ch)
- **Mission**: Independent social welfare consulting services
- **Focus**: Supporting individuals and families in Switzerland

### Original Author
- **GitHub**: [@znerol](https://github.com/znerol)
- **Contributions**: Initial plugin development and architecture
- **Projects**: Active contributor to various open-source projects

### Redmine Resources
- **Official Site**: [redmine.org](https://redmine.org)
- **Plugin Directory**: [redmine.org/plugins](https://redmine.org/plugins)
- **Documentation**: [redmine.org/guide](https://redmine.org/guide) 