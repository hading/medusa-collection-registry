class FileFormatDecorator < BaseDecorator

  def pronom_links
    object.pronoms.decorate.collect do |pronom|
      pronom.link
    end.join(', ').html_safe
  end

  def extensions_string
    file_format_profiles.all.collect do |file_format_profile|
      file_format_profile.logical_extensions.all.collect {|extension| extension.label}
    end.flatten.uniq.sort.join(', ')
  end

end