/obj/item/remote/reinforcement_beacon
	name = "Reinforcement Beacon"
	icon = 'icons/obj/items/device.dmi'
	desc = "A handheld beacon that allows you to call a Syndicate gunbot to the user's current location."
	icon_state = "beacon" //replace later
	item_state = "electronic"
	density = FALSE
	anchored = FALSE
	w_class = W_CLASS_SMALL
	var/uses = 1
	var/ghost_confirmation_delay = 30 SECONDS

	New()
		..()
		desc = "A handheld beacon that allows you to call a Syndicate gunbot to the user's current location. It has [src.uses] charge left."

/obj/item/remote/reinforcement_beacon/attack_self(mob/user as mob)
	if(!isonstationz(user.z))
		boutput(user, "<span class='alert'>The [src] can't be used here, try again on station!</span>")
		return

	if(uses >= 1)
		uses -= 1
		boutput(user, "<span class='alert'>You activate the [src], before setting it down on the ground.</span>")
		src.force_drop(user)
		src.anchored = TRUE
		sleep(1 SECOND)
		src.visible_message("<span class='alert'>The [src] beeps, before locking itself to the ground.</span>")
		src.desc = "A handheld beacon that allows you to call a Syndicate gunbot to the user's current location. It seems to currently be transmitting something."
		sleep(5 SECONDS)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a nuclear operative gunbot? You may be randomly selected from the list of candidates.")
		text_messages.Add("You are eligible to be respawned as a nuclear operative gunbot. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. Please wait for the game to choose, good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		message_admins("Sending Syndicate Reinforcement offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1)
		if(!length(candidates))
			src.visible_message("<span class='alert'>The [src] buzzes, before unbolting itself from the ground. There seems to be no reinforcements available currently.</span>")
			src.anchored = FALSE
		var/datum/mind/chosen = pick(candidates)
		var/mob/living/critter/robotic/gunbot/syndicate/synd = new/mob/living/critter/robotic/gunbot/syndicate
		chosen.transfer_to(synd)
		//user.mind.transfer_to(synd) //comment out ghost messages & uncomment this to make *you* the reinforcement for testing purposes
		synd.mind.special_role = ROLE_NUKEOP_GUNBOT
		synd.mind.current.antagonist_overlay_refresh(1, 0)
		if(istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/nuke_mode = ticker.mode
			synd.mind.store_memory("The bomb must be armed in <B>[nuke_mode.concatenated_location_names]</B>.", 0, 0)
			nuke_mode.syndicates += synd.mind
		synd.mind.current.show_antag_popup("nukeop-gunbot")
		SPAWN(0)
			launch_with_missile(synd, src.loc, null, "arrival_missile_synd")
		sleep(3 SECONDS)
		if(src.uses <= 0)
			elecflash(src)
			src.visible_message("<span class='alert'>The [src] sparks, before exploding!</span>")
			sleep(5 DECI SECONDS)
			explosion_new(src, get_turf(src), 0.1)
			qdel(src)
		else
			src.visible_message("<span class='alert'>The [src] beeps twice, before unbolting itself from the ground.</span>")
			src.anchored = FALSE
	else
		boutput(user, "<span class='alert'>The [src] is out of charge and can't be used again!</span>")
