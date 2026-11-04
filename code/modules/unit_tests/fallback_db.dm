/datum/unit_test/fallback_db

/datum/unit_test/fallback_db/Run()
	var/database/db = FALLBACK_DB.open("fallback_db_local.sqlite", config.server_id, config.server_group_id)
	TEST_ASSERT(!isnull(db), "Fallback DB failed to open")
	global.apiHandler.enabled = FALSE
	var/datum/apiRoute/bans/check/route = new
	route.queryParams = list("ckey" = "playerone")
	var/datum/apiModel/Tracked/Ban/ban = global.apiHandler.queryAPI(route, 1)
	TEST_ASSERT(!isnull(ban), "Failed to retrieve ban information")
