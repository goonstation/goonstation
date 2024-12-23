#define UNWRENCHED 0
#define WRENCHED 1

ABSTRACT_TYPE(/obj/machinery/power/power_wheel)
TYPEINFO(/obj/machinery/power/power_wheel)
	mats = list("conductive" = 5,
				"metal" = 25,
				"insulated" = 3,
				"energy_high" = 10)
/obj/machinery/power/power_wheel
	name = "Kinetic Generator"
	desc = "A large wheel used to generate power."
	icon = 'icons/obj/power.dmi'
	icon_state = ""
	anchored = 0
	density = 1
	p_class = 3
	soundproofing = 0
	maptext_y = -32
	deconstruct_flags = DECON_MULTITOOL | DECON_WELDER | DECON_WRENCH | DECON_WIRECUTTERS
	var/mob_y_offset = 5
	var/mob/occupant
	var/movement_sound = 'sound/effects/spring.ogg'
	var/occupant_vis_flags
	var/watts_gen = 0
	var/lastgen = 0
	var/image/indicator
	var/image/indicator_light
	var/was_running
	var/state = UNWRENCHED
	var/debug = FALSE
	var/exits = SOUTH


	New()
		..()
		indicator = image('icons/obj/power.dmi', "power_indicator", layer=LIGHTING_LAYER_BASE-1)
		indicator_light = image('icons/obj/power.dmi', "power_indicator", layer=LIGHTING_LAYER_BASE)
		indicator_light.blend_mode = BLEND_ADD
		indicator_light.plane = PLANE_LIGHTING
		indicator_light.color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5)

	disposing()
		if(occupant)
			boutput(occupant, SPAN_ALERT("<B>Your [src] is destroyed!</B>"))
			eject_occupant()
		. = ..()

	attack_hand(mob/user)
		if(occupant && user != occupant)
			occupant.Attackhand(user)
			if(user.a_intent == INTENT_DISARM || user.a_intent == INTENT_GRAB)
				eject_occupant()
			user.lastattacked = src
		else
			. = ..()

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W))
			if(state == UNWRENCHED)
				state = WRENCHED
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				boutput(user, "You secure the external reinforcing bolts to the floor.")
				desc = "[initial(desc)]  It has been bolted to the floor."
				src.anchored = 1
				return

			else if(state == WRENCHED)
				state = UNWRENCHED
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				boutput(user, "You undo the external reinforcing bolts.")
				desc = initial(desc)
				src.anchored = 0
				return
		else if(src.occupant && W.force)
			W.attack(src.occupant, user)
			user.lastattacked = src
			if (occupant.hasStatus(list("knockdown", "unconscious", "stunned")))
				eject_occupant()
			W.visible_message(SPAN_ALERT("[user] swings at [src.occupant] with [W]!"))
		else if(!src.occupant && isgrab(W))
			var/obj/item/grab/G = W
			if (ismob(G.affecting))
				var/mob/new_occupant = G.affecting
				var/msg = "[user.name] pushes [new_occupant.name] onto \the [src]!"
				user.visible_message(msg, self_message=SPAN_NOTICE("You push [new_occupant.name] onto \the [src]!"))
				user.u_equip(G)
				qdel(G)
				insert_occupant(new_occupant)
		return

	bullet_act(flag, A as obj)
		if(occupant)
			occupant.bullet_act(flag, A)
			//do not eject!
		else
			..()

	meteorhit()
		if (ismob(src.occupant))
			src.occupant.meteorhit()
			src.eject_occupant()
		..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)

			if(2.0)
				if (prob(50))
					for(var/atom/movable/A as mob|obj in src)
						A.set_loc(src.loc)
						A.ex_act(severity)
					qdel(src)

			if(3.0)
				if (prob(25))
					for(var/atom/movable/A as mob|obj in src)
						A.set_loc(src.loc)
						A.ex_act(severity)
					qdel(src)

	Entered(atom/movable/AM, atom/OldLoc)
		. = ..()
		if(isitem(AM)) // prevent dropped items being lost forever
			AM.set_loc(src)

	Exited(atom/movable/thing, atom/newloc)
		. = ..()
		if(thing == src.occupant)
			src.eject_occupant()

	hitby(atom/movable/M, datum/thrown_thing/thr)
		if(src.occupant && prob(70))
			src.occupant.hitby(M, thr)
		else
			..()

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume, cannot_be_cooled = FALSE)
		..()
		// Simulate hotspot Crossed/Process so turfs engulfed in flames aren't simply ignored in vehicles
		if (isliving(src.occupant) && exposed_volume > (CELL_VOLUME * 0.5) && exposed_temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)
			var/mob/living/L = src.occupant
			L.update_burning(clamp(exposed_temperature / 60, 0, 20))

	MouseDrop_T(mob/living/target, mob/user)
		climb_into(target, user)

	proc/climb_into(mob/living/target, mob/user)
		if (occupant || !istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, target) > 0 || is_incapacitated(user) || isAI(user))
			return FALSE

		var/msg
		if(target == user && !user.stat)	// if drop self, then climbed in
			msg = "[user.name] climbs onto the [src]."
			user.visible_message(msg, self_message=SPAN_NOTICE("You climb onto \the [src]."))
		else if(target != user && !user.restrained())
			msg = "[user.name] helps [target.name] onto \the [src]!"
			user.visible_message(msg, self_message=SPAN_NOTICE("You help [target.name] onto \the [src]!"))
		else
			return FALSE

		insert_occupant(target)
		return TRUE

	proc/insert_occupant(mob/target)
		target.set_loc(src)
		occupant = target
		occupant.pixel_x = 0
		occupant.pixel_y = mob_y_offset
		occupant_vis_flags = occupant.vis_flags
		src.vis_contents |= occupant
		occupant.vis_flags |= VIS_INHERIT_ID
		return

	Click()
		if(usr != occupant)
			..()
			return
		if(can_act(usr))
			eject_occupant()

	Bumped(AM)
		if(isliving(AM) && get_dir(src, AM) == SOUTH)
			if(climb_into(AM, AM))
				return
		. = ..()

	proc/eject_occupant()
		if(src.occupant?.loc == src)
			src.occupant.set_loc(get_turf(src))

		for (var/atom/movable/AM in src.contents)
			AM.set_loc(get_turf(src))

		if(src.occupant)
			occupant.vis_flags = occupant_vis_flags
			src.vis_contents -= occupant
			src.occupant.pixel_y = 0
			src.occupant = null
		update()

	proc/update()
		if (!occupant)
			src.UpdateOverlays(null, "occupant")

		var/power_check = src.lastgen || src.watts_gen
		switch(power_check)
			if(0)
				src.dir = SOUTH
			if(1 to 200)
				indicator.color = "#522"
			if(200 to 800)
				indicator.color = "#f00"
			if(800 to 1500)
				indicator.color = "#ff0"
			if(1500 to INFINITY)
				indicator.color = "#0f0"

		if(src.watts_gen && src.powernet)
			indicator.alpha = 255
		else
			indicator.alpha = 50

		if(!src.lastgen || !src.watts_gen)
			was_running = 0 // clear running

		if(power_check)
			src.UpdateOverlays(indicator, "indicator")
			src.UpdateOverlays(indicator_light, "indicator_l")
		else
			src.UpdateOverlays(null, "indicator")
			src.UpdateOverlays(null, "indicator_l")


	process(mult)
		. = ..()

		add_avail(src.watts_gen WATTS)

		update()
		lastgen = watts_gen
		watts_gen = 0

	relaymove(mob/user, direction, delay, running)
		if(src.occupant != user)
			stack_trace("relaymove() called on [src] by '[user]' who is not the occupant '[occupant]'!")
			src.occupant = user
		var/spin_dir = direction & (EAST | WEST)
		if(spin_dir)
			if(was_running && (was_running != spin_dir) )
				if(tumble(user))
					return
			src.dir = spin_dir
		else if(direction & exits)
			eject_occupant()
			return
		else
			return delay

		generate_power(delay, running)

		animate_occupant(user, delay, running)

		if(!ON_COOLDOWN(src, "squeek", delay * 3))
			if(running)
				playsound(src, movement_sound, 20, TRUE, 0, 0.9)
			else
				playsound(src, movement_sound, 15, TRUE, -3, 1.0)

		was_running = spin_dir * running

		if(!ON_COOLDOWN(src, "starting", 2 SECONDS))
			update()

		return delay

	proc/tumble(mob/user)
		user.show_text(SPAN_ALERT("You weren't able to keep up with [src]!"))
		animate_spin(user, was_running == WEST ? "L" : "R", 1, 0)
		user.changeStatus("unconscious", 2 SECONDS)
		user.changeStatus("knockdown", 2 SECONDS)
		src.visible_message(SPAN_ALERT("<b>[user]</b> loses their footing and tumbles inside of [src]."))
		animate_storage_thump(src)
		return TRUE

	proc/animate_occupant(mob/user, delay, running)
		var/orig_y_ofst = user.pixel_y
		var/y_movement = 1 + (running * 2) + (1 * prob(10))
		var/x_movement = 3 + (1 * prob(20))
		if(user.dir == WEST)
			x_movement *= -1
		animate(user, time=delay/2, pixel_y=orig_y_ofst+y_movement, pixel_x=x_movement)
		animate(time=delay/2, pixel_y=orig_y_ofst, pixel_x=0)

	proc/generate_power(delay, running)
		var/move_gen = 50

		if( running )
			move_gen *= 1.1 // give benefit to sprinting on meth...
			occupant.remove_stamina((occupant.lying ? 3 : 1) * STAMINA_COST_SPRINT)

		watts_gen += move_gen

		if(debug && watts_gen)
			src.maptext = "<span class='pixel c ol'>[delay]  [lastgen]</span>"
		else
			src.maptext = ""

	was_deconstructed_to_frame(mob/user)
		src.eject_occupant()

/obj/machinery/power/power_wheel/hamster
	icon_state = "base"
	var/wheel_offset = 6
	var/wheel_top_offset = 22

	New()
		..()
		UpdateOverlays(image('icons/obj/power.dmi', src.loc, "wheel_b_1", pixel_y=wheel_offset), "wheel")
		UpdateOverlays(image('icons/obj/power.dmi', src.loc, "wheel_t_1", pixel_y=wheel_top_offset, layer=100), "wheel_top")

	update()
		..()
		var/speed = 1
		if((src.watts_gen > 100) || src.lastgen)
			speed++
		if((src.watts_gen > 1500) || (src.lastgen > 1500))
			speed++
		speed = clamp(speed, 1, 3)

		UpdateOverlays(image('icons/obj/power.dmi', src.loc, "wheel_b_[speed]", pixel_y=wheel_offset), "wheel")
		UpdateOverlays(image('icons/obj/power.dmi', src.loc, "wheel_t_[speed]", pixel_y=wheel_top_offset, layer=100), "wheel_top")

/obj/machinery/power/power_wheel/treadmill
	desc = "A large treadmill used to generate power."
	icon_state = ""
	mob_y_offset = 10
	exits = NORTH | SOUTH

	New()
		UpdateOverlays(image('icons/obj/power.dmi', "tread_1", layer=LIGHTING_LAYER_BASE-2), "wheel")
		..()

	update()
		..()
		var/speed = 1
		if((src.watts_gen > 100) || src.lastgen)
			speed++
		if((src.watts_gen > 1500) || (src.lastgen > 1500))
			speed++
		speed = clamp(speed, 1, 3)

		UpdateOverlays(image('icons/obj/power.dmi', "tread_[speed]", layer=LIGHTING_LAYER_BASE-2), "wheel")

	animate_occupant(mob/user, delay, running)
		var/orig_y_ofst = user.pixel_y
		var/y_movement = 1 + (running * 2) + (1 * prob(10))
		var/x_movement = 3 + (1 * prob(20))
		if(user.dir == WEST)
			x_movement *= -1
		animate(user, time=delay/2, pixel_y=orig_y_ofst+y_movement, pixel_x=x_movement)
		animate(time=delay/2, pixel_y=orig_y_ofst, pixel_x=0)
		animate(time=delay, pixel_x=(-x_movement*1.5))
		animate(time=delay*0.5, pixel_x=0)

	tumble(mob/user)
		user.show_text(SPAN_ALERT("You weren't able to keep up with [src]!"))
		user.changeStatus("knockdown", 2 SECONDS)
		src.visible_message(SPAN_ALERT("<b>[user]</b> loses their footing and slides off [src]."))
		eject_occupant()
		var/dx = 2
		if(was_running == EAST)
			dx *= -1
		user.throw_at(get_offset_target_turf(src.loc, dx, 0), abs(dx), 1)
		return TRUE


#undef UNWRENCHED
#undef WRENCHED
