
var/global/datum/mutex/limited/latespawning = new(5 SECONDS)
TYPEINFO(/mob/new_player)
	start_listen_modifiers = null
	start_listen_inputs = list(LISTEN_INPUT_EARS)
	start_listen_languages = list(LANGUAGE_ALL)
	start_speech_modifiers = null
	start_speech_outputs = null

/mob/new_player
	anchored = ANCHORED
	has_typing_indicator = FALSE

	var/ready_play = FALSE //!Ready to play game
	var/ready_tutorial = FALSE //!Ready to start tutorial
	var/tutorial_loading = FALSE //!Tutorial is loading
	var/spawning = 0
	var/keyd
	var/adminspawned = 0
	var/is_respawned_player = 0
	var/pregameBrowserLoaded = FALSE
	var/antag_fallthrough = FALSE
	/// indicates if a player is currently barred from joining the game
	var/blocked_from_joining = FALSE

	var/my_own_roundstart_tip = null //! by default everyone sees the get_global_tip() tip, but if they press the button to refresh they get their own

#ifdef TWITCH_BOT_ALLOWED
	var/twitch_bill_spawn = FALSE
#endif

	density = FALSE
	stat = STAT_DEAD
	canmove = 0

	anchored = ANCHORED	//  don't get pushed around

	var/datum/spend_spacebux/bank_menu
	default_speech_output_channel = SAY_CHANNEL_OOC

	New()
		. = ..()
		START_TRACKING
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_ALWAYS)
	#ifdef I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO
		src.ready_play = TRUE
	#endif

	// How could this even happen? Regardless, no log entries for unaffected mobs (Convair880).
	ex_act(severity)
		return

	disposing()
		STOP_TRACKING
		mobs.Remove(src)
		if (mind)
			if (mind.current == src)
				mind.current = null

			mind = null
		key = null
		..()

	Login()
		if (!src.client)
			logTheThing(LOG_DEBUG, src, "new_player/Login called with null client. This is likely due to someone trying to log in with an in-use key.")
			return
		..()

		if(!mind)
			mind = new(src)
			keyd = mind.key

		if (src.client?.player) //playtime logging stuff
			var/datum/player/P = src.client.player
			if (!isnull(P.round_join_time) && isnull(P.round_leave_time)) //they likely died but didnt d/c b4 respawn
				P.log_leave_time()

		src.client?.load_pregame()
		close_spawn_windows()
		new_player_panel()
		var/turf/default_loc = locate(1,1,1)
		if (istype(default_loc.loc, /area/cordon))
			default_loc = pick_landmark(LANDMARK_LATEJOIN, locate(world.maxx/2,world.maxy/2,1))
		src.set_loc(pick_landmark(LANDMARK_NEW_PLAYER, default_loc))
		src.sight |= SEE_TURFS

		#if CLIENT_AUTH_PROVIDER_CURRENT == CLIENT_AUTH_PROVIDER_BYOND
		// byond members get a special join message :]
		if (src.client?.IsByondMember())
			var/list/msgs_which_are_gifs = list(8, 9, 10) //not all of these are normal jpgs
			var/num = rand(1,16)
			var/resource = resource("images/member_msgs/byond_member_msg_[num].[(num in msgs_which_are_gifs) ? "gif" : "jpg"]")
			boutput(src, "<img src='[resource]' style='margin: auto; display: block; max-width: 100%;'>")
		#endif

		if (src.ckey && !adminspawned)
			if ("[src.ckey]" in spawned_in_keys)
				if (!(client && client.holder) && !abandon_allowed)
					 //They have already been alive this round!!
					var/mob/dead/observer/observer = new()

					src.spawning = 1

					close_spawn_windows()
					boutput(src, SPAN_NOTICE("Now teleporting."))
					var/ASLoc = pick_landmark(LANDMARK_OBSERVER)
					if (ASLoc)
						observer.set_loc(ASLoc)
					else
						observer.set_loc(locate(1, 1, 1))
					observer.key = key

					if (client?.preferences)
						if (client.preferences.be_random_name)
							client.preferences.randomize_name()

						observer.name = client.preferences.real_name

					observer.real_name = observer.name
					qdel(src)

			else
				if (src.client.authenticated) spawned_in_keys += "[src.ckey]"
				for (var/sound in global.dj_panel.preloaded_sounds)
					src.client << load_resource(sound, -1)

#ifdef TWITCH_BOT_ALLOWED
		if (current_state == GAME_STATE_PLAYING)
			src.try_force_into_bill()
		else
			if (src.client && src.client.ckey == TWITCH_BOT_CKEY)
				twitch_bill_spawn = 1
				boutput(src, "<span class='bold notice'>Please wait. When the game starts, Shitty Bill will be activated.</span>")
#endif

	Logout()
		src.ready_play = FALSE
		src.ready_tutorial = FALSE
		if (src.ckey) //Null if the client changed to another mob, but not null if they disconnected.
			spawned_in_keys -= "[src.ckey]"
		else if (isclient(src.last_client)) //playtime logging stuff
			src.last_client.player.log_join_time()

		..()
		close_spawn_windows()
		if(!spawning)
			qdel(src)

		// Given below call, not much reason to do this if pregameHTML wasn't set
		// explanation for isnull(src.key) from the reference: In the case of a player switching to another mob, by the time Logout() is called, the original mob's key will be null,
		if (isnull(src.key) && pregameHTML && isclient(src.last_client))
			// Removed dupe "if (src.last_client)" check since it was still runtiming anyway
			SPAWN(0)
				if(isclient(src.last_client))
					src.last_client << browse("", "window=pregameBrowser")
					winshow(src.last_client, "pregameBrowser", FALSE)
		return

	verb/new_player_panel()
		set src = usr
		src.update_joinmenu()

	Stat()
		..()
		if(current_state <= GAME_STATE_PREGAME)
			statpanel("Lobby")
			if(client.statpanel=="Lobby" && ticker)
				for (var/client/C)
					var/mob/new_player/player = C.mob
					if (!istype(player)) continue

					var/playing = null
					if (player.ready_play)
						playing = "(Playing)"
					else if (player.ready_tutorial)
						playing = "(Tutorial)"

					if (player.client.holder && (player.client.stealth || player.client.alt_key)) // are they an admin and in stealth mode/have a fake key?
						if (client.holder) // are we an admin?
							stat("[player.key] (as [player.client.fakekey])", playing) // give us the full deets
						else // are we not an admin?
							stat("[player.client.fakekey]", playing) // only show the fake key
					else // are they a normal player or not in stealth mode/using a fake key?
						stat("[player.key]", playing) // show them normally

	proc/AttemptLateSpawn(var/datum/job/JOB, force=0)
		if (!JOB)
			return
		if (src.is_respawned_player && (src.client.preferences.real_name in src.client.player.joined_names) && !src.client.preferences.be_random_name)
			tgui_alert(src, "Please pick a different character to respawn as, you've already joined this round as [src.client.preferences.real_name]. You can select \"random appearance\" in character setup if you don't want to make a new character.")
			return
		global.latespawning.lock()

		if (JOB && (force || job_controls.check_job_eligibility(src, JOB, STAPLE_JOBS | SPECIAL_JOBS)))
			var/mob/character = create_character(JOB, JOB.can_roll_antag)
			if (isnull(character))
				global.latespawning.unlock()
				return
			JOB.assigned++
			if (JOB.player_requested || JOB == job_controls.priority_job)
				SPAWN(0) // don't pause late spawning for this
					var/limit_reached = JOB.limit <= JOB.assigned
					var/list/req_prio = list()
					if (JOB.player_requested)
						req_prio += "requested"
					if (JOB == job_controls.priority_job)
						req_prio += "priority"
					var/message = "RoleControl notification: [english_list(req_prio, "")] role [JOB.name] hired[limit_reached ? " (limit reached, clearing [english_list(req_prio, "")] status)" : ""]"
					if (JOB.player_requested && limit_reached)
						JOB.player_requested = FALSE
					if (JOB == job_controls.priority_job && limit_reached)
						job_controls.priority_job = null
					var/datum/signal/pdaSignal = get_free_signal()
					pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="COMMAND-MAILBOT", "group"=list(MGD_COMMAND), "sender"="00000000", "message"=message)
					radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)
			if (JOB.counts_as)
				var/datum/job/other = find_job_in_controller_by_string(JOB.counts_as)
				other.assigned++
			// Stop adding non game mode logic BEFORE game modes!
			if(istype(ticker.mode, /datum/game_mode/football))
				var/datum/game_mode/football/F = ticker.mode
				F.init_player(character, 0, 1)
			else if(istype(ticker.mode, /datum/game_mode/pod_wars))
				var/datum/game_mode/pod_wars/mode = ticker.mode
				mode.add_latejoin_to_team(character.mind, JOB)
			else if(istype(ticker.mode, /datum/game_mode/battle_royale))
				var/datum/game_mode/battle_royale/battlemode = ticker.mode
				if (current_state < GAME_STATE_FINISHED)
					battlemode.battlersleft_hud.add_client(character.client)
				if(ticker.round_elapsed_ticks > 3000) // no new people after 5 minutes
					boutput(character.mind.current,"<h3 class='notice'>You've arrived on a station with a battle royale in progress! Feel free to spectate!</h3>")
					character.ghostize()
					qdel(character)
					return
				character.set_loc(pick_landmark(LANDMARK_BATTLE_ROYALE_SPAWN))
				equip_battler(character)
				character.mind.assigned_role = "MODE"
				character.mind.special_role = ROLE_BATTLER
				battlemode.living_battlers.Add(character.mind)
				DEBUG_MESSAGE("Adding a new battler")
				battlemode.battle_shuttle_spawn(character.mind)
			else if (JOB.special_spawn_location)
				var/location = JOB.special_spawn_location
				if (!istype(JOB.special_spawn_location, /turf))
					location = pick_landmark(JOB.special_spawn_location)
				if (!isnull(location))
					character.set_loc(location)
			else if (istype(JOB, /datum/job/special/stowaway))
				var/list/obj/storage/SL = get_random_station_storage_list(closed=TRUE, breathable=TRUE)
				if(length(SL) > 0)
					boutput(character.mind.current,"<h3 class='notice'>You've arrived in a nondescript container! Good luck!</h3>")
					character.set_loc(pick(SL))
					logTheThing(LOG_STATION, src, "has the Stowaway job and spawns in storage at [log_loc(src)]")
				else
					var/starting_loc = null
					starting_loc = pick_landmark(LANDMARK_LATEJOIN, locate(round(world.maxx / 2), round(world.maxy / 2), 1))
					character.set_loc(starting_loc)
					logTheThing(LOG_STATION, src, "has the Stowaway job but there were no valid containers to stow into!")
			else if (character.traitHolder && character.traitHolder.hasTrait("pilot"))
				if (istype(character.loc, /obj/machinery/vehicle))
					boutput(character.mind.current,"<h3 class='notice'>You've become lost on your way to the station! Good luck!</h3>")
			else if (character.traitHolder && character.traitHolder.hasTrait("sleepy"))
				var/datum/trait/T = character.traitHolder.getTrait("sleepy")
				SPAWN(T.spawn_delay)
					boutput(character?.mind?.current,"<h3 class='notice'>Hey, you! You're finally awake!</h3>")
				//As with the Stowaway trait, location setting is handled elsewhere.
			else if (character.traitHolder && character.traitHolder.hasTrait("partyanimal"))
				var/datum/trait/T = character.traitHolder.getTrait("partyanimal")
				var/list/valid_tables = list()
				var/list/table_turfs = list()

				for_by_tcl(table, /obj/table)
					if (table.z != Z_LEVEL_STATION)
						continue
					var/area/table_area = get_area(table)
					var/is_bar = istype(table_area, /area/station/crew_quarters/bar) || istype(table_area, /area/station/crew_quarters/cafeteria)
					if (!is_bar)
						continue
					if (locate(/mob/living/carbon/human) in get_turf(table))
						continue
					valid_tables += table
					table_turfs += get_turf(table)

				if (length(valid_tables) > 0)
					var/picked_table = pick(valid_tables)
					var/starting_loc = get_turf(picked_table)
					character.set_loc(starting_loc)
					character.layer = 2.5 // so that they wake up under a table

					var/turf/new_turf = null
					for (var/turf/spot in orange(1, character))
						if (!jpsTurfPassable(spot, source=get_turf(character), passer=character)) // Make sure we can walk there
							continue
						if(spot in table_turfs) // Ensure we don't move to another table tile
							continue
						new_turf = spot
						break
					if (new_turf)
						SPAWN(T.spawn_delay) // Move from under the table
							character.step_towards_movedelay(new_turf)
							character.layer = initial(character.layer)
					else
						character.layer = initial(character.layer)

					boutput(character?.mind?.current,"<h3 class='notice'>Man, what a party, eh? Anyway, good luck!</h3>")
			else if (istype(character.mind.purchased_bank_item, /datum/bank_purchaseable/space_diner))
				// Location is set in bank_purchaseable Create()
				boutput(character.mind.current,"<h3 class='notice'>You've arrived through an alternative mode of travel! Good luck!</h3>")
			else if (istype(ticker.mode, /datum/game_mode/assday))
				character.set_loc(pick_landmark(LANDMARK_BATTLE_ROYALE_SPAWN))
			else if (map_settings?.arrivals_type == MAP_SPAWN_CRYO)
				var/obj/cryotron/starting_loc = null
				if (ishuman(character) && by_type[/obj/cryotron])
					starting_loc = pick(by_type[/obj/cryotron])

				if (istype(starting_loc))
					starting_loc.add_person_to_queue(character, JOB)
				else
					starting_loc = pick_landmark(LANDMARK_LATEJOIN, locate(1, 1, 1))
					character.set_loc(starting_loc)
			else if (map_settings?.arrivals_type == MAP_SPAWN_MISSILE)
				latejoin_missile_spawn(character)
			else
				var/starting_loc = null
				starting_loc = pick_landmark(LANDMARK_LATEJOIN, locate(round(world.maxx / 2), round(world.maxy / 2), 1))
				character.set_loc(starting_loc)

			var/player_count = 0
			for (var/client/client in clients)
				if (!client?.mob) //?????? Byond??? Lummox??? Help??????
					continue
				if (!istype(client.mob.loc, /obj/cryotron) && !istype(client.mob, /mob/new_player)) //don't count cryoed or lobby players
					player_count++
			for(var/datum/job/staple_job in job_controls.staple_jobs) //we'll just assume only staple jobs have variable limits for now
				if (staple_job.variable_limit)
					staple_job.recalculate_limit(player_count)

			if (isliving(character))
				var/mob/living/LC = character
				if(!istype(JOB,/datum/job/battler) && !istype(JOB, /datum/job/football))
					LC.Equip_Rank(JOB.name, joined_late=1)

			spawn_rules_controller.apply_to(character)

#ifdef CREW_OBJECTIVES
			if (ticker && character.mind)
				ticker.generate_individual_objectives(character.mind)
#endif

			if (manualbreathing)
				boutput(character, "<B>You must breathe manually using the *inhale and *exhale commands!</B>")
			if (manualblinking)
				boutput(character, "<B>You must blink manually using the *closeeyes and *openeyes commands!</B>")

			if (ticker && character.mind)
				character.mind.join_time = world.time
				if (!(character.mind in ticker.minds))
					logTheThing(LOG_DEBUG, character, "<b>Late join:</b> added player to ticker.minds. [character.mind.on_ticker_add_log()]")
					ticker.minds += character.mind
				logTheThing(LOG_DEBUG, character, "<b>Late join:</b> assigned job: [JOB.name]")
				//if they have a ckey, joined before a certain threshold and the shuttle wasnt already on its way
				if (character.mind.ckey && (ticker.round_elapsed_ticks <= MAX_PARTICIPATE_TIME) && !emergency_shuttle.online)
					var/datum/player/P = character.mind.get_player()
					participationRecorder.record(P)

			// Apply any roundstart mutators to late join if applicable
			var/mob/living/LM = character
			if(istype(LM))
				LM.apply_roundstart_events()

			//picky eater trait handling
			if (ishuman(character) && character.traitHolder?.hasTrait("picky_eater"))
				var/datum/trait/picky_eater/eater_trait = character.traitHolder.getTrait("picky_eater")
				if (length(eater_trait.fav_foods) > 0)
					boutput(character, eater_trait.explanation_text)
					character.mind.store_memory(eater_trait.explanation_text)

			SPAWN(0)
				qdel(src)
			global.latespawning.unlock()

		else
			global.latespawning.unlock()
			tgui_alert(src, "[JOB.name] is not available. Please try another.", "Job unavailable")

		return

	proc/AttemptSiliconLateSpawn(obj/item/organ/brain/latejoin/latejoin)
		if (jobban_isbanned(src, "Cyborg"))
			boutput(src, SPAN_NOTICE("Sorry, you are banned from playing silicons."))
			return

		if (latejoin.activated)
			boutput(src, SPAN_NOTICE("Sorry, that Silicon has already been taken control of."))
			return

		// the brain is in the head, which is in the silicon mob
		var/mob/living/silicon/S = latejoin.find_parent_of_type(/mob/living/silicon)
		if (!S)
			return

		latejoin.activated = TRUE
		latejoin.name_prefix("activated")
		latejoin.UpdateName()
		latejoin.color = json_decode("\[-0.152143,1.02282,-0.546681,1.28769,-0.143153,0.610996,-0.135547,0.120332,0.935685\]")
		latejoin.owner = src.mind
		src.mind.transfer_to(S)

		if (S.emagged)
			logTheThing(LOG_STATION, src, "[key_name(S)] late-joins as an emagged cyborg.")
			S.mind?.add_antagonist(ROLE_EMAGGED_ROBOT, respect_mutual_exclusives = FALSE, source = ANTAGONIST_SOURCE_LATE_JOIN)
		else if (S.syndicate)
			logTheThing(LOG_STATION, src, "[key_name(S)] late-joins as an syndicate cyborg.")
			S.mind?.add_antagonist(ROLE_SYNDICATE_ROBOT, respect_mutual_exclusives = FALSE, source = ANTAGONIST_SOURCE_LATE_JOIN)

		if (isAI(S))
			S.job = "AI"
			S.mind.assigned_role = "AI"
		else
			S.job = "Cyborg"
			S.mind.assigned_role = "Cyborg"

		S.traitHolder.removeTrait("cyber_incompatible")
		S.mind.join_time = world.time
		logTheThing(LOG_DEBUG, S, "<b>Late join:</b> added player to ticker.minds. [S.mind.on_ticker_add_log()]")
		ticker.minds += S.mind

		S.Equip_Bank_Purchase(S.mind?.purchased_bank_item)
		S.apply_roundstart_events()
		S.show_laws()

		SPAWN(1 DECI SECOND)
			S.bioHolder?.mobAppearance?.pronouns = S.client.preferences.AH.pronouns
			S.choose_name()
			qdel(src)

	proc/LateChoices()
		if (!global.ticker.mode)
			return

		if (istype(global.ticker.mode, /datum/game_mode/construction))
			src.AttemptLateSpawn(new /datum/job/special/station_builder)
			return

		if (istype(global.ticker.mode, /datum/game_mode/battle_royale))
			src.AttemptLateSpawn(new /datum/job/battler)
			return

		if (istype(global.ticker.mode, /datum/game_mode/football))
			src.AttemptLateSpawn(new /datum/job/football)
			return

		if (istype(global.ticker.mode, /datum/game_mode/pod_wars))
			var/datum/game_mode/pod_wars/mode = global.ticker.mode
			if (length(mode.team_NT?.members) > length(mode.team_SY?.members))
				src.AttemptLateSpawn(new /datum/job/special/pod_wars/syndicate, TRUE)
			else
				src.AttemptLateSpawn(new /datum/job/special/pod_wars/nanotrasen, TRUE)

			return

		global.latejoin_menu.ui_interact(src)
		src.bank_menu ||= new()
		src.bank_menu.ui_interact(src)

	proc/create_character(var/datum/job/J, var/allow_late_antagonist = 0)
		if (!src || !src.mind || !src.client)
			return null
#ifdef I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO
		src.client.preferences.savefile_load(src.client)
#endif
		if (!J)
			J = find_job_in_controller_by_string(src.mind.assigned_role)

		src.spawning = 1

		var/turf/spawn_turf = null
		if(!(LANDMARK_LATEJOIN in landmarks))
			// the middle of the map is GeNeRaLlY part of the actual station. moreso than 1,1,1 at least
			var/midx = round(world.maxx / 2)
			var/midy = round(world.maxy / 2)
			var/msg = "No latejoin landmarks placed, dumping [src] to ([midx], [midy], 1)"
			message_admins(msg)
			stack_trace(msg)
			spawn_turf = locate(midx,midy,1)
		else
			spawn_turf = pick_landmark(LANDMARK_LATEJOIN)

		if(force_random_names)
			src.client.preferences.be_random_name = 1
		if(force_random_looks)
			src.client.preferences.be_random_look = 1

		var/mob/new_character = null
		if (J)
			new_character = new J.mob_type(spawn_turf, client.preferences.AH, client.preferences, FALSE, src.mind?.assigned_role)
		else
			// fallback
			new_character = new /mob/living/carbon/human(spawn_turf, client.preferences.AH, client.preferences, FALSE, src.mind?.assigned_role)
		new_character.set_dir(pick(NORTH, EAST, SOUTH, WEST))
		if (!J || J.uses_character_profile)//borg joins don't lock out your character profile
			src.client.player.joined_names += (src.client.preferences.be_random_name ? new_character.real_name : src.client.preferences.real_name)
		else //don't use flavor text if we're not using the profile
			new_character.bioHolder.mobAppearance.flavor_text = null

		close_spawn_windows()

		if(ishuman(new_character))
			var/mob/living/carbon/human/H = new_character
			H.update_colorful_parts()

		mind.transfer_to(new_character)

		// Latejoin antag stuff

		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/assday))
			var/bad_type = ROLE_TRAITOR
			makebad(new_character, bad_type)
			new_character.mind.late_special_role = 1
			logTheThing(LOG_DEBUG, new_character, "<b>Late join</b>: assigned antagonist role: [bad_type].")
		else
			if (ishuman(new_character) && allow_late_antagonist && current_state == GAME_STATE_PLAYING && ticker.round_elapsed_ticks >= 6000 && emergency_shuttle.timeleft() >= 300 && !src.is_respawned_player) // no new evils for the first 10 minutes or last 5 before shuttle
				if (late_traitors && ticker.mode.latejoin_antag_compatible && !(jobban_isbanned(new_character, "Syndicate")))
					var/livingtraitor = 0

					for(var/datum/mind/brain in ticker.minds)
						if(brain.current && brain.is_antagonist())
							if (issilicon(brain.current) || isdead(brain.current) || brain.current.client == null) // if a silicon mob, dead or logged out, skip
								continue

							livingtraitor = TRUE
							logTheThing(LOG_DEBUG, null, "<b>Late join</b>: checking [new_character.ckey], found livingtraitor [brain.key].")
							break

					var/bad_type = null
					if (islist(ticker.mode.latejoin_antag_roles) && length(ticker.mode.latejoin_antag_roles))
						//Another one I need input on
						if(ticker.mode.latejoin_antag_roles[ROLE_TRAITOR] != null)
							bad_type = weighted_pick(ticker.mode.latejoin_antag_roles);
						else
							bad_type = pick(ticker.mode.latejoin_antag_roles)
					else
						bad_type = ROLE_TRAITOR

					// Check if they have this antag type enabled. If not, too bad!
					// get_preference_for_role can't handle antag types under 'misc' like wrestler or wolf, so we need to special case those
					var/antag_enabled = new_character.client?.preferences.vars[get_preference_for_role(bad_type) || get_preference_for_role(ROLE_MISC)]
					if (antag_enabled && J.can_be_antag(bad_type))
						if ((!livingtraitor && prob(40)) || (livingtraitor && !ticker.mode.latejoin_only_if_all_antags_dead && prob(4)))
							makebad(new_character, bad_type)
							new_character.mind.late_special_role = TRUE
							logTheThing(LOG_DEBUG, new_character, "<b>Late join</b>: assigned antagonist role: [bad_type].")
							antagWeighter.record(role = bad_type, P = new_character.mind.get_player(), latejoin = 1)




		if(new_character?.client)
			SPAWN(0)
				new_character.client?.loadResources()

		new_character.temporary_attack_alert(1200) //Messages admins if this new character attacks someone within 2 minutes of signing up. Might help detect grief, who knows?
		new_character.temporary_suicide_alert(1500) //Messages admins if this new character commits suicide within 2 1/2 minutes. probably a bit much but whatever

		return new_character

	Move()
		SHOULD_CALL_PARENT(FALSE) // Heeding the warning

		return 1 // do not return 0 in here for the love of god, let me tell you the tale of why:
		// the default mob/Login (which got called before we actually set our loc onto the start screen), will attempt to put the mob at (1, 1, 1) if the loc is null
		// however, the documentation actually says "near" (1, 1, 1), and will count Move returning 0 as that it cannot be placed there
		// by "near" it means anywhere on the goddamn map where Move will return 1, this meant that anyone logging in would cause the server to
		// grind itself to a slow death in a caciphony of endless Move calls

	proc/makebad(mob/living/carbon/human/traitormob, type)
		if (!traitormob || !ismob(traitormob) || !traitormob.mind)
			return

		var/datum/mind/traitor = traitormob.mind
		ticker.mode.traitors += traitor

		switch (type)
			if (ROLE_TRAITOR)
				if (traitor.assigned_role)
					traitor.add_antagonist(type, source = ANTAGONIST_SOURCE_LATE_JOIN)
				else // this proc is potentially called on latejoining players before they have job equipment - we set the antag up afterwards if this is the case
					traitor.add_antagonist(type, source = ANTAGONIST_SOURCE_LATE_JOIN, late_setup = TRUE)

			if (ROLE_ARCFIEND, ROLE_SALVAGER, ROLE_CHANGELING, ROLE_VAMPIRE, ROLE_WEREWOLF, ROLE_WRESTLER, ROLE_HUNTER, ROLE_GRINCH, ROLE_WRAITH, ROLE_FLOCKMIND)
				traitor.add_antagonist(type, source = ANTAGONIST_SOURCE_LATE_JOIN)

			else // Fallback if role is unrecognized.
				traitor.special_role = ROLE_TRAITOR

	proc/close_spawn_windows()
		if (!src.client)
			return

		winshow(src, "joinmenu", FALSE)

	verb/declare_ready_use_token()
		set hidden = 1
		set name = ".ready_antag"

		if(!tgui_process)
			boutput(src, SPAN_ALERT("Stuff is still setting up, wait a moment before readying up."))
			return

		if (src.blocked_from_joining)
			return
		if (src.client.has_login_notice_pending(TRUE))
			return

		if(!(!ticker || current_state <= GAME_STATE_PREGAME))
			src.show_text("Round has already started. You can't redeem tokens now. (You have [src.client.antag_tokens].)", "red")
		else if(src.client.antag_tokens > 0)
			src.client.using_antag_token = 1
			src.show_text("Token redeemed, if mode supports redemption your new total will be [src.client.antag_tokens - 1].", "red")
		else
			src.show_text("You don't even have any tokens. How did you get here?", "red")

		src.declare_ready()

	verb/declare_ready()
		set hidden = 1
		set name = ".ready"

		if(!tgui_process)
			boutput(src, SPAN_ALERT("Stuff is still setting up, wait a moment before readying up."))
			return

		if (src.blocked_from_joining)
			return
		if (src.client.has_login_notice_pending(TRUE))
			return

		if (ticker)
			if(current_state == GAME_STATE_SETTING_UP || (current_state <= GAME_STATE_PREGAME && ticker.pregame_timeleft <= 1))
				boutput(usr, SPAN_ALERT("The round is currently being set up. Please wait."))
				return

			if (ticker.mode)
				if (istype(ticker.mode, /datum/game_mode/construction))
					var/datum/game_mode/construction/C = ticker.mode
					if (C.in_setup)
						boutput(usr, SPAN_ALERT("The round is currently being set up. Please wait."))
						return

		if(!ticker || current_state <= GAME_STATE_PREGAME)
			if(!src.ready_play)
				src.ready_play = TRUE
				src.update_joinmenu()
				if(!bank_menu)
					bank_menu = new
				bank_menu.ui_interact( usr, null )
				src.client.loadResources()
		else
			LateChoices()

	verb/cancel_ready()
		set hidden = 1
		set name = ".cancel_ready"

		if (src.client.has_login_notice_pending(TRUE))
			return

		if (ticker)
			if(ticker.pregame_timeleft <= 3 && !isadmin(usr))
				boutput(usr, SPAN_ALERT("It is too close to roundstart for you to unready. Please wait until setup finishes."))
				return
			if (ticker.mode)
				if (istype(ticker.mode, /datum/game_mode/construction))
					var/datum/game_mode/construction/C = ticker.mode
					if (C.in_setup)
						boutput(usr, SPAN_ALERT("You are already spawning, and cannot unready. Please wait until setup finishes."))
						return

		if(src.ready_play)
			src.ready_play = FALSE
			if (src.client.using_antag_token)
				src.client.using_antag_token = 0
				src.show_text("Token cancelled", "red")
			src.update_joinmenu()

		if(src.ready_tutorial)
			src.ready_tutorial = FALSE
			src.update_joinmenu()

	verb/observe_round()
		set hidden = 1
		set name = ".observe_round"

		if (src.blocked_from_joining)
			return
		if (src.client.has_login_notice_pending(TRUE))
			return

		if(tgui_alert(src, "Join the round as an observer?", "Player Setup", list("Yes", "No"), 30 SECONDS) == "Yes")
			if(!src.client) return
			var/mob/dead/observer/observer = new(src)
			if (src.client && src.client.using_antag_token) //ZeWaka: Fix for null.using_antag_token
				src.client.using_antag_token = 0
				src.show_text("Token refunded, your new total is [src.client.antag_tokens].", "red")
			src.spawning = 1

			close_spawn_windows()
			boutput(src, SPAN_NOTICE("Now teleporting."))
			logTheThing(LOG_DEBUG, src, "observes.")
			var/ASLoc = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
			if (ASLoc)
				observer.set_loc(ASLoc)

			observer.observe_round = 1
			if(client.preferences && client.preferences.be_random_name) //Wire: fix for Cannot read null.be_random_name (preferences &&)
				client.preferences.randomize_name()
			observer.real_name = client.preferences.real_name
			observer.bioHolder.mobAppearance.CopyOther(client.preferences.AH)
			observer.gender = observer.bioHolder.mobAppearance.gender
			observer.UpdateName()
			observer.apply_looks_of(client)

			if(!src.mind) src.mind = new(src)
			ticker.minds |= src.mind
			src.mind.get_player()?.joined_observer = TRUE
			src.mind.transfer_to(observer)
			if(observer?.client)
				observer.client.loadResources()

			respawn_controller.subscribeNewRespawnee(observer?.client?.ckey)

			qdel(src)

#ifdef TWITCH_BOT_ALLOWED
	proc/try_force_into_bill() //try to put the twitch mob into shittbill
		if (src.client && src.client.ckey == TWITCH_BOT_CKEY)
			for(var/mob/living/carbon/human/biker/shittybill in mobs)
				if (shittybill.z == 2) continue
				if(!src.mind) src.mind = new(src)
				src.mind.transfer_to(shittybill)
				break
#endif

#define JOINMENU_VERTICAL_OFFSET_START 24
#define JOINMENU_VERTICAL_OFFSET_PER_BUTTON 56

/mob/new_player/proc/update_joinmenu()
	if (!client || !client.authenticated)
		return

	// super conservative with client checks as we *really* don't want to crash here

	var/current_vertical_offset = JOINMENU_VERTICAL_OFFSET_START
	var/pre_game = TRUE
	if (ticker && global.current_state >= GAME_STATE_PLAYING)
		pre_game = FALSE

	if (client) winset(src, "joinmenu.button_cancel", "is-disabled=true;is-visible=false") // cancel button re-enabled as needed below

	// character setup button
	if (src.ready_play || src.ready_tutorial)
		if (client) winset(src, "joinmenu.button_charsetup", "is-disabled=true;pos=18,[current_vertical_offset]")
	else
		if (client) winset(src, "joinmenu.button_charsetup", "is-disabled=false;pos=18,[current_vertical_offset]")
	current_vertical_offset += JOINMENU_VERTICAL_OFFSET_PER_BUTTON

	// ready play / join game / cancel ready play
	if (pre_game)
		if (client) winset(src, "joinmenu.button_joingame", "is-disabled=true;is-visible=false") // hide join
		if (src.ready_play)
			if (client?.using_antag_token) // show disabled ready
				if (client) winset(src, "joinmenu.button_ready_play", "is-disabled=true;is-visible=true;pos=18,[current_vertical_offset]")
			else // remove ready, show cancel
				if (client) winset(src, "joinmenu.button_ready_play", "is-disabled=true;is-visible=false")
				if (client) winset(src, "joinmenu.button_cancel", "is-disabled=false;is-visible=true;pos=18,[current_vertical_offset]")
		else if (src.ready_tutorial) // show disabled ready
			if (client) winset(src, "joinmenu.button_ready_play", "is-disabled=true;is-visible=true;pos=18,[current_vertical_offset]")
		else // enable ready button, hide cancel
			if (client) winset(src, "joinmenu.button_ready_play", "is-disabled=false;is-visible=true;pos=18,[current_vertical_offset]")
			if (client) winset(src, "joinmenu.button_cancel", "is-disabled=true;is-visible=false")
	else // replace ready play with join game
		if (client) winset(src, "joinmenu.button_joingame", "is-disabled=false;is-visible=true;pos=18,[current_vertical_offset]")
	current_vertical_offset += JOINMENU_VERTICAL_OFFSET_PER_BUTTON

	// ready antag / cancel ready antag
	if (pre_game && client?.antag_tokens > 0) // only show ready antag button if pre game and the client has antag tokens
		if (src.ready_play)
			if (client?.using_antag_token) // hide ready antag, show cancel button
				if (client) winset(src, "joinmenu.button_ready_antag", "is-disabled=true;is-visible=false")
				if (client) winset(src, "joinmenu.button_cancel", "is-disabled=false;is-visible=true;pos=18,[current_vertical_offset]")
			else // show disabled ready antag
				if (client) winset(src, "joinmenu.button_ready_antag", "is-disabled=true;is-visible=true;pos=18,[current_vertical_offset]")
		else if (src.ready_tutorial) // show disabled ready antag
			if (client) winset(src, "joinmenu.button_ready_antag", "is-disabled=true;is-visible=true;pos=18,[current_vertical_offset]")
		else // show ready antag
			if (client) winset(src, "joinmenu.button_ready_antag", "is-disabled=false;is-visible=true;pos=18,[current_vertical_offset]")
		current_vertical_offset += JOINMENU_VERTICAL_OFFSET_PER_BUTTON
	else
		if (client) winset(src, "joinmenu.button_ready_antag", "is-disabled=true;is-visible=false")

	// observe
	if (src.ready_play || src.ready_tutorial)
		if (client) winset(src, "joinmenu.button_observe", "is-disabled=true;pos=18,[current_vertical_offset]")
	else
		if (client) winset(src, "joinmenu.button_observe", "is-disabled=false;pos=18,[current_vertical_offset]")
	current_vertical_offset += JOINMENU_VERTICAL_OFFSET_PER_BUTTON

	// ready tutorial / cancel ready tutorial
	if (global.newbee_tutorial_enabled)
		if (src.ready_play) // disabled tutorial
			if (client) winset(src, "joinmenu.button_tutorial", "is-disabled=true;is-visible=true;pos=18,[current_vertical_offset]")
		else if (src.ready_tutorial) // hide ready tutorial, show cancel here
			if (client) winset(src, "joinmenu.button_tutorial", "is-disabled=true;is-visible=false")
			if (client) winset(src, "joinmenu.button_cancel", "is-disabled=false;is-visible=true;pos=18,[current_vertical_offset]")
		else // show ready tutorial
			if (client) winset(src, "joinmenu.button_tutorial", "is-disabled=false;is-visible=true;pos=18,[current_vertical_offset]")
		current_vertical_offset += JOINMENU_VERTICAL_OFFSET_PER_BUTTON

	if(client) winset(src, "joinmenu", "size=240x[current_vertical_offset]")

	if(client)
		winshow(src, "joinmenu", 1)

#undef JOINMENU_VERTICAL_OFFSET_START
#undef JOINMENU_VERTICAL_OFFSET_PER_BUTTON
