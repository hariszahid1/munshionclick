$(document).on("keyup", "#discount, #total, #received", function() {
  var received = $("#received").val();
  var total = $("#total").val();

  var balance = parseInt(total) - parseInt(received);
  $("#balance").val(balance);
});