/* Hello these are the new logs wow gosh look at this isn't it exciting
Some procs  exist for replacement within text:
	[constructTarget(target,type)]

Example in-game log call:
		logTheThing("admin", src, M, "shot that nerd [constructTarget(src,"diary")] at [log_loc(usr)]")
Example out of game log call:
		logTheThing("diary", src, null, "gibbed everyone ever", "admin")
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

/proc/logTheThing(type, source, target, text, diaryType)
	var/diaryLogging
	var/forceNonDiaryLoggingToo = FALSE
	var/area/A

	if (source)
		A = get_area(source)
		source = constructName(source, type)
	else
		if (type != "diary") source = "<span class='blank'>(blank)</span>"

	//if (target) target does nothing but i cant be assed to remove its arg from every single logthething and idk regex
	//	target = constructTarget(target,type)

	if (disable_log_lists) // lag reduction hack - ONLY print logs to the web versions
		if (type == "diary")
			switch (diaryType)
				//These are things we log in the out of game logs (the diary)
				if ("admin") if (config.log_admin) diaryLogging = 1
				if ("ahelp") if (config.log_say) diaryLogging = 1 //log_ahelp
				if ("mhelp") if (config.log_say) diaryLogging = 1 //log_mhelp
				if ("game") if (config.log_game) diaryLogging = 1
				if ("access") if (config.log_access) diaryLogging = 1
				if ("say") if (config.log_say) diaryLogging = 1
				if ("ooc") if (config.log_ooc) diaryLogging = 1
				if ("whisper") if (config.log_whisper) diaryLogging = 1
				if ("station") if (config.log_station) diaryLogging = 1
				if ("combat") if (config.log_combat) diaryLogging = 1
				if ("telepathy") if (config.log_telepathy) diaryLogging = 1
				if ("debug") if (config.log_debug) diaryLogging = 1
				if ("vehicle") if (config.log_vehicles) diaryLogging = 1


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
			if ("audit")
				logs["audit"] += ingameLog
				diaryLogging = 1
				diaryType = "audit"
				forceNonDiaryLoggingToo = TRUE
			if ("admin") logs["admin"] += ingameLog
			if ("admin_help") logs["admin_help"] += ingameLog
			if ("mentor_help") logs["mentor_help"] += ingameLog
			if ("say") logs["speech"] += ingameLog
			if ("ooc") logs["ooc"] += ingameLog
			if ("whisper") logs["speech"] += ingameLog
			if ("station") logs["station"] += ingameLog
			if ("combat")
				if (A?.dont_log_combat)
					return
				logs["combat"] += ingameLog
			if ("telepathy") logs["telepathy"] += ingameLog
			if ("debug") logs["debug"] += ingameLog
			if ("pdamsg") logs["pdamsg"] += ingameLog
			if ("signalers") logs["signalers"] += ingameLog
			if ("bombing") logs["bombing"] += ingameLog
			if ("atmos") logs["atmos"] += ingameLog
			if ("pathology") logs["pathology"] += ingameLog
			if ("deleted") logs["deleted"] += ingameLog
			if ("vehicle") logs["vehicle"] += ingameLog
			if ("computers") logs["computers"] += ingameLog
			if ("diary")
				switch (diaryType)
					//These are things we log in the out of game logs (the diary)
					if ("admin") if (config.log_admin) diaryLogging = 1
					if ("ahelp") if (config.log_say) diaryLogging = 1 //log_ahelp
					if ("mhelp") if (config.log_say) diaryLogging = 1 //log_mhelp
					if ("game") if (config.log_game) diaryLogging = 1
					if ("access") if (config.log_access) diaryLogging = 1
					if ("say") if (config.log_say) diaryLogging = 1
					if ("ooc") if (config.log_ooc) diaryLogging = 1
					if ("whisper") if (config.log_whisper) diaryLogging = 1
					if ("station") if (config.log_station) diaryLogging = 1
					if ("combat") if (config.log_combat) diaryLogging = 1
					if ("telepathy") if (config.log_telepathy) diaryLogging = 1
					if ("debug") if (config.log_debug) diaryLogging = 1
					if ("vehicle") if (config.log_vehicles) diaryLogging = 1


		if (diaryLogging)
			WRITE_LOG(diary_name, "[diaryType]: [source ? "[source] ": ""][text]")

		//A little trial run of full logs saved to disk. They are cleared by the server every so often (cronjob) (HEH NOT ANYMORE)
		if ((!diaryLogging || forceNonDiaryLoggingToo) && config.allowRotatingFullLogs)
			WRITE_LOG(roundLog_name, "\[[type]] [source && source != "<span class='blank'>(blank)</span>" ? "[source]: ": ""][text]<br>")
			logLength++
	return

/proc/logDiary(text)
	WRITE_LOG(diary_name, "[text]")

/**
 * Appends a tgui-related log entry. All arguments are optional.
 */
/proc/log_tgui(user, message, context,
		datum/tgui_window/window,
		datum/src_object)
	var/entry = "\[tgui\] " // |GOONSTATION-CHANGE| (tgui:->\[tgui\])
	// Insert user info
	if(!user)
		entry += "(nobody)" // |GOONSTATION-CHANGE| (<nobody>->(nobody))
	else if(istype(user, /mob))
		var/mob/mob = user
		entry += "[mob.ckey] (as [mob] at [mob.x],[mob.y],[mob.z])"
	else if(istype(user, /client))
		var/client/client = user
		entry += "[client.ckey]"
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
	WRITE_LOG(roundLog_name, entry)
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
	var/traitor
	var/online
	var/dead = 1
	var/mobType = null
	var/lawracktext = null

	var/mob/mobRef
	if (ismob(ref))
		mobRef = ref
		traitor = checktraitor(mobRef)
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
			traitor = checktraitor(mobRef)
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
	else
		return ref

	if (mobRef && isnull(mobRef))
		if (ismonkey(mobRef)) mobType = "Monkey"
		else if (isrobot(mobRef)) mobType = "Robot"
		else if (isshell(mobRef)) mobType = "AI Shell"
		else if (isAI(mobRef)) mobType = "AI"
		else if (!ckey && !mobRef.last_ckey) mobType = "NPC"

	if (mobRef && (issilicon(mobRef) || isAIeye(mobRef)))
		var/obj/machinery/lawrack/lawrack = null
		if(isAIeye(mobRef))
			var/mob/living/intangible/aieye/aieye = mobRef
			lawrack = aieye?.mainframe?.law_rack_connection
		else if(isshell(mobRef))
			var/mob/living/silicon/sil = mobRef
			lawrack = sil?.mainframe?.law_rack_connection
		else
			var/mob/living/silicon/sil = mobRef
			lawrack = sil?.law_rack_connection
		if(isnull(lawrack))
			lawracktext = "NONE"
		else
			lawracktext = "<a href=\"#\" \
				onMouseOver=\"this.children\[0\].style.display = 'block'\"	\
				onMouseOut=\"this.children\[0\].style.display = 'none';\"		\
				>[lawrack.unique_id]										\
				<span id=\"innerContent\" style=\"							\
					display: none;											\
					background: #C8C8C8;									\
					margin-left: 28px;										\
					padding: 10px;											\
					position: absolute;										\
					z-index: 1000;											\
				\">[lawrack.format_for_logs()]</span>		\
				</a>"

	var/list/data = list()
	if (name)
		if (type == "diary")
			data += name
		else
			data += "<span class='name'>[name]</span>"
	if (mobType)
		data += " ([mobType])"
	if (ckey && key)
		if (type == "diary")
			data += "[name ? " (" : ""][key][name ? ")" : ""]"
		else
			data += "[name ? " (" : ""]<a href='?src=%admin_ref%;action=adminplayeropts;targetckey=[ckey]' title='Player Options'>[key]</a>[name ? ")" : ""]"
	else if(mobRef.last_ckey)
		if (type == "diary")
			data += "[name ? " (" : ""]last: [ckey][name ? ")" : ""]"
		else
			data += "[name ? " (" : ""]last: <a href='?src=%admin_ref%;action=adminplayeropts;targetckey=[ckey]' title='Player Options'>[ckey]</a>[name ? ")" : ""]"
	if (traitor)
		if (type == "diary")
			data += " \[TRAITOR\]"
		else
			data += " \[<span class='traitorTag'>T</span>\]"
	if (type != "diary" && !online && ckey)
		data += " \[<span class='offline'>OFF</span>\]"
	if (dead && ticker && current_state > GAME_STATE_PREGAME)
		if (type == "diary")
			data += " \[DEAD\]"
		else
			data += " \[<span class='alert'>DEAD</span>\]"
	if(lawracktext)
		data += "\[LawRack: [lawracktext]\]"
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
		logTheThing("combat", shooter_data, SHOT, "<span class='alert'>Friendly Fire!</span>[vehicle ? "driving [V.name] " : ""]shoots [constructTarget(SHOT,"combat")][P.was_pointblank != 0 ? " point-blank" : ""][target_is_immune ? " (immune due to spellshield/nodamage)" : ""] at [log_loc(SHOT)]. <b>Projectile:</b> <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", <b>Type:</b> [P.proj_data.type]" :""]")
		if (istype(ticker.mode, /datum/game_mode/pod_wars))
			var/datum/game_mode/pod_wars/mode = ticker.mode
			mode.stats_manager?.inc_friendly_fire(shooter_data)
	else
		logTheThing("combat", shooter_data, SHOT, "[vehicle ? "driving [V.name] " : ""]shoots [constructTarget(SHOT,"combat")][P.was_pointblank != 0 ? " point-blank" : ""][target_is_immune ? " (immune due to spellshield/nodamage)" : ""] at [log_loc(SHOT)]. <b>Projectile:</b> <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", <b>Type:</b> [P.proj_data.type]" :""]")
#else
	logTheThing("combat", shooter_data, SHOT, "[vehicle ? "driving [V.name] " : ""]shoots [constructTarget(SHOT,"combat")][P.was_pointblank != 0 ? " point-blank" : ""][target_is_immune ? " (immune due to spellshield/nodamage)" : ""] at [log_loc(SHOT)]. <b>Projectile:</b> <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", <b>Type:</b> [P.proj_data.type]" :""]")
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

/proc/log_loc(var/atom/A)
	if (!A)
		return
	var/turf/our_turf = get_turf(A)
	if (!our_turf)
		return
	return "([showCoords(our_turf.x, our_turf.y, our_turf.z)] in [our_turf.loc])"

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
		logTheThing("debug", null, null, "Tried to search logs with invalid regex, switching to plain text: [searchString]")

	var/list/dat = list("<table>")

	logType = replacetext(logType, "_string", "")
	logType = replacetext(logType, "_log", "")

	var/prettyLogName = replacetext(logType, "_", " ")
	if (prettyLogName == "alls") prettyLogName = "all"

	var/foundCount = 0
	if (logType == "alls")
		for (var/log in logs)
			if(log == "audit") continue
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
