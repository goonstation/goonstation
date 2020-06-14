/////////////////////////////
//      Deployer Code      //
/////////////////////////////

/obj/item/turret_deployer
	name = "NAS-T Deployer"
	desc = "A Nuclear Agent Sentry Turret Deployer. Use it in your hand to deploy."
	icon = 'icons/obj/syndieturret.dmi'
	icon_state = "st_deployer"
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3
	health = 100
	//var/emagged = 0 removing all emag stuff because it's a bad idea in retrospect
	var/damage_words = "fully operational!"
	var/icon_tag = "st"
	var/quick_deploy_fuel = 2

	New()
		..()
		icon_state = "[src.icon_tag]_deployer"

	get_desc(dist)
		. = "<br><span class='notice'>It looks [damage_words]</span>"


	attack_self(mob/user as mob)
		user.show_message("You assemble the turret parts.")
		src.loc = get_turf(user)
		src.spawn_turret(user.dir)
		user.u_equip(src)
		src.loc = get_turf(user)
		qdel(src)

	proc/spawn_turret(var/direct)
		var/obj/deployable_turret/turret = new /obj/deployable_turret(src.loc,direction=direct)
		turret.health = src.health // NO FREE REPAIRS, ASSHOLES
		//turret.emagged = src.emagged
		turret.damage_words = src.damage_words
		turret.quick_deploy_fuel = src.quick_deploy_fuel
		return turret

	/*
	emag_act(var/user, var/emag)
		if(src.emagged)
			return
		src.emagged = 1
		boutput(user,"You short out the safeties on the turret.")
		src.damage_words += "<br><span class='alert'>Its safety indicator is off!</span>"
	*/

	throw_at(atom/target, range, speed, list/params, turf/thrown_from, throw_type = 1, allow_anchored = 0)
		..()
		if(src.quick_deploy_fuel > 0)
			var/turf/thrown_to = get_turf(src)
			var/spawn_direction = get_dir(thrown_to,thrown_from)
			var/obj/deployable_turret/turret = src.spawn_turret(spawn_direction)
			turret.set_angle(get_angle(thrown_from,thrown_to))
			turret.quick_deploy()
			qdel(src)



/////////////////////////////
//       Turret Code       //
/////////////////////////////

/obj/deployable_turret

	name = "NAS-T"
	desc = "A Nuclear Agent Sentry Turret."
	icon = 'icons/obj/syndieturret.dmi'
	icon_state = "st_off"
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
	var/projectile_type = /datum/projectile/bullet/ak47
	var/datum/projectile/current_projectile
	var/burst_size = 3 // number of shots to fire. Keep in mind the bullet's shot_count
	var/fire_rate = 3 // rate of fire in shots per second
	var/angle_arc_size = 45
	var/active = 0 // are we gonna shoot some peeps?
	//var/emagged = 0
	var/damage_words = "fully operational!"
	var/waiting = 0 // tracks whether or not the turret is waiting
	var/shooting = 0 // tracks whether we're currently in the process of shooting someone
	var/icon_tag = "st"
	var/quick_deploy_fuel = 2 // number of quick deploys the turret has left
	var/spread = 0

	New(var/direction)
		..()
		src.dir = direction
		src.set_initial_angle()

		src.icon_state = "[src.icon_tag]_base"
		src.appearance_flags |= RESET_TRANSFORM
		src.underlays += src
		src.appearance_flags &= ~RESET_TRANSFORM
		src.icon_state = "[src.icon_tag]_off"
		src.appearance_flags |= PIXEL_SCALE

		var/matrix/M = matrix()
		src.transform = M.Turn(src.external_angle)
		if (!(src in processing_items))
			processing_items.Add(src)
		if(active)
			set_projectile()

	disposing()
		processing_items.Remove(src)
		..()


	get_desc(dist)
		. = "<br><span class='notice'>It looks [damage_words]</span>"

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
					SPAWN_DBG(0)
						for(var/i in 1 to src.current_projectile.shot_number) //loop animation until finished
							flick("[src.icon_tag]_fire",src)
							sleep(src.current_projectile.shot_delay)
					shoot_projectile_ST_pixel_spread(src, current_projectile, target, 0, 0 , spread)


	attackby(obj/item/W, mob/user)
		if (isweldingtool(W) && !(src.active))
			var/turf/T = user.loc
			if(!W:try_weld(user, 1))
				return

			if(src.anchored)
				user.show_message("You start to unweld the turret from the floor.")
				sleep(3 SECONDS)

				if ((user.loc == T && user.equipped() == W))
					user.show_message("You unweld the turret from the floor.")
					src.anchored = 0


				else if((istype(user, /mob/living/silicon/robot) && (user.loc == T)))
					user.show_message("You unweld the turret  the floor.")
					src.anchored = 0

			else
				user.show_message("You start to weld the turret to the floor.")
				sleep(3 SECONDS)

				if ((user.loc == T && user.equipped() == W))
					user.show_message("You weld the turret to the floor.")
					src.anchored = 1


				else if((istype(user, /mob/living/silicon/robot) && (user.loc == T)))
					user.show_message("You weld the turret to the floor.")
					src.anchored = 1

		else if (isweldingtool(W) && (src.active))
			var/turf/T = user.loc
			if (src.health >= max_health)
				user.show_message("<span class='notice'>The turret is already fully repaired!.</span>")
				return

			if(!W:try_weld(user, 1))
				return

			user.show_message("You start to repair the turret.")
			sleep(2 SECONDS)

			if ((user.loc == T && user.equipped() == W))
				user.show_message("You repair some of the damage on the turret.")
				src.health = min(src.max_health, (src.health + 10))
				src.check_health()

		else if (istype(W, /obj/item/wrench))

			if(src.anchored)

				user.show_message("<span class='notice'>Click where you want to aim the turret!</span>")
				var/datum/targetable/deployable_turret_aim/A = new()
				user.targeting_ability = A
				user.update_cursor()
				A.my_turret = src
				A.user_turf = get_turf(user)
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)

			else
				var/turf/T = user.loc
				user.show_message("You begin to disassemble the turret.")
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)

				sleep(2 SECONDS)

				if ((user.loc == T && user.equipped() == W))
					user.show_message("You disassemble the turret.")
					src.active = 0
					src.shooting = 0
					src.waiting = 0
					src.target = null
					src.spawn_deployer()
					qdel(src)
		/*
		else if (istype(W, /obj/item/card/emag))
			return
		*/

		else if (istype(W, /obj/item/screwdriver))

			if(!src.anchored)
				user.show_message("<span class='notice'>The turret is too unstable to fire! Secure it to the ground with a welding tool first!</span>")
				return

			var/turf/T = user.loc

			playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)

			sleep(1 SECOND)

			if ((user.loc == T && user.equipped() == W))
				if(src.active)
					user.show_message("<span class='notice'>You power off the turret.</span>")
					src.icon_state = "[src.icon_tag]_off"
					src.active = 0
					src.shooting = 0
					src.waiting = 0
					src.target = null

				else
					user.show_message("<span class='notice'>You power on the turret.</span>")
					set_projectile()
					src.active = 1
					src.icon_state = "[src.icon_tag]_idle"

			else if((istype(user, /mob/living/silicon/robot) && (user.loc == T)))
				if(src.active)
					user.show_message("<span class='notice'>You power off the turret.</span>")
					src.icon_state = "[src.icon_tag]_off"
					src.active = 0
					src.shooting = 0
					src.waiting = 0
					src.target = null

				else
					user.show_message("<span class='notice'>You power on the turret.</span>")
					set_projectile()
					src.active = 1
					src.icon_state = "[src.icon_tag]_idle"

		else
			src.health = src.health - W.force
			src.check_health()
			..()

		return

	proc/quick_deploy()
		if(!(src.quick_deploy_fuel > 0))
			return
		src.quick_deploy_fuel--
		src.visible_message("<span class='alert'>[src]'s quick deploy system engages, automatically securing it!</span>")
		playsound(src.loc, "sound/items/Welder2.ogg", 50, 1)
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
				damage_words = "fully operational!"
			if(75 to 89)
				damage_words = "a little bit damaged."
			if(30 to 74)
				damage_words = "pretty beaten up."
			if(0 to 29)
				damage_words = "to be on the verge of falling apart!"

		/*
		if(src.emagged)
			damage_words += "<br><span class='alert'>Its safety indicator is off!</span>"
		*/


	proc/die()
		playsound(src.loc, "sound/effects/robogib.ogg", 50, 1)
		new /obj/decal/cleanable/robot_debris(src.loc)
		qdel(src)


	proc/spawn_deployer()
		var/obj/item/turret_deployer/deployer = new /obj/item/turret_deployer(src.loc)
		deployer.health = src.health // NO FREE REPAIRS, ASSHOLES
		//deployer.emagged = src.emagged
		deployer.damage_words = src.damage_words
		deployer.quick_deploy_fuel = src.quick_deploy_fuel
		return deployer


	proc/seek_target()
		src.target_list = list()
		for (var/mob/living/C in mobs)
			if(!src)
				break

			if (src.target_valid(C))
				src.target_list += C
				var/distance = get_dist(C.loc,src.loc)
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

			playsound(src.loc, "sound/vox/woofsound.ogg", 40, 1)

		return src.target


	proc/target_valid(var/mob/living/C)
		var/distance = get_dist(C.loc,src.loc)

		if(distance > src.range)
			return 0
		if (!C)
			return 0
		if (C.health < 0)
			return 0
		if (C.stat == 2)
			return 0
		if (istype(C,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			if (H.hasStatus(list("resting", "weakened", "stunned", "paralysis"))) // stops it from uselessly firing at people who are already suppressed. It's meant to be a suppression weapon!
				return 0
		if (is_friend(C))
			return 0


		/*var/turf/curr_step = src.loc // CAUSES GAME CRASH??

		while(curr_step != C.loc)
			curr_step = get_step(C.loc,get_dir(C.loc,curr_step))
			if (curr_step.opacity || curr_step.density)
				return 0 */


		var/angle = get_angle(src,C)


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
		/*
		if (src.emagged)
			return 0 // NO FRIENDS :'[
		*/
		return istype(C.get_id(), /obj/item/card/id/syndicate)

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

	/*
	emag_act(var/user, var/emag)
		if(src.emagged)
			return
		src.emagged = 1
		boutput(user,"You short out the safeties on the turret.")
		src.damage_words += "<br><span class='alert'>Its safety indicator is off!</span>"
	*/


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

			if(!istype(M.equipped(),/obj/item/wrench))
				return

			if(!(get_turf(usr) == src.user_turf))
				return

			if(target == my_turret)
				return

			if (!istype(target,/turf))
				target = get_turf(target)

			if(target == get_turf(my_turret))
				return

			SPAWN_DBG(0)
				src.my_turret.set_angle(get_angle(my_turret,target))

			return 0



/////////////////////////////
//Why not one for security?//
/////////////////////////////

/obj/item/turret_deployer/riot
	name = "N.A.R.C.S. Deployer"
	desc = "A Nanotrasen Automatic Riot Control System Deployer. Use it in your hand to deploy."
	icon_state = "st_deployer"
	w_class = 4
	health = 125
	icon_tag = "nt"
	quick_deploy_fuel = 0

	spawn_turret(var/direct)
		var/obj/deployable_turret/riot/turret = new /obj/deployable_turret/riot(src.loc,direction=direct)
		turret.health = src.health
		//turret.emagged = src.emagged
		turret.damage_words = src.damage_words
		turret.quick_deploy_fuel = src.quick_deploy_fuel
		return turret

/obj/deployable_turret/riot
	name = "N.A.R.C.S."
	desc = "A Nanotrasen Automatic Riot Control System."
	health = 125
	max_health = 125
	wait_time = 20 //wait if it can't find a target
	range = 5 // tiles
	projectile_type = /datum/projectile/bullet/abg
	current_projectile = new/datum/projectile/bullet/abg
	burst_size = 1 // number of shots to fire. Keep in mind the bullet's shot_count
	fire_rate = 1 // rate of fire in shots per second
	angle_arc_size = 60
	icon_tag = "nt"
	quick_deploy_fuel = 0

	New(var/direction)
		..(direction=direction)
		/*
		SPAWN_DBG(src.wait_time)

			if (src.emagged)
				src.projectile_type = /datum/projectile/bullet/a12
				src.current_projectile = new/datum/projectile/bullet/a12
		*/

	is_friend(var/mob/living/C)
		/*
		if (src.emagged)
			return 0
		*/
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

	spawn_deployer()
		var/obj/item/turret_deployer/riot/deployer = new /obj/item/turret_deployer/riot(src.loc)
		deployer.health = src.health
		//deployer.emagged = src.emagged
		deployer.damage_words = src.damage_words
		deployer.quick_deploy_fuel = src.quick_deploy_fuel
		return deployer

	/*
	emag_act(var/user, var/emag)
		..()
		src.projectile_type = /datum/projectile/bullet/a12
		src.current_projectile = new/datum/projectile/bullet/a12
	*/

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
