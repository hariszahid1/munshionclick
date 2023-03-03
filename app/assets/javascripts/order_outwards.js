
  function products_call(user_id, add_more){
    $.ajax({
      url: '/order_outwards/get_outward_party_data',
      type: 'GET',
      data: { id: user_id },
      dataType: 'script',
      success: function (result) {
        var options = "<option value='0'>Please select a product</option>";
        var result_data = JSON.parse(result)
        for(var i = 0; i < result_data.length; i++){
          options += "<option value='" + result_data[i].id + "'>" + result_data[i].title + "</option>";
        }
        if(add_more){
          for(var i = 0; i<$('.product-outward').length; i++ ){
            if (isNaN(parseInt($('.product-outward')[i].value))){
              $($('.product-outward')[i]).html(options);
            }
          }
        }
        else{
          $('.product-outward').html(options);
        }

     },
     error: function (){
        window.alert("something wrong!");
     }
    });
  }


function markas_call(product_id, id){
  var party_id = $('#party-name').val()
    $.ajax({
      url: '/order_outwards/get_outward_marka_data',
      type: 'GET',
      data: { product_id: product_id, party_id: party_id },
      dataType: 'script',
      success: function (result) {
        var options = "<option value='0'>Please select a marka</option>";
        var result_data = JSON.parse(result)
        for(var i = 0; i < result_data.length; i++){
          options += "<option value='" + result_data[i] + "'>" + result_data[i] + "</option>";
        }
        $('#order_order_items_attributes_' + id.split('order_order_items_attributes_')[1].split('_product_id')[0] + '_marka').html(options);
     },
     error: function (){
        window.alert("something wrong!");
     }
    });
  }

  function challans_call(event){
    var target = event.currentTarget;
    var party_id = $('#party-name').val()
    var marka_no =  $(target.closest('.challan-stock-container')).find('.marka-outward').val()
    var product_id =  $(target.closest('.challan-stock-container')).find('.product-outward').val()
    $.ajax({
      url: '/order_outwards/get_outward_challan_data',
      type: 'GET',
      data: { marka_id: marka_no, party_id: party_id, product_id: product_id },
      dataType: 'script',
      success: function (result) {
        var options = "<option value='0'>Please select a challan</option>";
        var result_data = JSON.parse(result)
        for(var i = 0; i < result_data.length; i++){
          options += "<option value='" + result_data[i][0] + "'>" + result_data[i] + "</option>";
        }
        $(target.closest('.challan-stock-container')).find('.challan-outward').html(options);
     },
     error: function (){
        window.alert("something wrong!");
     }
    });
  }


  function remainimg_stocks_call(event){
    var target = event.currentTarget;
    var party_id = $('#party-name').val()
    var challan_no =  $(target.closest('.challan-stock-container')).find('.challan-outward').val()
    var marka_no =  $(target.closest('.challan-stock-container')).find('.marka-outward').val()
    var product_id =  $(target.closest('.challan-stock-container')).find('.product-outward').val()
    $.ajax({
      url: '/order_outwards/get_outward_stock_data',
      type: 'GET',
      data: { challan_no: challan_no, marka_no: marka_no, product_id: product_id, party_id: party_id },
      dataType: 'script',
      success: function (result) {
        var result_data = JSON.parse(result).toString()
        $(target.closest('.challan-stock-container')).find('.outward-remaining-stock').val(result_data);
     },
     error: function (){
        window.alert("something wrong!");
     }
    });
  }


  function set_remainimg_outward_quantity(event){
    var target = event.currentTarget;
    var stock_val = target.value;
    var party_id = $('.outward-party-name').val();
    var challan_no =  $(target.closest('.challan-stock-container')).find('.challan-storage-outward').val();
    var marka_no =  $(target.closest('.challan-stock-container')).find('.marka-storage-outward').val();
    var product_id =  $(target.closest('.challan-stock-container')).find('.product-storage-outward').val();
    $.ajax({
      url: '/cold_storage_outwards/get_outward_storage_stock_data',
      type: 'GET',
      data: { challan_no: challan_no, marka_no: marka_no, product_id: product_id, party_id: party_id },
      dataType: 'script',
      success: function (result) {
        var result_data = JSON.parse(result).toString()
        if (parseInt(stock_val) > parseInt(result_data))
        {
          window.alert("You cannot enter stock more than remaining!");
          target.value = '';
        }
        else
        {
          $(target.closest('.challan-stock-container')).find('.outward-stock-value-quantity').val(stock_val);
          var rem_out_stock_val = parseInt(result_data) - parseInt(stock_val);
          $(target.closest('.challan-stock-container')).find('.outward-storage-remaining-stock').html(rem_out_stock_val);
          $(target.closest('.challan-stock-container')).find('.outward-stock-value-rem-quantity').val(rem_out_stock_val);
          outwardCarriageCostUpdate()
        }
     },
     error: function (){
        window.alert("something wrong!");
     }
    });
  }

  function outwardCarriageCostUpdate(){
    var carriage = $("#outward_purchase_sale_detail_carriage_value").val()!= "" ? parseFloat($("#outward_purchase_sale_detail_carriage_value").val()) : 0
    var loading = $("#outward_purchase_sale_detail_loading_value").val()!= "" ? parseFloat($("#outward_purchase_sale_detail_loading_value").val()) : 0
    var len = $('.outward-stock-value').length
    var total_stock = 0
    for (var i=0; i < len; i++)
    {
      var single_stock = parseFloat($('.outward-stock-value')[i].value)
      total_stock = total_stock + single_stock
    }
    $("#outward_purchase_sale_detail_carriage").val((carriage*total_stock))
    $("#outward_purchase_sale_detail_loading").val((loading*total_stock))
  }

  function outwardCarriageUpdate(){
    var carriage = $("#outward_purchase_sale_detail_carriage").val()!= "" ? parseFloat($("#outward_purchase_sale_detail_carriage").val()) : 0
    var loading = $("#outward_purchase_sale_detail_loading").val()!= "" ? parseFloat($("#outward_purchase_sale_detail_loading").val()) : 0
    var len = $('.outward-stock-value').length
    var total_stock = 0
    for (var i=0; i < len; i++)
    {
      var single_stock = parseFloat($('.outward-stock-value')[i].value)
      total_stock = total_stock + single_stock
    }
    $("#outward_purchase_sale_detail_carriage_value").val((carriage/total_stock).toFixed(2))
    $("#outward_purchase_sale_detail_loading_value").val((loading/total_stock).toFixed(2))
  }
