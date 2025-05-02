
/mob/var/prev_loc = 0 //! The location of the mob before it last moved
/mob/var/move_dir = 0 //! The direction the mob is moving/last moved
/mob/var/prev_move = 0 //! The time the mob last moved
/mob/var/next_move = 0 //! The next time the mob can move
/mob/var/is_running = 0 //! If the mob is running

/mob/var/movement_last_modified = 0 //! When mob's movement was last modified
/mob/var/movement_last_delay = 0 //! The last speed the mob was moving at
/mob/var/movement_last_progress = 0 //! The progress of the move the mob was at when it was last modified

/mob/hotkey(name)
	var/datum/movement_controller/controller = src.override_movement_controller
	if (controller)
		return controller.hotkey(src, name)
	return ..()

/mob/proc/can_turn()
	return !src.dir_locked && (!isliving(src) || !isdead(src)) && !HAS_ATOM_PROPERTY(src, PROP_MOB_CANTTURN)

/mob/proc/keys_changed(keys, changed)
	set waitfor = 0
	if (changed & KEY_EXAMINE && src.client)
		if (keys & KEY_EXAMINE)
			if (HAS_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES))
				var/atom/movable/name_tag/hover_tag
				for (var/atom/A as anything in src.get_tracked_examine_atoms())
					hover_tag = A.get_examine_tag(src)
					hover_tag?.show_images(src.client, TRUE, FALSE)
			if (src.atom_hovered_over)
				var/atom/A = src.atom_hovered_over
				var/atom/movable/name_tag/hover_tag = A.get_examine_tag(src)
				hover_tag?.show_images(src.client, FALSE, TRUE)
		else
			if (HAS_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES))
				var/atom/movable/name_tag/hover_tag
				for (var/mob/A as anything in src.get_tracked_examine_atoms())
					hover_tag = A.get_examine_tag(src)
					hover_tag?.show_images(src.client, FALSE, FALSE)
			else if (src.atom_hovered_over)
				var/atom/A = src.atom_hovered_over
				var/atom/movable/name_tag/hover_tag = A.get_examine_tag(src)
				hover_tag?.show_images(src.client, FALSE, FALSE)

	var/datum/movement_controller/controller = src.override_movement_controller
	if (controller)
		controller.keys_changed(src, keys, changed)
		return

	if (changed & (KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT))
		var/move_x = 0
		var/move_y = 0
		if (keys & KEY_FORWARD)
			move_y += 1
		if (keys & KEY_BACKWARD)
			move_y -= 1
		if (keys & KEY_RIGHT)
			move_x += 1
		if (keys & KEY_LEFT)
			move_x -= 1
		if (move_x || move_y)
			if(!src.move_dir && src.canmove && src.restrained())
				if (src.pulled_by || length(src.grabbed_by))
					boutput(src, SPAN_NOTICE("You're restrained! You can't move!"))

			src.move_dir = angle2dir(arctan(move_y, move_x))
			attempt_move(src)
		else
			src.move_dir = 0

		if(src.can_turn()) //in order to not turn around and good fuckin ruin the emote animation
			src.set_dir(src.move_dir)
	if (changed & (KEY_THROW|KEY_PULL|KEY_POINT|KEY_EXAMINE|KEY_BOLT|KEY_OPEN|KEY_SHOCK)) // bleh
		src.update_cursor()


/mob/proc/get_move_delay()
	var/delay = max(src.movement_delay(get_step(src,src.move_dir), is_running), world.tick_lag) // don't divide by zero
	if (move_dir & (move_dir-1))
		delay *= DIAG_MOVE_DELAY_MULT // actual sqrt(2) unsurprisingly resulted in rounding errors
	if (src.buckled && istype(src.buckled, /obj/stool/chair))
		var/obj/stool/chair/C = src.buckled
		delay += C.buckle_move_delay //GriiiiIIIND
	for (var/obj/item/grab/G as anything in src.grabbed_by)
		if (istype(G) && BOUNDS_DIST(src, G.assailant) > 0)
			if (G.state > GRAB_STRONG)
				delay += G.assailant.p_class
	return delay

/mob/proc/process_movespeed_update()
	if (next_move > world.time)
		var/new_delay = get_move_delay()

		// calculate how far the player has moved
		var/move_complete = src.movement_last_progress + (world.time - src.movement_last_modified)/src.movement_last_delay

		src.glide_size = (world.icon_size / ceil(new_delay / world.tick_lag))
		next_move = world.time + (1-move_complete)*new_delay
		src.movement_last_modified = world.time
		src.movement_last_delay = new_delay
		src.movement_last_progress = move_complete
		return

/mob/proc/process_move(keys)
	set waitfor = 0
	var/datum/movement_controller/controller = src.override_movement_controller
	if (controller)
		return controller.process_move(src, keys)

	if (isdead(src) && isliving(src))
		if (keys)
			// Ghostize people who are trying to move while in a dead body.
			boutput(src, SPAN_NOTICE("You leave your dead body. You can use the 'Re-enter Corpse' command to return to it."))
			src.ghostize()
		return

	if (src.next_move - world.time >= world.tick_lag / 10)
		return max(world.tick_lag, (src.next_move - world.time) - world.tick_lag / 10)

	if (src.move_dir)
		var/mob/living/carbon/human/H = src
		if ((keys & KEY_RUN) && \
		      ((H.get_stamina() > STAMINA_COST_SPRINT && HAS_ATOM_PROPERTY(src, PROP_MOB_FAILED_SPRINT_FLOP)) ||  H.get_stamina() > STAMINA_SPRINT) && \
			  !HAS_ATOM_PROPERTY(src, PROP_MOB_CANTSPRINT))
			src.is_running = 1
		else
			src.is_running = 0
		if (H.pushing && get_dir(H,H.pushing) != H.move_dir) //Stop pushing before calculating move_delay if we've changed direction
			H.pushing = 0

		var/delay = get_move_delay()
		movement_last_delay = delay
		movement_last_modified = world.time
		movement_last_progress = 0
		var/move_dir = src.move_dir
		if (src.client && src.client.flying || (ismob(src) && HAS_ATOM_PROPERTY(src, PROP_MOB_NOCLIP)))
			if(isnull(get_step(src, move_dir)))
				return
			var/glide = 32 / (is_running ? 0.5 : 1.5) * world.tick_lag
			if (!ticker || last_move_trigger + 10 <= ticker.round_elapsed_ticks)
				last_move_trigger = ticker.round_elapsed_ticks
				deliver_move_trigger(is_running ? "sprint" : m_intent)

			src.glide_size = glide // dumb hack: some Move() code needs glide_size to be set early in order to adjust "following" objects
			src.animate_movement = SLIDE_STEPS
			src.set_loc(get_step(src.loc, move_dir))
			if(!src.dir_locked) //in order to not turn around and good fuckin ruin the emote animation
				src.set_dir(move_dir)
			OnMove()
			src.glide_size = glide
			next_move = world.time + (is_running ? 0.5 : 1.5)
			prev_move = world.time
			return (is_running ? 0.5 : 1.5)
		src.update_canmove()
		if (src.canmove)
			if (src.restrained())
				if (src.pulled_by || length(src.grabbed_by))
					return

			var/misstep_angle = 0
			if (src.traitHolder && prob(5) && src.traitHolder.hasTrait("leftfeet"))
				misstep_angle += 45
			if (prob(DISORIENT_MISSTEP_CHANCE) && src.getStatusDuration("disorient"))
				misstep_angle += 45
			if (prob(src.misstep_chance)) // 1.5 beecause going off straight chance felt weird; I don't want to totally nerf effects that rely on this
				misstep_angle += randfloat(0,src.misstep_chance*1.5)  // 66% Misstep Chance = 9% chance of 90 degree turn

			if(misstep_angle)
				misstep_angle = min(misstep_angle,90)
				var/move_angle = dir2angle(move_dir)
				move_angle += pick(-misstep_angle,misstep_angle)
				move_dir = angle2dir(move_angle)

			if (src.buckled && !istype(src.buckled, /obj/stool/chair))
				src.buckled.relaymove(src, move_dir)
			else if (isturf(src.loc))
				if (src.buckled && istype(src.buckled, /obj/stool/chair))
					var/obj/stool/chair/C = src.buckled
					if (C.rotatable)
						C.rotate(src.move_dir)

				for (var/obj/item/grab/G in src.equipped_list(check_for_magtractor = 0))
					if (BOUNDS_DIST(src, G.affecting) > 0)
						qdel(G)
				for (var/obj/item/grab/G as anything in src.grabbed_by)
					if (istype(G) && BOUNDS_DIST(src, G.assailant) > 0)
						qdel(G)

				var/turf/old_loc = src.loc
				src.prev_loc = old_loc

				//use commented bit if you wanna have world fps different from client. But its not perfect!
				var/glide = (world.icon_size / ceil(delay / world.tick_lag)) //* (world.tick_lag / CLIENTSIDE_TICK_LAG_SMOOTH))

				var/spacemove = 0
				if (src.no_gravity || (old_loc.throw_unlimited && !src.is_spacefaring()) )

					spacemove = 1
					for (var/atom/A in oview(1,src))
						if (A.stops_space_move && (!src.no_gravity || !isfloor(A)))
							spacemove = 0
							break

				if (spacemove)
					if (istype(src.back, /obj/item/tank/jetpack))
						var/obj/item/tank/jetpack/J = src.back
						if(J.allow_thrust(0.01, src))
							spacemove = 0
							src.inertia_dir = 0
					else if (ishuman(src))
						var/mob/living/carbon/human/Hu = src // I hate doing this uuuugh
						if (istype(Hu.shoes, /obj/item/clothing/shoes/jetpack))
							var/obj/item/clothing/shoes/jetpack/J = Hu.shoes
							if (J.allow_thrust(0.01, src))
								spacemove = 0
								src.inertia_dir = 0
					else if (isrobot(src) || isghostdrone(src) || isshell(src))
						if (src:jetpack)
							spacemove = 0
							src.inertia_dir = 0

					if (!spacemove) // yes, this is dumb
						// also fuck it.
						var/obj/effects/ion_trails/I = new /obj/effects/ion_trails
						I.set_loc(src.loc)
						I.set_dir(src.dir)
						FLICK("ion_fade", I)
						I.icon_state = "blank"
						I.pixel_x = src.pixel_x
						I.pixel_y = src.pixel_y
						SPAWN( 20 )
							if (I && !I.disposed) qdel(I)

				if (!spacemove) // buh
					// if the gameticker doesn't exist yet just work with no cooldown
					src.inertia_dir = 0

					if (!ticker || last_move_trigger + 10 <= ticker.round_elapsed_ticks)
						last_move_trigger = ticker ? ticker.round_elapsed_ticks : 0 //Wire note: Fix for Cannot read null.round_elapsed_ticks
						deliver_move_trigger(is_running ? "sprint" : m_intent)

					// Tripping (the physical kind)
					var/trip_chance = 2 // because of how often this is called, 2% seems like more than enough
					if (src.traitHolder && src.traitHolder.hasTrait("trippy") && prob(trip_chance))
						src.setStatus("resting", INFINITE_STATUS)
						src.force_laydown_standup()
						src.visible_message(SPAN_ALERT("<B>[src]</B> trips!"))

					src.glide_size = glide // dumb hack: some Move() code needs glide_size to be set early in order to adjust "following" objects
					src.animate_movement = SLIDE_STEPS
					//if (src.client && src.client.flying)
					//	src.set_loc(get_step(src.loc, move_dir))
					//	src.set_dir(move_dir)
					//else
					src.pushing = 0

					var/do_step = 1 //robust grab : don't even bother if we are in a chokehold. Assailant gets moved below. Makes the tile glide better without having a chain of step(src)->step(assailant)->step(me)
					for (var/obj/item/grab/G as anything in src.grabbed_by)
						if (G?.state < GRAB_AGGRESSIVE) continue
						do_step = 0
						break

					if(ishuman(src) && !src?.client?.flying && !src.hasStatus("resting") && !src.buckled && !H.limbs.l_leg && !H.limbs.r_leg)	//do this before we move, so we can dump stuff on the old tile. Just to be mean.
						boutput(src, SPAN_ALERT("Without a leg to walk with, you flop over!"))
						src.setStatus("resting", duration = INFINITE_STATUS)
						src.force_laydown_standup()

					if (do_step)
						step(src, move_dir)
						if (src.loc != old_loc)
							OnMove()

					src.glide_size = glide // but Move will auto-set glide_size, so we need to override it again

					//robust grab : Assailant gets moved here (do_step shit). this is messy, i'm sorry, blame MBC
					if (!do_step || src.loc != old_loc)

						SEND_SIGNAL(src, COMSIG_MOB_TRIGGER_THREAT) //we do this check here because if we DID take a step, we aren't tight-grabbed and the gunpoint shot will be triggered by Mob/Move(). messy i know, fix later
						var/list/stepped = list()
						for (var/obj/item/grab/G as anything in src.grabbed_by)
							if ((G.assailant in stepped) || G.assailant == pushing || G.affecting == pushing) continue
							if (G.state < GRAB_AGGRESSIVE) continue
							if (!G.assailant || !isturf(G.assailant.loc) || G.assailant.anchored)
								return
							src.set_density(0) //assailant shouldn't be able to bump us here. Density is set to 0 by the grab stuff but *SAFETY!*
							step(G.assailant, move_dir)
							delay += G.assailant.p_class
							stepped |= G.assailant


					if (src.loc != old_loc)
						if (is_running)
							src.remove_stamina((src.lying ? 3 : 1) * STAMINA_COST_SPRINT)
							if (src.pulling)
								src.remove_stamina((src.lying ? 3 : 1) * (STAMINA_COST_SPRINT-1))

						if(src.get_stamina() < STAMINA_COST_SPRINT && HAS_ATOM_PROPERTY(src, PROP_MOB_FAILED_SPRINT_FLOP)) //Check after move rather than before so we cleanly transition from sprint to flop
							if (!src?.client?.flying && !src.hasStatus("resting")) //no flop if laying or noclipping
								//just fall over in place when in space (to prevent zooming)
								var/turf/current_turf = get_turf(src)
								if (!(istype(current_turf, /turf/space)))
									src.throw_at(get_step(src, move_dir), 1, 1)
								src.setStatus("resting", duration = INFINITE_STATUS)
								src.force_laydown_standup()
								src.emote("wheeze")
								boutput(src, SPAN_ALERT("You flop over, too winded to continue running!"))

						var/list/pulling = list()
						if (src.pulling)
							if ((BOUNDS_DIST(old_loc, src.pulling) > 0 && BOUNDS_DIST(src, src.pulling) > 0) || !isturf(src.pulling.loc) || src.pulling == src) // fucks sake
								src.remove_pulling()
								//hud.update_pulling() // FIXME
							else
								pulling += src.pulling
						for (var/obj/item/grab/G in src.equipped_list(check_for_magtractor = 0))
							pulling += G.affecting

						for (var/atom/movable/A in pulling)
							if (GET_DIST(src, A) == 0) // if we're moving onto the same tile as what we're pulling, don't pull
								continue
							if (A == src || A == pushing)
								continue
							if (!isturf(A.loc) || A.anchored)
								continue // whoops
							A.animate_movement = SYNC_STEPS
							A.glide_size = glide
							step(A, get_dir(A, old_loc))
							A.glide_size = glide
							A.OnMove(src)
			else
				if(!src.dir_locked) //in order to not turn around and good fuckin ruin the emote animation
					src.set_dir(move_dir)
				if (src.loc) //ZeWaka: Fix for null.relaymove
					delay = src.loc.relaymove(src, move_dir, delay, is_running) //relaymove returns 1 if we dont want to override delay
					if (!delay)
						delay = 0.5

			next_move = world.time + delay
			prev_move = world.time
			return delay
		else
			if (src.restrained() || !isalive(src))
				return
			for (var/obj/item/grab/G as anything in src.grabbed_by)
				if (G.state == GRAB_PIN)
					if (src.last_resist > world.time)
						return
					src.last_resist = world.time + 20
					G.do_resist()
