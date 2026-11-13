/**
  * # N.B.
  * The current system for locked styles must instantiate a `/datum/customization_style` to determine eligibility for the unlock. This is an ideal
  *	candidate for offloading to the GoonHub API or something so that `/datum/customization_style` only serves static data. As this feature remains
  * completely un-used on the public codebase, the necessary changes could be left on the backburner or we could even fully deprecate style unlock
  * support. Would need to confirm on Secret.
  * - @DisturbHerb
**/

/// `/datum/customization_style` types which are available in character preferences.
var/global/list/always_available_styles = list()
/// `/datum/customization_style` types which are not available in character preferences but are otherwise obtainable without special requirements.
var/global/list/non_setup_styles = list()
/// `/datum/customization_style` types which have special unlock requirements.
var/global/list/locked_styles = list()

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

/**
  * # /proc/get_available_custom_style_types()
  * Returns a list of `/datum/customization_style`s filtered by slot, category, and gender. Can exclude gimmick and non-random types.
  *
  * ## Arguments
  * * `C`: 				Optional, will return any `customization_style`s that the client fulfills the unlock conditions for.
  * * `style_filter`: 	Optional, accepts `CUSTOMIZATION::SLOT` and/or `CUSTOMIZATION::CATEGORY` individually and as a list. Will filter out any
  * 					`customization_style` which fails an equality check (inclusive OR).
  * * `gender`:			Optional, accepts native BYOND gender constants but in practice only `MALE` and `FEMALE` are ever defined on a style. Will
  *						filter out any `customization_style` with a `gender` var mismatch. Usecase limited to character appearance randomization.
  * * `pref_blacklist`:	If `FALSE`, filter out any `customization_style` that is blacklisted from character preferences.
  * * `random_only`:	If `TRUE`, filter out any `customization_style` that is blacklisted from random character appearances.
  * * `bypass_lock`:	If `TRUE`, add all styles with special unlock requirements to the catalog even if `C`, when defined, fails to meet the
  * 					requirements.
**/
/proc/get_available_custom_style_types(client/C, style_filter = CUSTOMIZATION::SLOT::HAIR, gender = null, pref_blacklist = TRUE, random_only = FALSE, bypass_lock = FALSE)
	var/list/output = list()
	var/list/style_catalog = list()

	// Only one check since the three lists are built at the same time.
	if (!length(global.always_available_styles))
		if (!global.build_customization_style_caches())
			CRASH("Customization style type caches were not generated properly!")

	style_catalog += global.always_available_styles

	if (pref_blacklist)
		style_catalog += global.non_setup_styles

	if (bypass_lock)
		style_catalog += global.locked_styles
	else if (isclient(C))
		for (var/locked_style_type in global.locked_styles)
			var/datum/customization_style/locked_style_instance = get_singleton(locked_style_type)
			if (!locked_style_instance.check_available(C))
				continue
			style_catalog += locked_style_type

	for (var/datum/customization_style/style_type as anything in style_catalog)
		if (random_only && !style_type::allow_random)
			continue

		if (gender && style_type::gender)
			// Explicit case for NEUTER, just in case.
			if ((gender != style_type::gender) && (gender != NEUTER))
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

/**
  * # /proc/select_custom_style()
  * Shows `user` a modal of `/datum/customization_style`s they can pick.
  *
  * ## Arguments
  * * `user`: 			Required, the target to show the modal to. Also used to determine eligibility for `customization_style`s with unlock
  *						requirements.
  * * `style_filter`: 	Optional, accepts `CUSTOMIZATION::SLOT` and/or `CUSTOMIZATION::CATEGORY` individually and as a list. Will filter out any
  * 					`customization_style` which fails an equality check (inclusive OR).
  * * `pref_blacklist`:	If `FALSE`, filter out any `customization_style` that is blacklisted from character preferences.
  * * `bypass_lock`:	If `TRUE`, add all styles with special unlock requirements to the catalog even if `user` fails to meet the requirements.
**/
/proc/select_custom_style(mob/living/carbon/human/user, style_filter = CUSTOMIZATION::SLOT::HAIR, pref_blacklist = TRUE, bypass_lock = FALSE)
	var/list/datum/customization_style/options = list()
	for (var/datum/customization_style/style_type as anything in get_available_custom_style_types(user.client, style_filter, pref_blacklist = pref_blacklist, bypass_lock = bypass_lock))
		options[initial(style_type.name)] = style_type
	var/new_style = tgui_input_list(user, "Please select style", "Style", options)
	var/selected_type = options[new_style]
	if (selected_type)
		return new selected_type

/**
  * # /proc/find_style_by_name()
  * Returns a `/datum/customization_style` with `name` matching the input `target_name`.
  *
  * ## Arguments
  * * `target_name`:	The `/datum/customization_style` `name` to match. Strict equality.
  * * `C`: 				Optional, will return any `customization_style`s that the client fulfills the unlock conditions for.
  * * `style_filter`: 	Optional, accepts `CUSTOMIZATION::SLOT` and/or `CUSTOMIZATION::CATEGORY` individually and as a list. Will filter out any
  * 					`customization_style` which fails an equality check (inclusive OR).
  * * `pref_blacklist`:	If `FALSE`, filter out any `customization_style` that is blacklisted from character preferences.
  * * `bypass_lock`:	If `TRUE`, add all styles with special unlock requirements to the catalog even if `user` fails to meet the requirements.
**/
/proc/find_style_by_name(var/target_name, client/C, style_filter = CUSTOMIZATION::SLOT::HAIR, pref_blacklist = TRUE, bypass_lock = FALSE)
	for (var/datum/customization_style/style_type as anything in get_available_custom_style_types(C, style_filter, pref_blacklist = pref_blacklist, bypass_lock = bypass_lock))
		if (cmptext(initial(style_type.name), target_name))
			return new style_type
	stack_trace("Couldn't find a customization_style with the name \"[target_name]\".")
	return new /datum/customization_style/none

/**
  * # /proc/find_style_by_id()
  * Returns a `/datum/customization_style` with `id` matching the input `target_id`.
  *
  * ## Arguments
  * * `target_id`:	The `/datum/customization_style` `id` to match. Strict equality.
  * * `C`: 				Optional, will return any `customization_style`s that the client fulfills the unlock conditions for.
  * * `style_filter`: 	Optional, accepts `CUSTOMIZATION::SLOT` and/or `CUSTOMIZATION::CATEGORY` individually and as a list. Will filter out any
  * 					`customization_style` which fails an equality check (inclusive OR).
  * * `pref_blacklist`:	If `FALSE`, filter out any `customization_style` that is blacklisted from character preferences.
  * * `bypass_lock`:	If `TRUE`, add all styles with special unlock requirements to the catalog even if `user` fails to meet the requirements.
**/
/proc/find_style_by_id(var/target_id, client/C, style_filter = CUSTOMIZATION::SLOT::HAIR, pref_blacklist = TRUE, bypass_lock = FALSE)
	for (var/datum/customization_style/style_type as anything in get_available_custom_style_types(C, style_filter, pref_blacklist = pref_blacklist, bypass_lock = bypass_lock))
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
/// Static data used in customizing physical appearance in character preferences, genetics, barber interactions, etc.
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
