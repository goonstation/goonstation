/obj/item/storage/photo_album
	name = "Photo album"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "album"
	item_state = "briefcase"

/obj/item/storage/photo_album/attackby(obj/item/W, mob/user)
	if (!istype(W,/obj/item/photo))
		boutput(user, "<span class='alert'>You can only put photos in a photo album.</span>")
		return

	return ..()

TYPEINFO(/obj/item/camera)
	mats = 15

TYPEINFO(/obj/item/camera/large)
	mats = 25

/obj/item/camera
	name = "camera"
	icon = 'icons/obj/items/device.dmi'
	desc = "A reusable polaroid camera."
	icon_state = "camera"
	item_state = "electropack"
	w_class = W_CLASS_SMALL
	flags = FPRINT | TABLEPASS | EXTRADELAY | CONDUCT
	c_flags = ONBELT
	m_amt = 2000
	throwforce = 5
	throw_speed = 4
	throw_range = 10
	var/pictures_left = 10 // set to a negative to take INFINITE PICTURES
	var/pictures_max = 30
	var/can_use = 1
	var/takes_voodoo_pics = 0
	var/steals_souls = FALSE
	var/film_cost = 1

	New()
		..()
		src.setItemSpecial(null)

	large
		pictures_left = 30


	examine()
		. = ..()
		. += "There are [src.pictures_left < 0 ? "a whole lot of" : src.pictures_left] pictures left!"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/camera_film))
			var/obj/item/camera_film/C = W

			if (C.pictures <= 0)
				user.show_text("The [C.name] is used up.", "red")
				return
			if (src.pictures_left < 0)
				user.show_text("You go to replace the film cartrige, but it looks like the one already in [src] still has a whole lot of film left! You don't think you'll need to replace it in this lifetime.", "red")
				return
			if (src.pictures_left != 0)
				user.show_text("You have to use up the current film cartridge before you can replace it.", "red")
				return

			src.pictures_left = min(src.pictures_left + C.pictures, src.pictures_max)
			user.u_equip(C)
			qdel(C)
			user.show_text("You replace the film cartridge. The camera can now take [src.pictures_left] pictures.", "blue")

		else if (istype(W, /obj/item/parts/robot_parts/arm))
			var/obj/item/camera_arm_assembly/B = new /obj/item/camera_arm_assembly
			B.set_loc(user)
			user.u_equip(W)
			user.u_equip(src)
			user.put_in_hand_or_drop(B)
			boutput(user, "You add the robot arm to the camera!")
			qdel(W)
			qdel(src)
			return

		else
			..()
		return

/obj/item/camera/voodoo //kubius: voodoo cam subtyped for cleanliness
	desc = "There's some sort of faint writing etched into the casing."
	takes_voodoo_pics = 1

	ultimate
		name = "soul-binding camera"
		desc = "No one cam should have all this power."
		takes_voodoo_pics = 2

/obj/item/camera/spy
	inventory_counter_enabled = 1
	var/flash_mode = 0
	var/wait_cycle = 0

	attack_self(mob/user)
		if (user.find_in_hand(src) && user.mind && user.mind.special_role == ROLE_SPY_THIEF) // No metagming this
			if (!src.flash_mode)
				user.show_text("You use the secret switch to set the camera to flash mode.", "blue")
				playsound(user, 'sound/items/pickup_defib.ogg', 100, 1)
				src.icon_state = "camera_flash"
			else
				user.show_text("You use the secret switch to set the camera to take photos.", "blue")
				playsound(user, 'sound/items/putback_defib.ogg', 100, 1)
				src.icon_state = "camera"
			src.flash_mode = !src.flash_mode
			src.UpdateIcon()

	New()
		var/cell = new/obj/item/ammo/power_cell/self_charging/medium{recharge_rate = 5}
		AddComponent(/datum/component/cell_holder,cell, FALSE, 200, FALSE)
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		..()
		UpdateIcon()

	update_icon()
		if (!src.flash_mode)
			inventory_counter.update_text("")
		else
			var/list/ret = list()
			if (SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
				inventory_counter.update_percent(ret["charge"], ret["max_charge"])
			else
				inventory_counter.update_text("-")
		return 0

	disposing()
		processing_items -= src
		..()

/obj/item/camera/spy/attack(atom/target, mob/user, flag)
	if (!ismob(target))
		return
	if (src.flash_mode)
		// Use cell charge
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, 25) & CELL_SUFFICIENT_CHARGE))
			user.show_text("[src] doesn't have enough battery power!", "red")
			return 0
		var/turf/T = get_turf(target.loc)
		if (T.is_sanctuary())
			user.visible_message("<span class='alert'><b>[user]</b> tries to use [src], cannot quite comprehend the forces at play!</span>")
			return
		src.UpdateIcon()
		// Generic flash
		var/mob/M = target
		SEND_SIGNAL(src, COMSIG_CELL_USE, 25)
		var/blind_success = M.apply_flash(30, 8, 0, 0, 0, rand(0, 1), 0, 0, 100, 70, disorient_time = 30)
		playsound(src, 'sound/weapons/flash.ogg', 100, 1)
		flick("camera_flash-anim", src)
		// Log entry.
		var/blind_msg_target = "!"
		var/blind_msg_others = "!"
		if (!blind_success)
			blind_msg_target = " but your eyes are protected!"
			blind_msg_others = " but [his_or_her(M)] eyes are protected!"
		M.visible_message("<span class='alert'>[user] blinds [M] with the flash[blind_msg_others]</span>", "<span class='alert'>You are blinded by the flash[blind_msg_target]</span>") // Pretend to be a flash
		logTheThing(LOG_COMBAT, user, "blinds [constructTarget(M,"combat")] with spy [src] at [log_loc(user)].")
	else
		. = ..()

/obj/item/camera/spy/afterattack(atom/target, mob/user, flag)
	if (!can_use || ismob(target.loc))
		return
	if (src.flash_mode)
		return
	else
		. = ..() 	// Call /obj/item/camera/spy/afterattack() for photo mode

// Victim types
#define VICTIM_TYPE_HUMAN 0
#define VICTIM_TYPE_MOB 1
#define VICTIM_TYPE_CREATURE 1
#define VICTIM_TYPE_NOTHING 2
#define VICTIM_TYPE_CYBORG 3
#define VICTIM_TYPE_AI 4
// Number of icon states (had to be copied from playing_cards uuughh)
#define STGCARD_NUMBER_F 4 //female
#define STGCARD_NUMBER_M 4 //male
#define STGCARD_NUMBER_N 2 //nonbinary
#define STGCARD_NUMBER_GENERAL 8
#define STGCARD_NUMBER_BORG 2
#define STGCARD_NUMBER_AI 2
/obj/item/camera/stg // Turns things into StG cards
	desc = "It seems magical... and it also seems to need a lot of film."
	film_cost = 10

	examine()
		. = ..()
		. += "But only [src.pictures_left < 0 ? "a whole lot of" : round(src.pictures_left/10)] shots can be taken."

	// Imports a specific griffin card datum into a playing card with a victim in mind
	proc/importGriffDatum(obj/item/playing_card/card, datum/playing_card/griffening/card_data, mob/living/victim)
		card.name = card_data.card_name
		card.desc = card_data.card_data // heh
		if(istype(card_data, /datum/playing_card/griffening/creature))
			var/datum/playing_card/griffening/creature/card_data_creature = card_data
			var/atk
			var/def
			var/icon_state_num
			if(card_data_creature.randomized_stats)
				if(!card_data_creature.LVL)
					card_data_creature.LVL = rand(1,10)
				// fun idea would be to add mults for traits like athletic but too much tech debt is here already
				atk = rand(1, 10) * card_data_creature.LVL
				def = rand(1, 10) * card_data_creature.LVL
			else
				atk = card_data_creature.ATK
				def = card_data_creature.DEF
			if(card_data_creature.LVL)
				card.name = "LVL [card_data_creature.LVL] [victim.real_name]"
			else
				card.name = "[victim.real_name]"
			if(istype(card_data_creature, /datum/playing_card/griffening/creature/mob/ai)) // AIs are named with a suffix
				card.name += " the AI"
			card.name += " [atk]/[def]"
			card.desc = card_data_creature.card_data
			card.desc += " ATK [atk] | DEF [def]"
			switch(victim.gender)
				if(MALE)
					icon_state_num = rand(1,STGCARD_NUMBER_F)
					card.icon_state = "stg-f-[icon_state_num]"
				if(FEMALE)
					icon_state_num = rand(1,STGCARD_NUMBER_M)
					card.icon_state = "stg-m-[icon_state_num]"
				else // neuter and plural
					icon_state_num = rand(1,STGCARD_NUMBER_N)
					card.icon_state = "stg-n-[icon_state_num]"
			// Actually silicons have unique iconstates
			if(istype(card_data_creature, /datum/playing_card/griffening/creature/mob/ai))
				icon_state_num = rand(1,STGCARD_NUMBER_AI)
				card.icon_state = "stg-ai-[icon_state_num]"
			if(istype(card_data_creature, /datum/playing_card/griffening/creature/mob/cyborg))
				icon_state_num = rand(1,STGCARD_NUMBER_BORG)
				card.icon_state = "stg-borg-[icon_state_num]"
		else // is an area or effect
			card.icon_state = "stg-general-[rand(1,STGCARD_NUMBER_GENERAL)]"
		card.card_style = "stg"
		card.update_stored_info()
		return card

	proc/findSentientOnTurf(turf/the_turf, typepath)
		// Find things on this space and the last one to the looped through is our victim
		// but prioritize sentient ones (with clients)
		var/victim_chosen = null
		for (var/mob/living/carbon/human/victim in the_turf)
			if (victim.invisibility)
				continue
			victim_chosen = victim
			if(victim.client)  // Great! A sapient human! Best case scenario, stop checking
				break
		return victim_chosen

	create_photo(var/atom/target, var/powerflash = 0)
		if (!target)
			return 0
		var/turf/the_turf = get_turf(target)
		var/atom/movable/victim_chosen = null // Chosen thing to cardify
		var/victim_type = VICTIM_TYPE_HUMAN // What is it?
		var/obj/item/playing_card/card = null // The card item
		var/datum/playing_card/griffening/card_data = null // Card data once we find something

		victim_chosen = findSentientOnTurf(the_turf, /mob/living/carbon/human)
		// No humans? Find a borg....
		if (!victim_chosen)
			victim_chosen = findSentientOnTurf(the_turf, /mob/living/silicon/robot)
			victim_type = VICTIM_TYPE_CYBORG
		// No borgs? Find an AI....
		if (!victim_chosen)
			victim_chosen = findSentientOnTurf(the_turf, /mob/living/silicon/ai)
			victim_type = VICTIM_TYPE_AI
		// No AI? Find a critter...
		if (!victim_chosen)
			victim_chosen = findSentientOnTurf(the_turf, /mob/living/critter)
			victim_type = VICTIM_TYPE_CREATURE
		// Oh yeah, object critters are still a thing.
		if (!victim_chosen)
			victim_chosen = findSentientOnTurf(the_turf, /obj/critter)
			victim_type = VICTIM_TYPE_CREATURE
		// why are bots considered obj/machinery...
		if (!victim_chosen)
			victim_chosen = findSentientOnTurf(the_turf, /obj/machinery/bot)
			victim_type = VICTIM_TYPE_CREATURE
		// Lost at 20 questions again! Get area card as fallback
		if (!victim_chosen)
			victim_type = VICTIM_TYPE_NOTHING

		switch(victim_type)
			if(VICTIM_TYPE_HUMAN)
				// Let's dig into your mind and extract some things...
				// You an antag we know? Just like areas they dont (or shouldnt) map 1:1 to griff. So sad! Atleast we dont need special_role back compat
				var/mob/living/carbon/human/victim_human = victim_chosen
				var/list/stg_antag_table = list()
				stg_antag_table += list(ROLE_TRAITOR, /datum/playing_card/griffening/creature/mob/traitor)
				stg_antag_table += list(ROLE_CHANGELING, /datum/playing_card/griffening/creature/mob/changeling)
				stg_antag_table += list(ROLE_VAMPIRE, /datum/playing_card/griffening/creature/mob/vampire)
				stg_antag_table += list(ROLE_WRAITH, /datum/playing_card/griffening/creature/mob/wraith) // Impressive!
				stg_antag_table += list(ROLE_NUKEOP, /datum/playing_card/griffening/creature/mob/nukeop)
				stg_antag_table += list(ROLE_WIZARD, /datum/playing_card/griffening/creature/mob/wizard) // lol
				var/datum/mind/victim_mind = null
				if (ismind(victim_human.mind))
					victim_mind = victim_human.mind
					for (var/list/compare_antag in stg_antag_table)
						if(victim_mind && victim_mind.get_antagonist(compare_antag[0]))
							card_data = new compare_antag[1]
							break
					//message_admins(ismind(victim_mind))
					//message_admins(victim_mind?.assigned_role)
					// No antag? What's your job? Sadly text2path ended up being too janky, so this is yet another table mess.
					// Thankfully this time we can do it with a switch without too much redundancy to be painful
					if(victim_mind)
						switch(victim_mind.assigned_role)
							if("Captain")
								card_data = new /datum/playing_card/griffening/creature/mob/captain
							if("Head of Personnel")
								card_data = new /datum/playing_card/griffening/creature/mob/head_of_personnel
							if("Head of Security")
								card_data = new /datum/playing_card/griffening/creature/mob/head_of_security
							if("Research Director")
								card_data = new /datum/playing_card/griffening/creature/mob/head_of_security
							if("Scientist")
								card_data = new /datum/playing_card/griffening/creature/mob/scientist
							if("Clown")
								card_data = new /datum/playing_card/griffening/creature/mob/clown
							if("Chief Engineer")
								card_data = new /datum/playing_card/griffening/creature/mob/chief_engineer
							if("Engineer")
								card_data = new /datum/playing_card/griffening/creature/mob/engineer
							if("Chaplain")
								card_data = new /datum/playing_card/griffening/creature/mob/chaplain
							if("Botanist")
								card_data = new /datum/playing_card/griffening/creature/mob/botanist
							if("Janitor")
								card_data = new /datum/playing_card/griffening/creature/mob/janitor
							if("Chef")
								card_data = new /datum/playing_card/griffening/creature/mob/chef
							if("Bartender")
								card_data = new /datum/playing_card/griffening/creature/mob/bartender
							if("Medical Director")
								card_data = new /datum/playing_card/griffening/creature/mob/medical_director
							if("Roboticist")
								card_data = new /datum/playing_card/griffening/creature/mob/roboticist
							if("Geneticist")
								card_data = new /datum/playing_card/griffening/creature/mob/geneticist
							if("Medical Doctor")
								card_data = new /datum/playing_card/griffening/creature/mob/medical_doctor
							// more specially named ones below:
							if("Staff Assistant")
								card_data = new /datum/playing_card/griffening/creature/mob/assistant
							if("Medical Assistant")
								card_data = new /datum/playing_card/griffening/creature/mob/assistant
							if("Technical Assistant")
								card_data = new /datum/playing_card/griffening/creature/mob/assistant
							if("Research Assistant")
								card_data = new /datum/playing_card/griffening/creature/mob/assistant
							if("Atmospherish Technician")
								card_data = new /datum/playing_card/griffening/creature/mob/atmospherics
							if("Sous Chef")
								card_data = new /datum/playing_card/griffening/creature/mob/chef
							if("Security Officer")
								card_data = new /datum/playing_card/griffening/creature/mob/security
				if(!card_data) // Absolutely no valid antag or job at all?? Okay, fine, get some random data
					card_data = new /datum/playing_card/griffening/creature/mob
					var/datum/playing_card/griffening/creature/mob/temp = card_data
					temp.card_name = "Human"
					if(victim_mind)
						temp.card_data = "Some kinda [victim_mind.assigned_role] card. "
					temp.card_data += "Wait, this isn't a tournament legal card."
					temp.randomized_stats = TRUE
					card_data = temp
				//message_admins(card_data.type)
			if(VICTIM_TYPE_CYBORG) // Special silicon cases which have just one card each
				card_data = new /datum/playing_card/griffening/creature/mob/cyborg
			if(VICTIM_TYPE_AI)
				card_data = new /datum/playing_card/griffening/creature/mob/ai
			if(VICTIM_TYPE_CREATURE) // Critters and creatures in general
				// Special cases!
				if(ispath(victim_chosen,/obj/critter/domestic_bee/heisenbee))
					card_data = new /datum/playing_card/griffening/creature/friend/bee/heisenbee
				else if(ispath(victim_chosen,/obj/critter/domestic_bee) || ispath(victim_chosen,/obj/critter/domestic_bee_larva) || ispath(victim_chosen,/obj/critter/fake_bee) || ispath(victim_chosen,/mob/living/critter/small_animal/bee))
					card_data = new /datum/playing_card/griffening/creature/friend/bee
				else if(ispath(victim_chosen,/obj/machinery/bot/secbot/beepsky))
					card_data = new /datum/playing_card/griffening/creature/friend/beepsky
				else if(ispath(victim_chosen,/obj/critter/bat/doctor) || ispath(victim_chosen,/mob/living/critter/small_animal/bat/doctor))
					card_data = new /datum/playing_card/griffening/creature/friend/dracula
				else if(ispath(victim_chosen,/mob/living/critter/brullbar/king))
					card_data = new /datum/playing_card/griffening/creature/friend/brullbar/king
				else if(ispath(victim_chosen,/mob/living/critter/brullbar))
					card_data = new /datum/playing_card/griffening/creature/friend/brullbar
				else if(ispath(victim_chosen,/mob/living/critter/bear))
					card_data = new /datum/playing_card/griffening/creature/friend/bear
				else // No special case, randomize!
					card_data = new /datum/playing_card/griffening/creature/friend
					var/datum/playing_card/griffening/creature/friend/temp = card_data
					temp.card_name = "Strange Little Creature"
					temp.card_data = "Wait, this isn't a tournament-legal card."
					temp.randomized_stats = TRUE
					card_data = temp
			if(VICTIM_TYPE_NOTHING) // Nothing found? Try to find this area and manually cardify from table
				var/the_area = get_area(the_turf)
				var/list/stg_area_table = list() // (area, card data)
				// griffin does not convert 1:1 to station areas so here's a big table of conversions. can't just index the right one, need to typecheck + asoc doesnt do object indexes well(?) if at all(?)
				// highly unfortunate and ugly. if this fails (like photo'ing an azone's *floor*) then i applaud you for such a total misplay
				// order does matter here for children - most inherited first please
				stg_area_table += list(/area/space, /datum/playing_card/griffening/effect/hull_breach)
				stg_area_table += list(/area/station/turret_protected/armory_outside, /datum/playing_card/griffening/area/security) // There's no one big AI path for turret protected AI areas
				stg_area_table += list(/area/station/turret_protected, /datum/playing_card/griffening/area/upload) // so assume non-armory area is gonna be AI
				stg_area_table += list(/area/station/construction, /datum/playing_card/griffening/area/engineering)
				stg_area_table += list(/area/station/engine, /datum/playing_card/griffening/area/engineering)
				stg_area_table += list(/area/station/mining, /datum/playing_card/griffening/area/engineering)
				stg_area_table += list(/area/mining/miningoutpost, /datum/playing_card/griffening/area/engineering)
				stg_area_table += list(/area/station/medical/robotics, /datum/playing_card/griffening/area/robotics)
				stg_area_table += list(/area/station/medical/research, /datum/playing_card/griffening/area/genetics)
				stg_area_table += list(/area/station/medical, /datum/playing_card/griffening/area/medbay)
				stg_area_table += list(/area/station/chapel, /datum/playing_card/griffening/area/chapel)
				stg_area_table += list(/area/listeningpost, /datum/playing_card/griffening/area/syndicate) // how tf did you get in there??
				stg_area_table += list(/area/station/bridge, /datum/playing_card/griffening/area/bridge)
				stg_area_table += list(/area/station/security, /datum/playing_card/griffening/area/security)
				stg_area_table += list(/area/station/crew_quarters/kitchen, /datum/playing_card/griffening/area/kitchen)
				stg_area_table += list(/area/station/crew_quarters/cafeteria, /datum/playing_card/griffening/area/cafeteria)
				stg_area_table += list(/area/shuttle/escape, /datum/playing_card/griffening/area/shuttle)
				stg_area_table += list(/area/station/maintenance, /datum/playing_card/griffening/effect/disarm) // surprisingly no maint area card!
				stg_area_table += list(/area/station/science, /datum/playing_card/griffening/effect/Telescientist) // or a sci card
				stg_area_table += list(/area/station, /datum/playing_card/griffening/effect/abandoned_crate) // Atleast you're still on station right?

				for(var/list/compare_area in stg_area_table)
					if(istype(the_area, compare_area[0]))
						card_data = new compare_area[1]
				if(card_data)
					card = new /obj/item/playing_card(the_turf)
					importGriffDatum(card, card_data, victim_chosen)
				else // - ⇀ -
					card = new /obj/item/playing_card/expensive(the_turf) // consolation prize
				if(prob(10))
					card.add_foil()
				return
		card = new /obj/item/playing_card(the_turf)
		importGriffDatum(card, card_data, victim_chosen)
		if(prob(10))
			card.add_foil()
		// Final part! Their soul shall now be trapped inside the card.
		if(isliving(victim_chosen))
			var/mob/living/temp = victim_chosen
			temp.flash(5 SECONDS)
			temp.pixel_x = 0
			temp.pixel_y = 0
			temp.real_name = card.name // so we get "LVL 6 Test Dummy 40/48 says" or "LVL 1 SHODAN the AI 10/12 states"
			temp.name = temp.real_name
			victim_chosen = temp
			victim_chosen.set_loc(card)
			APPLY_ATOM_PROPERTY(temp, PROP_MOB_BREATHLESS, src.type) // So that you don't choke while being held. Cards don't breathe now do they?
			boutput(temp, "<span class='alert'>Oh no! You've been turned into a Spaceman: The Griffening card!<br>Don't worry, this doesn't mean you're dead. You can still talk and do certain local things.<br>If the card life isn't for you, maybe consider suicide.</span>")
#undef VICTIM_TYPE_HUMAN
#undef VICTIM_TYPE_MOB
#undef VICTIM_TYPE_NOTHING
#undef VICTIM_TYPE_AI
#undef VICTIM_TYPE_CYBORG
#undef STGCARD_NUMBER_F
#undef STGCARD_NUMBER_M
#undef STGCARD_NUMBER_N

TYPEINFO(/obj/item/camera_film)
	mats = 10

TYPEINFO(/obj/item/camera_film/large)
	mats = 15

/obj/item/camera_film
	name = "film cartridge"
	desc = "A replacement film cartridge for an instant camera."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "camera_film"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box"
	w_class = W_CLASS_SMALL
	var/pictures = 10

	large
		name = "film cartridge (large)"
		pictures = 30

	examine()
		. = ..()
		. += "It is good for [src.pictures] pictures."


/obj/item/photo
	name = "photo"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "photo"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	w_class = W_CLASS_TINY
	var/image/fullImage
	var/icon/fullIcon
	var/list/signed = list()
	var/written = null
	var/image/my_writing = null
	tooltip_flags = REBUILD_DIST
	burn_point = 220
	burn_output = 900
	burn_possible = 2

	New(location, var/image/IM, var/icon/IC, var/nname, var/ndesc)
		..(location)
		if (istype(IM))
			fullImage = IM
			IM.transform = matrix(24/32, 22/32, MATRIX_SCALE)
			IM.pixel_y = 1
			src.UpdateOverlays(IM, "photo")
		if (istype(IC))
			fullIcon = IC
		if (nname)
			src.name = nname
		if (ndesc)
			src.desc = ndesc

/obj/item/photo/get_desc(var/dist)
	if(dist>1)
		return
	else
		if(signed || written)
			. += "<br>"
		if(signed.len > 0)
			for(var/x in signed)
				. += "It is signed: [x]"
				. += "<br>"
		if (written)
			. += "At the bottom is written: [written]"


/obj/item/photo/attackby(obj/item/W, mob/user)
	var/obj/item/pen/P = W
	if(istype(P))
		var/signwrite = input(user, "Sign or Write?", null, null) as null|anything in list("sign","write")
		var/t = input(user, "What do you want to [signwrite]?", null, null) as null|text
		t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN)
		if(t)
			if(signwrite == "sign")
				var/image/signature = image(icon='icons/misc/photo_writing.dmi',icon_state="[signwrite]")
				signature.color = P.font_color
				signature.pixel_x = -10*(1-rand())
				signature.pixel_y = 15*(1-rand())
				signature.layer = OBJ_LAYER + 0.01
				src.overlays += signature
				signed += "<span style='color: [P.font_color]'>[t]</span>"
				tooltip_rebuild = 1
			else if (signwrite == "write")
				var/image/writing = image(icon='icons/misc/photo_writing.dmi',icon_state="[signwrite]")
				writing.color = P.font_color
				writing.layer = OBJ_LAYER + 0.01

				if(!written)
					written = "<span style='color: [P.font_color]'>[t]</span>"
				else
					src.overlays -= src.my_writing
					written = "[src.written] <span style='color: [P.font_color]'>[t]</span>"
				tooltip_rebuild = 1
				src.my_writing = writing
				src.overlays += writing
		return
	..()

/obj/item/photo/voodoo //kubius: voodoo "doll" photograph
	var/mob/cursed_dude = null //set at photo creation
	var/enchant_power = 13 //how long the photo's magic lasts, negative values make it infinite
	var/enchant_delay = 0 //rolling counter to prevent spam utilization
	event_handler_flags = USE_FLUID_ENTER | IS_FARTABLE

	//farting is handled in human.dm

	attackby(obj/item/W, mob/user)
		if (enchant_power && world.time > src.enchant_delay && cursed_dude && istype(cursed_dude, /mob))
			cursed_dude.Attackby(W,user)
			src.enchant_delay = world.time + COMBAT_CLICK_DELAY
			if(enchant_power > 0) enchant_power--
		else
			..()
		if(enchant_power == 0)
			boutput(user,"<span class='alert'><b>[src]</b> crumbles away to dust!</span>")
			qdel(src)
		return

	throw_begin(atom/target)
		if (enchant_power && world.time > src.enchant_delay && cursed_dude && ismob(cursed_dude))
			cursed_dude.visible_message("<span class='alert'><b>[cursed_dude] is violently thrown by an unseen force!</b></span>")
			cursed_dude.throw_at(get_edge_cheap(src, get_dir(src, target)), 20, 1)
			src.enchant_delay = world.time + COMBAT_CLICK_DELAY
			if(enchant_power > 0) enchant_power--
		if(enchant_power == 0)
			src.visible_message("<span class='alert'><b>[src]</b> crumbles away to dust!</span>")
			qdel(src)
		return ..(target)


//////////////////////////////////////////////////////////////////////////////////////////////////
/*/obj/item/camera*/
/proc/build_composite_icon(var/atom/C)
	if (!C)
		return
	var/image/composite = image(C.icon, null, C.icon_state, null /*max(OBJ_LAYER, C.layer)*/, C.dir)
	if (!composite)
		return

	composite.overlays = C.overlays
	composite.underlays = C.underlays
	return composite
//////////////////////////////////////////////////////////////////////////////////////////////////
/obj/item/camera/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/camera/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if (!can_use || ismob(target.loc)) return
	if (src.pictures_left >= 0 && src.pictures_left < src.film_cost && user)
		user.show_text("The film cartridge doesn't have enough film to take a photo. You have to replace it first.", "red")
		return

	src.create_photo(target)
	playsound(src, "sound/items/polaroid[rand(1,2)].ogg", 75, 1, -3)

	if (src.pictures_left > 0)
		src.pictures_left = max(0, src.pictures_left - src.film_cost)
		if (user)
			boutput(user, "<span class='notice'>[pictures_left] photos left.</span>")
	can_use = FALSE
	SPAWN(10 SECONDS)
		if (src)
			src.can_use = TRUE

/obj/item/camera/proc/create_photo(var/atom/target, var/powerflash = 0)
	if (!target)
		return 0
	var/turf/the_turf = get_turf(target)

	var/image/photo = image(the_turf.icon, null, the_turf.icon_state, OBJ_LAYER, the_turf.dir)
	var/icon/photo_icon = getFlatIcon(the_turf)
	if (!photo)
		return

	//photo.overlays += the_turf

	//turficon.Scale(22,20)

	var/mob_title = null
	var/mob_detail = null
	var/mob/deafnote = null //kubius: voodoo photo mob tracking, takes the first mob in an image
	//POSSIBLe gc woes later, on that is if we ever fuckin get mobs to gc at all hahaha

	var/item_title = null
	var/item_detail = null

	var/mobnumber = 0 // above 3 and it'll stop listing what they're holding and if they're hurt
	var/itemnumber = 0
	var/list/mob/stolen_souls = list()

	for (var/atom/A in the_turf)
		if (A.invisibility || istype(A, /obj/overlay/tile_effect))
			continue
		var/icon/ic = getFlatIcon(A)
		if (ic)
			photo_icon.Blend(ic, ICON_OVERLAY, x=A.pixel_x + world.icon_size * (A.x - the_turf.x), y=A.pixel_y + world.icon_size * (A.y - the_turf.y))
		if (ismob(A))
			var/mob/M = A

			if(src.steals_souls)
				stolen_souls += M

			if (!mob_title)
				if(src.takes_voodoo_pics)
					deafnote = A
				mob_title = "[M]"
			else
				mob_title += " and [M]"

			if (mobnumber < 4)
				var/holding = null
				if (iscarbon(M))
					var/mob/living/carbon/temp = M
					if (temp.l_hand || temp.r_hand)
						var/they_are = M.gender == "male" ? "He's" : M.gender == "female" ? "She's" : "They're" // I wanna just use he_or_she() but it wouldn't really work
						if (temp.l_hand)
							holding = "[they_are] holding \a [temp.l_hand]"
						if (temp.r_hand)
							if (holding)
								holding += " and \a [temp.r_hand]."
							else
								holding = "[they_are] holding \a [temp.r_hand]."
						else if (holding)
							holding += "."

				var/they_look = M.gender == "male" ? "he looks" : M.gender == "female" ? "she looks" : "they look"
				var/health_info = M.health < 75 ? " - [they_look][M.health < 25 ? " really" : null] hurt" : null
				if (powerflash && M == target && !M.eyes_protected_from_light())
					if (!health_info)
						health_info = " - [they_look] dazed"
					else
						health_info += " and dazed"
				if (!mob_detail)
					mob_detail = "In the photo, you can see [M][M.lying ? " lying on [the_turf]" : null][health_info][holding ? ". [holding]" : "."]"
				else
					mob_detail += " You can also see [M][M.lying ? " lying on [the_turf]" : null][health_info][holding ? ". [holding]" : "."]"
			else
				mob_detail += " You can also see [M]."

		else
			if (itemnumber < 5)
				itemnumber++

				if (!item_title)
					item_title = " \a [A]"
				else
					item_title = " some objects"

				if (!item_detail)
					item_detail = "\a [A]"
				else
					item_detail += " and \a [A]"

	var/finished_title = null
	var/finished_detail = null

	if (!item_title && !mob_title)
		finished_title = "boring photo"
		finished_detail = "This is a pretty boring photo of \a [the_turf]."
	else
		if (mob_title)
			finished_title = "photo of [mob_title][item_title ? " and[item_title]" : null]"
			finished_detail = "[mob_detail][item_detail ? " There's also [item_detail]." : null]"
		else if (item_title)
			finished_title = "photo of[item_title]"
			finished_detail = "You can see [item_detail]."

	if (istype(photo_icon))
		photo_icon.Crop(1,1,32,32)
	photo.icon = photo_icon

	var/obj/item/photo/P
	if(src.takes_voodoo_pics)
		P = new/obj/item/photo/voodoo(get_turf(src), photo, photo_icon, finished_title, finished_detail)
		P:cursed_dude = deafnote //kubius: using runtime eval because non-voodoo photos don't have a cursed_dude var
		if(src.takes_voodoo_pics == 2) //unlimited photo uses
			P:enchant_power = -1
	else if(src.steals_souls)
		P = new/obj/item/photo/haunted(get_turf(src), photo, photo_icon, finished_title, finished_detail)
		var/obj/item/photo/haunted/HP = P
		for(var/mob/M as anything in stolen_souls)
			HP.add_soul(M)
	else
		P = new/obj/item/photo(get_turf(src), photo, photo_icon, finished_title, finished_detail)

	return P
