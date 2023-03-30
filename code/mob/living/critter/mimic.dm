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
	add_abilities = list(/datum/targetable/critter/mimic, /datum/targetable/critter/pounce)
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
		src.disguise = new /mutable_appearance(startDisguise)
		src.UpdateIcon()
		startDisguise.set_loc(null) //don't just have a random toolbox inside mimics
		qdel(startDisguise)

	update_icon()
		. = ..()
		src.appearance = src.disguise
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

	proc/disguise_as(var/obj/target)
		src.disguise = new /mutable_appearance(target)
		src.UpdateIcon()


/datum/targetable/critter/mimic
	name = "Mimic Object"
	desc = "Disguise yourself as a target object."
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "snakes"
	cooldown = 600
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
