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

class ImportsControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries

  RedmineContacts::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts).directory + '/test/fixtures/', [:contacts,
                                                                                                                    :contacts_projects,
                                                                                                                    :deals,
                                                                                                                    :deal_statuses,
                                                                                                                    :notes,
                                                                                                                    :tags,
                                                                                                                    :taggings,
                                                                                                                    :queries])

  def setup
    RedmineContacts::TestCase.prepare
    User.current = nil
    @request.session[:user_id] = 1
    @deal_csv_file = Rack::Test::UploadedFile.new(redmine_contacts_fixture_files_path + 'deals_correct.csv', 'text/csv')
    @contact_csv_file = Rack::Test::UploadedFile.new(redmine_contacts_fixture_files_path + 'contacts_cf.csv', 'text/csv')
  end

  def teardown
    Import.destroy_all
  end

  # Deal Import Tests

  test 'should open deal import form' do
    compatible_request :get, :new, type: 'DealImport', project_id: 1
    assert_response :success
    assert_select 'form input#file'
  end

  test 'should create new deal import object' do
    compatible_request :get, :create, type: 'DealImport', project_id: 1, file: @deal_csv_file
    assert_response :redirect
    assert_equal Import.last.class, DealImport
    assert_equal Import.last.user, User.find(1)
    assert_equal Import.last.project.id, 1

    import_settings = Import.last.settings
    project_id = import_settings['mapping']['project_id']
    wrapper, date_format = import_settings['wrapper'], import_settings['date_format']
    expected_settings = { 'project_id' => project_id, 'wrapper' => wrapper, 'date_format' => date_format }

    assert_equal expected_settings, { 'project_id' => 1, 'wrapper' => "\"", 'date_format' => '%m/%d/%Y' }
    assert %w[; ,].include?(Import.last.settings['separator'])
    assert %w[ISO-8859-1 UTF-8].include?(Import.last.settings['encoding'])
  end

  test 'should open deal import settings page' do
    import = DealImport.new
    import.user = User.find(1)
    import.settings['mapping'] = { 'project_id' => 1 }
    import.file = @deal_csv_file
    import.save!
    compatible_request :get, :settings, id: import.filename
    assert_response :success
    assert_select 'form#import-form'
  end

  test 'should show deal import mapping page' do
    import = DealImport.new
    import.user = User.find(1)
    import.settings = { 'mapping' => {'project_id' => 1},
                        'separator' => ';',
                        'wrapper' => "\"",
                        'encoding' => 'UTF-8',
                        'date_format' => '%m/%d/%Y' }
    import.file = @deal_csv_file
    import.save!
    compatible_request :get, :mapping, :id => import.filename
    assert_response :success
    assert_select "select[name='import_settings[mapping][name]']"
    assert_select 'select[name="import_settings[mapping][currency]"]'
    assert_select 'table.sample-data tr'
    assert_select 'table.sample-data tr td', 'Сделка века'
    assert_select 'table.sample-data tr td', 'Кемска волость'
  end

  test 'should successfully deal import from CSV with new import' do
    cf = DealCustomField.create!(:name => 'LIST_FIELD', :field_format => 'list', :multiple => true, :possible_values => %w(1 2 3))
    import = DealImport.new
    import.user = User.find(1)
    import.settings = { 'mapping' => {'project_id' => 1},
                        'separator' => ';',
                        'wrapper' => "\"",
                        'encoding' => 'UTF-8',
                        'date_format' => '%m/%d/%Y' }
    import.file = @deal_csv_file
    import.save!
    compatible_request :post, :mapping, id: import.filename, :import_settings => { :mapping => { :project_id =>1, :name => 1, :background => 2, :contact => 8, "cf_#{cf.id}" => 12 } }
    assert_response :redirect
    compatible_request :post, :run, id: import.filename, format: :js
    deal = Deal.last
    assert_equal deal.name, 'Сделка века'
    assert_equal deal.background, 'Кемска волость'
    assert_equal deal.contact.primary_email, 'marat@mail.ru'
    assert_equal deal.custom_field_value(cf).sort, ['1', '3']
  end

  # Contact Import Tests

  test 'should open contact import form' do
    compatible_request :get, :new, type: 'ContactImport', project_id: 1
    assert_response :success
    assert_select 'form input#file'
  end

  test 'should create new contact import object' do
    compatible_request :get, :create, type: 'ContactImport', project_id: 1, file: @contact_csv_file
    assert_response :redirect
    assert_equal Import.last.class, ContactImport
    assert_equal Import.last.user, User.find(1)
    assert_equal Import.last.project.id, 1

    import_settings = Import.last.settings
    project_id = import_settings['mapping']['project_id']
    wrapper, date_format = import_settings['wrapper'], import_settings['date_format']
    expected_settings = { 'project_id' => project_id, 'wrapper' => wrapper, 'date_format' => date_format }

    assert_equal expected_settings, { 'project_id' => 1, 'wrapper' => "\"", 'date_format' => '%m/%d/%Y' }
    assert %w[; ,].include?(Import.last.settings['separator'])
    assert %w[ISO-8859-1 UTF-8].include?(Import.last.settings['encoding'])
  end

  test 'should open contact import settings page' do
    import = ContactImport.new
    import.user = User.find(1)
    import.settings['mapping'] = { 'project_id' => 1 }
    import.file = @contact_csv_file
    import.save!
    compatible_request :get, :settings, :id => import.filename
    assert_response :success
    assert_select 'form#import-form'
  end

  test 'should show contact import mapping page' do
    import = ContactImport.new
    import.user = User.find(1)
    import.settings = { 'mapping' => {'project_id' => 1},
                        'separator' => ',',
                        'wrapper' => "\"",
                        'encoding' => 'UTF-8',
                        'date_format' => '%m/%d/%Y' }
    import.file = @contact_csv_file
    import.save!
    compatible_request :get, :mapping, id: import.filename
    assert_response :success
    assert_select "select[name='import_settings[mapping][is_company]']"
    assert_select 'select[name="import_settings[mapping][first_name]"]'
    assert_select 'table.sample-data tr'
    assert_select 'table.sample-data tr td', 'Monica'
    assert_select 'table.sample-data tr td', 'ivan@mail.com'
  end

  test 'should successfully contact import from CSV with new import' do
    cf = ContactCustomField.create!(name: 'LIST_FIELD', field_format: 'list', multiple: true, possible_values: %w(1 2 3))
    import = ContactImport.new
    import.user = User.find(1)
    import.settings = { 'mapping' => {'project_id' => 1},
                        'separator' => ',',
                        'wrapper' => "\"",
                        'encoding' => 'UTF-8',
                        'date_format' => '%m/%d/%Y' }
    import.file = @contact_csv_file
    import.save!
    compatible_request :post, :mapping, id: import.filename,
                        import_settings: { mapping: { :project_id =>1, :first_name => 2, :email => 8, "cf_#{cf.id}" => 21 } }
    assert_response :redirect
    compatible_request :post, :run, :id => import.filename, format: :js
    assert_equal Contact.last.first_name, 'Monica'
    assert_equal Contact.last.email, 'ivan@mail.com'
    assert_equal Contact.last.custom_field_value(cf).sort, ['1', '3']
  end
end if Redmine::VERSION.to_s >= '4.1'
