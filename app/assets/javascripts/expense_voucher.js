function expenseVoucherUpdate(){
  $("#expense_voucher_amount").val(0.00);
  $(".expense_voucher_total_bill").text(0.00);
  var i;
  for (i = 0; i < $(".expense").length; i++) {
    if(!isNaN(parseFloat($(".expense")[i].value)))
    {
      $("#expense_voucher_amount").val(Number((parseFloat($(".expense")[i].value))+parseFloat($("#expense_voucher_amount").val())).toFixed(2));
      $(".expense_voucher_total_bill").text($("#expense_voucher_amount").val());
    }
  }
  price_in_words($("#expense_voucher_amount").val(), 'price_in_words')
}