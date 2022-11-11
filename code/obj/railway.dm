/var/global/list/railway_vehicles = list()

/proc/find_adaption_points(var/obj/O, var/adT)
	var/turf/T = get_turf(O)
	var/list/ret = list()
	for (var/D in cardinal)
		var/turf/N = get_step(T, D)
		if (N)
			if (locate(adT) in N)
				ret += D
	return ret

/proc/minlist(var/list/L)
	if (!L.len)
		return null
	var/minv = L[1]
	for (var/A in L)
		if (A < minv)
			minv = A
	return minv

/proc/railway_adapt(var/obj/railway/this, var/ad_adj = 1)
	var/list/AP = find_adaption_points(this, /obj/railway)
	var/skip_adj = 0
	switch (AP.len)
		if (0)
			this.dir1 = 0
			this.dir2 = this.dir
			skip_adj = 1
		if (1)
			this.dir1 = 0
			this.dir2 = AP[1]
		else
			this.dir1 = minlist(AP)
			AP -= this.dir1
			this.dir2 = minlist(AP)
	if (ad_adj && !skip_adj)
		if (this.dir1)
			var/turf/N = get_step(this.loc, this.dir1)
			if (N)
				var/obj/railway/R = locate() in N
				if (R)
					R.adapt(0)

		if (this.dir2)
			var/turf/N = get_step(this.loc, this.dir2)
			var/obj/railway/R = locate() in N
			if (N)
				if (R)
					R.adapt(0)

	this.update_icon_state()


/obj/railway
	name = "rail"
	var/dir1
	var/dir2
	icon = 'icons/obj/railway.dmi'
	icon_state = "1-2"
	var/indestructible = 0

	New()
		..()
		setup_dirs()

	proc/setup_dirs()
		if (length(icon_state) == 3)
			var/list/cardinal_str = list("0", "1", "2", "4", "8")
			var/asc_0 = 48
			var/s1_asc = text2ascii(icon_state,1)
			var/s1 = ascii2text(s1_asc)
			var/s2 = ascii2text(text2ascii(icon_state,2))
			var/s3_asc = text2ascii(icon_state,3)
			var/s3 = ascii2text(s3_asc)
			if (s2 == "-" && (s1 in cardinal_str) && (s3 in cardinal_str) && s1 != s3 && s3_asc > s1_asc)
				dir1 = s1_asc - asc_0
				dir2 = s3_asc - asc_0

	proc/entering(var/obj/railway_vehicle/V)

	proc/update_icon_state()
		set_icon_state("[dir1]-[dir2]")

	onVarChanged(variable, oldVal, val)
		..()
		if (variable == "dir1" || variable == "dir2")
			if (dir1 > dir2)
				var/D = dir2
				dir2 = dir1
				dir1 = D
			update_icon_state()
		else if (variable == "icon_state")
			setup_dirs()

	proc/may_pass(var/moving_dir)
		if (dir1 == moving_dir || dir2 == moving_dir)
			var/turf/N = get_step(loc, moving_dir)
			if (N)
				var/obj/railway/R = locate() in N
				var/from_dir = turn(moving_dir, 180)
				if (R && (R.dir1 == from_dir || R.dir2 == from_dir))
					return 1
		return 0

	proc/get_travel_dir(var/last_travel_dir)
		if (last_travel_dir != 0)
			var/camefrom = turn(last_travel_dir, 180)
			if (dir1 == camefrom)
				return dir2
			else if (dir2 == camefrom)
				return dir1
		else
			if (dir1 == 0)
				return dir2
			else if (dir2 == 0)
				return dir1
			else
				return pick(dir1, dir2)

		if (dir1 == last_travel_dir || dir2 == last_travel_dir)
			return last_travel_dir
		else
			return pick(dir1, dir2)

	proc/adapt(var/ad_adj)

	adaptive
		New()
			..()
			adapt()

		adapt(var/ad_adj = 1)
			railway_adapt(src, ad_adj)


	traffic_control
		name = "rail"
		var/hold_range = 15

		proc/traverse_check(var/obj/railway/current, var/last_travel_dir, var/distance)
			if (distance == 0)
				return
			if (current == src)
				return 1
			if (locate(/obj/railway_vehicle) in get_turf(current))
				return 0
			if (istype(current, /obj/railway/traffic_control))
				return 1

			var/next_dir = current.get_travel_dir(last_travel_dir)
			if (next_dir)
				var/turf/T = get_step(get_turf(current), next_dir)
				if (T)
					var/obj/railway/NR = locate() in T
					if (NR)
						return traverse_check(NR, next_dir, distance - 1)
			return 1

		may_pass(var/moving_dir)
			if (!..())
				return 0
			var/turf/N = get_step(loc, moving_dir)
			if (N)
				var/obj/railway/R = locate() in N
				var/from_dir = turn(moving_dir, 180)
				if (R && (R.dir1 == from_dir || R.dir2 == from_dir))
					return traverse_check(R, moving_dir, hold_range)
				else
					return 0

		adaptive
			New()
				..()
				adapt()

			adapt(var/ad_adj = 1)
				railway_adapt(src, ad_adj)

	trigger
		name = "rail"

		entering(var/obj/railway_vehicle/V)
			..()
			V.on_trigger()

		adaptive
			New()
				..()
				adapt()

			adapt(var/ad_adj = 1)
				railway_adapt(src, ad_adj)

	ex_act()
		if (indestructible)
			return
		..()

	meteorhit()
		if (indestructible)
			return
		..()

	blob_act()
		if (indestructible)
			return
		..()

	bullet_act()
		if (indestructible)
			return
		return

/obj/railway_vehicle
	var/obj/railway/current = null
	var/moving_dir = 0
	var/active = 1
	var/magically_destructive = 0
	var/free_moving = 0
	var/self_powered = 0
	var/distance = 0
	var/indestructible = 0
	var/default_distance = 10
	var/speed = 2
	var/waited = 0

	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper_0"

	name = "railway vehicle"
	density = 1
	anchored = 1
	var/road_rage_force = 40

	New()
		..()
		railway_vehicles.Add(src)
		if (isturf(loc) && (locate(/obj/railway) in loc))
			start_path(loc)

	Bumped(var/mob/M)
		if (!istype(M) || !isturf(loc))
			return
		if (!current)
			current = locate() in loc
		if (current && free_moving && !moving_dir && active)
			var/bump_dir = get_dir(M, src)
			if (current.dir1 == bump_dir || current.dir2 == bump_dir)
				start_path_towards(loc, bump_dir)

	proc/start_path(var/turf/T, var/last_travel_dir = 0)
		if (!istype(T))
			return
		var/obj/railway/R = locate() in T
		if (R == null)
			return
		var/MD = R.get_travel_dir(last_travel_dir)
		if (MD)
			start_path_towards(T, MD)
			distance = 5 // human force *shrug*

	proc/start_path_towards(var/turf/T, var/towards_dir = 0)
		if (!istype(T))
			return
		if (towards_dir == 0)
			return
		var/obj/railway/R = locate() in T
		if (R == null)
			return
		if (R.dir1 != towards_dir && R.dir2 != towards_dir)
			return
		current = R
		moving_dir = towards_dir
		set_dir(moving_dir)
		set_loc(T)
		current.entering(src)
		distance = default_distance
		on_start_path()
		waited = 0

	proc/process()
		if (!moving_dir || !active)
			return
		if (!current)
			current = locate() in loc
		if (!current)
			return
		if (!current.may_pass(moving_dir))
			return
		waited++
		if (waited < speed)
			return
		waited = 0
		var/turf/next = get_step(loc, moving_dir)
		if (next)
			var/obj/railway/NR = locate() in next
			if (NR)
				if (locate(/obj/railway_vehicle) in next)
					return // defer
				for (var/obj/O in next)
					if (O == src || istype(O, /obj/railway) || !O.density)
						continue
					if (O.anchored && !magically_destructive)
						visible_message("<span class='alert'>[src] bumps against [O].</span>")
						moving_dir = 0
						on_end_path()
						return
				current = NR
				moving_dir = current.get_travel_dir(moving_dir)
				set_dir(moving_dir)
				current.entering(src)
				set_loc(next)
				if (!self_powered)
					distance -= 1
				if (moving_dir == 0 || (!self_powered && distance <= 0))
					moving_dir = 0
					on_end_path()
				return

		moving_dir = 0
		on_end_path()

	set_loc(var/dest)
		var/turf/from_t = loc
		..()
		var/turf/dest_t = dest
		if (from_t == dest_t)
			return
		if (BOUNDS_DIST(from_t, dest_t) > 0)
			return
		if (istype(from_t) && istype(dest_t))
			var/knock_dir = get_dir(from_t, dest_t)
			for (var/mob/living/M in dest_t)
				M.TakeDamageAccountArmor("chest", src.road_rage_force, 0)
				M.visible_message("<span class='alert'><b>[M] was hit by [src]!</b></span>", "<span class='alert'><b>You were hit by [src]!</b></span>")
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
				M.throw_at(get_edge_target_turf(M, knock_dir), 10, 2)
			for (var/obj/O in dest_t)
				if (O == src || istype(O, /obj/railway) || !O.density)
					continue
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
				if (O.anchored && magically_destructive)
					visible_message("<span class='alert'><b>[src] crashes into [O].</b></span>")
					qdel(O)
				else if (!O.anchored)
					visible_message("<span class='alert'><b>[O] was hit by [src]!</b></span>")
					O.throw_at(get_edge_target_turf(O, knock_dir), 10, 2)


	ex_act()
		if (indestructible)
			return
		..()

	meteorhit()
		if (indestructible)
			return
		..()

	blob_act()
		if (indestructible)
			return
		..()

	bullet_act()
		if (indestructible)
			return
		return

	proc/on_start_path()
	proc/on_trigger()
	proc/on_end_path()

	arrival_pod
		indestructible = 1
		magically_destructive = 1
		self_powered = 1
		var/dump_angle = 90

		on_trigger()
			if (contents.len > 0)
				var/dump_dir = turn(dir, dump_angle)
				var/turf/T = get_step(loc, dump_dir)
				for (var/atom/movable/AM in src)
					visible_message("<span class='notice'><b>[src] dumps out [AM].</b></span>")
					AM.set_loc(T)

		on_end_path()
			qdel(src)
