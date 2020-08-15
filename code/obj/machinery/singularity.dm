/*
Contains:
-Singularity generator
-Singularity
-Field generator & containment field
-Emitter
-Collector array & controller
-Singularity bomb
*/
// I came here with good intentions, I swear, I didn't know what this code was like until I was already waist deep in it
#define SINGULARITY_TIME 11
// I'm sorry
//////////////////////////////////////////////////// Singularity generator /////////////////////

/obj/machinery/the_singularitygen/
	name = "Gravitational Singularity Generator"
	desc = "An Odd Device which produces a Black Hole when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = 0 // so it can be moved around out of crates
	density = 1
	mats = 250
	var/bhole = 0 // it is time. we can trust people to use the singularity For Good - cirr
/* no
/obj/machinery/the_singularitygen/New()
	..()
*/
/obj/machinery/the_singularitygen/process()
	var/checkpointC = 0
	for (var/obj/X in orange(4,src))
		if (istype(X, /obj/machinery/containment_field))
			checkpointC ++
	if (checkpointC >= 20)

		// Did you know this thing still works? And wasn't logged (Convair880)?
		logTheThing("bombing", src.fingerprintslast, null, "A [src.name] was activated, spawning a singularity at [log_loc(src)]. Last touched by: [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"]")
		message_admins("A [src.name] was activated, spawning a singularity at [log_loc(src)]. Last touched by: [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"]")

		var/turf/T = src.loc
		playsound(T, 'sound/machines/satcrash.ogg', 100, 0, 3, 0.8)
		if (src.bhole)
			new /obj/bhole(T, 3000)
		else
			new /obj/machinery/the_singularity(T, 100)
		qdel(src)

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user)
	src.add_fingerprint(user)
	if (iswrenchingtool(W))
		if (!anchored)
			anchored = 1
			playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
			boutput(user, "You secure the [src.name] to the floor.")
			src.anchored = 1
		else if (anchored)
			anchored = 0
			playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
			boutput(user, "You unsecure the [src.name].")
			src.anchored = 0

		logTheThing("station", user, null, "[src.anchored ? "bolts" : "unbolts"] a [src.name] [src.anchored ? "to" : "from"] the floor at [log_loc(src)].") // Ditto (Convair880).
		return
	else
		return ..()

//////////////////////////////////////////////////// Singularity /////////////////////////////

/obj/machinery/the_singularity/
	name = "gravitational singularity"
	desc = "A Gravitational Singularity."

	icon = 'icons/effects/160x160.dmi'
	icon_state = "Sing2"
	anchored = 1
	density = 1
	event_handler_flags = IMMUNE_SINGULARITY
	deconstruct_flags = DECON_WELDER | DECON_MULTITOOL

	bound_width = 96
	bound_height = 96

	bound_x = -32
	bound_y = -32

	var/active = 0
	var/energy = 10
	var/warp = 5
	var/lastT = 0
	var/warp_delay = 30
	var/Dtime = null
	var/Wtime = 0
	var/dieot = 0
	var/selfmove = 1
	var/grav_pull = 6

#ifdef SINGULARITY_TIME
/*
hello I've lost my remaining sanity by dredging this code from the depths of hell where it was cast eons before I arrived in this place
for some reason I brought it back and tried to clean it up a bit and I regret everything but it's too late now I can't put it back please forgive me
- haine
*/
/obj/machinery/the_singularity/New(loc, var/E = 100, var/Ti = null)
	src.energy = E
	pixel_x = -64
	pixel_y = -64
	event()
	if (Ti)
		src.Dtime = Ti
	..()

/obj/machinery/the_singularity/process()
	eat()

	if (src.Dtime)//If its a temp singularity IE: an event
		if (Wtime != 0)
			if ((src.Wtime + src.Dtime) <= world.time)
				src.Wtime = 0
				qdel (src)
		else
			src.Wtime = world.time

	if (dieot)
		if (energy <= 0)//slowly dies over time
			qdel (src)
		else
			energy -= 15


	if (prob(20))//Chance for it to run a special event
		event()

	if (active == 1)
		move()
		SPAWN_DBG(1.1 SECONDS) // slowing this baby down a little -drsingh
			move()
	else
		var/checkpointC = 0
		for (var/obj/machinery/containment_field/X in orange(3,src))
			checkpointC ++
		if (checkpointC < 18)
			src.active = 1
			grav_pull = 8

/obj/machinery/the_singularity/proc/eat()
	for (var/X in orange(grav_pull, src.get_center()))
		LAGCHECK(LAG_LOW)
		if (!X)
			continue
		var/atom/A = X

		if (A.event_handler_flags & IMMUNE_SINGULARITY)
			continue

		if (!active)
			if (A.event_handler_flags & IMMUNE_SINGULARITY_INACTIVE)
				continue

		if (!isarea(X))
			if (get_dist(src.get_center(), X) <= 2) // why was this a switch before ffs
				src.Bumped(A)
				if (A && A.qdeled)
					A = null
					X = null
			else if (istype(X, /atom/movable))
				var/atom/movable/AM = X
				if (!AM.anchored)
					step_towards(AM, src)

/obj/machinery/the_singularity/proc/move()
	// if we're inside something (e.g posessed mob) dont move
	if (!isturf(src.loc))
		return

	if (selfmove)
		var/dir = pick(cardinal)

		var/checkloc = get_step(src,dir)
		for (var/dist = 0, dist < 3, dist ++)
			if (locate(/obj/machinery/containment_field) in checkloc)
				return
			checkloc = get_step(checkloc, dir)

		step(src, dir)

/obj/machinery/the_singularity/Bumped(atom/A)
	var/gain = 0

	if (A.event_handler_flags & IMMUNE_SINGULARITY)
		return
	if (!active)
		if (A.event_handler_flags & IMMUNE_SINGULARITY_INACTIVE)
			return

	if (isliving(A) && !isintangible(A))//if its a mob
		var/mob/living/L = A
		gain = 20
		if (ishuman(L))
			var/mob/living/carbon/human/H = A
			//Special halloween-time Unkillable gibspam protection!
			if (H.unkillable)
				H.unkillable = 0
			if (H.mind && H.mind.assigned_role)
				switch (H.mind.assigned_role)
					if ("Clown")
						// Hilarious.
						gain = 500
					if ("Lawyer")
						// Satan.
						gain = 250
					if ("Tourist", "Geneticist")
						// Nerds that are oblivious to dangers
						gain = 200
					if ("Chief Engineer")
						// Hubris
						gain = 150
					if ("Engineer", "Mechanic")
						// More hubris
						gain = 100
					if ("Staff Assistant", "Captain")
						// Worthless
						gain = 20
					else
						gain = 50

		L.gib()

	else if (isobj(A))
		//if (istype(A, /obj/item/graviton_grenade))
			//src.warp = 100

		if (istype(A, /obj/decal/cleanable)) //MBC : this check sucks, but its far better than cleanables doing hard-delete at the whims of the singularity. replace ASAP when i figure out cleanablessssss
			pool(A)
			gain = 2
		else
			var/obj/O = A
			O.ex_act(1.0)
			if (O)
				qdel(O)
			gain = 2

	else if (isturf(A))
		var/turf/T = A
		if (T.turf_flags & IS_TYPE_SIMULATED)
			if (istype(T, /turf/simulated/floor))
				T.ReplaceWithSpace()
				gain = 2
			else
				T.ReplaceWithFloor()

	src.energy += gain

/obj/machinery/the_singularity/proc/get_center()
	. = get_turf(src)
	. = get_step(., NORTHEAST)

/obj/machinery/the_singularity/attackby(var/obj/item/I as obj, var/mob/user as mob)
	if (istype(I, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/C = I
		if (!C.on)
			C.light(user, "<span class='alert'><b>[user]</b> lights [C] on [src]. Holy fucking shit!</span>")
		else
			return ..()
	else
		return ..()

// totally rewrote this proc from the ground-up because it was puke but I want to keep this comment down here vvv so we can bask in the glory of What Used To Be - haine
		/* uh why was lighting a cig causing the singularity to have an extra process()?
		   this is dumb as hell, commenting this. the cigarette will get processed very soon. -drsingh
		SPAWN_DBG(0) //start fires while it's lit
			src.process()
		*/

/////////////////////////////////////////////Controls which "event" is called
/obj/machinery/the_singularity/proc/event()
	var/numb = rand(1,4)
	switch (numb)
		if (1)//EMP
			Zzzzap()
			return
		if (2)//Eats the turfs around it
			BHolerip()
			return
		if (3)//tox damage all carbon mobs in area
			Toxmob()
			return
		if (4)//Stun mobs who lack optic scanners
			Mezzer()
			return

/obj/machinery/the_singularity/proc/Toxmob()

	for (var/mob/living/carbon/M in orange(7, src.get_center()))
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.wear_suit)
				return
		M.take_toxin_damage(3)
		M.changeStatus("radiation", 100)
		M.show_text("You feel odd.", "red")

/obj/machinery/the_singularity/proc/Mezzer()

	for (var/mob/living/carbon/M in oviewers(8, src.get_center()))
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (istype(H.glasses,/obj/item/clothing/glasses/meson))
				M.show_text("You look directly into [src.name], good thing you had your protective eyewear on!", "green")
				return
		M.changeStatus("stunned", 3 SECONDS)
		M.visible_message("<span class='alert'><B>[M] stares blankly at [src]!</B></span>",\
		"<B>You look directly into [src]!<br><span class='alert'>You feel weak!</span></B>")

/obj/machinery/the_singularity/proc/BHolerip()

	for (var/turf/T in orange(6, src.get_center()))
		LAGCHECK(LAG_LOW)
		if (prob(70))
			continue
		if (T && !(T.turf_flags & CAN_BE_SPACE_SAMPLE) && (get_dist(src.get_center(),T) == 4 || get_dist(src.get_center(),T) == 5)) // I'm very tired and this is the least dumb thing I can make of what was here for now
			if (T.turf_flags & IS_TYPE_SIMULATED)
				if (istype(T,/turf/simulated/floor) && !istype(T,/turf/simulated/floor/plating))
					var/turf/simulated/floor/F = T
					if (!F.broken)
						if (prob(80))
							new/obj/item/tile (F)
							F.break_tile_to_plating()
						else
							F.break_tile()
				else if (istype(T, /turf/simulated/wall))
					var/turf/simulated/wall/W = T
					if (istype(W, /turf/simulated/wall/r_wall) || istype(W, /turf/simulated/wall/auto/reinforced))
						new /obj/structure/girder/reinforced(W)
					else
						new /obj/structure/girder(W)
					var/obj/item/sheet/S = new /obj/item/sheet(W)
					if (W.material)
						S.setMaterial(W.material)
					else
						var/datum/material/M = getMaterial("steel")
						S.setMaterial(M)
					W.ReplaceWithFloor()
			else
				T.ReplaceWithFloor()
	return

/obj/machinery/the_singularity/proc/Zzzzap()///Pulled from wizard spells might edit later
	var/turf/T = src.get_center()

	var/obj/overlay/pulse = new/obj/overlay(T)
	pulse.icon = 'icons/effects/effects.dmi'
	pulse.icon_state = "emppulse"
	pulse.name = "emp pulse"
	pulse.anchored = 1
	SPAWN_DBG (20)
		if (pulse)
			qdel(pulse)

	for (var/mob/M in all_viewers(world.view-1, T))

		if (!isliving(M))
			continue

		//if (M == usr) // what
			//continue // what?????

		M.emp_act()

	for (var/obj/machinery/M in range(world.view-1, T))
		M.emp_act()
#endif

//////////////////////////////////////// Field generator /////////////////////////////////////////

/obj/machinery/field_generator
	name = "Field Generator"
	desc = "Projects an energy field when active"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "Field_Gen"
	anchored = 0
	density = 1
	req_access = list(access_engineering_engine)
	object_flags = CAN_REPROGRAM_ACCESS
	var/Varedit_start = 0
	var/Varpower = 0
	var/active = 0
	var/power = 20
	var/max_power = 250
	var/state = 0
	var/steps = 0
	var/last_check = 0
	var/check_delay = 10
	var/recalc = 0
	var/locked = 1
	//Remote control stuff
	var/net_id = null
	var/obj/machinery/power/data_terminal/link = null
	mats = 14


	proc/set_active(var/act)
		if (src.active != act)
			src.active = act
			if (src.active)
				event_handler_flags |= IMMUNE_SINGULARITY
			else
				event_handler_flags &= ~IMMUNE_SINGULARITY

/obj/machinery/field_generator/attack_hand(mob/user as mob)
	if(state == 3)
		if(!src.locked)
			if(src.active >= 1)
	//			src.active = 0
	//			icon_state = "Field_Gen"
				boutput(user, "You are unable to turn off the field generator, wait till it powers down.")
	//			src.cleanup()
			else
				set_active(1)
				icon_state = "Field_Gen +a"
				boutput(user, "You turn on the field generator.")
				logTheThing("station", user, null, "activated a [src.name] at [log_loc(src)].") // Hmm (Convair880).
		else
			boutput(user, "The controls are locked!")
	else
		boutput(user, "The field generator needs to be firmly secured to the floor first.")
	src.add_fingerprint(user)

/obj/machinery/field_generator/attack_ai(mob/user as mob)
	if(state == 3)
		if(src.active >= 1)
			boutput(user, "You are unable to turn off the field generator, wait till it powers down.")
		else
			src.set_active(1)
			icon_state = "Field_Gen +a"
			boutput(user, "You turn on the field generator.")
			logTheThing("station", user, null, "activated a [src.name] at [log_loc(src)].") // Hmm (Convair880).
	else
		boutput(user, "The field generator needs to be firmly secured to the floor first.")
	src.add_fingerprint(user)

/obj/machinery/field_generator/New()
	..()
	SPAWN_DBG(0.6 SECONDS)
		if(!src.link && (state == 3))
			src.get_link()

		src.net_id = format_net_id("\ref[src]")

/obj/machinery/field_generator/process()

	if(src.Varedit_start == 1)
		if(src.active == 0)
			src.set_active(1)
			src.state = 3
			src.power = 250
			src.anchored = 1
			icon_state = "Field_Gen +a"
		Varedit_start = 0

	if(src.active == 1)
		if(!src.state == 3)
			src.set_active(0)
			return
		setup_field(1)
		setup_field(2)
		setup_field(4)
		setup_field(8)
		src.set_active(2)
	if(src.power < 0)
		src.power = 0
	if(src.power > src.max_power)
		src.power = src.max_power
	if(src.active >= 1)
		src.power -= 1
		if(Varpower == 0)
			if(src.power <= 0)
				src.visible_message("<span class='alert'>The [src.name] shuts down due to lack of power!</span>")
				icon_state = "Field_Gen"
				src.set_active(0)
				src.cleanup(1)
				src.cleanup(2)
				src.cleanup(4)
				src.cleanup(8)

/obj/machinery/field_generator/proc/setup_field(var/NSEW = 0)
	var/turf/T = src.loc
	var/turf/T2 = src.loc
	var/obj/machinery/field_generator/G
	var/steps = 0
	var/oNSEW = 0

	if(!NSEW)//Make sure its ran right
		return

	if(NSEW == 1)
		oNSEW = 2
	else if(NSEW == 2)
		oNSEW = 1
	else if(NSEW == 4)
		oNSEW = 8
	else if(NSEW == 8)
		oNSEW = 4

	for(var/dist = 0, dist <= 9, dist += 1) // checks out to 8 tiles away for another generator
		T = get_step(T2, NSEW)
		T2 = T
		steps += 1
		if(locate(/obj/machinery/field_generator) in T)
			G = (locate(/obj/machinery/field_generator) in T)
			steps -= 1
			if(!G.active)
				return
			G.cleanup(oNSEW)
			break

	if(isnull(G))
		return

	T2 = src.loc

	for(var/dist = 0, dist < steps, dist += 1) // creates each field tile
		var/field_dir = get_dir(T2,get_step(T2, NSEW))
		T = get_step(T2, NSEW)
		T2 = T
		var/obj/machinery/containment_field/CF = new/obj/machinery/containment_field/(src, G) //(ref to this gen, ref to connected gen)
		CF.set_loc(T)
		CF.dir = field_dir

//Create a link with a data terminal on the same tile, if possible.
/obj/machinery/field_generator/proc/get_link()
	if(src.link)
		src.link.master = null
		src.link = null
	var/turf/T = get_turf(src)
	var/obj/machinery/power/data_terminal/test_link = locate() in T
	if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
		src.link = test_link
		src.link.master = src

	return

/obj/machinery/field_generator/bullet_act(var/obj/projectile/P)
	if(!P)
		return
	if(!P.proj_data)
		return
	if(P.proj_data.damage_type == D_ENERGY)
		src.power += P.power

/obj/machinery/field_generator/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		if(active)
			boutput(user, "Turn off the field generator first.")
			return

		else if(state == 0)
			state = 1
			playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
			boutput(user, "You secure the external reinforcing bolts to the floor.")
			src.anchored = 1
			return

		else if(state == 1)
			state = 0
			playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
			boutput(user, "You undo the external reinforcing bolts.")
			src.anchored = 0
			return

	if(isweldingtool(W))

		var/turf/T = user.loc

		if(state == 1)
			if(!W:try_weld(user, 1, noisy = 2))
				return
			boutput(user, "You start to weld the field generator to the floor.")
			sleep(2 SECONDS)

			if ((user.loc == T && user.equipped() == W))
				state = 3
				boutput(user, "You weld the field generator to the floor.")
				src.get_link() //Set up a link, now that we're secure!
			else if((isrobot(user) && (user.loc == T)))
				state = 3
				boutput(user, "You weld the field generator to the floor.")
				src.get_link()
			return

		if(state == 3)
			if(!W:try_weld(user, 1, noisy = 2))
				return
			boutput(user, "You start to cut the field generator free from the floor.")
			sleep(2 SECONDS)

			if ((user.loc == T && user.equipped() == W))
				state = 1
				if(src.link) //Clear active link.
					src.link.master = null
					src.link = null
				boutput(user, "You cut the field generator free from the floor.")
			else if((isrobot(user) && (user.loc == T)))
				state = 1
				if(src.link) //Clear active link.
					src.link.master = null
					src.link = null
				boutput(user, "You cut the field generator free from the floor.")
			return

	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card
	if (istype(W, /obj/item/card/id))
		if (src.allowed(user))
			src.locked = !src.locked
			boutput(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
		else
			boutput(user, "<span class='alert'>Access denied.</span>")

	else
		src.add_fingerprint(user)
		boutput(user, "<span class='alert'>You hit the [src.name] with your [W.name]!</span>")
		for(var/mob/M in AIviewers(src))
			if(M == user)	continue
			M.show_message("<span class='alert'>The [src.name] has been hit with the [W.name] by [user.name]!</span>")

/obj/machinery/field_generator/proc/cleanup(var/NSEW)
	var/obj/machinery/containment_field/F
	var/obj/machinery/field_generator/G
	var/turf/T = src.loc
	var/turf/T2 = src.loc

	for(var/dist = 0, dist <= 9, dist += 1) // checks out to 8 tiles away for fields
		T = get_step(T2, NSEW)
		T2 = T
		if(locate(/obj/machinery/containment_field) in T)
			F = (locate(/obj/machinery/containment_field) in T)
			qdel(F)

		if(locate(/obj/machinery/field_generator) in T)
			G = (locate(/obj/machinery/field_generator) in T)
			if(!G.active)
				break

//Send a signal over our link, if possible.
/obj/machinery/field_generator/proc/post_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
	if(!src.link || !target_id)
		return

	var/datum/signal/signal = get_free_signal()
	signal.source = src
	signal.transmission_method = TRANSMISSION_WIRE
	signal.data[key] = value
	if(key2)
		signal.data[key2] = value2
	if(key3)
		signal.data[key3] = value3

	signal.data["address_1"] = target_id
	signal.data["sender"] = src.net_id

	src.link.post_signal(src, signal)

//What do we do with an incoming command?
/obj/machinery/field_generator/receive_signal(datum/signal/signal)
	if(!src.link)
		return
	if(!signal || !src.net_id || signal.encryption)
		return

	/* People might abuse this but I find it funny
	if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
		return
	*/

	var/target = signal.data["sender"]

	//They don't need to target us specifically to ping us.
	//Otherwise, ff they aren't addressing us, ignore them
	if(signal.data["address_1"] != src.net_id)
		if((signal.data["address_1"] == "ping") && signal.data["sender"])
			SPAWN_DBG(0.5 SECONDS) //Send a reply for those curious jerks
				src.post_status(target, "command", "ping_reply", "device", "PNET_ENG_FIELD", "netid", src.net_id)

		return

	var/sigcommand = lowertext(signal.data["command"])
	if(!sigcommand || !signal.data["sender"])
		return

	//Oh okay, time to start up.
	if(sigcommand == "activate" && !src.active)
		src.set_active(1)
		icon_state = "Field_Gen +a"

	if(sigcommand == "deactivate" && src.active)
		src.set_active(0)
		icon_state = "Field_Gen"

	return

/obj/machinery/field_generator/disposing()
	src.cleanup(1)
	src.cleanup(2)
	src.cleanup(4)
	src.cleanup(8)
	if (link)
		link.master = null
		link = null
	..()

/////////////////////////////////////////////// Containment field //////////////////////////////////

/obj/machinery/containment_field
	name = "Containment Field"
	desc = "An energy field."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "Contain_F"
	anchored = 1
	density = 0
	event_handler_flags = USE_FLUID_ENTER | IMMUNE_SINGULARITY | USE_CANPASS
	var/active = 1
	var/power = 10
	var/delay = 5
	var/last_active
	var/mob/U
	var/obj/machinery/field_generator/gen_primary
	var/obj/machinery/field_generator/gen_secondary
	var/datum/light/light

/obj/machinery/containment_field/New(var/obj/machinery/field_generator/A, var/obj/machinery/field_generator/B)
	src.gen_primary = A
	src.gen_secondary = B
	light = new /datum/light/point
	light.set_brightness(0.7)
	light.set_color(0, 0.1, 0.8)
	light.attach(src)
	light.enable()

	..()

/obj/machinery/containment_field/attack_hand(mob/user as mob)
	return

/obj/machinery/containment_field/process()
	if(isnull(gen_primary)||isnull(gen_secondary))
		qdel(src)
		return

	if(!(gen_primary.active)||!(gen_secondary.active))
		qdel(src)
		return

/obj/machinery/containment_field/proc/shock(mob/user as mob)
	if(isnull(gen_primary))
		qdel(src)
		return
	if(isnull(gen_secondary))
		qdel(src)
		return

	elecflash(user)

	src.power = max(gen_primary.power,gen_secondary.power)

	var/prot = 1
	var/shock_damage = 0
	if(src.power > 200)
		shock_damage = min(rand(40,80),rand(40,100))*prot
	else if(src.power > 120)
		shock_damage = min(rand(30,60),rand(30,90))*prot
	else if(src.power > 80)
		shock_damage = min(rand(20,40),rand(20,40))*prot
	else if(src.power > 60)
		shock_damage = min(rand(20,30),rand(20,30))*prot
	else
		shock_damage = min(rand(10,20),rand(10,20))*prot

	// Added (Convair880).
	logTheThing("combat", user, null, "was shocked by a containment field at [log_loc(src)].")

	if (user && user.bioHolder)
		if (user.bioHolder.HasEffect("resist_electric") == 2)
			var/healing = 0
			if (shock_damage)
				healing = shock_damage / 3
			user.HealDamage("All", shock_damage, shock_damage)
			user.take_toxin_damage(0 - healing)
			boutput(user, "<span class='notice'>You absorb the electrical shock, healing your body!</span>")
			return
		else if (user.bioHolder.HasEffect("resist_electric") == 1)
			boutput(user, "<span class='notice'>You feel electricity course through you harmlessly!</span>")
			return

	user.TakeDamage(user.hand == 1 ? "l_arm" : "r_arm", 0, shock_damage)
	boutput(user, "<span class='alert'><B>You feel a powerful shock course through your body sending you flying!</B></span>")
	user.unlock_medal("HIGH VOLTAGE", 1)
	if (isliving(user))
		var/mob/living/L = user
		L.Virus_ShockCure(100)
		L.shock_cyberheart(100)
	if(user.getStatusDuration("stunned") < shock_damage * 10)	user.changeStatus("stunned", shock_damage * 10)
	if(user.getStatusDuration("weakened") < shock_damage * 10)	user.changeStatus("weakened", shock_damage * 10)

	if(user.get_burn_damage() >= 500) //This person has way too much BURN, they've probably been shocked a lot! Let's destroy them!
		user.visible_message("<span style=\"color:red;font-weight:bold;\">[user.name] was disintegrated by the [src.name]!</span>")
		user.elecgib()
		return
	else
		var/throwdir = get_dir(src, get_step_away(user, src))
		if (prob(20))
			user.set_loc(get_turf(src))
			if (prob(50))
				throwdir = turn(throwdir,90)
			else
				throwdir = turn(throwdir,-90)
		var/atom/target = get_edge_target_turf(user, throwdir)
		user.throw_at(target, 200, 4)
		for(var/mob/M in AIviewers(src))
			if(M == user)	continue
			M.show_message("<span class='alert'>[user.name] was shocked by the [src.name]!</span>", 3, "<span class='alert'>You hear a heavy electrical crack</span>", 2)

	src.gen_primary.power -= 3
	src.gen_secondary.power -= 3
	return

/obj/machinery/containment_field/CanPass(atom/movable/O as mob|obj, target as turf, height=0, air_group=0)
	if(iscarbon(O) && prob(80))
		shock(O)
	..()


/////////////////////////////////////////// Emitter ///////////////////////////////
/obj/machinery/emitter
	name = "Emitter"
	desc = "Shoots a high power laser when active"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "Emitter"
	anchored = 0
	density = 1
	req_access = list(access_engineering_engine)
	object_flags = CAN_REPROGRAM_ACCESS
	var/active = 0
	var/power = 20
	var/fire_delay = 100
	var/HP = 20
	var/last_shot = 0
	var/shot_number = 0
	var/state = 0
	var/locked = 1
	//Remote control stuff
	var/net_id = null
	var/obj/machinery/power/data_terminal/link = null
	var/datum/projectile/current_projectile = new/datum/projectile/laser/heavy
	mats = 10

/obj/machinery/emitter/New()
	..()
	SPAWN_DBG(0.6 SECONDS)
		if(!src.link && (state == 3))
			src.get_link()

		src.net_id = format_net_id("\ref[src]")

//Create a link with a data terminal on the same tile, if possible.
/obj/machinery/emitter/proc/get_link()
	if(src.link)
		src.link.master = null
		src.link = null
	var/turf/T = get_turf(src)
	var/obj/machinery/power/data_terminal/test_link = locate() in T
	if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
		src.link = test_link
		src.link.master = src

	return

/obj/machinery/emitter/attack_hand(mob/user as mob)
	if(state == 3)
		if(!src.locked)
			if(src.active==1)
				if(alert("Turn off the emitter?",,"Yes","No") == "Yes")
					src.active = 0
					icon_state = "Emitter"
					boutput(user, "You turn off the emitter.")
					logTheThing("station", user, null, "deactivated active emitter at [log_loc(src)].")
					message_admins("[key_name(user)] deactivated active emitter at [log_loc(src)].")
			else
				if(alert("Turn on the emitter?",,"Yes","No") == "Yes")
					src.active = 1
					icon_state = "Emitter +a"
					boutput(user, "You turn on the emitter.")
					logTheThing("station", user, null, "activated emitter at [log_loc(src)].")
					src.shot_number = 0
					src.fire_delay = 100
					message_admins("[key_name(user)] activated emitter at [log_loc(src)].")
		else
			boutput(user, "The controls are locked!")
	else
		boutput(user, "The emitter needs to be firmly secured to the floor first.")
	src.add_fingerprint(user)
	..()

/obj/machinery/emitter/attack_ai(mob/user as mob)
	if(state == 3)
		if(src.active==1)
			if(alert("Turn off the emitter?",,"Yes","No") == "Yes")
				src.active = 0
				icon_state = "Emitter"
				boutput(user, "You turn off the emitter.")
				logTheThing("station", user, null, "deactivated active emitter at [log_loc(src)].")
				message_admins("[key_name(user)] deactivated active emitter at [log_loc(src)].")
		else
			if(alert("Turn on the emitter?",,"Yes","No") == "Yes")
				src.active = 1
				icon_state = "Emitter +a"
				boutput(user, "You turn on the emitter.")
				logTheThing("station", user, null, "activated emitter at [log_loc(src)].")
				src.shot_number = 0
				src.fire_delay = 100
				message_admins("[key_name(user)] activated emitter at [log_loc(src)].")
	else
		boutput(user, "The emitter needs to be firmly secured to the floor first.")
	src.add_fingerprint(user)
	return

/obj/machinery/emitter/process()

	if(status & (NOPOWER|BROKEN))
		return

	if(!src.state == 3)
		src.active = 0
		return

	if(((src.last_shot + src.fire_delay) <= world.time) && (src.active == 1))
		src.last_shot = world.time
		if(src.shot_number < 3)
			src.fire_delay = 2
			src.shot_number ++
		else
			src.fire_delay = rand(20,100)
			src.shot_number = 0

		if ((src.dir - 1) & src.dir) // Not cardinal (not power of 2)
			src.dir &= 12 // Cardinalize
		src.visible_message("<span class='alert'><b>[src]</b> fires a bolt of energy!</span>")
		shoot_projectile_DIR(src, current_projectile, dir)

		if(prob(35))
			elecflash(src)
	..()

/obj/machinery/emitter/attackby(obj/item/W, mob/user)
	if (ispryingtool(W))
		if(!anchored)
			src.dir = turn(src.dir, -90)
			return
		else
			boutput(user, "The emitter is too firmly secured to be rotated!")
			return
	else if (iswrenchingtool(W))
		if(active)
			boutput(user, "Turn off the emitter first.")
			return

		else if(state == 0)
			state = 1
			playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
			boutput(user, "You secure the external reinforcing bolts to the floor.")
			src.anchored = 1
			desc = "Shoots a high power laser when active, it has been bolted to the floor."
			return

		else if(state == 1)
			state = 0
			playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
			boutput(user, "You undo the external reinforcing bolts.")
			src.anchored = 0
			desc = "Shoots a high power laser when active."
			return

	if(isweldingtool(W))

		var/turf/T = user.loc

		if(state == 1)
			if(!W:try_weld(user, 1, noisy = 2))
				return
			boutput(user, "You start to weld the emitter to the floor.")
			sleep(2 SECONDS)

			if ((user.loc == T && user.equipped() == W))
				state = 3
				src.get_link()
				boutput(user, "You weld the emitter to the floor.")
			else if((isrobot(user) && (user.loc == T)))
				state = 3
				src.get_link()
				desc = "Shoots a high power laser when active, it has been bolted and welded to the floor."
				boutput(user, "You weld the emitter to the floor.")
			return

		if(state == 3)
			if(!W:try_weld(user, 1, noisy = 2))
				return
			boutput(user, "You start to cut the emitter free from the floor.")
			sleep(2 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				state = 1
				if(src.link) //Time to clear our link.
					src.link.master = null
					src.link = null
					desc = "Shoots a high power laser when active, it has been bolted to the floor."
				boutput(user, "You cut the emitter free from the floor.")
			else if((isrobot(user) && (user.loc == T)))
				state = 1
				if(src.link)
					src.link.master = null
					src.link = null
					desc = "Shoots a high power laser when active, it has been bolted to the floor."
				boutput(user, "You cut the emitter free from the floor.")
			return

	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card
	if (istype(W, /obj/item/card/id))
		if (src.allowed(user))
			src.locked = !src.locked
			boutput(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
			if (!src.locked)
				logTheThing("station", user, null, "unlocked emitter at at [log_loc(src)].")
		else
			boutput(user, "<span class='alert'>Access denied.</span>")

	else
		src.add_fingerprint(user)
		boutput(user, "<span class='alert'>You hit the [src.name] with your [W.name]!</span>")
		for(var/mob/M in AIviewers(src))
			if(M == user)	continue
			M.show_message("<span class='alert'>The [src.name] has been hit with the [W.name] by [user.name]!</span>")


//Send a signal over our link, if possible.
/obj/machinery/emitter/proc/post_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
	if(!src.link || !target_id)
		return

	var/datum/signal/signal = get_free_signal()
	signal.source = src
	signal.transmission_method = TRANSMISSION_WIRE
	signal.data[key] = value
	if(key2)
		signal.data[key2] = value2
	if(key3)
		signal.data[key3] = value3

	signal.data["address_1"] = target_id
	signal.data["sender"] = src.net_id

	src.link.post_signal(src, signal)

//What do we do with an incoming command?
/obj/machinery/emitter/receive_signal(datum/signal/signal)
	if(!src.link)
		return
	if(!signal || !src.net_id || signal.encryption)
		return


	if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
		return

	var/target = signal.data["sender"]

	//They don't need to target us specifically to ping us.
	//Otherwise, ff they aren't addressing us, ignore them
	if(signal.data["address_1"] != src.net_id)
		if((signal.data["address_1"] == "ping") && signal.data["sender"])
			SPAWN_DBG(0.5 SECONDS) //Send a reply for those curious jerks
				src.post_status(target, "command", "ping_reply", "device", "PNET_ENG_EMITR", "netid", src.net_id)

		return

	var/sigcommand = lowertext(signal.data["command"])
	if(!sigcommand || !signal.data["sender"])
		return

	//Oh okay, time to start up.
	if(sigcommand == "activate" && !src.active)
		src.active = 1
		icon_state = "Emitter +a"
		src.shot_number = 0
		src.fire_delay = 100
	//oh welp shutdown time.
	else if(sigcommand == "deactivate" && src.active)
		src.active = 0
		icon_state = "Emitter"

	return

/////////////////////////////////// Collector array /////////////////////////////////

/obj/item/electronics/frame/collector_array
	name = "Radiation Collector Array frame"
	store_type = /obj/machinery/power/collector_array
	viewstat = 2
	secured = 2
	icon_state = "dbox"

/obj/machinery/power/collector_array
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "ca"
	anchored = 1
	density = 1
	directwired = 1
	var/magic = 0
	var/active = 0
	var/obj/item/tank/plasma/P = null
	var/obj/machinery/power/collector_control/CU = null

/obj/machinery/power/collector_array/New()
	..()
	SPAWN_DBG(0.5 SECONDS)
		updateicon()


/obj/machinery/power/collector_array/proc/updateicon()

	if(status & (NOPOWER|BROKEN))
		overlays = null
	if(P)
		overlays += image('icons/obj/singularity.dmi', "ptank")
	else
		overlays = null
	overlays += image('icons/obj/singularity.dmi', "on")
	if(P)
		overlays += image('icons/obj/singularity.dmi', "ptank")
	if(magic == 1)
		overlays += image('icons/obj/singularity.dmi', "ptank")
		overlays += image('icons/obj/singularity.dmi', "on")

/obj/machinery/power/collector_array/power_change()
	updateicon()
	..()

/obj/machinery/power/collector_array/process()

	if(magic == 1)
		src.active = 1
		icon_state = "ca_active"
	else
		if(P)
			if(P.air_contents.toxins <= 0)
				src.active = 0
				icon_state = "ca_deactive"
				updateicon()
		else if(src.active == 1)
			src.active = 0
			icon_state = "ca_deactive"
			updateicon()
		..()

/obj/machinery/power/collector_array/attack_hand(mob/user as mob)
	if(src.active==1)
		src.active = 0
		icon_state = "ca_deactive"
		if(CU)
			CU.updatecons()
		boutput(user, "You turn off the collector array.")
		return

	if(src.active==0)
		src.active = 1
		icon_state = "ca_active"
		if(CU)
			CU.updatecons()
		boutput(user, "You turn on the collector array.")
		return

/obj/machinery/power/collector_array/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		if(src.active)
			boutput("<span class='alert'>The [src.name] must be turned off first!</span>")
		else
			if (!src.anchored)
				playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
				boutput(user, "You secure the [src.name] to the floor.")
				src.anchored = 1
			else
				playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
				boutput(user, "You unsecure the [src.name].")
				src.anchored = 0
			logTheThing("station", user, null, "[src.anchored ? "bolts" : "unbolts"] a [src.name] [src.anchored ? "to" : "from"] the floor at [log_loc(src)].") // Ditto (Convair880).
	else if(istype(W, /obj/item/tank/plasma))
		if(src.P)
			boutput(user, "<span class='alert'>There appears to already be a plasma tank loaded!</span>")
			return
		src.P = W
		W.set_loc(src)
		user.u_equip(W)
		if(CU)
			CU.updatecons()
		updateicon()
	else if (ispryingtool(W))
		if(!P)
			return
		var/obj/item/tank/plasma/Z = src.P
		Z.set_loc(get_turf(src))
		Z.layer = initial(Z.layer)
		src.P = null
		if(CU)
			CU.updatecons()
		updateicon()
	else
		src.add_fingerprint(user)
		boutput(user, "<span class='alert'>You hit the [src.name] with your [W.name]!</span>")
		for(var/mob/M in AIviewers(src))
			if(M == user)	continue
			M.show_message("<span class='alert'>The [src.name] has been hit with the [W.name] by [user.name]!</span>")

////////////////////////// Collector array controller ////////////////////////////

/obj/item/electronics/frame/collector_control
	name = "Radiation Collector Control frame"
	store_type = /obj/machinery/power/collector_control
	viewstat = 2
	secured = 2
	icon_state = "dbox"

/obj/machinery/power/collector_control
	name = "Radiation Collector Control"
	desc = "A device which uses Hawking Radiation and Plasma to produce power."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "cu"
	anchored = 1
	density = 1
	directwired = 1
	var/magic = 0
	var/active = 0
	var/lastpower = 0
	var/obj/item/tank/plasma/P1 = null
	var/obj/item/tank/plasma/P2 = null
	var/obj/item/tank/plasma/P3 = null
	var/obj/item/tank/plasma/P4 = null
	var/obj/machinery/power/collector_array/CA1 = null
	var/obj/machinery/power/collector_array/CA2 = null
	var/obj/machinery/power/collector_array/CA3 = null
	var/obj/machinery/power/collector_array/CA4 = null
	var/obj/machinery/power/collector_array/CAN = null
	var/obj/machinery/power/collector_array/CAS = null
	var/obj/machinery/power/collector_array/CAE = null
	var/obj/machinery/power/collector_array/CAW = null
	var/obj/machinery/the_singularity/S1 = null

/obj/machinery/power/collector_control/New()
	..()
	SPAWN_DBG(1 SECOND)
		updatecons()

/obj/machinery/power/collector_control/proc/updatecons()

	if(magic != 1)

		CAN = locate(/obj/machinery/power/collector_array) in get_step(src,NORTH)
		CAS = locate(/obj/machinery/power/collector_array) in get_step(src,SOUTH)
		CAE = locate(/obj/machinery/power/collector_array) in get_step(src,EAST)
		CAW = locate(/obj/machinery/power/collector_array) in get_step(src,WEST)
		for(var/obj/machinery/the_singularity/S in orange(12,src))
			S1 = S

		if(!isnull(CAN))
			CA1 = CAN
			CAN.CU = src
			if(CA1.P)
				P1 = CA1.P
		else
			CAN = null
		if(!isnull(CAS))
			CA3 = CAS
			CAS.CU = src
			if(CA3.P)
				P3 = CA3.P
		else
			CAS = null
		if(!isnull(CAW))
			CA4 = CAW
			CAW.CU = src
			if(CA4.P)
				P4 = CA4.P
		else
			CAW = null
		if(!isnull(CAE))
			CA2 = CAE
			CAE.CU = src
			//DrMelon attempted fix for null.P at singularity.dm /// seemed to have been a tabulation error
			if(CA2.P)
				P2 = CA2.P
		else
			CAE = null
		if(isnull(S1))
			S1 = null

		updateicon()
		SPAWN_DBG(1 MINUTE)
			updatecons()

	else
		updateicon()
		SPAWN_DBG(1 MINUTE)
			updatecons()

/obj/machinery/power/collector_control/proc/updateicon()

	if(magic != 1)

		if(status & (NOPOWER|BROKEN))
			overlays = null
		else
			overlays = null
		if(src.active == 0)
			return
		overlays += image('icons/obj/singularity.dmi', "cu on")
		if((P1)&&(CA1.active != 0))
			overlays += image('icons/obj/singularity.dmi', "cu 1 on")
		if((P2)&&(CA2.active != 0))
			overlays += image('icons/obj/singularity.dmi', "cu 2 on")
		if((P3)&&(CA3.active != 0))
			overlays += image('icons/obj/singularity.dmi', "cu 3 on")
		if((!P1)||(!P2)||(!P3))
			overlays += image('icons/obj/singularity.dmi', "cu n error")
		if(S1)
			overlays += image('icons/obj/singularity.dmi', "cu sing")
			if(!S1.active)
				overlays += image('icons/obj/singularity.dmi', "cu conterr")
	else
		overlays += image('icons/obj/singularity.dmi', "cu on")
		overlays += image('icons/obj/singularity.dmi', "cu 1 on")
		overlays += image('icons/obj/singularity.dmi', "cu 2 on")
		overlays += image('icons/obj/singularity.dmi', "cu 3 on")
		overlays += image('icons/obj/singularity.dmi', "cu sing")

/obj/machinery/power/collector_control/power_change()
	updateicon()
	..()

/obj/machinery/power/collector_control/process()
	if(magic != 1)
		if(src.active == 1)
			var/power_a = 0
			var/power_s = 0
			var/power_p = 0

			if(!isnull(S1))
				power_s += S1.energy
			if(!isnull(P1))
				if(CA1.active != 0)
					power_p += P1.air_contents.toxins
					P1.air_contents.toxins -= 0.001
			if(!isnull(P2))
				if(CA2.active != 0)
					power_p += P2.air_contents.toxins
					P2.air_contents.toxins -= 0.001
			if(!isnull(P3))
				if(CA3.active != 0)
					power_p += P3.air_contents.toxins
					P3.air_contents.toxins -= 0.001
			if(!isnull(P4))
				if(CA4.active != 0)
					power_p += P4.air_contents.toxins
					P4.air_contents.toxins -= 0.001
			power_a = power_p*power_s*50
			src.lastpower = power_a
			add_avail(power_a)
			..()
	else
		var/power_a = 0
		var/power_s = 0
		var/power_p = 0
		if(!isnull(S1))
			power_s += S1.energy
		power_p += 50
		power_a = power_p*power_s*50
		src.lastpower = power_a
		add_avail(power_a)
		..()

/obj/machinery/power/collector_control/attack_hand(mob/user as mob)
	if(src.active==1)
		src.active = 0
		boutput(user, "You turn off the collector control.")
		src.lastpower = 0
		updateicon()
		return

	if(src.active==0)
		src.active = 1
		boutput(user, "You turn on the collector control.")
		updatecons()
		return

/obj/machinery/power/collector_control/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		if(src.active)
			boutput("<span class='alert'>The [src.name] must be turned off first!</span>")
		else
			if (!src.anchored)
				playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
				boutput(user, "You secure the [src.name] to the floor.")
				src.anchored = 1
			else
				playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
				boutput(user, "You unsecure the [src.name].")
				src.anchored = 0
			logTheThing("station", user, null, "[src.anchored ? "bolts" : "unbolts"] a [src.name] [src.anchored ? "to" : "from"] the floor at [log_loc(src)].") // Ditto (Convair880).
	else if(istype(W, /obj/item/device/analyzer/atmospheric))
		boutput(user, "<span class='notice'>The analyzer detects that [lastpower]W are being produced.</span>")

	else
		src.add_fingerprint(user)
		boutput(user, "<span class='alert'>You hit the [src.name] with your [W.name]!</span>")
		for(var/mob/M in AIviewers(src))
			if(M == user)	continue
			M.show_message("<span class='alert'>The [src.name] has been hit with the [W.name] by [user.name]!</span>")

///////////////////////////////////////// Singularity bomb /////////////////////////////

// Thing thing had zero logging despite being overhauled recently. I corrected that oversight (Convair880).
/obj/machinery/the_singularitybomb/
	name = "\improper Singularity Bomb"
	desc = "A WMD that creates a singularity."
	icon = 'icons/obj/power.dmi'
	icon_state = "portgen0"
	anchored = 0
	density = 1
	var/state = 0
	var/timing = 0.0
	var/time = 30
	var/last_tick = null
	var/mob/activator = null // For logging purposes.
	is_syndicate = 1
	mats = 14
	var/bhole = 1

/obj/machinery/the_singularitybomb/attackby(obj/item/W, mob/user)
	src.add_fingerprint(user)

	if (iswrenchingtool(W))

		if(state == 0)
			state = 1
			playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
			boutput(user, "You secure the external reinforcing bolts to the floor.")
			src.anchored = 1
			return

		else if(state == 1)
			state = 0
			playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
			boutput(user, "You undo the external reinforcing bolts.")
			src.anchored = 0
			return

	if(isweldingtool(W))
		if(timing)
			boutput(user, "Stop the countdown first.")
			return

		var/turf/T = user.loc


		if(state == 1)
			if(!W:try_weld(user, 1, noisy = 2))
				return
			boutput(user, "You start to weld the bomb to the floor.")
			sleep(5 SECONDS)

			logTheThing("station", user, null, "welds a [src.name] to the floor at [log_loc(src)].") // Like here (Convair880).

			if ((user.loc == T && user.equipped() == W))
				state = 3
				icon_state = "portgen1"
				boutput(user, "You weld the bomb to the floor.")
			else if((isrobot(user) && (user.loc == T)))
				state = 3
				icon_state = "portgen1"
				boutput(user, "You weld the bomb to the floor.")
			return

		if(state == 3)
			if(!W:try_weld(user, 1, noisy = 2))
				return
			boutput(user, "You start to cut the bomb free from the floor.")
			sleep(5 SECONDS)

			logTheThing("station", user, null, "cuts a [src.name] from the floor at [log_loc(src)].") // Hmm (Convair880).
			if (src.activator)
				src.activator = null

			if ((user.loc == T && user.equipped() == W))
				state = 1
				icon_state = "portgen0"
				boutput(user, "You cut the bomb free from the floor.")
			else if((isrobot(user) && (user.loc == T)))
				state = 1
				icon_state = "portgen0"
				boutput(user, "You cut the bomb free from the floor.")
			return

	else
		boutput(user, "<span class='alert'>You hit the [src.name] with your [W.name]!</span>")
		for(var/mob/M in AIviewers(src))
			if(M == user)	continue
			M.show_message("<span class='alert'>The [src.name] has been hit with the [W.name] by [user.name]!</span>")

/obj/machinery/the_singularitybomb/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() || usr.lying)
		return
	if ((in_range(src, usr) && istype(src.loc, /turf)))
		src.add_dialog(usr)
		switch(href_list["action"]) //Yeah, this is weirdly set up. Planning to expand it later.
			if("trigger")
				switch(href_list["spec"])
					if("prime")
						if(!timing)
							src.timing = 1
							if(!(src in processing_items))
								processing_items.Add(src)
							src.icon_state = "portgen2"

							// And here (Convair880).
							logTheThing("bombing", usr, null, "activated [src.name] ([src.time] seconds) at [log_loc(src)].")
							message_admins("[key_name(usr)] activated [src.name] ([src.time] seconds) at [log_loc(src)].")
							if (ismob(usr))
								src.activator = usr

						else
							boutput(usr, "<span class='alert'>\The [src] is already primed!</span>")
					if("abort")
						if(timing)
							src.timing = 0
							src.icon_state = "portgen1"

							// And here (Convair880).
							logTheThing("bombing", usr, src.activator, "deactivated [src.name][src.activator ? " (primed by [constructTarget(src.activator,"bombing")]" : ""] at [log_loc(src)].")
							message_admins("[key_name(usr)] deactivated [src.name][src.activator ? " (primed by [key_name(src.activator)])" : ""] at [log_loc(src)].")

						else
							boutput(usr, "<span class='alert'>\The [src] is already deactivated!</span>")
			if("timer")
				if(!timing)
					var/tp = text2num(href_list["tp"])
					src.time += tp
					src.time = min(max(round(src.time), 30), 600)
				else
					boutput(usr, "<span class='alert'>You can't change the time while the timer is engaged!</span>")
		/*
		if (href_list["time"])
			src.timing = text2num(href_list["time"])
			if(timing && !(src in processing_items))
				processing_items.Add(src)
				src.icon_state = "portgen2"
			else
				src.icon_state = "portgen1"

		if (href_list["tp"])
			var/tp = text2num(href_list["tp"])
			src.time += tp
			src.time = min(max(round(src.time), 60), 600)

		if (href_list["close"])
			usr.Browse(null, "window=timer")
			usr.machine = null
			return
		*/
		if (ismob(src.loc))
			attack_hand(src.loc)
		else
			src.updateUsrDialog()

		src.add_fingerprint(usr)
	else
		usr.Browse(null, "window=timer")
		return
	return

/obj/machinery/the_singularitybomb/attack_ai(mob/user as mob)
	return

/obj/machinery/the_singularitybomb/attack_hand(mob/user as mob)
	..()
	if(src.state != 3)
		boutput(user, "The bomb needs to be firmly secured to the floor first.")
		return
	if (user.stat || user.restrained() || user.lying)
		return
	if ((get_dist(src, user) <= 1 && istype(src.loc, /turf)))
		src.add_dialog(user)
		/*
		var/dat = text("<TT><B>Timing Unit</B><br>[] []:[]<br><A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A><br></TT>", (src.timing ? text("<A href='?src=\ref[];time=0'>Timing</A>", src) : text("<A href='?src=\ref[];time=1'>Not Timing</A>", src)), minute, second, src, src, src, src)
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
		*/
		user.Browse(src.get_interface(), "window=timer")
		onclose(user, "timer")
	else
		user.Browse(null, "window=timer")
		src.remove_dialog(user)

	src.add_fingerprint(user)
	return

/obj/machinery/the_singularitybomb/proc/time()
	var/turf/T = get_turf(src.loc)
	for(var/mob/O in hearers(src.loc, null))
		O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)


	playsound(T, 'sound/effects/creaking_metal1.ogg', 100, 0, 5, 0.5)
	for (var/mob/M in range(7,T))
		boutput(M, "<span class='bold alert'>The contaiment field on \the [src] begins destabilizing!</span>")
		shake_camera(M, 5, 1)
	for (var/turf/TF in range(4,T))
		animate_shake(TF,5,1 * get_dist(TF,T),1 * get_dist(TF,T))
	particleMaster.SpawnSystem(new /datum/particleSystem/bhole_warning(T))

	SPAWN_DBG(3 SECONDS)
		for (var/mob/M in range(7,T))
			boutput(M, "<span class='bold alert'>The containment field on \the [src] fails completely!</span>")
			shake_camera(M, 5, 1)

		// And most importantly here (Convair880)!
		logTheThing("bombing", src.activator, null, "A [src.name] (primed by [src.activator ? "[src.activator]" : "*unknown*"]) detonates at [log_loc(src)].")
		message_admins("A [src.name] (primed by [src.activator ? "[key_name(src.activator)]" : "*unknown*"]) detonates at [log_loc(src)].")

		playsound(T, 'sound/machines/satcrash.ogg', 100, 0, 5, 0.5)
		if (bhole)
			var/obj/B = new /obj/bhole(get_turf(src.loc), rand(1600, 2400), rand(75, 100))
			B.name = "gravitational singularity"
			B.color = "#FF00FF"
		else
			new /obj/machinery/the_singularity(get_turf(src.loc), rand(1600, 2400))

	return

/obj/machinery/the_singularitybomb/process()
	if (src.timing)
		if (src.time > 0)
			if (!last_tick) last_tick = world.time
			var/passed_time = round(max(round(world.time - last_tick),10) / 10)
			src.time = max(0, src.time - passed_time)
			last_tick = world.time
		else
			time()
			src.time = 0
			src.timing = 0
			last_tick = 0

		if (ismob(src.loc))
			attack_hand(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.using_dialog_of(src))
					src.attack_hand(M)

	return

/obj/machinery/the_singularitybomb/proc/get_time()
	if(src.time < 0)
		return "DO:OM"
	else
		var/seconds = src.time % 60
		var/minutes = (src.time - seconds) / 60
		minutes = minutes < 10 ? "0[minutes]" : "[minutes]"
		seconds = seconds < 10 ? "0[seconds]" : "[seconds]"

		return "[minutes][seconds % 2 == 0 ? ":" : " "][seconds]"

/obj/machinery/the_singularitybomb/proc/get_interface()
	return {"<html>
				<head>
					<style>
						body {
							font-family:verdana,sans-serif;

						}
						a {
							text-decoration:none;
						}
						.top_level {
							display: inline;
							border: 2px solid #333;
							padding:10px;
						}
						.timing_div {
							overflow:auto;
							padding:10px;
						}
						.timer {
							display:table-cell;
							color:#0A0;
							font-weight:bold;
							text-align:src.get_center();
							vertical-align:middle;
							border:3px solid #222;
							background-color:#111;
							padding:3px;
						}
						.timer.active {
							color:#F00;
						}
						.button {
							display:table-cell;
							color:#0A0;
							font-weight:bold;
							text-align:src.get_center();
							vertical-align:middle;
							border:3px solid #222;
							background-color:#111;
							padding:3px;
						}
						.button.timer_b {
							width:50px;
						}
						/*
						.button:hover {
							background-color:#222;
							border:3px solid #333;
						}
						*/
						#abort {
							color:#000;
							background-color:#A00;
						}
						/*
						#abort:hover {
							background-color:#600;
						}
						*/
						#prime {
							color:#000;
							background-color:#0A0;
						}
						/*
						#prime:hover {
							background-color:#060;
						}
						*/

						.timer_table {
							text-align:src.get_center();
							vertical-align:middle;
							width:200px;
						}
					</style>

				</head>
				<body bgcolor=#555>
					<div class="timing_div top_level">
						<table class="timer_table">
							<tr>
								<td class="timer[src.timing ? " active" : ""]" colspan=4>[src.get_time()]</td>
							</tr>

							<tr>
								<td>
									<a href="?src=\ref[src];action=timer;tp=-30">
										<div class="button timer_b">
											--
										</div>
									</a>
								</td>
								<td>
									<a href="?src=\ref[src];action=timer;tp=-1">
										<div class="button timer_b">
											-
										</div>
									</a>
								</td>
								<td>
									<a href="?src=\ref[src];action=timer;tp=1">
										<div class="button timer_b">
											+
										</div>
									</a>
								</td>
								<td>
									<a href="?src=\ref[src];action=timer;tp=30">
										<div class="button timer_b">
											++
										</div>
									</a>
								</td>
							</tr>
							<tr>
								<td colspan=2>
									<a href="?src=\ref[src];action=trigger;spec=abort">
										<div class="button" id="abort">
											Abort
										</div>
									</a>
								</td>
								<td colspan=2>
									<a href="?src=\ref[src];action=trigger;spec=prime">
										<div class="button" id="prime">
											Prime
										</div>
									</a>
								</td>
							</tr>
						</table>
					</div>
				</body>
			</html>"}
