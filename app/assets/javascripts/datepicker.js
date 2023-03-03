function initializeDatepicker() {
  $('.datepicker').datetimepicker({
    format: "YYYY-MM-DD"
  });

  setTimeout(function(){
    $(".chosen-select").chosen({
    allow_single_deselect: true,
    width: '100%'
  });
  }, 50);

}

$(document).on('turbolinks:load', function() {
  FontAwesome.dom.i2svg();
  initializeDatepicker();
});

$(document).ready(function() {
  FontAwesome.dom.i2svg();
  initializeDatepicker();
});

$(document).on('turbolinks:before-cache', function() {
  $('.chosen-select').chosen('destroy');
  $('.chosen-container').remove();
});