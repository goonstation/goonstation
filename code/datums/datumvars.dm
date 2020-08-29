//
//
//


/client/proc/debug_global_variable(var/S as text)
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "View Global Variable"

	if( !src.holder || src.holder.level < LEVEL_ADMIN)
		boutput( src, "<span class='alert'>Get down from there!!</span>" )
		return
	if (!S)
		boutput( src, "<span class='alert'>Can't enter null!!</span>" )
		return

	src.audit(AUDIT_VIEW_VARIABLES, "is viewing global variable [S]")

	var/body = {"
	<table>
		<thead>
			<tr>
				<th></th>
				<th>Var</th>
				<th>Value</th>
			</tr>
		</thead>
		<tbody>
	"}

	var/V = global.vars[S]
	if (V == logs || V == logs["audit"])
		src.audit(AUDIT_ACCESS_DENIED, "tried to access the logs datum for modification.")
		boutput(usr, "<span class='alert'>Yeah, no.</span>")
		return
	if (V)
		body += debug_variable(S, V, V, 0)
	else
		boutput(usr, "<span class='alert'>Could not find [S] in the Global Variables list!!</span>" )
		return
	body += "</tbody></table>"

	var/title = "[S][src.holder.level >= LEVEL_ADMIN ? " (\ref[V])" : ""] - Refresh button doesn't work."

	//stole this from view_variables below
	var/html = {"
<html>
<head>
	<title>[title]</title>
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
[Make_view_variabls_style()]
</head>
	<body>
	<strong>Global Variable: [S]</strong>
	<hr>
	<a href='byond://?src=\ref[src];Refresh-Global-Var=\ref[V]'>Refresh</a>
		<hr>
		[body]
	</body>
</html>
"}

	if (src.holder.level >= LEVEL_CODER)
		html += " &middot; <a href='byond://?src=\ref[src];CallProc=\ref[V]'>Call Proc</a>"
		html += " &middot; <a href='byond://?src=\ref[src];ListProcs=\ref[V]'>List Procs</a>"
	usr.Browse(html, "window=variables\ref[V];size=600x400")

/client/proc/debug_variables(datum/D in world) // causes GC to lock up for a few minutes, the other option is to use atom/D but that doesn't autocomplete in the command bar
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "View Variables"
	set popup_menu = 1

	if( !src.holder || src.holder.level < LEVEL_PA )
		src.audit(AUDIT_ACCESS_DENIED, "tried to use view variables while being below PA.")
		boutput( src, "<span class='alert'>Get down from there!!</span>" )
		return

	if(D == world && src.holder.level < LEVEL_CODER) // maybe host???
		src.audit(AUDIT_ACCESS_DENIED, "tried to view variables of world as non-coder.")
		boutput( src, "<span class='alert'>Get down from there!!</span>" )
		return

	//set src in world

	if (!D) //Wire: Fix for runtime error: Cannot read null.type (datum having been deleted)
		return

	if(istype(D, /datum/configuration) || istype(D, /datum/admins))
		boutput(src, "<span class='alert'>YEAH... no....</span>")
		src.audit(AUDIT_ACCESS_DENIED, "tried to View-Variables a forbidden type([D.type])")
		return

	if(D != "GLOB")
		src.audit(AUDIT_VIEW_VARIABLES, "is viewing variables on [D]: [D.type] [istype(D, /atom) ? "at [D:x], [D:y], [D:z]" : ""]")
	else
		src.audit(AUDIT_VIEW_VARIABLES, "is viewing global variables")

	var/title = ""
	var/list/body = new

	// Since istype(D, /atom) is used a few times, I guess just have a copy of it here...
	// Saves a little time casting later, maybe? I don't know. BYOND.
	var/atom/A	= null
	if (istype(D, /atom))
		A = D
		title = "[A.name][src.holder.level >= LEVEL_ADMIN ? " (\ref[A])" : ""] = [A.type]"

		#ifdef VARSICON
		if (A.icon)
			body += debug_variable("icon", new/icon(A.icon, A.icon_state, A.dir), 0)
		#endif
	if(D == "GLOB")
		title = "Global Variables"
	else
		title = "[D][src.holder.level >= LEVEL_ADMIN ? " (\ref[D])" : ""] = [D.type]"

	body += {"

	<table>
		<thead>
			<tr>
				<th></th>
				<th style="min-width:150px">Var</th>
				<th>Value</th>
			</tr>
		</thead>
		<tbody>
	"}

	var/list/names = list()
	if(D == "GLOB")
		for(var/V in global.vars)
			if(V != "logs")
				names += V
	else
		for (var/V in D.vars)
			if(!istype(D.vars[V], /datum/admins))
				names += V

	names = sortList(names)
	if(D == "GLOB")
		for (var/V in names)
			body += debug_variable(V, global.vars[V], D, 0)
	else
		for (var/V in names)
			body += debug_variable(V, D.vars[V], D, 0)
		//body += debug_variable_link(V, D, (istype(D.vars[V], /datum) && src.holder.level >= LEVEL_CODER) ? 1 : 0)

	body += "</tbody></table>"

	var/list/html = list({"
<html>
<head>
	<title>[title]</title>
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
[Make_view_variabls_style()]</head>
<body>
	<a style="display:block;position:fixed;right:0;" href='byond://?src=\ref[src];Refresh=\ref[D]'>🔄</a>
	<strong>[title]</strong>
"})

	if (A)
		html += "<br><strong><a href='byond://?src=\ref[src];Vars=\ref[A];varToEdit=name'>Name:</a></strong> [html_encode(A.name)]"
		html += "<br><strong><a href='byond://?src=\ref[src];Vars=\ref[A];varToEdit=desc'>Desc:</a></strong> "
		if (A.desc)
			if(length(A.desc) > 1000)
				html += html_encode(copytext(A.desc,1,1000)) + "..."
			else
				html += html_encode(A.desc)
		else
			html += "<em>(null)</em>"

	html += "<hr>"

	html += "<a href='byond://?src=\ref[src];CallProc=\ref[D]'>Call Proc</a>"
	html += " &middot; <a href='byond://?src=\ref[src];ListProcs=\ref[D]'>List Procs</a>"

	if (src.holder.level >= LEVEL_CODER && D != "GLOB")
		html += " &middot; <a href='byond://?src=\ref[src];ViewReferences=\ref[D]'>View References</a>"

	html += "<br>"
	html += {"<a href='byond://?src=\ref[src];Refresh=\ref[D]'>Refresh</a>"}

	if (A)
		html += " &middot; <a href='byond://?src=\ref[src];JumpToThing=\ref[D]'>Jump To</a>"
		if (ismob(D) || isobj(D))
			html += " &middot; <a href='byond://?src=\ref[src];GetThing=\ref[D]'>Get (turf)</a> &middot; <a href='byond://?src=\ref[src];GetThing_Insert=\ref[D]'>Get (loc)</a>"
			if (ismob(D))
				html += " &middot; <a href='byond://?src=\ref[src];PlayerOptions=\ref[D]'>Player Options</a>"
	if (istype(D, /datum))
		html += " &middot; <a href='byond://?src=\ref[src];AddComponent=\ref[D]'>Add Component</a>"
	html += "<br><a href='byond://?src=\ref[src];Delete=\ref[D]'>Delete</a>"
	html += " &middot; <a href='byond://?src=\ref[src];HardDelete=\ref[D]'>Hard Delete</a>"
	if (A || istype(D, /image))
		html += " &middot; <a href='byond://?src=\ref[src];Display=\ref[D]'>Display In Chat</a>"

	if (isobj(D))
		html += "<br><a href='byond://?src=\ref[src];CheckReactions=\ref[D]'>Check Possible Reactions</a>"
		html += " &middot; <a href='byond://?src=\ref[src];ReplaceExplosive=\ref[D]'>Replace with Explosive</a>"
		html += " &middot; <a href='byond://?src=\ref[src];Possess=\ref[D]'>Possess</a>"
		html += " &middot; <a href='byond://?src=\ref[src];AddPathogen=\ref[D]'>Add Random Pathogens Reagent</a>"


		if (isitem(D))
			html += "<br><a href='byond://?src=\ref[src];GiveProperty=\ref[D]'>Give Property</a>"
			html += " &middot; <a href='byond://?src=\ref[src];GiveSpecial=\ref[D]'>Give Special</a>"
	if (A)
		html += "<br><a href='byond://?src=\ref[src];CreatePoster=\ref[D]'>Create Poster</a>"
		html += "&middot; <a href='byond://?src=\ref[src];Vars=\ref[A];varToEdit=maptext'>Edit Maptext</a>"
		html += "&middot; <a href='byond://?src=\ref[src];AdminInteract=\ref[D]'>Interact</a>"

	if (istype(D,/obj/critter))
		html += "<br> &middot; <a href='byond://?src=\ref[src];KillCritter=\ref[D]'>Kill Critter</a>"
		html += " &middot; <a href='byond://?src=\ref[src];ReviveCritter=\ref[D]'>Revive Critter</a>"



	html += {"
		<br>Direction: <a href='byond://?src=\ref[src];SetDirection=\ref[D];DirectionToSet=L90'>&lt; 90&deg;</a> &middot;
		<a href='byond://?src=\ref[src];SetDirection=\ref[D];DirectionToSet=L45'>&lt; 45&deg;</a> &middot;
		<a href='byond://?src=\ref[src];SetDirection=\ref[D]'>Set</a> &middot;
		<a href='byond://?src=\ref[src];SetDirection=\ref[D];DirectionToSet=R45'>45&deg; &gt;</a> &middot;
		<a href='byond://?src=\ref[src];SetDirection=\ref[D];DirectionToSet=R90'>90&deg; &gt;</a>
		<hr>
		[body.Join()]
	</body>
</html>
"}

	usr.Browse(html.Join(), "window=variables\ref[D];size=600x400")

	return


/client/proc/debug_variable_link(V, D, proccable)
	var/proctext = ""
	if (proccable)
		proctext = "&middot; <a href='byond://?src=\ref[src];Vars=\ref[D];procCall=[V]' title='Call Proc'>P</a>"
	if (D != "GLOB")
		return {"
		<div class='opts'>
			<a href='byond://?src=\ref[src];Vars=\ref[D];varToEdit=[V]'>Edit</a> &middot;
			<a href='byond://?src=\ref[src];Vars=\ref[D];varToEditAll=[V]' title='Edit All'>A</a> &middot;
			<a href='byond://?src=\ref[src];Vars=\ref[D];setAll=[V]' title='Set All'>S</a>
			[proctext]
		</div>
		"}
	else
		return {"
		<div class='opts'>
			<a href='byond://?src=\ref[src];Vars=\ref[D];varToEdit=[V]'>Edit</a> &middot;
		</div>
		"}
	//Really, move this out to a .css file or something, too lazy and don't know how offhand
/proc/Make_view_variabls_style()
	return {"	<style>
		body {
			font-family: Verdana, sans-serif;
			font-size: 9pt;
		}
		a {
			text-decoration: none;
		}
		a:hover, a:active {
			text-decoration: underline;
		}
		.var {
			min-width: 10em;
		}
		.value {
			font-family: "Consolas", "Courier New", monospace;
		}
		table {
			border: none;
			border-collapse: collapse;
			width: 100%;
			font-size: 100%;
		}
		tr:hover {
			background-color: rgba(128, 128, 128, .2);
		}
		th, td {
			text-align: left;
			padding: 0.1em 0.25em;
			border-bottom: 1px solid rgba(128, 128, 128, .5);
			border-right: 1px solid rgba(128, 128, 128, .3);
			vertical-align: top;

			overflow-wrap: break-word;
			word-wrap: break-word;
			word-break: break-all;
			break-word: break-all;
		}

		thead th {
			white-space: nowrap;
		}
		.nowrap {
			white-space: nowrap;
			font-size: 80%;
		}
</style>"}

/client/proc/debug_variable(name, value, var/fullvar, level)
	var/html = ""
	html += "<tr>"
	if (level == 0)
		html += "<td class='nowrap'>"
		html += debug_variable_link(name, fullvar, 1)
		html += "</td>"

	html += "<th>"

	if (isnull(value))
		html += "\[[name]\]</th><td><em class='value null'>null</em>"

	else if (istext(value))
		if(length(value) > 1000)
			html += "\[[name]\]</th><td>\"<span class='value'>[html_encode(copytext(value,1,1000))]</span>...\""
		else
			html += "\[[name]\]</th><td>\"<span class='value'>[html_encode(value)]</span>\""

	else if (isicon(value))
		#ifdef VARSICON
		var/icon/I = new/icon(value)
		var/rnd = rand(1,10000)
		var/rname = "tmp\ref[I][rnd].png"
		usr << browse_rsc(I, rname)
		html += "\[[name]\]</th><td>(<span class='value'>[value]</span>) <img class=icon src=\"[rname]\">"
		#else
		html += "\[[name]\]</th><td>/icon (<em class='value'>[value]</em>)"
		#endif

/*	else if (istype(value, /image))
		#ifdef VARSICON
		var/rnd = rand(1, 10000)
		var/image/I = value

		src << browse_rsc(I.icon, "tmp\ref[value][rnd].png")
		html += "[name]</th><td><img src=\"tmp\ref[value][rnd].png\">"
		#else
		html += "[name]</th><td>/image (<span class='value'>[value]</span>)"
		#endif
*/
	else if (isfile(value))
		html += "\[[name]\]</th><td>file (<em class='value'>[value]</em>)"

	else if (istype(value, /datum))
		var/datum/D = value
		var/dname = null
		if ("name" in D.vars)
			dname = " (" + html_encode( "[D.vars["name"]]" ) + ")"
		html += "<a href='byond://?src=\ref[src];Vars=\ref[value]'>\[[name]\]</a></th><td>[dname] (<span class='value'>[D.type][src.holder.level >= LEVEL_ADMIN ? " <em>\ref[value]</em>" : ""])"

	else if (isclient(value))
		var/client/C = value
		html += "<a href='byond://?src=\ref[src];Vars=\ref[value]'>\[[name]\]</a></th><td>[C] ([C.type][src.holder.level >= LEVEL_ADMIN ? " <em class='value'>\ref[value]</em>" : ""])"

	else if (islist(value))
		var/list/L = value
		html += "\[[name]\]</th><td>List ([(!isnull(L) && L.len > 0) ? "[L.len] items" : "<em>empty</em>"])"

		if (!isnull(L) && L.len > 0 && !(name == "underlays" || name == "overlays" || name == "vars" || name == "verbs"))
			// not sure if this is completely right...
			//if (0) // (L.vars.len > 0)
			//	html += "<ol>"
			//	for (var/entry in L)
			//		html += debug_variable(entry, L[entry], level + 1)
			//	html += "</ol>"

			html += "<table><thead><tr><th>Idx</th><th>Value</th></tr></thead><tbody>"
			var/assoc = 0
			if(name != "contents" && name != "images" && name != "screen" && name != "vis_contents")
				try
					assoc = !isnum(L[1]) && L[L[1]]
				catch
					DEBUG_MESSAGE("bad assoc list var [name] [L] [1] [L[1]]")
			for (var/index = 1, index <= min(L.len, 1500), index++)
				if (name != "contents" && name != "screen" && name != "vis_contents" && name != "vis_locs" && assoc)
					html += debug_variable(L[index], L[L[index]], value, level + 1)
				else
					html += debug_variable("[index]", L[index], value, level + 1)
			if(L.len > 1500)
				html += "<tr><th>\[...\]</th><td><em class='value'>...</em></td>"

			html += "</tbody></table>"

	else
		html += "\[[name]\]</th><td><em class='value'>[html_encode("[value]")]</em>"

	html += "</td></tr>"

	return html

/client/Topic(href, href_list, hsrc)
	if (href_list["Refresh"])
		usr_admin_only
		src.debug_variables(locate(href_list["Refresh"]))
	if (href_list["Refresh-Global-Var"])
		usr_admin_only
		src.debug_variable(locate(href_list["Refresh-Global-Var"]))
		// src.debug_variable(S, V, V, 0)
	if (href_list["JumpToThing"])
		usr_admin_only
		var/atom/A = locate(href_list["JumpToThing"])
		if (istype(A))
			src.jumptoturf(get_turf(A))
		return
	if (href_list["GetThing"])
		usr_admin_only
		var/atom/A = locate(href_list["GetThing"])
		if (ismob(A) || isobj(A))
			src.cmd_admin_get_mobject(A)
		return
	if (href_list["GetThing_Insert"])
		usr_admin_only
		var/atom/A = locate(href_list["GetThing_Insert"])
		if (ismob(A) || isobj(A))
			src.cmd_admin_get_mobject_loc(A)
		return
	if (href_list["PlayerOptions"])
		usr_admin_only
		var/mob/M = locate(href_list["PlayerOptions"])
		if (istype(M))
			src.holder.playeropt(M)
		return
	if (href_list["SetDirection"])
		usr_admin_only
		var/atom/A = locate(href_list["SetDirection"])
		if (istype(A))
			var/new_dir = href_list["DirectionToSet"]
			if (new_dir == "L90")
				A.dir = turn(A.dir, 90)
				boutput(src, "Turned [A] 90&deg; to the left: direction is now [uppertext(dir2text(A.dir))].")
			else if (new_dir == "L45")
				A.dir = turn(A.dir, 45)
				boutput(src, "Turned [A] 45&deg; to the left: direction is now [uppertext(dir2text(A.dir))].")
			else if (new_dir == "R90")
				A.dir = turn(A.dir, -90)
				boutput(src, "Turned [A] 90&deg; to the right: direction is now [uppertext(dir2text(A.dir))].")
			else if (new_dir == "R45")
				A.dir = turn(A.dir, -45)
				boutput(src, "Turned [A] 45&deg; to the right: direction is now [uppertext(dir2text(A.dir))].")
			else
				var/list/english_dirs = list("NORTH", "NORTHEAST", "EAST", "SOUTHEAST", "SOUTH", "SOUTHWEST", "WEST", "NORTHWEST")
				new_dir = input(src, "Choose a direction for [A] to face.", "Selection", "NORTH") as null|anything in english_dirs
				if (new_dir)
					A.dir = text2dir(new_dir)
					boutput(src, "Set [A]'s direction to [new_dir]")
		return
	if (href_list["CallProc"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_ADMIN)
			var/target = href_list["CallProc"] == "global" ? null : locate(href_list["CallProc"])
			if("proc_ref" in href_list)
				doCallProc(target, locate(href_list["proc_ref"]))
			else
				doCallProc(target)
		else
			audit(AUDIT_ACCESS_DENIED, "tried to call a proc on something all rude-like.")
		return
	if (href_list["ListProcs"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_ADMIN)
			var/target = href_list["CallProc"] == "global" ? null : locate(href_list["ListProcs"])
			src.show_proc_list(target)
		else
			audit(AUDIT_ACCESS_DENIED, "tried to call a proc on something all rude-like.")
		return
	if (href_list["AddComponent"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_PA)
			debugAddComponent(locate(href_list["AddComponent"]))
		else
			audit(AUDIT_ACCESS_DENIED, "tried to add a component to something all rude-like.")
		return
	if (href_list["Delete"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_PA)
			var/datum/D = locate(href_list["Delete"])
			if(alert(src, "Are you sure you want to delete [D] of type [D.type]?",,"Yes","No") == "Yes")
				qdel(D)
		else
			audit(AUDIT_ACCESS_DENIED, "tried to delete something all rude-like.")
		return
	if (href_list["HardDelete"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_PA)
			var/datum/D = locate(href_list["HardDelete"])
			if(alert(src, "Are you sure you want to delete [D] of type [D.type]?",,"Yes","No") == "Yes")
				del(D)
		else
			audit(AUDIT_ACCESS_DENIED, "tried to delete something all rude-like.")
		return
	if (href_list["Display"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_PA)
			var/fname = "varview_preview_[href_list["Display"]]_[world.timeofday].png"
			src << browse_rsc(getFlatIcon(locate(href_list["Display"])), fname)
			sleep(0.4 SECONDS)
			boutput(src, {"<img src="[fname]" style="-ms-interpolation-mode: nearest-neighbor;zoom:200%;">"})
		else
			audit(AUDIT_ACCESS_DENIED, "tried to display a flat icon of something all rude-like.")
		return
	if (href_list["ReplaceExplosive"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_PA)
			var/obj/O = locate(href_list["ReplaceExplosive"])
			O.replace_with_explosive()
		else
			audit(AUDIT_ACCESS_DENIED, "tried to replace explosive replica all rude-like.")
		return
	if (href_list["ViewReferences"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_CODER)
			var/datum/D = locate(href_list["ViewReferences"])
			usr.client.view_references(D, href_list["window_name"])
		else
			audit(AUDIT_ACCESS_DENIED, "tried to view references.")
		return
	if (href_list["AddPathogen"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_PA)
			var/obj/O = locate(href_list["AddPathogen"])
			O.addpathogens()
		else
			audit(AUDIT_ACCESS_DENIED, "tried to add random pathogens all rude-like.")
		return
	if (href_list["KillCritter"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_PA)
			var/obj/critter/O = locate(href_list["KillCritter"])
			O.kill_critter()
		else
			audit(AUDIT_ACCESS_DENIED, "tried to kill critter all rude-like.")
		return
	if (href_list["ReviveCritter"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_PA)
			var/obj/critter/O = locate(href_list["ReviveCritter"])
			O.revive_critter()
		else
			audit(AUDIT_ACCESS_DENIED, "tried to revive critter all rude-like.")
		return
	if (href_list["GiveProperty"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_PA)
			var/obj/item/I = locate(href_list["GiveProperty"])
			I.dbg_objectprop()
		else
			audit(AUDIT_ACCESS_DENIED, "tried to give property all rude-like.")
		return
	if (href_list["GiveSpecial"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_PA)
			var/obj/item/I = locate(href_list["GiveSpecial"])
			I.dbg_itemspecial()
		else
			audit(AUDIT_ACCESS_DENIED, "tried to give special all rude-like.")
		return
	if (href_list["CheckReactions"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_PA)
			var/atom/A = locate(href_list["CheckReactions"])
			A.debug_check_possible_reactions()
		else
			audit(AUDIT_ACCESS_DENIED, "tried to check reactions all rude-like.")
		return
	if (href_list["CreatePoster"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_PA)
			var/atom/A = locate(href_list["CreatePoster"])
			src.generate_poster(A)
		else
			audit(AUDIT_ACCESS_DENIED, "tried to create poster all rude-like.")
		return
	if (href_list["AdminInteract"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_SA)
			var/atom/A = locate(href_list["AdminInteract"])
			src.mob.admin_interact(A, list())
		else
			audit(AUDIT_ACCESS_DENIED, "tried to admin-interact all rude-like.")
		return
	if (href_list["Possess"])
		usr_admin_only
		if(holder && src.holder.level >= LEVEL_PA)
			var/obj/O = locate(href_list["Possess"])
			possess(O)
		else
			audit(AUDIT_ACCESS_DENIED, "tried to Possess all rude-like.")
		return
	if (href_list["Vars"])
		usr_admin_only
		if (href_list["varToEdit"])
			modify_variable(locate(href_list["Vars"]), href_list["varToEdit"])
		else if (href_list["varToEditAll"])
			modify_variable(locate(href_list["Vars"]), href_list["varToEditAll"], 1)
		else if (href_list["setAll"])
			set_all(locate(href_list["Vars"]), href_list["setAll"])
		else if (href_list["procCall"])
			var/datum/D = locate(href_list["Vars"])
			if (D)
				var/datum/C = D.vars[href_list["procCall"]]
				if (istype(C, /datum))
					doCallProc(C)
		else
			debug_variables(locate(href_list["Vars"]))
	else
		..()

/client/proc/set_all(datum/D, variable, val)
	if(!variable || !D || !(variable in D.vars))
		return
	if(variable == "holder")
		boutput(src, "Access denied.")
		return
	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return

	var/var_value = D.vars[variable]
	if(istype(D, /client))
		for(var/client/c)
			c:vars[variable] = var_value
	else
		for(var/x in world)
			if(!istype(x, D.type)) continue
			x:vars[variable] = var_value
			LAGCHECK(LAG_LOW)

/client/proc/modify_variable(datum/D, variable, set_global = 0)
	if(D != "GLOB" && (!variable || !D || !(variable in D.vars)))
		return
	var/list/locked = list("vars", "key", "ckey", "client", "holder")

	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return

	var/default
	var/var_value = D == "GLOB" ? global.vars[variable] : D.vars[variable]
	if( istype(var_value, /datum/admins) || istype(D, /datum/admins) || var_value == logs || var_value == logs["audit"] )
		src.audit(AUDIT_ACCESS_DENIED, "tried to assign a value to a forbidden variable.")
		boutput(src, "You can't set that value.")
		return
	var/dir

	if (locked.Find(variable) && !(src.holder.rank in list("Host", "Coder", "Administrator")))
		boutput(usr, "<span class='alert'>You do not have access to edit this variable!</span>")
		return

	//Let's prevent people from promoting themselves, yes?
	var/list/locked_type = list(/datum/admins) //Short list - might be good if there are more objects that oughta be paws-off
	if(D != "GLOB" && (D.type == /datum/configuration || (!(src.holder.rank in list("Host", "Coder")) && (D.type in locked_type) )))
		boutput(usr, "<span class='alert'>You're not allowed to edit [D.type] for security reasons!</span>")
		logTheThing("admin", usr, null, "tried to varedit [D.type] but was denied!")
		logTheThing("diary", usr, null, "tried to varedit [D.type] but was denied!", "admin")
		message_admins("[key_name(usr)] tried to varedit [D.type] but was denied.") //If someone tries this let's make sure we all know it.
		return


	if (isnull(var_value))
		boutput(usr, "Unable to determine variable type.")

	else if (isnum(var_value))
		boutput(usr, "Variable appears to be <b>NUM</b>.")
		default = "num"
		dir = 1

	else if (is_valid_color_string(var_value))
		boutput(usr, "Variable appears to be <b>COLOR</b>.")
		default = "color"

	else if (istext(var_value))
		boutput(usr, "Variable appears to be <b>TEXT</b>.")
		default = "text"

	else if (isloc(var_value))
		boutput(usr, "Variable appears to be <b>REFERENCE</b>.")
		default = "reference"

	else if (isicon(var_value))
		boutput(usr, "Variable appears to be <b>ICON</b>.")
		//var_value = "[bicon(var_value)]"
		default = "icon"

	else if (istype(var_value,/atom) || istype(var_value,/datum))
		boutput(usr, "Variable appears to be <b>TYPE</b>.")
		default = "type"

	else if (islist(var_value))
		boutput(usr, "Variable appears to be <b>LIST</b>.")
		default = "list"

	else if (isclient(var_value))
		boutput(usr, "Variable appears to be <b>CLIENT</b>.")
		default = "cancel"

	else
		boutput(usr, "Variable appears to be <b>FILE</b>.")
		default = "file"

	boutput(usr, "\"<tt>[variable]</tt>\" contains: [var_value]")
	if(dir)
		switch(var_value)
			if(1)
				dir = "NORTH"
			if(2)
				dir = "SOUTH"
			if(4)
				dir = "EAST"
			if(8)
				dir = "WEST"
			if(5)
				dir = "NORTHEAST"
			if(6)
				dir = "SOUTHEAST"
			if(9)
				dir = "NORTHWEST"
			if(10)
				dir = "SOUTHWEST"
			else
				dir = null
		if(dir)
			boutput(usr, "If a direction, direction is: [dir]")

	var/class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
		"num","type","reference","mob reference","turf by coordinates","reference picker","new instance of a type","icon","file","color","list","edit referenced object","create new list","null", "ref", "restore to default")

	if(!class)
		return

	var/original_name
	if(D == "GLOB")
		original_name = "Global Variable"
	else
		if (!istype(D, /atom))
			original_name = "[src.holder.level >= LEVEL_ADMIN ? "\ref[D] " : ""]([D])"
		else
			original_name = D:name

	var/oldVal = D == "GLOB" ? global.vars[variable] : D.vars[variable]
	switch(class)
		if("null")
			if(set_global)
				for(var/x in world)
					if(!istype(x, D.type)) continue
					x:vars[variable] = null
					LAGCHECK(LAG_LOW)
			else
				if(D == "GLOB")
					global.vars[variable] = null
				else
					D.vars[variable] = null
		if("ref")
			if (!(src.holder.rank in list("Host", "Coder", "Administrator")))
				boutput( src, "<span class='alert'>This can super break shit so you can't use this. Sorry.</span> ")
				return
			var/theref = input("What ref?") as null|text
			if(theref)
				var/thing = locate(theref)
				if(!thing)
					thing = locate("\[[theref]\]")
				if(!thing)
					boutput(src, "<span class='alert'>Bad ref or couldn't find that thing. Drats.</span>")
					return
				if(set_global)
					for(var/x in world)
						if(!istype(x, D.type)) continue
						x:vars[variable] = thing
						LAGCHECK(LAG_LOW)
				else
					if(D == "GLOB")
						global.vars[variable] = thing
					else
						D.vars[variable] = thing

		if("list")
			if(D == "GLOB")
				mod_list(global.vars[variable])
			else
				mod_list(D.vars[variable])
			//return <- Way to screw up logging

		if("restore to default")
			if(set_global)
				for(var/x in world)
					if(!istype(x, D.type)) continue
					x:vars[variable] = initial(x:vars[variable])
					LAGCHECK(LAG_LOW)
			else
				if(D == "GLOB")
					global.vars[variable] = initial(global.vars[variable])
				else
					D.vars[variable] = initial(D.vars[variable])

		if("edit referenced object")
			if(D == "GLOB")
				return .(global.vars[variable])
			else
				return .(D.vars[variable])

		if("create new list")
			if(set_global)
				for(var/x in world)
					if(!istype(x, D.type)) continue
					x:vars[variable] = list()
					LAGCHECK(LAG_LOW)
			else
				if(D == "GLOB")
					global.vars[variable] = list()
				else
					D.vars[variable] = list()

		if("text")
			var/theInput = input("Enter new text:","[variable]", D == "GLOB" ? global.vars[variable] : D.vars[variable]) as null|message
			if(theInput == null) return
			if(set_global)
				if(isclient(D))
					for(var/client/x)
						x:vars[variable] = theInput
						LAGCHECK(LAG_LOW)
				else
					for(var/x in world)
						if(!istype(x, D.type)) continue
						x:vars[variable] = theInput
						LAGCHECK(LAG_LOW)
			else
				if(D == "GLOB")
					global.vars[variable] = theInput
				else
					D.vars[variable] = theInput

		if("num")
			var/theInput = input("Enter new number:","[variable]", D == "GLOB" ? global.vars[variable] : D.vars[variable]) as null|num
			if(theInput == null) return
			if(set_global)
				for(var/x in world)
					if(!istype(x, D.type)) continue
					x:vars[variable] = theInput
					LAGCHECK(LAG_LOW)
			else
				if(D == "GLOB")
					global.vars[variable] = theInput
				else
					D.vars[variable] = theInput

		if("type")
			boutput(usr, "<span class='hint'>Type part of the path of the type.</span>")
			var/typename = input("Part of type path.", "Part of type path.", "/obj") as null|text
			if (typename)
				var/match = get_one_match(typename, /datum)
				if (match)
					if (set_global)
						for (var/datum/x in world)
							LAGCHECK(LAG_LOW)
							if (!istype(x, D.type)) continue
							x.vars[variable] = match
					else
						if(D == "GLOB")
							global.vars[variable] = match
						else
							D.vars[variable] = match

		if("reference")
			var/theInput = input("Select reference:","[variable]", D == "GLOB" ? global.vars[variable] : D.vars[variable]) as null|mob|obj|turf|area in world
			if(theInput == null) return
			if(set_global)
				for(var/x in world)
					if(!istype(x, D.type)) continue
					x:vars[variable] = theInput
					LAGCHECK(LAG_LOW)
			else
				if(D == "GLOB")
					global.vars[variable] = theInput
				else
					D.vars[variable] = theInput

		if("mob reference")
			var/theInput = input("Select reference:","[variable]", D == "GLOB" ? global.vars[variable] : D.vars[variable]) as null|mob in world
			if(theInput == null) return
			if(set_global)
				for(var/x in world)
					if(!istype(x, D.type)) continue
					x:vars[variable] = theInput
					LAGCHECK(LAG_LOW)
			else
				if(D == "GLOB")
					global.vars[variable] = theInput
				else
					D.vars[variable] = theInput

		if("file")
			var/theInput = input("Pick file:","[variable]",D == "GLOB" ? global.vars[variable] : D.vars[variable]) as null|file
			if(theInput == null) return
			if(set_global)
				for(var/x in world)
					if(!istype(x, D.type)) continue
					x:vars[variable] = theInput
					LAGCHECK(LAG_LOW)
			else
				if(D == "GLOB")
					global.vars[variable] = theInput
				else
					D.vars[variable] = theInput

		if("icon")
			var/theInput = input("Pick icon:","[variable]",D == "GLOB" ? global.vars[variable] : D.vars[variable]) as null|icon
			if(theInput == null) return
			if(set_global)
				for(var/x in world)
					if(!istype(x, D.type)) continue
					x:vars[variable] = theInput
					LAGCHECK(LAG_LOW)
			else
				if(D == "GLOB")
					global.vars[variable] = theInput
				else
					D.vars[variable] = theInput

		if("color")
			var/theInput = input("Pick color:","[variable]",D == "GLOB" ? global.vars[variable] : D.vars[variable]) as null|color
			if(theInput == null) return
			if(set_global)
				if(isclient(D))
					for(var/client/x)
						x:vars[variable] = theInput
						LAGCHECK(LAG_LOW)
				else
					for(var/x in world)
						if(!istype(x, D.type)) continue
						x:vars[variable] = theInput
						LAGCHECK(LAG_LOW)
			else
				if(D == "GLOB")
					global.vars[variable] = theInput
				else
					D.vars[variable] = theInput

		if("turf by coordinates")
			var/x = input("X coordinate", "Set to turf at \[_, ?, ?\]", 1) as num
			var/y = input("Y coordinate", "Set to turf at \[[x], _, ?\]", 1) as num
			var/z = input("Z coordinate", "Set to turf at \[[x], [y], _\]", 1) as num
			var/turf/T = locate(x, y, z)
			if (istype(T))
				if (set_global)
					for (var/datum/q in world)
						LAGCHECK(LAG_LOW)
						if (!istype(q, D.type)) continue
						q.vars[variable] = T
				else
					if(D == "GLOB")
						global.vars[variable] = T
					else
						D.vars[variable] = T
			else
				boutput(usr, "<span class='alert'>Invalid coordinates!</span>")
				return

		if("reference picker")
			boutput(usr, "<span class='hint'>Click the mob, object or turf to use as a reference.</span>")
			var/mob/M = usr
			if (istype(M))
				var/datum/targetable/refpicker/R
				if (set_global)
					R = new /datum/targetable/refpicker/global()
				else
					R = new()
				R.target = D
				R.varname = variable
				M.targeting_ability = R
				M.update_cursor()
				return

		if ("new instance of a type")
			boutput(usr, "<span class='notice'>Type part of the path of type of thing to instantiate.</span>")
			var/typename = input("Part of type path.", "Part of type path.", "/obj") as null|text
			if (typename)
				var/basetype = /obj
				if (src.holder.rank in list("Host", "Coder", "Administrator"))
					basetype = /datum
				var/match = get_one_match(typename, basetype)
				if (match)
					if (set_global)
						for (var/datum/x in world)
							LAGCHECK(LAG_LOW)
							if (!istype(x, D.type)) continue
							x.vars[variable] = new match(x)
					else
						if(D == "GLOB")
							global.vars[variable] = new match()
						else

							D.vars[variable] = new match(D)
			else
				return

	logTheThing("admin", src, null, "modified [original_name]'s [variable] to [D == "GLOB" ? global.vars[variable] : D.vars[variable]]" + (set_global ? " on all entities of same type" : ""))
	logTheThing("diary", src, null, "modified [original_name]'s [variable] to [D == "GLOB" ? global.vars[variable] : D.vars[variable]]" + (set_global ? " on all entities of same type" : ""), "admin")
	message_admins("[key_name(src)] modified [original_name]'s [variable] to [D == "GLOB" ? global.vars[variable] : D.vars[variable]]" + (set_global ? " on all entities of same type" : ""), 1)
	SPAWN_DBG(0)
		if (istype(D, /datum))
			D.onVarChanged(variable, oldVal, D.vars[variable])
	src.debug_variables(D)

/mob/proc/Delete(atom/A in view())
	set category = "Debug"
	switch (alert("Are you sure you wish to delete \the [A.name] at ([A.x],[A.y],[A.z]) ?", "Admin Delete Object","Yes","No"))
		if("Yes")
			logTheThing("admin", usr, null, "deleted [A.name] at ([showCoords(A.x, A.y, A.z)])")
			logTheThing("diary", usr, null, "deleted [A.name] at ([showCoords(A.x, A.y, A.z, 1)])", "admin")
