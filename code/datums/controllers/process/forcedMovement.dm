proc/BeginSpacePush(var/atom/movable/A)
	if (!(A.temp_flags & SPACE_PUSHING))
		spacePushList += A
		A.temp_flags |= SPACE_PUSHING

proc/EndSpacePush(var/atom/movable/A)
	if(ismob(A))
		var/mob/M = A
		M.inertia_dir = 0
	spacePushList -= A
	A.temp_flags &= ~SPACE_PUSHING

/// Controls forced movements
/datum/controller/process/fMove
	var/list/debugPushList = null //Remove this on release.

	setup()
		name = "Forced movement"
		schedule_interval = 0.5 SECONDS

	doWork()
		//space first :)
		for (var/atom/movable/M as anything in spacePushList)
			if(!M)
				continue

			var/turf/T = M.loc
			if (!istype(T) || (!(istype(T, /turf/space) || T.throw_unlimited) || T != M.loc) && !M.no_gravity)
				EndSpacePush(M)
				continue

			if (ismob(M))
				var/mob/tmob = M
				if(tmob.client && tmob.client.flying || (ismob(tmob) && HAS_ATOM_PROPERTY(tmob, PROP_MOB_NOCLIP)))
					EndSpacePush(M)
					continue

				if (istype(T, /turf/space) || M.no_gravity)
					var/prob_slip = 5

					if (tmob.hasStatus("handcuffed"))
						prob_slip = 100

					if (!tmob.canmove)
						prob_slip = 100

					for (var/atom/AA in oview(1,tmob))
						if (AA.stops_space_move && (!M.no_gravity || !isfloor(AA)))
							if (!( tmob.l_hand ))
								prob_slip -= 3
							else if (tmob.l_hand.w_class <= W_CLASS_SMALL)
								prob_slip -= 1

							if (!( tmob.r_hand ))
								prob_slip -= 2
							else if (tmob.r_hand.w_class <= W_CLASS_SMALL)
								prob_slip -= 1

							break

					prob_slip = round(prob_slip)
					if (prob_slip < 5) //next to something, but they might slip off
						if (prob(prob_slip) )
							boutput(tmob, SPAN_NOTICE("<B>You slipped!</B>"))
							tmob.inertia_dir = tmob.last_move
							step(tmob, tmob.inertia_dir)
							continue
						else
							EndSpacePush(M)
							continue

				else
					var/end = 0
					for (var/atom/AA in oview(1,tmob))
						if (AA.stops_space_move && (!M.no_gravity || !isfloor(AA)))
							end = 1
							break
					if (end)
						EndSpacePush(M)
						continue


				if (M && !( M.anchored ) && !(M.flags & NODRIFT))
					if (! (TIME > (tmob.l_move_time + schedule_interval)) ) //we need to stand still for 5 realtime ticks before space starts pushing us!
						continue

					var/pre_inertia_loc = M.loc

					var/glide = (32 / schedule_interval) * world.tick_lag
					tmob.glide_size = glide
					tmob.animate_movement = SLIDE_STEPS

					if(tmob.inertia_dir) //they keep moving the same direction
						var/original_dir = tmob.dir
						step(tmob, tmob.inertia_dir)
						tmob.set_dir(original_dir)
					else
						tmob.inertia_dir = tmob.last_move
						step(tmob, tmob.inertia_dir)

					tmob.glide_size = glide

					if(tmob.loc == pre_inertia_loc) //something stopped them from moving so cancel their inertia
						tmob.inertia_dir = 0
				else
					EndSpacePush(M)
					continue

			else if (isobj(M))
				var/glide = (32 / schedule_interval) * world.tick_lag
				M.glide_size = glide
				M.animate_movement = SLIDE_STEPS

				step(M, M.last_move)

				M.glide_size = glide
			else
				EndSpacePush(M)
				continue

			if(M.loc == T) // we didn't move, probably hit something
				EndSpacePush(M)
				continue









		//now manta!
		debugPushList = mantaPushList
		if(mantaMoving == 1)
			for (var/atom/movable/M as anything in mantaPushList)
				if(!M)
					continue

				var/turf/T = get_turf(M)
				if (T && ! (T.turf_flags & MANTA_PUSH) )
					continue

				if (T != M.loc)
					continue

				if(M.throwing)
					continue

				if ((M.event_handler_flags & IMMUNE_MANTA_PUSH || M.anchored || M.throwing) && !istype(M,/obj/decal)) //mbc : decal is here for blood cleanables, consider somehow optimizing or adjusting later
					continue

				if(ismob(M))
					var/mob/B = M
					if(B.client && B.client.flying || (ismob(B) && HAS_ATOM_PROPERTY(B, PROP_MOB_NOCLIP)))
						continue

					if (ishuman(B))
						var/mob/living/carbon/human/H = B
						if (H.back && H.back.c_flags & IS_JETPACK)
							if (istype(H.back, /obj/item/tank/jetpack)) //currently unnecessary but what if we have IS_JETPACK on clothing items that are not back-wear later on?
								var/obj/item/tank/jetpack/J = H.back
								if(J.allow_thrust(0.01, H))
									continue

					if (isghostdrone(B) && MagneticTether)
						continue

					M.setStatus("slowed", 2 SECONDS, 20)

				if(!step(M, SOUTH))
					var/dirMod = pick(1, -1)
					if(!step(M, turn(SOUTH, 90*dirMod)))
						step(M, turn(SOUTH, 90*-dirMod))
		return

	tickDetail()
		boutput(usr, "<b>ForcedMovement:</b> Managing [mantaPushList.len] mantapush objects and [spacePushList.len] spacepush objects")
