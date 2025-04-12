/obj/item/shipcomponent/mainweapon
	name = "Class-A Light Phaser"
	desc = "A simple phaser designed for scout vehicles."
	var/r_gunner = 0
	var/mob/gunner = null
	var/datum/projectile/current_projectile = new/datum/projectile/laser/light/pod
	var/firerate = 8
	/// number of projectiles that are fired when weapon is fired
	var/shots_to_fire = 1
	/// change to a degree in angles to give custom spread
	var/spread = -1
	var/weapon_score = 0.1
	var/appearanceString

	var/uses_ammunition = 0
	var/remaining_ammunition = 0
	var/muzzle_flash = null

	/// Can it be removed by a player
	var/removable = TRUE

	icon = 'icons/obj/podweapons.dmi'		//remove this line.  or leave it. Could put these sprites in ship.dmi like how the original is
	icon_state = "class-a"

	power_used = 65
	system = "Main Weapon"
	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		src.add_dialog(user)

		var/dat = "<TT><B>[src] Console</B><BR><HR><BR>"
		if(src.active)
			if(r_gunner)
				dat += {"<B>Gunner:</B>"}
				if(!gunner)
					dat += {"<A href='?src=\ref[src];gunner=1'>Enter Gunner Seat</A><BR>"}
				else
					dat += {"[src]<BR>"}
			if(uses_ammunition)
				dat += {"<b>Remaining ammo:</b> [remaining_ammunition]<BR>"}
		else
			dat += {"<B><span style=\"color:red\">SYSTEM OFFLINE</span></B>"}
		user.Browse(dat, "window=ship_main_weapon")
		onclose(user, "ship_main_weapon")
		return

	Topic(href, href_list)
		if(usr.stat || usr.restrained())
			return

		if (usr.loc == ship)
			src.add_dialog(usr)

			if (href_list["gunner"])
				MakeGunner(usr)
				src.updateDialog()

			src.add_fingerprint(usr)
			for(var/mob/M in ship)
				if (M.using_dialog_of(src))
					src.opencomputer(M)
		else
			usr.Browse(null, "window=ship_main_weapon")
			return
		return

/obj/item/shipcomponent/mainweapon/buildTooltipContent()
	. = ..() + src.current_projectile?.get_tooltip_content()
	. += "<br><img src=\"[resource("images/tooltips/frenzy.png")]\" class='icon' style='width: .8em; height: .8em;' /> Firerate: [src.firerate / 10] seconds"
	src.lastTooltipContent = .

/obj/item/shipcomponent/mainweapon/proc/Fire(var/mob/user,var/shot_dir_override = -1)
	if(ON_COOLDOWN(src, "fire", firerate))
		return
	EXTEND_COOLDOWN(src, "weapon_swap_cd", 10 SECONDS)
	if(uses_ammunition)
		if (remaining_ammunition < ship.AmmoPerShot())
			boutput(user, "[ship.ship_message("You need [ship.AmmoPerShot()] to fire the weapon. You currently have [remaining_ammunition] loaded.")]")
			return
		else
			boutput(user, "[ship.ship_message("[remaining_ammunition] shots remaining.")]")

	var/rdir = ship.dir
	if (shot_dir_override > 1)
		rdir = shot_dir_override
	//if (!istype(ship,/obj/machinery/vehicle/tank)) //Tanks are allowed to shoot diagonally!
	//	if ((rdir - 1) & rdir)
	//		rdir &= 12
	logTheThing(LOG_COMBAT, user, "driving [ship.name] fires [src.name] (<b>Dir:</b> <i>[dir2text(rdir)]</i>, <b>Projectile:</b> <i>[src.current_projectile]</i>) at [log_loc(ship)].") // Similar to handguns, but without target coordinates (Convair880).
	ship.ShootProjectiles(user, current_projectile, rdir, src.spread, src.shots_to_fire)
	remaining_ammunition -= ship.AmmoPerShot()

/obj/item/shipcomponent/mainweapon/proc/MakeGunner(mob/M as mob)
	if(!gunner)
		gunner = M

/obj/item/shipcomponent/mainweapon/light_longrange
	name = "Class-AX Light Long-range Phaser"
	desc = "A phaser designed for scout vehicles. Features a more focused energy discharge, leading to an increased range."
	current_projectile = new/datum/projectile/laser/light/longrange
	icon_state = "class-a"
	muzzle_flash = "muzzle_flash_phaser"

/obj/item/shipcomponent/mainweapon/mining
	name = "Plasma Cutter System"
	desc = "A high-temperature rock cutter for pods. Use with extreme caution."
	power_used = 80
	weapon_score = 0.7
	current_projectile = new/datum/projectile/laser/mining
	appearanceString = "pod_weapon_cutter_on"
	firerate = 12
	icon_state = "plasma-cutter"

/obj/item/shipcomponent/mainweapon/bad_mining
	name = "Mining Phaser System"
	desc = "A weak, short-range phaser that can cut through solid rock. Weak damage, but more effective against critters."
	power_used = 10
	current_projectile = new/datum/projectile/laser/light/mining
	appearanceString = "pod_weapon_ltlaser"
	firerate = 7
	icon_state = "mining-phaser"

/obj/item/shipcomponent/mainweapon/taser
	name = "Mk.1 Combat Taser"
	desc = "A projectile-based weapon used to non-lethally disable people."
	power_used = 50
	appearanceString = "pod_weapon_taser"
	weapon_score = 0.2
	current_projectile = new/datum/projectile/energy_bolt
	firerate = 10
	icon_state = "combat-taser"
	muzzle_flash = "muzzle_flash_elec"

/obj/item/shipcomponent/mainweapon/phaser
	name = "Mk 1.5 Light Phaser"
	desc = "A basic, light weight phaser designed for scout vehicles."
	weapon_score = 0.3
	appearanceString = "pod_weapon_ltlaser"
	current_projectile = new/datum/projectile/laser/light/pod
	icon_state = "class-a"
	muzzle_flash = "muzzle_flash_phaser"

/obj/item/shipcomponent/mainweapon/phaser/burst_phaser
	name = "Mk 1.5e Burst Phaser"
	desc = "A variant of the Mk 1.5 Light Phaser that fires a stronger burst of 3 shots at a third of the firerate."
	firerate = 2.4 SECONDS
	shots_to_fire = 3
	current_projectile = new/datum/projectile/laser/light/pod/burst
	icon_state = "class-a-burst"

/obj/item/shipcomponent/mainweapon/phaser/short
	name = "Mk 1.45 Light Phaser"
	desc = "A basic, light weight phaser designed for close quarters space fights..."
	weapon_score = 0.2
	appearanceString = "pod_weapon_ltlaser"
	current_projectile = new/datum/projectile/laser/light
	icon_state = "class-a"
	muzzle_flash = "muzzle_flash_phaser"

/obj/item/shipcomponent/mainweapon/laser
	name = "Mk.2 Scout Laser"
	desc = "An upgraded variant of the stock MK 1.5 phaser. Due to the concentration of energy, a higher quality engine might be necessary."
	weapon_score = 0.4
	appearanceString = "pod_weapon_laser"
	power_used = 100
	current_projectile = new/datum/projectile/laser/pod
	icon_state = "mk-2-scout"
	muzzle_flash = "muzzle_flash_laser"

/obj/item/shipcomponent/mainweapon/laser/short
	name = "Mk.2 CQ Laser"
	desc = "A downgraded variant of the upgraded MK 2.0 laser. Doesn't shoot quite as far, but doesn't use quite as much energy either."
	weapon_score = 0.35
	appearanceString = "pod_weapon_laser"
	power_used = 75
	current_projectile = new/datum/projectile/laser
	icon_state = "mk-2-scout"
	muzzle_flash = "muzzle_flash_laser"


/obj/item/shipcomponent/mainweapon/maser
	name = "Syndicate Maser Device"
	desc = "A microwave beam weapon that bypasses pod armor to directly damage the pilot. Quite nasty."
	weapon_score = 0.4
	appearanceString = "pod_weapon_maser"
	current_projectile = new/datum/projectile/laser/light/maser/pod
	icon_state = "maser"
	muzzle_flash = null

/obj/item/shipcomponent/mainweapon/russian
	name = "Svet-Oruzhiye Mk.4"
	weapon_score = 0.6
	current_projectile = new/datum/projectile/laser/glitter
	power_used = 75
	firerate = 5
	icon_state = "strelka"
	muzzle_flash = "muzzle_flash_laser"
	removable = FALSE

/obj/item/shipcomponent/mainweapon/disruptor_light
	name = "Mk.3 Disruptor"
	desc = "A projectile-based weapon used to disable vehicles."
	weapon_score = 0.6
	current_projectile = new/datum/projectile/disruptor
	icon_state = "disruptor-l"
	muzzle_flash = "muzzle_flash_plaser"

/obj/item/shipcomponent/mainweapon/precursor
	name = "IRIDIUM Spheroid Projector"
	desc = "****CLASSIFIED: THANOTECH APPLIED RESEARCH DIVISION, Y-LEVEL CLEARANCE REQUIRED****."
	weapon_score = 1.25
	current_projectile = new/datum/projectile/laser/precursor/sphere
	appearanceString = "pod_weapon_precursor"
	firerate = 25

/obj/item/shipcomponent/mainweapon/gun
	name = "SPE-12 Ballistic System"
	desc = "A one of it's kind kinetic podweapon, designed to fire shotgun rounds similar to those in a SPES-12."
	weapon_score = 1.25
	power_used = 30
	current_projectile = new/datum/projectile/bullet/a12/weak
	appearanceString = "pod_weapon_gun_off"
	firerate = 10
	icon_state = "spes"
	muzzle_flash = "muzzle_flash"

/obj/item/shipcomponent/mainweapon/minigun
	name = "Minigun"
	desc = "A low damage but high firerate anti-personnel minigun stuffed into a pod weapon."
	weapon_score = 1.25
	firerate = 0.25 SECONDS
	spread = 25
	appearanceString = "pod_weapon_gun_off"
	current_projectile = new/datum/projectile/bullet/akm/pod
	icon_state = "minigun"
	muzzle_flash = "muzzle_flash"

/obj/item/shipcomponent/mainweapon/gun_9mm
	name = "PEP-9 Ballistic System"
	desc = "A peashooter attached to a kinetic podweapon, designed to fire 9mm rounds."
	weapon_score = 1.25
	power_used = 30
	current_projectile = new/datum/projectile/bullet/bullet_9mm
	appearanceString = "pod_weapon_gun_off"
	firerate = 10
	icon_state = "spes"
	muzzle_flash = "muzzle_flash"

/obj/item/shipcomponent/mainweapon/gun_9mm/uses_ammo
	name = "PEP-9L Ballistic System"
	desc = "A peashooter attached to a kinetic podweapon, designed to fire 9mm rounds. It has an integral magazine that must be reloaded when empty."

	uses_ammunition = 1
	remaining_ammunition = 20

/obj/item/shipcomponent/mainweapon/gun_22
	name = "PEP-22 Ballistic System"
	desc = "A peashooter attached to a kinetic podweapon, designed to fire 22 caliber rounds."
	weapon_score = 1.25
	power_used = 30
	current_projectile = new/datum/projectile/bullet/bullet_22
	appearanceString = "pod_weapon_gun_off"
	firerate = 10
	icon_state = "spes"
	muzzle_flash = "muzzle_flash"

/obj/item/shipcomponent/mainweapon/gun_22/uses_ammo
	name = "PEP-22L Ballistic System"
	desc = "A peashooter attached to a kinetic podweapon, designed to fire 22 caliber rounds. It has an integral magazine that must be reloaded when empty."

	uses_ammunition = 1
	remaining_ammunition = 20

/obj/item/shipcomponent/mainweapon/salvo_rockets
	name = "Cerberus Salvo Rockets"
	desc = "A three-rocket salvo launcher, created in mind for multi-purpose space combat. Usable only by small pods."
	icon_state = "cerberus-salvo-rockets"
	weapon_score = 1.25
	power_used = 50
	current_projectile = new/datum/projectile/bullet/homing/rocket/salvo
	appearanceString = "pod_weapon_cerberus"
	firerate = 5 SECONDS
	shots_to_fire = 3
	spread = 30
	large_pod_compatible = FALSE

/obj/item/shipcomponent/mainweapon/laser_ass // hehhh
	name = "Mk.4 Assault Laser"
	weapon_score = 1.25
	power_used = 300
	firerate = 35
	appearanceString = "pod_weapon_emitter"
	current_projectile = new/datum/projectile/laser/asslaser
	icon_state = "assult-laser"
	muzzle_flash = "muzzle_flash_laser"

/obj/item/shipcomponent/mainweapon/hammer_railgun
	name = "Hammerhead Railgun"
	desc = "A powerful wall-piercing railgun designed for siege operations."
	firerate = 5 SECONDS
	power_used = 100
	current_projectile = new/datum/projectile/bullet/hammer_railgun
	weapon_score = 1.5
	appearanceString = "pod_weapon_hammer_railgun"
	icon_state = "hammer-railgun"
	muzzle_flash = "muzzle_flash_launch"

/obj/item/shipcomponent/mainweapon/rockdrills
	name = "Rock Drilling Rig"
	desc = "A sturdy drill designed for chewing up asteroids like nobodies business."
	power_used = 90
	weapon_score = 1
	current_projectile = new/datum/projectile/laser/drill
	appearanceString = "pod_weapon_drills"
	firerate = 10
	icon_state = "rock-drill"

/obj/item/shipcomponent/mainweapon/disruptor
	name = "Heavy Disruptor Array"
	desc = "Huh."
	power_used = 180
	weapon_score = 1.25
	current_projectile = new/datum/projectile/disruptor/high
	appearanceString = "pod_weapon_cbeam_off"
	firerate = 25
	icon_state = "disruptor-h"

/obj/item/shipcomponent/mainweapon/artillery
	name = "40mm Grenade Launcher Platform"
	desc = "A slow but extremely destructive weapon that fires explosive 40mm shells."
	current_projectile = new/datum/projectile/bullet/autocannon

	uses_ammunition = 1
	remaining_ammunition = 14

	weapon_score = 1.5
	appearanceString = "pod_weapon_bfg"
	firerate = 100
	icon_state = "grenade-launcher"
	muzzle_flash = "muzzle_flash_launch"

	lower_ammo
		remaining_ammunition = 6

/obj/item/shipcomponent/mainweapon/UFO
	name = "UFO Blaster"
	desc = "An extraterrestrial weapons system."
	weapon_score = 1.1
	var/datum/projectile/ufo = new/datum/projectile/bullet/flare/UFO
	var/datum/projectile/hlaser = new/datum/projectile/laser/heavy
	var/mode = 0

	New()
		..()
		current_projectile = ufo

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		src.add_dialog(user)

		var/dat = "<TT><B>Weapon Console</B><BR><HR>"
		if(src.active)
			dat +="<B>Weapon Mode:</B><BR>"
			if(mode == 0)
				dat+="Heat Beam<BR>"
				dat+="<A href='?src=\ref[src];death=1'>Death Ray</A><BR>"
			else
				dat+="<A href='?src=\ref[src];heat=1'>Heat Beam</A><BR>"
				dat+="Death Ray<BR>"

		else
			dat += {"<B><span style=\"color:red\">SYSTEM OFFLINE</span></B>"}
		user.Browse(dat, "window=ship_main_weapon")
		onclose(user, "ship_main_weapon")
		return

	Topic(href, href_list)
		if(..())
			return

		if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
			src.add_dialog(usr)

		if (href_list["heat"])
			current_projectile = ufo
			mode = 0
		else if(href_list["death"])
			current_projectile = hlaser
			mode = 1
		opencomputer(usr)
		return

// engineer miniputt constructor utility

/obj/item/shipcomponent/mainweapon/foamer
	name = "Industrial Utility Arms"
	desc = "A pair of robotic arms equipped with metalfoam nozzles and cutter blades."
	current_projectile = new/datum/projectile/laser/drill/cutter
	firerate = 60
	var/mode = 0
	icon_state = "util-arms"

	attack_self(var/mob/user)
		mode = !mode
		..()

	Fire(var/mob/user,var/shot_dir_override = -1)
		switch(mode)
			if(0)
				if(ON_COOLDOWN(src, "fire", firerate))
					return
				EXTEND_COOLDOWN(src, "weapon_swap_cd", 10 SECONDS)
				var/obj/decal/D = new/obj/decal(ship.loc)
				D.set_dir(ship.dir)
				if (shot_dir_override > 1)
					D.set_dir(shot_dir_override)

				D.name = "metal foam spray"
				D.icon = 'icons/obj/chemical.dmi'
				D.icon_state = "chempuff"
				D.layer = EFFECTS_LAYER_BASE

				playsound(src.loc, 'sound/machines/mixer.ogg', 50, 1)

				// Necessary, as the foamer doesn't use the global fire proc (Convair880).
				logTheThing(LOG_COMBAT, user, "driving [ship.name] fires [src.name], creating metal foam at [log_loc(ship)].")

				SPAWN(0)
					step_towards(D, get_step(D, D.dir))
					var/location = get_turf(D)
					for(var/mob/M in AIviewers(5, location))
						boutput(M, SPAN_ALERT("[ship] spews out a metallic foam!"))
					var/list/bandaidfix = list("iron" = 3, "fluorosurfactant" = 1, "acid" = 1)
					var/datum/effects/system/foam_spread/s = new()
					s.set_up(5, location, bandaidfix, 1) // Aborts if reagent list is null (even for metal foam), but I'm not gonna touch foam_spread.dm (Convair880).
					s.start()
					sleep(0.3 SECONDS)
					D.dispose()
			if(1)
				..()

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		src.add_dialog(user)

		var/dat = "<TT><B>Weapon Console</B><BR><HR>"
		if(src.active)
			dat +="<B>Weapon Mode:</B><BR>"
			if(mode == 0)
				dat+="Metalfoam Constructor Nozzles<BR>"
				dat+="<A href='?src=\ref[src];cutter=1'>Switch to Cutter Blades</A><BR>"
			else
				dat+="<A href='?src=\ref[src];foam=1'>Switch to Foam Nozzles</A><BR>"
				dat+="Industrial Cutter Blades<BR>"

		else
			dat += {"<B><span style=\"color:red\">SYSTEM OFFLINE</span></B>"}
		user.Browse(dat, "window=ship_main_weapon")
		onclose(user, "ship_main_weapon")
		return

	Topic(href, href_list)
		if(..())
			return

		if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
			src.add_dialog(usr)

		if (href_list["foam"])
			mode = 0
			firerate = 60

		else if(href_list["cutter"])
			mode = 1
			firerate = 15

		opencomputer(usr)
		return

// Extra-Facility Integrity Fabricator: the big boyo pod construction tool

//mode defines for tool
#define EFIF_MODE_DRILL 0
#define EFIF_MODE_FLOORS 1
#define EFIF_MODE_R_FLOORS 2
#define EFIF_MODE_WALLS 3
#define EFIF_MODE_REPAIR 4

//construction time modifier per tile
#define EFIF_FLOOR_BUILD_TIME 2
#define EFIF_R_FLOOR_BUILD_TIME 3
#define EFIF_WALL_BUILD_TIME 6
//walls will also require the floor build time if built directly on space

//construction cost per tile
#define EFIF_FLOOR_COST 1
#define EFIF_R_FLOOR_COST 2
#define EFIF_WALL_COST 4

//sheet-loading success flags
#define LOAD_FULL 1
#define LOAD_SUCCESS 2

TYPEINFO(/obj/item/shipcomponent/mainweapon/constructor)
	mats = list("metal_superdense" = 50, "claretine" = 20, "electrum" = 10)

/obj/item/shipcomponent/mainweapon/constructor
	name = "EFIF-1 Construction System"
	desc = "A pair of elaborate robotic arms equipped for large-scale construction and asteroid demolition."
	current_projectile = new/datum/projectile/laser/drill/cutter
	appearanceString = "pod_weapon_efif"
	icon_state = "constructor"
	firerate = 15
	var/mode = EFIF_MODE_REPAIR
	///Current loaded steel sheets (only accepts steel, as the system's metalforming is designed for it)
	var/obj/item/sheet/steel_sheets = null
	///Maximum allowable sheets loaded within tool
	var/max_sheets = 200
	///Secondary toggleable setting to increase build size (can be deactivated for fine work)
	var/wide_field = FALSE

	///Currently active construction fields
	var/list/active_fields = list()

	attack_self(var/mob/user)
		if(src.steel_sheets)
			user.put_in_hand_or_drop(steel_sheets)
			src.steel_sheets = null
			boutput(user,SPAN_NOTICE("You eject the steel sheets stored in [src]."))
			playsound(src, 'sound/items/Deconstruct.ogg', 40, TRUE)
			return
		..()

	attackby(obj/item/W, mob/user)
		var/outcome
		if (W?.cant_drop)
			boutput(user, SPAN_ALERT("You can't put that in [src] when it's attached to you!"))
			return ..()
		else
			outcome = sheet_load_helper(W, user)
			if (outcome & LOAD_SUCCESS)
				boutput(user, SPAN_NOTICE("You load [W] into [src]."))
				playsound(src, 'sound/items/Deconstruct.ogg', 40, TRUE)
			if (outcome & LOAD_FULL)
				boutput(user, SPAN_NOTICE("[src] is[outcome & LOAD_SUCCESS ? " now" : null] fully loaded."))
			if (outcome < 1)
				boutput(user, SPAN_ALERT("[src] only accepts unreinforced steel sheets!"))
				. = ..()

	//Stopgap discoverability feature, pending pod UI improvement
	activate()
		. = ..()
		if(ship?.pilot)
			src.opencomputer(ship.pilot)

	Fire(var/mob/user,var/shot_dir_override = -1)
		switch(mode)

			if(EFIF_MODE_FLOORS to EFIF_MODE_WALLS)
				if(ON_COOLDOWN(src, "fire", firerate))
					return
				EXTEND_COOLDOWN(src, "weapon_swap_cd", 10 SECONDS)
				if(length(src.active_fields) >= 1)
					return
				if(!src.check_sheets())
					boutput(user,SPAN_ALERT("The construction system is out of metal sheets and requires reloading."))
					src.sadbuzz()
					return

				if(ship.bound_height == 64)
					src.do_construct(mode,TRUE)
				else
					src.do_construct(mode,FALSE)

				playsound(src.loc, 'sound/machines/constructor_work.ogg', 30, 1)
				// Necessary when not calling base fire proc
				logTheThing(LOG_COMBAT, user, "driving [ship.name] fires [src.name], attempting to construct [mode == EFIF_MODE_WALLS ? "walls" : "floors"] at [log_loc(ship)].")

			if(EFIF_MODE_REPAIR)
				if(ON_COOLDOWN(src, "fire", firerate))
					return
				EXTEND_COOLDOWN(src, "weapon_swap_cd", 10 SECONDS)
				if(length(src.active_fields) >= 1)
					return

				if(ship.bound_height == 64)
					src.do_repair(TRUE,user)
				else
					src.do_repair(FALSE,user)

				// Necessary when not calling base fire proc
				logTheThing(LOG_COMBAT, user, "driving [ship.name] fires [src.name], attempting to repair an area at [log_loc(ship)].")

			else
				..()

	proc/sadbuzz()
		for (var/mob/M in ship)
			M.playsound_local(ship, 'sound/machines/buzz-two.ogg', 5, TRUE, ignore_flag = SOUND_IGNORE_SPACE)

	///Helper proc that checks if enough sheets are available for building given current build mode and ship size
	proc/check_sheets(var/mode_specify)
		if(!mode_specify)
			mode_specify = mode
		. = FALSE
		var/sizemult = 1
		if(ship.bound_height == 64)
			sizemult = 2
		if(src.wide_field)
			sizemult += 2
		if(!src.steel_sheets)
			return
		if(mode_specify == EFIF_MODE_FLOORS && src.steel_sheets.amount >= EFIF_FLOOR_COST * sizemult)
			return TRUE
		else if(mode_specify == EFIF_MODE_R_FLOORS && src.steel_sheets.amount >= EFIF_R_FLOOR_COST * sizemult)
			return TRUE
		else if(mode_specify == EFIF_MODE_WALLS && src.steel_sheets.amount >= EFIF_WALL_COST * sizemult)
			return TRUE

	///Ship arms' proc to find and attempt loading of sheets on the ground
	proc/scoop_up_sheets()
		var/turf/load_from
		var/turf/also_load_from
		var/loaded_stuff
		if(ship.bound_height == 64) //always load at the front side of the pod, left offset
			switch(ship.dir)
				if(NORTH)
					load_from = locate(ship.x,ship.y+2,ship.z)
					also_load_from = locate(ship.x+1,ship.y+2,ship.z)
				if(EAST)
					load_from = locate(ship.x+2,ship.y+1,ship.z)
					also_load_from = locate(ship.x+2,ship.y+2,ship.z)
				if(SOUTH)
					load_from = locate(ship.x+1,ship.y-1,ship.z)
					also_load_from = locate(ship.x+2,ship.y-1,ship.z)
				if(WEST)
					load_from = locate(ship.x-1,ship.y,ship.z)
					also_load_from = locate(ship.x-1,ship.y+1,ship.z)
		else
			load_from = get_step(ship,ship.dir)
		if(!load_from)
			return
		for (var/obj/O in load_from)
			if(src.sheet_load_helper(O) >= LOAD_SUCCESS)
				loaded_stuff = TRUE
		if(also_load_from && src.steel_sheets?.amount < src.max_sheets)
			for (var/obj/O in also_load_from)
				if(src.sheet_load_helper(O) >= LOAD_SUCCESS)
					loaded_stuff = TRUE
					if(src.steel_sheets.amount >= src.max_sheets)
						break
		if(loaded_stuff)
			for (var/mob/M in ship)
				M.playsound_local(ship, 'sound/machines/chime.ogg', 5, TRUE, ignore_flag = SOUND_IGNORE_SPACE)
			ship.visible_message("<b>[ship]</b> loads metal sheets into its tool.")

	///Sheet-loading proc for both automatic and manual loading. Set up for flag-based return, for responsive player messaging.
	///Returns FALSE if provided object is unsuitable, LOAD_FULL (1) if storage is full, and/or LOAD_SUCCESS (2) if sheets were loaded.
	proc/sheet_load_helper(var/obj/item/I,var/mob/user)
		. = FALSE
		if(!istype(I))
			return

		///How many sheets we had before attempting to load more
		var/sheets_before = 0

		//This is out here because
		var/obj/item/sheet/S = I
		if(!S.material || !(S.material.getID() == "steel") || S.reinforcement)
			return

		if(!src.steel_sheets)
			if(user) user.u_equip(S)
			I.set_loc(src)
			src.steel_sheets = S
		else
			sheets_before = src.steel_sheets.amount
			src.steel_sheets.stack_item(S)

		if(src.steel_sheets.amount > sheets_before)
			. |= LOAD_SUCCESS
		if(src.steel_sheets.amount >= src.max_sheets)
			. |= LOAD_FULL

	///Selects locations for construction operation and initiates action bar
	proc/do_construct(var/bldmode, var/large_pod)
		var/list/build_locations = list()

		//oh lordy
		if(large_pod)
			switch(ship.dir)
				if(NORTH)
					build_locations += locate(ship.x,ship.y+2,ship.z)
					build_locations += locate(ship.x+1,ship.y+2,ship.z)
					if(src.wide_field)
						build_locations += locate(ship.x-1,ship.y+2,ship.z)
						build_locations += locate(ship.x+2,ship.y+2,ship.z)
				if(EAST)
					build_locations += locate(ship.x+2,ship.y,ship.z)
					build_locations += locate(ship.x+2,ship.y+1,ship.z)
					if(src.wide_field)
						build_locations += locate(ship.x+2,ship.y-1,ship.z)
						build_locations += locate(ship.x+2,ship.y+2,ship.z)
				if(SOUTH)
					build_locations += locate(ship.x,ship.y-1,ship.z)
					build_locations += locate(ship.x+1,ship.y-1,ship.z)
					if(src.wide_field)
						build_locations += locate(ship.x-1,ship.y-1,ship.z)
						build_locations += locate(ship.x+2,ship.y-1,ship.z)
				if(WEST)
					build_locations += locate(ship.x-1,ship.y,ship.z)
					build_locations += locate(ship.x-1,ship.y+1,ship.z)
					if(src.wide_field)
						build_locations += locate(ship.x-1,ship.y-1,ship.z)
						build_locations += locate(ship.x-1,ship.y+2,ship.z)
		else
			build_locations += get_step(ship,ship.dir)
			if(src.wide_field)
				switch(ship.dir)
					if(NORTH)
						build_locations += locate(ship.x+1,ship.y+1,ship.z)
						build_locations += locate(ship.x-1,ship.y+1,ship.z)
					if(EAST)
						build_locations += locate(ship.x+1,ship.y+1,ship.z)
						build_locations += locate(ship.x+1,ship.y-1,ship.z)
					if(SOUTH)
						build_locations += locate(ship.x-1,ship.y-1,ship.z)
						build_locations += locate(ship.x+1,ship.y-1,ship.z)
					if(WEST)
						build_locations += locate(ship.x-1,ship.y-1,ship.z)
						build_locations += locate(ship.x-1,ship.y+1,ship.z)

		if(!length(build_locations))
			return

		for(var/turf/T in build_locations)
			if(build_mode_eval(T))
				var/obj/overlay/construction_field/newfield = new /obj/overlay/construction_field(T)
				newfield.to_build = bldmode
				src.active_fields += newfield
		actions.start(new /datum/action/bar/construction_field(src.ship,src,src.mode),src.ship)

	///Selects locations for construction operation and initiates action bar. Needs construction recall on turf or area to work
	proc/do_repair(var/large_pod,var/mob/user)
		var/list/build_locations = list()
		var/turf/turfA
		var/turf/turfB

		//much easier
		if(large_pod)
			switch(ship.dir)
				if(NORTH)
					turfA = locate(ship.x,ship.y+2,ship.z)
					turfB = locate(ship.x+1,ship.y+2,ship.z)
				if(EAST)
					turfA = locate(ship.x+2,ship.y,ship.z)
					turfB = locate(ship.x+2,ship.y+1,ship.z)
				if(SOUTH)
					turfA = locate(ship.x,ship.y-1,ship.z)
					turfB = locate(ship.x+1,ship.y-1,ship.z)
				if(WEST)
					turfA = locate(ship.x-1,ship.y,ship.z)
					turfB = locate(ship.x-1,ship.y+1,ship.z)
		else
			turfA = get_step(ship,ship.dir)

		build_locations += turfA
		if(turfB)
			build_locations += turfB
		if(src.wide_field)
			build_locations += get_step(turfA,ship.dir)
			if(turfB)
				build_locations += get_step(turfB,ship.dir)

		if(!length(build_locations))
			return

		var/cost_estimate = 0

		for(var/turf/T in build_locations) //once
			if(T.type != T.path_old && build_mode_eval(T))
				var/mode_instruction //cost calculation, and restricting which paths can be repaired to
				if(ispath(T.path_old,/turf/simulated/floor/engine) || ispath(T.path_old,/turf/simulated/floor/shuttlebay))
					mode_instruction = EFIF_MODE_R_FLOORS
				else if(ispath(T.path_old,/turf/simulated/floor) && !ispath(T.path_old,/turf/simulated/floor/plating/airless/asteroid))
					mode_instruction = EFIF_MODE_FLOORS
				else if(ispath(T.path_old,/turf/simulated/wall/auto) && !ispath(T.path_old,/turf/simulated/wall/auto/asteroid))
					mode_instruction = EFIF_MODE_WALLS
				else
					continue
				var/obj/overlay/construction_field/newfield = new /obj/overlay/construction_field(T)
				newfield.to_build = mode_instruction
				newfield.repair_mode = TRUE
				cost_estimate += get_cost_mod(newfield)
				src.active_fields += newfield

		if(!length(active_fields))
			boutput(user,SPAN_ALERT("The construction system can't find any repair data for this location."))
			for (var/mob/M in ship)
				M.playsound_local(ship, 'sound/machines/click.ogg', 8, TRUE, ignore_flag = SOUND_IGNORE_SPACE)
			return

		if(src.steel_sheets?.amount < cost_estimate)
			for(var/obj/O in src.active_fields)
				qdel(O)
			src.active_fields = list()
			boutput(user,SPAN_ALERT("The construction system has inadequate metal sheets for the targeted repair."))
			src.sadbuzz()
			return

		playsound(src.loc, 'sound/machines/constructor_work.ogg', 30, 1)
		actions.start(new /datum/action/bar/construction_field(src.ship,src,src.mode),src.ship)

	///Helper proc to get an individual construction field's cost (used by action bar as well)
	proc/get_cost_mod(var/obj/overlay/construction_field/F)
		switch(F.to_build)
			if(EFIF_MODE_FLOORS)
				return EFIF_FLOOR_COST
			if(EFIF_MODE_R_FLOORS)
				return EFIF_R_FLOOR_COST
			if(EFIF_MODE_WALLS)
				return EFIF_WALL_COST

	///Helper proc to determine suitability of current tile for construction field application
	proc/build_mode_eval(var/turf/T)
		. = FALSE
		//floors can be freshly constructed on other floors if they're bare (less fussy if repairing)
		if (mode == EFIF_MODE_FLOORS || mode == EFIF_MODE_R_FLOORS)
			if(!T.intact)
				return TRUE
		//walls can be built on most floors. avoid some types that are unsuitable
		if (mode == EFIF_MODE_WALLS || mode == EFIF_MODE_REPAIR)
			if(istype(T,/turf/simulated/floor) && !istype(T,/turf/simulated/floor/airbridge) && !istype(T,/turf/simulated/floor/shuttle)\
				&& !istype(T,/turf/simulated/floor/setpieces) && !istype(T,/turf/simulated/floor/martian) && !istype(T,/turf/simulated/floor/feather))
				return TRUE
		//fallback: space is good
		if (istype(T,/turf/space))
			return TRUE

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		src.add_dialog(user)

		var/dat = "<TT><B>Weapon Console</B><BR><HR>"
		if(src.active)
			dat +="<B>Weapon Mode:</B><BR>"
			switch(mode)
				if(EFIF_MODE_FLOORS)
					dat+="<B>Floors</B><BR>"
					dat+="<A href='?src=\ref[src];r_floors=1'>Switch to Reinforced Floors</A><BR>"
					dat+="<A href='?src=\ref[src];walls=1'>Switch to Walls</A><BR>"
					dat+="<A href='?src=\ref[src];repair=1'>Switch to Repair</A><BR>"
					dat+="<A href='?src=\ref[src];cutter=1'>Switch to Drilling</A><BR>"
				if(EFIF_MODE_R_FLOORS)
					dat+="<A href='?src=\ref[src];floors=1'>Switch to Floors</A><BR>"
					dat+="<B>Reinforced Floors</B><BR>"
					dat+="<A href='?src=\ref[src];walls=1'>Switch to Walls</A><BR>"
					dat+="<A href='?src=\ref[src];repair=1'>Switch to Repair</A><BR>"
					dat+="<A href='?src=\ref[src];cutter=1'>Switch to Drilling</A><BR>"
				if(EFIF_MODE_WALLS)
					dat+="<A href='?src=\ref[src];floors=1'>Switch to Floors</A><BR>"
					dat+="<A href='?src=\ref[src];r_floors=1'>Switch to Reinforced Floors</A><BR>"
					dat+="<B>Walls</B><BR>"
					dat+="<A href='?src=\ref[src];repair=1'>Switch to Repair</A><BR>"
					dat+="<A href='?src=\ref[src];cutter=1'>Switch to Drilling</A><BR>"
				if(EFIF_MODE_REPAIR)
					dat+="<A href='?src=\ref[src];floors=1'>Switch to Floors</A><BR>"
					dat+="<A href='?src=\ref[src];r_floors=1'>Switch to Reinforced Floors</A><BR>"
					dat+="<A href='?src=\ref[src];walls=1'>Switch to Walls</A><BR>"
					dat+="<B>Repair</B><BR>"
					dat+="<A href='?src=\ref[src];cutter=1'>Switch to Drilling</A><BR>"
				else
					dat+="<A href='?src=\ref[src];floors=1'>Switch to Floors</A><BR>"
					dat+="<A href='?src=\ref[src];r_floors=1'>Switch to Reinforced Floors</A><BR>"
					dat+="<A href='?src=\ref[src];walls=1'>Switch to Walls</A><BR>"
					dat+="<A href='?src=\ref[src];repair=1'>Switch to Repair</A><BR>"
					dat+="<B>Drilling</B><BR>"
			dat+="<BR>"
			dat+="Wide Field Mode <B>[src.wide_field ? "Active" : "Inactive"]</B> <A href='?src=\ref[src];wide_field=1'>(Toggle)</A><BR>"
			dat+="[src.steel_sheets?.amount] of [src.max_sheets] Steel Sheets Loaded <A href='?src=\ref[src];load=1'>(Load)</A><BR>"

		else
			dat += {"<B><span style=\"color:red\">SYSTEM OFFLINE</span></B>"}
		user.Browse(dat, "window=ship_main_weapon")
		onclose(user, "ship_main_weapon")
		return

	Topic(href, href_list)
		if(..())
			return

		if (href_list["floors"])
			mode = EFIF_MODE_FLOORS
			firerate = 15

		else if (href_list["r_floors"])
			mode = EFIF_MODE_R_FLOORS
			firerate = 25

		else if (href_list["walls"])
			mode = EFIF_MODE_WALLS
			firerate = 35

		else if (href_list["repair"])
			mode = EFIF_MODE_REPAIR
			firerate = 15

		else if(href_list["cutter"])
			mode = EFIF_MODE_DRILL
			firerate = 15

		else if(href_list["wide_field"])
			wide_field = !wide_field

		else if(href_list["load"])
			src.scoop_up_sheets()

		opencomputer(usr)
		return

/obj/overlay/construction_field
	name = "energy"
	icon = 'icons/obj/objects.dmi'
	icon_state = "buildeffect"
	layer = EFFECTS_LAYER_BASE
	///Tracks the build type of what each field is building for cost calculation and placement logic
	var/to_build
	///If in repair mode, build the precise initial turf
	var/repair_mode = FALSE

/datum/action/bar/construction_field
	var/obj/machinery/vehicle/pod
	var/obj/item/shipcomponent/mainweapon/constructor/buildtool
	var/mode
	///Sum of current attempted construction's cost in sheets
	var/action_build_cost = 0
	duration = 1 SECONDS

	New(var/obj/thepod,var/obj/thetool,var/passmode)
		src.pod = thepod
		if(pod.bound_height == 64)
			src.bar_x_offset += 16
			src.bar_y_offset += 16
		src.buildtool = thetool
		src.mode = passmode
		for (var/obj/overlay/construction_field/F in buildtool.active_fields)
			src.duration += src.get_duration_mod(F)
			src.action_build_cost += buildtool.get_cost_mod(F)
		..()

	proc/get_duration_mod(var/obj/overlay/construction_field/F)
		switch(F.to_build)
			if(EFIF_MODE_FLOORS)
				return EFIF_FLOOR_BUILD_TIME
			if(EFIF_MODE_R_FLOORS)
				return EFIF_R_FLOOR_BUILD_TIME
			if(EFIF_MODE_WALLS)
				var/space_adjustment = EFIF_WALL_BUILD_TIME
				if(istype(get_turf(F),/turf/space))
					space_adjustment += EFIF_FLOOR_BUILD_TIME
				return space_adjustment

	///Check whether dense objects are present in wall build fields; interrupt any fields which have been blocked
	proc/dense_object_refresh()
		. = FALSE
		for (var/obj/overlay/construction_field/field in buildtool.active_fields)
			if (field.to_build != EFIF_MODE_WALLS) //If we're not building walls, interruptions are alright
				continue
			for (var/obj/O in get_turf(field))
				if (O.density && !(istype(O, /obj/structure/girder)))
					src.action_build_cost -= buildtool.get_cost_mod(field)
					buildtool.active_fields -= field
					qdel(field)
					break

	onStart()
		..()

		if (buildtool.steel_sheets?.amount < action_build_cost)
			interrupt(INTERRUPT_ALWAYS)
			return

		src.dense_object_refresh()

		if (!length(buildtool.active_fields))
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt(var/flag)
		for(var/atom/field in buildtool.active_fields)
			qdel(field)
		buildtool.active_fields = list()
		..()

	onDelete()
		for(var/atom/field in buildtool.active_fields)
			qdel(field)
		buildtool.active_fields = list()
		..()

	onEnd()
		..()
		src.dense_object_refresh()
		if (buildtool.steel_sheets?.amount < action_build_cost || !length(buildtool.active_fields))
			interrupt(INTERRUPT_ALWAYS)
			return
		///Plural management for log formatting
		var/multy = FALSE
		if (length(buildtool.active_fields) > 1)
			multy = TRUE
		if(duration > 2 SECONDS)
			playsound(owner, 'sound/machines/constructor_work.ogg', 30, 1)

		///Flag set for log reporting; 1 is floors, 2 is walls
		var/build_types = 0

		for (var/obj/overlay/construction_field/field in buildtool.active_fields)
			var/turf/T = get_turf(field)
			var/turf/built
			if(field.repair_mode == FALSE)
				switch(field.to_build)
					if(EFIF_MODE_FLOORS)
						build_types |= 1
						built = T.ReplaceWithFloor()
					if(EFIF_MODE_R_FLOORS)
						build_types |= 1
						built = T.ReplaceWithEngineFloor()
					if(EFIF_MODE_WALLS)
						build_types |= 2
						for (var/obj/O in T) //tidy up girders and lattices
							if (istype(O, /obj/structure/girder) || istype(O,/obj/lattice))
								qdel(O)
						built = T.ReplaceWithWall()
				if(built)
					built.inherit_area()
			else
				switch(field.to_build)
					if(EFIF_MODE_FLOORS)
						build_types |= 1
					if(EFIF_MODE_R_FLOORS)
						build_types |= 1
					if(EFIF_MODE_WALLS)
						build_types |= 2
						for (var/obj/O in T) //tidy up girders and lattices
							if (istype(O, /obj/structure/girder) || istype(O,/obj/lattice))
								qdel(O)
				if(ispath(T.path_old,/turf/simulated/floor) || ispath(T.path_old,/turf/simulated/wall))
					T.ReplaceWithInitial()
			qdel(field)

		var/what_we_built
		switch(build_types)
			if(1)
				if(multy)
					what_we_built = "floors"
				else
					what_we_built = "a floor"
			if(2)
				if(multy)
					what_we_built = "walls"
				else
					what_we_built = "a wall"
			if(3) //implicitly multiple
				what_we_built = "floors and walls"

		logTheThing(LOG_STATION, owner, "[mode == EFIF_MODE_REPAIR ? "repairs" : "constructs"] [what_we_built] with a pod at [log_loc(owner)].")
		buildtool.steel_sheets.change_stack_amount(-(action_build_cost))

/obj/item/shipcomponent/mainweapon/constructor/stocked
	New()
		. = ..()
		src.steel_sheets = new /obj/item/sheet/steel(src)
		src.steel_sheets.set_stack_amount(200)

#undef EFIF_MODE_DRILL
#undef EFIF_MODE_FLOORS
#undef EFIF_MODE_R_FLOORS
#undef EFIF_MODE_WALLS
#undef EFIF_MODE_REPAIR

#undef EFIF_FLOOR_BUILD_TIME
#undef EFIF_R_FLOOR_BUILD_TIME
#undef EFIF_WALL_BUILD_TIME

#undef EFIF_FLOOR_COST
#undef EFIF_R_FLOOR_COST
#undef EFIF_WALL_COST

#undef LOAD_FULL
#undef LOAD_SUCCESS


/obj/item/shipcomponent/mainweapon/syndicate_purge_system
	name = "Syndicate Purge System"
	desc = "An unfinished pod weapon, the blueprints for which have been plundered from a raid on a now-destroyed Syndicate base. Requires a unique power source to function."
	current_projectile = new/datum/projectile/laser/drill/cutter
	firerate = 100
	var/increment
	var/pod_is_large = FALSE
	var/core_inserted = FALSE
	icon = 'icons/misc/retribution/SWORD_loot.dmi'
	icon_state= "SPS_empty"

	Fire(var/mob/user,var/shot_dir_override = -1)
		if(ON_COOLDOWN(src, "fire", firerate))
			return
		EXTEND_COOLDOWN(src, "weapon_swap_cd", 10 SECONDS)
		if(!core_inserted)
			boutput(ship.pilot, SPAN_ALERT("<B>The weapon requires a unique power source to function!</B>"))
			return
		playsound(src.loc, 'sound/weapons/heavyioncharge.ogg', 75, 1)
		logTheThing(LOG_COMBAT, user, "driving [ship.name] fires [src.name] from [log_loc(ship)].")
		var/obj/overlay/purge = new/obj/overlay{mouse_opacity=FALSE; icon='icons/misc/retribution/320x320.dmi'; plane=PLANE_SELFILLUM; appearance_flags=RESET_TRANSFORM}
		purge.dir = ship.facing
		if(!is_cardinal(purge.dir))
			if(prob(50))
				purge.dir &= NORTH | SOUTH
			else
				purge.dir &= EAST | WEST
		ship.vis_contents += purge
		if(ship.capacity != 1 && !istype(/obj/machinery/vehicle/miniputt, ship) && !istype(/obj/machinery/vehicle/recon, ship) && !istype(/obj/machinery/vehicle/cargo, ship))
			pod_is_large = TRUE
			FLICK("SPS_o_large", purge)
			purge.pixel_x -= 128
			purge.pixel_y -= 128
		else
			pod_is_large = FALSE
			FLICK("SPS_o_small", purge)
			purge.pixel_x -= 144
			purge.pixel_y -= 144

		SPAWN(1.2 SECONDS)
			var/destruction_point_x
			var/destruction_point_y
			ship.vis_contents -= purge
			playsound(ship.loc, 'sound/weapons/laserultra.ogg', 100, 1)
			switch (purge.dir)
				if (NORTH)
					for (increment in 1 to 4)
						destruction_point_x = ship.loc.x
						destruction_point_y = ship.loc.y + increment
						if(pod_is_large)
							destruction_point_y++
							purge_sps(destruction_point_x, destruction_point_y)
							destruction_point_x = ship.loc.x + 1
						purge_sps(destruction_point_x, destruction_point_y)

				if (EAST)
					for(increment in 1 to 4)
						destruction_point_x = ship.loc.x + increment
						destruction_point_y = ship.loc.y
						if(pod_is_large)
							destruction_point_x++
							purge_sps(destruction_point_x, destruction_point_y)
							destruction_point_y = ship.loc.y + 1
						purge_sps(destruction_point_x, destruction_point_y)

				if (SOUTH)
					for (increment in 1 to 4)
						destruction_point_x = ship.loc.x
						destruction_point_y = ship.loc.y - increment
						if(pod_is_large)
							purge_sps(destruction_point_x, destruction_point_y)
							destruction_point_x = ship.loc.x + 1
						purge_sps(destruction_point_x, destruction_point_y)

				if (WEST)
					for (increment in 1 to 4)
						destruction_point_x = ship.loc.x - increment
						destruction_point_y = ship.loc.y
						if(pod_is_large)
							purge_sps(destruction_point_x, destruction_point_y)
							destruction_point_y = ship.loc.y + 1
						purge_sps(destruction_point_x, destruction_point_y)
			return
		return

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W) && core_inserted)
			core_inserted = FALSE
			set_icon_state("SPS_empty")
			user.put_in_hand_or_drop(new /obj/item/sword_core)
			user.show_message(SPAN_NOTICE("You remove the SWORD core from the Syndicate Purge System!"), 1)
			desc = "After a delay, fires a destructive beam capable of penetrating walls. The core is missing."
			tooltip_rebuild = 1
			return
		else if ((istype(W,/obj/item/sword_core) && !core_inserted))
			core_inserted = TRUE
			qdel(W)
			set_icon_state("SPS")
			user.show_message(SPAN_NOTICE("You insert the SWORD core into the Syndicate Purge System!"), 1)
			desc = "After a delay, fires a destructive beam capable of penetrating walls. The core is installed."
			tooltip_rebuild = 1
			return

	proc/purge_sps(var/point_x, var/point_y)
		for (var/mob/M in locate(point_x,point_y,ship.loc.z))
			random_burn_damage(M, 60)
			M.changeStatus("knockdown", 2 SECOND)
			INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, emote), "scream")
			playsound(M.loc, 'sound/impact_sounds/burn_sizzle.ogg', 70, 1)
		var/turf/simulated/T = locate(point_x,point_y,ship.loc.z)
		if(T && prob(100 - (10 * increment)))
			T.ex_act(1)
		for (var/obj/S in locate(point_x,point_y,ship.loc.z))
			if(prob(50 - (10 * increment)))
				S.ex_act(1)
		return

/datum/projectile/laser/pod
	dissipation_rate = 2
	dissipation_delay = 16
	projectile_speed = 42

/datum/projectile/laser/light/pod
	impact_range = 2
	dissipation_rate = 1
	dissipation_delay = 14
	projectile_speed = 42

/datum/projectile/laser/light/pod/burst
	damage = 25
	shot_delay = 0.2 SECONDS

/datum/projectile/laser/light/pod/support_gunner
	damage = 5

/datum/projectile/disruptor
	impact_range = 4
	dissipation_delay = 16
	projectile_speed = 42

/datum/projectile/disruptor/high
	impact_range = 4
	dissipation_delay = 16
	projectile_speed = 42
