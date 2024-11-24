/world/New()
	..()
	Remove_reboot_file()
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

	// Global handlers that should be highly available
	roundManagement = new()
	participationRecorder = new()
	antagWeighter = new()
	if (!chui) chui = new()

	station_name() // generate station name and set it

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

#ifndef LIVE_SERVER
#ifndef MY_COMPUTER_ACTUALLY_ISNT_THIS_FAST
	// "my computer is too fast and when i start the server in vscode
	// the client map area is just a black screen. for some reason adding
	// a sleep before world New() fixes it"
	sleep(1 SECOND)
#endif
#endif
	SPAWN(0)
		init()

#ifdef UNIT_TESTS
	unit_tests.run_tests()
#endif
