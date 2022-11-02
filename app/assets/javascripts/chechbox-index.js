document.addEventListener("turbolinks:load", function() {
  $('.select-all-checkbox').on("click", function () {
    var cbxs = $('input[name="object_ids[]"]');
    if($(this).is(":checked")){
      cbxs.prop("checked", true);
    }
    else{
      cbxs.prop("checked", false);
    }
  });

  $('.delete-selected').on('click', function () {
    var object_ids = $('input[name="object_ids[]"]:checked')
    var ids = object_ids.map(function (i, e) { return e.value }).toArray();
    var table_name = $(this).val()
    var text_data = "Are u sure u want to delete this item?";
    if (object_ids.length > 0){
      if (confirm(text_data) == true) {
        $.ajax({
          url: '/bulk_delete_data',
          type: 'POST',
          data: { ids: ids, table_name: table_name },
          success: function (response) {
            $('input[name="object_ids[]"]:checked').closest('tr').addClass('d-none')
            $('.custom-alert-text').text(response.message)
            $('#custom-alert').removeClass('d-none')
          }
        })
      }
    }
    else{
      $('.custom-alert-text').text('Please select some record first.')
      $('#custom-alert').removeClass('d-none')
    }
  })

  $(".email-fields").keydown(function (e) {
    if (e.keyCode == 13){
      e.preventDefault();
      $('.email-send-btn').click();
    }
  });

})
