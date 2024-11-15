/**
 * THIS !!!SINGLE!!! PROC IS WHERE ANY FORM OF INIITIALIZATION THAT CAN'T BE PERFORMED IN CONTROLLERS, WORLD/NEW, OR preMapLoad IS DONE
 * NOWHERE THE FUCK ELSE
 * I DON'T CARE HOW MANY LAYERS OF DEBUG/PROFILE/TRACE WE HAVE, YOU JUST HAVE TO DEAL WITH THIS PROC EXISTING
 * YOU WILL BE SENT TO THE CRUSHER IF YOU TOUCH THIS UNNECESSAIRLY
 */
/world/proc/Genesis()
#ifdef LIVE_SERVER
	world.log = file("data/errors.log")
#endif

	var/should_init_tracy = FALSE
	tracy_initialized = FALSE

#ifdef TRACY_PROFILER_HOOK
	global.tracy_init_reason = "TRACY_PROFILER_HOOK defined"
	should_init_tracy = TRUE
#else
	if (fexists(TRACY_ENABLE_PATH))
		global.tracy_init_reason ||= "enabled for round"
		world.log << "[TRACY_ENABLE_PATH] exists, initializing byond-tracy!"
		should_init_tracy = TRUE
		fdel(TRACY_ENABLE_PATH)
#endif
	if (should_init_tracy)
		prof_init()

	enable_auxtools_debugger()

#if defined(SERVER_SIDE_PROFILING) && (defined(SERVER_SIDE_PROFILING_FULL_ROUND) || defined(SERVER_SIDE_PROFILING_PREGAME))
#warn Profiler enabled at start of init
	world.Profile(PROFILE_START | PROFILE_AVERAGE, "sendmaps", "json")
#endif

	// // !!
	// world.log << "Uncomment and breakpoint me if you need to Tracy Profile preMapLoad, otherwise it likely won't catch it"
	// // !!


//Called RIGHT AFTER THE ABOVE, BEFORE the map loads. Useful for objects that require certain things be set during init
/datum/preMapLoad/New()
	global.current_state = GAME_STATE_PRE_MAP_LOAD

	server_start_time = world.timeofday

#ifdef Z_LOG_ENABLE
	ZLOG_START_TIME = world.timeofday
#endif
	Z_LOG_DEBUG("Preload", "Map preload running.")

#ifndef CI_RUNTIME_CHECKING
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

	// Global handlers that should be highly available
	apiHandler = new()
	eventRecorder = new()

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

	url_regex = new("(https?|\\bbyond|\\bwww)(\\.|:\\/\\/)", "ig")
	full_url_regex = new(@"(https?:\/\/)?((\\bwww\.)?([-\w]+\.)+[\l]+(\/\S+)*\/?)","ig")

	Z_LOG_DEBUG("Preload", "initLimiter() (whatever the fuck that does)")
	initLimiter()
	Z_LOG_DEBUG("Preload", "Creating named color list...")
	create_named_colors()

	Z_LOG_DEBUG("Preload", "Building material property cache...")
	buildMaterialPropertyCache()	//Order is important.
	Z_LOG_DEBUG("Preload", "Building material cache...")
	buildMaterialCache()			//^^
	Z_LOG_DEBUG("Preload", "Building manufacturing requirement cache...")
	buildManufacturingRequirementCache() // ^^

	Z_LOG_DEBUG("Preload", "Generating access name lookup") // ^^
	generate_access_name_lookup()

	// no log because this is functionally instant
	global_signal_holder = new

	Z_LOG_DEBUG("Preload", "Loading saved gamemode...")
	world.load_mode()

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
	for(var/A in concrete_typesof(/datum/jobXpReward)) //Caching xp rewards.
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

	Z_LOG_DEBUG("Preload", "  fluid turf misc setup")
	fluid_turf_setup(first_time=TRUE)

	Z_LOG_DEBUG("Preload", "Preload stage complete")
	..()
	global.current_state = GAME_STATE_MAP_LOAD



/proc/buildMaterialPropertyCache()
	if(materialProps.len) return
	for(var/A in childrentypesof(/datum/material_property)) //Caching material props
		var/datum/material_property/R = new A()
		materialProps.Add(R)
	return

/proc/buildMaterialCache()
	material_cache = list()
	var/materialList = concrete_typesof(/datum/material)
	for(var/datum/material/mat as anything in materialList)
		if(initial(mat.cached))
			var/datum/material/M = new mat()
			material_cache[M.getID()] = M.getImmutable()

/proc/buildManufacturingRequirementCache()
	requirement_cache = list()
	var/requirementList = concrete_typesof(/datum/manufacturing_requirement) - /datum/manufacturing_requirement/match_material
	for (var/datum/manufacturing_requirement/R_path as anything in requirementList)
		var/datum/manufacturing_requirement/R = new R_path()
		#ifdef CHECK_MORE_RUNTIMES
		if (R.getID() in requirement_cache)
			CRASH("ID conflict: [R.getID()] from [R]")
		#endif
		requirement_cache[R.getID()] = R
	for (var/datum/material/mat as anything in material_cache)
		var/datum/manufacturing_requirement/match_material/R = new /datum/manufacturing_requirement/match_material(mat)
		#ifdef CHECK_MORE_RUNTIMES
		if (R.getID() in requirement_cache)
			CRASH("ID conflict: [R.getID()] from [R]")
		#endif
		requirement_cache[R.getID()] = R
