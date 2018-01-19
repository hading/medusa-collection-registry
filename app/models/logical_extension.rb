class LogicalExtension < ApplicationRecord

  has_many :file_format_profiles_logical_extensions_joins, dependent: :destroy
  has_many :file_format_profiles, through: :file_format_profiles_logical_extensions_joins

  validates_uniqueness_of :description, scope: :extension
  validates_presence_of :extension

end