$(document).on("keyup", "#discount, #total, #received", function() {
  debugger;
  var discount = $("#discount").val();
  var received = $("#received").val();
  var total = $("#total").val();

  var balance = parseInt(total) - parseInt(received) - parseInt(discount);
  $("#balance").val(balance);
});