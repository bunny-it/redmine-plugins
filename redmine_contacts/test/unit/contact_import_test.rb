# encoding: utf-8
#
# This file is a part of Redmine CRM (redmine_contacts) plugin,
# customer relationship management plugin for Redmine
#
# Copyright (C) 2010-2025 RedmineUP
# http://www.redmineup.com/
#
# redmine_contacts is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_contacts is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_contacts.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../../test_helper', __FILE__)

class ContactImportTest < ActiveSupport::TestCase
  fixtures :projects, :users, :issues, :issue_statuses, :trackers

  def test_open_correct_csv
    assert_difference('Contact.count', 4, 'Should add 4 contacts in the database') do
      contact_import = generate_import_with_mapping
      assert contact_import.run, 4
    end
  end

  def test_should_report_error_line
    assert_difference('Contact.count', 3, 'Should add 3 contacts in the database') do
      contact_import = generate_import_with_mapping('with_data_malformed.csv')
      assert contact_import.run, 4
      messages = contact_import.items.pluck(:message).compact.map(&:downcase)
      assert messages.include?('first name cannot be blank')
    end
  end

  def test_open_csv_with_custom_fields
    cf1 = ContactCustomField.create!(:name => 'License', :field_format => 'string')
    cf2 = ContactCustomField.create!(:name => 'Purchase date', :field_format => 'date')
    contact_import = generate_import_with_mapping('contacts_cf.csv')
    contact_import.settings['separator'] = ','
    contact_import.settings['date_format'] = '%Y-%m-%d'
    contact_import.mapping.merge!("cf_#{cf1.id}" => '15', "cf_#{cf2.id}" => '16', 'assigned_to' => '17', 'address_zip' => '18', 'address_city' => '19', 'address_country_code' => '20')
    contact_import.run

    assert_equal 1, contact_import.items.count, 'Should find 1 contact in file'
    contact = Contact.find_by_first_name('Monica')
    assert_equal '12345', contact.custom_field_value(cf1.id)
    assert_equal 'rhill', contact.assigned_to.login
    assert_equal '123456', contact.postcode
    assert_equal 'Moscow', contact.city
    assert_equal 'Russia', contact.country
  end

  protected

  def generate_import(fixture_name='correct.csv')
    import = ContactImport.new
    import.user_id = 2
    import.file = Rack::Test::UploadedFile.new(redmine_contacts_fixture_files_path + fixture_name, 'text/csv')
    import.save!
    import
  end

  def generate_import_with_mapping(fixture_name='correct.csv')
    import = generate_import(fixture_name)

    import.settings = {
      'separator' => ';',
      'wrapper' => '"',
      'encoding' => 'UTF-8',
      'date_format' => '%m/%d/%Y',
      'mapping' => {'project_id' => '1', 'first_name' => '2', 'email' => '8', 'birthday' => '12'}
    }
    import.save!
    import
  end
end if Redmine::VERSION.to_s >= '4.1'
