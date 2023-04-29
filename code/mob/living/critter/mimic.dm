/mob/living/critter/mimic
	name = "Mimic"
	desc = null
	icon = 'icons/misc/critter.dmi'
	icon_state = "mimicface"
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
	//we're an ambush critter so we use all our abilities immediately
	ai_attacks_per_ability = 0

	dir_locked = TRUE //most items don't have dirstates, so don't let us change one
	var/mutable_appearance/disguise
	var/icon/face_image
	var/icon/face_displace_image
	var/is_hiding = FALSE
	///The last time our disguise was interrupted
	var/last_disturbed = INFINITY
	///Time taken to hide if we sit still (Life interval dependent)
	var/rehide_time = 5 SECONDS

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS, src)
		src.face_image = icon('icons/misc/critter.dmi',"mimicface")
		var/toolboxType =pick(25;/obj/item/storage/toolbox/mechanical, 25;/obj/item/storage/toolbox/emergency, 25;/obj/item/storage/toolbox/electrical, 24;/obj/item/storage/toolbox/artistic, 1;/obj/item/storage/toolbox/memetic)
		var/obj/item/storage/toolbox/startDisguise = new toolboxType(null)
		src.disguise_as(startDisguise)
		qdel(startDisguise)

	update_icon()
		. = ..()
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

	proc/disguise_as(var/obj/target)
		src.disguise = new /mutable_appearance(target)
		src.appearance = src.disguise
		src.overlay_refs = target.overlay_refs?.Copy() //this is necessary to preserve overlay management metadata
		src.start_hiding()

	proc/start_hiding()
		if (src.is_hiding)
			return
		src.is_hiding = TRUE
		qdel(src.name_tag)
		src.name_tag = null
		src.UpdateIcon()

	proc/stop_hiding()
		src.last_disturbed = TIME
		if(!src.is_hiding)
			return
		src.is_hiding = FALSE
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
		if(!sting.disabled && sting.cooldowncheck())
			sting.handleCast(target)
			return TRUE
		if(!pounce.disabled && pounce.cooldowncheck())
			pounce.handleCast(target)
			return TRUE

	seek_target(var/range = 5)
		. = list()
		for (var/mob/living/C in hearers(range, src))
			if (isintangible(C)) continue
			if (is_incapacitated(C)) continue
			if (istype(C, src.type)) continue
			. += C

	Life(datum/controller/process/mobs/parent)
		. = ..()
		if (!src.is_hiding && (TIME - src.last_disturbed > src.rehide_time))
			src.start_hiding()

/datum/targetable/critter/mimic
	name = "Mimic Object"
	desc = "Disguise yourself as a target object."
	icon_state = "mimic"
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
			boutput(holder.owner, "<span class='alert'>You must be adjacent to [target] to mimic it.</span>")
			return TRUE
		var/mob/living/critter/mimic/parent = holder.owner
		parent.disguise_as(target)
		boutput(holder.owner, "<span class='alert'>You mimic [target].</span>")
		return FALSE

/datum/targetable/critter/sting/mimic
	name = "Mimicotoxin Sting"
	desc = "Inject your target with a confusing toxin."
	venom_ids = list("mimicotoxin")
	inject_amount = 15

	antag_spawn
		inject_amount = 17 //enough to blind someone for a few seconds

/mob/living/critter/mimic/antag_spawn
	//same health as a firebot
	health_brute = 25
	health_burn = 25
	add_abilities = list(/datum/targetable/critter/mimic, /datum/targetable/critter/tackle, /datum/targetable/critter/sting/mimic/antag_spawn)
	hand_count = 2
	//give them an actual hand so they can open doors etc.
	setup_hands()
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
