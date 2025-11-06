/datum/random_event/major/antag/sleeper_agent
	name = "Awaken Sleeper Agents"
	required_elapsed_round_time = 26.6 MINUTES
	customization_available = TRUE
	announce_to_admins = FALSE // Doing it manually.
	centcom_headline = "Enemy Signal Detected"
	centcom_message = "A Syndicate radio station temporarily hijacked our communications. Be wary of individuals acting strangely."
	message_delay = 5 SECONDS
	var/num_agents = 0
	var/override_player_pref = FALSE
	var/lock = FALSE
	var/admin_override = FALSE
	var/signal_intro = 'sound/misc/sleeper_agent_hello.ogg'
	var/frequency = 1459
	var/sound_channel = 174
	var/list/numbers = list(0, 0, 0, 0, 0, 0)
	var/list/listeners = null
	var/list/candidates = null

	admin_call(var/source)
		if (..())
			return

		if (src.lock)
			message_admins("Setup of previous Awaken Sleeper Agents event hasn't finished yet, aborting.")
			return

		src.num_agents = input(usr, "How many sleeper agents to awaken?", src.name, 0) as num|null
		if (isnull(src.num_agents))
			return
		else if (src.num_agents < 1)
			return
		else
			src.num_agents = round(src.num_agents)

		switch (alert(usr, "Override player antagonist preferences?", src.name, "Yes", "No"))
			if ("Yes")
				src.override_player_pref = TRUE
			if ("No")
				src.override_player_pref = FALSE
			else
				return

		src.admin_override = TRUE
		src.event_effect(source)
		return

	event_effect(var/source)
		if(src.lock)
			return
		if (!src.admin_override)
			if (!source && (!ticker.mode || ticker.mode.latejoin_antag_compatible == 0 || late_traitors == 0))
				message_admins("Sleeper Agents are disabled in this game mode, aborting.")
				return
#ifdef RP_MODE
			if(source == null)
				return
#endif
			if (emergency_shuttle.online)
				return
		message_admins(SPAN_INTERNAL("Setting up Sleeper Agent event. Source: [source ? "[source]" : "random"]"))
		logTheThing(LOG_ADMIN, null, "Setting up Sleeper Agent event. Source: [source ? "[source]" : "random"]")
		SPAWN(0)
			src.lock = TRUE
			do_event(source == "spawn_antag", source)

	proc/do_event(var/force_antags = FALSE, var/source)
		gen_numbers()
		gather_listeners()
		if (!length(src.listeners))
			cleanup_event()
			return

		if(!src.admin_override)
			var/temp = rand(0,99)
			if(temp < 50)
				src.num_agents = 1
			else if (temp < 75)
				src.num_agents = 2
			else
				if (force_antags)
					src.num_agents = 1
				else
					src.num_agents = 0

		SPAWN(1 SECOND)
			broadcast_sound(src.signal_intro)
			sleep(8 SECONDS)
			play_all_numbers()
			broadcast_sound(src.signal_intro)

			sleep(2 SECONDS)
			if (length(src.candidates))
				var/mob/living/carbon/human/H = null
				src.num_agents = min(src.num_agents, length(src.candidates))
				for(var/i in 1 to src.num_agents)
					H = pick(src.candidates)
					src.candidates -= H
					if(istype(H))
						awaken_sleeper_agent(H, source)
			else
				message_admins("No valid candidates to wake for sleeper event.")

			if (src.centcom_headline && src.centcom_message && random_events.announce_events)
				sleep(src.message_delay)
				command_alert("[src.centcom_message]", "[src.centcom_headline]")



			cleanup_event()
		return

	proc/awaken_sleeper_agent(var/mob/living/carbon/human/H, var/source)
		H.mind.add_antagonist(ROLE_SLEEPER_AGENT, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
		message_admins("[key_name(H)] awakened as a sleeper agent antagonist. Source: [source ? "[source]" : "random event"]")
		logTheThing(LOG_ADMIN, H, "awakened as a sleeper agent antagonist. Source: [source ? "[source]" : "random event"]")

	proc/gen_numbers()
		var/num_numbers = length(src.numbers)
		src.numbers.len = 0
		for(var/i = 0, i < num_numbers, i++)
			src.numbers += rand(1,99)

	proc/gather_listeners()
		//setup empty lists
		src.listeners = list()
		src.candidates = list()

		for (var/mob/living/carbon/human/H in mobs)
			if(!isalive(H))
				continue
			for (var/obj/item/device/radio/Hs in H)
				if (Hs.frequency == src.frequency)
					src.listeners += H
					boutput(H, SPAN_NOTICE("A peculiar noise intrudes upon the radio frequency of your [Hs.name]."))
					if (H.client && !H.mind?.is_antagonist() && !isVRghost(H) && (H.client.preferences.be_traitor || src.override_player_pref) && isalive(H))
						var/datum/job/J = find_job_in_controller_by_string(H?.mind.assigned_role)
						if (J.can_be_antag(ROLE_SLEEPER_AGENT))
							src.candidates.Add(H)
				break
		for (var/mob/living/silicon/robot/R in mobs)
			if(!isalive(R))
				continue
			if (istype(R.radio, /obj/item/device/radio))
				var/obj/item/device/radio/Hs = R.radio
				if (Hs.frequency == src.frequency)
					src.listeners += R
					boutput(R, SPAN_NOTICE("A peculiar noise intrudes upon your radio frequency."))

	proc/broadcast_sound(var/soundfile)
		for (var/mob/M in src.listeners)
			if (M.client)
				if (M.client.ignore_sound_flags)
					if (M.client.ignore_sound_flags & SOUND_ALL)
						continue
				M.playsound_local(M, soundfile, 15, 0)
		sleep(1 SECOND)

	proc/play_all_numbers()
		var/batch = 0
		var/period = get_vox_by_string(".")
		for (var/number in src.numbers)
			play_number(number)
			broadcast_sound(period)
			batch++
			if (batch >= 3)
				sleep(0.1 SECONDS)

	proc/get_tens(var/n)
		if (n >= 20)
			var/tens = round(n / 10)
			switch (tens)
				if (2)
					return "twenty"
				if (3)
					return "thirty"
				if (4)
					return "fourty"
				if (5)
					return "fifty"
				if (6)
					return "sixty"
				if (7)
					return "seventy"
				if (8)
					return "eighty"
				if (9)
					return "ninety"
		return null

	proc/get_ones(var/n)
		if (n == 0)
			return "zero"
		if (n >= 10 && n < 20)
			switch (n)
				if (10)
					return "ten"
				if (11)
					return "eleven"
				if (12)
					return "twelve"
				if (13)
					return "thirteen"
				if (14)
					return "fourteen"
				if (15)
					return "fifteen"
				if (16)
					return "sixteen"
				if (17)
					return "seventeen"
				if (18)
					return "eighteen"
				if (19)
					return "nineteen"
		else
			var/ones = n % 10
			switch (ones)
				if (1)
					return "one"
				if (2)
					return "two"
				if (3)
					return "three"
				if (4)
					return "four"
				if (5)
					return "five"
				if (6)
					return "six"
				if (7)
					return "seven"
				if (8)
					return "eight"
				if (9)
					return "nine"
		return null

	proc/get_vox_by_string(var/vt)
		if (!vt)
			return null
		var/datum/VOXsound/vs = voxsounds[vt]
		if (!vs)
			return null
		return vs.ogg

	proc/play_number(var/n)
		var/stens = get_tens(n)
		var/ogg = get_vox_by_string(stens)
		if (ogg)
			broadcast_sound(ogg)
		var/sones = get_ones(n)
		ogg = get_vox_by_string(sones)
		if (ogg)
			broadcast_sound(ogg)

	proc/cleanup_event()
		//clear lists
		src.listeners = null
		src.candidates = null

		//clear flags
		src.admin_override = FALSE
		src.override_player_pref = FALSE
		src.lock = FALSE
