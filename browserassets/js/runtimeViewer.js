var triggerError = attachErrorHandler('runtimeViewer', true);
var decoder = decodeURIComponent || unescape;

$(document).ready(function() {
	var runtimes = null;
	var loading = true;
	var viewingDetails = false;
	var occurrences = {};

	var $wrap = $('#runtime-wrap');
	var $header = $('#runtime-header');
	var $list = $('#runtime-list');
	var $details = $('#runtime-details');


	/***********************
	* METHODS
	***********************/

	//At some point the json is gonna be fucked up ok
	function parseRuntimes(json) {
		try {
			runtimes = $.parseJSON(json);
		} catch(e) {
			triggerError('JSON parse error: ' + e + '. For runtime data: ' + json);
			return
		}
	}

	//Actually builds the main list of runtimes, while building secondary datasets at the same time
	function buildView() {
		var count = 0;
		occurrences = {};
		$list.empty();

		$.each(runtimes, function(key, run) {
			var row = null;

			if (run.invalid) {
				row = $('<li>', {'class': 'runtime runtime-invalid well'}).append(
					$('<span>', {'class': 'seen', text: '[' + run.seen + ']'}),
					' Invalid exception in error handler: ',
					$('<span>', {'class': 'name', text: run.name})
				);

			} else {
				row = $('<li>', {'class': 'runtime well'}).append(
					$('<span>', {'class': 'seen', text: '[' + run.seen + ']'}),
					' In ',
					$('<span>', {'class': 'file', text: run.file}),
					', line ',
					$('<span>', {'class': 'line', text: run.line}),
					': ',
					$('<span>', {'class': 'name', text: run.name})
				);

				if (run.desc) {
					row.append(
						$('<span>', {'class': 'desc', html: run.desc})
					);
				}

				if (run.usr) {
					row.append(
						$('<span>', {'class': 'usr', html: run.usr})
					);
				}

				var uid = run.file + run.line + run.name;
				if (typeof occurrences[uid] !== 'undefined') {
					occurrences[uid]++;
				} else {
					occurrences[uid] = 1;
				}
			}

			$list.prepend(row);
			count++;
		});

		$header.find('.total-runtimes').text(count);
		$('#content').nanoScroller(); //refreshes scrollbar for new height
		loading = false;
	}

	//Byond hits this via error_handling.dm
	window.refreshRuntimes = function(json) {
		if (!json) {
			triggerError('Got no json in refreshRuntimes');
			return;
		}

		loading = true;
		parseRuntimes(decoder(json));
		buildView();
	};


	/***********************
	* EVENTS
	***********************/

	//Trigger refresh
	$header.on('click', '.refresh', function() {
		if (loading) {
			return;
		}

		if (viewingDetails) {
			$details.hide();
			$list.show();
			viewingDetails = false;
		}

		$list.html(
			$('<li>', {'class': 'loading well', text: 'Loading...'})
		);

		window.location = '?action=getRuntimeData';
	});

	//Show details view
	$list.on('click', '.runtime:not(.runtime-invalid)', function() {
		if (loading || viewingDetails) {
			return;
		}

		viewingDetails = true;

		var $this = $(this);
		var file = $this.find('.file').text();
		var line = $this.find('.line').text();
		var name = $this.find('.name').text();
		var usr = $this.find('.usr').text();

		var uid = file + line + name;

		var details = '<h2><i class="icon-pencil"></i> Summary</h2>';
		details += 'This runtime has occurred <strong>' + occurrences[uid] + '</strong> times.<br><br>';

		details += '<table><tbody>';
		details += '<tr><td><strong>File</strong></td><td>' + file + '</td></tr>';
		details += '<tr><td><strong>Line</strong></td><td>' + line + '</td></tr>';
		details += '<tr><td><strong>Error</strong></td><td>' + name + '</td></tr>';
		details += '<tr><td><strong>Usr</strong></td><td>' + usr + '</td></tr>';
		details += '</tbody></table>';

		details += '<h2><i class="icon-code"></i> Description</h2>';
		details += '<pre>' + $this.find('.desc').html() + '</pre>';

		$details.find('.details').html(details);
		$list.hide();
		$details.show();
		$('#content').nanoScroller(); //refreshes scrollbar for new height
	});

	//Hide details view
	$details.on('click', '.back', function() {
		$details.hide();
		$list.show();
		$('#content').nanoScroller(); //refreshes scrollbar for new height
		viewingDetails = false;
	});


	/***********************
	* INIT
	***********************/

	window.location = '?action=getRuntimeData';
});
