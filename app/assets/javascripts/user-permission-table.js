$(document).on('ready turbolinks:load', function () {

	// for create
	$('#select-all-checkbox-of-create').on('click', function () {
		if (this.checked) {
			$('.can-create-checkbox').each(function () {
				this.checked = true;
			});
		} else {
			$('.can-create-checkbox').each(function () {
				this.checked = false;
			});
		}
	});

	$('.can-create-checkbox').on('click', function () {
		if ($('.can-create-checkbox:checked').length == $('.can-create-checkbox').length) {
			$('#select-all-checkbox-of-create').prop('checked', true);
		} else {
			$('#select-all-checkbox-of-create').prop('checked', false);
		}
	});

	// for read
	$('#select-all-checkbox-of-read').on('click', function () {
		if (this.checked) {
			$('.can-read-checkbox').each(function () {
				this.checked = true;
			});
		} else {
			$('.can-read-checkbox').each(function () {
				this.checked = false;
			});
		}
	});

	$('.can-read-checkbox').on('click', function () {
		if ($('.can-read-checkbox:checked').length == $('.can-read-checkbox').length) {
			$('#select-all-checkbox-of-read').prop('checked', true);
		} else {
			$('#select-all-checkbox-of-read').prop('checked', false);
		}
	});

	// for update
	$('#select-all-checkbox-of-update').on('click', function () {
		if (this.checked) {
			$('.can-update-checkbox').each(function () {
				this.checked = true;
			});
		} else {
			$('.can-update-checkbox').each(function () {
				this.checked = false;
			});
		}
	});

	$('.can-update-checkbox').on('click', function () {
		if ($('.can-update-checkbox:checked').length == $('.can-update-checkbox').length) {
			$('#select-all-checkbox-of-update').prop('checked', true);
		} else {
			$('#select-all-checkbox-of-update').prop('checked', false);
		}
	});

	// for delete
	$('#select-all-checkbox-of-delete').on('click', function () {
		if (this.checked) {
			$('.can-delete-checkbox').each(function () {
				this.checked = true;
			});
		} else {
			$('.can-delete-checkbox').each(function () {
				this.checked = false;
			});
		}
	});

	$('.can-delete-checkbox').on('click', function () {
		if ($('.can-delete-checkbox:checked').length == $('.can-delete-checkbox').length) {
			$('#select-all-checkbox-of-delete').prop('checked', true);
		} else {
			$('#select-all-checkbox-of-delete').prop('checked', false);
		}
	});

	// for hidden
	$('#select-all-checkbox-of-hidden').on('click', function () {
		if (this.checked) {
			$('.is-hidden-checkbox').each(function () {
				this.checked = true;
			});
		} else {
			$('.is-hidden-checkbox').each(function () {
				this.checked = false;
			});
		}
	});

	$('.is-hidden-checkbox').on('click', function () {
		if ($('.is-hidden-checkbox:checked').length == $('.is-hidden-checkbox').length) {
			$('#select-all-checkbox-of-hidden').prop('checked', true);
		} else {
			$('#select-all-checkbox-of-hidden').prop('checked', false);
		}
	});

	// for pdf
	$('#select-all-checkbox-of-can-download-pdf').on('click', function () {
		if (this.checked) {
			$('.can-download-pdf-checkbox').each(function () {
				this.checked = true;
			});
		} else {
			$('.can-download-pdf-checkbox').each(function () {
				this.checked = false;
			});
		}
	});

	$('.can-download-pdf-checkbox').on('click', function () {
		if ($('.can-download-pdf-checkbox:checked').length == $('.can-download-pdf-checkbox').length) {
			$('#select-all-checkbox-of-can-download-pdf').prop('checked', true);
		} else {
			$('#select-all-checkbox-of-can-download-pdf').prop('checked', false);
		}
	});

	// for csv
	$('#select-all-checkbox-of-can-download-csv').on('click', function () {
		if (this.checked) {
			$('.can-download-csv-checkbox').each(function () {
				this.checked = true;
			});
		} else {
			$('.can-download-csv-checkbox').each(function () {
				this.checked = false;
			});
		}
	});

	$('.can-download-csv-checkbox').on('click', function () {
		if ($('.can-download-csv-checkbox:checked').length == $('.can-download-csv-checkbox').length) {
			$('#select-all-checkbox-of-can-download-csv').prop('checked', true);
		} else {
			$('#select-all-checkbox-of-can-download-csv').prop('checked', false);
		}
	});

	// for eamil
	$('#select-all-checkbox-of-can-send-email').on('click', function () {
		if (this.checked) {
			$('.can-send-email-checkbox').each(function () {
				this.checked = true;
			});
		} else {
			$('.can-send-email-checkbox').each(function () {
				this.checked = false;
			});
		}
	});

	$('.can-send-email-checkbox').on('click', function () {
		if ($('.can-send-email-checkbox:checked').length == $('.can-send-email-checkbox').length) {
			$('#select-all-checkbox-of-can-send-email').prop('checked', true);
		} else {
			$('#select-all-checkbox-of-can-send-email').prop('checked', false);
		}
	});

	// for import export
	$('#select-all-checkbox-of-can-import-export').on('click', function () {
		if (this.checked) {
			$('.can-import-export-checkbox').each(function () {
				this.checked = true;
			});
		} else {
			$('.can-import-export-checkbox').each(function () {
				this.checked = false;
			});
		}
	});

	$('.can-import-export-checkbox').on('click', function () {
		if ($('.can-import-export-checkbox:checked').length == $('.can-import-export-checkbox').length) {
			$('#select-all-checkbox-of-can-import-export').prop('checked', true);
		} else {
			$('#select-all-checkbox-of-can-import-export').prop('checked', false);
		}
	});

	// for disabling entire tr
	$('.can-access-checkbox').on('click', function () {
		debugger;
		$(this).closest('tr').find('input').prop('disabled', !$(this).is(':checked'))
		$(this).closest('td').find('input').removeAttr('disabled')
	})
});
