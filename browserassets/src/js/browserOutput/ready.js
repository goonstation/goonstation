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
$(function () {
  if (readyCalled) {
    return;
  }
  readyCalled = true;

  $messages = $('#messages');
  $subOptions = $('#subOptions');
  $playMusic = $('#play-music');

  //Hey look it's a controller loop!
  setInterval(function () {
    if (opts.pingCounter >= opts.pingLimit && !opts.restarting) {
      //Every pingLimit seconds
      let pingDuration = (opts.pongTime - opts.pingTime) / 2;
      opts.pingCounter = 0; //reset
      opts.pongTime = 0; //reset
      opts.pingTime = Date.now();
      runByond(
        '?action=ehjax&window=browseroutput&type=datum&datum=chatOutput&proc=ping&param[last_ping]=' +
          pingDuration
      );
      setTimeout(function () {
        if (!opts.pongTime) {
          //If no response within 10 seconds of ping request
          if (!opts.noResponse) {
            //Only actually append a message if the previous ping didn't also fail (to prevent spam)
            opts.noResponse = true;
            opts.noResponseCount++;
            output(
              '<div class="connectionClosed internal" data-count="' +
                opts.noResponseCount +
                '">You are either experiencing lag or the connection has closed.</div>'
            );
          }
        } else {
          if (opts.noResponse) {
            //Previous ping attempt failed ohno
            $(
              '.connectionClosed[data-count="' +
                opts.noResponseCount +
                '"]:not(.restored)'
            )
              .addClass('restored')
              .text('Your connection has been restored (probably)!');
            opts.noResponse = false;
          }
        }
      }, 10000); //10 seconds
    } else {
      //Every second
      opts.pingCounter++;
    }
  }, 1000); //1 second

  /*****************************************
   *
   * LOAD SAVED CONFIG
   *
   ******************************************/
  var savedConfig = {
    sfontSize: getCookie('fontsize'),
    sfontType: getCookie('fonttype'),
    spingDisabled: getCookie('pingdisabled'),
    shighlightTerms: getCookie('highlightterms'),
    shighlightColor: getCookie('highlightcolor'),
    stheme: getCookie('theme'),
    smessageLimitEnabled: getCookie('messageLimitEnabled'),
    soddMsgHighlight: getCookie('oddMsgHighlight'),
  };

  if (savedConfig.sfontSize) {
    $messages.css('font-size', savedConfig.sfontSize);
    output(
      '<span class="internal boldnshit">Loaded font size setting of: ' +
        savedConfig.sfontSize +
        '</span>'
    );
  }
  if (savedConfig.sfontType) {
    $messages.css(
      'font-family',
      savedConfig.sfontType + ", 'Twemoji', 'Segoe UI Emoji'"
    );
    output(
      '<span class="internal boldnshit">Loaded font type setting of: ' +
        savedConfig.sfontType +
        '</span>'
    );
  }
  if (savedConfig.spingDisabled) {
    if (savedConfig.spingDisabled == 'true') {
      opts.pingDisabled = true;
      $('#ping').hide();
    }
    output(
      '<span class="internal boldnshit">Loaded ping display of: ' +
        (opts.pingDisabled ? 'hidden' : 'visible') +
        '</span>'
    );
  }
  if (savedConfig.shighlightTerms) {
    var savedTerms = $.parseJSON(savedConfig.shighlightTerms).filter(
      function (entry) {
        return entry !== null && /\S/.test(entry);
      }
    );
    var actualTerms = savedTerms.length != 0 ? savedTerms.join(', ') : null;
    if (actualTerms) {
      output(
        '<span class="internal boldnshit">Loaded highlight strings of: ' +
          actualTerms +
          '</span>'
      );
      // Check for invalid regexes in saved config
      for (var t = 0; t < savedTerms.length; t++) {
        var testTerm = savedTerms[t];
        try {
          new RegExp(testTerm);
        } catch (err) {
          savedTerms[t] = 'INVALID REGEX';
        }
      }
      opts.highlightTerms = savedTerms;
    }
  }
  if (savedConfig.shighlightColor) {
    opts.highlightColor = savedConfig.shighlightColor;
    output(
      '<span class="internal boldnshit">Loaded highlight color of: ' +
        savedConfig.shighlightColor +
        '</span>'
    );
  }
  if (savedConfig.stheme) {
    var html = $('html');
    html.removeClass(opts.currentTheme);
    html.addClass(savedConfig.stheme);
    opts.currentTheme = savedConfig.stheme;
    output(
      '<span class="internal boldnshit">Loaded theme setting of: ' +
        themes[savedConfig.stheme] +
        '</span>'
    );
  }
  if (savedConfig.smessageLimitEnabled) {
    opts.messageLimitEnabled = savedConfig.smessageLimitEnabled;
  }
  if (savedConfig.soddMsgHighlight) {
    if (savedConfig.soddMsgHighlight == 'true') {
      opts.oddMsgHighlight = true;
    } else if (savedConfig.soddMsgHighlight == 'false') {
      opts.oddMsgHighlight = false;
    }
  }

  (function () {
    var dataCookie = getCookie('connData');
    if (dataCookie) {
      var dataJ;
      try {
        dataJ = $.parseJSON(dataCookie);
      } catch (e) {
        triggerError(
          '(cookie connData) JSON parse error for: ' + dataCookie + '. ' + e
        );
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

  $('body').on('click', 'a', function (e) {
    e.preventDefault();
  });

  $('body').on('mousedown', function (e) {
    var $target = $(e.target);

    if (
      $contextMenu &&
      opts.hasOwnProperty('contextMenuTarget') &&
      opts.contextMenuTarget
    ) {
      hideContextMenu();
      return false;
    }

    if (
      $target.is('a') ||
      $target.parent('a').length ||
      $target.is('input') ||
      $target.is('textarea')
    ) {
      opts.preventFocus = true;
    } else {
      opts.preventFocus = false;
      opts.mouseDownX = e.pageX;
      opts.mouseDownY = e.pageY;
    }
  });

  $messages.on('mousedown', function (e) {
    if ($subOptions && $subOptions.is(':visible')) {
      $subOptions.slideUp('fast', function () {
        $(this).removeClass('scroll');
        $(this).css('height', '');
      });
      clearInterval(opts.subOptionsLoop);
    }
  });

  $('body').on('mouseup', function (e) {
    if (
      !opts.preventFocus &&
      e.pageX >= opts.mouseDownX - opts.clickTolerance &&
      e.pageX <= opts.mouseDownX + opts.clickTolerance &&
      e.pageY >= opts.mouseDownY - opts.clickTolerance &&
      e.pageY <= opts.mouseDownY + opts.clickTolerance
    ) {
      opts.mouseDownX = null;
      opts.mouseDownY = null;
      runByond('byond://winset?mainwindow.input.focus=true');
    }
  });

  $messages.on('click', 'a', function (e) {
    e.preventDefault();
    var href = $(this).attr('href');
    if (
      href[0] == '?' ||
      (href.length >= 8 && href.substring(0, 8) == 'byond://')
    ) {
      runByond(href);
    } else {
      href = escaper(href);
      runByond('?action=openLink&link=' + href);
    }
  });

  //Fuck everything about this event. Will look into alternatives.
  $('body').on('keydown', function (e) {
    if (e.target.nodeName == 'INPUT' || e.target.nodeName == 'TEXTAREA') {
      return;
    }

    if (e.ctrlKey || e.altKey || e.shiftKey) {
      //Band-aid "fix" for allowing ctrl+c copy paste etc. Needs a proper fix.
      return;
    }

    var c = String.fromCharCode(e.which);
    if (c) {
      if (!e.shiftKey) {
        c = c.toLowerCase();
      }
      runByond(
        'byond://winset?mainwindow.input.focus=true;mainwindow.input.text=' + c
      );
      return false;
    } else {
      runByond('byond://winset?mainwindow.input.focus=true');
      return false;
    }
  });

  //Mildly hacky fix for scroll issues on mob change (interface gets resized sometimes, messing up snap-scroll)
  $(window).on('resize', function (e) {
    if ($(this).height() !== opts.priorChatHeight) {
      $('body,html').scrollTop($messages.outerHeight());
      opts.priorChatHeight = $(this).height();
    }
  });

  //Audio sound prevention
  $messages.on('click', '.stopAudio', function () {
    var $audio = $(this).parent().children('audio');
    if ($audio) {
      $audio.remove();
    }
  });

  $messages.on('click', '.reconnectClient', function () {
    clearTimeout(opts.reconnectTimeout);
    runByond('byond://winset?command=.reconnect');
  });

  $(window).on('scroll', function () {
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

  $('body').on('click', '#newMessages', function (e) {
    var messagesHeight = $messages.outerHeight();
    $('body,html').scrollTop(messagesHeight);
    $('#newMessages').remove();
  });

  $('#toggleOptions').click(function (e) {
    if ($subOptions.is(':visible')) {
      $subOptions.slideUp('fast', function () {
        $(this).removeClass('scroll');
        $(this).css('height', '');
      });
      clearInterval(opts.subOptionsLoop);
    } else {
      $subOptions.slideDown('fast', function () {
        var windowHeight = $(window).height();
        var toggleHeight = $('#toggleOptions').outerHeight();
        var priorSubHeight = $subOptions.outerHeight();
        var newSubHeight = windowHeight - toggleHeight;
        $(this).height(newSubHeight);
        if (priorSubHeight > windowHeight - toggleHeight) {
          $(this).addClass('scroll');
        }
      });
      opts.subOptionsLoop = setInterval(function () {
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

  $('#subOptions, #toggleOptions').mouseenter(function () {
    opts.suppressOptionsClose = true;
  });

  $('#subOptions, #toggleOptions').mouseleave(function () {
    opts.suppressOptionsClose = false;
  });

  $('#decreaseFont').click(function (e) {
    var fontSize = parseInt($messages.css('font-size'));
    fontSize = fontSize - 1 + 'px';
    $messages.css({ 'font-size': fontSize });
    setCookie('fontsize', fontSize, 365);
    output(
      '<span class="internal boldnshit">Font size set to ' +
        fontSize +
        '</span>'
    );
  });

  $('#increaseFont').click(function (e) {
    var fontSize = parseInt($messages.css('font-size'));
    fontSize = fontSize + 1 + 'px';
    $messages.css({ 'font-size': fontSize });
    setCookie('fontsize', fontSize, 365);
    output(
      '<span class="internal boldnshit">Font size set to ' +
        fontSize +
        '</span>'
    );
  });

  $('#chooseFont').click(function (e) {
    if ($('.popup .changeFont').is(':visible')) {
      return;
    }
    var popupContent =
      '<div class="head">Change Font</div>' +
      '<div id="changeFont" class="changeFont">' +
      '<a href="#" data-font="\'Helvetica Neue\', Helvetica, Arial" style="font-family: \'Helvetica Neue\', Helvetica, Arial;">Arial / Helvetica (Default)</a>' +
      '<a href="#" data-font="Times New Roman" style="font-family: Times New Roman;">Times New Roman</a>' +
      '<a href="#" data-font="Georgia" style="font-family: Georgia;">Georgia</a>' +
      '<a href="#" data-font="Verdana" style="font-family: Verdana;">Verdana</a>' +
      '<a href="#" data-font="Wingdings" style="font-family: Wingdings;">Wingdings</a>' +
      '<a href="#" data-font="Comic Sans MS" style="font-family: Comic Sans MS;">Comic Sans MS</a>' +
      '<a href="#" data-font="Courier New" style="font-family: Courier New;">Courier New</a>' +
      '<a href="#" data-font="Lucida Console" style="font-family: Lucida Console;">Lucida Console</a>' +
      '</div>';
    createPopup(popupContent, 200);
  });

  $('body').on('click', '#changeFont a', function (e) {
    var font = $(this).attr('data-font');
    $messages.css('font-family', font + ", 'Twemoji', 'Segoe UI Emoji'");
    setCookie('fonttype', font, 365);
  });

  $('#chooseTheme').click(function (e) {
    if ($('.popup .changeTheme').is(':visible')) {
      return;
    }
    var popupContent =
      '<div class="head">Change Theme</div><div id="changeTheme" class="changeTheme">';
    $.each(themes, function (themeclass, themename) {
      popupContent =
        popupContent +
        '<a href="#" data-theme="' +
        themeclass +
        '">' +
        themename +
        '</a>';
    });

    popupContent = popupContent + '</div>';
    createPopup(popupContent, 200);
  });

  $('body').on('click', '#changeTheme a', function (e) {
    var theme = $(this).attr('data-theme');
    changeTheme(theme);
  });

  $('#togglePing').click(function (e) {
    if (opts.pingDisabled) {
      $('#ping').slideDown('fast');
      opts.pingDisabled = false;
    } else {
      $('#ping').slideUp('fast');
      opts.pingDisabled = true;
    }
    setCookie('pingdisabled', opts.pingDisabled ? 'true' : 'false', 365);
  });

  $('#toggleMessageLimit').click(function (e) {
    opts.messageLimitEnabled = !opts.messageLimitEnabled;
    setCookie('messageLimitEnabled', opts.messageLimitEnabled, 365);
    output(
      '<span class="internal boldnshit">' +
        (opts.messageLimitEnabled
          ? 'Old messages will get deleted.'
          : 'Old messages no longer get deleted. This might cause performance issues.') +
        '</span>'
    );
  });

  $('#toggleOddMsgHighlight').click(function (e) {
    opts.oddMsgHighlight = !opts.oddMsgHighlight;
    setCookie('oddMsgHighlight', opts.oddMsgHighlight, 365);
    output(
      '<span class="internal boldnshit">' +
        (opts.oddMsgHighlight
          ? 'Odd messages will be highlighted.'
          : 'Odd messages will no longer be highlighted.') +
        '</span>'
    );
  });

  $('#saveLog').click(async function (e) {
    var saved = '<!doctype html>';

    if (window.XMLHttpRequest) {
      xmlHttp = new XMLHttpRequest();
    } else {
      xmlHttp = new ActiveXObject('Microsoft.XMLHTTP');
    }
    xmlHttp.open(
      'GET',
      'https://cdn-main1.goonhub.com/css/browserOutput.css',
      false
    );
    xmlHttp.setRequestHeader(
      'Content-type',
      'application/x-www-form-urlencoded'
    );
    xmlHttp.send();

    // translate all images to base64 so they work in the saved log
    // With love by ZeWaka
    var $cloned = $messages.clone();
    var imgPromises = [];
    $cloned.find('img').each(function () {
      var img = this;
      var src = img.src;
      // Only process http(s) images
      if (/^https?:\/\//i.test(src)) {
        var p = fetch(src)
          .then(function (resp) {
            return resp.blob();
          })
          .then(function (blob) {
            return new Promise(function (resolve) {
              var reader = new FileReader();
              reader.onloadend = function () {
                img.src = reader.result;
                resolve();
              };
              reader.readAsDataURL(blob);
            });
          })
          .catch(function () {
            // lol fuck em
          });
        imgPromises.push(p);
      }
    });

    await Promise.all(imgPromises);

    saved += `<html class="${opts.currentTheme ?? 'theme-default'}">`;
    saved += `<head><meta charset="utf-8" /><style>${xmlHttp.responseText}</style></head>`;
    saved += `<body class="${opts.currentTheme ?? 'theme-default'}">`;

    saved += $cloned.html();
    saved += '</body></html>';

    var now = new Date();
    var filename =
      'log_' +
      now.getFullYear() +
      '-' +
      (now.getMonth() + 1) +
      '-' +
      now.getDate() +
      '_' +
      now.getHours() +
      '-' +
      now.getMinutes() +
      '.html';

    var blob = new Blob([saved], { type: 'text/html' });

    if (window.showSaveFilePicker) {
      var accept = {};
      accept[blob.type] = ['.html'];

      var fileOpts = {
        suggestedName: filename,
        types: [
          {
            description: 'SS13 file',
            accept: accept,
          },
        ],
      };

      window
        .showSaveFilePicker(fileOpts)
        .then(function (file) {
          return file.createWritable();
        })
        .then(function (writable) {
          return writable.write(blob).then(function () {
            return writable.close();
          });
        })
        .catch(function () {});
    }
    // ...existing code for msSaveBlob or <a download> if needed...
  });

  $('#highlightTerm').click(function (e) {
    if ($('.popup .highlightTerm').is(':visible')) {
      return;
    }
    var termInputs = '';
    for (var i = 0; i < opts.highlightLimit; i++) {
      termInputs +=
        '<div><input type="text" name="highlightTermInput' +
        i +
        '" id="highlightTermInput' +
        i +
        '" class="highlightTermInput' +
        i +
        '" maxlength="255" value="' +
        (opts.highlightTerms[i] ? opts.highlightTerms[i] : '') +
        '" /></div>';
    }
    var popupContent =
      '<div class="head">String Highlighting</div>' +
      '<div class="highlightPopup" id="highlightPopup">' +
      '<div>Choose up to ' +
      opts.highlightLimit +
      ' strings that will highlight the line when they appear in chat. Regex is supported.</div>' +
      '<form id="highlightTermForm">' +
      termInputs +
      '<div><input type="text" name="highlightColor" id="highlightColor" class="highlightColor" ' +
      'style="background-color: ' +
      (opts.highlightColor ? opts.highlightColor : '#FFFF00') +
      '" value="' +
      (opts.highlightColor ? opts.highlightColor : '#FFFF00') +
      '" maxlength="7" /></div>' +
      '<div><input type="submit" name="highlightTermSubmit" id="highlightTermSubmit" class="highlightTermSubmit" value="Save" /></div>' +
      '</form>' +
      '</div>';
    createPopup(popupContent, 250);
  });

  $('body').on('keyup', '#highlightColor', function () {
    var color = $('#highlightColor').val();
    color = color.trim();
    if (!color || color.charAt(0) != '#') return;
    $('#highlightColor').css('background-color', color);
  });

  $('body').on('submit', '#highlightTermForm', function (e) {
    e.preventDefault();

    // Validate and replace invalid regexes
    // Don't allow people to crash their own chat
    opts.highlightTerms = [];
    for (var count = 0; count < opts.highlightLimit; count++) {
      var term = $('#highlightTermInput' + count).val();
      if (term !== null && /\S/.test(term)) {
        try {
          new RegExp(term);
          opts.highlightTerms.push(term);
        } catch (err) {
          opts.highlightTerms.push('INVALID REGEX');
        }
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

  $('#clearMessages').click(function () {
    $messages.empty();
    opts.messageCount = 0;
  });

  $('body').on('click', '.browser-warning .close', function (e) {
    e.preventDefault();
    $('.browser-warning').remove();
  });

  /*****************************************
   *
   * KICK EVERYTHING OFF
   *
   ******************************************/

  runByond('?action=ehjax&type=datum&datum=chatOutput&proc=doneLoading');
  if ($('#loading').is(':visible')) {
    $('#loading').remove();
  }
  $('#userBar').show();
  opts.priorChatHeight = $(window).height();
});
