/datum/game_server
	var/id
	var/name
	var/url
	var/numeric_id
	var/publ = TRUE

	New(id, name, url, numeric_id, publ=TRUE)
		..()
		src.id = id
		src.name = name
		src.url = url
		src.numeric_id = numeric_id
		src.publ = publ

	proc/is_me()
		return src.id == config.server_id

	proc/send_message(list/data)
		return world.Export("[src.url]?[list2params(data)]")

/datum/game_servers
	var/list/servers

	New()
		..()
		src.servers = list()

		add_server(new/datum/game_server(
			"main1",
			"Goonstation 1 Classic: Heisenbee",
			"byond://goon1.goonhub.com:26100",
			1
			))
		add_server(new/datum/game_server(
			"main2",
			"Goonstation 2 Classic: Bombini",
			"byond://goon2.goonhub.com:26200",
			2
			))
		add_server(new/datum/game_server(
			"main3",
			"Goonstation 3 Roleplay: Morty",
			"byond://goon3.goonhub.com:26300",
			3
			))
		add_server(new/datum/game_server(
			"main4",
			"Goonstation 4 Roleplay: Sylvester",
			"byond://goon4.goonhub.com:26400",
			4
			))

		add_server(new/datum/game_server(
			"streamer1",
			"Goonstation Nightshade 1",
			"byond://tomato.goonhub.com:27111",
			11, publ=FALSE
			))
		add_server(new/datum/game_server(
			"streamer2",
			"Goonstation Nightshade 2",
			"byond://tomato.goonhub.com:27112",
			12, publ=FALSE
			))
		add_server(new/datum/game_server(
			"streamer3",
			"Goonstation Nightshade 3",
			"byond://tomato.goonhub.com:27113",
			13, publ=FALSE
			))

	proc/add_server(datum/game_server/server)
		src.servers[server.id] = server

	proc/find_server(text)
		RETURN_TYPE(/datum/game_server)
		if(text in src.servers)
			return src.servers[text]
		text = ckey(text)
		for(var/id in src.servers)
			var/datum/game_server/server = src.servers[id]
			if(
				ckey(server.id) == text || \
				ckey(server.name) == text || \
				ckey(server.url) == text || \
				"[server.numeric_id]" == text || \
				server.numeric_id == text)
				return server
		return null

	proc/get_buddy()
		RETURN_TYPE(/datum/game_server)
		if(config.server_buddy_id in src.servers)
			return src.servers[config.server_buddy_id]
		return null

var/global/datum/game_servers/game_servers = new
