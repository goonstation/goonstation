/datum/component/wearertargeting/alpha_clothing
	var/dm_filter/filter
	var/obj/effect/effect
	var/obj/item/item_parent

/datum/component/wearertargeting/alpha_clothing/Initialize()
	. = ..()
	if (!isitem(src.parent))
		return COMPONENT_INCOMPATIBLE

	src.item_parent = src.parent // cast for convenience

	// concept stolen from dwarf because pali smart
	src.effect = new()
	src.effect.render_target = ref(src.item_parent)
	src.effect.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR
	src.effect.vis_flags = VIS_INHERIT_DIR
	src.effect.icon = icon(src.item_parent.wear_image_icon, src.item_parent.icon_state)

	src.filter = alpha_mask_filter(render_source=src.effect.render_target, flags=MASK_INVERSE)


/datum/component/wearertargeting/alpha_clothing/on_equip(datum/source, mob/equipper, slot)
	. = ..()
	// current_user will be set in parent if we're in a valid wear slot
	if (src.current_user)
		src.current_user.add_filter("clothing_[ref(src)]", 0, src.filter) // 0 because we want to correctly distort for displacement/blur/etc
		src.current_user.vis_contents += src.effect

/datum/component/wearertargeting/alpha_clothing/on_unequip(datum/source, mob/user)
	if (src.current_user)
		src.current_user.remove_filter("clothing_[ref(src)]")
		src.current_user.vis_contents -= src.effect
	. = ..()
