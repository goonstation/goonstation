/**
 * Manage cloud save files and data for a player
 */


#define CLOUD_SAVES_SIMULATED_CLOUD "data/simulated_cloud.json"

/datum/cloudSaves
	var/datum/player/player = null
	///generic cloud data
	var/list/data = list()
	///cloudsaves. ONLY FOR CHARACTER PROFILE CLOUD SAVES. NOTHING ELSE.
	var/list/saves = list()
	var/loaded = FALSE // Have we performed an initial fetch
	var/simulating = FALSE

	New(datum/player/player)
		..()
		src.player = player
		#ifndef LIVE_SERVER
		src.simulating = TRUE
		#endif

	/// Get the simulated cloud information for this player, for local development
	proc/getSimulatedCloud()
		if (fexists(CLOUD_SAVES_SIMULATED_CLOUD))
			var/simulatedContent = file2text(CLOUD_SAVES_SIMULATED_CLOUD)
			if (simulatedContent)
				var/list/simulatedCloud = json_decode(simulatedContent)
				var/list/playerCloud = simulatedCloud["[src.player.ckey]"]
				if (playerCloud)
					if (!("data" in playerCloud)) playerCloud["data"] = list()
					if (!("saves" in playerCloud)) playerCloud["saves"] = list()
					return playerCloud

		return list("data" = list(), "saves" = list())

	/// Put new data into the simulated cloud for this player, for local development
	proc/putSimulatedCloud(type, key, value)
		var/list/simulatedCloud = list()
		var/list/playerCloud = list("data" = list(), "saves" = list())
		if (fexists(CLOUD_SAVES_SIMULATED_CLOUD))
			var/simulatedContent = file2text(CLOUD_SAVES_SIMULATED_CLOUD)
			if (simulatedContent)
				simulatedCloud = json_decode(simulatedContent)
				playerCloud = simulatedCloud["[src.player.ckey]"]

		if (!playerCloud) playerCloud = list()
		if (!("data" in playerCloud)) playerCloud["data"] = list()
		if (!("saves" in playerCloud)) playerCloud["saves"] = list()
		playerCloud[type][key] = value
		simulatedCloud["[src.player.ckey]"] = playerCloud
		rustg_file_write(json_encode(simulatedCloud), CLOUD_SAVES_SIMULATED_CLOUD)

	/// Delete data from the simulated cloud for this player, for local development
	proc/deleteSimulatedCloud(type, key)
		var/list/simulatedCloud = list()
		var/list/playerCloud = list("data" = list(), "saves" = list())
		if (fexists(CLOUD_SAVES_SIMULATED_CLOUD))
			var/simulatedContent = file2text(CLOUD_SAVES_SIMULATED_CLOUD)
			if (simulatedContent)
				simulatedCloud = json_decode(simulatedContent)
				playerCloud = simulatedCloud["[src.player.ckey]"]

		if (key in playerCloud[type])
			var/list/thing = playerCloud[type]
			thing.Remove(key)
			playerCloud[type] = thing

		simulatedCloud["[src.player.ckey]"] = playerCloud
		rustg_file_write(json_encode(simulatedCloud), CLOUD_SAVES_SIMULATED_CLOUD)

	/// Fetch all cloud data and files associated with this player
	proc/fetch()
		if (src.simulating)
			// Local fallback, load data from JSON file
			var/list/playerCloud = src.getSimulatedCloud()
			src.data = playerCloud["data"]
			src.saves = playerCloud["saves"]
			src.loaded = TRUE

		else
			if (!src.player.id && !src.player.ckey) return FALSE
			try
				var/datum/apiRoute/players/saves/get/getSavesAndData = new
				getSavesAndData.queryParams = list("player_id" = src.player.id, "ckey" = src.player.ckey)
				var/datum/apiModel/GetPlayerSaves/savesAndData = apiHandler.queryAPI(getSavesAndData)
				var/list/newData = list()
				for (var/datum/apiModel/Tracked/PlayerRes/PlayerDataResource/data in savesAndData.data)
					newData[data.key] = data.value
				var/list/newSaves = list()
				for (var/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource/save in savesAndData.saves)
					newSaves[save.name] = save.data

				src.data = newData
				src.saves = newSaves
				src.loaded = TRUE
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, src.player.ckey, "failed to have their cloud data loaded: [error.message]")
				logTheThing(LOG_DIARY, src.player.ckey, "failed to have their cloud data loaded: [error.message]", "admin")

		return TRUE

	/// Save new cloud data for this player
	proc/putData(key, value)
		if(value == src.data[key]) //don't bother sending data if we'd be making no change
			return TRUE

		if (src.simulating)
			// Local fallback, update JSON file
			src.putSimulatedCloud("data", key, value)

		else
			if (!src.player.id && !src.player.ckey)
				logTheThing(LOG_DEBUG, src.player.ckey, "No player ID or ckey found in cloud data put [key], [value]")
				logTheThing(LOG_DIARY, src.player.ckey, "No player ID or ckey found in cloud data put [key], [value]", "admin")
				return
			try
				var/datum/apiRoute/players/saves/data/post/addPlayerData = new
				addPlayerData.buildBody(src.player.id, src.player.ckey, key, value)
				apiHandler.queryAPI(addPlayerData)
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, src.player.ckey, "failed to put data into their cloud. Key: [key]. Value: [value]. Error: [error.message]")
				logTheThing(LOG_DIARY, src.player.ckey, "failed to put data into their cloud. Key: [key]. Value: [value]. Error: [error.message]", "admin")
				return FALSE

		src.data[key] = value
		return TRUE

	/// Save a new cloud file for this player. ONLY FOR CHARACTER PROFILE CLOUD SAVES. USE putData FOR ANYTHING ELSE.
	proc/putSave(name, data)
		if(data == src.saves[name]) //don't bother sending save if we'd be making no change
			return TRUE

		if (src.simulating)
			// Local fallback, update JSON file
			src.putSimulatedCloud("saves", name, data)

		else
			if (!src.player.id && !src.player.ckey) return
			try
				var/datum/apiRoute/players/saves/file/post/addPlayerSave = new
				addPlayerSave.buildBody(src.player.id, src.player.ckey, name, data)
				apiHandler.queryAPI(addPlayerSave)
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, src.player.ckey, "failed to put save into their cloud. Error: [error.message]")
				logTheThing(LOG_DIARY, src.player.ckey, "failed to put save into their cloud. Error: [error.message]", "admin")
				return FALSE

		src.saves[name] = data
		return TRUE

	/// Delete cloud data for this player
	proc/deleteData(key)
		if (src.simulating)
			// Local fallback, update JSON file
			src.deleteSimulatedCloud("data", key)

		else
			if (!src.player.id && !src.player.ckey) return
			try
				var/datum/apiRoute/players/saves/data/delete/deletePlayerData = new
				deletePlayerData.buildBody(src.player.id, src.player.ckey, key)
				apiHandler.queryAPI(deletePlayerData)
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, src.player.ckey, "failed to delete data from their cloud. Error: [error.message]")
				logTheThing(LOG_DIARY, src.player.ckey, "failed to delete data from their cloud. Error: [error.message]", "admin")
				return FALSE

		src.data.Remove(key)
		return TRUE

	/// Delete a cloud file for this player
	proc/deleteSave(name)
		if (src.simulating)
			// Local fallback, update JSON file
			src.deleteSimulatedCloud("saves", name)

		else
			if (!src.player.id && !src.player.ckey) return
			try
				var/datum/apiRoute/players/saves/file/delete/deletePlayerSave = new
				deletePlayerSave.buildBody(src.player.id, src.player.ckey, name)
				apiHandler.queryAPI(deletePlayerSave)
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, src.player.ckey, "failed to delete save from their cloud. Error: [error.message]")
				logTheThing(LOG_DIARY, src.player.ckey, "failed to delete save from their cloud. Error: [error.message]", "admin")
				return FALSE

		src.saves.Remove(name)
		return TRUE

	proc/getData(key)
		return src.data[key]

	proc/getSave(name)
		return src.saves[name]


/**
 * Mass save a collection of cloud data for various players
 * Input format:
 * list(
 * 		list(
 * 			"player_id" = 1,
 * 			"key" = "foo",
 * 			"value" = "bar"
 * 		),
 * 		list(
 * 			"player_id" = 2,
 * 			"key" = "foo2",
 * 			"value" = "bar2"
 * 		)
 * )
 */
/proc/cloud_saves_put_data_bulk(list/data)
#ifndef LIVE_SERVER
	var/list/newSimulatedCloud = list()
	var/list/simulatedCloud = list()
	if (fexists(CLOUD_SAVES_SIMULATED_CLOUD))
		var/simulatedContent = file2text(CLOUD_SAVES_SIMULATED_CLOUD)
		simulatedCloud = json_decode(simulatedContent)

	for (var/item in data)
		var/datum/player/P
		for (var/client/C in clients)
			if (C.player.id == item["player_id"])
				P = C.player
				break

		var/list/playerCloud = list("data" = list(), "saves" = list())
		if (P.ckey in simulatedCloud)
			playerCloud = simulatedCloud["[P.ckey]"]

		playerCloud["data"][item["key"]] = item["value"]
		P.cloudSaves.data[item["key"]] = item["value"]
		newSimulatedCloud["[P.ckey]"] = playerCloud

	rustg_file_write(json_encode(newSimulatedCloud), CLOUD_SAVES_SIMULATED_CLOUD)
	return TRUE
#else
	try
		var/datum/apiRoute/players/saves/databulk/post/addBulkData = new
		addBulkData.buildBody(json_encode(data))
		logTheThing(LOG_DIARY, null, "TEMP CLOUD BULK: [json_encode(data)]", "admin")
		apiHandler.queryAPI(addBulkData)
		return TRUE
	catch (var/exception/e)
		var/datum/apiModel/Error/error = e.name
		logTheThing(LOG_DEBUG, null, "failed to put bulk data into the cloud. Error: [error.message]")
		logTheThing(LOG_DIARY, null, "failed to put bulk data into the cloud. Error: [error.message]", "admin")
		return FALSE
#endif

/// Transfer all cloud save files from one player to another
/// WARNING: This overwrites all the saves for the target
/proc/cloud_saves_transfer(from_ckey, to_ckey)
#ifndef LIVE_SERVER
	// Wire note: I simply cannot be bothered to code the simulated file aspect of this
	throw EXCEPTION("Cloud save transferring is disabled during local development")
#else
	try
		var/datum/apiRoute/players/saves/file/transfer/transferSaves = new
		transferSaves.buildBody(from_ckey, to_ckey)
		apiHandler.queryAPI(transferSaves)
	catch (var/exception/e)
		var/datum/apiModel/Error/error = e.name
		logTheThing(LOG_DEBUG, null, "failed to transfer cloud saves from [from_ckey] to [to_ckey]. Error: [error.message]")
		throw EXCEPTION(error.message)
		return FALSE

	// Run updates if any of the targets are currently logged in
	for (var/client/C in clients)
		if (C.ckey == from_ckey)
			// The source player has all their saves moved
			C.player.cloudSaves.saves = list()
		if (C.ckey == to_ckey)
			// Trigger a re-fetch on the target so they can get their new saves right away
			C.player.cloudSaves.fetch()

	return TRUE
#endif
