#define UPDATE_TITLE_STATUS(x) if (game_start_countdown) game_start_countdown.update_status(x)

/world/proc/init()
	set background = 1
	Z_LOG_DEBUG("World/Init", "init() - Lagcheck enabled")
	lagcheck_enabled = 1

	game_start_countdown = new()
	UPDATE_TITLE_STATUS("Initializing world")

	Z_LOG_DEBUG("World/Init", "Loading admins...")
	load_admins()//UGH
	Z_LOG_DEBUG("World/Init", "Loading whitelist...")
	load_whitelist() //WHY ARE WE UGH-ING
	Z_LOG_DEBUG("World/Init", "Loading playercap bypass keys...")
	load_playercap_bypass()

	Z_LOG_DEBUG("World/Init", "Notifying hub of new round")
	roundManagement.recordStart()
#ifdef LIVE_SERVER
	if (roundId == 0) //oh no
		SPAWN(0)
			var/counter = 0
			while (roundId == 0)
				message_admins("Roundstart API query failed, this is very bad, trying again in 5 seconds.")
				logTheThing(LOG_DEBUG, src, "Roundstart API query failed, this is very bad, trying again in 5 seconds.")
				sleep(5 SECONDS)
				roundManagement.recordStart()
				counter++
			message_admins("Roundstart API query succeeded after [counter] failed attempts.")
			logTheThing(LOG_DEBUG, src, "Roundstart API query succeeded after [counter] failed attempts.")
#endif
	Z_LOG_DEBUG("World/Init", "Loading MOTD...")
	src.load_motd()//GUH


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

	mapSwitcher = new()

	Z_LOG_DEBUG("World/Init", "Telemanager setup...")
	tele_man = new()
	tele_man.setup()

	Z_LOG_DEBUG("World/Init", "M4GP13 setup...")
	magpie_man.setup()

	Z_LOG_DEBUG("World/Init", "Mining setup...")
	mining_controls.setup_mining_landmarks()

	createRenderSourceHolder()

	// Set this stupid shit up here because byond's object tree output can't
	// cope with a list initializer that contains "[constant]" keys
	headset_channel_lookup = list(
		"[R_FREQ_RESEARCH]" = "Research",
		"[R_FREQ_MEDICAL]" = "Medical",
		"[R_FREQ_ENGINEERING]" = "Engineering",
		"[R_FREQ_CORPORATE]" = "Corporate",
		"[R_FREQ_COMMAND]" = "Command",
		"[R_FREQ_SECURITY]" = "Security",
		"[R_FREQ_CIVILIAN]" = "Civilian",
		"[R_FREQ_DEFAULT]" = "General",
		"[R_FREQ_INTERCOM_AI]" = "AI Intercom",
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
#ifndef CI_RUNTIME_CHECKING
	world.log << "Map: [getMapNameFromID(map_setting)]"
	logTheThing(LOG_STATION, null, "Map: [getMapNameFromID(map_setting)]")
#endif

	if (time2text(world.realtime,"DDD") == "Fri")
		NT |= mentors

	Z_LOG_DEBUG("World/Init", "Loading intraround jars...")
	load_intraround_jars()
	load_intraround_eggs()
	spawn_kitchen_note()

	//SpyStructures and caches live here
	UPDATE_TITLE_STATUS("Updating cache")
	Z_LOG_DEBUG("World/Init", "Building various caches...")
	build_valid_game_modes()
	build_chem_structure()
	build_reagent_cache()
	build_supply_pack_cache()
	build_syndi_buylist_cache()
	build_manufacturer_icons()
	build_clothingbooth_caches()
	initialize_biomes()

	Z_LOG_DEBUG("World/Init", "Setting up airlock/APC wires...")
	airlockWireColorToFlag = RandomAirlockWires()
	APCWireColorToFlag = RandomAPCWires()
	Z_LOG_DEBUG("World/Init", "Loading fishing spots...")
	global.initialise_fishing_spots()

	//QM Categories by ZeWaka
	build_qm_categories()

	#ifndef SKIP_Z5_SETUP
	UPDATE_TITLE_STATUS("Building mining level")
	Z_LOG_DEBUG("World/Init", "Setting up mining level...")
	makeMiningLevel()
	#endif

	if (derelict_mode)
		Z_LOG_DEBUG("World/Init", "Derelict mode stuff")
		creepify_station()
		voidify_world()
		signal_loss = 80 // heh
		bust_lights()
		master_mode = "disaster" // heh pt. 2

	UPDATE_TITLE_STATUS("Generating minimaps")
	Z_LOG_DEBUG("World/Init", "Generating minimaps...")
	minimap_renderer = new /datum/minimap_renderer()
	minimap_renderer.initialise_minimaps()

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
	initialize_mail_system()
	#endif

	#if defined(ENABLE_ARTEMIS) && !defined(SKIP_PLANETS_SETUP)
	UPDATE_TITLE_STATUS("Building planet level")
	Z_LOG_DEBUG("World/Init", "Setting up planet level...")
	makePlanetLevel()
	#endif

	UPDATE_TITLE_STATUS("Generating terrain")
	Z_LOG_DEBUG("World/Init", "Setting perlin noise terrain...")
	for (var/area/map_gen/A in by_type[/area/map_gen])
		A.generate_perlin_noise_terrain()

	UPDATE_TITLE_STATUS("Calculating cameras")
	Z_LOG_DEBUG("World/Init", "Updating camera visibility...")
	build_camera_network()
	camera_coverage_controller.setup()

	UPDATE_TITLE_STATUS("Preloading client data...")
	Z_LOG_DEBUG("World/Init", "Transferring manuf. icons to clients...")
	sendItemIconsToAll()

	UPDATE_TITLE_STATUS("Starting processes")
	Z_LOG_DEBUG("World/Init", "Setting up process scheduler...")
	processScheduler.setup()

	UPDATE_TITLE_STATUS("Reticulating splines")
	Z_LOG_DEBUG("World/Init", "Running map-specific initialization...")
	map_settings.init()

	UPDATE_TITLE_STATUS("Initializing worldgen setup")
	Z_LOG_DEBUG("World/Init", "Initializing worldgen...")
	initialize_worldgen()

	#if !defined(GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW) && !defined(CI_RUNTIME_CHECKING)
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

	lincolnshire = new


#ifdef PREFAB_CHECKING
	placeAllPrefabs()
#endif
#ifdef RANDOM_ROOM_CHECKING
	placeAllRandomRooms()
#endif

#ifdef CI_RUNTIME_CHECKING
	populate_station()
	check_map_correctness()
	SPAWN(15 SECONDS)
		Reboot_server()
#endif

#if defined(UNIT_TESTS) && !defined(UNIT_TESTS_RUN_TILL_COMPLETION)
	SPAWN(10 SECONDS)
		Reboot_server()
#endif

#undef UPDATE_TITLE_STATUS



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


/proc/createRenderSourceHolder()
	if(!renderSourceHolder)
		renderSourceHolder = new
		renderSourceHolder.name = "SCREEN HOLDER"
		renderSourceHolder.screen_loc = "CENTER"
		renderSourceHolder.mouse_opacity = 0
		renderSourceHolder.render_target = "*renderSourceHolder"

/world/proc/load_motd()
	join_motd = grabResource("html/motd.html")
