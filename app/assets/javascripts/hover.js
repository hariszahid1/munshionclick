$(document).ready(function() {
  $('form').on('focus', 'input[type=number]', function (e) {
    $(this).on('wheel.disableScroll', function (e) {
      e.preventDefault()
    })
  })
  $('form').on('blur', 'input[type=number]', function (e) {
    $(this).off('wheel.disableScroll')
  })

  $('select#available_mapping_id').on('change', function () {
    var mapping_id = this.value;
    $.ajax({
      type: 'GET',
      contentType: 'application/json; charset=utf-8',
      url: '/map_columns/' + mapping_id,
      dataType: 'json',
      success: function(result) {
        $('#mapping_column_for_update').val(result.mapping_column);
      }
    })
  })

  $('button#update_mapping').on('click', function () {
    var mapping_id = $('select#available_mapping_id').val();
    if (mapping_id) {
      var mapping_column = $('#mapping_column_for_update').val();
      if (window.confirm('Do you want to update column mapping.')) {
        $.ajax({
          url: '/map_columns/' + mapping_id,
          type: 'PATCH',
          data: {
            map_column: {
              mapping_column: mapping_column
            }
          },
          dataType: 'html',
          success: function(result) {
            $('div#js-msg').append("<div id='notice' class='alert alert success border-success'>"+ result +"<button type='button' class='close' data-dismiss='alert' aria-label='Close><span aria-hidden='true'>×</span></button></div>")
          }
        })
      }
    } else {
      window.alert('Please select any column.');
    }
  })
});
