(function ($) {
    var mode = 'execute';

    window.onload = function () {
        jax("getUIState");
        initEvents();
    }

    function reportError(message) {
        jax("reportError", {message: message});
    }

    function errWrapper(func) {
        return function (event) {
            try {
                func(event);
            } catch (e) {
                reportError(e);
            }
        }
    }

    function initEvents() {
        $('#butt-load').on("click", errWrapper(handleButtonLoadClick));
        $('#butt-save').on("click", errWrapper(handleButtonSaveClick));
		$('#butt-abort').on("click", errWrapper(handleButtonAbortClick));
        $('.btn-c').on("click", errWrapper(handleButtonClick));
        $('.reservoir-button').on("click", errWrapper(handleReservoirButtonClick));
    }

    function setRef(theRef) {
        ref = theRef;
    }

    function jax(action, data) {
        if (typeof data === 'undefined')
            data = {};
        var params = [];
        for (var k in data) {
            if (data.hasOwnProperty(k)) {
                params.push(encodeURIComponent(k) + '=' + encodeURIComponent(data[k]));
            }
        }
        var newLoc = '?src=' + ref + ';action=' + action + ';' + params.join(';');

        window.location = newLoc;
    }

    function setCode(code) {
        code = code || '';
        $('#code-input').html(code);
    }

    function getCode() {
        return $('#code-input').val();
    }

    function handleButtonClick(event) {
        var buttonId = $(event.currentTarget).data('btn-id');

        switch (mode) {
            case 'load':
                doLoadCode(buttonId);
                break;
            case 'save':
                doSaveCode(buttonId);
                break;
            case 'execute':
                doExecuteCode(buttonId);
                break;
            default:
                break;
        }
        setMode("execute");
    }

    function setMode(newMode) {
        if (newMode === mode) {
            return;
        }

        if (newMode == 'execute') {
            $('#butt-save').removeClass("active");
            $('#butt-load').removeClass("active");
        }

        if (newMode == 'load') {
            $('#butt-save').removeClass("active");
            $('#butt-load').addClass("active");
        }

        if (newMode == 'save') {
            $('#butt-load').removeClass("active");
            $('#butt-save').addClass("active");
        }

        mode = newMode;
    }

    function handleButtonLoadClick() {
        setMode("load");
    }

    function doLoadCode(buttonId) {
        jax("loadCode", {id: buttonId});
    }

    function loadCodeCallback() {
        setMode("execute")
    }

    function handleButtonSaveClick() {
        setMode("save")
    }

	function handleButtonAbortClick(buttonId) {
		jax("abortCode", {id: buttonId, message: "Aborted by user"});
	}

    function doSaveCode(buttonId) {
        jax("saveCode", {id: buttonId, code: getCode()});
    }

    function saveCodeCallback() {
        setMode("execute");
    }

    function doExecuteCode(buttonId) {
        jax("executeCode", {id: buttonId});
    }

    function handleReservoirButtonClick(event) {
        var target = $(event.currentTarget || event.target || event.srcElement);
        jax("reservoir", {id: target.data("id")});
    }

    function setUIState(data) {
        data = JSON.parse(data);
        var i, res;
        for (i = 1; i <= 10; i++) {
            var res = $('#reservoir-' + i);
            if (data.reservoirs[i])
                res.addClass("btn-primary").removeClass("btn-default");
            else
                res.addClass("btn-default").removeClass("btn-primary")
        }
        for (i = 1; i <= 6; i++) {
            var butt = $('#butt-' + i);

            if (data.buttons[i])
                butt.addClass("btn-success").removeClass("btn-default");
            else
                butt.addClass("btn-default").removeClass("btn-success")
        }
        setCode(decodeURIComponent(data.output));
        $('#sx-input').val(data.sx);
        $('#tx-input').val(data.tx);
        $('#ax-input').val(data.ax);
    }

    window.loadCodeCallback = loadCodeCallback;
    window.saveCodeCallback = saveCodeCallback;
    window.setUIState = setUIState;
    window.setRef = setRef;
}(jQuery));
