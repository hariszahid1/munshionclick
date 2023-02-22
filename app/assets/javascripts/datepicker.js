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
  initializeDatepicker();
});

$(document).ready(function() {
  initializeDatepicker();
});