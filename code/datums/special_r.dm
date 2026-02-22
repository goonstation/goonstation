
datum/special_respawn
//	var/list/dead = list()
	var/mob/dead/observer/target

	proc/find_player(var/type = "an unknown", var/require_client)
		var/list/eligible = dead_player_list(require_client = require_client)

		if (!eligible.len)
			return 0
		target = eligible[1]

		if(target)
			target.respawning = 1
//			boutput(target, text("You have been picked to come back into play as [type], enter your new body now."))
			return target
		else
			return 0

	proc/find_player_any(var/type = "an unknown", var/require_client)
		var/list/eligible = dead_player_list(allow_dead_antags = 1, require_client = require_client)

		if (!eligible.len)
			return 0
		target = eligible[1]

		if(target)
			target.respawning = 1
//			boutput(target, text("You have been picked to come back into play as [type], enter your new body now."))
			return target
		else
			return 0

	proc/spawn_syndies(var/number = 3)
		var/r_number = 0
		var/B = pick_landmark(LANDMARK_SYNDICATE)

		if(!B)	return
		for(var/c = 0, c < number, c++)
			var/player = find_player("a syndicate agent", TRUE)
			if(player)
				var/check = spawn_character_human("[syndicate_name()] Operative #[c+1]", player, pick_landmark(LANDMARK_SYNDICATE), "syndie")
				if(!check)
					break
				r_number ++
				SPAWN(5 SECONDS)
					if(player && !player:client)
						qdel(player)

		new /obj/storage/closet/syndicate/nuclear(pick_landmark(LANDMARK_NUCLEAR_CLOSET))
		for(var/turf/T in landmarks[LANDMARK_SYNDICATE_GEAR_CLOSET])
			new /obj/storage/closet/syndicate/personal(T)
		for(var/turf/T in landmarks[LANDMARK_SYNDICATE_BOMB])
		new /obj/spawner/newbomb/timer/syndicate(pick_landmark(LANDMARK_SYNDICATE_BOMB))
		for(var/turf/T in landmarks[LANDMARK_SYNDICATE_BREACHING_CHARGES])
			for(var/i = 1 to 5)
				new /obj/item/breaching_charge/thermite(T)

		message_admins("[r_number] syndicate agents spawned at Syndicate Station.")
		return

	proc/spawn_normal(var/number = 3, var/include_antags = 0, var/strip_antag = 0)
		var/r_number = 0
		var/mob/player = null
		for(var/c = 0, c < number, c++)
			if(include_antags)
				player = src.find_player_any("a person", TRUE)
			else
				player = src.find_player("a person", TRUE)
			if(player)
				var/mob/living/carbon/human/normal/M = new/mob/living/carbon/human/normal(pick_landmark(LANDMARK_LATEJOIN))
				if(!player.mind)
					player.mind = new (player)
				player.mind.transfer_to(M)
				//M.ckey = player:ckey

				if(strip_antag)
					M.mind?.wipe_antagonists()
				r_number ++
				SPAWN(5 SECONDS)
					if(player && !player:client)
						qdel(player)
			else
				break
		message_admins("[r_number] players spawned.")

	proc/spawn_as_job(var/number = 3, var/datum/job/job, var/include_antags = 0, var/strip_antag = 0)
		var/r_number = 0
		var/mob/player = null
		for(var/c = 0, c < number, c++)
			if(include_antags)
				player = src.find_player_any("a person", TRUE)
			else
				player = src.find_player("a person", TRUE)
			if(player)
				var/mob/living/carbon/human/normal/M = new/mob/living/carbon/human/normal(pick_landmark(LANDMARK_LATEJOIN))
				SPAWN(0)
					M.JobEquipSpawned(job.name)

				if(!player.mind)
					player.mind = new (player)
				player.mind.transfer_to(M)

				if(strip_antag)
					M.mind?.wipe_antagonists()
				r_number ++
				SPAWN(5 SECONDS)
					if(player && !player:client)
						qdel(player)
			else
				break
		message_admins("[r_number] players spawned.")

	proc/spawn_custom(var/blType, var/number = 3)
		var/r_number = 0
		for(var/c = 0, c < number, c++)
			var/mob/player = find_player("a person", TRUE)
			if(player)
				var/mob/M = new blType(pick_landmark(LANDMARK_LATEJOIN))
				if(!player.mind)

					player.mind = new (player)
				player.mind.transfer_to(M)

				//M.ckey = player:ckey
				r_number++
				SPAWN(rand(1,10))
					M.set_clothing_icon_dirty()
				SPAWN(5 SECONDS)
					if(player && !player:client)
						qdel(player)
			else
				break
		message_admins("[r_number] players spawned.")

	proc/spawn_character_human(var/rname = "Unknown", var/mob/player = null, var/obj/spawn_landmark = null,var/equip = "none")
		if(!player||!spawn_landmark)
			return 0
		var/mob/living/carbon/human/mob

		if(rname == "The Smiling Man")
			mob = new /mob/living/carbon/human(spawn_landmark.loc)
			mob.equip_if_possible(new /obj/item/device/radio/headset(mob), SLOT_EARS)
			mob.equip_if_possible(new /obj/item/clothing/under/suit/pinstripe(mob), SLOT_W_UNIFORM)
			mob.equip_if_possible(new /obj/item/clothing/shoes/black(mob), SLOT_SHOES)
			var/obj/item/clothing/gloves/latex/gloves = new /obj/item/clothing/gloves/latex
			gloves.name = "Kidskin Gloves"
			mob.equip_if_possible(gloves, SLOT_GLOVES)
			mob.equip_if_possible(new /obj/item/clothing/mask/smile(mob), SLOT_WEAR_MASK)
			mob.equip_if_possible(new /obj/item/dagger/smile(mob), SLOT_R_HAND)
			for (var/obj/item/O in mob.contents)
				O.cant_other_remove = 1
				O.cant_self_remove = 1
			mob.nodamage = 1
			mob.bioHolder.AddEffect("xray", 2)
			mob.verbs += /client/proc/noclip
			mob.bioHolder.AddEffect("accent_smiling")
		else
			mob = new /mob/living/carbon/human/normal(spawn_landmark)
		mob.real_name = rname

		if(!player.mind)
			player.mind = new (player)
		player.mind.transfer_to(mob)

		/*
		mob.mind = new
		mob.mind.key = player.key
		mob.mind.current = player

		//mob.key = player.key
		^*/
		mob.mind.special_role = equip
		SPAWN(0.5 SECONDS)
			if (mob)
				eq_mob(equip,mob)
				mob.set_clothing_icon_dirty()
		return 1

	proc/eq_mob(var/type, var/mob/living/carbon/human/user)
		if(!type) return
		switch(type)
			if("commando")
				user.equip_new_if_possible(/obj/item/clothing/under/color/red, SLOT_W_UNIFORM)
				user.equip_new_if_possible(/obj/item/clothing/suit/armor/vest, SLOT_WEAR_SUIT)
				user.equip_new_if_possible(/obj/item/clothing/head/helmet, SLOT_HEAD)
				user.equip_new_if_possible(/obj/item/clothing/shoes/brown, SLOT_SHOES)
				user.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, SLOT_GLASSES)
				user.equip_new_if_possible(/obj/item/handcuffs, SLOT_IN_BACKPACK)
				user.equip_new_if_possible(/obj/item/handcuffs, SLOT_IN_BACKPACK)
				user.equip_new_if_possible(/obj/item/baton, SLOT_BELT)
				user.equip_new_if_possible(/obj/item/device/flash, SLOT_L_STORE)
				user.equip_new_if_possible(/obj/item/device/radio/headset/security, SLOT_EARS)
				//var/obj/item/implant/sec/S = new /obj/item/implant/sec(user)
				//S.implanted = 1
				//S.implanted(user)
				//S.owner = user
				//user.implant.Add(S)

			if ("T.U.R.D.S.")
				var/obj/item/device/radio/R = new /obj/item/device/radio/headset/security(user)
				user.equip_if_possible(R, SLOT_EARS)
				user.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(user), SLOT_GLASSES)
				user.equip_if_possible(new /obj/item/clothing/gloves/black(user), SLOT_GLOVES)
				user.equip_if_possible(new /obj/item/clothing/head/helmet/turd(user), SLOT_HEAD)
				user.equip_if_possible(new /obj/item/clothing/shoes/swat(user), SLOT_SHOES)
				user.equip_if_possible(new /obj/item/clothing/suit/armor/turd(user), SLOT_WEAR_SUIT)
				user.equip_if_possible(new /obj/item/clothing/under/misc/turds(user), SLOT_W_UNIFORM)
				user.equip_if_possible(new /obj/item/storage/backpack(user), SLOT_BACK)
//				user.equip_if_possible(new /obj/item/gun/fiveseven(user), SLOT_IN_BACKPACK)
//				user.equip_if_possible(new /obj/item/gun/shotgun(user), SLOT_R_HAND)
//				user.equip_if_possible(new /obj/item/gun/mp5(user), SLOT_L_HAND)
//				user.equip_if_possible(new /obj/item/ammo/a57(user), SLOT_IN_BACKPACK)
				//var/obj/item/implant/sec/S = new /obj/item/implant/sec(user)
				//S.implanted = 1
				//S.implanted(user)
				//S.owner = src
				//user.implant.Add(S)

			else
				return


/proc/bust_lights()
	for(var/i in 1 to PROCESSING_MAX_IN_USE) // oh boy
		for(var/list/machines_list in processing_machines[i])
			for(var/obj/machinery/light_area_manager/LAM in machines_list)
				for(var/obj/machinery/light/lights in LAM.lights)
					if(prob(70))
						lights.on = 0
						lights.status = LIGHT_BROKEN
						lights.update()
	for(var/obj/machinery/power/apc/apcs in machine_registry[MACHINES_POWER])
		if(prob(65))
			apcs.cell.charge-=20
	return

/proc/creepify_station()
	var/counter = 0
	for(var/turf/T in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
		if(istype(T, /turf/simulated/floor))
			var/turf/simulated/floor/F = T
			if (was_eaten)
				F.icon = 'icons/turf/floors.dmi'
				F.icon_state = "bloodfloor_2"
				F.name = "fleshy floor"
			else
				if(prob(75))
					F.to_plating()
				if(prob(75))
					F.break_tile()
				else if(prob(90))
					F.burn_tile()
		else if(istype(T, /turf/simulated/wall))
			var/turf/simulated/wall/W = T
			if (was_eaten)
				W.icon = 'icons/misc/meatland.dmi'
				W.icon_state = "bloodwall_2"
				W.name = "meaty wall"
				if(istype(W, /turf/simulated/wall/auto))
					var/turf/simulated/wall/auto/WA = W
					WA.mod = "meatier-"
			else
				var/overlay
				if(istype(W,/turf/simulated/wall/auto/supernorn) || istype(W,/turf/simulated/wall/auto/reinforced/supernorn))
					overlay = image('icons/turf/walls/damage.dmi',"burn-[W.icon_state]")
				W.UpdateOverlays(overlay,"burn")
		if(counter++ % 300 == 0)
			LAGCHECK(LAG_MED)
