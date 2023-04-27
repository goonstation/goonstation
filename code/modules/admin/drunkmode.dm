//Verbs we have deemed "server-breaking" or just anything a drunkmin probably shouldnt have
var/list/dangerousVerbs = list(\

//No accidentally restarting the server
/verb/restart_the_fucking_server_i_mean_it,\
TYPE_PROC_REF(/datum/admins, restart),\

//Music/sounds
TYPE_PROC_REF(/client, open_dj_panel),\

//No banning for you
TYPE_PROC_REF(/client, warn),\
TYPE_PROC_REF(/client, openBanPanel),\
TYPE_PROC_REF(/client, cmd_admin_addban),\
TYPE_PROC_REF(/client, banooc),\
TYPE_PROC_REF(/client, sharkban),\

//This is a little involved for a drunk person huh
TYPE_PROC_REF(/client, main_loop_context),\
TYPE_PROC_REF(/client, main_loop_tick_detail),\
TYPE_PROC_REF(/client, cmd_explosion),\

//Shitguy stuff
TYPE_PROC_REF(/client, debug_variables),\
TYPE_PROC_REF(/client, cmd_debug_mutantrace),\
TYPE_PROC_REF(/client, cmd_debug_del_all),\
TYPE_PROC_REF(/client, general_report),\
TYPE_PROC_REF(/client, map_debug_panel),\
TYPE_PROC_REF(/client, air_report),\
TYPE_PROC_REF(/client, air_status),\
TYPE_PROC_REF(/client, fix_next_move),\
TYPE_PROC_REF(/client, debugreward),\

//Coder stuff this is mostly all dangerous shit
TYPE_PROC_REF(/client, cmd_modify_market_variables),\
TYPE_PROC_REF(/client, BK_finance_debug),\
TYPE_PROC_REF(/client, BK_alter_funds),\
TYPE_PROC_REF(/client, debug_pools),\
TYPE_PROC_REF(/client, debug_variables),\
TYPE_PROC_REF(/client, debug_global_variable),\
TYPE_PROC_REF(/client, call_proc),\
TYPE_PROC_REF(/client, call_proc_all),\
TYPE_PROC_REF(/client, ticklag),\
TYPE_PROC_REF(/client, cmd_debug_vox),\
TYPE_PROC_REF(/client, mapWorld),\
TYPE_PROC_REF(/client, haine_blood_debug),\
TYPE_PROC_REF(/client, debug_messages),\
TYPE_PROC_REF(/client, debug_reaction_list),\
TYPE_PROC_REF(/client, debug_reagents_cache),\
TYPE_PROC_REF(/client, set_admin_level),\
TYPE_PROC_REF(/client, show_camera_paths), \
/*TYPE_PROC_REF(/client, remove_camera_paths_verb), \*/
TYPE_PROC_REF(/client, check_gang_scores),\
TYPE_PROC_REF(/client, critter_creator_debug),\
TYPE_PROC_REF(/client, debug_deletions),\
TYPE_PROC_REF(/client, cmd_modify_controller_variables),\
TYPE_PROC_REF(/client, cmd_modify_ticker_variables),\
TYPE_PROC_REF(/client, find_thing),\
TYPE_PROC_REF(/client, find_one_of),\
TYPE_PROC_REF(/client, find_all_of),\
TYPE_PROC_REF(/client, fix_powernets),\
TYPE_PROC_REF(/client, cmd_job_controls),\

//Toggles (these are ones that could be very confusing to accidentally toggle for a drunk person)
TYPE_PROC_REF(/client, toggle_toggles),\
TYPE_PROC_REF(/client, toggle_popup_verbs),\
TYPE_PROC_REF(/client, toggle_server_toggles_tab),\
TYPE_PROC_REF(/datum/admins, toggleenter),\
TYPE_PROC_REF(/datum/admins, toggle_blood_system),\
TYPE_PROC_REF(/datum/admins, toggle_bone_system),\
TYPE_PROC_REF(/client, togglebuildmode),\
TYPE_PROC_REF(/client, toggle_atom_verbs),\
TYPE_PROC_REF(/client, toggle_camera_network_reciprocity), \
TYPE_PROC_REF(/client, toggle_atom_verbs),\
TYPE_PROC_REF(/client, toggle_extra_verbs),\
TYPE_PROC_REF(/datum/admins, togglethetoggles),\

/client/proc/forceDrunkMode\
)

/client/proc/enableDrunkMode()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Enable Drunk Mode"
	set desc = "Are you drunk and slightly responsible still? Turn this on!"
	set popup_menu = 0

	ADMIN_ONLY

	if (alert("Enable drunk mode for yourself?", "Confirmation", "Yes", "No") == "Yes")
		var/not_drunk_but_high = (alert("Are you boozin' or weedin'", "drugs", "Drunk", "High") == "High")

		if (src)
			src.verbs -= TYPE_PROC_REF(/client, enableDrunkMode)
			src.verbs += TYPE_PROC_REF(/client, disableDrunkMode)
			src.toggleDrunkMode(src, not_drunk_but_high)
	return

/client/proc/disableDrunkMode()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Disable Drunk Mode"
	set desc = "Done being drunk? We'll see."
	set popup_menu = 0

	ADMIN_ONLY

	//Puzzle goes here
	var/message = "Hello! You are drunk! Think you're not? Solve this simple puzzle then.\n\n"
	//generate two, two digit numbers
	var/num1 = rand(10,99)
	var/num2 = rand(10,99)
	var/answer = num1 + num2
	message += "What is [num1] + [num2]?\n\n"
	message += "You have to give your answer in WORDS! e.g. 310 = three hundred and ten"

	answer = get_english_num(answer)

	var/puzzle = input(src, message, "Puzzle time!") as text
	if (puzzle)
		if (puzzle == answer)
			src.verbs -= TYPE_PROC_REF(/client, disableDrunkMode)
			src.verbs += TYPE_PROC_REF(/client, enableDrunkMode)
			src.toggleDrunkMode(src)
		else
			message_admins("[key_name(src)] tried to disable drunk-mode on himself but failed the puzzle ([num1] + [num2]). Everyone laugh at them.")
			alert("WRONG! This highly scientific test has determined that you are still drunk, the mode has not been disabled.")
	else
		return


/client/proc/forceDrunkMode(var/client/C in onlineAdmins)
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set name = "Force Drunk Mode"
	set desc = "Is another admin drunk as a skunk? Put them in drunk mode sharpish."
	set popup_menu = 0

	if (!C) return

	ADMIN_ONLY

	//Apparently if the onlineAdmins list contains only one entry, it just picks it by default without giving any input
	if (src == C)
		alert("There are no other admins online besides you")
		return

	src.toggleDrunkMode(C)


/client/proc/toggleDrunkMode(var/client/C, var/is_actually_high = 0)
	if (!C) return

	ADMIN_ONLY

	var/forced = 0
	if (C != src)
		forced = 1

	if (!C.holder)
		alert("This person is not an admin you dumbass")
		return
	if (C.holder.level <= LEVEL_BABBY)
		if (forced)
			alert("They're a lowmin nobody cares if they're drunk go away")
		else
			alert("You're a lowmin nobody cares if you're drunk go away")
		return

	if (C.holder.drunk)
		//turn it off
		C.clear_admin_verbs()
		C.update_admins(C.holder.priorRank)
		admins[C.ckey] = C.holder.priorRank
		C.holder.drunk = 0

		if (forced)
			C.verbs -= TYPE_PROC_REF(/client, disableDrunkMode)
			C.verbs += TYPE_PROC_REF(/client, enableDrunkMode)

		var/logMessage = (forced ? "was forced out of drunk-mode by [key_name(src)]" : "has disabled drunk-mode for themselves")
		logTheThing(LOG_ADMIN, C, logMessage)
		logTheThing(LOG_DIARY, C, logMessage, "admin")
		message_admins("[key_name(C)] [logMessage]")

	else
		//turn it on
		C.holder.priorRank = C.holder.rank
		C.holder.rank = "Drunkmin"
		C.verbs -= dangerousVerbs
		admins[C.ckey] = "Drunkmin"
		C.holder.drunk = 1

		if (forced)
			C.verbs -= TYPE_PROC_REF(/client, enableDrunkMode)
			C.verbs += TYPE_PROC_REF(/client, disableDrunkMode)

		var/logMessage = (forced ? "was forced into drunk-mode by [key_name(src)]" : "has enabled drunk-mode for themselves")
		logTheThing(LOG_ADMIN, C, logMessage)
		logTheThing(LOG_DIARY, C, logMessage, "admin")
		message_admins("[key_name(C)] [logMessage]")

		if (!is_actually_high)
			//Make centcom announcement
			var/list/announce = list(\
				"is drunk as a skunk",\
				"makes poor life choices",\
				"likes to get wasted and play terrible space farting games. What a loser",\
				"is here to ruin everyone's round",\
				"\"I'm drunk it doesn't have to make sense\""\
			)
			command_alert("[C.key] [pick(announce)].", "Drunkmin detected")

		else
			//Make centcom announcement
			var/list/announce = list(\
				"is high as a kite",\
				"makes poor life choices",\
				"likes to get stoned and play terrible space farting games. What a loser",\
				"is here to ruin everyone's round",\
				"\"I'm high it doesn't have to make sense\""\
			)
			command_alert("[C.key] [pick(announce)].", "Weedmin detected")

		boutput(C, "<span class='alert'><b><big>You are now in drunk-mode!</big></b><br>You will have reduced powers so you can't fuck shit up so much.<br>Use \"Disable Drunk Mode\" to disable this.</span>")
