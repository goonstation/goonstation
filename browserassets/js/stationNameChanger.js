var triggerError = attachErrorHandler('stationNamer', true);

$(document).ready(function() {
	//Cached elements
	var $page = $('#stationNameChanger');
	var $form = $page.find('.input-area');
	var $name = $('#station-name');
	var $error = $form.find('.error-message');
	var $submit = $form.find('button[type="submit"]');
	var $randomise = $form.find('.randomise');

	var whitelistSectioned = $.parseJSON($('#whitelist-json').text());
	var whitelist = [];
	var valid = false; //is the name valid or not?
	var submitted = false; //prevent spam submissions
	var maxNameLength = 0;
	var adminUser = false; //is an admin using the panel?
	var fillerSections = [].concat( //sections used as "filler" for the randomiser
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


	//Build human-readable whitelist and flattened whitelist array
	var whiteListHtml = '<h2>Whitelist</h2>';
	$.each(whitelistSectioned, function(section, words) {
		whiteListHtml += '<h3>' + section + '</h3>';
		whiteListHtml += '<p>';

		$.each(words, function(i, word) {
			whiteListHtml += word.toLowerCase() + (i < words.length - 1 ? ', ' : '');
			whitelist.push(word.toLowerCase());
		});

		whiteListHtml += '</p>';
	});
	$('.whitelist').html(whiteListHtml);
	$('#content').nanoScroller(); //refreshes scrollbar for new height

	var setValid = function() {
		valid = true;
		$name.removeClass('error').addClass('valid');
		$error.html('&nbsp;');
		$submit.removeAttr('disabled');
	};

	var setInvalid = function(msg) {
		valid = false;
		$name.removeClass('valid').addClass('error');
		$error.html(msg);
		$submit.attr('disabled', 'disabled');
	};

	function pick(thing) {
		return thing[Math.floor(Math.random() * thing.length)];
	}

	var randomName = function() {
		//prefix, adjective, <any>, suffix
		var prefix = pick(whitelistSectioned['Prefixes']);
		var adjective = pick(whitelistSectioned['Adjectives']);
		var suffix = pick(whitelistSectioned['Suffixes']);
		var consumedLength = (prefix + adjective + suffix).length + 3; //4 words total means 3 spaces

		var filler;
		var lengthCheck = false;
		while (!lengthCheck) {
			filler = pick(fillerSections);
			lengthCheck = filler.length <= maxNameLength - consumedLength;
		}

		return prefix + ' ' + adjective + ' ' + filler + ' ' + suffix;
	};

	//Show validation errors
	$name.on('keyup', function() {
		var name = $.trim($name.val());

		if (name.length < 1 || name.length > maxNameLength) {
			return setInvalid('Name must be between 0 and ' + (maxNameLength + 1) + ' characters.');
		}

		//admins can do anything their little heart desires
		if (adminUser) {
			return setValid();
		}

		var words = name.split(' ');
		for (var i = 0; i < words.length; i++) {
			var word = words[i];

			if ($.isNumeric(word)) {
				continue;
			}

			if ($.inArray(word.toLowerCase(), whitelist) === -1) {
				return setInvalid('"' + word + '" is an invalid word!');
			}
		}

		setValid();
	});

	$randomise.on('click', function() {
		var random = randomName();
		$name.val(random).trigger('keyup');
	});

	//Form submit handler
	$form.on('submit', function(e) {
		e.preventDefault();

		if (submitted) {
			return;
		}

		if (valid) {
			submitted = true;
			window.location = $form.attr('action') + $.param({newName: $.trim($name.val())});
		}
	});


	//Init
	maxNameLength = parseInt($name.attr('maxlength'));
	adminUser = $('#admin-user').val() === '1';
	$name.focus();

	//Admin user crap
	if (adminUser) {
		$page.find('.tips').addClass('admin-mode').html('Admin mode is on, there are no restrictions, go nuts!');
	}
});
