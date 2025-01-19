// emote

/mob/living/carbon/human/emote(var/act, var/voluntary = 0, var/emoteTarget = null) //mbc : if voluntary is 2, it's a hotkeyed emote and that means that we can skip the findtext check. I am sorry, cleanup later
	set waitfor = FALSE
	..()
	var/param = null

	if (!bioHolder) bioHolder = new/datum/bioHolder( src )

	if(voluntary && !src.emote_allowed)
		return

	if (isdead(src))
		src.emote_allowed = FALSE
		return

	if (src.hasStatus("paralysis"))
		return //pls stop emoting :((

	if (voluntary && (src.hasStatus("unconscious") || isunconscious(src)))
		return

	if (src.bioHolder.HasEffect("revenant"))
		src.visible_message(SPAN_ALERT("[src] makes [pick("a rude", "an eldritch", "a", "an eerie", "an otherworldly", "a netherly", "a spooky")] gesture!"), group = "revenant_emote")
		return

	if (emoteTarget)
		param = emoteTarget
	else if (voluntary == 1)
		if (findtext(act, " ", 1, null))
			var/t1 = findtext(act, " ", 1, null)
			param = copytext(act, t1 + 1, length(act) + 1)
			act = copytext(act, 1, t1)

	act = lowertext(act)

	var/muzzled = (src.wear_mask && src.wear_mask.is_muzzle)
	var/m_type = 1 //1 is visible, 2 is audible
	var/custom = 0 //Sorry, gotta make this for chat groupings.

	var/maptext_out = 0
	var/message = null

	var/list/mutantrace_emote_stuff = src.mutantrace.emote(act, voluntary)
	if(!islist(mutantrace_emote_stuff))
		message = mutantrace_emote_stuff
	else
		if(length(mutantrace_emote_stuff) >= 1)
			message = mutantrace_emote_stuff[1]
		if(length(mutantrace_emote_stuff) >= 2)
			maptext_out = mutantrace_emote_stuff[2]

	if (!message)
		switch (act)
			// most commonly used emotes first for minor performance improvements
			if ("scream")
				if (src.emote_check(voluntary, 5 SECONDS))
					if(src.bioHolder?.HasEffect("mute"))
						var/pre_message = "[pick("vibrates for a moment, then stops", "opens [his_or_her(src)] mouth, but no sound comes out",
						"tries to scream, but can't", "emits an audible silence", "huffs and puffs with all [his_or_her(src)] might, but can't seem to make a sound",
						"opens [his_or_her(src)] mouth to produce a resounding lack of noise","flails desperately","")]..."
						message = "<B>[src]</B> [pre_message]"
						maptext_out = "<i>[pre_message]</i>"
						m_type = 1
					else if (!muzzled)
						message = "<B>[src]</B> [istype(src.w_uniform, /obj/item/clothing/under/gimmick/frog) ? "croaks" : "screams"]!"
						m_type = 2
						if (src.sound_list_scream && length(src.sound_list_scream))
							playsound(src.loc, pick(src.sound_list_scream), 80, 0, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
						else
							//if (src.gender == MALE)
								//playsound(src, src.sound_malescream, 80, 0, 0, src.get_age_pitch())
							//else
							playsound(src, src.sound_scream, 80, 0, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
						#ifdef HALLOWEEN
						spooktober_GH.change_points(src.ckey, 30)
						#endif
						var/possumMax = 15
						for_by_tcl(responsePossum, /obj/critter/opossum)
							if (!responsePossum.alive)
								continue
							if(!IN_RANGE(responsePossum, src, 4))
								continue
							if (possumMax-- < 0)
								break
							responsePossum.CritterDeath() // startled into playing dead!
						for_by_tcl(P, /mob/living/critter/small_animal/opossum) // is this more or less intensive than a range(4)?
							if (P.playing_dead) // already out
								continue
							if(!IN_RANGE(P, src, 4))
								continue
							P.play_dead(rand(20,40)) // shorter than the regular "death" stun
					else
						message = "<B>[src]</B> makes a very loud noise."
						m_type = 2
					if (src.traitHolder && src.traitHolder.hasTrait("scaredshitless") && !ON_COOLDOWN(src, "scaredshitless", 1 SECOND))
						src.emote("fart") //We can still fart if we're muzzled.

			if ("monsterscream")
				// three things:
				// 1. monsters can scream through a muzzle
				// 2. omnitraitors make all of these noises
				// 3. this is bullshit copy paste. rework emotes and then sue me, in that order
				if (src.emote_check(voluntary, 5 SECONDS))
					var/screamed = FALSE
					if (src.get_ability_holder(/datum/abilityHolder/werewolf)) // is_werewolf only checks mutantrace also kill me
						playsound(src, 'sound/voice/animal/werewolf_howl.ogg', 80, TRUE, extrarange = 2, pitch = clamp(1.0 + (30 - src.bioHolder.age)/60, 0.7, 1.2), channel=VOLUME_CHANNEL_EMOTE)
						screamed = TRUE
					if (ischangeling(src))
						playsound(src, 'sound/voice/creepyshriek.ogg', 80, TRUE, extrarange = 2, pitch = clamp(1.0 + (30 - src.bioHolder.age)/60, 0.7, 1.2), channel=VOLUME_CHANNEL_EMOTE)
						screamed = TRUE
					if (isvampire(src))
						playsound(src, 'sound/effects/screech_tone.ogg', 90, TRUE, extrarange = 2, pitch = clamp(1.0 + (30 - src.bioHolder.age)/60, 0.7, 1.2), channel=VOLUME_CHANNEL_EMOTE)
						screamed = TRUE
					if (isarcfiend(src))
						playsound(src, 'sound/effects/elec_bzzz.ogg', 80, TRUE, extrarange = 2, pitch = clamp(1.0 + (30 - src.bioHolder.age)/60, 0.7, 1.2), channel=VOLUME_CHANNEL_EMOTE)
						screamed = TRUE
					#ifdef HALLOWEEN
					spooktober_GH.change_points(src.ckey, 100)
					#endif

					if (!screamed)
						boutput(src, SPAN_ALERT("You don't feel monstrous enough to do that."))


			if ("fart")
				var/oxyplasmafart = 0
				if (src.emote_check(voluntary) && farting_allowed && (!src.reagents || !src.reagents.has_reagent("anti_fart")))
					if (!src.get_organ("butt"))
						m_type = 1
						if (prob(10))
							switch(rand(1, 5))
								if (1) message = "<B>[src]</B> purses [his_or_her(src)] lips and makes a wet sound. It's not very convincing."
								if (2) message = "<B>[src]</B> quietly peels some eggs. <B>Ugh!</B> what a <i>smell!</i>"
								if (3) message = "<B>[src]</B> does some armpit singing. Rude."
								if (4) message = "<B>[src]</B> manages to blow one out- but it goes <i>right back in!</i>"
								if (5)
									message = SPAN_ALERT("<B>[src]</B> grunts so hard [he_or_she(src)] tears a ligament!")
									src.emote("scream")
									random_brute_damage(src, 20)
						else
							message = "<B>[src]</B> grunts for a moment. Nothing happens."
					else
						m_type = 2


						if (iscluwne(src))
							playsound(src, 'sound/voice/farts/poo.ogg', 50, TRUE, channel=VOLUME_CHANNEL_EMOTE)
						else if (src.organ_istype("butt", /obj/item/clothing/head/butt/cyberbutt))
							playsound(src, 'sound/voice/farts/poo2_robot.ogg', 50, TRUE, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
						else if (src.reagents && src.reagents.has_reagent("honk_fart"))
							playsound(src.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 50, 1, -1, channel=VOLUME_CHANNEL_EMOTE)
						else if (src.getStatusDuration("food_deep_fart"))
							playsound(src, src.sound_fart, 50, 0, 0, src.get_age_pitch() - 0.3, channel=VOLUME_CHANNEL_EMOTE)
						else
							playsound(src, src.sound_fart, 50, 0, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)

						var/fart_on_other = 0
						for (var/atom/A as anything in src.loc)
							if (A.event_handler_flags & IS_FARTABLE && !ON_COOLDOWN(A, "\ref[src]fart", 0.1 SECONDS))
								if (istype(A,/mob/living))
									var/mob/living/M = A
									if (M == src || !M.lying)
										continue
									message = SPAN_ALERT("<B>[src]</B> farts in [M]'s face!")
									if (sims)
										sims.affectMotive("fun", 4)
									if (src.mind)
										if (M.mind && M.mind.assigned_role == "Geneticist")
											src.add_karma(10)
									fart_on_other = 1
									break
								else if (istype(A,/obj/item/bible))
									var/obj/item/bible/B = A
									B.farty_heresy(src)
									fart_on_other = 1
									break
								else if (istype(A,/obj/item/book_kinginyellow))
									var/obj/item/book_kinginyellow/K = A
									K.farty_doom(src)
									fart_on_other = 1
									break
								else if (istype(A,/obj/item/photo/voodoo))
									var/obj/item/photo/voodoo/V = A
									var/mob/M = V.cursed_dude
									if (!M || !M.lying)
										continue
									playsound(M, src.sound_fart, 20, 0, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
									switch(rand(1, 7))
										if (1) M.visible_message(SPAN_EMOTE("<b>[M]</b> suddenly radiates an unwelcoming odor."))
										if (2) M.visible_message(SPAN_EMOTE("<b>[M]</b> is visited by ethereal incontinence."))
										if (3) M.visible_message(SPAN_EMOTE("<b>[M]</b> experiences paranormal gastrointestinal phenomena."))
										if (4) M.visible_message(SPAN_EMOTE("<b>[M]</b> involuntarily telecommutes to the farty party."))
										if (5) M.visible_message(SPAN_EMOTE("<b>[M]</b> is swept over by a mysterious draft."))
										if (6) M.visible_message(SPAN_EMOTE("<b>[M]</b> abruptly emits an odor of cheese."))
										if (7) M.visible_message(SPAN_EMOTE("<b>[M]</b> is set upon by extradimensional flatulence."))
									if (sims)
										sims.affectMotive("fun", 4)
									//break deliberately omitted

						if (!fart_on_other)
							switch(rand(1, 42))
								if (1) message = "<B>[src]</B> lets out a little 'toot' from [his_or_her(src)] butt."
								if (2) message = "<B>[src]</B> farts loudly!"
								if (3) message = "<B>[src]</B> lets one rip!"
								if (4) message = "<B>[src]</B> farts! It sounds wet and smells like rotten eggs."
								if (5) message = "<B>[src]</B> farts robustly!"
								if (6) message = "<B>[src]</B> farted! It smells like something died."
								if (7) message = "<B>[src]</B> farts like a muppet!"
								if (8) message = "<B>[src]</B> defiles the station's air supply."
								if (9) message = "<B>[src]</B> farts a ten second long fart."
								if (10) message = "<B>[src]</B> groans and moans, farting like the world depended on it."
								if (11) message = "<B>[src]</B> breaks wind!"
								if (12) message = "<B>[src]</B> expels intestinal gas through the anus."
								if (13) message = "<B>[src]</B> release an audible discharge of intestinal gas."
								if (14) message = "<B>[src]</B> is a farting motherfucker!!!"
								if (15) message = "<B>[src]</B> suffers from flatulence!"
								if (16) message = "<B>[src]</B> releases flatus."
								if (17) message = "<B>[src]</B> releases methane."
								if (18) message = "<B>[src]</B> farts up a storm."
								if (19) message = "<B>[src]</B> farts. It smells like Soylent Surprise!"
								if (20) message = "<B>[src]</B> farts. It smells like pizza!"
								if (21) message = "<B>[src]</B> farts. It smells like George Melons' perfume!"
								if (22) message = "<B>[src]</B> farts. It smells like the kitchen!"
								if (23) message = "<B>[src]</B> farts. It smells like medbay in here now!"
								if (24) message = "<B>[src]</B> farts. It smells like the bridge in here now!"
								if (25) message = "<B>[src]</B> farts like a pubby!"
								if (26) message = "<B>[src]</B> farts like a goone!"
								if (27) message = "<B>[src]</B> sharts! That's just nasty."
								if (28) message = "<B>[src]</B> farts delicately."
								if (29) message = "<B>[src]</B> farts timidly."
								if (30) message = "<B>[src]</B> farts very, very quietly. The stench is OVERPOWERING."
								if (31) message = "<B>[src]</B> farts egregiously."
								if (32) message = "<B>[src]</B> farts voraciously."
								if (33) message = "<B>[src]</B> farts cantankerously."
								if (34) message = "<B>[src]</B> fart in [he_or_she(src)] own mouth. A shameful [src]."
								if (35)
									message = "<B>[src]</B> farts out pure plasma! [SPAN_ALERT("<B>FUCK!</B>")]"
									oxyplasmafart = 1
								if (36)
									message = "<B>[src]</B> farts out pure oxygen. What the fuck did [he_or_she(src)] eat?"
									oxyplasmafart = 2
								if (37) message = "<B>[src]</B> breaks wind noisily!"
								if (38) message = "<B>[src]</B> releases gas with the power of the gods! The very station trembles!!"
								if (39) message = "<B>[src] <span style='color:red'>f</span><span style='color:blue'>a</span>r<span style='color:red'>t</span><span style='color:blue'>s</span>!</B>"
								if (40) message = "<B>[src]</B> laughs! [his_or_her(src)] breath smells like a fart."
								if (41) message = "<B>[src]</B> farts, and as such, blob cannot evoulate."
								if (42) message = "<b>[src]</B> farts. It might have been the Citizen Kane of farts."

						// If there is a chest item, see if it can be activated on fart (attack_self)
						if (src && src.chest_item != null) //Gotta do that pre-emptive runtime protection!
							src.chest_item_attack_self_on_fart()

						if (src.bioHolder)
							var/toxic = src.bioHolder.HasEffect("toxic_farts")
							if (toxic)
								message = SPAN_ALERT("<B>[src] [pick("unleashes","rips","blasts")] \a [pick("truly","utterly","devastatingly","shockingly")] [pick("hideous","horrendous","horrific","heinous","horrible")] fart!</B>")
								var/turf/fart_turf = get_turf(src)
								fart_turf.fluid_react_single("[toxic > 1 ?"very_":""]toxic_fart", toxic*2, airborne = 1)

							if (src.bioHolder.HasEffect("linkedfart"))
								for(var/mob/living/H in mobs)
									if (H.bioHolder && H.bioHolder.HasEffect("linkedfart")) continue
									var/found_bible = 0
									for (var/atom/A as anything in H.loc)
										if (A.event_handler_flags & IS_FARTABLE)
											if (istype(A,/obj/item/bible))
												found_bible = 1
									if (found_bible)
										src.visible_message(SPAN_ALERT("<b>A mysterious force smites [src.name] for inciting blasphemy!</b>"))
										src.gib()
									else
										H.emote("fart")

						var/turf/T = get_turf(src)
						if (T && T == src.loc)
							if (T.turf_flags & CAN_BE_SPACE_SAMPLE)
								if (src.getStatusDuration("food_space_farts"))
									src.inertia_dir = src.dir
									step(src, inertia_dir)
									SPAWN(1 DECI SECOND)
										src.inertia_dir = src.dir
										step(src, inertia_dir)
							else
								if(prob(10) && istype(src.loc, /turf/simulated/floor/specialroom/freezer)) //ZeWaka: Fix for null.loc
									message = "<b>[src]</B> farts. The fart freezes in MID-AIR!!!"
									new/obj/item/material_piece/fart(src.loc)
									var/obj/item/material_piece/fart/F = new /obj/item/material_piece/fart
									F.set_loc(src.loc)

						src.expel_fart_gas(oxyplasmafart)

						src.stamina_stun()
						fartcount++
						if(fartcount == 69 || fartcount == 420)
							var/obj/item/paper/grillnasium/fartnasium_recruitment/flyer/F = new(get_turf(src))
							src.put_in_hand_or_drop(F)
							src.visible_message("<b>[src]</B> farts out a... wait is this viral marketing?")
#if defined(MAP_OVERRIDE_POD_WARS)
						if (istype(ticker.mode, /datum/game_mode/pod_wars))
							var/datum/game_mode/pod_wars/mode = ticker.mode
							mode.stats_manager?.inc_farts(src)
#endif
		#ifdef DATALOGGER
						game_stats.Increment("farts")
		#endif
				if(src.bioHolder && src.traitHolder.hasTrait("training_miner") && prob(1))
					var/glowsticktype = pick(typesof(/obj/item/device/light/glowstick))
					var/obj/item/device/light/glowstick/G = new glowsticktype
					G.set_loc(src.loc)
					G.turnon()
					var/turf/target = get_offset_target_turf(src.loc, (rand(5)-rand(5)), (rand(5)-rand(5)))
					G.throw_at(target,5,1)
					src.visible_message("<b>[src]</B> farts out a...glowstick?")

			if ("salute","saluteto","bow","hug","wave","waveto","blowkiss","sidehug","fingerguns")
				// visible targeted emotes
				if (!src.restrained())
					var/M = null
					var/range = 5
					if (act == "hug" || act == "sidehug")
						range = 1
					if (param)
						for (var/atom/movable/A in view(range, src))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					else if(act != "wave" && act != "salute") // use *waveto to wave to someone, *saluteto too salute someone
						var/list/target_list = src.get_targets(range, "mob")
						if(length(target_list))
							var/action_phrase = "emote upon"
							switch(act)
								if("salute", "hug", "sidehug")
									action_phrase = act
								if("bow")
									action_phrase = "bow before"
								if("waveto")
									action_phrase = "wave to"
								if("blowkiss")
									action_phrase = "to whom you'll blow a [prob(1) ? "smooch" : "kiss"]"
								if("fingerguns")
									action_phrase = "point finger guns at"
							M = tgui_input_list(src, "Pick something to [action_phrase]!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))
							if (M && (range > 1 && !IN_RANGE(get_turf(src), get_turf(M), range)) || (range == 1 && !in_interact_range(src, M)) )
								var/inaction_phrase = "emote upon"
								switch(act)
									if("salute")
										inaction_phrase = "saluting"
									if("hug","sidehug")
										inaction_phrase = "[act]ging"
									if("bow")
										inaction_phrase = "[prob(1) ? "prostration" : "bowing"]"
									if("waveto")
										inaction_phrase = "waving"
									if("blowkiss")
										inaction_phrase = "[prob(1) ? "smooching" : "kissing"]"
								boutput(src, SPAN_EMOTE("<B>[M]</B> is not in [inaction_phrase] distance!"))
								return

					act = lowertext(act)
					if (M)
						switch(act)
							if ("bow","wave")
								message = "<B>[src]</B> [act]s to [M]."
								maptext_out = "<I>[act]s to [M]</I>"
							if ("waveto")
								message = "<B>[src]</B> waves to [M]."
								maptext_out = "<I>waves to [M]</I>"
							if ("saluteto")
								message = "<B>[src]</B> salutes [M]."
								maptext_out = "<I>salutes [M]</I>"
							if ("sidehug")
								message = "<B>[src]</B> awkwardly side-hugs [M]."
								maptext_out = "<I>awkwardly side-hugs [M]</I>"
							if ("blowkiss")
								message = "<B>[src]</B> blows a kiss to [M]."
								maptext_out = "<I>blows a kiss to [M]</I>"
								//var/atom/U = get_turf(param)
								//shoot_projectile_ST_pixel_spread(src, new/datum/projectile/special/kiss(), U) //I gave this all of 5 minutes of my time I give up
							if ("fingerguns")
								message = "<B>[src]</B> points finger guns at [M]!"
								maptext_out = "<I>points finger guns at [M]!</I>"
							else
								message = "<B>[src]</B> [act]s [M]."
								maptext_out = "<I>[act]s [M]</I>"
					else
						var/obj/item/I = src.equipped()
						switch(act)
							if ("hug", "sidehug")
								message = "<B>[src]</b> [act]s [himself_or_herself(src)]."
								maptext_out = "<I>[act]s [himself_or_herself(src)]</I>"
							if ("blowkiss")
								message = "<B>[src]</b> blows a kiss to... [himself_or_herself(src)]?"
								maptext_out = "<I> blows a kiss to... [himself_or_herself(src)]?</I>"
							if ("fingerguns")
								message = "<B>[src]</b> points finger guns at... [himself_or_herself(src)]?"
								maptext_out = "<I> points finger guns at... [himself_or_herself(src)]?</I>"
							else
								if ("wave" && istype(I, /obj/item/cloth/handkerchief))
									message = "<B>[src]</b> waves [I]."
									maptext_out = "<I>waves [I]</I>"
								else
									message = "<B>[src]</b> [act]s."
									maptext_out = "<I>[act]s</I>"
								src.add_karma(2)

				else
					message = "<B>[src]</B> struggles to move."
					maptext_out = "<I>struggles to move</I>"

				m_type = 1
			if ("nod","nodat","glare","glareat","stare","stareat","look")
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (ckey(param) == ckey(A.name))
							M = A
							break
				else if(act != "nod" && act != "glare" && act != "stare") // use *nodat to nod to something
					var/list/target_list = src.get_targets(5, "mob")
					if(length(target_list))
						var/action_phrase = "[act] at"
						M = tgui_input_list(src, "Pick something to [action_phrase]!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))
						if (M && !IN_RANGE(get_turf(src), get_turf(M), 5))
							var/inaction_phrase = "emote upon"
							switch(act)
								if("nodat")
									inaction_phrase = "not in acknowledgement distance"
								if("glareat", "stareat", "look")
									inaction_phrase = "[prob(1) ? "out of sight" : "not in sight"]"
							boutput(src, SPAN_EMOTE("<B>[M]</B> is [inaction_phrase]!"))
							return

				act = lowertext(act)
				if (M)
					switch(act)
						if ("nodat")
							message = "<B>[src]</B> nods at [M]."
							maptext_out = "<I>nods at [M]</I>"
						if ("stareat")
							message = "<B>[src]</B> stares at [M]."
							maptext_out = "<I>stares at [M]</I>"
						if ("glareat")
							message = "<B>[src]</B> glares at [M]."
							maptext_out = "<I>glares at [M]</I>"
						if ("glare","stare","look","nod")
							message = "<B>[src]</B> [act]s at [M]."
							maptext_out = "<I>[act]s at [M]</I>"
				else
					message = "<B>[src]</b> [act]s."
					maptext_out = "<I>[act]s</I>"

				m_type = 1

			// other emotes

			if ("custom")
				if (src.client)
					if (IS_TWITCH_CONTROLLED(src)) return
					var/input = copytext(sanitize(html_encode(input("Choose an emote to display."))), 1, MAX_MESSAGE_LEN)
					var/input2 = input("Is this a visible or audible emote?") in list("Visible","Audible")
					if (input2 == "Visible") m_type = 1
					else if (input2 == "Audible") m_type = 2
					else
						alert("Unable to use this emote, must be either audible or visible.")
						return
					phrase_log.log_phrase("emote", input)
					message = "<B>[src]</B> [input]"
					maptext_out = "<I>[regex({"(&#34;.*?&#34;)"}, "g").Replace(input, "</i>$1<i>")]</I>"
					custom = copytext(input, 1, 10)

			if ("customv")
				if (IS_TWITCH_CONTROLLED(src)) return
				if (!param)
					param = input("Choose an emote to display.")
					if(!param) return
				else //hack to fix double encoding of custom emotes when using hotkey, speech code is a knotted mess
					param = html_decode(param)

				param = copytext(sanitize(html_encode(param)), 1, MAX_MESSAGE_LEN)
				phrase_log.log_phrase("emote", param)
				message = "<b>[src]</b> [param]"
				maptext_out = "<I>[regex({"(&#34;.*?&#34;)"}, "g").Replace(param, "</i>$1<i>")]</I>"
				m_type = 1
				custom = copytext(param, 1, 10)

			if ("customh")
				if (IS_TWITCH_CONTROLLED(src)) return
				if (!param)
					param = input("Choose an emote to display.")
					if(!param) return
				param = copytext(sanitize(html_encode(param)), 1, MAX_MESSAGE_LEN)
				phrase_log.log_phrase("emote", param)
				message = "<b>[src]</b> [param]"
				maptext_out = "<I>[regex({"(&#34;.*?&#34;)"}, "g").Replace(param, "</i>$1<i>")]</I>"
				m_type = 2
				custom = copytext(param, 1, 10)

			if ("me")
				if (IS_TWITCH_CONTROLLED(src)) return
				if (!param)
					return
				param = copytext(sanitize(param), 1, MAX_MESSAGE_LEN)
				phrase_log.log_phrase("emote", param)
				message = "<b>[src]</b> [param]"
				maptext_out = "<I>[regex({"(&#34;.*?&#34;)"}, "g").Replace(param, "</i>$1<i>")]</I>"
				m_type = 1 // default to visible
				custom = copytext(param, 1, 10)

			if ("give")
				if (!src.restrained())
					if (!src.emote_check(voluntary, 50))
						return
					var/obj/item/thing = src.equipped()
					if (!thing)
						if (src.l_hand)
							thing = src.l_hand
						else if (src.r_hand)
							thing = src.r_hand

					if (thing)
						var/mob/living/carbon/human/H = null
						if (param)
							for (var/mob/living/carbon/human/M in view(1, src))
								if (ckey(param) == ckey(M.name) && can_act(M, TRUE))
									H = M
									break
						else
							var/list/possible_recipients = list()
							for (var/mob/living/carbon/human/M in view(1, src))
								if (M != src && can_act(M, TRUE))
									possible_recipients += M
							if (length(possible_recipients) > 1)
								H = input(src, "Who would you like to hand your [thing] to?", "Choice") as null|anything in possible_recipients
							else if (length(possible_recipients) == 1)
								H = possible_recipients[1]

#ifdef TWITCH_BOT_ALLOWED
						if (IS_TWITCH_CONTROLLED(H))
							return
#endif
						maptext_out = "<I>offers to [H]...</I>"
						src.give_to(H)
						return
				m_type = 1

			if ("help")
				src.show_text("To use emotes, simply enter 'me (emote)' in the input bar. Certain emotes can be targeted at other characters - to do this, enter 'me (emote) (name of character)' without the brackets.")
				src.show_text("For a list of all emotes, use 'me list'. For a list of basic emotes, use 'me listbasic'. For a list of emotes that can be targeted, use 'me listtarget'.")

			if ("listbasic")
				src.show_text("smile, grin, smirk, frown, scowl, grimace, sulk, pout, nod, blink, drool, shrug, tremble, quiver, shiver, shudder, shake, \
				think, ponder, clap, wave, salute, flap, aflap, laugh, chuckle, giggle, chortle, guffaw, cough, hiccup, sigh, mumble, grumble, groan, moan, sneeze, \
				wheeze, sniff, snore, whimper, yawn, choke, gasp, weep, sob, wail, whine, gurgle, gargle, blush, flinch, blink_r, eyebrow, shakehead, \
				pale, flipout, rage, shame, raisehand, crackknuckles, stretch, rude, cry, retch, raspberry, tantrum, gesticulate, wgesticulate, smug, \
				nosepick, flex, facepalm, panic, snap, airquote, twitch, twitch_v, faint, deathgasp, signal, wink, collapse, trip, dance, scream, \
				burp, fart, monologue, contemplate, custom")

			if ("listtarget")
				src.show_text("salute, bow, hug, wave, glare, stare, look, nod, flipoff, doubleflip, shakefist, handshake, daps, slap, boggle, highfive, fingerguns")
			if ("list")
				src.emote("listbasic")
				src.emote("listtarget")
			if ("suicide")
				src.show_text("Suicide is a command, not an emote.  Please type 'suicide' in the input bar at the bottom of the game window to kill yourself.", "red")

	//april fools start

			if ("inhale")
				if (!manualbreathing)
					src.show_text("You are already breathing!")
					return

				var/datum/lifeprocess/breath/B = lifeprocesses?[/datum/lifeprocess/breath]
				if (B)
					if (B.breathstate)
						src.show_text("You just breathed in, try breathing out next dummy!")
						return
					B.breathtimer = 0
					B.breathstate = 1

				src.show_text("You breathe in.")

			if ("exhale")
				if (!manualbreathing)
					src.show_text("You are already breathing!")
					return

				var/datum/lifeprocess/breath/B = lifeprocesses?[/datum/lifeprocess/breath]
				if (B)
					if (!B.breathstate)
						src.show_text("You just breathed out, try breathing in next silly!")
						return
					B.breathstate = 0

				src.show_text("You breathe out.")

			if ("closeeyes")
				if (!manualblinking)
					src.show_text("Why would you want to do that?")
					return

				var/datum/lifeprocess/statusupdate/S = lifeprocesses?[/datum/lifeprocess/statusupdate]
				if (S)
					if (S.blinkstate)
						src.show_text("You just closed your eyes, try opening them now dumbo!")
						return
					S.blinkstate = 1
					S.blinktimer = 0

				src.show_text("You close your eyes.")

			if ("openeyes")
				if (!manualblinking)
					src.show_text("Your eyes are already open!")
					return

				var/datum/lifeprocess/statusupdate/S = lifeprocesses?[/datum/lifeprocess/statusupdate]
				if (S)
					if (!S.blinkstate)
						src.show_text("Your eyes are already open, try closing them next moron!")
						return
					S.blinkstate = 0

				src.show_text("You open your eyes.")

	//april fools end

			if ("birdwell")
				if ((src.client && src.client.holder) && src.emote_check(voluntary, 50))
					message = "<B>[src]</B> birdwells."
					maptext_out = "<I>birdwells</I>"
					playsound(src.loc, 'sound/vox/birdwell.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
				else
					if (voluntary)
						src.show_text("Unusable emote '[act]'. 'Me help' for a list.", "blue")
					return

			if ("uguu")
				if (istype(src.wear_mask, /obj/item/clothing/mask/anime) && !src.stat)

					message = "<B>[src]</B> uguus!"
					maptext_out = "<I>uguus</I>"
					m_type = 2
					playsound(src, 'sound/voice/uguu.ogg', 80, FALSE, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
					SPAWN(1 SECOND)
						src.wear_mask.set_loc(src.loc)
						src.wear_mask = null
						logTheThing(LOG_COMBAT, src, "was gibbed by emoting uguu at [log_loc(src)].")
						src.gib()
						return
				else
					src.show_text("You just don't feel kawaii enough to uguu right now!", "red")
					return

			if ("juggle")
				if (!src.restrained())
					if (src.emote_check(voluntary, 25))
						m_type = 1
						if (src.traitHolder?.hasTrait("training_clown") || src.traitHolder?.hasTrait("training_mime") || src.can_juggle)
							var/obj/item/thing = src.equipped()
							if (!thing)
								if (src.l_hand)
									thing = src.l_hand
								else if (src.r_hand)
									thing = src.r_hand
							if (thing && !thing.cant_drop)
								if (src.juggling())
									if (prob(src.juggling.len * 5)) // might drop stuff while already juggling things
										src.drop_juggle()
									else
										src.add_juggle(thing)
								else
									src.add_juggle(thing)
							else
								message = "<B>[src]</B> wiggles [his_or_her(src)] fingers a bit.[prob(10) ? " Weird." : null]"
								maptext_out = "<I>wiggles [his_or_her(src)] fingers a bit.</I>"
			if ("twirl", "spin"/*, "juggle"*/)
				if (!src.restrained())
					if (src.emote_check(voluntary, 25))
						m_type = 1

						var/obj/item/thing = src.equipped()
						if (!thing)
							if (src.l_hand)
								thing = src.l_hand
							else if (src.r_hand)
								thing = src.r_hand
						if (thing && !(istype(thing, /obj/item/grab)))
							SEND_SIGNAL(thing, COMSIG_ITEM_TWIRLED, src, thing)
							message = thing.on_spin_emote(src)
							maptext_out = "<I>twirls [thing]</I>"
							animate_spin(thing, prob(50) ? "L" : "R", 1, 0)
						else
							message = "<B>[src]</B> wiggles [his_or_her(src)] fingers a bit.[prob(10) ? " Weird." : null]"
							maptext_out = "<I>wiggles [his_or_her(src)] fingers a bit.</I>"
				else
					message = "<B>[src]</B> struggles to move."
					maptext_out = "<I>struggles to move</I>"

			if ("tip")
				if (!src.restrained() && !src.stat)
					if (istype(src.head, /obj/item/clothing/head/mj_hat || /obj/item/clothing/head/det_hat/))
						src.say (pick("M'lady", "M'lord", "M'liege")) //male, female and non-binary variants with alliteration
					if (istype(src.head, /obj/item/clothing/head/fedora))
						src.visible_message("[src] tips [his_or_her(src)] fedora and smirks.")
						src.say ("M'lady")
						SPAWN(1 SECOND)
							src.add_karma(-10)
							logTheThing(LOG_COMBAT, src, "was gibbed by emoting fedora tipping at [log_loc(src)].")
							src.gib()

			if ("hatstomp", "stomphat")
				if (!src.restrained())
					var/obj/item/clothing/head/hos_hat/hat = src.find_type_in_hand(/obj/item/clothing/head/hos_hat)
					var/hat_or_beret = null
					var/already_stomped = null // store the picked phrase in here
					var/on_head = 0

					if (!hat) // if the find_type_in_hand() returned 0 earlier
						if (istype(src.head, /obj/item/clothing/head/hos_hat)) // maybe it's on our head?
							hat = src.head
							on_head = 1
						else // if not then never mind
							return
					if (hat.icon_state == "hosberet" || hat.icon_state == "hosberet-smash") // does it have one of the beret icons?
						hat_or_beret = "beret" // call it a beret
					else // otherwise?
						hat_or_beret = "hat" // call it a hat. this should cover cases where the hat somehow doesn't have either hosberet or hoscap
					if (hat.icon_state == "hosberet-smash" || hat.icon_state == "hoscap-smash") // has it been smashed already?
						already_stomped = pick(" That [hat_or_beret] has seen better days.", " That [hat_or_beret] is looking pretty shabby.", " How much more abuse can that [hat_or_beret] take?", " It looks kinda ripped up now.") // then add some extra flavor text

					// the actual messages are generated here
					if (on_head)
						message = "<B>[src]</B> yanks [his_or_her(src)] [hat_or_beret] off [his_or_her(src)] head, throws it on the floor and stomps on it![already_stomped]\
						<br><B>[src]</B> grumbles, \"<i>rasmn frasmn grmmn[prob(1) ? " dick dastardly" : null]</i>.\""
					else
						message = "<B>[src]</B> throws [his_or_her(src)] [hat_or_beret] on the floor and stomps on it![already_stomped]\
						<br><B>[src]</B> grumbles, \"<i>rasmn frasmn grmmn</i>.\""

					maptext_out = "<I>stomps on [his_or_her(src)] hat!</I>"

					src.drop_from_slot(hat) // we're done here, drop that hat!
					hat.pixel_x = 0
					hat.pixel_y = -16

					animate_stomp(src)

					SPAWN(0.5 SECONDS)
						if (hat_or_beret == "beret")
							hat.icon_state="hosberet-smash"
						else
							hat.icon_state="hoscap-smash"
					if(src.mind && src.mind.assigned_role != "Head of Security")
						src.add_karma(5)
				else
					message = "<B>[src]</B> tries to move [his_or_her(src)] arm and grumbles."
				m_type = 1

			if ("bubble")
				var/obj/item/clothing/mask/bubblegum/gum = src.wear_mask
				if (!istype(gum))
					return
				if (!muzzled)
					if (src.emote_check(voluntary, 25))
						message = "<B>[src]</B> blows a bubble."
						maptext_out = "<I>blows a bubble</I>"
						//todo: sound
						//todo: gum icon animation?
						if (gum.reagents && gum.reagents.total_volume)
							gum.reagents.reaction(get_turf(src), TOUCH, gum.chew_size)
				else
					message = "<B>[src]</B> tries to make a noise."
					maptext_out = "<I>tries to make a noise</I>"
				m_type = 2

			if ("handpuppet")
				message = "<b>[src]</b> throws [his_or_her(src)] voice, badly, while flapping [his_or_her(src)] thumb and index finger like some sort of lips.[prob(10) ? " Admittedly, it is a pretty good impression of the [pick("captain", "head of personnel", "clown", "research director", "chief engineer", "head of security", "medical director", "AI", "chaplain", "detective")]." : null]"
				m_type = 1

			if ("smile","grin","smirk","frown","scowl","grimace","sulk","pout","blink","drool","shrug","tremble","quiver","shiver","shudder","shake","think","ponder","contemplate","grump","squint")
				// basic visible single-word emotes
				message = "<B>[src]</B> [act]s."
				maptext_out = "<I>[act]s</I>"
				m_type = 1

			if (":)")
				message = "<B>[src]</B> smiles."
				maptext_out = "<I>smiles</I>"
				m_type = 1

			if (":(")
				message = "<B>[src]</B> frowns."
				maptext_out = "<I>frowns</I>"
				m_type = 1

			if (":d", ">:)") // the switch is lowertext()ed so this is what :D would be
				message = "<B>[src]</B> grins."
				maptext_out = "<I>grins</I>"
				m_type = 1

			if ("d:", "dx") // same as above for D: and DX
				message = "<B>[src]</B> grimaces."
				maptext_out = "<I>grimaces</I>"
				m_type = 1

			if (">:(")
				message = "<B>[src]</B> scowls."
				maptext_out = "<I>scowls</I>"
				m_type = 1

			if (":j")
				message = "<B>[src]</B> smirks."
				maptext_out = "<I>smirks</I>"
				m_type = 1

			if (":i")
				message = "<B>[src]</B> grumps."
				maptext_out = "<I>grumps</I>"
				m_type = 1

			if (":|")
				message = "<B>[src]</B> stares."
				maptext_out = "<I>stares</I>"
				m_type = 1

			if ("xd")
				message = "<B>[src]</B> laughs."
				maptext_out = "<I>laughs</I>"
				m_type = 1

			if (":c")
				message = "<B>[src]</B> pouts."
				maptext_out = "<I>pouts</I>"
				m_type = 1

			if ("clap")
				// basic visible single-word emotes - unusable while restrained
				if (!src.restrained())
					message = "<B>[src]</B> [lowertext(act)]s."
					maptext_out = "<I>claps</I>"
				else
					message = "<B>[src]</B> struggles to move."
					maptext_out = "<I>struggles to move</I>"
				m_type = 1

			if ("cough","hiccup","sigh","mumble","grumble","groan","moan","sneeze","wheeze","sniff","snore","whimper","noncontagiousyawn","yawn","choke","gasp","weep","sob","wail","whine","gurgle","gargle","wheeze","sputter","scoff",)
				// basic audible single-word emotes
				if (!muzzled)
					if (lowertext(act) == "sigh" && prob(1)) act = "singh" //1% chance to change sigh to singh. a bad joke for drsingh fans.
					var/obj/item/I = src.equipped()
					if (istype(I, /obj/item/cloth/handkerchief))
						message = "<B>[src]</B> [act]s into [I]."
						maptext_out = "<I>[act]s into [I]</I>"
					else if (act == "sneeze" && prob(1) && (src.mind?.assigned_role == "Clown" || src.reagents.has_reagent("honky_tonic")))
						message = "<B>[src]</B> sneezes out a handkerchief!"
						maptext_out = "<I>sneezes out a handkerchief!</I>"
						var/obj/HK = new /obj/item/cloth/handkerchief/random(get_turf(src))
						var/turf/T = get_edge_target_turf(src, pick(alldirs))
						HK.throw_at(T, 5, 1)
					else if (act == "noncontagiousyawn")
						message = "<B>[src]</B> yawns."
						maptext_out = "<I>yawns</I>"
					else if (act == "yawn")
						message = "<B>[src]</B> [act]s."
						maptext_out = "<I>[act]s</I>"
						for (var/mob/living/carbon/C in view(5,get_turf(src)))
							if (prob(5) && !ON_COOLDOWN(C, "contagious_yawn", 5 SECONDS))
								C.emote("noncontagiousyawn")
					else
						message = "<B>[src]</B> [act]s."
						maptext_out = "<I>[act]s</I>"
				else
					message = "<B>[src]</B> tries to make a noise."
					maptext_out = "<I>tries to make a noise</I>"
				m_type = 2

				if (src.emote_check(voluntary,20))
					if (act == "gasp")
						if (src.health <= 0)
							var/dying_gasp_sfx = "sound/voice/gasps/[src.gender]_gasp_[pick(1,5)].ogg"
							playsound(src, dying_gasp_sfx, 40, FALSE, 0, src.get_age_pitch())
						else
							playsound(src, src.sound_gasp, 15, 0, 0, src.get_age_pitch())

			if ("laugh","chuckle","giggle","chortle","guffaw","cackle")
				if (!muzzled)
					message = "<B>[src]</B> [act]s."
					maptext_out = "<I>[act]s</I>"
					if (src.sound_list_laugh && length(src.sound_list_laugh))
						playsound(src.loc, pick(src.sound_list_laugh), 80, 0, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
				else
					message = "<B>[src]</B> tries to make a noise."
					maptext_out = "<I>tries to make a noise</I>"
				m_type = 2

			// basic emotes that change the wording a bit

			if ("blush")
				message = "<B>[src]</B> blushes."
				maptext_out = "<I>blushes</I>"
				m_type = 1

			if ("flinch")
				message = "<B>[src]</B> flinches."
				maptext_out = "<I>flinches</I>"
				m_type = 1

			if ("blink_r")
				message = "<B>[src]</B> blinks rapidly."
				maptext_out = "<I>blinks rapidly</I>"
				m_type = 1

			if ("eyebrow","raiseeyebrow")
				message = "<B>[src]</B> raises an eyebrow."
				maptext_out = "<I>raises an eyebrow</I>"
				m_type = 1

			if ("shakehead","smh")
				message = "<B>[src]</B> shakes [his_or_her(src)] head."
				maptext_out = "<I>shakes [his_or_her(src)] head</I>"
				m_type = 1

			if ("pale")
				message = "<B>[src]</B> goes pale for a second."
				maptext_out = "<I>goes pale...</I>"
				m_type = 1

			if ("flipout")
				message = "<B>[src]</B> flips the fuck out!"
				maptext_out = "<I>flips the fuck out!</I>"
				m_type = 1

			if ("rage","fury","angry")
				message = "<B>[src]</B> becomes utterly furious!"
				maptext_out = "<I>becomes utterly furious!</I>"
				m_type = 1

			if ("shame","hanghead")
				message = "<B>[src]</B> hangs [his_or_her(src)] head in shame."
				maptext_out = "<I>hangs [his_or_her(src)] head in shame</I>"
				m_type = 1

			if ("nods", "nodslowly")
				message = "<B>[src]</B> nods slowly."
				maptext_out = "<I>nods slowly</I>"
				m_type = 1

			if ("stareh", "starehands")
				message = "<B>[src]</B> stares at [his_or_her(src)] hands."
				maptext_out = "<I>stares at [his_or_her(src)] hands</I>"
				m_type = 1

			if ("jsay")
				message = "<B>[src]</B> just stares at you."
				maptext_out = "<I>just stares at you</I>"
				m_type = 1

			// basic emotes with alternates for restraints

			if ("flap")
				if (!src.restrained())
					message = "<B>[src]</B> flaps [his_or_her(src)] arms!"
					maptext_out = "<I>flaps [his_or_her(src)] arms!</I>"
					if (src.sound_list_flap && length(src.sound_list_flap))
						playsound(src.loc, pick(src.sound_list_flap), 80, 0, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
				else
					message = "<B>[src]</B> writhes!"
					maptext_out = "<I>writhes!</I>"
				m_type = 1

			if ("aflap")
				if (!src.restrained())
					message = "<B>[src]</B> flaps [his_or_her(src)] arms ANGRILY!"
					maptext_out = "<I>flaps [his_or_her(src)] arms ANGRILY!</I>"
					if (src.sound_list_flap && length(src.sound_list_flap))
						playsound(src.loc, pick(src.sound_list_flap), 80, 0, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
				else
					message = "<B>[src]</B> writhes angrily!"
					maptext_out = "<I>writhes angrily!</I>"
				m_type = 1

			if ("raisehand")
				if (!src.restrained())
					var/obj/item/thing = src.equipped()
					if (thing)
						message = "<B>[src]</B> raises [thing]."
						maptext_out = "<I>raises [thing]</I>"
					else
						message = "<B>[src]</B> raises a hand."
						maptext_out = "<I>raises a hand</I>"
				else
					message = "<B>[src]</B> tries to move [his_or_her(src)] arm."
					maptext_out = "<I>tries to move [his_or_her(src)] arm</I>"
				m_type = 1

			if ("crackknuckles","knuckles")
				if (!src.restrained())
					message = "<B>[src]</B> cracks [his_or_her(src)] knuckles."
					maptext_out = "<I>cracks [his_or_her(src)] knuckles</I>"
				else
					message = "<B>[src]</B> irritably shuffles around."
					maptext_out = "<I>irritably shuffles around</I>"
				m_type = 1

			if ("stretch")
				if (!src.restrained())
					message = "<B>[src]</B> stretches."
					maptext_out = "<I>stretches</I>"
				else
					message = "<B>[src]</B> writhes around slowly."
					maptext_out = "<I>writhes around slowly</I>"
				m_type = 1

			if ("rude")
				if (!src.restrained())
					message = "<B>[src]</B> makes a rude gesture."
					maptext_out = "<I>makes a rude gesture</I>"
				else
					message = "<B>[src]</B> tries to move [his_or_her(src)] arm."
					maptext_out = "<I>tries to move [his_or_her(src)] arm</I>"
				m_type = 1

			if ("cry")
				if (!muzzled)
					message = "<B>[src]</B> cries."
					maptext_out = "<I>cries</I>"
				else
					message = "<B>[src]</B> makes an odd noise. A tear runs down [his_or_her(src)] face."
					maptext_out = "<I>makes an odd noise</I>"
				m_type = 2

			if ("retch","gag")
				if (!muzzled)
					message = "<B>[src]</B> retches in disgust!"
					maptext_out = "<I>retches in disgust!</I>"
				else
					message = "<B>[src]</B> makes a strange choking sound."
					maptext_out = "<I>makes a strange choking sound</I>"
				m_type = 2

			if ("raspberry")
				if (!muzzled)
					message = "<B>[src]</B> blows a raspberry."
					maptext_out = "<I>blows a raspberry</I>"
				else
					message = "<B>[src]</B> slobbers all over [himself_or_herself(src)]."
					maptext_out = "<I>slobbers all over themselves</I>"
				m_type = 2

			if ("tantrum")
				if (!src.restrained())
					message = "<B>[src]</B> throws a tantrum!"
					maptext_out = "<I>throws a tantrum!</I>"
				else
					message = "<B>[src]</B> starts wriggling around furiously!"
					maptext_out = "<I>starts wriggling around furiously!</I>"
				m_type = 1

			if ("gesticulate")
				if (!src.restrained())
					message = "<B>[src]</B> gesticulates."
					maptext_out = "<I>gesticulates</I>"
				else
					message = "<B>[src]</B> wriggles around a lot."
					maptext_out = "<I>wriggles around a lot</I>"
				m_type = 1

			if ("wgesticulate")
				if (!src.restrained())
					message = "<B>[src]</B> gesticulates wildly."
					maptext_out = "<I>gesticulates wildly</I>"
				else
					message = "<B>[src]</B> enthusiastically wriggles around a lot!"
					maptext_out = "<I>enthusiastically wriggles around a lot!</I>"
				m_type = 1

			if ("smug")
				if (!src.restrained())
					message = "<B>[src]</B> folds [his_or_her(src)] arms and smirks broadly, making a self-satisfied \"heh\"."
					maptext_out = "<I>folds [his_or_her(src)] arms and smirks broadly</I>"
				else
					message = "<B>[src]</B> shuffles a bit and smirks broadly, emitting a rather self-satisfied noise."
					maptext_out = "<I>shuffles a bit and smirks broadly</I>"
				m_type = 1
				if (src.mind)
					src.add_karma(-2)

			if ("nosepick","picknose")
				if (!src.restrained())
					message = "<B>[src]</B> picks [his_or_her(src)] nose."
					maptext_out = "<I>picks [his_or_her(src)] nose</I>"
				else
					message = "<B>[src]</B> sniffs and scrunches [his_or_her(src)] face up irritably."
					maptext_out = "<I>sniffs and scrunches [his_or_her(src)] face up irritably</I>"
				m_type = 1
				if (src.mind)
					src.add_karma(-1)

			if ("flex","flexmuscles")
				if (!src.restrained())
					var/roboarms = src.limbs && istype(src.limbs.r_arm, /obj/item/parts/robot_parts) && istype(src.limbs.l_arm, /obj/item/parts/robot_parts)
					if (roboarms)
						message = "<B>[src]</B> flexes [his_or_her(src)] powerful robotic muscles."
						maptext_out = "<I>flexes [his_or_her(src)] powerful robotic muscles</I>"
					else
						message = "<B>[src]</B> flexes [his_or_her(src)] muscles."
						maptext_out = "<I>flexes [his_or_her(src)] muscles</I>"
					if(src.emote_check(voluntary))
						for (var/obj/item/C as anything in src.get_equipped_items())
							if ((locate(/obj/item/tool/omnitool/syndicate) in C) != null)
								var/obj/item/tool/omnitool/syndicate/O = (locate(/obj/item/tool/omnitool/syndicate) in C)
								var/drophand = (src.hand == RIGHT_HAND ? SLOT_R_HAND : SLOT_L_HAND)
								var/original_tool_loc = O.loc
								drop_item()
								O.set_loc(src)
								if(equip_if_possible(O, drophand))
									src.visible_message(SPAN_ALERT("<B>[src] pulls a set of tools out of \the [C]!</B>"))
									playsound(src.loc, "rustle", 60, 1)
								else
									O.set_loc(original_tool_loc)
									boutput(src, SPAN_ALERT("You aren't able to equip the omnitool to that hand!"))
								break
				else
					message = "<B>[src]</B> tries to stretch [his_or_her(src)] arms."
					maptext_out = "<I>tries to stretch [his_or_her(src)] arms</I>"
				m_type = 1

			if ("facepalm")
				if (!src.restrained())
					message = "<B>[src]</B> places [his_or_her(src)] hand on [his_or_her(src)] face in exasperation."
					maptext_out = "<I>places [his_or_her(src)] hand on [his_or_her(src)] face in exasperation</I>"
				else
					message = "<B>[src]</B> looks rather exasperated."
					maptext_out = "<I>looks rather exasperated</I>"
				m_type = 1

			if ("panic","freakout")
				if (!src.restrained())
					message = "<B>[src]</B> enters a state of hysterical panic!"
					maptext_out = "<I>enters a state of hysterical panic!</I>"
				else
					message = "<B>[src]</B> starts writhing around in manic terror!"
					maptext_out = "<I>starts writhing around in manic terror!</I>"
				m_type = 1

			if ("rubf", "rubface")
				if (!src.restrained())
					message = "<B>[src]</B> rubs [his_or_her(src)] face."
					maptext_out = "<I>rubs [his_or_her(src)] face</I>"
				else
					message = "<B>[src]</B> tries to move [his_or_her(src)] arm."
					maptext_out = "<I>tries to move [his_or_her(src)] arm</I>"
				m_type = 1

			if ("rubt", "rubtemples")
				if (!src.restrained())
					message = "<B>[src]</B> rubs [his_or_her(src)] temples."
					maptext_out = "<I>rubs [his_or_her(src)] temples</I>"
				else
					message = "<B>[src]</B> tries to move [his_or_her(src)] arm."
					maptext_out = "<I>tries to move [his_or_her(src)] arm</I>"
				m_type = 1

			if ("scratch", "scratchhead")
				if (!src.restrained())
					message = "<B>[src]</B> scratches [his_or_her(src)] head."
					maptext_out = "<I>scratches [his_or_her(src)] head</I>"
				else
					message = "<B>[src]</B> tries to move [his_or_her(src)] arm."
					maptext_out = "<I>tries to move [his_or_her(src)] arm</I>"
				m_type = 1

			if ("jazz", "jazzhands")
				if (!src.restrained())
					message = "<B>[src]</B> makes some jazz hands."
					maptext_out = "<I>makes some jazz hands</I>"
				else
					message = "<B>[src]</B> tries to move [his_or_her(src)] arm."
					maptext_out = "<I>tries to move [his_or_her(src)] arm</I>"
				m_type = 1

			if ("up", "thumbsup")
				if (!src.restrained())
					message = "<B>[src]</B> gives a thumbs up."
					maptext_out = "<I>gives a thumbs up</I>"
				else
					message = "<B>[src]</B> tries to move [his_or_her(src)] arm."
					maptext_out = "<I>tries to move [his_or_her(src)] arm</I>"
				m_type = 1

			if ("pose")
				if (!src.restrained())
					message = "<B>[src]</B> strikes a pose."
					maptext_out = "<I>strikes a pose</I>"
				else
					message = "<B>[src]</B> squirms."
					maptext_out = "<I>squirms</I>"
				m_type = 1

			// targeted emotes

			if ("flipoff","flipbird","middlefinger")
				m_type = 1
				if (!src.restrained())
					var/M = null
					if (param)
						for (var/mob/A in view(null, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					else
						var/list/target_list = src.get_targets(5, "mob")
						if(length(target_list))
							var/action_phrase = "emote upon"
							switch(act)
								if("flipoff")
									action_phrase = "flip off"
								if("flipbird")
									action_phrase = "give the bird"
								if("middlefinger")
									action_phrase = "raise your middle finger at"

							M = tgui_input_list(src, "Pick something to [action_phrase]!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))

					if (M) // You can totally actively passively aggressively flip people off after they leave the room
						message = "<B>[src]</B> flips off [M]."
						maptext_out = "<I>flips off [M]!</I>"
					else
						message = "<B>[src]</B> raises [his_or_her(src)] middle finger."
						maptext_out = "<I>raises [his_or_her(src)] middle finger</I>"
				else
					message = "<B>[src]</B> scowls and tries to move [his_or_her(src)] arm."
					maptext_out = "<I>scowls and tries to move [his_or_her(src)] arm</I>"

			if ("doubleflip","doubledeuce","doublebird","flip2")
				m_type = 1
				if (!src.restrained())
					var/M = null
					if (param)
						for (var/mob/A in view(null, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					else
						var/list/target_list = src.get_targets(5, "mob")
						if(length(target_list))
							var/action_phrase = "emote upon"
							switch(act)
								if("doubleflip")
									action_phrase = "blast the double-finger"
								if("doubledeuce")
									action_phrase = "give the double deuce"
								if("doublebird")
									action_phrase = "give both birds"
								if("flip2")
									action_phrase = "flip off twice"

							M = tgui_input_list(src, "Pick something to [action_phrase]!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))

					if (M)
						message = "<B>[src]</B> gives [M] the double deuce!"
						maptext_out = "<I>gives [M] the double deuce!</I>"
					else
						message = "<B>[src]</B> raises both of [his_or_her(src)] middle fingers."
						maptext_out = "<I>raises both of [his_or_her(src)] middle fingers</I>"
				else
					message = "<B>[src]</B> scowls and tries to move [his_or_her(src)] arms."
					maptext_out = "<I>scowls and tries to move [his_or_her(src)] arms.</I>"

			if ("boggle")
				m_type = 1
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (ckey(param) == ckey(A.name))
							M = A
							break
				else
					var/list/target_list = src.get_targets(5, "both") // Dr. Dingus boggles at robotics manufacturer's stupidity.
					if(length(target_list))
						M = tgui_input_list(src, "Pick something to boggle at!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))

				if (M) // You can totally boggle at something's stupidity without it being nearby
					message = "<B>[src]</B> boggles at [M]'s stupidity."
					maptext_out = "<I> boggles at [M]'s stupidity</I>"
				else
					message = "<B>[src]</B> boggles at the stupidity of it all."
					maptext_out = "<I>boggles at the stupidity of it all</I>"

			if ("eyes", "rolleyes")
				m_type = 1
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (ckey(param) == ckey(A.name))
							M = A
							break
				else
					var/list/target_list = src.get_targets(5, "mob")
					if(length(target_list))
						M = tgui_input_list(src, "Pick something to roll your eyes at!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))

				if (M)
					message = "<B>[src]</B> rolls [his_or_her(src)] eyes at [M]"
					maptext_out = "<I> rolls [his_or_her(src)] eyes at [M]</I>"
				else
					message = "<B>[src]</B> rolls [his_or_her(src)] eyes."
					maptext_out = "<I>rolls [his_or_her(src)] eyes</I>"

			if ("sideeye")
				m_type = 1
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (ckey(param) == ckey(A.name))
							M = A
							break
				else
					var/list/target_list = src.get_targets(5, "mob")
					if(length(target_list))
						M = tgui_input_list(src, "Pick something to side-eye!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))

				if (M)
					message = "<B>[src]</B> side-eyes [M]"
					maptext_out = "<I> side-eyes [M]</I>"
				else
					message = "<B>[src]</B> side-eyes nothing in particular."
					maptext_out = "<I>side-eyes nothing in particular</I>"

			if ("shakefist")
				m_type = 1
				if (!src.restrained())
					var/M = null
					if (param)
						for (var/mob/A in view(null, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					else
						var/list/target_list = src.get_targets(5, "mob") // Dr. Dingus boggles at robotics manufacturer's stupidity.
						if(length(target_list))
							M = tgui_input_list(src, "Pick something to shake your fist at!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))

					if (M)
						message = "<B>[src]</B> angrily shakes [his_or_her(src)] fist at [M]!"
						maptext_out = "<I>angrily shakes [his_or_her(src)] fist at [M]!</I>"
					else
						message = "<B>[src]</B> angrily shakes [his_or_her(src)] fist!"
						maptext_out = "<I>angrily shakes [his_or_her(src)] fist!</I>"
				else
					message = "<B>[src]</B> tries to move [his_or_her(src)] arm angrily!"
					maptext_out = "<I>tries to move [his_or_her(src)] arm angrily!</I>"

			if ("handshake","shakehand","shakehands")
				m_type = 1
				if (!src.restrained() && !src.r_hand)
					var/mob/M = null
					if (param)
						for (var/mob/A in view(1, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					if (M == src)
						M = null
					if(!M)
						var/list/target_list = src.get_targets(1, "mob") // Bobby Boblord shakes hands with grody spacemouse!
						if(length(target_list))
							M = tgui_input_list(src, "Pick someone with whom to shake hands!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))
							if (M && !in_interact_range(src, M))
								boutput(src, SPAN_EMOTE("<B>[M]</B> is out of reach!"))
								return
					if (M)
						if (can_act(M))
							if (tgui_alert(M, "[src] offers you a handshake. Do you accept it?", "Choice", list("Yes", "No")) == "Yes")
								if (M in view(1,null))
									message = "<B>[src]</B> shakes hands with [M]."
									maptext_out = "<I>shakes hands with [M].</I>"
							else
								message = "<B>[src]</B> offers [M] a handshake, but [M] declines."
								maptext_out = "<I>offers [M] a handshake, but [M] declines</I>"
						else
							message = "<B>[src]</B> holds out [his_or_her(src)] hand to [M]."
							maptext_out = "<I>holds out [his_or_her(src)] hand to [M]</I>"
					else
						message = "<B>[src]</B> randomly extends [his_or_her(src)] hand."
						maptext_out = "<I>randomly extends [his_or_her(src)] hand.</I>"


			if ("daps","dap")
				m_type = 1
				if (!src.restrained())
					var/M = null
					if (param)
						for (var/mob/A in view(1, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					else
						var/list/target_list = src.get_targets(1, "mob")
						if(length(target_list))
							M = tgui_input_list(src, "Pick someone to dap!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))
							if (M && !in_interact_range(src, M))
								boutput(src, SPAN_EMOTE("<B>[M]</B> is not in dapping distance!"))
								return

					if (M)
						message = "<B>[src]</B> gives daps to [M]."
						maptext_out = "<I>gives daps to [M]</I>"
					else
						message = "<B>[src]</B> sadly can't find anybody to give daps to, and daps [himself_or_herself(src)]. Shameful."
						maptext_out = "<I>shamefully gives daps to [himself_or_herself(src)]</I>"
				else
					message = "<B>[src]</B> wriggles around a bit."
					maptext_out = "<I>wriggles around a bit</I>"

			if ("slap","smack")
				m_type = 1
				if (!src.restrained())
					if (src.emote_check(voluntary))
						if (src.bioHolder.HasEffect("chime_snaps"))
							src.sound_snap = 'sound/impact_sounds/Glass_Shards_Hit_1.ogg'
						var/M = null
						if (param)
							for (var/mob/A in view(1, null))
								if (ckey(param) == ckey(A.name))
									M = A
									break
						else
							var/list/target_list = src.get_targets(1, "mob") // Funche Arnchlnm slaps shambling abomination across the face!
							if(length(target_list))
								M = tgui_input_list(src, "Pick someone to smack!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))
								if (M && !in_interact_range(src, M))
									boutput(src, SPAN_EMOTE("<B>[M]</B> is out of reach!"))
									return

						if (M)
							message = "<B>[src]</B> slaps [M] across the face! Ouch!"
							maptext_out = "<I>slaps [M] across the face!</I>"
						else
							message = "<B>[src]</B> slaps [himself_or_herself(src)]!"
							maptext_out = "<I>slaps [himself_or_herself(src)]!</I>"
							src.TakeDamage("head", 0, 4, 0, DAMAGE_BURN)
						playsound(src.loc, src.sound_snap, 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				else
					message = "<B>[src]</B> lurches forward strangely and aggressively!"
					maptext_out = "<I>lurches forward strangely and aggressively!</I>"

			if ("highfive")
				m_type = 1
				if (can_act(src))
					if (src.emote_check(voluntary))
						var/mob/M = null
						if (param)
							for (var/mob/A in view(1, null))
								if (ckey(param) == ckey(A.name))
									M = A
									break
#ifdef TWITCH_BOT_ALLOWED
							if (IS_TWITCH_CONTROLLED(M))
								return
#endif
						else
							var/list/target_list = src.get_targets(1, "mob") // Chrunb Erbrbt and Scales To Lizard highfive!
							if(length(target_list))
								M = tgui_input_list(src, "Pick someone to high-five!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))
								if (M && !in_interact_range(src, M))
									boutput(src, SPAN_EMOTE("<B>[M]</B> is out of reach!"))
									return

						if (M)
							if (can_act(M))
								if (tgui_alert(M, "[src] offers you a highfive! Do you accept it?", "Choice", list("Yes", "No")) == "Yes")
									if (M in view(1,null))
										message = "<B>[src]</B> and [M] highfive!"
										maptext_out = "<I>highfives [M]!</I>"
										playsound(src.loc, src.sound_snap, 100, 1, channel=VOLUME_CHANNEL_EMOTE)
								else
									message = "<B>[src]</B> offers [M] a highfive, but [M] leaves [him_or_her(src)] hanging!"
									maptext_out = "<I>tries to highfive [M] but is left hanging!</I>"
									if (M.mind)
										src.add_karma(-5)
							else
								message = "<B>[src]</B> highfives [M]!"
								maptext_out = "<I>highfives [M]!</I>"
								playsound(src.loc, src.sound_snap, 100, 1, channel=VOLUME_CHANNEL_EMOTE)
						else
							message = "<B>[src]</B> randomly raises [his_or_her(src)] hand!"
							maptext_out = "<I>randomly raises [his_or_her(src)] hand!</I>"
			// emotes that do STUFF! or are complex in some way i guess

			if ("snap","snapfingers","fingersnap","click","clickfingers")
				if (!src.restrained())
					if (src.emote_check(voluntary))
						if (src.bioHolder.HasEffect("chime_snaps"))
							src.sound_fingersnap = 'sound/musical_instruments/WeirdChime_5.ogg'
							src.sound_snap = 'sound/impact_sounds/Glass_Shards_Hit_1.ogg'
						if (prob(5) && !istype(src.gloves, /obj/item/clothing/gloves/bladed))
							message = SPAN_ALERT("<B>[src]</B> snaps [his_or_her(src)] fingers RIGHT OFF!")
							/*
							if (src.bioHolder)
								src.bioHolder.AddEffect("[src.hand ? "left" : "right"]_arm")
							else
							*/
							random_brute_damage(src, 20)
							playsound(src.loc, src.sound_snap, 100, 1, channel=VOLUME_CHANNEL_EMOTE)
						else
							message = "<B>[src]</B> snaps [his_or_her(src)] fingers."
							playsound(src.loc, src.sound_fingersnap, 50, TRUE, channel=VOLUME_CHANNEL_EMOTE)

							var/hasSwitch = FALSE
							for (var/obj/item/container as anything in src.get_equipped_items())
								if (!(locate(/obj/item/switchblade) in container))
									continue
								var/obj/item/switchblade/blade = (locate(/obj/item/switchblade) in container)
								var/drophand = (src.hand == RIGHT_HAND ? SLOT_R_HAND : SLOT_L_HAND)
								drop_item()
								blade.set_loc(get_turf(src))
								equip_if_possible(blade, drophand)
								src.visible_message("<span class='alert'><B>[src] pulls a [blade] out of \the [container]!</B></span>")
								playsound(src.loc, "rustle", 60, TRUE)
								hasSwitch = TRUE
								break

							if(!hasSwitch && !ON_COOLDOWN(src, "blade_deploy", 1 SECOND))
								if(istype(gloves, /obj/item/clothing/gloves/bladed))
									var/obj/item/clothing/gloves/bladed/blades = src.gloves
									blades.sheathe_blades_toggle(src)
									src.update_clothing()

			if ("airquote","airquotes")
				if (param)
					param = strip_html(param, 200)
					message = "<B>[src]</B> sneers, \"Ah yes, \"[param]\". We have dismissed that claim.\""
					m_type = 2
				else
					message = "<B>[src]</B> makes air quotes with [his_or_her(src)] fingers."
					maptext_out = "<I>makes air quotes with [his_or_her(src)] fingers</I>"
					m_type = 1

			if ("turnover", "examine")
				var/obj/item/thing = src.equipped()
				if (!thing)
					if (src.l_hand)
						thing = src.l_hand
					else if (src.r_hand)
						thing = src.r_hand
				if (thing)
					animate_spin(thing, prob(50) ? "L" : "R", 3, 0)
					message = "<B>[src]</B> turns [thing] over in [his_or_her(src)] hand, slowly examining it."
					maptext_out = "<I>turns [thing] over in [his_or_her(src)] hand, slowly examining it</I>"
					m_type = 1
				else
					boutput(src, SPAN_ALERT("There's nothing in your hand."))

			if ("twitch")
				message = "<B>[src]</B> twitches."
				m_type = 1
				SPAWN(0)
					var/old_x = src.pixel_x
					var/old_y = src.pixel_y
					src.pixel_x += rand(-2,2)
					src.pixel_y += rand(-1,1)
					sleep(0.2 SECONDS)
					src.pixel_x = old_x
					src.pixel_y = old_y

			if ("twitch_v","twitch_s")
				message = "<B>[src]</B> twitches violently."
				m_type = 1
				SPAWN(0)
					var/old_x = src.pixel_x
					var/old_y = src.pixel_y
					src.pixel_x += rand(-3,3)
					src.pixel_y += rand(-1,1)
					sleep(0.2 SECONDS)
					src.pixel_x = old_x
					src.pixel_y = old_y

			if ("faint")
				message = "<B>[src]</B> faints."
				src.sleeping = 1
				m_type = 1

			if ("deathgasp")
				if (!voluntary || src.emote_check(voluntary,50))
					if (prob(15) && !ischangeling(src) && !isdead(src))
						message = SPAN_REGULAR("<B>[src]</B> seizes up and falls limp, peeking out of one eye sneakily.")
					else
						if (!isdead(src))
							#ifdef COMSIG_MOB_FAKE_DEATH
							SEND_SIGNAL(src, COMSIG_MOB_FAKE_DEATH)
							#endif

						// Active if XMAS or manually toggled.
						if (deathConfettiActive)
							src.deathConfetti()

						message = SPAN_REGULAR("<B>[src]</B> seizes up and falls limp, [his_or_her(src)] eyes dead and lifeless...")
						playsound(src, "sound/voice/death_[pick(1,2)].ogg", 40, 0, 0, src.get_age_pitch())
					m_type = 1

			if ("johnny")
				if (src.emote_check(voluntary,60))
					var/M
					if (param) M = adminscrub(param)
					if (!M)
						var/list/nearby = list()
						for (var/mob/living/N in oview(4, M))
							if(N != M)
								nearby.Add(N)
						if(nearby.len)
							M = pick(nearby)
					if(M)
						message = "<B>[src]</B> says, \"[M], please. He had a family.\" [src.name] takes a drag from a cigarette and blows [his_or_her(src)] name out in smoke."
						particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(src.loc, src.dir))
						m_type = 2

			if ("point")
				if (!src.restrained())
					var/mob/M = null
					if (param)
						for (var/atom/A as mob|obj|turf|area in view(null, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break

					if (!M)
						message = "<B>[src]</B> points."
						maptext_out = "<I>points</I>"
					else
						src.point(M)

					if (M)
						message = "<B>[src]</B> points to [M]."
						maptext_out = "<I>points to [M]</I>"
				m_type = 1

			if ("signal")
				if (!src.restrained())
					var/t1 = min( max( round(text2num(param)), 1), 10)
					if (isnum(t1))
						if (t1 <= 5 && (!src.r_hand || !src.l_hand))
							message = "<B>[src]</B> raises [t1] finger\s."
							maptext_out = "<I>raises [t1] finger\s</I>"
						else if (t1 <= 10 && (!src.r_hand && !src.l_hand))
							message = "<B>[src]</B> raises [t1] finger\s."
							maptext_out = "<I>raises [t1] finger\s</I>"
				m_type = 1

			if ("wink")
				if (!src.restrained() && src.emote_check(voluntary))
					for (var/obj/item/C as anything in src.get_equipped_items())
						if ((locate(/obj/item/gun/kinetic/derringer) in C) != null)
							var/obj/item/gun/kinetic/derringer/D = (locate(/obj/item/gun/kinetic/derringer) in C)
							var/drophand = (src.hand == RIGHT_HAND ? SLOT_R_HAND : SLOT_L_HAND)
							drop_item()
							D.set_loc(src.loc)
							equip_if_possible(D, drophand)
							src.visible_message(SPAN_ALERT("<B>[src] pulls a derringer out of \the [C]!</B>"))
							playsound(src.loc, "rustle", 60, 1)
							break

				message = "<B>[src]</B> winks."
				maptext_out = "<I>winks</I>"
				m_type = 1

			if ("collapse", "trip")
				if (!src.getStatusDuration("unconscious"))
					src.changeStatus("unconscious", 3 SECONDS)
				message = "<B>[src]</B> [lowertext(act)]s!"
				m_type = 2

			if ("dance", "boogie")
				var/cooldown = 50 // I'm sorry but this is the best I can do with this janky system
				if (istype(src.shoes, /obj/item/clothing/shoes/heels/dancin))
					cooldown = 15
				if (src.emote_check(voluntary, cooldown))
					if (src.restrained()) // check this first for convenience
						message = "<B>[src]</B> twitches feebly in time to music only [he_or_she(src)] can hear."
					else
						if (iswizard(src) && prob(10))
							message = pick(SPAN_ALERT("<B>[src]</B> breaks out the most unreal dance move you've ever seen!"), SPAN_ALERT("<B>[src]'s</B> dance move borders on the goddamn diabolical!"))
							var/message_params = list(
								"maptext_css_values" = list(
									"color" = "white !important",
									"text-shadow" = "1px 1px 3px white",
									"-dm-text-outline" = "1px black",
								),
								"maptext_animation_colours" = list(
									"#FF0000",
									"#FFFF00",
									"#00FF00",
									"#00FFFF",
									"#0000FF",
									"#FF00FF",
								),
							)
							src.say("GHEIT DAUN!", message_params = message_params)
							animate_flash_color_fill(src,"#5C0E80", 1, 10)
							animate_levitate(src, 1, 10)
							SPAWN(0) // some movement to make it look cooler
								for (var/i in 0 to 9)
									src.set_dir(turn(src.dir, 90))
									sleep(0.2 SECONDS)

							elecflash(src,power = 2)
						else
							//glowsticks
							var/obj/item/device/light/glowstick/l_glowstick = src.find_type_in_hand(/obj/item/device/light/glowstick, "left")
							var/obj/item/device/light/glowstick/r_glowstick = src.find_type_in_hand(/obj/item/device/light/glowstick, "right")
							if (l_glowstick?.on || r_glowstick?.on)
								if (l_glowstick?.on)
									var/color = rgb(l_glowstick.col_r*255, l_glowstick.col_g*255, l_glowstick.col_b*255, l_glowstick.brightness*255)
									particleMaster.SpawnSystem(new /datum/particleSystem/glow_stick_dance(src.loc, color))
								if (r_glowstick?.on)
									var/color = rgb(r_glowstick.col_r*255, r_glowstick.col_g*255, r_glowstick.col_b*255, r_glowstick.brightness*255)
									particleMaster.SpawnSystem(new /datum/particleSystem/glow_stick_dance(src.loc, color))
								var/dancemove = rand(1,6)
								switch(dancemove)
									if (1)
										message = "<B>[src]</B> puts on a sick-ass lightshow!"
									if (2)
										message = "<B>[src]</B> waves a glowstick around in the air!"
									if (3)
										message = "<B>[src]</B> twirls a glowstick! Cool!"
									if (4)
										message = "<B>[src]</B> spins a glowstick! Trippy!"
									if (5)
										message = "<B>[src]</B> is the life of the party!"
									else
										message = "<B>[src]</B> is raving super hard!"
								SPAWN(0)
									for (var/i = 0, i < 4, i++)
										src.set_dir(turn(src.dir, 90))
										sleep(0.2 SECONDS)
							//standard dancing
							else
								var/dancemove = rand(1,7)

								switch(dancemove)
									if (1)
										message = "<B>[src]</B> busts out some mad moves."
										SPAWN(0)
											for (var/i = 0, i < 4, i++)
												src.set_dir(turn(src.dir, 90))
												sleep(0.2 SECONDS)

									if (2)
										message = "<B>[src]</B> does the twist, like [he_or_she(src)] did last summer."
										SPAWN(0)
											for (var/i = 0, i < 4, i++)
												src.set_dir(turn(src.dir, -90))
												sleep(0.2 SECONDS)

									if (3)
										message = "<B>[src]</B> moonwalks."
										SPAWN(0)
											for (var/i = 0, i < 4, i++)
												src.pixel_x+= 2
												sleep(0.2 SECONDS)
											for (var/i = 0, i < 4, i++)
												src.pixel_x-= 2
												sleep(0.2 SECONDS)

									if (4)
										message = "<B>[src]</B> boogies!"
										SPAWN(0)
											for (var/i = 0, i < 4, i++)
												src.pixel_x+= 2
												src.set_dir(turn(src.dir, 90))
												sleep(0.2 SECONDS)
											for (var/i = 0, i < 4, i++)
												src.pixel_x-= 2
												src.set_dir(turn(src.dir, 90))
												sleep(0.2 SECONDS)

									if (5)
										message = "<B>[src]</B> gets on down."
										SPAWN(0)
											for (var/i = 0, i < 4, i++)
												src.pixel_y-= 2
												sleep(0.2 SECONDS)
											for (var/i = 0, i < 4, i++)
												src.pixel_y+= 2
												sleep(0.2 SECONDS)

									if (6)
										message = "<B>[src]</B> dances!"
										SPAWN(0)
											for (var/i = 0, i < 4, i++)
												src.pixel_x+= 1
												src.pixel_y+= 1
												sleep(0.2 SECONDS)
											for (var/i = 0, i < 4, i++)
												src.pixel_x-= 1
												src.pixel_y-= 1
												sleep(0.2 SECONDS)

									else
										message = "<B>[src]</B> cranks out some dizzying windmills."
										SPAWN(0)
											for (var/i = 0, i < 4, i++)
												src.pixel_x+= 1
												src.pixel_y+= 1
												src.set_dir(turn(src.dir, -90))
												sleep(0.2 SECONDS)
											for (var/i = 0, i < 4, i++)
												src.pixel_x-= 1
												src.pixel_y-= 1
												src.set_dir(turn(src.dir, -90))
												sleep(0.2 SECONDS)
										// expand this too, however much

									// todo: add context-sensitive break dancing and some other goofy shit

						SPAWN(0.5 SECONDS)
							//i hate these checks - too lazy to fix for real now but lets throw on some lagchecks since we're already spawning
							LAGCHECK(LAG_MED)
							var/beeMax = 15
							for (var/obj/critter/domestic_bee/responseBee in range(7, src))
								if (!responseBee.alive)
									continue

								if (beeMax-- < 0)
									break

								responseBee.dance_response()
								src.add_karma(1)

							LAGCHECK(LAG_MED)
							var/parrotMax = 15
							for (var/obj/critter/parrot/responseParrot in range(7, src))
								if (!responseParrot.alive)
									continue
								if (parrotMax-- < 0)
									break
								responseParrot.dance_response()

							LAGCHECK(LAG_MED)
							var/crabMax = 5
							for (var/mob/living/critter/small_animal/crab/party/responseCrab in range(7, src))
								if (is_incapacitated(responseCrab))
									continue
								if (crabMax-- < 0)
									break
								responseCrab.dance_response()

						if (src.traitHolder && src.traitHolder.hasTrait("happyfeet"))
							if (prob(33))
								SPAWN(0.5 SECONDS)
									for (var/mob/living/carbon/human/responseMonkey in orange(1, src)) // they don't have to be monkeys, but it's signifying monkey code
										LAGCHECK(LAG_MED)
										if (!can_act(responseMonkey, 0))
											continue
										responseMonkey.emote("dance")

						if (src.reagents)
							if (src.reagents.has_reagent("ants") && src.reagents.has_reagent("mutagen"))
								var/ant_amt = src.reagents.get_reagent_amount("ants")
								var/mut_amt = src.reagents.get_reagent_amount("mutagen")
								src.reagents.del_reagent("ants")
								src.reagents.del_reagent("mutagen")
								src.reagents.add_reagent("spiders", ant_amt + mut_amt)
								boutput(src, SPAN_NOTICE("The ants arachnify."))
								playsound(src, 'sound/effects/bubbles.ogg', 80, TRUE)

			if ("flip")
				if (src.emote_check(voluntary, 50))

					var/stop_here = SEND_SIGNAL(src, COMSIG_MOB_FLIP, voluntary)
					if (stop_here)
						goto showmessage

					var/list/combatflipped = list()
					//TODO: space flipping
					//if ((!src.restrained()) && (!src.lying) && (istype(src.loc, /turf/space)))
					//	message = "<B>[src]</B> does a flip!"
					//	if (prob(50))
					//		animate(src, transform = turn(GetPooledMatrix(), 90), time = 1, loop = -1)
					//		animate(transform = turn(GetPooledMatrix(), 180), time = 1, loop = -1)
					//		animate(transform = turn(GetPooledMatrix(), 270), time = 1, loop = -1)
					//		animate(transform = turn(GetPooledMatrix(), 360), time = 1, loop = -1)
					//	else
					//		animate(src, transform = turn(GetPooledMatrix(), -90), time = 1, loop = -1)
					//		animate(transform = turn(GetPooledMatrix(), -180), time = 1, loop = -1)
					//		animate(transform = turn(GetPooledMatrix(), -270), time = 1, loop = -1)
					//		animate(transform = turn(GetPooledMatrix(), -360), time = 1, loop = -1)
					if (isobj(src.loc) && !is_incapacitated(src))
						var/obj/container = src.loc
						container.mob_flip_inside(src)

					if (!iswrestler(src))
						if (src.stamina <= STAMINA_FLIP_COST || (src.stamina - STAMINA_FLIP_COST) <= 0)
							boutput(src, SPAN_ALERT("You fall over, panting and wheezing."))
							message = SPAN_ALERT("<B>[src]</b> falls over, panting and wheezing.")
							src.changeStatus("knockdown", 2 SECONDS)
							src.set_stamina(min(1, src.stamina))
							src.emote_allowed = 0
							SPAWN(1 SECOND)
								src.emote_allowed = 1
							goto showmessage


					if (src.targeting_ability && istype(src.targeting_ability, /datum/targetable))
						var/datum/targetable/D = src.targeting_ability
						D.flip_callback()

					if ((!istype(src.loc, /turf/space)) && (!src.on_chair))
						if (!src.lying)
							if ((src.restrained()) || (src.reagents && src.reagents.get_reagent_amount("ethanol") > 30) || (src.bioHolder.HasEffect("clumsy")))
								message = pick("<B>[src]</B> tries to flip, but stumbles!", "<B>[src]</B> slips!")
								src.changeStatus("knockdown", 4 SECONDS)
								src.TakeDamage("head", 8, 0, 0, DAMAGE_BLUNT)
								JOB_XP(src, "Clown", 1)
							else
								message = "<B>[src]</B> does a flip!"
							if (!src.reagents.has_reagent("fliptonium"))
								animate_spin(src, prob(50) ? "L" : "R", 1, 0)
							//TACTICOOL FLOPOUT
							if (src.traitHolder.hasTrait("matrixflopout") && src.stance != "dodge")
								src.remove_stamina(STAMINA_FLIP_COST * 2)
								message = "<B>[src]</B> does a tactical flip!"
								src.stance = "dodge"
								SPAWN(0.2 SECONDS) //I'm sorry for my transgressions there's probably a way better way to do this
									if(src?.stance == "dodge")
										src.stance = "normal"

							//FLIP OVER TABLES
							if (iswrestler(src) && !istype(src.equipped(), /obj/item/grab))
								for (var/obj/table/T in oview(1, null))
									if ((src.dir == get_dir(src, T)))
										T.set_density(0)
										if (LinkBlockedWithAccess(src.loc, T.loc))
											T.set_density(1)
											continue
										T.set_density(1)
										var/turf/newloc = T.loc
										src.set_loc(newloc)
										message = "<B>[src]</B> flips onto [T]!"

							var/flipped_a_guy = FALSE
							for (var/obj/item/grab/G in src.equipped_list(check_for_magtractor = 0))
								var/mob/living/M = G.affecting
								if (M == src)
									continue
								if (!G.affecting) //Wire note: Fix for Cannot read null.loc
									continue
								if (G.affecting in combatflipped)
									continue
								if (src.a_intent == INTENT_HELP)
									M.emote("flip", 1) // make it voluntary so there's a cooldown and stuff
									continue
								flipped_a_guy = TRUE
								var/suplex_result = src.do_suplex(G)
								if(suplex_result)
									combatflipped |= G.affecting
									message = suplex_result
								if(!length(combatflipped))
									var/turf/oldloc = src.loc
									var/turf/newloc = G.affecting.loc
									var/mob/tmob = G.affecting
									var/do_flip = TRUE
									var/orig_src_flags = src.flags
									var/orig_tmob_flags = tmob.flags
									src.flags |= TABLEPASS
									tmob.flags |= TABLEPASS
									if(!istype(oldloc) || !istype(newloc))
										do_flip = FALSE
									if(do_flip && (!oldloc.Enter(tmob) || !newloc.Enter(src)))
										do_flip = FALSE
									if(do_flip && !(BOUNDS_DIST(newloc, oldloc) == 0))
										do_flip = FALSE
									if(do_flip)
										for(var/atom/movable/obstacle in oldloc)
											if(!ismob(obstacle) && !obstacle.Cross(tmob))
												do_flip = FALSE
												break
									if(do_flip)
										for(var/atom/movable/obstacle in newloc)
											if(!ismob(obstacle) && !obstacle.Cross(src))
												do_flip = FALSE
												break
									if(do_flip)
										src.set_loc(newloc)
										tmob.set_loc(oldloc)
										message = "<B>[src]</B> flips over [tmob]!"
									else
										flipped_a_guy = FALSE
									src.flags = orig_src_flags
									tmob.flags = orig_tmob_flags
							if (!flipped_a_guy)
								for (var/mob/living/M in view(1, null))
									if (M == src)
										continue
									if (M in combatflipped)
										continue
									if (src.reagents?.get_reagent_amount("ethanol") > 10 && src.can_drunk_act())
										if (!iswrestler(src) && src.traitHolder && !src.traitHolder.hasTrait("glasscannon"))
											src.remove_stamina(STAMINA_FLIP_COST)
											src.stamina_stun()
										combatflipped |= M
										message = SPAN_ALERT("<B>[src]</B> flips into [M]!")
										logTheThing(LOG_COMBAT, src, "flips into [constructTarget(M,"combat")]")
										src.changeStatus("knockdown", 6 SECONDS)
										src.TakeDamage("head", 4, 0, 0, DAMAGE_BLUNT)
										M.changeStatus("knockdown", 2 SECONDS)
										M.TakeDamage("head", 2, 0, 0, DAMAGE_BLUNT)
										playsound(src.loc, pick(sounds_punch), 100, 1)
										var/turf/newloc = M.loc
										src.set_loc(newloc)
									else if (!(src.reagents?.get_reagent_amount("ethanol") > 30))
										message = "<B>[src]</B> flips in [M]'s general direction."
									break
					if(length(combatflipped))
						actions.interrupt(src, INTERRUPT_ACT)
					src.drop_juggle()
					if (src.lying)
						message = "<B>[src]</B> flops on the floor like a fish."
						maptext_out = "<I>flops on the floor like a fish</I>"
					// If there is a chest item, see if its reagents can be dumped into the body
					if(src.chest_item != null)
						src.chest_item_dump_reagents_on_flip()

			if ("burp")
				if (src.emote_check(voluntary))
					if ((src.charges >= 1) && (!muzzled))
						for (var/mob/O in viewers(src, null))
							O.show_message("<B>[src]</B> burps.")
						for (var/mob/M in oview(1))
							elecflash(src,power = 2)
							boutput(M, SPAN_NOTICE("BZZZZZZZZZZZT!"))
							M.TakeDamage("chest", 0, 20, 0, DAMAGE_BURN)
							src.charges -= 1
							playsound(src, src.sound_burp, 70, 0, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
							return
					else if ((src.charges >= 1) && (muzzled) && !HAS_ATOM_PROPERTY(src, PROP_MOB_CANNOT_VOMIT))
						for (var/mob/O in viewers(src, null))
							O.show_message("<B>[src]</B> vomits in [his_or_her(src)] own mouth a bit.")
						src.TakeDamage("head", 0, 50, 0, DAMAGE_BURN)
						src.charges -=1
						return
					else if ((src.charges < 1) && (!muzzled))
						message = "<B>[src]</B> burps."
						m_type = 2
						if (src.getStatusDuration("food_deep_burp"))
							playsound(src, src.sound_burp, 70, 0, 0, src.get_age_pitch() * 0.5, channel=VOLUME_CHANNEL_EMOTE)
						else
							playsound(src, src.sound_burp, 70, 0, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)

						var/datum/statusEffect/fire_burp/FB = src.hasStatus("food_fireburp")
						if (!FB)
							FB = src.hasStatus("food_fireburp_big")
						if (FB)
							SPAWN(0)
								FB.cast()
					else
						message = "<B>[src]</B> vomits in [his_or_her(src)] own mouth a bit."
						m_type = 2

			if ("pee", "piss", "urinate")
				if (src.emote_check(voluntary))
					message = "<B>[src]</B> grunts for a moment. [prob(1) ? "Something" : "Nothing"] happens."
					maptext_out = "<I>grunts</I>"

			if ("poo", "poop", "shit", "crap")
				if (src.emote_check(voluntary))
					message = "<B>[src]</B> grunts for a moment. [prob(1) ? "Something" : "Nothing"] happens."
					maptext_out = "<I>grunts</I>"

			if ("monologue")
				m_type = 2
				if (src.mind && src.mind.assigned_role == "Detective")
					var/obj/item/grab/G
					if (istype(src.l_hand, /obj/item/grab))
						G = src.l_hand
					else if (istype(src.r_hand, /obj/item/grab))
						G = src.r_hand
					if (G && ishuman(G.affecting))
						var/mob/M = G.affecting
						src.say_verb("I'll stare the bastard in the face as [he_or_she(M)] screams to God, and I'll laugh harder when [he_or_she(M)] whimpers like a baby.")
						sleep(0.7 SECONDS)
						if(G && G.affecting == M)
							src.say_verb("And when [M]'s eyes go dead, the hell I send [him_or_her(M)] to will seem like heaven after what I've done to [him_or_her(M)].")
						else
							src.emote("laugh")
					else if (istype(src.loc.loc, /area/station/security/detectives_office))
						src.say_verb("As I looked out the door of my office, I realised it was a night when you didn't know your friends but strangers looked familiar.")
						sleep(1 SECONDS)
						src.say_verb("A night like this, the smartest thing to do is nothing: stay home.")
						sleep(0.5 SECONDS)
						src.say_verb("It was like the wind carried people along with it.")
						sleep(0.8 SECONDS)
						src.say_verb("But I had to get out there.")
					else if (istype(src.loc.loc, /area/station/maintenance))
						src.say_verb("The dark maintenance corridoors of this place were always the same, home to the most shady characters you could ever imagine.")
						sleep(1 SECONDS)
						src.say_verb("Walk down the right back alley in [station_name(1)], and you can find anything.")
					else if (istype(src.loc.loc, /area/station/hydroponics))
						src.say_verb("A gang of space farmers growing psilocybin mushrooms, cannabis, and of course those goddamned george melons.")
						sleep(1 SECONDS)
						src.say_verb("A shady bunch, whose wiles had earned them the trust of many.")
						sleep(0.8 SECONDS)
						src.say_verb("The Chef.")
						sleep(0.8 SECONDS)
						src.say_verb("The Bartender.")
						sleep(0.8 SECONDS)
						src.say_verb("But not me.")
						sleep(0.5 SECONDS)
						src.emote("frown")
						sleep(0.5 SECONDS)
						src.say_verb("No, their charms don't work on a [man_or_woman(src)] of values and principles.")
					else if (istype(src.loc.loc, /area/station/mailroom))
						src.say_verb("The post office, an unused room habited by a brainless monkey, a cynical postman, and now, me.")
						sleep(1 SECONDS)
						src.say_verb("I've never trusted postal workers, with their crisp blue suits and their peaked caps.")
						sleep(0.5 SECONDS)
						src.say_verb("There's never any mail sent, excepting the ticking packages I gotta defuse up in the bridge.")
					else if (istype(src.loc.loc, /area/centcom))
						src.say_verb("Central Command.")
						sleep(1 SECONDS)
						src.say_verb("I was tired as hell but I could afford to be tired now...")
						sleep(1 SECONDS)
						src.say_verb("I needed it to be morning.")
						sleep(0.7 SECONDS)
						src.say_verb("I wanted to hear doors opening, cars start, and human voices talking about the Space Olympics.")
						sleep(0.7 SECONDS)
						src.say_verb("I wanted to make sure there were still folks out there facing life with nothing up their sleeves but their arms.")
						sleep(1 SECONDS)
						src.say_verb("They didn't know it yet, but they had a better shot at happiness and a fair shake than they did yesterday.")
					else if (istype(src.loc.loc, /area/station/chapel))
						src.say_verb("The self-pontificating bastard who calls himself our chaplain conducts worship here.")
						sleep(0.5 SECONDS)
						src.say_verb("If you can call the summoning of an angry god who pelts us with toolboxes, bolts of lightning, and occasionally rips our bodies in twain 'worship'.")
					else if (istype(src.loc.loc, /area/station/bridge))
						src.say_verb("The bridge.")
						sleep(1 SECONDS)
						src.say_verb("The home of the Captain and Head of Personnel.")
						sleep(0.6 SECONDS)
						src.say_verb("I tried to tell myself I was the sturdy leg in our little triangle.")
						sleep(1 SECONDS)
						src.say_verb("I was worried it was true.")
					else if (istype(src.loc.loc, /area/station/security/main))
						src.say_verb("I had dreams of being security before I got into the detective game.")
						sleep(1 SECONDS)
						src.say_verb("I wanted to meet stimulating and interesting people of an ancient space culture, and kill them.")
						sleep(0.7 SECONDS)
						src.say_verb("I wanted to be the first kid on my ship to get a confirmed kill.")
					else if (istype(src.loc.loc, /area/station/crew_quarters/bar))
						src.say_verb("The station bar, full of the best examples of lowlifes and drunks I'll ever find.")
						sleep(0.7 SECONDS)
						src.say_verb("I need a drink though, and there are no better places to find a beer than here.")
					else if (istype(src.loc.loc, /area/station/medical))
						src.say_verb("Medical.")
						sleep(0.8 SECONDS)
						src.say_verb("In truth it's full of the biggest bunch of cut throats on the station, most would rather cut you up than sow you up, but if I've got a slug in my ass, I don't have much choice.")
					else if (istype(src.loc.loc, /area/station/hallway/primary/))
						src.say_verb("The halls of the station assault my nostrils like a week old meal left festering in the sink.")
						sleep(0.8 SECONDS)
						src.say_verb("A thug around every corner, and reason enough themselves to keep my gun in my hand.")
					else if (istype(src.loc.loc, /area/station/hallway/secondary/exit))
						src.say_verb("The only way off this hellhole and it's the one place I don't want to be, but sometimes you have to show your friends that you're worth a damn.")
						sleep(0.8 SECONDS)
						src.say_verb("Sometimes that means dying, sometimes it means killing a whole lot of people to escape alive.")
					else if (istype(src.loc.loc, /area/station/hallway/secondary/entry))
						src.say_verb("The entrance to [station_name(1)].")
						sleep(0.6 SECONDS)
						src.say_verb("You will never find a more wretched hive of scum and villainy.")
						sleep(0.7 SECONDS)
						src.say_verb("I must be cautious.")
					else if (istype(src.loc.loc, /area/station/engine/))
						src.say_verb("The churning, hellish heart of the station that just can't help missing the beat.")
						sleep(0.7 SECONDS)
						src.say_verb("Full of the dregs of society, and not the right place to be caught unwanted.")
						sleep(0.5 SECONDS)
						src.say_verb("I better watch my back.")
					else if (istype(src.loc.loc, /area/station/maintenance/disposal))
						src.say_verb("Disposal.")
						sleep(1 SECONDS)
						src.say_verb("Usually bloodied, full of grey-suited corpses and broken windows.")
						sleep(0.6 SECONDS)
						src.say_verb("Down here, you can hear the quiet moaning of the station itself.")
						sleep(1 SECONDS)
						src.say_verb("It's like it's mourning.")
						sleep(0.6 SECONDS)
						src.say_verb("Mourning better days long gone, like assistants through these pipes.")
					else if (istype(src.loc.loc, /area/station/crew_quarters/cafeteria))
						src.say_verb("A place to eat, but not an appealing one.")
						sleep(0.6 SECONDS)
						src.say_verb("I've heard rumours about this place, and if there's one thing I know, it's that it's not normal to eat people.")
					else if (istype(src.wear_mask, /obj/item/clothing/mask/cigarette))
						message = "<B>[src]</B> takes a drag on [his_or_her(src)] cigarette, surveying the scene around them carefullly."
					else
						message = "<B>[src]</B> looks uneasy, like [hes_or_shes(src)] missing a vital part of [himself_or_herself(src)]. [capitalize(he_or_she(src))] needs a smoke badly."

				else
					message = "<B>[src]</B> tries to say something clever, but just can't pull it off looking like that."

			if ("miranda")
				if (src.emote_check(voluntary, 50))
					if (src.mind && (src.mind.assigned_role in list("Captain", "Head of Personnel", "Head of Security", "Security Officer", "Security Assistant", "Detective", "Vice Officer", "Inspector")))
						src.recite_miranda()

			if ("dab") //I'm honestly not sure how I'm ever going to code anything lower than this - Readster 23/04/19
				var/mob/living/carbon/human/H = null
				if(ishuman(src))
					H = src
				var/obj/item/I = get_id_card(src.wear_id)
				if(H && (!H.limbs.l_arm || !H.limbs.r_arm || H.restrained()))
					src.show_text("You can't do that without free arms!")
				else if((src.mind && (src.mind.assigned_role in list("Clown", "Staff Assistant", "Captain"))) || istraitor(H) || isconspirator(H) || isnukeop(H) || isnukeopgunbot(H) || istype(src.head, /obj/item/clothing/head/bighat/syndicate/) || istype(I, /obj/item/card/id/dabbing_license) || (src.reagents && src.reagents.has_reagent("puredabs")) || (src.reagents && src.reagents.has_reagent("extremedabs"))) //only clowns and the useless know the true art of dabbing
					var/obj/item/card/id/dabbing_license/dab_id = null
					if(istype(I, /obj/item/card/id/dabbing_license)) // if we are using a dabbing license, save it so we can increment stats
						dab_id = I
						dab_id.dab_count++
						dab_id.tooltip_rebuild = 1
					src.add_karma(-4)
					if(!dab_id && locate(/obj/machinery/bot/secbot/beepsky) in view(7, get_turf(src)))
						var/datum/db_record/sec_record = data_core.security.find_record("name", src.name)
						if(sec_record && sec_record["criminal"] != ARREST_STATE_ARREST)
							sec_record["criminal"] = ARREST_STATE_ARREST
							sec_record["mi_crim"] = "Public dabbing."
							src.update_arrest_icon()

					if(src.reagents) src.reagents.add_reagent("dabs",5)


					if(prob(92) && (!src.reagents.has_reagent("extremedabs")))
						dabbify()
						var/get_dabbed_on = 0
						if(locate(/mob/living) in range(1, src))
							if(isturf(src.loc))
								for(var/mob/living/carbon/human/M in range(1, src)) //Is there somebody to dab on?
									if(M == src || !M.lying) //Are they on the floor and therefore fair game to get dabbed on?
										continue
									message = SPAN_ALERT("<B>[src]</B> dabs on [M]!") //Get fucking dabbed on!!!
									get_dabbed_on = 1
									if(prob(5))
										M.emote("cry") //You should be ashamed
									if(dab_id)
										dab_id.dabbed_on_count++

						if(get_dabbed_on == 0)
							if (src.mind && src.mind.assigned_role == "Clown")
								message = "<B>[src]</B> [pick("performs a sick dab", "dabs on the haters", "shows everybody [his_or_her(src)] dope dab skills", "performs a wicked dab", "dabs like nobody has dabbed before", "shows everyone how they dab in the circus")]!!!"
							else
								message = "<B>[src]</B> [pick("performs a sick dab", "dabs on the haters", "shows everybody [his_or_her(src)] dope dab skills", "performs a wicked dab", "dabs like nobody has dabbed before")]!!!"
					// Act 2: Starring Firebarrage
					else if(!src.reagents.has_reagent("puredabs"))
						message = SPAN_ALERT("<B>[src]</B> dabs [his_or_her(src)] arms <B>RIGHT OFF</B>!!!!")
						playsound(src.loc, 'sound/misc/deepfrieddabs.ogg', 25,0, channel=VOLUME_CHANNEL_EMOTE)
						shake_camera(src, 40, 8)
						if(H)
							if(H.limbs.l_arm)
								src.limbs.l_arm.sever()
								if(dab_id)
									dab_id.arm_count++
							if(H.limbs.r_arm)
								src.limbs.r_arm.sever()
								if(dab_id)
									dab_id.arm_count++
							H.emote("scream")
					if(!(istype(src.head, /obj/item/clothing/head/bighat/syndicate) || src.reagents.has_reagent("puredabs")))
						src.take_brain_damage(10)
						dab_id?.brain_damage_count += 10
						if(src.get_brain_damage() > 60)
							src.show_text(SPAN_ALERT("Your head hurts!"))
					if(locate(/obj/item/bible) in src.loc)
						if(H.limbs.l_arm)
							src.limbs.l_arm.sever()
							dab_id?.arm_count++
						if(H.limbs.r_arm)
							src.limbs.r_arm.sever()
							dab_id?.arm_count++
						src.limbs.r_leg?.sever()
						src.limbs.l_leg?.sever()
						message = SPAN_ALERT("[src] does a sick dab on the bible!")
						src.visible_message(SPAN_ALERT("An unseen force smites [src]'s' limbs off</B>!"))
						playsound(src.loc, 'sound/misc/deepfrieddabs.ogg', 25,0, channel=VOLUME_CHANNEL_EMOTE)
				else
					src.show_text("You don't know how to do that but you feel deeply ashamed for trying", "red")

			if ("woof")
				if (!ispug(src)) // not accounting for critter dogs since they have their own bark handling
					src.say("Woof.")
					return
				else
					message = "<b>[src]</b> woofs!"
					playsound(src.loc, 'sound/voice/urf.ogg', 60, channel=VOLUME_CHANNEL_EMOTE)
			else
				if (voluntary)
					src.show_text("Unusable emote '[act]'. 'Me help' for a list.", "blue")
				return

	showmessage:

	if (!message)
		return

	var/list/client/recipients = list()
	if (m_type & 1)
		for (var/mob/M as anything in viewers(src, null))
			if (!M.client)
				continue

			recipients += M.client

	else if (m_type & 2)
		for (var/mob/M in hearers(src, null))
			if (!M.client)
				continue

			recipients += M.client

	else if (!isturf(src.loc))
		var/atom/A = src.loc
		for (var/mob/M in A.contents)
			if (!M.client)
				continue

			recipients += M.client

	logTheThing(LOG_SAY, src, "EMOTE: [message]")
	act = lowertext(act)
	for (var/client/client as anything in recipients)
		client.mob.show_message(SPAN_EMOTE("[message]"), m_type, group = "[src]_[act]_[custom]")

	if (maptext_out && !ON_COOLDOWN(src, "emote maptext", 0.5 SECONDS))
		global.display_emote_maptext(src, recipients, maptext_out)

/mob/living/carbon/human/proc/expel_fart_gas(var/oxyplasmafart)
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/gas = new /datum/gas_mixture
	if(oxyplasmafart == 1)
		gas.toxins += 1
	if(oxyplasmafart == 2)
		gas.oxygen += 1
	if(src.reagents && src.reagents.get_reagent_amount("fartonium") > 6.9)
		gas.farts = 6.9
	else if(src.reagents && src.reagents.get_reagent_amount("egg") > 6.9)
		gas.farts = 2.69
	else if(src.reagents && src.reagents.get_reagent_amount("refried_beans") > 6.9)
		gas.farts = 1.69
	else
		gas.farts = 0.69
	if(src.bioHolder?.HasEffect("radioactive_farts"))
		gas.radgas = 2
	gas.temperature = T20C
	gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
	if (T)
		T.assume_air(gas)

	src.remove_stamina(STAMINA_DEFAULT_FART_COST)

/mob/living/carbon/human/proc/dabbify()
	if(ON_COOLDOWN(src, "dab", 2 SECONDS))
		return
	src.render_target = "*\ref[src]"
	var/image/left_arm = image(null, src)
	left_arm.render_source = src.render_target
	left_arm.filters += filter(type="alpha", icon=icon('icons/mob/humanmasks.dmi', "r_arm"))
	left_arm.appearance_flags = KEEP_APART | PIXEL_SCALE
	var/image/right_arm = image(null, src)
	right_arm.render_source = src.render_target
	right_arm.filters += filter(type="alpha", icon=icon('icons/mob/humanmasks.dmi', "l_arm"))
	right_arm.appearance_flags = KEEP_APART | PIXEL_SCALE
	var/image/torso = image(null, src)
	torso.render_source = src.render_target
	torso.filters += filter(type="alpha", icon=icon('icons/mob/humanmasks.dmi', "torso"))
	torso.appearance_flags = KEEP_APART | PIXEL_SCALE
	APPLY_ATOM_PROPERTY(src, PROP_MOB_CANTMOVE, "dabbify")
	src.update_canmove()
	src.set_dir(SOUTH)
	src.dir_locked = TRUE
	sleep(0.1) //so the direction setting actually takes place
	world << torso
	world << right_arm
	world << left_arm
	torso.plane = PLANE_DEFAULT
	right_arm.plane = PLANE_DEFAULT
	left_arm.plane = PLANE_DEFAULT
	/*torso.loc = get_turf(O)
	right_arm.loc = get_turf(O)
	left_arm.loc = get_turf(O)*/
	animate(left_arm, transform = turn(left_arm.transform, -110), pixel_y = 10, pixel_x = -1, 5, 1, CIRCULAR_EASING)
	animate(right_arm, transform = turn(right_arm.transform, -95), pixel_y = 1, pixel_x = 10, 5, 1, CIRCULAR_EASING)
	SPAWN(1 SECOND)
		animate(left_arm, transform = null, pixel_y = 0, pixel_x = 0, 4, 1, CIRCULAR_EASING)
		animate(right_arm, transform = null, pixel_y = 0, pixel_x = 0, 4, 1, CIRCULAR_EASING)
		sleep(0.5 SECONDS)
		qdel(torso)
		qdel(right_arm)
		qdel(left_arm)
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_CANTMOVE, "dabbify")
		src.update_canmove()
		src.dir_locked = FALSE
		src.render_target = "\ref[src]"

/mob/living/proc/do_suplex(obj/item/grab/G)
	if (!(G.state >= GRAB_STRONG && isturf(src.loc) && isturf(G.affecting.loc)))
		return null
	if(!(BOUNDS_DIST(src, G.affecting) == 0))
		return null

	var/obj/table/tabl = locate() in src.loc.contents
	var/turf/newloc = src.loc
	G.affecting.set_loc(newloc)
	if (!G.affecting.reagents?.has_reagent("fliptonium"))
		animate_spin(src, prob(50) ? "L" : "R", 1, 0)

	if (!iswrestler(src) && src.traitHolder && !src.traitHolder.hasTrait("glasscannon"))
		src.remove_stamina(STAMINA_FLIP_COST)
		src.stamina_stun()

	G.affecting.was_harmed(src)

	src.emote("scream")
	. = SPAN_ALERT("<B>[src] suplexes [G.affecting][tabl ? " into [tabl]" : null]!</B>")
	logTheThing(LOG_COMBAT, src, "suplexes [constructTarget(G.affecting,"combat")][tabl ? " into \an [tabl]" : null] [log_loc(src)]")
	G.affecting.lastattacker = src
	G.affecting.lastattackertime = world.time
	if (iswrestler(src))
		G.affecting.changeStatus("knockdown", max(G.affecting.getStatusDuration("knockdown"), 4.4 SECONDS))
		G.affecting.force_laydown_standup()
		G.affecting.TakeDamage("head", 10, 0, 0, DAMAGE_BLUNT)
		src.changeStatus("knockdown", 1.5 SECONDS)
		playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)
	else
		src.changeStatus("knockdown", 3.9 SECONDS)

		G.affecting.changeStatus("knockdown", max(G.affecting.getStatusDuration("knockdown"), 4.4 SECONDS))


		G.affecting.force_laydown_standup()
		SPAWN(0.8 SECONDS) //let us do that combo shit people like with throwing
			src.force_laydown_standup()
			qdel(G)

		G.affecting.TakeDamage("head", 9, 0, 0, DAMAGE_BLUNT)
		playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)
	if (istype(tabl, /obj/table/glass))
		var/obj/table/glass/g_tabl = tabl
		if (!g_tabl.glass_broken)
			if ((prob(g_tabl.reinforced ? 60 : 80)) || (src.bioHolder.HasEffect("clumsy") && (!g_tabl.reinforced || prob(90))))
				SPAWN(0)
					g_tabl.smash()
					src.changeStatus("knockdown", 7 SECONDS)
					random_brute_damage(src, rand(20,40))
					take_bleeding_damage(src, src, rand(20,40))
					G.affecting.changeStatus("knockdown", 4 SECONDS)
					random_brute_damage(G.affecting, rand(20,40))
					take_bleeding_damage(G.affecting, src, rand(20,40))
					G.affecting.force_laydown_standup()
					sleep(1 SECOND) //let us do that combo shit people like with throwing
					src.force_laydown_standup()

/// Looks for the kind_of_target movables within range, and throws the user an input
/// Valid kinds: "mob", "obj", "both"
/mob/living/proc/get_targets(range = 1, kind_of_target = "mob")
	if(!isturf(get_turf(src))) return

	var/list/targets = list()
	switch(kind_of_target)
		if("both")
			for(var/atom/movable/AM in view(range, get_turf(src)))
				if(AM == src)
					continue
				targets += AM
		if("mob")
			for(var/mob/M in view(range, get_turf(src)))
				if(M == src || isintangible(M) || isobserver(M))
					continue
				targets += M
		if("obj")
			for(var/obj/O in view(range, get_turf(src)))
				targets += O
	return targets
