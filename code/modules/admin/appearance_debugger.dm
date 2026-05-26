/client/proc/cmd_debug_appearance(atom/target)
	ADMIN_ONLY
	if (!target)
		return
	var/datum/appearance_debugger/debugger = new(src)
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

	/// Assoc list of appearance_id -> atom ref (for VV)
	var/list/atom_refs

	/// Map preview for hovered node
	var/datum/movable_preview/preview_hover

	/// Map preview for selected node
	var/datum/movable_preview/preview_selected

	/// Whether hover/selected previews have been populated
	var/hover_active = FALSE
	var/selected_active = FALSE

	/// The client that owns this debugger
	var/client/owner

/datum/appearance_debugger/New(client/C)
	..()
	owner = C
	appearance_copies = list()
	appearance_cache = list()
	atom_refs = list()

/datum/appearance_debugger/disposing()
	debug_target = null
	appearance_copies = null
	appearance_cache = null
	if (preview_hover)
		qdel(preview_hover)
		preview_hover = null
	if (preview_selected)
		qdel(preview_selected)
		preview_selected = null
	owner = null
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
		if (isatom(appearance_owner))
			atom_refs["[length(appearance_copies)]"] = appearance_owner
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

	// Display previews - use the appearance's own dir for correct rendering
	// Validate that the icon_state actually exists in the DMI to avoid showing full spritesheets
	if (target.icon && isfile(target.icon))
		try
			var/list/states = icon_states(target.icon)
			var/target_state = target.icon_state || ""
			if (target_state in states)
				var/use_dir = target.dir ? target.dir : SOUTH
				var/icon/used_icon = icon(target.icon, target_state, use_dir, frame = 1)
				if (istext(target.color))
					used_icon.Blend(target.color, ICON_MULTIPLY)
				else if (islist(target.color))
					var/list/cm = target.color
					if (length(cm) >= 12)
						var/r = cm[1]
						var/g = cm[6]
						var/b = cm[11]
						if (r != 1 || g != 1 || b != 1)
							used_icon.Blend(rgb(round(r * 255), round(g * 255), round(b * 255)), ICON_MULTIPLY)
				data["embed_icon"] = icon2base64(used_icon)
			else if (length(target_state))
				data["embed_icon_error"] = "'[target_state]' not found in [target.icon]"
		catch(var/exception/e)
			data["embed_icon_error"] = "Icon generation failed: [e]"

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

	// Handle dynamically modified layers - find nearest known layer if no exact match
	var/list/readable_layers = get_readable_layers()
	var/found_exact = FALSE
	for (var/layer_name in readable_layers)
		if (readable_layers[layer_name] == target.layer)
			found_exact = TRUE
			break
	if (!found_exact)
		// Find nearest layer (closest by absolute distance)
		var/best_name = null
		var/best_dist = INFINITY
		var/best_val = 0
		for (var/layer_name in readable_layers)
			var/val = readable_layers[layer_name]
			var/dist = abs(target.layer - val)
			if (dist < best_dist)
				best_dist = dist
				best_val = val
				best_name = layer_name
		if (best_name)
			var/offset = round(target.layer - best_val, 0.001)
			if (offset == 0)
				data["layer_text_override"] = best_name
			else
				data["layer_text_override"] = "[best_name] ([offset > 0 ? "+" : ""][offset])"

	return data

/datum/appearance_debugger/ui_state(mob/user)
	return tgui_admin_state

/datum/appearance_debugger/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AppearanceDebug")
		ui.open()
	if (!preview_hover)
		preview_hover = new(owner, ui.window.id, "appearance_debug_hover")
	if (!preview_selected)
		preview_selected = new(owner, ui.window.id, "appearance_debug_selected")

/datum/appearance_debugger/ui_static_data(mob/user)
	return list(
		"mainAppearance" = get_appearance_data(debug_target),
		"planeToText" = get_readable_planes(),
		"layerToText" = get_readable_layers(),
		"flagsToText" = list(
			"LONG_GLIDE" = LONG_GLIDE,
			"RESET_COLOR" = RESET_COLOR,
			"RESET_ALPHA" = RESET_ALPHA,
			"RESET_TRANSFORM" = RESET_TRANSFORM,
			"NO_CLIENT_COLOR" = NO_CLIENT_COLOR,
			"KEEP_TOGETHER" = KEEP_TOGETHER,
			"KEEP_APART" = KEEP_APART,
			"PLANE_MASTER" = PLANE_MASTER,
			"TILE_BOUND" = TILE_BOUND,
			"PIXEL_SCALE" = PIXEL_SCALE,
			"PASS_MOUSE" = PASS_MOUSE,
			"TILE_MOVER" = TILE_MOVER,
		),
		"visToText" = list(
			"VIS_INHERIT_ICON" = VIS_INHERIT_ICON,
			"VIS_INHERIT_ICON_STATE" = VIS_INHERIT_ICON_STATE,
			"VIS_INHERIT_DIR" = VIS_INHERIT_DIR,
			"VIS_INHERIT_LAYER" = VIS_INHERIT_LAYER,
			"VIS_INHERIT_PLANE" = VIS_INHERIT_PLANE,
			"VIS_INHERIT_ID" = VIS_INHERIT_ID,
			"VIS_UNDERLAY" = VIS_UNDERLAY,
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
		"mapRefHover" = hover_active ? (preview_hover?.preview_id || "") : "",
		"mapRefSelected" = selected_active ? (preview_selected?.preview_id || "") : "",
	)

/datum/appearance_debugger/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("refreshAppearance")
			appearance_copies = list()
			appearance_cache = list()
			atom_refs = list()
			tgui_process.update_uis(src)

		if("swapMapViewHover")
			var/appearance_id = text2num(params["id"])
			if (appearance_id && appearance_id <= length(appearance_copies) && preview_hover)
				hover_active = TRUE
				var/mutable_appearance/hover_app = appearance_copies[appearance_id]
				preview_hover.preview_thing.appearance = hover_app
				preview_hover.preview_thing.plane = PLANE_DEFAULT
				preview_hover.preview_thing.layer = MOB_LAYER
				preview_hover.preview_thing.pixel_x = 0
				preview_hover.preview_thing.pixel_y = 0
				preview_hover.preview_thing.pixel_w = 0
				preview_hover.preview_thing.pixel_z = 0
				preview_hover.preview_thing.transform = null
				preview_hover.preview_thing.alpha = 255
				preview_hover.preview_thing.overlays = null
				preview_hover.preview_thing.underlays = null
				preview_hover.preview_thing.screen_loc = "[preview_hover.preview_id];1,1"

		if("swapMapViewSelected")
			var/appearance_id = text2num(params["id"])
			if (appearance_id && appearance_id <= length(appearance_copies) && preview_selected)
				selected_active = TRUE
				var/mutable_appearance/selected_app = appearance_copies[appearance_id]
				preview_selected.preview_thing.appearance = selected_app
				preview_selected.preview_thing.plane = PLANE_DEFAULT
				preview_selected.preview_thing.layer = MOB_LAYER
				preview_selected.preview_thing.pixel_x = 0
				preview_selected.preview_thing.pixel_y = 0
				preview_selected.preview_thing.pixel_w = 0
				preview_selected.preview_thing.pixel_z = 0
				preview_selected.preview_thing.transform = null
				preview_selected.preview_thing.alpha = 255
				preview_selected.preview_thing.overlays = null
				preview_selected.preview_thing.underlays = null
				preview_selected.preview_thing.screen_loc = "[preview_selected.preview_id];1,1"

		if("vvAppearance")
			var/appearance_id = text2num(params["id"])
			if (appearance_id && atom_refs["[appearance_id]"])
				owner.debug_variables(atom_refs["[appearance_id]"])

/datum/appearance_debugger/ui_close(mob/user)
	qdel(src)

/datum/appearance_debugger/proc/set_target(datum/new_target)
	debug_target = new_target
	appearance_copies = list()
	appearance_cache = list()
	atom_refs = list()

/datum/appearance_debugger/proc/get_readable_planes()
	return list(
		"FLOAT_PLANE" = -32767,
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
		"PLATING_LAYER" = PLATING_LAYER,
		"BETWEEN_FLOORS_LAYER" = BETWEEN_FLOORS_LAYER,
		"TURF_LAYER" = TURF_LAYER,
		"LATTICE_LAYER" = LATTICE_LAYER,
		"DISPOSAL_PIPE_LAYER" = DISPOSAL_PIPE_LAYER,
		"PIPE_LAYER" = PIPE_LAYER,
		"FLUID_PIPE_LAYER" = FLUID_PIPE_LAYER,
		"CATWALK_LAYER" = CATWALK_LAYER,
		"CABLE_LAYER" = CABLE_LAYER,
		"PIPE_MACHINE_LAYER" = PIPE_MACHINE_LAYER,
		"DECAL_LAYER" = DECAL_LAYER,
		"FLUID_LAYER" = FLUID_LAYER,
		"FLUID_AIR_LAYER" = FLUID_AIR_LAYER,
		"FLOOR_EQUIP_LAYER1" = FLOOR_EQUIP_LAYER1,
		"FLOOR_EQUIP_LAYER2" = FLOOR_EQUIP_LAYER2,
		"AI_RAIL_LAYER" = AI_RAIL_LAYER,
		"UNDERFLOOR_MACHINE" = UNDERFLOOR_MACHINE,
		"TURF_EFFECTS_LAYER" = TURF_EFFECTS_LAYER,
		"GRILLE_LAYER" = GRILLE_LAYER,
		"COG2_WINDOW_LAYER" = COG2_WINDOW_LAYER,
		"SUB_TAG_LAYER" = SUB_TAG_LAYER,
		"TAG_LAYER" = TAG_LAYER,
		"DOOR_LAYER" = DOOR_LAYER,
		"STORAGE_LAYER" = STORAGE_LAYER,
		"OBJ_LAYER" = OBJ_LAYER,
		"ABOVE_OBJ_LAYER" = ABOVE_OBJ_LAYER,
		"MOB_LAYER_BASE" = MOB_LAYER_BASE,
		"MOB_LAYER" = MOB_LAYER,
		"FLY_LAYER" = FLY_LAYER,
		"EFFECTS_LAYER_UNDER_4" = EFFECTS_LAYER_UNDER_4,
		"EFFECTS_LAYER_UNDER_3" = EFFECTS_LAYER_UNDER_3,
		"EFFECTS_LAYER_UNDER_2" = EFFECTS_LAYER_UNDER_2,
		"EFFECTS_LAYER_UNDER_1" = EFFECTS_LAYER_UNDER_1,
		"EFFECTS_LAYER_BASE" = EFFECTS_LAYER_BASE,
		"EFFECTS_LAYER_1" = EFFECTS_LAYER_1,
		"EFFECTS_LAYER_2" = EFFECTS_LAYER_2,
		"EFFECTS_LAYER_3" = EFFECTS_LAYER_3,
		"EFFECTS_LAYER_4" = EFFECTS_LAYER_4,
		"OVERLAY_EFFECT_LAYER_BASE" = OVERLAY_EFFECT_LAYER_BASE,
		"TILE_EFFECT_OVERLAY_LAYER_LIGHTING" = TILE_EFFECT_OVERLAY_LAYER_LIGHTING,
		"TILE_EFFECT_OVERLAY_LAYER" = TILE_EFFECT_OVERLAY_LAYER,
		"NOLIGHT_EFFECTS_LAYER_BASE" = NOLIGHT_EFFECTS_LAYER_BASE,
		"NOLIGHT_EFFECTS_LAYER_1" = NOLIGHT_EFFECTS_LAYER_1,
		"NOLIGHT_EFFECTS_LAYER_2" = NOLIGHT_EFFECTS_LAYER_2,
		"NOLIGHT_EFFECTS_LAYER_3" = NOLIGHT_EFFECTS_LAYER_3,
		"NOLIGHT_EFFECTS_LAYER_4" = NOLIGHT_EFFECTS_LAYER_4,
		"HUD_LAYER_UNDER_4" = HUD_LAYER_UNDER_4,
		"HUD_LAYER_UNDER_3" = HUD_LAYER_UNDER_3,
		"HUD_LAYER_UNDER_2" = HUD_LAYER_UNDER_2,
		"HUD_LAYER_UNDER_1" = HUD_LAYER_UNDER_1,
		"HUD_LAYER" = HUD_LAYER,
		"HUD_LAYER_1" = HUD_LAYER_1,
		"HUD_LAYER_2" = HUD_LAYER_2,
		"HUD_LAYER_3" = HUD_LAYER_3,
		"MOB_OVERLAY_BASE" = MOB_OVERLAY_BASE,
		"MOB_LAYER_OVER_FUCKING_EVERYTHING_LAYER" = MOB_LAYER_OVER_FUCKING_EVERYTHING_LAYER,
		"MOB_OVER_TOP_LAYER" = MOB_OVER_TOP_LAYER,
		"MOB_BACK_SUIT_LAYER" = MOB_BACK_SUIT_LAYER,
		"MOB_FULL_SUIT_LAYER" = MOB_FULL_SUIT_LAYER,
		"MOB_EFFECT_LAYER" = MOB_EFFECT_LAYER,
		"MOB_HANDCUFF_LAYER" = MOB_HANDCUFF_LAYER,
		"MOB_INHAND_LAYER" = MOB_INHAND_LAYER,
		"MOB_HEAD_LAYER2" = MOB_HEAD_LAYER2,
		"MOB_OVERMASK_LAYER" = MOB_OVERMASK_LAYER,
		"MOB_HEAD_LAYER1" = MOB_HEAD_LAYER1,
		"MOB_EARS_LAYER" = MOB_EARS_LAYER,
		"MOB_GLASSES_LAYER2" = MOB_GLASSES_LAYER2,
		"MOB_HAIR_LAYER2" = MOB_HAIR_LAYER2,
		"MOB_GLASSES_LAYER" = MOB_GLASSES_LAYER,
		"MOB_BACK_LAYER" = MOB_BACK_LAYER,
		"MOB_OVERSUIT_LAYER1" = MOB_OVERSUIT_LAYER1,
		"MOB_OVERSUIT_LAYER2" = MOB_OVERSUIT_LAYER2,
		"MOB_SHEATH_LAYER" = MOB_SHEATH_LAYER,
		"MOB_BACK_LAYER_SATCHEL" = MOB_BACK_LAYER_SATCHEL,
		"MOB_ARMOR_LAYER" = MOB_ARMOR_LAYER,
		"MOB_HAND_LAYER2" = MOB_HAND_LAYER2,
		"MOB_HAND_LAYER1" = MOB_HAND_LAYER1,
		"MOB_BELT_LAYER" = MOB_BELT_LAYER,
		"MOB_HAIR_LAYER1" = MOB_HAIR_LAYER1,
		"MOB_FACE_LAYER" = MOB_FACE_LAYER,
		"MOB_CLOTHING_LAYER" = MOB_CLOTHING_LAYER,
		"MOB_UNDERWEAR_LAYER" = MOB_UNDERWEAR_LAYER,
		"MOB_DAMAGE_LAYER" = MOB_DAMAGE_LAYER,
		"MOB_BODYDETAIL_LAYER3" = MOB_BODYDETAIL_LAYER3,
		"MOB_BODYDETAIL_LAYER2" = MOB_BODYDETAIL_LAYER2,
		"MOB_BODYDETAIL_LAYER1" = MOB_BODYDETAIL_LAYER1,
		"MOB_LIMB_LAYER" = MOB_LIMB_LAYER,
		"MOB_TAIL_LAYER2" = MOB_TAIL_LAYER2,
		"MOB_TAIL_LAYER1" = MOB_TAIL_LAYER1,
	)
