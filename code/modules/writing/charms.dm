/obj/item/paper/folded/charm
	name = "paper charm"
	desc = "A little folded paper charm with something written on the inside."
	icon = 'icons/obj/charms.dmi'
	icon_state = "paper_charm"
	/// Sealed with blood?
	var/bloodied = FALSE
	/// Was the blood from a curse victim?
	var/curse_protect = FALSE
	/// How many curses will this block?
	var/charges = 3

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
			var/datum/effects/system/bad_smoke_spread/smoke = new(get_turf(src))
			smoke.set_up(2, 0, get_turf(src), null, "#b1b1b1")
			smoke.start()
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

	set_loc(newloc, storage_check)
		src.on_set_loc(newloc, src.loc)
		. = ..()

	proc/on_set_loc(newloc, currentloc)
		if (currentloc == newloc)
			return
		if (ismob(newloc))
			src.RegisterSignal(newloc, COMSIG_TRY_CURSE, PROC_REF(on_try_curse))
		else if (ismob(currentloc))
			src.UnregisterSignal(currentloc, COMSIG_TRY_CURSE)

	proc/on_try_curse(mob/living/victim, mob/living/intangible/wraith/wraith)
		if (!src.curse_protect || src.charges <= 0)
			return FALSE
		var/obj/effects/harmless_smoke/smoke = new(get_turf(src))
		SPAWN(1 SECOND)
			qdel(smoke)
		boutput(victim, SPAN_ALERT("Your [src] singes as it protects you from a foul curse!"))
		victim.TakeDamage("chest", burn = 5) //ow!
		playsound(get_turf(victim), 'sound/impact_sounds/burn_sizzle.ogg', 50, 1)
		src.charges--
		if (src.charges <= 0)
			if (istype(src.loc, /obj/item/clothing))
				victim.u_equip(src.loc)
				qdel(src.loc)
			else
				victim.drop_item(src)
				qdel(src)
			new /obj/decal/cleanable/ash(victim.loc)

		return TRUE

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
