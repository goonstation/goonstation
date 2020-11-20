///proc/boutput(dest,what)
//	dest<<what
#ifndef INCLUDE_BUGGY_LUA_SHIT
#error Somehow included the lua shit without INCLUDE_BUGGY_LUA_SHIT. You might've enabled it in the DME or something. Either turn it off or define INCLUDE_BUGGY_LUA_SHIT.
#endif
#warn BYOND Lua enabled. Server may crash.

#if 0//set to 1 to disable the debug console
//no actually don't do that since i don't statically link lua into the release build for some reason
var/bylua_bin = world.system_type == MS_WINDOWS ? "lua/ByondLua.dll" : "lua/byondlua.so"
#define LJ_DEBUG 0
#else
var/bylua_bin = world.system_type == MS_WINDOWS ? "lua/ByondLuaD.dll" : "lua/byondlua.so"
#define LJ_DEBUG 1
#endif
lua
	var/ReturnData = 0
	var/valid = 0
	New(var/list/libsToLoad)
		var/list/cfg = list()
		if(istype( libsToLoad ))
			cfg["libraries"] = cfg
		call(bylua_bin, "blua_newstate")("\ref[src]", json_encode(cfg))
		valid = 1
		RunString("BYINIT()")
	Del()
		call(bylua_bin, "blua_close")("\ref[src]")

	proc/ParseYield(var/list/yield, var/thread)
		//world << "Yield: [yield]"
		if(!yield || yield == "closed")
			//world << "Yield finished!"
			return 0//Success!
		if( copytext( yield, 1, 2 ) != "{" )
			CRASH("Lua Error: [yield]")
			return 0//just in case
		yield = json_decode(yield)

		if(yield["error"])
			CRASH(yield["error"])
			return 0
		else if(yield["ProcName"])
			return CallProc(yield["ProcName"], yield["ProcArgs"], thread)
		else if(!isnull(yield["ReturnData"]))
			//world << "Returning data [yield["ReturnData"]]"
			ReturnData=1//ugh
			return yield["ReturnData"]
		else
			boutput( world, "Unknown thing just happened!!! AAA" )
		return 0

	var/list/varcache = list()
	proc/LuaifyDatum(var/datum/d, var/nocap, var/force_assoc = 0)
		if(d == null) return null
		if(istype(d) || istype(d,/client) || d == world)
			var/typ = (d == world ? "/world" : (istype(d,/client) ? "/client" : d.type))
			if(!varcache[typ] || LJ_DEBUG)
				var/list/vc = list()
				if( istype(d) )
					for(var/v in d.vars)
						vc[v] = 1
					varcache[d.type] = vc
				else if(d == world)
					vc = list()
					for(var/k in worldvars) vc[k] = 1
					varcache["/world"] = vc
				else if(istype(d,/client))
					var/client/c = d
					vc = list()
					for(var/k in c.__vars) vc[k] = 1
					varcache["/client"] = vc
				return list("_ref"="\ref[d]", "_vars"=vc, "_type"="[typ]")
			else
				return list("_ref"="\ref[d]", "_type"="[typ]")
		else if(istype(d, /list))
			var/list/lisht = d
			var/list/vals = list()
			if(lisht.len <= 32 || nocap)
				if( force_assoc == 1 )
					for(var/k in lisht)
						vals[k] = LuaifyDatum(vals[k])
				else if(force_assoc == -1)
					for(var/k in lisht)
						vals[++vals.len] = LuaifyDatum(k)
				else
					for(var/k in lisht)
						if( lisht[k] == null )//lovely consistency in byonds foreach)
							vals[++vals.len] = LuaifyDatum(k)
						else
							lisht[k] = LuaifyDatum( vals[k] )
			return list("_ref"="\ref[d]", "_vars"=vals, "_list" = 1)
				//world << "RET:[ret]"
		return d
	proc/ToLua(what) return LuaifyDatum(what)
	proc/ReturnToLua(var/with, var/nolimit, var/assochack, var/thread)
		if(!thread)
			CRASH("Got no thread! OH GOD OH MAN! @ ReturnToLua")
		return call(bylua_bin, "blua_resume")("\ref[src]", thread, json_encode(list("ret" = LuaifyDatum(with,nolimit,assochack))))

	proc/ProcCall( var/name, var/list/argz )
		//overridable, but return ..() if you care about /proc/calls
		return call("/proc/[name]")(arglist(argz))

	proc/CallProc(var/name, var/list/argz, var/thread)
		//call("bylua.dll", "bylua_resume")("\ref[src]",
		//world << "Calling a prac"
		//world << "Calling [procs[name]] with [list2params(argz)]"
		var/a1isref = 0//lol.
		for(var/i = 1, i <= argz.len, i++)
			var/rg = argz[i]
			if(istype(rg,/list))
				if(rg["_ref"])
					if(i==1)a1isref=1//lol
					argz[i] = locate(rg["_ref"])
		if(a1isref)
			var/tgt = argz[1]
			if(!tgt)
				return "{\"error\":\"Object is NULL.\"}"
			switch(name)
				if("ObjVarGet")
					if(tgt == world)
						return ReturnToLua(world_index(argz[2]), 0, 0, thread)
					else if(hascall(tgt, "__index"))
						return ReturnToLua(tgt:__index(argz[2]), 0, 0, thread)
					else if(istype(tgt,/list))
						return ReturnToLua(tgt[argz[2]], 0, 0, thread)
					else if(istype(tgt,/datum))
						if(argz[2]=="contents")//hackhackhack
							return ReturnToLua(tgt:contents,0,-1, thread)
						else
							return ReturnToLua(tgt:vars[argz[2]],0,argz.len==3 && argz[3], thread)
				if("ObjVarSet")
					if(tgt == world)
						world_newindex(argz[2], argz[3])
						return ReturnToLua(0, 0, 0, thread)
					else if(hascall(tgt, "__index"))
						tgt:__newindex(argz[2], argz[3])
						return ReturnToLua(0, 0, 0, thread)
					else if(istype(tgt,/list))
						if(argz[2] == "#")
							tgt:len = argz[3]
						else
							tgt[argz[2]] = argz[3]
						return ReturnToLua(0, 0, 0, thread)
					else if(istype(tgt,/datum))
						tgt:vars[argz[2]] = argz[3]
						return ReturnToLua(0, 0, 0, thread)
				if("ObjProcCall")
					var/procname = argz[2]
					argz.Cut( 1, 3 )
					return ReturnToLua(call(tgt, procname)(arglist(argz)), 0, 0, thread)
				if("del")
					del(tgt)
					return ReturnToLua(1, 0, 0, thread)
				if("flick")
					flick( argz[2], tgt )
					return ReturnToLua(1, 0, 0, thread)

		switch(name)
			if("spawn")
				SPAWN_DBG(argz[1])
					ResumeVM(ReturnToLua(0), 0, 0, thread)
				return 0
			if("locate")
				switch(argz.len)
					if(3)
						return ReturnToLua(locate(argz[1], argz[2], argz[3]), 0, 0, thread)
					else
						return ReturnToLua(locate(argz[1]), 0, 0, thread)
			if("WorldPrint")
				boutput( world, argz[1] )
				return ReturnToLua(1, 0, 0, thread)
			if("clients")
				var/list/clis = list()
				for(var/client/c)
					clis[++clis.len] = c
				return ReturnToLua(clis,1, 0, thread)
			if("input")
				if(istype(argz[2],/list))
					var/list/thing = argz[2]
					return ReturnToLua(input(argz[1], argz[3], argz[4], argz[5]) in thing, 0, 0, thread)
				switch(argz[2])
					if("num")
						return ReturnToLua(input(argz[1], argz[3], argz[4], argz[5]) as num, 0, 0, thread)
					if("text")
						return ReturnToLua(input(argz[1], argz[3], argz[4], argz[5]) as text, 0, 0, thread)
					if("message")
						return ReturnToLua(input(argz[1], argz[3], argz[4], argz[5]) as message, 0, 0, thread)
				return ReturnToLua(0)
			if("alert")
				switch(argz.len)
					if(4)
						return ReturnToLua(alert( argz[1], argz[2], argz[3], argz[4] ), 0, 0, thread)
					if(5)
						return ReturnToLua(alert( argz[1], argz[2], argz[3], argz[4], argz[5] ), 0, 0, thread)
					if(6)
						return ReturnToLua(alert( argz[1], argz[2], argz[3], argz[4], argz[5], argz[6] ), 0, 0, thread)
				return ReturnToLua(0, 0, 0, thread)
			if("new")
				var/typ = text2path(argz[1])
				if(!typ)
					return ReturnToLua(0, 0, 0, thread)
				argz.Cut( 1, 2 )
				return ReturnToLua(new typ(arglist(argz)), 0, 0, thread)
			else
				return ReturnToLua(ProcCall( name, argz ), 0, 0, thread)
		return ReturnToLua(0, 0, 0, thread)
	proc/PullOut(var/thread)
		if(!thread)
			CRASH("Got no thread! OH GOD OH MAN! @ Pullout")
		/*var/ret = */call(bylua_bin, "blua_pullout")("\ref[src]", thread)
	proc/ResumeVM(var/ret, var/thread)
		while(1)
			try
				ret = ParseYield(ret, thread)
				if(ReturnData)
					ReturnData=0
					return ret//ugh
				if(!ret)
					break
			catch(var/exception/e)
				PullOut(thread)
				throw e;//honk
	proc/RunString(var/code)
		var/thread = call(bylua_bin, "blua_newthread")("\ref[src]")
		if(!thread) CRASH("Failed to allocate thread! Not sure why, but don't go asking questions!")
		var/ret = call(bylua_bin, "blua_runstring")("\ref[src]", thread, code)
		if(ret && copytext(ret,1,2) != "{")
			PullOut(thread)
			CRASH(ret)
		if(ret)
			ResumeVM(ret, thread)
	proc/RunHook(var/name, var/list/data)
		try{
			return SendData( list("cmd" = "hook", "hook" = name, "data" = data) )
		}catch(/*var/exception/e*/){
			//todo
			return
		}
	proc/SendData(var/data)
		var/thread = call(bylua_bin, "blua_newthread")("\ref[src]")
		if(!thread) CRASH("Failed to allocate thread! Not sure why, but don't go asking questions!")
		var/ret = call(bylua_bin, "blua_senddata")("\ref[src]", thread, json_encode(data))//Manually call LuaifyDatum if you want.
		if(ret && copytext(ret,1,2) != "{")
			PullOut( thread )
			CDBG3("[ret]")
			CRASH(ret)
		if(ret)
			return ResumeVM(ret, thread)

//the below was autogenerated.
//in hindsight, this wasn't a good idea.
/client/proc/__index(var/k)
	switch(k)
		if("address") return src.address
		if("authenticate") return src.authenticate
		if("bounds") return src.bounds
		if("byond_version") return src.byond_version
		if("CGI") return src.CGI
		if("ckey") return src.ckey
		if("color") return src.color
		if("command_text") return src.command_text
		if("connection") return src.connection
		if("control_freak") return src.control_freak
		if("computer_id") return src.computer_id
		if("default_verb_category") return src.default_verb_category
		if("dir") return src.dir
		if("edge_limit") return src.edge_limit
		if("eye") return src.eye
		if("gender") return src.gender
		if("images") return src.images
		if("inactivity") return src.inactivity
		if("key") return src.key
		if("lazy_eye") return src.lazy_eye
		if("mob") return src.mob
		if("mouse_pointer_icon") return src.mouse_pointer_icon
		if("perspective") return src.perspective
		if("pixel_x") return src.pixel_x
		if("pixel_y") return src.pixel_y
		if("pixel_z") return src.pixel_z
		if("glide_size") return src.glide_size
		if("preload_rsc") return src.preload_rsc
		if("screen") return src.screen
		if("script") return src.script
		if("show_map") return src.show_map
		if("show_popup_menus") return src.show_popup_menus
		if("show_verb_panel") return src.show_verb_panel
		if("statobj") return src.statobj
		if("statpanel") return src.statpanel
		if("verbs") return src.verbs
		if("view") return src.view
		if("virtual_eye") return src.virtual_eye
		else CRASH("Bad index [k]")
/client/proc/__newindex(var/k, var/v)
	switch(k)
		//if("address") src.address = v
		//if("authenticate") src.authenticate = v
		//if("bounds") src.bounds = v
		//if("byond_version") src.byond_version = v
		if("CGI") src.CGI = v
		if("ckey") src.ckey = v
		if("color") src.color = v
		if("command_text") src.command_text = v
		//if("connection") src.connection = v
		if("control_freak") src.control_freak = v
		//if("computer_id") src.computer_id = v
		if("default_verb_category") src.default_verb_category = v
		if("dir") src.set_dir(v)
		if("edge_limit") src.edge_limit = v
		if("eye") src.eye = v
		//if("gender") src.gender = v
		if("images") src.images = v
		//if("inactivity") src.inactivity = v
		if("key") src.key = v
		if("lazy_eye") src.lazy_eye = v
		if("mob") src.mob = v
		if("mouse_pointer_icon") src.mouse_pointer_icon = v
		if("perspective") src.perspective = v
		if("pixel_x") src.pixel_x = v
		if("pixel_y") src.pixel_y = v
		if("pixel_z") src.pixel_z = v
		if("glide_size") src.glide_size = v
		if("preload_rsc") src.preload_rsc = v
		if("screen") src.screen = v
		if("script") src.script = v
		if("show_map") src.show_map = v
		if("show_popup_menus") src.show_popup_menus = v
		if("show_verb_panel") src.show_verb_panel = v
		if("statobj") src.statobj = v
		if("statpanel") src.statpanel = v
		if("verbs") src.verbs = v
		if("view") src.view = v
		if("virtual_eye") src.virtual_eye = v
		else CRASH("Bad index [k]")

/client/var/__vars = list("address","authenticate","bounds","byond_version","CGI","ckey","color","command_text","connection","control_freak","computer_id","default_verb_category","dir","edge_limit","eye","gender","images","inactivity","key","lazy_eye","mob","mouse_pointer_icon","perspective","pixel_x","pixel_y","pixel_z","glide_size","preload_rsc","screen","script","show_map","show_popup_menus","show_verb_panel","statobj","statpanel","verbs","view","virtual_eye")

/proc/world_index(k)
	switch(k)
		if("address") return world.address
		if("area") return world.area
		if("cache_lifespan") return world.cache_lifespan
		if("contents") return world.contents
		if("cpu") return world.cpu
		if("executor") return world.executor
		if("fps") return world.fps
		if("game_state") return world.game_state
		if("host") return world.host
		//if("hub") return world.hub
		//if("hub_password") return world.hub_password
		if("icon_size") return world.icon_size
		if("internet_address") return world.internet_address
		if("log") return world.log
		if("loop_checks") return world.loop_checks
		if("map_format") return world.map_format
		if("maxx") return world.maxx
		if("maxy") return world.maxy
		if("maxz") return world.maxz
		if("mob") return world.mob
		if("name") return world.name
		if("params") return world.params
		if("port") return world.port
		if("realtime") return world.realtime
		if("reachable") return world.reachable
		if("sleep_offline") return world.sleep_offline
		if("status") return world.status
		if("system_type") return world.system_type
		if("tick_lag") return world.tick_lag
		if("tick_usage") return world.tick_usage
		if("turf") return world.turf
		if("time") return world.time
		if("timeofday") return world.timeofday
		//if("url") return world.url
		if("version") return world.version
		if("view") return world.view
		if("visibility") return world.visibility
/proc/world_newindex(var/k,var/v)
	switch(k)
		if("address") world.address = v
		//if("area") world.area = v
		//if("cache_lifespan") world.cache_lifespan = v
		//if("contents") world.contents = v
		//if("cpu") world.cpu = v
		if("executor") world.executor = v
		if("fps") world.fps = v
		if("game_state") world.game_state = v
		//if("host") world.host = v
		//if("hub") world.hub = v
		//if("hub_password") world.hub_password = v
		//if("icon_size") world.icon_size = v
		if("internet_address") world.internet_address = v
		if("log") world.log = v
		if("loop_checks") world.loop_checks = v
		//if("map_format") world.map_format = v
		if("maxx") world.maxx = v
		if("maxy") world.maxy = v
		if("maxz") world.maxz = v
		if("mob") world.mob = v
		if("name") world.name = v
		if("params") world.params = v
		//if("port") world.port = v
		if("realtime") world.realtime = v
		//if("reachable") world.reachable = v
		if("sleep_offline") world.sleep_offline = v
		if("status") world.status = v
		//if("system_type") world.system_type = v
		if("tick_lag") world.tick_lag = v
		//if("tick_usage") world.tick_usage = v
		//if("turf") world.turf = v
		if("time") world.time = v
		if("timeofday") world.timeofday = v
		//if("url") world.url = v
		if("version") world.version = v
		//if("view") world.view = v
		if("visibility") world.visibility = v

/var/list/worldvars = list("address","area","cache_lifespan","contents","cpu","executor","fps","game_state","host","icon_size","internet_address","log","loop_checks","map_format","maxx","maxy","maxz","mob","name","params","port","realtime","reachable","sleep_offline","status","system_type","tick_lag","tick_usage","turf","time","timeofday","version","view","visibility")
var/global/lua/L = new
/client/proc/RunLuaString(var/code as message)
	set name = "Run Lua Code"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)

	admin_only
	if( !IsSecureAuthorized() )
		boutput( usr, "<span class='alert'>You are not authorized to use this command.</span>" )
	try//
		L.RunString("local me = locate(\"\ref[usr]\");local client=locate('\ref[src]');local function print(str) BYOND.CallProc('boutput', me, tostring(str)) end;local function printf(s,...)world(s:format(...))end;[code]")
	catch(var/exception/e)
		boutput( usr, "<span class='alert'>Error: [e.name]</span>" )
