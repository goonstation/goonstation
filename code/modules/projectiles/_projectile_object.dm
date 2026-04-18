/**
 * This file is not good
 * Fucked up var names lie ahead
 * Caution, traveler
 *
 * General cleanup todo:
 * Go through undocumented math and document it
 * Remove bad vars, fill in gaps then created
 * Deduplicate info between this and proj_data
 */

//Leah edit: moderately less bad now, proc/setup still requires a maths degree though

/obj/projectile
	name = "projectile"
	flags = TABLEPASS | UNCRUSHABLE
	layer = EFFECTS_LAYER_BASE
	anchored = ANCHORED
	animate_movement = FALSE
	event_handler_flags = IMMUNE_TRENCH_WARP
	pass_unstable = FALSE

	/// Projectile data; almost all specific projectile information and functionality lives here
	var/datum/projectile/proj_data = null

	/// List of all targets this projectile can go after; useful for homing projectiles and the like
	var/list/targets = list()
	/// Does this projectile pierce armor?
	var/armor_ignored = FALSE
	/// Maximum range this projectile can travel before impacting a (non-dense) turf
	var/max_range = PROJ_INFINITE_RANGE
	/// What kind of implant this projectile leaves in impacted mobs
	var/implanted = null
	/// The mob/thing that fired this projectile
	var/atom/shooter = null
	/// Mob-typed copy of `shooter` var to save time on casts later
	var/mob/mob_shooter = null
	/// Number of tiles this projectile has travelled
	var/travelled = 0
	/// Angle of this shot. For reference @see setup()
	var/angle
	/// Original turf this projectiles was fired from
	var/turf/orig_turf
	/// Degree of spread this projectile was fired with. Note that this informational, and doesn't affect the projectile's trajectory
	var/spread = 0

	///Default dir, set to in do_step()
	var/facing_dir = NORTH
	/// Whether this projectile was shot point-blank style (clicking an adjacent mob). Adjusts the log entry accordingly
	var/was_pointblank = FALSE

	/// Bullshit var for storing special data for niche cases. Sucks, is probably necessary nonetheless
	var/list/special_data = list()

	/// Tracks the number of steps before a piercing projectile is allowed to hit a mob after hitting another one. Scarcely used. TODO remove?
	var/ticks_until_can_hit_mob = 0
	/// Whether this projectile can freely pass through dense turfs
	var/goes_through_walls = FALSE
	/// Whether this projectile can freely pass through mobs
	var/goes_through_mobs = FALSE
	/// List of atoms collided with this tick
	var/list/hitlist = list()
	/// Number of times this projectile has been reflected off of things. Used to cap reflections
	var/reflectcount = 0
	/// For disabling collision when a projectile has died but hasn't been disposed yet, e.g. under on_end effects
	var/has_died = FALSE


	/// x component of the projectile's direction vector. EAST is positive, WEST is negative.
	var/xo
	/// y component of the projectile's direction vector. NORTH is positive, SOUTH is negative.
	var/yo

	/// Offset within a tile, separate to pixel_x/y due to animation things probably?
	var/wx = 0
	var/wy = 0

	/// The list of precalculated turfs this projectile will try to cross, along with the tick count(?) when each turf should be crossed.
	/// The structure of this list is pure Byond demon magic: it's an indexed list of key-value pairs that can be accessed like:
	/// `var/turf/T = crossed[i]` OR `var/value = crossed[T]` where `T` is a turf in the list and `value` is the aforesaid tick count.
	/// a thousand year curse on whoever thought this was a good idea, and Lummox for enabling them.
	var/list/crossing = list()
	/// For precalculated projectiles, how far along the `crossing` list have we reached
	var/curr_t = 0
	/// Whether the projectile is precalculated or not, copied initially from the projectile datum but may change due to gravity shenanigans
	var/precalculated = TRUE

	/// Used to override the speed from the projectile datum so we can have WEIRD and DANGEROUS non-static speeds (see gyrojet)
	/// Only works with non-precalc projectiles obviously.
	var/internal_speed = null

	/// Safety check var to make sure we do some kind of sane "collide and die" behaviour if setup fails due to bad input params (0 speed etc.)
	var/was_setup = 0

	/// X position of the projectile impact, used for particles and bullet impacts
	var/impact_x = null
	/// y position of the projectile impact, used for particles and bullet impacts
	var/impact_y = FALSE

	/// Simulate standard atmos for any mobs inside
	var/has_atmosphere = FALSE

	// ----------------- BADLY DOCUMENTED VARS WHICH ARE NONETHELESS (PROBABLY) USEFUL, OR VARS THAT MAY BE UNNECESSARY BUT THAT IS UNCLEAR --------------------

	/// Reflection normal on the current tile (NORTH if projectile came from the north, etc.)
	/// TODO can maybe be replaced with a single dir check when relevant? not 100% sure why we need to track this always. Might be crucial, dunno
	var/incidence = 0

	/// One of the two below vars needs to be renamed or removed. Fucking confusing

	/// I don't know why this var is here it just stores the result of a proc called on the proj data. TODO revisit
	var/power = 20 // temp var to store what the current power of the projectile should be when it hits something
	/// TODO this var also feels dumb. convert to initial() prolly (on data not on this)
	var/initial_power = 20

	// ------------------- VARS TO BE TAKEN OUT BACK AND SHOT ----------------------------

	/// Yeah this sucks. TODO remove. I don't care bring the bug back so we can actually fix it
	var/is_processing = FALSE //MBC BANDAID FOR BAD BUG : Sometimes Launch() is called twice and spawns two process loops, causing DOUBLEBULLET speed and collision. this fix is bad but i cant figure otu the real issue

	/// Arbitrary projectile data. Currently only used to hold an object that a projectile is seeking for a singular type. TODO remove
	var/data = 0

	/// Number of impassable atoms this projectile can pierce. Decremented on pierce. Can probably be axed in favor of the component. TODO remove
	var/pierces_left = 0

	/// Below stuff but also this is dumb and only used for frost bats and I don't even know why it's used there. TODO remove
	var/collide_with_other_projectiles = 0 //allow us to pass canpass() function to proj_data as well as receive bullet_act events

	/// Target for called shots behavior - by default does not affect projectile behaviour
	var/atom/called_target

	/// Turf of the called_target during projectile initialization
	var/turf/called_target_turf

	disposing()
		special_data = null
		proj_data = null
		targets = null
		hitlist = null
		shooter = null
		data = null
		mob_shooter = null
		..()

	proc/rotateDirection(var/angle)
		var/oldxo = xo
		var/oldyo = yo
		var/sa = sin(angle)
		var/ca = cos(angle)
		xo = ca * oldxo - sa * oldyo
		yo = sa * oldxo + ca * oldyo
		src.Turn(-angle)

	proc/setDirection(x,y, do_turn = 1, angle_override = 0)
		xo = x
		yo = y
		var/matrix/scale_matrix = matrix(src.proj_data.scale, src.proj_data.scale, MATRIX_SCALE)
		if (do_turn)
			//src.transform = null
			src.transform = turn(scale_matrix,(angle_override ? angle_override : arctan(y,x)))
		else if (angle_override)
			src.transform = scale_matrix
			facing_dir = angle2dir(angle_override)

	proc/launch(do_delay = FALSE)
		if (proj_data)
			proj_data.on_launch(src)
		src.setup()
		if(proj_data)
			proj_data.post_setup(src)
		if (!QDELETED(src))
			SPAWN(do_delay ? 0 : -1)
				if (!is_processing)
					process()

	proc/process()
		if(length(hitlist))
			hitlist.len = 0
		is_processing = 1
		while (!QDELETED(src))
			do_step()
			sleep(1 DECI SECOND) //Changed from 1, minor proj. speed buff
		is_processing = 0

	proc/collide(atom/A as mob|obj|turf|area, first = 1)
		if (!A) return // you never know ok??
		if (QDELETED(src)) return // if disposed = true, QDELETED(src) or set for garbage collection and shouldn't process bumps
		if (has_died) return
		if (!proj_data) return // this apparently happens sometimes!! (more than you think!)
		if (proj_data?.on_pre_hit(A, src.angle, src))
			return // Our bullet doesnt want to hit this
		if (A in hitlist)
			return
		else
			hitlist += A
		if (A == shooter) return // never collide with the original shooter
		if (ismob(A)) //don't doublehit
			if (ticks_until_can_hit_mob > 0 || goes_through_mobs)
				return
			if (src.proj_data) //ZeWaka: Fix for null.ticks_between_mob_hits
				ticks_until_can_hit_mob = src.proj_data.ticks_between_mob_hits
		var/turf/T = get_turf(A)
		src.power = src.proj_data.get_power(src, A)
		if(src.power <= 0 && src.proj_data.power != 0) return //we have run out of power
		// Necessary because the check in human.dm is ineffective (Convair880).
		var/immunity = check_target_immunity(A, source = src)
		if (immunity)
			log_shot(src, A, 1)
			var/turf/sanctuary_check = get_turf(A)
			if (sanctuary_check.is_sanctuary())
				die()
			A.visible_message(SPAN_ALERT("<b>The projectile narrowly misses [A]!</b>"))
			//A.visible_message(SPAN_ALERT("<b>The projectile thuds into [A] uselessly!</b>"))
			//die()
			return

		//determine where exactly the bullet hit the atom and spawn particles
		calculate_impact_particles(src, A, ground_hit=FALSE)
		var/sigreturn = SEND_SIGNAL(src, COMSIG_OBJ_PROJ_COLLIDE, A)
		sigreturn |= SEND_SIGNAL(A, COMSIG_ATOM_HITBY_PROJ, src, src.impact_x, src.impact_y)
		if(QDELETED(src)) //maybe a signal proc QDELETED(src) us
			return
		// also run the atom's general bullet act
		var/atom/B = A.bullet_act(src) //If bullet_act returns an atom, do all bad stuff to that atom instead
		if(istype(B))
			A = B

		if (QDELETED(src)) //maybe bullet_act QDELETED(src) us. (MBC : SORRY THIS IS THE THING THAT FIXES REFLECTION RACE CONDITIONS)
			return

		// if we made it this far this is a valid bump, run the specific projectile's hit code
		if (proj_data) //Apparently proj_data can still be missing. HUH.
			proj_data.on_hit(A, angle_to_dir(src.angle), src)

		//Trigger material on attack.
		proj_data?.material?.triggerOnAttack(src, src.shooter, A)

		if (istype(A,/turf))
			// if we hit a turf apparently the bullet is magical and hits every single object in the tile, nice shooting tex
			for (var/obj/O in A)
				O.bullet_act(src)
			T = A
			if ((sigreturn & PROJ_ATOM_CANNOT_PASS) || (!goes_through_walls && !(sigreturn & PROJ_PASSWALL) && !(sigreturn & PROJ_ATOM_PASSTHROUGH)))
				if (proj_data?.hit_object_sound)
					playsound(A, proj_data.hit_object_sound, 60, 0.5)
				die()
		else if (ismob(A))
			if (proj_data?.hit_mob_sound)
				playsound(A.loc, proj_data.hit_mob_sound, 60, 0.5)
			SEND_SIGNAL(A, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)
			SEND_SIGNAL(A, COMSIG_MOB_DISGUISER_DEACTIVATE)
			if (ishuman(A))
				var/mob/living/carbon/human/H = A
				H.stamina_stun()
				if (istype(A, /mob/living/carbon/human/npc/monkey))
					var/mob/living/carbon/human/npc/monkey/M = A
					M.shot_by(shooter)

			if(sigreturn & PROJ_ATOM_PASSTHROUGH || (pierces_left != 0 && first && !(sigreturn & PROJ_ATOM_CANNOT_PASS))) //try to hit other targets on the tile
				for (var/mob/X in T.contents)
					if(!(X in src.hitlist))
						if (!X.Cross(src))
							src.collide(X, first = 0)
					if(QDELETED(src))
						return
			if(!(sigreturn & PROJ_ATOM_PASSTHROUGH))
				if (pierces_left == 0 || (sigreturn & PROJ_ATOM_CANNOT_PASS))
					die()
				else
					pierces_left--

		else if (isobj(A))
			if ((sigreturn & PROJ_ATOM_CANNOT_PASS) || (!goes_through_walls && !(sigreturn & PROJ_PASSOBJ) && !(sigreturn & PROJ_ATOM_PASSTHROUGH)))
				if (iscritter(A))
					if (proj_data?.hit_mob_sound)
						playsound(A.loc, proj_data.hit_mob_sound, 60, 0.5)
				else
					if (proj_data?.hit_object_sound)
						playsound(A.loc, proj_data.hit_object_sound, 60, 0.5)
				die()
			if(first && (sigreturn & PROJ_OBJ_HIT_OTHER_OBJS))
				for (var/obj/X in T.contents)
					if(!(X in src.hitlist))
						if (!X.Cross(src))
							src.collide(X, first = 0)
					if(QDELETED(src))
						return
			else if (src.was_pointblank)
				die()
		else
			die()

	proc/die()
		has_died = TRUE
		if (proj_data)
			proj_data.on_end(src)
		qdel(src)

	proc/set_icon()
		if(istype(proj_data))
			src.icon = proj_data.icon
			src.icon_state = proj_data.icon_state
			src.invisibility = proj_data.invisibility
			if (!proj_data.override_color)
				src.color = proj_data.color_icon
		else
			src.icon = 'icons/obj/projectiles.dmi'
			src.icon_state = null
			src.invisibility = INVIS_NONE
			if (!proj_data) return //ZeWaka: Fix for null.override_color
			if (!proj_data.override_color)
				src.color = "#ffffff"
	proc/get_len()
		return sqrt(src.xo**2 + src.yo**2)
	// Awful var names. TODO rename pretty much everything here, or at least document the functions
	proc/setup()
		if(QDELETED(src))
			return
		if (src.proj_data == null)
			die()
			return
		src.precalculated = src.proj_data.precalculated
		src.pixel_z = src.proj_data.x_offset
		src.pixel_w = src.proj_data.y_offset
		name = src.proj_data.name
		pierces_left = src.proj_data.pierces
		goes_through_walls = src.proj_data.goes_through_walls
		goes_through_mobs = src.proj_data.goes_through_mobs
		set_icon()

		var/len = src.get_len()
		if (len == 0 || proj_data.projectile_speed == 0)
			return //will die on next step before moving

		src.xo = src.xo / len
		src.yo = src.yo / len

		//recalculate the angle from the vector components, taking into account edge case trig weirdness
		if (src.yo == 0)
			if (src.xo < 0)
				src.angle = -90
			else
				src.angle = -270
		else if (src.xo == 0)
			if (src.yo < 0)
				src.angle = 180
			else
				src.angle = 0
		else
			var/r = 1
			src.angle = arccos(src.yo / r)
			var/anglecheck = arcsin(src.xo / r)
			if (anglecheck < 0)
				src.angle = -src.angle

		transform = matrix(src.proj_data.scale, src.proj_data.scale, MATRIX_SCALE)
		Turn(angle)
		if (!src.precalculated)
			src.was_setup = TRUE
			return
		var/speed = internal_speed || proj_data.projectile_speed
		var/x32 = 0
		var/x_sign = 1
		var/y32 = 0
		var/y_sign = 1 //y sign?
		if (xo)
			x32 = 32 / (speed * xo)
			if (x32 < 0)
				x_sign = -1
				x32 = -x32
		if (yo)
			y32 = 32 / (speed * yo)
			if (y32 < 0)
				y_sign = -1
				y32 = -y32
		var/max_t = src.max_range * (32/speed)
		var/next_x = x32 * (16-wx*x_sign)/32
		var/next_y = y32 * (16-wy*y_sign)/32
		var/ct = 0
		var/turf/T = get_turf(src)
		var/cx = T.x
		var/cy = T.y
		//precalculate all the turfs this projectile will cross if able
		while (ct < max_t)
			if (next_x == 0 && next_y == 0)
				break
			if (next_x == 0 || (next_y != 0 && next_y < next_x))
				ct = next_y
				next_y = ct + y32
				cy += y_sign
			else
				ct = next_x
				next_x = ct + x32
				cx += x_sign
			var/turf/Q = locate(cx, cy, T.z)
			if (!Q)
				break
			crossing += Q
			crossing[Q] = ct

		curr_t = 0
		src.was_setup = TRUE

	ex_act(severity)
		return

	bump(var/atom/A)
		src.collide(A)

	Crossed(var/atom/movable/A)
		..()
		if (!A.Cross(src))
			src.collide(A)

		if (collide_with_other_projectiles && A.type == src.type)
			var/obj/projectile/P = A
			if (P.proj_data && src.proj_data && P.proj_data.type != src.proj_data.type) //ignore collisions with me own subtype
				src.collide(A)

	Exited(Obj, newloc)
		. = ..()
		src.proj_data?.on_exited(src, Obj)

	proc/collide_with_applicable_in_tile(var/turf/T)
		var/i = 0
		for(var/thing as mob|obj|turf|area in T)
			var/atom/A = thing
			if (A == src) continue
			if (!A.Cross(src))
				src.collide(A)

			if (collide_with_other_projectiles && A.type == src.type)
				var/obj/projectile/P = A
				if (P.proj_data && src.proj_data && P.proj_data.type != src.proj_data.type) //ignore collisions with me own subtype
					src.collide(A)

			if(i++ >= 50)
				break


	proc/do_step()
		if (!loc || !orig_turf)
			die()
			return
		proj_data.tick(src)
		if(QDELETED(src))
			return

		src.ticks_until_can_hit_mob--

		if(!was_setup) //if setup failed due to us having no speed or no direction, try to collide with something before dying
			collide_with_applicable_in_tile(loc)
			die()
			return

		var/turf/curr_turf = get_turf(src)

		//delta wx, how far in pixels(?) the projectile should move this step
		var/dwx
		var/dwy
		if (!isnull(internal_speed))
			dwx = src.internal_speed * src.xo
			dwy = src.internal_speed * src.yo
			curr_t++
			if (src.proj_data.affected_by_gravity)
				src.travelled += src.internal_speed * (curr_turf ? curr_turf.get_gforce_fractional() : 1)
			else
				src.travelled += src.internal_speed
		else
			dwx = src.proj_data.projectile_speed * src.xo
			dwy = src.proj_data.projectile_speed * src.yo
			curr_t++
			if (src.proj_data.affected_by_gravity)
				src.travelled += src.proj_data.projectile_speed * (curr_turf ? curr_turf.get_gforce_fractional() : 1)
			else
				src.travelled += src.proj_data.projectile_speed

		// The bullet would be expired/decayed.
		if (src.travelled >= src.max_range * 32)
			if (isfloor(curr_turf))
				calculate_impact_particles(src, curr_turf, ground_hit=TRUE)
			proj_data.on_max_range_die(src)
			die()
			return

		if (src.precalculated)
			var/incidence_turf = curr_turf
			//now Move through the crossing turfs until we reach our current position in the list
			for (var/i = 1, i < length(crossing), i++)
				var/turf/T = crossing[i]
				if (crossing[T] < curr_t)
					Move(T)
					if (QDELETED(src)) //we hit something, stop
						return
					src.incidence = get_dir(incidence_turf, T)
					incidence_turf = T
					crossing.Cut(1,2)
					i--
				else
					break
			if (length(crossing) == 1)
				src.precalculated = FALSE


		if (src.precalculated)
			wx += dwx
			wy += dwy
		else
			var/steps = ceil(((!isnull(src.internal_speed)) ? src.internal_speed : src.proj_data.projectile_speed) / 32)
			for (var/i in 1 to steps)
				wx += dwx / steps
				wy += dwy / steps
				var/turf_x = round((wx + 16) / 32)
				var/turf_y = round((wy + 16) / 32)
				//check if we're about to fly out of the world, projectiles don't cross z levels
				if (orig_turf.x + turf_x >= world.maxx-1 || orig_turf.x + turf_x <= 1 || orig_turf.y + turf_y >= world.maxy-1 || orig_turf.y + turf_y <= 1 )
					die()
					return
				var/turf/Dest = locate(orig_turf.x + turf_x, orig_turf.y + turf_y, orig_turf.z)
				if (loc != Dest)

					if (!goes_through_walls)
						Move(Dest)
					else
						set_loc(Dest) //set loc so we can cross walls etc properly
						collide_with_applicable_in_tile(Dest)
					if (QDELETED(src))
						return

					incidence = get_dir(curr_turf, Dest)
					if (!(incidence in cardinal))
						var/txl = wx + 16 % 32
						var/tyl = wy + 16 % 32
						var/ext
						if (xo)
							ext = xo < 0 ? (32 - txl) / -xo : txl / xo
						else
							ext = txl
						var/eyt
						if (eyt)
							eyt = yo < 0 ? (32 - tyl) / -yo : tyl / yo
						else
							eyt = tyl
						if (ext < eyt)
							incidence &= EAST | WEST
						else
							incidence &= NORTH | SOUTH

				if (!loc && !QDELETED(src))
					die()
					return


		set_dir(facing_dir)
		incidence = turn(incidence, 180)
		var/dx = loc.x - orig_turf.x
		var/dy = loc.y - orig_turf.y
		var/pixel_dx = dx * 32
		var/pixel_dy = dy * 32

		if (!dx && !dy) 	//smooth movement within a tile
			animate(src,pixel_x = wx-pixel_dx, pixel_y = wy-pixel_dy, time = 1 DECI SECOND, flags = ANIMATION_END_NOW)
		else
			if ((loc.x - curr_turf.x))
				pixel_x += 32 * -(loc.x - curr_turf.x)
			if ((loc.y - curr_turf.y))
				pixel_y += 32 * -(loc.y - curr_turf.y)

			animate(src,pixel_x = wx-pixel_dx, pixel_y = wy-pixel_dy, time = 1 DECI SECOND, flags = ANIMATION_END_NOW) //todo figure out later

	track_blood()
		src.tracked_blood = null
		return

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume, cannot_be_cooled = FALSE)
		return

	return_air(direct)
		if (src.has_atmosphere)
			var/datum/gas_mixture/GM = new /datum/gas_mixture

			var/oxygen = MOLES_O2STANDARD
			var/nitrogen = MOLES_N2STANDARD
			var/sum = oxygen + nitrogen

			GM.oxygen = (oxygen/sum)
			GM.nitrogen = (nitrogen/sum)
			GM.temperature = T20C

			return GM
		..()

	handle_internal_lifeform(mob/lifeform_inside_me, breath_request, mult)
		if (src.has_atmosphere && breath_request > 0)
			var/datum/gas_mixture/GM = new /datum/gas_mixture

			var/oxygen = MOLES_O2STANDARD
			var/nitrogen = MOLES_N2STANDARD
			var/sum = oxygen + nitrogen

			GM.oxygen = (oxygen/sum)*breath_request * mult
			GM.nitrogen = (nitrogen/sum)*breath_request * mult
			GM.temperature = T20C

			return GM
		..()

	proc/calculate_impact_particles(obj/projectile/shot, atom/hit, ground_hit=FALSE)
		var/datum/projectile/shotdata = shot.proj_data

		// Apply offset based on dir. The side we want to put holes on is opposite the dir of the bullet
		// i.e. left facing bullet hits right side of wall
		var/impact_side_dir = opposite_dir_to(shot.dir) // which edge of this object are we drawing the decals on

		var/impact_target_height = 0 //! how 'high' on the wall we're hitting. in pixels from the outermost border
		var/impact_random_cap = 0 //! how much we can safely move an impact up/down
		var/max_sane_spread = 15 //! the spread value that caps how crazy the impact pattern is
		var/impact_normal = 0 //! the way 'outwards' from the wall
		switch(impact_side_dir)
			if(WEST)
				impact_target_height = 6
				impact_random_cap = 5
				impact_normal = 180
			if (EAST)
				impact_target_height = 6
				impact_random_cap = 5
				impact_normal = 0
			if (NORTH)
				impact_target_height = 4
				impact_random_cap = 3
				impact_normal = 90
			if (SOUTH)
				impact_target_height = 11
				impact_random_cap = 8 // front face has a lot of room for impacts
				impact_normal = 270

		var/spread_peak = sqrt(shot.spread/max_sane_spread) * impact_random_cap
		// as covered earlier - this is how 'high' up the wall the bullet hits. as if you were aiming for head/body shots.
		var/impact_final_height = impact_target_height + rand(-spread_peak, spread_peak)

		var/turf/parent_turf = get_turf(hit)
		//distance from centre of wall to bullet's location
		var/x_distance = (shot.orig_turf.x*32 + shot.wx) - parent_turf.x*32
		var/y_distance = (shot.orig_turf.y*32 + shot.wy) - parent_turf.y*32

		var/shot_angle = arctan(shot.xo, shot.yo)
		//distance from chosen 'height' of wall, to bullet location.
		var/distance = (x_distance * cos(impact_normal))+(y_distance*sin(impact_normal)) - (16-impact_final_height)
		//final offsets for the impact decal
		var/impact_offset_x = (cos(shot_angle)  * distance)
		var/impact_offset_y = (sin(shot_angle)  * distance)

		// Add the offsets to the impact's position. abs(sin(impact_normal)) strips the y component of the offset if we're hitting a horizontal wall, and vice versa for cos
		var/new_x = (impact_offset_x + x_distance)*abs(sin(impact_normal)) + (16-impact_final_height)*cos(impact_normal)
		var/new_y = (impact_offset_y + y_distance)*abs(cos(impact_normal)) + (16-impact_final_height)*sin(impact_normal)

		shotdata.spawn_impact_particles(hit, shot, new_x, new_y, ground_hit)
		src.impact_x = new_x
		src.impact_y = new_y
		return
