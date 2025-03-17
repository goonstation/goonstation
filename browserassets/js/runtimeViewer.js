// var triggerError = attachErrorHandler('runtimeViewer', true);
var decoder = decodeURIComponent || unescape;

document.addEventListener('DOMContentLoaded', function() {
	var runtimes = null;
	var loading = true;
	var viewingDetails = false;
	var occurrences = {};

	var $wrap = document.querySelector('#runtime-wrap');
	var $header = document.querySelector('#runtime-header');
	var $list = document.querySelector('#runtime-list');
	var $details = document.querySelector('#runtime-details');

	/***********************
	* METHODS
	***********************/

	function parseRuntimes(json) {
		try {
			runtimes = JSON.parse(json);
		} catch (e) {
			triggerError('JSON parse error: ' + e + '. For runtime data: ' + json);
			return;
		}
	}

	function buildView() {
		var count = 0;
		occurrences = {};
		$list.innerHTML = '';

		Object.entries(runtimes).forEach(function([key, run]) {
			var row = document.createElement('li');
			if (run.invalid) {
				row.className = 'runtime runtime-invalid well';
				row.innerHTML = `<span class="seen">[${run.seen}]</span> Invalid exception in error handler: <span class="name">${run.name}</span>`;
			} else {
				row.className = 'runtime well';
				row.innerHTML = `
					<span class="seen">[${run.seen}]</span> In
					<span class="file">${run.file}</span>, line
					<span class="line">${run.line}</span>:
					<span class="name">${run.name}</span>
				`;
				if (run.desc) {
					var descSpan = document.createElement('span');
					descSpan.className = 'desc';
					descSpan.innerHTML = run.desc;
					row.appendChild(descSpan);
				}
				if (run.usr) {
					var usrSpan = document.createElement('span');
					usrSpan.className = 'usr';
					usrSpan.innerHTML = run.usr;
					row.appendChild(usrSpan);
				}

				var uid = run.file + run.line + run.name;
				occurrences[uid] = (occurrences[uid] || 0) + 1;
			}

			$list.insertBefore(row, $list.firstChild);
			count++;
		});

		$header.querySelector('.total-runtimes').textContent = count;
		if (window.nanoScroller) {
			document.querySelector('#content').nanoScroller();
		}
		loading = false;
	}

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

	$header.addEventListener('click', function(e) {
		if (e.target.closest('.refresh')) {
			if (loading) return;

			if (viewingDetails) {
				$details.style.display = 'none';
				$list.style.display = 'block';
				viewingDetails = false;
			}

			$list.innerHTML = '<li class="loading well">Loading...</li>';
			window.location = '?action=getRuntimeData';
		}
	});

	$list.addEventListener('click', function(e) {
		var target = e.target.closest('.runtime:not(.runtime-invalid)');
		if (!target || loading || viewingDetails) return;

		viewingDetails = true;

		var file = target.querySelector('.file').textContent;
		var line = target.querySelector('.line').textContent;
		var name = target.querySelector('.name').textContent;
		var usr = target.querySelector('.usr') ? target.querySelector('.usr').textContent : '';

		var uid = file + line + name;

		var details = '<h2><i class="icon-pencil"></i> Summary</h2>';
		details += `This runtime has occurred <strong>${occurrences[uid]}</strong> times.<br><br>`;

		details += '<table><tbody>';
		details += `<tr><td><strong>File</strong></td><td>${file}</td></tr>`;
		details += `<tr><td><strong>Line</strong></td><td>${line}</td></tr>`;
		details += `<tr><td><strong>Error</strong></td><td>${name}</td></tr>`;
		details += `<tr><td><strong>Usr</strong></td><td>${usr}</td></tr>`;
		details += '</tbody></table>';

		details += '<h2><i class="icon-code"></i> Description</h2>';
		details += `<pre>${target.querySelector('.desc') ? target.querySelector('.desc').innerHTML : ''}</pre>`;

		$details.querySelector('.details').innerHTML = details;
		$list.style.display = 'none';
		$details.style.display = 'block';
		if (window.nanoScroller) {
			document.querySelector('#content').nanoScroller();
		}
	});

	$details.addEventListener('click', function(e) {
		if (e.target.closest('.back')) {
			$details.style.display = 'none';
			$list.style.display = 'block';
			if (window.nanoScroller) {
				document.querySelector('#content').nanoScroller();
			}
			viewingDetails = false;
		}
	});

	/***********************
	* INIT
	***********************/
	window.location = '?action=getRuntimeData';
});
