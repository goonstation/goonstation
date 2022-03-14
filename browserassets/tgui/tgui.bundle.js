/******/ (function() { // webpackBootstrap
/******/ 	var __webpack_modules__ = ({

/***/ "./packages/common/bem.ts":
/*!********************************!*\
  !*** ./packages/common/bem.ts ***!
  \********************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.modifier = exports.element = exports.block = void 0;

/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */
var block = function block(base, suffix) {
  return base + "-" + suffix;
};

exports.block = block;

var element = function element(block, _element) {
  return block + "__" + _element;
};

exports.element = element;

var modifier = function modifier(element, _modifier) {
  return element + "--" + _modifier;
};

exports.modifier = modifier;

/***/ }),

/***/ "./packages/tgui/index.js":
/*!********************************!*\
  !*** ./packages/tgui/index.js ***!
  \********************************/
/***/ (function(__unused_webpack_module, __unused_webpack_exports, __webpack_require__) {

"use strict";


var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

__webpack_require__(/*! ./styles/main.scss */ "./packages/tgui/styles/main.scss");

__webpack_require__(/*! ./styles/themes/genetek.scss */ "./packages/tgui/styles/themes/genetek.scss");

__webpack_require__(/*! ./styles/themes/genetek-disabled.scss */ "./packages/tgui/styles/themes/genetek-disabled.scss");

__webpack_require__(/*! ./styles/themes/ntos.scss */ "./packages/tgui/styles/themes/ntos.scss");

__webpack_require__(/*! ./styles/themes/paper.scss */ "./packages/tgui/styles/themes/paper.scss");

__webpack_require__(/*! ./styles/themes/retro-dark.scss */ "./packages/tgui/styles/themes/retro-dark.scss");

__webpack_require__(/*! ./styles/themes/syndicate.scss */ "./packages/tgui/styles/themes/syndicate.scss");

__webpack_require__(/*! ./styles/themes/flock.scss */ "./packages/tgui/styles/themes/flock.scss");

var _perf = __webpack_require__(/*! common/perf */ "./packages/common/perf.js");

var _client = __webpack_require__(/*! tgui-dev-server/link/client */ "./packages/tgui-dev-server/link/client.js");

var _hotkeys = __webpack_require__(/*! ./hotkeys */ "./packages/tgui/hotkeys.ts");

var _links = __webpack_require__(/*! ./links */ "./packages/tgui/links.js");

var _renderer = __webpack_require__(/*! ./renderer */ "./packages/tgui/renderer.js");

var _store = __webpack_require__(/*! ./store */ "./packages/tgui/store.js");

var _events = __webpack_require__(/*! ./events */ "./packages/tgui/events.js");

var _window$performance, _window$performance$t;

_perf.perf.mark('inception', (_window$performance = window.performance) == null ? void 0 : (_window$performance$t = _window$performance.timing) == null ? void 0 : _window$performance$t.navigationStart);

_perf.perf.mark('init');

var store = (0, _store.configureStore)();
var renderApp = (0, _renderer.createRenderer)(function () {
  var _require = __webpack_require__(/*! ./routes */ "./packages/tgui/routes.js"),
      getRoutedComponent = _require.getRoutedComponent;

  var Component = getRoutedComponent(store);
  return (0, _inferno.createComponentVNode)(2, _store.StoreProvider, {
    "store": store,
    children: (0, _inferno.createComponentVNode)(2, Component)
  });
});

var setupApp = function setupApp() {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  (0, _events.setupGlobalEvents)();
  (0, _hotkeys.setupHotKeys)();
  (0, _links.captureExternalLinks)(); // Subscribe for state updates

  store.subscribe(renderApp); // Dispatch incoming messages

  window.update = function (msg) {
    return store.dispatch(Byond.parseJson(msg));
  }; // Process the early update queue


  while (true) {
    var msg = window.__updateQueue__.shift();

    if (!msg) {
      break;
    }

    window.update(msg);
  } // Enable hot module reloading


  if (false) {}
};

setupApp();

/***/ }),

/***/ "./packages/tgui/interfaces/AIMap.js":
/*!*******************************************!*\
  !*** ./packages/tgui/interfaces/AIMap.js ***!
  \*******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.AIMap = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var AIMap = function AIMap(params, context) {
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 610,
    "height": 640,
    "title": "AI station map",
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: (0, _inferno.createComponentVNode)(2, _components.ByondUi, {
        "params": {
          type: 'map',
          id: "ai_map"
        },
        "style": {
          width: "600px",
          height: "600px"
        }
      })
    })
  });
};

exports.AIMap = AIMap;

/***/ }),

/***/ "./packages/tgui/interfaces/Airlock.js":
/*!*********************************************!*\
  !*** ./packages/tgui/interfaces/Airlock.js ***!
  \*********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.AccessPanel = exports.Airlock = exports.uiCurrentUserPermissions = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _format = __webpack_require__(/*! ../format */ "./packages/tgui/format.js");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

/**
* @file
* @copyright 2020
* @author ThePotato97 (https://github.com/ThePotato97)
* @license ISC
*/
var uiCurrentUserPermissions = function uiCurrentUserPermissions(data) {
  var panelOpen = data.panelOpen,
      userStates = data.userStates;
  return {
    // can only access airlock if they're AI or a borg.
    airlock: userStates.isBorg || userStates.isAi,

    /** borgs can only access panel when they're next to the airlock
    * carbons are checked on the backend so no need to check their distance here
    * so we'll return true
    */
    accessPanel: userStates.isBorg && userStates.distance <= 1 && panelOpen || panelOpen && !userStates.isBorg && !userStates.isAi
  };
};

exports.uiCurrentUserPermissions = uiCurrentUserPermissions;

var Airlock = function Airlock(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data;

  var userPerms = uiCurrentUserPermissions(data); //  We render 3 different interfaces so we can change the window sizes

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "theme": "ntos",
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: [!userPerms["airlock"] && !userPerms["accessPanel"] && (0, _inferno.createComponentVNode)(2, _components.Modal, {
        "textAlign": "center",
        "fontSize": "24px",
        children: (0, _inferno.createComponentVNode)(2, _components.Box, {
          "width": 25,
          "height": 5,
          "align": "center",
          children: "Access Panel is Closed"
        })
      }), !!userPerms["airlock"] && !!userPerms["accessPanel"] && (0, _inferno.createComponentVNode)(2, AirlockAndAccessPanel) || !!userPerms["airlock"] && (0, _inferno.createComponentVNode)(2, AirlockControlsOnly) || !!userPerms["accessPanel"] && (0, _inferno.createComponentVNode)(2, AccessPanelOnly)]
    })
  });
};

exports.Airlock = Airlock;

var AirlockAndAccessPanel = function AirlockAndAccessPanel(props, context) {
  var _useBackend2 = (0, _backend.useBackend)(context),
      data = _useBackend2.data;

  var name = data.name,
      canAiControl = data.canAiControl,
      hackMessage = data.hackMessage,
      canAiHack = data.canAiHack,
      noPower = data.noPower;

  var _useLocalState = (0, _backend.useLocalState)(context, 'tabIndex', 1),
      tabIndex = _useLocalState[0],
      setTabIndex = _useLocalState[1];

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 354,
    "height": 495,
    "title": "Airlock - " + (0, _format.truncate)(name, 19),
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Tabs, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
          "selected": tabIndex === 1,
          "onClick": function () {
            function onClick() {
              setTabIndex(1);
            }

            return onClick;
          }(),
          children: "Airlock Controls"
        }), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
          "selected": tabIndex === 2,
          "onClick": function () {
            function onClick() {
              setTabIndex(2);
            }

            return onClick;
          }(),
          children: "Access Panel"
        })]
      }), tabIndex === 1 && (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Section, {
        "fitted": true,
        "backgroundColor": "transparent",
        children: [(!canAiControl || !!noPower) && (0, _inferno.createComponentVNode)(2, _components.Modal, {
          "textAlign": "center",
          "fontSize": "24px",
          children: (0, _inferno.createComponentVNode)(2, _components.Box, {
            "width": 20,
            "height": 5,
            "algin": "center",
            children: hackMessage ? hackMessage : "Airlock Controls Disabled"
          })
        }), (0, _inferno.createComponentVNode)(2, PowerStatus), (0, _inferno.createComponentVNode)(2, AccessAndDoorControl), (0, _inferno.createComponentVNode)(2, Electrify)]
      }), !!canAiHack && (0, _inferno.createComponentVNode)(2, Hack)], 0), tabIndex === 2 && (0, _inferno.createComponentVNode)(2, AccessPanel)]
    })
  });
};

var AirlockControlsOnly = function AirlockControlsOnly(props, context) {
  var _useBackend3 = (0, _backend.useBackend)(context),
      data = _useBackend3.data;

  var name = data.name,
      canAiControl = data.canAiControl,
      hackMessage = data.hackMessage,
      canAiHack = data.canAiHack,
      noPower = data.noPower;
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 315,
    "height": 380,
    "title": "Airlock - " + (0, _format.truncate)(name, 19),
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: [(!canAiControl || !!noPower) && (0, _inferno.createComponentVNode)(2, _components.Modal, {
        "textAlign": "center",
        "fontSize": "26px",
        children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
          "width": 20,
          "height": 5,
          "algin": "center",
          children: hackMessage ? hackMessage : "Airlock Controls Disabled"
        }), !!canAiHack && (0, _inferno.createComponentVNode)(2, Hack)]
      }), (0, _inferno.createComponentVNode)(2, PowerStatus), (0, _inferno.createComponentVNode)(2, AccessAndDoorControl), (0, _inferno.createComponentVNode)(2, Electrify)]
    })
  });
};

var AccessPanelOnly = function AccessPanelOnly(props, context) {
  var _useBackend4 = (0, _backend.useBackend)(context),
      data = _useBackend4.data;

  var name = data.name;
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 354,
    "height": 465,
    "title": "Airlock - " + (0, _format.truncate)(name, 19),
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: (0, _inferno.createComponentVNode)(2, AccessPanel)
    })
  });
};

var PowerStatus = function PowerStatus(props, context) {
  var _useBackend5 = (0, _backend.useBackend)(context),
      act = _useBackend5.act,
      data = _useBackend5.data;

  var mainTimeLeft = data.mainTimeLeft,
      backupTimeLeft = data.backupTimeLeft,
      wires = data.wires,
      netId = data.netId,
      accessCode = data.accessCode;
  var buttonProps = {
    width: 6.7,
    textAlign: "center"
  };
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Power Status",
    children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
      children: ["Access sensor reports the net identifer is:", " ", (0, _inferno.createComponentVNode)(2, _components.Box, {
        "inline": true,
        "italic": true,
        children: netId
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      children: ["Net access code:", " ", (0, _inferno.createComponentVNode)(2, _components.Box, {
        "inline": true,
        "italic": true,
        children: accessCode
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Main",
        "color": mainTimeLeft ? "bad" : "good",
        "buttons": (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _components.Button, Object.assign({}, buttonProps, {
          "color": "bad",
          "icon": "plug",
          "disabled": !!mainTimeLeft,
          "onClick": function () {
            function onClick() {
              return act("disruptMain");
            }

            return onClick;
          }(),
          children: "Disrupt"
        }))),
        children: [mainTimeLeft ? "Offline" : "Online", " ", (!wires.main_1 || !wires.main_2) && "[Wires cut!]" || mainTimeLeft > 0 && "[" + mainTimeLeft + "s]"]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Backup",
        "color": backupTimeLeft ? "bad" : "good",
        "buttons": (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _components.Button, Object.assign({}, buttonProps, {
          "mt": 0.5,
          "color": "bad",
          "icon": "plug",
          "disabled": !!backupTimeLeft,
          "onClick": function () {
            function onClick() {
              return act("disruptBackup");
            }

            return onClick;
          }(),
          children: "Disrupt"
        }))),
        children: [backupTimeLeft ? "Offline" : "Online", " ", (!wires.backup_1 || !wires.backup_2) && "[Wires cut!]" || backupTimeLeft > 0 && "[" + backupTimeLeft + "s]"]
      })]
    })]
  });
};

var AccessAndDoorControl = function AccessAndDoorControl(props, context) {
  var _useBackend6 = (0, _backend.useBackend)(context),
      act = _useBackend6.act,
      data = _useBackend6.data;

  var mainTimeLeft = data.mainTimeLeft,
      backupTimeLeft = data.backupTimeLeft,
      wires = data.wires,
      idScanner = data.idScanner,
      boltsAreUp = data.boltsAreUp,
      opened = data.opened,
      welded = data.welded;
  var buttonProps = {
    width: 6.7,
    textAlign: "center"
  };
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Access and Door Control",
    "pt": 1,
    children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "ID Scan",
        "color": "bad",
        "buttons": (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _components.Button, Object.assign({}, buttonProps, {
          "color": idScanner ? "good" : "bad",
          "icon": idScanner ? "power-off" : "times",
          "disabled": !wires.idScanner || mainTimeLeft && backupTimeLeft,
          "onClick": function () {
            function onClick() {
              return act("idScanToggle");
            }

            return onClick;
          }(),
          children: idScanner ? "Enabled" : "Disabled"
        }))),
        children: !wires.idScanner && "[Wires cut!]"
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Door Bolts",
        "color": "bad",
        "buttons": (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _components.Button, Object.assign({
          "mt": 0.5
        }, buttonProps, {
          "color": !boltsAreUp ? "bad" : "good",
          "icon": !boltsAreUp ? "unlock" : "lock",
          "disabled": !wires.bolts || mainTimeLeft && backupTimeLeft,
          "onClick": function () {
            function onClick() {
              return act("boltToggle");
            }

            return onClick;
          }(),
          children: !boltsAreUp ? "Lowered" : "Raised"
        }))),
        children: !wires.bolts && "[Wires cut!]"
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Door Control",
        "color": "bad",
        "buttons": (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _components.Button, Object.assign({}, buttonProps, {
          "mt": 0.5,
          "color": opened ? "bad" : "good",
          "icon": opened ? "sign-out-alt" : "sign-in-alt",
          "disabled": !boltsAreUp || welded || mainTimeLeft && backupTimeLeft,
          "onClick": function () {
            function onClick() {
              return act("openClose");
            }

            return onClick;
          }(),
          children: opened ? "Open" : "Closed"
        }))),
        children: !!(!boltsAreUp || welded) && (0, _inferno.createVNode)(1, "span", null, [(0, _inferno.createTextVNode)("["), !boltsAreUp && "Bolted", !boltsAreUp && welded && " & ", welded && "Welded", (0, _inferno.createTextVNode)("!]")], 0)
      })]
    })
  });
};

var Electrify = function Electrify(props, context) {
  var _useBackend7 = (0, _backend.useBackend)(context),
      act = _useBackend7.act,
      data = _useBackend7.data;

  var mainTimeLeft = data.mainTimeLeft,
      backupTimeLeft = data.backupTimeLeft,
      wires = data.wires,
      shockTimeLeft = data.shockTimeLeft;
  return (0, _inferno.createComponentVNode)(2, _components.NoticeBox, {
    "backgroundColor": "#601B1B",
    children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "labelColor": "white",
        "color": shockTimeLeft ? "average" : "good",
        "label": "Electrify",
        children: [!shockTimeLeft ? "Safe" : "Electrified", " ", !wires.shock && "[Wires cut!]" || shockTimeLeft > 0 && "[" + shockTimeLeft + "s]" || shockTimeLeft === -1 && "[Permanent]"]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "color": !shockTimeLeft ? "Average" : "Bad",
        children: (0, _inferno.createComponentVNode)(2, _components.Box, {
          "pl": shockTimeLeft ? 18 : 0,
          "pt": 0.5,
          children: [!shockTimeLeft && (0, _inferno.createComponentVNode)(2, _components.Button.Confirm, {
            "width": 9,
            "p": 0.5,
            "align": "center",
            "color": "average",
            "content": "Temporary",
            "confirmContent": "Are you sure?",
            "icon": "bolt",
            "disabled": !wires.shock || mainTimeLeft && backupTimeLeft,
            "onClick": function () {
              function onClick() {
                return act("shockTemp");
              }

              return onClick;
            }()
          }), (0, _inferno.createComponentVNode)(2, _components.Button.Confirm, {
            "width": 9,
            "p": 0.5,
            "align": "center",
            "color": shockTimeLeft ? "good" : "bad",
            "icon": "bolt",
            "confirmContent": "Are you sure?",
            "content": shockTimeLeft ? "Restore" : "Permanent",
            "disabled": !wires.shock || mainTimeLeft && backupTimeLeft,
            "onClick": shockTimeLeft ? function () {
              return act("shockRestore");
            } : function () {
              return act("shockPerm");
            }
          })]
        })
      })]
    })
  });
};

var Hack = function Hack(props, context) {
  var _useBackend8 = (0, _backend.useBackend)(context),
      act = _useBackend8.act,
      data = _useBackend8.data;

  var aiHacking = data.aiHacking,
      hackingProgression = data.hackingProgression;
  return (0, _inferno.createComponentVNode)(2, _components.Box, {
    "fitted": true,
    "py": 0.5,
    "pt": 2,
    "align": "center",
    children: [!aiHacking && (0, _inferno.createComponentVNode)(2, _components.Button, {
      "className": "Airlock-hack-button",
      "fontSize": "29px",
      "backgroundColor": "#00FF00",
      "disabled": aiHacking,
      "textColor": "black",
      "textAlign": "center",
      "width": 16,
      "onClick": function () {
        function onClick() {
          return act("hackAirlock");
        }

        return onClick;
      }(),
      children: "HACK"
    }), !!aiHacking && (0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
      "ranges": {
        good: [6, Infinity],
        average: [2, 5],
        bad: [-Infinity, 1]
      },
      "minValue": 0,
      "maxValue": 6,
      "value": hackingProgression
    })]
  });
};

var AccessPanel = function AccessPanel(props, context) {
  var _useBackend9 = (0, _backend.useBackend)(context),
      act = _useBackend9.act,
      data = _useBackend9.data;

  var signalers = data.signalers,
      wireColors = data.wireColors,
      wireStates = data.wireStates,
      netId = data.netId,
      powerIsOn = data.powerIsOn,
      boltsAreUp = data.boltsAreUp,
      canAiControl = data.canAiControl,
      aiControlVar = data.aiControlVar,
      safety = data.safety,
      panelOpen = data.panelOpen,
      accessCode = data.accessCode;

  var handleWireInteract = function handleWireInteract(wireColorIndex, action) {
    act(action, {
      wireColorIndex: wireColorIndex
    });
  };

  var wires = Object.keys(wireColors);
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Access Panel",
    children: [!panelOpen && (0, _inferno.createComponentVNode)(2, _components.Modal, {
      "textAlign": "center",
      "fontSize": "24px",
      children: "Access Panel is Closed"
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      children: ["An identifier is engraved under the airlock's card sensors:", " ", (0, _inferno.createComponentVNode)(2, _components.Box, {
        "inline": true,
        "italic": true,
        children: netId
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      children: ["A display shows net access code:", " ", (0, _inferno.createComponentVNode)(2, _components.Box, {
        "inline": true,
        "italic": true,
        children: accessCode
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: wires.map(function (entry, i) {
        return (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": entry + " wire",
          "labelColor": entry.toLowerCase(),
          children: !wireStates[i] ? (0, _inferno.createComponentVNode)(2, _components.Box, {
            "height": 1.8,
            children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": "cut",
              "onClick": function () {
                function onClick() {
                  return handleWireInteract(i, "cut");
                }

                return onClick;
              }(),
              children: "Cut"
            }), (0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": "bolt",
              "onClick": function () {
                function onClick() {
                  return handleWireInteract(i, "pulse");
                }

                return onClick;
              }(),
              children: "Pulse"
            }), (0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": "broadcast-tower",
              "width": 10.5,
              "className": "AccessPanel-wires-btn",
              "selected": signalers[i],
              "onClick": function () {
                function onClick() {
                  return handleWireInteract(i, "signaler");
                }

                return onClick;
              }(),
              children: !signalers[i] ? "Attach Signaler" : "Detach Signaler"
            })]
          }) : (0, _inferno.createComponentVNode)(2, _components.Button, {
            "color": "green",
            "height": 1.8,
            "onClick": function () {
              function onClick() {
                return handleWireInteract(i, "mend");
              }

              return onClick;
            }(),
            children: "Mend"
          })
        }, entry);
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.Flex, {
      "direction": "row",
      children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Door bolts",
            "color": boltsAreUp ? "green" : "red",
            children: boltsAreUp ? "Disengaged" : "Engaged"
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Test light",
            "color": powerIsOn ? "green" : "red",
            children: powerIsOn ? "Active" : "Inactive"
          })]
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "AI control",
            "color": canAiControl ? aiControlVar === 2 ? "orange" : "green" : "red",
            children: canAiControl ? "Enabled" : "Disabled"
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Safety light",
            "color": safety ? "green" : "red",
            children: safety ? "Active" : "Inactive"
          })]
        })
      })]
    })]
  });
};

exports.AccessPanel = AccessPanel;

/***/ }),

/***/ "./packages/tgui/interfaces/AlertModal.js":
/*!************************************************!*\
  !*** ./packages/tgui/interfaces/AlertModal.js ***!
  \************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Loader = exports.AlertModal = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var _keycodes = __webpack_require__(/*! common/keycodes */ "./packages/common/keycodes.js");

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var AlertModal = /*#__PURE__*/function (_Component) {
  _inheritsLoose(AlertModal, _Component);

  function AlertModal() {
    var _this;

    _this = _Component.call(this) || this;
    _this.buttonRefs = [(0, _inferno.createRef)()];
    _this.state = {
      current: 0
    };
    return _this;
  }

  var _proto = AlertModal.prototype;

  _proto.componentDidMount = function () {
    function componentDidMount() {
      var _useBackend = (0, _backend.useBackend)(this.context),
          data = _useBackend.data;

      var buttons = data.buttons;
      var current = this.state.current;
      var button = this.buttonRefs[current].current; // Fill ref array with refs for other buttons

      for (var i = 1; i < buttons.length; i++) {
        this.buttonRefs.push((0, _inferno.createRef)());
      }

      setTimeout(function () {
        return button.focus();
      }, 1);
    }

    return componentDidMount;
  }();

  _proto.setCurrent = function () {
    function setCurrent(current, isArrowKey) {
      var _useBackend2 = (0, _backend.useBackend)(this.context),
          data = _useBackend2.data;

      var buttons = data.buttons; // Mimic alert() behavior for tabs and arrow keys

      if (current >= buttons.length) {
        current = isArrowKey ? current - 1 : 0;
      } else if (current < 0) {
        current = isArrowKey ? 0 : buttons.length - 1;
      }

      var button = this.buttonRefs[current].current; // Prevents an error from occurring on close

      if (button) {
        setTimeout(function () {
          return button.focus();
        }, 1);
      }

      this.setState({
        current: current
      });
    }

    return setCurrent;
  }();

  _proto.render = function () {
    function render() {
      var _this2 = this;

      var _useBackend3 = (0, _backend.useBackend)(this.context),
          act = _useBackend3.act,
          data = _useBackend3.data;

      var title = data.title,
          message = data.message,
          buttons = data.buttons,
          timeout = data.timeout;
      var current = this.state.current;

      var focusCurrentButton = function () {
        function focusCurrentButton() {
          return _this2.setCurrent(current, false);
        }

        return focusCurrentButton;
      }();

      return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
        "title": title,
        "width": 350,
        "height": 150,
        children: [timeout && (0, _inferno.createComponentVNode)(2, Loader, {
          "value": timeout
        }), (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
          "onFocus": focusCurrentButton,
          "onClick": focusCurrentButton,
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "fill": true,
            children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
              "direction": "column",
              "height": "100%",
              children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                "grow": 1,
                children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
                  "direction": "column",
                  "className": "AlertModal__Message",
                  "height": "100%",
                  children: (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                    children: (0, _inferno.createComponentVNode)(2, _components.Box, {
                      "m": 1,
                      children: message
                    })
                  })
                })
              }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                "my": 8,
                children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
                  "className": "AlertModal__Buttons",
                  children: buttons.map(function (button, buttonIndex) {
                    return (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                      "mx": 1,
                      children: (0, _inferno.createVNode)(1, "div", "Button Button--color--default", button, 0, {
                        "px": 3,
                        "onClick": function () {
                          function onClick() {
                            return act("choose", {
                              choice: button
                            });
                          }

                          return onClick;
                        }(),
                        "onKeyDown": function () {
                          function onKeyDown(e) {
                            var keyCode = window.event ? e.which : e.keyCode;
                            /**
                              * Simulate a click when pressing space or enter,
                              * allow keyboard navigation, override tab behavior
                              */

                            if (keyCode === _keycodes.KEY_SPACE || keyCode === _keycodes.KEY_ENTER) {
                              act("choose", {
                                choice: button
                              });
                            } else if (keyCode === _keycodes.KEY_LEFT || e.shiftKey && keyCode === _keycodes.KEY_TAB) {
                              _this2.setCurrent(current - 1, keyCode === _keycodes.KEY_LEFT);
                            } else if (keyCode === _keycodes.KEY_RIGHT || keyCode === _keycodes.KEY_TAB) {
                              _this2.setCurrent(current + 1, keyCode === _keycodes.KEY_RIGHT);
                            }
                          }

                          return onKeyDown;
                        }()
                      }, null, _this2.buttonRefs[buttonIndex])
                    }, buttonIndex);
                  })
                })
              })]
            })
          })
        })]
      });
    }

    return render;
  }();

  return AlertModal;
}(_inferno.Component);

exports.AlertModal = AlertModal;

var Loader = function Loader(props) {
  var value = props.value;
  return (0, _inferno.createVNode)(1, "div", "AlertModal__Loader", (0, _inferno.createComponentVNode)(2, _components.Box, {
    "className": "AlertModal__LoaderProgress",
    "style": {
      width: (0, _math.clamp01)(value) * 100 + '%'
    }
  }), 2);
};

exports.Loader = Loader;

/***/ }),

/***/ "./packages/tgui/interfaces/ArtifactPaper.js":
/*!***************************************************!*\
  !*** ./packages/tgui/interfaces/ArtifactPaper.js ***!
  \***************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ArtifactPaper = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

/**
 * @file
 * @copyright 2021
 * @author zjdtmkhzt (https://github.com/zjdtmkhzt)
 * @license MIT
 */
var ArtifactPaper = function ArtifactPaper(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var artifactName = data.artifactName,
      artifactOrigin = data.artifactOrigin,
      artifactType = data.artifactType,
      artifactTriggers = data.artifactTriggers,
      artifactFaults = data.artifactFaults,
      artifactDetails = data.artifactDetails,
      allArtifactOrigins = data.allArtifactOrigins,
      allArtifactTypes = data.allArtifactTypes,
      allArtifactTriggers = data.allArtifactTriggers,
      hasPen = data.hasPen;
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "title": "Nanotrasen Alien Artifact Analysis Form",
    "theme": "paper",
    "width": 800,
    "height": 835,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: (0, _inferno.createComponentVNode)(2, _components.Section, {
        children: [(0, _inferno.createVNode)(1, "h3", null, "Artifact Name", 16), (0, _inferno.createVNode)(1, "h4", null, artifactName === "" ? "unknown" : artifactName, 0), (0, _inferno.createVNode)(1, "h3", null, "Artifact Origin", 16), (0, _inferno.createComponentVNode)(2, _components.Flex, {
          "direction": "column",
          "wrap": "wrap",
          "height": 3,
          children: allArtifactOrigins.map(function (x) {
            return (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
              "onClick": function () {
                function onClick(e, value) {
                  return act("origin", {
                    newOrigin: x,
                    hasPen: hasPen
                  });
                }

                return onClick;
              }(),
              children: [(0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
                "checked": artifactOrigin === x
              }), (0, _inferno.createVNode)(1, "a", null, x, 0)]
            }, x.id);
          })
        }), (0, _inferno.createVNode)(1, "h3", null, "Artifact Type", 16), (0, _inferno.createComponentVNode)(2, _components.Flex, {
          "direction": "column",
          "wrap": "wrap",
          "height": 25,
          "justify": "space-evenly",
          children: allArtifactTypes.map(function (x) {
            return (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
              "className": "artifactType" + x[1],
              "onClick": function () {
                function onClick(e, value) {
                  return act("type", {
                    newType: x[0],
                    hasPen: hasPen
                  });
                }

                return onClick;
              }(),
              children: [(0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
                "checked": artifactType === x[0]
              }), (0, _inferno.createVNode)(1, "a", null, x[0], 0)]
            }, x[0].id);
          })
        }), (0, _inferno.createVNode)(1, "h3", null, "Artifact Triggers", 16), (0, _inferno.createComponentVNode)(2, _components.Flex, {
          "direction": "column",
          "wrap": "wrap",
          "height": 5,
          children: allArtifactTriggers.map(function (x) {
            return (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
              "onClick": function () {
                function onClick(e, value) {
                  return act("trigger", {
                    newTriggers: x,
                    hasPen: hasPen
                  });
                }

                return onClick;
              }(),
              children: [(0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
                "checked": artifactTriggers === x
              }), (0, _inferno.createVNode)(1, "a", null, x, 0)]
            }, x.id);
          })
        }), (0, _inferno.createVNode)(1, "h3", null, "Artifact Faults", 16), (0, _inferno.createComponentVNode)(2, _components.TextArea, {
          "value": artifactFaults,
          "fluid": true,
          "height": 5,
          "onChange": function () {
            function onChange(_, x) {
              return act("fault", {
                newFaults: x,
                hasPen: hasPen
              });
            }

            return onChange;
          }()
        }), (0, _inferno.createVNode)(1, "h3", null, "Additional Information", 16), (0, _inferno.createComponentVNode)(2, _components.TextArea, {
          "value": artifactDetails,
          "fluid": true,
          "height": 10,
          "onChange": function () {
            function onChange(_, x) {
              return act("detail", {
                newDetail: x,
                hasPen: hasPen
              });
            }

            return onChange;
          }()
        })]
      })
    })
  });
};

exports.ArtifactPaper = ArtifactPaper;

/***/ }),

/***/ "./packages/tgui/interfaces/BarcodeComputer.js":
/*!*****************************************************!*\
  !*** ./packages/tgui/interfaces/BarcodeComputer.js ***!
  \*****************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.BarcodeComputer = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var BarcodeComputerSection = function BarcodeComputerSection(props, context) {
  var title = props.title,
      destinations = props.destinations,
      act = props.act,
      amount = props.amount;
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": title,
    children: destinations.map(function (destination) {
      var crate_tag = destination.crate_tag,
          name = destination.name;
      return (0, _inferno.createComponentVNode)(2, _components.Button, {
        "width": "100%",
        "align": "center",
        "content": name ? name : crate_tag,
        "onClick": function () {
          function onClick() {
            return act('print', {
              crate_tag: crate_tag,
              amount: amount
            });
          }

          return onClick;
        }()
      }, crate_tag);
    })
  });
};

var IDCard = function IDCard(props, context) {
  if (!props.card) {
    return;
  }

  var card = props.card,
      act = props.act;
  return (0, _inferno.createComponentVNode)(2, _components.Button, {
    "icon": "eject",
    "content": card.name + (" (" + card.role + ")"),
    "tooltip": "Clear scanned card",
    "tooltipPosition": "bottom-end",
    "onClick": function () {
      function onClick() {
        act("reset_id");
      }

      return onClick;
    }()
  });
};

var BarcodeComputer = function BarcodeComputer(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var sections = data.sections,
      card = data.card;

  var _useLocalState = (0, _backend.useLocalState)(context, 'amount', 1),
      amount = _useLocalState[0],
      setAmount = _useLocalState[1];

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "title": "Barcode computer",
    "width": 600,
    "height": 450,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      "scrollable": true,
      children: [(0, _inferno.createComponentVNode)(2, _components.Stack, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          "grow": 1,
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "title": "Amount to print",
            "fill": true,
            children: (0, _inferno.createComponentVNode)(2, _components.Box, {
              "align": "center",
              children: (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
                "value": amount,
                "minValue": 1,
                "maxValue": 5,
                "stepPixelSize": 15,
                "unit": "Barcodes",
                "onDrag": function () {
                  function onDrag(e, value) {
                    return setAmount(value);
                  }

                  return onDrag;
                }()
              })
            })
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          "grow": 1,
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "title": "Scanned ID card",
            "fill": true,
            children: (0, _inferno.createComponentVNode)(2, _components.Box, {
              "align": "center",
              children: [(0, _inferno.createComponentVNode)(2, IDCard, {
                "card": card,
                "act": act
              }), (0, _inferno.createVNode)(1, "br"), card ? "Account balance: $" + card.balance : null]
            })
          })
        })]
      }), (0, _inferno.createVNode)(1, "br"), (0, _inferno.createComponentVNode)(2, _components.Stack, {
        children: sections.map(function (section) {
          var title = section.title,
              destinations = section.destinations;
          return (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
            "width": "33%",
            children: (0, _inferno.createComponentVNode)(2, BarcodeComputerSection, {
              "title": title,
              "destinations": destinations,
              "act": act,
              "amount": amount
            })
          }, title);
        })
      })]
    })
  });
};

exports.BarcodeComputer = BarcodeComputer;

/***/ }),

/***/ "./packages/tgui/interfaces/BugReportForm.js":
/*!***************************************************!*\
  !*** ./packages/tgui/interfaces/BugReportForm.js ***!
  \***************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.BugReportForm = exports.InputTitle = exports.Textarea = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _Button = __webpack_require__(/*! ../components/Button */ "./packages/tgui/components/Button.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

/**
 * @file
 * @copyright 2022 pali (https://github.com/pali6)
 * @license MIT
 */
var Textarea = function Textarea(props, context) {
  return (0, _inferno.createVNode)(128, "textarea", null, props.defaultText, 0, {
    "rows": 4,
    "style": {
      "overflow-y": "hidden",
      "width": "100%",
      "background-color": "black",
      "border": "solid 1px #6992c2",
      "color": "white"
    },
    "onInput": function () {
      function onInput(e) {
        e.target.style.height = "auto";
        e.target.style.height = e.target.scrollHeight + "px";
      }

      return onInput;
    }(),
    "id": props.id,
    "placeholder": props.placeholder
  });
};

exports.Textarea = Textarea;

var InputTitle = function InputTitle(props, context) {
  return (0, _inferno.createVNode)(1, "h2", null, [props.children, props.required && (0, _inferno.createVNode)(1, "span", null, " *", 0, {
    "style": {
      "color": "red"
    }
  })], 0);
};

exports.InputTitle = InputTitle;

var BugReportForm = function BugReportForm(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var _useLocalState = (0, _backend.useLocalState)(context, 'is_secret', false),
      isSecret = _useLocalState[0],
      setIsSecret = _useLocalState[1];

  var _useLocalState2 = (0, _backend.useLocalState)(context, 'tag', 'BUG'),
      chosenTag = _useLocalState2[0],
      setTag = _useLocalState2[1];

  var tags = [["Unclassified", "BUG"], ["Trivial", "TRIVIAL"], ["Minor", "MINOR"], ["Major", "MAJOR"], ["Critical", "CRITICAL"]];

  var submit = function submit() {
    var data = {};
    data.secret = isSecret;
    data.tags = [chosenTag];
    data.steps = document.getElementById("steps").value;
    data.additional = document.getElementById("additional").value;
    data.title = document.getElementById("title").getElementsByTagName('input')[0].value;
    data.description = document.getElementById("description").getElementsByTagName('input')[0].value;
    data.expected_behavior = document.getElementById("expected_behavior").getElementsByTagName('input')[0].value;

    if (!data.title || !data.description || !data.expected_behavior || !data.steps) {
      alert("Please fill out all required fields!");
      return;
    }

    act("confirm", data);
  };

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "title": "Bug Report Form",
    "width": 600,
    "height": 700,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: (0, _inferno.createComponentVNode)(2, _components.Section, {
        "fill": true,
        "scrollable": true,
        children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
          "direction": "column",
          "height": "100%",
          children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "style": {
              "text-align": "center"
            },
            children: (0, _inferno.createVNode)(1, "a", null, "If you have a GitHub account click here instead", 16, {
              "href": "https://github.com/goonstation/goonstation/issues/new?assignees=&labels=&template=bug_report.yml",
              "target": "_blank",
              "rel": "noreferrer",
              "style": {
                "color": "#6992c2"
              }
            })
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            children: [(0, _inferno.createComponentVNode)(2, InputTitle, {
              "required": true,
              children: "Title"
            }), (0, _inferno.createComponentVNode)(2, _components.Input, {
              "width": "100%",
              "id": "title"
            })]
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "my": 2,
            children: [(0, _inferno.createVNode)(1, "h2", null, "Tags", 0), tags.map(function (pair) {
              return (0, _inferno.createComponentVNode)(2, _Button.ButtonCheckbox, {
                "checked": pair[1] === chosenTag,
                "onClick": function () {
                  function onClick() {
                    return setTag(pair[1]);
                  }

                  return onClick;
                }(),
                children: pair[0]
              }, pair[1]);
            })]
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "my": 2,
            children: [(0, _inferno.createComponentVNode)(2, InputTitle, {
              "required": true,
              children: "Description"
            }), "Give a short description of the bug", (0, _inferno.createComponentVNode)(2, _components.Input, {
              "width": "100%",
              "id": "description"
            })]
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "my": 2,
            children: [(0, _inferno.createComponentVNode)(2, InputTitle, {
              "required": true,
              children: "Steps To Reproduce"
            }), "Give a list of steps to reproduce this issue", (0, _inferno.createComponentVNode)(2, Textarea, {
              "id": "steps",
              "placeholder": "1.\n2.\n3."
            })]
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "my": 2,
            children: [(0, _inferno.createComponentVNode)(2, InputTitle, {
              "required": true,
              children: "Expected Behavior"
            }), "Give a short description of what you expected to happen", (0, _inferno.createComponentVNode)(2, _components.Input, {
              "width": "100%",
              "id": "expected_behavior"
            })]
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "my": 2,
            children: [(0, _inferno.createVNode)(1, "h2", null, "Additional Information & Screenshots", 0), "Add screenshots and any other information here", (0, _inferno.createComponentVNode)(2, Textarea, {
              "id": "additional"
            })]
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "my": 2,
            children: [(0, _inferno.createVNode)(1, "h2", null, "Is this bug an exploit or related to secret content?", 0), (0, _inferno.createComponentVNode)(2, _Button.ButtonCheckbox, {
              "checked": isSecret,
              "onClick": function () {
                function onClick() {
                  setIsSecret(!isSecret);
                }

                return onClick;
              }(),
              children: "Exploit / Secret"
            })]
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "my": 2,
            children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
              "style": {
                "justify-content": "center"
              },
              children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                "mx": 1,
                children: (0, _inferno.createVNode)(1, "div", "Button Button--color--default", "Submit", 0, {
                  "onClick": submit
                })
              }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                "mx": 1,
                children: (0, _inferno.createVNode)(1, "div", "Button Button--color--default", "Cancel", 0, {
                  "onClick": function () {
                    function onClick() {
                      return act("cancel");
                    }

                    return onClick;
                  }()
                })
              })]
            })
          })]
        })
      })
    })
  });
};

exports.BugReportForm = BugReportForm;

/***/ }),

/***/ "./packages/tgui/interfaces/CharacterPreferences/CharacterTab.tsx":
/*!************************************************************************!*\
  !*** ./packages/tgui/interfaces/CharacterPreferences/CharacterTab.tsx ***!
  \************************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.CharacterTab = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */
var CustomDetail = function CustomDetail(_ref, context) {
  var id = _ref.id,
      color = _ref.color,
      style = _ref.style;

  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.ColorButton, {
    "color": color,
    "onClick": function () {
      function onClick() {
        return act('update-detail-color', {
          id: id
        });
      }

      return onClick;
    }()
  }), (0, _inferno.createComponentVNode)(2, _components.Button, {
    "icon": "chevron-left",
    "onClick": function () {
      function onClick() {
        return act('update-detail-style-cycle', {
          id: id,
          direction: -1
        });
      }

      return onClick;
    }()
  }), (0, _inferno.createComponentVNode)(2, _components.Button, {
    "icon": "chevron-right",
    "onClick": function () {
      function onClick() {
        return act('update-detail-style-cycle', {
          id: id,
          direction: 1
        });
      }

      return onClick;
    }()
  }), (0, _inferno.createComponentVNode)(2, _components.Button, {
    "onClick": function () {
      function onClick() {
        return act('update-detail-style', {
          id: id
        });
      }

      return onClick;
    }(),
    children: style
  })], 4);
};

var CharacterTab = function CharacterTab(_props, context) {
  var _useBackend2 = (0, _backend.useBackend)(context),
      act = _useBackend2.act,
      data = _useBackend2.data;

  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Appearance",
    "buttons": (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
      "checked": data.randomAppearance,
      "onClick": function () {
        function onClick() {
          return act('update-randomAppearance');
        }

        return onClick;
      }(),
      children: "Random appearance"
    }),
    children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Skin Tone",
        children: [(0, _inferno.createComponentVNode)(2, _components.ColorButton, {
          "color": data.skinTone,
          "onClick": function () {
            function onClick() {
              return act('update-skinTone');
            }

            return onClick;
          }()
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "angle-double-left",
          "onClick": function () {
            function onClick() {
              return act('decrease-skinTone', {
                alot: 1
              });
            }

            return onClick;
          }()
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "chevron-left",
          "onClick": function () {
            function onClick() {
              return act('decrease-skinTone');
            }

            return onClick;
          }()
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "chevron-right",
          "onClick": function () {
            function onClick() {
              return act('increase-skinTone');
            }

            return onClick;
          }()
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "angle-double-right",
          "onClick": function () {
            function onClick() {
              return act('increase-skinTone', {
                alot: 1
              });
            }

            return onClick;
          }()
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Eye Color",
        children: (0, _inferno.createComponentVNode)(2, _components.ColorButton, {
          "color": data.eyeColor,
          "onClick": function () {
            function onClick() {
              return act('update-eyeColor');
            }

            return onClick;
          }()
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Top Detail",
        children: (0, _inferno.createComponentVNode)(2, CustomDetail, {
          "id": "custom3",
          "color": data.customColor3,
          "style": data.customStyle3
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Middle Detail",
        children: (0, _inferno.createComponentVNode)(2, CustomDetail, {
          "id": "custom2",
          "color": data.customColor2,
          "style": data.customStyle2
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Bottom Detail",
        children: (0, _inferno.createComponentVNode)(2, CustomDetail, {
          "id": "custom1",
          "color": data.customColor1,
          "style": data.customStyle1
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Special Style",
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-specialStyle');
            }

            return onClick;
          }(),
          children: data.specialStyle || "default"
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Underwear",
        children: (0, _inferno.createComponentVNode)(2, CustomDetail, {
          "id": "underwear",
          "color": data.underwearColor,
          "style": data.underwearStyle
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Divider)]
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Sounds",
    children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Fart",
        children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-fartsound');
            }

            return onClick;
          }(),
          children: data.fartsound
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "volume-up",
          "onClick": function () {
            function onClick() {
              return act('previewSound', {
                fartsound: 1
              });
            }

            return onClick;
          }(),
          children: "Preview"
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Scream",
        children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-screamsound');
            }

            return onClick;
          }(),
          children: data.screamsound
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "volume-up",
          "onClick": function () {
            function onClick() {
              return act('previewSound', {
                screamsound: 1
              });
            }

            return onClick;
          }(),
          children: "Preview"
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Chat",
        children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-chatsound');
            }

            return onClick;
          }(),
          children: data.chatsound
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "volume-up",
          "onClick": function () {
            function onClick() {
              return act('previewSound', {
                chatsound: 1
              });
            }

            return onClick;
          }(),
          children: "Preview"
        })]
      })]
    })
  })], 4);
};

exports.CharacterTab = CharacterTab;

/***/ }),

/***/ "./packages/tgui/interfaces/CharacterPreferences/GameSettingsTab.tsx":
/*!***************************************************************************!*\
  !*** ./packages/tgui/interfaces/CharacterPreferences/GameSettingsTab.tsx ***!
  \***************************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.GameSettingsTab = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _type = __webpack_require__(/*! ./type */ "./packages/tgui/interfaces/CharacterPreferences/type.ts");

/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */
var GameSettingsTab = function GameSettingsTab(_props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Popup Font Size",
        "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-fontSize', {
                reset: 1
              });
            }

            return onClick;
          }(),
          children: "Reset"
        }),
        children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          "color": "label",
          children: "Changes the font size used in popup windows. Only works when CHUI is disabled."
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-fontSize');
            }

            return onClick;
          }(),
          children: data.fontSize ? data.fontSize + '%' : 'Default'
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Messages",
        children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          "color": "label",
          children: "Toggles if certain messages are shown in the chat window by default. You can change these mid-round by using the Toggle OOC/LOOC commands under the Commands tab in the top right."
        }), data.isMentor ? (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.seeMentorPms,
            "onClick": function () {
              function onClick() {
                return act('update-seeMentorPms');
              }

              return onClick;
            }(),
            children: "Display Mentorhelp"
          })
        }) : null, (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.listenOoc,
            "onClick": function () {
              function onClick() {
                return act('update-listenOoc');
              }

              return onClick;
            }(),
            "tooltip": "Out-of-Character chat. This mostly just shows up on the RP server and at the end of rounds.",
            children: "Display OOC chat"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.listenLooc,
            "onClick": function () {
              function onClick() {
                return act('update-listenLooc');
              }

              return onClick;
            }(),
            "tooltip": "Local Out-of-Character is OOC chat, but only appears for nearby players. This is basically only used on the RP server.",
            children: "Display LOOC chat"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": !data.flyingChatHidden,
            "onClick": function () {
              function onClick() {
                return act('update-flyingChatHidden');
              }

              return onClick;
            }(),
            "tooltip": "Chat messages will appear over characters as they're talking.",
            children: "See chat above people's heads"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.autoCapitalization,
            "onClick": function () {
              function onClick() {
                return act('update-autoCapitalization');
              }

              return onClick;
            }(),
            "tooltip": "Chat messages you send will be automatically capitalized.",
            children: "Auto-capitalize your messages"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.localDeadchat,
            "onClick": function () {
              function onClick() {
                return act('update-localDeadchat');
              }

              return onClick;
            }(),
            "tooltip": "You'll only hear chat messages from living people on your screen as a ghost.",
            children: "Local ghost hearing"
          })
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "HUD Theme",
        children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button, {
            "onClick": function () {
              function onClick() {
                return act('update-hudTheme');
              }

              return onClick;
            }(),
            children: "Change"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          children: (0, _inferno.createComponentVNode)(2, _components.Image, {
            "pixelated": true,
            "src": "hud_preview_" + data.hudTheme + ".png",
            "width": "32px",
            "height": "32px"
          })
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Targeting Cursor",
        children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button, {
            "onClick": function () {
              function onClick() {
                return act('update-targetingCursor');
              }

              return onClick;
            }(),
            children: "Change"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          children: (0, _inferno.createComponentVNode)(2, _components.Image, {
            "pixelated": true,
            "src": "tcursor_" + data.targetingCursor + ".png",
            "width": "32px",
            "height": "32px"
          })
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Tooltips",
        children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          "color": "label",
          children: "Tooltips can appear when hovering over items. These tooltips can provide bits of information about the item, such as attack strength, special moves, etc."
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.tooltipOption === _type.CharacterPreferencesTooltip.Always,
            "onClick": function () {
              function onClick() {
                return act('update-tooltipOption', {
                  value: _type.CharacterPreferencesTooltip.Always
                });
              }

              return onClick;
            }(),
            children: "Show Always"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.tooltipOption === _type.CharacterPreferencesTooltip.Alt,
            "onClick": function () {
              function onClick() {
                return act('update-tooltipOption', {
                  value: _type.CharacterPreferencesTooltip.Alt
                });
              }

              return onClick;
            }(),
            children: "Show When ALT is held"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.tooltipOption === _type.CharacterPreferencesTooltip.Never,
            "onClick": function () {
              function onClick() {
                return act('update-tooltipOption', {
                  value: _type.CharacterPreferencesTooltip.Never
                });
              }

              return onClick;
            }(),
            children: "Never Show"
          })
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "tgui",
        children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          "color": "label",
          children: "tgui is the UI framework we use for some game windows, and it comes with options!"
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.tguiFancy,
            "onClick": function () {
              function onClick() {
                return act('update-tguiFancy');
              }

              return onClick;
            }(),
            children: "Fast & Fancy Windows"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.tguiLock,
            "onClick": function () {
              function onClick() {
                return act('update-tguiLock');
              }

              return onClick;
            }(),
            children: "Lock initial placement of windows"
          })
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Popups",
        children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          "color": "label",
          children: "These options toggle the popups that appear when logging in and at the end of a round."
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.viewChangelog,
            "onClick": function () {
              function onClick() {
                return act('update-viewChangelog');
              }

              return onClick;
            }(),
            "tooltip": "The changelog can be shown at any time by using the 'Changelog' command, under the Commands tab in the top right.",
            "tooltipPosition": "top",
            children: "Auto-open changelog"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.viewScore,
            "onClick": function () {
              function onClick() {
                return act('update-viewScore');
              }

              return onClick;
            }(),
            "tooltip": "The end-of-round scoring shows various stats on how the round went. If this option is off, you won't be able to see it.",
            "tooltipPosition": "top",
            children: "Auto-open end-of-round score"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.viewTickets,
            "onClick": function () {
              function onClick() {
                return act('update-viewTickets');
              }

              return onClick;
            }(),
            "tooltip": "The end-of-round ticketing summary shows the various tickets and fines that were handed out. If this option is off, you can still see them on Goonhub (goonhub.com).",
            "tooltipPosition": "top",
            children: "Auto-open end-of-round ticket summary"
          })
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Controls",
        children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          "color": "label",
          children: "Various options for how you control your character and the game."
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.useClickBuffer,
            "onClick": function () {
              function onClick() {
                return act('update-useClickBuffer');
              }

              return onClick;
            }(),
            "tooltip": "There is a cooldown after clicking on things in-game. When enabled, if you click something during this cooldown, the game will apply that click after the cooldown. Otherwise, the click is ignored.",
            "tooltipPosition": "top",
            children: "Queue Combat Clicks"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.useWasd,
            "onClick": function () {
              function onClick() {
                return act('update-useWasd');
              }

              return onClick;
            }(),
            "tooltip": "Enabling this allows you to use WASD to move instead of the arrow keys, and enables a few other hotkeys.",
            "tooltipPosition": "top",
            children: "Use WASD Mode"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mb": "5px",
          children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": data.useAzerty,
            "onClick": function () {
              function onClick() {
                return act('update-useAzerty');
              }

              return onClick;
            }(),
            "tooltip": "If you have an AZERTY keyboard, enable this. Yep. This sure is a tooltip.",
            "tooltipPosition": "top",
            children: "Use AZERTY Keyboard Layout"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "color": "label",
          children: "Familiar with /tg/station controls? You can enable/disable them under the Game/Interface menu in the top left."
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Preferred Map",
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-preferredMap');
            }

            return onClick;
          }(),
          children: data.preferredMap ? data.preferredMap : (0, _inferno.createComponentVNode)(2, _components.Box, {
            "italic": true,
            children: "None"
          })
        })
      })]
    })
  });
};

exports.GameSettingsTab = GameSettingsTab;

/***/ }),

/***/ "./packages/tgui/interfaces/CharacterPreferences/GeneralTab.tsx":
/*!**********************************************************************!*\
  !*** ./packages/tgui/interfaces/CharacterPreferences/GeneralTab.tsx ***!
  \**********************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.GeneralTab = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _string = __webpack_require__(/*! common/string */ "./packages/common/string.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */
var GeneralTab = function GeneralTab(_props, context) {
  var _data$pin;

  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Records",
    children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Name",
        "buttons": (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
          "checked": data.randomName,
          "onClick": function () {
            function onClick() {
              return act('update-randomName');
            }

            return onClick;
          }(),
          children: "Random"
        }),
        children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-nameFirst');
            }

            return onClick;
          }(),
          children: data.nameFirst
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-nameMiddle');
            }

            return onClick;
          }(),
          "color": data.nameMiddle === '' ? 'grey' : 'default',
          children: data.nameMiddle !== '' ? data.nameMiddle : (0, _inferno.createComponentVNode)(2, _components.Box, {
            "italic": true,
            children: "None"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-nameLast');
            }

            return onClick;
          }(),
          children: data.nameLast
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Gender",
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-gender');
            }

            return onClick;
          }(),
          children: data.gender
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Pronouns",
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-pronouns');
            }

            return onClick;
          }(),
          children: data.pronouns
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Age",
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-age');
            }

            return onClick;
          }(),
          children: data.age
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Blood Type",
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-bloodType');
            }

            return onClick;
          }(),
          children: data.bloodRandom ? (0, _inferno.createComponentVNode)(2, _components.Box, {
            "as": "span",
            "italic": true,
            children: "Random"
          }) : data.bloodType
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Bank PIN",
        "buttons": (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
          "checked": !data.pin,
          "onClick": function () {
            function onClick() {
              return act('update-pin', {
                random: !!data.pin
              });
            }

            return onClick;
          }(),
          children: "Random"
        }),
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-pin');
            }

            return onClick;
          }(),
          children: (_data$pin = data.pin) != null ? _data$pin : (0, _inferno.createComponentVNode)(2, _components.Box, {
            "as": "span",
            "italic": true,
            children: "Random"
          })
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Flavor Text",
        "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-flavorText');
            }

            return onClick;
          }(),
          "icon": "wrench",
          children: "Edit"
        }),
        children: (0, _inferno.createComponentVNode)(2, _components.BlockQuote, {
          children: data.flavorText ? (0, _string.decodeHtmlEntities)(data.flavorText) : (0, _inferno.createComponentVNode)(2, _components.Box, {
            "italic": true,
            children: "None"
          })
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Security Note",
        "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-securityNote');
            }

            return onClick;
          }(),
          "icon": "wrench",
          children: "Edit"
        }),
        children: (0, _inferno.createComponentVNode)(2, _components.BlockQuote, {
          children: data.securityNote ? (0, _string.decodeHtmlEntities)(data.securityNote) : (0, _inferno.createComponentVNode)(2, _components.Box, {
            "italic": true,
            children: "None"
          })
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Medical Note",
        "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-medicalNote');
            }

            return onClick;
          }(),
          "icon": "wrench",
          children: "Edit"
        }),
        children: (0, _inferno.createComponentVNode)(2, _components.BlockQuote, {
          children: data.medicalNote ? (0, _string.decodeHtmlEntities)(data.medicalNote) : (0, _inferno.createComponentVNode)(2, _components.Box, {
            "italic": true,
            children: "None"
          })
        })
      })]
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "PDA",
    children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Ringtone",
        children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('update-pdaRingtone');
            }

            return onClick;
          }(),
          children: data.pdaRingtone
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('previewSound', {
                pdaRingtone: 1
              });
            }

            return onClick;
          }(),
          "icon": "volume-up",
          children: "Preview"
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Background Color",
        children: (0, _inferno.createComponentVNode)(2, _components.ColorButton, {
          "color": data.pdaColor,
          "onClick": function () {
            function onClick() {
              return act('update-pdaColor');
            }

            return onClick;
          }()
        })
      })]
    })
  })], 4);
};

exports.GeneralTab = GeneralTab;

/***/ }),

/***/ "./packages/tgui/interfaces/CharacterPreferences/SavesTab.tsx":
/*!********************************************************************!*\
  !*** ./packages/tgui/interfaces/CharacterPreferences/SavesTab.tsx ***!
  \********************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.SavesTab = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */
var SavesTab = function SavesTab(_props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Cloud Saves",
    children: data.cloudSaves ? (0, _inferno.createFragment)([data.cloudSaves.map(function (name, index) {
      return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, Cloudsave, {
        "name": name,
        "index": index
      }), (0, _inferno.createComponentVNode)(2, _components.Divider)], 4, name);
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      "mt": "5px",
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "onClick": function () {
          function onClick() {
            return act('cloud-new');
          }

          return onClick;
        }(),
        children: "Create new save"
      })
    })], 0) : (0, _inferno.createComponentVNode)(2, _components.Box, {
      "italic": true,
      "color": "label",
      children: "Cloud saves could not be loaded."
    })
  });
};

exports.SavesTab = SavesTab;

var Cloudsave = function Cloudsave(_ref, context) {
  var name = _ref.name,
      index = _ref.index;

  var _useBackend2 = (0, _backend.useBackend)(context),
      act = _useBackend2.act;

  return (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
    children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
      "label": "Cloud save " + (index + 1),
      "buttons": (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
        "onClick": function () {
          function onClick() {
            return act('cloud-load', {
              name: name
            });
          }

          return onClick;
        }(),
        children: "Load"
      }), (0, _inferno.createTextVNode)(" -"), (0, _inferno.createTextVNode)(' '), (0, _inferno.createComponentVNode)(2, _components.Button, {
        "onClick": function () {
          function onClick() {
            return act('cloud-save', {
              name: name
            });
          }

          return onClick;
        }(),
        children: "Save"
      }), (0, _inferno.createTextVNode)(" -"), (0, _inferno.createTextVNode)(' '), (0, _inferno.createComponentVNode)(2, _components.Button.Confirm, {
        "onClick": function () {
          function onClick() {
            return act('cloud-delete', {
              name: name
            });
          }

          return onClick;
        }(),
        "content": "Delete"
      })], 0),
      children: name
    })
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/CharacterPreferences/index.tsx":
/*!*****************************************************************!*\
  !*** ./packages/tgui/interfaces/CharacterPreferences/index.tsx ***!
  \*****************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.CharacterPreferences = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _keycodes = __webpack_require__(/*! common/keycodes */ "./packages/common/keycodes.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../../layouts */ "./packages/tgui/layouts/index.js");

var _CharacterTab = __webpack_require__(/*! ./CharacterTab */ "./packages/tgui/interfaces/CharacterPreferences/CharacterTab.tsx");

var _GameSettingsTab = __webpack_require__(/*! ./GameSettingsTab */ "./packages/tgui/interfaces/CharacterPreferences/GameSettingsTab.tsx");

var _GeneralTab = __webpack_require__(/*! ./GeneralTab */ "./packages/tgui/interfaces/CharacterPreferences/GeneralTab.tsx");

var _SavesTab = __webpack_require__(/*! ./SavesTab */ "./packages/tgui/interfaces/CharacterPreferences/SavesTab.tsx");

var _type = __webpack_require__(/*! ./type */ "./packages/tgui/interfaces/CharacterPreferences/type.ts");

/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */
var nextRotateTime = 0;

var CharacterPreferences = function CharacterPreferences(_props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var _useLocalState = (0, _backend.useLocalState)(context, 'menu', _type.CharacterPreferencesTabKeys.General),
      menu = _useLocalState[0],
      setMenu = _useLocalState[1];

  var handleKeyDown = function handleKeyDown(e) {
    if ((menu === _type.CharacterPreferencesTabKeys.General || menu === _type.CharacterPreferencesTabKeys.Character) && (e.keyCode === _keycodes.KEY_LEFT || e.keyCode === _keycodes.KEY_RIGHT)) {
      e.preventDefault();

      if (nextRotateTime > performance.now()) {
        return;
      }

      nextRotateTime = performance.now() + 125;
      var direction = 'rotate-counter-clockwise';

      if (e.keyCode === _keycodes.KEY_RIGHT) {
        direction = 'rotate-clockwise';
      }

      act(direction);
    }
  };

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 600,
    "height": 750,
    "title": "Character Setup",
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      "onKeyDown": handleKeyDown,
      children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
        "vertical": true,
        "fill": true,
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, SavesAndProfile)
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Tabs, {
            children: [(0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
              "selected": menu === _type.CharacterPreferencesTabKeys.General,
              "onClick": function () {
                function onClick() {
                  return setMenu(_type.CharacterPreferencesTabKeys.General);
                }

                return onClick;
              }(),
              children: "General"
            }), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
              "selected": menu === _type.CharacterPreferencesTabKeys.Character,
              "onClick": function () {
                function onClick() {
                  return setMenu(_type.CharacterPreferencesTabKeys.Character);
                }

                return onClick;
              }(),
              children: "Appearance"
            }), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
              "onClick": function () {
                function onClick() {
                  return act('open-occupation-window');
                }

                return onClick;
              }(),
              children: "Occupation"
            }), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
              "onClick": function () {
                function onClick() {
                  return act('open-traits-window');
                }

                return onClick;
              }(),
              children: "Traits"
            }), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
              "selected": menu === _type.CharacterPreferencesTabKeys.GameSettings,
              "onClick": function () {
                function onClick() {
                  return setMenu(_type.CharacterPreferencesTabKeys.GameSettings);
                }

                return onClick;
              }(),
              children: "Game Settings"
            }), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
              "selected": menu === _type.CharacterPreferencesTabKeys.Saves,
              "onClick": function () {
                function onClick() {
                  return setMenu(_type.CharacterPreferencesTabKeys.Saves);
                }

                return onClick;
              }(),
              children: "Cloud Saves"
            })]
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          "grow": "1",
          children: menu === _type.CharacterPreferencesTabKeys.General || menu === _type.CharacterPreferencesTabKeys.Character ? (0, _inferno.createComponentVNode)(2, _components.Stack, {
            "fill": true,
            children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
              "basis": 0,
              "grow": "1",
              children: (0, _inferno.createComponentVNode)(2, _components.Section, {
                "scrollable": true,
                "fill": true,
                children: [menu === _type.CharacterPreferencesTabKeys.General && (0, _inferno.createComponentVNode)(2, _GeneralTab.GeneralTab), menu === _type.CharacterPreferencesTabKeys.Character && (0, _inferno.createComponentVNode)(2, _CharacterTab.CharacterTab)]
              })
            }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
              children: (0, _inferno.createComponentVNode)(2, _components.Section, {
                "fill": true,
                children: [(0, _inferno.createComponentVNode)(2, _components.ByondUi, {
                  "params": {
                    id: data.preview,
                    type: 'map'
                  },
                  "style": {
                    width: '64px',
                    height: '128px'
                  }
                }), (0, _inferno.createComponentVNode)(2, _components.Box, {
                  "textAlign": "center",
                  "mt": "5px",
                  children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
                    "icon": "chevron-left",
                    "onClick": function () {
                      function onClick() {
                        return act('rotate-counter-clockwise');
                      }

                      return onClick;
                    }()
                  }), (0, _inferno.createComponentVNode)(2, _components.Button, {
                    "icon": "chevron-right",
                    "onClick": function () {
                      function onClick() {
                        return act('rotate-clockwise');
                      }

                      return onClick;
                    }()
                  })]
                })]
              })
            })]
          }) : (0, _inferno.createComponentVNode)(2, _components.Section, {
            "scrollable": true,
            "fill": true,
            children: [menu === _type.CharacterPreferencesTabKeys.GameSettings && (0, _inferno.createComponentVNode)(2, _GameSettingsTab.GameSettingsTab), menu === _type.CharacterPreferencesTabKeys.Saves && (0, _inferno.createComponentVNode)(2, _SavesTab.SavesTab)]
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            children: (0, _inferno.createComponentVNode)(2, _components.Button.Confirm, {
              "content": "Reset All",
              "onClick": function () {
                function onClick() {
                  return act('reset');
                }

                return onClick;
              }()
            })
          })
        })]
      })
    })
  });
};

exports.CharacterPreferences = CharacterPreferences;

var SavesAndProfile = function SavesAndProfile(_props, context) {
  var _useBackend2 = (0, _backend.useBackend)(context),
      act = _useBackend2.act,
      data = _useBackend2.data;

  var activeProfileIndex = data.profiles.findIndex(function (p) {
    return p.active;
  });
  return (0, _inferno.createComponentVNode)(2, _components.Stack, {
    "vertical": true,
    children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
        children: data.profiles.map(function (profile, index) {
          return (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
            "basis": 0,
            "grow": 1,
            children: (0, _inferno.createComponentVNode)(2, Profile, {
              "profile": profile,
              "index": index
            })
          }, index);
        })
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      children: (0, _inferno.createComponentVNode)(2, _components.Section, {
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Profile Name",
            "buttons": activeProfileIndex > -1 ? (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
              "onClick": function () {
                function onClick() {
                  return act('load', {
                    index: activeProfileIndex + 1
                  });
                }

                return onClick;
              }(),
              children: "Reload"
            }), ' - ', (0, _inferno.createComponentVNode)(2, _components.Button, {
              "onClick": function () {
                function onClick() {
                  return act('save', {
                    index: activeProfileIndex + 1
                  });
                }

                return onClick;
              }(),
              "icon": data.profileModified ? 'exclamation-triangle' : undefined,
              "color": data.profileModified ? 'danger' : undefined,
              "tooltip": data.profileModified ? 'You may have unsaved changes! Any unsaved changes will take effect for this round only.' : undefined,
              "tooltipPosition": "left",
              children: "Save"
            })], 0) : null,
            children: (0, _inferno.createComponentVNode)(2, _components.Button, {
              "onClick": function () {
                function onClick() {
                  return act('update-profileName');
                }

                return onClick;
              }(),
              children: data.profileName ? data.profileName : (0, _inferno.createComponentVNode)(2, _components.Box, {
                "italic": true,
                children: "None"
              })
            })
          })
        })
      })
    })]
  });
};

var Profile = function Profile(props, context) {
  var index = props.index,
      profile = props.profile;

  var _useBackend3 = (0, _backend.useBackend)(context),
      act = _useBackend3.act;

  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Profile " + (index + 1),
    "textAlign": "center",
    "backgroundColor": profile.active ? 'rgba(0, 0, 0, 0.10)' : null,
    "fill": true,
    children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
      "vertical": true,
      "fill": true,
      "justify": "space-between",
      children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
        children: (0, _inferno.createComponentVNode)(2, _components.Box, {
          children: profile.name ? (0, _inferno.createComponentVNode)(2, _components.Box, {
            children: profile.name
          }) : (0, _inferno.createComponentVNode)(2, _components.Box, {
            "italic": true,
            "color": "label",
            children: "Empty"
          })
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
          "disabled": !profile.name,
          "onClick": function () {
            function onClick() {
              return act('load', {
                index: index + 1
              });
            }

            return onClick;
          }(),
          children: "Load"
        }), ' - ', (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              return act('save', {
                index: index + 1
              });
            }

            return onClick;
          }(),
          children: "Save"
        })]
      })]
    })
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/CharacterPreferences/type.ts":
/*!***************************************************************!*\
  !*** ./packages/tgui/interfaces/CharacterPreferences/type.ts ***!
  \***************************************************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.CharacterPreferencesTooltip = exports.CharacterPreferencesTabKeys = void 0;

/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */
var CharacterPreferencesTabKeys;
exports.CharacterPreferencesTabKeys = CharacterPreferencesTabKeys;

(function (CharacterPreferencesTabKeys) {
  CharacterPreferencesTabKeys[CharacterPreferencesTabKeys["Saves"] = 0] = "Saves";
  CharacterPreferencesTabKeys[CharacterPreferencesTabKeys["General"] = 1] = "General";
  CharacterPreferencesTabKeys[CharacterPreferencesTabKeys["Character"] = 2] = "Character";
  CharacterPreferencesTabKeys[CharacterPreferencesTabKeys["GameSettings"] = 3] = "GameSettings";
})(CharacterPreferencesTabKeys || (exports.CharacterPreferencesTabKeys = CharacterPreferencesTabKeys = {}));

var CharacterPreferencesTooltip;
exports.CharacterPreferencesTooltip = CharacterPreferencesTooltip;

(function (CharacterPreferencesTooltip) {
  CharacterPreferencesTooltip[CharacterPreferencesTooltip["Always"] = 1] = "Always";
  CharacterPreferencesTooltip[CharacterPreferencesTooltip["Never"] = 2] = "Never";
  CharacterPreferencesTooltip[CharacterPreferencesTooltip["Alt"] = 3] = "Alt";
})(CharacterPreferencesTooltip || (exports.CharacterPreferencesTooltip = CharacterPreferencesTooltip = {}));

/***/ }),

/***/ "./packages/tgui/interfaces/ChemDispenser.js":
/*!***************************************************!*\
  !*** ./packages/tgui/interfaces/ChemDispenser.js ***!
  \***************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ChemGroups = exports.BeakerContentsGraph = exports.Beaker = exports.ReagentDispenser = exports.ChemDispenser = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var _stateMap;

var MatterState = {
  Solid: 1,
  Liquid: 2,
  Gas: 3
};
var stateMap = (_stateMap = {}, _stateMap[MatterState.Solid] = {
  icon: 'square',
  pr: 0.5
}, _stateMap[MatterState.Liquid] = {
  icon: 'tint',
  pr: 0.9
}, _stateMap[MatterState.Gas] = {
  icon: 'wind',
  pr: 0.5
}, _stateMap);

var ChemDispenser = function ChemDispenser(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data;

  var beakerContents = data.beakerContents;
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 570,
    "height": 705,
    "theme": "ntos",
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      "scrollable": true,
      children: (0, _inferno.createComponentVNode)(2, _components.Box, {
        children: [(0, _inferno.createComponentVNode)(2, ReagentDispenser), (0, _inferno.createComponentVNode)(2, Beaker), !!beakerContents.length && (0, _inferno.createComponentVNode)(2, BeakerContentsGraph), (0, _inferno.createComponentVNode)(2, ChemGroups)]
      })
    })
  });
};

exports.ChemDispenser = ChemDispenser;

var ReagentDispenser = function ReagentDispenser(props, context) {
  var _useBackend2 = (0, _backend.useBackend)(context),
      act = _useBackend2.act,
      data = _useBackend2.data;

  var beakerName = data.beakerName,
      currentBeakerName = data.currentBeakerName,
      maximumBeakerVolume = data.maximumBeakerVolume,
      beakerTotalVolume = data.beakerTotalVolume;

  var _useSharedState = (0, _backend.useSharedState)(context, 'addAmount', 10),
      addAmount = _useSharedState[0],
      setAddAmount = _useSharedState[1];

  var _useSharedState2 = (0, _backend.useSharedState)(context, 'iconToggle', false),
      iconToggle = _useSharedState2[0],
      setIconToggle = _useSharedState2[1];

  var _useLocalState = (0, _backend.useLocalState)(context, 'hoverOver', ""),
      hoverOverId = _useLocalState[0],
      setHoverOverId = _useLocalState[1];

  var dispensableReagents = data.dispensableReagents || [];
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "fontSize": "12px",
    "title": (0, _inferno.createFragment)([(0, _inferno.createTextVNode)("Dispense"), (0, _inferno.createComponentVNode)(2, _components.Box, {
      "as": "span",
      "ml": 18,
      children: ["Icons:", (0, _inferno.createComponentVNode)(2, _components.Button, {
        "width": 2,
        "textAlign": "center",
        "backgroundColor": "rgba(0, 0, 0, 0)",
        "textColor": iconToggle ? "rgba(255, 255, 255, 0.5)" : "rgba(255, 255, 255, 1)",
        "onClick": function () {
          function onClick() {
            return setIconToggle(false);
          }

          return onClick;
        }(),
        children: (0, _inferno.createComponentVNode)(2, _components.Icon, {
          "mr": 1,
          "name": "circle"
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Button, {
        "width": 2,
        "backgroundColor": "rgba(0, 0, 0, 0)",
        "textColor": iconToggle ? "rgba(255, 255, 255, 1)" : "rgba(255, 255, 255, 0.5)",
        "onClick": function () {
          function onClick() {
            return setIconToggle(true);
          }

          return onClick;
        }(),
        children: (0, _inferno.createComponentVNode)(2, _components.Icon, {
          "name": "tint"
        })
      })]
    })], 4),
    "buttons": (0, _inferno.createComponentVNode)(2, _components.Box, {
      children: ["Dispense Amount: ", (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
        "value": addAmount,
        "format": function () {
          function format(value) {
            return value + "u";
          }

          return format;
        }(),
        "width": 4,
        "minValue": 1,
        "maxValue": 100,
        "onDrag": function () {
          function onDrag(e, value) {
            return setAddAmount(value);
          }

          return onDrag;
        }()
      })]
    }),
    children: [(0, _inferno.createComponentVNode)(2, _components.Section, {
      "fitted": true,
      "backgroundColor": "rgba(0,0,0,0)",
      children: [(!maximumBeakerVolume || maximumBeakerVolume === beakerTotalVolume) && (0, _inferno.createComponentVNode)(2, _components.Modal, {
        "className": "chem-dispenser__labels",
        "fontSize": "20px",
        "mr": 2,
        "p": 3,
        children: (0, _inferno.createComponentVNode)(2, _components.Box, {
          children: !maximumBeakerVolume && "No " + beakerName + " Inserted" || currentBeakerName + " Full"
        })
      }), dispensableReagents.map(function (reagent, reagentIndex) {
        return (0, _inferno.createComponentVNode)(2, _components.Button, {
          "className": "chem-dispenser__dispense-buttons",
          "align": "left",
          "width": "130px",
          "onMouseEnter": function () {
            function onMouseEnter() {
              return setHoverOverId(reagent.id);
            }

            return onMouseEnter;
          }(),
          "onMouseLeave": function () {
            function onMouseLeave() {
              return setHoverOverId("");
            }

            return onMouseLeave;
          }(),
          "disabled": maximumBeakerVolume === beakerTotalVolume,
          "lineHeight": 1.75,
          "onClick": function () {
            function onClick() {
              return act("dispense", {
                amount: addAmount,
                reagentId: reagent.id
              });
            }

            return onClick;
          }(),
          children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
            "color": "rgba(" + reagent.colorR + "," + reagent.colorG + ", " + reagent.colorB + ", 1)",
            "name": iconToggle ? stateMap[reagent.state].icon : "circle",
            "pt": 1,
            "style": {
              "text-shadow": "0 0 3px #000"
            }
          }), reagent.name]
        }, reagentIndex);
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      "italic": true,
      "pt": 0.5,
      children: [" ", "Reagent ID: " + hoverOverId]
    })]
  });
};

exports.ReagentDispenser = ReagentDispenser;

var Beaker = function Beaker(props, context) {
  var _useBackend3 = (0, _backend.useBackend)(context),
      act = _useBackend3.act,
      data = _useBackend3.data;

  var beakerName = data.beakerName,
      beakerTotalVolume = data.beakerTotalVolume,
      currentBeakerName = data.currentBeakerName,
      maximumBeakerVolume = data.maximumBeakerVolume;

  var _useSharedState3 = (0, _backend.useSharedState)(context, 'iconToggle', false),
      iconToggle = _useSharedState3[0];

  var _useSharedState4 = (0, _backend.useSharedState)(context, 'removeAmount', 10),
      removeAmount = _useSharedState4[0],
      setRemoveAmount = _useSharedState4[1];

  var removeReagentButtons = [removeAmount, 10, 5, 1];
  var beakerContents = data.beakerContents || [];
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "fontSize": "12px",
    "title": (0, _inferno.createComponentVNode)(2, _components.Button, {
      "className": "chem-dispenser__buttons",
      "icon": "eject",
      "onClick": function () {
        function onClick() {
          return act("eject");
        }

        return onClick;
      }(),
      children: !maximumBeakerVolume ? "Insert " + beakerName : "Eject " + currentBeakerName + " (" + beakerTotalVolume + "/" + maximumBeakerVolume + ")"
    }),
    "buttons": (0, _inferno.createComponentVNode)(2, _components.Box, {
      "align": "left",
      "as": "span",
      children: ["Remove Amount: ", (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
        "width": 4,
        "format": function () {
          function format(value) {
            return value + "u";
          }

          return format;
        }(),
        "value": removeAmount,
        "minValue": 1,
        "maxValue": 100,
        "onDrag": function () {
          function onDrag(e, value) {
            return setRemoveAmount(value);
          }

          return onDrag;
        }()
      })]
    }),
    children: [(0, _inferno.createComponentVNode)(2, _components.Table.Row, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
        "bold": true,
        "collapsing": true,
        "textAlign": "center"
      }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
        "collapsing": true
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      "color": "label",
      children: !beakerContents.length && "No Contents"
    }), beakerContents.map(function (reagent, indexContents) {
      return (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          "collapsing": true,
          "textAlign": "left",
          children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
            "pr": stateMap[reagent.state].pr,
            "style": {
              "text-shadow": "0 0 3px #000;"
            },
            "color": "rgba(" + reagent.colorR + "," + reagent.colorG + ", " + reagent.colorB + ", 1)",
            "name": iconToggle ? stateMap[reagent.state].icon : "circle"
          }), "( " + reagent.volume + "u ) " + reagent.name]
        }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          "collapsing": true,
          "textAlign": "left",
          children: (0, _inferno.createComponentVNode)(2, _components.Box, {
            "mt": 0.5,
            children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": "filter",
              "onClick": function () {
                function onClick() {
                  return act("isolate", {
                    reagentId: reagent.id
                  });
                }

                return onClick;
              }(),
              children: "Isolate"
            }), (0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": "minus",
              "onClick": function () {
                function onClick() {
                  return act("all", {
                    amount: removeAmount,
                    reagentId: reagent.id
                  });
                }

                return onClick;
              }(),
              children: "All"
            }), removeReagentButtons.map(function (amount, indexButtons) {
              return (0, _inferno.createComponentVNode)(2, _components.Button, {
                "icon": "minus",
                "onClick": function () {
                  function onClick() {
                    return act("remove", {
                      amount: amount,
                      reagentId: reagent.id
                    });
                  }

                  return onClick;
                }(),
                children: amount
              }, indexButtons);
            })]
          })
        })]
      }, indexContents);
    })]
  });
};

exports.Beaker = Beaker;

var BeakerContentsGraph = function BeakerContentsGraph(props, context) {
  var _useBackend4 = (0, _backend.useBackend)(context),
      data = _useBackend4.data;

  var _useSharedState5 = (0, _backend.useSharedState)(context, 'sort', 1),
      sort = _useSharedState5[0],
      setSort = _useSharedState5[1];

  var beakerContents = data.beakerContents,
      maximumBeakerVolume = data.maximumBeakerVolume,
      beakerTotalVolume = data.beakerTotalVolume;
  var finalColor = data.finalColor || "";
  var sortMap = [{
    id: 0,
    icon: "sort-amount-down",
    contents: "",
    compareFunction: function () {
      function compareFunction(a, b) {
        return b.volume - a.volume;
      }

      return compareFunction;
    }()
  }, {
    id: 1,
    icon: "sort-amount-up",
    contents: "",
    compareFunction: function () {
      function compareFunction(a, b) {
        return a.volume - b.volume;
      }

      return compareFunction;
    }()
  }, {
    id: 2,
    contents: "Density",
    compareFunction: function () {
      function compareFunction(a, b) {
        return a.state - b.state;
      }

      return compareFunction;
    }()
  }, {
    id: 3,
    contents: "Order Added",
    compareFunction: function () {
      function compareFunction() {
        return 1;
      }

      return compareFunction;
    }()
  }];
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "align": "center",
    "p": 0.5,
    "title": (0, _inferno.createComponentVNode)(2, _components.Tabs, {
      children: sortMap.map(function (sortBy, index) {
        return (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
          "fontSize": "11px",
          "textAlign": "center",
          "align": "center",
          "selected": sort === sortBy.id,
          "onClick": function () {
            function onClick() {
              return setSort(sortBy.id);
            }

            return onClick;
          }(),
          children: [sortBy.icon && (0, _inferno.createComponentVNode)(2, _components.Icon, {
            "name": sortBy.icon
          }), sortBy.contents]
        }, index);
      })
    }),
    children: [(0, _inferno.createComponentVNode)(2, _components.Tooltip, {
      "position": "top",
      "content": "Current Mixture Color",
      children: (0, _inferno.createComponentVNode)(2, _components.Box, {
        "position": "relative",
        "py": 1.5,
        "pl": 4,
        "backgroundColor": finalColor.substring(0, 7)
      })
    }), beakerContents.slice().sort(sortMap[sort].compareFunction).map(function (reagent, index) {
      return (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
        "content": reagent.name + " ( " + reagent.volume + "u )",
        "position": "top",
        children: (0, _inferno.createComponentVNode)(2, _components.Box, {
          "position": "relative",
          "as": "span",
          "pl": reagent.volume / maximumBeakerVolume * 100 / 1.146,
          "py": 1,
          "backgroundColor": "rgba(" + reagent.colorR + "," + reagent.colorG + ", " + reagent.colorB + ", 1)"
        })
      }, index);
    }), (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
      "content": "( " + (maximumBeakerVolume - beakerTotalVolume) + "u )",
      "position": "top",
      children: (0, _inferno.createComponentVNode)(2, _components.Box, {
        "as": "span",
        "position": "relative",
        "pl": (maximumBeakerVolume - beakerTotalVolume) / maximumBeakerVolume * 100 / 1.146,
        "py": 1,
        "backgroundColor": "black"
      })
    })]
  });
};

exports.BeakerContentsGraph = BeakerContentsGraph;

var ChemGroups = function ChemGroups(props, context) {
  var _useBackend5 = (0, _backend.useBackend)(context),
      act = _useBackend5.act,
      data = _useBackend5.data;

  var _useLocalState2 = (0, _backend.useLocalState)(context, 'groupName', ""),
      groupName = _useLocalState2[0],
      setGroupName = _useLocalState2[1];

  var _useLocalState3 = (0, _backend.useLocalState)(context, 'reagents', ""),
      reagents = _useLocalState3[0],
      setReagents = _useLocalState3[1];

  var groupList = data.groupList,
      idCardName = data.idCardName,
      idCardInserted = data.idCardInserted;
  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Reagent Groups",
    "buttons": (0, _inferno.createComponentVNode)(2, _components.Box, {
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "className": "chem-dispenser__buttons",
        "icon": "eject",
        "onClick": function () {
          function onClick() {
            return act("card");
          }

          return onClick;
        }(),
        children: idCardInserted ? "Eject ID: " + idCardName : "Insert ID"
      })
    }),
    children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
          "pt": 1,
          "pr": 7,
          "as": "span",
          children: "Group Name:"
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "pt": 1,
          "as": "span",
          children: "Reagents:"
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Input, {
        "pl": 5,
        "placeholder": "Name",
        "value": groupName,
        "onInput": function () {
          function onInput(e, value) {
            return setGroupName(value);
          }

          return onInput;
        }()
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        "pt": 1,
        "as": "span",
        children: (0, _inferno.createComponentVNode)(2, _components.Input, {
          "pl": 5,
          "placeholder": "Reagents",
          "value": reagents,
          "onInput": function () {
            function onInput(e, value) {
              return setReagents(value);
            }

            return onInput;
          }()
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        "as": "span",
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "plus-circle",
          "lineHeight": 1.75,
          "onClick": function () {
            function onClick() {
              act("newGroup", {
                reagents: reagents,
                groupName: groupName
              });
              setGroupName("");
              setReagents("");
            }

            return onClick;
          }(),
          children: "Add Group"
        })
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      "pt": 0.5,
      children: "Reagents Format: water=1;sugar=1;"
    })]
  }), !!groupList.length && (0, _inferno.createComponentVNode)(2, _components.Section, {
    children: groupList.map(function (group, index) {
      return (0, _inferno.createComponentVNode)(2, _components.Box, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "tint",
          "lineHeight": 1.75,
          "onClick": function () {
            function onClick() {
              return act("groupDispense", {
                selectedGroup: group.ref
              });
            }

            return onClick;
          }(),
          children: group.name
        }, index), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "trash",
          "lineHeight": 1.75,
          "onClick": function () {
            function onClick() {
              return act("deleteGroup", {
                selectedGroup: group.ref
              });
            }

            return onClick;
          }(),
          children: "Delete"
        }), " " + group.info]
      }, index);
    })
  })], 0);
};

exports.ChemGroups = ChemGroups;

/***/ }),

/***/ "./packages/tgui/interfaces/CloningConsole.js":
/*!****************************************************!*\
  !*** ./packages/tgui/interfaces/CloningConsole.js ***!
  \****************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.CloningConsole = exports.shortenNumber = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var _HealthStat = __webpack_require__(/*! ./common/HealthStat */ "./packages/tgui/interfaces/common/HealthStat.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var Suffixes = ['', 'k', 'M', 'B', 'T'];

var shortenNumber = function shortenNumber(value, minimumTier) {
  if (minimumTier === void 0) {
    minimumTier = 0;
  }

  var tier = Math.log10(Math.abs(value)) / 3 | 0;
  return tier === minimumTier ? value : "" + Math.round(value / Math.pow(10, tier * 3)) + Suffixes[tier];
};

exports.shortenNumber = shortenNumber;
var healthColorByLevel = ['#17d568', '#2ecc71', '#e67e22', '#ed5100', '#e74c3c', '#ed2814'];

var healthToColor = function healthToColor(oxy, tox, burn, brute) {
  var healthSum = oxy + tox + burn + brute;
  var level = (0, _math.clamp)(Math.ceil(healthSum / 25), 0, 5);
  return healthColorByLevel[level];
};

var Tab = {
  Functions: 'functions',
  Records: 'records',
  Pods: 'pods'
};
var Types = {
  Danger: 'danger',
  Info: 'info',
  Success: 'success'
};

var TypedNoticeBox = function TypedNoticeBox(props) {
  var type = props.type,
      rest = _objectWithoutPropertiesLoose(props, ["type"]);

  var typeProps = Object.assign({}, type === Types.Danger ? {
    danger: true
  } : {}, type === Types.Info ? {
    info: true
  } : {}, type === Types.Success ? {
    success: true
  } : {});
  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _components.NoticeBox, Object.assign({}, typeProps, rest)));
};

var CloningConsole = function CloningConsole(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data,
      act = _useBackend.act;

  var balance = data.balance,
      cloneSlave = data.cloneSlave,
      clonesForCash = data.clonesForCash; // N.B. uses `deletionTarget` that is shared with Records component

  var _useLocalState = (0, _backend.useLocalState)(context, 'deletionTarget', ''),
      deletionTarget = _useLocalState[0],
      setDeletionTarget = _useLocalState[1];

  var _useSharedState = (0, _backend.useSharedState)(context, 'tab', Tab.Records),
      tab = _useSharedState[0],
      setTab = _useSharedState[1];

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "theme": cloneSlave.some(Boolean) ? 'syndicate' : 'ntos',
    "width": 540,
    "height": 595,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: [deletionTarget && (0, _inferno.createComponentVNode)(2, _components.Modal, {
        "mx": 7,
        "fontSize": "31px",
        children: [(0, _inferno.createComponentVNode)(2, _components.Flex, {
          "align": "center",
          children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "mr": 2,
            "mt": 1,
            children: (0, _inferno.createComponentVNode)(2, _components.Icon, {
              "name": "trash"
            })
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            children: "Delete Record?"
          })]
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "mt": 2,
          "textAlign": "center",
          "fontSize": "24px",
          children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
            "lineHeight": "40px",
            "icon": "check",
            "color": "good",
            "onClick": function () {
              function onClick() {
                act('delete', {
                  ckey: deletionTarget
                });
                setDeletionTarget('');
              }

              return onClick;
            }(),
            children: "Yes"
          }), (0, _inferno.createComponentVNode)(2, _components.Button, {
            "width": 8,
            "align": "center",
            "mt": 2,
            "ml": 5,
            "lineHeight": "40px",
            "icon": "times",
            "color": "bad",
            "onClick": function () {
              function onClick() {
                return setDeletionTarget('');
              }

              return onClick;
            }(),
            children: "No"
          })]
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Section, {
        "fitted": true,
        children: (0, _inferno.createComponentVNode)(2, _components.Tabs, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
            "icon": "list",
            "selected": tab === Tab.Records,
            "onClick": function () {
              function onClick() {
                return setTab(Tab.Records);
              }

              return onClick;
            }(),
            children: "Records"
          }), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
            "icon": "box",
            "selected": tab === Tab.Pods,
            "onClick": function () {
              function onClick() {
                return setTab(Tab.Pods);
              }

              return onClick;
            }(),
            children: "Pods"
          }), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
            "icon": "wrench",
            "selected": tab === Tab.Functions,
            "onClick": function () {
              function onClick() {
                return setTab(Tab.Functions);
              }

              return onClick;
            }(),
            children: "Functions"
          })]
        })
      }), !!clonesForCash && (0, _inferno.createComponentVNode)(2, _components.Section, {
        children: ["Current machine credit: ", balance]
      }), (0, _inferno.createComponentVNode)(2, StatusSection), tab === Tab.Records && (0, _inferno.createComponentVNode)(2, Records), tab === Tab.Pods && (0, _inferno.createComponentVNode)(2, Pods), tab === Tab.Functions && (0, _inferno.createComponentVNode)(2, Functions)]
    })
  });
};

exports.CloningConsole = CloningConsole;

var Functions = function Functions(props, context) {
  var _useBackend2 = (0, _backend.useBackend)(context),
      act = _useBackend2.act,
      data = _useBackend2.data;

  var allowMindErasure = data.allowMindErasure,
      disk = data.disk,
      diskReadOnly = data.diskReadOnly,
      geneticAnalysis = data.geneticAnalysis,
      mindWipe = data.mindWipe;
  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Advanced Genetic Analysis",
    children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
        "bold": true,
        children: "Notice:"
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        children: "Enabling this feature will prompt the attached clone pod to transfer active genetic mutations from the genetic record to the subject during cloning."
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        children: "The cloning process will be slightly slower as a result."
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      "pt": 2,
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "textAlign": "center",
        "width": 6.7,
        "icon": geneticAnalysis ? 'toggle-on' : 'toggle-off',
        "color": geneticAnalysis ? 'good' : 'bad',
        "onClick": function () {
          function onClick() {
            return act('toggleGeneticAnalysis');
          }

          return onClick;
        }(),
        children: geneticAnalysis ? 'Enabled' : 'Disabled'
      })
    })]
  }), !!allowMindErasure && (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Criminal Rehabilitation Controls",
    children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
        "bold": true,
        children: "Notice:"
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        children: "Enabling this feature will enable an experimental criminal rehabilitation routine."
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        "bold": true,
        children: "Human use is specifically forbidden by the Space Geneva convention."
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      "pt": 2,
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "textAlign": "center",
        "width": 6.7,
        "icon": mindWipe ? 'toggle-on' : 'toggle-off',
        "color": mindWipe ? 'good' : 'bad',
        "onClick": function () {
          function onClick() {
            return act('mindWipeToggle');
          }

          return onClick;
        }(),
        children: mindWipe ? 'Enabled' : 'Disabled'
      })
    })]
  }), !!disk && (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Disk Controls",
    "buttons": (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
      "icon": "upload",
      "color": "blue",
      "onClick": function () {
        function onClick() {
          return act("load");
        }

        return onClick;
      }(),
      children: "Load from disk"
    }), (0, _inferno.createComponentVNode)(2, _components.Button, {
      "icon": "eject",
      "color": "bad",
      "onClick": function () {
        function onClick() {
          return act("eject");
        }

        return onClick;
      }(),
      children: "Eject Disk"
    })], 4),
    children: (0, _inferno.createComponentVNode)(2, _components.Box, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
        "color": diskReadOnly ? 'bad' : 'good',
        "name": 'check'
      }), ' ', diskReadOnly ? 'Disk is read only.' : 'Disk is writeable.']
    })
  })], 0);
};

var StatusSection = function StatusSection(props, context) {
  var _useBackend3 = (0, _backend.useBackend)(context),
      act = _useBackend3.act,
      data = _useBackend3.data;

  var scannerLocked = data.scannerLocked,
      occupantScanned = data.occupantScanned,
      scannerOccupied = data.scannerOccupied,
      scannerGone = data.scannerGone;
  var message = data.message || {
    text: '',
    status: ''
  };
  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Status Messages",
    "height": 7,
    children: message.text && (0, _inferno.createComponentVNode)(2, TypedNoticeBox, {
      "type": message.status,
      "textColor": "white",
      "height": 3.17,
      "align": "center",
      "style": {
        'vertical-align': 'middle',
        'horizontal-align': 'middle'
      },
      children: (0, _inferno.createComponentVNode)(2, _components.Box, {
        "style": {
          position: 'relative',
          left: '50%',
          top: '50%',
          transform: 'translate(-50%, -50%)'
        },
        children: message.text
      })
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Scanner Controls",
    "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
      "width": 7,
      "icon": scannerLocked ? 'unlock' : 'lock-open',
      "align": "center",
      "color": scannerLocked ? 'bad' : 'good',
      "onClick": function () {
        function onClick() {
          return act('toggleLock');
        }

        return onClick;
      }(),
      children: scannerLocked ? 'Locked' : 'Unlocked'
    }),
    children: [(!!scannerGone || !!occupantScanned || !scannerOccupied) && (0, _inferno.createComponentVNode)(2, _components.Box, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
        "color": scannerGone || !scannerOccupied ? 'bad' : 'good',
        "name": scannerGone || !scannerOccupied ? 'times' : 'check'
      }), ' ', !!scannerGone && 'No scanner detected.', !scannerGone && (scannerOccupied ? 'Occupant scanned.' : 'Scanner has no occupant.')]
    }), !scannerGone && !occupantScanned && !!scannerOccupied && (0, _inferno.createComponentVNode)(2, _components.Button, {
      "width": scannerGone ? 8 : 7,
      "icon": "dna",
      "align": "center",
      "color": scannerGone ? 'bad' : 'good',
      "disabled": occupantScanned || scannerGone,
      "onClick": function () {
        function onClick() {
          return act('scan');
        }

        return onClick;
      }(),
      children: "Scan"
    })]
  })], 4);
};

var Records = function Records(props, context) {
  var _useBackend4 = (0, _backend.useBackend)(context),
      act = _useBackend4.act,
      data = _useBackend4.data;

  var disk = data.disk,
      diskReadOnly = data.diskReadOnly,
      allowedToDelete = data.allowedToDelete,
      meatLevels = data.meatLevels;
  var records = data.cloneRecords || []; // N.B. uses `deletionTarget` that is shared with CloningConsole component

  var _useLocalState2 = (0, _backend.useLocalState)(context, 'deletionTarget', ''),
      setDeletionTarget = _useLocalState2[1];

  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Section, {
    "mb": 0,
    "title": "Records",
    "style": {
      'border-bottom': '2px solid rgba(51, 51, 51, 0.4);'
    },
    children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
      "className": "cloning-console__flex__head",
      children: (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "className": "cloning-console__head__row",
        "mr": 2,
        children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
          "className": "cloning-console__head__item",
          "style": {
            'width': '190px'
          },
          children: "Name"
        }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
          "className": "cloning-console__head__item",
          "style": {
            'width': '160px'
          },
          children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
            children: "Damage"
          }), (0, _inferno.createComponentVNode)(2, _components.Box, {
            "style": {
              position: 'absolute',
              left: '50%',
              top: '20%',
              transform: 'translate(-40%, 22px)'
            },
            "fontSize": "9px",
            children: "OXY / TOX / BURN / BRUTE"
          })]
        }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
          "className": "cloning-console__head__item",
          "style": {
            'width': '155px'
          },
          children: "Actions"
        })]
      })
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Section, {
    "scrollable": true,
    children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
      children: (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "className": "cloning-console__flex__table",
        children: (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
          children: records.map(function (record) {
            return (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
              "className": "cloning-console__body__row",
              children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                "inline": true,
                "className": "cloning-console__body__item",
                "style": {
                  'width': '190px'
                },
                children: record.name
              }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                "className": "cloning-console__body__item",
                "style": {
                  'width': '160px'
                },
                children: [(0, _inferno.createComponentVNode)(2, _components.ColorBox, {
                  "mr": 1,
                  "color": healthToColor(record.health.OXY, record.health.TOX, record.health.BURN, record.health.BRUTE)
                }), record.implant && record.health.OXY >= 0 ? (0, _inferno.createComponentVNode)(2, _components.Box, {
                  "inline": true,
                  children: [(0, _inferno.createComponentVNode)(2, _HealthStat.HealthStat, {
                    "inline": true,
                    "align": "center",
                    "type": "oxy",
                    "width": 2,
                    children: shortenNumber(record.health.OXY)
                  }), "/", (0, _inferno.createComponentVNode)(2, _HealthStat.HealthStat, {
                    "inline": true,
                    "align": "center",
                    "type": "toxin",
                    "width": 2,
                    children: shortenNumber(record.health.TOX)
                  }), "/", (0, _inferno.createComponentVNode)(2, _HealthStat.HealthStat, {
                    "inline": true,
                    "align": "center",
                    "type": "burn",
                    "width": 2,
                    children: shortenNumber(record.health.BURN)
                  }), "/", (0, _inferno.createComponentVNode)(2, _HealthStat.HealthStat, {
                    "inline": true,
                    "align": "center",
                    "type": "brute",
                    "width": 2,
                    children: shortenNumber(record.health.BRUTE)
                  })]
                }) : 'No Implant Detected']
              }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                "align": "baseline",
                "className": "cloning-console__body__item",
                "style": {
                  'width': '155px'
                },
                children: [!!allowedToDelete && (0, _inferno.createComponentVNode)(2, _components.Button, {
                  "icon": "trash",
                  "color": "bad",
                  "onClick": function () {
                    function onClick() {
                      return setDeletionTarget(record.ckey);
                    }

                    return onClick;
                  }()
                }), !!disk && (0, _inferno.createComponentVNode)(2, _components.Button, {
                  "icon": !!diskReadOnly || !!record.saved ? '' : 'save',
                  "color": "blue",
                  "alignText": "center",
                  "width": "22px",
                  "disabled": record.saved || diskReadOnly,
                  "onClick": function () {
                    function onClick() {
                      return act('saveToDisk', {
                        ckey: record.ckey
                      });
                    }

                    return onClick;
                  }(),
                  children: [!diskReadOnly && !!record.saved && (0, _inferno.createComponentVNode)(2, _components.Icon, {
                    "color": "black",
                    "name": "check"
                  }), !!diskReadOnly && (0, _inferno.createComponentVNode)(2, _components.Icon.Stack, {
                    children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
                      "color": "black",
                      "name": "pen"
                    }), (0, _inferno.createComponentVNode)(2, _components.Icon, {
                      "color": "black",
                      "name": "slash"
                    })]
                  })]
                }), (0, _inferno.createComponentVNode)(2, _components.Button, {
                  "icon": "dna",
                  "color": "good",
                  "disabled": !meatLevels.length,
                  "onClick": function () {
                    function onClick() {
                      return act('clone', {
                        ckey: record.ckey
                      });
                    }

                    return onClick;
                  }(),
                  children: "Clone"
                })]
              })]
            }, record.id);
          })
        })
      })
    })
  })], 4);
};

var Pods = function Pods(props, context) {
  var _useBackend5 = (0, _backend.useBackend)(context),
      data = _useBackend5.data;

  var completion = data.completion,
      meatLevels = data.meatLevels,
      podNames = data.podNames;

  if (!meatLevels.length) {
    return (0, _inferno.createComponentVNode)(2, _components.Section, {
      "title": "Cloning Pod Status",
      children: (0, _inferno.createComponentVNode)(2, _components.Box, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
          "color": "bad",
          "name": "times"
        }), " No Pod Detected"]
      })
    });
  }

  return meatLevels.map(function (meat, i) {
    return (0, _inferno.createComponentVNode)(2, _components.Section, {
      "title": podNames[i].replace(/cloning pod/, "Cloning Pod") + " Status",
      children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
        children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Completion",
          children: (0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
            "value": completion[i],
            "maxValue": 100,
            "minValue": 0,
            "ranges": {
              good: [90, Infinity],
              average: [25, 90],
              bad: [-Infinity, 25]
            }
          })
        }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Bio-Matter",
          children: (0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
            "value": meat,
            "maxValue": 100,
            "minValue": 0,
            "ranges": {
              good: [50, 100],
              average: [25, 50],
              bad: [0, 25]
            }
          })
        })]
      })
    }, "pod" + i);
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/ComUplink/index.tsx":
/*!******************************************************!*\
  !*** ./packages/tgui/interfaces/ComUplink/index.tsx ***!
  \******************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ComUplink = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../../layouts */ "./packages/tgui/layouts/index.js");

var _stringUtils = __webpack_require__(/*! ../common/stringUtils */ "./packages/tgui/interfaces/common/stringUtils.js");

/**
 * @file
 * @copyright 2021
 * @author Zonespace (https://github.com/Zonespace27)
 * @license MIT
 */
var ComUplink = function ComUplink(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data;

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "theme": "syndicate",
    "title": "Syndicate Commander Uplink",
    "width": 500,
    "height": 500,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      "scrollable": true,
      children: [(0, _inferno.createComponentVNode)(2, _components.Stack, {
        "className": "ComUplink"
      }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
        children: (0, _inferno.createComponentVNode)(2, _components.Section, {
          "fill": true,
          children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
            children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
              "label": "Points",
              children: (0, _inferno.createComponentVNode)(2, _components.Box, {
                "inline": true,
                "bold": true,
                "color": "green",
                "mr": "5px",
                "className": "ComUplink__Points--commander",
                children: data.points
              }, data.points)
            })
          })
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
        "grow": 1,
        children: [(0, _inferno.createComponentVNode)(2, _components.Section, {
          "fill": true,
          "scrollable": true,
          "title": "Uplink Items"
        }), (0, _inferno.createComponentVNode)(2, _components.Collapsible, {
          "className": "ComUplink__Category--Main",
          "title": "Equipment",
          "open": true,
          "color": "Main",
          children: (0, _inferno.createComponentVNode)(2, _components.Table, {
            children: data.stock.filter(function (stock) {
              return stock.category === "Main";
            }).map(function (stock) {
              return (0, _inferno.createComponentVNode)(2, Stock, {
                "stock": stock
              }, stock.name);
            })
          })
        })]
      })]
    })
  });
};

exports.ComUplink = ComUplink;

var Stock = function Stock(_ref, context) {
  var stock = _ref.stock;

  var _useBackend2 = (0, _backend.useBackend)(context),
      data = _useBackend2.data,
      act = _useBackend2.act;

  return (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
    "className": "ComUplink__Row",
    "opacity": stock.cost > data.points[stock.category] ? 0.5 : 1,
    children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      "className": "ComUplink__Cell",
      "py": "5px",
      children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
        "mb": "5px",
        "bold": true,
        children: stock.name
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        children: stock.description
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      "className": "ComUplink__Cell",
      "py": "5px",
      "textAlign": "right",
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "disabled": stock.cost > data.points,
        "onClick": function () {
          function onClick() {
            return act('redeem', {
              ref: stock.ref
            });
          }

          return onClick;
        }(),
        children: ["Purchase ", stock.cost, " ", (0, _stringUtils.pluralize)('point', stock.cost)]
      })
    })]
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/ComUplink/type.ts":
/*!****************************************************!*\
  !*** ./packages/tgui/interfaces/ComUplink/type.ts ***!
  \****************************************************/
/***/ (function() {

"use strict";


/***/ }),

/***/ "./packages/tgui/interfaces/CyborgModuleRewriter/EmptyPlaceholder.tsx":
/*!****************************************************************************!*\
  !*** ./packages/tgui/interfaces/CyborgModuleRewriter/EmptyPlaceholder.tsx ***!
  \****************************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.EmptyPlaceholder = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var styles = _interopRequireWildcard(__webpack_require__(/*! ./style */ "./packages/tgui/interfaces/CyborgModuleRewriter/style.ts"));

function _getRequireWildcardCache() { if (typeof WeakMap !== "function") return null; var cache = new WeakMap(); _getRequireWildcardCache = function _getRequireWildcardCache() { return cache; }; return cache; }

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } if (obj === null || typeof obj !== "object" && typeof obj !== "function") { return { "default": obj }; } var cache = _getRequireWildcardCache(); if (cache && cache.has(obj)) { return cache.get(obj); } var newObj = {}; var hasPropertyDescriptor = Object.defineProperty && Object.getOwnPropertyDescriptor; for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) { var desc = hasPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : null; if (desc && (desc.get || desc.set)) { Object.defineProperty(newObj, key, desc); } else { newObj[key] = obj[key]; } } } newObj["default"] = obj; if (cache) { cache.set(obj, newObj); } return newObj; }

/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */
var EmptyPlaceholder = function EmptyPlaceholder(props) {
  var children = props.children,
      className = props.className;
  var cn = (0, _react.classes)([styles.EmptyPlaceholder, className]);
  return (0, _inferno.createVNode)(1, "div", cn, children, 0);
};

exports.EmptyPlaceholder = EmptyPlaceholder;
EmptyPlaceholder.defaultHooks = _react.pureComponentHooks;

/***/ }),

/***/ "./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/Module.tsx":
/*!*****************************************************************************!*\
  !*** ./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/Module.tsx ***!
  \*****************************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Module = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! ../../../components */ "./packages/tgui/components/index.js");

var _Tools = __webpack_require__(/*! ./Tools */ "./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/Tools.tsx");

/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */
var resetOptions = [{
  id: 'brobocop',
  name: 'Brobocop'
}, {
  id: 'chemistry',
  name: 'Chemistry'
}, {
  id: 'civilian',
  name: 'Civilian'
}, {
  id: 'engineering',
  name: 'Engineering'
}, {
  id: 'medical',
  name: 'Medical'
}, {
  id: 'mining',
  name: 'Mining'
}];

var Module = function Module(props) {
  var onMoveToolDown = props.onMoveToolDown,
      onMoveToolUp = props.onMoveToolUp,
      onRemoveTool = props.onRemoveTool,
      onResetModule = props.onResetModule,
      tools = props.tools;
  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Preset",
    children: resetOptions.map(function (resetOption) {
      var id = resetOption.id,
          name = resetOption.name;
      return (0, _inferno.createComponentVNode)(2, _components.Button, {
        "onClick": function () {
          function onClick() {
            return onResetModule(id);
          }

          return onClick;
        }(),
        "title": name,
        children: name
      }, id);
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Tools",
    children: (0, _inferno.createComponentVNode)(2, _Tools.Tools, {
      "onMoveToolDown": onMoveToolDown,
      "onMoveToolUp": onMoveToolUp,
      "onRemoveTool": onRemoveTool,
      "tools": tools
    })
  })], 4);
};

exports.Module = Module;

/***/ }),

/***/ "./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/Tools.tsx":
/*!****************************************************************************!*\
  !*** ./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/Tools.tsx ***!
  \****************************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Tools = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! ../../../components */ "./packages/tgui/components/index.js");

var _EmptyPlaceholder = __webpack_require__(/*! ../EmptyPlaceholder */ "./packages/tgui/interfaces/CyborgModuleRewriter/EmptyPlaceholder.tsx");

var styles = _interopRequireWildcard(__webpack_require__(/*! ../style */ "./packages/tgui/interfaces/CyborgModuleRewriter/style.ts"));

function _getRequireWildcardCache() { if (typeof WeakMap !== "function") return null; var cache = new WeakMap(); _getRequireWildcardCache = function _getRequireWildcardCache() { return cache; }; return cache; }

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } if (obj === null || typeof obj !== "object" && typeof obj !== "function") { return { "default": obj }; } var cache = _getRequireWildcardCache(); if (cache && cache.has(obj)) { return cache.get(obj); } var newObj = {}; var hasPropertyDescriptor = Object.defineProperty && Object.getOwnPropertyDescriptor; for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) { var desc = hasPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : null; if (desc && (desc.get || desc.set)) { Object.defineProperty(newObj, key, desc); } else { newObj[key] = obj[key]; } } } newObj["default"] = obj; if (cache) { cache.set(obj, newObj); } return newObj; }

/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */
var Tool = function Tool(props) {
  var children = props.children,
      onMoveToolDown = props.onMoveToolDown,
      onMoveToolUp = props.onMoveToolUp,
      onRemoveTool = props.onRemoveTool;
  return (0, _inferno.createVNode)(1, "div", null, [(0, _inferno.createComponentVNode)(2, _components.Button, {
    "icon": "arrow-up",
    "onClick": onMoveToolUp,
    "title": "Move Up"
  }), (0, _inferno.createComponentVNode)(2, _components.Button, {
    "icon": "arrow-down",
    "onClick": onMoveToolDown,
    "title": "Move Down"
  }), (0, _inferno.createComponentVNode)(2, _components.Button, {
    "icon": "trash",
    "onClick": onRemoveTool,
    "title": "Remove"
  }), (0, _inferno.createVNode)(1, "span", styles.ToolLabel, children, 0)], 4);
};

var Tools = function Tools(props) {
  var _onMoveToolDown = props.onMoveToolDown,
      _onMoveToolUp = props.onMoveToolUp,
      _onRemoveTool = props.onRemoveTool,
      _props$tools = props.tools,
      tools = _props$tools === void 0 ? [] : _props$tools;
  return (0, _inferno.createVNode)(1, "div", null, tools.length > 0 ? tools.map(function (tool) {
    var name = tool.name,
        toolRef = tool.ref;
    return (0, _inferno.createComponentVNode)(2, Tool, {
      "onMoveToolDown": function () {
        function onMoveToolDown() {
          return _onMoveToolDown(toolRef);
        }

        return onMoveToolDown;
      }(),
      "onMoveToolUp": function () {
        function onMoveToolUp() {
          return _onMoveToolUp(toolRef);
        }

        return onMoveToolUp;
      }(),
      "onRemoveTool": function () {
        function onRemoveTool() {
          return _onRemoveTool(toolRef);
        }

        return onRemoveTool;
      }(),
      children: name
    }, toolRef);
  }) : (0, _inferno.createComponentVNode)(2, _EmptyPlaceholder.EmptyPlaceholder, {
    children: "Module has no tools"
  }), 0);
};

exports.Tools = Tools;

/***/ }),

/***/ "./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/index.tsx":
/*!****************************************************************************!*\
  !*** ./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/index.tsx ***!
  \****************************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ModuleView = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! ../../../components */ "./packages/tgui/components/index.js");

var _EmptyPlaceholder = __webpack_require__(/*! ../EmptyPlaceholder */ "./packages/tgui/interfaces/CyborgModuleRewriter/EmptyPlaceholder.tsx");

var _Module = __webpack_require__(/*! ./Module */ "./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/Module.tsx");

/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */
// width hard-coded to allow display of widest current module name
// without resizing when ejected/reset
var ModuleListWidth = 18;

var ModuleView = function ModuleView(props) {
  var _props$modules = props.modules;
  _props$modules = _props$modules === void 0 ? {} : _props$modules;
  var _props$modules$availa = _props$modules.available,
      available = _props$modules$availa === void 0 ? [] : _props$modules$availa,
      selected = _props$modules.selected,
      onEjectModule = props.onEjectModule,
      onMoveToolDown = props.onMoveToolDown,
      onMoveToolUp = props.onMoveToolUp,
      onRemoveTool = props.onRemoveTool,
      onResetModule = props.onResetModule,
      onSelectModule = props.onSelectModule;

  var _ref = selected || {},
      selectedModuleRef = _ref.ref,
      _ref$tools = _ref.tools,
      tools = _ref$tools === void 0 ? [] : _ref$tools;

  var handleMoveToolDown = function handleMoveToolDown(toolRef) {
    return onMoveToolDown(selectedModuleRef, toolRef);
  };

  var handleMoveToolUp = function handleMoveToolUp(toolRef) {
    return onMoveToolUp(selectedModuleRef, toolRef);
  };

  var handleRemoveTool = function handleRemoveTool(toolRef) {
    return onRemoveTool(selectedModuleRef, toolRef);
  };

  var handleResetModule = function handleResetModule(moduleId) {
    return onResetModule(selectedModuleRef, moduleId);
  };

  return available.length > 0 ? (0, _inferno.createComponentVNode)(2, _components.Flex, {
    children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "width": ModuleListWidth,
      "mr": 1,
      children: (0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Modules",
        "fitted": true,
        children: (0, _inferno.createComponentVNode)(2, _components.Tabs, {
          "vertical": true,
          children: available.map(function (module) {
            var moduleRef = module.ref,
                name = module.name;
            var ejectButton = (0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": "eject",
              "color": "transparent",
              "onClick": function () {
                function onClick() {
                  return onEjectModule(moduleRef);
                }

                return onClick;
              }(),
              "title": "Eject " + name
            });
            return (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
              "onClick": function () {
                function onClick() {
                  return onSelectModule(moduleRef);
                }

                return onClick;
              }(),
              "rightSlot": ejectButton,
              "selected": moduleRef === selectedModuleRef,
              children: name
            }, moduleRef);
          })
        })
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "grow": 1,
      "basis": 0,
      children: selectedModuleRef ? (0, _inferno.createComponentVNode)(2, _Module.Module, {
        "onMoveToolDown": handleMoveToolDown,
        "onMoveToolUp": handleMoveToolUp,
        "onRemoveTool": handleRemoveTool,
        "onResetModule": handleResetModule,
        "tools": tools
      }) : (0, _inferno.createComponentVNode)(2, _components.Section, {
        children: (0, _inferno.createComponentVNode)(2, _EmptyPlaceholder.EmptyPlaceholder, {
          children: "No module selected"
        })
      })
    })]
  }) : (0, _inferno.createComponentVNode)(2, _components.Section, {
    children: (0, _inferno.createComponentVNode)(2, _EmptyPlaceholder.EmptyPlaceholder, {
      children: "No modules inserted"
    })
  });
};

exports.ModuleView = ModuleView;

/***/ }),

/***/ "./packages/tgui/interfaces/CyborgModuleRewriter/action.ts":
/*!*****************************************************************!*\
  !*** ./packages/tgui/interfaces/CyborgModuleRewriter/action.ts ***!
  \*****************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.selectModule = exports.resetModule = exports.removeTool = exports.moveTool = exports.ejectModule = void 0;

var _type = __webpack_require__(/*! ./type */ "./packages/tgui/interfaces/CyborgModuleRewriter/type.ts");

/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */
var createAction = function createAction(action) {
  return function (act, payload) {
    return act(action, payload);
  };
};

var ejectModule = createAction(_type.Action.EjectModule);
exports.ejectModule = ejectModule;
var moveTool = createAction(_type.Action.MoveTool);
exports.moveTool = moveTool;
var removeTool = createAction(_type.Action.RemoveTool);
exports.removeTool = removeTool;
var resetModule = createAction(_type.Action.ResetModule);
exports.resetModule = resetModule;
var selectModule = createAction(_type.Action.SelectModule);
exports.selectModule = selectModule;

/***/ }),

/***/ "./packages/tgui/interfaces/CyborgModuleRewriter/index.tsx":
/*!*****************************************************************!*\
  !*** ./packages/tgui/interfaces/CyborgModuleRewriter/index.tsx ***!
  \*****************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.CyborgModuleRewriter = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _layouts = __webpack_require__(/*! ../../layouts */ "./packages/tgui/layouts/index.js");

var _ModuleView = __webpack_require__(/*! ./ModuleView */ "./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/index.tsx");

var _action = __webpack_require__(/*! ./action */ "./packages/tgui/interfaces/CyborgModuleRewriter/action.ts");

var styles = _interopRequireWildcard(__webpack_require__(/*! ./style */ "./packages/tgui/interfaces/CyborgModuleRewriter/style.ts"));

var _type = __webpack_require__(/*! ./type */ "./packages/tgui/interfaces/CyborgModuleRewriter/type.ts");

function _getRequireWildcardCache() { if (typeof WeakMap !== "function") return null; var cache = new WeakMap(); _getRequireWildcardCache = function _getRequireWildcardCache() { return cache; }; return cache; }

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } if (obj === null || typeof obj !== "object" && typeof obj !== "function") { return { "default": obj }; } var cache = _getRequireWildcardCache(); if (cache && cache.has(obj)) { return cache.get(obj); } var newObj = {}; var hasPropertyDescriptor = Object.defineProperty && Object.getOwnPropertyDescriptor; for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) { var desc = hasPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : null; if (desc && (desc.get || desc.set)) { Object.defineProperty(newObj, key, desc); } else { newObj[key] = obj[key]; } } } newObj["default"] = obj; if (cache) { cache.set(obj, newObj); } return newObj; }

/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */
var CyborgModuleRewriter = function CyborgModuleRewriter(_props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var modules = data.modules;

  var handleEjectModule = function handleEjectModule(moduleRef) {
    return (0, _action.ejectModule)(act, {
      moduleRef: moduleRef
    });
  };

  var handleMoveToolDown = function handleMoveToolDown(moduleRef, toolRef) {
    return (0, _action.moveTool)(act, {
      dir: _type.Direction.Down,
      moduleRef: moduleRef,
      toolRef: toolRef
    });
  };

  var handleMoveToolUp = function handleMoveToolUp(moduleRef, toolRef) {
    return (0, _action.moveTool)(act, {
      dir: _type.Direction.Up,
      moduleRef: moduleRef,
      toolRef: toolRef
    });
  };

  var handleRemoveTool = function handleRemoveTool(moduleRef, toolRef) {
    return (0, _action.removeTool)(act, {
      moduleRef: moduleRef,
      toolRef: toolRef
    });
  };

  var handleResetModule = function handleResetModule(moduleRef, moduleId) {
    return (0, _action.resetModule)(act, {
      moduleId: moduleId,
      moduleRef: moduleRef
    });
  };

  var handleSelectModule = function handleSelectModule(moduleRef) {
    return (0, _action.selectModule)(act, {
      moduleRef: moduleRef
    });
  };

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 670,
    "height": 640,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      "className": styles.Block,
      "scrollable": true,
      children: (0, _inferno.createComponentVNode)(2, _ModuleView.ModuleView, {
        "modules": modules,
        "onEjectModule": handleEjectModule,
        "onMoveToolDown": handleMoveToolDown,
        "onMoveToolUp": handleMoveToolUp,
        "onRemoveTool": handleRemoveTool,
        "onResetModule": handleResetModule,
        "onSelectModule": handleSelectModule
      })
    })
  });
};

exports.CyborgModuleRewriter = CyborgModuleRewriter;

/***/ }),

/***/ "./packages/tgui/interfaces/CyborgModuleRewriter/style.ts":
/*!****************************************************************!*\
  !*** ./packages/tgui/interfaces/CyborgModuleRewriter/style.ts ***!
  \****************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.EmptyPlaceholder = exports.ToolLabel = exports.ModuleView = exports.Block = void 0;

var _bem = __webpack_require__(/*! common/bem */ "./packages/common/bem.ts");

/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */
var Block = 'cyborg-module-rewriter-interface';
exports.Block = Block;
var ModuleView = (0, _bem.block)(Block, 'module-view');
exports.ModuleView = ModuleView;
var ToolLabel = (0, _bem.element)(ModuleView, 'tool-label');
exports.ToolLabel = ToolLabel;
var EmptyPlaceholder = (0, _bem.block)(Block, 'empty-placeholder');
exports.EmptyPlaceholder = EmptyPlaceholder;

/***/ }),

/***/ "./packages/tgui/interfaces/CyborgModuleRewriter/type.ts":
/*!***************************************************************!*\
  !*** ./packages/tgui/interfaces/CyborgModuleRewriter/type.ts ***!
  \***************************************************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.Direction = exports.Action = void 0;

/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */
var Action;
exports.Action = Action;

(function (Action) {
  Action["EjectModule"] = "module-eject";
  Action["MoveTool"] = "tool-move";
  Action["RemoveTool"] = "tool-remove";
  Action["ResetModule"] = "module-reset";
  Action["SelectModule"] = "module-select";
})(Action || (exports.Action = Action = {}));

var Direction;
exports.Direction = Direction;

(function (Direction) {
  Direction["Up"] = "up";
  Direction["Down"] = "down";
})(Direction || (exports.Direction = Direction = {}));

/***/ }),

/***/ "./packages/tgui/interfaces/DJPanel.js":
/*!*********************************************!*\
  !*** ./packages/tgui/interfaces/DJPanel.js ***!
  \*********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.DJPanel = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _format = __webpack_require__(/*! ../format.js */ "./packages/tgui/format.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

/**
 * @file
 * @copyright 2020
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */
var DJPanel = function DJPanel(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var loadedSound = data.loadedSound,
      adminChannel = data.adminChannel,
      preloadedSounds = data.preloadedSounds;
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 430,
    "height": 306,
    "title": "DJ Panel",
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Section, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
          children: [(0, _inferno.createVNode)(1, "strong", null, "Active Soundfile: ", 16), (0, _inferno.createComponentVNode)(2, _components.Button, {
            "icon": loadedSound ? 'file-audio' : 'upload',
            "selected": !loadedSound,
            "content": loadedSound ? (0, _format.truncate)(loadedSound, 38) : "Upload",
            "tooltip": loadedSound,
            "onClick": function () {
              function onClick() {
                return act('set-file');
              }

              return onClick;
            }()
          })]
        }), (0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, KnobZone)]
      }), (0, _inferno.createComponentVNode)(2, _components.Section, {
        children: (0, _inferno.createComponentVNode)(2, _components.Box, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
            "icon": "music",
            "selected": loadedSound,
            "disabled": !loadedSound,
            "content": "Play Music",
            "onClick": function () {
              function onClick() {
                return act('play-music');
              }

              return onClick;
            }()
          }), (0, _inferno.createComponentVNode)(2, _components.Button, {
            "icon": "volume-up",
            "selected": loadedSound,
            "disabled": !loadedSound,
            "content": "Play Sound",
            "onClick": function () {
              function onClick() {
                return act('play-sound');
              }

              return onClick;
            }()
          }), (0, _inferno.createComponentVNode)(2, _components.Button, {
            "icon": "record-vinyl",
            "selected": loadedSound,
            "disabled": !loadedSound,
            "content": "Play Ambience",
            "onClick": function () {
              function onClick() {
                return act('play-ambience');
              }

              return onClick;
            }()
          }), (0, _inferno.createComponentVNode)(2, _components.Box, {
            "as": "span",
            "color": "grey",
            "textAlign": "right",
            "pl": 1,
            children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
              "name": "satellite"
            }), " Channel: ", (0, _inferno.createVNode)(1, "em", null, -adminChannel + 1024, 0)]
          })]
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Section, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
            "content": "Play Remote",
            "onClick": function () {
              function onClick() {
                return act('play-remote');
              }

              return onClick;
            }()
          }), (0, _inferno.createComponentVNode)(2, _components.Button, {
            "disabled": !loadedSound,
            "content": "Play To Player",
            "onClick": function () {
              function onClick() {
                return act('play-player');
              }

              return onClick;
            }()
          })]
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
            "disabled": !loadedSound,
            "content": "Preload Sound",
            "onClick": function () {
              function onClick() {
                return act('preload-sound');
              }

              return onClick;
            }()
          }), (0, _inferno.createComponentVNode)(2, _components.Button, {
            "disabled": !Object.keys(preloadedSounds).length,
            "content": "Play Preloaded Sound",
            "onClick": function () {
              function onClick() {
                return act('play-preloaded');
              }

              return onClick;
            }()
          })]
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
            "color": "yellow",
            "content": "Toggle DJ Announcements",
            "onClick": function () {
              function onClick() {
                return act('toggle-announce');
              }

              return onClick;
            }()
          }), (0, _inferno.createComponentVNode)(2, _components.Button, {
            "color": "yellow",
            "content": "Toggle DJ For Player",
            "onClick": function () {
              function onClick() {
                return act('toggle-player-dj');
              }

              return onClick;
            }()
          })]
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
            "icon": "stop",
            "color": "red",
            "content": "Stop Last Sound",
            "onClick": function () {
              function onClick() {
                return act('stop-sound');
              }

              return onClick;
            }()
          }), (0, _inferno.createComponentVNode)(2, _components.Button, {
            "icon": "broadcast-tower",
            "color": "red",
            "content": "Stop The Radio For Everyone",
            "onClick": function () {
              function onClick() {
                return act('stop-radio');
              }

              return onClick;
            }()
          })]
        })]
      }), (0, _inferno.createComponentVNode)(2, AnnounceActive)]
    })
  });
};

exports.DJPanel = DJPanel;

var AnnounceActive = function AnnounceActive(props, context) {
  var _useBackend2 = (0, _backend.useBackend)(context),
      data = _useBackend2.data;

  var announceMode = data.announceMode;

  if (announceMode) {
    return (0, _inferno.createComponentVNode)(2, _components.NoticeBox, {
      "info": true,
      children: "Announce Mode Enabled"
    });
  }
};

var formatDoublePercent = function formatDoublePercent(value) {
  return (0, _math.toFixed)(value * 2) + '%';
};

var formatHundredPercent = function formatHundredPercent(value) {
  return (0, _math.toFixed)(value * 100) + '%';
};

var KnobZone = function KnobZone(props, context) {
  var _useBackend3 = (0, _backend.useBackend)(context),
      act = _useBackend3.act,
      data = _useBackend3.data;

  var loadedSound = data.loadedSound,
      volume = data.volume,
      frequency = data.frequency;

  var setVolume = function setVolume(e, value) {
    return act('set-volume', {
      volume: value
    });
  };

  var resetVolume = function resetVolume(e, value) {
    return act('set-volume', {
      volume: "reset"
    });
  };

  var setFreq = function setFreq(e, value) {
    return act('set-freq', {
      frequency: value
    });
  };

  var resetFreq = function resetFreq(e, value) {
    return act('set-freq', {
      frequency: "reset"
    });
  };

  return (0, _inferno.createComponentVNode)(2, _components.Box, {
    children: (0, _inferno.createComponentVNode)(2, _components.LabeledControls, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledControls.Item, {
        "label": "Volume",
        children: (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
          "animated": true,
          "value": volume,
          "minValue": 0,
          "maxValue": 100,
          "format": formatDoublePercent,
          "onDrag": setVolume
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledControls.Item, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Knob, {
          "minValue": 0,
          "maxValue": 100,
          "ranges": {
            primary: [20, 80],
            average: [10, 90],
            bad: [0, 100]
          },
          "value": volume,
          "format": formatDoublePercent,
          "onDrag": setVolume
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "sync-alt",
          "top": "0.3em",
          "content": "Reset",
          "onClick": resetVolume
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledControls.Item, {
        "label": "Frequency",
        children: (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
          "animated": true,
          "value": frequency,
          "step": 0.1,
          "minValue": -100,
          "maxValue": 100,
          "format": formatHundredPercent,
          "onDrag": setFreq
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledControls.Item, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Knob, {
          "disabled": !loadedSound,
          "minValue": -100,
          "maxValue": 100,
          "step": 0.1,
          "stepPixelSize": 0.1,
          "ranges": {
            primary: [-40, 40],
            average: [-70, 70],
            bad: [-100, 100]
          },
          "value": frequency,
          "format": formatHundredPercent,
          "onDrag": setFreq
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "sync-alt",
          "top": "0.3em",
          "content": "Reset",
          "onClick": resetFreq
        })]
      })]
    })
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/DisposalChute/index.tsx":
/*!**********************************************************!*\
  !*** ./packages/tgui/interfaces/DisposalChute/index.tsx ***!
  \**********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.DisposalChute = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../../layouts */ "./packages/tgui/layouts/index.js");

var _ListSearch = __webpack_require__(/*! ../common/ListSearch */ "./packages/tgui/interfaces/common/ListSearch.tsx");

var _type = __webpack_require__(/*! ./type */ "./packages/tgui/interfaces/DisposalChute/type.ts");

var _disposalChuteConfigL;

var disposalChuteConfigLookup = (_disposalChuteConfigL = {}, _disposalChuteConfigL[_type.DisposalChuteState.Off] = {
  pumpColor: 'bad',
  pumpText: 'Inactive'
}, _disposalChuteConfigL[_type.DisposalChuteState.Charging] = {
  pumpColor: 'average',
  pumpText: 'Pressurizing'
}, _disposalChuteConfigL[_type.DisposalChuteState.Charged] = {
  pumpColor: 'good',
  pumpText: 'Ready'
}, _disposalChuteConfigL);

var DisposalChute = function DisposalChute(_props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var name = data.name,
      _data$destinations = data.destinations,
      destinations = _data$destinations === void 0 ? null : _data$destinations,
      destinationTag = data.destinationTag,
      flush = data.flush,
      mode = data.mode,
      pressure = data.pressure;
  var disposalChuteConfig = disposalChuteConfigLookup[mode];
  var pumpColor = disposalChuteConfig.pumpColor,
      pumpText = disposalChuteConfig.pumpText;
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "title": name,
    "width": 355,
    "height": destinations ? 350 : 140,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      "className": "disposal-chute-interface",
      "scrollable": !!destinations,
      children: [(0, _inferno.createComponentVNode)(2, _components.Stack, {
        "vertical": true,
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
            children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
              "label": "Current Pressure"
            })
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
            "ranges": {
              good: [1, Infinity],
              average: [0.75, 1],
              bad: [-Infinity, 0.75]
            },
            "value": pressure
          })
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
        children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Air Pump",
          "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
            "icon": "power-off",
            "content": mode ? 'Enabled' : 'Disabled',
            "color": mode ? 'green' : 'red',
            "onClick": function () {
              function onClick() {
                return act('togglePump');
              }

              return onClick;
            }()
          }),
          children: (0, _inferno.createComponentVNode)(2, _components.Box, {
            "color": pumpColor,
            children: pumpText
          })
        }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Chute Handle",
          "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
            "icon": destinations ? "envelope" : "trash-alt",
            "content": flush ? "Flushing" : "Flush",
            "color": flush ? '' : 'red',
            "onClick": function () {
              function onClick() {
                return act('toggleHandle');
              }

              return onClick;
            }()
          }),
          children: (0, _inferno.createComponentVNode)(2, _components.Button, {
            "content": "Eject Contents",
            "icon": "eject",
            "onClick": function () {
              function onClick() {
                return act('eject');
              }

              return onClick;
            }()
          })
        })]
      }), !!destinations && (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.Stack, {
        "vertical": true,
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
            children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
              "label": "Destination",
              "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
                "icon": "search",
                "content": "Rescan",
                "onClick": function () {
                  function onClick() {
                    return act('rescanDest');
                  }

                  return onClick;
                }()
              }),
              children: destinationTag
            })
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, DestinationSearch, {
            "destinations": destinations,
            "destinationTag": destinationTag
          })
        })]
      })], 4)]
    })
  });
};

exports.DisposalChute = DisposalChute;

var DestinationSearch = function DestinationSearch(props, context) {
  var _props$destinations = props.destinations,
      destinations = _props$destinations === void 0 ? [] : _props$destinations,
      _props$destinationTag = props.destinationTag,
      destinationTag = _props$destinationTag === void 0 ? null : _props$destinationTag;

  var _useBackend2 = (0, _backend.useBackend)(context),
      act = _useBackend2.act;

  var _useLocalState = (0, _backend.useLocalState)(context, 'searchText', ''),
      searchText = _useLocalState[0],
      setSearchText = _useLocalState[1];

  var handleSelectDestination = function handleSelectDestination(destination) {
    return act('select-destination', {
      destination: destination
    });
  };

  var filteredDestinations = destinations.filter(function (destination) {
    return destination.includes(searchText);
  });
  return (0, _inferno.createComponentVNode)(2, _ListSearch.ListSearch, {
    "autoFocus": true,
    "currentSearch": searchText,
    "onSearch": setSearchText,
    "onSelect": handleSelectDestination,
    "options": filteredDestinations,
    "selectedOption": destinationTag
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/DisposalChute/type.ts":
/*!********************************************************!*\
  !*** ./packages/tgui/interfaces/DisposalChute/type.ts ***!
  \********************************************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.DisposalChuteState = void 0;

/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */
var DisposalChuteState;
exports.DisposalChuteState = DisposalChuteState;

(function (DisposalChuteState) {
  DisposalChuteState[DisposalChuteState["Off"] = 0] = "Off";
  DisposalChuteState[DisposalChuteState["Charging"] = 1] = "Charging";
  DisposalChuteState[DisposalChuteState["Charged"] = 2] = "Charged";
})(DisposalChuteState || (exports.DisposalChuteState = DisposalChuteState = {}));

/***/ }),

/***/ "./packages/tgui/interfaces/DoorTimer/index.tsx":
/*!******************************************************!*\
  !*** ./packages/tgui/interfaces/DoorTimer/index.tsx ***!
  \******************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.DoorTimer = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _format = __webpack_require__(/*! ../../format */ "./packages/tgui/format.js");

var _layouts = __webpack_require__(/*! ../../layouts */ "./packages/tgui/layouts/index.js");

/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */
var DoorTimer = function DoorTimer(_props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 260,
    "height": data.flasher ? 279 : 207,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
        "vertical": true,
        "fill": true,
        "justify": "stretch",
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          "grow": 1,
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "title": "Timer",
            "fill": true,
            children: (0, _inferno.createComponentVNode)(2, _components.LabeledControls, {
              "justify": "start",
              children: [(0, _inferno.createComponentVNode)(2, _components.LabeledControls.Item, {
                "label": "Time",
                children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
                  "align": "center",
                  children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                    children: (0, _inferno.createComponentVNode)(2, _components.Knob, {
                      "animated": true,
                      "minValue": 0,
                      "maxValue": data.maxTime,
                      "value": data.time,
                      "format": function () {
                        function format(v) {
                          return (0, _format.formatTime)(v * 10);
                        }

                        return format;
                      }(),
                      "onDrag": function () {
                        function onDrag(_e, time) {
                          return act('set-time', {
                            time: time
                          });
                        }

                        return onDrag;
                      }(),
                      "onChange": function () {
                        function onChange(_e, time) {
                          return act('set-time', {
                            time: time,
                            finish: true
                          });
                        }

                        return onChange;
                      }()
                    })
                  }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                    children: (0, _inferno.createComponentVNode)(2, _components.TimeDisplay, {
                      "value": data.time * 10,
                      "timing": data.timing,
                      "format": _format.formatTime
                    })
                  })]
                })
              }), (0, _inferno.createComponentVNode)(2, _components.LabeledControls.Item, {
                children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                  "onClick": function () {
                    function onClick() {
                      return act('toggle-timing');
                    }

                    return onClick;
                  }(),
                  children: data.timing ? 'Stop' : 'Start'
                })
              })]
            })
          })
        }), !!data.flusher && (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "title": "Floor Flusher",
            "fill": true,
            children: (0, _inferno.createComponentVNode)(2, _components.Button, {
              "onClick": function () {
                function onClick() {
                  return act('toggle-flusher');
                }

                return onClick;
              }(),
              "backgroundColor": data.opening ? 'orange' : undefined,
              children: data.opening ? data.flusheropen ? 'Opening...' : 'Closing...' : data.flusheropen ? 'Close Flusher' : 'Open Flusher'
            })
          })
        }), !!data.flasher && (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "title": "Flasher",
            "fill": true,
            children: (0, _inferno.createComponentVNode)(2, _components.Button, {
              "onClick": function () {
                function onClick() {
                  return act('activate-flasher');
                }

                return onClick;
              }(),
              "backgroundColor": data.recharging ? 'orange' : undefined,
              children: ["Flash Cell ", !!data.recharging && '(Recharging)']
            })
          })
        })]
      })
    })
  });
};

exports.DoorTimer = DoorTimer;

/***/ }),

/***/ "./packages/tgui/interfaces/DoorTimer/type.ts":
/*!****************************************************!*\
  !*** ./packages/tgui/interfaces/DoorTimer/type.ts ***!
  \****************************************************/
/***/ (function() {

"use strict";


/***/ }),

/***/ "./packages/tgui/interfaces/Filteriffic.js":
/*!*************************************************!*\
  !*** ./packages/tgui/interfaces/Filteriffic.js ***!
  \*************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Filteriffic = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var _collections = __webpack_require__(/*! common/collections */ "./packages/common/collections.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _math2 = __webpack_require__(/*! ../../common/math */ "./packages/common/math.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var FilterIntegerEntry = function FilterIntegerEntry(props, context) {
  var value = props.value,
      name = props.name,
      filterName = props.filterName;

  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act;

  return (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
    "value": value,
    "minValue": -500,
    "maxValue": 500,
    "stepPixelSize": 5,
    "width": "39px",
    "onDrag": function () {
      function onDrag(e, value) {
        var _new_data;

        return act('modify_filter_value', {
          name: filterName,
          new_data: (_new_data = {}, _new_data[name] = value, _new_data)
        });
      }

      return onDrag;
    }()
  });
};

var FilterFloatEntry = function FilterFloatEntry(props, context) {
  var value = props.value,
      name = props.name,
      filterName = props.filterName;

  var _useBackend2 = (0, _backend.useBackend)(context),
      act = _useBackend2.act;

  var _useLocalState = (0, _backend.useLocalState)(context, filterName + "-" + name, 0.01),
      step = _useLocalState[0],
      setStep = _useLocalState[1];

  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.NumberInput, {
    "value": value,
    "minValue": -500,
    "maxValue": 500,
    "stepPixelSize": 4,
    "step": step,
    "format": function () {
      function format(value) {
        return (0, _math.toFixed)(value, (0, _math2.numberOfDecimalDigits)(step));
      }

      return format;
    }(),
    "width": "80px",
    "onDrag": function () {
      function onDrag(e, value) {
        var _new_data2;

        return act('transition_filter_value', {
          name: filterName,
          new_data: (_new_data2 = {}, _new_data2[name] = value, _new_data2)
        });
      }

      return onDrag;
    }()
  }), (0, _inferno.createComponentVNode)(2, _components.Box, {
    "inline": true,
    "ml": 2,
    "mr": 1,
    children: "Step:"
  }), (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
    "value": step,
    "step": 0.001,
    "format": function () {
      function format(value) {
        return (0, _math.toFixed)(value, 4);
      }

      return format;
    }(),
    "width": "70px",
    "onChange": function () {
      function onChange(e, value) {
        return setStep(value);
      }

      return onChange;
    }()
  })], 4);
};

var FilterTextEntry = function FilterTextEntry(props, context) {
  var value = props.value,
      name = props.name,
      filterName = props.filterName;

  var _useBackend3 = (0, _backend.useBackend)(context),
      act = _useBackend3.act;

  return (0, _inferno.createComponentVNode)(2, _components.Input, {
    "value": value,
    "width": "250px",
    "onInput": function () {
      function onInput(e, value) {
        var _new_data3;

        return act('modify_filter_value', {
          name: filterName,
          new_data: (_new_data3 = {}, _new_data3[name] = value, _new_data3)
        });
      }

      return onInput;
    }()
  });
};

var FilterColorEntry = function FilterColorEntry(props, context) {
  var value = props.value,
      filterName = props.filterName,
      name = props.name;

  var _useBackend4 = (0, _backend.useBackend)(context),
      act = _useBackend4.act;

  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
    "icon": "pencil-alt",
    "onClick": function () {
      function onClick() {
        return act('modify_color_value', {
          name: filterName
        });
      }

      return onClick;
    }()
  }), (0, _inferno.createComponentVNode)(2, _components.ColorBox, {
    "color": value,
    "mr": 0.5
  }), (0, _inferno.createComponentVNode)(2, _components.Input, {
    "value": value,
    "width": "90px",
    "onInput": function () {
      function onInput(e, value) {
        var _new_data4;

        return act('transition_filter_value', {
          name: filterName,
          new_data: (_new_data4 = {}, _new_data4[name] = value, _new_data4)
        });
      }

      return onInput;
    }()
  })], 4);
};

var FilterIconEntry = function FilterIconEntry(props, context) {
  var value = props.value,
      filterName = props.filterName;

  var _useBackend5 = (0, _backend.useBackend)(context),
      act = _useBackend5.act;

  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
    "icon": "pencil-alt",
    "onClick": function () {
      function onClick() {
        return act('modify_icon_value', {
          name: filterName
        });
      }

      return onClick;
    }()
  }), (0, _inferno.createComponentVNode)(2, _components.Box, {
    "inline": true,
    "ml": 1,
    children: value
  })], 4);
};

var FilterFlagsEntry = function FilterFlagsEntry(props, context) {
  var name = props.name,
      value = props.value,
      filterName = props.filterName,
      filterType = props.filterType;

  var _useBackend6 = (0, _backend.useBackend)(context),
      act = _useBackend6.act,
      data = _useBackend6.data;

  var filterInfo = data.filter_info;
  var flags = filterInfo[filterType]['flags'];
  return (0, _collections.map)(function (bitField, flagName) {
    return (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
      "checked": value & bitField,
      "content": flagName,
      "onClick": function () {
        function onClick() {
          var _new_data5;

          return act('modify_filter_value', {
            name: filterName,
            new_data: (_new_data5 = {}, _new_data5[name] = value ^ bitField, _new_data5)
          });
        }

        return onClick;
      }()
    });
  })(flags);
};

var FilterDataEntry = function FilterDataEntry(props, context) {
  var name = props.name,
      value = props.value,
      hasValue = props.hasValue,
      filterName = props.filterName;
  var filterEntryTypes = {
    "int": (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, FilterIntegerEntry, Object.assign({}, props))),
    "float": (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, FilterFloatEntry, Object.assign({}, props))),
    string: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, FilterTextEntry, Object.assign({}, props))),
    color: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, FilterColorEntry, Object.assign({}, props))),
    icon: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, FilterIconEntry, Object.assign({}, props))),
    flags: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, FilterFlagsEntry, Object.assign({}, props)))
  };
  var filterEntryMap = {
    x: 'float',
    y: 'float',
    icon: 'icon',
    render_source: 'string',
    flags: 'flags',
    size: 'float',
    color: 'color',
    offset: 'float',
    radius: 'float',
    falloff: 'float',
    density: 'int',
    threshold: 'float',
    factor: 'float',
    repeat: 'int'
  };
  return (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
    "label": name,
    children: [filterEntryTypes[filterEntryMap[name]] || "Not Found (This is an error)", ' ', !hasValue && (0, _inferno.createComponentVNode)(2, _components.Box, {
      "inline": true,
      "color": "average",
      children: "(Default)"
    })]
  });
};

var FilterEntry = function FilterEntry(props, context) {
  var _useBackend7 = (0, _backend.useBackend)(context),
      act = _useBackend7.act,
      data = _useBackend7.data;

  var name = props.name,
      filterDataEntry = props.filterDataEntry;

  var type = filterDataEntry.type,
      priority = filterDataEntry.priority,
      restOfProps = _objectWithoutPropertiesLoose(filterDataEntry, ["type", "priority"]);

  var filterDefaults = data["filter_info"];
  var targetFilterPossibleKeys = Object.keys(filterDefaults[type]['defaults']);
  return (0, _inferno.createComponentVNode)(2, _components.Collapsible, {
    "title": name + " (" + type + ")",
    "buttons": (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.NumberInput, {
      "value": priority,
      "stepPixelSize": 10,
      "width": "60px",
      "onChange": function () {
        function onChange(e, value) {
          return act('change_priority', {
            name: name,
            new_priority: value
          });
        }

        return onChange;
      }()
    }), (0, _inferno.createComponentVNode)(2, _components.Button.Input, {
      "content": "Rename",
      "placeholder": name,
      "onCommit": function () {
        function onCommit(e, new_name) {
          return act('rename_filter', {
            name: name,
            new_name: new_name
          });
        }

        return onCommit;
      }(),
      "width": "90px"
    }), (0, _inferno.createComponentVNode)(2, _components.Button.Confirm, {
      "icon": "minus",
      "onClick": function () {
        function onClick() {
          return act("remove_filter", {
            name: name
          });
        }

        return onClick;
      }()
    })], 4),
    children: (0, _inferno.createComponentVNode)(2, _components.Section, {
      "level": 2,
      children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
        children: targetFilterPossibleKeys.map(function (entryName) {
          var defaults = filterDefaults[type]['defaults'];
          var value = restOfProps[entryName] || defaults[entryName];
          var hasValue = value !== defaults[entryName];
          return (0, _inferno.createComponentVNode)(2, FilterDataEntry, {
            "filterName": name,
            "filterType": type,
            "name": entryName,
            "value": value,
            "hasValue": hasValue
          }, entryName);
        })
      })
    })
  });
};

var Filteriffic = function Filteriffic(props, context) {
  var _useBackend8 = (0, _backend.useBackend)(context),
      act = _useBackend8.act,
      data = _useBackend8.data;

  var name = data.target_name || "Unknown Object";
  var filters = data.target_filter_data || {};
  var hasFilters = filters !== {};
  var filterDefaults = data["filter_info"];

  var _useLocalState2 = (0, _backend.useLocalState)(context, 'massApplyPath', ''),
      massApplyPath = _useLocalState2[0],
      setMassApplyPath = _useLocalState2[1];

  var _useLocalState3 = (0, _backend.useLocalState)(context, 'hidden', false),
      hiddenSecret = _useLocalState3[0],
      setHiddenSecret = _useLocalState3[1];

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 500,
    "height": 500,
    "title": "Filteriffic",
    "resizable": true,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      "scrollable": true,
      children: [(0, _inferno.createComponentVNode)(2, _components.NoticeBox, {
        "danger": true,
        children: "DO NOT MESS WITH EXISTING FILTERS IF YOU DO NOT KNOW THE CONSEQUENCES. YOU HAVE BEEN WARNED."
      }), (0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": hiddenSecret ? (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Box, {
          "mr": 0.5,
          "inline": true,
          children: "MASS EDIT:"
        }), (0, _inferno.createComponentVNode)(2, _components.Input, {
          "value": massApplyPath,
          "width": "100px",
          "onInput": function () {
            function onInput(e, value) {
              return setMassApplyPath(value);
            }

            return onInput;
          }()
        }), (0, _inferno.createComponentVNode)(2, _components.Button.Confirm, {
          "content": "Apply",
          "confirmContent": "ARE YOU SURE?",
          "onClick": function () {
            function onClick() {
              return act('mass_apply', {
                path: massApplyPath
              });
            }

            return onClick;
          }()
        })], 4) : (0, _inferno.createComponentVNode)(2, _components.Box, {
          "inline": true,
          "onDblClick": function () {
            function onDblClick() {
              return setHiddenSecret(true);
            }

            return onDblClick;
          }(),
          children: name
        }),
        "buttons": (0, _inferno.createComponentVNode)(2, _components.Dropdown, {
          "icon": "plus",
          "displayText": "Add Filter",
          "nochevron": true,
          "options": Object.keys(filterDefaults),
          "onSelected": function () {
            function onSelected(value) {
              return act('add_filter', {
                name: 'default',
                priority: 10,
                type: value
              });
            }

            return onSelected;
          }()
        }),
        children: !hasFilters ? (0, _inferno.createComponentVNode)(2, _components.Box, {
          children: "No filters"
        }) : (0, _collections.map)(function (entry, key) {
          return (0, _inferno.createComponentVNode)(2, FilterEntry, {
            "filterDataEntry": entry,
            "name": key
          }, key);
        })(filters)
      })]
    })
  });
};

exports.Filteriffic = Filteriffic;

/***/ }),

/***/ "./packages/tgui/interfaces/FlockPanel.js":
/*!************************************************!*\
  !*** ./packages/tgui/interfaces/FlockPanel.js ***!
  \************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.FlockPanel = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var FlockPartitions = function FlockPartitions(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act;

  var partitions = props.partitions;
  return (0, _inferno.createComponentVNode)(2, _components.Stack, {
    "vertical": true,
    children: partitions.map(function (partition) {
      return (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
        children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
          "align": "center",
          "height": "100%",
          children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
            "width": "20%",
            "height": "100%",
            children: (0, _inferno.createComponentVNode)(2, _components.Section, {
              "align": "center",
              "height": "100%",
              children: partition.name
            })
          }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
            "height": "100%",
            "grow": 1,
            children: (0, _inferno.createComponentVNode)(2, _components.Section, {
              "height": "100%",
              children: partition.host && (0, _inferno.createComponentVNode)(2, _components.Stack, {
                children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: (0, _inferno.createComponentVNode)(2, _components.Icon, {
                    "name": "wifi",
                    "size": 3
                  })
                }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
                    "vertical": true,
                    "align": "center",
                    children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                      children: partition.host
                    }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                      children: [partition.health, (0, _inferno.createComponentVNode)(2, _components.Icon, {
                        "name": "heart"
                      })]
                    })]
                  })
                })]
              })
            })
          }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
            "height": "100%",
            children: (0, _inferno.createComponentVNode)(2, _components.Section, {
              "height": "100%",
              children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
                children: [partition.host && (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                    "onClick": function () {
                      function onClick() {
                        return act('eject_trace', {
                          'origin': partition.ref
                        });
                      }

                      return onClick;
                    }(),
                    children: "Eject"
                  })
                }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                    "onClick": function () {
                      function onClick() {
                        return act('delete_trace', {
                          'origin': partition.ref
                        });
                      }

                      return onClick;
                    }(),
                    children: "Remove sentience"
                  })
                }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                    "onClick": function () {
                      function onClick() {
                        return act('jump_to', {
                          'origin': partition.ref
                        });
                      }

                      return onClick;
                    }(),
                    children: "Jump"
                  })
                })]
              })
            })
          })]
        })
      }, partition.ref);
    })
  });
}; // basic sorting function for numbers and strings


var compare = function compare(a, b, sortBy) {
  if (!isNaN(a[sortBy]) && !isNaN(b[sortBy])) {
    return b[sortBy] - a[sortBy];
  }

  return ('' + a[sortBy]).localeCompare(b[sortBy]);
}; // maps drone tasks to icons


var iconLookup = {
  "thinking": "brain",
  "shooting": "bolt",
  "rummaging": "dumpster",
  "wandering": "question",
  "building": "hammer",
  "harvesting": "cogs",
  "controlled": "wifi",
  "replicating": "egg",
  "rallying": "map-marker",
  "opening container": "box-open",
  "butchering": "recycle",
  "repairing": "tools",
  "capturing": "bars",
  "deposit": "puzzle-piece"
};

var taskIcon = function taskIcon(task) {
  var iconString = iconLookup[task];

  if (iconString) {
    return (0, _inferno.createComponentVNode)(2, _components.Icon, {
      "size": 3,
      "name": iconString
    });
  }

  return "";
};

var capitalizeString = function capitalizeString(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
};

var FlockDrones = function FlockDrones(props, context) {
  var _useBackend2 = (0, _backend.useBackend)(context),
      act = _useBackend2.act;

  var drones = props.drones,
      sortBy = props.sortBy;
  return (0, _inferno.createComponentVNode)(2, _components.Stack, {
    "vertical": true,
    children: drones.sort(function (a, b) {
      return compare(a, b, sortBy);
    }).map(function (drone) {
      return (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
        children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
            "width": "20%",
            children: (0, _inferno.createComponentVNode)(2, _components.Section, {
              "height": "100%",
              children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
                "vertical": true,
                "align": "center",
                children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: drone.name
                }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: [drone.health, (0, _inferno.createComponentVNode)(2, _components.Icon, {
                    "name": "heart"
                  }), " ", drone.resources, (0, _inferno.createComponentVNode)(2, _components.Icon, {
                    "name": "cog"
                  })]
                })]
              })
            })
          }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
            "grow": 1,
            children: (0, _inferno.createComponentVNode)(2, _components.Section, {
              "height": "100%",
              children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
                "align": "center",
                children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  "width": "50px",
                  children: (0, _inferno.createComponentVNode)(2, _components.Box, {
                    "align": "center",
                    children: taskIcon(drone.task)
                  })
                }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: [(0, _inferno.createVNode)(1, "b", null, drone.area, 0), " ", (0, _inferno.createVNode)(1, "br"), " ", capitalizeString(drone.task)]
                })]
              })
            })
          }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
            children: (0, _inferno.createComponentVNode)(2, _components.Section, {
              "height": "100%",
              children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
                children: [drone.task === "controlled" && (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                    "onClick": function () {
                      function onClick() {
                        return act('eject_trace', {
                          'origin': drone.controller_ref
                        });
                      }

                      return onClick;
                    }(),
                    children: "Eject Trace"
                  })
                }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                    "onClick": function () {
                      function onClick() {
                        return act('rally', {
                          'origin': drone.ref
                        });
                      }

                      return onClick;
                    }(),
                    children: "Rally"
                  })
                }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                    "onClick": function () {
                      function onClick() {
                        return act('jump_to', {
                          'origin': drone.ref
                        });
                      }

                      return onClick;
                    }(),
                    children: "Jump"
                  })
                })]
              })
            })
          })]
        })
      }, drone.ref);
    })
  });
}; // TODO: actual structure information (power draw/generation etc.)


var FlockStructures = function FlockStructures(props, context) {
  var _useBackend3 = (0, _backend.useBackend)(context),
      act = _useBackend3.act;

  var structures = props.structures;
  return (0, _inferno.createComponentVNode)(2, _components.Stack, {
    "vertical": true,
    children: structures.map(function (structure) {
      return (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
        children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
            "grow": 1,
            children: (0, _inferno.createComponentVNode)(2, _components.Section, {
              children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
                "vertical": true,
                "align": "center",
                children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: structure.name
                }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: [structure.health, (0, _inferno.createComponentVNode)(2, _components.Icon, {
                    "name": "heart"
                  })]
                })]
              })
            })
          }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
            children: (0, _inferno.createComponentVNode)(2, _components.Section, {
              "height": "100%",
              children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                "onClick": function () {
                  function onClick() {
                    return act('jump_to', {
                      'origin': structure.ref
                    });
                  }

                  return onClick;
                }(),
                children: "Jump"
              })
            })
          })]
        })
      }, structure.ref);
    })
  });
};

var FlockEnemies = function FlockEnemies(props, context) {
  var _useBackend4 = (0, _backend.useBackend)(context),
      act = _useBackend4.act;

  var enemies = props.enemies;
  return (0, _inferno.createComponentVNode)(2, _components.Stack, {
    "vertical": true,
    children: enemies.map(function (enemy) {
      return (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
        children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
            "width": "30%",
            children: (0, _inferno.createComponentVNode)(2, _components.Section, {
              "height": "100%",
              children: enemy.name
            })
          }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
            "grow": 1,
            children: (0, _inferno.createComponentVNode)(2, _components.Section, {
              "height": "100%",
              children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
                children: (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  "grow": 1,
                  children: (0, _inferno.createVNode)(1, "b", null, enemy.area, 0)
                })
              })
            })
          }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
            children: (0, _inferno.createComponentVNode)(2, _components.Section, {
              "height": "100%",
              children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
                children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                    "icon": "times",
                    "onClick": function () {
                      function onClick() {
                        return act('remove_enemy', {
                          'origin': enemy.ref
                        });
                      }

                      return onClick;
                    }(),
                    children: "Remove"
                  })
                }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                    "onClick": function () {
                      function onClick() {
                        return act('jump_to', {
                          'origin': enemy.ref
                        });
                      }

                      return onClick;
                    }(),
                    children: "Jump"
                  })
                })]
              })
            })
          })]
        })
      }, enemy.ref);
    })
  });
};

var FlockPanel = function FlockPanel(props, context) {
  var _useBackend5 = (0, _backend.useBackend)(context),
      data = _useBackend5.data,
      act = _useBackend5.act;

  var _useLocalState = (0, _backend.useLocalState)(context, 'tabIndex', 1),
      tabIndex = _useLocalState[0],
      setTabIndex = _useLocalState[1];

  var _useLocalState2 = (0, _backend.useLocalState)(context, 'sortBy', 'resources'),
      sortBy = _useLocalState2[0],
      setSortBy = _useLocalState2[1];

  var vitals = data.vitals,
      partitions = data.partitions,
      drones = data.drones,
      structures = data.structures,
      enemies = data.enemies;
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "theme": "flock",
    "title": "Flockmind " + vitals.name,
    "width": 600,
    "height": 450,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      "scrollable": true,
      children: [(0, _inferno.createComponentVNode)(2, _components.Tabs, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
          "selected": tabIndex === 1,
          "onClick": function () {
            function onClick() {
              return setTabIndex(1);
            }

            return onClick;
          }(),
          children: ["Drones ", "(" + drones.length + ")"]
        }), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
          "selected": tabIndex === 2,
          "onClick": function () {
            function onClick() {
              return setTabIndex(2);
            }

            return onClick;
          }(),
          children: ["Partitions ", "(" + partitions.length + ")"]
        }), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
          "selected": tabIndex === 3,
          "onClick": function () {
            function onClick() {
              return setTabIndex(3);
            }

            return onClick;
          }(),
          children: ["Structures ", "(" + structures.length + ")"]
        }), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
          "selected": tabIndex === 4,
          "onClick": function () {
            function onClick() {
              return setTabIndex(4);
            }

            return onClick;
          }(),
          children: ["Enemies ", "(" + enemies.length + ")"]
        })]
      }), tabIndex === 1 && (0, _inferno.createComponentVNode)(2, _components.Box, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Dropdown, {
          "options": ["name", "health", "resources", "area"],
          "selected": "resources",
          "onSelected": function () {
            function onSelected(value) {
              return setSortBy(value);
            }

            return onSelected;
          }()
        }), (0, _inferno.createComponentVNode)(2, FlockDrones, {
          "drones": drones,
          "sortBy": sortBy
        })]
      }), tabIndex === 2 && (0, _inferno.createComponentVNode)(2, FlockPartitions, {
        "partitions": partitions
      }), tabIndex === 3 && (0, _inferno.createComponentVNode)(2, FlockStructures, {
        "structures": structures
      }), tabIndex === 4 && (0, _inferno.createComponentVNode)(2, FlockEnemies, {
        "enemies": enemies
      })]
    })
  });
};

exports.FlockPanel = FlockPanel;

/***/ }),

/***/ "./packages/tgui/interfaces/GasCanister/Detonator.js":
/*!***********************************************************!*\
  !*** ./packages/tgui/interfaces/GasCanister/Detonator.js ***!
  \***********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Detonator = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _DetonatorTimer = __webpack_require__(/*! ./DetonatorTimer */ "./packages/tgui/interfaces/GasCanister/DetonatorTimer.js");

var Detonator = function Detonator(props) {
  var detonator = props.detonator,
      detonatorAttachments = props.detonatorAttachments,
      onToggleAnchor = props.onToggleAnchor,
      onToggleSafety = props.onToggleSafety,
      onWireInteract = props.onWireInteract,
      onPrimeDetonator = props.onPrimeDetonator,
      onTriggerActivate = props.onTriggerActivate,
      onSetTimer = props.onSetTimer;
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Detonator",
    children: [(0, _inferno.createComponentVNode)(2, DetonatorWires, {
      "detonator": detonator,
      "onWireInteract": onWireInteract,
      "onSetTimer": onSetTimer
    }), (0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, DetonatorUtility, {
      "detonator": detonator,
      "detonatorAttachments": detonatorAttachments,
      "onToggleAnchor": onToggleAnchor,
      "onToggleSafety": onToggleSafety,
      "onPrimeDetonator": onPrimeDetonator,
      "onTriggerActivate": onTriggerActivate
    })]
  });
};

exports.Detonator = Detonator;

var DetonatorWires = function DetonatorWires(props) {
  var _props$detonator = props.detonator;
  _props$detonator = _props$detonator === void 0 ? {} : _props$detonator;
  var wireNames = _props$detonator.wireNames,
      wireStatus = _props$detonator.wireStatus,
      time = _props$detonator.time,
      isPrimed = _props$detonator.isPrimed,
      onWireInteract = props.onWireInteract,
      onSetTimer = props.onSetTimer;
  return (0, _inferno.createComponentVNode)(2, _components.Flex, {
    children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
        children: wireNames.map(function (entry, i) {
          return (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": entry,
            children: (0, _inferno.createComponentVNode)(2, _components.Box, {
              "height": 1.7,
              children: wireStatus && wireStatus[i] ? (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
                "icon": "cut",
                "content": "Cut",
                "onClick": function () {
                  function onClick() {
                    return onWireInteract("cut", i);
                  }

                  return onClick;
                }()
              }), (0, _inferno.createComponentVNode)(2, _components.Button, {
                "icon": "bolt",
                "content": "Pulse",
                "onClick": function () {
                  function onClick() {
                    return onWireInteract("pulse", i);
                  }

                  return onClick;
                }()
              })], 4) : (0, _inferno.createComponentVNode)(2, _components.Box, {
                "color": "average",
                "minHeight": 1.4,
                children: "Cut"
              })
            })
          }, entry + i);
        })
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "mr": 2,
      "mt": 2,
      children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
        "direction": "column",
        "align": "center",
        children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
          children: (0, _inferno.createComponentVNode)(2, _DetonatorTimer.DetonatorTimer, {
            "time": time,
            "isPrimed": isPrimed
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
            "mt": 1,
            "disabled": isPrimed,
            "icon": "fast-backward",
            "onClick": function () {
              function onClick() {
                return onSetTimer(time - 300);
              }

              return onClick;
            }()
          }), (0, _inferno.createComponentVNode)(2, _components.Button, {
            "mt": 1,
            "disabled": isPrimed,
            "icon": "backward",
            "onClick": function () {
              function onClick() {
                return onSetTimer(time - 10);
              }

              return onClick;
            }()
          }), (0, _inferno.createComponentVNode)(2, _components.Button, {
            "mt": 1,
            "disabled": isPrimed,
            "icon": "forward",
            "onClick": function () {
              function onClick() {
                return onSetTimer(time + 10);
              }

              return onClick;
            }()
          }), (0, _inferno.createComponentVNode)(2, _components.Button, {
            "mt": 1,
            "disabled": isPrimed,
            "icon": "fast-forward",
            "onClick": function () {
              function onClick() {
                return onSetTimer(time + 300);
              }

              return onClick;
            }()
          })]
        })]
      })
    })]
  });
};

var DetonatorUtility = function DetonatorUtility(props) {
  var _props$detonator2 = props.detonator;
  _props$detonator2 = _props$detonator2 === void 0 ? {} : _props$detonator2;
  var isAnchored = _props$detonator2.isAnchored,
      trigger = _props$detonator2.trigger,
      safetyIsOn = _props$detonator2.safetyIsOn,
      isPrimed = _props$detonator2.isPrimed,
      detonatorAttachments = props.detonatorAttachments,
      onToggleAnchor = props.onToggleAnchor,
      onToggleSafety = props.onToggleSafety,
      onPrimeDetonator = props.onPrimeDetonator,
      onTriggerActivate = props.onTriggerActivate;

  var renderArmingStatus = function renderArmingStatus() {
    if (safetyIsOn) {
      return "The safety is on, therefore, you cannot prime the bomb.";
    } else if (!isPrimed) {
      return (0, _inferno.createComponentVNode)(2, _components.Button, {
        "color": "danger",
        "icon": "bomb",
        "content": "Prime",
        "onClick": onPrimeDetonator
      });
    } else {
      return (0, _inferno.createComponentVNode)(2, _components.Box, {
        "bold": true,
        "color": "red",
        children: "PRIMED"
      });
    }
  };

  return (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
    children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
      "className": "gas-canister-detonator-utility__list-item",
      "label": "Anchor Status",
      children: isAnchored ? "Anchored. There are no controls for undoing this." : (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "anchor",
        "content": "Anchor",
        "onClick": onToggleAnchor
      })
    }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
      "className": "gas-canister-detonator-utility__list-item",
      "label": "Trigger",
      children: trigger ? (0, _inferno.createComponentVNode)(2, _components.Button, {
        "onClick": onTriggerActivate,
        children: trigger
      }) : "There is no trigger attached."
    }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
      "className": "gas-canister-detonator-utility__list-item",
      "label": "Safety",
      children: safetyIsOn ? (0, _inferno.createComponentVNode)(2, _components.Button, {
        "color": "average",
        "icon": "power-off",
        "content": "Turn Off",
        "onClick": onToggleSafety
      }) : (0, _inferno.createComponentVNode)(2, _components.Box, {
        "color": "average",
        children: "Off"
      })
    }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
      "className": "gas-canister-detonator-utility__list-item",
      "label": "Arming",
      children: renderArmingStatus()
    }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
      "label": "Attachments",
      "className": "gas-canister-detonator-utility__list-item",
      children: detonatorAttachments && detonatorAttachments.length > 0 ? detonatorAttachments.map(function (entry, i) {
        return (0, _inferno.createComponentVNode)(2, _components.Box, {
          "className": "gas-canister-detonator-utility__attachment-item",
          children: detonatorAttachments[i]
        }, entry + i);
      }) : "There are no additional attachments to the detonator."
    })]
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/GasCanister/DetonatorTimer.js":
/*!****************************************************************!*\
  !*** ./packages/tgui/interfaces/GasCanister/DetonatorTimer.js ***!
  \****************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.DetonatorTimer = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _format = __webpack_require__(/*! ../../format */ "./packages/tgui/format.js");

var DetonatorTimer = function DetonatorTimer(props) {
  var time = props.time,
      isPrimed = props.isPrimed,
      _props$warningThresho = props.warningThreshold,
      warningThreshold = _props$warningThresho === void 0 ? 300 : _props$warningThresho,
      _props$dangerThreshol = props.dangerThreshold,
      dangerThreshold = _props$dangerThreshol === void 0 ? 100 : _props$dangerThreshol,
      _props$explosionMessa = props.explosionMessage,
      explosionMessage = _props$explosionMessa === void 0 ? "BO:OM" : _props$explosionMessa;
  var timeColor = "green";

  if (time <= dangerThreshold) {
    timeColor = "red";
  } else if (time <= warningThreshold) {
    timeColor = "orange";
  }

  return (0, _inferno.createComponentVNode)(2, _components.Box, {
    "p": 1,
    "textAlign": "center",
    "backgroundColor": "black",
    "color": timeColor,
    "maxWidth": "90px",
    "width": "90px",
    "fontSize": "20px",
    children: (0, _inferno.createComponentVNode)(2, _components.TimeDisplay, {
      "value": time,
      "timing": isPrimed,
      "format": function () {
        function format(value) {
          return (0, _format.formatTime)(value, explosionMessage);
        }

        return format;
      }()
    })
  });
};

exports.DetonatorTimer = DetonatorTimer;

/***/ }),

/***/ "./packages/tgui/interfaces/GasCanister/index.js":
/*!*******************************************************!*\
  !*** ./packages/tgui/interfaces/GasCanister/index.js ***!
  \*******************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.GasCanister = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../../layouts */ "./packages/tgui/layouts/index.js");

var _PortableAtmos = __webpack_require__(/*! ../common/PortableAtmos */ "./packages/tgui/interfaces/common/PortableAtmos.js");

var _ReleaseValve = __webpack_require__(/*! ../common/ReleaseValve */ "./packages/tgui/interfaces/common/ReleaseValve.js");

var _PaperSheet = __webpack_require__(/*! ../PaperSheet */ "./packages/tgui/interfaces/PaperSheet.js");

var _Detonator = __webpack_require__(/*! ./Detonator */ "./packages/tgui/interfaces/GasCanister/Detonator.js");

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

var GasCanister = function GasCanister(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var connected = data.connected,
      holding = data.holding,
      hasValve = data.hasValve,
      valveIsOpen = data.valveIsOpen,
      pressure = data.pressure,
      maxPressure = data.maxPressure,
      releasePressure = data.releasePressure,
      minRelease = data.minRelease,
      maxRelease = data.maxRelease,
      detonator = data.detonator,
      detonatorAttachments = data.detonatorAttachments,
      hasPaper = data.hasPaper;

  var handleSetPressure = function handleSetPressure(releasePressure) {
    act("set-pressure", {
      releasePressure: releasePressure
    });
  };

  var handleToggleValve = function handleToggleValve() {
    act("toggle-valve");
  };

  var handleEjectTank = function handleEjectTank() {
    act("eject-tank");
  };

  var handleWireInteract = function handleWireInteract(toolAction, index) {
    act("wire-interact", {
      index: index,
      toolAction: toolAction
    });
  };

  var handleToggleAnchor = function handleToggleAnchor() {
    act("anchor");
  };

  var handleToggleSafety = function handleToggleSafety() {
    act("safety");
  };

  var handlePrimeDetonator = function handlePrimeDetonator() {
    act("prime");
  };

  var handleTriggerActivate = function handleTriggerActivate() {
    act("trigger");
  };

  var handleSetTimer = function handleSetTimer(newTime) {
    act("timer", {
      newTime: newTime
    });
  };

  var hasDetonator = !!detonator;
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": hasDetonator ? hasPaper ? 880 : 470 : 305,
    "height": hasDetonator ? 685 : 340,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
          "width": "480px",
          children: [(0, _inferno.createComponentVNode)(2, _PortableAtmos.PortableBasicInfo, {
            "connected": connected,
            "pressure": pressure,
            "maxPressure": maxPressure,
            children: [(0, _inferno.createComponentVNode)(2, _components.Divider), hasValve ? (0, _inferno.createComponentVNode)(2, _ReleaseValve.ReleaseValve, {
              "valveIsOpen": valveIsOpen,
              "releasePressure": releasePressure,
              "minRelease": minRelease,
              "maxRelease": maxRelease,
              "onToggleValve": handleToggleValve,
              "onSetPressure": handleSetPressure
            }) : (0, _inferno.createComponentVNode)(2, _components.Box, {
              "color": "average",
              children: "The release valve is missing."
            })]
          }), detonator ? (0, _inferno.createComponentVNode)(2, _Detonator.Detonator, {
            "detonator": detonator,
            "detonatorAttachments": detonatorAttachments,
            "onToggleAnchor": handleToggleAnchor,
            "onToggleSafety": handleToggleSafety,
            "onWireInteract": handleWireInteract,
            "onPrimeDetonator": handlePrimeDetonator,
            "onTriggerActivate": handleTriggerActivate,
            "onSetTimer": handleSetTimer
          }) : (0, _inferno.createComponentVNode)(2, _PortableAtmos.PortableHoldingTank, {
            "holding": holding,
            "onEjectTank": handleEjectTank
          })]
        }), !!hasPaper && (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
          "width": "410px",
          children: (0, _inferno.createComponentVNode)(2, PaperView)
        })]
      })
    })
  });
};

exports.GasCanister = GasCanister;

var PaperView = /*#__PURE__*/function (_Component) {
  _inheritsLoose(PaperView, _Component);

  function PaperView(props, context) {
    var _this;

    _this = _Component.call(this, props) || this;
    _this.el = document.createElement('div');
    return _this;
  }

  var _proto = PaperView.prototype;

  _proto.render = function () {
    function render() {
      var _useBackend2 = (0, _backend.useBackend)(this.context),
          data = _useBackend2.data;

      var _data$paperData = data.paperData,
          text = _data$paperData.text,
          stamps = _data$paperData.stamps;
      return (0, _inferno.createComponentVNode)(2, _components.Section, {
        "scrollable": true,
        "width": "400px",
        "height": "518px",
        "backgroundColor": "white",
        "style": {
          'overflow-wrap': 'break-word'
        },
        children: (0, _inferno.createComponentVNode)(2, _PaperSheet.PaperSheetView, {
          "value": text ? text : "",
          "stamps": stamps,
          "readOnly": true
        })
      });
    }

    return render;
  }();

  return PaperView;
}(_inferno.Component);

/***/ }),

/***/ "./packages/tgui/interfaces/GasTank.js":
/*!*********************************************!*\
  !*** ./packages/tgui/interfaces/GasTank.js ***!
  \*********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.GasTankInfo = exports.GasTank = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var _format = __webpack_require__(/*! ../format */ "./packages/tgui/format.js");

var _ReleaseValve = __webpack_require__(/*! ./common/ReleaseValve */ "./packages/tgui/interfaces/common/ReleaseValve.js");

var GasTank = function GasTank(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var pressure = data.pressure,
      maxPressure = data.maxPressure,
      valveIsOpen = data.valveIsOpen,
      releasePressure = data.releasePressure,
      maxRelease = data.maxRelease;

  var handleSetPressure = function handleSetPressure(releasePressure) {
    act('set-pressure', {
      releasePressure: releasePressure
    });
  };

  var handleToggleValve = function handleToggleValve() {
    act('toggle-valve');
  };

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 400,
    "height": 220,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Status",
        children: (0, _inferno.createComponentVNode)(2, GasTankInfo, {
          "pressure": pressure,
          "maxPressure": maxPressure
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Section, {
        children: (0, _inferno.createComponentVNode)(2, _ReleaseValve.ReleaseValve, {
          "valveIsOpen": valveIsOpen,
          "releasePressure": releasePressure,
          "maxRelease": maxRelease,
          "onToggleValve": handleToggleValve,
          "onSetPressure": handleSetPressure
        })
      })]
    })
  });
};

exports.GasTank = GasTank;

var GasTankInfo = function GasTankInfo(props) {
  var pressure = props.pressure,
      maxPressure = props.maxPressure;
  return (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
    children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
      "label": "Pressure",
      children: (0, _inferno.createComponentVNode)(2, _components.RoundGauge, {
        "size": 1.75,
        "value": pressure,
        "minValue": 0,
        "maxValue": maxPressure,
        "alertAfter": maxPressure * 0.70,
        "ranges": {
          "good": [0, maxPressure * 0.70],
          "average": [maxPressure * 0.70, maxPressure * 0.85],
          "bad": [maxPressure * 0.85, maxPressure]
        },
        "format": _format.formatPressure
      })
    })
  });
};

exports.GasTankInfo = GasTankInfo;

/***/ }),

/***/ "./packages/tgui/interfaces/GeneTek.js":
/*!*********************************************!*\
  !*** ./packages/tgui/interfaces/GeneTek.js ***!
  \*********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.GeneTek = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var _index = __webpack_require__(/*! ./GeneTek/index */ "./packages/tgui/interfaces/GeneTek/index.js");

/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */
var formatSeconds = function formatSeconds(v) {
  return v > 0 ? (v / 10).toFixed(0) + "s" : "Ready";
};

var GeneTek = function GeneTek(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data,
      act = _useBackend.act;

  var _useSharedState = (0, _backend.useSharedState)(context, "menu", "research"),
      menu = _useSharedState[0],
      setMenu = _useSharedState[1];

  var _useSharedState2 = (0, _backend.useSharedState)(context, "buymats", null),
      buyMats = _useSharedState2[0],
      setBuyMats = _useSharedState2[1];

  var _useSharedState3 = (0, _backend.useSharedState)(context, "iscombining", false),
      isCombining = _useSharedState3[0];

  var materialCur = data.materialCur,
      materialMax = data.materialMax,
      currentResearch = data.currentResearch,
      equipmentCooldown = data.equipmentCooldown,
      subject = data.subject,
      costPerMaterial = data.costPerMaterial,
      budget = data.budget,
      record = data.record,
      scannerAlert = data.scannerAlert,
      scannerError = data.scannerError,
      allowed = data.allowed;

  var _ref = subject || {},
      name = _ref.name,
      stat = _ref.stat,
      health = _ref.health,
      stability = _ref.stability;

  var maxBuyMats = Math.min(materialMax - materialCur, Math.floor(budget / costPerMaterial));
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "theme": allowed ? "genetek" : "genetek-disabled",
    "width": 730,
    "height": 415,
    children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
      "height": "100%",
      children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "width": "245px",
        "height": "100%",
        "style": {
          "padding": "5px 5px 5px 5px"
        },
        children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
          "direction": "column",
          "height": "100%",
          children: [!allowed && (0, _inferno.createFragment)([(0, _inferno.createVNode)(1, "div", null, "Insufficient access to interact.", 16, {
            "style": {
              "color": "#ff3333",
              "text-align": "center"
            }
          }), (0, _inferno.createComponentVNode)(2, _components.Divider)], 4), (0, _inferno.createComponentVNode)(2, _components.Flex, {
            children: [(0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
              "value": materialCur,
              "maxValue": materialMax,
              "mb": 1,
              children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
                "position": "absolute",
                "bold": true,
                children: "Materials"
              }), materialCur, " / ", materialMax]
            }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
              "grow": 0,
              "shrink": 0,
              "ml": 1,
              children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                "circular": true,
                "compact": true,
                "icon": "dollar-sign",
                "disabled": maxBuyMats <= 0,
                "onClick": function () {
                  function onClick() {
                    return setBuyMats(1);
                  }

                  return onClick;
                }()
              })
            })]
          }), subject && (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
            children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
              "label": "Occupant",
              children: name
            }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
              "label": "Health",
              children: (0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
                "ranges": {
                  bad: [-Infinity, 0.15],
                  average: [0.15, 0.75],
                  good: [0.75, Infinity]
                },
                "value": health,
                children: stat < 2 ? health <= 0 ? (0, _inferno.createComponentVNode)(2, _components.Box, {
                  "color": "bad",
                  children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
                    "name": "exclamation-triangle"
                  }), " Critical"]
                }) : (health * 100).toFixed(0) + "%" : (0, _inferno.createComponentVNode)(2, _components.Box, {
                  children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
                    "name": "skull"
                  }), " Deceased"]
                })
              })
            }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
              "label": "Stability",
              children: (0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
                "ranges": {
                  bad: [-Infinity, 15],
                  average: [15, 75],
                  good: [75, Infinity]
                },
                "value": stability,
                "maxValue": 100
              })
            })]
          }), (0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "grow": 1,
            "style": {
              overflow: "hidden"
            },
            children: currentResearch.map(function (r) {
              return (0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
                "value": r.total - r.current,
                "maxValue": r.total,
                "mb": 1,
                children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
                  "position": "absolute",
                  children: r.name
                }), (0, _inferno.createComponentVNode)(2, _components.TimeDisplay, {
                  "timing": true,
                  "value": r.current,
                  "format": formatSeconds
                })]
              }, r.ref);
            })
          }), !!scannerAlert && (0, _inferno.createComponentVNode)(2, _components.NoticeBox, {
            "info": !scannerError,
            "danger": !!scannerError,
            children: scannerAlert
          }), (0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
            children: equipmentCooldown.map(function (e) {
              return (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
                "label": e.label,
                children: e.cooldown < 0 ? "Ready" : (0, _inferno.createComponentVNode)(2, _components.TimeDisplay, {
                  "timing": true,
                  "value": e.cooldown,
                  "format": formatSeconds
                })
              }, e.label);
            })
          })]
        })
      }), (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
        "scrollable": true,
        children: (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Box, {
            "ml": "250px",
            children: [(0, _inferno.createComponentVNode)(2, _components.Tabs, {
              children: [(0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
                "icon": "flask",
                "selected": menu === "research",
                "onClick": function () {
                  function onClick() {
                    return setMenu("research");
                  }

                  return onClick;
                }(),
                children: "Research"
              }), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
                "icon": "radiation",
                "selected": menu === "mutations",
                "onClick": function () {
                  function onClick() {
                    return setMenu("mutations");
                  }

                  return onClick;
                }(),
                children: "Mutations"
              }), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
                "icon": "server",
                "selected": menu === "storage" || !record && menu === "record",
                "onClick": function () {
                  function onClick() {
                    return setMenu("storage");
                  }

                  return onClick;
                }(),
                children: "Storage"
              }), !!record && (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
                "icon": "save",
                "selected": menu === "record",
                "onClick": function () {
                  function onClick() {
                    return setMenu("record");
                  }

                  return onClick;
                }(),
                "rightSlot": menu === "record" && (0, _inferno.createComponentVNode)(2, _components.Button, {
                  "circular": true,
                  "compact": true,
                  "color": "transparent",
                  "icon": "times",
                  "onClick": function () {
                    function onClick() {
                      return act("clearrecord");
                    }

                    return onClick;
                  }()
                }),
                children: "Record"
              }), subject && (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
                "icon": "dna",
                "selected": menu === "scanner",
                "onClick": function () {
                  function onClick() {
                    return setMenu("scanner");
                  }

                  return onClick;
                }(),
                children: "Scanner"
              })]
            }), buyMats !== null && (0, _inferno.createComponentVNode)(2, _index.BuyMaterialsModal, {
              "maxAmount": maxBuyMats
            }), !!isCombining && (0, _inferno.createComponentVNode)(2, _index.CombineGenesModal), menu === "research" && (0, _inferno.createComponentVNode)(2, _index.ResearchTab, {
              "maxBuyMats": maxBuyMats,
              "setBuyMats": setBuyMats
            }), menu === "mutations" && (0, _inferno.createComponentVNode)(2, _index.MutationsTab), menu === "storage" && (0, _inferno.createComponentVNode)(2, _index.StorageTab), menu === "record" && (record ? (0, _inferno.createComponentVNode)(2, _index.RecordTab) : (0, _inferno.createComponentVNode)(2, _index.StorageTab)), menu === "scanner" && (0, _inferno.createComponentVNode)(2, _index.ScannerTab)]
          })
        })
      })]
    })
  });
};

exports.GeneTek = GeneTek;

/***/ }),

/***/ "./packages/tgui/interfaces/GeneTek/AppearanceEditor.js":
/*!**************************************************************!*\
  !*** ./packages/tgui/interfaces/GeneTek/AppearanceEditor.js ***!
  \**************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.AppearanceEditor = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */
var AppearanceEditor = function AppearanceEditor(params, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act;

  var preview = params.preview,
      hairStyles = params.hairStyles,
      skin = params.skin,
      eyes = params.eyes,
      color1 = params.color1,
      color2 = params.color2,
      color3 = params.color3,
      style1 = params.style1,
      style2 = params.style2,
      style3 = params.style3,
      fixColors = params.fixColors,
      hasEyes = params.hasEyes,
      hasSkin = params.hasSkin,
      hasHair = params.hasHair,
      channels = params.channels;
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Appearance Editor",
    "buttons": (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
      "onClick": function () {
        function onClick() {
          return act("editappearance", {
            apply: true
          });
        }

        return onClick;
      }(),
      "icon": "user",
      "color": "good",
      children: "Apply Changes"
    }), (0, _inferno.createComponentVNode)(2, _components.Button, {
      "onClick": function () {
        function onClick() {
          return act("editappearance", {
            cancel: true
          });
        }

        return onClick;
      }(),
      "icon": "times",
      "color": "bad"
    })], 4),
    children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "shrink": "1",
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [!!hasSkin && (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Skin Tone",
            children: (0, _inferno.createComponentVNode)(2, ColorInput, {
              "color": skin,
              "onChange": function () {
                function onChange(c) {
                  return act("editappearance", {
                    skin: c
                  });
                }

                return onChange;
              }()
            })
          }), !!hasEyes && (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Eye Color",
            children: (0, _inferno.createComponentVNode)(2, ColorInput, {
              "color": eyes,
              "onChange": function () {
                function onChange(c) {
                  return act("editappearance", {
                    eyes: c
                  });
                }

                return onChange;
              }()
            })
          }), !!((hasSkin || hasEyes) && channels[0]) && (0, _inferno.createComponentVNode)(2, _components.LabeledList.Divider), !!channels[0] && !!hasHair && (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": channels[0],
            children: (0, _inferno.createComponentVNode)(2, _components.Dropdown, {
              "width": 20,
              "selected": style1,
              "onSelected": function () {
                function onSelected(s) {
                  return act("editappearance", {
                    style1: s
                  });
                }

                return onSelected;
              }(),
              "options": hairStyles
            })
          }), !!channels[0] && (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": channels[0].replace(/ Detail$/, "") + " Color",
            children: (0, _inferno.createComponentVNode)(2, ColorInput, {
              "color": color1,
              "onChange": function () {
                function onChange(c) {
                  return act("editappearance", {
                    color1: c
                  });
                }

                return onChange;
              }(),
              "fix": fixColors
            })
          }), !!channels[1] && (0, _inferno.createComponentVNode)(2, _components.LabeledList.Divider), !!channels[1] && !!hasHair && (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": channels[1],
            children: (0, _inferno.createComponentVNode)(2, _components.Dropdown, {
              "width": 20,
              "selected": style2,
              "onSelected": function () {
                function onSelected(s) {
                  return act("editappearance", {
                    style2: s
                  });
                }

                return onSelected;
              }(),
              "options": hairStyles
            })
          }), !!channels[1] && (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": channels[1].replace(/ Detail$/, "") + " Color",
            children: (0, _inferno.createComponentVNode)(2, ColorInput, {
              "color": color2,
              "onChange": function () {
                function onChange(c) {
                  return act("editappearance", {
                    color2: c
                  });
                }

                return onChange;
              }(),
              "fix": fixColors
            })
          }), !!channels[2] && (0, _inferno.createComponentVNode)(2, _components.LabeledList.Divider), !!channels[2] && !!hasHair && (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": channels[2],
            children: (0, _inferno.createComponentVNode)(2, _components.Dropdown, {
              "width": 20,
              "selected": style3,
              "onSelected": function () {
                function onSelected(s) {
                  return act("editappearance", {
                    style3: s
                  });
                }

                return onSelected;
              }(),
              "options": hairStyles
            })
          }), !!channels[2] && (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": channels[2].replace(/ Detail$/, "") + " Color",
            children: (0, _inferno.createComponentVNode)(2, ColorInput, {
              "color": color3,
              "onChange": function () {
                function onChange(c) {
                  return act("editappearance", {
                    color3: c
                  });
                }

                return onChange;
              }(),
              "fix": fixColors
            })
          })]
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "basis": "80px",
        "shrink": "0",
        children: (0, _inferno.createComponentVNode)(2, _components.ByondUi, {
          "params": {
            id: preview,
            type: "map"
          },
          "style": {
            width: "80px",
            height: "160px"
          }
        })
      })]
    })
  });
};

exports.AppearanceEditor = AppearanceEditor;

var ColorInput = function ColorInput(params, context) {
  var color = params.color,
      onChange = params.onChange,
      fix = params.fix;
  var r = parseInt(color.substr(1, 2), 16);
  var g = parseInt(color.substr(3, 2), 16);
  var b = parseInt(color.substr(5, 2), 16);

  var onComponentChange = function onComponentChange(newR, newG, newB) {
    if (onChange) {
      onChange("#" + newR.toString(16).padStart(2, "0") + newG.toString(16).padStart(2, "0") + newB.toString(16).padStart(2, "0"));
    }
  };

  return (0, _inferno.createComponentVNode)(2, _components.Box, {
    children: [(0, _inferno.createComponentVNode)(2, _components.ColorBox, {
      "color": color
    }), (0, _inferno.createComponentVNode)(2, _components.Knob, {
      "inline": true,
      "ml": 1,
      "minValue": fix ? 50 : 0,
      "maxValue": fix ? 190 : 255,
      "value": r,
      "color": "red",
      "onChange": function () {
        function onChange(_, newR) {
          return onComponentChange(newR, g, b);
        }

        return onChange;
      }()
    }), (0, _inferno.createComponentVNode)(2, _components.Knob, {
      "inline": true,
      "ml": 1,
      "minValue": fix ? 50 : 0,
      "maxValue": fix ? 190 : 255,
      "value": g,
      "color": "green",
      "onChange": function () {
        function onChange(_, newG) {
          return onComponentChange(r, newG, b);
        }

        return onChange;
      }()
    }), (0, _inferno.createComponentVNode)(2, _components.Knob, {
      "inline": true,
      "ml": 1,
      "minValue": fix ? 50 : 0,
      "maxValue": fix ? 190 : 255,
      "value": b,
      "color": "blue",
      "onChange": function () {
        function onChange(_, newB) {
          return onComponentChange(r, g, newB);
        }

        return onChange;
      }()
    })]
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/GeneTek/BioEffect.js":
/*!*******************************************************!*\
  !*** ./packages/tgui/interfaces/GeneTek/BioEffect.js ***!
  \*******************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.GeneList = exports.Description = exports.BioEffect = exports.onCooldown = exports.haveDevice = exports.ResearchLevel = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _UnlockModal = __webpack_require__(/*! ./modals/UnlockModal */ "./packages/tgui/interfaces/GeneTek/modals/UnlockModal.js");

var _DNASequence = __webpack_require__(/*! ./DNASequence */ "./packages/tgui/interfaces/GeneTek/DNASequence.js");

var _GeneIcon = __webpack_require__(/*! ./GeneIcon */ "./packages/tgui/interfaces/GeneTek/GeneIcon.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _createForOfIteratorHelperLoose(o, allowArrayLike) { var it = typeof Symbol !== "undefined" && o[Symbol.iterator] || o["@@iterator"]; if (it) return (it = it.call(o)).next.bind(it); if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; return function () { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

var ResearchLevel = {
  None: 0,
  InProgress: 1,
  Done: 2,
  Activated: 3
};
exports.ResearchLevel = ResearchLevel;

var haveDevice = function haveDevice(equipmentCooldown, name) {
  for (var _iterator = _createForOfIteratorHelperLoose(equipmentCooldown), _step; !(_step = _iterator()).done;) {
    var _step$value = _step.value,
        label = _step$value.label,
        cooldown = _step$value.cooldown;

    if (label === name) {
      return true;
    }
  }

  return false;
};

exports.haveDevice = haveDevice;

var onCooldown = function onCooldown(equipmentCooldown, name) {
  for (var _iterator2 = _createForOfIteratorHelperLoose(equipmentCooldown), _step2; !(_step2 = _iterator2()).done;) {
    var _step2$value = _step2.value,
        label = _step2$value.label,
        cooldown = _step2$value.cooldown;

    if (label === name) {
      return cooldown > 0;
    }
  }

  return true;
};

exports.onCooldown = onCooldown;

var BioEffect = function BioEffect(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data,
      act = _useBackend.act;

  var _useSharedState = (0, _backend.useSharedState)(context, "booth", null),
      booth = _useSharedState[0],
      setBooth = _useSharedState[1];

  var materialCur = data.materialCur,
      researchCost = data.researchCost,
      equipmentCooldown = data.equipmentCooldown,
      saveSlots = data.saveSlots,
      savedMutations = data.savedMutations,
      subject = data.subject,
      boothCost = data.boothCost,
      injectorCost = data.injectorCost,
      precisionEmitter = data.precisionEmitter,
      toSplice = data.toSplice;
  var gene = props.gene,
      showSequence = props.showSequence,
      isSample = props.isSample,
      isPotential = props.isPotential,
      isActive = props.isActive,
      isStorage = props.isStorage;
  var ref = gene.ref,
      name = gene.name,
      desc = gene.desc,
      icon = gene.icon,
      research = gene.research,
      canResearch = gene.canResearch,
      canInject = gene.canInject,
      canScramble = gene.canScramble,
      canReclaim = gene.canReclaim,
      spliceError = gene.spliceError,
      dna = gene.dna;
  var dnaGood = dna.every(function (pair) {
    return !pair.style;
  });
  var dnaGoodExceptLocks = dna.every(function (pair) {
    return !pair.style || pair.marker === "locked";
  });
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": name,
    "buttons": (0, _inferno.createComponentVNode)(2, _GeneIcon.GeneIcon, {
      "name": icon,
      "size": 1.5
    }),
    children: [booth && booth.ref === ref && (0, _inferno.createComponentVNode)(2, _components.Modal, {
      "full": true,
      children: (0, _inferno.createComponentVNode)(2, _components.Section, {
        "width": 35,
        "title": name,
        "style": {
          "margin": "-10px",
          "margin-right": "2px"
        },
        "buttons": (0, _inferno.createComponentVNode)(2, _GeneIcon.GeneIcon, {
          "name": icon,
          "size": 4,
          "style": {
            "margin-top": "-2px",
            "margin-right": "-4px"
          }
        }),
        children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Price",
            children: (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
              "minValue": 0,
              "maxValue": 999999,
              "width": 5,
              "value": booth.price,
              "onChange": function () {
                function onChange(_, price) {
                  return setBooth({
                    ref: booth.ref,
                    price: price,
                    desc: booth.desc
                  });
                }

                return onChange;
              }()
            })
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Description",
            children: (0, _inferno.createComponentVNode)(2, _components.Input, {
              "width": 25,
              "value": booth.desc,
              "onChange": function () {
                function onChange(_, desc) {
                  return setBooth({
                    ref: booth.ref,
                    price: booth.price,
                    desc: desc
                  });
                }

                return onChange;
              }()
            })
          })]
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "inline": true,
          "width": "50%",
          "textAlign": "center",
          "mt": 2,
          children: (0, _inferno.createComponentVNode)(2, _components.Button, {
            "icon": "person-booth",
            "color": "good",
            "disabled": boothCost > materialCur,
            "onClick": function () {
              function onClick() {
                return act("booth", booth);
              }

              return onClick;
            }(),
            children: "Send to Booth"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "inline": true,
          "width": "50%",
          "textAlign": "center",
          children: (0, _inferno.createComponentVNode)(2, _components.Button, {
            "icon": "times",
            "color": "bad",
            "onClick": function () {
              function onClick() {
                return setBooth(null);
              }

              return onClick;
            }(),
            children: "Cancel"
          })
        })]
      })
    }), (0, _inferno.createComponentVNode)(2, _UnlockModal.UnlockModal), (0, _inferno.createComponentVNode)(2, _components.Box, {
      "textAlign": "right",
      children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
        "mr": 1,
        "style": {
          "float": "left"
        },
        children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
          "color": research >= 3 ? "good" : research >= 2 ? "teal" : research >= 1 ? "average" : "bad",
          "name": research >= 2 ? "flask" : research >= 1 ? "hourglass" : "times"
        }), research >= 2 ? " Researched" : research >= 1 ? " In Progress" : " Not Researched"]
      }), !isActive && !!canResearch && research === 0 && (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "flask",
        "disabled": researchCost > materialCur,
        "onClick": function () {
          function onClick() {
            return act("researchmut", {
              ref: ref,
              sample: !!isSample
            });
          }

          return onClick;
        }(),
        "color": "teal",
        children: "Research"
      }), isPotential && (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "check",
        "disabled": !dnaGood,
        "onClick": function () {
          function onClick() {
            return act("activate", {
              ref: ref
            });
          }

          return onClick;
        }(),
        "color": "blue",
        children: "Activate"
      }), research >= 3 && !dnaGood && (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "magic",
        "disabled": dnaGoodExceptLocks,
        "onClick": function () {
          function onClick() {
            return act("autocomplete", {
              ref: ref
            });
          }

          return onClick;
        }(),
        children: "Autocomplete DNA"
      }), haveDevice(equipmentCooldown, "Analyzer") && !dnaGood && isPotential && (0, _inferno.createComponentVNode)(2, _components.Button, {
        "disabled": onCooldown(equipmentCooldown, "Analyzer"),
        "icon": "microscope",
        "color": "average",
        "onClick": function () {
          function onClick() {
            return act("analyze", {
              ref: ref
            });
          }

          return onClick;
        }(),
        children: "Check Stability"
      }), haveDevice(equipmentCooldown, "Reclaimer") && isPotential && !!canReclaim && (0, _inferno.createComponentVNode)(2, _components.Button, {
        "disabled": onCooldown(equipmentCooldown, "Reclaimer"),
        "icon": "times",
        "color": "bad",
        "onClick": function () {
          function onClick() {
            return act("reclaim", {
              ref: ref
            });
          }

          return onClick;
        }(),
        children: "Reclaim"
      }), boothCost >= 0 && research >= 2 && (isActive || isStorage) && (0, _inferno.createComponentVNode)(2, _components.Button, {
        "disabled": materialCur < boothCost,
        "icon": "person-booth",
        "color": "good",
        "onClick": function () {
          function onClick() {
            return setBooth({
              ref: ref,
              price: 200,
              desc: ""
            });
          }

          return onClick;
        }(),
        children: "Sell at Booth"
      }), !!precisionEmitter && research >= 2 && isPotential && !!canScramble && (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "radiation",
        "disabled": onCooldown(equipmentCooldown, "Emitter") || subject.stat > 0,
        "color": "bad",
        "onClick": function () {
          function onClick() {
            return act("precisionemitter", {
              ref: ref
            });
          }

          return onClick;
        }(),
        children: "Scramble Gene"
      }), saveSlots > 0 && research >= 2 && isActive && (0, _inferno.createComponentVNode)(2, _components.Button, {
        "disabled": saveSlots <= savedMutations.length,
        "icon": "save",
        "color": "average",
        "onClick": function () {
          function onClick() {
            return act("save", {
              ref: ref
            });
          }

          return onClick;
        }(),
        children: "Store"
      }), research >= 2 && !!canInject && haveDevice(equipmentCooldown, "Injectors") && (0, _inferno.createComponentVNode)(2, _components.Button, {
        "disabled": onCooldown(equipmentCooldown, "Injectors"),
        "icon": "syringe",
        "onClick": function () {
          function onClick() {
            return act("activator", {
              ref: ref
            });
          }

          return onClick;
        }(),
        children: "Activator"
      }), research >= 2 && !!canInject && injectorCost >= 0 && (isActive || isStorage) && (0, _inferno.createComponentVNode)(2, _components.Button, {
        "disabled": onCooldown(equipmentCooldown, "Injectors") || materialCur < injectorCost,
        "icon": "syringe",
        "onClick": function () {
          function onClick() {
            return act("injector", {
              ref: ref
            });
          }

          return onClick;
        }(),
        "color": "bad",
        children: "Injector"
      }), (isActive || isStorage) && !!toSplice && (0, _inferno.createComponentVNode)(2, _components.Button, {
        "disabled": !!spliceError,
        "icon": "map-marker-alt",
        "onClick": function () {
          function onClick() {
            return act("splicegene", {
              ref: ref
            });
          }

          return onClick;
        }(),
        "tooltip": spliceError,
        "tooltipPosition": "left",
        children: "Splice"
      }), isStorage && subject && (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "check",
        "onClick": function () {
          function onClick() {
            return act("addstored", {
              ref: ref
            });
          }

          return onClick;
        }(),
        "color": "blue",
        children: "Add to Occupant"
      }), isStorage && (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "trash",
        "onClick": function () {
          function onClick() {
            return act("deletegene", {
              ref: ref
            });
          }

          return onClick;
        }(),
        "color": "bad"
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        "inline": true
      })]
    }), (0, _inferno.createComponentVNode)(2, Description, {
      "text": desc
    }), showSequence && (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _DNASequence.DNASequence, Object.assign({}, props)))]
  });
};

exports.BioEffect = BioEffect;

var Description = function Description(props, context) {
  var lines = props.text.split(/<br ?\/?>/g);
  return lines.map(function (line, i) {
    return (0, _inferno.createVNode)(1, "p", null, line, 0, null, i);
  });
};

exports.Description = Description;

var GeneList = function GeneList(props, context) {
  var _researchLevels;

  var _useBackend2 = (0, _backend.useBackend)(context),
      data = _useBackend2.data,
      act = _useBackend2.act;

  var activeGene = data.activeGene;

  var genes = props.genes,
      noSelection = props.noSelection,
      noGenes = props.noGenes,
      rest = _objectWithoutPropertiesLoose(props, ["genes", "noSelection", "noGenes"]);

  var ag = genes.find(function (g) {
    return g.ref === activeGene;
  });
  var researchLevels = (_researchLevels = {}, _researchLevels[ResearchLevel.None] = {
    icon: "question",
    color: "grey"
  }, _researchLevels[ResearchLevel.InProgress] = {
    icon: "hourglass",
    color: "average"
  }, _researchLevels[ResearchLevel.Done] = {
    icon: "flask",
    color: "teal"
  }, _researchLevels[ResearchLevel.Activated] = {
    icon: "flask",
    color: "good"
  }, _researchLevels);
  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Flex, {
    "wrap": true,
    "mb": 1,
    children: genes.map(function (g) {
      return (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "grow": 1,
        "textAlign": "center",
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": researchLevels[g.research].icon,
          "color": g.ref === activeGene ? "black" : researchLevels[g.research].color,
          "onClick": function () {
            function onClick() {
              return act("setgene", {
                ref: g.ref
              });
            }

            return onClick;
          }(),
          "tooltip": g.research === ResearchLevel.InProgress ? "Researching..." : g.name,
          "tooltipPosition": "left",
          "width": "80%"
        })
      }, g.ref);
    })
  }), !genes.length && (noGenes || "No genes found."), !!genes.length && !ag && (noSelection || "Select a gene to view it."), ag && (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, BioEffect, Object.assign({
    "gene": ag,
    "showSequence": true
  }, rest), ag.ref))], 0);
};

exports.GeneList = GeneList;

/***/ }),

/***/ "./packages/tgui/interfaces/GeneTek/DNASequence.js":
/*!*********************************************************!*\
  !*** ./packages/tgui/interfaces/GeneTek/DNASequence.js ***!
  \*********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Nucleotide = exports.DNASequence = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var letterColor = {
  "?": "grey",
  "A": "red",
  "T": "blue",
  "C": "yellow",
  "G": "green"
};
var typeColor = {
  "": "good",
  "X": "grey",
  "1": "good",
  "2": "olive",
  "3": "average",
  "4": "orange",
  "5": "bad"
};

var DNASequence = function DNASequence(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act;

  var gene = props.gene,
      isPotential = props.isPotential;
  var sequence = gene.dna;
  var allGood = true;
  var blocks = [];

  for (var i = 0; i < sequence.length; i++) {
    if (i % 4 === 0) {
      blocks.push([]);
    }

    blocks[blocks.length - 1].push(sequence[i]);

    if (sequence[i].style) {
      allGood = false;
    }
  }

  var advancePair = function advancePair(i) {
    if (isPotential) {
      act("advancepair", {
        ref: gene.ref,
        pair: i
      });
    }
  };

  return blocks.map(function (block, i) {
    return (0, _inferno.createVNode)(1, "table", null, [(0, _inferno.createVNode)(1, "tr", null, block.map(function (pair, j) {
      return (0, _inferno.createVNode)(1, "td", null, (0, _inferno.createComponentVNode)(2, Nucleotide, {
        "letter": pair.pair.charAt(0),
        "type": pair.style,
        "mark": pair.marker,
        "useLetterColor": allGood,
        "onClick": function () {
          function onClick() {
            return advancePair(i * 4 + j + 1);
          }

          return onClick;
        }()
      }), 2, null, j);
    }), 0), (0, _inferno.createVNode)(1, "tr", null, block.map(function (pair, j) {
      return (0, _inferno.createVNode)(1, "td", null, allGood ? "|" : pair.marker === "locked" ? (0, _inferno.createComponentVNode)(2, _components.Icon, {
        "name": "lock",
        "color": "average",
        "onClick": function () {
          function onClick() {
            return advancePair(i * 4 + j + 1);
          }

          return onClick;
        }()
      }) : (0, _inferno.createComponentVNode)(2, _components.Icon, {
        "name": pair.style === "" ? "check" // correct
        : pair.style === "5" ? "times" // incorrect
        : "question" // changed since last analyze
        ,
        "color": typeColor[pair.style]
      }), 0, {
        "style": {
          "text-align": "center"
        }
      }, j);
    }), 0), (0, _inferno.createVNode)(1, "tr", null, block.map(function (pair, j) {
      return (0, _inferno.createVNode)(1, "td", null, (0, _inferno.createComponentVNode)(2, Nucleotide, {
        "letter": pair.pair.charAt(1),
        "type": pair.style,
        "mark": pair.marker,
        "useLetterColor": allGood,
        "onClick": function () {
          function onClick() {
            return advancePair(i * 4 + j + 1);
          }

          return onClick;
        }()
      }), 2, null, j);
    }), 0)], 4, {
      "style": {
        display: "inline-table",
        "margin-top": "1em",
        "margin-left": i % 4 === 0 ? "0" : "0.25em",
        "margin-right": i % 4 === 3 ? "0" : "0.25em"
      }
    }, i);
  });
};

exports.DNASequence = DNASequence;

var Nucleotide = function Nucleotide(props) {
  var letter = props.letter,
      type = props.type,
      mark = props.mark,
      useLetterColor = props.useLetterColor,
      rest = _objectWithoutPropertiesLoose(props, ["letter", "type", "mark", "useLetterColor"]);

  var color = useLetterColor ? letterColor[letter] : typeColor[type];
  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _components.Button, Object.assign({
    "width": "1.75em",
    "textAlign": "center",
    "color": color
  }, rest, {
    children: letter
  })));
};

exports.Nucleotide = Nucleotide;

/***/ }),

/***/ "./packages/tgui/interfaces/GeneTek/GeneIcon.js":
/*!******************************************************!*\
  !*** ./packages/tgui/interfaces/GeneTek/GeneIcon.js ***!
  \******************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.GeneIcon = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _Box = __webpack_require__(/*! ../../components/Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var GeneIcon = function GeneIcon(props) {
  var name = props.name,
      size = props.size,
      _props$style = props.style,
      style = _props$style === void 0 ? {} : _props$style,
      rest = _objectWithoutPropertiesLoose(props, ["name", "size", "style"]);

  if (size) {
    style["font-size"] = size * 100 + "%";
  }

  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Box.Box, Object.assign({
    "as": "i",
    "className": (0, _react.classes)(["GeneIcon", "GeneIcon--" + name]),
    "style": style
  }, rest)));
};

exports.GeneIcon = GeneIcon;
GeneIcon.defaultHooks = _react.pureComponentHooks;

/***/ }),

/***/ "./packages/tgui/interfaces/GeneTek/index.js":
/*!***************************************************!*\
  !*** ./packages/tgui/interfaces/GeneTek/index.js ***!
  \***************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.StorageTab = exports.RecordTab = exports.ScannerTab = exports.ResearchTab = exports.MutationsTab = exports.UnlockModal = exports.CombineGenesModal = exports.BuyMaterialsModal = void 0;

var _BuyMaterialsModal = __webpack_require__(/*! ./modals/BuyMaterialsModal */ "./packages/tgui/interfaces/GeneTek/modals/BuyMaterialsModal.js");

exports.BuyMaterialsModal = _BuyMaterialsModal.BuyMaterialsModal;

var _CombineGenesModal = __webpack_require__(/*! ./modals/CombineGenesModal */ "./packages/tgui/interfaces/GeneTek/modals/CombineGenesModal.js");

exports.CombineGenesModal = _CombineGenesModal.CombineGenesModal;

var _UnlockModal = __webpack_require__(/*! ./modals/UnlockModal */ "./packages/tgui/interfaces/GeneTek/modals/UnlockModal.js");

exports.UnlockModal = _UnlockModal.UnlockModal;

var _MutationsTab = __webpack_require__(/*! ./tabs/MutationsTab */ "./packages/tgui/interfaces/GeneTek/tabs/MutationsTab.js");

exports.MutationsTab = _MutationsTab.MutationsTab;

var _ResearchTab = __webpack_require__(/*! ./tabs/ResearchTab */ "./packages/tgui/interfaces/GeneTek/tabs/ResearchTab.js");

exports.ResearchTab = _ResearchTab.ResearchTab;

var _ScannerTab = __webpack_require__(/*! ./tabs/ScannerTab */ "./packages/tgui/interfaces/GeneTek/tabs/ScannerTab.js");

exports.ScannerTab = _ScannerTab.ScannerTab;

var _StorageTab = __webpack_require__(/*! ./tabs/StorageTab */ "./packages/tgui/interfaces/GeneTek/tabs/StorageTab.js");

exports.RecordTab = _StorageTab.RecordTab;
exports.StorageTab = _StorageTab.StorageTab;

/***/ }),

/***/ "./packages/tgui/interfaces/GeneTek/modals/BuyMaterialsModal.js":
/*!**********************************************************************!*\
  !*** ./packages/tgui/interfaces/GeneTek/modals/BuyMaterialsModal.js ***!
  \**********************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.BuyMaterialsModal = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../../components */ "./packages/tgui/components/index.js");

/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */
var BuyMaterialsModal = function BuyMaterialsModal(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data,
      act = _useBackend.act;

  var _useSharedState = (0, _backend.useSharedState)(context, "buymats", null),
      buyMats = _useSharedState[0],
      setBuyMats = _useSharedState[1];

  var maxBuyMats = props.maxAmount;
  var budget = data.budget,
      costPerMaterial = data.costPerMaterial;
  var resolvedBuyMats = Math.min(buyMats, maxBuyMats);
  return (0, _inferno.createComponentVNode)(2, _components.Modal, {
    "full": true,
    children: (0, _inferno.createComponentVNode)(2, _components.Box, {
      "position": "relative",
      "width": 18,
      children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
        "position": "absolute",
        "right": 1,
        "top": 0,
        children: (0, _inferno.createComponentVNode)(2, _components.Knob, {
          "inline": true,
          "value": resolvedBuyMats,
          "onChange": function () {
            function onChange(e, value) {
              return setBuyMats(value);
            }

            return onChange;
          }(),
          "minValue": 1,
          "maxValue": maxBuyMats
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
        children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Purchase",
          children: [resolvedBuyMats, resolvedBuyMats === 1 ? " Material" : " Materials"]
        }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Budget",
          children: budget + " Credits"
        }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Cost",
          children: resolvedBuyMats * costPerMaterial + " Credits"
        }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Remainder",
          children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
            "inline": true,
            "color": budget - resolvedBuyMats * costPerMaterial < 0 && "bad",
            children: budget - resolvedBuyMats * costPerMaterial
          }), " Credits"]
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Divider, {
        "hidden": true
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        "inline": true,
        "width": "50%",
        "textAlign": "center",
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "color": "good",
          "icon": "dollar-sign",
          "disabled": resolvedBuyMats <= 0,
          "onClick": function () {
            function onClick() {
              act("purchasematerial", {
                amount: resolvedBuyMats
              });
              setBuyMats(null);
            }

            return onClick;
          }(),
          children: "Submit"
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        "inline": true,
        "width": "50%",
        "textAlign": "center",
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "color": "bad",
          "icon": "times",
          "onClick": function () {
            function onClick() {
              return setBuyMats(null);
            }

            return onClick;
          }(),
          children: "Cancel"
        })
      })]
    })
  });
};

exports.BuyMaterialsModal = BuyMaterialsModal;

/***/ }),

/***/ "./packages/tgui/interfaces/GeneTek/modals/CombineGenesModal.js":
/*!**********************************************************************!*\
  !*** ./packages/tgui/interfaces/GeneTek/modals/CombineGenesModal.js ***!
  \**********************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.CombineGenesModal = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../../components */ "./packages/tgui/components/index.js");

/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */
var CombineGenesModal = function CombineGenesModal(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data,
      act = _useBackend.act;

  var _useSharedState = (0, _backend.useSharedState)(context, "iscombining", false),
      isCombining = _useSharedState[0],
      setIsCombining = _useSharedState[1];

  var savedMutations = data.savedMutations,
      _data$combining = data.combining,
      combining = _data$combining === void 0 ? [] : _data$combining;
  return (0, _inferno.createComponentVNode)(2, _components.Modal, {
    "full": true,
    children: (0, _inferno.createComponentVNode)(2, _components.Box, {
      "width": 16,
      "mr": 2,
      children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
        "bold": true,
        "mb": 2,
        children: "Select genes to combine"
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        "mb": 2,
        children: savedMutations.map(function (g) {
          return (0, _inferno.createComponentVNode)(2, _components.Box, {
            children: [combining.indexOf(g.ref) >= 0 ? (0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": "check",
              "color": "blue",
              "onClick": function () {
                function onClick() {
                  return act("togglecombine", {
                    ref: g.ref
                  });
                }

                return onClick;
              }()
            }) : (0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": "blank",
              "color": "grey",
              "onClick": function () {
                function onClick() {
                  return act("togglecombine", {
                    ref: g.ref
                  });
                }

                return onClick;
              }()
            }), " " + g.name]
          }, g.ref);
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        "inline": true,
        "width": "50%",
        "textAlign": "center",
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "sitemap",
          "disabled": !combining.length,
          "onClick": function () {
            function onClick() {
              act("combinegenes");
              setIsCombining(false);
            }

            return onClick;
          }(),
          children: "Combine"
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        "inline": true,
        "width": "50%",
        "textAlign": "center",
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "color": "bad",
          "icon": "times",
          "onClick": function () {
            function onClick() {
              return setIsCombining(false);
            }

            return onClick;
          }(),
          children: "Cancel"
        })
      })]
    })
  });
};

exports.CombineGenesModal = CombineGenesModal;

/***/ }),

/***/ "./packages/tgui/interfaces/GeneTek/modals/UnlockModal.js":
/*!****************************************************************!*\
  !*** ./packages/tgui/interfaces/GeneTek/modals/UnlockModal.js ***!
  \****************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.UnlockModal = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../../components */ "./packages/tgui/components/index.js");

/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */
var UnlockModal = function UnlockModal(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data,
      act = _useBackend.act;

  var _useSharedState = (0, _backend.useSharedState)(context, "unlockcode", ""),
      unlockCode = _useSharedState[0],
      setUnlockCode = _useSharedState[1];

  var autoDecryptors = data.autoDecryptors,
      unlock = data.unlock;

  if (!unlock) {
    return;
  }

  return (0, _inferno.createComponentVNode)(2, _components.Modal, {
    "full": true,
    children: (0, _inferno.createComponentVNode)(2, _components.Box, {
      "width": 22,
      "mr": 2,
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList, {
        children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Detected Length",
          children: [unlock.length, " characters"]
        }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Possible Characters",
          children: unlock.chars.join(" ")
        }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Enter Unlock Code",
          children: (0, _inferno.createComponentVNode)(2, _components.Input, {
            "value": unlockCode,
            "onChange": function () {
              function onChange(_, code) {
                return setUnlockCode(code.toUpperCase());
              }

              return onChange;
            }()
          })
        }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Correct Characters",
          children: [unlock.correctChar, " of ", unlock.length]
        }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Correct Positions",
          children: [unlock.correctPos, " of ", unlock.length]
        }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Attempts Remaining",
          children: [unlock.tries, " before mutation"]
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        "textAlign": "right",
        "mt": 2,
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "magic",
          "color": "average",
          "tooltip": "Auto-Decryptors Available: " + autoDecryptors,
          "disabled": autoDecryptors < 1,
          "onClick": function () {
            function onClick() {
              setUnlockCode("");
              act("unlock", {
                code: "UNLOCK"
              });
            }

            return onClick;
          }(),
          children: "Use Auto-Decryptor"
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        "textAlign": "right",
        "mt": 1,
        children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
          "mr": 1,
          "icon": "check",
          "color": "good",
          "tooltip": unlockCode.length !== unlock.length ? "Code is the wrong length." : unlockCode.split("").some(function (c) {
            return unlock.chars.indexOf(c) === -1;
          }) ? "Invalid character in code." : "",
          "disabled": unlockCode.length !== unlock.length || unlockCode.split("").some(function (c) {
            return unlock.chars.indexOf(c) === -1;
          }),
          "onClick": function () {
            function onClick() {
              setUnlockCode("");
              act("unlock", {
                code: unlockCode
              });
            }

            return onClick;
          }(),
          children: "Attempt Decryption"
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "times",
          "color": "bad",
          "onClick": function () {
            function onClick() {
              setUnlockCode("");
              act("unlock", {
                code: null
              });
            }

            return onClick;
          }(),
          children: "Cancel"
        })]
      })]
    })
  });
};

exports.UnlockModal = UnlockModal;

/***/ }),

/***/ "./packages/tgui/interfaces/GeneTek/tabs/MutationsTab.js":
/*!***************************************************************!*\
  !*** ./packages/tgui/interfaces/GeneTek/tabs/MutationsTab.js ***!
  \***************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.MutationsTab = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../../components */ "./packages/tgui/components/index.js");

var _BioEffect = __webpack_require__(/*! ../BioEffect */ "./packages/tgui/interfaces/GeneTek/BioEffect.js");

/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */
var MutationsTab = function MutationsTab(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data;

  var _useSharedState = (0, _backend.useSharedState)(context, "mutsortmode", "time"),
      sortMode = _useSharedState[0],
      setSortMode = _useSharedState[1];

  var _useSharedState2 = (0, _backend.useSharedState)(context, 'showSequence', false),
      showSequence = _useSharedState2[0],
      toggleShowSequence = _useSharedState2[1];

  var bioEffects = (data.bioEffects || []).slice(0);

  if (sortMode === "time") {
    bioEffects.sort(function (a, b) {
      return a.time - b.time;
    });
  } else if (sortMode === "alpha") {
    bioEffects.sort(function (a, b) {
      if (a.name > b.name) {
        return 1;
      }

      if (a.name < b.name) {
        return -1;
      }

      return 0;
    });
  }

  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Section, {
    children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
      "icon": sortMode === "time" ? "clock" : "sort-alpha-down",
      "onClick": function () {
        function onClick() {
          return setSortMode(sortMode === "time" ? "alpha" : "time");
        }

        return onClick;
      }(),
      children: "Sort Mode"
    }), (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
      "inline": true,
      "content": "Show Sequence",
      "checked": showSequence,
      "onClick": function () {
        function onClick() {
          return toggleShowSequence(!showSequence);
        }

        return onClick;
      }()
    })]
  }), bioEffects.map(function (be) {
    return (0, _inferno.createComponentVNode)(2, _BioEffect.BioEffect, {
      "gene": be,
      "showSequence": showSequence
    }, be.ref);
  })], 0);
};

exports.MutationsTab = MutationsTab;

/***/ }),

/***/ "./packages/tgui/interfaces/GeneTek/tabs/ResearchTab.js":
/*!**************************************************************!*\
  !*** ./packages/tgui/interfaces/GeneTek/tabs/ResearchTab.js ***!
  \**************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ResearchTab = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../../components */ "./packages/tgui/components/index.js");

var _BioEffect = __webpack_require__(/*! ../BioEffect */ "./packages/tgui/interfaces/GeneTek/BioEffect.js");

/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */
var ResearchTab = function ResearchTab(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data,
      act = _useBackend.act;

  var materialCur = data.materialCur,
      materialMax = data.materialMax,
      budget = data.budget,
      mutationsResearched = data.mutationsResearched,
      autoDecryptors = data.autoDecryptors,
      saveSlots = data.saveSlots,
      availableResearch = data.availableResearch,
      finishedResearch = data.finishedResearch,
      savedMutations = data.savedMutations,
      research = data.research;
  var maxBuyMats = props.maxBuyMats,
      setBuyMats = props.setBuyMats;
  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Statistics",
    "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
      "icon": "dollar-sign",
      "disabled": maxBuyMats <= 0,
      "onClick": function () {
        function onClick() {
          return setBuyMats(1);
        }

        return onClick;
      }(),
      children: "Purchase Additional Materials"
    }),
    children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Research Materials",
        children: [materialCur, " / ", materialMax]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Research Budget",
        children: [(0, _inferno.createComponentVNode)(2, _components.AnimatedNumber, {
          "value": budget
        }), " Credits"]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Mutations Researched",
        children: mutationsResearched
      }), saveSlots > 0 && (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Mutations Stored",
        children: [savedMutations.length, " / ", saveSlots]
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Auto-Decryptors",
        children: autoDecryptors
      })]
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Available Research",
    children: availableResearch.map(function (ar, tier) {
      return (0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Tier " + (tier + 1),
        children: ar.length ? ar.map(function (r) {
          return (0, _inferno.createComponentVNode)(2, _components.Section, {
            "title": research[r.ref].name,
            "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": "flask",
              "disabled": materialCur < r.cost,
              "onClick": function () {
                function onClick() {
                  return act("research", {
                    ref: r.ref
                  });
                }

                return onClick;
              }(),
              "color": "teal",
              children: "Research (" + r.cost + " mat, " + r.time + "s)"
            }),
            children: (0, _inferno.createComponentVNode)(2, _BioEffect.Description, {
              "text": research[r.ref].desc
            })
          }, r.ref);
        }) : "No research is currently available at this tier."
      }, tier);
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Finished Research",
    children: finishedResearch.map(function (fr, tier) {
      return (0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Tier " + (tier + 1),
        children: fr.length ? fr.map(function (r) {
          return (0, _inferno.createComponentVNode)(2, _components.Section, {
            "title": research[r.ref].name,
            children: (0, _inferno.createComponentVNode)(2, _BioEffect.Description, {
              "text": research[r.ref].desc
            })
          }, research[r.ref].name);
        }) : "No research has been completed at this tier."
      }, tier);
    })
  })], 4);
};

exports.ResearchTab = ResearchTab;

/***/ }),

/***/ "./packages/tgui/interfaces/GeneTek/tabs/ScannerTab.js":
/*!*************************************************************!*\
  !*** ./packages/tgui/interfaces/GeneTek/tabs/ScannerTab.js ***!
  \*************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ScannerTab = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../../components */ "./packages/tgui/components/index.js");

var _AppearanceEditor = __webpack_require__(/*! ../AppearanceEditor */ "./packages/tgui/interfaces/GeneTek/AppearanceEditor.js");

var _BioEffect = __webpack_require__(/*! ../BioEffect */ "./packages/tgui/interfaces/GeneTek/BioEffect.js");

var _GeneIcon = __webpack_require__(/*! ../GeneIcon */ "./packages/tgui/interfaces/GeneTek/GeneIcon.js");

/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */
var ScannerTab = function ScannerTab(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data,
      act = _useBackend.act;

  var _useSharedState = (0, _backend.useSharedState)(context, "changingmutantrace", false),
      changingMutantRace = _useSharedState[0],
      setChangingMutantRace = _useSharedState[1];

  var _useSharedState2 = (0, _backend.useSharedState)(context, 'togglePreview', false),
      showPreview = _useSharedState2[0],
      togglePreview = _useSharedState2[1];

  var haveScanner = data.haveScanner,
      subject = data.subject,
      modifyAppearance = data.modifyAppearance,
      equipmentCooldown = data.equipmentCooldown,
      mutantRaces = data.mutantRaces;

  var _ref = subject || {},
      preview = _ref.preview,
      name = _ref.name,
      health = _ref.health,
      human = _ref.human,
      age = _ref.age,
      bloodType = _ref.bloodType,
      mutantRace = _ref.mutantRace,
      canAppearance = _ref.canAppearance,
      premature = _ref.premature,
      potential = _ref.potential,
      active = _ref.active;

  if (changingMutantRace && (!subject || !human || premature)) {
    changingMutantRace = false;
    setChangingMutantRace(false);
  }

  if (!subject) {
    return (0, _inferno.createComponentVNode)(2, _components.Section, {
      "title": "Scanner Error",
      children: haveScanner ? "Subject has absconded." : "Check connection to scanner."
    });
  }

  return (0, _inferno.createFragment)([!!changingMutantRace && (0, _inferno.createComponentVNode)(2, _components.Modal, {
    "full": true,
    children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
      "bold": true,
      "width": 20,
      "mb": 0.5,
      children: "Change to which body type?"
    }), mutantRaces.map(function (mr) {
      return (0, _inferno.createComponentVNode)(2, _components.Box, {
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "color": "blue",
          "disabled": mutantRace === mr.name,
          "mt": 0.5,
          "onClick": function () {
            function onClick() {
              setChangingMutantRace(false);
              act("mutantrace", {
                ref: mr.ref
              });
            }

            return onClick;
          }(),
          children: [(0, _inferno.createComponentVNode)(2, _GeneIcon.GeneIcon, {
            "name": mr.icon,
            "size": 1.5,
            "style": {
              "margin": "-4px",
              "margin-right": "4px"
            }
          }), mr.name]
        })
      }, mr.ref);
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      "mt": 1,
      "textAlign": "right",
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "color": "bad",
        "icon": "times",
        "onClick": function () {
          function onClick() {
            return setChangingMutantRace(false);
          }

          return onClick;
        }(),
        children: "Cancel"
      })
    })]
  }), modifyAppearance ? (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _AppearanceEditor.AppearanceEditor, Object.assign({}, modifyAppearance))) : (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Occupant",
    children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "mr": 1,
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Name",
            "buttons": (0, _BioEffect.haveDevice)(equipmentCooldown, "Emitter") && (0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": "radiation",
              "disabled": (0, _BioEffect.onCooldown)(equipmentCooldown, "Emitter") || health <= 0,
              "color": "bad",
              "onClick": function () {
                function onClick() {
                  return act("emitter");
                }

                return onClick;
              }(),
              children: "Scramble DNA"
            }),
            children: name
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Body Type",
            "buttons": !!human && (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": "user",
              "color": "blue",
              "disabled": !!premature,
              "onClick": function () {
                function onClick() {
                  return setChangingMutantRace(true);
                }

                return onClick;
              }(),
              children: "Change"
            }), (0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": "wrench",
              "color": "average",
              "disabled": !canAppearance,
              "onClick": function () {
                function onClick() {
                  return act("editappearance");
                }

                return onClick;
              }()
            })], 4),
            children: mutantRace
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Physical Age",
            "buttons": !!human && (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
              "inline": true,
              "color": "good",
              "content": "DNA Render",
              "checked": showPreview,
              "onClick": function () {
                function onClick() {
                  return togglePreview(!showPreview);
                }

                return onClick;
              }()
            }),
            children: [age, " years"]
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Blood Type",
            children: bloodType
          })]
        })
      }), human && showPreview && (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "grow": 0,
        "shrink": 0,
        children: (0, _inferno.createComponentVNode)(2, _components.ByondUi, {
          "params": {
            id: preview,
            type: "map"
          },
          "style": {
            width: "64px",
            height: "128px"
          },
          "hideOnScroll": true
        })
      })]
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Potential Genes",
    children: (0, _inferno.createComponentVNode)(2, _BioEffect.GeneList, {
      "genes": potential,
      "noGenes": "All detected potential mutations are active.",
      "isPotential": true
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Active Mutations",
    children: (0, _inferno.createComponentVNode)(2, _BioEffect.GeneList, {
      "genes": active,
      "noGenes": "Subject has no detected mutations.",
      "isActive": true
    })
  })], 4)], 0);
};

exports.ScannerTab = ScannerTab;

/***/ }),

/***/ "./packages/tgui/interfaces/GeneTek/tabs/StorageTab.js":
/*!*************************************************************!*\
  !*** ./packages/tgui/interfaces/GeneTek/tabs/StorageTab.js ***!
  \*************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.RecordTab = exports.StorageTab = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../../backend */ "./packages/tgui/backend.ts");

var _BioEffect = __webpack_require__(/*! ../BioEffect */ "./packages/tgui/interfaces/GeneTek/BioEffect.js");

var _components = __webpack_require__(/*! ../../../components */ "./packages/tgui/components/index.js");

/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */
var StorageTab = function StorageTab(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data,
      act = _useBackend.act;

  var _useSharedState = (0, _backend.useSharedState)(context, "menu", "research"),
      menu = _useSharedState[0],
      setMenu = _useSharedState[1];

  var _useSharedState2 = (0, _backend.useSharedState)(context, "iscombining", false),
      isCombining = _useSharedState2[0],
      setIsCombining = _useSharedState2[1];

  var saveSlots = data.saveSlots,
      samples = data.samples,
      savedMutations = data.savedMutations,
      savedChromosomes = data.savedChromosomes,
      toSplice = data.toSplice;
  var chromosomes = Object.values(savedChromosomes.reduce(function (p, c) {
    if (!p[c.name]) {
      p[c.name] = {
        name: c.name,
        desc: c.desc,
        count: 0
      };
    }

    p[c.name].count++;
    p[c.name].ref = c.ref;
    return p;
  }, {}));
  chromosomes.sort(function (a, b) {
    return a.name > b.name ? 1 : -1;
  });
  return (0, _inferno.createFragment)([saveSlots > 0 && (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Stored Mutations",
    "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
      "icon": "sitemap",
      "onClick": function () {
        function onClick() {
          return setIsCombining(true);
        }

        return onClick;
      }(),
      children: "Combine"
    }),
    children: savedMutations.length ? savedMutations.map(function (g) {
      return (0, _inferno.createComponentVNode)(2, _BioEffect.BioEffect, {
        "gene": g,
        "showSequence": true,
        "isStorage": true
      }, g.ref);
    }) : "There are no mutations in storage."
  }), (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Stored Chromosomes",
    children: chromosomes.length ? (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: chromosomes.map(function (c) {
        return (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": c.name,
          "buttons": (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
            "disabled": c.name === toSplice,
            "icon": "map-marker-alt",
            "onClick": function () {
              function onClick() {
                return act("splicechromosome", {
                  ref: c.ref
                });
              }

              return onClick;
            }(),
            children: "Splice"
          }), (0, _inferno.createComponentVNode)(2, _components.Button, {
            "color": "bad",
            "icon": "trash",
            "onClick": function () {
              function onClick() {
                return act("deletechromosome", {
                  ref: c.ref
                });
              }

              return onClick;
            }()
          })], 4),
          children: [c.desc, (0, _inferno.createComponentVNode)(2, _components.Box, {
            "mt": 0.5,
            children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
              "inline": true,
              "color": "grey",
              children: "Stored Copies:"
            }), " ", c.count]
          })]
        }, c.ref);
      })
    }) : "There are no chromosomes in storage."
  }), (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "DNA Samples",
    children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: samples.map(function (s) {
        return (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": s.name,
          "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
            "icon": "save",
            "onClick": function () {
              function onClick() {
                act("setrecord", {
                  ref: s.ref
                });
                setMenu("record");
              }

              return onClick;
            }(),
            children: "View Record"
          }),
          children: (0, _inferno.createVNode)(1, "tt", null, s.uid, 0)
        }, s.ref);
      })
    })
  })], 0);
};

exports.StorageTab = StorageTab;

var RecordTab = function RecordTab(props, context) {
  var _useBackend2 = (0, _backend.useBackend)(context),
      data = _useBackend2.data;

  var record = data.record;

  if (!record) {
    return;
  }

  var name = record.name,
      uid = record.uid,
      genes = record.genes;
  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": name,
    children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Genetic Signature",
        children: (0, _inferno.createVNode)(1, "tt", null, uid, 0)
      })
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Section, {
    children: (0, _inferno.createComponentVNode)(2, _BioEffect.GeneList, {
      "genes": genes,
      "noGenes": "No genes found in sample.",
      "isSample": true
    })
  })], 4);
};

exports.RecordTab = RecordTab;

/***/ }),

/***/ "./packages/tgui/interfaces/GlassRecycler.js":
/*!***************************************************!*\
  !*** ./packages/tgui/interfaces/GlassRecycler.js ***!
  \***************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.GlassRecycler = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var _stringUtils = __webpack_require__(/*! ./common/stringUtils */ "./packages/tgui/interfaces/common/stringUtils.js");

var GlassRecyclerProductEntry = function GlassRecyclerProductEntry(props, context) {
  var _props$product = props.product,
      name = _props$product.name,
      cost = _props$product.cost,
      img = _props$product.img,
      disabled = props.disabled,
      onClick = props.onClick;
  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Flex, {
    "direction": "row",
    "align": "center",
    children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      children: (0, _inferno.createVNode)(1, "img", null, null, 1, {
        "src": "data:image/png;base64," + img,
        "style": {
          'vertical-align': 'middle',
          'horizontal-align': 'middle'
        }
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "grow": 1,
      children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
        "bold": true,
        children: (0, _stringUtils.capitalize)(name)
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        children: "Cost: " + cost + " " + (0, _stringUtils.pluralize)('Unit', cost)
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "onClick": onClick,
        "disabled": disabled,
        children: "Create"
      })
    })]
  }), (0, _inferno.createComponentVNode)(2, _components.Divider)], 4);
};

var GlassRecycler = function GlassRecycler(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var glassAmt = data.glassAmt,
      products = data.products;

  var _useLocalState = (0, _backend.useLocalState)(context, 'filter-available', false),
      filterAvailable = _useLocalState[0],
      setFilterAvailable = _useLocalState[1];

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "title": "Glass Recycler",
    "width": 300,
    "height": 400,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
        "vertical": true,
        "fill": true,
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
              "direction": "row",
              "align": "center",
              children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                "grow": 1,
                children: (0, _inferno.createComponentVNode)(2, _components.Box, {
                  children: "Glass: " + glassAmt + " " + (0, _stringUtils.pluralize)('Unit', glassAmt)
                })
              }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
                  "checked": filterAvailable,
                  "onClick": function () {
                    function onClick() {
                      return setFilterAvailable(!filterAvailable);
                    }

                    return onClick;
                  }(),
                  children: "Filter Available"
                })
              })]
            })
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          "grow": 1,
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "fill": true,
            "scrollable": true,
            "title": "Products",
            children: products.map(function (product) {
              var type = product.type,
                  cost = product.cost;

              if (filterAvailable && glassAmt < cost) {
                return;
              }

              return (0, _inferno.createComponentVNode)(2, GlassRecyclerProductEntry, {
                "product": product,
                "disabled": glassAmt < cost,
                "onClick": function () {
                  function onClick() {
                    return act('create', {
                      type: type
                    });
                  }

                  return onClick;
                }()
              }, type);
            })
          })
        })]
      })
    })
  });
};

exports.GlassRecycler = GlassRecycler;

/***/ }),

/***/ "./packages/tgui/interfaces/ListInput.js":
/*!***********************************************!*\
  !*** ./packages/tgui/interfaces/ListInput.js ***!
  \***********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Loader = exports.ListInput = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _keycodes = __webpack_require__(/*! common/keycodes */ "./packages/common/keycodes.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

/**
 * @file
 * @copyright 2020 watermelon914 (https://github.com/watermelon914)
 * @license MIT
 */
var nextScrollTime = 0;
var nextTick = typeof Promise !== 'undefined' ? Promise.resolve().then.bind(Promise.resolve()) : function (a) {
  window.setTimeout(a, 0);
};

var ListInput = function ListInput(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var title = data.title,
      message = data.message,
      buttons = data.buttons,
      timeout = data.timeout; // Search

  var _useLocalState = (0, _backend.useLocalState)(context, 'search_bar', false),
      showSearchBar = _useLocalState[0],
      setShowSearchBar = _useLocalState[1];

  var _useLocalState2 = (0, _backend.useLocalState)(context, 'displayed_array', buttons),
      displayedArray = _useLocalState2[0],
      setDisplayedArray = _useLocalState2[1]; // KeyPress


  var _useLocalState3 = (0, _backend.useLocalState)(context, 'search_array', []),
      searchArray = _useLocalState3[0],
      setSearchArray = _useLocalState3[1];

  var _useLocalState4 = (0, _backend.useLocalState)(context, 'search_index', 0),
      searchIndex = _useLocalState4[0],
      setSearchIndex = _useLocalState4[1];

  var _useLocalState5 = (0, _backend.useLocalState)(context, 'last_char_code', null),
      lastCharCode = _useLocalState5[0],
      setLastCharCode = _useLocalState5[1]; // Selected Button


  var _useLocalState6 = (0, _backend.useLocalState)(context, 'selected_button', buttons[0]),
      selectedButton = _useLocalState6[0],
      setSelectedButton = _useLocalState6[1];

  var handleKeyDown = function handleKeyDown(e) {
    var searchBarInput = showSearchBar ? document.getElementById("search_bar").getElementsByTagName('input')[0] : null;
    var searchBarFocused = document.activeElement === searchBarInput;

    if (!searchBarFocused) {
      e.preventDefault();
    }

    if (!searchBarFocused && e.keyCode === _keycodes.KEY_END) {
      if (!displayedArray.length) {
        return;
      }

      var button = displayedArray[buttons.length - 1];
      setSelectedButton(button);
      setLastCharCode(null);
      document.getElementById(button).focus();
    } else if (!searchBarFocused && e.keyCode === _keycodes.KEY_HOME) {
      if (!displayedArray.length) {
        return;
      }

      var _button = displayedArray[0];
      setSelectedButton(_button);
      setLastCharCode(null);
      document.getElementById(_button).focus();
    } else if (e.keyCode === _keycodes.KEY_ESCAPE) {
      act("cancel");
    } else if (e.keyCode === _keycodes.KEY_ENTER) {
      act("choose", {
        choice: selectedButton
      });
    } else if (e.keyCode === _keycodes.KEY_TAB) {
      var selectedButtonElement = document.getElementById(selectedButton);

      if (searchBarFocused && selectedButtonElement) {
        selectedButtonElement.focus();
      } else if (searchBarInput && !searchBarFocused) {
        searchBarInput.focus();
      }

      e.preventDefault();
    } else if (e.keyCode === _keycodes.KEY_UP || e.keyCode === _keycodes.KEY_DOWN || e.keyCode === _keycodes.KEY_PAGEDOWN || e.keyCode === _keycodes.KEY_PAGEUP) {
      if (nextScrollTime > performance.now() || !displayedArray.length) {
        return;
      }

      nextScrollTime = performance.now() + 50;
      var direction;

      switch (e.keyCode) {
        case _keycodes.KEY_UP:
          direction = -1;
          break;

        case _keycodes.KEY_DOWN:
          direction = 1;
          break;

        case _keycodes.KEY_PAGEUP:
          direction = -10;
          break;

        case _keycodes.KEY_PAGEDOWN:
          direction = 10;
          break;
      }

      var index = 0;

      for (index; index < displayedArray.length; index++) {
        if (displayedArray[index] === selectedButton) break;
      }

      index += direction;
      if (index < 0 && Math.abs(direction) === 1) index = displayedArray.length - 1;else if (index >= displayedArray.length && Math.abs(direction) === 1) index = 0;else if (index < 0) index = 0;else if (index >= displayedArray.length) index = displayedArray.length - 1;
      var _button2 = displayedArray[index];
      setSelectedButton(_button2);
      setLastCharCode(null);
      document.getElementById(_button2).focus();
    }

    var charCode = String.fromCharCode(e.keyCode).toLowerCase();
    if (!charCode) return;

    if (charCode === "f" && e.ctrlKey) {
      if (!showSearchBar) {
        nextTick(function () {
          return document.getElementById("search_bar").getElementsByTagName('input')[0].focus();
        });
      } else {
        var _document$getElementB;

        (_document$getElementB = document.getElementById(selectedButton)) == null ? void 0 : _document$getElementB.focus();
      }

      setShowSearchBar(!showSearchBar);
      e.preventDefault();
      return;
    }

    if (searchBarFocused) {
      return;
    }

    if (nextScrollTime > performance.now() || !displayedArray.length) {
      return;
    }

    nextScrollTime = performance.now() + 50;
    var foundValue;

    if (charCode === lastCharCode && searchArray.length > 0) {
      var nextIndex = searchIndex + 1;

      if (nextIndex < searchArray.length) {
        foundValue = searchArray[nextIndex];
        setSearchIndex(nextIndex);
      } else {
        foundValue = searchArray[0];
        setSearchIndex(0);
      }
    } else {
      var resultArray = displayedArray.filter(function (value) {
        return value.substring(0, 1).toLowerCase() === charCode;
      });

      if (resultArray.length > 0) {
        setSearchArray(resultArray);
        setSearchIndex(0);
        foundValue = resultArray[0];
      }
    }

    if (foundValue) {
      setLastCharCode(charCode);
      setSelectedButton(foundValue);
      document.getElementById(foundValue).focus();
    }
  };

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "title": title,
    "width": 325,
    "height": 325,
    children: [timeout !== undefined && (0, _inferno.createComponentVNode)(2, Loader, {
      "value": timeout
    }), (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      "onkeydown": handleKeyDown,
      children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
        "fill": true,
        "vertical": true,
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          "grow": true,
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "fill": true,
            "scrollable": true,
            "className": "ListInput__Section",
            "title": message,
            "tabIndex": 0,
            "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
              "compact": true,
              "icon": "search",
              "color": "transparent",
              "selected": showSearchBar,
              "tooltip": "Search Bar",
              "tooltipPosition": "left",
              "onClick": function () {
                function onClick() {
                  if (!showSearchBar) {
                    nextTick(function () {
                      return document.getElementById("search_bar").getElementsByTagName('input')[0].focus();
                    });
                  } else {
                    var _document$getElementB2;

                    (_document$getElementB2 = document.getElementById(selectedButton)) == null ? void 0 : _document$getElementB2.focus();
                  }

                  setShowSearchBar(!showSearchBar);
                  setDisplayedArray(buttons);
                }

                return onClick;
              }()
            }),
            children: displayedArray.map(function (button) {
              return (0, _inferno.createComponentVNode)(2, _components.Button, {
                "fluid": true,
                "color": "transparent",
                "id": button,
                "selected": selectedButton === button,
                "onClick": function () {
                  function onClick() {
                    if (selectedButton === button) {
                      act('choose', {
                        choice: button
                      });
                    } else {
                      setSelectedButton(button);
                    }

                    setLastCharCode(null);
                  }

                  return onClick;
                }(),
                children: button
              }, button, {
                "onComponentDidMount": function () {
                  function onComponentDidMount(node) {
                    if (selectedButton === button) {
                      node.focus();
                    }
                  }

                  return onComponentDidMount;
                }()
              });
            })
          })
        }), showSearchBar && (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Input, {
            "fluid": true,
            "id": "search_bar",
            "onInput": function () {
              function onInput(e, value) {
                var newDisplayed = buttons.filter(function (val) {
                  return val.toLowerCase().search(value.toLowerCase()) !== -1;
                });
                setDisplayedArray(newDisplayed);

                if (!newDisplayed.includes(selectedButton) && newDisplayed.length > 0) {
                  setSelectedButton(newDisplayed[0]);
                }
              }

              return onInput;
            }()
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
            "textAlign": "center",
            children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
              "grow": true,
              "basis": 0,
              children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                "fluid": true,
                "color": "good",
                "lineHeight": 2,
                "content": "Confirm",
                "disabled": selectedButton === null,
                "onClick": function () {
                  function onClick() {
                    return act("choose", {
                      choice: selectedButton
                    });
                  }

                  return onClick;
                }()
              })
            }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
              "grow": true,
              "basis": 0,
              children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                "fluid": true,
                "color": "bad",
                "lineHeight": 2,
                "content": "Cancel",
                "onClick": function () {
                  function onClick() {
                    return act("cancel");
                  }

                  return onClick;
                }()
              })
            })]
          })
        })]
      })
    })]
  });
};

exports.ListInput = ListInput;

var Loader = function Loader(props) {
  var value = props.value;
  return (0, _inferno.createVNode)(1, "div", "ListInput__Loader", (0, _inferno.createComponentVNode)(2, _components.Box, {
    "className": "ListInput__LoaderProgress",
    "style": {
      width: (0, _math.clamp01)(value) * 100 + '%'
    }
  }), 2);
};

exports.Loader = Loader;

/***/ }),

/***/ "./packages/tgui/interfaces/LongRangeTeleporter.js":
/*!*********************************************************!*\
  !*** ./packages/tgui/interfaces/LongRangeTeleporter.js ***!
  \*********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.LongRangeTeleporter = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

/**
 * Copyright (c) 2021 @Azrun
 * SPDX-License-Identifier: MIT
 */
var LongRangeTeleporter = function LongRangeTeleporter(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var destinations = data.destinations,
      receive_allowed = data.receive_allowed,
      send_allowed = data.send_allowed,
      syndicate = data.syndicate;
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "theme": syndicate ? 'syndicate' : 'ntos',
    "width": 390,
    "height": 380,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: (0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Destinations",
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: destinations.length ? destinations.map(function (d) {
            return (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
              "label": d["destination"],
              children: [send_allowed && (0, _inferno.createComponentVNode)(2, _components.Button, {
                "icon": "sign-out-alt",
                "onClick": function () {
                  function onClick() {
                    return act("send", {
                      target: d["ref"],
                      name: d["destination"]
                    });
                  }

                  return onClick;
                }(),
                children: "Send"
              }), receive_allowed && (0, _inferno.createComponentVNode)(2, _components.Button, {
                "icon": "sign-in-alt",
                "onClick": function () {
                  function onClick() {
                    return act("receive", {
                      target: d["ref"],
                      name: d["destination"]
                    });
                  }

                  return onClick;
                }(),
                children: "Receive"
              })]
            }, d["destination"]);
          }) : (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            children: "No destinations are currently available."
          })
        })
      })
    })
  });
};

exports.LongRangeTeleporter = LongRangeTeleporter;

/***/ }),

/***/ "./packages/tgui/interfaces/MixingDesk.js":
/*!************************************************!*\
  !*** ./packages/tgui/interfaces/MixingDesk.js ***!
  \************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.MixingDesk = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var _format = __webpack_require__(/*! ../format.js */ "./packages/tgui/format.js");

/**
 * @file
 * @copyright 2021
 * @author pali (https://github.com/pali6)
 * @license MIT
 */
var MixingDesk = function MixingDesk(_props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var voices = data.voices,
      selected_voice = data.selected_voice,
      say_popup = data.say_popup;

  var _useSharedState = (0, _backend.useSharedState)(context, 'message', null),
      message = _useSharedState[0],
      setMessage = _useSharedState[1];

  var sayPopup = function sayPopup() {
    return (0, _inferno.createComponentVNode)(2, _components.Modal, {
      children: ["Say as ", selected_voice > 0 && selected_voice <= voices.length ? voices[selected_voice - 1].name : 'yourself', ":", (0, _inferno.createVNode)(1, "br"), (0, _inferno.createComponentVNode)(2, _components.Box, {
        "pt": "5px",
        "pr": "10px",
        "textAlign": "center",
        children: (0, _inferno.createComponentVNode)(2, _components.Input, {
          "autoFocus": true,
          "selfClear": true,
          "width": 20,
          "value": message,
          "onEnter": function () {
            function onEnter(_, msg) {
              window.focus();
              act('say', {
                message: msg
              });
              setMessage('');
            }

            return onEnter;
          }(),
          "onChange": function () {
            function onChange(_, msg) {
              return setMessage(msg);
            }

            return onChange;
          }()
        })
      }), (0, _inferno.createVNode)(1, "br"), (0, _inferno.createComponentVNode)(2, _components.Box, {
        "textAlign": "center",
        children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              act('say', {
                message: message
              });
              setMessage('');
            }

            return onClick;
          }(),
          children: "Say"
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "onClick": function () {
            function onClick() {
              act('cancel_say');
              setMessage('');
            }

            return onClick;
          }(),
          children: "Cancel"
        })]
      })]
    });
  };

  var onKeyDown = function onKeyDown(e) {
    var key = String.fromCharCode(e.keyCode);
    var caught_key = true;

    if (key === 'T') {
      act('say_popup');
    } else if (e.keyCode === 27 && say_popup) {
      // escape
      act('cancel_say');
      setMessage('');
    } else if (!say_popup) {
      var num = Number(key);

      if (String(num) === key) {
        // apparently in js this is the correct way to check if it's a number
        act('switch_voice', {
          id: num
        });
      } else {
        caught_key = false;
      }
    } else {
      caught_key = false;
    }

    if (caught_key) {
      e.stopPropagation();
    }
  };

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "height": 375,
    "width": 370,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      "onkeydown": onKeyDown,
      children: [!!say_popup && sayPopup(), (0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Voice Synthesizer",
        children: [(0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [voices.map(function (entry, index) {
            return (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
              "label": index + 1 + " " + (0, _format.truncate)(entry['name'], 18) + (entry['accent'] ? " [" + entry['accent'] + "]" : ''),
              "labelColor": index + 1 === selected_voice ? "red" : "label",
              children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
                "icon": "trash-alt",
                "onClick": function () {
                  function onClick() {
                    return act('remove_voice', {
                      id: index + 1
                    });
                  }

                  return onClick;
                }()
              }), (0, _inferno.createComponentVNode)(2, _components.Button, {
                "icon": "bullhorn",
                "onClick": function () {
                  function onClick() {
                    return act("say_popup", {
                      id: index + 1
                    });
                  }

                  return onClick;
                }()
              })]
            }, entry['name']);
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
              "align": "center",
              children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                  "icon": "plus",
                  "onClick": function () {
                    function onClick() {
                      return act('add_voice');
                    }

                    return onClick;
                  }(),
                  "disabled": voices.length >= 9
                })
              }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                children: (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
                  "position": "right",
                  "content": "Press T to talk and 1-9 keys to switch voices. Press 0 to reset to your normal voice.",
                  children: (0, _inferno.createComponentVNode)(2, _components.Icon, {
                    "name": "question-circle"
                  })
                })
              })]
            })
          })]
        })]
      })]
    })
  });
};

exports.MixingDesk = MixingDesk;

/***/ }),

/***/ "./packages/tgui/interfaces/PaperSheet.js":
/*!************************************************!*\
  !*** ./packages/tgui/interfaces/PaperSheet.js ***!
  \************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.PaperSheet = exports.PaperSheetView = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _assets = __webpack_require__(/*! ../assets */ "./packages/tgui/assets.js");

var _marked = _interopRequireDefault(__webpack_require__(/*! marked */ "./.yarn/cache/marked-npm-2.0.3-e188d0bdaa-1894006520.zip/node_modules/marked/lib/marked.js"));

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _sanitize = __webpack_require__(/*! ../sanitize */ "./packages/tgui/sanitize.js");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; _setPrototypeOf(subClass, superClass); }

function _createForOfIteratorHelperLoose(o, allowArrayLike) { var it = typeof Symbol !== "undefined" && o[Symbol.iterator] || o["@@iterator"]; if (it) return (it = it.call(o)).next.bind(it); if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; return function () { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function _wrapRegExp(re, groups) { _wrapRegExp = function _wrapRegExp(re, groups) { return new BabelRegExp(re, undefined, groups); }; var _RegExp = _wrapNativeSuper(RegExp); var _super = RegExp.prototype; var _groups = new WeakMap(); function BabelRegExp(re, flags, groups) { var _this = _RegExp.call(this, re, flags); _groups.set(_this, groups || _groups.get(re)); return _this; } _inherits(BabelRegExp, _RegExp); BabelRegExp.prototype.exec = function (str) { var result = _super.exec.call(this, str); if (result) result.groups = buildGroups(result, this); return result; }; BabelRegExp.prototype[Symbol.replace] = function (str, substitution) { if (typeof substitution === "string") { var groups = _groups.get(this); return _super[Symbol.replace].call(this, str, substitution.replace(/\$<([^>]+)>/g, function (_, name) { return "$" + groups[name]; })); } else if (typeof substitution === "function") { var _this = this; return _super[Symbol.replace].call(this, str, function () { var args = []; args.push.apply(args, arguments); if (typeof args[args.length - 1] !== "object") { args.push(buildGroups(args, _this)); } return substitution.apply(this, args); }); } else { return _super[Symbol.replace].call(this, str, substitution); } }; function buildGroups(result, re) { var g = _groups.get(re); return Object.keys(g).reduce(function (groups, name) { groups[name] = result[g[name]]; return groups; }, Object.create(null)); } return _wrapRegExp.apply(this, arguments); }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function"); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, writable: true, configurable: true } }); if (superClass) _setPrototypeOf(subClass, superClass); }

function _possibleConstructorReturn(self, call) { if (call && (typeof call === "object" || typeof call === "function")) { return call; } return _assertThisInitialized(self); }

function _assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }

function _wrapNativeSuper(Class) { var _cache = typeof Map === "function" ? new Map() : undefined; _wrapNativeSuper = function () { function _wrapNativeSuper(Class) { if (Class === null || !_isNativeFunction(Class)) return Class; if (typeof Class !== "function") { throw new TypeError("Super expression must either be null or a function"); } if (typeof _cache !== "undefined") { if (_cache.has(Class)) return _cache.get(Class); _cache.set(Class, Wrapper); } function Wrapper() { return _construct(Class, arguments, _getPrototypeOf(this).constructor); } Wrapper.prototype = Object.create(Class.prototype, { constructor: { value: Wrapper, enumerable: false, writable: true, configurable: true } }); return _setPrototypeOf(Wrapper, Class); } return _wrapNativeSuper; }(); return _wrapNativeSuper(Class); }

function _construct(Parent, args, Class) { if (_isNativeReflectConstruct()) { _construct = Reflect.construct; } else { _construct = function () { function _construct(Parent, args, Class) { var a = [null]; a.push.apply(a, args); var Constructor = Function.bind.apply(Parent, a); var instance = new Constructor(); if (Class) _setPrototypeOf(instance, Class.prototype); return instance; } return _construct; }(); } return _construct.apply(null, arguments); }

function _isNativeReflectConstruct() { if (typeof Reflect === "undefined" || !Reflect.construct) return false; if (Reflect.construct.sham) return false; if (typeof Proxy === "function") return true; try { Boolean.prototype.valueOf.call(Reflect.construct(Boolean, [], function () {})); return true; } catch (e) { return false; } }

function _isNativeFunction(fn) { return Function.toString.call(fn).indexOf("[native code]") !== -1; }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function () { function _setPrototypeOf(o, p) { o.__proto__ = p; return o; } return _setPrototypeOf; }(); return _setPrototypeOf(o, p); }

function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function () { function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); } return _getPrototypeOf; }(); return _getPrototypeOf(o); }

var MAX_PAPER_LENGTH = 5000; // Question, should we send this with ui_data?

var WINDOW_TITLEBAR_HEIGHT = 30; // Hacky, yes, works?...yes

var textWidth = function textWidth(text, font, fontsize) {
  // default font height is 12 in tgui
  font = fontsize + "x " + font;
  var c = document.createElement('canvas');
  var ctx = c.getContext("2d");
  ctx.font = font;
  return ctx.measureText(text).width;
};

var setFontinText = function setFontinText(text, font, color, bold) {
  if (bold === void 0) {
    bold = false;
  }

  return "<span style=\"" + "color:" + color + ";" + "font-family:" + font + ";" + (bold ? "font-weight: bold;" : "") + "\">" + text + "</span>";
};

var createIDHeader = function createIDHeader(index) {
  return "paperfield_" + index;
}; // To make a field you do a [_______] or however long the field is
// we will then output a TEXT input for it that hopefully covers
// the exact amount of spaces


var fieldRegex = /\[(_+)\]/g; // TODO: regex needs documentation

var fieldTagRegex = /*#__PURE__*/_wrapRegExp(/\[<input[\t-\r \xA0\u1680\u2000-\u200A\u2028\u2029\u202F\u205F\u3000\uFEFF]+(?!disabled)(.*?)[\t-\r \xA0\u1680\u2000-\u200A\u2028\u2029\u202F\u205F\u3000\uFEFF]+id="(paperfield_[0-9]+)"(.*?)\/>\]/gm, {
  id: 2
});

var signRegex = /%s(?:ign)?(?=\\s|$)?/igm;

var createInputField = function createInputField(length, width, font, fontsize, color, id) {
  return "[<input " + "type=\"text\" " + "style=\"" + "font:'" + fontsize + "x " + font + "';" + "color:'" + color + "';" + "min-width:" + width + ";" + "max-width:" + width + ";" + "\" " + "id=\"" + id + "\" " + "maxlength=" + length + " " + "size=" + length + " " + "/>]";
};

var createFields = function createFields(txt, font, fontsize, color, counter) {
  var retText = txt.replace(fieldRegex, function (match, p1, offset, string) {
    var width = textWidth(match, font, fontsize) + "px";
    return createInputField(p1.length, width, font, fontsize, color, createIDHeader(counter++));
  });
  return {
    counter: counter,
    text: retText
  };
};

var signDocument = function signDocument(txt, color, user) {
  return txt.replace(signRegex, function () {
    return setFontinText(user, "Times New Roman", color, true);
  });
};

var runMarkedDefault = function runMarkedDefault(value) {
  // Override function, any links and images should
  // kill any other marked tokens we don't want here
  var walkTokens = function walkTokens(token) {
    switch (token.type) {
      case 'url':
      case 'autolink':
      case 'reflink':
      case 'link':
      case 'image':
        token.type = 'text'; // Once asset system is up change to some default image
        // or rewrite for icon images

        token.href = "";
        break;
    }
  };

  return (0, _marked["default"])(value, {
    breaks: true,
    smartypants: true,
    smartLists: true,
    walkTokens: walkTokens,
    // Once assets are fixed might need to change this for them
    baseUrl: 'thisshouldbreakhttp'
  });
};
/*
** This gets the field, and finds the dom object and sees if
** the user has typed something in.  If so, it replaces,
** the dom object, in txt with the value, spaces so it
** fits the [] format and saves the value into a object
** There may be ways to optimize this in javascript but
** doing this in byond is nightmarish.
**
** It returns any values that were saved and a corrected
** html code or null if nothing was updated
*/


var checkAllFields = function checkAllFields(txt, font, color, userName, bold) {
  if (bold === void 0) {
    bold = false;
  }

  var matches;
  var values = {};
  var replace = []; // I know its tempting to wrap ALL this in a .replace
  // HOWEVER the user might not of entered anything
  // if thats the case we are rebuilding the entire string
  // for nothing, if nothing is entered, txt is just returned

  while ((matches = fieldTagRegex.exec(txt)) !== null) {
    var fullMatch = matches[0];
    var id = matches.groups.id;

    if (id) {
      var dom = document.getElementById(id); // make sure we got data, and kill any html that might
      // be in it

      var domText = dom && dom.value ? dom.value : "";

      if (domText.length === 0) {
        continue;
      }

      var sanitizedText = (0, _sanitize.sanitizeText)(dom.value.trim(), []);

      if (sanitizedText.length === 0) {
        continue;
      } // this is easier than doing a bunch of text manipulations


      var target = dom.cloneNode(true); // in case they sign in a field

      if (sanitizedText.match(signRegex)) {
        target.style.fontFamily = "Times New Roman";
        bold = true;
        target.defaultValue = userName;
      } else {
        target.style.fontFamily = font;
        target.defaultValue = sanitizedText;
      }

      if (bold) {
        target.style.fontWeight = "bold";
      }

      target.style.color = color;
      target.disabled = true;
      var wrap = document.createElement('div');
      wrap.appendChild(target);
      values[id] = sanitizedText; // save the data

      replace.push({
        value: "[" + wrap.innerHTML + "]",
        rawText: fullMatch
      });
    }
  }

  if (replace.length > 0) {
    for (var _iterator = _createForOfIteratorHelperLoose(replace), _step; !(_step = _iterator()).done;) {
      var o = _step.value;
      txt = txt.replace(o.rawText, o.value);
    }
  }

  return {
    text: txt,
    fields: values
  };
};

var pauseEvent = function pauseEvent(e) {
  if (e.stopPropagation) {
    e.stopPropagation();
  }

  if (e.preventDefault) {
    e.preventDefault();
  }

  e.cancelBubble = true;
  e.returnValue = false;
  return false;
};

var Stamp = function Stamp(props, context) {
  var image = props.image,
      opacity = props.opacity,
      activeStamp = props.activeStamp;
  var stampTransform = {
    'left': image.x + 'px',
    'top': image.y + 'px',
    'transform': 'rotate(' + image.rotate + 'deg)',
    'opacity': opacity || 1.0
  };
  return image.sprite.match("stamp-.*") ? (0, _inferno.createVNode)(1, "img", "paper__stamp", null, 1, {
    "id": activeStamp && "stamp",
    "style": stampTransform,
    "src": (0, _assets.resolveAsset)(image.sprite)
  }) : (0, _inferno.createComponentVNode)(2, _components.Box, {
    "id": activeStamp && "stamp",
    "style": stampTransform,
    "className": "paper__stamp-text",
    children: image.sprite
  });
};

var setInputReadonly = function setInputReadonly(text, readonly) {
  return readonly ? text.replace(/<input\s[^d]/g, '<input disabled ') : text.replace(/<input\sdisabled\s/g, '<input ');
}; // got to make this a full component if we
// want to control updates


var PaperSheetView = function PaperSheetView(props, context) {
  var _props$value = props.value,
      value = _props$value === void 0 ? "" : _props$value,
      _props$stamps = props.stamps,
      stamps = _props$stamps === void 0 ? [] : _props$stamps,
      backgroundColor = props.backgroundColor,
      readOnly = props.readOnly;
  var stampList = stamps || [];
  var textHtml = {
    __html: '<span class="paper-text">' + setInputReadonly(value, readOnly) + '</span>'
  };
  return (0, _inferno.createComponentVNode)(2, _components.Box, {
    "className": "paper__page",
    "position": "relative",
    "backgroundColor": backgroundColor,
    "width": "100%",
    "height": "100%",
    children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
      "color": "black",
      "backgroundColor": backgroundColor,
      "fillPositionedParent": true,
      "width": "100%",
      "height": "100%",
      "dangerouslySetInnerHTML": textHtml,
      "p": "10px"
    }), stampList.map(function (o, i) {
      return (0, _inferno.createComponentVNode)(2, Stamp, {
        "image": {
          sprite: o[0],
          x: o[1],
          y: o[2],
          rotate: o[3]
        }
      }, o[0] + i);
    })]
  });
}; // again, need the states for dragging and such


exports.PaperSheetView = PaperSheetView;

var PaperSheetStamper = /*#__PURE__*/function (_Component) {
  _inheritsLoose(PaperSheetStamper, _Component);

  function PaperSheetStamper(props, context) {
    var _this2;

    _this2 = _Component.call(this, props, context) || this;
    _this2.state = {
      x: 0,
      y: 0,
      rotate: 0
    };
    _this2.style = null;

    _this2.handleMouseMove = function (e) {
      var pos = _this2.findStampPosition(e);

      if (!pos) {
        return;
      } // center offset of stamp & rotate


      pauseEvent(e);

      _this2.setState({
        x: pos[0],
        y: pos[1],
        rotate: pos[2]
      });
    };

    _this2.handleMouseClick = function (e) {
      if (e.pageY <= WINDOW_TITLEBAR_HEIGHT) {
        return;
      }

      var _useBackend = (0, _backend.useBackend)(_this2.context),
          act = _useBackend.act;

      var stampObj = {
        x: _this2.state.x,
        y: _this2.state.y,
        r: _this2.state.rotate
      };
      act("stamp", stampObj);
    };

    return _this2;
  }

  var _proto = PaperSheetStamper.prototype;

  _proto.findStampPosition = function () {
    function findStampPosition(e) {
      var rotating;
      var windowRef = document.querySelector('.Layout__content');

      if (e.shiftKey) {
        rotating = true;
      }

      var stamp = document.getElementById("stamp");

      if (stamp) {
        var stampHeight = stamp.clientHeight;
        var stampWidth = stamp.clientWidth;
        var currentHeight = rotating ? this.state.y : e.pageY + windowRef.scrollTop - stampHeight;
        var currentWidth = rotating ? this.state.x : e.pageX - stampWidth / 2;
        var widthMin = 0;
        var heightMin = 0;
        var widthMax = windowRef.clientWidth - stampWidth;
        var heightMax = windowRef.clientHeight + windowRef.scrollTop - stampHeight;
        var radians = Math.atan2(e.pageX - currentWidth, e.pageY - currentHeight);
        var rotate = rotating ? radians * (180 / Math.PI) * -1 : this.state.rotate;
        return [(0, _math.clamp)(currentWidth, widthMin, widthMax), (0, _math.clamp)(currentHeight, heightMin, heightMax), rotate];
      }
    }

    return findStampPosition;
  }();

  _proto.componentDidMount = function () {
    function componentDidMount() {
      document.addEventListener("mousemove", this.handleMouseMove);
      document.addEventListener("click", this.handleMouseClick);
    }

    return componentDidMount;
  }();

  _proto.componentWillUnmount = function () {
    function componentWillUnmount() {
      document.removeEventListener("mousemove", this.handleMouseMove);
      document.removeEventListener("click", this.handleMouseClick);
    }

    return componentWillUnmount;
  }();

  _proto.render = function () {
    function render() {
      var _this$props = this.props,
          value = _this$props.value,
          stampClass = _this$props.stampClass,
          stamps = _this$props.stamps;
      var stampList = stamps || [];
      var currentPos = {
        sprite: stampClass,
        x: this.state.x,
        y: this.state.y,
        rotate: this.state.rotate
      };
      return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, PaperSheetView, {
        "readOnly": true,
        "value": value,
        "stamps": stampList
      }), (0, _inferno.createComponentVNode)(2, Stamp, {
        "activeStamp": true,
        "opacity": 0.5,
        "image": currentPos
      })], 4);
    }

    return render;
  }();

  return PaperSheetStamper;
}(_inferno.Component); // ugh.  So have to turn this into a full
// component too if I want to keep updates
// low and keep the weird flashing down


var PaperSheetEdit = /*#__PURE__*/function (_Component2) {
  _inheritsLoose(PaperSheetEdit, _Component2);

  function PaperSheetEdit(props, context) {
    var _this3;

    _this3 = _Component2.call(this, props, context) || this;
    _this3.state = {
      previewSelected: "Preview",
      oldText: props.value || "",
      textAreaText: "",
      combinedText: props.value || "",
      showingHelpTip: false
    };
    return _this3;
  } // This is the main rendering part, this creates the html from marked text
  // as well as the form fields


  var _proto2 = PaperSheetEdit.prototype;

  _proto2.createPreview = function () {
    function createPreview(value, doFields) {
      if (doFields === void 0) {
        doFields = false;
      }

      var _useBackend2 = (0, _backend.useBackend)(this.context),
          data = _useBackend2.data;

      var text = data.text,
          penColor = data.penColor,
          penFont = data.penFont,
          isCrayon = data.isCrayon,
          fieldCounter = data.fieldCounter,
          editUsr = data.editUsr;
      var out = {
        text: text
      }; // check if we are adding to paper, if not
      // we still have to check if someone entered something
      // into the fields

      value = value.trim();

      if (value.length > 0) {
        // Second, we sanitize the text of html
        var sanitizedText = (0, _sanitize.sanitizeText)(value);
        var signedText = signDocument(sanitizedText, penColor, editUsr); // Third we replace the [__] with fields as markedjs fucks them up

        var fieldedText = createFields(signedText, penFont, 12, penColor, fieldCounter); // Fourth, parse the text using markup

        var formattedText = runMarkedDefault(fieldedText.text); // Fifth, we wrap the created text in the pin color, and font.
        // crayon is bold (<b> tags), maybe make fountain pin italic?

        var fontedText = setFontinText(formattedText, penFont, penColor, isCrayon);
        out.text += fontedText;
        out.fieldCounter = fieldedText.counter;
      }

      if (doFields) {
        // finally we check all the form fields to see
        // if any data was entered by the user and
        // if it was return the data and modify the text
        var finalProcessing = checkAllFields(out.text, penFont, penColor, editUsr, isCrayon);
        out.text = finalProcessing.text;
        out.formFields = finalProcessing.fields;
      }

      return out;
    }

    return createPreview;
  }();

  _proto2.onInputHandler = function () {
    function onInputHandler(e, value) {
      var _this4 = this;

      if (value !== this.state.textAreaText) {
        var combinedLength = this.state.oldText.length + this.state.textAreaText.length;

        if (combinedLength > MAX_PAPER_LENGTH) {
          if (combinedLength - MAX_PAPER_LENGTH >= value.length) {
            // Basically we cannot add any more text to the paper
            value = '';
          } else {
            value = value.substr(0, value.length - (combinedLength - MAX_PAPER_LENGTH));
          } // we check again to save an update


          if (value === this.state.textAreaText) {
            // Do nothing
            return;
          }
        }

        this.setState(function () {
          return {
            textAreaText: value,
            combinedText: _this4.createPreview(value)
          };
        });
      }
    }

    return onInputHandler;
  }() // the final update send to byond, final upkeep
  ;

  _proto2.finalUpdate = function () {
    function finalUpdate(newText) {
      var _useBackend3 = (0, _backend.useBackend)(this.context),
          act = _useBackend3.act;

      var finalProcessing = this.createPreview(newText, true);
      act('save', finalProcessing);
      this.setState(function () {
        return {
          textAreaText: "",
          previewSelected: "save",
          combinedText: finalProcessing.text
        };
      }); // byond should switch us to readonly mode from here
    }

    return finalUpdate;
  }();

  _proto2.render = function () {
    function render() {
      var _this5 = this;

      var _this$props2 = this.props,
          textColor = _this$props2.textColor,
          fontFamily = _this$props2.fontFamily,
          stamps = _this$props2.stamps,
          backgroundColor = _this$props2.backgroundColor;
      return (0, _inferno.createComponentVNode)(2, _components.Flex, {
        "direction": "column",
        "fillPositionedParent": true,
        children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Tabs, {
            "size": "100%",
            children: [(0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
              "textColor": "black",
              "backgroundColor": this.state.previewSelected === "Edit" ? "grey" : "white",
              "selected": this.state.previewSelected === "Edit",
              "onClick": function () {
                function onClick() {
                  return _this5.setState({
                    previewSelected: "Edit"
                  });
                }

                return onClick;
              }(),
              children: "Edit"
            }, "marked_edit"), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
              "textColor": "black",
              "backgroundColor": this.state.previewSelected === "Preview" ? "grey" : "white",
              "selected": this.state.previewSelected === "Preview",
              "onClick": function () {
                function onClick() {
                  return _this5.setState(function () {
                    var newState = {
                      previewSelected: "Preview",
                      textAreaText: _this5.state.textAreaText,
                      combinedText: _this5.createPreview(_this5.state.textAreaText).text
                    };
                    return newState;
                  });
                }

                return onClick;
              }(),
              children: "Preview"
            }, "marked_preview"), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
              "textColor": "black",
              "backgroundColor": this.state.previewSelected === "confirm" ? "red" : this.state.previewSelected === "save" ? "grey" : "white",
              "selected": this.state.previewSelected === "confirm" || this.state.previewSelected === "save",
              "onClick": function () {
                function onClick() {
                  if (_this5.state.previewSelected === "confirm") {
                    _this5.finalUpdate(_this5.state.textAreaText);
                  } else if (_this5.state.previewSelected === "Edit") {
                    _this5.setState(function () {
                      var newState = {
                        previewSelected: "confirm",
                        textAreaText: _this5.state.textAreaText,
                        combinedText: _this5.createPreview(_this5.state.textAreaText).text
                      };
                      return newState;
                    });
                  } else {
                    _this5.setState({
                      previewSelected: "confirm"
                    });
                  }
                }

                return onClick;
              }(),
              children: this.state.previewSelected === "confirm" ? "Confirm" : "Save"
            }, "marked_done"), (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
              "textColor": 'black',
              "backgroundColor": "white",
              "icon": "question-circle-o",
              "onmouseover": function () {
                function onmouseover() {
                  _this5.setState({
                    showingHelpTip: true
                  });
                }

                return onmouseover;
              }(),
              "onmouseout": function () {
                function onmouseout() {
                  _this5.setState({
                    showingHelpTip: false
                  });
                }

                return onmouseout;
              }(),
              children: "Help"
            }, "marked_help")]
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
          "grow": 1,
          "basis": 1,
          children: this.state.previewSelected === "Edit" && (0, _inferno.createComponentVNode)(2, _components.TextArea, {
            "value": this.state.textAreaText,
            "textColor": textColor,
            "fontFamily": fontFamily,
            "height": window.innerHeight - 60 + "px",
            "backgroundColor": backgroundColor,
            "onInput": this.onInputHandler.bind(this)
          }) || (0, _inferno.createComponentVNode)(2, PaperSheetView, {
            "value": this.state.combinedText,
            "stamps": stamps,
            "fontFamily": fontFamily,
            "textColor": textColor
          })
        }), this.state.showingHelpTip && (0, _inferno.createComponentVNode)(2, HelpToolip)]
      });
    }

    return render;
  }();

  return PaperSheetEdit;
}(_inferno.Component);

var PaperSheet = function PaperSheet(props, context) {
  var _useBackend4 = (0, _backend.useBackend)(context),
      data = _useBackend4.data;

  var editMode = data.editMode,
      text = data.text,
      _data$paperColor = data.paperColor,
      paperColor = _data$paperColor === void 0 ? "white" : _data$paperColor,
      _data$penColor = data.penColor,
      penColor = _data$penColor === void 0 ? "black" : _data$penColor,
      _data$penFont = data.penFont,
      penFont = _data$penFont === void 0 ? "Verdana" : _data$penFont,
      stamps = data.stamps,
      stampClass = data.stampClass,
      sizeX = data.sizeX,
      sizeY = data.sizeY,
      name = data.name;
  var stampList = !stamps ? [] : stamps;

  var decideMode = function decideMode(mode) {
    switch (mode) {
      case 0:
        return (0, _inferno.createComponentVNode)(2, PaperSheetView, {
          "value": text,
          "stamps": stampList,
          "readOnly": true
        });

      case 1:
        return (0, _inferno.createComponentVNode)(2, PaperSheetEdit, {
          "value": text,
          "textColor": penColor,
          "fontFamily": penFont,
          "stamps": stampList,
          "backgroundColor": paperColor
        });

      case 2:
        return (0, _inferno.createComponentVNode)(2, PaperSheetStamper, {
          "value": text,
          "stamps": stampList,
          "stampClass": stampClass
        });

      default:
        return "ERROR ERROR WE CANNOT BE HERE!!";
    }
  };

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "title": name,
    "theme": "paper",
    "width": sizeX || 400,
    "height": sizeY || 500,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      "backgroundColor": paperColor,
      "scrollable": true,
      children: (0, _inferno.createComponentVNode)(2, _components.Box, {
        "id": "page",
        "fitted": true,
        "fillPositionedParent": true,
        children: decideMode(editMode)
      })
    })
  });
};

exports.PaperSheet = PaperSheet;

var HelpToolip = function HelpToolip() {
  return (0, _inferno.createComponentVNode)(2, _components.Box, {
    "position": "absolute",
    "left": "10px",
    "top": "25px",
    "width": "300px",
    "height": "350px",
    "backgroundColor": "#E8E4C9",
    "textAlign": "center",
    children: [(0, _inferno.createVNode)(1, "h3", null, "Markdown Syntax", 16), (0, _inferno.createComponentVNode)(2, _components.Table, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Table.Row, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
            children: "Heading"
          }), "====="]
        }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: (0, _inferno.createVNode)(1, "h2", null, "Heading", 16)
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
            children: "Sub Heading"
          }), "------"]
        }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: (0, _inferno.createVNode)(1, "h4", null, "Sub Heading", 16)
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: "_Italic Text_"
        }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: (0, _inferno.createVNode)(1, "i", null, "Italic Text", 16)
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: "**Bold Text**"
        }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: (0, _inferno.createVNode)(1, "b", null, "Bold Text", 16)
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: "`Code Text`"
        }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: (0, _inferno.createVNode)(1, "code", null, "Code Text", 16)
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: "~~Strikethrough Text~~"
        }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: (0, _inferno.createVNode)(1, "s", null, "Strikethrough Text", 16)
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
            children: "Horizontal Rule"
          }), "---"]
        }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: ["Horizontal Rule", (0, _inferno.createVNode)(1, "hr")]
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: (0, _inferno.createComponentVNode)(2, _components.Table, {
            children: [(0, _inferno.createComponentVNode)(2, _components.Table.Row, {
              children: "* List Element 1"
            }), (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
              children: "* List Element 2"
            }), (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
              children: "* Etc..."
            })]
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: (0, _inferno.createVNode)(1, "ul", null, [(0, _inferno.createVNode)(1, "li", null, "List Element 1", 16), (0, _inferno.createVNode)(1, "li", null, "List Element 2", 16), (0, _inferno.createVNode)(1, "li", null, "Etc...", 16)], 4)
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: (0, _inferno.createComponentVNode)(2, _components.Table, {
            children: [(0, _inferno.createComponentVNode)(2, _components.Table.Row, {
              children: "1. List Element 1"
            }), (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
              children: "2. List Element 2"
            }), (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
              children: "3. Etc..."
            })]
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
          children: (0, _inferno.createVNode)(1, "ol", null, [(0, _inferno.createVNode)(1, "li", null, "List Element 1", 16), (0, _inferno.createVNode)(1, "li", null, "List Element 2", 16), (0, _inferno.createVNode)(1, "li", null, "Etc...", 16)], 4)
        })]
      })]
    })]
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/Particool.js":
/*!***********************************************!*\
  !*** ./packages/tgui/interfaces/Particool.js ***!
  \***********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Particool = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _math2 = __webpack_require__(/*! ../../common/math */ "./packages/common/math.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var _logging = __webpack_require__(/*! ../logging */ "./packages/tgui/logging.js");

/**
 * @file
 * @copyright 2021 Gomble (https://github.com/AndrewL97)
 * @author Original Gomble (https://github.com/AndrewL97)
 * @author Changes Azrun
 * @author Changes Sovexe (https://github.com/Sovexe)
 * @license MIT
 */
var ParticleIntegerEntry = function ParticleIntegerEntry(props, context) {
  var value = props.value,
      tooltip = props.tooltip,
      name = props.name;

  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act;

  return (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
    "position": "bottom",
    "content": tooltip,
    children: (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
      "value": value,
      "stepPixelSize": 5,
      "width": "39px",
      "onDrag": function () {
        function onDrag(e, value) {
          return act('modify_particle_value', {
            new_data: {
              name: name,
              value: value,
              type: 'int'
            }
          });
        }

        return onDrag;
      }()
    })
  });
};

var ParticleMatrixEntry = function ParticleMatrixEntry(props, context) {
  var value = props.value,
      name = props.name;

  var _useBackend2 = (0, _backend.useBackend)(context),
      act = _useBackend2.act; // Actual matrix, or matrix of 0


  value = value || [1, 0, 0, 1, 0, 0]; // this doesn't make sense, it should be [1, 0, 0, 0, 1, 0] but it's not

  return (0, _inferno.createComponentVNode)(2, _components.Flex, {
    children: (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      children: value.map(function (val, i) {
        return (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
          "value": val,
          "onDrag": function () {
            function onDrag(e, v) {
              value[i] = v;
              act('modify_particle_value', {
                new_data: {
                  name: name,
                  value: value,
                  type: 'matrix'
                }
              });
            }

            return onDrag;
          }()
        }, i);
      })
    })
  });
};

var ParticleFloatEntry = function ParticleFloatEntry(props, context) {
  var value = props.value,
      tooltip = props.tooltip,
      name = props.name;

  var _useBackend3 = (0, _backend.useBackend)(context),
      act = _useBackend3.act;

  var entry = null;
  var isGen = typeof value === 'string';

  if (isGen) {
    entry = ParticleGeneratorEntry(props, context);
  } else {
    entry = ParticleFloatNonGenEntry(props, context);
  }

  return (0, _inferno.createComponentVNode)(2, _components.Flex, {
    children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      children: entry
    }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "align": "right",
      children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
        "checked": isGen,
        "content": "generator",
        "onClick": function () {
          function onClick() {
            return act('modify_particle_value', {
              new_data: {
                name: name,
                value: isGen ? 0 : {
                  genType: 'num',
                  a: value,
                  b: value,
                  rand: "UNIFORM_RAND"
                },
                type: isGen ? 'float' : 'generator'
              }
            });
          }

          return onClick;
        }()
      })
    })]
  });
};

var ParticleFloatNonGenEntry = function ParticleFloatNonGenEntry(props, context) {
  var value = props.value,
      tooltip = props.tooltip,
      name = props.name;

  var _useBackend4 = (0, _backend.useBackend)(context),
      act = _useBackend4.act;

  var _useLocalState = (0, _backend.useLocalState)(context, 'particleFloatStep', 0.01),
      step = _useLocalState[0],
      _ = _useLocalState[1];

  return (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
    "position": "bottom",
    "content": tooltip,
    children: (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
      "value": value,
      "stepPixelSize": 4,
      "step": step,
      "format": function () {
        function format(value) {
          return (0, _math.toFixed)(value, (0, _math2.numberOfDecimalDigits)(step));
        }

        return format;
      }(),
      "width": "80px",
      "onDrag": function () {
        function onDrag(e, value) {
          return act('modify_particle_value', {
            new_data: {
              name: name,
              value: value,
              type: 'float'
            }
          });
        }

        return onDrag;
      }()
    })
  });
};

var ParticleVectorEntry = function ParticleVectorEntry(props, context) {
  var value = props.value,
      tooltip = props.tooltip,
      name = props.name;

  var _useBackend5 = (0, _backend.useBackend)(context),
      act = _useBackend5.act;

  var entry = null;
  var isGen = typeof value === 'string';

  if (isGen) {
    entry = ParticleGeneratorEntry(props, context);
  } else {
    entry = ParticleVectorNonGenEntry(props, context);
  }

  return (0, _inferno.createComponentVNode)(2, _components.Flex, {
    children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      children: entry
    }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "align": "right",
      children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
        "checked": isGen,
        "content": "generator",
        "onClick": function () {
          function onClick() {
            return act('modify_particle_value', {
              new_data: {
                name: name,
                value: isGen ? [0, 0, 0] : {
                  genType: 'box',
                  a: value,
                  b: value,
                  rand: "UNIFORM_RAND"
                },
                type: isGen ? 'vector' : 'generator'
              }
            });
          }

          return onClick;
        }()
      })
    })]
  });
};

var ParticleVectorNonGenEntryVarLen = function ParticleVectorNonGenEntryVarLen(len) {
  return function (props, context) {
    var value = props.value,
        name = props.name;

    var _useBackend6 = (0, _backend.useBackend)(context),
        act = _useBackend6.act;

    value = value || Array(len).fill(0);

    if (!isNaN(value)) {
      value = Array(len).fill(value);
    }

    value = value.slice(0, len);
    return (0, _inferno.createComponentVNode)(2, _components.Flex, {
      children: (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        children: value.map(function (val, i) {
          return (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
            "value": val,
            "width": "40px",
            "onDrag": function () {
              function onDrag(e, v) {
                value[i] = v;
                act('modify_particle_value', {
                  new_data: {
                    name: name,
                    value: value,
                    type: 'vector'
                  }
                });
              }

              return onDrag;
            }()
          }, i);
        })
      })
    });
  };
};

var ParticleVectorNonGenEntry = ParticleVectorNonGenEntryVarLen(3);

var ParticleVector2Entry = function ParticleVector2Entry(props, context) {
  var value = props.value,
      tooltip = props.tooltip,
      name = props.name;

  var _useBackend7 = (0, _backend.useBackend)(context),
      act = _useBackend7.act;

  var entry = null;
  var isGen = typeof value === 'string';

  if (isGen) {
    entry = ParticleGeneratorEntry(props, context);
  } else {
    entry = ParticleVectorNonGenEntryVarLen(2)(props, context);
  }

  return (0, _inferno.createComponentVNode)(2, _components.Flex, {
    children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      children: entry
    }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "align": "right",
      children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
        "checked": isGen,
        "content": "generator",
        "onClick": function () {
          function onClick() {
            return act('modify_particle_value', {
              new_data: {
                name: name,
                value: isGen ? [0, 0] : {
                  genType: 'box',
                  a: value,
                  b: value,
                  rand: "UNIFORM_RAND"
                },
                type: isGen ? 'vector' : 'generator'
              }
            });
          }

          return onClick;
        }()
      })
    })]
  });
};

var ParticleGeneratorEntry = function ParticleGeneratorEntry(props, context) {
  var value = props.value,
      name = props.name;

  var _useBackend8 = (0, _backend.useBackend)(context),
      act = _useBackend8.act;

  var generatorTypes = ["num", "vector", "box", "color", "circle", "sphere", "square", "cube"];
  var randTypes = ["UNIFORM_RAND", "NORMAL_RAND", "LINEAR_RAND", "SQUARE_RAND"];
  var tempGenType = '';
  var tempA = '';
  var tempB = '';
  var tempRand = '';

  _logging.logger.log(value); // Value will come through a binobj of the generator, i.e
  // "client generator(box, UNIFORM_RAND, list(-10,-10,-10), list(10,10,10))"
  // So do this hacky garbage to convert it back into values


  if (value) {
    // Get contents of brackets
    var params = value.match(/\((.*)\)/);
    params = params ? params : ["", "", "", ""]; // Split into params

    params = params[1].split(', ');

    if (params.length === 4) {
      tempGenType = params[0].replace(/['"]+/g, ''); // Try to get contents of list(), just pass value if null

      var aTemp = params[1].match(/\((.*)\)/);
      tempA = aTemp ? aTemp[1] : params[1].replace(/['"]+/g, ''); // fermented soy beans

      var bTemp = params[2].match(/\((.*)\)/);
      tempB = bTemp ? bTemp[1] : params[2].replace(/['"]+/g, '');
      tempRand = params[3];
    }
  }

  var _useLocalState2 = (0, _backend.useLocalState)(context, name + 'genType', tempGenType),
      genType = _useLocalState2[0],
      setGenType = _useLocalState2[1];

  var _useLocalState3 = (0, _backend.useLocalState)(context, name + 'a', tempA),
      a = _useLocalState3[0],
      setA = _useLocalState3[1];

  var _useLocalState4 = (0, _backend.useLocalState)(context, name + 'b', tempB),
      b = _useLocalState4[0],
      setB = _useLocalState4[1];

  var _useLocalState5 = (0, _backend.useLocalState)(context, name + 'rand', tempRand),
      rand = _useLocalState5[0],
      setRand = _useLocalState5[1];

  var doAct = function doAct() {
    _logging.logger.log(genType);

    act('modify_particle_value', {
      new_data: {
        name: name,
        value: {
          genType: genType,
          a: a,
          b: b,
          rand: rand
        },
        type: 'generator'
      }
    });
  };

  return (0, _inferno.createComponentVNode)(2, _components.Collapsible, {
    "title": "Generator Settings - Hit Set to save",
    children: (0, _inferno.createComponentVNode)(2, _components.Section, {
      "level": 2,
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList, {
        children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "type",
          children: (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
            "position": "bottom",
            "content": "" + generatorTypes.join(", "),
            children: (0, _inferno.createComponentVNode)(2, _components.Input, {
              "value": genType,
              "onInput": function () {
                function onInput(e, val) {
                  return setGenType(val);
                }

                return onInput;
              }()
            })
          })
        }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "A",
          children: (0, _inferno.createComponentVNode)(2, _components.Input, {
            "value": a,
            "onInput": function () {
              function onInput(e, val) {
                return setA(val);
              }

              return onInput;
            }()
          })
        }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "B",
          children: (0, _inferno.createComponentVNode)(2, _components.Input, {
            "value": b,
            "onInput": function () {
              function onInput(e, val) {
                return setB(val);
              }

              return onInput;
            }()
          })
        }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Rand Type",
          children: (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
            "position": "bottom",
            "content": "" + randTypes.join(", "),
            children: (0, _inferno.createComponentVNode)(2, _components.Input, {
              "value": rand,
              "onInput": function () {
                function onInput(e, val) {
                  return setRand(val);
                }

                return onInput;
              }()
            })
          })
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Button, {
        "content": "Set",
        "onClick": function () {
          function onClick() {
            return doAct();
          }

          return onClick;
        }()
      })]
    })
  });
};

var ParticleTextEntry = function ParticleTextEntry(props, context) {
  var value = props.value,
      tooltip = props.tooltip,
      name = props.name;

  var _useBackend9 = (0, _backend.useBackend)(context),
      act = _useBackend9.act;

  return (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
    "position": "bottom",
    "content": tooltip,
    children: (0, _inferno.createComponentVNode)(2, _components.Input, {
      "value": value,
      "width": "250px",
      "onInput": function () {
        function onInput(e, value) {
          return act('modify_particle_value', {
            new_data: {
              name: name,
              value: value,
              type: 'text'
            }
          });
        }

        return onInput;
      }()
    })
  });
};

var ParticleNumListEntry = function ParticleNumListEntry(props, context) {
  var value = props.value,
      tooltip = props.tooltip,
      name = props.name;

  var _useBackend10 = (0, _backend.useBackend)(context),
      act = _useBackend10.act;

  var valArr = value ? Object.keys(value).map(function (key) {
    return value[key];
  }) : [];
  return (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
    "position": "bottom",
    "content": tooltip,
    children: (0, _inferno.createComponentVNode)(2, _components.Input, {
      "value": valArr.join(','),
      "width": "250px",
      "onInput": function () {
        function onInput(e, val) {
          return act('modify_particle_value', {
            new_data: {
              name: name,
              value: val,
              type: 'numList'
            }
          });
        }

        return onInput;
      }()
    })
  });
};

var ParticleListEntry = function ParticleListEntry(props, context) {
  var value = props.value,
      tooltip = props.tooltip,
      name = props.name;

  var _useBackend11 = (0, _backend.useBackend)(context),
      act = _useBackend11.act;

  var valArr = value ? Object.keys(value).map(function (key) {
    return value[key];
  }) : [];
  return (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
    "position": "bottom",
    "content": tooltip,
    children: (0, _inferno.createComponentVNode)(2, _components.Input, {
      "value": valArr.join(','),
      "width": "250px",
      "onInput": function () {
        function onInput(e, val) {
          return act('modify_particle_value', {
            new_data: {
              name: name,
              value: val,
              type: 'list'
            }
          });
        }

        return onInput;
      }()
    })
  });
};

var ParticleColorNonGenEntry = function ParticleColorNonGenEntry(props, context) {
  var value = props.value,
      tooltip = props.tooltip,
      name = props.name;

  var _useBackend12 = (0, _backend.useBackend)(context),
      act = _useBackend12.act;

  return (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
    "position": "bottom",
    "content": tooltip,
    children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
      "icon": "pencil-alt",
      "onClick": function () {
        function onClick() {
          return act('modify_color_value');
        }

        return onClick;
      }()
    }), (0, _inferno.createComponentVNode)(2, _components.ColorBox, {
      "color": value,
      "mr": 0.5
    }), (0, _inferno.createComponentVNode)(2, _components.Input, {
      "value": value,
      "width": "90px",
      "onInput": function () {
        function onInput(e, value) {
          return act('modify_particle_value', {
            new_data: {
              name: name,
              value: value,
              type: 'color'
            }
          });
        }

        return onInput;
      }()
    })]
  });
};

var ParticleColorEntry = function ParticleColorEntry(props, context) {
  var value = props.value,
      tooltip = props.tooltip,
      name = props.name;

  var _useBackend13 = (0, _backend.useBackend)(context),
      act = _useBackend13.act;

  var entry = null;
  var isGen = typeof value === 'string' && value.charAt(0) !== '#';

  if (isGen) {
    entry = ParticleGeneratorEntry(props, context);
  } else {
    entry = ParticleColorNonGenEntry(props, context);
  }

  return (0, _inferno.createComponentVNode)(2, _components.Flex, {
    children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      children: entry
    }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "align": "right",
      children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
        "checked": isGen,
        "content": "generator",
        "onClick": function () {
          function onClick() {
            return act('modify_particle_value', {
              new_data: {
                name: name,
                value: isGen ? "#ffffff" : {
                  genType: 'color',
                  a: value,
                  b: value,
                  rand: "UNIFORM_RAND"
                },
                type: isGen ? 'color' : 'generator'
              }
            });
          }

          return onClick;
        }()
      })
    })]
  });
};

var ParticleIconEntry = function ParticleIconEntry(props, context) {
  var value = props.value;

  var _useBackend14 = (0, _backend.useBackend)(context),
      act = _useBackend14.act;

  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
    "icon": "pencil-alt",
    "onClick": function () {
      function onClick() {
        return act('modify_icon_value');
      }

      return onClick;
    }()
  }), (0, _inferno.createComponentVNode)(2, _components.Box, {
    "inline": true,
    "ml": 1,
    children: value
  })], 4);
};

var particleEntryMap = {
  width: {
    type: 'float_nongen',
    tooltip: 'Width of particle image in pixels'
  },
  height: {
    type: 'float_nongen',
    tooltip: 'Height of particle image in pixels'
  },
  count: {
    type: 'int',
    tooltip: "Maximum particle count"
  },
  spawning: {
    type: 'float_nongen',
    tooltip: "Number of particles to spawn per tick (can be fractional)"
  },
  bound1: {
    type: 'vector_nongen',
    tooltip: "Minimum particle position in x,y,z space"
  },
  bound2: {
    type: 'vector_nongen',
    tooltip: "Maximum particle position in x,y,z space"
  },
  gravity: {
    type: 'vector_nongen',
    tooltip: "Constant acceleration applied to all particles in this set (pixels per squared tick)"
  },
  gradient: {
    type: 'list',
    tooltip: "Color gradient used, if any"
  },
  transform: {
    type: 'matrix',
    tooltip: "Transform done to all particles, if any (can be higher than 2D)"
  },
  lifespan: {
    type: 'float',
    tooltip: "Maximum life of the particle, in ticks"
  },
  fade: {
    type: 'float',
    tooltip: "Fade-out time at end of lifespan, in ticks"
  },
  fadein: {
    type: 'float',
    tooltip: "Fade-in time, in ticks"
  },
  icon: {
    type: 'icon',
    tooltip: "Icon to use, if any; no icon means this particle will be a dot"
  },
  icon_state: {
    type: 'list',
    tooltip: "Icon state to use, if any"
  },
  color: {
    type: 'color',
    tooltip: "Particle color; can be a number if a gradient is used"
  },
  color_change: {
    type: 'float',
    tooltip: "Color change per tick; only applies if gradient is used"
  },
  position: {
    type: 'vector',
    tooltip: "x,y,z position, from center in pixels"
  },
  velocity: {
    type: 'vector',
    tooltip: "x,y,z velocity, in pixels"
  },
  scale: {
    type: 'vector2',
    tooltip: "(2D)	Scale applied to icon, if used; defaults to list(1,1)"
  },
  grow: {
    type: 'vector2',
    tooltip: "Change in scale per tick; defaults to list(0,0)"
  },
  rotation: {
    type: 'float',
    tooltip: "Angle of rotation (clockwise); applies only if using an icon"
  },
  spin: {
    type: 'float',
    tooltip: "Change in rotation per tick"
  },
  friction: {
    type: 'float',
    tooltip: "Amount of velocity to shed (0 to 1) per tick, also applied to acceleration from drift"
  },
  drift: {
    type: 'vector',
    tooltip: "Added acceleration every tick; e.g. a circle or sphere generator can be applied to produce snow or ember effects"
  }
};

var ParticleDataEntry = function ParticleDataEntry(props, context) {
  var name = props.name,
      value = props.value;
  var particleEntryTypes = {
    "int": (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, ParticleIntegerEntry, Object.assign({}, props))),
    "float": (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, ParticleFloatEntry, Object.assign({}, props))),
    float_nongen: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, ParticleFloatNonGenEntry, Object.assign({}, props))),
    string: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, ParticleTextEntry, Object.assign({}, props))),
    numlist: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, ParticleNumListEntry, Object.assign({}, props))),
    list: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, ParticleListEntry, Object.assign({}, props))),
    color: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, ParticleColorEntry, Object.assign({}, props))),
    icon: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, ParticleIconEntry, Object.assign({}, props))),
    generator: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, ParticleGeneratorEntry, Object.assign({}, props))),
    matrix: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, ParticleMatrixEntry, Object.assign({}, props))),
    vector: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, ParticleVectorEntry, Object.assign({}, props))),
    vector_nongen: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, ParticleVectorNonGenEntry, Object.assign({}, props))),
    vector2: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, ParticleVector2Entry, Object.assign({}, props)))
  };
  return (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
    "label": name,
    children: particleEntryTypes[particleEntryMap[name].type] || particleEntryMap[name].type || "Not Found (This is an error)"
  });
};

var ParticleEntry = function ParticleEntry(props, context) {
  var _useBackend15 = (0, _backend.useBackend)(context),
      act = _useBackend15.act,
      data = _useBackend15.data;

  var particle = props.particle;
  return (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
    children: Object.keys(particleEntryMap).map(function (entryName) {
      var value = particle[entryName];
      var tooltip = particleEntryMap[entryName].tooltip || "Oh Bees! Tooltip is missing.";
      return (0, _inferno.createComponentVNode)(2, ParticleDataEntry, {
        "name": entryName,
        "tooltip": tooltip,
        "value": value
      }, entryName);
    })
  });
};

var GeneratorHelp = function GeneratorHelp() {
  return (0, _inferno.createComponentVNode)(2, _components.Collapsible, {
    "title": "Generator Help",
    children: [(0, _inferno.createComponentVNode)(2, _components.Section, {
      "level": 2
    }), (0, _inferno.createComponentVNode)(2, _components.Section, {
      "level": 2,
      children: (0, _inferno.createVNode)(1, "table", null, (0, _inferno.createVNode)(1, "tbody", null, [(0, _inferno.createVNode)(1, "tr", null, [(0, _inferno.createVNode)(1, "td", null, "Generator type", 16), (0, _inferno.createVNode)(1, "td", null, "Result type", 16), (0, _inferno.createVNode)(1, "td", null, "Description", 16)], 4), (0, _inferno.createVNode)(1, "tr", null, [(0, _inferno.createVNode)(1, "td", null, "num", 16), (0, _inferno.createVNode)(1, "td", null, "num", 16), (0, _inferno.createVNode)(1, "td", null, "A random number between A and B.", 16)], 4), (0, _inferno.createVNode)(1, "tr", null, [(0, _inferno.createVNode)(1, "td", null, "vector", 16), (0, _inferno.createVNode)(1, "td", null, "vector", 16), (0, _inferno.createVNode)(1, "td", null, "A random vector on a line between A and B.", 16)], 4), (0, _inferno.createVNode)(1, "tr", null, [(0, _inferno.createVNode)(1, "td", null, "box", 16), (0, _inferno.createVNode)(1, "td", null, "vector", 16), (0, _inferno.createVNode)(1, "td", null, "A random vector within a box whose corners are at A and B.", 16)], 4), (0, _inferno.createVNode)(1, "tr", null, [(0, _inferno.createVNode)(1, "td", null, "color", 16), (0, _inferno.createVNode)(1, "td", null, "color (string) or color matrix", 16), (0, _inferno.createVNode)(1, "td", null, "Result type depends on whether A or B are matrices or not. The result is interpolated between A and B; components are not randomized separately.", 16)], 4), (0, _inferno.createVNode)(1, "tr", null, [(0, _inferno.createVNode)(1, "td", null, "circle", 16), (0, _inferno.createVNode)(1, "td", null, "vector", 16), (0, _inferno.createVNode)(1, "td", null, "A random XY-only vector in a ring between radius A and B, centered at 0,0.", 16)], 4), (0, _inferno.createVNode)(1, "tr", null, [(0, _inferno.createVNode)(1, "td", null, "sphere", 16), (0, _inferno.createVNode)(1, "td", null, "vector", 16), (0, _inferno.createVNode)(1, "td", null, "A random vector in a spherical shell between radius A and B, centered at 0,0,0.", 16)], 4), (0, _inferno.createVNode)(1, "tr", null, [(0, _inferno.createVNode)(1, "td", null, "square", 16), (0, _inferno.createVNode)(1, "td", null, "vector", 16), (0, _inferno.createVNode)(1, "td", null, "A random XY-only vector between squares of sizes A and B. (The length of the square is between A*2 and B*2, centered at 0,0.)", 16)], 4), (0, _inferno.createVNode)(1, "tr", null, [(0, _inferno.createVNode)(1, "td", null, "cube", 16), (0, _inferno.createVNode)(1, "td", null, "vector", 16), (0, _inferno.createVNode)(1, "td", null, "A random vector between cubes of sizes A and B. (The length of the cube is between A*2 and B*2, centered at 0,0,0.)", 16)], 4)], 4), 2)
    })]
  });
};

var Particool = function Particool(props, context) {
  var _useBackend16 = (0, _backend.useBackend)(context),
      act = _useBackend16.act,
      data = _useBackend16.data;

  var particles = data.target_particle || {};
  var hasParticles = particles && Object.keys(particles).length > 0;

  var _useLocalState6 = (0, _backend.useLocalState)(context, 'particleFloatStep', 0.01),
      step = _useLocalState6[0],
      setStep = _useLocalState6[1];

  var _useLocalState7 = (0, _backend.useLocalState)(context, 'hidden', false),
      hiddenSecret = _useLocalState7[0],
      setHiddenSecret = _useLocalState7[1];

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "title": "Particool",
    "width": 700,
    "height": 500,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      "scrollable": true,
      children: [!!hiddenSecret && (0, _inferno.createComponentVNode)(2, _components.NoticeBox, {
        "danger": true,
        children: [" ", String(Date.now()), " ", (0, _inferno.createVNode)(1, "br"), "Particles? ", hasParticles.toString(), " -", (data.target_particle === null).toString(), " ", (0, _inferno.createVNode)(1, "br"), "Json - ", JSON.stringify(data.target_particle)]
      }), (0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": (0, _inferno.createComponentVNode)(2, _components.Box, {
          "inline": true,
          "onDblClick": function () {
            function onDblClick() {
              return setHiddenSecret(true);
            }

            return onDblClick;
          }(),
          children: "Particle"
        }),
        "buttons": !hasParticles ? (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "plus",
          "content": "Add Particle",
          "onClick": function () {
            function onClick() {
              return act('add_particle');
            }

            return onClick;
          }()
        }) : (0, _inferno.createComponentVNode)(2, _components.Button.Confirm, {
          "icon": "minus",
          "content": "Remove Particle",
          "onClick": function () {
            function onClick() {
              return act("remove_particle");
            }

            return onClick;
          }()
        }),
        children: [(0, _inferno.createComponentVNode)(2, GeneratorHelp), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "inline": true,
          "ml": 2,
          "mr": 1,
          children: "Float change step:"
        }), (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
          "value": step,
          "step": 0.001,
          "format": function () {
            function format(value) {
              return (0, _math.toFixed)(value, (0, _math2.numberOfDecimalDigits)(step));
            }

            return format;
          }(),
          "width": "70px",
          "onChange": function () {
            function onChange(e, value) {
              return setStep(value);
            }

            return onChange;
          }()
        }), !hasParticles ? (0, _inferno.createComponentVNode)(2, _components.Box, {
          children: "No particle"
        }) : (0, _inferno.createComponentVNode)(2, ParticleEntry, {
          "particle": particles
        })]
      })]
    })
  });
};

exports.Particool = Particool;

/***/ }),

/***/ "./packages/tgui/interfaces/PlayerPanel/Header.tsx":
/*!*********************************************************!*\
  !*** ./packages/tgui/interfaces/PlayerPanel/Header.tsx ***!
  \*********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Header = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _constant = __webpack_require__(/*! ./constant */ "./packages/tgui/interfaces/PlayerPanel/constant.ts");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var Header = function Header(props) {
  var children = props.children,
      onSortClick = props.onSortClick,
      sortDirection = props.sortDirection,
      rest = _objectWithoutPropertiesLoose(props, ["children", "onSortClick", "sortDirection"]);

  var iconName = sortDirection ? sortDirection === _constant.SortDirection.Asc ? 'sort-alpha-down' : 'sort-alpha-up' : 'sort';
  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _components.Stack, Object.assign({
    "style": {
      cursor: 'pointer'
    },
    "onClick": onSortClick
  }, rest, {
    children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      children: children
    }), onSortClick && (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      children: (0, _inferno.createComponentVNode)(2, _components.Icon, {
        "name": iconName,
        "unselectable": true
      })
    })]
  })));
};

exports.Header = Header;

/***/ }),

/***/ "./packages/tgui/interfaces/PlayerPanel/constant.ts":
/*!**********************************************************!*\
  !*** ./packages/tgui/interfaces/PlayerPanel/constant.ts ***!
  \**********************************************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.SortDirection = exports.Action = void 0;

/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */
var Action;
exports.Action = Action;

(function (Action) {
  Action["JumpToPlayerLocation"] = "jump-to-player-loc";
  Action["OpenPlayerOptions"] = "open-player-options";
  Action["PrivateMessagePlayer"] = "private-message-player";
})(Action || (exports.Action = Action = {}));

var SortDirection;
exports.SortDirection = SortDirection;

(function (SortDirection) {
  SortDirection["Asc"] = "asc";
  SortDirection["Desc"] = "desc";
})(SortDirection || (exports.SortDirection = SortDirection = {}));

/***/ }),

/***/ "./packages/tgui/interfaces/PlayerPanel/index.tsx":
/*!********************************************************!*\
  !*** ./packages/tgui/interfaces/PlayerPanel/index.tsx ***!
  \********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.PlayerPanel = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../../layouts */ "./packages/tgui/layouts/index.js");

var _Header = __webpack_require__(/*! ./Header */ "./packages/tgui/interfaces/PlayerPanel/Header.tsx");

var _constant = __webpack_require__(/*! ./constant */ "./packages/tgui/interfaces/PlayerPanel/constant.ts");

/**
 * @file
 * @copyright 2021
 * @author Sovexe (https://github.com/Sovexe)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */
var defaultTemplate = function defaultTemplate(config) {
  return "" + config.value;
};

var ckeyTemplate = function ckeyTemplate(config) {
  var act = config.act,
      row = config.row,
      value = config.value;
  return (0, _inferno.createComponentVNode)(2, _components.Stack, {
    children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      "grow": 1,
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "onClick": function () {
          function onClick() {
            return act(_constant.Action.OpenPlayerOptions, {
              ckey: value,
              mobRef: row.mobRef
            });
          }

          return onClick;
        }(),
        children: value
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "envelope",
        "color": "bad",
        "onClick": function () {
          function onClick() {
            return act(_constant.Action.PrivateMessagePlayer, {
              ckey: value,
              mobRef: row.mobRef
            });
          }

          return onClick;
        }()
      })
    })]
  });
};

var playerLocationTemplate = function playerLocationTemplate(config) {
  var act = config.act,
      row = config.row,
      value = config.value;
  return (0, _inferno.createComponentVNode)(2, _components.Button, {
    "onClick": function () {
      function onClick() {
        return act(_constant.Action.JumpToPlayerLocation, {
          ckey: row.ckey,
          mobRef: row.mobRef
        });
      }

      return onClick;
    }(),
    children: value
  });
};

var alphabeticalSorter = function alphabeticalSorter(a, b) {
  return a.localeCompare(b);
}; // https://stackoverflow.com/a/68147012


var makeIpNumber = function makeIpNumber(ip) {
  return Number(ip.split('.').map(function (subString) {
    return ("00" + subString).slice(-3);
  }).join(''));
};

var ipSorter = function ipSorter(a, b) {
  return makeIpNumber(a) - makeIpNumber(b);
};

var numberSorter = function numberSorter(a, b) {
  return a - b;
};

var dateStringSorter = function dateStringSorter(a, b) {
  var aArray = a.split("-").map(parseFloat);
  var bArray = b.split("-").map(parseFloat);
  return aArray > bArray ? 1 : aArray < bArray ? -1 : 0;
};

var createDefaultValueSelector = function createDefaultValueSelector(field) {
  return function (config) {
    return config.row[field];
  };
};

var createDefaultColumnConfig = function createDefaultColumnConfig(field) {
  return {
    id: field,
    sorter: alphabeticalSorter,
    template: defaultTemplate,
    valueSelector: createDefaultValueSelector(field)
  };
};

var columns = [Object.assign({}, createDefaultColumnConfig('ckey'), {
  name: 'CKey',
  template: ckeyTemplate
}), Object.assign({}, createDefaultColumnConfig('name'), {
  name: 'Name'
}), Object.assign({}, createDefaultColumnConfig('realName'), {
  name: 'Real Name'
}), Object.assign({}, createDefaultColumnConfig('assignedRole'), {
  name: 'Assigned Role'
}), Object.assign({}, createDefaultColumnConfig('specialRole'), {
  name: 'Special Role'
}), Object.assign({}, createDefaultColumnConfig('playerType'), {
  name: 'Player Type'
}), Object.assign({}, createDefaultColumnConfig('computerId'), {
  name: 'CID'
}), Object.assign({}, createDefaultColumnConfig('ip'), {
  name: 'IP',
  sorter: ipSorter
}), Object.assign({}, createDefaultColumnConfig('joined'), {
  name: 'Join Date',
  sorter: dateStringSorter
}), Object.assign({}, createDefaultColumnConfig('playerLocation'), {
  name: 'Player Location',
  template: playerLocationTemplate
}), Object.assign({}, createDefaultColumnConfig('ping'), {
  name: 'Ping',
  sorter: numberSorter
})];

var PlayerPanel = function PlayerPanel(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var players = data.players;

  var _useLocalState = (0, _backend.useLocalState)(context, 'search', ''),
      search = _useLocalState[0],
      setSearch = _useLocalState[1];

  var _useLocalState2 = (0, _backend.useLocalState)(context, 'sort', null),
      sort = _useLocalState2[0],
      setSort = _useLocalState2[1];

  var resolvedPlayers = Object.keys(players).map(function (ckey) {
    return players[ckey];
  }); // generate all values up front (to avoid having to generate multiple times)

  var playerValues = resolvedPlayers.reduce(function (prevPlayerValues, currPlayer) {
    prevPlayerValues[currPlayer.ckey] = columns.reduce(function (prevValues, currColumn) {
      var id = currColumn.id,
          valueSelector = currColumn.valueSelector;
      prevValues[id] = valueSelector({
        column: currColumn,
        row: currPlayer
      });
      return prevValues;
    }, {});
    return prevPlayerValues;
  }, {});

  if (search) {
    var lowerSearch = search.toLowerCase();
    resolvedPlayers = resolvedPlayers.filter(function (player) {
      var values = Object.values(playerValues[player.ckey]);
      return values.some(function (value) {
        return typeof value === 'string' && value.toLowerCase().includes(lowerSearch);
      });
    });
  }

  if (sort) {
    var sortColumn = columns.find(function (column) {
      return column.id === sort.id;
    });

    if (sortColumn) {
      resolvedPlayers.sort(function (a, b) {
        var comparison = sortColumn.sorter(playerValues[a.ckey][sortColumn.id], playerValues[b.ckey][sortColumn.id]);

        if (sort.dir === _constant.SortDirection.Desc) {
          comparison *= -1;
        }

        return comparison;
      });
    }
  }

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 1100,
    "height": 640,
    "title": "Player Panel",
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      "scrollable": true,
      children: [(0, _inferno.createComponentVNode)(2, _components.Input, {
        "autoFocus": true,
        "mb": 1,
        "placeholder": "Search...",
        "onInput": function () {
          function onInput(_e, value) {
            return setSearch(value);
          }

          return onInput;
        }(),
        "value": search
      }), (0, _inferno.createComponentVNode)(2, _components.Table, {
        children: [(0, _inferno.createComponentVNode)(2, _components.Table.Row, {
          "header": true,
          children: columns.map(function (column) {
            var columnSort = (sort == null ? void 0 : sort.id) === column.id ? sort : null;
            return (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
              children: (0, _inferno.createComponentVNode)(2, _Header.Header, {
                "onSortClick": column.sorter ? function () {
                  return setSort({
                    dir: columnSort != null && columnSort.dir ? columnSort.dir === _constant.SortDirection.Asc ? _constant.SortDirection.Desc : _constant.SortDirection.Asc : _constant.SortDirection.Asc,
                    id: column.id
                  });
                } : null,
                "sortDirection": columnSort == null ? void 0 : columnSort.dir,
                children: column.name
              })
            }, column.field);
          })
        }), resolvedPlayers.map(function (player) {
          var ckey = player.ckey;
          return (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
            children: columns.map(function (column) {
              var id = column.id,
                  template = column.template;
              return (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
                children: template({
                  act: act,
                  column: column,
                  row: player,
                  value: playerValues[ckey][id]
                })
              }, id);
            })
          }, ckey);
        })]
      })]
    })
  });
};

exports.PlayerPanel = PlayerPanel;

/***/ }),

/***/ "./packages/tgui/interfaces/PlayerPanel/type.ts":
/*!******************************************************!*\
  !*** ./packages/tgui/interfaces/PlayerPanel/type.ts ***!
  \******************************************************/
/***/ (function() {

"use strict";


/***/ }),

/***/ "./packages/tgui/interfaces/PowerMonitor/Apc.tsx":
/*!*******************************************************!*\
  !*** ./packages/tgui/interfaces/PowerMonitor/Apc.tsx ***!
  \*******************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.PowerMonitorApcTableRows = exports.PowerMonitorApcTableHeader = exports.PowerMonitorApcGlobal = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _format = __webpack_require__(/*! ../../format */ "./packages/tgui/format.js");

var _apcState, _apcCellState;

var apcState = (_apcState = {}, _apcState[0] = 'Off', _apcState[1] = (0, _inferno.createComponentVNode)(2, _components.Box, {
  "inline": true,
  children: ["Off", ' ', (0, _inferno.createComponentVNode)(2, _components.Box, {
    "inline": true,
    "color": "grey",
    children: "(Auto)"
  })]
}), _apcState[2] = 'On', _apcState[3] = (0, _inferno.createComponentVNode)(2, _components.Box, {
  "inline": true,
  children: ["On", ' ', (0, _inferno.createComponentVNode)(2, _components.Box, {
    "inline": true,
    "color": "grey",
    children: "(Auto)"
  })]
}), _apcState);
var apcCellState = (_apcCellState = {}, _apcCellState[0] = 'Discharging', _apcCellState[1] = 'Charging', _apcCellState[2] = 'Charged', _apcCellState);

var PowerMonitorApcGlobal = function PowerMonitorApcGlobal(_props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data;

  var availableHistory = data.history.map(function (v) {
    return v[0];
  });
  var availableHistoryData = availableHistory.map(function (v, i) {
    return [i, v];
  });
  var loadHistory = data.history.map(function (v) {
    return v[1];
  });
  var loadHistoryData = loadHistory.map(function (v, i) {
    return [i, v];
  });
  var max = Math.max.apply(Math, availableHistory.concat(loadHistory));
  return (0, _inferno.createComponentVNode)(2, _components.Stack, {
    "fill": true,
    children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      "width": "50%",
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList, {
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Total Power",
          children: (0, _format.formatPower)(data.available)
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Chart.Line, {
        "mt": "5px",
        "height": "5em",
        "data": availableHistoryData,
        "rangeX": [0, availableHistoryData.length - 1],
        "rangeY": [0, max],
        "strokeColor": "rgba(1, 184, 170, 1)",
        "fillColor": "rgba(1, 184, 170, 0.25)"
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      "width": "50%",
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList, {
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Total Load",
          children: (0, _format.formatPower)(data.load)
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Chart.Line, {
        "mt": "5px",
        "height": "5em",
        "data": loadHistoryData,
        "rangeX": [0, loadHistoryData.length - 1],
        "rangeY": [0, max],
        "strokeColor": "rgba(1, 184, 170, 1)",
        "fillColor": "rgba(1, 184, 170, 0.25)"
      })]
    })]
  });
};

exports.PowerMonitorApcGlobal = PowerMonitorApcGlobal;

var PowerMonitorApcTableHeader = function PowerMonitorApcTableHeader() {
  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
    "header": true,
    children: "Area"
  }), (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
    "content": "Equipment",
    children: (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      "header": true,
      "collapsing": true,
      children: "Eqp."
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
    "content": "Lighting",
    children: (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      "header": true,
      "collapsing": true,
      children: "Lgt."
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
    "content": "Environment",
    children: (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      "header": true,
      "collapsing": true,
      children: "Env."
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
    "header": true,
    "textAlign": "right",
    children: "Load"
  }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
    "header": true,
    "textAlign": "right",
    children: "Cell Charge"
  }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
    "header": true,
    children: "Cell State"
  })], 4);
};

exports.PowerMonitorApcTableHeader = PowerMonitorApcTableHeader;

var PowerMonitorApcTableRows = function PowerMonitorApcTableRows(props, context) {
  var search = props.search;

  var _useBackend2 = (0, _backend.useBackend)(context),
      data = _useBackend2.data;

  return (0, _inferno.createFragment)(data.apcs.map(function (apc) {
    return (0, _inferno.createComponentVNode)(2, PowerMonitorApcTableRow, {
      "apc": apc,
      "search": search
    }, apc[0]);
  }), 0);
};

exports.PowerMonitorApcTableRows = PowerMonitorApcTableRows;

var PowerMonitorApcTableRow = function PowerMonitorApcTableRow(props, context) {
  var _data$apcNames$ref;

  var apc = props.apc,
      search = props.search; // Indexed array to lower data transfer between byond and the window.

  var ref = apc[0],
      equipment = apc[1],
      lighting = apc[2],
      environment = apc[3],
      load = apc[4],
      cellCharge = apc[5],
      cellCharging = apc[6];

  var _useBackend3 = (0, _backend.useBackend)(context),
      data = _useBackend3.data;

  var name = (_data$apcNames$ref = data.apcNames[ref]) != null ? _data$apcNames$ref : 'N/A';

  if (search && !name.toLowerCase().includes(search.toLowerCase())) {
    return null;
  }

  return (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
    children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      children: name
    }), (0, _inferno.createComponentVNode)(2, ApcState, {
      "state": equipment
    }), (0, _inferno.createComponentVNode)(2, ApcState, {
      "state": lighting
    }), (0, _inferno.createComponentVNode)(2, ApcState, {
      "state": environment
    }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      "textAlign": "right",
      "nowrap": true,
      children: (0, _format.formatPower)(load)
    }), typeof cellCharge === 'number' ? (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      "textAlign": "right",
      "nowrap": true,
      children: [cellCharge, "%"]
    }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      "color": cellCharging > 0 ? cellCharging === 1 ? 'average' : 'good' : 'bad',
      "nowrap": true,
      children: apcCellState[cellCharging]
    })], 4) : (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Table.Cell), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      "color": "bad",
      children: "N/A"
    })], 4)]
  });
};

var ApcState = function ApcState(_ref) {
  var state = _ref.state;
  return (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
    "nowrap": true,
    "color": state >= 2 ? 'good' : 'bad',
    children: apcState[state]
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/PowerMonitor/Smes.tsx":
/*!********************************************************!*\
  !*** ./packages/tgui/interfaces/PowerMonitor/Smes.tsx ***!
  \********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.PowerMonitorSmesTableRows = exports.PowerMonitorSmesTableHeader = exports.PowerMonitorSmesGlobal = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _format = __webpack_require__(/*! ../../format */ "./packages/tgui/format.js");

/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */
var PowerMonitorSmesGlobal = function PowerMonitorSmesGlobal(_props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data;

  var availableHistory = data.history.map(function (v) {
    return v[0];
  });
  var availableHistoryData = availableHistory.map(function (v, i) {
    return [i, v];
  });
  var loadHistory = data.history.map(function (v) {
    return v[1];
  });
  var loadHistoryData = loadHistory.map(function (v, i) {
    return [i, v];
  });
  var max = Math.max.apply(Math, availableHistory.concat(loadHistory));
  return (0, _inferno.createComponentVNode)(2, _components.Stack, {
    "fill": true,
    children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      "width": "50%",
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList, {
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "Engine Output",
          children: (0, _format.formatPower)(data.available)
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Chart.Line, {
        "mt": "5px",
        "height": "5em",
        "data": availableHistoryData,
        "rangeX": [0, availableHistoryData.length - 1],
        "rangeY": [0, max],
        "strokeColor": "rgba(1, 184, 170, 1)",
        "fillColor": "rgba(1, 184, 170, 0.25)"
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      "width": "50%",
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList, {
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
          "label": "SMES/PTL Draw",
          children: (0, _format.formatPower)(data.load)
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Chart.Line, {
        "mt": "5px",
        "height": "5em",
        "data": loadHistoryData,
        "rangeX": [0, loadHistoryData.length - 1],
        "rangeY": [0, max],
        "strokeColor": "rgba(1, 184, 170, 1)",
        "fillColor": "rgba(1, 184, 170, 0.25)"
      })]
    })]
  });
};

exports.PowerMonitorSmesGlobal = PowerMonitorSmesGlobal;

var PowerMonitorSmesTableHeader = function PowerMonitorSmesTableHeader(props, context) {
  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
    "header": true,
    children: "Area"
  }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
    "header": true,
    children: "Stored Power"
  }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
    "header": true,
    children: "Charging"
  }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
    "header": true,
    children: "Input"
  }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
    "header": true,
    children: "Output"
  }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
    "header": true,
    children: "Active"
  }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
    "header": true,
    children: "Load"
  })], 4);
};

exports.PowerMonitorSmesTableHeader = PowerMonitorSmesTableHeader;

var PowerMonitorSmesTableRows = function PowerMonitorSmesTableRows(props, context) {
  var search = props.search;

  var _useBackend2 = (0, _backend.useBackend)(context),
      data = _useBackend2.data;

  return (0, _inferno.createFragment)(data.units.map(function (unit) {
    return (0, _inferno.createComponentVNode)(2, PowerMonitorSmesTableRow, {
      "unit": unit,
      "search": search
    }, unit[0]);
  }), 0);
};

exports.PowerMonitorSmesTableRows = PowerMonitorSmesTableRows;

var PowerMonitorSmesTableRow = function PowerMonitorSmesTableRow(props, context) {
  var _data$unitNames$ref;

  var unit = props.unit,
      search = props.search; // Indexed array to lower data transfer between byond and the window.

  var ref = unit[0],
      stored = unit[1],
      charging = unit[2],
      input = unit[3],
      output = unit[4],
      online = unit[5],
      load = unit[6];

  var _useBackend3 = (0, _backend.useBackend)(context),
      data = _useBackend3.data;

  var name = (_data$unitNames$ref = data.unitNames[ref]) != null ? _data$unitNames$ref : 'N/A';

  if (search && !name.toLowerCase().includes(search.toLowerCase())) {
    return null;
  }

  return (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
    children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      children: name
    }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      children: [stored, "%"]
    }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      "color": charging ? 'good' : 'bad',
      children: charging ? 'Yes' : 'No'
    }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      children: (0, _format.formatPower)(input)
    }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      children: (0, _format.formatPower)(output)
    }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      "color": online ? 'good' : 'bad',
      children: online ? 'Yes' : 'No'
    }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      children: load ? (0, _format.formatPower)(load) : 'N/A'
    })]
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/PowerMonitor/index.tsx":
/*!*********************************************************!*\
  !*** ./packages/tgui/interfaces/PowerMonitor/index.tsx ***!
  \*********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.PowerMonitor = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../../layouts */ "./packages/tgui/layouts/index.js");

var _Apc = __webpack_require__(/*! ./Apc */ "./packages/tgui/interfaces/PowerMonitor/Apc.tsx");

var _Smes = __webpack_require__(/*! ./Smes */ "./packages/tgui/interfaces/PowerMonitor/Smes.tsx");

var _type = __webpack_require__(/*! ./type */ "./packages/tgui/interfaces/PowerMonitor/type.ts");

/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */
var PowerMonitor = function PowerMonitor(_props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data;

  var _useSharedState = (0, _backend.useSharedState)(context, 'search', ''),
      search = _useSharedState[0],
      setSearch = _useSharedState[1];

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 700,
    "height": 700,
    "theme": "retro-dark",
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
        "vertical": true,
        "fill": true,
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            children: [(0, _type.isDataForApc)(data) && (0, _inferno.createComponentVNode)(2, _Apc.PowerMonitorApcGlobal), (0, _type.isDataForSmes)(data) && (0, _inferno.createComponentVNode)(2, _Smes.PowerMonitorSmesGlobal)]
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
              children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
                "label": "Search",
                children: (0, _inferno.createComponentVNode)(2, _components.Input, {
                  "value": search,
                  "onInput": function () {
                    function onInput(e, value) {
                      return setSearch(value);
                    }

                    return onInput;
                  }()
                })
              })
            })
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          "grow": 1,
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "fill": true,
            "scrollable": true,
            children: (0, _inferno.createComponentVNode)(2, _components.Table, {
              children: [(0, _inferno.createComponentVNode)(2, _components.Table.Row, {
                "header": true,
                children: (0, _type.isDataForApc)(data) && (0, _inferno.createComponentVNode)(2, _Apc.PowerMonitorApcTableHeader)
              }), (0, _type.isDataForApc)(data) && (0, _inferno.createComponentVNode)(2, _Apc.PowerMonitorApcTableRows, {
                "search": search
              }), (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
                "header": true,
                children: (0, _type.isDataForSmes)(data) && (0, _inferno.createComponentVNode)(2, _Smes.PowerMonitorSmesTableHeader)
              }), (0, _type.isDataForSmes)(data) && (0, _inferno.createComponentVNode)(2, _Smes.PowerMonitorSmesTableRows, {
                "search": search
              })]
            })
          })
        })]
      })
    })
  });
};

exports.PowerMonitor = PowerMonitor;

/***/ }),

/***/ "./packages/tgui/interfaces/PowerMonitor/type.ts":
/*!*******************************************************!*\
  !*** ./packages/tgui/interfaces/PowerMonitor/type.ts ***!
  \*******************************************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.isDataForSmes = exports.isDataForApc = exports.PowerMonitorType = void 0;

/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */
var PowerMonitorType;
exports.PowerMonitorType = PowerMonitorType;

(function (PowerMonitorType) {
  PowerMonitorType["Apc"] = "apc";
  PowerMonitorType["Smes"] = "smes";
})(PowerMonitorType || (exports.PowerMonitorType = PowerMonitorType = {}));

var isDataForApc = function isDataForApc(data) {
  return data.type === PowerMonitorType.Apc;
};

exports.isDataForApc = isDataForApc;

var isDataForSmes = function isDataForSmes(data) {
  return data.type === PowerMonitorType.Smes;
};

exports.isDataForSmes = isDataForSmes;

/***/ }),

/***/ "./packages/tgui/interfaces/PowerTransmissionLaser.js":
/*!************************************************************!*\
  !*** ./packages/tgui/interfaces/PowerTransmissionLaser.js ***!
  \************************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.PowerTransmissionLaser = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _format = __webpack_require__(/*! ../format */ "./packages/tgui/format.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

/**
 * @file
 * @copyright 2020
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */
var PowerTransmissionLaser = function PowerTransmissionLaser(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data;

  var lifetimeEarnings = data.lifetimeEarnings,
      _data$name = data.name,
      name = _data$name === void 0 ? 'Power Transmission Laser' : _data$name;
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "title": name,
    "width": "310",
    "height": "485",
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: [(0, _inferno.createComponentVNode)(2, Status), (0, _inferno.createComponentVNode)(2, InputControls), (0, _inferno.createComponentVNode)(2, OutputControls), (0, _inferno.createComponentVNode)(2, _components.NoticeBox, {
        "success": true,
        children: ["Earned Credits : ", (0, _format.formatMoney)(lifetimeEarnings)]
      })]
    })
  });
};

exports.PowerTransmissionLaser = PowerTransmissionLaser;

var Status = function Status(props, context) {
  var _useBackend2 = (0, _backend.useBackend)(context),
      data = _useBackend2.data;

  var capacity = data.capacity,
      charge = data.charge,
      gridLoad = data.gridLoad,
      totalGridPower = data.totalGridPower;
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Status",
    children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Reserve Power",
        children: (0, _format.formatSiUnit)(charge, 0, 'J')
      })
    }), (0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
      "mt": "0.5em",
      "mb": "0.5em",
      "ranges": {
        good: [0.8, Infinity],
        average: [0.5, 0.8],
        bad: [-Infinity, 0.5]
      },
      "value": charge / capacity
    }), (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Grid Saturation"
      })
    }), (0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
      "mt": "0.5em",
      "ranges": {
        good: [0.8, Infinity],
        average: [0.5, 0.8],
        bad: [-Infinity, 0.5]
      },
      "value": gridLoad / totalGridPower
    })]
  });
};

var InputControls = function InputControls(props, context) {
  var _useBackend3 = (0, _backend.useBackend)(context),
      act = _useBackend3.act,
      data = _useBackend3.data;

  var isChargingEnabled = data.isChargingEnabled,
      excessPower = data.excessPower,
      isCharging = data.isCharging,
      inputLevel = data.inputLevel,
      inputNumber = data.inputNumber,
      inputMultiplier = data.inputMultiplier;
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Input Controls",
    children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Input Circuit",
        "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "power-off",
          "content": isChargingEnabled ? 'Enabled' : 'Disabled',
          "color": isChargingEnabled ? 'green' : 'red',
          "onClick": function () {
            function onClick() {
              return act('toggleInput');
            }

            return onClick;
          }()
        }),
        children: (0, _inferno.createComponentVNode)(2, _components.Box, {
          "color": isCharging && 'good' || isChargingEnabled && 'average' || 'bad',
          children: isCharging && 'Online' || isChargingEnabled && 'Idle' || 'Offline'
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Input Level",
        children: (0, _format.formatPower)(inputLevel)
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Optimal",
        children: (0, _format.formatPower)(excessPower)
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      "mt": "0.5em",
      children: [(0, _inferno.createComponentVNode)(2, _components.Knob, {
        "mr": "0.5em",
        "animated": true,
        "size": 1.25,
        "inline": true,
        "step": 5,
        "stepPixelSize": 2,
        "minValue": 0,
        "maxValue": 999,
        "value": inputNumber,
        "onDrag": function () {
          function onDrag(e, setInput) {
            return act('setInput', {
              setInput: setInput
            });
          }

          return onDrag;
        }()
      }), (0, _inferno.createComponentVNode)(2, _components.Button, {
        "content": 'W',
        "selected": inputMultiplier === 1,
        "onClick": function () {
          function onClick() {
            return act('inputW');
          }

          return onClick;
        }()
      }), (0, _inferno.createComponentVNode)(2, _components.Button, {
        "content": 'kW',
        "selected": inputMultiplier === Math.pow(10, 3),
        "onClick": function () {
          function onClick() {
            return act('inputkW');
          }

          return onClick;
        }()
      }), (0, _inferno.createComponentVNode)(2, _components.Button, {
        "content": 'MW',
        "selected": inputMultiplier === Math.pow(10, 6),
        "onClick": function () {
          function onClick() {
            return act('inputMW');
          }

          return onClick;
        }()
      }), (0, _inferno.createComponentVNode)(2, _components.Button, {
        "content": 'GW',
        "selected": inputMultiplier === Math.pow(10, 9),
        "onClick": function () {
          function onClick() {
            return act('inputGW');
          }

          return onClick;
        }()
      }), (0, _inferno.createComponentVNode)(2, _components.Button, {
        "content": 'TW',
        "selected": inputMultiplier === Math.pow(10, 12),
        "onClick": function () {
          function onClick() {
            return act('inputTW');
          }

          return onClick;
        }()
      })]
    })]
  });
};

var OutputControls = function OutputControls(props, context) {
  var _useBackend4 = (0, _backend.useBackend)(context),
      act = _useBackend4.act,
      data = _useBackend4.data;

  var isEmagged = data.isEmagged,
      isFiring = data.isFiring,
      isLaserEnabled = data.isLaserEnabled,
      outputLevel = data.outputLevel,
      outputNumber = data.outputNumber,
      outputMultiplier = data.outputMultiplier;
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Output Controls",
    children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Laser Circuit",
        "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "power-off",
          "content": isLaserEnabled ? 'Enabled' : 'Disabled',
          "color": isLaserEnabled ? 'green' : 'red',
          "onClick": function () {
            function onClick() {
              return act('toggleOutput');
            }

            return onClick;
          }()
        }),
        children: (0, _inferno.createComponentVNode)(2, _components.Box, {
          "color": isFiring && 'good' || isLaserEnabled && 'average' || 'bad',
          children: isFiring && 'Online' || isLaserEnabled && 'Idle' || 'Offline'
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Output Level",
        children: outputNumber < 0 ? '-' + (0, _format.formatPower)(Math.abs(outputLevel)) : (0, _format.formatPower)(outputLevel)
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      "mt": "0.5em",
      children: [(0, _inferno.createComponentVNode)(2, _components.Knob, {
        "mr": "0.5em",
        "size": 1.25,
        "animated": true,
        "bipolar": isEmagged,
        "inline": true,
        "step": 5,
        "stepPixelSize": 2,
        "minValue": isEmagged ? -999 : 0,
        "maxValue": 999,
        "ranges": {
          bad: [-Infinity, -1]
        },
        "value": outputNumber,
        "onDrag": function () {
          function onDrag(e, setOutput) {
            return act('setOutput', {
              setOutput: setOutput
            });
          }

          return onDrag;
        }()
      }), (0, _inferno.createComponentVNode)(2, _components.Button, {
        "content": 'MW',
        "selected": outputMultiplier === Math.pow(10, 6),
        "onClick": function () {
          function onClick() {
            return act('outputMW');
          }

          return onClick;
        }()
      }), (0, _inferno.createComponentVNode)(2, _components.Button, {
        "content": 'GW',
        "selected": outputMultiplier === Math.pow(10, 9),
        "onClick": function () {
          function onClick() {
            return act('outputGW');
          }

          return onClick;
        }()
      }), (0, _inferno.createComponentVNode)(2, _components.Button, {
        "content": 'TW',
        "selected": outputMultiplier === Math.pow(10, 12),
        "onClick": function () {
          function onClick() {
            return act('outputTW');
          }

          return onClick;
        }()
      })]
    })]
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/Pressurizer.js":
/*!*************************************************!*\
  !*** ./packages/tgui/interfaces/Pressurizer.js ***!
  \*************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Pressurizer = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var _PortableAtmos = __webpack_require__(/*! ./common/PortableAtmos */ "./packages/tgui/interfaces/common/PortableAtmos.js");

/**
 * Copyright (c) 2021 @Azrun
 * SPDX-License-Identifier: MIT
 */
var FanState = {
  Off: 0,
  In: 1,
  Out: 2
};
var GaugeRanges = {
  good: [1, Infinity],
  average: [0.75, 1],
  bad: [-Infinity, 0.75]
};

var Pressurizer = function Pressurizer(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var airSafe = data.airSafe,
      blastArmed = data.blastArmed,
      blastDelay = data.blastDelay,
      connected = data.connected,
      emagged = data.emagged,
      fanState = data.fanState,
      materialsCount = data.materialsCount,
      materialsProgress = data.materialsProgress,
      maxArmDelay = data.maxArmDelay,
      maxPressure = data.maxPressure,
      maxRelease = data.maxRelease,
      minArmDelay = data.minArmDelay,
      minBlastPercent = data.minBlastPercent,
      minRelease = data.minRelease,
      pressure = data.pressure,
      processRate = data.processRate,
      releasePressure = data.releasePressure;

  var handleSetPressure = function handleSetPressure(releasePressure) {
    act("set-pressure", {
      releasePressure: releasePressure
    });
  };

  var handleSetBlastDelay = function handleSetBlastDelay(blastDelay) {
    act("set-blast-delay", {
      blastDelay: blastDelay
    });
  };

  var handleSetProcessRate = function handleSetProcessRate(processRate) {
    act("set-process_rate", {
      processRate: processRate
    });
  };

  var handleSetFan = function handleSetFan(fanState) {
    act("fan", {
      fanState: fanState
    });
  };

  var hasSufficientPressure = pressure < maxPressure * minBlastPercent;

  var getArmedState = function getArmedState() {
    if (hasSufficientPressure) {
      return "Insufficient Pressure";
    }

    if (!airSafe) {
      return "AIR UNSAFE - Locked";
    }

    if (blastArmed) {
      return "Armed";
    }

    return "Ready";
  };

  var handleEjectContents = function handleEjectContents() {
    act("eject-materials");
  };

  var handleArmPressurizer = function handleArmPressurizer() {
    act("arm");
  };

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "theme": emagged ? 'syndicate' : 'ntos',
    "width": 390,
    "height": 380,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: [(0, _inferno.createComponentVNode)(2, _PortableAtmos.PortableBasicInfo, {
        "connected": connected,
        "pressure": pressure,
        "maxPressure": maxPressure,
        children: [(0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Emergency Blast Release",
            children: (0, _inferno.createComponentVNode)(2, _components.Button, {
              "fluid": true,
              "textAlign": "center",
              "icon": "circle",
              "content": getArmedState(),
              "disabled": hasSufficientPressure || !airSafe,
              "color": blastArmed ? 'bad' : 'average',
              "onClick": function () {
                function onClick() {
                  return handleArmPressurizer();
                }

                return onClick;
              }()
            })
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Delay",
            children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
              "onClick": function () {
                function onClick() {
                  return handleSetBlastDelay(minArmDelay);
                }

                return onClick;
              }(),
              children: "Min"
            }), (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
              "animated": true,
              "width": "7em",
              "value": blastDelay,
              "minValue": minArmDelay,
              "maxValue": maxArmDelay,
              "onChange": function () {
                function onChange(e, targetDelay) {
                  return handleSetBlastDelay(targetDelay);
                }

                return onChange;
              }()
            }), (0, _inferno.createComponentVNode)(2, _components.Button, {
              "onClick": function () {
                function onClick() {
                  return handleSetBlastDelay(maxArmDelay);
                }

                return onClick;
              }(),
              children: "Max"
            })]
          })]
        }), (0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Fan Status",
            children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
              "color": fanState === FanState.Off ? 'bad' : 'default',
              "onClick": function () {
                function onClick() {
                  return handleSetFan(FanState.Off);
                }

                return onClick;
              }(),
              children: "Off"
            }), (0, _inferno.createComponentVNode)(2, _components.Button, {
              "selected": fanState === FanState.In,
              "onClick": function () {
                function onClick() {
                  return handleSetFan(FanState.In);
                }

                return onClick;
              }(),
              children: "In"
            }), (0, _inferno.createComponentVNode)(2, _components.Button, {
              "selected": fanState === FanState.Out,
              "onClick": function () {
                function onClick() {
                  return handleSetFan(FanState.Out);
                }

                return onClick;
              }(),
              children: "Out"
            })]
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Release Pressure",
            children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
              "onClick": function () {
                function onClick() {
                  return handleSetPressure(minRelease);
                }

                return onClick;
              }(),
              children: "Min"
            }), (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
              "animated": true,
              "width": "7em",
              "value": releasePressure,
              "minValue": minRelease,
              "maxValue": maxRelease,
              "onChange": function () {
                function onChange(e, targetPressure) {
                  return handleSetPressure(targetPressure);
                }

                return onChange;
              }()
            }), (0, _inferno.createComponentVNode)(2, _components.Button, {
              "onClick": function () {
                function onClick() {
                  return handleSetPressure(maxRelease);
                }

                return onClick;
              }(),
              children: "Max"
            })]
          })]
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Material Processing",
        "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "eject",
          "disabled": materialsCount === 0,
          "onClick": function () {
            function onClick() {
              return handleEjectContents();
            }

            return onClick;
          }(),
          children: "Eject"
        }),
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Speed",
            children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
              "selected": processRate === 1,
              "onClick": function () {
                function onClick() {
                  return handleSetProcessRate(1);
                }

                return onClick;
              }(),
              children: "1"
            }), (0, _inferno.createComponentVNode)(2, _components.Button, {
              "selected": processRate === 2,
              "onClick": function () {
                function onClick() {
                  return handleSetProcessRate(2);
                }

                return onClick;
              }(),
              children: "2"
            }), (0, _inferno.createComponentVNode)(2, _components.Button, {
              "selected": processRate === 3,
              "onClick": function () {
                function onClick() {
                  return handleSetProcessRate(3);
                }

                return onClick;
              }(),
              children: "3"
            }), !!emagged && (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
              "selected": processRate === 4,
              "onClick": function () {
                function onClick() {
                  return handleSetProcessRate(4);
                }

                return onClick;
              }(),
              children: "4"
            }), (0, _inferno.createComponentVNode)(2, _components.Button, {
              "selected": processRate === 5,
              "onClick": function () {
                function onClick() {
                  return handleSetProcessRate(5);
                }

                return onClick;
              }(),
              children: "5"
            })], 4)]
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Progress",
            children: (0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
              "ranges": GaugeRanges,
              "value": materialsProgress / 100
            })
          })]
        })
      })]
    })
  });
};

exports.Pressurizer = Pressurizer;

/***/ }),

/***/ "./packages/tgui/interfaces/Radio/index.tsx":
/*!**************************************************!*\
  !*** ./packages/tgui/interfaces/Radio/index.tsx ***!
  \**************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Radio = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _format = __webpack_require__(/*! ../../format */ "./packages/tgui/format.js");

var _layouts = __webpack_require__(/*! ../../layouts */ "./packages/tgui/layouts/index.js");

var _type = __webpack_require__(/*! ./type */ "./packages/tgui/interfaces/Radio/type.ts");

/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */
var MIN_FREQ = 1441;
var MAX_FREQ = 1489;

var Radio = function Radio(_props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data,
      act = _useBackend.act;

  var setFrequency = function setFrequency(value, finish) {
    act('set-frequency', {
      value: value,
      finish: finish
    });
  };

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": "280",
    "height": "400",
    "title": data.name,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
        "vertical": true,
        "fill": true,
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
              children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
                "label": "Microphone",
                children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
                  "checked": data.broadcasting,
                  "onClick": function () {
                    function onClick() {
                      return act('toggle-broadcasting');
                    }

                    return onClick;
                  }(),
                  children: data.broadcasting ? 'Engaged' : 'Disengaged'
                })
              }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
                "label": "Speaker",
                children: (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
                  "checked": data.listening,
                  "onClick": function () {
                    function onClick() {
                      return act('toggle-listening');
                    }

                    return onClick;
                  }(),
                  children: data.listening ? 'Engaged' : 'Disengaged'
                })
              }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
                "label": "Frequency",
                children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
                  "align": "center",
                  children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                    children: !data.lockedFrequency && (0, _inferno.createComponentVNode)(2, _components.Knob, {
                      "animated": true,
                      "value": data.frequency,
                      "minValue": MIN_FREQ,
                      "maxValue": MAX_FREQ,
                      "stepPixelSize": 2,
                      "format": _format.formatFrequency,
                      "onDrag": function () {
                        function onDrag(_e, value) {
                          return setFrequency(value, false);
                        }

                        return onDrag;
                      }(),
                      "onChange": function () {
                        function onChange(_e, value) {
                          return setFrequency(value, true);
                        }

                        return onChange;
                      }()
                    })
                  }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                    children: (0, _inferno.createComponentVNode)(2, _components.AnimatedNumber, {
                      "value": data.frequency,
                      "format": _format.formatFrequency
                    })
                  })]
                })
              })]
            })
          })
        }), data.secureFrequencies.length > 0 && (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          "grow": 1,
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "title": "Supplementary Channels",
            "fill": true,
            "scrollable": true,
            children: (0, _inferno.createComponentVNode)(2, _components.Table, {
              children: [(0, _inferno.createComponentVNode)(2, _components.Table.Row, {
                "header": true,
                children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
                  "header": true,
                  children: "Channel"
                }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
                  "header": true,
                  children: "Frequency"
                }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
                  "header": true,
                  children: "Prefix"
                })]
              }), data.secureFrequencies.map(function (freq) {
                return (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
                  children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
                    children: freq.channel
                  }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
                    children: freq.frequency
                  }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
                    children: (0, _inferno.createComponentVNode)(2, _components.Box, {
                      "as": "code",
                      children: freq.sayToken
                    })
                  })]
                }, freq.frequency);
              })]
            })
          })
        }), !!data.modifiable && (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "title": "Access Panel",
            children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
              children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
                "label": "Green Wire",
                "labelColor": "green",
                children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                  "color": "green",
                  "onClick": function () {
                    function onClick() {
                      return act('toggle-wire', {
                        wire: _type.RadioWires.Transmit
                      });
                    }

                    return onClick;
                  }(),
                  children: data.wires & _type.RadioWires.Transmit ? 'Cut' : 'Mend'
                })
              }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
                "label": "Red Wire",
                "labelColor": "red",
                children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                  "color": "red",
                  "onClick": function () {
                    function onClick() {
                      return act('toggle-wire', {
                        wire: _type.RadioWires.Receive
                      });
                    }

                    return onClick;
                  }(),
                  children: data.wires & _type.RadioWires.Receive ? 'Cut' : 'Mend'
                })
              }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
                "label": "Blue Wire",
                "labelColor": "blue",
                children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                  "color": "blue",
                  "onClick": function () {
                    function onClick() {
                      return act('toggle-wire', {
                        wire: _type.RadioWires.Signal
                      });
                    }

                    return onClick;
                  }(),
                  children: data.wires & _type.RadioWires.Signal ? 'Cut' : 'Mend'
                })
              })]
            })
          })
        })]
      })
    })
  });
};

exports.Radio = Radio;

/***/ }),

/***/ "./packages/tgui/interfaces/Radio/type.ts":
/*!************************************************!*\
  !*** ./packages/tgui/interfaces/Radio/type.ts ***!
  \************************************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.RadioWires = void 0;

/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */
var RadioWires;
exports.RadioWires = RadioWires;

(function (RadioWires) {
  RadioWires[RadioWires["Signal"] = 1] = "Signal";
  RadioWires[RadioWires["Receive"] = 2] = "Receive";
  RadioWires[RadioWires["Transmit"] = 4] = "Transmit";
})(RadioWires || (exports.RadioWires = RadioWires = {}));

/***/ }),

/***/ "./packages/tgui/interfaces/ReagentExtractor.js":
/*!******************************************************!*\
  !*** ./packages/tgui/interfaces/ReagentExtractor.js ***!
  \******************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ReagentExtractor = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var _ReagentInfo = __webpack_require__(/*! ./common/ReagentInfo.js */ "./packages/tgui/interfaces/common/ReagentInfo.js");

// Feel free to adjust this for performance
var extractablesPerPage = 25;

var clamp = function clamp(value, min, max) {
  return Math.min(Math.max(min, value), max);
};

var noContainer = {
  name: "No Beaker Inserted",
  id: "inserted",
  maxVolume: 100,
  totalVolume: 0,
  fake: true
};

var ReagentExtractor = function ReagentExtractor(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data;

  var containersData = data.containersData;
  var inserted = containersData.inserted,
      storage_tank_1 = containersData.storage_tank_1,
      storage_tank_2 = containersData.storage_tank_2;
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "title": "Reagent Extractor",
    "width": 500,
    "height": 739,
    "theme": "ntos",
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
        "vertical": true,
        "fill": true,
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          "basis": 19.5,
          children: (0, _inferno.createComponentVNode)(2, ReagentDisplay, {
            "container": inserted,
            "insertable": true
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          "grow": true,
          children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
            "fill": true,
            children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
              "grow": true,
              children: (0, _inferno.createComponentVNode)(2, ExtractableList)
            }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
              "basis": 18,
              children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
                "vertical": true,
                "fill": true,
                children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  "basis": 19.5,
                  "grow": true,
                  children: (0, _inferno.createComponentVNode)(2, ReagentDisplay, {
                    "container": storage_tank_1
                  })
                }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
                  "basis": 19.5,
                  children: (0, _inferno.createComponentVNode)(2, ReagentDisplay, {
                    "container": storage_tank_2
                  })
                })]
              })
            })]
          })
        })]
      })
    })
  });
};

exports.ReagentExtractor = ReagentExtractor;

var ReagentDisplay = function ReagentDisplay(props, context) {
  var _useBackend2 = (0, _backend.useBackend)(context),
      act = _useBackend2.act;

  var insertable = props.insertable;
  var container = props.container || noContainer;

  var _useSharedState = (0, _backend.useSharedState)(context, "transferAmount_" + container.id, 10),
      transferAmount = _useSharedState[0],
      setTransferAmount = _useSharedState[1];

  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": (0, _inferno.createComponentVNode)(2, _components.Flex, {
      "inline": true,
      "nowrap": true,
      children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "grow": true,
        "overflow": "hidden",
        "style": {
          "text-overflow": "ellipsis",
          "text-transform": "capitalize"
        },
        children: container.name
      }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "px": 4
      }), " "]
    }),
    "buttons": (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
      "tooltip": "Flush All",
      "icon": "times",
      "color": "red",
      "disabled": !container.totalVolume,
      "onClick": function () {
        function onClick() {
          return act('flush', {
            container_id: container.id
          });
        }

        return onClick;
      }()
    }), !insertable || (0, _inferno.createComponentVNode)(2, _components.Button, {
      "tooltip": "Eject",
      "icon": "eject",
      "disabled": !props.container,
      "onClick": function () {
        function onClick() {
          return act('ejectcontainer');
        }

        return onClick;
      }()
    })], 0),
    children: [!!props.container || (0, _inferno.createComponentVNode)(2, _components.Dimmer, {
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "eject",
        "fontSize": 1.5,
        "onClick": function () {
          function onClick() {
            return act('insertcontainer');
          }

          return onClick;
        }(),
        "bold": true,
        children: "Insert Beaker"
      })
    }), (0, _inferno.createComponentVNode)(2, _ReagentInfo.ReagentGraph, {
      "container": container
    }), (0, _inferno.createComponentVNode)(2, _ReagentInfo.ReagentList, {
      "container": container,
      "renderButtons": function () {
        function renderButtons(reagent) {
          return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
            "px": 0.75,
            "mr": 1.5,
            "icon": "filter",
            "color": "red",
            "tooltip": "Isolate",
            "onClick": function () {
              function onClick() {
                return act('isolate', {
                  container_id: container.id,
                  reagent_id: reagent.id
                });
              }

              return onClick;
            }()
          }), (0, _inferno.createComponentVNode)(2, _components.Button, {
            "px": 0.75,
            "icon": "times",
            "color": "red",
            "tooltip": "Flush",
            "onClick": function () {
              function onClick() {
                return act('flush_reagent', {
                  container_id: container.id,
                  reagent_id: reagent.id
                });
              }

              return onClick;
            }()
          })], 4);
        }

        return renderButtons;
      }()
    }), (0, _inferno.createComponentVNode)(2, _components.Flex, {
      "wrap": true,
      "justify": "center",
      children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "grow": true
      }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "grow": true,
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "mb": 0.5,
          "width": 17,
          "textAlign": "center",
          "selected": container.selected,
          "tooltip": "Select Extraction and Transfer Target",
          "icon": container.selected ? "check-square-o" : "square-o",
          "onClick": function () {
            function onClick() {
              return act('extractto', {
                container_id: container.id
              });
            }

            return onClick;
          }(),
          children: "Select"
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
          "width": 17,
          children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "grow": true,
            children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
              "disabled": container.selected,
              "onClick": function () {
                function onClick() {
                  return act('chemtransfer', {
                    container_id: container.id,
                    amount: transferAmount
                  });
                }

                return onClick;
              }(),
              children: "Transfer"
            }), (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
              "value": transferAmount,
              "format": function () {
                function format(value) {
                  return value + "u";
                }

                return format;
              }(),
              "minValue": 1,
              "maxValue": 500,
              "onDrag": function () {
                function onDrag(e, value) {
                  return setTransferAmount(value);
                }

                return onDrag;
              }()
            })]
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            children: (0, _inferno.createComponentVNode)(2, _components.Button, {
              "disabled": container.selected,
              "onClick": function () {
                function onClick() {
                  return act('chemtransfer', {
                    container_id: container.id,
                    amount: 500
                  });
                }

                return onClick;
              }(),
              children: "Transfer All"
            })
          })]
        })
      })]
    })]
  });
};

var ExtractableList = function ExtractableList(props, context) {
  var _useBackend3 = (0, _backend.useBackend)(context),
      act = _useBackend3.act,
      data = _useBackend3.data;

  var autoextract = data.autoextract;
  var extractables = data.ingredientsData || [];

  var _useLocalState = (0, _backend.useLocalState)(context, 'page', 1),
      page = _useLocalState[0],
      setPage = _useLocalState[1];

  var totalPages = Math.max(1, Math.ceil(extractables.length / extractablesPerPage));
  if (page < 1 || page > totalPages) setPage(clamp(page, 1, totalPages));
  var extractablesOnPage = extractables.slice(extractablesPerPage * (page - 1), extractablesPerPage * (page - 1) + extractablesPerPage);
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "fill": true,
    "title": "Extractable Items",
    "buttons": (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
      "checked": autoextract,
      "tooltip": "Items will be extracted into the selected container automatically upon insertion.",
      "onClick": function () {
        function onClick() {
          return act('autoextract');
        }

        return onClick;
      }(),
      children: "Auto-Extract"
    }),
    children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
      "height": "100%",
      "direction": "column",
      children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "grow": true,
        children: (0, _inferno.createComponentVNode)(2, _components.Section, {
          "scrollable": true,
          "fill": true,
          children: extractablesOnPage.map(function (extractable, index) {
            return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Flex, {
              children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                "grow": true,
                children: extractable.name
              }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                "nowrap": true,
                children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
                  "onClick": function () {
                    function onClick() {
                      return act('extractingredient', {
                        ingredient_id: extractable.id
                      });
                    }

                    return onClick;
                  }(),
                  children: "Extract"
                }), (0, _inferno.createComponentVNode)(2, _components.Button, {
                  "icon": "eject",
                  "tooltip": "Eject",
                  "onClick": function () {
                    function onClick() {
                      return act('ejectingredient', {
                        ingredient_id: extractable.id
                      });
                    }

                    return onClick;
                  }()
                })]
              })]
            }), (0, _inferno.createComponentVNode)(2, _components.Divider)], 4, extractable.id);
          })
        })
      }), totalPages < 2 || (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "textAlign": "center",
        "basis": 1.5,
        children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "caret-left",
          "tooltip": "Previous Page",
          "disabled": page < 2,
          "onClick": function () {
            function onClick() {
              return setPage(page - 1);
            }

            return onClick;
          }()
        }), (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
          "value": page,
          "format": function () {
            function format(value) {
              return "Page " + value + "/" + totalPages;
            }

            return format;
          }(),
          "minValue": 1,
          "maxValue": totalPages,
          "stepPixelSize": 15,
          "onChange": function () {
            function onChange(e, value) {
              return setPage(value);
            }

            return onChange;
          }()
        }), (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "caret-right",
          "tooltip": "Next Page",
          "disabled": page > totalPages - 1,
          "onClick": function () {
            function onClick() {
              return setPage(page + 1);
            }

            return onClick;
          }()
        })]
      })]
    })
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/Rockbox.js":
/*!*********************************************!*\
  !*** ./packages/tgui/interfaces/Rockbox.js ***!
  \*********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Rockbox = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _Button = __webpack_require__(/*! ../components/Button */ "./packages/tgui/components/Button.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var Rockbox = function Rockbox(_props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var amount = data.amount,
      forSale = data.forSale,
      name = data.name,
      price = data.price,
      stats = data.stats;

  var _useLocalState = (0, _backend.useLocalState)(context, 'takeAmount', 1),
      takeAmount = _useLocalState[0],
      setTakeAmount = _useLocalState[1];

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "title": "Rockbox",
    "width": 375,
    "height": 400,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
        "vertical": true,
        "fill": true,
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "fill": true,
            children: (0, _inferno.createComponentVNode)(2, _components.Box, {
              children: ["Amount to eject: ", (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
                "value": takeAmount,
                "width": 4,
                "minValue": 1,
                "onDrag": function () {
                  function onDrag(e, value) {
                    return setTakeAmount(value);
                  }

                  return onDrag;
                }(),
                "onChange": function () {
                  function onChange(e, value) {
                    return setTakeAmount(value);
                  }

                  return onChange;
                }()
              })]
            })
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          "grow": 1,
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "fill": true,
            "scrollable": true,
            children: data.ores.length ? (0, _inferno.createComponentVNode)(2, _components.Box, {
              children: data.ores.map(function (currentOre) {
                return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Tooltip, {
                  "position": "bottom",
                  "content": currentOre.stats,
                  children: (0, _inferno.createComponentVNode)(2, _components.Table, {
                    children: (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
                      children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
                        children: (0, _inferno.createComponentVNode)(2, _components.Box, {
                          children: currentOre.name + ": " + currentOre.amount
                        })
                      }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
                        "textAlign": "right",
                        children: (0, _inferno.createComponentVNode)(2, _components.Box, {
                          children: ['Price: ', (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
                            "value": currentOre.price,
                            "width": 4,
                            "minValue": 0,
                            "format": function () {
                              function format(value) {
                                return "$" + value;
                              }

                              return format;
                            }(),
                            "onChange": function () {
                              function onChange(e, value) {
                                return act('set-ore-price', {
                                  newPrice: value,
                                  ore: currentOre.name
                                });
                              }

                              return onChange;
                            }()
                          }), (0, _inferno.createComponentVNode)(2, _Button.ButtonCheckbox, {
                            "content": "For Sale",
                            "color": currentOre.forSale ? 'green' : 'red',
                            "checked": currentOre.forSale,
                            "onClick": function () {
                              function onClick() {
                                return act('toggle-ore-sell-status', {
                                  ore: currentOre.name
                                });
                              }

                              return onClick;
                            }()
                          }), (0, _inferno.createComponentVNode)(2, _components.Button, {
                            "color": currentOre.amount < takeAmount ? 'orange' : 'default',
                            "disabled": currentOre.amount === 0,
                            "onClick": function () {
                              function onClick() {
                                return act('dispense-ore', {
                                  ore: currentOre.name,
                                  take: takeAmount
                                });
                              }

                              return onClick;
                            }(),
                            children: "Eject"
                          })]
                        })
                      })]
                    })
                  })
                }), (0, _inferno.createComponentVNode)(2, _components.Divider)], 4, currentOre.name);
              })
            }) : (0, _inferno.createComponentVNode)(2, _components.Box, {
              children: "No ores stored"
            })
          })
        })]
      })
    })
  });
};

exports.Rockbox = Rockbox;

/***/ }),

/***/ "./packages/tgui/interfaces/SeedFabricator.js":
/*!****************************************************!*\
  !*** ./packages/tgui/interfaces/SeedFabricator.js ***!
  \****************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.SeedFabricator = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var _stringUtils = __webpack_require__(/*! ./common/stringUtils */ "./packages/tgui/interfaces/common/stringUtils.js");

var DefaultSort = {
  Fruit: 1,
  Vegetable: 2,
  Herb: 3,
  Flower: 4,
  Miscellaneous: 5,
  Other: 6
};

var categorySorter = function categorySorter(a, b) {
  return (DefaultSort[a.name] || DefaultSort.Other) - (DefaultSort[b.name] || DefaultSort.Other);
};

var SeedFabricator = function SeedFabricator(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data;

  var canVend = data.canVend,
      isWorking = data.isWorking,
      maxSeed = data.maxSeed,
      name = data.name,
      seedCount = data.seedCount;
  var categories = data.seedCategories || [];
  categories.sort(categorySorter);

  var _useLocalState = (0, _backend.useLocalState)(context, 'dispenseAmount', 1),
      dispenseAmount = _useLocalState[0],
      setDispenseAmount = _useLocalState[1];

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "title": name,
    "width": 500,
    "height": 600,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: [!isWorking && (0, _inferno.createComponentVNode)(2, _components.Modal, {
        "textAlign": "center",
        "width": 35,
        "height": 10,
        "fontSize": 3,
        "fontFamily": "Courier",
        "color": "red",
        children: [(0, _inferno.createComponentVNode)(2, _components.Blink, {
          "time": 500,
          children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
            "name": "exclamation-triangle",
            "pr": 1.5
          }), "MALFUNCTION", (0, _inferno.createComponentVNode)(2, _components.Icon, {
            "name": "exclamation-triangle",
            "pl": 1.5
          })]
        }), "CHECK WIRES"]
      }), (0, _inferno.createComponentVNode)(2, _components.Section, {
        children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "bold": true,
            "pr": 1,
            children: "Dispense:"
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "basis": 6,
            "grow": true,
            children: (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
              "value": dispenseAmount,
              "format": function () {
                function format(value) {
                  return value + (0, _stringUtils.pluralize)(" seed", value);
                }

                return format;
              }(),
              "minValue": 1,
              "maxValue": 10,
              "onDrag": function () {
                function onDrag(e, value) {
                  return setDispenseAmount(value);
                }

                return onDrag;
              }()
            })
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "grow": 2,
            children: (0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
              "value": Math.max(0, maxSeed - seedCount),
              "maxValue": maxSeed,
              "ranges": {
                yellow: [5, Infinity],
                bad: [-Infinity, 5]
              },
              children: (0, _inferno.createComponentVNode)(2, _components.Icon, {
                "name": "bolt"
              })
            })
          })]
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Section, {
        children: [!canVend && (0, _inferno.createComponentVNode)(2, _components.Modal, {
          "textAlign": "center",
          "width": 25,
          "height": 5,
          "fontSize": 2,
          "fontFamily": "Courier",
          "color": "yellow",
          children: [(0, _inferno.createComponentVNode)(2, _components.Blink, {
            "interval": 500,
            "time": 500,
            children: (0, _inferno.createComponentVNode)(2, _components.Icon, {
              "name": "bolt",
              "pr": 1.5
            })
          }), "UNIT RECHARGING"]
        }), categories.map(function (category, index) {
          return (0, _inferno.createComponentVNode)(2, SeedCategory, {
            "category": category,
            "dispenseAmount": dispenseAmount
          }, category.name);
        })]
      })]
    })
  });
};

exports.SeedFabricator = SeedFabricator;

var seedsSorter = function seedsSorter(a, b) {
  return a.name.localeCompare(b.name);
};

var SeedCategory = function SeedCategory(props, context) {
  var _useBackend2 = (0, _backend.useBackend)(context),
      act = _useBackend2.act;

  var category = props.category,
      dispenseAmount = props.dispenseAmount;
  var name = category.name,
      seeds = category.seeds;
  if (!seeds) return false;
  seeds.sort(seedsSorter);
  return (0, _inferno.createComponentVNode)(2, _components.Collapsible, {
    "title": name,
    children: seeds.map(function (seed) {
      return (0, _inferno.createComponentVNode)(2, _components.Box, {
        "as": "span",
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "width": "155px",
          "height": "32px",
          "px": 0,
          "m": 0.25,
          "onClick": function () {
            function onClick() {
              return act('disp', {
                path: seed.path,
                amount: dispenseAmount
              });
            }

            return onClick;
          }(),
          children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
            "direction": "row",
            "align": "center",
            children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
              children: seed.img ? (0, _inferno.createVNode)(1, "img", null, null, 1, {
                "style": {
                  'vertical-align': 'middle',
                  'horizontal-align': 'middle'
                },
                "height": "32px",
                "width": "32px",
                "src": "data:image/png;base64," + seed.img
              }) : (0, _inferno.createComponentVNode)(2, _components.Icon, {
                "style": {
                  'vertical-align': 'middle',
                  'horizontal-align': 'middle'
                },
                "height": "32px",
                "width": "32px",
                "name": "question-circle-o",
                "pl": "8px",
                "pt": "4px",
                "fontSize": "24px"
              })
            }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
              "overflow": "hidden",
              "style": {
                'text-overflow': 'ellipsis'
              },
              "title": seed.name,
              children: seed.name
            })]
          })
        })
      }, seed.name);
    })
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/Sleeper.js":
/*!*********************************************!*\
  !*** ./packages/tgui/interfaces/Sleeper.js ***!
  \*********************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Sleeper = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

var _format = __webpack_require__(/*! ../format */ "./packages/tgui/format.js");

var _HealthStat = __webpack_require__(/*! ./common/HealthStat */ "./packages/tgui/interfaces/common/HealthStat.js");

var _occupantStatuses;

var damageNum = function damageNum(num) {
  return num <= 0 ? '0' : num.toFixed(1);
};

var OccupantStatus = {
  Conscious: 0,
  Unconscious: 1,
  Dead: 2
};
var occupantStatuses = (_occupantStatuses = {}, _occupantStatuses[OccupantStatus.Conscious] = {
  name: 'Conscious',
  color: 'good',
  icon: 'check'
}, _occupantStatuses[OccupantStatus.Unconscious] = {
  name: 'Unconscious',
  color: 'average',
  icon: 'bed'
}, _occupantStatuses[OccupantStatus.Dead] = {
  name: 'Dead',
  color: 'bad',
  icon: 'skull'
}, _occupantStatuses);

var Sleeper = function Sleeper(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data,
      act = _useBackend.act;

  var sleeperGone = data.sleeperGone,
      hasOccupant = data.hasOccupant,
      occupantStat = data.occupantStat,
      health = data.health,
      oxyDamage = data.oxyDamage,
      toxDamage = data.toxDamage,
      burnDamage = data.burnDamage,
      bruteDamage = data.bruteDamage,
      recharging = data.recharging,
      rejuvinators = data.rejuvinators,
      isTiming = data.isTiming,
      time = data.time,
      timeStarted = data.timeStarted,
      timeNow = data.timeNow,
      maxTime = data.maxTime;
  var curTime = Math.max(timeStarted ? (time || 0) + timeStarted - timeNow : time || 0, 0);
  var canInject = hasOccupant && !isTiming && !recharging && occupantStat < 2;
  var occupantStatus = occupantStatuses[occupantStat];
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "theme": "ntos",
    "width": 440,
    "height": 440,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Occupant Statistics",
        "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "eject",
          "align": "center",
          "color": "good",
          "disabled": !hasOccupant || !!isTiming,
          "onClick": function () {
            function onClick() {
              return act('eject');
            }

            return onClick;
          }(),
          children: "Eject"
        }),
        children: [!hasOccupant && (sleeperGone ? "Check connection to sleeper pod." : "The sleeper is unoccupied."), !!hasOccupant && (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Status",
            children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
              "color": occupantStatus.color,
              "name": occupantStatus.icon
            }), " ", occupantStatus.name]
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Overall Health",
            children: (0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
              "value": health,
              "ranges": {
                good: [0.9, Infinity],
                average: [0.5, 0.9],
                bad: [-Infinity, 0.5]
              }
            })
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Damage Breakdown",
            children: [(0, _inferno.createComponentVNode)(2, _HealthStat.HealthStat, {
              "inline": true,
              "align": "center",
              "type": "oxy",
              "width": 5,
              children: damageNum(oxyDamage)
            }), "/", (0, _inferno.createComponentVNode)(2, _HealthStat.HealthStat, {
              "inline": true,
              "align": "center",
              "type": "toxin",
              "width": 5,
              children: damageNum(toxDamage)
            }), "/", (0, _inferno.createComponentVNode)(2, _HealthStat.HealthStat, {
              "inline": true,
              "align": "center",
              "type": "burn",
              "width": 5,
              children: damageNum(burnDamage)
            }), "/", (0, _inferno.createComponentVNode)(2, _HealthStat.HealthStat, {
              "inline": true,
              "align": "center",
              "type": "brute",
              "width": 5,
              children: damageNum(bruteDamage)
            })]
          })]
        })]
      }), !!hasOccupant && (0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Detected Rejuvinators",
        "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "syringe",
          "align": "center",
          "color": "good",
          "disabled": !canInject,
          "onClick": function () {
            function onClick() {
              return act('inject');
            }

            return onClick;
          }(),
          children: "Inject"
        }),
        children: [(0, _inferno.createComponentVNode)(2, _components.Section, {
          "height": 10,
          "scrollable": true,
          children: !rejuvinators.length ? "No rejuvinators detected in occupant's bloodstream." : (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
            children: rejuvinators.map(function (r) {
              return (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
                "label": r.name,
                children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
                  "name": !r.od || r.volume < r.od ? 'circle' : 'skull',
                  "color": r.color
                }), ' ' + r.volume.toFixed(3), !!r.od && r.volume >= r.od && (0, _inferno.createComponentVNode)(2, _components.Box, {
                  "inline": true,
                  "color": "bad",
                  "pl": 1,
                  children: "(Overdose!)"
                })]
              }, r.name);
            })
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Box, {
          "italic": true,
          "textAlign": "center",
          "color": "label",
          "mt": 2,
          children: "Use separate reagent scanner for complete analysis."
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Occupant Alarm Clock",
        "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
          "width": 8,
          "icon": "clock",
          "align": "center",
          "color": isTiming ? 'bad' : 'good',
          "disabled": !hasOccupant || occupantStat > 1 || time <= 0,
          "onClick": function () {
            function onClick() {
              return act('timer');
            }

            return onClick;
          }(),
          children: isTiming ? 'Stop Timer' : 'Start Timer'
        }),
        children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            children: (0, _inferno.createComponentVNode)(2, _components.Knob, {
              "mr": "0.5em",
              "animated": true,
              "size": 1.25,
              "step": 5,
              "stepPixelSize": 2,
              "minValue": 0,
              "maxValue": maxTime / 10,
              "value": curTime / 10,
              "onDrag": function () {
                function onDrag(e, targetValue) {
                  return act('time_add', {
                    tp: targetValue - curTime / 10
                  });
                }

                return onDrag;
              }()
            })
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            children: (0, _inferno.createComponentVNode)(2, _components.Box, {
              "p": 1,
              "textAlign": "center",
              "backgroundColor": "black",
              "color": "good",
              "maxWidth": "90px",
              "width": "90px",
              "fontSize": "20px",
              children: (0, _inferno.createComponentVNode)(2, _components.TimeDisplay, {
                "value": curTime,
                "timing": !!isTiming,
                "format": function () {
                  function format(value) {
                    return (0, _format.formatTime)(value);
                  }

                  return format;
                }()
              })
            })
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "shrink": 1,
            children: (0, _inferno.createComponentVNode)(2, _components.Box, {
              "italic": true,
              "textAlign": "center",
              "color": "label",
              "pl": 1,
              children: "System will inject rejuvenators automatically when occupant is in hibernation."
            })
          })]
        })
      })]
    })
  });
};

exports.Sleeper = Sleeper;

/***/ }),

/***/ "./packages/tgui/interfaces/SlotMachine.js":
/*!*************************************************!*\
  !*** ./packages/tgui/interfaces/SlotMachine.js ***!
  \*************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.SlotMachine = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

/**
 * Copyright (c) 2020 @ZeWaka
 * SPDX-License-Identifier: ISC
 */
var SlotMachine = function SlotMachine(_props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data;

  var busy = data.busy,
      scannedCard = data.scannedCard;
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "title": "Slot Machine",
    "width": 375,
    "height": 220,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: !scannedCard ? (0, _inferno.createComponentVNode)(2, InsertCard) : busy ? (0, _inferno.createComponentVNode)(2, BusyWindow) : (0, _inferno.createComponentVNode)(2, SlotWindow)
    })
  });
};

exports.SlotMachine = SlotMachine;

var InsertCard = function InsertCard(_props, context) {
  var _useBackend2 = (0, _backend.useBackend)(context),
      act = _useBackend2.act;

  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.NoticeBox, {
    "danger": true,
    children: "You must insert your ID to continue!"
  }), (0, _inferno.createComponentVNode)(2, _components.Button, {
    "icon": "id-card",
    "onClick": function () {
      function onClick() {
        return act('insert_card');
      }

      return onClick;
    }(),
    children: "Insert ID"
  })], 4);
};

var SlotWindow = function SlotWindow(_props, context) {
  var _useBackend3 = (0, _backend.useBackend)(context),
      act = _useBackend3.act,
      data = _useBackend3.data;

  var account_funds = data.account_funds,
      money = data.money,
      plays = data.plays,
      scannedCard = data.scannedCard,
      wager = data.wager;
  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.NoticeBox, {
    "success": true,
    children: (0, _inferno.createVNode)(1, "marquee", null, " Wager some credits! ", 16)
  }), (0, _inferno.createComponentVNode)(2, _components.Stack, {
    "vertical": true,
    children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      children: [(0, _inferno.createVNode)(1, "strong", null, "Your card: ", 16), (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "eject",
        "content": scannedCard,
        "tooltip": "Pull Funds and Eject Card",
        "tooltipPosition": "bottom-end",
        "onClick": function () {
          function onClick() {
            return act('eject');
          }

          return onClick;
        }()
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
        "align": "center",
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createVNode)(1, "strong", null, "Account Balance:", 16)
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
            "name": "dollar-sign"
          }), ' ', account_funds]
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Button, {
            "tooltip": "Add Funds",
            "tooltipPosition": "bottom",
            "onClick": function () {
              function onClick() {
                return act('cashin');
              }

              return onClick;
            }(),
            children: "Cash In"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Button, {
            "tooltip": "Pull Funds",
            "tooltipPosition": "bottom",
            "onClick": function () {
              function onClick() {
                return act('cashout');
              }

              return onClick;
            }(),
            children: "Cash Out"
          })
        })]
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
        "align": "center",
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: "Amount Wagered:"
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
            "minValue": 20,
            "maxValue": 1000,
            "value": wager,
            "format": function () {
              function format(value) {
                return "$" + value;
              }

              return format;
            }(),
            "onDrag": function () {
              function onDrag(_e, value) {
                return act('set_wager', {
                  bet: value
                });
              }

              return onDrag;
            }()
          })
        })]
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
        "align": "center",
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createVNode)(1, "strong", null, "Credits Remaining:", 16)
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
            "name": "dollar-sign"
          }), ' ', money]
        })]
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      children: (0, _inferno.createComponentVNode)(2, _components.BlockQuote, {
        children: [plays, " attempts have been made today!"]
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Stack.Divider), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "dice",
        "tooltip": "Pull the lever",
        "tooltipPosition": "right",
        "onClick": function () {
          function onClick() {
            return act('play', {
              bet: wager
            });
          }

          return onClick;
        }(),
        children: "Play!"
      })
    })]
  })], 4);
};

var BusyWindow = function BusyWindow() {
  return (0, _inferno.createComponentVNode)(2, _components.NoticeBox, {
    "warning": true,
    children: "The Machine is busy, please wait!"
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/Smes.js":
/*!******************************************!*\
  !*** ./packages/tgui/interfaces/Smes.js ***!
  \******************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Smes = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _format = __webpack_require__(/*! ../format */ "./packages/tgui/format.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Original spookydonut (https://github.com/spookydonut)
 * @author Changes Aleksej Komarov (https://github.com/stylemistake)
 * @author Changes Sovexe (https://github.com/Sovexe)
 * @license MIT
 */
// Common power multiplier
var POWER_MUL = 1e3;

var Smes = function Smes(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var charge = data.charge,
      capacity = data.capacity,
      inputAttempt = data.inputAttempt,
      inputting = data.inputting,
      inputLevel = data.inputLevel,
      inputLevelMax = data.inputLevelMax,
      inputAvailable = data.inputAvailable,
      outputAttempt = data.outputAttempt,
      outputting = data.outputting,
      outputLevel = data.outputLevel,
      outputLevelMax = data.outputLevelMax;
  var inputState = charge / capacity >= 1 && 'good' || inputting && inputLevel && 'average' || 'bad';
  var outputState = outputAttempt && outputting && 'good' || charge > 0 && 'average' || 'bad';
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 340,
    "height": 360,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Stored Energy",
        children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Stored Energy",
            children: (0, _format.formatSiUnit)(charge, 0, 'J')
          })
        }), (0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
          "mt": "0.5em",
          "value": charge / capacity,
          "ranges": {
            good: [0.5, Infinity],
            average: [0.15, 0.5],
            bad: [-Infinity, 0.15]
          }
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Input",
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Charge Mode",
            "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": "power-off",
              "color": inputAttempt ? "green" : "red",
              "onClick": function () {
                function onClick() {
                  return act('toggle-input');
                }

                return onClick;
              }(),
              children: inputAttempt ? 'On' : 'Off'
            }),
            children: (0, _inferno.createComponentVNode)(2, _components.Box, {
              "color": inputState,
              children: charge / capacity >= 1 && 'Fully Charged' || inputAttempt && inputLevel && !inputting && 'Initializing' || inputAttempt && inputLevel && inputting && 'Charging' || inputAttempt && inputting && 'Idle' || 'Not Charging'
            })
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Target Input",
            children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
              "inline": true,
              "width": "100%",
              children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
                  "icon": "fast-backward",
                  "disabled": inputLevel === 0,
                  "onClick": function () {
                    function onClick() {
                      return act('set-input', {
                        target: 'min'
                      });
                    }

                    return onClick;
                  }()
                }), (0, _inferno.createComponentVNode)(2, _components.Button, {
                  "icon": "backward",
                  "disabled": inputLevel === 0,
                  "onClick": function () {
                    function onClick() {
                      return act('set-input', {
                        adjust: -10000
                      });
                    }

                    return onClick;
                  }()
                })]
              }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                "grow": 1,
                "mx": 1,
                children: (0, _inferno.createComponentVNode)(2, _components.Slider, {
                  "value": inputLevel / POWER_MUL,
                  "fillValue": inputAvailable / POWER_MUL,
                  "minValue": 0,
                  "maxValue": inputLevelMax / POWER_MUL,
                  "step": 5,
                  "stepPixelSize": 4,
                  "format": function () {
                    function format(value) {
                      return (0, _format.formatPower)(value * POWER_MUL, 1);
                    }

                    return format;
                  }(),
                  "onDrag": function () {
                    function onDrag(e, value) {
                      return act('set-input', {
                        target: value * POWER_MUL
                      });
                    }

                    return onDrag;
                  }()
                })
              }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
                  "icon": "forward",
                  "disabled": inputLevel === inputLevelMax,
                  "onClick": function () {
                    function onClick() {
                      return act('set-input', {
                        adjust: 10000
                      });
                    }

                    return onClick;
                  }()
                }), (0, _inferno.createComponentVNode)(2, _components.Button, {
                  "icon": "fast-forward",
                  "disabled": inputLevel === inputLevelMax,
                  "onClick": function () {
                    function onClick() {
                      return act('set-input', {
                        target: 'max'
                      });
                    }

                    return onClick;
                  }()
                })]
              })]
            })
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Available",
            children: (0, _format.formatPower)(inputAvailable)
          })]
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Output",
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Output Mode",
            "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": "power-off",
              "color": outputAttempt ? "green" : "red",
              "onClick": function () {
                function onClick() {
                  return act('toggle-output');
                }

                return onClick;
              }(),
              children: outputAttempt ? 'On' : 'Off'
            }),
            children: (0, _inferno.createComponentVNode)(2, _components.Box, {
              "color": outputState,
              children: outputting && outputAttempt && 'Enabled' || outputAttempt && 'Idle' || charge && 'Disabled' || 'No Charge'
            })
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Target Output",
            children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
              "inline": true,
              "width": "100%",
              children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
                  "icon": "fast-backward",
                  "disabled": outputLevel === 0,
                  "onClick": function () {
                    function onClick() {
                      return act('set-output', {
                        target: 'min'
                      });
                    }

                    return onClick;
                  }()
                }), (0, _inferno.createComponentVNode)(2, _components.Button, {
                  "icon": "backward",
                  "disabled": outputLevel === 0,
                  "onClick": function () {
                    function onClick() {
                      return act('set-output', {
                        adjust: -10000
                      });
                    }

                    return onClick;
                  }()
                })]
              }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                "grow": 1,
                "mx": 1,
                children: (0, _inferno.createComponentVNode)(2, _components.Slider, {
                  "value": outputLevel / POWER_MUL,
                  "minValue": 0,
                  "maxValue": outputLevelMax / POWER_MUL,
                  "step": 5,
                  "stepPixelSize": 4,
                  "format": function () {
                    function format(value) {
                      return (0, _format.formatPower)(value * POWER_MUL, 1);
                    }

                    return format;
                  }(),
                  "onDrag": function () {
                    function onDrag(e, value) {
                      return act('set-output', {
                        target: value * POWER_MUL
                      });
                    }

                    return onDrag;
                  }()
                })
              }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
                children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
                  "icon": "forward",
                  "disabled": outputLevel === outputLevelMax,
                  "onClick": function () {
                    function onClick() {
                      return act('set-output', {
                        adjust: 10000
                      });
                    }

                    return onClick;
                  }()
                }), (0, _inferno.createComponentVNode)(2, _components.Button, {
                  "icon": "fast-forward",
                  "disabled": outputLevel === outputLevelMax,
                  "onClick": function () {
                    function onClick() {
                      return act('set-output', {
                        target: 'max'
                      });
                    }

                    return onClick;
                  }()
                })]
              })]
            })
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Outputting",
            children: (0, _format.formatPower)(outputting)
          })]
        })
      })]
    })
  });
};

exports.Smes = Smes;

/***/ }),

/***/ "./packages/tgui/interfaces/TEG.js":
/*!*****************************************!*\
  !*** ./packages/tgui/interfaces/TEG.js ***!
  \*****************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.TEG = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _format = __webpack_require__(/*! ../format */ "./packages/tgui/format.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

/**
 * @file
 * @copyright 2020
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */
var TEG = function TEG(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  var output = data.output,
      history = data.history,
      hotCircStatus = data.hotCircStatus,
      hotInletTemp = data.hotInletTemp,
      hotOutletTemp = data.hotOutletTemp,
      hotInletPres = data.hotInletPres,
      hotOutletPres = data.hotOutletPres,
      coldCircStatus = data.coldCircStatus,
      coldInletTemp = data.coldInletTemp,
      coldOutletTemp = data.coldOutletTemp,
      coldInletPres = data.coldInletPres,
      coldOutletPres = data.coldOutletPres;
  var historyData = history.map(function (value, i) {
    return [i, value];
  });
  var historyMax = Math.max.apply(Math, history);

  var formatTemperature = function formatTemperature(temperature) {
    return (temperature >= 1000 ? temperature.toExponential(3) : temperature) + " K";
  };

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "height": "520",
    "width": "300",
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Status",
        children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Output History"
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Chart.Line, {
          "height": "5em",
          "data": historyData,
          "rangeX": [0, historyData.length - 1],
          "rangeY": [0, historyMax],
          "strokeColor": "rgba(1, 184, 170, 1)",
          "fillColor": "rgba(1, 184, 170, 0.25)"
        }), (0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Energy Output",
            "textAlign": "right",
            children: (0, _format.formatPower)(output)
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Hot Gas Circulator",
            "textAlign": "right",
            children: (0, _inferno.createComponentVNode)(2, _components.Box, {
              "color": hotCircStatus && hotInletTemp && 'good' || hotCircStatus && 'average' || 'bad',
              children: hotCircStatus && hotInletTemp && 'OK' || hotCircStatus && 'Idle' || 'ERROR'
            })
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Cold Gas Circulator",
            "textAlign": "right",
            children: (0, _inferno.createComponentVNode)(2, _components.Box, {
              "color": coldCircStatus && coldInletTemp && 'good' || coldCircStatus && 'average' || 'bad',
              children: coldCircStatus && coldInletTemp && 'OK' || coldCircStatus && 'Idle' || 'ERROR'
            })
          })]
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Hot Loop",
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Inlet Temp",
            "textAlign": "right",
            children: formatTemperature(hotInletTemp)
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Outlet Temp",
            "textAlign": "right",
            children: formatTemperature(hotOutletTemp)
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Inlet Pressure",
            "textAlign": "right",
            children: (0, _format.formatSiUnit)(Math.max(hotInletPres, 0), 1, 'Pa')
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Outlet Pressure",
            "textAlign": "right",
            children: (0, _format.formatSiUnit)(hotOutletPres, 1, 'Pa')
          })]
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Section, {
        "title": "Cold Loop",
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Inlet Temp",
            "textAlign": "right",
            children: formatTemperature(coldInletTemp)
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Outlet Temp",
            "textAlign": "right",
            children: formatTemperature(coldOutletTemp)
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Divider), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Inlet Pressure",
            "textAlign": "right",
            children: (0, _format.formatSiUnit)(Math.max(coldInletPres, 0), 1, 'Pa')
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Outlet Pressure",
            "textAlign": "right",
            children: (0, _format.formatSiUnit)(coldOutletPres, 1, 'Pa')
          })]
        })
      })]
    })
  });
};

exports.TEG = TEG;

/***/ }),

/***/ "./packages/tgui/interfaces/TankDispenser.js":
/*!***************************************************!*\
  !*** ./packages/tgui/interfaces/TankDispenser.js ***!
  \***************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.TankDispenser = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../layouts */ "./packages/tgui/layouts/index.js");

/**
 * Copyright (c) 2020 @actioninja
 * Minor changes by Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */
var TankDispenser = function TankDispenser(props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      act = _useBackend.act,
      data = _useBackend.data;

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 280,
    "height": 105,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: (0, _inferno.createComponentVNode)(2, _components.Section, {
        children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
          children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Plasma",
            "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": data.plasma ? 'circle' : 'circle-o',
              "content": "Dispense",
              "disabled": !data.plasma,
              "onClick": function () {
                function onClick() {
                  return act('dispense-plasma');
                }

                return onClick;
              }()
            }),
            children: data.plasma
          }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
            "label": "Oxygen",
            "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
              "icon": data.oxygen ? 'circle' : 'circle-o',
              "content": "Dispense",
              "disabled": !data.oxygen,
              "onClick": function () {
                function onClick() {
                  return act('dispense-oxygen');
                }

                return onClick;
              }()
            }),
            children: data.oxygen
          })]
        })
      })
    })
  });
};

exports.TankDispenser = TankDispenser;

/***/ }),

/***/ "./packages/tgui/interfaces/WeaponVendor/index.tsx":
/*!*********************************************************!*\
  !*** ./packages/tgui/interfaces/WeaponVendor/index.tsx ***!
  \*********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.WeaponVendor = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _string = __webpack_require__(/*! common/string */ "./packages/common/string.js");

var _backend = __webpack_require__(/*! ../../backend */ "./packages/tgui/backend.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! ../../layouts */ "./packages/tgui/layouts/index.js");

var _stringUtils = __webpack_require__(/*! ../common/stringUtils */ "./packages/tgui/interfaces/common/stringUtils.js");

/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */
var WeaponVendor = function WeaponVendor(_props, context) {
  var _useBackend = (0, _backend.useBackend)(context),
      data = _useBackend.data;

  var _useLocalState = (0, _backend.useLocalState)(context, 'filter-available', false),
      filterAvailable = _useLocalState[0],
      setFilterAvailable = _useLocalState[1];

  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    "width": 550,
    "height": 700,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      children: (0, _inferno.createComponentVNode)(2, _components.Stack, {
        "className": "WeaponVendor",
        "vertical": true,
        "fill": true,
        children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "fill": true,
            children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
              children: (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
                "label": "Balance",
                children: Object.entries(data.credits).map(function (_ref, index) {
                  var name = _ref[0],
                      value = _ref[1];
                  return (0, _inferno.createComponentVNode)(2, _components.Box, {
                    "inline": true,
                    "mr": "5px",
                    "className": "WeaponVendor__Credits--" + name,
                    children: [value, " ", name, " ", (0, _stringUtils.pluralize)('credit', value), index + 1 !== Object.keys(data.credits).length ? ', ' : '']
                  }, name);
                })
              })
            })
          })
        }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
          "grow": 1,
          children: (0, _inferno.createComponentVNode)(2, _components.Section, {
            "fill": true,
            "scrollable": true,
            "title": "Materiel",
            "buttons": (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
              "checked": filterAvailable,
              "onClick": function () {
                function onClick() {
                  return setFilterAvailable(!filterAvailable);
                }

                return onClick;
              }(),
              children: "Filter Available"
            }),
            children: Object.keys(data.credits).map(function (category) {
              return (0, _inferno.createComponentVNode)(2, StockCategory, {
                "category": category,
                "filterAvailable": filterAvailable
              }, category);
            })
          })
        })]
      })
    })
  });
};

exports.WeaponVendor = WeaponVendor;

var StockCategory = function StockCategory(props, context) {
  var category = props.category,
      filterAvailable = props.filterAvailable;

  var _useBackend2 = (0, _backend.useBackend)(context),
      data = _useBackend2.data;

  var stock = data.stock.filter(function (stock) {
    return stock.category === category;
  });

  if (filterAvailable) {
    stock = stock.filter(function (stock) {
      return stock.cost <= data.credits[stock.category];
    });
  }

  if (stock.length === 0) {
    return null;
  }

  return (0, _inferno.createComponentVNode)(2, _components.Collapsible, {
    "className": "WeaponVendor__Category--" + category,
    "title": (0, _string.toTitleCase)(category),
    "open": true,
    "color": category,
    children: (0, _inferno.createComponentVNode)(2, _components.Table, {
      children: data.stock.filter(function (stock) {
        return stock.category === category;
      }).map(function (stock) {
        return (0, _inferno.createComponentVNode)(2, Stock, {
          "stock": stock
        }, stock.name);
      })
    })
  });
};

var Stock = function Stock(_ref2, context) {
  var stock = _ref2.stock;

  var _useBackend3 = (0, _backend.useBackend)(context),
      data = _useBackend3.data,
      act = _useBackend3.act;

  return (0, _inferno.createComponentVNode)(2, _components.Table.Row, {
    "className": "WeaponVendor__Row",
    "opacity": stock.cost > data.credits[stock.category] ? 0.5 : 1,
    children: [(0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      "className": "WeaponVendor__Cell",
      "py": "5px",
      children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
        "mb": "5px",
        "bold": true,
        children: stock.name
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        children: stock.description
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Table.Cell, {
      "className": "WeaponVendor__Cell",
      "py": "5px",
      "textAlign": "right",
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "disabled": stock.cost > data.credits[stock.category],
        "color": stock.category,
        "onClick": function () {
          function onClick() {
            return act('redeem', {
              ref: stock.ref
            });
          }

          return onClick;
        }(),
        children: ["Redeem ", stock.cost, " ", (0, _stringUtils.pluralize)('credit', stock.cost)]
      })
    })]
  });
};

/***/ }),

/***/ "./packages/tgui/interfaces/WeaponVendor/type.ts":
/*!*******************************************************!*\
  !*** ./packages/tgui/interfaces/WeaponVendor/type.ts ***!
  \*******************************************************/
/***/ (function() {

"use strict";


/***/ }),

/***/ "./packages/tgui/interfaces/common/BeakerContents.js":
/*!***********************************************************!*\
  !*** ./packages/tgui/interfaces/common/BeakerContents.js ***!
  \***********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.BeakerContents = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var BeakerContents = function BeakerContents(props) {
  var beakerLoaded = props.beakerLoaded,
      beakerContents = props.beakerContents;
  return (0, _inferno.createComponentVNode)(2, _components.Box, {
    children: [!beakerLoaded && (0, _inferno.createComponentVNode)(2, _components.Box, {
      "color": "label",
      children: "No beaker loaded."
    }) || beakerContents.length === 0 && (0, _inferno.createComponentVNode)(2, _components.Box, {
      "color": "label",
      children: "Beaker is empty."
    }), beakerContents.map(function (chemical) {
      return (0, _inferno.createComponentVNode)(2, _components.Box, {
        "color": "label",
        children: [chemical.volume, " units of ", chemical.name]
      }, chemical.name);
    })]
  });
};

exports.BeakerContents = BeakerContents;

/***/ }),

/***/ "./packages/tgui/interfaces/common/HealthStat.js":
/*!*******************************************************!*\
  !*** ./packages/tgui/interfaces/common/HealthStat.js ***!
  \*******************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.HealthStat = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _constants = __webpack_require__(/*! ../../constants */ "./packages/tgui/constants.js");

var _Box = __webpack_require__(/*! ../../components/Box */ "./packages/tgui/components/Box.tsx");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

/*
 * A box that applies a color to its contents depending on the damage type.
 * Accepted types: oxy, toxin, burn, brute.
 */
var HealthStat = function HealthStat(props) {
  var type = props.type,
      children = props.children,
      className = props.className,
      rest = _objectWithoutPropertiesLoose(props, ["type", "children", "className"]);

  rest.color = _constants.COLORS.damageType[type] & _constants.COLORS.damageType[type];
  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _Box.Box, Object.assign({}, rest, {
    "className": (0, _react.classes)(['HealthStat', className, (0, _Box.computeBoxClassName)(rest)]),
    "color": _constants.COLORS.damageType[type],
    children: children
  })));
};

exports.HealthStat = HealthStat;

/***/ }),

/***/ "./packages/tgui/interfaces/common/ListSearch.tsx":
/*!********************************************************!*\
  !*** ./packages/tgui/interfaces/common/ListSearch.tsx ***!
  \********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ListSearch = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.ts");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */
var ListSearch = function ListSearch(props) {
  var autoFocus = props.autoFocus,
      className = props.className,
      currentSearch = props.currentSearch,
      noResultsPlaceholder = props.noResultsPlaceholder,
      onSearch = props.onSearch,
      onSelect = props.onSelect,
      options = props.options,
      _props$searchPlacehol = props.searchPlaceholder,
      searchPlaceholder = _props$searchPlacehol === void 0 ? 'Search...' : _props$searchPlacehol,
      _props$selectedOption = props.selectedOption,
      selectedOption = _props$selectedOption === void 0 ? null : _props$selectedOption;

  var handleSearch = function handleSearch(_e, value) {
    onSearch(value);
  };

  var cn = (0, _react.classes)(['list-search-interface', className]);
  return (0, _inferno.createComponentVNode)(2, _components.Stack, {
    "className": cn,
    "vertical": true,
    children: [(0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      children: (0, _inferno.createComponentVNode)(2, _components.Input, {
        "autoFocus": autoFocus,
        "fluid": true,
        "onInput": handleSearch,
        "placeholder": searchPlaceholder,
        "value": currentSearch
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Stack.Item, {
      children: [options.length === 0 && (0, _inferno.createComponentVNode)(2, _components.Placeholder, {
        "mx": 1,
        "py": 0.5,
        children: noResultsPlaceholder
      }), options.map(function (option) {
        return (0, _inferno.createVNode)(1, "div", (0, _react.classes)(['list-search-interface__search-option', 'Button', 'Button--fluid', 'Button--color--transparent', 'Button--ellipsis', selectedOption && option === selectedOption && 'Button--selected']), option, 0, {
          "onClick": function () {
            function onClick() {
              return onSelect(option);
            }

            return onClick;
          }(),
          "title": option
        }, option);
      })]
    })]
  });
};

exports.ListSearch = ListSearch;

/***/ }),

/***/ "./packages/tgui/interfaces/common/PortableAtmos.js":
/*!**********************************************************!*\
  !*** ./packages/tgui/interfaces/common/PortableAtmos.js ***!
  \**********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.PortableHoldingTank = exports.PortableBasicInfo = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

var _format = __webpack_require__(/*! ../../format */ "./packages/tgui/format.js");

var PortableBasicInfo = function PortableBasicInfo(props) {
  var connected = props.connected,
      pressure = props.pressure,
      maxPressure = props.maxPressure,
      children = props.children;
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Status",
    children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Pressure",
        children: (0, _inferno.createComponentVNode)(2, _components.RoundGauge, {
          "size": 1.75,
          "value": pressure,
          "minValue": 0,
          "maxValue": maxPressure,
          "alertAfter": maxPressure * 0.70,
          "ranges": {
            "good": [0, maxPressure * 0.70],
            "average": [maxPressure * 0.70, maxPressure * 0.85],
            "bad": [maxPressure * 0.85, maxPressure]
          },
          "format": _format.formatPressure
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Port",
        "color": connected ? 'good' : 'average',
        children: connected ? 'Connected' : 'Not Connected'
      })]
    }), children]
  });
};

exports.PortableBasicInfo = PortableBasicInfo;

var PortableHoldingTank = function PortableHoldingTank(props) {
  var holding = props.holding,
      onEjectTank = props.onEjectTank;
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Holding Tank",
    "minHeight": "115px",
    "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
      "icon": "eject",
      "content": "Eject",
      "disabled": !holding,
      "onClick": function () {
        function onClick() {
          return onEjectTank();
        }

        return onClick;
      }()
    }),
    children: holding ? (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Pressure",
        children: (0, _inferno.createComponentVNode)(2, _components.RoundGauge, {
          "size": 1.75,
          "value": holding.pressure,
          "minValue": 0,
          "maxValue": holding.maxPressure,
          "alertAfter": holding.maxPressure * 0.70,
          "ranges": {
            "good": [0, holding.maxPressure * 0.70],
            "average": [holding.maxPressure * 0.70, holding.maxPressure * 0.85],
            "bad": [holding.maxPressure * 0.85, holding.maxPressure]
          },
          "format": _format.formatPressure
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Label",
        children: holding.name
      })]
    }) : (0, _inferno.createComponentVNode)(2, _components.Box, {
      "color": "average",
      children: "No holding tank"
    })
  });
};

exports.PortableHoldingTank = PortableHoldingTank;

/***/ }),

/***/ "./packages/tgui/interfaces/common/ReagentInfo.js":
/*!********************************************************!*\
  !*** ./packages/tgui/interfaces/common/ReagentInfo.js ***!
  \********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ReagentList = exports.ReagentGraph = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var ReagentGraph = function ReagentGraph(props) {
  var container = props.container,
      height = props.height,
      rest = _objectWithoutPropertiesLoose(props, ["container", "height"]);

  var maxVolume = container.maxVolume,
      totalVolume = container.totalVolume,
      finalColor = container.finalColor;
  var contents = container.contents || [];
  rest.height = height || "50px";
  return (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _components.Box, Object.assign({}, rest, {
    children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
      "height": "100%",
      "direction": "column",
      children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "grow": true,
        children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
          "height": "100%",
          children: [contents.map(function (reagent) {
            return (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
              "grow": reagent.volume / maxVolume,
              children: (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
                "content": reagent.name + " (" + reagent.volume + "u)",
                "position": "bottom",
                children: (0, _inferno.createComponentVNode)(2, _components.Box, {
                  "px": 0,
                  "my": 0,
                  "height": "100%",
                  "backgroundColor": "rgb(" + reagent.colorR + ", " + reagent.colorG + ", " + reagent.colorB + ")"
                })
              })
            }, reagent.id);
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "grow": (maxVolume - totalVolume) / maxVolume,
            children: (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
              "content": "Nothing (" + (maxVolume - totalVolume) + "u)",
              "position": "bottom",
              children: (0, _inferno.createComponentVNode)(2, _components.NoticeBox, {
                "px": 0,
                "my": 0,
                "height": "100%",
                "backgroundColor": "rgba(0, 0, 0, 0)"
              })
            })
          })]
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        children: (0, _inferno.createComponentVNode)(2, _components.Tooltip, {
          "content": (0, _inferno.createComponentVNode)(2, _components.Box, {
            children: [(0, _inferno.createComponentVNode)(2, _components.ColorBox, {
              "color": finalColor
            }), " Current Mixture Color"]
          }),
          "position": "bottom",
          children: (0, _inferno.createComponentVNode)(2, _components.Box, {
            "height": "14px",
            "backgroundColor": contents.length ? finalColor : "rgba(0, 0, 0, 0.1)",
            "textAlign": "center",
            children: container.fake || (0, _inferno.createComponentVNode)(2, _components.Box, {
              "as": "span",
              "backgroundColor": "rgba(0, 0, 0, 0.5)",
              "px": 1,
              children: totalVolume + "/" + maxVolume
            })
          })
        })
      })]
    })
  })));
};

exports.ReagentGraph = ReagentGraph;

var ReagentList = function ReagentList(props) {
  var container = props.container,
      renderButtons = props.renderButtons,
      height = props.height,
      rest = _objectWithoutPropertiesLoose(props, ["container", "renderButtons", "height"]);

  var contents = container.contents || [];
  rest.height = height || 6;
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "scrollable": true,
    children: (0, _inferno.normalizeProps)((0, _inferno.createComponentVNode)(2, _components.Box, Object.assign({}, rest, {
      children: contents.length ? contents.map(function (reagent) {
        return (0, _inferno.createComponentVNode)(2, _components.Flex, {
          "mb": 0.5,
          "align": "center",
          children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "grow": true,
            children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
              "pr": 0.9,
              "name": "circle",
              "style": {
                "text-shadow": "0 0 3px #000;"
              },
              "color": "rgb(" + reagent.colorR + ", " + reagent.colorG + ", " + reagent.colorB + ")"
            }), "( " + reagent.volume + "u ) " + reagent.name]
          }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
            "nowrap": true,
            children: renderButtons(reagent)
          })]
        }, reagent.id);
      }) : (0, _inferno.createComponentVNode)(2, _components.Box, {
        "color": "label",
        children: [(0, _inferno.createComponentVNode)(2, _components.Icon, {
          "pr": 0.9,
          "name": "circle-o",
          "style": {
            "text-shadow": "0 0 3px #000;"
          }
        }), "Empty"]
      })
    })))
  });
};

exports.ReagentList = ReagentList;

/***/ }),

/***/ "./packages/tgui/interfaces/common/ReleaseValve.js":
/*!*********************************************************!*\
  !*** ./packages/tgui/interfaces/common/ReleaseValve.js ***!
  \*********************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ReleaseValve = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! ../../components */ "./packages/tgui/components/index.js");

/**
* @file
* @copyright 2020
* @author PrimeNumb (https://github.com/primenumb)
* @license MIT
*/
var ReleaseValve = function ReleaseValve(props) {
  var valveIsOpen = props.valveIsOpen,
      _props$releasePressur = props.releasePressure,
      releasePressure = _props$releasePressur === void 0 ? 0 : _props$releasePressur,
      _props$minRelease = props.minRelease,
      minRelease = _props$minRelease === void 0 ? 0 : _props$minRelease,
      _props$maxRelease = props.maxRelease,
      maxRelease = _props$maxRelease === void 0 ? 0 : _props$maxRelease,
      onToggleValve = props.onToggleValve,
      onSetPressure = props.onSetPressure;
  return (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
    children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
      "label": "Release valve",
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "content": valveIsOpen ? 'Open' : 'Closed',
        "color": valveIsOpen ? 'average' : 'default',
        "onClick": onToggleValve
      })
    }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
      "label": "Release pressure",
      children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
        "onClick": function () {
          function onClick() {
            return onSetPressure(minRelease);
          }

          return onClick;
        }(),
        "content": "Min"
      }), (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
        "animated": true,
        "width": "7em",
        "value": releasePressure,
        "minValue": minRelease,
        "maxValue": maxRelease,
        "onChange": function () {
          function onChange(e, targetPressure) {
            return onSetPressure(targetPressure);
          }

          return onChange;
        }()
      }), (0, _inferno.createComponentVNode)(2, _components.Button, {
        "onClick": function () {
          function onClick() {
            return onSetPressure(maxRelease);
          }

          return onClick;
        }(),
        "content": "Max"
      })]
    })]
  });
};

exports.ReleaseValve = ReleaseValve;

/***/ }),

/***/ "./packages/tgui/interfaces/common/stringUtils.js":
/*!********************************************************!*\
  !*** ./packages/tgui/interfaces/common/stringUtils.js ***!
  \********************************************************/
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.capitalize = exports.pluralize = void 0;

var pluralize = function pluralize(word, n) {
  return n !== 1 ? word + 's' : word;
};

exports.pluralize = pluralize;

var capitalize = function capitalize(word) {
  return word.replace(/(^\w{1})|(\s+\w{1})/g, function (letter) {
    return letter.toUpperCase();
  });
};

exports.capitalize = capitalize;

/***/ }),

/***/ "./packages/tgui/routes.js":
/*!*********************************!*\
  !*** ./packages/tgui/routes.js ***!
  \*********************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.getRoutedComponent = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/cache/inferno-npm-7.4.8-f828cb79a7-dd2af1493c.zip/node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ./backend */ "./packages/tgui/backend.ts");

var _selectors = __webpack_require__(/*! ./debug/selectors */ "./packages/tgui/debug/selectors.js");

var _layouts = __webpack_require__(/*! ./layouts */ "./packages/tgui/layouts/index.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var requireInterface = __webpack_require__("./packages/tgui/interfaces sync recursive ^\\.\\/.*$");

var routingError = function routingError(type, name) {
  return function () {
    return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
      children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
        "scrollable": true,
        children: [type === 'notFound' && (0, _inferno.createVNode)(1, "div", null, [(0, _inferno.createTextVNode)("Interface "), (0, _inferno.createVNode)(1, "b", null, name, 0), (0, _inferno.createTextVNode)(" was not found.")], 4), type === 'missingExport' && (0, _inferno.createVNode)(1, "div", null, [(0, _inferno.createTextVNode)("Interface "), (0, _inferno.createVNode)(1, "b", null, name, 0), (0, _inferno.createTextVNode)(" is missing an export.")], 4)]
      })
    });
  };
};

var SuspendedWindow = function SuspendedWindow() {
  return (0, _inferno.createComponentVNode)(2, _layouts.Window, {
    children: (0, _inferno.createComponentVNode)(2, _layouts.Window.Content, {
      "scrollable": true
    })
  });
};

var getRoutedComponent = function getRoutedComponent(store) {
  var state = store.getState();

  var _selectBackend = (0, _backend.selectBackend)(state),
      suspended = _selectBackend.suspended,
      config = _selectBackend.config;

  if (suspended) {
    return SuspendedWindow;
  }

  if (true) {
    var debug = (0, _selectors.selectDebug)(state); // Show a kitchen sink

    if (debug.kitchenSink) {
      return __webpack_require__(/*! ./debug */ "./packages/tgui/debug/index.js").KitchenSink;
    }
  }

  var name = config == null ? void 0 : config["interface"];
  var interfacePathBuilders = [function (name) {
    return "./" + name + ".tsx";
  }, function (name) {
    return "./" + name + ".js";
  }, function (name) {
    return "./" + name + "/index.tsx";
  }, function (name) {
    return "./" + name + "/index.js";
  }];
  var esModule;

  while (!esModule && interfacePathBuilders.length > 0) {
    var interfacePathBuilder = interfacePathBuilders.shift();
    var interfacePath = interfacePathBuilder(name);

    try {
      esModule = requireInterface(interfacePath);
    } catch (err) {
      if (err.code !== 'MODULE_NOT_FOUND') {
        throw err;
      }
    }
  }

  if (!esModule) {
    return routingError('notFound', name);
  }

  var Component = esModule[name];

  if (!Component) {
    return routingError('missingExport', name);
  }

  return Component;
};

exports.getRoutedComponent = getRoutedComponent;

/***/ }),

/***/ "./packages/tgui/sanitize.js":
/*!***********************************!*\
  !*** ./packages/tgui/sanitize.js ***!
  \***********************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.sanitizeText = void 0;

var _dompurify = _interopRequireDefault(__webpack_require__(/*! dompurify */ "./.yarn/cache/dompurify-npm-2.2.7-228180f49d-ddf23c494b.zip/node_modules/dompurify/dist/purify.js"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

/**
 * Copyright (c) 2020 Warlockd
 * SPDX-License-Identifier: MIT
 */
// Default values
var defAllowedTags = ['b', 'br', 'center', 'code', 'div', 'font', 'hr', 'i', 'li', 'menu', 'ol', 'p', 'pre', 'span', 'table', 'td', 'th', 'tr', 'u', 'ul'];
var defForbidAttr = ['class', 'style'];
/**
 * Feed it a string and it should spit out a sanitized version.
 *
 * @param {string} input
 * @param {array} tags
 * @param {array} forbidAttr
 */

var sanitizeText = function sanitizeText(input, tags, forbidAttr) {
  if (tags === void 0) {
    tags = defAllowedTags;
  }

  if (forbidAttr === void 0) {
    forbidAttr = defForbidAttr;
  }

  // This is VERY important to think first if you NEED
  // the tag you put in here.  We are pushing all this
  // though dangerouslySetInnerHTML and even though
  // the default DOMPurify kills javascript, it dosn't
  // kill href links or such
  return _dompurify["default"].sanitize(input, {
    ALLOWED_TAGS: tags,
    FORBID_ATTR: forbidAttr
  });
};

exports.sanitizeText = sanitizeText;

/***/ }),

/***/ "./packages/tgui/styles/main.scss":
/*!****************************************!*\
  !*** ./packages/tgui/styles/main.scss ***!
  \****************************************/
/***/ (function() {

// extracted by mini-css-extract-plugin

/***/ }),

/***/ "./packages/tgui/styles/themes/flock.scss":
/*!************************************************!*\
  !*** ./packages/tgui/styles/themes/flock.scss ***!
  \************************************************/
/***/ (function() {

// extracted by mini-css-extract-plugin

/***/ }),

/***/ "./packages/tgui/styles/themes/genetek-disabled.scss":
/*!***********************************************************!*\
  !*** ./packages/tgui/styles/themes/genetek-disabled.scss ***!
  \***********************************************************/
/***/ (function() {

// extracted by mini-css-extract-plugin

/***/ }),

/***/ "./packages/tgui/styles/themes/genetek.scss":
/*!**************************************************!*\
  !*** ./packages/tgui/styles/themes/genetek.scss ***!
  \**************************************************/
/***/ (function() {

// extracted by mini-css-extract-plugin

/***/ }),

/***/ "./packages/tgui/styles/themes/ntos.scss":
/*!***********************************************!*\
  !*** ./packages/tgui/styles/themes/ntos.scss ***!
  \***********************************************/
/***/ (function() {

// extracted by mini-css-extract-plugin

/***/ }),

/***/ "./packages/tgui/styles/themes/paper.scss":
/*!************************************************!*\
  !*** ./packages/tgui/styles/themes/paper.scss ***!
  \************************************************/
/***/ (function() {

// extracted by mini-css-extract-plugin

/***/ }),

/***/ "./packages/tgui/styles/themes/retro-dark.scss":
/*!*****************************************************!*\
  !*** ./packages/tgui/styles/themes/retro-dark.scss ***!
  \*****************************************************/
/***/ (function() {

// extracted by mini-css-extract-plugin

/***/ }),

/***/ "./packages/tgui/styles/themes/syndicate.scss":
/*!****************************************************!*\
  !*** ./packages/tgui/styles/themes/syndicate.scss ***!
  \****************************************************/
/***/ (function() {

// extracted by mini-css-extract-plugin

/***/ }),

/***/ "./packages/tgui/interfaces sync recursive ^\\.\\/.*$":
/*!*************************************************!*\
  !*** ./packages/tgui/interfaces/ sync ^\.\/.*$ ***!
  \*************************************************/
/***/ (function(module, __unused_webpack_exports, __webpack_require__) {

var map = {
	"./AIMap": "./packages/tgui/interfaces/AIMap.js",
	"./AIMap.js": "./packages/tgui/interfaces/AIMap.js",
	"./Airlock": "./packages/tgui/interfaces/Airlock.js",
	"./Airlock.js": "./packages/tgui/interfaces/Airlock.js",
	"./AlertModal": "./packages/tgui/interfaces/AlertModal.js",
	"./AlertModal.js": "./packages/tgui/interfaces/AlertModal.js",
	"./ArtifactPaper": "./packages/tgui/interfaces/ArtifactPaper.js",
	"./ArtifactPaper.js": "./packages/tgui/interfaces/ArtifactPaper.js",
	"./BarcodeComputer": "./packages/tgui/interfaces/BarcodeComputer.js",
	"./BarcodeComputer.js": "./packages/tgui/interfaces/BarcodeComputer.js",
	"./BugReportForm": "./packages/tgui/interfaces/BugReportForm.js",
	"./BugReportForm.js": "./packages/tgui/interfaces/BugReportForm.js",
	"./CharacterPreferences": "./packages/tgui/interfaces/CharacterPreferences/index.tsx",
	"./CharacterPreferences/": "./packages/tgui/interfaces/CharacterPreferences/index.tsx",
	"./CharacterPreferences/CharacterTab": "./packages/tgui/interfaces/CharacterPreferences/CharacterTab.tsx",
	"./CharacterPreferences/CharacterTab.tsx": "./packages/tgui/interfaces/CharacterPreferences/CharacterTab.tsx",
	"./CharacterPreferences/GameSettingsTab": "./packages/tgui/interfaces/CharacterPreferences/GameSettingsTab.tsx",
	"./CharacterPreferences/GameSettingsTab.tsx": "./packages/tgui/interfaces/CharacterPreferences/GameSettingsTab.tsx",
	"./CharacterPreferences/GeneralTab": "./packages/tgui/interfaces/CharacterPreferences/GeneralTab.tsx",
	"./CharacterPreferences/GeneralTab.tsx": "./packages/tgui/interfaces/CharacterPreferences/GeneralTab.tsx",
	"./CharacterPreferences/SavesTab": "./packages/tgui/interfaces/CharacterPreferences/SavesTab.tsx",
	"./CharacterPreferences/SavesTab.tsx": "./packages/tgui/interfaces/CharacterPreferences/SavesTab.tsx",
	"./CharacterPreferences/index": "./packages/tgui/interfaces/CharacterPreferences/index.tsx",
	"./CharacterPreferences/index.tsx": "./packages/tgui/interfaces/CharacterPreferences/index.tsx",
	"./CharacterPreferences/type": "./packages/tgui/interfaces/CharacterPreferences/type.ts",
	"./CharacterPreferences/type.ts": "./packages/tgui/interfaces/CharacterPreferences/type.ts",
	"./ChemDispenser": "./packages/tgui/interfaces/ChemDispenser.js",
	"./ChemDispenser.js": "./packages/tgui/interfaces/ChemDispenser.js",
	"./CloningConsole": "./packages/tgui/interfaces/CloningConsole.js",
	"./CloningConsole.js": "./packages/tgui/interfaces/CloningConsole.js",
	"./ComUplink": "./packages/tgui/interfaces/ComUplink/index.tsx",
	"./ComUplink/": "./packages/tgui/interfaces/ComUplink/index.tsx",
	"./ComUplink/index": "./packages/tgui/interfaces/ComUplink/index.tsx",
	"./ComUplink/index.tsx": "./packages/tgui/interfaces/ComUplink/index.tsx",
	"./ComUplink/type": "./packages/tgui/interfaces/ComUplink/type.ts",
	"./ComUplink/type.ts": "./packages/tgui/interfaces/ComUplink/type.ts",
	"./CyborgModuleRewriter": "./packages/tgui/interfaces/CyborgModuleRewriter/index.tsx",
	"./CyborgModuleRewriter/": "./packages/tgui/interfaces/CyborgModuleRewriter/index.tsx",
	"./CyborgModuleRewriter/EmptyPlaceholder": "./packages/tgui/interfaces/CyborgModuleRewriter/EmptyPlaceholder.tsx",
	"./CyborgModuleRewriter/EmptyPlaceholder.tsx": "./packages/tgui/interfaces/CyborgModuleRewriter/EmptyPlaceholder.tsx",
	"./CyborgModuleRewriter/ModuleView": "./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/index.tsx",
	"./CyborgModuleRewriter/ModuleView/": "./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/index.tsx",
	"./CyborgModuleRewriter/ModuleView/Module": "./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/Module.tsx",
	"./CyborgModuleRewriter/ModuleView/Module.tsx": "./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/Module.tsx",
	"./CyborgModuleRewriter/ModuleView/Tools": "./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/Tools.tsx",
	"./CyborgModuleRewriter/ModuleView/Tools.tsx": "./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/Tools.tsx",
	"./CyborgModuleRewriter/ModuleView/index": "./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/index.tsx",
	"./CyborgModuleRewriter/ModuleView/index.tsx": "./packages/tgui/interfaces/CyborgModuleRewriter/ModuleView/index.tsx",
	"./CyborgModuleRewriter/action": "./packages/tgui/interfaces/CyborgModuleRewriter/action.ts",
	"./CyborgModuleRewriter/action.ts": "./packages/tgui/interfaces/CyborgModuleRewriter/action.ts",
	"./CyborgModuleRewriter/index": "./packages/tgui/interfaces/CyborgModuleRewriter/index.tsx",
	"./CyborgModuleRewriter/index.tsx": "./packages/tgui/interfaces/CyborgModuleRewriter/index.tsx",
	"./CyborgModuleRewriter/style": "./packages/tgui/interfaces/CyborgModuleRewriter/style.ts",
	"./CyborgModuleRewriter/style.ts": "./packages/tgui/interfaces/CyborgModuleRewriter/style.ts",
	"./CyborgModuleRewriter/type": "./packages/tgui/interfaces/CyborgModuleRewriter/type.ts",
	"./CyborgModuleRewriter/type.ts": "./packages/tgui/interfaces/CyborgModuleRewriter/type.ts",
	"./DJPanel": "./packages/tgui/interfaces/DJPanel.js",
	"./DJPanel.js": "./packages/tgui/interfaces/DJPanel.js",
	"./DisposalChute": "./packages/tgui/interfaces/DisposalChute/index.tsx",
	"./DisposalChute/": "./packages/tgui/interfaces/DisposalChute/index.tsx",
	"./DisposalChute/index": "./packages/tgui/interfaces/DisposalChute/index.tsx",
	"./DisposalChute/index.tsx": "./packages/tgui/interfaces/DisposalChute/index.tsx",
	"./DisposalChute/type": "./packages/tgui/interfaces/DisposalChute/type.ts",
	"./DisposalChute/type.ts": "./packages/tgui/interfaces/DisposalChute/type.ts",
	"./DoorTimer": "./packages/tgui/interfaces/DoorTimer/index.tsx",
	"./DoorTimer/": "./packages/tgui/interfaces/DoorTimer/index.tsx",
	"./DoorTimer/index": "./packages/tgui/interfaces/DoorTimer/index.tsx",
	"./DoorTimer/index.tsx": "./packages/tgui/interfaces/DoorTimer/index.tsx",
	"./DoorTimer/type": "./packages/tgui/interfaces/DoorTimer/type.ts",
	"./DoorTimer/type.ts": "./packages/tgui/interfaces/DoorTimer/type.ts",
	"./Filteriffic": "./packages/tgui/interfaces/Filteriffic.js",
	"./Filteriffic.js": "./packages/tgui/interfaces/Filteriffic.js",
	"./FlockPanel": "./packages/tgui/interfaces/FlockPanel.js",
	"./FlockPanel.js": "./packages/tgui/interfaces/FlockPanel.js",
	"./GasCanister": "./packages/tgui/interfaces/GasCanister/index.js",
	"./GasCanister/": "./packages/tgui/interfaces/GasCanister/index.js",
	"./GasCanister/Detonator": "./packages/tgui/interfaces/GasCanister/Detonator.js",
	"./GasCanister/Detonator.js": "./packages/tgui/interfaces/GasCanister/Detonator.js",
	"./GasCanister/DetonatorTimer": "./packages/tgui/interfaces/GasCanister/DetonatorTimer.js",
	"./GasCanister/DetonatorTimer.js": "./packages/tgui/interfaces/GasCanister/DetonatorTimer.js",
	"./GasCanister/index": "./packages/tgui/interfaces/GasCanister/index.js",
	"./GasCanister/index.js": "./packages/tgui/interfaces/GasCanister/index.js",
	"./GasTank": "./packages/tgui/interfaces/GasTank.js",
	"./GasTank.js": "./packages/tgui/interfaces/GasTank.js",
	"./GeneTek": "./packages/tgui/interfaces/GeneTek.js",
	"./GeneTek.js": "./packages/tgui/interfaces/GeneTek.js",
	"./GeneTek/": "./packages/tgui/interfaces/GeneTek/index.js",
	"./GeneTek/AppearanceEditor": "./packages/tgui/interfaces/GeneTek/AppearanceEditor.js",
	"./GeneTek/AppearanceEditor.js": "./packages/tgui/interfaces/GeneTek/AppearanceEditor.js",
	"./GeneTek/BioEffect": "./packages/tgui/interfaces/GeneTek/BioEffect.js",
	"./GeneTek/BioEffect.js": "./packages/tgui/interfaces/GeneTek/BioEffect.js",
	"./GeneTek/DNASequence": "./packages/tgui/interfaces/GeneTek/DNASequence.js",
	"./GeneTek/DNASequence.js": "./packages/tgui/interfaces/GeneTek/DNASequence.js",
	"./GeneTek/GeneIcon": "./packages/tgui/interfaces/GeneTek/GeneIcon.js",
	"./GeneTek/GeneIcon.js": "./packages/tgui/interfaces/GeneTek/GeneIcon.js",
	"./GeneTek/index": "./packages/tgui/interfaces/GeneTek/index.js",
	"./GeneTek/index.js": "./packages/tgui/interfaces/GeneTek/index.js",
	"./GeneTek/modals/BuyMaterialsModal": "./packages/tgui/interfaces/GeneTek/modals/BuyMaterialsModal.js",
	"./GeneTek/modals/BuyMaterialsModal.js": "./packages/tgui/interfaces/GeneTek/modals/BuyMaterialsModal.js",
	"./GeneTek/modals/CombineGenesModal": "./packages/tgui/interfaces/GeneTek/modals/CombineGenesModal.js",
	"./GeneTek/modals/CombineGenesModal.js": "./packages/tgui/interfaces/GeneTek/modals/CombineGenesModal.js",
	"./GeneTek/modals/UnlockModal": "./packages/tgui/interfaces/GeneTek/modals/UnlockModal.js",
	"./GeneTek/modals/UnlockModal.js": "./packages/tgui/interfaces/GeneTek/modals/UnlockModal.js",
	"./GeneTek/tabs/MutationsTab": "./packages/tgui/interfaces/GeneTek/tabs/MutationsTab.js",
	"./GeneTek/tabs/MutationsTab.js": "./packages/tgui/interfaces/GeneTek/tabs/MutationsTab.js",
	"./GeneTek/tabs/ResearchTab": "./packages/tgui/interfaces/GeneTek/tabs/ResearchTab.js",
	"./GeneTek/tabs/ResearchTab.js": "./packages/tgui/interfaces/GeneTek/tabs/ResearchTab.js",
	"./GeneTek/tabs/ScannerTab": "./packages/tgui/interfaces/GeneTek/tabs/ScannerTab.js",
	"./GeneTek/tabs/ScannerTab.js": "./packages/tgui/interfaces/GeneTek/tabs/ScannerTab.js",
	"./GeneTek/tabs/StorageTab": "./packages/tgui/interfaces/GeneTek/tabs/StorageTab.js",
	"./GeneTek/tabs/StorageTab.js": "./packages/tgui/interfaces/GeneTek/tabs/StorageTab.js",
	"./GlassRecycler": "./packages/tgui/interfaces/GlassRecycler.js",
	"./GlassRecycler.js": "./packages/tgui/interfaces/GlassRecycler.js",
	"./ListInput": "./packages/tgui/interfaces/ListInput.js",
	"./ListInput.js": "./packages/tgui/interfaces/ListInput.js",
	"./LongRangeTeleporter": "./packages/tgui/interfaces/LongRangeTeleporter.js",
	"./LongRangeTeleporter.js": "./packages/tgui/interfaces/LongRangeTeleporter.js",
	"./MixingDesk": "./packages/tgui/interfaces/MixingDesk.js",
	"./MixingDesk.js": "./packages/tgui/interfaces/MixingDesk.js",
	"./PaperSheet": "./packages/tgui/interfaces/PaperSheet.js",
	"./PaperSheet.js": "./packages/tgui/interfaces/PaperSheet.js",
	"./Particool": "./packages/tgui/interfaces/Particool.js",
	"./Particool.js": "./packages/tgui/interfaces/Particool.js",
	"./PlayerPanel": "./packages/tgui/interfaces/PlayerPanel/index.tsx",
	"./PlayerPanel/": "./packages/tgui/interfaces/PlayerPanel/index.tsx",
	"./PlayerPanel/Header": "./packages/tgui/interfaces/PlayerPanel/Header.tsx",
	"./PlayerPanel/Header.tsx": "./packages/tgui/interfaces/PlayerPanel/Header.tsx",
	"./PlayerPanel/constant": "./packages/tgui/interfaces/PlayerPanel/constant.ts",
	"./PlayerPanel/constant.ts": "./packages/tgui/interfaces/PlayerPanel/constant.ts",
	"./PlayerPanel/index": "./packages/tgui/interfaces/PlayerPanel/index.tsx",
	"./PlayerPanel/index.tsx": "./packages/tgui/interfaces/PlayerPanel/index.tsx",
	"./PlayerPanel/type": "./packages/tgui/interfaces/PlayerPanel/type.ts",
	"./PlayerPanel/type.ts": "./packages/tgui/interfaces/PlayerPanel/type.ts",
	"./PowerMonitor": "./packages/tgui/interfaces/PowerMonitor/index.tsx",
	"./PowerMonitor/": "./packages/tgui/interfaces/PowerMonitor/index.tsx",
	"./PowerMonitor/Apc": "./packages/tgui/interfaces/PowerMonitor/Apc.tsx",
	"./PowerMonitor/Apc.tsx": "./packages/tgui/interfaces/PowerMonitor/Apc.tsx",
	"./PowerMonitor/Smes": "./packages/tgui/interfaces/PowerMonitor/Smes.tsx",
	"./PowerMonitor/Smes.tsx": "./packages/tgui/interfaces/PowerMonitor/Smes.tsx",
	"./PowerMonitor/index": "./packages/tgui/interfaces/PowerMonitor/index.tsx",
	"./PowerMonitor/index.tsx": "./packages/tgui/interfaces/PowerMonitor/index.tsx",
	"./PowerMonitor/type": "./packages/tgui/interfaces/PowerMonitor/type.ts",
	"./PowerMonitor/type.ts": "./packages/tgui/interfaces/PowerMonitor/type.ts",
	"./PowerTransmissionLaser": "./packages/tgui/interfaces/PowerTransmissionLaser.js",
	"./PowerTransmissionLaser.js": "./packages/tgui/interfaces/PowerTransmissionLaser.js",
	"./Pressurizer": "./packages/tgui/interfaces/Pressurizer.js",
	"./Pressurizer.js": "./packages/tgui/interfaces/Pressurizer.js",
	"./Radio": "./packages/tgui/interfaces/Radio/index.tsx",
	"./Radio/": "./packages/tgui/interfaces/Radio/index.tsx",
	"./Radio/index": "./packages/tgui/interfaces/Radio/index.tsx",
	"./Radio/index.tsx": "./packages/tgui/interfaces/Radio/index.tsx",
	"./Radio/type": "./packages/tgui/interfaces/Radio/type.ts",
	"./Radio/type.ts": "./packages/tgui/interfaces/Radio/type.ts",
	"./ReagentExtractor": "./packages/tgui/interfaces/ReagentExtractor.js",
	"./ReagentExtractor.js": "./packages/tgui/interfaces/ReagentExtractor.js",
	"./Rockbox": "./packages/tgui/interfaces/Rockbox.js",
	"./Rockbox.js": "./packages/tgui/interfaces/Rockbox.js",
	"./SeedFabricator": "./packages/tgui/interfaces/SeedFabricator.js",
	"./SeedFabricator.js": "./packages/tgui/interfaces/SeedFabricator.js",
	"./Sleeper": "./packages/tgui/interfaces/Sleeper.js",
	"./Sleeper.js": "./packages/tgui/interfaces/Sleeper.js",
	"./SlotMachine": "./packages/tgui/interfaces/SlotMachine.js",
	"./SlotMachine.js": "./packages/tgui/interfaces/SlotMachine.js",
	"./Smes": "./packages/tgui/interfaces/Smes.js",
	"./Smes.js": "./packages/tgui/interfaces/Smes.js",
	"./TEG": "./packages/tgui/interfaces/TEG.js",
	"./TEG.js": "./packages/tgui/interfaces/TEG.js",
	"./TankDispenser": "./packages/tgui/interfaces/TankDispenser.js",
	"./TankDispenser.js": "./packages/tgui/interfaces/TankDispenser.js",
	"./WeaponVendor": "./packages/tgui/interfaces/WeaponVendor/index.tsx",
	"./WeaponVendor/": "./packages/tgui/interfaces/WeaponVendor/index.tsx",
	"./WeaponVendor/index": "./packages/tgui/interfaces/WeaponVendor/index.tsx",
	"./WeaponVendor/index.tsx": "./packages/tgui/interfaces/WeaponVendor/index.tsx",
	"./WeaponVendor/type": "./packages/tgui/interfaces/WeaponVendor/type.ts",
	"./WeaponVendor/type.ts": "./packages/tgui/interfaces/WeaponVendor/type.ts",
	"./common/BeakerContents": "./packages/tgui/interfaces/common/BeakerContents.js",
	"./common/BeakerContents.js": "./packages/tgui/interfaces/common/BeakerContents.js",
	"./common/HealthStat": "./packages/tgui/interfaces/common/HealthStat.js",
	"./common/HealthStat.js": "./packages/tgui/interfaces/common/HealthStat.js",
	"./common/ListSearch": "./packages/tgui/interfaces/common/ListSearch.tsx",
	"./common/ListSearch.tsx": "./packages/tgui/interfaces/common/ListSearch.tsx",
	"./common/PortableAtmos": "./packages/tgui/interfaces/common/PortableAtmos.js",
	"./common/PortableAtmos.js": "./packages/tgui/interfaces/common/PortableAtmos.js",
	"./common/ReagentInfo": "./packages/tgui/interfaces/common/ReagentInfo.js",
	"./common/ReagentInfo.js": "./packages/tgui/interfaces/common/ReagentInfo.js",
	"./common/ReleaseValve": "./packages/tgui/interfaces/common/ReleaseValve.js",
	"./common/ReleaseValve.js": "./packages/tgui/interfaces/common/ReleaseValve.js",
	"./common/stringUtils": "./packages/tgui/interfaces/common/stringUtils.js",
	"./common/stringUtils.js": "./packages/tgui/interfaces/common/stringUtils.js"
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
webpackContext.id = "./packages/tgui/interfaces sync recursive ^\\.\\/.*$";

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
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = __webpack_modules__;
/******/ 	
/************************************************************************/
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
/******/ 	/* webpack/runtime/jsonp chunk loading */
/******/ 	!function() {
/******/ 		// no baseURI
/******/ 		
/******/ 		// object to store loaded and loading chunks
/******/ 		// undefined = chunk not loaded, null = chunk preloaded/prefetched
/******/ 		// [resolve, reject, Promise] = chunk loading, 0 = chunk loaded
/******/ 		var installedChunks = {
/******/ 			"tgui": 0
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
/******/ 	var __webpack_exports__ = __webpack_require__.O(undefined, ["tgui-common"], function() { return __webpack_require__("./packages/tgui/index.js"); })
/******/ 	__webpack_exports__ = __webpack_require__.O(__webpack_exports__);
/******/ 	
/******/ })()
;
//# sourceMappingURL=tgui.bundle.js.map