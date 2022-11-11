/////////////////////////////
//      Deployer Code      //
/////////////////////////////

ABSTRACT_TYPE(/obj/item/turret_deployer)
/obj/item/turret_deployer
	name = "fucked up turret deployer that you shouldn't see"
	desc = "this isn't going to spawn anything and will also probably yell errors at you"
	icon = 'icons/obj/syndieturret.dmi'
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	var/damage_words = "mostly undamaged!"
	var/icon_tag = null
	var/quick_deploy_fuel = 0
	var/associated_turret = null //what kind of turret should this spawn?
	var/turret_health = 100

	New()
		..()
		icon_state = "[src.icon_tag]_deployer"

	get_desc()
		. = "<br><span class='notice'>It looks [damage_words]</span>"


	attack_self(mob/user as mob)
		if(istype(get_area(src), /area/sim/gunsim))
			boutput(user, "You can't deploy the turret here!")
			return
		user.show_message("You assemble the turret parts.")
		src.set_loc(get_turf(user))
		src.spawn_turret(user.dir)
		user.u_equip(src)
		src.set_loc(get_turf(user))
		qdel(src)

	proc/spawn_turret(var/direct)
		var/obj/deployable_turret/turret = new src.associated_turret(src.loc, direct)
		turret.health = src.turret_health // NO FREE REPAIRS, ASSHOLES
		turret.damage_words = src.damage_words
		turret.quick_deploy_fuel = src.quick_deploy_fuel
		return turret

	throw_end(list/params, turf/thrown_from)
		if(istype(get_area(src), /area/sim/gunsim))
			boutput(usr, "You can't deploy the turret here!")
			return
		if(src.quick_deploy_fuel > 0)
			var/turf/thrown_to = get_turf(src)
			var/spawn_direction = get_dir(thrown_to,thrown_from)
			var/obj/deployable_turret/turret = src.spawn_turret(spawn_direction)
			turret.set_angle(get_angle(thrown_from,thrown_to))
			turret.quick_deploy()
			qdel(src)

/obj/item/turret_deployer/syndicate
	name = "NAS-T Deployer"
	desc = "A Nuclear Agent Sentry Turret Deployer. Use it in your hand to deploy."
	turret_health = 250
	icon_tag = "st"
	quick_deploy_fuel = 2
	associated_turret = /obj/deployable_turret/syndicate

	New()
		..()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

/obj/item/turret_deployer/riot
	name = "N.A.R.C.S. Deployer"
	desc = "A Nanotrasen Automatic Riot Control System Deployer. Use it in your hand to deploy."
	turret_health = 125
	icon_state = "st_deployer"
	w_class = W_CLASS_BULKY
	icon_tag = "nt"
	mats = list("INS-1"=10, "CON-1"=10, "CRY-1"=3, "MET-2"=2)
	is_syndicate = 1
	associated_turret = /obj/deployable_turret/riot

/////////////////////////////
//       Turret Code       //
/////////////////////////////
ABSTRACT_TYPE(/obj/deployable_turret)
/obj/deployable_turret

	name = "fucked up abstract turret that should never exist"
	desc = "why did you do this"
	icon = 'icons/obj/syndieturret.dmi'
	anchored = 0
	density = 1
	var/health = 250
	var/max_health = 250
	var/list/mob/living/target_list = list()
	var/mob/living/target = null
	var/wait_time = 20 //wait if it can't find a target
	var/range = 7 // tiles
	var/internal_angle = 0 // used for the matrix transforms
	var/external_angle = 180 // used for determining target validity
	var/projectile_type = null
	var/datum/projectile/current_projectile
	var/burst_size = 3 // number of shots to fire. Keep in mind the bullet's shot_count
	var/fire_rate = 3 // rate of fire in shots per second
	var/angle_arc_size = 45
	var/active = 0 // are we gonna shoot some peeps?
	var/damage_words = "mostly undamaged!"
	var/waiting = 0 // tracks whether or not the turret is waiting
	var/shooting = 0 // tracks whether we're currently in the process of shooting someone
	var/icon_tag = null //tag for icons to get correct states on activating/deactivating. 'st' for syndicate, 'nt' for NT
	var/quick_deploy_fuel = 2 // number of quick deploys the turret has left
	var/spread = 0
	var/associated_deployer = null //what kind of turret deployer should this deconstruct to?
	var/deconstructable = TRUE

	New(var/loc, var/direction)
		..()
		src.set_dir(direction || src.dir) // don't set the dir if we weren't passed one
		src.set_initial_angle()

		src.icon_state = "[src.icon_tag]_base"
		src.appearance_flags |= RESET_TRANSFORM
		src.underlays += src
		src.appearance_flags &= ~RESET_TRANSFORM
		src.icon_state = "[src.icon_tag]_off"
		src.appearance_flags |= PIXEL_SCALE

		var/matrix/M = matrix()
		src.transform = M.Turn(src.external_angle)
		processing_items |= src
		if(active)
			set_projectile()

		#ifdef LOW_SECURITY
		START_TRACKING_CAT(TR_CAT_DELETE_ME)
		#endif

	disposing()
		processing_items.Remove(src)
		..()


	get_desc(dist)
		. = "<br><span class='notice'>It looks [src.damage_words]. It is [src.anchored ? "secured to" : "unsecured from"] the floor and powered [src.active ? "on" : "off"].</span>"

	proc/set_initial_angle()
		switch(src.dir)
			if(NORTH)
				src.external_angle = (0)
			if(NORTHEAST)
				src.external_angle = (45)
			if(EAST)
				src.external_angle = (90)
			if(SOUTHEAST)
				src.external_angle = (135)
			if(SOUTH)
				src.external_angle = (180)
			if(SOUTHWEST)
				src.external_angle = (225)
			if(WEST)
				src.external_angle = (270)
			if(NORTHWEST)
				src.external_angle = (315)
			else
				src.external_angle = (180) // how did you get here?

	proc/set_projectile()
		current_projectile = new projectile_type
		current_projectile.shot_number = burst_size
		current_projectile.shot_delay = 10/fire_rate

	proc/process()
		if(src.active)
			if(!src.target && !src.seek_target()) //attempt to set the target if no target
				return
			if(!src.target_valid(src.target)) //check valid target
				src.icon_state = "[src.icon_tag]_idle"
				src.target = null
				return
			else //GUN THEM DOWN
				if(src.target)
					SPAWN(0)
						for(var/i in 1 to src.current_projectile.shot_number) //loop animation until finished
							flick("[src.icon_tag]_fire",src)
							muzzle_flash_any(src, 0, "muzzle_flash")
							sleep(src.current_projectile.shot_delay)
					shoot_projectile_ST_pixel_spread(src, current_projectile, target, 0, 0 , spread)


	attackby(obj/item/W, mob/user)
		user.lastattacked = src
		if (isweldingtool(W) && !(src.active))
			if(!W:try_weld(user, 1))
				return

			user.show_message(src.anchored ? "You start to unweld the turret from the floor." : "You start to weld the turret to the floor.")
			SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, .proc/toggle_anchored, null, W.icon, W.icon_state, \
			  src.anchored ? "[user] unwelds the turret from the floor." : "[user] welds the turret to the floor.", \
			  INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)

		else if (isweldingtool(W) && (src.active))
			if (src.health >= max_health)
				user.show_message("<span class='notice'>The turret is already fully repaired!.</span>")
				return

			if(!W:try_weld(user, 1))
				return

			user.show_message("You start to repair the turret.")
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, .proc/repair, null, W.icon, W.icon_state, \
			  "[user] repairs some of the turret's damage.", \
			  INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)

		else if  (iswrenchingtool(W))

			if(src.anchored)

				user.show_message("<span class='notice'>Click where you want to aim the turret!</span>")
				var/datum/targetable/deployable_turret_aim/A = new()
				user.targeting_ability = A
				user.update_cursor()
				A.my_turret = src
				A.user_turf = get_turf(user)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)

			else
				user.show_message("You begin to disassemble the turret.")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, .proc/spawn_deployer, null, W.icon, W.icon_state, \
				  "[user] disassembles the turret.", \
				  INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)

		else if (isscrewingtool(W))

			if(!src.anchored)
				user.show_message("<span class='notice'>The turret is too unstable to fire! Secure it to the ground with a welding tool first!</span>")
				return

			if (!src.deconstructable)
				user.show_message("<span class='alert'>You can't power the turret off! The controls are too secure!</span>")
				return

			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)

			SETUP_GENERIC_ACTIONBAR(user, src, 1 SECOND, .proc/toggle_activated, null, W.icon, W.icon_state, \
			  "[user] powers the turret [src.active ? "off" : "on"].", \
			  INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)

		else
			src.health = src.health - W.force
			playsound(get_turf(src), 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 25, 1)
			attack_particle(user,src)
			src.check_health()
			..()

	//actionbar procs
	///Anchor if unanchored, unanchor if anchored
	proc/toggle_anchored()
		src.anchored = !src.anchored

	///Repair the turret by 10 health (only repaired by welding currently, so no custom values)
	proc/repair()
		src.health = min(src.max_health, (src.health + 10))
		src.check_health()

	///Toggle the turret on or off.
	proc/toggle_activated()
		if (src.active)
			src.icon_state = "[src.icon_tag]_off"
			src.active = 0
			src.shooting = 0
			src.waiting = 0
			src.target = null
		else
			src.set_projectile()
			src.active = 1
			src.icon_state = "[src.icon_tag]_idle"

	proc/quick_deploy()
		if(!(src.quick_deploy_fuel > 0))
			return
		src.quick_deploy_fuel--
		src.visible_message("<span class='alert'>[src]'s quick deploy system engages, automatically securing it!</span>")
		playsound(src.loc, 'sound/items/Welder2.ogg', 30, 1)
		set_projectile()
		src.anchored = 1
		src.active = 1
		src.icon_state = "[src.icon_tag]_idle"

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round((P.power*P.proj_data.ks_ratio), 1.0)
		if (damage < 1)
			return
		src.health = src.health - max(P.power/2,0) // staples have a power of 5, .22 bullets have a power of 35
		src.check_health()

	proc/check_health()
		if(src.health <= 0)
			src.active = 0
			src.shooting = 0
			src.waiting = 0
			src.target = null
			src.die()

		var/percent_damage = src.health/src.max_health * 100
		switch(percent_damage)
			if(90 to 100)
				damage_words = "mostly undamaged!"
			if(75 to 89)
				damage_words = "a little bit damaged."
			if(30 to 74)
				damage_words = "pretty beaten up."
			if(0 to 29)
				damage_words = "to be on the verge of falling apart!"

	proc/die()
		playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 50, 1)
		new /obj/decal/cleanable/robot_debris(src.loc)
		qdel(src)

	proc/spawn_deployer()
		var/obj/item/turret_deployer/deployer = new src.associated_deployer(src.loc)
		deployer.turret_health = src.health // NO FREE REPAIRS, ASSHOLES
		deployer.damage_words = src.damage_words
		deployer.quick_deploy_fuel = src.quick_deploy_fuel
		deployer.tooltip_rebuild = 1
		qdel(src)
		return deployer

	proc/seek_target()
		src.target_list = list()
		for (var/mob/living/C in mobs)
			if(!src)
				break

			if (!isnull(C) && src.target_valid(C))
				src.target_list += C
				var/distance = GET_DIST(C.loc,src.loc)
				src.target_list[C] = distance

			else
				continue

		if (src.target_list.len>0)
			var/min_dist = 99999

			for (var/mob/living/T in src.target_list)
				if (src.target_list[T] < min_dist)
					src.target = T
					min_dist = src.target_list[T]

			src.icon_state = "[src.icon_tag]_active"

			playsound(src.loc, 'sound/vox/woofsound.ogg', 40, 1)

		return src.target

	proc/target_valid(var/mob/living/C)
		var/distance = GET_DIST(get_turf(C),get_turf(src))

		if(distance > src.range)
			return 0
		if (!C)
			return 0
		if(!isliving(C) || isintangible(C))
			return 0
		if (C.health < 0)
			return 0
		if (C.stat == 2)
			return 0
		for(var/atom/movable/some_loc in obj_loc_chain(C))
			if(istype(some_loc, /obj/item)) // prevent shooting at pickled people and such
				return 0
		if (istype(C,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			if (H.hasStatus(list("resting", "weakened", "stunned", "paralysis"))) // stops it from uselessly firing at people who are already suppressed. It's meant to be a suppression weapon!
				return 0
		if (is_friend(C))
			return 0

		var/angle = get_angle(get_turf(src),get_turf(C))


		var/anglemod = (-(angle < 180 ? angle : angle - 360) + 90) //Blatant Code Theft from showLine(), checks to see if there's something in the way of us and the target
		var/crossed_turfs = list()
		crossed_turfs = castRay(src,anglemod,distance)
		for (var/turf/T in crossed_turfs)
			if (T.opacity == 1)
				return 0
			if (T.density == 1)
				return 0

		angle = angle < 0 ? angle+360 : angle // make angles positive
		angle = angle - src.external_angle

		if (angle > 180) // rotate angle and convert into absolute terms from 0, where 0 is the seek-arc midpoint
			angle = abs(360-angle)
		else if (angle < -180)
			angle = abs(360+angle)
		else
			angle = abs(angle)

		if (angle <= (angle_arc_size/2)) //are we in the seeking arc?
			return 1
		return 0


	proc/is_friend(var/mob/living/C) //tried to keep this generic in case you want to make a turret that only shoots monkeys or something
		return null

	proc/set_angle(var/angle)
		angle = angle > 0 ? angle%360 : -((-angle)%360)+360 //limit user input to a sane range!
		var/angle_diff = angle - src.external_angle
		var/new_internal_angle = src.internal_angle + angle_diff

		new_internal_angle = new_internal_angle > 0 ? new_internal_angle%360 : -((-new_internal_angle)%360)+360 //limit user input to a sane range!

		src.animate_turret_turn(src.internal_angle,new_internal_angle)

		src.internal_angle = new_internal_angle
		src.external_angle = angle


	proc/animate_turret_turn(var/curr_ang,var/new_ang)
		var/ang = (new_ang - curr_ang)
		if (abs(ang) > 180) // stops funky turret moving where it flips the long way around
			ang = ang > 0 ? ang - 360 : ang + 360

		var/matrix/transform_original = src.transform
		animate(src, transform = matrix(transform_original, ang/3, MATRIX_ROTATE | MATRIX_MODIFY), time = 10/3, loop = 0) //blatant code theft from throw_at proc
		animate(transform = matrix(transform_original, ang/3, MATRIX_ROTATE | MATRIX_MODIFY), time = 10/3, loop = 0) // needs to do in multiple steps because byond takes shortcuts
		animate(transform = matrix(transform_original, ang/3, MATRIX_ROTATE | MATRIX_MODIFY), time = 10/3, loop = 0) // :argh:


/obj/deployable_turret/syndicate
	name = "NAS-T"
	desc = "A Nuclear Agent Sentry Turret."
	projectile_type = /datum/projectile/bullet/akm
	icon_tag = "st"
	associated_deployer = /obj/item/turret_deployer/syndicate

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	is_friend(var/mob/living/C)
		return istype(C.get_id(), /obj/item/card/id/syndicate) || istype(C, /mob/living/critter/robotic/gunbot/syndicate) //dumb lazy

/obj/deployable_turret/syndicate/active
	anchored = 1

	New(loc)
		..(src.loc, src.dir)
		src.toggle_activated()

/obj/deployable_turret/riot
	name = "N.A.R.C.S."
	desc = "A Nanotrasen Automatic Riot Control System."
	health = 125
	max_health = 125
	range = 5
	projectile_type = /datum/projectile/bullet/abg
	burst_size = 1
	fire_rate = 1
	angle_arc_size = 60
	icon_tag = "nt"
	quick_deploy_fuel = 0
	associated_deployer = /obj/item/turret_deployer/riot

	is_friend(var/mob/living/C)
		var/obj/item/card/id/I = C.get_id()
		if(!istype(I))
			return 0
		switch(I.icon_state)
			if("id_sec")
				return 1
			if("id_com")
				return 1
			if("gold")
				return 1
			else
				return 0

/obj/deployable_turret/riot/active
	anchored = 1

	New(loc)
		..(src.loc, src.dir)
		src.toggle_activated()

/////////////////////////////
//   Turret Ability Stuff  //
/////////////////////////////

/datum/targetable/deployable_turret_aim
	name = "Turret Aim"
	desc = "You are aiming a turret"
	cooldown = 0
	targeted = 1
	target_anything = 1
	max_range = 3000
	var/obj/deployable_turret/my_turret = null
	var/turf/user_turf = null

	castcheck(var/mob/M)
		if (M.client && M.client.holder)
			return 1

	handleCast(var/atom/target)

		var/mob/M = usr

		if (istype(M))

			if(!iswrenchingtool(M.equipped()))
				boutput(M, "<span class='alert'>You need to be holding a wrench or similar to modify the turret's facing.</span>")
				return

			if (!my_turret.deconstructable)
				boutput(M, "<span class='alert'>You can't modify this turret's facing- it's bolted in place!</span>")
				return

			if(!(get_turf(usr) == src.user_turf))
				return

			if(target == my_turret)
				return

			if (!istype(target,/turf))
				target = get_turf(target)

			if(target == get_turf(my_turret))
				return

			SPAWN(0)
				src.my_turret.set_angle(get_angle(my_turret,target))

			return 0

/////////////////////////////
//       User Manuals      //
/////////////////////////////

/obj/item/paper/nast_manual
	name = "paper- 'Nuclear Agent Sentry Turret Manual'"
	info = {"<h4>Nuclear Agent Sentry Turret Manual</h4>
	Congratulations, on your purchase of a Nuclear Agent Sentry Turret!<br>
	This a turret that fires at non-syndicate threats in a 30 degree arc.<br>
	Press its deploy button while it is your hand to deploy it.<br>
	The turret will start out facing the direction you are facing.<br>
	If the turret is unsecured, wrenching it will disassemble it.<br>
	Weld it to the floor to secure it.<br>
	While secured, using a screwdriver on the turret will turn it on, and using a wrench on it will set the angle.<br>
	Setting the angle will bring up a prompt to choose a target. Direct the turret to a sightline by pointing at it.<br>
	Welding the turret while it is active will allow you to perform repairs.<br>
	This turret is equipped with two quick-deploy charges installed.<br>
	When thrown, one quick-deploy charge will be used, automatically securing and activating the turret.<br>
	The quick-deployed turret will point in the direction it was thrown."}

/obj/item/paper/narcs_manual
	name = "paper- 'Nanotrasen Automatic Riot Control System'"
	info = {"<h4>Nanotrasen Automatic Riot Control System</h4>
	Congratulations, on your purchase of a Nanotrasen Automatic Riot Control System!<br>
	This a turret that fires at non-security and non-command threats in a 60 degree arc.<br>
	Press its deploy button while it is your hand to deploy it.<br>
	The turret will start out facing the direction you are facing.<br>
	If the turret is unsecured, wrenching it will disassemble it.<br>
	Weld it to the floor to secure it.<br>
	While secured, using a screwdriver on the turret will turn it on, and using a wrench on it will set the angle.<br>
	Setting the angle will bring up a prompt to choose a target. Direct the turret to a sightline by pointing at it.<br>
	Welding the turret while it is active will allow you to perform repairs.<br>"}
