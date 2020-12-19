#define SECREC_MAIN_MENU 1
#define SECREC_LIST_RECORDS 2
#define SECREC_MANAGE_RECORDS 3
#define SECREC_VIEW_RECORD 4


/obj/machinery/computer/secure_data
	name = "Security Records"
	icon_state = "datasec"
	req_access = list(access_security)
	var/obj/item/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active_record_general = null
	var/datum/data/record/active_record_security = null
	// var/a_id = null
	var/temp = null
	var/printing = null
	// var/can_change_id = 0
	var/require_login = 1
	desc = "A computer that allows an authorized user to set warrants, view fingerprints, and add notes to various crewmembers."

	lr = 1
	lg = 0.7
	lb = 0.74

/obj/machinery/computer/secure_data/detective_computer
	icon = 'icons/obj/computer.dmi'
	icon_state = "messyfiles"
	req_access = list(access_forensics_lockers)

/obj/machinery/computer/secure_data/attackby(obj/item/I as obj, user as mob)
	if (isscrewingtool(I))
		playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
		if (do_after(user, 2 SECONDS))
			if (src.status & BROKEN)
				boutput(user, "<span class='notice'>The broken glass falls out.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if (src.material) A.setMaterial(src.material)
				var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
				G.set_loc(src.loc)
				var/obj/item/circuitboard/secure_data/M = new /obj/item/circuitboard/secure_data( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				qdel(src)
			else
				boutput(user, "<span class='notice'>You disconnect the monitor.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if (src.material) A.setMaterial(src.material)
				var/obj/item/circuitboard/secure_data/M = new /obj/item/circuitboard/secure_data( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				qdel(src)
	else
		src.attack_hand(user)
	return

/obj/machinery/computer/secure_data/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/secure_data/attack_hand(mob/user as mob)
	if (..())
		return
	var/dat

	if (src.temp)
		dat = {"
			[src.temp]
			<br>
			<br><a href="javascript:goBYOND('action=temp');">Return</a>
			"}
	else
		dat = {"
			Confirm Identity: <a href="javascript:goBYOND('action=scan');">[src.scan ? src.scan.name : "----------"]</a>
			[src.authenticated ? "&mdash; <a href=\"javascript:goBYOND('action=logout');\">Log Out</a>" : ""]<hr>
			"}

		if (src.authenticated)
			src.validate_records()

			switch(src.screen)
				if (SECREC_MAIN_MENU)
					dat += {"
					<h3>Security Records</h3>
					<a href="javascript:goBYOND('action=list');">List Records</a>
					<br><a href="javascript:goBYOND('action=search');">Search Records</a>
					<br><a href="javascript:goBYOND('action=search_fingerprint');">Search Fingerprints</a>
					<hr>
					<a href="javascript:goBYOND('action=record_maintenance');">Record Maintenance</a>
					"}

				if (SECREC_LIST_RECORDS)
					dat += "<h3>Security Record List</h3><hr>"
					for (var/datum/data/record/R in data_core.general)
						dat += {"
							<a href="javascript:goBYOND('action=view_record;rec=\ref[R]');">[R.fields["id"]]: [R.fields["name"]]
							<br>
							"}

					dat += {"
						<hr><a href="javascript:goBYOND('action=main');">Back</a>
						"}

				if (SECREC_MANAGE_RECORDS)
					dat += {"
					<h3>Security Record Maintenance</h3>
					<hr>
					<a href="javascript:goBYOND('action=new_general_record');">Create New Record</a>
					<br>
					<br><a href="javascript:doPopup('del_all_records', 'Really delete ALL security records?');">Delete All Records</a>
					<br>
					<br><a href="javascript:goBYOND('action=main');">Back</a>
					"}

				if (SECREC_VIEW_RECORD)
					dat += {"
					<h3>Security Record</h3>
<table>
	<tbody>
		<tr><th colspan='3'>General Record</th></tr>
					"}
					if (src.active_record_general)
						var/photo_filename = null
						try
							var/datum/computer/file/image/img_record = src.active_record_general.fields["file_photo"]
							var/icon/photo = img_record.ourIcon
							if (!photo)
								photo = wanted_poster_unknown
							photo_filename = copytext("\ref[src.active_record_general]", 4, -1)
							if (photo)
								usr << browse_rsc(photo, "[photo_filename].png")
						catch
							photo_filename = null

						dat += {"
		<tr>
			<th>Name</th>
			<td><a href="javascript:goBYOND('action=field;field=name');">[src.active_record_general.fields["name"]]</a></td>
			<td rowspan="9" style="text-align: center; vertical-align: middle;">[photo_filename ? {"<img style="-ms-interpolation-mode:nearest-neighbor;" height="64" width="64" src="[photo_filename].png">"} : "No photo<br>available"]
			<br>File Photo</td>
		</tr>
		<tr>
			<th>ID No.</th>
			<td><a href="javascript:goBYOND('action=field;field=id');">[src.active_record_general.fields["id"]]</a></td>
		</tr>
		<tr>
			<th>Gender</th>
			<td><a href="javascript:goBYOND('action=field;field=sex');">[src.active_record_general.fields["sex"]]</a></td>
		</tr>
		<tr>
			<th>Age</th>
			<td><a href="javascript:goBYOND('action=field;field=age');">[src.active_record_general.fields["age"]]</a></td>
		</tr>
		<tr>
			<th>Job</th>
			<td><a href="javascript:goBYOND('action=field;field=rank');">[src.active_record_general.fields["rank"]]</a></td>
		</tr>
		<tr>
			<th>Fingerprint</th>
			<td><a href="javascript:goBYOND('action=field;field=fingerprint');">[src.active_record_general.fields["fingerprint"]]</a></td>
		</tr>
		<tr>
			<th>DNA</th>
			<td>[src.active_record_general.fields["dna"]]</td>
		</tr>
		<tr>
			<th>Physical Status</th>
			<td>[src.active_record_general.fields["p_stat"]]</td>
		</tr>
		<tr>
			<th>Mental Status</th>
			<td>[src.active_record_general.fields["m_stat"]]</td>
		</tr>
			"}
					else
						dat += {"
		<tr><td colspan='3' style='text-align: center;'>General record missing.</td></tr>
						"}

					dat += {"
		<tr><th colspan='3'>Security Record</th></tr>

					"}

					if (src.active_record_security)

						var/list/record_to_display = list(
							"none" = "None",
							"arrest" = "*Arrest*",
							"incarcerated" = "Incarcerated",
							"parolled" = "Parolled",
							"released" = "Released"
							)

						var/list/arrest_status = list()

						for (var/n in record_to_display)
							arrest_status += {"<a href="javascript:goBYOND('action=criminal;criminal=[n]');" class="[n] [record_to_display[n] == src.active_record_security.fields["criminal"] ? "active" : ""]">[record_to_display[n]]</a>"}

						dat += {"
		<tr>
			<th>Criminal Status</th>
			<td colspan='2'><div class="crimer">[arrest_status.Join(" ")]</div></td>
		</tr>
		<tr>
			<th>Major Crimes</th>
			<td colspan='2'><a href="javascript:goBYOND('action=field;field=major_crimes');">[src.active_record_security.fields["ma_crim"]]</a>
			<br>
			<br><strong>Details:</strong> (<a href="javascript:goBYOND('action=field;field=major_crime_details');">&#9998; Edit</a>)<br><div class='monospace'>[src.active_record_security.fields["ma_crim_d"]]</div></td>
		</tr>
		<tr>
			<th>Minor Crimes</th>
			<td colspan='2'><a href="javascript:goBYOND('action=field;field=minor_crimes');">[src.active_record_security.fields["mi_crim"]]</a>
			<br>
			<br><strong>Details:</strong> (<a href="javascript:goBYOND('action=field;field=minor_crime_details');">&#9998; Edit</a>)<br><div class='monospace'>[src.active_record_security.fields["mi_crim_d"]]</div></td>
		</tr>
		<tr>
			<th>Notes</th>
			<td colspan='2'><a href="javascript:goBYOND('action=field;field=notes');">&#9998; Edit</a>
			<br><div class='monospace'>[src.active_record_security.fields["notes"]]</div></td>
		</tr>
		<tr>
			<th colspan="3">Comments / Log</th>
		</tr>
						"}

						if (src.active_record_security.fields["log"])
							var/list/log_list = active_record_security.fields["log"]
							for (var/comment_num in 1 to log_list.len)
								var/list/comment = log_list[comment_num]
								dat += {"
			<tr>
				<th colspan="2" style="font-weight: normal; text-align: left;">
					[comment["time"]] - <strong>[comment["author"]]</strong>
				</th>
				<th>[comment["author"] != "Deleted" ? "<a href=\"javascript:doPopup('del_comment;comment=[comment_num]', 'Delete this entry?');\">Delete</a>" : "&mdash;"]</th>
			</tr>
			<tr><td colspan="3" class="monospace">[comment["text"]]</td></tr>
			"}

						dat += {"
		<tr>
			<th colspan="3"><a href="javascript:goBYOND('action=add_comment');">Add Entry</a></th>
		</tr>
	</tbody>
</table>
<br><a href="javascript:doPopup('del_security_record', 'Delete security record?');">Delete Security Record</a>
							"}
					else
						dat += {"
		<tr><td colspan='3' style='text-align: center;'>
			Security record missing.
			<br><br><a href="javascript:goBYOND('action=new_security_record');">Create new record</a>
		</td></tr>
	</tbody>
</table>
							"}
					dat += {"
<br><a href="javascript:doPopup('del_full_record', 'Delete full record?');">Delete Full Record</a>
<br><a href="javascript:goBYOND('action=print_record');">Print Record</a>
<br>
<br><a href="javascript:goBYOND('action=list');">Back</a>
						"}

		else
			dat += {"
					<a href="javascript:goBYOND('action=login');">Log In</a>
					"}

	user.Browse({"
	<title>Security Records</title>
	<style>
		.monospace { white-space: pre-wrap; }
		#popup-container {
			position: fixed;
			top: 0;
			left: 0;
			right: 0;
			bottom: 0;
			background: rgba(128, 128, 128, 0.5);
		}

		#popup {
			margin: 1em;
			padding: 1em;
			border: 1px solid black;
			background: white;
			color: black;
			text-align: center;
		}

		#popup a {
			margin: 0 1.5em;
			padding: 0.25em 1em;
			background: #aaf;
			color: #008;
		}

		.crimer a {
			display: inline-block;
			vertical-align: middle;
			border: 3px double #666;
			background: #eee;
			font-weight: bold;
			padding: 0.1em 0.3em;
			border-radius: 3px;
			text-decoration: none;
		}

		.none         {}
		.arrest       { color: #ff0000; background: #ffeeee; }
		.incarcerated { color: #888800; background: #ffffbb; }
		.parolled     { color: #339966; background: #bbffdd; }
		.released     { color: #3366ff; background: #bbddff; }
		.crimer .active { border: 3px solid black; }
		.none.active,         .none:hover         { background: #ffffff; color: black; }
		.arrest.active,       .arrest:hover       { background: #ff0000; color: white; }
		.incarcerated.active, .incarcerated:hover { background: #ffff33; color: black; }
		.parolled.active,     .parolled:hover     { background: #33cc66; color: black; }
		.released.active,     .released:hover     { background: #3399ff; color: black; }

	/* borrowed from char prefs */
	table {
		border-collapse: collapse;
		font-size: 100%;
		width: 100%;
	}
	td, th {
		border: 1px solid #888;
		padding: 0.1em 0.3em;
	}
	th {
		background: rgba(125, 125, 125, 0.4);
		white-space: nowrap;
	}

	th\[colspan="3"] {
		background: rgba(125, 125, 125, 0.6);
		padding: 0.5em;
	}
	</style>
	<script>
		function goBYOND(url) {
			// copy-pasted from the geneticsMachines version
			// mostly to reduce the sheer number of src text injections everywhere
			var surrogate = document.getElementById("surrogate");
			surrogate.src = "?src=\ref[src];" + url;
		}

		function doPopup(link, text) {
			var popupC = document.getElementById("popup-container");
			var popup = document.getElementById("popup");
			popup.innerHTML = text + "<br><br><a href=\\"javascript:goBYOND('action="+ link +";answer=yes');\\">Yes</a> <a href=\\"javascript:goBYOND('action="+ link +";answer=no');\\">No</a>";
			popupC.style.display = "";
		}
	</script>
</head>
<body>
	<iframe src="about:blank" style="display: none;" id="surrogate"></iframe>
	<div id="popup-container" style="display: none;">
		<div id="popup"></div>
	</div>


	[dat]
</body></html>"}, "window=secure_rec;size=600x700")
	onclose(user, "secure_rec")
	return

/obj/machinery/computer/secure_data/proc/validate_records()
	// Most of these checks were done inline; moved here for ease-of-use
	if (src.active_record_general && (!istype(src.active_record_general, /datum/data/record) || !data_core.general.Find(src.active_record_general)))
		src.active_record_general = null
	if (src.active_record_security && (!istype(src.active_record_security, /datum/data/record) || !data_core.security.Find(src.active_record_security)))
		src.active_record_security = null

/obj/machinery/computer/secure_data/proc/validate_can_still_use(var/datum/data/record/general_record, var/datum/data/record/security_record, mob/user as mob)
	// Check if we can still use it (after the input() calls)
	if ((general_record && general_record != src.active_record_general) || (security_record && security_record != src.active_record_security))
		return 1
	if (user && (user.lying || user.stat))
		return 1
	if (user && (get_dist(src, user) > 1 || !istype(src.loc, /turf)) && !issilicon(user) && !isAI(usr))
		return 1



/obj/machinery/computer/secure_data/Topic(href, href_list)
	if (..())
		return

	src.validate_records()

	src.add_dialog(usr)
	if (href_list["temp"])
		src.temp = null

	switch (href_list["action"])
		if ("temp")
			src.temp = null

		if ("scan")
			if (src.scan)
				src.scan.set_loc(src.loc)
				src.scan = null
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/card/id))
					usr.drop_item()
					I.set_loc(src)

					src.scan = I
				else if (istype(I, /obj/item/magtractor))
					var/obj/item/magtractor/mag = I
					if (istype(mag.holding, /obj/item/card/id))
						I = mag.holding
						mag.dropItem(0)
						I.set_loc(src)
						src.scan = I

		if ("logout") // && require_login)
			src.authenticated = null
			src.screen = null
			src.active_record_general = null
			src.active_record_security = null

		if ("login")
			if (!require_login || ((issilicon(usr) || isAI(usr)) && !isghostdrone(usr)))
				src.active_record_general = null
				src.active_record_security = null
				src.authenticated = 1
				src.rank = "AI"
				src.screen = SECREC_MAIN_MENU
			if (istype(src.scan, /obj/item/card/id))
				src.active_record_general = null
				src.active_record_security = null
				if (check_access(src.scan))
					src.authenticated = src.scan.registered
					src.rank = src.scan.assignment
					src.screen = SECREC_MAIN_MENU

	if (src.authenticated)

		switch (href_list["action"])
			if ("list")
				src.screen = SECREC_LIST_RECORDS
				src.active_record_general = null
				src.active_record_security = null

			if ("record_maintenance")
				src.screen = SECREC_MANAGE_RECORDS
				src.active_record_general = null
				src.active_record_security = null

			if ("del_all_records")
				if (href_list["answer"] == "yes")
					for (var/datum/data/record/R in data_core.security)
						data_core.security -= R
						qdel(R)
					src.temp = "All records deleted."
				else
					src.temp = null

			if ("main")
				src.screen = SECREC_MAIN_MENU
				src.active_record_general = null
				src.active_record_security = null

			if ("field")
				var/datum/data/record/current_general = src.active_record_general
				var/datum/data/record/current_security = src.active_record_security

				switch(href_list["field"])
					if ("name") //todo: sanitize these fucking inputs jesus christ
						if (istype(src.active_record_general, /datum/data/record))
							var/t1 = input("Please input name:", "Security Records", src.active_record_general.fields["name"], null) as text
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_general.fields["name"] = t1
					if ("id")
						if (istype(src.active_record_security, /datum/data/record))
							var/t1 = input("Please input id:", "Security Records", src.active_record_general.fields["id"], null) as text
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_general.fields["id"] = t1
					if ("fingerprint")
						if (istype(src.active_record_general, /datum/data/record))
							var/t1 = input("Please input fingerprint hash:", "Security Records", src.active_record_general.fields["fingerprint"], null) as text
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_general.fields["fingerprint"] = t1
					if ("sex")
						if (istype(src.active_record_general, /datum/data/record))
							if (src.active_record_general.fields["sex"] == "Male")
								src.active_record_general.fields["sex"] = "Female"
							else
								src.active_record_general.fields["sex"] = "Male"
					if ("age")
						if (istype(src.active_record_general, /datum/data/record))
							var/t1 = input("Age:", "Security Records", src.active_record_general.fields["age"], null) as num
							t1 = max(1, min(t1, 99))
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_general.fields["age"] = t1
					if ("minor_crimes")
						if (istype(src.active_record_security, /datum/data/record))
							var/t1 = input("Minor crimes:", "Security Records", src.active_record_security.fields["mi_crim"], null) as text
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_security.fields["mi_crim"] = t1
					if ("minor_crime_details")
						if (istype(src.active_record_security, /datum/data/record))
							var/t1 = input("Minor crime details:", "Security Records", src.active_record_security.fields["mi_crim_d"], null) as message
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_security.fields["mi_crim_d"] = t1
					if ("major_crimes")
						if (istype(src.active_record_security, /datum/data/record))
							var/t1 = input("Major crimes:", "Security Records", src.active_record_security.fields["ma_crim"], null) as text
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_security.fields["ma_crim"] = t1
					if ("major_crime_details")
						if (istype(src.active_record_security, /datum/data/record))
							var/t1 = input("Major crime details:", "Security Records", src.active_record_security.fields["ma_crim_d"], null) as message
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_security.fields["ma_crim_d"] = t1
					if ("notes")
						if (istype(src.active_record_security, /datum/data/record))
							var/t1 = input("Notes:", "Security Records", src.active_record_security.fields["notes"], null) as message
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_security.fields["notes"] = t1
					if ("rank")
						var/list/L = list( "Head of Personnel", "Captain", "AI" )
						if ((istype(src.active_record_general, /datum/data/record) && L.Find(src.rank)))

							if (istype(src.active_record_security, /datum/data/record))
								var/t1 = input("Job/Rank:", "Security Records", src.active_record_security.fields["rank"], null) as text
								t1 = adminscrub(t1)
								if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
									return
								src.active_record_security.fields["rank"] = t1

						// 	src.temp = {"
						// <b>Rank:</b>
						// <br>
						// <br><b>Assistants:</b>
						// <br>
						// <br><a href="javascript:goBYOND('action=rank;rank=res_assist');">Assistant</a>
						// <br>
						// <br><b>Technicians:</b>
						// <br>
						// <br><a href="javascript:goBYOND('action=rank;rank=foren_tech');">Detective</a>
						// <br>
						// <br><a href="javascript:goBYOND('action=rank;rank=atmo_tech');">Atmospheric Technician</a>
						// <br>
						// <br><a href="javascript:goBYOND('action=rank;rank=engineer');">Station Engineer</a>
						// <br>
						// <br><b>Researchers:</b>
						// <br>
						// <br><a href="javascript:goBYOND('action=rank;rank=med_res');">Geneticist</a>
						// <br>
						// <br><a href="javascript:goBYOND('action=rank;rank=tox_res');">Scientist</a>
						// <br>
						// <br><b>Officers:</b>
						// <br>
						// <br><a href="javascript:goBYOND('action=rank;rank=med_doc');">Medical Doctor</a>
						// <br>
						// <br><a href="javascript:goBYOND('action=rank;rank=secure_off');">Security Officer</a>
						// <br>
						// <br><b>Higher Officers:</b>
						// <br>
						// <br><a href="javascript:goBYOND('action=rank;rank=hoperson');">Head of Security</a>
						// <br>
						// <br><a href="javascript:goBYOND('action=rank;rank=hosecurity');">Head of Personnel</a>
						// <br>
						// <br><a href="javascript:goBYOND('action=rank;rank=captain');">Captain</a>
						// <br>
						// "}
						else
							alert(usr, "You do not have the required rank to do this!")

			// if ("rank")
			// 	if (src.active_record_general)
			// 		switch(href_list["rank"])
			// 			if ("res_assist")
			// 				src.active_record_general.fields["rank"] = "Assistant"
			// 			if ("foren_tech")
			// 				src.active_record_general.fields["rank"] = "Detective"
			// 			if ("atmo_tech")
			// 				src.active_record_general.fields["rank"] = "Atmospheric Technician"
			// 			if ("engineer")
			// 				src.active_record_general.fields["rank"] = "Station Engineer"
			// 			if ("med_res")
			// 				src.active_record_general.fields["rank"] = "Geneticist"
			// 			if ("tox_res")
			// 				src.active_record_general.fields["rank"] = "Scientist"
			// 			if ("med_doc")
			// 				src.active_record_general.fields["rank"] = "Medical Doctor"
			// 			if ("secure_off")
			// 				src.active_record_general.fields["rank"] = "Security Officer"
			// 			if ("hoperson")
			// 				src.active_record_general.fields["rank"] = "Head of Security"
			// 			if ("hosecurity")
			// 				src.active_record_general.fields["rank"] = "Head of Personnel"
			// 			if ("captain")
			// 				src.active_record_general.fields["rank"] = "Captain"
			// 			if ("bartender")
			// 				src.active_record_general.fields["rank"] = "Bartender"
			// 			if ("chemist")
			// 				src.active_record_general.fields["rank"] = "Chemist"
			// 			if ("janitor")
			// 				src.active_record_general.fields["rank"] = "Janitor"
			// 			if ("clown")
			// 				src.active_record_general.fields["rank"] = "Clown"
			// 		src.temp = null


			if ("criminal")
				if (src.active_record_security)
					switch(href_list["criminal"])
						if ("none")
							src.active_record_security.fields["criminal"] = "None"
						if ("arrest")
							src.active_record_security.fields["criminal"] = "*Arrest*"
							if (usr && src.active_record_general.fields["name"])
								logTheThing("station", usr, null, "[src.active_record_general.fields["name"]] is set to arrest by [usr] (using the ID card of [src.authenticated]) [log_loc(src)]")
						if ("incarcerated")
							src.active_record_security.fields["criminal"] = "Incarcerated"
						if ("parolled")
							src.active_record_security.fields["criminal"] = "Parolled"
						if ("released")
							src.active_record_security.fields["criminal"] = "Released"
					src.temp = null

			if ("del_security_record")
				if (href_list["answer"] == "yes" && src.active_record_security)
					data_core.security -= src.active_record_security
					qdel(src.active_record_security)
					src.active_record_security = null
					src.temp = "Security record deleted."
				else
					src.temp = null

			if ("del_full_record")
				if (href_list["answer"] == "yes")
					for (var/datum/data/record/R in data_core.medical)
						if ((R.fields["name"] == src.active_record_general.fields["name"] || R.fields["id"] == src.active_record_general.fields["id"]))
							data_core.medical -= R
							qdel(R)
					if (src.active_record_security)
						data_core.security -= src.active_record_security
						qdel(src.active_record_security)
					if (src.active_record_general)
						data_core.general -= src.active_record_general
						qdel(src.active_record_general)

					src.active_record_general = null
					src.active_record_security = null
					src.screen = SECREC_LIST_RECORDS
					src.temp = "Record deleted."

				else
					src.temp = null

			if ("view_record")
				var/datum/data/record/R = locate(href_list["rec"])
				var/S = locate(href_list["rec"])
				if (!data_core.general.Find(R))
					src.temp = "Record Not Found!"
					return
				for (var/datum/data/record/E in data_core.security)
					if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						S = E
				src.active_record_general = R
				src.active_record_security = S
				src.screen = SECREC_VIEW_RECORD

			if ("new_general_record")
				var/datum/data/record/G = new /datum/data/record()
				G.fields["name"] = "New Record"
				G.fields["id"] = num2hex(rand(1, 1.6777215E7), 6)
				G.fields["rank"] = "Unassigned"
				G.fields["sex"] = "Unknown"
				G.fields["age"] = "Unknown"
				G.fields["fingerprint"] = "Unknown"
				G.fields["p_stat"] = "Active"
				G.fields["m_stat"] = "Stable"
				data_core.general += G
				src.active_record_general = G
				src.active_record_security = null
				src.screen = SECREC_VIEW_RECORD

			if ("new_security_record")
				if ((istype(src.active_record_general, /datum/data/record) && !( istype(src.active_record_security, /datum/data/record) )))
					var/datum/data/record/R = new /datum/data/record(  )
					R.fields["name"] = src.active_record_general.fields["name"]
					R.fields["id"] = src.active_record_general.fields["id"]
					R.name = {"Security Record #[R.fields["id"]]"}
					R.fields["criminal"] = "None"
					R.fields["mi_crim"] = "None"
					R.fields["mi_crim_d"] = "No minor crime convictions."
					R.fields["ma_crim"] = "None"
					R.fields["ma_crim_d"] = "No major crime convictions."
					R.fields["notes"] = "No notes."
					data_core.security += R
					src.active_record_security = R
					src.screen = SECREC_VIEW_RECORD

			if ("add_comment")
				if (!src.active_record_security)
					return
				var/current_security = src.active_record_security
				var/t1 = input("Add Comment:", "Security Records", null, null) as message
				t1 = adminscrub(t1)
				if (!t1 || src.validate_can_still_use(null, current_security, usr))
					return
				// var/counter = 1
				// while (src.active_record_security.fields["com_[counter]"])
				// 	counter++

				var/list/new_comment = list(
					"author" = "[src.authenticated] ([src.rank])",
					"time" = "[time2text(world.realtime, "hh:mm:ss")]",
					"text" = t1
					)

				if (!src.active_record_security.fields["log"])
					src.active_record_security.fields["log"] = list()

				// this looks dumb as fuck, but: byond
				src.active_record_security.fields["log"] += list( new_comment )

			if ("del_comment")
				var/comment_num = text2num(href_list["comment"])
				if (src.active_record_security && src.active_record_security.fields["log"] && src.active_record_security.fields["log"][comment_num])
					src.active_record_security.fields["log"][comment_num]["author"] = "Deleted"
					src.active_record_security.fields["log"][comment_num]["text"] = "<div style='text-align: center;'>Deleted at [time2text(world.realtime, "hh:mm:ss")]</div>"


			if ("search_fingerprint")
				var/t1 = input("Search String: (Fingerprint)", "Security Records", null, null) as text
				t1 = adminscrub(t1)
				if (!t1 || src.validate_can_still_use(null, null, usr))
					return
				src.active_record_general = null
				src.active_record_security = null
				t1 = lowertext(t1)
				for (var/datum/data/record/R in data_core.general)
					if (lowertext(R.fields["fingerprint"]) == t1)
						src.active_record_general = R
				if (!src.active_record_general)
					src.temp = "Could not locate record matching '[t1]''."
				else
					for (var/datum/data/record/E in data_core.security)
						if ((E.fields["name"] == src.active_record_general.fields["name"] || E.fields["id"] == src.active_record_general.fields["id"]))
							src.active_record_security = E
					src.screen = SECREC_VIEW_RECORD

			if ("search")
				var/t1 = input("Search String: (Name, DNA, or ID)", "Security Records", null, null) as text
				t1 = adminscrub(t1)
				if (!t1 || src.validate_can_still_use(null, null, usr))
					return
				src.active_record_general = null
				src.active_record_security = null
				t1 = lowertext(t1)
				for (var/datum/data/record/R in data_core.general)
					if ((lowertext(R.fields["name"]) == t1 || t1 == lowertext(R.fields["dna"]) || t1 == lowertext(R.fields["id"])))
						src.active_record_general = R
				if (!src.active_record_general)
					src.temp = "Could not locate record [t1]."
				else
					for (var/datum/data/record/E in data_core.security)
						if ((E.fields["name"] == src.active_record_general.fields["name"] || E.fields["id"] == src.active_record_general.fields["id"]))
							src.active_record_security = E
					src.screen = SECREC_VIEW_RECORD

			if ("print_record")
				if (!( src.printing ))
					src.printing = 1
					sleep(5 SECONDS)
					var/obj/item/paper/P = new /obj/item/paper( src.loc )
					P.info = "<center><b>Security Record</b></center><br>"
					src.validate_records()
					if (src.active_record_general)
						P.info += {"
						Name: [src.active_record_general.fields["name"]] ID: [src.active_record_general.fields["id"]]
						<br>
						<br>Sex: [src.active_record_general.fields["sex"]]
						<br>
						<br>Age: [src.active_record_general.fields["age"]]
						<br>
						<br>Fingerprint: [src.active_record_general.fields["fingerprint"]]
						<br>
						<br>Physical Status: [src.active_record_general.fields["p_stat"]]
						<br>
						<br>Mental Status: [src.active_record_general.fields["m_stat"]]
						<br>
						"}
					else
						P.info += "<b>General Record Lost!</b><br>"
					if (src.active_record_security)
						P.info += {"
						<br>
						<br><center><b>Security Data</b></center>
						<br>
						<br>Criminal Status: [src.active_record_security.fields["criminal"]]
						<br>
						<br>
						<br>
						<br>Minor Crimes: [src.active_record_security.fields["mi_crim"]]
						<br>
						<br>Details: [src.active_record_security.fields["mi_crim_d"]]
						<br>
						<br>
						<br>
						<br>Major Crimes: [src.active_record_security.fields["ma_crim"]]
						<br>
						<br>Details: [src.active_record_security.fields["ma_crim_d"]]
						<br>
						<br>
						<br>
						<br>Important Notes:
						<br>
						<br>&emsp;[src.active_record_security.fields["notes"]]
						<br>
						<br>
						<br>
						<br><center><b>Comments/Log</b></center>
						<br>
						"}
						var/counter = 1
						while (src.active_record_security.fields["com_[counter]"])
							P.info += {"[src.active_record_security.fields["com_[counter]"]]<br>"}
							counter++
					else
						P.info += "<b>Security Record Lost!</b><br>"
					P.info += "</TT>"
					P.name = "paper- 'Security Record'"
					src.printing = null
	src.add_fingerprint(usr)
	src.updateUsrDialog()

	return

#undef SECREC_MAIN_MENU
#undef SECREC_LIST_RECORDS
#undef SECREC_MANAGE_RECORDS
#undef SECREC_VIEW_RECORD
