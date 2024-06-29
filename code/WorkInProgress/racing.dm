/area/sim/racing_entry
	name = "Clowncar Race track - Entry"
	icon_state = "green"
	luminosity = 1
	force_fullbright = 1
	requires_power = 0

/area/sim/racing_track
	name = "Clowncar Race track"
	icon_state = "yellow"
	luminosity = 1
	force_fullbright = 1
	requires_power = 0

/obj/racing_boosterstrip
	name = "Booster"
	icon = 'icons/misc/racing.dmi'
	icon_state = "boosterstrip"
	anchored = ANCHORED
	density = 0
	opacity = 0

	Crossed(atom/movable/A)
		..()
		if(istype(A,/obj/racing_clowncar))
			step(A,src.dir)

			var/obj/racing_clowncar/R = A
			R.boost()


/obj/racing_powerup_spawner
	name = "PowerUpSpawner"
	icon = 'icons/map-editing/mapping_helpers.dmi'
	icon_state = "spawner"
	anchored = ANCHORED
	density = 0
	opacity = 0
	invisibility = INVIS_ALWAYS
	var/spawn_time = 0
	var/wait = 0

	New()
		processing_items += src
		spawnit()
		..()

	disposing()
		processing_items -= src
		..()

	proc/process()
		if (world.time > spawn_time + wait)
			spawnit()

	proc/spawnit()
		if(!(locate(/obj/racing_powerupbox) in src.loc))
			new/obj/racing_powerupbox(src.loc)
		wait = 150 + rand(50, 400)
		spawn_time = world.time

/obj/racing_butt/
	name = "butt"
	icon = 'icons/misc/racing.dmi'
	icon_state = "buttshell"
	anchored = ANCHORED
	density = 1
	opacity = 0
	var/source_car = null

	New(var/atom/spawnloc, var/spawndir, var/atom/sourcecar)
		..()
		src.set_loc(spawnloc)
		src.set_dir(spawndir)
		source_car = sourcecar
		SPAWN(7.5 SECONDS)
			playsound(src, 'sound/mksounds/itemdestroy.ogg', 45, FALSE)
			qdel(src)
		move_process()

	bump(var/atom/A)
		if(istype(A,/obj/racing_clowncar) && A != source_car)
			var/obj/racing_clowncar/R = A
			R.spin(20)
			playsound(A, 'sound/mksounds/gothit.ogg', 45, FALSE)
			qdel(src)

	proc/move_process()
		if (src.qdeled || src.disposed)
			return
		step(src,dir)
		SPAWN(1 DECI SECOND) move_process()

/obj/super_racing_butt/
	name = "superbutt"
	icon = 'icons/misc/racing.dmi'
	icon_state = "superbuttshell"
	anchored = ANCHORED
	density = 1
	opacity = 0
	var/source_car = null

	New(var/atom/spawnloc, var/spawndir, var/atom/sourcecar)
		..()
		src.set_loc(spawnloc)
		src.set_dir(spawndir)
		source_car = sourcecar
		SPAWN(7.5 SECONDS)
			playsound(src, 'sound/mksounds/itemdestroy.ogg', 45, FALSE)
			qdel(src)
		move_process()

	bump(var/atom/A)
		if(istype(A,/obj/racing_clowncar) && A != source_car)
			var/obj/racing_clowncar/R = A
			R.spin(15)
			playsound(A, 'sound/mksounds/gothit.ogg', 45, FALSE)
			qdel(src)

	proc/move_process()
		if (src.qdeled || src.disposed)
			return

		var/atom/target = null

		for(var/obj/racing_clowncar/C in view(2,src))
			if(C != source_car)
				target = C
				break

		if(target)
			step_towards(src,target)
			SPAWN(1 DECI SECOND) move_process()
		else
			step(src, src.dir)
			SPAWN(1 DECI SECOND) move_process()

/obj/racing_trap_banana/
	name = "banana peel"
	icon = 'icons/misc/racing.dmi'
	icon_state = "banana-peel"
	anchored = ANCHORED
	density = 0
	opacity = 0
	var/delete = 1
	var/spawn_time = 0

	New()
		..()
		spawn_time = world.time
		if (delete)
			processing_items += src

	disposing()
		if (delete)
			processing_items -= src
		..()

	proc/process()
		if (world.time > spawn_time + 4500)
			qdel(src)

	Crossed(atom/movable/A)
		..()
		if(istype(A,/obj/racing_clowncar))
			var/obj/racing_clowncar/R = A
			R.spin(20)
			playsound(src, 'sound/mksounds/itemdestroy.ogg', 45, FALSE)
			if(delete)	qdel(src)


/obj/racing_powerupbox/
	name = "POWERUP!"
	icon = 'icons/misc/racing.dmi'
	icon_state = "powerup"
	anchored = ANCHORED
	density = 0
	opacity = 0

	Crossed(atom/movable/A)
		..()
		if(istype(A,/obj/racing_clowncar))
			var/obj/racing_clowncar/R = A
			R.random_powerup()
			qdel(src)

/// This holds all of your abilities for kart racing
/datum/abilityHolder/kart_racing
	topBarRendered = 1

/// the base kart ability
ABSTRACT_TYPE(/datum/targetable/kart_powerup)
/datum/targetable/kart_powerup
	icon = 'icons/misc/racing.dmi'
	icon_state = "blank"
	desc = "Click to use"
	cooldown = 0
	last_cast = 0
	targeted = 0
	preferred_holder_type = /datum/abilityHolder/kart_racing
	var/mob/living/carbon/human/racer

	onAttach(datum/abilityHolder/H)
		. = ..()
		if(ishuman(holder.owner))
			racer = holder.owner
		return

	cast()
		if (!istype(racer))
			return 1
		if (..())
			return 1
		if(!istype(racer?.loc,/obj/racing_clowncar))
			return 1

	disposing()
		racer = null
		. = ..()


/datum/targetable/kart_powerup/banana_peel
	name = "Bananapeel"
	desc = "Click to use"
	icon_state = "banana"

	cast()
		if (..())
			return 1

		var/turf/T = get_turf(get_turf(racer))
		new/obj/racing_trap_banana/(T)

		playsound(T, 'sound/mksounds/itemdrop.ogg', 45, FALSE)
		// remove ourselves when we're used
		holder.removeAbilityInstance(src)

/datum/targetable/kart_powerup/butt
	name = "Butt"
	desc = "Click to use"
	icon_state = "butt"

	cast()
		if (..())
			return 1

		var/turf/T = get_turf(racer)
		var/turf/T2 = get_step(T,racer.loc?.dir)
		var/turf/trg = null

		if(!T2.density) trg = T2
		else trg = T

		new/obj/racing_butt(trg, racer.loc?.dir, racer.loc)

		playsound(racer.loc, 'sound/mksounds/throw.ogg', 33, FALSE)

		// remove ourselves when we're used
		holder.removeAbilityInstance(src)

/datum/targetable/kart_powerup/superbutt
	name = "Superbutt"
	desc = "Click to use"
	icon_state = "superbutt"

	cast()
		if (..())
			return 1

		var/turf/T = get_turf(racer)
		var/turf/T2 = get_step(T,racer.loc?.dir)
		var/turf/trg = null

		if(!T2.density) trg = T2
		else trg = T

		new/obj/super_racing_butt(trg, racer.loc?.dir, racer.loc)

		playsound(racer.loc, 'sound/mksounds/throw.ogg', 33, FALSE)

		// remove ourselves when we're used
		holder.removeAbilityInstance(src)

/datum/targetable/kart_powerup/mushroom
	name = "Mushroom"
	desc = "Click to use"
	icon_state = "mushroom"

	cast()
		if (..())
			return 1

		// this should be valid, we're checking for it before we cast
		var/obj/racing_clowncar/R = racer.loc
		playsound(R, 'sound/mksounds/boost.ogg', 33, FALSE)
		R.boost()

		// remove ourselves when we're used
		holder.removeAbilityInstance(src)

/datum/targetable/kart_powerup/superboost
	name = "Super Boost"
	desc = "Click to use"
	icon_state = "superboost"

	cast()
		if (..())
			return 1

		// this should be valid, we're checking for it before we cast
		var/obj/racing_clowncar/R = racer.loc
		R.boost(TRUE)

		// remove ourselves when we're used
		holder.removeAbilityInstance(src)

/obj/racing_clowncar
	name = "Turbo Clowncar 2000"
	desc = ""
	icon = 'icons/misc/racing.dmi'
	icon_state = "clowncar"
	anchored = UNANCHORED
	density = 1
	opacity = 0

	var/obj/powerup/powerup = null

	var/dir_original = 1

	var/cant_control = 0 //Used during spins, etc
	var/base_speed = 2 //Base speed.
	var/turbo = 1 //Boost speed is base_speed - turbo.
	var/super = 0 //Invincibility

	var/driving = 0
	var/speed = 2 //This is actually the DELAY. Lower = faster.

	var/mob/living/carbon/human/driver = null
	var/datum/abilityHolder/kart_racing/abilities = null

	proc/random_powerup()
		var/list/powerups = concrete_typesof(/datum/targetable/kart_powerup)
		if(!length(powerups))
			return
		var/datum/targetable/kart_powerup/new_powerup = pick(powerups)

		playsound(src, 'sound/mksounds/gotitem.ogg', 33, FALSE)

		if (abilities && new_powerup)
			// only add a new kart powerup when there's not one already there
			if (!length(abilities.abilities))
				abilities.addAbility(new_powerup)

		return
	// copied from clown cars
	Click()
		if(usr != driver)
			..()
			return
		if(can_act(usr))
			exit()
		return

	// allow people to enter the car by clickdragging
	MouseDrop_T(mob/living/target, mob/user)
		if (BOUNDS_DIST(user, src) > 0 || !in_interact_range(src,user)) return
		if (target == user)
			enter()

	verb/enter()
		set src in oview(1)
		set category = "Local"
		if(!ishuman(usr)) return

		if(driver)
			boutput(usr, SPAN_ALERT("Car already occupied by [driver.name]."))
			return

		var/mob/M = usr

		M.set_loc(src)
		driver = M

		// setup kart abilities
		var/datum/abilityHolder/kart_racing/A = driver.get_ability_holder(/datum/abilityHolder/kart_racing)
		if (!A || !istype(A))
			A = driver.add_ability_holder(/datum/abilityHolder/kart_racing)
		abilities = A

		name = "Turbo Clowncar 2000 ([driver.name])"
		src.name_suffix("([driver.name])")
		src.UpdateName()
		driving = 0

	verb/exit()
		set src in oview(1)
		set category = "Local"
		if(!ishuman(usr) || usr != driver) return

		stop()

		driver.set_loc(get_turf(src))

		var/datum/abilityHolder/kart_racing/A = driver.get_ability_holder(/datum/abilityHolder/kart_racing)
		if (istype(A))
			driver.remove_ability_holder(/datum/abilityHolder/kart_racing)
		abilities = null

		src.remove_suffixes("([driver.name])")
		src.UpdateName()
		driver = null
		driving = 0

	proc/spin(var/magnitude)
		if(super) return
		cant_control = 1
		set_density(0)
		dir_original = src.dir
		var/image/out_of_control = image('icons/misc/racing.dmi',"broken")
		src.AddOverlays(out_of_control,"spin")

		playsound(src, 'sound/mksounds/cpuspin.ogg', 33, FALSE)

		SPAWN(magnitude+1)
			cant_control = 0
			dir_original = 0
			set_density(1)
			src.ClearSpecificOverlays("spin")

		SPAWN(0)
			for(var/i=0, i<magnitude, i++)
				src.set_dir(turn(src.dir, 90))
				sleep(0.1 SECONDS)
		return

	proc/boost(var/super_boost = FALSE)
		speed = base_speed - turbo
		drive(dir, speed)

		// clown car doesnt have an overlay, so sad
		if (super_boost)
			src.super = TRUE
			src.icon_state = "clowncar_super"
			playsound(src, 'sound/mksounds/invin10sec.ogg',33, FALSE,0) // 33
			SPAWN(10 SECONDS)
				src.super = FALSE
				speed = base_speed
				src.icon_state = "clowncar"
		else
			icon_state = "clowncar_boost"
			playsound(src, 'sound/mksounds/boost.ogg', 30, FALSE)
			SPAWN(5 SECONDS)
				speed = base_speed
				if (driving) drive(dir, speed)
				icon_state = "clowncar"


	proc/drive(var/direction, var/speed)
		set_dir(direction)
		driving = 1
		src.glide_size = (32 / speed) * world.tick_lag
		walk(src, dir, speed)

	proc/stop()
		driving = 0
		playsound(src, 'sound/mksounds/skidd.ogg', 25, FALSE)
		walk(src, 0)

	relaymove(mob/user, direction)
		if(!driver) return
		if(user != driver || cant_control) return

		if(direction == turn(src.dir,180))
			set_dir(direction)
			stop()
		else
			drive(direction, speed)

	bump(var/atom/A)
		if(super && istype(A,/obj/racing_clowncar))
			var/obj/racing_clowncar/R = A
			if(!R.super)
				R.set_dir(pick(turn(src.dir,90),turn(src.dir,-90)))
				step(R,R.dir)
				R.spin(6)
		return

	remove_air(amount as num)
		var/datum/gas_mixture/Air = new /datum/gas_mixture
		Air.oxygen = amount
		Air.temperature = 310
		return Air



/obj/racing_clowncar/kart
	name = "Go-Kart"
	desc = "A Go-Kart, whatever the kids spell it these days."
	icon = 'icons/misc/racing.dmi'
	icon_state = "kart_blue_u"
	layer = OBJ_LAYER
	var/returnpoint = null
	var/returndir = null
	var/turf/returnloc = null

	/// the vis_flags to be restored on exiting the vehicle
	var/occupant_vis_flags
	var/cover_state = "kart_blue"

	New()
		..()
		returndir = dir
		if(returnpoint)
			returnloc = pick_landmark(returnpoint)

	enter()
		set src in oview(1)
		set category = "Local"
		if(!ishuman(usr)) return

		if(driver)
			boutput(usr, SPAN_ALERT("Car already occupied by [driver.name]."))
			return

		var/mob/M = usr

		M.set_loc(src)
		driver = M

		src.vis_contents += driver
		occupant_vis_flags = driver.vis_flags
		driver.pixel_x = 0
		driver.pixel_y = 0
		driver.vis_flags |= VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_DIR

		src.AddOverlays(image('icons/misc/racing.dmi', src.cover_state,layer=ABOVE_OBJ_LAYER),"driver_cover")
		update()

		// setup kart abilities
		var/datum/abilityHolder/kart_racing/A = driver.get_ability_holder(/datum/abilityHolder/kart_racing)
		if (!A || !istype(A))
			A = driver.add_ability_holder(/datum/abilityHolder/kart_racing)
		abilities = A

		src.name_suffix("([driver.name])")
		src.UpdateName()
		driving = 0
		update()

	exit()
		set src in oview(1)
		set category = "Local"
		if(!ishuman(usr) || usr != driver) return
		reset()

	proc/reset()
		stop()
		returntoline()
		if(driver)
			driver.set_loc(get_turf(src))

		var/datum/abilityHolder/kart_racing/A = driver.get_ability_holder(/datum/abilityHolder/kart_racing)
		if (A && istype(A))
			driver.remove_ability_holder(/datum/abilityHolder/kart_racing)
		abilities = null

		src.ClearSpecificOverlays("boost")
		src.ClearSpecificOverlays("spin")
		src.ClearSpecificOverlays("super")

		src.remove_suffixes("([driver.name])")
		src.UpdateName()
		driver.vis_flags = occupant_vis_flags
		src.vis_contents -= driver
		driver = null
		driving = 0
		update()

	proc/update()
		if(!driver)
			src.ClearSpecificOverlays("driver_cover")

	proc/returntoline()
		if(returnloc)
			set_loc(returnloc)
			set_dir(returndir)

	boost(var/super_boost = FALSE) // this exists because we dont have a boosted kart sprite????
		speed = base_speed - turbo
		drive(dir, speed)

		src.AddOverlays(image('icons/mob/robots.dmi', "up-speed",layer=ABOVE_OBJ_LAYER),"boost")

		if (super_boost)
			src.super = TRUE
			src.AddOverlays(image('icons/misc/racing.dmi', "kart_super"),"super")
			playsound(src, 'sound/mksounds/invin10sec.ogg',33, FALSE,0) // 33
			SPAWN(10 SECONDS)
				src.super = FALSE
				speed = base_speed
				if (driving) drive(dir, speed)
				src.ClearSpecificOverlays("super")
				src.ClearSpecificOverlays("boost")
		else
			playsound(src, 'sound/mksounds/boost.ogg', 30, FALSE)
			SPAWN(5 SECONDS)
				speed = base_speed
				if (driving) drive(dir, speed)
				src.ClearSpecificOverlays("boost")


/obj/racing_clowncar/kart/red
	icon_state = "kart_red_u"
	cover_state = "kart_red"
