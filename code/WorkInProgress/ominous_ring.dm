
/obj/item/clothing/gloves/ring/ominous
	name = "unnerving arc"
	desc = "Your ears start ringing when you look at it for too long."
	icon = 'icons/obj/clothing/item_wizard_rings.dmi'
	icon_state = "arc"
	var/is_emitting = FALSE
	///Odds of the ring doing something each process, 0.4% chance per cumulation; builds while equipped at 1/tick, and +3 when user is struck
	var/cumulation = 0
	///Odds that, when the ring does a thing, it will be retaliatory. 1% chance per agitation; +5 when user is struck, dissipates at 1/tick
	var/agitation = 0
	///Effects are directed at most recent agitator of the ring's current "custodian", aka the last one to beat em up
	var/mob/last_agitator = null

	examine(mob/user)
		. = ..()
		if(ishuman(user) && src.loc == user)
			. += "<br>For some reason, you feel a strange urge to slide it onto your finger."

	New()
		. = ..()
		src.name = "[pick("resonating","unnerving","peculiar","metallic")] [pick("arc","ring","band","clasp")]"

	disposing()
		is_emitting = FALSE
		if(ismob(src.loc))
			var/mob/M = src.loc
			M.bioHolder?.RemoveEffect("unnatural_vitality")
		processing_items.Remove(src)
		. = ..()

	equipped(var/mob/user, var/slot) //add an equip noise (whispers, spooky ring noise?) probably also unequip
		. = ..()
		is_emitting = TRUE
		var/datum/bioEffect/regenerator/unnatural/our_effect = user.bioHolder?.AddEffect("unnatural_vitality")
		if(our_effect)
			user.playsound_local_not_inworld('sound/effects/ring_happi.ogg', 40, 0)
			our_effect.host_ring = src
			our_effect.RegisterSignal(user, COMSIG_MOB_ATTACKED_PRE, /datum/bioEffect/regenerator/unnatural/proc/agitate)
		processing_items.Add(src)

	unequipped(var/mob/user)
		. = ..()
		is_emitting = FALSE
		user.bioHolder?.RemoveEffect("unnatural_vitality")
		processing_items.Remove(src)

	process()
		. = ..()
		var/turf/da_turf = get_turf(src)
		if(da_turf.z != Z_LEVEL_STATION || istype(da_turf,/turf/unsimulated)) //don't tick up or expend ticks while we're somewhere unusual
			return
		if (cumulation >= 16 && prob(0.4 * src.cumulation))
			cumulation = 0
			src.do_a_thing()
		else
			cumulation++
			if(agitation > 0) agitation--

	proc/zap_agitator()
		if(last_agitator)
			var/area/target_area = get_area(last_agitator)
			if(target_area.area_apc)
				target_area.area_apc.cell.charge = target_area.area_apc.cell.maxcharge
				arcFlash(target_area.area_apc, last_agitator, 500000)

	proc/do_a_thing(var/manual_call = null) //do the thing
		var/our_spot = get_turf(src)
		var/mob/our_mob = null
		var/dangertime = prob(min(src.agitation,100))

		//manual call can override behaviors. pass values 0-5 for safe rolls and 10-16 for dangerous rolls
		//0 or 10 don't specify the exact safe/unsafe behavior, no value at all uses the ring's agitation to choose
		var/roll_override
		if(manual_call)
			roll_override = manual_call % 10
			if(manual_call - roll_override > 0) dangertime = TRUE

		if(ismob(src.loc))
			our_mob = src.loc
			if(!dangertime) //foretelling
				if(!ON_COOLDOWN(our_mob,"ominous_ring_cue",2 MINUTES)) //don't notify in text TOO often
					boutput(our_mob,SPAN_NOTICE("<i>[src] [pick("sings to you.","makes a strange noise.","makes an odd chime.")]</i>"))
				var/chirpy = pick('sound/effects/magic1.ogg','sound/effects/magic2.ogg')
				our_mob.playsound_local_not_inworld(chirpy, 50, 1, pitch = 0.4)
		if(dangertime) //forewarning
			flick("arc-grump",src)
			if(!ON_COOLDOWN(src,"spookisound",30 SECONDS))
				var/weirdnoise = pick('sound/ambience/industrial/Precursor_Drone2.ogg',\
				'sound/ambience/industrial/Precursor_Choir.ogg',\
				'sound/ambience/industrial/Precursor_Drone3.ogg',\
				'sound/ambience/industrial/Precursor_Bells.ogg')

				playsound(our_spot, weirdnoise, 50, 1)
		else //other foretelling
			flick("arc-chirp",src)
		SPAWN(rand(24,48))
			//update information
			our_spot = get_turf(src)
			if(ismob(src.loc))
				our_mob = src.loc
			else
				our_mob = null

			if(dangertime) //shit's goin down
				flick("arc-grump",src)
				if(our_mob)
					boutput(our_mob,SPAN_ALERT("<b>[src] vibrates violently!</b>"))
					our_mob.playsound_local_not_inworld('sound/effects/brrp.ogg', 40, 1, pitch = 0.5)

				src.agitation = max(src.agitation - 40, 0)

				var/needs_target_roll_range = 4 //tail end of the roll range is only for effects that want a target
				if(!ismob(last_agitator)) needs_target_roll_range = 0
				var/picker = rand(1,3+needs_target_roll_range)
				if(roll_override) picker = roll_override
				switch(picker)
					if(1) //AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA STOP IT
						if(our_mob) our_mob.audible_message(SPAN_ALERT("<B>[our_mob]</B> emits a piercing [pick("dirge","shriek","screech")]!"))
						else src.audible_message(SPAN_ALERT("<B>[src]</B> emits a piercing [pick("dirge","shriek","screech")]!"))
						playsound(our_spot, 'sound/effects/screech_tone.ogg', 80, 1)
						for (var/mob/living/M in hearers(our_spot, null))
							if (our_mob && M == our_mob)
								continue
							M.apply_sonic_stun(0, 3, 0, 0, 0, 8)
						sonic_attack_environmental_effect(our_spot, 7, list("light", "window", "r_window"))
					if(2) //everyone calm down for a minute ok? have some nice tunes
						playsound(our_spot, 'sound/musical_instruments/artifact/Artifact_Precursor_1.ogg', 60, 0)
						new /obj/overlay/darkness_field(our_spot, 20 SECONDS, radius = 12)
					if(3) //safety corner for you - if there is no equipped alive mob it will do nothing, this is ok as a sometimes
						if(our_mob && isalive(our_mob))
							var/turf/safety_corner = pick_landmark(LANDMARK_MENHIR_PENANCE)
							var/turf/whisked_from = get_turf(our_mob)
							showswirl_out(whisked_from)
							showswirl(safety_corner)
							our_mob.set_loc(safety_corner)
							SPAWN(2)
								if(our_mob.client)
									our_mob.client.stop_all_sounds()
							SPAWN(rand(6,8))
								boutput(our_mob,SPAN_NOTICE("A soothing tone suffuses the room around you, for a moment."))
								///DEBUG DEBUG DEBUG this needs to clear out previous ominous noises to be soothin, it may also want to move you to a regular menhir node landmark
								if(iscarbon(our_mob))
									our_mob.reagents.add_reagent("omnizine", 4)
									our_mob.reagents.add_reagent("saline", 4)
									our_mob.changeStatus("defibbed", 6 SECONDS)
								playsound(safety_corner, 'sound/musical_instruments/artifact/Artifact_Precursor_3.ogg', 60, 0)
							SPAWN(rand(18 SECONDS,20 SECONDS))
								showswirl(our_spot)
								showswirl_out(safety_corner)
								our_mob.set_loc(our_spot)
					if(4) //timeout corner for them
						var/turf/timeout_corner = pick_landmark(LANDMARK_MENHIR_PENANCE)
						var/turf/whisked_from = get_turf(last_agitator)
						showswirl_out(whisked_from)
						showswirl(timeout_corner)
						last_agitator.set_loc(timeout_corner)
						SPAWN(rand(24 SECONDS,32 SECONDS))
							showswirl(whisked_from)
							showswirl_out(timeout_corner)
							last_agitator.set_loc(whisked_from)
					if(5) //yeet cannon (or electricity)
						if(isturf(last_agitator.loc) && GET_DIST(our_spot,last_agitator) < 13)
							var/direction = get_dir(our_spot,last_agitator)
							var/turf/target = get_edge_target_turf(last_agitator, direction)
							playsound(last_agitator.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 50, 1, -1)
							last_agitator.visible_message("<b>[last_agitator] [pick("goes flying","is suddenly flung away","is blasted away")]!</b>")
							last_agitator.throw_at(target, 15, 1, bonus_throwforce=20, throw_type=THROW_THROUGH_WALL)
						else
							src.zap_agitator()
					if(6) //always electricity
						src.zap_agitator()

					if(7) //get some shade (or electricity)
						if(ishuman(last_agitator))
							var/mob/living/carbon/human/H = last_agitator
							H.setStatus("art_light_curse_ring", rand(50 SECONDS, 80 SECONDS))
						else
							src.zap_agitator()

			else //things are fine probably, so do something nice
				var/picker = rand(1,9)
				if(roll_override) picker = roll_override
				switch(picker)
					if(1) //apc recharge but quieter this time
						var/area/target_area = get_area(our_spot)
						if(target_area.area_apc)
							var/obj/item/cell/apc_cell = target_area.area_apc.cell
							apc_cell.charge = min(apc_cell.charge + 1000, apc_cell.maxcharge)
							FLICK("apc-spark", target_area.area_apc)
							if(our_mob) boutput(our_mob,SPAN_NOTICE("You feel an odd crackling in the air."))
					if(2) //here have cool rock
						var/turf/nearby_spot = null
						for(var/D in alldirs)
							var/turf/proxturf = get_step(our_spot,D)
							if(!is_blocked_turf(proxturf))
								nearby_spot = proxturf
								break
						showswirl(nearby_spot)
						SPAWN(2)
							var/path = pick(/obj/item/raw_material/cobryl,/obj/item/raw_material/gemstone,/obj/item/raw_material/miracle)
							new path(nearby_spot)
					if(3) //maintain yr ape
						if(isalive(our_mob) && iscarbon(our_mob))
							our_mob.reagents.add_reagent("saline", 2)
							our_mob.reagents.add_reagent("salicylic_acid", 2)
							if(our_mob) boutput(our_mob,SPAN_NOTICE("You feel a flushing sensation through your body."))
					if(4 to 6) //have cube. tasty
						var/turf/nearby_spot = null
						for(var/D in alldirs)
							var/turf/proxturf = get_step(our_spot,D)
							if(!is_blocked_turf(proxturf))
								nearby_spot = proxturf
								break
						showswirl(nearby_spot)
						SPAWN(2)
							new /obj/item/reagent_containers/food/snacks/cube(nearby_spot)
					if(7) //on rare occasion, a particularly special gift for you
						if(prob(5))
							var/turf/nearby_spot = null
							for(var/D in alldirs)
								var/turf/proxturf = get_step(our_spot,D)
								if(!is_blocked_turf(proxturf))
									nearby_spot = proxturf
									break
							showswirl(nearby_spot)
							SPAWN(2)
								Artifact_Spawn(nearby_spot,"precursor")
					if(8 to 9) //all is well, probably. unless you're in hell.
						var/area/target_area = get_area(our_spot)
						if(our_mob && istype(target_area,/area/precursor/pit))
							var/turf/yonder = pick_landmark(LANDMARK_MENHIR_PENANCE)
							showswirl_out(our_spot)
							our_mob.set_loc(yonder)
							showswirl(yonder)
							SPAWN(2 SECOND)
								playsound(yonder, 'sound/musical_instruments/artifact/Artifact_Precursor_3.ogg', 60, 0)
								boutput(our_mob,SPAN_DISARM("« 86 67 96 37 78 23 97 48 23 38 28 37 96 27 48 23 48 97 87 23 96 76 87 56 87 96 08 «"))
							SPAWN(18 SECONDS)
								var/turf/andback = pick_landmark(LANDMARK_MENHIR_OUTREACH)
								showswirl_out(yonder)
								our_mob.set_loc(andback)
								showswirl(andback)


/datum/bioEffect/regenerator/unnatural
	name = "Unnatural Vitality"
	desc = "Subject's cells are resonating synchronously, which appears to be having beneficial effects on overall vitality."
	id = "unnatural_vitality"
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	stability_loss = 0
	msgGain = "A strange comfort washes over you, like every cell in your body is singing together."
	msgLose = "The chorus recedes from your body."
	heal_per_tick = 0.8
	regrow_prob = 0
	acceptable_in_mutini = 0
	var/obj/item/clothing/gloves/ring/ominous/host_ring = null

	OnRemove()
		. = ..()
		if(owner) src.UnregisterSignal(owner, COMSIG_MOB_ATTACKED_PRE)

	proc/agitate(var/our_host,var/the_agitator)
		if(the_agitator == our_host) return
		if(host_ring)
			host_ring.cumulation = min(host_ring.cumulation + 3, 250)
			if(the_agitator && istype(the_agitator,/mob))
				host_ring.agitation = min(host_ring.agitation + 6, 100)
				host_ring.last_agitator = the_agitator

/obj/item/reagent_containers/food/snacks/cube
	name = "odd cube"
	desc = "Strangely tacky to the touch, but it smells nice. Might be someone's idea of food?"
	icon = 'icons/obj/items/materials/materials.dmi'
	icon_state = "block"
	bites_left = 2
	heal_amt = 5
	food_color = "#ffcdfb"
	initial_volume = 5
	initial_reagents = list("sugar"=5)
	food_effects = list("food_refreshed_big")
	rand_pos = 0
	var/huhmessage = "Tastes vaguely sweet."

	New()
		..()
		name = "[pick("odd","weird","funky","scented","perplexing")] [pick("cube","block","brick")]"
		huhmessage = pick("Tastes like... chicken?","It's... edible chalk?","It doesn't taste as nice as it smells.","It's surprisingly palatable.",\
		"You don't know what taste you expected, but it wasn't whatever that was.","It melts in your mouth like cotton candy.")

	heal(var/mob/M)
		boutput(M, SPAN_NOTICE("[huhmessage]"))
		. = ..()
