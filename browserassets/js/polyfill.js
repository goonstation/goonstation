/*
 * Polyfills for methods missing in as far back as IE8, as that is (believed) to be used by players
 * running the game through WINE. Intention is to provide some more modern JS methods for easier
 * development.
 *
 * IE8 lacks a proper Object.defineProperty method, so in those cases the methods are added
 * directly to the target which should be fine for most use-cases but is something to be aware of.
 */

(function (Array, Object) {

	/*
	 * INTERNAL UTILITIES
	 */

	// derived from: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign
	// brought into module scope due to usage in polyfill function
	function assign(target, varArgs) { // length of function is 2
		'use strict';
		var index;
		var nextKey;
		var nextSource;
		var to;

		if (typeof target === 'undefined' || target === null) {
			throw new TypeError('Cannot convert undefined or null to object');
		}

		to = Object(target);

		for (index = 1; index < arguments.length; index++) {
			nextSource = arguments[index];

			if (typeof nextSource !== 'undefined' && nextSource !== null) {
				for (nextKey in nextSource) {
					// avoid bugs when hasOwnProperty is shadowed
					if (Object.prototype.hasOwnProperty.call(nextSource, nextKey)) {
						to[nextKey] = nextSource[nextKey];
					}
				}
			}
		}
		return to;
	}

	function polyfill(target, name, method, descriptor) {
		if (!target[name]) {
			try {
				Object.defineProperty(target, name, assign({ value: method }, descriptor));
			} catch (error) {
				// failing gracefully to account for IE8 erroring when attempting to use defineProperty on non-DOM object
			}
			// follow-up check, attach directly if still not present (likely due to IE8's lack of Object.defineProperty for non-DOM objects)
			if (!target[name]) {
				target[name] = method;
			}
		}
	}

	/*
	 * POLYFILLS
	 * Note that order of polyfilling is important, as later polyfills may rely on earlier ones.
	 * We could set up a dependency manager here.
	 */

	polyfill(Object, 'assign', assign);

	// derived from: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/isArray
	(function (Array, Object) {
		function isArray(value) {
			return Object.prototype.toString.call(value) === '[object Array]';
		}
		polyfill(Array, 'isArray', isArray);
	})(Array, Object);

	// artisanally crafted by: Mordent
	// not intended as a 100% perfect polyfill for edge-case use
	(function (Array) {
		function includes(searchElement, fromIndex) {
			var i;
			var length;
			var resolvedFromIndex;

			if (!Array.isArray(this)) {
				throw new TypeError('Cannot call Array method "includes" on type "' + (typeof this) + '"');
			}
			length = this.length;
			// short-circuit exit
			if (length === 0) {
				return false;
			}
			// parse fromIndex
			resolvedFromIndex = fromIndex || 0;
			if (resolvedFromIndex < 0) {
				// negative indices count back from the end of the array
				resolvedFromIndex = Math.max(length - Math.abs(resolvedFromIndex), 0);
			}
			// search
			for (i = resolvedFromIndex; i < length; i++) {
				if (this[i] === searchElement) {
					return true;
				}
			}
			return false;
		}
		polyfill(Array.prototype, 'includes', includes);
	})(Array);

	// derived from: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/keys
	(function (Object) {
		'use strict';
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		var hasDontEnumBug = !({ toString: null }).propertyIsEnumerable('toString');
		var dontEnums = [
			'toString',
			'toLocaleString',
			'valueOf',
			'hasOwnProperty',
			'isPrototypeOf',
			'propertyIsEnumerable',
			'constructor'
		];
		var dontEnumsLength = dontEnums.length;

		function keys(obj) {
			var i;
			var prop;
			var result;

			if (typeof obj !== 'function' && (typeof obj !== 'object' || obj === null)) {
				throw new TypeError('Object.keys called on non-object');
			}

			for (prop in obj) {
				if (hasOwnProperty.call(obj, prop)) {
					result.push(prop);
				}
			}

			if (hasDontEnumBug) {
				for (i = 0; i < dontEnumsLength; i++) {
					if (hasOwnProperty.call(obj, dontEnums[i])) {
						result.push(dontEnums[i]);
					}
				}
			}
			return result;
		}
		polyfill(Object, 'keys', keys);
	})(Object);

})(Array, Object);
