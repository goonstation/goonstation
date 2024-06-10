/// proocess for cross server data syncing
/datum/controller/process/cross_server_sync
	setup()
		name = "Cross Server Sync"
		schedule_interval = 1 MINUTE

#ifdef LIVE_SERVER
		src.doWork()

	doWork()
		SPAWN(0)
			for(var/server in game_servers.servers)
				var/datum/game_server/game_server = game_servers.servers[server]
				game_server.sync_server_data()
			SEND_SIGNAL(src, COMSIG_SERVER_DATA_SYNCED)
#endif
