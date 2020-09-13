var/global/debug_messages = 0

/client/proc/debug_messages()
	set desc = "Toggle debug messages."
	set name = "HDM" // debug ur haines
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only

	debug_messages = !(debug_messages)
	logTheThing("admin", usr, null, "toggled debug messages [debug_messages ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled debug messages [debug_messages ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled debug messages [debug_messages ? "on" : "off"]")

/client/proc/debug_deletions()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Debug Deletions"
	admin_only
	var/deletedJson = "\[{path:null,count:0}"
	var/deletionWhat = "Deleted Object Counts:"
	#ifdef DELETE_QUEUE_DEBUG
	for(var/path in deletedObjects)
		deletedJson += ",{path:\"[path]\",count:[deletedObjects[path]]}\n"
	#else
	deletionWhat = "Detailed counts disabled."
	#endif

	var/list/buckets = list()
	var/dp = global.delqueue_pos
	var/cp = (global.delqueue_pos + DELQUEUE_WAIT) % DELQUEUE_SIZE + 1
	var/total = 0
	for (var/b = 1; b <= DELQUEUE_SIZE; b++)
		buckets += "<li style='[b == dp ? "background-color: #fcc;": ( b == cp ? "background-color: #bbf;" : "")]'><span style='display: inline-block; width: 6em; text-align: right;'>[global.delete_queue_2[b].len]</span><span style='display: inline-block; height: 1em; width: [round(global.delete_queue_2[b].len / 2.5)]px; background: black;'></span></li>"
		total += global.delete_queue_2[b].len

	deletedJson += "]"
	var/html = {"<!doctype html><html>
	<head><title>Deletions debug</title>
	<script type="text/javascript">
	function display() {
		var i, html,
			listing = document.getElementById('listing'),
			deletedObjects = [deletedJson].sort(function(a, b) { return b.count - a.count; });
		html = '';
		var total = 0;
		for(i = 0;i < deletedObjects.length; i++) {
			total += deletedObjects\[i].count;
			html += '<li><strong>' + deletedObjects\[i].path
				+ '</strong>: ' + deletedObjects\[i].count.toString()
				+ '</li>';
		}
		html = '<li><span style="color:red;font-weight:bold">Total</span>: ' + total.toString() + "</li>" + html;
		listing.innerHTML = html;
	}
	</script>
	</head><body onload="display()">
	<h1>Delete Queue Length: [total]</h1>
	<h3>bukkets</h3>
	<ol>[buckets.Join("")]</ol>
	<h1>[deletionWhat]</h1>
	<ul id="listing"></ul>
	</body></html>"}
	src.Browse(html, "window=deletedObjects;size=400x600")

#ifdef IMAGE_DEL_DEBUG
/client/proc/debug_image_deletions_clear()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Clear Image Deletion Log"
	admin_only
	deletedImageData = new

/client/proc/debug_image_deletions()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Debug Image Deletions"
	admin_only
	#ifdef IMAGE_DEL_DEBUG
	var/deletedJson = "\[''"
	var/deletionWhat = "Deleted Image data:"
	var/deletionCounts = "Deleted icon_state counts:<br>"
	for(var/i = 1,i <= deletedImageIconStates.len, i++)
		deletionCounts += "[deletedImageIconStates[i]]: [deletedImageIconStates[deletedImageIconStates[i]]]<br>"

	for(var/i = 1,i <= deletedImageData.len, i++)
		deletedJson += ",'[deletedImageData[i]]'\n"
	deletedJson += "]"
	var/html = {"<!doctype html><html>
	<head><title>Image data deletion debug</title>
	<script type="text/javascript">
	function display() {
		var i, html,
			listing = document.getElementById('listing'),
			deletedObjects = [deletedJson].sort(function(a, b) { return b.count - a.count; });
		html = '';
		for(i = 0;i < deletedObjects.length; i++) {
			html += '<li>' + deletedObjects\[i] + '</li>';
		}
		listing.innerHTML = html;
	}
	</script>
	</head><body onload="display()">
	<h1>[deletionWhat]</h1>
	<ul id="listing"></ul>
	[deletionCounts]
	</body></html>"}
	#else
	var/html = "<h1>Image deletion debug disabled</h1>"
	#endif
	src.Browse(html, "window=deletedImageData;size=400x600")
#endif

/client/proc/debug_pools()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Debug Object Pools"
	admin_only

	#ifndef DETAILED_POOL_STATS
	var/poolsJson = "\[{pool:null,count:0}"
	for(var/pool in object_pools)
		var/list/poolList = object_pools[pool]
		poolsJson += ",{pool:'[pool]',count:[poolList.len]}\n"
	poolsJson += "]"
	var/html = {"<!doctype html><html>
	<head><title>object pool counts</title>
	<script type="text/javascript">
	function display() {
		var i, html,
			listing = document.getElementById('listing'),
			objectPools = [poolsJson].sort(function(a, b) { return b.count - a.count; });
		html = '';
		var total = 0;
		for(i = 0;i < objectPools.length; i++) {
			total += objectPools\[i].count;
			html += '<li><strong>' + objectPools\[i].pool
				+ '</strong>: ' + objectPools\[i].count.toString()
				+ '</li>';
		}
		html = '<li><span style="color:red;font-weight:bold">Total</span>: ' + total.toString() + "</li>" + html;
		listing.innerHTML = html;
	}
	</script>
	</head><body onload="display()">
	<h1>Object Pool Counts:</h1>
	<ul id="listing"></ul>
	</body></html>"}
	#else
	var/poolsJson = getPoolingJson()
	var/html = {"<!doctype html><html>
				<head><title>object pool counts</title>
				<style>
					table {
						border: 1px solid black;
						border-collapse:collapse;
					}
					th, td {
						padding:5px;
						border: 1px solid black;
					}
				</style>
				</head><body>
				<h1>Object Pool Counts:</h1>
				<span id="listing"></span>
				<script type="text/javascript">
					function display() {
						var i, html,
							listing = document.getElementById('listing'),
							objectPools = [poolsJson].sort(function(a, b) { return b.count - a.count; });
						html = '';
						var total = 0;
						for(i = 0;i < objectPools.length; i++) {
							var p = objectPools\[i];
							total += p.count;
							html += '<tr><td>' + p.path + '</td><td>' + p.count.toString() + '</td><td>' + p.hits.toString() + '</td><td>' + p.misses.toString() + '</td><td>' + p.poolings.toString() + '</td><td>' + p.unpoolings.toString() + '</td><td>' + p.evictions.toString() + '</td></tr>';
						}
						html = '<table><tr><th>Path</th><th>Count</th><th>Hits</th><th>Misses</th><th>Poolings</th><th>Unpoolings</th><th>Evictions</th></tr>' + html + '<tr><th>Total:</th><td>' + total.toString() + '</td></tr></table>';
						listing.innerHTML = html;
					};
				display();
				</script>
				</body></html>"}
	#endif
	src.Browse(html, "window=poolCounts;size=400x800")

/client/proc/call_proc_atom(atom/target as null|area|obj|mob|turf in world)
	set name = "Call Proc"
	set desc = "Calls a proc associated with the targeted atom"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	admin_only
	if (!target)
		return
	doCallProc(target)

/client/proc/call_proc_all(var/typename as null|text)
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Call Proc All"
	set desc = "Call proc on all instances of a type, will probably slow shit down"

	if (!typename)
		return
	var/thetype = get_one_match(typename, /atom)
	if (thetype)
		var/counter = 0
		var/procname = input("Procpath","path:", null) as text
		var/argnum = input("Number of arguments:","Number", 0) as num
		var/list/listargs = list()

		for(var/i=0, i<argnum, i++)
			var/class = input("Type of Argument #[i]","Variable Type", null) in list("text","num","type","reference","mob reference","reference atom at current turf","icon","file","-cancel-")
			switch(class)
				if("-cancel-")
					return

				if("text")
					listargs += input("Enter new text:","Text",null) as null|text

				if("num")
					listargs += input("Enter new number:","Num", 0) as null|num

				if("type")
					listargs += input("Enter type:","Type", null) in null|typesof(/obj,/mob,/area,/turf)

				if("reference")
					listargs += input("Select reference:","Reference", null) as null|mob|obj|turf|area in world

				if("mob reference")
					listargs += input("Select reference:","Reference", null) as null|mob in world

				if("reference atom at current turf")
					var/list/possible = list()
					var/turf/T = get_turf(usr)
					possible += T.loc
					possible += T
					for (var/atom/A in T)
						possible += A
						for (var/atom/B in A)
							possible += B
					listargs += input("Select reference:","Reference", null) as mob|obj|turf|area in possible

				if("file")
					listargs += input("Pick file:","File", null) as null|file

				if("icon")
					listargs += input("Pick icon:","Icon", null) as null|icon
			if (listargs == null) return

		for (var/atom/theinstance in world)
			if (!istype(theinstance, thetype))
				continue
			counter++
			if(listargs.len)
				call(theinstance,procname)(arglist(listargs))
			else
				call(theinstance,procname)()

			LAGCHECK(LAG_LOW)

		boutput(usr, "<span class='notice'>'[procname]' called on [counter] instances of '[typename]'</span>")
		message_admins("<span class='alert'>Admin [key_name(src)] called '[procname]' on all instances of '[typename]'</span>")
		logTheThing("admin", src, null, "called [procname] on all instances of [typename]")
		logTheThing("diary", src, null, "called [procname] on all instances of [typename]")
	else
		boutput(usr, "No type matches for [typename]")
		return




/client/proc/call_proc()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Advanced ProcCall"
	admin_only
	var/target = null

	switch (alert("Proc owned by obj?",,"Yes","No","Cancel"))
		if ("Cancel")
			return
		if ("Yes")
			target = input("Enter target:","Target",null) as null|obj|mob|area|turf in world
			if (!target)
				return
		if ("No")
			target = null
	doCallProc(target)

/proc/doCallProc(target = null, procname = null) // also accepts actual proc
	var/returnval = null
	if(isnull(procname))
		procname = input("Procpath (ex. bust_lights)","path:", null) as null|text
	if (isnull(procname))
		return

	var/list/listargs = get_proccall_arglist()

	var/list/name_list

	if(istext(procname))
		if(copytext(procname, 1, 6) == "proc/")
			procname = copytext(procname, 6)
		else if(copytext(procname, 1, 7) == "/proc/")
			procname = copytext(procname, 7)
		name_list = list(procname, "proc/" + procname, "/proc/" + procname, "verb/" + procname)
	else // is an actual proc, not a name
		name_list = list(procname)

	if(target)
		boutput(usr, "<span class='notice'>Calling '[procname]' with [islist(listargs) ? listargs.len : "0"] arguments on '[target]'</span>")
	else
		boutput(usr, "<span class='notice'>Calling '[procname]' with [islist(listargs) ? listargs.len : "0"] arguments</span>")

	var/success = FALSE
	for(var/actual_proc in name_list)
		try
			if (target)
				if(islist(listargs) && listargs.len)
					returnval = call(target,actual_proc)(arglist(listargs))
				else
					returnval = call(target,actual_proc)()
			else
				if(islist(listargs) && listargs.len)
					returnval = call(actual_proc)(arglist(listargs))
				else
					returnval = call(actual_proc)()
			success = TRUE
			break
		catch(var/exception/e)
			if(e.name != "bad proc" && copytext(e.name, 1, 15) != "undefined proc") // fuck u byond
				boutput(usr, "<span class='alert'>Exception occured! <a style='color: #88f;' href='byond://winset?command=View-Runtimes'>View Runtimes</a></span>")
				throw e

	if(!success)
		boutput(usr, "<span class='alert'>Proc [procname] not found!</span>")
		return

	var/pretty_returnval = returnval
	if(istype(returnval, /datum) || istype(returnval, /client))
		pretty_returnval = "<a href='byond://?src=\ref[usr.client];Refresh=\ref[returnval]'>[returnval] \ref[returnval]</a>"
	else
		pretty_returnval = json_encode(returnval)
	boutput(usr, "<span class='notice'>Proc returned: [pretty_returnval]</span>")
	return

/proc/get_proccall_arglist()
	var/argnum = input("Number of arguments:","Number", 0) as null|num
	var/list/listargs = list()
	if (!argnum)
		return listargs
	for (var/i=0, i<argnum, i++)
		var/class = input("Type of Argument #[i]","Variable Type", null) as null|anything in list("text","num","type","reference","mob reference","reference atom at current turf","icon","color","file","the turf of which you are on top of right now")
		if(!class)
			break
		switch(class)
			if ("cancel")
				break
			if ("text")
				listargs += input("Enter new text:","Text",null) as null|text

			if ("num")
				listargs += input("Enter new number:","Num", 0) as null|num

			if ("type")
				boutput(usr, "<span class='notice'>Type part of the path of the type.</span>")
				var/typename = input("Part of type path.", "Part of type path.", "/obj") as null|text
				if (typename)
					var/match = get_one_match(typename, /datum)
					if (match)
						listargs += match

			if ("reference")
				listargs += input("Select reference:","Reference", null) as null|mob|obj|turf|area in world

			if ("mob reference")
				listargs += input("Select reference:","Reference", null) as null|mob in world

			if ("the turf of which you are on top of right now")
				listargs += get_turf(usr)

			if ("reference atom at current turf")
				var/list/possible = list()
				var/turf/T = get_turf(usr)
				possible += T.loc
				possible += T
				for (var/atom/A in T)
					possible += A
					for (var/atom/B in A)
						possible += B
				listargs += input("Select reference:","Reference", null) as mob|obj|turf|area in possible

			if ("file")
				listargs += input("Pick file:","File", null) as null|file

			if ("icon")
				listargs += input("Pick icon:","Icon", null) as null|icon

			if ("color")
				listargs += input("Pick color:","Color") as null|color

			if ("turf by coordinates")
				var/x = input("X coordinate", "Set to turf at \[_, ?, ?\]", 1) as null|num
				var/y = input("Y coordinate", "Set to turf at \[[x], _, ?\]", 1) as null|num
				var/z = input("Z coordinate", "Set to turf at \[[x], [y], _\]", 1) as null|num
				var/turf/T = locate(x, y, z)
				if (istype(T))
					listargs += T
				else
					boutput(usr, "<span class='alert'>Invalid coordinates!</span>")

			else
				continue

		if (listargs == null)
			return list()
	return listargs

/client/proc/cmd_admin_mobileAIize(var/mob/M in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Mobile AIize"
	set popup_menu = 0
	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		logTheThing("admin", src, M, "has mobile-AIized [constructTarget(M,"admin")]")
		logTheThing("diary", src, M, "has mobile-AIized [constructTarget(M,"diary")]", "admin")
		SPAWN_DBG(1 SECOND)
			M:AIize(1)

	else
		alert("Invalid mob")

/client/proc/cmd_admin_makeai(var/mob/M in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Make AI"
	set popup_menu = 0
	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/turf/new_loc
		if (job_start_locations["AI"])
			new_loc = pick(job_start_locations["AI"])
		if (new_loc)
			boutput(M, "<span class='notice'><B>You have been teleported to your new starting location!</B></span>")
			M.set_loc(new_loc)
			M.buckled = null
		message_admins("<span class='alert'>Admin [key_name(src)] AIized [key_name(M)]!</span>")
		logTheThing("admin", src, M, "AIized [constructTarget(M,"admin")]")
		logTheThing("diary", src, M, "AIized [constructTarget(M,"diary")]", "admin")
		return H.AIize()

	else
		alert("This is untested so it will probably break! Good luck.")
		return M.AIize()

/client/proc/cmd_admin_makecyborg(var/mob/M in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Make Cyborg"
	set popup_menu = 0
	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		return H.Robotize_MK2()

	else
		alert("This only works on human mobs.")

/client/proc/cmd_admin_makeghostdrone(var/mob/M in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Make Ghostdrone"
	set popup_menu = 0
	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		return droneize(H, 0)

	else
		alert("This only works on human mobs.")

/* Just use the set traitor dialog thing
/client/proc/cmd_admin_changelinginize(var/mob/M in world)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Make Changeling"
	set popup_menu = 0
	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M) && M.mind != null)
		logTheThing("admin", src, M, "has made [constructTarget(M,"admin")] a changeling.")
		logTheThing("diary", src, M, "has made [constructTarget(M,"diary")] a changeling.", "admin")
		SPAWN_DBG(1 SECOND)
			M.mind.absorbed_dna[M.bioHolder] = M.real_name
			M.make_changeling()
	else
		alert("Invalid mob")
*/

/client/proc/cmd_debug_del_all()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Del-All"

	// to prevent REALLY stupid deletions
	var/blocked = list(/obj, /mob, /mob/living, /mob/living/carbon, /mob/living/carbon/human)
	var/hsbitem = input("Enter atom path:","Delete",null) as null|text
	var/background =  alert("Run the process in the background?",,"Yes (High)","Yes (Low)" ,"No")

	hsbitem = text2path(hsbitem)
	for(var/V in blocked)
		if(V == hsbitem)
			boutput(usr, "Can't delete that you jerk!")
			return
	if(hsbitem)
		src.delete_state = DELETE_RUNNING
		src.verbs += /client/proc/cmd_debug_del_all_cancel
		src.verbs += /client/proc/cmd_debug_del_all_check
		boutput(usr, "Deleting [hsbitem]...")
		var/numdeleted = 0
		for(var/atom/O in world)
			if(istype(O, hsbitem))
				del(O)
				numdeleted++
				if(background == "Yes (Low)")
					LAGCHECK(LAG_LOW)
				else if(background == "Yes (High)")
					LAGCHECK(LAG_REALTIME)
			if (src.delete_state == DELETE_STOP)
				break
			else if (src.delete_state == DELETE_CHECK)
				boutput(usr, "Deleted [numdeleted] instances of [hsbitem] so far.")
				src.delete_state = DELETE_RUNNING

		if(numdeleted == 0) boutput(usr, "No instances of [hsbitem] found!")
		else boutput(usr, "Deleted [numdeleted] instances of [hsbitem]!")
		logTheThing("admin", src, null, "has deleted [numdeleted] instances of [hsbitem].")
		logTheThing("diary", src, null, "has deleted [numdeleted] instances of [hsbitem].", "admin")
		message_admins("[key_name(src)] has deleted [numdeleted] instances of [hsbitem].")
		src.verbs -= /client/proc/cmd_debug_del_all_cancel
		src.verbs -= /client/proc/cmd_debug_del_all_check
		src.delete_state = DELETE_STOP

// cancels your del_all in process, if one is running
/client/proc/cmd_debug_del_all_cancel()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Del-All Cancel"

	src.delete_state = DELETE_STOP

// makes del_all print how much is currently deleted
/client/proc/cmd_debug_del_all_check()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Del-All Progress"

	src.delete_state = DELETE_CHECK

// fuck this
// fuck
// GO AWAY
/client/proc/cmd_explosion(var/turf/T in world)
	set name = "Create Explosion"
	set popup_menu = 0

	var/esize = input("Enter POWER of Explosion\nPlease use decimals for greater accuracy!)","Explosion Power",null) as num|null
	if (!esize)
		return
	var/bris = input("Enter BRISANCE of Explosion\nLeave it on 1 if you have no idea what this is.", "Brisance", 1) as num

	logTheThing("admin", src, null, "created an explosion (power [esize], brisance [bris]) at [log_loc(T)].")
	logTheThing("diary", src, null, "created an explosion (power [esize], brisance [bris]) at [log_loc(T)].", "admin")
	message_admins("[key_name(src)] has created an explosion (power [esize], brisance [bris]) at [log_loc(T)].")

	explosion_new(null, T, esize, bris)
	return
/*
/client/proc/cmd_ultimategrife()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "ULTIMATE GRIFE"

	switch(alert("Holy shit are you sure?! (also the server will lag for a few seconds)",,"Yes","No"))
		if("Yes")
			for(var/turf/simulated/wall/W in world)
				new /obj/machinery/crusher(get_turf(W))
				qdel(W)

			for(var/turf/simulated/wall/r_wall/RW in world)
				new /obj/machinery/crusher(get_turf(RW))
				qdel(RW)

			logTheThing("admin", src, null, "has turned every wall into a crusher! God damn.")
			logTheThing("diary", src, null, "has turned every wall into a crusher! God damn.", "admin")
			message_admins("[key_name(src)] has turned every wall into a crusher! God damn.")

			alert("Uh oh.")

		if("No")
			alert("Thank god for that.")
*/
/client/proc/cmd_debug_mutantrace(var/mob/mob in world)
	set name = "Change Mutant Race"
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set popup_menu = 0
	if(!ishuman(mob))
		alert("[mob] is not a human mob!")
		return

	var/mob/living/carbon/human/H = mob

	var/race = input("Select a mutant race","Races",null) as null|anything in typesof(/datum/mutantrace)

	if (!race)
		return

	if(H.mutantrace)
		qdel(H.mutantrace)
	H.set_mutantrace(race)
	H.set_face_icon_dirty()
	H.set_body_icon_dirty()
	H.update_clothing()

/client/proc/view_save_data(var/mob/mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "View Save Data"
	set desc = "Displays the save data for any mob with an associated client."

	if(!mob.client)
		boutput(src, "That mob has no client!")
		return
	var/datum/preferences/prefs = new
	prefs.savefile_load(mob.client)

	var/title = "[mob.client]'s Save Data"
	var/body = ""

	body += "<ol>"

	var/list/names = list()
	for (var/V in prefs.vars)
		names += V

	names = sortList(names)

	for (var/V in names)
		body += debug_variable(V, prefs.vars[V], 0)

	body += "</ol>"

	var/html = "<html><head>"
	if (title)
		html += "<title>[title]</title>"
	html += {"<style>
body
{
	font-family: Verdana, sans-serif;
	font-size: 9pt;
}
.value
{
	font-family: "Courier New", monospace;
	font-size: 8pt;
}
</style>"}
	html += "</head><body>"
	html += body
	html += "</body></html>"

	usr.Browse(html, "window=variables\ref[prefs]")

/client/proc/check_gang_scores()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Check Gang Scores"

	if(!(ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/gang)))
		alert("It isn't gang mode, dummy!")
		return

	boutput(usr, "Gang scores:")

	for(var/datum/gang/G in ticker.mode:gangs)
		boutput(usr, "[G.gang_name]: [G.gang_score()] ([G.num_areas_controlled()] areas)")

/client/proc/scenario()
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Profiling Scenario"

	var/selected = input("Select scenario", "Do not use on a live server for the love of god", "Cancel") in list("Cancel", "Disco Inferno", "Chemist's Delight", "Viscera Cleanup Detail")
	switch (selected)
		if ("Disco Inferno")
			for (var/turf/T in landmarks[LANDMARK_BLOBSTART])
				var/datum/gas_mixture/gas = unpool(/datum/gas_mixture)
				gas.toxins = 10000
				gas.oxygen = 10000
				gas.temperature = 10000
				T.assume_air(gas)
			for (var/obj/machinery/door/airlock/maintenance/door in by_type[/obj/machinery/door])
				LAGCHECK(LAG_LOW)
				qdel(door)
			for (var/obj/machinery/door/firedoor/door in by_type[/obj/machinery/door])
				LAGCHECK(LAG_LOW)
				qdel(door)
		if ("Chemist's Delight")
			for (var/turf/simulated/floor/T in world)
				LAGCHECK(LAG_LOW)
				if ((T.x*T.y) % 50 == 0)
					T.reagents = new(300)
					T.reagents.my_atom = T
					T.reagents.add_reagent("argine", 100)
					T.reagents.add_reagent("nitrogen", 50)
					T.reagents.add_reagent("plasma", 50)
					T.reagents.add_reagent("water", 50)
					T.reagents.add_reagent("oxygen", 50)
					T.reagents.handle_reactions()
		if ("Viscera Cleanup Detail")
			for (var/turf/simulated/floor/T in world)
				LAGCHECK(LAG_LOW)
				if ((T.x*T.y) % 10 == 0)
					gibs(T)
/*
/client/proc/icon_print_test()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Icon printing test"
	set desc = "Tests printing all the objects around you with or without icons to test 507"

	var/with_icons = alert("Print with icons?", "Icon Test","Yes", "No", "Cancel")
	if (with_icons == "Cancel") return
	with_icons = with_icons == "Yes"
	for(var/obj/O in range(usr,5))
		if(with_icons)
			boutput(usr, "[bicon(O)] : [O]")
		else
			boutput(usr, "NI : [O]")
*/

/client/proc/debug_reaction_list()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Debug Reaction Structure"
	set desc = "Checks the current reaction structure."

	var/T = "<h1>Reaction Structure</h1><hr>"
	for(var/reagent in total_chem_reactions)
		T += "<h3>[reagent]</h3>"
		for(var/datum/chemical_reaction/R in total_chem_reactions[reagent])
			T += "   - [R.type]<br>"
		T+="<hr>"

	usr.Browse(T, "window=browse_reactions")

/client/proc/debug_reagents_cache()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Debug Reagents Cache"
	set desc = "Check which things are in the reaction cache."

	var/T = "<h1>Reagents Cache</h1><hr><table border=1><tr><td><B><center>ID</center></B></td><td><B><center>Name</center></B></td><td><B><center>Type</center></B></td>"
	for(var/reagent in reagents_cache)
		var/datum/reagent/R = reagents_cache[reagent]
		T += "<tr><td>[reagent]</td><td>[R]</td><td>[R.type]</td></tr>"
	T += "</table>"
	usr.Browse(T, "window=browse_reagents;size=800x400")

/atom/proc/debug_check_possible_reactions()
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Check Possible Reactions"
	set desc = "Checks which things could possibly be made from reagents in this thing."

	if(src.reagents && src.reagents.total_volume)
		var/T = "<TT><h1>Possible Reactions</h1><center>for reagents inside<BR><B>[src]</b></center><hr>"
		if(src.reagents.possible_reactions.len)
			for(var/datum/chemical_reaction/CR in src.reagents.possible_reactions)
				T += "  -  [CR.type]<br>"
		else
			T += "Nothing at all!"

		usr.Browse(T, "window=possible_chem_reactions_in_thing")
	else
		usr.show_text("\The [src] does not have a reagent holder or is empty.", "red")

/client/proc/showMyCoords(var/x, var/y, var/z)
	return replacetext(showCoords(x,y,z), "%admin_ref%", "\ref[src.holder]")

/client/proc/print_instance(var/atom/theinstance)
	if (isarea(theinstance))
		var/turf/T = locate(/turf) in theinstance
		if (!T)
			boutput(usr, "<span class='notice'>[theinstance] (no turfs in area).</span>")
		else
			boutput(usr, "<span class='notice'>[theinstance] including [showMyCoords(T.x, T.y, T.z)].</span>")
	else if (isturf(theinstance))
		boutput(usr, "<span class='notice'>[theinstance] at [showMyCoords(theinstance.x, theinstance.y, theinstance.z)].</span>")
	else
		var/turf/T = get_turf(theinstance)
		var/in_text = ""
		var/atom/Q = theinstance.loc
		while (Q && Q != T)
			in_text += " in [Q]"
			Q = Q.loc
		boutput(usr, "<span class='notice'>[theinstance][in_text] at [showMyCoords(T.x, T.y, T.z)]</span>")

/client/proc/find_one_of(var/typename as text)
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set name = "Find One"
	set desc = "Show the location of one instance of type."

	var/thetype = get_one_match(typename, /atom)
	if (thetype)
		var/atom/theinstance = locate(thetype) in world
		if (!theinstance)
			boutput(usr, "<span class='alert'>Cannot locate an instance of [thetype].</span>")
			return
		boutput(usr, "<span class='notice'><b>Found instance of [thetype]:</b></span>")
		print_instance(theinstance)
	else
		boutput(usr, "<span class='alert'>No type matches for [typename].</span>")
		return

/client/proc/find_all_of(var/typename as text)
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set name = "Find All"
	set desc = "Show the location of all instances of a type. Performance warning!!"

	var/thetype = get_one_match(typename, /atom)
	if (thetype)
		var/counter = 0
		boutput(usr, "<span class='notice'><b>All instances of [thetype]: </b></span>")
		for (var/atom/theinstance in world)
			LAGCHECK(LAG_LOW)
			if (!istype(theinstance, thetype))
				continue
			counter++
			print_instance(theinstance)
		boutput(usr, "<span class='notice'>Found [counter] instances total.</span>")
	else
		boutput(usr, "No type matches for [typename].")
		return

/client/proc/find_thing(var/atom/A as null|anything in world)
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set name = "Find Thing"
	set desc = "Show the location of an atom by name."
	set popup_menu = 0

	if (!A)
		return

	boutput(usr, "<span class='notice'><b>Located [A] ([A.type]): </b></span>")
	print_instance(A)

/client/proc/count_all_of(var/typename as text)
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set name = "Count All"
	set desc = "Returns the number of all instances of a type that exist."

	var/thetype = get_one_match(typename, /atom)
	if (thetype)
		var/counter = 0
		for (var/atom/theinstance in world)
			LAGCHECK(LAG_LOW)
			if (!istype(theinstance, thetype))
				continue
			counter++
		boutput(usr, "<span class='notice'>There are <b>[counter]</b> instances total of [thetype].</span>")
	else
		boutput(usr, "<span class='alert'><b>No type matches for [typename].</b></span>")
		return

/client/proc/set_admin_level()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Change Admin Level"
	set desc = "Allows you to change your admin level at will for testing. Does not change your available verbs."
	set popup_menu = 0
	admin_only

	var/new_level = input(src, null, "Choose New Rank", "Coder") as anything in null|list("Host", "Coder", "Shit Guy", "Primary Admin", "Admin", "Secondary Admin", "Mod", "Babby")
	if (!new_level)
		return
	src.holder.rank = new_level
	switch (new_level)
		if ("Host")
			src.holder.level = LEVEL_HOST
		if ("Coder")
			src.holder.level = LEVEL_CODER
		if ("Shit Guy")
			src.holder.level = LEVEL_ADMIN
		if ("Primary Admin")
			src.holder.level = LEVEL_PA
		if ("Admin")
			src.holder.level = LEVEL_IA
		if ("Secondary Admin")
			src.holder.level = LEVEL_SA
		if ("Mod")
			src.holder.level = LEVEL_MOD
		if ("Babby")
			src.holder.level = LEVEL_BABBY

var/global/debug_camera_paths = 0
/client/proc/show_camera_paths()
	set name = "Toggle camera connections"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only

	if (!debug_camera_paths && alert(src, "DO YOU REALLY WANT TO TURN THIS ON? THE SERVER WILL SHIT ITSELF AND DIE DO NOT DO IT ON THE LIVE SERVERS THANKS", "Confirmation", "Yes", "No") == "No")
		return

	debug_camera_paths = !(debug_camera_paths)
	if (debug_camera_paths)
		display_camera_paths()
	else
		remove_camera_paths()

	message_admins("[key_name(usr)] [debug_camera_paths ? "displayed" : "hid"] all camera connections!")
	logTheThing("admin", usr, null, "[debug_camera_paths ? "displayed" : "hid"] all camera connections!")
	logTheThing("diary", usr, null, "[debug_camera_paths ? "displayed" : "hid"] all camera connections!", "admin")

proc/display_camera_paths()
	remove_camera_paths() //Clean up any old ones laying around before displaying this
	for (var/obj/machinery/camera/C in by_type[/obj/machinery/camera])
		if (C.c_north)
			camera_path_list.Add(particleMaster.SpawnSystem(new /datum/particleSystem/mechanic(C.loc, C.c_north.loc)))

		if (C.c_east)
			camera_path_list.Add(particleMaster.SpawnSystem(new /datum/particleSystem/mechanic(C.loc, C.c_east.loc)))

		if (C.c_south)
			camera_path_list.Add(particleMaster.SpawnSystem(new /datum/particleSystem/mechanic(C.loc, C.c_south.loc)))
		if (C.c_west)
			camera_path_list.Add(particleMaster.SpawnSystem(new /datum/particleSystem/mechanic(C.loc, C.c_west.loc)))

/*
/client/proc/remove_camera_paths_verb()
	set name = "Hide camera connections"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only
	remove_camera_paths()
*/

/proc/remove_camera_paths()
	for (var/datum/particleSystem/mechanic/M in camera_path_list)
		M.Die()
	camera_path_list.Cut()

/client/proc/toggle_camera_network_reciprocity()
	set name = "Toggle Camnet Reciprocity"
	set desc = "Toggle AI camera connection behaviour, off to select each node based on the individual camera, on to force cameras to reciprocate the connection"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	admin_only

	camera_network_reciprocity = !camera_network_reciprocity
	boutput(usr, "<span class='notice'>Toggled camera network reciprocity [camera_network_reciprocity ? "on" : "off"]</span>")
	logTheThing("admin", usr, null, "toggled camera network reciprocity [camera_network_reciprocity ? "on" : "off"]")
	logTheThing("diary", usr, null, "toggled camera network reciprocity [camera_network_reciprocity ? "on" : "off"]", "admin")
	message_admins("[key_name(usr)] toggled camera network reciprocity [camera_network_reciprocity ? "on" : "off"]")

	//Force a complete rebuild
	disconnect_camera_network()
	build_camera_network()

	if(camera_path_list.len > 0) //Refresh the display
		display_camera_paths()

/* Wire note: View Runtimes supercedes this in a different way
/client/proc/show_runtime_window()
	set name = "Show Runtime Window"
	set desc = "Shows the runtime window for yourself"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)

	winshow(src, "runtimes", 1)
*/

/client/proc/cmd_randomize_look()
	set name = "Randomize Appearance"
	set desc = "Randomizes how you look (if you are a human)"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)

	admin_only
	if (!ishuman(src.mob))
		return boutput(usr, "<span class='alert'>Error: client mob is invalid type or does not exist</span>")
	randomize_look(src.mob)
	logTheThing("admin", usr, null, "randomized their appearance")
	logTheThing("diary", usr, null, "randomized their appearance", "admin")

/client/proc/cmd_randomize_handwriting()
	set name = "Randomize Handwriting"
	set desc = "Randomizes how you write on paper."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)

	admin_only
	if (src.mob && src.mob.mind)
		src.mob.mind.handwriting = pick(handwriting_styles)
		boutput(usr, "<span class='notice'>Handwriting style is now: [src.mob.mind.handwriting]</span>")
		logTheThing("admin", usr, null, "randomized their handwriting style: [src.mob.mind.handwriting]")
		logTheThing("diary", usr, null, "randomized their handwriting style: [src.mob.mind.handwriting]", "admin")

#ifdef MACHINE_PROCESSING_DEBUG
/client/proc/cmd_display_detailed_machine_stats()
	set name = "Machine stats"
	set desc = "Displays the statistics for how machines are processed."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only

	var/output = ""
	for(var/T in detailed_machine_timings)
		var/list/dmtl = detailed_machine_timings[T]
		//Item type		-	Total processing time		-	Times processed		-	Average processing time
		output += "<tr><td>[T]</td><td>[dmtl[1]]</td><td>[dmtl[2]]</td><td>[dmtl[1] / dmtl[2]]</td>"

	output = {"<html>
				<head>
					<style>
						table {
							border: 1px solid black;
							border-collapse: collapse;
						}
						td {
							width: 150px;
							border-top: 1px solid black;
							border-bottom: 1px solid black;
							border-left: 1px dotted black;
							border-right: 1px dotted black;
							padding: 5px;
						}
						th {
							width: 150px;
							border-top: 1px solid black;
							border-bottom: 1px solid black;
							border-left: 1px dotted black;
							border-right: 1px dotted black;
							padding: 5px;
						}

						.alert
							{
								font-weight: bold;
								font-color: #FF0000;
							}
					</style>
				</head>
				<body>
					<table style='border:1px solid black;'>
						<tr><th>Item Type</th><th>Total processing time</th><th>Times processed</th><th>Avg processing time</th></tr>
						[output]
					</table>
				</body>
			</html>"}
	src.Browse(output, "window=holyfuck;size=600x500")

#endif

#ifdef QUEUE_STAT_DEBUG
/client/proc/cmd_display_queue_stats()
	set name = "Queue stats"
	set desc = "Displays the statistics for how queue stuff is processed."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only

	var/output = ""
	for(var/T in queue_stat_list)
		var/list/dmtl = queue_stat_list[T]
		//Item type		-	Total processing time		-	Times processed		-	Average processing time
		output += "<tr><td>[T]</td><td>[dmtl[1]]</td><td>[dmtl[2]]</td><td>[dmtl[1] / dmtl[2]]</td>"

	output = {"<html>
				<head>
					<style>
						table {
							border: 1px solid black;
							border-collapse: collapse;
						}
						td {
							width: 150px;
							border-top: 1px solid black;
							border-bottom: 1px solid black;
							border-left: 1px dotted black;
							border-right: 1px dotted black;
							padding: 5px;
						}
						th {
							width: 150px;
							border-top: 1px solid black;
							border-bottom: 1px solid black;
							border-left: 1px dotted black;
							border-right: 1px dotted black;
							padding: 5px;
						}

						.alert
							{
								font-weight: bold;
								font-color: #FF0000;
							}
					</style>
				</head>
				<body>
					<table style='border:1px solid black;'>
						<tr><th>Type</th><th>Total processing time</th><th>Times processed</th><th>Avg processing time</th></tr>
						[output]
					</table>
				</body>
			</html>"}
	src.Browse(output, "window=queuestats;size=600x500")

#endif

/client/proc/upload_custom_hud()
	set name = "Upload Custom HUD Style"
	set desc = "Adds a dmi to the global list of available huds, for every player to use."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only

	var/icon/new_style = input("Please choose a new icon file to upload", "Upload Icon") as null|icon
	if (!isicon(new_style))
		return
	var/new_style_name = input("Please enter a new name for your HUD", "Enter Name") as null|text
	if (!new_style_name)
		boutput(src, "<span class='alert'>Cannot create a HUD with no name![prob(5) ? " It's not a horse!" : null]</span>") // c:
		return
	if (alert("Create: \"[new_style_name]\" with icon [new_style]?", "Confirmation", "Yes", "No") == "Yes")
		hud_style_selection[new_style_name] = new_style
		logTheThing("admin", usr, null, "added a new HUD style with the name \"[new_style_name]\"")
		logTheThing("diary", usr, null, "added a new HUD style with the name \"[new_style_name]\"", "admin")
		message_admins("[key_name(usr)] added a new HUD style with the name \"[new_style_name]\"")


/client/proc/random_color_matrix()
	set name = "Random Color Matrix Test"
	set desc = "Animates the client to a randomised color matrix"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only

	if(!islist(usr.client.color))
		usr.client.color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)

	var/list/newColorMatrix = generate_random_value_list(2, 20)

	animate(usr.client, color=newColorMatrix, time=5, easing=SINE_EASING)
	var/matrixTable = "<table>"
	var/isBigMatrix = (newColorMatrix.len == 20)
	var/rows = isBigMatrix ? 5 : 4
	for(var/row=1, row<=rows, row++)
		matrixTable += "<tr>"
		for(var/col=1, col<=4, col++)
			matrixTable += "<td>[newColorMatrix[(row-1)*4 + col]]</td>"
		if(isBigMatrix)
			matrixTable += "<td>[row == 5 ? 1 : 0]</td>"
			matrixTable += "</tr>"
	matrixTable += "</table>"
	boutput(src, matrixTable)

/proc/generate_random_value_list(var/range=2, var/amount=20)
	. = list()
	for(var/i=0, i<amount, i++)
		. += rand_deci(-range,range,0,9)


/client/proc/test_mass_flock_convert()
	set name = "Test Mass Flock Convert"
	set desc = "Don't fucking use this EVER"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only

	if(alert("This will IRREVERSIBLY FUCK UP THE STATION and might be laggy, do not use this live. Are you sure?","Misclick Prevention","Yes","No") == "Yes")
		logTheThing("admin", usr, null, "started a mass flocktile conversion at [showCoords(usr.x, usr.y, usr.z)]")
		logTheThing("diary", usr, null, "started a mass flocktile conversion at [showCoords(usr.x, usr.y, usr.z)]", "admin")
		message_admins("[key_name(usr)] started a mass flocktile conversion at [showCoords(usr.x, usr.y, usr.z)]")
		mass_flock_convert_turf(get_turf(usr))

var/datum/flock/testflock
/client/proc/test_flock_panel()
	set name = "Test Flock Panel"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only

	if(isnull(testflock))
		testflock = new()

	var/chui/window/flockpanel/panel = testflock.panel
	panel.Subscribe(usr)

/client/proc/clear_string_cache()
	set name = "Clear String Cache"
	set desc = "Invalidates/clears the string cache to allow for files to be reloaded."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only

	if(alert("Really clear the string cache?","Invalidate String Cache","OK","Cancel") == "OK")
		var/length = string_cache.len
		string_cache = new
		logTheThing("admin", usr, null, "cleared the string cache, clearing [length] existing list(s).")
		logTheThing("diary", usr, null, "cleared the string cache, clearing [length] existing list(s).", "admin")
		boutput(src, "String cache invalidated. [length] list(s) cleared.")

/client/proc/edit_color_matrix()
	set name = "Edit Color Matrix"
	set desc = "A little more control over the VFX"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only

	if(!istype(thething))
		thething = new
	thething.edit(src)


/client/proc/temporary_deadmin_self()
	set name = "Temp. Deadmin Self"
	set desc = "Deadmin you're own self. Temporarily."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only

	if(src.holder)
		var/seconds = input("How many seconds would you like to be deadminned?", "Temporary Deadmin", 60) as num
		boutput(src, "<B><I>You have been deadminned for [seconds] seconds.</I></B>")
		src.holder.dispose()
		src.holder = null
		src.clear_admin_verbs()
		src.update_admins(null)
		SPAWN_DBG(seconds * 10)
			src.init_admin()
			boutput(src, "<B><I>Your adminnery has returned.</I></B>")


/var/datum/debugthing/thething

/datum/debugthing

	proc/edit(var/client/user)
		var/editor = grabResource("html/admin/color_matrix.html")
		user.Browse(editor, "window=colormatrix;can_close=1")
		SPAWN_DBG(1 SECOND)
			callJsFunc(usr, "setRef", list("\ref[src]")) //This is shit but without it, it calls the JS before the window is open and doesn't work.

	Topic(href, href_list)
		if(!islist(usr.client.color))
			usr.client.color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)

		// as somepotato pointed out this form is very insecure, so let's do some serverside verification that we got what we wanted
		var/sanitised = sanitize(strip_html(href_list["matrix"]))
		var/list/matrixStrings = splittext(sanitised, ",")
		// we are expecting 12 strings, so abort if we don't have that many
		if(matrixStrings.len != 20)
			return

		var/list/matrix = list()
		for(var/i=1, i<=matrixStrings.len, i++)
			var/num = text2num(matrixStrings[i])
			if(isnum(num))
				matrix += num
		if(href_list["everyone"] == "y")

			if(href_list["animate"] == "y")
				for(var/client/c)
					animate(c, color=matrix, time=5, easing=SINE_EASING)
			else
				for(var/client/c)
					c.color = matrix
		else
			if(href_list["animate"] == "y")
				animate(usr.client, color=matrix, time=5, easing=SINE_EASING)
			else
				usr.client.color = matrix

	proc/callJsFunc(var/client, var/funcName, var/list/params)
		var/paramsJS = list2params(params)
		client << output(paramsJS,"colormatrix.browser:[funcName]")
		return

#ifdef ENABLE_SPAWN_DEBUG
/client/proc/spawn_dbg()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Debug Spawn"
	set desc = "Displays all the spawns that've happened so far or dies trying"
	if(src.holder)
		if(!src.mob)
			return

		var/min = input(usr,"Enter a minimum spawn count to display, default 1 will show everything","Threshold","1") as num

		var/i
		var/text = "<html><head><title>Spawn Debug</title></head><body>\n"

		for (i in global_spawn_dbg)
			if (global_spawn_dbg[i] >= min)
				text += "[i] - [global_spawn_dbg[i]]<br>\n"

		text += "</body></html>"

		usr.Browse(text, "window=spawndbg;size=800x600")
#elif defined(ENABLE_SPAWN_DEBUG_2)
/client/proc/spawn_dbg()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Debug Spawn"
	set desc = "Displays all the spawns that've happened so far or dies trying"
	if(src.holder)
		if(!src.mob)
			return
		var/fname = "spawn_dbg.json"
		if (fexists(fname))
			fdel(fname)
		text2file(json_encode(list("spawn" = detailed_spawn_dbg)), fname)
		var/tmp_file = file(fname)
		usr << ftp(tmp_file)
		fdel(fname)
#endif

/proc/debugAddComponent(var/datum/target = null)
	var/pathpart = input("Part of component path.", "Part of component path.", "") as null|text
	if(!pathpart)
		pathpart = "/"
	var/comptype = get_one_match(pathpart, /datum/component)
	if(!comptype)
		return

	var/list/listargs = get_proccall_arglist()

	var/returnval = target._AddComponent(list(comptype) + listargs)


	boutput(usr, "<span class='notice'>Returned: [!isnull(returnval) ? returnval : "null"]</span>")
