var triggerError = attachErrorHandler('flockpanel', true);

$(document).ready(function () {

    var state = {
      vitals: {},
      partitions: [],
      drones: [],
      enemies: []
    };
    var healthGradient = ["#802020",
      "#FF0000",
      "#FFA200",
      "#FFFB00",
      "#C8FF00",
      "#00FF00"]; // least health to most health
    // var hoverSound = new Howl({
    // 	src: ['../../sound/flockdrone/hover.ogg'],
    // 	volume: 0.25
    // });
    // var clickSound = new Howl({
    // 	src: ['../../sound/flockdrone/click.ogg'],
    // 	volume: 0.5
    // });
    // var denySound = new Howl({
    // 	src: ['../../sound/flockdrone/deny.ogg'],
    // 	volume: 0.5
    // });
    var flockPanelRef = null; // reference to a flock datum to query for information
    // a big ol' list of what each aspect of the flock panel should be rendering from received data (data driven design is go)
    var entityProperties = {
      partitions: [{
        name: 'name',
        content: '??.?'
      }, {
        name: 'host',
        content: ''
      }, {
        name: 'health',
        content: 100
      }, {
        name: 'jump',
        action: 'jump_to',
        content: '<i class="icon-map-marker"></i>'
      }, {
        name: 'eject',
        action: 'eject_trace',
        content: '<i class="icon-eject"></i>',
        required: 'host'
      }, {
        name: 'delete',
        action: 'delete_trace',
        content: '<i class="icon-ban-circle"></i>'
      }],
      drones: [{
        name: 'name',
        content: '??.??.??'
      }, {
        name: 'health',
        content: 100
      }, {
        name: 'resources',
        content: 0
      }, {
        name: 'task',
        content: 0
      }, {
        name: 'area',
        content: 'Unknown'
      }, {
        name: 'jump',
        action: 'jump_to',
        content: '<i class="icon-map-marker"></i>'
      }, {
        name: 'rally',
        action: 'rally',
        content: '<i class="icon-reply-all"></i>'
      }],
      enemies: [{
        name: 'name',
        content: 'Unknown'
      }, {
        name: 'area',
        content: 'Unknown'
      }, {
        name: 'remove',
        action: 'remove_enemy',
        content: '<i class="icon-remove"></i>'
      }]
    };

    function getGradientFromRange(gradient, value, min, max) { // probably not the right name but fuck it
      // gradient: an array of hex colours from least to most
      if (!Array.isArray(gradient) || isNaN(value) || isNaN(min) || isNaN(max)) {
        return; // ERROR
      }
      if (min > max) { // you dimwit!
        var temp = min;
        min = max;
        max = temp;
      }
      value = clamp(value, min, max);
      var normLerp = (value - min) / (max - min);
      if (normLerp >= 1) {
        // short circuit and just return the last gradient value
        return gradient[gradient.length - 1];
      }
      var gradLerp = (normLerp * gradient.length);
      // this gives a value where the integer is the index and the decimal is the value to lerp to the next colour
      var gradLerpInt = Math.floor(gradLerp);
      var gradLerpFrac = gradLerp - gradLerpInt;
      var firstCol = hexToRgb(gradient[gradLerpInt]);
      var secondCol = hexToRgb(gradient[gradLerpInt + 1]); // this should not go out of range
      var lerpCol = {
        r: firstCol.r + ((secondCol.r - firstCol.r) * gradLerpFrac),
        g: firstCol.g + ((secondCol.g - firstCol.g) * gradLerpFrac),
        b: firstCol.b + ((secondCol.b - firstCol.b) * gradLerpFrac)
      };
      return rgbToHex(Math.floor(lerpCol.r), Math.floor(lerpCol.g), Math.floor(lerpCol.b));
    }

    function hexToRgb(hex) {
      var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
      return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
      } : null;
    }

    function rgbToHex(r, g, b) {
      return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
    }

    function clamp(num, min, max) {
      return num <= min ? min : num >= max ? max : num;
    }

    function getHtmlSafeRef(ref) {
      return ref.slice(3, -1);  // trim [0xWHATEVER] down to WHATEVER
    }

    function formatHealth(value) {
      value = Math.floor(value);
      var color = getGradientFromRange(healthGradient, value, 0, 100);
      return "<span style='color:" + color + "'>" + value + "%</span>";
    }

    // this table is a summary table, not a listing table
    // as such it is already constructed, and only needs values updated
    // to see what fields are used, please check flockpanel.dm
    function updateVitalsTable() {
      var table = $('#vitals');
      var vitals = state.vitals;
      table.find('td.value').each(function (index, element) {
        var id = element.id;
        var field = id.split('-')[1];
        element.innerHTML = (typeof vitals[field] !== 'undefined') ? vitals[field] : '???';
      });
    }

    // update entity list tables (flocktraces, drones, structures, enemies)
    function updateEntityTable(entitiesKey) {
      var entities = state[entitiesKey];
      var table = $('#' + entitiesKey);
      var properties = entityProperties[entitiesKey];

      $.each(entities, function (i, entity) {
        if (entity.ref) {
          var htmlSafeRef = getHtmlSafeRef(entity.ref);
          var row = $('#' + entitiesKey + '-' + htmlSafeRef);
          if (row.length === 0) {
            // create element and attach it
            row = $('<tr>').attr('id', entitiesKey + '-' + htmlSafeRef);
            row.appendTo(table);
          }
          // update element
          var td, button, content;
          $.each(properties, function (index, value) {
            // if td doesn't exist, create and append it
            td = row.find('.' + value.name);
            if (td.length === 0) {
              td = $('<td>').addClass(value.name);
              row.append(td);
            }
            if (value.action) {
              // property is a button, handle it differently
              // if button doesn't exist, create and append it
              // and set up its handler
              button = td.find('#' + entitiesKey + '-' + value.name + '-' + htmlSafeRef);
              if (button.length === 0) {
                button = $('<a>').addClass('button').attr('id', entitiesKey + '-' + value.name + '-' + htmlSafeRef);
                td.append(button);
                var ref = '[0x' + htmlSafeRef + ']'; // this may seem pointless, however this makes ref immutable, which is important
                button.click(function () {
                  onAction(ref, value.action);
                });
                button.html(value.content);
              }
              // disable the button if required values aren't present, enable it if they are
              if(value.required) {
                var valuePresent = entity[value.required] !== null;
                if(valuePresent) {
                  button.attr('disabled', false);
                } else {
                  button.attr('disabled', true);
                }
              }
            } else {
              content = entity[value.name] ? entity[value.name] : value.content;
              td.html(content);
            }
          });
        }
      });
    }

    function onAction(ref, action) {
      window.location = "?src=" + flockPanelRef + "&action=" + action + "&origin=" + ref;
    }

    function updateUi() {
      if (state.tab === 'vitals') {
        updateVitalsTable();
      } else if (state[state.tab] && state[state.tab].length > 0) {
        updateEntityTable(state.tab);
      }

      // POST DATA FORMATTING
      // DRONE HEALTH VALUES
      // format health values
      $(".health").each(function () {
        var originalText = $(this).text();
        $(this).html(formatHealth(parseInt(originalText)));
      });
    }

    function init() {
      // initialise sorting aspect of state
      state.sort = {};

      // assign handlers to tab buttons
      $(".tablinks").click(function () {
        var id = $(this).attr("id");
        var parts = id.split("-");
        changeTab(parts[parts.length - 1]);
      });
      updateUi();
      changeTab("vitals"); // default tab

      // annoying UI sounds beep boop
      // $('body').on('click', 'a.button', function(event) {
      // 	if ($(this).attr("disabled")) {
      // 		denySound.play();
      // 	} else {
      // 		clickSound.play();
      // 	}
      // });
      // $('body').on('mouseenter', 'a.button', function() {
      // 	hoverSound.play();
      // });

      // ASSIGN DRONE TABLE HEADER BUTTONS
      $('.sortable').click(onSortButton);

      flockPanelRef = $('#panel-ref').text();
      window.flock = {
        receiveData: receiveData
      };
    }

    function changeTab(tabName) {
      $(".tabcontent").hide();
      $(".tablinks").removeClass("selected");
      $("#tab-button-" + tabName).addClass("selected");
      $("#tab-" + tabName).show();
      state.tab = tabName;
      updateUi();
    }

    function onSortButton() {
      // get params based on id of button
      var self = $(this);
      var id = self.attr("id");
      var parts = id.split("-");
      var statePart = parts[0]; // what part of state are we sorting?
      var toSort = state[statePart];
      var sortOn = parts[1]; // what field are we sorting by?

      // get current sorting state for this part of the state
      var sortState = state.sort[statePart];
      var sortDirection = -1; // asc by default
      if (sortState) {
        if (typeof sortState[sortOn] !== 'undefined') {
          sortDirection = -1 * sortState[sortOn]; // if it exists, flip it
        }
        sortState[sortOn] = sortDirection;
      } else {
        state.sort[statePart] = {
          sortOn: sortDirection
        };
      }

      // sort state array
      sort(toSort, sortOn, sortDirection);
      // empty existing table
      var table = $('#' + statePart);
      table.find('tr:gt(0)').remove();
      // remove "selected" class from all header cells in table
      table.find('.sortable').removeClass('selected asc desc');
      // adjust corresponding header cell to have selected
      self.addClass('selected ' + (sortDirection === 1 ? 'desc' : 'asc'));
      // refresh UI
      updateUi();
    }

    function sort(array, field, direction) {
      if (direction < 0) {
        // ascending
        array.sort(function (a, b) {
          if (a[field] < b[field]) {
            return -1;
          } else if (b[field] < a[field]) {
            return 1;
          } else {
            return 0;
          }
        });
      } else {
        // descending
        array.sort(function (a, b) {
          if (a[field] > b[field]) {
            return -1;
          } else if (b[field] > a[field]) {
            return 1;
          } else {
            return 0;
          }
        });
      }
    }

    function getData() {
      window.location = "?src=" + flockPanelRef + "&action=update";
    }

    function populateEntityList(entitiesKey, entitiesList) {
      state[entitiesKey] = [];
      $.each(entitiesList, function(i, entity) {
        if (typeof entity === 'object') {
          state[entitiesKey].push(entity);
        }
      });
    }

    function receiveData(flockData) {
      var i, entity, list;
      flockData = JSON.parse(flockData);
      if (flockData && flockData.update) {
        if (flockData.update === 'flock') {
          // reset vitals
          state.vitals = {};
          // copy over vitals properties
          for (var prop in flockData.vitals) {
            if (flockData.vitals.hasOwnProperty(prop)) {
              state.vitals[prop] = flockData.vitals[prop];
            }
          }
          populateEntityList('drones', flockData.drones);
          populateEntityList('enemies', flockData.enemies);
          populateEntityList('partitions', flockData.partitions);
        } else if (flockData.update === 'add') {
          // overwrite specific entry if it exists
          // not using dictionary/map because ordering matters
          // else append
          list = state[flockData.key];
          var found = false;
          for (i = 0; i < list.length; ++i) {
            entity = list[i];
            if (entity.ref === flockData.ref) {
              // update
              found = true;
              list[i] = flockData;
              break;
            }
          }
          if (!found) {
            // append
            list.push(flockData);
          }
        } else if (flockData.update === 'remove') {
          list = state[flockData.key];
          for (i = 0; i < list.length; ++i) {
            entity = list[i];
            if (entity.ref === flockData.ref) {
              // we found it, remove it from drones
              list.splice(i, 1);
              // if a row exists in the tab, remove it
              var htmlSafeRef = getHtmlSafeRef(entity.ref);
              var row = $('#' + flockData.key + '-' + htmlSafeRef);
              if (row.length !== 0) {
                row.remove();
              }
              // break out of loop, we're done here
              break;
            }
          }
        }
      }
      updateUi();
    }

    init();
    getData();
    setInterval(getData, 3500);
  }
);





