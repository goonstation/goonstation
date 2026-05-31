/*
 * EHJAX SERVER COMMUNICATION
 */

function handleClientData(ckey, ip, compid) {
  //byond sends player info to here
  var currentData = { ckey: ckey, ip: ip, compid: compid };
  if (opts.clientData && !$.isEmptyObject(opts.clientData)) {
    runByond(
      '?action=ehjax&type=datum&datum=chatOutput&proc=analyzeClientData&param[cookie]=' +
        JSON.stringify({ connData: opts.clientData })
    );

    for (var i = 0; i < opts.clientData.length; i++) {
      var saved = opts.clientData[i];
      if (
        currentData.ckey == saved.ckey &&
        currentData.ip == saved.ip &&
        currentData.compid == saved.compid
      ) {
        return; //Record already exists
      }
    }

    if (opts.clientData.length >= opts.clientDataLimit) {
      opts.clientData.shift();
    }
  } else {
    runByond(
      '?action=ehjax&type=datum&datum=chatOutput&proc=analyzeClientData&param[cookie]=none'
    );
  }

  //Update the cookie with current details
  opts.clientData.push(currentData);
  setCookie('connData', JSON.stringify(opts.clientData), 365);
}

//Server calls this on ehjax response
//Or, y'know, whenever really
function ehjaxCallback(data) {
  if (data == 'pong') {
    if (opts.pingDisabled) {
      return;
    }
    opts.pongTime = Date.now();
    var pingDuration = Math.ceil((opts.pongTime - opts.pingTime) / 2);
    $('#pingMs').text(pingDuration + 'ms');
    pingDuration = Math.min(pingDuration, 255);
    var red = pingDuration;
    var green = 255 - pingDuration;
    var blue = 0;
    var hex = rgbToHex(red, green, blue);
    $('#pingDot').css('color', '#' + hex);
  } else if (
    data == 'roundrestart' ||
    data == 'hardrestart' ||
    data == 'updaterestart'
  ) {
    opts.restarting = true;
    output(
      '<div class="connectionClosed internal restarting">The connection has been closed because the server is restarting. Please wait while you automatically reconnect.</div>'
    );

    //server is shutting down before restarting
    if (data == 'hardrestart' || data == 'updaterestart') {
      output(
        '<div class="internal boldnshit"><a href="#" class="reconnectClient">Click here to manually reconnect</a></div>'
      );
      opts.reconnectTimeout = setTimeout(function () {
        runByond('byond://winset?command=.reconnect');
      }, 30000); //30 seconds
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
      triggerError(
        '(ehjaxCallback data) JSON parse error for: ' + data + '. ' + e
      );
      return;
    }
    data = dataJ;

    if (data.clientData) {
      if (opts.restarting) {
        opts.restarting = false;
        $('.connectionClosed.restarting:not(.restored)')
          .addClass('restored')
          .text('The round restarted and you successfully reconnected!');
      }
      if (
        !data.clientData.ckey &&
        !data.clientData.ip &&
        !data.clientData.compid
      ) {
        //TODO: Call shutdown perhaps
        return;
      } else {
        handleClientData(
          data.clientData.ckey,
          data.clientData.ip,
          data.clientData.compid
        );
      }
    } else if (data.changeTheme) {
      changeTheme(data.changeTheme);
    } else if (data.loadAdminCode) {
      if (opts.adminLoaded) {
        return;
      }
      var adminCode = data.loadAdminCode;
      $('body').append(adminCode);
      opts.adminLoaded = true;
    } else if (data.loadPerfMon) {
      if (opts.perfMonLoaded) {
        return;
      }
      var perfMon = data.loadPerfMon;
      $('body').append(perfMon);
      opts.perfMonLoaded = true;
    } else if (data.modeChange) {
      changeMode(data.modeChange);
    } else if (data.dectalk) {
      var message =
        '<audio class="dectalk" src="' +
        data.dectalk +
        '" autoplay="autoplay"></audio>';
      if (data.decTalkTrigger) {
        message =
          '<a href="#" class="stopAudio icon-stack" title="Stop Audio" style="color: black;"><i class="icon-volume-off"></i><i class="icon-ban-circle" style="color: red;"></i></a> ' +
          '<span class="italic">You hear a strange robotic voice...</span>' +
          message;
      }
      output(message, 'preventLink');
    } else if (data.playMusic) {
      if (window.HTMLAudioElement) {
        try {
          if (
            typeof data.volume !== 'number' ||
            data.volume < 0 ||
            data.volume > 1
          ) {
            data.volume = opts.volume;
          }

          var fromTopic = data.fromTopic;
          if (fromTopic) {
            // Play youtube-dl style
            $playMusic.attr('src', data.playMusic);
            $playMusic.attr('youtube', true);
            var music = $playMusic.get(0);
            /* Added the multiplier here because youtube is consistently louder than admin music, which makes people lower the volume. */
            music.volume = data.volume * 0.4;
            if (music.paused) {
              music.play();
            }
          } else {
            // Play cobalt-tools style
            var xhr = new XMLHttpRequest();
            xhr.open('GET', data.playMusic, true);
            xhr.responseType = 'blob';

            xhr.onload = function () {
              if (xhr.status === 200) {
                var blob = xhr.response;
                var url = URL.createObjectURL(blob);
                $playMusic.attr('src', url);
                $playMusic.attr('youtube', true);
                var music = $playMusic.get(0);
                /* Added the multiplier here because youtube is consistently louder than admin music, which makes people lower the volume. */
                music.volume = data.volume * 0.4;
                if (music.paused) {
                  music.play();
                }
              } else {
                triggerError(
                  'PlayMusic: Failed to download music. Status: ' + xhr.status
                );
              }
            };
            xhr.onerror = function () {
              triggerError('PlayMusic: Network error.');
            };
            xhr.send();
          }
        } catch (e) {
          triggerError('PlayMusic: ' + e + '. ' + JSON.stringify(data));
        }
      } else {
        output(
          '<span class="internal boldnshit">Your IE version is too old for this music. Please upgrade to IE 9+.</span>'
        );
      }
    } else if (typeof data.adjustVolume !== undefined) {
      if (
        typeof data.adjustVolume !== 'number' ||
        data.adjustVolume < 0 ||
        data.adjustVolume > 1
      ) {
        return;
      }

      opts.volume = data.adjustVolume;

      // set volume of any music currently playing
      if (window.HTMLAudioElement) {
        var audio = $playMusic.get(0);
        // If the youtube attribute is on the playmusic element, it's a youtube video
        // and thus we need to adjust the volume differently
        if ($playMusic.attr('youtube')) {
          audio.volume = data.adjustVolume * 0.4;
        } else {
          audio.volume = data.adjustVolume;
        }
        $('.dectalk').each(function (i, el) {
          el.volume = data.adjustVolume;
        });
      }
    }
  }
}
