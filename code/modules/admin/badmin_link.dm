///world/Topic
var/global/goonhub/goonhub

/proc/logit(var/where, var/sendToAdmins)
	var/list/built = list()
	built["channel"] = where
	var/list/logdata = list()
	for(var/i = 3, i <= args.len, i++)
		var/datum/arg = args[i]
		if(istext(arg))
			logdata[++logdata.len] = arg
		else if(isnum(arg))
			logdata[++logdata.len] = num2text(arg)
		else if(ismob(arg))
			var/list/mdata = list()
			var/mob/M = arg
			mdata["mob"] = M.name
			var/turf/t = get_turf(M)
			mdata["loc"] = t ? "[t.x],[t.y],[t.z]" : "null"
			mdata["type"] = "[M.type]"
			if(M.client)
				mdata["client"] = M.client.key
			logdata[++logdata.len] = mdata
		else if(isclient(arg))
			logdata[++logdata.len] = list("client"=arg:key)
		else if(istype(arg,/datum))
			logdata[++logdata.len] = list("datum"=args.type, "name"=args.vars["name"] || "null")
		else if(istype(arg,/list))
			logdata[++logdata.len] = arg
	built["log"] = logdata
	goonhub.StreamSend( "log", built )

/goonhub
	New()
		..()
		SPAWN_DBG(0)
			Connect()
	proc/Connect()
		var/ret = Send("check", list("apikey" = "something","servername" = (config.server_name ? replacetext(config.server_name, "#", "") : "GOON Unnamed")), 1)
		if(ret)
			available = 1
			session = ret["session"]

	proc/Send(var/cmd, var/list/data, var/override = 0)
		//if(!available && !override) return
		/*var/ret = world.Export( "byond://[server]?[json_encode(list("cmd"=cmd,"data"=data,"session"=session))]", null, 1 )
		if(!ret) return
		try{
			return json_decode(ret)
		}catch(var/ex){
			ex=ex
			return null
		}*/
	proc/Fire(var/cmd, var/list/data)
		if(!available) return
		SPAWN_DBG(0)
			Send(cmd,data)
	proc/StreamSend(var/cmd, var/list/data)
		if(streamspawn)
			Fire(cmd, data)
		else
			return Send(cmd,data)
	var
		available = 0
		server = "198.27.70.16:25565"
		session = ""
		streamspawn = 1
