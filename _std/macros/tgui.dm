#define USE_OR_MAKE_TGUI(js_name, disp_name...) \
	ui = tgui_process.try_update_ui(user, src, ui); \
	if (!ui) {\
		ui = new(user, src, js_name, ##disp_name); \
		ui.open(); \
	}