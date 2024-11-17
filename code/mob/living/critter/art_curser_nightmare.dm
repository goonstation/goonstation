/mob/living/critter/art_curser_nightmare
	name = "???"
	desc = "You sense some presence, but can't tell what it is!"
	icon_state = ""
	color = "#5c0079"

	hand_count = 1

	health_brute = 20
	health_burn = 20
	health_brute_vuln = 1
	health_burn_vuln = 1

	ai_type = /datum/aiHolder/art_curser_nightmare
	is_npc = TRUE

	canbegrabbed = FALSE
	faction = list(FACTION_NEUTRAL)
	use_stamina = FALSE
	ailment_immune = TRUE
	has_genes = FALSE

	event_handler_flags = MOVE_NOCLIP // phases through things

	grabresistmessage = "slips right out of their hands!"

	var/mob/living/carbon/human/cursed_human
	var/image/hidden_appearance
	var/datum/statusEffect/art_curse/nightmare/tracking_curse

	New(newLoc, datum/statusEffect/art_curse/nightmare/curse)
		..()
		src.tracking_curse = curse
		remove_lifeprocess(/datum/lifeprocess/mutations)
		remove_lifeprocess(/datum/lifeprocess/organs)
		remove_lifeprocess(/datum/lifeprocess/stuns_lying)
		remove_lifeprocess(/datum/lifeprocess/blindness)
		remove_lifeprocess(/datum/lifeprocess/radiation)

		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_EXT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)

		src.hidden_appearance = image(src.icon, src, "floateye")
		src.hidden_appearance.alpha = 0
		animate(src.hidden_appearance, alpha = 255, time = 1 SECOND)

		get_image_group(CLIENT_IMAGE_GROUP_ART_CURSER_NIGHTMARE).add_image(src.hidden_appearance)

	Life(datum/controller/process/mobs/parent)
		..()
		if (src.z != src.cursed_human.z || !istype(src.cursed_human.loc, /turf) || GET_DIST(src, src.cursed_human) > 50) // person is on another z level or inside closet or something
			src.tracking_curse.created_creatures -= src
			qdel(src)
		else if (!length(get_path_to(src, src.cursed_human, 0))) // cases like person walling themselves off, moves through obstacles
			step_towards(src, src.cursed_human, 32)

	death()
		src.tracking_curse.creatures_to_kill -= 1
		..()
		qdel(src)

	disposing()
		get_image_group(CLIENT_IMAGE_GROUP_ART_CURSER_NIGHTMARE).remove_image(src.hidden_appearance)
		QDEL_NULL(src.hidden_appearance)
		src.tracking_curse.created_creatures -= src
		src.tracking_curse = null
		src.cursed_human = null
		..()

	examine(mob/user)
		if (user == src.cursed_human)
			return list("Some creature spawned as part of your curse. Kill it.")
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/art_curser_nightmare
		HH.name = "tentacle"
		HH.limb_name = HH.name
		HH.can_hold_items = FALSE

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)
		add_health_holder(/datum/healthHolder/toxin)

	do_disorient(stamina_damage, knockdown, stunned, unconscious, disorient = 60, remove_stamina_below_zero = 0, target_type = DISORIENT_BODY, stack_stuns = 1)
		return

	is_spacefaring()
		return TRUE

	seek_target()
		return list(src.cursed_human)

	attackby(obj/item/I, mob/M)
		if (M != src.cursed_human)
			return
		. = ..()

	attack_hand(mob/living/M)
		if (M != src.cursed_human)
			return
		. = ..()

	proc/register_target(mob/living/carbon/human/to_kill)
		src.cursed_human = to_kill

/datum/limb/small_critter/art_curser_nightmare
	dam_low = 2
	dam_high = 2
	actions = list("swipes", "swipes", "swipes", "swipes")
