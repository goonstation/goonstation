//[{seq: 'BD7', stable:'No', trans: 'No'}, {seq: '325', stable:'Yes', trans: 'Yes'}, {seq: '325AE6', stable:'No', trans: 'No'}, {seq: '4A0', stable:'Yes', trans: 'Yes'}, {seq: '4A0EB8', stable:'No', trans: 'No'}, {seq: '4A0AE6', stable:'Yes', trans: 'Yes'}, {seq: '4A0AE6EB8', stable:'Yes', trans: 'Yes'}, {seq: '795', stable:'Yes', trans: 'Yes'}, {seq: 'FF9', stable:'Yes', trans: 'Yes'}, {seq: '067', stable:'Yes', trans: 'Yes'}]
( function (window, document) {
	var knownList = [];
	var lastKey = "";
	var descendingSort = false;

	function initializeScript(listOfStuff) {
		knownList = listOfStuff;
		fuckYouByondBrowser();
	}

	function fuckYouByondBrowser() {

		if(!document.getElementsByClassName) {
			document.getElementsByClassName = function (cl) {
				var pattern, i,
				d = document,
				results = [];

				if(d.querySelectorAll) {
					return d.querySelectorAll("." + cl);
				}
				if (d.evaluate) {
					pattern = ".//*[contains(concat(' ', @class, ' '),' " + cl + " ')]";
					elements = d.evaluate(pattern, d, null, 0, null);
					while ((i = elements.iterateNext())) {
						results.push(i)
					}
				} else {
					elements = document.getElementsByTagName("*");
					pattern = new RegExp("(^|\\s)" + cl + "(\\s|$)");
					for(i = 0; i < elements.length; i++) {
						if ( pattern.test(elements[i].className) ) {
							results.push(elements[i]);
						}
					}
				}
				return results;
			};
		}
	}

	function sortOn(key) {

		var sortFunc;
		if (lastKey != key || descendingSort) {
			sortFunc = function(a, b){
										var ret = 0;
										if(a[key] > b[key]){
											ret = 1;
										} else if (a[key] < b[key]) {
											ret = -1;
										}
										return ret;
									};
			descendingSort = false;
		} else {
			sortFunc = function(a, b){
									var ret = 0;
									if(a[key] < b[key]){
										ret = 1;
									} else if (a[key] > b[key]) {
										ret = -1;
									}
									return ret;
								};
			descendingSort = true;
		}
		knownList.sort(sortFunc);
		lastKey = key;

	}

	function display() {
		var i,
			html = '',
			tableSpan = document.getElementById("listing");

		for (i = 0; i < knownList.length; i++) {
			var listing = knownList[i];
			html += "<tr>"
			for (k in listing) {
				var data = listing[k]
				if (k != "seq")
					data = prettifyYesNo(data);
				else
					data = insertSpaces(data);
				html += "<td>" + data + "</td>";
			}
			html +="</tr>"
		}
		html = '<table>' + getTableHeader() + html + '</table>';
		tableSpan.innerHTML = html;
		setListeners();
	}

	function prettifyYesNo(text) {
		if (text == "Yes") {
			text = "<span style='font-weight:bold;color:#0C0;'>" + text + "</span>";
		} else {
			text = "<span style='font-weight:bold;color:#D00;'>" + text + "</span>";
		}
		return text
	}

	// This inserts spaces between the individual segments of a sequence, so the list is less of an eyesore
	function insertSpaces(text) {
		var text2 = "";
		for(i = 0; i < text.length; i++)
		{
			text2 += text.substring(i*3, (i+1)*3);
			text2 += " ";
		}
		return text2;
	}

	function getTableHeader() {

		var thead = '<tr>';

		var headerObj = {
			seq: "Sequence",
			stable: "Stable",
			trans: "Trans"
		};

		var sortChar = '\u2193';
		if (descendingSort) {sortChar = '\u2191';}

		for (k in headerObj) {
			var v = headerObj[k]

			var out = v;
			if (k == lastKey) {
				out += ' ' + sortChar;
			}
			thead += '<th><a href = "#" class="tableHeader" id="' + k + '">' + out + '</a></th>';
		}
		return thead + '</tr>';

	}

	function setListeners() {
		var targets = document.getElementsByClassName("tableHeader");

		for(var i = 0; i < targets.length; i++){
			var a = targets[i];
			var func = function(){sortAndDisplay(this.id); return false;};

			a.onclick = func; //Do I give any fucks about how ancient this is? Nope. Sure don't.
		}
	}

	function sortAndDisplay(key) {
		sortOn(key);
		display();
	}

	window.initializeScript = initializeScript;
	window.sortAndDisplay = sortAndDisplay;
})(window, document);
