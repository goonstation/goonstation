/datum/unit_test/fallback_db

/datum/unit_test/fallback_db/Run()
	RUN_SEEDER(/datum/seeder/banSeeder)
	var/handle = FALLBACK_DB.open("fallback_db_local.sqlite", config.server_id, config.server_group_id)
	TEST_ASSERT(!isnull(handle), "Fallback DB failed to open")

	global.apiHandler.enabled = FALSE
	var/datum/apiRoute/bans/check/route = new
	route.queryParams = list("ckey" = "playerone")
	var/datum/apiModel/Tracked/Ban/ban = global.apiHandler.queryAPI(route, 1)
	TEST_ASSERT(!isnull(ban), "Failed to retrieve ban information")

	FALLBACK_DB.rows(handle, "DELETE * FROM BANS")

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
	playerResponse = apiHandler.queryAPI(playerLogin)
	TEST_ASSERT(!isnull(playerResponse), "Failed to retrieve player information")
	TEST_ASSERT(playerResponse["is_hos"], "playerfive should be hos")

	FALLBACK_DB.close(handle)
