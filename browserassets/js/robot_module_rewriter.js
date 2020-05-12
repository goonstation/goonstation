attachErrorHandler('robot_module_rewriter');

(function(window, $, StateManager, domUtil) {

	/*
	 * UTILITY FUNCTIONS
	 */

	/**
	 * Utility for creating a CHUI button element.
	 * @param {object} props
	 * @param {string} [props.size]
	 * @param {string} [props.className]
	 * @param {boolean} [props.disabled]
	 * @param {string} [props.id]
	 * @param {string} [props.info]
	 * @param {string} [props.title]
	 * @param {DomUtil~Appendable} props.children
	 */
	function createButton(props) {
		var attributes = {};
		var classNames = [
			'button',
			typeof props.size !== 'undefined' ? props.size : 'medium',
		];
		if (typeof props.className !== 'undefined') {
			classNames.push(props.className);
		}
		if (!!props.disabled) {
			attributes.disabled = 'disabled';
		}
		attributes.id = props.id || '';
		attributes['data-info'] = props.info || '',
		attributes.title = props.title || '';
		return domUtil.createElement({
			tagName: 'a',
			className: classNames.join(' '),
			attributes: attributes,
			children: [
				domUtil.createElement({
					tagName: 'span',
					className: 'top'
				}),
				props.children,
				domUtil.createElement({
					tagName: 'span',
					className: 'bottom'
				})
			]
		});
	}

	/**
	 * @param {jQuery} $button Button to update.
	 * @param {string} text Label to update to.
	 */
	function updateButtonText($button, text) {
		$button.text('');
		$button.append('<span class="top"></span>');
		$button.append(text);
		$button.append('<span class="bottom"></span>');
	}

	/**
	 * Refreshes scrollbar for new content height.
	 */
	function updateScrollbar() {
		$('#content').nanoScroller();
	}

	/*
	 * CONFIG
	 */

	/**
	 * @typedef {object} RobotModuleRewriter~ModuleResetOption
	 * @property {string} id Identifier for BYOND.
	 * @property {string} name Displayable label for the reset option.
	 */

	/** @type {RobotModuleRewriter~ModuleResetOption[]} */
	var moduleResetOptions = [
		{ id: 'brobocop', name: 'Brobocop' },
		{ id: 'chemistry', name: 'Chemistry' },
		{ id: 'civilian', name: 'Civilian' },
		{ id: 'engineering', name: 'Engineering' },
		{ id: 'medical', name: 'Medical' },
		{ id: 'mining', name: 'Mining' }
	];

	/*
	 * STATE
	 */

	/**
	 * @typedef {object} RobotModuleRewriter~ModuleTool}
	 * @property {string} name Name of the tool.
	 * @property {string} ref BYOND's string ref for the tool.
	 */

	/**
	 * @typedef {object} RobotModuleRewriter~State
	 * @property {boolean} moduleLoaded Whether a module is loaded in the machine.
	 * @property {string} moduleName Name of module, if module is present.
	 * @property {boolean} moduleResetLock Whether module reset lock is engaged.
	 * @property {boolean} moduleToolRemovalLock Whether module tool removal lock is engaged.
	 * @property {RobotModuleRewriter~ModuleTool[]} moduleTools Tools within the module.
	 */

	/** @type {RobotModuleRewriter~State} */
	var initialState = {
		moduleLoaded: false,
		moduleName: null,
		moduleResetLock: true,
		moduleToolRemovalLock: true,
		moduleTools: []
	};

	/** @type {StateManager} */
	var stateManager = new StateManager(initialState);

	stateManager.addStateListener(renderModule, ['moduleLoaded', 'moduleName']);
	stateManager.addStateListener(renderModuleResetLock, 'moduleResetLock');
	stateManager.addStateListener(renderModuleResetOptions, ['moduleLoaded', 'moduleResetLock']);
	stateManager.addStateListener(renderModuleToolRemovalLock, ['moduleToolRemovalLock']);
	stateManager.addStateListener(renderModuleTools, ['moduleLoaded', 'moduleToolRemovalLock', 'moduleTools']);

	// initialize based on initial state
	(function () {
		var state = stateManager.getState();
		renderModule(state);
		renderModuleResetLock(state);
		renderModuleResetOptions(state);
		renderModuleToolRemovalLock(state);
		renderModuleTools(state);
	})();

	/*
	 * RENDER FUNCTIONS
	 */

	/**
	 * @param {RobotModuleRewriter~State} state
	 */
	function renderModule(state) {
		var $moduleEject = $('#module-eject');
		var $moduleName = $('#module-name');
		if (state.moduleLoaded) {
			$moduleName.text(state.moduleName);
			$moduleName.removeClass('module-name--no-module');
			$moduleEject.prop('disabled', false);
		} else {
			$moduleName.text('Empty');
			$moduleName.addClass('module-name--no-module');
			$moduleEject.prop('disabled', true);
		}
	}

	/**
	 * @param {RobotModuleRewriter~State} state
	 */
	function renderModuleResetLock(state) {
		var $moduleResetLock = $('#module-reset-lock');
		updateButtonText($moduleResetLock, state.moduleResetLock ? 'Engaged' : 'Disengaged');
	}

	/**
	 * @param {RobotModuleRewriter~State} state
	 */
	function renderModuleResetOptions(state) {
		var $moduleResetOptions = $('#module-reset-options');
		var $moduleResetSection = $('#module-reset-section');
		var moduleResetOption;
		var moduleResetOptionIndex;
		$moduleResetOptions.text('');
		if (state.moduleLoaded) {
			for (moduleResetOptionIndex = 0; moduleResetOptionIndex < moduleResetOptions.length; moduleResetOptionIndex++) {
				moduleResetOption = moduleResetOptions[moduleResetOptionIndex];
				$moduleResetOptions.append(createButton({
					children: moduleResetOption.name,
					disabled: state.moduleResetLock,
					id: 'module-reset-option-' + moduleResetOption.id,
					info: 'module-reset=' + moduleResetOption.id,
					title: moduleResetOption.name
				}));
			}
			$moduleResetSection.removeClass('module-reset-section--no-module');
		} else {
			$moduleResetSection.addClass('module-reset-section--no-module');
		}
	}

	/**
	 * @param {RobotModuleRewriter~State} state
	 */
	function renderModuleToolRemovalLock(state) {
		var $moduleToolRemovalLock = $('#module-tool-removal-lock');
		updateButtonText($moduleToolRemovalLock, state.moduleToolRemovalLock ? 'Engaged' : 'Disengaged');
	}

	/**
	 * @param {RobotModuleRewriter~State} state
	 */
	function renderModuleTools(state) {
		var $moduleTools = $('#module-tools');
		var $moduleToolsSection = $('#module-tools-section');
		var moduleTool;
		var moduleToolElement;
		var moduleToolIndex;
		$moduleTools.text('');
		if (state.moduleLoaded) {
			if (state.moduleTools.length > 0) {
				for (moduleToolIndex = 0; moduleToolIndex < state.moduleTools.length; moduleToolIndex++) {
					moduleTool = state.moduleTools[moduleToolIndex];
					moduleToolElement = domUtil.createElement({
						tagName: 'div',
						className: 'module-tool',
						children: [
							createButton({
								children: '\u2191',
								id: 'tool-move-up-' + moduleTool.ref,
								info: 'tool-move-up=' + moduleTool.ref,
								title: 'Move Up'
							}),
							createButton({
								children: '\u2193',
								id: 'tool-move-down-' + moduleTool.ref,
								info: 'tool-move-down=' + moduleTool.ref,
								title: 'Move Down'
							}),
							createButton({
								children: '\u00d7',
								disabled: state.moduleToolRemovalLock,
								id: 'tool-remove-' + moduleTool.ref,
								info: 'tool-remove=' + moduleTool.ref,
								title: 'Remove'
							}),
							domUtil.createElement({
								tagName: 'span',
								className: 'module-tool__name',
								children: moduleTool.name
							})
						]
					});
					$moduleTools.append(moduleToolElement);
				}
			} else {
				$moduleTools.append(domUtil.createElement({
					tagName: 'span',
					className: 'tools-message--empty',
					children: 'Module is empty!'
				}));
			}
			$moduleToolsSection.removeClass('module-tools-section--no-module');
		} else {
			$moduleToolsSection.addClass('module-tools-section--no-module');
		}
		updateScrollbar();
	}

	/*
	 * UPDATE FUNCTIONS
	 */

	/**
	 * @typedef {object} RobotModuleRewriter~ConfigurationData
	 * @property {boolean} [moduleResetLock] Whether module reset lock is engaged.
	 * @property {boolean} [moduleToolRemovalLock] Whether module tool removal lock is engaged.
	 */

	/**
	 * @param {(string|RobotModuleRewriter~ConfigurationData)} data
	 */
	function updateConfiguration(data) {
		var stateUpdates = {};
		if (typeof data === 'string') {
			data = $.parseJSON(data);
		}
		if (data.hasOwnProperty('moduleResetLock')) {
			stateUpdates.moduleResetLock = !!data.moduleResetLock;
		}
		if (data.hasOwnProperty('moduleToolRemovalLock')) {
			stateUpdates.moduleToolRemovalLock = !!data.moduleToolRemovalLock;
		}
		stateManager.setState(stateUpdates);
	}

	/**
	 * @typedef {object} RobotModuleRewriter~ModuleData
	 * @property {string} [moduleName] Name of module, if module is present.
	 */

	/**
	 * @typedef {object} RobotModuleRewriter~ModuleToolsData
	 * @property {RobotModuleRewriter~ModuleTool[]} [tools] Tools within the module.
	 */

	/**
	 * @param {(string|(RobotModuleRewriter~ModuleData & RobotModuleRewriter~ModuleToolsData))} data
	 */
	function updateModule(data) {
		var stateUpdates = {};
		if (typeof data === 'string') {
			data = $.parseJSON(data);
		}
		if (data.hasOwnProperty('moduleName')) {
			// module present
			stateUpdates.moduleLoaded = true;
			stateUpdates.moduleName = data.moduleName;
		} else {
			// no module
			stateUpdates.moduleLoaded = initialState.moduleLoaded;
			stateUpdates.moduleName = initialState.moduleName;
		}
		Object.assign(stateUpdates, updateModuleTools(data, { suppressStateUpdate: true }));
		stateManager.setState(stateUpdates);
	}

	/**
	 * @param {(string|RobotModuleRewriter~ModuleToolsData)} data
	 * @param {object} [options]
	 * @param {boolean} [suppressStateUpdate] Whether to prevent triggering a state update.
	 */
	function updateModuleTools(data, options) {
		var stateUpdates = {};
		if (typeof data === 'string') {
			data = $.parseJSON(data);
		}
		if (data.hasOwnProperty('tools')) {
			stateUpdates.moduleTools = data.tools;
		} else {
			stateUpdates.moduleTools = initialState.tools;
		}
		if (typeof options === 'undefined' || !options.suppressStateUpdate) {
			stateManager.setState(stateUpdates);
		}
		return stateUpdates;
	}

	window.updateConfiguration = updateConfiguration;
	window.updateModule = updateModule;
	window.updateModuleTools = updateModuleTools;

})(window, jQuery, StateManager, domUtil);
