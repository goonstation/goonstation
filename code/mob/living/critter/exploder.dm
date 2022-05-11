/mob/living/critter/exploder
	name = "Bloated abomination"
	desc = "A rotting, walking mass of flesh."
	icon = 'icons/mob/wraith_critters.dmi'
	icon_state = "rot_hulk"
	density = 1
	speechverb_say = "moans"
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	can_help = 1
	// HEALTHS
	var/health_brute = 50
	var/health_burn = 50
	var/health_brute_vuln = 1
	var/health_burn_vuln = 1.5
	is_npc = 1

	use_stamina = 0

	can_lie = 0
	blood_id = "miasma"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/hunter
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "hand"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/hunter
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "hand"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src.loc, pick('sound/voice/Zgroan1.ogg', 'sound/voice/Zgroan2.ogg', 'sound/voice/Zgroan3.ogg', 'sound/voice/Zgroan4.ogg'), 25, 0)
					return "<b>[src]</b> screams!"
		return null

	death(var/gibbed)
		..(gibbed, 0)

		src.visible_message("[src] explodes!")	//Shouldnt stand close to this thing
		for (var/mob/M in view(3, src.loc))
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if(istype(H.wear_suit, /obj/item/clothing/suit/bio_suit) && istype(H.head, /obj/item/clothing/head/bio_hood))
					boutput(M, "<span class='notice'>You are sprayed with guts, but your biosuit protects you!</span>")
					continue
				else
					boutput(M, "<span class='alert'>You are sprayed with disgusting rotting flesh! You're pretty sure some of it got in your mouth.</span>")
			M.emote("scream")
			M.take_toxin_damage(25)
			if (M.reagents)
				M.reagents.add_reagent("miasma", 20, null, T0C)
		var/turf/U = get_turf(src)
		U.fluid_react_single("miasma", 120, airborne = 1)
		U.fluid_react_single("blood", 60, airborne = 0)

		if (!gibbed)
			gibs(src.loc)
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
			src.drop_item()
			qdel(src)
		else
			gibs(src.loc)
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)

/mob/living/critter/exploder/New(var/atom/L)
	..()
	src.ai = new /datum/aiHolder/wraith_critters/exploder(src)

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


/mob/living/critter/exploder/say(message, involuntary = 0)	//Should probably remove this
	if(isdead(src) && src.is_npc)
		return
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	..(message)

	if (involuntary || message == "" || stat)
		return
	if (dd_hasprefix(message, "*"))
		return

	var/prefixAndMessage = separate_radio_prefix_and_message(message)
	message = prefixAndMessage[2]

	if(!src.is_npc)
		message = gradientText("#3cb5a3", "#124e43", message)

/mob/living/critter/exploder/Life(datum/controller/process/mobs/parent)	//most likely not needed, maybe
	if (..(parent)) //??
		return 1


/mob/living/critter/exploder/strong	//Summoned by rot hulk if we find a big pile of filth
	name = "Huge plague-ridden goliath"
	desc = "A rotting, walking mass of flesh."
	health_brute = 80
	health_burn = 80
	health_brute_vuln = 1
	health_burn_vuln = 1.3

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/brullbar
		HH.icon_state = "handl"
		HH.limb_name = "hand"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/brullbar
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "hand"
