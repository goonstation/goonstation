/datum/unit_test/fallback_db
	//database handle
	var/handle

/datum/unit_test/fallback_db/SetUp()
	RUN_SEEDER(/datum/seeder/banSeeder)
	src.handle = FALLBACK_DB.open("fallback_db_local.sqlite", config.server_id, config.server_group_id, rw_flag = RUSTG_SQLITE_READ_WRITE)

/datum/unit_test/fallback_db/Run()
	TEST_ASSERT(!isnull(handle), "Fallback DB failed to open")

	global.apiHandler.enabled = FALSE
	var/datum/apiRoute/bans/check/route = new
	route.queryParams = list("ckey" = "playerone")
	var/datum/apiModel/Tracked/Ban/ban = global.apiHandler.queryAPI(route, 1)

	TEST_ASSERT(!isnull(ban), "Failed to retrieve ban information")

	var/datum/apiRoute/players/login/playerLogin = new
	playerLogin.buildBody(
		"playerfive",
		"playerfive",
		"127.0.0.1",
		"",
		"",
		"",
		4,
		config.server_id
	)
	var/datum/apiModel/Tracked/Player/playerResponse = apiHandler.queryAPI(playerLogin)
	TEST_ASSERT(!isnull(playerResponse), "Failed to retrieve player information")
	TEST_ASSERT(playerResponse["is_hos"], "playerfive should be hos")

	var/datum/apiRoute/bans/get/getbans = new
	var/datum/apiModel/Paginated/BanList/bans = apiHandler.queryAPI(getbans)
	TEST_ASSERT(length(bans.data) > 0, "Failed to retrieve any paginated ban data")


/datum/unit_test/fallback_db/TearDown()
	FALLBACK_DB.rows(handle, "DELETE * FROM BANS")
	FALLBACK_DB.close(handle)
