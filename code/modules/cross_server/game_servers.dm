var/global/datum/game_servers/game_servers = new

/datum/game_servers
	var/list/servers = list()
	var/list/by_ip_port = list()
	var/list/message_kinds = list()

	New()
		..()
		load_servers() // see server_list.dm
		for(var/type in concrete_typesof(/datum/cross_server_message, FALSE))
			var/datum/cross_server_message/csm = get_singleton(type)
			src.message_kinds[csm.name] = csm

	proc/find_by_ip_port(ip_port)
		RETURN_TYPE(/datum/game_server)
		if(ip_port in src.by_ip_port)
			return src.by_ip_port[ip_port]
		if(get_buddy()?.get_ip_port() == ip_port)
			return get_buddy()
		for(var/server_id in src.servers)
			var/datum/game_server/server = src.servers[server_id]
			if(server.is_me())
				continue
			if(server.get_ip_port() == ip_port)
				return server
		return null

	proc/add_server(datum/game_server/server)
		RETURN_TYPE(/datum/game_server)
		src.servers[server.id] = server
		return server

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

	proc/topic(textdata, addr)
		var/list/data = params2list(textdata)
		if(data["type"] != "game_servers")
			return null
		if(data["subtype"] == "get_ip_port")
			return copytext(world.url, 9) // strip "byond://"
		var/datum/game_server/server = src.find_by_ip_port(addr)
		if(isnull(server))
			return null
		if(!(data["subtype"] in src.message_kinds))
			return null
		var/datum/cross_server_message/csm = src.message_kinds[data["subtype"]]
		return csm.receive(data, server)

	proc/send_to_buddy(message_name, ...)
		if(!(message_name in src.message_kinds))
			throw EXCEPTION("Invalid cross-server message type")
		var/datum/cross_server_message/csm = src.message_kinds[message_name]
		var/datum/game_server/buddy = src.get_buddy()
		var/list/arguments = args
		arguments[1] = buddy // remove message_name, replace with server
		return csm.send(arglist(arguments))

	proc/input_server(mob/user, text, title, can_pick_all=FALSE, public_only=FALSE)
		RETURN_TYPE(/datum/game_server)
		var/list/pick_list = list()
		if(can_pick_all)
			pick_list["All"] = "all"
		for(var/id in src.servers)
			var/datum/game_server/server = src.servers[id]
			if(public_only && !server.publ)
				continue
			pick_list[server.name] = server
		var/text_result = input(user, text, title) as null|anything in pick_list
		if(isnull(text_result))
			return null
		return pick_list[text_result]

/datum/game_server
	var/id
	var/name
	var/url
	var/numeric_id
	var/publ = TRUE
	var/ghost_notif_target = TRUE
	var/ip_port = null

	New(id, name, url, numeric_id, publ=TRUE, ghost_notif_target=TRUE)
		..()
		src.id = id
		src.name = name
		src.url = url
		src.numeric_id = numeric_id
		src.publ = publ
		src.ghost_notif_target = ghost_notif_target

	proc/get_ip_port()
		if(isnull(src.ip_port))
			src.ip_port = src.send_message(list("type"="game_servers", "subtype"="get_ip_port"))
			if(!src.ip_port)
				src.ip_port = null
			global.game_servers.by_ip_port[src.ip_port] = src
		return src.ip_port

	proc/is_me()
		return src.id == config.server_id

	proc/send_message(list/data)
		return world.Export("[src.url]?[list2params(data)]")
