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
			command_alert("Our [sensortext] have [pickuptext] \a [anomlytext] [ohshittext] the station. Duck and Cover immediately.", "Anomaly Alert", alert_origin = ALERT_ANOMALY)
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
										SPAWN(0)
											M.set_loc(T2)

						if (prob(50))
							ass_explosion(M, 0, limbloss_temp2)

/proc/ass_explosion(var/mob/living/carbon/human/H as mob, var/magical = 0, var/limbloss_prob = 0, var/turf/T as turf) // jfc what am I doing with my life
	if (!H || !(ishuman(H) || isrobot(H)))
		return

	limbloss_prob = clamp(limbloss_prob, 0, 100)
	var/severed_something

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
		H.visible_message("<span class='alert'><b>[H]</b>'s [magical ? "arse" : "ass"] tears itself away from [his_or_her(H)] body[magical ? " in a magical explosion" : null]!</span>",\
		"<span class='alert'>[changer ? "Our" : "Your"] [magical ? "arse" : "ass"] tears itself away from [changer ? "our" : "your"] body[magical ? " in a magical explosion" : null]!</span>")
		severed_something = TRUE

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
				severed_something = TRUE
				H.visible_message("<span class='alert'><b>[H]</b>'s [magical ? "tægl" : "tail"] is torn free from [his_or_her(H)] body[magical ? " in a magical explosion" : null]!</span>",\
				"<span class='alert'>[changer ? "Our" : "Your"] [magical ? "tægl" : "tail"] is torn free from [changer ? "our" : "your"] body[magical ? " in a magical explosion" : null]!</span>")
				H.drop_and_throw_organ("tail", dist = 6, speed = 1, showtext = 1)
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
						severed_something = TRUE
						ass_explosion_message(L, H, magical, possible_limbs[L], 1)
						L.sever()
						break
					if(2)
						if(prob(50))
							ass_explosion_message(L, H, magical, possible_limbs[L], 1)
							severed_something = TRUE
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
		boutput(H, "<span class='notification'>[changer ? "We" : "You"] hear an otherworldly force let out a short, disappointed cluck at [changer ? "our" : "your"] lack of an arse.</span>")
	H.visible_message("<span class='alert'>[is_bot ? "Oily chunks of twisted shrapnel" : "Wadded hunks of blood and gore"] burst out of where <b>[H]</b>'s [magical ? "arse" : "ass"] used to be!</span>",\
	"<span class='alert'>[nobutt_phrase[assmagic]]</span>")
	if(!magical)
		H.changeStatus("weakened", 3 SECONDS)
	else
		H.changeStatus("weakened", 1 DECI SECOND)
	H.force_laydown_standup()
	if(!severed_something)
		H.emote("scream")

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
					boutput(H, "<span class='alert'>An invisible hand clamps down around [ch ? "our" : "your"] [L] and yanks it with a powerful, otherworldly force!</span>")
					if(severed)
						boutput(H, "<span class='alert'>[ch ? "Our" : "Your"] [L] snaps off at the [armleg == "arm" ? "shoulder" : "hip"] like a greasy toothpick!</span>")
					else
						boutput(H, "<span class='notification'>...but it stays in one piece!</span>")
				else
					boutput(H, "<span class='alert'>[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!</span>")
					if(severed)
						boutput(H, "<span class='alert'>It bursts through [ch ? "our" : "your"] [armleg == "arm" ? "armpit" : "hip"] like a celestial zit, launching [ch ? "our" : "your"] [L] off with the force of a thousand suns!</span>")
					else
						boutput(H, "<span class='notification'>...and then seems to just dissipate back into the aether!</span>")
			else if(HAS_FLAG(F,LIMB_HEAVY))
				if(magical)
					boutput(H, "<span class='alert'>A pair of invisible hands clamp down around [ch ? "our" : "your"] [L] and yanks it with a powerful, otherworldly force!</span>")
					boutput(H, "<span class='notification'>...but the cyber-attachment medi-staples holding it in place extend so deep into [ch ? "our" : "your"] [armleg == "arm" ? "shoulder" : "hip"] that you'd be torn in half long before it'd pop free!</span>")
				else
					boutput(H, "<span class='alert'>[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!</span>")
					boutput(H, "<span class='notification'>...but the cyberlimb's internal cosmic lighting rod safely conducts it back out into the aether!</span>")
			else if(HAS_FLAG(F,LIMB_HEAVIER))
				if(magical)
					boutput(H, "<span class='alert'>A pair of invisible hands try to clamp down around [ch ? "our" : "your"] [L]!</span>")
					boutput(H, "<span class='notification'>...but they just can't seem to find a good grip arouond that massive hunk of metal you call [armleg == "arm" ? "an arm" : "a leg"]!</span>")
				else
					boutput(H, "<span class='alert'>[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!</span>")
					boutput(H, "<span class='notification'>...but the mass and material of [ch ? "our" : "your"] [L] absorbs and harmlessly radiates it back out into the aether!</span>")
			else
				if(magical)
					boutput(H, "<span class='alert'>An invisible hand clamps down around [ch ? "our" : "your"] [L] and wrenches it with a powerful, otherworldly tug!</span>")
					boutput(H, "<span class='notification'>...but the cyber-attachment medi-staples holding it in place don't budge!<span>")
				else
					boutput(H, "<span class='alert'>[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!</span>")
					boutput(H, "<span class='notification'>...but the cyberlimb's \"creative\" wiring conducts it safely back out into the aether!</span>")

		else if(HAS_FLAG(F,LIMB_ABOM))
			if(ch)
				if(magical)
					boutput(H, "<span class='alert'>An invisible being tried to grab our [L]!</span>")
					boutput(H, "<span class='notification'>We successfully fended off whatever this was.<span>")
				else
					boutput(H, "<span class='alert'>We've been flooded by some kind of disgusting... energy?!</span>")
					boutput(H, "<span class='notification'>...but we managed to drain it through our [L]. We remain whole!</span>")
			else
				if(magical)
					boutput(H, "<span class='alert'>You feel an unseen hand grab onto your [L]!</span>")
					boutput(H, "<span class='notification'>...but a fleshy pseudopod pops out and bats it away[prob(50) ? "!" : "...?"]<span>")
				else
					boutput(H, "<span class='alert'>You feel a cosmic force conduct through your body, coursing into your [L]!</span>")
					boutput(H, "<span class='notification'>...it willomies for a moment, but otherwise it looks just fine.</span>")

		else if(HAS_FLAG(F,LIMB_BEAR))
			if(ch)
				if(magical)
					boutput(H, "<span class='alert'>It felt like we just raked our [pick("viciously restless", "restlessly viscious")] bear claws through an invisible arm!</span>")
					boutput(H, "<span class='notification'>Whatever it was, it seems to be gone now.<span>")
				else
					boutput(H, "<span class='alert'>We've been flooded by some kind of disgusting... energy?!</span>")
					boutput(H, "<span class='notification'>...but the manic flailing of our foreign limb seems to have dissippated it. We remain whole!</span>")
			else
				var/as_what_1 = pick("an invisible", "a phantom", "a spectral")
				var/as_what_2 = pick("ham", "rump roast", "burrito", "wacky water noodle")
				if(magical)
					boutput(H, "<span class='alert'>You feel your [L] slice through what could only be described as [as_what_1] [as_what_2]!</span>")
					boutput(H, "<span class='notification'>You hear a faint whimper...<span>")
				else
					boutput(H, "<span class='alert'>You feel a cosmic force conduct through your body, coursing into your [L]!</span>")
					boutput(H, "<span class='notification'>...it flails around and disperses the energy back into the aether.</span>")

		else if (HAS_FLAG(F,LIMB_BRULLBAR))
			if(magical)
				boutput(H, "<span class='alert'>An invisible hand clamps down around [ch ? "our" : "your"] [L] and yanks it with a powerful, otherworldly force!</span>")
				if(severed)
					boutput(H, "<span class='alert'>[ch ? "Our" : "Your"] [L] rips free from its socket!</span>")
				else
					boutput(H, "<span class='notification'>...but the [L]'s connection to [ch ? "our" : "your"] [armleg == "arm" ? "shoulder" : "hip"] proves to be stronger!</span>")
			else
				boutput(H, "<span class='alert'>[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!</span>")
				if(severed)
					boutput(H, "<span class='alert'>It bursts through [ch ? "our" : "your"] [armleg == "arm" ? "armpit" : "hip"] like a celestial zit, launching [ch ? "our" : "your"] [L] off with the force of a thousand suns!</span>")
				else
					boutput(H, "<span class='notification'>...and then seems to just dissipate back into the aether!</span>")

		else if (HAS_FLAG(F,LIMB_WOLF))
			if(magical)
				boutput(H, "<span class='alert'>A pair of invisible hands clamp down around [ch ? "our" : "your"] [L] and yanks it with a powerful, otherworldly force!</span>")
				if(severed)
					boutput(H, "<span class='alert'>[ch ? "Our" : "Your"] [L] rips free from its socket!</span>")
				else
					boutput(H, "<span class='notification'>...but it slips, only managing to rip out a clump of hair!</span>")
					H.emote("scream")
			else
				boutput(H, "<span class='alert'>[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!</span>")
				if(severed)
					boutput(H, "<span class='alert'>It bursts through [ch ? "our" : "your"] [armleg == "arm" ? "armpit" : "hip"] like a celestial zit, launching [ch ? "our" : "your"] [L] off with the force of a thousand suns!</span>")
				else
					boutput(H, "<span class='notification'>...and then seems to just dissipate back into the aether!</span>")

		else if (HAS_FLAG(F,LIMB_STONE))
			if(magical)
				boutput(H, "<span class='alert'>An invisible hand clamps down around [ch ? "our" : "your"] [L] and yanks it with a powerful, otherworldly force!</span>")
				if(severed)
					boutput(H, "<span class='alert'>[ch ? "Our" : "Your"] [L] breaks off at the [armleg == "arm" ? "shoulder" : "hip"]!</span>")
				else
					boutput(H, "<span class='notification'>...but it slips off the smooth stony finish of [ch ? "our" : "your"] [L]!</span>")
					H.emote("scream")
			else
				boutput(H, "<span class='alert'>[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!</span>")
				if(severed)
					boutput(H, "<span class='alert'>It bursts through [ch ? "our" : "your"] [armleg == "arm" ? "armpit" : "hip"] like a celestial zit, launching [ch ? "our" : "your"] [L] off with the force of a thousand suns!</span>")
				else
					boutput(H, "<span class='notification'>...but [ch ? "our" : "your"] [L] grounds the energy!</span>")

		else if(HAS_FLAG(F, LIMB_ARTIFACT))
			if(magical)
				boutput(H, "<span class='alert'>An invisible hand clamps down around [ch ? "our" : "your"] [L] and yanks it with a powerful, otherworldly force!</span>")
				if(severed)
					boutput(H, "<span class='alert'>[ch ? "Our" : "Your"] [L] is ripped off!</span>")
				else
					boutput(H, "<span class='notification'>...but [ch ? "our" : "your"] [L] resists it!</span>")
			else
				boutput(H, "<span class='alert'>[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!</span>")
				if(severed)
					boutput(H, "<span class='alert'>It bursts through [ch ? "our" : "your"] [armleg == "arm" ? "armpit" : "hip"] like a celestial zit, launching [ch ? "our" : "your"] [L] off with the force of a thousand suns!</span>")
				else
					boutput(H, "<span class='notification'>...but [ch ? "our" : "your"] [L] absorbs the energy!</span>")

		else
			if(magical)
				boutput(H, "<span class='alert'>An invisible hand clamps down around [ch ? "our" : "your"] [L] and yanks it with a powerful, otherworldly force!</span>")
				if(severed)
					boutput(H, "<span class='alert'>[ch ? "Our" : "Your"] [L] rips free from its socket!</span>")
				else
					boutput(H, "<span class='notification'>...but [ch ? "our" : "your"] [armleg == "arm" ? "shoulder" : "hip"] manages to hold it on!</span>")
					H.emote("scream")
			else
				boutput(H, "<span class='alert'>[ch ? "We" : "You"] feel a cosmic force conduct through [ch ? "our" : "your"] body, collecting around [ch ? "our" : "your"] [L]!</span>")
				if(severed)
					boutput(H, "<span class='alert'>It bursts through [ch ? "our" : "your"] [armleg == "arm" ? "armpit" : "hip"] like a celestial zit, launching [ch ? "our" : "your"] [L] off with the force of a thousand suns!</span>")
				else
					boutput(H, "<span class='notification'>...but then it dissipates!</span>")
