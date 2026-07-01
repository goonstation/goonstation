
TYPEINFO(/mob/living/critter/wraith/demon_doll)
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN, SPEECH_OUTPUT_EQUIPPED, SPEECH_OUTPUT_WRAITHCHAT_DEMON_DOLL)

/mob/living/critter/wraith/demon_doll
	name = "demon doll"
	desc = "It kind of hurts to look at, let alone hear."
	density = 1
	icon = 'icons/mob/wraith_critters.dmi'
	icon_state = "demon_doll"
	icon_state_dead = "dead_demon_doll"
	hand_count = 2
	health_brute = 50
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 0.8
	faction = list(FACTION_WRAITH)
	name_generator_path = /datum/wraith_name_generator/wraith_summon/doll
	var/mob/living/intangible/wraith/master = null

	New(var/turf/T, var/mob/living/intangible/wraith/M = null)
		..(T)
		if(M != null)
			src.master = M

			if (isnull(M.summons))
				M.summons = list()
			M.summons += src
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/demon_doll, src.type)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		src.setStatus("dark_affinity")

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0

	death(var/gibbed)
		if (src.master)
			src.master.summons -= src
		src.master = null
		playsound(src, "sound/voice/wraith/revleave.ogg", 50)
		if (gibbed)
			return ..()

		animate(src, 3 SECONDS, pixel_y = 40)
		SPAWN(3 SECONDS)
			src.gib()
		return ..()

/datum/statusEffect/dark_affinity
	id = "dark_affinity"
	name = "Dark Affinity"
	desc = "Darkness restores your form and grants you haste."
	icon_state = "person"
	duration = INFINITE_STATUS
	maxDuration = null
	unique = 1
	var/lastlight_check = TRUE
	var/counter = 0
	var/count_max = 10

	onUpdate(timePassed)
		counter += timePassed
		if (counter >= count_max)
			var/turf/T = get_turf(owner)
			var/current_light
			if (!isturf(T) || T.is_lit())
				current_light = TRUE
			else
				current_light = FALSE

			if (lastlight_check != current_light)
				edit_status(current_light)

			lastlight_check = current_light

		. = ..(timePassed)

	proc/edit_status(var/light)
		var/mob/living/living_owner = owner
		if (light)
			src.icon_state = "person"
			living_owner.alpha = 255
			if (istype(living_owner, /mob/living/critter/wraith/demon_doll))
				REMOVE_MOVEMENT_MODIFIER(living_owner, /datum/movement_modifier/dark_affinity_strong, src.type)
			else
				REMOVE_MOVEMENT_MODIFIER(living_owner, /datum/movement_modifier/dark_affinity, src.type)
		else
			src.icon_state = "fire1"
			living_owner.alpha = 160
			if (istype(living_owner, /mob/living/critter/wraith/demon_doll))
				APPLY_MOVEMENT_MODIFIER(living_owner, /datum/movement_modifier/dark_affinity_strong, src.type)
			else
				APPLY_MOVEMENT_MODIFIER(living_owner, /datum/movement_modifier/dark_affinity, src.type)




