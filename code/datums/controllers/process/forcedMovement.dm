/obj/effect/event_handler_flags = IMMUNE_MANTA_PUSH //mbc dont know where to put this because we have no master effects file lol lets leave it here, maybe someone wil clean up later >:)

proc/BeginSpacePush(var/atom/movable/A)
	if (!(A.temp_flags & SPACE_PUSHING))
		spacePushList += A
		A.temp_flags |= SPACE_PUSHING

proc/EndSpacePush(var/atom/movable/A)
	spacePushList -= A
	A.temp_flags &= ~SPACE_PUSHING

datum/controller/process/fMove
	var/list/debugPushList = null //Remove this on release.

	// mbc : replaced with IMMUNE_MANTA_PUSH flag. faster.
	/*
	var/list/pushBlacklist = list(
		/obj/fluid,
		/obj/fluid_spawner,
		/obj/effect,
		/obj/overlay,
		/obj/particle,
		/obj/torpedo,
		/obj/torpedo_targeter,
		/obj/machinery/vehicle/tank/minisub,
		/obj/machinery/nuclearbomb,
		/mob/living/intangible,
		/mob/dead,
		/mob/wraith,
	)*/

	setup()
		name = "Forced movement"
		schedule_interval = 5

	doWork()
		//space first :)
		for(var/A in spacePushList)
			var/atom/movable/M = A
			if(!M)
				continue

			var/turf/T = get_turf(M)
			if (T && (!(T.turf_flags & CAN_BE_SPACE_SAMPLE || T.throw_unlimited) || T != M.loc)) //ZeWaka: Added T null check re: (forcedMovement.dm,44: Cannot read null.turf_flags)
				EndSpacePush(M)
				continue

			if (ismob(M))
				var/mob/tmob = M
				if(tmob.client && tmob.client.flying)
					EndSpacePush(M)
					continue

				if (T && T.turf_flags & CAN_BE_SPACE_SAMPLE)
					var/prob_slip = 5

					if (tmob.hasStatus("handcuffed"))
						prob_slip = 100

					if (!tmob.canmove)
						prob_slip = 100

					for (var/atom/AA in oview(1,tmob))
						if (AA.stops_space_move)
							if (!( tmob.l_hand ))
								prob_slip -= 3
							else if (tmob.l_hand.w_class <= 2)
								prob_slip -= 1

							if (!( tmob.r_hand ))
								prob_slip -= 2
							else if (tmob.r_hand.w_class <= 2)
								prob_slip -= 1

							break

					prob_slip = round(prob_slip)
					if (prob_slip < 5) //next to something, but they might slip off
						if (prob(prob_slip) )
							boutput(tmob, "<span class='notice'><B>You slipped!</B></span>")
							tmob.inertia_dir = tmob.last_move
							step(tmob, tmob.inertia_dir)
							continue
						else
							EndSpacePush(M)
							continue

				else
					var/end = 0
					for (var/atom/AA in oview(1,tmob))
						if (AA.stops_space_move)
							end = 1
							break
					if (end)
						EndSpacePush(M)
						continue


				if (M && !( M.anchored ) && !(M.flags & NODRIFT))
					if (! (world.timeofday > (tmob.l_move_time + schedule_interval)) ) //we need to stand still for 5 realtime ticks before space starts pushing us!
						continue

					var/pre_inertia_loc = M.loc

					var/glide = (32 / schedule_interval) * world.tick_lag
					tmob.glide_size = glide
					tmob.animate_movement = SLIDE_STEPS

					if(tmob.inertia_dir) //they keep moving the same direction
						var/original_dir = tmob.dir
						step(tmob, tmob.inertia_dir)
						tmob.dir = original_dir
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










		//now manta!
		debugPushList = mantaPushList
		if(mantaMoving == 1)
			for(var/A in mantaPushList)
				var/atom/movable/M = A
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
					if(B.client && B.client.flying)
						continue

					if (ishuman(B))
						var/mob/living/carbon/human/H = B
						if (H.back && H.back.c_flags & IS_JETPACK)
							if (istype(H.back, /obj/item/tank/jetpack)) //currently unnecessary but what if we have IS_JETPACK on clothing items that are not back-wear later on?
								var/obj/item/tank/jetpack/J = H.back
								if(J.allow_thrust(0.01, H))
									continue

					M.setStatus("slowed", 20, 20)

				if(!step(M, SOUTH))
					var/dirMod = pick(1, -1)
					if(!step(M, turn(SOUTH, 90*dirMod)))
						step(M, turn(SOUTH, 90*-dirMod))
		return

	tickDetail()
		boutput(usr, "<b>ForcedMovement:</b> Managing [mantaPushList.len] mantapush objects and [spacePushList.len] spacepush objects")
