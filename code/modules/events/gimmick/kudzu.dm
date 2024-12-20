#define KUDZU_TO_SPREAD_INITIAL 40
/obj/item/kudzuseed//TODO: Move all this to respective files everything works right.
	name = "kudzu seed"
	desc = "So this is where Kudzu went. Plant on a floor to grow.<br/>The disclaimer seems faded out, though."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "seeds-kudzu"
	var/to_spread = KUDZU_TO_SPREAD_INITIAL

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(ishuman( target ))
			if( user == target )
				boutput(user, "You feed yourself the [src]. [SPAN_ALERT("Oh god!")]")
			else
				boutput(user, "You feed [target] the [src]. [SPAN_ALERT("Oh god!")]")
			animate(target, color = "#0F0", time = 300)//TODO: See below.
			qdel(src)
			return

	afterattack(var/atom/A as mob|turf, var/mob/user as mob, reach, params)
		if(isturf( A ))
			//var/obj/spacevine/kudzu = new( A )
			//kudzu.Life()
			if (prob(1))
				new /obj/spacevine/alien/living(A, src.to_spread)
			else
				new /obj/spacevine/living(A, src.to_spread)

			boutput(user, "You plant the [src] on the [A].")
			logTheThing(LOG_STATION, user, "plants [src] (kudzu) at [log_loc(src)].")
			user.setStatus("kudzuwalk", INFINITE_STATUS)
			message_admins("[key_name(user)] planted kudzu at [log_loc(src)].")
			message_ghosts("<b>Kudzu</b> has been planted at [log_loc(src.loc, ghostjump=TRUE)].")
			user.u_equip(src)
			qdel(src)

		else
			return ..()

/datum/random_event/major/kudzu
	name = "Kudzu Outbreak"
	centcom_headline = "Plant Outbreak"
	centcom_message = "Rapidly expanding plant organism detected aboard the station. All personnel must contain the outbreak."
	centcom_origin = ALERT_STATION
	message_delay = 2 MINUTES
	wont_occur_past_this_time = 40 MINUTES
	customization_available = 1
	disabled = 1

	event_effect(var/source, var/aggressive, var/startturf)
		..()
		if (!landmarks[LANDMARK_KUDZUSTART] && !isturf(startturf))
			message_admins("Error starting event, no kudzu start landmarks. Process aborted.")
			return
		var/kudzloc = isturf(startturf) ? startturf : pick_landmark(LANDMARK_KUDZUSTART)
		if (prob(1) || aggressive)
			var/obj/spacevine/alien/living/L = new /obj/spacevine/alien/living(kudzloc, KUDZU_TO_SPREAD_INITIAL)
			if(!QDELETED(L))
				L.set_loc(kudzloc)
		else
			var/obj/spacevine/living/L = new /obj/spacevine/living(kudzloc, KUDZU_TO_SPREAD_INITIAL)
			if(!QDELETED(L))
				L.set_loc(kudzloc)

	admin_call(var/source)
		if (..())
			return

		var/aggressive = input(usr,"Aggressive?", src.name) as null|anything in list("Normal", "Aggressive")
		if (isnull(aggressive))
			return
		if (aggressive == "Normal")
			aggressive = 0
		else
			aggressive = 1
		var/startturf = input(usr,"Starting point?",src.name) as null|anything in list("Random (kudzustart)","My Location","XYZ")
		if (isnull(startturf))
			return
		switch(startturf)
			if ("Random (kudzustart)")
				startturf = 0
			if ("My Location")
				startturf = get_turf(usr)
			if ("XYZ")
				var/ecoords = input(usr,"Enter X,Y,Z:",src.name) as null|text
				if (isnull(ecoords))
					return
				var/list/coords = splittext(ecoords, ",")
				if (length(coords) < 3)
					return
				startturf = locate(text2num(coords[1]), text2num(coords[2]), text2num(coords[3]))

		src.event_effect(source,aggressive,startturf)
		return

/obj/spacevine
	name = "space kudzu"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/obj/objects.dmi'
	icon_state = "vine-light1"
	anchored = ANCHORED
	density = 0
	event_handler_flags = USE_FLUID_ENTER
	var/static/ideal_temp = 310		//same as blob, why not? I have no other reference point.
	var/growth = 0
	var/waittime = 40
	var/run_life = 0 // I think we have some that spawns on the map so don't just default to growy stuff
	var/base_state = "vine"
	var/vinepath = /obj/spacevine/living
	var/current_stage = 0
	var/aggressive = 0
	var/to_spread = 10				//bascially the radius of child kudzu plants that any given kudzu object can create.
	var/stunted = FALSE


	get_desc()
		var/flavor
		switch (to_spread)
			if (-INFINITY to 0)	flavor = "dormant"
			if (1 to 10) 		flavor = "lethargic"
			if (11 to 20)		flavor = "lively"
			if (21 to INFINITY) flavor = "vivacious"
		return "[..()] It looks [flavor]."

	Cross(atom/A)
		//kudzumen can pass through dense kudzu
		if (current_stage == 3)
			if (ishuman(A) &&  istype(A:mutantrace, /datum/mutantrace/kudzu) || A.hasStatus("kudzuwalk"))
				animate_door_squeeze(A)
				return 1
			return 0
		return 1

	New(turf/loc, var/to_spread = KUDZU_TO_SPREAD_INITIAL)
		src.to_spread = to_spread
		var/turf/T = get_turf(loc)
		if (istype(T, /turf/space))
			qdel(src)
			return 1
		else if (T)
			T.temp_flags |= HAS_KUDZU

			src.update_self()
			if (src.run_life)
				var/datum/controller/process/kudzu/K = get_master_kudzu_controller()
				if (K)
					K.kudzu += src
		..()

	set_loc(var/newloc as turf|mob|obj in world)
		if (istype(newloc, /turf/space))
			qdel(src)
			return 1
		..()
		//Add kudzu flag to new turf.
		var/turf/T2 = get_turf(newloc)
		if (T2)
			T2.temp_flags |= HAS_KUDZU

	Move()
		var/turf/T = get_turf(src)
		T.temp_flags &= ~HAS_KUDZU
		. = ..()

	disposing()
		var/turf/T = get_turf(src)
		T.temp_flags &= ~HAS_KUDZU
		var/datum/controller/process/kudzu/K = get_master_kudzu_controller()
		if (K)
			K.kudzu -= src
		var/obj/machinery/door/D = locate(/obj/machinery/door) in T.contents
		if (D)
			D.locked = 0
		..()

	attackby(obj/item/W, mob/user)
		if (!W) return
		if (!user) return
		var/dmg = 1
		if (W.hit_type == DAMAGE_CUT || W.hit_type == DAMAGE_BURN)
			dmg = 3
		else if (W.hit_type == DAMAGE_STAB)
			dmg = 2
		else if (W.hit_type == DAMAGE_BLUNT && istype(W, /obj/item/kudzu/kudzumen_vine))
			return

		dmg *= isnum(W.force) ? min((W.force / 2), 5) : 1
		DEBUG_MESSAGE("[user] damaging [src] with [W] [log_loc(src)]: dmg is [dmg]")

		src.take_damage(dmg, "brute", user)

		user.lastattacked  = src
		..()

/obj/spacevine/proc/update_self()
	switch(src.growth)
		if (-INFINITY to 9)
			if (src.current_stage == 1)
				return
			src.current_stage = 1
			src.name = initial(src.name)
			src.icon_state = "[src.base_state]-light[rand(1,3)]"
			src.set_opacity(0)
			src.set_density(0)
		if (10 to 19)
			if (src.current_stage == 2)
				return
			src.current_stage = 2
			src.name = "thick [initial(src.name)]"
			src.icon_state = "[src.base_state]-med[rand(1,3)]"
			src.set_opacity(1)
			src.set_density(0)
		if (20 to INFINITY)
			if (src.current_stage == 3)
				return
			src.current_stage = 3
			src.name = "dense [initial(src.name)]"
			src.icon_state = "[src.base_state]-hvy[rand(1,3)]"
			src.set_opacity(1)
			src.set_density(1)

/obj/spacevine/proc/Life()
	if (!src || to_spread <= 0)
		return
	if (!ispath(src.vinepath))
		var/datum/controller/process/kudzu/K = get_master_kudzu_controller()
		if (K)
			K.kudzu -= src
		return
	var/Vspread
	if (prob(50))
		Vspread = locate(src.x + rand(-1,1),src.y,src.z)
	else
		Vspread = locate(src.x,src.y + rand(-1, 1),src.z)

	if (src.growth < 20 && !stunted)
		src.growth++
		src.update_self()
	if (!src.aggressive && src.growth >= 20)
		var/datum/controller/process/kudzu/K = get_master_kudzu_controller()
		if (K)
			K.kudzu -= src

	var/spread_vines = TRUE

	if (!istype(Vspread, /turf/simulated/floor) || isfeathertile(Vspread))
		spread_vines = FALSE
		return

	for (var/obj/O in Vspread)
		if (istype(O, /obj/window) || istype(O, /obj/blob) || istype(O, /obj/spacevine) || istype(O, /obj/kudzu_marker))
			spread_vines = FALSE
			return
		if (istype(O, /obj/forcefield) && O.density) //atmos and fluid fields shouldn't block
			spread_vines = FALSE
			return
		if (istype(O, /obj/machinery/door))
			var/obj/machinery/door/door = O
			if(!door.density)
				spread_vines = TRUE
				continue
			if (door_open_prob())
				door.interrupt_autoclose = TRUE //force open doors
				door.open()
				spread_vines = TRUE //for clarity
			else
				spread_vines = FALSE

	if (spread_vines)
		var/obj/V = new src.vinepath(loc=Vspread, to_spread=to_spread-1)
		if(!QDELETED(V))
			V.set_loc(Vspread)
		return

/obj/spacevine/proc/door_open_prob()
	//door integrity starts at 0. Bolting/welding/shocking increases how well it stands up to kudzu
	var/door_integrity = 0
	if (istype(src, /obj/machinery/door/airlock))	//pretty sure you can only weld airlocks, but they are most of the doors anyway
		var/obj/machinery/door/airlock/AL = src
		if (AL.welded)
			door_integrity++
		if (AL.locked)
			door_integrity++
		if (AL.isElectrified())
			door_integrity++
		if (src.aggressive)
			door_integrity--

		//Based on door integrity, return the probability (0-100) that the kudzu will breach the door.
		switch (door_integrity)
			if (1)
				return 50
			if (2)
				return 25
			if (3)
				return 0
		return 90
	return 90

/obj/spacevine/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if (prob(66))
				qdel(src)
				return
		if(3)
			if (prob(33))
				qdel(src)
				return

/obj/spacevine/proc/take_damage(var/amount, var/damtype = "brute",var/mob/user)
	if (!isnum(amount) || amount <= 0)
		return

	src.growth -= amount
	if (src.growth < 1)
		qdel (src)
	else
		src.update_self()


/obj/spacevine/temperature_expose(datum/gas_mixture/air, temperature, volume)
	var/temp_diff = temperature - src.ideal_temp

	if (temp_diff >= 300)
		var/power = max(round(temp_diff /300), 5)

		src.take_damage(power*10, 1, "burn")

/obj/spacevine/proc/herbicide(datum/reagent/R)
	if(!src.stunted)
		if((src.current_stage < 2) || prob(33))
			src.stunted = TRUE

			//Swap green to red to turn brown, desaturate and soften slightly
			var/new_color = list(0.20,	0.70,  0.10,  0.00,\
								 0.70,  0.10,  0.10,  0.50,\
								 0.07,  0.10,  0.50,  0.00,\
								 0.00,  0.00,  0.00,  0.70,\
								 0.00,  0.00,  0.00,  0.00)
			//Add damage texture to create dark banding
			setTexture("damaged")
			animate(src,time=2 SECONDS,color=new_color)
			src.growth -= 10
			src.to_spread = round(log(max(src.to_spread,1))*2)
			src.update_self()
		// Delay update to allow fluid controllers to manage
		R.holder?.remove_reagent(R.id, src.current_stage, update_total=FALSE, reagents_change=FALSE)

/obj/spacevine/living // these ones grow
	run_life = 1

/obj/spacevine/alien
	name = "strange alien vine"
	icon_state = "avine-light1"
	base_state = "avine"
	vinepath = /obj/spacevine/alien/living
	aggressive = 1

	New(turf/loc, var/to_spread = KUDZU_TO_SPREAD_INITIAL)
		if (..(loc, to_spread))
			return 1
		SPAWN(0)
			if (prob(20) && !locate(/obj/spacevine/alien/flower) in get_turf(src))
				var/obj/spacevine/alien/flower/F = new /obj/spacevine/alien/flower()
				if(!QDELETED(F))
					F.set_loc(src.loc)

	herbicide()
		return

/obj/spacevine/alien/living
	run_life = 1

/obj/spacevine/alien/flower
	name = "strange alien flower"
	desc = "Is it going to eat you if you get too close?"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "alienflower"

	New()
		if (..())
			return 1
		src.set_dir(pick(alldirs))
		src.pixel_y += rand(-8,8)
		src.pixel_x += rand(-8,8)

	update_self()
		return

/proc/get_master_kudzu_controller()
	for (var/datum/controller/process/kudzu/K in processScheduler.processes)
		return K
	return null

//For making kudzumen
/obj/icecube/kudzu
	name = "vine cocoon"
	desc = "That is a cocoon of vines."
	icon = 'icons/misc/kudzu_plus.dmi'
	icon_state = "cocoon"
	health = 10
	steam_on_death = 0
	var/const/bulb_time = 20 SECONDS		//how long it takes a bulb to form
	var/const/bulb_complete = 40 SECONDS	//how long the bulb takes to open once spawned. Total time in object is bulb_time + bulb_complete
	var/natural_opening = 0							//for flavor text.
	var/destroyed = 0
	add_underlay = 0
	health = 20
	melttemp = 1000 //arbitrarily big number

	New(loc, mob/M as mob)
		..()
		if (ishuman(M))
			SPAWN(bulb_time)
				if (src)
					name = "huge bulb"
					desc = "A huge botanical bulb. It looks like there's something inside it..."
					icon_state = "bulb-closed"

				sleep(bulb_complete)

				if(!isalive(M) && M.ghost?.mind?.get_player()?.dnr)
					src.visible_message(SPAN_ALERT("The [src] opens, having drained all the nutrients from [M]!"))
					M.gib()
					flick("bulb-open-animation", src)
					new/obj/decal/opened_kudzu_bulb(get_turf(src))
					SPAWN(1 SECOND)
						qdel(src)

				else if (!destroyed && ishuman(M))
					var/mob/living/carbon/human/H = M
					flick("bulb-open-animation", src)
					new/obj/decal/opened_kudzu_bulb(get_turf(src.loc))
					if(H in src)
						H.full_heal()
						if (!H.ckey && H.last_client && !H.last_client.mob.mind.get_player()?.dnr)
							if (!istype(H.last_client.mob,/mob/living) || inafterlifebar(H.last_client.mob))
								H.ckey = H.last_client.ckey
						if (istype(H.abilityHolder, /datum/abilityHolder/composite))
							var/datum/abilityHolder/composite/Comp = H.abilityHolder
							Comp.removeHolder(/datum/abilityHolder/kudzu)
						else if (H.abilityHolder)
							H.abilityHolder.dispose()
							H.abilityHolder = null
						H.set_mutantrace(/datum/mutantrace/kudzu)
						H.show_antag_popup("kudzu")
					natural_opening = 1
					qdel(src)
		else
			qdel(src)

	disposing()
		destroyed = 1
		if (natural_opening)
			src.visible_message(SPAN_ALERT("[src] puffs and it opens wide revealing what's inside!"))
		else
			for (var/mob/M in contents)
				M.take_toxin_damage(60)

		..()
		return

/obj/decal/opened_kudzu_bulb
	name = "open bulb"
	desc = "A huge open bulb."
	icon = 'icons/misc/64x32.dmi'
	icon_state = "kudzu_bulb-open"
	density = 0
	opacity = 0
	pixel_x = -16
	layer = MOB_LAYER - 1
	anchored = ANCHORED

	attackby(obj/item/W, mob/user)
		if (iscuttingtool(W))
			src.visible_message(SPAN_ALERT("[user] cuts [src] to bits!"))
			qdel(src)
		..()
	//destroy if attacked by wirecutters or something


#undef KUDZU_TO_SPREAD_INITIAL
