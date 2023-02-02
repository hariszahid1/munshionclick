$(document).keyup(function(e) {
  if (e.key === "Escape" || e.keyCode === 27) {
    if (navigator.userAgent.indexOf('Firefox') > 0){
      window.location.href = "/"
    }else{
      window.history.back();
    }
  }
});

function discountCal(){
  $('#purchase_sale_detail_discount_price').val(parseInt($('#purchase_sale_detail_amount').val()*(Number($('#purchase_sale_detail_discount_price_per').val())/100)));
  remaingUpdateAmount();
}
function discountCalOder(){
  $('#order_discount_price').val(parseInt($('#order_total_bill').val()*(Number($('#order_detail_discount_price_per').val())/100)));
  remaingUpdateAmountOrder();
}

function warranty_generat(e){
  // DEBUG:
  text = e.parentNode.parentNode.getElementsByClassName('warranty-serail')[0].value;
  from = e.parentNode.parentNode.getElementsByClassName('warranty-from')[0].value;
  to = e.parentNode.parentNode.getElementsByClassName('warranty-to')[0].value;
  result=""
  for (i = parseInt(from); i <= parseInt(to); i++) {
    result=result+text+i+"\r\n";
  }
  e.parentNode.parentNode.getElementsByClassName('serial_no')[0].value = result;

}

function wage_rate_generat(e){
  // DEBUG:
  wage_rate = e.parentNode.parentNode.parentNode.getElementsByClassName('wage-rate')[0].value;
  qty_hour = e.parentNode.parentNode.parentNode.getElementsByClassName('qty-hour')[0].value;
  result=""
  result=wage_rate*qty_hour;
  e.parentNode.parentNode.parentNode.parentNode.getElementsByClassName('salary-amount')[0].value = result;
}

function sum(input){

 if (toString.call(input) !== "[object Array]")
  return false;
  var total =  0;
  for(var i=0;i<input.length;i++)
    {
      if(isNaN(input[i])){
      continue;
       }
        total += Number(input[i]);
     }
   return total;
}

function expense_total()
{
  b=$(".expense").map(function() {
    return this.value;
  }).get();
  sum_number=b.map(function(item) {
    return parseInt(item, 10);
  });
 $("#expense_total").text(sum(sum_number));
}

function advance_all_total()
{
  b=$(".advance_all").map(function() {
    return this.value;
  }).get();
  sum_number=b.map(function(item) {
    return parseInt(item, 10);
  });
 $("#advance_all_total").text(sum(sum_number));
}

$(document).ready(function() {
  if ($("#expiryDateDisplay").text()[0]=="S")
  {
    $(".expiryDateDisplay").text($("#expiryDateDisplay").text());
    $('#expiryDateModel').show();
  }

  setTimeout(function(){
    $(".chosen-select").chosen({
      allow_single_deselect: true,
      width: '100%'
    });
  }, 50);
});
function close_model(model_id){
  $("#"+model_id).hide("model");
}

function set_atom_sale(value,id){
  $.ajax({
     type: "GET",// GET in place of POST
     contentType: "application/json; charset=utf-8",
     url: "/products/get_product_data",
     data : {product_id: value},
     dataType: "json",
     success: function (result) {
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_sale_price").val(result.sale);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_quantity").val(1);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_comment").val(result.stock);
       costAtomUpdateReturn();
       // costAtomUpdate();
     },
     error: function (){
        window.alert("something wrong!");
     }
  });
}

function salary_detail_credit()
{
  $("#salary_detail_payments_attributes_0_credit").val($("#salary_detail_amount").val());
}

function set_sale(value,id){
  order_number=$('#purchase_sale_detail_order_id').val();
  purchase_number=$('#purchase_sale_detail_id').val();
  $.ajax({
     type: "GET",// GET in place of POST
     contentType: "application/json; charset=utf-8",
     url: "/products/get_product_data",
     data : {product_id: value,order_id: order_number,purchase_id: purchase_number,transaction_type:"sale"},
     dataType: "json",
     success: function (result) {
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_sale_price").val(result.sale);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_sale_price").attr('min',result.cost);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_sale_price").parent().parent().children('input').val(result.sale);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_quantity").val(1);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_comment").val(result.stock);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_comment").parent().parent().nextAll('span:first').text(result.stock);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_comment").parent().parent().nextAll('span:last.span-cost-price').text(result.cost);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_gst").val(result.gst);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_gst_amount").val((result.sale/100)*result.gst);
       if ($("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_comment").parent().parent().nextAll('span:first').text()<=0 && (result.sys_type!="batha" && result.sys_type!="FastFood" && result.sys_type!="Factory"))
       {
         alert("Stock less then 0 please Add Stock first");
         $(".return.remove_fields.dynamic:last").click();
         $("a.add_fields.new_product").trigger("click");
       }
       else{
         costUpdateReturn();
         if ((!isNaN($(".stock")[$(".stock").length-1].valueAsNumber)) && $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_purchase_sale_type").val()!="Return_type")
         {
           $("a.add_fields.new_product").trigger("click");
           if (result.serial)
           {
             $("a.add_fields.new_warranty").trigger("click");
             setTimeout(function(){
               $(".product_serial_no:last").text(result.warranty_list);
             }, 100);
           }
         }
       }
     },
     error: function (){
        window.alert("something wrong!");
     }
  });
}

function productAssign(value){
  if($(".product.chosen-select").length>0)
  {
    if ($("#"+$(".product.chosen-select")[$(".product.chosen-select").length-1].id).val()=="")
    {
      var $mySelectProduct= $("#"+$(".product.chosen-select")[$(".product.chosen-select").length-1].id);
    }

    var $mySelect= $("#"+$(".product.chosen-select")[$(".product.chosen-select").length-1].id);
    var enableChosen = setTimeout(function() {
      $mySelect.chosen();
      if ($mySelect.val()=="")
      {
        $mySelect.val(value);
      }
      $mySelect.trigger("chosen:updated");
      // $mySelect.trigger('chosen:activate');
      set_sale_order(value,$mySelect[0].id);
    }, 50);
    setTimeout(function() {
      discountCalOder();
    }, 1000);


    setTimeout(function(){
      $(".chosen-select").chosen({
        allow_single_deselect: true,
        width: '100%'
      });
    }, 60);

  }
  return false;
}

function serail_number_return(value){
  serail = $("#"+value.id).parent().parent().next().children('div').children('textarea.serial_no').val();
  if (value.checked) {
    // the checkbox is now checked
    $("#"+value.id).parent().parent().next().children('div').children('textarea.serial_no').val($("#"+value.id).val()+'\n'+serail);
  } else {
    alpha = $.trim(serail).replace(/[\n\n]+/g,'\n').split('\n');
    alpha.splice(alpha.indexOf($("#"+value.id).val()),1);
    $("#"+value.id).parent().parent().next().children('div').children('textarea.serial_no').val(alpha.join('\n'));

    // the checkbox is now no longer checked
  }
}

function serail_number_validation(e,value){
    product_id = $("#purchase_sale_detail_product_warranties_attributes_"+value.id.split("purchase_sale_detail_product_warranties_attributes_")[1].split("_serial")[0]+"_product_id").val();
    $(".product").each(function( index ) {
      if($(".product")[index].value==product_id)
      {
        $("#"+value.id).parent().nextAll('span:last').text($(".quantity-price")[index].value)
      }
    });

    var barcode="";
    var code = (e.keyCode ? e.keyCode : e.which);
    if(code==13)// Enter key hit
    {
      if (parseInt($("#"+value.id).parent().nextAll('span:last').text())>0)
      {
        value.value=Array.from(new Set($.trim(value.value.split(value.value.substring(0, 3)).join("\n"+value.value.substring(0, 3)).replace(/[\n\n]+/g,'\n')).split('\n').slice(0, parseInt($("#"+value.id).parent().nextAll('span:last').text())))).join("\n")
        if (value.value!="" && value.value.length>0)
        value.value=value.value+"\n"
      }
      if($("#"+value.id).parent().nextAll('textarea').text().toUpperCase().includes("\r"))
        var alpha = $("#"+value.id).parent().nextAll('textarea').text().toUpperCase().split('\r\n').filter(Boolean);
      else
        var alpha = $("#"+value.id).parent().nextAll('textarea').text().toUpperCase().split('\n').filter(Boolean);
      var beta =  value.value.toUpperCase().split('\n').filter(Boolean);
      var mega=beta;
      gama = alpha.filter(function(el) {return beta.indexOf(el) != -1});
      cgama = $(beta).not(alpha).get();
      $("#"+value.id).parent().nextAll('span:first').text(gama.length+cgama.length)
      if ((gama.length!=beta.length) && $("#purchase_sale_detail_transaction_type").val()=="Sale")
      {
        alert("Bar Code not in Database");
        value.value=gama.join("\n")
        if(gama.length>0)
        value.value=value.value+"\n"
        $("#"+value.id).parent().nextAll('span:first').text(gama.length)
      }
      else if((cgama.length!=beta.length) && $("#purchase_sale_detail_transaction_type").val()=="Purchase" && $('#purchase_sale_detail_id').val()==undefined)
      {
        alert("Code Already in Database: "+gama.toString()+' '+cgama.length);
        // if(cgama.length>0)
        $("#"+value.id).parent().nextAll('span:first').text(Array.from(new Set((gama.toString()+','+cgama).split(','))).length)
        // value.value=Array.from(new Set((gama.toString()+','+cgama).split(','))).join("\n")
        if (cgama.length>1)
        value.value=(cgama).join("\n");
        if (cgama.length==1)
        value.value=Array.from(new Set(cgama)).join("\n");value.value=value.value+"\n";
        if (cgama.length==0)
        {
          value.value=""
          $("#"+value.id).parent().nextAll('span:first').text(0)
        }
      }
      else {
        var current_serial_no = '';
        $('.serial_no').each(function( index ) {
          if ($(".serial_no")[index].id !=value.id)
            current_serial_no = current_serial_no+$(".serial_no")[index].value.toUpperCase();
        });
        current_serial_no=$.trim(current_serial_no).split('\n')
        pop_value=mega.pop();
        var arraybeta = (current_serial_no.indexOf(pop_value) > -1);
        if (arraybeta==true)
        value.value=mega.join("\n");
      }
    }
    else
    {
      if(parseInt($("#"+value.id).parent().nextAll('span:first').text())>parseInt($("#"+value.id).parent().nextAll('span:last').text()))
      {
        alert("Stock Matched : Please try another One!");
        // $("#"+value.id).val(Array.from(new Set($("#"+value.id).val().split('\n'))).filter(Boolean).slice(0,-1).toString().replace(/,/g,'\n'));
        // $("#"+value.id).parent().nextAll('span:first').text(Array.from(new Set($("#"+value.id).val().split('\n'))).filter(Boolean).length);
        // value.value=value.value+"\n"
        // console.log(Array.from(new Set($("#"+value.id).val().split('\n'))));
        // if($("#"+value.id).parent().nextAll('textarea').text().toUpperCase().includes("\r"))
        //   var alpha = $("#"+value.id).parent().nextAll('textarea').text().toUpperCase().split('\r\n').filter(Boolean);
        // else
        //   var alpha = $("#"+value.id).parent().nextAll('textarea').text().toUpperCase().split('\n').filter(Boolean);
        // var beta =  value.value.toUpperCase().split('\n').filter(Boolean);
        // gama=alpha.filter(function(el) {return beta.indexOf(el) != -1});
        // value.value=gama.join("\n")
        // if(gama.length>0)
        // value.value=value.value+"\n"
      }
      barcode=barcode+String.fromCharCode(code);
    }
    // var alpha = $("#"+value.id).parent().nextAll('textarea').text().toUpperCase().split('\r\n').filter(Boolean);
    // var beta =  value.value.toUpperCase().split('\n').filter(Boolean);
    // console.log( alpha );
    // console.log( beta );
    // gama=alpha.filter(function(el) {return beta.indexOf(el) != -1});
    // value.value=gama.join("\n")
    // value.value=value.value+"\n"
}
function save_sale()
{
  return_type=true;
  if($("#pos_setting_sys_type").val()!="HousingScheme")
  {
    if ($(".stock").length>0)
    {
      if (isNaN($(".stock")[$(".stock").length-1].valueAsNumber))
      {$("a.remove_fields.return")[($("a.remove_fields.return").length-1)].click();}
    }
    else if (isNaN($(".quantity-price")[$(".quantity-price").length-1].valueAsNumber))
    {$("a.remove_fields.return")[($("a.remove_fields.return").length-1)].click();}
  }
  $(".product").each(function( index ) {
  	product_detail = $('.product')[index].value
    if (window.location.href.split('transaction_type=sale').length>1)
  	{product_detail_value = $("#"+$('.product')[index].id).parent().parent().next().next().children().children()[1].value}
    else {product_detail_value = $("#"+$('.product')[index].id).parent().parent().next().children().children()[1].value}
  	$(".product-warranty").each(function( index ) {
  		product_war_detail = $('.product-warranty')[index].value
  		product_war_detail_value = $("#"+$('.product-warranty')[index].id).parent().parent().next().children().next('span:first').text()
  		if (product_war_detail==product_detail && parseInt(product_detail_value)!=parseInt(product_war_detail_value) && product_detail != '')
  		{
        //window.alert("Please Match the Quantity and Serial Number!");return_type = false;
      }
  	});
  });
  return return_type;
}
function set_bata_sale(value,id){
  $.ajax({
     type: "GET",// GET in place of POST
     contentType: "application/json; charset=utf-8",
     url: "/products/get_product_data",
     data : {product_id: value},
     dataType: "json",
     success: function (result) {
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_sale_price").val(result.sale);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_quantity").val(1);
       $("#size_1").val(result.size_1);
       $("#size_2").val(result.size_2);
       $("#size_3").val(result.size_3);
       $("#size_4").val(result.size_4);
       $("#size_5").val(result.size_5);
       $("#size_6").val(result.size_6);
       $("#size_7").val(result.size_7);
       $("#size_8").val(result.size_8);
       $("#size_9").val(result.size_9);
       $("#size_10").val(result.size_10);
       $("#size_11").val(result.size_11);
       $("#size_12").val(result.size_12);
       $("#size_13").val(result.size_13);
       $("#total_shoe").html(Number(result.size_1)+Number(result.size_2)+Number(result.size_3)+Number(result.size_4)+Number(result.size_5)+Number(result.size_6)+Number(result.size_7)+Number(result.size_8)+Number(result.size_9)+Number(result.size_10)+Number(result.size_11)+Number(result.size_12)+Number(result.size_13));
       costUpdate();
     },
     error: function (){
        window.alert("something wrong!");
     }
  });
}

function set_cost(value,id){
  $.ajax({
     type: "GET",// GET in place of POST
     contentType: "application/json; charset=utf-8",
     url: "/products/get_product_data",
     data : {product_id: value,transaction_type:"purchase"},
     dataType: "json",
     success: function (result) {
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_sale_price").val(result.sale);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_cost_price").val(result.cost);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_quantity").val(1);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_product_id")[0]+"_comment").val(result.stock);
       costUpdate();
       if ($(".quantity-price")[$(".quantity-price").length-1].valueAsNumber==1)
       {
         $("a.add_fields.new_product").trigger("click");
         if (result.serial)
         {
           $("a.add_fields.new_warranty").trigger("click");
           setTimeout(function(){
             $(".product_serial_no:last").text(result.warranty_list);
           }, 70);
         }
       }
     },
     error: function (){
        window.alert("something wrong!");
     }
  });
}

function set_raw_cost(value,id){
  $.ajax({
     type: "GET",// GET in place of POST
     contentType: "application/json; charset=utf-8",
     url: "/items/get_item_data",
     data : {item_id: value},
     dataType: "json",
     success: function (result) {
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_item_id")[0]+"_sale_price").val(result.sale);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_item_id")[0]+"_cost_price").val(result.cost);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_item_id")[0]+"_quantity").val(1);
       $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_item_id")[0]+"_comment").val(result.stock);
       costUpdate();
     },
     error: function (){
        window.alert("something wrong!");
     }
  });
}

function set_sys_user_balance(value,position){
  $.ajax({
     type: "GET",// GET in place of POST
     contentType: "application/json; charset=utf-8",
     url: "/sys_users/sys_user_balance",
     data : {sys_user_id: value},
     dataType: "json",
     success: function (result) {
       $("#"+position).html(result.balance);
     },
     error: function (){
       $("#sys_user_balance").html(0.0);
        window.alert("Please select Customer/Supplier!");
     }
  });
}

/////////////new balance mbWork///////////////
function newBalance(from_bal,position){
  //old Balance
  var oldBalance= document.querySelector("."+from_bal).textContent;
  oldBalance=parseFloat(oldBalance)
  //credit value
    enteredCreditValue=isNaN(Number($('.credit').val())) ? 0 : Number($('.credit').val());
    enteredCreditValue=parseFloat(enteredCreditValue)
  //debit value
  var enteredDebitValue=isNaN(Number($('.debit').val())) ? 0 : Number($('.debit').val());
  enteredDebitValue=parseFloat(enteredDebitValue)
  //formula
  temp=oldBalance+(enteredCreditValue-enteredDebitValue)
  //setting new value
  $("."+position).html(temp);
}

function newBalancePayment(value_1,value_2,position_1,position_2){
  //old Balance
  var oldBalance_1= document.querySelector("#"+value_1).textContent;
  oldBalance_1=parseFloat(oldBalance_1)
  var oldBalance_2= document.querySelector("#"+value_2).textContent;
  oldBalance_2=parseFloat(oldBalance_2)
  //credit value
  enteredCreditValue=isNaN(Number($('.credit').val())) ? 0 : Number($('.credit').val());
  enteredCreditValue=parseFloat(enteredCreditValue)
  //debit value
  var enteredDebitValue=isNaN(Number($('.debit').val())) ? 0 : Number($('.debit').val());
  enteredDebitValue=parseFloat(enteredDebitValue)
  //formula
  temp_1=oldBalance_1-(enteredCreditValue-enteredDebitValue)
  temp_2=oldBalance_2+(enteredCreditValue-enteredDebitValue)
  //setting new value
  $("#"+position_1).html(temp_1);
  $("#"+position_2).html(temp_2);
}

function newBalancePurchaseSaleDetails(){
  if(($("#purchase_sale_detail_transaction_type").val()=="Purchase") || ($(".inward-outward-field").val()=="InWard") || ($(".inward-outward-field").val()=="OutWard"))  
  { var oldBalance =$('#sys_user_balance').text();
    var remaining=$('.purchase_sale_detail_amount').text();
    oldBalance=parseFloat(oldBalance);
    remaining=parseFloat(remaining);
    temp=oldBalance+remaining;
  $(".newBalance1").html(temp);
}
  else
  { var oldBalance =$('#sys_user_balance').text();
    var remaining=$('.purchase_sale_detail_amount').text();
    oldBalance=parseFloat(oldBalance);
    remaining=parseFloat(remaining);
    temp=oldBalance-remaining;
  $(".newBalance1").html(temp);
}


}
// /////////////new balance ///////////////


function set_account_balance(value,position){
  $.ajax({
     type: "GET",// GET in place of POST
     contentType: "application/json; charset=utf-8",
     url: "/accounts/account_balance",
     data : {account_id: value},
     dataType: "json",
     success: function (result) {
       $("#"+position).html(result.balance);
     },
     error: function (){
       $("#"+position).html(0.0);
        window.alert("Please select Account!");
     }
  });
}

function set_material_sale(value,id){
  $.ajax({
     type: "GET",// GET in place of POST
     contentType: "application/json; charset=utf-8",
     url: "/items/get_item_data",
     data : {item_id: value},
     dataType: "json",
     success: function (result) {
       $("#production_materials_attributes_"+id.split("production_materials_attributes_")[1].split("_item_id")[0]+"_sale_price").val(result.sale);
         $("#production_materials_attributes_"+id.split("production_materials_attributes_")[1].split("_item_id")[0]+"_cost_price").val(result.cost);
       $("#production_materials_attributes_"+id.split("production_materials_attributes_")[1].split("_item_id")[0]+"_quantity").val(1);
       materialCostUpdate();
     },
     error: function (){
        window.alert("something wrong!");
     }
  });
}

function set_material_sale(value,id){
  $.ajax({
     type: "GET",// GET in place of POST
     contentType: "application/json; charset=utf-8",
     url: "/items/get_item_data",
     data : {item_id: value},
     dataType: "json",
     success: function (result) {
       $("#production_materials_attributes_"+id.split("production_materials_attributes_")[1].split("_item_id")[0]+"_sale_price").val(result.sale);
         $("#production_materials_attributes_"+id.split("production_materials_attributes_")[1].split("_item_id")[0]+"_cost_price").val(result.cost);
       $("#production_materials_attributes_"+id.split("production_materials_attributes_")[1].split("_item_id")[0]+"_quantity").val(1);
       materialCostUpdate();
     },
     error: function (){
        window.alert("something wrong!");
     }
  });
}

function set_material_product_sale(value,id){
  $.ajax({
     type: "GET",// GET in place of POST
     contentType: "application/json; charset=utf-8",
     url: "/products/get_product_data",
     data : {product_id: value},
     dataType: "json",
     success: function (result) {
       $("#production_materials_attributes_"+id.split("production_materials_attributes_")[1].split("_product_id")[0]+"_sale_price").val(result.sale);
         $("#production_materials_attributes_"+id.split("production_materials_attributes_")[1].split("_product_id")[0]+"_cost_price").val(result.cost);
       $("#production_materials_attributes_"+id.split("production_materials_attributes_")[1].split("_product_id")[0]+"_quantity").val(1);
       materialCostUpdate();
     },
     error: function (){
        window.alert("something wrong!");
     }
  });
}

function set_sale_data(data){

}

document.addEventListener("turbolinks:load", function() {
  FontAwesome.dom.i2svg();

  if ($(".bootstrap-table").length == 0){
    $("table").bootstrapTable();
  }

  $('.datepicker').datetimepicker({
    format: "YYYY-MM-DD"
  });

  $(".container-fluid form").validate();

  setTimeout(function(){
    $(".chosen-select").chosen({
  allow_single_deselect: true,
  width: '100%'
});
  }, 100);

});
function daily_count(){
  $('#p5000').html(Number($("#c5000").val()).toFixed(2)*5000);
  $('#p1000').html(Number($("#c1000").val()).toFixed(2)*1000);
  $('#p500').html(Number($("#c500").val()).toFixed(2)*500);
  $('#p100').html(Number($("#c100").val()).toFixed(2)*100);
  $('#p50').html(Number($("#c50").val()).toFixed(2)*50);
  $('#p20').html(Number($("#c20").val()).toFixed(2)*20);
  $('#p10').html(Number($("#c10").val()).toFixed(2)*10);
  $('#total').html(
    (Number($("#c5000").val()).toFixed(2)*5000)+(Number($("#c1000").val()).toFixed(2)*1000)+(Number($("#c500").val()).toFixed(2)*500)+
    (Number($("#c100").val()).toFixed(2)*100)+
    (Number($("#c50").val()).toFixed(2)*50)+
    (Number($("#c20").val()).toFixed(2)*20)+
    (Number($("#c10").val()).toFixed(2)*10))
  $('#daily_sale_sale').val($('#total').html());
  $('#daily_sale_cash_out').val(Number($('#total').html())-10000);

}

function vaToFloat(val)
{
  return Number(parseFloat(val)).toFixed(2);
}


function remaingUpdate(){
  total_bill=$("#purchase_sale_detail_total_bill").val()!="" ? vaToFloat($("#purchase_sale_detail_total_bill").val()) : 0
  discount_price=$("#purchase_sale_detail_discount_price").val()!="" ? vaToFloat($("#purchase_sale_detail_discount_price").val()) : 0
  discount_amount=($(".purchase_sale_discount_amount").text()!="" && $(".purchase_sale_discount_amount").text()!="NaN") ? vaToFloat($(".purchase_sale_discount_amount").text()) : 0
  final_discount_amount=vaToFloat(total_bill-discount_price);
  $(".purchase_sale_discount_amount").text(final_discount_amount);
  // $("#purchase_sale_detail_amount").val($(".purchase_sale_discount_amount").text());
  // $(".purchase_sale_detail_amount").text(vaToFloat(final_discount_amount-total_amount));
}
function remaingUpdateAmount(){
  total_bill=$("#purchase_sale_detail_total_bill").val()!="" ? vaToFloat($("#purchase_sale_detail_total_bill").val()) : 0
  discount_price=$("#purchase_sale_detail_discount_price").val()!="" ? vaToFloat($("#purchase_sale_detail_discount_price").val()) : 0
  discount_amount=($(".purchase_sale_discount_amount").text()!="" && $(".purchase_sale_discount_amount").text()!="NaN") ? vaToFloat($(".purchase_sale_discount_amount").text()) : 0
  final_discount_amount=vaToFloat(total_bill-discount_price);
  $(".purchase_sale_discount_amount").text(final_discount_amount);
  total_amount=$("#purchase_sale_detail_amount").val()!="" ? vaToFloat($("#purchase_sale_detail_amount").val()) : 0
  $(".purchase_sale_detail_amount").text(vaToFloat(final_discount_amount-total_amount));
  newBalancePurchaseSaleDetails()
}

function expenseUpdate(){
  $("#expense_expense").val(0.00);
  $(".expense_total_bill").text(0.00);
  var i;
  for (i = 0; i < $(".expense").length; i++) {
    if(!isNaN(parseFloat($(".expense")[i].value)))
    {
      $("#expense_expense").val(Number((parseFloat($(".expense")[i].value))+parseFloat($("#expense_expense").val())).toFixed(2));
      $(".expense_total_bill").text($("#expense_expense").val());
    }
  }
  price_in_words($("#expense_expense").val(), 'price_in_words')
}

function carriageCostUpdate(){
  var i;
  var quantity=0;
  var total_quantity=0;
  carriage=$("#purchase_sale_detail_carriage_value").val()!= "" ? parseFloat($("#purchase_sale_detail_carriage_value").val()) : 0
  loading=$("#purchase_sale_detail_loading_value").val()!= "" ? parseFloat($("#purchase_sale_detail_loading_value").val()) : 0
  for (i = 0; i < $(".cost-price").length; i++) {
    if($("#"+$(".quantity-price")[i].id).parent().parent().parent().css("display")!='none' && !isNaN(parseFloat($(".cost-price")[i].value)) && !isNaN(parseFloat($(".quantity-price")[i].value)) && !isNaN(parseFloat($(".discount-price")[i].value)) && !isNaN(parseFloat($("#purchase_sale_detail_total_bill").val())))
    {
      quantity = (parseFloat($(".quantity-price")[i].value)).toFixed(2) != 'NaN' ? (parseFloat($(".quantity-price")[i].value)) : 0;
      total_quantity += quantity;
      cost = (parseFloat($(".cost-price-fixed")[i].value)).toFixed(2) != 'NaN' ? (parseFloat($(".cost-price-fixed")[i].value)) : 0;
      if ($("#pos_setting_sys_type").val() =='Factory')
      {
        $(".cost-price")[i].value=(cost-((((carriage*quantity)/quantity))+((loading/quantity))));
      }
      else {
        $(".cost-price")[i].value=(cost-(((carriage/quantity)*(quantity/1000))+((loading/quantity)*(quantity/1000))));
      }
    }
  }
  if ($("#pos_setting_sys_type").val() =='Factory')
  {
    $("#purchase_sale_detail_carriage").val((carriage*total_quantity))
    $("#purchase_sale_detail_loading").val((loading*total_quantity))
  }
  else {
    $("#purchase_sale_detail_carriage").val((carriage/1000)*total_quantity)
    $("#purchase_sale_detail_loading").val((loading/1000)*total_quantity)
  }
  // costUpdateReturn();
}

function carriageCostUpdateHscheme(){
  var i;
  var quantity=0;
  var total_quantity=0;
  carriage=$("#purchase_sale_detail_carriage_value").val()!= "" ? parseFloat($("#purchase_sale_detail_carriage_value").val()) : 0
  loading=$("#purchase_sale_detail_loading_value").val()!= "" ? parseFloat($("#purchase_sale_detail_loading_value").val()) : 0
  for (i = 0; i < $(".cost-price").length; i++) {
    if($("#"+$(".quantity-price")[i].id).parent().parent().parent().css("display")!='none' && !isNaN(parseFloat($(".cost-price")[i].value)) && !isNaN(parseFloat($(".quantity-price")[i].value)) && !isNaN(parseFloat($(".discount-price")[i].value)) && !isNaN(parseFloat($("#purchase_sale_detail_total_bill").val())))
    {
      quantity = (parseFloat($(".quantity-price")[i].value)).toFixed(2) != 'NaN' ? (parseFloat($(".quantity-price")[i].value)) : 0;
      total_quantity += quantity;
      cost = (parseFloat($(".cost-price-fixed")[i].value)).toFixed(2) != 'NaN' ? (parseFloat($(".cost-price-fixed")[i].value)) : 0;
      $(".cost-price")[i].value=(cost-(((carriage/quantity)*(quantity))+((loading/quantity)*(quantity))));
    }
  }
  $("#purchase_sale_detail_carriage").val((carriage)*total_quantity)
  $("#purchase_sale_detail_loading").val((loading)*total_quantity)
  // costUpdateReturn();
}

function costUpdate(){
  $("#purchase_sale_detail_total_bill").val(Number(parseFloat($("#purchase_sale_detail_carriage").val())+parseFloat($("#purchase_sale_detail_loading").val())).toFixed(2));
  $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
  // $("#purchase_sale_detail_discount_price").val(0);
  var i;
  for (i = 0; i < $(".cost-price").length; i++) {
    if($("#"+$(".quantity-price")[i].id).parent().parent().parent().css("display")!='none' && !isNaN(parseFloat($(".cost-price")[i].value)) && !isNaN(parseFloat($(".quantity-price")[i].value)) && !isNaN(parseFloat($(".discount-price")[i].value)) && !isNaN(parseFloat($("#purchase_sale_detail_total_bill").val())))
    {
      $("#purchase_sale_detail_total_bill").val(Number((parseFloat($(".cost-price")[i].value)*parseFloat($(".quantity-price")[i].value))+parseFloat($("#purchase_sale_detail_total_bill").val())).toFixed(2));
      $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
      // $("#purchase_sale_detail_amount").val($("#purchase_sale_detail_total_bill").val());
      $("#purchase_sale_detail_discount_price").val(parseFloat($(".discount-price")[i].value)+parseFloat($("#purchase_sale_detail_discount_price").val()));
      $(".total-cost-price")[i].value=Number(parseFloat($(".cost-price")[i].value)*parseFloat($(".quantity-price")[i].value)).toFixed(2);
      $("#total_price").val(Number((parseFloat($(".cost-price")[i].value)*parseFloat($(".quantity-price")[i].value))+parseFloat($("#purchase_sale_detail_total_bill").val())).toFixed(2));
    }
  }
  remaingUpdate();
}
function bataQuantityUpdate(id){
  total=
  parseFloat($("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_size")[0]+"_size_1").val())+
  parseFloat($("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_size")[0]+"_size_2").val())+
  parseFloat($("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_size")[0]+"_size_3").val())+
  parseFloat($("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_size")[0]+"_size_4").val())+
  parseFloat($("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_size")[0]+"_size_5").val())+
  parseFloat($("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_size")[0]+"_size_6").val())+
  parseFloat($("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_size")[0]+"_size_7").val())+
  parseFloat($("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_size")[0]+"_size_8").val())+
  parseFloat($("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_size")[0]+"_size_9").val())+
  parseFloat($("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_size")[0]+"_size_10").val())+
  parseFloat($("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_size")[0]+"_size_11").val())+
  parseFloat($("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_size")[0]+"_size_12").val())+
  parseFloat($("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_size")[0]+"_size_13").val());

  $("#purchase_sale_detail_purchase_sale_items_attributes_"+id.split("purchase_sale_detail_purchase_sale_items_attributes_")[1].split("_size")[0]+"_quantity").val(total);
  costUpdate();

}

function costAtomUpdate(){
  carriage=$("#purchase_sale_detail_carriage").val()!= "" ? parseFloat($("#purchase_sale_detail_carriage").val()) : 0
  loading=$("#purchase_sale_detail_loading").val()!= "" ? parseFloat($("#purchase_sale_detail_loading").val()) : 0

  $("#purchase_sale_detail_total_bill").val(Number(carriage+loading).toFixed(2));
  $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
  // $("#purchase_sale_detail_discount_price").val(0);
  var i;
  for (i = 0; i < $(".cost-price").length; i++) {
    if($(".pack-price").length>0){
      if($("#"+$(".quantity-price")[i].id).parent().parent().parent().css("display")!='none' && !isNaN(parseFloat($(".cost-price")[i].value)) && !isNaN(parseFloat($(".quantity-price")[i].value)) && !isNaN(parseFloat($("#purchase_sale_detail_total_bill").val())))
      {
        pack_price=1;
        if (!isNaN(parseFloat($(".pack-price")[i].value)))
        {
          pack_price=parseFloat($(".pack-price")[i].value);
        }
        quantity_price=parseFloat($(".quantity-price")[i].value);
        cost_price=parseFloat($(".cost-price")[i].value);
        total_bill=parseFloat($("#purchase_sale_detail_total_bill").val());
        discount_price=parseFloat($(".discount-price")[i].value);
        detail_discount_price=parseFloat($("#purchase_sale_detail_discount_price").val());
        $("#purchase_sale_detail_discount_price").val(discount_price+detail_discount_price);
        $("#purchase_sale_detail_total_bill").val(Number((cost_price*quantity_price*pack_price)+total_bill).toFixed(2));
        $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
        $("#purchase_sale_detail_amount").val($("#purchase_sale_detail_total_bill").val());
        $(".total-cost-price")[i].value=Number(cost_price*(quantity_price*pack_price)).toFixed(2);
        $("#total_price").val(Number((cost_price*quantity_price*pack_price)+$("#purchase_sale_detail_total_bill").val()).toFixed(2));
      }
    }else{
      if(!isNaN(parseFloat($(".cost-price")[i].value)) && !isNaN(parseFloat($(".quantity-price")[i].value)) && !isNaN(parseFloat($("#purchase_sale_detail_total_bill").val())))
      {
        $("#purchase_sale_detail_discount_price").val(parseFloat($(".discount-price")[i].value)+parseFloat($("#purchase_sale_detail_discount_price").val()));
        $("#purchase_sale_detail_total_bill").val(Number((parseFloat($(".cost-price")[i].value)*(parseFloat($(".quantity-price")[i].value)))+parseFloat($("#purchase_sale_detail_total_bill").val())+parseFloat($("#purchase_sale_detail_carriage").val())).toFixed(2));
        $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
        $("#purchase_sale_detail_amount").val($("#purchase_sale_detail_total_bill").val());
        $(".total-cost-price")[i].value=Number(parseFloat($(".cost-price")[i].value)*(parseFloat($(".quantity-price")[i].value))).toFixed(2);
        $("#total_price").val(Number((parseFloat($(".cost-price")[i].value)*(parseFloat($(".quantity-price")[i].value)))+parseFloat($("#purchase_sale_detail_total_bill").val())).toFixed(2));
      }
    }

  }
  remaingUpdate();
}

function costAtomUpdateReturn(){
  carriage=$("#purchase_sale_detail_carriage").val()!= "" ? parseFloat($("#purchase_sale_detail_carriage").val()) : 0
  loading=$("#purchase_sale_detail_loading").val()!= "" ? parseFloat($("#purchase_sale_detail_loading").val()) : 0
  $("#purchase_sale_detail_total_bill").val(Number(carriage+loading).toFixed(2));
  $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
  $("#purchase_sale_detail_amount").val($("#purchase_sale_detail_total_bill").val());
  // $("#purchase_sale_detail_discount_price").val(0);
  var i;
  for (i = 0; i < $(".cost-price").length; i++) {
    if($(".pack-price").length>0){
      if($("#"+$(".quantity-price")[i].id).parent().parent().parent().css("display")!='none' && !isNaN(parseFloat($(".cost-price")[i].value)) && !isNaN(parseFloat($(".quantity-price")[i].value)) && !isNaN(parseFloat($("#purchase_sale_detail_total_bill").val())))
      {
        pack_price=1;
        if (!isNaN(parseFloat($(".pack-price")[i].value)))
        {
          pack_price=parseFloat($(".pack-price")[i].value);
        }
        quantity_price=parseFloat($(".quantity-price")[i].value);
        cost_price=parseFloat($(".cost-price")[i].value);
        total_bill=parseFloat($("#purchase_sale_detail_total_bill").val());
        discount_price=parseFloat($(".discount-price")[i].value);
        detail_discount_price=parseFloat($("#purchase_sale_detail_discount_price").val());
        $("#purchase_sale_detail_discount_price").val(discount_price+detail_discount_price);
        $("#purchase_sale_detail_total_bill").val(Number((cost_price*quantity_price*pack_price)+total_bill).toFixed(2));
        $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
        $("#purchase_sale_detail_amount").val($("#purchase_sale_detail_total_bill").val());
        $(".total-cost-price")[i].value=Number(cost_price*(quantity_price*pack_price)).toFixed(2);
        $("#total_price").val(Number((cost_price*quantity_price*pack_price)+$("#purchase_sale_detail_total_bill").val()).toFixed(2));
      }
    }else{
      if(!isNaN(parseFloat($(".cost-price")[i].value)) && !isNaN(parseFloat($(".quantity-price")[i].value)) && !isNaN(parseFloat($("#purchase_sale_detail_total_bill").val())))
      {
        $("#purchase_sale_detail_discount_price").val(parseFloat($(".discount-price")[i].value)+parseFloat($("#purchase_sale_detail_discount_price").val()));
        $("#purchase_sale_detail_total_bill").val(Number((parseFloat($(".cost-price")[i].value)*(parseFloat($(".quantity-price")[i].value)))+parseFloat($("#purchase_sale_detail_total_bill").val())+parseFloat($("#purchase_sale_detail_carriage").val())).toFixed(2));
        $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
        $("#purchase_sale_detail_amount").val($("#purchase_sale_detail_total_bill").val());
        $(".total-cost-price")[i].value=Number(parseFloat($(".cost-price")[i].value)*(parseFloat($(".quantity-price")[i].value))).toFixed(2);
        $("#total_price").val(Number((parseFloat($(".cost-price")[i].value)*(parseFloat($(".quantity-price")[i].value)))+parseFloat($("#purchase_sale_detail_total_bill").val())).toFixed(2));
      }
    }
  }
  for (i = 0; i < $(".cost-price-return").length; i++) {
    if($(".pack-price-return").length>0){
      if($("#"+$(".quantity-price-return")[i].id).parent().parent().parent().css("display")!='none' && !isNaN(parseFloat($(".cost-price-return")[i].value)) && !isNaN(parseFloat($(".quantity-price-return")[i].value)) && !isNaN(parseFloat($("#purchase_sale_detail_total_bill").val())))
      {
        pack_price=1;
        if (!isNaN(parseFloat($(".pack-price-return")[i].value)))
        {
          pack_price=parseFloat($(".pack-price-return")[i].value);
        }
        quantity_price=parseFloat($(".quantity-price-return")[i].value);
        cost_price=parseFloat($(".cost-price-return")[i].value);
        total_bill=parseFloat($("#purchase_sale_detail_total_bill").val());
        discount_price=parseFloat($(".discount-price-return")[i].value);
        detail_discount_price=parseFloat($("#purchase_sale_detail_discount_price").val());
        $("#purchase_sale_detail_discount_price").val(Number(discount_price+detail_discount_price).toFixed(2));
        $("#purchase_sale_detail_total_bill").val(Number(total_bill-(cost_price*quantity_price*pack_price)).toFixed(2));
        $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
        $("#purchase_sale_detail_amount").val($("#purchase_sale_detail_total_bill").val());
        $(".total-cost-price-return")[i].value=Number(cost_price*(quantity_price*pack_price)).toFixed(2);
        $("#total_price").val(Number((cost_price*quantity_price*pack_price)+$("#purchase_sale_detail_total_bill").val()).toFixed(2));
      }
    }else{
      if(!isNaN(parseFloat($(".cost-price-return")[i].value)) && !isNaN(parseFloat($(".quantity-price-return")[i].value)) && !isNaN(parseFloat($("#purchase_sale_detail_total_bill").val())))
      {
        $("#purchase_sale_detail_discount_price").val(parseFloat($(".discount-price-return")[i].value)+parseFloat($("#purchase_sale_detail_discount_price").val()));
        $("#purchase_sale_detail_total_bill").val(Number((parseFloat($(".cost-price-return")[i].value)*(parseFloat($(".quantity-price-return")[i].value)))+parseFloat($("#purchase_sale_detail_total_bill").val())+parseFloat($("#purchase_sale_detail_carriage").val())).toFixed(2));
        $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
        $("#purchase_sale_detail_amount").val($("#purchase_sale_detail_total_bill").val());
        $(".total-cost-price-return")[i].value=Number(parseFloat($(".cost-price-return")[i].value)*(parseFloat($(".quantity-price-return")[i].value))).toFixed(2);
        $("#total_price").val(Number((parseFloat($(".cost-price-return")[i].value)*(parseFloat($(".quantity-price-return")[i].value)))+parseFloat($("#purchase_sale_detail_total_bill").val())).toFixed(2));
      }
    }
  }
  remaingUpdateAmount();
}

function saleCostUpdateReturn(com_type){

  if(($("#pos_setting_sys_type").val()=="HousingScheme") && (com_type=='commission' || parseFloat($("#purchase_sale_detail_carriage_value").val()) > 0 || parseFloat($("#purchase_sale_detail_loading_value").val()) > 0))
  {carriageCostUpdateHscheme();}
  else if(($("#pos_setting_sys_type").val()=="HousingScheme") && (com_type=='commission with perc'))
  {commissionPercentageUpdateHscheme();}
  else if(($("#pos_setting_sys_type").val()=="HousingScheme") && (com_type=='commission with price'))
  {commissionPriceUpdateHscheme();}
  else
  {carriageCostUpdate();}
  carriage=$("#purchase_sale_detail_carriage").val()!= "" ? parseFloat($("#purchase_sale_detail_carriage").val()) : 0
  loading=$("#purchase_sale_detail_loading").val()!= "" ? parseFloat($("#purchase_sale_detail_loading").val()) : 0
  $("#purchase_sale_detail_total_bill").val(Number(carriage+loading).toFixed(2));
  $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
  var i;
  for (i = 0; i < $(".cost-price").length; i++) {
    if($("#"+$(".quantity-price")[i].id).parent().parent().parent().css("display")!='none' && !isNaN(parseFloat($(".cost-price")[i].value)) && !isNaN(parseFloat($(".quantity-price")[i].value)) && !isNaN(parseFloat($("#purchase_sale_detail_total_bill").val())))
    {
      pack_price=1;
      quantity_price=parseFloat($(".quantity-price")[i].value);
      cost_price=parseFloat($(".cost-price")[i].value);
      total_bill=parseFloat($("#purchase_sale_detail_total_bill").val());
      discount_price=parseFloat($(".discount-price")[i].value);
      detail_discount_price=parseFloat($("#purchase_sale_detail_discount_price").val());
      $("#purchase_sale_detail_discount_price").val(discount_price+detail_discount_price);
      $("#purchase_sale_detail_total_bill").val(Number((cost_price*quantity_price*pack_price)+total_bill).toFixed(2));
      $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
      // $("#purchase_sale_detail_amount").val($("#purchase_sale_detail_total_bill").val());
      $(".total-cost-price")[i].value=Number(cost_price*(quantity_price*pack_price)).toFixed(2);
      $("#total_price").val(Number((cost_price*quantity_price*pack_price)+$("#purchase_sale_detail_total_bill").val()).toFixed(2));
    }

  }
  for (i = 0; i < $(".cost-price-return").length; i++) {
      if($("#"+$(".quantity-price-return")[i].id).parent().parent().parent().css("display")!='none' && !isNaN(parseFloat($(".cost-price-return")[i].value)) && !isNaN(parseFloat($(".quantity-price-return")[i].value)) && !isNaN(parseFloat($("#purchase_sale_detail_total_bill").val())))
      {
        pack_price=1;
        quantity_price=parseFloat($(".quantity-price-return")[i].value);
        cost_price=parseFloat($(".cost-price-return")[i].value);
        total_bill=parseFloat($("#purchase_sale_detail_total_bill").val());
        discount_price=parseFloat($(".discount-price-return")[i].value);
        detail_discount_price=parseFloat($("#purchase_sale_detail_discount_price").val());
        $("#purchase_sale_detail_discount_price").val(Number(discount_price+detail_discount_price).toFixed(2));
        $("#purchase_sale_detail_total_bill").val(Number(total_bill-(cost_price*quantity_price*pack_price)).toFixed(2));
        $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
        // $("#purchase_sale_detail_amount").val($("#purchase_sale_detail_total_bill").val());
        $(".total-cost-price-return")[i].value=Number(cost_price*(quantity_price*pack_price)).toFixed(2);
        $("#total_price").val(Number((cost_price*quantity_price*pack_price)+$("#purchase_sale_detail_total_bill").val()).toFixed(2));
      }
  }
  remaingUpdateAmount();

}

function costUpdateReturn(){
  carriage=$("#purchase_sale_detail_carriage").val()!= "" ? parseFloat($("#purchase_sale_detail_carriage").val()) : 0
  loading=$("#purchase_sale_detail_loading").val()!= "" ? parseFloat($("#purchase_sale_detail_loading").val()) : 0
  $("#purchase_sale_detail_total_bill").val(Number(carriage+loading).toFixed(2));
  $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
  var i;
  for (i = 0; i < $(".cost-price").length; i++) {
    if($("#"+$(".quantity-price")[i].id).parent().parent().parent().parent().css("display")!='none' && !isNaN(parseFloat($(".cost-price")[i].value)) && !isNaN(parseFloat($(".quantity-price")[i].value)) && !isNaN(parseFloat($("#purchase_sale_detail_total_bill").val())))
    {
      if($("#pos_setting_sys_type").val()!='Batha' && $(".product-stock").length>0)
      {
        if(parseFloat($(".product-stock")[i].textContent)<parseFloat($(".quantity-price")[i].value) && parseFloat($(".product-stock")[i].textContent)>0 && $('#purchase_sale_detail_id').val()==undefined)
        {
          $(".quantity-price")[i].value=$(".product-stock")[i].textContent
        }
      }
      pack_price=1;
      quantity_price=parseFloat($(".quantity-price")[i].value);
      if($(".stock").length>0)
      {
        stock=parseFloat($("#"+$(".stock")[i].id).parent().parent().nextAll('span:first').text())>0 ? parseFloat($("#"+$(".stock")[i].id).parent().parent().nextAll('span:first').text()) : 0;
        $(".extra-quantity")[i].value=(stock-quantity_price)
      }
      cost_price=parseFloat($(".cost-price")[i].value);
      gst_amount=0;
      gst=0;
      if($(".sale-price").length>0)
      {
        sale_price=parseFloat($(".sale-price")[i].value);
        $(".total-sale-price")[i].value=Number(sale_price*(quantity_price*pack_price)).toFixed(2);
      }
      total_bill=parseFloat($("#purchase_sale_detail_total_bill").val());
      discount_price=parseFloat($(".discount-price")[i].value);
      detail_discount_price=parseFloat($("#purchase_sale_detail_discount_price").val());
      if ($(".gst-total")[i]!=undefined)
      {
        gst=parseFloat($(".gst-per")[i].value);
        $(".gst-total")[i].value=Number((Number(cost_price*(quantity_price*pack_price)).toFixed(2)/100)*gst ).toFixed(2);
        gst_amount=parseFloat($(".gst-total")[i].value);
      }
      $("#purchase_sale_detail_discount_price").val(discount_price+detail_discount_price);
      $("#purchase_sale_detail_total_bill").val(Number((cost_price*quantity_price*pack_price)+total_bill+gst_amount).toFixed(2));
      $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
      // $("#purchase_sale_detail_amount").val($("#purchase_sale_detail_total_bill").val());
      $(".total-cost-price")[i].value=Number(cost_price*(quantity_price*pack_price)).toFixed(2);
      $("#total_price").val(Number((cost_price*quantity_price*pack_price)+$("#purchase_sale_detail_total_bill").val()).toFixed(2));
    }

  }
  for (i = 0; i < $(".cost-price-return").length; i++) {
      if($("#"+$(".quantity-price-return")[i].id).parent().parent().parent().css("display")!='none' && !isNaN(parseFloat($(".cost-price-return")[i].value)) && !isNaN(parseFloat($(".quantity-price-return")[i].value)) && !isNaN(parseFloat($("#purchase_sale_detail_total_bill").val())))
      {
        pack_price=1;
        quantity_price=parseFloat($(".quantity-price-return")[i].value);
        cost_price=parseFloat($(".cost-price-return")[i].value);
        total_bill=parseFloat($("#purchase_sale_detail_total_bill").val());
        discount_price=parseFloat($(".discount-price-return")[i].value);
        detail_discount_price=parseFloat($("#purchase_sale_detail_discount_price").val());
        $("#purchase_sale_detail_discount_price").val(Number(discount_price+detail_discount_price).toFixed(2));
        $("#purchase_sale_detail_total_bill").val(Number(total_bill-(cost_price*quantity_price*pack_price)).toFixed(2));
        $(".purchase_sale_detail_total_bill").text($("#purchase_sale_detail_total_bill").val());
        // $("#purchase_sale_detail_amount").val($("#purchase_sale_detail_total_bill").val());
        $(".total-cost-price-return")[i].value=Number(cost_price*(quantity_price*pack_price)).toFixed(2);
        $("#total_price").val(Number((cost_price*quantity_price*pack_price)+$("#purchase_sale_detail_total_bill").val()).toFixed(2));
      }
  }
  remaingUpdateAmount();

}

$(document).on("click",".return.remove_fields.existing",function(){
    setTimeout(function(){
      costUpdateReturn();
    }, 70);
});

$(document).on("click",".return.remove_fields.dynamic",function(){
    setTimeout(function(){
      costUpdateReturn();
    }, 70);
});

function materialCostUpdate(){
  $("#production_cost_price").val(0)
  var i;
  for (i = 0; i < $(".cost-price").length; i++) {
    if(!isNaN(parseFloat($(".cost-price")[i].value)) && !isNaN(parseFloat($(".quantity-price")[i].value)) && !isNaN(parseFloat($("#production_cost_price").val())))
    {
      $("#production_cost_price").val(Number((parseFloat($(".cost-price")[i].value)*parseFloat($(".quantity-price")[i].value))+parseFloat($("#production_cost_price").val())).toFixed(2));
      $(".production_cost_price").text($("#production_cost_price").val());
      $("#production_sale_price").val($("#production_cost_price").val());
      $(".total-cost-price")[i].value=Number(parseFloat($(".cost-price")[i].value)*parseFloat($(".quantity-price")[i].value)).toFixed(2);
      $(".total-sale-price")[i].value=Number(parseFloat($(".sale-price")[i].value)*parseFloat($(".quantity-price")[i].value)).toFixed(2);
      $("#production_sale_price").val(Number((parseFloat($(".sale-price")[i].value)*parseFloat($(".quantity-price")[i].value))+parseFloat($("#production_sale_price").val())).toFixed(2));
    }
  }
}
function toggle_teacher_staff(selected_value){
  $("#staff_monthly_salary").val('');
  $("#staff_salary_per_day").val('');
  $("#salary_paid_salary").val('');
  $("#salary_leaves_in_month").val('');
  $("#advance_salary_info").addClass("hidden");
  $("#calculate_teach_staff_salary_btn").addClass("hidden");
  if(selected_value == "Staff"){
    $("#staff_options_list").removeClass('hidden');
    $("#salary_staff_id").attr("required", "required");
  }else{
    $("#staff_options_list").addClass('hidden');
    $("#salary_staff_id").removeAttr("required");
  }
}

function set_staff_salary_info(selected_value){
  path = "/staffs/"+selected_value+"/salary_info";
  params= {}

  ajaxCall(path, params, set_staff_salary_detail);
}
function get_staff_wage_rate_info(selected_value){
  path = "/staffs/"+selected_value+"/salary_wage_rate_info";
  params= {}

  ajaxCall(path, params, set_staff_wage_rate_detail);

}

function set_staff_wage_rate_detail(data){
  $("#salary_detail_wage_rate").val(data.wage_rate);
  $("#balance").text(data.advance_amount);
  // $("#OtherStaff").text(data.staffs)
  var i=0;
  for(;i<data.staffs.length;i++)
  {
    var hold = document.getElementById("OtherStaff");
     var checkbox = document.createElement('input');
     checkbox.type = "checkbox";
     checkbox.name = "salary_detail[staff_ids_"+data.staff_ids[i]+"]";
     checkbox.id = "staff_ids_"+data.staff_ids[i];
     checkbox.checked = true;
     checkbox.class = "checkbox";
     checkbox.value = data.staff_ids[i];
     var label = document.createElement('label');
     var tn = document.createTextNode(data.staffs[i]);
     label.htmlFor=data.staff_ids[i];
     label.appendChild(tn);
     hold.appendChild(label);
     hold.appendChild(checkbox);
     document.getElementById("staff_ids_"+data.staff_ids[i]).addEventListener("click", checkbox_check);

  }
  var text = document.createElement('input');
  text.type = "hidden";
  text.name = "salary_detail[staff]";
  text.id = "staff_ids";
  text.value = data.staff_ids;
  hold.appendChild(text);
  var text = document.createElement('input');
  text.type = "hidden";
  text.name = "salary_detail[staff_count]";
  text.id = "staff_id_count";
  text.value = data.staff_count;
  hold.appendChild(text);
  $("#OtherStaffCount").text(data.staff_count)
  salaryCostUpdate();
}
function checkbox_check(){
  if ($(this).prop('checked')) {
     // do what you need here
     ids=$("#staff_ids").val();
     new_val=$(this).attr('value');
     if(ids!=new_val && ids!="")
     {
       $("#staff_ids").val($("#staff_ids").val()+","+new_val);
     }else{
       $("#staff_ids").val(new_val);
     }
     $("#staff_id_count").val(parseFloat($("#staff_id_count").val())+1);

  }
  else {
     // do what you need here
     ids=$("#staff_ids").val();
     new_val=$(this).attr('value');
     if($("#staff_ids").val().length>1)
     {
       after_ids=$("#staff_ids").val().replace(","+new_val,'');
     }
     else {
       after_ids=$("#staff_ids").val().replace(new_val,'');
     }
     if (ids==after_ids)
     {
       $("#staff_ids").val(ids.replace(new_val+",",''));
     }
     else if (after_ids=="") {
       $("#staff_ids").val(after_ids);
     }
     else {
       $("#staff_ids").val($("#staff_ids").val().replace(","+new_val,''));
     }
     $("#staff_id_count").val(parseFloat($("#staff_id_count").val())-1);
  }
  $("#OtherStaffCount").text($("#staff_id_count").val());
  salaryCostUpdate();
}
function set_staff_salary_detail(data){
  $("#staff_monthly_salary").val(data.monthly_salary);
  $("#staff_salary_per_day").val(data.daily_Salary);
  $("#staff_salary_info").removeClass("hidden");
  $("#advance_salary_info").removeClass("hidden");
  $("#salary_advance").val(data.advance_amount);
  $("#balance").text(data.balance);
  // $("#wage_debit").text(data.wage_debit);


  $("#calculate_teach_staff_salary_btn").removeClass("hidden");
  total_salary_to_pay = parseFloat(data.monthly_salary) - parseFloat(data.advance_amount);
  $("#salary_paid_salary").val(Math.round(total_salary_to_pay));
  $("#calculated_salary_model").text(Math.round(total_salary_to_pay));
  $("#salaryModel").show("model");
}

function calculate_teach_staff_salary(){
  advance_amount = $("#salary_advance").val();
  if(advance_amount == ""){
    advance_amount = 0;
  }
  leaves_in_month = $("#salary_leaves_in_month").val();
  if(leaves_in_month == ""){
    leaves_in_month = 0;
  }
  salary_per_day = $("#staff_salary_per_day").val();
  salary_to_pay = parseFloat(salary_per_day)*(parseInt(daysInThisMonth()) - parseInt(leaves_in_month));

  //after advance deduct
  total_salary_to_pay = parseFloat(salary_to_pay) - parseFloat(advance_amount);
  $("#salary_paid_salary").val(Math.round(total_salary_to_pay));

  $("#calculate_teach_staff_salary_btn").removeClass("hidden");
  if(parseInt(leaves_in_month) > 0){
    $("#calculated_salary_model_text").html("After advance and leaves amount deducted");
  }else{
    $("#calculated_salary_model_text").html("After advance deducted");
  }
  $("#calculated_salary_model").text(Math.round(total_salary_to_pay));
  $("#salaryModel").show("model");
}

function set_staff_advance_info(selected_value,position){
  path = "/staffs/"+selected_value+"/salary_info";
  params= {}
  $.ajax({
    url: path,
    type: 'GET',
    dataType: 'json',
    data: params,
    error: function(jqXHR, textStatus, errorThrown) {
      $("#cutoffModel").hide("model");
      $("#cutoffModel").removeClass("readyForEnter");
      $("#ajaxError").show("model");
    },
    success: function(data) {
      $("#advance_amount_taken").val(data.advance_amount);
      $("#"+position).text(data.balance);
      $("#salary_balance").val(data.wage_debit);
      $("#salary_total_balance").val(data.balance);
      $("#wage_debit").text(data.wage_debit);
      $("#wage_rate").text(data.wage_rate);
      $("#advance_amount_taken_div").removeClass("hidden");
    }
  });

}

function set_account_info(selected_value){
  $('.account').val(selected_value);
}
function set_rate_info(selected_value){
  $('.rate').val(selected_value);
}
function set_gift_rate_info(selected_value){
  $('.gift_rate').val(selected_value);
}
function set_coverge_rate_rate_info(selected_value){
  $('.coverge_rate').val(selected_value);
}

function set_staff_advance_detail(data){
  $("#advance_amount_taken").val(data.advance_amount);
  $("#advance_amount_taken_div").removeClass("hidden");
}

function set_teacher_advance_info(selected_value){
  path = "/teachers/"+selected_value+"/salary_info";
  params= {}

  ajaxCall(path, params, set_teacher_advance_detail);
}
function set_teacher_advance_detail(data){
  $("#advance_amount_taken").val(data.advance_amount);
  $("#balance").text(data.balance);
  $("#salary_balance").val(data.wage_debit);
  $("#salary_total_balance").val(data.balance);
  $("#wage_debit").text(data.wage_debit);
  $("#wage_rate").text(data.wage_rate);
  $("#advance_amount_taken_div").removeClass("hidden");
}

function set_khakar_info(selected_value,id){
  path = "/staffs/"+selected_value+"/salary_info";
  params= {}
  $.ajax({
    url: path,
    type: 'GET',
    dataType: 'json',
    data: params,
    error: function(jqXHR, textStatus, errorThrown) {
      $("#cutoffModel").hide("model");
      $("#cutoffModel").removeClass("readyForEnter");
      $("#ajaxError").show("model");
    },
    success: function(data) {
      if ($("#pos_setting_sys_type").val()=="batha")
      {
        $("#"+id.split('staff_id')[0]+"wage_rate").val(data.wage_rate*1000);
      }
      daily_book_khakar_update();
    }
  });
}


function daysInThisMonth() {
  var now = new Date();
  return new Date(now.getFullYear(), now.getMonth()+1, 0).getDate();
}
// Ajax calls
// function get_draw_limit_info(draw_setting_limit_id, serial_no){
//   bond_purchase_type = $("#bond_purchase_type").val();
//   if (bond_purchase_type == ""){
//     bond_purchase_type = "Normal";
//   }
//   path = "/customer_orders/draw_limit_info/"+draw_setting_limit_id+"/"+serial_no+"/"+bond_purchase_type;
//   customer_id = $("#customer_id").val();
//   params= {customer_id: customer_id}

//   ajaxCall(path, params, set_draw_limit_info, "get");
// }
function updatetabs(val)
{
  $('#from_tabe').val(val);
}

function salaryCostUpdate()
{
  // pack=Number(parseFloat($("#salary_detail_status").val())).toFixed(2);
  // quantity=Number(parseFloat($("#salary_detail_quantity").val())).toFixed(2);0
  wage_rate =$("#salary_detail_wage_rate").val() !=""? Number(parseFloat($("#salary_detail_wage_rate").val())).toFixed(2) : 0
  pack      =$("#salary_detail_status").val() !=""? Number(parseFloat($("#salary_detail_status").val())).toFixed(2) : 1
  extra      =$("#salary_detail_extra").val() !=""? Number(parseFloat($("#salary_detail_extra").val())).toFixed(2) : 0
  quantity  =$("#salary_detail_quantity").val()  !=""? Number(parseFloat($("#salary_detail_quantity").val())).toFixed(2) : 0
  staff_count=parseFloat($("#staff_id_count").val())+1
  $("#salary_detail_amount").val(wage_rate*quantity);
  $(".salary_detail_amount").text(Number(wage_rate*quantity).toFixed(2));
  $(".salary_detail_stock").text(Number((pack*quantity)-extra).toFixed(2));
  $("#OtherStaffAmount").text(Number((wage_rate*quantity)/staff_count).toFixed(2));

}

function ajaxCall(path, params, return_method, methodType){
  $.ajax({
    url: path,
    type: methodType,
    dataType: 'json',
    data: params,
    error: function(jqXHR, textStatus, errorThrown) {
      $("#cutoffModel").hide("model");
      $("#cutoffModel").removeClass("readyForEnter");
      $("#ajaxError").show("model");
    },
    success: function(data) {
      return_method(data)
    }
  });
  return result;
}

function kachiRate()
{
  raw_rate=$("#salary_details_raw_rate").val();
  $(".raw-wage-rate").val(raw_rate);
  daily_book_update();
}

function paakiRate(){
  wage_rate=$("#salary_details_wage_rate").val();
  $(".wage-rate").val(wage_rate);
  daily_book_update();
}

function debitRate()
{
  raw_rate=$("#salary_details_raw_rate").val();
  $(".raw-wage-rate").val(raw_rate);
  cal_product_quantity();
}

function creditRate(){
  wage_rate=$("#salary_details_wage_rate").val();
  $(".wage-rate").val(wage_rate);
  cal_product_quantity();
}

function giftRate()
{
  gift_rate=$("#salary_details_gift_rate").val();
  $(".gift-rate").val(gift_rate);
  daily_book_update();
}

function covergeRate()
{
  coverge_rate=$("#salary_details_coverge_rate").val();
  $(".coverge-rate").val(coverge_rate);
  daily_book_update();
}
function daily_bhari_book_update(){
  var total_bricks=0;
  var total_tiles=0;
  var i;
  for (i = 0; i < $(".raw-quantity").length; i++) {
    var bricks=0;
    var tiles=0;
    if(!isNaN(parseFloat($(".raw-quantity")[i].value)))
    {bricks=parseFloat($(".raw-quantity")[i].value);}
    if(!isNaN(parseFloat($(".quantity")[i].value)))
    {tiles=parseFloat($(".quantity")[i].value);}
    total_bricks+=bricks;
    total_tiles+=tiles;
  }
  $("#total_bhari_bricks").text(total_bricks);
  $("#total_tiles").text(total_tiles);

}

function daily_book_update(){
  $("#total_difference").val(0.00);
  $("#total_wast").val(0.00);
  $("#ready_for_khakar").val(0.00);
  $("#kachi_rate").val(0.00);
  $("#paaki_rate").val(0.00);
  kachi_total=0;
  paaki_total=0;
  wast_total=0;
  kachi_rate_total=0;
  paaki_rate_total=0;
  total_diff_total=0;
  ready_for_khakar_total=0;
  gift_rate_total=0;
  coverge_rate_total=0;
  pay_total=0;
  total_pay_total=0;
  total_gift_total=0
  total_coverge_total=0;


  var i;
  for (i = 0; i < $(".raw-quantity").length; i++) {
    if(!isNaN(parseFloat($(".raw-quantity")[i].value)) || !isNaN(parseFloat($(".quantity")[i].value)))
    {
      raw_quantity=parseFloat(+Number($(".raw-quantity")[i].value));
      quantity=parseFloat(+Number($(".quantity")[i].value));
      wast=parseFloat(+Number($(".wast")[i].value));
      raw_wage_rate=parseFloat(+Number($(".raw-wage-rate")[i].value));
      wage_rate=parseFloat(+Number($(".wage-rate")[i].value));
      gift_rate=parseFloat(+Number($(".gift-rate")[i].value));
      coverge_rate=parseFloat(+Number($(".coverge-rate")[i].value));
      difference=parseFloat(raw_quantity-quantity);
      ready_for_khakar=parseFloat(quantity-wast);
      kachi_rate_pay=parseFloat(raw_quantity*raw_wage_rate);
      paaki_rate_pay=parseFloat(quantity*wage_rate);
      total_gift=parseFloat(raw_quantity*gift_rate);
      coverge_quantity= quantity==0 ? raw_quantity : quantity
      total_coverge=parseFloat(coverge_quantity*coverge_rate);
      $('.row-difference')[i].innerText=Number(difference).toFixed(0);
      $(".for-khakar")[i].innerText=Number(ready_for_khakar).toFixed(0);
      $("input.pay")[i].value=Number(kachi_rate_pay).toFixed(0);
      $("input.remaning_quanity")[i].value=quantity;
      $("input.total_pay")[i].value=Number(paaki_rate_pay).toFixed(0);
      $("span.pay")[i].innerText=Number(kachi_rate_pay).toFixed(0);
      $("span.total_pay")[i].innerText=Number(paaki_rate_pay).toFixed(0);
      $("input.total_gift")[i].value=Number(total_gift).toFixed(0);
      $("input.total_coverge")[i].value=Number(total_coverge).toFixed(0);
      $("span.total_gift")[i].innerText=Number(total_gift).toFixed(0);
      $("span.total_coverge")[i].innerText=Number(total_coverge).toFixed(0);
      kachi_total+=raw_quantity;
      paaki_total+=quantity;
      wast_total+=wast;
      kachi_rate_total+=raw_wage_rate;
      paaki_rate_total+=wage_rate;
      gift_rate_total+=gift_rate;
      coverge_rate_total+=coverge_rate;
      total_diff_total+=difference;
      ready_for_khakar_total+=ready_for_khakar;
      pay_total+=kachi_rate_pay;
      total_pay_total+=paaki_rate_pay;
      total_gift_total+=total_gift;
      total_coverge_total+=total_coverge;
    }
  }
  $("#kachi_total").text(Number(kachi_total).toFixed(0));
  $("#paaki_total").text(Number(paaki_total).toFixed(0));
  $("#wast_total").text(Number(wast_total).toFixed(0));
  $("#kachi_rate_total").text(Number(kachi_rate_total).toFixed(0));
  $("#paaki_rate_total").text(Number(paaki_rate_total).toFixed(0));
  $("#gift_rate_total").text(Number(gift_rate_total).toFixed(0));
  $("#coverge_rate_total").text(Number(coverge_rate_total).toFixed(0));
  $("#total_diff_total").text(Number(total_diff_total).toFixed(0));
  $("#ready_for_khakar_total").text(Number(ready_for_khakar_total).toFixed(0));
  $("#pay_total").text(Number(pay_total).toFixed(0));
  $("#total_pay_total").text(Number(total_pay_total).toFixed(0));
  $("#total_gift_total").text(Number(total_gift_total).toFixed(0));
  $("#total_coverge_total").text(Number(total_coverge_total).toFixed(0));

  $("#total_difference")[0].innerText=total_diff_total;
  $("#total_wast")[0].innerText=wast_total;
  $("#ready_for_khakar")[0].innerText=ready_for_khakar_total;
  $("#kachi_rate")[0].innerText=Number(pay_total).toFixed(0);
  $("#paaki_rate")[0].innerText=Number(total_pay_total).toFixed(0);

}

function adjustmentUpdate(val){
  $("#total_wage").val(0)
  var i;
  var total_wage_detail=0;
  var total_gift_rate=0;
  var total_coverge_rate=0;
  for (i = 0; i < $(".rate").length; i++) {
    if(!isNaN(parseFloat($(".rate")[i].value)) || !isNaN(parseFloat($(".gift_rate")[i].value)) || !isNaN(parseFloat($(".coverge_rate")[i].value)))
    {
      wage_debit = Math.round($('.quantity')[i].value*($('.rate')[i].value/1000)/100)*100;
      $('.wage_debit')[i].value = wage_debit;
      $("span.wage_debit_span")[i].innerText = wage_debit;
      gift_rate = Math.round($('.quantity')[i].value*($('.gift_rate')[i].value/1000)/10)*10;
      $('.gift_rate_total')[i].value = gift_rate;
      $("span.gift_rate_total_span")[i].innerText = gift_rate;
      coverge_rate = Math.round($('.quantity')[i].value*($('.coverge_rate')[i].value/1000)/10)*10;
      $('.coverge_rate_total')[i].value = coverge_rate;
      $("span.coverge_rate_total_span")[i].innerText = coverge_rate;
      total_wage_detail += wage_debit;
      total_gift_rate += gift_rate;
      total_coverge_rate += coverge_rate;
    }
  }
  $('#total_wage').text(Math.ceil(total_wage_detail/100)*100);
  $('#total_gift').text(Math.ceil(total_gift_rate/10)*10);
  $('#total_coverge').text(Math.ceil(total_coverge_rate/10)*10);

  $('#user_created_at_gteq').val( $('#created_at_gteq').val() );
  $('#user_created_at_lteq').val( $('#created_at_lteq').val() );
}

function adjustmentKhakarUpdate(val){
  $("#total_wage").val(0)
  var i;
  var total_wage_detail=0;
  for (i = 0; i < $(".rate").length; i++) {
    if(!isNaN(parseFloat($(".rate")[i].value)) )
    {
      wage_debit = Math.round($('.quantity')[i].value*($('.rate')[i].value/1000)/100)*100;
      $('.wage_debit')[i].value = wage_debit;
      $("span.wage_debit_span")[i].innerText = wage_debit;
      total_wage_detail += wage_debit;
    }
  }
  $('#total_wage').text(Math.ceil(total_wage_detail/100)*100);
  $('#user_created_at_gteq').val( $('#created_at_gteq').val() );
  $('#user_created_at_lteq').val( $('#created_at_lteq').val() );
}

function daily_debit_rate()
{
  raw_rate=$("#salary_details_raw_rate").val();
  $(".raw-wage-rate").val(raw_rate);
  daily_book_khakar_update();
}
function daily_credit_rate()
{
  wage_rate=$("#salary_details_wage_rate").val();
  $(".wage-rate").val(wage_rate);
  daily_book_khakar_update();
}

function daily_book_khakar_quantity(id){
  console.log(id)
}

function daily_book_khakar_update(){
  khakar_quantity_total=0;
  difference_total=0;
  wast_total=0;
  khakar_remaning_total=0;
  debit_rate_total =0;
  credit_rate_total = 0;
  debit_total_total = 0;
  credit_total_total = 0;
  pather_remaning_quanity_total = 0;
  pather_remaning_quanity_min_total = 0;
  khakar_kat = parseFloat(+Number($("#salary_details_kat").val()));
  var i;
  for (i = 0; i < $(".raw-quantity").length; i++) {
    if(!isNaN(parseFloat($(".raw-quantity")[i].value)))
    {
      khakar_quantity = parseFloat(+Number($(".raw-quantity")[i].value));
      pather_remaning_quanity = parseFloat(+Number($("span.remaning_quanity")[i].innerText));
      wast = parseFloat(+Number($(".wast")[i].value));
      if ($("#pos_setting_sys_type").val() =='Factory')
      {
        debit_rate = parseFloat(+Number($(".raw-wage-rate")[i].value));
        credit_rate = parseFloat(+Number($(".wage-rate")[i].value));
      }else {
        debit_rate = parseFloat(+Number($(".raw-wage-rate")[i].value))/1000;
        credit_rate = parseFloat(+Number($(".wage-rate")[i].value))/1000;
      }
      difference = parseFloat(khakar_quantity/100*khakar_kat);
      khakar_remaning = khakar_quantity-difference-wast
      debit_total = debit_rate*khakar_remaning
      credit_total = credit_rate*khakar_remaning
      pather_remaning_quanity_totals = pather_remaning_quanity-khakar_quantity
      $("input.pay")[i].value=Number(debit_total).toFixed(0);
      $("span.pay")[i].innerText=Number(debit_total).toFixed(0);
      $("input.total_pay")[i].value=Number(credit_total).toFixed(0);
      $("span.total_pay")[i].innerText=Number(credit_total).toFixed(0);
      $("input.quantity")[i].value=Number(khakar_remaning).toFixed(0);
      $("span.quantity")[i].innerText=Number(khakar_remaning).toFixed(0);
      $("span.kat_quantity")[i].innerText=Number(difference).toFixed(0);
      $("span.pather_remaning_quanity")[i].innerText=Number(pather_remaning_quanity_totals).toFixed(0);
      $("input.pather_remaning_quanity")[i].value=Number(pather_remaning_quanity_totals).toFixed(0);
      khakar_quantity_total+=khakar_quantity;
      difference_total+=difference;
      wast_total+=wast;
      khakar_remaning_total+=khakar_remaning;
      debit_rate_total+=debit_rate;
      credit_rate_total+=credit_rate;
      debit_total_total+=debit_total;
      credit_total_total+=credit_total;
      pather_remaning_quanity_total+=pather_remaning_quanity;
      pather_remaning_quanity_min_total+=pather_remaning_quanity_totals;
    }
  }
  $("#khakar_remaning_min_total").text(Number(pather_remaning_quanity_min_total).toFixed(0));
  $("#item_quantity_total").text(Number(pather_remaning_quanity_total).toFixed(0));
  $("#quantity_total").text(Number(khakar_quantity_total).toFixed(0));
  $("#difference_total").text(Number(difference_total).toFixed(0));
  $("#wast_total").text(Number(wast_total).toFixed(0));
  $("#khakar_remaning_total").text(Number(khakar_remaning_total).toFixed(0));
  $("#debit_rate_total").text(Number(debit_rate_total).toFixed(0));
  $("#credit_rate_total").text(Number(credit_rate_total).toFixed(0));
  $("#debit_total_total").text(Number(debit_total_total).toFixed(0));
  $("#credit_total_total").text(Number(credit_total_total).toFixed(0));
}


function daily_book_khakar_stock_update(){
  khakar_quantity_total=0;
  difference_total=0;
  wast_total=0;
  khakar_remaning_total=0;
  debit_rate_total =0;
  credit_rate_total = 0;
  debit_total_total = 0;
  credit_total_total = 0;
  pather_remaning_quanity_total = 0;
  pather_remaning_quanity_min_total = 0;
  khakar_kat = parseFloat(+Number($("#salary_details_kat").val()));
  var i;
  for (i = 0; i < $(".raw-quantity").length; i++) {
    if(!isNaN(parseFloat($(".raw-quantity")[i].value)))
    {
      khakar_quantity = parseFloat(+Number($(".raw-quantity")[i].value));
      wast = parseFloat(+Number($(".wast")[i].value));
      debit_rate = parseFloat(+Number($(".raw-wage-rate")[i].value))/1000;
      credit_rate = parseFloat(+Number($(".wage-rate")[i].value))/1000;
      difference = parseFloat(khakar_quantity/100*khakar_kat);
      khakar_remaning = khakar_quantity-difference-wast
      debit_total = debit_rate*khakar_remaning
      credit_total = credit_rate*khakar_remaning
      $("input.pay")[i].value=Number(debit_total).toFixed(0);
      $("span.pay")[i].innerText=Number(debit_total).toFixed(0);
      $("input.total_pay")[i].value=Number(credit_total).toFixed(0);
      $("span.total_pay")[i].innerText=Number(credit_total).toFixed(0);
      $("input.quantity")[i].value=Number(khakar_remaning).toFixed(0);
      $("span.quantity")[i].innerText=Number(khakar_remaning).toFixed(0);
      $("span.kat_quantity")[i].innerText=Number(difference).toFixed(0);
      khakar_quantity_total+=khakar_quantity;
      difference_total+=difference;
      wast_total+=wast;
      khakar_remaning_total+=khakar_remaning;
      debit_rate_total+=debit_rate;
      credit_rate_total+=credit_rate;
      debit_total_total+=debit_total;
      credit_total_total+=credit_total;
    }
  }
  $("#quantity_total").text(Number(khakar_quantity_total).toFixed(0));
  $("#difference_total").text(Number(difference_total).toFixed(0));
  $("#wast_total").text(Number(wast_total).toFixed(0));
  $("#khakar_remaning_total").text(Number(khakar_remaning_total).toFixed(0));
  $("#debit_rate_total").text(Number(debit_rate_total).toFixed(0));
  $("#credit_rate_total").text(Number(credit_rate_total).toFixed(0));
  $("#debit_total_total").text(Number(debit_total_total).toFixed(0));
  $("#credit_total_total").text(Number(credit_total_total).toFixed(0));
}


function block_type_quantity_update(value,id){
  quantity=$('#'+value).text();
  make_id="#production_cycle_production_blocks_attributes_"+id.split("production_cycle_production_blocks_attributes_")[1].split("production_block_type_id")[0]
  $(make_id+"bricks_quantity").val(quantity);
  $(make_id+"tiles_quantity").val(0);
  if(quantity>0){
    $(make_id+"tiles_quantity").attr('readonly', true);
    $(make_id+"bricks_quantity").attr('readonly', true);
  }else {
    $(make_id+"tiles_quantity").attr('readonly', false);
    $(make_id+"bricks_quantity").attr('readonly', false);
  }
  daily_bhari_book_update();
}

function nakasi_cost_calculation()
{
  nakasi_a_quantity=0
  nakasi_b_quantity=0
  var i;
  for (i = 0; i < $(".nakasi_a_quantity").length; i++) {
  	nakasi_a_quantity+=Number($(".nakasi_a_quantity")[i].value);
    nakasi_b_quantity+=Number($(".nakasi_b_quantity")[i].value);
    console.log(nakasi_a_quantity);
  	console.log(nakasi_b_quantity);
  }
}

function jalai_cost_calculation()
{
  quantity = Number($("#production_cycle_quantity").val()).toFixed(2);
  measurement_quantity = Number($('#measurement_quantity').val()).toFixed(2);
  lines = Number($("#production_cycle_lines").val()).toFixed(0);
  if(lines==1){
    lines=2;
  }

  total_bricks = Number($("#total_bricks").text()).toFixed(2);
  total_item_quantity = Number(quantity*measurement_quantity).toFixed(2);
  item_quantity_per_line = Number((quantity*measurement_quantity)/lines).toFixed(2);
  item_bricks = Number(total_bricks/total_item_quantity).toFixed(2);
  $("#item_quantity_per_line").text(Number(item_quantity_per_line).toFixed(2)+' kg');
  $("#total_item_quantity").text(Number(total_item_quantity).toFixed(2));
  $("#item_bricks").text(Number(item_bricks*1000).toFixed(2));
  $("#production_cycle_item_quantity_per_line").val(item_quantity_per_line);
  $("#production_cycle_total_item_quantity").val(total_item_quantity);
  $("#production_cycle_per_ton_bricks").val(item_bricks*1000);

  $(".jalai_a_quantity").val(item_quantity_per_line);
  $(".jalai_b_quantity").val(item_quantity_per_line);
  // $(".jalai_a_quantity").attr('readonly', true);
  // $(".jalai_b_quantity").attr('readonly', true);
  jalai_a_quantity=0
  jalai_b_quantity=0
  jalai_a_cost=0
  jalai_b_cost=0
  total_bricks_quantity=0
  var i;
  total_bricks=Number($("#total_bricks_hidden").text());
  for (i = 0; i < $(".jalai_b_quantity").length; i++) {
    id=$(".jalai_b_quantity")[i].id
    make_id="#production_cycle_production_blocks_attributes_"+id.split("production_cycle_production_blocks_attributes_")[1].split("jalai_b_quantity")[0]
    cost=$("#purchase_"+$(make_id+"purchase_sale_detail_id").val()).text();
    bricks_quantity=Number($(make_id+"bricks_quantity").text());
    tiles_quantity=Number($(make_id+"tiles_quantity").text());
    if ($(make_id+"pre_status").text() == "Uncomplete"){
      if ($(make_id+"production_status").val() == "Uncomplete") {
        total=(bricks_quantity+(tiles_quantity/2));
        total_bricks_quantity+=total/2
      }
      else {
        total=(bricks_quantity+(tiles_quantity/2))/2;
        total_bricks_quantity+=total
      }
    }
    else {
      if ($(make_id+"production_status").val() == "Uncomplete") {
        total=(bricks_quantity+(tiles_quantity/2))/2;
        total_bricks_quantity+=total
      }
      else {
        total=(bricks_quantity+(tiles_quantity/2));
        total_bricks_quantity+=total
      }
    }
    $("#total_bricks").text(total_bricks_quantity);
    $("#production_cycle_total_bricks").val(total_bricks_quantity);
    if($(make_id+"pre_status").text() == "Uncomplete"){
      if($(make_id+"production_status").val() == "Uncomplete")
      {
        a = Number($(make_id+"jalai_a").val());
        a_quantity = Number($(make_id+"jalai_a_quantity").val());
        $(make_id+"jalai_a").val(a);
        $(make_id+"jalai_a_quantity").val(a_quantity);
        $(make_id+"jalai_b").val(0);
        $(make_id+"jalai_b_quantity").val(0);
      }
      else {
        a = Number($(make_id+"jalai_a").val());
        a_quantity = Number($(make_id+"jalai_a_quantity").val());
        $(make_id+"jalai_b").val(0);
        $(make_id+"jalai_b_quantity").val(0);
      }
    }
    else{
      if($(make_id+"production_status").val() == "Uncomplete" && window.location.href.toString().split("edit").length>1)
      {
        a = Number($(make_id+"jalai_a").val());
        a_quantity = Number($(make_id+"jalai_a_quantity").val());
        $(make_id+"jalai_a").val(a+a);
        $(make_id+"jalai_a_quantity").val(a_quantity+a_quantity);
        $(make_id+"jalai_b").val(0);
        $(make_id+"jalai_b_quantity").val(0);
      }
      else if($(make_id+"production_status").val() == "Uncomplete" && window.location.href.toString().split("new").length>1)
      {
        a = Number($(make_id+"jalai_a").val());
        a_quantity = Number($(make_id+"jalai_a_quantity").val());
        $(make_id+"jalai_a").val(a);
        $(make_id+"jalai_a_quantity").val(a_quantity);
        $(make_id+"jalai_b").val(0);
        $(make_id+"jalai_b_quantity").val(0);
      }
      else {
        a = Number($(make_id+"jalai_a").val());
        a_quantity = Number($(make_id+"jalai_a_quantity").val());
        $(make_id+"jalai_b").val(a);
        $(make_id+"jalai_b_quantity").val(a_quantity);
      }
    }
    jalai_a_quantity=Number($(make_id+"jalai_a_quantity").val());
    jalai_b_quantity=Number($(make_id+"jalai_b_quantity").val());
    $(make_id+"jalai_a").val(cost*jalai_a_quantity)
    $(make_id+"jalai_b").val(cost*jalai_b_quantity)
    $(".jalai_a").attr('readonly', true);
    $(".jalai_b").attr('readonly', true);
    jalai_a_cost+=Number($(".jalai_a")[i].value);
    jalai_b_cost+=Number($(".jalai_b")[i].value);
  }
  total_cost=jalai_a_cost+jalai_b_cost
  cost_per_line=total_cost/lines
  total_bricks = Number($("#total_bricks").text()).toFixed(2);
  $("#per_line").text(Number(cost_per_line).toFixed(2));
  $("#total_cost").text(Number(total_cost).toFixed(2));
  per_product_cost = Number(total_cost/total_bricks).toFixed(2);
  thousand_cost = Number(per_product_cost*1000).toFixed(2);
  item_bricks = Number(total_bricks/total_item_quantity).toFixed(2);
  $("#per_product_cost").text(Number(per_product_cost).toFixed(2));
  $("#thousand_cost").text(Number(thousand_cost).toFixed(2));
  $("#item_bricks").text(Number(item_bricks*1000).toFixed(2));
  $("#production_cycle_cost_per_line").val(cost_per_line);
  $("#production_cycle_total_cost").val(total_cost);
  $("#production_cycle_per_product_cost").val(per_product_cost);
  $("#production_cycle_per_thousand_product_cost").val(thousand_cost);
}

function all_lines_update(){
    id=$(".jalai_b_quantity")[0].id
    make_id="#production_cycle_production_blocks_attributes_"+id.split("production_cycle_production_blocks_attributes_")[1].split("jalai_b_quantity")[0]
}

function lines_update(value,id){

  make_id="#production_cycle_production_blocks_attributes_"+id.split("production_cycle_production_blocks_attributes_")[1].split("production_status")[0]
  bricks_quantity=Number($(make_id+"bricks_quantity").text());
  tiles_quantity=Number($(make_id+"tiles_quantity").text());
  total=(bricks_quantity+(tiles_quantity/2))/2
  total_bricks=Number($("#total_bricks").text());
  if ($(make_id+"pre_status").text() == "Uncomplete"){
    if (value == "Uncomplete"){
      if ($("#production_cycle_lines").val()=='2' || $("#production_cycle_lines").val()>'1');
      $("#production_cycle_lines").val(Number($("#production_cycle_lines").val())-1);
      $("#total_bricks").text(total_bricks-total);
    }
    else{
      $("#production_cycle_lines").val(Number($("#production_cycle_lines").val())+1);
      $("#total_bricks").text(total_bricks+total);
    }
  }
  else {
    if (value == "Uncomplete"){
      if ($("#production_cycle_lines").val()=='2' || $("#production_cycle_lines").val()>'1')
      $("#production_cycle_lines").val(Number($("#production_cycle_lines").val())-1);
      $("#total_bricks").text(total_bricks-total);
    }
    else{
      $("#production_cycle_lines").val(Number($("#production_cycle_lines").val())+1);
      $("#total_bricks").text(total_bricks+total);
    }
  }
  jalai_cost_calculation();
}

function lines_cost_update(){
  var i;
  for (i = 0; i < $(".jalai_a").length; i++) {
    id=$(".jalai_a")[i].id
    make_id="#production_cycle_production_blocks_attributes_"+id.split("production_cycle_production_blocks_attributes_")[1].split("jalai_a")[0]
    cost=$("#purchase_"+$(make_id+"purchase_sale_detail_id").val()).text();
    jalai_a_quantity=Number($(make_id+"jalai_a_quantity").val());
    jalai_b_quantity=Number($(make_id+"jalai_b_quantity").val());
    $(make_id+"jalai_a").val(cost*jalai_a_quantity)
    $(make_id+"jalai_b").val(cost*jalai_b_quantity)
    $(".jalai_a").attr('readonly', true);
    $(".jalai_b").attr('readonly', true);
  }
  jalai_cost_calculation();
}

function rohraQuantity()
{
  $("#bricks").text(Number($("#brick_quantity").text())-$("#daily_book_brick_rohra").val());
  $("#tile").text(Number($("#tile_quantity").text())-$("#daily_book_tile_rohra").val());
}


function cal_product_quantity(){
  total_count=0;
  total_credit=0;
  total_debit=0;
  total = $(".pro-check").length/$(".wage-rate").length;
  var total_array=[]
  var i;
  var j;
  for (i=0;i<total;i++)
  {
    total_array.push(0)
  }
  for(i=0;i< $(".raw-wage-rate").length;i++)
  {
    var count=0;
    for (j = 0; j < total; j++) {
      count+=Number($("#daily_book_salary_details_attributes_"+i+"_salary_detail_product_quantities_attributes_"+j+"_quantity").val());
      total_array[j]+=Number($("#daily_book_salary_details_attributes_"+i+"_salary_detail_product_quantities_attributes_"+j+"_quantity").val());
      $("#total_product_quantity_"+(j+1)).text(total_array[j]);
    }
    debit_rate = Number($("#daily_book_salary_details_attributes_"+i+"_raw_wage_rate").val())
    credit_rate = Number($("#daily_book_salary_details_attributes_"+i+"_wage_rate").val())
    debit_rate_total = ((count.toFixed(0)/1000)*(debit_rate*1000)).toFixed(2);
    credit_rate_total = ((count.toFixed(0)/1000)*(credit_rate*1000)).toFixed(2);
    $("#daily_book_salary_details_attributes_"+i+"_wage_debit").val(debit_rate_total);
    $("#daily_book_salary_details_attributes_"+i+"_amount").val(credit_rate_total);
    $("span.pay")[i].innerText=debit_rate_total;
    $("span.total_pay")[i].innerText=credit_rate_total;
    $("span.quantity_product")[i].innerText=count;
    total_count+=Number(count);
    total_credit+=Number(credit_rate_total);
    total_debit+=Number(debit_rate_total);
  }
  $("#total_debit").text(Math.round(total_debit));
  $("#total_credit").text(Math.round(total_credit));
  $("#total_quantity_product").text(Math.round(total_count));
  // console.log(count);

}


function set_return_sale_total(value){
  $(value).closest('div').next().next().find('.total-cost-price').val(parseFloat(value.value)*parseFloat($(value).closest('div').next().find('.cost-price').val()));
}





function price_in_words(price,position) {
  price = parseInt(price);

  var sglDigit = ["Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"],
    dblDigit = ["Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"],
    tensPlace = ["", "Ten", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"],
    handle_tens = function(dgt, prevDgt) {
      return 0 == dgt ? "" : " " + (1 == dgt ? dblDigit[prevDgt] : tensPlace[dgt])
    },
    handle_utlc = function(dgt, nxtDgt, denom) {
      return (0 != dgt && 1 != nxtDgt ? " " + sglDigit[dgt] : "") + (0 != nxtDgt || dgt > 0 ? " " + denom : "")
    };

  var str = "",
    digitIdx = 0,
    digit = 0,
    nxtDigit = 0,
    words = [];
  if (price += "", isNaN(parseInt(price))) str = "";
  else if (parseInt(price) > 0 && price.length <= 10) {
    for (digitIdx = price.length - 1; digitIdx >= 0; digitIdx--) switch (digit = price[digitIdx] - 0, nxtDigit = digitIdx > 0 ? price[digitIdx - 1] - 0 : 0, price.length - digitIdx - 1) {
      case 0:
        words.push(handle_utlc(digit, nxtDigit, ""));
        break;
      case 1:
        words.push(handle_tens(digit, price[digitIdx + 1]));
        break;
      case 2:
        words.push(0 != digit ? " " + sglDigit[digit] + " Hundred" + (0 != price[digitIdx + 1] && 0 != price[digitIdx + 2] ? " and" : "") : "");
        break;
      case 3:
        words.push(handle_utlc(digit, nxtDigit, "Thousand"));
        break;
      case 4:
        words.push(handle_tens(digit, price[digitIdx + 1]));
        break;
      case 5:
        words.push(handle_utlc(digit, nxtDigit, "Lakh"));
        break;
      case 6:
        words.push(handle_tens(digit, price[digitIdx + 1]));
        break;
      case 7:
        words.push(handle_utlc(digit, nxtDigit, "Crore"));
        break;
      case 8:
        words.push(handle_tens(digit, price[digitIdx + 1]));
        break;
      case 9:
        words.push(0 != digit ? " " + sglDigit[digit] + " Hundred" + (0 != price[digitIdx + 1] || 0 != price[digitIdx + 2] ? " and" : " Crore") : "")
    }
    str = words.reverse().join("")
  } else str = "";
  $("#"+position).html(str);

  return str

}
