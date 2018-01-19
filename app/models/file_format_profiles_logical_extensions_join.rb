class FileFormatProfilesLogicalExtensionsJoin < ApplicationRecord

  belongs_to :file_format_profile
  belongs_to :logical_extension

end

