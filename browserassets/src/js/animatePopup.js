(function(window, $) {
	var AnimatePopup = function() {
		var ctx = this;
		var _running;
		var _animation = '';
		var _details = null;
		var _settings = {};
		var _seqFirst = true;
		var _seqDur = 0;
		var _stopped = false;

		var _logger = null; //DEBUG

		var AnimatePopupException = function(message) {
			this.name = 'AnimatePopupException';
			this.message = message;
		};

		var byond = function(type, properties) {
			var params = '';
			$.map(properties, function(val, key) {
				params += ';' + key + '=' + val;
			});

			window.location = 'byond://win' + type + '?id=' + _settings.interface + params;
		};

		var animate = function(step) {
			_running = $({boop: 0}).animate({boop: 1}, {
				duration: _settings.duration,
				step: function(now) {
					step(now);
				},
				complete: _settings.complete
			});
		};

		var sequence = function(queue) {
			if (_stopped || queue.length < 1) {
				if (_stopped && queue.length > 0) {
					_logger('jumping to end of sequence');
					queue[queue.length - 1](1);
				}

				return _settings.complete();
			}

			if (_seqFirst) {
				_seqDur = _settings.duration / queue.length;
				_seqFirst = false;
			}

			var step = queue[0];

			_running = $({boop: 0}).animate({boop: 1}, {
				duration: _seqDur,
				step: function(now) {
					step(now);
				},
				complete: function() {
					queue.shift();
					sequence(queue);
				}
			});
		};

		var animations = {
			/******************************
			* CALLOUTS
			******************************/
			bounce: function() {
				var bounceAmount = _settings.amount || 30;
				sequence([
					function(now) {
						byond('set', {pos: _details.pos.x + ',' + (_details.pos.y - (bounceAmount * now))});
					},
					function(now) {
						byond('set', {pos: _details.pos.x + ',' + ((_details.pos.y - bounceAmount) + (bounceAmount * now))});
					},
					function(now) {
						byond('set', {pos: _details.pos.x + ',' + (_details.pos.y - ((bounceAmount / 2) * now))});
					},
					function(now) {
						byond('set', {pos: _details.pos.x + ',' + ((_details.pos.y - (bounceAmount / 2)) + ((bounceAmount / 2) * now))});
					},
				]);
			},

			shake: function() {
				var shakeAmount = _settings.amount || 11;
				sequence([
					function(now) {
						byond('set', {pos: (_details.pos.x - (shakeAmount * now)) + ',' + _details.pos.y});
					},
					function(now) {
						byond('set', {pos: ((_details.pos.x - shakeAmount) + ((shakeAmount * 2) * now)) + ',' + _details.pos.y});
					},
					function(now) {
						byond('set', {pos: ((_details.pos.x + shakeAmount) - ((shakeAmount * 2) * now)) + ',' + _details.pos.y});
					},
					function(now) {
						byond('set', {pos: ((_details.pos.x - shakeAmount) + ((shakeAmount * 2) * now)) + ',' + _details.pos.y});
					},
					function(now) {
						byond('set', {pos: ((_details.pos.x + shakeAmount) - ((shakeAmount * 2) * now)) + ',' + _details.pos.y});
					},
					function(now) {
						byond('set', {pos: ((_details.pos.x - shakeAmount) + (shakeAmount * now)) + ',' + _details.pos.y});
					},
				]);
			},

			flash: function() {
				sequence([
					function(now) {
						byond('set', {alpha: 255 * (1 - now)});
					},
					function(now) {
						byond('set', {alpha: 255 * now});
					},
					function(now) {
						byond('set', {alpha: 255 * (1 - now)});
					},
					function(now) {
						byond('set', {alpha: 255 * now});
					},
				]);
			},

			/******************************
			* FADING
			******************************/
			fadeIn: function() {
				animate(function(now) {
					byond('set', {alpha: 255 * now});
				});
			},

			fadeOut: function() {
				animate(function(now) {
					byond('set', {alpha: 255 * (1 - now)});
				});
			},

			/******************************
			* SLIDING
			******************************/
			_slideHandler: function(dir, show) {
				animate(function(now) {
					var neg = 1 - now;
					byond('set', {
					  alpha: 255 * (show ? now : neg),
					  pos: (_details.pos.x + (dir === 'left' || dir === 'right' ? 
							(_details.size.x * (dir === 'left' ? -1 : 1)) * (show ? neg : now) :
						  0)) +
							',' + 
						  (_details.pos.y + (dir === 'up' || dir === 'down' ? 
							(_details.size.y * (dir === 'down' ? -1 : 1)) * (show ? neg : now * -1) :
						  0))
					});
				});
			},

			//IN
			slideUpIn: function() {
				animations._slideHandler('up', true);
			},
			slideDownIn: function() {
				animations._slideHandler('down', true);
			},
			slideLeftIn: function() {
				animations._slideHandler('left', true);
			},
			slideRightIn: function() {
				animations._slideHandler('right', true);
			},

			//OUT
			slideUpOut: function() {
				animations._slideHandler('up', false);
			},
			slideDownOut: function() {
				animations._slideHandler('down', false);
			},
			slideLeftOut: function() {
				animations._slideHandler('left', false);
			},
			slideRightOut: function() {
				animations._slideHandler('right', false);
			},
		};


		/******************************
		* PUBLIC METHODS
		******************************/

		this.isValidAnimation = function(animation) {
			return typeof animations[animation] === 'function';
		};

		this.run = function(animation, options) {
			var settings = $.extend({
				//Global defaults
				interface: false,
				duration: 500,
				complete: function() {},
			}, options);

			//reset
			_seqFirst = true;
			_seqDur = 0;
			_stopped = false;

			_logger = settings.logger; //DEBUG

			if (typeof settings.interface === 'boolean') {
				throw new AnimatePopupException('You must pass an interface name');
			}

			if (typeof animations[animation] === 'undefined') {
				throw new AnimatePopupException('Animation "'+animation+'" does not exist');
			}

			_animation = animation;
			_settings = settings;
			byond('get', {
				callback: settings.interface + ':_animatePopup.updateCallback',
				property: 'size,pos'
			});
			
			return this;
		};

		this.updateCallback = function(details) {
			_details = details;
			animations[_animation](_settings);
		};

		this.stop = function(clearQueue, jumpToEnd) {
			if (_running) {
				_stopped = true;
				_running.stop(clearQueue, jumpToEnd);
			}
		};
	}

	window._animatePopup = new AnimatePopup;

}(window, jQuery));