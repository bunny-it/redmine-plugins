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

module RedmineContacts
  module Patches
    module CustomFieldValuePatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
        end
      end

      module InstanceMethods
        def related_object
          return @related_object if @related_object
          return nil unless custom_field.format.respond_to?(:related_object)

          cv = customized.custom_values.detect { |v| v.custom_field == custom_field }
          cv ||= customized.custom_values.build(custom_field: custom_field)
          @related_object = custom_field.format.related_object(cv)
        end
      end
    end
  end
end

unless CustomFieldValue.included_modules.include?(RedmineContacts::Patches::CustomFieldValuePatch)
  CustomFieldValue.send(:include, RedmineContacts::Patches::CustomFieldValuePatch)
end
