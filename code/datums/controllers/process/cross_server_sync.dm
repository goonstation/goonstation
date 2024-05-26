/// proocess for flock_structure objects
/datum/controller/process/cross_server_sync
	setup()
		name = "Cross Server Sync"
		schedule_interval = 1 MINUTE

#ifdef LIVE_SERVER
		src.doWork()
	doWork()
		for(var/datum/game_server/game_server as anything in game_servers.servers)
			game_server.sync_server_data()
#endif
