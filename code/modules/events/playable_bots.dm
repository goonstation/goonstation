/datum/random_event/major/player_spawn/bots
	name = "Bots (playable)"

	required_elapsed_round_time = 5 MINUTES

	var/ghost_confirmation_delay = 1 MINUTES // time to acknowledge or deny respawn offer.
	event_effect()
		..()

		// 1: alert | 2: alert (chatbox) | 3: alert acknowledged (chatbox) | 4: no longer eligible (chatbox) | 5: waited too long (chatbox)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a random pest? (special ghost critter)") // Don't disclose which type it is. You know, metagaming.
		text_messages.Add("You are eligible to be respawned as a random pest. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of pests. Please wait...")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 0)


		if (candidates.len)
			if(!latejoin || !latejoin.len)
				message_admins("Bots event couldn't find a latejoin landmark!")
				return

			var/atom/location = pick(latejoin)

			var/howmany = rand(1,min(3,candidates.len))
			for (var/i in 0 to howmany)
				if (!candidates || !candidates.len)
					break

				var/datum/mind/M = pick(candidates)
				if (M.current)
					var/mob/dead/observer/O = null
					if (istype(M.current,/mob/dead/observer))
						O = M.current
					else
						O = M.current.ghostize()
					var/type = pick(\
						prob(200); /obj/machinery/bot/medbot,\
						prob(200);/obj/machinery/bot/cleanbot,\
						/obj/machinery/bot/firebot,\
						/obj/machinery/bot/floorbot,\
						prob(50);/obj/machinery/bot/buttbot,\
						prob(50);/obj/machinery/bot/duckbot,\
						prob(50);/obj/machinery/bot/secbot\
					)
					var/obj/machinery/bot/B = new type(location)
					O.insert_control_observer(B)

				candidates -= M

			command_alert("A unit of advanced maintenance bots has been deployed.", "Helpful Bots")



/mob/proc/testy_thingy()
	var/list/candidates = list(src.mind)
	if (candidates.len)
		if(!latejoin || !latejoin.len)
			message_admins("Bots event couldn't find a latejoin landmark!")
			return

		var/atom/location = pick(latejoin)

		var/howmany = rand(1,min(3,candidates.len))
		for (var/i in 0 to howmany)
			if (!candidates || !candidates.len)
				break

			var/datum/mind/M = pick(candidates)
			if (M.current)
				var/mob/dead/observer/O = null
				if (istype(M.current,/mob/dead/observer))
					O = M.current
				else
					O = M.current.ghostize()
				var/type = pick(\
					prob(200); /obj/machinery/bot/medbot,\
					prob(200);/obj/machinery/bot/cleanbot,\
					/obj/machinery/bot/firebot,\
					/obj/machinery/bot/floorbot,\
					prob(50);/obj/machinery/bot/buttbot,\
					prob(50);/obj/machinery/bot/duckbot,\
					prob(50);/obj/machinery/bot/secbot\
				)
				var/obj/machinery/bot/B = new type(location)
				var/mob/newobs = O.insert_control_observer(B)

			candidates -= M

		command_alert("A unit of advanced maintenance bots has been deployed.", "Helpful Bots")
