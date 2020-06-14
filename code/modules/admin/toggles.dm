#define NOT_IF_TOGGLES_ARE_OFF if (!toggles_enabled) { alert("Toggling toggles has been disabled."); return; }


//List of verbs cluttering the popup menus
//ADD YOUR SHIT HERE IF YOU MAKE A NEW VERB THAT GOES ON RIGHT-CLICK OR YOU ARE LITERALLY HITLER (Aka marquesas jr)
//fixed that for you -marq
var/list/popup_verbs_to_toggle = list(\
/client/proc/sendmobs,
/client/proc/sendhmobs,
/client/proc/Jump,\
)

/client/proc/toggle_popup_verbs()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Popup Verbs"
	set desc = "Toggle verbs that appear on right-click"
	admin_only

	var/list/final_verblist

	//The main bunch
	for(var/I = 1,  I <= admin_verbs.len && I <= rank_to_level(src.holder.rank)+2, I++)
		final_verblist += popup_verbs_to_toggle & admin_verbs[I] //So you only toggle verbs at your level

	//The special A+ observer verbs
	if(rank_to_level(src.holder.rank) >= LEVEL_IA)
		final_verblist |= special_admin_observing_verbs
		//And the special PA+ observer verbs why do we even use this? It's dumb imo
		if(rank_to_level(src.holder.rank) >= LEVEL_PA)
			final_verblist |= special_pa_observing_verbs

	if(final_verblist.len)
		if(!src.holder.popuptoggle)
			for(var/V in final_verblist)
				src.verbs -= V
		else
			for(var/V in final_verblist)
				src.verbs += V
		src.holder.popuptoggle = !src.holder.popuptoggle

		boutput(usr, "<span class='notice'>Toggled popup verbs [src.holder.popuptoggle?"off":"on"]!</span>")

	return

// if it's in Toggles (Server) it should be in here, ya dig?
var/list/server_toggles_tab_verbs = list(\
/client/proc/toggle_attack_messages,\
/client/proc/toggle_toggles,\
/client/proc/toggle_jobban_announcements,\
/client/proc/toggle_banlogin_announcements,\
/client/proc/toggle_literal_disarm,\
/datum/admins/proc/toggleooc,\
/datum/admins/proc/togglelooc,\
/datum/admins/proc/toggleoocdead,\
/datum/admins/proc/toggletraitorscaling,\
/datum/admins/proc/pcap,\
/datum/admins/proc/toggleenter,\
/datum/admins/proc/toggleAI,\
/datum/admins/proc/toggle_soundpref_override,\
/datum/admins/proc/toggle_respawns,\
/datum/admins/proc/adsound,\
/datum/admins/proc/adspawn,\
/datum/admins/proc/adrev,\
/datum/admins/proc/toggledeadchat,\
/datum/admins/proc/togglefarting,\
/datum/admins/proc/toggle_blood_system,\
/datum/admins/proc/toggle_bone_system,\
/datum/admins/proc/togglesuicide,\
/datum/admins/proc/togglethetoggles,\
/datum/admins/proc/toggleautoending,\
/datum/admins/proc/toggleaprilfools,\
/datum/admins/proc/togglespeechpopups,\
/datum/admins/proc/togglemonkeyspeakhuman,\
/datum/admins/proc/togglelatetraitors,\
/datum/admins/proc/togglesoundwaiting,\
/datum/admins/proc/adjump,\
/datum/admins/proc/togglesimsmode,\
/datum/admins/proc/toggle_pull_slowing,\
/client/proc/admin_toggle_nightmode,\
/client/proc/toggle_camera_network_reciprocity,\
)

/client/proc/toggle_server_toggles_tab()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Server Toggles Tab"
	set desc = "Toggle all the crap in the Toggles (Server) tab so it should go away/show up.  in thoery."
	admin_only

	var/list/final_verblist

	//The main bunch
	for (var/I = 1,  I <= admin_verbs.len && I <= rank_to_level(src.holder.rank)+2, I++)
		final_verblist += server_toggles_tab_verbs & admin_verbs[I] //So you only toggle verbs at your level

	//The special A+ observer verbs
	if (rank_to_level(src.holder.rank) >= LEVEL_IA)
		final_verblist |= special_admin_observing_verbs
		//And the special PA+ observer verbs why do we even use this? It's dumb imo
		if (rank_to_level(src.holder.rank) >= LEVEL_PA)
			final_verblist |= special_pa_observing_verbs

	if (final_verblist.len)
		if (!src.holder.servertoggles_toggle)
			for (var/V in final_verblist)
				src.verbs -= V
		else
			for (var/V in final_verblist)
				src.verbs += V
		src.holder.servertoggles_toggle = !src.holder.servertoggles_toggle

		boutput(usr, "<span class='notice'>Toggled Server Toggle tab [src.holder.servertoggles_toggle?"off":"on"]!</span>")

	return

/client/proc/toggle_extra_verbs()//Going to put some things in here that we dont need to see every single second when trying to play though atm only the add_r is in it
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Extra Verbs"
	admin_only
	if (!src.holder.extratoggle)
		src.verbs -= /client/proc/addreagents

		//src.verbs -= /proc/possess
		src.verbs -= /client/proc/addreagents
		src.verbs -= /client/proc/cmd_admin_rejuvenate

		src.verbs -= /client/proc/main_loop_context
		src.verbs -= /client/proc/main_loop_tick_detail
		src.verbs -= /client/proc/ticklag

		src.holder.extratoggle = 1
		boutput(src, "Extra Toggled Off")
	else
		src.verbs += /client/proc/addreagents
		src.holder.extratoggle = 0
		boutput(src, "Extra Toggled On")
		src.verbs += /client/proc/addreagents


		//src.verbs += /proc/possess
		src.verbs += /client/proc/addreagents
		src.verbs += /client/proc/cmd_admin_rejuvenate

		src.verbs += /client/proc/main_loop_context
		src.verbs += /client/proc/main_loop_tick_detail
		src.verbs += /client/proc/ticklag

var/global/IP_alerts = 1

/client/proc/toggle_ip_alerts()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle IP Alerts"
	set desc = "Toggles the same-IP alerts"
	admin_only

	IP_alerts = !IP_alerts
	logTheThing("admin", usr, null, "has toggled same-IP alerts [(IP_alerts ? "On" : "Off")]")
	logTheThing("diary", usr, null, "has toggled same-IP alerts [(IP_alerts ? "On" : "Off")]", "admin")
	message_admins("[key_name(usr)] has toggled same-IP alerts [(IP_alerts ? "On" : "Off")]")

/client/proc/toggle_hearing_all_looc()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Hearing All LOOC"
	set desc = "Toggles the ability to hear all LOOC messages regardless of where you are"
	admin_only

	src.only_local_looc = !src.only_local_looc
	boutput(usr, "<span class='notice'>Toggled seeing all LOOC messages [src.only_local_looc ?"off":"on"]!</span>")

/client/proc/toggle_attack_messages()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Attack Alerts"
	set desc = "Toggles the after-join attack messages"
	admin_only

	src.holder.attacktoggle = !src.holder.attacktoggle
	boutput(usr, "<span class='notice'>Toggled attack log messages [src.holder.attacktoggle ?"on":"off"]!</span>")

/client/proc/toggle_hear_prayers()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Hearing Prayers"
	set desc = "Toggles if you can hear prayers or not"
	admin_only

	src.holder.hear_prayers = !src.holder.hear_prayers
	boutput(usr, "<span class='notice'>Toggled prayers [src.holder.hear_prayers ?"on":"off"]!</span>")

/client/proc/toggle_buildmode_view()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Buildmode View"
	set desc = "Toggles if buildmode changes your view"
	admin_only

	src.holder.buildmode_view = !src.holder.buildmode_view
	boutput(usr, "<span class='notice'>Toggled buildmode changing view [src.holder.buildmode_view ?"off":"on"]!</span>")

/client/proc/toggle_spawn_in_loc()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Spawn in Loc"
	set desc = "Toggles if buildmode changes your view"
	admin_only

	src.holder.spawn_in_loc = !src.holder.spawn_in_loc
	boutput(usr, "<span class='notice'>Toggled spawn verb spawning in your loc [src.holder.spawn_in_loc ?"off":"on"]!</span>")

/client/proc/cmd_admin_playermode()
	set name = "Toggle Player mode"
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set desc = "Disables most admin messages."

	admin_only

	if (player_mode)
		player_mode = 0
		player_mode_asay = 0
		player_mode_ahelp = 0
		player_mode_mhelp = 0
		if (src.holder.popuptoggle)
			src.toggle_popup_verbs()
		boutput(usr, "<span class='notice'>Player mode now OFF.</span>")
	else
		var/choice = input(src, "ASAY = adminsay, AHELP = adminhelp, MHELP = mentorhelp", "Choose which messages to recieve") as null|anything in list("NONE (Remove admin menus)","NONE (Keep admin menus)", "ASAY, AHELP & MHELP", "ASAY & AHELP", "ASAY & MHELP", "AHELP & MHELP", "ASAY ONLY", "AHELP ONLY", "MHELP ONLY")
		switch (choice)
			if ("ASAY, AHELP & MHELP")
				player_mode = 1
				player_mode_asay = 1
				player_mode_ahelp = 1
				player_mode_mhelp = 1
			if ("ASAY & AHELP")
				player_mode = 1
				player_mode_asay = 1
				player_mode_ahelp = 1
				player_mode_mhelp = 0
			if ("ASAY & MHELP")
				player_mode = 1
				player_mode_asay = 1
				player_mode_ahelp = 0
				player_mode_mhelp = 1
			if ("AHELP & MHELP")
				player_mode = 1
				player_mode_asay = 0
				player_mode_ahelp = 1
				player_mode_mhelp = 1
			if ("ASAY ONLY")
				player_mode = 1
				player_mode_asay = 1
				player_mode_ahelp = 0
				player_mode_mhelp = 0
			if ("AHELP ONLY")
				player_mode = 1
				player_mode_asay = 0
				player_mode_ahelp = 1
				player_mode_mhelp = 0
			if ("MHELP ONLY")
				player_mode = 1
				player_mode_asay = 0
				player_mode_ahelp = 0
				player_mode_mhelp = 1
			if ("NONE (Keep admin menus)")
				player_mode = 1
				player_mode_asay = 0
				player_mode_ahelp = 0
				player_mode_mhelp = 0
			if ("NONE (Remove admin menus)")
				player_mode = 1
				player_mode_asay = 0
				player_mode_ahelp = 0
				player_mode_mhelp = 0
				cmd_admin_disable()
			else
				// Cancel = don't turn on player mode
				return

		boutput(usr, "<span class='notice'>Player mode now on. [player_mode_asay ? "&mdash; ASAY ON" : ""] [player_mode_ahelp ? "&mdash; AHELPs ON" : ""] [player_mode_mhelp ? "&mdash; MHELPs ON" : ""]</span>")

		// turn of popup verbs too
		if (src.holder && !src.holder.popuptoggle)
			src.toggle_popup_verbs()

	logTheThing("admin", usr, null, "has set player mode to [(player_mode ? "On" : "Off")]")
	logTheThing("diary", usr, null, "has set player mode to [(player_mode ? "On" : "Off")]", "admin")
	message_admins("[key_name(usr)] has set player mode to [(player_mode ? "On" : "Off")]")

/client/proc/cmd_admin_godmode(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Toggle Mob Godmode"
	set popup_menu = 0
	admin_only

	if (!isliving(M))
		return
	M.nodamage = !(M.nodamage)
	boutput(usr, "<span class='notice'><b>[M]'s godmode is now [usr.nodamage ? "ON" : "OFF"]</b></span>")

	logTheThing("admin", usr, M, "has toggled %target%'s nodamage to [(M.nodamage ? "On" : "Off")]")
	logTheThing("diary", usr, M, "has toggled %target%'s nodamage to [(M.nodamage ? "On" : "Off")]", "admin")
	message_admins("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.nodamage ? "On" : "Off")]")

/client/proc/cmd_admin_godmode_self()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Your Godmode"
	set popup_menu = 0
	admin_only

	if (!isliving(usr))
		return
	usr.nodamage = !(usr.nodamage)
	boutput(usr, "<span class='notice'><b>Your godmode is now [usr.nodamage ? "ON" : "OFF"]</b></span>")

	logTheThing("admin", usr, null, "has toggled their nodamage to [(usr.nodamage ? "On" : "Off")]")
	logTheThing("diary", usr, null, "has toggled their nodamage to [(usr.nodamage ? "On" : "Off")]", "admin")
	message_admins("[key_name(usr)] has toggled their nodamage to [(usr.nodamage ? "On" : "Off")]")

/client/var/flying = 0
/client/proc/noclip()
	set name = "Toggle Your Noclip"
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set desc = "Fly through walls"

	usr.client.flying = !usr.client.flying
	boutput(usr, "Noclip mode [usr.client.flying ? "ON" : "OFF"].")

/client/proc/toggle_atom_verbs() // I hate calling them "atom verbs" but wtf else should they be called, fuck
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Atom Verbs"
	admin_only
	if(!src.holder.animtoggle)
		src.holder.animtoggle = 1
		boutput(src, "Atom Verbs Toggled Off but not really, use Change Admin Preferences instead")
	else
		src.holder.animtoggle = 0
		boutput(src, "Atom Verbs Toggled On but not really, use Change Admin Preferences instead")

/client/proc/toggle_view_range()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle View Range"
	set desc = "switches between 1x and custom views"

	if(src.view == world.view)
		var/x = input("Enter view width in tiles: (1 - 59, default 15 (normal) / 21 (widescreen))", "Width", 21)
		var/y = input("Enter view height in tiles: (1 - 30, default 15)", "Height", 15)

		src.set_view_size(x,y)
	else
		// Reset view - takes into account widescreen
		src.reset_view()
		//src.view = world.view

/client/proc/toggle_toggles()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Toggles"
	set desc = "Toggles toggles ON/OFF"
	if(!(src.holder.rank in list("Host", "Coder")))
		NOT_IF_TOGGLES_ARE_OFF

	toggles_enabled = !toggles_enabled
	logTheThing("admin", usr, null, "toggled Toggles to [toggles_enabled].")
	logTheThing("diary", usr, null, "toggled Toggles to [toggles_enabled].", "admin")
	message_admins("[key_name(usr)] toggled Toggles [toggles_enabled ? "on" : "off"].")

/client/proc/toggle_force_mixed_wraith()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Toggle Force Wraith"
	set desc = "If turned on, a wraith will always appear in mixed or traitor, regardless of player count or probabilities."
	debug_mixed_forced_wraith = !debug_mixed_forced_wraith
	logTheThing("admin", usr, null, "toggled force mixed wraith [debug_mixed_forced_wraith ? "on" : "off"]")
	logTheThing("diary", usr, null, "toggled force mixed wraith [debug_mixed_forced_wraith ? "on" : "off"]")
	message_admins("[key_name(usr)] toggled force mixed wraith [debug_mixed_forced_wraith ? "on" : "off"]")

/client/proc/toggle_force_mixed_blob()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Toggle Force Blob"
	set desc = "If turned on, a blob will always appear in mixed, regardless of player count or probabilities."
	debug_mixed_forced_blob = !debug_mixed_forced_blob
	logTheThing("admin", usr, null, "toggled force mixed blob [debug_mixed_forced_blob ? "on" : "off"]")
	logTheThing("diary", usr, null, "toggled force mixed blob [debug_mixed_forced_blob ? "on" : "off"]")
	message_admins("[key_name(usr)] toggled force mixed blob [debug_mixed_forced_blob ? "on" : "off"]")

/client/proc/toggle_jobban_announcements()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Jobban Alerts"
	set desc = "Toggles the announcement of job bans ON/OFF"
	if (!(src.holder.rank in list("Host", "Coder", "Administrator")))
		NOT_IF_TOGGLES_ARE_OFF

	if (announce_jobbans == 1) announce_jobbans = 0
	else announce_jobbans = 1
	logTheThing("admin", usr, null, "toggled Jobban Alerts to [announce_jobbans].")
	logTheThing("diary", usr, null, "toggled Jobban Alerts to [announce_jobbans].", "admin")
	message_admins("[key_name(usr)] toggled Jobban Alerts [announce_jobbans ? "on" : "off"].")

/client/proc/toggle_banlogin_announcements()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Banlog Alerts"
	set desc = "Toggles the announcement of failed logins ON/OFF"
	admin_only
	if (announce_banlogin == 1) announce_banlogin = 0
	else announce_banlogin = 1
	logTheThing("admin", usr, null, "toggled Banned User Alerts to [announce_banlogin].")
	logTheThing("diary", usr, null, "toggled Banned User Alerts to [announce_banlogin].", "admin")
	message_admins("[key_name(usr)] toggled Banned User Alerts to [announce_banlogin ? "on" : "off"].")

/client/proc/toggle_literal_disarm()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Literal Disarm"
	set desc = "Toggles literal disarm intent ON/OFF"
	if(!(src.holder.rank in list("Host", "Coder")))
		NOT_IF_TOGGLES_ARE_OFF
	literal_disarm = !literal_disarm
	logTheThing("admin", usr, null, "toggled literal disarming to [literal_disarm].")
	logTheThing("diary", usr, null, "toggled literal disarming to [literal_disarm].", "admin")
	message_admins("[key_name(usr)] toggled literal disarming [literal_disarm ? "on" : "off"].")

/datum/admins/proc/toggleooc()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle dis bitch"
	set name="Toggle OOC"
	NOT_IF_TOGGLES_ARE_OFF
	ooc_allowed = !( ooc_allowed )
	boutput(world, "<B>The OOC channel has been globally [ooc_allowed ? "en" : "dis"]abled!</B>")
	logTheThing("admin", usr, null, "toggled OOC.")
	logTheThing("diary", usr, null, "toggled OOC.", "admin")
	message_admins("[key_name(usr)] toggled OOC.")

/datum/admins/proc/togglelooc()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle dis bitch"
	set name="Toggle LOOC"
	NOT_IF_TOGGLES_ARE_OFF
	looc_allowed = !( looc_allowed )
	boutput(world, "<B>The LOOC channel has been globally [looc_allowed ? "en" : "dis"]abled!</B>")
	logTheThing("admin", usr, null, "toggled LOOC.")
	logTheThing("diary", usr, null, "toggled LOOC.", "admin")
	message_admins("[key_name(usr)] toggled LOOC.")

/datum/admins/proc/toggleoocdead()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle dis bitch"
	set name="Toggle Dead OOC"
	NOT_IF_TOGGLES_ARE_OFF
	dooc_allowed = !( dooc_allowed )
	logTheThing("admin", usr, null, "toggled OOC.")
	logTheThing("diary", usr, null, "toggled OOC.", "admin")
	message_admins("[key_name(usr)] toggled Dead OOC.")

/datum/admins/proc/toggletraitorscaling()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle traitor scaling"
	set name="Toggle Traitor Scaling"
	NOT_IF_TOGGLES_ARE_OFF
	traitor_scaling = !traitor_scaling
	logTheThing("admin", usr, null, "toggled Traitor Scaling to [traitor_scaling].")
	logTheThing("diary", usr, null, "toggled Traitor Scaling to [traitor_scaling].", "admin")
	message_admins("[key_name(usr)] toggled Traitor Scaling [traitor_scaling ? "on" : "off"].")

/datum/admins/proc/pcap()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle player cap"
	set name = "Toggle Player Cap"
	player_capa = !( player_capa )
	if (player_capa)
		boutput(world, "<B>The global player cap has been enabled at [player_cap] players.</B>")
	else
		boutput(world, "<B>The global player cap has been disabled.</B>")
	logTheThing("admin", usr, null, "toggled player cap to [player_cap].")
	logTheThing("diary", usr, null, "toggled player cap to [player_cap].", "admin")
	message_admins("[key_name(usr)] toggled the global player cap [player_cap ? "on" : "off"]")

/datum/admins/proc/toggleenter()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="People can't enter"
	set name="Toggle Entering"
	NOT_IF_TOGGLES_ARE_OFF
	enter_allowed = !( enter_allowed )
	if (!( enter_allowed ))
		boutput(world, "<B>You may no longer enter the game.</B>")
	else
		boutput(world, "<B>You may now enter the game.</B>")
	logTheThing("admin", usr, null, "toggled new player game entering.")
	logTheThing("diary", usr, null, "toggled new player game entering.", "admin")
	message_admins("<span class='notice'>[key_name(usr)] toggled new player game entering.</span>")
	world.update_status()

/datum/admins/proc/toggleAI()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="People can't be AI"
	set name="Toggle AI"
	NOT_IF_TOGGLES_ARE_OFF
	config.allow_ai = !( config.allow_ai )
	if (!( config.allow_ai ))
		boutput(world, "<B>The AI job is no longer chooseable.</B>")
	else
		boutput(world, "<B>The AI job is chooseable now.</B>")
	logTheThing("admin", usr, null, "toggled AI allowed.")
	logTheThing("diary", usr, null, "toggled AI allowed.", "admin")
	world.update_status()

/datum/admins/proc/toggle_soundpref_override()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Force people to hear admin-played sounds even if they have them disabled."
	set name = "Toggle SoundPref Override"
	NOT_IF_TOGGLES_ARE_OFF
	soundpref_override = !( soundpref_override )
	logTheThing("admin", usr, null, "toggled Sound Preference Override [soundpref_override ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled Sound Preference Override [soundpref_override ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled Sound Preference Override [soundpref_override ? "on" : "off"]")

/datum/admins/proc/toggle_respawns()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Enable or disable the ability for all players to respawn"
	set name="Toggle Respawn"
	NOT_IF_TOGGLES_ARE_OFF
	abandon_allowed = !( abandon_allowed )
	if (abandon_allowed)
		boutput(world, "<B>You may now respawn.</B>")
	else
		boutput(world, "<B>You may no longer respawn :(</B>")
	message_admins("<span class='notice'>[key_name(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].</span>")
	logTheThing("admin", usr, null, "toggled respawn to [abandon_allowed ? "On" : "Off"].")
	logTheThing("diary", usr, null, "toggled respawn to [abandon_allowed ? "On" : "Off"].", "admin")
	world.update_status()

/client/proc/toggle_pray()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set desc="Toggle Your Pray"
	set name="Toggle Local Pray"
	NOT_IF_TOGGLES_ARE_OFF
	if(pray_l == 0)
		pray_l = 1
		boutput(usr, "Pray turned on")
	else
		pray_l = 0
		boutput(usr, "Pray turned off")
	message_admins("[key_name(usr)] toggled its Pray to [pray_l].")

/client/proc/toggle_flourish()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set desc="Toggles Your Flourish Mode"
	set name="Toggle Flourish Mode"
	NOT_IF_TOGGLES_ARE_OFF
	if(flourish)
		flourish = 0
	else
		flourish = 1
	message_admins("[key_name(usr)] toggled its Flourish Mode to [flourish].")

/datum/admins/proc/adsound()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle admin sound playing"
	set name="Toggle Sound Playing"
	NOT_IF_TOGGLES_ARE_OFF
	config.allow_admin_sounds = !(config.allow_admin_sounds)
	message_admins("<span class='notice'>Toggled admin sound playing to [config.allow_admin_sounds].</span>")

/datum/admins/proc/adspawn()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle admin spawning"
	set name="Toggle Spawn"
	NOT_IF_TOGGLES_ARE_OFF
	config.allow_admin_spawning = !(config.allow_admin_spawning)
	message_admins("<span class='notice'>Toggled admin item spawning to [config.allow_admin_spawning].</span>")

/datum/admins/proc/adrev()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle admin revives"
	set name="Toggle Revive"
	NOT_IF_TOGGLES_ARE_OFF
	config.allow_admin_rev = !(config.allow_admin_rev)
	message_admins("<span class='notice'>Toggled reviving to [config.allow_admin_rev].</span>")

/datum/admins/proc/toggledeadchat()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle Deadchat on or off."
	set name = "Toggle Deadchat"
	NOT_IF_TOGGLES_ARE_OFF
	deadchat_allowed = !( deadchat_allowed )
	if (deadchat_allowed)
		boutput(world, "<B>The Deadsay channel has been enabled.</B>")
	else
		boutput(world, "<B>The Deadsay channel has been disabled.</B>")
	logTheThing("admin", usr, null, "toggled Deadchat [deadchat_allowed ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled Deadchat [deadchat_allowed ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled Deadchat [deadchat_allowed ? "on" : "off"]")

/datum/admins/proc/togglefarting()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle Farting on or off."
	set name = "Toggle Farting"
	NOT_IF_TOGGLES_ARE_OFF
	farting_allowed = !( farting_allowed )
	if (farting_allowed)
		boutput(world, "<B>Farting has been enabled.</B>")
	else
		boutput(world, "<B>Farting has been disabled.</B>")
	logTheThing("admin", usr, null, "toggled Farting [farting_allowed ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled Farting [farting_allowed ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled Farting [farting_allowed ? "on" : "off"]")

/datum/admins/proc/toggle_blood_system()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle the blood system on or off."
	set name = "Toggle Blood System"
	NOT_IF_TOGGLES_ARE_OFF
	blood_system = !(blood_system)
	boutput(world, "<B>Blood system has been [blood_system ? "enabled" : "disabled"].</B>")
	logTheThing("admin", usr, null, "toggled the blood system [blood_system ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled the blood system [blood_system ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled the blood system [blood_system ? "on" : "off"]")

/datum/admins/proc/toggle_bone_system()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle the bone system on or off."
	set name = "Toggle Bone System"
	NOT_IF_TOGGLES_ARE_OFF
	bone_system = !(bone_system)
	boutput(world, "<B>Bone system has been [bone_system ? "enabled" : "disabled"].</B>")
	logTheThing("admin", usr, null, "toggled the bone system [bone_system ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled the bone system [bone_system ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled the bone system [bone_system ? "on" : "off"]")

/datum/admins/proc/togglesuicide()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Allow/Disallow people to commit suicide."
	set name = "Toggle Suicide"
	NOT_IF_TOGGLES_ARE_OFF
	suicide_allowed = !( suicide_allowed )
	logTheThing("admin", usr, null, "toggled Suicides [suicide_allowed ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled Suicides [suicide_allowed ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled Suicides [suicide_allowed ? "on" : "off"]")

/datum/admins/proc/togglethetoggles()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle All Toggles"
	set name = "Toggle All Toggles"
	NOT_IF_TOGGLES_ARE_OFF
	ooc_allowed = !( ooc_allowed )
	dooc_allowed = !( dooc_allowed )
	player_capa = !( player_capa )
	enter_allowed = !( enter_allowed )
	config.allow_ai = !( config.allow_ai )
	soundpref_override = !( soundpref_override )
	abandon_allowed = !( abandon_allowed )
	config.allow_admin_jump = !(config.allow_admin_jump)
	config.allow_admin_sounds = !(config.allow_admin_sounds)
	config.allow_admin_spawning = !(config.allow_admin_spawning)
	config.allow_admin_rev = !(config.allow_admin_rev)
	deadchat_allowed = !( deadchat_allowed )
	farting_allowed = !( farting_allowed )
	suicide_allowed = !( suicide_allowed )
	monkeysspeakhuman = !( monkeysspeakhuman )
	no_automatic_ending = !( no_automatic_ending )
	late_traitors = !( late_traitors )
	sound_waiting = !( sound_waiting )
	message_admins("[key_name(usr)] toggled OOC [ooc_allowed ? "on" : "off"], Dead OOC  [dooc_allowed ? "on" : "off"], Global Player Cap  [player_capa ? "on" : "off"], Entering [enter_allowed ? "on" : "off"],Playing as the AI [config.allow_ai ? "on" : "off"], Sound Preference override [soundpref_override ? "on" : "off"], Abandoning [abandon_allowed ? "on" : "off"], Admin Jumping [config.allow_admin_jump ? "on" : "off"], Admin sound playing [config.allow_admin_sounds ? "on" : "off"], Admin Spawning [config.allow_admin_spawning ? "on" : "off"], Admin Reviving [config.allow_admin_rev ? "on" : "off"], Deadchat [deadchat_allowed ? "on" : "off"], Farting [farting_allowed ? "on" : "off"], Blood system [blood_system ? "on" : "off"], Suicide [suicide_allowed ? "on" : "off"], Monkey/Human communication [monkeysspeakhuman ? "on" : "off"], Late Traitors [late_traitors ? "on" : "off"], and Sound Queuing [sound_waiting ? "on" : "off"]   ")

/client/proc/togglepersonaldeadchat()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set desc = "Toggle whether you can see deadchat or not"
	set name = "Toggle Your Deadchat"
	NOT_IF_TOGGLES_ARE_OFF
	if(deadchatoff == 0)
		deadchatoff = 1
		boutput(usr, "<span class='notice'>No longer viewing deadchat.</span>")
	else
		deadchatoff = 0
		boutput(usr, "<span class='notice'>Now viewing deadchat.</span>")

/datum/admins/proc/toggleaprilfools()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle manual breathing and/or blinking."
	set name = "Toggle Manual Breathing/Blinking"
	NOT_IF_TOGGLES_ARE_OFF

	var/priorbreathing = manualbreathing
	var/breathing = alert("Manual breathing mode?","Toggle","On","Off")
	if(breathing == "On")
		manualbreathing = 1
		if(priorbreathing != manualbreathing) boutput(world, "<B>You must now breathe manually using the *inhale and *exhale emotes!</B>")
	else
		manualbreathing = 0
		if(priorbreathing != manualbreathing) boutput(world, "<B>You no longer need to breathe manually!</B>")

	var/priorblinking = manualblinking
	var/blinking = alert("Manual blinking mode?","Toggle","On","Off")
	if(blinking == "On")
		manualblinking = 1
		if(priorblinking != manualblinking) boutput(world, "<B>You must now blink manually using the *closeeyes and *openeyes emotes!</B>")
	else
		manualblinking = 0
		if(priorblinking != manualblinking) boutput(world, "<B>You no longer need to blink manually!</B>")

	logTheThing("admin", usr, null, "turned manual breathing [manualbreathing ? "on" : "off"] and manual blinking [manualblinking ? "on" : "off"].")
	logTheThing("diary", usr, null, "turned manual breathing [manualbreathing ? "on" : "off"] and manual blinking [manualblinking ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] turned manual breathing [manualbreathing ? "on" : "off"] and manual blinking [manualblinking ? "on" : "off"].")

/datum/admins/proc/togglespeechpopups()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Makes mob chat show up in-game as floating text."
	set name = "Toggle Global Flying Chat"
	NOT_IF_TOGGLES_ARE_OFF
	speechpopups = !( speechpopups )
	logTheThing("admin", usr, null, "toggled speech popups [speechpopups ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled speech popups [speechpopups ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled speech popups [speechpopups ? "on" : "off"]")

/datum/admins/proc/togglemonkeyspeakhuman()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle monkeys being able to speak human."
	set name = "Toggle Monkeys Speaking Human"
	NOT_IF_TOGGLES_ARE_OFF
	monkeysspeakhuman = !( monkeysspeakhuman )
	if (monkeysspeakhuman)
		boutput(world, "<B>Monkeys can now speak to humans.</B>")
	else
		boutput(world, "<B>Monkeys can no longer speak to humans.</B>")
	logTheThing("admin", usr, null, "toggled Monkey/Human communication [monkeysspeakhuman ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled Monkey/Human communication [monkeysspeakhuman ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled Monkey/Human communication [monkeysspeakhuman ? "on" : "off"]")

/datum/admins/proc/toggleautoending()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle the round automatically ending in invasive round types."
	set name = "Toggle Automatic Round End"
	NOT_IF_TOGGLES_ARE_OFF
	no_automatic_ending = !( no_automatic_ending )
	logTheThing("admin", usr, null, "toggled Automatic Round End [no_automatic_ending ? "off" : "on"].")
	logTheThing("diary", usr, null, "toggled Automatic Round End [no_automatic_ending ? "off" : "on"].", "admin")
	message_admins("[key_name(usr)] toggled Automatic Round End [no_automatic_ending ? "off" : "on"]")

/datum/admins/proc/togglelatetraitors()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle late joiners spawning as antagonists if all starting antagonists are dead."
	set name = "Toggle Late Antagonists"
	NOT_IF_TOGGLES_ARE_OFF
	late_traitors = !( late_traitors )
	logTheThing("admin", usr, null, "toggled late antagonists [late_traitors ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled late antagonists [late_traitors ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled late antagonists [late_traitors ? "on" : "off"]")

/datum/admins/proc/togglesoundwaiting()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle admin-played sounds waiting for previous sounds to finish before playing."
	set name = "Toggle Admin Sound Queue"
	NOT_IF_TOGGLES_ARE_OFF
	sound_waiting = !( sound_waiting )
	logTheThing("admin", usr, null, "toggled admin sound queue [sound_waiting ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled admin sound queue [sound_waiting ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled admin sound queue [sound_waiting ? "on" : "off"]")

/datum/admins/proc/adjump()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle admin jumping"
	set name="Toggle Jump"
	NOT_IF_TOGGLES_ARE_OFF
	config.allow_admin_jump = !(config.allow_admin_jump)
	message_admins("<span class='notice'>Toggled admin jumping to [config.allow_admin_jump].</span>")

/datum/admins/proc/togglesimsmode()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Enable sims mode for this round."
	set name = "Toggle Sims Mode"
	NOT_IF_TOGGLES_ARE_OFF
	global_sims_mode = !global_sims_mode
	message_admins("<span class='notice'>[key_name(usr)] toggled sims mode. [global_sims_mode ? "Oh, the humanity!" : "Phew, it's over."]</span>")
	for (var/mob/M in mobs)
		LAGCHECK(LAG_LOW)
		boutput(M, "<b>Motives have been globally [global_sims_mode ? "enabled" : "disabled"].</b>")
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (global_sims_mode && !H.sims)
#ifdef RP_MODE
				H.sims = new /datum/simsHolder/rp(H)
#else
				H.sims = new /datum/simsHolder/human(H)
#endif
			else if (!global_sims_mode && H.sims)
				qdel(H.sims)
				H.sims = null

/datum/admins/proc/toggle_pull_slowing()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle whether pulling items should slow people down or not."
	set name = "Toggle Pull Slowing"
	NOT_IF_TOGGLES_ARE_OFF
	pull_slowing = !( pull_slowing )
	logTheThing("admin", usr, null, "toggled pull slowing [pull_slowing ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled pull slowing [pull_slowing ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled pull slowing [pull_slowing ? "on" : "off"]")


//Dont need this any more? Player controlled now
/*
/client/proc/togglewidescreen()
	set name = "Toggle Widescreen Station"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "SS13, future edition. Toggle widescreen for all clients."
	admin_only
	NOT_IF_TOGGLES_ARE_OFF

	if( view == "21x15" )
		for(var/client/C)
			C.set_widescreen(0)
		message_admins( "[key_name(src)] toggled widescreen off." )
	else
		for(var/client/C)
			C.set_widescreen(1)
		message_admins( "[key_name(src)] toggled widescreen on." )
*/

/client/proc/toggle_next_click()
	set name = "Toggle next_click"
	set desc = "Removes most click delay. Don't know what this is? Probably shouldn't touch it."
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	admin_only

	disable_next_click = !(disable_next_click)
	logTheThing("admin", usr, null, "toggled next_click [disable_next_click ? "off" : "on"].")
	logTheThing("diary", usr, null, "toggled next_click [disable_next_click ? "off" : "on"].", "admin")
	message_admins("[key_name(usr)] toggled next_click [disable_next_click ? "off" : "on"]")

/client/proc/narrator_mode()
	set name = "Toggle Narrator Mode"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle narrator mode on or off."
	admin_only

	narrator_mode = !(narrator_mode)

	logTheThing("admin", usr, null, "toggled narrator mode [narrator_mode ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled narrator mode [narrator_mode ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled narrator mode [narrator_mode ? "on" : "off"]")

/client/proc/toggle_station_name_changing()
	set name = "Toggle Station Name Changing"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle station name changing on or off."
	admin_only

	station_name_changing = !(station_name_changing)

	logTheThing("admin", usr, null, "toggled station name changing [station_name_changing ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled station name changing [station_name_changing ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled station name changing [station_name_changing ? "on" : "off"]")

/client/proc/toggle_map_voting()
	set name = "Toggle Map Voting"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle whether map votes are allowed"
	set popup_menu = 0

	admin_only

	var/bustedMapSwitcher = isMapSwitcherBusted()
	if (bustedMapSwitcher)
		return alert(bustedMapSwitcher)

	mapSwitcher.votingAllowed = !mapSwitcher.votingAllowed

	logTheThing("admin", usr, null, "toggled map voting [mapSwitcher.votingAllowed ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled map voting [mapSwitcher.votingAllowed ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled map voting [mapSwitcher.votingAllowed ? "on" : "off"]")

/client/proc/waddle_walking()
	set name = "Toggle Waddle Walking"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle waddle walking on or off."
	admin_only

	waddle_walking = !(waddle_walking)

	logTheThing("admin", usr, null, "toggled waddle walking [waddle_walking ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled waddle walking [waddle_walking ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled waddle walking [waddle_walking ? "on" : "off"]")

/client/proc/toggle_respawn_arena()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Respawn Arena"
	set desc = "Lets ghosts go to the respawn arena to compete for a new life"

	admin_only
	respawn_arena_enabled = 1 - respawn_arena_enabled
	logTheThing("admin", usr, null, "toggled the respawn arena [respawn_arena_enabled ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled the respawn arena [respawn_arena_enabled ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled the respawn arena [respawn_arena_enabled ? "on" : "off"]")
	if(respawn_arena_enabled)
		boutput(world, "<B>The Respawn Arena has been enabled! Use the go_to_respawn_arena verb as a ghost to compete for a new life!</B>")
	else
		boutput(world, "<B>The Respawn Arena has been disabled.</B>")
