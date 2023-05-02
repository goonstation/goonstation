/mob/living/critter/jeans_elemental
	name = "jeans jelemental"
	desc = "A jysteroius jeing jomposed jostly of jeans."
	icon = 'icons/misc/critter.dmi'
	icon_state = "jeans_elemental"
	density = TRUE
	custom_gib_handler = /proc/gibs
	hand_count = 2
	can_help = TRUE
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	butcherable = TRUE
	meat_type = /obj/item/material_piece/cloth/jean
	custom_vomit_type = /obj/item/material_piece/cloth/jean
	name_the_meat = FALSE
	health_brute = 40
	health_brute_vuln = 0.5
	health_burn = 50
	health_burn_vuln = 2
	ai_type = /datum/aiHolder/wanderer_aggressive
	is_npc = TRUE
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP

	var/transmute_mat = "jean"

	New()
		..()
		animate_levitate(src)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)
		add_health_holder(/datum/healthHolder/toxin)
		add_health_holder(/datum/healthHolder/brain)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "left_pant"
		HH.name = "left jean"
		HH.limb_name = "left jean"
		HH.can_hold_items = 1

		HH = hands[2]
		HH.limb = new /datum/limb
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "right_pant"
		HH.name = "right jean"
		HH.limb_name = "right jean"
		HH.can_hold_items = 1

	put_in_hand(obj/item/I, t_hand)
		. = ..()
		if(.)
			I.setMaterial(getMaterial(transmute_mat))

	proc/make_the_noise()
		var/sound = pick(
			'sound/voice/jeans/1.ogg',
			'sound/voice/jeans/2.ogg',
			'sound/voice/jeans/3.ogg',
			'sound/voice/jeans/4.ogg',
			'sound/voice/jeans/5.ogg',
		)
		var/pitch_variation = randfloat(-0.25, 0.3)
		if(prob(20))
			pitch_variation *= 2
		if(prob(20))
			pitch_variation *= 2
		var/pitch = 1 + pitch_variation
		if(prob(1))
			pitch *= -1
		playsound(src.loc, sound, rand(20, 60), 0, pitch=pitch)

	proc/transmute_the_stuff()
		var/atom/A = src.loc
		A.setMaterial(getMaterial(transmute_mat))
		var/list/valid_objs = list()
		for (var/obj/O in range(1, src))
			if (O.invisibility == 0 && !istype(O, /obj/effect) && !istype(O, /obj/overlay))
				valid_objs += O
		for (var/turf/T in orange(1, src))
			if(!istype(T, /turf/space))
				valid_objs += T
		A = pick(valid_objs)
		A.setMaterial(getMaterial(transmute_mat))

	seek_target(var/range)
		. = list()
		for (var/mob/living/C in hearers(range, src))
			if (isdead(C)) continue //don't attack the dead
			if (isintangible(C)) continue //don't attack the AI eye
			if (istype(C, src.type)) continue //don't attack other jeans
			if (C.material?.mat_id == transmute_mat) continue //don't attack other jeans-like things
			if (C.ckey == null && prob(80)) continue //usually do not attack non-threats ie. NPC monkeys and AFK players
			. += C

		if(length(.) && prob(30) && isalive(src))
			make_the_noise()

	Life(datum/controller/process/mobs/parent)
		. = ..()
		if(!isalive(src))
			return
		if(prob(30) && src.is_npc)
			make_the_noise()
		transmute_the_stuff()
		if(prob(1))
			animate(src)
			animate_levitate(src)
		if(prob(20))
			var/list/walls = list()
			for(var/turf/simulated/wall/wall in orange(1, src))
				if(wall.material?.mat_id == transmute_mat)
					walls += wall
			if(length(walls))
				src.set_loc(pick(walls))

	death(gibbed, do_drop_equipment)
		. = ..()
		animate(src)

	on_pet(mob/user)
		..()
		if(prob(10))
			src.visible_message("[src] jiggles jelightedly!")

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 3 SECONDS))
					make_the_noise()
					return "<b>[src]</b> screams the word 'JEANS'!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()
