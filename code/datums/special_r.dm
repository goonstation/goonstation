
datum/special_respawn
//	var/list/dead = list()
	var/mob/dead/observer/target

	proc/find_player(var/type = "an unknown")
		var/list/eligible = dead_player_list()

		if (!eligible.len)
			return 0
		target = pick(eligible)

		if(target)
			target.respawning = 1
//			boutput(target, text("You have been picked to come back into play as [type], enter your new body now."))
			return target
		else
			return 0

	proc/find_player_any(var/type = "an unknown")
		var/list/eligible = dead_player_list(allow_dead_antags = 1)

		if (!eligible.len)
			return 0
		target = pick(eligible)

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
			var/player = find_player("a syndicate agent")
			if(player)
				var/check = spawn_character_human("[syndicate_name()] Operative #[c+1]", player, pick_landmark(LANDMARK_SYNDICATE), "syndie")
				if(!check)
					break
				r_number ++
				SPAWN_DBG(5 SECONDS)
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
				player = src.find_player_any("a person")
			else
				player = src.find_player("a person")
			if(player)
				var/mob/living/carbon/human/normal/M = new/mob/living/carbon/human/normal(pick_landmark(LANDMARK_LATEJOIN))
				if(!player.mind)
					player.mind = new (player)
				player.mind.transfer_to(M)
				//M.ckey = player:ckey

				if(strip_antag)
					remove_antag(M, usr, 1, 1)
				r_number ++
				SPAWN_DBG(5 SECONDS)
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
				player = src.find_player_any("a person")
			else
				player = src.find_player("a person")
			if(player)
				var/mob/living/carbon/human/normal/M = new/mob/living/carbon/human/normal(pick_landmark(LANDMARK_LATEJOIN))
				SPAWN_DBG(0)
					M.JobEquipSpawned(job.name)

				if(!player.mind)
					player.mind = new (player)
				player.mind.transfer_to(M)

				if(strip_antag)
					remove_antag(M, usr, 1, 1)
				r_number ++
				SPAWN_DBG(5 SECONDS)
					if(player && !player:client)
						qdel(player)
			else
				break
		message_admins("[r_number] players spawned.")

	proc/spawn_custom(var/blType, var/number = 3)
		var/r_number = 0
		for(var/c = 0, c < number, c++)
			var/mob/player = find_player("a person")
			if(player)
				var/mob/M = new blType(pick_landmark(LANDMARK_LATEJOIN))
				if(!player.mind)

					player.mind = new (player)
				player.mind.transfer_to(M)

				//M.ckey = player:ckey
				r_number++
				SPAWN_DBG(rand(1,10))
					M.set_clothing_icon_dirty()
				SPAWN_DBG(5 SECONDS)
					if(player && !player:client)
						qdel(player)
			else
				break
		message_admins("[r_number] players spawned.")

/*
	proc/spawn_commandos(var/number = 3)
		var/r_number = 0
		var/obj/landmark/B
		for (var/obj/landmark/A in landmarks)//world)
			if (A.name == "SR commando")
				B = A
		for(var/c = 0, c < number, c++)
			var/player = find_player("a commando")
			if(player)
				var/check = spawn_character_human("Central Command Officer #[c+1]",player,B,"commando")
				if(!check)
					break
				r_number ++
				SPAWN_DBG(5 SECONDS)
					if(player && !player:client)
						qdel(player)
		message_admins("[r_number] officers spawned.")
		return


	proc/spawn_aliens(var/number = 1,var/location = null)
		if(!location)
			return 0

		for(var/c = 0, c < number, c++)
			var/player = find_player("an alien")
			if(player)
				var/check = spawn_character_alien(player,location)
				if(!check)
					break
				SPAWN_DBG(5 SECONDS)
					if(player && !player:client)
						qdel(player)
				return 1
		return 0


	proc/spawn_turds(var/number = 5)
		boutput(src, "The TURDS ship is gone, so no.")
		return//No the ship is gone
		var/r_number = 0
		var/obj/landmark/B
		var/commander = 0
		for (var/obj/landmark/A in landmarks)//world)
			if (A.name == "SR Turds-Spawn")
				B = A

		if(!B)	return
		for(var/c = 0, c < number, c++)
			var/player = find_player("a T.U.R.D.S. Commando")
			if(player)
				var/check = 0
				if(!commander)
					check = spawn_character_human("T.U.R.D.S. Commander",player,B,"T.U.R.D.S.")
					commander = 1
				else
					check = spawn_character_human("T.U.R.D.S. Commando #[c+1]",player,B,"T.U.R.D.S.")
				if(!check)
					break
				r_number ++
				SPAWN_DBG(5 SECONDS)
					if(player && !player:client)
						qdel(player)

		message_admins("[r_number] T.U.R.D.S. Commandos spawned.")
		return

	proc/spawn_smilingman(var/number = 1)
		var/list/landlist = new/list()
		var/obj/landmark/B
		for (var/obj/landmark/A in landmarks)//world)
			if (A.name == "SR Welder")
				landlist.Add(A)
		B = pick(landlist)
		if(!B)	return
		var/player = input(usr,"Who?","Spawn Smiling Man",) as mob in world
		if(player)
			var/check = 0
			check = spawn_character_human("The Smiling Man",player,B,"Smiling Man")
			if(!check)
				return
			SPAWN_DBG(5 SECONDS)
				if(player && !player:client)
					qdel(player)

			message_admins("A Smiling Man has spawned.")
*/

	proc/spawn_character_human(var/rname = "Unknown", var/mob/player = null, var/obj/spawn_landmark = null,var/equip = "none")
		if(!player||!spawn_landmark)
			return 0
		var/mob/living/carbon/human/mob

		if(rname == "The Smiling Man")
			mob = new /mob/living/carbon/human(spawn_landmark.loc)
			mob.equip_if_possible(new /obj/item/device/radio/headset(mob), mob.slot_ears)
			mob.equip_if_possible(new /obj/item/clothing/under/suit/pinstripe(mob), mob.slot_w_uniform)
			mob.equip_if_possible(new /obj/item/clothing/shoes/black(mob), mob.slot_shoes)
			var/obj/item/clothing/gloves/latex/gloves = new /obj/item/clothing/gloves/latex
			gloves.name = "Kidskin Gloves"
			mob.equip_if_possible(gloves, mob.slot_gloves)
			mob.equip_if_possible(new /obj/item/clothing/mask/smile(mob), mob.slot_wear_mask)
			mob.equip_if_possible(new /obj/item/dagger/smile(mob), mob.slot_r_hand)
			for (var/obj/item/O in mob.contents)
				O.cant_other_remove = 1
				O.cant_self_remove = 1
			mob.nodamage = 1
			mob.bioHolder.AddEffect("xray")
			mob.verbs += /client/proc/smnoclip
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
		SPAWN_DBG(0.5 SECONDS)
			if (mob)
				eq_mob(equip,mob)
				mob.set_clothing_icon_dirty()
		return 1


/*
	proc/spawn_character_alien(var/mob/player = null, var/spawn_landmark = null)
		if(!player)
			return 0

		var/mob/living/carbon/alien/larva/mob = new /mob/living/carbon/alien/larva(spawn_landmark)

		player.client.mob = mob

		mob.mind = new
		// drsingh attempted fix for Cannot read null.key
		if (player != null) mob.mind.key = player.key
		mob.mind.current = player
		mob.key = mob.mind.key
		mob.mind.special_role = "alien"

		return 1
*/
/*
Note:

Wouldn't client.mob not be easier for this?

EndNote

		mob.mind = new
		mob.mind.key = player.key
		mob.mind.current = player
		mob.key = player.key
		return 1
*/

	proc/eq_mob(var/type, var/mob/living/carbon/human/user)
		if(!type) return
		switch(type)

			if("syndie")
				equip_syndicate(user)
				return
			if("commando")
				user.equip_new_if_possible(/obj/item/clothing/under/color/red, user.slot_w_uniform)
				user.equip_new_if_possible(/obj/item/clothing/suit/armor/vest, user.slot_wear_suit)
				user.equip_new_if_possible(/obj/item/clothing/head/helmet, user.slot_head)
				user.equip_new_if_possible(/obj/item/clothing/shoes/brown, user.slot_shoes)
				user.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, user.slot_glasses)
				user.equip_new_if_possible(/obj/item/handcuffs, user.slot_in_backpack)
				user.equip_new_if_possible(/obj/item/handcuffs, user.slot_in_backpack)
				user.equip_new_if_possible(/obj/item/baton, user.slot_belt)
				user.equip_new_if_possible(/obj/item/device/flash, user.slot_l_store)
				user.equip_new_if_possible(/obj/item/device/radio/headset/security, user.slot_ears)
				//var/obj/item/implant/sec/S = new /obj/item/implant/sec(user)
				//S.implanted = 1
				//S.implanted(user)
				//S.owner = user
				//user.implant.Add(S)

			if ("T.U.R.D.S.")
				var/obj/item/device/radio/R = new /obj/item/device/radio/headset/security(user)
				user.equip_if_possible(R, user.slot_ears)
				user.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(user), user.slot_glasses)
				user.equip_if_possible(new /obj/item/clothing/gloves/black(user), user.slot_gloves)
				user.equip_if_possible(new /obj/item/clothing/head/helmet/turd(user), user.slot_head)
				user.equip_if_possible(new /obj/item/clothing/shoes/swat(user), user.slot_shoes)
				user.equip_if_possible(new /obj/item/clothing/suit/armor/turd(user), user.slot_wear_suit)
				user.equip_if_possible(new /obj/item/clothing/under/misc/turds(user), user.slot_w_uniform)
				user.equip_if_possible(new /obj/item/storage/backpack(user), user.slot_back)
//				user.equip_if_possible(new /obj/item/gun/fiveseven(user), user.slot_in_backpack)
//				user.equip_if_possible(new /obj/item/gun/shotgun(user), user.slot_r_hand)
//				user.equip_if_possible(new /obj/item/gun/mp5(user), user.slot_l_hand)
//				user.equip_if_possible(new /obj/item/ammo/a57(user), user.slot_in_backpack)
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
	for(var/turf/simulated/floor/F in world)
		if (was_eaten)
			F.icon_state = "bloodfloor_2"
			F.name = "fleshy floor"
		else
			F.icon_state = pick("platingdmg1","platingdmg2","platingdmg3")
	for(var/turf/simulated/wall/W in world)
		if (was_eaten)
			W.icon = 'icons/misc/meatland.dmi'
			W.icon_state = "bloodwall_2"
			W.name = "meaty wall"
		else
			if(!istype(W, /turf/simulated/wall/r_wall) && !istype(W, /turf/simulated/wall/auto/reinforced))
				W.icon_state = "r_wall-4"
	return
