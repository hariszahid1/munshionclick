$( document ).ready(function() {
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

  $(document).on('keyup', '.challan-no-value', function () {
    var party_id = $('.inward-party-name').val()
    var product_id = $(this).closest('.challan-stock-container').find('.inward-product').val()
    var marka_no = $(this).closest('.challan-stock-container').find('.inward-marka').val()
    var challan_no = $(this).val()

    $.ajax({
      url: '/order_inwards/check_duplicate_challan',
      type: 'GET',
      data: { challan_no: challan_no, marka_no: marka_no, product_id: product_id, party_id: party_id },
      dataType: 'script',
      success: function (result) {
        var result_data = JSON.parse(result).toString()
        if (result_data.length > 0)
        {
          window.alert("Same challan already present!");
        }
     },
     error: function (){
     }
    });

    if($(this).val().includes('/')){
      value_for_stocks = $(this).val().split('/')[1].split('(')[0]
      $(this).closest('.challan-stock-container').find('.stock-value').val(value_for_stocks)
    }
    else{
      $(this).closest('.challan-stock-container').find('.stock-value').val(0)
    }
  })

})

// Preloader JS
$(window).on('turbolinks:load', function () {
  $('.preloader').fadeOut();
});

$(window).on('document:load', function () {
  $('.cover-spin').addClass('d-none')
});

$(document).on('turbolinks:click', function () {
  $('.cover-spin').removeClass('d-none')
});

$(document).on('turbolinks:load', function () {
  $('.cover-spin').addClass('d-none')
});

// $(document).on('turbolinks:render', function () {
//   $('.cover-spin, .loading').addClass('d-none')
// });
