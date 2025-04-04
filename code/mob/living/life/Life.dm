/datum/lifeprocess
	var/mob/living/owner
	var/last_process = 0

	/// This should pretty much *always* stay at 20, for it is the one number that all do-over-time stuff should be balanced around
	var/const/tick_spacing = LIFE_PROCESS_TICK_SPACING
	/// highest TIME allowance between ticks to try to play catchup with realtime thingo
	var/const/cap_tick_spacing = LIFE_PROCESS_CAP_TICK_SPACING

	var/mob/living/carbon/human/human_owner = null
	var/mob/living/silicon/hivebot/hivebot_owner = null
	var/mob/living/silicon/robot/robot_owner = null
	var/mob/living/silicon/ai/ai_mainframe_owner = null
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
		if (istype(owner,/mob/living/silicon/ai))
			ai_mainframe_owner = owner
		if (istype(owner,/mob/living/critter))
			critter_owner = owner

	disposing()
		..()
		owner = null
		human_owner = null
		hivebot_owner = null
		robot_owner = null
		ai_mainframe_owner = null
		critter_owner = null

	proc/Process(datum/gas_mixture/environment)
		SHOULD_NOT_OVERRIDE(TRUE)
		process(environment)
		last_process = TIME

	proc/process(datum/gas_mixture/environment)
		PROTECTED_PROC(TRUE)
		//SHOULD_NOT_SLEEP(TRUE)

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
		if(!lifeprocesses) return //sometimes list is null, causes runtime.
		var/datum/lifeprocess/L = lifeprocesses[type]
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
	restore_life_processes()

/mob/living/full_heal()
	. = ..()
	if (src.ai && src.is_npc) src.ai.enable()
	src.remove_ailments()
	src.change_misstep_chance(-INFINITY)
	restore_life_processes()

/mob/living/disposing()
	for (var/datum/lifeprocess/L in lifeprocesses)
		remove_lifeprocess(L)
	lifeprocesses.len = 0
	lifeprocesses = null
	..()

/mob/living/carbon/human
	var/list/heartbeatOverlays = list()
	var/last_human_life_tick = 0

/mob/living/critter/restore_life_processes()
	..()
	add_lifeprocess(/datum/lifeprocess/blood)
	//add_lifeprocess(/datum/lifeprocess/bodytemp) //maybe enable per-critter
	//add_lifeprocess(/datum/lifeprocess/breath) //most of them cant even wear internals
	add_lifeprocess(/datum/lifeprocess/chems)
	add_lifeprocess(/datum/lifeprocess/disability)
	add_lifeprocess(/datum/lifeprocess/hud)
	add_lifeprocess(/datum/lifeprocess/mutations)
	add_lifeprocess(/datum/lifeprocess/organs)
	add_lifeprocess(/datum/lifeprocess/sight)
	add_lifeprocess(/datum/lifeprocess/statusupdate)
	add_lifeprocess(/datum/lifeprocess/stuns_lying)
	add_lifeprocess(/datum/lifeprocess/blindness)
	add_lifeprocess(/datum/lifeprocess/radiation)

/mob/living/carbon/human/restore_life_processes()
	..()
	add_lifeprocess(/datum/lifeprocess/blood)
	add_lifeprocess(/datum/lifeprocess/bodytemp)
	add_lifeprocess(/datum/lifeprocess/breath)
	add_lifeprocess(/datum/lifeprocess/chems)
	add_lifeprocess(/datum/lifeprocess/critical)
	remove_lifeprocess(/datum/lifeprocess/decomposition) // only happens when mob is dead
	add_lifeprocess(/datum/lifeprocess/disability)
	add_lifeprocess(/datum/lifeprocess/hud)
	add_lifeprocess(/datum/lifeprocess/mutations)
	add_lifeprocess(/datum/lifeprocess/organs)
	add_lifeprocess(/datum/lifeprocess/sight)
	add_lifeprocess(/datum/lifeprocess/statusupdate)
	add_lifeprocess(/datum/lifeprocess/stuns_lying)
	add_lifeprocess(/datum/lifeprocess/blindness)
	add_lifeprocess(/datum/lifeprocess/radiation)
	add_lifeprocess(/datum/lifeprocess/faith)

/mob/living/carbon/cube/restore_life_processes()
	..()
	add_lifeprocess(/datum/lifeprocess/chems)
	add_lifeprocess(/datum/lifeprocess/disability)
	add_lifeprocess(/datum/lifeprocess/hud)
	add_lifeprocess(/datum/lifeprocess/organs)
	add_lifeprocess(/datum/lifeprocess/sight)
	add_lifeprocess(/datum/lifeprocess/statusupdate)
	add_lifeprocess(/datum/lifeprocess/stuns_lying)
	add_lifeprocess(/datum/lifeprocess/blindness)
	add_lifeprocess(/datum/lifeprocess/radiation)

/mob/living/silicon/ai/restore_life_processes()
	..()
	add_lifeprocess(/datum/lifeprocess/sight)
	add_lifeprocess(/datum/lifeprocess/blindness)
	add_lifeprocess(/datum/lifeprocess/disability)
	add_lifeprocess(/datum/lifeprocess/faith)

/mob/living/silicon/hivebot/restore_life_processes()
	..()
	add_lifeprocess(/datum/lifeprocess/hud)
	add_lifeprocess(/datum/lifeprocess/sight)
	add_lifeprocess(/datum/lifeprocess/hivebot_statusupdate)
	add_lifeprocess(/datum/lifeprocess/stuns_lying)
	add_lifeprocess(/datum/lifeprocess/blindness)
	add_lifeprocess(/datum/lifeprocess/hivebot_signal)


/mob/living/silicon/robot/restore_life_processes()
	..()
	add_lifeprocess(/datum/lifeprocess/hud)
	add_lifeprocess(/datum/lifeprocess/sight)
	add_lifeprocess(/datum/lifeprocess/robot_statusupdate)
	add_lifeprocess(/datum/lifeprocess/stuns_lying)
	add_lifeprocess(/datum/lifeprocess/blindness)
	add_lifeprocess(/datum/lifeprocess/robot_locks)
	add_lifeprocess(/datum/lifeprocess/disability)
	add_lifeprocess(/datum/lifeprocess/faith)


/mob/living/silicon/drone/restore_life_processes()
	..()
	add_lifeprocess(/datum/lifeprocess/stuns_lying)

/mob/living/intangible/aieye/restore_life_processes()
	. = ..()
	add_lifeprocess(/datum/lifeprocess/disability) // for misstep

/mob/living/Life(datum/controller/process/mobs/parent)
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

		if (length(src.observers))
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

	src.mutantrace?.onLife(mult)

	if (farty_party)
		src.emote("fart")

	if (length(src.juggling))
		var/list/juggled_items = list()
		for (var/obj/item/juggled in src.juggling)
			juggled_items += juggled
		if (length(juggled_items) > 1)
			var/obj/item/item1 = pick(juggled_items)
			juggled_items -= item1
			var/obj/item/item2 = pick(juggled_items)
			item2.Attackby(item1, src, silent = TRUE)

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

	if (!isdead(src)) // Marq was here, breaking everything.
		if(src.limbs)
			src.limbs.l_arm?.on_life(parent)
			src.limbs.r_arm?.on_life(parent)
			src.limbs.l_leg?.on_life(parent)
			src.limbs.r_leg?.on_life(parent)

		if (src.sims && src.ckey) // ckey will be null if it's an npc, so they're skipped
			src.sims.Life()

		if (prob(1) && prob(5))
			src.handle_random_emotes()

		if (src.organHolder?.chest?.op_stage > 0 && !src.chest_cavity_clamped && prob(10)) //Going around with a gaping unsutured wound is a bad idea
			take_bleeding_damage(src, null, rand(5, 10))

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

	for (var/obj/item/parts/robot_parts/part in src.contents)
		part.on_life(src)

	if (metalman_skin && prob(1))
		var/msg = pick("can't see...","feels bad...","leave me...", "you're cold...", "unwelcome...")
		src.show_text(voidSpeak(msg))

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

/mob/living/silicon/drone/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1
	//hud.update_health()
	if (hud)
		hud.update_charge()
		hud.update_tools()

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
			src.visible_message(SPAN_ALERT("<b>[src] [idle_message]!</b>"))

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

	proc/update_sight()
		var/datum/lifeprocess/L = lifeprocesses?[/datum/lifeprocess/sight]
		if (L)
			L.Process()

	update_canmove()
		// update buckled
		if (src.buckled)
			if (src.buckled.loc != src.loc)
				if(istype(src.buckled, /obj/stool))
					src.buckled.unbuckle()
					src.buckled.buckled_guy = null
				src.buckled = null
				return
			src.set_density(initial(src.density))
		else if (src.can_lie)
			src.set_density(src.lying ? FALSE : initial(src.density))

		// update canmove
		if (HAS_ATOM_PROPERTY(src, PROP_MOB_CANTMOVE))
			src.canmove = 0
			return

		if (src.buckled?.anchored)
			if (istype(src.buckled, /obj/stool/chair)) //this check so we can still rotate the chairs on their slower delay even if we are anchored
				var/obj/stool/chair/chair = src.buckled
				if (!chair.rotatable)
					src.canmove = FALSE
					return
			else
				src.canmove = FALSE
				return

		if (src.throwing & (THROW_CHAIRFLIP | THROW_GUNIMPACT | THROW_SLIP))
			src.canmove = FALSE
			return

		src.canmove = TRUE

	force_laydown_standup() //immediately force a laydown
		if(!lifeprocesses)
			return
		var/datum/lifeprocess/L = lifeprocesses?[/datum/lifeprocess/stuns_lying]
		if (L)
			L.Process()
		src.update_canmove()
		L = lifeprocesses?[/datum/lifeprocess/blindness]
		if (L)
			L.Process()

		if (src.client)
			updateOverlaysClient(src.client)
		if (length(src.observers))
			for (var/mob/x in src.observers)
				if (x.client)
					src.updateOverlaysClient(x.client)


	handle_stamina_updates()
		if (stamina == STAMINA_NEG_CAP)
			setStatusMin("unconscious", STAMINA_NEG_CAP_STUN_TIME)

		//Modify stamina.
		var/stam_time_passed = max(tick_spacing, TIME - last_stam_change)

		var/final_mod = (max(1, src.stamina_regen + GET_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS))) * (stam_time_passed / tick_spacing)
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


/mob/living/carbon/human

	proc/get_disease_protection(var/ailment_path=null, var/ailment_name=null)
		if (!src)
			return 100

		var/resist_prob = 0

		if (ispath(ailment_path) || (ailment_name && istext(ailment_name)))
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


	// unused???
	proc/get_fire_protection(temp)
		if (head)
			if (head.protective_temperature > temp)
				. += (head.protective_temperature/10)
		if (wear_mask)
			if (wear_mask.protective_temperature > temp)
				. += (wear_mask.protective_temperature/10)
		if (glasses)
			if (glasses.protective_temperature > temp)
				. += (glasses.protective_temperature/10)
		if (ears)
			if (ears.protective_temperature > temp)
				. += (ears.protective_temperature/10)
		if (wear_suit)
			if (wear_suit.protective_temperature > temp)
				. += (wear_suit.protective_temperature/10)
		if (w_uniform)
			if (w_uniform.protective_temperature > temp)
				. += (w_uniform.protective_temperature/10)
		if (gloves)
			if (gloves.protective_temperature > temp)
				. += (gloves.protective_temperature/10)
		if (shoes)
			if (shoes.protective_temperature > temp)
				. += (shoes.protective_temperature/10)
