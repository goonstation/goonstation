/verb/restart_the_fucking_server_i_mean_it()
	set name = "Emergency Restart"
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	if(config.update_check_enabled)
		world.installUpdate()
	world.Reboot()

/verb/rebuild_flow_networks()
	set name = "Rebuild Flow Networks"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	make_fluid_networks()

/verb/print_flow_networks()
	set name = "Print Flow Networks"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	DEBUG_MESSAGE("Dumping flow network refs")
	for_by_tcl(network, /datum/flow_network)
		DEBUG_MESSAGE_VARDBG("[showCoords(network.nodes[1].x,network.nodes[1].y,network.nodes[1].z)]", network)
	for_by_tcl(network, /datum/flow_network)
		DEBUG_MESSAGE("Printing flow network rooted at [showCoords(network.nodes[1].x,network.nodes[1].y,network.nodes[1].z)] (\ref[network])")
		// Clear DFS flags
		network.clear_DFS_flags()
		DFS_LOUD(network.nodes[1])

/client/proc/cmd_admin_drop_everything(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	set name = "Drop Everything"
	ADMIN_ONLY

	M.unequip_all()

	logTheThing(LOG_ADMIN, usr, "made [constructTarget(M,"admin")] drop everything!")
	logTheThing(LOG_DIARY, usr, "made [constructTarget(M,"diary")] drop everything!", "admin")
	message_admins("[key_name(usr)] made [key_name(M)] drop everything!")

/client/proc/cmd_admin_prison_unprison(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	set name = "Prison"
	ADMIN_ONLY

	if (M && ismob(M))
		var/area/A = get_area(M)
		if (A && istype(A, /area/prison/cell_block/wards))
			if (alert(src, "Do you wish to unprison [M.name]?", "Confirmation", "Yes", "No") != "Yes")
				return
			if (!M || !ismob(M))
				return

			var/ASLoc = pick_landmark(LANDMARK_LATEJOIN, locate(1, 1, 1))
			if (ASLoc)
				M.set_loc(ASLoc)

			M.show_text("<h2><font color=red><b>You have been unprisoned and sent back to the station.</b></font></h2>", "red")
			message_admins("[key_name(usr)] has unprisoned [key_name(M)].")
			logTheThing(LOG_ADMIN, usr, "has unprisoned [constructTarget(M,"admin")].")
			logTheThing(LOG_DIARY, usr, "has unprisoned [constructTarget(M,"diary")].", "admin")

		else
			if (isAI(M))
				alert("Sending the AI to the prison zone would be ineffective.", null, null, null, null, null)
				return
			if (alert(src, "Do you wish to send [M.name] to the prison zone?", "Confirmation", "Yes", "No") != "Yes")
				return
			if (!M || !ismob(M) || (M && isobserver(M)))
				return

			var/PLoc = pick_landmark(LANDMARK_PRISONWARP)
			if (PLoc)
				M.changeStatus("paralysis", 8 SECONDS)
				M.set_loc(PLoc)
			else
				message_admins("[key_name(usr)] couldn't send [key_name(M)] to the prison zone (no landmark found).")
				logTheThing(LOG_ADMIN, usr, "couldn't send [constructTarget(M,"admin")] to the prison zone (no landmark found).")
				logTheThing(LOG_DIARY, usr, "couldn't send [constructTarget(M,"diary")] to the prison zone (no landmark found).")
				return

			M.show_text("<h2><font color=red><b>You have been sent to the penalty box, and an admin should contact you shortly. If nobody does within a minute or two, please inquire about it in adminhelp (F1 key).</b></font></h2>", "red")
			logTheThing(LOG_ADMIN, usr, "sent [constructTarget(M,"admin")] to the prison zone.")
			logTheThing(LOG_DIARY, usr, "[constructTarget(M,"diary")] to the prison zone.", "admin")
			message_admins("<span class='internal'>[key_name(usr)] sent [key_name(M)] to the prison zone.</span>")

	return

/client/proc/cmd_admin_subtle_message(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Subtle Message"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	var/client/Mclient = M.client

	var/msg = input("Message:", text("Subtle PM to [Mclient.key]")) as null|text

	if (!msg)
		return
	if (src?.holder)
		M.playsound_local(M, 'sound/misc/prayerchime.ogg', 100, flags = SOUND_IGNORE_SPACE, channel = VOLUME_CHANNEL_MENTORPM)
		boutput(Mclient.mob, "<span class='notice'>You hear a voice in your head... <i>[msg]</i></span>")

	logTheThing(LOG_ADMIN, src.mob, "Subtle Messaged [constructTarget(Mclient.mob,"admin")]: [msg]")
	logTheThing(LOG_DIARY, src.mob, "Subtle Messaged [constructTarget(Mclient.mob,"diary")]: [msg]", "admin")

	var/subtle_href = null
	if(M.client)
		subtle_href = "?src=%admin_ref%;action=subtlemsg&targetckey=[M.client.ckey]"
	message_admins("<span class='internal'><b>SubtleMessage: [key_name(src.mob)] <i class='icon-arrow-right'></i> [key_name(Mclient.mob, custom_href=subtle_href)] : [msg]</b></span>")

/client/proc/cmd_admin_plain_message(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Plain Message"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	var/client/Mclient = M.client

	var/msg = input("Message:", text("Plain message to [Mclient.key]")) as null|text

	if(!(src.holder.level >= LEVEL_PA))
		msg = strip_html(msg)

	if (!msg)
		return
	if (src?.holder)
		boutput(Mclient.mob, "<span class='alert'>[msg]</span>")

	logTheThing(LOG_ADMIN, src.mob, "Plain Messaged [constructTarget(Mclient.mob,"admin")]: [html_encode(msg)]")
	logTheThing(LOG_DIARY, src.mob, ": Plain Messaged [constructTarget(Mclient.mob,"diary")]: [html_encode(msg)]", "admin")
	message_admins("<span class='internal'><b>PlainMSG: [key_name(src.mob)] <i class='icon-arrow-right'></i> [key_name(Mclient.mob)] : [html_encode(msg)]</b></span>")

/client/proc/cmd_admin_plain_message_all()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Plain Message to All"

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	var/msg = input("Message:", text("Plain message to all")) as null|text

	if(!(src.holder.level >= LEVEL_PA))
		msg = strip_html(msg)

	if (!msg)
		return
	if (src?.holder)
		boutput(world, "[msg]")

	logTheThing(LOG_ADMIN, src.mob, "Plain Messaged All: [html_encode(msg)]")
	logTheThing(LOG_DIARY, src.mob, "Plain Messaged All: [html_encode(msg)]", "admin")
	message_admins("<span class='internal'>[key_name(src.mob)] showed a plain message to all</span>")

/client/proc/cmd_admin_pm(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Admin PM"
	set popup_menu = 0

	ADMIN_ONLY

	do_admin_pm(M.ckey, src.mob) //Changed to work off of ckeys instead of mobs.




/client/proc/cmd_admin_alert(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set name = "Admin Alert"
	set popup_menu = 0
	ADMIN_ONLY

	var/client/Mclient = M.client

	var/t = input("Message:", text("Messagebox to [Mclient.key]")) as null|text

	if(!t) return

	message_admins("[key_name(src.mob)] displayed an alert to [key_name(Mclient.mob)] with the message \"[t]\"")
	logTheThing(LOG_ADMIN, src.mob, "displayed an alert to [constructTarget(Mclient.mob,"admin")] with the message \"[t]\"")
	logTheThing(LOG_DIARY, src.mob, "displayed an alert to [constructTarget(Mclient.mob,"diary")] with the message \"[t]\"", "admin")

	if(Mclient?.mob)
		SPAWN(0)
			var/sound/honk = sound('sound/voice/animal/goose.ogg')
			honk.volume = 75
			Mclient.mob << honk
			if(alert(Mclient.mob, t, "!! Admin Alert !!", "OK") == "OK") //I have a sneaking suspicion the "OK" button text depends on locale and fuck dealing with that
				message_admins("[key_name(Mclient.mob)] acknowledged the alert from [key_name(src.mob)].")



/*
/proc/pmwin(mob/M as mob in world, msg)

	var/title = ""

	var/body = "<ol><center>ADMIN PM</center><br><br>"

	var/admin_pm = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))

	var/pm_in_browser = "<center>Click on my name to respond.</center><br><br>"

	pm_in_browser += "Admin PM from-<b>[key_name(usr, M, 0)]</b>"


	pm_in_browser += "<br><br><p>[admin_pm]"

	body += pm_in_browser

	body += "</ol>"

	var/html = "<html><head>"
	if (title)
		html += "<title>[title]</title>"
	html += {"<style>
	body
	{
		font-family: Verdana;
		font-size: 16pt; color: red;
	}
	p
	{
		 font-family: Verdana;
		 font-size: 16pt; color: black;
	}
	</style>"}
	html += "</head><body>"
	html += body
	html += "</body></html>"

	M.Browse(html, "window=adminpm;size=700x300")
	return
*/

/client/proc/cmd_admin_mute(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	set name = "Mute Permanently"
	ADMIN_ONLY
	if (M.client && M.client.holder && (M.client.holder.level >= src.holder.level))
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
		return
	if (!M.client)
		return
	var/muted = 0
	if (M.client.ismuted())
		M.client.unmute()
	else
		M.client.mute(-1)
		muted = 1

	logTheThing(LOG_ADMIN, src, "has [(muted ? "permanently muted" : "unmuted")] [constructTarget(M,"admin")].")
	logTheThing(LOG_DIARY, src, "has [(muted ? "permanently muted" : "unmuted")] [constructTarget(M,"diary")].", "admin")
	message_admins("[key_name(src)] has [(muted ? "permanently muted" : "unmuted")] [key_name(M)].")

	boutput(M, "You have been [(muted ? "permanently muted" : "unmuted")].")

/client/proc/cmd_admin_mute_temp(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	set name = "Mute Temporarily"
	ADMIN_ONLY
	if (M.client && M.client.holder && (M.client.holder.level >= src.holder.level))
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
		return
	if (!M.client)
		return
	var/muted = 0
	if (M.client.ismuted())
		M.client.unmute()
	else
		M.client.mute(60)
		muted = 1

	logTheThing(LOG_ADMIN, src, "has [(muted ? "temporarily muted" : "unmuted")] [constructTarget(M,"admin")].")
	logTheThing(LOG_DIARY, src, "has [(muted ? "temporarily muted" : "unmuted")] [constructTarget(M,"diary")].", "admin")
	message_admins("[key_name(src)] has [(muted ? "temporarily muted" : "unmuted")] [key_name(M)].")

	boutput(M, "You have been [(muted ? "temporarily muted" : "unmuted")].")

/client/proc/cmd_admin_add_freeform_ai_law()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set name = "AI: Add Law"

	ADMIN_ONLY

	var/input = input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "Law for default AI law rack", "") as text
	if (!input)
		return

	var/law_num = input(usr, "Which slot should this go in? It will override anything in an occupied slot (1-9)", "Enter law number", 9) as null|num
	if (isnull(law_num))
		return
	if (law_num < 1 || law_num > 9)
		return
	else
		ticker.ai_law_rack_manager.default_ai_rack.SetLawCustom("Centcom Law Module",input,law_num,TRUE,TRUE)
	boutput(usr, "Uploaded '[input]' as law # [law_num]")
	ticker.ai_law_rack_manager.default_ai_rack.UpdateLaws() //I don't love this, but meh


	logTheThing(LOG_ADMIN, usr, "has added a new AI law - [input] (law # [law_num])")
	logTheThing(LOG_DIARY, usr, "has added a new AI law - [input] (law # [law_num])", "admin")
	logTheThing(LOG_ADMIN, null, "Resulting AI Lawset:<br>[ticker.ai_law_rack_manager.default_ai_rack.format_for_logs()]")
	logTheThing(LOG_DIARY, null, "Resulting AI Lawset:<br>[ticker.ai_law_rack_manager.default_ai_rack.format_for_logs()]", "admin")
	message_admins("Admin [key_name(usr)] has added a new AI law - [input] (law # [law_num])")

//badcode from Somepotato, pls no nerf its very bad AAA
/client/proc/cmd_admin_bulk_law_change()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set name = "AI: Bulk Law Change"
	ADMIN_ONLY

	var/input = input(usr, "Replace all AI laws with what? Seriously. It's true, [pick("Somepotato only adds gimmicks.", "alter them to whatever you want friend.")]", "Bulk Law Modification", "") as message
	var/list/split = splittext(input, "\n")
	ticker.ai_law_rack_manager.default_ai_rack.DeleteAllLaws()
	for(var/i = 1, i <= 9, i++)
		if(i < split.len)
			ticker.ai_law_rack_manager.default_ai_rack.SetLawCustom("Centcom Law Module",split[i],i,true,true)
	ticker.ai_law_rack_manager.default_ai_rack.UpdateLaws()
	logTheThing(LOG_ADMIN, usr, "has set the AI laws to [input]")
	logTheThing(LOG_DIARY, usr, "has set the AI laws to [input]", "admin")
	logTheThing(LOG_ADMIN, usr, "Resulting AI Lawset:<br>[ticker.ai_law_rack_manager.default_ai_rack.format_for_logs()]")
	logTheThing(LOG_DIARY, usr, "Resulting AI Lawset:<br>[ticker.ai_law_rack_manager.default_ai_rack.format_for_logs()]", "admin")
	message_admins("Admin [key_name(usr)] has adjusted all of the AI's laws!")



/client/proc/cmd_admin_show_ai_laws()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set name = "AI: Show Laws"
	boutput(usr, "The AI laws are:")
	if (ticker.ai_law_rack_manager == null)
		boutput(usr, "Oh god somehow the law rack manager is null. This is real bad. Contact an admin. You are an admin? Oh no...")
	else
		boutput(usr,ticker.ai_law_rack_manager.format_for_logs(round_end = TRUE))
	return

/client/proc/cmd_admin_reset_ai()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set name = "AI: Law Reset"
	ADMIN_ONLY

	if (alert(src, "Are you sure you want to reset the AI's laws?", "Confirmation", "Yes", "No") == "Yes")
		ticker.ai_law_rack_manager.default_ai_rack.DeleteAllLaws()
		ticker.ai_law_rack_manager.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov1,1,true,true)
		ticker.ai_law_rack_manager.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov2,2,true,true)
		ticker.ai_law_rack_manager.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov3,3,true,true)
		ticker.ai_law_rack_manager.default_ai_rack.UpdateLaws()

		logTheThing(LOG_ADMIN, usr, "reset the centralized AI laws.")
		logTheThing(LOG_DIARY, usr, "reset the centralized AI laws.", "admin")
		message_admins("Admin [key_name(usr)] reset the centralized AI laws.")

/client/proc/cmd_admin_rejuvenate(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Heal"
	set popup_menu = 0
	ADMIN_ONLY
	if(!src.mob)
		return
	if(isobserver(M))
		alert("Cannot revive a ghost")
		return
	if(config.allow_admin_rev)
		M.full_heal()

		logTheThing(LOG_ADMIN, usr, "healed / revived [constructTarget(M,"admin")]")
		logTheThing(LOG_DIARY, usr, "healed / revived [constructTarget(M,"diary")]", "admin")
		message_admins("<span class='alert'>Admin [key_name(usr)] healed / revived [key_name(M)]!</span>")
	else
		alert("Admin revive disabled")

/client/proc/cmd_admin_rejuvenate_all()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Heal All"

	ADMIN_ONLY
	if (alert(src, "Are you sure?", "Confirmation", "Yes", "No") == "Yes")
		var/heal_dead = alert(src, "Heal and revive the dead?", "Confirmation", "Yes", "No")
		var/healed = 0
		if (config.allow_admin_rev)
			for (var/mob/living/H in mobs)
				if (H.stat && heal_dead != "Yes")
					continue
				H.full_heal()
				healed ++
		else
			alert("Admin revive disabled")
			return

		logTheThing(LOG_ADMIN, usr, "healed / revived [healed] mobs via Heal All")
		logTheThing(LOG_DIARY, usr, "healed / revived [healed] mobs via Heal All", "admin")
		message_admins("<span class='alert'>Admin [key_name(usr)] healed / revived [healed] mobs via Heal All!</span>")

/client/proc/cmd_admin_create_centcom_report()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Create Command Report"
	ADMIN_ONLY
	var/input = input(usr, "Enter the text for the alert. Anything. Serious.", "What?", "") as null|message
	if(!input)
		return
	var/input2 = input(usr, "Add a headline for this alert? leaving this blank creates no headline", "What?", "") as null|text
	var/input3 = input(usr, "Add an origin to the transmission, leaving this blank 'Central Command Update'", "What?", "") as null|text
	if(!input3)
		input3 = "Central Command Update"

	if (alert(src, "Origin: [input3 ? "\"[input3]\"" : "None"]\nHeadline: [input2 ? "\"[input2]\"" : "None"]\nBody: \"[input]\"", "Confirmation", "Send Report", "Cancel") == "Send Report")
		for_by_tcl(C, /obj/machinery/communications_dish)
			C.add_centcom_report(input2, input)

		var/sound_to_play = 'sound/misc/announcement_1.ogg'
		command_alert(input, input2, sound_to_play, alert_origin = input3);

		logTheThing(LOG_ADMIN, src, "has created a command report: [input]")
		logTheThing(LOG_DIARY, src, "has created a command report: [input]", "admin")
		message_admins("[key_name(src)] has created a command report")

/client/proc/cmd_admin_create_advanced_centcom_report()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Adv. Command Report"
	ADMIN_ONLY

	var/input = input(usr, "Please enter anything you want. Anything. Serious.", "What?", "") as null|message
	if (!input)
		return
	var/input2 = input(usr, "Add a headline for this alert?", "What?", "") as null|text
	if (alert(src, "Headline: [input2 ? "\"[input2]\"" : "None"] | Body: \"[input]\"", "Confirmation", "Send Report", "Cancel") == "Send Report")
		var/sound_to_play = 'sound/misc/announcement_1.ogg'
		advanced_command_alert(input, input2, sound_to_play);

		logTheThing(LOG_ADMIN, src, "has created an advanced command report: [input]")
		logTheThing(LOG_DIARY, src, "has created an advanced command report: [input]", "admin")
		message_admins("[key_name(src)] has created an advanced command report")

/client/proc/cmd_admin_advanced_centcom_report_help()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Adv. Command Report - Help"
	ADMIN_ONLY

	var/T = {"<TT><h1>Advanced Command Report</h1><hr>
	This report works exactly like the normal report, except it sends a tailored message
	to each mob in the world, replacing some values with values applicable to them.
	If you're not planning to use this feature, then I recommend the normal command report as it is
	less demanding on resources.
	<table border=1>
		<tr>
			<td>%name%
			<td>The name of the mob currently viewing the report
		<tr>
			<td>%key%
			<td>The key of the mob currently viewing the report
		<tr>
			<td>%job%
			<td>The job of the mob currently viewing the report
		<tr>
			<td>%area_name%
			<td>The name of the area where the mob currently viewing the report is.
		<tr>
			<td>%srand_name%
			<td>The name of a random player, this is the same for everyone viewing the report.
		<tr>
			<td>%srand_job%
			<td>The job of a random player, this is the same for everyone viewing the report.
		<tr>
			<td>%mrand_name%
			<td>The name of a random player, this is <B>different</B> for everyone viewing the report.
		<tr>
			<td>%mrand_job%
			<td>The job of a random player, this is <B>different</B> for everyone viewing the report.

		</table>"}
	usr.Browse(T, "window=adv_com_help;size=700x500")

/client/proc/cmd_admin_delete(atom/O as obj|mob|turf in world)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Delete"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (alert(src, "Are you sure you want to delete:\n[O]\nat ([O.x], [O.y], [O.z])?", "Confirmation", "Yes", "No") == "Yes")
		logTheThing(LOG_ADMIN, usr, "deleted [O] at ([log_loc(O)])")
		logTheThing(LOG_DIARY, usr, "deleted [O] at ([log_loc(O)])", "admin")
		message_admins("[key_name(usr)] deleted [O] at ([log_loc(O)])")
		if (flourish)
			leaving_animation(O)
		qdel(O)
		O=null

/client/proc/cmd_admin_check_contents(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Check Contents"
	set popup_menu = 0

	if (M && ismob(M))
		M.print_contents(usr)
	return

/client/proc/cmd_admin_check_vehicle()
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set name = "Check Vehicle Occupant"
	set popup_menu = 0

	var/list/piloted_vehicles = list()

	for_by_tcl(V, /obj/machinery/vehicle)
		if (locate(/mob) in V) //also finds vehicles that only have passengers in case you're looking for waldo or something
			piloted_vehicles += V

	for_by_tcl(V, /obj/vehicle)
		if (V.rider)
			piloted_vehicles += V

	if (!length(piloted_vehicles))
		boutput(usr, "No piloted vehicles found!")
		return

	var/obj/V = tgui_input_list(usr, "Which vehicle?", "Check vehicle occupant", piloted_vehicles)
	if (!V)
		return

	boutput(usr, "<b>[V.name]'s Occupants:</b>")
	var/obj/machinery/vehicle/MV = V
	ENSURE_TYPE(MV)
	for(var/mob/M in V.contents)
		var/info = ""
		info = M == MV?.pilot ? "*Pilot*" : ""
		var/role = getRole(M)
		boutput(usr, "<span class='notice'><b>[key_name(M, 1, 0)][role ? " ([role])" : ""] [info]</b></span>")

/client/proc/cmd_admin_remove_plasma()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set name = "Stabilize Atmos."
	set desc = "Resets the air contents of every turf in view to normal."
	ADMIN_ONLY
	SPAWN(0)
		for(var/turf/simulated/T in view())
			if(!T.air)
				continue
			ZERO_BASE_GASES(T.air)
#ifdef ATMOS_ARCHIVING
			ZERO_ARCHIVED_BASE_GASES(T.air)
			T.air.ARCHIVED(temperature) = null
#endif
			T.air.oxygen = MOLES_O2STANDARD
			T.air.nitrogen = MOLES_N2STANDARD
			T.air.fuel_burnt = 0
			T.air.clear_trace_gases()
			T.air.temperature = T20C
			LAGCHECK(LAG_LOW)

/client/proc/flip_view()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Flip View"
	set desc = "Rotates a client's viewport"

	var/list/keys = list()
	for(var/mob/M in mobs)
		keys += M.client
	var/client/selection = input("Please, select a player!", "HEH", null, null) as null|anything in keys
	if(!selection)
		return

	var/rotation = input("Select rotation:", "FUCK YE", "0°") in list("0°", "90°", "180°", "270°")

	switch(rotation)
		if("0°")
			selection.dir = NORTH
		if("90°")
			selection.dir = EAST
		if("180°")
			selection.dir = SOUTH
		if("270°")
			selection.dir = WEST

	logTheThing(LOG_ADMIN, usr, "set [constructTarget(selection,"admin")]'s viewport orientation to [rotation].")
	logTheThing(LOG_DIARY, usr, "set [constructTarget(src,"diary")]'s viewport orientation to [rotation].", "admin")
	message_admins("<span class='internal'>[key_name(usr)] set [key_name(selection)]'s viewport orientation to [rotation].</span>")

/client/proc/cmd_admin_clownify(mob/living/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Clownify"
	set popup_menu = 0
	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
	smoke.set_up(5, 0, M.loc)
	smoke.attach(M)
	smoke.start()

	boutput(M, "<span class='alert'><B>You HONK painfully!</B></span>")
	M.take_brain_damage(80)
	M.stuttering = 120
	M.contract_disease(/datum/ailment/disease/cluwneing_around/cluwne, null, null, 1) // path, name, strain, bypass resist
	M.contract_disease(/datum/ailment/disability/clumsy/cluwne, null, null, 1) // path, name, strain, bypass resist
	M.job = "Cluwne"
	M.change_misstep_chance(66)

	M.unequip_all()

	if(ishuman(M))
		var/mob/living/carbon/human/cursed = M
		cursed.equip_if_possible(new /obj/item/clothing/under/gimmick/cursedclown(cursed), cursed.slot_w_uniform)
		cursed.equip_if_possible(new /obj/item/clothing/shoes/cursedclown_shoes(cursed), cursed.slot_shoes)
		cursed.equip_if_possible(new /obj/item/clothing/mask/cursedclown_hat(cursed), cursed.slot_wear_mask)
		cursed.equip_if_possible(new /obj/item/clothing/gloves/cursedclown_gloves(cursed), cursed.slot_gloves)

		logTheThing(LOG_ADMIN, usr, "clownified [constructTarget(M,"admin")]")
		logTheThing(LOG_DIARY, usr, "clownified [constructTarget(M,"diary")]", "admin")
		message_admins("[key_name(usr)] clownified [key_name(M)]")

		M.real_name = "cluwne"
		M.UpdateName()
		SPAWN(2.5 SECONDS) // Don't remove.
			if (M) M.assign_gimmick_skull() // The mask IS your new face (Convair880).

/client/proc/cmd_admin_view_playernotes(target as text)
	set name = "View Player Notes"
	set desc = "View the notes for a current player's key."
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	ADMIN_ONLY

	src.holder.viewPlayerNotes(ckey(target))

/client/proc/cmd_admin_set_loginnotice(target as text)
	set name = "Set Player LoginNotice"
	set desc = "Change a player's login notice."
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	ADMIN_ONLY

	src.holder.setLoginNotice(ckey(target))

/client/proc/cmd_admin_polymorph(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Polymorph Player"
	set desc = "Futz with a human mob's DNA."
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if(!ishuman(M))
		alert("Invalid mob")
		return

	new /datum/polymorph_menu(src, M)
	return

/datum/polymorph_menu
	var/client/usercl = null
	var/cinematic = "None"

	var/mob/living/carbon/human/target_mob = null
	var/real_name = "A Jerk"
	var/hair_override = 0
	var/update_wearid = 0

	var/datum/bioHolder/tf_holder
	var/datum/mutantrace/mutantrace = null

	var/icon/preview_icon = null

	New(var/client/newuser, var/mob/target)
		..()
		if(!newuser || !ishuman(target))
			qdel(src)
			return

		src.tf_holder = new
		src.target_mob = target
		src.usercl = newuser
		src.load_mob_data(src.target_mob)
		src.update_menu()
		src.process()
		return

	disposing()
		if(usercl?.mob)
			usercl.mob.Browse(null, "window=adminpmorph")
		usercl = null
		target_mob = null
		mutantrace = null
		preview_icon = null
		tf_holder = null
		..()

	Topic(href, href_list) // Assumption here, that we've always been the thing we're TFing into
		USR_ADMIN_ONLY
		if(href_list["close"])
			qdel(src)
			return

		else if (href_list["real_name"])
			var/new_name = input(usr, "Please select a name:", "Polymorph Menu")  as null|text
			//var/list/bad_characters = list("_", "'", "\"", "<", ">", ";", "[", "]", "{", "}", "|", "\\")
			for(var/c in bad_name_characters)
				new_name = replacetext(new_name, c, "")

			if(new_name)
				//Shit guys can name a dude into the entire play of hamlet, if they want.
				//But they  shouldn't.
				if(!(usr.client.holder.level >= LEVEL_ADMIN) && length(new_name) > FULLNAME_MAX)
					new_name = copytext(new_name, 1, FULLNAME_MAX)

				src.real_name = new_name

		else if (href_list["flavor_text"])
			var/new_text = input(usr, "Please enter new flavor text (appears when examining):", "Polymorph Menu", src.tf_holder.mobAppearance.flavor_text) as null|text
			if (isnull(new_text))
				return
			new_text = html_encode(new_text)
			if (!(usr.client.holder.level >= LEVEL_ADMIN) && length(new_text) > FLAVOR_CHAR_LIMIT)
				alert("The entered flavor text is too long. It must be no more than [FLAVOR_CHAR_LIMIT] characters long. The current text will be trimmed down to meet the limit.")
				new_text = copytext(new_text, 1, FLAVOR_CHAR_LIMIT+1)
			src.tf_holder.mobAppearance.flavor_text = new_text

		else if (href_list["customization_first"])
			var/list/customization_types = concrete_typesof(/datum/customization_style)
			var/new_style = select_custom_style(customization_types, usr)

			if (new_style)
				src.tf_holder.mobAppearance.customization_first = new_style
				src.tf_holder.mobAppearance.customization_first_original = new_style

		else if (href_list["customization_second"])
			var/list/customization_types = concrete_typesof(/datum/customization_style)
			var/new_style = select_custom_style(customization_types, usr)

			if (new_style)
				src.tf_holder.mobAppearance.customization_second = new_style
				src.tf_holder.mobAppearance.customization_second_original = new_style

		else if (href_list["customization_third"])
			var/list/customization_types = concrete_typesof(/datum/customization_style)
			var/new_style = select_custom_style(customization_types, usr)

			if (new_style)
				src.tf_holder.mobAppearance.customization_third = new_style
				src.tf_holder.mobAppearance.customization_third_original = new_style

		else if (href_list["age"])
			var/minage = 20
			var/maxage = 99

			if (usr.client.holder.level >= LEVEL_ADMIN)
				minage = -999
				maxage = 999

			var/new_age = input(usr, "Please select type in age: [minage]-[maxage]", "Polymorph Menu")  as num

			if(new_age)
				src.tf_holder.age = clamp(round(text2num(new_age)), minage, maxage)

		else if (href_list["blType"])
			var/blTypeNew = input(usr, "Please select a blood type:", "Polymorph Menu")  as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )

			if (blTypeNew)
				src.tf_holder.bloodType = blTypeNew

		else if (href_list["hair"])
			var/new_hair = input(usr, "Please select hair color.", "Polymorph Menu") as color
			if(new_hair)
				src.tf_holder.mobAppearance.customization_first_color = new_hair
				src.tf_holder.mobAppearance.customization_first_color_original = new_hair

		else if (href_list["facial"])
			var/new_facial = input(usr, "Please select detail 1 color.", "Polymorph Menu") as color
			if(new_facial)
				src.tf_holder.mobAppearance.customization_second_color = new_facial
				src.tf_holder.mobAppearance.customization_second_color_original = new_facial

		else if (href_list["detail"])
			var/new_detail = input(usr, "Please select detail 2 color.", "Polymorph Menu") as color
			if(new_detail)
				src.tf_holder.mobAppearance.customization_third_color = new_detail
				src.tf_holder.mobAppearance.customization_third_color_original = new_detail

		else if (href_list["eyes"])
			var/new_eyes = input(usr, "Please select eye color.", "Polymorph Menu") as color
			if(new_eyes)
				src.tf_holder.mobAppearance.e_color = new_eyes
				src.tf_holder.mobAppearance.e_color_original = new_eyes

		else if (href_list["s_tone"])
			var/new_tone = input(usr, "Please select skin tone color.", "Polymorph Menu")  as color

			if (new_tone)
				src.tf_holder.mobAppearance.s_tone = new_tone
				src.tf_holder.mobAppearance.s_tone_original = new_tone

		else if (href_list["gender"])
			if (src.tf_holder.mobAppearance.gender == FEMALE)
				src.tf_holder.mobAppearance.gender = MALE
			else
				src.tf_holder.mobAppearance.gender = FEMALE

		else if (href_list["hair_override"])
			src.hair_override = !src.hair_override

		else if (href_list["updateid"])
			src.update_wearid = !src.update_wearid

		else if (href_list["mutantrace"])
			if (usr.client.holder.level >= LEVEL_ADMIN)
				var/new_race = input(usr, "Please select mutant race", "Polymorph Menu") as null|anything in (childrentypesof(/datum/mutantrace) + "Remove")

				if (ispath(new_race, /datum/mutantrace))
					src.mutantrace = new new_race
				if (new_race == "Remove")
					src.mutantrace = null
			else
				boutput(src, "You must be at least a Administrator to polymorph mutantraces.")

		else if(href_list["apply"])
			src.copy_to_target()
			logTheThing(LOG_ADMIN, usr, "polymorphed [constructTarget(src.target_mob,"admin")]!")
			logTheThing(LOG_DIARY, usr, "polymorphed [constructTarget(src.target_mob,"diary")]!", "admin")
			message_admins("[key_name(usr)] polymorphed [key_name(src.target_mob)]!")

		else if(href_list["cinematic"])
			var/new_cinema = input(usr, "Please select cinematic mode.", "Polymorph Menu")  as null|anything in list("Smoke","Changeling","Wizard","None")

			if (new_cinema)
				src.cinematic = new_cinema

		src.update_menu()
		return

	proc/load_mob_data(var/mob/living/carbon/human/H)
		if(!ishuman(H) || !H.bioHolder)
			qdel(src)
			return
		if(!src.tf_holder) // but how?
			src.tf_holder = new

		src.tf_holder.CopyOther(H.bioHolder) // load their bioholder into ours

		src.real_name = H.real_name

		src.hair_override = H.hair_override

		if(H.mutantrace)
			src.mutantrace = new H.mutantrace.type
		return

	proc/update_menu()
		if(!usercl)
			qdel(src)
			return
		var/mob/user = usercl.mob
		src.update_preview_icon()
		user << browse_rsc(preview_icon, "polymorphicon.png")

		var/dat = "<html><body>"
		dat += "<b>Name:</b> "
		dat += "<a href='byond://?src=\ref[src];real_name=input'><b>[src.real_name]</b></a> "
		dat += "<br>"

		dat += "<b>Gender:</b> <a href='byond://?src=\ref[src];gender=input'><b>[src.tf_holder.mobAppearance.gender == MALE ? "Male" : "Female"]</b></a><br>"
		dat += "<b>Age:</b> <a href='byond://?src=\ref[src];age=input'>[src.tf_holder.age]</a>"

		dat += "<hr><table><tr><td><b>Body</b><br>"
		dat += "Blood Type: <a href='byond://?src=\ref[src];blType=input'>[src.tf_holder.bloodType]</a><br>"
		dat += "Flavor Text: <a href='byond://?src=\ref[src];flavor_text=input'><small>[length(src.tf_holder.mobAppearance.flavor_text) ? src.tf_holder.mobAppearance.flavor_text : "None"]</small></a><br>"
		dat += "Skin Tone: <a href='byond://?src=\ref[src];s_tone=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"[src.tf_holder.mobAppearance.s_tone]\"><table bgcolor=\"[src.tf_holder.mobAppearance.s_tone]\"><tr><td>ST</td></tr></table></font><br>"
		dat += "Mutant Hair: <a href='byond://?src=\ref[src];hair_override=1'>[src.hair_override ? "YES" : "NO"]</a><br>"

		if (usr.client.holder.level >= LEVEL_ADMIN)
			dat += "Mutant Race: <a href='byond://?src=\ref[src];mutantrace=1'>[src.mutantrace ? capitalize(src.mutantrace.name) : "None"]</a><br>"

		dat += "Update ID/PDA/Manifest: <a href='byond://?src=\ref[src];updateid=1'>[src.update_wearid ? "YES" : "NO"]</a><br>"
		dat += "</td><td><b>Preview</b><br><img src=polymorphicon.png height=64 width=64></td></tr></table>"

		dat += "<hr><b>Bottom Detail</b><br>"
		dat += "<a href='byond://?src=\ref[src];hair=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"[src.tf_holder.mobAppearance.customization_first_color]\"><table bgcolor=\"[src.tf_holder.mobAppearance.customization_first_color]\"><tr><td>C1</td></tr></table></font>"
		dat += "Style: <a href='byond://?src=\ref[src];customization_first=input'>[src.tf_holder.mobAppearance.customization_first.name]</a>"
		dat += "<hr><b>Mid Detail</b><br>"
		dat += "<a href='byond://?src=\ref[src];facial=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"[src.tf_holder.mobAppearance.customization_second_color]\"><table bgcolor=\"[src.tf_holder.mobAppearance.customization_second_color]\"><tr><td>C2</td></tr></table></font>"
		dat += "Style: <a href='byond://?src=\ref[src];customization_second=input'>[src.tf_holder.mobAppearance.customization_second.name]</a>"
		dat += "<hr><b>Top Detail</b><br>"
		dat += "<a href='byond://?src=\ref[src];detail=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"[src.tf_holder.mobAppearance.customization_third_color]\"><table bgcolor=\"[src.tf_holder.mobAppearance.customization_third_color]\"><tr><td>C3</td></tr></table></font>"
		dat += "Style: <a href='byond://?src=\ref[src];customization_third=input'>[src.tf_holder.mobAppearance.customization_third.name]</a>"

		dat += "<hr><b>Eyes</b><br>"
		dat += "<a href='byond://?src=\ref[src];eyes=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"[src.tf_holder.mobAppearance.e_color]\"><table bgcolor=\"[src.tf_holder.mobAppearance.e_color]\"><tr><td>EC</td></tr></table></font>"

		dat += "<hr>"

		dat += "<a href='byond://?src=\ref[src];apply=1'>Apply</a><br>"
		dat += "Cinematic Application: <a href='byond://?src=\ref[src];cinematic=1'>[src.cinematic]</a><br>"
		dat += "</body></html>"

		user.Browse(dat, "window=adminpmorph;size=300x550")
		onclose(user, "adminpmorph", src)
		return

	proc/copy_to_target()
		if(!target_mob || !ishuman(target_mob) || !target_mob.bioHolder)
			return

		target_mob.set_mutantrace(null) // It tries to overwrite the appearanceholder we're trying to overwrite, so we'll let it do that first
		target_mob.bioHolder.CopyOther(src.tf_holder) // load our bioholder into theirs

		var/old_name = target_mob.real_name
		target_mob.real_name = real_name

		if (target_mob.limbs)
			target_mob.limbs.reset_stone()

		if(src.update_wearid && target_mob.wear_id)
			target_mob.choose_name(1,1,target_mob.real_name, force_instead = 1)

		if(src.mutantrace)
			target_mob.set_mutantrace(src.mutantrace.type)

		switch(src.cinematic)
			if("Changeling") //Heh
				target_mob.visible_message("<span class='alert'><b>[target_mob] transforms!</b></span>")

			if("Wizard") //Heh 2: Merlin Edition
				qdel(target_mob.wear_suit)
				qdel(target_mob.head)
				qdel(target_mob.shoes)
				qdel(target_mob.r_hand)
				target_mob.equip_if_possible(new /obj/item/clothing/suit/wizrobe, target_mob.slot_wear_suit)
				target_mob.equip_if_possible(new /obj/item/clothing/head/wizard, target_mob.slot_head)
				target_mob.equip_if_possible(new /obj/item/clothing/shoes/sandal/wizard, target_mob.slot_shoes)
				target_mob.put_in_hand(new /obj/item/staff(target_mob))

				var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
				smoke.set_up(5, 0, target_mob.loc)
				smoke.attach(target_mob)
				smoke.start()

				target_mob.visible_message("<span class='alert'><b>The glamour around [old_name] drops!</b></span>")
				target_mob.say("DISPEL!")

			if("Smoke")
				var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
				smoke.set_up(5, 0, target_mob.loc)
				smoke.attach(target_mob)
				smoke.start()

		sanitize_null_values(target_mob)

		target_mob.hair_override = src.hair_override

		target_mob.bioHolder.mobAppearance.UpdateMob()
		target_mob.update_colorful_parts()
		return

	proc/sanitize_null_values(var/mob/living/carbon/human/target_mob)
		if (!target_mob || !target_mob.bioHolder || !target_mob.bioHolder.mobAppearance) return
		var/datum/appearanceHolder/AH = target_mob.bioHolder.mobAppearance
		if (!src.tf_holder.mobAppearance.gender || !(src.tf_holder.mobAppearance.gender == MALE || src.tf_holder.mobAppearance.gender == FEMALE))
			src.tf_holder.mobAppearance.gender = MALE
		if (!AH)
			AH = new
		if (AH.gender != src.tf_holder.mobAppearance.gender)
			AH.gender = src.tf_holder.mobAppearance.gender
		if (AH.customization_first_color == null)
			AH.customization_first_color = "#101010"
		if (AH.customization_first == null)
			AH.customization_first = new /datum/customization_style/none
		if (AH.customization_second_color == null)
			AH.customization_second_color = "#101010"
		if (AH.customization_second == null)
			AH.customization_second = new /datum/customization_style/none
		if (AH.customization_third_color == null)
			AH.customization_third_color = "#101010"
		if (AH.customization_third == null)
			AH.customization_third = new /datum/customization_style/none
		if (AH.e_color == null)
			AH.e_color = "#101010"
		if (AH.u_color == null)
			AH.u_color = "#FEFEFE"
		return


	proc/process() //Oh no what if we get orphaned!! (Also don't garbage collect us as soon as we spawn you fuk)
		while(!disposed)
			if(!usercl || !target_mob)
				qdel(src)
				return
			sleep(2 SECONDS)
		return

	proc/update_preview_icon()
		src.preview_icon = null

		var/customization_first_r = null
		var/customization_second_r = null
		var/customization_third_r = null

		var/g = "m"
		if (src.tf_holder.mobAppearance.gender == MALE)
			g = "m"
		else
			g = "f"

		if(src.mutantrace)
			src.preview_icon = new /icon(src.mutantrace.icon, src.mutantrace.icon_state)
		else
			src.preview_icon = new /icon('icons/mob/human.dmi', "body_[g]")

		if(!src.mutantrace?.override_skintone)
			// Skin tone
			if (src.tf_holder.mobAppearance.s_tone)
				src.preview_icon.Blend(src.tf_holder.mobAppearance.s_tone ? src.tf_holder.mobAppearance.s_tone : "#FFFFFF", ICON_MULTIPLY)

		var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_hair.dmi', "icon_state" = "eyes")

		if(!src.mutantrace?.override_eyes)
			eyes_s.Blend(src.tf_holder.mobAppearance.e_color, ICON_MULTIPLY)
			src.preview_icon.Blend(eyes_s, ICON_OVERLAY)

		if(!src.mutantrace?.override_hair)
			customization_first_r = src.tf_holder.mobAppearance.customization_first.id
			if(!customization_first_r)
				customization_first_r = "none"
			var/icon/hair_s = new/icon("icon" = 'icons/mob/human_hair.dmi', "icon_state" = customization_first_r)
			hair_s.Blend(src.tf_holder.mobAppearance.customization_first_color, ICON_MULTIPLY)
			eyes_s.Blend(hair_s, ICON_OVERLAY)

		if(!src.mutantrace?.override_beard)
			customization_second_r = src.tf_holder.mobAppearance.customization_second.id
			if(!customization_second_r)
				customization_second_r = "none"
			var/icon/facial_s = new/icon("icon" = 'icons/mob/human_hair.dmi', "icon_state" = customization_second_r)
			facial_s.Blend(src.tf_holder.mobAppearance.customization_second_color, ICON_MULTIPLY)
			eyes_s.Blend(facial_s, ICON_OVERLAY)

		if(!src.mutantrace?.override_detail)
			customization_third_r = src.tf_holder.mobAppearance.customization_third.id
			if(!customization_third_r)
				customization_third_r = "none"
			var/icon/detail_s = new/icon("icon" = 'icons/mob/human_hair.dmi', "icon_state" = customization_third_r)
			detail_s.Blend(src.tf_holder.mobAppearance.customization_third_color, ICON_MULTIPLY)
			eyes_s.Blend(detail_s, ICON_OVERLAY)

		src.preview_icon.Blend(eyes_s, ICON_OVERLAY)

		return

/client/proc/cmd_admin_remove_all_labels()
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set name = "Remove All Labels"
	set popup_menu = 0

	for (var/atom/A in world)
		if(!isnull(A.name_suffixes))
			A.name_suffixes = null
			A.UpdateName()
		LAGCHECK(LAG_LOW)

	return

/client/proc/cmd_admin_aview()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Aview"
	set popup_menu = 0
	ADMIN_ONLY
	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (widescreen)
		if (src.view == "21x15") //tried using world.view stuff but it was not happy
			src.view = "28x20"
			usr.see_in_dark = 10
		else
			src.view = "21x15"
			usr.see_in_dark = initial(usr.see_in_dark)
	else //not widescreen
		if (src.view == "15x15")// 15x15 should be default for non-widescreen
			src.view = "20x20"
			usr.see_in_dark = 10
		else
			src.view = "15x15"
			usr.see_in_dark = initial(usr.see_in_dark)


/client/proc/iddt()
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "iddt"
	set popup_menu = 0
	ADMIN_ONLY
	usr.client.cmd_admin_advview()
	if (src.adventure_view)
		src.mob.bioHolder.AddEffect("xray", magical = 1)
	else
		src.mob.bioHolder.RemoveEffect("xray")


/client/proc/cmd_admin_advview()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Adventure View"
	set popup_menu = 0
	set desc = "When toggled on, you will be able to see all 'hidden' adventure elements regardless of your current mob."

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (!adventure_view || mob.see_invisible < INVIS_ADVENTURE)
		adventure_view = 1
		mob.see_invisible = INVIS_ADVENTURE
		boutput(src, "Adventure View activated.")

	else
		adventure_view = 0
		boutput(src, "Adventure View deactivated.")
		if (!isliving(mob))
			mob.see_invisible = INVIS_GHOST // this seems to be quasi-standard for dead and wraith mobs? might fuck up target observers but WHO CARES
		else
			mob.see_invisible = INVIS_NONE // it'll sort itself out on the next Life() tick anyway

/proc/possess(obj/O as obj in world)
	set name = "Possess"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set popup_menu = 0
	new /mob/living/object(get_turf(O), O, usr)

/proc/possessmob(mob/M as mob in world)
	set name = "Possess Mob"
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	M.oldmob = usr
	M.oldmind = M.mind
	boutput(M, "<span class='alert'>Your soul is forced out of your body!</span>")
	M.ghostize()
	var/ckey = usr.key
	M.mind = usr.mind
	M.ckey = ckey

/proc/releasemob(mob/M as mob in world)
	set name = "Release Mob"
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	if(M.oldmob)
		M.oldmob.mind = usr.mind
		usr.client.mob = M.oldmob
	else
		M.ghostize()
	M.mind = M.oldmind
	if(M.mind)
		M.ckey = M.mind.key
	boutput(M, "<span class='alert'>Your soul is sucked back into your body!</span>")

/client/proc/cmd_whois(target as text)
	set name = "Whois"
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set desc = "Lookup a player by string (can search: mob names, byond keys and job titles)"
	set popup_menu = 0
	ADMIN_ONLY

	target = trim(lowertext(target))
	if (!target) return 0

	var/list/msg = list("<span class='notice'>")
	var/whois = whois(target)
	if (whois)
		var/list/whoisR = whois
		msg += "<b>Player[(whoisR.len == 1 ? "" : "s")] found for '[target]':</b><br>"
		for (var/mob/M in whoisR)
			var/role = getRole(M)
			msg += "<b>[key_name(M, 1, 0)][role ? " ([role])" : ""]</b><br>"
	else
		msg += "No players found for '[target]'"

	msg += "</span>"
	boutput(src, msg.Join())

/client/proc/cmd_whodead()
	set name = "Whodead"
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set desc = "Lookup everyone who's dead"
	set popup_menu = 0
	ADMIN_ONLY

	var/list/msg = list("<span class='notice'>")
	var/list/whodead = whodead()
	if (whodead.len)
		msg += "<b>Dead player[(whodead.len == 1 ? "" : "s")] found:</b><br>"
		for (var/mob/M in whodead)
			var/role = getRole(M)
			msg += "<b>[key_name(M, 1, 0)][role ? " ([role])" : ""]</b><br>"
	else
		msg += "No dead players found"

	msg += "</span>"
	boutput(src, msg.Join())

/client/proc/debugreward()
	set background = 1
	set name = "Debug Rewards"
	set desc = "For testing rewards on local servers."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set popup_menu = 0
	ADMIN_ONLY

	SPAWN(0)
		boutput(usr, "<span class='alert'>Generating reward list.</span>")
		var/list/eligible = list()
		for (var/A in rewardDB)
			var/datum/achievementReward/D = rewardDB[A]
			eligible.Add(D.title)
			eligible[D.title] = D

		if (!length(eligible))
			boutput(usr, "<span class='alert'>Sorry, you don't have any rewards available.</span>")
			return

		var/selection = input(usr,"Please select your reward", "VIP Rewards","CANCEL") as null|anything in eligible

		if (!selection)
			return

		var/datum/achievementReward/S = null

		for (var/X in rewardDB)
			var/datum/achievementReward/C = rewardDB[X]
			if(C.title == selection)
				S = C
				break

		if (S == null)
			boutput(usr, "<span class='alert'>Invalid Rewardtype after selection. Please inform a coder.</span>")

		var/M = alert(usr,S.desc + "\n(Earned through the \"[S.required_medal]\" Medal)","Claim this Reward?","Yes","No")
		if (M == "Yes")
			S.rewardActivate(src.mob)

/client/proc/cmd_admin_check_health(var/atom/target as null|mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	set name = "Check Health"
	set desc = "Checks the health of someone."
	ADMIN_ONLY

	if (!target)
		return
		//target = input(usr, "Target", "Target") as mob in world

	boutput(usr, scan_health(target, 1, 255, 1, syndicate = TRUE))
	return

/client/proc/cmd_admin_check_reagents(var/atom/target as null|mob|obj|turf in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	set name = "Check Reagents"
	set desc = "Checks the reagents of something."
	ADMIN_ONLY

	src.check_reagents_internal(target,)

/client/proc/check_reagents_internal(var/atom/target as null|mob|obj|turf in world, refresh = 0)
	if (!target)
		return
		//target = input(usr, "Target", "Target") as mob|obj|turf in world

	var/datum/reagents/reagents = 0
	if (!target.reagents) // || !target.reagents.total_volume)
		if (istype(target,/obj/fluid))
			var/obj/fluid/F = target
			if (F.group && F.group.reagents)
				reagents = F.group.reagents
		if (!reagents)
			boutput(usr, "<span class='notice'><b>[target] contains no reagents.</b></span>")
			return
	else
		reagents = target.reagents

	var/display_max = reagents.maximum_volume
	if (!reagents.maximum_volume)
		display_max = reagents.total_volume
	else if (reagents.maximum_volume >= 100000)	// fluids have an absurdly high cap so, eh
		display_max = reagents.total_volume

	var/pct = display_max ? (reagents.total_volume / display_max) : 1
	var/datum/color/color = reagents.get_average_color()
	var/log_reagents = ""

	var/report_reagents = ""

	var/w = 0
	var/bar = ""
	for (var/current_id in reagents.reagent_list)
		var/datum/reagent/current_reagent = reagents.reagent_list[current_id]

		var/disp_width = (current_reagent.volume / reagents.total_volume) * pct * 100
		if (disp_width >= 0.1)
			bar += "<div style='left: [w]%; width: [disp_width]%; background-color: rgb([current_reagent.fluid_r], [current_reagent.fluid_g], [current_reagent.fluid_b]);'><span style='border-color: rgb([current_reagent.fluid_r], [current_reagent.fluid_g], [current_reagent.fluid_b]);' class='[w >= 50 ? "rs" : "ls"]'>[html_encode(current_reagent)] ([current_reagent.volume])</span></div>\n"
			w += disp_width;
		log_reagents += " [current_reagent] ([current_reagent.volume]),"
		report_reagents += {"
		<tr>
			<td>[current_reagent.name]</td>
			<td>[current_reagent.id]</td>
			<td align='right'>[current_reagent.volume]</td>
		</tr>
		"}


	var/refresh_url = "?src=\ref[src.holder];action=checkreagent_refresh;target=\ref[target];origin=reagent_report"
	var/final_report = {"
	<style type='text/css'>
		* {
			box-sizing: border-box;
		}
		.reagents {
			position: relative;
			width: 100%;
			padding: 2px;
			border: 1px solid white;
			background: black;
			height: 2em;
			margin: 0;
			}
		.reagents div {
			position: absolute;
			top: 1px;
			left: 0;
			margin-left: 1px;
			bottom: 1px;
			background: #aaa;
			border-right: 1px solid white;
			}
		#reagents2 div:hover {
			top: -2em;
			}
		#reagents2 div span {
			display: none;
			}
		#reagents2 div {
			border-right: 1px solid black;
			}
		#reagents2 div:hover span {
			z-index: 10000;
			display: inline-block;
			background: white;
			border: 3px solid black;
			color: black;
			position: absolute;
			top: 0em;
			padding: 0.1em 0.25em;
			white-space: nowrap;
			}
		#reagents2 div:hover span.rs {
			right: 0px;
			}
		#reagents2 div:hover span.ls {
			left: 0px;
			}

	</style>
	Reagent Report for <b>[target]</b> <a style="display:block;float:right;" href="[refresh_url]">Refresh</a>
	<hr>
	<br>Temperature: [reagents.total_temperature]&deg;K ([reagents.total_temperature - 273.15]&deg;C)
	<br>Volume: [reagents.total_volume] / [reagents.maximum_volume]
	<br><div class='reagents' id='reagents2'>[bar]</div><div class='reagents' style='height: 0.75em;'><div style='color: [color.to_rgb()]; width: [pct * 100]%;'></div></div>
	<br>Colour: <div style='display: inline-block; width: 1em; border: 1px solid black; background: [color.to_rgb()]; position: relative; height: 1em;'></div> [color.to_rgba()] ([color.r] [color.g] [color.b], [color.a])
	<table border="0" style="width:100%">
	<tbody>
		<tr>
			<th>Name</th>
			<th>ID</th>
			<th>Volume</th>
		</tr>
	[report_reagents]
	</tbody></table>
	"}

	if (log_reagents == "")
		log_reagents = "(nothing)"

	if(!refresh)
		boutput(usr, "<span class='notice'><b>[target]'s reagents</b> ([reagents.total_volume] / [reagents.maximum_volume])<br>[log_reagents]</span><br>Temp: <i>[reagents.total_temperature]&deg;K ([reagents.total_temperature - 273.15]&deg;C)</i>") // Added temperature (Convair880).
	usr.Browse(final_report, "window=reagent_report")

	logTheThing(LOG_ADMIN, usr, "checked the reagents of [target] <i>(<b>Contents:</b>[log_reagents])</i>. <b>Temp:</b> <i>[reagents.total_temperature] K</i>) [log_loc(target)]")
	logTheThing(LOG_DIARY, usr, "checked the reagents of [target] <i>(<b>Contents:</b>[log_reagents])</i>. <b>Temp:</b> <i>[reagents.total_temperature] K</i>) [log_loc(target)]", "admin")
	return

/client/proc/popt_key(var/client/ckey in clients)
	set name = "Popt Key"
	set desc = "Open the player options panel for a key."
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set popup_menu = 0
	ADMIN_ONLY

	src.POK(ckey)

/client/proc/POK(var/client/ckey in clients)
	set name = "POK"
	set desc = "Open the player options panel for a key."
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	ADMIN_ONLY

	var/mob/target
	if (!ckey)
		var/client/selection = input("Please, select a player!", "Player Options (Key)", null, null) as null|anything in clients
		if(!selection)
			return
		target = selection.mob
	else
		target = ckey.mob

	if(holder)
		src.holder.playeropt(target)


/client/proc/POM(var/mob/M in mobs)
	set name = "POM"
	set desc = "Open the player options panel for a selected mob."
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	ADMIN_ONLY

	if (!M)
		M = input("Please, select a player!", "Player Options (Mob)", null, null) as null|anything in mob
		if(!istype(M))
			return

	if(holder)
		src.holder.playeropt(M)

/obj/proc/addpathogens()
	USR_ADMIN_ONLY
	var/obj/A = src
	if(!A.reagents) A.create_reagents(100)
	var/amount = input(usr,"Amount:","Amount",50) as num
	if(!amount) return

	A.reagents.add_reagent("pathogen", amount)
	var/datum/reagent/blood/pathogen/R = A.reagents.get_reagent("pathogen")
	var/datum/pathogen/P = new /datum/pathogen
	P.setup(1)
	R.pathogens += P.pathogen_uid
	R.pathogens[P.pathogen_uid] = P

	boutput(usr, "<span class='success'>Added [amount] units of pathogen to [A.name] with pathogen [P.name].</span>")

/client/proc/addreagents(var/atom/A in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Add Reagent"
	set popup_menu = 0

	ADMIN_ONLY

	if(!A.reagents)
		A.create_reagents(100) // we don't ask for a specific amount since if you exceed 100 it gets asked about below

	var/list/L = list()
	var/searchFor = input(usr, "Look for a part of the reagent name (or leave blank for all)", "Add reagent") as null|text
	if(searchFor)
		for(var/R in concrete_typesof(/datum/reagent))
			if(findtext("[R]", searchFor)) L += R

	var/type
	if(L.len == 1)
		type = L[1]
	else if(L.len > 1)
		type = input(usr,"Select Reagent:","Reagents",null) as null|anything in L
	else
		usr.show_text("No reagents matching that name", "red")
		return

	if(!type) return
	var/datum/reagent/reagent = new type()

	var/amount = input(usr, "Amount:", "Amount", 50) as null|num
	if(!amount)
		return
	var/overflow = amount - (A.reagents.maximum_volume - A.reagents.total_volume)
	if (overflow > 0) // amount exceeds reagent space
		if (tgui_alert(usr, "That amount of reagents exceeds the available space by [overflow] units. Increase the reagent cap of [A] to fit?",
			"Reagent Cap Expansion", list("Yes", "No")) == "Yes")
			A.reagents.maximum_volume += overflow
			if (ismob(A) && amount > 800) // rough estimate
				if (tgui_alert(usr, "That amount of reagents will probably make [A] explode. Want to prevent them from exploding due to excessive blood?",
					"Bloodgib Status", list("Yes", "No")) == "Yes")
					APPLY_ATOM_PROPERTY(A, PROP_MOB_BLOODGIB_IMMUNE, usr)
		else
			// didn't increase cap, only report actual amount added.
			amount = -(overflow - amount)

	A.reagents.add_reagent(reagent.id, amount)
	boutput(usr, "<span class='success'>Added [amount] units of [reagent.id] to [A.name].</span>")

	// Brought in line with adding reagents via the player panel (Convair880).
	logTheThing(LOG_ADMIN, src, "added [amount] units of [reagent.id] to [A] at [log_loc(A)].")
	if (ismob(A))
		message_admins("[key_name(src)] added [amount] units of [reagent.id] to [A] (Key: [key_name(A) || "NULL"]) at [log_loc(A)].")

/client/proc/cmd_cat_county()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Cat County"
	set desc = "We can't stop here!"
	ADMIN_ONLY

	var/catcounter = 0
	for(var/obj/vehicle/segway/S in by_type[/obj/vehicle])
		new /obj/vehicle/cat(S.loc)
		qdel(S)
		catcounter++
		LAGCHECK(LAG_LOW)

	usr.show_text("You replaced every single segway with a rideable cat. Good job!", "blue")
	logTheThing(LOG_ADMIN, usr, "replaced every segway with a cat, total: [catcounter].")
	for(var/I = 1, I <= catcounter, I++)
		for(var/mob/M in mobs)
			if(M)
				M.playsound_local(M.loc, 'sound/voice/animal/cat.ogg', 30, 30)
				if(I==1 && !isobserver(M)) new /obj/critter/cat(M.loc)
		sleep(rand(10,20))

/client/proc/revive_all_bees()
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Revive All Bees"
	ADMIN_ONLY

	var/revived = 0
	for (var/obj/critter/domestic_bee/Bee in world)
		LAGCHECK(LAG_LOW)
		if (!Bee.alive)
			Bee.health = initial(Bee.health)
			Bee.alive = 1
			//Bee.icon_state = initial(Bee.icon_state)
			Bee.set_density(initial(Bee.density))
			Bee.UpdateIcon()
			Bee.on_revive()
			Bee.visible_message("<span class='alert'>[Bee] seems to rise from the dead!</span>")
			revived ++
	for (var/obj/critter/domestic_bee_larva/Larva in world)
		LAGCHECK(LAG_LOW)
		if (!Larva.alive)
			Larva.health = initial(Larva.health)
			Larva.alive = 1
			Larva.icon_state = initial(Larva.icon_state)
			Larva.set_density(initial(Larva.density))
			Larva.on_revive()
			Larva.visible_message("<span class='alert'>[Larva] seems to rise from the dead!</span>")
			revived ++
	logTheThing(LOG_ADMIN, src, "revived [revived] bee[revived == 1 ? "" : "s"].")
	message_admins("[key_name(src)] revived [revived] bee[revived == 1 ? "" : "s"]!")

/client/proc/revive_all_cats()
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Revive All Cats"
	ADMIN_ONLY

	var/revived = 0
	for (var/obj/critter/cat/Cat in world)
		LAGCHECK(LAG_LOW)
		if (!Cat.alive)
			Cat.health = initial(Cat.health)
			Cat.alive = 1
			Cat.icon_state = initial(Cat.icon_state)
			Cat.set_density(initial(Cat.density))
			Cat.on_revive()
			Cat.visible_message("<span class='alert'>[Cat] seems to rise from the dead!</span>")
			revived ++
	logTheThing(LOG_ADMIN, src, "revived [revived] cat[revived == 1 ? "" : "s"].")
	message_admins("[key_name(src)] revived [revived] cat[revived == 1 ? "" : "s"]!")

/client/proc/revive_all_parrots()
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Revive All Parrots"
	ADMIN_ONLY

	var/revived = 0
	for (var/obj/critter/parrot/Bird in world)
		LAGCHECK(LAG_LOW)
		if (!Bird.alive)
			Bird.health = initial(Bird.health)
			Bird.alive = 1
			Bird.icon_state = Bird.species
			Bird.set_density(initial(Bird.density))
			Bird.on_revive()
			Bird.visible_message("<span class='alert'>[Bird] seems to rise from the dead!</span>")
			revived ++
	logTheThing(LOG_ADMIN, src, "revived [revived] parrot[revived == 1 ? "" : "s"].")
	message_admins("[key_name(src)] revived [revived] parrot[revived == 1 ? "" : "s"]!")

/proc/listCritters(var/alive)
	var/list/critters = list()
	for (var/obj/critter/C in view(usr))
		if (C.alive && alive)
			critters += C
		else if (!C.alive && !alive)
			critters += C
	return critters

/client/proc/cmd_transfer_client(var/mob/M)
	set name = "Transfer Client To"
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set desc = "Transfer a client to the selected mob."
	set popup_menu = 0 //Imagine if we could have subcategories in the popup menus. Wouldn't that be nice?
	ADMIN_ONLY

	if (M.ckey)
		var/con = alert("[M] currently has a ckey. Continue?",, "Yes", "No")
		if (con != "Yes")
			return
	var/list/L = sortListCopy(clients, /proc/cmp_text_asc)
	var/client/selection = input("Please, select a player!", "Player Options (Key)", null, null) as null|anything in L

	if (selection)
		if (istype(selection.mob, /mob/living))
			var/con = alert("Target client: [selection.ckey], is of type /mob/living. Are you sure you want to transfer them?",, "Yes", "No")
			if (con != "Yes")
				return
		message_admins("[key_name(src)] moved [selection.ckey] into [M].")
		logTheThing(LOG_ADMIN, src, "ckey transferred [constructTarget(selection,"admin")]")
		if (istype(selection.mob,/mob/dead/target_observer))
			qdel(src)

		M.client = selection

/client/proc/cmd_swap_minds(var/mob/M)
	set name = "Swap Bodies With"
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set desc = "Swaps yours and the other person's bodies around."
	set popup_menu = 0 //Imagine if we could have subcategories in the popup menus. Wouldn't that be nice?

	ADMIN_ONLY
	if(!M || M == usr ) return

	if(usr.mind)
		logTheThing(LOG_ADMIN, usr, "swapped bodies with [constructTarget(M,"admin")]")
		logTheThing(LOG_DIARY, usr, "swapped bodies with [constructTarget(M,"diary")]", "admin")
		var/mob/oldmob //This needs to be here
		if(M.key || M.client) //Nobody gives a shit if you wanna be an npc.
			message_admins("[key_name(src)] swapped bodies with [key_name(M)]")
			M.show_text("You are punted out of your body!", "red")
		else //You can only get rid of the ghost if you wanna swap with an NPC, because a player is getting YOUR ghost.
			if(isobserver(usr)) //You're dead, I guess an orphan ghost is not something we'd want.
				if(usr:corpse == M) //You're using admin observe and trying to be a smarty
					usr.client.admin_play()
					return
				oldmob = usr

		usr.mind.swap_with(M)
		if(oldmob) qdel(oldmob)
	else //You don't have a mind. Let's give you one and try again
		//usr.show_text("You don't have a mind!")
		logTheThing(LOG_DEBUG, usr, "<B>SpyGuy/Mindswap</B> - [usr] didn't have a mind so one was created for them.")
		usr.mind = new /datum/mind(usr)
		ticker.minds += usr.mind
		.()

// Tweaked this to implement log entries and make it feature-complete with regard to every antagonist roles (Convair880).
/proc/remove_antag(var/mob/M, var/mob/admin, var/new_mind_only = 0, var/show_message = 0)
	set name = "Remove Antag"
	set desc = "Removes someone's traitor status."

	if (!M || !M.mind || !M.mind.special_role)
		return

	var/former_role
	former_role = text("[M.mind.special_role]")

	message_admins("[key_name(M)]'s antagonist status ([former_role]) was removed. Source: [admin ? "[key_name(admin)]" : "*automated*"].")
	if (admin) // Log entries for automated antag status removal is handled in helpers.dm, remove_mindhack_status().
		logTheThing(LOG_ADMIN, admin, "removed the antagonist status of [constructTarget(M,"admin")].")
		logTheThing(LOG_DIARY, admin, "removed the antagonist status of [constructTarget(M,"diary")].", "admin")

	if (show_message == 1)
		M.show_text("<h2><font color=red><B>Your antagonist status has been revoked by an admin! If this is an unexpected development, please inquire about it in adminhelp.</B></font></h2>", "red")
		M.show_antag_popup("antagremoved")

	// Replace the mind first, so the new mob doesn't automatically end up with changeling etc. abilities.
	var/datum/mind/newMind = new /datum/mind()
	newMind.ckey = M.ckey
	newMind.key = M.key
	newMind.current = M
	newMind.assigned_role = M.mind.assigned_role
	newMind.brain = M.mind.brain
	newMind.dnr = M.mind.dnr
	newMind.is_target = M.mind.is_target
	if (M.mind.former_antagonist_roles.len)
		newMind.former_antagonist_roles.Add(M.mind.former_antagonist_roles)
	if (M.mind in ticker.mode.Agimmicks)
		ticker.mode.Agimmicks -= M.mind
	qdel(M.mind)
	if (!(newMind in ticker.minds))
		ticker.minds.Add(newMind)
	M.mind = newMind
	M.mind.brain?.owner = M.mind

	M.antagonist_overlay_refresh(1, 1)

	if (new_mind_only)
		return

	// Then spawn a new mob to delete all mob-/client-bound antagonist verbs.
	// Complete overkill for mindhacks, though. Blobs and wraiths need special treatment as well.
	// Synthetic mobs aren't really included yet, because it would be a complete pain to account for them properly.
	if (issilicon(M))
		var/mob/living/silicon/S = M
		S.emagged = 0
		S.syndicate = 0
		if (S.mainframe && S != S.mainframe)
			var/mob/living/silicon/ai/MF = S.mainframe
			MF.emagged = 0
			MF.syndicate = 0


		for (var/mob/living/silicon/S2 in mobs)
			if (S2.emagged || S2.syndicate) continue
			if (isghostdrone(S2)) continue
			S2.law_rack_connection = ticker.ai_law_rack_manager.default_ai_rack
			logTheThing(LOG_STATION, S2, "[S2.name] is connected to the default rack at [constructName(S2.law_rack_connection)] by admemery")
			S2.show_text("<b>Your laws have been changed!</b>", "red")
			S2.playsound_local(S2, 'sound/misc/lawnotify.ogg', 100, flags = SOUND_IGNORE_SPACE)
			S2.show_laws()
		for (var/mob/living/intangible/aieye/E in mobs)
			E.playsound_local(E, 'sound/misc/lawnotify.ogg', 100, flags = SOUND_IGNORE_SPACE)

	switch (former_role)
		if (ROLE_MINDHACK) M.delStatus("mindhack")
		if (ROLE_VAMPTHRALL) return
		if ("spyminion") return
		if (ROLE_BLOB) M.humanize(1)
		if (ROLE_WRAITH) M.humanize(1)
		else
			if (ishuman(M))
				// They could be in a pod or whatever, which would have unfortunate results when respawned.
				if (!isturf(M.loc))
					return
				var/mob/living/carbon/human/H = M

				// Get rid of those uplinks first.
				var/list/L = H.get_all_items_on_mob()
				if (length(L))
					for (var/obj/item/device/pda2/PDA in L)
						if (PDA?.uplink)
							qdel(PDA.uplink)
							PDA.uplink = null
					for (var/obj/item/device/radio/R in L)
						if (R?.traitorradio)
							qdel(R.traitorradio)
							R.traitorradio = null
							R.traitor_frequency = 0
					for (var/obj/item/uplink/U in L)
						if (U) qdel(U)
					for (var/obj/item/SWF_uplink/WZ in L)
						if (WZ) qdel(WZ)

				H.unkillable_respawn(1)

			if (isobserver(M)) // Ugly but necessary.
				var/mob/dead/observer/O = M
				var/mob/dead/observer/newO = new/mob/dead/observer(O)
				if (O.corpse)
					newO.corpse = O.corpse
				O.mind.transfer_to(newO)
				qdel(O)

	return

//flourish told me this was broken... if you want admin foam brew it yourself!!
/*
/client/proc/admin_foam(var/atom/A as turf|obj|mob, var/amount as num)
	set name = "Create Foam"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set desc = "Creates a foam reaction."
	set popup_menu = 1
	ADMIN_ONLY

	if (!A)
		return
	var/datum/reagents/holder
	if (A.reagents)
		holder = A.reagents
		logTheThing(LOG_ADMIN, src, "created foam in [A] [log_reagents(A)] at [log_loc(A)].")
		message_admins("[key_name(src)] created foam in [A] [log_reagents(A)] at [log_loc(A)].")
	var/datum/effects/system/foam_spread/s = new()
	s.set_up(amount, get_turf(A), holder, 0)
	s.start()
	if (A.reagents)
		holder.clear_reagents()
*/

//client/proc/admin_smoke(var/atom/A as turf|obj|mob, var/size as num)
//	set name = "Create Smoke"
//	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
//	set desc = "Creates a smoke reaction."
//	set popup_menu = 1
//	ADMIN_ONLY

//	if (!A)
//		return
//	var/datum/reagents/holder
//	if (A.reagents)
//		holder = A.reagents
//		logTheThing(LOG_ADMIN, src, "created smoke in [A] [log_reagents(A)] at [log_loc(A)].")
//		message_admins("[key_name(src)] created smoke in [A] [log_reagents(A)] at [log_loc(A)].)")
//	smoke_reaction(holder, size, get_turf(A), 1)



/client/proc/admin_smoke(var/turf/T in world)
	set name = "Create smoke"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set popup_menu = 0
	ADMIN_ONLY

	var/list/L = list()
	var/searchFor = input(usr, "Look for a part of the reagent name (or leave blank for all)", "Add reagent") as null|text
	if(searchFor)
		for(var/R in concrete_typesof(/datum/reagent))
			if(findtext("[R]", searchFor)) L += R
	else
		L = concrete_typesof(/datum/reagent)

	var/type
	if(L.len == 1)
		type = L[1]
	else if(L.len > 1)
		type = input(usr,"Select Reagent:","Reagents",null) as null|anything in L
	else
		usr.show_text("No reagents matching that name", "red")
		return

	if(!type) return
	var/datum/reagent/reagent = new type()

	var/amount = input(usr,"Amount:","Amount",50) as null|num
	if(!amount) return

	//var/time = input(usr,"Time:","Time") as null|num
	//if(!amount) return

	var/range = input(usr,"Range:","Range") as null|num
	if(!amount) return

	var/datum/reagents/smokeContents = new/datum/reagents(amount)
	smokeContents.add_reagent(reagent.id,amount)
	//particleMaster.SpawnSystem(new /datum/particleSystem/chemSmoke(T, smokeContents, time, range))
	smoke_reaction(smokeContents, range, T)
	return


/client/proc/admin_fluid(var/turf/T in world)
	set name = "Create Fluid"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set desc = "Attempt a fluid reaction on a turf."
	set popup_menu = 0
	ADMIN_ONLY

	if (!T)
		return

	var/list/L = list()
	var/searchFor = input(usr, "Look for a part of the reagent name (or leave blank for all)", "Add reagent") as null|text
	if(searchFor)
		for(var/R in concrete_typesof(/datum/reagent))
			if(findtext("[R]", searchFor)) L += R
	else
		L = concrete_typesof(/datum/reagent)

	var/type = 0
	if(L.len == 1)
		type = L[1]
	else if(L.len > 1)
		type = input(usr,"Select Reagent:","Reagents",null) as null|anything in L
	else
		usr.show_text("No reagents matching that name", "red")
		return

	if(!type) return
	var/datum/reagent/reagent = new type()
	var/amount = input(usr,"Amount:","Amount",100) as null|num
	if(!amount) return


	logTheThing(LOG_ADMIN, src, "created fluid at [T] : [reagent.id] with volume [amount] at [log_loc(T)].")
	message_admins("[key_name(src)] created fluid at [T] : [reagent.id] with volume [amount] at [log_loc(T)].)")

	T.fluid_react_single(reagent.id, amount)

/*
/client/proc/admin_airborne_fluid(var/turf/T in world)
	set name = "Create Airborne Fluid"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set desc = "Attempt an airborne fluid reaction on a turf."
	set popup_menu = 1
	ADMIN_ONLY

	if (!T)
		return

	var/list/L = list()
	var/searchFor = input(usr, "Look for a part of the reagent name (or leave blank for all)", "Add reagent") as null|text
	if(searchFor)
		for(var/R in concrete_typesof(/datum/reagent))
			if(findtext("[R]", searchFor)) L += R
	else
		L = concrete_typesof(/datum/reagent)

	var/type = 0
	if(L.len == 1)
		type = L[1]
	else if(L.len > 1)
		type = input(usr,"Select Reagent:","Reagents",null) as null|anything in L
	else
		usr.show_text("No reagents matching that name", "red")
		return

	if(!type) return
	var/datum/reagent/reagent = new type()
	var/amount = input(usr,"Amount:","Amount",100) as null|num
	if(!amount) return


	logTheThing(LOG_ADMIN, src, "created fluid at [T] : [reagent.id] with volume [amount] at [log_loc(T)].")
	message_admins("[key_name(src)] created fluid at [T] : [reagent.id] with volume [amount] at [log_loc(T)].)")

	T.fluid_react_single(reagent.id, amount, airborne = 1)


	if (T.active_airborne_liquid && T.active_airborne_liquid.group)
		var/datum/fluid_group/FG
		FG = T.active_airborne_liquid.group
		spawn()
			FG.required_to_spread = 1
			FG.update_once()
			FG.update_once()
			FG.update_once()
			FG.required_to_spread = initial(FG.required_to_spread)
*/


/client/proc/admin_follow_mobject(var/atom/target as mob|obj in world)
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set popup_menu = 0
	set name = "Follow Thing"
	set desc = "It's like observing, but without that part where you see everything as the person you're observing. Move to cancel if an observer, or use any jump command to leave if alive."
	ADMIN_ONLY

	usr:set_loc(target)
	logTheThing(LOG_ADMIN, usr, "began following [target].")
	logTheThing(LOG_DIARY, usr, "began following [target].", "admin")

/client/proc/admin_observe_random_player()
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set name = "Observe Random Player"
	set desc = "Observe a random living logged-in player."
	ADMIN_ONLY

	if (!isobserver(src.mob))
		boutput(src, "<span class='alert'>Error: you must be an observer to use this command.</span>")
		return

	if (istype(src.mob, /mob/dead/target_observer))
		qdel(src.mob)

	var/mob/dead/observer/O = src.mob
	var/client/C
	var/mob/M
	var/i = 0 // prevent infinite loops in worst case scenario

	while (!isliving(M))
		i++
		if (i > 10) // sorry, magic
			boutput(src, "<span class='alert'>Error: no valid players found.</span>")
			return
		C = pick(clients)
		if (C?.mob)
			M = C.mob

	O.insert_observer(M)

/client/proc/orp()
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "ORP"
	set popup_menu = 0
	ADMIN_ONLY

	src.admin_observe_random_player()

/client/proc/admin_pick_random_player()
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set name = "Pick Random Player"
	set desc = "Picks a random logged-in player and brings up their player panel."
	ADMIN_ONLY

	var/what_group = input(src, "What group would you like to pick from?", "Selection", "Everyone") as null|anything in list("Everyone", "Traitors Only", "Non-Traitors Only")
	if (!what_group)
		return
	var/choose_from_dead = input(src, "What group would you like to pick from?", "Selection", "Everyone") as null|anything in list("Everyone", "Living Only", "Dead Only")
	if (!choose_from_dead)
		return

	var/list/player_pool = list()
	for (var/mob/M in mobs)
		if (!M.client || istype(M, /mob/new_player))
			continue
		if (what_group != "Everyone")
			if ((what_group == "Traitors Only") && !checktraitor(M))
				continue
			else if ((what_group == "Non-Traitors Only") && checktraitor(M))
				continue
		if (choose_from_dead != "Everyone")
			if ((choose_from_dead == "Living Only") && M.stat)
				continue
			else if ((choose_from_dead == "Dead Only") && !M.stat)
				continue
		player_pool += M

	if (!player_pool.len)
		boutput(src, "<span class='alert'>Error: no valid mobs found via selected options.</span>")
		return

	var/chosen_player = pick(player_pool)
	src.holder.playeropt(chosen_player)

var/global/night_mode_enabled = 0
/client/proc/admin_toggle_nightmode()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Night Mode"
	set desc = "Switch the station into night mode so the crew can rest and relax off-work."
	ADMIN_ONLY

	night_mode_enabled = !night_mode_enabled
	message_admins("[key_name(src)] toggled Night Mode [night_mode_enabled ? "on" : "off"]")
	logTheThing(LOG_ADMIN, src, "toggled Night Mode [night_mode_enabled ? "on" : "off"]")
	logTheThing(LOG_DIARY, src, "toggled Night Mode [night_mode_enabled ? "on" : "off"]", "admin")

	for(var/obj/machinery/power/apc/APC in machine_registry[MACHINES_POWER])
		if(APC.area && APC.area.workplace)
			APC.do_not_operate = night_mode_enabled
			APC.update()
			APC.UpdateIcon()

/client/proc/admin_set_ai_vox()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle AI VOX"
	set desc = "Grant or revoke AI access to VOX"
	ADMIN_ONLY

	var/answer = alert("Set AI VOX access.", "Fun stuff.", "Grant Access", "Revoke Access", "Cancel")
	switch(answer)
		if ("Grant Access")
			message_admins("[key_name(src)] granted VOX access to all AIs!")
			logTheThing(LOG_ADMIN, src, "granted VOX access to all AIs!")
			logTheThing(LOG_DIARY, src, "granted VOX access to all AIs!", "admin")
			boutput(world, "<B>The AI may now use VOX!</B>")
			for_by_tcl(AI, /mob/living/silicon/ai)
				AI.cancel_camera()
				AI.verbs += /mob/living/silicon/ai/proc/ai_vox_announcement
				AI.verbs += /mob/living/silicon/ai/proc/ai_vox_help
				AI.show_text("<B>You may now make intercom announcements!</B><BR>You'll find two new verbs under AI commands: \"AI Intercom Announcement\" and \"AI Intercom Help\"")


		if ("Revoke Access")
			message_admins("[key_name(src)] revoked VOX access from all AIs!")
			logTheThing(LOG_ADMIN, src, "revoked VOX access from all AIs!")
			logTheThing(LOG_DIARY, src, "revoked VOX access from all AIs!", "admin")
			boutput(world, "<B>The AI may no longer use VOX!</B>")
			for_by_tcl(AI, /mob/living/silicon/ai)
				AI.cancel_camera()
				AI.verbs -= /mob/living/silicon/ai/proc/ai_vox_announcement
				AI.verbs -= /mob/living/silicon/ai/proc/ai_vox_help
				AI.show_text("<B>You may no longer make intercom announcements!</B>")

		if("Cancel")
			return

/proc/list_humans()
	var/list/L = list()
	for (var/mob/living/carbon/human/H in mobs)
		L += H
	return L

/client/proc/modify_organs(var/mob/living/carbon/human/H as mob in list_humans())
	set name = "Modify Organs"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set popup_menu = 0
	ADMIN_ONLY

	if (!istype(H))
		boutput(usr, "<span class='alert'>This can only be used on humans!</span>")
		return
	if (!H.organHolder)
		if (alert(usr, "[H] lacks an organHolder! Create a new one?", "Error", "Yes", "No") == "Yes")
			H.organHolder = new(H)
		else
			return
	// oh god this is going to be a horrible input tree
	var/list/organ_list = list("All", "Butt" = H.organHolder.butt, "Head" = H.organHolder.head, "Brain" = H.organHolder.brain, "Skull" = H.organHolder.skull, "Heart" = H.organHolder.heart, "Left Eye" = H.organHolder.left_eye, "Right Eye" = H.organHolder.right_eye, "Left Lung" = H.organHolder.left_lung, "Right Lung" = H.organHolder.right_lung)
	var/organ = input(usr, "Select organ(s) to edit", "Selection", "All") as null|anything in organ_list //list("Butt", "Brain", "Skull", "Left Eye", "Right Eye", "Heart", "Left Lung", "Right Lung", "All")
	if (!organ)
		return
	if (organ == "All")
		var/what2do = input(usr, "What would you like to do?", "Selection", "Drop") as null|anything in list("Drop", "Delete")
		if (!what2do)
			return
		switch (what2do)
			if ("Drop")
				if (alert(usr, "Are you sure you want to drop ALL of [H]'s organs? This will probably kill them!", "Confirmation", "Yes", "No") == "Yes")
					for (var/o in organ_list)
						if (o == "All")
							continue
						H.organHolder.drop_organ(o)
			if ("Delete")
				if (alert(usr, "Are you sure you want to delete ALL of [H]'s organs? This will probably kill them!", "Confirmation", "Yes", "No") == "Yes")
					for (var/o in organ_list)
						if (o == "All")
							continue
						var/organ2del = H.organHolder.drop_organ(o)
						qdel(organ2del)
		return

	var/obj/item/ref_organ = organ_list[organ]

	var/options_list = list("Replace")
	if (ref_organ)
		options_list += "Drop"
		options_list += "Delete"

	var/what2do = input(usr, "What would you like to do?", "Selection", "Replace") as null|anything in options_list
	if (!what2do)
		return

	switch (what2do)
		if ("Replace")
			var/d_d_c
			if (ref_organ)
				d_d_c = input(usr, "Drop or delete existing organ?", "Selection", "Drop") as null|anything in list("Drop", "Delete")
				if (!d_d_c)
					return
			var/new_organ
			var/organ_path
			switch (organ)
				if ("Butt")
					organ_path = /obj/item/clothing/head/butt
				if ("Head")
					organ_path = /obj/item/organ/head
				if ("Brain")
					organ_path = /obj/item/organ/brain
				if ("Skull")
					organ_path = /obj/item/skull
				if ("Left Eye")
					organ_path = /obj/item/organ/eye
				if ("Right Eye")
					organ_path = /obj/item/organ/eye
				if ("Heart")
					organ_path = /obj/item/organ/heart
				if ("Left Lung")
					organ_path = /obj/item/organ/lung
				if ("Right Lung")
					organ_path = /obj/item/organ/lung
			new_organ = input(usr, "What would you like to replace \the [lowertext(organ)] with?", "New Organ") as null|anything in typesof(organ_path)

			if (!new_organ || !ispath(new_organ))
				return
			if (d_d_c)
				switch (d_d_c)
					if ("Drop")
						H.organHolder.drop_organ(organ)
					if ("Delete")
						var/organ2del = H.organHolder.drop_organ(organ)
						qdel(organ2del)

			var/obj/item/created_organ = new new_organ
			created_organ:donor = H
			H.organHolder.receive_organ(created_organ, organ)
			boutput(usr, "<span class='notice'>[H]'s [lowertext(organ)] replaced with [created_organ].</span>")
			logTheThing(LOG_ADMIN, usr, "replaced [constructTarget(H,"admin")]'s [lowertext(organ)] with [created_organ]")
			logTheThing(LOG_DIARY, usr, "replaced [constructTarget(H,"diary")]'s [lowertext(organ)] with [created_organ]", "admin")
		if ("Drop")
			if (alert(usr, "Are you sure you want [H] to drop their [lowertext(organ)]?", "Confirmation", "Yes", "No") == "Yes")
				H.organHolder.drop_organ(organ)
				boutput(usr, "<span class='notice'>[H]'s [lowertext(organ)] dropped.</span>")
				logTheThing(LOG_ADMIN, usr, "dropped [constructTarget(H,"admin")]'s [lowertext(organ)]")
				logTheThing(LOG_DIARY, usr, "dropped [constructTarget(H,"diary")]'s [lowertext(organ)]", "admin")
			else
				return
		if ("Delete")
			if (alert(usr, "Are you sure you want to delete [H]'s [lowertext(organ)]?", "Confirmation", "Yes", "No") == "Yes")
				var/organ2del = H.organHolder.drop_organ(organ)
				qdel(organ2del)
				boutput(usr, "<span class='notice'>[H]'s [lowertext(organ)] deleted.</span>")
				logTheThing(LOG_ADMIN, usr, "deleted [constructTarget(H,"admin")]'s [lowertext(organ)]")
				logTheThing(LOG_DIARY, usr, "deleted [constructTarget(H,"diary")]'s [lowertext(organ)]", "admin")
			else
				return
	return

/client/proc/display_bomb_monitor()
	set name = "Display Bomb Monitor"
	set desc = "Get a list of every canister- and tank-transfer bomb on station."
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	ADMIN_ONLY
	if(!bomb_monitor) bomb_monitor = new
	bomb_monitor.display_ui(src.mob, 1)

/client/proc/generate_poster(var/target as null|area|turf|obj|mob in world)
	set name = "Create Poster"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set popup_menu = 0

	ADMIN_ONLY
	if (alert(usr, "Wanted poster or custom poster?", "Select Poster Style", "Wanted", "Custom") == "Wanted")
		gen_wp(target)
	else
		gen_poster(target)

/client/proc/cmd_boot(mob/M as mob in world)
	set name = "Boot"
	set desc = "Boot a player off the server"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set popup_menu = 0

	ADMIN_ONLY

	if (src.holder.level >= LEVEL_MOD)
		if (ismob(M))
			if (alert(usr, "Boot [M]?", "Confirmation", "Yes", "No") == "Yes")
				logTheThing(LOG_ADMIN, usr, "booted [constructTarget(M,"admin")].")
				logTheThing(LOG_DIARY, usr, "booted [constructTarget(M,"diary")].", "admin")
				message_admins("<span class='internal'>[key_name(usr)] booted [key_name(M)].</span>")
				del(M.client)
	else
		alert("You need to be at least a Moderator to kick players.")

/client/proc/cmd_admin_fake_medal(var/msg as null|text)
	set name = "Fake Medal"
	set desc = "Creates a false medal message and shows it to someone, or everyone."
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set popup_menu = 0

	ADMIN_ONLY

	if (!msg)
		msg = input("Enter message", "Message", "[src.key] earned the Banned medal.") as null|text
		if (!msg)
			return

	if (!(src.holder.level >= LEVEL_PA))
		msg = strip_html(msg)

	var/mob/audience = null
	if (alert("Who should see this message?", "Select Audience", "One Mob", "Every Mob") == "One Mob")
		audience = input("Select the mob. Cancel to select every mob.", "Select Mob") as null|anything in mobs

	if (alert("Show the message: \"[msg]\" to [audience ? audience : "everyone"]?", "Confirm", "OK", "Cancel") == "OK")
		msg = "<span class='medal'>" + msg + "</span>"
		logTheThing(LOG_ADMIN, usr, "showed a fake medal message to [audience ? audience : "everyone"]: \"[msg]\"")
		logTheThing(LOG_DIARY, usr, "showed a fake medal message to [audience ? audience : "everyone"]: \"[msg]\"", "admin")
		message_admins("[key_name(usr)] showed a fake medal message to [audience ? audience : "everyone"]: \"[msg]\"")
		if (audience)
			boutput(audience, msg)
		else
			for (var/client/C in clients)
				boutput(C, msg)

/client/proc/cmd_unshame_cube(var/mob/M as mob in world)
	set name = "Unshamecube"
	set desc = "Mostly removes the shamecube someone is under"
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set popup_menu = 0

	ADMIN_ONLY

	if (!M || !src.mob || !M.client || !M.client.player || !M.client.player.shamecubed)
		return 0
	if(isdead(M))
		M.invisibility = initial(M.invisibility)
	var/turf/targetLoc = get_turf(M)
	M.client.player.shamecubed = 0
	new/area/shamecube/unshamefulcube(targetLoc)
	targetLoc.name = "unshameful void"
	targetLoc.desc = "The shame and desparity surrounding this void has faded."
	for (var/direction in (alldirs+0))
		var/turf/t = get_step(targetLoc, direction)

		if(t.name == "shameful void")
			new/area/shamecube/unshamefulcube(t)
			t.name = "unshameful void"
			t.desc = "The shame and desparity surrounding this void has faded."
			for(var/obj/window/auto/reinforced/indestructible/extreme/thing in t)
				thing.initialPos = null
				thing.smash(1)

	logTheThing(LOG_ADMIN, src, "deshame-cubed [constructTarget(M,"admin")] at [get_area(M)] ([log_loc(M)])")
	logTheThing(LOG_DIARY, src, "deshame-cubed [constructTarget(M,"diary")] at [get_area(M)] ([log_loc(M)])", "admin")
	message_admins("[key_name(src)] deshame-cubed [key_name(M)] at [get_area(M)] ([log_loc(M)])")



/client/proc/cmd_shame_cube(var/mob/M as mob in world)
	set name = "Shamecube"
	set desc = "Places the player in a windowed cube at your location"
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set popup_menu = 0

	ADMIN_ONLY

	if (!M || !src.mob || !M.client || !M.client.player || M.client.player.shamecubed)
		return 0
	if(isdead(M))
		M.invisibility = INVIS_NONE
	var/announce = alert("Announce this cubing to the server?", "Announce", "Yes", "No")

	var/turf/targetLoc = src.mob.loc
	var/area/where = get_area(M)

	//Build our shame cube
	for (var/direction in (alldirs + 0))
		if (direction)
			var/obj/window/auto/reinforced/indestructible/extreme/R = new /obj/window/auto/reinforced/indestructible/extreme(get_step(targetLoc, direction))
			//R.set_dir(direction)
			R.name = "robust shamecube glass"
			R.desc = "A pane of robust, yet shameful, glass."
		var/turf/orig = get_step(targetLoc, direction)
		var/turf/void = orig.ReplaceWith(/turf/unsimulated/floor/void, FALSE, TRUE, FALSE, TRUE)
		void.name = "shameful void"
		void.desc = "really is just a shame"
		new/area/shamecube(get_step(targetLoc, direction))
	//new/turf/unsimulated/floor/void(targetLoc)
	//new/area/shamecube(targetLoc)

	//Place our sucker into it
	M.client.player.shamecubed = targetLoc
	M.set_loc(targetLoc)


	if (announce == "Yes")
		command_alert("[M.name] has been shamecubed in [where]!", "Dumb person detected!")

	out(M, "<span class='bold alert'>You have been shame-cubed by an admin! Take this embarrassing moment to reflect on what you have done.</span>")
	logTheThing(LOG_ADMIN, src, "shame-cubed [constructTarget(M,"admin")] at [where] ([log_loc(M)])")
	logTheThing(LOG_DIARY, src, "shame-cubed [constructTarget(M,"diary")] at [where] ([log_loc(M)])", "admin")
	message_admins("[key_name(src)] shame-cubed [key_name(M)] at [where] ([log_loc(M)])")

	return 1

/client/proc/cmd_makeshittyweapon()
	set name = "Make Shitty Weapon"
	set desc = "make some stupid junk, laugh"
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	ADMIN_ONLY

	if (src.holder.level >= LEVEL_PA)
		var/obj/O = makeshittyweapon()
		if (O)
			logTheThing(LOG_ADMIN, src, "made a shitty piece of junk weapon: [O][src.mob ? " [log_loc(src.mob)]" : null]")
			logTheThing(LOG_DIARY, src, "made a shitty piece of junk weapon: [O][src.mob ? " [log_loc(src.mob)]" : null]", "admin")
			message_admins("[key_name(src)] made a shitty piece of junk weapon:	 [O][src.mob ? " [log_loc(src.mob)]" : null]")

/client/proc/cmd_admin_unhandcuff(var/mob/M as mob in world)
	set name = "unhandcuff player"
	set desc = "take someone's handcuffs off!"
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	ADMIN_ONLY

	if (!istype(M))
		usr.show_text("You can only remove handcuffs from mobs.", "red")
		return

	if (M.hasStatus("handcuffed"))
		M.handcuffs.drop_handcuffs(M)

		logTheThing(LOG_ADMIN, src, "unhandcuffed [constructTarget(M,"admin")] at [get_area(M)] ([log_loc(M)])")
		logTheThing(LOG_DIARY, src, "unhandcuffed [constructTarget(M,"diary")] at [get_area(M)] ([log_loc(M)])", "admin")
		message_admins("[key_name(src)] unhandcuffed [key_name(M)] at [get_area(M)] ([log_loc(M)])")

		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			H.update_clothing()
		M.show_text("<b>Your handcuffs suddenly fall off!</b>", "blue")
	else
		usr.show_text("[M] has no handcuffs!", "red")


/client/proc/admin_toggle_lighting() //shameless copied from the ghost one
	set name = "Toggle Lighting"
	set desc = "Turns the scary darkness off"
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	ADMIN_ONLY

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	var/atom/plane = src.get_plane(PLANE_LIGHTING)
	if( plane )
		plane.alpha = plane.alpha ? 0 : 255
	else
		boutput( src, "Well, I want to, but you don't have any lights to fix!" )


// hi it's cirr if this is in the wrong place please move it
/client/proc/getturftelesci(var/turf/T in world)
	set name = "Get Telesci Coords"
	set desc = "Get the weird messed up co-ordinates that telesci wants for this turf"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set popup_menu = 0

	ADMIN_ONLY

	if(!telesci_modifiers_set)
		boutput(src, "No telesci modifiers! Perhaps they haven't been set up yet.")
	else
		var/tx = (T.x + XSUBTRACT) / XMULTIPLY
		tx = clamp(tx, 0, world.maxx+1)
		var/ty = (T.y + YSUBTRACT) / YMULTIPLY
		ty = clamp(ty, 0, world.maxy+1)
		var/tz = T.z + ZSUBTRACT
		tz = clamp(tz, 0, world.maxz+1)
		boutput(src, "Telesci Coords: [tx], [ty], [tz]")


/client/proc/clear_medals(var/target_key as null|text)
	set name = "Clear Medals"
	set desc = "Clear medals of an account."
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set popup_menu = 0

	ADMIN_ONLY

	if (!target_key)
		target_key = input("Enter target key", "Target account key", null) as null|text
	var/medals = world.GetMedal("", null, config.medal_hub, config.medal_password)
	medals = params2list(medals)
	var/mob/M
	for (var/client/C in clients)
		LAGCHECK(LAG_LOW)
		if (C.key == target_key	)
			M = C.mob
	if (isnull(M))
		M = new /mob
		M.key = target_key
	for (var/medal in medals)
		var/result = world.ClearMedal(medal, M, config.medal_hub, config.medal_password)
		if (isnull(result))
			boutput(src, "Failed to clear medal; error!")
			break

/client/proc/give_mass_medals(var/medal as null|text)
	set name = "Give Mass Medals"
	set desc = "Give a bunch of players a medal. Don't use this while any of them are online please lol."
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0

	ADMIN_ONLY

	if (!config || !config.medal_hub || !config.medal_password)
		return

	if (!medal)
		medal = input("Enter medal name", "Medal name", "Banned") as null|text
		if (!medal)
			return

	var/revoke = (alert(src, "Mass grant or revoke medals?", "Mass grant/revoke", "Grant", "Revoke") == "Revoke")
	var/key = input("Enter player key", "Player key", null) as null|text
	while(key)
		var/player = ckey(key)
		var/result
		if (revoke)
			result = world.ClearMedal(medal, player, config.medal_hub, config.medal_password)
		else
			result = world.SetMedal(medal, player, config.medal_hub, config.medal_password)
		if (isnull(result))
			boutput(src, "Failed to set medal; error communicating with BYOND hub!")
			break
		key = input("Enter player key", "Player key", null) as null|text

/client/proc/copy_medals(var/old_key as null|text, var/new_key as null|text)
	set name = "Copy Medals"
	set desc = "Copy medals from one account to another."
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0

	ADMIN_ONLY

	if (!config || !config.medal_hub || !config.medal_password)
		return
	var/mob/M = new /mob
	if (!old_key)
		old_key = input("Enter old account key", "Old account key", null) as null|text
	M.key = old_key // Old key shouldn't be online, so
	if (!new_key)
		new_key = input("Enter new account key", "New account key", null) as null|text
	var/medals = world.GetMedal("", M, config.medal_hub, config.medal_password)
	if (!medals)
		boutput(src, "No medals; error communicating with BYOND hub!")
		return
	medals = params2list(medals)
	for (var/client/C in clients)
		LAGCHECK(LAG_LOW)
		if (C.key == new_key)
			M = C.mob
	if (M.key == old_key)
		M.key = new_key
	for (var/medal in medals)
		var/result = world.SetMedal(medal, M, config.medal_hub, config.medal_password)
		if (isnull(result))
			boutput(src, "Failed to set medal; error communicating with BYOND hub!")
			break

/client/proc/copy_cloud_saves(old_key as null|text)
	set name  = "Copy Cloud Data"
	set desc = "Copy cloud saves from one account to another. This WILL overwrite all saves on the target account."
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0

	ADMIN_ONLY

	if (!old_key)
		old_key = input("Enter old account key", "Old account key", null) as null|text
	if (!old_key)
		boutput(usr, "<span class='alert'>Transfer aborted.</span>")
		return
	old_key = ckey(old_key)

	var/new_key = ckey(input("Enter new account key", "New account key", null) as null|text)
	if (!new_key)
		boutput(usr, "<span class='alert'>Transfer aborted.</span>")
		return

	//criminal activity
	var/datum/player/dummy_player = new
	dummy_player.clouddata = list() // trick it into thinking we have cloud data I guess. only gets nullchecked
	dummy_player.cloudsaves = list() // ditto
	var/datum/preferences/dummy_preferences = new
	var/list/save_names = dummy_player.cloud_fetch_target_saves_only(old_key) // technically a map from names to nums

	if (!save_names)
		boutput(usr, "<span class='alert'>Couldn't find cloud data for that key.</span>")
		return
	if (!length(save_names))
		boutput(usr, "<span class='alert'>Couldn't find any cloud saves for that key.</span>")
		return
	if (tgui_alert(usr, "You're about to transfer [length(save_names)] saves from [old_key] to [new_key]. This will overwrite all the existing saves on the target account. Do it?", "Cloud Save Transfer", list("Yes", "No")) == "No")
		boutput(usr, "<span class='alert'>Transfer aborted.</span>")
		return

	for (var/name in save_names)
		dummy_preferences.cloudsave_load(null, name, old_key)
		var/ret = dummy_preferences.cloudsave_save(null, name, new_key)
		if (ret != 1) //yes this is intentional
			boutput(usr, "<span class='alert'>Something went wrong while saving to the cloud. Return value was: ([ret]). Transfer aborted.</span>")
			return

	dummy_player.cloud_put_target(new_key, "saves", save_names)
	boutput(usr, "<span class='success'>Cloud saves transferred.</span>")

/client/proc/cmd_admin_disable()
	set name = "Disable Admin Powers"
	set desc = "Disables all admin features for yourself until returned or you log in again."
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set popup_menu = 0

	ADMIN_ONLY

	if(alert("Disable admin powers? Lasts until you log in or you cancel the effect.", "Disable admin powers?", "Yes", "No") == "Yes")
		message_admins("[key_name(src)] has shut off their admin powers.")
		src.clear_admin()
		src.verbs += /client/proc/cmd_admin_reinitialize
		alert("Your admin abilities have been removed. Use 'Return Admin Powers' to get them back.")

/client/proc/cmd_admin_reinitialize()
	set name = "Return Admin Powers"
	set desc = "Returns your admin powers to you. If you had any. If not you will always and forever be a chumperton."
	set category = "Commands"
	set popup_menu = 0

	if(src.init_admin())
		message_admins("[key_name(src)] has re-enabled their admin powers.")
	else
		message_admins("[key_name(src)] tried to re-enable admin powers but was rejected.")

	src.verbs -= /client/proc/cmd_admin_reinitialize

/client/proc/toggle_text_mode(client/C in clients)
	set name = "Toggle Text Mode"
	set desc = "Makes a client see the game in ASCII vision."
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	ADMIN_ONLY

	var/is_text = winget(C,  "mapwindow.map", "text-mode") == "true"
	logTheThing(LOG_ADMIN, usr, "has toggled [constructTarget(C.mob,"admin")]'s text mode to [!is_text]")
	logTheThing(LOG_DIARY, usr, "has toggled [constructTarget(C.mob,"diary")]'s text mode to [!is_text]", "admin")
	message_admins("[key_name(usr)] has toggled [key_name(C.mob)]'s text mode to [!is_text]")
	winset(C, "mapwindow.map", "text-mode=[is_text ? "false" : "true"]" )


/client/proc/retreat_to_office()
	set name = "Retreat To Office"
	set desc = "Retreat to my office at centcom."
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set popup_menu = 0
	ADMIN_ONLY

	//it's a mess, sue me
	var/list/areas = get_areas(/area/centcom/offices)
	for (var/area/centcom/offices/office in areas)
		//search all offices for an office with the same ckey variable as the usr.
		if (office.ckey == src.ckey)
			var/list/turfs = get_area_turfs(office.type)
			if (islist(turfs) && length(turfs))

				for (var/turf/T in turfs)
					//search all turfs for a chair if we can't find one, put em anywhere (might make personalized chairs in the future...)
					var/obj/stool/chair/chair = locate(/obj/stool/chair) in T
					if (istype(chair))
						var/turf/chair_turf = get_turf(chair)
						src.mob.set_loc(chair_turf)
						src.mob.dir = chair.dir
						boutput(src, "<span class='notice'>Arrived at your office, safe and sound in your favorite chair!</span>")
						return
				//put em in a random place in their office if they don't have a chair.
				src.mob.set_loc(pick(turfs))
				boutput(src, "<span class='alert'>Arrived at your office, but where's your chair? Maybe someone stole it!</span>")
			else
				boutput(src, "Can't seem to find any turfs in your office. You must not have one here!")
			return
	boutput(src, "You don't seem to have an office, so sad. :(")

var/global/mirrored_physical_zone_created = FALSE //enables secondary code branch in bump proc to allow bumping into mirrors with offsets
/client/proc/summon_office()
	set name = "Summon Office"
	set desc = "Expand your domain across dimensional planes."
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set popup_menu = 0
	ADMIN_ONLY

	var/turf/src_turf = get_turf(src.mob)
	if (!src_turf) return

	var/list/areas = get_areas(/area/centcom/offices)
	var/area/A = get_area(src.mob)
	if (A.type in childrentypesof(/area/centcom/offices))
		boutput(src, "In order to prevent a complete collapse of the known universe you resist the urge to manipulate spacetime within the office.")
		return
	for (var/area/centcom/offices/office in areas)
		//search all offices for an office with the same ckey variable as the usr.
		if (office.ckey == src.ckey)
			var/list/turfs = get_area_turfs(office.type)
			if (!length(turfs))
				boutput(src, "Can't seem to find any turfs in your office. You must not have one here!")
				return

			//find the door
			var/turf/office_entry = null
			var/obj/stool/chair/chair = locate(/obj/stool/chair) in office
			if (chair)
				office_entry = get_turf(chair)
				src.mob.dir = chair.dir
			var/obj/machinery/door/unpowered/wood/O = locate(/obj/machinery/door/unpowered/wood) in office
			if (O)
				if (!office_entry)
					office_entry = get_turf(O)
				turfs -= get_turf(O)

			if (!office_entry)
				boutput(src, "<span class='alert'>Can't find the entry to your office!</span>")
				return

			if (!office_entry) return
			var/x_diff = src_turf.x - office_entry.x
			var/y_diff = src_turf.y - office_entry.y

			var/summoning_office = null //bleh
			for (var/turf/T in turfs)
				if (T.vistarget)
					T.vistarget.vis_contents -= T
					T.vistarget.warptarget = null
					T.vistarget.fullbright = initial(T.vistarget.fullbright)
					T.vistarget.RL_Init()
					T.vistarget = null
					T.warptarget = null
					summoning_office = FALSE
					T.appearance_flags &= ~KEEP_TOGETHER
					T.layer -= 0.1 //retore to normal

				else
					new /obj/landmark/viscontents_spawn(T, man_xOffset = x_diff, man_yOffset = y_diff, man_targetZ = src.mob.z, man_warptarget_modifier = LANDMARK_VM_WARP_NONE)
					summoning_office = TRUE
					T.layer += 0.1 //stop hiding my turfs!!

					//anti-sneaky players breaking into centcom through summoned office code
					T.warptarget = T.vistarget
					T.warptarget_modifier = LANDMARK_VM_WARP_NON_ADMINS

			if (summoning_office)
				src.mob.visible_message("[src.mob] manipulates the very fabric of spacetime around themselves linking their current location with another! Wow!", "You skillfully manipulate spacetime to join the space containing your office with your current location.", "You have no idea what's happening but it sure does sound cool!")
				playsound(src.mob, 'sound/machines/door_open.ogg', 50, 1)
				if (!mirrored_physical_zone_created)
					mirrored_physical_zone_created = TRUE
			else
				src.mob.visible_message("[src.mob] returns the fabric of spacetime to normal! Wow!", "You wave your office away, returning the space to normal.", "You have no idea what's happening but it sure does sound cool!")
				playsound(src.mob, 'sound/machines/door_close.ogg', 50, 1)
			return
	boutput(src, "You don't seem to have an office, so sad. :(")

/client/proc/cmd_crusher_walls()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Crusher Walls"
	if(holder && src.holder.level >= LEVEL_ADMIN)
		switch(alert("Holy shit are you sure?! This is going to turn the walls into crushers!",,"Yes","No"))
			if("Yes")
				for(var/turf/simulated/wall/W in world)
					if (W.z != 1) continue
					var/obj/machinery/crusher/O = locate() in W.contents //in case someone presses it again
					if (O) continue
					new /obj/machinery/crusher(locate(W.x, W.y, W.z))
					W.set_density(0)

				logTheThing(LOG_ADMIN, src, "has turned every wall into a crusher! God damn.")
				logTheThing(LOG_DIARY, src, "has turned every wall into a crusher! God damn.", "admin")
				message_admins("[key_name(src)] has turned every wall into a crusher! God damn.")

			if("No")
				return
	else
		boutput(src, "You must be at least an Administrator to use this command.")

/client/proc/cmd_disco_lights()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Disco Lights"
	set desc = "Set every light on the station to a random color"
	var/R = null
	var/G = null
	var/B = null

	if(holder && src.holder.level >= LEVEL_ADMIN)
		switch(alert("Set every light on the station to a random color?",,"Yes","No"))
			if("Yes")
				for (var/obj/machinery/light/L as anything in stationLights)
					R = rand(100)/100
					G = rand(100)/100
					B = rand(100)/100
					if ((R + G + B) < 1)
						switch (rand(1,3))
							if (1)
								R = 1
							if (2)
								G = 1
							if (3)
								B = 1
					L.light?.set_color(R, G, B)
					LAGCHECK(LAG_LOW)
				logTheThing(LOG_ADMIN, src, "set every light on the station to a random color.")
				logTheThing(LOG_DIARY, src, "set every light on the station to a random color.", "admin")
				message_admins("[key_name(src)] set every light on the station to a random color.")
	else
		boutput(src, "You must be at least an Administrator to use this command.")

/client/proc/cmd_blindfold_monkeys()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "See No Evil"
	if(holder && src.holder.level >= LEVEL_ADMIN)
		switch(alert("Really blindfold all monkeys?",,"Yes","No"))
			if("Yes")
				for (var/mob/living/carbon/human/M in mobs)
					if (!ismonkey(M))
						continue
					var/obj/item/clothing/glasses/G = M.glasses
					if (G)
						M.u_equip(G)
						qdel(G)
					var/obj/item/clothing/glasses/blindfold/B = new()
					M.force_equip(B, M.slot_glasses)

				logTheThing(LOG_ADMIN, src, "has blindfolded every monkey.")
				logTheThing(LOG_DIARY, src, "has blindfolded every monkey.", "admin")

			if("No")
				return
	else
		boutput(src, "You must be at least an Administrator to use this command.")

/client/proc/cmd_special_shuttle()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Special Shuttle"
	set desc = "Spawn in a special escape shuttle"
	ADMIN_ONLY
	if(src.holder.level >= LEVEL_ADMIN)
		var/list/shuttles = get_map_prefabs(/datum/mapPrefab/shuttle)
		var/datum/mapPrefab/shuttle/shuttle = shuttles[tgui_input_list(src, "Select a shuttle", "Special Shuttle", shuttles)]
		if(shuttle?.load())
			logTheThing(LOG_ADMIN, src, "replaced the shuttle with [shuttle.name].")
			logTheThing(LOG_DIARY, src, "replaced the shuttle with [shuttle.name].", "admin")
			message_admins("[key_name(src)] replaced the shuttle with [shuttle.name].")
	else
		boutput(src, "You must be at least an Administrator to use this command.")

/client/proc/cmd_admin_ship_movable_to_cargo(atom/movable/AM)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Ship to Cargo"
	set popup_menu = 0
	ADMIN_ONLY

	if (AM.anchored)
		boutput(src, "Target is anchored and you probably shouldn't be shipping it!")
		return

	if (tgui_alert(src.mob, "Are you sure you want to ship [AM]?", "Confirmation", list("Yes", "No")) == "Yes")
		shippingmarket.receive_crate(AM)
		logTheThing(LOG_ADMIN, usr, "has shipped [AM] to cargo.")
		logTheThing(LOG_DIARY, usr, "has shipped [AM] to cargo.", "admin")
		message_admins("[key_name(usr)] has shipped [AM] to cargo.")

var/global/force_radio_maptext = FALSE
/client/proc/toggle_radio_maptext()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Toggle Forced Radio maptext"
	ADMIN_ONLY

	if(holder && src.holder.level >= LEVEL_ADMIN)
		if(!force_radio_maptext)
			switch(alert("Set all radios to use flying text?", "Bad Idea??","Yes","No"))
				if("Yes")
					force_radio_maptext = TRUE
					logTheThing(LOG_ADMIN, src, "has enabled forced radio maptext.")
					logTheThing(LOG_DIARY, src, "has enabled forced radio maptext.", "admin")
					message_admins("[key_name(src)] has enabled flying text for all radios!")
				if("No")
					return
		else
			force_radio_maptext = FALSE
			logTheThing(LOG_ADMIN, src, "has disabled forced radio maptext.")
			logTheThing(LOG_DIARY, src, "has disabled forced radio maptext.", "admin")
			message_admins("[key_name(src)] has disabled forced radio flying text.")
			return
	else
		boutput(src, "You must be at least an Administrator to use this command.")


/client/proc/idkfa()
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "idkfa"
	set popup_menu = 0
	ADMIN_ONLY
	boutput(usr, "<span class='notice'><b>Very Happy Ammo Added</b></span>")

	// yes... ha ha ha... YES!
	var/obj/item/storage/backpack/syndie/backpack_full_of_ammo = new()
	backpack_full_of_ammo.name = "backpack full of ammo"
	backpack_full_of_ammo.desc = "Try not to lose it, idiot."
	backpack_full_of_ammo.max_wclass = INFINITY
	backpack_full_of_ammo.slots = 9
	backpack_full_of_ammo.cant_other_remove = 1

	var/obj/item/saw/syndie/button_1 = new()
	button_1.name = "chainsaw"
	button_1.desc = "Find some meat!"
	button_1.cant_other_remove = 1

	var/obj/item/gun/kinetic/pistol/button_2 = new()
	button_2.name = "pistol"
	button_2.desc = "To defeat the spacemans, shoot him until he dies."
	button_2.max_ammo_capacity = 400
	button_2.ammo.amount_left = 400
	button_2.cant_other_remove = 1

	var/obj/item/gun/kinetic/spes/button_3 = new()
	button_3.name = "shotgun"
	button_3.desc = "Somehow fits 100 shells."
	button_3.max_ammo_capacity = 100	// this is a backpack, after all
	button_3.ammo.amount_left = 100
	button_3.cant_other_remove = 1

	var/obj/item/gun/kinetic/minigun/button_4 = new()
	button_4.name = "chaingun"
	button_4.desc = "Chainguns direct heavy firepower into your opponent, making them do the chaingun cha-cha."
	button_4.max_ammo_capacity = 400	// boolet
	button_4.ammo.amount_left = 400
	button_4.cant_other_remove = 1

	var/obj/item/gun/kinetic/rpg7/loaded/button_5 = new()
	button_5.name = "rocket launcher"
	button_5.desc = "Splash damage zone!"
	button_5.ammo.amount_left = 100
	button_5.max_ammo_capacity = 100
	button_5.cant_other_remove = 1

	// were you expecting a plasma gun or something?
	var/obj/item/breaching_hammer/button_6 = new()
	button_6.name = "doomhammer"
	button_6.desc = "If you aren't the one holding this, you should probably be running."
	button_6.force = 100000
	button_6.click_delay = 0
	button_6.cant_other_remove = 1

	var/obj/item/gun/energy/bfg/button_7 = new()
	// button_7.cell.max_charge = 1500	// 100shot/300max (SS13) vs 40shot/600ammo (D) = 1500 max
	// button_7.cell.charge = 1500
	// i have no idea how component cells work and i cannot be bothered
	button_7.cant_other_remove = 1

	var/obj/item/device/key/iridium/fancy_keys = new()

	backpack_full_of_ammo.add_contents(button_1)
	backpack_full_of_ammo.add_contents(button_2)
	backpack_full_of_ammo.add_contents(button_3)
	backpack_full_of_ammo.add_contents(button_4)
	backpack_full_of_ammo.add_contents(button_5)
	backpack_full_of_ammo.add_contents(button_6)
	backpack_full_of_ammo.add_contents(button_7)
	backpack_full_of_ammo.add_contents(fancy_keys)

	if (ishuman(src.mob))
		// If you are using this you are going to Fuck Things Up
		var/mob/living/carbon/human/doomguy = src.mob
		doomguy.click_delay = 0
		doomguy.combat_click_delay = 0
		if(doomguy.back)
			var/obj/item/I = doomguy.back
			doomguy.u_equip(I)
			I.set_loc(doomguy.loc)

		doomguy.force_equip(backpack_full_of_ammo, doomguy.slot_back)

	else
		backpack_full_of_ammo.set_loc(get_turf(src.mob))
