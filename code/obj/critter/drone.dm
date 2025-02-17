TYPEINFO(/obj/critter/gunbot/drone)
	mats = list("energy" = 5,
				"metal_dense" = 12,
				"conductive_high" = 12,
				"dense" = 6)
TYPEINFO(/obj/critter/gunbot/drone/glitchdrone)
	mats = null

TYPEINFO(/obj/critter/gunbot/drone/heavydrone)
	mats = list("energy_high" = 10,
				"metal_superdense" = 12,
				"conductive_high" = 12,
				"dense_super" = 9)
TYPEINFO(/obj/critter/gunbot/drone/cannondrone)
	mats = list("energy_extreme" = 15,
				"metal_superdense" = 17,
				"conductive_high" = 13,
				"crystal_dense" = 17,
				"erebite" = 16)
TYPEINFO(/obj/critter/gunbot/drone/minigundrone)
	mats = list("energy_extreme" = 13,
				"metal_superdense" = 24,
				"conductive_high" = 20,
				"crystal_dense" = 17)
TYPEINFO(/obj/critter/gunbot/drone/raildrone)
	mats = list("energy_extreme" = 19,
				"metal_superdense" = 20,
				"conductive_high" = 24,
				"dense_super" = 16)
TYPEINFO(/obj/critter/gunbot/drone/buzzdrone)
	mats = list("energy_high" = 19,
				"metal_dense" = 12,
				"conductive_high" = 14,
				"dense_super" = 26)
TYPEINFO(/obj/critter/gunbot/drone/buzzdrone/fish)
	mats = 	24

TYPEINFO(/obj/critter/gunbot/drone/laser)
	mats = list("energy_high" = 11,
				"metal_dense" = 14,
				"conductive_high" = 13,
				"dense_super" = 12)
TYPEINFO(/obj/critter/gunbot/drone/cutterdrone)
	mats = list("energy" = 9,
				"metal_superdense" = 15,
				"conductive" = 7,
				"crystal_dense" = 20)
TYPEINFO(/obj/critter/gunbot/drone/assdrone)
	mats = list("energy_extreme" = 30,
				"metal_superdense" = 14,
				"conductive_high" = 23,
				"crystal_dense" = 22,
				"butt" = 10)
TYPEINFO(/obj/critter/gunbot/drone/aciddrone)
	mats = list("energy" = 10,
				"metal" = 15,
				"conductive_high" = 15,
				"dense" = 10)
TYPEINFO(/obj/critter/gunbot/drone/helldrone)
	mats = null

/obj/critter/gunbot/drone
	name = "Syndicate Drone"
	desc = "An armed and automated Syndicate scout drone."
	icon = 'icons/mob/critter/robotic/drone/phaser.dmi'
	icon_state = "drone_phaser"
	dead_state = "drone_phaser-dead"
	density = 1
	health = 65
	maxhealth = 65 // for damage description
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 1
	atksilicon = 1
	atcritter = 0
	firevuln = 0.5
	brutevuln = 1
	miscvuln = 0
	attack_range = 7
	luminosity = 5
	seekrange = 15
	flying = 1
	var/score = 10
	var/obj/item/droploot = null
	var/damaged = 0 // 1, 2, 3
	var/dying = 0
	var/beeptext = "beeps"
	var/beepsound = 'sound/machines/twobeep.ogg'
	var/alertsound1 = 'sound/machines/whistlealert.ogg'
	var/alertsound2 = 'sound/machines/whistlebeep.ogg'
	var/projectile_type = /datum/projectile/laser/light
	var/datum/projectile/current_projectile = new/datum/projectile/laser/light // shoot proc cleanup

	var/attack_cooldown = 30

	var/smashes_shit = 0
	var/smashed_recently = 0
	var/smash_cooldown = 200
	var/list/can_smash = list(/obj/window, /obj/mesh/grille, /obj/table, /obj/foamedmetal, /obj/rack)
	var/list/do_not_smash = list(/obj/critter, /obj/machinery/vehicle, /obj/machinery/cruiser)

	var/projectile_spread = 0


	proc/select_target(var/atom/newtarget)
		src.target = newtarget
		src.oldtarget_name = newtarget.name
		if (alertsound1 || alertsound2)
			playsound(src.loc, ismob(newtarget) ? alertsound2 : alertsound1, 55, 1)
		src.visible_message(SPAN_ALERT("<b>[src]</b> starts chasing [src.target]!"))
		task = "chasing"


	New()
		..()
		name = "Drone SC-[rand(1,999)]"
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	bump(atom/movable/AM)
		if(smashes_shit)
			if(isobj(AM))
				for(var/type in do_not_smash)
					if(istype(AM, type)) return
				var/smashed_shit = 1

				if(istype(AM, /obj/window))
					AM:health = 0
					AM:smash()
				else if(istype(AM,/obj/mesh/grille))
					AM:damage_blunt(30)
				else if(istype(AM, /obj/table))
					AM.meteorhit()
				else if(istype(AM, /obj/foamedmetal))
					AM.dispose()
				else
					AM.meteorhit()

				if(smashed_shit)
					playsound(src.loc, 'sound/effects/exlow.ogg', 70,1)
					src.visible_message(SPAN_ALERT("<B>[src]</B> smashes into \the [AM]!"))
			..()


	seek_target()
		src.anchored = UNANCHORED

		if(smashes_shit)
			//There be shit near us what can block our way.
			for (var/obj/O in oview(1,src))
				if(O.type in can_smash)
					step_towards(src,O,4) //Thugg lyfe
					break

		for (var/mob/living/C in view(src.seekrange,src))
			if (!src.alive) break
			if (C.health < 0) continue
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				select_target(C)
				src.attack = 0
				return
			else continue


		for (var/atom in by_cat[TR_CAT_PODS_AND_CRUISERS])
			var/atom/A = atom
			if (A && src.z == A.z && GET_DIST(src,A) <= src.seekrange)
				if (istype(atom, /obj/machinery/vehicle))
					var/obj/machinery/vehicle/C = atom
					if (C.health < 0)
						continue
					if (!(FACTION_SYNDICATE in C.faction))
						src.attack = 1
					if (C.name == src.attacker)
						src.attack = 1

					if (src.attack)
						select_target(C)
						C.threat_alert(src)
						src.attack = 0
						return
					else continue
				else if (istype(atom, /obj/machinery/cruiser))
					var/obj/machinery/cruiser/C = atom
					if (C.health < 0) continue
					if (C.name == src.attacker) src.attack = 1
					src.attack = 1

					if (src.attack)
						select_target(C)
						src.attack = 0
						return
					else continue

		if(src.atcritter)
			for (var/obj/critter/C in view(src.seekrange,src))
				if (!C.alive) break
				if (C.health < 0) continue
				if (C.name == src.attacker) src.attack = 1
				if (!istype(C, /obj/critter/gunbot)) src.attack = 1

				if (src.attack)
					select_target(C)
					src.attack = 0
					return
				else continue

	check_health()
		..()
		if(health == maxhealth) return
		var/percent_damage = src.health/src.maxhealth * 100
		switch(percent_damage)
			if(75 to 100)
				return
			if(50 to 74)
				if(damaged == 1) return
				damaged = 1
				desc = "[src] looks lightly [pick("dented", "burned", "scorched", "scratched")]."
			if(25 to 49)
				if(damaged == 2) return
				damaged = 2
				desc = "[src] looks [pick("quite", "pretty", "rather")] [pick("dented", "busted", "messed up", "burned", "scorched", "haggard")]."
			if(0 to 24)
				if(damaged == 3) return
				damaged = 3
				desc = "[src] looks [pick("really", "totally", "very", "all sorts of", "super")] [pick("mangled", "busted", "messed up", "burned", "broken", "haggard", "smashed up", "trashed")]."
		return

	CritterAttack(atom/M)
		if(target)
			src.attacking = 1
			//playsound(src.loc, 'sound/machines/whistlebeep.ogg', 55, 1)
			src.visible_message(SPAN_ALERT("<b>[src]</b> fires at [M]!"))

			var/tturf = get_turf(M)
			Shoot(tturf, src.loc, src)

			if(prob(20)) // break target fixation
				src.target = null
				src.last_found = world.time
				src.frustration = 0
				src.task = "thinking"
				walk_to(src,0)

			SPAWN(attack_cooldown)
				src.attacking = 0
		return


	ChaseAttack(atom/M)
		if(target)
			src.attacking = 1
			//playsound(src.loc, 'sound/machines/whistlebeep.ogg', 55, 1)
			src.visible_message(SPAN_ALERT("<b>[src]</b> fires at [M]!"))

			var/tturf = get_turf(M)
			Shoot(tturf, src.loc, src)

			if(prob(20))
				src.target = null
				src.last_found = world.time
				src.frustration = 0
				src.task = "thinking"
				walk_to(src,0)

			SPAWN(attack_cooldown)
				src.attacking = 0
		return

	proc/applyDeathState()
		icon_state = dead_state

	CritterDeath()
		if(dying) return
		applyDeathState()
		dying = 1 // this was dying = 0. ha ha.
		SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_DRONE_DEATH, src)
		SPAWN(2 SECONDS)
			if (prob(25))
				new /obj/item/device/prox_sensor(src.loc)
			if(droploot)
				new droploot(src.loc)
			..()
			return

	Shoot(var/target, var/start, var/user, var/bullet = 0)
		if(target == start)
			return

		if(istype(target, /obj/machinery/cruiser))
			shoot_projectile_ST_pixel_spread(src, current_projectile, target, 64, 64, projectile_spread)
		else
			shoot_projectile_ST_pixel_spread(src, current_projectile, target, 0, 0, projectile_spread)
		return

	process() // override so drones don't just loaf all fuckin day
		if (!src.alive) return 0

		if(sleeping > 0)
			sleeping--
			return 0

		check_health()

		if(prob(7))
			src.visible_message("<b>[src] [beeptext].</b>")
			if (beepsound)
				playsound(src, beepsound, 55, TRUE)

		if(task == "following path")
			follow_path()
		else if(task == "sleeping")
			var/waking = 0

			for (var/client/C)
				var/mob/M = C.mob
				if (M && src.z == M.z && GET_DIST(src, M) <= 10)
					if (isliving(M))
						waking = 1
						break

			for (var/atom in by_cat[TR_CAT_PODS_AND_CRUISERS])
				var/atom/A = atom
				if (A && src.z == A.z && GET_DIST(src, A) <= 10)
					waking = 1
					break

			if(waking)
				task = "thinking"
			else
				sleeping = 5
				return 0
		else if(sleep_check <= 0)
			sleep_check = 5

			var/stay_awake = 0

			for (var/client/C)
				var/mob/M = C.mob
				if (M && src.z == M.z && GET_DIST(src, M) <= 10)
					if (isliving(M))
						stay_awake = 1
						break

			for (var/atom in by_cat[TR_CAT_PODS_AND_CRUISERS])
				var/atom/A = atom
				if (A && src.z == A.z && GET_DIST(src, A) <= 10)
					stay_awake = 1
					break

			if(!stay_awake)
				sleeping = 5
				task = "sleeping"
				return 0

		else
			sleep_check--

		return ai_think()

	ai_think() // more dumb overrides, fuckin lazy critters
		switch(task)
			if("thinking")
				src.attack = 0
				src.target = null

				walk_to(src,0)
				if (src.aggressive) seek_target()
				if (src.wanderer && !src.target) src.task = "wandering"
			if("chasing")
				if (src.frustration >= rand(20,40))
					src.target = null
					src.last_found = world.time
					src.frustration = 0
					src.task = "thinking"
					walk_to(src,0)
				if (target)
					if (GET_DIST(src, src.target) <= src.attack_range)
						var/mob/living/carbon/M = src.target
						if (M)
							if(!src.attacking) ChaseAttack(M)
							src.task = "attacking"
							src.anchored = ANCHORED
							src.target_lastloc = M.loc
							if(prob(15)) walk_rand(src,4) // juke around and dodge shots

					else
						var/turf/olddist = GET_DIST(src, src.target)

						if(smashes_shit) //Break another thing near the drone
							//There be shit near us what can block our way.
							for (var/obj/O in view(1,src))
								if(O.type in can_smash)
									step_towards(src,O,4) //Thugg lyfe
									break

						if(prob(20)) walk_rand(src,4) // juke around and dodge shots
						/*else if(smashes_shit && !smashed_recently && prob(20) && target in ohearers(src,src.seekrange) ) //RAM THE FUCKER! Or not. This sucks. Bad idea.
							smashed_recently = 1
							SPAWN(smash_cooldown)
								smashed_recently = 0

							walk_towards(src, src.target, 1, 4)*/
						else walk_to(src, src.target,1,4)

						if ((GET_DIST(src, src.target)) >= (olddist))
							src.frustration++

						else
							src.frustration = 0
				else src.task = "thinking"
			if("attacking")
				if(prob(15)) walk_rand(src,4) // juke around and dodge shots
				// see if he got away
				if ((BOUNDS_DIST(src, src.target) > 0) || ((src.target:loc != src.target_lastloc)))
					src.anchored = UNANCHORED
					src.task = "chasing"
				else
					if (BOUNDS_DIST(src, src.target) == 0)
						var/mob/living/carbon/M = src.target
						if (!src.attacking) CritterAttack(src.target)
						if (!src.aggressive)
							src.task = "thinking"
							src.target = null
							src.anchored = UNANCHORED
							src.last_found = world.time
							src.frustration = 0
							src.attacking = 0
						else
							if(M!=null)
								if (M.health < 0)
									src.task = "thinking"
									src.target = null
									src.anchored = UNANCHORED
									src.last_found = world.time
									src.frustration = 0
									src.attacking = 0
					else
						src.anchored = UNANCHORED
						src.attacking = 0
						src.task = "chasing"
			if("wandering")
				patrol_step()
		return 1

	glitchdrone
		name = "Syndic<t@ Ar%#i§lÜrr D²o-|"
		desc = "A highly dÄ:;g$r+us $yn§i#a{e $'+~`?? ???? ? ???? ??"
		icon = 'icons/mob/critter/robotic/drone/glitch.dmi'
		icon_state = "drone_glitch"
		dead_state = "drone_glitch"
		health = 8000
		maxhealth = 8000
		score = 9000
		alertsound1 = 'sound/machines/glitch1.ogg'
		alertsound2 = 'sound/machines/glitch2.ogg'
		droploot = /obj/bomberman
		projectile_type = /datum/projectile/bullet/glitch
		current_projectile = new/datum/projectile/bullet/glitch

		New()
			..()
			name = "Dr~n³ *§#-[rand(1,999)]"

		applyDeathState()
			overlays += image('icons/mob/critter/robotic/drone/overlays.dmi', "dying-overlay")

	heavydrone
		name = "Syndicate Hunter-Killer Drone"
		desc = "A heavily-armed Syndicate hunter-killer drone."
		icon = 'icons/mob/critter/robotic/drone/disruptor.dmi'
		icon_state = "drone_disruptor"
		dead_state = "drone_distruptor-dead"
		health = 250
		maxhealth = 250
		score = 50
		droploot = /obj/item/gun/energy/phaser_gun
		projectile_type = /datum/projectile/disruptor/high
		current_projectile = new/datum/projectile/disruptor/high
		attack_cooldown = 40

		New()
			..()
			name = "Drone HK-[rand(1,999)]"

	virtual
		applyDeathState()
			overlays += image('icons/mob/critter/robotic/drone/overlays.dmi', "dying-overlay")

		laserdrone
			name = "Virtual Laser Drone"
			desc = "An alarmingly well-equipped but relatively fragile virtual drone."
			icon = 'icons/mob/critter/robotic/drone/laser.dmi'
			icon_state = "drone_laser"
			dead_state = "drone_laser"
			health = 100
			maxhealth = 100
			score = 30
			projectile_type = /datum/projectile/laser
			current_projectile = new/datum/projectile/laser

			New()
				..()
				name = "Drone LZ-[rand(1,999)]"

		cutterdrone
			name = "Virtual Plasma Cutter Drone"
			desc = "A virtual copy of the classic PC series mining drones, now primarily used to cut people in half instead of asteroids."
			icon = 'icons/mob/critter/robotic/drone/cutter.dmi'
			icon_state = "drone_cutter"
			dead_state = "drone_cutter"
			health = 150
			maxhealth = 150
			score = 40
			projectile_type = /datum/projectile/laser/mining
			current_projectile = new/datum/projectile/laser/mining

			New()
				..()
				name = "Drone PC-[rand(1,999)]"

		assdrone // HEH
			name = "Virtual Assault Drone"
			desc = "This is a digital reconstruction of the BR-series breach drones employed by Nanotrasen in space extraction and destruction missions."
			icon = 'icons/mob/critter/robotic/drone/assault.dmi'
			icon_state = "drone_assault"
			dead_state = "drone_assault"
			health = 150
			maxhealth = 150
			score = 60
			projectile_type = /datum/projectile/laser/asslaser
			current_projectile = new/datum/projectile/laser/asslaser

			New()
				..()
				name = "Drone BR-[rand(1,999)]"

		aciddrone
			name = "Virtual Acid Drone"
			desc = "This is a digital reconstruction of the CA-series concentrated acid breach drones, the planetary mission counterpart to the robustness of the BR-series assault drones."
			icon = 'icons/mob/critter/robotic/drone/acid.dmi'
			icon_state = "drone_acid"
			dead_state = "drone_acid"
			health = 250
			maxhealth = 250
			score = 80
			projectile_type = /datum/projectile/special/acid
			current_projectile = new/datum/projectile/special/acid

			New()
				..()
				name = "Drone CA-[rand(1,999)]"

	cannondrone
		name = "Syndicate Artillery Drone"
		desc = "A highly dangerous Syndicate drone equipped with a miniaturized artillery system."
		icon = 'icons/mob/critter/robotic/drone/artillery.dmi'
		icon_state = "drone_artillery"
		dead_state = "drone_artillery-dead"
		health = 200
		maxhealth = 200
		score = 120
		alertsound1 = 'sound/machines/engine_alert1.ogg'
		alertsound2 = 'sound/machines/engine_alert1.ogg'
		droploot = /obj/item/shipcomponent/secondary_system/crash
		projectile_type = /datum/projectile/bullet/aex
		current_projectile = new/datum/projectile/bullet/aex
		attack_cooldown = 50

		New()
			..()
			name = "Drone AR-[rand(1,999)]"

	minigundrone
		name = "Syndicate BL Drone"
		desc = "A Syndicate drone equipped with a ballistic weapon."
		icon = 'icons/mob/critter/robotic/drone/ballistic.dmi'
		icon_state = "drone_ballistic"
		dead_state = "drone_ballistic-dead"
		health = 200
		maxhealth = 200
		score = 120
		alertsound1 = 'sound/machines/engine_alert1.ogg'
		alertsound2 = 'sound/machines/engine_alert1.ogg'
		droploot = /obj/item/bang_gun
		projectile_type = /datum/projectile/bullet/akm
		current_projectile = new/datum/projectile/bullet/akm
		attack_cooldown = 20

		New()
			..()
			name = "Drone BML-[rand(1,999)]"

	raildrone // a real jerk
		name = "Syndicate Railgun Drone"
		desc = "An experimental and extremely dangerous Syndicate railgun drone."
		icon = 'icons/mob/critter/robotic/drone/railgun.dmi'
		icon_state = "drone_railgun"
		dead_state = "drone_railgun-dead"
		health = 800
		maxhealth = 800
		score = 500
		droploot = /obj/item/currency/buttcoin // replace with railgun if that's ever safe enough to hand out? idk
		attack_cooldown = 50
		smashes_shit = 1

		Shoot(var/atom/target, var/start, var/user, var/bullet = 0)
			if(target == start)
				return
			playsound(src, 'sound/effects/mag_warp.ogg', 50, TRUE)
			SPAWN(rand(1,3)) // so it might miss, sometimes, maybe
				var/obj/target_r

				if(istype(target, /obj/machinery/cruiser))
					target_r = new/obj/railgun_trg_dummy(locate(target.x+2, target.y+2, target.z))
				else
					target_r = new/obj/railgun_trg_dummy(target)

				playsound(src, 'sound/weapons/railgun.ogg', 50, TRUE)
				src.set_dir(get_dir(src, target))

				var/list/affected = drawLineObj(src, target_r, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeRailG",1,1,"HalfStartRailG","HalfEndRailG",OBJ_LAYER,1)

				for(var/obj/O in affected)
					O.anchored = ANCHORED //Proc wont spawn the right object type so lets do that here.
					O.name = "Energy"
					var/turf/src_turf = O.loc
					for(var/obj/machinery/vehicle/A in src_turf)
						if(A == O || A == user) continue
						A.meteorhit(O)
					for(var/mob/living/M in src_turf)
						if(M == O || M == user) continue
						M.meteorhit(O)
					for(var/turf/T in src_turf)
						if(T == O) continue
						T.meteorhit(O)
					for (var/obj/machinery/cruiser/C in src_turf)
						if (C == O || C == user) continue
						C.meteorhit(O)

		//			var/turf/T = O.loc
		//			for(var/atom/A in T.contents)
		//				boutput(src, "There is a [A.name] at this location.")
					SPAWN(0.3 SECONDS) qdel(O)

				if(istype(target_r, /obj/railgun_trg_dummy)) qdel(target_r)
			return

		New()
			..()
			name = "Drone X-[rand(1,999)]"

	buzzdrone
		name = "Syndicate Salvage Drone"
		desc = "A Syndicate scrap cutter drone, designed for automated salvage operations."
		icon = 'icons/mob/critter/robotic/drone/saw.dmi'
		icon_state = "drone_saw"
		dead_state = "drone_saw-dead"
		health = 200
		maxhealth = 200
		score = 20
		droploot = /obj/item/circular_saw
		projectile_type = /datum/projectile/laser/drill/cutter
		current_projectile = new/datum/projectile/laser/drill/cutter
		smashes_shit = 1
		attack_range = 1

		ChaseAttack(atom/M)
			if(target && !attacking)
				attacking = 1
				src.visible_message(SPAN_ALERT("<b>[src]</b> charges at [M]!"))
				walk_to(src, src.target,1,4)
				var/tturf = get_turf(M)
				Shoot(tturf, src.loc, src)
				SPAWN(attack_cooldown)
					attacking = 0
			return

		CritterAttack(atom/M)
			if(target && !attacking)
				attacking = 1
				//playsound(src.loc, 'sound/machines/whistlebeep.ogg', 55, 1)
				src.visible_message(SPAN_ALERT("<b>[src]</b> hits [M]!"))

				var/tturf = get_turf(M)
				Shoot(tturf, src.loc, src)
				SPAWN(attack_cooldown)
					attacking = 0
			return

		New()
			..()
			name = "Drone CR-[rand(1,999)]"

		bullet_act(var/obj/projectile/P)
			if (isobj(P.shooter))
				var/obj/O = P.shooter
				if(istype(O, /obj/critter/gunbot/drone/buzzdrone)) //No more friendly fire at melee range
					return
			..()

		fish
			name = "Syndicate Fish Drone"
			desc = "A Syndicate robo-fish. This appears to be a continuation of the scrap cutter production line made for underwater use."
			icon_state = "drone_piranha"
			dead_state = "drone_piranha-dead"
			health = 100
			maxhealth = 100
			score = 10
			droploot = /obj/item/factionrep/ntboard
			projectile_type = /datum/projectile/laser/drill/saw_teeth
			current_projectile = new/datum/projectile/laser/drill/saw_teeth
			smashes_shit = 0
			event_handler_flags = IMMUNE_MANTA_PUSH
			//TODO : TEENSY REDRAW TO ICON TO MAKE IT A LITTLE MORE ROBOTTY

			New()
				..()
				name = "FishDrone CR-[rand(1,999)]b"

			CritterDeath() //Yeah thanks for only supporting a single item, loot variable.
				if(dying)
					return
				new /obj/item/mining_tool/powered/pickaxe(get_turf(src))
				..()

	gunshark
		name = "Syndicate Gun Shark"
		desc = "A Syndicate robo-shark. Watch out for that minigun!"
		icon = 'icons/mob/critter/robotic/drone/drone64x32.dmi'
		icon_state = "gunshark"
		dead_state = "gunshark-dead"
		health = 220
		maxhealth = 220
		score = 80
		bound_height = 32
		bound_width = 64
		alertsound1 = 'sound/machines/engine_alert1.ogg'
		alertsound2 = 'sound/machines/engine_alert1.ogg'
		droploot = /obj/item/factionrep/ntboard
		projectile_type = /datum/projectile/bullet/lmg/weak
		current_projectile = new/datum/projectile/bullet/lmg/weak
		attack_cooldown = 20
		projectile_spread = 13
		event_handler_flags = IMMUNE_MANTA_PUSH

		New()
			..()
			name = "SharkDrone BML-[rand(1,999)]b"

	laserdrone
		name = "Laser Drone"
		desc = "A Syndicate drone equipped with a combat laser."
		icon = 'icons/mob/critter/robotic/drone/laser.dmi'
		icon_state = "drone_laser"
		dead_state = "drone_laser"
		health = 100
		maxhealth = 100
		score = 30
		projectile_type = /datum/projectile/laser
		current_projectile = new/datum/projectile/laser

		New()
			..()
			name = "Drone LZ-[rand(1,999)]"

	cutterdrone
		name = "Plasma Cutter Drone"
		desc = "An industrial mining drone, repurposed by Syndicate engineers for nefarious purposes."
		icon = 'icons/mob/critter/robotic/drone/cutter.dmi'
		icon_state = "drone_cutter"
		dead_state = "drone_cutter"
		health = 150
		maxhealth = 150
		score = 50
		projectile_type = /datum/projectile/laser/mining
		current_projectile = new/datum/projectile/laser/mining

		New()
			..()
			name = "Drone PC-[rand(1,999)]"

	assdrone // HEH
		name = "Breach Drone"
		desc = "A highly dangerous Syndicate drone built for extraction and sabotage operations."
		icon = 'icons/mob/critter/robotic/drone/assault.dmi'
		icon_state = "drone_assault"
		dead_state = "drone_assault"
		health = 150
		maxhealth = 150
		score = 100
		projectile_type = /datum/projectile/laser/asslaser
		current_projectile = new/datum/projectile/laser/asslaser

		New()
			..()
			name = "Drone BR-[rand(1,999)]"

	aciddrone
		name = "Acid Drone"
		desc = "This Syndicate drone is equipped with a corrosive chemical weapon. Rude!"
		icon = 'icons/mob/critter/robotic/drone/acid.dmi'
		icon_state = "drone_acid"
		dead_state = "drone_acid"
		health = 200
		maxhealth = 200
		score = 65
		projectile_type = /datum/projectile/special/acid
		current_projectile = new/datum/projectile/special/acid

		New()
			..()
			name = "Drone CA-[rand(1,999)]"


	helldrone // the worst jerk
		name = "Syndicate Command Drone"
		desc = "An enormous automated Syndicate battledrone, likely responsible for the loss of several NT facilities in this sector."
		icon = 'icons/mob/critter/robotic/drone/drone96x96.dmi'
		icon_state = "battledrone"
		dead_state = "battledrone-dead"
		bound_height = 96
		bound_width = 96
		health = 5000
		maxhealth = 5000
		score = 10000
		droploot = /obj/item/plutonium_core
		alertsound1 = 'sound/machines/engine_alert2.ogg'
		alertsound2 = 'sound/machines/engine_alert3.ogg'
		projectile_type = /datum/projectile/bullet/autocannon/plasma_orb
		current_projectile = new/datum/projectile/bullet/autocannon/plasma_orb
		attack_cooldown = 70
		smashes_shit = 1

		CritterDeath() //Yeah thanks for only supporting a single item, loot variable.
			if(dying) return
			var/area/A = get_area(src)
			if (A?.virtual)
				droploot = null
			..()

		process()
			..()
			if(prob(3))
				playsound(src, 'sound/machines/signal.ogg', 60, FALSE)
			return

		Shoot(var/target, var/start, var/user, var/bullet = 0)
			if(target == start)
				return

			src.set_dir(get_dir(src, target))

			if (!cardinal.Find(src.dir))
				return //hell drone only shoots cardinals

			var/obj/projectile/P1 =	initialize_projectile(src.loc, current_projectile, 0, 0, src)
			var/obj/projectile/P2 =	initialize_projectile(src.loc, current_projectile, 0, 0, src)

			switch(src.dir) // linked fire, directional offsets so they don't hit the ship itself // these need more work still
				if(NORTH)
					P1.yo = 96
					P1.xo = 0
					P2.yo = 96
					P2.xo = 0
					P1.set_loc(locate(src.x, src.y+2, src.z))
					P2.set_loc(locate(src.x+2,src.y+2, src.z))
					P1.orig_turf = P1.loc //our orig_turf was set in initialize_projectile() but that was before we moved it to the side of the ship
					P2.orig_turf = P2.loc
				if(EAST)
					P1.yo = 0
					P1.xo = 96
					P2.yo = 0
					P2.xo = 96
					P1.set_loc(locate(src.x+2,src.y+2,src.z))
					P2.set_loc(locate(src.x+2,src.y,src.z))
					P1.orig_turf = P1.loc
					P2.orig_turf = P2.loc
				if(WEST)
					P1.yo = 0
					P1.xo = -96
					P2.yo = 0
					P2.xo = -96
					P1.set_loc(locate(src.x,src.y, src.z))
					P2.set_loc(locate(src.x,src.y+2, src.z))
					P1.orig_turf = P1.loc
					P2.orig_turf = P2.loc
				if(SOUTH)
					P1.yo = -96
					P1.xo = 0
					P2.yo = -96
					P2.xo = 0
					P1.set_loc(locate(src.x+2,src.y, src.z))
					P2.set_loc(locate(src.x, src.y, src.z))
					P1.orig_turf = P1.loc
					P2.orig_turf = P2.loc
				else
					P1.die()
					P2.die()
					return

			SPAWN(0)
				P1.launch() // FIRE!
			SPAWN(0)
				P2.launch()

		New()
			..()
			name = "Battledrone Omega-[rand(1,10)]"
			return

ABSTRACT_TYPE(/obj/gunbotdrone_spawner)
/obj/gunbotdrone_spawner
	name = "gunbot drone spawner"
	var/list/possible_drones = null

	New()
		..()
		var/obj/critter/gunbot/drone/drone = weighted_pick(src.possible_drones)
		drone = new drone(get_turf(src))
		qdel(src)

/obj/gunbotdrone_spawner/common
	icon = 'icons/mob/critter/robotic/drone/phaser.dmi'
	icon_state = "drone_phaser"
	possible_drones = list(/obj/critter/gunbot/drone = 90,
						   /obj/critter/gunbot/drone/buzzdrone = 100,
						   /obj/critter/gunbot/drone/laserdrone = 5)

/obj/gunbotdrone_spawner/uncommon
	icon = 'icons/mob/critter/robotic/drone/laser.dmi'
	icon_state = "drone_laser"
	possible_drones = list(/obj/critter/gunbot/drone/laserdrone = 100,
						   /obj/critter/gunbot/drone/heavydrone = 75,
						   /obj/critter/gunbot/drone/minigundrone = 5)

/obj/gunbotdrone_spawner/rare
	icon = 'icons/mob/critter/robotic/drone/ballistic.dmi'
	icon_state = "drone_ballistic"
	possible_drones = list(/obj/critter/gunbot/drone/minigundrone = 100)

TYPEINFO(/obj/critter/gunbot/drone/iridium)
	mats = null //no

/obj/critter/gunbot/drone/iridium // the worstest jerk, even worse than the previous worst jerk.
	name = "Y-Class Battledrone"
	desc = "One of the prototype battledrones from the Syndicate's PROJECT IRIDIUM, utilizing adapted artifact technologies."
	health = 6000
	maxhealth = 6000
	icon = 'icons/mob/critter/robotic/drone/drone96x96.dmi'
	dead_state = "ydrone-dead"
	icon_state = "ydrone"
	bound_height = 96
	bound_width = 96
	score = 10000
	droploot = /obj/item/device/key/iridium
	alertsound1 = 'sound/machines/engine_alert2.ogg'
	alertsound2 = 'sound/machines/engine_alert3.ogg'
	projectile_type = /datum/projectile/laser/precursor/sphere
	current_projectile = new/datum/projectile/laser/precursor/sphere
	smashes_shit = 1
	attack_cooldown = 70
	process()
		..()
		if(prob(3))
			playsound(src, 'sound/machines/signal.ogg', 60, FALSE)

		return


	Shoot(var/target, var/start, var/user, var/bullet = 0)
		if(target == start)
			return

		if (prob(10))
			elec_zap()

		/*
		var/obj/projectile/A = new /obj/projectile
		if(!A)	return
		A.set_loc(src.loc)
		A.projectile = new current_projectile.type
		A.projectile.master = A
		A.set_icon()
		if(src.current_projectile.shot_sound)
			playsound(src, src.current_projectile.shot_sound, 60)


		if(!A)	return

		if (!istype(target, /turf))
			A.die()
			return
		A.target = target
		A.yo = target:y - start:y
		A.xo = target:x - start:x
		src.set_dir(get_dir(src, target))
		SPAWN( 0 )
			A.process()
		return */

		src.set_dir(get_dir(src, target))

		var/obj/projectile/P1 = initialize_projectile(src.loc, current_projectile, 0, 0, src)
		var/obj/projectile/P2 = initialize_projectile(src.loc, current_projectile, 0, 0, src)

		switch(src.dir) // linked fire, directional offsets so they don't hit the ship itself // these need more work still
			if(NORTH)
				P1.yo = 96
				P1.xo = 0
				P2.yo = 96
				P2.xo = 0
				P1.set_loc(locate(src.x, src.y+2, src.z))
				P2.set_loc(locate(src.x+2,src.y+2, src.z))
				P1.orig_turf = P1.loc //our orig_turf was set in initialize_projectile() but that was before we moved it to the side of the ship
				P2.orig_turf = P2.loc
			if(EAST, NORTHEAST, SOUTHEAST)
				switch(src.dir)
					if(NORTHEAST)
						P1.yo = 96
						P1.xo = 96
						P2.yo = 96
						P2.xo = 96
					if(SOUTHEAST)
						P1.yo = -96
						P1.xo = 96
						P2.yo = -96
						P2.xo = 96
					else
						P1.yo = 0
						P1.xo = 96
						P2.yo = 0
						P2.xo = 96
				P1.set_loc(locate(src.x+2,src.y+2,src.z))
				P2.set_loc(locate(src.x+2,src.y,src.z))
				P1.orig_turf = P1.loc
				P2.orig_turf = P2.loc
			if(WEST, NORTHWEST, SOUTHWEST)
				switch(src.dir)
					if(NORTHWEST)
						P1.yo = 96
						P1.xo = -96
						P2.yo = 96
						P2.xo = -96
					if(SOUTHWEST)
						P1.yo = -96
						P1.xo = -96
						P2.yo = -96
						P2.xo = -96
					else
						P1.yo = 0
						P1.xo = -96
						P2.yo = 0
						P2.xo = -96
				P1.set_loc(locate(src.x,src.y, src.z))
				P2.set_loc(locate(src.x,src.y+2, src.z))
				P1.orig_turf = P1.loc
				P2.orig_turf = P2.loc
			if(SOUTH)
				P1.yo = -96
				P1.xo = 0
				P2.yo = -96
				P2.xo = 0
				P1.set_loc(locate(src.x+2,src.y, src.z))
				P2.set_loc(locate(src.x, src.y, src.z))
				P1.orig_turf = P1.loc
				P2.orig_turf = P2.loc
			else
				P1.die()
				P2.die()
				return

		SPAWN(0)
			P1.launch()
		SPAWN(0)
			P2.launch()

	proc/elec_zap()
		playsound(src, 'sound/effects/elec_bigzap.ogg', 40, TRUE)

		var/list/lineObjs
		for (var/mob/living/poorSoul in range(src, 5))
			lineObjs += drawLineObj(src, poorSoul, /obj/line_obj/elec, 'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",FLY_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

			poorSoul.playsound_local_not_inworld('sound/effects/electric_shock.ogg', 50)
			random_burn_damage(poorSoul, 45)
			boutput(poorSoul, SPAN_ALERT("<B>You feel a powerful shock course through your body!</B>"))
			poorSoul.unlock_medal("HIGH VOLTAGE", 1)
			poorSoul:Virus_ShockCure(100)
			poorSoul:shock_cyberheart(100)
			poorSoul:changeStatus("knockdown", 4 SECONDS)
			if (isdead(poorSoul) && prob(25))
				poorSoul.gib()

		for (var/obj/machinery/vehicle/poorPod in range(src, 5))
			lineObjs += drawLineObj(src, poorPod, /obj/line_obj/elec, 'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",FLY_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

			playsound(poorPod.loc, 'sound/effects/elec_bigzap.ogg', 40, 0)
			poorPod.ex_act(3)

		for (var/obj/machinery/cruiser/C in range(src, 5))
			lineObjs += drawLineObj(src, C, /obj/line_obj/elec, 'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",FLY_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')
			playsound(C.loc, 'sound/effects/elec_bigzap.ogg', 40, 0)
			C.ex_act(3)

		SPAWN(0.6 SECONDS)
			for (var/obj/O in lineObjs)
				qdel(O)

	New()
		..()

		//name = "X Æ Y-[rand(10,15)]" //lmfao
		name = "Battledrone Y-[rand(1,5)]"


	CritterDeath() //Yeah thanks for only supporting a single item, loot variable.
		if(dying) return
		var/area/A = get_area(src)
		if (A?.virtual)
			droploot = /obj/item/device/key/virtual
		else
			new/obj/item/material_piece/iridiumalloy(src.loc)
			new/obj/item/material_piece/iridiumalloy(src.loc)
			new/obj/item/material_piece/iridiumalloy(src.loc)
		..()

/obj/critter/gunbot/drone/iridium/whydrone
	name = "Battledronì4?½&?aÄ ÏbçÇ~¥D??õ®×³?£"
	desc = "Run."
	health = 5000
	maxhealth = 5000 // per stage
	var/stage = 0
	icon = 'icons/mob/critter/robotic/drone/drone96x96.dmi'
	icon_state = "ydrone"
	dead_state = "ydrone-dead"
	bound_height = 96
	bound_width = 96
	attack_range = 7
	score = 1500
	droploot = /obj/item/device/key/iridium
	alertsound1 = 'sound/machines/glitch3.ogg'
	alertsound2 = 'sound/machines/glitch3.ogg'
	projectile_type = /datum/projectile/bullet/autocannon/huge
	current_projectile = new/datum/projectile/bullet/autocannon/huge
	var/datum/projectile/sphere_projectile = new/datum/projectile/laser/precursor/sphere
	generic = 0
	smashes_shit = 1

	New()
		..()
		name = "Battledronì4?½&?aÄ ÏbçÇ~¥D??õ®×³?£-[rand(1,5)]"

	// copied and modified to fuck from the Y-drone, murder me
	Shoot(var/target, var/start, var/user, var/bullet = 0)
		if(target == start)
			return

		if (prob(50))
			elec_zap()

		src.set_dir(get_dir(src, target))

		var/obj/projectile/sphere = initialize_projectile(src.loc, sphere_projectile, 0, 0, src)

		switch(src.dir)
			if(NORTH)
				sphere.yo = 96
				sphere.xo = 0
				sphere.set_loc(locate(src.x+1, src.y+2, src.z))
				sphere.orig_turf = sphere.loc
			if(EAST)
				sphere.yo = 0
				sphere.xo = 96
				sphere.set_loc(locate(src.x+2,src.y+1,src.z))
				sphere.orig_turf = sphere.loc
			if(WEST)
				sphere.yo = 0
				sphere.xo = -96
				sphere.set_loc(locate(src.x,src.y+1, src.z))
				sphere.orig_turf = sphere.loc
			else
				sphere.yo = -96
				sphere.xo = 0
				sphere.set_loc(locate(src.x+1,src.y, src.z))
				sphere.orig_turf = sphere.loc

		SPAWN(0)
			sphere.launch()

		if (bounds_dist(src, target) >= 2*32) // dont murder ourself with explosives
			var/obj/projectile/P1 = initialize_projectile(src.loc, current_projectile, sphere.xo, sphere.yo, src)
			var/obj/projectile/P2 = initialize_projectile(src.loc, current_projectile, sphere.xo, sphere.yo, src)
			P1.set_loc(sphere.loc)
			P2.set_loc(sphere.loc)
			P1.orig_turf = P1.loc
			P2.orig_turf = P2.loc

			SPAWN(0)
				P1.launch()
			SPAWN(0)
				P2.launch()


	/*proc/elec_zap()
		playsound(src, 'sound/effects/elec_bigzap.ogg', 40, TRUE)

		var/list/lineObjs
		for (var/mob/living/poorSoul in range(src, 5))
			lineObjs += drawLineObj(src, poorSoul, /obj/line_obj/elec, 'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",FLY_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

			poorSoul.playsound_local_not_inworld('sound/effects/electric_shock.ogg', 50)
			random_burn_damage(poorSoul, 45)
			boutput(poorSoul, SPAN_ALERT("<B>You feel a powerful shock course through your body!</B>"))
			poorSoul.unlock_medal("HIGH VOLTAGE", 1)
			poorSoul:Virus_ShockCure(100)
			poorSoul:shock_cyberheart(100)
			poorSoul:weakened += rand(3,5)
			if (isdead(poorSoul) && prob(25))
				poorSoul.gib()

		for (var/obj/machinery/vehicle/poorPod in range(src, 5))
			lineObjs += drawLineObj(src, poorPod, /obj/line_obj/elec, 'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",FLY_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

			playsound(poorPod.loc, 'sound/effects/elec_bigzap.ogg', 40, 0)
			poorPod.ex_act(3)

		SPAWN(0.6 SECONDS)
			for (var/obj/O in lineObjs)
				qdel(O)*/

/obj/critter/gunbot/drone/iridium/whydrone/horse
	name = "Horseman"
	desc = "What the hell is this thing!? Oh God, is that a MOUTH?"
	health = 5000
	maxhealth = 5000
	icon = 'icons/mob/critter/robotic/drone/drone96x96.dmi'
	icon_state = "horsedrone"
	dead_state = "horsedrone-dead"
	bound_height = 96
	bound_width = 96
	attack_range = 14
	score = 45000
	droploot = /obj/item/clothing/mask/horse_mask/cursed
	beeptext = "neighs"
	beepsound = 'sound/vox/na.ogg' //how is nay or neigh not a thing in vox?
	alertsound1 = 'sound/effects/mag_pandroar.ogg'
	alertsound2 = 'sound/voice/animal/brullbar_roar.ogg'
	projectile_type = /datum/projectile/bullet/autocannon/huge
	current_projectile = new/datum/projectile/bullet/autocannon/huge
	sphere_projectile = new/datum/projectile/laser/precursor/sphere
	generic = 0
	smashes_shit = 1

	process()
		..()
		if(prob(3))
			playsound(src,'sound/effects/heartbeat.ogg', 60, FALSE) //for the spooky effect
		return

	New()
		..()
		name = "[pick("War", "Death", "Pestilence", "Famine")]"

	ex_act(severity)
		return //immune to our own explosions

	check_health()
		..()
		if(health == maxhealth) return
		var/percent_damage = src.health/src.maxhealth * 100
		switch(percent_damage)
			if(75 to 100)
				return
			if(50 to 74)
				if(damaged == 1) return
				damaged = 1
				desc = "[src] looks lightly [pick("injured", "hurt", "bruised", "cut")]."
			if(25 to 49)
				if(damaged == 2) return
				damaged = 2
				desc = "[src] looks [pick("quite", "pretty", "rather")] [pick("injured", "wounded", "messed up", "beaten up", "hurt", "haggard")]."
			if(0 to 24)
				if(damaged == 3) return
				damaged = 3
				desc = "[src] looks [pick("really", "totally", "very", "all sorts of", "super", "grievously")] [pick("mangled", "wounded", "messed up", "injured", "hurt", "haggard", "beaten down", "bloodied")]."
		return

	CritterDeath() //Yeah thanks for only supporting a single item, loot variable.
		if(dying) return
		var/area/A = get_area(src)
		if (A?.virtual)
			droploot = /obj/item/device/key/virtual //we don't want this loot in vr do we???
		else
			new/obj/item/instrument/fiddle(src.loc)
			new/obj/item/instrument/trumpet/dootdoot(src.loc)
			new/obj/item/rubber_hammer(src.loc)
			new/obj/item/instrument/bagpipe(src.loc)
			new/obj/item/storage/belt/macho_belt(src.loc)
			new/obj/item/stimpack/large_dose(src.loc)
			new/obj/item/stimpack/large_dose(src.loc)
			new/obj/item/stimpack/large_dose(src.loc)
			new/obj/item/stimpack/large_dose(src.loc)
			new/obj/item/stimpack/large_dose(src.loc)
		..()


TYPEINFO(/obj/critter/gunbot/drone/miniature_syndie)
	mats = 12 //this should be funny

/obj/critter/gunbot/drone/miniature_syndie
	name = "miniature Syndicate Operative"
	desc = "They look determined."
	icon = 'icons/mob/critter/humanoid/mini_syndies.dmi'
	icon_state = "minisyndie"
	density = 1
	health = 8
	maxhealth = 8
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 1
	atcritter = 0
	firevuln = 0.5
	brutevuln = 1
	miscvuln = 0
	luminosity = 0
	seekrange = 15
	flying = 1
	dead_state = "minisyndie-dead"
	beeptext = "prepares to finish the fight!"
	beepsound = 0
	alertsound1 = 0
	var/bulletcount = 0
	alertsound2 = 0
	projectile_type = /datum/projectile/bullet/bullet_22
	current_projectile = new/datum/projectile/bullet/bullet_22
	attack_cooldown = 20

	var/voice_gender = "male"

	New()
		..()
		voice_gender = pick("male","female")
		name = "miniature Syndicate Operative"
		bulletcount = rand(4, 6) // don't give them too many bullets!


	select_target(var/atom/newtarget)
		..()
		playsound(src, (voice_gender == "male" ? 'sound/voice/screams/male_scream.ogg' : 'sound/voice/screams/female_scream.ogg'), 40, 1, 0.1, 3, channel=VOLUME_CHANNEL_EMOTE)

	ex_act(severity)
		return

	CritterDeath()
		if(dying) return
		playsound(src, 'sound/voice/farts/poo2.ogg', 40, TRUE, 0.1, 3, channel=VOLUME_CHANNEL_EMOTE)
		icon_state = dead_state
		SPAWN(0.5 SECONDS)// for the dramatic effect
			explosion(src, get_turf(src), -1, -1, 2, 3)
		..()

	Shoot(var/target, var/start, var/user, var/bullet = 0)
		..()
		bulletcount--
		if(bulletcount<=0)// out of ammo? bedtime
			SPAWN(0.5 SECONDS)
				src.visible_message("[src] runs out of ammo!")
				task = "sleeping"
				src.health = 0
				src.CritterDeath()

/obj/critter/gunbot/drone/miniature_syndie/robust
	New()
		. = ..()
		src.bulletcount = INFINITY
		src.maxhealth = 40
		src.health = 40
		projectile_type = /datum/projectile/bullet/revolver_38/nuke_safe
		current_projectile = new/datum/projectile/bullet/revolver_38/nuke_safe

/datum/projectile/bullet/revolver_38/nuke_safe
	get_power(obj/projectile/P, atom/A)
		. = ..()
		if(istype(A, /obj/machinery/nuclearbomb) || istype(A, /obj/critter/gunbot/drone/miniature_syndie/robust))
			. = 0
