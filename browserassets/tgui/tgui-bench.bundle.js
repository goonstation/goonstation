/******/ (function() { // webpackBootstrap
/******/ 	var __webpack_modules__ = ({

/***/ "./packages/common/collections.js":
/*!****************************************!*\
  !*** ./packages/common/collections.js ***!
  \****************************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.zipWith = exports.zip = exports.uniqBy = exports.reduce = exports.sortBy = exports.map = exports.filter = exports.toKeyedArray = exports.toArray = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Converts a given collection to an array.
 *
 * - Arrays are returned unmodified;
 * - If object was provided, keys will be discarded;
 * - Everything else will result in an empty array.
 *
 * @returns {any[]}
 */
var toArray = function toArray(collection) {
  if (Array.isArray(collection)) {
    return collection;
  }

  if (typeof collection === 'object') {
    var _hasOwnProperty = Object.prototype.hasOwnProperty;
    var result = [];

    for (var i in collection) {
      if (_hasOwnProperty.call(collection, i)) {
        result.push(collection[i]);
      }
    }

    return result;
  }

  return [];
};
/**
 * Converts a given object to an array, and appends a key to every
 * object inside of that array.
 *
 * Example input (object):
 * ```
 * {
 *   'Foo': { info: 'Hello world!' },
 *   'Bar': { info: 'Hello world!' },
 * }
 * ```
 *
 * Example output (array):
 * ```
 * [
 *   { key: 'Foo', info: 'Hello world!' },
 *   { key: 'Bar', info: 'Hello world!' },
 * ]
 * ```
 *
 * @template T
 * @param {{ [key: string]: T }} obj Object, or in DM terms, an assoc array
 * @param {string} keyProp Property, to which key will be assigned
 * @returns {T[]} Array of keyed objects
 */


exports.toArray = toArray;

var toKeyedArray = function toKeyedArray(obj, keyProp) {
  if (keyProp === void 0) {
    keyProp = 'key';
  }

  return map(function (item, key) {
    var _Object$assign;

    return Object.assign((_Object$assign = {}, _Object$assign[keyProp] = key, _Object$assign), item);
  })(obj);
};
/**
 * Iterates over elements of collection, returning an array of all elements
 * iteratee returns truthy for. The predicate is invoked with three
 * arguments: (value, index|key, collection).
 *
 * If collection is 'null' or 'undefined', it will be returned "as is"
 * without emitting any errors (which can be useful in some cases).
 *
 * @returns {any[]}
 */


exports.toKeyedArray = toKeyedArray;

var filter = function filter(iterateeFn) {
  return function (collection) {
    if (collection === null || collection === undefined) {
      return collection;
    }

    if (Array.isArray(collection)) {
      var result = [];

      for (var i = 0; i < collection.length; i++) {
        var item = collection[i];

        if (iterateeFn(item, i, collection)) {
          result.push(item);
        }
      }

      return result;
    }

    throw new Error("filter() can't iterate on type " + typeof collection);
  };
};
/**
 * Creates an array of values by running each element in collection
 * thru an iteratee function. The iteratee is invoked with three
 * arguments: (value, index|key, collection).
 *
 * If collection is 'null' or 'undefined', it will be returned "as is"
 * without emitting any errors (which can be useful in some cases).
 *
 * @returns {any[]}
 */


exports.filter = filter;

var map = function map(iterateeFn) {
  return function (collection) {
    if (collection === null || collection === undefined) {
      return collection;
    }

    if (Array.isArray(collection)) {
      var result = [];

      for (var i = 0; i < collection.length; i++) {
        result.push(iterateeFn(collection[i], i, collection));
      }

      return result;
    }

    if (typeof collection === 'object') {
      var _hasOwnProperty2 = Object.prototype.hasOwnProperty;
      var _result = [];

      for (var _i in collection) {
        if (_hasOwnProperty2.call(collection, _i)) {
          _result.push(iterateeFn(collection[_i], _i, collection));
        }
      }

      return _result;
    }

    throw new Error("map() can't iterate on type " + typeof collection);
  };
};

exports.map = map;

var COMPARATOR = function COMPARATOR(objA, objB) {
  var criteriaA = objA.criteria;
  var criteriaB = objB.criteria;
  var length = criteriaA.length;

  for (var i = 0; i < length; i++) {
    var a = criteriaA[i];
    var b = criteriaB[i];

    if (a < b) {
      return -1;
    }

    if (a > b) {
      return 1;
    }
  }

  return 0;
};
/**
 * Creates an array of elements, sorted in ascending order by the results
 * of running each element in a collection thru each iteratee.
 *
 * Iteratees are called with one argument (value).
 *
 * @returns {any[]}
 */


var sortBy = function sortBy() {
  for (var _len = arguments.length, iterateeFns = new Array(_len), _key = 0; _key < _len; _key++) {
    iterateeFns[_key] = arguments[_key];
  }

  return function (array) {
    if (!Array.isArray(array)) {
      return array;
    }

    var length = array.length; // Iterate over the array to collect criteria to sort it by

    var mappedArray = [];

    var _loop = function _loop(i) {
      var value = array[i];
      mappedArray.push({
        criteria: iterateeFns.map(function (fn) {
          return fn(value);
        }),
        value: value
      });
    };

    for (var i = 0; i < length; i++) {
      _loop(i);
    } // Sort criteria using the base comparator


    mappedArray.sort(COMPARATOR); // Unwrap values

    while (length--) {
      mappedArray[length] = mappedArray[length].value;
    }

    return mappedArray;
  };
};
/**
 * A fast implementation of reduce.
 */


exports.sortBy = sortBy;

var reduce = function reduce(reducerFn, initialValue) {
  return function (array) {
    var length = array.length;
    var i;
    var result;

    if (initialValue === undefined) {
      i = 1;
      result = array[0];
    } else {
      i = 0;
      result = initialValue;
    }

    for (; i < length; i++) {
      result = reducerFn(result, array[i], i, array);
    }

    return result;
  };
};
/**
 * Creates a duplicate-free version of an array, using SameValueZero for
 * equality comparisons, in which only the first occurrence of each element
 * is kept. The order of result values is determined by the order they occur
 * in the array.
 *
 * It accepts iteratee which is invoked for each element in array to generate
 * the criterion by which uniqueness is computed. The order of result values
 * is determined by the order they occur in the array. The iteratee is
 * invoked with one argument: value.
 */


exports.reduce = reduce;

var uniqBy = function uniqBy(iterateeFn) {
  return function (array) {
    var length = array.length;
    var result = [];
    var seen = iterateeFn ? [] : result;
    var index = -1;

    outer: while (++index < length) {
      var value = array[index];
      var computed = iterateeFn ? iterateeFn(value) : value;
      value = value !== 0 ? value : 0;

      if (computed === computed) {
        var seenIndex = seen.length;

        while (seenIndex--) {
          if (seen[seenIndex] === computed) {
            continue outer;
          }
        }

        if (iterateeFn) {
          seen.push(computed);
        }

        result.push(value);
      } else if (!seen.includes(computed)) {
        if (seen !== result) {
          seen.push(computed);
        }

        result.push(value);
      }
    }

    return result;
  };
};
/**
 * Creates an array of grouped elements, the first of which contains
 * the first elements of the given arrays, the second of which contains
 * the second elements of the given arrays, and so on.
 *
 * @returns {any[]}
 */


exports.uniqBy = uniqBy;

var zip = function zip() {
  for (var _len2 = arguments.length, arrays = new Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
    arrays[_key2] = arguments[_key2];
  }

  if (arrays.length === 0) {
    return;
  }

  var numArrays = arrays.length;
  var numValues = arrays[0].length;
  var result = [];

  for (var valueIndex = 0; valueIndex < numValues; valueIndex++) {
    var entry = [];

    for (var arrayIndex = 0; arrayIndex < numArrays; arrayIndex++) {
      entry.push(arrays[arrayIndex][valueIndex]);
    }

    result.push(entry);
  }

  return result;
};
/**
 * This method is like "zip" except that it accepts iteratee to
 * specify how grouped values should be combined. The iteratee is
 * invoked with the elements of each group.
 *
 * @returns {any[]}
 */


exports.zip = zip;

var zipWith = function zipWith(iterateeFn) {
  return function () {
    return map(function (values) {
      return iterateeFn.apply(void 0, values);
    })(zip.apply(void 0, arguments));
  };
};

exports.zipWith = zipWith;

/***/ }),

/***/ "./packages/common/events.js":
/*!***********************************!*\
  !*** ./packages/common/events.js ***!
  \***********************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.EventEmitter = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var EventEmitter = /*#__PURE__*/function () {
  function EventEmitter() {
    this.listeners = {};
  }

  var _proto = EventEmitter.prototype;

  _proto.on = function () {
    function on(name, listener) {
      this.listeners[name] = this.listeners[name] || [];
      this.listeners[name].push(listener);
    }

    return on;
  }();

  _proto.off = function () {
    function off(name, listener) {
      var listeners = this.listeners[name];

      if (!listeners) {
        throw new Error("There is no listeners for \"" + name + "\"");
      }

      this.listeners[name] = listeners.filter(function (existingListener) {
        return existingListener !== listener;
      });
    }

    return off;
  }();

  _proto.emit = function () {
    function emit(name) {
      var listeners = this.listeners[name];

      if (!listeners) {
        return;
      }

      for (var _len = arguments.length, params = new Array(_len > 1 ? _len - 1 : 0), _key = 1; _key < _len; _key++) {
        params[_key - 1] = arguments[_key];
      }

      for (var i = 0, len = listeners.length; i < len; i += 1) {
        var listener = listeners[i];
        listener.apply(void 0, params);
      }
    }

    return emit;
  }();

  _proto.clear = function () {
    function clear() {
      this.listeners = {};
    }

    return clear;
  }();

  return EventEmitter;
}();

exports.EventEmitter = EventEmitter;

/***/ }),

/***/ "./packages/common/keycodes.js":
/*!*************************************!*\
  !*** ./packages/common/keycodes.js ***!
  \*************************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.KEY_QUOTE = exports.KEY_RIGHT_BRACKET = exports.KEY_BACKSLASH = exports.KEY_LEFT_BRACKET = exports.KEY_SLASH = exports.KEY_PERIOD = exports.KEY_MINUS = exports.KEY_COMMA = exports.KEY_EQUAL = exports.KEY_SEMICOLON = exports.KEY_F12 = exports.KEY_F11 = exports.KEY_F10 = exports.KEY_F9 = exports.KEY_F8 = exports.KEY_F7 = exports.KEY_F6 = exports.KEY_F5 = exports.KEY_F4 = exports.KEY_F3 = exports.KEY_F2 = exports.KEY_F1 = exports.KEY_Z = exports.KEY_Y = exports.KEY_X = exports.KEY_W = exports.KEY_V = exports.KEY_U = exports.KEY_T = exports.KEY_S = exports.KEY_R = exports.KEY_Q = exports.KEY_P = exports.KEY_O = exports.KEY_N = exports.KEY_M = exports.KEY_L = exports.KEY_K = exports.KEY_J = exports.KEY_I = exports.KEY_H = exports.KEY_G = exports.KEY_F = exports.KEY_E = exports.KEY_D = exports.KEY_C = exports.KEY_B = exports.KEY_A = exports.KEY_9 = exports.KEY_8 = exports.KEY_7 = exports.KEY_6 = exports.KEY_5 = exports.KEY_4 = exports.KEY_3 = exports.KEY_2 = exports.KEY_1 = exports.KEY_0 = exports.KEY_DELETE = exports.KEY_INSERT = exports.KEY_DOWN = exports.KEY_RIGHT = exports.KEY_UP = exports.KEY_LEFT = exports.KEY_HOME = exports.KEY_END = exports.KEY_PAGEDOWN = exports.KEY_PAGEUP = exports.KEY_SPACE = exports.KEY_ESCAPE = exports.KEY_CAPSLOCK = exports.KEY_PAUSE = exports.KEY_ALT = exports.KEY_CTRL = exports.KEY_SHIFT = exports.KEY_ENTER = exports.KEY_TAB = exports.KEY_BACKSPACE = void 0;

/**
 * All possible browser keycodes, in one file.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var KEY_BACKSPACE = 8;
exports.KEY_BACKSPACE = KEY_BACKSPACE;
var KEY_TAB = 9;
exports.KEY_TAB = KEY_TAB;
var KEY_ENTER = 13;
exports.KEY_ENTER = KEY_ENTER;
var KEY_SHIFT = 16;
exports.KEY_SHIFT = KEY_SHIFT;
var KEY_CTRL = 17;
exports.KEY_CTRL = KEY_CTRL;
var KEY_ALT = 18;
exports.KEY_ALT = KEY_ALT;
var KEY_PAUSE = 19;
exports.KEY_PAUSE = KEY_PAUSE;
var KEY_CAPSLOCK = 20;
exports.KEY_CAPSLOCK = KEY_CAPSLOCK;
var KEY_ESCAPE = 27;
exports.KEY_ESCAPE = KEY_ESCAPE;
var KEY_SPACE = 32;
exports.KEY_SPACE = KEY_SPACE;
var KEY_PAGEUP = 33;
exports.KEY_PAGEUP = KEY_PAGEUP;
var KEY_PAGEDOWN = 34;
exports.KEY_PAGEDOWN = KEY_PAGEDOWN;
var KEY_END = 35;
exports.KEY_END = KEY_END;
var KEY_HOME = 36;
exports.KEY_HOME = KEY_HOME;
var KEY_LEFT = 37;
exports.KEY_LEFT = KEY_LEFT;
var KEY_UP = 38;
exports.KEY_UP = KEY_UP;
var KEY_RIGHT = 39;
exports.KEY_RIGHT = KEY_RIGHT;
var KEY_DOWN = 40;
exports.KEY_DOWN = KEY_DOWN;
var KEY_INSERT = 45;
exports.KEY_INSERT = KEY_INSERT;
var KEY_DELETE = 46;
exports.KEY_DELETE = KEY_DELETE;
var KEY_0 = 48;
exports.KEY_0 = KEY_0;
var KEY_1 = 49;
exports.KEY_1 = KEY_1;
var KEY_2 = 50;
exports.KEY_2 = KEY_2;
var KEY_3 = 51;
exports.KEY_3 = KEY_3;
var KEY_4 = 52;
exports.KEY_4 = KEY_4;
var KEY_5 = 53;
exports.KEY_5 = KEY_5;
var KEY_6 = 54;
exports.KEY_6 = KEY_6;
var KEY_7 = 55;
exports.KEY_7 = KEY_7;
var KEY_8 = 56;
exports.KEY_8 = KEY_8;
var KEY_9 = 57;
exports.KEY_9 = KEY_9;
var KEY_A = 65;
exports.KEY_A = KEY_A;
var KEY_B = 66;
exports.KEY_B = KEY_B;
var KEY_C = 67;
exports.KEY_C = KEY_C;
var KEY_D = 68;
exports.KEY_D = KEY_D;
var KEY_E = 69;
exports.KEY_E = KEY_E;
var KEY_F = 70;
exports.KEY_F = KEY_F;
var KEY_G = 71;
exports.KEY_G = KEY_G;
var KEY_H = 72;
exports.KEY_H = KEY_H;
var KEY_I = 73;
exports.KEY_I = KEY_I;
var KEY_J = 74;
exports.KEY_J = KEY_J;
var KEY_K = 75;
exports.KEY_K = KEY_K;
var KEY_L = 76;
exports.KEY_L = KEY_L;
var KEY_M = 77;
exports.KEY_M = KEY_M;
var KEY_N = 78;
exports.KEY_N = KEY_N;
var KEY_O = 79;
exports.KEY_O = KEY_O;
var KEY_P = 80;
exports.KEY_P = KEY_P;
var KEY_Q = 81;
exports.KEY_Q = KEY_Q;
var KEY_R = 82;
exports.KEY_R = KEY_R;
var KEY_S = 83;
exports.KEY_S = KEY_S;
var KEY_T = 84;
exports.KEY_T = KEY_T;
var KEY_U = 85;
exports.KEY_U = KEY_U;
var KEY_V = 86;
exports.KEY_V = KEY_V;
var KEY_W = 87;
exports.KEY_W = KEY_W;
var KEY_X = 88;
exports.KEY_X = KEY_X;
var KEY_Y = 89;
exports.KEY_Y = KEY_Y;
var KEY_Z = 90;
exports.KEY_Z = KEY_Z;
var KEY_F1 = 112;
exports.KEY_F1 = KEY_F1;
var KEY_F2 = 113;
exports.KEY_F2 = KEY_F2;
var KEY_F3 = 114;
exports.KEY_F3 = KEY_F3;
var KEY_F4 = 115;
exports.KEY_F4 = KEY_F4;
var KEY_F5 = 116;
exports.KEY_F5 = KEY_F5;
var KEY_F6 = 117;
exports.KEY_F6 = KEY_F6;
var KEY_F7 = 118;
exports.KEY_F7 = KEY_F7;
var KEY_F8 = 119;
exports.KEY_F8 = KEY_F8;
var KEY_F9 = 120;
exports.KEY_F9 = KEY_F9;
var KEY_F10 = 121;
exports.KEY_F10 = KEY_F10;
var KEY_F11 = 122;
exports.KEY_F11 = KEY_F11;
var KEY_F12 = 123;
exports.KEY_F12 = KEY_F12;
var KEY_SEMICOLON = 186;
exports.KEY_SEMICOLON = KEY_SEMICOLON;
var KEY_EQUAL = 187;
exports.KEY_EQUAL = KEY_EQUAL;
var KEY_COMMA = 188;
exports.KEY_COMMA = KEY_COMMA;
var KEY_MINUS = 189;
exports.KEY_MINUS = KEY_MINUS;
var KEY_PERIOD = 190;
exports.KEY_PERIOD = KEY_PERIOD;
var KEY_SLASH = 191;
exports.KEY_SLASH = KEY_SLASH;
var KEY_LEFT_BRACKET = 219;
exports.KEY_LEFT_BRACKET = KEY_LEFT_BRACKET;
var KEY_BACKSLASH = 220;
exports.KEY_BACKSLASH = KEY_BACKSLASH;
var KEY_RIGHT_BRACKET = 221;
exports.KEY_RIGHT_BRACKET = KEY_RIGHT_BRACKET;
var KEY_QUOTE = 222;
exports.KEY_QUOTE = KEY_QUOTE;

/***/ }),

/***/ "./packages/common/math.js":
/*!*********************************!*\
  !*** ./packages/common/math.js ***!
  \*********************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.numberOfDecimalDigits = exports.keyOfMatchingRange = exports.inRange = exports.toFixed = exports.round = exports.scale = exports.clamp01 = exports.clamp = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Limits a number to the range between 'min' and 'max'.
 */
var clamp = function clamp(value, min, max) {
  return value < min ? min : value > max ? max : value;
};
/**
 * Limits a number between 0 and 1.
 */


exports.clamp = clamp;

var clamp01 = function clamp01(value) {
  return value < 0 ? 0 : value > 1 ? 1 : value;
};
/**
 * Scales a number to fit into the range between min and max.
 */


exports.clamp01 = clamp01;

var scale = function scale(value, min, max) {
  return (value - min) / (max - min);
};
/**
 * Robust number rounding.
 *
 * Adapted from Locutus, see: http://locutus.io/php/math/round/
 *
 * @param  {number} value
 * @param  {number} precision
 * @return {number}
 */


exports.scale = scale;

var round = function round(value, precision) {
  if (!value || isNaN(value)) {
    return value;
  } // helper variables


  var m, f, isHalf, sgn; // making sure precision is integer

  precision |= 0;
  m = Math.pow(10, precision);
  value *= m; // sign of the number

  sgn = value > 0 | -(value < 0); // isHalf = value % 1 === 0.5 * sgn;

  isHalf = Math.abs(value % 1) >= 0.4999999999854481;
  f = Math.floor(value);

  if (isHalf) {
    // rounds .5 away from zero
    value = f + (sgn > 0);
  }

  return (isHalf ? value : Math.round(value)) / m;
};
/**
 * Returns a string representing a number in fixed point notation.
 */


exports.round = round;

var toFixed = function toFixed(value, fractionDigits) {
  if (fractionDigits === void 0) {
    fractionDigits = 0;
  }

  return Number(value).toFixed(Math.max(fractionDigits, 0));
};
/**
 * Checks whether a value is within the provided range.
 *
 * Range is an array of two numbers, for example: [0, 15].
 */


exports.toFixed = toFixed;

var inRange = function inRange(value, range) {
  return range && value >= range[0] && value <= range[1];
};
/**
 * Walks over the object with ranges, comparing value against every range,
 * and returns the key of the first matching range.
 *
 * Range is an array of two numbers, for example: [0, 15].
 */


exports.inRange = inRange;

var keyOfMatchingRange = function keyOfMatchingRange(value, ranges) {
  for (var _i = 0, _Object$keys = Object.keys(ranges); _i < _Object$keys.length; _i++) {
    var rangeName = _Object$keys[_i];
    var range = ranges[rangeName];

    if (inRange(value, range)) {
      return rangeName;
    }
  }
};
/**
 * Get number of digits following the decimal point in a number
 */


exports.keyOfMatchingRange = keyOfMatchingRange;

var numberOfDecimalDigits = function numberOfDecimalDigits(value) {
  if (Math.floor(value) !== value) {
    return value.toString().split('.')[1].length || 0;
  }

  return 0;
};

exports.numberOfDecimalDigits = numberOfDecimalDigits;

/***/ }),

/***/ "./packages/common/perf.js":
/*!*********************************!*\
  !*** ./packages/common/perf.js ***!
  \*********************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.perf = void 0;

var _window$performance;

/**
 * Ghetto performance measurement tools.
 *
 * Uses NODE_ENV to remove itself from production builds.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var FPS = 60;
var FRAME_DURATION = 1000 / FPS; // True if Performance API is supported

var supportsPerf = !!((_window$performance = window.performance) != null && _window$performance.now); // High precision markers

var hpMarkersByName = {}; // Low precision markers

var lpMarkersByName = {};
/**
 * Marks a certain spot in the code for later measurements.
 */

var mark = function mark(name, timestamp) {
  if (true) {
    if (supportsPerf && !timestamp) {
      hpMarkersByName[name] = performance.now();
    }

    lpMarkersByName[name] = timestamp || Date.now();
  }
};
/**
 * Calculates and returns the difference between two markers as a string.
 *
 * Use logger.log() to print the measurement.
 */


var measure = function measure(markerNameA, markerNameB) {
  if (true) {
    var markerA = hpMarkersByName[markerNameA];
    var markerB = hpMarkersByName[markerNameB];

    if (!markerA || !markerB) {
      markerA = lpMarkersByName[markerNameA];
      markerB = lpMarkersByName[markerNameB];
    }

    var duration = Math.abs(markerB - markerA);
    return formatDuration(duration);
  }
};

var formatDuration = function formatDuration(duration) {
  var durationInFrames = duration / FRAME_DURATION;
  return duration.toFixed(duration < 10 ? 1 : 0) + 'ms ' + '(' + durationInFrames.toFixed(2) + ' frames)';
};

var perf = {
  mark: mark,
  measure: measure
};
exports.perf = perf;

/***/ }),

/***/ "./packages/common/react.ts":
/*!**********************************!*\
  !*** ./packages/common/react.ts ***!
  \**********************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.canRender = exports.pureComponentHooks = exports.shallowDiffers = exports.normalizeChildren = exports.classes = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Helper for conditionally adding/removing classes in React
 */
var classes = function classes(classNames) {
  var className = '';

  for (var i = 0; i < classNames.length; i++) {
    var part = classNames[i];

    if (typeof part === 'string') {
      className += part + ' ';
    }
  }

  return className;
};
/**
 * Normalizes children prop, so that it is always an array of VDom
 * elements.
 */


exports.classes = classes;

var normalizeChildren = function normalizeChildren(children) {
  if (Array.isArray(children)) {
    return children.flat().filter(function (value) {
      return value;
    });
  }

  if (typeof children === 'object') {
    return [children];
  }

  return [];
};
/**
 * Shallowly checks if two objects are different.
 * Credit: https://github.com/developit/preact-compat
 */


exports.normalizeChildren = normalizeChildren;

var shallowDiffers = function shallowDiffers(a, b) {
  var i;

  for (i in a) {
    if (!(i in b)) {
      return true;
    }
  }

  for (i in b) {
    if (a[i] !== b[i]) {
      return true;
    }
  }

  return false;
};
/**
 * Default inferno hooks for pure components.
 */


exports.shallowDiffers = shallowDiffers;
var pureComponentHooks = {
  onComponentShouldUpdate: function () {
    function onComponentShouldUpdate(lastProps, nextProps) {
      return shallowDiffers(lastProps, nextProps);
    }

    return onComponentShouldUpdate;
  }()
};
/**
 * A helper to determine whether the object is renderable by React.
 */

exports.pureComponentHooks = pureComponentHooks;

var canRender = function canRender(value) {
  return value !== undefined && value !== null && typeof value !== 'boolean';
};
/**
 * A common case in tgui, when you pass a value conditionally, these are
 * the types that can fall through the condition.
 */


exports.canRender = canRender;

/***/ }),

/***/ "./packages/common/timer.js":
/*!**********************************!*\
  !*** ./packages/common/timer.js ***!
  \**********************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.sleep = exports.debounce = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Returns a function, that, as long as it continues to be invoked, will
 * not be triggered. The function will be called after it stops being
 * called for N milliseconds. If `immediate` is passed, trigger the
 * function on the leading edge, instead of the trailing.
 */
var debounce = function debounce(fn, time, immediate) {
  if (immediate === void 0) {
    immediate = false;
  }

  var timeout;
  return function () {
    for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
      args[_key] = arguments[_key];
    }

    var later = function later() {
      timeout = null;

      if (!immediate) {
        fn.apply(void 0, args);
      }
    };

    var callNow = immediate && !timeout;
    clearTimeout(timeout);
    timeout = setTimeout(later, time);

    if (callNow) {
      fn.apply(void 0, args);
    }
  };
};
/**
 * Suspends an asynchronous function for N milliseconds.
 *
 * @param {number} time
 */


exports.debounce = debounce;

var sleep = function sleep(time) {
  return new Promise(function (resolve) {
    return setTimeout(resolve, time);
  });
};

exports.sleep = sleep;

/***/ }),

/***/ "./packages/tgui-bench/entrypoint.tsx":
/*!********************************************!*\
  !*** ./packages/tgui-bench/entrypoint.tsx ***!
  \********************************************/
/***/ (function(__unused_webpack_module, __unused_webpack_exports, __webpack_require__) {

"use strict";


var _events = __webpack_require__(/*! tgui/events */ "./packages/tgui/events.js");

__webpack_require__(/*! tgui/styles/main.scss */ "./packages/tgui/styles/main.scss");

var _benchmark = _interopRequireDefault(__webpack_require__(/*! ./lib/benchmark */ "./packages/tgui-bench/lib/benchmark.js"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _createForOfIteratorHelperLoose(o, allowArrayLike) { var it = typeof Symbol !== "undefined" && o[Symbol.iterator] || o["@@iterator"]; if (it) return (it = it.call(o)).next.bind(it); if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; return function () { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function _asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

var sendMessage = function sendMessage(obj) {
  var req = new XMLHttpRequest();
  req.open('POST', "/message", false);
  req.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
  req.timeout = 250;
  req.send(JSON.stringify(obj));
};

var setupApp = /*#__PURE__*/function () {
  var _ref = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function () {
    function _callee() {
      var requireTest, _loop, _iterator, _step;

      return regeneratorRuntime.wrap(function () {
        function _callee$(_context2) {
          while (1) {
            switch (_context2.prev = _context2.next) {
              case 0:
                if (!(document.readyState === 'loading')) {
                  _context2.next = 3;
                  break;
                }

                document.addEventListener('DOMContentLoaded', setupApp);
                return _context2.abrupt("return");

              case 3:
                (0, _events.setupGlobalEvents)({
                  ignoreWindowFocus: true
                });
                requireTest = __webpack_require__("./packages/tgui-bench/tests sync \\.test\\.");
                _loop = /*#__PURE__*/regeneratorRuntime.mark(function () {
                  function _loop() {
                    var file, tests;
                    return regeneratorRuntime.wrap(function () {
                      function _loop$(_context) {
                        while (1) {
                          switch (_context.prev = _context.next) {
                            case 0:
                              file = _step.value;
                              sendMessage({
                                type: 'suite-start',
                                file: file
                              });
                              _context.prev = 2;
                              tests = requireTest(file);
                              _context.next = 6;
                              return new Promise(function (resolve) {
                                var suite = new _benchmark["default"].Suite(file, {
                                  onCycle: function () {
                                    function onCycle(e) {
                                      sendMessage({
                                        type: 'suite-cycle',
                                        message: String(e.target)
                                      });
                                    }

                                    return onCycle;
                                  }(),
                                  onComplete: function () {
                                    function onComplete() {
                                      // This message is somewhat useless, but leaving it here in case
                                      // someone has an idea how to show more useful data.
                                      // sendMessage({
                                      //   type: 'suite-complete',
                                      //   message: 'Fastest is ' + this.filter('fastest').map('name'),
                                      // });
                                      resolve();
                                    }

                                    return onComplete;
                                  }(),
                                  onError: function () {
                                    function onError(e) {
                                      sendMessage({
                                        type: 'error',
                                        e: e
                                      });
                                      resolve();
                                    }

                                    return onError;
                                  }()
                                });

                                for (var _i = 0, _Object$entries = Object.entries(tests); _i < _Object$entries.length; _i++) {
                                  var _Object$entries$_i = _Object$entries[_i],
                                      name = _Object$entries$_i[0],
                                      fn = _Object$entries$_i[1];

                                  if (typeof fn === 'function') {
                                    suite.add(name, fn);
                                  }
                                }

                                suite.run();
                              });

                            case 6:
                              _context.next = 11;
                              break;

                            case 8:
                              _context.prev = 8;
                              _context.t0 = _context["catch"](2);
                              sendMessage({
                                type: 'error',
                                error: _context.t0
                              });

                            case 11:
                            case "end":
                              return _context.stop();
                          }
                        }
                      }

                      return _loop$;
                    }(), _loop, null, [[2, 8]]);
                  }

                  return _loop;
                }());
                _iterator = _createForOfIteratorHelperLoose(requireTest.keys());

              case 7:
                if ((_step = _iterator()).done) {
                  _context2.next = 11;
                  break;
                }

                return _context2.delegateYield(_loop(), "t0", 9);

              case 9:
                _context2.next = 7;
                break;

              case 11:
                sendMessage({
                  type: 'finished'
                });

              case 12:
              case "end":
                return _context2.stop();
            }
          }
        }

        return _callee$;
      }(), _callee);
    }

    return _callee;
  }()));

  return function () {
    function setupApp() {
      return _ref.apply(this, arguments);
    }

    return setupApp;
  }();
}();

setupApp();

/***/ }),

/***/ "./packages/tgui-bench/lib/benchmark.js":
/*!**********************************************!*\
  !*** ./packages/tgui-bench/lib/benchmark.js ***!
  \**********************************************/
/***/ (function(module, __unused_webpack_exports, __webpack_require__) {

"use strict";


/* eslint-disable */

/*!
 * Benchmark.js <https://benchmarkjs.com/>
 * Copyright 2010-2016 Mathias Bynens <https://mths.be/>
 * Based on JSLitmus.js, copyright Robert Kieffer <http://broofa.com/>
 * Modified by John-David Dalton <http://allyoucanleet.com/>
 * Manually stripped from useless junk by /tg/station13 maintainers.
 * Available under MIT license <https://mths.be/mit>
 */
module.exports = function () {
  'use strict';
  /** Used as a safe reference for `undefined` in pre ES5 environments. */

  var undefined;
  /** Used to determine if values are of the language type Object. */

  var objectTypes = {
    'function': true,
    'object': true
  };
  /** Used as a reference to the global object. */

  var root = objectTypes[typeof window] && window || this;
  /** Detect free variable `define`. */

  var freeDefine = false;
  /** Used to assign each benchmark an incremented id. */

  var counter = 0;
  /** Used to detect primitive types. */

  var rePrimitive = /^(?:boolean|number|string|undefined)$/;
  /** Used to make every compiled test unique. */

  var uidCounter = 0;
  /** Used to assign default `context` object properties. */

  var contextProps = ['Array', 'Date', 'Function', 'Math', 'Object', 'RegExp', 'String', '_', 'clearTimeout', 'chrome', 'chromium', 'document', 'navigator', 'phantom', 'platform', 'process', 'runtime', 'setTimeout'];
  /** Used to avoid hz of Infinity. */

  var divisors = {
    '1': 4096,
    '2': 512,
    '3': 64,
    '4': 8,
    '5': 0
  };
  /**
   * T-Distribution two-tailed critical values for 95% confidence.
   * For more info see http://www.itl.nist.gov/div898/handbook/eda/section3/eda3672.htm.
   */

  var tTable = {
    '1': 12.706,
    '2': 4.303,
    '3': 3.182,
    '4': 2.776,
    '5': 2.571,
    '6': 2.447,
    '7': 2.365,
    '8': 2.306,
    '9': 2.262,
    '10': 2.228,
    '11': 2.201,
    '12': 2.179,
    '13': 2.16,
    '14': 2.145,
    '15': 2.131,
    '16': 2.12,
    '17': 2.11,
    '18': 2.101,
    '19': 2.093,
    '20': 2.086,
    '21': 2.08,
    '22': 2.074,
    '23': 2.069,
    '24': 2.064,
    '25': 2.06,
    '26': 2.056,
    '27': 2.052,
    '28': 2.048,
    '29': 2.045,
    '30': 2.042,
    'infinity': 1.96
  };
  /**
   * Critical Mann-Whitney U-values for 95% confidence.
   * For more info see http://www.saburchill.com/IBbiology/stats/003.html.
   */

  var uTable = {
    '5': [0, 1, 2],
    '6': [1, 2, 3, 5],
    '7': [1, 3, 5, 6, 8],
    '8': [2, 4, 6, 8, 10, 13],
    '9': [2, 4, 7, 10, 12, 15, 17],
    '10': [3, 5, 8, 11, 14, 17, 20, 23],
    '11': [3, 6, 9, 13, 16, 19, 23, 26, 30],
    '12': [4, 7, 11, 14, 18, 22, 26, 29, 33, 37],
    '13': [4, 8, 12, 16, 20, 24, 28, 33, 37, 41, 45],
    '14': [5, 9, 13, 17, 22, 26, 31, 36, 40, 45, 50, 55],
    '15': [5, 10, 14, 19, 24, 29, 34, 39, 44, 49, 54, 59, 64],
    '16': [6, 11, 15, 21, 26, 31, 37, 42, 47, 53, 59, 64, 70, 75],
    '17': [6, 11, 17, 22, 28, 34, 39, 45, 51, 57, 63, 67, 75, 81, 87],
    '18': [7, 12, 18, 24, 30, 36, 42, 48, 55, 61, 67, 74, 80, 86, 93, 99],
    '19': [7, 13, 19, 25, 32, 38, 45, 52, 58, 65, 72, 78, 85, 92, 99, 106, 113],
    '20': [8, 14, 20, 27, 34, 41, 48, 55, 62, 69, 76, 83, 90, 98, 105, 112, 119, 127],
    '21': [8, 15, 22, 29, 36, 43, 50, 58, 65, 73, 80, 88, 96, 103, 111, 119, 126, 134, 142],
    '22': [9, 16, 23, 30, 38, 45, 53, 61, 69, 77, 85, 93, 101, 109, 117, 125, 133, 141, 150, 158],
    '23': [9, 17, 24, 32, 40, 48, 56, 64, 73, 81, 89, 98, 106, 115, 123, 132, 140, 149, 157, 166, 175],
    '24': [10, 17, 25, 33, 42, 50, 59, 67, 76, 85, 94, 102, 111, 120, 129, 138, 147, 156, 165, 174, 183, 192],
    '25': [10, 18, 27, 35, 44, 53, 62, 71, 80, 89, 98, 107, 117, 126, 135, 145, 154, 163, 173, 182, 192, 201, 211],
    '26': [11, 19, 28, 37, 46, 55, 64, 74, 83, 93, 102, 112, 122, 132, 141, 151, 161, 171, 181, 191, 200, 210, 220, 230],
    '27': [11, 20, 29, 38, 48, 57, 67, 77, 87, 97, 107, 118, 125, 138, 147, 158, 168, 178, 188, 199, 209, 219, 230, 240, 250],
    '28': [12, 21, 30, 40, 50, 60, 70, 80, 90, 101, 111, 122, 132, 143, 154, 164, 175, 186, 196, 207, 218, 228, 239, 250, 261, 272],
    '29': [13, 22, 32, 42, 52, 62, 73, 83, 94, 105, 116, 127, 138, 149, 160, 171, 182, 193, 204, 215, 226, 238, 249, 260, 271, 282, 294],
    '30': [13, 23, 33, 43, 54, 65, 76, 87, 98, 109, 120, 131, 143, 154, 166, 177, 189, 200, 212, 223, 235, 247, 258, 270, 282, 293, 305, 317]
  };
  /*--------------------------------------------------------------------------*/

  /**
   * Create a new `Benchmark` function using the given `context` object.
   *
   * @static
   * @memberOf Benchmark
   * @param {Object} [context=root] The context object.
   * @returns {Function} Returns a new `Benchmark` function.
   */

  function runInContext(context) {
    // Exit early if unable to acquire lodash.
    var _ = context && context._ || __webpack_require__(/*! lodash */ "./.yarn/cache/lodash-npm-4.17.21-6382451519-4983720b9a.zip/node_modules/lodash/lodash.js") || root._;

    if (!_) {
      Benchmark.runInContext = runInContext;
      return Benchmark;
    } // Avoid issues with some ES3 environments that attempt to use values, named
    // after built-in constructors like `Object`, for the creation of literals.
    // ES5 clears this up by stating that literals must use built-in constructors.
    // See http://es5.github.io/#x11.1.5.


    context = context ? _.defaults(root.Object(), context, _.pick(root, contextProps)) : root;
    /** Native constructor references. */

    var Array = context.Array,
        Date = context.Date,
        Function = context.Function,
        Math = context.Math,
        Object = context.Object,
        RegExp = context.RegExp,
        String = context.String;
    /** Used for `Array` and `Object` method references. */

    var arrayRef = [],
        objectProto = Object.prototype;
    /** Native method shortcuts. */

    var abs = Math.abs,
        clearTimeout = context.clearTimeout,
        floor = Math.floor,
        log = Math.log,
        max = Math.max,
        min = Math.min,
        pow = Math.pow,
        push = arrayRef.push,
        setTimeout = context.setTimeout,
        shift = arrayRef.shift,
        slice = arrayRef.slice,
        sqrt = Math.sqrt,
        toString = objectProto.toString,
        unshift = arrayRef.unshift;
    /** Detect DOM document object. */

    var doc = isHostType(context, 'document') && context.document;
    /** Used to access Node.js's high resolution timer. */

    var processObject = isHostType(context, 'process') && context.process;
    /** Used to prevent a `removeChild` memory leak in IE < 9. */

    var trash = doc && doc.createElement('div');
    /** Used to integrity check compiled tests. */

    var uid = 'uid' + _.now();
    /** Used to avoid infinite recursion when methods call each other. */


    var calledBy = {};
    /**
     * An object used to flag environments/features.
     *
     * @static
     * @memberOf Benchmark
     * @type Object
     */

    var support = {};

    (function () {
      /**
       * Detect if running in a browser environment.
       *
       * @memberOf Benchmark.support
       * @type boolean
       */
      support.browser = doc && isHostType(context, 'navigator') && !isHostType(context, 'phantom');
      /**
       * Detect if the Timers API exists.
       *
       * @memberOf Benchmark.support
       * @type boolean
       */

      support.timeout = isHostType(context, 'setTimeout') && isHostType(context, 'clearTimeout');
      /**
       * Detect if function decompilation is support.
       *
       * @name decompilation
       * @memberOf Benchmark.support
       * @type boolean
       */

      try {
        // Safari 2.x removes commas in object literals from `Function#toString` results.
        // See http://webk.it/11609 for more details.
        // Firefox 3.6 and Opera 9.25 strip grouping parentheses from `Function#toString` results.
        // See http://bugzil.la/559438 for more details.
        support.decompilation = Function(('return (' + function (x) {
          return {
            'x': '' + (1 + x) + '',
            'y': 0
          };
        } + ')'). // Avoid issues with code added by Istanbul.
        replace(/__cov__[^;]+;/g, ''))()(0).x === '1';
      } catch (e) {
        support.decompilation = false;
      }
    })();
    /**
     * Timer object used by `clock()` and `Deferred#resolve`.
     *
     * @private
     * @type Object
     */


    var timer = {
      /**
       * The timer namespace object or constructor.
       *
       * @private
       * @memberOf timer
       * @type {Function|Object}
       */
      'ns': Date,

      /**
       * Starts the deferred timer.
       *
       * @private
       * @memberOf timer
       * @param {Object} deferred The deferred instance.
       */
      'start': null,
      // Lazy defined in `clock()`.

      /**
       * Stops the deferred timer.
       *
       * @private
       * @memberOf timer
       * @param {Object} deferred The deferred instance.
       */
      'stop': null // Lazy defined in `clock()`.

    };
    /*------------------------------------------------------------------------*/

    /**
     * The Benchmark constructor.
     *
     * Note: The Benchmark constructor exposes a handful of lodash methods to
     * make working with arrays, collections, and objects easier. The lodash
     * methods are:
     * [`each/forEach`](https://lodash.com/docs#forEach), [`forOwn`](https://lodash.com/docs#forOwn),
     * [`has`](https://lodash.com/docs#has), [`indexOf`](https://lodash.com/docs#indexOf),
     * [`map`](https://lodash.com/docs#map), and [`reduce`](https://lodash.com/docs#reduce)
     *
     * @constructor
     * @param {string} name A name to identify the benchmark.
     * @param {Function|string} fn The test to benchmark.
     * @param {Object} [options={}] Options object.
     * @example
     *
     * // basic usage (the `new` operator is optional)
     * var bench = new Benchmark(fn);
     *
     * // or using a name first
     * var bench = new Benchmark('foo', fn);
     *
     * // or with options
     * var bench = new Benchmark('foo', fn, {
     *
     *   // displayed by `Benchmark#toString` if `name` is not available
     *   'id': 'xyz',
     *
     *   // called when the benchmark starts running
     *   'onStart': onStart,
     *
     *   // called after each run cycle
     *   'onCycle': onCycle,
     *
     *   // called when aborted
     *   'onAbort': onAbort,
     *
     *   // called when a test errors
     *   'onError': onError,
     *
     *   // called when reset
     *   'onReset': onReset,
     *
     *   // called when the benchmark completes running
     *   'onComplete': onComplete,
     *
     *   // compiled/called before the test loop
     *   'setup': setup,
     *
     *   // compiled/called after the test loop
     *   'teardown': teardown
     * });
     *
     * // or name and options
     * var bench = new Benchmark('foo', {
     *
     *   // a flag to indicate the benchmark is deferred
     *   'defer': true,
     *
     *   // benchmark test function
     *   'fn': function(deferred) {
     *     // call `Deferred#resolve` when the deferred test is finished
     *     deferred.resolve();
     *   }
     * });
     *
     * // or options only
     * var bench = new Benchmark({
     *
     *   // benchmark name
     *   'name': 'foo',
     *
     *   // benchmark test as a string
     *   'fn': '[1,2,3,4].sort()'
     * });
     *
     * // a test's `this` binding is set to the benchmark instance
     * var bench = new Benchmark('foo', function() {
     *   'My name is '.concat(this.name); // "My name is foo"
     * });
     */

    function Benchmark(name, fn, options) {
      var bench = this; // Allow instance creation without the `new` operator.

      if (!(bench instanceof Benchmark)) {
        return new Benchmark(name, fn, options);
      } // Juggle arguments.


      if (_.isPlainObject(name)) {
        // 1 argument (options).
        options = name;
      } else if (_.isFunction(name)) {
        // 2 arguments (fn, options).
        options = fn;
        fn = name;
      } else if (_.isPlainObject(fn)) {
        // 2 arguments (name, options).
        options = fn;
        fn = null;
        bench.name = name;
      } else {
        // 3 arguments (name, fn [, options]).
        bench.name = name;
      }

      setOptions(bench, options);
      bench.id || (bench.id = ++counter);
      bench.fn == null && (bench.fn = fn);
      bench.stats = cloneDeep(bench.stats);
      bench.times = cloneDeep(bench.times);
    }
    /**
     * The Deferred constructor.
     *
     * @constructor
     * @memberOf Benchmark
     * @param {Object} clone The cloned benchmark instance.
     */


    function Deferred(clone) {
      var deferred = this;

      if (!(deferred instanceof Deferred)) {
        return new Deferred(clone);
      }

      deferred.benchmark = clone;
      clock(deferred);
    }
    /**
     * The Event constructor.
     *
     * @constructor
     * @memberOf Benchmark
     * @param {Object|string} type The event type.
     */


    function Event(type) {
      var event = this;

      if (type instanceof Event) {
        return type;
      }

      return event instanceof Event ? _.assign(event, {
        'timeStamp': _.now()
      }, typeof type == 'string' ? {
        'type': type
      } : type) : new Event(type);
    }
    /**
     * The Suite constructor.
     *
     * Note: Each Suite instance has a handful of wrapped lodash methods to
     * make working with Suites easier. The wrapped lodash methods are:
     * [`each/forEach`](https://lodash.com/docs#forEach), [`indexOf`](https://lodash.com/docs#indexOf),
     * [`map`](https://lodash.com/docs#map), and [`reduce`](https://lodash.com/docs#reduce)
     *
     * @constructor
     * @memberOf Benchmark
     * @param {string} name A name to identify the suite.
     * @param {Object} [options={}] Options object.
     * @example
     *
     * // basic usage (the `new` operator is optional)
     * var suite = new Benchmark.Suite;
     *
     * // or using a name first
     * var suite = new Benchmark.Suite('foo');
     *
     * // or with options
     * var suite = new Benchmark.Suite('foo', {
     *
     *   // called when the suite starts running
     *   'onStart': onStart,
     *
     *   // called between running benchmarks
     *   'onCycle': onCycle,
     *
     *   // called when aborted
     *   'onAbort': onAbort,
     *
     *   // called when a test errors
     *   'onError': onError,
     *
     *   // called when reset
     *   'onReset': onReset,
     *
     *   // called when the suite completes running
     *   'onComplete': onComplete
     * });
     */


    function Suite(name, options) {
      var suite = this; // Allow instance creation without the `new` operator.

      if (!(suite instanceof Suite)) {
        return new Suite(name, options);
      } // Juggle arguments.


      if (_.isPlainObject(name)) {
        // 1 argument (options).
        options = name;
      } else {
        // 2 arguments (name [, options]).
        suite.name = name;
      }

      setOptions(suite, options);
    }
    /*------------------------------------------------------------------------*/

    /**
     * A specialized version of `_.cloneDeep` which only clones arrays and plain
     * objects assigning all other values by reference.
     *
     * @private
     * @param {*} value The value to clone.
     * @returns {*} The cloned value.
     */


    var cloneDeep = _.partial(_.cloneDeepWith, _, function (value) {
      // Only clone primitives, arrays, and plain objects.
      return _.isObject(value) && !_.isArray(value) && !_.isPlainObject(value) ? value : undefined;
    });
    /**
     * Creates a function from the given arguments string and body.
     *
     * @private
     * @param {string} args The comma separated function arguments.
     * @param {string} body The function body.
     * @returns {Function} The new function.
     */


    function createFunction() {
      // Lazy define.
      createFunction = function createFunction(args, body) {
        var result,
            anchor = freeDefine ? freeDefine.amd : Benchmark,
            prop = uid + 'createFunction';
        runScript((freeDefine ? 'define.amd.' : 'Benchmark.') + prop + '=function(' + args + '){' + body + '}');
        result = anchor[prop];
        delete anchor[prop];
        return result;
      }; // Fix JaegerMonkey bug.
      // For more information see http://bugzil.la/639720.


      createFunction = support.browser && (createFunction('', 'return"' + uid + '"') || _.noop)() == uid ? createFunction : Function;
      return createFunction.apply(null, arguments);
    }
    /**
     * Delay the execution of a function based on the benchmark's `delay` property.
     *
     * @private
     * @param {Object} bench The benchmark instance.
     * @param {Object} fn The function to execute.
     */


    function delay(bench, fn) {
      bench._timerId = _.delay(fn, bench.delay * 1e3);
    }
    /**
     * Destroys the given element.
     *
     * @private
     * @param {Element} element The element to destroy.
     */


    function destroyElement(element) {
      trash.appendChild(element);
      trash.innerHTML = '';
    }
    /**
     * Gets the name of the first argument from a function's source.
     *
     * @private
     * @param {Function} fn The function.
     * @returns {string} The argument name.
     */


    function getFirstArgument(fn) {
      return !_.has(fn, 'toString') && (/^[\s(]*function[^(]*\(([^\s,)]+)/.exec(fn) || 0)[1] || '';
    }
    /**
     * Computes the arithmetic mean of a sample.
     *
     * @private
     * @param {Array} sample The sample.
     * @returns {number} The mean.
     */


    function getMean(sample) {
      return _.reduce(sample, function (sum, x) {
        return sum + x;
      }) / sample.length || 0;
    }
    /**
     * Gets the source code of a function.
     *
     * @private
     * @param {Function} fn The function.
     * @returns {string} The function's source code.
     */


    function getSource(fn) {
      var result = '';

      if (isStringable(fn)) {
        result = String(fn);
      } else if (support.decompilation) {
        // Escape the `{` for Firefox 1.
        result = _.result(/^[^{]+\{([\s\S]*)\}\s*$/.exec(fn), 1);
      } // Trim string.


      result = (result || '').replace(/^\s+|\s+$/g, ''); // Detect strings containing only the "use strict" directive.

      return /^(?:\/\*+[\w\W]*?\*\/|\/\/.*?[\n\r\u2028\u2029]|\s)*(["'])use strict\1;?$/.test(result) ? '' : result;
    }
    /**
     * Checks if an object is of the specified class.
     *
     * @private
     * @param {*} value The value to check.
     * @param {string} name The name of the class.
     * @returns {boolean} Returns `true` if the value is of the specified class, else `false`.
     */


    function isClassOf(value, name) {
      return value != null && toString.call(value) == '[object ' + name + ']';
    }
    /**
     * Host objects can return type values that are different from their actual
     * data type. The objects we are concerned with usually return non-primitive
     * types of "object", "function", or "unknown".
     *
     * @private
     * @param {*} object The owner of the property.
     * @param {string} property The property to check.
     * @returns {boolean} Returns `true` if the property value is a non-primitive, else `false`.
     */


    function isHostType(object, property) {
      if (object == null) {
        return false;
      }

      var type = typeof object[property];
      return !rePrimitive.test(type) && (type != 'object' || !!object[property]);
    }
    /**
     * Checks if a value can be safely coerced to a string.
     *
     * @private
     * @param {*} value The value to check.
     * @returns {boolean} Returns `true` if the value can be coerced, else `false`.
     */


    function isStringable(value) {
      return _.isString(value) || _.has(value, 'toString') && _.isFunction(value.toString);
    }
    /**
     * Runs a snippet of JavaScript via script injection.
     *
     * @private
     * @param {string} code The code to run.
     */


    function runScript(code) {
      var anchor = freeDefine ? __webpack_require__.amdO : Benchmark,
          script = doc.createElement('script'),
          sibling = doc.getElementsByTagName('script')[0],
          parent = sibling.parentNode,
          prop = uid + 'runScript',
          prefix = '(' + (freeDefine ? 'define.amd.' : 'Benchmark.') + prop + '||function(){})();'; // Firefox 2.0.0.2 cannot use script injection as intended because it executes
      // asynchronously, but that's OK because script injection is only used to avoid
      // the previously commented JaegerMonkey bug.

      try {
        // Remove the inserted script *before* running the code to avoid differences
        // in the expected script element count/order of the document.
        script.appendChild(doc.createTextNode(prefix + code));

        anchor[prop] = function () {
          destroyElement(script);
        };
      } catch (e) {
        parent = parent.cloneNode(false);
        sibling = null;
        script.text = code;
      }

      parent.insertBefore(script, sibling);
      delete anchor[prop];
    }
    /**
     * A helper function for setting options/event handlers.
     *
     * @private
     * @param {Object} object The benchmark or suite instance.
     * @param {Object} [options={}] Options object.
     */


    function setOptions(object, options) {
      options = object.options = _.assign({}, cloneDeep(object.constructor.options), cloneDeep(options));

      _.forOwn(options, function (value, key) {
        if (value != null) {
          // Add event listeners.
          if (/^on[A-Z]/.test(key)) {
            _.each(key.split(' '), function (key) {
              object.on(key.slice(2).toLowerCase(), value);
            });
          } else if (!_.has(object, key)) {
            object[key] = cloneDeep(value);
          }
        }
      });
    }
    /*------------------------------------------------------------------------*/

    /**
     * Handles cycling/completing the deferred benchmark.
     *
     * @memberOf Benchmark.Deferred
     */


    function resolve() {
      var deferred = this,
          clone = deferred.benchmark,
          bench = clone._original;

      if (bench.aborted) {
        // cycle() -> clone cycle/complete event -> compute()'s invoked bench.run() cycle/complete.
        deferred.teardown();
        clone.running = false;
        cycle(deferred);
      } else if (++deferred.cycles < clone.count) {
        clone.compiled.call(deferred, context, timer);
      } else {
        timer.stop(deferred);
        deferred.teardown();
        delay(clone, function () {
          cycle(deferred);
        });
      }
    }
    /*------------------------------------------------------------------------*/

    /**
     * A generic `Array#filter` like method.
     *
     * @static
     * @memberOf Benchmark
     * @param {Array} array The array to iterate over.
     * @param {Function|string} callback The function/alias called per iteration.
     * @returns {Array} A new array of values that passed callback filter.
     * @example
     *
     * // get odd numbers
     * Benchmark.filter([1, 2, 3, 4, 5], function(n) {
     *   return n % 2;
     * }); // -> [1, 3, 5];
     *
     * // get fastest benchmarks
     * Benchmark.filter(benches, 'fastest');
     *
     * // get slowest benchmarks
     * Benchmark.filter(benches, 'slowest');
     *
     * // get benchmarks that completed without erroring
     * Benchmark.filter(benches, 'successful');
     */


    function filter(array, callback) {
      if (callback === 'successful') {
        // Callback to exclude those that are errored, unrun, or have hz of Infinity.
        callback = function callback(bench) {
          return bench.cycles && _.isFinite(bench.hz) && !bench.error;
        };
      } else if (callback === 'fastest' || callback === 'slowest') {
        // Get successful, sort by period + margin of error, and filter fastest/slowest.
        var result = filter(array, 'successful').sort(function (a, b) {
          a = a.stats;
          b = b.stats;
          return (a.mean + a.moe > b.mean + b.moe ? 1 : -1) * (callback === 'fastest' ? 1 : -1);
        });
        return _.filter(result, function (bench) {
          return result[0].compare(bench) == 0;
        });
      }

      return _.filter(array, callback);
    }
    /**
     * Converts a number to a more readable comma-separated string representation.
     *
     * @static
     * @memberOf Benchmark
     * @param {number} number The number to convert.
     * @returns {string} The more readable string representation.
     */


    function formatNumber(number) {
      number = String(number).split('.');
      return number[0].replace(/(?=(?:\d{3})+$)(?!\b)/g, ',') + (number[1] ? '.' + number[1] : '');
    }
    /**
     * Invokes a method on all items in an array.
     *
     * @static
     * @memberOf Benchmark
     * @param {Array} benches Array of benchmarks to iterate over.
     * @param {Object|string} name The name of the method to invoke OR options object.
     * @param {...*} [args] Arguments to invoke the method with.
     * @returns {Array} A new array of values returned from each method invoked.
     * @example
     *
     * // invoke `reset` on all benchmarks
     * Benchmark.invoke(benches, 'reset');
     *
     * // invoke `emit` with arguments
     * Benchmark.invoke(benches, 'emit', 'complete', listener);
     *
     * // invoke `run(true)`, treat benchmarks as a queue, and register invoke callbacks
     * Benchmark.invoke(benches, {
     *
     *   // invoke the `run` method
     *   'name': 'run',
     *
     *   // pass a single argument
     *   'args': true,
     *
     *   // treat as queue, removing benchmarks from front of `benches` until empty
     *   'queued': true,
     *
     *   // called before any benchmarks have been invoked.
     *   'onStart': onStart,
     *
     *   // called between invoking benchmarks
     *   'onCycle': onCycle,
     *
     *   // called after all benchmarks have been invoked.
     *   'onComplete': onComplete
     * });
     */


    function invoke(benches, name) {
      var args,
          bench,
          queued,
          index = -1,
          eventProps = {
        'currentTarget': benches
      },
          options = {
        'onStart': _.noop,
        'onCycle': _.noop,
        'onComplete': _.noop
      },
          result = _.toArray(benches);
      /**
       * Invokes the method of the current object and if synchronous, fetches the next.
       */


      function execute() {
        var listeners,
            async = isAsync(bench);

        if (async) {
          // Use `getNext` as the first listener.
          bench.on('complete', getNext);
          listeners = bench.events.complete;
          listeners.splice(0, 0, listeners.pop());
        } // Execute method.


        result[index] = _.isFunction(bench && bench[name]) ? bench[name].apply(bench, args) : undefined; // If synchronous return `true` until finished.

        return !async && getNext();
      }
      /**
       * Fetches the next bench or executes `onComplete` callback.
       */


      function getNext(event) {
        var cycleEvent,
            last = bench,
            async = isAsync(last);

        if (async) {
          last.off('complete', getNext);
          last.emit('complete');
        } // Emit "cycle" event.


        eventProps.type = 'cycle';
        eventProps.target = last;
        cycleEvent = Event(eventProps);
        options.onCycle.call(benches, cycleEvent); // Choose next benchmark if not exiting early.

        if (!cycleEvent.aborted && raiseIndex() !== false) {
          bench = queued ? benches[0] : result[index];

          if (isAsync(bench)) {
            delay(bench, execute);
          } else if (async) {
            // Resume execution if previously asynchronous but now synchronous.
            while (execute()) {}
          } else {
            // Continue synchronous execution.
            return true;
          }
        } else {
          // Emit "complete" event.
          eventProps.type = 'complete';
          options.onComplete.call(benches, Event(eventProps));
        } // When used as a listener `event.aborted = true` will cancel the rest of
        // the "complete" listeners because they were already called above and when
        // used as part of `getNext` the `return false` will exit the execution while-loop.


        if (event) {
          event.aborted = true;
        } else {
          return false;
        }
      }
      /**
       * Checks if invoking `Benchmark#run` with asynchronous cycles.
       */


      function isAsync(object) {
        // Avoid using `instanceof` here because of IE memory leak issues with host objects.
        var async = args[0] && args[0].async;
        return name == 'run' && object instanceof Benchmark && ((async == null ? object.options.async : async) && support.timeout || object.defer);
      }
      /**
       * Raises `index` to the next defined index or returns `false`.
       */


      function raiseIndex() {
        index++; // If queued remove the previous bench.

        if (queued && index > 0) {
          shift.call(benches);
        } // If we reached the last index then return `false`.


        return (queued ? benches.length : index < result.length) ? index : index = false;
      } // Juggle arguments.


      if (_.isString(name)) {
        // 2 arguments (array, name).
        args = slice.call(arguments, 2);
      } else {
        // 2 arguments (array, options).
        options = _.assign(options, name);
        name = options.name;
        args = _.isArray(args = 'args' in options ? options.args : []) ? args : [args];
        queued = options.queued;
      } // Start iterating over the array.


      if (raiseIndex() !== false) {
        // Emit "start" event.
        bench = result[index];
        eventProps.type = 'start';
        eventProps.target = bench;
        options.onStart.call(benches, Event(eventProps)); // End early if the suite was aborted in an "onStart" listener.

        if (name == 'run' && benches instanceof Suite && benches.aborted) {
          // Emit "cycle" event.
          eventProps.type = 'cycle';
          options.onCycle.call(benches, Event(eventProps)); // Emit "complete" event.

          eventProps.type = 'complete';
          options.onComplete.call(benches, Event(eventProps));
        } // Start method execution.
        else {
            if (isAsync(bench)) {
              delay(bench, execute);
            } else {
              while (execute()) {}
            }
          }
      }

      return result;
    }
    /**
     * Creates a string of joined array values or object key-value pairs.
     *
     * @static
     * @memberOf Benchmark
     * @param {Array|Object} object The object to operate on.
     * @param {string} [separator1=','] The separator used between key-value pairs.
     * @param {string} [separator2=': '] The separator used between keys and values.
     * @returns {string} The joined result.
     */


    function join(object, separator1, separator2) {
      var result = [],
          length = (object = Object(object)).length,
          arrayLike = length === length >>> 0;
      separator2 || (separator2 = ': ');

      _.each(object, function (value, key) {
        result.push(arrayLike ? value : key + separator2 + value);
      });

      return result.join(separator1 || ',');
    }
    /*------------------------------------------------------------------------*/

    /**
     * Aborts all benchmarks in the suite.
     *
     * @name abort
     * @memberOf Benchmark.Suite
     * @returns {Object} The suite instance.
     */


    function abortSuite() {
      var event,
          suite = this,
          resetting = calledBy.resetSuite;

      if (suite.running) {
        event = Event('abort');
        suite.emit(event);

        if (!event.cancelled || resetting) {
          // Avoid infinite recursion.
          calledBy.abortSuite = true;
          suite.reset();
          delete calledBy.abortSuite;

          if (!resetting) {
            suite.aborted = true;
            invoke(suite, 'abort');
          }
        }
      }

      return suite;
    }
    /**
     * Adds a test to the benchmark suite.
     *
     * @memberOf Benchmark.Suite
     * @param {string} name A name to identify the benchmark.
     * @param {Function|string} fn The test to benchmark.
     * @param {Object} [options={}] Options object.
     * @returns {Object} The suite instance.
     * @example
     *
     * // basic usage
     * suite.add(fn);
     *
     * // or using a name first
     * suite.add('foo', fn);
     *
     * // or with options
     * suite.add('foo', fn, {
     *   'onCycle': onCycle,
     *   'onComplete': onComplete
     * });
     *
     * // or name and options
     * suite.add('foo', {
     *   'fn': fn,
     *   'onCycle': onCycle,
     *   'onComplete': onComplete
     * });
     *
     * // or options only
     * suite.add({
     *   'name': 'foo',
     *   'fn': fn,
     *   'onCycle': onCycle,
     *   'onComplete': onComplete
     * });
     */


    function add(name, fn, options) {
      var suite = this,
          bench = new Benchmark(name, fn, options),
          event = Event({
        'type': 'add',
        'target': bench
      });

      if (suite.emit(event), !event.cancelled) {
        suite.push(bench);
      }

      return suite;
    }
    /**
     * Creates a new suite with cloned benchmarks.
     *
     * @name clone
     * @memberOf Benchmark.Suite
     * @param {Object} options Options object to overwrite cloned options.
     * @returns {Object} The new suite instance.
     */


    function cloneSuite(options) {
      var suite = this,
          result = new suite.constructor(_.assign({}, suite.options, options)); // Copy own properties.

      _.forOwn(suite, function (value, key) {
        if (!_.has(result, key)) {
          result[key] = value && _.isFunction(value.clone) ? value.clone() : cloneDeep(value);
        }
      });

      return result;
    }
    /**
     * An `Array#filter` like method.
     *
     * @name filter
     * @memberOf Benchmark.Suite
     * @param {Function|string} callback The function/alias called per iteration.
     * @returns {Object} A new suite of benchmarks that passed callback filter.
     */


    function filterSuite(callback) {
      var suite = this,
          result = new suite.constructor(suite.options);
      result.push.apply(result, filter(suite, callback));
      return result;
    }
    /**
     * Resets all benchmarks in the suite.
     *
     * @name reset
     * @memberOf Benchmark.Suite
     * @returns {Object} The suite instance.
     */


    function resetSuite() {
      var event,
          suite = this,
          aborting = calledBy.abortSuite;

      if (suite.running && !aborting) {
        // No worries, `resetSuite()` is called within `abortSuite()`.
        calledBy.resetSuite = true;
        suite.abort();
        delete calledBy.resetSuite;
      } // Reset if the state has changed.
      else if ((suite.aborted || suite.running) && (suite.emit(event = Event('reset')), !event.cancelled)) {
          suite.aborted = suite.running = false;

          if (!aborting) {
            invoke(suite, 'reset');
          }
        }

      return suite;
    }
    /**
     * Runs the suite.
     *
     * @name run
     * @memberOf Benchmark.Suite
     * @param {Object} [options={}] Options object.
     * @returns {Object} The suite instance.
     * @example
     *
     * // basic usage
     * suite.run();
     *
     * // or with options
     * suite.run({ 'async': true, 'queued': true });
     */


    function runSuite(options) {
      var suite = this;
      suite.reset();
      suite.running = true;
      options || (options = {});
      invoke(suite, {
        'name': 'run',
        'args': options,
        'queued': options.queued,
        'onStart': function () {
          function onStart(event) {
            suite.emit(event);
          }

          return onStart;
        }(),
        'onCycle': function () {
          function onCycle(event) {
            var bench = event.target;

            if (bench.error) {
              suite.emit({
                'type': 'error',
                'target': bench
              });
            }

            suite.emit(event);
            event.aborted = suite.aborted;
          }

          return onCycle;
        }(),
        'onComplete': function () {
          function onComplete(event) {
            suite.running = false;
            suite.emit(event);
          }

          return onComplete;
        }()
      });
      return suite;
    }
    /*------------------------------------------------------------------------*/

    /**
     * Executes all registered listeners of the specified event type.
     *
     * @memberOf Benchmark, Benchmark.Suite
     * @param {Object|string} type The event type or object.
     * @param {...*} [args] Arguments to invoke the listener with.
     * @returns {*} Returns the return value of the last listener executed.
     */


    function emit(type) {
      var listeners,
          object = this,
          event = Event(type),
          events = object.events,
          args = (arguments[0] = event, arguments);
      event.currentTarget || (event.currentTarget = object);
      event.target || (event.target = object);
      delete event.result;

      if (events && (listeners = _.has(events, event.type) && events[event.type])) {
        _.each(listeners.slice(), function (listener) {
          if ((event.result = listener.apply(object, args)) === false) {
            event.cancelled = true;
          }

          return !event.aborted;
        });
      }

      return event.result;
    }
    /**
     * Returns an array of event listeners for a given type that can be manipulated
     * to add or remove listeners.
     *
     * @memberOf Benchmark, Benchmark.Suite
     * @param {string} type The event type.
     * @returns {Array} The listeners array.
     */


    function listeners(type) {
      var object = this,
          events = object.events || (object.events = {});
      return _.has(events, type) ? events[type] : events[type] = [];
    }
    /**
     * Unregisters a listener for the specified event type(s),
     * or unregisters all listeners for the specified event type(s),
     * or unregisters all listeners for all event types.
     *
     * @memberOf Benchmark, Benchmark.Suite
     * @param {string} [type] The event type.
     * @param {Function} [listener] The function to unregister.
     * @returns {Object} The current instance.
     * @example
     *
     * // unregister a listener for an event type
     * bench.off('cycle', listener);
     *
     * // unregister a listener for multiple event types
     * bench.off('start cycle', listener);
     *
     * // unregister all listeners for an event type
     * bench.off('cycle');
     *
     * // unregister all listeners for multiple event types
     * bench.off('start cycle complete');
     *
     * // unregister all listeners for all event types
     * bench.off();
     */


    function off(type, listener) {
      var object = this,
          events = object.events;

      if (!events) {
        return object;
      }

      _.each(type ? type.split(' ') : events, function (listeners, type) {
        var index;

        if (typeof listeners == 'string') {
          type = listeners;
          listeners = _.has(events, type) && events[type];
        }

        if (listeners) {
          if (listener) {
            index = _.indexOf(listeners, listener);

            if (index > -1) {
              listeners.splice(index, 1);
            }
          } else {
            listeners.length = 0;
          }
        }
      });

      return object;
    }
    /**
     * Registers a listener for the specified event type(s).
     *
     * @memberOf Benchmark, Benchmark.Suite
     * @param {string} type The event type.
     * @param {Function} listener The function to register.
     * @returns {Object} The current instance.
     * @example
     *
     * // register a listener for an event type
     * bench.on('cycle', listener);
     *
     * // register a listener for multiple event types
     * bench.on('start cycle', listener);
     */


    function on(type, listener) {
      var object = this,
          events = object.events || (object.events = {});

      _.each(type.split(' '), function (type) {
        (_.has(events, type) ? events[type] : events[type] = []).push(listener);
      });

      return object;
    }
    /*------------------------------------------------------------------------*/

    /**
     * Aborts the benchmark without recording times.
     *
     * @memberOf Benchmark
     * @returns {Object} The benchmark instance.
     */


    function abort() {
      var event,
          bench = this,
          resetting = calledBy.reset;

      if (bench.running) {
        event = Event('abort');
        bench.emit(event);

        if (!event.cancelled || resetting) {
          // Avoid infinite recursion.
          calledBy.abort = true;
          bench.reset();
          delete calledBy.abort;

          if (support.timeout) {
            clearTimeout(bench._timerId);
            delete bench._timerId;
          }

          if (!resetting) {
            bench.aborted = true;
            bench.running = false;
          }
        }
      }

      return bench;
    }
    /**
     * Creates a new benchmark using the same test and options.
     *
     * @memberOf Benchmark
     * @param {Object} options Options object to overwrite cloned options.
     * @returns {Object} The new benchmark instance.
     * @example
     *
     * var bizarro = bench.clone({
     *   'name': 'doppelganger'
     * });
     */


    function clone(options) {
      var bench = this,
          result = new bench.constructor(_.assign({}, bench, options)); // Correct the `options` object.

      result.options = _.assign({}, cloneDeep(bench.options), cloneDeep(options)); // Copy own custom properties.

      _.forOwn(bench, function (value, key) {
        if (!_.has(result, key)) {
          result[key] = cloneDeep(value);
        }
      });

      return result;
    }
    /**
     * Determines if a benchmark is faster than another.
     *
     * @memberOf Benchmark
     * @param {Object} other The benchmark to compare.
     * @returns {number} Returns `-1` if slower, `1` if faster, and `0` if indeterminate.
     */


    function compare(other) {
      var bench = this; // Exit early if comparing the same benchmark.

      if (bench == other) {
        return 0;
      }

      var critical,
          zStat,
          sample1 = bench.stats.sample,
          sample2 = other.stats.sample,
          size1 = sample1.length,
          size2 = sample2.length,
          maxSize = max(size1, size2),
          minSize = min(size1, size2),
          u1 = getU(sample1, sample2),
          u2 = getU(sample2, sample1),
          u = min(u1, u2);

      function getScore(xA, sampleB) {
        return _.reduce(sampleB, function (total, xB) {
          return total + (xB > xA ? 0 : xB < xA ? 1 : 0.5);
        }, 0);
      }

      function getU(sampleA, sampleB) {
        return _.reduce(sampleA, function (total, xA) {
          return total + getScore(xA, sampleB);
        }, 0);
      }

      function getZ(u) {
        return (u - size1 * size2 / 2) / sqrt(size1 * size2 * (size1 + size2 + 1) / 12);
      } // Reject the null hypothesis the two samples come from the
      // same population (i.e. have the same median) if...


      if (size1 + size2 > 30) {
        // ...the z-stat is greater than 1.96 or less than -1.96
        // http://www.statisticslectures.com/topics/mannwhitneyu/
        zStat = getZ(u);
        return abs(zStat) > 1.96 ? u == u1 ? 1 : -1 : 0;
      } // ...the U value is less than or equal the critical U value.


      critical = maxSize < 5 || minSize < 3 ? 0 : uTable[maxSize][minSize - 3];
      return u <= critical ? u == u1 ? 1 : -1 : 0;
    }
    /**
     * Reset properties and abort if running.
     *
     * @memberOf Benchmark
     * @returns {Object} The benchmark instance.
     */


    function reset() {
      var bench = this;

      if (bench.running && !calledBy.abort) {
        // No worries, `reset()` is called within `abort()`.
        calledBy.reset = true;
        bench.abort();
        delete calledBy.reset;
        return bench;
      }

      var event,
          index = 0,
          changes = [],
          queue = []; // A non-recursive solution to check if properties have changed.
      // For more information see http://www.jslab.dk/articles/non.recursive.preorder.traversal.part4.

      var data = {
        'destination': bench,
        'source': _.assign({}, cloneDeep(bench.constructor.prototype), cloneDeep(bench.options))
      };

      do {
        _.forOwn(data.source, function (value, key) {
          var changed,
              destination = data.destination,
              currValue = destination[key]; // Skip pseudo private properties like `_timerId` which could be a
          // Java object in environments like RingoJS.

          if (key.charAt(0) == '_') {
            return;
          }

          if (value && typeof value == 'object') {
            if (_.isArray(value)) {
              // Check if an array value has changed to a non-array value.
              if (!_.isArray(currValue)) {
                changed = currValue = [];
              } // Check if an array has changed its length.


              if (currValue.length != value.length) {
                changed = currValue = currValue.slice(0, value.length);
                currValue.length = value.length;
              }
            } // Check if an object has changed to a non-object value.
            else if (!currValue || typeof currValue != 'object') {
                changed = currValue = {};
              } // Register a changed object.


            if (changed) {
              changes.push({
                'destination': destination,
                'key': key,
                'value': currValue
              });
            }

            queue.push({
              'destination': currValue,
              'source': value
            });
          } // Register a changed primitive.
          else if (value !== currValue && !(value == null || _.isFunction(value))) {
              changes.push({
                'destination': destination,
                'key': key,
                'value': value
              });
            }
        });
      } while (data = queue[index++]); // If changed emit the `reset` event and if it isn't cancelled reset the benchmark.


      if (changes.length && (bench.emit(event = Event('reset')), !event.cancelled)) {
        _.each(changes, function (data) {
          data.destination[data.key] = data.value;
        });
      }

      return bench;
    }
    /**
     * Displays relevant benchmark information when coerced to a string.
     *
     * @name toString
     * @memberOf Benchmark
     * @returns {string} A string representation of the benchmark instance.
     */


    function toStringBench() {
      var bench = this,
          error = bench.error,
          hz = bench.hz,
          id = bench.id,
          stats = bench.stats,
          size = stats.sample.length,
          pm = '\xb1',
          result = bench.name || (_.isNaN(id) ? id : '<Test #' + id + '>');

      if (error) {
        var errorStr;

        if (!_.isObject(error)) {
          errorStr = String(error);
        } else if (!_.isError(Error)) {
          errorStr = join(error);
        } else {
          // Error#name and Error#message properties are non-enumerable.
          errorStr = join(_.assign({
            'name': error.name,
            'message': error.message
          }, error));
        }

        result += ': ' + errorStr;
      } else {
        result += ' x ' + formatNumber(hz.toFixed(hz < 100 ? 2 : 0)) + ' ops/sec ' + pm + stats.rme.toFixed(2) + '% (' + size + ' run' + (size == 1 ? '' : 's') + ' sampled)';
      }

      return result;
    }
    /*------------------------------------------------------------------------*/

    /**
     * Clocks the time taken to execute a test per cycle (secs).
     *
     * @private
     * @param {Object} bench The benchmark instance.
     * @returns {number} The time taken.
     */


    function clock() {
      var options = Benchmark.options,
          templateData = {},
          timers = [{
        'ns': timer.ns,
        'res': max(0.0015, getRes('ms')),
        'unit': 'ms'
      }]; // Lazy define for hi-res timers.

      clock = function clock(clone) {
        var deferred;

        if (clone instanceof Deferred) {
          deferred = clone;
          clone = deferred.benchmark;
        }

        var bench = clone._original,
            stringable = isStringable(bench.fn),
            count = bench.count = clone.count,
            decompilable = stringable || support.decompilation && (clone.setup !== _.noop || clone.teardown !== _.noop),
            id = bench.id,
            name = bench.name || (typeof id == 'number' ? '<Test #' + id + '>' : id),
            result = 0; // Init `minTime` if needed.

        clone.minTime = bench.minTime || (bench.minTime = bench.options.minTime = options.minTime); // Compile in setup/teardown functions and the test loop.
        // Create a new compiled test, instead of using the cached `bench.compiled`,
        // to avoid potential engine optimizations enabled over the life of the test.

        var funcBody = deferred ? 'var d#=this,${fnArg}=d#,m#=d#.benchmark._original,f#=m#.fn,su#=m#.setup,td#=m#.teardown;' + // When `deferred.cycles` is `0` then...
        'if(!d#.cycles){' + // set `deferred.fn`,
        'd#.fn=function(){var ${fnArg}=d#;if(typeof f#=="function"){try{${fn}\n}catch(e#){f#(d#)}}else{${fn}\n}};' + // set `deferred.teardown`,
        'd#.teardown=function(){d#.cycles=0;if(typeof td#=="function"){try{${teardown}\n}catch(e#){td#()}}else{${teardown}\n}};' + // execute the benchmark's `setup`,
        'if(typeof su#=="function"){try{${setup}\n}catch(e#){su#()}}else{${setup}\n};' + // start timer,
        't#.start(d#);' + // and then execute `deferred.fn` and return a dummy object.
        '}d#.fn();return{uid:"${uid}"}' : 'var r#,s#,m#=this,f#=m#.fn,i#=m#.count,n#=t#.ns;${setup}\n${begin};' + 'while(i#--){${fn}\n}${end};${teardown}\nreturn{elapsed:r#,uid:"${uid}"}';
        var compiled = bench.compiled = clone.compiled = createCompiled(bench, decompilable, deferred, funcBody),
            isEmpty = !(templateData.fn || stringable);

        try {
          if (isEmpty) {
            // Firefox may remove dead code from `Function#toString` results.
            // For more information see http://bugzil.la/536085.
            throw new Error('The test "' + name + '" is empty. This may be the result of dead code removal.');
          } else if (!deferred) {
            // Pretest to determine if compiled code exits early, usually by a
            // rogue `return` statement, by checking for a return object with the uid.
            bench.count = 1;
            compiled = decompilable && (compiled.call(bench, context, timer) || {}).uid == templateData.uid && compiled;
            bench.count = count;
          }
        } catch (e) {
          compiled = null;
          clone.error = e || new Error(String(e));
          bench.count = count;
        } // Fallback when a test exits early or errors during pretest.


        if (!compiled && !deferred && !isEmpty) {
          funcBody = (stringable || decompilable && !clone.error ? 'function f#(){${fn}\n}var r#,s#,m#=this,i#=m#.count' : 'var r#,s#,m#=this,f#=m#.fn,i#=m#.count') + ',n#=t#.ns;${setup}\n${begin};m#.f#=f#;while(i#--){m#.f#()}${end};' + 'delete m#.f#;${teardown}\nreturn{elapsed:r#}';
          compiled = createCompiled(bench, decompilable, deferred, funcBody);

          try {
            // Pretest one more time to check for errors.
            bench.count = 1;
            compiled.call(bench, context, timer);
            bench.count = count;
            delete clone.error;
          } catch (e) {
            bench.count = count;

            if (!clone.error) {
              clone.error = e || new Error(String(e));
            }
          }
        } // If no errors run the full test loop.


        if (!clone.error) {
          compiled = bench.compiled = clone.compiled = createCompiled(bench, decompilable, deferred, funcBody);
          result = compiled.call(deferred || bench, context, timer).elapsed;
        }

        return result;
      };
      /*----------------------------------------------------------------------*/

      /**
       * Creates a compiled function from the given function `body`.
       */


      function createCompiled(bench, decompilable, deferred, body) {
        var fn = bench.fn,
            fnArg = deferred ? getFirstArgument(fn) || 'deferred' : '';
        templateData.uid = uid + uidCounter++;

        _.assign(templateData, {
          'setup': decompilable ? getSource(bench.setup) : interpolate('m#.setup()'),
          'fn': decompilable ? getSource(fn) : interpolate('m#.fn(' + fnArg + ')'),
          'fnArg': fnArg,
          'teardown': decompilable ? getSource(bench.teardown) : interpolate('m#.teardown()')
        }); // Use API of chosen timer.


        if (timer.unit == 'ns') {
          _.assign(templateData, {
            'begin': interpolate('s#=n#()'),
            'end': interpolate('r#=n#(s#);r#=r#[0]+(r#[1]/1e9)')
          });
        } else if (timer.unit == 'us') {
          if (timer.ns.stop) {
            _.assign(templateData, {
              'begin': interpolate('s#=n#.start()'),
              'end': interpolate('r#=n#.microseconds()/1e6')
            });
          } else {
            _.assign(templateData, {
              'begin': interpolate('s#=n#()'),
              'end': interpolate('r#=(n#()-s#)/1e6')
            });
          }
        } else if (timer.ns.now) {
          _.assign(templateData, {
            'begin': interpolate('s#=n#.now()'),
            'end': interpolate('r#=(n#.now()-s#)/1e3')
          });
        } else {
          _.assign(templateData, {
            'begin': interpolate('s#=new n#().getTime()'),
            'end': interpolate('r#=(new n#().getTime()-s#)/1e3')
          });
        } // Define `timer` methods.


        timer.start = createFunction(interpolate('o#'), interpolate('var n#=this.ns,${begin};o#.elapsed=0;o#.timeStamp=s#'));
        timer.stop = createFunction(interpolate('o#'), interpolate('var n#=this.ns,s#=o#.timeStamp,${end};o#.elapsed=r#')); // Create compiled test.

        return createFunction(interpolate('window,t#'), 'var global = window, clearTimeout = global.clearTimeout, setTimeout = global.setTimeout;\n' + interpolate(body));
      }
      /**
       * Gets the current timer's minimum resolution (secs).
       */


      function getRes(unit) {
        var measured,
            begin,
            count = 30,
            divisor = 1e3,
            ns = timer.ns,
            sample = []; // Get average smallest measurable time.

        while (count--) {
          if (unit == 'us') {
            divisor = 1e6;

            if (ns.stop) {
              ns.start();

              while (!(measured = ns.microseconds())) {}
            } else {
              begin = ns();

              while (!(measured = ns() - begin)) {}
            }
          } else if (unit == 'ns') {
            divisor = 1e9;
            begin = (begin = ns())[0] + begin[1] / divisor;

            while (!(measured = (measured = ns())[0] + measured[1] / divisor - begin)) {}

            divisor = 1;
          } else if (ns.now) {
            begin = ns.now();

            while (!(measured = ns.now() - begin)) {}
          } else {
            begin = new ns().getTime();

            while (!(measured = new ns().getTime() - begin)) {}
          } // Check for broken timers.


          if (measured > 0) {
            sample.push(measured);
          } else {
            sample.push(Infinity);
            break;
          }
        } // Convert to seconds.


        return getMean(sample) / divisor;
      }
      /**
       * Interpolates a given template string.
       */


      function interpolate(string) {
        // Replaces all occurrences of `#` with a unique number and template tokens with content.
        return _.template(string.replace(/\#/g, /\d+/.exec(templateData.uid)))(templateData);
      }
      /*----------------------------------------------------------------------*/
      // Detect Chrome's microsecond timer:
      // enable benchmarking via the --enable-benchmarking command
      // line switch in at least Chrome 7 to use chrome.Interval


      try {
        if (timer.ns = new (context.chrome || context.chromium).Interval()) {
          timers.push({
            'ns': timer.ns,
            'res': getRes('us'),
            'unit': 'us'
          });
        }
      } catch (e) {} // Detect Node.js's nanosecond resolution timer available in Node.js >= 0.8.


      if (processObject && typeof (timer.ns = processObject.hrtime) == 'function') {
        timers.push({
          'ns': timer.ns,
          'res': getRes('ns'),
          'unit': 'ns'
        });
      } // Pick timer with highest resolution.


      timer = _.minBy(timers, 'res'); // Error if there are no working timers.

      if (timer.res == Infinity) {
        throw new Error('Benchmark.js was unable to find a working timer.');
      } // Resolve time span required to achieve a percent uncertainty of at most 1%.
      // For more information see http://spiff.rit.edu/classes/phys273/uncert/uncert.html.


      options.minTime || (options.minTime = max(timer.res / 2 / 0.01, 0.05));
      return clock.apply(null, arguments);
    }
    /*------------------------------------------------------------------------*/

    /**
     * Computes stats on benchmark results.
     *
     * @private
     * @param {Object} bench The benchmark instance.
     * @param {Object} options The options object.
     */


    function compute(bench, options) {
      options || (options = {});
      var async = options.async,
          elapsed = 0,
          initCount = bench.initCount,
          minSamples = bench.minSamples,
          queue = [],
          sample = bench.stats.sample;
      /**
       * Adds a clone to the queue.
       */

      function enqueue() {
        queue.push(bench.clone({
          '_original': bench,
          'events': {
            'abort': [update],
            'cycle': [update],
            'error': [update],
            'start': [update]
          }
        }));
      }
      /**
       * Updates the clone/original benchmarks to keep their data in sync.
       */


      function update(event) {
        var clone = this,
            type = event.type;

        if (bench.running) {
          if (type == 'start') {
            // Note: `clone.minTime` prop is inited in `clock()`.
            clone.count = bench.initCount;
          } else {
            if (type == 'error') {
              bench.error = clone.error;
            }

            if (type == 'abort') {
              bench.abort();
              bench.emit('cycle');
            } else {
              event.currentTarget = event.target = bench;
              bench.emit(event);
            }
          }
        } else if (bench.aborted) {
          // Clear abort listeners to avoid triggering bench's abort/cycle again.
          clone.events.abort.length = 0;
          clone.abort();
        }
      }
      /**
       * Determines if more clones should be queued or if cycling should stop.
       */


      function evaluate(event) {
        var critical,
            df,
            mean,
            moe,
            rme,
            sd,
            sem,
            variance,
            clone = event.target,
            done = bench.aborted,
            now = _.now(),
            size = sample.push(clone.times.period),
            maxedOut = size >= minSamples && (elapsed += now - clone.times.timeStamp) / 1e3 > bench.maxTime,
            times = bench.times,
            varOf = function varOf(sum, x) {
          return sum + pow(x - mean, 2);
        }; // Exit early for aborted or unclockable tests.


        if (done || clone.hz == Infinity) {
          maxedOut = !(size = sample.length = queue.length = 0);
        }

        if (!done) {
          // Compute the sample mean (estimate of the population mean).
          mean = getMean(sample); // Compute the sample variance (estimate of the population variance).

          variance = _.reduce(sample, varOf, 0) / (size - 1) || 0; // Compute the sample standard deviation (estimate of the population standard deviation).

          sd = sqrt(variance); // Compute the standard error of the mean (a.k.a. the standard deviation of the sampling distribution of the sample mean).

          sem = sd / sqrt(size); // Compute the degrees of freedom.

          df = size - 1; // Compute the critical value.

          critical = tTable[Math.round(df) || 1] || tTable.infinity; // Compute the margin of error.

          moe = sem * critical; // Compute the relative margin of error.

          rme = moe / mean * 100 || 0;

          _.assign(bench.stats, {
            'deviation': sd,
            'mean': mean,
            'moe': moe,
            'rme': rme,
            'sem': sem,
            'variance': variance
          }); // Abort the cycle loop when the minimum sample size has been collected
          // and the elapsed time exceeds the maximum time allowed per benchmark.
          // We don't count cycle delays toward the max time because delays may be
          // increased by browsers that clamp timeouts for inactive tabs. For more
          // information see https://developer.mozilla.org/en/window.setTimeout#Inactive_tabs.


          if (maxedOut) {
            // Reset the `initCount` in case the benchmark is rerun.
            bench.initCount = initCount;
            bench.running = false;
            done = true;
            times.elapsed = (now - times.timeStamp) / 1e3;
          }

          if (bench.hz != Infinity) {
            bench.hz = 1 / mean;
            times.cycle = mean * bench.count;
            times.period = mean;
          }
        } // If time permits, increase sample size to reduce the margin of error.


        if (queue.length < 2 && !maxedOut) {
          enqueue();
        } // Abort the `invoke` cycle when done.


        event.aborted = done;
      } // Init queue and begin.


      enqueue();
      invoke(queue, {
        'name': 'run',
        'args': {
          'async': async
        },
        'queued': true,
        'onCycle': evaluate,
        'onComplete': function () {
          function onComplete() {
            bench.emit('complete');
          }

          return onComplete;
        }()
      });
    }
    /*------------------------------------------------------------------------*/

    /**
     * Cycles a benchmark until a run `count` can be established.
     *
     * @private
     * @param {Object} clone The cloned benchmark instance.
     * @param {Object} options The options object.
     */


    function cycle(clone, options) {
      options || (options = {});
      var deferred;

      if (clone instanceof Deferred) {
        deferred = clone;
        clone = clone.benchmark;
      }

      var clocked,
          cycles,
          divisor,
          event,
          minTime,
          period,
          async = options.async,
          bench = clone._original,
          count = clone.count,
          times = clone.times; // Continue, if not aborted between cycles.

      if (clone.running) {
        // `minTime` is set to `Benchmark.options.minTime` in `clock()`.
        cycles = ++clone.cycles;
        clocked = deferred ? deferred.elapsed : clock(clone);
        minTime = clone.minTime;

        if (cycles > bench.cycles) {
          bench.cycles = cycles;
        }

        if (clone.error) {
          event = Event('error');
          event.message = clone.error;
          clone.emit(event);

          if (!event.cancelled) {
            clone.abort();
          }
        }
      } // Continue, if not errored.


      if (clone.running) {
        // Compute the time taken to complete last test cycle.
        bench.times.cycle = times.cycle = clocked; // Compute the seconds per operation.

        period = bench.times.period = times.period = clocked / count; // Compute the ops per second.

        bench.hz = clone.hz = 1 / period; // Avoid working our way up to this next time.

        bench.initCount = clone.initCount = count; // Do we need to do another cycle?

        clone.running = clocked < minTime;

        if (clone.running) {
          // Tests may clock at `0` when `initCount` is a small number,
          // to avoid that we set its count to something a bit higher.
          if (!clocked && (divisor = divisors[clone.cycles]) != null) {
            count = floor(4e6 / divisor);
          } // Calculate how many more iterations it will take to achieve the `minTime`.


          if (count <= clone.count) {
            count += Math.ceil((minTime - clocked) / period);
          }

          clone.running = count != Infinity;
        }
      } // Should we exit early?


      event = Event('cycle');
      clone.emit(event);

      if (event.aborted) {
        clone.abort();
      } // Figure out what to do next.


      if (clone.running) {
        // Start a new cycle.
        clone.count = count;

        if (deferred) {
          clone.compiled.call(deferred, context, timer);
        } else if (async) {
          delay(clone, function () {
            cycle(clone, options);
          });
        } else {
          cycle(clone);
        }
      } else {
        // Fix TraceMonkey bug associated with clock fallbacks.
        // For more information see http://bugzil.la/509069.
        if (support.browser) {
          runScript(uid + '=1;delete ' + uid);
        } // We're done.


        clone.emit('complete');
      }
    }
    /*------------------------------------------------------------------------*/

    /**
     * Runs the benchmark.
     *
     * @memberOf Benchmark
     * @param {Object} [options={}] Options object.
     * @returns {Object} The benchmark instance.
     * @example
     *
     * // basic usage
     * bench.run();
     *
     * // or with options
     * bench.run({ 'async': true });
     */


    function run(options) {
      var bench = this,
          event = Event('start'); // Set `running` to `false` so `reset()` won't call `abort()`.

      bench.running = false;
      bench.reset();
      bench.running = true;
      bench.count = bench.initCount;
      bench.times.timeStamp = _.now();
      bench.emit(event);

      if (!event.cancelled) {
        options = {
          'async': ((options = options && options.async) == null ? bench.async : options) && support.timeout
        }; // For clones created within `compute()`.

        if (bench._original) {
          if (bench.defer) {
            Deferred(bench);
          } else {
            cycle(bench, options);
          }
        } // For original benchmarks.
        else {
            compute(bench, options);
          }
      }

      return bench;
    }
    /*------------------------------------------------------------------------*/
    // Firefox 1 erroneously defines variable and argument names of functions on
    // the function itself as non-configurable properties with `undefined` values.
    // The bugginess continues as the `Benchmark` constructor has an argument
    // named `options` and Firefox 1 will not assign a value to `Benchmark.options`,
    // making it non-writable in the process, unless it is the first property
    // assigned by for-in loop of `_.assign()`.


    _.assign(Benchmark, {
      /**
       * The default options copied by benchmark instances.
       *
       * @static
       * @memberOf Benchmark
       * @type Object
       */
      'options': {
        /**
         * A flag to indicate that benchmark cycles will execute asynchronously
         * by default.
         *
         * @memberOf Benchmark.options
         * @type boolean
         */
        'async': false,

        /**
         * A flag to indicate that the benchmark clock is deferred.
         *
         * @memberOf Benchmark.options
         * @type boolean
         */
        'defer': false,

        /**
         * The delay between test cycles (secs).
         * @memberOf Benchmark.options
         * @type number
         */
        'delay': 0.005,

        /**
         * Displayed by `Benchmark#toString` when a `name` is not available
         * (auto-generated if absent).
         *
         * @memberOf Benchmark.options
         * @type string
         */
        'id': undefined,

        /**
         * The default number of times to execute a test on a benchmark's first cycle.
         *
         * @memberOf Benchmark.options
         * @type number
         */
        'initCount': 1,

        /**
         * The maximum time a benchmark is allowed to run before finishing (secs).
         *
         * Note: Cycle delays aren't counted toward the maximum time.
         *
         * @memberOf Benchmark.options
         * @type number
         */
        'maxTime': 5,

        /**
         * The minimum sample size required to perform statistical analysis.
         *
         * @memberOf Benchmark.options
         * @type number
         */
        'minSamples': 5,

        /**
         * The time needed to reduce the percent uncertainty of measurement to 1% (secs).
         *
         * @memberOf Benchmark.options
         * @type number
         */
        'minTime': 0,

        /**
         * The name of the benchmark.
         *
         * @memberOf Benchmark.options
         * @type string
         */
        'name': undefined,

        /**
         * An event listener called when the benchmark is aborted.
         *
         * @memberOf Benchmark.options
         * @type Function
         */
        'onAbort': undefined,

        /**
         * An event listener called when the benchmark completes running.
         *
         * @memberOf Benchmark.options
         * @type Function
         */
        'onComplete': undefined,

        /**
         * An event listener called after each run cycle.
         *
         * @memberOf Benchmark.options
         * @type Function
         */
        'onCycle': undefined,

        /**
         * An event listener called when a test errors.
         *
         * @memberOf Benchmark.options
         * @type Function
         */
        'onError': undefined,

        /**
         * An event listener called when the benchmark is reset.
         *
         * @memberOf Benchmark.options
         * @type Function
         */
        'onReset': undefined,

        /**
         * An event listener called when the benchmark starts running.
         *
         * @memberOf Benchmark.options
         * @type Function
         */
        'onStart': undefined
      },

      /**
       * Platform object with properties describing things like browser name,
       * version, and operating system. See [`platform.js`](https://mths.be/platform).
       *
       * @static
       * @memberOf Benchmark
       * @type Object
       */
      'platform': context.platform || __webpack_require__(/*! platform */ "./.yarn/cache/platform-npm-1.3.6-8c3cef9352-d4d10d5a55.zip/node_modules/platform/platform.js") || {
        'description': context.navigator && context.navigator.userAgent || null,
        'layout': null,
        'product': null,
        'name': null,
        'manufacturer': null,
        'os': null,
        'prerelease': null,
        'version': null,
        'toString': function () {
          function toString() {
            return this.description || '';
          }

          return toString;
        }()
      },

      /**
       * The semantic version number.
       *
       * @static
       * @memberOf Benchmark
       * @type string
       */
      'version': '2.1.2'
    });

    _.assign(Benchmark, {
      'filter': filter,
      'formatNumber': formatNumber,
      'invoke': invoke,
      'join': join,
      'runInContext': runInContext,
      'support': support
    }); // Add lodash methods to Benchmark.


    _.each(['each', 'forEach', 'forOwn', 'has', 'indexOf', 'map', 'reduce'], function (methodName) {
      Benchmark[methodName] = _[methodName];
    });
    /*------------------------------------------------------------------------*/


    _.assign(Benchmark.prototype, {
      /**
       * The number of times a test was executed.
       *
       * @memberOf Benchmark
       * @type number
       */
      'count': 0,

      /**
       * The number of cycles performed while benchmarking.
       *
       * @memberOf Benchmark
       * @type number
       */
      'cycles': 0,

      /**
       * The number of executions per second.
       *
       * @memberOf Benchmark
       * @type number
       */
      'hz': 0,

      /**
       * The compiled test function.
       *
       * @memberOf Benchmark
       * @type {Function|string}
       */
      'compiled': undefined,

      /**
       * The error object if the test failed.
       *
       * @memberOf Benchmark
       * @type Object
       */
      'error': undefined,

      /**
       * The test to benchmark.
       *
       * @memberOf Benchmark
       * @type {Function|string}
       */
      'fn': undefined,

      /**
       * A flag to indicate if the benchmark is aborted.
       *
       * @memberOf Benchmark
       * @type boolean
       */
      'aborted': false,

      /**
       * A flag to indicate if the benchmark is running.
       *
       * @memberOf Benchmark
       * @type boolean
       */
      'running': false,

      /**
       * Compiled into the test and executed immediately **before** the test loop.
       *
       * @memberOf Benchmark
       * @type {Function|string}
       * @example
       *
       * // basic usage
       * var bench = Benchmark({
       *   'setup': function() {
       *     var c = this.count,
       *         element = document.getElementById('container');
       *     while (c--) {
       *       element.appendChild(document.createElement('div'));
       *     }
       *   },
       *   'fn': function() {
       *     element.removeChild(element.lastChild);
       *   }
       * });
       *
       * // compiles to something like:
       * var c = this.count,
       *     element = document.getElementById('container');
       * while (c--) {
       *   element.appendChild(document.createElement('div'));
       * }
       * var start = new Date;
       * while (count--) {
       *   element.removeChild(element.lastChild);
       * }
       * var end = new Date - start;
       *
       * // or using strings
       * var bench = Benchmark({
       *   'setup': '\
       *     var a = 0;\n\
       *     (function() {\n\
       *       (function() {\n\
       *         (function() {',
       *   'fn': 'a += 1;',
       *   'teardown': '\
       *          }())\n\
       *        }())\n\
       *      }())'
       * });
       *
       * // compiles to something like:
       * var a = 0;
       * (function() {
       *   (function() {
       *     (function() {
       *       var start = new Date;
       *       while (count--) {
       *         a += 1;
       *       }
       *       var end = new Date - start;
       *     }())
       *   }())
       * }())
       */
      'setup': _.noop,

      /**
       * Compiled into the test and executed immediately **after** the test loop.
       *
       * @memberOf Benchmark
       * @type {Function|string}
       */
      'teardown': _.noop,

      /**
       * An object of stats including mean, margin or error, and standard deviation.
       *
       * @memberOf Benchmark
       * @type Object
       */
      'stats': {
        /**
         * The margin of error.
         *
         * @memberOf Benchmark#stats
         * @type number
         */
        'moe': 0,

        /**
         * The relative margin of error (expressed as a percentage of the mean).
         *
         * @memberOf Benchmark#stats
         * @type number
         */
        'rme': 0,

        /**
         * The standard error of the mean.
         *
         * @memberOf Benchmark#stats
         * @type number
         */
        'sem': 0,

        /**
         * The sample standard deviation.
         *
         * @memberOf Benchmark#stats
         * @type number
         */
        'deviation': 0,

        /**
         * The sample arithmetic mean (secs).
         *
         * @memberOf Benchmark#stats
         * @type number
         */
        'mean': 0,

        /**
         * The array of sampled periods.
         *
         * @memberOf Benchmark#stats
         * @type Array
         */
        'sample': [],

        /**
         * The sample variance.
         *
         * @memberOf Benchmark#stats
         * @type number
         */
        'variance': 0
      },

      /**
       * An object of timing data including cycle, elapsed, period, start, and stop.
       *
       * @memberOf Benchmark
       * @type Object
       */
      'times': {
        /**
         * The time taken to complete the last cycle (secs).
         *
         * @memberOf Benchmark#times
         * @type number
         */
        'cycle': 0,

        /**
         * The time taken to complete the benchmark (secs).
         *
         * @memberOf Benchmark#times
         * @type number
         */
        'elapsed': 0,

        /**
         * The time taken to execute the test once (secs).
         *
         * @memberOf Benchmark#times
         * @type number
         */
        'period': 0,

        /**
         * A timestamp of when the benchmark started (ms).
         *
         * @memberOf Benchmark#times
         * @type number
         */
        'timeStamp': 0
      }
    });

    _.assign(Benchmark.prototype, {
      'abort': abort,
      'clone': clone,
      'compare': compare,
      'emit': emit,
      'listeners': listeners,
      'off': off,
      'on': on,
      'reset': reset,
      'run': run,
      'toString': toStringBench
    });
    /*------------------------------------------------------------------------*/


    _.assign(Deferred.prototype, {
      /**
       * The deferred benchmark instance.
       *
       * @memberOf Benchmark.Deferred
       * @type Object
       */
      'benchmark': null,

      /**
       * The number of deferred cycles performed while benchmarking.
       *
       * @memberOf Benchmark.Deferred
       * @type number
       */
      'cycles': 0,

      /**
       * The time taken to complete the deferred benchmark (secs).
       *
       * @memberOf Benchmark.Deferred
       * @type number
       */
      'elapsed': 0,

      /**
       * A timestamp of when the deferred benchmark started (ms).
       *
       * @memberOf Benchmark.Deferred
       * @type number
       */
      'timeStamp': 0
    });

    _.assign(Deferred.prototype, {
      'resolve': resolve
    });
    /*------------------------------------------------------------------------*/


    _.assign(Event.prototype, {
      /**
       * A flag to indicate if the emitters listener iteration is aborted.
       *
       * @memberOf Benchmark.Event
       * @type boolean
       */
      'aborted': false,

      /**
       * A flag to indicate if the default action is cancelled.
       *
       * @memberOf Benchmark.Event
       * @type boolean
       */
      'cancelled': false,

      /**
       * The object whose listeners are currently being processed.
       *
       * @memberOf Benchmark.Event
       * @type Object
       */
      'currentTarget': undefined,

      /**
       * The return value of the last executed listener.
       *
       * @memberOf Benchmark.Event
       * @type Mixed
       */
      'result': undefined,

      /**
       * The object to which the event was originally emitted.
       *
       * @memberOf Benchmark.Event
       * @type Object
       */
      'target': undefined,

      /**
       * A timestamp of when the event was created (ms).
       *
       * @memberOf Benchmark.Event
       * @type number
       */
      'timeStamp': 0,

      /**
       * The event type.
       *
       * @memberOf Benchmark.Event
       * @type string
       */
      'type': ''
    });
    /*------------------------------------------------------------------------*/

    /**
     * The default options copied by suite instances.
     *
     * @static
     * @memberOf Benchmark.Suite
     * @type Object
     */


    Suite.options = {
      /**
       * The name of the suite.
       *
       * @memberOf Benchmark.Suite.options
       * @type string
       */
      'name': undefined
    };
    /*------------------------------------------------------------------------*/

    _.assign(Suite.prototype, {
      /**
       * The number of benchmarks in the suite.
       *
       * @memberOf Benchmark.Suite
       * @type number
       */
      'length': 0,

      /**
       * A flag to indicate if the suite is aborted.
       *
       * @memberOf Benchmark.Suite
       * @type boolean
       */
      'aborted': false,

      /**
       * A flag to indicate if the suite is running.
       *
       * @memberOf Benchmark.Suite
       * @type boolean
       */
      'running': false
    });

    _.assign(Suite.prototype, {
      'abort': abortSuite,
      'add': add,
      'clone': cloneSuite,
      'emit': emit,
      'filter': filterSuite,
      'join': arrayRef.join,
      'listeners': listeners,
      'off': off,
      'on': on,
      'pop': arrayRef.pop,
      'push': push,
      'reset': resetSuite,
      'run': runSuite,
      'reverse': arrayRef.reverse,
      'shift': shift,
      'slice': slice,
      'sort': arrayRef.sort,
      'splice': arrayRef.splice,
      'unshift': unshift
    });
    /*------------------------------------------------------------------------*/
    // Expose Deferred, Event, and Suite.


    _.assign(Benchmark, {
      'Deferred': Deferred,
      'Event': Event,
      'Suite': Suite
    });
    /*------------------------------------------------------------------------*/
    // Add lodash methods as Suite methods.


    _.each(['each', 'forEach', 'indexOf', 'map', 'reduce'], function (methodName) {
      var func = _[methodName];

      Suite.prototype[methodName] = function () {
        var args = [this];
        push.apply(args, arguments);
        return func.apply(_, args);
      };
    }); // Avoid array-like object bugs with `Array#shift` and `Array#splice`
    // in Firefox < 10 and IE < 9.


    _.each(['pop', 'shift', 'splice'], function (methodName) {
      var func = arrayRef[methodName];

      Suite.prototype[methodName] = function () {
        var value = this,
            result = func.apply(value, arguments);

        if (value.length === 0) {
          delete value[0];
        }

        return result;
      };
    }); // Avoid buggy `Array#unshift` in IE < 8 which doesn't return the new
    // length of the array.


    Suite.prototype.unshift = function () {
      var value = this;
      unshift.apply(value, arguments);
      return value.length;
    };

    return Benchmark;
  }
  /*--------------------------------------------------------------------------*/


  var Benchmark = runInContext();
  window.Benchmark = Benchmark;
  return Benchmark;
}.call(void 0);

/***/ }),

/***/ "./packages/tgui-bench/tests/Button.test.tsx":
/*!***************************************************!*\
  !*** ./packages/tgui-bench/tests/Button.test.tsx ***!
  \***************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ListOfButtonsWithTooltips = exports.ListOfButtonsWithIcons = exports.ListOfButtonsWithLinkEvent = exports.ListOfButtonsWithCallback = exports.ListOfButtons = exports.SingleButtonWithLinkEvent = exports.SingleButtonWithCallback = exports.SingleButton = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! tgui/components */ "./packages/tgui/components/index.js");

var _renderer = __webpack_require__(/*! tgui/renderer */ "./packages/tgui/renderer.ts");

var render = (0, _renderer.createRenderer)();

var handleClick = function handleClick() {
  return undefined;
};

var SingleButton = function SingleButton() {
  var node = (0, _inferno.createComponentVNode)(2, _components.Button, {
    children: "Hello world!"
  });
  render(node);
};

exports.SingleButton = SingleButton;

var SingleButtonWithCallback = function SingleButtonWithCallback() {
  var node = (0, _inferno.createComponentVNode)(2, _components.Button, {
    "onClick": function () {
      function onClick() {
        return undefined;
      }

      return onClick;
    }(),
    children: "Hello world!"
  });
  render(node);
};

exports.SingleButtonWithCallback = SingleButtonWithCallback;

var SingleButtonWithLinkEvent = function SingleButtonWithLinkEvent() {
  var node = (0, _inferno.createComponentVNode)(2, _components.Button, {
    "onClick": (0, _inferno.linkEvent)(null, handleClick),
    children: "Hello world!"
  });
  render(node);
};

exports.SingleButtonWithLinkEvent = SingleButtonWithLinkEvent;

var ListOfButtons = function ListOfButtons() {
  var nodes = [];

  for (var i = 0; i < 100; i++) {
    var node = (0, _inferno.createComponentVNode)(2, _components.Button, {
      children: ["Hello world! ", i]
    }, i);
    nodes.push(node);
  }

  render((0, _inferno.createVNode)(1, "div", null, nodes, 0));
};

exports.ListOfButtons = ListOfButtons;

var ListOfButtonsWithCallback = function ListOfButtonsWithCallback() {
  var nodes = [];

  for (var i = 0; i < 100; i++) {
    var node = (0, _inferno.createComponentVNode)(2, _components.Button, {
      "onClick": function () {
        function onClick() {
          return undefined;
        }

        return onClick;
      }(),
      children: ["Hello world! ", i]
    }, i);
    nodes.push(node);
  }

  render((0, _inferno.createVNode)(1, "div", null, nodes, 0));
};

exports.ListOfButtonsWithCallback = ListOfButtonsWithCallback;

var ListOfButtonsWithLinkEvent = function ListOfButtonsWithLinkEvent() {
  var nodes = [];

  for (var i = 0; i < 100; i++) {
    var node = (0, _inferno.createComponentVNode)(2, _components.Button, {
      "onClick": (0, _inferno.linkEvent)(null, handleClick),
      children: ["Hello world! ", i]
    }, i);
    nodes.push(node);
  }

  render((0, _inferno.createVNode)(1, "div", null, nodes, 0));
};

exports.ListOfButtonsWithLinkEvent = ListOfButtonsWithLinkEvent;

var ListOfButtonsWithIcons = function ListOfButtonsWithIcons() {
  var nodes = [];

  for (var i = 0; i < 100; i++) {
    var node = (0, _inferno.createComponentVNode)(2, _components.Button, {
      "icon": 'arrow-left',
      children: ["Hello world! ", i]
    }, i);
    nodes.push(node);
  }

  render((0, _inferno.createVNode)(1, "div", null, nodes, 0));
};

exports.ListOfButtonsWithIcons = ListOfButtonsWithIcons;

var ListOfButtonsWithTooltips = function ListOfButtonsWithTooltips() {
  var nodes = [];

  for (var i = 0; i < 100; i++) {
    var node = (0, _inferno.createComponentVNode)(2, _components.Button, {
      "tooltip": 'Hello world!',
      children: ["Hello world! ", i]
    }, i);
    nodes.push(node);
  }

  render((0, _inferno.createVNode)(1, "div", null, nodes, 0));
};

exports.ListOfButtonsWithTooltips = ListOfButtonsWithTooltips;

/***/ }),

/***/ "./packages/tgui-bench/tests/Flex.test.tsx":
/*!*************************************************!*\
  !*** ./packages/tgui-bench/tests/Flex.test.tsx ***!
  \*************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Default = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! tgui/components */ "./packages/tgui/components/index.js");

var _renderer = __webpack_require__(/*! tgui/renderer */ "./packages/tgui/renderer.ts");

var render = (0, _renderer.createRenderer)();

var Default = function Default() {
  var node = (0, _inferno.createComponentVNode)(2, _components.Flex, {
    "align": "baseline",
    children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "mr": 1,
      children: ["Text ", Math.random()]
    }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "grow": 1,
      "basis": 0,
      children: ["Text ", Math.random()]
    })]
  });
  render(node);
};

exports.Default = Default;

/***/ }),

/***/ "./packages/tgui-bench/tests/Stack.test.tsx":
/*!**************************************************!*\
  !*** ./packages/tgui-bench/tests/Stack.test.tsx ***!
  \**************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Default = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! tgui/components */ "./packages/tgui/components/index.js");

var _renderer = __webpack_require__(/*! tgui/renderer */ "./packages/tgui/renderer.ts");

var render = (0, _renderer.createRenderer)();

var Default = function Default() {
  var node = (0, _inferno.createComponentVNode)(2, _components.Stack, {
    "align": "baseline",
    children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      children: ["Text ", Math.random()]
    }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      "grow": 1,
      "basis": 0,
      children: ["Text ", Math.random()]
    })]
  });
  render(node);
};

exports.Default = Default;

/***/ }),

/***/ "./packages/tgui-dev-server/link/client.js":
/*!*************************************************!*\
  !*** ./packages/tgui-dev-server/link/client.js ***!
  \*************************************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.setupHotReloading = exports.sendLogEntry = exports.sendMessage = exports.subscribe = void 0;

function _createForOfIteratorHelperLoose(o, allowArrayLike) { var it = typeof Symbol !== "undefined" && o[Symbol.iterator] || o["@@iterator"]; if (it) return (it = it.call(o)).next.bind(it); if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; return function () { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var socket;
var queue = [];
var subscribers = [];

var ensureConnection = function ensureConnection() {
  if (true) {
    if (!window.WebSocket) {
      return;
    }

    if (!socket || socket.readyState === WebSocket.CLOSED) {
      var DEV_SERVER_IP =  false || '127.0.0.1';
      socket = new WebSocket("ws://" + DEV_SERVER_IP + ":3000");

      socket.onopen = function () {
        // Empty the message queue
        while (queue.length !== 0) {
          var msg = queue.shift();
          socket.send(msg);
        }
      };

      socket.onmessage = function (event) {
        var msg = JSON.parse(event.data);

        for (var _iterator = _createForOfIteratorHelperLoose(subscribers), _step; !(_step = _iterator()).done;) {
          var subscriber = _step.value;
          subscriber(msg);
        }
      };
    }
  }
};

if (true) {
  window.onunload = function () {
    return socket && socket.close();
  };
}

var subscribe = function subscribe(fn) {
  return subscribers.push(fn);
};
/**
 * A json serializer which handles circular references and other junk.
 */


exports.subscribe = subscribe;

var serializeObject = function serializeObject(obj) {
  var refs = [];

  var primitiveReviver = function primitiveReviver(value) {
    if (typeof value === 'number' && !Number.isFinite(value)) {
      return {
        __number__: String(value)
      };
    }

    if (typeof value === 'undefined') {
      return {
        __undefined__: true
      };
    }

    return value;
  };

  var objectReviver = function objectReviver(key, value) {
    if (typeof value === 'object') {
      if (value === null) {
        return value;
      } // Circular reference


      if (refs.includes(value)) {
        return '[circular ref]';
      }

      refs.push(value); // Error object

      var isError = value instanceof Error || value.code && value.message && value.message.includes('Error');

      if (isError) {
        return {
          __error__: true,
          string: String(value),
          stack: value.stack
        };
      } // Array


      if (Array.isArray(value)) {
        return value.map(primitiveReviver);
      }

      return value;
    }

    return primitiveReviver(value);
  };

  var json = JSON.stringify(obj, objectReviver);
  refs = null;
  return json;
};

var sendMessage = function sendMessage(msg) {
  if (true) {
    var json = serializeObject(msg); // Send message using WebSocket

    if (window.WebSocket) {
      ensureConnection();

      if (socket.readyState === WebSocket.OPEN) {
        socket.send(json);
      } else {
        // Keep only 100 latest messages in the queue
        if (queue.length > 100) {
          queue.shift();
        }

        queue.push(json);
      }
    } // Send message using plain HTTP request.
    else {
        var DEV_SERVER_IP =  false || '127.0.0.1';
        var req = new XMLHttpRequest();
        req.open('POST', "http://" + DEV_SERVER_IP + ":3001", true);
        req.timeout = 250;
        req.send(json);
      }
  }
};

exports.sendMessage = sendMessage;

var sendLogEntry = function sendLogEntry(level, ns) {
  if (true) {
    try {
      for (var _len = arguments.length, args = new Array(_len > 2 ? _len - 2 : 0), _key = 2; _key < _len; _key++) {
        args[_key - 2] = arguments[_key];
      }

      sendMessage({
        type: 'log',
        payload: {
          level: level,
          ns: ns || 'client',
          args: args
        }
      });
    } catch (err) {}
  }
};

exports.sendLogEntry = sendLogEntry;

var setupHotReloading = function setupHotReloading() {
  if (false) {}
};

exports.setupHotReloading = setupHotReloading;

/***/ }),

/***/ "./packages/tgui-polyfill/css-om.js":
/*!******************************************!*\
  !*** ./packages/tgui-polyfill/css-om.js ***!
  \******************************************/
/***/ (function() {

"use strict";


/**
 * CSS Object Model patches
 *
 * Adapted from: https://github.com/shawnbot/aight
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/* eslint-disable */
(function (Proto) {
  'use strict';

  if (typeof Proto.setAttribute !== 'undefined') {
    var toAttr = function toAttr(prop) {
      return prop.replace(/-[a-z]/g, function (bit) {
        return bit[1].toUpperCase();
      });
    };

    Proto.setProperty = function (prop, value) {
      var attr = toAttr(prop);

      if (!value) {
        return this.removeAttribute(attr);
      }

      var str = String(value);
      return this.setAttribute(attr, str);
    };

    Proto.getPropertyValue = function (prop) {
      var attr = toAttr(prop);
      return this.getAttribute(attr) || null;
    };

    Proto.removeProperty = function (prop) {
      var attr = toAttr(prop);
      var value = this.getAttribute(attr);
      this.removeAttribute(attr);
      return value;
    };
  }
})(CSSStyleDeclaration.prototype);

/***/ }),

/***/ "./packages/tgui-polyfill/dom4.js":
/*!****************************************!*\
  !*** ./packages/tgui-polyfill/dom4.js ***!
  \****************************************/
/***/ (function() {

"use strict";


/**
 * @file
 * @copyright 2013 Andrea Giammarchi, WebReflection
 * @license MIT
 */

/* eslint-disable */
(function (window) {
  'use strict';
  /* jshint loopfunc: true, noempty: false*/
  // http://www.w3.org/TR/dom/#element

  function createDocumentFragment() {
    return document.createDocumentFragment();
  }

  function createElement(nodeName) {
    return document.createElement(nodeName);
  }

  function enoughArguments(length, name) {
    if (!length) throw new Error('Failed to construct ' + name + ': 1 argument required, but only 0 present.');
  }

  function mutationMacro(nodes) {
    if (nodes.length === 1) {
      return textNodeIfPrimitive(nodes[0]);
    }

    for (var fragment = createDocumentFragment(), list = slice.call(nodes), i = 0; i < nodes.length; i++) {
      fragment.appendChild(textNodeIfPrimitive(list[i]));
    }

    return fragment;
  }

  function textNodeIfPrimitive(node) {
    return typeof node === 'object' ? node : document.createTextNode(node);
  }

  for (var head, property, TemporaryPrototype, TemporaryTokenList, wrapVerifyToken, document = window.document, hOP = Object.prototype.hasOwnProperty, defineProperty = Object.defineProperty || function (object, property, descriptor) {
    if (hOP.call(descriptor, 'value')) {
      object[property] = descriptor.value;
    } else {
      if (hOP.call(descriptor, 'get')) object.__defineGetter__(property, descriptor.get);
      if (hOP.call(descriptor, 'set')) object.__defineSetter__(property, descriptor.set);
    }

    return object;
  }, indexOf = [].indexOf || function () {
    function indexOf(value) {
      var length = this.length;

      while (length--) {
        if (this[length] === value) {
          break;
        }
      }

      return length;
    }

    return indexOf;
  }(), // http://www.w3.org/TR/domcore/#domtokenlist
  verifyToken = function verifyToken(token) {
    if (!token) {
      throw 'SyntaxError';
    } else if (spaces.test(token)) {
      throw 'InvalidCharacterError';
    }

    return token;
  }, DOMTokenList = function DOMTokenList(node) {
    var noClassName = typeof node.className === 'undefined',
        className = noClassName ? node.getAttribute('class') || '' : node.className,
        isSVG = noClassName || typeof className === 'object',
        value = (isSVG ? noClassName ? className : className.baseVal : className).replace(trim, '');

    if (value.length) {
      properties.push.apply(this, value.split(spaces));
    }

    this._isSVG = isSVG;
    this._ = node;
  }, classListDescriptor = {
    get: function () {
      function get() {
        return new DOMTokenList(this);
      }

      return get;
    }(),
    set: function () {
      function set() {}

      return set;
    }()
  }, trim = /^\s+|\s+$/g, spaces = /\s+/, SPACE = '\x20', CLASS_LIST = 'classList', toggle = function () {
    function toggle(token, force) {
      if (this.contains(token)) {
        if (!force) {
          // force is not true (either false or omitted)
          this.remove(token);
        }
      } else if (force === undefined || force) {
        force = true;
        this.add(token);
      }

      return !!force;
    }

    return toggle;
  }(), DocumentFragmentPrototype = window.DocumentFragment && DocumentFragment.prototype, Node = window.Node, NodePrototype = (Node || Element).prototype, CharacterData = window.CharacterData || Node, CharacterDataPrototype = CharacterData && CharacterData.prototype, DocumentType = window.DocumentType, DocumentTypePrototype = DocumentType && DocumentType.prototype, ElementPrototype = (window.Element || Node || window.HTMLElement).prototype, HTMLSelectElement = window.HTMLSelectElement || createElement('select').constructor, selectRemove = HTMLSelectElement.prototype.remove, SVGElement = window.SVGElement, properties = ['matches', ElementPrototype.matchesSelector || ElementPrototype.webkitMatchesSelector || ElementPrototype.khtmlMatchesSelector || ElementPrototype.mozMatchesSelector || ElementPrototype.msMatchesSelector || ElementPrototype.oMatchesSelector || function () {
    function matches(selector) {
      var parentNode = this.parentNode;
      return !!parentNode && -1 < indexOf.call(parentNode.querySelectorAll(selector), this);
    }

    return matches;
  }(), 'closest', function () {
    function closest(selector) {
      var parentNode = this,
          matches;

      while ( // document has no .matches
      (matches = parentNode && parentNode.matches) && !parentNode.matches(selector)) {
        parentNode = parentNode.parentNode;
      }

      return matches ? parentNode : null;
    }

    return closest;
  }(), 'prepend', function () {
    function prepend() {
      var firstChild = this.firstChild,
          node = mutationMacro(arguments);

      if (firstChild) {
        this.insertBefore(node, firstChild);
      } else {
        this.appendChild(node);
      }
    }

    return prepend;
  }(), 'append', function () {
    function append() {
      this.appendChild(mutationMacro(arguments));
    }

    return append;
  }(), 'before', function () {
    function before() {
      var parentNode = this.parentNode;

      if (parentNode) {
        parentNode.insertBefore(mutationMacro(arguments), this);
      }
    }

    return before;
  }(), 'after', function () {
    function after() {
      var parentNode = this.parentNode,
          nextSibling = this.nextSibling,
          node = mutationMacro(arguments);

      if (parentNode) {
        if (nextSibling) {
          parentNode.insertBefore(node, nextSibling);
        } else {
          parentNode.appendChild(node);
        }
      }
    }

    return after;
  }(), // https://dom.spec.whatwg.org/#dom-element-toggleattribute
  'toggleAttribute', function () {
    function toggleAttribute(name, force) {
      var had = this.hasAttribute(name);

      if (1 < arguments.length) {
        if (had && !force) this.removeAttribute(name);else if (force && !had) this.setAttribute(name, "");
      } else if (had) this.removeAttribute(name);else this.setAttribute(name, "");

      return this.hasAttribute(name);
    }

    return toggleAttribute;
  }(), // WARNING - DEPRECATED - use .replaceWith() instead
  'replace', function () {
    function replace() {
      this.replaceWith.apply(this, arguments);
    }

    return replace;
  }(), 'replaceWith', function () {
    function replaceWith() {
      var parentNode = this.parentNode;

      if (parentNode) {
        parentNode.replaceChild(mutationMacro(arguments), this);
      }
    }

    return replaceWith;
  }(), 'remove', function () {
    function remove() {
      var parentNode = this.parentNode;

      if (parentNode) {
        parentNode.removeChild(this);
      }
    }

    return remove;
  }()], slice = properties.slice, i = properties.length; i; i -= 2) {
    property = properties[i - 2];

    if (!(property in ElementPrototype)) {
      ElementPrototype[property] = properties[i - 1];
    } // avoid unnecessary re-patch when the script is included
    // gazillion times without any reason whatsoever
    // https://github.com/WebReflection/dom4/pull/48


    if (property === 'remove' && !selectRemove._dom4) {
      // see https://github.com/WebReflection/dom4/issues/19
      (HTMLSelectElement.prototype[property] = function () {
        return 0 < arguments.length ? selectRemove.apply(this, arguments) : ElementPrototype.remove.call(this);
      })._dom4 = true;
    } // see https://github.com/WebReflection/dom4/issues/18


    if (/^(?:before|after|replace|replaceWith|remove)$/.test(property)) {
      if (CharacterData && !(property in CharacterDataPrototype)) {
        CharacterDataPrototype[property] = properties[i - 1];
      }

      if (DocumentType && !(property in DocumentTypePrototype)) {
        DocumentTypePrototype[property] = properties[i - 1];
      }
    } // see https://github.com/WebReflection/dom4/pull/26


    if (/^(?:append|prepend)$/.test(property)) {
      if (DocumentFragmentPrototype) {
        if (!(property in DocumentFragmentPrototype)) {
          DocumentFragmentPrototype[property] = properties[i - 1];
        }
      } else {
        try {
          createDocumentFragment().constructor.prototype[property] = properties[i - 1];
        } catch (o_O) {}
      }
    }
  } // most likely an IE9 only issue
  // see https://github.com/WebReflection/dom4/issues/6


  if (!createElement('a').matches('a')) {
    ElementPrototype[property] = function (matches) {
      return function (selector) {
        return matches.call(this.parentNode ? this : createDocumentFragment().appendChild(this), selector);
      };
    }(ElementPrototype[property]);
  } // used to fix both old webkit and SVG


  DOMTokenList.prototype = {
    length: 0,
    add: function () {
      function add() {
        for (var j = 0, token; j < arguments.length; j++) {
          token = arguments[j];

          if (!this.contains(token)) {
            properties.push.call(this, property);
          }
        }

        if (this._isSVG) {
          this._.setAttribute('class', '' + this);
        } else {
          this._.className = '' + this;
        }
      }

      return add;
    }(),
    contains: function (indexOf) {
      return function () {
        function contains(token) {
          i = indexOf.call(this, property = verifyToken(token));
          return -1 < i;
        }

        return contains;
      }();
    }([].indexOf || function (token) {
      i = this.length;

      while (i-- && this[i] !== token) {}

      return i;
    }),
    item: function () {
      function item(i) {
        return this[i] || null;
      }

      return item;
    }(),
    remove: function () {
      function remove() {
        for (var j = 0, token; j < arguments.length; j++) {
          token = arguments[j];

          if (this.contains(token)) {
            properties.splice.call(this, i, 1);
          }
        }

        if (this._isSVG) {
          this._.setAttribute('class', '' + this);
        } else {
          this._.className = '' + this;
        }
      }

      return remove;
    }(),
    toggle: toggle,
    toString: function () {
      function toString() {
        return properties.join.call(this, SPACE);
      }

      return toString;
    }()
  };

  if (SVGElement && !(CLASS_LIST in SVGElement.prototype)) {
    defineProperty(SVGElement.prototype, CLASS_LIST, classListDescriptor);
  } // http://www.w3.org/TR/dom/#domtokenlist
  // iOS 5.1 has completely screwed this property
  // classList in ElementPrototype is false
  // but it's actually there as getter


  if (!(CLASS_LIST in document.documentElement)) {
    defineProperty(ElementPrototype, CLASS_LIST, classListDescriptor);
  } else {
    // iOS 5.1 and Nokia ASHA do not support multiple add or remove
    // trying to detect and fix that in here
    TemporaryTokenList = createElement('div')[CLASS_LIST];
    TemporaryTokenList.add('a', 'b', 'a');

    if ('a\x20b' != TemporaryTokenList) {
      // no other way to reach original methods in iOS 5.1
      TemporaryPrototype = TemporaryTokenList.constructor.prototype;

      if (!('add' in TemporaryPrototype)) {
        // ASHA double fails in here
        TemporaryPrototype = window.TemporaryTokenList.prototype;
      }

      wrapVerifyToken = function wrapVerifyToken(original) {
        return function () {
          var i = 0;

          while (i < arguments.length) {
            original.call(this, arguments[i++]);
          }
        };
      };

      TemporaryPrototype.add = wrapVerifyToken(TemporaryPrototype.add);
      TemporaryPrototype.remove = wrapVerifyToken(TemporaryPrototype.remove); // toggle is broken too ^_^ ... let's fix it

      TemporaryPrototype.toggle = toggle;
    }
  }

  if (!('contains' in NodePrototype)) {
    defineProperty(NodePrototype, 'contains', {
      value: function () {
        function value(el) {
          while (el && el !== this) {
            el = el.parentNode;
          }

          return this === el;
        }

        return value;
      }()
    });
  }

  if (!('head' in document)) {
    defineProperty(document, 'head', {
      get: function () {
        function get() {
          return head || (head = document.getElementsByTagName('head')[0]);
        }

        return get;
      }()
    });
  } // requestAnimationFrame partial polyfill


  (function () {
    for (var raf, rAF = window.requestAnimationFrame, cAF = window.cancelAnimationFrame, prefixes = ['o', 'ms', 'moz', 'webkit'], i = prefixes.length; !cAF && i--;) {
      rAF = rAF || window[prefixes[i] + 'RequestAnimationFrame'];
      cAF = window[prefixes[i] + 'CancelAnimationFrame'] || window[prefixes[i] + 'CancelRequestAnimationFrame'];
    }

    if (!cAF) {
      // some FF apparently implemented rAF but no cAF
      if (rAF) {
        raf = rAF;

        rAF = function rAF(callback) {
          var goOn = true;
          raf(function () {
            if (goOn) callback.apply(this, arguments);
          });
          return function () {
            goOn = false;
          };
        };

        cAF = function cAF(id) {
          id();
        };
      } else {
        rAF = function rAF(callback) {
          return setTimeout(callback, 15, 15);
        };

        cAF = function cAF(id) {
          clearTimeout(id);
        };
      }
    }

    window.requestAnimationFrame = rAF;
    window.cancelAnimationFrame = cAF;
  })(); // http://www.w3.org/TR/dom/#customevent


  try {
    new window.CustomEvent('?');
  } catch (o_O) {
    window.CustomEvent = function (eventName, defaultInitDict) {
      // the infamous substitute
      function CustomEvent(type, eventInitDict) {
        /*jshint eqnull:true */
        var event = document.createEvent(eventName);

        if (typeof type != 'string') {
          throw new Error('An event name must be provided');
        }

        if (eventName == 'Event') {
          event.initCustomEvent = initCustomEvent;
        }

        if (eventInitDict == null) {
          eventInitDict = defaultInitDict;
        }

        event.initCustomEvent(type, eventInitDict.bubbles, eventInitDict.cancelable, eventInitDict.detail);
        return event;
      } // attached at runtime


      function initCustomEvent(type, bubbles, cancelable, detail) {
        /*jshint validthis:true*/
        this.initEvent(type, bubbles, cancelable);
        this.detail = detail;
      } // that's it


      return CustomEvent;
    }( // is this IE9 or IE10 ?
    // where CustomEvent is there
    // but not usable as construtor ?
    window.CustomEvent ? // use the CustomEvent interface in such case
    'CustomEvent' : 'Event', // otherwise the common compatible one
    {
      bubbles: false,
      cancelable: false,
      detail: null
    });
  } // window.Event as constructor


  try {
    new Event('_');
  } catch (o_O) {
    /* jshint -W022 */
    o_O = function ($Event) {
      function Event(type, init) {
        enoughArguments(arguments.length, 'Event');
        var out = document.createEvent('Event');
        if (!init) init = {};
        out.initEvent(type, !!init.bubbles, !!init.cancelable);
        return out;
      }

      Event.prototype = $Event.prototype;
      return Event;
    }(window.Event || function () {
      function Event() {}

      return Event;
    }());

    defineProperty(window, 'Event', {
      value: o_O
    }); // Android 4 gotcha

    if (Event !== o_O) Event = o_O;
  } // window.KeyboardEvent as constructor


  try {
    new KeyboardEvent('_', {});
  } catch (o_O) {
    /* jshint -W022 */
    o_O = function ($KeyboardEvent) {
      // code inspired by https://gist.github.com/termi/4654819
      var initType = 0,
          defaults = {
        "char": '',
        key: '',
        location: 0,
        ctrlKey: false,
        shiftKey: false,
        altKey: false,
        metaKey: false,
        altGraphKey: false,
        repeat: false,
        locale: navigator.language,
        detail: 0,
        bubbles: false,
        cancelable: false,
        keyCode: 0,
        charCode: 0,
        which: 0
      },
          eventType;

      try {
        var e = document.createEvent('KeyboardEvent');
        e.initKeyboardEvent('keyup', false, false, window, '+', 3, true, false, true, false, false);
        initType = (e.keyIdentifier || e.key) == '+' && (e.keyLocation || e.location) == 3 && (e.ctrlKey ? e.altKey ? 1 : 3 : e.shiftKey ? 2 : 4) || 9;
      } catch (o_O) {}

      eventType = 0 < initType ? 'KeyboardEvent' : 'Event';

      function getModifier(init) {
        for (var out = [], keys = ['ctrlKey', 'Control', 'shiftKey', 'Shift', 'altKey', 'Alt', 'metaKey', 'Meta', 'altGraphKey', 'AltGraph'], i = 0; i < keys.length; i += 2) {
          if (init[keys[i]]) out.push(keys[i + 1]);
        }

        return out.join(' ');
      }

      function withDefaults(target, source) {
        for (var key in source) {
          if (source.hasOwnProperty(key) && !source.hasOwnProperty.call(target, key)) target[key] = source[key];
        }

        return target;
      }

      function withInitValues(key, out, init) {
        try {
          out[key] = init[key];
        } catch (o_O) {}
      }

      function KeyboardEvent(type, init) {
        enoughArguments(arguments.length, 'KeyboardEvent');
        init = withDefaults(init || {}, defaults);
        var out = document.createEvent(eventType),
            ctrlKey = init.ctrlKey,
            shiftKey = init.shiftKey,
            altKey = init.altKey,
            metaKey = init.metaKey,
            altGraphKey = init.altGraphKey,
            modifiers = initType > 3 ? getModifier(init) : null,
            key = String(init.key),
            chr = String(init["char"]),
            location = init.location,
            keyCode = init.keyCode || (init.keyCode = key) && key.charCodeAt(0) || 0,
            charCode = init.charCode || (init.charCode = chr) && chr.charCodeAt(0) || 0,
            bubbles = init.bubbles,
            cancelable = init.cancelable,
            repeat = init.repeat,
            locale = init.locale,
            view = init.view || window,
            args;
        if (!init.which) init.which = init.keyCode;

        if ('initKeyEvent' in out) {
          out.initKeyEvent(type, bubbles, cancelable, view, ctrlKey, altKey, shiftKey, metaKey, keyCode, charCode);
        } else if (0 < initType && 'initKeyboardEvent' in out) {
          args = [type, bubbles, cancelable, view];

          switch (initType) {
            case 1:
              args.push(key, location, ctrlKey, shiftKey, altKey, metaKey, altGraphKey);
              break;

            case 2:
              args.push(ctrlKey, altKey, shiftKey, metaKey, keyCode, charCode);
              break;

            case 3:
              args.push(key, location, ctrlKey, altKey, shiftKey, metaKey, altGraphKey);
              break;

            case 4:
              args.push(key, location, modifiers, repeat, locale);
              break;

            default:
              args.push(char, key, location, modifiers, repeat, locale);
          }

          out.initKeyboardEvent.apply(out, args);
        } else {
          out.initEvent(type, bubbles, cancelable);
        }

        for (key in out) {
          if (defaults.hasOwnProperty(key) && out[key] !== init[key]) {
            withInitValues(key, out, init);
          }
        }

        return out;
      }

      KeyboardEvent.prototype = $KeyboardEvent.prototype;
      return KeyboardEvent;
    }(window.KeyboardEvent || function () {
      function KeyboardEvent() {}

      return KeyboardEvent;
    }());

    defineProperty(window, 'KeyboardEvent', {
      value: o_O
    }); // Android 4 gotcha

    if (KeyboardEvent !== o_O) KeyboardEvent = o_O;
  } // window.MouseEvent as constructor


  try {
    new MouseEvent('_', {});
  } catch (o_O) {
    /* jshint -W022 */
    o_O = function ($MouseEvent) {
      function MouseEvent(type, init) {
        enoughArguments(arguments.length, 'MouseEvent');
        var out = document.createEvent('MouseEvent');
        if (!init) init = {};
        out.initMouseEvent(type, !!init.bubbles, !!init.cancelable, init.view || window, init.detail || 1, init.screenX || 0, init.screenY || 0, init.clientX || 0, init.clientY || 0, !!init.ctrlKey, !!init.altKey, !!init.shiftKey, !!init.metaKey, init.button || 0, init.relatedTarget || null);
        return out;
      }

      MouseEvent.prototype = $MouseEvent.prototype;
      return MouseEvent;
    }(window.MouseEvent || function () {
      function MouseEvent() {}

      return MouseEvent;
    }());

    defineProperty(window, 'MouseEvent', {
      value: o_O
    }); // Android 4 gotcha

    if (MouseEvent !== o_O) MouseEvent = o_O;
  }

  if (!document.querySelectorAll('*').forEach) {
    (function () {
      function patch(what) {
        var querySelectorAll = what.querySelectorAll;

        what.querySelectorAll = function () {
          function qSA(css) {
            var result = querySelectorAll.call(this, css);
            result.forEach = Array.prototype.forEach;
            return result;
          }

          return qSA;
        }();
      }

      patch(document);
      patch(Element.prototype);
    })();
  }

  try {
    // https://drafts.csswg.org/selectors-4/#the-scope-pseudo
    document.querySelector(':scope *');
  } catch (o_O) {
    (function () {
      var dataScope = 'data-scope-' + (Math.random() * 1e9 >>> 0);
      var proto = Element.prototype;
      var querySelector = proto.querySelector;
      var querySelectorAll = proto.querySelectorAll;

      proto.querySelector = function () {
        function qS(css) {
          return find(this, querySelector, css);
        }

        return qS;
      }();

      proto.querySelectorAll = function () {
        function qSA(css) {
          return find(this, querySelectorAll, css);
        }

        return qSA;
      }();

      function find(node, method, css) {
        node.setAttribute(dataScope, null);
        var result = method.call(node, String(css).replace(/(^|,\s*)(:scope([ >]|$))/g, function ($0, $1, $2, $3) {
          return $1 + '[' + dataScope + ']' + ($3 || ' ');
        }));
        node.removeAttribute(dataScope);
        return result;
      }
    })();
  }
})(window);

(function (global) {
  'use strict'; // a WeakMap fallback for DOM nodes only used as key

  var DOMMap = global.WeakMap || function () {
    var counter = 0,
        dispatched = false,
        drop = false,
        value;

    function dispatch(key, ce, shouldDrop) {
      drop = shouldDrop;
      dispatched = false;
      value = undefined;
      key.dispatchEvent(ce);
    }

    function Handler(value) {
      this.value = value;
    }

    Handler.prototype.handleEvent = function () {
      function handleEvent(e) {
        dispatched = true;

        if (drop) {
          e.currentTarget.removeEventListener(e.type, this, false);
        } else {
          value = this.value;
        }
      }

      return handleEvent;
    }();

    function DOMMap() {
      counter++; // make id clashing highly improbable

      this.__ce__ = new Event('@DOMMap:' + counter + Math.random());
    }

    DOMMap.prototype = {
      'constructor': DOMMap,
      'delete': function () {
        function del(key) {
          return dispatch(key, this.__ce__, true), dispatched;
        }

        return del;
      }(),
      'get': function () {
        function get(key) {
          dispatch(key, this.__ce__, false);
          var v = value;
          value = undefined;
          return v;
        }

        return get;
      }(),
      'has': function () {
        function has(key) {
          return dispatch(key, this.__ce__, false), dispatched;
        }

        return has;
      }(),
      'set': function () {
        function set(key, value) {
          dispatch(key, this.__ce__, true);
          key.addEventListener(this.__ce__.type, new Handler(value), false);
          return this;
        }

        return set;
      }()
    };
    return DOMMap;
  }();

  function Dict() {}

  Dict.prototype = (Object.create || Object)(null); // https://dom.spec.whatwg.org/#interface-eventtarget

  function createEventListener(type, callback, options) {
    function eventListener(e) {
      if (eventListener.once) {
        e.currentTarget.removeEventListener(e.type, callback, eventListener);
        eventListener.removed = true;
      }

      if (eventListener.passive) {
        e.preventDefault = createEventListener.preventDefault;
      }

      if (typeof eventListener.callback === 'function') {
        /* jshint validthis: true */
        eventListener.callback.call(this, e);
      } else if (eventListener.callback) {
        eventListener.callback.handleEvent(e);
      }

      if (eventListener.passive) {
        delete e.preventDefault;
      }
    }

    eventListener.type = type;
    eventListener.callback = callback;
    eventListener.capture = !!options.capture;
    eventListener.passive = !!options.passive;
    eventListener.once = !!options.once; // currently pointless but specs say to use it, so ...

    eventListener.removed = false;
    return eventListener;
  }

  createEventListener.preventDefault = function () {
    function preventDefault() {}

    return preventDefault;
  }();

  var Event = global.CustomEvent,
      dE = global.dispatchEvent,
      aEL = global.addEventListener,
      rEL = global.removeEventListener,
      counter = 0,
      increment = function increment() {
    counter++;
  },
      indexOf = [].indexOf || function () {
    function indexOf(value) {
      var length = this.length;

      while (length--) {
        if (this[length] === value) {
          break;
        }
      }

      return length;
    }

    return indexOf;
  }(),
      getListenerKey = function getListenerKey(options) {
    return ''.concat(options.capture ? '1' : '0', options.passive ? '1' : '0', options.once ? '1' : '0');
  },
      augment;

  try {
    aEL('_', increment, {
      once: true
    });
    dE(new Event('_'));
    dE(new Event('_'));
    rEL('_', increment, {
      once: true
    });
  } catch (o_O) {}

  if (counter !== 1) {
    (function () {
      var dm = new DOMMap();

      function createAEL(aEL) {
        return function () {
          function addEventListener(type, handler, options) {
            if (options && typeof options !== 'boolean') {
              var info = dm.get(this),
                  key = getListenerKey(options),
                  i,
                  tmp,
                  wrap;
              if (!info) dm.set(this, info = new Dict());
              if (!(type in info)) info[type] = {
                handler: [],
                wrap: []
              };
              tmp = info[type];
              i = indexOf.call(tmp.handler, handler);

              if (i < 0) {
                i = tmp.handler.push(handler) - 1;
                tmp.wrap[i] = wrap = new Dict();
              } else {
                wrap = tmp.wrap[i];
              }

              if (!(key in wrap)) {
                wrap[key] = createEventListener(type, handler, options);
                aEL.call(this, type, wrap[key], wrap[key].capture);
              }
            } else {
              aEL.call(this, type, handler, options);
            }
          }

          return addEventListener;
        }();
      }

      function createREL(rEL) {
        return function () {
          function removeEventListener(type, handler, options) {
            if (options && typeof options !== 'boolean') {
              var info = dm.get(this),
                  key,
                  i,
                  tmp,
                  wrap;

              if (info && type in info) {
                tmp = info[type];
                i = indexOf.call(tmp.handler, handler);

                if (-1 < i) {
                  key = getListenerKey(options);
                  wrap = tmp.wrap[i];

                  if (key in wrap) {
                    rEL.call(this, type, wrap[key], wrap[key].capture);
                    delete wrap[key]; // return if there are other wraps

                    for (key in wrap) {
                      return;
                    } // otherwise remove all the things


                    tmp.handler.splice(i, 1);
                    tmp.wrap.splice(i, 1); // if there are no other handlers

                    if (tmp.handler.length === 0) // drop the info[type] entirely
                      delete info[type];
                  }
                }
              }
            } else {
              rEL.call(this, type, handler, options);
            }
          }

          return removeEventListener;
        }();
      }

      augment = function augment(Constructor) {
        if (!Constructor) return;
        var proto = Constructor.prototype;
        proto.addEventListener = createAEL(proto.addEventListener);
        proto.removeEventListener = createREL(proto.removeEventListener);
      };

      if (global.EventTarget) {
        augment(EventTarget);
      } else {
        augment(global.Text);
        augment(global.Element || global.HTMLElement);
        augment(global.HTMLDocument);
        augment(global.Window || {
          prototype: global
        });
        augment(global.XMLHttpRequest);
      }
    })();
  }
})(window);

/***/ }),

/***/ "./packages/tgui-polyfill/html5shiv.js":
/*!*********************************************!*\
  !*** ./packages/tgui-polyfill/html5shiv.js ***!
  \*********************************************/
/***/ (function(module) {

"use strict";


/**
 * @file
 * @copyright 2014 Alexander Farkas
 * @license MIT
 */

/* eslint-disable */
(function (window, document) {
  /*jshint evil:true */

  /** version */
  var version = '3.7.3';
  /** Preset options */

  var options = window.html5 || {};
  /** Used to skip problem elements */

  var reSkip = /^<|^(?:button|map|select|textarea|object|iframe|option|optgroup)$/i;
  /** Not all elements can be cloned in IE **/

  var saveClones = /^(?:a|b|code|div|fieldset|h1|h2|h3|h4|h5|h6|i|label|li|ol|p|q|span|strong|style|table|tbody|td|th|tr|ul)$/i;
  /** Detect whether the browser supports default html5 styles */

  var supportsHtml5Styles;
  /** Name of the expando, to work with multiple documents or to re-shiv one document */

  var expando = '_html5shiv';
  /** The id for the the documents expando */

  var expanID = 0;
  /** Cached data for each document */

  var expandoData = {};
  /** Detect whether the browser supports unknown elements */

  var supportsUnknownElements;

  (function () {
    try {
      var a = document.createElement('a');
      a.innerHTML = '<xyz></xyz>'; //if the hidden property is implemented we can assume, that the browser supports basic HTML5 Styles

      supportsHtml5Styles = 'hidden' in a;

      supportsUnknownElements = a.childNodes.length == 1 || function () {
        // assign a false positive if unable to shiv
        document.createElement('a');
        var frag = document.createDocumentFragment();
        return typeof frag.cloneNode == 'undefined' || typeof frag.createDocumentFragment == 'undefined' || typeof frag.createElement == 'undefined';
      }();
    } catch (e) {
      // assign a false positive if detection fails => unable to shiv
      supportsHtml5Styles = true;
      supportsUnknownElements = true;
    }
  })();
  /*--------------------------------------------------------------------------*/

  /**
   * Creates a style sheet with the given CSS text and adds it to the document.
   * @private
   * @param {Document} ownerDocument The document.
   * @param {String} cssText The CSS text.
   * @returns {StyleSheet} The style element.
   */


  function addStyleSheet(ownerDocument, cssText) {
    var p = ownerDocument.createElement('p'),
        parent = ownerDocument.getElementsByTagName('head')[0] || ownerDocument.documentElement;
    p.innerHTML = 'x<style>' + cssText + '</style>';
    return parent.insertBefore(p.lastChild, parent.firstChild);
  }
  /**
   * Returns the value of `html5.elements` as an array.
   * @private
   * @returns {Array} An array of shived element node names.
   */


  function getElements() {
    var elements = html5.elements;
    return typeof elements == 'string' ? elements.split(' ') : elements;
  }
  /**
   * Extends the built-in list of html5 elements
   * @memberOf html5
   * @param {String|Array} newElements whitespace separated list or array of new element names to shiv
   * @param {Document} ownerDocument The context document.
   */


  function addElements(newElements, ownerDocument) {
    var elements = html5.elements;

    if (typeof elements != 'string') {
      elements = elements.join(' ');
    }

    if (typeof newElements != 'string') {
      newElements = newElements.join(' ');
    }

    html5.elements = elements + ' ' + newElements;
    shivDocument(ownerDocument);
  }
  /**
  * Returns the data associated to the given document
  * @private
  * @param {Document} ownerDocument The document.
  * @returns {Object} An object of data.
  */


  function getExpandoData(ownerDocument) {
    var data = expandoData[ownerDocument[expando]];

    if (!data) {
      data = {};
      expanID++;
      ownerDocument[expando] = expanID;
      expandoData[expanID] = data;
    }

    return data;
  }
  /**
   * returns a shived element for the given nodeName and document
   * @memberOf html5
   * @param {String} nodeName name of the element
   * @param {Document|DocumentFragment} ownerDocument The context document.
   * @returns {Object} The shived element.
   */


  function createElement(nodeName, ownerDocument, data) {
    if (!ownerDocument) {
      ownerDocument = document;
    }

    if (supportsUnknownElements) {
      return ownerDocument.createElement(nodeName);
    }

    if (!data) {
      data = getExpandoData(ownerDocument);
    }

    var node;

    if (data.cache[nodeName]) {
      node = data.cache[nodeName].cloneNode();
    } else if (saveClones.test(nodeName)) {
      node = (data.cache[nodeName] = data.createElem(nodeName)).cloneNode();
    } else {
      node = data.createElem(nodeName);
    } // Avoid adding some elements to fragments in IE < 9 because
    // * Attributes like `name` or `type` cannot be set/changed once an element
    //   is inserted into a document/fragment
    // * Link elements with `src` attributes that are inaccessible, as with
    //   a 403 response, will cause the tab/window to crash
    // * Script elements appended to fragments will execute when their `src`
    //   or `text` property is set


    return node.canHaveChildren && !reSkip.test(nodeName) && !node.tagUrn ? data.frag.appendChild(node) : node;
  }
  /**
   * returns a shived DocumentFragment for the given document
   * @memberOf html5
   * @param {Document} ownerDocument The context document.
   * @returns {Object} The shived DocumentFragment.
   */


  function createDocumentFragment(ownerDocument, data) {
    if (!ownerDocument) {
      ownerDocument = document;
    }

    if (supportsUnknownElements) {
      return ownerDocument.createDocumentFragment();
    }

    data = data || getExpandoData(ownerDocument);
    var clone = data.frag.cloneNode(),
        i = 0,
        elems = getElements(),
        l = elems.length;

    for (; i < l; i++) {
      clone.createElement(elems[i]);
    }

    return clone;
  }
  /**
   * Shivs the `createElement` and `createDocumentFragment` methods of the document.
   * @private
   * @param {Document|DocumentFragment} ownerDocument The document.
   * @param {Object} data of the document.
   */


  function shivMethods(ownerDocument, data) {
    if (!data.cache) {
      data.cache = {};
      data.createElem = ownerDocument.createElement;
      data.createFrag = ownerDocument.createDocumentFragment;
      data.frag = data.createFrag();
    }

    ownerDocument.createElement = function (nodeName) {
      //abort shiv
      if (!html5.shivMethods) {
        return data.createElem(nodeName);
      }

      return createElement(nodeName, ownerDocument, data);
    };

    ownerDocument.createDocumentFragment = Function('h,f', 'return function(){' + 'var n=f.cloneNode(),c=n.createElement;' + 'h.shivMethods&&(' + // unroll the `createElement` calls
    getElements().join().replace(/[\w\-:]+/g, function (nodeName) {
      data.createElem(nodeName);
      data.frag.createElement(nodeName);
      return 'c("' + nodeName + '")';
    }) + ');return n}')(html5, data.frag);
  }
  /*--------------------------------------------------------------------------*/

  /**
   * Shivs the given document.
   * @memberOf html5
   * @param {Document} ownerDocument The document to shiv.
   * @returns {Document} The shived document.
   */


  function shivDocument(ownerDocument) {
    if (!ownerDocument) {
      ownerDocument = document;
    }

    var data = getExpandoData(ownerDocument);

    if (html5.shivCSS && !supportsHtml5Styles && !data.hasCSS) {
      data.hasCSS = !!addStyleSheet(ownerDocument, // corrects block display not defined in IE6/7/8/9
      'article,aside,dialog,figcaption,figure,footer,header,hgroup,main,nav,section{display:block}' + // adds styling not present in IE6/7/8/9
      'mark{background:#FF0;color:#000}' + // hides non-rendered elements
      'template{display:none}');
    }

    if (!supportsUnknownElements) {
      shivMethods(ownerDocument, data);
    }

    return ownerDocument;
  }
  /*--------------------------------------------------------------------------*/

  /**
   * The `html5` object is exposed so that more elements can be shived and
   * existing shiving can be detected on iframes.
   * @type Object
   * @example
   *
   * // options can be changed before the script is included
   * html5 = { 'elements': 'mark section', 'shivCSS': false, 'shivMethods': false };
   */


  var html5 = {
    /**
     * An array or space separated string of node names of the elements to shiv.
     * @memberOf html5
     * @type Array|String
     */
    'elements': options.elements || 'abbr article aside audio bdi canvas data datalist details dialog figcaption figure footer header hgroup main mark meter nav output picture progress section summary template time video',

    /**
     * current version of html5shiv
     */
    'version': version,

    /**
     * A flag to indicate that the HTML5 style sheet should be inserted.
     * @memberOf html5
     * @type Boolean
     */
    'shivCSS': options.shivCSS !== false,

    /**
     * Is equal to true if a browser supports creating unknown/HTML5 elements
     * @memberOf html5
     * @type boolean
     */
    'supportsUnknownElements': supportsUnknownElements,

    /**
     * A flag to indicate that the document's `createElement` and `createDocumentFragment`
     * methods should be overwritten.
     * @memberOf html5
     * @type Boolean
     */
    'shivMethods': options.shivMethods !== false,

    /**
     * A string to describe the type of `html5` object ("default" or "default print").
     * @memberOf html5
     * @type String
     */
    'type': 'default',
    // shivs the document according to the specified `html5` object options
    'shivDocument': shivDocument,
    //creates a shived element
    createElement: createElement,
    //creates a shived documentFragment
    createDocumentFragment: createDocumentFragment,
    //extends list of elements
    addElements: addElements
  };
  /*--------------------------------------------------------------------------*/
  // expose html5

  window.html5 = html5; // shiv the document

  shivDocument(document);

  if ( true && module.exports) {
    module.exports = html5;
  }
})(window, document);

/***/ }),

/***/ "./packages/tgui-polyfill/ie8.js":
/*!***************************************!*\
  !*** ./packages/tgui-polyfill/ie8.js ***!
  \***************************************/
/***/ (function() {

"use strict";


/**
 * @file
 * @copyright 2013 Andrea Giammarchi, WebReflection
 * @license MIT
 */

/* eslint-disable */
(function (window) {
  /*! (C) WebReflection Mit Style License */
  if (document.createEvent) return;

  var DUNNOABOUTDOMLOADED = true,
      READYEVENTDISPATCHED = false,
      ONREADYSTATECHANGE = 'onreadystatechange',
      DOMCONTENTLOADED = 'DOMContentLoaded',
      SECRET = '__IE8__' + Math.random(),
      // Object = window.Object,
  defineProperty = Object.defineProperty || // just in case ...
  function (object, property, descriptor) {
    object[property] = descriptor.value;
  },
      defineProperties = Object.defineProperties || // IE8 implemented defineProperty but not the plural...
  function (object, descriptors) {
    for (var key in descriptors) {
      if (hasOwnProperty.call(descriptors, key)) {
        try {
          defineProperty(object, key, descriptors[key]);
        } catch (o_O) {
          if (window.console) {
            console.log(key + ' failed on object:', object, o_O.message);
          }
        }
      }
    }
  },
      getOwnPropertyDescriptor = Object.getOwnPropertyDescriptor,
      hasOwnProperty = Object.prototype.hasOwnProperty,
      // here IE7 will break like a charm
  ElementPrototype = window.Element.prototype,
      TextPrototype = window.Text.prototype,
      // none of above native constructors exist/are exposed
  possiblyNativeEvent = /^[a-z]+$/,
      // ^ actually could probably be just /^[a-z]+$/
  readyStateOK = /loaded|complete/,
      types = {},
      div = document.createElement('div'),
      html = document.documentElement,
      removeAttribute = html.removeAttribute,
      setAttribute = html.setAttribute,
      valueDesc = function valueDesc(value) {
    return {
      enumerable: true,
      writable: true,
      configurable: true,
      value: value
    };
  };

  function commonEventLoop(currentTarget, e, $handlers, synthetic) {
    for (var handler, continuePropagation, handlers = $handlers.slice(), evt = enrich(e, currentTarget), i = 0, length = handlers.length; i < length; i++) {
      handler = handlers[i];

      if (typeof handler === 'object') {
        if (typeof handler.handleEvent === 'function') {
          handler.handleEvent(evt);
        }
      } else {
        handler.call(currentTarget, evt);
      }

      if (evt.stoppedImmediatePropagation) break;
    }

    continuePropagation = !evt.stoppedPropagation;
    /*
    if (continuePropagation && !synthetic && !live(currentTarget)) {
      evt.cancelBubble = true;
    }
    */

    return synthetic && continuePropagation && currentTarget.parentNode ? currentTarget.parentNode.dispatchEvent(evt) : !evt.defaultPrevented;
  }

  function commonDescriptor(get, set) {
    return {
      // if you try with enumerable: true
      // IE8 will miserably fail
      configurable: true,
      get: get,
      set: set
    };
  }

  function commonTextContent(protoDest, protoSource, property) {
    var descriptor = getOwnPropertyDescriptor(protoSource || protoDest, property);
    defineProperty(protoDest, 'textContent', commonDescriptor(function () {
      return descriptor.get.call(this);
    }, function (textContent) {
      descriptor.set.call(this, textContent);
    }));
  }

  function enrich(e, currentTarget) {
    e.currentTarget = currentTarget;
    e.eventPhase = // AT_TARGET : BUBBLING_PHASE
    e.target === e.currentTarget ? 2 : 3;
    return e;
  }

  function find(array, value) {
    var i = array.length;

    while (i-- && array[i] !== value) {
      ;
    }

    return i;
  }

  function getTextContent() {
    if (this.tagName === 'BR') return '\n';
    var textNode = this.firstChild,
        arrayContent = [];

    while (textNode) {
      if (textNode.nodeType !== 8 && textNode.nodeType !== 7) {
        arrayContent.push(textNode.textContent);
      }

      textNode = textNode.nextSibling;
    }

    return arrayContent.join('');
  }

  function live(self) {
    return self.nodeType !== 9 && html.contains(self);
  }

  function onkeyup(e) {
    var evt = document.createEvent('Event');
    evt.initEvent('input', true, true);
    (e.srcElement || e.fromElement || document).dispatchEvent(evt);
  }

  function onReadyState(e) {
    if (!READYEVENTDISPATCHED && readyStateOK.test(document.readyState)) {
      READYEVENTDISPATCHED = !READYEVENTDISPATCHED;
      document.detachEvent(ONREADYSTATECHANGE, onReadyState);
      e = document.createEvent('Event');
      e.initEvent(DOMCONTENTLOADED, true, true);
      document.dispatchEvent(e);
    }
  }

  function getter(attr) {
    return function () {
      return html[attr] || document.body && document.body[attr] || 0;
    };
  }

  function setTextContent(textContent) {
    var node;

    while (node = this.lastChild) {
      this.removeChild(node);
    }
    /*jshint eqnull:true */


    if (textContent != null) {
      this.appendChild(document.createTextNode(textContent));
    }
  }

  function verify(self, e) {
    if (!e) {
      e = window.event;
    }

    if (!e.target) {
      e.target = e.srcElement || e.fromElement || document;
    }

    if (!e.timeStamp) {
      e.timeStamp = new Date().getTime();
    }

    return e;
  } // normalized textContent for:
  //  comment, script, style, text, title


  commonTextContent(window.HTMLCommentElement.prototype, ElementPrototype, 'nodeValue');
  commonTextContent(window.HTMLScriptElement.prototype, null, 'text');
  commonTextContent(TextPrototype, null, 'nodeValue');
  commonTextContent(window.HTMLTitleElement.prototype, null, 'text');
  defineProperty(window.HTMLStyleElement.prototype, 'textContent', function (descriptor) {
    return commonDescriptor(function () {
      return descriptor.get.call(this.styleSheet);
    }, function (textContent) {
      descriptor.set.call(this.styleSheet, textContent);
    });
  }(getOwnPropertyDescriptor(window.CSSStyleSheet.prototype, 'cssText')));
  var opacityre = /\b\s*alpha\s*\(\s*opacity\s*=\s*(\d+)\s*\)/;
  defineProperty(window.CSSStyleDeclaration.prototype, 'opacity', {
    get: function () {
      function get() {
        var m = this.filter.match(opacityre);
        return m ? (m[1] / 100).toString() : '';
      }

      return get;
    }(),
    set: function () {
      function set(value) {
        this.zoom = 1;
        var found = false;

        if (value < 1) {
          value = ' alpha(opacity=' + Math.round(value * 100) + ')';
        } else {
          value = '';
        }

        this.filter = this.filter.replace(opacityre, function () {
          found = true;
          return value;
        });

        if (!found && value) {
          this.filter += value;
        }
      }

      return set;
    }()
  });
  defineProperties(ElementPrototype, {
    // bonus
    textContent: {
      get: getTextContent,
      set: setTextContent
    },
    // http://www.w3.org/TR/ElementTraversal/#interface-elementTraversal
    firstElementChild: {
      get: function () {
        function get() {
          for (var childNodes = this.childNodes || [], i = 0, length = childNodes.length; i < length; i++) {
            if (childNodes[i].nodeType == 1) return childNodes[i];
          }
        }

        return get;
      }()
    },
    lastElementChild: {
      get: function () {
        function get() {
          for (var childNodes = this.childNodes || [], i = childNodes.length; i--;) {
            if (childNodes[i].nodeType == 1) return childNodes[i];
          }
        }

        return get;
      }()
    },
    oninput: {
      get: function () {
        function get() {
          return this._oninput || null;
        }

        return get;
      }(),
      set: function () {
        function set(oninput) {
          if (this._oninput) {
            this.removeEventListener('input', this._oninput);
            this._oninput = oninput;

            if (oninput) {
              this.addEventListener('input', oninput);
            }
          }
        }

        return set;
      }()
    },
    previousElementSibling: {
      get: function () {
        function get() {
          var previousElementSibling = this.previousSibling;

          while (previousElementSibling && previousElementSibling.nodeType != 1) {
            previousElementSibling = previousElementSibling.previousSibling;
          }

          return previousElementSibling;
        }

        return get;
      }()
    },
    nextElementSibling: {
      get: function () {
        function get() {
          var nextElementSibling = this.nextSibling;

          while (nextElementSibling && nextElementSibling.nodeType != 1) {
            nextElementSibling = nextElementSibling.nextSibling;
          }

          return nextElementSibling;
        }

        return get;
      }()
    },
    childElementCount: {
      get: function () {
        function get() {
          for (var count = 0, childNodes = this.childNodes || [], i = childNodes.length; i--; count += childNodes[i].nodeType == 1) {
            ;
          }

          return count;
        }

        return get;
      }()
    },

    /*
    // children would be an override
    // IE8 already supports them but with comments too
    // not just nodeType 1
    children: {
      get: function () {
        for(var
          children = [],
          childNodes = this.childNodes || [],
          i = 0, length = childNodes.length;
          i < length; i++
        ) {
          if (childNodes[i].nodeType == 1) {
            children.push(childNodes[i]);
          }
        }
        return children;
      }
    },
    */
    // DOM Level 2 EventTarget methods and events
    addEventListener: valueDesc(function (type, handler, capture) {
      if (typeof handler !== 'function' && typeof handler !== 'object') return;
      var self = this,
          ontype = 'on' + type,
          temple = self[SECRET] || defineProperty(self, SECRET, {
        value: {}
      })[SECRET],
          currentType = temple[ontype] || (temple[ontype] = {}),
          handlers = currentType.h || (currentType.h = []),
          e,
          attr;

      if (!hasOwnProperty.call(currentType, 'w')) {
        currentType.w = function (e) {
          // e[SECRET] is a silent notification needed to avoid
          // fired events during live test
          return e[SECRET] || commonEventLoop(self, verify(self, e), handlers, false);
        }; // if not detected yet


        if (!hasOwnProperty.call(types, ontype)) {
          // and potentially a native event
          if (possiblyNativeEvent.test(type)) {
            // do this heavy thing
            try {
              // TODO:  should I consider tagName too so that
              //        INPUT[ontype] could be different ?
              e = document.createEventObject(); // do not clone ever a node
              // specially a document one ...
              // use the secret to ignore them all

              e[SECRET] = true; // document a part if a node has never been
              // added to any other node, fireEvent might
              // behave very weirdly (read: trigger unspecified errors)

              if (self.nodeType != 9) {
                /*jshint eqnull:true */
                if (self.parentNode == null) {
                  div.appendChild(self);
                }

                if (attr = self.getAttribute(ontype)) {
                  removeAttribute.call(self, ontype);
                }
              }

              self.fireEvent(ontype, e);
              types[ontype] = true;
            } catch (meh) {
              types[ontype] = false;

              while (div.hasChildNodes()) {
                div.removeChild(div.firstChild);
              }
            }

            if (attr != null) {
              setAttribute.call(self, ontype, attr);
            }
          } else {
            // no need to bother since
            // 'x-event' ain't native for sure
            types[ontype] = false;
          }
        }

        if (currentType.n = types[ontype]) {
          self.attachEvent(ontype, currentType.w);
        }
      }

      if (find(handlers, handler) < 0) {
        handlers[capture ? 'unshift' : 'push'](handler);
      }

      if (type === 'input') {
        self.attachEvent('onkeyup', onkeyup);
      }
    }),
    dispatchEvent: valueDesc(function (e) {
      var self = this,
          ontype = 'on' + e.type,
          temple = self[SECRET],
          currentType = temple && temple[ontype],
          valid = !!currentType,
          parentNode;
      if (!e.target) e.target = self;
      return valid ? currentType.n
      /* && live(self) */
      ? self.fireEvent(ontype, e) : commonEventLoop(self, e, currentType.h, true) : (parentNode = self.parentNode) ?
      /* && live(self) */
      parentNode.dispatchEvent(e) : true, !e.defaultPrevented;
    }),
    removeEventListener: valueDesc(function (type, handler, capture) {
      if (typeof handler !== 'function' && typeof handler !== 'object') return;
      var self = this,
          ontype = 'on' + type,
          temple = self[SECRET],
          currentType = temple && temple[ontype],
          handlers = currentType && currentType.h,
          i = handlers ? find(handlers, handler) : -1;
      if (-1 < i) handlers.splice(i, 1);
    })
  });
  /* this is not needed in IE8
  defineProperties(window.HTMLSelectElement.prototype, {
    value: {
      get: function () {
        return this.options[this.selectedIndex].value;
      }
    }
  });
  //*/
  // EventTarget methods for Text nodes too

  defineProperties(TextPrototype, {
    addEventListener: valueDesc(ElementPrototype.addEventListener),
    dispatchEvent: valueDesc(ElementPrototype.dispatchEvent),
    removeEventListener: valueDesc(ElementPrototype.removeEventListener)
  });
  defineProperties(window.XMLHttpRequest.prototype, {
    addEventListener: valueDesc(function (type, handler, capture) {
      var self = this,
          ontype = 'on' + type,
          temple = self[SECRET] || defineProperty(self, SECRET, {
        value: {}
      })[SECRET],
          currentType = temple[ontype] || (temple[ontype] = {}),
          handlers = currentType.h || (currentType.h = []);

      if (find(handlers, handler) < 0) {
        if (!self[ontype]) {
          self[ontype] = function () {
            var e = document.createEvent('Event');
            e.initEvent(type, true, true);
            self.dispatchEvent(e);
          };
        }

        handlers[capture ? 'unshift' : 'push'](handler);
      }
    }),
    dispatchEvent: valueDesc(function (e) {
      var self = this,
          ontype = 'on' + e.type,
          temple = self[SECRET],
          currentType = temple && temple[ontype],
          valid = !!currentType;
      return valid && (currentType.n
      /* && live(self) */
      ? self.fireEvent(ontype, e) : commonEventLoop(self, e, currentType.h, true));
    }),
    removeEventListener: valueDesc(ElementPrototype.removeEventListener)
  });
  var buttonGetter = getOwnPropertyDescriptor(Event.prototype, 'button').get;
  defineProperties(window.Event.prototype, {
    bubbles: valueDesc(true),
    cancelable: valueDesc(true),
    preventDefault: valueDesc(function () {
      if (this.cancelable) {
        this.returnValue = false;
      }
    }),
    stopPropagation: valueDesc(function () {
      this.stoppedPropagation = true;
      this.cancelBubble = true;
    }),
    stopImmediatePropagation: valueDesc(function () {
      this.stoppedImmediatePropagation = true;
      this.stopPropagation();
    }),
    initEvent: valueDesc(function (type, bubbles, cancelable) {
      this.type = type;
      this.bubbles = !!bubbles;
      this.cancelable = !!cancelable;

      if (!this.bubbles) {
        this.stopPropagation();
      }
    }),
    pageX: {
      get: function () {
        function get() {
          return this._pageX || (this._pageX = this.clientX + window.scrollX - (html.clientLeft || 0));
        }

        return get;
      }()
    },
    pageY: {
      get: function () {
        function get() {
          return this._pageY || (this._pageY = this.clientY + window.scrollY - (html.clientTop || 0));
        }

        return get;
      }()
    },
    which: {
      get: function () {
        function get() {
          return this.keyCode ? this.keyCode : isNaN(this.button) ? undefined : this.button + 1;
        }

        return get;
      }()
    },
    charCode: {
      get: function () {
        function get() {
          return this.keyCode && this.type == 'keypress' ? this.keyCode : 0;
        }

        return get;
      }()
    },
    buttons: {
      get: function () {
        function get() {
          return buttonGetter.call(this);
        }

        return get;
      }()
    },
    button: {
      get: function () {
        function get() {
          var buttons = this.buttons;
          return buttons & 1 ? 0 : buttons & 2 ? 2 : buttons & 4 ? 1 : undefined;
        }

        return get;
      }()
    },
    defaultPrevented: {
      get: function () {
        function get() {
          // if preventDefault() was never called, or returnValue not given a value
          // then returnValue is undefined
          var returnValue = this.returnValue,
              undef;
          return !(returnValue === undef || returnValue);
        }

        return get;
      }()
    },
    relatedTarget: {
      get: function () {
        function get() {
          var type = this.type;

          if (type === 'mouseover') {
            return this.fromElement;
          } else if (type === 'mouseout') {
            return this.toElement;
          } else {
            return null;
          }
        }

        return get;
      }()
    }
  });
  defineProperties(window.HTMLDocument.prototype, {
    defaultView: {
      get: function () {
        function get() {
          return this.parentWindow;
        }

        return get;
      }()
    },
    textContent: {
      get: function () {
        function get() {
          return this.nodeType === 11 ? getTextContent.call(this) : null;
        }

        return get;
      }(),
      set: function () {
        function set(textContent) {
          if (this.nodeType === 11) {
            setTextContent.call(this, textContent);
          }
        }

        return set;
      }()
    },
    addEventListener: valueDesc(function (type, handler, capture) {
      var self = this;
      ElementPrototype.addEventListener.call(self, type, handler, capture); // NOTE:  it won't fire if already loaded, this is NOT a $.ready() shim!
      //        this behaves just like standard browsers

      if (DUNNOABOUTDOMLOADED && type === DOMCONTENTLOADED && !readyStateOK.test(self.readyState)) {
        DUNNOABOUTDOMLOADED = false;
        self.attachEvent(ONREADYSTATECHANGE, onReadyState);
        /* global top */

        if (window == top) {
          (function () {
            function gonna(e) {
              try {
                self.documentElement.doScroll('left');
                onReadyState();
              } catch (o_O) {
                setTimeout(gonna, 50);
              }
            }

            return gonna;
          })()();
        }
      }
    }),
    dispatchEvent: valueDesc(ElementPrototype.dispatchEvent),
    removeEventListener: valueDesc(ElementPrototype.removeEventListener),
    createEvent: valueDesc(function (Class) {
      var e;
      if (Class !== 'Event') throw new Error('unsupported ' + Class);
      e = document.createEventObject();
      e.timeStamp = new Date().getTime();
      return e;
    })
  });
  defineProperties(window.Window.prototype, {
    getComputedStyle: valueDesc(function () {
      var // partially grabbed from jQuery and Dean's hack
      notpixel = /^(?:[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|))(?!px)[a-z%]+$/,
          position = /^(top|right|bottom|left)$/,
          re = /\-([a-z])/g,
          place = function place(match, $1) {
        return $1.toUpperCase();
      };

      function ComputedStyle(_) {
        this._ = _;
      }

      ComputedStyle.prototype.getPropertyValue = function (name) {
        var el = this._,
            style = el.style,
            currentStyle = el.currentStyle,
            runtimeStyle = el.runtimeStyle,
            result,
            left,
            rtLeft;

        if (name == 'opacity') {
          return style.opacity || '1';
        }

        name = (name === 'float' ? 'style-float' : name).replace(re, place);
        result = currentStyle ? currentStyle[name] : style[name];

        if (notpixel.test(result) && !position.test(name)) {
          left = style.left;
          rtLeft = runtimeStyle && runtimeStyle.left;

          if (rtLeft) {
            runtimeStyle.left = currentStyle.left;
          }

          style.left = name === 'fontSize' ? '1em' : result;
          result = style.pixelLeft + 'px';
          style.left = left;

          if (rtLeft) {
            runtimeStyle.left = rtLeft;
          }
        }
        /*jshint eqnull:true */


        return result == null ? result : result + '' || 'auto';
      }; // unsupported


      function PseudoComputedStyle() {}

      PseudoComputedStyle.prototype.getPropertyValue = function () {
        return null;
      };

      return function (el, pseudo) {
        return pseudo ? new PseudoComputedStyle(el) : new ComputedStyle(el);
      };
    }()),
    addEventListener: valueDesc(function (type, handler, capture) {
      var self = window,
          ontype = 'on' + type,
          handlers;

      if (!self[ontype]) {
        self[ontype] = function (e) {
          return commonEventLoop(self, verify(self, e), handlers, false) && undefined;
        };
      }

      handlers = self[ontype][SECRET] || (self[ontype][SECRET] = []);

      if (find(handlers, handler) < 0) {
        handlers[capture ? 'unshift' : 'push'](handler);
      }
    }),
    dispatchEvent: valueDesc(function (e) {
      var method = window['on' + e.type];
      return method ? method.call(window, e) !== false && !e.defaultPrevented : true;
    }),
    removeEventListener: valueDesc(function (type, handler, capture) {
      var ontype = 'on' + type,
          handlers = (window[ontype] || Object)[SECRET],
          i = handlers ? find(handlers, handler) : -1;
      if (-1 < i) handlers.splice(i, 1);
    }),
    pageXOffset: {
      get: getter('scrollLeft')
    },
    pageYOffset: {
      get: getter('scrollTop')
    },
    scrollX: {
      get: getter('scrollLeft')
    },
    scrollY: {
      get: getter('scrollTop')
    },
    innerWidth: {
      get: getter('clientWidth')
    },
    innerHeight: {
      get: getter('clientHeight')
    }
  });
  window.HTMLElement = window.Element;

  (function (styleSheets, HTML5Element, i) {
    for (i = 0; i < HTML5Element.length; i++) {
      document.createElement(HTML5Element[i]);
    }

    if (!styleSheets.length) document.createStyleSheet('');
    styleSheets[0].addRule(HTML5Element.join(','), 'display:block;');
  })(document.styleSheets, ['header', 'nav', 'section', 'article', 'aside', 'footer']);

  (function () {
    if (document.createRange) return;

    document.createRange = function () {
      function createRange() {
        return new Range();
      }

      return createRange;
    }();

    function getContents(start, end) {
      var nodes = [start];

      while (start !== end) {
        nodes.push(start = start.nextSibling);
      }

      return nodes;
    }

    function Range() {}

    var proto = Range.prototype;

    proto.cloneContents = function () {
      function cloneContents() {
        for (var fragment = this._start.ownerDocument.createDocumentFragment(), nodes = getContents(this._start, this._end), i = 0, length = nodes.length; i < length; i++) {
          fragment.appendChild(nodes[i].cloneNode(true));
        }

        return fragment;
      }

      return cloneContents;
    }();

    proto.cloneRange = function () {
      function cloneRange() {
        var range = new Range();
        range._start = this._start;
        range._end = this._end;
        return range;
      }

      return cloneRange;
    }();

    proto.deleteContents = function () {
      function deleteContents() {
        for (var parentNode = this._start.parentNode, nodes = getContents(this._start, this._end), i = 0, length = nodes.length; i < length; i++) {
          parentNode.removeChild(nodes[i]);
        }
      }

      return deleteContents;
    }();

    proto.extractContents = function () {
      function extractContents() {
        for (var fragment = this._start.ownerDocument.createDocumentFragment(), nodes = getContents(this._start, this._end), i = 0, length = nodes.length; i < length; i++) {
          fragment.appendChild(nodes[i]);
        }

        return fragment;
      }

      return extractContents;
    }();

    proto.setEndAfter = function () {
      function setEndAfter(node) {
        this._end = node;
      }

      return setEndAfter;
    }();

    proto.setEndBefore = function () {
      function setEndBefore(node) {
        this._end = node.previousSibling;
      }

      return setEndBefore;
    }();

    proto.setStartAfter = function () {
      function setStartAfter(node) {
        this._start = node.nextSibling;
      }

      return setStartAfter;
    }();

    proto.setStartBefore = function () {
      function setStartBefore(node) {
        this._start = node;
      }

      return setStartBefore;
    }();
  })();
})(window);

/***/ }),

/***/ "./packages/tgui-polyfill/index.js":
/*!*****************************************!*\
  !*** ./packages/tgui-polyfill/index.js ***!
  \*****************************************/
/***/ (function(__unused_webpack_module, __unused_webpack_exports, __webpack_require__) {

"use strict";


__webpack_require__(/*! core-js/modules/es.symbol.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.symbol.js");

__webpack_require__(/*! core-js/modules/es.symbol.description.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.symbol.description.js");

__webpack_require__(/*! core-js/modules/es.symbol.async-iterator.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.symbol.async-iterator.js");

__webpack_require__(/*! core-js/modules/es.symbol.has-instance.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.symbol.has-instance.js");

__webpack_require__(/*! core-js/modules/es.symbol.is-concat-spreadable.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.symbol.is-concat-spreadable.js");

__webpack_require__(/*! core-js/modules/es.symbol.iterator.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.symbol.iterator.js");

__webpack_require__(/*! core-js/modules/es.symbol.match.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.symbol.match.js");

__webpack_require__(/*! core-js/modules/es.symbol.replace.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.symbol.replace.js");

__webpack_require__(/*! core-js/modules/es.symbol.search.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.symbol.search.js");

__webpack_require__(/*! core-js/modules/es.symbol.species.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.symbol.species.js");

__webpack_require__(/*! core-js/modules/es.symbol.split.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.symbol.split.js");

__webpack_require__(/*! core-js/modules/es.symbol.to-primitive.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.symbol.to-primitive.js");

__webpack_require__(/*! core-js/modules/es.symbol.to-string-tag.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.symbol.to-string-tag.js");

__webpack_require__(/*! core-js/modules/es.symbol.unscopables.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.symbol.unscopables.js");

__webpack_require__(/*! core-js/modules/es.array.concat.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.concat.js");

__webpack_require__(/*! core-js/modules/es.array.copy-within.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.copy-within.js");

__webpack_require__(/*! core-js/modules/es.array.every.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.every.js");

__webpack_require__(/*! core-js/modules/es.array.fill.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.fill.js");

__webpack_require__(/*! core-js/modules/es.array.filter.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.filter.js");

__webpack_require__(/*! core-js/modules/es.array.find.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.find.js");

__webpack_require__(/*! core-js/modules/es.array.find-index.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.find-index.js");

__webpack_require__(/*! core-js/modules/es.array.flat.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.flat.js");

__webpack_require__(/*! core-js/modules/es.array.flat-map.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.flat-map.js");

__webpack_require__(/*! core-js/modules/es.array.for-each.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.for-each.js");

__webpack_require__(/*! core-js/modules/es.array.from.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.from.js");

__webpack_require__(/*! core-js/modules/es.array.includes.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.includes.js");

__webpack_require__(/*! core-js/modules/es.array.index-of.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.index-of.js");

__webpack_require__(/*! core-js/modules/es.array.is-array.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.is-array.js");

__webpack_require__(/*! core-js/modules/es.array.iterator.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.iterator.js");

__webpack_require__(/*! core-js/modules/es.array.join.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.join.js");

__webpack_require__(/*! core-js/modules/es.array.last-index-of.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.last-index-of.js");

__webpack_require__(/*! core-js/modules/es.array.map.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.map.js");

__webpack_require__(/*! core-js/modules/es.array.of.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.of.js");

__webpack_require__(/*! core-js/modules/es.array.reduce.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.reduce.js");

__webpack_require__(/*! core-js/modules/es.array.reduce-right.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.reduce-right.js");

__webpack_require__(/*! core-js/modules/es.array.reverse.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.reverse.js");

__webpack_require__(/*! core-js/modules/es.array.slice.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.slice.js");

__webpack_require__(/*! core-js/modules/es.array.some.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.some.js");

__webpack_require__(/*! core-js/modules/es.array.sort.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.sort.js");

__webpack_require__(/*! core-js/modules/es.array.species.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.species.js");

__webpack_require__(/*! core-js/modules/es.array.splice.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.splice.js");

__webpack_require__(/*! core-js/modules/es.array.unscopables.flat.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.unscopables.flat.js");

__webpack_require__(/*! core-js/modules/es.array.unscopables.flat-map.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array.unscopables.flat-map.js");

__webpack_require__(/*! core-js/modules/es.array-buffer.constructor.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array-buffer.constructor.js");

__webpack_require__(/*! core-js/modules/es.array-buffer.is-view.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array-buffer.is-view.js");

__webpack_require__(/*! core-js/modules/es.array-buffer.slice.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.array-buffer.slice.js");

__webpack_require__(/*! core-js/modules/es.data-view.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.data-view.js");

__webpack_require__(/*! core-js/modules/es.date.now.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.date.now.js");

__webpack_require__(/*! core-js/modules/es.date.to-iso-string.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.date.to-iso-string.js");

__webpack_require__(/*! core-js/modules/es.date.to-json.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.date.to-json.js");

__webpack_require__(/*! core-js/modules/es.date.to-primitive.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.date.to-primitive.js");

__webpack_require__(/*! core-js/modules/es.date.to-string.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.date.to-string.js");

__webpack_require__(/*! core-js/modules/es.function.bind.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.function.bind.js");

__webpack_require__(/*! core-js/modules/es.function.has-instance.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.function.has-instance.js");

__webpack_require__(/*! core-js/modules/es.function.name.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.function.name.js");

__webpack_require__(/*! core-js/modules/es.json.to-string-tag.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.json.to-string-tag.js");

__webpack_require__(/*! core-js/modules/es.map.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.map.js");

__webpack_require__(/*! core-js/modules/es.math.acosh.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.acosh.js");

__webpack_require__(/*! core-js/modules/es.math.asinh.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.asinh.js");

__webpack_require__(/*! core-js/modules/es.math.atanh.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.atanh.js");

__webpack_require__(/*! core-js/modules/es.math.cbrt.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.cbrt.js");

__webpack_require__(/*! core-js/modules/es.math.clz32.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.clz32.js");

__webpack_require__(/*! core-js/modules/es.math.cosh.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.cosh.js");

__webpack_require__(/*! core-js/modules/es.math.expm1.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.expm1.js");

__webpack_require__(/*! core-js/modules/es.math.fround.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.fround.js");

__webpack_require__(/*! core-js/modules/es.math.hypot.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.hypot.js");

__webpack_require__(/*! core-js/modules/es.math.imul.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.imul.js");

__webpack_require__(/*! core-js/modules/es.math.log10.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.log10.js");

__webpack_require__(/*! core-js/modules/es.math.log1p.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.log1p.js");

__webpack_require__(/*! core-js/modules/es.math.log2.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.log2.js");

__webpack_require__(/*! core-js/modules/es.math.sign.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.sign.js");

__webpack_require__(/*! core-js/modules/es.math.sinh.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.sinh.js");

__webpack_require__(/*! core-js/modules/es.math.tanh.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.tanh.js");

__webpack_require__(/*! core-js/modules/es.math.to-string-tag.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.to-string-tag.js");

__webpack_require__(/*! core-js/modules/es.math.trunc.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.math.trunc.js");

__webpack_require__(/*! core-js/modules/es.number.constructor.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.number.constructor.js");

__webpack_require__(/*! core-js/modules/es.number.epsilon.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.number.epsilon.js");

__webpack_require__(/*! core-js/modules/es.number.is-finite.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.number.is-finite.js");

__webpack_require__(/*! core-js/modules/es.number.is-integer.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.number.is-integer.js");

__webpack_require__(/*! core-js/modules/es.number.is-nan.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.number.is-nan.js");

__webpack_require__(/*! core-js/modules/es.number.is-safe-integer.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.number.is-safe-integer.js");

__webpack_require__(/*! core-js/modules/es.number.max-safe-integer.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.number.max-safe-integer.js");

__webpack_require__(/*! core-js/modules/es.number.min-safe-integer.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.number.min-safe-integer.js");

__webpack_require__(/*! core-js/modules/es.number.parse-float.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.number.parse-float.js");

__webpack_require__(/*! core-js/modules/es.number.parse-int.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.number.parse-int.js");

__webpack_require__(/*! core-js/modules/es.number.to-fixed.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.number.to-fixed.js");

__webpack_require__(/*! core-js/modules/es.number.to-precision.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.number.to-precision.js");

__webpack_require__(/*! core-js/modules/es.object.assign.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.assign.js");

__webpack_require__(/*! core-js/modules/es.object.create.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.create.js");

__webpack_require__(/*! core-js/modules/es.object.define-getter.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.define-getter.js");

__webpack_require__(/*! core-js/modules/es.object.define-properties.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.define-properties.js");

__webpack_require__(/*! core-js/modules/es.object.define-property.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.define-property.js");

__webpack_require__(/*! core-js/modules/es.object.define-setter.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.define-setter.js");

__webpack_require__(/*! core-js/modules/es.object.entries.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.entries.js");

__webpack_require__(/*! core-js/modules/es.object.freeze.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.freeze.js");

__webpack_require__(/*! core-js/modules/es.object.from-entries.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.from-entries.js");

__webpack_require__(/*! core-js/modules/es.object.get-own-property-descriptor.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.get-own-property-descriptor.js");

__webpack_require__(/*! core-js/modules/es.object.get-own-property-descriptors.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.get-own-property-descriptors.js");

__webpack_require__(/*! core-js/modules/es.object.get-own-property-names.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.get-own-property-names.js");

__webpack_require__(/*! core-js/modules/es.object.get-prototype-of.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.get-prototype-of.js");

__webpack_require__(/*! core-js/modules/es.object.is.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.is.js");

__webpack_require__(/*! core-js/modules/es.object.is-extensible.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.is-extensible.js");

__webpack_require__(/*! core-js/modules/es.object.is-frozen.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.is-frozen.js");

__webpack_require__(/*! core-js/modules/es.object.is-sealed.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.is-sealed.js");

__webpack_require__(/*! core-js/modules/es.object.keys.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.keys.js");

__webpack_require__(/*! core-js/modules/es.object.lookup-getter.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.lookup-getter.js");

__webpack_require__(/*! core-js/modules/es.object.lookup-setter.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.lookup-setter.js");

__webpack_require__(/*! core-js/modules/es.object.prevent-extensions.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.prevent-extensions.js");

__webpack_require__(/*! core-js/modules/es.object.seal.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.seal.js");

__webpack_require__(/*! core-js/modules/es.object.set-prototype-of.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.set-prototype-of.js");

__webpack_require__(/*! core-js/modules/es.object.to-string.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.to-string.js");

__webpack_require__(/*! core-js/modules/es.object.values.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.object.values.js");

__webpack_require__(/*! core-js/modules/es.parse-float.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.parse-float.js");

__webpack_require__(/*! core-js/modules/es.parse-int.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.parse-int.js");

__webpack_require__(/*! core-js/modules/es.promise.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.promise.js");

__webpack_require__(/*! core-js/modules/es.promise.finally.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.promise.finally.js");

__webpack_require__(/*! core-js/modules/es.reflect.apply.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.reflect.apply.js");

__webpack_require__(/*! core-js/modules/es.reflect.construct.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.reflect.construct.js");

__webpack_require__(/*! core-js/modules/es.reflect.define-property.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.reflect.define-property.js");

__webpack_require__(/*! core-js/modules/es.reflect.delete-property.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.reflect.delete-property.js");

__webpack_require__(/*! core-js/modules/es.reflect.get.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.reflect.get.js");

__webpack_require__(/*! core-js/modules/es.reflect.get-own-property-descriptor.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.reflect.get-own-property-descriptor.js");

__webpack_require__(/*! core-js/modules/es.reflect.get-prototype-of.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.reflect.get-prototype-of.js");

__webpack_require__(/*! core-js/modules/es.reflect.has.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.reflect.has.js");

__webpack_require__(/*! core-js/modules/es.reflect.is-extensible.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.reflect.is-extensible.js");

__webpack_require__(/*! core-js/modules/es.reflect.own-keys.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.reflect.own-keys.js");

__webpack_require__(/*! core-js/modules/es.reflect.prevent-extensions.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.reflect.prevent-extensions.js");

__webpack_require__(/*! core-js/modules/es.reflect.set.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.reflect.set.js");

__webpack_require__(/*! core-js/modules/es.reflect.set-prototype-of.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.reflect.set-prototype-of.js");

__webpack_require__(/*! core-js/modules/es.regexp.constructor.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.regexp.constructor.js");

__webpack_require__(/*! core-js/modules/es.regexp.exec.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.regexp.exec.js");

__webpack_require__(/*! core-js/modules/es.regexp.flags.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.regexp.flags.js");

__webpack_require__(/*! core-js/modules/es.regexp.to-string.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.regexp.to-string.js");

__webpack_require__(/*! core-js/modules/es.set.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.set.js");

__webpack_require__(/*! core-js/modules/es.string.code-point-at.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.code-point-at.js");

__webpack_require__(/*! core-js/modules/es.string.ends-with.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.ends-with.js");

__webpack_require__(/*! core-js/modules/es.string.from-code-point.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.from-code-point.js");

__webpack_require__(/*! core-js/modules/es.string.includes.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.includes.js");

__webpack_require__(/*! core-js/modules/es.string.iterator.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.iterator.js");

__webpack_require__(/*! core-js/modules/es.string.match.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.match.js");

__webpack_require__(/*! core-js/modules/es.string.pad-end.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.pad-end.js");

__webpack_require__(/*! core-js/modules/es.string.pad-start.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.pad-start.js");

__webpack_require__(/*! core-js/modules/es.string.raw.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.raw.js");

__webpack_require__(/*! core-js/modules/es.string.repeat.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.repeat.js");

__webpack_require__(/*! core-js/modules/es.string.replace.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.replace.js");

__webpack_require__(/*! core-js/modules/es.string.search.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.search.js");

__webpack_require__(/*! core-js/modules/es.string.split.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.split.js");

__webpack_require__(/*! core-js/modules/es.string.starts-with.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.starts-with.js");

__webpack_require__(/*! core-js/modules/es.string.trim.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.trim.js");

__webpack_require__(/*! core-js/modules/es.string.trim-end.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.trim-end.js");

__webpack_require__(/*! core-js/modules/es.string.trim-start.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.trim-start.js");

__webpack_require__(/*! core-js/modules/es.string.anchor.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.anchor.js");

__webpack_require__(/*! core-js/modules/es.string.big.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.big.js");

__webpack_require__(/*! core-js/modules/es.string.blink.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.blink.js");

__webpack_require__(/*! core-js/modules/es.string.bold.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.bold.js");

__webpack_require__(/*! core-js/modules/es.string.fixed.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.fixed.js");

__webpack_require__(/*! core-js/modules/es.string.fontcolor.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.fontcolor.js");

__webpack_require__(/*! core-js/modules/es.string.fontsize.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.fontsize.js");

__webpack_require__(/*! core-js/modules/es.string.italics.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.italics.js");

__webpack_require__(/*! core-js/modules/es.string.link.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.link.js");

__webpack_require__(/*! core-js/modules/es.string.small.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.small.js");

__webpack_require__(/*! core-js/modules/es.string.strike.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.strike.js");

__webpack_require__(/*! core-js/modules/es.string.sub.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.sub.js");

__webpack_require__(/*! core-js/modules/es.string.sup.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.string.sup.js");

__webpack_require__(/*! core-js/modules/es.typed-array.float32-array.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.float32-array.js");

__webpack_require__(/*! core-js/modules/es.typed-array.float64-array.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.float64-array.js");

__webpack_require__(/*! core-js/modules/es.typed-array.int8-array.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.int8-array.js");

__webpack_require__(/*! core-js/modules/es.typed-array.int16-array.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.int16-array.js");

__webpack_require__(/*! core-js/modules/es.typed-array.int32-array.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.int32-array.js");

__webpack_require__(/*! core-js/modules/es.typed-array.uint8-array.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.uint8-array.js");

__webpack_require__(/*! core-js/modules/es.typed-array.uint8-clamped-array.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.uint8-clamped-array.js");

__webpack_require__(/*! core-js/modules/es.typed-array.uint16-array.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.uint16-array.js");

__webpack_require__(/*! core-js/modules/es.typed-array.uint32-array.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.uint32-array.js");

__webpack_require__(/*! core-js/modules/es.typed-array.copy-within.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.copy-within.js");

__webpack_require__(/*! core-js/modules/es.typed-array.every.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.every.js");

__webpack_require__(/*! core-js/modules/es.typed-array.fill.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.fill.js");

__webpack_require__(/*! core-js/modules/es.typed-array.filter.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.filter.js");

__webpack_require__(/*! core-js/modules/es.typed-array.find.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.find.js");

__webpack_require__(/*! core-js/modules/es.typed-array.find-index.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.find-index.js");

__webpack_require__(/*! core-js/modules/es.typed-array.for-each.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.for-each.js");

__webpack_require__(/*! core-js/modules/es.typed-array.from.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.from.js");

__webpack_require__(/*! core-js/modules/es.typed-array.includes.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.includes.js");

__webpack_require__(/*! core-js/modules/es.typed-array.index-of.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.index-of.js");

__webpack_require__(/*! core-js/modules/es.typed-array.iterator.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.iterator.js");

__webpack_require__(/*! core-js/modules/es.typed-array.join.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.join.js");

__webpack_require__(/*! core-js/modules/es.typed-array.last-index-of.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.last-index-of.js");

__webpack_require__(/*! core-js/modules/es.typed-array.map.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.map.js");

__webpack_require__(/*! core-js/modules/es.typed-array.of.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.of.js");

__webpack_require__(/*! core-js/modules/es.typed-array.reduce.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.reduce.js");

__webpack_require__(/*! core-js/modules/es.typed-array.reduce-right.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.reduce-right.js");

__webpack_require__(/*! core-js/modules/es.typed-array.reverse.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.reverse.js");

__webpack_require__(/*! core-js/modules/es.typed-array.set.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.set.js");

__webpack_require__(/*! core-js/modules/es.typed-array.slice.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.slice.js");

__webpack_require__(/*! core-js/modules/es.typed-array.some.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.some.js");

__webpack_require__(/*! core-js/modules/es.typed-array.sort.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.sort.js");

__webpack_require__(/*! core-js/modules/es.typed-array.subarray.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.subarray.js");

__webpack_require__(/*! core-js/modules/es.typed-array.to-locale-string.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.to-locale-string.js");

__webpack_require__(/*! core-js/modules/es.typed-array.to-string.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.typed-array.to-string.js");

__webpack_require__(/*! core-js/modules/es.weak-map.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.weak-map.js");

__webpack_require__(/*! core-js/modules/es.weak-set.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/es.weak-set.js");

__webpack_require__(/*! core-js/modules/web.immediate.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/web.immediate.js");

__webpack_require__(/*! core-js/modules/web.queue-microtask.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/web.queue-microtask.js");

__webpack_require__(/*! core-js/modules/web.timers.js */ "./.yarn/cache/core-js-npm-3.10.2-f47c97f865-6ff7c52541.zip/node_modules/core-js/modules/web.timers.js");

__webpack_require__(/*! regenerator-runtime/runtime */ "./.yarn/cache/regenerator-runtime-npm-0.13.8-0450f887d6-20178f5753.zip/node_modules/regenerator-runtime/runtime.js");

__webpack_require__(/*! ./html5shiv */ "./packages/tgui-polyfill/html5shiv.js");

__webpack_require__(/*! ./ie8 */ "./packages/tgui-polyfill/ie8.js");

__webpack_require__(/*! ./dom4 */ "./packages/tgui-polyfill/dom4.js");

__webpack_require__(/*! ./css-om */ "./packages/tgui-polyfill/css-om.js");

__webpack_require__(/*! ./inferno */ "./packages/tgui-polyfill/inferno.js");

// Fetch is required for Webpack HMR
if (false) {}

/***/ }),

/***/ "./packages/tgui-polyfill/inferno.js":
/*!*******************************************!*\
  !*** ./packages/tgui-polyfill/inferno.js ***!
  \*******************************************/
/***/ (function() {

"use strict";


/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
// Inferno needs Int32Array, and it is not covered by core-js.
if (!window.Int32Array) {
  window.Int32Array = Array;
}

/***/ }),

/***/ "./packages/tgui/components/AnimatedNumber.js":
/*!****************************************************!*\
  !*** ./packages/tgui/components/AnimatedNumber.js ***!
  \****************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.AnimatedNumber = void 0;

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var FPS = 20;
var Q = 0.5;

var isSafeNumber = function isSafeNumber(value) {
  return typeof value === 'number' && Number.isFinite(value) && !Number.isNaN(value);
};

var AnimatedNumber = /*#__PURE__*/function (_Component) {
  _inheritsLoose(AnimatedNumber, _Component);

  function AnimatedNumber(props) {
    var _this;

    _this = _Component.call(this, props) || this;
    _this.timer = null;
    _this.state = {
      value: 0
    }; // Use provided initial state

    if (isSafeNumber(props.initial)) {
      _this.state.value = props.initial;
    } // Set initial state with value provided in props
    else if (isSafeNumber(props.value)) {
        _this.state.value = Number(props.value);
      }

    return _this;
  }

  var _proto = AnimatedNumber.prototype;

  _proto.tick = function () {
    function tick() {
      var props = this.props,
          state = this.state;
      var currentValue = Number(state.value);
      var targetValue = Number(props.value); // Avoid poisoning our state with infinities and NaN

      if (!isSafeNumber(targetValue)) {
        return;
      } // Smooth the value using an exponential moving average


      var value = currentValue * Q + targetValue * (1 - Q);
      this.setState({
        value: value
      });
    }

    return tick;
  }();

  _proto.componentDidMount = function () {
    function componentDidMount() {
      var _this2 = this;

      this.timer = setInterval(function () {
        return _this2.tick();
      }, 1000 / FPS);
    }

    return componentDidMount;
  }();

  _proto.componentWillUnmount = function () {
    function componentWillUnmount() {
      clearTimeout(this.timer);
    }

    return componentWillUnmount;
  }();

  _proto.render = function () {
    function render() {
      var props = this.props,
          state = this.state;
      var format = props.format,
          children = props.children;
      var currentValue = state.value;
      var targetValue = props.value; // Directly display values which can't be animated

      if (!isSafeNumber(targetValue)) {
        return targetValue || null;
      }

      var formattedValue; // Use custom formatter

      if (format) {
        formattedValue = format(currentValue);
      } // Fix our animated precision at target value's precision.
      else {
          var fraction = String(targetValue).split('.')[1];
          var precision = fraction ? fraction.length : 0;
          formattedValue = (0, _math.toFixed)(currentValue, (0, _math.clamp)(precision, 0, 8));
        } // Use a custom render function


      if (typeof children === 'function') {
        return children(formattedValue, currentValue);
      }

      return formattedValue;
    }

    return render;
  }();

  return AnimatedNumber;
}(_inferno.Component);

exports.AnimatedNumber = AnimatedNumber;

/***/ }),

/***/ "./packages/tgui/components/Blink.js":
/*!*******************************************!*\
  !*** ./packages/tgui/components/Blink.js ***!
  \*******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Blink = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var DEFAULT_BLINKING_INTERVAL = 1000;
var DEFAULT_BLINKING_TIME = 1000;

var Blink = /*#__PURE__*/function (_Component) {
  _inheritsLoose(Blink, _Component);

  function Blink() {
    var _this;

    _this = _Component.call(this) || this;
    _this.state = {
      hidden: false
    };
    return _this;
  }

  var _proto = Blink.prototype;

  _proto.createTimer = function () {
    function createTimer() {
      var _this2 = this;

      var _this$props = this.props,
          _this$props$interval = _this$props.interval,
          interval = _this$props$interval === void 0 ? DEFAULT_BLINKING_INTERVAL : _this$props$interval,
          _this$props$time = _this$props.time,
          time = _this$props$time === void 0 ? DEFAULT_BLINKING_TIME : _this$props$time;
      clearInterval(this.interval);
      clearTimeout(this.timer);
      this.setState({
        hidden: false
      });
      this.interval = setInterval(function () {
        _this2.setState({
          hidden: true
        });

        _this2.timer = setTimeout(function () {
          _this2.setState({
            hidden: false
          });
        }, time);
      }, interval + time);
    }

    return createTimer;
  }();

  _proto.componentDidMount = function () {
    function componentDidMount() {
      this.createTimer();
    }

    return componentDidMount;
  }();

  _proto.componentDidUpdate = function () {
    function componentDidUpdate(prevProps) {
      if (prevProps.interval !== this.props.interval || prevProps.time !== this.props.time) {
        this.createTimer();
      }
    }

    return componentDidUpdate;
  }();

  _proto.componentWillUnmount = function () {
    function componentWillUnmount() {
      clearInterval(this.interval);
      clearTimeout(this.timer);
    }

    return componentWillUnmount;
  }();

  _proto.render = function () {
    function render(props) {
      return (0, _inferno.createVNode)(1, "span", null, props.children, 0, {
        "style": {
          visibility: this.state.hidden ? "hidden" : "visible"
        }
      });
    }

    return render;
  }();

  return Blink;
}(_inferno.Component);

exports.Blink = Blink;

/***/ }),

/***/ "./packages/tgui/components/BlockQuote.js":
/*!************************************************!*\
  !*** ./packages/tgui/components/BlockQuote.js ***!
  \************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.BlockQuote = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var BlockQuote = function BlockQuote(props) {
  var className = props.className,
      rest = _objectWithoutPropertiesLoose(props, ["className"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Box.Box, Object.assign({
    "className": (0, _react.classes)(['BlockQuote', className])
  }, rest)));
};

exports.BlockQuote = BlockQuote;

/***/ }),

/***/ "./packages/tgui/components/Box.tsx":
/*!******************************************!*\
  !*** ./packages/tgui/components/Box.tsx ***!
  \******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Box = exports.computeBoxClassName = exports.computeBoxProps = exports.halfUnit = exports.unit = void 0;

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _infernoVnodeFlags = __webpack_require__(/*! inferno-vnode-flags */ "./.yarn/cache/inferno-vnode-flags-npm-7.4.8-c2e3597db0-9dec51a6f6.zip/node_modules/inferno-vnode-flags/dist/index.esm.js");

var _constants = __webpack_require__(/*! ../constants */ "./packages/tgui/constants.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

/**
 * Coverts our rem-like spacing unit into a CSS unit.
 */
var unit = function unit(value) {
  if (typeof value === 'string') {
    // Transparently convert pixels into rem units
    if (value.endsWith('px') && !Byond.IS_LTE_IE8) {
      return parseFloat(value) / 12 + 'rem';
    }

    return value;
  }

  if (typeof value === 'number') {
    if (Byond.IS_LTE_IE8) {
      return value * 12 + 'px';
    }

    return value + 'rem';
  }
};
/**
 * Same as `unit`, but half the size for integers numbers.
 */


exports.unit = unit;

var halfUnit = function halfUnit(value) {
  if (typeof value === 'string') {
    return unit(value);
  }

  if (typeof value === 'number') {
    return unit(value * 0.5);
  }
};

exports.halfUnit = halfUnit;

var isColorCode = function isColorCode(str) {
  return !isColorClass(str);
};

var isColorClass = function isColorClass(str) {
  if (typeof str === 'string') {
    return _constants.CSS_COLORS.includes(str);
  }
};

var mapRawPropTo = function mapRawPropTo(attrName) {
  return function (style, value) {
    if (typeof value === 'number' || typeof value === 'string') {
      style[attrName] = value;
    }
  };
};

var mapUnitPropTo = function mapUnitPropTo(attrName, unit) {
  return function (style, value) {
    if (typeof value === 'number' || typeof value === 'string') {
      style[attrName] = unit(value);
    }
  };
};

var mapBooleanPropTo = function mapBooleanPropTo(attrName, attrValue) {
  return function (style, value) {
    if (value) {
      style[attrName] = attrValue;
    }
  };
};

var mapDirectionalUnitPropTo = function mapDirectionalUnitPropTo(attrName, unit, dirs) {
  return function (style, value) {
    if (typeof value === 'number' || typeof value === 'string') {
      for (var i = 0; i < dirs.length; i++) {
        style[attrName + '-' + dirs[i]] = unit(value);
      }
    }
  };
};

var mapColorPropTo = function mapColorPropTo(attrName) {
  return function (style, value) {
    if (isColorCode(value)) {
      style[attrName] = value;
    }
  };
};

var styleMapperByPropName = {
  // Direct mapping
  position: mapRawPropTo('position'),
  overflow: mapRawPropTo('overflow'),
  overflowX: mapRawPropTo('overflow-x'),
  overflowY: mapRawPropTo('overflow-y'),
  top: mapUnitPropTo('top', unit),
  bottom: mapUnitPropTo('bottom', unit),
  left: mapUnitPropTo('left', unit),
  right: mapUnitPropTo('right', unit),
  width: mapUnitPropTo('width', unit),
  minWidth: mapUnitPropTo('min-width', unit),
  maxWidth: mapUnitPropTo('max-width', unit),
  height: mapUnitPropTo('height', unit),
  minHeight: mapUnitPropTo('min-height', unit),
  maxHeight: mapUnitPropTo('max-height', unit),
  fontSize: mapUnitPropTo('font-size', unit),
  fontFamily: mapRawPropTo('font-family'),
  lineHeight: function () {
    function lineHeight(style, value) {
      if (typeof value === 'number') {
        style['line-height'] = value;
      } else if (typeof value === 'string') {
        style['line-height'] = unit(value);
      }
    }

    return lineHeight;
  }(),
  opacity: mapRawPropTo('opacity'),
  textAlign: mapRawPropTo('text-align'),
  verticalAlign: mapRawPropTo('vertical-align'),
  // Boolean props
  inline: mapBooleanPropTo('display', 'inline-block'),
  bold: mapBooleanPropTo('font-weight', 'bold'),
  italic: mapBooleanPropTo('font-style', 'italic'),
  nowrap: mapBooleanPropTo('white-space', 'nowrap'),
  preserveWhitespace: mapBooleanPropTo('white-space', 'pre-wrap'),
  // Margins
  m: mapDirectionalUnitPropTo('margin', halfUnit, ['top', 'bottom', 'left', 'right']),
  mx: mapDirectionalUnitPropTo('margin', halfUnit, ['left', 'right']),
  my: mapDirectionalUnitPropTo('margin', halfUnit, ['top', 'bottom']),
  mt: mapUnitPropTo('margin-top', halfUnit),
  mb: mapUnitPropTo('margin-bottom', halfUnit),
  ml: mapUnitPropTo('margin-left', halfUnit),
  mr: mapUnitPropTo('margin-right', halfUnit),
  // Margins
  p: mapDirectionalUnitPropTo('padding', halfUnit, ['top', 'bottom', 'left', 'right']),
  px: mapDirectionalUnitPropTo('padding', halfUnit, ['left', 'right']),
  py: mapDirectionalUnitPropTo('padding', halfUnit, ['top', 'bottom']),
  pt: mapUnitPropTo('padding-top', halfUnit),
  pb: mapUnitPropTo('padding-bottom', halfUnit),
  pl: mapUnitPropTo('padding-left', halfUnit),
  pr: mapUnitPropTo('padding-right', halfUnit),
  // Color props
  color: mapColorPropTo('color'),
  textColor: mapColorPropTo('color'),
  backgroundColor: mapColorPropTo('background-color'),
  // Utility props
  fillPositionedParent: function () {
    function fillPositionedParent(style, value) {
      if (value) {
        style['position'] = 'absolute';
        style['top'] = 0;
        style['bottom'] = 0;
        style['left'] = 0;
        style['right'] = 0;
      }
    }

    return fillPositionedParent;
  }()
};

var computeBoxProps = function computeBoxProps(props) {
  var computedProps = {};
  var computedStyles = {}; // Compute props

  for (var _i = 0, _Object$keys = Object.keys(props); _i < _Object$keys.length; _i++) {
    var propName = _Object$keys[_i];

    if (propName === 'style') {
      continue;
    } // IE8: onclick workaround


    if (Byond.IS_LTE_IE8 && propName === 'onClick') {
      computedProps.onclick = props[propName];
      continue;
    }

    var propValue = props[propName];
    var mapPropToStyle = styleMapperByPropName[propName];

    if (mapPropToStyle) {
      mapPropToStyle(computedStyles, propValue);
    } else {
      computedProps[propName] = propValue;
    }
  } // Concatenate styles


  var style = '';

  for (var _i2 = 0, _Object$keys2 = Object.keys(computedStyles); _i2 < _Object$keys2.length; _i2++) {
    var attrName = _Object$keys2[_i2];
    var attrValue = computedStyles[attrName];
    style += attrName + ':' + attrValue + ';';
  }

  if (props.style) {
    for (var _i3 = 0, _Object$keys3 = Object.keys(props.style); _i3 < _Object$keys3.length; _i3++) {
      var _attrName = _Object$keys3[_i3];
      var _attrValue = props.style[_attrName];
      style += _attrName + ':' + _attrValue + ';';
    }
  }

  if (style.length > 0) {
    computedProps.style = style;
  }

  return computedProps;
};

exports.computeBoxProps = computeBoxProps;

var computeBoxClassName = function computeBoxClassName(props) {
  var color = props.textColor || props.color;
  var backgroundColor = props.backgroundColor;
  return (0, _react.classes)([isColorClass(color) && 'color-' + color, isColorClass(backgroundColor) && 'color-bg-' + backgroundColor]);
};

exports.computeBoxClassName = computeBoxClassName;

var Box = function Box(props) {
  var _props$as = props.as,
      as = _props$as === void 0 ? 'div' : _props$as,
      className = props.className,
      children = props.children,
      rest = _objectWithoutPropertiesLoose(props, ["as", "className", "children"]); // Render props


  if (typeof children === 'function') {
    return children(computeBoxProps(props));
  }

  var computedClassName = typeof className === 'string' ? className + ' ' + computeBoxClassName(rest) : computeBoxClassName(rest);
  var computedProps = computeBoxProps(rest); // Render a wrapper element

  return (0, _inferno.createVNode)(_infernoVnodeFlags.VNodeFlags.HtmlElement, as, computedClassName, children, _infernoVnodeFlags.ChildFlags.UnknownChildren, computedProps);
};

exports.Box = Box;
Box.defaultHooks = _react.pureComponentHooks;

/***/ }),

/***/ "./packages/tgui/components/Button.js":
/*!********************************************!*\
  !*** ./packages/tgui/components/Button.js ***!
  \********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ButtonInput = exports.ButtonConfirm = exports.ButtonCheckbox = exports.Button = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _keycodes = __webpack_require__(/*! common/keycodes */ "./packages/common/keycodes.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _logging = __webpack_require__(/*! ../logging */ "./packages/tgui/logging.js");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

var _Icon = __webpack_require__(/*! ./Icon */ "./packages/tgui/components/Icon.js");

var _Tooltip = __webpack_require__(/*! ./Tooltip */ "./packages/tgui/components/Tooltip.tsx");

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var logger = (0, _logging.createLogger)('Button');

var Button = function Button(props) {
  var className = props.className,
      fluid = props.fluid,
      icon = props.icon,
      iconRotation = props.iconRotation,
      iconSpin = props.iconSpin,
      color = props.color,
      disabled = props.disabled,
      selected = props.selected,
      tooltip = props.tooltip,
      tooltipPosition = props.tooltipPosition,
      ellipsis = props.ellipsis,
      compact = props.compact,
      circular = props.circular,
      content = props.content,
      children = props.children,
      onclick = props.onclick,
      _onClick = props.onClick,
      rest = _objectWithoutPropertiesLoose(props, ["className", "fluid", "icon", "iconRotation", "iconSpin", "color", "disabled", "selected", "tooltip", "tooltipPosition", "ellipsis", "compact", "circular", "content", "children", "onclick", "onClick"]);

  var hasContent = !!(content || children); // A warning about the lowercase onclick

  if (onclick) {
    logger.warn("Lowercase 'onclick' is not supported on Button and lowercase" + " prop names are discouraged in general. Please use a camelCase" + "'onClick' instead and read: " + "https://infernojs.org/docs/guides/event-handling");
  } // IE8: Use a lowercase "onclick" because synthetic events are fucked.
  // IE8: Use an "unselectable" prop because "user-select" doesn't work.


  var buttonContent = (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "div", (0, _react.classes)(['Button', fluid && 'Button--fluid', disabled && 'Button--disabled', selected && 'Button--selected', hasContent && 'Button--hasContent', ellipsis && 'Button--ellipsis', circular && 'Button--circular', compact && 'Button--compact', color && typeof color === 'string' ? 'Button--color--' + color : 'Button--color--default', className, (0, _Box.computeBoxClassName)(rest)]), [icon && (0, _inferno.createComponentVNode)(2, _Icon.Icon, {
    "name": icon,
    "rotation": iconRotation,
    "spin": iconSpin
  }), content, children], 0, Object.assign({
    "tabIndex": !disabled && '0',
    "unselectable": Byond.IS_LTE_IE8,
    "onClick": function () {
      function onClick(e) {
        if (!disabled && _onClick) {
          _onClick(e);
        }
      }

      return onClick;
    }(),
    "onKeyDown": function () {
      function onKeyDown(e) {
        var keyCode = window.event ? e.which : e.keyCode; // Simulate a click when pressing space or enter.

        if (keyCode === _keycodes.KEY_SPACE || keyCode === _keycodes.KEY_ENTER) {
          e.preventDefault();

          if (!disabled && _onClick) {
            _onClick(e);
          }

          return;
        } // Refocus layout on pressing escape.


        if (keyCode === _keycodes.KEY_ESCAPE) {
          e.preventDefault();
          return;
        }
      }

      return onKeyDown;
    }()
  }, (0, _Box.computeBoxProps)(rest))));

  if (tooltip) {
    buttonContent = (0, _inferno.createComponentVNode)(2, _Tooltip.Tooltip, {
      "content": tooltip,
      "position": tooltipPosition,
      children: buttonContent
    });
  }

  return buttonContent;
};

exports.Button = Button;
Button.defaultHooks = _react.pureComponentHooks;

var ButtonCheckbox = function ButtonCheckbox(props) {
  var checked = props.checked,
      rest = _objectWithoutPropertiesLoose(props, ["checked"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, Button, Object.assign({
    "color": "transparent",
    "icon": checked ? 'check-square-o' : 'square-o',
    "selected": checked
  }, rest)));
};

exports.ButtonCheckbox = ButtonCheckbox;
Button.Checkbox = ButtonCheckbox;

var ButtonConfirm = /*#__PURE__*/function (_Component) {
  _inheritsLoose(ButtonConfirm, _Component);

  function ButtonConfirm() {
    var _this;

    _this = _Component.call(this) || this;
    _this.state = {
      clickedOnce: false
    };

    _this.handleClick = function () {
      if (_this.state.clickedOnce) {
        _this.setClickedOnce(false);
      }
    };

    return _this;
  }

  var _proto = ButtonConfirm.prototype;

  _proto.setClickedOnce = function () {
    function setClickedOnce(clickedOnce) {
      var _this2 = this;

      this.setState({
        clickedOnce: clickedOnce
      });

      if (clickedOnce) {
        setTimeout(function () {
          return window.addEventListener('click', _this2.handleClick);
        });
      } else {
        window.removeEventListener('click', this.handleClick);
      }
    }

    return setClickedOnce;
  }();

  _proto.render = function () {
    function render() {
      var _this3 = this;

      var _this$props = this.props,
          _this$props$confirmCo = _this$props.confirmContent,
          confirmContent = _this$props$confirmCo === void 0 ? "Confirm?" : _this$props$confirmCo,
          _this$props$confirmCo2 = _this$props.confirmColor,
          confirmColor = _this$props$confirmCo2 === void 0 ? "bad" : _this$props$confirmCo2,
          confirmIcon = _this$props.confirmIcon,
          icon = _this$props.icon,
          color = _this$props.color,
          content = _this$props.content,
          _onClick2 = _this$props.onClick,
          rest = _objectWithoutPropertiesLoose(_this$props, ["confirmContent", "confirmColor", "confirmIcon", "icon", "color", "content", "onClick"]);

      return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, Button, Object.assign({
        "content": this.state.clickedOnce ? confirmContent : content,
        "icon": this.state.clickedOnce ? confirmIcon : icon,
        "color": this.state.clickedOnce ? confirmColor : color,
        "onClick": function () {
          function onClick() {
            return _this3.state.clickedOnce ? _onClick2() : _this3.setClickedOnce(true);
          }

          return onClick;
        }()
      }, rest)));
    }

    return render;
  }();

  return ButtonConfirm;
}(_inferno.Component);

exports.ButtonConfirm = ButtonConfirm;
Button.Confirm = ButtonConfirm;

var ButtonInput = /*#__PURE__*/function (_Component2) {
  _inheritsLoose(ButtonInput, _Component2);

  function ButtonInput() {
    var _this4;

    _this4 = _Component2.call(this) || this;
    _this4.inputRef = (0, _inferno.createRef)();
    _this4.state = {
      inInput: false
    };
    return _this4;
  }

  var _proto2 = ButtonInput.prototype;

  _proto2.setInInput = function () {
    function setInInput(inInput) {
      this.setState({
        inInput: inInput
      });

      if (this.inputRef) {
        var input = this.inputRef.current;

        if (inInput) {
          input.value = this.props.currentValue || "";

          try {
            input.focus();
            input.select();
          } catch (_unused) {}
        }
      }
    }

    return setInInput;
  }();

  _proto2.commitResult = function () {
    function commitResult(e) {
      if (this.inputRef) {
        var input = this.inputRef.current;
        var hasValue = input.value !== "";

        if (hasValue) {
          this.props.onCommit(e, input.value);
          return;
        } else {
          if (!this.props.defaultValue) {
            return;
          }

          this.props.onCommit(e, this.props.defaultValue);
        }
      }
    }

    return commitResult;
  }();

  _proto2.render = function () {
    function render() {
      var _this5 = this;

      var _this$props2 = this.props,
          fluid = _this$props2.fluid,
          content = _this$props2.content,
          icon = _this$props2.icon,
          iconRotation = _this$props2.iconRotation,
          iconSpin = _this$props2.iconSpin,
          tooltip = _this$props2.tooltip,
          tooltipPosition = _this$props2.tooltipPosition,
          _this$props2$color = _this$props2.color,
          color = _this$props2$color === void 0 ? 'default' : _this$props2$color,
          placeholder = _this$props2.placeholder,
          maxLength = _this$props2.maxLength,
          rest = _objectWithoutPropertiesLoose(_this$props2, ["fluid", "content", "icon", "iconRotation", "iconSpin", "tooltip", "tooltipPosition", "color", "placeholder", "maxLength"]);

      var buttonContent = (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Box.Box, Object.assign({
        "className": (0, _react.classes)(['Button', fluid && 'Button--fluid', 'Button--color--' + color])
      }, rest, {
        "onClick": function () {
          function onClick() {
            return _this5.setInInput(true);
          }

          return onClick;
        }(),
        children: [icon && (0, _inferno.createComponentVNode)(2, _Icon.Icon, {
          "name": icon,
          "rotation": iconRotation,
          "spin": iconSpin
        }), (0, _inferno.createVNode)(1, "div", null, content, 0), (0, _inferno.createVNode)(64, "input", "NumberInput__input", null, 1, {
          "style": {
            'display': !this.state.inInput ? 'none' : undefined,
            'text-align': 'left'
          },
          "onBlur": function () {
            function onBlur(e) {
              if (!_this5.state.inInput) {
                return;
              }

              _this5.setInInput(false);

              _this5.commitResult(e);
            }

            return onBlur;
          }(),
          "onKeyDown": function () {
            function onKeyDown(e) {
              if (e.keyCode === _keycodes.KEY_ENTER) {
                _this5.setInInput(false);

                _this5.commitResult(e);

                return;
              }

              if (e.keyCode === _keycodes.KEY_ESCAPE) {
                _this5.setInInput(false);
              }
            }

            return onKeyDown;
          }()
        }, null, this.inputRef)]
      })));

      if (tooltip) {
        buttonContent = (0, _inferno.createComponentVNode)(2, _Tooltip.Tooltip, {
          "content": tooltip,
          "position": tooltipPosition,
          children: buttonContent
        });
      }

      return buttonContent;
    }

    return render;
  }();

  return ButtonInput;
}(_inferno.Component);

exports.ButtonInput = ButtonInput;
Button.Input = ButtonInput;

/***/ }),

/***/ "./packages/tgui/components/ByondUi.js":
/*!*********************************************!*\
  !*** ./packages/tgui/components/ByondUi.js ***!
  \*********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ByondUi = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _timer = __webpack_require__(/*! common/timer */ "./packages/common/timer.js");

var _logging = __webpack_require__(/*! ../logging */ "./packages/tgui/logging.js");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var logger = (0, _logging.createLogger)('ByondUi'); // Stack of currently allocated BYOND UI element ids.

var byondUiStack = [];

var createByondUiElement = function createByondUiElement(elementId) {
  // Reserve an index in the stack
  var index = byondUiStack.length;
  byondUiStack.push(null); // Get a unique id

  var id = elementId || 'byondui_' + index;
  logger.log("allocated '" + id + "'"); // Return a control structure

  return {
    render: function () {
      function render(params) {
        logger.log("rendering '" + id + "'");
        byondUiStack[index] = id;
        Byond.winset(id, params);
      }

      return render;
    }(),
    unmount: function () {
      function unmount() {
        logger.log("unmounting '" + id + "'");
        byondUiStack[index] = null;
        Byond.winset(id, {
          parent: ''
        });
      }

      return unmount;
    }()
  };
};

window.addEventListener('beforeunload', function () {
  // Cleanly unmount all visible UI elements
  for (var index = 0; index < byondUiStack.length; index++) {
    var id = byondUiStack[index];

    if (typeof id === 'string') {
      logger.log("unmounting '" + id + "' (beforeunload)");
      byondUiStack[index] = null;
      Byond.winset(id, {
        parent: ''
      });
    }
  }
});
/**
 * Get the bounding box of the DOM element.
 */

var getBoundingBox = function getBoundingBox(element) {
  var rect = element.getBoundingClientRect();
  return {
    pos: [rect.left, rect.top],
    size: [rect.right - rect.left, rect.bottom - rect.top]
  };
};

var ByondUi = /*#__PURE__*/function (_Component) {
  _inheritsLoose(ByondUi, _Component);

  function ByondUi(props) {
    var _props$params;

    var _this;

    _this = _Component.call(this, props) || this;
    _this.containerRef = (0, _inferno.createRef)();
    _this.byondUiElement = createByondUiElement((_props$params = props.params) == null ? void 0 : _props$params.id);
    _this.handleResize = (0, _timer.debounce)(function () {
      _this.forceUpdate();
    }, 100);
    var lock = false;

    _this.handleScroll = function () {
      if (!lock) {
        window.requestAnimationFrame(function () {
          _this.componentDidUpdate();

          lock = false;
        });
        lock = true;
      }
    };

    return _this;
  }

  var _proto = ByondUi.prototype;

  _proto.shouldComponentUpdate = function () {
    function shouldComponentUpdate(nextProps) {
      var _this$props = this.props,
          _this$props$params = _this$props.params,
          prevParams = _this$props$params === void 0 ? {} : _this$props$params,
          prevRest = _objectWithoutPropertiesLoose(_this$props, ["params"]);

      var _nextProps$params = nextProps.params,
          nextParams = _nextProps$params === void 0 ? {} : _nextProps$params,
          nextRest = _objectWithoutPropertiesLoose(nextProps, ["params"]);

      return (0, _react.shallowDiffers)(prevParams, nextParams) || (0, _react.shallowDiffers)(prevRest, nextRest);
    }

    return shouldComponentUpdate;
  }();

  _proto.componentDidMount = function () {
    function componentDidMount() {
      // IE8: It probably works, but fuck you anyway.
      if (Byond.IS_LTE_IE10) {
        return;
      }

      window.addEventListener('resize', this.handleResize);
      window.addEventListener('scroll', this.handleScroll, true);
      this.componentDidUpdate();
      this.handleResize();
    }

    return componentDidMount;
  }();

  _proto.componentDidUpdate = function () {
    function componentDidUpdate() {
      // IE8: It probably works, but fuck you anyway.
      if (Byond.IS_LTE_IE10) {
        return;
      }

      var _this$props2 = this.props,
          _this$props2$params = _this$props2.params,
          params = _this$props2$params === void 0 ? {} : _this$props2$params,
          hideOnScroll = _this$props2.hideOnScroll;

      if (this.containerRef.current) {
        var box = getBoundingBox(this.containerRef.current);
        logger.debug('bounding box', box);

        if (hideOnScroll && box.pos[1] < 32) {
          this.byondUiElement.unmount();
          return;
        }

        this.byondUiElement.render(Object.assign({
          parent: window.__windowId__
        }, params, {
          pos: box.pos[0] + ',' + box.pos[1],
          size: box.size[0] + 'x' + box.size[1]
        }));
      }
    }

    return componentDidUpdate;
  }();

  _proto.componentWillUnmount = function () {
    function componentWillUnmount() {
      // IE8: It probably works, but fuck you anyway.
      if (Byond.IS_LTE_IE10) {
        return;
      }

      window.removeEventListener('resize', this.handleResize);
      window.removeEventListener('scroll', this.handleScroll, true);
      this.byondUiElement.unmount();
    }

    return componentWillUnmount;
  }();

  _proto.render = function () {
    function render() {
      var _this$props3 = this.props,
          params = _this$props3.params,
          rest = _objectWithoutPropertiesLoose(_this$props3, ["params"]);

      return (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "div", null, (0, _inferno.createVNode)(1, "div", null, null, 1, {
        "style": {
          'min-height': '22px'
        }
      }), 0, Object.assign({}, (0, _Box.computeBoxProps)(rest)), null, this.containerRef));
    }

    return render;
  }();

  return ByondUi;
}(_inferno.Component);

exports.ByondUi = ByondUi;

/***/ }),

/***/ "./packages/tgui/components/Chart.js":
/*!*******************************************!*\
  !*** ./packages/tgui/components/Chart.js ***!
  \*******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Chart = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _collections = __webpack_require__(/*! common/collections */ "./packages/common/collections.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var normalizeData = function normalizeData(data, scale, rangeX, rangeY) {
  if (data.length === 0) {
    return [];
  }

  var min = (0, _collections.zipWith)(Math.min).apply(void 0, data);
  var max = (0, _collections.zipWith)(Math.max).apply(void 0, data);

  if (rangeX !== undefined) {
    min[0] = rangeX[0];
    max[0] = rangeX[1];
  }

  if (rangeY !== undefined) {
    min[1] = rangeY[0];
    max[1] = rangeY[1];
  }

  return (0, _collections.map)(function (point) {
    return (0, _collections.zipWith)(function (value, min, max, scale) {
      return (value - min) / (max - min) * scale;
    })(point, min, max, scale);
  })(data);
};

var dataToPolylinePoints = function dataToPolylinePoints(data) {
  var points = '';

  for (var i = 0; i < data.length; i++) {
    var point = data[i];
    points += point[0] + ',' + point[1] + ' ';
  }

  return points;
};

var LineChart = /*#__PURE__*/function (_Component) {
  _inheritsLoose(LineChart, _Component);

  function LineChart(props) {
    var _this;

    _this = _Component.call(this, props) || this;
    _this.ref = (0, _inferno.createRef)();
    _this.state = {
      // Initial guess
      viewBox: [600, 200]
    };

    _this.handleResize = function () {
      var element = _this.ref.current;

      _this.setState({
        viewBox: [element.offsetWidth, element.offsetHeight]
      });
    };

    return _this;
  }

  var _proto = LineChart.prototype;

  _proto.componentDidMount = function () {
    function componentDidMount() {
      window.addEventListener('resize', this.handleResize);
      this.handleResize();
    }

    return componentDidMount;
  }();

  _proto.componentWillUnmount = function () {
    function componentWillUnmount() {
      window.removeEventListener('resize', this.handleResize);
    }

    return componentWillUnmount;
  }();

  _proto.render = function () {
    function render() {
      var _this2 = this;

      var _this$props = this.props,
          _this$props$data = _this$props.data,
          data = _this$props$data === void 0 ? [] : _this$props$data,
          rangeX = _this$props.rangeX,
          rangeY = _this$props.rangeY,
          _this$props$fillColor = _this$props.fillColor,
          fillColor = _this$props$fillColor === void 0 ? 'none' : _this$props$fillColor,
          _this$props$strokeCol = _this$props.strokeColor,
          strokeColor = _this$props$strokeCol === void 0 ? '#ffffff' : _this$props$strokeCol,
          _this$props$strokeWid = _this$props.strokeWidth,
          strokeWidth = _this$props$strokeWid === void 0 ? 2 : _this$props$strokeWid,
          rest = _objectWithoutPropertiesLoose(_this$props, ["data", "rangeX", "rangeY", "fillColor", "strokeColor", "strokeWidth"]);

      var viewBox = this.state.viewBox;
      var normalized = normalizeData(data, viewBox, rangeX, rangeY); // Push data outside viewBox and form a fillable polygon

      if (normalized.length > 0) {
        var first = normalized[0];
        var last = normalized[normalized.length - 1];
        normalized.push([viewBox[0] + strokeWidth, last[1]]);
        normalized.push([viewBox[0] + strokeWidth, -strokeWidth]);
        normalized.push([-strokeWidth, -strokeWidth]);
        normalized.push([-strokeWidth, first[1]]);
      }

      var points = dataToPolylinePoints(normalized);
      return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Box.Box, Object.assign({
        "position": "relative"
      }, rest, {
        children: function () {
          function children(props) {
            return (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "div", null, (0, _inferno.createVNode)(32, "svg", null, (0, _inferno.createVNode)(32, "polyline", null, null, 1, {
              "transform": "scale(1, -1) translate(0, -" + viewBox[1] + ")",
              "fill": fillColor,
              "stroke": strokeColor,
              "stroke-width": strokeWidth,
              "points": points
            }), 2, {
              "viewBox": "0 0 " + viewBox[0] + " " + viewBox[1],
              "preserveAspectRatio": "none",
              "style": {
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                overflow: 'hidden'
              }
            }), 2, Object.assign({}, props), null, _this2.ref));
          }

          return children;
        }()
      })));
    }

    return render;
  }();

  return LineChart;
}(_inferno.Component);

LineChart.defaultHooks = _react.pureComponentHooks;

var Stub = function Stub(props) {
  return null;
}; // IE8: No inline svg support


var Chart = {
  Line: Byond.IS_LTE_IE8 ? Stub : LineChart
};
exports.Chart = Chart;

/***/ }),

/***/ "./packages/tgui/components/Collapsible.js":
/*!*************************************************!*\
  !*** ./packages/tgui/components/Collapsible.js ***!
  \*************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Collapsible = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

var _Button = __webpack_require__(/*! ./Button */ "./packages/tgui/components/Button.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var Collapsible = /*#__PURE__*/function (_Component) {
  _inheritsLoose(Collapsible, _Component);

  function Collapsible(props) {
    var _this;

    _this = _Component.call(this, props) || this;
    var open = props.open;
    _this.state = {
      open: open || false
    };
    return _this;
  }

  var _proto = Collapsible.prototype;

  _proto.render = function () {
    function render() {
      var _this2 = this;

      var props = this.props;
      var open = this.state.open;

      var children = props.children,
          _props$color = props.color,
          color = _props$color === void 0 ? 'default' : _props$color,
          title = props.title,
          buttons = props.buttons,
          rest = _objectWithoutPropertiesLoose(props, ["children", "color", "title", "buttons"]);

      return (0, _inferno.createComponentVNode)(2, _Box.Box, {
        "mb": 1,
        children: [(0, _inferno.createVNode)(1, "div", "Table", [(0, _inferno.createVNode)(1, "div", "Table__cell", (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Button.Button, Object.assign({
          "fluid": true,
          "color": color,
          "icon": open ? 'chevron-down' : 'chevron-right',
          "onClick": function () {
            function onClick() {
              return _this2.setState({
                open: !open
              });
            }

            return onClick;
          }()
        }, rest, {
          children: title
        }))), 2), buttons && (0, _inferno.createVNode)(1, "div", "Table__cell Table__cell--collapsing", buttons, 0)], 0), open && (0, _inferno.createComponentVNode)(2, _Box.Box, {
          "mt": 1,
          children: children
        })]
      });
    }

    return render;
  }();

  return Collapsible;
}(_inferno.Component);

exports.Collapsible = Collapsible;

/***/ }),

/***/ "./packages/tgui/components/ColorBox.js":
/*!**********************************************!*\
  !*** ./packages/tgui/components/ColorBox.js ***!
  \**********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ColorBox = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var ColorBox = function ColorBox(props) {
  var content = props.content,
      children = props.children,
      className = props.className,
      color = props.color,
      backgroundColor = props.backgroundColor,
      rest = _objectWithoutPropertiesLoose(props, ["content", "children", "className", "color", "backgroundColor"]);

  rest.color = content ? null : 'transparent';
  rest.backgroundColor = color || backgroundColor;
  return (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "div", (0, _react.classes)(['ColorBox', className, (0, _Box.computeBoxClassName)(rest)]), content || '.', 0, Object.assign({}, (0, _Box.computeBoxProps)(rest))));
};

exports.ColorBox = ColorBox;
ColorBox.defaultHooks = _react.pureComponentHooks;

/***/ }),

/***/ "./packages/tgui/components/Dimmer.js":
/*!********************************************!*\
  !*** ./packages/tgui/components/Dimmer.js ***!
  \********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Dimmer = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var Dimmer = function Dimmer(props) {
  var className = props.className,
      children = props.children,
      full = props.full,
      rest = _objectWithoutPropertiesLoose(props, ["className", "children", "full"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Box.Box, Object.assign({
    "className": (0, _react.classes)(['Dimmer', !!full && 'Dimmer--full'].concat(className))
  }, rest, {
    children: (0, _inferno.createVNode)(1, "div", "Dimmer__inner", children, 0)
  })));
};

exports.Dimmer = Dimmer;

/***/ }),

/***/ "./packages/tgui/components/Divider.js":
/*!*********************************************!*\
  !*** ./packages/tgui/components/Divider.js ***!
  \*********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Divider = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var Divider = function Divider(props) {
  var vertical = props.vertical,
      hidden = props.hidden;
  return (0, _inferno.createVNode)(1, "div", (0, _react.classes)(['Divider', hidden && 'Divider--hidden', vertical ? 'Divider--vertical' : 'Divider--horizontal']));
};

exports.Divider = Divider;

/***/ }),

/***/ "./packages/tgui/components/DraggableControl.js":
/*!******************************************************!*\
  !*** ./packages/tgui/components/DraggableControl.js ***!
  \******************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.DraggableControl = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _AnimatedNumber = __webpack_require__(/*! ./AnimatedNumber */ "./packages/tgui/components/AnimatedNumber.js");

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var DEFAULT_UPDATE_RATE = 400;
/**
 * Reduces screen offset to a single number based on the matrix provided.
 */

var getScalarScreenOffset = function getScalarScreenOffset(e, matrix) {
  return e.screenX * matrix[0] + e.screenY * matrix[1];
};

var DraggableControl = /*#__PURE__*/function (_Component) {
  _inheritsLoose(DraggableControl, _Component);

  function DraggableControl(props) {
    var _this;

    _this = _Component.call(this, props) || this;
    _this.inputRef = (0, _inferno.createRef)();
    _this.state = {
      value: props.value,
      dragging: false,
      editing: false,
      internalValue: null,
      origin: null,
      suppressingFlicker: false
    }; // Suppresses flickering while the value propagates through the backend

    _this.flickerTimer = null;

    _this.suppressFlicker = function () {
      var suppressFlicker = _this.props.suppressFlicker;

      if (suppressFlicker > 0) {
        _this.setState({
          suppressingFlicker: true
        });

        clearTimeout(_this.flickerTimer);
        _this.flickerTimer = setTimeout(function () {
          return _this.setState({
            suppressingFlicker: false
          });
        }, suppressFlicker);
      }
    };

    _this.handleDragStart = function (e) {
      var _this$props = _this.props,
          value = _this$props.value,
          dragMatrix = _this$props.dragMatrix;
      var editing = _this.state.editing;

      if (editing) {
        return;
      }

      document.body.style['pointer-events'] = 'none';
      _this.ref = e.target;

      _this.setState({
        dragging: false,
        origin: getScalarScreenOffset(e, dragMatrix),
        value: value,
        internalValue: value
      });

      _this.timer = setTimeout(function () {
        _this.setState({
          dragging: true
        });
      }, 250);
      _this.dragInterval = setInterval(function () {
        var _this$state = _this.state,
            dragging = _this$state.dragging,
            value = _this$state.value;
        var onDrag = _this.props.onDrag;

        if (dragging && onDrag) {
          onDrag(e, value);
        }
      }, _this.props.updateRate || DEFAULT_UPDATE_RATE);
      document.addEventListener('mousemove', _this.handleDragMove);
      document.addEventListener('mouseup', _this.handleDragEnd);
    };

    _this.handleDragMove = function (e) {
      var _this$props2 = _this.props,
          minValue = _this$props2.minValue,
          maxValue = _this$props2.maxValue,
          step = _this$props2.step,
          stepPixelSize = _this$props2.stepPixelSize,
          dragMatrix = _this$props2.dragMatrix;

      _this.setState(function (prevState) {
        var state = Object.assign({}, prevState);
        var offset = getScalarScreenOffset(e, dragMatrix) - state.origin;

        if (prevState.dragging) {
          var stepOffset = Number.isFinite(minValue) ? minValue % step : 0; // Translate mouse movement to value
          // Give it some headroom (by increasing clamp range by 1 step)

          state.internalValue = (0, _math.clamp)(state.internalValue + offset * step / stepPixelSize, minValue - step, maxValue + step); // Clamp the final value

          state.value = (0, _math.clamp)(state.internalValue - state.internalValue % step + stepOffset, minValue, maxValue);
          state.origin = getScalarScreenOffset(e, dragMatrix);
        } else if (Math.abs(offset) > 4) {
          state.dragging = true;
        }

        return state;
      });
    };

    _this.handleDragEnd = function (e) {
      var _this$props3 = _this.props,
          onChange = _this$props3.onChange,
          onDrag = _this$props3.onDrag;
      var _this$state2 = _this.state,
          dragging = _this$state2.dragging,
          value = _this$state2.value,
          internalValue = _this$state2.internalValue;
      document.body.style['pointer-events'] = 'auto';
      clearTimeout(_this.timer);
      clearInterval(_this.dragInterval);

      _this.setState({
        dragging: false,
        editing: !dragging,
        origin: null
      });

      document.removeEventListener('mousemove', _this.handleDragMove);
      document.removeEventListener('mouseup', _this.handleDragEnd);

      if (dragging) {
        _this.suppressFlicker();

        if (onChange) {
          onChange(e, value);
        }

        if (onDrag) {
          onDrag(e, value);
        }
      } else if (_this.inputRef) {
        var input = _this.inputRef.current;
        input.value = internalValue; // IE8: Dies when trying to focus a hidden element
        // (Error: Object does not support this action)

        try {
          input.focus();
          input.select();
        } catch (_unused) {}
      }
    };

    return _this;
  }

  var _proto = DraggableControl.prototype;

  _proto.render = function () {
    function render() {
      var _this2 = this;

      var _this$state3 = this.state,
          dragging = _this$state3.dragging,
          editing = _this$state3.editing,
          intermediateValue = _this$state3.value,
          suppressingFlicker = _this$state3.suppressingFlicker;
      var _this$props4 = this.props,
          animated = _this$props4.animated,
          value = _this$props4.value,
          unit = _this$props4.unit,
          minValue = _this$props4.minValue,
          maxValue = _this$props4.maxValue,
          unclamped = _this$props4.unclamped,
          format = _this$props4.format,
          onChange = _this$props4.onChange,
          onDrag = _this$props4.onDrag,
          children = _this$props4.children,
          height = _this$props4.height,
          lineHeight = _this$props4.lineHeight,
          fontSize = _this$props4.fontSize;
      var displayValue = value;

      if (dragging || suppressingFlicker) {
        displayValue = intermediateValue;
      } // Setup a display element
      // Shows a formatted number based on what we are currently doing
      // with the draggable surface.


      var renderDisplayElement = function () {
        function renderDisplayElement(value) {
          return value + (unit ? ' ' + unit : '');
        }

        return renderDisplayElement;
      }();

      var displayElement = animated && !dragging && !suppressingFlicker && (0, _inferno.createComponentVNode)(2, _AnimatedNumber.AnimatedNumber, {
        "value": displayValue,
        "format": format,
        children: renderDisplayElement
      }) || renderDisplayElement(format ? format(displayValue) : displayValue); // Setup an input element
      // Handles direct input via the keyboard

      var inputElement = (0, _inferno.createVNode)(64, "input", "NumberInput__input", null, 1, {
        "style": {
          display: !editing ? 'none' : undefined,
          height: height,
          'line-height': lineHeight,
          'font-size': fontSize
        },
        "onBlur": function () {
          function onBlur(e) {
            if (!editing) {
              return;
            }

            var value;

            if (unclamped) {
              value = e.target.value;
            } else {
              value = (0, _math.clamp)(parseFloat(e.target.value), minValue, maxValue);

              if (Number.isNaN(value)) {
                _this2.setState({
                  editing: false
                });

                return;
              }
            }

            _this2.setState({
              editing: false,
              value: value
            });

            _this2.suppressFlicker();

            if (onChange) {
              onChange(e, value);
            }

            if (onDrag) {
              onDrag(e, value);
            }
          }

          return onBlur;
        }(),
        "onKeyDown": function () {
          function onKeyDown(e) {
            if (e.keyCode === 13) {
              var _value;

              if (unclamped) {
                _value = e.target.value;
              } else {
                _value = (0, _math.clamp)(parseFloat(e.target.value), minValue, maxValue);

                if (Number.isNaN(_value)) {
                  _this2.setState({
                    editing: false
                  });

                  return;
                }
              }

              _this2.setState({
                editing: false,
                value: _value
              });

              _this2.suppressFlicker();

              if (onChange) {
                onChange(e, _value);
              }

              if (onDrag) {
                onDrag(e, _value);
              }

              return;
            }

            if (e.keyCode === 27) {
              _this2.setState({
                editing: false
              });

              return;
            }
          }

          return onKeyDown;
        }()
      }, null, this.inputRef); // Return a part of the state for higher-level components to use.

      return children({
        dragging: dragging,
        editing: editing,
        value: value,
        displayValue: displayValue,
        displayElement: displayElement,
        inputElement: inputElement,
        handleDragStart: this.handleDragStart
      });
    }

    return render;
  }();

  return DraggableControl;
}(_inferno.Component);

exports.DraggableControl = DraggableControl;
DraggableControl.defaultHooks = _react.pureComponentHooks;
DraggableControl.defaultProps = {
  minValue: -Infinity,
  maxValue: +Infinity,
  step: 1,
  stepPixelSize: 1,
  suppressFlicker: 50,
  dragMatrix: [1, 0]
};

/***/ }),

/***/ "./packages/tgui/components/Dropdown.js":
/*!**********************************************!*\
  !*** ./packages/tgui/components/Dropdown.js ***!
  \**********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Dropdown = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

var _Icon = __webpack_require__(/*! ./Icon */ "./packages/tgui/components/Icon.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var Dropdown = /*#__PURE__*/function (_Component) {
  _inheritsLoose(Dropdown, _Component);

  function Dropdown(props) {
    var _this;

    _this = _Component.call(this, props) || this;
    _this.state = {
      selected: props.selected,
      open: false
    };

    _this.handleClick = function () {
      if (_this.state.open) {
        _this.setOpen(false);
      }
    };

    return _this;
  }

  var _proto = Dropdown.prototype;

  _proto.componentWillUnmount = function () {
    function componentWillUnmount() {
      window.removeEventListener('click', this.handleClick);
    }

    return componentWillUnmount;
  }();

  _proto.setOpen = function () {
    function setOpen(open) {
      var _this2 = this;

      this.setState({
        open: open
      });

      if (open) {
        setTimeout(function () {
          return window.addEventListener('click', _this2.handleClick);
        });
        this.menuRef.focus();
      } else {
        window.removeEventListener('click', this.handleClick);
      }
    }

    return setOpen;
  }();

  _proto.setSelected = function () {
    function setSelected(selected) {
      this.setState({
        selected: selected
      });
      this.setOpen(false);
      this.props.onSelected(selected);
    }

    return setSelected;
  }();

  _proto.buildMenu = function () {
    function buildMenu() {
      var _this3 = this;

      var _this$props$options = this.props.options,
          options = _this$props$options === void 0 ? [] : _this$props$options;
      var ops = options.map(function (option) {
        return (0, _inferno.createComponentVNode)(2, _Box.Box, {
          "className": "Dropdown__menuentry",
          "onClick": function () {
            function onClick() {
              _this3.setSelected(option);
            }

            return onClick;
          }(),
          children: option
        }, option);
      });
      return ops.length ? ops : 'No Options Found';
    }

    return buildMenu;
  }();

  _proto.render = function () {
    function render() {
      var _this4 = this;

      var props = this.props;

      var icon = props.icon,
          iconRotation = props.iconRotation,
          iconSpin = props.iconSpin,
          _props$color = props.color,
          color = _props$color === void 0 ? 'default' : _props$color,
          over = props.over,
          noscroll = props.noscroll,
          nochevron = props.nochevron,
          width = props.width,
          onClick = props.onClick,
          selected = props.selected,
          disabled = props.disabled,
          displayText = props.displayText,
          boxProps = _objectWithoutPropertiesLoose(props, ["icon", "iconRotation", "iconSpin", "color", "over", "noscroll", "nochevron", "width", "onClick", "selected", "disabled", "displayText"]);

      var className = boxProps.className,
          rest = _objectWithoutPropertiesLoose(boxProps, ["className"]);

      var adjustedOpen = over ? !this.state.open : this.state.open;
      var menu = this.state.open ? (0, _inferno.createVNode)(1, "div", (0, _react.classes)([noscroll && 'Dropdown__menu-noscroll' || 'Dropdown__menu', over && 'Dropdown__over']), this.buildMenu(), 0, {
        "tabIndex": "-1",
        "style": {
          'width': width
        }
      }, null, function (menu) {
        _this4.menuRef = menu;
      }) : null;
      return (0, _inferno.createVNode)(1, "div", "Dropdown", [(0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Box.Box, Object.assign({
        "width": width,
        "className": (0, _react.classes)(['Dropdown__control', 'Button', 'Button--color--' + color, disabled && 'Button--disabled', className])
      }, rest, {
        "onClick": function () {
          function onClick() {
            if (disabled && !_this4.state.open) {
              return;
            }

            _this4.setOpen(!_this4.state.open);
          }

          return onClick;
        }(),
        children: [icon && (0, _inferno.createComponentVNode)(2, _Icon.Icon, {
          "name": icon,
          "rotation": iconRotation,
          "spin": iconSpin,
          "mr": 1
        }), (0, _inferno.createVNode)(1, "span", "Dropdown__selected-text", displayText ? displayText : this.state.selected, 0), !!nochevron || (0, _inferno.createVNode)(1, "span", "Dropdown__arrow-button", (0, _inferno.createComponentVNode)(2, _Icon.Icon, {
          "name": adjustedOpen ? 'chevron-up' : 'chevron-down'
        }), 2)]
      }))), menu], 0);
    }

    return render;
  }();

  return Dropdown;
}(_inferno.Component);

exports.Dropdown = Dropdown;

/***/ }),

/***/ "./packages/tgui/components/Flex.tsx":
/*!*******************************************!*\
  !*** ./packages/tgui/components/Flex.tsx ***!
  \*******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.computeFlexItemProps = exports.computeFlexItemClassName = exports.Flex = exports.computeFlexProps = exports.computeFlexClassName = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var computeFlexClassName = function computeFlexClassName(props) {
  return (0, _react.classes)(['Flex', Byond.IS_LTE_IE10 && (props.direction === 'column' ? 'Flex--iefix--column' : 'Flex--iefix'), props.inline && 'Flex--inline']);
};

exports.computeFlexClassName = computeFlexClassName;

var computeFlexProps = function computeFlexProps(props) {
  var className = props.className,
      direction = props.direction,
      wrap = props.wrap,
      align = props.align,
      justify = props.justify,
      inline = props.inline,
      rest = _objectWithoutPropertiesLoose(props, ["className", "direction", "wrap", "align", "justify", "inline"]);

  return Object.assign({
    style: Object.assign({}, rest.style, {
      'flex-direction': direction,
      'flex-wrap': wrap === true ? 'wrap' : wrap,
      'align-items': align,
      'justify-content': justify
    })
  }, rest);
};

exports.computeFlexProps = computeFlexProps;

var Flex = function Flex(props) {
  var className = props.className,
      rest = _objectWithoutPropertiesLoose(props, ["className"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "div", (0, _react.classes)([className, computeFlexClassName(rest), (0, _Box.computeBoxClassName)(rest)]), null, 1, Object.assign({}, (0, _Box.computeBoxProps)(computeFlexProps(rest)))));
};

exports.Flex = Flex;
Flex.defaultHooks = _react.pureComponentHooks;

var computeFlexItemClassName = function computeFlexItemClassName(props) {
  return (0, _react.classes)(['Flex__item', Byond.IS_LTE_IE10 && 'Flex__item--iefix', Byond.IS_LTE_IE10 && props.grow && props.grow > 0 && 'Flex__item--iefix--grow']);
};

exports.computeFlexItemClassName = computeFlexItemClassName;

var computeFlexItemProps = function computeFlexItemProps(props) {
  var className = props.className,
      style = props.style,
      grow = props.grow,
      order = props.order,
      shrink = props.shrink,
      _props$basis = props.basis,
      basis = _props$basis === void 0 ? props.width : _props$basis,
      align = props.align,
      rest = _objectWithoutPropertiesLoose(props, ["className", "style", "grow", "order", "shrink", "basis", "align"]);

  return Object.assign({
    style: Object.assign({}, style, {
      'flex-grow': grow !== undefined && Number(grow),
      'flex-shrink': shrink !== undefined && Number(shrink),
      'flex-basis': (0, _Box.unit)(basis),
      'order': order,
      'align-self': align
    })
  }, rest);
};

exports.computeFlexItemProps = computeFlexItemProps;

var FlexItem = function FlexItem(props) {
  var className = props.className,
      rest = _objectWithoutPropertiesLoose(props, ["className"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "div", (0, _react.classes)([className, computeFlexItemClassName(props), (0, _Box.computeBoxClassName)(props)]), null, 1, Object.assign({}, (0, _Box.computeBoxProps)(computeFlexItemProps(rest)))));
};

FlexItem.defaultHooks = _react.pureComponentHooks;
Flex.Item = FlexItem;

/***/ }),

/***/ "./packages/tgui/components/Grid.js":
/*!******************************************!*\
  !*** ./packages/tgui/components/Grid.js ***!
  \******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.GridColumn = exports.Grid = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _Table = __webpack_require__(/*! ./Table */ "./packages/tgui/components/Table.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

/** @deprecated */
var Grid = function Grid(props) {
  var children = props.children,
      rest = _objectWithoutPropertiesLoose(props, ["children"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Table.Table, Object.assign({}, rest, {
    children: (0, _inferno.createComponentVNode)(2, _Table.Table.Row, {
      children: children
    })
  })));
};

exports.Grid = Grid;
Grid.defaultHooks = _react.pureComponentHooks;
/** @deprecated */

var GridColumn = function GridColumn(props) {
  var _props$size = props.size,
      size = _props$size === void 0 ? 1 : _props$size,
      style = props.style,
      rest = _objectWithoutPropertiesLoose(props, ["size", "style"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Table.Table.Cell, Object.assign({
    "style": Object.assign({
      width: size + '%'
    }, style)
  }, rest)));
};

exports.GridColumn = GridColumn;
Grid.defaultHooks = _react.pureComponentHooks;
Grid.Column = GridColumn;

/***/ }),

/***/ "./packages/tgui/components/Icon.js":
/*!******************************************!*\
  !*** ./packages/tgui/components/Icon.js ***!
  \******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.IconStack = exports.Icon = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var FA_OUTLINE_REGEX = /-o$/;

var Icon = function Icon(props) {
  var name = props.name,
      size = props.size,
      spin = props.spin,
      className = props.className,
      _props$style = props.style,
      style = _props$style === void 0 ? {} : _props$style,
      rotation = props.rotation,
      inverse = props.inverse,
      rest = _objectWithoutPropertiesLoose(props, ["name", "size", "spin", "className", "style", "rotation", "inverse"]);

  if (size) {
    style['font-size'] = size * 100 + '%';
  }

  if (typeof rotation === 'number') {
    style['transform'] = "rotate(" + rotation + "deg)";
  }

  var faRegular = FA_OUTLINE_REGEX.test(name);
  var faName = name.replace(FA_OUTLINE_REGEX, '');
  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Box.Box, Object.assign({
    "as": "i",
    "className": (0, _react.classes)(['Icon', className, faRegular ? 'far' : 'fas', 'fa-' + faName, spin && 'fa-spin']),
    "style": style
  }, rest)));
};

exports.Icon = Icon;
Icon.defaultHooks = _react.pureComponentHooks;

var IconStack = function IconStack(props) {
  var className = props.className,
      _props$style2 = props.style,
      style = _props$style2 === void 0 ? {} : _props$style2,
      children = props.children,
      rest = _objectWithoutPropertiesLoose(props, ["className", "style", "children"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Box.Box, Object.assign({
    "as": "span",
    "class": (0, _react.classes)(['IconStack', className]),
    "style": style
  }, rest, {
    children: children
  })));
};

exports.IconStack = IconStack;
Icon.Stack = IconStack;

/***/ }),

/***/ "./packages/tgui/components/Image.js":
/*!*******************************************!*\
  !*** ./packages/tgui/components/Image.js ***!
  \*******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Image = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var Image = function Image(props) {
  var pixelated = props.pixelated,
      className = props.className,
      rest = _objectWithoutPropertiesLoose(props, ["pixelated", "className"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Box.Box, Object.assign({
    "as": "img"
  }, rest, {
    "className": (0, _react.classes)("Image", pixelated && "Image--pixelated", className)
  })));
};

exports.Image = Image;

/***/ }),

/***/ "./packages/tgui/components/Input.js":
/*!*******************************************!*\
  !*** ./packages/tgui/components/Input.js ***!
  \*******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Input = exports.toInputValue = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

var _keycodes = __webpack_require__(/*! common/keycodes */ "./packages/common/keycodes.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var toInputValue = function toInputValue(value) {
  return typeof value !== 'number' && typeof value !== 'string' ? '' : String(value);
};

exports.toInputValue = toInputValue;

var Input = /*#__PURE__*/function (_Component) {
  _inheritsLoose(Input, _Component);

  function Input() {
    var _this;

    _this = _Component.call(this) || this;
    _this.inputRef = (0, _inferno.createRef)();
    _this.state = {
      editing: false
    };

    _this.handleInput = function (e) {
      var editing = _this.state.editing;
      var onInput = _this.props.onInput;

      if (!editing) {
        _this.setEditing(true);
      }

      if (onInput) {
        onInput(e, e.target.value);
      }
    };

    _this.handleFocus = function (e) {
      var editing = _this.state.editing;

      if (!editing) {
        _this.setEditing(true);
      }
    };

    _this.handleBlur = function (e) {
      var editing = _this.state.editing;
      var onChange = _this.props.onChange;

      if (editing) {
        _this.setEditing(false);

        if (onChange) {
          onChange(e, e.target.value);
        }
      }
    };

    _this.handleKeyDown = function (e) {
      var _this$props = _this.props,
          onInput = _this$props.onInput,
          onChange = _this$props.onChange,
          onEnter = _this$props.onEnter;

      if (e.keyCode === _keycodes.KEY_ENTER) {
        _this.setEditing(false);

        if (onChange) {
          onChange(e, e.target.value);
        }

        if (onInput) {
          onInput(e, e.target.value);
        }

        if (onEnter) {
          onEnter(e, e.target.value);
        }

        if (_this.props.selfClear) {
          e.target.value = '';
        } else {
          e.target.blur();
        }

        return;
      }

      if (e.keyCode === _keycodes.KEY_ESCAPE) {
        _this.setEditing(false);

        e.target.value = toInputValue(_this.props.value);
        e.target.blur();
        return;
      }
    };

    return _this;
  }

  var _proto = Input.prototype;

  _proto.componentDidMount = function () {
    function componentDidMount() {
      var nextValue = this.props.value;
      var input = this.inputRef.current;

      if (input) {
        input.value = toInputValue(nextValue);
      }

      if (this.props.autoFocus) {
        setTimeout(function () {
          return input.focus();
        }, 1);
      }
    }

    return componentDidMount;
  }();

  _proto.componentDidUpdate = function () {
    function componentDidUpdate(prevProps, prevState) {
      var editing = this.state.editing;
      var prevValue = prevProps.value;
      var nextValue = this.props.value;
      var input = this.inputRef.current;

      if (input && !editing && prevValue !== nextValue) {
        input.value = toInputValue(nextValue);
      }
    }

    return componentDidUpdate;
  }();

  _proto.setEditing = function () {
    function setEditing(editing) {
      this.setState({
        editing: editing
      });
    }

    return setEditing;
  }();

  _proto.render = function () {
    function render() {
      var props = this.props; // Input only props

      var selfClear = props.selfClear,
          onInput = props.onInput,
          onChange = props.onChange,
          onEnter = props.onEnter,
          value = props.value,
          maxLength = props.maxLength,
          placeholder = props.placeholder,
          boxProps = _objectWithoutPropertiesLoose(props, ["selfClear", "onInput", "onChange", "onEnter", "value", "maxLength", "placeholder"]); // Box props


      var className = boxProps.className,
          fluid = boxProps.fluid,
          monospace = boxProps.monospace,
          rest = _objectWithoutPropertiesLoose(boxProps, ["className", "fluid", "monospace"]);

      return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Box.Box, Object.assign({
        "className": (0, _react.classes)(['Input', fluid && 'Input--fluid', monospace && 'Input--monospace', className])
      }, rest, {
        children: [(0, _inferno.createVNode)(1, "div", "Input__baseline", ".", 16), (0, _inferno.createVNode)(64, "input", "Input__input", null, 1, {
          "placeholder": placeholder,
          "onInput": this.handleInput,
          "onFocus": this.handleFocus,
          "onBlur": this.handleBlur,
          "onKeyDown": this.handleKeyDown,
          "maxLength": maxLength
        }, null, this.inputRef)]
      })));
    }

    return render;
  }();

  return Input;
}(_inferno.Component);

exports.Input = Input;

/***/ }),

/***/ "./packages/tgui/components/Knob.js":
/*!******************************************!*\
  !*** ./packages/tgui/components/Knob.js ***!
  \******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Knob = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

var _DraggableControl = __webpack_require__(/*! ./DraggableControl */ "./packages/tgui/components/DraggableControl.js");

var _NumberInput = __webpack_require__(/*! ./NumberInput */ "./packages/tgui/components/NumberInput.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var Knob = function Knob(props) {
  // IE8: I don't want to support a yet another component on IE8.
  // IE8: It also can't handle SVG.
  if (Byond.IS_LTE_IE8) {
    return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _NumberInput.NumberInput, Object.assign({}, props)));
  }

  var animated = props.animated,
      format = props.format,
      maxValue = props.maxValue,
      minValue = props.minValue,
      unclamped = props.unclamped,
      onChange = props.onChange,
      onDrag = props.onDrag,
      step = props.step,
      stepPixelSize = props.stepPixelSize,
      suppressFlicker = props.suppressFlicker,
      unit = props.unit,
      value = props.value,
      className = props.className,
      style = props.style,
      fillValue = props.fillValue,
      color = props.color,
      _props$ranges = props.ranges,
      ranges = _props$ranges === void 0 ? {} : _props$ranges,
      _props$size = props.size,
      size = _props$size === void 0 ? 1 : _props$size,
      bipolar = props.bipolar,
      children = props.children,
      rest = _objectWithoutPropertiesLoose(props, ["animated", "format", "maxValue", "minValue", "unclamped", "onChange", "onDrag", "step", "stepPixelSize", "suppressFlicker", "unit", "value", "className", "style", "fillValue", "color", "ranges", "size", "bipolar", "children"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _DraggableControl.DraggableControl, Object.assign({
    "dragMatrix": [0, -1]
  }, {
    animated: animated,
    format: format,
    maxValue: maxValue,
    minValue: minValue,
    unclamped: unclamped,
    onChange: onChange,
    onDrag: onDrag,
    step: step,
    stepPixelSize: stepPixelSize,
    suppressFlicker: suppressFlicker,
    unit: unit,
    value: value
  }, {
    children: function () {
      function children(control) {
        var dragging = control.dragging,
            editing = control.editing,
            value = control.value,
            displayValue = control.displayValue,
            displayElement = control.displayElement,
            inputElement = control.inputElement,
            handleDragStart = control.handleDragStart;
        var scaledFillValue = (0, _math.scale)(fillValue != null ? fillValue : displayValue, minValue, maxValue);
        var scaledDisplayValue = (0, _math.scale)(displayValue, minValue, maxValue);
        var effectiveColor = color || (0, _math.keyOfMatchingRange)(fillValue != null ? fillValue : value, ranges) || 'default';
        var rotation = Math.min((scaledDisplayValue - 0.5) * 270, 225);
        return (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "div", (0, _react.classes)(['Knob', 'Knob--color--' + effectiveColor, bipolar && 'Knob--bipolar', className, (0, _Box.computeBoxClassName)(rest)]), [(0, _inferno.createVNode)(1, "div", "Knob__circle", (0, _inferno.createVNode)(1, "div", "Knob__cursorBox", (0, _inferno.createVNode)(1, "div", "Knob__cursor"), 2, {
          "style": {
            transform: "rotate(" + rotation + "deg)"
          }
        }), 2), dragging && (0, _inferno.createVNode)(1, "div", "Knob__popupValue", displayElement, 0), (0, _inferno.createVNode)(32, "svg", "Knob__ring Knob__ringTrackPivot", (0, _inferno.createVNode)(32, "circle", "Knob__ringTrack", null, 1, {
          "cx": "50",
          "cy": "50",
          "r": "50"
        }), 2, {
          "viewBox": "0 0 100 100"
        }), (0, _inferno.createVNode)(32, "svg", "Knob__ring Knob__ringFillPivot", (0, _inferno.createVNode)(32, "circle", "Knob__ringFill", null, 1, {
          "style": {
            'stroke-dashoffset': Math.max(((bipolar ? 2.75 : 2.00) - scaledFillValue * 1.5) * Math.PI * 50, 0)
          },
          "cx": "50",
          "cy": "50",
          "r": "50"
        }), 2, {
          "viewBox": "0 0 100 100"
        }), inputElement], 0, Object.assign({}, (0, _Box.computeBoxProps)(Object.assign({
          style: Object.assign({
            'font-size': size + 'em'
          }, style)
        }, rest)), {
          "onMouseDown": handleDragStart
        })));
      }

      return children;
    }()
  })));
};

exports.Knob = Knob;

/***/ }),

/***/ "./packages/tgui/components/LabeledControls.js":
/*!*****************************************************!*\
  !*** ./packages/tgui/components/LabeledControls.js ***!
  \*****************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.LabeledControls = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _Flex = __webpack_require__(/*! ./Flex */ "./packages/tgui/components/Flex.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var LabeledControls = function LabeledControls(props) {
  var children = props.children,
      wrap = props.wrap,
      rest = _objectWithoutPropertiesLoose(props, ["children", "wrap"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Flex.Flex, Object.assign({
    "mx": -0.5,
    "wrap": wrap,
    "align": "stretch",
    "justify": "space-between"
  }, rest, {
    children: children
  })));
};

exports.LabeledControls = LabeledControls;

var LabeledControlsItem = function LabeledControlsItem(props) {
  var label = props.label,
      children = props.children,
      _props$mx = props.mx,
      mx = _props$mx === void 0 ? 1 : _props$mx,
      rest = _objectWithoutPropertiesLoose(props, ["label", "children", "mx"]);

  return (0, _inferno.createComponentVNode)(2, _Flex.Flex.Item, {
    "mx": mx,
    children: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Flex.Flex, Object.assign({
      "height": "100%",
      "direction": "column",
      "align": "center",
      "textAlign": "center",
      "justify": "space-between"
    }, rest, {
      children: [(0, _inferno.createComponentVNode)(2, _Flex.Flex.Item), (0, _inferno.createComponentVNode)(2, _Flex.Flex.Item, {
        children: children
      }), (0, _inferno.createComponentVNode)(2, _Flex.Flex.Item, {
        "color": "label",
        children: label
      })]
    })))
  });
};

LabeledControls.Item = LabeledControlsItem;

/***/ }),

/***/ "./packages/tgui/components/LabeledList.tsx":
/*!**************************************************!*\
  !*** ./packages/tgui/components/LabeledList.tsx ***!
  \**************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.LabeledList = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

var _Divider = __webpack_require__(/*! ./Divider */ "./packages/tgui/components/Divider.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var LabeledList = function LabeledList(props) {
  var children = props.children;
  return (0, _inferno.createVNode)(1, "table", "LabeledList", children, 0);
};

exports.LabeledList = LabeledList;
LabeledList.defaultHooks = _react.pureComponentHooks;

var LabeledListItem = function LabeledListItem(props) {
  var className = props.className,
      label = props.label,
      _props$labelColor = props.labelColor,
      labelColor = _props$labelColor === void 0 ? 'label' : _props$labelColor,
      color = props.color,
      textAlign = props.textAlign,
      buttons = props.buttons,
      content = props.content,
      children = props.children;
  return (0, _inferno.createVNode)(1, "tr", (0, _react.classes)(['LabeledList__row', className]), [(0, _inferno.createComponentVNode)(2, _Box.Box, {
    "as": "td",
    "color": labelColor,
    "className": (0, _react.classes)(['LabeledList__cell', 'LabeledList__label']),
    children: label ? label + ':' : null
  }), (0, _inferno.createComponentVNode)(2, _Box.Box, {
    "as": "td",
    "color": color,
    "textAlign": textAlign,
    "className": (0, _react.classes)(['LabeledList__cell', 'LabeledList__content']),
    "colSpan": buttons ? undefined : 2,
    children: [content, children]
  }), buttons && (0, _inferno.createVNode)(1, "td", "LabeledList__cell LabeledList__buttons", buttons, 0)], 0);
};

LabeledListItem.defaultHooks = _react.pureComponentHooks;

var LabeledListDivider = function LabeledListDivider(props) {
  var padding = props.size ? (0, _Box.unit)(Math.max(0, props.size - 1)) : 0;
  return (0, _inferno.createVNode)(1, "tr", "LabeledList__row", (0, _inferno.createVNode)(1, "td", null, (0, _inferno.createComponentVNode)(2, _Divider.Divider), 2, {
    "colSpan": 3,
    "style": {
      'padding-top': padding,
      'padding-bottom': padding
    }
  }), 2);
};

LabeledListDivider.defaultHooks = _react.pureComponentHooks;
LabeledList.Item = LabeledListItem;
LabeledList.Divider = LabeledListDivider;

/***/ }),

/***/ "./packages/tgui/components/Modal.js":
/*!*******************************************!*\
  !*** ./packages/tgui/components/Modal.js ***!
  \*******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Modal = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

var _Dimmer = __webpack_require__(/*! ./Dimmer */ "./packages/tgui/components/Dimmer.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var Modal = function Modal(props) {
  var className = props.className,
      children = props.children,
      full = props.full,
      rest = _objectWithoutPropertiesLoose(props, ["className", "children", "full"]);

  return (0, _inferno.createComponentVNode)(2, _Dimmer.Dimmer, {
    "full": full,
    children: (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "div", (0, _react.classes)(['Modal', className, (0, _Box.computeBoxClassName)(rest)]), children, 0, Object.assign({}, (0, _Box.computeBoxProps)(rest))))
  });
};

exports.Modal = Modal;

/***/ }),

/***/ "./packages/tgui/components/NoticeBox.js":
/*!***********************************************!*\
  !*** ./packages/tgui/components/NoticeBox.js ***!
  \***********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.NoticeBox = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var NoticeBox = function NoticeBox(props) {
  var className = props.className,
      color = props.color,
      info = props.info,
      warning = props.warning,
      success = props.success,
      danger = props.danger,
      rest = _objectWithoutPropertiesLoose(props, ["className", "color", "info", "warning", "success", "danger"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Box.Box, Object.assign({
    "className": (0, _react.classes)(['NoticeBox', color && 'NoticeBox--color--' + color, info && 'NoticeBox--type--info', success && 'NoticeBox--type--success', danger && 'NoticeBox--type--danger', className])
  }, rest)));
};

exports.NoticeBox = NoticeBox;
NoticeBox.defaultHooks = _react.pureComponentHooks;

/***/ }),

/***/ "./packages/tgui/components/NumberInput.js":
/*!*************************************************!*\
  !*** ./packages/tgui/components/NumberInput.js ***!
  \*************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.NumberInput = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _AnimatedNumber = __webpack_require__(/*! ./AnimatedNumber */ "./packages/tgui/components/AnimatedNumber.js");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var DEFAULT_UPDATE_RATE = 400;

var NumberInput = /*#__PURE__*/function (_Component) {
  _inheritsLoose(NumberInput, _Component);

  function NumberInput(props) {
    var _this;

    _this = _Component.call(this, props) || this;
    var value = props.value;
    _this.inputRef = (0, _inferno.createRef)();
    _this.state = {
      value: value,
      dragging: false,
      editing: false,
      internalValue: null,
      origin: null,
      suppressingFlicker: false
    }; // Suppresses flickering while the value propagates through the backend

    _this.flickerTimer = null;

    _this.suppressFlicker = function () {
      var suppressFlicker = _this.props.suppressFlicker;

      if (suppressFlicker > 0) {
        _this.setState({
          suppressingFlicker: true
        });

        clearTimeout(_this.flickerTimer);
        _this.flickerTimer = setTimeout(function () {
          return _this.setState({
            suppressingFlicker: false
          });
        }, suppressFlicker);
      }
    };

    _this.handleDragStart = function (e) {
      var value = _this.props.value;
      var editing = _this.state.editing;

      if (editing) {
        return;
      }

      document.body.style['pointer-events'] = 'none';
      _this.ref = e.target;

      _this.setState({
        dragging: false,
        origin: e.screenY,
        value: value,
        internalValue: value
      });

      _this.timer = setTimeout(function () {
        _this.setState({
          dragging: true
        });
      }, 250);
      _this.dragInterval = setInterval(function () {
        var _this$state = _this.state,
            dragging = _this$state.dragging,
            value = _this$state.value;
        var onDrag = _this.props.onDrag;

        if (dragging && onDrag) {
          onDrag(e, value);
        }
      }, _this.props.updateRate || DEFAULT_UPDATE_RATE);
      document.addEventListener('mousemove', _this.handleDragMove);
      document.addEventListener('mouseup', _this.handleDragEnd);
    };

    _this.handleDragMove = function (e) {
      var _this$props = _this.props,
          minValue = _this$props.minValue,
          maxValue = _this$props.maxValue,
          step = _this$props.step,
          stepPixelSize = _this$props.stepPixelSize;

      _this.setState(function (prevState) {
        var state = Object.assign({}, prevState);
        var offset = state.origin - e.screenY;

        if (prevState.dragging) {
          var stepOffset = Number.isFinite(minValue) ? minValue % step : 0; // Translate mouse movement to value
          // Give it some headroom (by increasing clamp range by 1 step)

          state.internalValue = (0, _math.clamp)(state.internalValue + offset * step / stepPixelSize, minValue - step, maxValue + step); // Clamp the final value

          state.value = (0, _math.clamp)(state.internalValue - state.internalValue % step + stepOffset, minValue, maxValue);
          state.origin = e.screenY;
        } else if (Math.abs(offset) > 4) {
          state.dragging = true;
        }

        return state;
      });
    };

    _this.handleDragEnd = function (e) {
      var _this$props2 = _this.props,
          onChange = _this$props2.onChange,
          onDrag = _this$props2.onDrag;
      var _this$state2 = _this.state,
          dragging = _this$state2.dragging,
          value = _this$state2.value,
          internalValue = _this$state2.internalValue;
      document.body.style['pointer-events'] = 'auto';
      clearTimeout(_this.timer);
      clearInterval(_this.dragInterval);

      _this.setState({
        dragging: false,
        editing: !dragging,
        origin: null
      });

      document.removeEventListener('mousemove', _this.handleDragMove);
      document.removeEventListener('mouseup', _this.handleDragEnd);

      if (dragging) {
        _this.suppressFlicker();

        if (onChange) {
          onChange(e, value);
        }

        if (onDrag) {
          onDrag(e, value);
        }
      } else if (_this.inputRef) {
        var input = _this.inputRef.current;
        input.value = internalValue; // IE8: Dies when trying to focus a hidden element
        // (Error: Object does not support this action)

        try {
          input.focus();
          input.select();
        } catch (_unused) {}
      }
    };

    return _this;
  }

  var _proto = NumberInput.prototype;

  _proto.render = function () {
    function render() {
      var _this2 = this;

      var _this$state3 = this.state,
          dragging = _this$state3.dragging,
          editing = _this$state3.editing,
          intermediateValue = _this$state3.value,
          suppressingFlicker = _this$state3.suppressingFlicker;
      var _this$props3 = this.props,
          className = _this$props3.className,
          fluid = _this$props3.fluid,
          animated = _this$props3.animated,
          value = _this$props3.value,
          unit = _this$props3.unit,
          minValue = _this$props3.minValue,
          maxValue = _this$props3.maxValue,
          height = _this$props3.height,
          width = _this$props3.width,
          lineHeight = _this$props3.lineHeight,
          fontSize = _this$props3.fontSize,
          format = _this$props3.format,
          onChange = _this$props3.onChange,
          onDrag = _this$props3.onDrag;
      var displayValue = value;

      if (dragging || suppressingFlicker) {
        displayValue = intermediateValue;
      } // IE8: Use an "unselectable" prop because "user-select" doesn't work.


      var renderContentElement = function () {
        function renderContentElement(value) {
          return (0, _inferno.createVNode)(1, "div", "NumberInput__content", value + (unit ? ' ' + unit : ''), 0, {
            "unselectable": Byond.IS_LTE_IE8
          });
        }

        return renderContentElement;
      }();

      var contentElement = animated && !dragging && !suppressingFlicker && (0, _inferno.createComponentVNode)(2, _AnimatedNumber.AnimatedNumber, {
        "value": displayValue,
        "format": format,
        children: renderContentElement
      }) || renderContentElement(format ? format(displayValue) : displayValue);
      return (0, _inferno.createComponentVNode)(2, _Box.Box, {
        "className": (0, _react.classes)(['NumberInput', fluid && 'NumberInput--fluid', className]),
        "minWidth": width,
        "minHeight": height,
        "lineHeight": lineHeight,
        "fontSize": fontSize,
        "onMouseDown": this.handleDragStart,
        children: [(0, _inferno.createVNode)(1, "div", "NumberInput__barContainer", (0, _inferno.createVNode)(1, "div", "NumberInput__bar", null, 1, {
          "style": {
            height: (0, _math.clamp)((displayValue - minValue) / (maxValue - minValue) * 100, 0, 100) + '%'
          }
        }), 2), contentElement, (0, _inferno.createVNode)(64, "input", "NumberInput__input", null, 1, {
          "style": {
            opacity: !editing ? 0 : undefined,
            height: height,
            'line-height': lineHeight,
            'font-size': fontSize
          },
          "onFocus": function () {
            function onFocus(e) {
              _this2.setState({
                editing: true
              });

              if (onChange) {
                onChange(e, value);
              }
            }

            return onFocus;
          }(),
          "onBlur": function () {
            function onBlur(e) {
              if (!editing) {
                return;
              }

              var value = (0, _math.clamp)(parseFloat(e.target.value), minValue, maxValue);

              if (Number.isNaN(value)) {
                _this2.setState({
                  editing: false
                });

                return;
              }

              _this2.setState({
                editing: false,
                value: value
              });

              _this2.suppressFlicker();

              if (onChange) {
                onChange(e, value);
              }

              if (onDrag) {
                onDrag(e, value);
              }
            }

            return onBlur;
          }(),
          "onKeyDown": function () {
            function onKeyDown(e) {
              if (e.keyCode === 13) {
                var _value = (0, _math.clamp)(parseFloat(e.target.value), minValue, maxValue);

                if (Number.isNaN(_value)) {
                  _this2.setState({
                    editing: false
                  });

                  return;
                }

                _this2.setState({
                  editing: false,
                  value: _value
                });

                _this2.suppressFlicker();

                if (onChange) {
                  onChange(e, _value);
                }

                if (onDrag) {
                  onDrag(e, _value);
                }

                return;
              }

              if (e.keyCode === 27) {
                _this2.setState({
                  editing: false
                });

                return;
              }
            }

            return onKeyDown;
          }()
        }, null, this.inputRef)]
      });
    }

    return render;
  }();

  return NumberInput;
}(_inferno.Component);

exports.NumberInput = NumberInput;
NumberInput.defaultHooks = _react.pureComponentHooks;
NumberInput.defaultProps = {
  minValue: -Infinity,
  maxValue: +Infinity,
  step: 1,
  stepPixelSize: 1,
  suppressFlicker: 50
};

/***/ }),

/***/ "./packages/tgui/components/Popper.tsx":
/*!*********************************************!*\
  !*** ./packages/tgui/components/Popper.tsx ***!
  \*********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Popper = void 0;

var _core = __webpack_require__(/*! @popperjs/core */ "./.yarn/cache/@popperjs-core-npm-2.9.3-e135257c62-cf73816868.zip/node_modules/@popperjs/core/lib/index.js");

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var Popper = /*#__PURE__*/function (_Component) {
  _inheritsLoose(Popper, _Component);

  function Popper() {
    var _this;

    _this = _Component.call(this) || this;
    _this.renderedContent = void 0;
    _this.popperInstance = void 0;
    Popper.id += 1;
    return _this;
  }

  var _proto = Popper.prototype;

  _proto.componentDidMount = function () {
    function componentDidMount() {
      var _this2 = this;

      var _this$props = this.props,
          additionalStyles = _this$props.additionalStyles,
          options = _this$props.options;
      this.renderedContent = document.createElement("div");

      if (additionalStyles) {
        for (var _i = 0, _Object$entries = Object.entries(additionalStyles); _i < _Object$entries.length; _i++) {
          var _Object$entries$_i = _Object$entries[_i],
              attribute = _Object$entries$_i[0],
              value = _Object$entries$_i[1];
          this.renderedContent.style[attribute] = value;
        }
      }

      this.renderPopperContent(function () {
        document.body.appendChild(_this2.renderedContent);
        _this2.popperInstance = (0, _core.createPopper)( // HACK: We don't want to create a wrapper, as it could break the layout
        // of consumers, so we do the inferno equivalent of `findDOMNode(this)`.
        // This is usually bad as refs are usually better, but refs did
        // not work in this case, as they weren't propagating correctly.
        // A previous attempt was made as a render prop that passed an ID,
        // but this made consuming use too unwieldly.
        // This code is copied from `findDOMNode` in inferno-extras.
        // Because this component is written in TypeScript, we will know
        // immediately if this internal variable is removed.
        (0, _inferno.findDOMfromVNode)(_this2.$LI, true), _this2.renderedContent, options);
      });
    }

    return componentDidMount;
  }();

  _proto.componentDidUpdate = function () {
    function componentDidUpdate() {
      var _this3 = this;

      this.renderPopperContent(function () {
        var _this3$popperInstance;

        return (_this3$popperInstance = _this3.popperInstance) == null ? void 0 : _this3$popperInstance.update();
      });
    }

    return componentDidUpdate;
  }();

  _proto.componentWillUnmount = function () {
    function componentWillUnmount() {
      var _this$popperInstance;

      (_this$popperInstance = this.popperInstance) == null ? void 0 : _this$popperInstance.destroy();
      this.renderedContent.remove();
      this.renderedContent = null;
    }

    return componentWillUnmount;
  }();

  _proto.renderPopperContent = function () {
    function renderPopperContent(callback) {
      (0, _inferno.render)(this.props.popperContent, this.renderedContent, callback);
    }

    return renderPopperContent;
  }();

  _proto.render = function () {
    function render() {
      return this.props.children;
    }

    return render;
  }();

  return Popper;
}(_inferno.Component);

exports.Popper = Popper;
Popper.id = 0;

/***/ }),

/***/ "./packages/tgui/components/ProgressBar.js":
/*!*************************************************!*\
  !*** ./packages/tgui/components/ProgressBar.js ***!
  \*************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ProgressBar = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

var _constants = __webpack_require__(/*! ../constants */ "./packages/tgui/constants.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var ProgressBar = function ProgressBar(props) {
  var className = props.className,
      value = props.value,
      _props$minValue = props.minValue,
      minValue = _props$minValue === void 0 ? 0 : _props$minValue,
      _props$maxValue = props.maxValue,
      maxValue = _props$maxValue === void 0 ? 1 : _props$maxValue,
      color = props.color,
      _props$ranges = props.ranges,
      ranges = _props$ranges === void 0 ? {} : _props$ranges,
      children = props.children,
      rest = _objectWithoutPropertiesLoose(props, ["className", "value", "minValue", "maxValue", "color", "ranges", "children"]);

  var scaledValue = (0, _math.scale)(value, minValue, maxValue);
  var hasContent = children !== undefined;
  var effectiveColor = color || (0, _math.keyOfMatchingRange)(value, ranges) || 'default'; // We permit colors to be in hex format, rgb()/rgba() format,
  // a name for a color-<name> class, or a base CSS class.

  var outerProps = (0, _Box.computeBoxProps)(rest);
  var outerClasses = ['ProgressBar', className, (0, _Box.computeBoxClassName)(rest)];
  var fillStyles = {
    'width': (0, _math.clamp01)(scaledValue) * 100 + '%'
  };

  if (_constants.CSS_COLORS.includes(effectiveColor) || effectiveColor === 'default') {
    // If the color is a color-<name> class, just use that.
    outerClasses.push('ProgressBar--color--' + effectiveColor);
  } else {
    // Otherwise, set styles directly.
    outerProps.style = (outerProps.style || "") + ("border-color: " + effectiveColor + ";");
    fillStyles['background-color'] = effectiveColor;
  }

  return (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "div", (0, _react.classes)(outerClasses), [(0, _inferno.createVNode)(1, "div", "ProgressBar__fill ProgressBar__fill--animated", null, 1, {
    "style": fillStyles
  }), (0, _inferno.createVNode)(1, "div", "ProgressBar__content", hasContent ? children : (0, _math.toFixed)(scaledValue * 100) + '%', 0)], 4, Object.assign({}, outerProps)));
};

exports.ProgressBar = ProgressBar;
ProgressBar.defaultHooks = _react.pureComponentHooks;

/***/ }),

/***/ "./packages/tgui/components/RoundGauge.js":
/*!************************************************!*\
  !*** ./packages/tgui/components/RoundGauge.js ***!
  \************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.RoundGauge = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _AnimatedNumber = __webpack_require__(/*! ./AnimatedNumber */ "./packages/tgui/components/AnimatedNumber.js");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var RoundGauge = function RoundGauge(props) {
  // Support for IE8 is for losers sorry B)
  if (Byond.IS_LTE_IE8) {
    return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _AnimatedNumber.AnimatedNumber, Object.assign({}, props)));
  }

  var value = props.value,
      _props$minValue = props.minValue,
      minValue = _props$minValue === void 0 ? 1 : _props$minValue,
      _props$maxValue = props.maxValue,
      maxValue = _props$maxValue === void 0 ? 1 : _props$maxValue,
      ranges = props.ranges,
      alertAfter = props.alertAfter,
      format = props.format,
      _props$size = props.size,
      size = _props$size === void 0 ? 1 : _props$size,
      className = props.className,
      style = props.style,
      rest = _objectWithoutPropertiesLoose(props, ["value", "minValue", "maxValue", "ranges", "alertAfter", "format", "size", "className", "style"]);

  var scaledValue = (0, _math.scale)(value, minValue, maxValue);
  var clampedValue = (0, _math.clamp01)(scaledValue);
  var scaledRanges = ranges ? {} : {
    "primary": [0, 1]
  };

  if (ranges) {
    Object.keys(ranges).forEach(function (x) {
      var range = ranges[x];
      scaledRanges[x] = [(0, _math.scale)(range[0], minValue, maxValue), (0, _math.scale)(range[1], minValue, maxValue)];
    });
  }

  var alertColor = null;

  if (alertAfter < value) {
    alertColor = (0, _math.keyOfMatchingRange)(clampedValue, scaledRanges);
  }

  return (0, _inferno.createComponentVNode)(2, _Box.Box, {
    "inline": true,
    children: [(0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "div", (0, _react.classes)(['RoundGauge', className, (0, _Box.computeBoxClassName)(rest)]), (0, _inferno.createVNode)(32, "svg", null, [alertAfter && (0, _inferno.createVNode)(32, "g", (0, _react.classes)(['RoundGauge__alert', alertColor ? "active RoundGauge__alert--" + alertColor : '']), (0, _inferno.createVNode)(32, "path", null, null, 1, {
      "d": "M48.211,14.578C48.55,13.9 49.242,13.472 50,13.472C50.758,13.472 51.45,13.9 51.789,14.578C54.793,20.587 60.795,32.589 63.553,38.106C63.863,38.726 63.83,39.462 63.465,40.051C63.101,40.641 62.457,41 61.764,41C55.996,41 44.004,41 38.236,41C37.543,41 36.899,40.641 36.535,40.051C36.17,39.462 36.137,38.726 36.447,38.106C39.205,32.589 45.207,20.587 48.211,14.578ZM50,34.417C51.426,34.417 52.583,35.574 52.583,37C52.583,38.426 51.426,39.583 50,39.583C48.574,39.583 47.417,38.426 47.417,37C47.417,35.574 48.574,34.417 50,34.417ZM50,32.75C50,32.75 53,31.805 53,22.25C53,20.594 51.656,19.25 50,19.25C48.344,19.25 47,20.594 47,22.25C47,31.805 50,32.75 50,32.75Z"
    }), 2), (0, _inferno.createVNode)(32, "g", null, (0, _inferno.createVNode)(32, "circle", "RoundGauge__ringTrack", null, 1, {
      "cx": "50",
      "cy": "50",
      "r": "45"
    }), 2), (0, _inferno.createVNode)(32, "g", null, Object.keys(scaledRanges).map(function (x, i) {
      var col_ranges = scaledRanges[x];
      return (0, _inferno.createVNode)(32, "circle", "RoundGauge__ringFill RoundGauge--color--" + x, null, 1, {
        "style": {
          'stroke-dashoffset': Math.max((2.0 - (col_ranges[1] - col_ranges[0])) * Math.PI * 50, 0)
        },
        "transform": "rotate(" + (180 + 180 * col_ranges[0]) + " 50 50)",
        "cx": "50",
        "cy": "50",
        "r": "45"
      }, i);
    }), 0), (0, _inferno.createVNode)(32, "g", "RoundGauge__needle", [(0, _inferno.createVNode)(32, "polygon", "RoundGauge__needleLine", null, 1, {
      "points": "46,50 50,0 54,50"
    }), (0, _inferno.createVNode)(32, "circle", "RoundGauge__needleMiddle", null, 1, {
      "cx": "50",
      "cy": "50",
      "r": "8"
    })], 4, {
      "transform": "rotate(" + (clampedValue * 180 - 90) + " 50 50)"
    })], 0, {
      "viewBox": "0 0 100 50"
    }), 2, Object.assign({}, (0, _Box.computeBoxProps)(Object.assign({
      style: Object.assign({
        'font-size': size + 'em'
      }, style)
    }, rest))))), (0, _inferno.createComponentVNode)(2, _AnimatedNumber.AnimatedNumber, {
      "value": value,
      "format": format,
      "size": size
    })]
  });
};

exports.RoundGauge = RoundGauge;

/***/ }),

/***/ "./packages/tgui/components/Section.tsx":
/*!**********************************************!*\
  !*** ./packages/tgui/components/Section.tsx ***!
  \**********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Section = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _events = __webpack_require__(/*! ../events */ "./packages/tgui/events.js");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var Section = /*#__PURE__*/function (_Component) {
  _inheritsLoose(Section, _Component);

  function Section(props) {
    var _this;

    _this = _Component.call(this, props) || this;
    _this.scrollableRef = void 0;
    _this.scrollable = void 0;
    _this.scrollableRef = (0, _inferno.createRef)();
    _this.scrollable = props.scrollable;
    return _this;
  }

  var _proto = Section.prototype;

  _proto.componentDidMount = function () {
    function componentDidMount() {
      if (this.scrollable) {
        (0, _events.addScrollableNode)(this.scrollableRef.current);
      }
    }

    return componentDidMount;
  }();

  _proto.componentWillUnmount = function () {
    function componentWillUnmount() {
      if (this.scrollable) {
        (0, _events.removeScrollableNode)(this.scrollableRef.current);
      }
    }

    return componentWillUnmount;
  }();

  _proto.render = function () {
    function render() {
      var _this$props = this.props,
          className = _this$props.className,
          title = _this$props.title,
          buttons = _this$props.buttons,
          fill = _this$props.fill,
          fitted = _this$props.fitted,
          scrollable = _this$props.scrollable,
          children = _this$props.children,
          rest = _objectWithoutPropertiesLoose(_this$props, ["className", "title", "buttons", "fill", "fitted", "scrollable", "children"]);

      var hasTitle = (0, _react.canRender)(title) || (0, _react.canRender)(buttons);
      return (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "div", (0, _react.classes)(['Section', Byond.IS_LTE_IE8 && 'Section--iefix', fill && 'Section--fill', fitted && 'Section--fitted', scrollable && 'Section--scrollable', className, (0, _Box.computeBoxClassName)(rest)]), [hasTitle && (0, _inferno.createVNode)(1, "div", "Section__title", [(0, _inferno.createVNode)(1, "span", "Section__titleText", title, 0), (0, _inferno.createVNode)(1, "div", "Section__buttons", buttons, 0)], 4), (0, _inferno.createVNode)(1, "div", "Section__rest", (0, _inferno.createVNode)(1, "div", "Section__content", children, 0, null, null, this.scrollableRef), 2)], 0, Object.assign({}, (0, _Box.computeBoxProps)(rest))));
    }

    return render;
  }();

  return Section;
}(_inferno.Component);

exports.Section = Section;

/***/ }),

/***/ "./packages/tgui/components/Slider.js":
/*!********************************************!*\
  !*** ./packages/tgui/components/Slider.js ***!
  \********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Slider = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

var _DraggableControl = __webpack_require__(/*! ./DraggableControl */ "./packages/tgui/components/DraggableControl.js");

var _NumberInput = __webpack_require__(/*! ./NumberInput */ "./packages/tgui/components/NumberInput.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var Slider = function Slider(props) {
  // IE8: I don't want to support a yet another component on IE8.
  if (Byond.IS_LTE_IE8) {
    return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _NumberInput.NumberInput, Object.assign({}, props)));
  }

  var animated = props.animated,
      format = props.format,
      maxValue = props.maxValue,
      minValue = props.minValue,
      onChange = props.onChange,
      onDrag = props.onDrag,
      step = props.step,
      stepPixelSize = props.stepPixelSize,
      suppressFlicker = props.suppressFlicker,
      unit = props.unit,
      value = props.value,
      className = props.className,
      fillValue = props.fillValue,
      color = props.color,
      _props$ranges = props.ranges,
      ranges = _props$ranges === void 0 ? {} : _props$ranges,
      _children = props.children,
      rest = _objectWithoutPropertiesLoose(props, ["animated", "format", "maxValue", "minValue", "onChange", "onDrag", "step", "stepPixelSize", "suppressFlicker", "unit", "value", "className", "fillValue", "color", "ranges", "children"]);

  var hasContent = _children !== undefined;
  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _DraggableControl.DraggableControl, Object.assign({
    "dragMatrix": [1, 0]
  }, {
    animated: animated,
    format: format,
    maxValue: maxValue,
    minValue: minValue,
    onChange: onChange,
    onDrag: onDrag,
    step: step,
    stepPixelSize: stepPixelSize,
    suppressFlicker: suppressFlicker,
    unit: unit,
    value: value
  }, {
    children: function () {
      function children(control) {
        var dragging = control.dragging,
            editing = control.editing,
            value = control.value,
            displayValue = control.displayValue,
            displayElement = control.displayElement,
            inputElement = control.inputElement,
            handleDragStart = control.handleDragStart;
        var hasFillValue = fillValue !== undefined && fillValue !== null;
        var scaledValue = (0, _math.scale)(value, minValue, maxValue);
        var scaledFillValue = (0, _math.scale)(fillValue != null ? fillValue : displayValue, minValue, maxValue);
        var scaledDisplayValue = (0, _math.scale)(displayValue, minValue, maxValue);
        var effectiveColor = color || (0, _math.keyOfMatchingRange)(fillValue != null ? fillValue : value, ranges) || 'default';
        return (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "div", (0, _react.classes)(['Slider', 'ProgressBar', 'ProgressBar--color--' + effectiveColor, className, (0, _Box.computeBoxClassName)(rest)]), [(0, _inferno.createVNode)(1, "div", (0, _react.classes)(['ProgressBar__fill', hasFillValue && 'ProgressBar__fill--animated']), null, 1, {
          "style": {
            width: (0, _math.clamp01)(scaledFillValue) * 100 + '%',
            opacity: 0.4
          }
        }), (0, _inferno.createVNode)(1, "div", "ProgressBar__fill", null, 1, {
          "style": {
            width: (0, _math.clamp01)(Math.min(scaledFillValue, scaledDisplayValue)) * 100 + '%'
          }
        }), (0, _inferno.createVNode)(1, "div", "Slider__cursorOffset", [(0, _inferno.createVNode)(1, "div", "Slider__cursor"), (0, _inferno.createVNode)(1, "div", "Slider__pointer"), dragging && (0, _inferno.createVNode)(1, "div", "Slider__popupValue", displayElement, 0)], 0, {
          "style": {
            width: (0, _math.clamp01)(scaledDisplayValue) * 100 + '%'
          }
        }), (0, _inferno.createVNode)(1, "div", "ProgressBar__content", hasContent ? _children : displayElement, 0), inputElement], 0, Object.assign({}, (0, _Box.computeBoxProps)(rest), {
          "onMouseDown": handleDragStart
        })));
      }

      return children;
    }()
  })));
};

exports.Slider = Slider;

/***/ }),

/***/ "./packages/tgui/components/Stack.tsx":
/*!********************************************!*\
  !*** ./packages/tgui/components/Stack.tsx ***!
  \********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Stack = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Flex = __webpack_require__(/*! ./Flex */ "./packages/tgui/components/Flex.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var Stack = function Stack(props) {
  var className = props.className,
      vertical = props.vertical,
      fill = props.fill,
      rest = _objectWithoutPropertiesLoose(props, ["className", "vertical", "fill"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Flex.Flex, Object.assign({
    "className": (0, _react.classes)(['Stack', fill && 'Stack--fill', vertical ? 'Stack--vertical' : 'Stack--horizontal', className]),
    "direction": vertical ? 'column' : 'row'
  }, rest)));
};

exports.Stack = Stack;

var StackItem = function StackItem(props) {
  var className = props.className,
      rest = _objectWithoutPropertiesLoose(props, ["className"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Flex.Flex.Item, Object.assign({
    "className": (0, _react.classes)(['Stack__item', className])
  }, rest)));
};

Stack.Item = StackItem;

var StackDivider = function StackDivider(props) {
  var className = props.className,
      hidden = props.hidden,
      rest = _objectWithoutPropertiesLoose(props, ["className", "hidden"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Flex.Flex.Item, Object.assign({
    "className": (0, _react.classes)(['Stack__item', 'Stack__divider', hidden && 'Stack__divider--hidden', className])
  }, rest)));
};

Stack.Divider = StackDivider;

/***/ }),

/***/ "./packages/tgui/components/Table.js":
/*!*******************************************!*\
  !*** ./packages/tgui/components/Table.js ***!
  \*******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.TableCell = exports.TableRow = exports.Table = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var Table = function Table(props) {
  var className = props.className,
      collapsing = props.collapsing,
      children = props.children,
      rest = _objectWithoutPropertiesLoose(props, ["className", "collapsing", "children"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "table", (0, _react.classes)(['Table', collapsing && 'Table--collapsing', className, (0, _Box.computeBoxClassName)(rest)]), (0, _inferno.createVNode)(1, "tbody", null, children, 0), 2, Object.assign({}, (0, _Box.computeBoxProps)(rest))));
};

exports.Table = Table;
Table.defaultHooks = _react.pureComponentHooks;

var TableRow = function TableRow(props) {
  var className = props.className,
      header = props.header,
      rest = _objectWithoutPropertiesLoose(props, ["className", "header"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "tr", (0, _react.classes)(['Table__row', header && 'Table__row--header', className, (0, _Box.computeBoxClassName)(props)]), null, 1, Object.assign({}, (0, _Box.computeBoxProps)(rest))));
};

exports.TableRow = TableRow;
TableRow.defaultHooks = _react.pureComponentHooks;

var TableCell = function TableCell(props) {
  var className = props.className,
      collapsing = props.collapsing,
      header = props.header,
      rest = _objectWithoutPropertiesLoose(props, ["className", "collapsing", "header"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "td", (0, _react.classes)(['Table__cell', collapsing && 'Table__cell--collapsing', header && 'Table__cell--header', className, (0, _Box.computeBoxClassName)(props)]), null, 1, Object.assign({}, (0, _Box.computeBoxProps)(rest))));
};

exports.TableCell = TableCell;
TableCell.defaultHooks = _react.pureComponentHooks;
Table.Row = TableRow;
Table.Cell = TableCell;

/***/ }),

/***/ "./packages/tgui/components/Tabs.js":
/*!******************************************!*\
  !*** ./packages/tgui/components/Tabs.js ***!
  \******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Tabs = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

var _Icon = __webpack_require__(/*! ./Icon */ "./packages/tgui/components/Icon.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var Tabs = function Tabs(props) {
  var className = props.className,
      vertical = props.vertical,
      fill = props.fill,
      fluid = props.fluid,
      children = props.children,
      rest = _objectWithoutPropertiesLoose(props, ["className", "vertical", "fill", "fluid", "children"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "div", (0, _react.classes)(['Tabs', vertical ? 'Tabs--vertical' : 'Tabs--horizontal', fill && 'Tabs--fill', fluid && 'Tabs--fluid', className, (0, _Box.computeBoxClassName)(rest)]), children, 0, Object.assign({}, (0, _Box.computeBoxProps)(rest))));
};

exports.Tabs = Tabs;

var Tab = function Tab(props) {
  var className = props.className,
      selected = props.selected,
      color = props.color,
      icon = props.icon,
      leftSlot = props.leftSlot,
      rightSlot = props.rightSlot,
      children = props.children,
      rest = _objectWithoutPropertiesLoose(props, ["className", "selected", "color", "icon", "leftSlot", "rightSlot", "children"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createVNode)(1, "div", (0, _react.classes)(['Tab', 'Tabs__Tab', 'Tab--color--' + color, selected && 'Tab--selected', className].concat((0, _Box.computeBoxClassName)(rest))), [(0, _react.canRender)(leftSlot) && (0, _inferno.createVNode)(1, "div", "Tab__left", leftSlot, 0) || !!icon && (0, _inferno.createVNode)(1, "div", "Tab__left", (0, _inferno.createComponentVNode)(2, _Icon.Icon, {
    "name": icon
  }), 2), (0, _inferno.createVNode)(1, "div", "Tab__text", children, 0), (0, _react.canRender)(rightSlot) && (0, _inferno.createVNode)(1, "div", "Tab__right", rightSlot, 0)], 0, Object.assign({}, (0, _Box.computeBoxProps)(rest))));
};

Tabs.Tab = Tab;

/***/ }),

/***/ "./packages/tgui/components/TextArea.js":
/*!**********************************************!*\
  !*** ./packages/tgui/components/TextArea.js ***!
  \**********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.TextArea = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

var _Input = __webpack_require__(/*! ./Input */ "./packages/tgui/components/Input.js");

var _keycodes = __webpack_require__(/*! common/keycodes */ "./packages/common/keycodes.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var TextArea = /*#__PURE__*/function (_Component) {
  _inheritsLoose(TextArea, _Component);

  function TextArea(props, context) {
    var _this;

    _this = _Component.call(this, props, context) || this;
    _this.textareaRef = (0, _inferno.createRef)();
    _this.fillerRef = (0, _inferno.createRef)();
    _this.state = {
      editing: false
    };
    var _props$dontUseTabForI = props.dontUseTabForIndent,
        dontUseTabForIndent = _props$dontUseTabForI === void 0 ? false : _props$dontUseTabForI;

    _this.handleOnInput = function (e) {
      var editing = _this.state.editing;
      var onInput = _this.props.onInput;

      if (!editing) {
        _this.setEditing(true);
      }

      if (onInput) {
        onInput(e, e.target.value);
      }
    };

    _this.handleOnChange = function (e) {
      var editing = _this.state.editing;
      var onChange = _this.props.onChange;

      if (editing) {
        _this.setEditing(false);
      }

      if (onChange) {
        onChange(e, e.target.value);
      }
    };

    _this.handleKeyPress = function (e) {
      var editing = _this.state.editing;
      var onKeyPress = _this.props.onKeyPress;

      if (!editing) {
        _this.setEditing(true);
      }

      if (onKeyPress) {
        onKeyPress(e, e.target.value);
      }
    };

    _this.handleKeyDown = function (e) {
      var editing = _this.state.editing;
      var onKeyDown = _this.props.onKeyDown;

      if (e.keyCode === _keycodes.KEY_ESCAPE) {
        _this.setEditing(false);

        e.target.value = (0, _Input.toInputValue)(_this.props.value);
        e.target.blur();
        return;
      }

      if (!editing) {
        _this.setEditing(true);
      }

      if (!dontUseTabForIndent) {
        var keyCode = e.keyCode || e.which;

        if (keyCode === 9) {
          e.preventDefault();
          var _e$target = e.target,
              value = _e$target.value,
              selectionStart = _e$target.selectionStart,
              selectionEnd = _e$target.selectionEnd;
          e.target.value = value.substring(0, selectionStart) + "\t" + value.substring(selectionEnd);
          e.target.selectionEnd = selectionStart + 1;
        }
      }

      if (onKeyDown) {
        onKeyDown(e, e.target.value);
      }
    };

    _this.handleFocus = function (e) {
      var editing = _this.state.editing;

      if (!editing) {
        _this.setEditing(true);
      }
    };

    _this.handleBlur = function (e) {
      var editing = _this.state.editing;
      var onChange = _this.props.onChange;

      if (editing) {
        _this.setEditing(false);

        if (onChange) {
          onChange(e, e.target.value);
        }
      }
    };

    return _this;
  }

  var _proto = TextArea.prototype;

  _proto.componentDidMount = function () {
    function componentDidMount() {
      var nextValue = this.props.value;
      var input = this.textareaRef.current;

      if (input) {
        input.value = (0, _Input.toInputValue)(nextValue);
      }
    }

    return componentDidMount;
  }();

  _proto.componentDidUpdate = function () {
    function componentDidUpdate(prevProps, prevState) {
      var editing = this.state.editing;
      var prevValue = prevProps.value;
      var nextValue = this.props.value;
      var input = this.textareaRef.current;

      if (input && !editing && prevValue !== nextValue) {
        input.value = (0, _Input.toInputValue)(nextValue);
      }
    }

    return componentDidUpdate;
  }();

  _proto.setEditing = function () {
    function setEditing(editing) {
      this.setState({
        editing: editing
      });
    }

    return setEditing;
  }();

  _proto.getValue = function () {
    function getValue() {
      return this.textareaRef.current && this.textareaRef.current.value;
    }

    return getValue;
  }();

  _proto.render = function () {
    function render() {
      // Input only props
      var _this$props = this.props,
          onChange = _this$props.onChange,
          onKeyDown = _this$props.onKeyDown,
          onKeyPress = _this$props.onKeyPress,
          onInput = _this$props.onInput,
          onFocus = _this$props.onFocus,
          onBlur = _this$props.onBlur,
          onEnter = _this$props.onEnter,
          value = _this$props.value,
          maxLength = _this$props.maxLength,
          placeholder = _this$props.placeholder,
          boxProps = _objectWithoutPropertiesLoose(_this$props, ["onChange", "onKeyDown", "onKeyPress", "onInput", "onFocus", "onBlur", "onEnter", "value", "maxLength", "placeholder"]); // Box props


      var className = boxProps.className,
          fluid = boxProps.fluid,
          rest = _objectWithoutPropertiesLoose(boxProps, ["className", "fluid"]);

      return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Box.Box, Object.assign({
        "className": (0, _react.classes)(['TextArea', fluid && 'TextArea--fluid', className])
      }, rest, {
        children: (0, _inferno.createVNode)(128, "textarea", "TextArea__textarea", null, 1, {
          "placeholder": placeholder,
          "onChange": this.handleOnChange,
          "onKeyDown": this.handleKeyDown,
          "onKeyPress": this.handleKeyPress,
          "onInput": this.handleOnInput,
          "onFocus": this.handleFocus,
          "onBlur": this.handleBlur,
          "maxLength": maxLength
        }, null, this.textareaRef)
      })));
    }

    return render;
  }();

  return TextArea;
}(_inferno.Component);

exports.TextArea = TextArea;

/***/ }),

/***/ "./packages/tgui/components/TimeDisplay.js":
/*!*************************************************!*\
  !*** ./packages/tgui/components/TimeDisplay.js ***!
  \*************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.TimeDisplay = void 0;

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

// AnimatedNumber Copypaste
var isSafeNumber = function isSafeNumber(value) {
  return typeof value === 'number' && Number.isFinite(value) && !Number.isNaN(value);
};

var TimeDisplay = /*#__PURE__*/function (_Component) {
  _inheritsLoose(TimeDisplay, _Component);

  function TimeDisplay(props) {
    var _this;

    _this = _Component.call(this, props) || this;
    _this.timer = null;
    _this.timing = false;
    _this.format = null;
    _this.last_seen_value = undefined;
    _this.state = {
      value: 0
    }; // Set initial state with value provided in props

    if (isSafeNumber(props.value)) {
      _this.state.value = Number(props.value);
      _this.last_seen_value = Number(props.value);
    }

    return _this;
  }

  var _proto = TimeDisplay.prototype;

  _proto.componentDidUpdate = function () {
    function componentDidUpdate() {
      var _this2 = this;

      if (this.props.timing) {
        clearInterval(this.timer);
        this.timer = setInterval(function () {
          return _this2.tick();
        }, 1000); // every 1 s
      }
    }

    return componentDidUpdate;
  }();

  _proto.tick = function () {
    function tick() {
      var current = Number(this.state.value);

      if (this.props.value !== this.last_seen_value) {
        this.last_seen_value = this.props.value;
        current = this.props.value;
      }

      var mod = this.props.auto === "up" ? 10 : -10; // Time down by default.

      var value = Math.max(0, current + mod); // one sec tick

      this.setState({
        value: value
      });
    }

    return tick;
  }();

  _proto.componentDidMount = function () {
    function componentDidMount() {
      var _this3 = this;

      if (this.props.timing) {
        this.timer = setInterval(function () {
          return _this3.tick();
        }, 1000); // every 1 s
      }
    }

    return componentDidMount;
  }();

  _proto.componentWillUnmount = function () {
    function componentWillUnmount() {
      clearInterval(this.timer);
    }

    return componentWillUnmount;
  }();

  TimeDisplay.getDerivedStateFromProps = function () {
    function getDerivedStateFromProps(nextProps) {
      if (nextProps.timing) {
        return null;
      }

      return {
        value: nextProps.value
      };
    }

    return getDerivedStateFromProps;
  }();

  TimeDisplay.defaultFormat = function () {
    function defaultFormat(value) {
      var seconds = (0, _math.toFixed)(Math.floor(value / 10 % 60)).padStart(2, "0");
      var minutes = (0, _math.toFixed)(Math.floor(value / (10 * 60) % 60)).padStart(2, "0");
      var hours = (0, _math.toFixed)(Math.floor(value / (10 * 60 * 60) % 24)).padStart(2, "0");
      return hours + ":" + minutes + ":" + seconds;
    }

    return defaultFormat;
  }();

  _proto.render = function () {
    function render() {
      var val = this.state.value; // Directly display weird stuff

      if (!isSafeNumber(val)) {
        return this.state.value || null;
      }

      if (this.props.format) {
        return this.props.format(val);
      } else {
        return TimeDisplay.defaultFormat(val);
      }
    }

    return render;
  }();

  return TimeDisplay;
}(_inferno.Component);

exports.TimeDisplay = TimeDisplay;

/***/ }),

/***/ "./packages/tgui/components/Tooltip.tsx":
/*!**********************************************!*\
  !*** ./packages/tgui/components/Tooltip.tsx ***!
  \**********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Tooltip = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _Popper = __webpack_require__(/*! ./Popper */ "./packages/tgui/components/Popper.tsx");

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var DEFAULT_PLACEMENT = "top";

var Tooltip = /*#__PURE__*/function (_Component) {
  _inheritsLoose(Tooltip, _Component);

  function Tooltip() {
    var _this;

    _this = _Component.call(this) || this;
    _this.state = {
      hovered: false
    };
    return _this;
  }

  var _proto = Tooltip.prototype;

  _proto.componentDidMount = function () {
    function componentDidMount() {
      var _this2 = this;

      // HACK: We don't want to create a wrapper, as it could break the layout
      // of consumers, so we do the inferno equivalent of `findDOMNode(this)`.
      // My attempt to avoid this was a render prop that passed in
      // callbacks to onmouseenter and onmouseleave, but this was unwiedly
      // to consumers, specifically buttons.
      // This code is copied from `findDOMNode` in inferno-extras.
      // Because this component is written in TypeScript, we will know
      // immediately if this internal variable is removed.
      var domNode = (0, _inferno.findDOMfromVNode)(this.$LI, true);
      domNode.addEventListener("mouseenter", function () {
        _this2.setState({
          hovered: true
        });
      });
      domNode.addEventListener("mouseleave", function () {
        _this2.setState({
          hovered: false
        });
      });
    }

    return componentDidMount;
  }();

  _proto.render = function () {
    function render() {
      return (0, _inferno.createComponentVNode)(2, _Popper.Popper, {
        "options": {
          placement: this.props.position || "auto"
        },
        "popperContent": (0, _inferno.createVNode)(1, "div", "Tooltip", this.props.content, 0, {
          "style": {
            opacity: this.state.hovered ? 1 : 0
          }
        }),
        "additionalStyles": {
          "pointer-events": "none"
        },
        children: this.props.children
      });
    }

    return render;
  }();

  return Tooltip;
}(_inferno.Component);

exports.Tooltip = Tooltip;

/***/ }),

/***/ "./packages/tgui/components/goonstation/ColorButton.js":
/*!*************************************************************!*\
  !*** ./packages/tgui/components/goonstation/ColorButton.js ***!
  \*************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ColorButton = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _Box = __webpack_require__(/*! ../Box */ "./packages/tgui/components/Box.tsx");

var _Button = __webpack_require__(/*! ../Button */ "./packages/tgui/components/Button.js");

var _ColorBox = __webpack_require__(/*! ../ColorBox */ "./packages/tgui/components/ColorBox.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var ColorButton = function ColorButton(props) {
  var color = props.color,
      rest = _objectWithoutPropertiesLoose(props, ["color"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Button.Button, Object.assign({}, rest, {
    children: [(0, _inferno.createComponentVNode)(2, _ColorBox.ColorBox, {
      "color": color,
      "mr": "5px"
    }), (0, _inferno.createComponentVNode)(2, _Box.Box, {
      "as": "code",
      children: color
    })]
  })));
};

exports.ColorButton = ColorButton;

/***/ }),

/***/ "./packages/tgui/components/goonstation/Placeholder.tsx":
/*!**************************************************************!*\
  !*** ./packages/tgui/components/goonstation/Placeholder.tsx ***!
  \**************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Placeholder = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ../Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var Placeholder = function Placeholder(props) {
  var _props$children = props.children,
      children = _props$children === void 0 ? 'No results found' : _props$children,
      className = props.className,
      rest = _objectWithoutPropertiesLoose(props, ["children", "className"]);

  var cn = (0, _react.classes)(['placeholder', className]);
  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Box.Box, Object.assign({
    "className": cn,
    "color": "label",
    "italic": true
  }, rest, {
    children: children
  })));
};

exports.Placeholder = Placeholder;

/***/ }),

/***/ "./packages/tgui/components/goonstation/SectionEx.js":
/*!***********************************************************!*\
  !*** ./packages/tgui/components/goonstation/SectionEx.js ***!
  \***********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.SectionEx = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ../Box */ "./packages/tgui/components/Box.tsx");

var _Section = __webpack_require__(/*! ../Section */ "./packages/tgui/components/Section.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var SectionEx = function SectionEx(props) {
  var className = props.className,
      capitalize = props.capitalize,
      rest = _objectWithoutPropertiesLoose(props, ["className", "capitalize"]);

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Section.Section, Object.assign({
    "className": (0, _react.classes)(['SectionEx', capitalize && 'SectionEx__capitalize', className, (0, _Box.computeBoxClassName)(rest)])
  }, rest)));
};

exports.SectionEx = SectionEx;

/***/ }),

/***/ "./packages/tgui/components/index.js":
/*!*******************************************!*\
  !*** ./packages/tgui/components/index.js ***!
  \*******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Tooltip = exports.TimeDisplay = exports.TextArea = exports.Tabs = exports.Table = exports.Stack = exports.Slider = exports.SectionEx = exports.Section = exports.RoundGauge = exports.Popper = exports.ProgressBar = exports.Placeholder = exports.NumberInput = exports.NoticeBox = exports.Modal = exports.LabeledList = exports.LabeledControls = exports.Knob = exports.Input = exports.Image = exports.Icon = exports.Grid = exports.Flex = exports.Dropdown = exports.DraggableControl = exports.Divider = exports.Dimmer = exports.ColorButton = exports.ColorBox = exports.Collapsible = exports.Chart = exports.ByondUi = exports.Button = exports.Box = exports.BlockQuote = exports.Blink = exports.AnimatedNumber = void 0;

var _AnimatedNumber = __webpack_require__(/*! ./AnimatedNumber */ "./packages/tgui/components/AnimatedNumber.js");

exports.AnimatedNumber = _AnimatedNumber.AnimatedNumber;

var _Blink = __webpack_require__(/*! ./Blink */ "./packages/tgui/components/Blink.js");

exports.Blink = _Blink.Blink;

var _BlockQuote = __webpack_require__(/*! ./BlockQuote */ "./packages/tgui/components/BlockQuote.js");

exports.BlockQuote = _BlockQuote.BlockQuote;

var _Box = __webpack_require__(/*! ./Box */ "./packages/tgui/components/Box.tsx");

exports.Box = _Box.Box;

var _Button = __webpack_require__(/*! ./Button */ "./packages/tgui/components/Button.js");

exports.Button = _Button.Button;

var _ByondUi = __webpack_require__(/*! ./ByondUi */ "./packages/tgui/components/ByondUi.js");

exports.ByondUi = _ByondUi.ByondUi;

var _Chart = __webpack_require__(/*! ./Chart */ "./packages/tgui/components/Chart.js");

exports.Chart = _Chart.Chart;

var _Collapsible = __webpack_require__(/*! ./Collapsible */ "./packages/tgui/components/Collapsible.js");

exports.Collapsible = _Collapsible.Collapsible;

var _ColorBox = __webpack_require__(/*! ./ColorBox */ "./packages/tgui/components/ColorBox.js");

exports.ColorBox = _ColorBox.ColorBox;

var _ColorButton = __webpack_require__(/*! ./goonstation/ColorButton */ "./packages/tgui/components/goonstation/ColorButton.js");

exports.ColorButton = _ColorButton.ColorButton;

var _Dimmer = __webpack_require__(/*! ./Dimmer */ "./packages/tgui/components/Dimmer.js");

exports.Dimmer = _Dimmer.Dimmer;

var _Divider = __webpack_require__(/*! ./Divider */ "./packages/tgui/components/Divider.js");

exports.Divider = _Divider.Divider;

var _DraggableControl = __webpack_require__(/*! ./DraggableControl */ "./packages/tgui/components/DraggableControl.js");

exports.DraggableControl = _DraggableControl.DraggableControl;

var _Dropdown = __webpack_require__(/*! ./Dropdown */ "./packages/tgui/components/Dropdown.js");

exports.Dropdown = _Dropdown.Dropdown;

var _Flex = __webpack_require__(/*! ./Flex */ "./packages/tgui/components/Flex.tsx");

exports.Flex = _Flex.Flex;

var _Grid = __webpack_require__(/*! ./Grid */ "./packages/tgui/components/Grid.js");

exports.Grid = _Grid.Grid;

var _Icon = __webpack_require__(/*! ./Icon */ "./packages/tgui/components/Icon.js");

exports.Icon = _Icon.Icon;

var _Image = __webpack_require__(/*! ./Image */ "./packages/tgui/components/Image.js");

exports.Image = _Image.Image;

var _Input = __webpack_require__(/*! ./Input */ "./packages/tgui/components/Input.js");

exports.Input = _Input.Input;

var _Knob = __webpack_require__(/*! ./Knob */ "./packages/tgui/components/Knob.js");

exports.Knob = _Knob.Knob;

var _LabeledControls = __webpack_require__(/*! ./LabeledControls */ "./packages/tgui/components/LabeledControls.js");

exports.LabeledControls = _LabeledControls.LabeledControls;

var _LabeledList = __webpack_require__(/*! ./LabeledList */ "./packages/tgui/components/LabeledList.tsx");

exports.LabeledList = _LabeledList.LabeledList;

var _Modal = __webpack_require__(/*! ./Modal */ "./packages/tgui/components/Modal.js");

exports.Modal = _Modal.Modal;

var _NoticeBox = __webpack_require__(/*! ./NoticeBox */ "./packages/tgui/components/NoticeBox.js");

exports.NoticeBox = _NoticeBox.NoticeBox;

var _NumberInput = __webpack_require__(/*! ./NumberInput */ "./packages/tgui/components/NumberInput.js");

exports.NumberInput = _NumberInput.NumberInput;

var _Placeholder = __webpack_require__(/*! ./goonstation/Placeholder */ "./packages/tgui/components/goonstation/Placeholder.tsx");

exports.Placeholder = _Placeholder.Placeholder;

var _ProgressBar = __webpack_require__(/*! ./ProgressBar */ "./packages/tgui/components/ProgressBar.js");

exports.ProgressBar = _ProgressBar.ProgressBar;

var _Popper = __webpack_require__(/*! ./Popper */ "./packages/tgui/components/Popper.tsx");

exports.Popper = _Popper.Popper;

var _RoundGauge = __webpack_require__(/*! ./RoundGauge */ "./packages/tgui/components/RoundGauge.js");

exports.RoundGauge = _RoundGauge.RoundGauge;

var _Section = __webpack_require__(/*! ./Section */ "./packages/tgui/components/Section.tsx");

exports.Section = _Section.Section;

var _SectionEx = __webpack_require__(/*! ./goonstation/SectionEx */ "./packages/tgui/components/goonstation/SectionEx.js");

exports.SectionEx = _SectionEx.SectionEx;

var _Slider = __webpack_require__(/*! ./Slider */ "./packages/tgui/components/Slider.js");

exports.Slider = _Slider.Slider;

var _Stack = __webpack_require__(/*! ./Stack */ "./packages/tgui/components/Stack.tsx");

exports.Stack = _Stack.Stack;

var _Table = __webpack_require__(/*! ./Table */ "./packages/tgui/components/Table.js");

exports.Table = _Table.Table;

var _Tabs = __webpack_require__(/*! ./Tabs */ "./packages/tgui/components/Tabs.js");

exports.Tabs = _Tabs.Tabs;

var _TextArea = __webpack_require__(/*! ./TextArea */ "./packages/tgui/components/TextArea.js");

exports.TextArea = _TextArea.TextArea;

var _TimeDisplay = __webpack_require__(/*! ./TimeDisplay */ "./packages/tgui/components/TimeDisplay.js");

exports.TimeDisplay = _TimeDisplay.TimeDisplay;

var _Tooltip = __webpack_require__(/*! ./Tooltip */ "./packages/tgui/components/Tooltip.tsx");

exports.Tooltip = _Tooltip.Tooltip;

/***/ }),

/***/ "./packages/tgui/constants.js":
/*!************************************!*\
  !*** ./packages/tgui/constants.js ***!
  \************************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.getGasColor = exports.getGasLabel = exports.RADIO_CHANNELS = exports.CSS_COLORS = exports.COLORS = exports.UI_CLOSE = exports.UI_DISABLED = exports.UI_UPDATE = exports.UI_INTERACTIVE = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
// UI states, which are mirrored from the BYOND code.
var UI_INTERACTIVE = 2;
exports.UI_INTERACTIVE = UI_INTERACTIVE;
var UI_UPDATE = 1;
exports.UI_UPDATE = UI_UPDATE;
var UI_DISABLED = 0;
exports.UI_DISABLED = UI_DISABLED;
var UI_CLOSE = -1; // All game related colors are stored here

exports.UI_CLOSE = UI_CLOSE;
var COLORS = {
  // Department colors
  department: {
    captain: '#548b55',
    // |GOONSTATION-CHANGE|
    security: '#e74c3c',
    medbay: '#3498db',
    science: '#9b59b6',
    engineering: '#f1c40f',
    cargo: '#f39c12',
    centcom: '#00c100',
    other: '#c38312'
  },
  // Damage type colors
  damageType: {
    oxy: '#3498db',
    toxin: '#2ecc71',
    burn: '#e67e22',
    brute: '#e74c3c'
  }
}; // Colors defined in CSS

exports.COLORS = COLORS;
var CSS_COLORS = ['black', 'white', 'red', 'orange', 'yellow', 'olive', 'green', 'teal', 'blue', 'violet', 'purple', 'pink', 'brown', 'grey', 'good', 'average', 'bad', 'label'];
exports.CSS_COLORS = CSS_COLORS;
var RADIO_CHANNELS = [{
  name: 'Syndicate',
  freq: 1352,
  color: '#BB3333'
}, {
  name: 'CentCom',
  freq: 1451,
  color: '#2681a5'
}, {
  name: 'Catering',
  freq: 1485,
  color: '#C16082'
}, {
  name: 'Civilian',
  freq: 1355,
  color: '#6ca729'
}, {
  name: 'Research',
  freq: 1354,
  color: '#153E9E'
}, {
  name: 'Command',
  freq: 1356,
  color: '#5177ff'
}, {
  name: 'Medical',
  freq: 1445,
  color: '#57b8f0'
}, {
  name: 'Engineering',
  freq: 1441,
  color: '#BBBB00'
}, {
  name: 'Security',
  freq: 1485,
  color: '#dd3535'
}, {
  name: 'AI',
  freq: 1447,
  color: '#333399'
}, {
  name: 'Bridge',
  freq: 1442,
  color: '#339933'
}];
exports.RADIO_CHANNELS = RADIO_CHANNELS;
var GASES = [{
  'id': 'o2',
  'name': 'Oxygen',
  'label': 'O₂',
  'color': 'blue'
}, {
  'id': 'n2',
  'name': 'Nitrogen',
  'label': 'N₂',
  'color': 'red'
}, {
  'id': 'co2',
  'name': 'Carbon Dioxide',
  'label': 'CO₂',
  'color': 'grey'
}, {
  'id': 'plasma',
  'name': 'Plasma',
  'label': 'Plasma',
  'color': 'pink'
}, {
  'id': 'n2o',
  'name': 'Nitrous Oxide',
  'label': 'N₂O',
  'color': 'red'
}];

var getGasLabel = function getGasLabel(gasId, fallbackValue) {
  var gasSearchString = String(gasId).toLowerCase();
  var gas = GASES.find(function (gas) {
    return gas.id === gasSearchString || gas.name.toLowerCase() === gasSearchString;
  });
  return gas && gas.label || fallbackValue || gasId;
};

exports.getGasLabel = getGasLabel;

var getGasColor = function getGasColor(gasId) {
  var gasSearchString = String(gasId).toLowerCase();
  var gas = GASES.find(function (gas) {
    return gas.id === gasSearchString || gas.name.toLowerCase() === gasSearchString;
  });
  return gas && gas.color;
};

exports.getGasColor = getGasColor;

/***/ }),

/***/ "./packages/tgui/events.js":
/*!*********************************!*\
  !*** ./packages/tgui/events.js ***!
  \*********************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.KeyEvent = exports.removeScrollableNode = exports.addScrollableNode = exports.canStealFocus = exports.setupGlobalEvents = exports.globalEvents = void 0;

var _events = __webpack_require__(/*! common/events */ "./packages/common/events.js");

var _keycodes = __webpack_require__(/*! common/keycodes */ "./packages/common/keycodes.js");

/**
 * Normalized browser focus events and BYOND-specific focus helpers.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var globalEvents = new _events.EventEmitter();
exports.globalEvents = globalEvents;
var ignoreWindowFocus = false;

var setupGlobalEvents = function setupGlobalEvents(options) {
  if (options === void 0) {
    options = {};
  }

  ignoreWindowFocus = !!options.ignoreWindowFocus;
}; // Window focus
// --------------------------------------------------------


exports.setupGlobalEvents = setupGlobalEvents;
var windowFocusTimeout;
var windowFocused = true;

var setWindowFocus = function setWindowFocus(value, delayed) {
  // Pretend to always be in focus.
  if (ignoreWindowFocus) {
    windowFocused = true;
    return;
  }

  if (windowFocusTimeout) {
    clearTimeout(windowFocusTimeout);
    windowFocusTimeout = null;
  }

  if (delayed) {
    windowFocusTimeout = setTimeout(function () {
      return setWindowFocus(value);
    });
    return;
  }

  if (windowFocused !== value) {
    windowFocused = value;
    globalEvents.emit(value ? 'window-focus' : 'window-blur');
    globalEvents.emit('window-focus-change', value);
  }
}; // Focus stealing
// --------------------------------------------------------


var focusStolenBy = null;

var canStealFocus = function canStealFocus(node) {
  var tag = String(node.tagName).toLowerCase();
  return tag === 'input' || tag === 'textarea';
};

exports.canStealFocus = canStealFocus;

var stealFocus = function stealFocus(node) {
  releaseStolenFocus();
  focusStolenBy = node;
  focusStolenBy.addEventListener('blur', releaseStolenFocus);
};

var releaseStolenFocus = function releaseStolenFocus() {
  if (focusStolenBy) {
    focusStolenBy.removeEventListener('blur', releaseStolenFocus);
    focusStolenBy = null;
  }
}; // Focus follows the mouse
// --------------------------------------------------------


var focusedNode = null;
var lastVisitedNode = null;
var trackedNodes = [];

var addScrollableNode = function addScrollableNode(node) {
  trackedNodes.push(node);
};

exports.addScrollableNode = addScrollableNode;

var removeScrollableNode = function removeScrollableNode(node) {
  var index = trackedNodes.indexOf(node);

  if (index >= 0) {
    trackedNodes.splice(index, 1);
  }
};

exports.removeScrollableNode = removeScrollableNode;

var focusNearestTrackedParent = function focusNearestTrackedParent(node) {
  if (focusStolenBy || !windowFocused) {
    return;
  }

  var body = document.body;

  while (node && node !== body) {
    if (trackedNodes.includes(node)) {
      // NOTE: Contains is a DOM4 method
      if (node.contains(focusedNode)) {
        return;
      }

      focusedNode = node;
      node.focus();
      return;
    }

    node = node.parentNode;
  }
};

window.addEventListener('mousemove', function (e) {
  var node = e.target;

  if (node !== lastVisitedNode) {
    lastVisitedNode = node;
    focusNearestTrackedParent(node);
  }
}); // Focus event hooks
// --------------------------------------------------------

window.addEventListener('focusin', function (e) {
  lastVisitedNode = null;
  focusedNode = e.target;
  setWindowFocus(true);

  if (canStealFocus(e.target)) {
    stealFocus(e.target);
    return;
  }
});
window.addEventListener('focusout', function (e) {
  lastVisitedNode = null;
  setWindowFocus(false, true);
});
window.addEventListener('blur', function (e) {
  lastVisitedNode = null;
  setWindowFocus(false, true);
});
window.addEventListener('beforeunload', function (e) {
  setWindowFocus(false);
}); // Key events
// --------------------------------------------------------

var keyHeldByCode = {};

var KeyEvent = /*#__PURE__*/function () {
  function KeyEvent(e, type, repeat) {
    this.event = e;
    this.type = type;
    this.code = window.event ? e.which : e.keyCode;
    this.ctrl = e.ctrlKey;
    this.shift = e.shiftKey;
    this.alt = e.altKey;
    this.repeat = !!repeat;
  }

  var _proto = KeyEvent.prototype;

  _proto.hasModifierKeys = function () {
    function hasModifierKeys() {
      return this.ctrl || this.alt || this.shift;
    }

    return hasModifierKeys;
  }();

  _proto.isModifierKey = function () {
    function isModifierKey() {
      return this.code === _keycodes.KEY_CTRL || this.code === _keycodes.KEY_SHIFT || this.code === _keycodes.KEY_ALT;
    }

    return isModifierKey;
  }();

  _proto.isDown = function () {
    function isDown() {
      return this.type === 'keydown';
    }

    return isDown;
  }();

  _proto.isUp = function () {
    function isUp() {
      return this.type === 'keyup';
    }

    return isUp;
  }();

  _proto.toString = function () {
    function toString() {
      if (this._str) {
        return this._str;
      }

      this._str = '';

      if (this.ctrl) {
        this._str += 'Ctrl+';
      }

      if (this.alt) {
        this._str += 'Alt+';
      }

      if (this.shift) {
        this._str += 'Shift+';
      }

      if (this.code >= 48 && this.code <= 90) {
        this._str += String.fromCharCode(this.code);
      } else if (this.code >= _keycodes.KEY_F1 && this.code <= _keycodes.KEY_F12) {
        this._str += 'F' + (this.code - 111);
      } else {
        this._str += '[' + this.code + ']';
      }

      return this._str;
    }

    return toString;
  }();

  return KeyEvent;
}(); // IE8: Keydown event is only available on document.


exports.KeyEvent = KeyEvent;
document.addEventListener('keydown', function (e) {
  if (canStealFocus(e.target)) {
    return;
  }

  var code = e.keyCode;
  var key = new KeyEvent(e, 'keydown', keyHeldByCode[code]);
  globalEvents.emit('keydown', key);
  globalEvents.emit('key', key);
  keyHeldByCode[code] = true;
});
document.addEventListener('keyup', function (e) {
  if (canStealFocus(e.target)) {
    return;
  }

  var code = e.keyCode;
  var key = new KeyEvent(e, 'keyup');
  globalEvents.emit('keyup', key);
  globalEvents.emit('key', key);
  keyHeldByCode[code] = false;
});

/***/ }),

/***/ "./packages/tgui/logging.js":
/*!**********************************!*\
  !*** ./packages/tgui/logging.js ***!
  \**********************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.logger = exports.createLogger = void 0;

var _client = __webpack_require__(/*! tgui-dev-server/link/client */ "./packages/tgui-dev-server/link/client.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var LEVEL_DEBUG = 0;
var LEVEL_LOG = 1;
var LEVEL_INFO = 2;
var LEVEL_WARN = 3;
var LEVEL_ERROR = 4;

var _log = function log(level, ns) {
  for (var _len = arguments.length, args = new Array(_len > 2 ? _len - 2 : 0), _key = 2; _key < _len; _key++) {
    args[_key - 2] = arguments[_key];
  }

  // Send logs to a remote log collector
  if (true) {
    _client.sendLogEntry.apply(void 0, [level, ns].concat(args));
  } // Send important logs to the backend


  if (level >= LEVEL_INFO) {
    var logEntry = [ns].concat(args).map(function (value) {
      if (typeof value === 'string') {
        return value;
      }

      if (value instanceof Error) {
        return value.stack || String(value);
      }

      return JSON.stringify(value);
    }).filter(function (value) {
      return value;
    }).join(' ') + '\nUser Agent: ' + navigator.userAgent;
    Byond.topic({
      tgui: 1,
      window_id: window.__windowId__,
      type: 'log',
      ns: ns,
      message: logEntry
    });
  }
};

var createLogger = function createLogger(ns) {
  return {
    debug: function () {
      function debug() {
        for (var _len2 = arguments.length, args = new Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
          args[_key2] = arguments[_key2];
        }

        return _log.apply(void 0, [LEVEL_DEBUG, ns].concat(args));
      }

      return debug;
    }(),
    log: function () {
      function log() {
        for (var _len3 = arguments.length, args = new Array(_len3), _key3 = 0; _key3 < _len3; _key3++) {
          args[_key3] = arguments[_key3];
        }

        return _log.apply(void 0, [LEVEL_LOG, ns].concat(args));
      }

      return log;
    }(),
    info: function () {
      function info() {
        for (var _len4 = arguments.length, args = new Array(_len4), _key4 = 0; _key4 < _len4; _key4++) {
          args[_key4] = arguments[_key4];
        }

        return _log.apply(void 0, [LEVEL_INFO, ns].concat(args));
      }

      return info;
    }(),
    warn: function () {
      function warn() {
        for (var _len5 = arguments.length, args = new Array(_len5), _key5 = 0; _key5 < _len5; _key5++) {
          args[_key5] = arguments[_key5];
        }

        return _log.apply(void 0, [LEVEL_WARN, ns].concat(args));
      }

      return warn;
    }(),
    error: function () {
      function error() {
        for (var _len6 = arguments.length, args = new Array(_len6), _key6 = 0; _key6 < _len6; _key6++) {
          args[_key6] = arguments[_key6];
        }

        return _log.apply(void 0, [LEVEL_ERROR, ns].concat(args));
      }

      return error;
    }()
  };
};
/**
 * A generic instance of the logger.
 *
 * Does not have a namespace associated with it.
 */


exports.createLogger = createLogger;
var logger = createLogger();
exports.logger = logger;

/***/ }),

/***/ "./packages/tgui/renderer.ts":
/*!***********************************!*\
  !*** ./packages/tgui/renderer.ts ***!
  \***********************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.createRenderer = exports.suspendRenderer = exports.resumeRenderer = void 0;

var _perf = __webpack_require__(/*! common/perf */ "./packages/common/perf.js");

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _logging = __webpack_require__(/*! ./logging */ "./packages/tgui/logging.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var logger = (0, _logging.createLogger)('renderer');
var reactRoot;
var initialRender = true;
var suspended = false; // These functions are used purely for profiling.

var resumeRenderer = function resumeRenderer() {
  initialRender = initialRender || 'resumed';
  suspended = false;
};

exports.resumeRenderer = resumeRenderer;

var suspendRenderer = function suspendRenderer() {
  suspended = true;
};

exports.suspendRenderer = suspendRenderer;

var createRenderer = function createRenderer(getVNode) {
  return function () {
    _perf.perf.mark('render/start'); // Start rendering


    if (!reactRoot) {
      reactRoot = document.getElementById('react-root');
    }

    if (getVNode) {
      (0, _inferno.render)(getVNode.apply(void 0, arguments), reactRoot);
    } else {
      (0, _inferno.render)(arguments.length <= 0 ? undefined : arguments[0], reactRoot);
    }

    _perf.perf.mark('render/finish');

    if (suspended) {
      return;
    } // Report rendering time


    if (true) {
      if (initialRender === 'resumed') {
        logger.log('rendered in', _perf.perf.measure('render/start', 'render/finish'));
      } else if (initialRender) {
        logger.debug('serving from:', location.href);
        logger.debug('bundle entered in', _perf.perf.measure('inception', 'init'));
        logger.debug('initialized in', _perf.perf.measure('init', 'render/start'));
        logger.log('rendered in', _perf.perf.measure('render/start', 'render/finish'));
        logger.log('fully loaded in', _perf.perf.measure('inception', 'render/finish'));
      } else {
        logger.debug('rendered in', _perf.perf.measure('render/start', 'render/finish'));
      }
    }

    if (initialRender) {
      initialRender = false;
    }
  };
};

exports.createRenderer = createRenderer;

/***/ }),

/***/ "./packages/tgui/styles/main.scss":
/*!****************************************!*\
  !*** ./packages/tgui/styles/main.scss ***!
  \****************************************/
/***/ (function() {

// extracted by mini-css-extract-plugin

/***/ }),

/***/ "./packages/tgui-bench/tests sync \\.test\\.":
/*!***************************************************************!*\
  !*** ./packages/tgui-bench/tests/ sync nonrecursive \.test\. ***!
  \***************************************************************/
/***/ (function(module, __unused_webpack_exports, __webpack_require__) {

var map = {
	"./Button.test.tsx": "./packages/tgui-bench/tests/Button.test.tsx",
	"./Flex.test.tsx": "./packages/tgui-bench/tests/Flex.test.tsx",
	"./Stack.test.tsx": "./packages/tgui-bench/tests/Stack.test.tsx"
};


function webpackContext(req) {
	var id = webpackContextResolve(req);
	return __webpack_require__(id);
}
function webpackContextResolve(req) {
	if(!__webpack_require__.o(map, req)) {
		var e = new Error("Cannot find module '" + req + "'");
		e.code = 'MODULE_NOT_FOUND';
		throw e;
	}
	return map[req];
}
webpackContext.keys = function webpackContextKeys() {
	return Object.keys(map);
};
webpackContext.resolve = webpackContextResolve;
module.exports = webpackContext;
webpackContext.id = "./packages/tgui-bench/tests sync \\.test\\.";

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			id: moduleId,
/******/ 			loaded: false,
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = __webpack_modules__;
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/amd options */
/******/ 	!function() {
/******/ 		__webpack_require__.amdO = {};
/******/ 	}();
/******/ 	
/******/ 	/* webpack/runtime/chunk loaded */
/******/ 	!function() {
/******/ 		var deferred = [];
/******/ 		__webpack_require__.O = function(result, chunkIds, fn, priority) {
/******/ 			if(chunkIds) {
/******/ 				priority = priority || 0;
/******/ 				for(var i = deferred.length; i > 0 && deferred[i - 1][2] > priority; i--) deferred[i] = deferred[i - 1];
/******/ 				deferred[i] = [chunkIds, fn, priority];
/******/ 				return;
/******/ 			}
/******/ 			var notFulfilled = Infinity;
/******/ 			for (var i = 0; i < deferred.length; i++) {
/******/ 				var chunkIds = deferred[i][0];
/******/ 				var fn = deferred[i][1];
/******/ 				var priority = deferred[i][2];
/******/ 				var fulfilled = true;
/******/ 				for (var j = 0; j < chunkIds.length; j++) {
/******/ 					if ((priority & 1 === 0 || notFulfilled >= priority) && Object.keys(__webpack_require__.O).every(function(key) { return __webpack_require__.O[key](chunkIds[j]); })) {
/******/ 						chunkIds.splice(j--, 1);
/******/ 					} else {
/******/ 						fulfilled = false;
/******/ 						if(priority < notFulfilled) notFulfilled = priority;
/******/ 					}
/******/ 				}
/******/ 				if(fulfilled) {
/******/ 					deferred.splice(i--, 1)
/******/ 					result = fn();
/******/ 				}
/******/ 			}
/******/ 			return result;
/******/ 		};
/******/ 	}();
/******/ 	
/******/ 	/* webpack/runtime/global */
/******/ 	!function() {
/******/ 		__webpack_require__.g = (function() {
/******/ 			if (typeof globalThis === 'object') return globalThis;
/******/ 			try {
/******/ 				return this || new Function('return this')();
/******/ 			} catch (e) {
/******/ 				if (typeof window === 'object') return window;
/******/ 			}
/******/ 		})();
/******/ 	}();
/******/ 	
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	!function() {
/******/ 		__webpack_require__.o = function(obj, prop) { return Object.prototype.hasOwnProperty.call(obj, prop); }
/******/ 	}();
/******/ 	
/******/ 	/* webpack/runtime/node module decorator */
/******/ 	!function() {
/******/ 		__webpack_require__.nmd = function(module) {
/******/ 			module.paths = [];
/******/ 			if (!module.children) module.children = [];
/******/ 			return module;
/******/ 		};
/******/ 	}();
/******/ 	
/******/ 	/* webpack/runtime/jsonp chunk loading */
/******/ 	!function() {
/******/ 		// no baseURI
/******/ 		
/******/ 		// object to store loaded and loading chunks
/******/ 		// undefined = chunk not loaded, null = chunk preloaded/prefetched
/******/ 		// [resolve, reject, Promise] = chunk loading, 0 = chunk loaded
/******/ 		var installedChunks = {
/******/ 			"tgui-bench": 0
/******/ 		};
/******/ 		
/******/ 		// no chunk on demand loading
/******/ 		
/******/ 		// no prefetching
/******/ 		
/******/ 		// no preloaded
/******/ 		
/******/ 		// no HMR
/******/ 		
/******/ 		// no HMR manifest
/******/ 		
/******/ 		__webpack_require__.O.j = function(chunkId) { return installedChunks[chunkId] === 0; };
/******/ 		
/******/ 		// install a JSONP callback for chunk loading
/******/ 		var webpackJsonpCallback = function(parentChunkLoadingFunction, data) {
/******/ 			var chunkIds = data[0];
/******/ 			var moreModules = data[1];
/******/ 			var runtime = data[2];
/******/ 			// add "moreModules" to the modules object,
/******/ 			// then flag all "chunkIds" as loaded and fire callback
/******/ 			var moduleId, chunkId, i = 0;
/******/ 			for(moduleId in moreModules) {
/******/ 				if(__webpack_require__.o(moreModules, moduleId)) {
/******/ 					__webpack_require__.m[moduleId] = moreModules[moduleId];
/******/ 				}
/******/ 			}
/******/ 			if(runtime) runtime(__webpack_require__);
/******/ 			if(parentChunkLoadingFunction) parentChunkLoadingFunction(data);
/******/ 			for(;i < chunkIds.length; i++) {
/******/ 				chunkId = chunkIds[i];
/******/ 				if(__webpack_require__.o(installedChunks, chunkId) && installedChunks[chunkId]) {
/******/ 					installedChunks[chunkId][0]();
/******/ 				}
/******/ 				installedChunks[chunkIds[i]] = 0;
/******/ 			}
/******/ 			__webpack_require__.O();
/******/ 		}
/******/ 		
/******/ 		var chunkLoadingGlobal = self["webpackChunktgui_workspace"] = self["webpackChunktgui_workspace"] || [];
/******/ 		chunkLoadingGlobal.forEach(webpackJsonpCallback.bind(null, 0));
/******/ 		chunkLoadingGlobal.push = webpackJsonpCallback.bind(null, chunkLoadingGlobal.push.bind(chunkLoadingGlobal));
/******/ 	}();
/******/ 	
/************************************************************************/
/******/ 	
/******/ 	// startup
/******/ 	// Load entry module and return exports
/******/ 	// This entry module depends on other loaded chunks and execution need to be delayed
/******/ 	__webpack_require__.O(undefined, ["tgui-common"], function() { return __webpack_require__("./packages/tgui-polyfill/index.js"); })
/******/ 	var __webpack_exports__ = __webpack_require__.O(undefined, ["tgui-common"], function() { return __webpack_require__("./packages/tgui-bench/entrypoint.tsx"); })
/******/ 	__webpack_exports__ = __webpack_require__.O(__webpack_exports__);
/******/ 	
/******/ })()
;
//# sourceMappingURL=tgui-bench.bundle.js.map