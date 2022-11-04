$(document).on('ready turbolinks:load', function() {
  $('.bulk-import-form').removeAttr('novalidate')
  $('.sidebar-toggle-icon').on('click', function(){
    $('#sidebar').toggleClass('active');
    $('#sidebar-container').toggleClass('col-2')
    $('#content').toggleClass('col-11')
    $('#sidebar').toggleClass('col-2')
  })

  $('.sidebar-toggle-icon-mobile').on('click', function(){
    $('#sidebar-container').toggleClass('d-none')
    $('#sidebar-container').removeClass('col-2')
    $('#sidebar-container').removeClass('col-1')
    $('#content').removeClass('col-10')
  })
})
