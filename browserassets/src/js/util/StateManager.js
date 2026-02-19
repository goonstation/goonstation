var StateManager = (function () {
  /**
   * @typedef {object} StateManager~State
   */

  /**
   * @callback StateManager~ListenerCallback
   * @param {StateManager~State} state
   */

  var StateListener = (function () {
    /**
     * @param {StateManager~ListenerCallback} callback
     * @param {(string|string[])} [fields] Field or fields to listen for changes to.
     */
    function StateListener(callback, fields) {
      if (typeof callback === 'function') {
        this._callback = callback;
      } else {
        throw new TypeError(
          'Unexpected "callback" argument of type "' +
            typeof callback +
            '"; expected function.'
        );
      }
      if (typeof fields === 'undefined' || fields === null) {
        this._fields = null;
      } else if (typeof fields === 'string') {
        this._fields = [fields];
      } else if (Array.isArray(fields)) {
        for (fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
          field = fields[fieldIndex];
          if (typeof field !== 'string') {
            throw new TypeError(
              'Unexpected member of "fields" argument at index ' +
                fieldIndex +
                ' of type "' +
                typeof field +
                '"; expected string.'
            );
          }
        }
        this._fields = fields;
      } else {
        throw new TypeError(
          'Unexpected "fields" argument of type "' +
            typeof fields +
            '"; expected undefined, null, string, or array of strings.'
        );
      }
    }

    /**
     * @param {StateManager~State} newState
     */
    function fire(newState) {
      this._callback(newState);
    }

    /**
     * @param {StateManager~State} diff
     * @param {StateManager~State} newState
     */
    function trigger(diff, newState) {
      var diffField;
      var diffFieldIndex;
      var diffFields;
      if (this._fields === null) {
        this._fire(newState);
      } else if (Array.isArray(this._fields)) {
        diffFields = Object.keys(diff);
        for (
          diffFieldIndex = 0;
          diffFieldIndex < diffFields.length;
          diffFieldIndex++
        ) {
          diffField = diffFields[diffFieldIndex];
          if (this._fields.includes(diffField)) {
            this._fire(newState);
            break;
          }
        }
      }
    }

    StateListener.prototype._fire = fire;
    StateListener.prototype.trigger = trigger;

    return StateListener;
  })();

  /**
   * @param {StateManager~State} initialState
   */
  function StateManager(initialState) {
    this._state = Object.assign({}, initialState || {});
    this._stateListeners = [];
  }

  /**
   * @param {StateManager~ListenerCallback} callback
   * @param {string|string[]} [fields]
   * @return {StateListener}
   */
  function addStateListener(callback, fields) {
    var stateListener;
    stateListener = new StateListener(callback, fields);
    this._stateListeners.push(stateListener);
    return stateListener;
  }

  /**
   * @param {string|string[]} [fields]
   * @return {object}
   */
  function getState(fields) {
    var field;
    var fieldIndex;
    var returnedState;
    if (typeof fields === 'undefined') {
      returnedState = {};
      return Object.assign(returnedState, this._state);
    } else if (typeof fields === 'string') {
      returnedState = {};
      returnedState[fields] = this._state[fields];
    } else if (Array.isArray(fields)) {
      returnedState = {};
      for (fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
        var field = fields[fieldIndex];
        returnedState[field] = this._state[field];
      }
    } else {
      throw new TypeError(
        'Unexpected "fields" argument of type "' +
          typeof fields +
          '"; expected undefined, string, or array of strings.'
      );
    }
    return returnedState;
  }

  /**
   * @param {StateListener} stateListener
   */
  function removeStateListener(stateListener) {
    var stateListenerIndex;
    for (
      stateListenerIndex = 0;
      stateListenerIndex < this._stateListeners.length;
      stateListenerIndex++
    ) {
      if (this._stateListeners[stateListenerIndex] === stateListener) {
        this._stateListeners.splice(stateListenerIndex, 1);
        break;
      }
    }
  }

  /**
   * @param {StateManager~State} diff
   */
  function triggerStateListeners(diff) {
    var stateListener;
    var stateListenerIndex;
    if (Object.keys(diff).length > 0) {
      for (
        stateListenerIndex = 0;
        stateListenerIndex < this._stateListeners.length;
        stateListenerIndex++
      ) {
        stateListener = this._stateListeners[stateListenerIndex];
        stateListener.trigger(diff, this._state);
      }
    }
  }

  /**
   * @callback StateManager~Reducer
   * @param {StateManager~State} state
   * @return {StateManager~State}
   */

  /**
   * @param {(object|StateManager~Reducer)} updater
   */
  function setState(updater) {
    var diff;
    var field;
    var fieldIndex;
    var fields;
    var resolvedUpdater;
    if (!updater) {
      return;
    }
    diff = {};
    resolvedUpdater =
      typeof updater === 'function' ? updater(this._state) : updater;
    if (typeof resolvedUpdater !== 'object') {
      throw new TypeError(
        'Unexpected argument of type "' +
          typeof updater +
          '" passed to setState; expected function or object.'
      );
    }
    // generate state diff
    fields = Object.keys(resolvedUpdater);
    for (fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
      field = fields[fieldIndex];
      if (this._state[field] !== updater[field]) {
        diff[field] = updater[field];
      }
    }
    Object.assign(this._state, diff);
    this._triggerStateListeners(diff);
  }

  StateManager.prototype.addStateListener = addStateListener;
  StateManager.prototype.getState = getState;
  StateManager.prototype.removeStateListener = removeStateListener;
  StateManager.prototype.setState = setState;
  StateManager.prototype._triggerStateListeners = triggerStateListeners;

  return StateManager;
})();
