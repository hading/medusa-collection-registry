class FileExtension < ApplicationRecord
  include RandomCfsFile

  validates_uniqueness_of :extension, allow_nil: false
  validates_numericality_of :cfs_file_count, :cfs_file_size
  has_many :cfs_files

  def self.ensure_for_name(filename)
    self.find_or_create_by(extension: self.normalized_extension(filename))
  end

  def self.normalized_extension(filename)
    File.extname(filename).sub(/^\./, '').downcase
  end

  def extension_label
    self.extension.if_blank('<no extension>')
  end

  def self.prune_empty
    where(cfs_file_count: 0).each do |file_extension|
      file_extension.destroy!
    end
  end

  def active_logical_profiles
    LogicalExtension.where(extension: extension).all.collect do |logical_extension|
      logical_extension.file_format_profiles.active.to_a
    end.flatten
  end

end
