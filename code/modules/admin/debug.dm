var/global/debug_messages = 0

#define ARG_INFO_NAME 1
#define ARG_INFO_TYPE 2
#define ARG_INFO_DESC 3
#define ARG_INFO_DEFAULT 4

/client/proc/debug_messages()
	set desc = "Toggle debug messages."
	set name = "HDM" // debug ur haines
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY
	SHOW_VERB_DESC

	debug_messages = !(debug_messages)
	logTheThing(LOG_ADMIN, usr, "toggled debug messages [debug_messages ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled debug messages [debug_messages ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled debug messages [debug_messages ? "on" : "off"]")

/client/proc/debug_deletions()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Debug Deletions"
	ADMIN_ONLY
	SHOW_VERB_DESC
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
		total += length(global.delete_queue_2[b])

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
	ADMIN_ONLY
	SHOW_VERB_DESC
	deletedImageData = new

/client/proc/debug_image_deletions()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Debug Image Deletions"
	ADMIN_ONLY
	SHOW_VERB_DESC
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

/client/proc/call_proc_atom(atom/target as null|area|obj|mob|turf in world)
	set name = "Call Proc"
	set desc = "Calls a proc associated with the targeted atom"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	ADMIN_ONLY
	if (!target)
		return
	src.doCallProc(target)

/client/proc/call_proc_all(var/typename as null|text)
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Call Proc All"
	set desc = "Call proc on all instances of a type, will probably slow shit down"
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!typename)
		typename = input("Input part of type:", "Type Input") as null|text
	if (!typename)
		return
	var/thetype = get_one_match(typename, /datum, use_concrete_types = FALSE, only_admin_spawnable = FALSE)
	if (thetype)
		var/procname = input("Procpath","path:", null) as text
		var/list/listargs = src.get_proccall_arglist()
		if (listargs == null) return

		var/list/results = find_all_by_type(thetype, procname, "instance", listargs)

		boutput(usr, SPAN_NOTICE("'[procname]' called on [length(results)] instances of '[thetype]'"))
		message_admins(SPAN_ALERT("Admin [key_name(src)] called '[procname]' on all instances of '[thetype]'"))
		logTheThing(LOG_ADMIN, src, "called [procname] on all instances of [thetype]")
		logTheThing(LOG_DIARY, src, "called [procname] on all instances of [thetype]")
	else
		boutput(usr, "No type matches for [typename]")
		return




/client/proc/call_proc()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Advanced ProcCall"
	ADMIN_ONLY
	SHOW_VERB_DESC
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
	src.doCallProc(target)

/client/proc/doCallProc(datum/target = null, procname = null) // also accepts actual proc
	var/returnval = null
	if(isnull(procname))
		procname = input("Procpath (ex. bust_lights)","path:", null) as null|text
	if (isnull(procname))
		return

	var/list/listargs = src.get_proccall_arglist()

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
		boutput(usr, SPAN_NOTICE("Calling '[procname]' with [islist(listargs) ? listargs.len : "0"] arguments on '[target]'"))
	else
		boutput(usr, SPAN_NOTICE("Calling '[procname]' with [islist(listargs) ? listargs.len : "0"] arguments"))

	var/success = FALSE
	for(var/actual_proc in name_list)
		try
			if (target)
				target.onProcCalled(actual_proc, listargs)
				if(islist(listargs) && length(listargs))
					returnval = call(target,actual_proc)(arglist(listargs))
				else
					returnval = call(target,actual_proc)()
			else
				if(islist(listargs) && length(listargs))
					returnval = call(actual_proc)(arglist(listargs))
				else
					returnval = call(actual_proc)()
			success = TRUE
			break
		catch(var/exception/e)
			if(e.name != "bad proc" && copytext(e.name, 1, 15) != "undefined proc") // fuck u byond
				boutput(usr, SPAN_ALERT("Exception occurred! <a style='color: #88f;' href='byond://winset?command=View-Runtimes'>View Runtimes</a>"))
				throw e

	if(!success)
		boutput(usr, SPAN_ALERT("Proc [procname] not found!"))
		return

	var/pretty_returnval = returnval
	if(istype(returnval, /datum) || istype(returnval, /client))
		pretty_returnval = "<a href='byond://?src=\ref[usr.client];Refresh=\ref[returnval]'>[returnval] \ref[returnval]</a>"
	else
		pretty_returnval = json_encode(returnval)
	boutput(usr, SPAN_NOTICE("Proc returned: [pretty_returnval]"))
	return

/datum/proccall_editor
	var/atom/movable/target
	/// The current key value state of the arguments we want to return
	var/list/listargs
	var/list/initialization_args
	/// Boolean field describing if the tgui_color_picker was closed by the user.
	var/closed = FALSE

/datum/proccall_editor/New(atom/target, init_args)
	..()
	src.target = target
	initialization_args = init_args
	src.setup_listargs()

/datum/proccall_editor/disposing()
	src.target = null
	src.listargs = null
	src.initialization_args = null
	..()

/datum/proccall_editor/ui_state(mob/user)
	return tgui_admin_state

/datum/proccall_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ProcCall")
		ui.open()
		//ui.set_autoupdate(timeout > 0)

/**
 * Waits for a user's response to the tgui_color_picker's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/proccall_editor/proc/wait()
	while (!closed && !QDELETED(src))
		sleep(1)

/datum/proccall_editor/ui_close(mob/user)
	. = ..()
	closed = TRUE

///Set up the default values stored in listargs before we open the interface
/datum/proccall_editor/proc/setup_listargs()
	src.listargs = list()
	for(var/customization in initialization_args)
		if(length(customization) >= ARG_INFO_DEFAULT)
			if (customization[ARG_INFO_TYPE] == DATA_INPUT_LIST_PROVIDED)
				var/list/supplied_list = customization[ARG_INFO_DEFAULT]
				src.listargs[customization[ARG_INFO_NAME]] = supplied_list[1]
			else
				src.listargs[customization[ARG_INFO_NAME]] = customization[ARG_INFO_DEFAULT]
		else
			src.listargs[customization[ARG_INFO_NAME]] = null

/datum/proccall_editor/ui_data(mob/user)
	. = list()
	.["name"] = "Variables"
	.["options"] = list()
	for(var/customization in initialization_args)
		.["options"][customization[ARG_INFO_NAME]] += list(
			"type" = customization[ARG_INFO_TYPE],
			"description" = customization[ARG_INFO_DESC])

		//show coordinates as well as actual value
		if(customization[ARG_INFO_TYPE] == DATA_INPUT_REFPICKER)
			var/atom/target = src.listargs[customization[ARG_INFO_NAME]]
			if(isatom(target))
				.["options"][customization[ARG_INFO_NAME]]["value"] = "([target.x],[target.y],[target.z]) [target]"
			else
				.["options"][customization[ARG_INFO_NAME]]["value"] = "null"
			continue
		//supplied lists have a different interface with a `list` var and `value` being the currently selected list item
		//confusing!!
		if (customization[ARG_INFO_TYPE] == DATA_INPUT_LIST_PROVIDED)
			var/list/key_list = list()
			for (var/key in customization[ARG_INFO_DEFAULT])
				key_list += "[key]" //stringify here to prevent encoding issues with letting the frontend do it
			.["options"][customization[ARG_INFO_NAME]]["list"] = key_list
			.["options"][customization[ARG_INFO_NAME]]["value"] = src.listargs[customization[ARG_INFO_NAME]]
		//normal variable
		.["options"][customization[ARG_INFO_NAME]]["value"] = src.listargs[customization[ARG_INFO_NAME]]

/datum/proccall_editor/ui_act(action, list/params, datum/tgui/ui)
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	. = ..()
	if(.)
		return

	switch(action)
		if("modify_value")
			for(var/customization in initialization_args)
				if(params["name"]==customization[ARG_INFO_NAME] \
				&& params["type"]==customization[ARG_INFO_TYPE] )
					listargs[params["name"]] = params["value"]
					. = TRUE
					break

		if("modify_color_value")
			for(var/customization in initialization_args)
				if(params["name"]==customization[ARG_INFO_NAME] \
				&& params["type"]==customization[ARG_INFO_TYPE] )
					var/new_color = input(usr, "Pick new color", "Event Color") as color|null
					if(new_color)
						listargs[params["name"]] = new_color
					. = TRUE
					break;

		if("modify_ref_value")
			for(var/customization in initialization_args)
				if(params["name"]==customization[ARG_INFO_NAME] \
				&& params["type"]==customization[ARG_INFO_TYPE])
					var/atom/target = pick_ref(usr)
					listargs[params["name"]] = target
					. = TRUE
					break;
		if ("modify_list_value")
			for(var/customization in initialization_args)
				if(params["name"]==customization[ARG_INFO_NAME] \
				&& params["type"]==customization[ARG_INFO_TYPE])
					//go through the actual values and compare their stringified value to the one we got from the frontend
					//so we don't end up returning a string instead of a type for instance
					for (var/list_option in customization[ARG_INFO_DEFAULT])
						if (strip_illegal_characters("[list_option]") == params["value"])
							src.listargs[params["name"]] = list_option
							return TRUE
		if("activate")
			closed = TRUE
			ui.close()

		if("unsupported_type")
			src.closed = TRUE
			src.listargs = null
			boutput(usr, "DataInput.tsx does not support type: [params["type"]] for name:[params["name"]]")
			ui.close()

/client/proc/get_proccall_arglist(list/arginfo = null, var/list/custom_options = null)
	if(arginfo)
		var/datum/proccall_editor/E = new /datum/proccall_editor(usr, arginfo)
		if(E)
			E.ui_interact(usr)
			E.wait()
			if(islist(E.listargs) && length(E.listargs))
				return E.listargs
	var/argnum = arginfo ? length(arginfo) : input("Number of arguments:","Number", 0) as null|num
	var/list/listargs = list()
	if (!argnum)
		return listargs
	for (var/i = 1 , i <= argnum, i++)
		var/datum/data_input_result/arg = src.input_data(list(DATA_INPUT_TEXT, DATA_INPUT_NUM, DATA_INPUT_BOOL, DATA_INPUT_TYPE, DATA_INPUT_JSON, DATA_INPUT_REF, DATA_INPUT_MOB_REFERENCE, \
										DATA_INPUT_ATOM_ON_CURRENT_TURF, DATA_INPUT_ICON, DATA_INPUT_COLOR, DATA_INPUT_FILE, DATA_INPUT_REFPICKER, DATA_INPUT_LIST_BUILD, DATA_INPUT_NULL, \
										DATA_INPUT_NEW_INSTANCE) \
										+ custom_options, default = (length(arginfo?[i]) > 3) ? arginfo[i][ARG_INFO_DEFAULT] : null, custom_type_title = arginfo ? arginfo[i][ARG_INFO_DESC] + ":" : "Type of Argument #[i]", \
										custom_type_message =  arginfo ? "Argument #[i]: " + arginfo[i][ARG_INFO_NAME] : "Variable Type", \
										default_type = arginfo?[i][ARG_INFO_TYPE])

		if(isnull(arg.output_type))
			break

		listargs += list(arg.output)

	return listargs

/client/proc/cmd_admin_mobileAIize(var/mob/M in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Mobile AIize"
	set popup_menu = 0
	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		logTheThing(LOG_ADMIN, src, "has mobile-AIized [constructTarget(M,"admin")]")
		logTheThing(LOG_DIARY, src, "has mobile-AIized [constructTarget(M,"diary")]", "admin")
		SPAWN(1 SECOND)
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
			boutput(M, SPAN_NOTICE("<B>You have been teleported to your new starting location!</B>"))
			M.set_loc(new_loc)
			M.buckled = null
		message_admins(SPAN_ALERT("Admin [key_name(src)] AIized [key_name(M)]!"))
		logTheThing(LOG_ADMIN, src, "AIized [constructTarget(M,"admin")]")
		logTheThing(LOG_DIARY, src, "AIized [constructTarget(M,"diary")]", "admin")
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

/client/proc/cmd_debug_del_all(var/typename as text)
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Del-All"
	set desc = "Delete all instances of the selected type."
	ADMIN_ONLY
	SHOW_VERB_DESC
	// to prevent REALLY stupid deletions on live
	var/hsbitem = get_one_match(typename, /atom, use_concrete_types=FALSE)
	var/background =  alert("Run the process in the background?",,"Yes" ,"No")

#ifdef LIVE_SERVER
	var/blocked = list(/obj, /mob, /mob/living, /mob/living/carbon, /mob/living/carbon/human)
	for(var/V in blocked)
		if(V == hsbitem)
			boutput(usr, "Can't delete that you jerk!")
			return
#endif
	if(hsbitem)
		src.delete_state = DELETE_RUNNING
		src.verbs += /client/proc/cmd_debug_del_all_cancel
		src.verbs += /client/proc/cmd_debug_del_all_check
		boutput(usr, "Deleting [hsbitem]...")
		var/station_only = alert("Only delete from the station Z?",,"Yes" ,"No")
		var/numdeleted = 0
		for(var/atom/O as anything in find_all_by_type(hsbitem, lagcheck=(background == "yes")))
			if ((station_only == "Yes") && O.z != Z_LEVEL_STATION)
				continue
			qdel(O)
			numdeleted++
			if(background == "Yes")
				LAGCHECK(LAG_LOW)
			if (src.delete_state == DELETE_STOP)
				break
			else if (src.delete_state == DELETE_CHECK)
				boutput(usr, "Deleted [numdeleted] instances of [hsbitem] so far.")
				src.delete_state = DELETE_RUNNING

		if(numdeleted == 0) boutput(usr, "No instances of [hsbitem] found!")
		else boutput(usr, "Deleted [numdeleted] instances of [hsbitem]!")
		logTheThing(LOG_ADMIN, src, "has deleted [numdeleted] instances of [hsbitem].")
		logTheThing(LOG_DIARY, src, "has deleted [numdeleted] instances of [hsbitem].", "admin")
		message_admins("[key_name(src)] has deleted [numdeleted] instances of [hsbitem].")
		src.verbs -= /client/proc/cmd_debug_del_all_cancel
		src.verbs -= /client/proc/cmd_debug_del_all_check
		src.delete_state = DELETE_STOP

/client/proc/cmd_debug_del_half(var/typename as text)
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Del-Half"
	set desc = "Delete approximately half of instances of the selected type. *snap"
	ADMIN_ONLY
	SHOW_VERB_DESC
	// to prevent REALLY stupid deletions
	var/hsbitem = get_one_match(typename, /atom, use_concrete_types=FALSE)
	var/background =  alert("Run the process in the background?",,"Yes" ,"No")

#ifdef LIVE_SERVER
	var/blocked = list(/obj, /mob, /mob/living, /mob/living/carbon, /mob/living/carbon/human)
	for(var/V in blocked)
		if(V == hsbitem)
			boutput(usr, "Can't delete that you jerk!")
			return
#endif
	if(hsbitem)
		src.delete_state = DELETE_RUNNING
		src.verbs += /client/proc/cmd_debug_del_all_cancel
		src.verbs += /client/proc/cmd_debug_del_all_check
		boutput(usr, "Deleting [hsbitem]...")
		var/station_only = alert("Only delete from the station Z?",,"Yes" ,"No")
		var/numdeleted = 0
		var/numtotal = 0
		for(var/atom/O as anything in find_all_by_type(hsbitem, lagcheck=(background == "yes")))
			if ((station_only == "Yes") && O.z != Z_LEVEL_STATION)
				continue
			numtotal++
			if(prob(50))
				qdel(O)
				numdeleted++
			if(background == "Yes")
				LAGCHECK(LAG_LOW)
			if (src.delete_state == DELETE_STOP)
				break
			else if (src.delete_state == DELETE_CHECK)
				boutput(usr, "Deleted [numdeleted]/[numtotal] instances of [hsbitem] so far.")
				src.delete_state = DELETE_RUNNING

		if(numtotal == 0) boutput(usr, "No instances of [hsbitem] found!")
		else boutput(usr, "Deleted [numdeleted]/[numtotal] instances of [hsbitem]!")
		logTheThing(LOG_ADMIN, src, "has deleted [numdeleted]/[numtotal] instances of [hsbitem].")
		logTheThing(LOG_DIARY, src, "has deleted [numdeleted]/[numtotal] instances of [hsbitem].", "admin")
		message_admins("[key_name(src)] has deleted [numdeleted]/[numtotal] instances of [hsbitem].")
		src.verbs -= /client/proc/cmd_debug_del_all_cancel
		src.verbs -= /client/proc/cmd_debug_del_all_check
		src.delete_state = DELETE_STOP

// cancels your del_all in process, if one is running
/client/proc/cmd_debug_del_all_cancel()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Del-All Cancel"
	ADMIN_ONLY
	SHOW_VERB_DESC
	src.delete_state = DELETE_STOP

// makes del_all print how much is currently deleted
/client/proc/cmd_debug_del_all_check()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Del-All Progress"
	ADMIN_ONLY
	SHOW_VERB_DESC
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
	var/angle = input("Enter ANGLE of Explosion (clockwise from north)\nIf not a multiple of 45, you may encounter issues.", "Angle", 0) as num
	var/width = input("Enter WIDTH of Explosion\nLeave it on 360 if you have no idea what this does.", "Width", 360) as num
	var/turf_safe = alert("Do you want to make the explosion safe for turfs?", "Turf safe?", "Yes", "No") == "Yes"

	logTheThing(LOG_ADMIN, src, "created an explosion (power [esize], brisance [bris]) at [log_loc(T)].")
	logTheThing(LOG_DIARY, src, "created an explosion (power [esize], brisance [bris]) at [log_loc(T)].", "admin")
	message_admins("[key_name(src)] has created an explosion (power [esize], brisance [bris]) at [log_loc(T)].")

	explosion_new(null, T, esize, bris, angle, width, turf_safe=turf_safe)
	return

/client/proc/cmd_debug_mutantrace(var/mob/mob in world)
	set name = "Change Mutant Race"
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC
	if(!ishuman(mob))
		alert("[mob] is not a human mob!")
		return

	var/mob/living/carbon/human/H = mob

	var/race = input("Select a mutant race","Races",null) as null|anything in typesof(/datum/mutantrace)

	if (!race)
		return

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

	sortList(names, /proc/cmp_text_asc)

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
	ADMIN_ONLY
	SHOW_VERB_DESC
	boutput(usr, "Gang scores:")

	for(var/datum/gang/G in get_all_gangs())
		boutput(usr, "[G.gang_name]: [G.gang_score()] ([G.num_tiles_controlled()] tiles)")

/client/proc/scenario()
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Profiling Scenario"

	var/selected = input("Select scenario", "Do not use on a live server for the love of god", "Cancel") in list("Cancel", "Disco Inferno", "Chemist's Delight", "Viscera Cleanup Detail", "Brighter Bonanza", "Monkey Business","Monkey Chemistry","Monkey Gear","Clothing Dummies")
	switch (selected)
		if ("Disco Inferno")
			for (var/turf/T as anything in landmarks[LANDMARK_BLOBSTART]+landmarks[LANDMARK_HALLOWEEN_SPAWN]+landmarks[LANDMARK_PESTSTART])
				var/datum/gas_mixture/gas = new /datum/gas_mixture
				gas.toxins = 33333
				gas.oxygen = 66666
				gas.temperature = 100000
				T.assume_air(gas)
			for_by_tcl(door, /obj/machinery/door)
				var/turf/T = get_step(door, NORTH)
				if(istype(T, /turf/space) || istype(T, /turf/simulated/floor/airless/plating/catwalk))
					continue
				T = get_step(door, SOUTH)
				if(istype(T, /turf/space) || istype(T, /turf/simulated/floor/airless/plating/catwalk))
					continue
				T = get_step(door, EAST)
				if(istype(T, /turf/space) || istype(T, /turf/simulated/floor/airless/plating/catwalk))
					continue
				T = get_step(door, WEST)
				if(istype(T, /turf/space) || istype(T, /turf/simulated/floor/airless/plating/catwalk))
					continue
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
		if ("Brighter Bonanza")
			var/list/obj/item/device/light/zippo/brighter/brighters = list()
			for(var/i in 1 to 1000)
				brighters += new /obj/item/device/light/zippo/brighter
				brighters[i].light.enable()
			while(TRUE)
				for(var/obj/brighter in brighters)
					brighter.set_loc(locate(rand(1, world.maxx), rand(1, world.maxy), Z_LEVEL_STATION))
				sleep(0.2 SECONDS)
		if ("Monkey Business")
			var/list/station_areas = get_accessible_station_areas()
			var/turf/location
			for(var/i in 1 to 100)
				LAGCHECK(LAG_LOW)
				if(prob(25))
					var/list/turfs = get_area_turfs(station_areas[pick(station_areas)],TRUE)
					if(!length(turfs)) continue
					location = pick(turfs)
				else
					var/job = pick(job_start_locations)
					location = pick(job_start_locations[job])
				var/mob/living/carbon/human/npc/monkey/M = new /mob/living/carbon/human/npc/monkey(location)
				if(prob(10))
					new /obj/item/implant/access/infinite/shittybill(M)
				M.ai_offhand_pickup_chance = rand(20,80)
				M.ai_poke_thing_chance = rand(20,50)
		if ("Monkey Chemistry")
			while(TRUE)
				var/mob/M = pick(by_type[/mob/living/carbon/human/npc/monkey])
				var/reagent_id = pick(reagents_cache)
				M.reagents.add_reagent(reagent_id, rand(1,10))
				sleep(0.2 SECONDS)
		if ("Monkey Gear")
			var/obj/item/I
			for_by_tcl(monkey, /mob/living/carbon/human/npc/monkey)
				I = pick(concrete_typesof(/obj/item))
				new I(get_turf(monkey))
			while(TRUE)
				var/mob/M = pick(by_type[/mob/living/carbon/human/npc/monkey])
				I = pick(concrete_typesof(/obj/item))
				new I(get_turf(M))
				sleep(1 SECONDS)
		if ("Clothing Dummies")
			for (var/i in 1 to 80)
				var/human_type = pick(concrete_typesof(/mob/living/carbon/human/normal))
				new human_type(pick_landmark(LANDMARK_PESTSTART))
			while(TRUE)
				var/mob/living/carbon/human/normal/human = pick(by_type[/mob/living/carbon/human])
				human.update_clothing()
				if (prob(40))
					sleep(0.1 SECONDS)
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
	ADMIN_ONLY
	SHOW_VERB_DESC
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
	ADMIN_ONLY
	SHOW_VERB_DESC
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
	var/varedit_link = "<a href='byond://?src=\ref[src];Refresh=\ref[theinstance]'>[theinstance] \ref[theinstance]</a>"
	if (isarea(theinstance))
		var/turf/T = locate(/turf) in theinstance
		if (!T)
			boutput(usr, SPAN_NOTICE("[varedit_link] (no turfs in area)."))
		else
			boutput(usr, SPAN_NOTICE("[varedit_link] including [showMyCoords(T.x, T.y, T.z)]."))
	else if (isturf(theinstance))
		boutput(usr, SPAN_NOTICE("[varedit_link] at [showMyCoords(theinstance.x, theinstance.y, theinstance.z)]."))
	else
		var/turf/T = get_turf(theinstance)
		var/in_text = ""
		var/atom/Q = theinstance.loc
		while (Q && Q != T)
			in_text += " in [Q]"
			Q = Q.loc
		boutput(usr, SPAN_NOTICE("[varedit_link][in_text] at [isnull(T) ? "null" : showMyCoords(T.x, T.y, T.z)]"))

/client/proc/find_one_of(var/typename as text)
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set name = "Find One"
	set desc = "Show the location of one instance of type."
	ADMIN_ONLY
	SHOW_VERB_DESC
	var/thetype = get_one_match(typename, /atom, use_concrete_types = FALSE, only_admin_spawnable = FALSE)
	if (thetype)
		var/atom/theinstance = find_first_by_type(thetype)
		if (!theinstance)
			boutput(usr, SPAN_ALERT("Cannot locate an instance of [thetype]."))
			return
		boutput(usr, SPAN_NOTICE("<b>Found instance of [thetype]:</b>"))
		print_instance(theinstance)
	else
		boutput(usr, SPAN_ALERT("No type matches for [typename]."))
		return

/client/proc/find_all_of(var/typename as text)
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set name = "Find All"
	set desc = "Show the location of all instances of a type. Performance warning!!"
	ADMIN_ONLY
	SHOW_VERB_DESC
	var/thetype = get_one_match(typename, /atom, use_concrete_types = FALSE, only_admin_spawnable = FALSE)
	if (thetype)
		boutput(usr, SPAN_NOTICE("<b>All instances of [thetype]: </b>"))
		var/list/all_instances = find_all_by_type(thetype, PROC_REF(print_instance), src)
		boutput(usr, SPAN_NOTICE("Found [length(all_instances)] instances total."))
	else
		boutput(usr, "No type matches for [typename].")
		return

/client/proc/find_thing(var/atom/A as null|anything in world)
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set name = "Find Thing"
	set desc = "Show the location of an atom by name."
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC
	if (!A)
		return

	boutput(usr, SPAN_NOTICE("<b>Located [A] ([A.type]): </b>"))
	print_instance(A)

/client/proc/count_all_of(var/typename as text)
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set name = "Count All"
	set desc = "Returns the number of all instances of a type that exist."
	ADMIN_ONLY
	SHOW_VERB_DESC
	var/thetype = get_one_match(typename, /atom, use_concrete_types = FALSE, only_admin_spawnable = FALSE)
	if (thetype)
		boutput(usr, SPAN_NOTICE("There are <b>[length(find_all_by_type(thetype))]</b> instances total of [thetype]."))
	else
		boutput(usr, SPAN_ALERT("<b>No type matches for [typename].</b>"))
		return

/client/proc/set_admin_level()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Change Admin Level"
	set desc = "Allows you to change your admin level at will for testing. Does not change your available verbs."
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC

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

	ADMIN_ONLY
	SHOW_VERB_DESC
	if (!ishuman(src.mob))
		return boutput(usr, SPAN_ALERT("Error: client mob is invalid type or does not exist"))
	randomize_look(src.mob)
	logTheThing(LOG_ADMIN, usr, "randomized their appearance")
	logTheThing(LOG_DIARY, usr, "randomized their appearance", "admin")

/client/proc/cmd_randomize_handwriting()
	set name = "Randomize Handwriting"
	set desc = "Randomizes how you write on paper."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)

	ADMIN_ONLY
	SHOW_VERB_DESC
	if (src.mob && src.mob.mind)
		src.mob.mind.handwriting = pick(handwriting_styles)
		boutput(usr, SPAN_NOTICE("Handwriting style is now: [src.mob.mind.handwriting]"))
		logTheThing(LOG_ADMIN, usr, "randomized their handwriting style: [src.mob.mind.handwriting]")
		logTheThing(LOG_DIARY, usr, "randomized their handwriting style: [src.mob.mind.handwriting]", "admin")

#ifdef MACHINE_PROCESSING_DEBUG
/client/proc/cmd_display_detailed_machine_stats()
	set name = "Machine stats"
	set desc = "Displays the statistics for how machines are processed."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY
	SHOW_VERB_DESC

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


/client/proc/cmd_display_detailed_power_stats()
	set name = "Machine Power stats"
	set desc = "Displays the statistics for how much power machines are using."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(holder)
		var/datum/power_usage_viewer/E = new(src.mob)
		E.ui_interact(mob)

	return
#endif

#ifdef QUEUE_STAT_DEBUG
/client/proc/cmd_display_queue_stats()
	set name = "Queue stats"
	set desc = "Displays the statistics for how queue stuff is processed."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY
	SHOW_VERB_DESC

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
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/icon/new_style = input("Please choose a new icon file to upload", "Upload Icon") as null|icon
	if (!isicon(new_style))
		return
	var/new_style_name = input("Please enter a new name for your HUD", "Enter Name") as null|text
	if (!new_style_name)
		boutput(src, SPAN_ALERT("Cannot create a HUD with no name![prob(5) ? " It's not a horse!" : null]")) // c:
		return
	if (alert("Create: \"[new_style_name]\" with icon [new_style]?", "Confirmation", "Yes", "No") == "Yes")
		hud_style_selection[new_style_name] = new_style
		logTheThing(LOG_ADMIN, usr, "added a new HUD style with the name \"[new_style_name]\"")
		logTheThing(LOG_DIARY, usr, "added a new HUD style with the name \"[new_style_name]\"", "admin")
		message_admins("[key_name(usr)] added a new HUD style with the name \"[new_style_name]\"")


/client/proc/random_color_matrix()
	set name = "Random Color Matrix Test"
	set desc = "Animates the client to a randomised color matrix"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(!islist(usr.client.color))
		src.set_color()

	var/list/newColorMatrix = generate_random_value_list(2, 20)
	src.animate_color(newColorMatrix)

	var/matrixTable = "<table>"
	var/isBigMatrix = (length(newColorMatrix) == 20)
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


/client/proc/test_mass_flock_convert(force as num|null, radius as num|null, fancy as num|null)
	set name = "Mass Flock Convert"
	set desc = "Convert a part of the area to flock"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(isnull(force))
		force = tgui_alert(src, "Force convert unsimulated too?", "Force?", list("Yes", "No")) == "Yes"
	if(isnull(radius))
		radius = tgui_input_number(src, "Tile radius:", "Tile radius", 300, max_value=300, min_value=0)
	if(isnull(radius) || radius <= 0)
		return
	if(isnull(fancy))
		fancy = tgui_alert(src, "Recolor misc stuff?", "Fancy?", list("Yes", "No")) == "Yes"

	if(radius > 15 && tgui_alert(src, "This will IRREVERSIBLY FUCK UP the current zlevel and might be laggy, do not use this live with such a high radius. Are you sure?","Misclick Prevention",list("Yes","No")) != "Yes")
		return

	logTheThing(LOG_ADMIN, usr, "started a mass flocktile conversion at [log_loc(usr)] with [radius] radius and force=[force]")
	logTheThing(LOG_DIARY, usr, "started a mass flocktile conversion at [log_loc(usr)] with [radius] radius and force=[force]", "admin")
	message_admins("[key_name(usr)] started a mass flocktile conversion at [log_loc(usr)] with [radius] radius and force=[force]")
	mass_flock_convert_turf(get_turf(usr), null, radius=radius, force=force, fancy=fancy)

var/datum/flock/testflock
/client/proc/test_flock_panel()
	set name = "Test Flock Panel"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(isnull(testflock))
		testflock = new()

	testflock.ui_interact(usr, testflock.flockpanel)

/client/proc/clear_string_cache()
	set name = "Clear String Cache"
	set desc = "Invalidates/clears the string cache to allow for files to be reloaded."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(alert("Really clear the string cache?","Invalidate String Cache","OK","Cancel") == "OK")
		var/length = length(string_cache)
		string_cache = new
		logTheThing(LOG_ADMIN, usr, "cleared the string cache, clearing [length] existing list(s).")
		logTheThing(LOG_DIARY, usr, "cleared the string cache, clearing [length] existing list(s).", "admin")
		boutput(src, "String cache invalidated. [length] list(s) cleared.")

/client/proc/temporary_deadmin_self()
	set name = "Temp. Deadmin Self"
	set desc = "Deadmin you're own self. Temporarily."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(src.holder)
		var/seconds = input("How many seconds would you like to be deadminned?", "Temporary Deadmin", 60) as num
		boutput(src, "<B><I>You have been deadminned for [seconds] seconds.</I></B>")
		src.clear_admin()
		SPAWN(seconds * 10)
			src.init_admin()
			boutput(src, "<B><I>Your adminnery has returned.</I></B>")

#ifdef ENABLE_SPAWN_DEBUG
/client/proc/spawn_dbg()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Debug Spawn"
	set desc = "Displays all the spawns that've happened so far or dies trying"
	ADMIN_ONLY
	SHOW_VERB_DESC
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
	ADMIN_ONLY
	SHOW_VERB_DESC
	if(src.holder)
		if(!src.mob)
			return
		var/fname = "spawn_dbg.json"
		rustg_file_write(json_encode(list("spawn" = detailed_spawn_dbg)), fname)
		var/tmp_file = file(fname)
		usr << ftp(tmp_file)
		fdel(fname)
#endif

/client/proc/debugAddComponent(var/datum/target = null)
	var/pathpart = input("Part of component path.", "Part of component path.", "") as null|text
	if(!pathpart)
		pathpart = "/"
	var/comptype = get_one_match(pathpart, /datum/component)
	if(!comptype)
		return

	var/typeinfo/datum/component/TI = get_type_typeinfo(comptype)

	var/list/listargs = src.get_proccall_arglist(TI.initialization_args)

	var/returnval = target._AddComponent(list(comptype) + listargs)


	boutput(usr, SPAN_NOTICE("Returned: [!isnull(returnval) ? returnval : "null"]"))

/client/proc/debugRemoveComponent(var/datum/target = null)
	var/list/dc = target.datum_components
	if(!dc)
		boutput(usr, SPAN_NOTICE("No components present on [target]."))
		return

	var/list/comps = dc[/datum/component]
	if(!islist(comps))
		comps = list(comps)

	var/datum/component/selection
	selection = tgui_input_list(usr, "Select a component to remove", "Matches for pattern", comps)
	if (!selection)
		return // user cancelled

	selection.RemoveComponent()
	boutput(usr, SPAN_NOTICE("Removed [selection] from [target]."))

/client/proc/delete_profiling_logs()
	set desc = "Delete all saved profiling data, I hope you know what you're doing."
	set name = "Delete profiling logs"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(input(usr, "Type in: 'delete profiling logs' to confirm:", "Confirmation of prof. logs deletion") != "delete profiling logs")
		boutput(usr, "Deletion of profiling logs aborted.")
		return
	fdel("data/logs/profiling/")
	logTheThing(LOG_ADMIN, usr, "deleted profiling logs.")
	logTheThing(LOG_DIARY, usr, "deleted profiling logs.")
	message_admins("[key_name(usr)] deleted profiling logs.")
	ircbot.export_async("admin_debug", list("key"=usr.ckey, "msg"="deleted profiling logs for this server."))

/client/proc/cause_lag(a as num, b as num)
	set desc = "Loops a times b times over some trivial statement."
	set name = "cause lag"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(alert("Are you sure you want to cause lag?","Why would you do this?","Yes","No") != "Yes")
		return

	logTheThing(LOG_ADMIN, usr, "decided to cause lag with parameters of [a] and [b]")

	var/x = 0
	boutput(src, "lag start [world.time] [TIME] (x=[x])")
	for(var/i in 1 to a)
		for(var/j in 1 to b)
			x++
	boutput(usr, "lag end [world.time] [TIME] (x=[x])")

/client/proc/persistent_lag(cpu_usage as num)
	set desc = "Makes it so lag is at least the set number."
	set name = "persistent lag"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(alert("Are you sure you want to set persistent lag to [cpu_usage]?","Why would you do this?","Yes","No") != "Yes")
		return

	logTheThing(LOG_ADMIN, usr, "decided to set persistent lag to [cpu_usage]%.")

	var/static/target_lag = null
	target_lag = cpu_usage
	while(target_lag > 0)
		var/last_tick = world.time
		while(world.tick_usage < target_lag)
			;
		while(world.time == last_tick)
			sleep(0.001)

/client/proc/list_adminteract_buttons()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/list/lines = list("<html><head><title>Admin Interact Buttons</title></head><body>")
	for(var/type in typesof(/typeinfo/atom))
		var/typeinfo/atom/typeinfo = get_singleton(type)
		var/list/procpath/proc_paths = typeinfo.admin_procs
		var/typeinfo/atom/parent_typeinfo = get_singleton(type2parent(typeinfo))
		if(istype(parent_typeinfo))
			proc_paths = proc_paths - parent_typeinfo.admin_procs // remove inherited procs
			// also note that we do NOT want -= here because that would edit the list in the typeinfo
		if(length(proc_paths))
			var/name = copytext("[typeinfo]", 10)
			lines += "<b>[name]</b><ul>"
			for(var/procpath/proc_path as anything in proc_paths)
				var/proc_name = proc_path.name
				if (!proc_name)
					var/split_list = splittext("[proc_path]", "/")
					proc_name = split_list[length(split_list)]
				lines += "<li>[proc_name]</li>"
			lines += "</ul>"

	lines += "</body></html>"
	src.Browse(lines.Join(), "window=adminteract_buttons;size=300x800")

// see code/modules/disposals/disposal_test.dm for documentation
/client/proc/dbg_disposal_system()
	set name ="Test Disposal System"
	set desc = "Test disposal and mail chutes for broken routing."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/input_x = input(usr, "Enter X coordinate") as null | num
	if(isnull(input_x))
		return
	var/input_y = input(usr, "Enter Y coordinate") as null | num
	if(isnull(input_y))
		return
	var/sleep_time = input(usr, "Enter time to sleep (in seconds)", null, 120) as null | num
	if(isnull(sleep_time))
		return
	var/include_mail = alert(usr, "Test mail system?", null, "Yes", "No")
	if(isnull(include_mail)) // somehow
		return
	test_disposal_system(input_x, input_y, sleep_time SECONDS, include_mail == "Yes" ? TRUE : FALSE)


#undef ARG_INFO_NAME
#undef ARG_INFO_TYPE
#undef ARG_INFO_DESC
#undef ARG_INFO_DEFAULT
