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

class DealImport < Import
  AUTO_MAPPABLE_FIELDS = {
    'name' => 'field_name',
    'background' => 'field_background',
    'currency' => 'field_currency',
    'price' => 'field_price',
    'price_type' => 'field_price_type',
    'duration' => 'field_duration',
    'probability' => 'field_probability',
    'due_date' => 'field_due_date',
    'contact_id' => 'field_contact',
    'category_id' => 'field_category',
    'status_id' => 'field_status',
    'author_id' => 'field_author',
    'assigned_to_id' => 'field_assigned_to'
  }
  
  def self.menu_item
    :deals
  end

  def self.authorized?(user)
    user.allowed_to?(:import_deals, nil, :global => true)
  end

  def saved_objects
    object_ids = saved_items.pluck(:obj_id)
    Deal.where(:id => object_ids).order(:id)
  end

  def project
    Project.find_by_id(mapping['project_id'].to_i)
  end

  def allowed_target_projects
    Project.allowed_to(user, :import_deals)
  end

  def mappable_custom_fields
    DealCustomField.all
  end

  private

  def build_object(row, _item = nil)
    deal = Deal.new
    deal.project = project
    deal.author = user

    attributes = {}
    if name = row_value(row, 'name')
      attributes['name'] = name
    end
    if background = row_value(row, 'background')
      attributes['background'] = background
    end
    if currency = row_value(row, 'currency')
      attributes['currency'] = currency
    end
    if price = row_value(row, 'price')
      attributes['price'] = price.to_f
    end
    if probability = row_value(row, 'probability')
      attributes['probability'] = probability.to_i
    end
    if status = row_value(row, 'status')
      attributes['status_id'] = DealStatus.where('name = ?', status).first.try(:id)
    end
    if contact = row_value(row, 'contact')
      attributes['contact_id'] = Contact.where("email LIKE ?", "#{contact.strip}%").first.try(:id)
    end
    if assigned_to = row_value(row, 'assigned_to')
      attributes['assigned_to_id'] = User.where("LOWER(CONCAT(#{User.table_name}.firstname,' ',#{User.table_name}.lastname)) = ? ", assigned_to.mb_chars.downcase.to_s)
                                         .first
                                         .try(:id)
    end
    if category = row_value(row, 'category')
      attributes['category_id'] =  DealCategory.where(:name => category).first.try(:id)
    end

    attributes['custom_field_values'] = deal.custom_field_values.inject({}) do |h, v|
      value = case v.custom_field.field_format
              when 'date'
                row_date(row, "cf_#{v.custom_field.id}")
              when 'list'
                row_value(row, "cf_#{v.custom_field.id}").try(:split, ',')
              else
                row_value(row, "cf_#{v.custom_field.id}")
              end
      if value
        h[v.custom_field.id.to_s] =
          if value.is_a?(Array)
            value.map { |val| v.custom_field.value_from_keyword(val.strip, contact) }.compact.flatten
          else
            v.custom_field.value_from_keyword(value, contact)
          end
      end
      h
    end

    deal.send :safe_attributes=, attributes, user
    deal
  end
end
