/mob/living/critter/mimic
	name = "mimic"
	desc = null
	icon = 'icons/misc/critter.dmi'
	icon_state = "mimictrue"
	is_npc = TRUE
	ai_type = /datum/aiHolder/mimic
	can_lie = FALSE
	butcherable = BUTCHER_NOT_ALLOWED
	health_brute = 20
	health_burn = 20
	health_brute_vuln = 0.75
	health_burn_vuln = 1.25
	hand_count = 1
	add_abilities = list(/datum/targetable/critter/mimic, /datum/targetable/critter/tackle, /datum/targetable/critter/sting/mimic)
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP
	ai_retaliates = TRUE
	//we're an ambush critter so we use all our abilities immediately
	ai_attacks_per_ability = 0

	dir_locked = FALSE //most items don't have dirstates, so don't let us change one
	var/base_form = TRUE
	var/icon/face_image
	var/icon/face_displace_image
	var/is_hiding = FALSE
	///The last time our disguise was interrupted
	var/last_disturbed = INFINITY
	var/hide_density = null
	///Time taken to hide if we sit still (Life interval dependent)
	var/rehide_time = 2 SECONDS
	var/pixel_amount = null

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS, src)
		src.face_image = icon('icons/misc/critter.dmi',"mimicface")

	update_icon()
		. = ..()
		if (src.base_form)
			return
		else
			if(!is_hiding)
				src.add_filter("mimic_face", 101, layering_filter(icon = src.face_image,  blend_mode = BLEND_INSET_OVERLAY))
			else
				src.remove_filter("mimic_face")

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
		src.stop_hiding()

	proc/disguise_as(var/obj/target, var/base_return=FALSE)
		if (base_return)
			src.dir_locked = FALSE
			src.base_form = TRUE
			src.hide_density = 1
			src.appearance = /mob/living/critter/mimic/
			src.stop_hiding()
		else
			var/icon/I = getFlatIcon(target)
			var/pixels = null
			src.dir_locked = TRUE
			src.base_form = FALSE
			src.hide_density = target.density
			src.appearance = target
			src.dir = target.dir
			src.invisibility = initial(src.invisibility)
			src.alpha = max(src.alpha, 200)
			src.plane = initial(src.plane)
			src.overlay_refs = target.overlay_refs?.Copy() //this is necessary to preserve overlay management metadata
			src.start_hiding()
			for(var/y = 1, y <= I.Height(), y++)
				for(var/x = 1, x <= I.Width(), x++)
					var/nullcheck = I.GetPixel(x, y)
					if(nullcheck != null)
						pixels++
			src.pixel_amount = pixels


	proc/start_hiding()
		if (src.base_form)
			return
		if (src.is_hiding)
			return
		src.density = src.hide_density
		src.is_hiding = TRUE
		qdel(src.name_tag)
		src.name_tag = null
		src.UpdateIcon()

	proc/stop_hiding()
		if (src.base_form)
			return
		src.last_disturbed = TIME
		if(!src.is_hiding)
			return
		src.is_hiding = FALSE
		src.density = 1
		src.name_tag = new()
		src.update_name_tag()
		src.vis_contents += src.name_tag
		src.UpdateIcon()
		src.visible_message("[src] suddenly opens eyes that weren't there and sprouts teeth!")

	OnMove(source)
		. = ..()
		src.stop_hiding()

	critter_attack(mob/target)
		src.last_disturbed = TIME
		..()

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/sting/mimic/sting = src.abilityHolder.getAbility(/datum/targetable/critter/sting/mimic)
		var/datum/targetable/critter/tackle/pounce = src.abilityHolder.getAbility(/datum/targetable/critter/tackle)
		if(sting && !sting.disabled && sting.cooldowncheck())
			sting.handleCast(target)
			return TRUE
		if(pounce && !pounce.disabled && pounce.cooldowncheck())
			pounce.handleCast(target)
			return TRUE

	valid_target(mob/living/C)
		if (is_incapacitated(C)) return FALSE
		return ..()

	Life(datum/controller/process/mobs/parent)
		. = ..()
		if (!src.is_hiding && (TIME - src.last_disturbed > src.rehide_time))
			src.start_hiding()

/mob/living/critter/mimic/antag_spawn
	//same health as a firebot
	health_brute = 25
	health_burn = 25
	hand_count = 2
	var/modifier = null
	add_abilities = list(/datum/targetable/critter/mimic,
						/datum/targetable/critter/drop_disguise,
						/datum/targetable/critter/eat_limb,
						/datum/targetable/critter/tackle,
						/datum/targetable/critter/sting/mimic/antag_spawn,
						/datum/targetable/vent_move,
						/datum/targetable/critter/stomach_retreat)

	New()
		..()
		SPAWN(0)
			src.bioHolder.AddEffect("nightvision", 0, 0, 0, 1)

	setup_hands() //give them an actual hand so they can open doors etc.
		. = ..()
		var/datum/handHolder/HH = hands[2]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "grabber"
		HH.limb_name = "grabber"
		HH.can_hold_items = TRUE
		HH.can_attack = TRUE
		HH.can_range_attack = FALSE
		var/datum/limb/small_critter/L = HH.limb
		L.max_wclass = W_CLASS_SMALL

/mob/living/critter/mimic/virtual
		add_abilities = list(/datum/targetable/critter/mimic,/datum/targetable/critter/tackle)

/obj/mimicdummy
	name = "mimic"
	icon = 'icons/misc/critter.dmi'
	icon_state = "mimicface"
	desc = "You shouldn't be seeing me!"
	// dummy object for stomach appearance stuff
