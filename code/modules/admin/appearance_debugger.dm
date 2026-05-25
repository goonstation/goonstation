/client/proc/cmd_debug_appearance(atom/target)
	ADMIN_ONLY
	if (!target)
		return
	var/datum/appearance_debugger/debugger = new()
	debugger.set_target(target)
	debugger.ui_interact(src.mob)

/// Allows developers to see a breakdown of an atom's appearance (overlays, underlays, vis_contents)
/datum/appearance_debugger
	/// Currently debugged atom or mutable appearance
	var/datum/debug_target

	/// A list of copies of the currently debugged appearance and its children for access from the UI
	var/list/mutable_appearance/appearance_copies

	/// Assoc list of ref -> appearance for caching
	var/list/mutable_appearance/appearance_cache

/datum/appearance_debugger/New()
	..()
	appearance_copies = list()
	appearance_cache = list()

/datum/appearance_debugger/disposing()
	debug_target = null
	appearance_copies = null
	appearance_cache = null
	..()

/datum/appearance_debugger/proc/get_appearance_data(atom/appearance_owner)
	var/mutable_appearance/target = appearance_owner
	if (isatom(appearance_owner))
		var/ref_key = "\ref[appearance_owner]"
		target = appearance_cache[ref_key] || new /mutable_appearance(appearance_owner.appearance)
		appearance_cache[ref_key] = target

	var/list/data = list(
		"type" = isatom(appearance_owner) ? "atom" : (istype(appearance_owner, /image) ? "image" : "appearance"),
		"alpha" = target.alpha,
		"flags" = target.appearance_flags,
		"blend_mode" = target.blend_mode,
		"color" = target.color,
		"dir" = target.dir,
		"icon" = length("[target.icon]") ? "[target.icon]" : null,
		"icon_state" = target.icon_state,
		"invisibility" = target.invisibility,
		"layer" = target.layer,
		"name" = target.name,
		"maptext" = target.maptext,
		"maptext_width" = target.maptext_width,
		"maptext_height" = target.maptext_height,
		"maptext_x" = target.maptext_x,
		"maptext_y" = target.maptext_y,
		"mouse_opacity" = target.mouse_opacity,
		"pixel_x" = target.pixel_x,
		"pixel_y" = target.pixel_y,
		"pixel_w" = target.pixel_w,
		"pixel_z" = target.pixel_z,
		"plane" = target.plane,
		"plane_true" = target.plane,
		"render_source" = target.render_source,
		"render_target" = target.render_target,
		"screen_loc" = target.screen_loc,
	)

	if (!(target in appearance_copies))
		appearance_copies += target
		data["id"] = length(appearance_copies)
	else
		data["id"] = appearance_copies.Find(target)

	var/list/filter_data = list()
	if (isatom(appearance_owner))
		var/atom/atom_target = appearance_owner
		if (atom_target.filter_data)
			for (var/filter_name in atom_target.filter_data)
				var/list/our_filter = atom_target.filter_data[filter_name]
				filter_data += list(list("name" = filter_name, "type" = our_filter["type"]))
	data["filters"] = filter_data

	var/list/underlay_data = list()
	for (var/mutable_appearance/underlay as anything in target.underlays)
		underlay_data += list(get_appearance_data(underlay))
	data["underlays"] = underlay_data

	var/list/overlay_data = list()
	for (var/mutable_appearance/overlay as anything in target.overlays)
		overlay_data += list(get_appearance_data(overlay))
	data["overlays"] = overlay_data

	// Display previews if it is either an instance icon or a file and we have icon_state set
	if (target.icon && target.icon_state)
		try
			var/icon/used_icon = icon(target.icon, target.icon_state, SOUTH, frame = 1)
			if (istext(target.color))
				used_icon.Blend(target.color, ICON_MULTIPLY)
			data["embed_icon"] = icon2base64(used_icon)
		catch
			// Icon generation can fail for various reasons, just skip it

	var/list/transform_data = list(1, 0, 0, 0, 1, 0) // identity matrix default
	if (target.transform)
		var/matrix/M = target.transform
		transform_data = list(M.a, M.b, M.c, M.d, M.e, M.f)
	data["transform"] = transform_data

	// Handle vis_contents for atoms
	if (ismovable(appearance_owner) || isturf(appearance_owner))
		var/atom/movable/as_movable = appearance_owner
		data["vis_flags"] = as_movable.vis_flags
		var/list/vis_data = list()
		for (var/atom/vis_thing as anything in as_movable.vis_contents)
			vis_data += list(get_appearance_data(vis_thing))
		data["vis_contents"] = vis_data
	else
		data["vis_contents"] = null
		data["vis_flags"] = null

	return data

/datum/appearance_debugger/ui_state(mob/user)
	return tgui_admin_state

/datum/appearance_debugger/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AppearanceDebug")
		ui.open()

/datum/appearance_debugger/ui_static_data(mob/user)
	return list(
		"mainAppearance" = get_appearance_data(debug_target),
		"planeToText" = get_readable_planes(),
		"layerToText" = get_readable_layers(),
		"flagsToText" = list(
			"LONG_GLIDE" = 1,
			"RESET_COLOR" = 2,
			"RESET_ALPHA" = 4,
			"RESET_TRANSFORM" = 8,
			"NO_CLIENT_COLOR" = 16,
			"KEEP_TOGETHER" = 32,
			"KEEP_APART" = 64,
			"PLANE_MASTER" = 128,
			"TILE_BOUND" = 256,
			"PIXEL_SCALE" = 512,
			"PASS_MOUSE" = 1024,
			"TILE_MOVER" = 2048,
		),
		"visToText" = list(
			"VIS_INHERIT_ICON" = 1,
			"VIS_INHERIT_ICON_STATE" = 2,
			"VIS_INHERIT_DIR" = 4,
			"VIS_INHERIT_LAYER" = 8,
			"VIS_INHERIT_PLANE" = 16,
			"VIS_INHERIT_ID" = 32,
			"VIS_UNDERLAY" = 64,
			"VIS_HIDE" = 128,
		),
		"blendToText" = list(
			"0" = "BLEND_DEFAULT",
			"1" = "BLEND_OVERLAY",
			"2" = "BLEND_ADD",
			"3" = "BLEND_SUBTRACT",
			"4" = "BLEND_MULTIPLY",
			"5" = "BLEND_INSET_OVERLAY",
		),
		"mapRefHover" = "",
		"mapRefSelected" = "",
	)

/datum/appearance_debugger/ui_data(mob/user)
	return list(
		"updateWarning" = FALSE,
	)

/datum/appearance_debugger/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("refreshAppearance")
			appearance_copies = list()
			appearance_cache = list()
			tgui_process.update_uis(src)

/datum/appearance_debugger/proc/set_target(datum/new_target)
	debug_target = new_target
	appearance_copies = list()
	appearance_cache = list()

/datum/appearance_debugger/proc/get_readable_planes()
	return list(
		"PLANE_AMBIENT_LIGHTING" = PLANE_AMBIENT_LIGHTING,
		"PLANE_DISTORTION" = PLANE_DISTORTION,
		"PLANE_SPACE" = PLANE_SPACE,
		"PLANE_PARALLAX" = PLANE_PARALLAX,
		"PLANE_UNDERFLOOR" = PLANE_UNDERFLOOR,
		"PLANE_FLOOR" = PLANE_FLOOR,
		"PLANE_WALL" = PLANE_WALL,
		"PLANE_OVERFLOOR" = PLANE_OVERFLOOR,
		"PLANE_NOSHADOW_BELOW" = PLANE_NOSHADOW_BELOW,
		"PLANE_DEFAULT" = PLANE_DEFAULT,
		"PLANE_DEFAULT_NOWARP" = PLANE_DEFAULT_NOWARP,
		"PLANE_NOSHADOW_ABOVE" = PLANE_NOSHADOW_ABOVE,
		"PLANE_NOSHADOW_ABOVE_NOWARP" = PLANE_NOSHADOW_ABOVE_NOWARP,
		"PLANE_HIDDENGAME" = PLANE_HIDDENGAME,
		"PLANE_FOREGROUND_PARALLAX" = PLANE_FOREGROUND_PARALLAX,
		"PLANE_FOREGROUND_PARALLAX_OCCLUSION" = PLANE_FOREGROUND_PARALLAX_OCCLUSION,
		"PLANE_ABOVE_FOREGROUND_PARALLAX" = PLANE_ABOVE_FOREGROUND_PARALLAX,
		"PLANE_LIGHTING" = PLANE_LIGHTING,
		"PLANE_SELFILLUM" = PLANE_SELFILLUM,
		"PLANE_ABOVE_LIGHTING" = PLANE_ABOVE_LIGHTING,
		"PLANE_BLACKNESS" = PLANE_BLACKNESS,
		"PLANE_MOB_OVERLAY" = PLANE_MOB_OVERLAY,
		"PLANE_ABOVE_BLACKNESS" = PLANE_ABOVE_BLACKNESS,
		"PLANE_MASTER_GAME" = PLANE_MASTER_GAME,
		"PLANE_FLOCKVISION" = PLANE_FLOCKVISION,
		"PLANE_OVERLAY_EFFECTS" = PLANE_OVERLAY_EFFECTS,
		"PLANE_MUL_OVERLAY_EFFECTS" = PLANE_MUL_OVERLAY_EFFECTS,
		"PLANE_HUD" = PLANE_HUD,
		"PLANE_ABOVE_HUD" = PLANE_ABOVE_HUD,
		"PLANE_ANTAG_ICONS" = PLANE_ANTAG_ICONS,
		"PLANE_SCREEN_OVERLAYS" = PLANE_SCREEN_OVERLAYS,
	)

/datum/appearance_debugger/proc/get_readable_layers()
	return list(
		"FLOAT_LAYER" = FLOAT_LAYER,
		"AREA_LAYER" = AREA_LAYER,
		"TURF_LAYER" = TURF_LAYER,
		"OBJ_LAYER" = OBJ_LAYER,
		"MOB_LAYER" = MOB_LAYER,
		"FLY_LAYER" = FLY_LAYER,
		"EFFECTS_LAYER_BASE" = EFFECTS_LAYER_BASE,
	)
