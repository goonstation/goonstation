
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

	// The topBar style here is so that it can continue to happily chill at the top of even chui windows
	var/header_thing_chui_toggle = (usr.client && !usr.client.use_chui) ? "<style type='text/css'>#topBar { top: 0; left: 0; right: 0; background-color: white; } </style>" : "<style type='text/css'>#topBar { top: 46px; left: 4px; right: 10px; background: inherit; }</style>"

	var/list/dat = list()
	dat += {"
	[header_thing_chui_toggle]
	<title>[M.name] ([M.key ? M.key : "NO CKEY"]) Options</title>
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

	//Antag roles (yes i said antag jeez shut up about it already)
	var/antag
	if (M.mind)
		var/antag_len = length(M.mind.antagonists)
		if (antag_len)
			antag = "<b>[antag_len] antagonist role\s present.</b><br>"
			for (var/datum/antagonist/this_antag as anything in M.mind.antagonists)
				antag += "<span class='antag'>[this_antag.display_name]</span> &mdash; <a href='?src=\ref[src];action=remove_antagonist;targetmob=\ref[M];target_antagonist=\ref[this_antag]'>Remove</a><br>"
			antag += "<a href='?src=\ref[src];targetmob=\ref[M];action=add_antagonist'>Add Antagonist Role</a><br>"
			antag += "<a href='?src=\ref[src];targetmob=\ref[M];action=wipe_antagonists'>Remove All Antagonist Roles</a>"
		else if (M.mind.special_role != null)
			antag = {"
			<a href='[playeropt_link(M, "traitor")]' class='antag'>[M.mind.special_role]</a> &mdash;
			<a href='[playeropt_link(M, "remove_traitor")]' class='antag'>Remove</a>
			"}
		else if (!isobserver(M))
			antag = {"<a href='[playeropt_link(M, "traitor")]'>Make Antagonist</a> &bull;
					<a href='?src=\ref[src];targetmob=\ref[M];action=add_antagonist'>Add Antagonist Role</a>"}
		else
			antag = "Observer"

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
	<b>[M.name]</b> (<tt>[M.key ? M.key : "<em>no key</em>"]</tt>)
</div>

<div id="mobInfo">
	Mob: <b>[M.name]</b> [M.mind && M.mind.assigned_role ? "{[M.mind.assigned_role]}": ""] (<tt>[M.key ? M.key : "<em>no key</em>"]</tt>)
	[M.client ? "" : "<em>(no client)</em>"]
	[isdead(M) ? "<span class='antag'>(dead)</span>" : ""]
	<div style="font-family: Monospace; font-size: 0.7em; float: right;">ping [M.client?.chatOutput?.last_ping || "N/A "]ms</div>
	<br>Mob Type: <b>[M.type]</b> ([antag])
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
						<a href='[playeropt_link(M, "showrules")]'>Show Rules</a>
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
						[(M.stat == 2 || M.max_health == 0) ? "Dead" : "[round(100 * M.health / M.max_health)]%"] &bull;
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
						<a href='[playeropt_link(M, "goldgib")]'>Gold</a>
						<br>
						<a href='[playeropt_link(M, "owlgib")]'>Owl</a> &bull;
						<a href='[playeropt_link(M, "sharkgib")]'>Shark</a> &bull;
						<a href='[playeropt_link(M, "spidergib")]'>Spider</a> &bull;
						<a href='[playeropt_link(M, "cluwnegib")]'>Cluwne</a> &bull;
						<a href='[playeropt_link(M, "tysongib")]'>Tyson</a> &bull;
						<a href='[playeropt_link(M, "flockgib")]'>Flock</a> &bull;
						<a href='[playeropt_link(M, "damn")]'>(Un)Damn</a>
					</div>
					<div class='l'>Misc</div>
					<div class='r'>
						<a href='[playeropt_link(M, "forcespeech")]'>Force Say</a>
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
						<a href='[playeropt_link(M, "sendmob")]'>Send to...</a>
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
						<a href='[playeropt_link(M, "viewcompids")]'>CompIDs</a>
					</div>
					<div class='l'>
						Persistent
					</div>
					<div class='r'>
						<a href='[playeropt_link(M, "giveantagtoken")]'>Antag Tokens</a> &bull;
						<a href='[playeropt_link(M, "setspacebux")]'>Spacebux</a> &bull;
						<a href='[playeropt_link(M, "viewantaghistory")]'>Antag History</a> &bull;
						<a href='[playeropt_link(M, "chatbans")]'>Chat Bans</a>
					</div>
				"}

		dat += "</div></div>"

	//Very special roles
	if(!istype(M, /mob/new_player))
		dat += {"
			<div class='optionGroup' style='border-color: #B57EDC;'>
				<h2 style='background-color: #B57EDC;'>Antagonist Options</h2>
				<div>
					<div class='l'>Antag Status</div>
					<div class='r'>
						[antag]
					</div>
					<div class='l'>Make Into</div>
					<div class='r'>
						[iswraith(M) ? "<em>Is Wraith</em>" : "<a href='[playeropt_link(M, "makewraith")]'>Wraith</a>"] &bull;
						[isblob(M) ? "<em>Is Blob</em>" : "<a href='[playeropt_link(M, "makeblob")]'>Blob</a>"] &bull;
						[istype(M, /mob/living/carbon/human/machoman) ? "<em>Is Macho Man</em>" : "<a href='[playeropt_link(M, "makemacho")]'>Macho Man</a>"] &bull;
						[isflockmob(M) ? "<em>Is Flock</em>" : "<a href='[playeropt_link(M, "makeflock")]'>Flock</a>"] &bull;
						[isfloorgoblin(M) ? "<em>Is Floor Goblin</em>" : "<a href='[playeropt_link(M, "makefloorgoblin")]'>Floor Goblin</a>"] &bull;
						[istype(M, /mob/living/carbon/human/slasher) ? "<em>Is Slasher</em>" : "<a href='[playeropt_link(M, "makeslasher")]'>Slasher</a>"]
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
						<a href='[playeropt_link(M, "clownify")]'>Cluwne</a>
						<br>
						<a href='[playeropt_link(M, "makeai")]'>AI</a> &bull;
						<a href='[playeropt_link(M, "makecyborg")]'>Cyborg</a> &bull;
						<a href='[playeropt_link(M, "makeghostdrone")]'>Ghostdrone</a>
						<br>
						<a href='[playeropt_link(M, "polymorph")]'>Edit Appearance</a> &bull;
						<a href='[playeropt_link(M, "modifylimbs")]'>Modify Limbs/Organs</a> &bull;
						<a href='[playeropt_link(M, "respawntarget")]'>Respawn</a> &bull;
						<a href='[playeropt_link(M, "respawnas")]'>Respawn As</a>
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
