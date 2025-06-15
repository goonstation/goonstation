chui = {
	minWidth: 200,
	minHeight: 200,
	flags: 0,
};

var escaper = encodeURIComponent || escape;
var decoder = decodeURIComponent || unescape;

var CHUI_FLAG_SIZABLE = 1;
var CHUI_FLAG_MOVABLE = 2;
var CHUI_FLAG_FADEIN = 4;
var CHUI_FLAG_CLOSABLE = 8;

chui.setCookie = function (cname, cvalue, exdays) {
	cvalue = escaper(cvalue);
	var d = new Date();
	d.setTime(d.getTime() + exdays * 24 * 60 * 60 * 1000);
	var expires = "expires=" + d.toUTCString();
	var cookie = cname + "=" + cvalue + "; " + expires + "; path=/";
	document.cookie = cookie;
};

chui.getCookie = function (cname) {
	var name = cname + "=";
	var ca = document.cookie.split(";");
	for (var i = 0; i < ca.length; i++) {
		var c = ca[i];
		while (c.charAt(0) == " ") {
			c = c.substring(1);
		}
		if (c.indexOf(name) === 0) {
			return decoder(c.substring(name.length, c.length));
		}
	}
	return "";
};

chui.setLabel = function (id, label) {
	$("a")
		.contents()
		.filter(function () {
			return this.nodeType === 3;
		})[0].textContent = label;
};

chui.bycall = function (method, data) {
	data = data || {};
	data._cact = method;
	const Http = new XMLHttpRequest();
	Http.open("GET", "byond://?src=" + chui.window + "&" + $.param(data));
	Http.send();
};

chui.close = function () {
	document.location =
		"byond://winset?command=" + escaper(".chui-close " + chui.window);
	chui.winset("is-visible", "false");
};

chui.winset = function (key, value) {
	document.location =
		"byond://winset?" + chui.window + "." + key + "=" + escape(value);
};

chui.winsets = function (kvs) {
	document.location = "byond://winset?id=" + chui.window + "&" + $.param(kvs);
};

chui.setPos = function (x, y) {
	chui.winset("pos", x + "," + y);
};

chui.setSize = function (w, h) {
	chui.winset("size", w + "," + h);
};

chui.setPosSize = function (x, y, w, h) {
	document.location =
		"byond://winset?" +
		chui.window +
		".size=" +
		escape(w + "," + h) +
		"&" +
		chui.window +
		".pos=" +
		escape(x + "," + y);
};

chui.chatDebug = function (msg) {
	document.location =
		"byond://winset?command=" +
		escaper(".output browseroutput:output " + escaper(msg));
};

chui.initialize = function () {
	chui.data = {};
	$("meta").each(function () {
		var key = $(this).attr("name");
		if (key) {
			chui.data[key] = $(this).attr("value");
		}
	});

	chui.window = chui.data.ref; // BYOND reference to this window.
	chui.flags = Number(chui.data.flags); // Window flags. Look at top for more info.

	// Scrollbar
	$("#content").nanoScroller({ scrollTop: window.name });

	chui.winset("transparent-color", "#FF00E4"); // Sets the window transparent color for 1 bit transparency.

	// Window Movement
	////// ALIGNMENT

	// Save opening position
	var prevX = window.screenLeft;
	var prevY = window.screenTop;

	// If the offset data exists in a cookie, just get it from there, otherwise generate it
	var offsetCookie = chui.getCookie("chuiOffset");
	//prompt("cook" + offsetCookie, offsetCookie);
	if (offsetCookie) {
		var offsetData = $.parseJSON(offsetCookie);
		chui.offsetX = offsetData.offsetX;
		chui.offsetY = offsetData.offsetY;
	} //else // Mordent note: I'm like 95% sure that by commenting out the else but leaving the below section, it always runs and overwrites the cookie-set offsets
	{
		// Put the window at top left
		chui.setPos(0, 0);
		// Get any offsets still present
		chui.offsetX = window.screenLeft;
		chui.offsetY = window.screenTop;
	}

	// Clamp the window into the viewport
	var clampedX = prevX - chui.offsetX;
	var clampedY = prevY - chui.offsetY;
	clampedX = clampedX < chui.offsetX ? 0 : clampedX;
	clampedY = clampedY < chui.offsetY ? 0 : clampedY;

	// Save the offset data to a cookie
	if (!offsetCookie) {
		var cookieOffsetData = {
			offsetX: chui.offsetX,
			offsetY: chui.offsetY,
		};
		chui.setCookie("chuiOffset", JSON.stringify(cookieOffsetData), 0.333); // 0.333 days is approx 8 hour expiry
	}

	// Put the window back where it came from
	chui.setPos(clampedX, clampedY);

	/////// ALIGNMENT FIN
	//// Titlebar

	$("body").on("mousemove", "#titlebar", function (ev) {
		ev = ev || window.event;
		if (typeof chui.lastX === "undefined") {
			chui.lastX = ev.screenX;
			chui.lastY = ev.clientY;
		}
		if (chui.titlebarMousedown == 1) {
			var dx = ev.screenX - chui.lastX;
			var dy = ev.screenY - chui.lastY;
			dx += window.screenLeft - chui.offsetX;
			dy += window.screenTop - chui.offsetY;

			chui.setPos(dx, dy);
		}
		chui.lastX = ev.screenX;
		chui.lastY = ev.screenY;
	});
	$("body").on("mousedown", "#titlebar", function () {
		chui.titlebarMousedown = 1;
		if ($(this)[0].setCapture) {
			$(this)[0].setCapture();
		}
	});
	$("body").on("mouseup", "#titlebar", function () {
		chui.titlebarMousedown = 0;
		if ($(this)[0].releaseCapture) {
			$(this)[0].releaseCapture();
		}
	});

	//// FIN Titlebar
	//// Size handles

	if (chui.flags & (CHUI_FLAG_SIZABLE > 0)) {
		$("body").on("mousemove", "div.resizeArea", function (ev) {
			if (chui.resizeWorking) {
				return;
			}
			chui.resizeWorking = true;
			ev = ev || window.event;
			if (typeof chui.lastX === "undefined") {
				chui.lastX = ev.screenX - chui.offsetX;
				chui.lastY = ev.screenY - chui.offsetY;
			}
			if (chui.resizeMousedown == 1) {
				// TODO: Handle sizing under minimum and coming back up being funny.
				var width = document.body.offsetWidth;
				var height = document.body.offsetHeight;
				var rx = Number($(this).attr("rx"));
				var ry = Number($(this).attr("ry"));

				var dx = ev.screenX - chui.offsetX - chui.lastX;
				var dy = ev.screenY - chui.offsetY - chui.lastY;

				var newX = window.screenLeft - chui.offsetX;
				var newY = window.screenTop - chui.offsetY;

				var newW = width + dx * rx;
				if (rx == -1) {
					newX += dx;
				}
				var newH = height + dy * ry;
				if (ry == -1) {
					newY += dy;
				}

				newW = Math.max(chui.minWidth, newW);
				newH = Math.max(chui.minHeight, newH);

				chui.setPosSize(newX, newY, newW, newH);
			}
			chui.lastX = ev.screenX - chui.offsetX;
			chui.lastY = ev.screenY - chui.offsetY;

			chui.resizeWorking = false; //Prevent odd occasions where this gets called multiple times while working.
		});
		$("body").on("mousedown", "div.resizeArea", function () {
			chui.resizeMousedown = 1;
			if (this.setCapture) {
				this.setCapture();
			}
		});
		$("body").on("mouseup", "div.resizeArea", function () {
			chui.resizeMousedown = 0;
			if (this.releaseCapture) {
				this.releaseCapture();
			}
		});
	} else {
		$("div.resizeArea").remove();
	}

	// FIN Window Movement

	$("body").on("click", "a.button", function () {
		var info = null;
		try {
			info = this.dataset.info;
		} catch (err) {
			info = this.getAttribute("data-info");
		}
		chui.bycall("click", {
			id: this.id,
			data: info,
		});
	});

	$(".close").click(function () {
		if (chui.flags & CHUI_FLAG_FADEIN) {
			chui.fadeOut();
		} else {
			chui.close();
		}
	});
	$(".close").attr("href", "#");

	chui.bycall("register");

	if (chui.flags & CHUI_FLAG_FADEIN) {
		chui.fadeIn();
	}

	if (chui.data.needstitle) {
		$("#windowtitle").text($("title").text() || " ");
	}
};

chui.fadeIn = function () {
	var width = document.body.offsetWidth;
	var height = document.body.offsetHeight;

	var x = window.screenLeft - chui.offsetX;
	var y = window.screenTop - chui.offsetY;

	chui.setSize(width + 80, height + 80);
	chui.setPos(x - 40, y - 40);
	chui.winset("alpha", "0");
	setTimeout(function () {
		$({ foo: 0 }).animate(
			{ foo: 1 },
			{
				duration: 1000,
				step: function (val) {
					//prompt(""+val);
					var neg = 1 - val;
					chui.winsets({
						alpha: 255 * val,
						size: width + 80 * neg + "," + (height + 80 * neg),
						pos: x - 40 * neg + "," + (y - 40 * neg),
					});
				},
			},
		);
	}, 1000);
};

chui.fadeOut = function () {
	var width = document.body.offsetWidth;
	var height = document.body.offsetHeight;

	var x = window.screenLeft - chui.offsetX;
	var y = window.screenTop - chui.offsetY;
	$({ foo: 1 }).animate(
		{ foo: 0 },
		{
			duration: 1000,
			step: function (val) {
				//prompt(""+val);
				var neg = 1 - val;
				chui.winsets({
					alpha: 255 * val,
					size: width + 80 * neg + "," + (height + 80 * neg),
					pos: x - 40 * neg + "," + (y - 40 * neg),
				});
			},
			complete: chui.close,
		},
	);
};

chui.templateSet = function (id, value) {
	var templateItem = document.getElementById("chui-tmpl-" + id);
	if (!templateItem) {
		return;
	}
	templateItem.innerText = value;
};

chui.templateBulk = function (elements) {
	var els = JSON.parse(elements);
	if (!els) {
		return; // rude
	}
	for (var elem in els) {
		var element = document.getElementById("chui-tmpl-" + elem);
		if (element) {
			element.innerText = els[elem];
		}
	}
};

var activeRequests = [];
var reqID = 0;
chui.request = function (path, data, callback) {
	activeRequests.push({
		id: ++reqID,
		callback: callback,
	});
	data._id = reqID;
	data._path = path;
	chui.bycall("request", data);
};

function updateScroll() {
	window.name = $("#content")[0].nanoscroller.contentScrollTop;
}
window.addEventListener("beforeunload", updateScroll);
window.addEventListener("scroll", updateScroll);

$(chui.initialize);
