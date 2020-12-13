/obj/morgue
	name = "morgue"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"
	density = 1
	var/obj/m_tray/connected = null
	anchored = 1.0
	dir = EAST

	disposing()
		src.connected?.connected = null
		qdel(src.connected)
		src.connected = null
		if (length(src.contents))
			var/turf/T = get_turf(src)
			for (var/atom/movable/AM in contents)
				AM.set_loc(T)
		. = ..()

/obj/morgue/proc/update()
	if (src.connected.loc != src)
		src.icon_state = "morgue0"
	else
		if (src.contents.len > 1) //the tray lives in contents
			src.icon_state = "morgue2"
		else
			src.icon_state = "morgue1"
	return

/obj/morgue/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.set_loc(src.loc)
				A.ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)
				return
	return

/obj/morgue/alter_health()
	return src.loc

/obj/morgue/attack_hand(mob/user as mob)
	if (src.connected && src.connected.loc != src)
		for( var/atom/movable/A as mob|obj in src.connected.loc)
			if (!( A.anchored ))
				A.set_loc(src)
		playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
		src.connected.set_loc(src)
	else
		playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
		if (!connected)
			src.connected = new /obj/m_tray(src.loc)
		else
			src.connected.set_loc(src.loc)
		step(src.connected, src.dir)//EAST)
		src.connected.layer = OBJ_LAYER
		var/turf/T = get_step(src, src.dir)//EAST)
		if (T.contents.Find(src.connected))
			src.connected.connected = src
			for(var/atom/movable/A as mob|obj in src)
				A.set_loc(src.connected.loc)
			src.connected.icon_state = "morguet"
		else
			src.connected.set_loc(src)
	src.add_fingerprint(user)
	src.update()
	return

/obj/morgue/attackby(P as obj, mob/user as mob)
	src.add_fingerprint(user)
	if (istype(P, /obj/item/pen))
		var/t = input(user, "What would you like the label to be?", src.name, null) as null|text
		if (!t)
			return
		if (user.equipped() != P)
			return
		if ((!in_range(src, usr) && src.loc != user))
			return
		t = copytext(adminscrub(t),1,128)
		if (t)
			src.name = "Morgue- '[t]'"
		else
			src.name = "Morgue"
	else
		return ..()

/obj/morgue/relaymove(mob/user as mob)
	if (user.stat)
		return
	if (!connected)
		src.connected = new /obj/m_tray(src.loc)
	else
		src.connected.set_loc(src.loc)
	step(src.connected, src.dir)//EAST)
	src.connected.layer = OBJ_LAYER
	var/turf/T = get_step(src, src.dir)//EAST)
	if (T.contents.Find(src.connected))
		src.connected.connected = src
		for(var/atom/movable/A as mob|obj in src)
			A.set_loc(src.connected.loc)
			//Foreach goto(106)
		src.connected.icon_state = "morguet"
	else
		src.connected.set_loc(src)
	src.update()
	return

/obj/m_tray
	name = "morgue tray"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morguet"
	density = 1
	layer = FLOOR_EQUIP_LAYER1
	var/obj/morgue/connected = null
	anchored = 1.0
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS

	disposing()
		src.connected?.connected = null
		qdel(src.connected)
		src.connected = null
		. = ..()

/obj/m_tray/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (istype(mover, /obj/item/dummy))
		return 1
	else
		return ..()

/obj/m_tray/attack_hand(mob/user as mob)
	if (src.connected && src.connected != src.loc)
		for(var/atom/movable/A as mob|obj in src.loc)
			if (!( A.anchored ))
				A.set_loc(src.connected)
			//Foreach goto(26)
		playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
		src.connected.update()
		add_fingerprint(user)
		//SN src = null
		src.set_loc(src.connected)
		return
	return

/obj/m_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (!(isobj(O) || ismob(O)) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(O)) //user.contents.Find(src) WHY WERE WE LOOKING FOR THE MORGUE TRAY IN THE USER
		return
	if (istype(O, /obj/screen) || istype(O, /obj/effects) || istype(O, /obj/ability_button) || istype(O, /obj/item/grab))
		return
	O.set_loc(src.loc)
	if (user != O)
		src.visible_message("<span class='alert'>[user] stuffs [O] into [src]!</span>")
			//Foreach goto(99)
	return


/obj/crematorium
	name = "crematorium"
	desc = "A human incinerator."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema1"
	density = 1
	var/obj/c_tray/connected = null
	anchored = 1.0
	var/cremating = 0
	var/id = 1
	var/locked = 0
	var/obj/machinery/crema_switch/igniter = null

	New()
		. = ..()
		START_TRACKING

	disposing()
		src.igniter?.crematoriums -= src
		src.igniter = null
		src.connected?.connected = null
		qdel(src.connected)
		src.connected = null
		if (length(src.contents))
			var/turf/T = get_turf(src)
			for (var/atom/movable/AM in contents)
				AM.set_loc(T)
		. = ..()
		STOP_TRACKING

/obj/crematorium/proc/update()
	if (src.connected.loc != src.loc)
		src.icon_state = "crema0"
	else
		if (src.contents.len > 1)  //the tray lives in contents
			src.icon_state = "crema2"
		else
			src.icon_state = "crema1"
	return

/obj/crematorium/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.set_loc(src.loc)
				A.ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)
				return
	return

/obj/crematorium/alter_health()
	return src.loc

/obj/crematorium/attack_hand(mob/user as mob)
//	if (cremating) AWW MAN! THIS WOULD BE SO MUCH MORE FUN ... TO WATCH
//		user.show_message("<span class='alert'>Uh-oh, that was a bad idea.</span>", 1)
//		//boutput(usr, "Uh-oh, that was a bad idea.")
//		src:loc:poison += 20000000
//		src:loc:firelevel = src:loc:poison
//		return
	if (cremating)
		boutput(usr, "<span class='alert'>It's locked.</span>")
		return
	if ((src.connected && src.connected.loc != src) && (src.locked == 0))
		for(var/atom/movable/A as mob|obj in src.connected.loc)
			if (!( A.anchored ))
				A.set_loc(src)
		playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
		src.connected.set_loc(src)
	else if (src.locked == 0)
		playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
		if (!connected)
			src.connected = new /obj/c_tray(src.loc)
		else
			src.connected.set_loc(src.loc)
		step(src.connected, SOUTH)
		src.connected.layer = OBJ_LAYER
		var/turf/T = get_step(src, SOUTH)
		if (T.contents.Find(src.connected))
			src.connected.connected = src
			src.update()
			for(var/atom/movable/A as mob|obj in src)
				A.set_loc(src.connected.loc)
			src.connected.icon_state = "cremat"
		else
			src.connected.set_loc(src)
	src.add_fingerprint(user)
	update()

/obj/crematorium/attackby(P as obj, mob/user as mob)
	if (istype(P, /obj/item/pen))
		var/t = input(user, "What would you like the label to be?", src.name, null) as null|text
		if (!t)
			return
		if (user.equipped() != P)
			return
		if ((!in_range(src, usr) > 1 && src.loc != user))
			return
		t = copytext(adminscrub(t),1,128)
		if (t)
			src.name = "Crematorium- '[t]'"
		else
			src.name = "Crematorium"
	src.add_fingerprint(user)
	return

/obj/crematorium/relaymove(mob/user as mob)
	if (user.stat || locked)
		return
	if (!connected)
		src.connected = new /obj/c_tray(src.loc)
	else
		src.connected.set_loc(src.loc)
	step(src.connected, SOUTH)
	src.connected.layer = OBJ_LAYER
	var/turf/T = get_step(src, SOUTH)
	if (T.contents.Find(src.connected))
		src.connected.connected = src
		src.icon_state = "crema0"
		for(var/atom/movable/A as mob|obj in src)
			A.set_loc(src.connected.loc)
		src.connected.icon_state = "cremat"
	else
		src.connected.set_loc(src)
	src.update()
	return

/obj/crematorium/proc/cremate(mob/user as mob)
	if (!src || !istype(src))
		return
	if (src.cremating)
		return //don't let you cremate something twice or w/e
	if (!src.contents || !src.contents.len)
		src.visible_message("<span class='alert'>You hear a hollow crackle, but nothing else happens.</span>")
		return

	src.visible_message("<span class='alert'>You hear a roar as \the [src.name] activates.</span>")
	src.cremating = 1
	src.locked = 1
	var/ashes = 0

	for (var/M in contents)
		if (M == src.connected) continue //no cremating the tray tyvm
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
			src.cremating = 0
			src.locked = 0
			playsound(src.loc, "sound/machines/ding.ogg", 50, 1)

			while (ashes > 0)
				make_cleanable( /obj/decal/cleanable/ash,src)
				ashes -= 1

	return

/obj/c_tray
	name = "crematorium tray"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "cremat"
	density = 1
	layer = FLOOR_EQUIP_LAYER1
	var/obj/crematorium/connected = null
	anchored = 1.0
	var/datum/light/light //Only used for tanning beds.
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS

	disposing()
		src.connected?.connected = null
		src.light = null
		qdel(src.connected)
		src.connected = null
		. = ..()

/obj/c_tray/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (istype(mover, /obj/item/dummy))
		return 1
	else
		return ..()

/obj/c_tray/attack_hand(mob/user as mob)
	if (src.connected && src.connected != src.loc)
		for(var/atom/movable/A as mob|obj in src.loc)
			if (!( A.anchored ))
				A.set_loc(src.connected)
		playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
		src.connected.update()
		add_fingerprint(user)
		//SN src = null
		src.set_loc(src.connected)
		return
	return

/obj/c_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (!(isobj(O) || ismob(O)) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(O))
		return
	if (istype(O, /obj/screen) || istype(O, /obj/effects) || istype(O, /obj/ability_button) || istype(O, /obj/item/grab))
		return
	O.set_loc(src.loc)
	if (user != O)
		user.visible_message("<span class='alert'>[user] stuffs [O] into [src]!</span>", "<span class='alert'>You stuff [O] into [src]!</span>")
	return

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
	var/list/obj/crematorium/crematoriums = null

	disposing()
		for (var/obj/crematorium/O in src.crematoriums)
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
			for_by_tcl(C, /obj/crematorium)
				if (C.id == src.id)
					src.crematoriums.Add(C)
					C.igniter = src
		for (var/obj/crematorium/C as() in src.crematoriums)
			if (!C.cremating)
				C.cremate(user)
	else
		boutput(user, "<span class='alert'>Access denied.</span>")
	return


/obj/crematorium/tanning
	name = "tanning bed"
	desc = "Now bringing the rays of Space Hawaii to your local spa!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "tanbed"
	connected = null
	cremating = 0 //yes im going to keep this var name
	id = 2
	locked = 0
	mats = 30
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

	attack_hand(mob/user as mob)
		if (cremating)
			boutput(usr, "<span class='alert'>It's locked.</span>")
			return
		if ((src.connected && src.connected.loc != src) && (src.locked == 0))
			for(var/atom/movable/A as mob|obj in src.connected.loc)
				if (!( A.anchored ))
					A.set_loc(src)
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
			src.connected.set_loc(src)
		else if (src.locked == 0)
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
			if (!connected)
				src.connected = new /obj/c_tray/tanning(src.loc)
			else
				src.connected.set_loc(src.loc)
			step(src.connected, SOUTH)
			src.connected.layer = OBJ_LAYER
			src.connected.light.enable()
			var/turf/T = get_step(src, SOUTH)
			if (T.contents.Find(src.connected))
				src.connected.connected = src
				src.update()
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.connected.loc)
			else
				src.connected.set_loc(src)
				src.connected.light.disable()
		src.add_fingerprint(user)
		update()

	attackby(P as obj, mob/user as mob)
		if (istype(P, /obj/item/pen))
			var/t = input(user, "What would you like the label to be?", src.name, null) as null|text
			if (!t)
				return
			if (user.equipped() != P)
				return
			if ((!in_range(src, usr) > 1 && src.loc != user))
				return
			t = copytext(adminscrub(t),1,128)
			if (t)
				src.name = "Tanning Bed- '[t]'"
			else
				src.name = "Tanning Bed"
		src.add_fingerprint(user)
		return

	relaymove(mob/user as mob)
		if (user.stat || locked)
			return
		if (!connected)
			src.connected = new /obj/c_tray/tanning(src.loc)
		else
			src.connected.set_loc(src.loc)
		step(src.connected, SOUTH)
		src.connected.layer = OBJ_LAYER
		var/turf/T = get_step(src, SOUTH)
		if (T.contents.Find(src.connected))
			src.connected.connected = src
			for(var/atom/movable/A as mob|obj in src)
				A.set_loc(src.connected.loc)
		else
			src.connected.set_loc(src)
			src.connected.light.disable()
		src.update()
		return

	cremate(mob/user as mob)
		if (!src || !istype(src))
			return
		if (src.cremating)
			return //don't let you cremate something twice or w/e
		if (!src.contents || !src.contents.len)
			src.visible_message("<span class='alert'>You hear the lights turn on for a second, then turn off.</span>")
			return

		src.visible_message("<span class='alert'>You hear a faint buzz as \the [src] activates.</span>")
		playsound(src.loc, "sound/machines/shieldup.ogg", 30, 1)
		src.cremating = 1
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
				src.cremating = 0
				src.locked = 0
				playsound(src.loc, "sound/machines/ding.ogg", 50, 1)
		return

/obj/c_tray/tanning
	name = "tanning bed"
	desc = "The perfect place to lay down after a long day indoors."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "tantray_empty"
	connected = null
	var/obj/item/light/tube/tanningtube = null
	var/image/trayoverlay

	proc/generate_overlay_icon(var/tubecolor)
		if (!trayoverlay)
			src.trayoverlay = image('icons/obj/stationobjs.dmi', "tantray_overlay")
		src.overlays = null
		if (tanningtube)
			src.trayoverlay.color = tubecolor
			src.overlays += trayoverlay

	proc/send_new_tancolor(var/tubecolor)
		if (src.connected && istype (src.connected, /obj/crematorium/tanning))
			var/obj/crematorium/tanning/tanningbed = src.connected
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
		if (istype(P, /obj/item/light/tube) && !src.contents.len)
			var/obj/item/light/tube/G = P
			boutput(usr, "<span class='notice'>You put \the [G.name] into \the [src.name].</span>")
			user.drop_item()
			G.set_loc(src)
			src.tanningtube = G
			var/tanningtubecolor = rgb(tanningtube.color_r * 255, tanningtube.color_b * 255, tanningtube.color_g * 255)
			generate_overlay_icon(tanningtubecolor)
			send_new_tancolor(tanningtubecolor)
			if (src.light)
				light.set_color(tanningtube.color_r, tanningtube.color_g, tanningtube.color_b)
				light.set_brightness(0.5)

		if (ispryingtool(P) && src.contents.len) //pry out the tube with a crowbar
			boutput(usr, "<span class='notice'>You pry out \the [src.tanningtube.name] from \the [src.name].</span>")
			src.tanningtube.set_loc(src.loc)
			src.tanningtube = null
			generate_overlay_icon() //nulling overlay
			if (src.light)
				light.set_color(0, 0, 0)
				light.set_brightness(0)


/* -------------------- Computer -------------------- */

/obj/machinery/computer/tanning
	name = "Tanning Computer"
	desc = "Used to control a tanning bed."
	icon = 'icons/obj/stationobjs.dmi'
	mats = 20
	var/id = 2
	icon_state = "tanconsole"
	var/state_str = ""
	var/obj/crematorium/tanning/linked = null //The linked tanning bed


	New()
		..()
		get_link()

	disposing()
		src.linked?.linked = null
		src.linked = null
		. = ..()

	proc/get_link()
		for(var/obj/crematorium/tanning/C in by_type[/obj/crematorium])
			if(C.z == src.z && C.id == src.id && C != src)
				linked = C
				C.linked = src
				break

	proc/find_tray_tube()
		if (linked.connected && istype(linked.connected, /obj/c_tray/tanning))
			var/obj/c_tray/tanning/tray = linked.connected
			if (tray.tanningtube)
				return 1

	proc/get_state_string()
		if(linked == null) get_link()
		if(linked == null) return "ERROR: No tanning beds found."

		if(find_tray_tube() != 1) return "No light tube found in the tanning tray."
		if(linked.cremating) return "Tanning in progress. Please wait."
		if(linked.cremating == 0) return "Tanning bed idle."

		return "Unknown Error Encountered."

	attack_hand(var/mob/user as mob, params)
		if (..(user))
			return

		state_str = src.get_state_string()

		var/dat = ""
		dat += "<b>Tanning Bed Status:</b><BR>"
		dat += "[state_str]<BR>"
		dat += "Set Time: [linked.settime]<BR>"
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
			if (linked && !linked.cremating && find_tray_tube() == 1)
				playsound(src.loc, "sound/machines/bweep.ogg", 20, 1)
				linked.cremate()
				logTheThing("station", usr, null, "activated the tanning bed at [usr.loc.loc] ([showCoords(usr.x, usr.y, usr.z)])")

		else if (href_list["timer"])
			sleep (100)
			if (linked && !linked.cremating && find_tray_tube() == 1)
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
