var triggerError = attachErrorHandler('tooltipDebug', true, function(msg) {
	//I am sick and tired of the billions of absolutely useless error messages tooltips produce
	if (msg === 'Script error.') {
		return true;
	}
});
var animatePopup = window._animatePopup;

var escaper = encodeURIComponent || escape;
var decoder = decodeURIComponent || unescape;

function getParameterByName(name, params) {
	name = name.replace(/[\[\]]/g, '\\$&');
	var regex = new RegExp(name + '(=([^&;#]*)|&|#|$)');
	var results = regex.exec(params);
	if (!results) {
		return null;
	}
	if (!results[2]) {
		return '';
	}
	return decoder(results[2].replace(/\+/g, ' '));
}

function htmlEntities(str) {
	return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function htmlDecode(str) {
	return $('<textarea/>').html(str).text();
}

var tooltip = {
	loaded: false,
	mapInterface: {
		parent: '',
		control: '',
		helper: ''
	},
	map: null,
	tileSize: 32,
	interface: '',
	params: {},
	options: {},
	pinned: false,
	clientViewX: 0,
	clientViewY: 0,
	padding: 2,
	maxWidth: 0,
	$docBody: null,
	$wrap: null,
	$content: null,
	$title: null,
	$body: null,
	mapOffsets: { //Where the map is located on the screen
		x: 0,
		y: 0,
		w: 0,
		h: 0
	},
	screenProperties: { //What the user's screen looks like (not counting offsets like OS toolbars)
		x: 0,
		y: 0
	},
	showDelay: 100,
	showDelayInt: 0,
	interrupt: false,

	init: function(screen, tileSize, tInterface, map) {
		tooltip.screenProperties = screen;
		tooltip.tileSize = parseInt(tileSize);
		tooltip.interface = tInterface;

		try {
			tooltip.mapInterface = $.parseJSON(map);
		} catch (e) {
			triggerError('(init map) JSON parse error for: ' + map + '. ' + e);
			return;
		}

		tooltip.maxWidth = parseInt(tooltip.$wrap.css('max-width'));
	},

	getMapControlFor: function(control) {
		var string = tooltip.mapInterface.parent + '.';
		switch(control) {
			case 'map':
				string += tooltip.mapInterface.control;
				break;

			case 'helper':
				string += tooltip.mapInterface.helper;
				break;
		}
		return string;
	},

	removeDelays: function() {
		clearTimeout(tooltip.showDelayInt);
	},

	unInterrupt: function() {
		tooltip.interrupt = false;
		tooltip.removeDelays();
	},

	setInterrupt: function(which) {
		tooltip.interrupt = which === '1';
	},

	hide: function() {
		tooltip.removeDelays();
		animatePopup.stop();
		window.location = '?src=' + window.tooltipRef + ';action=hide;force=1';
	},

	log: function(text) {
		window.location = '?src=' + window.tooltipRef + ';action=log&msg='+escaper(text);
	},

	debugLog: function(text) {
		if (window.tooltipDebug) {
			tooltip.log(text);
		}
	},

	show: function(docWidth, docHeight, posX, posY) {
		if (tooltip.interrupt) {
			return tooltip.unInterrupt();
		}

		//Show the thing
		window.location = 'byond://winset?id='+tooltip.interface+';size='+docWidth+'x'+docHeight+';pos='+posX+','+posY+';alpha=255';

		//Animate in if set
		if (tooltip.options.hasOwnProperty('transition') && animatePopup.isValidAnimation(tooltip.options.transition)) {
			animatePopup.run(tooltip.options.transition, {
				logger: tooltip.log, //DEBUG
				interface: tooltip.interface,
				duration: 500,
				complete: function() {
					tooltip.debugLog(tooltip.options.transition + ' animation complete');
				}
			});
		}

		//On an appropriate keypress, move focus back to the map
		$(window).off('keypress').one('keypress', function(e) {
			if (!$(e.target).is('input, textarea, select, option, button')) {
				window.location = 'byond://winset?'+tooltip.getMapControlFor('map')+'.focus=true';
			}
		});

		if (tooltip.pinned) {
			var $closeTip = $('.close-tip');
			$closeTip.show().off('click').one('click', function(e) {
				e.preventDefault();
				tooltip.debugLog('tooltip hide called from click event');
				tooltip.hide();
			});

			//Clicking on stuff should switch focus back to the map so the player can move etc
			$(window).off('click').on('click', function(e) {
				if (!$(e.target).is('input, textarea, select, option, button')) {
					window.location = 'byond://winset?'+tooltip.getMapControlFor('map')+'.focus=true';
				}
			});
		} else {
			tooltip.$content.off('mouseover').one('mouseover', function() {
				tooltip.debugLog('tooltip hide called from mouseover event');
				tooltip.hide();
			});
		}
	},

	position: function(params) {
		if (typeof params !== undefined && params) {
			try {
				tooltip.params = $.parseJSON(params);
			} catch (e) {
				triggerError('(position params) JSON parse error for: ' + params + '. ' + e);
				return;
			}
		}

		//Get the real icon size according to the client view
		var mapWidth 		= tooltip.map.viewSize.x,
			mapHeight 		= tooltip.map.viewSize.y,
			tilesShownX		= (tooltip.clientViewX * 2) + 1,
			tilesShownY		= (tooltip.clientViewY * 2) + 1,
			realIconSizeX	= mapWidth / tilesShownX,
			realIconSizeY	= mapHeight / tilesShownY,
			resizeRatioX	= realIconSizeX / tooltip.tileSize,
			resizeRatioY	= realIconSizeY / tooltip.tileSize,
			//Calculate letterboxing offsets
			leftOffset		= (tooltip.map.size.x - mapWidth) / 2,
			topOffset		= (tooltip.map.size.y - mapHeight) / 2;

		//Parse out the tile and cursor locations from params (e.g. "icon-x=32;icon-y=29;screen-loc=3:10,15:29")
		var cursor = tooltip.params.cursor;
		var iconX = parseInt(getParameterByName('icon-x', cursor));
		var iconY = parseInt(getParameterByName('icon-y', cursor));
		var screenLoc = getParameterByName('screen-loc', cursor);

		if (!iconX || !iconY || !screenLoc) {return false;} //Sometimes screen-loc is never sent ahaha fuck you byond

		//screen-loc has special byond formatting
		screenLoc = screenLoc.split(',');
		if (screenLoc.length < 2) {return false;}
		var left = screenLoc[0];
		var top = screenLoc[1];
		if (!left || !top) {return false;}
		screenLoc = left.split(':');
		left = parseInt(screenLoc[0]);
		var enteredX = parseInt(screenLoc[1]);
		screenLoc = top.split(':');
		top = parseInt(screenLoc[0]);
		var enteredY = parseInt(screenLoc[1]);

		//Handle special cases (for fuck sake)
		if (tooltip.options.hasOwnProperty('special')) {
			if (tooltip.options.special === 'pod') {
				top--; //Pods do some weird funky shit with view and well just trust me that this is needed
			}
		}

		var yloc = top;

		//Handle manually set offsets (whether to adjust the tooltip along an axis by a pixel amount)
		if (tooltip.options.hasOwnProperty('offset')) {
			if (tooltip.options.offset.hasOwnProperty('x')) {
				var manualOffsetX = parseInt(tooltip.options.offset.x);
				leftOffset = leftOffset + (manualOffsetX * resizeRatioX);
				tooltip.debugLog('Manually adjusted leftOffset by ' + manualOffsetX + ' amount. Real pixel offset value: ' + (manualOffsetX * resizeRatioX));
			}
			if (tooltip.options.offset.hasOwnProperty('y')) {
				var manualOffsetY = parseInt(tooltip.options.offset.y);
				topOffset = topOffset + (manualOffsetY * resizeRatioY);
				tooltip.debugLog('Manually adjusted topOffset by ' + manualOffsetY + ' amount. Real pixel offset value: ' + (manualOffsetY * resizeRatioY));
			}
		}

		//Clamp values
		left = (left < 0 ? 0 : (left > tilesShownX ? tilesShownX : left));
		top = (top < 0 ? 0 : (top > tilesShownY ? tilesShownY : top));

		//Calculate where on the screen the popup should appear (below the hovered tile)
		var posX = Math.round(((left - 1) * realIconSizeX) + leftOffset + tooltip.padding); //-1 to position at the left of the target tile
		var posY = Math.round(((tilesShownY - top + 1) * realIconSizeY) + topOffset + tooltip.padding); //+1 to position at the bottom of the target tile

		var docWidth  = 0,
			docHeight = 0;

		tooltip.$wrap.attr('style', ''); //reset

		//We're forcing a certain size
		if (tooltip.options.hasOwnProperty('size') && typeof tooltip.options.size === 'string') {
			var size = tooltip.options.size.split('x');
			var widthString = size[0].toLowerCase();
			var heightString = size[1].toLowerCase();
			docWidth = widthString === 'auto' ? tooltip.$wrap.outerWidth() : parseInt(size[0]);
			docHeight = heightString === 'auto' ? tooltip.$wrap.outerHeight() : parseInt(size[1]);

			if (widthString !== 'auto') {
				tooltip.$wrap.css('min-width', docWidth);
			}

		//Otherwise, auto-size according to content
		} else {
			//the +2 is to fix some incredibly strange text wrapping bug that occurs AFTER sizing is complete
			docWidth = tooltip.$wrap.outerWidth() + 2;
			docHeight = tooltip.$wrap.outerHeight();
		}

		//Apply our sizing
		tooltip.$wrap.attr('style', 'width: ' + docWidth + 'px; height: ' + docHeight + 'px;');

		//Handle special flags
		if (tooltip.params.hasOwnProperty('flags') && tooltip.params.flags.length > 0) {
			var alignment = 'bottom';
			if ($.inArray('top', tooltip.params.flags) !== -1) { //TOOLTIP_TOP
				alignment = 'top';
				posY = (posY - docHeight) - realIconSizeY - (tooltip.padding * 2);
			}
			if ($.inArray('top2', tooltip.params.flags) !== -1) { //TOOLTIP_TOP_2 (give 1 tile of margin if tooltipping something at the bottom of view  (hud))
				alignment = 'top';
				posY = (posY - docHeight) - realIconSizeY - (tooltip.padding * 2);
				if (yloc<=1){
					posY = posY - (realIconSizeY)
				}
			}
			if ($.inArray('right', tooltip.params.flags) !== -1) { //TOOLTIP_RIGHT
				alignment = 'right';
				posX = posX + realIconSizeX;
				posY = posY - realIconSizeY;
			}
			if ($.inArray('left', tooltip.params.flags) !== -1) { //TOOLTIP_LEFT
				alignment = 'left';
				posX = posX - docWidth - (tooltip.padding * 2);
				posY = posY - realIconSizeY;
			}
			if ($.inArray('center', tooltip.params.flags) !== -1) { //TOOLTIP_CENTER
				if (alignment === 'bottom' || alignment === 'top') { //Horizontal centering
					posX = (posX + (realIconSizeX / 2)) - (docWidth / 2);
					if (posX < tooltip.padding) {
						posX = tooltip.padding;
					}
				} else { //Vertical centering
					var gap = realIconSizeY - docHeight;
					if (gap > 0) {
						posY = posY + (gap / 2);
					}
				}
			}
		}

		//Handle window offsets
		posX = posX + tooltip.mapOffsets.x - tooltip.screenProperties.x;
		posY = posY + tooltip.mapOffsets.y - tooltip.screenProperties.y;

		var boundaryY = tooltip.map.size.y + (tooltip.mapOffsets.y - tooltip.screenProperties.y);
		if (posY + docHeight > boundaryY) { //Is the bottom edge below the window? Snap it up if so
			posY = (posY - docHeight) - realIconSizeY - tooltip.padding;
		}

		var boundaryX = tooltip.map.size.x + (tooltip.mapOffsets.x - tooltip.screenProperties.x);
		if (posX + docWidth > boundaryX) { //Is the right edge outside the map area? Snap it back left if so
			posX = posX - ((posX + docWidth) - boundaryX) - (tooltip.padding * 2);
		}

		tooltip.debugLog('Position called. Width: ' + docWidth + '. Height: ' + docHeight + '. PosX: ' + posX + '. PosY: ' + posY);
		tooltip.show(docWidth, docHeight, posX, posY);
	},

	changeContent: function(title, content) {
		tooltip.options.title = title;
		tooltip.options.content = content;

		tooltip.$content.empty();

		if (typeof title !== 'undefined') {
			tooltip.$title = $('<h1>', {'class': 'title', html: title});
			tooltip.$content.append(tooltip.$title);
		}

		if (typeof content !== 'undefined') {
			tooltip.$body = $('<div>', {html: content});
			tooltip.$content.append(tooltip.$body);
		}

		//Images affect sizing, so we have to wait until they all load first
		tooltip.showDelayInt = tooltip.$content.waitForImages(function() {
			tooltip.showDelayInt = setTimeout(function() {
				tooltip.position();
			}, tooltip.showDelay);
		});
	},

	updateCallback: function(map) {
		if (typeof map === 'undefined' || !map) {return false;}

		tooltip.map = {
			size: map[tooltip.getMapControlFor('helper')+'.size'],
			viewSize: map[tooltip.getMapControlFor('map')+'.view-size']
		};

		try {
			tooltip.mapOffsets = $.parseJSON(map[tooltip.getMapControlFor('helper')+'.saved-params']);
		} catch (e) {
			triggerError('(updateCallback helper saved-params) JSON parse error for: ' + map[tooltip.getMapControlFor('helper')+'.saved-params'] + '. ' + e);
			return;
		}

		tooltip.debugLog('updateCallback called. map: '+JSON.stringify(map)+'. params: '+JSON.stringify(tooltip.params)+'. clientViewX: '+tooltip.clientViewX+'. clientViewY: '+tooltip.clientViewY+
				'. title: '+htmlEntities(tooltip.options.title)+'. theme: '+tooltip.options.theme + '. interrupt: ' + tooltip.interrupt);

		//Some reset stuff to avoid fringe issues with sizing
		window.location = 'byond://winset?id='+tooltip.interface+';pos='+tooltip.map.viewSize.x+',0;size=999x999;alpha=0';

		tooltip.$docBody.attr('class', tooltip.options.theme + (tooltip.pinned ? ' pinned' : ''));
		tooltip.$wrap.attr('style', '');
		tooltip.changeContent(tooltip.options.title, tooltip.options.content); //calls position, which calls show
	},

	update: function(params, options, clientViewX, clientViewY, stuck) {
		try {
			tooltip.params = $.parseJSON(params);
		} catch (e) {
			triggerError('(update params) JSON parse error for: ' + params + '. ' + e);
			return;
		}

		if (tooltip.params.hasOwnProperty('init')) {
			tooltip.init(tooltip.params.init.screen, tooltip.params.init.iconSize, tooltip.params.init.window, tooltip.params.init.map);
		}

		try {
			tooltip.options = $.parseJSON(options);
		} catch (e) {
			triggerError('(update options) JSON parse error for: ' + options + '. ' + e);
			return;
		}

		tooltip.removeDelays();
		tooltip.interrupt = false;
		tooltip.clientViewX = parseInt(clientViewX);
		tooltip.clientViewY = parseInt(clientViewY);
		tooltip.pinned = stuck === '1' ? true : false;

		//Go get the map details
		window.location = 'byond://winget?callback='+tooltip.interface+':tooltip.updateCallback;id='+tooltip.getMapControlFor('map')+','+tooltip.getMapControlFor('helper')+';property=pos,size,view-size,saved-params';
	},
};

//WE READY YO
$(window).on('load', function() {
	if (tooltip.loaded === false) {
		tooltip.loaded = true;
		tooltip.debugLog('JS loaded, calling topic show');
		window.location = '?src=' + window.tooltipRef + ';action=show';

		tooltip.$docBody = $('body');
		tooltip.$wrap = $('#wrap');
		tooltip.$content = $('#content');
	}
});
