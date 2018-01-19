$(document).ready(function () {
  initialize_data_table("table#file_format_profiles", {
      "order" : [[1, "asc"], [0 , "asc"]]
  })
})

$(document).ready(function () {
    $('#file_format_profile_form').on("submit", function (e) {
        if (checked_count('#edit_file_formats_list') > 1) {
            var proceed = confirm("Warning: You are about to make a change to a rendering profile that is attached to multiple file formats. Any changes made will now be reflected in this profile for the following formats. Do you wish to proceed with the selected changes?");
            if (!proceed) {
                e.preventDefault();
                return false;
            }
        }
    })
})

$(document).ready(function () {
  $('.logical-extension').on('click', function(e) {
    update_logical_extensions(this.innerText);
  })
})

function checked_count(selector) {
    return $(selector + " :checked").size();
}

function update_logical_extensions(text) {
  var input = logical_extensions_string_input();
  if (_.string.isBlank(input.val())) {
    input.val(text);
  } else {
    input.val(input.val() + ', ' + text);
  }
}

function logical_extensions_string_input() {
  return $('#file_format_profile_logical_extensions_string');
}