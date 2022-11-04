/*
*
* FUNCTION AND VAR DECLARATIONS
*
*/

var triggerError = attachErrorHandler('chatDebug', true);

var escaper = encodeURIComponent || escape;
var decoder = decodeURIComponent || unescape;

//Globals
window.status = 'Output';
var $messages, $subOptions, $contextMenu, $filterMessages, $playMusic, $lastEntry;
var opts = {
    //General
    'messageCount': 0, //A count...of messages...
    'messageLimit': 4000, //A limit...for the messages...
    'scrollSnapTolerance': 20, //If within x pixels of bottom
    'clickTolerance': 10, //Keep focus if outside x pixels of mousedown position on mouseup
    'popups': 0, //Amount of popups opened ever
    'wasd': false, //Is the user in wasd mode?
    'chatMode': 'default', //The mode the chat is in
    'priorChatHeight': 0, //Thing for height-resizing detection
    'restarting': false, //Is the round restarting?
    'volume': 0.5,
    'lastMessage': '', //the last message sent to chatks
    'maxStreakGrowth': 20, //at what streak point should we stop growing the last entry?
	'messageClasses': ['admin','combat','radio','say','ooc','internal'],

    //Options menu
    'subOptionsLoop': null, //Contains the interval loop for closing the options menu
    'suppressOptionsClose': false, //Whether or not we should be hiding the suboptions menu
    'highlightTerms': [],
    'highlightLimit': 10,
    'highlightColor': '#FFFF00', //The color of the highlighted message
    'pingDisabled': false, //Has the user disabled the ping counter
    'twemoji': true, // whether Twemoji are used instead of the default emoji
    'messageLimitEnabled': true, // whether old messages get deleted

    //Ping display
    'pingCounter': 0, //seconds counter
    'pingLimit': 10, //seconds limit
    'pingTime': 0, //Timestamp of when ping sent
    'pongTime': 0, //Timestamp of when ping received
    'noResponse': false, //Tracks the state of the previous ping request
    'noResponseCount': 0, //How many failed pings?

    //Clicks
    'mouseDownX': null,
    'mouseDownY': null,
    'preventFocus': false, //Prevents switching focus to the game window

    //Admin stuff
    'adminLoaded': false, //Has the admin loaded his shit?

    //Client Connection Data
    'clientDataLimit': 5,
    'clientData': [],

    // Theme stuff
    'currentTheme': 'theme-default',
};

var themes = { // "css-class": "Option name"
    'theme-default': 'Windows 3.1 (default)',
    'theme-dark': 'Dark',
}

//Polyfill for fucking date now because of course IE8 and below don't support it
if (!Date.now) {
    Date.now = function now() {
        return new Date().getTime();
    };
}
//Polyfill for trim() (IE8 and below)
if (typeof String.prototype.trim !== 'function') {
    String.prototype.trim = function () {
        return this.replace(/^\s+|\s+$/g, '');
    };
}

//Actually turns the highlight term match into appropriate html
function createHighlightMarkup() {
    var extra = '';
    if (opts.highlightColor) {
        extra += ' style="background-color: '+opts.highlightColor+'"';
    }
    return '<span class="highlight"'+extra+'></span>';
}

// Get all child text nodes that match a regex pattern
function getTextNodes(elem, pattern) {
    var result = $([]);
    $(elem).contents().each(function(idx, child) {
        if (child.nodeType === 3 && /\S/.test(child.nodeValue) && child.nodeValue.search(pattern) !== -1) {
            result = result.add(child);
        }
        else {
            result = result.add(getTextNodes(child, pattern));
        }
    });
    return result;
}

// Highlight all text terms matching the registered regex patterns
function highlightTerms(el) {
    var pattern = new RegExp('(' + opts.highlightTerms.join('|') + ')', 'gi');
    var nodes = getTextNodes(el, pattern);

    nodes.each(function (idx, node) {
        var $node = $(node);
        var content = $node.text();
        var parent = $node.parent();
        var pre = $(node.previousSibling);
        $node.remove();
        content.split(pattern).forEach(function (chunk) {
            // Get our highlighted span/text node
            var toInsert = null;
            if (pattern.test(chunk)) {
                var tmpElem = $(createHighlightMarkup());
                tmpElem.text(chunk);
                toInsert = tmpElem;
            }
            else {
                toInsert = document.createTextNode(chunk);
            }

            // Insert back into our element
            if (pre.length == 0) {
                var result = parent.prepend(toInsert);
                pre = $(result[0].firstChild);
            }
            else {
                pre.after(toInsert);
                pre = $(pre[0].nextSibling);
            }
        });
    });
}

function handleStreakCounter($el) {
    var $streakCounter = $el.find('.streak-counter');

    if ($streakCounter.length) {
        //streak exists, increment
        var currentStreak = $streakCounter.data('count');
        currentStreak++;
        $streakCounter.text('x' + currentStreak).data('count', currentStreak);

        //grow the last entry along with the streak count
        if (currentStreak <= opts.maxStreakGrowth) {
            $el.css('font-size', (1 + (currentStreak * 0.05)) + 'em');
        }

    } else {
        //new streak, append
        $el.css('font-size', '1.1em').append($('<span>', {'class': 'streak-counter', text: 'x2'}).data('count', 2));
    }
}

// Wrap all emojis in an element so we can enforce styles
function parseEmojis(message) {
    if (opts.twemoji) {
      return twemoji.parse(message, {
        folder: 'svg',
        ext: '.svg'
      });
    }
    else {
      var pattern = /((?:\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+)/g;
      return message.replace(pattern, '<span class="emoji">$1</span>');
    }
}

//Send a message to the client
function output(message, group, skipNonEssential, forceScroll) {
    if (typeof message === 'undefined') {
        return;
    }
    if (typeof group === 'undefined') {
        group = '';
    }
    if (typeof skipNonEssential === 'string' || skipNonEssential instanceof String) {
        skipNonEssential = parseInt(skipNonEssential);
    }
    if (typeof forceScroll === 'string' || forceScroll instanceof String) {
        forceScroll = parseInt(forceScroll);
    }


    //Stuff we do along with appending a message
    var atBottom = false;
    if (!skipNonEssential) {
        var bodyHeight = $('body').height();
        var messagesHeight = $messages.outerHeight();
        var scrollPos = document.documentElement.scrollTop;

        //Should we snap the output to the bottom?
        if (bodyHeight + scrollPos >= messagesHeight - opts.scrollSnapTolerance || forceScroll) {
            atBottom = true;
            if ($('#newMessages').length) {
                $('#newMessages').remove();
            }
        //If not, put the new messages box in
        } else {
            if ($('#newMessages').length) {
                var messages = $('#newMessages .number').text();
                messages = parseInt(messages);
                messages++;
                $('#newMessages .number').text(messages);
                if (messages == 2) {
                    $('#newMessages .messageWord').append('s');
                }
            } else {
                $messages.after('<a href="#" id="newMessages"><span class="number">1</span> new <span class="messageWord">message</span> <i class="icon-double-angle-down"></i></a>');
            }
        }
    }

    //Url stuff
    // if (message.length && flag != 'preventLink') {
    //  message = anchorme(message);
    // }

    message = parseEmojis(message);

    opts.messageCount++;

    //Pop the top message off if history limit reached
    if (opts.messageCount >= opts.messageLimit && opts.messageLimitEnabled && !skipNonEssential) {
        $messages.children('div.entry:nth-child(-n+' + opts.messageLimit / 2 + ')').remove();
        opts.messageCount -= opts.messageLimit / 2; //I guess the count should only ever equal the limit
    }

    //message is identical to the last message, do the streak counter stuff
    if (message === opts.lastMessage) {
        handleStreakCounter($lastEntry);
        opts.messageCount--;
    } else {
        var entry = null;

        //message has a group identifier, check if it matches the group of the previous message
        if (group && $lastEntry.hasClass('hasGroup') && $lastEntry.data('group') === group) {

            entry = $lastEntry[0];
            var $streakCounter = $lastEntry.find('.streak-counter');
            var $streakClone = null;

            //save the streak counter before overwriting message
            if ($streakCounter.length) {
                $streakClone = $streakCounter.clone(true);
            }

            //replace the last message with the new one
            $lastEntry.html(message);

            //re-add the streak counter
            if ($streakClone) {
                $lastEntry.append($streakClone);
            }

            handleStreakCounter($lastEntry);
            opts.messageCount--; //we didn't actually add a message like we thought

        } else {

            //Actually append the message
            entry = document.createElement('div');
            entry.className = 'entry';

            if (group) {
                entry.className += ' hasGroup';
                entry.setAttribute('data-group', group);
			}

			//get classes from messages, compare if its in messageclasses, and if so, add to entry
			let addedClass = false;
			let $message = $('<span>'+message+'</span>');
			$.each(opts.messageClasses, function (key, value) {
				if ($message.find("." + value).length !== 0 || $message.hasClass(value)) {
					entry.className += ' ' + value;
					addedClass = true;
				}
			});
			// fallback, if no class found in the classlist
			if (!addedClass) {
				entry.className += ' misc';
			}

            entry.innerHTML = message;
            $lastEntry = $($messages[0].appendChild(entry));
            opts.lastMessage = message;
        }

        //Stuff we can do after the message shows can go here, in the interests of responsiveness
        if (opts.highlightTerms && opts.highlightTerms.length > 0) {
            highlightTerms(entry);
        }
    }

    //Actually do the snap
    if (atBottom && !skipNonEssential) {
        window.scrollTo(0, document.body.scrollHeight);
    }
}

//Receive a large number of messages all at once to cut down on round trips.
function outputBatch(messages) {
    var list = JSON.parse(messages);
    var bodyHeight = $('body').height();
    var messagesHeight = $messages.outerHeight();
    var scrollPos = document.documentElement.scrollTop;
    var shouldScroll = bodyHeight + scrollPos >= messagesHeight - opts.scrollSnapTolerance;

    for (var i = 0; i < list.length; i++) {
        output(list[i].message, list[i].group, i < list.length - 1, shouldScroll || list[i].forceScroll);
    }
}

//Runs a route within byond, client or server side. Consider this "ehjax" for byond.
function runByond(uri) {
    window.location = uri;
}
function setCookie(cname, cvalue, exdays) {
    cvalue = escaper(cvalue);
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = 'expires='+d.toUTCString();
    var cookie = cname + '=' + cvalue + '; ' + expires + '; path=/';
    document.cookie = cookie;
}

function getCookie(cname) {
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
}

function rgbToHex(R,G,B) {return toHex(R)+toHex(G)+toHex(B);}
function toHex(n) {
    n = parseInt(n,10);
    if (isNaN(n)) return '00';
    n = Math.max(0,Math.min(n,255));
    return '0123456789ABCDEF'.charAt((n-n%16)/16) + '0123456789ABCDEF'.charAt(n%16);
}

function changeMode(mode) {
    switch (mode) {
        case 'geocities':
            //switch in stylesheet
            opts.chatMode = mode;
            break;
        case 'console':

            opts.chatMode = mode;
            break;
        case 'default':
        default:
            //remove loaded stylesheet/s
            opts.chatMode = 'default';
    }
}


function changeTheme(theme) {
    var body = $('body');
    body.removeClass(opts.currentTheme);
    body.addClass(theme);
    opts.currentTheme = theme;
    setCookie('theme', theme, 365);
}

function handleClientData(ckey, ip, compid) {
    //byond sends player info to here
    var currentData = {'ckey': ckey, 'ip': ip, 'compid': compid};
    if (opts.clientData && !$.isEmptyObject(opts.clientData)) {
        runByond('?action=ehjax&type=datum&datum=chatOutput&proc=analyzeClientData&param[cookie]='+JSON.stringify({'connData': opts.clientData}));

        for (var i = 0; i < opts.clientData.length; i++) {
            var saved = opts.clientData[i];
            if (currentData.ckey == saved.ckey && currentData.ip == saved.ip && currentData.compid == saved.compid) {
                return; //Record already exists
            }
        }

        if (opts.clientData.length >= opts.clientDataLimit) {
            opts.clientData.shift();
        }
    } else {
        runByond('?action=ehjax&type=datum&datum=chatOutput&proc=analyzeClientData&param[cookie]=none');
    }

    //Update the cookie with current details
    opts.clientData.push(currentData);
    setCookie('connData', JSON.stringify(opts.clientData), 365);
}

//Server calls this on ehjax response
//Or, y'know, whenever really
function ehjaxCallback(data) {
    if (data == 'pong') {
        if (opts.pingDisabled) {return;}
        opts.pongTime = Date.now();
        var pingDuration = Math.ceil((opts.pongTime - opts.pingTime) / 2);
        $('#pingMs').text(pingDuration+'ms');
        pingDuration = Math.min(pingDuration, 255);
        var red = pingDuration;
        var green = 255 - pingDuration;
        var blue = 0;
        var hex = rgbToHex(red, green, blue);
        $('#pingDot').css('color', '#'+hex);
    } else if (data == 'roundrestart' || data == 'hardrestart') {
        opts.restarting = true;
        output('<div class="connectionClosed internal restarting">The connection has been closed because the server is restarting. Please wait while you automatically reconnect.</div>');

        //a hard reboot was triggered, so we do our own auto-reconnection
        if (data == 'hardrestart') {
            setTimeout(function() {
                runByond('byond://winset?command=.reconnect');
                output('<span class="internal boldnshit">Auto reconnecting from hard restart...</span>');
            }, 60000); //1 minute
        }
    } else if (data == 'stopaudio') {
        $('.dectalk').remove();
        if (window.HTMLAudioElement) {
            $playMusic.get(0).pause();
        }
    } else {
        //Oh we're actually being sent data instead of an instruction
        var dataJ;
        try {
            dataJ = $.parseJSON(data);
        } catch (e) {
            //But...incorrect :sadtrombone:
            triggerError('(ehjaxCallback data) JSON parse error for: ' + data + '. ' + e);
            return;
        }
        data = dataJ;

        if (data.clientData) {
            if (opts.restarting) {
                opts.restarting = false;
                $('.connectionClosed.restarting:not(.restored)').addClass('restored').text('The round restarted and you successfully reconnected!');
            }
            if (!data.clientData.ckey && !data.clientData.ip && !data.clientData.compid) {
                //TODO: Call shutdown perhaps
                return;
            } else {
                handleClientData(data.clientData.ckey, data.clientData.ip, data.clientData.compid);
            }
        } else if (data.changeTheme) {
            changeTheme(data.changeTheme);
        } else if (data.loadAdminCode) {
            if (opts.adminLoaded) {return;}
            var adminCode = data.loadAdminCode;
            $('body').append(adminCode);
            opts.adminLoaded = true;
        } else if (data.loadPerfMon) {
            if (opts.perfMonLoaded) {return;}
            var perfMon = data.loadPerfMon;
            $('body').append(perfMon);
            opts.perfMonLoaded = true;
        } else if (data.modeChange) {
            changeMode(data.modeChange);
        } else if (data.firebug) {
            if (data.trigger) {
                output('<span class="internal boldnshit">Loading firebug console, triggered by '+data.trigger+'...</span>');
            } else {
                output('<span class="internal boldnshit">Loading firebug console...</span>');
            }
            var firebugEl = document.createElement('script');
            firebugEl.src = 'https://getfirebug.com/firebug-lite-debug.js';
            document.body.appendChild(firebugEl);
        } else if (data.dectalk) {
            var message = '<audio class="dectalk" src="'+data.dectalk+'" autoplay="autoplay"></audio>';
            if (data.decTalkTrigger) {
                message = '<a href="#" class="stopAudio icon-stack" title="Stop Audio" style="color: black;"><i class="icon-volume-off"></i><i class="icon-ban-circle" style="color: red;"></i></a> '+
                '<span class="italic">You hear a strange robotic voice...</span>' + message;
            }
            output(message, 'preventLink');
        } else if (data.playMusic) {
            if (window.HTMLAudioElement) {
                try {
                    if (typeof data.volume !== 'number' || data.volume < 0 || data.volume > 1) {
                        data.volume = opts.volume;
                    }

                    $playMusic.attr('src', data.playMusic);
                    var music = $playMusic.get(0);
                    music.volume = data.volume * 0.5; /*   Added the multiplier here because youtube is consistently   */
                    if (music.paused) {                /* louder than admin music, which makes people lower the volume. */
                        music.play();
                    }
                } catch (e) {
                    triggerError('PlayMusic: '+e+'. '+JSON.stringify(data));
                }
            } else {
                output('<span class="internal boldnshit">Your IE version is too old for this music. Please upgrade to IE 9+.</span>');
            }
        } else if (typeof data.adjustVolume !== undefined) {
            if (typeof data.adjustVolume !== 'number' || data.adjustVolume < 0 || data.adjustVolume > 1) {
                return;
            }

            opts.volume = data.adjustVolume;

            // set volume of any music currently playing
            if (window.HTMLAudioElement) {
                var audio = $playMusic.get(0);
                audio.volume = data.adjustVolume;
                $('.dectalk').each(function(i, el) {
                    el.volume = data.adjustVolume;
                });
            }
        }
    }
}

function createPopup(contents, width) {
    opts.popups++;
    $('body').append('<div class="popup" id="popup'+opts.popups+'" style="width: '+width+'px;">'+contents+' <a href="#" class="close"><i class="icon-remove"></i></a></div>');

    //Attach close popup event
    var $popup = $('#popup'+opts.popups);
    var height = $popup.outerHeight();
    $popup.css({'height': height+'px', 'margin': '-'+(height/2)+'px 0 0 -'+(width/2)+'px'});

    $popup.on('click', '.close', function(e) {
        e.preventDefault();
        $popup.remove();
    });
}

function toggleWasd(state) {
    opts.wasd = (state == 'on' ? true : false);
}


/*****************************************
*
* DOM READY
*
******************************************/

if (typeof $ === 'undefined') {
    var div = document.getElementById('loading').childNodes[1];
    div += '<br><br>ERROR: Jquery did not load.';
}

var readyCalled = false;
$(function() {
    if (readyCalled) {
        return;
    }
    readyCalled = true;

    $messages = $('#messages');
    $subOptions = $('#subOptions');
    $playMusic = $('#play-music');

    //Hey look it's a controller loop!
    setInterval(function() {
        if (opts.pingCounter >= opts.pingLimit && !opts.restarting) { //Every pingLimit seconds
            let pingDuration = (opts.pongTime - opts.pingTime) / 2;
            opts.pingCounter = 0; //reset
            opts.pongTime = 0; //reset
            opts.pingTime = Date.now();
            runByond('?action=ehjax&window=browseroutput&type=datum&datum=chatOutput&proc=ping&param[last_ping]=' + pingDuration);
            setTimeout(function() {
                if (!opts.pongTime) { //If no response within 10 seconds of ping request
                    if (!opts.noResponse) { //Only actually append a message if the previous ping didn't also fail (to prevent spam)
                        opts.noResponse = true;
                        opts.noResponseCount++;
                        output('<div class="connectionClosed internal" data-count="'+opts.noResponseCount+'">You are either experiencing lag or the connection has closed.</div>');
                    }
                } else {
                    if (opts.noResponse) { //Previous ping attempt failed ohno
                        $('.connectionClosed[data-count="'+opts.noResponseCount+'"]:not(.restored)').addClass('restored').text('Your connection has been restored (probably)!');
                        opts.noResponse = false;
                    }
                }
            }, 10000); //10 seconds
        } else { //Every second
            opts.pingCounter++;
        }
    }, 1000); //1 second

    /*****************************************
    *
    * LOAD SAVED CONFIG
    *
    ******************************************/
    var savedConfig = {
        'sfontSize': getCookie('fontsize'),
        'sfontType': getCookie('fonttype'),
        'spingDisabled': getCookie('pingdisabled'),
        'shighlightTerms': getCookie('highlightterms'),
        'shighlightColor': getCookie('highlightcolor'),
        'stheme': getCookie('theme'),
        'stwemoji': getCookie('twemoji'),
        'smessageLimitEnabled': getCookie('messageLimitEnabled')
    };

    if (savedConfig.sfontSize) {
        $messages.css('font-size', savedConfig.sfontSize);
        output('<span class="internal boldnshit">Loaded font size setting of: '+savedConfig.sfontSize+'</span>');
    }
    if (savedConfig.sfontType) {
        $messages.css('font-family', savedConfig.sfontType);
        output('<span class="internal boldnshit">Loaded font type setting of: '+savedConfig.sfontType+'</span>');
    }
    if (savedConfig.spingDisabled) {
        if (savedConfig.spingDisabled == 'true') {
            opts.pingDisabled = true;
            $('#ping').hide();
        }
        output('<span class="internal boldnshit">Loaded ping display of: '+(opts.pingDisabled ? 'hidden' : 'visible')+'</span>');
    }
    if (savedConfig.shighlightTerms) {
        var savedTerms = $.parseJSON(savedConfig.shighlightTerms).filter(function (entry) {
            return entry !== null && /\S/.test(entry);
        });
        var actualTerms = savedTerms.length != 0 ? savedTerms.join(', ') : null;
        if (actualTerms) {
            output('<span class="internal boldnshit">Loaded highlight strings of: ' + actualTerms+'</span>');
            opts.highlightTerms = savedTerms;
        }
    }
    if (savedConfig.shighlightColor) {
        opts.highlightColor = savedConfig.shighlightColor;
        output('<span class="internal boldnshit">Loaded highlight color of: '+savedConfig.shighlightColor+'</span>');
    }
    if (savedConfig.stheme) {
        var body = $('body');
        body.removeClass(opts.currentTheme);
        body.addClass(savedConfig.stheme);
        opts.currentTheme = savedConfig.stheme;
        output('<span class="internal boldnshit">Loaded theme setting of: '+themes[savedConfig.stheme]+'</span>');
    }
    if (savedConfig.stwemoji) {
      opts.twemoji = true;
    }
    if (savedConfig.smessageLimitEnabled) {
      opts.messageLimitEnabled = savedConfig.smessageLimitEnabled;
    }

    (function() {
        var dataCookie = getCookie('connData');
        if (dataCookie) {
            var dataJ;
            try {
                dataJ = $.parseJSON(dataCookie);
            } catch (e) {
                triggerError('(cookie connData) JSON parse error for: ' + dataCookie + '. ' + e);
                return;
            }
            opts.clientData = dataJ;
        }
    })();


    /*****************************************
    *
    * BASE CHAT OUTPUT EVENTS
    *
    ******************************************/

    $('body').on('click', 'a', function(e) {
        e.preventDefault();
    });

    $('body').on('mousedown', function(e) {
        var $target = $(e.target);

        if ($contextMenu && opts.hasOwnProperty('contextMenuTarget') && opts.contextMenuTarget) {
            hideContextMenu();
            return false;
        }

        if ($target.is('a') || $target.parent('a').length || $target.is('input') || $target.is('textarea')) {
            opts.preventFocus = true;
        } else {
            opts.preventFocus = false;
            opts.mouseDownX = e.pageX;
            opts.mouseDownY = e.pageY;
        }
    });

    $messages.on('mousedown', function(e) {
        if ($subOptions && $subOptions.is(':visible')) {
            $subOptions.slideUp('fast', function() {
                $(this).removeClass('scroll');
                $(this).css('height', '');
            });
            clearInterval(opts.subOptionsLoop);
        }
    });

    $('body').on('mouseup', function(e) {
        if (!opts.preventFocus &&
            (e.pageX >= opts.mouseDownX - opts.clickTolerance && e.pageX <= opts.mouseDownX + opts.clickTolerance) &&
            (e.pageY >= opts.mouseDownY - opts.clickTolerance && e.pageY <= opts.mouseDownY + opts.clickTolerance)
        ) {
            opts.mouseDownX = null;
            opts.mouseDownY = null;
            runByond('byond://winset?mainwindow.input.focus=true');
        }
    });

    $messages.on('click', 'a', function(e) {
        e.preventDefault();
        var href = $(this).attr('href');
        if (href[0] == '?' || (href.length >= 8 && href.substring(0,8) == 'byond://')) {
            runByond(href);
        } else {
            href = escaper(href);
            runByond('?action=openLink&link='+href);
        }
    });

    //Fuck everything about this event. Will look into alternatives.
    $('body').on('keydown', function(e) {
        if (e.target.nodeName == 'INPUT' || e.target.nodeName == 'TEXTAREA') {
            return;
        }

        if (e.ctrlKey || e.altKey || e.shiftKey) { //Band-aid "fix" for allowing ctrl+c copy paste etc. Needs a proper fix.
            return;
        }

        var c = String.fromCharCode(e.which);
        if (c) {
            if (!e.shiftKey) {
                c = c.toLowerCase();
            }
            runByond('byond://winset?mainwindow.input.focus=true;mainwindow.input.text='+c);
            return false;
        } else {
            runByond('byond://winset?mainwindow.input.focus=true');
            return false;
        }
    });

    //Mildly hacky fix for scroll issues on mob change (interface gets resized sometimes, messing up snap-scroll)
    $(window).on('resize', function(e) {
        if ($(this).height() !== opts.priorChatHeight) {
            $('body,html').scrollTop($messages.outerHeight());
            opts.priorChatHeight = $(this).height();
        }
    });

    //Audio sound prevention
    $messages.on('click', '.stopAudio', function() {
        var $audio = $(this).parent().children('audio');
        if ($audio) {
            $audio.remove();
        }
    });

    $(window).on('scroll', function() {
        var bodyHeight = $('body').height();
        var messagesHeight = $messages.outerHeight();
        var scrollPos = $('body,html').scrollTop();

        if (bodyHeight + scrollPos >= messagesHeight - opts.scrollSnapTolerance) {
            if ($('#newMessages').length) {
                $('#newMessages').remove();
            }
        }
    });


    /*****************************************
    *
    * OPTIONS INTERFACE EVENTS
    *
    ******************************************/

    $('body').on('click', '#newMessages', function(e) {
        var messagesHeight = $messages.outerHeight();
        $('body,html').scrollTop(messagesHeight);
        $('#newMessages').remove();
    });

    $('#toggleOptions').click(function(e) {
        if ($subOptions.is(':visible')) {
            $subOptions.slideUp('fast', function() {
                $(this).removeClass('scroll');
                $(this).css('height', '');
            });
            clearInterval(opts.subOptionsLoop);
        } else {
            $subOptions.slideDown('fast', function() {
                var windowHeight = $(window).height();
                var toggleHeight = $('#toggleOptions').outerHeight();
                var priorSubHeight = $subOptions.outerHeight();
                var newSubHeight = windowHeight - toggleHeight;
                $(this).height(newSubHeight);
                if (priorSubHeight > (windowHeight - toggleHeight)) {
                    $(this).addClass('scroll');
                }
            });
            opts.subOptionsLoop = setInterval(function() {
                // if (!opts.suppressOptionsClose && $('#subOptions').is(':visible')) {
                //  $subOptions.slideUp('fast', function() {
                //      $(this).removeClass('scroll');
                //      $(this).css('height', '');
                //  });
                //  clearInterval(opts.subOptionsLoop);
                // }
            }, 5000); //Every 5 seconds
        }
    });

    $('#subOptions, #toggleOptions').mouseenter(function() {
        opts.suppressOptionsClose = true;
    });

    $('#subOptions, #toggleOptions').mouseleave(function() {
        opts.suppressOptionsClose = false;
    });

    $('#decreaseFont').click(function(e) {
        var fontSize = parseInt($messages.css('font-size'));
        fontSize = fontSize - 1 + 'px';
        $messages.css({'font-size': fontSize});
        setCookie('fontsize', fontSize, 365);
        output('<span class="internal boldnshit">Font size set to '+fontSize+'</span>');
    });

    $('#increaseFont').click(function(e) {
        var fontSize = parseInt($messages.css('font-size'));
        fontSize = fontSize + 1 + 'px';
        $messages.css({'font-size': fontSize});
        setCookie('fontsize', fontSize, 365);
        output('<span class="internal boldnshit">Font size set to '+fontSize+'</span>');
    });

    $('#chooseFont').click(function(e) {
        if ($('.popup .changeFont').is(':visible')) {return;}
        var popupContent = '<div class="head">Change Font</div>' +
            '<div id="changeFont" class="changeFont">'+
                '<a href="#" data-font="\'Helvetica Neue\', Helvetica, Arial" style="font-family: \'Helvetica Neue\', Helvetica, Arial;">Arial / Helvetica (Default)</a>'+
                '<a href="#" data-font="Times New Roman" style="font-family: Times New Roman;">Times New Roman</a>'+
                '<a href="#" data-font="Georgia" style="font-family: Georgia;">Georgia</a>'+
                '<a href="#" data-font="Verdana" style="font-family: Verdana;">Verdana</a>'+
                '<a href="#" data-font="Wingdings" style="font-family: Wingdings;">Wingdings</a>'+
                '<a href="#" data-font="Comic Sans MS" style="font-family: Comic Sans MS;">Comic Sans MS</a>'+
                '<a href="#" data-font="Courier New" style="font-family: Courier New;">Courier New</a>'+
                '<a href="#" data-font="Lucida Console" style="font-family: Lucida Console;">Lucida Console</a>'+
            '</div>';
        createPopup(popupContent, 200);
    });

    $('body').on('click', '#changeFont a', function(e) {
        var font = $(this).attr('data-font');
        $messages.css('font-family', font);
        setCookie('fonttype', font, 365);
    });

    $('#chooseTheme').click(function(e) {
        if ($('.popup .changeTheme').is(':visible')) {return;}
        var popupContent = '<div class="head">Change Theme</div><div id="changeTheme" class="changeTheme">';
        $.each(themes, function(themeclass, themename) {
          popupContent = popupContent + '<a href="#" data-theme="'+themeclass+'">'+themename+'</a>';
        })

        popupContent = popupContent + '</div>';
        createPopup(popupContent, 200);
    });

    $('body').on('click', '#changeTheme a', function(e) {
        var theme = $(this).attr('data-theme');
        changeTheme(theme);
    });

    $('#togglePing').click(function(e) {
        if (opts.pingDisabled) {
            $('#ping').slideDown('fast');
            opts.pingDisabled = false;
        } else {
            $('#ping').slideUp('fast');
            opts.pingDisabled = true;
        }
        setCookie('pingdisabled', (opts.pingDisabled ? 'true' : 'false'), 365);
    });

    $('#toggleEmojiFont').click(function(e) {
        opts.twemoji = !opts.twemoji;
        setCookie('twemoji', opts.twemoji, 365);
        output('<span class="internal boldnshit">Emoji set to '+(opts.twemoji?'Twemoji':'Windows emoji')+'</span>');
    });

    $('#toggleMessageLimit').click(function(e) {
        opts.messageLimitEnabled = !opts.messageLimitEnabled;
        setCookie('messageLimitEnabled', opts.messageLimitEnabled, 365);
        output('<span class="internal boldnshit">'+(opts.messageLimitEnabled ? 'Old messages will get deleted.' : 'Old messages no longer get deleted. This might cause performance issues.')+'</span>');
    });

    $('#saveLog').click(function(e) {
        var saved = '';

        if (window.XMLHttpRequest) {
            xmlHttp = new XMLHttpRequest();
        } else {
            xmlHttp = new ActiveXObject('Microsoft.XMLHTTP');
        }
        xmlHttp.open('GET', 'https://cdn.goonhub.com/css/browserOutput.css', false);
        xmlHttp.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
        xmlHttp.send();
        saved += '<style>'+xmlHttp.responseText+'</style>';
        saved += '<body class="' + opts.currentTheme + '">';

        saved += $messages.html();
        saved += '</body>';

        var now = new Date();
        var filename = 'log_' + now.getFullYear() + '-' + (now.getMonth() + 1) + '-' + now.getDate() + '_' + now.getHours() + '-' + now.getMinutes() + '.html';

        navigator.msSaveBlob(new Blob([saved], {type : 'text/html'}), filename);
      });

    $('#highlightTerm').click(function(e) {
        if ($('.popup .highlightTerm').is(':visible')) {return;}
        var termInputs = '';
        for (var i = 0; i < opts.highlightLimit; i++) {
            termInputs += '<div><input type="text" name="highlightTermInput'+i+'" id="highlightTermInput'+i+'" class="highlightTermInput'+i+'" maxlength="255" value="'+(opts.highlightTerms[i] ? opts.highlightTerms[i] : '')+'" /></div>';
        }
        var popupContent = '<div class="head">String Highlighting</div>' +
            '<div class="highlightPopup" id="highlightPopup">' +
                '<div>Choose up to '+opts.highlightLimit+' strings that will highlight the line when they appear in chat.</div>' +
                '<form id="highlightTermForm">' +
                    termInputs +
                    '<div><input type="text" name="highlightColor" id="highlightColor" class="highlightColor" '+
                        'style="background-color: '+(opts.highlightColor ? opts.highlightColor : '#FFFF00')+'" value="'+(opts.highlightColor ? opts.highlightColor : '#FFFF00')+'" maxlength="7" /></div>' +
                    '<div><input type="submit" name="highlightTermSubmit" id="highlightTermSubmit" class="highlightTermSubmit" value="Save" /></div>' +
                '</form>' +
            '</div>';
        createPopup(popupContent, 250);
    });

    $('body').on('keyup', '#highlightColor', function() {
        var color = $('#highlightColor').val();
        color = color.trim();
        if (!color || color.charAt(0) != '#') return;
        $('#highlightColor').css('background-color', color);
    });

    $('body').on('submit', '#highlightTermForm', function(e) {
        e.preventDefault();

        opts.highlightTerms = [];
        for (var count = 0; count < opts.highlightLimit; count++) {
            var term = $('#highlightTermInput'+count).val();
            if (term !== null && /\S/.test(term)) {
                opts.highlightTerms.push(term.trim().toLowerCase());
            }
        }

        var color = $('#highlightColor').val();
        color = color.trim();
        if (color == '' || color.charAt(0) != '#') {
            opts.highlightColor = '#FFFF00';
        } else {
            opts.highlightColor = color;
        }
        var $popup = $('#highlightPopup').closest('.popup');
        $popup.remove();

        setCookie('highlightterms', JSON.stringify(opts.highlightTerms), 365);
        setCookie('highlightcolor', opts.highlightColor, 365);
    });

    $('#clearMessages').click(function() {
        $messages.empty();
        opts.messageCount = 0;
    });

    $('body').on('click', '.browser-warning .close', function(e) {
        e.preventDefault();
        $('.browser-warning').remove();
    });


    /*****************************************
    *
    * KICK EVERYTHING OFF
    *
    ******************************************/

    //Do IE check because apparently some luddites still rock XP and IE 8 in the year of our lord 2017
    var trident = navigator.userAgent.match(/Trident\/(\d)\.\d(?:;|$)/gi);
    var msie = document.documentMode;
    if ((msie && msie < 10) || (trident && parseInt(trident) < 6)) { //Trident/6.0 == IE 10
        $('body').append('<div class="browser-warning">'+
                'BYOND uses IE for interfaces and we\'ve detected yours is very old.<br>'+
                '<strong>Please consider upgrading or some stuff might be broken for you!</strong>'+
                '<a href="#" class="close"><i class="icon-remove"></i></a>'+
            '</div>');
    }

    runByond('?action=ehjax&type=datum&datum=chatOutput&proc=doneLoading&param[ua]='+escaper(navigator.userAgent));
    if ($('#loading').is(':visible')) {
        $('#loading').remove();
    }
    $('#userBar').show();
    opts.priorChatHeight = $(window).height();
});
