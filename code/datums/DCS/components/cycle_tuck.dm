// I beg for `toggle_hood.dm`, `toggle_coat.dm`, and this to be unified at some point. This is not the time. - DisturbHerb
#define UNTUCK ""
#define HALF_TUCK "half_tuck"
#define FULL_TUCK "full_tuck"

/datum/component/cycle_tuck
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/current_style_index = 1
	var/base_name = ""
	var/list/styles = list(
		UNTUCK,
		HALF_TUCK,
		FULL_TUCK,
	)
	var/obj/item/clothing/under/misc/collar_shirt/shirt = null
	var/obj/ability_button/tuck_cycle/toggle = new

/datum/component/cycle_tuck/Initialize(current_style, base_name)
	. = ..()
	if(!istype(src.parent, /obj/item/clothing/under/misc/collar_shirt))
		return COMPONENT_INCOMPATIBLE
	src.current_style_index = src.styles.Find(current_style) || 1
	src.base_name = base_name || "collar_shirt-white"
	src.shirt = src.parent
	LAZYLISTADD(src.shirt.ability_buttons, src.parent)
	src.shirt.ability_buttons += src.toggle
	src.toggle.the_item = shirt
	src.toggle.name = src.toggle.name + " ([shirt.name])"
	RegisterSignal(src.parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(cycle_style))
	RegisterSignal(src.parent, COMSIG_ATOM_POST_UPDATE_ICON, PROC_REF(shirt_icon))

/datum/component/cycle_tuck/proc/cycle_style(atom/movable/thing, mob/user)
	src.current_style_index = src.current_style_index >= length(src.styles) ? 1 : src.current_style_index + 1
	if (ismob(src.shirt.loc))
		var/mob/M = src.shirt.loc
		M.set_clothing_icon_dirty()
	src.shirt.UpdateIcon()

	switch (src.styles[src.current_style_index])
		if (UNTUCK)
			user.visible_message("[user] untucks [his_or_her(user)] [src.shirt.name] from [his_or_her(user)] trousers.",\
			"You untuck your [src.shirt.name] from your trousers.")
		if (HALF_TUCK)
			user.visible_message("[user] half-tucks [his_or_her(user)] [src.shirt.name] into [his_or_her(user)] trousers.",\
			"You half-tuck your [src.shirt.name] into your trousers.")
		if (FULL_TUCK)
			user.visible_message("[user] fully tucks [his_or_her(user)] [src.shirt.name] into [his_or_her(user)] trousers.",\
			"You fully tuck your [src.shirt.name] into your trousers.")

/datum/component/cycle_tuck/proc/shirt_icon()
	src.shirt.wear_state = "[src.base_name][src.styles[src.current_style_index] ? "-[src.styles[src.current_style_index]]" : ""]"
	var/next_style = src.styles[(src.current_style_index >= length(src.styles) ? 1 : src.current_style_index + 1)]
	src.toggle.icon_state = "shirt[next_style ? "-[next_style]" : ""]"

/datum/component/cycle_tuck/UnregisterFromParent()
	UnregisterSignal(src.parent, COMSIG_ITEM_ATTACK_SELF)
	UnregisterSignal(src.parent, COMSIG_ATOM_POST_UPDATE_ICON)
	src.shirt.ability_buttons -= src.toggle
	src.shirt = null
	qdel(src.toggle)
	src.toggle = null
	. = ..()

#undef UNTUCK
#undef HALF_TUCK
#undef FULL_TUCK
