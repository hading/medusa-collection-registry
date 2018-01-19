#Note that we now label these in the interface as File Rendering Profiles, but
#we haven't changed the model name, etc.
class FileFormatProfile < ApplicationRecord

  STATUSES = %w(active inactive)
  validates_uniqueness_of :name, allow_blank: false
  validates :status, presence: true, inclusion: STATUSES

  has_many :file_format_profiles_content_types_joins, dependent: :destroy
  has_many :content_types, -> { order 'name asc' }, through: :file_format_profiles_content_types_joins
  has_many :file_format_profiles_logical_extensions_joins, dependent: :destroy
  has_many :logical_extensions, -> {order 'extension asc, description asc'}, through: :file_format_profiles_logical_extensions_joins
  has_many :file_formats_file_format_profiles_joins, dependent: :destroy
  has_many :file_formats, through: :file_formats_file_format_profiles_joins

  default_scope { order(:status, :name) }

  def self.active
    where(status: 'active')
  end

  def create_clone
    self.dup.tap do |clone|
      clone.name = clone.name + ' (new)'
      clone.save!
      clone.content_types = self.content_types
      clone.logical_extensions = self.logical_extensions
    end
  end

  def logical_extensions_string
    logical_extensions.collect {|extension| extension.label}.join(', ')
  end

  def logical_extensions_string=(extensions)
    if extensions.strip.blank?
      self.logical_extensions = []
    else
      self.logical_extensions = extensions.split(',').collect {|ext| LogicalExtension.ensure_extension(ext)}
    end
  end

end
