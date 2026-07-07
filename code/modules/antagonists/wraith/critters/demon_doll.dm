
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
	can_use_say = FALSE
	can_juggle = TRUE
	name_generator_path = /datum/wraith_name_generator/wraith_summon/doll
	var/mob/living/intangible/wraith/master = null
	var/traps_laid = 0

	New(var/turf/T, var/mob/living/intangible/wraith/M = null)
		..(T)
		if(M != null)
			src.master = M

			if (isnull(M.summons))
				M.summons = list()
			M.summons += src
		src.see_invisible = INVIS_SPOOKY
		src.addAbility(/datum/targetable/critter/demon_doll/devious_song)
		src.addAbility(/datum/targetable/critter/demon_doll/shrieking_song)
		src.addAbility(/datum/targetable/critter/demon_doll/bouncy_song)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_THERMALVISION, src)

		src.setStatus("dark_affinity")

	say_verb()
		if (!ON_COOLDOWN(src, "playsound", 10 SECONDS))
			playsound(src, 'sound/voice/wraith/doll_laugh.ogg', 60, 1)
			src.emote("giggle", TRUE)
		return

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
			new/obj/item/clothing/gloves/ring/gold()
			src.gib()
		return ..()

	gib()
		var/turf/T = get_turf(src)
		if (T)
			new/obj/item/clothing/gloves/ring/gold(T)
			playsound(T, 'sound/items/coindrop.ogg', 30, 1)
		return ..()

/datum/statusEffect/dark_affinity
	id = "dark_affinity"
	name = "Dark Affinity"
	desc = "Darkness restores your form and grants you haste."
	icon_state = "eye"
	duration = INFINITE_STATUS
	maxDuration = null
	unique = 1
	var/last_check = TRUE // TRUE = lights on
	var/counter = 0

	onAdd()
		light_check(TRUE)
		..()

	onUpdate(timePassed)
		counter += timePassed
		if (counter >= 20)
			light_check()
		. = ..(timePassed)

	proc/light_check(var/check_bypass=FALSE)
		var/current_check
		var/turf/T = src.owner.loc
		if (T?.is_lit())
			current_check = TRUE
		else
			current_check = FALSE
		if (check_bypass || (current_check != src.last_check)) // only toggle effects when you need to, or when telling it to
			src.last_check = current_check
			toggle_status(current_check)

	proc/toggle_status(var/light)
		var/mob/living/living_owner = owner
		if (light)
			src.icon_state = "eye_closed"
			src.desc = "Darkness will restore your body and grant you haste."
			living_owner.alpha = 255
			living_owner.bioHolder.RemoveEffect("regenerator")
			REMOVE_MOVEMENT_MODIFIER(living_owner, /datum/movement_modifier/dark_affinity_on, src.type)
			APPLY_MOVEMENT_MODIFIER(living_owner, /datum/movement_modifier/dark_affinity_off, src.type)
		else
			src.icon_state = "eye"
			src.desc = "Darkness is restoring your body and granting you haste."
			living_owner.alpha = 160
			living_owner.bioHolder.AddEffect("regenerator", magical = 1)
			REMOVE_MOVEMENT_MODIFIER(living_owner, /datum/movement_modifier/dark_affinity_off, src.type)
			APPLY_MOVEMENT_MODIFIER(living_owner, /datum/movement_modifier/dark_affinity_on, src.type)




