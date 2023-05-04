/obj/item/remote/reinforcement_beacon
	name = "Reinforcement Beacon"
	icon = 'icons/obj/items/device.dmi'
	desc = "A handheld beacon that allows you to call a Syndicate gunbot to the user's current location."
	icon_state = "beacon" //replace later
	item_state = "electronic"
	density = FALSE
	anchored = UNANCHORED
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
		src.anchored = ANCHORED
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
			src.anchored = UNANCHORED
		var/datum/mind/chosen = candidates[1]
		log_respawn_event(chosen, "syndicate gunbot", user)
		chosen.add_antagonist(ROLE_NUKEOP_GUNBOT, respect_mutual_exclusives = FALSE)

		SPAWN(0)
			launch_with_missile(chosen.current, src.loc, null, "arrival_missile_synd")
		sleep(3 SECONDS)
		if(src.uses <= 0)
			elecflash(src)
			src.visible_message("<span class='alert'>The [src] sparks, before exploding!</span>")
			sleep(5 DECI SECONDS)
			explosion_new(src, get_turf(src), 0.1)
			qdel(src)
		else
			src.visible_message("<span class='alert'>The [src] beeps twice, before unbolting itself from the ground.</span>")
			src.anchored = UNANCHORED
	else
		boutput(user, "<span class='alert'>The [src] is out of charge and can't be used again!</span>")
