/// proocess for flock_structure objects
/datum/controller/process/cross_server_sync
	setup()
		name = "Cross Server Sync"
		schedule_interval = 1 MINUTE

		for(var/datum/game_server/game_server as anything in game_servers)
			game_server.sync_server_data()
	doWork()
		for(var/datum/game_server/game_server as anything in game_servers)
			game_server.sync_server_data()
