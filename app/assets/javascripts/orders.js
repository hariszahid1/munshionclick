 // Place all the behaviors and hooks related to the matching controller here.
//  All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/
var costUpdateReturnOrder, remaingUpdateAmountOrder, set_sale_order;

costUpdateReturnOrder = function() {
  var carriage, cost_price, detail_discount_price, discount_price, i, loading, pack_price, quantity_price, total_bill;
  carriage = $('#order_carriage').val() !== '' ? parseFloat($('#order_carriage').val()) : 0;
  loading = $('#order_loading').val() !== '' ? parseFloat($('#order_loading').val()) : 0;
  $('#order_total_bill').val(Number(carriage + loading).toFixed(2));
  $('.purchase_sale_detail_total_bill').text($('#order_total_bill').val());
  i = void 0;
  i = 0;
  gst_amount = 0;
  gst = 0;
  with_carriage = 0;
  sale_price_entry = 0;

  while (i < $('.cost-price').length) {
    if ($('#' + $('.quantity-price')[i].id).parent().parent().parent().css('display') !== 'none' && !isNaN(parseFloat($('.cost-price')[i].value)) && !isNaN(parseFloat($('.quantity-price')[i].value)) && !isNaN(parseFloat($('#order_total_bill').val()))) {
      if($('.marla')[i])
      {
        marla = $('.marla')[i].value !== '' ? parseFloat($('.marla')[i].value) : 0;
        square_feet = $('.square_feet')[i].value !== '' ? parseFloat($('.square_feet')[i].value) : 0;
        if(marla>0 || square_feet>0)
        {
          area_in_marla = (parseFloat(marla)+(parseFloat(square_feet)/225));
          cost_price = parseFloat($('.cost-price')[0].value);
          total_price = (cost_price*area_in_marla).toFixed(2);
          $('.quantity-price')[i].value = area_in_marla;
          $('#order_property_plans_attributes_0_area_in_marla').val(area_in_marla);
          $('#order_property_plans_attributes_0_price_per_marla').val(parseFloat($('.cost-price')[0].value));
          $('#order_property_plans_attributes_0_total_price_diabled').val(total_price);
          $('#order_property_plans_attributes_0_total_price').val(total_price)
        }
      }
      pack_price = 1;
      quantity_price = parseFloat($('.quantity-price')[i].value);
      cost_price = parseFloat($('.cost-price')[i].value);
      total_bill = parseFloat($('#order_total_bill').val());
      discount_price = parseFloat($('.discount-price')[i].value);
      if ($(".gst-total")[i]!=undefined)
      {
        gst=parseFloat($(".gst-per")[i].value);
        $(".gst-total")[i].value=Number((Number(cost_price*(quantity_price*pack_price)).toFixed(2)/100)*gst ).toFixed(2);
        gst_amount=parseFloat($(".gst-total")[i].value);
      }

      // detail_discount_price = parseFloat($('#order_discount_price').val());
      // $('#order_discount_price').val(discount_price + detail_discount_price);
      sale_price_entry += Number(cost_price * quantity_price * pack_price)
      $('#order_total_bill').val(Number(cost_price * quantity_price * pack_price + total_bill + gst_amount).toFixed(2));
      $('.purchase_sale_detail_total_bill').text($('#order_total_bill').val());
      $('.total-cost-price')[i].value = Number(cost_price * quantity_price * pack_price).toFixed(2);
      with_carriage += Number($('.total-cost-price')[i].value*Number($('#order_extra_charges').val()));
      $('#total_price').val(Number(cost_price * quantity_price * pack_price + $('#order_total_bill').val()).toFixed(2));
    }
    i++;
  }

  i = 0;
  while (i < $('.cost-price-return').length) {
    if ($('#' + $('.quantity-price-return')[i].id).parent().parent().parent().css('display') !== 'none' && !isNaN(parseFloat($('.cost-price-return')[i].value)) && !isNaN(parseFloat($('.quantity-price-return')[i].value)) && !isNaN(parseFloat($('#order_total_bill').val()))) {
      pack_price = 1;
      quantity_price = parseFloat($('.quantity-price-return')[i].value);
      cost_price = parseFloat($('.cost-price-return')[i].value);
      total_bill = parseFloat($('#order_total_bill').val());
      discount_price = parseFloat($('.discount-price-return')[i].value);
      // detail_discount_price = parseFloat($('#order_discount_price').val());
      // $('#order_discount_price').val(Number(discount_price + detail_discount_price).toFixed(2));
      $('#order_total_bill').val(Number(total_bill - (cost_price * quantity_price * pack_price)).toFixed(2));
      $('.purchase_sale_detail_total_bill').text($('#order_total_bill').val());
      $('.total-cost-price-return')[i].value = Number(cost_price * quantity_price * pack_price).toFixed(2);
      $('#total_price').val(Number(cost_price * quantity_price * pack_price + $('#order_total_bill').val()).toFixed(2));
    }
    i++;
  }
  $('#order_carriage').val(with_carriage);
  $('#order_total_bill').val(Number(with_carriage + sale_price_entry).toFixed(2));
  $('.purchase_sale_detail_total_bill').text($('#order_total_bill').val());
  remaingUpdateAmountOrder();
};

remaingUpdateAmountOrder = function() {
  var discount_amount, discount_price, final_discount_amount, total_amount, total_bill;
  total_bill = $('#order_total_bill').val() !== '' ? vaToFloat($('#order_total_bill').val()) : 0;
  discount_price = $('#order_discount_price').val() !== '' ? vaToFloat($('#order_discount_price').val()) : 0;
  discount_amount = $('.purchase_sale_discount_amount').text() !== '' && $('.purchase_sale_discount_amount').text() !== 'NaN' ? vaToFloat($('.purchase_sale_discount_amount').text()) : 0;
  final_discount_amount = vaToFloat(total_bill - discount_price);
  $('.purchase_sale_discount_amount').text(final_discount_amount);
  total_amount = $('#order_amount').val() !== '' ? vaToFloat($('#order_amount').val()) : 0;
  $('.purchase_sale_detail_amount').text(vaToFloat(final_discount_amount - total_amount));
};

set_sale_order = function(value, id) {
  $.ajax({
    type: 'GET',
    contentType: 'application/json; charset=utf-8',
    url: '/products/get_product_data',
    data: {
      product_id: value
    },
    dataType: 'json',
    success: function(result) {
      $('#order_order_items_attributes_' + id.split('order_order_items_attributes_')[1].split('_product_id')[0] + '_sale_price').val(result.sale);
      $('#order_order_items_attributes_' + id.split('order_order_items_attributes_')[1].split('_product_id')[0] + '_quantity').val(1);
      $("#order_order_items_attributes_" + id.split("order_order_items_attributes_")[1].split("_product_id")[0] + "_comment").val(result.stock);
      $("#order_order_items_attributes_" + id.split("order_order_items_attributes_")[1].split("_product_id")[0] + "_comment").parent().parent().nextAll('span:first').text(result.stock);
      $("#order_order_items_attributes_" + id.split("order_order_items_attributes_")[1].split("_product_id")[0] + "_comment").parent().parent().nextAll('span:last.span-cost-price').text(result.cost);
      $('#order_order_items_attributes_' + id.split('order_order_items_attributes_')[1].split('_product_id')[0] + '_gst').val(result.gst);
      costUpdateReturnOrder();
      if (!isNaN($(".stock")[$(".stock").length-1].valueAsNumber))
      {$("a.add_fields").trigger("click");}
    },
    error: function() {
      window.alert('something wrong!');
    }
  });
};

set_sale_order_hscheme = function(value, id) {
  $.ajax({
    type: 'GET',
    contentType: 'application/json; charset=utf-8',
    url: '/products/get_product_data',
    data: {
      product_id: value
    },
    dataType: 'json',
    success: function(result) {
      $('#order_order_items_attributes_' + id.split('order_order_items_attributes_')[1].split('_product_id')[0] + '_sale_price').val(result.sale);
      $('#order_order_items_attributes_' + id.split('order_order_items_attributes_')[1].split('_product_id')[0] + '_quantity').val(result.size_1);
      $('#order_order_items_attributes_' + id.split('order_order_items_attributes_')[1].split('_product_id')[0] + '_marla').val(result.marla);
      $('#order_order_items_attributes_' + id.split('order_order_items_attributes_')[1].split('_product_id')[0] + '_square_feet').val(result.square_feet);
      $("#order_order_items_attributes_" + id.split("order_order_items_attributes_")[1].split("_product_id")[0] + "_comment").val(result.stock);
      $("#order_order_items_attributes_" + id.split("order_order_items_attributes_")[1].split("_product_id")[0] + "_comment").parent().parent().nextAll('span:first').text(result.stock);
      $("#order_order_items_attributes_" + id.split("order_order_items_attributes_")[1].split("_product_id")[0] + "_comment").parent().parent().nextAll('span:last.span-cost-price').text(result.cost);
      $('#order_order_items_attributes_' + id.split('order_order_items_attributes_')[1].split('_product_id')[0] + '_gst').val(result.gst);
      $('#order_property_plans_attributes_0_area_in_marla').val(result.size_1*result.sale);
      $('#order_property_plans_attributes_0_price_per_marla').val(result.size_1*result.sale);
      costUpdateReturnOrder();
      if (!isNaN($(".stock")[$(".stock").length-1].valueAsNumber))
      {$("a.add_fields").trigger("click");}
    },
    error: function() {
      window.alert('something wrong!');
    }
  });
};


function save_sale_order()
{
  if ($(".stock").length>0)
  {
    if (isNaN($(".stock")[$(".stock").length-1].valueAsNumber))
    {$("a.remove_fields")[($("a.remove_fields").length-1)].click();}
  }
  else if (isNaN($(".quantity-price")[$(".quantity-price").length-1].valueAsNumber))
  {$("a.remove_fields")[($("a.remove_fields").length-1)].click();}
}



$(document).on("click",".return_order.remove_fields.existing",function(){
    setTimeout(function(){
      costUpdateReturnOrder();
    }, 70);
});

$(document).on("click",".return_order.remove_fields.dynamic",function(){
    setTimeout(function(){
      costUpdateReturnOrder();
    }, 70);
});
