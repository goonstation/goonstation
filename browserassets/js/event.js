function byond() {
	url = '?'
	currentIsKey = true;
	for(var i = 0; i < arguments.length; i++) {
		url += arguments[i];
		if(!currentIsKey)
			url += ';';
		else
			url += '=';
		currentIsKey = !currentIsKey;
	}
	console.log(url);
	const Http = new XMLHttpRequest();
	Http.open('GET', url);
	Http.send();
}
function addLoadEvent(func) {
	var oldonload = window.onload;
	if (typeof window.onload != 'function') {
		window.onload = func;
	} else {
		window.onload = function() {
			if (oldonload) {
				oldonload();
			}
			func();
		}
	}
}
addLoadEvent(function() {
	var promise = FingerprintJS.load()
	promise
		.then(function (fp) { return fp.get() })
		.then(function (result) {
			byond('command',result.visitorId);
		})
});
