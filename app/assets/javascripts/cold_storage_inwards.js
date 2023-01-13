function inwardCarriageCostUpdate(){
    var carriage = $("#inward_purchase_sale_detail_carriage_value").val()!= "" ? parseFloat($("#inward_purchase_sale_detail_carriage_value").val()) : 0
    var loading = $("#inward_purchase_sale_detail_loading_value").val()!= "" ? parseFloat($("#inward_purchase_sale_detail_loading_value").val()) : 0
    var total_stock = $("#order_inward_total").text()!= "" ? parseFloat($("#order_inward_total").text()) : 0
    $("#inward_purchase_sale_detail_carriage").val((carriage*total_stock))
    $("#inward_purchase_sale_detail_loading").val((loading*total_stock))
  }

  function inwardCarriageUpdate(){
    var carriage = $("#inward_purchase_sale_detail_carriage").val()!= "" ? parseFloat($("#inward_purchase_sale_detail_carriage").val()) : 0
    var loading = $("#inward_purchase_sale_detail_loading").val()!= "" ? parseFloat($("#inward_purchase_sale_detail_loading").val()) : 0
    var total_stock = $("#order_inward_total").text()!= "" ? parseFloat($("#order_inward_total").text()) : 0
    $("#inward_purchase_sale_detail_carriage_value").val((carriage/total_stock).toFixed(2))
    $("#inward_purchase_sale_detail_loading_value").val((loading/total_stock).toFixed(2))
  }