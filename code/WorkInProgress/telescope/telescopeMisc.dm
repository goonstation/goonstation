var/datum/telescope_manager/tele_man
var/list/special_places = list() //list of location names, which are coincidentally also landmark ids

var/list/magnet_locations = list()

/obj/machinery/lrteleporter
	name = "Experimental long-range teleporter"
	desc = "Well this looks somewhat unsafe."
	icon = 'icons/misc/32x64.dmi'
	icon_state = "lrport"
	density = 0
	anchored = 1
	flags = FPRINT | CONDUCT | TGUI_INTERACTIVE
	var/busy = 0
	layer = 2
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER

	New()
		..()
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send", .proc/mechcompsend)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"receive", .proc/mechcompreceive)

	attack_ai(mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		ui_interact(user)
		add_fingerprint(user)

	proc/mechcompsend(var/datum/mechanicsMessage/input)
		if(!input)
			return
		lrtsend(input.signal)

	proc/mechcompreceive(var/datum/mechanicsMessage/input)
		if(!input)
			return
		lrtreceive(input.signal)

	proc/is_good_location(var/place)
		if(special_places.len)
			for(var/A in special_places)
				if (place == A)
					return 1

			return 0
		else
			return 0

	proc/lrtsend(var/place)
		if (place && src.is_good_location(place))
			var/turf/target = null
			for(var/turf/T in landmarks[LANDMARK_LRT])
				var/name = landmarks[LANDMARK_LRT][T]
				if(name == place)
					target = T
					break
			if (!target) //we didnt find a turf to send to
				return 0
			src.busy = 1
			flick("lrport1", src)
			playsound(src, 'sound/machines/lrteleport.ogg', 60, 1)
			for(var/atom/movable/M in src.loc)
				if(M.anchored)
					continue
				animate_teleport(M)
				if(ismob(M))
					var/mob/O = M
					O.changeStatus("stunned", 2 SECONDS)
				SPAWN(6 DECI SECONDS) M.set_loc(target)
			SPAWN(1 SECOND) busy = 0
			return 1
		return 0

	proc/lrtreceive(var/place)
		if (place && src.is_good_location(place))
			var/turf/target = null
			for(var/turf/T in landmarks[LANDMARK_LRT])
				var/name = landmarks[LANDMARK_LRT][T]
				if(name == place)
					target = T
					break
			if (!target) //we didnt find a turf to send to
				return 0
			src.busy = 1
			flick("lrport1", src)
			playsound(src, 'sound/machines/lrteleport.ogg', 60, 1)
			for(var/atom/movable/M in target)
				if(M.anchored)
					continue
				animate_teleport(M)
				if(ismob(M))
					var/mob/O = M
					O.changeStatus("stunned", 2 SECONDS)
				SPAWN(6 DECI SECONDS) M.set_loc(src.loc)
			SPAWN(1 SECOND) busy = 0
			return 1
		return 0

/obj/machinery/lrteleporter/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LongRangeTeleporter", name)
		ui.open()

/obj/machinery/lrteleporter/ui_data(mob/user)
	var/list/destinations = list()
	for(var/A in special_places)
		destinations += list(list(
			"destination" = "[A]",
			"ref" = null))

	. = list(
		"destinations" = destinations
	)

/obj/machinery/lrteleporter/ui_static_data(mob/user)
	. = list(
		"send_allowed" = TRUE,
		"receive_allowed" = TRUE,
		"syndicate" = FALSE
	)

/obj/machinery/lrteleporter/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(busy) return
	if(!in_interact_range(src, usr) || usr.z != src.z) return

	switch(action)
		if("send")
			var/place = params["name"]
			src.lrtsend(place)

		if("receive")
			var/place = params["name"]
			src.lrtreceive(place)

//////////////////////////////////////////////////
/datum/telescope_manager
	var/list/events_inactive = list() //Events that are currently not visible but might show up.
	var/list/events_active = list()	  //Events that are currently visible but not found.
	var/list/events_found = list()    //Events that are currently visible AND found.

	proc/setup()
		var/types = childrentypesof(/datum/telescope_event)
		for(var/x in types)
			var/datum/telescope_event/R = new x(src)
			if(R.manual) continue
			events_inactive.Add(R.id)
			events_inactive[R.id] = R
			if(!R.fixed_location)
				R.loc_x = rand(0, 640)
				R.loc_y = rand(0, 431)
		return

	proc/tick()
		if(events_active.len < 3)

			var/can_spawn = 0 //If there's only events with less than 100% rarity left, we don't spawn anything.
			//This is to stop the system from spawning only rare events when there's few left.

			for(var/I in events_inactive)
				var/datum/telescope_event/EI = events_inactive[I]
				if(EI.disabled) continue
				if(EI.rarity >= 100)
					can_spawn = 1
					break

			if(can_spawn && events_inactive.len && prob(33))

				var/list/choices = list()
				var/list/weights = list()

				for(var/A in events_inactive)
					var/datum/telescope_event/E = events_inactive[A]
					if(E.disabled) continue
					choices.Add(A)
					weights.Add(E.rarity)

				var/chosen_id = weightedprob(choices, weights)
				var/datum/telescope_event/T = events_inactive[chosen_id]

				if(T)
					events_active.Add(T.id)
					events_active[T.id] = T
					events_inactive.Remove(T.id)
		return

	proc/addManualEvent(var/eventType = null, var/active=1)
		if(ispath(eventType, /datum/telescope_event))
			var/datum/telescope_event/E = new eventType(src)
			if(!E.fixed_location)
				E.loc_x = rand(0, 640)
				E.loc_y = rand(0, 431)
			if(active)
				if(!(E.id in events_active))
					events_active.Add(E.id)
					events_active[E.id] = E
			else
				if(!(E.id in events_inactive))
					events_inactive.Add(E.id)
					events_inactive[E.id] = E
			return E
		else
			return null


///MISC EVENT ETC RELATED BELOW
/obj/critter/gunbot/drone/buzzdrone/naniteswarm
	name = "nanite swarm"
	desc = "A swarm of angry nanites."
	icon_state = "nanites"
	dead_state = "nanites-dead"
	icon = 'icons/misc/critter.dmi'
	health = 30
	maxhealth = 30
	score = 1
	projectile_type = /datum/projectile/laser/drill/cutter
	current_projectile = new/datum/projectile/laser/drill/cutter
	droploot = null
	smashes_shit = 1

	ChaseAttack(atom/M)
		if(target && !attacking)
			attacking = 1
			src.visible_message("<span class='alert'><b>[src]</b> floats towards [M]!</span>")
			walk_to(src, src.target,1,4)
			var/tturf = get_turf(M)
			Shoot(tturf, src.loc, src)
			SPAWN(attack_cooldown)
				attacking = 0
		return

	CritterAttack(atom/M)
		if(target && !attacking)
			attacking = 1
			//playsound(src.loc, "sound/machines/whistlebeep.ogg", 55, 1)
			src.visible_message("<span class='alert'><b>[src]</b> shreds [M]!</span>")

			var/tturf = get_turf(M)
			Shoot(tturf, src.loc, src)
			SPAWN(attack_cooldown)
				attacking = 0
		return

	New()
		..()
		name = "Nanite Swarm Cluster NN-[rand(1,999)]"
		return

	CritterDeath()
		if(prob(20) && alive)
			src.visible_message("<span class='alert'><b>[src]</b> begins to reassemble!</span>")
			var/turf/T = src.loc
			SPAWN(5 SECONDS)
				new/obj/critter/gunbot/drone/buzzdrone/naniteswarm(T)
				if(src)
					qdel(src)

		if(prob(1) && alive)
			new/obj/item/material_piece/iridiumalloy(src.loc)

		..()
