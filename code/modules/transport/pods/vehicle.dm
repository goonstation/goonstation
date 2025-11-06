/obj/machinery/vehicle
	name = "Vehicle Pod"
	icon = 'icons/obj/ship.dmi'
	icon_state = "podfire"
	density = 1
	flags = USEDELAY
	anchored = ANCHORED
	stops_space_move = 1
	status = REQ_PHYSICAL_ACCESS
	var/numbers_in_name = TRUE //! Whether to append a random number to the name of the vehicle
	var/datum/effects/system/ion_trail_follow/ion_trail = null
	var/mob/pilot = null //The mob which actually flys the ship
	var/capacity = 3 //How many passengers the ship can hold
	var/passengers = 0 //The number of passengers in the ship

	var/obj/item/tank/atmostank = null // provides the air for the passengers
	var/obj/item/tank/fueltank = null // provides fuel, different mixes affect engine performance
	var/obj/item/device/radio/intercom/ship/intercom = null //All ships have these is used by communication array

	///Associative list of part slot to the part installed in it
	var/list/installed_parts = list(POD_PART_ENGINE=null, POD_PART_LIFE_SUPPORT=null, POD_PART_COMMS=null, \
		POD_PART_MAIN_WEAPON=null, POD_PART_SECONDARY=null, POD_PART_SENSORS=null, POD_PART_LOCK=null, POD_PART_LIGHTS=null)

	/// brake toggle
	var/rcs = TRUE
	var/uses_weapon_overlays = 0
	var/health = 200
	var/maxhealth = 200
	var/health_percentage = 100 // cogwerks: health percentage check for bigpods
	var/damage_overlays = 0 // cogwerks: 0 = normal, 1 = dented, 2 = on fire
	var/acid_damage_multiplier = 1 // kubius: multiplier to damage taken from acid sea turfs (1 is full, 0 is none). 0 for syndie, 0.5 for subs
	var/weapon_class = 0 //what weapon class a ship is
	var/powercapacity = 0 //How much power the ship's components can use, set by engine
	var/powercurrent = 0 //How much power the components are using
	/// multiplicative ship speed modification
	var/speedmod = 1
	/// acceleration modification provided by afterburner if installed
	var/afterburner_accel_mod = 1
	/// speed modification provided by afterburner if installed
	var/afterburner_speed_mod = 1
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
	var/init_comms_type = /obj/item/shipcomponent/communications
	var/faction = null // I don't really want to atom level define this, but it does make sense for pods to have faction too

	/// allow muzzle flash when firing pod weapon
	var/allow_muzzle_flash = TRUE

	//////////////////////////////////////////////////////
	///////Life Support Stuff ////////////////////////////
	/////////////////////////////////////////////////////

	New()
		src.contextActions = childrentypesof(/datum/contextAction/vehicle)
		src.facing = src.dir

		. = ..()
		START_TRACKING


	remove_air(amount as num)
		var/obj/item/shipcomponent/life_support/life_support_part = src.get_part(POD_PART_LIFE_SUPPORT)
		if(atmostank?.air_contents)
			if(life_support_part?.active && MIXTURE_PRESSURE(atmostank.air_contents) < 1000)
				life_support_part.power_used = 5 * passengers + 15
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
			life_support_part?.power_used = 0
			var/turf/T = get_turf(src)
			return T.remove_air(amount)

	handle_internal_lifeform(mob/lifeform_inside_me, breath_request, mult)
		if (breath_request>0)
			return remove_air(breath_request * mult)
		else
			return null

	Click(location,control,params)
		if(istype(usr, /mob/dead/observer) && usr.client && !usr.client.keys_modifier)
			var/mob/dead/observer/O = usr
			if(src.pilot)
				O.insert_observer(src.pilot)
		else
			. = ..()

	/////////////////////////////////////////////////////////
	///////Attack Code									////
	////////////////////////////////////////////////////////

	attackby(obj/item/W, mob/living/user)
		user.lastattacked = get_weakref(src)
		if (health < maxhealth && isweldingtool(W) && W:welding)
			if (actions.hasAction(user, /datum/action/bar/private/welding/loop/vehicle))
				return
			var/datum/action/bar/icon/callback/action_bar
			var/list/positions = src.get_welding_positions()
			action_bar = new /datum/action/bar/private/welding/loop/vehicle(user, src, \
			proc_path=/obj/machinery/vehicle/proc/weld_action, \
			proc_args=list(user), \
			start=positions[1], \
			stop=positions[2], \
			tool=W)
			actions.start(action_bar, user)
			return

		if (istype(W, /obj/item/ammo/bullets))
			if (W.disposed)
				return
			var/obj/item/shipcomponent/mainweapon/main_weapon = src.get_part(POD_PART_MAIN_WEAPON)
			if(!main_weapon)
				boutput(user, SPAN_ALERT("No main weapon system installed."))
				return
			if (!main_weapon.uses_ammunition)
				boutput(user, SPAN_ALERT("That weapon does not require ammunition."))
				return
			if (main_weapon.remaining_ammunition >= 50)
				boutput(user, SPAN_ALERT("The automated loader for the weapon cannot hold any more ammunition."))
				return
			var/obj/item/ammo/bullets/ammo = W
			if (!ammo.amount_left)
				return
			if (main_weapon.current_projectile.type != ammo.ammo_type.type)
				boutput(user, SPAN_ALERT("The [main_weapon] cannot fire that kind of ammunition."))
				return
			var/may_load = 50 - main_weapon.remaining_ammunition
			if (may_load < ammo.amount_left)
				ammo.amount_left -= may_load
				main_weapon.remaining_ammunition += may_load
				boutput(user, SPAN_NOTICE("You load [may_load] ammunition from [ammo]. [ammo] now contains [ammo.amount_left] ammunition."))
				logTheThing(LOG_COMBAT, user, "reloads [src]'s [main_weapon.name] (<b>Ammo type:</b> <i>[main_weapon.current_projectile.type]</i>) at [log_loc(src)].") // Might be useful (Convair880)
				return
			else
				main_weapon.remaining_ammunition += ammo.amount_left
				ammo.amount_left = 0
				boutput(user, SPAN_NOTICE("You load [ammo] into [main_weapon]."))
				logTheThing(LOG_COMBAT, user, "reloads [src]'s [main_weapon.name] (<b>Ammo type:</b> <i>[main_weapon.current_projectile.type]</i>) at [log_loc(src)].")
				qdel(ammo)
				return

		if (istype(W, /obj/item/device/key))
			user.visible_message(SPAN_ALERT("<B>[user] scratches [src] with \the [W]! [prob(75) ? pick_string("descriptors.txt", "jerks") : null]</B>"), null,SPAN_ALERT("You hear a metallic scraping sound!"))
			if(!keyed) src.name = "scratched-up [src.name]"
			src.keyed++
			src.add_fingerprint(user)
			return

		if (istype(W, /obj/item/sheet))
			var/obj/item/shipcomponent/mainweapon/main_weapon = src.get_part(POD_PART_MAIN_WEAPON)
			if (istype(main_weapon,/obj/item/shipcomponent/mainweapon/constructor))
				main_weapon.Attackby(W,user)
				return

		if (istype(W, /obj/item/tank/plasma))
			src.open_parts_panel(user)
			return

		..()

		if (W.force)
			ON_COOLDOWN(src, "in_combat", 5 SECONDS)

		attack_particle(user,src)
		playsound(src.loc, W.hitsound, 50, 1, -1)
		hit_twitch(src)

		switch(W.hit_type)
			if (DAMAGE_BURN)
				src.material_trigger_on_temp(W.force * 1000)
				if (prob(W.force*2))
					playsound(src.loc, 'sound/impact_sounds/Metal_Clang_1.ogg', 50, 1, -1)
					for (var/mob/M in src)
						M.changeStatus("knockdown",1 SECONDS)
						M.show_text("The physical shock of the blow knocks you around!", "red")
				return /////ships should pretty much be immune to fire
			else
				src.health -= W.force
				if (prob(W.force*3))
					playsound(src.loc, 'sound/impact_sounds/Metal_Clang_1.ogg', 50, 1, -1)
					for (var/mob/M in src)
						M.changeStatus("knockdown",1 SECONDS)
						M.show_text("The physical shock of the blow knocks you around!", "red")

		checkhealth()

	updateDialog()
		. = ..()
		// for(var/client/C)
		// 	if (C.mob && C.mob.using_dialog_of(src) && BOUNDS_DIST(C.mob, src) == 0)
		// 		src.open_parts_panel(C.mob)

	///////////////////////////////////////////////////////////////////////////
	////////Install/Eject Ship Part////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////

	/// Remove the part from the ship and drop it. Returns the part.
	proc/eject_part(var/mob/user, var/slot, var/give_message = TRUE)
		RETURN_TYPE(/obj/item/shipcomponent)
		var/obj/item/shipcomponent/part = src.get_part(slot)
		if(!part)
			return null
		part.deactivate(give_message)
		part.ship_uninstall()
		part.ship = null
		src.installed_parts[slot] = null

		if (!QDELETED(part))
			part.set_loc(get_turf(src))
			if(user)
				user.put_in_hand_or_drop(part)
			return part

	/// Don't know which slot a part is in? Use this.
	proc/find_part_slot(var/obj/item/shipcomponent/part)
		for(var/part_slot in src.installed_parts)
			if(src.installed_parts[part_slot] == part)
				return part_slot
		return null

	/// Remove the part from the ship and delete it from existance. Returns TRUE if there was a part to delete.
	proc/delete_part(var/slot, var/give_message = TRUE)
		var/obj/item/shipcomponent/part = src.eject_part(null, slot, give_message)
		if(part)
			qdel(part)
			return TRUE
		return FALSE

	/// Use this proc to install a part onto the ship. Returns TRUE if successful.
	proc/install_part(var/mob/user, var/obj/item/shipcomponent/part, var/slot, var/activate = FALSE, var/eject = TRUE)
		if(!slot)
			boutput(usr, "Report dev error! Slot not found.")
			return FALSE
		if(src.get_part(slot))
			if(eject)
				src.eject_part(user, slot)
			else
				boutput(usr, "That system already has a part!")
				return FALSE
		if(user) //This mean it's going on during the game!
			user.drop_item(part)
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 0)
		part.set_loc(src)
		src.installed_parts[slot] = part
		part.ship = src
		part.ship_install()
		if(activate)
			part.activate()
		if(src.myhud)
			src.myhud.update_systems()
			src.myhud.update_states()
		return TRUE

	/// Returns the part currently installed in the specified slot, if any
	proc/get_part(var/slot)
		RETURN_TYPE(/obj/item/shipcomponent)
		return src.installed_parts[slot]

	/// Check if the part can be used before returning it
	proc/get_usable_part(var/mob/user, var/slot)
		RETURN_TYPE(/obj/item/shipcomponent)
		if(is_incapacitated(user))
			boutput(user, SPAN_ALERT("Not when you are incapacitated."))
			return null
		if(user.loc != src)
			boutput(user, SPAN_ALERT("Uh-oh... you aren't in the ship! Report this."))
			return null
		var/obj/item/shipcomponent/part = src.get_part(slot)
		if(!part)
			boutput(user, "[src.ship_message("System not installed in ship!")]")
			return null
		if(!part.active)
			boutput(user, "[src.ship_message("SYSTEM OFFLINE")]")
			return null
		return part

	Topic(href, href_list)
		if (is_incapacitated(usr) || usr.restrained())
			return
		///////////////////////////////////////
		//////Main Computer Code		//////
		//////////////////////////////////////
		if (usr.loc == src)
			src.add_dialog(usr)
			if(href_list["deactivate"])
				if(href_list["deactivate"] == POD_PART_ENGINE && usr != pilot)
					boutput(usr, "[ship_message("Only the pilot may do this!")]")
					return
				src.get_part(href_list["deactivate"])?.deactivate()
			else if(href_list["activate"])
				src.get_part(href_list["activate"])?.activate()
			else if (href_list["opencomp"])
				src.get_part(href_list["opencomp"])?.opencomputer(usr)

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
				boutput(usr, SPAN_ALERT("You can't modify parts with somebody inside."))
				return

			var/obj/item/shipcomponent/secondary_system/lock/lock_part = src.get_part(POD_PART_LOCK)
			if (lock_part && src.locked)
				boutput(usr, SPAN_ALERT("You can't modify parts while [src] is locked."))
				lock_part.show_lock_panel(usr, 0)
				return

			src.add_dialog(usr)
			if (href_list["unengine"])
				var/obj/item/ejected_part = src.eject_part(usr, POD_PART_ENGINE)
				if(ejected_part)
					logTheThing(LOG_STATION, usr, "ejects the engine system ([ejected_part]) from [src] at [log_loc(src)]")
			else if (href_list["un_lock"])
				if (lock_part)
					if (src.locked)
						lock_part.show_lock_panel(usr, 0)
					else
						src.eject_part(usr, POD_PART_LOCK)
			else if (href_list["unlife"])
				var/obj/item/ejected_part = src.eject_part(usr, POD_PART_LIFE_SUPPORT)
				if(ejected_part)
					logTheThing(LOG_VEHICLE, usr, "ejects the life support system ([ejected_part]) from [src] at [log_loc(src)]")
			else if (href_list["uncom"])
				var/obj/item/ejected_part = src.eject_part(usr, POD_PART_COMMS)
				if (ejected_part)
					logTheThing(LOG_VEHICLE, usr, "ejects the comms system ([ejected_part]) from [src] at [log_loc(src)]")
			else if (href_list["unm_w"])
				var/obj/item/shipcomponent/mainweapon/main_weapon = src.get_part(POD_PART_MAIN_WEAPON)
				if(!main_weapon)
					return
				if(!main_weapon.removable)
					boutput(usr, SPAN_ALERT("[main_weapon] is fused to the hull and cannot be removed."))
					return
				if(src.eject_part(usr, POD_PART_MAIN_WEAPON))
					logTheThing(LOG_VEHICLE, usr, "ejects the main weapon system ([main_weapon]) from [src] at [log_loc(src)]")
			else if (href_list["unloco"])
				var/obj/item/ejected_part = src.eject_part(usr, POD_PART_LOCOMOTION)
				if(ejected_part)
					logTheThing(LOG_VEHICLE, usr, "ejects the locomotion system from [src] at [log_loc(src)]")
			else if (href_list["unsec_system"])
				var/obj/item/ejected_part = src.eject_part(usr, POD_PART_SECONDARY)
				if (ejected_part)
					logTheThing(LOG_VEHICLE, usr, "ejects the secondary system ([ejected_part]) from [src] at [log_loc(src)]")
			else if (href_list["unsensors"])
				var/obj/item/ejected_part = src.eject_part(usr, POD_PART_SENSORS)
				if (ejected_part)
					logTheThing(LOG_VEHICLE, usr, "ejects the sensors system ([ejected_part]) from [src] at [log_loc(src)]")
			else if (href_list["unlights"])
				var/obj/item/ejected_part = src.eject_part(usr, POD_PART_LIGHTS)
				if (ejected_part)
					logTheThing(LOG_VEHICLE, usr, "ejects the lighting system ([ejected_part]) from [src] at [log_loc(src)]")
			// Added logs for atmos tanks and such here, because booby-trapping pods is becoming a trend (Convair880).
			else if (href_list["atmostank"])
				if (src.atmostank)
					boutput(usr, SPAN_ALERT("There's already a tank in that slot."))
					return
				var/obj/item/tank/W = usr.equipped()
				if (W && istype(W, /obj/item/tank))
					logTheThing(LOG_VEHICLE, usr, "replaces [src.name]'s air supply with [W] [log_atmos(W)] at [log_loc(src)].")
					boutput(usr, SPAN_NOTICE("You attach the [W.name] to [src.name]'s air supply valve."))
					usr.drop_item()
					W.set_loc(src)
					src.atmostank = W
				else
					boutput(usr, SPAN_ALERT("That doesn't fit there."))
			else if (href_list["takeatmostank"])
				if (src.atmostank)
					logTheThing(LOG_VEHICLE, usr, "removes [src.name]'s air supply [log_atmos(atmostank)] at [log_loc(src)].")
					usr.put_in_hand_or_drop(src.atmostank)
					atmostank = null
				else
					boutput(usr, SPAN_ALERT("There's no tank in the slot."))
					return
			else if (href_list["fueltank"])
				if (src.fueltank)
					boutput(usr, SPAN_ALERT("There's already a tank in that slot."))
					return
				var/obj/item/tank/W = usr.equipped()
				if (W && istype(W, /obj/item/tank))
					logTheThing(LOG_VEHICLE, usr, "replaces [src.name]'s engine fuel supply with [W] [log_atmos(W)] at [log_loc(src)].")
					boutput(usr, SPAN_NOTICE("You attach the [W.name] to [src.name]'s fuel supply valve."))
					usr.drop_item()
					W.set_loc(src)
					src.fueltank = W
					src.myhud?.update_fuel()
				else
					boutput(usr, SPAN_ALERT("That doesn't fit there."))
					return
			else if (href_list["takefueltank"])
				if (src.fueltank)
					logTheThing(LOG_VEHICLE, usr, "removes [src.name]'s engine fuel supply [log_atmos(fueltank)] at [log_loc(src)].")
					usr.put_in_hand_or_drop(src.fueltank)
					fueltank = null
					src.updateDialog()
					src.myhud?.update_fuel()
					src.get_part(POD_PART_ENGINE)?.deactivate()
				else
					boutput(usr, SPAN_ALERT("There's no tank in the slot."))
					return

			src.updateDialog()
			myhud.update_systems()
		else
			usr.Browse(null, "window=ship_main")
			return

	proc/AmmoPerShot()
		return 1

	proc/ShootProjectiles(mob/user, datum/projectile/PROJ, shoot_dir, spread = -1, num_shots = 1)
		var/obj/item/shipcomponent/mainweapon/main_weapon = src.get_part(POD_PART_MAIN_WEAPON)
		if (main_weapon?.muzzle_flash && src.allow_muzzle_flash)
			muzzle_flash_any(src, dir_to_angle(shoot_dir), main_weapon.muzzle_flash)

		src.create_projectile(src, user, PROJ, shoot_dir, spread)

		for (var/i in 1 to (num_shots - 1))
			sleep(PROJ.shot_delay)
			src.create_projectile(src, user, PROJ, shoot_dir, spread)

	proc/create_projectile(atom/proj_start, mob/user, datum/projectile/PROJ, shoot_dir, spread = -1)
		var/obj/projectile/P
		if (spread == -1)
			P = shoot_projectile_DIR(proj_start, PROJ, shoot_dir)
		else
			P = shoot_projectile_relay_pixel_spread(proj_start, PROJ, get_step(src, shoot_dir), spread_angle = spread)
		P.mob_shooter = user

	hitby(atom/movable/AM, datum/thrown_thing/thr)
		. = 'sound/impact_sounds/Metal_Clang_3.ogg'
		ON_COOLDOWN(src, "in_combat", 5 SECONDS)
		if (isitem(AM))
			var/obj/item/I = AM
			switch(I.hit_type)
				if (DAMAGE_BLUNT, DAMAGE_CRUSH)
					src.health -= AM.throwforce / 1.5
				if (DAMAGE_CUT, DAMAGE_STAB)
					src.health -= AM.throwforce / 2
				if (DAMAGE_BURN)
					src.health -= AM.throwforce / 3
		else
			src.health -= AM.throwforce / 1.5 // assuming most non-items aren't sharp
		src.visible_message(SPAN_ALERT("[src] has been hit by \the [AM]."))
		checkhealth()
		..()

	bullet_act(var/obj/projectile/P)
		if(P.shooter == src)
			return
		//Wire: fix for Cannot read null.ks_ratio below
		if (!P.proj_data)
			return

		ON_COOLDOWN(src, "in_combat", 5 SECONDS)

		log_shot(P, src)

		src.material_trigger_on_bullet(src, P)

		var/damage = src.calculate_shielded_dmg(round(P.power, 1.0))

		var/hitsound = null
		var/volume = 35

		if (istype(P.proj_data, /datum/projectile/bullet/foamdart)) // foam darts shouldn't hurt
			hitsound = 'sound/impact_sounds/Glass_Hit_1.ogg'
		else if (P.proj_data?.shot_sound)
			hitsound = P.proj_data.shot_sound
		else
			volume = 30
		switch(P.proj_data.damage_type)
			if(D_KINETIC)
				src.health -= damage/1.7
				hitsound ||= 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg'
			if(D_PIERCING)
				src.health -= damage/1
				hitsound ||= 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg'
			if(D_ENERGY)
				src.health -= damage/1.5
				hitsound ||= 'sound/impact_sounds/Energy_Hit_3.ogg'
			if(D_SLASHING)
				src.health -= damage/2
				hitsound ||= 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg'
			if(D_BURNING)
				src.material_trigger_on_temp(5000)
				src.health -= damage/3
				hitsound ||= 'sound/items/Welder.ogg'
			if(D_SPECIAL) //blob
				src.health -= damage
				hitsound ||= 'sound/impact_sounds/Slimy_Hit_2.ogg'
		checkhealth()
		if(P.proj_data && P.proj_data.disruption) //ZeWaka: Fix for null.disruption
			src.disrupt(P.proj_data.disruption, P)

		src.visible_message(SPAN_ALERT("<b>[P]<b> hits [src]!"))

		for(var/mob/M in src)
			M.playsound_local(src, hitsound, vol=volume)
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
		ON_COOLDOWN(src, "in_combat", 5 SECONDS)
		src.health -= power * 3
		checkhealth()

	get_desc(dist, mob/user)
		. = ..()
		var/list/visible_parts = list()
		var/obj/item/shipcomponent/engine/engine = src.get_part(POD_PART_ENGINE)
		if (istype(engine))
			visible_parts += "[engine.name]"
		var/obj/item/shipcomponent/mainweapon/main_weapon = src.get_part(POD_PART_MAIN_WEAPON)
		if (istype(main_weapon))
			visible_parts += "[main_weapon.name]"
		if (length(visible_parts))
			. += "It looks like it has [english_list(visible_parts)] installed."

		if (src.keyed > 0)
			var/t = strings("descriptors.txt", "keyed")
			var/t_ind = clamp(round(keyed/10), 0, 10)
			. += "It has been keyed [keyed] time[s_es(keyed)]! [t_ind ? t[t_ind] : null]"

	proc/calculate_shielded_dmg(dmg)
		var/obj/item/shipcomponent/secondary_system/sec_part = src.get_part(POD_PART_SECONDARY)
		if (!istype(sec_part, /obj/item/shipcomponent/secondary_system/shielding))
			return dmg
		var/obj/item/shipcomponent/secondary_system/shielding/shielding_comp = sec_part
		return shielding_comp.process_incoming_dmg(dmg)

	proc/paint_pod(var/obj/item/pod/paintjob/P as obj, var/mob/user as mob)
		if (!P || !istype(P))
			return
		if (user)
			user.show_text("You paint [src].", "blue")
			user.u_equip(P)
		src.UpdateOverlays(image(src.icon, P.pod_skin), "skin")
		qdel(P)
		return

	proc/get_random_part()
		var/list/actually_installed_parts = list()
		for (var/id in src.installed_parts)
			if (src.installed_parts[id])
				actually_installed_parts += src.installed_parts[id]
		if (!length(actually_installed_parts))
			return null
		return pick(actually_installed_parts)

	proc/disrupt(disruption, obj/projectile/P)
		if(disruption <= 0 || !length(src.installed_parts))
			return
		playsound(src.loc, pick('sound/machines/glitch1.ogg', 'sound/machines/glitch2.ogg', 'sound/machines/glitch3.ogg', 'sound/effects/electric_shock.ogg', 'sound/effects/elec_bzzz.ogg'), 50, 1)
		if(pilot)
			boutput(src.pilot, "[ship_message("WARNING! Electrical system disruption detected!")]")

		var/obj/item/shipcomponent/S = src.get_random_part()
		if (!S)
			return
		if (istype(S, /obj/item/shipcomponent/engine))
			disruption += 40

		if(prob(disruption))
			if (istype(S, /obj/item/shipcomponent/engine)) //dont turn off engine thats annoying. instead ddisable the wormhole func!!
				var/obj/item/shipcomponent/engine/E = S
				if (E.ready)
					E.ready = 0
					E.ready()
			else
				S.deactivate()
				S.disrupted = TRUE
				SPAWN(3 SECONDS)
					S.disrupted = FALSE

	overload_act()
		ON_COOLDOWN(src, "in_combat", 5 SECONDS)
		src.disrupt(100) //you managed to punch a pod, you get full disruption
		src.disrupt(100)
		return TRUE

	emp_act()
		ON_COOLDOWN(src, "in_combat", 5 SECONDS)
		src.disrupt(10)
		return

	ex_act(severity)
		ON_COOLDOWN(src, "in_combat", 5 SECONDS)
		var/obj/item/shipcomponent/secondary_system/sec_part = src.get_part(POD_PART_SECONDARY)
		if(sec_part?.type == /obj/item/shipcomponent/secondary_system/crash)
			if(sec_part:crashable)
				return
		var/sevmod = 0
		sevmod = round(src.explosion_protection / 5)

		severity += sevmod

		switch (severity)
			if (1)
				src.health -= src.calculate_shielded_dmg(round(src.maxhealth / 3) + 65)
				checkhealth()
			if(2)
				src.health -= src.calculate_shielded_dmg(round(src.maxhealth / 4) + 40)
				checkhealth()
			if(3)
				src.health -= src.calculate_shielded_dmg(round(src.maxhealth / 5) + 25)
				checkhealth()

	proc/get_move_velocity_magnitude()
		.= movement_controller:velocity_magnitude

	bump(var/atom/target)
		if (get_move_velocity_magnitude() > 5)
			ON_COOLDOWN(src, "in_combat", 5 SECONDS)

			var/power = get_move_velocity_magnitude()

			src.health -= min(power * ram_self_damage_multiplier,10)
			checkhealth()

			if (istype(target, /obj/machinery/vehicle/))
				var/obj/machinery/vehicle/V = target
				V.health -= min(power*1.5,30)
				V.checkhealth()

			for (var/mob/C in src)
				shake_camera(C, 6, 8)

			if (ismob(target) && target != hitmob)
				hitmob = target
				SPAWN(0.5 SECONDS)
					hitmob = 0
				var/mob/M = target
				var/vehicular_manslaughter
				if(M.health > 0)
					vehicular_manslaughter = 1 //we first check if the person is not in crit before hit, if yes we qualify for vehicular manslaughter achievement
				//M.changeStatus("stunned", 1 SECOND)
				//M.changeStatus("knockdown", 1 SECOND)
				M.TakeDamageAccountArmor("chest", power * 1.3, 0, 0, DAMAGE_BLUNT)
				M.remove_stamina(power)
				var/turf/throw_at = get_edge_target_turf(src, src.dir)
				M.throw_at(throw_at, movement_controller:velocity_magnitude, 2)
				logTheThing(LOG_COMBAT, src, "(piloted by [constructTarget(src.pilot,"combat")]) crashes into [constructTarget(target,"combat")] at [log_loc(target)].")
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

				logTheThing(LOG_COMBAT, src, "(piloted by [constructTarget(src.pilot,"combat")]) crashes into [constructTarget(target,"combat")] at [log_loc(target)].")
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
				logTheThing(LOG_COMBAT, src, "(piloted by [constructTarget(src.pilot,"combat")]) crashes into [constructTarget(target,"combat")] at [log_loc(target)].")

			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)

		var/obj/item/shipcomponent/secondary_system/sec_part = src.get_part(POD_PART_SECONDARY)
		if (sec_part?.type == /obj/item/shipcomponent/secondary_system/crash)
			if (sec_part:crashable)
				sec_part:crashtime2(target)
		SPAWN(0)
			..()
			return
		return

	meteorhit(var/obj/O as obj)
		ON_COOLDOWN(src, "in_combat", 5 SECONDS)
		src.health -= src.calculate_shielded_dmg(50)
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

		QDEL_NULL(src.myhud)

		if (pilot)
			pilot = null

		if(src.installed_parts)
			for(var/slot_type in src.installed_parts)
				var/obj/part = src.installed_parts[slot_type]
				part?.dispose()
		src.installed_parts.len = 0
		src.installed_parts = null
		src.atmostank = null
		src.fueltank = null
		src.intercom = null

		fire_overlay = null
		damage_overlay = null
		ion_trail = null
		STOP_TRACKING_CAT(TR_CAT_PODS_AND_CRUISERS)
		STOP_TRACKING

		..()

	process(mult)
		var/obj/item/shipcomponent/sec_part = src.get_part(POD_PART_SECONDARY)
		if(sec_part?.active)
			sec_part.run_component(mult)
		var/obj/item/shipcomponent/engine_part = src.get_part(POD_PART_ENGINE)
		if(engine_part?.active)
			var/usage = src.powercurrent/3000*mult // 0.0333 moles consumed per 100W per tick
			var/datum/gas_mixture/consumed = src.fueltank?.remove_air(usage)
			var/toxins = consumed?.toxins
			if(isnull(toxins))
				toxins = 0
			if(usage)
				src.myhud?.update_fuel()
				if(abs(usage - toxins)/usage > 0.10) // 5% difference from expectation
					engine_part.deactivate()
			consumed?.dispose()

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
						src.UpdateOverlays(fire_overlay, "fire")
						for(var/mob/living/carbon/human/M in src)
							M.update_burning(35)
							boutput(M, SPAN_ALERT("<b>The cabin bursts into flames!</b>"))
							playsound(M.loc, 'sound/machines/engine_alert1.ogg', 35, 0)
				if(25 to 50)
					if(damage_overlays < 1)
						damage_overlays = 1
						damage_overlay = image('icons/effects/64x64.dmi', "pod_damage")
						src.UpdateOverlays(damage_overlay, "damage")
				if(50 to INFINITY)
					if (damage_overlays)
						if(damage_overlays == 2)
							src.UpdateOverlays(null, "fire")
							src.UpdateOverlays(null, "damage")
							fire_overlay = null
						else if(damage_overlays == 1)
							src.UpdateOverlays(null, "damage")
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

/// Callback for welding repair actionbar
/obj/machinery/vehicle/proc/weld_action(mob/user)
	src.health += 30
	src.delStatus("pod_corrosion")
	src.checkhealth()
	src.add_fingerprint(user)
	src.visible_message(SPAN_ALERT("[user] has fixed some of the dents on [src]!"))
	if(health >= maxhealth)
		src.visible_message(SPAN_ALERT("[src] is fully repaired!"))

/// Produces a random small welding line across the vehicle
/obj/machinery/vehicle/proc/get_welding_positions()
	var/start
	var/stop
	// 0,0 coords correspond to 16,16 on sprite of any size
	// so we need to shift the range by -16
	var/startX = rand(-8, (src.bound_width-24))
	var/startY = rand(-8, (src.bound_height-24))
	var/difference = rand(3, 6) // small x means bigger y, vice versa
	var/endX = startX + (difference * (prob(50) ? 1 : -1))
	var/endY = startY + ((8 - difference) * (prob(50) ? 1 : -1))

	start = list(startX, startY)
	stop = list(endX, endY)
	. = list(start, stop)

/obj/machinery/vehicle/proc/shipcrit()
	if(src.delete_part(POD_PART_ENGINE))
		playsound(src.loc, 'sound/machines/pod_alarm.ogg', 40, 1)
		visible_message(SPAN_ALERT("[src]'s engine bursts into flame!"))
		for(var/mob/living/carbon/human/M in src)
			M.update_burning(35)

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
			boutput(M, SPAN_ALERT("<b>Everything is on fire!</b>"))
			M.playsound_local_not_inworld('sound/machines/engine_alert1.ogg', vol=50)
		sleep(2.5 SECONDS)
		playsound(src.loc, 'sound/machines/pod_alarm.ogg', 40, 1)
		for(var/mob/living/carbon/human/M in src)
			M.playsound_local_not_inworld('sound/machines/pod_alarm.ogg', vol=50)
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

	ejectee.override_movement_controller = null

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

	logTheThing(LOG_VEHICLE, ejectee, "exits pod: <b>[constructTarget(src.name,"vehicle")]</b> at [log_loc(src)]")

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

	// Items can fall off the player while they are in the pod. Eject anything not considered to be installed.
	for (var/obj/item/I in src)
		var/is_installed = (I == src.atmostank || I == src.fueltank || I == src.intercom)
		if(!is_installed)
			for(var/part_slot in src.installed_parts)
				if(src.installed_parts[part_slot] == I)
					is_installed = TRUE
					break
		if (is_installed)
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
		boutput(boarder, SPAN_ALERT("Pods are only for the living, so quit being a smartass!"))
		return

	if(iscube(boarder))
		boutput(boarder, SPAN_ALERT("You can't squeeze your wide cube body through the access door!"))
		return

	if(isflockmob(boarder) || istype(boarder, /mob/living/critter/space_phoenix))
		boutput(boarder, SPAN_ALERT("You're unable to use this vehicle!"))
		return

	if(locked)
		boutput(boarder, SPAN_ALERT("[src] is locked!"))
		return

	if (boarder.getStatusDuration("stunned") > 0 || boarder.getStatusDuration("knockdown") || boarder.getStatusDuration("unconscious") || !isalive(boarder) || boarder.restrained())
		boutput(boarder, SPAN_ALERT("You can't enter a pod while incapacitated or restrained."))
		return

	if (boarder in src) // fuck's sake
		boutput(boarder, SPAN_ALERT("You're already inside [src]!"))
		return

	if (!src.allowed(boarder))
		boutput(boarder, SPAN_ALERT("Access denied."))
		return

	passengers = 0 // reset this shit

	for(var/mob/M in src) // nobody likes losing a pod to a dead pilot
		passengers++

	eject_pod(boarder, dead_only = 1)

	if (src.capacity <= src.passengers)
		boutput(boarder, "There is no more room!")
		return

	if(!src.pilot && (ismobcritter(boarder) && (!isadmin(boarder) || boarder.client.player_mode)))
		boutput(boarder, SPAN_ALERT("You don't know how to pilot a pod, you can only enter as a passenger!"))
		return

	actions.start(new/datum/action/bar/board_pod(src,boarder), boarder)

/obj/machinery/vehicle/proc/finish_board_pod(var/mob/boarder)
	for(var/part_slot in src.installed_parts)
		var/obj/item/shipcomponent/S = get_part(part_slot)
		S?.mob_activate(boarder)

	src.passengers++
	var/mob/M = boarder

	M.set_loc(src, src.view_offset_x, src.view_offset_y)
	M.override_movement_controller = src.movement_controller
	M.reset_keymap()
	M.recheck_keys()
	if(!src.pilot && (!ismobcritter(boarder) || (isadmin(boarder) && !M.client.player_mode)))
		src.ion_trail.start()
	src.find_pilot()
	if (M.client)
		M.attach_hud(myhud)
		if(ishuman(M))
			myhud.check_hud_layout(M)

	src.add_fingerprint(M)

	//boarder.make_shipcrewmember(src.weapon_class)

	boutput(M, SPAN_HINT("You can also use the Space Bar to fire!"))

	logTheThing(LOG_VEHICLE, M, "enters vehicle: <b>[constructTarget(src.name,"vehicle")]</b> at [log_loc(src)]")

/obj/machinery/vehicle/proc/eject_occupants()
	if(isghostdrone(usr))
		boutput(usr, SPAN_ALERT("Your laws don't permit you to do that!"))
		return

	if(locked)
		boutput(usr, SPAN_ALERT("[src] is locked!"))
		return

	if(locate(/mob) in src.contents)
		actions.start(new/datum/action/bar/icon/eject_pod(src,usr), usr)
		return

	boutput(usr, SPAN_ALERT("No one is in [src]."))

/obj/machinery/vehicle/proc/eject_pod(var/mob/user, var/dead_only = 0)
	for(var/mob/M in src) // nobody likes losing a pod to a dead pilot
		if (!dead_only)
			leave_pod(M)
			boutput(user, SPAN_ALERT("You yank [M] out of [src]."))
		else
			if(M.stat || !M.client)
				leave_pod(M)
				boutput(user, SPAN_ALERT("You pull [M] out of [src]."))
			else if(!isliving(M))
				leave_pod(M)
				boutput(user, SPAN_ALERT("You scrape [M] out of [src]."))

	for(var/obj/decal/cleanable/O in src)
		boutput(user, SPAN_ALERT("You [pick("scrape","scrub","clean")] [O] out of [src]."))
		var/floor = get_turf(src)
		O.set_loc(floor)


/datum/action/bar/board_pod
	duration = 20
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_MOVE
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

		var/was_seen_boarding = FALSE
		if (istype(V, /obj/machinery/vehicle/tank/car)) // you can drive pods drunk, but not cars. space law.
			was_seen_boarding = seen_by_camera(owner)

		V.finish_board_pod(owner)

		if (was_seen_boarding && V.pilot == owner && ishuman(owner) && owner.hasStatus("drunk"))
			var/mob/living/carbon/human/H = owner
			H.apply_automated_arrest("DUI.", "Drove while inebriated.", requires_camera_seen = FALSE)

/datum/action/bar/icon/eject_pod
	duration = 50
	interrupt_flags = INTERRUPT_STUNNED
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
		if (isdead(M) || M.restrained() || owner.getStatusDuration("knockdown") || owner.getStatusDuration("unconscious") || owner.getStatusDuration("stunned"))
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

		if (isdead(M) || M.restrained() || owner.getStatusDuration("knockdown") || owner.getStatusDuration("unconscious") || owner.getStatusDuration("stunned"))
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
		if(!src.pilot && !M.stat && M.client && (!ismobcritter(M) || isadmin(M) && !M.client.player_mode))
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
		M.playsound_local_not_inworld(bad_drone.alertsound1, vol=25)
		boutput(M, src.ship_message(message))

	return




/////////////////////////////////////////////////////////////////////////
////////What happens to occupants when ship is destroyed ////////////////
////////////////////////////////////////////////////////////////////////
/obj/machinery/vehicle/proc/handle_occupants_shipdeath()
	for(var/mob/M in src)
		boutput(M, SPAN_ALERT("<b>You are ejected from [src]!</b>"))
		logTheThing(LOG_VEHICLE, M, "is ejected from pod: <b>[constructTarget(src.name,"vehicle")]</b> when it blew up!")

		M.set_loc(get_turf(src))
		var/atom/target = get_edge_cheap(M, src.dir)
		M.throw_at(target, 10, 2)


/////////////////////////////////////////////////////////////////////
////////Open Part Panel									////////////
////////////////////////////////////////////////////////////////////
/obj/machinery/vehicle/proc/open_parts_panel(mob/user as mob)
	if(isghostdrone(user))
		boutput(user, SPAN_ALERT("Pods are only for the living, so quit trying to mess with them!"))
		return

	if (passengers)
		boutput(user, SPAN_ALERT("You can't modify parts with somebody inside."))
		return

	var/obj/item/shipcomponent/secondary_system/lock/lock_part = src.get_part(POD_PART_LOCK)
	if (lock_part && src.locked)
		boutput(user, SPAN_ALERT("You can't modify parts while [src] is locked."))
		lock_part.show_lock_panel(user, 0)
		return

	src.add_dialog(user)

	var/dat = "<TT><B>[src] Maintenance Panel</B><BR>"
	//Air and Fuel tanks
	dat += "<HR><B>Atmos Tank</B>: "
	if(!isnull(src.atmostank))
		dat += "<A href='byond://?src=\ref[src];takeatmostank=1'>[src.atmostank]</A>"
	else
		dat += "<A href='byond://?src=\ref[src];atmostank=1'>--------</A>"
	dat += "<HR><B>Fuel Tank</B>: "
	if(src.fueltank)
		dat += "<A href='byond://?src=\ref[src];takefueltank=1'>[src.fueltank]</A>"
	else
		dat += "<A href='byond://?src=\ref[src];fueltank=1'>--------</A>"
	dat += "<HR><B>Engine</B>: "
	//Engine
	if(src.get_part(POD_PART_ENGINE))
		dat += "<A href='byond://?src=\ref[src];unengine=1'>[src.get_part(POD_PART_ENGINE)]</A>"
	else
		dat += "None Installed"
	///Life Support
	dat += "<HR><B>Life Support</B>: "
	if(src.get_part(POD_PART_LIFE_SUPPORT))
		dat += "<A href='byond://?src=\ref[src];unlife=1'>[src.get_part(POD_PART_LIFE_SUPPORT)]</A>"
	else
		dat += "None Installed"
	//// Com System
	dat += "<HR><B>Com System</B>: "
	if(src.get_part(POD_PART_COMMS))
		dat += "<A href='byond://?src=\ref[src];uncom=1'>[src.get_part(POD_PART_COMMS)]</A>"
	else
		dat += "None Installed"
	///Main Weapon
	if(weapon_class != 0)
		dat += "<HR><B>Main Weapon</B>: "
		var/obj/item/shipcomponent/mainweapon/main_weapon = src.get_part(POD_PART_MAIN_WEAPON)
		if(main_weapon)
			dat += "<A href='byond://?src=\ref[src];unm_w=1'>[main_weapon]</A>"
			if (main_weapon.uses_ammunition)
				dat += "<br><b>Remaining ammo:</b> [main_weapon.remaining_ammunition]"
		else
			dat += "None Installed"
	if(istype(src,/obj/machinery/vehicle/tank))
		dat += "<HR><B>Locomotion</B>: "
		if(src.get_part(POD_PART_LOCOMOTION))
			dat += "<A href='byond://?src=\ref[src];unloco=1'>[src.get_part(POD_PART_LOCOMOTION)]</A>"
		else
			dat += "None Installed"
	////Sensors
	dat += "<HR><B>Sensors</B>: "
	if(src.get_part(POD_PART_SENSORS))
		dat += "<A href='byond://?src=\ref[src];unsensors=1'>[src.get_part(POD_PART_SENSORS)]</A>"
	else
		dat += "None Installed"
	////Secondary System
	dat += "<HR><B>Secondary System</B>: "
	if(src.get_part(POD_PART_SECONDARY))
		dat += "<A href='byond://?src=\ref[src];unsec_system=1'>[src.get_part(POD_PART_SECONDARY)]</A>"
	else
		dat += "None Installed"
	////Lights System
	dat += "<HR><B>Lights System</B>: "
	if(src.get_part(POD_PART_LIGHTS))
		dat += "<A href='byond://?src=\ref[src];unlights=1'>[src.get_part(POD_PART_LIGHTS)]</A>"
	else
		dat += "None Installed"
	////Locking System
	dat += "<HR><B>Locking System</B>: "
	if(src.get_part(POD_PART_LOCK))
		dat += "<A href='byond://?src=\ref[src];un_lock=1'>[src.get_part(POD_PART_LOCK)]</A>"
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

	var/list/slots_list = list(POD_PART_ENGINE, POD_PART_LIFE_SUPPORT, POD_PART_COMMS, \
		POD_PART_MAIN_WEAPON, POD_PART_SENSORS, POD_PART_SECONDARY, POD_PART_LIGHTS)
	for(var/slot in slots_list)
		var/obj/item/shipcomponent/part = src.get_part(slot)
		if(!part)
			continue
		if(part.active)
			dat += {"<HR><B>[part.system]</B>: <I><A href='byond://?src=\ref[src];opencomp=[slot]'>[part]</A></I>"}
			dat += {"<BR><A href='byond://?src=\ref[src];deactivate=[slot]'>(Deactivate)</A>"}
		else
			dat += {"<HR><B>[part.system]</B>: <I>[part]</I>"}
			dat += {"<BR><A href='byond://?src=\ref[src];activate=[slot]'>(Activate)</A>"}
		if(slot != POD_PART_ENGINE) // Engine power used should be zero, but just in case
			dat+={"([part.power_used])<BR>"}

	var/obj/item/shipcomponent/secondary_system/lock/lock_part = src.get_part(POD_PART_LOCK)
	if(lock_part)
		dat += "<HR><B>Lock</B>:<br>"
		if(src.locked)
			dat += "<a href='byond://?src=\ref[lock_part];unlock=1'>(Unlock)</a>"
		else
			if (lock_part.is_set())
				dat += "<a href='byond://?src=\ref[lock_part];lock=1'>(Lock)</a>"
			// if the lock is not set OR it is set and can be reset, show the set code button
			if (!lock_part.is_set() || (lock_part.is_set() && lock_part.can_reset))
				dat += " <a href='byond://?src=\ref[lock_part];setcode=1;'>(Set Code)</a>"
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
	if(src.name == initial(src.name) && numbers_in_name)
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
	src.fueltank = new /obj/item/tank/plasma(src)
	src.install_part(null, new /obj/item/shipcomponent/engine(src), POD_PART_ENGINE, FALSE)
	/////Life Support Setup
	src.atmostank = new /obj/item/tank/air(src)
	src.install_part(null, new /obj/item/shipcomponent/life_support(src), POD_PART_LIFE_SUPPORT, FALSE)
	/////Com-System Setup
	src.intercom = new /obj/item/device/radio/intercom/ship(src)
	//src.intercom.icon_state = src.icon_state
	src.install_part(null, new src.init_comms_type(src), POD_PART_COMMS, FALSE)
	///// Sensor System Setup
	src.install_part(null, new /obj/item/shipcomponent/sensor(src), POD_PART_SENSORS, FALSE)
	///// Lights Subsystem
	src.install_part(null, new /obj/item/shipcomponent/pod_lights/pod_1x1(src), POD_PART_LIGHTS, FALSE)
	// src.get_part(POD_PART_ENGINE).deactivate() // gotta not use up all that fuel!
	myhud.update_systems()
	myhud.update_states()
	myhud.update_health()
	myhud.update_fuel()

	START_TRACKING_CAT(TR_CAT_PODS_AND_CRUISERS)

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////					MouseDrop Crate Loading						////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

/obj/machinery/vehicle/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (!user.client || !isliving(user) || isintangible(user))
		return
	if (!can_reach(user, src))
		return
	if (is_incapacitated(user))
		user.show_text("Not when you're incapacitated.", "red")
		return

	if(locked)
		boutput(user, SPAN_ALERT("[src] is locked!"))
		return

	if(isliving(O))
		var/mob/living/M = O
		if (M == user)
			src.board_pod(M)
			return

	var/obj/item/shipcomponent/secondary_system/SS = src.get_part(POD_PART_SECONDARY)
	if (!SS)
		return
	SS.Clickdrag_ObjectToPod(user,O)

/obj/machinery/vehicle/mouse_drop(over_object, src_location, over_location)
	if (!usr.client || !isliving(usr) || isintangible(usr))
		return
	if (!can_reach(usr, src))
		return
	if (is_incapacitated(usr))
		usr.show_text("Not when you're incapacitated.", "red")
		return

	if(locked)
		boutput(usr, SPAN_ALERT("[src] is locked!"))
		return

	var/obj/item/shipcomponent/secondary_system/SS = src.get_part(POD_PART_SECONDARY)
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
		boutput(usr, SPAN_ALERT("Not when you are incapacitated."))
		return
	if(istype(usr.loc, /obj/machinery/vehicle/))
		var/obj/machinery/vehicle/ship = usr.loc
		ship.access_computer(usr)
	else
		boutput(usr, SPAN_ALERT("Uh-oh you aren't in a ship! Report this."))

/obj/machinery/vehicle/proc/fire_main_weapon(mob/user)
	if(src.stall)
		return
	var/obj/item/shipcomponent/mainweapon/main_weapon = src.get_usable_part(user, POD_PART_MAIN_WEAPON)
	if(!main_weapon)
		return
	if(!main_weapon.r_gunner)
		main_weapon.Fire(user, src.facing)
		return
	if(user != main_weapon.gunner)
		boutput(user, "[src.ship_message("You must be in the gunner seat!")]")
		return
	src.stall += 1
	main_weapon.Fire(user, src.facing)

/obj/machinery/vehicle/proc/use_external_speaker()
	var/obj/item/shipcomponent/communications/comms = src.get_usable_part(usr, POD_PART_COMMS)
	if(comms)
		comms.External()

/obj/machinery/vehicle/proc/create_wormhole()
	var/obj/item/shipcomponent/engine/engine_part = src.get_usable_part(usr, POD_PART_ENGINE)
	if(!engine_part)
		return
	if(!engine_part.ready)
		boutput(usr, "[src.ship_message("Engine recharging wormhole capabilities!")]")
		return
	var/turf/T = src.loc
	if(!istype(T) || !T.allows_vehicles)
		boutput(usr, "[src.ship_message("Cannot create wormhole on this flooring!")]")
		return
	engine_part.Wormhole()

/obj/machinery/vehicle/proc/access_sensors()
	var/obj/item/shipcomponent/sensor/sensors_part = src.get_usable_part(usr, POD_PART_SENSORS)
	if(sensors_part)
		sensors_part.opencomputer(usr)

/obj/machinery/vehicle/proc/use_secondary_system()
	if(is_incapacitated(usr))
		boutput(usr, SPAN_ALERT("Not when you are incapacitated."))
		return
	if(usr.loc != src)
		boutput(usr, SPAN_ALERT("Uh-oh... you aren't in the ship! Report this."))
		return
	var/obj/item/shipcomponent/secondary_system/sec_part = src.get_part(POD_PART_SECONDARY) // Cannot use get_usable_part() here due to f_active
	if(!sec_part)
		boutput(usr, "[src.ship_message("System not installed in ship!")]")
		return
	if(!sec_part.active && !sec_part.f_active)
		boutput(usr, "[src.ship_message("SYSTEM OFFLINE")]")
		return
	if(!sec_part.ready)
		boutput(usr, "[src.ship_message("Secondary System isn't ready for use yet!")]")
		return
	sec_part.Use(usr)

/obj/machinery/vehicle/proc/toggle_hangar_door(var/pass)
	var/obj/item/shipcomponent/communications/comms = src.get_usable_part(usr, POD_PART_COMMS)
	if(!comms)
		return
	comms.rc_ship.toggle_hangar_door(usr, pass)


/obj/machinery/vehicle/proc/return_to_station()
	var/obj/item/shipcomponent/communications/comms = src.get_usable_part(usr, POD_PART_COMMS)
	if(!comms)
		return
	if(comms.go_home())
		return
	src.going_home = 1
	boutput(usr, "[src.ship_message("Course set for station level. Traveling off the edge of the current level will take you to the station level.")]")

/obj/machinery/vehicle/proc/go_home()
	var/obj/item/shipcomponent/communications/comms_part = src.get_part(POD_PART_COMMS)
	. = comms_part?.get_home_turf()

//TODO

// make ships less destructive (maybe depends on Mass and Speed?)

ABSTRACT_TYPE(/obj/machinery/vehicle/tank)
/obj/machinery/vehicle/tank
	name = "tank"
	icon = 'icons/obj/machines/8dirvehicles.dmi'
	icon_state = "minisub_body"
	numbers_in_name = FALSE
	var/body_type = "minisub"
	uses_weapon_overlays = 0
	health = 100
	maxhealth = 100
	speedmod = 0 // speed literally does nothing? what??
	stall = 0 // slow the ship down when firing
	weapon_class = 1

	var/prev_velocity = 0
	ram_self_damage_multiplier = 0.14
	//var/datum/movement_controller/pod/movement_controller

	Move(NewLoc,Dir=0,step_x=0,step_y=0)
		.=..(NewLoc,Dir,step_x,step_y)

		if (movement_controller && istype(movement_controller,/datum/movement_controller/tank))
			var/datum/movement_controller/tank/M = movement_controller
			if (M.squeal_sfx)
				M.squeal_sfx = 0
				playsound(src, 'sound/machines/car_screech.ogg', 40, TRUE)
			if (M.accel_sfx)
				M.accel_sfx = 0
				playsound(src, 'sound/machines/rev_engine.ogg', 40, TRUE)

	get_move_velocity_magnitude()
		.= movement_controller:velocity_magnitude

/obj/machinery/vehicle/tank/minisub
	name = "minisub"
	body_type = "minisub"
	event_handler_flags = USE_FLUID_ENTER | IMMUNE_OCEAN_PUSH
	acid_damage_multiplier = 0.5

	New()
		..()
		src.install_part(null, new /obj/item/shipcomponent/locomotion/treads(src), POD_PART_LOCOMOTION, FALSE)

/obj/machinery/vehicle/tank/minisub/pilot
	body_type = "minisub"
	health = 150
	maxhealth = 150


	New()
		..()
		src.delete_part(POD_PART_ENGINE, FALSE)
		src.delete_part(POD_PART_COMMS, FALSE)
		src.install_part(null, new /obj/item/shipcomponent/engine/zero(src), POD_PART_ENGINE, FALSE)
		src.install_part(null, new /obj/item/shipcomponent/mainweapon/bad_mining(src), POD_PART_MAIN_WEAPON, FALSE)
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
		src.install_part(null, new /obj/item/shipcomponent/mainweapon/taser(src), POD_PART_MAIN_WEAPON, FALSE)
		src.install_part(null, new /obj/item/shipcomponent/secondary_system/lock(src), POD_PART_LOCK, FALSE)
		myhud.update_systems()
		myhud.update_states()


/obj/machinery/vehicle/tank/minisub/syndisub
	body_type = "minisub"
	icon_state = "syndisub_body"
	health = 150
	maxhealth = 150
	acid_damage_multiplier = 0
	faction = list(FACTION_SYNDICATE)
	init_comms_type = /obj/item/shipcomponent/communications/syndicate

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()
		name = "syndicate minisub"
		src.install_part(null, new /obj/item/shipcomponent/secondary_system/lock(src), POD_PART_LOCK, FALSE)
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
		src.install_part(null, new /obj/item/shipcomponent/mainweapon/bad_mining(src), POD_PART_MAIN_WEAPON, FALSE)
		src.install_part(null, new /obj/item/shipcomponent/secondary_system/orescoop(src), POD_PART_SECONDARY, FALSE)

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
		src.install_part(null, new /obj/item/shipcomponent/mainweapon/foamer(src), POD_PART_MAIN_WEAPON, FALSE)
		src.install_part(null, new /obj/item/shipcomponent/secondary_system/cargo(src), POD_PART_SECONDARY, FALSE)


/obj/machinery/vehicle/tank/minisub/escape_sub
	name = "escape sub"
	body_type = "minisub"
	desc = "A small one-person sub that scans for the emergency shuttle's engine signature and warps to it mid-transit. These are notorious for lacking any safety checks. <br>It looks sort of rickety..."
	icon_state = "escapesub_body"
	capacity = 1
	health = 60
	maxhealth = 60
	weapon_class = 1
	speedmod = 0.2
	var/fail_type = 0
	var/launched = 0
	var/steps_moved = 0
	var/failing = 0
	var/succeeding = 0
	var/did_warp = 0

	New()
		. = ..()
		src.delete_part(POD_PART_ENGINE, FALSE)
		src.install_part(null, new /obj/item/shipcomponent/engine/escape(src), POD_PART_ENGINE, TRUE)

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
			P.set_target(T)
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
				pilot?.playsound_local_not_inworld('sound/machines/engine_alert1.ogg', vol=100)
				boutput(pilot, SPAN_ALERT("The fuel tank of your escape sub explodes!"))
				explosion(src, src.loc, 2, 3, 4, 6)
			if(3) //falls apart
				pilot?.playsound_local_not_inworld('sound/machines/engine_alert1.ogg', vol=100)
				boutput(pilot, SPAN_ALERT("Your escape sub is falling apart around you!"))
				while(src)
					step(src,src.dir)
					if(prob(50))
						make_cleanable(/obj/decal/cleanable/robot_debris/gib, src.loc)
					if(prob(20) && pilot)
						boutput(pilot, SPAN_ALERT("You fall out of the rapidly disintegrating escape sub!"))
						src.leave_pod(pilot)
					if(prob(10)) shipdeath()
					sleep(0.4 SECONDS)
			if(4) //flies off course
				pilot?.playsound_local_not_inworld('sound/machines/engine_alert1.ogg', vol=100)
				boutput(pilot, SPAN_ALERT("Your escape sub is veering out of control!"))
				while(src)
					if(prob(10)) src.dir = turn(dir,pick(90,-90))
					var/loc = src.loc
					step(src,src.dir)
					if(src.loc == loc) //we hit something
						explosion(src, src.loc, 1, 1, 2, 3)
						break
					sleep(0.4 SECONDS)
			if(5)
				boutput(pilot, SPAN_ALERT("Your escape sub sputters to a halt!"))
			if(6)
				boutput(pilot, SPAN_ALERT("Your escape sub explosively decompresses, hurling you into the ocean!"))
				pilot?.playsound_local_not_inworld('sound/effects/Explosion2.ogg', vol=100)
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
				boutput(pilot, SPAN_ALERT("Your escape sub begins to accelerate!"))
				var/speed = 5
				while(speed)
					var/loc = src.loc
					step(src,src.dir)
					if(src.loc == loc) //we hit something
						explosion(src, src.loc, 1, 1, 2, 3)
						break
					if(speed > 1 && prob(10)) speed--
					if(speed == 1 && prob(5))
						boutput(pilot, SPAN_ALERT("Your escape sub is moving so fast that it tears itself apart!"))
						shipdeath()
					else if(prob(10/speed))
						boutput(pilot, SPAN_ALERT("Your escape sub is [pick("vibrating","shuddering","shaking")] [pick("alarmingly","worryingly","violently","terribly","scarily","weirdly","distressingly")]!"))
					sleep(speed)
			if(8)
				boutput(pilot, SPAN_ALERT("Your escape sub starts to drive around in circles [pick("awkwardly","embarrassingly","sadly","pathetically","shamefully","ridiculously")]!"))
				pilot?.playsound_local_not_inworld('sound/machines/engine_alert1.ogg', vol=100)
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
		src.install_part(null, new /obj/item/shipcomponent/locomotion/wheels(src), POD_PART_LOCOMOTION, FALSE)

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
		src.install_part(null, new /obj/item/shipcomponent/locomotion/wheels(src), POD_PART_LOCOMOTION, FALSE)

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
			src.install_part(null, new /obj/item/shipcomponent/mainweapon/taser(src), POD_PART_MAIN_WEAPON, FALSE)
			src.install_part(null, new /obj/item/shipcomponent/pod_lights/police_siren(src), POD_PART_LIGHTS, FALSE)
			src.myhud?.update_states()
/*
	engineering
		body_type =
		icon_state =

		New()
			..()
			name = "engineering car
			desc = "A Toriyama-Okawara EV-94 personal mobility vehicle, painted in engineering colours."
*/
