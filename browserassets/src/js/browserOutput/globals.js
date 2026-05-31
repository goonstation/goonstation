/*
 * GLOBAL DECLARATIONS AND POLYFILLS
 */

var triggerError = attachErrorHandler('chatDebug', true);

var escaper = encodeURIComponent || escape;
var decoder = decodeURIComponent || unescape;

//Globals
window.status = 'Output';
var $messages,
  $subOptions,
  $contextMenu,
  $filterMessages,
  $playMusic,
  $lastEntry;
var opts = {
  //General
  messageCount: 0, //A count...of messages...
  messageLimit: 4000, //A limit...for the messages...
  scrollSnapTolerance: 20, //If within x pixels of bottom
  clickTolerance: 10, //Keep focus if outside x pixels of mousedown position on mouseup
  popups: 0, //Amount of popups opened ever
  wasd: false, //Is the user in wasd mode?
  chatMode: 'default', //The mode the chat is in
  priorChatHeight: 0, //Thing for height-resizing detection
  restarting: false, //Is the round restarting?
  volume: 0.5,
  lastMessage: '', //the last message sent to chatks
  maxStreakGrowth: 20, //at what streak point should we stop growing the last entry?
  messageClasses: ['admin', 'combat', 'radio', 'say', 'ooc', 'internal'],
  msgOdd: false, //Is the last message odd or even?
  reconnectTimeout: 0,

  //Options menu
  subOptionsLoop: null, //Contains the interval loop for closing the options menu
  suppressOptionsClose: false, //Whether or not we should be hiding the suboptions menu
  highlightTerms: [],
  highlightLimit: 10,
  highlightColor: '#FFFF00', //The color of the highlighted message
  pingDisabled: false, //Has the user disabled the ping counter
  messageLimitEnabled: true, // whether old messages get deleted
  oddMsgHighlight: false, // whether odd messages get highlighted

  //Ping display
  pingCounter: 0, //seconds counter
  pingLimit: 10, //seconds limit
  pingTime: 0, //Timestamp of when ping sent
  pongTime: 0, //Timestamp of when ping received
  noResponse: false, //Tracks the state of the previous ping request
  noResponseCount: 0, //How many failed pings?

  //Clicks
  mouseDownX: null,
  mouseDownY: null,
  preventFocus: false, //Prevents switching focus to the game window

  //Admin stuff
  adminLoaded: false, //Has the admin loaded his shit?

  //Client Connection Data
  clientDataLimit: 5,
  clientData: [],

  // Theme stuff
  currentTheme: 'theme-default',
};

var themes = {
  // "css-class": "Option name"
  'theme-default': 'Windows 3.1 (default)',
  'theme-dark': 'Dark',
};

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
