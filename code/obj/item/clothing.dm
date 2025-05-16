ABSTRACT_TYPE(/obj/item/clothing)
/obj/item/clothing
	name = "clothing"
	//var/obj/item/clothing/master = null
	w_class = W_CLASS_SMALL

	var/see_face = TRUE
	///Makes it so the item doesn't show up upon examining, currently only applied for gloves
	var/nodescripition = FALSE

	//for clothing that covers other clothing from examines
	var/hides_from_examine = 0

	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	//var/c_flags = null // these don't need to be in the general flags when they only apply to clothes  :I
	// mbc moived c flags up to item bewcause some wearaables things are items and not clothign :)

	var/color_r = 1 // used for vision stuff, see human/handle_regular_hud_updates()
	var/color_g = 1 // (why were these only on crafted glasses?  they could have just been used on the parent like this from the start  :V)
	var/color_b = 1

	var/protective_temperature = 0
	var/magical = 0 // for wizard item spell power check
	var/chemicalprotection = 0 //chemsuit and chemhood in combination grant this

	/// allow mutantraces to wear certain garments, see [/datum/mutantrace/var/uses_human_clothes]
	var/list/compatible_species = list("human", "cow")

	var/fallen_offset_x = 1
	var/fallen_offset_z = -6
	/// we want to use Z rather than Y incase anything gets rotated, it would look all jank

	var/material_piece = /obj/item/material_piece/cloth/cottonfabric

	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0

	var/can_stain = 1
	var/list/datum/stain/stains = null

	New()
		..()
		src.real_name = src.name // meh will probably grab any custom names like this

	disposing()
		if (ismob(src.loc))
			var/mob/M = src.loc
			M.u_equip(src)

			if (ishuman(src.loc))
				var/mob/living/carbon/human/H = src.loc
				for (var/datum/hud/hud in H.huds)
					if (src in hud.objects)
						hud.remove_object(src)
				H.hud.remove_object(src)
		//fucky way of doing this but whatever
		..()


	UpdateName()
		src.name = src.real_name || initial(src.name)
		if(src.material?.usesSpecialNaming())
			src.name = src.material.specialNaming(src)
		src.name = "[name_prefix(null, 1)][src.get_stain_names()][src.name][name_suffix(null, 1)]"

	///Add a stain to this clothing piece
	proc/add_stain(stain_type)
		var/datum/stain/stain = get_singleton(stain_type)
		if (!istype(stain) || !src.can_stain)
			return
		if (!islist(src.stains))
			src.stains = list()
		else if (stain in src.stains)
			return
		src.stains.Add(stain)
		stain.add_to_clothing(src)
		src.UpdateName()

	///Returns a space-concatenated string of stain names
	proc/get_stain_names()
		if (src.can_stain && islist(src.stains) && length(src.stains))
			for (var/datum/stain/stn in src.stains)
				. += stn.name + " "

	///Removes a stain from this clothing piece. Returns 1/TRUE if stain removed.
	proc/remove_stain(stain_type)
		var/datum/stain/stain = get_singleton(stain_type)
		if(stain in src.stains)
			stain.remove_from_clothing(src)
			. = src.stains.Remove(stain)
			src.UpdateName()

	///Removes all stains from this clothing piece
	proc/clean_stains()
		if (islist(src.stains) && length(src.stains))
			for (var/datum/stain/stain in src.stains)
				stain.remove_from_clothing(src)
			src.stains = list()
			src.UpdateName()

	// here for consistency; not all clothing can be ripped up
	proc/try_rip_up(mob/user)
		boutput(user, "You begin ripping up [src].")
		SETUP_GENERIC_PRIVATE_ACTIONBAR(user, src, 3 SECONDS, PROC_REF(finish_rip_up), list(user), null, null, "[user] rips up [src].", null)
		return TRUE

	proc/finish_rip_up(mob/user)
		for (var/i in 1 to 3)
			var/obj/item/material_piece/CF = new material_piece
			CF.pixel_x = rand(-4,4)
			CF.pixel_y = rand(-4,4)
			CF.set_loc(get_turf(src))
		user.u_equip(src)
		qdel(src)

/obj/item/clothing/material_trigger_on_mob_attacked(var/mob/attacker, var/mob/attacked, var/atom/weapon, var/situation_modifier)
	// if someone wearing this gets attacked, only trigger this if the corresponding zone is hit
	if (src.material && (src.equipped_in_slot))
		var/targeted_zone = "chest"
		if (situation_modifier && istext(situation_modifier))
			targeted_zone = parse_zone(situation_modifier)
		if (src.check_for_covered(targeted_zone))
			src.material.triggerOnAttacked(src, attacker, attacked, weapon)
		return
	..()

///This proc returns true if the zone specified is covered by the clothing in question
/obj/item/clothing/proc/check_for_covered(var/checked_zone)
	if (!istext(checked_zone))
		return FALSE
	var/target_zone = parse_zone(checked_zone)
	var/list/head_list = list("head", "brain", "left eye", "right eye", "both eyes")
	var/list/torso_list = list("torso", "butt", "heart", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail")
	var/list/legs_list = list("left leg", "right leg", "both legs")
	var/list/arms_list = list("right arm", "left arm", "both arms")
	if ((src && src.body_parts_covered & HEAD) && (target_zone in head_list))
		return TRUE
	if ((src && src.body_parts_covered & TORSO) && (target_zone in torso_list))
		return TRUE
	if ((src && src.body_parts_covered & LEGS) && (target_zone in legs_list))
		return TRUE
	if ((src && src.body_parts_covered & ARMS) && (target_zone in arms_list))
		return TRUE
	return FALSE

ABSTRACT_TYPE(/obj/item/clothing/under)
/obj/item/clothing/under
	equipped(var/mob/user, var/slot)
		..()
		playsound(src.loc, 'sound/items/zipper.ogg', 30, 0.2, pitch = 2)

/*
/obj/item/clothing/fire_burn(obj/fire/raging_fire, datum/air_group/environment)
	if(raging_fire.internal_temperature > src.s_fire)
		SPAWN( 0 )
			var/t = src.icon_state
			src.icon_state = ""
			src.icon = 'b_items.dmi'
			FLICK(text("[]", t), src)
			sleep(1.4 SECONDS)
			qdel(src)
		return 0
	return 1
*/ //TODO FIX
