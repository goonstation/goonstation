/obj/machinery/cruiser/syndicate
	name = "Experimental BX-1 Cruiser"
	desc = "An experimental type of syndicate cruiser based on drone technology."
	interior_area = /area/cruiser/syndicate
	upper_area = /area/cruiser/syndicate/upper
	prefab_type = /datum/mapPrefab/allocated/cruiser_syndicate

/obj/machinery/cruiser/nanotrasen
	name = "Experimental BX-2 Cruiser"
	desc = "An experimental type of syndicate cruiser based on drone technology."
	interior_area = /area/cruiser/nanotrasen
	upper_area = /area/cruiser/nanotrasen/upper
	prefab_type = /datum/mapPrefab/allocated/cruiser_nanotrasen

/obj/cruiser_shield_visual//This is dumb but required because icons and images don't animate properly as overlays AND their icon_state cannot be changed properly once added (images)
	name = ""
	desc = ""
	icon = 'icons/obj/large/160x160.dmi'
	icon_state = "shield"
	mouse_opacity = 0
	bound_width = 160
	bound_height = 160
	density = 0
	anchored = ANCHORED
	layer = 4

	bullet_act(var/obj/projectile/P)
		return

	ex_act(var/severity)
		return

/obj/machinery/cruiser
	icon = 'icons/obj/large/160x160.dmi'
	icon_state = "placeholder"
	name = "Experimental someone-didnt-give-me-a-name cruiser"
	desc = "Ruh-roh"
	bound_width = 160
	bound_height = 160
	density = 1
	anchored = ANCHORED
	dir = NORTH
	plane = PLANE_FLOOR
	var/obj/cruiser_shield_visual/shield_obj

	var/image/frames
	var/image/overframes
	var/image/bar_top
	var/image/bar_middle
	var/image/bar_bottom

	var/facing = 1
	var/flying = 0
	var/speed = 3
	var/stall = 0
	var/speed_mod = 0

	var/obj/item/shipcomponent/mainweapon/turret_left = null
	var/obj/item/shipcomponent/mainweapon/turret_right = null
	var/obj/item/shipcomponent/engine/engine = null
	var/obj/item/shipcomponent/life_support/life_support = null

	var/list/powerUse = list()

	var/power_used = 0
	var/power_used_last = 0
	var/power_produced_last = 300
	var/power_boost = 0 //Additional power per tick.

	var/power_movement = 100
	var/power_defense = 100
	var/power_offense = 100

	var/shields_regen = 30 //How much per process tick restored.
	var/shields_timer = 0  //How long since last damage taken.
	var/shields_delay = 75 //How long in 1/10s of seconds after damage was taken will shields begin to recharge?
	var/shields_recharge_cost = 20 //Cost per tick to recharge [shields_regen] per tick.
	var/shields = 600
	var/shields_max = 600
	var/shields_last = 0
	var/shield_regen_always = 0 //If true, shields will continually recharge. Damage wont stop regeneration.
	var/shield_regen_boost = 0  //Additional shield regen per tick.
	var/shield_modulation = 0 //If 1, shields will not be weak to energy weapons.

	//DO NOT MODIFY DIRECTLY
	var/health = 400
	var/health_last = 0
	var/health_max = 400
	//DO NOT MODIFY DIRECTLY

	var/weapon_cooldown_mod = 0 //Modifier for weapon cooldown
	var/firemode = CRUISER_FIREMODE_BOTH
	var/alt_weapon = 0

	var/ramming = 0 //How many ramming hits we have left.

	var/datum/mapPrefab/allocated/prefab_type = null
	var/datum/allocated_region/region
	var/area/cruiser/interior_area //interior area to use for this cruiser
	var/area/cruiser/upper_area // upper deck area
	var/obj/cruiser_camera_dummy/camera //used to control camera position

	var/list/crew = list()

	var/atmos_fail_count = 5 //counts down when life support is offline. once it his 0, life support fails.

	var/degradation = 0 //Slowly accumulates and makes new damage more severe.
	var/warping = 0

	var/list/pooList = list()
	var/list/interiorViewers = list()

	var/turf/entrance
	var/turf/center

	proc/internal_sound(var/atom/source, soundin, vol as num, vary, extrarange as num, pitch)
		playsound(source, soundin, vol, vary, extrarange, pitch)
		for(var/mob/M in crew)
			M.playsound_local(M, soundin, vol , vary, extrarange, pitch)
		return

	proc/subscribe_interior(var/mob/who)
		if(who in interiorViewers) return
		interiorViewers += who
		if(who.client)
			who.client.screen += pooList
	proc/unsubscribe_interior(var/mob/who)
		if(!(who in interiorViewers)) return
		interiorViewers -= who
		if(who.client)
			who.client.screen -= pooList

	proc/toggle_interior(var/mob/who)
		if(who in interiorViewers)
			unsubscribe_interior(who)
		else
			subscribe_interior(who)

	bullet_act(var/obj/projectile/P)
		if(P.shooter == src) return

		var/datum/projectile/PD = P.proj_data

		var/damage = PD.power * PD.ks_ratio
		damage = round(max(0, damage))

		var/ltlpoints = PD.power * (1 - PD.ks_ratio)
		ltlpoints = round(max(0, ltlpoints))

		if(shields)
			internal_sound(src.loc, 'sound/impact_sounds/Energy_Hit_2.ogg', 65, 1, 1)
			damageShields(damage, PD.damage_type)
		else
			internal_sound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 65, 1, 1)
			damageArmor(damage, PD.damage_type)
			shakeCruiser(3, 1, 0.2)

		return

	meteorhit(var/obj/O as obj)
		if(shields)
			internal_sound(src.loc, 'sound/impact_sounds/Energy_Hit_2.ogg', 65, 1, 1)
			damageShields(80, D_KINETIC)
			shakeCruiser(3, 1, 0.2)
		else
			internal_sound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 65, 1, 1)
			damageArmor(30, D_KINETIC)
			shakeCruiser(6, 2, 0.2)

	ex_act(var/severity)
		var/dmg_mult = 1
		switch(severity)
			if(1)
				dmg_mult = 2.5
			if(2)
				dmg_mult = 1.5
			if(3)
				dmg_mult = 1
			if(4 to INFINITY)
				dmg_mult = 0.75

		var/damage = round(40 * dmg_mult)

		if(shields)
			internal_sound(src.loc, 'sound/impact_sounds/Energy_Hit_2.ogg', 65, 1, 1)
			damageShields(damage, D_KINETIC)
			shakeCruiser(3, 1, 0.2)
		else
			internal_sound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 65, 1, 1)
			damageArmor(damage, D_KINETIC)
			shakeCruiser(6, 2, 0.2)

		if(length(src.interior_area.contents) && shields <= 0 && prob(75))
			var/atom/source = pick(src.interior_area.contents)
			explosion_new(source, source, clamp(4 - severity, 1, 3))
		return

	New()
		..()

		var/datum/mapPrefab/allocated/prefab = get_singleton(src.prefab_type)
		src.region = prefab.load()
		for(var/turf/T in REGION_TURFS(src.region))
			if(istype(T.loc, src.interior_area))
				src.interior_area = T.loc
				src.interior_area.ship = src
			else if(istype(T.loc, src.upper_area))
				src.upper_area = T.loc
				src.upper_area.ship = src

		if(!istype(interior_area))
			CRASH("No interior area found for cruiser")

		shield_obj = new(src.loc)
		var/matrix/mtx = new

		for(var/turf/T in landmarks[LANDMARK_CRUISER_CENTER])
			if(T.loc == upper_area)
				center = T
				break
		for(var/turf/T in landmarks[LANDMARK_CRUISER_ENTRANCE])
			if(T.loc == interior_area)
				entrance = T
				break

		for(var/turf/T in upper_area)
			var/obj/overlay/pooObj = new
			pooObj.mouse_opacity = FALSE
			pooObj.screen_loc = "CENTER,CENTER"
			mtx.Reset()
			mtx.Translate( (T.x - center.x) * world.icon_size, (T.y - center.y) * world.icon_size)
			pooObj.vis_contents = list(T)
			pooObj.transform = mtx
			pooList += pooObj

		frames = image('icons/obj/large/160x160.dmi',src,"frames",src.layer+1)
		overframes = image('icons/obj/large/160x160.dmi',src,"overframes",src.layer+2)
		bar_top = image('icons/obj/large/160x160.dmi',src,"bartop",src.layer+1)
		bar_middle = image('icons/obj/large/160x160.dmi',src,"barmiddle",src.layer+1)
		bar_bottom = image('icons/obj/large/160x160.dmi',src,"barbottom",src.layer+1)

		bar_top.color = "#8A1919"
		bar_middle.color = "#19688A"
		bar_bottom.color = "#CF9417"

		camera = new(locate(src.x + 2, src.y + 2, src.z))
		camera.name = src.name

		turret_left = new/obj/item/shipcomponent/mainweapon/light_longrange(src)
		turret_right = new/obj/item/shipcomponent/mainweapon/light_longrange(src)
		engine = new/obj/item/shipcomponent/engine/hermes(src)
		life_support = new/obj/item/shipcomponent/life_support(src)

		START_TRACKING_CAT(TR_CAT_PODS_AND_CRUISERS)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_PODS_AND_CRUISERS)

		qdel(src.shield_obj)
		src.shield_obj = null

		landmarks[LANDMARK_CRUISER_CENTER] -= src.center
		landmarks[LANDMARK_CRUISER_ENTRANCE] -= src.entrance

		for(var/obj/machinery/cruiser_destroyable/cruiser_pod/C in src.upper_area)
			for(var/mob/M in C)
				C.exitPod(M)
		src.region.move_movables_to(src.loc)
		for(var/mob/M in src.loc)
			unsubscribe_interior(M)
			M.set_eye(null)
		src.region.clean_up(/turf/space, /turf/space)

		qdel(src.region)

		qdel(camera)
		interior_area = null
		upper_area = null
		..()

	attack_hand(mob/user)
		return MouseDrop_T(user, user)

	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		enterShip(O, user)
		return

	Move(NewLoc,Dir=0,step_x=0,step_y=0)
		var/preserve_dir = src.dir
		. = ..(NewLoc,Dir,step_x,step_y)
		set_dir(preserve_dir)
		camera.set_loc(locate(src.x + 2, src.y + 2, src.z))
		shield_obj.set_loc(src.loc)
		return

	process()
		..()
		if(warping) return
		checkHealth()
		handlePowerCosts()
		updateIndicators()
		handleLifeSupport()
		return

	proc/handleLifeSupport()
		if(src.hasPower() && life_support)
			atmos_fail_count = min(atmos_fail_count+1, 5)
			for(var/turf/simulated/T in interior_area)
				if(T.density) continue
				if(T.air)
					T.air.temperature = life_support.tempreg
					T.oxygen = MOLES_O2STANDARD * 4
					T.nitrogen = MOLES_N2STANDARD * 4
		else
			if((atmos_fail_count - 1) == 2)
				internal_sound(src.loc, 'sound/machines/alarm_a.ogg', 80, 1, -1)
			if((atmos_fail_count - 1) == 0)
				internal_sound(src.loc, 'sound/machines/decompress.ogg', 100, 1, -1)

			atmos_fail_count = max(atmos_fail_count-1, 0)
			if(!atmos_fail_count)
				for(var/turf/simulated/T in interior_area)
					if(T.density) continue
					if(T.air) T.air.temperature = T0C - 100
					T.remove_air(100)


	proc/switchFireMode()
		switch(firemode)
			if(CRUISER_FIREMODE_BOTH)
				firemode = CRUISER_FIREMODE_ALT
				boutput(usr, SPAN_ALERT("Fire mode now: Alternate"))
			if(CRUISER_FIREMODE_ALT)
				firemode = CRUISER_FIREMODE_LEFT
				boutput(usr, SPAN_ALERT("Fire mode now: Left only"))
			if(CRUISER_FIREMODE_LEFT)
				firemode = CRUISER_FIREMODE_RIGHT
				boutput(usr, SPAN_ALERT("Fire mode now: Right only"))
			if(CRUISER_FIREMODE_RIGHT)
				firemode = CRUISER_FIREMODE_BOTH
				boutput(usr, SPAN_ALERT("Fire mode now: Simultaneous"))
		return

	bump(atom/O)
		..(O)
		if(ramming)
			ramming--
			O.meteorhit(src)
			if(istype(O, /atom/movable))
				if(!O:anchored)
					step(O,dir)
			internal_sound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 80, 1, -1)

			if(shields)
				damageShields(50, D_SPECIAL)
			else
				damageArmor(11, D_SPECIAL)
				shakeCruiser(3, 2, 0.3)

			if(!ramming)
				walk(src, 0)
				src.flying = 0

	proc/enableRamming()
		src.addPowerUse("rammingMode", 90, -1)
		internal_sound(src.loc, 'sound/machines/boost.ogg', 100, 1, -1)
		src.speed_mod -= 2
		src.ramming += 8
		SPAWN(10 SECONDS)
			src.speed_mod += 2
			src.removePowerUse("rammingMode")
			src.ramming = max(src.ramming - 8, 0)
			walk(src, 0)
			src.flying = 0
		return

	proc/overload_weapons()
		src.addPowerUse("weaponOverload", 90, -1)
		internal_sound(src.loc, 'sound/machines/weaponoverload.ogg', 80, 1, -1)
		src.weapon_cooldown_mod -= 3
		SPAWN(10 SECONDS)
			src.weapon_cooldown_mod += 3
			src.removePowerUse("weaponOverload")
		return

	proc/overload_shields()
		src.addPowerUse("shieldOverload", 90, -1)
		src.shield_regen_always += 1
		src.shield_regen_boost += 10
		var/image/I = image('icons/obj/large/160x160.dmi',shield_obj,"shieldoverload",shield_obj.layer+1)
		I.alpha = 150
		shield_obj.overlays += I
		internal_sound(src.loc, 'sound/machines/shieldoverload.ogg', 80, 0, -1)
		SPAWN(15 SECONDS)
			src.removePowerUse("shieldOverload")
			src.shield_regen_always -= 1
			src.shield_regen_boost -= 5
			shield_obj.overlays.Cut()
		return

	proc/toggleShieldModulation()
		shield_modulation = !shield_modulation
		internal_sound(src.loc, 'sound/machines/ArtifactAnc1.ogg', 65, 1, -1)

		if(shield_modulation)
			src.addPowerUse("shieldModulation", 90, -1)
			shield_obj.color = "#FF0000"
		else
			src.removePowerUse("shieldModulation")
			shield_obj.color = "#FFFFFF"
		return

	proc/addPowerUse(var/key, var/amount, var/rounds = -1)
		powerUse[key] = "[amount]=[rounds]"
		return

	proc/removePowerUse(var/key)
		if(powerUse[key]) powerUse.Remove(key)
		return

	proc/updatePower()
		if(engine)
			var/adjustment = 0
			adjustment += (1 - (power_movement / 100)) * engine.powergenerated
			adjustment += (1 - (power_offense / 100)) * engine.powergenerated
			adjustment += (1 - (power_defense / 100)) * engine.powergenerated

			power_produced_last = engine.powergenerated + adjustment
			power_used_last = power_used
			engine.power_used = power_used
			power_used = 0
		else
			power_produced_last = 0
		updateIndicators()
		return

	proc/handlePowerCosts()
		for(var/U in powerUse) //v FUCK BYOND. FUCK. DOUBLEFUCK. TRIPLEFUCK.
			var/params = powerUse[U]
			var/list/L = params2list(params)
			var/usage = text2num_safe(L[1])
			var/rounds = text2num_safe(L[L[1]])
			power_used += usage
			if(rounds > 0)
				if((--rounds) <= 0) removePowerUse(U)
				else powerUse[U] = "[usage]=[rounds]"

		if(src.engine)
			if(src.flying) addPowerUse("thrusters", 10, 1)

		if(turret_left)
			addPowerUse("turretLeft", round(turret_left.power_used / 2), 1)

		if(turret_right)
			addPowerUse("turretRight", round(turret_right.power_used / 2), 1)

		if(life_support)
			addPowerUse("lifeSupport", life_support.power_used, 1)

		if(src.hasPower() && src.shields < src.shields_max && ((world.time - src.shields_timer) >= src.shields_delay || src.shield_regen_always))
			addPowerUse("shieldRecharge", src.shields_recharge_cost, 1)
			src.adjustShields(src.shields_regen + shield_regen_boost)

		power_used = max(power_used, 0)

		src.updatePower()
		var/power_area = 1

		if(!src.hasPower())
			src.adjustShields(-src.shields_max)
			walk(src, 0)
			src.flying = 0
			power_area = 0

		interior_area.power_equip = power_area
		interior_area.power_light = power_area
		interior_area.power_environ = power_area
		interior_area.power_change()
		return

	proc/hasPower()
		if(power_used_last > power_produced_last || health <= 0) return 0
		else return 1

	proc/damageArmor(var/amount, var/type = D_SPECIAL, var/use_resistance = 1)
		if(health <= 0) return //BEEP BOOP

		if(use_resistance)
			if(type & D_KINETIC || type & D_PIERCING || type & D_SLASHING)
				amount += (amount * 0.5)
			else if(type & D_TOXIC)
				amount = amount //TODO: Add special
			else if(type & D_SPECIAL)
				amount = amount //TODO: Add special

		shields_timer = world.time
		amount = round(max(1, amount))
		adjustArmor(-amount, type)
		return

	proc/damageShields(var/amount, var/type = D_SPECIAL, var/use_resistance = 1)
		if(use_resistance)
			if(type & D_ENERGY || type & D_BURNING || type & D_RADIOACTIVE)
				if(!shield_modulation)
					amount += (amount * 0.5)
			else if(type & D_KINETIC || type & D_PIERCING || type & D_SLASHING)
				amount -= (amount * 0.25)
			else if(type & D_TOXIC)
				amount = amount //TODO: Add special
			else if(type & D_SPECIAL)
				amount = amount //TODO: Add special

		var/adjustment = (1 - (power_defense / 100)) * amount
		amount += adjustment

		shields_timer = world.time
		amount = round(max(1, amount))
		adjustShields(-amount, type)
		return


	proc/adjustShields(var/amount, var/type = D_SPECIAL)
		shields_last = shields
		shields += amount
		shields = clamp(shields, 0, shields_max)

		var/percent_shields = clamp((shields / shields_max), 0, 1)
		if(shields_last > 0 && shields <= 0) //Collapse
			if(shield_obj.icon_state != "shield_collapse")
				internal_sound(src.loc, 'sound/machines/shielddown.ogg', 100, 1, -1)
				shield_obj.alpha = 170
				shield_obj.icon_state = "shield_collapse"
				animate(shield_obj, loop = 1, time = 10, alpha = 1)
		else if(shields_last <= 0 && shields > 0) //Reboot
			if(shield_obj.icon_state != "shield_reboot")
				internal_sound(src.loc, 'sound/machines/shieldup.ogg', 100, 1, -1)
				shield_obj.alpha = 170
				shield_obj.icon_state = "shield_reboot"
				animate(shield_obj, loop = 1, time = 10, alpha = round(170 * percent_shields))
		else if(shields > 0)
			shield_obj.alpha = max(round(170 * percent_shields), 25)

		updateIndicators()
		return

	proc/warp()
		if (warping)
			return

		//warp
		if (!src.engine)
			message_coders("ZeWaka/CruiserWarp: No engine but warp was called.")
		var/list/beacons = list()
		for(var/obj/warp_beacon/W in by_type[/obj/warp_beacon])
			beacons += W
		for (var/obj/machinery/tripod/T in machine_registry[MACHINES_MISC])
			if (istype(T.bulb, /obj/item/tripod_bulb/beacon))
				beacons += T
		warping = 1

		var/obj/target = input(usr, "Please select a location to warp to.", "Warp Computer") as null|obj in beacons
		if(!target)
			warping = 0
			return

		internal_sound(src.loc, 'sound/machines/cruiser_warp.ogg', 85, 0, 1)
		var/image/warpOverlay = image('icons/obj/large/160x160.dmi',"warp")
		overlays.Add(warpOverlay)
		animate(src, alpha = 0, time = 10)
		shield_obj.invisibility = INVIS_ALWAYS

		sleep(2 SECONDS)

		do_teleport(src, target, 1)
		animate(src, alpha = 255, time = 10)

		sleep(1.5 SECONDS)
		overlays.Cut()
		shield_obj.invisibility = INVIS_NONE
		warping = 0
		return

	proc/adjustArmor(var/amount, var/type = D_SPECIAL)
		if(amount < 0)
			distributeHealthDamage(amount)
		else
			distributeHealthRepair(amount)

		checkHealth()
		updateIndicators()
		if(amount < 0 && health <= (health_max - (health_max / 3)) && prob(10+degradation))
			var/amount_add = nround((degradation / 2)/10)
			startFire(1+amount_add)
		return

	proc/distributeHealthRepair(var/amount)
		var/list/components = list()
		for(var/obj/machinery/cruiser_destroyable/D in interior_area)
			if(D.ignore || D.health == D.health_max) continue
			components.Add(D)

		//Shuffle list???

		if(components.len)
			for(var/obj/machinery/cruiser_destroyable/D in components)
				if(!amount) break
				var/missing = D.health_max - D.health
				if(amount >= missing)
					D.adjustHealth(missing)
					amount -= missing
				else if (missing < amount)
					D.adjustHealth(amount)
					amount = 0
					break
		return

	proc/distributeHealthDamage(var/amount)
		var/list/components = list()
		for(var/obj/machinery/cruiser_destroyable/D in interior_area)
			if(D.ignore || D.health == 0) continue
			components.Add(D)

		var/num_split = rand(1,4)

		var/list/selected = list()
		for(var/i=0, i<num_split, i++)
			if(!components.len) continue
			var/curr = pick(components)
			selected.Add(curr)
			components.Remove(curr)

		if(selected.len)
			while(amount < 0)
				var/chunk = max(rand(-10, -5), amount)
				amount += abs(chunk)

				var/obj/machinery/cruiser_destroyable/D = pick(selected)
				D.adjustHealth(chunk)
		return

	proc/getMaxHealth()
		var/count = 0
		for(var/obj/machinery/cruiser_destroyable/D in interior_area)
			if(D.ignore) continue
			count += D.health_max

		health_max = count
		return count

	proc/getCurrHealth()
		var/count = 0
		for(var/obj/machinery/cruiser_destroyable/D in interior_area)
			if(D.ignore) continue
			count += D.health

		health_last = health
		health = count
		return count

	proc/checkHealth()
		getMaxHealth()
		getCurrHealth()
		if(health_last <= 0 && health)
			particleMaster.RemoveSystem(/datum/particleSystem/cruiserSmoke, src)
		if(health_last > 0 && health <= 0)
			destroy()
		return

	proc/startFire(var/amount = 1)
		if(interior_area && length(interior_area))
			var/list/hotspot_turfs = list()
			for(var/turf/T in interior_area)
				if(T.density) continue
				hotspot_turfs.Add(T)

			for(var/i=0, i<amount, i++)
				var/turf/A = pick(hotspot_turfs)
				fireflash(A, 1, chemfire = CHEM_FIRE_RED)
		return

	proc/destroy()
		particleMaster.SpawnSystem(new /datum/particleSystem/cruiserSmoke(src))
		return

	proc/updateIndicators()
		var/percent_health = clamp((health / max(1,health_max)), 0, 1)
		bar_top.transform = matrix(percent_health, 1, MATRIX_SCALE)
		bar_top.pixel_x = -nround( ((81 - (81 * percent_health)) / 2) )

		var/percent_shields = clamp((shields / shields_max), 0, 1)
		bar_middle.transform = matrix(percent_shields, 1, MATRIX_SCALE)
		bar_middle.pixel_x = -nround( ((81 - (81 * percent_shields)) / 2) )

		var/percent_power = clamp((power_used_last / max(1,power_produced_last)), 0, 1)
		bar_bottom.transform = matrix(percent_power, 1, MATRIX_SCALE)
		bar_bottom.pixel_x = -nround( ((81 - (81 * percent_power)) / 2) )

		if(interior_area)
			for(var/obj/machinery/cruiser_status_panel/S in interior_area)
				S.setValues(percent_health, percent_shields, percent_power)
			for(var/obj/machinery/cruiser_status_panel/S in upper_area)
				S.setValues(percent_health, percent_shields, percent_power)
		return

	proc/receiveMovement(var/direction)
		if(!hasPower() || !(direction == NORTH || direction == EAST || direction == SOUTH || direction == WEST))
			return

		var/base_speed = 5

		if(engine)
			base_speed = 1.5 // speed modification by equipped engine not implemented - feel free to change

		var/adjustment = (1 - (power_movement / 100)) * base_speed
		base_speed += adjustment

		base_speed = max(base_speed + speed_mod, 0.1)

		src.facing = direction
		if (src.dir == direction)
			if(flying == turn(src.dir,180))
				walk(src, 0)
				flying = 0
			else
				walk(src, src.dir, base_speed + stall)
				flying = src.dir
		else
			src.set_dir(direction)
		return

	proc/getProjectileOrigins()
		/* //Outer edge version.
		switch(src.dir)
			if(NORTH)
				return list("left"=locate(src.x, src.y + 5, src.z), "right"=locate(src.x + 4, src.y + 5, src.z))
			if(EAST)
				return list("left"=locate(src.x + 5, src.y + 4, src.z), "right"=locate(src.x + 5, src.y, src.z))
			if(SOUTH)
				return list("left"=locate(src.x + 4, src.y - 1, src.z), "right"=locate(src.x, src.y - 1, src.z))
			if(WEST)
				return list("left"=locate(src.x - 1, src.y, src.z), "right"=locate(src.x - 1, src.y + 4, src.z))
		*/
		switch(src.dir) //Inner 2 version
			if(NORTH)
				return list("left"=locate(src.x + 1, src.y + 5, src.z), "right"=locate(src.x + 3, src.y + 5, src.z))
			if(EAST)
				return list("left"=locate(src.x + 5, src.y + 3, src.z), "right"=locate(src.x + 5, src.y + 1, src.z))
			if(SOUTH)
				return list("left"=locate(src.x + 3, src.y - 1, src.z), "right"=locate(src.x + 1, src.y - 1, src.z))
			if(WEST)
				return list("left"=locate(src.x - 1, src.y + 1, src.z), "right"=locate(src.x - 1, src.y + 3, src.z))


	proc/fireAt(var/atom/target)
		if(!hasPower())
			return

		var/list/origins = getProjectileOrigins()
		var/list/cooldown = 0

		if(turret_left)
			if(get_dir(origins["left"], target) != src.dir && get_dir(origins["left"], target) != turn(src.dir,45) && get_dir(origins["left"], target) != turn(src.dir,-45))
				; //internal_sound(src.loc, 'sound/machines/shielddown.ogg', 100, 1, -1)
			else
				if(!(firemode & CRUISER_FIREMODE_RIGHT))
					if((firemode & CRUISER_FIREMODE_ALT && alt_weapon == 0) || !(firemode & CRUISER_FIREMODE_ALT))
						var/obj/projectile/proj_left = initialize_projectile_pixel_spread(origins["left"], turret_left.current_projectile, target)
						proj_left.launch()
						proj_left.shooter = src

						var/adjustment = (1 - (power_offense / 100)) * turret_left.firerate
						cooldown = (turret_left.firerate + adjustment)

						if(turret_left.current_projectile.shot_sound)
							internal_sound(src.loc, turret_left.current_projectile.shot_sound, 80, 1, 1)

		if(turret_right)
			if(get_dir(origins["right"], target) != src.dir && get_dir(origins["right"], target) != turn(src.dir,45) && get_dir(origins["right"], target) != turn(src.dir,-45))
				; //internal_sound(src.loc, 'sound/machines/shielddown.ogg', 100, 1, -1)
			else
				if(!(firemode & CRUISER_FIREMODE_LEFT))
					if((firemode & CRUISER_FIREMODE_ALT && alt_weapon == 1) || !(firemode & CRUISER_FIREMODE_ALT))
						var/obj/projectile/proj_right = initialize_projectile_pixel_spread(origins["right"], turret_right.current_projectile, target)
						proj_right.launch()
						proj_right.shooter = src

						var/adjustment = (1 - (power_offense / 100)) * turret_right.firerate
						cooldown = max(turret_right.firerate + adjustment, cooldown)

						if(turret_right.current_projectile.shot_sound)
							internal_sound(src.loc, turret_right.current_projectile.shot_sound, 80, 1, 1)

		alt_weapon = !alt_weapon

		return max(cooldown + weapon_cooldown_mod, 0)

	proc/leaveShip(mob/user as mob)
		var/turf/T = getExitLoc()
		var/blocked = T.density

		for(var/atom/A in T)
			if(A.density)
				blocked = 1
				break
		if(!blocked)
			user.set_loc(getExitLoc())
			if(ismob(user)) crew.Remove(user)
		else
			boutput(user, SPAN_ALERT("The exit is blocked."))
		return

	proc/enterShip(atom/movable/O as obj, mob/user as mob)
		if(!interior_area || O == src) return

		if(entrance)
			if(BOUNDS_DIST(O, getExitLoc()) == 0)
				O.set_loc(entrance)
				if(ismob(O))
					crew.Add(O)
				boutput(user, SPAN_ALERT("You put [O] into [src]."))
			else
				boutput(user, SPAN_ALERT("[O] is too far away from [src]'s airlock."))
		return

	proc/shakeCruiser(duration, strength=1, delay=0.2)
		for(var/mob/M in crew)
			shake_camera(M, duration, strength, delay)
		return

	proc/getExitLoc()
		switch(src.dir)
			if(NORTH)
				return locate(src.x + 2, src.y - 1, src.z)
			if(EAST)
				return locate(src.x - 1, src.y + 2, src.z)
			if(SOUTH)
				return locate(src.x + 2, src.y + 5, src.z)
			if(WEST)
				return locate(src.x + 5, src.y + 2, src.z)

/area/cruiser
	name = "cruiser interior"
	icon = 'icons/turf/areas.dmi'
	icon_state = "eshuttle_transit"
	var/obj/machinery/cruiser/ship
	var/is_upper = FALSE
	requires_power = 1

	Entered(var/atom/movable/A, atom/oldloc)
		. = ..()
		if(!src.is_upper || !ismob(A))
			return
		var/mob/user = A
		src.ship.subscribe_interior(user)
		user.set_eye(src.ship)

	Exited(atom/movable/A)
		. = ..()
		if(!ismob(A))
			return
		if(get_area(A) == src)
			return
		var/mob/user = A
		src.ship.unsubscribe_interior(user)
		user.set_eye(null)

/area/cruiser/syndicate/lower
	name = "Syndicate cruiser interior"
	sound_group = "cruiser_syndicate"
/area/cruiser/syndicate/upper
	name = "Syndicate cruiser interior"
	sound_group = "cruiser_syndicate"
	is_upper = TRUE
/area/cruiser/nanotrasen/lower
	name = "Nanotrasen cruiser interior"
	sound_group = "cruiser_nanotrasen"
/area/cruiser/nanotrasen/upper
	name = "Nanotrasen cruiser interior"
	sound_group = "cruiser_nanotrasen"
	is_upper = TRUE


/obj/cruiser_camera_dummy
	name = ""
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	density = 0

	New()
		. = ..()
		START_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)

	disposing()
		. = ..()
		STOP_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)

/obj/machinery/cruiser_status_panel
	name = "Status panel"
	icon = 'icons/obj/ship.dmi'
	icon_state = "statpanel"
	density = 0
	anchored = ANCHORED
	var/image/barTop
	var/image/barMid
	var/image/barBot

	New()
		..()
		UnsubscribeProcess()
		barTop = image('icons/obj/ship.dmi',src,"statpanel1",src.layer+1)
		barTop.color = "#8A1919"

		barMid = image('icons/obj/ship.dmi',src,"statpanel2",src.layer+1)
		barMid.color = "#19688A"

		barBot = image('icons/obj/ship.dmi',src,"statpanel3",src.layer+1)
		barBot.color = "#CF9417"

	proc/setValues(var/armor, var/shields, var/power)
		barTop.transform = matrix(armor, 1, MATRIX_SCALE)
		barTop.pixel_x = -nround( ((24 - (24 * armor)) / 2) )

		barMid.transform = matrix(shields, 1, MATRIX_SCALE)
		barMid.pixel_x = -nround( ((24 - (24 * shields)) / 2) )

		barBot.transform = matrix(power, 1, MATRIX_SCALE)
		barBot.pixel_x = -nround( ((24 - (24 * power)) / 2) )

		src.overlays.Cut()
		src.overlays.Add(barTop)
		src.overlays.Add(barMid)
		src.overlays.Add(barBot)
		return

/obj/machinery/cruiser_destroyable/cable_panel
	name = "Cable panel"
	icon_state = "wpanel0"
	icon_working = "wpanel0"
	icon_broken = "wpanel1"
	name_working = "Panel"
	name_broken = "Ruined cable panel"
	health = 20
	health_max = 20
	repair_time = 30

/obj/machinery/cruiser_destroyable/cable_floor
	name = ""
	desc = "A large hole in the floor."
	icon_state = "hole1"
	icon_working = "hole0"
	icon_broken = "hole1"
	name_working = ""
	name_broken = "hole"
	repair_time = 180

	New()
		icon_broken = pick("hole1", "hole1a", "hole1b", "hole1c", "hole1d")
		..()

/obj/machinery/cruiser_destroyable
	name = "Panel"
	icon = 'icons/obj/ship.dmi'
	icon_state = "wpanel0"
	density = 0
	anchored = ANCHORED
	var/ignore = 0 //Wont count towards health / max health and won't break.
	var/broken = 0
	var/health = 50
	var/health_last = 0
	var/health_max = 50
	var/icon_working = "wpanel0"
	var/icon_broken = "wpanel1"
	var/name_working = ""
	var/name_broken = ""
	var/tool_type = /obj/item/wrench
	var/repair_time = 150
	var/rebooting = 0

	meteorhit()
		return

	bullet_act(var/obj/projectile/P)
		return

	ex_act(var/severity)
		return

	attackby(obj/item/W, mob/user)
		if (rebooting) return
		if (istype(W, tool_type) && (broken || health < health_max))
			playsound(src.loc, 'sound/machines/repairing.ogg', 85, 1)
			var/health_adj = 1 - (health / health_max) //90% = 0,1, 10% = 0,9
			var/repair_time_adj = round(repair_time * health_adj)
			actions.start(new/datum/action/bar/icon/cruiser_repair(src, W, repair_time_adj), user)
			return 1
		return 0

	proc/reboot() //Called when the device is rebooted / in override mode.
		rebooting = 1
		SPAWN(1 SECOND) rebooting = 0
		return "Reboot complete"

	proc/adjustHealth(var/amount)
		if(amount < 0 && health == 0) return
		if(amount > 0 && health == health_max) return

		health_last = health
		health += amount
		health = max(health, 0)
		health = min(health, health_max)
		checkHealth()
		return

	proc/checkHealth()
		if(health_last == 0 && health > 0)
			repair()
		else if(health_last > 0 && health == 0)
			destroy()
		return

	proc/destroy()
		if(broken) return
		broken = 1
		setIcon()
		var/area/cruiser/I = get_area(src)
		if(istype(I) && I.ship)
			I.ship.shakeCruiser(4, 5, 0.4)
			I.ship.degradation = min(I.ship.degradation + 2, 100)
		return

	proc/repair()
		if(!broken) return
		broken = 0
		setIcon()
		return

	proc/setIcon()
		if(broken)
			icon_state = icon_broken
			name = name_broken
		else
			icon_state = icon_working
			name = name_working
		return

/obj/machinery/cruiser_destroyable/cruiser_component_slot
	name = "Component slot"
	icon = 'icons/obj/ship.dmi'
	icon_state = "chute0"
	var/icon_state_open = "chute1"
	var/icon_state_closed = "chute0"
	var/container_type = /obj/item/shipcomponent
	var/open = 0
	var/ready = 1
	var/check_blocked = 1

	setIcon()
		if(broken)
			src.setTexture("damaged", BLEND_MULTIPLY, "damaged")
		else
			src.UpdateOverlays(null, "damaged")

		if(open) icon_state = icon_state_open
		else icon_state = icon_state_closed

	attackby(obj/item/W, mob/user)
		if(!..())
			if(open)
				user.drop_item()
				W.set_loc(src.loc)
			else
				attack_hand(user)
		return

	destroy()
		. = ..()
		open(null, 1)
		return .

	reboot()
		if(rebooting) return "Device is busy."
		rebooting = 1
		open()
		sleep(repair_time / 2)
		if(health == 0)
			adjustHealth(1)
		rebooting = 0
		close()
		return "Reboot complete."

	proc/open(var/mob/user = null, var/ignore_blocked = 0)
		if(open) return

		var/blocked = src.loc.density
		for(var/atom/B in src.loc)
			if(B.density)
				blocked = 1
				break
		if(check_blocked && blocked && !ignore_blocked)
			if(user)
				boutput(user, SPAN_ALERT("Something is preventing the [src] from opening."))
		else
			ready = 0
			SPAWN(1 SECOND) ready = 1
			playsound(src.loc, 'sound/machines/hydraulic.ogg', 50, 0, -1)
			open = 1
			setIcon()
			uninstall_component()
			set_density(1)
		return

	proc/close(var/mob/user = null)
		if(!open) return
		if(rebooting)
			boutput(user, SPAN_ALERT("This device is currently disabled."))
			return
		ready = 0
		SPAWN(1 SECOND) ready = 1
		playsound(src.loc, 'sound/machines/weapons-deploy.ogg', 60, 0, -1)
		open = 0
		setIcon()
		install_component()
		set_density(0)
		return

	attack_hand(mob/user)
		if(!ready) return
		if(open)
			if(broken)
				boutput(user, "[src] is broken. It needs to be repaired.</span>")
			else
				close(user)
		else
			if(broken)
				boutput(user, "[src] is broken. It needs to be repaired.</span>")
				return
			open(user)


	proc/install_component()
		return

	proc/uninstall_component()
		return

/obj/machinery/cruiser_destroyable/cruiser_component_slot/weapon
	name = "Weapon slot"
	container_type = /obj/item/shipcomponent/mainweapon

/obj/machinery/cruiser_destroyable/cruiser_component_slot/weapon/left
	name = "Left turret slot"
	install_component()
		var/area/cruiser/interior = get_area(src)
		if(interior?.ship)
			for(var/atom/movable/A in src.loc)
				if(istype(A, container_type))
					A.set_loc(interior.ship)
					interior.ship.turret_left = A
					break
		return
	uninstall_component()
		var/area/cruiser/interior = get_area(src)
		if(interior?.ship?.turret_left)
			interior.ship.turret_left.set_loc(src.loc)
			interior.ship.turret_left = null
		return

/obj/machinery/cruiser_destroyable/cruiser_component_slot/weapon/right
	name = "Right turret slot"
	install_component()
		var/area/cruiser/interior = get_area(src)
		if(interior?.ship)
			for(var/atom/movable/A in src.loc)
				if(istype(A, container_type))
					A.set_loc(interior.ship)
					interior.ship.turret_right = A
					break
		return
	uninstall_component()
		var/area/cruiser/interior = get_area(src)
		if(interior?.ship?.turret_right)
			interior.ship.turret_right.set_loc(src.loc)
			interior.ship.turret_right = null
		return

/obj/machinery/cruiser_destroyable/cruiser_component_slot/engine
	name = "Engine core"
	container_type = /obj/item/shipcomponent/engine
	health = 75
	health_max = 75
	install_component()
		var/area/cruiser/interior = get_area(src)
		if(interior?.ship)
			for(var/atom/movable/A in src.loc)
				if(istype(A, container_type))
					A.set_loc(interior.ship)
					interior.ship.engine = A
					break
		return
	uninstall_component()
		var/area/cruiser/interior = get_area(src)
		if(interior?.ship?.engine)
			interior.ship.engine.set_loc(src.loc)
			interior.ship.engine = null
		return

/obj/machinery/cruiser_destroyable/cruiser_component_slot/life_support
	name = "Life support slot"
	icon = 'icons/obj/ship.dmi'
	icon_state = "chuteb1"
	icon_state_open = "chuteb0"
	icon_state_closed = "chuteb1"
	container_type = /obj/item/shipcomponent/life_support
	check_blocked = 0

	install_component()
		var/area/cruiser/interior = get_area(src)
		if(interior?.ship)
			for(var/atom/movable/A in src.loc)
				if(istype(A, container_type))
					A.set_loc(interior.ship)
					interior.ship.life_support = A
					break
		return

	uninstall_component()
		var/area/cruiser/interior = get_area(src)
		if(interior?.ship?.life_support)
			interior.ship.life_support.set_loc(src.loc)
			interior.ship.life_support = null
		return

/obj/machinery/cruiser_destroyable/cruiser_exit
	name = "ship exit"
	desc = "This airlock leads out of the ship."
	icon = 'icons/obj/doors/blastdoor.dmi'
	icon_state = "bdoorsingle1"
	anchored = ANCHORED
	density = 1
	ignore = 1

	bullet_act(var/obj/projectile/P)
		return
	ex_act(var/severity)
		return

	attack_hand(mob/user)
		var/area/cruiser/interior = get_area(src)
		if(interior.ship)
			interior.ship.leaveShip(user)

	attackby(var/obj/item/grab/G, mob/user)
		if ((!( istype(G, /obj/item/grab) ) || !( ismob(G.affecting) )))
			return
		if (G.state == GRAB_PASSIVE)
			boutput(user, SPAN_ALERT("You need a tighter grip!"))
			return
		var/mob/M = G.affecting
		var/area/cruiser/interior = get_area(src)
		if(interior.ship)
			user.visible_message(SPAN_ALERT("<b>[user] throws [M] out of \the [src]!"), SPAN_ALERT("<b>You throw [M] out of \the [src]!</b>"))
			interior.ship.leaveShip(M)
			M.changeStatus("knockdown", 2 SECONDS)
		qdel(G)
		return

/obj/machinery/cruiser_camera_screen
	name = "camera computer"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	density = 1
	anchored = ANCHORED

	attack_hand(mob/user)
		/*
		if(1) return//todo remove
		if(istype(user.abilityHolder, /datum/abilityHolder/composite))
			var/datum/abilityHolder/composite/C = user.abilityHolder
			C.addHolder(/datum/abilityHolder/cruiser)
			C.addAbility(/datum/targetable/cruiser/cancel_camera)
			user.client.view = 11
			var/area/cruiser/I = get_area(src)
			user.set_eye(I.ship)*/
		return

/obj/machinery/cruiser_destroyable/cruiser_pod
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "pod_command_0"
	var/mob/using = null
	var/area/cruiser/interior
	var/icon_state_full = "pod_command_1"
	var/icon_state_empty = "pod_command_0"
	var/datum/abilityHolder/cruiser/AbHolder
	var/list/abilities = list()
	bound_width = 32
	bound_height = 32
	texture_size = 64
	density = 1
	anchored = ANCHORED
	health = 85
	health_max = 85

	remove_air(amount)
		return src.loc.remove_air(amount)

	return_air(direct = FALSE)
		if (!direct)
			return src.loc.return_air()

	bullet_act(var/obj/projectile/P)
		for(var/atom/A in src)
			A.bullet_act(P)
		return

	ex_act(var/severity)
		for(var/atom/A in src)
			A.ex_act(severity)
		return

	setIcon()
		if(broken)
			src.setTexture("damaged", BLEND_MULTIPLY, "damaged")
		else
			src.UpdateOverlays(null, "damaged")
		if(using) icon_state = icon_state_full
		else icon_state = icon_state_empty

	destroy()
		. = ..()
		exitPod()
		return .

	reboot()
		if(rebooting) return "Device is busy."
		rebooting = 1
		exitPod()
		sleep(repair_time / 2)
		if(health == 0)
			adjustHealth(1)
		rebooting = 0
		return "Reboot complete."

	New()
		..()
		interior = get_area(src)
		icon_state = icon_state_empty
		AbHolder = new()
		AbHolder.addAbility(/datum/targetable/cruiser/exit_pod)
		AbHolder.addAbility(/datum/targetable/cruiser/toggle_interior)
		for(var/T in abilities)
			AbHolder.addAbility(T)

	attack_hand(mob/user)
		if(broken)
			boutput(user, SPAN_ALERT("This pod is broken and must be repaired before it can be used again."))
			return
		if(using)
			boutput(user, SPAN_ALERT("This pod is already being used."))
			return
		else
			enterPod(user)

	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		if(ismob(O) && O:client)
			attack_hand(O)

	proc/enterPod(mob/user as mob)
		var/obj/machinery/cruiser/C = interior.ship
		if(rebooting)
			boutput(user, SPAN_ALERT("This device is currently disabled."))
			return
		using = user
		user.set_loc(src)
		//user.set_eye(C.camera)
		//user.client.view = 11
		if(ishuman(user) && istype(user.abilityHolder, /datum/abilityHolder/composite))
			var/datum/abilityHolder/composite/H = user.abilityHolder
			H.addHolderInstance(AbHolder)
			AbHolder.resumeAllAbilities()
			user.attach_hud(AbHolder.hud)
		if(C)
			user.client.images += C.frames
			user.client.images += C.overframes
			user.client.images += C.bar_top
			user.client.images += C.bar_middle
			user.client.images += C.bar_bottom

		setIcon()
		return

	proc/exitPod()
		var/obj/machinery/cruiser/C = interior.ship
		if(!using) return
		using.set_loc(src.loc)

		//using.set_eye(null)
		//using.client.view = world.view
		if(ishuman(using) && istype(using.abilityHolder, /datum/abilityHolder/composite))
			using.targeting_ability = null
			using.update_cursor()
			using.detach_hud(AbHolder.hud)
			var/datum/abilityHolder/composite/H = using.abilityHolder
			AbHolder.suspendAllAbilities()
			H.removeHolder(/datum/abilityHolder/cruiser)
			C.subscribe_interior(using)

		if(C)
			using.client.images -= C.frames
			using.client.images -= C.overframes
			using.client.images -= C.bar_top
			using.client.images -= C.bar_middle
			using.client.images -= C.bar_bottom

		using = null
		setIcon()
		return

	process()
		..()
		return

/obj/machinery/cruiser_destroyable/cruiser_pod/movement
	name = "Navigation pod"
	icon_state_full = "pod_command_1"
	icon_state_empty = "pod_command_0"
	abilities = list(/datum/targetable/cruiser/ram, /datum/targetable/cruiser/warp)

	relaymove(mob/user, direction)
		var/obj/machinery/cruiser/C = interior.ship
		if (C)
			C.receiveMovement(direction)
		return

/obj/machinery/cruiser_destroyable/cruiser_pod/security
	name = "Security pod"
	icon_state = "pod_security_0"
	icon_state_full = "pod_security_1"
	icon_state_empty = "pod_security_0"
	abilities = list(/datum/targetable/cruiser/fire_weapons, /datum/targetable/cruiser/firemode, /datum/targetable/cruiser/weapon_overload, /datum/targetable/cruiser/shield_overload, /datum/targetable/cruiser/shield_modulation)

// currently unused pod
/obj/machinery/cruiser_destroyable/cruiser_pod/engineering
	name = "Engineering pod"
	icon_state = "pod_engineer_0"
	icon_state_full = "pod_engineer_1"
	icon_state_empty = "pod_engineer_0"

/obj/ladder/cruiser
	id = "cruiser"

	New()
		..()
		src.update_id("[src.id][src.x][src.z][world.time]")

/obj/ladder/cruiser/syndicate
	id = "cruiser_syndicate"

/obj/ladder/cruiser/nanotrasen
	id = "cruiser_nanotrasen"
