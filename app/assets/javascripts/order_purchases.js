set_cost_order = function(value, id) {
    $.ajax({
      type: 'GET',
      contentType: 'application/json; charset=utf-8',
      url: '/products/get_product_data',
      data: {
        product_id: value
      },
      dataType: 'json',
      success: function(result) {
        $('#order_order_items_attributes_' + id.split('order_order_items_attributes_')[1].split('_product_id')[0] + '_cost_price').val(result.cost);
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

  set_raw_purchase_cost = function(value,id){
    $.ajax({
       type: "GET",// GET in place of POST
       contentType: "application/json; charset=utf-8",
       url: "/items/get_item_data",
       data : {item_id: value},
       dataType: "json",
       success: function (result) {
         $('#order_order_items_attributes_' + id.split('order_order_items_attributes_')[1].split("_item_id")[0]+"_cost_price").val(result.cost);
         $('#order_order_items_attributes_' + id.split('order_order_items_attributes_')[1].split("_item_id")[0]+"_quantity").val(1);
         $("#order_order_items_attributes_" + id.split("order_order_items_attributes_")[1].split("_product_id")[0] + "_comment").parent().parent().nextAll('span:first').text(result.stock);
         $("#order_order_items_attributes_" + id.split("order_order_items_attributes_")[1].split("_product_id")[0] + "_comment").parent().parent().nextAll('span:last.span-cost-price').text(result.cost);
         costUpdateReturnOrder();
         if (!isNaN($(".stock")[$(".stock").length-1].valueAsNumber))
         {$("a.add_fields").trigger("click");}
       },
       error: function (){
          window.alert("something wrong!");
       }
    });
  }