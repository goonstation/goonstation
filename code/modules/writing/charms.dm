#define is_blood(x) x in list("blood", "bloodc", "hemolymph", "martian_flesh")
/obj/item/paper/folded/charm
	name = "paper charm"
	desc = "A little folded paper charm with something written on the inside."
	icon = 'icons/obj/charms.dmi'
	icon_state = "paper_charm"
	/// ID of the reagent staining this charm
	var/stain_reagent = null
	var/datum/charm_effect/effect = null
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
		for (var/type in concrete_typesof(/datum/charm_effect))
			var/typeinfo/typeinfo = get_type_typeinfo(type)
			if (typeinfo.stain_condition(reagent_id, volume, datum/reagents/holder_reagents))
				src.effect = new type()
				src.effect.charm = src
				break

		return TRUE

	disposing()
		src.effect.charm = null
		src.effect = null
		. = ..()

	attackby(obj/item/cable_coil/cable, mob/living/user, params)
		if (!istype(cable))
			return ..()
		if (!cable.use(2))
			boutput(user, SPAN_ALERT("You need at least 2 lengths of cable to make that!"))
			return
		var/obj/item/clothing/suit/charm/strung_charm = new
		strung_charm.set_up(src, cable.insulator.getColor())
		user.drop_item(src)
		src.set_loc(strung_charm)
		user.put_in_hand(strung_charm)

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

/obj/item/clothing/suit/charm
	name = "strung charm"
	wear_image_icon = 'icons/obj/charms.dmi'
	wear_state = "worn_charm"

	var/obj/item/paper/folded/charm/charm

	proc/set_up(obj/item/paper/folded/charm/charm, cable_color)
		src.charm = charm
		src.icon = charm.icon
		src.icon_state = charm.icon_state
		copy_overlays(charm, src)
		var/image/cable_overlay = image(charm.icon, "cord")
		cable_overlay.color = cable_color
		src.UpdateOverlays(cable_overlay, "cord")

	set_loc(newloc, storage_check)
		src.charm.on_set_loc(newloc, src.loc)
		. = ..()

	reagent_act(reagent_id, volume, datum/reagents/holder_reagents)
		if (src.charm.reagent_act(reagent_id, volume, holder_reagents))
			copy_overlays(src.charm, src)

	setupProperties()
		..()
		setProperty("meleeprot", 0)
		setProperty("heatprot", 0)
		setProperty("coldprot", 0)
