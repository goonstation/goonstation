
/datum/game_servers/proc/load_servers()
	// TODO move to a config file or read existing config files

	add_server(new/datum/game_server(
		"main1",
		"Goonstation 1 Classic: Heisenbee",
		"byond://goon1.goonhub.com:26100",
		1, ghost_notif_target=FALSE
		))
/* 	add_server(new/datum/game_server(
		"main2",
		"Goonstation 2 Classic: Bombini",
		"byond://goon2.goonhub.com:26200",
		2
		)) */
	add_server(new/datum/game_server(
		"main3",
		"Goonstation 3 Roleplay: Morty",
		"byond://goon3.goonhub.com:26300",
		3, ghost_notif_target=FALSE
		))
	add_server(new/datum/game_server(
		"main4",
		"Goonstation 4 Roleplay: Sylvester",
		"byond://goon4.goonhub.com:26400",
		4
		))
	add_server(new/datum/game_server(
		"main5",
		"Goonstation 5 Event: Rocko",
		"byond://goon5.goonhub.com:26500",
		5
		))

/* 	add_server(new/datum/game_server(
		"streamer1",
		"Goonstation Nightshade 1",
		"byond://tomato1.goonhub.com:27111",
		11, publ=FALSE
		))
	add_server(new/datum/game_server(
		"streamer2",
		"Goonstation Nightshade 2",
		"byond://tomato2.goonhub.com:27112",
		12, publ=FALSE
		))
	add_server(new/datum/game_server(
		"streamer3",
		"Goonstation Nightshade 3",
		"byond://tomato3.goonhub.com:27113",
		13, publ=FALSE
		)) */
