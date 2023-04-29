/obj/machinery/vehicle
	name = "Vehicle Pod"
	icon = 'icons/obj/ship.dmi'
	icon_state = "podfire"
	density = 1
	flags = FPRINT | USEDELAY
	anchored = ANCHORED
	stops_space_move = 1
	status = REQ_PHYSICAL_ACCESS
	var/datum/effects/system/ion_trail_follow/ion_trail = null
	var/mob/pilot = null //The mob which actually flys the ship
	var/capacity = 3 //How many passengers the ship can hold
	var/passengers = 0 //The number of passengers in the ship
	var/obj/item/tank/atmostank = null // provides the air for the passengers
	var/obj/item/tank/fueltank = null // provides fuel, different mixes affect engine performance
	var/list/components = list() //List of current components in ship
	var/obj/item/shipcomponent/engine/engine = null //without this the ship can't do much
	var/obj/item/shipcomponent/life_support/life_support = null // cleans and extends the life of the atmos tank
	var/obj/item/shipcomponent/communications/com_system = null
	var/obj/item/shipcomponent/mainweapon/m_w_system = null
	var/obj/item/shipcomponent/secondary_system/sec_system = null
	var/obj/item/shipcomponent/sensor/sensors = null
	var/obj/item/shipcomponent/secondary_system/lock/lock = null
	var/obj/item/shipcomponent/pod_lights/lights = null
	var/rcs = 0		//bool, 1 for active, 0 for inactive
	var/uses_weapon_overlays = 0
	var/health = 200
	var/maxhealth = 200
	var/health_percentage = 100 // cogwerks: health percentage check for bigpods
	var/damage_overlays = 0 // cogwerks: 0 = normal, 1 = dented, 2 = on fire
	var/acid_damage_multiplier = 1 // kubius: multiplier to damage taken from acid sea turfs (1 is full, 0 is none). 0 for syndie, 0.5 for subs
	var/obj/item/device/radio/intercom/ship/intercom = null //All ships have these is used by communication array
	var/weapon_class = 0 //what weapon class a ship is
	var/powercapacity = 0 //How much power the ship's components can use, set by engine
	var/powercurrent = 0 //How much power the components are using
	var/speed = 1 //FOR PODS : While holding thruster, how much to add on to our max speed. Does nothing for tanks.
	var/stall = 0 // slow the ship down when firing
	var/flying = 0 // holds the direction the ship is currently drifting, or 0 if stopped
	var/facing = SOUTH // holds the direction the ship is currently facing
	var/going_home = 0 // set to 1 when the com system locates the station, next z level crossing will head to 1
	var/image/fire_overlay = null
	var/image/damage_overlay = null
	var/exploding = 0 // don't blow up a bunch of times sheesh
	var/locked = 0 // todo: stop people from carjacking pods in flight so easily
	var/owner = null // to use with locked var
	var/cleaning = 0 // another safety check, god knows shit will find a way to go wrong without it
	var/keyed = 0 // Did some jerk key this pod? HUH??
	var/datum/hud/pod/myhud
	var/view_offset_x = 0
	var/view_offset_y = 0
	var/datum/movement_controller/movement_controller

	var/req_smash_velocity = 7 //7 is the 'normal' cap right now
	var/hitmob = 0
	var/ram_self_damage_multiplier = 0.5

	/// I got sick of having the comms type swapping code in 17 New() ship types
	/// so this is the initial type of comms array this vehicle will have
	var/init_comms_type = /obj/item/shipcomponent/communications/

	//////////////////////////////////////////////////////
	///////Life Support Stuff ////////////////////////////
	/////////////////////////////////////////////////////

	New()
		src.contextActions = childrentypesof(/datum/contextAction/vehicle)
		src.facing = src.dir

		. = ..()
		START_TRACKING


	remove_air(amount as num)
		if(atmostank?.air_contents)
			if(life_support?.active && MIXTURE_PRESSURE(atmostank.air_contents) < 1000)
				life_support.power_used = 5 * passengers + 15
				atmostank.air_contents.oxygen += amount / 5
				atmostank.air_contents.nitrogen += 4 * amount / 5
				if (atmostank.air_contents.carbon_dioxide > 0)
					atmostank.air_contents.carbon_dioxide -= HUMAN_NEEDED_OXYGEN * 2
					atmostank.air_contents.carbon_dioxide = max(atmostank.air_contents.carbon_dioxide, 0)
				if(atmostank.air_contents.temperature > 310)
					atmostank.air_contents.temperature -= max(atmostank.air_contents.temperature - 310, 5)
				if(atmostank.air_contents.temperature < 310)
					atmostank.air_contents.temperature += max(310 - atmostank.air_contents.temperature, 5)

			return atmostank.remove_air(amount)

		else
			if (life_support) //ZeWaka: Fix for null.power_used
				life_support.power_used = 0
			var/turf/T = get_turf(src)
			return T.remove_air(amount)

	handle_internal_lifeform(mob/lifeform_inside_me, breath_request, mult)
		if (breath_request>0)
			return remove_air(breath_request * mult)
		else
			return null

	Click(location,control,params)
		if(istype(usr, /mob/dead/observer) && usr.client && !usr.client.keys_modifier && !usr:in_point_mode)
			var/mob/dead/observer/O = usr
			if(src.pilot)
				O.insert_observer(src.pilot)
		else
			. = ..()

	/////////////////////////////////////////////////////////
	///////Attack Code									////
	////////////////////////////////////////////////////////

	attackby(obj/item/W, mob/living/user)
		user.lastattacked = src
		if (health < maxhealth && isweldingtool(W))
			var/turf/T = get_turf(src)
			if(T.active_liquid)
				if(T.active_liquid.my_depth_level >= 3 && T.active_liquid.group.reagents.get_reagent_amount("tene")) //SO MANY PERIODS
					boutput(user, "<span class='alert'>The damaged parts are saturated with fluid. You need to move somewhere drier.</span>")
					return
#ifdef MAP_OVERRIDE_NADIR
			if(istype(T,/turf/space/fluid) || istype(T,/turf/simulated/floor/plating/airless/asteroid))
				//prevent in-acid welding from extending excursion times indefinitely
				boutput(user, "<span class='alert'>The damaged parts are saturated with acid. You need to move somewhere with less pressure.</span>")
				return
#endif
			if(!W:try_weld(user, 1))
				return
			src.health += 30
			checkhealth()
			src.add_fingerprint(user)
			src.visible_message("<span class='alert'>[user] has fixed some of the dents on [src]!</span>")
			if(health >= maxhealth)
				src.visible_message("<span class='alert'>[src] is fully repaired!</span>")
			return

		if (istype(W, /obj/item/shipcomponent))
			Install(W)
			return

		if (istype(W, /obj/item/ammo/bullets))
			if (W.disposed)
				return
			if (src.m_w_system)
				if (!src.m_w_system.uses_ammunition)
					boutput(user, "<span class='alert'>That weapon does not require ammunition.</span>")
					return
				if (src.m_w_system.remaining_ammunition >= 50)
					boutput(user, "<span class='alert'>The automated loader for the weapon cannot hold any more ammunition.</span>")
					return
				var/obj/item/ammo/bullets/ammo = W
				if (!ammo.amount_left)
					return
				if (src.m_w_system.current_projectile.type != ammo.ammo_type.type)
					boutput(user, "<span class='alert'>The [m_w_system] cannot fire that kind of ammunition.</span>")
					return
				var/may_load = 50 - src.m_w_system.remaining_ammunition
				if (may_load < ammo.amount_left)
					ammo.amount_left -= may_load
					src.m_w_system.remaining_ammunition += may_load
					boutput(user, "<span class='notice'>You load [may_load] ammunition from [ammo]. [ammo] now contains [ammo.amount_left] ammunition.</span>")
					logTheThing(LOG_COMBAT, user, "reloads [src]'s [src.m_w_system.name] (<b>Ammo type:</b> <i>[src.m_w_system.current_projectile.type]</i>) at [log_loc(src)].") // Might be useful (Convair880)
					return
				else
					src.m_w_system.remaining_ammunition += ammo.amount_left
					ammo.amount_left = 0
					boutput(user, "<span class='notice'>You load [ammo] into [m_w_system].</span>")
					logTheThing(LOG_COMBAT, user, "reloads [src]'s [src.m_w_system.name] (<b>Ammo type:</b> <i>[src.m_w_system.current_projectile.type]</i>) at [log_loc(src)].")
					qdel(ammo)
					return
			else
				boutput(user, "<span class='alert'>No main weapon system installed.</span>")
				return

		if (istype(W, /obj/item/device/key))
			user.visible_message("<span class='alert'><B>[user] scratches [src] with \the [W]! [prob(75) ? pick_string("descriptors.txt", "jerks") : null]</B></span>", null,"<span class='alert'>You hear a metallic scraping sound!</span>")
			if(!keyed) src.name = "scratched-up [src.name]"
			src.keyed++
			src.add_fingerprint(user)
			return
		..()

		attack_particle(user,src)
		playsound(src.loc, W.hitsound, 50, 1, -1)
		hit_twitch(src)

		switch(W.hit_type)
			if (DAMAGE_BURN)
				src.material?.triggerTemp(src, W.force * 1000)
				if (prob(W.force*2))
					playsound(src.loc, 'sound/impact_sounds/Metal_Clang_1.ogg', 50, 1, -1)
					for (var/mob/M in src)
						M.changeStatus("weakened",1 SECONDS)
						M.show_text("The physical shock of the blow knocks you around!", "red")
				return /////ships should pretty much be immune to fire
			else
				src.health -= W.force
				if (prob(W.force*3))
					playsound(src.loc, 'sound/impact_sounds/Metal_Clang_1.ogg', 50, 1, -1)
					for (var/mob/M in src)
						M.changeStatus("weakened",1 SECONDS)
						M.show_text("The physical shock of the blow knocks you around!", "red")

		checkhealth()

	updateDialog()
		for(var/client/C)
			if (C.mob && C.mob.using_dialog_of(src) && BOUNDS_DIST(C.mob, src) == 0)
				src.open_parts_panel(C.mob)

	Topic(href, href_list)
		if (is_incapacitated(usr) || usr.restrained())
			return
		///////////////////////////////////////
		//////Main Computer Code		//////
		//////////////////////////////////////
		if (usr.loc == src)
			src.add_dialog(usr)
			if (href_list["dengine"])
				if (usr != pilot)
					boutput(usr, "[ship_message("Only the pilot may do this!")]")
					return
				engine.deactivate()
				src.updateDialog()

			else if (href_list["aengine"])
				engine.activate()
				src.updateDialog()

			else if (href_list["dlife"])
				life_support.deactivate()
				src.updateDialog()

			else if (href_list["alife"])
				life_support.activate()
				src.updateDialog()

			else if (href_list["acom"])
				com_system.activate()
				src.updateDialog()

			else if (href_list["dcom"])
				com_system.deactivate()
				src.updateDialog()

			else if (href_list["amweapon"])
				m_w_system.activate()
				src.updateDialog()

			else if (href_list["dmweapon"])
				m_w_system.deactivate()
				src.updateDialog()

			else if (href_list["asensors"])
				sensors.activate()
				src.updateDialog()

			else if (href_list["dsensors"])
				sensors.deactivate()
				src.updateDialog()

			else if (href_list["asec_system"])
				sec_system.activate()
				src.updateDialog()

			else if (href_list["dsec_system"])
				sec_system.deactivate()
				src.updateDialog()

			else if (href_list["comcomp"])
				com_system.opencomputer(usr)
				src.updateDialog()

			else if (href_list["mweaponcomp"])
				m_w_system.opencomputer(usr)
				src.updateDialog()

			else if (href_list["enginecomp"])
				engine.opencomputer(usr)
				src.updateDialog()

			else if (href_list["sensorcomp"])
				sensors.opencomputer(usr)
				src.updateDialog()

			else if (href_list["sec_systemcomp"])
				sec_system.opencomputer(usr)
				src.updateDialog()

			src.add_fingerprint(usr)
			for (var/mob/M in src)
				if (M.using_dialog_of(src))
					src.access_computer(M)
			myhud.update_states()
		///////////////////////////////////////
		///////Panel Code//////////////////////
		///////////////////////////////////////
		else if (BOARD_DIST_ALLOWED(usr,src) && isturf(src.loc))
			if (passengers)
				boutput(usr, "<span class='alert'>You can't modify parts with somebody inside.</span>")
				return

			if (src.lock && src.locked)
				boutput(usr, "<span class='alert'>You can't modify parts while [src] is locked.</span>")
				lock.show_lock_panel(usr, 0)
				return

			src.add_dialog(usr)
			if (href_list["unengine"])
				if (src.engine)
					engine.deactivate()
					components -= engine
					engine.set_loc(src.loc)
					engine = null
					src.updateDialog()

			else if (href_list["un_lock"])
				if (src.lock)
					if (src.locked)
						lock.show_lock_panel(usr, 0)
					else
						lock.deactivate()
						components -= lock
						lock.set_loc(src.loc)
						lock = null
						src.updateDialog()

			else if (href_list["unlife"])
				if (src.life_support)
					life_support.deactivate()
					components -= life_support
					life_support.set_loc(src.loc)
					life_support = null
					src.updateDialog()

			else if (href_list["uncom"])
				if (src.com_system)
					com_system.deactivate()
					components -= com_system
					com_system.set_loc(src.loc)
					com_system = null
					src.updateDialog()

			else if (href_list["unm_w"])
				if (src.m_w_system)
					m_w_system.deactivate()
					components -= m_w_system
					if (uses_weapon_overlays && m_w_system.appearanceString)
						src.overlays -= image('icons/effects/64x64.dmi', "[m_w_system.appearanceString]")
					m_w_system.set_loc(src.loc)
					m_w_system = null
					src.updateDialog()

			else if (href_list["unloco"])
				if (istype(src,/obj/machinery/vehicle/tank))
					src:remove_locomotion()
					src.updateDialog()

			else if (href_list["unsec_system"])
				if (src.sec_system)
					sec_system.deactivate()
					components -= sec_system
					sec_system.set_loc(src.loc)
					sec_system = null
					src.updateDialog()

			else if (href_list["unsensors"])
				if (src.sensors)
					sensors.deactivate()
					components -= sensors
					sensors.set_loc(src.loc)
					sensors = null
					src.updateDialog()

			// Added logs for atmos tanks and such here, because booby-trapping pods is becoming a trend (Convair880).
			else if (href_list["atmostank"])
				if (src.atmostank)
					boutput(usr, "<span class='alert'>There's already a tank in that slot.</span>")
					return
				var/obj/item/tank/W = usr.equipped()
				if (W && istype(W, /obj/item/tank))
					logTheThing(LOG_VEHICLE, usr, "replaces [src.name]'s air supply with [W] [log_atmos(W)] at [log_loc(src)].")
					boutput(usr, "<span class='notice'>You attach the [W.name] to [src.name]'s air supply valve.</span>")
					usr.drop_item()
					W.set_loc(src)
					src.atmostank = W
					src.updateDialog()
				else
					boutput(usr, "<span class='alert'>That doesn't fit there.</span>")

			else if (href_list["takeatmostank"])
				if (src.atmostank)
					logTheThing(LOG_VEHICLE, usr, "removes [src.name]'s air supply [log_atmos(atmostank)] at [log_loc(src)].")
					atmostank.set_loc(src.loc)
					atmostank = null
					src.updateDialog()
				else
					boutput(usr, "<span class='alert'>There's no tank in the slot.</span>")
					return

			else if (href_list["fueltank"])
				if (src.fueltank)
					boutput(usr, "<span class='alert'>There's already a tank in that slot.</span>")
					return
				var/obj/item/tank/W = usr.equipped()
				if (W && istype(W, /obj/item/tank))
					logTheThing(LOG_VEHICLE, usr, "replaces [src.name]'s engine fuel supply with [W] [log_atmos(W)] at [log_loc(src)].")
					boutput(usr, "<span class='notice'>You attach the [W.name] to [src.name]'s fuel supply valve.</span>")
					usr.drop_item()
					W.set_loc(src)
					src.fueltank = W
					src.updateDialog()
					src.engine.activate()
				else
					boutput(usr, "<span class='alert'>That doesn't fit there.</span>")
					return

			else if (href_list["takefueltank"])
				if (src.fueltank)
					logTheThing(LOG_VEHICLE, usr, "removes [src.name]'s engine fuel supply [log_atmos(fueltank)] at [log_loc(src)].")
					fueltank.set_loc(src.loc)
					fueltank = null
					src.updateDialog()
					src.engine.deactivate()
				else
					boutput(usr, "<span class='alert'>There's no tank in the slot.</span>")
					return

			myhud.update_systems()

		else
			usr.Browse(null, "window=ship_main")
			return
		return

	proc/AmmoPerShot()
		return 1

	proc/ShootProjectiles(var/mob/user, var/datum/projectile/PROJ, var/shoot_dir)
		var/obj/projectile/P = shoot_projectile_DIR(src, PROJ, shoot_dir)
		P.mob_shooter = user
		if (src.m_w_system?.muzzle_flash)
			muzzle_flash_any(src, dir_to_angle(shoot_dir), src.m_w_system.muzzle_flash)

	bullet_act(var/obj/projectile/P)
		if(P.shooter == src)
			return
		//Wire: fix for Cannot read null.ks_ratio below
		if (!P.proj_data)
			return

		log_shot(P, src)

		if(src.material) src.material.triggerOnBullet(src, src, P)

		var/damage = round(P.power, 1.0)

		var/hitsound = null
		switch(P.proj_data.damage_type)
			if(D_KINETIC)
				src.health -= damage/1.7
				hitsound = 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg'
			if(D_PIERCING)
				src.health -= damage/1
				hitsound = 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg'
			if(D_ENERGY)
				src.health -= damage/1.5
				hitsound = 'sound/impact_sounds/Energy_Hit_3.ogg'
			if(D_SLASHING)
				src.health -= damage/2
				hitsound = 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg'
			if(D_BURNING)
				src.material?.triggerTemp(src, 5000)
				src.health -= damage/3
				hitsound = 'sound/items/Welder.ogg'
			if(D_SPECIAL) //blob
				src.health -= damage
				hitsound = 'sound/impact_sounds/Slimy_Hit_2.ogg'
		checkhealth()
		if(P.proj_data && P.proj_data.disruption) //ZeWaka: Fix for null.disruption
			src.disrupt(P.proj_data.disruption, P)

		src.visible_message("<span class='alert'><b>[P]<b> hits [src]!</span>")

		for(var/mob/M in src)
			M << sound(P.proj_data.shot_sound,volume=35)
			M << sound(hitsound, volume=30)
			shake_camera(M, 1, 8)



		//IF DAMAGE IS ENOUGH, PICK MOB AND SHOOT THAT GUY
		//means the bullet went into the pod instead of hitting the exterior
		//to implement : when subs get damage overlays otherwise it wouldn't make sense
		/*
		if (prob(50))
			var/list/mobs = list()
			for (var/mob/M in src)
				mobs+=M
			var/mob/M = pick(mobs)
			M.bullet_act(PROJ)
		*/

	blob_act(var/power)
		src.health -= power * 3
		checkhealth()

	get_desc()
		if (src.keyed > 0)
			var/t = strings("descriptors.txt", "keyed")
			var/t_ind = clamp(round(keyed/10), 0, 10)
			. += "It has been keyed [keyed] time[s_es(keyed)]! [t_ind ? t[t_ind] : null]"

	proc/paint_pod(var/obj/item/pod/paintjob/P as obj, var/mob/user as mob)
		if (!P || !istype(P))
			return
		if (user)
			user.show_text("You paint [src].", "blue")
			user.u_equip(P)
		src.overlays += image(src.icon, P.pod_skin)
		qdel(P)
		return

	proc/disrupt(var/disruption as num, var/obj/projectile/P)
		if(disruption)
			playsound(src.loc, pick('sound/machines/glitch1.ogg', 'sound/machines/glitch2.ogg', 'sound/machines/glitch3.ogg', 'sound/effects/electric_shock.ogg', 'sound/effects/elec_bzzz.ogg'), 50, 1)
			if(pilot)
				boutput(src.pilot, "[ship_message("WARNING! Electrical system disruption detected!")]")
			//if (P)
			//	for (var/mob/M in src)
			//		M.bullet_act_indirect(P)
			var/chance = disruption * 1
			for(var/obj/item/shipcomponent/S in src.components)
				var/my_chance = chance
				if (istype(S, /obj/item/shipcomponent/engine))
					my_chance += 40

				if(prob(my_chance))
					if (istype(S, /obj/item/shipcomponent/engine)) //dont turn off engine thats annoying. instead ddisable the wormhole func!!
						var/obj/item/shipcomponent/engine/E = S
						if (E.ready)
							E.ready = 0
							E.ready()
					else
						S.deactivate()

					chance -= 25
					if (chance <= 0)
						return

	emp_act()
		src.disrupt(10)
		return

	ex_act(severity)
		if (sec_system)
			if (sec_system.type == /obj/item/shipcomponent/secondary_system/crash)
				if (sec_system:crashable)
					return
		var/sevmod = 0
		sevmod = round(src.explosion_protection / 5)

		severity += sevmod

		switch (severity)
			if (1)
				src.health -= round(src.maxhealth / 3)
				src.health -= 65
				checkhealth()
			if(2)
				src.health -= round(src.maxhealth / 4)
				src.health -= 40
				checkhealth()
			if(3)
				src.health -= round(src.maxhealth / 5)
				src.health -= 25
				checkhealth()

	proc/get_move_velocity_magnitude()
		.= movement_controller:velocity_magnitude

	bump(var/atom/target)
		if (get_move_velocity_magnitude() > 5)
			var/power = get_move_velocity_magnitude()

			src.health -= min(power * ram_self_damage_multiplier,10)
			checkhealth()

			if (istype(target, /obj/machinery/vehicle/))
				var/obj/machinery/vehicle/V = target
				V.health -= min(power*1.5,30)
				V.checkhealth()

			for (var/mob/C in src)
				shake_camera(C, 6, 8)
				//M << sound('sound/impact_sounds/Generic_Hit_Heavy_1.ogg',volume=35)

			if (ismob(target) && target != hitmob)
				hitmob = target
				SPAWN(0.5 SECONDS)
					hitmob = 0
				var/mob/M = target
				var/vehicular_manslaughter
				if(M.health > 0)
					vehicular_manslaughter = 1 //we first check if the person is not in crit before hit, if yes we qualify for vehicular manslaughter achievement
				//M.changeStatus("stunned", 1 SECOND)
				//M.changeStatus("weakened", 1 SECOND)
				M.TakeDamageAccountArmor("chest", power * 1.3, 0, 0, DAMAGE_BLUNT)
				M.remove_stamina(power)
				var/turf/throw_at = get_edge_target_turf(src, src.dir)
				M.throw_at(throw_at, movement_controller:velocity_magnitude, 2)
				logTheThing(LOG_COMBAT, src, "(piloted by [constructTarget(src.pilot,"combat")]) crashes into [constructTarget(target,"combat")] [log_loc(src)].")
				SPAWN(2.5 SECONDS)
					if(M.health > 0)
						vehicular_manslaughter = 0 //we now check if person was sent into crit after hit, if they did we get the achievement
					if(vehicular_manslaughter && ishuman(M))
						src.pilot.unlock_medal("Vehicular Manslaughter", 1)

			else if(isturf(target) && power > 20)
				if(istype(target, /turf/simulated/wall/r_wall || istype(target, /turf/simulated/wall/auto/reinforced)) && prob(power / 2))
					return
				if(istype(target, /turf/simulated/wall) && prob(power))
					var/turf/simulated/wall/T = target
					T.dismantle_wall(1)

				logTheThing(LOG_COMBAT, src, "(piloted by [constructTarget(src.pilot,"combat")]) crashes into [constructTarget(target,"combat")] [log_loc(src)].")
			else if (isobj(target) && power >= req_smash_velocity)
				var/obj/O = target

				if (power > 20)
					if (istype(O, /obj/machinery/door) && O.density)
						var/obj/machinery/door/D = O
						SPAWN(0)
							D.try_force_open(src)
					if (istype(O, /obj/structure/girder) || istype(O, /obj/foamedmetal))
						qdel(O)
				var/obj_damage = 5 * power
				target.damage_blunt(obj_damage)

				if (istype(O, /obj/table))
					var/obj/table/table = target
					table.deconstruct()

				if (istype(O,/obj/machinery/vending))
					var/obj/machinery/vending/V = O
					V.fall(src)
				logTheThing(LOG_COMBAT, src, "(piloted by [constructTarget(src.pilot,"combat")]) crashes into [constructTarget(target,"combat")] [log_loc(src)].")

			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)

		if (sec_system)
			if (sec_system.type == /obj/item/shipcomponent/secondary_system/crash)
				if (sec_system:crashable)
					sec_system:crashtime2(target)
		SPAWN(0)
			..()
			return
		return

	meteorhit(var/obj/O as obj)
		src.health -= 50
		checkhealth()

	Move(NewLoc,Dir=0,step_x=0,step_y=0)
		// set return value to default
		.=..(NewLoc,Dir,step_x,step_y)

		if (movement_controller)
			movement_controller.update_owner_dir()
		else if (flying && facing != flying)
			set_dir(facing)

	disposing()
		if (movement_controller)
			movement_controller.dispose()

		myhud.detach_all_clients()
		myhud.master = null
		myhud = null

		if (pilot)
			pilot = null
		if (components)
			for(var/obj/S in components)
				S.dispose()
			components.len = 0
			components = null
		atmostank = null
		fueltank = null
		engine = null
		life_support = null
		com_system = null
		m_w_system = null
		sec_system = null
		sensors = null
		intercom = null
		fire_overlay = null
		damage_overlay = null
		ion_trail = null
		STOP_TRACKING_CAT(TR_CAT_PODS_AND_CRUISERS)
		STOP_TRACKING

		..()

	process(mult)
		if(sec_system)
			if(sec_system.active)
				sec_system.run_component()
#ifdef MAP_OVERRIDE_NADIR
		if(src.acid_damage_multiplier > 0)
			var/T = get_turf(src)
			if(istype(T,/turf/space/fluid) || istype(T,/turf/simulated/floor/plating/airless/asteroid))
				var/power = get_move_velocity_magnitude()
				src.health -= max(0.1 * power, 0.2) * acid_damage_multiplier * mult
				checkhealth()
#endif

	proc/checkhealth()
		myhud?.update_health()
		// sanitize values
		if(health > maxhealth)
			health = maxhealth
		// find percentage of total health
		health_percentage = (health / maxhealth) * 100

		if(istype(src, /obj/machinery/vehicle/pod_smooth)) // check to see if it's one of the new pods
			switch(health_percentage)

			//add or remove damage overlays, murderize the ship

				if(-INFINITY to -20)
					shipdeath()
					return
				if(-20 to 0)
					shipcrit()
				if(0 to 25)
					if(damage_overlays != 2)
						particleMaster.SpawnSystem(new /datum/particleSystem/areaSmoke("#CCCCCC", 50, src))
						damage_overlays = 2
						fire_overlay = image('icons/effects/64x64.dmi', "pod_fire")
						src.overlays += fire_overlay
						for(var/mob/living/carbon/human/M in src)
							M.update_burning(35)
							boutput(M, "<span class='alert'><b>The cabin bursts into flames!</b></span>")
							playsound(M.loc, 'sound/machines/engine_alert1.ogg', 35, 0)
				if(25 to 50)
					if(damage_overlays < 1)
						damage_overlays = 1
						damage_overlay = image('icons/effects/64x64.dmi', "pod_damage")
						src.overlays += damage_overlay
				if(50 to INFINITY)
					if (damage_overlays)
						if(damage_overlays == 2)
							src.overlays -= fire_overlay
							src.overlays -= damage_overlay
							fire_overlay = null
						else if(damage_overlays == 1)
							src.overlays -= damage_overlay
						damage_overlays = 0
						damage_overlay = null

// if not a big pod, assume it's an old-style one instead
		else
			switch(health_percentage)
				if(-INFINITY to -20)
					shipdeath()
					return
				if(-20 to 0)
					shipcrit()

/obj/machinery/vehicle/proc/shipcrit()
	if (src.engine)
		playsound(src.loc, 'sound/machines/pod_alarm.ogg', 40, 1)
		visible_message("<span class='alert'>[src]'s engine bursts into flame!</span>")
		for(var/mob/living/carbon/human/M in src)
			M.update_burning(35)
		engine.deactivate()
		components -= engine
		qdel(engine)
		engine = null

///////////////////////////////////////////////////////////////////////////
////////Install Ship Part////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/obj/machinery/vehicle/proc/Install(obj/item/shipcomponent/S as obj)
	switch(S.system)
		if("Engine")
			if(!src.engine)
				src.engine = S
			else
				boutput(usr, "That system already has a part!")
				return
		if("Communications")
			if(!com_system)
				src.com_system = S
			else
				boutput(usr, "That system already has a part!")
				return
		if("Life Support")
			if(!life_support)
				src.life_support = S
			else
				boutput(usr, "That system already has a part!")
				return
		if("Sensors")
			if(!sensors)
				src.sensors = S
			else
				boutput(usr, "That system already has a part!")
				return
		if("Secondary System")
			if(!sec_system)
				sec_system = S
			else
				boutput(usr, "That system already has a part!")
				return
		if("Main Weapon")
			if(!m_w_system)
				if(weapon_class == 0)
					boutput(usr, "Weapons cannot be installed in this ship!")
					return
				m_w_system = S
				if(uses_weapon_overlays && m_w_system.appearanceString)
					src.overlays += image('icons/effects/64x64.dmi', "[m_w_system.appearanceString]")

				m_w_system.activate()
			else
				boutput(usr, "That system already has a part!")
				return
		if("Lock")
			if (!lock)
				src.lock = S
			else
				boutput(usr, "That system already has a part!")
				return
	components += S
	S.ship = src
	if (usr) //This mean it's going on during the game!
		usr.drop_item(S)
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 0)
	S.set_loc(src)
	myhud.update_systems()
	myhud.update_states()
	return

/////////////////////////////////////////////////////////////////////////////
////////////// Ship Death									////////////////
////////////////////////////////////////////////////////////////////////////

/obj/machinery/vehicle/proc/shipdeath()
	if(exploding)
		return
	exploding = 1
	SPAWN(1 DECI SECOND)
		src.visible_message("<b>[src] is breaking apart!</b>")
		new /obj/effects/explosion (src.loc)
		playsound(src.loc, "explosion", 50, 1)
		sleep(3 SECONDS)
		for(var/mob/living/carbon/human/M in src)
			M.update_burning(35)
			boutput(M, "<span class='alert'><b>Everything is on fire!</b></span>")
			//playsound(M.loc, "explosion", 50, 1)
			//playsound(M.loc, 'sound/machines/engine_alert1.ogg', 40, 0)
			M << sound('sound/machines/engine_alert1.ogg',volume=50)
		sleep(2.5 SECONDS)
		//playsound(src.loc, 'sound/machines/engine_alert2.ogg', 40, 1)
		playsound(src.loc, 'sound/machines/pod_alarm.ogg', 40, 1)
		for(var/mob/living/carbon/human/M in src)
			//playsound(M.loc, 'sound/machines/engine_alert2.ogg', 50, 0)
			M << sound('sound/machines/pod_alarm.ogg',volume=50)
		new /obj/effects/explosion (src.loc)
		playsound(src.loc, "explosion", 50, 1)
		sleep(1.5 SECONDS)
		handle_occupants_shipdeath()
		playsound(src.loc, "explosion", 50, 1)
		sleep(0.2 SECONDS)
		var/turf/T = get_turf(src.loc)
		if(T)
			src.visible_message("<b>[src] explodes!</b>")
			explosion_new(src, T, 5)
		//Exploding engines, cargo pods launching their contents, etc.
		for(var/obj/item/shipcomponent/SC in src)
			SC.on_shipdeath()

		for(T in range(src,1))
			make_cleanable(/obj/decal/cleanable/machine_debris, T)

		qdel (src)
///////////////////////////////////////////////////////////////////////////
////////// Exit Ship Code /////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
/obj/machinery/vehicle/proc/exit_ship()
	if (is_incapacitated(usr))
		usr.show_text("Not when you're incapacitated.", "red")
		return

	src.leave_pod(usr)

/// Called when the loc of an occupant changes to something other than a pod. (It's in mob/set_loc. Yes, really.)
/// Use leave_pod if the occupant is exiting the pod normally, and don't call this directly.
/obj/machinery/vehicle/proc/eject(mob/ejectee)
	if (!ejectee || ejectee.loc != src)
		return

	if (ejectee.client)
		ejectee.detach_hud(myhud)
		if (ejectee.client.tooltipHolder)
			ejectee.client.tooltipHolder.inPod = 0

	src.passengers--

	//ejectee.remove_shipcrewmember_powers(src.weapon_class)
	ejectee.reset_keymap()
	ejectee.recheck_keys()
	if(src.pilot == ejectee)
		src.pilot = null
	if(passengers)
		find_pilot()
	else
		src.ion_trail?.stop()

	logTheThing(LOG_VEHICLE, ejectee, "exits pod: <b>[constructTarget(src.name,"vehicle")]</b>")

/obj/machinery/vehicle/proc/leave_pod(mob/ejectee as mob)
	// Assert facing direction for eject location offset
	if (!ejectee || ejectee.loc != src)
		return

	var/x_offset = 0
	var/y_offset = 0
	if (bound_width == 64 && bound_height == 64)	// ensure it is a 2x2 pod
		if (facing == NORTH)
			x_offset = 1
			y_offset = 1
		else if (facing == EAST)
			x_offset = 1
		else if (facing == WEST)
			y_offset = 1

	var/x_coord = src.loc.x + x_offset
	var/y_coord = src.loc.y + y_offset
	var/z_coord = src.loc.z
	var/location = locate(x_coord, y_coord, z_coord)
	var/atom/movable/EJ = ejectee		// stops ejectee floating off in the direction they last moved
	EJ.last_move = null
	ejectee.set_loc(location) // set_loc will call eject()

	for (var/obj/item/I in src)
		if ( (I in src.components) || I == src.atmostank || I == src.fueltank || I == src.intercom)
			continue

		I.set_loc(location)


///////////////////////////////////////////////////////////////////////
/////////Board Code  (also eject code lol)		//////////////////////
//////////////////////////////////////////////////////////////////////
/obj/machinery/vehicle/proc/board()
	src.board_pod(usr)
	return

/obj/machinery/vehicle/proc/board_pod(var/mob/boarder)
	if(!isliving(boarder) || isintangible(boarder) || isghostdrone(boarder))
		boutput(boarder, "<span class='alert'>Pods are only for the living, so quit being a smartass!</span>")
		return

	if(iscube(boarder))
		boutput(boarder, "<span class='alert'>You can't squeeze your wide cube body through the access door!</span>")
		return

	if(isflockmob(boarder))
		boutput(boarder, "<span class='alert'>You're unable to use this vehicle!</span>")
		return

	if(locked)
		boutput(boarder, "<span class='alert'>[src] is locked!</span>")
		return

	if (boarder.getStatusDuration("stunned") > 0 || boarder.getStatusDuration("weakened") || boarder.getStatusDuration("paralysis") || !isalive(boarder) || boarder.restrained())
		boutput(boarder, "<span class='alert'>You can't enter a pod while incapacitated or restrained.</span>")
		return

	if (boarder in src) // fuck's sake
		boutput(boarder, "<span class='alert'>You're already inside [src]!</span>")
		return

	if (!src.allowed(boarder))
		boutput(boarder, "<span class='alert'>Access denied.</span>")
		return

	passengers = 0 // reset this shit

	for(var/mob/M in src) // nobody likes losing a pod to a dead pilot
		passengers++

	eject_pod(boarder, dead_only = 1)

	if (src.capacity <= src.passengers)
		boutput(boarder, "There is no more room!")
		return

	if(!src.pilot && (ismobcritter(boarder)))
		boutput(boarder, "<span class='alert'>You don't know how to pilot a pod, you can only enter as a passenger!</span>")
		return

	actions.start(new/datum/action/bar/board_pod(src,boarder), boarder)

/obj/machinery/vehicle/proc/finish_board_pod(var/mob/boarder)
	for(var/obj/item/shipcomponent/S in src.components)
		S.mob_activate(boarder)

	src.passengers++
	var/mob/M = boarder

	M.set_loc(src, src.view_offset_x, src.view_offset_y)
	M.reset_keymap()
	M.recheck_keys()
	if(!src.pilot && !(ismobcritter(boarder)))
		src.ion_trail.start()
	src.find_pilot()
	if (M.client)
		M.attach_hud(myhud)
		if(ishuman(M))
			myhud.check_hud_layout(M)
		if (M.client.tooltipHolder)
			M.client.tooltipHolder.inPod = 1

	src.add_fingerprint(M)

	//boarder.make_shipcrewmember(src.weapon_class)

	boutput(M, "<span class='hint'>You can also use the Space Bar to fire!</span>")

	logTheThing(LOG_VEHICLE, M, "enters vehicle: <b>[constructTarget(src.name,"vehicle")]</b>")

/obj/machinery/vehicle/proc/eject_occupants()
	if(isghostdrone(usr))
		boutput(usr, "<span class='alert'>Your laws don't permit you to do that!</span>")
		return

	if(locked)
		boutput(usr, "<span class='alert'>[src] is locked!</span>")
		return

	actions.start(new/datum/action/bar/icon/eject_pod(src,usr), usr)
	return

/obj/machinery/vehicle/proc/eject_pod(var/mob/user, var/dead_only = 0)
	for(var/mob/M in src) // nobody likes losing a pod to a dead pilot
		if (!dead_only)
			leave_pod(M)
			boutput(user, "<span class='alert'>You yank [M] out of [src].</span>")
		else
			if(M.stat || !M.client)
				leave_pod(M)
				boutput(user, "<span class='alert'>You pull [M] out of [src].</span>")
			else if(!isliving(M))
				leave_pod(M)
				boutput(user, "<span class='alert'>You scrape [M] out of [src].</span>")

	for(var/obj/decal/cleanable/O in src)
		boutput(user, "<span class='alert'>You [pick("scrape","scrub","clean")] [O] out of [src].</span>")
		var/floor = get_turf(src)
		O.set_loc(floor)


/datum/action/bar/board_pod
	duration = 20
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_MOVE
	id = "board_pod"
	var/mob/M
	var/obj/machinery/vehicle/V

	New(Vehicle, Mob)
		V=Vehicle
		M=Mob
		..()


	onUpdate()
		..()
		if(!BOARD_DIST_ALLOWED(owner,V) || V == null || V.locked)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (M.restrained() || is_incapacitated(M))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(!BOARD_DIST_ALLOWED(owner,V) || V == null || V.locked)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(!BOARD_DIST_ALLOWED(owner,V) || V == null || V.locked || V.capacity <= V.passengers)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (M.restrained() || is_incapacitated(M))
			interrupt(INTERRUPT_ALWAYS)
			return

		V.finish_board_pod(owner)

/datum/action/bar/icon/eject_pod
	duration = 50
	interrupt_flags = INTERRUPT_STUNNED
	id = "eject_pod"
	icon = 'icons/ui/actions.dmi'
	//icon_state = "working"
	var/mob/M
	var/obj/machinery/vehicle/V

	New(Vehicle,Mob)
		V=Vehicle
		M=Mob
		..()

	onUpdate()
		..()
		if(!BOARD_DIST_ALLOWED(owner,V) || V == null || V.locked)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (isdead(M) || M.restrained() || owner.getStatusDuration("weakened") || owner.getStatusDuration("paralysis") || owner.getStatusDuration("stunned"))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(!BOARD_DIST_ALLOWED(owner,V) || V == null || V.locked)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(!BOARD_DIST_ALLOWED(owner,V) || V == null || V.locked)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (isdead(M) || M.restrained() || owner.getStatusDuration("weakened") || owner.getStatusDuration("paralysis") || owner.getStatusDuration("stunned"))
			interrupt(INTERRUPT_ALWAYS)
			return

		V.eject_pod(owner)

///////////////////////////////////////////////////////////////////////////
///////// Find new pilot									////////////
/////////////////////////////////////////////////////////////////////////

/obj/machinery/vehicle/proc/find_pilot()
	if(src.pilot && (src.pilot.disposed || isdead(src.pilot) || src.pilot.loc != src))
		src.pilot = null
	for(var/mob/living/M in src) // fuck's sake stop assigning ghosts and observers to be the pilot
		if(!src.pilot && !M.stat && M.client && !(ismobcritter(M)))
			src.pilot = M
			break

//////////////////////////////////////////////////////////////////////////
////////Ship Message												//////
//////////////////////////////////////////////////////////////////////////
/obj/machinery/vehicle/proc/ship_message(var/message as text)
	message = "<font color='green'><b>[bicon(src)]\[[src]\]</b> states, \"[message]\"</font>"
	return message

//////////////////////////////////////////////////////////////////////////
////////Incoming!												//////
//////////////////////////////////////////////////////////////////////////
/obj/machinery/vehicle/proc/threat_alert(var/obj/critter/gunbot/drone/bad_drone)
	var/message = "[bad_drone.name] in pursuit! Threat Rating: [bad_drone.score]"
	for(var/mob/M in src)
		M << sound(bad_drone.alertsound1,volume=25)
		boutput(M, src.ship_message(message))

	return




/////////////////////////////////////////////////////////////////////////
////////What happens to occupants when ship is destroyed ////////////////
////////////////////////////////////////////////////////////////////////
/obj/machinery/vehicle/proc/handle_occupants_shipdeath()
	for(var/mob/M in src)
		boutput(M, "<span class='alert'><b>You are ejected from [src]!</b></span>")
		logTheThing(LOG_VEHICLE, M, "is ejected from pod: <b>[constructTarget(src.name,"vehicle")]</b> when it blew up!")

		M.set_loc(get_turf(src))
		var/atom/target = get_edge_cheap(M, src.dir)
		M.throw_at(target, 10, 2)


/////////////////////////////////////////////////////////////////////
////////Open Part Panel									////////////
////////////////////////////////////////////////////////////////////
/obj/machinery/vehicle/proc/open_parts_panel(mob/user as mob)
	if(isghostdrone(user))
		boutput(user, "<span class='alert'>Pods are only for the living, so quit trying to mess with them!</span>")
		return

	if (passengers)
		boutput(user, "<span class='alert'>You can't modify parts with somebody inside.</span>")
		return

	if (src.lock && src.locked)
		boutput(user, "<span class='alert'>You can't modify parts while [src] is locked.</span>")
		lock.show_lock_panel(user, 0)
		return

	src.add_dialog(user)

	var/dat = "<TT><B>[src] Maintenance Panel</B><BR><HR><BR>"
	//Air and Fuel tanks
	dat += "<HR><B>Atmos Tank</B>: "
	if(!isnull(src.atmostank))
		dat += "<A href='?src=\ref[src];takeatmostank=1'>[src.atmostank]</A>"
	else
		dat += "<A href='?src=\ref[src];atmostank=1'>--------</A>"
	dat += "<HR><B>Fuel Tank</B>: "
	if(src.fueltank)
		dat += "<A href='?src=\ref[src];takefueltank=1'>[src.fueltank]</A>"
	else
		dat += "<A href='?src=\ref[src];fueltank=1'>--------</A>"
	dat += "<HR><B>Engine</B>: "
	//Engine
	if(src.engine)
		dat += "<A href='?src=\ref[src];unengine=1'>[src.engine]</A>"
	else
		dat += "None Installed"
	///Life Support
	dat += "<HR><B>Life Support</B>: "
	if(src.life_support)
		dat += "<A href='?src=\ref[src];unlife=1'>[src.life_support]</A>"
	else
		dat += "None Installed"
	//// Com System
	dat += "<HR><B>Com System</B>: "
	if(src.com_system)
		dat += "<A href='?src=\ref[src];uncom=1'>[src.com_system]</A>"
	else
		dat += "None Installed"
	///Main Weapon
	if(weapon_class != 0)
		dat += "<HR><B>Main Weapon</B>: "
		if(src.m_w_system)
			dat += "<A href='?src=\ref[src];unm_w=1'>[src.m_w_system]</A>"
			if (src.m_w_system.uses_ammunition)
				dat += "<br><b>Remaining ammo:</b> [src.m_w_system.remaining_ammunition]"
		else
			dat += "None Installed"
	if(istype(src,/obj/machinery/vehicle/tank))
		dat += "<HR><B>Locomotion</B>: "
		if(src:locomotion)
			dat += "<A href='?src=\ref[src];unloco=1'>[src:locomotion]</A>"
		else
			dat += "None Installed"
	////Sensors
	dat += "<HR><B>Sensors</B>: "
	if(src.sensors)
		dat += "<A href='?src=\ref[src];unsensors=1'>[src.sensors]</A>"
	else
		dat += "None Installed"
	////Secondary System
	dat += "<HR><B>Secondary System</B>: "
	if(src.sec_system)
		dat += "<A href='?src=\ref[src];unsec_system=1'>[src.sec_system]</A>"
	else
		dat += "None Installed"
	////Locking System
	dat += "<HR><B>Locking System</B>: "
	if(src.lock)
		dat += "<A href='?src=\ref[src];un_lock=1'>[src.lock]</A>"
	else
		dat += "None Installed"

	user.Browse(dat, "window=ship_maint")
	onclose(user, "ship_maint")
	return
/////////////////////////////////////////////////////////////////////
////////Main Ship Computer Access 						////////////
/////////////////////////////////////////////////////////////////////
/obj/machinery/vehicle/proc/access_computer(mob/user as mob)
	if(user.loc != src)
		return
	src.add_dialog(user)

	var/dat = "<TT><B>[src] Control Console</B><BR><HR><BR>"
	dat += "<B>Hull Integrity:</B> [src.health/src.maxhealth * 100]%<BR>"
	dat += "<B>Current Power Usage:</B> [src.powercurrent]/[src.powercapacity]<BR>"
	dat += "<B>Air Status:</B> "
	if(src.atmostank && src.atmostank.air_contents)
		var/pressure = MIXTURE_PRESSURE(atmostank.air_contents)
		var/total_moles = TOTAL_MOLES(atmostank.air_contents)

		dat += "Pressure: [round(pressure,0.1)] kPa"

		if (total_moles)
			var/o2_level = atmostank.air_contents.oxygen/total_moles
			var/n2_level = atmostank.air_contents.nitrogen/total_moles
			var/co2_level = atmostank.air_contents.carbon_dioxide/total_moles
			var/plasma_level = atmostank.air_contents.toxins/total_moles
			var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)

			dat += " Nitrogen: [round(n2_level*100)]% Oxygen: [round(o2_level*100)]% Carbon Dioxide: [round(co2_level*100)]% Plasma: [round(plasma_level*100)]%"

			if(unknown_level > 0.01)
				dat += " OTHER: [round(unknown_level)]%"

		dat += " Temperature: [round(TO_CELSIUS(atmostank.air_contents.temperature))]&deg;C<br>"
	else
		dat += "<font color=red>No tank installed!</font><BR>"
	dat += "<B>Fuel Status:</B> "
	if(src.fueltank && src.fueltank.air_contents)

		var/pressure = MIXTURE_PRESSURE(fueltank.air_contents)
		var/total_moles = TOTAL_MOLES(fueltank.air_contents)

		dat += "Pressure: [round(pressure,0.1)] kPa"

		if (total_moles)
			var/o2_level = fueltank.air_contents.oxygen/total_moles
			var/n2_level = fueltank.air_contents.nitrogen/total_moles
			var/co2_level = fueltank.air_contents.carbon_dioxide/total_moles
			var/plasma_level = fueltank.air_contents.toxins/total_moles
			var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)

			dat += " Nitrogen: [round(n2_level*100)]% Oxygen: [round(o2_level*100)]% Carbon Dioxide: [round(co2_level*100)]% Plasma: [round(plasma_level*100)]%"

			if(unknown_level > 0.01)
				dat += " OTHER: [round(unknown_level)]%"

		dat += " Temperature: [round(TO_CELSIUS(fueltank.air_contents.temperature))]&deg;C<br>"
	else
		dat += "<font color=red>No tank installed!</font><BR>"
	if(src.engine)
		if(src.engine.active)
			dat += {"<HR><B>Engine</B>: <I><A href='?src=\ref[src];enginecomp=1'>[src.engine]</A></I>"}
			dat += {"<BR><A href='?src=\ref[src];dengine=1'>(Deactivate)</A>"}
		else
			dat += {"<HR><B>Engine</B>: <I>[src.engine]</I>"}
			dat += {"<BR><A href='?src=\ref[src];aengine=1'>(Activate)</A>"}
	if(src.life_support)
		dat += {"<HR><B>Life Support</B>: <I>[src.life_support]</I>"}
		if(src.life_support.active)
			dat += {"<BR><A href='?src=\ref[src];dlife=1'>(Deactivate)</A>"}
		else
			dat += {"<BR><A href='?src=\ref[src];alife=1'>(Activate)</A>"}
		dat+={"([src.life_support.power_used])<BR>"}
	if(src.com_system)
		if(src.com_system.active)
			dat += {"<HR><B>Com System</B>: <I><A href='?src=\ref[src];comcomp=1'>[src.com_system]</A></I>"}
			dat += {"<BR><A href='?src=\ref[src];dcom=1'>(Deactivate)</A>"}
		else
			dat += {"<HR><B>Com System</B>: <I>[src.com_system]</I>"}
			dat += {"<BR><A href='?src=\ref[src];acom=1'>(Activate)</A>"}
		dat+= {"([src.com_system.power_used])"}
	if(src.m_w_system)
		if(src.m_w_system.active)
			dat += {"<HR><B>Main Weapon</B>: <I><A href='?src=\ref[src];mweaponcomp=1'>[src.m_w_system]</A></I> "}
			dat += {"<BR><A href='?src=\ref[src];dmweapon=1'>(Deactivate)</A>"}
		else
			dat += {"<HR><B>Main Weapon</B>: <I>[src.m_w_system]</I>"}
			dat += {"<BR><A href='?src=\ref[src];amweapon=1'>(Activate)</A>"}
		dat+= {"([src.m_w_system.power_used])"}
	if(src.sensors)
		if(src.sensors.active)
			dat += {"<HR><B>Sensors</B>: <I><A href='?src=\ref[src];sensorcomp=1'>[src.sensors]</A></I> "}
			dat += {"<BR><A href='?src=\ref[src];dsensors=1'>(Deactivate)</A>"}
		else
			dat += {"<HR><B>Sensors</B>: <I>[src.sensors]</I>"}
			dat += {"<BR><A href='?src=\ref[src];asensors=1'>(Activate)</A>"}
		dat+= {"([src.sensors.power_used])"}
	if(src.sec_system)
		if(src.sec_system.active)
			dat += {"<HR><B>Secondary System</B>: <I><A href='?src=\ref[src];sec_systemcomp=1'>[src.sec_system]</A></I> "}
			dat += {"<BR><A href='?src=\ref[src];dsec_system=1'>(Deactivate)</A>"}
		else
			dat += {"<HR><B>Secondary System</B>: <I><A href='?src=\ref[src];sec_systemcomp=1'>[src.sec_system]</A></I> "}
			dat += {"<BR><A href='?src=\ref[src];asec_system=1'>(Activate)</A>"}
		dat+= {"([src.sec_system.power_used])"}
	if(src.lock)
		if(src.locked)
			dat += "<HR><B>Lock</B>:<br><a href='?src=\ref[src.lock];unlock=1'>(Unlock)</a>"
		else
			dat += "<HR><B>Lock</B>:"
			if (src.lock.code)
				dat += "<br><a href='?src=\ref[src.lock];lock=1'>(Lock)</a>"

			dat += " <a href='?src=\ref[src.lock];setcode=1;'>(Set Code)</a>"
	user.Browse(dat, "window=ship_main")
	onclose(user, "ship_main")
	return

/////////////////////////////////////////////////////////////////////////////////
/////// New Vehicle Code 	///////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

/obj/machinery/vehicle/proc/setup_ion_trail()
	//////Ion Trail Setup
	src.ion_trail = new /datum/effects/system/ion_trail_follow()
	src.ion_trail.set_up(src)

/obj/machinery/vehicle/New()
	..()
	name += "[pick(rand(1, 999))]"
	if(prob(1))
		var/new_name = phrase_log.random_phrase("vehicle")
		if(new_name)
			src.name = html_encode(new_name)
	setup_ion_trail()

	if (!movement_controller)
		movement_controller = new /datum/movement_controller/pod(src)

	src.myhud = new /datum/hud/pod(src)
	///Engine Setup
	src.fueltank = new /obj/item/tank/plasma( src )
	src.engine = new /obj/item/shipcomponent/engine( src )
	src.engine.ship = src
	src.components += src.engine
	src.engine.activate()

	/////Life Support Setup
	src.atmostank = new /obj/item/tank/air( src )
	src.life_support = new /obj/item/shipcomponent/life_support( src )
	src.life_support.ship = src
	src.components += src.life_support
	src.life_support.activate()
	/////Com-System Setup
	src.intercom = new /obj/item/device/radio/intercom/ship( src )
	//src.intercom.icon_state = src.icon_state
	src.com_system = new src.init_comms_type(src)
	src.com_system.ship = src
	src.components += src.com_system
	src.com_system.activate()
	///// Sensor System Setup
	src.sensors = new /obj/item/shipcomponent/sensor( src )
	src.sensors.ship = src
	src.components += src.sensors
	src.sensors.activate()
	myhud.update_systems()
	myhud.update_states()
	///// Lights Subsystem
	src.lights = new /obj/item/shipcomponent/pod_lights/pod_1x1( src )
	src.lights.ship = src
	src.components += src.lights

	START_TRACKING_CAT(TR_CAT_PODS_AND_CRUISERS)

/obj/machinery/vehicle/get_movement_controller()
	return movement_controller

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////					MouseDrop Crate Loading						////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

/obj/machinery/vehicle/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (!user.client || !isliving(user) || isintangible(user))
		return
	if (is_incapacitated(user))
		user.show_text("Not when you're incapacitated.", "red")
		return
	if (!can_reach(user, src))
		return

	if(locked)
		boutput(user, "<span class='alert'>[src] is locked!</span>")
		return

	if(isliving(O) && O:stat != 2)
		if (O == user)
			src.board_pod(O)
		else
			boutput(user, "<span class='alert'>You can't shove someone else into a pod.</span>")

		return

	var/obj/item/shipcomponent/secondary_system/SS = src.sec_system
	if (!SS)
		return
	SS.Clickdrag_ObjectToPod(user,O)
	return

/obj/machinery/vehicle/mouse_drop(over_object, src_location, over_location)
	if (!usr.client || !isliving(usr) || isintangible(usr))
		return
	if (is_incapacitated(usr))
		usr.show_text("Not when you're incapacitated.", "red")
		return

	if(locked)
		boutput(usr, "<span class='alert'>[src] is locked!</span>")
		return

	var/obj/item/shipcomponent/secondary_system/SS = src.sec_system
	if (!SS)
		return
	SS.Clickdrag_PodToObject(usr,over_object)
	return

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////					Ship Verbs									////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

/*
/mob/proc/make_shipcrewmember(weapon_class as num)
	//boutput(world, "Is called for [src.name]")
	src.verbs += /client/proc/access_main_computer
	if(weapon_class)
		src.verbs += /client/proc/fire_main_weapon
	src.verbs += /client/proc/use_external_speaker
	src.verbs += /client/proc/access_sensors
	src.verbs += /client/proc/create_wormhole
	src.verbs += /client/proc/use_secondary_system
	src.verbs += /client/proc/open_hangar
	src.verbs += /client/proc/return_to_station
	return

/mob/proc/remove_shipcrewmember_powers(weapon_class as num)
	src.verbs -= /client/proc/access_main_computer
	if(weapon_class)
		src.verbs -= /client/proc/fire_main_weapon
	src.verbs -= /client/proc/use_external_speaker
	src.verbs -= /client/proc/access_sensors
	src.verbs -= /client/proc/create_wormhole
	src.verbs -= /client/proc/use_secondary_system
	src.verbs -= /client/proc/open_hangar
	src.verbs -= /client/proc/return_to_station
	return
*/

/obj/machinery/vehicle/proc/access_main_computer()
	if(is_incapacitated(usr))
		boutput(usr, "<span class='alert'>Not when you are incapacitated.</span>")
		return
	if(istype(usr.loc, /obj/machinery/vehicle/))
		var/obj/machinery/vehicle/ship = usr.loc
		ship.access_computer(usr)
	else
		boutput(usr, "<span class='alert'>Uh-oh you aren't in a ship! Report this.</span>")

/obj/machinery/vehicle/proc/fire_main_weapon(mob/user)
	if(is_incapacitated(user))
		boutput(user, "<span class='alert'>Not when you are incapacitated.</span>")
		return
	if(istype(user.loc, /obj/machinery/vehicle/))
		var/obj/machinery/vehicle/ship = user.loc
		if(ship.stall)
			return
		if(ship.m_w_system)
			if(ship.m_w_system.active)
				if(ship.m_w_system.r_gunner)
					if(user == ship.m_w_system.gunner)
						ship.stall += 1
						ship.m_w_system.Fire(user, src.facing)
					else
						boutput(user, "[ship.ship_message("You must be in the gunner seat!")]")
				else
					ship.m_w_system.Fire(user, src.facing)
			else
				boutput(user, "[ship.ship_message("SYSTEM OFFLINE")]")
		else
			boutput(user, "[ship.ship_message("System not installed in ship!")]")
	else
		boutput(user, "<span class='alert'>Uh-oh you aren't in a ship! Report this.</span>")

/obj/machinery/vehicle/proc/use_external_speaker()
	if(is_incapacitated(usr))
		boutput(usr, "<span class='alert'>Not when you are incapacitated.</span>")
		return
	if(istype(usr.loc, /obj/machinery/vehicle/))
		var/obj/machinery/vehicle/ship = usr.loc
		if(ship.com_system)
			if(ship.com_system.active)
				ship.com_system.External()
			else
				boutput(usr, "[ship.ship_message("SYSTEM OFFLINE")]")
		else
			boutput(usr, "[ship.ship_message("System not installed in ship!")]")
	else
		boutput(usr, "<span class='alert'>Uh-oh you aren't in a ship! Report this.</span>")

/obj/machinery/vehicle/proc/create_wormhole()//HEY THIS DOES SAMETHING AS HUD POD BUTTON
	if(is_incapacitated(usr))
		boutput(usr, "<span class='alert'>Not when you are incapacitated.</span>")
		return
	if(istype(usr.loc, /obj/machinery/vehicle/))
		var/obj/machinery/vehicle/ship = usr.loc
		if(ship.engine && !istype(ship,/obj/machinery/vehicle/tank/car))
			if(ship.engine.active)
				if(ship.engine.ready)
					var/turf/T = ship.loc
					if (istype(T) && T.allows_vehicles)
						ship.engine.Wormhole()
					else
						boutput(usr, "[ship.ship_message("Cannot create wormhole on this flooring!")]")
				else
					boutput(usr, "[ship.ship_message("Engine recharging wormhole capabilities!")]")
			else
				boutput(usr, "[ship.ship_message("SYSTEM OFFLINE")]")
		else
			boutput(usr, "[ship.ship_message("System not installed in ship!")]")
	else
		boutput(usr, "<span class='alert'>Uh-oh you aren't in a ship! Report this.</span>")


/obj/machinery/vehicle/proc/access_sensors()
	if(is_incapacitated(usr))
		boutput(usr, "<span class='alert'>Not when you are incapacitated.</span>")
		return
	if(istype(usr.loc, /obj/machinery/vehicle/))
		var/obj/machinery/vehicle/ship = usr.loc
		if(ship.sensors)
			if(ship.sensors.active)
				ship.sensors.opencomputer(usr)

			else
				boutput(usr, "[ship.ship_message("SYSTEM OFFLINE")]")
		else
			boutput(usr, "[ship.ship_message("System not installed in ship!")]")
	else
		boutput(usr, "<span class='alert'>Uh-oh you aren't in a ship! Report this.</span>")



/obj/machinery/vehicle/proc/use_secondary_system()
	if(is_incapacitated(usr))
		boutput(usr, "<span class='alert'>Not when you are incapacitated.</span>")
		return
	if(istype(usr.loc, /obj/machinery/vehicle/))
		var/obj/machinery/vehicle/ship = usr.loc
		if(ship.sec_system)
			if(ship.sec_system.active || ship.sec_system.f_active)
				if(ship.sec_system.ready)
					ship.sec_system.Use(usr)
				else
					boutput(usr, "[ship.ship_message("Secondary System isn't ready for use yet!")]")
			else
				boutput(usr, "[ship.ship_message("SYSTEM OFFLINE")]")
		else
			boutput(usr, "[ship.ship_message("System not installed in ship!")]")
	else
		boutput(usr, "<span class='alert'>Uh-oh you aren't in a ship! Report this.</span>")

/obj/machinery/vehicle/proc/open_hangar()
	if(is_incapacitated(usr))
		boutput(usr, "<span class='alert'>Not when you are incapacitated.</span>")
		return
	if(istype(usr.loc, /obj/machinery/vehicle/))
		var/obj/machinery/vehicle/ship = usr.loc
		if(ship.com_system)
			if(ship.com_system.active)
				ship.com_system.rc_ship.open_hangar(usr)
			else
				boutput(usr, "[ship.ship_message("SYSTEM OFFLINE")]")
		else
			boutput(usr, "[ship.ship_message("System not installed in ship!")]")
	else
		boutput(usr, "<span class='alert'>Uh-oh you aren't in a ship! Report this.</span>")

/obj/machinery/vehicle/proc/return_to_station()
	if(is_incapacitated(usr))
		boutput(usr, "<span class='alert'>Not when you are incapacitated.</span>")
		return
	if(istype(usr.loc, /obj/machinery/vehicle/))
		var/obj/machinery/vehicle/ship = usr.loc
		if(ship.com_system)
			if(ship.com_system.active)
				if(ship.com_system.go_home())
					return
				ship.going_home = 1
				boutput(usr, "[ship.ship_message("Course set for station level. Traveling off the edge of the current level will take you to the station level.")]")
			else
				boutput(usr, "[ship.ship_message("SYSTEM OFFLINE")]")
		else
			boutput(usr, "[ship.ship_message("System not installed in ship!")]")
	else
		boutput(usr, "<span class='alert'>Uh-oh you aren't in a ship! Report this.</span>")

/obj/machinery/vehicle/proc/go_home()
	. = src.com_system?.get_home_turf()



//TODO

// make ships less destructive (maybe depends on Mass and Speed?)

/obj/machinery/vehicle/tank
	name = "tank"
	icon = 'icons/obj/machines/8dirvehicles.dmi'
	icon_state = "minisub_body"
	var/body_type = "minisub"
	var/obj/item/shipcomponent/locomotion/locomotion = null //wheels treads hovermagnets etc
	uses_weapon_overlays = 0
	health = 100
	maxhealth = 100
	speed = 0 // speed literally does nothing? what??
	stall = 0 // slow the ship down when firing
	weapon_class = 1

	var/prev_velocity = 0
	ram_self_damage_multiplier = 0.14
	//var/datum/movement_controller/pod/movement_controller

	New()
		..()
		name = "minisub"

	Move(NewLoc,Dir=0,step_x=0,step_y=0)
		.=..(NewLoc,Dir,step_x,step_y)

		if (movement_controller && istype(movement_controller,/datum/movement_controller/tank))
			var/datum/movement_controller/tank/M = movement_controller
			if (M.squeal_sfx)
				M.squeal_sfx = 0
				playsound(src, 'sound/machines/car_screech.ogg', 40, 1)
			if (M.accel_sfx)
				M.accel_sfx = 0
				playsound(src, 'sound/machines/rev_engine.ogg', 40, 1)

	get_move_velocity_magnitude()
		.= movement_controller:velocity_magnitude

	Install(obj/item/shipcomponent/S as obj)
		if(S.system == "Locomotion")
			if (istype(src,/obj/machinery/vehicle/tank))
				var/obj/machinery/vehicle/tank/T = src
				if (!T.locomotion)
					T.locomotion = S
					T.overlays += image('icons/obj/machines/8dirvehicles.dmi', "[body_type]_[locomotion.appearanceString]")
				else
					if (usr) //Occuring during gameplay
						boutput(usr, "That system already has a part!")
					return
		..(S)

		 //lol
		if (S.system == "Locomotion")
			src.locomotion.activate()

	proc/remove_locomotion()
		if (src.locomotion)
			locomotion.deactivate()
			components -= locomotion
			src.overlays -= image('icons/obj/machines/8dirvehicles.dmi', "[body_type]_[locomotion.appearanceString]")
			locomotion.set_loc(src.loc)
			locomotion = null

/obj/machinery/vehicle/tank/minisub
	body_type = "minisub"
	event_handler_flags = USE_FLUID_ENTER | IMMUNE_MANTA_PUSH
	acid_damage_multiplier = 0.5

	New()
		..()
		Install(new /obj/item/shipcomponent/locomotion/treads(src))

/obj/machinery/vehicle/tank/minisub/pilot
	body_type = "minisub"
	health = 150
	maxhealth = 150


	New()
		..()
		src.com_system.deactivate()
		qdel(src.engine)
		qdel(src.com_system)
		src.components -= src.engine
		src.components -= src.com_system
		src.engine = null
		Install(new /obj/item/shipcomponent/engine/zero(src))
		Install(new /obj/item/shipcomponent/mainweapon/bad_mining(src))
		src.engine.activate()
		src.com_system = null
		myhud.update_systems()
		myhud.update_states()
		new /obj/item/sea_ladder(src)

/obj/machinery/vehicle/tank/minisub/secsub
	body_type = "minisub"
	icon_state = "secsub_body"
	health = 150
	maxhealth = 150
	init_comms_type = /obj/item/shipcomponent/communications/security

	New()
		..()
		name = "security patrol minisub"
		Install(new /obj/item/shipcomponent/mainweapon/taser(src))
		Install(new /obj/item/shipcomponent/secondary_system/lock(src))
		myhud.update_systems()
		myhud.update_states()


/obj/machinery/vehicle/tank/minisub/syndisub
	body_type = "minisub"
	icon_state = "syndisub_body"
	health = 150
	maxhealth = 150
	acid_damage_multiplier = 0
	init_comms_type = /obj/item/shipcomponent/communications/syndicate

	New()
		..()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		name = "syndicate minisub"
		src.lock = new /obj/item/shipcomponent/secondary_system/lock(src)
		src.lock.ship = src
		src.components += src.lock
		myhud.update_systems()
		myhud.update_states()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

/obj/machinery/vehicle/tank/minisub/mining
	body_type = "minisub"
	icon_state = "miningsub_body"
	health = 130
	maxhealth = 130

	New()
		..()
		name = "mining minisub"
		Install(new /obj/item/shipcomponent/mainweapon/bad_mining(src))
		Install(new /obj/item/shipcomponent/secondary_system/cargo(src))

/obj/machinery/vehicle/tank/minisub/civilian
	body_type = "minisub"
	icon_state = "whitesub_body"

	New()
		..()
		name = "civilian minisub"

/obj/machinery/vehicle/tank/minisub/heavy
	body_type = "minisub"
	icon_state = "graysub_body"
	health = 130
	maxhealth = 130

	New()
		..()
		name = "heavy minisub"

/obj/machinery/vehicle/tank/minisub/industrial
	body_type = "minisub"
	icon_state = "blacksub_body"
	health = 150
	maxhealth = 150

	New()
		..()
		name = "industrial minisub"

/obj/machinery/vehicle/tank/minisub/black
	body_type = "minisub"
	icon_state = "blacksub_body"
	health = 175
	maxhealth = 175

	New()
		..()
		name = "strange minisub"

/obj/machinery/vehicle/tank/minisub/engineer
	body_type = "minisub"
	icon_state = "graysub_body"

	New()
		..()
		name = "engineering minisub"
		Install(new /obj/item/shipcomponent/mainweapon/foamer(src))
		Install(new /obj/item/shipcomponent/secondary_system/cargo(src))


/obj/machinery/vehicle/tank/minisub/escape_sub
	name = "escape sub"
	body_type = "minisub"
	desc = "A small one-person sub that scans for the emergency shuttle's engine signature and warps to it mid-transit. These are notorious for lacking any safety checks. <br>It looks sort of rickety..."
	icon_state = "escapesub_body"
	capacity = 1
	health = 60
	maxhealth = 60
	weapon_class = 1
	speed = 5
	var/fail_type = 0
	var/launched = 0
	var/steps_moved = 0
	var/failing = 0
	var/succeeding = 0
	var/did_warp = 0

	New()
		. = ..()
		src.components -= src.engine
		qdel(src.engine)
		src.engine = new /obj/item/shipcomponent/engine/escape(src)
		src.components += src.engine
		src.engine.ship = src
		src.engine.activate()

	finish_board_pod(var/mob/boarder)
		..()
		if (!src.pilot) return //if they were stopped from entering by other parts of the board proc from ..()
		SPAWN(0)
			src.escape()

	proc/escape()
		if(!launched)
			launched = 1
			anchored = UNANCHORED
			var/opened_door = 0
			var/turf_in_front = get_step(src,src.dir)
			for(var/obj/machinery/door/poddoor/D in turf_in_front)
				D.open()
				opened_door = 1
			if(opened_door) sleep(2 SECONDS) //make sure it's fully open
			playsound(src.loc, 'sound/effects/bamf.ogg', 100, 0)
			sleep(0.5 SECONDS)
			playsound(src.loc, 'sound/effects/flameswoosh.ogg', 100, 0)
			while(!failing)
				var/loc = src.loc
				step(src,src.dir)
				if(src.loc == loc) //we hit something
					explosion(src, src.loc, 1, 1, 2, 3)
					break
				steps_moved++
				if(prob((steps_moved-7) * 3) && !succeeding)
					fail()
				if (prob((steps_moved-7) * 4))
					succeed()
				sleep(0.4 SECONDS)

	proc/test()
		boutput(world,"shuttle loc is [emergency_shuttle.location]")

	proc/succeed()
		if (succeeding && prob(3))
			succeeding = 0
		if (emergency_shuttle.location == SHUTTLE_LOC_TRANSIT & !did_warp) //lol sorry hardcoded a define thing
			succeeding = 1
			did_warp = 1

			playsound(src.loc, "warp", 50, 1, 0.1, 0.7)

			var/obj/portal/P = new /obj/portal
			P.set_loc(get_turf(src))
			var/turf/T = pick_landmark(LANDMARK_ESCAPE_POD_SUCCESS)
			P.target = T
			src.dir = map_settings ? map_settings.escape_dir : SOUTH
			src.set_loc(T)
			logTheThing(LOG_STATION, src, "creates an escape portal at [log_loc(src)].")


	proc/fail()
		failing = 1
		if(!fail_type) fail_type = rand(1,8)
		switch(fail_type)
			if(1) //dies
				shipdeath()
			if(2) //fuel tank explodes??
				pilot << sound('sound/machines/engine_alert1.ogg')
				boutput(pilot, "<span class='alert'>The fuel tank of your escape sub explodes!</span>")
				explosion(src, src.loc, 2, 3, 4, 6)
			if(3) //falls apart
				pilot << sound('sound/machines/engine_alert1.ogg')
				boutput(pilot, "<span class='alert'>Your escape sub is falling apart around you!</span>")
				while(src)
					step(src,src.dir)
					if(prob(50))
						make_cleanable(/obj/decal/cleanable/robot_debris/gib, src.loc)
					if(prob(20) && pilot)
						boutput(pilot, "<span class='alert'>You fall out of the rapidly disintegrating escape sub!</span>")
						src.leave_pod(pilot)
					if(prob(10)) shipdeath()
					sleep(0.4 SECONDS)
			if(4) //flies off course
				pilot << sound('sound/machines/engine_alert1.ogg')
				boutput(pilot, "<span class='alert'>Your escape sub is veering out of control!</span>")
				while(src)
					if(prob(10)) src.dir = turn(dir,pick(90,-90))
					var/loc = src.loc
					step(src,src.dir)
					if(src.loc == loc) //we hit something
						explosion(src, src.loc, 1, 1, 2, 3)
						break
					sleep(0.4 SECONDS)
			if(5)
				boutput(pilot, "<span class='alert'>Your escape sub sputters to a halt!</span>")
			if(6)
				boutput(pilot, "<span class='alert'>Your escape sub explosively decompresses, hurling you into the ocean!</span>")
				pilot << sound('sound/effects/Explosion2.ogg')
				if(ishuman(pilot))
					var/mob/living/carbon/human/H = pilot
					for(var/effect in list("sever_left_leg","sever_right_leg","sever_left_arm","sever_right_arm"))
						if(prob(40))
							SPAWN(rand(0,5))
								H.bioHolder.AddEffect(effect)
				src.leave_pod(pilot)
				src.icon_state = "escape_nowindow"
				while(src)
					var/loc = src.loc
					step(src,src.dir)
					if(src.loc == loc) //we hit something
						explosion(src, src.loc, 1, 1, 2, 3)
						break
					else if(prob(2)) shipdeath()
					sleep(0.4 SECONDS)

			if(7)
				boutput(pilot, "<span class='alert'>Your escape sub begins to accelerate!</span>")
				var/speed = 5
				while(speed)
					var/loc = src.loc
					step(src,src.dir)
					if(src.loc == loc) //we hit something
						explosion(src, src.loc, 1, 1, 2, 3)
						break
					if(speed > 1 && prob(10)) speed--
					if(speed == 1 && prob(5))
						boutput(pilot, "<span class='alert'>Your escape sub is moving so fast that it tears itself apart!</span>")
						shipdeath()
					else if(prob(10/speed))
						boutput(pilot, "<span class='alert'>Your escape sub is [pick("vibrating","shuddering","shaking")] [pick("alarmingly","worryingly","violently","terribly","scarily","weirdly","distressingly")]!</span>")
					sleep(speed)
			if(8)
				boutput(pilot, "<span class='alert'>Your escape sub starts to drive around in circles [pick("awkwardly","embarrassingly","sadly","pathetically","shamefully","ridiculously")]!</span>")
				pilot << sound('sound/machines/engine_alert1.ogg')
				var/spin_dir = pick(90,-90)
				while(src)
					src.dir = turn(dir,spin_dir)
					var/loc = src.loc
					step(src,src.dir)
					if(src.loc == loc) //we hit something
						explosion(src, src.loc, 1, 1, 2, 3)
						break
					if(prob(2)) //we don't want to do this forever so let's explode
						shipdeath()
					sleep(0.4 SECONDS)

/obj/machinery/vehicle/tank/truck
	body_type = "truck"
	icon_state = "truck_body"
	req_smash_velocity = 7

	New()
		..()
		name = "little truck"
		Install(new /obj/item/shipcomponent/locomotion/wheels(src))

// Gannets' Station Car/Vehicle Zone
/* To-Do:
	Remove space travel, station tiles only.
	More colours and installed components for specific departments.
	Give sec-car the police siren that segways use.
*/

/obj/machinery/vehicle/tank/car
	name = "personal car"
	desc = "A Toriyama-Okawara AV-92 personal mobility vehicle, designed for quick travel on space stations."
	body_type = "car"
	icon_state = "whitecar1_full"
	health = 90
	maxhealth = 90

	New()
		..()
		Install(new /obj/item/shipcomponent/locomotion/wheels(src))

	//Colours
	black
		body_type = "car"
		icon_state = "car_black"

	purple
		body_type = "car"
		icon_state = "car_purple"

	blue
		body_type = "car"
		icon_state = "car_blue"

	yellow
		body_type = "car"
		icon_state = "car_yellow"

	red
		body_type = "car"
		icon_state = "car_red"

	whitered
		body_type = "car"
		icon_state = "car_whitered"

	whiteyellow
		body_type = "car"
		icon_state = "car_whiteyellow"

	rusty
		body_type = "car"
		icon_state = "car_rusty"
		desc = "A Toriyama-Okawara AV-92 personal mobility vehicle, designed for quick travel on space stations. Kinda looks like this one's been sat rotting at the bottom of the ocean for a few years."

	//Department cars

	security
		body_type = "car"
		icon_state = "seccar1_full"
		health = 110
		maxhealth = 110

		New()
			..()
			name = "security patrol car"
			desc = "A Toriyama-Okawara SV-93 personal mobility vehicle, outfitted with a taser gun, siren system and a security livery."
			Install(new /obj/item/shipcomponent/mainweapon/taser(src))

			src.lights = new /obj/item/shipcomponent/pod_lights/police_siren( src )
			src.lights.ship = src
			src.components += src.lights
/*
	engineering
		body_type =
		icon_state =

		New()
			..()
			name = "engineering car
			desc = "A Toriyama-Okawara EV-94 personal mobility vehicle, painted in engineering colours."
*/
