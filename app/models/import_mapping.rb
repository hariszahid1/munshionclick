class ImportMapping < ApplicationRecord
  validates_uniqueness_of :table_name
end
