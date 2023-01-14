/datum/action/bar/skateboard //Only visible to rider of skateboard
	var/sCurr = 0
	var/sMax = 100
	interrupt_flags = 0

	onStart()
		. = ..()
		state = ACTIONSTATE_INFINITE
		bar.icon = null
		border.icon = null
		bar.pixel_y = 7
		border.pixel_y = 7
		if(istype(owner, /obj/vehicle/skateboard))
			var/obj/vehicle/skateboard/sb = owner
			if(sb.rider)
				sb.rider << bar.img
				sb.rider << border.img

	onDelete()
		bar.icon = 'icons/ui/actions.dmi'
		border.icon = 'icons/ui/actions.dmi'
		qdel(bar.img)
		qdel(border.img)
		..()

	onUpdate()
		if (bar)
			var/complete = clamp((sCurr / sMax), 0, 1)
			var/matrix/newMtx = matrix(complete, 1, MATRIX_SCALE)
			animate( bar, transform = newMtx, pixel_x = -nround( ((30 - (30 * complete)) / 2) ), time = 3 )
		//..()

/obj/decal/skateboardpopup
	name = ""
	desc = ""
	anchored = 1
	mouse_opacity = 0
	layer = MOB_LAYER + 2
	icon = 'icons/effects/96x32.dmi'
	icon_state = "1"
	alpha = 0
	pixel_x = -32

	New(var/location = null, var/state = null)
		..()
		if(location)
			src.set_loc(location)
		else
			src.set_loc(usr.loc)

		if(state)
			icon_state = "[state]"

		var/matrix/original = matrix()
		original.Scale(0.1)
		src.transform = original
		animate(src, transform = matrix(), alpha = 255, time = 5)
		animate(time = 5, alpha = 253)
		animate(pixel_y = 64, alpha = 0, time = 5)
		SPAWN(2 SECONDS)
			qdel(src)


/obj/vehicle/skateboard
	name = "Skateboard"
	desc = "Sick ... ollie ... bro...llie"
	icon_state = "skateboard0"
	layer = MOB_LAYER + 1
	soundproofing = 0
	can_eject_items = TRUE
	var/sickness = 0
	var/speed_delay = 5
	var/datum/action/bar/skateboard/runningAction = null
	var/input_lockout = 0
	var/atom/last_bumped_atom = null
	var/list/bumped_queue = list()
	density = 0
	mob_flip_inside(var/mob/user)
		animate_spin(src, prob(50) ? "L" : "R", 1, 0)

/obj/vehicle/skateboard/New()
	..()

/obj/vehicle/skateboard/proc/adjustSickness(var/mod)
	var/oldSick = sickness
	sickness = clamp(sickness + mod, 0, 100)
	var/howSick = round(sickness / 5)
	if(howSick > round(oldSick / 5))
		trickPopup(howSick)
	update()
	return

/obj/vehicle/skateboard/proc/update()
	if(rider)
		icon_state = "skateboard"
	else
		icon_state = "skateboard0"

	switch(sickness)
		if(0 to 20)
			speed_delay = 4
		if(21 to 40)
			speed_delay = 3
		if(41 to 60)
			speed_delay = 2
		if(61 to 80)
			speed_delay = 1
		if(81 to 100)
			speed_delay = 0

	if(runningAction?.bar)
		if(sickness >= 60)
			runningAction.bar.color = "#00DD00"
		else
			runningAction.bar.color = "#0000FF"

/obj/vehicle/skateboard/proc/trickName()
	var/list/adjectives = list("sicknasty", "sick", "sweet", "ballin'", "darkside", "goofy", "aggro", "gnarly", "mondo", "backside", "blindside", "bomb", "frontside", "juicy", "180", "360", "720", "totally sweet", "totally sick", "tubular")
	var/list/nouns = list("grind", "aerial", "cabbalerial", "eggplant", "rollo", "flip", "heel flip", "kick flip", "nollie kick flip", "aerial", "lipslide", "mctwist", "tailslide", "finger flip", "butter flip", "calf wrap", "g-turn", "coco-slide", "handstand", "heli-pop", "gazelle", "m80", "kickback", "jaywalk", "pogo", "pressure flip", "streetplant", "shove-it", "railslide")
	return pick(adjectives) + " " + pick(nouns)

/obj/vehicle/skateboard/proc/trickAnimate()
	var/matrix/X = matrix()
	animate(src, transform = X.Turn(rand(-180, 180)), easing = pick(LINEAR_EASING, SINE_EASING, CIRCULAR_EASING, QUAD_EASING, CUBIC_EASING, BOUNCE_EASING, ELASTIC_EASING, BACK_EASING), pixel_x = rand(-15,15), pixel_y = rand(-15,15), time = rand(1, 5))
	animate(transform = matrix(), easing = pick(LINEAR_EASING, SINE_EASING, CIRCULAR_EASING, QUAD_EASING, CUBIC_EASING, BOUNCE_EASING, ELASTIC_EASING, BACK_EASING), pixel_x = 0, pixel_y = 0, time = rand(1, 5))
	return

/obj/vehicle/skateboard/proc/trickPopup(var/val)
	new/obj/decal/skateboardpopup(src.loc, val)
	return

/obj/vehicle/skateboard/proc/messageNearby(var/textself, var/textother)
	boutput(rider, textself, group = "[src]_Skateboard")
	for (var/mob/C in AIviewers(src))
		if(C == rider)
			continue
		C.show_message(textother, 1, group = "[src]_Skateboard")

/obj/vehicle/skateboard/bump(atom/AM as mob|obj|turf)
	if(in_bump)
		return

	if(AM == last_bumped_atom)
		walk(src, turn(dir, pick(180, 90, -90)), speed_delay)
		return

	if(AM == rider || !rider)
		return

	var/turf/T = get_turf(src)
	if(isrestrictedz(T.z))
		sickness = 0

	..()
	src.stop()
	in_bump = 1

	var/give_points = 1
	if(AM in bumped_queue)
		give_points = 0
	if(last_bumped_atom)
		if(GET_DIST(last_bumped_atom, AM) <= 3)
			give_points = 0

	last_bumped_atom = AM
	bumped_queue.Add(AM)
	if(bumped_queue.len >= 9)
		bumped_queue.Cut(1,2)

	if(isturf(AM) || istype(AM, /obj/window) || istype(AM, /obj/grille))
		if(sickness < 100 || z == 2 || z == 4)
			src.messageNearby("<span class='alert'><B>You crash into the [AM]!</B></span>", "<span class='alert'><B>[rider] crashes into the [AM] with the [src]!</B></span>")
			playsound(src, pick(sb_fails), 55, 1)
			adjustSickness(-sickness)
			eject_rider(2)
		else
			src.set_loc(AM)
			walk(src, dir, speed_delay)

	else if(ismob(AM))
		if(sickness < 60)
			src.messageNearby("<span class='alert'><B>You crash into [AM]!</B></span>", "<span class='alert'><B>[rider] crashes into [AM] with the [src]!</B></span>")
			playsound(src, pick(sb_fails), 55, 1)
			adjustSickness(-sickness)
			eject_rider(2)
		else
			var/trick = trickName()
			src.messageNearby("<span class='alert'><B>You do a [trick] over [AM]!</B></span>", "<span class='alert'><B>[rider] does a [trick] over [AM]!</B></span>")
			if(give_points)
				adjustSickness(6)
			trickAnimate()
			src.set_loc(AM.loc)
			walk(src, turn(dir, pick(180, 90, -90)), speed_delay)
			playsound(src, pick(sb_tricks), 65, 1)

			input_lockout += 1
			SPAWN(0.4 SECONDS)
				input_lockout -= 1

	else if(isobj(AM))
		var/trick = trickName()
		src.messageNearby("<span class='alert'><B>You do a [trick] on the [AM]!</B></span>", "<span class='alert'><B>[rider] does a [trick] on the [AM]!</B></span>")
		if(give_points)
			adjustSickness(4)
		trickAnimate()
		var/newdir = turn(dir, pick(180, 90, -90))

		if(istype(AM, /obj/machinery/door))
			newdir = turn(dir, 180)

		walk(src, newdir, speed_delay)
		playsound(src, pick(sb_tricks), 65, 1)
		input_lockout += 1
		SPAWN(0.4 SECONDS)
			input_lockout -= 1

	if(runningAction)
		runningAction.sCurr = sickness

	update()
	in_bump = 0
	return

/obj/vehicle/skateboard/eject_rider(var/crashed, var/selfdismount)
	if (!src.rider)
		return

	density = 0

	var/mob/living/rider = src.rider
	..()
	rider.pixel_y = 0

	src.stop()

	if(crashed)
		if(crashed > 30)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 70, 1)

		src.messageNearby("<span class='alert'><B>You are flung off the [src]!</B></span>", "<span class='alert'><B>[rider] is flung off the [src]!</B></span>")

		rider.changeStatus("stunned", 2 SECONDS)
		rider.changeStatus("weakened", 2 SECONDS)
		var/turf/target = get_edge_target_turf(src, src.dir)
		rider.throw_at(target, 5, 1)
		rider.TakeDamageAccountArmor("All", round(sickness / 4), round(sickness / 4), 0, DAMAGE_BLUNT)
	else
		if(selfdismount)
			src.messageNearby("<span class='notice'>You dismount from the [src].</span>", "<B>[rider]</B> dismounts from the [src].")

	actions.stop(runningAction, src)
	runningAction = null

	rider = null
	overlays = null

	adjustSickness(-sickness)
	update()
	return

/obj/vehicle/skateboard/relaymove(mob/user as mob, dir)
	if(input_lockout) return

	if(rider)
		if(istype(src.loc, /turf/space))
			return
		walk(src, dir, speed_delay)
	else
		for(var/mob/M in src.contents)
			M.set_loc(src.loc)

/obj/vehicle/skateboard/MouseDrop_T(mob/living/target, mob/user)
	if (rider || !istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, target) > 0 || is_incapacitated(user) || isAI(user))
		return

	if(target == user && !user.stat)
		src.messageNearby("<span class='notice'>You climb onto the [src].</span>", "[user.name] climbs onto the [src].")
	else
		return

	density = 1

	target.set_loc(src)
	rider = target
	rider.pixel_x = 0
	rider.pixel_y = 4

	overlays += rider

	adjustSickness(-sickness)
	update()

	runningAction = new/datum/action/bar/skateboard()
	actions.start(runningAction, src)

	return

/obj/vehicle/skateboard/Click()
	if(usr != rider)
		..()
		return
	if(!(usr.getStatusDuration("paralysis") || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat))
		eject_rider(0, 1)
	return

/obj/vehicle/skateboard/attack_hand(mob/living/carbon/human/M)
	if(!M || !rider)
		..()
		return
	/*
	switch(M.a_intent)
		if("harm", "disarm")
			if(prob(60))
				playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
				src.visible_message("<span class='alert'><B>[M] has shoved [rider] off of the [src]!</B></span>")
				src.log_me(src.rider, M, "shoved_off")
				rider.weakened = 2
				eject_rider()
			else
				playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 25, 1, -1)
				src.visible_message("<span class='alert'><B>[M] has attempted to shove [rider] off of the [src]!</B></span>")
	*/
	return



/obj/vehicle/skateboard/disposing()
	if(rider)
		boutput(rider, "<span class='alert'><B>Your skateboard is somehow destroyed!</B></span>")
		eject_rider()
	..()
	return
