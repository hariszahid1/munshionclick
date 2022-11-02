$(document).ready(function () {
	// for create
	$('#select-all-checkbox-of-create').on('click',function(){
		debugger;
			if(this.checked){
					$('.can-create-checkbox').each(function(){
							this.checked = true;
					});
			}else{
					 $('.can-create-checkbox').each(function(){
							this.checked = false;
					});
			}
	});
	
	$('.can-create-checkbox').on('click',function(){
			if($('.can-create-checkbox:checked').length == $('.can-create-checkbox').length){
					$('#select-all-checkbox-of-create').prop('checked',true);
			}else{
					$('#select-all-checkbox-of-create').prop('checked',false);
			}
	});

	// for read
	$('#select-all-checkbox-of-read').on('click',function(){
		debugger;
			if(this.checked){
					$('.can-read-checkbox').each(function(){
							this.checked = true;
					});
			}else{
					 $('.can-read-checkbox').each(function(){
							this.checked = false;
					});
			}
	});
	
	$('.can-read-checkbox').on('click',function(){
			if($('.can-read-checkbox:checked').length == $('.can-read-checkbox').length){
					$('#select-all-checkbox-of-read').prop('checked',true);
			}else{
					$('#select-all-checkbox-of-read').prop('checked',false);
			}
	});

	// for update
	$('#select-all-checkbox-of-update').on('click',function(){
		debugger;
			if(this.checked){
					$('.can-update-checkbox').each(function(){
							this.checked = true;
					});
			}else{
					 $('.can-update-checkbox').each(function(){
							this.checked = false;
					});
			}
	});
	
	$('.can-update-checkbox').on('click',function(){
			if($('.can-update-checkbox:checked').length == $('.can-update-checkbox').length){
					$('#select-all-checkbox-of-update').prop('checked',true);
			}else{
					$('#select-all-checkbox-of-update').prop('checked',false);
			}
	});

	// for delete
	$('#select-all-checkbox-of-delete').on('click',function(){
		debugger;
			if(this.checked){
					$('.can-delete-checkbox').each(function(){
							this.checked = true;
					});
			}else{
					 $('.can-delete-checkbox').each(function(){
							this.checked = false;
					});
			}
	});
	
	$('.can-delete-checkbox').on('click',function(){
			if($('.can-delete-checkbox:checked').length == $('.can-delete-checkbox').length){
					$('#select-all-checkbox-of-delete').prop('checked',true);
			}else{
					$('#select-all-checkbox-of-delete').prop('checked',false);
			}
	});
});