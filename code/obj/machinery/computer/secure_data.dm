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
		if(do_after(user, 20))
			if (src.status & BROKEN)
				boutput(user, "<span class='notice'>The broken glass falls out.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
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
				if(src.material) A.setMaterial(src.material)
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
	if(..())
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
			Confirm Identity: <a href="javascript:goBYOND('action=scan');">[src.scan ? src.scan.name : "----------"]</a><hr>
			"}

		if (src.authenticated)
			src.validate_records()
			switch(src.screen)
				if (SECREC_MAIN_MENU)
					dat += {"
					<a href="javascript:goBYOND('action=search');">Search Records</a>
					<br>
					<br><a href="javascript:goBYOND('action=list');">List Records</a>
					<br>
					<br><a href="javascript:goBYOND('action=search_fingerprint');">Search Fingerprints</a>
					<br>
					<br>
					<br><a href="javascript:goBYOND('action=record_maintenance');">Record Maintenance</a>
					<br>
					<br><a href="javascript:goBYOND('action=logout');">Log Out</a>
					<br>
					<br>
					"}

				if (SECREC_LIST_RECORDS)
					dat += "<b>Record List</b>:<hr>"
					for (var/datum/data/record/R in data_core.general)
						dat += {"
							<a href="javascript:goBYOND('action=d_rec;rec=\ref[R]');">[R.fields["id"]]: [R.fields["name"]]
							<br>
							"}

					dat += {"
						<hr><a href="javascript:goBYOND('action=main');">Back</a>
						"}

				if (SECREC_MANAGE_RECORDS)
					dat += {"
					<b>Record Maintenance</b>
					<hr>
					<br><a href="javascript:goBYOND('action=new_r');">New Record</a>
					<br>
					<br><a href="javascript:doPopup('del_all_records', 'Really delete ALL security records?');">Delete All Records</a>
					<br>
					<br><a href="javascript:goBYOND('action=main');">Back</a>
					"}

				if (SECREC_VIEW_RECORD)
					dat += {"
					<center><b>Security Record</b></center><br>
					"}
					if (src.active_record_general)
						dat += {"
							Name: <a href="javascript:goBYOND('action=field;field=name');">[src.active_record_general.fields["name"]]</a> ID: <a href="javascript:goBYOND('action=field;field=id');">[src.active_record_general.fields["id"]]</a>
							<br>
							<br>Sex: <a href="javascript:goBYOND('action=field;field=sex');">[src.active_record_general.fields["sex"]]</a>
							<br>
							<br>Age: <a href="javascript:goBYOND('action=field;field=age');">[src.active_record_general.fields["age"]]</a>
							<br>
							<br>Rank: <a href="javascript:goBYOND('action=field;field=rank');">[src.active_record_general.fields["rank"]]</a>
							<br>
							<br>Fingerprint: <a href="javascript:goBYOND('action=field;field=fingerprint');">[src.active_record_general.fields["fingerprint"]]</a>
							<br>
							<br>DNA: [src.active_record_general.fields["dna"]]
							<br>
							<br>Physical Status: [src.active_record_general.fields["p_stat"]]
							<br>
							<br>Mental Status: [src.active_record_general.fields["m_stat"]]
							<br>
						"}
					else
						dat += "<b>General Record Lost!</b><br>"
					if (src.active_record_security)
						dat += {"
						<br>
						<br><center><b>Security Data</b></center>
						<br>
						<br>Criminal Status: <a href="javascript:goBYOND('action=field;field=criminal');">[src.active_record_security.fields["criminal"]]</a>
						<br>
						<br>Minor Crimes: <a href="javascript:goBYOND('action=field;field=mi_crim');">[src.active_record_security.fields["mi_crim"]]</a>
						<br>
						<br>Details: <a href="javascript:goBYOND('action=field;field=mi_crim_d');">[src.active_record_security.fields["mi_crim_d"]]</a>
						<br>
						<br>
						<br>
						<br>Major Crimes: <a href="javascript:goBYOND('action=field;field=ma_crim');">[src.active_record_security.fields["ma_crim"]]</a>
						<br>
						<br>Details: <a href="javascript:goBYOND('action=field;field=ma_crim_d');">[src.active_record_security.fields["ma_crim_d"]]</a>
						<br>
						<br>
						<br>
						<br>Important Notes:
						<br>
						<br>&emsp;<a href="javascript:goBYOND('action=field;field=notes');">[src.active_record_security.fields["notes"]]</a>
						<br>
						<br>
						<br>
						<br><center><b>Comments/Log</b></center>
						<br>
						"}

						var/counter = 1
						while (src.active_record_security.fields["com_[counter]"])
							dat += {"
								[src.active_record_security.fields["com_[counter]"]]
								<br><a href="javascript:doPopup('del_comment;comment=[counter]', 'Delete this entry?');">Delete Entry</a>
								<br>
								<br>"}
								counter++

						dat += {"
							<a href="javascript:goBYOND('action=add_comment');">Add Entry</a>
							<br>
							<br><a href="javascript:doPopup('del_security_record', 'Delete security record?');">Delete Security Record</a>
							<br>
							<br>
							"}
					else
						dat += {"
							<b>Security Record Lost!</b><br>
							<a href="javascript:goBYOND('action=new');">New Record</a>
							<br>
							<br>
							"}
					dat += {"
						<br><a href="javascript:doPopup('del_full_record', 'Delete full record?');">Delete Full Record</a>
						<br>
						<br>
						<br><a href="javascript:goBYOND('action=print_record');">Print Record</a>
						<br>
						<br><a href="javascript:goBYOND('action=list');">Back</a>
						<br>
						"}

		else
			dat += {"
					<a href="javascript:goBYOND('action=login');">Log In</a>
					"}

	user.Browse({"
	<title>Security Records</title>
	<style>
		body { font-family: Consolas, monospace; }
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
</body></html>"}, "window=secure_rec")
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
	if(user && (user.lying || user.stat))
		return 1
	if (user && (get_dist(src, user) > 1 || !istype(src.loc, /turf)) && !issilicon(user) && !isAI(usr))
		return 1



/obj/machinery/computer/secure_data/Topic(href, href_list)
	if(..())
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
				if(check_access(src.scan))
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
					if("name") //todo: sanitize these fucking inputs jesus christ
						if (istype(src.active_record_general, /datum/data/record))
							var/t1 = input("Please input name:", "Security Records", src.active_record_general.fields["name"], null) as text
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_general.fields["name"] = t1
					if("id")
						if (istype(src.active_record_security, /datum/data/record))
							var/t1 = input("Please input id:", "Security Records", src.active_record_general.fields["id"], null) as text
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_general.fields["id"] = t1
					if("fingerprint")
						if (istype(src.active_record_general, /datum/data/record))
							var/t1 = input("Please input fingerprint hash:", "Security Records", src.active_record_general.fields["fingerprint"], null) as text
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_general.fields["fingerprint"] = t1
					if("sex")
						if (istype(src.active_record_general, /datum/data/record))
							if (src.active_record_general.fields["sex"] == "Male")
								src.active_record_general.fields["sex"] = "Female"
							else
								src.active_record_general.fields["sex"] = "Male"
					if("age")
						if (istype(src.active_record_general, /datum/data/record))
							var/t1 = input("Age:", "Security Records", src.active_record_general.fields["age"], null) as num
							t1 = max(1, min(t1, 99))
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_general.fields["age"] = t1
					if("mi_crim")
						if (istype(src.active_record_security, /datum/data/record))
							var/t1 = input("Minor crimes:", "Security Records", src.active_record_security.fields["mi_crim"], null) as text
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_security.fields["mi_crim"] = t1
					if("mi_crim_d")
						if (istype(src.active_record_security, /datum/data/record))
							var/t1 = input("Minor detail crimes:", "Security Records", src.active_record_security.fields["mi_crim_d"], null) as message
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_security.fields["mi_crim_d"] = t1
					if("ma_crim")
						if (istype(src.active_record_security, /datum/data/record))
							var/t1 = input("Major crimes:", "Security Records", src.active_record_security.fields["ma_crim"], null) as text
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_security.fields["ma_crim"] = t1
					if("ma_crim_d")
						if (istype(src.active_record_security, /datum/data/record))
							var/t1 = input("Major crime details:", "Security Records", src.active_record_security.fields["ma_crim_d"], null) as message
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_security.fields["ma_crim_d"] = t1
					if("notes")
						if (istype(src.active_record_security, /datum/data/record))
							var/t1 = input("Notes:", "Security Records", src.active_record_security.fields["notes"], null) as message
							t1 = adminscrub(t1)
							if (!t1 || src.validate_can_still_use(current_general, current_security, usr))
								return
							src.active_record_security.fields["notes"] = t1
					if("criminal")
						if (istype(src.active_record_security, /datum/data/record))
							src.temp = {"
						<b>Criminal Status:</b>
						<br>
						<br>&emsp;<a href="javascript:goBYOND('action=criminal2;criminal2=none');">None</a>
						<br>
						<br>&emsp;<a href="javascript:goBYOND('action=criminal2;criminal2=arrest');">*Arrest*</a>
						<br>
						<br>&emsp;<a href="javascript:goBYOND('action=criminal2;criminal2=incarcerated');">Incarcerated</a>
						<br>
						<br>&emsp;<a href="javascript:goBYOND('action=criminal2;criminal2=parolled');">Parolled</a>
						<br>
						<br>&emsp;<a href="javascript:goBYOND('action=criminal2;criminal2=released');">Released</a>
						<br>
						"}
					if("rank")
						var/list/L = list( "Head of Personnel", "Captain", "AI" )
						if ((istype(src.active_record_general, /datum/data/record) && L.Find(src.rank)))
							src.temp = {"
						<b>Rank:</b>
						<br>
						<br><b>Assistants:</b>
						<br>
						<br><a href="javascript:goBYOND('action=rank;rank=res_assist');">Assistant</a>
						<br>
						<br><b>Technicians:</b>
						<br>
						<br><a href="javascript:goBYOND('action=rank;rank=foren_tech');">Detective</a>
						<br>
						<br><a href="javascript:goBYOND('action=rank;rank=atmo_tech');">Atmospheric Technician</a>
						<br>
						<br><a href="javascript:goBYOND('action=rank;rank=engineer');">Station Engineer</a>
						<br>
						<br><b>Researchers:</b>
						<br>
						<br><a href="javascript:goBYOND('action=rank;rank=med_res');">Geneticist</a>
						<br>
						<br><a href="javascript:goBYOND('action=rank;rank=tox_res');">Scientist</a>
						<br>
						<br><b>Officers:</b>
						<br>
						<br><a href="javascript:goBYOND('action=rank;rank=med_doc');">Medical Doctor</a>
						<br>
						<br><a href="javascript:goBYOND('action=rank;rank=secure_off');">Security Officer</a>
						<br>
						<br><b>Higher Officers:</b>
						<br>
						<br><a href="javascript:goBYOND('action=rank;rank=hoperson');">Head of Security</a>
						<br>
						<br><a href="javascript:goBYOND('action=rank;rank=hosecurity');">Head of Personnel</a>
						<br>
						<br><a href="javascript:goBYOND('action=rank;rank=captain');">Captain</a>
						<br>
						"}
						else
							alert(usr, "You do not have the required rank to do this!")

			if ("rank")
				if (src.active_record_general)
					switch(href_list["rank"])
						if("res_assist")
							src.active_record_general.fields["rank"] = "Assistant"
						if("foren_tech")
							src.active_record_general.fields["rank"] = "Detective"
						if("atmo_tech")
							src.active_record_general.fields["rank"] = "Atmospheric Technician"
						if("engineer")
							src.active_record_general.fields["rank"] = "Station Engineer"
						if("med_res")
							src.active_record_general.fields["rank"] = "Geneticist"
						if("tox_res")
							src.active_record_general.fields["rank"] = "Scientist"
						if("med_doc")
							src.active_record_general.fields["rank"] = "Medical Doctor"
						if("secure_off")
							src.active_record_general.fields["rank"] = "Security Officer"
						if("hoperson")
							src.active_record_general.fields["rank"] = "Head of Security"
						if("hosecurity")
							src.active_record_general.fields["rank"] = "Head of Personnel"
						if("captain")
							src.active_record_general.fields["rank"] = "Captain"
						if("barman")
							src.active_record_general.fields["rank"] = "Barman"
						if("chemist")
							src.active_record_general.fields["rank"] = "Chemist"
						if("janitor")
							src.active_record_general.fields["rank"] = "Janitor"
						if("clown")
							src.active_record_general.fields["rank"] = "Clown"
					src.temp = null


			if ("criminal2")
				if (src.active_record_security)
					switch(href_list["criminal2"])
						if("none")
							src.active_record_security.fields["criminal"] = "None"
						if("arrest")
							src.active_record_security.fields["criminal"] = "*Arrest*"
							if (usr && src.active_record_general.fields["name"])
								logTheThing("station", usr, null, "[src.active_record_general.fields["name"]] is set to arrest by [usr] (using the ID card of [src.authenticated]) [log_loc(src)]")
						if("incarcerated")
							src.active_record_security.fields["criminal"] = "Incarcerated"
						if("parolled")
							src.active_record_security.fields["criminal"] = "Parolled"
						if("released")
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

			if ("d_rec")
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

			if ("new_r")
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

			if ("new")
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
				var/counter = 1
				while (src.active_record_security.fields["com_[counter]"])
					counter++
				src.active_record_security.fields["com_[counter]"] = {"Made by [src.authenticated] ([src.rank]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [CURRENT_SPACE_YEAR]
						<br>[t1]
						"}

			if ("del_comment")
				if (src.active_record_security && src.active_record_security.fields["com_[href_list["comment"]]"])
					src.active_record_security.fields["com_[href_list["comment"]]"] = "<b>Deleted</b>"

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
