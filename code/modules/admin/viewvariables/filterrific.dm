/**
* @file
* @copyright 2020
* @author actioninja  (https://github.com/actioninja )
* @license MIT
*/

#define COLOR_HALF_TRANSPARENT_BLACK    "#0000007A"
#define COLOR_BLACK						"#000"
#define COLOR_WHITE						"#FFF"

/datum/filter_editor
	var/atom/target

/datum/filter_editor/New(atom/target)
	. = ..()
	src.target = target

/datum/filter_editor/ui_state(mob/user)
	return tgui_admin_state

/datum/filter_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Filteriffic")
		ui.open()

/datum/filter_editor/ui_static_data(mob/user)
	var/list/data = list()
	data["filter_info"] = master_filter_info
	return data

/datum/filter_editor/ui_data()
	var/list/data = list()
	data["target_name"] = target.name
	data["target_filter_data"] = target.filter_data
	return data

/datum/filter_editor/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("add_filter")
			var/target_name = params["name"]
			while(target.filter_data && target.filter_data[target_name])
				target_name = "[target_name]-dupe"
			target.add_filter(target_name, params["priority"], list("type" = params["type"]))
			. = TRUE
		if("remove_filter")
			target.remove_filter(params["name"])
			. = TRUE
		if("rename_filter")
			var/list/filter_data = target.filter_data[params["name"]]
			target.remove_filter(params["name"])
			target.add_filter(params["new_name"], filter_data["priority"], filter_data)
			. = TRUE
		if("edit_filter")
			target.remove_filter(params["name"])
			target.add_filter(params["name"], params["priority"], params["new_filter"])
			. = TRUE
		if("change_priority")
			var/new_priority = params["new_priority"]
			target.change_filter_priority(params["name"], new_priority)
			. = TRUE
		if("transition_filter_value")
			target.transition_filter(params["name"], 4, params["new_data"])
			. = TRUE
		if("modify_filter_value")
			var/list/old_filter_data = target.filter_data[params["name"]]
			var/list/new_filter_data = old_filter_data.Copy()
			for(var/entry in params["new_data"])
				new_filter_data[entry] = params["new_data"][entry]
			for(var/entry in new_filter_data)
				if(entry == master_filter_info[old_filter_data["type"]]["defaults"][entry])
					new_filter_data.Remove(entry)
			target.remove_filter(params["name"])
			target.add_filter(params["name"], old_filter_data["priority"], new_filter_data)
			. = TRUE
		if("modify_color_value")
			var/new_color = input(usr, "Pick new filter color", "Filteriffic Colors!") as color|null
			if(new_color)
				target.transition_filter(params["name"], 4, list("color" = new_color))
				. = TRUE
		if("convert_color_value_matrix")
			var/new_color = normalize_color_to_matrix(target.filter_data[params["name"]]["color"])
			if(new_color)
				target.transition_filter(params["name"], 4, list("color" = new_color))
				. = TRUE
		if("modify_icon_value")
			var/icon/new_icon = input("Pick icon:", "Icon") as null|icon
			if(new_icon)
				target.filter_data[params["name"]]["icon"] = new_icon
				target.update_filters()
				. = TRUE
		if("mass_apply")
			// if(!check_rights_for(usr.client, R_FUN))
			// 	to_chat(usr, "<span class='userdanger>Stay in your lane, jannie.</span>'")
			// 	return
			var/target_path = text2path(params["path"])
			if(!target_path)
				return
			var/filters_to_copy = target.filters
			var/filter_data_to_copy = target.filter_data
			var/count = 0
			for(var/atom/target as anything in find_all_by_type(target_path))
				target.filters = filters_to_copy
				target.filter_data = filter_data_to_copy
				count += 1
			//message_admins("LOCAL CLOWN [usr.ckey] JUST MASS FILTER EDITED [count] WITH PATH OF [params["path"]]!")
			//log_admin("LOCAL CLOWN [usr.ckey] JUST MASS FILTER EDITED [count] WITH PATH OF [params["path"]]!")

#define ICON_NOT_SET "Not Set"

//This is stored as a nested list instead of datums or whatever because it json encodes nicely for usage in tgui
var/static/master_filter_info = list(
	"alpha" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"icon" = ICON_NOT_SET,
			"render_source" = "",
			"flags" = 0
		),
		"flags" = list(
			"MASK_INVERSE" = MASK_INVERSE,
			"MASK_SWAP" = MASK_SWAP
		)
	),
	"angular_blur" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 1
		)
	),
	"color" = list(
		"defaults" = list(
			"color" = COLOR_WHITE,
			"space" = COLORSPACE_RGB
			),
		"space" = list(
			"RGB" = COLORSPACE_RGB,
			"HSV" = COLORSPACE_HSV,
			"HSL" = COLORSPACE_HSL,
			"HCY" = COLORSPACE_HCY
		)
	),
	"displace" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = null,
			"icon" = ICON_NOT_SET,
			"render_source" = ""
		)
	),
	"drop_shadow" = list(
		"defaults" = list(
			"x" = 1,
			"y" = -1,
			"size" = 1,
			"offset" = 0,
			"color" = COLOR_HALF_TRANSPARENT_BLACK
		)
	),
	"blur" = list(
		"defaults" = list(
			"size" = 1
		)
	),
	"layer" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"icon" = ICON_NOT_SET,
			"render_source" = "",
			"flags" = FILTER_OVERLAY,
			"color" = "",
			"transform" = null,
			"blend_mode" = BLEND_DEFAULT,
		),
		"blend_mode" = list(
				"BLEND_DEFAULT" = BLEND_DEFAULT,
				"BLEND_OVERLAY" = BLEND_OVERLAY,
				"BLEND_ADD" = BLEND_ADD,
				"BLEND_SUBTRACT" = BLEND_SUBTRACT,
				"BLEND_MULTIPLY" = BLEND_MULTIPLY,
				"BLEND_INSET_OVERLAY" = BLEND_INSET_OVERLAY,
			)
	),

	"motion_blur" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0
		)
	),
	"outline" = list(
		"defaults" = list(
			"size" = 0,
			"color" = COLOR_BLACK,
			"flags" = 0
		),
		"flags" = list(
			"OUTLINE_SHARP" = OUTLINE_SHARP,
			"OUTLINE_SQUARE" = OUTLINE_SQUARE
		)
	),
	"radial_blur" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 0.01
		)
	),
	"rays" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 16,
			"color" = COLOR_WHITE,
			"offset" = 0,
			"density" = 10,
			"threshold" = 0.5,
			"factor" = 0,
			"flags" = FILTER_OVERLAY | FILTER_UNDERLAY
		),
		"flags" = list(
			"FILTER_OVERLAY" = FILTER_OVERLAY,
			"FILTER_UNDERLAY" = FILTER_UNDERLAY
		)
	),
	"ripple" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 1,
			"repeat" = 2,
			"radius" = 0,
			"falloff" = 1,
			"flags" = 0
		),
		"flags" = list(
			"WAVE_BOUNDED" = WAVE_BOUNDED
		)
	),
	"wave" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 1,
			"offset" = 0,
			"flags" = 0
		),
		"flags" = list(
			"WAVE_SIDEWAYS" = WAVE_SIDEWAYS,
			"WAVE_BOUNDED" = WAVE_BOUNDED
		)
	)
)

#undef ICON_NOT_SET
