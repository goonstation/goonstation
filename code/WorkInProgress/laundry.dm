#define PRE 0
#define WASH "w"
#define DRY "d"
#define POST 1

/obj/submachine/laundry_machine
	name = "laundry machine"
	desc = "A combined washer/dryer unit used for cleaning clothes."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "laundry"
	anchored = 1
	density = 1
	deconstruct_flags = DECON_WELDER | DECON_WRENCH
	var/on = 0
	var/open = 0
	var/cycle = PRE
	var/cycle_time = 10
	var/cycle_current = 0
	var/image/image_door = null
	var/image/image_light = null
	//var/image/image_panel = null
	var/load_max = 12
	var/HTML = null

/obj/submachine/laundry_machine/New()
	..()
	src.update_icon()

/obj/submachine/laundry_machine/proc/update_icon()
	ENSURE_IMAGE(src.image_door, src.icon, "laundry[src.open]")
	src.UpdateOverlays(src.image_door, "door")

	if (src.contents.len)
		if (src.cycle == PRE)
			src.icon_state = "laundry-p"
			src.UpdateOverlays(null, "light")
		else if (src.cycle == POST)
			src.icon_state = "laundry-d0"
			src.UpdateOverlays(null, "light")
		else
			src.icon_state = "laundry-[src.cycle][src.on]"
			if (src.on)
				ENSURE_IMAGE(src.image_light, src.icon, "laundry-[src.cycle]light")
				src.UpdateOverlays(src.image_light, "light")
			else
				src.UpdateOverlays(null, "light")
	else
		src.icon_state = "laundry"
		src.UpdateOverlays(null, "light")

/obj/submachine/laundry_machine/proc/process()
	if (!src.contents.len || !src.on) // somehow there's nothing in the machine or it's turned off somehow, whoops!
		processing_items.Remove(src)
		src.visible_message("[src] lets out a grumpy buzz!")
		playsound(get_turf(src), "sound/machines/buzz-two.ogg", 50, 1)
		src.on = 0
		src.update_icon()
		src.generate_html()
		return

	if (src.cycle_current >= src.cycle_time) // cycle done!
		if (src.cycle == WASH) // we have to dry things now!
			for (var/obj/item/I in src.contents)
				if (istype(I, /obj/item/clothing))
					var/obj/item/clothing/C = I
					C.stains = list("damp")
					C.UpdateName()
				I.clean_forensic()
			src.cycle = DRY
			src.cycle_current = 0
			src.visible_message("[src] lets out a beep and hums as it switches to its drying cycle.")
			playsound(get_turf(src), "sound/machines/chime.ogg", 30, 1)
			playsound(get_turf(src), "sound/machines/engine_highpower.ogg", 30, 1)
			src.update_icon()
			src.generate_html()
		else // drying is done!
			processing_items.Remove(src)
			for (var/obj/item/clothing/C in src.contents)
				C.stains = null
				C.UpdateName()
			src.cycle = POST
			src.cycle_current = 0
			src.visible_message("[src] lets out a happy beep!")
			playsound(get_turf(src), "sound/machines/ding.ogg", 50, 1)
			src.update_icon()
			src.generate_html()
	else
		src.cycle_current++
		if (src.cycle == PRE) // just started up!
			src.cycle = WASH
			src.visible_message("[src] clicks locked and sloshes a bit as it starts its washing cycle.")
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			playsound(get_turf(src), "sound/impact_sounds/Liquid_Slosh_2.ogg", 100, 1)
			src.update_icon()
			src.generate_html()

		else if (src.cycle == WASH && prob(40)) // play a washery sound
			playsound(get_turf(src), "sound/impact_sounds/Liquid_Slosh_2.ogg", 100, 1)
			src.shake()
		else if (src.cycle == DRY && prob(20)) // play a dryery sound
			playsound(get_turf(src), "sound/machines/engine_highpower.ogg", 30, 1)
			src.shake()

/obj/submachine/laundry_machine/proc/shake(var/amt = 5)
	set waitfor = 0
	var/orig_x = src.pixel_x
	var/orig_y = src.pixel_y
	for (amt, amt>0, amt--)
		src.pixel_x = rand(-2,2)
		src.pixel_y = rand(-2,2)
		sleep(0.1 SECONDS)
	src.pixel_x = orig_x
	src.pixel_y = orig_y
	return 1

/obj/submachine/laundry_machine/attackby(obj/item/W, mob/user)
	if (istype(W))
		if (!src.open)
			src.visible_message("[user] tries to put [W] into [src], but [src]'s door is closed, so [he_or_she(user)] just smooshes [W] against the door.[prob(40) ? " What a doofus!" : null]")
			return
		else if (!istype(W, /obj/item/clothing) && W.w_class > W_CLASS_HUGE)
			src.visible_message("[user] tries [his_or_her(user)] best to put [W] into [src], but [W] is too big to fit!")
			return
		else if (src.contents.len >= src.load_max)
			src.visible_message("[user] tries [his_or_her(user)] best to put [W] into [src], but [src] is too full!")
			return
		else if (W.cant_drop || W.cant_self_remove)
			src.visible_message("[user] tries [his_or_her(user)] best to put [W] into [src], but [W] is stuck to [him_or_her(user)]!")
			return
		else
			user.u_equip(W)
			W.set_loc(src)
			src.visible_message("[user] puts [W] into [src].")
			src.update_icon()
			return
	else
		return ..()

/obj/submachine/laundry_machine/attack_hand(mob/user)
	if (!user || user.restrained() || user.lying || user.stat)
		return
	src.show_window(user)

/obj/submachine/laundry_machine/proc/generate_html()
	src.HTML = "<center><big><b>WashMan 550</b></big></center><hr><br>"
	if (src.on && src.cycle != POST)
		src.HTML += "<b>STATUS: [src.cycle == DRY ? "Drying" : "Washing"]</b><br>Please wait, machine is currently running."
		return
	else
		if (src.cycle == POST)
			src.HTML += "<b>STATUS: Cycle Complete</b><br>"
		else
			src.HTML += "<b>STATUS: Idle</b><br>"
		src.HTML += "CYCLE: <a href='byond://?src=\ref[src];cycle=1'>[src.on ? "Stop" : "Start"]</a><br>"
		src.HTML += "DOOR: <a href='byond://?src=\ref[src];door=1'>[src.open ? "Close" : "Open"]</a><br>"

/obj/submachine/laundry_machine/proc/show_window(mob/user)
	if (!user)
		return
	if (!src.HTML)
		src.generate_html()
	user.Browse(src.HTML, "window=laundry_machine;size=300x200;title=[capitalize(src.name)]")

/obj/submachine/laundry_machine/MouseDrop(over_object,src_location,over_location)
	var/mob/user = usr
	if (!user || !over_object || get_dist(user, src) > 1 || get_dist(user, over_object) > 1 || is_incapacitated(user) || (issilicon(user) && get_dist(src,user) > 1))
		return
	if (src.on)
		src.visible_message("[user] tries to open [src]'s door, but [src] is running and the door is locked!")
		return
	var/turf/T = get_turf(over_object)
	if (!T)
		return
	src.visible_message("[user] unloads [src] onto [T].")
	src.unload(T)

/obj/submachine/laundry_machine/proc/unload(var/turf/T)
	if (src.contents.len)
		T = istype(T) ?  T : get_turf(src)
		for (var/atom/movable/AM in src)
			AM.set_loc(T)
		src.update_icon()

/obj/submachine/laundry_machine/Topic(href, href_list)
	..()
	DEBUG_MESSAGE(json_encode(href_list))
	if (!usr || usr.restrained() || usr.lying || usr.stat || (!issilicon(usr) && get_dist(src,usr) > 1))
		return 1
	src.add_fingerprint(usr)
	if (href_list["cycle"])
		src.on = !src.on
		src.visible_message("[usr] switches [src] [src.on ? "on" : "off"].")
		if (src.on)
			src.open = 0
			if (!processing_items.Find(src))
				processing_items.Add(src)

	else if (href_list["door"])
		if (src.on)
			src.visible_message("[usr] tries to open [src]'s door, but [src] is running and the door is locked!")
			return
		else
			src.open = !src.open
			src.visible_message("[usr] [src.open ? "opens" : "closes"] [src]'s door.")
			if (src.open)
				src.unload()
				src.cycle = PRE

	src.update_icon()
	src.generate_html()
	src.show_window(usr)
	return

#undef PRE
#undef WASH
#undef DRY
#undef POST
