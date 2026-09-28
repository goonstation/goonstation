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

	get_help_message(dist, mob/user)
		if (!src.strung)
			return "Can be strung with a scrap of wire."

	get_desc(dist, mob/user)
		if (!src.stain_reagent)
			return "Might look better with a <i>splash</i> of color."

	reagent_act(reagent_id, volume, datum/reagents/holder_reagents)
		if (src.stain_reagent)
			return
		src.stain_reagent = reagent_id
		src.setup_overlay()

		for (var/type in concrete_typesof(/datum/charm_effect))
			var/datum/charm_effect/effect = new type()
			if (effect.stain_condition(reagent_id, volume, holder_reagents))
				src.set_effect(effect)
				break

		return TRUE

	proc/set_effect(datum/charm_effect/effect)
		src.effect = effect
		src.effect.charm = src
		src.effect.on_stain()
		if (isliving(src.loc))
			src.effect.on_gain(src.loc)

	proc/setup_overlay()
		var/stain_type = is_blood(src.stain_reagent) ? "bloodied" : "stained"
		var/image/overlay = image(src.icon, stain_type)
		var/datum/reagent/reagent = overlay.color = reagents_cache[src.stain_reagent]
		overlay.color = rgb(reagent.fluid_r, reagent.fluid_g, reagent.fluid_b)
		src.UpdateOverlays(overlay, "stain")

		if (ishuman(src.loc) && src.equipped_in_slot == SLOT_WEAR_SUIT)
			src.add_worn_overlays(src.loc)

	can_equip(mob/user, slot)
		return ..() && src.strung

	equipped(mob/user, slot)
		src.add_worn_overlays(user)
		. = ..()

	unequipped(mob/user)
		user.ClearSpecificOverlays("charm_stain")
		. = ..()

	attack_self(mob/user)
		src.paper?.ui_interact(user)
		return

	proc/add_worn_overlays(mob/living/carbon/human/human)
		if (!ishuman(human) || !src.stain_reagent)
			return
		var/typeinfo/datum/mutantrace/typeinfo = human.mutantrace?.get_typeinfo()
		var/overlay_icon = typeinfo.clothing_icons["overcoats"] ? typeinfo.clothing_icons["overcoats"] : src.wear_image_icon
		var/overlay_state = is_blood(src.stain_reagent) ? "charm_bloodied" : "charm_stained"
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

	attack(mob/living/target, mob/user, def_zone, is_special, params)
		if (!istype(target))
			return ..()
		if (target.bleeding)
			var/datum/reagents/holder = new()
			holder.add_reagent(target.blood_id, 10, target.bioHolder)
			src.reagent_act(target.blood_id, 10, holder)
			qdel(holder)
			attack_particle(user, target)
			boutput(user, SPAN_NOTICE("You press [src] into [target]'s wounds."))
			return
		. = ..()

	afterattack(atom/target, mob/user, reach, params)
		if (istype(target, /obj/decal/cleanable))
			var/obj/decal/cleanable/cleanable = target
			if (length(cleanable.reagents?.reagent_list) || cleanable.sample_reagent)
				boutput(user, SPAN_NOTICE("You smear [src] in [cleanable]."))
			if (length(cleanable.reagents?.reagent_list))
				var/reagent_id = cleanable.reagents.reagent_list[1]
				src.reagent_act(reagent_id, cleanable.reagents.get_reagent_amount(reagent_id), cleanable.reagents)
			else if (cleanable.sample_reagent)
				var/datum/reagents/holder = new()
				holder.add_reagent(cleanable.sample_reagent, 10)
				src.reagent_act(cleanable.sample_reagent, 10, holder)
		else if (isturf(target))
			var/turf/T = target
			var/datum/reagents/holder = T.active_liquid?.group?.reagents
			if (length(holder?.reagent_list))
				var/reagent_id = holder.reagent_list[1]
				src.reagent_act(reagent_id, holder.get_reagent_amount(reagent_id), holder)

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

/obj/item/clothing/suit/charm/cursed_blood
	stain_reagent = "blood"

	New()
		. = ..()
		src.setup_overlay()
		src.set_effect(new /datum/charm_effect/cursed_blood)

#undef is_blood
