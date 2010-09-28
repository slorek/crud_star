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
		
		// Enable date/time pickers
		$('input.datetime').datetimepicker({dateFormat: 'MM dd, yy'});
		$('input.date').datepicker({dateFormat: 'MM dd, yy'});
		
	});
}