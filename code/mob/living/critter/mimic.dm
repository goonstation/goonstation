/mob/living/critter/mimic
	name = "mechanical toolbox"
	desc = null
	icon_state = null
	is_npc = TRUE
	ai_type = /datum/aiHolder/mimic
	can_lie = FALSE
	butcherable = FALSE
	health_brute = 20
	health_burn = 20
	health_brute_vuln = 0.75
	health_burn_vuln = 1.25
	hand_count = 1
	add_abilities = list(/datum/targetable/critter/mimic, /datum/targetable/critter/tackle, /datum/targetable/critter/sting/mimic)
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP
	ai_retaliates = TRUE

	dir_locked = TRUE //most items don't have dirstates, so don't let us change one
	var/mutable_appearance/disguise
	var/icon/face_image
	var/icon/face_displace_image
	var/is_hiding = FALSE

	New()
		..()
		src.face_image = icon('icons/misc/critter.dmi',"mimicface")
		var/obj/item/storage/toolbox/startDisguise = new /obj/item/storage/toolbox/mechanical(src)
		src.disguise_as(startDisguise)
		startDisguise.set_loc(null) //don't just have a random toolbox inside mimics
		qdel(startDisguise)

	update_icon()
		. = ..()
		//src.appearance = src.disguise
		if(!is_hiding)
			src.add_filter("mimic_face", 101, layering_filter(icon = src.face_image,  blend_mode = BLEND_INSET_OVERLAY))

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/mouth
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0

	death(gibbed, do_drop_equipment)
		if(!gibbed)
			src.visible_message("[src] explodes in a shower of meat!")
			return src.gib()
		. = ..()

	was_harmed(mob/M, obj/item/weapon, special, intent)
		. = ..()
		src.is_hiding = FALSE
		src.UpdateIcon()

	proc/disguise_as(var/obj/target)
		src.disguise = new /mutable_appearance(target)
		src.appearance = src.disguise
		src.overlay_refs = target.overlay_refs?.Copy() //this is necessary to preserve overlay management metadata
		src.is_hiding = TRUE
		src.UpdateIcon()


	proc/stop_hiding()
		if(src.is_hiding)
			src.is_hiding = FALSE
			src.UpdateIcon()
			src.visible_message("[src] suddenly opens eyes that weren't there and sprouts teeth!")

	OnMove(source)
		. = ..()
		src.stop_hiding()

	critter_attack(mob/target)
		var/datum/targetable/critter/sting/mimic/sting = src.abilityHolder.getAbility(/datum/targetable/critter/sting/mimic)
		var/datum/targetable/critter/tackle/pounce = src.abilityHolder.getAbility(/datum/targetable/critter/tackle)
		if(!sting.disabled && sting.cooldowncheck())
			sting.handleCast(target)
		else if(!pounce.disabled && pounce.cooldowncheck())
			pounce.handleCast(target)
		else
			. = ..()

	seek_target(var/range = 5)
		. = list()
		for (var/mob/living/C in hearers(range, src))
			if (isintangible(C)) continue
			if (is_incapacitated(C)) continue
			if (istype(C, src.type)) continue
			. += C


/datum/targetable/critter/mimic
	name = "Mimic Object"
	desc = "Disguise yourself as a target object."
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "snakes"
	cooldown = 30 SECONDS
	targeted = TRUE
	target_anything = TRUE

	cast(atom/target)
		if (..())
			return TRUE
		if (!isobj(target))
			boutput(holder.owner, "<span class='alert'>You can't mimic this!</span>")
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>You must be in touch to mimic.</span>")
			return TRUE
		var/mob/living/critter/mimic/parent = holder.owner
		parent.disguise_as(target)
		boutput(holder.owner, "<span class='alert'>You mimic [target].</span>")
		return FALSE

/datum/targetable/critter/sting/mimic
	venom_ids = list("mimicotoxin")
	inject_amount = 15
