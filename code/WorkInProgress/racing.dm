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
	anchored = 1
	density = 0
	opacity = 0

	Crossed(atom/movable/A)
		..()
		if(istype(A,/obj/racing_clowncar))
			playsound(A, 'sound/mksounds/boost.ogg', 30, 0)
			step(A,src.dir)

			var/obj/racing_clowncar/R = A
			R.speed = R.base_speed - R.turbo
			R.drive(R.dir, R.speed)
			R.overlays += image('icons/mob/robots.dmi', "up-speed")
			SPAWN(1.5 SECONDS)
				R.speed = R.base_speed
				if (R.driving) R.drive(R.dir, 2)
				R.overlays -= image('icons/mob/robots.dmi', "up-speed")


/obj/racing_powerup_spawner
	name = "PowerUpSpawner"
	icon = 'icons/Testing/atmos_testing.dmi'
	anchored = 1
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
	anchored = 1
	density = 1
	opacity = 0
	var/source_car = null

	New(var/atom/spawnloc, var/spawndir, var/atom/sourcecar)
		..()
		src.set_loc(spawnloc)
		src.set_dir(spawndir)
		source_car = sourcecar
		SPAWN(7.5 SECONDS)
			playsound(src, 'sound/mksounds/itemdestroy.ogg', 45, 0)
			qdel(src)
		move_process()

	bump(var/atom/A)
		if(istype(A,/obj/racing_clowncar) && A != source_car)
			var/obj/racing_clowncar/R = A
			R.spin(20)
			playsound(A, 'sound/mksounds/gothit.ogg', 45, 0)
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
	anchored = 1
	density = 1
	opacity = 0
	var/source_car = null

	New(var/atom/spawnloc, var/spawndir, var/atom/sourcecar)
		..()
		src.set_loc(spawnloc)
		src.set_dir(spawndir)
		source_car = sourcecar
		SPAWN(7.5 SECONDS)
			playsound(src, 'sound/mksounds/itemdestroy.ogg', 45, 0)
			qdel(src)
		move_process()

	bump(var/atom/A)
		if(istype(A,/obj/racing_clowncar) && A != source_car)
			var/obj/racing_clowncar/R = A
			R.spin(15)
			playsound(A, 'sound/mksounds/gothit.ogg', 45, 0)
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
	anchored = 1
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
			playsound(src, 'sound/mksounds/itemdestroy.ogg', 45, 0)
			if(delete)	qdel(src)


/obj/racing_powerupbox/
	name = "POWERUP!"
	icon = 'icons/misc/racing.dmi'
	icon_state = "powerup"
	anchored = 1
	density = 0
	opacity = 0

	Crossed(atom/movable/A)
		..()
		if(istype(A,/obj/racing_clowncar))
			var/obj/racing_clowncar/R = A
			R.random_powerup()
			qdel(src)

/obj/powerup/
	name = "powerup"
	desc = "Click to use"
	icon = 'icons/misc/racing.dmi'
	icon_state = "blank"
	anchored = 1
	layer = HUD_LAYER
	screen_loc = "NORTH,WEST"
	var/obj/racing_clowncar/owner

	disposing()
		if(owner?.powerup == src)
			if(owner?.driver?.client)
				owner.driver.client.screen -= src
			owner.powerup = null
		owner = null
		..()

	Click()
		if (owner.powerup == src)
			owner.powerup = null
		qdel(src)
		return

/obj/powerup/bananapeel
	name = "Bananapeel"
	desc = "Click to use"
	anchored = 1
	icon_state = "banana"
	screen_loc = "NORTH,WEST"

	Click()

		if(!istype(src.loc,/obj/racing_clowncar))
			qdel(src)
			return

		var/turf/T = get_turf(src.loc)
		new/obj/racing_trap_banana/(T)

		playsound(T, 'sound/mksounds/itemdrop.ogg', 45, 0)

		qdel(src)

		return

/obj/powerup/butt
	name = "Butt"
	desc = "Click to use"
	anchored = 1
	icon_state = "butt"
	screen_loc = "NORTH,WEST"

	Click()

		if(!istype(src.loc,/obj/racing_clowncar))
			qdel(src)
			return

		var/obj/racing_clowncar/C = src.loc

		var/turf/T = get_turf(C)
		var/turf/T2 = get_step(T,C.dir)
		var/turf/trg = null

		if(!T2.density) trg = T2
		else trg = T

		new/obj/racing_butt(trg, C.dir, C)

		playsound(C, 'sound/mksounds/throw.ogg', 33, 0)

		qdel(src)

		return

/obj/powerup/superbutt
	name = "Superbutt"
	desc = "Click to use"
	anchored = 1
	icon_state = "superbutt"
	screen_loc = "NORTH,WEST"

	Click()

		if(!istype(src.loc,/obj/racing_clowncar))
			qdel(src)
			return

		var/obj/racing_clowncar/C = src.loc

		var/turf/T = get_turf(C)
		var/turf/T2 = get_step(T,C.dir)
		var/turf/trg = null

		if(!T2.density) trg = T2
		else trg = T

		new/obj/super_racing_butt(trg, C.dir, C)

		playsound(C, 'sound/mksounds/throw.ogg', 33, 0)

		qdel(src)

		return

/obj/powerup/mushroom
	name = "Mushroom"
	desc = "Click to use"
	anchored = 1
	icon_state = "mushroom"
	screen_loc = "NORTH,WEST"

	Click()
		var/atom/source = src
		src = null

		if(!istype(source.loc,/obj/racing_clowncar))
			qdel(source)
			return

		var/obj/racing_clowncar/R = source.loc

		playsound(R, 'sound/mksounds/boost.ogg', 33, 0)

		R.boost()
		qdel(source)
		return

/obj/powerup/superboost
	name = "Super Boost"
	desc = "Click to use"
	anchored = 1
	icon_state = "superboost"
	screen_loc = "NORTH,WEST"

	Click()
		var/atom/source = src
		src = null

		if(!istype(source.loc,/obj/racing_clowncar))
			qdel(source)
			return

		var/obj/racing_clowncar/R = source.loc

		playsound(R, 'sound/mksounds/invin10sec.ogg',33, 0,0) // 33

		R.super = 1
		R.boost()
		qdel(source)
		return

/obj/racing_clowncar
	name = "Turbo Clowncar 2000"
	desc = ""
	icon = 'icons/misc/racing.dmi'
	icon_state = "clowncar"
	anchored = 0
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

	proc/random_powerup()
		var/list/powerups = childrentypesof(/obj/powerup/)
		if(!powerups.len) return

		playsound(src, 'sound/mksounds/gotitem.ogg', 33, 0)

		for(var/obj/powerup/OLD in src)
			qdel(OLD)

		var/picked = pick(powerups)
		var/obj/powerup/P = new picked(src)
		src.powerup = P

		driver?.client.screen += P

		return

	verb/enter()
		set src in oview(1)
		set category = "Local"
		if(!ishuman(usr)) return

		if(driver)
			boutput(usr, "<span class='alert'>Car already occupied by [driver.name].</span>")
			return

		var/mob/M = usr

		M.set_loc(src)
		driver = M

		if(powerup && !(powerup in driver.client.screen))
			driver.client.screen += powerup

		name = "Turbo Clowncar 2000 ([driver.name])"
		driving = 0

	verb/exit()
		set src in oview(1)
		set category = "Local"
		if(!ishuman(usr) || usr != driver) return

		stop()

		driver.set_loc(get_turf(src))

		if(powerup && (powerup in driver.client.screen))
			driver.client.screen -= powerup

		name = "Turbo Clowncar 2000"
		driver = null
		driving = 0

	proc/spin(var/magnitude)
		if(super) return
		cant_control = 1
		set_density(0)
		dir_original = src.dir
		var/image/out_of_control = image('icons/misc/racing.dmi',"broken")
		src.overlays += out_of_control

		playsound(src, 'sound/mksounds/cpuspin.ogg', 33, 0)

		SPAWN(magnitude+1)
			cant_control = 0
			dir_original = 0
			set_density(1)
			src.overlays -= out_of_control

		SPAWN(0)
			for(var/i=0, i<magnitude, i++)
				src.set_dir(turn(src.dir, 90))
				sleep(0.1 SECONDS)
		return

	proc/boost()
		speed = base_speed - turbo
		drive(dir, speed)

//		if(istype(src,/obj/racing_clowncar)) //what the fuck? src is a power up, why would it be a clown car
		icon_state = "clowncar_boost"
		SPAWN(5 SECONDS)
			speed = base_speed
			if (driving) drive(dir, speed)
			icon_state = "clowncar"

//		else
//			R.overlays += image('icons/mob/robots.dmi', "up-speed")
//			SPAWN(5 SECONDS)
//				R.speed = R.base_speed
//				if (R.driving) R.drive(R.dir, 2)
//				R.overlays -= image('icons/mob/robots.dmi', "up-speed")

	proc/drive(var/direction, var/speed)
		set_dir(direction)
		driving = 1
		src.glide_size = (32 / speed) * world.tick_lag
		walk(src, dir, speed)

	proc/stop()
		driving = 0
		playsound(src, 'sound/mksounds/skidd.ogg', 25, 0)
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
			boutput(usr, "<span class='alert'>Car already occupied by [driver.name].</span>")
			return

		var/mob/M = usr

		M.set_loc(src)
		driver = M
		layer = MOB_EFFECT_LAYER
		overlays += driver
		update()
		if(powerup && !(powerup in driver.client.screen))
			driver.client.screen += powerup

		name = "[driver.name]'s Go-Kart"
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
			if(driver.client)
				if(powerup && (powerup in driver.client.screen))
					driver.client.screen -= powerup
		overlays = null
		name = "Go-Kart"
		driver = null
		driving = 0
		layer = OBJ_LAYER
		update()

	proc/update()
		if(!driver)
			overlays = null
			icon_state = "kart_blue_u"
		else
			icon_state = "kart_blue"

	proc/returntoline()
		if(returnloc)
			set_loc(returnloc)
			set_dir(returndir)

/obj/racing_clowncar/kart/red

	update()
		if(!driver)
			overlays = null
			icon_state = "kart_red_u"
		else
			icon_state = "kart_red"
