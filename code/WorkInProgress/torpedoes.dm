/obj/torpedo/explosive
	name = "explosive torpedo"
	icon_state_on_tray = "missileintray"
	icon_state_off_tray = "missilenotray"
	icon_state_fired = "missilefired"

	explode()
		new/obj/effect/supplyexplosion(src.loc)
		explosion_new(src, src.loc, 20)
		var/turf/T = get_turf(src)
		if (T)
			for (var/mob/living/carbon/human/M in view(src, 2))
				if (istype(M.wear_suit, /obj/item/clothing/suit/armor))
					boutput(M, "<span class='alert'>Your armor blocks the shrapnel!</span>")
					M.TakeDamage("chest", 5, 0)
				else
					M.TakeDamage("chest", 15, 0)
					var/obj/item/implant/projectile/shrapnel/implanted = new /obj/item/implant/projectile/shrapnel(M)
					implanted.owner = M
					M.implant += implanted
					implanted.implanted(M, null, 2)
					boutput(M, "<span class='alert'>You are struck by shrapnel!</span>")
					if (!M.stat)
						M.emote("scream")
		qdel(src)
		return

/obj/torpedo/hiexplosive
	name = "high explosive torpedo"
	icon_state_on_tray = "torped_hiexp_tray"
	icon_state_off_tray = "torped_hiexp_notray"
	icon_state_fired = "torped_hiexp_fired"
	numPierce = 0 //Max amount of steps that can pierce before it blows up instantly.
	stepsAfterPierce = 12 //Will blow up this many steps after first pierce at most.
	sleepPerStep = 2 //How long to sleep between steps.

	explode()
		new/obj/effect/supplyexplosion(src.loc)
		explosion_new(src, src.loc, 100)
		qdel(src)
		return

/obj/torpedo/incendiary
	name = "incendiary torpedo"
	icon_state_on_tray = "torped_incend_tray"
	icon_state_off_tray = "torped_incend_notray"
	icon_state_fired = "torped_incend_fired"

	explode()
		new/obj/effect/supplyexplosion(src.loc)
		tfireflash(src, 8, 9800, 0)
		qdel(src)
		return

/obj/torpedo/toxic
	name = "toxic torpedo"
	icon_state_on_tray = "torped_toxic_tray"
	icon_state_off_tray = "torped_toxic_notray"
	icon_state_fired = "torped_toxic_fired"

	explode()
		var/datum/reagents/R = new /datum/reagents(50)
		R.my_atom = get_turf(src)
		R.add_reagent("sarin", 50)
		smoke_reaction(R, 7, get_turf(src))
		qdel(src)
		SPAWN_DBG(30 SECONDS) qdel(R)
		return

/obj/machinery/torpedo_tube/syndicate
	icon_state_tube = "mantagun_synd"
	icon_state_open = "launcherlidsynd"
	icon_state_closed = "basesynd"

/obj/machinery/torpedo_tube/left
	icon_state_tube = "mantagun_left"
	icon_state_open = "launcherlid"
	icon_state_closed = "base"

/obj/machinery/torpedo_tube/right
	icon_state_tube = "mantagun_right"
	icon_state_open = "launcherlid"
	icon_state_closed = "base"

/////////////////////////////BASE STUFF BELOW

/obj/torpedo_targeter
	name = ""
	desc = ""
	anchored = 1
	density = 0
	layer = 10
	alpha = 200
	event_handler_flags = IMMUNE_MANTA_PUSH

	var/image/trgImage = null
	var/obj/machinery/torpedo_console/master = null

	New(var/obj/machinery/torpedo_console/C)
		. = ..()
		master = C
		trgImage = image('icons/effects/effects.dmi', src, "target")
		return .


/obj/machinery/torpedo_console
	desc = ""
	name = "torpedo console"
	icon = 'icons/obj/32x64.dmi'
	icon_state = "periscope"
	anchored = 1.0
	appearance_flags = TILE_BOUND
	density = 1.0
	var/datum/movement_controller/torpedo_control/movement_controller
	var/id = "torp1"
	var/obj/machinery/torpedo_tube/tube = null
	var/mob/controller = null
	var/turf/target = null
	var/obj/torpedo_targeter/targeter = null
	var/list/validTrg = list()
	var/inUse = 0

	New()
		movement_controller = new(src)
		targeter = new(src.loc, src)
		return ..()

	get_movement_controller()
		return movement_controller

	attack_hand(mob/user as mob)
		if(src.controller && src.controller.loc != src)
			src.exit(0)

		if(inUse) return

		if(tube == null)
			for(var/atom/A in range(10, src))
				if(istype(A, /obj/machinery/torpedo_tube))
					var/obj/machinery/torpedo_tube/T = A
					if(T.id == src.id)
						tube = T
						break
			resetTargeter()

		if(tube)
			inUse = 1
			user.set_loc(src)
			user.pixel_y = -8
			boutput(user, "<span class='hint'><b>Press Q or E to exit targeting.</b></span>")
			vis_contents += user
			controller = user
			user.reset_keymap()
			if(user.client && targeter)
				user.client.images += targeter.trgImage
				user.client.eye = targeter
		return

	proc/resetTargeter()
		if(tube && targeter)
			var/turf/start = tube.getLaunchTurf()
			start = get_steps(start, tube.dir, 3)
			targeter.set_loc(start)
		return

	proc/moveTarget(direction)
		var/width = 5
		var/height = 10
		if(tube && targeter)
			if(!validTrg.len)
				var/turf/start = get_steps(tube.getLaunchTurf(), tube.dir, 3)
				validTrg = block(locate(start.x - width, start.y, start.z), locate(start.x + width, start.y + height, start.z))
			var/turf/newTurf = get_step(targeter, direction)
			if(newTurf in validTrg)
				targeter.set_loc(get_step(targeter, direction))
				tube.targetTurf = targeter.loc
		return

	proc/exit(var/set_location = 1)
		if(controller)
			controller.pixel_y = 0
			if(set_location)
				controller.set_loc(get_step(src, SOUTH))
			vis_contents.Cut()
			controller.reset_keymap()
			if(controller.client && targeter)
				controller.client.images -= targeter.trgImage
				controller.client.eye = controller
			controller = null
			inUse = 0
		return

	proc/fire()
		tube?.launch()
		return

/obj/machinery/torpedo_switch
	desc = ""
	name = "torpedo button"
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	anchored = 1.0
	var/id = "torp1"
	var/list/cachedTubes = list()

	attack_hand()
		if(!cachedTubes.len)
			for(var/atom/A in range(10, src))
				if(istype(A, /obj/machinery/torpedo_tube))
					var/obj/machinery/torpedo_tube/T = A
					if(T.id == src.id)
						cachedTubes.Add(T)
		for(var/obj/machinery/torpedo_tube/T in cachedTubes)
			T.launch()
		return

/obj/machinery/torpedo_tube
	name = "torpedo tube"
	desc = ""
	icon = 'icons/obj/32x96.dmi'
	icon_state = "base"
	density = 1
	anchored = 1
	layer = 2

	var/icon_state_tube = "mantagun_left"
	var/icon_state_open = "launcherlid"
	var/icon_state_closed = "base"

	var/image/tube = null
	var/image/light = null
	var/image/tray = null

	var/atom/movable/loaded = null
	var/obj/torpedo_tray/tray_obj = null

	var/id = "torp1"

	var/turf/targetTurf = null

	bound_height = 96

	New()
		. =..()
		light = image('icons/obj/32x96.dmi')

		tray = image('icons/obj/32x96.dmi')
		tray.pixel_y = -16

		tube = image('icons/obj/32x96.dmi',icon_state_tube)
		tube.pixel_y = 16
		underlays.Add(tube)

		SPAWN_DBG(1 SECOND) //You might wonder what is going on here. IF I DON'T SPAWN THIS THE DIRECTION IS NOT SET IS WHAT'S GOING ON HERE.
			set_dir(NORTH)

		rebuildOverlays()
		return .

	attack_hand(mob/user as mob)
		if(tray_obj) close()
		else open()
		return

	proc/getLaunchTurf()
		return get_steps(src, src.dir, 3)

	proc/rebuildOverlays()
		overlays.Cut()

		if(tray_obj)
			icon_state = icon_state_open
			tray.icon_state = "door-open"
			light.icon_state = "empty"
		else
			icon_state = icon_state_closed
			tray.icon_state = "empty"
			if(loaded) light.icon_state = "light-green"
			else light.icon_state = "light-red"

		overlays.Add(tray)
		overlays.Add(light)
		return

	proc/open()
		if(is_blocked_turf(get_step(src, SOUTH)))
			boutput(usr, "<span class='alert'><b>You can't open the tube, something is blocking the way.</b></span>")
			return
		tray_obj = new/obj/torpedo_tube_tray(get_step(src, SOUTH))
		tray_obj.parent = src
		if(loaded)
			loaded.set_loc(tray_obj.loc)
			loaded = null
		rebuildOverlays()
		return

	proc/close()
		for(var/atom/movable/M in get_turf(tray_obj))
			if(!ismob(M) && !istype(M, /obj/torpedo) && !istype(M, /obj/storage/closet/coffin)) continue
			M.set_loc(src)
			loaded = M
			break

		qdel(tray_obj)
		tray_obj = null
		rebuildOverlays()
		return

	proc/launch()
		if(tray_obj) return
		if(loaded != null)

			logTheThing("combat", usr, null, " launches \a [src.loaded] from the torpedo tube at [showCoords(src.x, src.y, src.z)]")
			logTheThing("diary", usr, null, " launches \a [src.loaded] from the torpedo tube at [showCoords(src.x, src.y, src.z)]", "combat")
			var/turf/start = getLaunchTurf()
			var/atom/target
			if(targetTurf)
				target = targetTurf
			else
				target = get_edge_target_turf(src, src.dir)

			if(ismob(loaded))
				var/mob/M = loaded
				M.set_loc(start)
				M.set_dir(src.dir)
				M.throw_at(target, 600, 2)


			else if(istype(loaded, /obj/storage/closet))
				var/obj/storage/closet/C = loaded
				C.set_loc(start)
				C.set_dir(src.dir)
				C.throw_at(target, 600, 2)

			else if(istype(loaded, /obj/torpedo))
				var/obj/torpedo/T = loaded
				T.set_loc(start)
				T.set_dir(src.dir)
				T.lockdir = src.dir
				T.fired = 1
				SPAWN_DBG(0)
					T.launch(target)

			loaded = null
			rebuildOverlays()
		return

	relaymove(mob/user, direction)
		if(tray_obj == null) open()
		return ..()

/obj/torpedo_tube_tray
	name = "torpedo tube tray"
	desc = ""
	icon = 'icons/obj/32x64.dmi'
	icon_state = "tray"
	dir = NORTH
	density = 1
	anchored = 1
	pixel_y = 0
	layer = 2.1
	var/obj/machinery/torpedo_tube/parent = null

	attack_hand(mob/living/carbon/human/M as mob)
		parent?.close()
		return

	MouseDrop_T(atom/target, mob/user)
		if(ismob(target) && get_dist(src,target) <= 1 && can_act(usr) && can_reach(usr, src) && can_reach(usr, target))
			if (istype(target, /obj/storage/closet) && get_dist(src,target) <= 1 && can_act(usr) && can_reach(usr, src) && can_reach(usr, target))
				var/obj/storage/closet/O = target
				O.set_loc(src.loc)
				logTheThing("combat", usr, null, " loads \a [O] into \the [src] at [showCoords(src.x, src.y, src.z)]")
				logTheThing("diary", usr, null, " loads \a [O] into \the [src] at [showCoords(src.x, src.y, src.z)]", "combat")
			var/mob/M = target
			if (ishuman(M))
				M.setStatus("resting", INFINITE_STATUS)
				M.force_laydown_standup()
				M.set_loc(src.loc)
				logTheThing("combat", user, target, " laods [constructTarget(target,"combat")] onto \the [src] at [showCoords(user.x, user.y, user.z)]")
				logTheThing("diary", user, target, " laods [constructTarget(target,"diary")] onto \the [src] at [showCoords(user.x, user.y, user.z)]", "combat")
				user.visible_message("<span class='alert'><b>[user.name] shoves [target.name] onto [src]!</b></span>")
			else
				M.set_loc(src.loc)
				logTheThing("combat", usr, target, " loads [constructTarget(target,"combat")] into \the [src] at [showCoords(src.x, src.y, src.z)]")
				logTheThing("diary", usr, target, " loads [constructTarget(target,"diary")] into \the [src] at [showCoords(src.x, src.y, src.z)]", "combat")
				user.visible_message("<span class='alert'><b>[user.name] shoves [target.name] onto \the [src]!</b></span>")
				return

	attackby(var/obj/item/I, var/mob/user)
		var/obj/item/grab/G = I
		if(istype(G))	// handle grabbed mob
			if (ismob(G.affecting))
				var/mob/GM = G.affecting
				GM.set_loc(src.loc)
				GM.setStatus("resting", INFINITE_STATUS)
				GM.force_laydown_standup()
				user.visible_message("<span class='alert'><b>[user.name] shoves [GM.name] onto [src]!</b></span>")
				logTheThing("combat", usr, GM, " loads [constructTarget(GM,"combat")] into \the [src] at [showCoords(src.x, src.y, src.z)]")
				logTheThing("diary", usr, GM, " loads [constructTarget(GM,"diary")] into \the [src] at [showCoords(src.x, src.y, src.z)]", "combat")
				qdel(G)
		else
			return ..(I,user)

/obj/torpedo_tray
	name = "torpedo tray"
	desc = "A tray for wheeling around torpedos."
	icon = 'icons/obj/32x64.dmi'
	icon_state = "emptymissiletray"
	density = 1
	pixel_y = 0
	layer = 4
	throwforce = 50
	p_class = 1.5
	var/obj/machinery/torpedo_tube/parent = null
	var/obj/torpedo/loaded = null
	var/icon/northsouth = null
	var/icon/eastwest = null
	var/lastdir = null

	New()
		northsouth = icon('icons/obj/32x64.dmi')
		eastwest = icon('icons/obj/64x32.dmi')
		changeIcon()
		..()

	Bump(atom/O)
		. = ..()
		changeIcon(1)
		return .

	get_desc()
		if (loaded)
			return " It's carrying \a [loaded]."

	proc/changeIcon(var/rebuildOverlays = 0)
		if(dir == NORTH || dir == SOUTH)
			icon = northsouth
			pixel_y = -16
			pixel_x = 0
			layer = (dir == NORTH ? 4 : 3)
		else if(dir == EAST || dir == WEST)
			icon = eastwest
			pixel_x = -16
			pixel_y = 0
			layer = 3

		overlays.Cut()
		if(loaded)
			overlays.Add(image(((dir == NORTH || dir == SOUTH) ? northsouth : eastwest), null, loaded.icon_state_on_tray))
		return

	Move(NewLoc,Dir=0,step_x=0,step_y=0)
		if(..(NewLoc, Dir, step_x, step_y))
			if(dir != lastdir)
				if(dir == NORTHEAST || dir == SOUTHWEST || dir == SOUTHEAST || dir == NORTHWEST)
					set_dir(lastdir)
					changeIcon()
				else
					lastdir = dir
					changeIcon()
			return TRUE

	set_loc(var/newloc as turf|mob|obj in world)
		..(newloc)
		changeIcon()

	attackby(var/obj/item/I as obj, var/mob/user as mob)
		if(loaded) return loaded.attackby(I, user)
		else return ..()

	proc/add(var/obj/torpedo/T)
		if(loaded) return
		if(!can_act(usr) || !can_reach(usr, src) || !can_reach(usr, T)) return
		T.set_loc(src)
		src.loaded = T
		changeIcon()
		return

	proc/remove(var/turf/target, var/direction = null)
		if(loaded == null) return
		if(!can_act(usr) || !can_reach(usr, src) || !can_reach(usr, target)) return
		var/obj/torpedo/T = loaded
		loaded = null
		T.set_dir((direction ? direction : src.dir))
		T.set_loc(target)
		changeIcon()
		return

	MouseDrop_T(target, mob/user)
		if(istype(target, /obj/torpedo) && loaded == null && get_dist(src,target) <= 1)
			add(target)
		return

	MouseDrop(atom/over_object,src_location,over_location,src_control,over_control,params)
		if(loaded && get_dist(src,over_object) <= 1)
			var/turf/T = get_turf(over_object)
			if(T.density) return
			var/atom/trg = over_object
			if(isturf(trg))
				remove(trg)
			else if(istype(trg, /obj/torpedo_tube_tray))
				remove(get_turf(over_object), trg.dir)

/obj/torpedo_tray/explosive_loaded
	icon = 'icons/obj/32x64.dmi'
	icon_state = "emptymissiletray"

	New()
		..()
		var/obj/torpedo/explosive/T = new/obj/torpedo/explosive
		src.loaded = T
		T.set_loc(src)
		changeIcon()
		return

/obj/torpedo_tray/hiexp_loaded
	icon = 'icons/obj/32x64.dmi'
	icon_state = "emptymissiletray"

	New()
		..()
		var/obj/torpedo/hiexplosive/T = new/obj/torpedo/hiexplosive
		src.loaded = T
		T.set_loc(src)
		changeIcon()
		return

/obj/torpedo_tray/incendiary_loaded
	icon = 'icons/obj/32x64.dmi'
	icon_state = "emptymissiletray"

	New()
		..()
		var/obj/torpedo/hiexplosive/T = new/obj/torpedo/incendiary
		src.loaded = T
		T.set_loc(src)
		changeIcon()
		return

/obj/torpedo_tray/toxic_loaded
	icon = 'icons/obj/32x64.dmi'
	icon_state = "emptymissiletray"

	New()
		..()
		var/obj/torpedo/hiexplosive/T = new/obj/torpedo/toxic
		src.loaded = T
		T.set_loc(src)
		changeIcon()
		return



/obj/torpedo
	name = "Torpedo"
	dir = NORTH
	icon_state = "missilenotray"
	density = 1
	anchored = 1
	throw_spin = 0
	layer = 5
	event_handler_flags = USE_FLUID_ENTER | IMMUNE_MANTA_PUSH

	var/lockdir = null

	var/fired = 0
	var/icon/northsouth = null
	var/icon/eastwest = null
	var/launched = 0

	var/icon_state_on_tray = "missileintray"
	var/icon_state_off_tray = "missilenotray"
	var/icon_state_fired = "missileinflight"

	var/dmg_threshold = 50
	var/dmg = 0

	var/numPierce = 0 //Max amount of steps that can pierce before it blows up instantly.
	var/stepsAfterPierce = 0 //Will blow up this many steps after first pierce at most.
	var/sleepPerStep = 2 //How long to sleep between steps.

	New()
		northsouth = icon('icons/obj/32x64.dmi')
		eastwest = icon('icons/obj/64x32.dmi')
		changeIcon()
		dmg_threshold = rand(20,60)
		..()

	attackby(var/obj/item/I as obj, var/mob/user as mob)
		..()
		logTheThing("combat", user, null, " hits [src] with [I] at [showCoords(user.x, user.y, user.z)]")
		logTheThing("diary", user, null, " hits [src] with [I] at [showCoords(user.x, user.y, user.z)]", "combat")
		dmg += I.force
		if(dmg >= dmg_threshold)
			logTheThing("combat", user, null, " caused [src] to detonate at [showCoords(user.x, user.y, user.z)]")
			logTheThing("diary", user, null, " caused [src] to detonate at [showCoords(user.x, user.y, user.z)]", "combat")
			breakLaunch()
		return

	proc/changeIcon()
		icon_state = (fired ? icon_state_fired : icon_state_off_tray)
		if(dir == NORTH || dir == SOUTH)
			icon = northsouth
			pixel_y = -16
			pixel_x = 0
			layer = (dir == NORTH ? 4 : 1)
		else if(dir == EAST || dir == WEST)
			icon = eastwest
			pixel_x = -16
			pixel_y = 0
			layer = 3
		return

	set_loc(var/newloc as turf|mob|obj in world)
		. = ..(newloc)
		if(lockdir) dir = lockdir
		changeIcon()

	proc/launch(var/atom/target)
		if(launched) return
		else launched = 1
		var/flying = 1
		playsound(get_turf(src), "sound/effects/torpedolaunch.ogg", 100, 1)
		src.changeIcon()
		var/aboutToBlow = 0
		var/steps = 0
		while(flying)
			if(target && target == src.loc) target = null
			var/turf/nextStep = null
			if(target != null && target.z == src.z) nextStep = get_step_towards(src,target)
			else nextStep = get_step(src, lockdir ? lockdir : dir)

			if(!nextStep || (nextStep.x == 0 && nextStep.y == 0 && nextStep.z == 0))
				flying = 0
				explode()
				return

			src.set_loc(nextStep)
			if(checkHit())
				if(numPierce > 0)
					numPierce--
					aboutToBlow = 1
				else
					flying = 0
					explode()
					return
			if(aboutToBlow && stepsAfterPierce-- <= 0)
				flying = 0
				explode()
				return
			steps++
			if(steps >= 600) explode()
			sleep(sleepPerStep)
		return

	proc/checkHit()
		var/turf/T = get_turf(src)
		if(T == null) return 0
		if(T.density) return 1
		else
			for(var/atom/movable/M in T)
				if(M == src) continue
				if(istype(M, /obj/machinery/the_singularity)) numPierce = 0 //detonate instantly on the singularity
				if(!M.CanPass(src, T)) return 1
				if(M.density) return 1
		return 0

	proc/breakLaunch()
		var/obj/torpedo_tray/T = src.loc
		if(istype(T))
			T.remove(get_turf(src))
		var/atom/target = get_edge_target_turf(src, src.dir)
		src.lockdir = src.dir
		src.fired = 1
		SPAWN_DBG(0)
			src.launch(target)
		return

	proc/explode()
		qdel(src)
		return
