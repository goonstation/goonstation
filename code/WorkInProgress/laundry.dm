#define PRE 0
#define WASH "w"
#define DRY "d"
#define POST 1
#define CYCLE_TIME_MOB_INSIDE 5
#define CYCLE_TIME 10

TYPEINFO(/obj/submachine/laundry_machine)
	mats = 20

/obj/submachine/laundry_machine
	name = "laundry machine"
	desc = "A combined washer/dryer unit used for cleaning clothes."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "laundry"
	anchored = ANCHORED
	density = 1
	deconstruct_flags = DECON_WELDER | DECON_WRENCH
	var/on = 0
	var/open = 0
	var/cycle = PRE
	var/cycle_current = 0
	var/cycle_max = CYCLE_TIME
	var/mob/occupant = null
	var/mob/activator = null
	var/image/image_door = null
	var/image/image_light = null
	//var/image/image_panel = null
	var/load_max = 12
	var/HTML = null
	///oh no
	var/has_brick = FALSE

/obj/submachine/laundry_machine/New()
	..()
	src.UpdateIcon()

/obj/submachine/laundry_machine/disposing()
	src.unload()
	src.activator = null
	src.occupant = null
	..()

/obj/submachine/laundry_machine/update_icon()
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
		playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
		src.on = 0
		src.UpdateIcon()
		return

	var/mob/living/carbon/human/H = src.occupant
	if (src.cycle_current >= src.cycle_max) // cycle done! The cycle is faster if a human is inside
		if (src.cycle == WASH) // we have to dry things now!
			for (var/obj/item/I in src.contents)
				if (istype(I, /obj/item/clothing))
					var/obj/item/clothing/C = I
					C.clean_stains()
					C.add_stain(/datum/stain/damp)
				I.clean_forensic()
			if (src.occupant && ishuman(src.occupant))
				H.sims?.affectMotive("Hygiene", 100)
			src.cycle = DRY
			src.cycle_current = 0
			src.visible_message("[src] lets out a beep and hums as it switches to its drying cycle.")
			playsound(src, 'sound/machines/chime.ogg', 30, TRUE)
			playsound(src, 'sound/machines/engine_highpower.ogg', 20, TRUE)
			src.UpdateIcon()
		else // drying is done!
			processing_items.Remove(src)
			for (var/obj/item/item in src.contents)
				if (istype(item, /obj/item/clothing))
					var/obj/item/clothing/clothing = item
					clothing.clean_stains()
					clothing.delStatus("freshly_laundered") // ...and this is the price we pay for being cheeky
					clothing.changeStatus("freshly_laundered", rand(2,4) MINUTES)
					clothing.UpdateName()
				else if (istype(item, /obj/item/currency/spacecash))
					var/obj/item/currency/spacecash/cash = item
					cash.changeStatus("freshly_laundered", INFINITE_STATUS)
					var/list/amounts = random_split(cash.amount, min(rand(3,6), cash.amount - 1))
					for (var/amount in amounts)
						if (amount >= cash.amount)
							break
						var/obj/item/currency/spacecash/newcash = cash.split_stack(amount)
						newcash.changeStatus("freshly_laundered", INFINITE_STATUS)
						newcash.set_loc(src)
					//Money laundering is a crime!
					var/mob/living/carbon/human/criminal = src.activator
					if (ishuman(criminal) && seen_by_camera(criminal))
						var/perpname = criminal.name
						var/datum/db_record/sec_record = data_core.security.find_record("name", perpname)
						if(sec_record  && sec_record["criminal"] != ARREST_STATE_ARREST)
							sec_record["criminal"] = ARREST_STATE_ARREST
							sec_record["mi_crim"] = "Money laundering."
							criminal.update_arrest_icon()
			src.activator = null
			src.cycle = POST
			src.cycle_current = 0
			src.visible_message("[src] lets out a happy beep!")
			playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
			if(src.occupant) // If someone is inside we eject immediatly so as to not keep people hostage
				if (ishuman(src.occupant))
					H.w_uniform?.changeStatus("freshly_laundered", rand(2,4) MINUTES)
					H.wear_suit?.changeStatus("freshly_laundered", rand(2,4) MINUTES)
					H.shoes?.changeStatus("freshly_laundered", rand(2,4) MINUTES)
					H.gloves?.changeStatus("freshly_laundered", rand(2,4) MINUTES)
					H.glasses?.changeStatus("freshly_laundered", rand(2,4) MINUTES)
					H.head?.changeStatus("freshly_laundered", rand(2,4) MINUTES)
				H.changeStatus("knockdown", 1 SECONDS)
				H.make_dizzy(15) //Makes you dizzy for fifteen seconds due to the spinning
				H.change_misstep_chance(65)
				src.open = 1
				src.unload()
				src.cycle = PRE
				src.visible_message("[src]'s door flings open and [H] flops on the ground, squeaky clean.")
			src.occupant = null
			src.cycle_max = CYCLE_TIME
			src.on = 0
			src.UpdateIcon()
	else
		src.cycle_current++
		if (src.occupant)
			H.TakeDamage("All", 2, 0, 0, DAMAGE_BLUNT) //Getting washed like that has gotta hurt
			if (src.has_brick && prob(80))
				boutput(H, SPAN_ALERT("The brick flies around and hits you in the head, <b>OWW!</b>"))
				H.TakeDamage("Head", /obj/item/brick::force, 0, 0, DAMAGE_BLUNT)
			H.take_oxygen_deprivation(rand(0,3)) //Hard to keep breathing while in the machine
			src.shake()
			playsound(src, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, TRUE)
			if (src.cycle_current == 2 && src.cycle == WASH)
				src.visible_message("[src] groans horribly, some water drips out!")
				playsound(src, 'sound/impact_sounds/Metal_Clang_3.ogg', 80, TRUE)
			else if (src.cycle_current == 4 && src.cycle == WASH)
				src.visible_message("[src] is making a horrible ratchet! [H]'s face can be seen pressed against the glass.")
				if(isliving(H))
					H.emote("scream")
			else if (src.cycle_current == 2 && src.cycle == DRY)
				src.visible_message("[src] is shaking around threateningly!")
				if(isliving(H))
					H.emote("scream")
			else if (src.cycle_current == 4 && src.cycle == DRY)
				src.visible_message("[src] is quaking like a jackhammer!")

		if (src.cycle == PRE) // just started up!
			src.cycle = WASH
			if (src.occupant)
				src.visible_message("[src] clicks locked, grumps a bit and starts its washing cycle.")
				H.clean_forensic()
				H.delStatus("marker_painted")
			else
				src.visible_message("[src] clicks locked and sloshes a bit as it starts its washing cycle.")
			if (locate(/obj/item/brick) in src.contents)
				src.start_brick_grump()
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			playsound(src, 'sound/machines/washing_start.ogg', 80, TRUE)
			src.UpdateIcon()

		else if (src.cycle == WASH && prob(40)) // play a washery sound
			H?.delStatus("burning")
			playsound(src, 'sound/impact_sounds/Liquid_Slosh_2.ogg', 80, TRUE)
			src.shake()
		else if (src.cycle == DRY && prob(20)) // play a dryery sound
			playsound(src, 'sound/machines/engine_highpower.ogg', 20, TRUE)
			src.shake()

/obj/submachine/laundry_machine/proc/start_brick_grump()
	set waitfor = FALSE
	src.has_brick = TRUE
	while (src.cycle == WASH || src.cycle == DRY)
		animate_storage_thump(src, 11)
		if (prob(50))
			var/dir = pick(cardinal)
			for (var/mob/living/M in get_step(src, dir))
				if (!isintangible(M))
					random_brute_damage(M, 5)
					M.setStatus("knockdown", 2 SECONDS)
					M.force_laydown_standup()
					M.throw_at(get_steps(src, dir, 5), 5, 1, null, get_turf(src))
			step(src, dir)
			src.visible_message(SPAN_ALERT("[src] [pick("rattles", "shudders", "judders", "complains", "grumps")]"), group = "angry_laundry")
		if (prob(1))
			if (prob(20))
				src.unload(get_turf(src))
				src.blowthefuckup()
			else
				src.visible_message(SPAN_ALERT("Everything flies out of [src]!"))
				src.unload(get_step(src, src.dir), fling = TRUE)
				src.on = FALSE
				src.open = TRUE
				src.process()
			src.has_brick = FALSE
			break
		sleep(0.5 SECOND)

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
		else if ((!istype(W, /obj/item/clothing) || !istype(W, /obj/item/grab)) && W.w_class > W_CLASS_HUGE)
			src.visible_message("[user] tries [his_or_her(user)] best to put [W] into [src], but [W] is too big to fit!")
			return
		else if (length(src.contents) >= src.load_max)
			src.visible_message("[user] tries [his_or_her(user)] best to put [W] into [src], but [src] is too full!")
			return
		else if (W.cant_drop || W.cant_self_remove)
			src.visible_message("[user] tries [his_or_her(user)] best to put [W] into [src], but [W] is stuck to [him_or_her(user)]!")
			return
		else
			if (istype(W, /obj/item/clothing) || istype(W, /obj/item/currency/spacecash) || istype(W, /obj/item/brick))
				user.u_equip(W)
				W.set_loc(src)
				src.visible_message("[user] puts [W] into [src].")
				src.UpdateIcon()
				return
			else if (istype(W, /obj/item/grab)) //If its a person, we're trying to stuff them into the washing machine
				var/obj/item/grab/G = W
				user.visible_message(SPAN_ALERT("[user] starts to put [G.affecting] into the washing machine!"))
				SETUP_GENERIC_ACTIONBAR(user, src, 4 SECONDS, /obj/submachine/laundry_machine/proc/force_into_machine, list(G, user), 'icons/mob/screen1.dmi', "grabbed", null, null) //Sounds about right since it's a lengthy stun afterwards
	else
		return ..()

/obj/submachine/laundry_machine/hitby(atom/movable/MO, datum/thrown_thing/thr)
	if (istype(MO, /mob/living))
		if (src.on == 0)
			var/mob/living/H = MO
			H.visible_message(SPAN_ALERT("<B>[H] gets tossed into the washing machine!</B>"))
			logTheThing(LOG_COMBAT, H, "is thrown into a [src.name] at [log_loc(src)].")
			H.set_loc(src)
			src.open = 0
			UpdateIcon()
	else
		return ..()


/obj/submachine/laundry_machine/attack_hand(mob/user)
	if (!can_act(user))
		return
	src.add_fingerprint(user)
	ui_interact(user)

/obj/submachine/laundry_machine/proc/force_into_machine(obj/item/grab/W as obj, mob/user as mob)
	if (src.on == 0)
		if(W?.affecting && (BOUNDS_DIST(user, src) == 0))
			user.visible_message(SPAN_ALERT("[user] shoves [W.affecting] into the laundry machine and turns it on!"))
			src.add_fingerprint(user)
			logTheThing(LOG_COMBAT, user, "forced [constructTarget(W.affecting,"combat")] into a laundry machine at [log_loc(src)].")
			W.affecting.set_loc(src)
			src.open = 0
			src.on = 1
			src.cycle = PRE
			var/mob/M = W.affecting
			src.occupant = M
			UpdateIcon()
			cycle_max = CYCLE_TIME_MOB_INSIDE
			if (!processing_items.Find(src))
				processing_items.Add(src)
			var/mob/living/L = user

			if (L.pulling == W.affecting)
				L.remove_pulling()
			qdel(W)
	else //Prevents stuffing more than one person in at a time
		user.visible_message(SPAN_ALERT("[user] tries to shove [W.affecting] into the laundry machine but it was already running."))

/obj/submachine/laundry_machine/mouse_drop(over_object,src_location,over_location)
	var/mob/user = usr
	if (!user || !over_object || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, over_object) > 0 || is_incapacitated(user) || (issilicon(user) && BOUNDS_DIST(src, user) > 0))
		return
	if (src.on || !src.open)
		src.visible_message("[user] tries to unload items from [src], but the door is closed!")
		return
	var/turf/T = get_turf(over_object)
	if (!T)
		return
	src.visible_message("[user] unloads [src] onto [T].")
	src.unload(T)

/obj/submachine/laundry_machine/proc/unload(var/turf/T, fling = FALSE)
	if (src.contents.len)
		T = istype(T) ?  T : get_turf(src)
		for (var/atom/movable/AM in src)
			AM.set_loc(T)
			if (fling)
				AM.throw_at(get_steps(src, src.dir, 5), 5, 2)
		src.UpdateIcon()

/obj/submachine/laundry_machine/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Laundry")
		ui.open()

/obj/submachine/laundry_machine/ui_data(mob/user)
  . = list(
    "on" = on,
    "door" = open,
  )

/obj/submachine/laundry_machine/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if (.)
		return
	switch(action)
		if("door")
			if (src.on)
				src.visible_message("[usr] tries to open [src]'s door, but [src] is running and the door is locked!")
				return
			else
				src.open = !src.open
				. = TRUE
				src.visible_message("[usr] [src.open ? "opens" : "closes"] [src]'s door.")
				if (src.open)
					src.unload()
					src.cycle = PRE
		if("cycle")
			if (!occupant) //You cant turn it on or off if someone is inside to prevent people getting stuck inside
				src.on = !src.on
				. = TRUE
				src.visible_message("[usr] switches [src] [src.on ? "on" : "off"].")
				src.activator = usr
				if (src.on)
					src.cycle = PRE
					src.open = 0
					if (!(src in processing_items))
						processing_items.Add(src)
	src.UpdateIcon()

/obj/submachine/laundry_machine/Click(location, control, params)
	if(!src.ghost_observe_occupant(usr, src.occupant))
		. = ..()

#undef PRE
#undef WASH
#undef DRY
#undef POST
