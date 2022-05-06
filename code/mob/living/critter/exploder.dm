/mob/living/critter/exploder
	name = "exploder"
	desc = "A rotting, walking mass of flesh."
	icon = 'icons/misc/critter.dmi'
	icon_state = "mouse"
	density = 1
	speechverb_say = "moans"
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	can_help = 1
/*
	say_language = "feather"
	voice_name = "synthetic chirps"
	speechverb_say = "chirps"
	speechverb_exclaim = "screeches"
	speechverb_ask = "inquires"
	speechverb_gasp = "clatters"
	speechverb_stammer = "buzzes"
	custom_gib_handler = /proc/flockdronegibs
	custom_vomit_type = /obj/decal/cleanable/flockdrone_debris/fluid
	mat_appearances_to_ignore = list("gnesis")
	mat_changename = FALSE
	mat_changedesc = FALSE
*/
	// HEALTHS
	var/health_brute = 50
	var/health_burn = 50
	var/health_brute_vuln = 1.5
	var/health_burn_vuln = 1
	// this body sucks i want a different one
	var/mob/living/intangible/flock/controller = null
	// AI STUFF
	is_npc = 1

	use_stamina = 0 //haha no

	can_lie = 0 // no rotate when dead
	//blood_id = "flockdrone_fluid"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/bear
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left bear arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/bear
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right bear arm"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src.loc, pick('sound/voice/Zgroan1.ogg', 'sound/voice/Zgroan2.ogg', 'sound/voice/Zgroan3.ogg', 'sound/voice/Zgroan4.ogg'), 25, 0)
					return "<b>[src]</b> screams!"
		return null

	death(var/gibbed)
		..(gibbed, 0)

		src.visible_message("[src] explodes!")
		for (var/mob/M in view(3, src.loc))
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if(istype(H.wear_suit, /obj/item/clothing/suit/bio_suit) && istype(H.head, /obj/item/clothing/head/bio_hood))
					boutput(M, "<span class='notice'>You are sprayed with guts, but your biosuit protects you!</span>")
					continue
			M.emote("scream")
			M.take_toxin_damage(25)
			if (M.reagents)
				M.reagents.add_reagent("miasma", 20, null, T0C)
			boutput(M, "<span class='alert'>You are sprayed with disgusting rotting flesh!</span>")
		var/turf/U = get_turf(src)
		U.fluid_react_single("miasma", 120, airborne = 1)
		U.fluid_react_single("blood", 60, airborne = 0)

		if (!gibbed)
			gibs(src.loc) //cmon let's let them really make a mess
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
			src.drop_item()
			qdel(src)
		else
			gibs(src.loc) //cmon let's let them really make a mess
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)

/mob/living/critter/exploder/New(var/atom/L, var/datum/flock/F=null)
	..()
	src.ai = new /datum/aiHolder/wraith_critters/exploder(src)
	abilityHolder.addAbility(/datum/targetable/critter/takepicture)
	abilityHolder.addAbility(/datum/targetable/critter/flash)
	abilityHolder.addAbility(/datum/targetable/critter/control_owner)

	// do not automatically set up a flock if one is not provided
	// flockless drones act differently
	//src.flock = F
	// wait for like one tick for the unit to set up properly before registering
	/*SPAWN(1 DECI SECOND)
		if(!isnull(src.flock))
			src.flock.registerUnit(src)*/

/mob/living/critter/exploder/proc/describe_state()
	var/list/state = list()
	state["update"] = "exploder"
	state["ref"] = "\ref[src]"
	state["name"] = src.name
	state["health"] = round(src.get_health_percentage()*100)
	var/area/myArea = get_area(src)
	if(isarea(myArea))
		state["area"] = myArea.name
	else
		state["area"] = "???"
	return state


/mob/living/critter/exploder/say(message, involuntary = 0)
	if(isdead(src) && src.is_npc)
		return // NO ONE CARES
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	..(message) // caw at the non-drones

	if (involuntary || message == "" || stat)
		return
	if (dd_hasprefix(message, "*"))
		return

	var/prefixAndMessage = separate_radio_prefix_and_message(message)
	message = prefixAndMessage[2]

	if(!src.is_npc)
		message = gradientText("#3cb5a3", "#124e43", message)
	//flock_speak(src, message, src.flock)

/mob/living/critter/exploder/Life(datum/controller/process/mobs/parent)
	if (..(parent)) //??
		return 1
