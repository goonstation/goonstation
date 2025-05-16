/**
  * # World
  *
  * If you think this Universe is bad, you should see some of the others. ~ Philip K. Dick
  *
  * The byond world object stores some basic byond level config, and has a few hub specific procs for managing hub visiblity
  *
  * The world /New() is the root of where a round itself begins
  */
/world
	mob = /mob/new_player

	#ifdef MOVING_SUB_MAP //Defined in the map-specific .dm configuration file.
	turf = /turf/space/fluid/manta
	#elif defined(UNDERWATER_MAP)
	turf = /turf/space/fluid
	#else
	turf = /turf/space
	#endif

	area = /area/space
	movement_mode = TILE_MOVEMENT_MODE //Touching this will almost certainly break all glides. DO NOT TOUCH THIS unless you are willing to shoulder an absolute mountain of work.

	view = "15x15"

	hub = "Exadv1.SpaceStation13"
	hub_password = "kMZy3U5jJHSiBQjr"
	name = "Goonstation 13"


/world/proc/update_status()
	Z_LOG_DEBUG("World/Status", "Updating status")

	var/list/statsus = list()

	if (config?.server_name)
		statsus += "<b><a href=\"[config.goonhub_url]\">[config.server_name]</a></b>"
	else
		statsus += "<b>SERVER NAME HERE</b>"

	statsus += " — The classic SS13 experience. — (<a href=\"http://bit.ly/gndscd\">Discord</a>)<br>"

	if(ticker?.round_elapsed_ticks > 0 && current_state == GAME_STATE_PLAYING)
		statsus += "Time: <b>[round(ticker.round_elapsed_ticks / 36000)]:[add_zero(num2text(ticker.round_elapsed_ticks / 600 % 60), 2)]</b>"
	else if (current_state == GAME_STATE_FINISHED)
		statsus += "<b>RESTARTING</b>"
	else if(!ticker)
		statsus += "<b>STARTING</b>"
	else if(ticker?.pregame_timeleft && current_state <= GAME_STATE_PREGAME)
		statsus += "Starting: <b>[ticker.pregame_timeleft]</b>"

	if(emergency_shuttle?.online && emergency_shuttle.location < SHUTTLE_LOC_RETURNED)
		var/timeleft = emergency_shuttle.timeleft()
		if(timeleft)
			var/locstr
			if(emergency_shuttle.location == SHUTTLE_LOC_STATION)
				locstr = "ETD"
			else if(emergency_shuttle.location == SHUTTLE_LOC_TRANSIT)
				locstr = "ESC"
			else if(emergency_shuttle.direction == SHUTTLE_DIRECTION_TO_CENTCOMM)
				locstr = "RCL"
			else
				locstr = "ETA"
			statsus += " | Shuttle: <b>[locstr] [(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</b><br>"
	else
		statsus += "<br>"

	if (map_settings)
		var/map_name = istext(map_settings.display_name) ? "[map_settings.display_name]" : "[getMapNameFromID(map_setting)]"
		//var/map_link_str = map_settings.goonhub_map ? "<a href=\"[map_settings.goonhub_map]\">[map_name]</a>" : "[map_name]"
		statsus += "Map: <b>[map_name]</b>"
		if(mapSwitcher?.next)
			statsus += " | Next: <b>[mapSwitcher.next]</b><br>"
		else
			statsus += "<br>"

	var/list/features = list()

	//if(ticker && master_mode && !ticker.hide_mode)
	//	features += "Mode: <b>[master_mode]</b>"

	if (!enter_allowed)
		features += "closed"

	if (abandon_allowed)
		features += "respawn allowed"

	if(features)
		statsus += "[jointext(features, ", ")]"

	/* does this help? I do not know */
	statsus = statsus.Join()
	if (src.status != statsus)
		src.status = statsus

	Z_LOG_DEBUG("World/Status", "Status update complete")


/world/proc/load_mode()
	set background = 1
	var/text = file2text("data/mode.txt")
	if (text)
		var/list/lines = splittext(text, "\n")
		if (lines[1])
			master_mode = lines[1]
			next_round_mode = master_mode
			logDiary("Saved mode is '[master_mode]'")


/world/proc/save_mode(var/the_mode)
	rustg_file_write(the_mode, "data/mode.txt")
	next_round_mode = the_mode


/world/proc/load_intra_round_value(var/field) //Currently for solarium effects, could also be expanded to that pickle jar idea.
	var/path = "data/intra_round.sav"

	if (!fexists(path))
		return null

	var/savefile/F = new /savefile(path, 10)
	if (!F)
		logTheThing(LOG_DEBUG, null, "Failed to load intra round value \"[field]\". Save file exists but may be locked by another process.")
		return
	F["[field]"] >> .


/world/proc/save_intra_round_value(var/field, var/value)
	if (!field || isnull(value))
		return -1

	var/savefile/F = new /savefile("data/intra_round.sav", 10)
	if (!F)
		logTheThing(LOG_DEBUG, null, "Unable to save intra round value to field \"[field]\". Save file may be locked by another process.")
		return
	if (F.Lock(10))
		F["[field]"] << value
		return 0
	else
		logTheThing(LOG_DEBUG, null, "Unable to save intra round value to field \"[field]\". Failed to obtain an exclusive save file lock.")

/world/proc/setMaxZ(new_maxz)
	// when calling this proc if you don't care about the actual contents of the new z-level you might want to set
	// global.dont_init_space = TRUE before calling this proc and unset it afterwards. This will speed things up but
	// the space filling this z-level will be somewhat broken (which you will hopefully replace with whatever it is you want to replace it with).
	if (!isnum(new_maxz) || new_maxz <= src.maxz)
		return src.maxz
	for (var/zlevel = world.maxz+1; zlevel <= new_maxz; zlevel++)
		#ifdef CHECK_MORE_RUNTIMES
		in_replace_with++
		// technically we are not in ReplaceWith but for the new turfs created here we don't want to emit the warnings because they are not replacing
		// anything, they are just being created
		#endif
		src.maxz++
		#ifdef CHECK_MORE_RUNTIMES
		in_replace_with--
		#endif
		src.setupZLevel(zlevel)
	return src.maxz

/world/proc/setupZLevel(new_zlevel)
	global.zlevels += new/datum/zlevel("dyn[new_zlevel]", length(global.zlevels) + 1)
