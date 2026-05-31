/*
 * UTILITY FUNCTIONS
 */

//Runs a route within byond, client or server side. Consider this "ehjax" for byond.
function runByond(uri) {
  window.location = uri;
}
function setCookie(cname, cvalue, exdays) {
  cvalue = escaper(cvalue);
  var d = new Date();
  d.setTime(d.getTime() + exdays * 24 * 60 * 60 * 1000);
  var expires = 'expires=' + d.toUTCString();
  var cookie = cname + '=' + cvalue + '; ' + expires + '; path=/';
  document.cookie = cookie;
}

function getCookie(cname) {
  var name = cname + '=';
  var ca = document.cookie.split(';');
  for (var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') c = c.substring(1);
    if (c.indexOf(name) === 0) {
      return decoder(c.substring(name.length, c.length));
    }
  }
  return '';
}

function rgbToHex(R, G, B) {
  return toHex(R) + toHex(G) + toHex(B);
}
function toHex(n) {
  n = parseInt(n, 10);
  if (isNaN(n)) return '00';
  n = Math.max(0, Math.min(n, 255));
  return (
    '0123456789ABCDEF'.charAt((n - (n % 16)) / 16) +
    '0123456789ABCDEF'.charAt(n % 16)
  );
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
  var html = $('html');
  html.removeClass(opts.currentTheme);
  html.addClass(theme);
  opts.currentTheme = theme;
  setCookie('theme', theme, 365);
}

function createPopup(contents, width) {
  opts.popups++;
  $('body').append(
    '<div class="popup" id="popup' +
      opts.popups +
      '" style="width: ' +
      width +
      'px;">' +
      contents +
      ' <a href="#" class="close"><i class="icon-remove"></i></a></div>'
  );

  //Attach close popup event
  var $popup = $('#popup' + opts.popups);
  var height = $popup.outerHeight();
  $popup.css({
    height: height + 'px',
    margin: '-' + height / 2 + 'px 0 0 -' + width / 2 + 'px',
  });

  $popup.on('click', '.close', function (e) {
    e.preventDefault();
    $popup.remove();
  });
}

function toggleWasd(state) {
  opts.wasd = state == 'on' ? true : false;
}

function showAuthMessage(title, content) {
  output(
    '<div class="auth-message">' +
      '<div class="auth-message__title">' +
      title +
      '</div>' +
      '<div class="auth-message__content">' +
      content +
      '</div>' +
      '</div>',
    '',
    0,
    true
  );
}
