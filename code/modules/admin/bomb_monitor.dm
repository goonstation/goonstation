// Added support for single tank bombs and fingerprints (Convair880).
var/global/datum/bomb_monitor/bomb_monitor = new

/datum/bomb_monitor
	var/lists_built = 0
	var/list/obj/item/device/transfer_valve/TVs = list()
	var/list/obj/item/canbomb_detonator/dets = list()
	var/list/obj/item/assembly/complete/bomb_assemblies = list()
	var/list/obj/item/assembly/proximity_bomb/ST_prox = list()
	var/list/obj/item/assembly/time_bomb/ST_time = list()
	var/list/obj/item/assembly/radio_bomb/ST_radio = list()
	var/filter_active_only = 1
	disposing()
		lists_built = 0
		TVs.Cut()
		dets.Cut()
		ST_prox.Cut()
		ST_time.Cut()
		ST_radio.Cut()
		filter_active_only = 1
		..()


	proc/build_lists(var/force=0)
		if(lists_built && !force) return
		TVs.Cut()
		dets.Cut()
		ST_prox.Cut()
		ST_time.Cut()
		ST_radio.Cut()
		for(var/obj/item/I in world)
			if(istype(I, /obj/item/device/transfer_valve))
				TVs += I
			else if (istype(I, /obj/item/canbomb_detonator))
				dets += I
			else if (istype(I, /obj/item/assembly/proximity_bomb/))
				ST_prox += I
			else if (istype(I, /obj/item/assembly/time_bomb/))
				ST_time += I
			else if (istype(I, /obj/item/assembly/radio_bomb/))
				ST_radio += I
			else if (istype(I, /obj/item/assembly/complete))
				var/obj/item/assembly/complete/checked_bomb = I
				if(istype(checked_bomb.target, /obj/item/tank/plasma))
					src.bomb_assemblies += I
			LAGCHECK(LAG_LOW)

		lists_built = 1

	proc/display_ui(var/mob/user, var/force_update = 0)
		if(!user || !user.client || !user.client.holder) return
		build_lists(force_update)
		var/temp = ""
		for(var/obj/item/device/transfer_valve/TV in TVs)
			if(!filter_active_only || (TV.tank_one || TV.tank_two))
				var/turf/T = get_turf(TV)
				var/device_name = TV.attached_device?.name
				if(istype(TV.attached_device, /obj/item/device/radio/signaler))
					var/obj/item/device/radio/signaler/remotesignaler = TV.attached_device
					device_name += ", frequency: [remotesignaler.frequency]"
					if(remotesignaler.frequency == FREQ_SIGNALER)
						device_name += " (DEFAULT)"

				if (!T || !isturf(T)) continue
				var/ref_a = "<a href='?src=\ref[src];airmon=\ref[TV.tank_one]'>[TV.tank_one]</a>"
				var/ref_b = "<a href='?src=\ref[src];airmon=\ref[TV.tank_two]'>[TV.tank_two]</a>"
				temp += {"<tr>
							<td>
								[TV.name]
							</td>
							<td>
								[get_area(T)]
							</td>
							<td>
								[showCoords(T.x, T.y, T.z, 0, user.client.holder)]
							</td>
							<td>
								[TV.tank_one ? ref_a : "Nothing"]
							</td>
							<td>
								[TV.tank_two ? ref_b : "Nothing"]
							</td>
							<td>
								[TV.attached_device ? device_name : "Nothing"]
							</td>
							<td>
								[TV.fingerprintslast ? TV.fingerprintslast : "N/A"]
							</td>
							<td>
								<a href='?src=\ref[src];toggle_dud=\ref[TV]'>[TV.force_dud ? SPAN_ALERT("YES") : "No"]</a>
							</td>
							<td>
								<a href='?src=\ref[src];trigger=\ref[TV]'><B>[TV.tank_one && TV.tank_two ? "Trigger" : ""]</B></a>
							</td>
						</tr>"}

		var/TTVtable = {"<h2>Tank Transfer Valves</h2><hr>
						<table>
							<tr>
								<th>Name</th><th>Area name</th><th>Coords</th><th>Tank 1</th><th>Tank 2</th><th>Detonator</th><th>Fingerprints</th><th>Force Dud</th>
								[temp]
							</tr>
						</table>"}

		temp = ""
		for (var/obj/item/assembly/proximity_bomb/PB in ST_prox)
			var/turf/T = get_turf(PB)
			if (!T || !isturf(T)) continue
			var/ref_PB = "<a href='?src=\ref[src];airmon=\ref[PB.part3]'>[PB.part3]</a>"
			temp += {"<tr>
						<td>
							[PB.name]
						</td>
						<td>
							[get_area(T)]
						</td>
						<td>
							[showCoords(T.x, T.y, T.z, 0, user.client.holder)]
						</td>
						<td>
							[PB.part3 ? ref_PB : "Nothing"]
						</td>
						<td>
							[PB.part1 ? PB.part1 : "Nothing"]
						</td>
						<td>
							[PB.fingerprintslast ? PB.fingerprintslast : "N/A"]
						</td>
						<td>
							<a href='?src=\ref[src];toggle_dud=\ref[PB]'>[PB.force_dud ? SPAN_ALERT("YES") : "No"]</a>
						</td>
						<td>
							<a href='?src=\ref[src];trigger=\ref[PB]'><B>[PB.part3 ? "Trigger" : ""]</B></a>
						</td>
					</tr>"}

		for (var/obj/item/assembly/time_bomb/TB in ST_time)
			var/turf/T = get_turf(TB)
			if (!T || !isturf(T)) continue
			var/ref_TB = "<a href='?src=\ref[src];airmon=\ref[TB.part3]'>[TB.part3]</a>"
			temp += {"<tr>
						<td>
							[TB.name]
						</td>
						<td>
							[get_area(T)]
						</td>
						<td>
							[showCoords(T.x, T.y, T.z, 0, user.client.holder)]
						</td>
						<td>
							[TB.part3 ? ref_TB : "Nothing"]
						</td>
						<td>
							[TB.part1 ? TB.part1 : "Nothing"]
						</td>
						<td>
							[TB.fingerprintslast ? TB.fingerprintslast : "N/A"]
						</td>
						<td>
							<a href='?src=\ref[src];toggle_dud=\ref[TB]'>[TB.force_dud ? SPAN_ALERT("YES") : "No"]</a>
						</td>
						<td>
							<a href='?src=\ref[src];trigger=\ref[TB]'><B>[TB.part3 ? "Trigger" : ""]</B></a>
						</td>
					</tr>"}


		for (var/obj/item/assembly/complete/checked_bomb in bomb_assemblies)
			var/turf/T = get_turf(checked_bomb)
			if (!T || !isturf(T)) continue
			var/ref_checked_bomb = "<a href='?src=\ref[src];airmon=\ref[checked_bomb.target]'>[checked_bomb.target]</a>"
			temp += {"<tr>
						<td>
							[checked_bomb.name]
						</td>
						<td>
							[get_area(T)]
						</td>
						<td>
							[showCoords(T.x, T.y, T.z, 0, user.client.holder)]
						</td>
						<td>
							[checked_bomb.target ? ref_checked_bomb : "Nothing"]
						</td>
						<td>
							[checked_bomb.trigger ? checked_bomb.trigger : "Nothing"]
						</td>
						<td>
							[checked_bomb.fingerprintslast ? checked_bomb.fingerprintslast : "N/A"]
						</td>
						<td>
							<a href='?src=\ref[src];toggle_dud=\ref[checked_bomb]'>[checked_bomb.force_dud ? SPAN_ALERT("YES") : "No"]</a>
						</td>
						<td>
							<a href='?src=\ref[src];trigger=\ref[checked_bomb]'><B>[checked_bomb.target ? "Trigger" : ""]</B></a>
						</td>
					</tr>"}

		for (var/obj/item/assembly/radio_bomb/RB in ST_radio)
			var/turf/T = get_turf(RB)
			if (!T || !isturf(T)) continue
			var/ref_RB = "<a href='?src=\ref[src];airmon=\ref[RB.part3]'>[RB.part3]</a>"
			temp += {"<tr>
						<td>
							[RB.name]
						</td>
						<td>
							[get_area(T)]
						</td>
						<td>
							[showCoords(T.x, T.y, T.z, 0, user.client.holder)]
						</td>
						<td>
							[RB.part3 ? ref_RB : "Nothing"]
						</td>
						<td>
							[RB.part1 ? RB.part1 : "Nothing"]
						</td>
						<td>
							[RB.fingerprintslast ? RB.fingerprintslast : "N/A"]
						</td>
						<td>
							<a href='?src=\ref[src];toggle_dud=\ref[RB]'>[RB.force_dud ? SPAN_ALERT("YES") : "No"]</a>
						</td>
						<td>
							<a href='?src=\ref[src];trigger=\ref[RB]'><B>[RB.part3 ? "Trigger" : ""]</B></a>
						</td>
					</tr>"}

		var/STtable = {"<h2>Single Tank Bombs</h2><hr>
						<table>
							<tr>
								<th>Name</th><th>Area name</th><th>Coords</th><th>Tank</th><th>Detonator</th><th>Fingerprints</th><th>Force Dud</th>
								[temp]
							</tr>
						</table>"}

		temp = ""
		for(var/obj/item/canbomb_detonator/det in dets)
			if(!filter_active_only || det.attachedTo)
				var/turf/T = get_turf(det)
				if (!T || !isturf(T)) continue
				var/ref = "<a href='?src=\ref[src];airmon=\ref[det.attachedTo]'>[det.attachedTo]</a>"
				temp += {"<tr>
							<td>
								[det.name]
							</td>
							<td>
								[get_area(T)]
							</td>
							<td>
								[showCoords(T.x, T.y, T.z, 0, user.client.holder)]
							</td>
							<td>
								[det.attachedTo ? ref : "Nothing"]
							</td>
							<td>
								[det.fingerprintslast ? det.fingerprintslast : "N/A"]
							</td>
							<td>
								[det.attachedTo && det.attachedTo.fingerprintslast ? det.attachedTo.fingerprintslast : "N/A"]
							</td>
							<td>
								<a href='?src=\ref[src];toggle_dud=\ref[det]'>[det.force_dud ? SPAN_ALERT("YES") : "No"]</a>
							</td>
							<td>
								<a href='?src=\ref[src];trigger=\ref[det]'><B>[det.attachedTo ? "Trigger" : ""]</B></a>
							</td>
						</tr>"}

		var/cantable = {"<h2>Canister Bombs</h2><hr>
						<table>
							<tr>
								<th>Name</th><th>Area name</th><th>Coords</th><th>Canister</th><th>Fingerprints (Detonator)</th><th>Fingerprints (Canister)</th><th>Force Dud</th>
								[temp]
							</tr>
						</table>"}

		temp = {"<!doctype HTML>
					<html>
						<head>
							<title>Bomb Monitor</title>
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
							<a href='?src=\ref[src];refresh=rebuild'>Rebuild Lists</a> <a href='?src=\ref[src];refresh=interface'>Refresh</a> <a href='?src=\ref[src];filter=1'>Filtering: [filter_active_only ? "Only Complete" : "All"]</a><br>
							[TTVtable]
							<BR>
							[STtable]
							<BR>
							[cantable]
						</body>
					</html>"}

		user.Browse(temp, "window=bomb_monitor;size=750x500")
		onclose(user, "bomb_monitor", src)

	Topic(href, href_list[])
		if(!usr || !usr.client || !usr.client.holder) return

		if(href_list["refresh"])
			if(href_list["refresh"] == "rebuild")
				lists_built = 0
				build_lists()
			display_ui(usr)
		else if(href_list["airmon"])
			var/obj/O = locate(href_list["airmon"])
			if(O)
				boutput(usr, scan_atmospheric(O)) // We've got a global proc for that now (Convair880).
			else
				boutput(usr, SPAN_ALERT("Unable to locate the object (it's been deleted, somehow. Explosion, probably)."))

		else if(href_list["toggle_dud"])
			var/obj/item/I = locate(href_list["toggle_dud"])

			if (!I)
				boutput(usr, SPAN_ALERT("Unable to locate the object (it's been deleted, somehow. Explosion, probably)."))
				return

			if (istype(I, /obj/item/canbomb_detonator) || (istype(I, /obj/item/assembly/complete) || istype(I, /obj/item/device/transfer_valve) || istype(I, /obj/item/assembly/proximity_bomb) || istype(I, /obj/item/assembly/time_bomb/) || istype(I, /obj/item/assembly/radio_bomb/)))
				I:force_dud = !I:force_dud
				display_ui(usr)
				message_admins("[key_name(usr)] made \the [I] [I:force_dud ? "into a dud" : "able to explode again"] at [log_loc(I)].")
				logTheThing(LOG_ADMIN, usr, "made \the [I] [I:force_dud ? "into a dud" : "able to explode again"] at [log_loc(I)].")
				logTheThing(LOG_DIARY, usr, "made \the [I] [I:force_dud ? "into a dud" : "able to explode again"] at [log_loc(I)].", "admin")

		else  if(href_list["filter"])
			filter_active_only = !filter_active_only
			lists_built=0
			display_ui(usr)

		else if(href_list["trigger"])
			var/obj/item/I = locate(href_list["trigger"])
			var/turf/T = get_turf(I)

			if (!I || !T || !isturf(T)) // Cannot read null.x
				boutput(usr, SPAN_ALERT("Unable to locate the object (it's been deleted, somehow. Explosion, probably)."))
				return

			if (alert("Are you sure you want to detonate \the [I] at [T.x], [T.y], [T.z] ([get_area(I)])?", "Blow shit up.", "Yes", "No") != "Yes") return

			if (!I) // Alerts wait for user input. Bomb might not exist anymore.
				boutput(usr, SPAN_ALERT("Unable to locate the object (it's been deleted, somehow. Explosion, probably)."))
				return

			message_admins("[key_name(usr)] made \the [I] at [log_loc(I)] detonate!")
			logTheThing(LOG_ADMIN, usr, "made \the [I] at [log_loc(I)] detonate!")
			logTheThing(LOG_DIARY, usr, "made \the [I] at [log_loc(I)]  detonate!", "admin")

			if (istype(I, /obj/item/canbomb_detonator))
				var/obj/item/canbomb_detonator/D = I
				D.detonate()
			else if (istype(I, /obj/item/device/transfer_valve))
				var/obj/item/device/transfer_valve/TV = I
				TV.toggle_valve()
			else if (istype(I, /obj/item/assembly/proximity_bomb/))
				var/obj/item/assembly/proximity_bomb/PB = I
				PB.part3.ignite()
			else if (istype(I, /obj/item/assembly/time_bomb/))
				var/obj/item/assembly/time_bomb/TB = I
				TB.part3.ignite()
			else if (istype(I, /obj/item/assembly/complete))
				var/obj/item/assembly/complete/checked_bomb = I
				SEND_SIGNAL(checked_bomb.applier, COMSIG_ITEM_ASSEMBLY_APPLY, checked_bomb, checked_bomb.target)
			else if (istype(I, /obj/item/assembly/radio_bomb/))
				var/obj/item/assembly/radio_bomb/RB = I
				RB.part3.ignite()
			display_ui(usr, 1)
		if(href_list["close"])
			usr.Browse(null, "window=bomb_monitor")
