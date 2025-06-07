/* Hello these are the new logs wow gosh look at this isn't it exciting
Some procs  exist for replacement within text:
	[constructTarget(target,type)]

Example in-game log call:
		logTheThing(LOG_ADMIN, src, "shot that nerd [constructTarget(src,"diary")] at [log_loc(usr)]")
Example out of game log call:
		logTheThing(LOG_DIARY, src, "gibbed everyone ever", "admin")
*/

//We save this as html because the non-diary logging currently has html tags in place


#define WRITE_LOG(log, text) rustg_log_write(log, text, "true")
#define WRITE_LOG_NO_FORMAT(log, text) rustg_log_write(log, text, "false")

var/global/roundLog_date = time2text(world.realtime, "YYYY-MM-DD-hh-mm")
var/global/roundLog_name = "data/logs/full/[roundLog_date].html"
var/global/roundLog = file(roundLog_name)
var/global/disable_log_lists = 0
var/global/first_adminhelp_happened = 0
var/global/logLength = 0

/proc/logTheThing(type, source, text, diaryType)
	var/diaryLogging
	var/forceNonDiaryLoggingToo = FALSE
	var/area/A

	if(istype(source, /mob/living/carbon/human/preview) && type == LOG_COMBAT)
		return //we don't give a flying fuck about the preview mobs maving mutations - but maybe we care about debug etc.?

	if (source)
		A = get_area(source)
		source = constructName(source, type)
	else
		if (type != LOG_DIARY) source = "<span class='blank'>(blank)</span>"


	if (disable_log_lists) // lag reduction hack - ONLY print logs to the web versions
		if (type == LOG_DIARY)
			diaryLogging = should_diary_log(diaryType)

		if (diaryLogging)
			WRITE_LOG(diary_name, "[diaryType]: [source ? "[source] ": ""][text]")

		//A little trial run of full logs saved to disk. They are cleared by the server every so often (cronjob) (HEH NOT ANYMORE)
		if (!diaryLogging && config.allowRotatingFullLogs)
			WRITE_LOG(roundLog_name, "\[[type]] [source && source != "<span class='blank'>(blank)</span>" ? "[source]: ": ""][text]<br>")
			logLength++

	else
		var/ingameLog = "<td class='duration'>\[[round(world.time/600)]:[(world.time%600)/10]\]</td><td class='source'>[source]</td><td class='text'>[text]</td>"

		switch(type)
			//These are things we log in-game (accessible via the Secrets menu)
			if (LOG_AUDIT)
				logs[LOG_AUDIT] += ingameLog
				diaryLogging = 1
				diaryType = LOG_AUDIT
				forceNonDiaryLoggingToo = TRUE
			if (LOG_ADMIN) logs[LOG_ADMIN] += ingameLog
			if (LOG_AHELP) logs[LOG_AHELP] += ingameLog
			if (LOG_MHELP) logs[LOG_MHELP] += ingameLog
			if (LOG_SAY) logs[LOG_SPEECH] += ingameLog
			if (LOG_OOC) logs[LOG_OOC] += ingameLog
			if (LOG_WHISPER) logs[LOG_SPEECH] += ingameLog
			if (LOG_STATION) logs[LOG_STATION] += ingameLog
			if (LOG_COMBAT)
				if (A?.dont_log_combat)
					return
				logs[LOG_COMBAT] += ingameLog
			if (LOG_TELEPATHY) logs[LOG_TELEPATHY] += ingameLog
			if (LOG_DEBUG) logs[LOG_DEBUG] += ingameLog
			if (LOG_PDAMSG) logs[LOG_PDAMSG] += ingameLog
			if (LOG_SIGNALERS) logs[LOG_SIGNALERS] += ingameLog
			if (LOG_BOMBING) logs[LOG_BOMBING] += ingameLog
			if (LOG_VEHICLE) logs[LOG_VEHICLE] += ingameLog
			if (LOG_GAMEMODE) logs[LOG_GAMEMODE] += ingameLog
			if (LOG_TOPIC) logs[LOG_TOPIC] += ingameLog
			if (LOG_CHEMISTRY) logs[LOG_CHEMISTRY] += ingameLog
			if (LOG_DIARY)
				diaryLogging = should_diary_log(diaryType)

		if (diaryLogging)
			WRITE_LOG(diary_name, "[diaryType]: [source ? "[source] ": ""][text]")

		//A little trial run of full logs saved to disk. They are cleared by the server every so often (cronjob) (HEH NOT ANYMORE)
		if ((!diaryLogging || forceNonDiaryLoggingToo) && config.allowRotatingFullLogs)
			WRITE_LOG(roundLog_name, "\[[type]] [source && source != "<span class='blank'>(blank)</span>" ? "[source]: ": ""][text]<br>")
			logLength++

		if (!diaryLogging)
			var/datum/eventRecord/Log/logEvent = new()
			logEvent.send(type, source && source != "<span class='blank'>(blank)</span>" ? source : null, text)
	return

///Check config for whether a message should be logged to the diary
/proc/should_diary_log(diaryType)
	switch (diaryType)
		//These are things we log in the out of game logs (the diary)
		if (LOG_ADMIN) if (config.log_admin) return TRUE
		if (LOG_AHELP) if (config.log_say) return TRUE
		if (LOG_MHELP) if (config.log_say) return TRUE
		if (LOG_GAME) if (config.log_game) return TRUE
		if (LOG_ACCESS) if (config.log_access) return TRUE

		if (LOG_SAY) if (config.log_say) return TRUE
		if (LOG_OOC) if (config.log_ooc) return TRUE
		if (LOG_WHISPER) if (config.log_whisper) return TRUE
		if (LOG_STATION) if (config.log_station) return TRUE
		if (LOG_COMBAT) if (config.log_combat) return TRUE
		if (LOG_TELEPATHY) if (config.log_telepathy) return TRUE
		if (LOG_DEBUG) if (config.log_debug) return TRUE
		if (LOG_VEHICLE) if (config.log_vehicles) return TRUE
		if (LOG_GAMEMODE) if (config.log_gamemode) return TRUE
	return FALSE

/proc/logDiary(text)
	WRITE_LOG(diary_name, "[text]")

/**
 * Appends a tgui-related log entry. All arguments are optional.
 */
/proc/log_tgui(user, message, context,
		datum/tgui_window/window,
		datum/src_object)
	var/entry = "" // |GOONSTATION-CHANGE| (tgui:->)
	// Insert user info
	var/source = null // |GOONSTATION-CHANGE| -> split source out of entry to send to logTheThing
	if(!user)
		source = "(nobody)" // |GOONSTATION-CHANGE| (entry +->source ) (<nobody>->(nobody))
	else if(istype(user, /mob))
		var/mob/mob = user
		source = "[mob.ckey] (as [mob] at [mob.x],[mob.y],[mob.z])" // |GOONSTATION-CHANGE| (entry +->source )
	else if(istype(user, /client))
		var/client/client = user
		source = "[client.ckey]" // |GOONSTATION-CHANGE| (entry +->source )
	// Insert context
	if(context)
		entry += " in [context]"
	else if(window)
		entry += " in [window.id]"
	// Resolve src_object
	if(!src_object && window?.locked_by)
		src_object = window.locked_by.src_object
	// Insert src_object info
	if(src_object)
		entry += "<br>Using: [src_object.type] \ref[src_object]" // |GOONSTATION-CHANGE| (\n->br, REF->\ref)
	// Insert message
	if(message)
		entry += "<br>[message]" // |GOONSTATION-CHANGE| (\n->br)
	entry += "<br>" // |GOONSTATION-CHANGE| (br)
	logTheThing(LOG_TGUI, source, entry) // |GOONSTATION-CHANGE| (WRITE_LOG(roundLog_name, entry)->logTheThing(LOG_TGUI, source, entry))
	logLength++

/* Close open log handles. This should be called as late as possible, and no logging should hapen after. */
/proc/shutdown_logging()
	rustg_log_close_all()

/proc/constructTarget(ref,type)
	if (type == "diary") . = constructName(ref, type)
	else . = "<span class='target'>[constructName(ref, type)]</span>"

/proc/constructName(ref, type)
	var/name
	var/ckey
	var/key
	var/traitor_roles
	var/online
	var/dead = 1
	var/mobType = null
	var/lawsettext = null

	var/mob/mobRef
	if (ismob(ref))
		mobRef = ref
		traitor_roles = mobRef.mind?.list_antagonist_roles()
		if (mobRef.name)
			if (ishuman(mobRef))
				var/mob/living/carbon/human/humanRef = mobRef
				if (mobRef.name != mobRef.real_name && (mobRef.name == "Unknown" || mobRef.name == humanRef.wear_id?:registered))
					name = "[mobRef.real_name] (disguised as [mobRef.name])"
				else
					name = mobRef.name
			else
				name = mobRef.name
			if (length(mobRef.name_suffixes))
				name = mobRef.real_name

		if(isnull(mobRef.client) && isAIeye(mobRef))
			var/mob/living/intangible/aieye/aieye = mobRef
			if(aieye.mainframe?.client)
				mobRef = aieye.mainframe
				mobType = "(AIeye/mainframe)"
		else if(isnull(mobRef.client) && istype(mobRef, /mob/living/silicon/ai))
			var/mob/living/silicon/ai/ai = mobRef
			if(ai.eyecam?.client)
				mobRef = ai.eyecam
				mobType = "(mainframe/AIeye)"
			else if(ai.deployed_shell?.client)
				mobRef = ai.deployed_shell
				mobType = "(mainframe/shell)"
		if (mobRef.key)
			key = mobRef.key
		if (mobRef.ckey)
			ckey = mobRef.ckey
		if (mobRef.client)
			online = 1
		if (!isdead(mobRef))
			dead = 0
	else if (isclient(ref))
		var/client/clientRef = ref
		online = 1
		if (clientRef.mob)
			mobRef = clientRef.mob
			traitor_roles = mobRef.mind?.list_antagonist_roles()
			if (mobRef.name)
				if (ishuman(clientRef.mob))
					var/mob/living/carbon/human/humanRef = clientRef.mob
					if (clientRef.mob.name != clientRef.mob.real_name && (clientRef.mob.name == "Unknown" || clientRef.mob.name == humanRef.wear_id?:registered))
						name = "[clientRef.mob.real_name] (disguised as [clientRef.mob.name])"
					else
						name = clientRef.mob.name
				else
					name = clientRef.mob.name
				if (length(clientRef.mob.name_suffixes))
					name = clientRef.mob.real_name
			if (!isdead(mobRef))
				dead = 0
		if (clientRef.key)
			key = clientRef.key
		if (clientRef.ckey)
			ckey = clientRef.ckey
	else if (istype(ref,/obj/machinery/lawrack))
		var/list/nice_rack  = list()
		var/obj/machinery/lawrack/rack_ref = ref
		nice_rack += rack_ref.name
		nice_rack += "(UID: [rack_ref.unique_id]) at "
		nice_rack += log_loc(rack_ref)
		return nice_rack.Join()
	else if(istype(ref,/datum/mind))
		var/datum/mind/mindRef = ref
		if(mindRef.current && ismob(mindRef.current))
			return(constructName(mindRef.current, type))
		else
			name = "[mindRef.displayed_key] (character destroyed)"
			if (mindRef.key)
				key = mindRef.key
			if (mindRef.ckey)
				ckey = mindRef.ckey
	else
		return ref

	if (mobRef && isnull(mobRef))
		if (ismonkey(mobRef)) mobType = "Monkey"
		else if (isrobot(mobRef)) mobType = "Robot"
		else if (isshell(mobRef)) mobType = "AI Shell"
		else if (isAI(mobRef)) mobType = "AI"
		else if (!ckey && !mobRef.last_ckey) mobType = "NPC"

	if (mobRef && (issilicon(mobRef) || isAIeye(mobRef)))
		var/datum/ai_lawset/lawset = null
		if(isAIeye(mobRef))
			var/mob/living/intangible/aieye/aieye = mobRef
			lawset = aieye?.mainframe?.lawset_connection
		else if(isshell(mobRef))
			var/mob/living/silicon/sil = mobRef
			lawset = sil?.mainframe?.lawset_connection
		else
			var/mob/living/silicon/sil = mobRef
			lawset = sil?.lawset_connection
		if(isnull(lawset))
			lawsettext = "NONE"
		else
			lawsettext = "<a href=\"#\" \
				onMouseOver=\"this.children\[0\].style.display = 'block'\"	\
				onMouseOut=\"this.children\[0\].style.display = 'none';\"		\
				>[lawset.host_rack ? lawset.host_rack.unique_id : "No Lawrack"]										\
				<span id=\"innerContent\" style=\"							\
					display: none;											\
					background: #C8C8C8;									\
					margin-left: 28px;										\
					padding: 10px;											\
					position: absolute;										\
					z-index: 1000;											\
				\">[lawset.format_for_logs()]</span>		\
				</a>"

	var/list/data = list()
	if (name)
		if (type == "diary")
			data += name
		else
			data += SPAN_NAME("[name]")
	if (mobType)
		data += " ([mobType])"
	if (ckey && key)
		if (type == "diary")
			data += "[name ? " (" : ""][key][name ? ")" : ""]"
		else
			data += "[name ? " (" : ""]<a href='byond://?src=%admin_ref%;action=adminplayeropts;targetckey=[ckey]' title='Player Options'>[key]</a>[name ? ")" : ""]"
	else if(mobRef.last_ckey)
		if (type == "diary")
			data += "[name ? " (" : ""]last: [ckey][name ? ")" : ""]"
		else
			data += "[name ? " (" : ""]last: <a href='byond://?src=%admin_ref%;action=adminplayeropts;targetckey=[ckey]' title='Player Options'>[ckey]</a>[name ? ")" : ""]"
	if (traitor_roles)
		if (type == "diary")
			data += " \[TRAITOR\]"
		else
			data += "<a class='traitorTag' href=\"#\" 						\
				onMouseOver=\"this.children\[0\].style.display = 'block'\"	\
				onMouseOut=\"this.children\[0\].style.display = 'none';\"	\
				>T															\
				<span id=\"innerContent\" style=\"							\
					display: none;											\
					background: #ffffff;									\
					margin-left: 28px;										\
					padding: 10px;											\
					position: absolute;										\
					z-index: 1000;											\
				\">[traitor_roles]</span>									\
				</a>"
	if (type != "diary" && !online && ckey)
		data += " \[<span class='offline'>OFF</span>\]"
	if (dead && ticker && current_state > GAME_STATE_PREGAME)
		if (type == "diary")
			data += " \[DEAD\]"
		else
			data += " \[<span class='alert'>DEAD</span>\]"
	if(lawsettext)
		data += "\[Lawset: [lawsettext]\]"
	return data.Join()

proc/log_shot(var/obj/projectile/P,var/obj/SHOT, var/target_is_immune = 0)
	if (!P || !SHOT)
		return
	var/area/A = get_area(SHOT)
	if (A?.dont_log_combat)
		return
	var/shooter_data = null
	var/vehicle
	if (P.mob_shooter)
		shooter_data = P.mob_shooter
	else if (ismob(P.shooter))
		var/mob/M = P.shooter
		shooter_data = M
	var/obj/machinery/vehicle/V
	if (istype(P.shooter,/obj/machinery/vehicle/))
		V = P.shooter
		if (!shooter_data)
			shooter_data = V.pilot
		vehicle = 1
	//Wire: Added this so I don't get a bunch of logs for fukken drones shooting pods WHO CARES
	if (istype(P.shooter, /obj/critter/))
		return

//Pod wars friendly fire check
#if defined(MAP_OVERRIDE_POD_WARS)
	var/friendly_fire = 0
	if (shooter_data != SHOT)
		//if you shoot a teammate
		if (ismob(SHOT) && get_pod_wars_team_num(shooter_data) == get_pod_wars_team_num(SHOT))
			friendly_fire = 1

	if (friendly_fire)
		logTheThing(LOG_COMBAT, shooter_data, "[SPAN_ALERT("Friendly Fire!")][vehicle ? "driving [V.name] " : ""]shoots [constructTarget(SHOT,"combat")][P.was_pointblank != 0 ? " point-blank" : ""][target_is_immune ? " (immune due to spellshield/nodamage)" : ""] at [log_loc(SHOT)]. <b>Projectile:</b> <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", <b>Type:</b> [P.proj_data.type]" :""]")
		if (istype(ticker.mode, /datum/game_mode/pod_wars))
			var/datum/game_mode/pod_wars/mode = ticker.mode
			mode.stats_manager?.inc_friendly_fire(shooter_data)
	else
		logTheThing(LOG_COMBAT, shooter_data, "[vehicle ? "driving [V.name] " : ""]shoots [constructTarget(SHOT,"combat")][P.was_pointblank != 0 ? " point-blank" : ""][target_is_immune ? " (immune due to spellshield/nodamage)" : ""] at [log_loc(SHOT)]. <b>Projectile:</b> <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", <b>Type:</b> [P.proj_data.type]" :""]")
#else
	if (shooter_data)
		logTheThing(LOG_COMBAT, shooter_data, "[vehicle ? "driving [V.name] " : ""]shoots [constructTarget(SHOT,"combat")][P.was_pointblank != 0 ? " point-blank" : ""][target_is_immune ? " (immune due to spellshield/nodamage)" : ""] at [log_loc(SHOT)]. <b>Projectile:</b> <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", <b>Type:</b> [P.proj_data.type]" :""]")
	else
		logTheThing(LOG_COMBAT, SHOT, "is hit by a projectile [target_is_immune ? " (immune due to spellshield/nodamage)" : ""] at [log_loc(SHOT)]. <b>Projectile:</b> <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", <b>Type:</b> [P.proj_data.type]" :""]")
#endif


/proc/log_reagents(var/atom/A as turf|obj|mob)
	var/log_reagents = ""
	// In case we don't get a physical reagent holder. Required for chemSmoke particles (Convair880).
	if (!isnull(A) && istype(A, /datum/reagents/))
		var/datum/reagents/R = A
		for (var/current_id in R.reagent_list)
			var/datum/reagent/current_reagent = R.reagent_list[current_id]
			log_reagents += " [current_reagent] ([current_reagent.volume]),"
		if (log_reagents == "") log_reagents = "Nothing "
		var/final_log = copytext(log_reagents, 1, -1)
		return "(<b>Contents:</b> <i>[final_log]</i>. <b>Temp:</b> <i>[R.total_temperature] K</i>)"
	if (!A)
		return "(<b>Error:</b> <i>no source provided</i>)"
	if (!A.reagents)
		return "(<i>[A] has no reagent holder</i>)"
	if (!A.reagents.total_volume)
		return "(<b>Contents:</b> <i>nothing</i>)"
	for (var/current_id2 in A.reagents.reagent_list)
		var/datum/reagent/current_reagent2 = A.reagents.reagent_list[current_id2]
		log_reagents += " [current_reagent2] ([current_reagent2.volume]),"
	var/final_log2 = copytext(log_reagents, 1, -1)
	return "(<b>Contents:</b> <i>[final_log2]</i>. <b>Temp:</b> <i>[A.reagents.total_temperature] K</i>)" // Added temperature. Even non-lethal chems can be harmful at unusually low or high temperatures (Convair880).

/proc/log_health(var/mob/M)
	var/log_health = ""
	if (ishuman(M) || ismobcritter(M))
		log_health += "[M.get_brain_damage()], [M.get_oxygen_deprivation()], [M.get_toxin_damage()], [M.get_burn_damage()], [M.get_brute_damage()]"
	else if (issilicon(M))
		log_health += "[M.get_burn_damage()], [M.get_brute_damage()]"
	else
		log_health += "No clue! Report this to a coder!"
	return "(<b>Damage:</b> <i>[log_health]</i>)"

// "plain" used for player-visible versions. lazy
/proc/log_loc(var/atom/A, var/plain = FALSE, var/ghostjump=FALSE)
	if (!A)
		return
	var/turf/our_turf = get_turf(A)
	if (!our_turf)
		return "(null)"
	return "([showCoords(our_turf.x, our_turf.y, our_turf.z, plain, ghostjump=ghostjump)] in [our_turf.loc])"

// Does what is says on the tin. We're using the global proc, though (Convair880).
/proc/log_atmos(var/atom/A as turf|obj|mob)
	return scan_atmospheric(A, 0, 1)

/proc/alert_atmos(var/atom/A as turf|obj|mob)
	return scan_atmospheric(A, 0, 0, 0, 1)

/proc/get_log_data_html(logType as text, searchString as text, var/datum/admins/requesting_admin)
	if (!searchString)
		searchString = ""
	var/nameRegex
	try
		nameRegex = regex(searchString,"ig")
	catch()
		nameRegex = searchString
		logTheThing(LOG_DEBUG, null, "Tried to search logs with invalid regex, switching to plain text: [searchString]")

	var/list/dat = list("<table>")

	logType = replacetext(logType, "_string", "")
	logType = replacetext(logType, "_log", "")

	var/prettyLogName = replacetext(logType, "_", " ")
	if (prettyLogName == "alls") prettyLogName = "all"

	var/foundCount = 0
	if (logType == "alls")
		for (var/log in logs)
			if(log == "audit") continue
			if(log == "topic")
				if (requesting_admin.tempmin)
					continue
				if (!requesting_admin.show_topic_log)
					continue
			var/list/logList = logs[log]
			prettyLogName = replacetext(log, "_", " ")
			var/list/searchData = list()
			var/found
			for (var/l in logList)
				if (findtext(l, nameRegex, 1, null))
					searchData += "<tr class='log'>[l]</tr>"
					found = 1
					foundCount++
			if (found) dat += "<tr><td colspan='3' class='header [log]'>[prettyLogName] logs</td></tr>"
			dat += searchData.Join()
	else
		var/list/logList = logs[logType]
		dat += "<tr><td colspan='3' class='header [logType]'>[prettyLogName] logs</td></tr>"
		if (!logList)
			CRASH("get_log_data called with invalid log type: \"[logType]\"")
		else if (!logList.len)
			dat += "<tr><td colspan='3' class='log'>No results in [prettyLogName] logs.</td></tr>"
		else
			if (searchString)
				for (var/l in logList)
					if (findtext(l, nameRegex, 1, null))
						dat += "<tr class='log'>[l]</tr>"
						foundCount++
			else
				for (var/l in logList)
					dat += "<tr class='log'>[l]</tr>"
					foundCount++
		dat += "</table>"

	var/str_dat = "<tr><td colspan='3' class='header text-normal [logType]'><b>Logs</b>[searchString ? " (Searched for '[searchString]')" : ""]. Found <b>[foundCount]</b> results.</td></tr>" + dat.Join()
	str_dat = replacetext(str_dat, "%admin_ref%", "\ref[requesting_admin]")
	var/adminLogHtml = grabResource("html/admin/admin_log.html")
	adminLogHtml = replacetext(adminLogHtml, "<!-- TABLE GOES HERE -->", str_dat)

	return adminLogHtml
