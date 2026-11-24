/// Default value for every client setting. Settings listed in `client_setting_choices` pick from a set of values, the rest are t/f.
var/list/client_setting_defaults = list(
	CLIENT_SETTING_FPS = "smooth",
	CLIENT_SETTING_HORIZONTAL_SPLIT = FALSE,
	CLIENT_SETTING_WIDESCREEN = TRUE,
	CLIENT_SETTING_ICON_SIZE = "0",
	CLIENT_SETTING_ZOOM_MODE = "distort",
	CLIENT_SETTING_FULLSCREEN = FALSE,
	CLIENT_SETTING_HIDE_MENU = FALSE,
	CLIENT_SETTING_DARK_MODE = TRUE,
	CLIENT_SETTING_DEPTH_SHADOW = TRUE,
	CLIENT_SETTING_DISTORTION = TRUE,
	CLIENT_SETTING_PARALLAX = TRUE,
	CLIENT_SETTING_VIEW_TINT = TRUE,
	CLIENT_SETTING_CAMERA_RECOIL = TRUE,
	CLIENT_SETTING_DARK_SCREENFLASHES = FALSE,
	CLIENT_SETTING_COLORBLIND = "none",
	CLIENT_SETTING_TG_LAYOUT = FALSE,
	CLIENT_SETTING_TG_CONTROLS = FALSE,
	CLIENT_SETTING_HAND_GHOSTS = TRUE,
	CLIENT_SETTING_MUTE_ALL = FALSE,
	CLIENT_SETTING_MUTE_SPEECH = FALSE,
	CLIENT_SETTING_MUTE_VOX = FALSE,
)

/// The values each multiple-choice setting allows, mapped to the skin menu item for that value
var/list/client_setting_choices = list(
	CLIENT_SETTING_FPS = list("velvety" = "fps_velvety", "creamy" = "fps_creamy", "smooth" = "fps_smooth", "chunky" = "fps_chunky"),
	CLIENT_SETTING_ICON_SIZE = list("0" = "stretch", "32" = "icon32", "56" = "icon56", "64" = "icon64", "88" = "icon88", "96" = "icon96", "128" = "icon128"),
	CLIENT_SETTING_ZOOM_MODE = list("distort" = "zoom_distort", "normal" = "zoom_normal"),
	CLIENT_SETTING_COLORBLIND = list("none", "protanopia", "deuteranopia", "tritanopia"), // not in the skin menu
)

/// The skin menu item for each on/off setting. A pair means the first is checked when on and the second when off.
var/list/client_setting_menu_items = list(
	CLIENT_SETTING_WIDESCREEN = list("set_wide", "set_square"),
	CLIENT_SETTING_HORIZONTAL_SPLIT = list("horiz_split", "vert_split"),
	CLIENT_SETTING_FULLSCREEN = "fullscreen",
	CLIENT_SETTING_HIDE_MENU = "hide_menu",
	CLIENT_SETTING_DARK_MODE = "dark_mode",
	CLIENT_SETTING_DEPTH_SHADOW = "set_shadow",
	CLIENT_SETTING_DISTORTION = "set_distort",
	CLIENT_SETTING_PARALLAX = "toggle_parallax",
	CLIENT_SETTING_VIEW_TINT = "set_tint",
	CLIENT_SETTING_CAMERA_RECOIL = "toggle_camera_recoil",
	CLIENT_SETTING_DARK_SCREENFLASHES = "toggle_dark_screenflashes",
	CLIENT_SETTING_TG_LAYOUT = "tg_layout",
	CLIENT_SETTING_TG_CONTROLS = "tg_controls",
	CLIENT_SETTING_HAND_GHOSTS = "use_hand_ghosts",
	CLIENT_SETTING_MUTE_ALL = "all_sounds",
	CLIENT_SETTING_MUTE_SPEECH = "speech_sounds",
	CLIENT_SETTING_MUTE_VOX = "vox_sounds",
)

/proc/is_valid_client_setting(setting, value)
	if (!istext(setting) || !(setting in global.client_setting_defaults))
		return FALSE
	var/list/choices = global.client_setting_choices[setting]
	if (choices)
		return istext(value) && (value in choices)
	return value == TRUE || value == FALSE

/datum/preferences
	/// Each CLIENT_SETTING_* and its current value which get saved to the player's cloud data
	var/list/client_settings = null
	/// Stays false until settings load from the cloud. We don't want the defaults to overwrite what a player saved
	var/client_settings_loaded = FALSE

/// Loads the player's settings from the cloud, or migrates them from the skin the first time, then applies them. Sleeps.
/datum/preferences/proc/load_client_settings(client/C)
	UNTIL(!C || C.player?.cloudSaves.loaded, 10 SECONDS)
	if (!C?.player?.cloudSaves.loaded)
		return
	var/json = C.player.cloudSaves.getData(CLIENT_SETTINGS_CLOUD_KEY)
	if (json)
		var/list/saved = json_decode(json)
		for (var/setting in saved)
			if (is_valid_client_setting(setting, saved[setting]))
				src.client_settings[setting] = saved[setting]
	else
		src.migrate_skin_client_settings(C)
		if (!C)
			return
	src.client_settings_loaded = TRUE
	if (!json)
		src.save_client_settings(C)
	src.apply_client_settings(C)

/// Checks the value, applies it, updates the menu checkmark and saves it
/datum/preferences/proc/set_client_setting(client/C, setting, value)
	if (!is_valid_client_setting(setting, value))
		return FALSE
	src.client_settings[setting] = value
	src.apply_client_setting(C, setting)
	winset(C, null, src.client_setting_menu_params(setting))
	src.save_client_settings(C)
	return TRUE

/// Reads a player's old settings off the skin menu checkmarks the first time they log in after the move. Sleeps.
/datum/preferences/proc/migrate_skin_client_settings(client/C)
	var/list/checked = params2list(winget(C, "menu.*", "is-checked")) // keys look like "menu.fps_smooth.is-checked"
	if (!C)
		return
	for (var/setting in global.client_setting_defaults)
		var/list/choices = global.client_setting_choices[setting]
		if (choices)
			for (var/choice in choices)
				if (checked["menu.[choices[choice]].is-checked"] == "true")
					src.client_settings[setting] = choice
					break
			continue
		var/item = global.client_setting_menu_items[setting]
		if (islist(item))
			item = item[1]
		var/value = checked["menu.[item].is-checked"]
		if (value)
			src.client_settings[setting] = value == "true"

/datum/preferences/proc/save_client_settings(client/C)
	if (!src.client_settings_loaded)
		return
	C?.player?.cloudSaves.putDataSoon(CLIENT_SETTINGS_CLOUD_KEY, json_encode(src.client_settings))

/// Leave `sync_menu` off until settings have loaded, so the migration can still read the old skin checkmarks. Sleeps.
/datum/preferences/proc/apply_client_settings(client/C, sync_menu = TRUE)
	for (var/setting in src.client_settings)
		if (!C)
			return
		src.apply_client_setting(C, setting, keep_splitter = TRUE)
	if (!sync_menu)
		return
	var/list/menu_params = list()
	for (var/setting in src.client_settings)
		menu_params += src.client_setting_menu_params(setting)
	winset(C, null, jointext(menu_params, ";"))

/// `keep_splitter` keeps a chat width the player dragged when reapplying saved settings, instead of snapping it
/datum/preferences/proc/apply_client_setting(client/C, setting, keep_splitter = FALSE)
	var/value = src.client_settings[setting]
	switch (setting)
		if (CLIENT_SETTING_FPS)
			switch (value)
				if ("chunky")
					C.tick_lag = CLIENTSIDE_TICK_LAG_CHUNKY
				if ("creamy")
					C.tick_lag = CLIENTSIDE_TICK_LAG_CREAMY
				if ("velvety")
					C.tick_lag = CLIENTSIDE_TICK_LAG_VELVETY
				else
					C.tick_lag = CLIENTSIDE_TICK_LAG_SMOOTH
		if (CLIENT_SETTING_WIDESCREEN)
			C.set_widescreen(value, keep_splitter)
		if (CLIENT_SETTING_HORIZONTAL_SPLIT)
			C.set_splitter_orientation(!value)
			C.set_widescreen(src.client_settings[CLIENT_SETTING_WIDESCREEN], keep_splitter)
		if (CLIENT_SETTING_ICON_SIZE)
			winset(C, "mapwindow.map", "icon-size=[value]")
		if (CLIENT_SETTING_ZOOM_MODE)
			winset(C, "mapwindow.map", "zoom-mode=[value]")
		if (CLIENT_SETTING_FULLSCREEN)
			winset(C, null, value ? "mainwindow.titlebar=false;mainwindow.is-maximized=true" : "mainwindow.titlebar=true")
		if (CLIENT_SETTING_HIDE_MENU)
			winset(C, null, value ? "mainwindow.menu='';menub.is-visible=true" : "mainwindow.menu='menu';menub.is-visible=false")
		if (CLIENT_SETTING_DARK_MODE)
			C.darkmode = value
			C.sync_dark_mode()
		if (CLIENT_SETTING_DEPTH_SHADOW, CLIENT_SETTING_DISTORTION)
			C.apply_depth_filter(src.client_settings[CLIENT_SETTING_DEPTH_SHADOW], src.client_settings[CLIENT_SETTING_DISTORTION])
		if (CLIENT_SETTING_PARALLAX)
			C.toggle_parallax()
		if (CLIENT_SETTING_VIEW_TINT)
			C.view_tint = value
			if (C.mob?.respect_view_tint_settings)
				C.set_color(length(C.mob.active_color_matrix) ? C.mob.active_color_matrix : COLOR_MATRIX_IDENTITY, C.mob.respect_view_tint_settings)
		if (CLIENT_SETTING_CAMERA_RECOIL)
			C.toggle_camera_recoil()
		if (CLIENT_SETTING_DARK_SCREENFLASHES)
			C.dark_screenflash = value
		if (CLIENT_SETTING_COLORBLIND)
			C.set_colorblind_mode(value)
		if (CLIENT_SETTING_TG_LAYOUT)
			if (C.tg_layout != value)
				C.set_layout(value)
		if (CLIENT_SETTING_TG_CONTROLS)
			if (C.tg_controls != value)
				C.set_controls(value)
		if (CLIENT_SETTING_HAND_GHOSTS)
			C.hand_ghosts = value
		if (CLIENT_SETTING_MUTE_ALL)
			C.ignore_sound_flags = value ? (C.ignore_sound_flags | SOUND_ALL) : (C.ignore_sound_flags & ~SOUND_ALL)
		if (CLIENT_SETTING_MUTE_SPEECH)
			C.ignore_sound_flags = value ? (C.ignore_sound_flags | SOUND_SPEECH) : (C.ignore_sound_flags & ~SOUND_SPEECH)
		if (CLIENT_SETTING_MUTE_VOX)
			C.ignore_sound_flags = value ? (C.ignore_sound_flags | SOUND_VOX) : (C.ignore_sound_flags & ~SOUND_VOX)

/datum/preferences/proc/client_setting_menu_params(setting)
	var/value = src.client_settings[setting]
	var/list/choices = global.client_setting_choices[setting]
	if (choices)
		var/list/params = list()
		for (var/choice in choices)
			if (choices[choice])
				params += "menu.[choices[choice]].is-checked=[choice == value ? "true" : "false"]"
		return jointext(params, ";")
	var/item = global.client_setting_menu_items[setting]
	if (islist(item))
		return "menu.[item[1]].is-checked=[value ? "true" : "false"];menu.[item[2]].is-checked=[value ? "false" : "true"]"
	return "menu.[item].is-checked=[value ? "true" : "false"]"

/// Every value the `client-setting` verb accepts
var/list/client_setting_verb_values = list("0", "1") | flatten_client_setting_choices()

/proc/flatten_client_setting_choices()
	. = list()
	for (var/setting in global.client_setting_choices)
		. |= global.client_setting_choices[setting]

/// true/false settings take 1 or 0
/client/verb/client_setting(setting as anything in global.client_setting_defaults, value as anything in global.client_setting_verb_values)
	set hidden = TRUE
	set name = "client-setting"
	if (!istext(setting) || !(setting in global.client_setting_defaults))
		return
	if (!(setting in global.client_setting_choices))
		value = text2num(value) ? TRUE : FALSE
	if (!src.preferences.set_client_setting(src, setting, value))
		winset(src, null, src.preferences.client_setting_menu_params(setting))

/client/verb/toggle_client_setting(setting as anything in global.client_setting_defaults)
	set hidden = TRUE
	set name = "toggle-client-setting"
	if (!istext(setting) || !(setting in global.client_setting_defaults) || (setting in global.client_setting_choices))
		return
	src.preferences.set_client_setting(src, setting, !src.preferences.client_settings[setting])

/client/proc/toggle_parallax()
	if (src.preferences.client_settings[CLIENT_SETTING_PARALLAX] && parallax_enabled)
		qdel(src.parallax_controller)
		src.parallax_controller = new(src)
	else if (src.parallax_controller)
		qdel(src.parallax_controller)

/client/proc/toggle_camera_recoil()
	if (!src.recoil_controller)
		src.recoil_controller = new/datum/recoil_controller(src)
	if (src.preferences.client_settings[CLIENT_SETTING_CAMERA_RECOIL])
		src.recoil_controller.enable()
	else
		src.recoil_controller.disable()

/client/proc/set_colorblind_mode(mode)
	switch (mode)
		if ("protanopia")
			src.colorblind_matrix = COLOR_MATRIX_PROTANOPIA_ACCESSIBILITY
		if ("deuteranopia")
			src.colorblind_matrix = COLOR_MATRIX_DEUTERANOPIA_ACCESSIBILITY
		if ("tritanopia")
			src.colorblind_matrix = COLOR_MATRIX_TRITANOPIA_ACCESSIBILITY
		else
			src.colorblind_matrix = COLOR_MATRIX_IDENTITY
	src.set_color(src.color_matrix) // refresh with the new colorblind matrix, keeping the current tint
	src.mob?.update_active_matrix()
