/datum/random_event/special/bigfart
	name = "Flatulent Anomaly"
	customization_available = 1

	// I implemented a bit of customization. Modify the proc call in rathens.dm if you want to nerf/buff the wizard spell (Convair880).
	admin_call(var/source)
		if (..())
			return

		var/limbloss_temp
		var/select = input(usr, "How likely should severed limbs be (0-100)?", "Probability of limb loss") as null|num
		if (select >= 0 && select <= 100)
			limbloss_temp = select

		if (!limbloss_temp)
			limbloss_temp = 0

		src.event_effect(source, limbloss_temp)
		return

	event_effect(var/source, var/limbloss_temp2 = 0)
		..()
		if (fart_attack == 1)
			return
		fart_attack = 1
		SPAWN_DBG(12 SECONDS)
			fart_attack = 0
		if (random_events.announce_events)
			var/sensortext = pick("sensors", "technicians", "probes", "satellites", "monitors", 20; "neckbeards")
			var/pickuptext = pick("picked up", "detected", "found", "sighted", "reported", 20; "drunkenly spotted")
			var/anomlytext = pick("strange anomaly", "wave of cosmic energy", "spectral emission", 20; "shuttle of phantom George Melons clones")
			var/ohshittext = pick("en route for collision with", "rapidly approaching", "heading towards", 20; "about to seriously fuck up")
			command_alert("Our [sensortext] have [pickuptext] \a [anomlytext] [ohshittext] the station. Duck and Cover immediately.", "Anomaly Alert")
		var/loops = rand(20, 100)
		var/freebie = 1
		for (var/i=0, i<loops, i++)
			if (prob(4) || freebie)
				freebie = 0
				SPAWN_DBG(50+rand(0,550))
					world << sound('sound/voice/farts/superfart.ogg', volume = 67)
					for (var/mob/M in mobs)
						if (M.client)
							shake_camera(M, 20, 8)
						if (M.lying)
							M.show_text("You duck and cover, avoiding the shockwave! Phew!", "blue")
							continue
						if (prob(30) && iscarbon(M))
							if (!M.lying)
								M.show_text("The shockwave sends you flying to the ground!", "red")
								M.getStatusDuration("weakened")
								M.force_laydown_standup()

								var/turf/T1 = get_turf(M)
								var/turf/T2 = get_step_rand(M)
								var/blocked = 0
								if (T2) //ZeWaka: Fix for null.contents
									for (var/atom/A in T2.contents)
										if (!ismob(A) && A.density)
											blocked = 1
											break
									if (!(!isturf(M.loc) || T1.density) && !(T2.density || blocked == 1))
										SPAWN_DBG(0)
											M.set_loc(T2)

						if (prob(50))
							ass_explosion(M, 0, limbloss_temp2)

/proc/ass_explosion(var/mob/living/carbon/human/H as mob, var/magical = 0, var/limbloss_prob = 0, var/turf/T as turf) // jfc what am I doing with my life
	if (!H || !(ishuman(H) || isrobot(H)))
		return

	if (limbloss_prob < 0)
		limbloss_prob = 0
	if (limbloss_prob > 100)
		limbloss_prob = 100

	var/is_bot = 0 // so we don't do a bunch of ishuman/isrobot calls

	if (!T)
		T = get_turf(H)
	if (isrobot(H))
		is_bot = 1

	var/flyroll = rand(10)
	var/turf/target = locate(H.x,H.y,H.z)
	switch (H.dir)
		if (NORTH)
			target = locate(H.x, H.y-flyroll, H.z)
		if (SOUTH)
			target = locate(H.x, H.y+flyroll, H.z)
		if (EAST)
			target = locate(H.x-flyroll, H.y, H.z)
		if (WEST)
			target = locate(H.x+flyroll, H.y, H.z)

	if (is_bot || H.get_organ("butt"))
		var/obj/item/clothing/head/butt/B
		var/obj/item/organ/tail/J
		if (!is_bot)
			B = H.drop_organ("butt", T)
		else
			B = new /obj/item/clothing/head/butt/cyberbutt(T)
			B.donor = H

		if (!is_bot && H.get_organ("tail"))	// Got a tail? Throw it *too*
			J = H.drop_organ("tail", T)

		if (B)
			B.throw_at(target, 6, 1)

		if (J)
			J.throw_at(target, 6, 1)

		H.visible_message("<span class='alert'><b>[H]</b>'s [magical ? "arse" : "ass"][J ? " and tail" : ""] flies off \his body[magical ? " in a magical explosion" : null]!</span>",\
		"<span class='alert'>Your [magical ? "arse" : "ass"][J ? " and tail" : ""] flies off your body[magical ? " in a magical explosion" : null]!</span>")
		H.changeStatus("weakened", 2 SECONDS)
		H.force_laydown_standup()

	else
		var/obj/decal/cleanable/G
		if (!is_bot)
			G = make_cleanable( /obj/decal/cleanable/blood/gibs/core,T)
		else
			G = make_cleanable( /obj/decal/cleanable/robot_debris,T)
		G.throw_at(target, 6, 1)
		H.TakeDamage("chest", 10, 0, 0, DAMAGE_STAB)
		H.show_text("You have no [magical ? "arse" : "ass"], but something had to give! Holy shit, what was that?", "red")
		H.changeStatus("weakened", 3 SECONDS)
		H.force_laydown_standup()

		if (!is_bot)
			var/list/possible_limbs = list()
			if (H.limbs.l_arm)
				possible_limbs += H.limbs.l_arm
			if (H.limbs.r_arm)
				possible_limbs += H.limbs.r_arm
			if (H.limbs.l_leg)
				possible_limbs += H.limbs.l_leg
			if (H.limbs.r_leg)
				possible_limbs += H.limbs.r_leg

			if (possible_limbs.len)
				var/obj/item/parts/P = pick(possible_limbs)
				var/obj/item/organ/tail/J2
				if (prob(limbloss_prob))
					P.sever()
				if (H.get_organ("tail"))	// Still coming off
					J2 = "tail"
					H.drop_organ(J2)
				H.show_text("Your [P][J2 ? " and tail" : ""] was severed by the [magical ? "explosion" : "shockwave"]!", "red")
