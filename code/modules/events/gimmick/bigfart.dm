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
		SPAWN(12 SECONDS)
			fart_attack = 0
		if (random_events.announce_events)
			var/sensortext = pick("sensors", "technicians", "probes", "satellites", "monitors", 20; "neckbeards")
			var/pickuptext = pick("picked up", "detected", "found", "sighted", "reported", 20; "drunkenly spotted")
			var/anomlytext = pick("strange anomaly", "wave of cosmic energy", "spectral emission", 20; "shuttle of phantom George Melons clones")
			var/ohshittext = pick("en route for collision with", "rapidly approaching", "heading towards", 20; "about to seriously fuck up")
			playsound_global(world, 'sound/machines/disaster_alert.ogg', 60)
			command_alert("Our [sensortext] have [pickuptext] \a [anomlytext] [ohshittext] the station. Duck and cover immediately and be aware it may strike multiple times.", "Anomaly Alert", alert_origin = ALERT_ANOMALY)
		var/loops = rand(20, 100)
		var/freebie = 1
		for (var/i=0, i<loops, i++)
			if (prob(4) || freebie)
				freebie = 0
				SPAWN(50+rand(0,550))
					playsound_global(world, 'sound/voice/farts/superfart.ogg', 60)
					for (var/mob/M in mobs)
						if (M.client)
							shake_camera(M, 20, 8)
						if (M.lying)
							M.show_text("You duck and cover, avoiding the shockwave! Phew!", "blue")
							continue
						if (prob(30) && iscarbon(M))
							if (!M.lying)
								M.show_text("The shockwave sends you flying to the ground!", "red")
								M.getStatusDuration("knockdown")
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
										SPAWN(0)
											M.set_loc(T2)

						if (prob(50))
							ass_explosion(M, 0, limbloss_temp2)

/proc/ass_explosion(var/mob/living/carbon/human/H as mob, var/magical = 0, var/limbloss_prob = 0, var/turf/T as turf) // jfc what am I doing with my life
	if (!H || !(ishuman(H) || isrobot(H)))
		return

	limbloss_prob = clamp(limbloss_prob, 0, 100)

	var/is_bot = 0 // so we don't do a bunch of ishuman/isrobot calls
	var/changer = ischangeling(H)

	if (!T)
		T = get_turf(H)
	if (isrobot(H))
		is_bot = 1

	/// First try to sever their butt
	if (is_bot || H.get_organ("butt"))
		var/obj/item/clothing/head/butt/B
		if (!is_bot)
			B = H.drop_and_throw_organ("butt", dist = 6, speed = 1, showtext = 0)
		else
			B = new /obj/item/clothing/head/butt/cyberbutt(T)
			B.donor = H
			ThrowRandom(B, dist = 6, speed = 1)
		H.visible_message(SPAN_ALERT("<b>[H]</b>'s [magical ? "arse" : "ass"] tears itself away from [his_or_her(H)] body[magical ? " in a magical explosion" : null]!"),\
		SPAN_ALERT("[changer ? "Our" : "Your"] [magical ? "arse" : "ass"] tears itself away from [changer ? "our" : "your"] body[magical ? " in a magical explosion" : null]!"))
		H.organHolder.back_op_stage = BACK_SURGERY_OPENED

	/// If that didn't work, try severing a limb or tail
	else if (!is_bot && prob(limbloss_prob)) // It'll try to sever an arm, then a leg, then an arm, then a leg
		var/list/possible_limbs = list()
		if (H.limbs.l_leg)
			possible_limbs[H.limbs.l_leg] = "leg"
		if (H.limbs.r_arm)
			possible_limbs[H.limbs.r_arm] = "arm"
		if (H.limbs.r_leg)
			possible_limbs[H.limbs.r_leg] = "leg"
		if (H.limbs.l_arm)
			possible_limbs[H.limbs.l_arm] = "arm"

		if (length(possible_limbs)) /// Dont want your tail removed? Keep all your limbs intact!
			if(istype(H.organHolder.tail) && prob(100 - (25 * length(possible_limbs)))) // 25% chance to lose a tail per missing limb
				H.visible_message(SPAN_ALERT("<b>[H]</b>'s [magical ? "tægl" : "tail"] is torn free from [his_or_her(H)] body[magical ? " in a magical explosion" : null]!"),\
				SPAN_ALERT("[changer ? "Our" : "Your"] [magical ? "tægl" : "tail"] is torn free from [changer ? "our" : "your"] body[magical ? " in a magical explosion" : null]!"))
				H.drop_and_throw_organ("tail", dist = 6, speed = 1, showtext = 1)
				H.organHolder.back_op_stage = BACK_SURGERY_OPENED
			for(var/obj/item/parts/L in possible_limbs)
				if(length(possible_limbs) > 2) // Lets not remove both limbs unless that's all that's left
					if(possible_limbs[L] == "arm" && (!H.limbs.l_arm || !H.limbs.l_arm))
						possible_limbs -= L
						continue
					if(possible_limbs[L] == "leg" && (!H.limbs.l_leg || !H.limbs.l_leg))
						possible_limbs -= L
						continue
				if(length(possible_limbs) > 1 && prob(25))
					possible_limbs -= L
					continue
				var/ass_exploded = ass_explosion_limb_success(L)
				switch(ass_exploded)
					if(0)
						ass_explosion_message(L, H, magical, possible_limbs[L], 0)
						continue
					if(1)
						ass_explosion_message(L, H, magical, possible_limbs[L], 1)
						L.sever()
						break
					if(2)
						if(prob(50))
							ass_explosion_message(L, H, magical, possible_limbs[L], 1)
							L.sever()
							break
						else
							ass_explosion_message(L, H, magical, possible_limbs[L], 0)
							continue

	// ehhh blow their missing ass out anyway
	if (is_bot)
		robogibs(T)
	else
		gibs(T, headbits = 0)
	var/list/nobutt_phrase = list("magical" = "[changer ? "We" : "You"] feel something grab handful of [changer ? "our" : "your"] [is_bot ? "internal components" : "innards"] and WRENCH them out of space where [changer ? "our" : "your"] arse used to be!",
																"notmagical" = "The cosmic force collides with [changer ? "our" : "your"] being, surges through [changer ? "our" : "your"] body, and exits through where [changer ? "our" : "your"] ass used to be, ripping along with it a sizable clump of [changer ? "our" : "your"] [is_bot ? "internal components" : "innards"]!")
	var/assmagic = magical ? "magical" : "notmagical"
	H.TakeDamage("chest", 10, 0, 0, DAMAGE_STAB)
	if(magical && prob(10))
		boutput(H, SPAN_NOTICE("[changer ? "We" : "You"] hear an otherworldly force let out a short, disappointed cluck at [changer ? "our" : "your"] lack of an arse."))
	H.visible_message(SPAN_ALERT("[is_bot ? "Oily chunks of twisted shrapnel" : "Wadded hunks of blood and gore"] burst out of where <b>[H]</b>'s [magical ? "arse" : "ass"] used to be!"),\
	SPAN_ALERT("[nobutt_phrase[assmagic]]"))
	if(!magical)
		H.changeStatus("knockdown", 3 SECONDS)
	else
		H.changeStatus("knockdown", 1 DECI SECOND)
	H.force_laydown_standup()

/// Returns 0 if it cant be severed like this, 1 if it always gets severed, or 2 if it *sometimes* gets severed
/proc/ass_explosion_limb_success(var/obj/item/parts/L)
	if(!istype(L)) return

	. = 1
	if(L.kind_of_limb)
		/// Returns if the limb is not ass-severable, and a message to the owner about why not
		var/F = L.kind_of_limb
		if(HAS_FLAG(F,LIMB_ROBOT))
			if(HAS_FLAG(F,LIMB_LIGHT))
				return 1 // Flimsy little things
			else
				return 0
		else if((HAS_FLAG(F,LIMB_ABOM)) || (HAS_FLAG(F,LIMB_BEAR)))
			return 0 // Not even magic wants to get near these things
		else if((HAS_FLAG(F,LIMB_BRULLBAR)) || (HAS_FLAG(F,LIMB_WOLF)) || (HAS_FLAG(F,LIMB_STONE)) || (HAS_FLAG(F,LIMB_ARTIFACT)))
			return 2 // Both sturdy and scary

/// returns some flufftext as to why their limb didnt come off. Or came off anyway.
/proc/ass_explosion_message(var/obj/item/parts/L, var/mob/living/H, var/magical, var/armleg, var/severed)
	if(!istype(L) || !istype(H)) return
	if(L.kind_of_limb)
		/// Returns if the limb is not ass-severable, and a message to the owner about why not
		var/F = L.kind_of_limb
		var/ch = ischangeling(H)
		if(HAS_FLAG(F,LIMB_ROBOT))
			if(HAS_FLAG(F,LIMB_LIGHT))
				if(magical)
					boutput(H, SPAN_ALERT("An invisible hand clamps down around [ch ? "our" : "your"] [L] and yanks it with a powerful, otherworldly force!"))
					if(severed)
						boutput(H, SPAN_ALERT("[ch ? "Our" : "Your"] [L] snaps off at the [armleg == "arm" ? "shoulder" : "hip"] like a greasy toothpick!"))
					else
						boutput(H, SPAN_NOTICE("...but it stays in one piece!"))
				else
					boutput(H, SPAN_ALERT("[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!"))
					if(severed)
						boutput(H, SPAN_ALERT("It bursts through [ch ? "our" : "your"] [armleg == "arm" ? "armpit" : "hip"] like a celestial zit, launching [ch ? "our" : "your"] [L] off with the force of a thousand suns!"))
					else
						boutput(H, SPAN_NOTICE("...and then seems to just dissipate back into the aether!"))
			else if(HAS_FLAG(F,LIMB_HEAVY))
				if(magical)
					boutput(H, SPAN_ALERT("A pair of invisible hands clamp down around [ch ? "our" : "your"] [L] and yanks it with a powerful, otherworldly force!"))
					boutput(H, SPAN_NOTICE("...but the cyber-attachment medi-staples holding it in place extend so deep into [ch ? "our" : "your"] [armleg == "arm" ? "shoulder" : "hip"] that you'd be torn in half long before it'd pop free!"))
				else
					boutput(H, SPAN_ALERT("[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!"))
					boutput(H, SPAN_NOTICE("...but the cyberlimb's internal cosmic lighting rod safely conducts it back out into the aether!"))
			else if(HAS_FLAG(F,LIMB_HEAVIER))
				if(magical)
					boutput(H, SPAN_ALERT("A pair of invisible hands try to clamp down around [ch ? "our" : "your"] [L]!"))
					boutput(H, SPAN_NOTICE("...but they just can't seem to find a good grip around that massive hunk of metal you call [armleg == "arm" ? "an arm" : "a leg"]!"))
				else
					boutput(H, SPAN_ALERT("[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!"))
					boutput(H, SPAN_NOTICE("...but the mass and material of [ch ? "our" : "your"] [L] absorbs and harmlessly radiates it back out into the aether!"))
			else
				if(magical)
					boutput(H, SPAN_ALERT("An invisible hand clamps down around [ch ? "our" : "your"] [L] and wrenches it with a powerful, otherworldly tug!"))
					boutput(H, SPAN_NOTICE("...but the cyber-attachment medi-staples holding it in place don't budge!"))
				else
					boutput(H, SPAN_ALERT("[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!"))
					boutput(H, SPAN_NOTICE("...but the cyberlimb's \"creative\" wiring conducts it safely back out into the aether!"))

		else if(HAS_FLAG(F,LIMB_ABOM))
			if(ch)
				if(magical)
					boutput(H, SPAN_ALERT("An invisible being tried to grab our [L]!"))
					boutput(H, SPAN_NOTICE("We successfully fended off whatever this was."))
				else
					boutput(H, SPAN_ALERT("We've been flooded by some kind of disgusting... energy?!"))
					boutput(H, SPAN_NOTICE("...but we managed to drain it through our [L]. We remain whole!"))
			else
				if(magical)
					boutput(H, SPAN_ALERT("You feel an unseen hand grab onto your [L]!"))
					boutput(H, SPAN_NOTICE("...but a fleshy pseudopod pops out and bats it away[prob(50) ? "!" : "...?"]"))
				else
					boutput(H, SPAN_ALERT("You feel a cosmic force conduct through your body, coursing into your [L]!"))
					boutput(H, SPAN_NOTICE("...it willomies for a moment, but otherwise it looks just fine."))

		else if(HAS_FLAG(F,LIMB_BEAR))
			if(ch)
				if(magical)
					boutput(H, SPAN_ALERT("It felt like we just raked our [pick("viciously restless", "restlessly vicious")] bear claws through an invisible arm!"))
					boutput(H, SPAN_NOTICE("Whatever it was, it seems to be gone now."))
				else
					boutput(H, SPAN_ALERT("We've been flooded by some kind of disgusting... energy?!"))
					boutput(H, SPAN_NOTICE("...but the manic flailing of our foreign limb seems to have dissippated it. We remain whole!"))
			else
				var/as_what_1 = pick("an invisible", "a phantom", "a spectral")
				var/as_what_2 = pick("ham", "rump roast", "burrito", "wacky water noodle")
				if(magical)
					boutput(H, SPAN_ALERT("You feel your [L] slice through what could only be described as [as_what_1] [as_what_2]!"))
					boutput(H, SPAN_NOTICE("You hear a faint whimper..."))
				else
					boutput(H, SPAN_ALERT("You feel a cosmic force conduct through your body, coursing into your [L]!"))
					boutput(H, SPAN_NOTICE("...it flails around and disperses the energy back into the aether."))

		else if (HAS_FLAG(F,LIMB_BRULLBAR))
			if(magical)
				boutput(H, SPAN_ALERT("An invisible hand clamps down around [ch ? "our" : "your"] [L] and yanks it with a powerful, otherworldly force!"))
				if(severed)
					boutput(H, SPAN_ALERT("[ch ? "Our" : "Your"] [L] rips free from its socket!"))
				else
					boutput(H, SPAN_NOTICE("...but the [L]'s connection to [ch ? "our" : "your"] [armleg == "arm" ? "shoulder" : "hip"] proves to be stronger!"))
			else
				boutput(H, SPAN_ALERT("[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!"))
				if(severed)
					boutput(H, SPAN_ALERT("It bursts through [ch ? "our" : "your"] [armleg == "arm" ? "armpit" : "hip"] like a celestial zit, launching [ch ? "our" : "your"] [L] off with the force of a thousand suns!"))
				else
					boutput(H, SPAN_NOTICE("...and then seems to just dissipate back into the aether!"))

		else if (HAS_FLAG(F,LIMB_WOLF))
			if(magical)
				boutput(H, SPAN_ALERT("A pair of invisible hands clamp down around [ch ? "our" : "your"] [L] and yanks it with a powerful, otherworldly force!"))
				if(severed)
					boutput(H, SPAN_ALERT("[ch ? "Our" : "Your"] [L] rips free from its socket!"))
				else
					boutput(H, SPAN_NOTICE("...but it slips, only managing to rip out a clump of hair!"))
			else
				boutput(H, SPAN_ALERT("[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!"))
				if(severed)
					boutput(H, SPAN_ALERT("It bursts through [ch ? "our" : "your"] [armleg == "arm" ? "armpit" : "hip"] like a celestial zit, launching [ch ? "our" : "your"] [L] off with the force of a thousand suns!"))
				else
					boutput(H, SPAN_NOTICE("...and then seems to just dissipate back into the aether!"))

		else if (HAS_FLAG(F,LIMB_STONE))
			if(magical)
				boutput(H, SPAN_ALERT("An invisible hand clamps down around [ch ? "our" : "your"] [L] and yanks it with a powerful, otherworldly force!"))
				if(severed)
					boutput(H, SPAN_ALERT("[ch ? "Our" : "Your"] [L] breaks off at the [armleg == "arm" ? "shoulder" : "hip"]!"))
				else
					boutput(H, SPAN_NOTICE("...but it slips off the smooth stony finish of [ch ? "our" : "your"] [L]!"))
			else
				boutput(H, SPAN_ALERT("[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!"))
				if(severed)
					boutput(H, SPAN_ALERT("It bursts through [ch ? "our" : "your"] [armleg == "arm" ? "armpit" : "hip"] like a celestial zit, launching [ch ? "our" : "your"] [L] off with the force of a thousand suns!"))
				else
					boutput(H, SPAN_NOTICE("...but [ch ? "our" : "your"] [L] grounds the energy!"))

		else if(HAS_FLAG(F, LIMB_ARTIFACT))
			if(magical)
				boutput(H, SPAN_ALERT("An invisible hand clamps down around [ch ? "our" : "your"] [L] and yanks it with a powerful, otherworldly force!"))
				if(severed)
					boutput(H, SPAN_ALERT("[ch ? "Our" : "Your"] [L] is ripped off!"))
				else
					boutput(H, SPAN_NOTICE("...but [ch ? "our" : "your"] [L] resists it!"))
			else
				boutput(H, SPAN_ALERT("[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!"))
				if(severed)
					boutput(H, SPAN_ALERT("It bursts through [ch ? "our" : "your"] [armleg == "arm" ? "armpit" : "hip"] like a celestial zit, launching [ch ? "our" : "your"] [L] off with the force of a thousand suns!"))
				else
					boutput(H, SPAN_NOTICE("...but [ch ? "our" : "your"] [L] absorbs the energy!"))

		else
			if(magical)
				boutput(H, SPAN_ALERT("An invisible hand clamps down around [ch ? "our" : "your"] [L] and yanks it with a powerful, otherworldly force!"))
				if(severed)
					boutput(H, SPAN_ALERT("[ch ? "Our" : "Your"] [L] rips free from its socket!"))
				else
					boutput(H, SPAN_NOTICE("...but [ch ? "our" : "your"] [armleg == "arm" ? "shoulder" : "hip"] manages to hold it on!"))
			else
				boutput(H, SPAN_ALERT("[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!"))
				if(severed)
					boutput(H, SPAN_ALERT("It bursts through [ch ? "our" : "your"] [armleg == "arm" ? "armpit" : "hip"] like a celestial zit, launching [ch ? "our" : "your"] [L] off with the force of a thousand suns!"))
				else
					boutput(H, SPAN_NOTICE("...but then it dissipates!"))
