/datum/random_event/major/antag/sleeper_agent
	name = "Awaken Sleeper Agents"
	required_elapsed_round_time = 26.6 MINUTES
	customization_available = 1
	announce_to_admins = 0 // Doing it manually.
	centcom_headline = "Enemy Signal Detected"
	centcom_message = "A Syndicate radio station temporarily hijacked our communications. Be wary of individuals acting strangely."
	message_delay = 5 SECONDS
	var/num_agents = 0
	var/override_player_pref = 0
	var/lock = 0
	var/admin_override = 0
	var/signal_intro = 'sound/misc/sleeper_agent_hello.ogg'
	var/frequency = 1459
	var/sound_channel = 174
	var/list/numbers = list(0,0,0,0,0,0)
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
				src.override_player_pref = 1
			if ("No")
				src.override_player_pref = 0
			else
				return

		src.admin_override = 1
		src.event_effect(source)
		return

	event_effect(var/source)
		if(src.lock)
			return
		if (src.admin_override != 1)
			if (!source && (!ticker.mode || ticker.mode.latejoin_antag_compatible == 0 || late_traitors == 0))
				message_admins("Sleeper Agents are disabled in this game mode, aborting.")
				return
			if (emergency_shuttle.online)
				return
		message_admins("<span class='internal'>Setting up Sleeper Agent event. Source: [source ? "[source]" : "random"]</span>")
		logTheThing("admin", null, null, "Setting up Sleeper Agent event. Source: [source ? "[source]" : "random"]")
		SPAWN_DBG(0)
			src.lock = 1
			do_event(source=="spawn_antag")

	proc/do_event(var/force_antags = 0)
		gen_numbers()
		gather_listeners()
		if (!listeners.len)
			cleanup_event()
			return

		if(!src.admin_override)
			var/temp = rand(0,99)
			if(temp < 50)
				num_agents = 1
			else if (temp < 75)
				num_agents = 2
			else
				if (force_antags)
					num_agents = 1
				else
					num_agents = 0
		if(!num_agents)
			cleanup_event()
			return

		SPAWN_DBG(10)
			broadcast_sound(signal_intro)
			play_all_numbers()
			broadcast_sound(signal_intro)

			sleep(30 SECONDS) //30s to let the signal play
			var/mob/living/carbon/human/H = null
			num_agents = min(num_agents,candidates.len)
			for(var/i = 0, i<num_agents,i++)
				H = pick(candidates)
				candidates -= H
				if(istype(H))
					awaken_sleeper_agent(H)

			if (src.centcom_headline && src.centcom_message && random_events.announce_events)
				sleep(src.message_delay)
				command_alert("[src.centcom_message]", "[src.centcom_headline]")

	#if ASS_JAM // no idea what this does or who did it
			var/list/sleepers = list()
			for(var/mob/listener in listeners)
				sleepers += new/obj/machinery/sleeper(get_turf(listener))
			sleep(3 SECONDS)
			for(var/atom/sleeper in sleepers)
				qdel(sleeper)
	#endif

			cleanup_event()
		return

	proc/awaken_sleeper_agent(var/mob/living/carbon/human/H)
		var/list/eligible_objectives = list()
		eligible_objectives = typesof(/datum/objective/regular/) + typesof(/datum/objective/escape/) - /datum/objective/regular/
		var/num_objectives = rand(1,3)
		var/datum/objective/new_objective = null
		for(var/i = 0, i < num_objectives, i++)
			var/select_objective = pick(eligible_objectives)
			new_objective = new select_objective
			new_objective.owner = H.mind
			new_objective.set_up()
			H.mind.objectives += new_objective

		H.show_text("<h2><font color=red><B>You have awakened as a syndicate sleeper agent!</B></font></h2>", "red")
		H.mind.special_role = "sleeper agent"
		H << browse(grabResource("html/traitorTips/traitorsleeperTips.html"),"window=antagTips;titlebar=1;size=600x400;can_minimize=0;can_resize=0")
		if(!(H.mind in ticker.mode.traitors))
			ticker.mode.traitors += H.mind
		if (H.mind.current)
			H.mind.current.antagonist_overlay_refresh(1, 0)
		var/obj_count = 1
		for(var/datum/objective/OBJ in H.mind.objectives)
			boutput(H, "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]")
			obj_count++

	proc/gen_numbers()
		var/num_numbers = numbers.len
		numbers.len = 0
		for(var/i = 0, i < num_numbers, i++)
			numbers += rand(1,99)

	proc/gather_listeners()
		//setup empty lists
		src.listeners = list()
		src.candidates = list()

		for (var/mob/living/carbon/human/H in mobs)
			if(!isalive(H))
				continue
			for (var/obj/item/device/radio/Hs in H)
				if (Hs.frequency == frequency)
					listeners += H
					boutput(H, "<span class='notice'>A peculiar noise intrudes upon the radio frequency of your [Hs].</span>")
					if(H.client && !checktraitor(H) && (H.client.preferences.be_traitor || src.override_player_pref) && !(H.mind.assigned_role in list("Head of Security", "Security Officer")))
						candidates += H
				break
		for (var/mob/living/silicon/robot/R in mobs)
			if(!isalive(R))
				continue
			if (istype(R.radio, /obj/item/device/radio))
				var/obj/item/device/radio/Hs = R.radio
				if (Hs.frequency == frequency)
					listeners += R
					boutput(R, "<span class='notice'>A peculiar noise intrudes upon your radio frequency.</span>")

	proc/broadcast_sound(var/soundfile)
		for (var/mob/M in listeners)
			if (M.client)
				if (M.client.ignore_sound_flags)
					if (M.client.ignore_sound_flags & SOUND_ALL)
						continue
				M << sound(soundfile, volume = 50, channel = sound_channel, wait = 1)


	proc/play_all_numbers()
		var/batch = 0
		var/period = get_vox_by_string(".")
		for (var/number in numbers)
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
		src.admin_override = 0
		src.override_player_pref = 0
		src.lock = 0
