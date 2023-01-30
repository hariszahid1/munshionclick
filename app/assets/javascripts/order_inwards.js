function set_order_inward_products(item_type_id){
    $.ajax({
      url: '/order_inwards/get_order_inward_product_data',
      type: 'GET',
      data: { item_type_id: item_type_id },
      dataType: 'json',
      success: function (data) {
        var options =  "<option value=''>Please select a Product</option>";;
        for (var i = 0; i < data.length; i++) {
          options += "<option value='" + data[i].id + "'>" + data[i].title + "</option>";
        }
        $('.order-inward-products').html(options);
     },
     error: function (){
        window.alert("something wrong!");
     }
    });
  }


function set_order_inward_suppliers(product_id){
$.ajax({
  url: '/order_inwards/get_order_inward_supplier_data',
  type: 'GET',
  data: { product_id: product_id },
  dataType: 'json',
  success: function (data) {
    var options =  "<option value=''>Please select a supplier</option>";;
    for (var i = 0; i < data.length; i++) {
      options += "<option value='" + data[i].id + "'>" + data[i].name + "</option>";
    }
    $('.order-inward-suppliers').html(options);
 },
 error: function (){
    window.alert("something wrong!");
 }
});
}