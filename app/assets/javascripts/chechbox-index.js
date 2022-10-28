$(document).ready(function(){
  $('.select-all-checkbox').on("click", function () {
    var cbxs = $('input[name="object_ids[]"]');
    cbxs.prop("checked", !cbxs.prop("checked"));
  });
  $('.delete-selected').on('click', function () {
    var object_ids = $('input[name="object_ids[]"]:checked')
    var ids = object_ids.map(function (i, e) { return e.value }).toArray();
    var table_name = $(this).val()
    $.ajax({
      url: '/bulk_delete_data',
      type: 'POST',
      data: { ids: ids, table_name: table_name },
      success: function (response) {
        window.location.reload()
      }
    })
  })
})
