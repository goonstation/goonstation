//DEBUG LOGGING
var escaper = encodeURIComponent || escape;
var decoder = decodeURIComponent || unescape;
window.onerror = function(msg, url, line, col, error) {
	if (document.location.href.indexOf("proc=debug") <= 0) {
		var extra = !col ? '' : ' | column: ' + col;
		extra += !error ? '' : ' | error: ' + error;
		extra += !navigator.userAgent ? '' : ' | user agent: ' + navigator.userAgent;
		var debugLine = 'Error: ' + msg + ' | url: ' + url + ' | line: ' + line + extra;
		window.location = '?action=ehjax&type=datum&datum=chatOutput&proc=debug&param[error]='+escaper(debugLine);
	}
	return true;
};

var setCookie = function(cname, cvalue, exdays) {
	cvalue = escaper(cvalue);
	var d = new Date();
	d.setTime(d.getTime() + (exdays*24*60*60*1000));
	var expires = 'expires='+d.toUTCString();
	document.cookie = cname + '=' + cvalue + '; ' + expires;
};

var getCookie = function(cname) {
	var name = cname + '=';
	var ca = document.cookie.split(';');
	for(var i=0; i < ca.length; i++) {
	var c = ca[i];
	while (c.charAt(0)==' ') c = c.substring(1);
		if (c.indexOf(name) === 0) {
			return decoder(c.substring(name.length,c.length));
		}
	}
	return '';
};

$(function() {
	//SETUP
	var chui = {
		'$chuiData' 		: $('#chuiData'),
		'window'			: null,
		'title'				: null,
		'content'			: null,
		'noResize'			: false,
		'noMinimize'		: false,
		'noClose'			: false,

		//Toolbar offsets
		'offsetX'			: 0,
		'offsetY'			: 0,

		//Titlebar
		'lastX'				: null,
		'lastY'				: null,
		'titlebarMousedown'	: 0,

		//Resizing
		'resizeMousedown'	: 0,
		'resizeWorking'		: false,
		'minWidth'			: 100,
		'minHeight'			: 100,
	};

	//Get the passed data
	if (chui.$chuiData.length) {
		chui.window = $('#chuiData').attr('data-window');
		chui.title = ($('#chuiData').is('[data-title]') ? $('#chuiData').attr('data-title') : '');
		chui.noResize = ($('#chuiData').is('[data-noresize]') ? true : false);
		chui.noMinimize = ($('#chuiData').is('[data-nominimize]') ? true : false);
		chui.noClose = ($('#chuiData').is('[data-noclose]') ? true : false);
	} else {
		//We can't go on without SOME data (this should never occur)
		return;
	}

	//Custom scrollbar
	$('#content').nanoScroller({
		//alwaysVisible: true,
	});

	//If we have a title
	if (chui.title.length) {
		document.title = chui.title;
		window.status = chui.title;
	}

	//TOOLBAR OFFSETS
	(function(window, chui) {
		//Check for offset cookie
		chui.offsetX = getCookie('windowOffsetX');
		chui.offsetY = getCookie('windowOffsetY');
		if (!chui.offsetX || !chui.offsetY) {
			//Save opening position
			var prevX = window.screenLeft;
			var prevY = window.screenTop;
			//Put the window at top left
			window.location = 'byond://winset?'+chui.window+'.pos=0,0';
			//Get any offsets still present
			chui.offsetX = window.screenLeft;
			chui.offsetY = window.screenTop;
			//Put the window back where it came from
			window.location = 'byond://winset?'+chui.window+'.pos=' + (prevX - chui.offsetX) + ',' + (prevY - chui.offsetY);
			//Save our offsets
			setCookie('windowOffsetX', chui.offsetX, 1);
			setCookie('windowOffsetY', chui.offsetY, 1);
		}
	})(window, chui);

	//MOVABLE WINDOWS
	$('body').on('mousemove', '#titlebar', function(ev) {
		ev = ev || window.event;
		if (!chui.lastX) {
			chui.lastX = ev.clientX;
			chui.lastY = ev.clientY;
		}
		if (chui.titlebarMousedown == 1) {
			var dx = (ev.clientX - chui.lastX);
			var dy = (ev.clientY - chui.lastY);
			chui.lastX = ev.clientX - dx;
			chui.lastY = ev.clientY - dy;
			dx += window.screenLeft - chui.offsetX;
			dy += window.screenTop - chui.offsetY;
			window.location = 'byond://winset?'+chui.window+'.pos=' + dx + ',' + dy;
		} else {
			chui.lastX = ev.clientX;
			chui.lastY = ev.clientY;
		}
	});
	$('body').on('mousedown', '#titlebar', function() {
		chui.titlebarMousedown = 1;
		if ($(this)[0].setCapture) {$(this)[0].setCapture();}
	});
	$('body').on('mouseup', '#titlebar', function() {
		chui.titlebarMousedown = 0;
		if ($(this)[0].releaseCapture) {$(this)[0].releaseCapture();}
	});

	//Titlebar Actions
	$('body').on('click', '#titlebar .actions a', function(e) {
		var type = $(this).attr('class');
		if (type == 'min') {
		} 
		else if (type == 'close') {
			//Fix for closing popups once lost connection. Also improves feeling of responsiveness.
			window.location = 'byond://winset?'+chui.window+'.is-visible=false';
		}
	});

	//RESIZE WINDOWS
	if (!chui.noResize) {
		$('body').on('mousemove', '#resizeArea', function(ev) {
			if (chui.resizeWorking) {return;}
			chui.resizeWorking = true;
			ev = ev || window.event;

			if (chui.resizeMousedown == 1) {
				var width = document.body.offsetWidth;
				var height = document.body.offsetHeight;
				width = (ev.clientX > width ? ev.clientX : width - (width - ev.clientX));
				height = (ev.clientY > height ? ev.clientY : height - (height - ev.clientY));
				if (width < chui.minWidth || height < chui.minHeight) { //Limit min dimensions
					chui.resizeWorking = false;
					return;
				}
				window.location = 'byond://winset?'+chui.window+'.size=' + width + 'x'+ height;
			}
			chui.resizeWorking = false;
		});
		$('body').on('mousedown', '#resizeArea', function() {
			chui.resizeMousedown = 1;
			if ($(this)[0].setCapture) {$(this)[0].setCapture();}
		});
		$('body').on('mouseup', '#resizeArea', function() {
			chui.resizeMousedown = 0;
			if ($(this)[0].releaseCapture) {$(this)[0].releaseCapture();}
		});
	}

	//Keep this last
	$('#content > .nano-content').focus();
});