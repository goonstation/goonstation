
/client/proc/cmd_admin_playeropt(mob/M as mob in world)
	set name = "Player Options"
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 1
	if (src.holder)
		src.holder.playeropt(M)
	return

/datum/admins/proc/playeropt_link(mob/M, action)
	return "?src=\ref[src];action=[action];targetckey=[M.ckey];targetmob=\ref[M];origin=adminplayeropts"

/datum/admins/proc/playeropt(mob/M)
	if (!ismob(M))
		alert("Mob not found - can't auto-refresh the panel. (May have been banned / deleted)")
		return

	if (istype(M, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = M
		if (AI.deployed_to_eyecam)
			M = AI.eyecam

	var/mentor = M.client?.player?.mentor
	var/hos = (M.ckey in NT)
	var/is_admin = M.client?.holder && ! M.client.player_mode

	// The topBar style here is so that it can continue to happily chill at the top of even chui windows
	var/header_thing_chui_toggle = (usr.client && !usr.client.use_chui) ? "<style type='text/css'>#topBar { top: 0; left: 0; right: 0; background-color: white; } </style>" : "<style type='text/css'>#topBar { top: 46px; left: 4px; right: 10px; background: inherit; }</style>"

	var/key_string = "no ckey"
	var/html_key_string = "<i>no ckey</i>"
	if (M.key)
		key_string = M.key
		html_key_string = key_string
	else if(M.last_ckey)
		if (find_player(M.last_ckey)?.client)
			key_string = "last: [M.last_ckey] / in other mob"
			html_key_string = "last: [M.last_ckey] <i>/ in <a href='?src=\ref[src];action=refreshoptions;targetckey=[M.last_ckey];'>other mob</a></i>"
		else
			key_string = "last: [M.last_ckey] / offline"
			html_key_string = "last: [M.last_ckey] <i>/ offline</i>"

	var/list/dat = list()
	dat += {"
	[header_thing_chui_toggle]
	<title>[M.name] ([key_string]) Options</title>
	<style>
		a {
			text-decoration: none;
		}
		.optionGroup {
			margin-bottom: 8px;
			padding: 1px;
			border: 1px solid black;
		}
		.optionGroup h2 {
			display: block;
			background: black;
			color: white;
			padding: 0.1em 0.5em;
			margin: 0;
			font-size: 100%;
		}

		.optionGroup > div {
			padding: 0.25em;
		}
		.optionGroup .l {
			width: 120px;
			float: left;
			clear: both;
			font-weight: bold;
		}
		.optionGroup .r {
			width: auto;
			overflow: auto;
		}

		.antag {
			color: #f55;
		}

		.pseudo {
			color: #b57edc;
		}

		.mentor {
			color: #a24cff;
		}

		.hos {
			color: #2237AD;
		}

		.admin {
			color: #BE6E53;
		}

		#topBar {
			position: fixed;
			padding: 0.2em 0.5em;
			border-bottom: 1px solid black;
		}

		#topOpts {
			float: right;
		}

		#mobInfo {
			margin-top: 2em;
			margin-bottom: 0.25em;
		}
	</style>
	"}

	var/antagonist_roles
	var/number_of_antagonist_roles = ""

	if (M.mind)
		var/number_of_antagonists =  0
		for (var/datum/antagonist/antagonist_role as anything in M.mind.antagonists)
			var/display_name = "<span class='antag'>[capitalize(antagonist_role.display_name)]</span>"
			if (antagonist_role.vr)
				display_name += " <span class='pseudo'>(VR)</span>"
			else if (antagonist_role.pseudo)
				display_name += " <span class='pseudo'>(pseudo)</span>"
			else
				number_of_antagonists++

			antagonist_roles += "<a href='?src=\ref[src];target=\ref[antagonist_role];action=viewvars'>[display_name]</a> &mdash; <a href='?src=\ref[src];action=remove_antagonist;targetmob=\ref[M];target_antagonist=\ref[antagonist_role]'>Remove</a><br>"

		if (isnull(antagonist_roles))
			antagonist_roles += "No antagonist roles present."
		else
			antagonist_roles += "<a href='?src=\ref[src];targetmob=\ref[M];action=wipe_antagonists'>Remove All Antagonist Roles</a>"

		if (number_of_antagonists)
			if (number_of_antagonists == 1)
				var/datum/antagonist/antagonist_role = M.mind.antagonists[1]
				number_of_antagonist_roles = " <b><span class='antag'>Antagonist: [capitalize(antagonist_role.display_name)]</span></b>"
			else
				number_of_antagonist_roles = " <b><span class='antag'>[number_of_antagonists] antagonist role\s present.</span></b>"

	//General info
	//  Logs link:
	//  <a href='?src=\ref[src];action=view_logs;type=all_logs_string;presearch=[M.key];origin=adminplayeropts'>LOGS</a>
	dat += {"
<div id="topBar">
	<div id="topOpts">
		[M.key ? "<a href='?src=\ref[src];action=notes;targetckey=[M.ckey];targetmob=\ref[M];origin=adminplayeropts'>Notes</a> &bull; <a href='[playeropt_link(M, "show_player_stats")]'>Stats</a> &bull;" : ""]
		<a href='?src=\ref[src];action=view_logs;type=all_logs_string;presearch=[M.key ? M.key : M.name];origin=adminplayeropts'>Logs</a> &bull;
		<a href='?src=\ref[src];action=refreshoptions;targetckey=[M.ckey];targetmob=\ref[M];'>&#8635;</a>
	</div>
	<b>[M.name]</b> (<tt>[html_key_string]</tt>)[mentor ? " <b class='mentor'>(Mentor)</b>" : ""][hos ? " <b class='hos'>(HoS)</b>" : ""][is_admin ? " <b class='admin'>(Admin)</b>" : ""]
</div>

<div id="mobInfo">
	Mob: <b>[M.name]</b> [M.mind && M.mind.assigned_role ? "{[M.mind.assigned_role]}": ""] (<tt>[html_key_string]</tt>)
	[M.client ? "" : "<em>(no client)</em>"]
	[M.ai ? "<a href='?src=\ref[src];target=\ref[M.ai];action=viewvars'>([M.ai.enabled ? "active" : "inactive"] AI)</a>" : ""]
	[isdead(M) ? "<span class='antag'>(dead)</span>" : ""]
	<div style="font-family: Monospace; font-size: 0.7em; float: right;">ping [M.client?.chatOutput?.last_ping || "N/A "]ms</div>
	<br>Mob Type: <b>[M.type]</b>[number_of_antagonist_roles]
</div>
	"}

	if (M.client)
		dat += {"
			<div class='optionGroup' style='border-color: #f77;'>
				<h2 style="background-color: #f44;">Administration</h2>
				<div>
					<div class='l'>Message</div>
					<div class='r'>
						<a href='?action=priv_msg&target=[M.ckey]'>PM</a> &bull;
						<a href='[playeropt_link(M, "subtlemsg")]'>Subtle PM</a> &bull;
						<a href='[playeropt_link(M, "plainmsg")]'>Plain Message</a> &bull;
						<a href='[playeropt_link(M, "adminalert")]'>Alert</a> &bull;
						<a href='[playeropt_link(M, "showrules;type=normal")]'>Show Rules</a> &bull;
						<a href='[playeropt_link(M, "showrules;type=rp")]'>Show RP Rules</a>
					</div>
				</div>
			</div>
		"}
	if (!istype(M, /mob/new_player))
		//Wire: Hey I wonder if I can put a short syntax condition with a multi-line text result inside a multi-line text string
		//Turns out yes but good lord does it break dream maker syntax highlighting
		//dat += {"[M.client ? " | " : ""][ishuman(M) ? {"<br>Reagents:

		dat += {"
			<div class='optionGroup' style='border-color: #88d;'>
				<h2 style='background-color: #88d;'>Common</h2>
				<div>
				[!isobserver(M) ? {"
					<div class='l'>Health</div>
					<div class='r'>
						<a href='[playeropt_link(M, "checkhealth")]'>Check</a> &bull;
						<a href='[playeropt_link(M, "revive")]'>Heal</a> &bull;
						[(isdead(M) || M.max_health == 0) ? "Dead" : "[round(100 * M.health / M.max_health)]%"] &bull;
						<a href='[playeropt_link(M, "max_health")]'>Max Health</a>: [M.max_health] &bull;
						<a href='[playeropt_link(M, "kill")]'>Kill</a>
					</div>
					"} : ""]
					<div class='l'>Reagents<a href='?src=\ref[src];action=secretsfun;type=reagent_help'>*</a></div>
					<div class='r'>
						<a href='[playeropt_link(M, "checkreagent")]'>Check</a> &bull;
						<a href='[playeropt_link(M, "addreagent")]'>Add</a> &bull;
						<a href='[playeropt_link(M, "removereagent")]'>Remove</a>
					</div>
					<div class='l'>Bioeffects<a href='?src=\ref[src];action=secretsfun;type=bioeffect_help'>*</a></div>
					<div class='r'>
						<a href='[playeropt_link(M, "managebioeffect")]'>Manage</a> &bull;
						<a href='[playeropt_link(M, "addbioeffect")]'>Add</a> &bull;
						<a href='[playeropt_link(M, "removebioeffect")]'>Remove</a>
					</div>
					<div class='l'>Abilities</div>
					<div class='r'>
						<a href='[playeropt_link(M, "manageabils")]'>Manage</a> &bull;
						<a href='[playeropt_link(M, "addabil")]'>Add</a> &bull;
						<a href='[playeropt_link(M, "removeabil")]'>Remove</a> &bull;
						<a href='[playeropt_link(M, "abilholder")]'>New Holder</a>
				 	</div>
					<div class='l'>Traits<a href='?src=\ref[src];action=secretsfun;type=traitlist_help'>*</a></div>
					<div class='r'>
						<a href='[playeropt_link(M, "managetraits")]'>Manage</a> &bull;
						<a href='[playeropt_link(M, "addtrait")]'>Add</a> &bull;
						<a href='[playeropt_link(M, "removetrait")]'>Remove</a>
				 	</div>
					<div class='l'>Objectives</div>
					<div class='r'>
						<a href='[playeropt_link(M, "manageobjectives")]'>Manage</a> &bull;
						<a href='[playeropt_link(M, "addobjective")]'>Add</a>
				 	</div>
					<div class='l'>StatusEffects<a href='?src=\ref[src];action=secretsfun;type=statuseffect_help'>*</a></div>
					<div class='r'>
						<a href='[playeropt_link(M, "setstatuseffect")]'>Set</a> &bull;
						<a href='[playeropt_link(M, "modifystatuseffect")]'>Modify</a>
				 	</div>
					<div class='l'>Contents</div>
					<div class='r'>
				 		<a href='[playeropt_link(M, "checkcontents")]'>Check</a> &bull;
				 		<a href='[playeropt_link(M, "dropcontents")]'>Drop</a>
					</div>
					<div class='l'>Gib</div>
					<div class='r'>
						<a href='[playeropt_link(M, "gib")]'>Normal</a> &bull;
						<a href='[playeropt_link(M, "implodegib")]'>Implode</a> &bull;
						<a href='[playeropt_link(M, "buttgib")]'>Buttgib</a> &bull;
						<a href='[playeropt_link(M, "partygib")]'>Party</a> &bull;
						<a href='[playeropt_link(M, "firegib")]'>Fire</a> &bull;
						<a href='[playeropt_link(M, "elecgib")]'>Elec</a> &bull;
						<a href='[playeropt_link(M, "icegib")]'>Ice</a> &bull;
						<a href='[playeropt_link(M, "goldgib")]'>Gold</a> &bull;
						<a href='[playeropt_link(M, "smite")]'>Smite</a>
						<br>
						<a href='[playeropt_link(M, "owlgib")]'>Owl</a> &bull;
						<a href='[playeropt_link(M, "sharkgib")]'>Shark</a> &bull;
						<a href='[playeropt_link(M, "spidergib")]'>Spider</a> &bull;
						<a href='[playeropt_link(M, "cluwnegib")]'>Cluwne</a> &bull;
						<a href='[playeropt_link(M, "tysongib")]'>Tyson</a> &bull;
						<a href='[playeropt_link(M, "flockgib")]'>Flock</a> &bull;
						<a href='[playeropt_link(M, "damn")]'>(Un)Damn</a> &bull;
						<a href='[playeropt_link(M, "rapture")]'>Rapture</a> &bull;
						<a href='[playeropt_link(M, "anvilgib")]'>Anvil</a>
					</div>
					<div class='l'>Misc</div>
					<div class='r'>
						<a href='[playeropt_link(M, "forcespeech")]'>Force Say</a> &bull;
						<a href='[playeropt_link(M, "halt")]'>Halt!</a> &bull;
						<a href='[playeropt_link(M, "animate")]'>Animate</a>
					</div>
				</div>
			</div>
				"}

	//Movement based options
	if(!istype(M, /mob/new_player))
		var/turf/T = get_turf(M)
		var/turf/A = get_area(T)
		var/atom/Q = M.loc

		dat += {"
			<div class='optionGroup' style='border-color: #77DD77;'>
				<h2 style='background-color:#77DD77'>Movement</h2>
				<div>
					<div class='l'>
						Common
					</div>
					<div class='r'>
						<a href='[playeropt_link(M, "jumpto")]'>Jump to</A> &bull;
						<a href='[playeropt_link(M, "observe")]'>Observe</A> &bull;
						<a href='[playeropt_link(M, "getmob")]'>Get</a> &bull;
						<a href='[playeropt_link(M, "sendmob")]'>Send to...</a> &bull;
						<a href='[playeropt_link(M, "viewport")]'>Viewport</a>
						<br>Currently in [A]
			"}
		if (T) //runtime fix for mobs in null space
			dat += "<br>&nbsp;&nbsp;[T.x], [T.y], [T.z][(Q && Q != T) ? ", inside \the [Q]" : ""]"
		else
			dat += "Null Space"
		dat += {"
					</div>
					<div class='l'>
						Prison
					</div>
					<div class='r'>
						<a href='[playeropt_link(M, "prison")]'>Prison</a> &bull;
						<a href='[playeropt_link(M, "shamecube")]'>Shamecube</a> &bull;
						Thunderdome <a href='[playeropt_link(M, "tdome;type=1")]'>One</a>/<a href='[playeropt_link(M, "tdome;type=2")]'>Two</a>
					</div>
				</div>
			</div>
			"}

	//Admin control options
	if (M.client || M.ckey)
		dat += {"
			<div class='optionGroup' style='border-color: #FF6961;'>
				<h2 style='background-color: #FF6961;'>Control</h2>
				<div>
				"}
		if (M.client)
			dat += {"
					<div class='l'>Client</div>
					<div class='r'>
						<a href='[playeropt_link(M, "prom_demot")]'>Rank</a> &bull;
						<a href='[playeropt_link(M, "toggle_dj")]'>Toggle DJ</a> &bull;
						[M.client.ismuted() ? "<a href='[playeropt_link(M, "mute")]'>Unmute</a>" : {"
						Mute <a href='[playeropt_link(M, "mute")]'>Perm</a>/<a href='[playeropt_link(M, "tempmute")]'>Temp</a>
						"}] &bull;
						[M.has_medal("Unlike the director, I went to college") ? {"
								<a href='[playeropt_link(M, "revokeclown")]'>Revoke Clown College Diploma	</a>
							"} : {"
								<a href='[playeropt_link(M, "grantclown")]'>Grant Clown College Diploma</a>
						"}]
					</div>

				"}
		if (M.ckey)
			dat += {"
					<div class='l'>
						Key
					</div>
					<div class='r'>
						<a href='[playeropt_link(M, "boot")]'>Kick</a> &bull;
						<a href='[playeropt_link(M, "addban")]'>Ban</a> &bull;
						<a href='[playeropt_link(M, "sharkban")]'>Ban w/shark</a> &bull;
						<a href='[playeropt_link(M, "jobbanpanel")]'>Job Bans</a> &bull;
						<a href='[playeropt_link(M, "banooc")]'>OOC [oocban_isbanned(M) ? "Unban" : "Ban"]</a> &bull;
						<a href='[playeropt_link(M, "viewcompids")]'>CompIDs</a> &bull;
						<a href='[playeropt_link(M, "centcombans")]'>CentCom</a>
					</div>
					<div class='l'>
						Persistent
					</div>
					<div class='r'>
						<a href='[playeropt_link(M, "giveantagtoken")]'>Antag Tokens</a> &bull;
						<a href='[playeropt_link(M, "setspacebux")]'>Spacebux</a> &bull;
						<a href='[playeropt_link(M, "chatbans")]'>Chat Bans</a> &bull;
						<a href='[playeropt_link(M, "flavortext")]'>Flavor text</a>
					</div>
				"}

		dat += "</div></div>"

	if(!istype(M, /mob/new_player))
		if (M.mind)
			dat += {"
				<div class='optionGroup' style='border-color: #B57EDC;'>
					<h2 style='background-color: #B57EDC;'>Antagonist Options</h2>
					<div>
						[jobban_isbanned(M, "Syndicate") ? "<div class='antag'>⚠ This player is antag banned ⚠</div>" : ""]
						<div class='l'>Options</div>
						<div class='r'>
							<a href='?src=\ref[src];targetmob=\ref[M];action=add_antagonist'>Add Antagonist Role</a> &bull;
							<a href='?src=\ref[src];targetmob=\ref[M];action=add_subordinate_antagonist'>Add Subordinate Antagonist Role</a><br>
						</div>

						<div class='l'>Antag Roles</div>
						<div class='r'>
							[antagonist_roles]
						</div>
					</div>
				</div>
				"}

		dat += {"
			<div class='optionGroup' style='border-color: #779ECB;'>
				<h2 style='background-color: #779ECB;'>Transformation</h2>
				<div>
					<div class='l'>
						Transform Into
					</div>
					<div class='r'>
				[ishuman(M) ? {"
						<a href='[playeropt_link(M, "makecritter")]'>Critter</a> &bull;
						<a href='[playeropt_link(M, "makecube")]'>Meatcube</a> &bull;
						<!-- <a href='[playeropt_link(M, "transform")]'>Transform</a> &bull; -->
						<a href='[playeropt_link(M, "clownify")]'>Cluwne</a> &bull;
						<a href='[playeropt_link(M, "makeai")]'>AI</a> &bull;
						<a href='[playeropt_link(M, "makecyborg")]'>Cyborg</a> &bull;
						<a href='[playeropt_link(M, "makeghostdrone")]'>Ghostdrone</a>
						<br>
						<a href='[playeropt_link(M, "polymorph")]'>Edit Appearance</a> &bull;
						<a href='[playeropt_link(M, "modifylimbs")]'>Modify Limbs/Organs</a> &bull;
						<a href='[playeropt_link(M, "respawntarget")]'>Respawn</a> &bull;
						<a href='[playeropt_link(M, "respawnas")]'>Respawn As</a>
						<br>
						<a href='[playeropt_link(M, "changeoutfit")]'>Change Outfit</a>
				"} : {"
						Only human mobs can be transformed.
						<br><a href='[playeropt_link(M, "humanize")]'>Humanize</a> &bull;
						<a href='[playeropt_link(M, "makecritter")]'>Make Critter</a> &bull;
						<a href='[playeropt_link(M, "respawntarget")]'>Respawn</a> &bull;
						<a href='[playeropt_link(M, "respawnas")]'>Respawn As</a>
				"}]
					</div>
				</div>
			</div>
					"}

		//if (!isobserver(M)) //moved from SG level stuff
		//	dat += " | <a href='?src=\ref[src];action=polymorph;targetckey=[M.ckey];targetmob=\ref[M];origin=adminplayeropts'>Polymorph</a>"
		//dat += "</div>"

	//Coder options
	if( src.level >= LEVEL_PA )
		dat += {"
			<div class='optionGroup' style='border-color: #FFB347;'>
				<h2 style='background-color: #FFB347;'>High Level Problems</h2>
				<div>
					<div class='l'>Administrator</div>
					<div class='r'>
						<a href='[playeropt_link(M, "possessmob")]'>[M == usr ? "Release" : "Possess"] mob</a> &bull;
						<a href='[playeropt_link(M, "viewvars")]'>Edit Variables</a> &bull;
						<a href='[playeropt_link(M, "modcolor")]'>Modify Icon</a>
					</div>
					"}
		if (src.level >= LEVEL_CODER)
			dat += {"
					<div class='l'>Coder</div>
					<div class='r'>
						<a href='[playeropt_link(M, "viewsave")]'>View Save Data</a>
						[M.client ? {" &bull;
							[M.has_medal("Contributor") ? {"
								<a href='[playeropt_link(M, "revokecontributor")]'>Revoke Contributor Medal</a>
							"} : {"
								<a href='[playeropt_link(M, "grantcontributor")]'>Grant Contributor Medal</a>
							"}]
						"} : ""]
					</div>
				"}
		dat += {"
				</div>
			</div>
			"}
	var/windowHeight = 450
	if (src.level >= LEVEL_CODER)
		windowHeight = 754	//weird number, but for chui screen, it removes the scrolling.
	else if (src.level >= LEVEL_ADMIN)
		windowHeight = 550
#ifdef SECRETS_ENABLED
	dat += restricted_playeroptions(M)
	windowHeight += 45
#endif
	usr.Browse(dat.Join(), "window=adminplayeropts[M.ckey];size=600x[windowHeight]")
