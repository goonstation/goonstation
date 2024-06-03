/// proocess for cross server data syncing
/datum/controller/process/cross_server_sync
	setup()
		name = "Cross Server Sync"
		schedule_interval = 1 MINUTE

#ifdef LIVE_SERVER
		src.doWork()

	doWork()
		for(var/server in game_servers.servers)
			var/datum/game_server/game_server = game_servers.servers[server]
			game_server.sync_server_data()
#endif
