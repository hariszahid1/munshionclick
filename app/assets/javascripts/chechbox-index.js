$(document).ready(function(){

  $('.select-all-checkbox').on("click", function () {
    var cbxs = $('input[name="object_ids[]"]');
    cbxs.prop("checked", !cbxs.prop("checked"));
  });

  $('.delete-selected').on('click', function () {
    var object_ids = $('input[name="object_ids[]"]:checked')
    var ids = object_ids.map(function (i, e) { return e.value }).toArray();
    var table_name = $(this).val()
    let text = "Are u sure u want to delete this item?";
    if (object_ids.length > 0){
      if (confirm(text) == true) {
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

})
