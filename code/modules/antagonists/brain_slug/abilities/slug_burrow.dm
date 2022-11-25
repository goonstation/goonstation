/datum/targetable/brain_slug/slug_burrow
	name = "Burrow"
	desc = "Burst through the flooring and attempt to enter a maintenance pipe. Can also be used when inside a disposal trunk."
	icon_state = "enter_disposal"
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

		D = new/obj/dummy/disposalmover(P, holder.owner, src, .proc/exit_or_bust_out)
		RegisterSignal(D, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC), .proc/handle_move)
		pointCost = 0
		var/atom/movable/screen/ability/topBar/B = src.object
		B.point_overlay.maptext = null

		src.icon_state = "exit_disposal"

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
		src.icon_state = "enter_disposal"
		if(force)
			holder.updateButtons()

	proc/send_images_to_client()
		if ((!holder.owner?.client) || (!isalive(holder.owner)) || (isrestrictedz(holder.owner.z)))
			exit_or_bust_out()
			return
		holder.owner.client.images += pipe_images

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
			playsound(the_pipe.loc, 'sound/impact_sounds/Metal_Clang_1.ogg', 50, 0, 0)

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
				var/obj/item/raw_material/scrap_metal/scrap_item = new /obj/item/raw_material/scrap_metal(the_pipe.loc)
				ThrowRandom(scrap_item, 5, 1)
			playsound(the_pipe.loc, 'sound/impact_sounds/Metal_Clang_1.ogg', 50, 0, 0)
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
			playsound(the_pipe.loc, 'sound/impact_sounds/Metal_Clang_1.ogg', 50, 0, 0)

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
				var/obj/item/raw_material/scrap_metal/scrap_item = new /obj/item/raw_material/scrap_metal(T)
				ThrowRandom(scrap_item, 5, 1)
			playsound(the_pipe.loc, 'sound/impact_sounds/Metal_Clang_1.ogg', 50, 0, 0)
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
