/**
* Not related to the other shield generator at all.
*/
/obj/machinery/shieldgenerator
	name = "Shield generator parent"
	desc = "fix me please"
	density = 1
	opacity = 0
	anchored = 0
	layer = FLOOR_EQUIP_LAYER1
	deconstruct_flags = DECON_DESTRUCT
	var/obj/item/cell/PCEL = null
	var/starts_with_cell = TRUE
	var/coveropen = 0
	var/active = 0
	var/range = 2
	var/min_range = 1
	var/max_range = 6
	var/battery_level = 0
	var/power_level = 1	//unused in meteor, used in energy shield
	var/image/display_active = null
	var/image/display_battery = null
	var/image/display_panel = null
	var/sound/sound_on = 'sound/effects/shielddown.ogg'
	var/sound/sound_off = 'sound/effects/shielddown2.ogg'
	var/sound/sound_shieldhit = 'sound/impact_sounds/Energy_Hit_1.ogg'
	var/sound/sound_battwarning = 'sound/machines/pod_alarm.ogg'
	var/list/deployed_shields = list()
	var/direction = ""	//for building the icon, always north or directional
	var/connected = 0	//determine if gen is wrenched over a wire.
	var/obj/cable/connected_wire = null	//wire the gen is wrenched over. used to validate pnet connection
	var/backup = 0		//if equip power went out while connected to wire, this should be true. Used to automatically turn gen back on if power is restored
	var/first = 0		//tic when the power goes out.

	New()
		if(starts_with_cell)
			PCEL = new /obj/item/cell/supercell(src)
			PCEL.charge = PCEL.maxcharge

		src.display_active = image('icons/obj/meteor_shield.dmi', "on")
		src.display_battery = image('icons/obj/meteor_shield.dmi', "")
		src.display_panel = image('icons/obj/meteor_shield.dmi', "")
		..()

	disposing()
		shield_off(1)
		PCEL?.dispose()
		PCEL = null
		display_active = null
		display_battery = null
		display_panel = null
		sound_on = null
		sound_off = null
		sound_battwarning = null
		sound_shieldhit = null
		deployed_shields = list()
		..()

	process()
		if(src.active)
			if(PCEL && !connected)
				process_battery()
			else
				process_wired()

		if(backup)
			src.active = !src.active

	ex_act(severity)
		switch(severity)
			if(1)
				shield_off(1) //1 for failed
				qdel(src)
				return
			if(2)
				if(PCEL && !connected && active)
					src.PCEL.use(120 * src.range * (src.power_level * src.power_level))
				else if(connected && active)
					use_power(src.power_usage * 4)
				if(prob(50))
					shield_off(1)
				return
			if(3)
				if(PCEL && !connected && active)
					src.PCEL.use(60 * src.range * (src.power_level * src.power_level))
					return
				else if(connected && active)
					use_power(src.power_usage * 2)
				return

	blob_act(var/power)
		if(PCEL && !connected && active)
			src.PCEL.use(60 * src.range * (src.power_level * src.power_level))
		else if(connected && active)
			use_power(src.power_usage * power/10)
		if(prob(25 * power/20))
			shield_off(1)
		return

	meteorhit() //Actual handling done in the shield objects.
		shield_off(1) //guess you shoulda turned it on!
		qdel(src)
		return

	//Code for power draw. Dictates actual draw, also used in description.
	proc/get_draw()
		return 30 * src.range * (src.power_level * src.power_level)

	//Checks if connected grid exists and is adequately powered. Doesn't use get_direct_powernet because that requires knots
	proc/line_powered()
		. = FALSE
		if(!src.connected_wire)
			return
		var/datum/powernet/net = src.connected_wire.get_powernet()
		if (net)
			if (net.avail - net.newload > power_usage)
				. = TRUE
		return

	proc/process_wired()
		//check for linepower
		if(line_powered())
			src.power_usage = get_draw()
			use_power(src.power_usage)

			//automatically turn back on if gen was deactivated due to power outage
			if(backup)
				backup = !backup
				src.shield_on()

			src.battery_level = 3
			src.build_icon()

			return
		else //connected grid missing or has no power
			if(!backup)
				backup = !backup
				first = 1
			//this iff is for testing the auto turn back on
			if(src.active && first)
				first = 0
				src.shield_off()
			return

	proc/process_battery()
		PCEL.use(get_draw())
		var/charge_percentage = 0
		var/current_battery_level = 0
		if(PCEL?.charge > 0 && PCEL.maxcharge > 0)
			charge_percentage = round((PCEL.charge/PCEL.maxcharge)*100)
			switch(charge_percentage)
				if(75 to 100)
					current_battery_level = 3
				if(35 to 74)
					current_battery_level = 2
				else
					current_battery_level = 1

		if(current_battery_level != src.battery_level)
			src.battery_level = current_battery_level
			src.build_icon()
			if(src.battery_level == 1)
				playsound(src.loc, src.sound_battwarning, 50, 1)
				src.visible_message("<span class='alert'>The <b>[src.name] emits a low battery alarm!</b></span>")

		if(PCEL.charge <= 0)
			src.visible_message("The <b>[src.name]</b> runs out of power and shuts down.")
			src.shield_off()
			return

	proc/set_range(var/mob/user)
		var/the_range = input("Enter a range from [src.min_range]-[src.max_range]. Higher ranges use more power.","[src.name]",2) as null|num
		if(!the_range)
			return
		if(BOUNDS_DIST(user, src) > 0)
			boutput(user, "<span class='alert'>You flail your arms at [src.name] from across the room like a complete muppet. Move closer, genius!</span>")
			return
		the_range = clamp(the_range, src.min_range, src.max_range)
		src.range = the_range
		var/outcome_text = "You set the range to [src.range]."
		if(src.active)
			outcome_text += " The generator shuts down for a brief moment to recalibrate."
			shield_off()
			sleep(0.5 SECONDS)
			shield_on()
		boutput(user, "<span class='notice'>[outcome_text]</span>")

	proc/pulse(var/mob/user)
		set_range(user)

	get_desc(dist, mob/user)
		. = ..()
		var/charge_percentage = 0
		if(PCEL?.charge > 0 && PCEL.maxcharge > 0)
			charge_percentage = round((PCEL.charge/PCEL.maxcharge)*100)
			. += "It has [PCEL.charge]/[PCEL.maxcharge] ([charge_percentage]%) battery power left."
			. += "The range setting is set to [src.range]."
			. += "The unit will consume [30 * src.range] power a second, and [60 * src.range] per meteor strike against the projected shield."
		else
			. += "It seems to be missing a usable battery."

	attack_hand(mob/user)
		if(src.coveropen && src.PCEL)
			src.PCEL.set_loc(src.loc)
			src.PCEL = null
			boutput(user, "You remove the power cell.")
			if(src.active)
				src.shield_off()
		else
			if(src.active)
				src.shield_off()
			else
				if(PCEL)
					if(PCEL.charge > 0)
						src.shield_on()
					else
						boutput(user, "The [src.name]'s battery light flickers briefly.")
				else	//turn on power if connected to a power grid with power in it
					if(line_powered() && connected)
						src.shield_on()
						src.visible_message("<b>[user.name]</b> powers up the [src.name].")
					else
						boutput(user, "The [src.name]'s battery light flickers briefly.")
		build_icon()

	attackby(obj/item/W, mob/user)
		if(ispryingtool(W))
			if(!anchored)
				src.set_dir(turn(src.dir, 90))
			else
				boutput(user, "You don't think you should mess around with the [src.name] while it's active.")
		else if(ispulsingtool(W))
			pulse(user)
		else if(isscrewingtool(W))
			if(!active)
				src.coveropen = !src.coveropen
				src.visible_message("<b>[user.name]</b> [src.coveropen ? "opens" : "closes"] [src.name]'s cell cover.")
			else
				boutput(user, "You don't think you should mess around with the [src.name] while it's active.")
				return
		else if(iswrenchingtool(W))
			if(active)
				boutput(user, "Disconnecting [src.name] from the power source while active doesn't sound like the best idea.")
				return

			//just checking if it's placed on any wire, like powersink
			var/obj/cable/C = locate() in get_turf(src)
			if(C) //if generator is on wire
				if(!src.connected)
					src.connected_wire = C
				else
					src.connected_wire = null
				src.connected = !src.connected
				src.anchored = !src.anchored
				src.backup = 0
				src.visible_message("<b>[user.name]</b> [src.connected ? "connects" : "disconnects"] [src.name] [src.connected ? "to" : "from"] the wire.")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			else
				boutput(user, "There is no cable to connect to.")


		else if(src.coveropen && !src.PCEL)
			if(istype(W,/obj/item/cell/))
				user.drop_item()
				W.set_loc(src)
				src.PCEL = W
				boutput(user, "You insert the power cell.")

		else
			..()

		build_icon()

	attack_ai(mob/user as mob)
		return attack_hand(user)

	proc/build_icon()
		src.overlays = null
		if(src.coveropen)
			if(istype(src.PCEL,/obj/item/cell/))
				src.display_panel.icon_state = "panel-batt[direction]"
			else
				src.display_panel.icon_state = "panel-nobatt[direction]"

			src.overlays += src.display_panel

		if(src.active)
			src.overlays += src.display_active
			if(istype(src.PCEL,/obj/item/cell))
				var/charge_percentage = null
				if(PCEL.charge > 0 && PCEL.maxcharge > 0)
					charge_percentage = round((PCEL.charge/PCEL.maxcharge)*100)
					switch(charge_percentage)
						if(75 to 100)
							src.display_battery.icon_state = "batt-3[direction]"
						if(35 to 74)
							src.display_battery.icon_state = "batt-2[direction]"
						else
							src.display_battery.icon_state = "batt-1[direction]"
				else
					src.display_battery.icon_state = "batt-3[direction]"
				src.overlays += src.display_battery

	//this method should be overridden in child. Currenlty just draws single tile meteor shield
	proc/shield_on()
		if(!PCEL)
			return
		if(PCEL.charge < 0)
			return

		var/turf/T = locate((src.x),(src.y),src.z)
		var/obj/forcefield/meteorshield/S = new /obj/forcefield/meteorshield(T)
		S.deployer = src
		src.deployed_shields += S

		src.anchored = 1
		src.active = 1
		playsound(src.loc, src.sound_on, 50, 1)
		build_icon()


	proc/shield_off(var/failed = 0)
		for(var/obj/forcefield/S in src.deployed_shields)
			src.deployed_shields -= S
			S:deployer = null	//There is no parent forcefield object and I'm not gonna be the one to make it so ":"
			qdel(S)

		if(!connected)
			src.anchored = 0
		src.active = 0

		//currently only the e-shield interacts with atmos
		// if(istype(src,/obj/machinery/shieldgenerator/energy_shield))
		// 	update_nearby_tiles()
		if(failed)
			src.visible_message("The <b>[src.name]</b> fails, and shuts down!")
		playsound(src.loc, src.sound_off, 50, 1)
		build_icon()

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.PCEL)
			src.PCEL = null

/*
/Force field objects for various generators
**/

/obj/forcefield/meteorshield
	name = "Impact Forcefield"
	desc = "A force field deployed to stop meteors and other high velocity masses."
	icon = 'icons/obj/meteor_shield.dmi'
	icon_state = "shield"
	var/sound/sound_shieldhit = 'sound/impact_sounds/Energy_Hit_1.ogg'
	var/obj/machinery/shieldgenerator/meteorshield/deployer = null

	attackby(obj/item/W, mob/user)
		. = ..()
		if(istype(deployer, /obj/machinery/shieldgenerator/meteorshield))
			var/obj/machinery/shieldgenerator/meteorshield/MS = deployer
			//blocks solid objects
			var/force_value = clamp(W.force/4, 1, 10)
			if(MS.PCEL && !MS.connected && MS.active)
				MS.PCEL.use(force_value * MS.range * (MS.power_level * MS.power_level))
			else if(MS.connected)
				MS.use_power(MS.power_usage + force_value )

			playsound(src, src.sound_shieldhit, 20, 1)
			return

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round(((P.power/6)*P.proj_data.ks_ratio), 1.0)
		if (!damage)
			return

		if(istype(deployer, /obj/machinery/shieldgenerator/meteorshield))
			var/obj/machinery/shieldgenerator/meteorshield/MS = deployer
			//blocks solid objects
			var/force_value
			if((P.proj_data.damage_type == D_PIERCING) || (P.proj_data.damage_type == D_ENERGY))
				force_value = damage
			else if (P.proj_data.damage_type == D_KINETIC)
				force_value = damage / 1.7

			if(MS.PCEL && !MS.connected && MS.active)
				MS.PCEL.use(force_value * MS.range * (MS.power_level * MS.power_level))
			else if(MS.connected)
				MS.use_power(MS.power_usage + force_value )

			playsound(src, src.sound_shieldhit, 20, 1)

	meteorhit(obj/O as obj)
		if(istype(deployer, /obj/machinery/shieldgenerator/meteorshield))
			var/obj/machinery/shieldgenerator/meteorshield/MS = deployer
			if(MS.PCEL && !MS.connected && MS.active)
				MS.PCEL.use(60 * MS.range)
			else if(MS.connected && MS.active)
				MS.use_power(MS.power_usage)
			playsound(src.loc, src.sound_shieldhit, 50, 1)
			return

	ex_act(severity)
		if(istype(deployer, /obj/machinery/shieldgenerator/meteorshield))
			var/obj/machinery/shieldgenerator/meteorshield/MS = deployer

			switch(severity)
				if(1)
					playsound(src.loc, src.sound_shieldhit, 50, 1)
					MS.shield_off(1) //1 for failed
					qdel(src)
					return
				if(2)
					if(MS.PCEL && !MS.connected && MS.active)
						MS.PCEL.use(120 * MS.range)
					else if(MS.connected && MS.active)
						MS.use_power(MS.power_usage * 4)
					playsound(src.loc, src.sound_shieldhit, 50, 1)
					return
				if(3)
					if(MS.PCEL && !MS.connected && MS.active)
						MS.PCEL.use(60 * MS.range)
					else if(MS.connected && MS.active)
						MS.use_power(MS.power_usage * 2)
					playsound(src.loc, src.sound_shieldhit, 50, 1)
					return

	blob_act(var/power)
		if(istype(deployer, /obj/machinery/shieldgenerator/meteorshield))
			var/obj/machinery/shieldgenerator/meteorshield/MS = deployer

			if(MS.PCEL && !MS.connected && MS.active)
				MS.PCEL.use(60 * MS.range * (MS.power_level * MS.power_level))
			else if(MS.connected && MS.active)
				MS.use_power(MS.power_usage * 2)
			if(prob(25 * power/20))
				MS.shield_off(1)
			playsound(src.loc, src.sound_shieldhit, 50, 1)
			return

/obj/forcefield/energyshield
	name = "Forcefield"
	desc = "A force field that can block various states of matter."
	icon = 'icons/obj/meteor_shield.dmi'
	icon_state = "shieldw"
	event_handler_flags = USE_FLUID_ENTER
	var/powerlevel //Stores the power level of the deployer
	var/isactive = TRUE
	density = 0

	var/sound/sound_shieldhit = 'sound/impact_sounds/Energy_Hit_1.ogg'
	var/obj/machinery/shieldgenerator/deployer = null
	var/obj/machinery/door/linked_door = null
	var/update_tiles

	flags = 0

	New(Loc, var/obj/machinery/shieldgenerator/deployer, var/update_tiles)
		..()
		src.update_tiles = update_tiles
		src.deployer = deployer

		if(update_tiles)
			update_nearby_tiles()

		if((deployer != null && deployer.power_level == 4) || src.powerlevel == 4)
			src.name = "Liquid Forcefield"
			src.desc = "A force field that prevents liquids from passing through it."
			src.icon_state = "shieldw"
			src.color = "#FF33FF" //change colour for different power levels
			src.powerlevel = 4
			src.mouse_opacity = 0
			flags = ALWAYS_SOLID_FLUID | FLUID_DENSE
		else if(deployer != null && deployer.power_level == 1)
			src.name = "Atmospheric Forcefield"
			src.desc = "A force field that prevents gas from passing through it."
			src.icon_state = "shieldw"
			src.color = "#3333FF" //change colour for different power levels
			src.powerlevel = 1
			src.mouse_opacity = 0
			flags = 0
			gas_impermeable = TRUE
		else if(deployer != null && deployer.power_level == 2)
			src.name = "Atmospheric/Liquid Forcefield"
			src.desc = "A force field that prevents gas and liquids from passing through it."
			src.icon_state = "shieldw"
			src.color = "#33FF33"
			src.powerlevel = 2
			src.mouse_opacity = 0
			flags = ALWAYS_SOLID_FLUID | FLUID_DENSE
			gas_impermeable = TRUE
		else if(deployer != null)
			src.name = "Energy Forcefield"
			src.desc = "A force field that prevents matter from passing through it."
			src.icon_state = "shieldw"
			src.color = "#FF3333"
			src.powerlevel = 3
			src.mouse_opacity = 1
			flags = ALWAYS_SOLID_FLUID | USEDELAY | FLUID_DENSE
			density = 1

	disposing()
		if(linked_door)
			linked_door.linked_forcefield = null
		if(update_tiles)
			update_nearby_tiles()
		deployer = 0
		..()

	//hello it is kubius, this is moved here and changed to respect + not modify powerlevel
	proc/setactive(var/a = 0) //this is called in a bunch of diff. door open procs. because the code was messy when i made this and i dont wanna redo door open code
		if(a == 1)
			src.icon_state = "shieldw"
			src.isactive = TRUE
			src.invisibility = INVIS_NONE
			//these power levels are kind of arbitrary
			if(src.powerlevel >= 2) src.flags |= FLUID_DENSE
			if(src.powerlevel < 3) src.gas_impermeable = TRUE
			if(src.powerlevel == 3) src.mouse_opacity = 1
		else
			src.icon_state = ""
			src.isactive = FALSE
			src.invisibility = INVIS_ALWAYS_ISH //ehh whatever this "works"
			src.flags &= ~FLUID_DENSE
			src.gas_impermeable = FALSE
			src.mouse_opacity = 0

	proc/update_nearby_tiles(need_rebuild)
		var/turf/simulated/source = loc
		if(istype(source))
			return source.update_nearby_tiles(need_rebuild)

		return 1

	attackby(obj/item/W, mob/user)
		. = ..()
		if(istype(deployer, /obj/machinery/shieldgenerator/energy_shield))
			var/obj/machinery/shieldgenerator/energy_shield/ES = deployer
			//blocks solid objects
			if(ES.power_level == 3)
				var/force_value = clamp(W.force/4, 1, 20)
				if(ES.PCEL && !ES.connected && ES.active)
					ES.PCEL.use(force_value * ES.range * (ES.power_level * ES.power_level))
				else if(ES.connected)
					ES.use_power(ES.power_usage + force_value )

				playsound(src, src.sound_shieldhit, 20, 1)
			return

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round((P.power/3), 1.0)
		if (!damage)
			return

		if(istype(deployer, /obj/machinery/shieldgenerator/energy_shield))
			var/obj/machinery/shieldgenerator/energy_shield/ES = deployer
			//blocks solid objects
			if(ES.power_level == 3)
				var/force_value
				if((P.proj_data.damage_type == D_PIERCING) || (P.proj_data.damage_type == D_ENERGY))
					force_value = damage
				else if (P.proj_data.damage_type == D_KINETIC)
					force_value = damage / 1.7

				if(ES.PCEL && !ES.connected && ES.active)
					ES.PCEL.use(force_value * ES.range * (ES.power_level * ES.power_level))
				else if(ES.connected)
					ES.use_power(ES.power_usage * (0.5 * force_value) )

				playsound(src, src.sound_shieldhit, 20, 1)

	meteorhit(obj/O as obj)
		if(istype(deployer, /obj/machinery/shieldgenerator/energy_shield))
			var/obj/machinery/shieldgenerator/energy_shield/ES = deployer
			//unless the power level is 3, which blocks solid objects, meteors should pass through untoucheda
			if(ES.power_level == 3)
				if(ES.PCEL && !ES.connected && ES.active)	//Technically these shields can be used as emergency meteor shields, but they are very bad a blocking them
					ES.PCEL.use(120 * ES.range * (ES.power_level * ES.power_level))
				else if(ES.connected && ES.active)
					ES.use_power(ES.power_usage * 2)
			playsound(src.loc, src.sound_shieldhit, 50, 1)
			return

	ex_act(severity)
		if(istype(deployer, /obj/machinery/shieldgenerator/energy_shield))
			var/obj/machinery/shieldgenerator/energy_shield/ES = deployer

			switch(severity)
				if(1)
					playsound(src.loc, src.sound_shieldhit, 50, 1)
					ES.shield_off(1) //1 for failed
					qdel(src)
					return
				if(2)
					if(ES.PCEL && !ES.connected && ES.active)
						ES.PCEL.use(60 * ES.range * (ES.power_level * ES.power_level))
					else if(ES.connected && ES.active)
						ES.use_power(ES.power_usage * 4)
					playsound(src.loc, src.sound_shieldhit, 50, 1)
					return
				if(3)
					if(ES.PCEL && !ES.connected && ES.active)
						ES.PCEL.use(30 * ES.range * (ES.power_level * ES.power_level))
					else if(ES.connected && ES.active)
						ES.use_power(ES.power_usage * 2)
					playsound(src.loc, src.sound_shieldhit, 50, 1)
					return

	blob_act(var/power)
		if(istype(deployer, /obj/machinery/shieldgenerator/energy_shield))
			var/obj/machinery/shieldgenerator/energy_shield/ES = deployer

			if(ES.PCEL && !ES.connected && ES.active)
				ES.PCEL.use(20 * ES.range * (ES.power_level * ES.power_level))
			else if(ES.connected)
				ES.use_power(ES.power_usage * 2)
			if(prob(25 * power/20))
				ES.shield_off(1)
			playsound(src.loc, src.sound_shieldhit, 50, 1)
			return



//sealab arrivalss
/obj/machinery/door/var/obj/forcefield/energyshield/linked_forcefield = 0

/obj/forcefield/energyshield/perma
	name = "Permanent Atmospheric/Liquid Forcefield"
	desc = "A permanent force field that prevents gas and liquids from passing through it."
	color = "#33FF33"
	powerlevel = 2
	layer = 2.5 //sits under doors if we want it to
	flags = ALWAYS_SOLID_FLUID | FLUID_DENSE
	gas_impermeable = TRUE
	event_handler_flags = USE_FLUID_ENTER

	meteorhit(obj/O as obj)
		return

	ex_act(severity)
		return

	blob_act(var/power)
		return

/obj/forcefield/energyshield/perma/vehicle
	name = "Permanent Vehicular Forcefield"
	desc = "A permanent force field that prevents gas, liquids, and vehicles from passing through it."

	Cross(atom/A)
		return ..() && !istype(A,/obj/machinery/vehicle)

/obj/forcefield/energyshield/perma/doorlink
	name = "Door-linked Atmospheric/Liquid Forcefield"
	desc = "A door-linked force field that prevents gas and liquids from passing through it."
	New()
		..()
		setactive(0)
		SPAWN(1 SECOND)//yucky...
			var/obj/machinery/door/door = (locate() in src.loc)
			if(door)
				door.linked_forcefield = src
				src.linked_door = door
				src.set_dir(door.dir)

/obj/machinery/door/disposing()
	if(linked_forcefield)
		qdel(linked_forcefield)
		linked_forcefield = 0
	..()
