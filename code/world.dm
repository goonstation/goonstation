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
	movement_mode = TILE_MOVEMENT_MODE

	view = "15x15"

	hub = "Exadv1.SpaceStation13"
	hub_password = "kMZy3U5jJHSiBQjr"
	name = "Goonstation 13"

//Let's clarify something. I don't know if it needs clarifying, but here I go anyways.

//The UNDERWATER_MAP define is for things that should only be changed if the map is an underwater one.
//Things like fluid turfs that would break on a normal map.

//The map_currently_underwater global var is a variable to change how fluids and other objects interact with the current map.
//This allows you to put ANY map 'underwater'. However, since underwater-specific maps are always underwater I set that here.

#ifdef UNDERWATER_MAP
var/global/map_currently_underwater = 1
#else
var/global/map_currently_underwater = 0
#endif

#ifdef TWITCH_BOT_ALLOWED
var/global/mob/twitch_mob = 0
#endif

/world/proc/load_mode()
	set background = 1
	var/text = file2text("data/mode.txt")
	if (text)
		var/list/lines = splittext(text, "\n")
		if (lines[1])
			master_mode = lines[1]
			logDiary("Saved mode is '[master_mode]'")

/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

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

/world/proc/load_motd()
	join_motd = grabResource("html/motd.html")

/world/proc/load_rules()
	rules = {"<meta http-equiv="refresh" content="0; url=http://wiki.ss13.co/Rules">"}


// dsingh for faster create panel loads
/world/proc/precache_create_txt()
	set background = 1
	if (!create_mob_html)
		var/mobjs = null
		mobjs = jointext(typesof(/mob), ";")
		create_mob_html = grabResource("html/admin/create_object.html")
		create_mob_html = replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	if (!create_object_html)
		var/objectjs = null
		objectjs = jointext(typesof(/obj), ";")
		create_object_html = grabResource("html/admin/create_object.html")
		create_object_html = replacetext(create_object_html, "null /* object types */", "\"[objectjs]\"")

	if (!create_turf_html)
		var/turfjs = null
		turfjs = jointext(typesof(/turf), ";")
		create_turf_html = grabResource("html/admin/create_object.html")
		create_turf_html = replacetext(create_turf_html, "null /* object types */", "\"[turfjs]\"")

var/f_color_selector_handler/F_Color_Selector

/proc/buildMaterialPropertyCache()
	if(materialProps.len) return
	for(var/A in childrentypesof(/datum/material_property)) //Caching material props
		var/datum/material_property/R = new A()
		materialProps.Add(R)
	return

/proc/createRenderSourceHolder()
	if(!renderSourceHolder)
		renderSourceHolder = new(locate(1,1,1))
		renderSourceHolder.name = "SCREEN HOLDER"
		renderSourceHolder.screen_loc = "CENTER"
		renderSourceHolder.mouse_opacity = 0
		renderSourceHolder.render_target = "*renderSourceHolder"

/proc/buildMaterialCache()
	material_cache = list()
	var/materialList = concrete_typesof(/datum/material)
	for(var/mat in materialList)
		var/datum/material/M = new mat()
		material_cache.Add(M.mat_id)
		material_cache[M.mat_id] = M

#ifdef TRACY_PROFILER_HOOK
/proc/prof_init()
	var/lib
	switch(world.system_type)
		if(MS_WINDOWS) lib = "prof.dll"
		if(UNIX) lib = "libprof.so"
		else CRASH("unsupported platform")

	var/init = call(lib, "init")()
	if("0" != init) CRASH("[lib] init error: [init]")
#endif

//Called BEFORE the map loads. Useful for objects that require certain things be set during init
/datum/preMapLoad
	New()
#ifdef TRACY_PROFILER_HOOK
		prof_init()
#endif
#ifdef LIVE_SERVER
		world.log = file("data/errors.log")
#endif
		enable_auxtools_debugger()
#ifdef REFERENCE_TRACKING
		enable_reference_tracking()
#endif

#if defined(SERVER_SIDE_PROFILING) && (defined(SERVER_SIDE_PROFILING_FULL_ROUND) || defined(SERVER_SIDE_PROFILING_PREGAME))
#warn Profiler enabled at start of init
		world.Profile(PROFILE_START | PROFILE_AVERAGE, "sendmaps", "json")
#endif
		server_start_time = world.timeofday

#ifdef Z_LOG_ENABLE
		ZLOG_START_TIME = world.timeofday
#endif
		Z_LOG_DEBUG("Preload", "Map preload running.")

#ifndef RUNTIME_CHECKING
		world.log << ""
		world.log << "========================================"
		world.log << "\[[time2text(world.timeofday,"hh:mm:ss")]\] Starting new round"
		world.log << "========================================"
		world.log << ""
#endif

		Z_LOG_DEBUG("Preload", "  radio")
		radio_controller = new /datum/controller/radio()

		Z_LOG_DEBUG("Preload", "Loading config...")
		config = new /datum/configuration()
		config.load("config/config.txt")

		if (config.server_specific_configs && world.port > 0)
			var/specific_config = "config/config-[world.port].txt"
			if (fexists(specific_config))
				config.load(specific_config)

		serverKey = config.server_key ? config.server_key : (world.port % 1000) / 100

		if (config.allowRotatingFullLogs)
			roundLog << "========================================<br>"
			roundLog << "\[[time2text(world.timeofday,"hh:mm:ss")]\] <b>Starting new round</b><br>"
			roundLog << "========================================<br>"
			roundLog << "<br>"
			logLength += 4

		Z_LOG_DEBUG("Preload", "Applying config...")
		// apply some settings from config..
		abandon_allowed = config.respawn
		cdn = config.cdn
		disableResourceCache = config.disableResourceCache
		chui = new()
		if (config.env == "dev") //WIRE TODO: Only do this (fallback to local files) if the coder testing has no internet
			Z_LOG_DEBUG("Preload", "Loading local browserassets...")
			recursiveFileLoader("browserassets/")

		Z_LOG_DEBUG("Preload", "Z-level datums...")
		init_zlevel_datums()

		Z_LOG_DEBUG("Preload", "Adding overlays...")
		var/overlayList = childrentypesof(/datum/overlayComposition)
		for(var/over in overlayList)
			var/datum/overlayComposition/E = new over()
			screenOverlayLibrary.Add(over)
			screenOverlayLibrary[over] = E

		url_regex = new("(https?|byond|www)(\\.|:\\/\\/)", "i")
		full_url_regex = new(@"(https?:\/\/)?((www\.)?([-\w]+\.)+[\l]+(\/\S+)*\/?)","ig")

		Z_LOG_DEBUG("Preload", "initLimiter() (whatever the fuck that does)")
		initLimiter()
		Z_LOG_DEBUG("Preload", "Creating named color list...")
		create_named_colors()

		Z_LOG_DEBUG("Preload", "Building material property cache...")
		buildMaterialPropertyCache()	//Order is important.
		Z_LOG_DEBUG("Preload", "Building material cache...")
		buildMaterialCache()			//^^

		// no log because this is functionally instant
		global_signal_holder = new

		Z_LOG_DEBUG("Preload", "Starting controllers")

		Z_LOG_DEBUG("Preload", "  data_core")
		data_core = new /datum/datacore()
		// Must go after data_core
		Z_LOG_DEBUG("Preload", "  get_all_functional_reagent_ids()")
		get_all_functional_reagent_ids()
		Z_LOG_DEBUG("Preload", "  wagesystem")
		wagesystem = new /datum/wage_system()
		Z_LOG_DEBUG("Preload", "  shippingmarket")
		shippingmarket = new /datum/shipping_market()
		Z_LOG_DEBUG("Preload", "  hydro_controls")
		hydro_controls = new /datum/hydroponics_controller()
		Z_LOG_DEBUG("Preload", "  job_controls")
		job_controls = new /datum/job_controller()
		Z_LOG_DEBUG("Preload", "  manuf_controls")
		manuf_controls = new /datum/manufacturing_controller()
		Z_LOG_DEBUG("Preload", "  random_events")
		random_events = new /datum/event_controller()
		Z_LOG_DEBUG("Preload", "  disease_controls")
		disease_controls = new /datum/disease_controller()
		Z_LOG_DEBUG("Preload", "  artifact_controls")
		artifact_controls = new /datum/artifact_controller()
		Z_LOG_DEBUG("Preload", "  mining_controls")
		mining_controls = new /datum/mining_controller()
		Z_LOG_DEBUG("Preload", "  score_tracker")
		score_tracker = new /datum/score_tracker()
		Z_LOG_DEBUG("Preload", "  actions")
		actions = new /datum/action_controller()
		Z_LOG_DEBUG("Preload", "  explosions")
		explosions = new /datum/explosion_controller()
		Z_LOG_DEBUG("Preload", "  ghost_notifier")
		ghost_notifier = new /datum/ghost_notification_controller()
		Z_LOG_DEBUG("Preload", "  respawn_controller")
		respawn_controller = new /datum/respawn_controls()
		Z_LOG_DEBUG("Preload", " cargo_pad_manager")
		cargo_pad_manager = new /datum/cargo_pad_manager()
		Z_LOG_DEBUG("Preload", " camera_coverage_controller")
		camera_coverage_controller = new /datum/controller/camera_coverage()

		Z_LOG_DEBUG("Preload", "hydro_controls set_up")
		hydro_controls.set_up()
		Z_LOG_DEBUG("Preload", "manuf_controls set_up")
		manuf_controls.set_up()

		//REMIND ME TO TRIM THIS CRAP DOWN -Keelin
		Z_LOG_DEBUG("Preload", "Beginning more setup things.")

		//YO, most of this crap below can be removed using initial() on the typepath in interations on the list, e.g.,
		/*
		/proc/baz(arg)
			for var/bar in list_of_foo_subtypes
				var/datum/foo/foobar = bar
				if initial(foobar.variable) == Arg
					do_thing
		*/

		Z_LOG_DEBUG("Preload", "  /datum/faction")
		for(var/A in childrentypesof(/datum/faction))
			var/datum/faction/R = new A()
			factions.Add(R.id)
			factions[R.id] = R

		Z_LOG_DEBUG("Preload", "  /datum/statusEffect")
		for(var/A in childrentypesof(/datum/statusEffect))
			var/datum/statusEffect/R = new A()
			globalStatusPrototypes.Add(R)

		Z_LOG_DEBUG("Preload", "  /datum/jobXpReward")
		for(var/A in childrentypesof(/datum/jobXpReward)) //Caching xp rewards.
			var/datum/jobXpReward/R = new A()
			xpRewards.Add(R.name)
			xpRewards[R.name] = R
			xpRewardButtons.Add(R)
			var/obj/jobxprewardbutton/B = new/obj/jobxprewardbutton()
			B.rewardDatum = R
			B.icon_state = R.icon_state
			B.name = R.name //Update this later for things with multiple requirements.
			if(R.required_levels.len)
				B.name += " LVL [R.required_levels[R.required_levels[1]]]"
			xpRewardButtons[R] = B

		Z_LOG_DEBUG("Preload", "  /datum/material_recipe")
		for(var/A in concrete_typesof(/datum/material_recipe)) //Caching material recipes.
			var/datum/material_recipe/R = new A()
			materialRecipes.Add(R)

		Z_LOG_DEBUG("Preload", "  /datum/achievementReward")
		for(var/A in concrete_typesof(/datum/achievementReward)) //Caching reward datums.
			var/datum/achievementReward/R = new A()
			rewardDB.Add(R.type)
			rewardDB[R.type] = R

		Z_LOG_DEBUG("Preload", "  /datum/trait")
		for(var/A in concrete_typesof(/datum/trait))
			var/datum/trait/T = new A()
			traitList.Add(T.id)
			traitList[T.id] = T

		Z_LOG_DEBUG("Preload", "  /obj/bioEffect")
		var/list/datum/bioEffect/tempBioList = concrete_typesof(/datum/bioEffect, cache=FALSE)
		for(var/effect in tempBioList)
			var/datum/bioEffect/E = new effect(1)
			bioEffectList[E.id] = E        //Caching instances for easy access to rarity and such. BECAUSE THERES NO PROPER CONSTANTS IN BYOND.
			E.dnaBlocks.GenerateBlocks()     //Generate global sequence for this effect.
			if (E.acceptable_in_mutini) // for the drink reagent  :T
				mutini_effects[E.id] = E

		Z_LOG_DEBUG("Preload", "  zoldorf")
		zoldorfsetup()

		Z_LOG_DEBUG("Preload", "  fluid turf misc setup")
		fluid_turf_setup(first_time=TRUE)

		Z_LOG_DEBUG("Preload", "Preload stage complete")
		..()

/world/New()
	current_state = GAME_STATE_WORLD_NEW
	Z_LOG_DEBUG("World/New", "World New()")
	TgsNew(new /datum/tgs_event_handler/impl, TGS_SECURITY_TRUSTED)
	tick_lag = MIN_TICKLAG//0.4//0.25
//	loop_checks = 0

	if(world.load_intra_round_value("heisenbee_tier") >= 15 && prob(50) || prob(3))
		lobby_titlecard = new /datum/titlecard/heisenbee()
	else
		lobby_titlecard = new /datum/titlecard()

	lobby_titlecard.set_pregame_html()

	diary = file("data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")].log")
	diary_name = "data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")].log"
	logDiary("\n----------------------\nStarting up. [time2text(world.timeofday, "hh:mm.ss")]\n----------------------\n")

	//This is used by bans for checking, so we want it very available
	apiHandler = new()

	participationRecorder = new()
	//participationRecorder = new(1) //Enable debug

	//This is also used pretty early
	Z_LOG_DEBUG("World/New", "Setting up powernets...")
	makepowernets()


	Z_LOG_DEBUG("World/New", "Setting up changelogs...")
	changelog = new /datum/changelog()
	admin_changelog = new /datum/admin_changelog()

#ifdef DATALOGGER
	game_stats = new
#endif

	if (config)
		Z_LOG_DEBUG("World/New", "Loading config...")

		oocban_loadbanfile()
		// oocban_updatelegacybans() seems to do nothing. code\admin\oocban.dm -drsingh

	Z_LOG_DEBUG("World/New", "New() complete, running world.init()")

	SPAWN(0)
		init()

#ifdef UNIT_TESTS
	unit_tests.run_tests()
#endif

#define UPDATE_TITLE_STATUS(x) if (game_start_countdown) game_start_countdown.update_status(x)

/world/proc/init()
	set background = 1
	Z_LOG_DEBUG("World/Init", "init() - Lagcheck enabled")
	lagcheck_enabled = 1

	game_start_countdown = new()
	UPDATE_TITLE_STATUS("Initializing world")

	Z_LOG_DEBUG("World/Init", "Loading MOTD...")
	src.load_motd()//GUH
	Z_LOG_DEBUG("World/Init", "Loading admins...")
	load_admins()//UGH
	Z_LOG_DEBUG("World/Init", "Loading whitelist...")
	load_whitelist() //WHY ARE WE UGH-ING
	Z_LOG_DEBUG("World/Init", "Loading playercap bypass keys...")
	load_playercap_bypass()

	Z_LOG_DEBUG("World/Init", "Starting input loop")
	start_input_loop()

	if(!delete_queue)
		delete_queue = new /datum/dynamicQueue(100)

	sun = new /datum/sun()

	Z_LOG_DEBUG("World/Init", "Vox init")
	init_vox()
	if (load_intra_round_value("solarium_complete") == 1)
		derelict_mode = 1
		was_eaten = world.load_intra_round_value("somebody_ate_the_fucking_thing")
		save_intra_round_value("solarium_complete", 0)
		save_intra_round_value("somebody_ate_the_fucking_thing", 0)

	UPDATE_TITLE_STATUS("Loading data")

	if (config)
		if (config.server_name != null && config.server_region != null)
			config.server_name += " [config.server_region]"

		if (config.server_name != null && config.server_suffix && world.port > 0)
			config.server_name += " #[serverKey]"

		precache_create_txt()

	Z_LOG_DEBUG("World/Init", "Loading mode...")
	src.load_mode()

	Z_LOG_DEBUG("World/Init", "Loading rules...")
	src.load_rules()

	mapSwitcher = new()

	Z_LOG_DEBUG("World/Init", "Telemanager setup...")
	tele_man = new()
	tele_man.setup()

	Z_LOG_DEBUG("World/Init", "Mining setup...")
	mining_controls.setup_mining_landmarks()

	createRenderSourceHolder()

	// Set this stupid shit up here because byond's object tree output can't
	// cope with a list initializer that contains "[constant]" keys
	headset_channel_lookup = list(
		"[R_FREQ_RESEARCH]" = "Research",
		"[R_FREQ_MEDICAL]" = "Medical",
		"[R_FREQ_ENGINEERING]" = "Engineering",
		"[R_FREQ_COMMAND]" = "Command",
		"[R_FREQ_SECURITY]" = "Security",
		"[R_FREQ_CIVILIAN]" = "Civilian",
		"[R_FREQ_DEFAULT]" = "General"
		)

	UPDATE_TITLE_STATUS("Starting processes")
	Z_LOG_DEBUG("World/Init", "Process scheduler setup...")
	processScheduler = new /datum/controller/processScheduler
	processSchedulerView = new /datum/processSchedulerView
	var/datum/controller/process/tgui/tgui_process = processScheduler.addNowSkipSetup(/datum/controller/process/tgui)
	var/datum/controller/process/ticker/ticker_process = processScheduler.addNowSkipSetup(/datum/controller/process/ticker)
	tgui_process.setup()
	ticker_process.setup()

	Z_LOG_DEBUG("World/Init", "Building area sims scores...")
	if (global_sims_mode)
		for (var/area/Ar in world)
			Ar.build_sims_score()

	UPDATE_TITLE_STATUS("Updating status")
	Z_LOG_DEBUG("World/Init", "Updating status...")
	src.update_status()

	Z_LOG_DEBUG("World/Init", "Setting up occupations list...")
	SetupOccupationsList()

	Z_LOG_DEBUG("World/Init", "Notifying Discord of new round")
	ircbot.event("serverstart", list("map" = getMapNameFromID(map_setting), "gamemode" = (ticker?.hide_mode) ? "secret" : master_mode))
#ifndef RUNTIME_CHECKING
	world.log << "Map: [getMapNameFromID(map_setting)]"
#endif

	Z_LOG_DEBUG("World/Init", "Notifying hub of new round")
	round_start_data() //Tell the hub site a round is starting
	if (time2text(world.realtime,"DDD") == "Fri")
		NT |= mentors

	Optimize()

	Z_LOG_DEBUG("World/Init", "Loading intraround jars...")
	load_intraround_jars()

	if (derelict_mode)
		Z_LOG_DEBUG("World/Init", "Derelict mode stuff")
		creepify_station()
		voidify_world()
		signal_loss = 80 // heh
		bust_lights()
		master_mode = "disaster" // heh pt. 2

	//SpyStructures and caches live here
	UPDATE_TITLE_STATUS("Updating cache")
	Z_LOG_DEBUG("World/Init", "Building various caches...")
	build_chem_structure()
	build_reagent_cache()
	build_supply_pack_cache()
	build_syndi_buylist_cache()
	build_camera_network()
	build_manufacturer_icons()
	clothingbooth_setup()
	initialize_biomes()

	Z_LOG_DEBUG("World/Init", "Loading fishing spots...")
	global.initialise_fishing_spots()

	//QM Categories by ZeWaka
	build_qm_categories()

	#if SKIP_Z5_SETUP == 0
	UPDATE_TITLE_STATUS("Building mining level")
	Z_LOG_DEBUG("World/Init", "Setting up mining level...")
	makeMiningLevel()
	#endif

	UPDATE_TITLE_STATUS("Lighting up")
	Z_LOG_DEBUG("World/Init", "RobustLight2 init...")
	RL_Start()

	#ifndef NO_RANDOM_ROOMS
	UPDATE_TITLE_STATUS("Building random station rooms")
	Z_LOG_DEBUG("World/Init", "Setting up random rooms...")
	buildRandomRooms()
	makepowernets()
	#endif

	#ifdef SECRETS_ENABLED
	UPDATE_TITLE_STATUS("Loading gallery artwork")
	Z_LOG_DEBUG("World/Init", "Initializing gallery manager...")
	initialize_gallery_manager()
	#endif

	UPDATE_TITLE_STATUS("Generating terrain")
	Z_LOG_DEBUG("World/Init", "Setting perlin noise terrain...")
	for (var/area/map_gen/A in by_type[/area/map_gen])
		A.generate_perlin_noise_terrain()

	UPDATE_TITLE_STATUS("Calculating cameras")
	Z_LOG_DEBUG("World/Init", "Updating camera visibility...")
	camera_coverage_controller.setup()

	UPDATE_TITLE_STATUS("Preloading client data...")
	Z_LOG_DEBUG("World/Init", "Transferring manuf. icons to clients...")
	sendItemIconsToAll()

	UPDATE_TITLE_STATUS("Starting processes")
	Z_LOG_DEBUG("World/Init", "Setting up process scheduler...")
	processScheduler.setup()

	UPDATE_TITLE_STATUS("Initializing worldgen setup")
	Z_LOG_DEBUG("World/Init", "Initializing worldgen...")
	initialize_worldgen()

	UPDATE_TITLE_STATUS("Reticulating splines")
	Z_LOG_DEBUG("World/Init", "Running map-specific initialization...")
	map_settings.init()

	#if !defined(GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW) && !defined(RUNTIME_CHECKING)
	Z_LOG_DEBUG("World/Init", "Initializing region allocator...")
	if(length(global.region_allocator.free_nodes) == 0)
		global.region_allocator.add_z_level()
	#endif

	UPDATE_TITLE_STATUS("Ready")
	current_state = GAME_STATE_PREGAME
	Z_LOG_DEBUG("World/Init", "Now in pre-game state.")

	#ifndef LIVE_SERVER
	for (var/thing in by_cat[TR_CAT_DELETE_ME])
		qdel(thing)
	#endif

#ifdef MOVING_SUB_MAP
	Z_LOG_DEBUG("World/Init", "Making Manta start moving...")
	mantaSetMove(moving=1, doShake=0)
#endif

#ifdef TWITCH_BOT_ALLOWED
	for (var/client/C)
		if (C.ckey == TWITCH_BOT_CKEY)
			C.restart_dreamseeker_js()
#endif

	Z_LOG_DEBUG("World/Init", "Init() complete")
	TgsInitializationComplete()
	//sleep_offline = 1

	// Biodome elevator accident stats
	bioele_load_stats()
	bioele_shifts_since_accident++
	bioele_save_stats()

	sortList(by_type[/area], /proc/cmp_name_asc)

#ifdef PREFAB_CHECKING
	placeAllPrefabs()
#endif
#ifdef RUNTIME_CHECKING
	populate_station()
	check_map_correctness()
	SPAWN(10 SECONDS)
		Reboot_server()
#endif
#if defined(UNIT_TESTS) && !defined(UNIT_TESTS_RUN_TILL_COMPLETION)
	SPAWN(10 SECONDS)
		Reboot_server()
#endif

#undef UPDATE_TITLE_STATUS
	return

//Crispy fullban
/proc/Reboot_server(var/retry)
#if defined(SERVER_SIDE_PROFILING) && (defined(SERVER_SIDE_PROFILING_FULL_ROUND) || defined(SERVER_SIDE_PROFILING_INGAME_ONLY))
#if defined(SERVER_SIDE_PROFILING_INGAME_ONLY) || !defined(SERVER_SIDE_PROFILING_PREGAME)
	// This is a profiler dump of only the in-game part of the round
	// b/c either it was reset (_INGAME_ONLY) or was never started (_PREGAME)
#warn Profiler output at end of game (ingame)
	var/profile_out = file("data/profile/[time2text(world.realtime, "YYYY-MM-DD hh-mm-ss")]-ingame.log")
#else
	// Full round profile
#warn Profiler enabled at end of game (full)
	var/profile_out = file("data/profile/[time2text(world.realtime, "YYYY-MM-DD hh-mm-ss")]-full.log")
#endif
	profile_out << world.Profile(PROFILE_START | PROFILE_AVERAGE, "sendmaps", "json")
	world.log << "Dumped profiler data."
	// not gonna need this again
	world.Profile(PROFILE_STOP | PROFILE_AVERAGE, "sendmaps", "json")
#endif

	lagcheck_enabled = 0
	processScheduler.stop()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_REBOOT)
	save_intraround_jars()
	global.save_noticeboards()
	for_by_tcl(canvas, /obj/item/canvas/big_persistent)
		canvas.save()
	global.phrase_log.save()
	for_by_tcl(P, /datum/player)
		P.on_round_end()
	save_tetris_highscores()
	if (current_state < GAME_STATE_FINISHED)
		current_state = GAME_STATE_FINISHED
#if defined(RUNTIME_CHECKING) || defined(UNIT_TESTS)
	for (var/client/C in clients)
		ehjax.send(C, "browseroutput", "hardrestart")

	logTheThing(LOG_DIARY, null, "Shutting down after testing for runtimes.", "admin")
	if (isnull(runtimeDetails))
		text2file("Runtime checking failed due to missing runtimeDetails global list", "errors.log")
	else if (length(runtimeDetails) > 0)
		text2file("[length(runtimeDetails)] runtimes generated:", "errors.log")
		for (var/idx in runtimeDetails)
			var/list/details = runtimeDetails[idx]
			var/timestamp = details["seen"]
			var/file = details["file"]
			var/line = details["line"]
			var/name = details["name"]
			text2file("\[[timestamp]\] [file],[line]: [name]", "errors.log")
#ifndef PREFAB_CHECKING
	var/apc_error_str = debug_map_apc_count("\n", zlim=Z_LEVEL_STATION)
	if (!is_blank_string(apc_error_str))
		text2file(apc_error_str, "errors.log")
#endif
	shutdown()
#endif

	SPAWN(world.tick_lag)
		for (var/client/C)
			if (C.mob)
				if (prob(40))
					C.mob << sound(pick('sound/misc/NewRound2.ogg', 'sound/misc/NewRound3.ogg', 'sound/misc/NewRound4.ogg', 'sound/misc/TimeForANewRound.ogg'))
				else
					C.mob << sound('sound/misc/NewRound.ogg')

#ifdef DATALOGGER
	SPAWN(world.tick_lag*2)
		var/playercount = 0
		var/admincount = 0
		for(var/client/C in clients)
			if(C.mob)
				if(C.holder)
					admincount++
				playercount++
		game_stats.SetValue("players", playercount)
		game_stats.SetValue("admins", admincount)
		//game_stats.WriteToFile("data/game_stats.txt")
#endif

	sleep(5 SECONDS) // wait for sound to play
	if(config.update_check_enabled)
		world.installUpdate()

	//if the server has a hard-reboot file, we trigger a shutdown (server supervisor process will restart the server after)
	//this is to avoid memory leaks from leaving the server running for long periods
	if (fexists("data/hard-reboot"))
		//Tell client browserOutput that we're hard rebooting, so it can handle manual auto-reconnection
		for (var/client/C in clients)
			ehjax.send(C, "browseroutput", "hardrestart")

		logTheThing(LOG_DIARY, null, "Hard reboot file detected, triggering shutdown instead of reboot.", "debug")
		message_admins("Hard reboot file detected, triggering shutdown instead of reboot. (The server will auto-restart don't worry)")

		fdel("data/hard-reboot")
		shutdown()
	else
		//Tell client browserOutput that a restart is happening RIGHT NOW
		for (var/client/C in clients)
			ehjax.send(C, "browseroutput", "roundrestart")

		world.Reboot()

/world/Reboot()
	TgsReboot()
	shutdown_logging()
	return ..()

/world/proc/update_status()
	Z_LOG_DEBUG("World/Status", "Updating status")

	var/list/statsus = list()

	if (config?.server_name)
		statsus += "<b><a href=\"https://goonhub.com\">[config.server_name]</a></b> &#8212; "
	else
		statsus += "<b>SERVER NAME HERE</b> &#8212; "

	statsus += "The classic SS13 experience. &#8212; (<a href=\"http://bit.ly/gndscd\">Discord</a>)<br>"

	if(ticker?.round_elapsed_ticks > 0 && current_state == GAME_STATE_PLAYING)
		statsus += "Time: <b>[round(ticker.round_elapsed_ticks / 36000)]:[add_zero(num2text(ticker.round_elapsed_ticks / 600 % 60), 2)]</b><br>"
	else if (current_state == GAME_STATE_FINISHED)
		statsus += "Time: <b>RESTARTING</b><br>"
	else if(!ticker)
		statsus += "Time: <b>STARTING</b><br>"

	if (map_settings)
		var/map_name = istext(map_settings.display_name) ? "[map_settings.display_name]" : "[map_settings.name]"
		//var/map_link_str = map_settings.goonhub_map ? "<a href=\"[map_settings.goonhub_map]\">[map_name]</a>" : "[map_name]"
		statsus += "Map: <b>[map_name]</b><br>"

	var/list/features = list()

	if(ticker && master_mode)
		if (ticker.hide_mode)
			features += "Mode: <b>secret</b>"
		else
			features += "Mode: <b>[master_mode]</b>"

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

/world/proc/installUpdate()
	// Simple check to see if a new dmb exists in the update folder
	logTheThing(LOG_DIARY, null, "Checking for updated [config.dmb_filename].dmb...", "admin")
	if(fexists("update/[config.dmb_filename].dmb"))
		logTheThing(LOG_DIARY, null, "Updated [config.dmb_filename].dmb found. Updating...", "admin")
		for(var/f in flist("update/"))
			if (IS_DIR_FNAME("update/[f]"))
				logTheThing(LOG_DIARY, null, "\tClearing [f]...", "admin")
				fdel(f)

			logTheThing(LOG_DIARY, null, "\tMoving [f]...", "admin")
			fcopy("update/[f]", "[f]")
			fdel("update/[f]")

		// Delete .dyn.rsc so that stupid shit doesn't happen
		fdel("[config.dmb_filename].dyn.rsc")

		logTheThing(LOG_DIARY, null, "Update complete.", "admin")
	else
		logTheThing(LOG_DIARY, null, "No update found. Skipping update process.", "admin")

/// world Topic. This is where external shit comes into byond and does shit.
/world/Topic(T, addr, master, key)
	TGS_TOPIC	// logging for these is done in TGS

	var/cleanT = replacetext(T, regex(@"auth=[a-zA-Z0-9]*(;|&|$)"), "auth=***$1")
	logDiary("TOPIC: \"[cleanT]\", from:[addr], master:[master], key:[key]")
	Z_LOG_DEBUG("World", "TOPIC: \"[cleanT]\", from:[addr], master:[master], key:[key]")

	if (T == "ping")
		var/x = 1
		for (var/client/C)
			if (C.stealth && !C.fakekey) // stealthed admins don't count
				continue
			x++
		return x
	else if(T == "players")
		var/n = 0
		for(var/client/C)
			if (C.stealth && !C.fakekey) // stealthed admins don't count
				continue
			n++
		return n

	else if (T == "status")
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = (ticker?.hide_mode) ? "secret" : master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = enter_allowed
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["players"] = list()
		s["station_name"] = station_name
		var/shuttle
		if (emergency_shuttle)
			if (emergency_shuttle.location == SHUTTLE_LOC_STATION) shuttle = 0 - emergency_shuttle.timeleft()
			else shuttle = emergency_shuttle.timeleft()
		else shuttle = "welp"
		s["shuttle_time"] = shuttle
		var/elapsed
		if (current_state < GAME_STATE_FINISHED)
			if (current_state <= GAME_STATE_PREGAME) elapsed = "pre"
			else if (current_state > GAME_STATE_PREGAME) elapsed = round(ticker.round_elapsed_ticks / 10)
		else if (current_state == GAME_STATE_FINISHED) elapsed = "post"
		else elapsed = "welp"
		s["elapsed"] = elapsed
		var/n = 0
		for(var/client/C in clients)
			if (C.stealth && !C.fakekey) // stealthed admins don't count
				continue
			s["player[n]"] = "[(C.stealth || C.alt_key) ? C.fakekey : C.key]"
			n++
		s["players"] = n
		s["map_name"] = getMapNameFromID(map_setting)
		return list2params(s)

	else // Discord bot communication (or callbacks)

		var/game_servers_response = game_servers?.topic(T, addr)
		if(!isnull(game_servers_response))
			return game_servers_response

#ifdef TWITCH_BOT_ALLOWED
		//boutput(world,"addres : [addr]     twitchbotaddr : [TWITCH_BOT_ADDR]")
		if (addr == TWITCH_BOT_ADDR)
			if (!twitch_mob || !twitch_mob.client)
				for (var/client/C in clients)
					if (C.ckey == TWITCH_BOT_CKEY)
						twitch_mob = C.mob
				if (!istype(twitch_mob))
					twitch_mob = 0
			//boutput(world,"twitch mob found? : [twitch_mob]")

			if (twitch_mob)
				var/list/plist = params2list(T)
				//boutput(world,"plist type? : [plist["type"]]")
				//boutput(world,"plist command? : [plist["command"]]")
				//boutput(world,"plist arg? : [plist["arg"]]")
				if (plist["type"] == "shittybill")
					switch(plist["command"])

						if("restart")
							if (twitch_mob.client)
								twitch_mob.client.restart_dreamseeker_js()
							return 1

						if("say")
							if (istype(twitch_mob,/mob/living/carbon/human/biker))
								var/mob/living/carbon/human/biker/H = twitch_mob
								H.speak()
							return 1

						if("move")
							if (!plist["arg"]) return 0

							var/dir = plist["arg"]
							dir = trim(copytext(sanitize(dir), 1, MAX_MESSAGE_LEN))
							dir = text2dir(dir)

							switch(dir)
								if(NORTH)
									twitch_mob.keys_changed(KEY_FORWARD, KEY_FORWARD)
								if(SOUTH)
									twitch_mob.keys_changed(KEY_BACKWARD, KEY_BACKWARD)
								if(EAST)
									twitch_mob.keys_changed(KEY_RIGHT, KEY_RIGHT)
								if(WEST)
									twitch_mob.keys_changed(KEY_LEFT, KEY_LEFT)
								if(NORTHEAST)
									twitch_mob.keys_changed(KEY_FORWARD|KEY_RIGHT, KEY_FORWARD|KEY_RIGHT)
								if(SOUTHEAST)
									twitch_mob.keys_changed(KEY_BACKWARD|KEY_RIGHT, KEY_BACKWARD|KEY_RIGHT)
								if(NORTHWEST)
									twitch_mob.keys_changed(KEY_FORWARD|KEY_LEFT, KEY_FORWARD|KEY_LEFT)
								if(SOUTHWEST)
									twitch_mob.keys_changed(KEY_BACKWARD|KEY_LEFT, KEY_BACKWARD|KEY_LEFT)

							SPAWN(1 DECI SECOND)
								twitch_mob.keys_changed(0,0xFFFF)

							return 1

						if("intent")
							if (!plist["arg"]) return 0

							var/msg = plist["arg"]
							msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))

							if (msg == INTENT_HELP || msg == INTENT_DISARM || msg == INTENT_GRAB || msg == INTENT_HARM)
								twitch_mob.set_a_intent(lowertext(msg))
								if (ishuman(twitch_mob))
									var/mob/living/carbon/human/H = twitch_mob
									H.hud.update_intent()
							return 1

						if("attack")
							if (!plist["arg"]) return 0
							if (twitch_mob.next_click > world.time) return 1

							var/dir = plist["arg"]
							dir = trim(copytext(sanitize(dir), 1, MAX_MESSAGE_LEN))
							dir = text2dir(dir)

							if (dir == 0)
								if (ishuman(twitch_mob))
									var/mob/living/carbon/human/H = twitch_mob
									var/trg = plist["arg"]
									trg = trim(copytext(sanitize(trg), 1, MAX_MESSAGE_LEN))
									H.auto_interact(trg)

							var/turf/target = get_ranged_target_turf(twitch_mob, dir, 7)
							//twitch_mob.click(get_edge_target_turf(twitch_mob, dir), location = "map")
							//twitch_mob.client.Click(target,target)

							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob

								if (twitch_mob.a_intent != INTENT_HARM && twitch_mob.a_intent != INTENT_DISARM)
									twitch_mob.set_a_intent(INTENT_HARM)
									H.hud.update_intent()

								var/obj/item/equipped = H.equipped()
								var/list/p = list()
								p["left"] = 1
								if (equipped)
									H.weapon_attack(target, equipped, reach = 0, params = p)
								else
									H.hand_range_attack(target, params = p)
								twitch_mob.next_click = world.time + twitch_mob.combat_click_delay

							return 1

						if("throw")
							if (!plist["arg"]) return 0

							var/dir = plist["arg"]
							dir = trim(copytext(sanitize(dir), 1, MAX_MESSAGE_LEN))
							dir = text2dir(dir)

							if (ishuman(twitch_mob))
								if (istype(twitch_mob.loc, /turf/space) || twitch_mob.no_gravity) //they're in space, move em one space in the opposite direction
									twitch_mob.inertia_dir = turn(dir, 180)
									step(twitch_mob, twitch_mob.inertia_dir)

								twitch_mob.drop_item_throw_dir(dir)
							return 1

						if("switchhand")
							twitch_mob.hotkey("swaphand")
							return 1

						if("equip")
							twitch_mob.hotkey("equip")
							return 1

						if("drop")
							twitch_mob.hotkey("drop")
							return 1

						if("use")
							twitch_mob.hotkey("attackself")
							return 1

						if("target")
							if (!plist["arg"]) return 0

							var/msg = plist["arg"]
							msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))

							twitch_mob.hotkey(msg)
							return 1

						if("walk")
							if (twitch_mob.m_intent != "walk")
								twitch_mob.hotkey("walk")
							return 1

						if("run")
							if (twitch_mob.m_intent != "run")
								twitch_mob.hotkey("walk")
							return 1

						if("emote")
							if (!plist["arg"]) return 0

							var/msg = plist["arg"]
							msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))

							if (msg == "faint" || msg == "collapse") return 1 //nope!

							twitch_mob.emote(msg,voluntary = 0)
							return 1

						if("pickup")
							if (!plist["arg"]) return 0
							if (isdead(twitch_mob)) return 1

							var/msg = plist["arg"]
							msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))

							var/list/hudlist = list()
							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob
								for (var/obj/item/I in H.contents)
									if (istype(I,/obj/item/organ) || istype(I,/obj/item/skull) || istype(I,/obj/item/parts) || istype(I,/atom/movable/screen/hud)) continue //FUCK
									hudlist += I
									if (istype(I,/obj/item/storage))
										hudlist += I.contents

							var/list/close_match = list()
							for (var/obj/item/I in view(1,twitch_mob) + hudlist)
								if (!isturf(I.loc)) continue
								if (TWITCH_BOT_INTERACT_BLOCK(I)) continue
								if (istype(I,/obj/item/organ) || istype(I,/obj/item/skull) || istype(I,/obj/item/parts) || istype(I,/atom/movable/screen/hud)) continue //FUCK
								if (I.name == msg)
									close_match.len = 0
									close_match += I
									break
								else if (findtext(I.name,msg))
									close_match += I


							twitch_mob.put_in_hand(pick(close_match), twitch_mob.hand)
							return 1

						if("interact") //mostly same as above
							if (!plist["arg"]) return 0

							var/msg = plist["arg"]
							msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob
								H.auto_interact(msg)
							return 1

						if("pull")
							if (!plist["arg"])
								twitch_mob.set_pulling(null)
								return 0
							if (isdead(twitch_mob)) return 1

							var/msg = plist["arg"]
							msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))

							var/list/close_match = list()
							for (var/atom/movable/I in view(1,twitch_mob))
								if (I.anchored || I.mouse_opacity == 0) continue
								if (I.name == msg)
									close_match.len = 0
									close_match += I
									break
								else if (findtext(I.name,msg))
									close_match += I

							twitch_mob.set_pulling(pick(close_match))
							return 1

						if("resist")
							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob
								H.resist()
							return 1

						if("rest")
							if(ON_COOLDOWN(twitch_mob, "toggle_rest", REST_TOGGLE_COOLDOWN)) return
							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob
								H.setStatus("resting", INFINITE_STATUS)
								H.force_laydown_standup()
								H.hud.update_resting()
							return 1

						if("stand")
							if(ON_COOLDOWN(twitch_mob, "toggle_rest", REST_TOGGLE_COOLDOWN)) return
							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob
								H.delStatus("resting")
								H.force_laydown_standup()
								H.hud.update_resting()
							return 1

						if("eject")
							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob

								if (istype(H.loc,/obj/machinery/vehicle))
									var/obj/machinery/vehicle/V = H.loc
									V.eject(twitch_mob)
								else if (istype(H.loc,/obj/vehicle))
									var/obj/vehicle/V = H.loc
									V.eject_rider(0, 1)

							return 1

						if("ooc") //this one is twitchadmins only
							if (!plist["arg"]) return 0

							var/msg = plist["arg"]
							msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob
								H.ooc(msg)
							return 1
#endif

		if (findtext(addr, ":")) // remove port if present
			addr = splittext(addr, ":")[1]
		if (addr != config.ircbot_ip && addr != config.goonhub_api_ip && addr != config.goonhub2_hostname)
			return 0 //ip filtering

		var/list/plist = params2list(T)

		if (T == "admins")
			var/list/s = list()
			var/n = 0
			for(var/client/C)
				if(C.holder)
					s["admin[n]"] = (C.stealth ? "~" : "") + C.key
					n++
			s["admins"] = n
			return list2params(s)
		else if (T == "mentors")
			var/list/s = list()
			var/n = 0
			for(var/client/C)
				if(!C.holder && C.is_mentor())
					s["mentor[n]"] = C.key
					n++
			s["mentors"] = n
			return list2params(s)

		switch(plist["type"])
			if("irc")
				if (!plist["nick"] || !plist["msg"]) return 0

				var/nick = plist["nick"]
				var/msg = plist["msg"]
				msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
				msg = discord_emojify(msg)

				logTheThing(LOG_OOC, null, "Discord OOC: [nick]: [msg]")

				if (nick == "buttbot")
					for (var/obj/machinery/bot/buttbot/B in machine_registry[MACHINES_BOTS])
						if(B.on)
							B.speak(msg)
					return 1

				//This is important.
				else if (nick == "HeadSurgeon")
					for (var/obj/machinery/bot/medbot/head_surgeon/HS in machine_registry[MACHINES_BOTS])
						if (HS.on)
							HS.speak(msg)
					for (var/obj/item/clothing/suit/cardboard_box/head_surgeon/HS in world)
						LAGCHECK(LAG_LOW)
						HS.speak(msg)
					return 1

				return 0

			if("ooc")
				if (!plist["nick"] || !plist["msg"]) return 0

				var/nick = plist["nick"]
				var/msg = plist["msg"]

				msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
				msg = discord_emojify(msg)
				logTheThing(LOG_OOC, nick, "OOC: [msg]")
				logTheThing(LOG_DIARY, nick, ": [msg]", "ooc")
				var/rendered = "<span class=\"adminooc\"><span class=\"prefix\">OOC:</span> <span class=\"name\">[nick]:</span> <span class=\"message\">[msg]</span></span>"

				for (var/client/C in clients)
					if (C.preferences && !C.preferences.listen_ooc)
						continue
					boutput(C, rendered)

				var/ircmsg[] = new()
				ircmsg["msg"] = msg
				return ircbot.response(ircmsg)

			if("asay")
				if (!plist["nick"] || !plist["msg"]) return 0

				var/nick = plist["nick"]
				var/msg = plist["msg"]

				if(copytext(msg, 1, 2) == SPACEBEE_EXTENSION_ASAY_PREFIX)
					spacebee_extension_system?.process_asay(msg, nick)
					var/ircmsg[] = new()
					ircmsg["key"] = nick
					ircmsg["msg"] = msg
					return ircbot.response(ircmsg)

				msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
				msg = linkify(msg)
				msg = discord_emojify(msg)

				logTheThing(LOG_ADMIN, null, "Discord ASAY: [nick]: [msg]")
				logTheThing(LOG_DIARY, null, "Discord ASAY: [nick]: [msg]", "admin")
				var/rendered = "<span class=\"admin\"><span class=\"prefix\"></span> <span class=\"name\">[nick]:</span> <span class=\"message adminMsgWrap\">[msg]</span></span>"

				message_admins(rendered, 1, 1)

				var/ircmsg[] = new()
				ircmsg["key"] = nick
				ircmsg["msg"] = msg
				return ircbot.response(ircmsg)

			if("fpm")
				if (!plist["nick"] || !plist["msg"]) return 0

				var/server_name = plist["server_name"]
				if (!server_name)
					server_name = "GOON-???"
				var/nick = plist["nick"]
				var/msg = plist["msg"]
				msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))

				logTheThing(LOG_ADMIN, null, "[server_name] PM: [nick]: [msg]")
				logTheThing(LOG_DIARY, null, "[server_name] PM: [nick]: [msg]", "admin")
				var/rendered = "<span class=\"admin\"><span class=\"prefix\">[server_name] PM:</span> <span class=\"name\">[nick]:</span> <span class=\"message adminMsgWrap\">[msg]</span></span>"

				for (var/client/C)
					if (C.holder)
						boutput(C.mob, rendered)

				var/ircmsg[] = new()
				ircmsg["key"] = nick
				ircmsg["msg"] = msg
				return ircbot.response(ircmsg)

			if("pm")
				// @TODO This is the other gross adminhelp stuff.
				// It should be combined with the crap in
				// code/modules/admin/adminhelp.dm
				// or something. ugh
				if (!plist["nick"] || !plist["msg"] || !plist["target"]) return 0

				var/nick = plist["nick"]
				var/msg = plist["msg"]
				var/who = lowertext(plist["target"])
				var/game_msg = linkify(msg)
				game_msg = discord_emojify(game_msg)

				var/mob/M = ckey_to_mob(who, exact=0)
				if (M?.client)
					boutput(M, {"
						<div style='border: 2px solid red; font-size: 110%;'>
							<div style="color: black; background: #f88; font-weight: bold; border-bottom: 1px solid red; text-align: center; padding: 0.2em 0.5em;">
								Admin PM from <a href=\"byond://?action=priv_msg_irc&nick=[ckey(nick)]\">[nick]</a>
							</div>
							<div style="padding: 0.2em 0.5em;">
								[game_msg]
							</div>
							<div style="font-size: 90%; background: #fcc; font-weight: bold; border-top: 1px solid red; text-align: center; padding: 0.2em 0.5em;">
								<a href=\"byond://?action=priv_msg_irc&nick=[ckey(nick)]" style='color: #833; font-weight: bold;'>&lt; Click to Reply &gt;</a></div>
							</div>
						</div>
						"}, forceScroll=TRUE)
					M << sound('sound/misc/adminhelp.ogg', volume=100, wait=0)
					logTheThing(LOG_AHELP, null, "Discord: [nick] PM'd [constructTarget(M,"admin_help")]: [msg]")
					logTheThing(LOG_DIARY, null, "Discord: [nick] PM'd [constructTarget(M,"diary")]: [msg]", "ahelp")
					M.client.make_sure_chat_is_open()
					for (var/client/C)
						if (C.holder && C.key != M.key)
							if (C.player_mode && !C.player_mode_ahelp)
								continue
							else
								boutput(C, "<span class='ahelp'><b>PM: <a href=\"byond://?action=priv_msg_irc&nick=[ckey(nick)]\">[nick]</a> (Discord) <i class='icon-arrow-right'></i> [key_name(M)]</b>: [game_msg]</span>")

				if (M)
					var/ircmsg[] = new()
					ircmsg["key"] = nick
					ircmsg["key2"] = (M.client != null && M.client.key != null) ? M.client.key : "*no client*"
					ircmsg["name2"] = (M.real_name != null) ? stripTextMacros(M.real_name) : ""
					ircmsg["msg"] = html_decode(msg)
					return ircbot.response(ircmsg)
				else
					return 0

			if("mentorpm")
				if (!plist["nick"] || !plist["msg"] || !plist["target"]) return 0

				var/nick = plist["nick"]
				var/msg = html_encode(plist["msg"])
				var/who = lowertext(plist["target"])
				var/mob/M = ckey_to_mob(who, exact=0)
				var/game_msg = linkify(msg)
				game_msg = discord_emojify(game_msg)

				if (M?.client)
					boutput(M, "<span class='mhelp'><b>MENTOR PM: FROM <a href=\"byond://?action=mentor_msg_irc&nick=[ckey(nick)]\">[nick]</a> (Discord)</b>: <span class='message'>[game_msg]</span></span>")
					M.playsound_local(M, 'sound/misc/mentorhelp.ogg', 100, flags = SOUND_IGNORE_SPACE, channel = VOLUME_CHANNEL_MENTORPM)
					logTheThing(LOG_ADMIN, null, "Discord: [nick] Mentor PM'd [constructTarget(M,"admin")]: [msg]")
					logTheThing(LOG_DIARY, null, "Discord: [nick] Mentor PM'd [constructTarget(M,"diary")]: [msg]", "admin")
					for (var/client/C)
						if (C.can_see_mentor_pms() && C.key != M.key)
							if(C.holder)
								if (C.player_mode && !C.player_mode_mhelp)
									continue
								else
									boutput(C, "<span class='mhelp'><b>MENTOR PM: [nick] (Discord) <i class='icon-arrow-right'></i> [key_name(M,0,0,1)][(C.mob.real_name ? "/"+M.real_name : "")] <A HREF='?src=\ref[C.holder];action=adminplayeropts;targetckey=[M.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: <span class='message'>[game_msg]</span></span>")
							else
								boutput(C, "<span class='mhelp'><b>MENTOR PM: [nick] (Discord) <i class='icon-arrow-right'></i> [key_name(M,0,0,1)]</b>: <span class='message'>[game_msg]</span></span>")

				if (M)
					var/ircmsg[] = new()
					ircmsg["key"] = nick
					ircmsg["key2"] = (M.client != null && M.client.key != null) ? M.client.key : "*no client*"
					ircmsg["name2"] = (M.real_name != null) ? stripTextMacros(M.real_name) : ""
					ircmsg["msg"] = html_decode(msg)
					return ircbot.response(ircmsg)
				else
					return 0

			if("whois")
				if (!plist["target"]) return 0

				var/list/whom = splittext(plist["target"], ",")
				if (length(whom))
					var/list/parsedWhois = list()
					var/count = 0
					var/list/whois_result
					for (var/who in whom)
						whois_result = whois(who)
						if (whois_result)
							for (var/mob/M in whois_result)
								count++
								var/role = getRole(M, 1)
								if (M.name) parsedWhois["name[count]"] = M.name
								if (M.key) parsedWhois["ckey[count]"] = M.key
								if (isdead(M)) parsedWhois["dead[count]"] = 1
								if (role) parsedWhois["role[count]"] = role
								if (checktraitor(M)) parsedWhois["t[count]"] = 1
					parsedWhois["count"] = count
					return ircbot.response(parsedWhois)
				else
					return 0

			if ("antags")
				var/list/badGuys = list()
				var/count = 0

				for (var/client/C in clients)
					if (C.mob)
						var/mob/M = C.mob
						if (M.mind && M.mind.special_role != null)
							count++
							var/role = getRole(M, 1)
							if (M.name) badGuys["name[count]"] = M.name
							if (M.key) badGuys["ckey[count]"] = M.key
							if (isdead(M)) badGuys["dead[count]"] = 1
							if (role) badGuys["role[count]"] = role
							if (checktraitor(M)) badGuys["t[count]"] = 1

				badGuys["count"] = count
				return ircbot.response(badGuys)

/*
			<ErikHanson> topic call, type=reboot reboots a server.. without a password, or any form of authentication.
			well there, i've fixed it. -drsingh

			if("reboot")
				var/ircmsg[] = new()
				ircmsg["msg"] = "Attempting to restart now"

				Reboot_server()
				return ircbot.response(ircmsg)
*/
			if ("heal")
				if (!plist["nick"] || !plist["target"]) return 0

				var/nick = plist["nick"]
				var/who = lowertext(plist["target"])
				var/list/found = list()
				for (var/mob/M in mobs)
					if (M.ckey && (findtext(M.real_name, who) || findtext(M.ckey, who)))
						M.full_heal()
						logTheThing(LOG_ADMIN, nick, "healed / revived [constructTarget(M,"admin")]")
						logTheThing(LOG_DIARY, nick, "healed / revived [constructTarget(M,"diary")]", "admin")
						message_admins("<span class='alert'>Admin [nick] healed / revived [key_name(M)] from Discord!</span>")

						var/ircmsg[] = new()
						ircmsg["type"] = "heal"
						ircmsg["who"] = who
						ircmsg["msg"] = "Admin [nick] healed / revived [M.ckey]"
						found.Add(ircmsg)

				if (length(found))
					return ircbot.response(found)
				else
					return 0

			if ("hubCallback")
				//Wire note: Temp debug logging as this should always get data and proc
				if (!plist["data"])
					logTheThing(LOG_DEBUG, null, "<b>API Error (Temp):</b> Didnt get data.")
					return 0
				if (!plist["proc"])
					logTheThing(LOG_DEBUG, null, "<b>API Error (Temp):</b> Didnt get proc.")
					return 0

				if (addr != config.goonhub_api_ip) return 0 //ip filtering
				var/auth = plist["auth"]
				if (auth != md5(config.goonhub_api_token)) return 0 //really bad md5 token security
				var/theDatum = plist["datum"] ? plist["datum"] : null
				var/theProc = "/proc/[plist["proc"]]"

				var/list/ldata
				try
					ldata = json_decode(plist["data"])
				catch
					logTheThing(LOG_DEBUG, null, "<b>API Error:</b> Invalid JSON detected: [plist["data"]]")
					return 0

				ldata["data_hub_callback"] = 1

				//calls the second stage of whatever proc specified
				var/rVal
				if (theDatum)
					rVal = call(theDatum, theProc)(ldata)
				else
					rVal = call(theProc)(ldata)

				if (rVal)
					logTheThing(LOG_DEBUG, null, "<b>Callback Error</b> - Hub callback failed in [theDatum ? "<b>[theDatum]</b> " : ""]<b>[theProc]</b> with message: <b>[rVal]</b>")
					logTheThing(LOG_DIARY, null, "<b>Callback Error</b> - Hub callback failed in [theDatum ? "[theDatum] " : ""][theProc] with message: [rVal]", "debug")
					return 0
				else
					return 1

			if ("roundEnd")
				if (!plist["server"] || !plist["address"]) return 0

				var/server = plist["server"]
				var/address = plist["address"]
				var/msg = "<br><div style='text-align: center; font-weight: bold;' class='deadsay'>---------------------<br>"
				msg += "A round just ended on [server]<br>"
				msg += "<a href='[address]'>Click here to join it</a><br>"
				msg += "---------------------</div><br>"
				for (var/client/C)
					if (isdead(C.mob))
						boutput(C.mob, msg)

				return 1

			if ("mysteryPrint")
				if (!plist["print_title"] || !plist["print_file"]) return 0

				var/msgTitle = plist["print_title"]
				var/msgFile = "strings/mysteryprint/"+plist["print_file"]
				if (!fexists(msgFile)) return 0
				var/msgText = file2text(msgFile)

				//Prints to every networked printer in the world
				for (var/obj/machinery/networked/printer/P as anything in machine_registry[MACHINES_PRINTERS])
					P.print_buffer += "[msgTitle]&title;[msgText]"
					P.print()

				return 1

			//Tells shitbee what the current AI laws are (if there are any custom ones)
			if ("ailaws")
				if (current_state > GAME_STATE_PREGAME)
					var/ircmsg[] = new()
					ircmsg["laws"] = ticker.ai_law_rack_manager.format_for_logs(glue = "\n", round_end = TRUE, include_link = FALSE)
					return ircbot.response(ircmsg)
				else
					return 0

			if ("health")
				var/ircmsg[] = new()
				ircmsg["cpu"] = world.cpu
				ircmsg["queue_len"] = delete_queue ? delete_queue.count() : 0
				var/curtime = world.timeofday
				sleep(1 SECOND)
				ircmsg["time"] = (world.timeofday - curtime) / 10
				ircmsg["ticklag"] = world.tick_lag
				ircmsg["runtimes"] = global.runtime_count
				if(world.system_type == "UNIX")
					try
						var/meminfo_file = "data/meminfo.txt"
						fcopy("/proc/meminfo", "meminfo_file")
						var/list/memory_info = splittext(file2text(meminfo_file), "\n")
						if(length(memory_info) >= 3)
							memory_info.len = 3
							ircmsg["meminfo"] = jointext(memory_info, "\n")
						fdel(meminfo_file)
					catch(var/exception/e)
						stack_trace("[e.name]\n[e.desc]")
				return ircbot.response(ircmsg)

			if ("rev")
				var/ircmsg[] = new()
				ircmsg["msg"] = "[vcs_revision] by [vcs_author]"
				return ircbot.response(ircmsg)

			if ("version")
				var/ircmsg[] = new()
				ircmsg["major"] = world.byond_version
				ircmsg["minor"] = world.byond_build
				ircmsg["goonhub_api"] = config.goonhub_api_version ? config.goonhub_api_version : 0
				return ircbot.response(ircmsg)

			if ("youtube")
				if (!plist["data"]) return 0

				play_music_remote(json_decode(plist["data"]))
				// trigger cooldown so radio station doesn't interrupt our cool music
				EXTEND_COOLDOWN(global, "music", 2 MINUTES) // TODO use plist duration data if available
				return 1

			if ("delay")
				var/ircmsg[] = new()

				if (game_end_delayed == 0)
					game_end_delayed = 1
					game_end_delayer = plist["nick"]
					logTheThing(LOG_ADMIN, null, "[game_end_delayer] delayed the server restart from Discord.")
					logTheThing(LOG_DIARY, null, "[game_end_delayer] delayed the server restart from Discord.", "admin")
					message_admins("<span class='internal'>[game_end_delayer] delayed the server restart from Discord.</span>")
					ircmsg["msg"] = "Server restart delayed. Use undelay to cancel this."
				else
					ircmsg["msg"] = "The server restart is already delayed, use undelay to cancel this."

				return ircbot.response(ircmsg)

			if ("undelay")
				var/ircmsg[] = new()

				if (game_end_delayed == 0)
					ircmsg["msg"] = "The server restart isn't delayed."
					return ircbot.response(ircmsg)

				else if (game_end_delayed == 1)
					game_end_delayed = 0
					game_end_delayer = plist["nick"]
					logTheThing(LOG_ADMIN, null, "[game_end_delayer] removed the restart delay from Discord.")
					logTheThing(LOG_DIARY, null, "[game_end_delayer] removed the restart delay from Discord.", "admin")
					message_admins("<span class='internal'>[game_end_delayer] removed the restart delay from Discord.</span>")
					game_end_delayer = null
					ircmsg["msg"] = "Removed the restart delay."
					return ircbot.response(ircmsg)

				else if (game_end_delayed == 2)
					game_end_delayer = plist["nick"]
					logTheThing(LOG_ADMIN, null, "[game_end_delayer] removed the restart delay from Discord and triggered an immediate restart.")
					logTheThing(LOG_DIARY, null, "[game_end_delayer] removed the restart delay from Discord and triggered an immediate restart.", "admin")
					message_admins("<span class='internal>[game_end_delayer] removed the restart delay from Discord and triggered an immediate restart.</span>")
					ircmsg["msg"] = "Removed the restart delay."

					SPAWN(1 DECI SECOND)
						ircbot.event("roundend")
						Reboot_server()

					return ircbot.response(ircmsg)

			if ("triggerMapSwitch")
				if (!plist["nick"] || !plist["map"])
					return 0

				if (!config.allow_map_switching)
					return ircbot.response(list("msg" = "Map switching is disabled on this server."))

				var/nick = plist["nick"]
				var/map = uppertext(plist["map"])
				var/mapName = getMapNameFromID(map)
				var/ircmsg[] = new()
				try
					mapSwitcher.setNextMap(nick, mapID = map)
					ircmsg["msg"] = "Map switched to [mapName]"
				catch (var/exception/e)
					ircmsg["msg"] = e.name

				logTheThing(LOG_ADMIN, nick, "set the next round's map to [mapName] from Discord")
				logTheThing(LOG_DIARY, nick, "set the next round's map to [mapName] from Discord", "admin")
				message_admins("[nick] set the next round's map to [mapName] from Discord")

				return ircbot.response(ircmsg)

			if ("whitelistChange")
				if (!plist["wlType"] || !plist["ckey"])
					return 0

				var/type = plist["wlType"]
				var/ckey = plist["ckey"]
				var/msg

				if (type == "add" && !(ckey in whitelistCkeys))
					whitelistCkeys += ckey
					msg = "Entry '[ckey]' added to whitelist"
				else if (type == "remove" && (ckey in whitelistCkeys))
					whitelistCkeys -= ckey
					msg = "Entry '[ckey]' removed from whitelist"

				if (msg)
					logTheThing(LOG_ADMIN, null, msg)
					logTheThing(LOG_DIARY, null, msg, "admin")

				return 1

			if ("getNotes")
				if (!plist["ckey"])
					return 0

				var/list/data = list(
					"auth" = config.player_notes_auth,
					"action" = "get",
					"ckey" = plist["ckey"],
					"format" = "json"
				)

				// Fetch notes via HTTP
				var/datum/http_request/request = new()
				request.prepare(RUSTG_HTTP_METHOD_GET, "[config.player_notes_baseurl]/?[list2params(data)]", "", "")
				request.begin_async()
				UNTIL(request.is_complete())
				var/datum/http_response/response = request.into_response()

				if (response.errored || !response.body)
					return 0

				return response.body

			if ("getPlayerStats")
				if (!plist["ckey"])
					return 0

				// playtime stats
				var/list/data = list(
					"auth" = config.player_notes_auth,
					"action" = "user_stats",
					"ckey" = plist["ckey"],
					"format" = "json"
				)
				var/datum/http_request/playtime_request = new()
				playtime_request.prepare(RUSTG_HTTP_METHOD_GET, "[config.player_notes_baseurl]/?[list2params(data)]", "", "")
				playtime_request.begin_async()

				// round stats
				// cleverly making this request inbetween the start and the wait of the playtime request
				var/list/response = null
				try
					response = apiHandler.queryAPI("playerInfo/get", list("ckey" = plist["ckey"]), forceResponse = 1)
				catch
					return 0
				if (!response)
					return 0

				// finish playtime stats
				UNTIL(playtime_request.is_complete())
				var/datum/http_response/playtime_response = playtime_request.into_response()
				if (!playtime_response.errored && playtime_response.body)
					response["playtime"] = playtime_response.body

				return json_encode(response)

			if("profile")
				var/type = plist["profiler_type"]
				if(type != "sendmaps")
					type = null
				if(plist["action"] == "save")
					var/static/profilerLogID = 0
					var/output = world.Profile(PROFILE_REFRESH, type, "json")
					var/fname = "data/logs/profiling/[global.roundLog_date]_manual_[profilerLogID++].json"
					rustg_file_write(output, fname)
					return fname
				var/action = list(
					"stop" = PROFILE_STOP,
					"clear" = PROFILE_CLEAR,
					"start" = PROFILE_START,
					"refresh" = PROFILE_REFRESH,
					"restart" = PROFILE_RESTART
				)[plist["action"]]
				var/final_action = action
				if(plist["average"])
					final_action |= PROFILE_AVERAGE
				if(plist["action"] == "stop")
					lag_detection_process.manual_profiling_on = FALSE
				else if(plist["action"] == "start")
					lag_detection_process.manual_profiling_on = TRUE
				var/output = world.Profile(final_action, type, "json")
				if(plist["action"] == "refresh" || plist["action"] == "stop")
					SPAWN(1)
						var/n_tries = 3
						var/datum/http_response/response = null
						while(--n_tries > 0 && (isnull(response) || response.errored))
							var/datum/http_request/request = new()
							request.prepare(RUSTG_HTTP_METHOD_POST, "[config.irclog_url]/profiler_result", output, "")
							request.begin_async()
							UNTIL(request.is_complete())
							response = request.into_response()
				return 1

			if("persistent_canvases")
				var/list/response = list()
				for_by_tcl(canvas, /obj/item/canvas/big_persistent)
					response[canvas.id] = icon2base64(canvas.art)
				return json_encode(response)

			if("lazy_canvas_list")
				var/list/response = list()
				for_by_tcl(canvas, /obj/item/canvas/lazy_restore)
					response += canvas.id
				return json_encode(response)

			if("lazy_canvas_get")
				var/list/response = list()
				for_by_tcl(canvas, /obj/item/canvas/lazy_restore)
					if(canvas.id == plist["id"])
						if(!canvas.initialized)
							canvas.load_from_id(canvas.id)
						response[canvas.id] = icon2base64(canvas.art)
				return json_encode(response)


/world/proc/setMaxZ(new_maxz)
	// when calling this proc if you don't care about the actual contents of the new z-level you might want to set
	// global.dont_init_space = TRUE before calling this proc and unset it afterwards. This will speed things up but
	// the space filling this z-level will be somewhat broken (which you will hopefully replace with whatever it is you want to replace it with).
	if (!isnum(new_maxz) || new_maxz <= src.maxz)
		return src.maxz
	for (var/zlevel = world.maxz+1; zlevel <= new_maxz; zlevel++)
		src.maxz++
		src.setupZLevel(zlevel)
	return src.maxz

/world/proc/setupZLevel(new_zlevel)
	global.zlevels += new/datum/zlevel("dyn[new_zlevel]", length(global.zlevels) + 1)
	init_spatial_map(new_zlevel)

/// EXPERIMENTAL STUFF
var/opt_inactive = null
/world/proc/Optimize()
	SPAWN(0)
		if(!opt_inactive) opt_inactive  = world.timeofday

		if(world.timeofday - opt_inactive >= 600 || world.timeofday - opt_inactive < 0)
			KickInactiveClients()
			//if(mysql)
				//mysql.CleanQueries()
			opt_inactive = world.timeofday

		sleep(10 SECONDS)

/world/proc/KickInactiveClients()
	for(var/client/C in clients)
		if(!C.holder && ((C.inactivity/10)/60) >= 15)
			boutput(C, "<span class='alert'>You have been inactive for more than 15 minutes and have been disconnected.</span>")
			del(C)

/// EXPERIMENTAL STUFF

/world/Del()
	disable_auxtools_debugger()
	. = ..()
