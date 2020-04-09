
/mob/living/carbon/human
	var/life_context = "begin"
	var/arrest_count = 0 //check arrest on interval i guess

	//more accurate timers
	var/last_stam_change = 0
	var/last_reagent_process = 0
	var/last_mutantrace_process = 0
	var/last_breath_process = 0
	var/last_blood_process = 0
	var/metabolizes = 1
	//not really useful yet?,but it coudl come in handy if one part is espcially slow or  we would want to do some lagchecking which is why i am making these separate


	var/last_life_tick = 0 //and this ones just the whole lifetick
	var/const/tick_spacing = 20 //This should pretty much *always* stay at 20, for it is the one number that all do-over-time stuff should be balanced around
	var/const/cap_tick_spacing = 90 //highest timeofday allowance between ticks to try to play catchup with realtime thingo

	var/list/heartbeatOverlays = list()

/mob/living/carbon/human/New()
	..()
	//wel gosh, its important that we do this otherwisde the crew could spawn into an airless room and then immediately die
	last_stam_change = world.timeofday
	last_reagent_process = world.timeofday
	last_mutantrace_process = world.timeofday
	last_breath_process = world.timeofday
	last_blood_process = world.timeofday
	last_life_tick = world.timeofday

/mob/living/carbon/human
	proc/Thumper_createHeartbeatOverlays()
		for (var/mob/x in (src.observers + src))
			if(!heartbeatOverlays[x] && x.client)
				var/obj/screen/hb = new
				hb.icon = x.client.widescreen ? 'icons/effects/overlays/crit_thicc.png' : 'icons/effects/overlays/crit_thin.png'
				hb.screen_loc = "1,1"
				hb.layer = HUD_LAYER_UNDER_2
				hb.plane = PLANE_HUD
				hb.mouse_opacity = 0
				x.client.screen += hb
				heartbeatOverlays[x] = hb
			else if(x.client && !(heartbeatOverlays[x] in x.client.screen))
				x.client.screen += heartbeatOverlays[x]
	proc/Thumper_thump(var/animateInitial)
		Thumper_createHeartbeatOverlays()
		var/sound/thud = sound('sound/effects/thump.ogg')
#define HEARTBEAT_THUMP_APERTURE 3.5
#define HEARTBEAT_THUMP_BASE 5
#define HEARTBEAT_THUMP_INTENSITY 0.2
#define HEARTBEAT_THUMP_INTENSITY_BASE 0.1
		for(var/mob/x in src.heartbeatOverlays)
			var/obj/screen/overlay = src.heartbeatOverlays[x]
			if(x.client)
				x.client << thud
				if(animateInitial)
					animate(overlay, alpha=255, color=list( list(HEARTBEAT_THUMP_INTENSITY,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,HEARTBEAT_THUMP_APERTURE)), 10, easing=ELASTIC_EASING)
					animate(color=list( list(HEARTBEAT_THUMP_INTENSITY_BASE,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,HEARTBEAT_THUMP_BASE), list(0,0,0,0) ), 10, easing=ELASTIC_EASING, flags=ANIMATION_END_NOW)
				else
					//src << sound('sound/thump.ogg')
					overlay.color=list( list(0.16,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,2.6), list(0,0,0,0) )//, 5, 0, ELASTIC_EASING)
					animate(overlay, color=list( list(0.13,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,3.5), list(0,0,0,0) ), 13, easing = ELASTIC_EASING, flags = ANIMATION_END_NOW)


#undef HEARTBEAT_THUMP_APERTURE
#undef HEARTBEAT_THUMP_BASE
#undef HEARTBEAT_THUMP_INTENSITY
#undef HEARTBEAT_THUMP_INTENSITY_BASE
	var/doThumps = 0
	proc/Thumper_theThumpening()
		if(doThumps) return
		doThumps = 1
		Thumper_thump(1)
		SPAWN_DBG(2 SECONDS)
			while(src.doThumps)
				Thumper_thump(0)
				sleep(20)
	proc/Thumper_stopThumps()
		doThumps = 0
	proc/Thumper_paralyzed()
		Thumper_createHeartbeatOverlays()
		if(doThumps)//we're thumping dangit
			doThumps = 0
		for(var/mob/x in src.heartbeatOverlays)
			var/obj/screen/overlay = src.heartbeatOverlays[x]
			if(x.client)
				animate(overlay, alpha = 255,
					color = list( list(0,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,4) ),
					10, flags=ANIMATION_END_NOW)//adjust the 4 to adjust aperture size
	proc/Thumper_crit()
		Thumper_createHeartbeatOverlays()
		if(doThumps)
			doThumps = 0
		for(var/mob/x in src.heartbeatOverlays)
			var/obj/screen/overlay = src.heartbeatOverlays[x]
			if(x.client)
				animate(overlay,
					alpha = 255,
					color = list( list(0.1,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,0.8), list(0,0,0,0) ),
				time = 10, easing = SINE_EASING)

	proc/Thumper_restore()
		Thumper_createHeartbeatOverlays()
		doThumps = 0
		for(var/mob/x in src.heartbeatOverlays)
			var/obj/screen/overlay = src.heartbeatOverlays[x]
			if(x.client)
				animate(overlay, color = list( list(0,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,-100), list(0,0,0,0) ), alpha = 0, 20, SINE_EASING )

/mob/living/carbon/human/Life(datum/controller/process/mobs/parent)
	set invisibility = 0
	if (..(parent))
		return 1

	if (farty_party)
		src.emote("fart")

	if (src.transforming)
		return

	if (!bioHolder)
		bioHolder = new/datum/bioHolder(src)

	var/life_time_passed = max(tick_spacing, world.timeofday - last_life_tick)

	parent.setLastTask("update_item_abilities", src)
	update_item_abilities()

	parent.setLastTask("update_objectives", src)
	update_objectives()

	// Jewel's attempted fix for: null.return_air()
	// These objects should be garbage collected the next tick, so it's not too bad if it's not breathing I think? I might be totallly wrong here.
	if (loc)
		var/datum/gas_mixture/environment = loc.return_air()

		if (!isdead(src)) //still breathing

			parent.setLastTask("handle_material_triggers", src)

			if(src.no_gravity)
				src.no_gravity = 0
				animate(src, transform = matrix(), time = 1)

			for (var/obj/item/I in src)
				if (I.no_gravity) src.no_gravity = 1
				if (!I.material) continue
				I.material.triggerOnLife(src, I)

			if(src.no_gravity)
				animate_levitate(src, -1, 10, 1)

			//Chemicals in the body
			parent.setLastTask("handle_chemicals_in_body", src)
			handle_chemicals_in_body()

			//Mutations and radiation
			parent.setLastTask("handle_mutations_and_radiation", src)
			handle_mutations_and_radiation()

			//Attaching a limb that didn't originally belong to you can do stuff
			if(prob(2) && src.limbs)
				if(src.limbs.l_arm && istype(src.limbs.l_arm, /obj/item/parts/human_parts/arm/))
					var/obj/item/parts/human_parts/arm/A = src.limbs.l_arm
					if(A.original_holder && src != A.original_holder)
						A.foreign_limb_effect()
				if(src.limbs.r_arm && istype(src.limbs.r_arm, /obj/item/parts/human_parts/arm/))
					var/obj/item/parts/human_parts/arm/B = src.limbs.r_arm
					if(B.original_holder && src != B.original_holder)
						B.foreign_limb_effect()
				if(src.limbs.l_leg && istype(src.limbs.l_leg, /obj/item/parts/human_parts/leg/))
					var/obj/item/parts/human_parts/leg/C = src.limbs.l_leg
					if(C.original_holder && src != C.original_holder)
						C.foreign_limb_effect()
				if(src.limbs.r_leg && istype(src.limbs.r_leg, /obj/item/parts/human_parts/leg/))
					var/obj/item/parts/human_parts/leg/D = src.limbs.r_leg
					if(D.original_holder && src != D.original_holder)
						D.foreign_limb_effect()

			parent.setLastTask("breath checks", src)
			//special (read: stupid) manual breathing stuff. weird numbers are so that messages don't pop up at the same time as manual blinking ones every time
			if (manualbreathing)
				breathtimer++
				switch(breathtimer)
					if (0 to 15)
						breathe()
					if (34)
						boutput(src, "<span style=\"color:red\">You need to breathe!</span>")
					if (35 to 51)
						if (prob(5)) emote("gasp")
					if (52)
						boutput(src, "<span style=\"color:red\">Your lungs start to hurt. You really need to breathe!</span>")
					if (53 to 61)
						hud.update_oxy_indicator(1)
						take_oxygen_deprivation(breathtimer/12)
					if (62)
						hud.update_oxy_indicator(1)
						boutput(src, "<span style=\"color:red\">Your lungs are burning and the need to take a breath is almost unbearable!</span>")
						take_oxygen_deprivation(10)
					if (63 to INFINITY)
						hud.update_oxy_indicator(1)
						take_oxygen_deprivation(breathtimer/6)
			else // plain old automatic breathing
				breathe()

			if (istype(loc, /obj/))
				parent.setLastTask("handle_internal_lifeform", src)
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

		else if (isdead(src))
			parent.setLastTask("handle_decomposition", src)
			handle_decomposition()

		//Apparently, the person who wrote this code designed it so that
		//blinded get reset each cycle and then get activated later in the
		//code. Very ugly. I dont care. Moving this stuff here so its easy
		//to find it.
		src.blinded = null

		parent.setLastTask("handle_mutantrace_life", src)



		if (src.mutantrace)
			var/mutant_time_passed = max(tick_spacing, world.timeofday - last_mutantrace_process)
			src.mutantrace.onLife(mult = (mutant_time_passed / tick_spacing))
		last_mutantrace_process = world.timeofday

		//Disease Check
		parent.setLastTask("handle_virus_updates", src)
		handle_virus_updates()

		//Handle temperature/pressure differences between body and environment
		parent.setLastTask("handle_environment", src)
		handle_environment(environment)

		//stuff in the stomach
		parent.setLastTask("handle_stomach", src)
		handle_stomach()

		//Disabilities
		parent.setLastTask("handle_disabilities", src)
		handle_disabilities(mult = (life_time_passed / tick_spacing))

	handle_burning()
	// handle_digestion((life_time_passed / tick_spacing))
	handle_skinstuff((life_time_passed / tick_spacing))
	//Status updates, death etc.
	clamp_values()
	parent.setLastTask("handle_regular_status_updates", src)
	handle_regular_status_updates(parent,mult = (life_time_passed / tick_spacing))

	parent.setLastTask("handle_stuns_lying", src)
	handle_stuns_lying(parent)

	if (!isdead(src)) // Marq was here, breaking everything.

		var/blood_time_passed = min(max(tick_spacing, world.timeofday - last_blood_process), cap_tick_spacing)

		parent.setLastTask("handle_blood", src)
		handle_blood(mult = (blood_time_passed / tick_spacing))

		parent.setLastTask("handle_blood_pressure", src)
		handle_blood_pressure(mult = (blood_time_passed / tick_spacing))

		last_blood_process = world.timeofday

		//Gonna use blood time for organs, why not?
		parent.setLastTask("handle_organs", src)
		handle_organs(mult = (life_time_passed / tick_spacing))

		parent.setLastTask("sims", src)
		if (src.sims && src.ckey) // ckey will be null if it's an npc, so they're skipped
			sims.Life()

		if (prob(1) && prob(5))
			parent.setLastTask("handle_random_emotes", src)
			handle_random_emotes()

	parent.setLastTask("handle pathogens", src)
	handle_pathogens()

	if (client)
		parent.setLastTask("handle_regular_hud_updates", src)
		handle_regular_hud_updates()
		parent.setLastTask("handle_regular_sight_updates", src)
		handle_regular_sight_updates()
		parent.setLastTask("handle_blindness_overlays", src)
		handle_blindness_overlays()

	//Being buckled to a chair or bed
	parent.setLastTask("check_if_buckled", src)
	check_if_buckled()

	// Yup.
	parent.setLastTask("update_canmove", src)
	update_canmove()

	clamp_values()

	if (arrestIcon) // Update security hud icon

		//TODO : move this code somewhere else that updates from an event trigger instead of constantly
		var/arrestState = ""
		var/visibleName = name
		if (wear_id)
			visibleName = wear_id.registered_owner()

		for (var/security_record in data_core.security)
			var/datum/data/record/R = security_record
			if ((R.fields["name"] == visibleName) && ((R.fields["criminal"] == "*Arrest*") || R.fields["criminal"] == "Parolled" || R.fields["criminal"] == "Incarcerated" || R.fields["criminal"] == "Released"))
				arrestState = R.fields["criminal"] // Found a record of some kind
				break

		if (arrestState != "*Arrest*") // Contraband overrides non-arrest statuses, now check for contraband

			if (locate(/obj/item/implant/antirev) in src.implant)
				if (ticker.mode && ticker.mode.type == /datum/game_mode/revolution)
					var/datum/game_mode/revolution/R = ticker.mode
					if (src.mind && src.mind.special_role == "head_rev")
						arrestState = "RevHead"
					else if (src.mind in R.revolutionaries)
						arrestState = "Loyal_Progress"
					else
						arrestState = "Loyal"
				else
					arrestState = "Loyal"

			else
				var/obj/item/card/id/myID = 0
				//mbc : its faster to check if the item in either hand has a registered owner than doing istype on equipped()
				//this does mean that if an ID has no registered owner + carry permit enabled it will blink off as contraband. however i dont care!
				if (l_hand && l_hand.registered_owner())
					myID = l_hand
				else if (r_hand && r_hand.registered_owner())
					myID = r_hand

				if (!myID)
					myID = wear_id
				if (myID && (access_carrypermit in myID.access))
					myID = null
				else
					var/contrabandLevel = 0
					if (l_hand)
						contrabandLevel += l_hand.contraband
					if (!contrabandLevel && r_hand)
						contrabandLevel += r_hand.contraband
					if (!contrabandLevel && belt)
						contrabandLevel += belt.contraband
					if (!contrabandLevel && wear_suit)
						contrabandLevel += wear_suit.contraband

					if (contrabandLevel > 0)
						arrestState = "Contraband"

		if (arrestIcon.icon_state != arrestState)
			arrestIcon.icon_state = arrestState

	// Update Prodoc overlay heart
	if (health_mon)
		// Originally the isdead() check was only done in the other check if <0, which meant
		// if you were dead but had > 0 HP (e.g. eaten by blob) you would still show
		// a not-dead heart. So, now you don't.
		if ((src.bioHolder && src.bioHolder.HasEffect("dead_scan")) || isdead(src))
			health_mon.icon_state = "-1"
		else
			// Handle possible division by zero
			var/health_prc = (health / (max_health != 0 ? max_health : 1)) * 100
			switch (health_prc)
				// There's 5 "regular" health states (ignoring 100% and < 0)
				// but the health icons were set up as if there were 4
				// (25, 50, 75, 100) / (20, 40, 60, 80, 100)
				// The "75" state was only used for 75-80!
				// Spread these out to make it more represenative
				if (98 to INFINITY) //100
					health_mon.icon_state = "100"
				if (80 to 98) //80
					health_mon.icon_state = "80"
				if (60 to 80) //75
					health_mon.icon_state = "75"
				if (40 to 60) //50
					health_mon.icon_state = "50"
				if (20 to 40) //25
					health_mon.icon_state = "25"
				if ( 0 to 20) //10
					health_mon.icon_state = "10"
				if (-INFINITY to 0) //0
					health_mon.icon_state = "0"
	if (health_implant)
		if (locate(/obj/item/implant/health) in src.implant)
			health_implant.icon_state = "implant"
		else
			health_implant.icon_state = null

	//Regular Trait updates
	if(src.traitHolder)
		for(var/T in src.traitHolder.traits)
			var/obj/trait/O = getTraitById(T)
			O.onLife(src)

	// Icons
	parent.setLastTask("update_icons", src)
	update_icons_if_needed()

	if (src.client) //ov1
		// overlays
		parent.setLastTask("update_screen_overlays", src)
		src.updateOverlaysClient(src.client)
		src.antagonist_overlay_refresh(0, 0)

	if (src.observers.len)
		for (var/mob/x in src.observers)
			if (x.client)
				src.updateOverlaysClient(x.client)

	for (var/obj/item/grab/G in src.equipped_list(check_for_magtractor = 0))
		parent.setLastTask("obj/item/grab.process() for [G]")
		G.process((life_time_passed / tick_spacing))

	if (!can_act(M=src,include_cuffs=0)) actions.interrupt(src, INTERRUPT_STUNNED)


	//rev mutiny

	if (src.mind && ticker.mode && ticker.mode.type == /datum/game_mode/revolution)
		var/datum/game_mode/revolution/R = ticker.mode

		if ((src.mind in R.revolutionaries) || (src.mind in R.head_revolutionaries))
			var/found = 0
			for (var/datum/mind/M in R.head_revolutionaries)
				if (M.current && ishuman(M.current))
					if (get_dist(src,M.current) <= 5)
						for (var/obj/item/revolutionary_sign/RS in M.current.equipped_list(check_for_magtractor = 0))
							found = 1
							break
			if (found)
				src.changeStatus("revspirit", 20 SECONDS)



	if (src.abilityHolder)
		//MBC : update countdowns on topbar screen abilities
		if (src.hud.current_ability_set == 1)
			if (istype(src.abilityHolder,/datum/abilityHolder/composite))
				var/datum/abilityHolder/composite/composite = src.abilityHolder
				for (var/datum/abilityHolder/H in composite.holders)
					for(var/datum/targetable/B in H.abilities)
						if (B.display_available())
							var/obj/screen/ability/topBar/button = B.object
							if (istype(B))
								button.update_on_hud(button.last_x, button.last_y)
			else
				for(var/datum/targetable/B in src.abilityHolder.abilities)
					if (B.display_available())
						var/obj/screen/ability/topBar/button = B.object
						if (istype(B))
							button.update_on_hud(button.last_x, button.last_y)


		src.abilityHolder.onLife((life_time_passed / tick_spacing))

		//move this to changeling onlife pls
		//Dumb changeling inactivity stuff
		//Allow hivemind members to Boot themselves if the changeling is inactive
		if (!src.client || (src.client && src.client.inactivity > 1800)) //3 minute inactivity check
			var/datum/abilityHolder/changeling/C = get_ability_holder(/datum/abilityHolder/changeling)
			if (C)
				if(!(C.master && C.owner != C.master)) //make sure the master is the one who is in control of the body
					for (var/mob/dead/target_observer/hivemind_observer/O in C.hivemind)
						if (!O.can_exit_hivemind)
							O.can_exit_hivemind = 1
							O.verbs += /mob/dead/target_observer/hivemind_observer/verb/exit_hivemind
							boutput(O, __blue("<b>Your master seems to be inactive. You are permitted to use the Exit-Hivemind command.</b>"))

#if ASS_JAM //Oh neat apparently this has to do with cool maptext for your health, very neat. plz comment cool things like this so I know what all is on assjam!
	src.UpdateDamage()
#endif

	last_life_tick = world.timeofday


/mob/living/carbon/human
	proc/clamp_values()
		sleeping = max(min(sleeping, 20), 0)
		stuttering = max(stuttering, 0)
		losebreath = max(min(losebreath,25),0) // stop going up into the thousands, goddamn
//		bleeding = max(min(bleeding, 10),0)
//		blood_volume = max(blood_volume, 0)

	proc/handle_burning()
		if (src.getStatusDuration("burning"))

			if (src.getStatusDuration("burning") > 200)
				for(var/atom in src.contents)
					var/atom/A = atom
					if (A.event_handler_flags & HANDLE_STICKER)
						if (A:active)
							src.visible_message("<span style=\"color:red\"><b>[A]</b> is burnt to a crisp and destroyed!</span>")
							qdel(A)

			if (isturf(src.loc))
				var/turf/location = src.loc
				location.hotspot_expose(T0C + 300, 400)

			for (var/atom/A in src.contents)
				if (A.material)
					A.material.triggerTemp(A, T0C + 900)

			if(src.traitHolder && src.traitHolder.hasTrait("burning"))
				if(prob(50))
					src.update_burning(1)


	proc/icky_icky_miasma(var/turf/T)
		var/max_produce_miasma = decomp_stage * 20
		if (T.active_airborne_liquid && prob(90)) //sometimes just add anyway lol
			var/obj/fluid/F = T.active_airborne_liquid
			if (F.group && F.group.reagents && F.group.reagents.total_volume > max_produce_miasma)
				max_produce_miasma = 0

		if (max_produce_miasma)
			T.fluid_react_single("miasma", 10, airborne = 1)

	proc/handle_decomposition()
		var/suspend_rot = 0
		if (src.decomp_stage >= 4)
			suspend_rot = (istype(loc, /obj/machinery/atmospherics/unary/cryo_cell) || istype(loc, /obj/morgue) || (src.reagents && src.reagents.has_reagent("formaldehyde")))
			if (!suspend_rot)
				icky_icky_miasma(get_turf(src))
			return

		if (!isdead(src) || src.mutantrace)
			return
		var/turf/T = get_turf(src)
		if (!T)
			return
		suspend_rot = (istype(loc, /obj/machinery/atmospherics/unary/cryo_cell) || istype(loc, /obj/morgue) || (src.reagents && src.reagents.has_reagent("formaldehyde")))
		var/env_temp = 0
		// cogwerks note: both the cryo cell and morgue things technically work, but the corpse rots instantly when removed
		// if it has been in there longer than the next decomp time that was initiated before the corpses went in. fuck!
		// will work out a fix for that soon, too tired right now

		// hello I fixed the thing by making it so that next_decomp_time is added to even if src is in a morgue/cryo or they have formaldehyde in them - haine
		if (!suspend_rot)
			var/datum/gas_mixture/environment = T.return_air()
			env_temp = environment.temperature
			src.next_decomp_time -= min(30, max(round((env_temp - T20C)/10), -60))

			icky_icky_miasma(T)

		if (world.time > src.next_decomp_time) // advances every 4-10 game minutes
			src.next_decomp_time = world.time + rand(240,600)*10
			if (suspend_rot)
				return
			src.decomp_stage = min(src.decomp_stage + 1, 4)
			src.update_body()
			src.update_face()

	proc/stink()
		if (prob(15))
			for (var/mob/living/carbon/C in view(6,get_turf(src)))
				if (C == src || !C.client)
					continue
				boutput(C, "<span style=\"color:red\">[stinkString()]</span>")
				if (prob(30))
					C.vomit()
					C.changeStatus("stunned", 2 SECONDS)
					boutput(C, "<span style=\"color:red\">[stinkString()]</span>")

	proc/handle_disabilities(var/mult = 1)

		// moved drowsy, confusion and such from handle_chemicals because it seems better here
		if (src.drowsyness)
			src.drowsyness--
			src.change_eye_blurry(2)
			if (prob(5))
				src.sleeping = 1
				src.changeStatus("paralysis", 5 SECONDS)

		if (misstep_chance > 0)
			switch(misstep_chance)
				if (50 to INFINITY)
					change_misstep_chance(-2 * mult)
				else
					change_misstep_chance(-1 * mult)

		// The value at which this stuff is capped at can be found in mob.dm
		if (src.hasStatus("resting"))
			dizziness = max(0, dizziness - 5)
			jitteriness = max(0, jitteriness - 5)
		else
			dizziness = max(0, dizziness - 2)
			jitteriness = max(0, jitteriness - 2)

		if (!isnull(src.mind) && (isvampire(src) || iswelder(src)))
			if (istype(get_area(src), /area/station/chapel) && src.check_vampire_power(3) != 1)
				if (prob(33))
					boutput(src, "<span style=\"color:red\">The holy ground burns you!</span>")
				src.TakeDamage("chest", 0, 5 * mult, 0, DAMAGE_BURN)
			if (src.loc && istype(src.loc, /turf/space))
				if (prob(33))
					boutput(src, "<span style=\"color:red\">The starlight burns you!</span>")
				src.TakeDamage("chest", 0, 2 * mult, 0, DAMAGE_BURN)

		if (src.loc && isarea(src.loc.loc))
			var/area/A = src.loc.loc
			if (A.irradiated)
				if (src.wear_suit && src.get_rad_protection())
					if (istype(wear_suit, /obj/item/clothing/suit/rad) && prob(33))
						boutput(src, "<span style=\"color:red\">Your geiger counter ticks...</span>")
					return
				else
					src.changeStatus("radiation", (A.irradiated * 10) SECONDS)

		if (src.bioHolder)
			var/total_stability = src.bioHolder.genetic_stability

			if (src.reagents && src.reagents.has_reagent("mutadone"))
				total_stability += 60

			if (total_stability <= 40 && prob(5))
				src.bioHolder.DegradeRandomEffect()

			if (total_stability <= 20 && prob(10))
				src.bioHolder.DegradeRandomEffect()

	proc/update_objectives()
		if (!src.mind)
			return
		if (!src.mind.objectives)
			return
		if (!istype(src.mind.objectives, /list))
			return
		for (var/datum/objective/O in src.mind.objectives)
			if (istype(O, /datum/objective/specialist/stealth))
				var/turf/T = get_turf_loc(src)
				if (T && isturf(T) && (istype(T, /turf/space) || T.loc.name == "Space" || T.loc.name == "Ocean" || T.z != 1))
					O:score = max(0, O:score - 1)
					if (prob(20))
						boutput(src, "<span style=\"color:red\"><B>Being away from the station is making you lose your composure...</B></span>")
					src << sound('sound/effects/env_damage.ogg')
					continue
				if (T && isturf(T) && T.RL_GetBrightness() < 0.2)
					O:score++
				else
					var/spotted_by_mob = 0
					for (var/mob/living/M in oviewers(src, 5))
						if (M.client && M.sight_check(1))
							O:score = max(0, O:score - 5)
							spotted_by_mob = 1
							break
					if (!spotted_by_mob)
						O:score++

	proc/handle_pathogens()
		if (isdead(src))
			if (src.pathogens.len)
				for (var/uid in src.pathogens)
					var/datum/pathogen/P = src.pathogens[uid]
					P.disease_act_dead()
					if (prob(5))
						src.cured(P)
			return
		for (var/uid in src.pathogens)
			var/datum/pathogen/P = src.pathogens[uid]
			P.disease_act()

	proc/handle_mutations_and_radiation()
		if (bioHolder) bioHolder.OnLife()

		if (src.bomberman == 1)
			SPAWN_DBG(1 SECOND)
				new /obj/bomberman(get_turf(src))

	proc/breathe()
		if (!loc)
			return

		var/atom/underwater = 0
		if (isturf(src.loc))
			var/turf/T = src.loc
			if (istype(T, /turf/space/fluid))
				underwater = T
			else if (T.active_liquid)
				var/obj/fluid/F = T.active_liquid

				var/depth_to_breathe_from = depth_levels.len
				if (src.lying)
					depth_to_breathe_from = depth_levels.len-1

				if (F.amt >= depth_levels[depth_to_breathe_from])
					underwater = F
					if (src.is_submerged != 4)
						src.show_submerged_image(4)

			else if (T.active_airborne_liquid)
				if (!(src.wear_mask && (src.wear_mask.c_flags & BLOCKSMOKE || (src.wear_mask.c_flags & MASKINTERNALS && src.internal))))
					//underwater = T.active_airborne_liquid
					var/obj/fluid/F = T.active_airborne_liquid
					F.force_mob_to_ingest(src)
				else
					if (!src.clothing_protects_from_chems())
						var/obj/fluid/airborne/F = T.active_airborne_liquid
						F.just_do_the_apply_thing(src, hasmask = 1)

		if (src.reagents)
			if (src.reagents.has_reagent("lexorin")) return
		if (istype(loc, /mob/living/object)) return // no breathing inside possessed objects
		if (istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) return
		//if (istype(loc, /obj/machinery/clonepod)) return

		var/breath_time_passed = min(max(tick_spacing, world.timeofday - last_breath_process), cap_tick_spacing)
																								//cutoff at max (dont wanna dael a shitton of breath dmaage all at once even in extreme lag)
		// Changelings generally can't take OXY/LOSEBREATH damage...except when they do.
		// And because they're excluded from the breathing procs, said damage didn't heal
		// on its own, making them essentially mute and perpetually gasping for air.
		// Didn't seem like a feature to me (Convair880).
		// If you have the breathless effect, same deal - you'd never heal oxy damage
		// If your mutant race doesn't need oxygen from breathing, ya no losebreath
		// so, now you do
		if (src.is_changeling() || (src.bioHolder && src.bioHolder.HasEffect("breathless") || (src.mutantrace && !src.mutantrace.needs_oxy)))
			if (src.losebreath)
				src.losebreath = 0
			if (src.get_oxygen_deprivation())
				src.take_oxygen_deprivation(-50 * (breath_time_passed / tick_spacing))
			return

		if (underwater)
			if (src.mutantrace && src.mutantrace.aquatic)
				return
			if (prob(25) && losebreath > 0)
				boutput(src, "<span style=\"color:red\">You are drowning!</span>")

		var/datum/gas_mixture/environment = loc.return_air()
		var/datum/air_group/breath = null
		// HACK NEED CHANGING LATER
		//if (src.oxymax == 0 || (breathtimer > 15))
		if (breathtimer > 15)
			src.losebreath += (0.7 * (breath_time_passed / tick_spacing))

		if (src.grabbed_by && src.grabbed_by.len)
			breath = get_breath_grabbed_by(BREATH_VOLUME)

		if (!breath)
			if (losebreath>0) //Suffocating so do not take a breath
				src.losebreath -= (1.3 * (breath_time_passed / tick_spacing))
				src.losebreath = max(src.losebreath,0)
				if (prob(75)) //High chance of gasping for air
					if (underwater)
						emote("gurgle")
					else emote("gasp")
				if (isobj(loc))
					var/obj/location_as_object = loc
					location_as_object.handle_internal_lifeform(src, 0)
				if (src.losebreath <= 0)
					boutput(src, "<span style='color:blue'>You catch your breath.</span>")
			else
				//First, check for air from internal atmosphere (using an air tank and mask generally)
				breath = get_breath_from_internal(BREATH_VOLUME)

				//No breath from internal atmosphere so get breath from location
				if (!breath)
					if (isobj(loc))
						var/obj/location_as_object = loc
						breath = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME)
					else if (isturf(loc))
						var/breath_moles = (environment.total_moles()*BREATH_PERCENTAGE)

						breath = loc.remove_air(breath_moles)

				else //Still give containing object the chance to interact
					underwater = 0 // internals override underwater state
					if (isobj(loc))
						var/obj/location_as_object = loc
						location_as_object.handle_internal_lifeform(src, 0)

		handle_breath(breath, underwater, mult = (breath_time_passed / tick_spacing))

		if (breath)
			loc.assume_air(breath)

		last_breath_process = world.timeofday

	proc/get_breath_grabbed_by(volume_needed)
		.= null
		for(var/obj/item/grab/force_mask/G in src.grabbed_by)
			.= G.get_breath(volume_needed)
			if (.)
				break

	proc/get_breath_from_internal(volume_needed)
		if (internal)
			if (!contents.Find(src.internal))
				internal = null
			if (!wear_mask || !(wear_mask.c_flags & MASKINTERNALS) )
				internal = null
			if (internal)
				if (src.internals)
					src.internals.icon_state = "internal1"
				for (var/obj/ability_button/tank_valve_toggle/T in internal.ability_buttons)
					T.icon_state = "airon"
				return internal.remove_air_volume(volume_needed)
			else
				if (src.internals)
					src.internals.icon_state = "internal0"

		return null

	proc/update_canmove()
		if (hasStatus("paralysis") || hasStatus("stunned") || hasStatus("weakened") || hasStatus("pinned"))
			canmove = 0
			return

		var/datum/abilityHolder/changeling/C = get_ability_holder(/datum/abilityHolder/changeling)
		if (C && C.in_fakedeath)
			canmove = 0
			return

		if (buckled && buckled.anchored)
			canmove = 0
			return

		if (throwing & (THROW_CHAIRFLIP | THROW_GUNIMPACT))
			canmove = 0
			return

		if (emote_lock)
			canmove = 0
			return

		//cant move while we pin someone down
		for (var/obj/item/grab/G in src.equipped_list(check_for_magtractor = 0))
			if (G.state == GRAB_PIN)
				canmove = 0
				return

		canmove = 1

	proc/handle_breath(datum/gas_mixture/breath, var/atom/underwater = 0, var/mult = 1) //'underwater' really applies for any reagent that gets deep enough. but what ever
		if (src.nodamage) return
		var/area/A = get_area(src)
		if( A && A.sanctuary )
			return
		// Looks like we're in space
		// or with recent atmos changes, in a room that's had a hole in it for any amount of time, so now we check src.loc
		if (underwater || !breath || (breath.total_moles() == 0))
			if (istype(src.loc, /turf/space))
				take_oxygen_deprivation(6 * mult)
			else
				take_oxygen_deprivation(3 * mult)
			hud.update_oxy_indicator(1)

			//consume some reagents if we drowning
			if (underwater && (src.oxyloss > 40 || underwater.type == /obj/fluid/airborne))
				if (istype(underwater,/obj/fluid))
					var/obj/fluid/F = underwater
					F.force_mob_to_ingest(src)// * mult
				else if (istype(underwater, /turf/space/fluid))
					var/turf/space/fluid/F = underwater
					F.force_mob_to_ingest(src)// * mult


			return 0

		if (src.health < 0 || (src.organHolder && src.organHolder.get_working_lung_amt() == 0)) //We aren't breathing.
			return 0

		var/has_cyberlungs = (src.organHolder && (organHolder.left_lung && organHolder.right_lung) && (src.organHolder.left_lung.robotic && src.organHolder.right_lung.robotic)) //gotta prevent null pointers...
		var/safe_oxygen_min = 17 // Minimum safe partial pressure of O2, in kPa
		//var/safe_oxygen_max = 140 // Maximum safe partial pressure of O2, in kPa (Not used for now)
		var/safe_co2_max = 9 // Yes it's an arbitrary value who cares?
		var/safe_toxins_max = 0.4
		var/SA_para_min = 1
		var/SA_sleep_min = 5
		var/oxygen_used = 0
		var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME
		var/fart_smell_min = 0.69 // don't ask ~warc
		var/fart_vomit_min = 6.9
		var/fart_choke_min = 16.9

		//Partial pressure of the O2 in our breath
		var/O2_pp = (breath.oxygen/breath.total_moles())*breath_pressure
		// Same, but for the toxins
		var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure
		// And CO2, lets say a PP of more than 10 will be bad (It's a little less really, but eh, being passed out all round aint no fun)
		var/CO2_pp = (breath.carbon_dioxide/breath.total_moles())*breath_pressure


		//change safe gas levels for cyberlungs
		if (has_cyberlungs)
			safe_oxygen_min = 9
			safe_co2_max = 18
			safe_toxins_max = 5		//making it a lot higher than regular, because even doubling the regular value is pitifully low. This is still reasonably low, but it might be noticable

		if (O2_pp < safe_oxygen_min) 			// Too little oxygen
			if (prob(20))
				if (underwater)
					emote("gurgle")
				else
					emote("gasp")
			if (O2_pp > 0)
				var/ratio = round(safe_oxygen_min/(O2_pp + 0.1))
				take_oxygen_deprivation(min(5*ratio, 5)) // Don't fuck them up too fast (space only does 7 after all!)
				oxygen_used = breath.oxygen*ratio/6
			else
				take_oxygen_deprivation(3 * mult)
			hud.update_oxy_indicator(1)
		else 									// We're in safe limits
			//if (breath.oxygen/breath.total_moles() >= 0.95) //high oxygen concentration. lets slightly heal oxy damage because it feels right
			//	take_oxygen_deprivation(-6 * mult)

			take_oxygen_deprivation(-6 * mult)
			oxygen_used = breath.oxygen/6
			hud.update_oxy_indicator(0)

		breath.oxygen -= oxygen_used
		breath.carbon_dioxide += oxygen_used

		if (CO2_pp > safe_co2_max)
			if (!co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
				co2overloadtime = world.time
			else if (world.time - co2overloadtime > 120)
				src.changeStatus("paralysis", (4 * mult) SECONDS)
				take_oxygen_deprivation(1.8 * mult) // Lets hurt em a little, let them know we mean business
				if (world.time - co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
					take_oxygen_deprivation(7 * mult)
			if (prob(20)) // Lets give them some chance to know somethings not right though I guess.
				emote("cough")

		else
			co2overloadtime = 0

		if (Toxins_pp > safe_toxins_max) // Too much toxins
			var/ratio = breath.toxins/safe_toxins_max
			take_toxin_damage(min(ratio * 125,20) * mult)
			hud.update_tox_indicator(1)
		else
			hud.update_tox_indicator(0)

		if (breath.trace_gases && breath.trace_gases.len)	// If there's some other shit in the air lets deal with it here.
			for (var/datum/gas/sleeping_agent/SA in breath.trace_gases)
				var/SA_pp = (SA.moles/breath.total_moles())*breath_pressure
				if (SA_pp > SA_para_min) // Enough to make us paralysed for a bit
					src.changeStatus("paralysis", 5 SECONDS)
					if (SA_pp > SA_sleep_min) // Enough to make us sleep as well
						src.sleeping = max(src.sleeping, 2)
				else if (SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
					if (prob(20))
						emote(pick("giggle", "laugh"))

			for (var/datum/gas/farts/FARD in breath.trace_gases) // FARDING AND SHIDDING TIME ~warc
				var/FARD_pp = (FARD.moles/breath.total_moles())*breath_pressure
				if (prob(15) && (FARD_pp > fart_smell_min))
					boutput(src, "<span style=\"color:red\">Smells like someone [pick("died","soiled themselves","let one rip","made a bad fart","peeled a dozen eggs")] in here!</span>")
					if ((FARD_pp > fart_vomit_min) && prob(50))
						src.visible_message("<span style=\"color:blue\">[src] vomits from the [pick("stink","stench","awful odor")]!!</span>")
						src.vomit()
				if (FARD_pp > fart_choke_min)
					take_oxygen_deprivation(6.9 * mult)
					if (prob(20))
						src.emote("cough")
						if (prob(30))
							boutput(src, "<span style=\"color:red\">Oh god it's so bad you could choke to death in here!</span>")


			//cyber lungs beat radiation. Is there anything they can't do?
			if (!has_cyberlungs)
				for (var/datum/gas/rad_particles/RV in breath.trace_gases)
					src.changeStatus("radiation", RV.moles, 2 SECONDS)

		if (breath.temperature > (T0C+66) && !src.is_heat_resistant()) // Hot air hurts :(
			if (!has_cyberlungs || (has_cyberlungs && (breath.temperature > (T0C+500))))
				var/burn_damage = min((breath.temperature - (T0C+66)) / 3,10) + 6
				TakeDamage("chest", 0, burn_damage, 0, DAMAGE_BURN)
				if (prob(20))
					boutput(src, "<span style=\"color:red\">You feel a searing heat in your lungs!</span>")
					if (src.organHolder)
						src.organHolder.damage_organs(0, max(burn_damage, 3), 0, list("left_lung", "right_lung"), 80)

				hud.update_fire_indicator(1)
				if (prob(4))
					boutput(src, "<span style=\"color:red\">Your lungs hurt like hell! This can't be good!</span>")
					//src.contract_disease(new/datum/ailment/disability/cough, 1, 0) // cogwerks ailment project - lung damage from fire

		else
			hud.update_fire_indicator(0)


		//Temporary fixes to the alerts.

		return 1

	proc/handle_environment(datum/gas_mixture/environment) //TODO : REALTIME BODY TEMP CHANGES (Mbc is too lazy to look at this mess right now)
		if (!environment)
			return
		var/environment_heat_capacity = environment.heat_capacity()
		var/loc_temp = T0C
		if (istype(loc, /turf/space))
			var/turf/space/S = loc
			environment_heat_capacity = S.heat_capacity
			loc_temp = S.temperature
		else if (istype(src.loc, /obj/machinery/vehicle))
			var/obj/machinery/vehicle/ship = src.loc
			if (ship.life_support)
				if (ship.life_support.active)
					loc_temp = ship.life_support.tempreg
				else
					loc_temp = environment.temperature
		// why am i repeating this shit?
		else if (istype(src.loc, /obj/vehicle))
			var/obj/vehicle/V = src.loc
			if (V.sealed_cabin)
				loc_temp = T20C // hardcoded honkytonk nonsense
		else if (istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
			var/obj/machinery/atmospherics/unary/cryo_cell/C = loc
			loc_temp = C.air_contents.temperature
		else if (istype(loc, /obj/machinery/colosseum_putt))
			loc_temp = T20C
		else
			loc_temp = environment.temperature

		var/thermal_protection
		if (stat < 2)
			src.bodytemperature = adjustBodyTemp(src.bodytemperature,src.base_body_temp,1,src.thermoregulation_mult)
		if (loc_temp < src.base_body_temp) // a cold place -> add in cold protection
			if (src.is_cold_resistant())
				return
			thermal_protection = get_cold_protection()
		else // a hot place -> add in heat protection
			if (src.is_heat_resistant())
				return
			thermal_protection = get_heat_protection()
		var/thermal_divisor = (100 - thermal_protection) * 0.01
		src.bodytemperature = adjustBodyTemp(src.bodytemperature,loc_temp,thermal_divisor,src.innate_temp_resistance)

		if (istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
			return

		// lets give them a fair bit of leeway so they don't just start dying
		//as that may be realistic but it's no fun
		if ((src.bodytemperature > src.base_body_temp + (src.temp_tolerance * 1.7) && environment.temperature > src.base_body_temp + (src.temp_tolerance * 1.7)) || (src.bodytemperature < src.base_body_temp - (src.temp_tolerance * 1.7) && environment.temperature < src.base_body_temp - (src.temp_tolerance * 1.7)))

			//Yep this means that the damage is no longer per limb. Restore this to per limb eventually. See above.
			handle_temperature_damage(LEGS, environment.temperature, environment_heat_capacity*thermal_divisor)
			handle_temperature_damage(TORSO,environment.temperature, environment_heat_capacity*thermal_divisor)
			handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*thermal_divisor)
			handle_temperature_damage(ARMS, environment.temperature, environment_heat_capacity*thermal_divisor)

			for (var/atom/A in src.contents)
				if (A.material)
					A.material.triggerTemp(A, environment.temperature)

		// decoupled this from environmental temp - this should be more for hypothermia/heatstroke stuff
		//if (src.bodytemperature > src.base_body_temp || src.bodytemperature < src.base_body_temp)

		//Account for massive pressure differences
		return //TODO: DEFERRED

	proc/get_cold_protection()
		// calculate 0-100% insulation from cold environments
		if (!src)
			return 0

		// Sealed space suit? If so, consider it to be full protection
		if (src.protected_from_space())
			return 100

		var/thermal_protection = 10 // base value

		// Resistance from Bio Effects
		if (src.bioHolder)
			if (src.bioHolder.HasEffect("fat"))
				thermal_protection += 10
			if (src.bioHolder.HasEffect("dwarf"))
				thermal_protection += 10

		// Resistance from Clothing
		for(var/atom in src.get_equipped_items())
			var/obj/item/C = atom
			thermal_protection += C.getProperty("coldprot")

		/*
		// Resistance from covered body parts
		// Commented out - made certain covering items (winter coats) basically spaceworthy all on their own, and made tooltips inaccurate
		// Besides, the protected_from_space check above covers wearing a full spacesuit.
		if (w_uniform && (w_uniform.body_parts_covered & TORSO))
			thermal_protection += 10

		if (wear_suit)
			if (wear_suit.body_parts_covered & TORSO)
				thermal_protection += 10
			if (wear_suit.body_parts_covered & LEGS)
				thermal_protection += 10
			if (wear_suit.body_parts_covered & ARMS)
				thermal_protection += 10
		*/

		thermal_protection = max(0,min(thermal_protection,100))
		return thermal_protection

	proc/get_disease_protection(var/ailment_path=null, var/ailment_name=null)
		if (!src)
			return 100

		var/resist_prob = 0

		if (ispath(ailment_path) || istext(ailment_name))
			var/datum/ailment/A = null
			if (ailment_name)
				A = get_disease_from_name(ailment_name)
			else
				A = get_disease_from_path(ailment_path)

			if (!istype(A,/datum/ailment/))
				return 100

			if (istype(A,/datum/ailment/disease/))
				var/datum/ailment/disease/D = A
				if (D.spread == "Airborne")
					if (src.wear_mask)
						if (src.internal)
							resist_prob += 100
				else if (D.spread == "Sight")
					if (src.eyes_protected_from_light())
						resist_prob += 190

		for(var/atom in src.get_equipped_items())
			var/obj/item/C = atom
			resist_prob += C.getProperty("viralprot")

		if(src.getStatusDuration("food_disease_resist"))
			resist_prob += 80

		resist_prob = CLAMP(resist_prob,0,100)
		return resist_prob

	proc/get_rad_protection()
		// calculate 0-100% insulation from rads
		if (!src)
			return 0

		var/rad_protection = 0

		// Resistance from Clothing
		for(var/atom in src.get_equipped_items())
			var/obj/item/C = atom
			rad_protection += C.getProperty("radprot")

		if (bioHolder && bioHolder.HasEffect("food_rad_resist"))
			rad_protection += 100

		rad_protection = max(0,min(rad_protection,100))
		return rad_protection

	get_ranged_protection()
		if (!src)
			return 0

		var/protection = 1

		// Resistance from Clothing
		for(var/atom in src.get_equipped_items())
			var/obj/item/C = atom
			if(C.hasProperty("rangedprot"))
				var/curr = C.getProperty("rangedprot")
				protection += curr

		return protection

	get_melee_protection(zone)
		if (!src)
			return 0
		var/protection = 0
		var/a_zone = zone
		if (a_zone in list("l_leg", "r_arm", "l_leg", "r_leg"))
			a_zone = "chest"
		if(a_zone=="All")
			protection=(5*get_melee_protection("chest")+get_melee_protection("head"))/6
		else
			// Resistance from Clothing
			for(var/atom in src.get_equipped_items())
				var/obj/item/C = atom
				if(C.hasProperty("meleeprot")&&(C==src.l_hand||C==src.r_hand||(a_zone=="head" && (istype(C, /obj/item/clothing/head)||istype(C, /obj/item/clothing/mask)||\
				istype(C, /obj/item/clothing/glasses)||istype(C, /obj/item/clothing/ears))||\
					a_zone=="chest"&&!(istype(C, /obj/item/clothing/head)||istype(C, /obj/item/clothing/mask)||\
					istype(C, /obj/item/clothing/glasses)||istype(C, /obj/item/clothing/ears)))))//why the fuck god there has to be a better way
					var/curr = C.getProperty("meleeprot")
					protection = max(curr, protection)
		return protection

	proc/get_deflection()
		if (!src)
			return 0

		var/protection = 0

		// Resistance from Clothing
		for(var/atom in src.get_equipped_items())
			var/obj/item/C = atom
			if(C.hasProperty("disarmblock"))
				var/curr = C.getProperty("disarmblock")
				protection += curr

		return min(protection, 90-STAMINA_BLOCK_CHANCE)


	proc/get_heat_protection()
		// calculate 0-100% insulation from cold environments
		if (!src)
			return 0

		var/thermal_protection = 10 // base value

		// Resistance from Bio Effects
		if (src.bioHolder)
			if (src.bioHolder.HasEffect("dwarf"))
				thermal_protection += 10

		// Resistance from Clothing
		for(var/atom in src.get_equipped_items())
			var/obj/item/C = atom
			thermal_protection += C.getProperty("heatprot")

		/*
		// Resistance from covered body parts
		// See get_cold_protection for comment out reasoning
		if (w_uniform && (w_uniform.body_parts_covered & TORSO))
			thermal_protection += 10

		if (wear_suit)
			if (wear_suit.body_parts_covered & TORSO)
				thermal_protection += 10
			if (wear_suit.body_parts_covered & LEGS)
				thermal_protection += 10
			if (wear_suit.body_parts_covered & ARMS)
				thermal_protection += 10
		*/

		thermal_protection = max(0,min(thermal_protection,100))
		return thermal_protection

	proc/add_fire_protection(var/temp)
		var/fire_prot = 0
		if (head)
			if (head.protective_temperature > temp)
				fire_prot += (head.protective_temperature/10)
		if (wear_mask)
			if (wear_mask.protective_temperature > temp)
				fire_prot += (wear_mask.protective_temperature/10)
		if (glasses)
			if (glasses.protective_temperature > temp)
				fire_prot += (glasses.protective_temperature/10)
		if (ears)
			if (ears.protective_temperature > temp)
				fire_prot += (ears.protective_temperature/10)
		if (wear_suit)
			if (wear_suit.protective_temperature > temp)
				fire_prot += (wear_suit.protective_temperature/10)
		if (w_uniform)
			if (w_uniform.protective_temperature > temp)
				fire_prot += (w_uniform.protective_temperature/10)
		if (gloves)
			if (gloves.protective_temperature > temp)
				fire_prot += (gloves.protective_temperature/10)
		if (shoes)
			if (shoes.protective_temperature > temp)
				fire_prot += (shoes.protective_temperature/10)

		return fire_prot

	proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
		if (exposed_temperature > src.base_body_temp && src.is_heat_resistant())
			return
		if (exposed_temperature < src.base_body_temp && src.is_cold_resistant())
			return
		var/discomfort = min(abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1)

		switch(body_part)
			if (HEAD)
				TakeDamage("head", 0, 2.5*discomfort, 0, DAMAGE_BURN)
			if (TORSO)
				TakeDamage("chest", 0, 2.5*discomfort, 0, DAMAGE_BURN)
			if (LEGS)
				TakeDamage("l_leg", 0, 0.6*discomfort, 0, DAMAGE_BURN)
				TakeDamage("r_leg", 0, 0.6*discomfort, 0, DAMAGE_BURN)
			if (ARMS)
				TakeDamage("l_arm", 0, 0.4*discomfort, 0, DAMAGE_BURN)
				TakeDamage("r_arm", 0, 0.4*discomfort, 0, DAMAGE_BURN)

	proc/handle_chemicals_in_body()
		if (src.nodamage) return

		if (reagents)

			var/reagent_time_passed = min(max(tick_spacing, world.timeofday - last_reagent_process), cap_tick_spacing)

			//temp_reagents does some weird "approach body temp" shit... we should jjust call it multiple times so i dont have to rework all the math
			for(var/x = 0, x < (reagent_time_passed), x+=tick_spacing)
				reagents.temperature_reagents(src.bodytemperature-30, 100)

			if (blood_system && reagents.get_reagent("blood"))
				var/blood2absorb = min(src.blood_absorption_rate, src.reagents.get_reagent_amount("blood")) * (reagent_time_passed / tick_spacing)
				reagents.remove_reagent("blood", blood2absorb)
				src.blood_volume += blood2absorb
			if (metabolizes)
				reagents.metabolize(src, multiplier = (reagent_time_passed / tick_spacing))

		src.last_reagent_process = world.timeofday


		if (src.nutrition > src.blood_volume)
			src.nutrition = src.blood_volume
		if (src.nutrition < 0)
			src.contract_disease(/datum/ailment/malady/hypoglycemia, null, null, 1)

		src.updatehealth()

		return //TODO: DEFERRED

	proc/handle_blood_pressure(var/mult = 1)
		if (!blood_system)
			return
		src.ensure_bp_list()
		// very low (90/60 or lower) (<375u)
		// low (100/65) (<415u)
		// normal (120/80) (500u)
		// high (stage 1) (140/90 or higher) (>585u)
		// very high (stage 2) (160/100 or higher) (>666u)
		// dangerously high (urgency) (180/110 or higher) (>750u)
		if (isvampire(src))
			src.blood_pressure["systolic"] = 120
			src.blood_pressure["diastolic"] = 80
			src.blood_pressure["rendered"] = "[rand(115,125)]/[rand(78,82)]"
			src.blood_pressure["total"] = 500
			src.blood_pressure["status"] = "Normal"
			return

		var/current_blood_amt = src.blood_volume + (src.reagents ? src.reagents.total_volume / 4 : 0) // dropping how much reagents count so that people stop going hypertensive at the drop of a hat
		var/anticoag_amt = (src.reagents ? src.reagents.get_reagent_amount("heparin") : 0)
		var/coag_amt = (src.reagents ? src.reagents.get_reagent_amount("proconvertin") : 0)
		var/cho_amt = (src.reagents ? src.reagents.get_reagent_amount("cholesterol") : 0)
		if (anticoag_amt)
			current_blood_amt -= ((anticoag_amt / 4) + anticoag_amt) * mult// set the total back to what it would be without the heparin, then remove the total of the heparin
		if (coag_amt)
			current_blood_amt -= (coag_amt / 4) * mult // set the blood total to what it would be without the proconvertin in it
			current_blood_amt += coag_amt * mult// then add the actual total of the proconvertin back so it counts for 4x what the other chems do
		if (cho_amt)
			current_blood_amt -= (cho_amt / 4) * mult // same as proconvertin above
			current_blood_amt += cho_amt * mult
		current_blood_amt = round(current_blood_amt, 1)

		var/current_systolic = round((current_blood_amt * 0.24), 1)
		var/current_diastolic = round((current_blood_amt * 0.16), 1)
		src.blood_pressure["systolic"] = current_systolic
		src.blood_pressure["diastolic"] = current_diastolic
		src.blood_pressure["rendered"] = "[max(rand(current_systolic-5,current_systolic+5), 0)]/[max(rand(current_diastolic-2,current_diastolic+2), 0)]"
		src.blood_pressure["total"] = current_blood_amt
		src.blood_pressure["status"] = (current_blood_amt < 415) ? "HYPOTENSIVE" : (current_blood_amt > 584) ? "HYPERTENSIVE" : "NORMAL"

		if (src.is_changeling())
			return

		//special case
		if (current_blood_amt >= 1500)
			if (prob(10))
				src.visible_message("<span style='color:red'><b>[src] bursts like a bloody balloon! Holy fucking shit!!</b></span>")
				src.gib(1) // :v
				return

		if (isdead(src))
			return

		switch (current_blood_amt)
			if (-INFINITY to 0) // welp
				src.take_oxygen_deprivation(1 * mult)
				src.take_brain_damage(2 * mult)
				src.losebreath += (1 * mult)
				src.drowsyness = max(src.drowsyness, rand(3,4))
				if (prob(10))
					src.change_misstep_chance(rand(3,4) * mult)
				if (prob(10))
					src.emote(pick("faint", "collapse", "pale", "shudder", "shiver", "gasp", "moan"))
				if (prob(18))
					var/extreme = pick("", "really ", "very ", "extremely ", "terribly ", "insanely ")
					var/feeling = pick("[extreme]ill", "[extreme]sick", "[extreme]numb", "[extreme]cold", "[extreme]dizzy", "[extreme]out of it", "[extreme]confused", "[extreme]off-balance", "[extreme]terrible", "[extreme]awful", "like death", "like you're dying", "[extreme]tingly", "like you're going to pass out", "[extreme]faint")
					boutput(src, "<span style='color:red'><b>You feel [feeling]!</b></span>")
					src.changeStatus("weakened", (4 * mult) SECONDS)
				src.contract_disease(/datum/ailment/malady/shock, null, null, 1) // if you have no blood you're gunna be in shock
				src.add_stam_mod_regen("hypotension", -3)
				src.add_stam_mod_max("hypotension", -15)

			if (1 to 374) // very low (90/60)
				src.take_oxygen_deprivation(0.8 * mult)
				src.take_brain_damage(0.8 * mult)
				src.losebreath += (0.8 * mult)
				src.drowsyness = max(src.drowsyness, rand(1,2))
				if (prob(6))
					src.change_misstep_chance(rand(1,2) * mult)
				if (prob(8))
					src.emote(pick("faint", "collapse", "pale", "shudder", "shiver", "gasp", "moan"))
				if (prob(14))
					var/extreme = pick("", "really ", "very ", "extremely ", "terribly ", "insanely ")
					var/feeling = pick("[extreme]ill", "[extreme]sick", "[extreme]numb", "[extreme]cold", "[extreme]dizzy", "[extreme]out of it", "[extreme]confused", "[extreme]off-balance", "[extreme]terrible", "[extreme]awful", "like death", "like you're dying", "[extreme]tingly", "like you're going to pass out", "[extreme]faint")
					boutput(src, "<span style='color:red'><b>You feel [feeling]!</b></span>")
					src.changeStatus("weakened", (3 * mult) SECONDS)
				if (prob(25))
					src.contract_disease(/datum/ailment/malady/shock, null, null, 1)
				src.add_stam_mod_regen("hypotension", -2)
				src.add_stam_mod_max("hypotension", -10)

			if (375 to 414) // low (100/65)
				if (prob(2))
					src.emote(pick("pale", "shudder", "shiver"))
				if (prob(5))
					var/extreme = pick("", "kinda ", "a little ", "sorta ", "a bit ")
					var/feeling = pick("ill", "sick", "numb", "cold", "dizzy", "out of it", "confused", "off-balance", "tingly", "faint")
					boutput(src, "<span style='color:red'><b>You feel [extreme][feeling]!</b></span>")
				if (prob(5))
					src.contract_disease(/datum/ailment/malady/shock, null, null, 1)
				src.add_stam_mod_regen("hypotension", -1)
				src.add_stam_mod_max("hypotension", -5)

			if (415 to 584) // normal (120/80)
				src.remove_stam_mod_regen("hypertension")
				src.remove_stam_mod_regen("hypotension")
				src.remove_stam_mod_max("hypertension")
				src.remove_stam_mod_max("hypotension")
				return

			if (585 to 665) // high (140/90)
				if (prob(2))
					var/msg = pick("You feel kinda sweaty",\
					"You can feel your heart beat loudly in your chest",\
					"Your head hurts")
					boutput(src, "<span style='color:red'>[msg].</span>")
				if (prob(1))
					src.losebreath += (1 * mult)
				if (prob(1))
					src.emote("gasp")
				if (prob(1) && prob(10))
					src.contract_disease(/datum/ailment/malady/heartdisease,null,null,1)
				src.add_stam_mod_regen("hypertension", -1)
				src.add_stam_mod_max("hypertension", -5)

			if (666 to 749) // very high (160/100)
				if (prob(2))
					var/msg = pick("You feel sweaty",\
					"Your heart beats rapidly",\
					"Your head hurts badly",\
					"Your chest hurts")
					boutput(src, "<span style='color:red'>[msg].</span>")
				if (prob(3))
					src.losebreath += (1 * mult)
				if (prob(2))
					src.emote("gasp")
				if (prob(1))
					src.contract_disease(/datum/ailment/malady/heartdisease,null,null,1)
				src.add_stam_mod_regen("hypertension", -2)
				src.add_stam_mod_max("hypertension", -10)

			if (750 to INFINITY) // critically high (180/110)
				if (prob(5))
					var/msg = pick("You feel really sweaty",\
					"Your heart pounds in your chest",\
					"Your head pounds with pain",\
					"Your chest hurts badly",\
					"It's hard to breathe")
					boutput(src, "<span style='color:red'>[msg]!</span>")
				if (prob(5))
					src.losebreath += (1 * mult)
				if (prob(2))
					src.take_eye_damage(1)
				if (prob(3))
					src.emote("gasp")
				if (prob(5))
					src.contract_disease(/datum/ailment/malady/heartdisease,null,null,1)
				if (prob(2))
					src.visible_message("<span style='color:red'>[src] coughs up a little blood!</span>")
					playsound(get_turf(src), "sound/impact_sounds/Slimy_Splat_1.ogg", 30, 1)
					bleed(src, rand(1,2) * mult, 1)
				src.add_stam_mod_regen("hypertension", -3)
				src.add_stam_mod_max("hypertension", -15)


	proc/handle_blood(var/mult = 1) // hopefully this won't cause too much lag?
		if (!blood_system) // I dunno if this'll do what I want but hopefully it will
			return

		if (isdead(src) || src.nodamage || !src.can_bleed || isvampire(src)) // if we're dead or immortal or have otherwise been told not to bleed, don't bother
			if (src.bleeding)
				src.bleeding = 0 // also stop bleeding if we happen to be doing that
			return

		//This is now handled by the on_life in the spleen organ in the organHolder
		// if (src.blood_volume < 500 && src.blood_volume > 0) // if we're full or empty, don't bother v
		// 	if (prob(66))
		// 		src.blood_volume += 1 * mult // maybe get a little blood back ^
		// else if (src.blood_volume > 500) // just in case there's no reagent holder
		// 	if (prob(20))
		// 		src.blood_volume -= 1 * mult

		if (src.bleeding)
			var/decrease_chance = 2 // defaults to 2 because blood does clot and all, but we want bleeding to maybe not stop entirely on its own TOO easily, and there's only so much clotting can do when all your blood is falling out at once
			if (src.bleeding > 1 && src.bleeding < 4) // higher bleeding gets a better chance to drop down
			//if (src.bleeding >= 4 && src.bleeding <= 7) // higher bleeding gets a better chance to drop down
				decrease_chance += 3
			if (src.reagents)
				if (src.reagents.has_reagent("heparin")) // anticoagulant
					decrease_chance -= rand(1,2)
				if (src.reagents.has_reagent("proconvertin")) // coagulant
					decrease_chance += rand(2,4)
			if (src.get_surgery_status())
				decrease_chance -= 1
			if (prob(decrease_chance))
				src.bleeding -= 1 * mult
				boutput(src, "<span style='color:blue'>Your wounds feel [pick("better", "like they're healing a bit", "a little better", "itchy", "less tender", "less painful", "like they're closing", "like they're closing up a bit", "like they're closing up a little")].</span>")

			if (src.bleeding < 0) //INVERSE BLOOD LOSS was a fun but ultimately easily fixed bug
				src.bleeding = 0

		else if (!src.bleeding && src.get_surgery_status())
			src.bleeding += 1 * mult

		if (src.bleeding && src.blood_volume)

			var/final_bleed = CLAMP(src.bleeding, 0, 5) // trying this at 5 being the max
			//var/final_bleed = CLAMP(src.bleeding, 0, 10) // still don't want this above 10

			if (src.reagents)
				var/anticoag_amt = src.reagents.has_reagent("heparin") // anticoagulant
				final_bleed += round(CLAMP((anticoag_amt / 10), 0, 2), 1)

			if (prob(max(0, min(final_bleed, 10)) * 5)) // up to 50% chance to make a big bloodsplatter
				bleed(src, final_bleed, 5)

			else
				switch (src.bleeding)
					if (1)
						bleed(src, final_bleed, 1) // this proc creates a bloodsplatter on src's tile
					if (2)
						bleed(src, final_bleed, 2) // it takes care of removing blood, and transferring reagents, color and ling status to the blood
					if (3 to 4)
						bleed(src, final_bleed, 3) // see blood_system.dm for the proc
					if (5)
						bleed(src, final_bleed, 4)

	proc/handle_organs(var/mult = 1) // is this even where this should go???  ??????  haine gud codr
		if (src.ignore_organs)
			return

		if (!src.organHolder)
			src.organHolder = new(src)
			sleep(10)

		var/datum/organHolder/oH = src.organHolder
		if (!oH.head && !src.nodamage)
			src.death()

		// time to find out why this wasn't added - cirr
		oH.handle_organs(mult)


		if (!oH.skull && !src.nodamage) // look okay it's close enough to an organ and there's no other place for it right now shut up
			if (oH.head)
				src.death()
				src.visible_message("<span style=\"color:red\"><b>[src]</b>'s head collapses into a useless pile of skin mush with no skull to keep it in its proper shape!</span>",\
				"<span style=\"color:red\">Your head collapses into a useless pile of skin mush with no skull to keep it in its proper shape!</span>")

		//Wire note: Fix for Cannot read null.loc
		if (oH.skull && oH.skull.loc != src)
			oH.skull = null

		if (!oH.brain && !src.nodamage)
			src.death()
		else if (oH.brain && oH.brain.loc != src)
			oH.brain = null

		if (!oH.heart && !src.nodamage)
			if (!src.is_changeling())
				if (src.get_oxygen_deprivation())
					src.take_brain_damage(3)
				else if (prob(10))
					src.take_brain_damage(1)

				src.changeStatus("weakened", 5 SECONDS)
				src.losebreath += 20
				src.take_oxygen_deprivation(20)
				src.updatehealth()
		else
			if (oH.heart.loc != src)
				oH.heart = null
			else if (oH.heart.robotic && oH.heart.emagged && !oH.heart.broken)
				src.drowsyness = max (src.drowsyness - 8, 0)
				if (src.sleeping) src.sleeping = 0
			else if (oH.heart.robotic && !oH.heart.broken)
				src.drowsyness = max (src.drowsyness - 4, 0)
				if (src.sleeping) src.sleeping = 0
			else if (oH.heart.broken)
				if (src.get_oxygen_deprivation())
					src.take_brain_damage(3)
				else if (prob(10))
					src.take_brain_damage(1)

				changeStatus("weakened", 2 SECONDS)
				src.losebreath += 20
				src.take_oxygen_deprivation(20)
				src.updatehealth()
			else if (src.organHolder.heart.get_damage() > 100)
				src.contract_disease(/datum/ailment/malady/flatline,null,null,1)

		// lungs are skipped until they can be removed/whatever

	handle_stamina_updates()
		if (stamina == STAMINA_NEG_CAP)
			setStatus("paralysis", max(getStatusDuration("paralysis"), STAMINA_NEG_CAP_STUN_TIME))

		//Modify stamina.
		var/stam_time_passed = max(tick_spacing, world.timeofday - last_stam_change)

		var/final_mod = (src.stamina_regen + src.get_stam_mod_regen()) * (stam_time_passed / tick_spacing)
		if (final_mod > 0)
			src.add_stamina(abs(final_mod))
		else if (final_mod < 0)
			src.remove_stamina(abs(final_mod))

		last_stam_change = world.timeofday

		if (src.stamina_bar && src.client)
			src.stamina_bar.update_value(src)


	proc/handle_regular_status_updates(datum/controller/process/mobs/parent,var/mult = 1)

		health = max_health - (get_oxygen_deprivation() + get_toxin_damage() + get_burn_damage() + get_brute_damage())
		var/death_health = src.health + (src.get_oxygen_deprivation() * 0.5) - (get_burn_damage() * 0.67) - (get_brute_damage() * 0.67) //lower weight of oxy, increase weight of brute/burn here
		// I don't think the revenant needs any of this crap - Marq
		if (src.bioHolder && src.bioHolder.HasEffect("revenant") || isdead(src)) //You also don't need to do a whole lot of this if the dude's dead.
			return

		//maximum stamina modifiers.
		stamina_max = max((STAMINA_MAX + src.get_stam_mod_max()), 0)
		stamina = min(stamina, stamina_max)

		parent.setLastTask("status_updates implants organs and augmentations check", src)
		for (var/obj/item/implant/I in src.implant)
			I.on_life(mult)

		//parent.setLastTask("status_updates max value calcs", src)

		parent.setLastTask("status_updates sleep and paralysis calcs", src)
		if (src.hasStatus("resting") && src.sleeping) src.sleeping = 4

		if ((sleeping && !last_sleep) || (last_sleep && !sleeping))
			last_sleep = sleeping
			if (sleeping)
				UpdateOverlays(sleep_bubble, "sleep_bubble")
			else
				UpdateOverlays(null, "sleep_bubble")

		if (src.sleeping)
			src.changeStatus("paralysis", 4 SECONDS)
			if (prob(10) && (health > 0))
				emote("snore")
			if (!src.hasStatus("resting")) src.sleeping--

		parent.setLastTask("status_updates health calcs", src)

		if (prob(50) && src.hasStatus("disorient"))
			src.drop_item()
			src.emote("twitch")

		var/is_chg = is_changeling()
		//if (src.brain_op_stage == 4.0) // handled above in handle_organs() now
			//death()
		if (src.get_brain_damage() >= 120 || death_health <= -500) //-200) a shitty test here // let's lower the weight of oxy
			if (!is_chg)
				death()
			else if (src.suiciding)
				death()

		if (src.get_brain_damage() >= 100) // braindeath
			if (!is_chg)
				boutput(src, "<span style=\"color:red\">Your head [pick("feels like shit","hurts like fuck","pounds horribly","twinges with an awful pain")].</span>")
				src.losebreath+=10
				src.changeStatus("weakened", 3 SECONDS)
		if (src.health <= -100)
			var/deathchance = min(99, ((src.get_brain_damage() * -5) + (src.health + (src.get_oxygen_deprivation() / 2))) * -0.01)
			if (prob(deathchance))
				death()

		/////////////////////////////////////////////
		//// cogwerks - critical health rewrite /////
		/////////////////////////////////////////////
		//// goal: make crit a medical emergency ////
		//// instead of game over black screen time /
		/////////////////////////////////////////////


		if (src.health < 0 && !isdead(src))
			if (prob(5))
				src.emote(pick("faint", "collapse", "cry","moan","gasp","shudder","shiver"))
			if (src.stuttering <= 5)
				src.stuttering+=5
			if (src.get_eye_blurry() <= 5)
				src.change_eye_blurry(5)
			if (prob(7))
				src.change_misstep_chance(2)
			if (prob(5))
				src.changeStatus("paralysis", 3 SECONDS)
			switch(src.health)
				if (-INFINITY to -100)
					src.take_oxygen_deprivation(1)
					if (prob(src.health * -0.1))
						src.contract_disease(/datum/ailment/malady/flatline,null,null,1)
						//boutput(world, "\b LOG: ADDED FLATLINE TO [src].")
					if (prob(src.health * -0.2))
						src.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)
						//boutput(world, "\b LOG: ADDED HEART FAILURE TO [src].")
					if (isalive(src))
						if (src && src.mind)
							src.lastgasp() // if they were ok before dropping below zero health, call lastgasp() before setting them unconscious
					setStatus("paralysis", max(getStatusDuration("paralysis"), 30))
				if (-99 to -80)
					src.take_oxygen_deprivation(1)
					if (prob(4))
						boutput(src, "<span style=\"color:red\"><b>Your chest hurts...</b></span>")
						src.changeStatus("paralysis", 2 SECONDS)
						src.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)
				if (-79 to -51)
					src.take_oxygen_deprivation(1)
					if (prob(10)) // shock added back to crit because it wasn't working as a bloodloss-only thing
						src.contract_disease(/datum/ailment/malady/shock,null,null,1)
						//boutput(world, "\b LOG: ADDED SHOCK TO [src].")
					if (prob(src.health * -0.08))
						src.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)
						//boutput(world, "\b LOG: ADDED HEART FAILURE TO [src].")
					if (prob(6))
						boutput(src, "<span style=\"color:red\"><b>You feel [pick("horrible pain", "awful", "like shit", "absolutely awful", "like death", "like you are dying", "nothing", "warm", "really sweaty", "tingly", "really, really bad", "horrible")]</b>!</span>")
						src.setStatus("weakened", max(src.getStatusDuration("weakened"), 30))
					if (prob(3))
						src.changeStatus("paralysis", 2 SECONDS)
				if (-50 to 0)
					src.take_oxygen_deprivation(0.25)
					/*if (src.reagents)
						if (!src.reagents.has_reagent("inaprovaline") && prob(50))
							src.take_oxygen_deprivation(1)*/
					if (prob(3))
						src.contract_disease(/datum/ailment/malady/shock,null,null,1)
						//boutput(world, "\b LOG: ADDED SHOCK TO [src].")
					if (prob(5))
						boutput(src, "<span style=\"color:red\"><b>You feel [pick("terrible", "awful", "like shit", "sick", "numb", "cold", "really sweaty", "tingly", "horrible")]!</b></span>")
						src.changeStatus("weakened", 3 SECONDS)

		parent.setLastTask("status_updates blindness checks", src)

		//todo : clothing blindles flags for less istypeing
		if (getStatusDuration("blinded"))
			src.blinded = 1

		if (istype(src.glasses, /obj/item/clothing/glasses/))
			var/obj/item/clothing/glasses/G = src.glasses
			if (G.block_vision)
				src.blinded = 1

		if (istype(src.head, /obj/item/clothing/head))
			var/obj/item/clothing/head/H = src.head
			if (H.block_vision)
				src.blinded = 1

		//A ghost costume without eyeholes is a bad idea.
		if (istype(src.wear_suit, /obj/item/clothing/suit/bedsheet))
			var/obj/item/clothing/suit/bedsheet/B = src.wear_suit
			if (!B.eyeholes && !B.cape)
				src.blinded = 1

		else if (istype(src.wear_suit, /obj/item/clothing/suit/cardboard_box))
			var/obj/item/clothing/suit/cardboard_box/B = src.wear_suit
			if (!B.eyeholes)
				src.blinded = 1

		if (manualblinking)
			var/showmessages = 1
			var/tempblind = src.get_eye_damage(1)

			if (src.find_ailment_by_type(/datum/ailment/disability/blind))
				showmessages = 0

			src.blinktimer++
			switch(src.blinktimer)
				if (20)
					if (showmessages) boutput(src, "<span style=\"color:red\">Your eyes feel slightly uncomfortable!</span>")
				if (30)
					if (showmessages) boutput(src, "<span style=\"color:red\">Your eyes feel quite dry!</span>")
				if (40)
					if (showmessages) boutput(src, "<span style=\"color:red\">Your eyes feel very dry and uncomfortable, it's getting difficult to see!</span>")
					src.change_eye_blurry(3, 3)
				if (41 to 59)
					src.change_eye_blurry(3, 3)
				if (60)
					if (showmessages) boutput(src, "<span style=\"color:red\">Your eyes are so dry that you can't see a thing!</span>")
					src.take_eye_damage(max(0, min(3, 3 - tempblind)), 1)
				if (61 to 99)
					src.take_eye_damage(max(0, min(3, 3 - tempblind)), 1)
				if (100) //blinking won't save you now, buddy
					if (showmessages) boutput(src, "<span style=\"color:red\">You feel a horrible pain in your eyes. That can't be good.</span>")
					src.contract_disease(/datum/ailment/disability/blind,null,null,1)

			if (src.blinkstate) src.take_eye_damage(max(0, min(1, 1 - tempblind)), 1)

		if (src.get_eye_damage(1)) // Temporary blindness.
			src.take_eye_damage(-1, 1)
			src.blinded = 1

		// drsingh :wtc: why was there a runtime error about comparing "" to 50 here? varedit or something?
		// welp thisll fix it
		parent.setLastTask("status_updates disability checks", src)
		src.stuttering = isnum(src.stuttering) ? min(src.stuttering, 50) : 0
		if (src.stuttering) src.stuttering--

		if (src.get_ear_damage(1)) // Temporary deafness.
			src.take_ear_damage(-1, 1)

		if (src.get_ear_damage() && (src.get_ear_damage() <= src.get_ear_damage_natural_healing_threshold()))
			src.take_ear_damage(-0.05)

		if (src.get_eye_blurry())
			src.change_eye_blurry(-1)

		if (src.druggy > 0)
			src.druggy--
			src.druggy = max(0, src.druggy)

		if (src.nodamage)
			parent.setLastTask("status_updates nodamage reset", src)
			src.HealDamage("All", 10000, 10000)
			src.take_toxin_damage(-5000)
			src.take_oxygen_deprivation(-5000)
			src.take_brain_damage(-120)
			src.delStatus("radiation")
			src.delStatus("paralysis")
			src.delStatus("weakened")
			src.delStatus("stunned")
			src.stuttering = 0
			src.take_ear_damage(-INFINITY)
			src.take_ear_damage(-INFINITY, 1)
			src.change_eye_blurry(-INFINITY)
			src.druggy = 0
			src.blinded = null

		return 1

	proc/handle_stuns_lying(datum/controller/process/mobs/parent)
		parent.setLastTask("status_updates lying/standing checks")
		var/lying_old = src.lying
		var/cant_lie = (src.limbs && istype(src.limbs.l_leg, /obj/item/parts/robot_parts/leg/left/treads) && istype(src.limbs.r_leg, /obj/item/parts/robot_parts/leg/right/treads) && !locate(/obj/table, src.loc) && !locate(/obj/machinery/optable, src.loc))

		var/must_lie = hasStatus("resting") || (!cant_lie && src.limbs && !src.limbs.l_leg && !src.limbs.r_leg) //hasn't got a leg to stand on... haaa

		var/changeling_fakedeath = 0
		var/datum/abilityHolder/changeling/C = get_ability_holder(/datum/abilityHolder/changeling)
		if (C && C.in_fakedeath)
			changeling_fakedeath = 1

		if (!isdead(src)) //Alive.
			if (src.hasStatus("paralysis") || src.hasStatus("stunned") || src.hasStatus("weakened") || hasStatus("pinned") || changeling_fakedeath || src.hasStatus("resting")) //Stunned etc.
				parent.setLastTask("status_updates lying/standing checks stun calcs")
				var/setStat = src.stat
				var/oldStat = src.stat
				if (src.hasStatus("stunned"))
					setStat = 0
				if (src.hasStatus("weakened") || src.hasStatus("pinned") && !src.fakedead)
					if (!cant_lie) src.lying = 1
					setStat = 0
				if (src.hasStatus("paralysis"))
					if (!cant_lie) src.lying = 1
					setStat = 1
				if (isalive(src) && setStat == 1)
					parent.setLastTask("status_updates lying/standing checks last gasp")
					sleep(0)
					if (src && src.mind) src.lastgasp() // calling lastgasp() here because we just got knocked out
				if (must_lie)
					src.lying = 1

				src.stat = setStat

				parent.setLastTask("status_updates lying/standing checks item dropping")
				var/h = src.hand
				src.hand = 0
				drop_item()
				src.hand = 1
				drop_item()
				src.hand = h
				if (src.juggling())
					src.drop_juggle()

				parent.setLastTask("status_updates lying/standing checks recovery checks")
				if (world.time - last_recovering_msg >= 60 || last_recovering_msg == 0)
					if (prob(10))
						last_recovering_msg = world.time

						//chance to heal self by minute amounts each 'recover' tick
						var/healtype = rand(1,5)
						if (healtype == 1)
							src.take_oxygen_deprivation(-0.3)
							src.lose_breath(-0.3)
						else if (healtype == 2)
							src.HealDamage("All", 0.2, 0, 0)
						else if (healtype == 3)
							src.HealDamage("All", 0, 0.2, 0)
						else if (healtype == 4)
							src.HealDamage("All", 0, 0, 0.2) ///adjsfkaljdsklf;ajs

				else if ((oldStat == 1) && (!getStatusDuration("paralysis") && !getStatusDuration("stunned") && !getStatusDuration("weakened") && !changeling_fakedeath))
					parent.setLastTask("status updates lying/standing checks wakeup ogg")
					src << sound('sound/misc/molly_revived.ogg', volume=50)
					setalive(src)

			else	//Not stunned.
				if (must_lie) src.lying = 1
				else src.lying = 0
				setalive(src)

		else //Dead.
			//if ((src.reagents && src.reagents.has_reagent("montaguone_extra")) || cant_lie) src.lying = 0
			if (cant_lie) src.lying = 0
			else src.lying = 1
			src.blinded = 1
			setdead(src)

		if (src.lying != lying_old)
			parent.setLastTask("status_updates lying/standing checks update clothing")
			update_lying()
			src.set_density(!src.lying)

			if (src.lying && !src.buckled)
				playsound(src.loc, 'sound/misc/body_thud.ogg', 40, 1, 0.3)

	proc/update_lying()
		if (src.buckled)
			if (src.buckled == src.loc)
				src.lying = 1
			if (istype(src.buckled, /obj/stool/bed))
				src.lying = 1
			else
				src.lying = 0

		if (src.lying != src.lying_old)
			src.lying_old = src.lying
			animate_rest(src, !src.lying)
			src.p_class = initial(src.p_class) + src.lying // 2 while standing, 3 while lying


	//MBC : fffuuuucckckckkk
	force_laydown_standup() //immediately force a laydown
		if (processScheduler.hasProcess("Mob"))
			var/datum/controller/process/P = processScheduler.nameToProcessMap["Mob"]
			src.handle_stuns_lying(P)
			src.update_canmove()

			src.handle_blindness_overlays()

			if (src.client)
				updateOverlaysClient(src.client)
			if (src.observers.len)
				for (var/mob/x in src.observers)
					if (x.client)
						src.updateOverlaysClient(x.client)

	proc/handle_regular_sight_updates()

////Mutrace and normal sight
		if (!isdead(src))
			src.sight &= ~SEE_TURFS
			src.sight &= ~SEE_MOBS
			src.sight &= ~SEE_OBJS

			if (src.mutantrace)
				src.mutantrace.sight_modifier()
			else
				src.see_in_dark = SEE_DARK_HUMAN
				src.see_invisible = 0

			if (src.client)
				if((src.traitHolder && src.traitHolder.hasTrait("cateyes")) || (src.getStatusDuration("food_cateyes")))
					render_special.set_centerlight_icon("cateyes")
				else
					render_special.set_centerlight_icon("default")

			if (isvampire(src))
				//var/turf/T = get_turf(src)
				//if (src.check_vampire_power(2) == 1 && (T && !isrestrictedz(T.z)))
				//	src.sight |= SEE_MOBS
				//	src.sight |= SEE_TURFS
				//	src.sight |= SEE_OBJS
				//	src.see_in_dark = SEE_DARK_FULL
				//	src.see_invisible = 2

				//else
				if (src.check_vampire_power(1) == 1 && !isrestrictedz(src.z))
					src.sight |= SEE_MOBS
					src.see_invisible = 2

////Dead sight
		var/turf/T = src.eye ? get_turf(src.eye) : get_turf(src) //They might be in a closet or something idk
		if ((isdead(src) ||( src.bioHolder && src.bioHolder.HasEffect("xray"))) && (T && !isrestrictedz(T.z)))
			src.sight |= SEE_TURFS
			src.sight |= SEE_MOBS
			src.sight |= SEE_OBJS
			src.see_in_dark = SEE_DARK_FULL
			if (client && client.adventure_view)
				src.see_invisible = 21
			else
				src.see_invisible = 2
			return

////Ship sight
		if (istype(src.loc, /obj/machinery/vehicle))
			var/obj/machinery/vehicle/ship = src.loc
			if (ship.sensors)
				if (ship.sensors.active)
					src.sight |= ship.sensors.sight
					src.see_in_dark = ship.sensors.see_in_dark
					if (client && client.adventure_view)
						src.see_invisible = 21
					else
						src.see_invisible = ship.sensors.see_invisible
					return

		if (src.traitHolder && src.traitHolder.hasTrait("infravision"))
			if (see_infrared < 1)
				src.see_infrared = 1

////Glasses

		if (istype(src.glasses, /obj/item/clothing/glasses/construction) && (T && !isrestrictedz(T.z)))
			if (see_in_dark < initial(see_in_dark) + 1)
				see_in_dark++
			if (see_invisible < 8)
				src.see_invisible = 8

		else if (istype(src.glasses, /obj/item/clothing/glasses/thermal/traitor))
			src.sight |= SEE_MOBS //traitor item can see through walls
			if (see_in_dark < SEE_DARK_FULL)
				src.see_in_dark = SEE_DARK_FULL
			if (see_invisible < 2)
				src.see_invisible = 2
			if (see_infrared < 1)
				src.see_infrared = 1

		else if ((istype(src.glasses, /obj/item/clothing/glasses/thermal) || src.eye_istype(/obj/item/organ/eye/cyber/thermal)))	//  && (T && !isrestrictedz(T.z))
			// This kinda fucks up the ability to hide things in infra writing in adv zones
			// so away the restricted z check goes.
			// with mobs invisible it shouldn't matter anyway? probably? idk.
			//src.sight |= SEE_MOBS
			if (see_in_dark < initial(see_in_dark) + 4)
				see_in_dark += 4
			if (see_invisible < 2)
				src.see_invisible = 2
			if (see_infrared < 1)
				src.see_infrared = 1
			render_special.set_centerlight_icon("thermal", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))

		else if (istype(src.wear_mask, /obj/item/clothing/mask/hunter) && (T && !isrestrictedz(T.z)))
			src.sight |= SEE_MOBS // Hunters kinda need proper thermal vision, I've found in playtesting (Convair880).
			if (see_in_dark < SEE_DARK_FULL)
				src.see_in_dark = SEE_DARK_FULL
			if (see_invisible < 2)
				src.see_invisible = 2

		else if (istype(src.glasses, /obj/item/clothing/glasses/regular/ecto) || eye_istype(/obj/item/organ/eye/cyber/ecto))
			if (see_in_dark != 1)
				see_in_dark = 1
			if (see_invisible < 15)
				src.see_invisible = 15
		else if (istype(src.glasses, /obj/item/clothing/glasses/nightvision) || eye_istype(/obj/item/organ/eye/cyber/nightvision) || src.bioHolder && src.bioHolder.HasEffect("nightvision"))
			render_special.set_centerlight_icon("nightvision", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))

		else if (istype(src.glasses, /obj/item/clothing/glasses/meson) && (T && !isrestrictedz(T.z)))
			var/obj/item/clothing/glasses/meson/M = src.glasses
			if (M.on)
				src.sight |= SEE_TURFS
				if (see_in_dark < initial(see_in_dark) + 1)
					see_in_dark++
				render_special.set_centerlight_icon("meson", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255), wide = (client && client.widescreen))

		else if (src.eye_istype(/obj/item/organ/eye/cyber/meson) && (T && !isrestrictedz(T.z)))
			if (!istype(src.glasses, /obj/item/clothing/glasses/meson))
				var/eye_on
				if (src.organ_istype("left_eye", /obj/item/organ/eye/cyber/meson))
					var/obj/item/organ/eye/cyber/meson/meson_eye = src.organHolder.left_eye
					if (meson_eye.on) eye_on = 1
				if (src.organ_istype("right_eye", /obj/item/organ/eye/cyber/meson))
					var/obj/item/organ/eye/cyber/meson/meson_eye = src.organHolder.right_eye
					if (meson_eye.on) eye_on = 1
				if (eye_on)
					src.sight |= SEE_TURFS
					if (see_in_dark < initial(see_in_dark) + 1)
						see_in_dark++
					render_special.set_centerlight_icon("meson", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255), wide = (client && client.widescreen))

////Reagents
		if (src.reagents.has_reagent("green_goop") && (T && !isrestrictedz(T.z)))
			if (see_in_dark != 1)
				see_in_dark = 1
			if (see_invisible < 15)
				src.see_invisible = 15

		if (client && client.adventure_view)
			src.see_invisible = 21

	proc/handle_regular_hud_updates()
		if (src.stamina_bar) src.stamina_bar.update_value(src)
		//hud.update_indicators()
		hud.update_health_indicator()
		hud.update_temp_indicator()
		hud.update_blood_indicator()
		hud.update_pulling()

		var/color_mod_r = 255
		var/color_mod_g = 255
		var/color_mod_b = 255
		if (istype(src.glasses))
			color_mod_r *= src.glasses.color_r
			color_mod_g *= src.glasses.color_g
			color_mod_b *= src.glasses.color_b
		if (istype(src.wear_mask))
			color_mod_r *= src.wear_mask.color_r
			color_mod_g *= src.wear_mask.color_g
			color_mod_b *= src.wear_mask.color_b
		if (istype(src.head))
			color_mod_r *= src.head.color_r
			color_mod_g *= src.head.color_g
			color_mod_b *= src.head.color_b
		var/obj/item/organ/eye/L_E = src.get_organ("left_eye")
		if (istype(L_E))
			color_mod_r *= L_E.color_r
			color_mod_g *= L_E.color_g
			color_mod_b *= L_E.color_b
		var/obj/item/organ/eye/R_E = src.get_organ("right_eye")
		if (istype(R_E))
			color_mod_r *= R_E.color_r
			color_mod_g *= R_E.color_g
			color_mod_b *= R_E.color_b

		if (src.druggy)
			vision.animate_color_mod(rgb(rand(0, 255), rand(0, 255), rand(0, 255)), 15)
		else
			vision.set_color_mod(rgb(color_mod_r, color_mod_g, color_mod_b))

		if (istype(src.glasses, /obj/item/clothing/glasses/healthgoggles))
			var/obj/item/clothing/glasses/healthgoggles/G = src.glasses
			if (src.client && !(G.assigned || G.assigned == src.client))
				G.assigned = src.client
				if (!(G in processing_items))
					processing_items.Add(G)
				//G.updateIcons()

		else if (src.organHolder && istype(src.organHolder.left_eye, /obj/item/organ/eye/cyber/prodoc))
			var/obj/item/organ/eye/cyber/prodoc/G = src.organHolder.left_eye
			if (src.client && !(G.assigned || G.assigned == src.client))
				G.assigned = src.client
				if (!(G in processing_items))
					processing_items.Add(G)
				//G.updateIcons()
		else if (src.organHolder && istype(src.organHolder.right_eye, /obj/item/organ/eye/cyber/prodoc))
			var/obj/item/organ/eye/cyber/prodoc/G = src.organHolder.right_eye
			if (src.client && !(G.assigned || G.assigned == src.client))
				G.assigned = src.client
				if (!(G in processing_items))
					processing_items.Add(G)
				//G.updateIcons()
		return 1

	proc/handle_blindness_overlays()
		vision.animate_dither_alpha(src.get_eye_blurry() / 10 * 255, 15) // animate it so that it doesnt "jump" as much

		var/eyes_blinded = 0

		if (!isdead(src))
			if (!src.sight_check(1))
				eyes_blinded |= EYEBLIND_L
				eyes_blinded |= EYEBLIND_R
			else
				if (!src.get_organ("left_eye"))
					eyes_blinded |= EYEBLIND_L
				if (!src.get_organ("right_eye"))
					eyes_blinded |= EYEBLIND_R
				if (istype(src.glasses))
					if (src.glasses.block_eye)
						if (src.glasses.block_eye == "L")
							eyes_blinded |= EYEBLIND_L
						else
							eyes_blinded |= EYEBLIND_R
					if (src.glasses.allow_blind_sight)
						eyes_blinded = 0

		if (src.last_eyes_blinded == eyes_blinded) // we don't need to update!
			return 1


		if (!eyes_blinded) // neither eye is blind
			src.removeOverlayComposition(/datum/overlayComposition/blinded)
			src.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
			src.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

		else if ((eyes_blinded & EYEBLIND_L) && (eyes_blinded & EYEBLIND_R)) // both eyes are blind
			src.addOverlayComposition(/datum/overlayComposition/blinded)
			src.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
			src.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

		else if (eyes_blinded & EYEBLIND_L) // left eye is blind, not right
			src.removeOverlayComposition(/datum/overlayComposition/blinded)
			src.addOverlayComposition(/datum/overlayComposition/blinded_l_eye)
			src.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

		else if (eyes_blinded & EYEBLIND_R) // right eye is blind, not left
			src.removeOverlayComposition(/datum/overlayComposition/blinded)
			src.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
			src.addOverlayComposition(/datum/overlayComposition/blinded_r_eye)

		else // edge case?  remove overlays just in case
			src.removeOverlayComposition(/datum/overlayComposition/blinded)
			src.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
			src.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

		src.last_eyes_blinded = eyes_blinded
		return 1

	proc/handle_random_events()
		if (prob(1) && prob(2))
			emote("sneeze")

	proc/handle_virus_updates()
		if (src.ailments && src.ailments.len)
			for (var/mob/living/carbon/M in oviewers(4, src))
				if (prob(40))
					src.viral_transmission(M,"Airborne",0)
				if (prob(20))
					src.viral_transmission(M,"Sight", 0)

			if (!isdead(src))
				for (var/datum/ailment_data/am in src.ailments)
					am.stage_act()

		if (prob(40))
			for (var/obj/decal/cleanable/blood/B in view(2, src))
				for (var/datum/ailment_data/disease/virus in B.diseases)
					if (virus.spread == "Airborne")
						src.contract_disease(null,null,virus,0)

	proc/check_if_buckled()
		if (src.buckled)
			if (src.buckled.loc != src.loc)
				src.buckled = null
				return
			src.lying = istype(src.buckled, /obj/stool/bed) || istype(src.buckled, /obj/machinery/conveyor)
			if (src.lying)
				src.drop_item()
			src.set_density(1)
		else
			src.set_density(!src.lying)

	proc/handle_stomach()
		if (stomach_contents && stomach_contents.len)
			SPAWN_DBG(0)
				for (var/mob/M in stomach_contents)
					if (M.loc != src)
						stomach_contents.Remove(M)
						continue
					if (iscarbon(M) && !isdead(src))
						if (isdead(M))
							M.death(1)
							stomach_contents.Remove(M)
							if (M.client)
								var/mob/dead/observer/newmob = new(M)
								M:client:mob = newmob
								M.mind.transfer_to(newmob)
							qdel(M)
							emote("burp")
							playsound(src.loc, "sound/voice/burp.ogg", 50, 1)
							continue
						if (air_master.current_cycle%3==1)
							if (!M.nodamage)
								M.TakeDamage("chest", 5, 0)
							src.nutrition += 10

	proc/handle_random_emotes()
		if (!islist(src.random_emotes) || !src.random_emotes.len || src.stat)
			return
		var/emote2do = pick(src.random_emotes)
		src.emote(emote2do)
