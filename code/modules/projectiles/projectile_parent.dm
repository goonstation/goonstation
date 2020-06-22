/proc/roundTZ(var/i)
	if (i < 0)
		return -round(-i)
	return round(i)

/obj/projectile
	name = "projectile"
	flags = TABLEPASS
	layer = EFFECTS_LAYER_BASE

	var/xo
	var/yo

	// I have no idea what to do with these.
	var/target = null
	var/datum/projectile/proj_data = null
	//var/obj/o_shooter = null
	var/list/targets = list()
	var/dissipation_ticker = 0 // moved this from the datum because why the hell was it on there
	var/power = 20 // local copy of power for proper dissipation tracking
	var/implanted = null
	var/forensic_ID = null
	var/atom/shooter = null // Who/what fired this?
	var/mob/mob_shooter = null
	// We use shooter to avoid self collision, however, the shot may have been initiated through a proxy object. This is for logging.
	var/travelled = 0 // track distance
	var/angle // for reference @see setup()
	animate_movement = 0
	var/turf/orig_turf

	var/facing_dir = 1 //default dir we set to in do_step()

	var/data = 0
	var/was_pointblank = 0 // Adjusts the log entry accordingly.

	var/was_setup = 0
	var/far_border_hit

	var/incidence = 0 // reflection normal on the current tile (NORTH if projectile came from the north, etc.)
	var/list/crossing = list()
	var/list/special_data = list()
	var/curr_t = 0

	var/wx = 0
	var/wy = 0

	var/internal_speed = null // experimental
	var/pierces_left = 0
	var/ticks_until_can_hit_mob = 0
	var/goes_through_walls = 0
	var/goes_through_mobs = 0
	var/collide_with_other_projectiles = 0 //allow us to pass canpass() function to proj_data as well as receive bullet_act events
	var/list/hitlist = list() //list of atoms collided with this tick
	var/reflectcount = 0
	var/is_processing = 0//MBC BANDAID FOR BAD BUG : Sometimes Launch() is called twice and spawns two process loops, causing DOUBLEBULLET speed and collision. this fix is bad but i cant figure otu the real issue
#if ASS_JAM
	var/projectile_paused = FALSE //for time stopping
#endif
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
		if (do_turn)
			//src.transform = null
			src.transform = turn(matrix(),(angle_override ? angle_override : arctan(y,x)))
		else if (angle_override)
			src.transform = null
			facing_dir = angle2dir(angle_override)

	proc/launch()
		if (proj_data)
			proj_data.on_launch(src)
		src.setup()
		if (!disposed && !pooled && !qdeled)
			SPAWN_DBG(-1)
				if (!is_processing)
					process()

	proc/process()
		if(hitlist.len)
			hitlist.len = 0
		is_processing = 1
		while (!disposed)
#if ASS_JAM //dont move while in timestop
			while(src.projectile_paused)
				sleep(1 SECOND)
#endif
			do_step()
			sleep(0.75) //Changed from 1, minor proj. speed buff
		is_processing = 0

	proc/get_power(obj/O)
		return src.proj_data.power - max(0,((isnull(src.orig_turf)? 0 : get_dist(src.orig_turf, get_turf(O)))-src.proj_data.dissipation_delay))*src.proj_data.dissipation_rate

	proc/collide(atom/A as mob|obj|turf|area)
		if (!A) return // you never know ok??
		if (disposed || pooled) return // if disposed = true, pooled or set for garbage collection and shouldn't process bumps
		if (!proj_data) return // this apparently happens sometimes!! (more than you think!)
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
		src.power = src.get_power(A)
		if(src.power <= 0 && src.proj_data.power != 0) return //we have run out of power
		// Necessary because the check in human.dm is ineffective (Convair880).
		var/immunity = check_target_immunity(A, source = src)
		if (immunity)
			log_shot(src, A, 1)
			A.visible_message("<b><span class='alert'>The projectile narrowly misses [A]!</span></b>")
			//A.visible_message("<b><span class='alert'>The projectile thuds into [A] uselessly!</span></b>")
			//die()
			return

		var/sigreturn = SEND_SIGNAL(src, COMSIG_PROJ_COLLIDE, A)
		// also run the atom's general bullet act
		var/atom/B = A.bullet_act(src) //If bullet_act returns an atom, do all bad stuff to that atom instead
		if(istype(B))
			A = B

		if (pooled) //maybe bullet_act pooled us. (MBC : SORRY THIS IS THE THING THAT FIXES REFLECTION RACE CONDITIONS)
			return

		// if we made it this far this is a valid bump, run the specific projectile's hit code
		if (proj_data) //Apparently proj_data can still be missing. HUH.
			proj_data.on_hit(A, angle_to_dir(src.angle), src)

		//Trigger material on attack.
		if(proj_data && proj_data.material) //ZeWaka: Fix for null.material
			proj_data.material.triggerOnAttack(src, src.shooter, A)

		if (istype(A,/turf))
			// if we hit a turf apparently the bullet is magical and hits every single object in the tile, nice shooting tex
			for (var/obj/O in A)
				O.bullet_act(src)
			var/turf/T = A
			if (T.density && !goes_through_walls && !(sigreturn & PROJ_PASSWALL))
				if (proj_data && proj_data.icon_turf_hit && istype(A, /turf/simulated/wall))
					var/turf/simulated/wall/W = A
					if (src.forensic_ID)
						W.forensic_impacts += src.forensic_ID

					if (W.proj_impacts.len <= 10)
						var/image/impact = image('icons/obj/projectiles.dmi', proj_data.icon_turf_hit)
						impact.transform = turn(impact.transform, pick(0, 90, 180, 270))
						impact.pixel_x += rand(-12,12)
						impact.pixel_y += rand(-12,12)
						W.proj_impacts += impact
						W.update_projectile_image(ticker.round_elapsed_ticks)
				if (proj_data && proj_data.hit_object_sound)
					playsound(A, proj_data.hit_object_sound, 60, 0.5)
				die()
		else if (ismob(A))
			if(pierces_left != 0) //try to hit other targets on the tile
				var/turf/T = get_turf(A)
				for (var/mob/X in T.contents)
					if (X != A)
						X.bullet_act(src)
						pierces_left--
						//holy duplicate code batman. If someone can come up with a better solution, be my guest
						if (src.proj_data) //ZeWaka: Fix for null.ticks_between_mob_hits
							if (proj_data.hit_mob_sound)
								playsound(X.loc, proj_data.hit_mob_sound, 60, 0.5)
							proj_data.on_hit(X, angle_to_dir(src.angle), src)
						for (var/obj/item/cloaking_device/S in X.contents)
							if (S.active)
								S.deactivate(X)
								src.visible_message("<span class='notice'><b>[X]'s cloak is disrupted!</b></span>")
						for (var/obj/item/device/disguiser/D in A.contents)
							if (D.on)
								D.disrupt(X)
								src.visible_message("<span class='notice'><b>[X]'s disguiser is disrupted!</b></span>")
						if (isliving(X))
							var/mob/living/H = X
							H.stamina_stun()
							if (istype(X, /mob/living/carbon/human/npc/monkey))
								var/mob/living/carbon/human/npc/monkey/M = X
								M.shot_by(shooter)

					if(pierces_left == 0)
						break
			if (src.proj_data) //ZeWaka: Fix for null.ticks_between_mob_hits
				if (proj_data.hit_mob_sound)
					playsound(A.loc, proj_data.hit_mob_sound, 60, 0.5)
			for (var/obj/item/cloaking_device/S in A.contents)
				if (S.active)
					S.deactivate(A)
					src.visible_message("<span class='notice'><b>[A]'s cloak is disrupted!</b></span>")
			for (var/obj/item/device/disguiser/D in A.contents)
				if (D.on)
					D.disrupt(A)
					src.visible_message("<span class='notice'><b>[A]'s disguiser is disrupted!</b></span>")
			if (ishuman(A))
				var/mob/living/carbon/human/H = A
				H.stamina_stun()
				if (istype(A, /mob/living/carbon/human/npc/monkey))
					var/mob/living/carbon/human/npc/monkey/M = A
					M.shot_by(shooter)

			if (pierces_left == 0)
				die()
			else
				pierces_left--

		else if (isobj(A))
			if (A.density && !goes_through_walls && !(sigreturn & PROJ_PASSOBJ))
				if (iscritter(A))
					if (proj_data && proj_data.hit_mob_sound)
						playsound(A.loc, proj_data.hit_mob_sound, 60, 0.5)
				else
					if (proj_data && proj_data.hit_object_sound)
						playsound(A.loc, proj_data.hit_object_sound, 60, 0.5)
				die()
		else
			die()

	pooled()
		name = "projectile"
		src.remove_simple_light()
		xo = 0
		yo = 0
		pixel_x = 0
		pixel_y = 0
		power = 0
		dissipation_ticker = 0
		travelled = 0
		target = null
		proj_data = null
		//o_shooter = null
		shooter = null
		mob_shooter = null
		implanted = null
		forensic_ID = null
		targets = null
		angle = 0
		was_setup = 0
		was_pointblank = 0
		data = 0
		crossing.len = 0
		curr_t = 0
		wx = 0
		wy = 0
		color = null
		incidence = 0
		special_data.len = 0
		overlays = null
		hitlist.len = 0
		transform = null
		internal_speed = null
		orig_turf = null
		pierces_left = 0
		goes_through_walls = 0
		goes_through_mobs = 0
		ticks_until_can_hit_mob = 0
		removeMaterial()
		collide_with_other_projectiles = 0
		is_processing = 0
		facing_dir = 1
		reflectcount = 0
		..()

	//just in fuck in case
	unpooled()
		//mbc hacky fix that prob doesnt work for shitty bug where unpooled projs get unpooled -- its even worse now :)
		special_data.len = 0
		for (var/atom/movable/A in src.contents)
			A.set_loc(src.loc)

		..()

	proc/die()
		if (proj_data)
			proj_data.on_end(src)
		pool(src)

	proc/max_range_fail()


	proc/set_icon()
		if(istype(proj_data))
			src.icon = proj_data.icon
			src.icon_state = proj_data.icon_state
			if (!proj_data.override_color)
				src.color = proj_data.color_icon
		else
			src.icon = 'icons/obj/projectiles.dmi'
			src.icon_state = null
			if (!proj_data) return //ZeWaka: Fix for null.override_color
			if (!proj_data.override_color)
				src.color = "#ffffff"

	proc/setup()
		if (src.proj_data == null || (xo == 0 && yo == 0) || proj_data.projectile_speed == 0)
			die()
			return

		name = src.proj_data.name
		pierces_left = src.proj_data.pierces
		goes_through_walls = src.proj_data.goes_through_walls
		goes_through_mobs = src.proj_data.goes_through_mobs
		set_icon()

		var/len = sqrt(src.xo * src.xo + src.yo * src.yo)

		if (len == 0)
			die()
		src.xo = src.xo / len
		src.yo = src.yo / len

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
		transform = null
		Turn(angle)
		if (!proj_data.precalculated)
			return

		var/x32 = 0
		var/xs = 1
		var/y32 = 0
		var/ys = 1
		if (xo)
			if (!isnull(internal_speed))
				x32 = 32 / (internal_speed * xo)
			else
				x32 = 32 / (proj_data.projectile_speed * xo)
			if (x32 < 0)
				xs = -1
				x32 = -x32
		if (yo)
			if (!isnull(internal_speed))
				y32 = 32 / (internal_speed * yo)
			else
				y32 = 32 / (proj_data.projectile_speed * yo)
			if (y32 < 0)
				ys = -1
				y32 = -y32
		var/max_t
		if (proj_data.dissipation_rate && proj_data.max_range == 500) //500 is default maximum range
			proj_data.max_range = proj_data.dissipation_delay + round(proj_data.power / proj_data.dissipation_rate)
		max_t = proj_data.max_range // why not
		var/next_x = x32 / 2
		var/next_y = y32 / 2
		var/ct = 0
		var/turf/T = get_turf(src)
		var/cx = T.x
		var/cy = T.y
		while (ct < max_t)
			if (next_x == 0 && next_y == 0)
				break
			if (next_x == 0 || (next_y != 0 && next_y < next_x))
				ct = next_y
				next_y = ct + y32
				cy += ys
			else
				ct = next_x
				next_x = ct + x32
				cx += xs
			var/turf/Q = locate(cx, cy, T.z)
			if (!Q)
				break
			crossing += Q
			crossing[Q] = ct

		curr_t = 0
		src.was_setup = 1

	Bump(var/atom/A)
		src.collide(A)

	Crossed(var/atom/movable/A)
		if (!istype(A))
			return // can't happen will happen
		if (!A.CanPass(src, get_step(src, A.dir), 1, 0))
			src.collide(A)

		if (collide_with_other_projectiles && A.type == src.type)
			var/obj/projectile/P = A
			if (P.proj_data && src.proj_data && P.proj_data.type != src.proj_data.type) //ignore collisions with me own subtype
				src.collide(A)

	proc/collide_with_applicable_in_tile(var/turf/T)
		var/i = 0
		for(var/thing as mob|obj|turf|area in T)
			var/atom/A = thing
			if (A == src) continue
			if (!A.CanPass(src, get_step(src, A.dir), 1, 0))
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
		src.ticks_until_can_hit_mob--
		src.dissipation_ticker++

		// The bullet has expired/decayed.
		if (src.dissipation_ticker > src.proj_data.max_range)
			proj_data.on_max_range_die(src)
			die()
			return
		proj_data.tick(src)
		if (disposed)
			return

		var/turf/curr_turf = loc

		var/dwx
		var/dwy
		if (!isnull(internal_speed))
			dwx = src.internal_speed * src.xo
			dwy = src.internal_speed * src.yo
			curr_t++
			src.travelled += src.internal_speed
		else
			dwx = src.proj_data.projectile_speed * src.xo
			dwy = src.proj_data.projectile_speed * src.yo
			curr_t++
			src.travelled += src.proj_data.projectile_speed

		if (proj_data.precalculated)
			for (var/i = 1, i < crossing.len, i++)
				var/turf/T = crossing[i]
				if (crossing[T] < curr_t)
					Move(T)
					if (disposed)
						return
					incidence = get_dir(curr_turf, T)
					curr_turf = T
					crossing.Cut(1,2)
					i--
				else
					break

		wx += dwx
		wy += dwy
		if (!proj_data.precalculated)
			var/trfx = round((wx + 16) / 32)
			var/trfy = round((wy + 16) / 32)
			if (orig_turf.x + trfx >= world.maxx-1 || orig_turf.x + trfx <= 1 || orig_turf.y + trfy >= world.maxy-1 || orig_turf.y + trfy <= 1 )
				die()
				return
			var/turf/Dest = locate(orig_turf.x + trfx, orig_turf.y + trfy, orig_turf.z)
			if (loc != Dest)

				if (!goes_through_walls)
					Move(Dest)
				else
					set_loc(Dest) //set loc so we can cross walls etc properly
					collide_with_applicable_in_tile(Dest)

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

			if (!loc)
				die()
				return

		dir = facing_dir
		incidence = turn(incidence, 180)

		var/dx = loc.x - orig_turf.x
		var/dy = loc.y - orig_turf.y
		var/dpx = dx * 32
		var/dpy = dy * 32

		if (!dx && !dy) 	//smooth movement within a tile
			animate(src,pixel_x = wx-dpx, pixel_y = wy-dpy, time = 0.75, flags = ANIMATION_END_NOW)
		else
			if (dx && dy) 	//diagonals are too fucky and i cant figure out why yet :(
				pixel_x = wx - dpx
				pixel_y = wy - dpy
			else			//smooth movement cross-tile
				if ((loc.x - curr_turf.x))
					pixel_x += 32 * -(loc.x - curr_turf.x)
				if ((loc.y - curr_turf.y))
					pixel_y += 32 * -(loc.y - curr_turf.y)

				animate(src,pixel_x = wx-dpx, pixel_y = wy-dpy, time = 0.75, flags = ANIMATION_END_NOW) //todo figure out later

	track_blood()
		src.tracked_blood = null
		return

ABSTRACT_TYPE(/datum/projectile)
datum/projectile
	// These vars were copied from the an projectile datum. I am not sure which version, probably not 4407.
	var
		name = "projectile"
		icon = 'icons/obj/projectiles.dmi'
		icon_state = "bullet"	// A special note: the icon state, if not a point-symmetric sprite, should face NORTH by default.
		icon_turf_hit = null // what kinda overlay they puke onto turfs when they hit
		brightness = 0
		color_red = 0
		color_green = 0
		color_blue = 0
		color_icon = "#ffffff"
		override_color = 0
		power = 20               // How much of a punch this has
		cost = 1                 // How much ammo this costs
		max_range = 500          // How many ticks can this projectile go for if not stopped, if it doesn't die from falloff
		dissipation_rate = 2     // How fast the power goes away
		dissipation_delay = 10   // How many tiles till it starts to lose power - not exactly tiles, because falloff works on ticks, and doesn't seem to quite match 1-1 to tiles.
		                         // When firing in a straight line, I was getting doubled falloff values on the fourth tile from the shooter, as well as others further along. -Tarm
		dissipation_ticker = 0   // Tracks how many tiles we moved
		ks_ratio = 1.0           /* Kill/Stun ratio, when it hits a mob the damage/stun is based upon this and the power
		                            eg 1.0 will cause damage = to power while 0.0 would cause just stun = to power */

		sname = "stun"           // name of the projectile setting, used when you change a guns setting
		shot_sound = 'sound/weapons/Taser.ogg' // file location for the sound you want it to play
		shot_volume = 100		 // How loud the sound plays (thank you mining drills for making this a needed thing)
		shot_number = 0          // How many projectiles should be fired, each will cost the full cost
		shot_delay = 1          // Time between shots in a burst.
		damage_type = D_KINETIC  // What is our damage type
		hit_type = null          // For blood system damage - DAMAGE_BLUNT, DAMAGE_CUT and DAMAGE_STAB
		hit_ground_chance = 0    // With what % do we hit mobs laying down
		window_pass = 0          // Can we pass windows
		obj/projectile/master = null
		silentshot = 0           // standard visible message upon bullet_act. if 2, hide even the 'armor hit' message!
		implanted                // Path of "bullet" left behind in the mob on successful hit
		disruption = 0           // planned thing to deal with pod electronics / etc
		zone = null              // todo: if fired from a handheld gun, check the targeted zone --- this should be in the goddamn obj
		caliber = null
		nomsg = 0

		datum/material/material = null

		casing = null
		reagent_payload = null
		forensic_ID = null
		precalculated = 1

		hit_object_sound = 0
		hit_mob_sound = 0

	// Determines the amount of length units the projectile travels each tick
	// A tile is 32 wide, 32 long, and 32 * sqrt(2) across.
	// Setting this to 32 will mimic the old behaviour for shots travelling in one of the cardinal directions.
	var/projectile_speed = 28

	// Determines the impact range of the projectile. Should ideally be half the length of the sprite
	// for line-based stuff (lasers), or the radius for circular projectiles.
	// If the projectile is irregular (like, a square), try to use the radius of a circle that touches the farthest point
	// of the edge of a shape in a cardinal direction from the center of symmetry (eg. half the edge length for a square)
	// This is mostly aesthetic, so the player feels like they are actually hit when the projectile reaches them, not
	// earlier or later.
	// For very high speed projectiles, this may be much lower than the suggested amounts.
	// If 0, no forward checking is done at all. May be useful for stuff like revolver shots, where the bullets are literally
	// a pixel wide.
	var/impact_range = 8

	// Self-explanatory.
	var/hits_ghosts = 0
	var/goes_through_walls = 0
	var/goes_through_mobs = 0
	var/pierces = 0
	var/ticks_between_mob_hits = 0
	// var/type = "K"					//3 types, K = Kinetic, E = Energy, T = Taser


	proc
		impact_image_effect(var/type, atom/hit, angle, var/obj/projectile/O)		//3 types, K = Kinetic, E = Energy, T = Taser
			var/obj/itemspecialeffect/impact/E = null
			//this way is probably fastest.
			switch (type)
				if ("K")
					if (iscarbon(hit))
						E = unpool(/obj/itemspecialeffect/impact/blood)
					else if (issilicon(hit))
						E = unpool(/obj/itemspecialeffect/impact/silicon)
				if ("E")
					if (iscarbon(hit))
						E = unpool(/obj/itemspecialeffect/impact/energy)
				if ("T")
					if (iscarbon(hit))
						E = unpool(/obj/itemspecialeffect/impact/taser)

			if (E)
				E.setup(hit.loc)

		hit_ground()
			return prob(hit_ground_chance)
		//For future use, ie guns that can change the power settings
		set_power()
			return
		//When it hits a mob or such should anything special happen
		on_hit(atom/hit, angle, var/obj/projectile/O) //MBC : what the fuck shouldn't this all be in bullet_act on human in damage.dm?? this split is giving me bad vibes
			if(ks_ratio == 0) //stun projectiles only
				impact_image_effect("T", hit)
//				if (isliving(hit))
//					var/mob/living/L = hit
//					stun_bullet_hit(O,L)
			return
		tick(var/obj/projectile/O)
			return
		on_launch(var/obj/projectile/O)
			return
		on_pointblank(var/obj/projectile/O, var/mob/target)
			return
		on_end(var/obj/projectile/O)
			return
		on_max_range_die(var/obj/projectile/O)
			return

		on_canpass(var/obj/projectile/O, atom/movable/passing_thing)
			.= 1

// WOO IMPACT RANGES
// Meticulously calculated by hand.

datum/projectile/laser
	impact_range = 16

	on_hit(atom/hit, angle, var/obj/projectile/O)
		..()
		impact_image_effect("E", hit)

datum/projectile/laser/pred
	impact_range = 2

datum/projectile/laser/light
	impact_range = 2

datum/projectile/laser/glitter
	impact_range = 4

datum/projectile/laser/precursor
	impact_range = 4

datum/projectile/laser/precursor/sphere
	impact_range = 16

datum/projectile/laser/mining
	impact_range = 12

datum/projectile/laser/eyebeams
	impact_range = 4

datum/projectile/laser/drill
	impact_range = 0

datum/projectile/laser/drill/cutter
	impact_range = 0

datum/projectile/fourtymm
	impact_range = 12

datum/projectile/bfg
	impact_range = 16

datum/projectile/bullet
	impact_range = 0
	on_hit(atom/hit, angle, var/obj/projectile/O)
		..()
		impact_image_effect("K", hit)

datum/projectile/bullet/autocannon
	impact_range = 2

datum/projectile/bullet/autocannon/plasma_orb
	impact_range = 8

datum/projectile/bullet/autocannon/huge
	impact_range = 8

datum/projectile/bullet/glitch
	impact_range = 4

// for the gun, not the drone
datum/projectile/bullet/glitch/gun
	impact_range = 16

datum/projectile/bullet/frog/getin
	impact_range = 5

datum/projectile/bullet/frog/getout
	impact_range = 5

datum/projectile/bullet/rod
	impact_range = 16

datum/projectile/bullet/flare/ufo
	impact_range = 8

datum/projectile/owl
	impact_range = 16

datum/projectile/disruptor
	impact_range = 4
	on_hit(atom/hit, angle, var/obj/projectile/O)
		..()
		impact_image_effect("E", hit)

datum/projectile/disruptor/high
	impact_range = 4

datum/projectile/energy_bolt
	impact_range = 4

datum/projectile/energy_bolt_v
	impact_range = 4

datum/projectile/energy_bolt_antighost
	impact_range = 16
	hits_ghosts = 1 // do it.

datum/projectile/rad_bolt
	impact_range = 0

datum/projectile/tele_bolt
	impact_range = 4

datum/projectile/wavegun
	impact_range = 4

datum/projectile/snowball
	impact_range = 4

// THIS IS INTENDED FOR POINTBLANKING.
/proc/hit_with_projectile(var/S, var/datum/projectile/DATA, var/atom/T)
	if (!S || !T)
		return
	var/times = max(1, DATA.shot_number)
	for (var/i = 1, i <= times, i++)
		var/obj/projectile/P = initialize_projectile_ST(S, DATA, T)
		if (S == T)
			P.shooter = null
			P.mob_shooter = S
		hit_with_existing_projectile(P, T)

/proc/hit_with_existing_projectile(var/obj/projectile/P, var/atom/T)
	if (!P || !T)
		return
	if (ismob(T))
		var/immunity = check_target_immunity(T) // Point-blank overrides, such as stun bullets (Convair880).
		if (immunity)
			log_shot(P, T, 1)
			T.visible_message("<b><span class='alert'>...but the projectile bounces off uselessly!</span></b>")
			P.die()
			return
		if (P.proj_data)
			P.proj_data.on_pointblank(P, T)
	P.collide(T) // The other immunity check is in there (Convair880).

/proc/shoot_projectile_ST(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/atom/movable/remote_sound_source)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return null
	var/obj/projectile/Q = shoot_projectile_relay(S, DATA, T, remote_sound_source)
	if (DATA.shot_number > 1)
		SPAWN_DBG(-1)
			for (var/i = 2, i < DATA.shot_number, i++)
				sleep(DATA.shot_delay)
				shoot_projectile_relay(S, DATA, T, remote_sound_source)
	return Q

/proc/shoot_projectile_ST_pixel(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return null
	var/obj/projectile/Q = shoot_projectile_relay_pixel(S, DATA, T, pox, poy)
	if (DATA.shot_number > 1)
		SPAWN_DBG(-1)
			for (var/i = 2, i <= DATA.shot_number, i++)
				sleep(DATA.shot_delay)
				shoot_projectile_relay_pixel(S, DATA, T, pox, poy)
	return Q

/proc/shoot_projectile_ST_pixel_spread(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy, var/spread_angle)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return null
	var/obj/projectile/Q = shoot_projectile_relay_pixel_spread(S, DATA, T, pox, poy, spread_angle)
	if (DATA.shot_number > 1)
		SPAWN_DBG(-1)
			for (var/i = 2, i <= DATA.shot_number, i++)
				sleep(DATA.shot_delay)
				shoot_projectile_relay_pixel_spread(S, DATA, T, pox, poy, spread_angle)
	return Q

/proc/shoot_projectile_DIR(var/atom/movable/S, var/datum/projectile/DATA, var/dir, var/atom/movable/remote_sound_source)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return null
	var/turf/T = get_step(get_turf(S), dir)
	if (T)
		return shoot_projectile_ST(S, DATA, T, remote_sound_source)
	return null

/proc/shoot_projectile_relay(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/atom/movable/remote_sound_source)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/obj/projectile/P = initialize_projectile_ST(S, DATA, T, remote_sound_source)
	if (P)
		P.launch()
	return P

/proc/shoot_projectile_relay_pixel(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/obj/projectile/P = initialize_projectile_pixel(S, DATA, T, pox, poy)
	if (P)
		P.launch()
	return P

/proc/shoot_projectile_relay_pixel_spread(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy, var/spread_angle)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/obj/projectile/P = initialize_projectile_pixel_spread(S, DATA, T, pox, poy, spread_angle)
	if (P)
		P.launch()
	return P

/proc/shoot_projectile_XY(var/atom/movable/S, var/datum/projectile/DATA, var/xo, var/yo)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/obj/projectile/Q = shoot_projectile_XY_relay(S, DATA, xo, yo)
	if (DATA.shot_number > 1)
		SPAWN_DBG(-1)
			for (var/i = 2, i <= DATA.shot_number, i++)
				sleep(DATA.shot_delay)
				shoot_projectile_XY_relay(S, DATA, xo, yo)
	return Q

/proc/shoot_projectile_XY_relay(var/atom/movable/S, var/datum/projectile/DATA, var/xo, var/yo)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/obj/projectile/P = initialize_projectile(get_turf(S), DATA, xo, yo, S)
	if (P)
		P.launch()
	return P

/proc/initialize_projectile_ST(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/atom/movable/remote_sound_source)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/turf/Q1 = get_turf(S)
	var/turf/Q2 = get_turf(T)
	return initialize_projectile(Q1, DATA, Q2.x - Q1.x, Q2.y - Q1.y, S, remote_sound_source)

/proc/initialize_projectile_pixel(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/turf/Q1 = get_turf(S)
	var/turf/Q2 = get_turf(T)
	return initialize_projectile(Q1, DATA, (Q2.x - Q1.x) * 32 + pox, (Q2.y - Q1.y) * 32 + poy, S)

/proc/initialize_projectile_pixel_spread(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy, var/spread_angle)
	var/obj/projectile/P = initialize_projectile_pixel(S, DATA, T, pox, poy)
	if (P && spread_angle)
		if (spread_angle < 0)
			spread_angle = -spread_angle
		var/spread = rand(spread_angle * 10) / 10
		P.rotateDirection(prob(50) ? spread : -spread)
	return P

/proc/initialize_projectile(var/turf/S, var/datum/projectile/DATA, var/xo, var/yo, var/shooter = null, var/turf/remote_sound_source)
	if (!S)
		return
	var/obj/projectile/P = unpool(/obj/projectile)
	if(!P)
		return

	P.set_loc(S)
	P.proj_data = DATA
	P.set_icon()
	P.shooter = shooter
	P.name = DATA.name
	P.setMaterial(DATA.material)
	P.power = DATA.power
	P.orig_turf = S

	if (DATA.implanted)
		P.implanted = DATA.implanted

	if(remote_sound_source)
		shooter = remote_sound_source

	if (narrator_mode)
		playsound(S, 'sound/vox/shoot.ogg', 50, 1)
	else if(DATA.shot_sound && DATA.shot_volume && shooter)
		playsound(S, DATA.shot_sound, DATA.shot_volume, 1)
		if (isobj(shooter))
			for (var/mob/M in shooter)
				M << sound(DATA.shot_sound, volume=DATA.shot_volume)

#ifdef DATALOGGER
	if (game_stats && istype(game_stats))
		game_stats.Increment("gunfire")
#endif
	if (DATA.brightness)
		P.add_simple_light("proj", list(DATA.color_red*255, DATA.color_green*255, DATA.color_blue*255, DATA.brightness * 255))

	P.xo = xo
	P.yo = yo
	return P

/proc/stun_bullet_hit(var/obj/projectile/O, var/mob/living/L)
	L.do_disorient(clamp(O.power*4, O.proj_data.power*2, O.power+80), weakened = O.power*2, stunned = O.power*2, disorient = min(O.power, 80), remove_stamina_below_zero = 0)
	L.emote("twitch_v")// for the above, flooring stam based off the power of the datum is intentional


/proc/shoot_reflected_to_sender(var/obj/projectile/P, var/obj/reflector, var/max_reflects = 3)
	if(P.reflectcount >= max_reflects)
		return
	var/obj/projectile/Q = initialize_projectile(get_turf(reflector), P.proj_data, -P.xo, -P.yo, reflector)
	if (!Q)
		return null
	Q.reflectcount = P.reflectcount + 1
	if (ismob(P.shooter))
		Q.mob_shooter = P.shooter
	Q.name = "reflected [Q.name]"
	Q.launch()
	return Q

/proc/shoot_reflected_true(var/obj/projectile/P, var/obj/reflector, var/max_reflects = 3)
	if (!P.incidence || !(P.incidence in cardinal))
		return null
	if(P.reflectcount >= max_reflects)
		return

	var/rx = 0
	var/ry = 0

	var/nx = P.incidence == WEST ? -1 : (P.incidence == EAST ?  1 : 0)
	var/ny = P.incidence == SOUTH ? -1 : (P.incidence == NORTH ?  1 : 0)

	var/dn = 2 * (P.xo * nx + P.yo * ny) // incident direction DOT normal * 2
	rx = P.xo - dn * nx // r = d - 2 * (d * n) * n
	ry = P.yo - dn * ny

	if (rx == ry && rx == 0)
		logTheThing("debug", null, null, "<b>Marquesas/Reflecting Projectiles</b>: Reflection failed for [P.name] (incidence: [P.incidence], direction: [P.xo];[P.yo]).")
		return null // unknown error

	var/obj/projectile/Q = initialize_projectile(get_turf(reflector), P.proj_data, rx, ry, reflector)
	if (!Q)
		return null
	Q.reflectcount = P.reflectcount + 1
	if (ismob(P.shooter))
		Q.mob_shooter = P.shooter
	Q.name = "reflected [Q.name]"
	Q.launch()
	return Q
