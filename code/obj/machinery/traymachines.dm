//Tray machines: machines have a big tray object associated that is used to load/unload things into the machine (previously morgue.dm)
//(as of the refactor that made these subtypes of a common machine parent, that's the morgue, crematorium and tanning bed)
//((Fun fact: the tanning bed used to be a type of crematorium!))

//In any case: the parent object handles taking the tray in and out and all the special cases that come with that territory (deconstruction, explosions)
//Note that they are subscribed to the process loop by default, but aside from drawing power (handled by the machinery parent) do nothing special.
//At the moment there's not really the support for the tray and machine to be separated, also disposing either will have the other qdel'd

//File contents:
// Tray machine parent object
// Locking tray machine parent (parent to crematorium & tanning bed)
// Tray parent object (+ morgue, crematorium trays, relatively pathed)
// Morgue
// Crematorium
// Crematorium switch
// Tanning bed
// Tanning bed tray (which has a little more going on than the other trays)
// Tanning bed computer (largely untouched in refactor)

//This header was last guaranteed to be accurate 2022-?-? <-> BatElite
#define TRAYMACHINE_DEFAULT_DRAW 250 //IDK I just put a number
#define TANNING_BED_MAX_TIME 20 SECONDS //For adjusting on the tanning computer.

//-----------------------------------------------------
/*~ Tray Machine Parent ~*/
//-----------------------------------------------------

ABSTRACT_TYPE(/obj/machinery/traymachine)
ADMIN_INTERACT_PROCS(/obj/machinery/traymachine, proc/eject_tray, proc/collect_tray)
/obj/machinery/traymachine
	name = "tray machine"
	desc = "This thing sure has a big tray that goes vwwwwwwsh when you slide it in and out."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"
	density = TRUE
	anchored = ANCHORED
	power_usage = 50

	//tray related variables
	var/obj/machine_tray/my_tray = null
	var/tray_type = /obj/machine_tray //type of tray the machine should be spawning

	//Currently no tray machine accepts anything into its contents except through tray loading
	//But anything in this list won't get ejected on opening, this is a bit of futureproofing
	var/list/non_tray_contents = list()

	//icon_state names for the default update proc, unused if you override that and don't use them yourself.
	var/icon_trayopen = "morgue0"
	var/icon_unoccupied = "morgue1"
	var/icon_occupied = "morgue2" //When the machine has things in contents that aren't the tray or in non_tray_contents


/obj/machinery/traymachine/New()
	my_tray = new tray_type(src) //Heck this lazy init tray spawning,
	my_tray.set_dir(src.dir)
	my_tray.my_machine = src
	my_tray.layer = OBJ_LAYER - 0.02
	my_tray.bound_width = src.bound_width
	my_tray.bound_height = src.bound_height
	my_tray.transform = src.transform

	..()

/obj/machinery/traymachine/disposing()
	my_tray?.my_machine = null
	qdel(my_tray)
	my_tray = null
	if (length(src.contents)) //dump out any other stuff
		var/turf/T = get_turf(src)
		for (var/atom/movable/AM in contents)
			if (!(AM in non_tray_contents))
				AM.set_loc(T)
	. = ..()

/obj/machinery/traymachine/attack_hand(mob/user)
	src.add_fingerprint(user)
	if (my_tray && my_tray.loc != src)
		collect_tray()
	else
		eject_tray()

/obj/machinery/traymachine/attack_ai(mob/user as mob)
	attack_hand(user) //finally silicons can open and close the fucking morgues

//Fun fact you can label these things
/obj/machinery/traymachine/attackby(P, mob/user)
	src.add_fingerprint(user)
	if (istype(P, /obj/item/pen))
		var/t = input(user, "What would you like the label to be?", src.name, null) as null|text
		if (!t)
			return
		if (user.equipped() != P)
			return
		if ((!in_interact_range(src, user) && src.loc != user))
			return
		t = copytext(adminscrub(t),1,128)
		if (t)
			src.name = "[initial(src.name)]- '[t]'"
		else
			src.name = "[initial(src.name)]"
	else
		return ..()

/obj/machinery/traymachine/ex_act(severity)
	var/chance //This switch was just the same loop with different probabilities 3 times and fuck that
	switch(severity)
		if(1)
			chance = 100
		if(2)
			chance = 50
		if(3)
			chance = 5
	if (prob(chance))
		for(var/atom/movable/A in src) //The reason for this loop here (when there's a similar one in disposing) is contents also get exploded
			if (!(A in non_tray_contents))
				A.set_loc(src.loc)
				A.ex_act(severity)
		qdel(src)
	return

//Someone is trying to move from inside
/obj/machinery/traymachine/relaymove(mob/user as mob)
	if (user.stat)
		return
	eject_tray()


///Tray comes out - probably override this if your tray should move weirdly
/obj/machinery/traymachine/proc/eject_tray()
	set name = "open"

	if (!is_cardinal(src.dir))
		src.set_dir(src.dir & (NORTH | SOUTH))

	var/turf/T_src = get_turf(src)
	var/turf/T = T_src
	for(var/i in 1 to src.bound_width / world.icon_size)
		T = get_step(T, src.dir)

	// stop the tray from extending into solid things
	if (T.density && !istype(get_area(src), /area/solarium)) // Solarium gets an exception because this is a hilarious way to get Helios
		playsound(src, 'sound/impact_sounds/Wood_Hit_1.ogg', 15, TRUE, -3)
		return
	for(var/obj/O in T) // we still want to extend into mobs, no iterating over them
		if (O.density && O.anchored) // it's ok to pull in unanchored stuff I guess!
			playsound(src, 'sound/impact_sounds/Wood_Hit_1.ogg', 15, TRUE, -3)
			return

	my_tray.set_dir(src.dir)
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

	//handle animation and ejection of contents
	for(var/atom/movable/AM as anything in src)
		if (AM in non_tray_contents)
			continue
		AM.set_loc(T)
		AM.pixel_x = 28 * (T_src.x - T.x) // 28 instead of 32 to obscure the double handle on morgues
		AM.pixel_y = 28 * (T_src.y - T.y)

		var/orig_layer = AM.layer
		if (AM != my_tray)
			AM.layer = OBJ_LAYER - 0.01

		animate(AM, 1 SECOND, easing = BOUNCE_EASING, pixel_x = 0, pixel_y = 0)
		animate(layer = orig_layer, easing = JUMP_EASING)
	update()

/obj/machinery/traymachine/set_dir(new_dir)
	if(src.my_tray && src.my_tray.loc != src)
		return
	. = ..()

/obj/machinery/traymachine/set_loc(atom/target)
	if(src.my_tray && src.my_tray.loc != src)
		return
	. = ..()

/obj/machinery/traymachine/Move(atom/target)
	if(src.my_tray && src.my_tray.loc != src)
		return
	. = ..()

///Tray goes in
/obj/machinery/traymachine/proc/collect_tray()
	set name = "close"
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	for( var/atom/movable/A as mob|obj in my_tray.loc)
		if (!(A.anchored) && (istype(A, /obj/item) || (istype(A, /mob)))) //note the tray is anchored
			A.set_loc(src)
	my_tray.set_loc(src)
	update()

///Update the tray machine's sprite
/obj/machinery/traymachine/proc/update()
	if (src.my_tray.loc != src)
		src.icon_state = icon_trayopen
	else
		if ((length(contents) - length(non_tray_contents)) > 1) //the tray lives in contents
			src.icon_state = icon_occupied
		else
			src.icon_state = icon_unoccupied
	return

//Possible old code. To the best of my knowledge this proc is unused (except in sleepers) but it's one that several things mobs can go inside of have
/obj/machinery/traymachine/alter_health()
	return src.loc


//-----------------------------------------------------
/*~ Locking Tray Machine Parent ~*/
//-----------------------------------------------------

//These will not open/close while locked
//Sure hope you coded em to unlock on their own at some point
ABSTRACT_TYPE(/obj/machinery/traymachine/locking)
/obj/machinery/traymachine/locking
	var/locked = FALSE
	power_usage = TRAYMACHINE_DEFAULT_DRAW
	var/powerdraw_use = TRAYMACHINE_DEFAULT_DRAW  //same as power_usage by default
	//crematoria/tanning beds also had a variable called cremating but from what I saw that and locked were always set together so

/obj/machinery/traymachine/locking/attack_hand(mob/user)
	if (locked)
		boutput(user, SPAN_ALERT("It's locked."))
		src.add_fingerprint(user) //because we're not reaching the parent call
		return
	..()

/obj/machinery/traymachine/locking/relaymove(mob/user as mob)
	if (locked)
		return //fuck you
	..()


//-----------------------------------------------------
/*~ Tray ~*/
//-----------------------------------------------------

ABSTRACT_TYPE(/obj/machine_tray)
/obj/machine_tray
	name = "machine tray"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morguet"
	density = TRUE
	layer = FLOOR_EQUIP_LAYER1
	var/obj/machinery/traymachine/my_machine = null
	anchored = ANCHORED
	event_handler_flags = USE_FLUID_ENTER

	//simple subtypes
	morgue
		name = "morgue tray"
		icon_state = "morguet"

	crematorium
		name = "crematorium tray"
		icon_state = "cremat"

/obj/machine_tray/disposing()
	my_machine?.my_tray = null
	qdel(my_machine)
	my_machine = null
	. = ..()

//Fuck knows what the point of this override is but I didn't code it
/obj/machine_tray/Cross(atom/movable/mover)
	if (istype(mover, /obj/item/dummy))
		return 1
	else
		return ..()

/obj/machine_tray/attack_hand(mob/user)
	if (my_machine && my_machine != src.loc)
		my_machine?.collect_tray()

/obj/machine_tray/attack_ai(mob/user as mob)
	attack_hand(user)

/obj/machine_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (!(isobj(O) || ismob(O)) || O.anchored || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, O) > 0 || user.contents.Find(O))
		return
	if (istype(O, /atom/movable/screen) || istype(O, /obj/effects) || istype(O, /obj/ability_button) || istype(O, /obj/item/grab))
		return
	O.set_loc(src.loc)
	if (user != O)
		src.visible_message(SPAN_ALERT("[user] stuffs [O] into [src]!"))
	return


//-----------------------------------------------------
/*~ Morgue ~*/
//-----------------------------------------------------

//Morgues prevent decomposition, but that functionality is handled by /datum/lifeprocess/decomposition
/obj/machinery/traymachine/morgue
	name = "morgue"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"

	tray_type = /obj/machine_tray/morgue

	dir = EAST //IDK why morgues default east but

	icon_trayopen = "morgue0"
	icon_unoccupied = "morgue1"
	icon_occupied = "morgue2"


//-----------------------------------------------------
/*~ Crematorium ~*/
//-----------------------------------------------------

/obj/machinery/traymachine/locking/crematorium
	name = "crematorium"
	desc = "A human incinerator."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema1"
	powerdraw_use = 1500
	var/id = 1 //crema switch uses this when finding crematoria
	var/obj/machinery/crema_switch/igniter = null
	tray_type = /obj/machine_tray/crematorium
	var/active = FALSE

	icon_trayopen = "crema0"
	icon_unoccupied = "crema1"
	icon_occupied = "crema2"

	medical
		id = "medicalcremator"

	New()
		. = ..()
		START_TRACKING

	disposing()
		src.igniter?.crematoriums -= src
		src.igniter = null
		. = ..()
		STOP_TRACKING

/obj/machinery/traymachine/locking/crematorium/proc/cremate(mob/user as mob)
	if (!src || !istype(src))
		return
	if (status & NOPOWER)
		return
	if (src.locked)
		return //don't let you cremate something twice or w/e
	if (src.active)
		return
	if (!src.contents || !length(src.contents))
		src.visible_message(SPAN_ALERT("You hear a hollow crackle, but nothing else happens."))
		return

	src.active = TRUE
	src.visible_message(SPAN_ALERT("You hear a roar as \the [src.name] activates."))
	var/ashes = 0
	power_usage = powerdraw_use //gotta chug them watts
	icon_state = "crema_active"
	playsound(src.loc, 'sound/machines/crematorium.ogg', 90, 0)

	for (var/obj/item/body_bag/bag in contents)
		for (var/obj/O in bag)
			O.set_loc(src)
		for (var/mob/M in bag)
			M.set_loc(src)
		qdel(bag)

	for (var/mob/living/L in contents)
		if (L in non_tray_contents)
			continue
		L.changeStatus("burning", 15 SECONDS)
		if (L in non_tray_contents)
			continue
		if (!L.is_heat_resistant())
			L.TakeDamage("chest", 0, 30)
			if (!isdead(L))
				L.emote("scream")

	sleep(3 SECONDS)

	for (var/i in 1 to 10)
		if(isnull(src))
			return
		for (var/mob/living/L in contents)
			if (L in non_tray_contents)
				continue
			L.changeStatus("burning", 30 SECONDS)

	sleep(6 SECONDS)

	if(isnull(src))
		return
	src.locked = TRUE // only lock when it's too late to escape
	src.visible_message(SPAN_ALERT("\The [src.name] clunks locked!"))
	sleep(1 SECOND)
	for (var/I in contents)
		if (I in non_tray_contents)
			continue
		if (I == my_tray)	//no cremating the tray tyvm
			continue
		if (isliving(I))
			var/mob/living/L = I
			if (!L.is_heat_resistant())
				logTheThing(LOG_COMBAT, user, "cremates [constructTarget(L,"combat")] in a crematorium at [log_loc(src)].")
				for (var/obj/item/W in L)
					if (prob(10))
						W.set_loc(L.loc)
				ashes += 1
			else
				logTheThing(LOG_COMBAT, user, "fails to cremate [constructTarget(L,"combat")] in a crematorium at [log_loc(src)] due to their heat resistance.")
				continue // don't qdel us thanks
		else if (!ismob(I))
			if (prob(max(0, 100 - (ashes * 10))))
				ashes += 1
		qdel(I)

	if(isnull(src))
		return
	src.visible_message(SPAN_ALERT("\The [src.name] finishes and shuts down."))
	src.locked = FALSE
	src.active = FALSE
	power_usage = initial(power_usage)
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)

	while (ashes > 0)
		make_cleanable( /obj/decal/cleanable/ash,src)
		ashes -= 1
	update() //get rid of the active sprite


//-----------------------------------------------------
/*~ Crematorium Switch ~*/
//-----------------------------------------------------

/obj/machinery/crema_switch
	name = "crematorium igniter"
	desc = "Burn baby burn!"
	icon = 'icons/obj/power.dmi'
	icon_state = "crema_switch"
	anchored = ANCHORED
	req_access = list(access_crematorium)
	plane = PLANE_NOSHADOW_ABOVE
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	var/area/area = null
	var/otherarea = null
	var/id = 1
	var/list/obj/machinery/traymachine/locking/crematorium/crematoriums = null

	medical
		id = "medicalcremator"
		req_access = list(access_medical_lockers)

	disposing()
		for (var/obj/machinery/traymachine/locking/crematorium/O in src.crematoriums)
			O.igniter = null
		src.crematoriums = null
		. = ..()

/obj/machinery/crema_switch/New()
	..()
	UnsubscribeProcess()

/obj/machinery/crema_switch/attack_hand(mob/user)
	if (src.allowed(user))
		if (!islist(src.crematoriums))
			src.crematoriums = list()
			for_by_tcl(C, /obj/machinery/traymachine/locking/crematorium)
				if (C.id == src.id)
					src.crematoriums.Add(C)
					C.igniter = src
		for (var/obj/machinery/traymachine/locking/crematorium/C as anything in src.crematoriums)
			if (!C.locked && C.my_tray.loc == C) //don't activate if the tray's not in ffs
				C.cremate(user)
	else
		boutput(user, SPAN_ALERT("Access denied."))


//-----------------------------------------------------
/*~ Tanning Bed ~*/
//-----------------------------------------------------

/obj/machinery/traymachine/locking/tanning
	name = "tanning bed"
	desc = "Now bringing the rays of Space Hawaii to your local spa!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "tanbed"
	var/id = 2 //this gets used when the tanning computer links to the bed
	powerdraw_use = 1000 //power cost while tanning
	//mats = 30

	icon_trayopen = "tanbed"
	icon_unoccupied = "tanbed"
	icon_occupied = "tanbed1"
	tray_type = /obj/machine_tray/tanning

	var/emagged = FALSE //heh heh
	var/settime = 10 SECONDS
	var/tanningcolor = rgb(205,88,34) //Change to tan people into hillarious colors!
	var/tanningmodifier = 0.03 //How fast do you want to go to your tanningcolor?
	var/obj/machinery/computer/tanning/linked = null

	New()
		..()
		START_TRACKING

	disposing()
		src.linked?.linked = null
		src.linked = null
		. = ..()
		STOP_TRACKING

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (src.emagged)
			return FALSE
		if (user)
			user.show_text("\The [src]'s safetey lock has been disabled.", "red")
		src.emagged = TRUE
		src.tanningmodifier = 0.2
		return TRUE

	proc/cremate(mob/user as mob)
		if (!src || !istype(src))
			return
		if (status & NOPOWER)
			return
		if (src.locked)
			return //don't let you cremate something twice or w/e
		if (!src.contents || !length(src.contents))
			src.visible_message(SPAN_ALERT("You hear the lights turn on for a second, then turn off."))
			return

		src.visible_message(SPAN_ALERT("You hear a faint buzz as \the [src] activates."))
		playsound(src.loc, 'sound/machines/shieldup.ogg', 30, 1)
		src.locked = TRUE
		power_usage = powerdraw_use
		icon_state = "tanbed_active"

		for (var/mob/M in contents)
			if (isliving(M))
				var/mob/living/L = M
				for (var/i = 1 SECOND, i <= src.settime; i += 1 SECOND)
					sleep(1 SECOND)
					if(ishuman(L))
						var/mob/living/carbon/human/H = L
						if (src.emagged)
							H.TakeDamage("All", 0, 10, 0, DAMAGE_BURN)
							if (i % (2 SECONDS)) //message limiter
								boutput(H, SPAN_ALERT("Your skin feels like it's on fire!"))
						else if (!H.wear_suit)
							H.TakeDamage("All", 0, 2, 0, DAMAGE_BURN)
							if (i % (2 SECONDS)) //limiter
								boutput(H, SPAN_ALERT("Your skin feels hot!"))
						if (!(H.glasses && istype(H.glasses, /obj/item/clothing/glasses/sunglasses))) //Always wear protection
							H.take_eye_damage(1, 2)
							H.change_eye_blurry(2)
							H.changeStatus("stunned", 1 SECOND)
							H.change_misstep_chance(5)
							boutput(H, SPAN_ALERT("Your eyes sting!"))
						if (H.bioHolder.mobAppearance.s_tone)
							var/currenttone = H.bioHolder.mobAppearance.s_tone
							var/newtone = BlendRGB(currenttone, src.tanningcolor, src.tanningmodifier) //Make them tan slowly
							H.bioHolder.mobAppearance.s_tone = newtone
							H.set_face_icon_dirty()
							H.set_body_icon_dirty()
							if (H.limbs)
								H.limbs.reset_stone()
							H.update_colorful_parts()
						if (isvampire(H))
							H.TakeDamage("All", 0, 15, 0, DAMAGE_BURN)
							if (prob(15) && isalive(H))
								H.emote("scream")
							if (i % (2 SECONDS))
								boutput(H, SPAN_ALERT("[pick("Your skin is melting!", "This false sun burns just like a real one!", "The light! <b>IT BURNS</b>!")]"))
								playsound(src, 'sound/impact_sounds/burn_sizzle.ogg', 50, TRUE)
							if (isdead(H))
								make_cleanable(/obj/decal/cleanable/ash, src)
								H.unequip_all()
								H.remove()
								src.visible_message(SPAN_ALERT("A puff of smoke erupts from the machine as it grinds to a halt! It smells like a graveyard caught fire!"))
								var/turf/T = get_turf(src)
								if (istype(T))
									var/datum/effects/system/bad_smoke_spread/smoke_effect = new /datum/effects/system/bad_smoke_spread/(T)
									smoke_effect.set_up(15, 0, T, null, "#000000")
									smoke_effect.start()
								end_tanning()

								return
				if (emagged && isdead(M))
					M.remove()
					make_cleanable( /obj/decal/cleanable/ash,src)

		SPAWN(src.settime)
			if (src)
				end_tanning()

	proc/end_tanning()
		src.visible_message(SPAN_ALERT("The [src.name] finishes and shuts down."))
		src.locked = FALSE
		power_usage = initial(power_usage)
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
		update()

//-----------------------------------------------------
/*~ Tanning Bed Tray ~*/
//-----------------------------------------------------

/obj/machine_tray/tanning
	name = "tanning bed tray"
	desc = "The perfect place to lay down after a long day indoors."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "tantray_empty"

	var/obj/item/light/tube/tanningtube = null
	var/image/trayoverlay
	var/datum/light/light

	proc/generate_overlay_icon(var/tubecolor)
		if (!trayoverlay)
			src.trayoverlay = image('icons/obj/stationobjs.dmi', "tantray_overlay")
		UpdateOverlays(null, "tube")
		if (tanningtube)
			src.trayoverlay.color = tubecolor
			UpdateOverlays(trayoverlay, "tube")

	proc/send_new_tancolor(var/tubecolor)
		if (my_machine && istype (my_machine, /obj/machinery/traymachine/locking/tanning))
			var/obj/machinery/traymachine/locking/tanning/tanningbed = my_machine
			tanningbed.tanningcolor = tubecolor

	New()
		..()
		tanningtube = new /obj/item/light/tube(src)
		tanningtube.name = "stock tanning light tube"
		tanningtube.desc = "Fancy. But not really."
		tanningtube.color_r = 0.7
		tanningtube.color_g = 0.3
		tanningtube.color_b = 0.5

		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.5)
		light.set_color(tanningtube.color_r, tanningtube.color_g, tanningtube.color_b)

		var/tanningtubecolor = rgb(tanningtube.color_r * 255, tanningtube.color_g * 255, tanningtube.color_b * 255)

		generate_overlay_icon(tanningtubecolor)

		send_new_tancolor(tanningtubecolor)

	disposing()
		src.tanningtube = null
		src.trayoverlay = null
		. = ..()

	attackby(var/obj/item/P, mob/user)

		if (istype(P, /obj/item/light/tube) && !length(src.contents))
			var/obj/item/light/tube/G = P
			boutput(user, SPAN_NOTICE("You put \the [G.name] into \the [src.name]."))
			user.drop_item()
			G.set_loc(src)
			src.tanningtube = G
			var/tanningtubecolor = rgb(tanningtube.color_r * 255, tanningtube.color_g * 255, tanningtube.color_b * 255)
			generate_overlay_icon(tanningtubecolor)
			send_new_tancolor(tanningtubecolor)
			if (src.light)
				light.set_color(tanningtube.color_r, tanningtube.color_g, tanningtube.color_b)
				light.set_brightness(0.5)
		else if (ispryingtool(P) && length(src.contents)) //pry out the tube with a crowbar
			boutput(user, SPAN_NOTICE("You pry out \the [src.tanningtube.name] from \the [src.name]."))
			src.tanningtube.set_loc(src.loc)
			src.tanningtube = null
			generate_overlay_icon() //nulling overlay
			if (src.light)
				light.set_color(0, 0, 0)
				light.set_brightness(0)
		else ..()


//-----------------------------------------------------
/*~ Tanning Computer ~*/
//-----------------------------------------------------

/obj/machinery/computer/tanning
	name = "tanning computer"
	desc = "Used to control a tanning bed."
	icon = 'icons/obj/stationobjs.dmi'
	//mats = 20
	id = 2
	icon_state = "tanconsole"
	var/state_str = ""
	var/obj/machinery/traymachine/locking/tanning/linked = null //The linked tanning bed

	New()
		..()
		get_link()

	disposing()
		src.linked?.linked = null
		src.linked = null
		. = ..()

	proc/get_link()
		for(var/obj/machinery/traymachine/locking/tanning/C in by_type[/obj/machinery/traymachine/locking/tanning])
			if(C.z == src.z && C.id == src.id && C != src)
				linked = C
				C.linked = src
				break

	proc/find_tray_tube()
		if (linked.my_tray && istype(linked.my_tray, /obj/machine_tray/tanning))
			var/obj/machine_tray/tanning/tray = linked.my_tray
			if (tray.tanningtube)
				return TRUE

	proc/get_state_string()
		if(linked == null) get_link()
		if(linked == null) return "ERROR: No tanning beds found."

		if(find_tray_tube() != 1) return "No light tube found in the tanning tray."
		if(linked.locked) return "Tanning in progress. Please wait."
		if(linked.locked == 0) return "Tanning bed idle."

		return "Unknown Error Encountered."

	attack_hand(var/mob/user, params)
		if (..(user))
			return

		state_str = src.get_state_string()

		var/dat = ""
		dat += "<b>Tanning Bed Status:</b><BR>"
		dat += "[state_str]<BR>"
		dat += "Set Time: [linked ? (linked.settime / (1 SECOND)) : "--"] seconds<BR>"
		dat += "<b>Tanning Bed Control:</b><BR>"
		dat += "<A href='byond://?src=\ref[src];toggle=1'>Activate Tanning Bed</A><BR>"
		dat += "<A href='byond://?src=\ref[src];timer=1'>Delayed Activation</A><BR>"
		dat += "<A href='byond://?src=\ref[src];settime=1'>Increase Time</A><BR>"
		dat += "<A href='byond://?src=\ref[src];unsettime=1'>Decrease Time</A><BR>"

		if (user.client?.tooltipHolder)
			user.client.tooltipHolder.showClickTip(src, list(
				"params" = params,
				"title" = src.name,
				"content" = dat,
			))

		return

	Topic(href, href_list)
		if (..(href, href_list))
			return

		if (href_list["toggle"])
			if (linked && !linked.locked && find_tray_tube() && linked.my_tray.loc == linked)
				playsound(src.loc, 'sound/machines/bweep.ogg', 20, 1)
				logTheThing(LOG_STATION, usr, "activated the tanning bed at [usr.loc.loc] ([log_loc(usr)])")
				linked.cremate()

		else if (href_list["timer"])
			sleep (10 SECONDS)
			if (linked && !linked.locked && find_tray_tube() && linked.my_tray.loc == linked)
				playsound(src.loc, 'sound/machines/bweep.ogg', 20, 1)
				logTheThing(LOG_STATION, usr, "activated the tanning bed at [usr.loc.loc] ([log_loc(usr)])")
				linked.cremate()

		else if (href_list["settime"])
			if (linked && linked.settime < TANNING_BED_MAX_TIME)
				linked.settime += 1 SECOND

		else if (href_list["unsettime"])
			if (linked && linked.settime > 0)
				linked.settime -= 1 SECOND

		src.updateDialog()

#undef TRAYMACHINE_DEFAULT_DRAW
#undef TANNING_BED_MAX_TIME
