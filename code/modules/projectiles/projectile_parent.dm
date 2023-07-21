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

/obj/projectile
	name = "projectile"
	flags = TABLEPASS | UNCRUSHABLE
	layer = EFFECTS_LAYER_BASE
	anchored = ANCHORED
	animate_movement = FALSE

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
	/// Forensic ID of the gun, etc that shot this projectile, used for forensics on implanted projectiles
	var/forensic_ID = null
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

	///Default dir, set to in do_step()
	var/facing_dir = 1
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

	// ----------------- BADLY DOCUMENTED VARS WHICH ARE NONETHELESS (PROBABLY) USEFUL, OR VARS THAT MAY BE UNNECESSARY BUT THAT IS UNCLEAR --------------------

	/// TODO dunno what these are. guessing 'original x' and 'original y' but all the code involving them is mathy and i don't have the patience rn
	/// Fill in if u know ty
	var/xo
	var/yo

	/// What the fuck is this comment your shit jesus christ ????? TODO
	var/wx = 0
	var/wy = 0

	/// Reflection normal on the current tile (NORTH if projectile came from the north, etc.)
	/// TODO can maybe be replaced with a single dir check when relevant? not 100% sure why we need to track this always. Might be crucial, dunno
	var/incidence = 0
	/// No clue. Assoc list seems like? Also accessed as a non-assoc list sometimes. fuck. TODO
	var/list/crossing = list()
	/// No clue. Related to curr_t. TODO
	var/curr_t = 0

	/// One of the two below vars needs to be renamed or removed. Fucking confusing

	/// I don't know why this var is here it just stores the result of a proc called on the proj data. TODO revisit
	var/power = 20 // temp var to store what the current power of the projectile should be when it hits something
	/// TODO this var also feels dumb. convert to initial() prolly (on data not on this)
	var/initial_power = 20

	// ------------------- VARS TO BE TAKEN OUT BACK AND SHOT ----------------------------

	/// Yeah this sucks. TODO remove. I don't care bring the bug back so we can actually fix it
	var/is_processing = FALSE //MBC BANDAID FOR BAD BUG : Sometimes Launch() is called twice and spawns two process loops, causing DOUBLEBULLET speed and collision. this fix is bad but i cant figure otu the real issue

	var/internal_speed = null // experimental    THANKS VERY INFORMATIVE   TODO: ask yass how this works

	// TODO axe this var, only used for witch gimmick abilities which can be reworked
	var/target = null

	/// Arbitrary projectile data. Currently only used to hold an object that a projectile is seeking for a singular type. TODO remove
	var/data = 0

	/// Number of impassable atoms this projectile can pierce. Decremented on pierce. Can probably be axed in favor of the component. TODO remove
	var/pierces_left = 0

	/// TODO axe this after testing. Used very infrequently, looks redundant
	var/was_setup = 0

	/// Below stuff but also this is dumb and only used for frost bats and I don't even know why it's used there. TODO remove
	var/collide_with_other_projectiles = 0 //allow us to pass canpass() function to proj_data as well as receive bullet_act events

	disposing()
		special_data = null
		proj_data = null
		targets = null
		hitlist = null
		target = null
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
		if(proj_data)
			proj_data.post_setup(src)
		if (!QDELETED(src))
			SPAWN(0)
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
			A.visible_message("<b><span class='alert'>The projectile narrowly misses [A]!</span></b>")
			//A.visible_message("<b><span class='alert'>The projectile thuds into [A] uselessly!</span></b>")
			//die()
			return

		var/sigreturn = SEND_SIGNAL(src, COMSIG_OBJ_PROJ_COLLIDE, A)
		sigreturn |= SEND_SIGNAL(A, COMSIG_ATOM_HITBY_PROJ, src)
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
		if(proj_data?.material) //ZeWaka: Fix for null.material
			proj_data.material.triggerOnAttack(src, src.shooter, A)

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

	proc/max_range_fail()


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

	// Awful var names. TODO rename pretty much everything here, or at least document the functions
	proc/setup()
		if(QDELETED(src))
			return
		if (src.proj_data == null || (xo == 0 && yo == 0) || proj_data.projectile_speed == 0)
			die()
			return

		name = src.proj_data.name
		pierces_left = src.proj_data.pierces
		goes_through_walls = src.proj_data.goes_through_walls
		goes_through_mobs = src.proj_data.goes_through_mobs
		set_icon()

		var/len = sqrt(src.xo**2 + src.yo**2)

		if (len == 0)
			die()
			return
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
		var/speed = internal_speed || proj_data.projectile_speed
		var/x32 = 0
		var/xs = 1
		var/y32 = 0
		var/ys = 1
		if (xo)
			x32 = 32 / (speed * xo)
			if (x32 < 0)
				xs = -1
				x32 = -x32
		if (yo)
			y32 = 32 / (speed * yo)
			if (y32 < 0)
				ys = -1
				y32 = -y32
		var/max_t = src.max_range * (32/speed)
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
		src.ticks_until_can_hit_mob--
		proj_data.tick(src)
		if (QDELETED(src))
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

		// The bullet would be expired/decayed.
		if (src.travelled >= src.max_range * 32)
			proj_data.on_max_range_die(src)
			die()
			return

		if (proj_data.precalculated)
			var/incidence_turf = curr_turf
			for (var/i = 1, i < length(crossing), i++)
				var/turf/T = crossing[i]
				if (crossing[T] < curr_t)
					Move(T)
					if (QDELETED(src))
						return
					incidence = get_dir(incidence_turf, T)
					incidence_turf = T
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
		var/dpx = dx * 32
		var/dpy = dy * 32

		if (!dx && !dy) 	//smooth movement within a tile
			animate(src,pixel_x = wx-dpx, pixel_y = wy-dpy, time = 1 DECI SECOND, flags = ANIMATION_END_NOW)
		else
			if ((loc.x - curr_turf.x))
				pixel_x += 32 * -(loc.x - curr_turf.x)
			if ((loc.y - curr_turf.y))
				pixel_y += 32 * -(loc.y - curr_turf.y)

			animate(src,pixel_x = wx-dpx, pixel_y = wy-dpy, time = 1 DECI SECOND, flags = ANIMATION_END_NOW) //todo figure out later

	track_blood()
		src.tracked_blood = null
		return

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		return

ABSTRACT_TYPE(/datum/projectile)
/datum/projectile
	// These vars were copied from the an projectile datum. I am not sure which version, probably not 4407.
	var/name = "projectile"
	var/icon = 'icons/obj/projectiles.dmi'
	var/icon_state = "bullet"	// A special note: the icon state, if not a point-symmetric sprite, should face NORTH by default.
	var/invisibility = INVIS_NONE
	var/impact_image_state = null // what kinda overlay they puke onto non-mobs when they hit
	var/brightness = 0
	var/color_red = 0
	var/color_green = 0
	var/color_blue = 0
	var/color_icon = "#ffffff"
	var/override_color = 0
	var/damage = 0				 // How much damage this will do
	var/stun = 0				 // How much "stun power" this will have.
	var/cost = 1                 // How much ammo this costs
	var/max_range = PROJ_INFINITE_RANGE            // How many ticks can this projectile go for if not stopped, if it doesn't die from falloff
	var/dissipation_rate = 2     // How fast the power goes away
	var/dissipation_delay = 10   // How many tiles till it starts to lose power - not exactly tiles, because falloff works on ticks, and doesn't seem to quite match 1-1 to tiles.
									// When firing in a straight line, I was getting doubled falloff values on the fourth tile from the shooter, as well as others further along. -Tarm
	var/power = 0               // How much of a punch this has. Autogenerated from damage and stun
	var/ks_ratio = 1.0           /** Kill/Stun ratio, when it hits a mob the damage/stun is based upon this and the power
	                                eg 1.0 will cause damage = to power while 0.0 would cause just stun = to power
									Do not override this, it is autogenerated from damage and stun*/

	var/armor_ignored = 0		 // Percentage of armor to ignore. Old-style AP is 0.66 = ignore 66% of target's armor

	var/sname = "stun"           // name of the projectile setting, used when you change a guns setting
	var/shot_sound = 'sound/weapons/Taser.ogg' // file location for the sound you want it to play
	var/shot_sound_extrarange = 0 //should the sound have extra range?
	var/shot_volume = 100		 // How loud the sound plays (thank you mining drills for making this a needed thing)
	var/shot_number = 0          // How many projectiles should be fired, each will cost the full cost
	var/shot_delay = 0.1 SECONDS          // Time between shots in a burst.
	var/damage_type = D_KINETIC  // What is our damage type
	var/hit_type = null          // For blood system damage - DAMAGE_BLUNT, DAMAGE_CUT and DAMAGE_STAB
	var/hit_ground_chance = 0    // With what % do we hit mobs laying down
	var/window_pass = 0          // Can we pass windows
	var/obj/projectile/master = null // The projectile obj that we're associated with
	var/silentshot = 0           // Standard visible message upon bullet_act.
	var/implanted                // Path of "bullet" left behind in the mob on successful hit
	var/disruption = 0           // planned thing to deal with pod electronics / etc
	var/zone = null              // todo: if fired from a handheld gun, check the targeted zone --- this should be in the goddamn obj

	var/datum/material/material = null

	var/casing = null
	var/reagent_payload = null
	var/forensic_ID = null
	var/precalculated = 1

	var/hit_object_sound = 0
	var/hit_mob_sound = 0

	///if a fullauto-capable weapon should be able to fullauto this ammo type
	var/fullauto_valid = 0

	// Determines the amount of length units the projectile travels each tick
	// A tile is 32 wide, 32 long, and 32 * sqrt(2) across.
	// Setting this to 32 will mimic the old behaviour for shots travelling in one of the cardinal directions.
	var/projectile_speed = 36

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
	var/hits_wraiths = 0
	var/goes_through_walls = 0
	var/goes_through_mobs = 0
	var/pierces = 0
	var/ticks_between_mob_hits = 0
	var/is_magical = 0              //magical projectiles, i.e. the chaplain is immune to these
	var/ie_type = "T"	//K, E, T
	// var/type = "K"					//3 types, K = Kinetic, E = Energy, T = Taser

	/// for on_pre_hit. Causes it to early-return TRUE if the thing checked was already cleared for pass-thru
	var/atom/last_thing_hit

	New()
		. = ..()
		generate_stats()

	onVarChanged(variable, oldval, newval)
		. = ..()
		switch(variable)
			if("damage", "stun")
				generate_stats()
			if("power", "ks_ratio")
				generate_inverse_stats()

	proc
		generate_stats()
			src.power = damage + stun
			if(power != 0)
				src.ks_ratio = damage / power
			else
				src.ks_ratio = 1 //for zero-power projectiles (usually gimmick stuff etc) or weirdness. Default to full lethal I suppose

		generate_inverse_stats() //in case you want to turn ks_ratio and power back into damage and stun? idk.
			src.damage = src.power * src.ks_ratio
			src.stun = src.power * (1-src.ks_ratio)


		impact_image_effect(var/type, atom/hit, angle, var/obj/projectile/O)		//3 types, K = Kinetic, E = Energy, T = Taser
			var/obj/itemspecialeffect/impact/E = null
			//this way is probably fastest.
			switch (type)
				if ("K")
					if (iscarbon(hit))
						E = new /obj/itemspecialeffect/impact/blood
					else if (issilicon(hit))
						E = new /obj/itemspecialeffect/impact/silicon
				if ("E")
					if (iscarbon(hit))
						E = new /obj/itemspecialeffect/impact/energy
				if ("T")
					if (iscarbon(hit))
						E = new /obj/itemspecialeffect/impact/taser

			if (E)
				E.setup(hit.loc)

		hit_ground()
			return prob(hit_ground_chance)
		//For future use, ie guns that can change the power settings
		set_power()
			return
		//When it hits a mob or such should anything special happen
		on_hit(atom/hit, angle, var/obj/projectile/O) //MBC : what the fuck shouldn't this all be in bullet_act on human in damage.dm?? this split is giving me bad vibes
			impact_image_effect(ie_type, hit)

		/// Does a thing every step this projectile takes
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
		/// Check if we want to do something before actually hitting the thing we hit
		/// Return TRUE for it to more or less skip collide()
		on_pre_hit(atom/hit, angle, var/obj/projectile/O)
			return

		on_canpass(var/obj/projectile/O, atom/movable/passing_thing)
			.= 1

		get_power(obj/projectile/P, atom/A)
			return P.initial_power - max(0, (P.travelled/32 - src.dissipation_delay))*src.dissipation_rate

		post_setup(obj/projectile/P)
			return

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

/proc/shoot_projectile_ST(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/atom/movable/remote_sound_source, var/datum/callback/alter_proj = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return null
	var/obj/projectile/Q = shoot_projectile_relay(S, DATA, T, remote_sound_source, alter_proj = alter_proj)
	if (DATA.shot_number > 1)
		SPAWN(-1)
			for (var/i = 2, i < DATA.shot_number, i++)
				sleep(DATA.shot_delay)
				shoot_projectile_relay(S, DATA, T, remote_sound_source, alter_proj = alter_proj)
	return Q

/proc/shoot_projectile_ST_pixel(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy, var/datum/callback/alter_proj = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return null
	var/obj/projectile/Q = shoot_projectile_relay_pixel(S, DATA, T, pox, poy, alter_proj = alter_proj)
	if (DATA.shot_number > 1)
		SPAWN(-1)
			for (var/i = 2, i <= DATA.shot_number, i++)
				sleep(DATA.shot_delay)
				shoot_projectile_relay_pixel(S, DATA, T, pox, poy, alter_proj = alter_proj)
	return Q

/proc/shoot_projectile_ST_pixel_spread(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy, var/spread_angle, var/datum/callback/alter_proj = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return null
	var/obj/projectile/Q = shoot_projectile_relay_pixel_spread(S, DATA, T, pox, poy, spread_angle, alter_proj = alter_proj)
	if (DATA.shot_number > 1)
		SPAWN(-1)
			for (var/i = 2, i <= DATA.shot_number, i++)
				sleep(DATA.shot_delay)
				shoot_projectile_relay_pixel_spread(S, DATA, T, pox, poy, spread_angle, alter_proj = alter_proj)
	return Q

/proc/shoot_projectile_DIR(var/atom/movable/S, var/datum/projectile/DATA, var/dir, var/atom/movable/remote_sound_source, var/datum/callback/alter_proj = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return null
	var/turf/T = get_step(get_turf(S), dir)
	if (T)
		return shoot_projectile_ST(S, DATA, T, remote_sound_source, alter_proj = alter_proj)
	return null

/proc/shoot_projectile_relay(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/atom/movable/remote_sound_source, var/datum/callback/alter_proj = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/obj/projectile/P = initialize_projectile_ST(S, DATA, T, remote_sound_source, alter_proj = alter_proj)
	if (P)
		P.launch()
	return P

/proc/shoot_projectile_relay_pixel(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy, var/datum/callback/alter_proj = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/obj/projectile/P = initialize_projectile_pixel(S, DATA, T, pox, poy, alter_proj = alter_proj)
	if (P)
		P.launch()
	return P

/proc/shoot_projectile_relay_pixel_spread(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy, var/spread_angle, var/datum/callback/alter_proj = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/obj/projectile/P = initialize_projectile_pixel_spread(S, DATA, T, pox, poy, spread_angle, alter_proj = alter_proj)
	if (P)
		P.launch()
	return P

/proc/shoot_projectile_XY(var/atom/movable/S, var/datum/projectile/DATA, var/xo, var/yo, var/datum/callback/alter_proj = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/obj/projectile/Q = shoot_projectile_XY_relay(S, DATA, xo, yo, alter_proj = alter_proj)
	if (DATA.shot_number > 1)
		SPAWN(-1)
			for (var/i = 2, i <= DATA.shot_number, i++)
				sleep(DATA.shot_delay)
				shoot_projectile_XY_relay(S, DATA, xo, yo, alter_proj = alter_proj)
	return Q

/proc/shoot_projectile_XY_relay(var/atom/movable/S, var/datum/projectile/DATA, var/xo, var/yo, var/datum/callback/alter_proj = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/obj/projectile/P = initialize_projectile(get_turf(S), DATA, xo, yo, S, alter_proj = alter_proj)
	if (P)
		P.launch()
	return P

/proc/initialize_projectile_ST(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/atom/movable/remote_sound_source, var/datum/callback/alter_proj = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/turf/Q1 = get_turf(S)
	var/turf/Q2 = get_turf(T)
	if (!(Q1 && Q2))
		return
	return initialize_projectile(Q1, DATA, Q2.x - Q1.x, Q2.y - Q1.y, S, remote_sound_source, alter_proj = alter_proj)

/proc/initialize_projectile_pixel(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy, var/datum/callback/alter_proj = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/turf/Q1 = get_turf(S)
	var/turf/Q2 = get_turf(T)
	if (!(Q1 && Q2))
		return
	return initialize_projectile(Q1, DATA, (Q2.x - Q1.x) * 32 + pox, (Q2.y - Q1.y) * 32 + poy, S, alter_proj = alter_proj)

/proc/initialize_projectile_pixel_spread(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy, var/spread_angle, var/datum/callback/alter_proj = null)
	var/obj/projectile/P = initialize_projectile_pixel(S, DATA, T, pox, poy, alter_proj = alter_proj)
	if (P && spread_angle)
		if (spread_angle < 0)
			spread_angle = -spread_angle
		var/spread = rand(spread_angle * 10) / 10
		P.rotateDirection(prob(50) ? spread : -spread)
	return P

/proc/initialize_projectile(var/turf/S, var/datum/projectile/DATA, var/xo, var/yo, var/shooter = null, var/turf/remote_sound_source, var/play_shot_sound = TRUE, var/datum/callback/alter_proj = null)
	if (!S)
		return
	var/obj/projectile/P = new
	if(!P)
		return

	P.set_loc(S)
	P.orig_turf = get_turf(S)
	P.shooter = shooter
	P.power = DATA.power

	P.proj_data = DATA
	alter_proj?.Invoke(P)


	if(P.proj_data == DATA)
		P.initial_power = P.power //allows us to set projectile power in callback without needing a new projectile datum
	else
		DATA = P.proj_data //could have been changed by alter_projectile
		P.initial_power = DATA.power

	P.set_icon()
	P.name = DATA.name
	P.setMaterial(DATA.material)


	if (DATA.implanted)
		P.implanted = DATA.implanted

	if(remote_sound_source)
		shooter = remote_sound_source

	if (play_shot_sound)
		if (narrator_mode)
			playsound(S, 'sound/vox/shoot.ogg', 50, 1)
		else if(DATA.shot_sound && DATA.shot_volume && shooter)
			playsound(S, DATA.shot_sound, DATA.shot_volume, 1,DATA.shot_sound_extrarange)
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

	if(DATA.dissipation_rate <= 0)
		P.max_range = DATA.max_range
	else
		P.max_range = min(DATA.dissipation_delay + round(P.power / DATA.dissipation_rate), DATA.max_range)

	if (DATA.reagent_payload)
		P.create_reagents(15)
		P.reagents.add_reagent(DATA.reagent_payload, 15)

	return P

/proc/shoot_reflected_to_sender(var/obj/projectile/P, var/obj/reflector, var/max_reflects = 3)
	if(P.reflectcount >= max_reflects)
		return
	var/obj/projectile/Q = initialize_projectile(get_turf(reflector), P.proj_data, -P.xo, -P.yo, reflector)
	if (!Q)
		return null
	SEND_SIGNAL(reflector, COMSIG_ATOM_PROJECTILE_REFLECTED)
	Q.reflectcount = P.reflectcount + 1
	if (ismob(P.shooter))
		Q.mob_shooter = P.shooter
	Q.name = "reflected [Q.name]"
	Q.launch()
	return Q

/*
 * shoot_reflected_true seemed half broken...
 * So I made my own proc, but left the old one in place just in case -- Sovexe
 * var/reflect_on_nondense_hits - flag for handling hitting objects that let bullets pass through like secbots, rather than duplicating projectiles
 */
/proc/shoot_reflected_bounce(var/obj/projectile/P, var/obj/reflector, var/max_reflects = 3, var/mode = PROJ_RAPID_HEADON_BOUNCE, var/reflect_on_nondense_hits = FALSE)
	if (!P || !reflector)
		return

	if(P.reflectcount >= max_reflects)
		return

	var/play_shot_sound = TRUE

	switch (mode)
		if (PROJ_NO_HEADON_BOUNCE) //no head-on bounce
			if ((P.shooter.x == reflector.x) || (P.shooter.y == reflector.y))
				return
		if (PROJ_HEADON_BOUNCE) // no rapid head-on bounce
			if ((P.shooter.x == reflector.x) && abs(P.shooter.y - reflector.y) == 2)
				return
			else if (abs(P.shooter.x - reflector.x) == 2 && (P.shooter.y == reflector.y))
				return
		if (PROJ_RAPID_HEADON_BOUNCE)
			if (P.proj_data.shot_sound)
				if ((P.shooter.x == reflector.x) && abs(P.shooter.y - reflector.y) == 2)
					play_shot_sound = FALSE //anti-ear destruction
				else if (abs(P.shooter.x - reflector.x) == 2 && (P.shooter.y == reflector.y))
					play_shot_sound = FALSE //anti-ear destruction
		else
			return

	/*
		* We have to calculate our incidence each time
		* Otherwise we risk the reflect projectile using the same incidence over and over
		* resulting in bumping same wall repeatadly
	*/
	var/x_diff = reflector.x - P.x
	var/y_diff = reflector.y - P.y

	if (!x_diff && !y_diff)
		return //we are inside the reflector or something went terribly wrong
	else if (x_diff > 0 && y_diff == 0)
		P.incidence = WEST
	else if (x_diff < 0 && y_diff == 0)
		P.incidence = EAST
	else if (x_diff == 0 && y_diff > 0)
		P.incidence = SOUTH
	else if (x_diff == 0 && y_diff < 0)
		P.incidence = NORTH
	else if (x_diff < 0 && y_diff < 0)
		P.incidence = pick(EAST, NORTH)
	else if (x_diff < 0 && y_diff > 0)
		P.incidence = pick(EAST, SOUTH)
	else if (x_diff > 0 && y_diff < 0)
		P.incidence = pick(WEST, NORTH)
	else if (x_diff > 0 && y_diff > 0)
		P.incidence = pick(WEST, SOUTH)
	else
		return //please no runtimes

	var/rx = 0
	var/ry = 0

	var/nx = P.incidence == WEST ? -1 : (P.incidence == EAST ?  1 : 0)
	var/ny = P.incidence == SOUTH ? -1 : (P.incidence == NORTH ?  1 : 0)

	var/dn = 2 * (P.xo * nx + P.yo * ny) // incident direction DOT normal * 2
	rx = P.xo - dn * nx // r = d - 2 * (d * n) * n
	ry = P.yo - dn * ny

	if (rx == ry && rx == 0)
		logTheThing(LOG_DEBUG, null, "<b>Reflecting Projectiles</b>: Reflection failed for [P.name] (incidence: [P.incidence], direction: [P.xo];[P.yo]).")
		return // unknown error

	//spawns the new projectile in the same location as the existing one, not inside the hit thing
	var/obj/projectile/Q = initialize_projectile(get_turf(P), P.proj_data, rx, ry, reflector, play_shot_sound = play_shot_sound)
	if (!Q)
		return
	Q.reflectcount = P.reflectcount + 1
	if (ismob(P.shooter))
		Q.mob_shooter = P.shooter

	//fix for duplicating projectiles when hitting nondense objects like secbots that don't kill projectiles
	if (isobj(reflector) && reflector.density == 0)
		if (reflect_on_nondense_hits)
			P.die()
		else
			Q.die()
			if (P)
				return P
			else
				return

	Q.name = "reflected [Q.name]"
	Q.launch()
	return Q
