
var/global/datum/mutex/limited/latespawning = new(5 SECONDS)
/mob/new_player
	anchored = ANCHORED

	var/ready = 0
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

	New()
		. = ..()
		START_TRACKING
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_ALWAYS)
	#ifdef I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO
		ready = TRUE
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
		..()

		if(!mind)
			mind = new(src)
			keyd = mind.key

		if (src.client?.player) //playtime logging stuff
			var/datum/player/P = src.client.player
			if (!isnull(P.round_join_time) && isnull(P.round_leave_time)) //they likely died but didnt d/c b4 respawn
				P.log_leave_time()

		new_player_panel()
		src.set_loc(pick_landmark(LANDMARK_NEW_PLAYER, locate(1,1,1)))
		src.sight |= SEE_TURFS


		// byond members get a special join message :]
		if (src.client?.IsByondMember())
			var/list/msgs_which_are_gifs = list(8, 9, 10) //not all of these are normal jpgs
			var/num = rand(1,16)
			var/resource = resource("images/member_msgs/byond_member_msg_[num].[(num in msgs_which_are_gifs) ? "gif" : "jpg"]")
			boutput(src, "<img src='[resource]' style='margin: auto; display: block; max-width: 100%;'>")


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
				spawned_in_keys += "[src.ckey]"
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
		ready = 0
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
					winshow(src.last_client, "pregameBrowser", 0)
					src.last_client << browse("", "window=pregameBrowser")
		return

	verb/new_player_panel()
		set src = usr
		if(client)
			winset(src, "joinmenu.button_charsetup", "is-disabled=false")
		// drsingh i put the extra ifs here. i think its dumb but there's a bad client error here so maybe it's somehow going away in winset because byond is shitty
		if(client)
			if(ticker && current_state >= GAME_STATE_PLAYING)
				winset(src, "joinmenu.button_joingame", "is-disabled=false;is-visible=true")
				winset(src, "joinmenu.button_ready", "is-disabled=true;is-visible=false")
			else
				winset(src, "joinmenu.button_ready", "is-disabled=false;is-visible=true")
				winset(src, "joinmenu.button_joingame", "is-disabled=true;is-visible=false")
		if(client)
			winset(src, "joinmenu.button_cancel", "is-disabled=true;is-visible=false")
		if(client)
			winshow(src, "joinmenu", 1)
		if(client?.antag_tokens > 0 && (!ticker || current_state <= GAME_STATE_PREGAME))
			winset(src, "joinmenu.button_ready_antag", "is-disabled=false;is-visible=true")
			winset(src, "joinmenu", "size=240x256")
			winset(src, "joinmenu.observe", "pos=18,192")
		else if(client) // this shouldn't be necessary but it is
			winset(src, "joinmenu", "size=240x200")
			winset(src, "joinmenu.observe", "pos=18,136")
			winset(src, "joinmenu.button_ready_antag", "is-disabled=true;is-visible=false")
		if(src.ready)
			if (client) winset(src, "joinmenu.button_charsetup", "is-disabled=true")
			if (client) winset(src, "joinmenu.button_ready", "is-disabled=true;is-visible=false")
			if (client) winset(src, "joinmenu.button_cancel", "is-disabled=false;is-visible=true")
			if (client) winset(src, "joinmenu.button_ready_antag", "is-disabled=true")
		#ifndef NO_PREGAME_HTML
		if(pregameHTML && client)
			winshow(client, "pregameBrowser", 1)
			client << browse(pregameHTML, "window=pregameBrowser")
			src.pregameBrowserLoaded = TRUE
		else if(client)
			winshow(src.last_client, "pregameBrowser", 0)
			src.last_client << browse("", "window=pregameBrowser")
		#endif

	Stat()
		..()
		if(current_state <= GAME_STATE_PREGAME)
			statpanel("Lobby")
			if(client.statpanel=="Lobby" && ticker)
				for (var/client/C)
					var/mob/new_player/player = C.mob
					if (!istype(player)) continue

					if (player.client.holder && (player.client.stealth || player.client.alt_key)) // are they an admin and in stealth mode/have a fake key?
						if (client.holder) // are we an admin?
							stat("[player.key] (as [player.client.fakekey])", (player.ready)?("(Playing)"):(null)) // give us the full deets
						else // are we not an admin?
							stat("[player.client.fakekey]", (player.ready)?("(Playing)"):(null)) // only show the fake key
					else // are they a normal player or not in stealth mode/using a fake key?
						stat("[player.key]", (player.ready)?("(Playing)"):(null)) // show them normally

	Topic(href, href_list[])
		if(href_list["SelectedJob"])
			if (src.spawning)
				return

			if (!enter_allowed)
				boutput(usr, SPAN_NOTICE("There is an administrative lock on entering the game!"))
				return

			var/datum/job/JOB = null
			var/mob/living/silicon/S = null

			if (ticker?.mode)
				S = locate(href_list["SelectedJob"]) in mobs
				if(S)
					if(istype(S, /mob/living/silicon/robot))
						JOB = get_singleton(/datum/job/civilian/cyborg)
					else if(istype(S, /mob/living/silicon/ai))
						JOB = get_singleton(/datum/job/civilian/AI)
				else if (istype(ticker.mode, /datum/game_mode/construction))
					var/datum/game_mode/construction/C = ticker.mode
					JOB = locate(href_list["SelectedJob"]) in C.enabled_jobs
				else
					var/list/alljobs = job_controls.staple_jobs | job_controls.special_jobs
					JOB = locate(href_list["SelectedJob"]) in alljobs

				if(!istype(JOB))
					stack_trace("Unknown job: [JOB] [href_list["SelectedJob"]]")

				if(href_list["latejoin"] == "prompt")
					var/wiki_link = JOB.wiki_link
					var/who_we_joining_as = JOB.name
					if(S)
						who_we_joining_as += " " + S.name
					var/list/alert_buttons = wiki_link ? list("Join", "Cancel", "Wiki") : list("Join", "Cancel")
					var/alert_response = tgui_alert(usr, "Join as [who_we_joining_as]?", "Join as [who_we_joining_as]?", alert_buttons)
					if(alert_response == "Cancel" || isnull(alert_response))
						return
					else if(alert_response == "Wiki")
						usr << link(wiki_link)
						return
				else if(href_list["latejoin"] != "join")
					stack_trace("Unknown latejoin link: [href_list["latejoin"]]")

				if (S)
					if(jobban_isbanned(src, "Cyborg"))
						boutput(usr, SPAN_NOTICE("Sorry, you are banned from playing silicons."))
						close_spawn_windows()
						return
					var/obj/item/organ/brain/latejoin/latejoin = IsSiliconAvailableForLateJoin(S)
					if(latejoin)
						close_spawn_windows()
						latejoin.activated = TRUE
						latejoin.name_prefix("activated")
						latejoin.UpdateName()
						latejoin.color = json_decode("\[-0.152143,1.02282,-0.546681,1.28769,-0.143153,0.610996,-0.135547,0.120332,0.935685\]") //spriters beware
						latejoin.owner = src.mind
						src.mind.transfer_to(S)
						if (S.emagged)
							logTheThing(LOG_STATION, src, "[key_name(S)] late-joins as an emagged cyborg.")
							S.mind?.add_antagonist(ROLE_EMAGGED_ROBOT, respect_mutual_exclusives = FALSE, source = ANTAGONIST_SOURCE_LATE_JOIN)
						else if (S.syndicate)
							logTheThing(LOG_STATION, src, "[key_name(S)] late-joins as an syndicate cyborg.")
							S.mind?.add_antagonist(ROLE_SYNDICATE_ROBOT, respect_mutual_exclusives = FALSE, source = ANTAGONIST_SOURCE_LATE_JOIN)
						S.Equip_Bank_Purchase(S.mind?.purchased_bank_item)
						S.apply_roundstart_events()
						S.show_laws()
						SPAWN(1 DECI SECOND)
							S.bioHolder?.mobAppearance?.pronouns = S.client.preferences.AH.pronouns
							S.choose_name()
							qdel(src)
					else
						close_spawn_windows()
						boutput(usr, SPAN_NOTICE("Sorry, that Silicon has already been taken control of."))
				else
					AttemptLateSpawn(JOB)

		if(href_list["preferences"])
			if (!ready)
				client.preferences.process_link(src, href_list)
		else if(!href_list["late_join"])
			new_player_panel()

	proc/IsSiliconAvailableForLateJoin(var/mob/living/silicon/S)
		if (isdead(S))
			return 0

		if (istype(S,/mob/living/silicon/ai))
			var/mob/living/silicon/ai/AI = S
			var/obj/item/organ/brain/latejoin/latejoin = AI.brain
			if (istype(latejoin) && !latejoin.activated)
				return latejoin
		if (istype(S,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = S
			var/obj/item/organ/brain/latejoin/latejoin = R.part_head?.brain
			if (istype(latejoin) && !latejoin.activated)
				return latejoin
		return 0


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
				//ticker.implant_skull_key() // This also checks if a key has been implanted already or not. If not then it'll implant a random sucker with a key.
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

	/// create a set of latejoin cards for a job
	proc/LateJoinLink(var/datum/job/J)
		if (J.no_late_join)
			return

		var/limit = J.limit
		var/c = J.assigned
		var/allowed = TRUE
		if (limit == 0 && c == 0)
			// 0 slots, nobody in it, don't show it
			return

		if (!job_controls.check_job_eligibility(src, J, STAPLE_JOBS | SPECIAL_JOBS))
			// Show unavailable jobs, but no joining them
			allowed = FALSE

		//If it's Revolution time, lets show all command jobs as filled to (try to) prevent metagaming.
		if(istype(J, /datum/job/command/) && istype(ticker.mode, /datum/game_mode/revolution))
			c = max(c, limit)

		var/hover_text = J.short_description || "Join the round as [J.name]."

		// probalby could be a define but dont give a shite
		var/maxslots = 5
		var/list/slots = list()
		var/shown = clamp(c, (limit == -1 ? maxslots : limit), maxslots)
		// if there's still an open space, show a final join link
		if (limit == -1 || (limit > maxslots && c < limit))
			slots += {"<a href='byond://?src=\ref[src];
			SelectedJob=\ref[J];latejoin=join' class='latejoin-card' style='border-color: [J.linkcolor];
			' title='[hover_text]'>&#x2713;
			&#xFE0E;
			</a>"}
		// show slots up to the limit
		// extra people beyond the limit will be shown as a [+X] card, supposedly
		for (var/i = shown, i > 0, i--)
			// can you believe all these slot appendages were in one line before using nested ternaries? awful.
			if (i <= c)
				if (i == 1 && c > shown)
					// display +X card
					slots += {"
					<div
					class='latejoin-card latejoin-full'
					style='border-color: [J.linkcolor]; background-color: [J.linkcolor];'
					title='Slot filled.'
					>+[c - maxslots]
					</div>
					"}
				else
					// display crossed out card
					slots += {"
					<div
					class='latejoin-card latejoin-full'
					style='border-color: [J.linkcolor]; background-color: [J.linkcolor];'
					title='Slot filled.'
					>&times;
					</div>
					"}
			else
				if(allowed)
					// display joinable slot
					slots += {"
					<a
					href='byond://?src=\ref[src];SelectedJob=\ref[J];latejoin=join'
					class='latejoin-card' style='border-color: [J.linkcolor];'
					title='[hover_text]'
					>&#x2713;&#xFE0E;
					</a>
					"}
				else
					// display faded empty slot
					slots += {"
					<div
					class ='latejoin-card latejoin-full'
					style='border-color: [J.linkcolor]; background-color: [J.linkcolor];'
					title='Job unavailable.'
					>&#xA0;
					</div>
					"}
		return {"
			<tr>
				<td class='latejoin-link[J.is_highlighted() ? " highlighted" : ""]'>
					[((limit == -1 || c < limit) && allowed) ? "<a href='byond://?src=\ref[src];SelectedJob=\ref[J];latejoin=prompt' style='color: [J.linkcolor];[istype(J, /datum/job/civilian/clown) ? "font-family: Comic Sans MS;" : ""]' title='[hover_text]'>[J.name]</a>" : "<span style='color: [J.linkcolor];' title='This job is unavailable.'>[J.name]</span>"]
				</td>
				<td class='latejoin-cards'>[jointext(slots, " ")]</td>
			</tr>
			"}

	proc/LateChoices()
		// shut up
		var/header_thing_chui_toggle = (usr.client && !usr.client.use_chui) ? {"
		<title>Select a Job</title>
		<style type='text/css'>
			body { background: #222; color: white; font-family: Tahoma, sans-serif; }
		</style>"} : ""

		var/dat = {"
[header_thing_chui_toggle]
<style type='text/css'>
.latejoin-cards {
	white-space: nowrap;
	min-width: 12em;
	text-align: left;
	}
.latejoin td {
	padding: 0.1em;
	}
.latejoin-link {
	max-width: 12em;
	padding: 0.2em 0;
	}
.latejoin-link > * {
	display: block;
	text-align: right;
	padding-right: 1em;
	}
.latejoin-link > a {
	font-weight: bold;
	}
.latejoin-link a:hover {
	background-color: #555;
	}

.latejoin-link span {
	opacity: 0.6;
	}

.latejoin-card {
	display: inline-block;
	padding: 0.0em 0.1em;
	border: 2px solid black;
	background: #fff;
	border-radius: 3px;
	min-width: 1em;
	text-align: center;
	font-size: 90%;
	text-decoration: none;
	font-weight: bold;
	}

.latejoin-full {
	opacity: 0.4;
	color: black;
	}

a.latejoin-card {
	box-shadow: -0.5px -0.5px 3px 1px rgba(255, 255, 255, 0.7);
	color: white;
	}

a.latejoin-card:hover {
	color: black;
	box-shadow: 0 0 6px 2px white;
	}

.latejoin th {
	background: #555;
	padding: 0.3em;
	margin-top: 0.5em;
}
.fuck {
	max-width: 48%;
	display: inline-block;
	vertical-align: top;
	margin: 0 1em;
}
.highlighted {
	border: 4px solid #FFE251;
	border-radius: 3px;
}
</style>
<h2 style='text-align: center; margin: 0 0 0.3em 0; font-size: 150%;'>You are joining a round in progress.</h2>
<h3 style='text-align: center; margin: 0 0 0.5em 0; font-size: 120%;'>Please choose from one of the remaining open positions.</h3>
<div style='text-align: center;'>
"}

		// deal with it
		dat += ""
		if (ticker.mode && !istype(ticker.mode, /datum/game_mode/construction) && !istype(ticker.mode,/datum/game_mode/battle_royale) && !istype(ticker.mode,/datum/game_mode/football) && !istype(ticker.mode,/datum/game_mode/pod_wars))
			dat += {"<div class='fuck'><table class='latejoin'><tr><th colspan='2'>Command / Security</th></tr>"}
			for(var/datum/job/command/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			for(var/datum/job/security/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			//dat += "</table></td>"

			dat += {"<tr><td colspan='2'>&nbsp;</td></tr><tr><th colspan='2'>Research / Medical</th></tr>"}
			for(var/datum/job/research/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			for(var/datum/job/medical/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			//dat += "</table></td>"

			//dat += {"<td valign="top"><table>"}
			dat += {"<tr><td colspan='2'>&nbsp;</td></tr><tr><th colspan='2'>Engineering / Supply</th></tr>"}
			for(var/datum/job/engineering/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			dat += {"</table></div><div class='fuck'><table class='latejoin'><tr><th colspan='2'>Crew Service / Silicon</th></tr>"}

			for(var/datum/job/civilian/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)

			for(var/datum/job/daily/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)

			// not showing if it's an ai or cyborg is the worst fuckin shit so: FIXED
			for(var/mob/living/silicon/S in mobs)
				if (IsSiliconAvailableForLateJoin(S))
					var/sili_type = istype(S, /mob/living/silicon/ai) ? "AI" : "Cyborg"
					var/hover_text = "Join as [sili_type]."
					if(istype(S, /mob/living/silicon/robot))
						hover_text = get_singleton(/datum/job/civilian/cyborg).short_description
					else if(istype(S, /mob/living/silicon/ai))
						hover_text = get_singleton(/datum/job/civilian/AI).short_description
					dat += {"<tr><td colspan='2' class='latejoin-link'><a href='byond://?src=\ref[src];SelectedJob=\ref[S];latejoin=prompt' style='color: #c4c4c4; text-align: center;' title='[hover_text]'>[S.name] ([sili_type])</a></td></tr>"}

			// is this ever actually off? ?????
			if (job_controls.allow_special_jobs)
				dat += {"<tr><td colspan='2'>&nbsp;</td></tr><tr><th colspan='2'>Special Jobs</th></tr>"}

				for(var/datum/job/special/J in job_controls.special_jobs)
					// if (job_controls.check_job_eligibility(src, J, SPECIAL_JOBS) && !J.no_late_join)
					dat += LateJoinLink(J)

				for(var/datum/job/created/J in job_controls.special_jobs)
					// if (job_controls.check_job_eligibility(src, J, SPECIAL_JOBS) && !J.no_late_join)
					dat += LateJoinLink(J)

			dat += "</table></div>"

		else if(istype(ticker.mode,/datum/game_mode/battle_royale))
			//ahahaha you get no choices im going to just shove you in the game now good luck
			AttemptLateSpawn(new /datum/job/battler)
			return
		else if(istype(ticker.mode,/datum/game_mode/football))
			//ahahaha you get no choices im going to just shove you in the game now good luck
			AttemptLateSpawn(new /datum/job/football)
			return
		else if(istype(ticker.mode,/datum/game_mode/pod_wars))
			//Go to the team with less members
			var/datum/game_mode/pod_wars/mode = ticker.mode

			if (mode?.team_NT?.members?.len > mode?.team_SY?.members?.len)
				AttemptLateSpawn(new /datum/job/special/pod_wars/syndicate, 1)
			else
				AttemptLateSpawn(new /datum/job/special/pod_wars/nanotrasen, 1)

			return
		else
			var/datum/game_mode/construction/C = ticker.mode
			if (!C.enabled_jobs.len)
				var/datum/job/special/station_builder/D = new /datum/job/special/station_builder()
				D.limit = -1
				C.enabled_jobs += D
			for (var/datum/job/J in C.enabled_jobs)
				if (job_controls.check_job_eligibility(src, J, STAPLE_JOBS|SPECIAL_JOBS) && !J.no_late_join)
					var/hover_text = J.short_description || "Join the round as [J.name]."
					dat += "<tr><td style='width:100%'>"
					dat += {"<a href='byond://?src=\ref[src];SelectedJob=\ref[J];latejoin=prompt' title='[hover_text]'><font color=[J.linkcolor]>[J.name]</font></a> ([J.assigned][J.limit == -1 ? "" : "/[J.limit]"])<br>"}
					dat += "</td></tr>"
		dat += "</table></div>"

		src.Browse(dat, "window=latechoices;size=800x666")
		if(!bank_menu)
			bank_menu = new
		bank_menu.ui_interact(usr ,null)

	proc/create_character(var/datum/job/J, var/allow_late_antagonist = 0)
		if (!src || !src.mind || !src.client)
			return null
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
					if (antag_enabled && job.can_be_antag(bad_type))
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
		if(client)
			src.Browse(null, "window=latechoices") //closes late choices window
			src.Browse(null, "window=playersetup") //closes the player setup window
			winshow(src, "joinmenu", 0)

	verb/declare_ready_use_token()
		set hidden = 1
		set name = ".ready_antag"

		if(!tgui_process)
			boutput(src, SPAN_ALERT("Stuff is still setting up, wait a moment before readying up."))
			return

		if (src.client.has_login_notice_pending(TRUE))
			return
		if (src.blocked_from_joining)
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

		if (src.client.has_login_notice_pending(TRUE))
			return
		if (src.blocked_from_joining)
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
			if(!ready)
				ready = 1
				if (usr.client) winset(src, "joinmenu.button_charsetup", "is-disabled=true")
				if (usr.client) winset(src, "joinmenu.button_ready", "is-disabled=true;is-visible=false")
				if (usr.client) winset(src, "joinmenu.button_cancel", "is-disabled=false;is-visible=true")
				if (usr.client) winset(src, "joinmenu.button_ready_antag", "is-disabled=true")
				usr.Browse(null, "window=mob_occupation")
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

		if(ready)
			ready = 0
			winset(src, "joinmenu.button_charsetup", "is-disabled=false")
			winset(src, "joinmenu.button_ready", "is-disabled=false;is-visible=true")
			winset(src, "joinmenu.button_cancel", "is-disabled=true;is-visible=false")
			winset(src, "joinmenu.button_ready_antag", "is-disabled=false")
			if (src.client.using_antag_token)
				src.client.using_antag_token = 0
				src.show_text("Token cancelled", "red")

	verb/observe_round()
		set hidden = 1
		set name = ".observe_round"

		if (src.client.has_login_notice_pending(TRUE))
			return
		if (src.blocked_from_joining)
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

	say(message)
		if(dd_hasprefix(message, "*"))
			return
		SEND_SIGNAL(src, COMSIG_MOB_SAY, message)
		src.ooc(message)

#ifdef TWITCH_BOT_ALLOWED
	proc/try_force_into_bill() //try to put the twitch mob into shittbill
		if (src.client && src.client.ckey == TWITCH_BOT_CKEY)
			for(var/mob/living/carbon/human/biker/shittybill in mobs)
				if (shittybill.z == 2) continue
				if(!src.mind) src.mind = new(src)
				src.mind.transfer_to(shittybill)
				break
#endif
