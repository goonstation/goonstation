'use strict';

function initContent(io) {
  io.println('test');
}

function setupHterm() {
  // We don't mark it local so people can play with it in the dev console.
  var term = new hterm.Terminal();

  term.onTerminalReady = function () {
    var io = this.io.push();
    function printPrompt() {
      io.print(
        '\x1B[38;2;51;105;232mh' +
          '\x1B[38;2;213;15;37mt' +
          '\x1B[38;2;238;178;17me' +
          '\x1B[38;2;51;105;232mr' +
          '\x1B[38;2;0;153;37mm' +
          '\x1B[38;2;213;15;37m>' +
          '\x1B[0m '
      );
    }

    io.onVTKeystroke = function (string) {
      switch (string) {
        case '\r':
          io.println('\r\nerror: command not found');
          printPrompt();
          break;
        default:
          io.print(string);
          break;
      }
    };
    io.sendString = io.print;
    initContent(io);
    printPrompt();
    this.setCursorVisible(true);

    this.keyboard.bindings.addBinding('F11', 'PASS');
    this.keyboard.bindings.addBinding('Ctrl-R', 'PASS');
  };
  term.decorate(document.querySelector('#terminal'));
  term.installKeyboard();

  // Useful for console debugging.
  window.term_ = term;
}

window.onload = function () {
  lib.init(setupHterm);
  hterm.defaultStorage = new lib.Storage.Memory();
  setupHterm();
};
