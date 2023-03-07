$(document).on("keyup", "#total-field, #received-field, #rebate-own-field", function() {
  var total = $("#total-field").val();
  var rebate = $('#rebate-own-field').val();
  var received = $("#received-field").val();

  var balance = (parseInt(total) + parseInt(rebate) ) - parseInt(received);
  $("#balance-field").val(balance);
});
