#define CLOUD_SAVES_SIMULATED_CLOUD "data/simulated_cloud.json"

/datum/cloudSaves
	var/datum/player/player = null
	var/list/data = list()
	var/list/saves = list()
	var/loaded = FALSE // Have we performed an initial fetch
	var/simulating = FALSE

	New(datum/player/player)
		..()
		src.player = player
		#ifndef LIVE_SERVER
		src.simulating = TRUE
		#endif

	proc/getSimulatedCloud()
		if (fexists(CLOUD_SAVES_SIMULATED_CLOUD))
			var/simulatedContent = file2text(CLOUD_SAVES_SIMULATED_CLOUD)
			var/list/simulatedCloud = json_decode(simulatedContent)
			var/list/playerCloud = simulatedCloud["[src.player.ckey]"]
			if (playerCloud)
				if (!("data" in playerCloud)) playerCloud["data"] = list()
				if (!("saves" in playerCloud)) playerCloud["saves"] = list()
				return playerCloud

		return list("data" = list(), "saves" = list())

	proc/putSimulatedCloud(type, key, value)
		var/list/simulatedCloud = list()
		var/list/playerCloud = list("data" = list(), "saves" = list())
		if (fexists(CLOUD_SAVES_SIMULATED_CLOUD))
			var/simulatedContent = file2text(CLOUD_SAVES_SIMULATED_CLOUD)
			simulatedCloud = json_decode(simulatedContent)
			playerCloud = simulatedCloud["[src.player.ckey]"]

		if (!("data" in playerCloud)) playerCloud["data"] = list()
		if (!("saves" in playerCloud)) playerCloud["saves"] = list()
		playerCloud[type][key] = value
		simulatedCloud["[src.player.ckey]"] = playerCloud
		rustg_file_write(json_encode(simulatedCloud), CLOUD_SAVES_SIMULATED_CLOUD)

	proc/deleteSimulatedCloud(type, key)
		var/list/simulatedCloud = list()
		var/list/playerCloud = list("data" = list(), "saves" = list())
		if (fexists(CLOUD_SAVES_SIMULATED_CLOUD))
			var/simulatedContent = file2text(CLOUD_SAVES_SIMULATED_CLOUD)
			simulatedCloud = json_decode(simulatedContent)
			playerCloud = simulatedCloud["[src.player.ckey]"]

		if (key in playerCloud[type])
			var/list/thing = playerCloud[type]
			thing.Remove(key)
			playerCloud[type] = thing

		simulatedCloud["[src.player.ckey]"] = playerCloud
		rustg_file_write(json_encode(simulatedCloud), CLOUD_SAVES_SIMULATED_CLOUD)

	proc/fetch()
		if (!src.player.id) return FALSE
		if (src.simulating)
			// Local fallback, load data from JSON file
			var/list/playerCloud = src.getSimulatedCloud()
			src.data = playerCloud["data"]
			src.saves = playerCloud["saves"]
			src.loaded = TRUE

		else
			try
				var/datum/apiRoute/players/saves/get/getSavesAndData = new
				getSavesAndData.queryParams = list("player_id" = src.player.id)
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

		out(world, json_encode(src.data))
		return TRUE

	proc/putData(key, value)
		if (!src.player.id) return
		if (src.simulating)
			// Local fallback, update JSON file
			src.putSimulatedCloud("data", key, value)

		else
			try
				var/datum/apiRoute/players/saves/data/post/addPlayerData = new
				addPlayerData.buildBody(src.player.id, key, value)
				var/datum/apiModel/Tracked/PlayerRes/PlayerDataResource/playerData = apiHandler.queryAPI(addPlayerData)
				out(world, "res is: [playerData.ToString()]") // TODO: remove
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, src.player.ckey, "failed to put data into their cloud. Key: [key]. Value: [value]. Error: [error.message]")
				return FALSE

		src.data[key] = value
		return TRUE

	proc/putSave(name, data)
		if (!src.player.id) return
		if (src.simulating)
			// Local fallback, update JSON file
			src.putSimulatedCloud("saves", name, data)

		else
			try
				var/datum/apiRoute/players/saves/file/post/addPlayerSave = new
				addPlayerSave.buildBody(src.player.id, name, data)
				var/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource/playerSave = apiHandler.queryAPI(addPlayerSave)
				out(world, "res is: [playerSave.ToString()]") // TODO: remove
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, src.player.ckey, "failed to put save into their cloud. Error: [error.message]")
				return FALSE

		src.saves[name] = data
		return TRUE

	proc/deleteData(key)
		if (!src.player.id) return
		if (src.simulating)
			// Local fallback, update JSON file
			src.deleteSimulatedCloud("data", key)

		else
			try
				var/datum/apiRoute/players/saves/data/delete/deletePlayerData = new
				deletePlayerData.buildBody(src.player.id, key)
				var/datum/apiModel/Message/message = apiHandler.queryAPI(deletePlayerData)
				out(world, "res is: [message.ToString()]") // TODO: remove
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, src.player.ckey, "failed to delete data from their cloud. Error: [error.message]")
				return FALSE

		src.data.Remove(key)
		return TRUE

	proc/deleteSave(name)
		if (!src.player.id) return
		if (src.simulating)
			// Local fallback, update JSON file
			src.deleteSimulatedCloud("saves", name)

		else
			try
				var/datum/apiRoute/players/saves/file/delete/deletePlayerSave = new
				deletePlayerSave.buildBody(src.player.id, name)
				var/datum/apiModel/Message/message = apiHandler.queryAPI(deletePlayerSave)
				out(world, "res is: [message.ToString()]") // TODO: remove
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, src.player.ckey, "failed to delete save from their cloud. Error: [error.message]")
				return FALSE

		src.saves.Remove(name)
		return TRUE

	proc/getData(key)
		return src.data[key]

	proc/getSave(name)
		return src.saves[name]


proc/cloud_saves_put_data_bulk(list/data)
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
		var/datum/apiModel/Message/message = apiHandler.queryAPI(addBulkData)
		out(world, "res is: [message.ToString()]") // TODO: remove
		return TRUE
	catch (var/exception/e)
		var/datum/apiModel/Error/error = e.name
		logTheThing(LOG_DEBUG, null, "failed to put bulk data into the cloud. Error: [error.message]")
		return FALSE
#endif
