mob/new_player
	anchored = 1

	var/ready = 0
	var/spawning = 0
	var/keyd
	var/adminspawned = 0

#ifdef TWITCH_BOT_ALLOWED
	var/twitch_bill_spawn = 0
#endif

	invisibility = 101

	density = 0
	stat = 2
	canmove = 0

	anchored = 1	//  don't get pushed around

	var/chui/window/spend_spacebux/bank_menu

	// How could this even happen? Regardless, no log entries for unaffected mobs (Convair880).
	ex_act(severity)
		return

	disposing()
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

		new_player_panel()
		src.set_loc(pick_landmark(LANDMARK_NEW_PLAYER, locate(1,1,1)))
		src.sight |= SEE_TURFS

		if (src.ckey && !adminspawned)
			if (spawned_in_keys.Find("[src.ckey]"))
				if (!(client && client.holder) && !abandon_allowed)
					 //They have already been alive this round!!
					var/mob/dead/observer/observer = new()

					src.spawning = 1

					close_spawn_windows()
					boutput(src, "<span class='notice'>Now teleporting.</span>")
					var/ASLoc = pick_landmark(LANDMARK_OBSERVER)
					if (ASLoc)
						observer.set_loc(ASLoc)
					else
						observer.set_loc(locate(1, 1, 1))
					observer.key = key

					if (client && client.preferences)
						if (client.preferences.be_random_name)
							client.preferences.randomize_name()

						observer.name = client.preferences.real_name

					observer.real_name = observer.name
					qdel(src)

			else
				spawned_in_keys += "[src.ckey]"

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
		..()
		close_spawn_windows()
		if(!spawning)
			qdel(src)

		// Given below call, not much reason to do this if pregameHTML wasn't set
		if (pregameHTML && src.last_client)
			// Removed dupe "if (src.last_client)" check since it was still runtiming anyway
			winshow(src.last_client, "pregameBrowser", 0)
			src.last_client << browse("", "window=pregameBrowser")
		return

	verb/new_player_panel()
		set src = usr
		if(client)
			winset(src, "joinmenu.button_charsetup", "is-disabled=false")
		// drsingh i put the extra ifs here. i think its dumb but there's a bad client error here so maybe it's somehow going away in winset because byond is shitty
		if(client)
			winset(src, "joinmenu.button_ready", "is-disabled=false;is-visible=true")
		if(client)
			winset(src, "joinmenu.button_cancel", "is-disabled=true;is-visible=false")
		if(client)
			winshow(src, "joinmenu", 1)
		if(client && client.antag_tokens > 0 && (!ticker || current_state <= GAME_STATE_PREGAME))
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
		if(pregameHTML && client)
			winshow(client, "pregameBrowser", 1)
			client << browse(pregameHTML, "window=pregameBrowser")
		else if(client)
			winshow(src.last_client, "pregameBrowser", 0)
			src.last_client << browse("", "window=pregameBrowser")
/*
		var/output = "<HR><B>New Player Options</B><BR>"
		output += "<HR><br><a href='byond://?src=\ref[src];show_preferences=1'>Setup Character</A><BR><BR>"
		if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
			if(!ready)
				output += "<a href='byond://?src=\ref[src];ready=1'>Declare Ready</A><BR>"
			else
				output += "You are ready.<BR>"
		else
			output += "<a href='byond://?src=\ref[src];late_join=1'>Join Game!</A><BR>"

		output += "<BR><a href='byond://?src=\ref[src];observe=1'>Observe</A><BR>"

		src.Browse(output,"window=playersetup;size=250x200;can_close=0")
*/
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
		if(href_list["show_preferences"])
			client.preferences.ShowChoices(src)
			return 1

		if(href_list["ready"])
			if(!ready)
				if(alert(src,"Are you sure you are ready? This will lock-in your preferences.","Player Setup","Yes","No") == "Yes")
					ready = 1

		if(href_list["observe"])
			if(alert(src,"Are you sure you wish to observe? You will not be able to play this round!","Player Setup","Yes","No") == "Yes")
				if(!src.client) return
				var/mob/dead/observer/observer = new()

				src.spawning = 1

				close_spawn_windows()
				boutput(src, "<span class='notice'>Now teleporting.</span>")
				var/ASLoc = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
				if (ASLoc)
					observer.set_loc(ASLoc)
				else
					observer.set_loc(locate(1, 1, 1))
				observer.apply_looks_of(client)

				if(src.mind)
					//src.mind.dnr = 1
					src.mind.joined_observer = 1
					src.mind.transfer_to(observer)
				else
					src.mind = new /datum/mind()
					//src.mind.dnr = 1
					src.mind.joined_observer = 1
					src.mind.transfer_to(observer)

				if(client.preferences.be_random_name)
					client.preferences.randomize_name()
				observer.name = client.preferences.real_name
				observer.real_name = observer.name
				observer.Equip_Bank_Purchase(observer.mind.purchased_bank_item)

				src.client.loadResources()


				qdel(src)

		if(href_list["late_join"])
			LateChoices()

		if(href_list["SelectedJob"])
			if (src.spawning)
				return

			if (!enter_allowed)
				boutput(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
				return

			if (ticker && ticker.mode)
				var/mob/living/silicon/S = locate(href_list["SelectedJob"]) in mobs
				if (S)
					var/obj/item/organ/brain/latejoin/latejoin = IsSiliconAvailableForLateJoin(S)
					if(latejoin)
						close_spawn_windows()
						latejoin.activated = 1
						src.mind.transfer_to(S)
						SPAWN_DBG(1 DECI SECOND)
							S.choose_name()
							qdel(src)
					else
						close_spawn_windows()
						boutput(usr, "<span class='notice'>Sorry, that Silicon has already been taken control of.</span>")

				else if (istype(ticker.mode, /datum/game_mode/construction))
					var/datum/game_mode/construction/C = ticker.mode
					var/datum/job/JOB = locate(href_list["SelectedJob"]) in C.enabled_jobs
					AttemptLateSpawn(JOB)
				else
					var/list/alljobs = job_controls.staple_jobs | job_controls.special_jobs
					var/datum/job/JOB = locate(href_list["SelectedJob"]) in alljobs
					AttemptLateSpawn(JOB)

		if(href_list["preferences"])
			if (!ready)
				client.preferences.process_link(src, href_list)
		else if(!href_list["late_join"])
			new_player_panel()

	proc/IsJobAvailable(var/datum/job/JOB)
		if(!ticker || !ticker.mode)
			return 0
		if (!JOB || !istype(JOB,/datum/job/) || JOB.limit == 0)
			return 0
		if (!JOB.no_jobban_from_this_job && jobban_isbanned(src,JOB.name))
			return 0
		if (JOB.requires_whitelist)
			if (!NT.Find(src.ckey))
				return 0
		if (JOB.needs_college && !src.has_medal("Unlike the director, I went to college"))
			return 0
		if (JOB.rounds_needed_to_play && (src.client && src.client.player))
			var/round_num = src.client.player.get_rounds_participated()
			if (!isnull(round_num) && round_num < JOB.rounds_needed_to_play) //they havent played enough rounds!
				return 0
		if (JOB.limit < 0 || countJob(JOB.name) < JOB.limit)
			return 1
		return 0

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
			var/obj/item/organ/brain/latejoin/latejoin = R.brain
			if (istype(latejoin) && !latejoin.activated)
				return latejoin
		return 0


	proc/AttemptLateSpawn(var/datum/job/JOB, force=0)
		if (!JOB)
			return
		if (JOB && (force || IsJobAvailable(JOB)))
			var/mob/character = create_character(JOB, JOB.allow_traitors)
			if (isnull(character))
				return

			if(istype(ticker.mode, /datum/game_mode/football))
				var/datum/game_mode/football/F = ticker.mode
				F.init_player(character, 0, 1)

			else if (character.traitHolder && character.traitHolder.hasTrait("immigrant"))
				boutput(character.mind.current,"<h3 class='notice'>You've arrived in a nondescript container! Good luck!</h3>")
				//So the location setting is handled in EquipRank in jobprocs.dm. I assume cause that is run all the time as opposed to this.
			else if (istype(character.mind.purchased_bank_item, /datum/bank_purchaseable/space_diner) || istype(character.mind.purchased_bank_item, /datum/bank_purchaseable/mail_order))
				// Location is set in bank_purchaseable Create()
				boutput(character.mind.current,"<h3 class='notice'>You've arrived through an alternative mode of travel! Good luck!</h3>")
			else if (map_settings && map_settings.arrivals_type == MAP_SPAWN_CRYO)
				var/obj/cryotron/starting_loc = null
				if (ishuman(character) && by_type[/obj/cryotron])
					starting_loc = pick(by_type[/obj/cryotron])

				if (istype(starting_loc))
					starting_loc.add_person_to_queue(character, JOB)
				else
					starting_loc = pick_landmark(LANDMARK_LATEJOIN, locate(1, 1, 1))
					character.set_loc(starting_loc)
			else if (map_settings && map_settings.arrivals_type == MAP_SPAWN_MISSILE)
				var/obj/arrival_missile/M = unpool(/obj/arrival_missile)
				var/turf/T = pick_landmark(LANDMARK_LATEJOIN_MISSILE)
				var/missile_dir = landmarks[LANDMARK_LATEJOIN_MISSILE][T]
				M.set_loc(T)
				SPAWN_DBG(0) M.lunch(character, missile_dir)
			else if(istype(ticker.mode, /datum/game_mode/battle_royale))
				var/datum/game_mode/battle_royale/battlemode = ticker.mode
				if(ticker.round_elapsed_ticks > 3000) // no new people after 5 minutes
					boutput(character.mind.current,"<h3 class='notice'>You've arrived on a station with a battle royale in progress! Feel free to spectate, but you are not considered one of the contestants!</h3>")
					return AttemptLateSpawn(new /datum/job/special/tourist)
				character.set_loc(pick_landmark(LANDMARK_BATTLE_ROYALE_SPAWN))
				equip_battler(character)
				character.mind.assigned_role = "MODE"
				character.mind.special_role = "battler"
				battlemode.living_battlers.Add(character.mind)
				DEBUG_MESSAGE("Adding a new battler")
				battlemode.battle_shuttle_spawn(character.mind)
			else
				var/starting_loc = null
				starting_loc = pick_landmark(LANDMARK_LATEJOIN, locate(round(world.maxx / 2), round(world.maxy / 2), 1))
				character.set_loc(starting_loc)

			if (isliving(character))
				var/mob/living/LC = character
				if(!istype(JOB,/datum/job/battler) && !istype(JOB, /datum/job/football))
					LC.Equip_Rank(JOB.name, joined_late=1)

			var/miscreant = 0
#ifdef MISCREANTS
#ifndef RP_MODE
			if (ticker && !character.client.using_antag_token && character.mind && JOB.allow_traitors != 0 && prob(10))
				ticker.generate_miscreant_objectives(character.mind)
				miscreant = 1
#endif
#endif

#ifdef CREW_OBJECTIVES
			if (ticker && character.mind && !miscreant)
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
					logTheThing("debug", character, null, "<b>Late join:</b> added player to ticker.minds.")
					ticker.minds += character.mind
				logTheThing("debug", character, null, "<b>Late join:</b> assigned job: [JOB.name]")
				//if they have a ckey, joined before a certain threshold and the shuttle wasnt already on its way
				if (character.mind.ckey && (ticker.round_elapsed_ticks <= MAX_PARTICIPATE_TIME) && !emergency_shuttle.online)
					participationRecorder.record(character.mind.ckey)
			SPAWN_DBG (0)
				qdel(src)

		else
			src << alert("[JOB.name] is not available. Please try another.")

		return

	proc/LateJoinLink(var/datum/job/J)
		// This is pretty ugly but: whatever! I don't care.
		// It likely needs some tweaking but everything does.
		if (!J.no_late_join)
			var/limit = J.limit
			if (!IsJobAvailable(J))
				// Show unavailable jobs, but no joining them
				limit = 0

			var/c = countJob(J.name) 	// gross
			if (limit == 0 && c == 0)
				// 0 slots, nobody in it, don't show it
				return

			//If it's Revolution time, lets show all command jobs as filled to (try to) prevent metagaming.
			if(istype(J, /datum/job/command/) && istype(ticker.mode, /datum/game_mode/revolution))
				c = limit

			// probalby could be a define but dont give a shite
			var/maxslots = 5
			var/list/slots = list()
			var/shown = min(max(c, (limit == -1 ? 99 : limit)), maxslots)
			// if there's still an open space, show a final join link
			if (limit == -1 || (limit > maxslots && c < limit))
				slots += "<a href='byond://?src=\ref[src];SelectedJob=\ref[J]' class='latejoin-card' style='border-color: [J.linkcolor];' title='Join the round as [J.name].'>&#x2713;&#xFE0E;</a>"

			// show slots up to the limit
			// extra people beyond the limit will be shown as a [+X] card
			for (var/i = shown, i > 0, i--)
				slots += (i <= c ? "<div class='latejoin-card latejoin-full' style='border-color: [J.linkcolor]; background-color: [J.linkcolor];' title='Slot filled.'>[(i == 1 && c > shown) ? "+[c - maxslots]" : "&times;"]</div>" : "<a href='byond://?src=\ref[src];SelectedJob=\ref[J]' class='latejoin-card' style='border-color: [J.linkcolor];' title='Join the round as [J.name].'>&#x2713;&#xFE0E;</a>")

			return {"
				<tr><td class='latejoin-link'>
					[(limit == -1 || c < limit) ? "<a href='byond://?src=\ref[src];SelectedJob=\ref[J]' style='color: [J.linkcolor];' title='Join the round as [J.name].'>[J.name]</a>" : "<span style='color: [J.linkcolor];' title='This job is full.'>[J.name]</span>"]
					</td>
					<td class='latejoin-cards'>[jointext(slots, " ")]</td>
				</tr>
				"}

		return

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
</style>
<h2 style='text-align: center; margin: 0 0 0.3em 0; font-size: 150%;'>You are joining a round in progress.</h2>
<h3 style='text-align: center; margin: 0 0 0.5em 0; font-size: 120%;'>Please choose from one of the remaining open positions.</h3>
<div style='text-align: center;'>
"}

		// deal with it
		dat += ""
		if (ticker.mode && !istype(ticker.mode, /datum/game_mode/construction) && !istype(ticker.mode,/datum/game_mode/battle_royale) && !istype(ticker.mode,/datum/game_mode/football))
			dat += {"<div class='fuck'><table class='latejoin'><tr><th colspan='2'>Command/Security</th></tr>"}
			for(var/datum/job/command/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			for(var/datum/job/security/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			//dat += "</table></td>"

			dat += {"<tr><td colspan='2'>&nbsp;</td></tr><tr><th colspan='2'>Research</th></tr>"}
			for(var/datum/job/research/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			//dat += "</table></td>"

			//dat += {"<td valign="top"><table>"}
			dat += {"<tr><td colspan='2'>&nbsp;</td></tr><tr><th colspan='2'>Engineering</th></tr>"}
			for(var/datum/job/engineering/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)
			dat += {"</table></div><div class='fuck'><table class='latejoin'><tr><th colspan='2'>Civilian</th></tr>"}

			for(var/datum/job/civilian/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)

			for(var/datum/job/daily/J in job_controls.staple_jobs)
				dat += LateJoinLink(J)

			// not showing if it's an ai or cyborg is the worst fuckin shit so: FIXED
			for(var/mob/living/silicon/S in mobs)
				if (IsSiliconAvailableForLateJoin(S))
					dat += {"<tr><td colspan='2' class='latejoin-link'><a href='byond://?src=\ref[src];SelectedJob=\ref[S]' style='color: #c4c4c4; text-align: center;'>[S.name] ([istype(S, /mob/living/silicon/ai) ? "AI" : "Cyborg"])</a></td></tr>"}

			// is this ever actually off? ?????
			if (job_controls.allow_special_jobs)
				dat += {"<tr><td colspan='2'>&nbsp;</td></tr><tr><th colspan='2'>Special Jobs</th></tr>"}

				for(var/datum/job/special/J in job_controls.special_jobs)
					if (IsJobAvailable(J) && !J.no_late_join)
						dat += LateJoinLink(J)

				for(var/datum/job/created/J in job_controls.special_jobs)
					if (IsJobAvailable(J) && !J.no_late_join)
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
		else
			var/datum/game_mode/construction/C = ticker.mode
			if (!C.enabled_jobs.len)
				var/datum/job/special/station_builder/D = new /datum/job/special/station_builder()
				D.limit = -1
				C.enabled_jobs += D
			for (var/datum/job/J in C.enabled_jobs)
				if (IsJobAvailable(J) && !J.no_late_join)
					dat += "<tr><td style='width:100%'>"
					dat += {"<a href='byond://?src=\ref[src];SelectedJob=\ref[J]'><font color=[J.linkcolor]>[J.name]</font></a> ([countJob(J.name)][J.limit == -1 ? "" : "/[J.limit]"])<br>"}
					dat += "</td></tr>"
		dat += "</table></div>"

		src.Browse(dat, "window=latechoices;size=800x666")
		if(!bank_menu)
			bank_menu = new
		bank_menu.Subscribe( usr.client )

	proc/create_character(var/datum/job/J, var/allow_late_antagonist = 0)
		if (!src || !src.mind || !src.client)
			return null
		if (!J)
			J = find_job_in_controller_by_string(src.mind.assigned_role)

		src.spawning = 1

		if(!(LANDMARK_LATEJOIN in landmarks))
			// the middle of the map is GeNeRaLlY part of the actual station. moreso than 1,1,1 at least
			var/midx = round(world.maxx / 2)
			var/midy = round(world.maxy / 2)
			boutput(world, "No latejoin landmarks placed, dumping [src] to ([midx], [midy], 1)")
			src.set_loc(locate(midx,midy,1))
		else
			src.set_loc(pick_landmark(LANDMARK_LATEJOIN))

		var/mob/new_character = null
		if (J)
			new_character = new J.mob_type(src.loc)
		else
			new_character = new /mob/living/carbon/human(src.loc) // fallback

		close_spawn_windows()

		client.preferences.copy_to(new_character,src)
		var/client/C = client
		mind.transfer_to(new_character)

		if (ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/assday))
			var/bad_type = "traitor"
			makebad(new_character, bad_type)
			new_character.mind.late_special_role = 1
			logTheThing("debug", new_character, null, "<b>Late join</b>: assigned antagonist role: [bad_type].")
		else
			if (ishuman(new_character) && allow_late_antagonist && current_state == GAME_STATE_PLAYING && ticker.round_elapsed_ticks >= 6000 && emergency_shuttle.timeleft() >= 300 && !C.hellbanned) // no new evils for the first 10 minutes or last 5 before shuttle
				if (late_traitors && ticker.mode && ticker.mode.latejoin_antag_compatible == 1)
					var/livingtraitor = 0

					for(var/datum/mind/brain in ticker.minds)
						if(brain.current && checktraitor(brain.current)) // if a traitor
							if (issilicon(brain.current) || brain.current.stat & 2 || brain.current.client == null) // if a silicon mob, dead or logged out, skip
								continue

							livingtraitor = 1
							logTheThing("debug", null, null, "<b>Late join</b>: checking [new_character.ckey], found livingtraitor [brain.key].")
							break

					var/bad_type = null
					if (islist(ticker.mode.latejoin_antag_roles) && ticker.mode.latejoin_antag_roles.len)
						bad_type = pick(ticker.mode.latejoin_antag_roles)
					else
						bad_type = "traitor"

					if ((!livingtraitor && prob(40)) || (livingtraitor && ticker.mode.latejoin_only_if_all_antags_dead == 0 && prob(4)))
						makebad(new_character, bad_type)
						new_character.mind.late_special_role = 1
						logTheThing("debug", new_character, null, "<b>Late join</b>: assigned antagonist role: [bad_type].")
						antagWeighter.record(role = bad_type, ckey = new_character.ckey, latejoin = 1)




		if(new_character && new_character.client)
			new_character.client.loadResources()

#if ASS_JAM
			if(ass_mutation)
				new_character.bioHolder.AddEffect(ass_mutation)
				boutput(new_character.mind.current,"<span class='alert'>A radiation anomaly is currently affecting [the_station_name] and everyone - including you - is afflicted with a certain mutation.</h3>")
#endif

		new_character.temporary_attack_alert(1200) //Messages admins if this new character attacks someone within 2 minutes of signing up. Might help detect grief, who knows?
		new_character.temporary_suicide_alert(1500) //Messages admins if this new character commits suicide within 2 1/2 minutes. probably a bit much but whatever
		return new_character

	Move()
		return 1 // do not return 0 in here for the love of god, let me tell you the tale of why:
		// the default mob/Login (which got called before we actually set our loc onto the start screen), will attempt to put the mob at (1, 1, 1) if the loc is null
		// however, the documentation actually says "near" (1, 1, 1), and will count Move returning 0 as that it cannot be placed there
		// by "near" it means anywhere on the goddamn map where Move will return 1, this meant that anyone logging in would cause the server to
		// grind itself to a slow death in a caciphony of endless Move calls

	proc/makebad(var/mob/living/carbon/human/traitormob, type)
		if (!traitormob || !ismob(traitormob) || !traitormob.mind)
			return

		var/datum/mind/traitor = traitormob.mind
		ticker.mode.traitors += traitor

		var/objective_set_path = null
		switch (type)

			if ("traitor")
				traitor.special_role = "traitor"
			#ifdef RP_MODE
				objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
			#else
				objective_set_path = pick(typesof(/datum/objective_set/traitor))
			#endif

			if ("changeling")
				traitor.special_role = "changeling"
				objective_set_path = /datum/objective_set/changeling
				traitormob.make_changeling()

			if ("vampire")
				traitor.special_role = "vampire"
				objective_set_path = /datum/objective_set/vampire
				traitormob.make_vampire()

			if ("wrestler")
				traitor.special_role = "wrestler"
				objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
				traitormob.make_wrestler(1)

			if ("grinch")
				traitor.special_role = "grinch"
				objective_set_path = /datum/objective_set/grinch
				traitormob.make_grinch()

			if ("hunter")
				traitor.special_role = "hunter"
				objective_set_path = /datum/objective_set/hunter
				traitormob.make_hunter()

			if ("werewolf")
				traitor.special_role = "werewolf"
				objective_set_path = /datum/objective_set/werewolf
				traitormob.make_werewolf()

			if ("wraith")
				traitor.special_role = "wraith"
				traitormob.make_wraith()
				generate_wraith_objectives(traitor)

			else // Fallback if role is unrecognized.
				traitor.special_role = "traitor"
			#ifdef RP_MODE
				objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
			#else
				objective_set_path = pick(typesof(/datum/objective_set/traitor))
			#endif

		if (!isnull(objective_set_path))
			if (ispath(objective_set_path, /datum/objective_set))
				new objective_set_path(traitor)
			else if (ispath(objective_set_path, /datum/objective))
				ticker.mode.bestow_objective(traitor, objective_set_path)

		var/obj_count = 1
		for(var/datum/objective/objective in traitor.objectives)
			#ifdef CREW_OBJECTIVES
			if (istype(objective, /datum/objective/crew) || istype(objective, /datum/objective/miscreant)) continue
			#endif
			boutput(traitor.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++

	proc/close_spawn_windows()
		if(client)
			src.Browse(null, "window=latechoices") //closes late choices window
			src.Browse(null, "window=playersetup") //closes the player setup window
			winshow(src, "joinmenu", 0)
			winshow(src, "playerprefs", 0)

	verb/declare_ready_use_token()
		set hidden = 1
		set name = ".ready_antag"

		if(!(!ticker || current_state <= GAME_STATE_PREGAME))
			src.show_text("Round has already started. You can't redeem tokens now. (You have [src.client.antag_tokens].)", "red")
		else if(src.client.antag_tokens > 0)
			if(master_mode in list("secret","traitor","nuclear","blob","wizard","changeling","mixed","mixed_rp","vampire"))
				src.client.using_antag_token = 1
			src.show_text("Token redeemed, if mode supports redemption your new total will be [src.client.antag_tokens - 1].", "red")
		else
			src.show_text("You don't even have any tokens. How did you get here?", "red")

		src.declare_ready()

	verb/declare_ready()
		set hidden = 1
		set name = ".ready"

		if (ticker)
			if (ticker.mode)
				if (istype(ticker.mode, /datum/game_mode/construction))
					var/datum/game_mode/construction/C = ticker.mode
					if (C.in_setup)
						boutput(usr, "<span class='alert'>The round is currently being set up. Please wait.</span>")
						return

		if(!ticker || current_state <= GAME_STATE_PREGAME)
			if(!ready)
				ready = 1
				if (usr.client) winset(src, "joinmenu.button_charsetup", "is-disabled=true")
				if (usr.client) winset(src, "joinmenu.button_ready", "is-disabled=true;is-visible=false")
				if (usr.client) winset(src, "joinmenu.button_cancel", "is-disabled=false;is-visible=true")
				if (usr.client) winset(src, "joinmenu.button_ready_antag", "is-disabled=true")
				usr.Browse(null, "window=mob_occupation")

				bank_menu = new
				bank_menu.Subscribe( usr.client )
				src.client.loadResources()
		else
			LateChoices()

	verb/cancel_ready()
		set hidden = 1
		set name = ".cancel_ready"

		if (ticker)
			if (ticker.mode)
				if (istype(ticker.mode, /datum/game_mode/construction))
					var/datum/game_mode/construction/C = ticker.mode
					if (C.in_setup)
						boutput(usr, "<span class='alert'>You are already spawning, and cannot unready. Please wait until setup finishes.</span>")
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

		if(alert(src,"Are you sure you wish to observe? You will not be able to play this round!","Player Setup","Yes","No") == "Yes")
			if(!src.client) return
			var/mob/dead/observer/observer = new()
			if (src.client && src.client.using_antag_token) //ZeWaka: Fix for null.using_antag_token
				src.client.using_antag_token = 0
				src.show_text("Token refunded, your new total is [src.client.antag_tokens].", "red")
			src.spawning = 1

			close_spawn_windows()
			boutput(src, "<span class='notice'>Now teleporting.</span>")
			var/ASLoc = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
			if (ASLoc)
				observer.set_loc(ASLoc)
			observer.apply_looks_of(client)

			observer.observe_round = 1
			if(client.preferences && client.preferences.be_random_name) //Wire: fix for Cannot read null.be_random_name (preferences &&)
				client.preferences.randomize_name()
			observer.name = client.preferences.real_name

			if(!src.mind) src.mind = new(src)

			//src.mind.dnr=1
			src.mind.joined_observer=1
			src.mind.transfer_to(observer)
			observer.real_name = observer.name
			if(observer && observer.client)
				observer.client.loadResources()

			qdel(src)

	say(message)
		if(dd_hasprefix(message, "*"))
			return
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
