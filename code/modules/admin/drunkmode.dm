//Verbs we have deemed "server-breaking" or just anything a drunkmin probably shouldnt have
var/list/dangerousVerbs = list(\

//No accidentally restarting the server
/verb/restart_the_fucking_server_i_mean_it,\
/datum/admins/proc/restart,\

//Music/sounds
/client/proc/open_dj_panel,\

//No banning for you
/client/proc/warn,\
/client/proc/openBanPanel,\
/client/proc/cmd_admin_addban,\
/client/proc/banooc,\
/client/proc/sharkban,\

//This is a little involved for a drunk person huh
/client/proc/main_loop_context,\
/client/proc/main_loop_tick_detail,\
/client/proc/cmd_explosion,\

//Shitguy stuff
/client/proc/debug_variables,\
/client/proc/cmd_debug_mutantrace,\
/client/proc/cmd_debug_del_all,\
/client/proc/general_report,\
/client/proc/map_debug_panel,\
/client/proc/air_report,\
/client/proc/air_status,\
/client/proc/fix_next_move,\
/client/proc/debugreward,\

//Coder stuff this is mostly all dangerous shit
/client/proc/cmd_modify_market_variables,\
/client/proc/BK_finance_debug,\
/client/proc/BK_alter_funds,\
/client/proc/debug_pools,\
/client/proc/debug_variables,\
/client/proc/debug_global_variable,\
/client/proc/call_proc,\
/client/proc/call_proc_all,\
/client/proc/ticklag,\
/client/proc/cmd_debug_vox,\
/client/proc/mapWorld,\
/client/proc/haine_blood_debug,\
/client/proc/debug_messages,\
/client/proc/debug_reaction_list,\
/client/proc/debug_reagents_cache,\
/client/proc/set_admin_level,\
/client/proc/show_camera_paths, \
/*/client/proc/remove_camera_paths_verb, \*/
/client/proc/check_gang_scores,\
/client/proc/critter_creator_debug,\
/client/proc/debug_deletions,\
/client/proc/cmd_modify_controller_variables,\
/client/proc/cmd_modify_ticker_variables,\
/client/proc/find_thing,\
/client/proc/find_one_of,\
/client/proc/find_all_of,\
/client/proc/fix_powernets,\
/client/proc/cmd_job_controls,\

//Toggles (these are ones that could be very confusing to accidentally toggle for a drunk person)
/client/proc/toggle_toggles,\
/client/proc/toggle_popup_verbs,\
/client/proc/toggle_server_toggles_tab,\
/datum/admins/proc/toggleenter,\
/datum/admins/proc/toggle_blood_system,\
/datum/admins/proc/toggle_bone_system,\
/client/proc/togglebuildmode,\
/client/proc/toggle_atom_verbs,\
/client/proc/toggle_camera_network_reciprocity, \
/client/proc/toggle_atom_verbs,\
/client/proc/toggle_extra_verbs,\
/datum/admins/proc/togglethetoggles,\

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
			src.verbs -= /client/proc/enableDrunkMode
			src.verbs += /client/proc/disableDrunkMode
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
			src.verbs -= /client/proc/disableDrunkMode
			src.verbs += /client/proc/enableDrunkMode
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
			C.verbs -= /client/proc/disableDrunkMode
			C.verbs += /client/proc/enableDrunkMode

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
			C.verbs -= /client/proc/enableDrunkMode
			C.verbs += /client/proc/disableDrunkMode

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
