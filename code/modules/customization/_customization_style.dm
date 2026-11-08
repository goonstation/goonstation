/// `/datum/customization_style` types which are available in character preferences.
var/global/list/always_available_styles = list()
/// `/datum/customization_style` types which are not available in character preferences but are otherwise obtainable without special requirements.
var/global/list/non_setup_styles = list()
/// `/datum/customization_style` types which have special unlock requirements.
var/global/list/locked_styles = list()

/// Returns a list of `/datum/customization_style`s filtered by slot, category, and gender. Can exclude gimmick and non-random types. If a client `C`
/// is provided, this will also return any `/datum/customization_style`s that the client fulfills the unlock conditions for.
///
/// `style_filter` can accept individual slots in `CUSTOMIZATION::SLOT` or types in `CUSTOMIZATION::CATEGORY`, either individually or as a `/list`.
/proc/get_available_custom_style_types(client/C, style_filter = CUSTOMIZATION::SLOT::HAIR, gender = null, allow_pref_blacklist = TRUE, random_only = FALSE)
	var/list/output = list()
	var/list/style_catalog = list()

	// Only one check since the three lists are built at the same time.
	if (!length(global.always_available_styles))
		if (!global.build_customization_style_caches())
			CRASH("Customization style type caches were not generated properly!")

	style_catalog += global.always_available_styles

	if (allow_pref_blacklist)
		style_catalog += global.non_setup_styles

	if (isclient(C))
		for (var/locked_style_type in global.locked_styles)
			var/datum/customization_style/locked_style_instance = get_singleton(locked_style_type)
			if (!locked_style_instance.check_available(C))
				continue
			style_catalog += locked_style_type

	for (var/datum/customization_style/style_type as anything in style_catalog)
		if (random_only && !style_type::allow_random)
			continue
		if (gender && style_type::gender && (style_type::gender != gender))
			continue

		var/typeinfo/datum/customization_style/style_typeinfo = get_type_typeinfo(style_type)

		// If there's no style_filter, just put it on the thing.
		// Add the universal /datum/customization_style/none and any other god-foresaken un-sorted style to the list.
		if (!style_filter || (!style_typeinfo.style_slot && !style_typeinfo.style_category))
			output += style_type
			continue

		// If style_filter is a list of CUSTOMIZATION::SLOT or CUSTOMIZATION::CATEGORY constants.
		if (islist(style_filter) && length(style_filter))
			for (var/filter_item in style_filter)
				if ((filter_item != style_typeinfo.style_slot) && (filter_item != style_typeinfo.style_category))
					continue
				output += style_type
				break

		// For individual CUSTOMIZATION::SLOT or CUSTOMIZATION::CATEGORY filters.
		else if ((style_filter == style_typeinfo.style_slot) || (style_filter == style_typeinfo.style_category))
			output += style_type

	output = length(output) ? sortListCopy(output, /proc/cmp_customization_style) : output
	. = output

/// Generates the lists of `/datum/customization_style` types for future recall.
/proc/build_customization_style_caches()
	. = TRUE

	var/list/always_available_buffer = list()
	var/list/non_setup_buffer = list()
	var/list/locked_buffer = list()

	for (var/datum/customization_style/style_type as anything in concrete_typesof(/datum/customization_style))
		if (style_type::req_unlock)
			locked_buffer += style_type
			continue
		if (!style_type::allow_prefs)
			non_setup_buffer += style_type
			continue
		always_available_buffer += style_type

	if (!length(always_available_buffer) && !length(non_setup_buffer) && !length(locked_buffer))
		return FALSE

	global.always_available_styles = always_available_buffer
	global.non_setup_styles = non_setup_buffer
	global.locked_styles = locked_buffer

/// For sorting `/datum/customization_style`s when displayed as a list.
/proc/cmp_customization_style(datum/customization_style/a, datum/customization_style/b)
	var/typeinfo/datum/customization_style/typeinfo_a = get_type_typeinfo(a)
	var/typeinfo/datum/customization_style/typeinfo_b = get_type_typeinfo(b)

	return cmp_numeric_asc(CUSTOMIZATION.sort_order.Find(typeinfo_a.style_category), CUSTOMIZATION.sort_order.Find(typeinfo_b.style_category))

/proc/select_custom_style(mob/living/carbon/human/user, style_filter = CUSTOMIZATION::SLOT::HAIR, allow_pref_blacklist = TRUE)
	var/list/datum/customization_style/options = list()
	for (var/datum/customization_style/style_type as anything in get_available_custom_style_types(user.client, style_filter, allow_pref_blacklist = allow_pref_blacklist))
		options[initial(style_type.name)] = style_type
	var/new_style = tgui_input_list(user, "Please select style", "Style", options)
	var/selected_type = options[new_style]
	if (selected_type)
		return new selected_type

/proc/find_style_by_name(var/target_name, client/C, style_filter = CUSTOMIZATION::SLOT::HAIR, allow_pref_blacklist = TRUE)
	for (var/datum/customization_style/style_type as anything in get_available_custom_style_types(C, style_filter, allow_pref_blacklist = allow_pref_blacklist))
		if (cmptext(initial(style_type.name), target_name))
			return new style_type
	stack_trace("Couldn't find a customization_style with the name \"[target_name]\".")
	return new /datum/customization_style/none

/proc/find_style_by_id(var/target_id, client/C, style_filter = CUSTOMIZATION::SLOT::HAIR, allow_pref_blacklist = TRUE)
	for (var/datum/customization_style/style_type as anything in get_available_custom_style_types(C, style_filter, allow_pref_blacklist = allow_pref_blacklist))
		if (initial(style_type.id) == target_id)
			return new style_type
	stack_trace("Couldn't find a customization_style with the id \"[target_id]\".")
	return new /datum/customization_style/none

TYPEINFO(/datum/customization_style)
	/// Affects which `/datum/customization_slot/`s this can be equipped in.
	/// See `CUSTOMIZATION::SLOT` namespace and `/datum/customization_slot/var/slot_type`.
	var/style_slot = null
	/// `/datum/customization_style`s are organized into categories which affect sort order in lists.
	/// For hair: scissors and razor blades can only apply certain categories of styles to a `/datum/customization_slot/`.
	/// See `CUSTOMIZATION::CATEGORY` namespace.
	var/style_category = null

/// /datum/customization_style
/// Used in customizing physical appearance in character preferences, genetics, barber interactions, etc.
ABSTRACT_TYPE(/datum/customization_style)
/datum/customization_style
	/// Display name.
	var/name = null
	/// Same as `icon_state`.
	var/id = null
	/// Affects character appearance randomization ONLY.
	var/gender = null

	/// Which mob icon layer this should go on (under or over glasses).
	/// Under by default, more direct subtypes where that makes sense.
	var/default_layer = MOB_HAIR_LAYER1
	/// Icon file this style should be pulled from.
	var/icon = 'icons/mob/human_hair.dmi'

	/// Does this style have some special unlock condition? (medal, rank, etc.)
	var/req_unlock = FALSE
	/// If `FALSE`, blacklist from Character Prefs.
	var/allow_prefs = TRUE
	/// For blacklisting the weird partial hairstyles that just look broken on random characters.
	var/allow_random = TRUE

/// Only used if `src.req_unlock` is TRUE.
/datum/customization_style/proc/check_available(client/C)
	return TRUE

/datum/customization_style/none
	name = "None"
	id = "none"
