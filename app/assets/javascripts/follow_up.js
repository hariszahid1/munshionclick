$(document).ready(function(){
    $(".notification-read").click(function(){
      var element = $(this)
      $.ajax({
        type: "post",
        url: `/notification`,
        data: {'follow_up_id': $(element).val(), read: true},
        success: function (result) {
          jQuery(element.closest('.text-decoration-none')).detach().prependTo('#read')
          element.addClass('d-none')
        },
        error: function (error){
          console.error(error)
        }
      });
    })
})


$(document).ready(function(){
  $(".notification-complete").click(function(){
    var element = $(this)
    $.ajax({
      type: "post",
      url: `/notification`,
      data: {'follow_up_id': $(element).val(), complete: true},
      success: function (result) {
        jQuery(element.closest('.text-decoration-none')).detach().prependTo('#completed')
        element.addClass('d-none')
      },
      error: function (error){
        console.error(error)
      }
    });
  })
})
