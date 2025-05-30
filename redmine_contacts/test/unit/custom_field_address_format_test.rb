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

class CustomFieldAddressFormatTest < ActiveSupport::TestCase
  fixtures :custom_fields, :projects, :members, :users, :member_roles, :issue_statuses, :trackers, :issues

  RedmineContacts::TestCase.create_fixtures(
    Redmine::Plugin.find(:redmine_contacts).directory + '/test/fixtures/',
    [:addresses]
  )

  def setup
    RedmineContacts::TestCase.prepare
    @custom_field = IssueCustomField.create!(
      name: 'Address',
      field_format: 'address',
      project_ids: [1],
      tracker_ids: [1]
    )
    @address_params = {'address' => {
      'street1' => 'Street1',
      'street2' => 'Street2',
      'city' => 'Moscow',
      'region' => 'Moscow',
      'postcode' => '110022',
      'country_code' => 'RU'
    }}
    @new_address_params = {'address' => {
      'street1' => 'New 1',
      'street2' => 'New 2',
      'city' => 'New city',
      'postcode' => '000000',
      'region' => 'Moscow',
      'country_code' => 'RU'
    }}
    @address = Address.create!(@address_params['address'])
    @custom_value = Issue.find(1).custom_values.create(custom_field: @custom_field, address: @address, value: @address.to_s)
    @issue_with_address = Issue.find(1)
  end

  def test_possible_values_options_with_no_arguments
    assert_equal [], @custom_field.possible_values_options
    assert_equal [], @custom_field.possible_values_options(nil)
  end

  def test_possible_values_options_with_project_resource
    project = Project.find(1)
    possible_values_options = @custom_field.possible_values_options(project.issues.first)
    assert possible_values_options.blank?
    assert_equal [], possible_values_options
  end

  def test_cast_single_value_as_string
    assert_kind_of String, @custom_field.format.cast_single_value(@custom_field, '1')
    assert_equal '1', @custom_field.format.cast_single_value(@custom_field, '1')
  end

  def test_should_set_custom_field_value_with_address_params
    custom_field_value = @issue_with_address.custom_field_values.detect { |custom_field_value| custom_field_value.custom_field_id == @custom_field.id }
    value = @custom_field.format.set_custom_field_value(@custom_field, custom_field_value, @new_address_params)
    address_string = Address.new(@new_address_params['address']).to_s

    assert_kind_of String, value
    assert_equal address_string, value
  end

  def test_cast_blank_value
    assert_nil @custom_field.cast_value(nil)
    assert_nil @custom_field.cast_value('')
  end

  def test_cast_valid_value
    address_id = @custom_field.cast_value(@address.id)
    assert_kind_of String, address_id
    assert_equal Address.find(@address.id).id.to_s, address_id
  end
end
