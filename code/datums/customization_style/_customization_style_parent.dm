var/global/list/customization_style_order = list(
	/datum/customization_style/none,

	/datum/customization_style/hair/short,
	/datum/customization_style/hair/long,
	/datum/customization_style/hair/hairup,
	/datum/customization_style/hair/gimmick,
	/datum/customization_style/hair/facial,
	/datum/customization_style/hair/eyebrows,
	/datum/customization_style/hair/makeup,
	/datum/customization_style/hair/biological,
)

TYPEINFO(/datum/customization_style)
	/// For filtering out different types.
	var/style_type = null
	/// Does this style have some special unlock condition? (medal, rank, etc.)
	var/special_criteria = FALSE
	/// Is this a gimmick style? Exclude it from Character Prefs.
	/// Currently used by /datum/customization_style/hair.
	var/gimmick = FALSE
ABSTRACT_TYPE(/datum/customization_style)
/// Used in customizing physical appearance in Character Prefs, Genetics, barber, etc.
/datum/customization_style
	var/name = null
	var/id = null
	var/gender = null
	/// Which mob icon layer this should go on (under or over glasses).
	/// Under by default, more direct subtypes where that makes sense.
	var/default_layer = MOB_HAIR_LAYER1
	/// Icon file this style should be pulled from.
	var/icon = 'icons/mob/human_hair.dmi'
	/// For blacklisting the weird partial hairstyles that just look broken on random characters.
	var/random_allowed = TRUE
	/// Affects sort order when displayed as part of a list.
	var/weight = 0

/// Only used if typeinfo.special_criteria is TRUE.
/datum/customization_style/proc/check_available(client/C)
	return TRUE

/datum/customization_style/none
	name = "None"
	id = "none"

/proc/select_custom_style(mob/living/carbon/human/user, style_filter = CUSTOMIZATION::SLOT::HAIR, no_gimmick = FALSE)
	var/list/datum/customization_style/options = list()
	for (var/datum/customization_style/styletype as anything in get_available_custom_style_types(user.client, style_filter, no_gimmick = no_gimmick))
		options[initial(styletype.name)] = styletype
	var/new_style = tgui_input_list(user, "Please select style", "Style", options)
	var/selected_type = options[new_style]
	if (selected_type)
		return new selected_type

/proc/find_style_by_name(var/target_name, client/C, style_filter = CUSTOMIZATION::SLOT::HAIR, no_gimmick = FALSE)
	for (var/datum/customization_style/styletype as anything in get_available_custom_style_types(C, style_filter, no_gimmick = no_gimmick))
		if(cmptext(initial(styletype.name), target_name))
			return new styletype
	stack_trace("Couldn't find a customization_style with the name \"[target_name]\".")
	return new /datum/customization_style/none

/proc/find_style_by_id(var/target_id, client/C, style_filter = CUSTOMIZATION::SLOT::HAIR, no_gimmick = FALSE)
	for (var/datum/customization_style/styletype as anything in get_available_custom_style_types(C, style_filter, no_gimmick = no_gimmick))
		if(initial(styletype.id) == target_id)
			return new styletype
	stack_trace("Couldn't find a customization_style with the id \"[target_id]\".")
	return new /datum/customization_style/none

/proc/build_customization_style_list()
	var/customization_style_list_buffer = list()

	for (var/customization_style_path in global.customization_style_order)
		if (!ispath(customization_style_path, /datum/customization_style))
			continue
		customization_style_list_buffer += concrete_typesof(customization_style_path)

	. = customization_style_list_buffer

/// Gets all the customization_styles which are available to a given client. Can be filtered by slot, type, and gender. Can exclude gimmick and
/// non-random types.
///
/// `style_filter` can be within the `CUSTOMIZATION::SLOT` namespace, or any customization style type namespace.
proc/get_available_custom_style_types(client/C, style_filter = CUSTOMIZATION::SLOT::HAIR, gender = null, no_gimmick = FALSE, random_only = FALSE)
	// Defining static vars with no value doesn't overwrite them with null if we call the proc multiple times
	// Styles with no restriction
	var/static/list/always_available
	// Styles which aren't available in char setup but are available everywhere else
	var/static/list/gimmick_styles
	// Styles which have special unlock requirements
	var/static/list/locked_styles

	// only one check since the 3 lists are built at the same time
	if (!always_available)
		always_available = list()
		gimmick_styles = list()
		locked_styles = list()
		for (var/datum/customization_style/styletype as anything in build_customization_style_list())
			var/typeinfo/datum/customization_style/typeinfo = get_type_typeinfo(styletype)
			if (style_filter && typeinfo.style_type)
				if ((style_filter != typeinfo.style_type) && (style_filter != CUSTOMIZATION.types_to_slot[typeinfo.style_type]))
					continue
			if (!typeinfo.special_criteria)
				if (!typeinfo.gimmick)
					always_available += styletype
				else
					gimmick_styles += styletype
			else
				locked_styles += styletype

	var/list/available = always_available.Copy()
	if (!no_gimmick)
		available += gimmick_styles

	if (C)
		for (var/style in locked_styles)
			var/datum/customization_style/instance = new style()
			if (instance.check_available(C))
				available += style

	for (var/datum/customization_style/style as anything in available)
		var/style_gender = initial(style.gender)
		if (gender && style_gender && !(style_gender & gender))
			available -= style
			continue
		if (random_only && !(initial(style.random_allowed)))
			available -= style
			continue

	return available
