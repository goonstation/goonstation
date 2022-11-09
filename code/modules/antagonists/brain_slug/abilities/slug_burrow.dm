/datum/targetable/brain_slug/slug_burrow
	name = "Burrow"
	desc = "Bust through the flooring and attempt to enter a maintenance pipe. Can also be used when inside a disposal trunk."
	icon_state = "slither"
	cooldown = 10 SECONDS
	targeted = 0
	var/active = FALSE
	var/view_range = 3
	var/list/pipe_images = null
	var/obj/dummy/disposalmover/D = null

	cast()
		var/turf/T = get_turf(holder.owner)
		if(active)
			exit_or_bust_out()
		else
			if (!T || !T.z || isrestrictedz(T.z))
				boutput(holder.owner, "<span class='notice'>There is nothing to dig through!</span>")
				return TRUE
			if (!istype(T, /turf/simulated/floor))
				boutput(holder.owner, "<span class='notice'>You can't seem to find a way to dig here!</span>")
				return TRUE
			else
				var/turf/simulated/floor/floor_turf = T
				var/obj/disposalpipe/P
				if (floor_turf.intact)
					floor_turf.pry_tile(null, holder.owner)
				P = locate(/obj/disposalpipe) in floor_turf
				if (!P)
					boutput(holder.owner, "<span class='alert'>There aren't any pipes here!</span>")
					return TRUE
				if (istype(holder.owner.loc, /obj/disposalpipe/trunk))
					activate()
					return TRUE
				else
					actions.start(new/datum/action/bar/private/icon/brain_slug_burrow(floor_turf, P, src), holder.owner)
					return TRUE

	onAttach(datum/abilityHolder/holder)
		. = ..()
		var/obj/disposalpipe/ctype = /obj/disposalpipe
		var/cicon = initial(ctype.icon)

		pipe_images = new/list(((view_range*2+1)**2)*2)
		for(var/i in 1 to length(pipe_images))
			var/image/cimg = image(cicon)
			cimg.layer = HUD_LAYER_UNDER_3
			cimg.plane = PLANE_OVERLAY_EFFECTS
			pipe_images[i] = cimg

	proc/activate()
		holder.owner.unequip_all()
		active = TRUE
		handle_move()

		var/obj/disposalpipe/P
		P = locate(/obj/disposalpipe) in get_turf(holder.owner)
		if(!P)
			active = FALSE
			CRASH("Unexpected situation!")

		if(isturf(holder.owner.loc))
			holder.owner.visible_message("<span class='alert'><b>[holder.owner] slips into [P]!</b></span>")
		else
			holder.owner.show_message("<span class='notice'>You squeeze your way into [P].</span>")

		D = new/obj/dummy/disposalmover(P, holder.owner, src)
		RegisterSignal(D, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC), .proc/handle_move)
		pointCost = 0
		var/atom/movable/screen/ability/topBar/B = src.object
		B.point_overlay.maptext = null

		//Todo change this icon
		src.icon_state = "disposals_out"

	proc/handle_move()
		var/turf/user_turf = get_turf(holder.owner)
		if (isrestrictedz(user_turf.z) || is_incapacitated(holder.owner))
			exit_or_bust_out()
			active = FALSE
			return
		var/turf/T1 = locate(clamp((user_turf.x - view_range), 1, world.maxx), clamp((user_turf.y - view_range), 1, world.maxy), user_turf.z)
		var/turf/T2 = locate(clamp((user_turf.x + view_range), 1, world.maxx), clamp((user_turf.y + view_range), 1, world.maxy), user_turf.z)

		for(var/turf/T as anything in block(T1, T2))
			var/depth = 0
			for(var/obj/disposalpipe/C in T)
				var/idx = ((C.y - user_turf.y + src.view_range) * src.view_range*2) + (C.x - user_turf.x + src.view_range*2) + 1
				var/image/img = pipe_images[(idx*2)+depth]
				img.appearance = C.appearance
				img.dir = C.dir
				img.invisibility = 0
				img.alpha = 255
				img.layer = HUD_LAYER_UNDER_3
				img.plane = PLANE_OVERLAY_EFFECTS
				img.loc = locate(C.x, C.y, C.z)
				depth += 1

		send_images_to_client()

	proc/exit_or_bust_out(force=FALSE)
		if(isturf(holder.owner.loc)) // Something is wrong...
			force = TRUE

		if(!force && D)
			var/obj/disposalpipe/trunk/P
			var/obj/disposalpipe/local_pipe
			if(istype(D.T.loc, /obj/disposalpipe/trunk))
				P = D.T.loc
				if(P.linked)
					if(istype(P.linked,/obj/machinery/disposal))
						holder.owner.set_loc(P.linked)
					else
						holder.owner.set_loc(D.T)
						P.transfer(D.T)
				else
					holder.owner.visible_message("<span class='alert'><b>[holder.owner] climbs out of [P]!</b></span>")
					holder.owner.set_loc(get_turf(holder.owner))
				deactivate(force)
			else if (istype(D.T.loc, /obj/disposalpipe))
				local_pipe = D.T.loc
				actions.start(new/datum/action/bar/private/icon/brain_slug_bust_out(local_pipe, holder.owner), holder.owner)

	proc/deactivate(force=FALSE)
		active = FALSE

		UnregisterSignal(D, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC))
		src.holder.owner.client?.images -= pipe_images
		qdel(D)
		D = null
		//Todo change this icon
		src.icon_state = "disposals"
		if(force)
			holder.updateButtons()

	proc/send_images_to_client()
		if ((!holder.owner?.client) || (!isalive(holder.owner)) || (isrestrictedz(holder.owner.z)))
			exit_or_bust_out()
			return
		holder.owner.client.images += pipe_images

/obj/dummy/disposalmover
	icon = null
	name = "???"
	desc = "Something is in disposals again..."
	anchored = 1
	density = 0
	opacity = 0
	var/can_move = 1
	var/image/img = null
	var/mob/the_user = null
	var/obj/disposalpipe/current_pipe
	var/obj/disposalholder/traveler/T
	var/datum/targetable/brain_slug/slug_burrow/A

	New(atom/location, mob/target, datum/targetable/brain_slug/slug_burrow/ability)
		..()
		src.set_loc(get_turf(location))
		T = new(src)
		T.traveler = target
		T.set_loc(location)
		current_pipe = location
		if(target)
			A = ability
			the_user = target
			target.set_loc(src)
			img = image('icons/effects/effects.dmi',src ,"orb")
			img.layer = HUD_LAYER
			img.plane = PLANE_OVERLAY_EFFECTS
			img.color = "#111"
			target << img
		RegisterSignal(the_user, list(COMSIG_MOB_DROPPED), .proc/handle_dropped_item)
		APPLY_ATOM_PROPERTY(the_user, PROP_MOB_CANTTHROW, src)

	proc/handle_dropped_item(mob/user, atom/movable/AM)
		var/obj/disposalholder/H = new(current_pipe)
		AM.set_loc(H)

	remove_air(amount as num)
		var/datum/gas_mixture/Air = new /datum/gas_mixture
		Air.oxygen = amount
		Air.temperature = 310
		return Air

	relaymove(mob/user, direction, delay, running)
		var/obj/disposalpipe/source_pipe
		var/obj/disposalpipe/destination_pipe

		if(!user.canmove)
			playsound(src, "step_barefoot", vol=80, vary=TRUE, extrarange=-1)

		if(can_move)
			if(istype(current_pipe, /obj/disposalpipe))
				source_pipe = current_pipe
			direction = source_pipe?.dpdir & direction
			if(direction)
				if (direction & (direction-1))
					return // no safe assumptions can be made, stop trying

				var/turf/new_loc = get_step(src, direction)
				for(var/obj/disposalpipe/P in new_loc)
					var/fdir = turn(direction, 180)	// flip the movement direction to find which connects back
					if(fdir & P.dpdir)
						destination_pipe = P
						break

				if(destination_pipe)
					// soylent green
					if(istype(destination_pipe, /obj/disposalpipe/loafer))
						var/obj/disposalholder/H = new(destination_pipe)
						user.set_loc(H)
						A.exit_or_bust_out(force=TRUE)
						destination_pipe.transfer(H)
						return

					if (prob(33))
						playsound(src, "step_barefoot", vol=80, vary=TRUE, extrarange=-1)

					delay = max(delay, 0.8)
					if (direction & (direction-1))
						delay *= DIAG_MOVE_DELAY_MULT

					var/glide = ((32 / delay) * world.tick_lag)
					src.glide_size = glide
					src.animate_movement = SLIDE_STEPS
					user.animate_movement = SYNC_STEPS
					user.glide_size = glide

					var/obj/disposalholder/H2 = locate() in destination_pipe
					if(H2 && H2.active)
						T.merged(H2)
						A.exit_or_bust_out(force=TRUE)
					else
						T.set_loc(destination_pipe)

					// Use step to allow for smooth glide
					if(!step(src, direction))
						//Set location if we get blocked by dense object, simulate glide delay
						src.set_loc(get_turf(destination_pipe))
						can_move = 0
						SPAWN(delay) can_move = 1

					src.glide_size = glide
					src.animate_movement = SLIDE_STEPS
					user.glide_size = glide

					if (running)
						user.remove_stamina((user.lying ? 3 : 1) * STAMINA_COST_SPRINT)

					current_pipe = destination_pipe
				else
					the_user.set_loc(get_turf(src))
					the_user.visible_message("<span class='alert'><b>[the_user] crawls out of [source_pipe]!</b></span>")
					step(the_user, direction)
					A.exit_or_bust_out(force=TRUE)

			else
				if(!ON_COOLDOWN(src, "vent_bonk", 1 SECOND))
					if(running)
						playsound(src, 'sound/impact_sounds/Metal_Clang_1.ogg', 50, 0, 0)
					else
						playsound(src, 'sound/impact_sounds/Wood_Hit_1.ogg', 15, 1, -3)


		return delay

	disposing()
		REMOVE_ATOM_PROPERTY(the_user, PROP_MOB_CANTTHROW, src)
		the_user = null
		qdel(T)
		T = null
		return ..()

/obj/disposalholder/traveler
	var/mob/traveler
	var/obj/dummy/disposalmover/holder

	New(obj/dummy/disposalmover/H)
		. = ..()
		src.holder = H

	merged(obj/disposalholder/host )
		..()
		traveler.set_loc(host)
		holder.A.exit_or_bust_out(force=TRUE)
		return

/datum/action/bar/private/icon/brain_slug_burrow
	duration = 4 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ATTACKED
	id = "brain_slug_burrow"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/turf/simulated/floor/the_floor = null
	var/mob/living/the_mob = null
	var/obj/disposalpipe/the_pipe = null

	New(var/turf/simulated/floor/T, var/obj/disposalpipe/target, source)
		the_floor = T
		the_pipe = target
		..()

	onStart()
		..()
		var/mob/living/caster = owner
		if (caster == null || !isalive(caster) || !can_act(caster) || the_floor == null || the_pipe == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (the_pipe.holed_up)
			boutput(caster, "<span class=notice>You begin to enter the holed up pipe.</span>")
			src.duration = src.duration / 2
		else
			boutput(caster, "<span class=alert>You begin to pierce into the disposal pipe below!</span>")

	onUpdate()
		..()
		var/mob/living/caster = owner

		if (caster == null || !isalive(caster) || !can_act(caster) || the_floor == null || the_pipe == null || BOUNDS_DIST(caster, the_pipe) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (prob(50))
			animate_storage_thump(the_pipe)
			playsound(src, 'sound/impact_sounds/Metal_Clang_1.ogg', 50, 0, 0)

	onEnd()
		..()
		var/mob/living/caster = owner
		if (the_pipe.holed_up)
			boutput(caster, "<span class=notice>You come out of the holed up pipe.</span>")
		else
			boutput(caster, "<span class=notice>You hole up the pipe and hide inside of it.</span>")
			the_pipe.bust_open()
			if (prob(50))
				var/obj/item/scrap/scrap_item = new /obj/item/scrap(the_pipe.loc)
				ThrowRandom(scrap_item, 5, 1)
			if (prob(50))
				var/obj/item/raw_material/scrap_metal/scrap_item = new /obj/decal/cleanable/machine_debris(the_pipe.loc)
				ThrowRandom(scrap_item, 5, 1)
			playsound(src, 'sound/impact_sounds/Metal_Clang_1.ogg', 50, 0, 0)
		var/datum/targetable/brain_slug/slug_burrow/the_ability = caster.abilityHolder.getAbility(/datum/targetable/brain_slug/slug_burrow)
		the_ability.activate()

	onInterrupt()
		..()
		var/mob/living/caster = owner
		boutput(caster, "<span class='alert'>You were interrupted!</span>")

/datum/action/bar/private/icon/brain_slug_bust_out
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ATTACKED
	id = "brain_slug_burrow"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/mob/living/the_mob = null
	var/obj/disposalpipe/the_pipe = null

	New(var/obj/disposalpipe/target, source)
		the_pipe = target
		..()

	onStart()
		..()
		var/mob/living/caster = owner
		if (caster == null || !isalive(caster) || the_pipe == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (the_pipe.holed_up)
			boutput(caster, "<span class=notice>You begin to exit the holed up pipe.</span>")
			src.duration = 2 SECONDS
		else
			boutput(caster, "<span class=alert>You begin to bust out of the pipe!</span>")

	onUpdate()
		..()
		var/mob/living/caster = owner

		if (caster == null || !isalive(caster) || the_pipe == null || BOUNDS_DIST(caster, the_pipe) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (prob(40))
			animate_storage_thump(the_pipe)
			playsound(src, 'sound/impact_sounds/Metal_Clang_1.ogg', 50, 0, 0)

	onEnd()
		..()
		var/mob/living/caster = owner
		var/turf/T = get_turf(the_pipe)
		if (istype(T, /turf/simulated/floor))
			var/turf/simulated/floor/floor_turf = T
			if (floor_turf.intact)
				floor_turf.pry_tile(null, caster)
		if (the_pipe.holed_up)
			boutput(caster, "<span class='notice'>You come out of the bursted pipe</span>")
		else
			boutput(caster, "<span class='notice'>You hole up the pipe and burst out of it.</span>")
			the_pipe.bust_open()
			if (prob(50))
				var/obj/item/scrap/scrap_item = new /obj/item/scrap(T)
				ThrowRandom(scrap_item, 5, 1)
			if (prob(50))
				var/obj/item/raw_material/scrap_metal/scrap_item = new /obj/decal/cleanable/machine_debris(T)
				ThrowRandom(scrap_item, 5, 1)
			playsound(src, 'sound/impact_sounds/Metal_Clang_1.ogg', 50, 0, 0)
		caster.set_loc(T)
		for (var/mob/living/M in range(0, the_pipe))
			if (M == caster) continue
			ThrowRandom(M, 3, 1)
			M.setStatus("stunned", 3 SECONDS)
			M.visible_message("<span class='alert'>[M] is suddenly thrown away by something coming out of the ground!</span>")

		var/datum/targetable/brain_slug/slug_burrow/the_ability = caster.abilityHolder.getAbility(/datum/targetable/brain_slug/slug_burrow)
		the_ability.deactivate(TRUE)

	onInterrupt()
		..()
		var/mob/living/caster = owner
		boutput(caster, "<span class='alert'>You were interrupted!</span>")
