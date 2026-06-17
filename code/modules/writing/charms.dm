#define is_blood(x) (x in list("blood", "bloodc", "hemolymph", "martian_flesh"))
/obj/item/clothing/suit/charm
	name = "paper charm"
	desc = "A little folded paper charm with something written on the inside."
	icon = 'icons/obj/charms.dmi'
	icon_state = "charm"
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_charms.dmi'
	wear_state = "charm"
	/// ID of the reagent staining this charm
	var/stain_reagent = null
	var/datum/charm_effect/effect = null
	/// Do we have a string, can be equipped?
	var/strung = FALSE
	var/obj/item/paper/paper = null
	//ideas for other charm effects: lavender gives disease resist + slightly higher chance for asymptomaticness
	//aconite stain prevent ww transforms

	reagent_act(reagent_id, volume, datum/reagents/holder_reagents)
		if (src.stain_reagent)
			return
		src.stain_reagent = reagent_id
		var/stain_type = is_blood(reagent_id) ? "bloodied" : "stained"
		var/image/overlay = image(src.icon, stain_type)
		var/datum/reagent/reagent = overlay.color = holder_reagents.get_reagent(reagent_id)
		overlay.color = rgb(reagent.fluid_r, reagent.fluid_g, reagent.fluid_b)
		src.UpdateOverlays(overlay, "stain")

		if (ishuman(src.loc) && src.equipped_in_slot == SLOT_WEAR_SUIT)
			src.add_worn_overlays(src.loc)

		for (var/type in concrete_typesof(/datum/charm_effect))
			var/datum/charm_effect/effect = new type()
			if (effect.stain_condition(reagent_id, volume, holder_reagents))
				src.effect = effect
				src.effect.charm = src
				if (isliving(src.loc))
					src.effect.on_gain(src.loc)
				break

		return TRUE

	can_equip(mob/user, slot)
		return ..() && src.strung

	equipped(mob/user, slot)
		src.add_worn_overlays(user)
		. = ..()

	unequipped(mob/user)
		user.ClearSpecificOverlays("charm_stain")
		. = ..()

	attack_self(mob/user)
		src.paper.ui_interact(user)
		return

	proc/add_worn_overlays(mob/living/carbon/human/human)
		if (!ishuman(human) || !src.stain_reagent)
			return
		var/typeinfo/datum/mutantrace/typeinfo = human.mutantrace?.get_typeinfo()
		var/overlay_icon = typeinfo.clothing_icons["overcoats"] ? typeinfo.clothing_icons["overcoats"] : src.wear_image_icon
		var/overlay_state = is_blood(src.stain_reagent) ? "charm_stained" : "charm_bloodied"
		var/image/overlay = image(overlay_icon, overlay_state)
		var/datum/reagent/reagent = reagents_cache[src.stain_reagent]
		overlay.color = rgb(reagent.fluid_r, reagent.fluid_g, reagent.fluid_b)
		human.UpdateOverlays(overlay, "charm_stain")

	disposing()
		src.effect?.charm = null
		src.effect = null
		. = ..()

	attackby(obj/item/cable_coil/cable, mob/living/user, params)
		if (!istype(cable))
			return ..()
		if (!cable.use(2))
			boutput(user, SPAN_ALERT("You need at least 2 lengths of cable to make that!"))
			return
		src.icon_state = "charm_strung"
		src.strung = TRUE

	set_loc(newloc, storage_check)
		src.on_set_loc(newloc, src.loc)
		. = ..()

	proc/on_set_loc(newloc, currentloc)
		if (currentloc == newloc || !src.effect)
			return
		if (ismob(currentloc))
			src.effect.on_lose(currentloc)
		if (ismob(newloc))
			src.effect.on_gain(newloc)

	setupProperties()
		..()
		setProperty("meleeprot", 0)
		setProperty("heatprot", 0)
		setProperty("coldprot", 0)
