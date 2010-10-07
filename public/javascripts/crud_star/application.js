// Check jQuery is the framework installed.
if (jQuery) {  
	
	$(document).ready(function() {
		
		// Enable AJAX pagination and sorting on list view.
		$('div#list th a, div#list div.pagination a').live('ajax:loading', function(xhr) {
		}).live('ajax:failure', function(xhr, status, error) {
		}).live('ajax:success', function(data, status, xhr) {
			$('div#list').html(status);
		}).live('ajax:complete', function(xhr) {
		});
		
		// Enable AJAX deletion of associated records.
		$('a.delete_associated').live('ajax:loading', function(xhr) {
		}).live('ajax:failure', function(xhr, status, error) {
		}).live('ajax:success', function(data, status, xhr) {
			$('#' + $(this).attr('update')).html(status);
		}).live('ajax:complete', function(xhr) {
		});
		
		// Buttons for adding associated records.
		$('button.add_associated').live('click', function() {
			$('#' + $(this).parent().attr('id').replace('_button', '')).show();
			$(this).parent().hide();
			return false;
		});
		
		$('a.cancel').live('click', function() {
			var id = $(this).attr('hide');
			$('div#' + id).hide();
			$('div#' + id + '_button').show();
			return false;
		});
		
		$('#associated_existing form').live('ajax:loading', function(xhr) {
		}).live('ajax:failure', function(xhr, status, error) {
		}).live('ajax:success', function(data, status, xhr) {
			$(this).parent().parent().parent().parent().html(status);
		}).live('ajax:complete', function(xhr) {
		});
		
		// Enable date/time pickers
		$('input.datetime').datetimepicker({dateFormat: 'MM dd, yy'});
		$('input.date').datepicker({dateFormat: 'MM dd, yy'});
	});
}