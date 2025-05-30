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

class IssuesControllerTest < ActionController::TestCase
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
                                                                                                                    :notes,
                                                                                                                    :tags,
                                                                                                                    :taggings,
                                                                                                                    :queries,
                                                                                                                    :addresses])

  def setup
    RedmineContacts::TestCase.prepare
    User.current = nil
    @request.session[:user_id] = 1

    issue = Issue.find(1)
    contact = Contact.find(2)
    deal = Deal.find(1)
    @address_params = {'address' => {
      'street1' => 'Street1',
      'street2' => 'Street2',
      'city' => 'Moscow',
      'region' => 'Moscow',
      'postcode' => '110022',
      'country_code' => 'RU'
    }}

    # Warning: test_helper already creates some custom fields and custom values
    @contact_cf = IssueCustomField.create!(name: 'Related contacts',
                                           field_format: 'contact',
                                           is_filter: true,
                                           is_for_all: true,
                                           multiple: true,
                                           tracker_ids: Tracker.pluck(:id))
    @deal_cf = IssueCustomField.create!(name: 'Related deals',
                                        field_format: 'deal',
                                        is_filter: true,
                                        is_for_all: true,
                                        multiple: true,
                                        tracker_ids: Tracker.pluck(:id))
    @address_cf = issue.custom_field_values.select { |cf| cf.custom_field.field_format == 'address' }.first.custom_field

    CustomValue.create!(custom_field: @contact_cf, customized: issue, value: contact.id)
    CustomValue.create!(custom_field: @deal_cf, customized: issue, value: deal.id)
  end
  def test_get_index_with_contacts_and_deals_and_address
    compatible_request :get, :index, :f => ['status_id', "cf_#{@contact_cf.id}", ''],
                                     :op => { :status_id => 'o', "cf_#{@contact_cf.id}" => '=' },
                                     :v => { "cf_#{@contact_cf.id}" => ['2'] },
                                     :c => ['subject', "cf_#{@contact_cf.id}", "cf_#{@deal_cf.id}", "cf_#{@address_cf.id}"],
                                     :project_id => 'ecookbook'
    assert_response :success
    assert_select 'table.list.issues td.contact span.contact a', /Marat Aminov/
    assert_select 'table.list.issues td.deal a', /First deal with contacts/
    assert_select 'table.list.issues td.address', /Avenida Silva Melo 1287/
  end

  def test_get_index_with_address_and_contains_filter
    compatible_request :get, :index, :f => ['status_id', "cf_#{@address_cf.id}", ''],
                       :op => { :status_id => '*', "cf_#{@address_cf.id}" => '~' },
                       :v => { "cf_#{@address_cf.id}" => ['Silva'] },
                       :c => ['subject', "cf_#{@address_cf.id}"],
                       :project_id => 'ecookbook'
    assert_response :success
    assert_select 'table.list.issues td.address', { count: 1, text: /Avenida Silva/}
  end

  def test_get_issues_without_contacts
    compatible_request :get, :index, :f => ['status_id', "cf_#{@contact_cf.id}", ''],
                                     :op => { :status_id => '*', "cf_#{@contact_cf.id}" => '!*' },
                                     :c => ['subject', "cf_#{@contact_cf.id}"],
                                     :project_id => 'ecookbook'
    assert_response :success
    assert_select 'table.list.issues td.contact', ''
  end

  def test_get_issues_with_none_addresses
    compatible_request :get, :index, :f => ['status_id', "cf_#{@address_cf.id}", ''],
                       :op => { :status_id => '*', "cf_#{@address_cf.id}" => '!*' },
                       :c => ['subject', "cf_#{@address_cf.id}"],
                       :project_id => 'ecookbook'
    assert_response :success
    assert_select 'table.list.issues td.address', ''
  end

  def test_get_issues_only_with_contacts
    compatible_request :get, :index, :f => ['status_id', "cf_#{@contact_cf.id}", ''],
                                     :op => { :status_id => '*', "cf_#{@contact_cf.id}" => '*' },
                                     :c => ['subject', "cf_#{@contact_cf.id}"],
                                     :project_id => 'ecookbook'
    assert_response :success
    assert_select 'table.list.issues td.contact'
  end

  def test_get_issues_only_with_any_addresses
    compatible_request :get, :index, :set_filter => 1,
                                     :f => ['status_id', "cf_#{@address_cf.id}", ''],
                                     :op => { :status_id => '*', "cf_#{@address_cf.id}" => '*' },
                                     :c => ['subject', "cf_#{@address_cf.id}"],
                                     :project_id => 'ecookbook'
    assert_response :success
    assert_select 'table.list.issues td.address', { count: 2, text: /.+/ }
  end

  def test_issue_with_filled_contacts_and_deals_and_addresses
    issue = Issue.find(1)

    compatible_request :get, :show, id: issue.id
    assert_response :success

    # Check attributes view
    assert_select ".cf_#{@deal_cf.id}", /First deal with contacts/
    assert_select ".cf_#{@contact_cf.id}", /Marat Aminov/
    assert_select ".cf_#{@address_cf.id}", /Rua Henrique/

    # Check form fields
    assert_select "#update #issue_custom_field_values_#{@deal_cf.id} option[selected]", /First deal with contacts/
    assert_select "#update #issue_custom_field_values_#{@contact_cf.id} option[selected]", /Marat Aminov/

    assert_select "#update span.custom-field-address-wrapper" do
      assert_select "input", { count: 5 }
      assert_select "select", { count: 1 }
    end
  end

  def test_new_issue_should_be_created_with_address_cf
    new_issue_params = {
      issue: {
        subject: 'Test issue with address',
        project_id: 1,
        tracker_id: 1,
        status_id: 1,
        priority_id: 4,
        custom_field_values: {
          @address_cf.id => @address_params
        }
      }
    }
    custom_fields_count = CustomField.where(type: 'IssueCustomField').count

    assert_difference 'Issue.count' do
      assert_difference 'CustomValue.count', custom_fields_count do
        assert_difference 'Address.count' do
          assert_no_difference 'Journal.count' do
            compatible_request :post, :create, new_issue_params
          end
        end
      end
    end
    assert_equal Issue.last.custom_field_value(@address_cf.id) , Address.new(@address_params['address']).to_s
  end

  def test_issue_should_be_updated_with_address_cf
    issue = Issue.find(1)
    assert_no_difference 'Address.count' do
      assert_difference 'Journal.count' do
        compatible_request :put, :update, id: issue.id, issue: { custom_field_values: { @address_cf.id => @address_params } }
      end
    end
    assert_response :redirect
    updated_address = Address.find(3)

    assert_equal 'Street1', updated_address.street1
    assert_equal 'Street2', updated_address.street2
    assert_equal 'Moscow', updated_address.city
    assert_equal 'Moscow', updated_address.region
    assert_equal '110022', updated_address.postcode
    assert_equal 'RU', updated_address.country_code
    assert_equal 'Street1, Street2, Moscow, 110022, Moscow, Russia', updated_address.full_address
  end

  def test_issue_should_be_updated_with_new_address_cf
    issue = create_issue
    address_custom_field = create_address_cf

    assert_difference 'Address.count' do
      assert_difference 'Journal.count' do
        compatible_request :put, :update, id: issue.id, issue: { custom_field_values: { address_custom_field.id => @address_params } }
      end
    end
    assert_response :redirect

    updated_address = issue.reload.custom_field_values.select { |cf| cf.custom_field.field_format == 'address' }.last.related_object

    assert_equal 'Street1', updated_address.street1
    assert_equal 'Street2', updated_address.street2
    assert_equal 'Moscow', updated_address.city
    assert_equal 'Moscow', updated_address.region
    assert_equal '110022', updated_address.postcode
    assert_equal 'RU', updated_address.country_code
    assert_equal 'Street1, Street2, Moscow, 110022, Moscow, Russia', updated_address.full_address
  end

  def test_issue_should_be_saved_with_history_about_change_address_cf
    issue = Issue.find(1)
    old_address = Address.find(3)
    assert_no_difference 'Address.count' do
      assert_difference 'Journal.count' do
        compatible_request :put, :update, id: issue.id, issue: { custom_field_values: { @address_cf.id => @address_params } }
      end
    end
    assert_response :redirect
    new_address = Address.find(3)

    compatible_request :get, :show, id: issue.id
    assert_response :success

    journal_id = issue.journals.last.id
    journal_text = "Test related addresses changed from #{old_address.full_address} to" \
      " #{new_address.full_address}"

    assert_select "div#change-#{journal_id} ul.details li", text: journal_text
  end

  private

  def create_address_cf
    address_cf = CustomField.new_subclass_instance('IssueCustomField')
    address_cf.name = 'Addresses cf'
    address_cf.field_format = 'address'
    address_cf.is_for_all = true

    address_cf.tracker_ids = Tracker.pluck(:id)
    address_cf.save!
    address_cf
  end

  def create_issue
    Issue.create!(
      subject: 'New issue address',
      project_id: 1,
      tracker_id: 1,
      status_id: 1,
      priority_id: 4,
      author_id: 1
    )
  end
end
