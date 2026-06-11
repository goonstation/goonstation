/obj/item/paper/folded/charm
	name = "paper charm"
	desc = "A little folded paper charm with something written on the inside."
	icon = 'icons/obj/charms.dmi'
	icon_state = "paper_charm"
	var/bloodied = FALSE
	var/curse_protect = FALSE

	reagent_act(reagent_id, volume, datum/reagents/holder_reagents)
		if (bloodied || !(reagent_id in list("blood", "bloodc", "hemolymph")))
			..()
			return FALSE
		src.bloodied = TRUE
		var/image/overlay = image(src.icon, "bloodied")
		var/datum/reagent/reagent = overlay.color = holder_reagents.get_reagent(reagent_id)
		overlay.color = rgb(reagent.fluid_r, reagent.fluid_g, reagent.fluid_b)
		src.UpdateOverlays(overlay, "bloodied")
		var/datum/bioHolder/bioholder = reagent.data
		if (istype(bioholder) && bioholder.cursed)
			src.curse_protect = TRUE
		return TRUE

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

/obj/item/clothing/suit/charm
	name = "strung charm"

	var/obj/item/paper/folded/charm/charm

	proc/set_up(obj/item/paper/folded/charm/charm, cable_color)
		src.charm = charm
		src.icon = charm.icon
		src.icon_state = charm.icon_state
		copy_overlays(charm, src)
		var/image/cable_overlay = image(charm.icon, "cord")
		cable_overlay.color = cable_color
		src.UpdateOverlays(cable_overlay, "cord")

	reagent_act(reagent_id, volume, datum/reagents/holder_reagents)
		if (src.charm.reagent_act(reagent_id, volume, holder_reagents))
			copy_overlays(src.charm, src)

	setupProperties()
		..()
		setProperty("meleeprot", 0)
		setProperty("heatprot", 0)
		setProperty("coldprot", 0)
