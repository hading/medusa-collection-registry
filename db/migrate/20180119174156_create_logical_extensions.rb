#Note this also creates the join table and migrates some information from the FileFormatProfile/FileExtension
# relationship
class CreateLogicalExtensions < ActiveRecord::Migration[5.1]
  def change
    create_table :logical_extensions do |t|
      t.string :extension, null: :false
      t.string :description, default: '', null: :false
    end
    add_index :logical_extensions, [:extension, :description], unique: true

    create_table :file_format_profiles_logical_extensions_joins do |t|
      t.references :file_format_profile, index: false
      t.references :logical_extension, index: false
      t.timestamps null: false
    end
    add_index :file_format_profiles_logical_extensions_joins, :file_format_profile_id, name: :ffplej_file_format_profile_id_idx
    add_index :file_format_profiles_logical_extensions_joins, :logical_extension_id, name: :ffplej_logical_extension_id_idx

    FileFormatProfilesFileExtensionsJoin.all.each do |join|
      file_extension = join.file_extension
      logical_extension = LogicalExtension.find_or_create_by(extension: file_extension.extension.strip, description: '')
      FileFormatProfilesLogicalExtensionsJoin.create(file_format_profile: join.file_format_profile, logical_extension: logical_extension)
    end

  end
end
