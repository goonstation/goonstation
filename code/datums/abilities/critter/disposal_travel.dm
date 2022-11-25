/datum/targetable/vent_move
	name = "Get in the disposals"
	desc = "Make your way into the disposal system."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "disposals"
	cooldown = 0 SECONDS
	var/active = FALSE
	var/view_range = 3
	var/list/pipe_images = null
	var/obj/dummy/disposalmover/D = null
	var/border_icon = 'icons/mob/critter_ui.dmi'
	var/border_state = "template_red"

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

		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

	cast(atom/target)
		. = ..()
		if (active)
			deactivate()
		else
			var/turf/T = get_turf(holder.owner)
			var/obj/disposalpipe/P

			if (!T.z || isrestrictedz(T.z))
				boutput(holder.owner, "<span class='alert'>You are forbidden from using that here!</span>")
				return TRUE

			P = locate(/obj/disposalpipe) in T
			// Attempt entry via disposal machinery OR a disconnected disposal pipe
			if (!istype(holder.owner.loc, /obj/machinery/disposal) && (P?.invisibility || !length(P?.disconnected_dirs()) ))
				boutput(holder.owner, "<span class='alert'>You there isn't anything to climb into here!</span>")
				return TRUE

			if (!P)
				boutput(holder.owner, "<span class='alert'>There aren't any pipes here!</span>")
				return TRUE

			activate()

	proc/activate()
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

		holder.owner.setStatus("disposals", INFINITE_STATUS)
		src.icon_state = "disposals_out"

	proc/handle_move()
		var/turf/user_turf = get_turf(holder.owner)
		if (isrestrictedz(user_turf.z) || is_incapacitated(holder.owner))
			deactivate()
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

	proc/deactivate(force=FALSE)
		if(isturf(holder.owner.loc)) // Something is wrong...
			force = TRUE

		if(!force && D)
			var/obj/disposalpipe/trunk/P
			if(istype(D.T.loc, /obj/disposalpipe/trunk))
				P = D.T.loc
			else
				boutput(holder.owner, "<span class='alert'>There isn't anywhere to climb out of here!</span>")
				return

			if(P.linked)
				if(istype(P.linked,/obj/machinery/disposal))
					holder.owner.set_loc(P.linked)
				else
					holder.owner.set_loc(D.T)
					P.transfer(D.T)
			else
				holder.owner.visible_message("<span class='alert'><b>[holder.owner] climbs out of [P]!</b></span>")
				holder.owner.set_loc(get_turf(holder.owner))

		active = FALSE

		UnregisterSignal(D, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC))
		src.holder.owner.client?.images -= pipe_images
		qdel(D)
		D = null
		holder.owner.delStatus("disposals")
		src.icon_state = "disposals"
		if(force)
			holder.updateButtons()

	proc/send_images_to_client()
		if ((!holder.owner?.client) || (!isalive(holder.owner)) || (isrestrictedz(holder.owner.z)))
			deactivate()
			return
		holder.owner.client.images += pipe_images

/datum/targetable/vent_move/green
	border_state = "template_tr"

/datum/targetable/vent_move/changeling
	border_icon = 'icons/mob/spell_buttons.dmi'
	border_state = "changeling-template"

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
	var/datum/targetable/vent_move/A

	New(atom/location, mob/target, datum/targetable/vent_move/ability)
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
						A.deactivate(force=TRUE)
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
						A.deactivate(force=TRUE)
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
					A.deactivate(force=TRUE)

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
		holder.A.deactivate(force=TRUE)
		return

/datum/statusEffect/disposals
	id = "disposals"
	name = "In disposals..."
	desc = ""
	icon_state = "eye"
	unique = 1

	onAdd(optional=null)
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			M.addOverlayComposition(/datum/overlayComposition/limited_sight)
			M.updateOverlaysClient(M.client)

	onRemove()
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			M.removeOverlayComposition(/datum/overlayComposition/limited_sight)
			M.updateOverlaysClient(M.client)

	getTooltip()
		. = "Oh my it is dark in here."
