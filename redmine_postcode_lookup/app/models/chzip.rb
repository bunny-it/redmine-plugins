class Chzip < ApplicationRecord
  self.table_name = 'chzip'
  validates :zip, presence: true, uniqueness: true
  validates :cty, :reg, presence: true
end