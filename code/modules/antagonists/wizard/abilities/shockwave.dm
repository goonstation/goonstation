/datum/targetable/spell/shockwave
	name = "Shockwave"
	desc = "Violently throws nearby targets away from the caster."
	icon_state = "shockwave"
	targeted = 0
	cooldown = 400
	requires_robes = 1
	offensive = 1
	voice_grim = 'sound/voice/wizard/EarthquakeGrim.ogg'
	voice_fem = 'sound/voice/wizard/EarthquakeFem.ogg'
	voice_other = 'sound/voice/wizard/EarthquakeLoud.ogg'

	cast()
		if(!holder)
			return
		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("ERATH QUUK")
		..()

		playsound(holder.owner.loc, 'sound/effects/exlow.ogg', 25, 1, -1)

		new/obj/effects/shockwave(holder.owner.loc)

		var/list/range1 = orange(1, holder.owner.loc)
		var/list/range2 = orange(2, holder.owner.loc)
		var/list/range3 = orange(3, holder.owner.loc)

		var/list/affected = list()
		get_edge_target_turf(src, holder.owner.dir)
		for(var/atom/A in range1)
			if(affected.Find(A)) continue
			if(check_target_immunity( A )) continue
			affected += A
			//animate_shockwave(A)
			if(hasvar(A, "weakened")) A:weakened += 3
			if(istype(A, /atom/movable))
				if(!isturf(A) && hasvar(A, "anchored") && !A:anchored)
					SPAWN(0) A:throw_at(get_edge_cheap(A, get_dir(holder.owner, A)), 30, 1)
		sleep(0.3 SECONDS)
		for(var/atom/A in range1 ^ range2)
			if(affected.Find(A)) continue
			if(check_target_immunity( A )) continue
			affected += A
			//animate_shockwave(A)
			if(hasvar(A, "weakened")) A:weakened += 3
			if(istype(A, /atom/movable))
				if(!isturf(A) && hasvar(A, "anchored") && !A:anchored)
					SPAWN(0) A:throw_at(get_edge_cheap(A, get_dir(holder.owner, A)), 30, 1)
		sleep(0.3 SECONDS)
		for(var/atom/A in range2 ^ range3)
			if(affected.Find(A)) continue
			if(check_target_immunity( A )) continue
			affected += A
			//animate_shockwave(A)
			if(hasvar(A, "weakened")) A:weakened += 3
			if(istype(A, /atom/movable))
				if(!isturf(A) && hasvar(A, "anchored") && !A:anchored)
					SPAWN(0) A:throw_at(get_edge_cheap(A, get_dir(holder.owner, A)), 30, 1)

/obj/effects/shockwave
	name = "shockwave"
	desc = ""
	anchored = 1
	layer = EFFECTS_LAYER_1
	density = 0
	opacity = 0
	icon = 'icons/effects/224x224.dmi'
	icon_state = "shockwave"
	pixel_y = -96
	pixel_x = -96

	New()
		..()
		src.Scale(0,0)
		animate(src, matrix(1.4, MATRIX_SCALE), time = 6, color = "#ffdddd", easing = LINEAR_EASING)
		animate(time = 2, alpha = 0)
		SPAWN(0.8 SECONDS) qdel(src)
