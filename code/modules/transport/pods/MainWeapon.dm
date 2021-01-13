/obj/item/shipcomponent/mainweapon
	name = "Class-A Light Phaser"
	desc = "A simple phaser designed for scout vehicles."
	var/r_gunner = 0
	var/mob/gunner = null
	var/datum/projectile/current_projectile = new/datum/projectile/laser/light/pod
	var/firerate = 8
	var/isfiring = 0
	var/weapon_score = 0.1
	var/appearanceString

	var/uses_ammunition = 0
	var/remaining_ammunition = 0
	var/muzzle_flash = null


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


/obj/item/shipcomponent/mainweapon/proc/Fire(var/mob/user,var/shot_dir_override = -1)
	if(isfiring) return
	isfiring = 1
	if(uses_ammunition)
		if (remaining_ammunition < ship.AmmoPerShot())
			boutput(usr, "[ship.ship_message("You need [ship.AmmoPerShot()] to fire the weapon. You currently have [remaining_ammunition] loaded.")]")
			isfiring  = 0
			return

	var/rdir = ship.dir
	if (shot_dir_override > 1)
		rdir = shot_dir_override
	//if (!istype(ship,/obj/machinery/vehicle/tank)) //Tanks are allowed to shoot diagonally!
	//	if ((rdir - 1) & rdir)
	//		rdir &= 12
	logTheThing("combat", usr, null, "driving [ship.name] fires [src.name] (<b>Dir:</b> <i>[dir2text(rdir)]</i>, <b>Projectile:</b> <i>[src.current_projectile]</i>) at [log_loc(ship)].") // Similar to handguns, but without target coordinates (Convair880).
	ship.ShootProjectiles(user, current_projectile, rdir)
	remaining_ammunition -= ship.AmmoPerShot()
	SPAWN_DBG (firerate)
		isfiring = 0

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
	power_used = 130
	weapon_score = 0.7
	current_projectile = new/datum/projectile/laser/mining
	appearanceString = "pod_weapon_cutter_on"
	firerate = 12
	icon_state = "plasma-cutter"

/obj/item/shipcomponent/mainweapon/bad_mining
	name = "Mining Phaser System"
	desc = "A weak, short-range phaser that can cut through solid rock. Weak damage, but more effective against critters."
	power_used = 1
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

/obj/item/shipcomponent/mainweapon/laser
	name = "Mk.2 Scout Laser"
	desc = "An upgraded variant of the stock MK 1.5 phaser. Due to the concentration of energy, a higher quality engine might be neccesary."
	weapon_score = 0.4
	appearanceString = "pod_weapon_laser"
	power_used = 100
	current_projectile = new/datum/projectile/laser
	icon_state = "mk-2-scout"
	muzzle_flash = "muzzle_flash_laser"

/obj/item/shipcomponent/mainweapon/russian
	name = "Svet-Oruzhiye Mk.4"
	weapon_score = 0.6
	current_projectile = new/datum/projectile/laser/glitter
	firerate = 5
	icon_state = "strelka"
	muzzle_flash = "muzzle_flash_laser"

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
	current_projectile = new/datum/projectile/bullet/a12/weak
	appearanceString = "pod_weapon_gun_off"
	firerate = 10
	icon_state = "spes"
	muzzle_flash = "muzzle_flash"

/obj/item/shipcomponent/mainweapon/laser_ass // hehhh
	name = "Mk.4 Assault Laser"
	weapon_score = 1.25
	power_used = 350
	firerate = 35
	appearanceString = "pod_weapon_emitter"
	current_projectile = new/datum/projectile/laser/asslaser
	icon_state = "assult-laser"
	muzzle_flash = "muzzle_flash_laser"

/obj/item/shipcomponent/mainweapon/rockdrills
	name = "Rock Drilling Rig"
	desc = "A strudy drill designed for chewing up asteroids like nobodies business."
	power_used = 100
	weapon_score = 1.0
	current_projectile = new/datum/projectile/laser/drill
	appearanceString = "pod_weapon_drills"
	firerate = 5
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

		if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
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
				if(isfiring) return
				isfiring = 1
				var/obj/decal/D = new/obj/decal(ship.loc)
				D.set_dir(ship.dir)
				if (shot_dir_override > 1)
					D.set_dir(shot_dir_override)

				D.name = "metal foam spray"
				D.icon = 'icons/obj/chemical.dmi'
				D.icon_state = "chempuff"
				D.layer = EFFECTS_LAYER_BASE

				playsound(src.loc, "sound/machines/mixer.ogg", 50, 1)

				// Necessary, as the foamer doesn't use the global fire proc (Convair880).
				logTheThing("combat", usr, null, "driving [ship.name] fires [src.name], creating metal foam at [log_loc(ship)].")

				SPAWN_DBG(0)
					step_towards(D, get_step(D, D.dir))
					var/location = get_turf(D)
					for(var/mob/M in AIviewers(5, location))
						boutput(M, "<span class='alert'>[ship] spews out a metalic foam!</span>")
					var/list/bandaidfix = list("iron" = 3, "fluorosurfactant" = 1, "acid" = 1)
					var/datum/effects/system/foam_spread/s = new()
					s.set_up(5, location, bandaidfix, 1) // Aborts if reagent list is null (even for metal foam), but I'm not gonna touch foam_spread.dm (Convair880).
					s.start()
					sleep(0.3 SECONDS)
					D.dispose()

				SPAWN_DBG(firerate)
					isfiring = 0
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

		if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
			src.add_dialog(usr)

		if (href_list["foam"])
			mode = 0
			firerate = 60

		else if(href_list["cutter"])
			mode = 1
			firerate = 15

		opencomputer(usr)
		return


/datum/projectile/laser/pod
	dissipation_rate = 2
	dissipation_delay = 16
	projectile_speed = 32

/datum/projectile/laser/light/pod
	impact_range = 2
	dissipation_rate = 1
	dissipation_delay = 14
	projectile_speed = 32

/datum/projectile/disruptor
	impact_range = 4
	dissipation_delay = 16
	projectile_speed = 32

/datum/projectile/disruptor/high
	impact_range = 4
	dissipation_delay = 16
	projectile_speed = 32
