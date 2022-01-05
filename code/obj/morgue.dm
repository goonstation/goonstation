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



//-----------------------------------------------------
/*~ Tray Machine Parent ~*/
//-----------------------------------------------------

ABSTRACT_TYPE(/obj/machinery/traymachine)
/obj/machinery/traymachine
	name = "tray machine"
	desc = "This thing sure has a big tray that goes vwwwwwwsh when you slide it in and out."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"
	density = 1
	anchored = 1.0
	power_usage = 250 //IDK I just put a number

	//tray related variables
	var/obj/machine_tray/my_tray = null
	var/tray_type = /obj/machine_tray //type of tray the machine should be spawning

	//Currently no tray machine accepts anything into its contents except through tray loading but anything in this list won't get ejected on opening
	var/list/non_tray_contents = list()

	//icon_state names for the default update proc, unused if you override that and don't use them yourself.
	var/icon_trayopen = "morgue0"
	var/icon_unoccupied = "morgue1"
	var/icon_occupied = "morgue2"

	//TESTING SHIT PLEASE IGNORE
	var/obj/testitem

/obj/machinery/traymachine/New()
	my_tray = new tray_type(src) //Heck this lazy init tray spawning,
	my_tray.set_dir(src.dir)
	my_tray.my_machine = src
	my_tray.layer = OBJ_LAYER - 0.02
	//TESTING SHIT PLEASE IGNORE
	testitem = new /obj/item/device/radio/headset/deaf(src)
	non_tray_contents += testitem

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

/obj/machinery/traymachine/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	if (my_tray && my_tray.loc != src)
		collect_tray()
	else
		eject_tray()

//Fun fact you can label these things
/obj/machinery/traymachine/morgue/attackby(P as obj, mob/user as mob)
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
		if(1.0)
			chance = 100
			return
		if(2.0)
			chance = 50
			return
		if(3.0)
			chance = 5
			return
	if (prob(chance))
		for(var/atom/movable/A as mob|obj in src) //The reason for this loop here (when there's a similar one in disposing) is contents also get exploded
			if (!(A in non_tray_contents))
				A.set_loc(src.loc)
				A.ex_act(severity)
		qdel(src)
	return

//Someone is trying to move from inside
/obj/machinery/traymachine/morgue/relaymove(mob/user as mob)
	if (user.stat)
		return
	eject_tray()


///Tray comes out - probably override this if your tray should move weirdly
/obj/machinery/traymachine/proc/eject_tray()
	playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)

	var/turf/T_src = get_turf(src)
	var/turf/T = get_step(src, src.dir)

	//handle animation and ejection of contents
	for(var/atom/movable/AM as anything in src)
		if (AM in non_tray_contents)
			continue
		AM.set_loc(T)
		AM.pixel_x += 28 * (T_src.x - T.x) // 28 instead of 32 to obscure the double handle on morgues
		AM.pixel_y += 28 * (T_src.y - T.y)

		var/orig_layer = AM.layer
		if (AM != my_tray)
			AM.layer = OBJ_LAYER - 0.01

		animate(AM, 1 SECOND, easing = BOUNCE_EASING, pixel_x = 0, pixel_y = 0)
		animate(layer = orig_layer, easing = JUMP_EASING)
	update()

///Tray goes in
/obj/machinery/traymachine/proc/collect_tray()
	playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
	for( var/atom/movable/A as mob|obj in my_tray.loc)
		if (!( A.anchored )) //note the tray is anchored
			A.set_loc(src)
	my_tray.set_loc(src)
	update()

///Update the tray machine's sprite
/obj/machinery/traymachine/proc/update()
	if (src.my_tray.loc != src)
		src.icon_state = icon_trayopen
	else
		if (src.contents.len > 1) //the tray lives in contents
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
/obj/machinery/traymachine/locking
	var/locked = FALSE
	//crematoria/tanning beds also had a variable called cremating but from what I saw that and locked were always set together so

/obj/machinery/traymachine/locking/attack_hand(mob/user as mob)
	if (locked)
		boutput(usr, "<span class='alert'>It's locked.</span>")
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

/obj/machine_tray
	name = "machine tray"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morguet"
	density = 1
	layer = FLOOR_EQUIP_LAYER1
	var/obj/machinery/traymachine/my_machine = null
	anchored = 1.0
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

/obj/machine_tray/attack_hand(mob/user as mob)
	if (my_machine && my_machine != src.loc)
		my_machine?.collect_tray()

/obj/machine_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (!(isobj(O) || ismob(O)) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(O))
		return
	if (istype(O, /atom/movable/screen) || istype(O, /obj/effects) || istype(O, /obj/ability_button) || istype(O, /obj/item/grab))
		return
	O.set_loc(src.loc)
	if (user != O)
		src.visible_message("<span class='alert'>[user] stuffs [O] into [src]!</span>")
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
	//var/obj/c_tray/connected = null
	//var/cremating = 0
	var/id = 1
	var/obj/machinery/crema_switch/igniter = null
	tray_type = /obj/machine_tray/crematorium

	icon_trayopen = "crema0"
	icon_unoccupied = "crema1"
	icon_occupied = "crema2"

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
	if (src.locked)
		return //don't let you cremate something twice or w/e
	if (!src.contents || !length(src.contents))
		src.visible_message("<span class='alert'>You hear a hollow crackle, but nothing else happens.</span>")
		return

	src.visible_message("<span class='alert'>You hear a roar as \the [src.name] activates.</span>")
	src.locked = 1
	var/ashes = 0

	for (var/M in contents)
		if (M == my_tray) continue //no cremating the tray tyvm
		if (isliving(M))
			var/mob/living/L = M
			SPAWN_DBG(0)
				L.changeStatus("stunned", 10 SECONDS)

				var/i
				for (i = 0, i < 10, i++)
					sleep(1 SECOND)
					L.TakeDamage("chest", 0, 30)
					if (!isdead(L) && prob(25))
						L.emote("scream")

				for (var/obj/item/W in L)
					if (prob(10))
						W.set_loc(L.loc)

				logTheThing("combat", user, L, "cremates [constructTarget(L,"combat")] in a crematorium at [log_loc(src)].")
				L.remove()
				ashes += 1

		else if (!ismob(M))
			if (prob(max(0, 100 - (ashes * 10))))
				ashes += 1
			qdel(M)

	SPAWN_DBG(10 SECONDS)
		if (src)
			src.visible_message("<span class='alert'>\The [src.name] finishes and shuts down.</span>")
			src.locked = 0
			playsound(src.loc, "sound/machines/ding.ogg", 50, 1)

			while (ashes > 0)
				make_cleanable( /obj/decal/cleanable/ash,src)
				ashes -= 1

	return


//-----------------------------------------------------
/*~ Crematorium Switch ~*/
//-----------------------------------------------------

/obj/machinery/crema_switch
	name = "crematorium igniter"
	desc = "Burn baby burn!"
	icon = 'icons/obj/power.dmi'
	icon_state = "crema_switch"
	anchored = 1.0
	req_access = list(access_crematorium)
	object_flags = CAN_REPROGRAM_ACCESS
	var/on = 0
	var/area/area = null
	var/otherarea = null
	var/id = 1
	var/list/obj/machinery/traymachine/locking/crematorium/crematoriums = null

	disposing()
		for (var/obj/machinery/traymachine/locking/crematorium/O in src.crematoriums)
			O.igniter = null
		src.crematoriums = null
		. = ..()

/obj/machinery/crema_switch/New()
	..()
	UnsubscribeProcess()

/obj/machinery/crema_switch/attack_hand(mob/user as mob)
	if (src.allowed(user))
		if (!islist(src.crematoriums))
			src.crematoriums = list()
			for_by_tcl(C, /obj/machinery/traymachine/locking/crematorium)
				if (C.id == src.id)
					src.crematoriums.Add(C)
					C.igniter = src
		for (var/obj/machinery/traymachine/locking/crematorium/C as anything in src.crematoriums)
			if (!C.locked)
				C.cremate(user)
	else
		boutput(user, "<span class='alert'>Access denied.</span>")
	return

//-----------------------------------------------------
/*~ Tanning Bed ~*/
//-----------------------------------------------------

/obj/machinery/traymachine/locking/tanning
	name = "tanning bed"
	desc = "Now bringing the rays of Space Hawaii to your local spa!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "tanbed"
	var/id = 2 //this gets used when the tanning computer links to the bed, pretty sure it's a weird thing because tanning beds used to be crematoria
	mats = 30

	icon_trayopen = "tanbed"
	icon_unoccupied = "tanbed"
	icon_occupied = "tanbed1"
	tray_type = /obj/machine_tray/tanning

	var/emagged = 0 //heh heh
	var/primed = 0 //Prime the bed via the console
	var/settime = 10 //How long? (s)
	var/tanningcolor = rgb(205,88,34) //Change to tan people into hillarious colors!
	var/tanningmodifier = 0.03 //How fast do you want to go to your tanningcolor?
	var/obj/machinery/computer/tanning/linked = null

	disposing()
		src.linked?.linked = null
		src.linked = null
		. = ..()

	update()
		if (src.contents.len)
			src.icon_state = "tanbed1"
		else
			src.icon_state = "tanbed"
		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (src.emagged)
			return 0
		if (user)
			user.show_text("\The [src]'s saftey lock has been disabled.", "red")
		src.emagged = 1
		src.tanningmodifier = 0.2
		return 1

	proc/cremate(mob/user as mob)
		if (!src || !istype(src))
			return
		if (src.locked)
			return //don't let you cremate something twice or w/e
		if (!src.contents || !length(src.contents))
			src.visible_message("<span class='alert'>You hear the lights turn on for a second, then turn off.</span>")
			return

		src.visible_message("<span class='alert'>You hear a faint buzz as \the [src] activates.</span>")
		playsound(src.loc, "sound/machines/shieldup.ogg", 30, 1)
		src.locked = 1

		for (var/mob/M in contents)
			if (isliving(M))
				var/mob/living/L = M
				for (var/i in 1 to src.settime)
					sleep(1 SECOND)
					if(ishuman(L))
						var/mob/living/carbon/human/H = L
						if (src.emagged)
							H.TakeDamage("All", 0, 10, 0, DAMAGE_BURN)
							if (src.settime % 2) //message limiter
								boutput(H, "<span class='alert'>Your skin feels like it's on fire!</span>")
						else if (!H.wear_suit)
							H.TakeDamage("All", 0, 2, 0, DAMAGE_BURN)
							if (src.settime % 2) //limiter
								boutput(H, "<span class='alert'>Your skin feels hot!</span>")
						if (!(H.glasses && istype(H.glasses, /obj/item/clothing/glasses/sunglasses/tanning))) //Always wear protection
							H.take_eye_damage(1, 2)
							H.change_eye_blurry(2)
							H.changeStatus("stunned", 1 SECOND)
							H.change_misstep_chance(5)
							boutput(H, "<span class='alert'>Your eyes sting!</span>")
						if (H.bioHolder.mobAppearance.s_tone)
							var/currenttone = H.bioHolder.mobAppearance.s_tone
							var/newtone = BlendRGB(currenttone, src.tanningcolor, src.tanningmodifier) //Make them tan slowly
							H.bioHolder.mobAppearance.s_tone = newtone
							H.set_face_icon_dirty()
							H.set_body_icon_dirty()
							if (H.limbs)
								H.limbs.reset_stone()
							H.update_colorful_parts()
				if (emagged && isdead(M))
					qdel(M)
					make_cleanable( /obj/decal/cleanable/ash,src)

		SPAWN_DBG(src.settime * 10)
			if (src)
				src.visible_message("<span class='alert'>The [src.name] finishes and shuts down.</span>")
				src.locked = 0
				playsound(src.loc, "sound/machines/ding.ogg", 50, 1)
		return

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
		src.overlays = null
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
		tanningtube.color_g = 0.5
		tanningtube.color_b = 0.3

		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.5)
		light.set_color(tanningtube.color_r, tanningtube.color_g, tanningtube.color_b)

		var/tanningtubecolor = rgb(tanningtube.color_r * 255, tanningtube.color_b * 255, tanningtube.color_g * 255)

		generate_overlay_icon(tanningtubecolor)

		send_new_tancolor(tanningtubecolor)

	disposing()
		src.tanningtube = null
		src.trayoverlay = null
		. = ..()

	attackby(var/obj/item/P as obj, mob/user as mob)
		..()
		if (istype(P, /obj/item/light/tube) && !length(src.contents))
			var/obj/item/light/tube/G = P
			boutput(user, "<span class='notice'>You put \the [G.name] into \the [src.name].</span>")
			user.drop_item()
			G.set_loc(src)
			src.tanningtube = G
			var/tanningtubecolor = rgb(tanningtube.color_r * 255, tanningtube.color_b * 255, tanningtube.color_g * 255)
			generate_overlay_icon(tanningtubecolor)
			send_new_tancolor(tanningtubecolor)
			if (src.light)
				light.set_color(tanningtube.color_r, tanningtube.color_g, tanningtube.color_b)
				light.set_brightness(0.5)

		if (ispryingtool(P) && length(src.contents)) //pry out the tube with a crowbar
			boutput(user, "<span class='notice'>You pry out \the [src.tanningtube.name] from \the [src.name].</span>")
			src.tanningtube.set_loc(src.loc)
			src.tanningtube = null
			generate_overlay_icon() //nulling overlay
			if (src.light)
				light.set_color(0, 0, 0)
				light.set_brightness(0)


//-----------------------------------------------------
/*~ Tanning Computer ~*/
//-----------------------------------------------------

/obj/machinery/computer/tanning
	name = "tanning computer"
	desc = "Used to control a tanning bed."
	icon = 'icons/obj/stationobjs.dmi'
	mats = 20
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
				return 1

	proc/get_state_string()
		if(linked == null) get_link()
		if(linked == null) return "ERROR: No tanning beds found."

		if(find_tray_tube() != 1) return "No light tube found in the tanning tray."
		if(linked.locked) return "Tanning in progress. Please wait."
		if(linked.locked == 0) return "Tanning bed idle."

		return "Unknown Error Encountered."

	attack_hand(var/mob/user as mob, params)
		if (..(user))
			return

		state_str = src.get_state_string()

		var/dat = ""
		dat += "<b>Tanning Bed Status:</b><BR>"
		dat += "[state_str]<BR>"
		dat += "Set Time: [linked ? linked.settime : "--"]<BR>"
		dat += "<b>Tanning Bed Control:</b><BR>"
		dat += "<A href='?src=\ref[src];toggle=1'>Activate Tanning Bed</A><BR>"
		dat += "<A href='?src=\ref[src];timer=1'>Delayed Activation</A><BR>"
		dat += "<A href='?src=\ref[src];settime=1'>Increase Time</A><BR>"
		dat += "<A href='?src=\ref[src];unsettime=1'>Decrease Time</A><BR>"

		if (user.client.tooltipHolder)
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
			if (linked && !linked.locked && find_tray_tube() == 1)
				playsound(src.loc, "sound/machines/bweep.ogg", 20, 1)
				linked.cremate()
				logTheThing("station", usr, null, "activated the tanning bed at [usr.loc.loc] ([showCoords(usr.x, usr.y, usr.z)])")

		else if (href_list["timer"])
			sleep (100)
			if (linked && !linked.locked && find_tray_tube() == 1)
				playsound(src.loc, "sound/machines/bweep.ogg", 20, 1)
				linked.cremate()
				logTheThing("station", usr, null, "activated the tanning bed at [usr.loc.loc] ([showCoords(usr.x, usr.y, usr.z)])")

		else if (href_list["settime"])
			if (linked && linked.settime < 20)
				linked.settime++

		else if (href_list["unsettime"])
			if (linked && linked.settime > 0)
				linked.settime--

		src.updateDialog()
		return
