module FileFormatsHelper

  def file_format_extensions_string(file_format)
    file_format.file_format_profiles.all.collect do |file_format_profile|
      file_format_profile.logical_extensions.all.collect {|extension| extension.label}
    end.flatten.uniq.sort.join(', ')
  end

end