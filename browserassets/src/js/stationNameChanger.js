document.addEventListener('DOMContentLoaded', function () {
  // Cached elements
  var $page = document.getElementById('stationNameChanger');
  var $form = $page.querySelector('.input-area');
  var $name = document.getElementById('station-name');
  var $error = $form.querySelector('.error-message');
  var $submit = $form.querySelector('button[type="submit"]');
  var $randomise = $form.querySelector('.randomise');

  var whitelistSectioned = JSON.parse(
    document.getElementById('whitelist-json').textContent
  );
  var whitelist = [];
  var valid = false;
  var submitted = false;
  var maxNameLength = 0;
  var adminUser = false;
  var fillerSections = [].concat(
    whitelistSectioned['Admins'],
    whitelistSectioned['Frontier Locations'],
    whitelistSectioned['Frontier Bodies'],
    whitelistSectioned['Sol System Bodies'],
    whitelistSectioned['Organizations'],
    whitelistSectioned['Countries'],
    whitelistSectioned['Directions'],
    whitelistSectioned['Greek'],
    whitelistSectioned['Military Letters'],
    whitelistSectioned['Misc. Nonsense'],
    whitelistSectioned['Nouns'],
    whitelistSectioned['Numbers'],
    whitelistSectioned['Petting Zoo Animals'],
    whitelistSectioned['Verbs']
  );

  // Build whitelist HTML
  var whiteListHtml = '<h2>Whitelist</h2>';
  for (var section in whitelistSectioned) {
    if (whitelistSectioned.hasOwnProperty(section)) {
      var words = whitelistSectioned[section];
      whiteListHtml += '<h3>' + section + '</h3><p>';
      for (var i = 0; i < words.length; i++) {
        whiteListHtml += words[i].toLowerCase();
        if (i < words.length - 1) {
          whiteListHtml += ', ';
        }
        whitelist.push(words[i].toLowerCase());
      }
      whiteListHtml += '</p>';
    }
  }
  document.querySelector('.whitelist').innerHTML = whiteListHtml;
  if (window.nanoScroller) {
    document.getElementById('content').nanoScroller();
  }

  function setValid() {
    valid = true;
    $name.className = $name.className.replace(' error', '') + ' valid';
    $error.innerHTML = '&nbsp;';
    $submit.removeAttribute('disabled');
  }

  function setInvalid(msg) {
    valid = false;
    $name.className = $name.className.replace(' valid', '') + ' error';
    $error.innerHTML = msg;
    $submit.setAttribute('disabled', 'disabled');
  }

  function pick(arr) {
    return arr[Math.floor(Math.random() * arr.length)];
  }

  function randomName() {
    var prefix = pick(whitelistSectioned['Prefixes']);
    var adjective = pick(whitelistSectioned['Adjectives']);
    var suffix = pick(whitelistSectioned['Suffixes']);
    var consumedLength = (prefix + adjective + suffix).length + 3;

    var filler,
      lengthCheck = false;
    while (!lengthCheck) {
      filler = pick(fillerSections);
      lengthCheck = filler.length <= maxNameLength - consumedLength;
    }

    return prefix + ' ' + adjective + ' ' + filler + ' ' + suffix;
  }

  // Validation logic
  $name.addEventListener('keyup', function () {
    var name = $name.value.trim();

    if (name.length < 1 || name.length > maxNameLength) {
      return setInvalid(
        'Name must be between 0 and ' + (maxNameLength + 1) + ' characters.'
      );
    }

    if (adminUser) {
      return setValid();
    }

    var words = name.split(' ');
    for (var i = 0; i < words.length; i++) {
      var word = words[i];
      if (!isNaN(word)) continue;
      if (whitelist.indexOf(word.toLowerCase()) === -1) {
        return setInvalid('"' + word + '" is an invalid word!');
      }
    }

    setValid();
  });

  $randomise.addEventListener('click', function () {
    var random = randomName();
    $name.value = random;
    var event = document.createEvent('Event');
    event.initEvent('keyup', true, true);
    $name.dispatchEvent(event);
  });

  // Form submission
  $form.addEventListener('submit', function (e) {
    e.preventDefault();
    if (submitted) return;

    if (valid) {
      submitted = true;
      var action = $form.getAttribute('action'); // this now grabs the full DM-provided URL

      // Append ?newName= correctly depending on DM output
      var separator = action.indexOf('?') > -1 ? '&' : '?';
      window.location =
        action +
        separator +
        'newName=' +
        encodeURIComponent($name.value.trim());
    }
  });

  // Init
  maxNameLength = parseInt($name.getAttribute('maxlength'), 10);
  adminUser = document.getElementById('admin-user').value === '1';
  $name.focus();

  if (adminUser) {
    var tips = $page.querySelector('.tips');
    tips.className += ' admin-mode';
    tips.innerHTML = 'Admin mode is on, there are no restrictions, go nuts!';
  }
});
