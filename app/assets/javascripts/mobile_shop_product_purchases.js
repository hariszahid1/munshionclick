function mobile_serail_number_return(value){
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
  
  function mobile_serail_number_validation(e,value){
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
  function save_mobile_sale()
  {
    if($("#pos_setting_sys_type").val()=="MobileShop"){
      var serial_fields = $('.serial_no');
      var quantity_fields = $('.quantity-price')
      for(var i = 0; i < serial_fields.length; i++){
        var value = $.trim($(serial_fields[i]).val());
        var q_field = parseInt($(quantity_fields[i]).val())
        var s_field = $(serial_fields[i]).val().split('\n').filter(e => String(e).trim()).length
        if(q_field != s_field)
        {
          window.alert("Please Match the Quantity and Serial Number!")
          return false;
        }
      }
    }
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