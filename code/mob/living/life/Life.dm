/datum/lifeprocess
	var/mob/living/owner
	var/last_process = 0

	var/const/tick_spacing = LIFE_PROCESS_TICK_SPACING //This should pretty much *always* stay at 20, for it is the one number that all do-over-time stuff should be balanced around
	var/const/cap_tick_spacing = LIFE_PROCESS_CAP_TICK_SPACING //highest TIME allowance between ticks to try to play catchup with realtime thingo

	var/mob/living/carbon/human/human_owner = null
	var/mob/living/silicon/hivebot/hivebot_owner = null
	var/mob/living/silicon/robot/robot_owner = null
	var/mob/living/critter/critter_owner = null

	New(new_owner,arguments)
		..()
		last_process = TIME

		owner = new_owner
		if (ishuman(owner))
			human_owner = owner
		if (istype(owner,/mob/living/silicon/hivebot))
			hivebot_owner = owner
		if (istype(owner,/mob/living/silicon/robot))
			robot_owner = owner
		if (istype(owner,/mob/living/critter))
			critter_owner = owner

	disposing()
		..()
		owner = null
		human_owner = null
		hivebot_owner = null
		robot_owner = null
		critter_owner = null

	proc/Process(datum/gas_mixture/environment)
		SHOULD_NOT_OVERRIDE(TRUE)
		process(environment)
		last_process = TIME

	proc/process(datum/gas_mixture/environment)
		PROTECTED_PROC(TRUE)

	proc/get_multiplier()
		.= clamp(TIME - last_process, tick_spacing, cap_tick_spacing) / tick_spacing

/mob/living
	var/list/lifeprocesses = list()

	//remove these evntually cause lifeporcesses handl ethem
	var/last_life_tick = 0 //and this ones just the whole lifetick
	var/const/tick_spacing = 20 //This should pretty much *always* stay at 20, for it is the one number that all do-over-time stuff should be balanced around
	var/const/cap_tick_spacing = 100 //highest TIME allowance between ticks to try to play catchup with realtime thingo
	var/last_stam_change = 0
	var/life_context = "begin"


	var/last_no_gravity = 0

	proc/add_lifeprocess(type,...)
		var/datum/lifeprocess/L = null
		if (length(args) > 1)
			var/arguments = args.Copy(2)
			L = new type(src,arguments)
		else
			L = new type(src)
		lifeprocesses?[type] = L
		return L

	proc/remove_lifeprocess(type)
		var/datum/lifeprocess/L = lifeprocesses?[type]
		lifeprocesses -= type
		qdel(L)

	proc/get_heat_protection()
		var/thermal_protection = 10 // base value

		// Resistance from Bio Effects
		if (src.bioHolder)
			if (src.bioHolder.HasEffect("dwarf"))
				thermal_protection += 10

		// Resistance from Clothing
		thermal_protection += GET_ATOM_PROPERTY(src, PROP_MOB_HEATPROT)
		thermal_protection = clamp(thermal_protection, 0, 100)
		return thermal_protection

	proc/get_cold_protection()
		// Sealed space suit? If so, consider it to be full protection
		if (src.protected_from_space())
			return 100

		var/thermal_protection = 10 // base value

		// Resistance from Clothing
		thermal_protection += GET_ATOM_PROPERTY(src, PROP_MOB_COLDPROT)

		thermal_protection = clamp(thermal_protection, 0, 100)
		return thermal_protection

	proc/get_rad_protection()
		return (tanh(0.02*(GET_ATOM_PROPERTY(src, PROP_MOB_RADPROT_EXT)+GET_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT)))**2)

	proc/get_chem_protection()
		return clamp(GET_ATOM_PROPERTY(src, PROP_MOB_CHEMPROT), 0, 100)

/mob/living/New()
	..()
	//wel gosh, its important that we do this otherwisde the crew could spawn into an airless room and then immediately die
	last_life_tick = TIME

/mob/living/disposing()
	for (var/datum/lifeprocess/L in lifeprocesses)
		remove_lifeprocess(L)
	lifeprocesses.len = 0
	lifeprocesses = null
	..()

/mob/living/carbon/human
	var/list/heartbeatOverlays = list()
	var/last_human_life_tick = 0

/mob/living/critter/New()
	..()
	add_lifeprocess(/datum/lifeprocess/blood)
	//add_lifeprocess(/datum/lifeprocess/bodytemp) //maybe enable per-critter
	//add_lifeprocess(/datum/lifeprocess/breath) //most of them cant even wear internals
	add_lifeprocess(/datum/lifeprocess/canmove)
	add_lifeprocess(/datum/lifeprocess/chems)
	add_lifeprocess(/datum/lifeprocess/disability)
	add_lifeprocess(/datum/lifeprocess/fire)
	add_lifeprocess(/datum/lifeprocess/hud)
	add_lifeprocess(/datum/lifeprocess/mutations)
	add_lifeprocess(/datum/lifeprocess/organs)
	add_lifeprocess(/datum/lifeprocess/sight)
	add_lifeprocess(/datum/lifeprocess/skin)
	add_lifeprocess(/datum/lifeprocess/statusupdate)
	add_lifeprocess(/datum/lifeprocess/stuns_lying)
	add_lifeprocess(/datum/lifeprocess/viruses)
	add_lifeprocess(/datum/lifeprocess/blindness)
	add_lifeprocess(/datum/lifeprocess/radiation)

/mob/living/carbon/human/New()
	..()
	add_lifeprocess(/datum/lifeprocess/arrest_icon)
	add_lifeprocess(/datum/lifeprocess/blood)
	add_lifeprocess(/datum/lifeprocess/bodytemp)
	add_lifeprocess(/datum/lifeprocess/breath)
	add_lifeprocess(/datum/lifeprocess/canmove)
	add_lifeprocess(/datum/lifeprocess/chems)
	add_lifeprocess(/datum/lifeprocess/critical)
	add_lifeprocess(/datum/lifeprocess/decomposition)
	add_lifeprocess(/datum/lifeprocess/disability)
	add_lifeprocess(/datum/lifeprocess/fire)
	add_lifeprocess(/datum/lifeprocess/health_mon)
	add_lifeprocess(/datum/lifeprocess/hud)
	add_lifeprocess(/datum/lifeprocess/mutations)
	add_lifeprocess(/datum/lifeprocess/organs)
	add_lifeprocess(/datum/lifeprocess/sight)
	add_lifeprocess(/datum/lifeprocess/skin)
	add_lifeprocess(/datum/lifeprocess/statusupdate)
	add_lifeprocess(/datum/lifeprocess/stuns_lying)
	add_lifeprocess(/datum/lifeprocess/viruses)
	add_lifeprocess(/datum/lifeprocess/blindness)
	add_lifeprocess(/datum/lifeprocess/radiation)

/mob/living/carbon/cube/New()
	..()
	add_lifeprocess(/datum/lifeprocess/canmove)
	add_lifeprocess(/datum/lifeprocess/chems)
	add_lifeprocess(/datum/lifeprocess/disability)
	add_lifeprocess(/datum/lifeprocess/hud)
	add_lifeprocess(/datum/lifeprocess/organs)
	add_lifeprocess(/datum/lifeprocess/sight)
	add_lifeprocess(/datum/lifeprocess/statusupdate)
	add_lifeprocess(/datum/lifeprocess/stuns_lying)
	add_lifeprocess(/datum/lifeprocess/blindness)
	add_lifeprocess(/datum/lifeprocess/radiation)

/mob/living/silicon/ai/New()
	..()
	add_lifeprocess(/datum/lifeprocess/sight)
	add_lifeprocess(/datum/lifeprocess/blindness)

/mob/living/silicon/hivebot/New()
	..()
	add_lifeprocess(/datum/lifeprocess/canmove)
	add_lifeprocess(/datum/lifeprocess/hud)
	add_lifeprocess(/datum/lifeprocess/sight)
	add_lifeprocess(/datum/lifeprocess/hivebot_statusupdate)
	add_lifeprocess(/datum/lifeprocess/stuns_lying)
	add_lifeprocess(/datum/lifeprocess/blindness)

/mob/living/silicon/robot/New()
	..()
	add_lifeprocess(/datum/lifeprocess/canmove)
	add_lifeprocess(/datum/lifeprocess/hud)
	add_lifeprocess(/datum/lifeprocess/sight)
	add_lifeprocess(/datum/lifeprocess/robot_statusupdate)
	add_lifeprocess(/datum/lifeprocess/stuns_lying)
	add_lifeprocess(/datum/lifeprocess/blindness)
	add_lifeprocess(/datum/lifeprocess/robot_oil)
	add_lifeprocess(/datum/lifeprocess/robot_locks)


/mob/living/silicon/drone/New()
	..()
	add_lifeprocess(/datum/lifeprocess/canmove)
	add_lifeprocess(/datum/lifeprocess/stuns_lying)

/mob/living/Life(datum/controller/process/mobs/parent)
	set invisibility = INVIS_NONE
	if (..())
		return 1

	if (src.transforming)
		return 1

	var/life_time_passed = max(tick_spacing, TIME - last_life_tick)

	var/life_mult = life_time_passed / tick_spacing

	// Jewel's attempted fix for: null.return_air()
	// These objects should be garbage collected the next tick, so it's not too bad if it's not breathing I think? I might be totallly wrong here.
	if (loc)
		clamp_values()

		var/datum/gas_mixture/environment = loc.return_air()

		src.blinded = null//needs to be set here, multiple life processes will be affecting it ewwww

		///LIFE PROCESS
		//Most stuff gets handled here but i've left some other code below because all living mobs can use it

		var/datum/lifeprocess/L
		for (var/thing in src.lifeprocesses)
			if(src.disposed) return
			L = src.lifeprocesses?[thing]
			if(!L)
				logTheThing(LOG_DEBUG, src, "had lifeprocess [thing] removed during Life() probably.")
				continue
			L.Process(environment)

		for (var/obj/item/implant/I in src.implant)
			I.on_life(life_mult)

		update_item_abilities()

		update_objectives()

		if (!isdead(src)) //still breathing
			//do on_life things for components?
			SEND_SIGNAL(src, COMSIG_LIVING_LIFE_TICK, life_mult)

			if (last_no_gravity != src.no_gravity)
				if(src.no_gravity)
					animate_levitate(src, -1, 10, 1)
				else
					src.no_gravity = 0
					animate(src, transform = matrix(), time = 1)
				last_no_gravity = src.no_gravity

		clamp_values()

		//Regular Trait updates
		if(src.traitHolder)
			for(var/id in src.traitHolder.traits)
				var/datum/trait/O = src.traitHolder.traits[id]
				O.onLife(src, life_mult)

		update_icons_if_needed()

		if (src.client) //ov1
			// overlays
			src.updateOverlaysClient(src.client)
			src.antagonist_overlay_refresh(0, 0)

		if (src.observers.len)
			for (var/mob/x in src.observers)
				if (x.client)
					src.updateOverlaysClient(x.client)

		for (var/obj/item/grab/G in src.equipped_list(check_for_magtractor = 0))
			G.process(life_mult)

		if (!can_act(M=src,include_cuffs=0))
			actions.interrupt(src, INTERRUPT_STUNNED)

		if (src.abilityHolder)
			src.abilityHolder.onLife(life_mult)

	last_life_tick = TIME

/////////////////////////////////////////////////////////////////////////////////////
//LIFE() PROCS THAT ARE HIGHLY SPECIFIC ABOUT WHAT MOB THEY RUN
//THIS INCLUDES EVERYTHING I COULDNT FIGURE OUT HOW TO WORK INTO A LIFEPROCESS NICELY
//////////////////////////////////////////////////////////////////////////////////////


/mob/living/carbon/human/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

	var/mult = (max(tick_spacing, TIME - last_human_life_tick) / tick_spacing)

	if (farty_party)
		src.emote("fart")

	//Attaching a limb that didn't originally belong to you can do stuff
	if(!isdead(src) && prob(2) && src.limbs)
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

	if (src.mutantrace)
		src.mutantrace.onLife(mult)

	if (!isdead(src)) // Marq was here, breaking everything.

		if (src.sims && src.ckey) // ckey will be null if it's an npc, so they're skipped
			src.sims.Life()

		if (prob(1) && prob(5))
			src.handle_random_emotes()

		if (src.slug)
			src.handle_slug_process()

	src.handle_pathogens()

	last_human_life_tick = TIME

/mob/living/critter/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

	if (!isdead(src))
		update_stunned_icon(canmove)

		for (var/T in healthlist)
			var/datum/healthHolder/HH = healthlist[T]
			HH.Life()

/mob/living/silicon/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1
	if (!isdead(src))
		use_power()

/mob/living/silicon/robot/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

	src.mainframe_check()

	if (!isdead(src)) //Alive.
		if (src.health < 0)
			death()

	process_killswitch()
	process_locks()
	update_canmove()

	if (metalman_skin && prob(1))
		var/msg = pick("can't see...","feels bad...","leave me...", "you're cold...", "unwelcome...")
		src.show_text(voidSpeak(msg))
		src.emagged = 1

/mob/living/silicon/ai/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

	if (isalive(src))
		if (src.health < 0)
			death()
	else
		tracker.cease_track()
		src:current = null
		if (src.health >= 0)
			// sure keep trying to use power i guess.
			use_power()


	hud.update()
	process_killswitch()

/mob/living/silicon/hivebot/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

	if(health <= 0)
		gib(1)

	if(client)
		src.shell = 0
		if(dependent)
			mainframe_check()

/mob/living/silicon/ghostdrone/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

	if (hud)
		hud.update_environment()
		hud.update_health()
		hud.update_tools()

	if (src.client)
		src.updateStatic()

/mob/living/silicon/drone/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1
	//hud.update_health()
	if (hud)
		hud.update_charge()
		hud.update_tools()

/mob/living/seanceghost/Life(parent)
	if (..(parent))
		return 1
	if (!src.abilityHolder)
		src.abilityHolder = new /datum/abilityHolder/zoldorf(src)
	else if (src.health < src.max_health)
		src.health++

/mob/living/object/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

/mob/living/carbon/cube
	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		// not sure if this could ever really happen but better to make sure
		if (isdead(src))
			pop()
			return 0

		// don't move or tick down the timer if we're in the fryer, we need to wait until we're well done
		if (istype(loc, /obj/machinery/deep_fryer))
			return 0

		if (prob(30))
			var/idle_message = get_cube_idle()
			src.visible_message("<span class='alert'><b>[src] [idle_message]!</b></span>")

		if (life_timer-- > 0)
			return 0

		pop()

/////////////////////////////////////////////////////////
// 					MISC STUFF
/////////////////////////////////////////////////////////

/mob/living/
	proc/clamp_values()
		sleeping = clamp(sleeping, 0, 20)
		stuttering = clamp(stuttering, 0, 50)
		losebreath = clamp(losebreath, 0, 25) // stop going up into the thousands, goddamn

	proc/handle_burning()
		if (src.getStatusDuration("burning"))

			if (src.getStatusDuration("burning") > 200)
				for (var/atom/A as anything in src.contents)
					if (A.event_handler_flags & HANDLE_STICKER)
						if (A:active)
							src.visible_message("<span class='alert'><b>[A]</b> is burnt to a crisp and destroyed!</span>")
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

	proc/stink()
		if (prob(15))
			for (var/mob/living/carbon/C in view(6,get_turf(src)))
				if (C == src || !C.client)
					continue
				boutput(C, "<span class='alert'>[stinkString()]</span>")
				if (prob(30))
					C.vomit()
					C.changeStatus("stunned", 2 SECONDS)
					boutput(C, "<span class='alert'>[stinkString()]</span>")


	proc/update_objectives()
		if (!src.mind)
			return
		if (!src.mind.objectives)
			return
		if (!istype(src.mind.objectives, /list))
			return
		if (src.mind.stealth_objective)
			for (var/datum/objective/O in src.mind.objectives)
				if (istype(O, /datum/objective/specialist/stealth))
					var/turf/T = get_turf(src)
					if (T && isturf(T) && (istype(T, /turf/space) || T.loc.name == "Space" || T.loc.name == "Ocean" || T.z != 1))
						O:score = max(0, O:score - 1)
						if (prob(20))
							boutput(src, "<span class='alert'><B>Being away from the station is making you lose your composure...</B></span>")
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

	proc/update_sight()
		var/datum/lifeprocess/L = lifeprocesses?[/datum/lifeprocess/sight]
		if (L)
			L.Process()

	update_canmove()
		var/datum/lifeprocess/L = lifeprocesses?[/datum/lifeprocess/canmove]
		if (L)
			L.Process()

	force_laydown_standup() //immediately force a laydown
		if(!lifeprocesses)
			return
		var/datum/lifeprocess/L = lifeprocesses?[/datum/lifeprocess/stuns_lying]
		if (L)
			L.Process()
		L = lifeprocesses?[/datum/lifeprocess/canmove]
		if (L)
			L.Process()
		L = lifeprocesses?[/datum/lifeprocess/blindness]
		if (L)
			L.Process()

		if (src.client)
			updateOverlaysClient(src.client)
		if (src.observers.len)
			for (var/mob/x in src.observers)
				if (x.client)
					src.updateOverlaysClient(x.client)


	handle_stamina_updates()
		if (stamina == STAMINA_NEG_CAP)
			setStatusMin("paralysis", STAMINA_NEG_CAP_STUN_TIME)

		//Modify stamina.
		var/stam_time_passed = max(tick_spacing, TIME - last_stam_change)

		var/final_mod = (src.stamina_regen + GET_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS)) * (stam_time_passed / tick_spacing)
		if (final_mod > 0)
			src.add_stamina(abs(final_mod))
		else if (final_mod < 0)
			src.remove_stamina(abs(final_mod))

		if (src.stamina_bar && src.client)
			src.stamina_bar.update_value(src)

		last_stam_change = TIME


	proc/handle_random_events()
		if (prob(1) && prob(2))
			emote("sneeze")

	proc/handle_random_emotes()
		if (!islist(src.random_emotes) || !src.random_emotes.len || src.stat)
			return
		var/emote2do = pick(src.random_emotes)
		src.emote(emote2do)

	//Hints towards a parasited host and takes away points on each tick
	proc/handle_slug_process()
		//Check if they have slug abilities
		if (src.abilityHolder)
			var/datum/abilityHolder/brain_slug/AH = null
			if(istype(src.abilityHolder, /datum/abilityHolder/brain_slug))
				AH = src.abilityHolder
			else if (istype(src.abilityHolder, /datum/abilityHolder/composite))
				var/datum/abilityHolder/composite/composite_holder = src.abilityHolder
				for (var/datum/abilityHolder/found_holder in composite_holder.holders)
					if (istype(found_holder, /datum/abilityHolder/brain_slug))
						AH = found_holder
						break
			//If they do, roll a chance to do some hint
			if (AH)
				AH.points --
				if (AH.points > 350)
					if (prob(4))
						if(prob(50))
							src.emote(pick("drool", "twitch_v", "sneeze", "groan", "shiver"))
						else
							src.visible_message("<span class='notice'>[src] vomits! It looks slimier than usual</span>")
							src.vomit()
				else if (AH.points > 1)
					if (prob(6))
						//emote or vomit
						if(prob(50))
							src.emote(pick("twitch_v", "gesticulate", "scream", "twitch", "cough"))
							src.make_jittery(20)
						else
							//small vomit or big puke
							if (prob(70))
								src.emote("cough")
								var/turf/T = get_turf(src)
								src.visible_message("<span class='alert'>[src] coughs up some slimy blood!</span>")
								make_cleanable(/obj/decal/cleanable/blood,T)
							else
								src.visible_message("<span class='alert'>[src] vomits a lot of slimy, sticky blood!</span>")
								playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
								bleed(src, rand(5,8), 5)
				//The body is rotting on it's feet, time to go
				else if (AH.points <= 0)
					random_brute_damage(src, -(AH.points))
					src.take_oxygen_deprivation(-(AH.points))
/mob/living/carbon/human

	proc/handle_pathogens()
		if (isdead(src))
			if (src.pathogens.len)
				for (var/uid in src.pathogens)
					var/datum/pathogen/P = src.pathogens[uid]
					P.disease_act_dead()
			return
		for (var/uid in src.pathogens)
			var/datum/pathogen/P = src.pathogens[uid]
			P.disease_act()


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

		for (var/obj/item/C as anything in src.get_equipped_items())
			resist_prob += C.getProperty("viralprot")

		if(src.getStatusDuration("food_disease_resist"))
			resist_prob += 80

		resist_prob = clamp(resist_prob,0,100)
		return resist_prob

	get_ranged_protection()
		if (!src)
			return 0

		var/protection = 1

		// Resistance from Clothing
		protection += GET_ATOM_PROPERTY(src, PROP_MOB_RANGEDPROT)
		protection += GET_ATOM_PROPERTY(src, PROP_MOB_ENCHANT_ARMOR)/10 //enchanted clothing isn't that bulletproof at all
		return protection

	get_melee_protection(zone, damage_type)
		if (!src)
			return 0
		var/protection = 0
		var/a_zone = zone
		if (a_zone in list("l_leg", "r_arm", "l_leg", "r_leg"))
			a_zone = "chest"
			//protection from clothing
		if(a_zone == "All")
			protection = (5 * GET_ATOM_PROPERTY(src, PROP_MOB_MELEEPROT_BODY) + GET_ATOM_PROPERTY(src, PROP_MOB_MELEEPROT_HEAD))/6
		else if (a_zone == "chest")
			protection = GET_ATOM_PROPERTY(src, PROP_MOB_MELEEPROT_BODY)
		else //can only be head
			protection = GET_ATOM_PROPERTY(src, PROP_MOB_MELEEPROT_HEAD)
		protection += GET_ATOM_PROPERTY(src, PROP_MOB_ENCHANT_ARMOR)/2
		//protection from blocks
		var/obj/item/grab/block/G = src.check_block()
		if (G && damage_type)
			protection += G.can_block(damage_type)

		if (isnull(protection)) //due to GET_ATOM_PROPERTY returning null if it doesnt exist
			protection = 0
		return protection

	get_deflection()
		if (!src)
			return 0
		return min(GET_ATOM_PROPERTY(src, PROP_MOB_DISARM_RESIST), 90)


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

////////////////////////////////////////
//Unused heart thump stuff
////////////////////////////////////////

/mob/living/carbon/human
	proc/Thumper_createHeartbeatOverlays()
		for (var/mob/x in (src.observers + src))
			if(!heartbeatOverlays[x] && x.client)
				var/atom/movable/screen/hb = new
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
			var/atom/movable/screen/overlay = src.heartbeatOverlays[x]
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
		SPAWN(2 SECONDS)
			while(src.doThumps)
				Thumper_thump(0)
				sleep(2 SECONDS)
	proc/Thumper_stopThumps()
		doThumps = 0
	proc/Thumper_paralyzed()
		Thumper_createHeartbeatOverlays()
		if(doThumps)//we're thumping dangit
			doThumps = 0
		for(var/mob/x in src.heartbeatOverlays)
			var/atom/movable/screen/overlay = src.heartbeatOverlays[x]
			if(x.client)
				animate(overlay, alpha = 255,
					color = list( list(0,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,4) ),
					10, flags=ANIMATION_END_NOW)//adjust the 4 to adjust aperture size
	proc/Thumper_crit()
		Thumper_createHeartbeatOverlays()
		if(doThumps)
			doThumps = 0
		for(var/mob/x in src.heartbeatOverlays)
			var/atom/movable/screen/overlay = src.heartbeatOverlays[x]
			if(x.client)
				animate(overlay,
					alpha = 255,
					color = list( list(0.1,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,0.8), list(0,0,0,0) ),
				time = 10, easing = SINE_EASING)

	proc/Thumper_restore()
		Thumper_createHeartbeatOverlays()
		doThumps = 0
		for(var/mob/x in src.heartbeatOverlays)
			var/atom/movable/screen/overlay = src.heartbeatOverlays[x]
			if(x.client)
				animate(overlay, color = list( list(0,0,0,0), list( 0,0,0,0 ), list(0,0,0,0), list(0,0,0,-100), list(0,0,0,0) ), alpha = 0, 20, SINE_EASING )
