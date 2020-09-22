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
	var/a_id = null
	var/temp = null
	var/printing = null
	var/can_change_id = 0
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
	var/list/htmlOut = list()
	if (src.temp)
		dat = text({"
					<TT>[]</TT>
					<br>
					<br><a href="javascript:goBYOND('temp=1');">Clear Screen</a>
					"}, src.temp)
	else
		dat = text({"
					Confirm Identity: <a href="javascript:goBYOND('scan=1');">[]</a><hr>
					"}, (src.scan ? text("[]", src.scan.name) : "----------"))
		if (src.authenticated)
			src.validate_records()
			switch(src.screen)
				if (SECREC_MAIN_MENU)
					dat += {"
					<a href="javascript:goBYOND('search=1');">Search Records</a>
					<br>
					<br><a href="javascript:goBYOND('list=1');">List Records</a>
					<br>
					<br><a href="javascript:goBYOND('search_f=1');">Search Fingerprints</a>
					<br>
					<br><a href="javascript:goBYOND('new_r=1');">New Record</a>
					<br>
					<br>
					<br>
					<br><a href="javascript:goBYOND('rec_m=1');">Record Maintenance</a>
					<br>
					<br><a href="javascript:goBYOND('logout=1');">{Log Out}</a>
					<br>
					<br>
					"}

				if (SECREC_LIST_RECORDS)
					dat += "<b>Record List</b>:<hr>"
					for(var/datum/data/record/R in data_core.general)
						dat += text({"
						<a href="javascript:goBYOND('d_rec=\ref[]');">[]: []
						<br>
						"}, R, R.fields["id"], R.fields["name"])

					dat += {"
					<hr><a href="javascript:goBYOND('main=1');">Back</a>
					"}

				if (SECREC_MANAGE_RECORDS)
					dat += {"
					<b>Records Maintenance</b><hr>
					<br><a href="javascript:goBYOND('back=1');">Backup To Disk</a>
					<br>
					<br><a href="javascript:goBYOND('u_load=1');">Upload From disk</a>
					<br>
					<br><a href="javascript:goBYOND('del_all=1');">Delete All Records</a>
					<br>
					<br>
					<br>
					<br><a href="javascript:goBYOND('main=1');">Back</a>
					"}

				if (SECREC_VIEW_RECORD)
					dat += {"
					<center><b>Security Record</b></center><br>
					"}
					if (src.active_record_general)
						dat += text({"
						Name: <a href="javascript:goBYOND('field=name');">[]</a> ID: <a href="javascript:goBYOND('field=id');">[]</a>
						<br>
						<br>Sex: <a href="javascript:goBYOND('field=sex');">[]</a>
						<br>
						<br>Age: <a href="javascript:goBYOND('field=age');">[]</a>
						<br>
						<br>Rank: <a href="javascript:goBYOND('field=rank');">[]</a>
						<br>
						<br>Fingerprint: <a href="javascript:goBYOND('field=fingerprint');">[]</a>
						<br>
						<br>DNA: []
						<br>
						<br>Physical Status: []
						<br>
						<br>Mental Status: []
						<br>
						"}, src.active_record_general.fields["name"], src.active_record_general.fields["id"], src.active_record_general.fields["sex"], src.active_record_general.fields["age"], src.active_record_general.fields["rank"], src.active_record_general.fields["fingerprint"], src.active_record_general.fields["dna"], src.active_record_general.fields["p_stat"], src.active_record_general.fields["m_stat"])
					else
						dat += "<b>General Record Lost!</b><br>"
					if (src.active_record_security)
						dat += text({"
						<br>
						<br><center><b>Security Data</b></center>
						<br>
						<br>Criminal Status: <a href="javascript:goBYOND('field=criminal');">[]</a>
						<br>
						<br>
						<br>
						<br>Minor Crimes: <a href="javascript:goBYOND('field=mi_crim');">[]</a>
						<br>
						<br>Details: <a href="javascript:goBYOND('field=mi_crim_d');">[]</a>
						<br>
						<br>
						<br>
						<br>Major Crimes: <a href="javascript:goBYOND('field=ma_crim');">[]</a>
						<br>
						<br>Details: <a href="javascript:goBYOND('field=ma_crim_d');">[]</a>
						<br>
						<br>
						<br>
						<br>Important Notes:
						<br>
						<br>&emsp;<a href="javascript:goBYOND('field=notes');">[]</a>
						<br>
						<br>
						<br>
						<br><center><b>Comments/Log</b></center>
						<br>
						"}, src.active_record_security.fields["criminal"], src.active_record_security.fields["mi_crim"], src.active_record_security.fields["mi_crim_d"], src.active_record_security.fields["ma_crim"], src.active_record_security.fields["ma_crim_d"], src.active_record_security.fields["notes"])

						var/counter = 1
						while (src.active_record_security.fields["com_[counter]"])
							dat += text({"
							[]
							<br><a href="javascript:goBYOND('del_c=[]');">Delete Entry</a>
							<br>
							<br>"}, src.active_record_security.fields["com_[counter]"], counter)
							counter++

						dat += {"
							<a href="javascript:goBYOND('add_c=1');">Add Entry</a>
							<br>
							<br>
							"}

						dat += {"
							<a href="javascript:goBYOND('del_r=1');">Delete Record (Security Only)</a>
							<br>
							<br>
							"}
					else
						dat += {"
							<b>Security Record Lost!</b><br>
							<a href="javascript:goBYOND('new=1');">New Record</a>
							<br>
							<br>
							"}
					dat += {"
						<br><a href="javascript:goBYOND('dela_r=1');">Delete Record (ALL)</a>
						<br>
						<br>
						<br><a href="javascript:goBYOND('print_p=1');">Print Record</a>
						<br>
						<br><a href="javascript:goBYOND('list=1');">Back</a>
						<br>
						"}

		else
			dat += {"
					<a href="javascript:goBYOND('login=1');">{Log In}</a>
					"}

	user.Browse({"
	<title>Security Records</title>
	<style>
		body { font-family: Consolas, monospace; }
	</style>
	<script>
		function goBYOND(url) {
			// copy-pasted from the geneticsMachines version
			// mostly to reduce the sheer number of src text injections everywhere
			var surrogate = document.getElementById("surrogate");
			surrogate.src = "?src=\ref[src];" + url;
		}
	</script>
</head>
<body>
	<iframe src="about:blank" style="display: none;" id="surrogate"></iframe>
	[dat]
</body></html>
					"}, "window=secure_rec")
	onclose(user, "secure_rec")
	return

/obj/machinery/computer/secure_data/proc/validate_records()
	// Most of these checks were done inline; moved here for ease-of-use
	if (src.active_record_general && (!istype(src.active_record_general, /datum/data/record) || !data_core.general.Find(src.active_record_general)))
		src.active_record_general = null
	if (src.active_record_security && (!istype(src.active_record_security, /datum/data/record) || !data_core.security.Find(src.active_record_security)))
		src.active_record_security = null


/obj/machinery/computer/secure_data/Topic(href, href_list)
	if(..())
		return

	src.validate_records()

	src.add_dialog(usr)
	if (href_list["temp"])
		src.temp = null
	if (href_list["scan"])
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

	else if (href_list["logout"] && require_login)
		src.authenticated = null
		src.screen = null
		src.active_record_general = null
		src.active_record_security = null

	else if (href_list["login"])
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
		var/usr_is_robot = issilicon(usr) || isAIeye(usr)
		if (href_list["list"])
			src.screen = SECREC_LIST_RECORDS
			src.active_record_general = null
			src.active_record_security = null

		else if (href_list["rec_m"])
			src.screen = SECREC_MANAGE_RECORDS
			src.active_record_general = null
			src.active_record_security = null

		else if (href_list["del_all"])
			src.temp = text({"
					Are you sure you wish to delete all records?
					<br>
					<br>&emsp;<a href="javascript:goBYOND('temp=1;del_all2=1');">Yes</a>
					<br>
					<br>&emsp;<a href="javascript:goBYOND('temp=1');">No</a>
					<br>
					"})

		else if (href_list["del_all2"])
			for(var/datum/data/record/R in data_core.security)
				//R = null
				data_core.security -= R
				qdel(R)
				//Foreach goto(497)
			src.temp = "All records deleted."

		else if (href_list["main"])
			src.screen = SECREC_MAIN_MENU
			src.active_record_general = null
			src.active_record_security = null

		else if (href_list["field"])
			var/a1 = src.active_record_general
			var/a2 = src.active_record_security
			switch(href_list["field"])
				if("name") //todo: sanitize these fucking inputs jesus christ
					if (istype(src.active_record_general, /datum/data/record))
						var/t1 = input("Please input name:", "Secure. records", src.active_record_general.fields["name"], null)  as text
						t1 = copytext(adminscrub(t1), 1, MAX_MESSAGE_LEN)
						if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!usr_is_robot))) || src.active_record_general != a1)
							return
						src.active_record_general.fields["name"] = t1
				if("id")
					if (istype(src.active_record_security, /datum/data/record))
						var/t1 = input("Please input id:", "Secure. records", src.active_record_general.fields["id"], null)  as text
						t1 = copytext(adminscrub(t1), 1, MAX_MESSAGE_LEN)
						if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!usr_is_robot)) || src.active_record_general != a1))
							return
						src.active_record_general.fields["id"] = t1
				if("fingerprint")
					if (istype(src.active_record_general, /datum/data/record))
						var/t1 = input("Please input fingerprint hash:", "Secure. records", src.active_record_general.fields["fingerprint"], null)  as text
						t1 = copytext(adminscrub(t1), 1, MAX_MESSAGE_LEN)
						if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!usr_is_robot)) || src.active_record_general != a1))
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
						var/t1 = input("Please input age:", "Secure. records", src.active_record_general.fields["age"], null)  as num
						t1 = max(1, min(t1, 99))
						if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!usr_is_robot)) || src.active_record_general != a1))
							return
						src.active_record_general.fields["age"] = t1
				if("mi_crim")
					if (istype(src.active_record_security, /datum/data/record))
						var/t1 = input("Please input minor disabilities list:", "Secure. records", src.active_record_security.fields["mi_crim"], null)  as text
						t1 = copytext(adminscrub(t1), 1, MAX_MESSAGE_LEN)
						if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!usr_is_robot)) || src.active_record_security != a2))
							return
						src.active_record_security.fields["mi_crim"] = t1
				if("mi_crim_d")
					if (istype(src.active_record_security, /datum/data/record))
						var/t1 = input("Please summarize minor dis.:", "Secure. records", src.active_record_security.fields["mi_crim_d"], null)  as message
						t1 = copytext(adminscrub(t1), 1, MAX_MESSAGE_LEN)
						if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!usr_is_robot)) || src.active_record_security != a2))
							return
						src.active_record_security.fields["mi_crim_d"] = t1
				if("ma_crim")
					if (istype(src.active_record_security, /datum/data/record))
						var/t1 = input("Please input major diabilities list:", "Secure. records", src.active_record_security.fields["ma_crim"], null)  as text
						t1 = copytext(adminscrub(t1), 1, MAX_MESSAGE_LEN)
						if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!usr_is_robot)) || src.active_record_security != a2))
							return
						src.active_record_security.fields["ma_crim"] = t1
				if("ma_crim_d")
					if (istype(src.active_record_security, /datum/data/record))
						var/t1 = input("Please summarize major dis.:", "Secure. records", src.active_record_security.fields["ma_crim_d"], null)  as message
						t1 = copytext(adminscrub(t1), 1, MAX_MESSAGE_LEN)
						if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!usr_is_robot)) || src.active_record_security != a2))
							return
						src.active_record_security.fields["ma_crim_d"] = t1
				if("notes")
					if (istype(src.active_record_security, /datum/data/record))
						var/t1 = input("Please summarize notes:", "Secure. records", src.active_record_security.fields["notes"], null)  as message
						t1 = copytext(adminscrub(t1), 1, MAX_MESSAGE_LEN)
						if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!usr_is_robot)) || src.active_record_security != a2))
							return
						src.active_record_security.fields["notes"] = t1
				if("criminal")
					if (istype(src.active_record_security, /datum/data/record))
						src.temp = text({"
					<b>Criminal Status:</b>
					<br>
					<br>&emsp;<a href="javascript:goBYOND('temp=1;criminal2=none');">None</a>
					<br>
					<br>&emsp;<a href="javascript:goBYOND('temp=1;criminal2=arrest');">*Arrest*</a>
					<br>
					<br>&emsp;<a href="javascript:goBYOND('temp=1;criminal2=incarcerated');">Incarcerated</a>
					<br>
					<br>&emsp;<a href="javascript:goBYOND('temp=1;criminal2=parolled');">Parolled</a>
					<br>
					<br>&emsp;<a href="javascript:goBYOND('temp=1;criminal2=released');">Released</a>
					<br>
					"})
				if("rank")
					var/list/L = list( "Head of Personnel", "Captain", "AI" )
					if ((istype(src.active_record_general, /datum/data/record) && L.Find(src.rank)))
						src.temp = text({"
					<b>Rank:</b>
					<br>
					<br><b>Assistants:</b>
					<br>
					<br><a href="javascript:goBYOND('temp=1;rank=res_assist');">Assistant</a>
					<br>
					<br><b>Technicians:</b>
					<br>
					<br><a href="javascript:goBYOND('temp=1;rank=foren_tech');">Detective</a>
					<br>
					<br><a href="javascript:goBYOND('temp=1;rank=atmo_tech');">Atmospheric Technician</a>
					<br>
					<br><a href="javascript:goBYOND('temp=1;rank=engineer');">Station Engineer</a>
					<br>
					<br><b>Researchers:</b>
					<br>
					<br><a href="javascript:goBYOND('temp=1;rank=med_res');">Geneticist</a>
					<br>
					<br><a href="javascript:goBYOND('temp=1;rank=tox_res');">Scientist</a>
					<br>
					<br><b>Officers:</b>
					<br>
					<br><a href="javascript:goBYOND('temp=1;rank=med_doc');">Medical Doctor</a>
					<br>
					<br><a href="javascript:goBYOND('temp=1;rank=secure_off');">Security Officer</a>
					<br>
					<br><b>Higher Officers:</b>
					<br>
					<br><a href="javascript:goBYOND('temp=1;rank=hoperson');">Head of Security</a>
					<br>
					<br><a href="javascript:goBYOND('temp=1;rank=hosecurity');">Head of Personnel</a>
					<br>
					<br><a href="javascript:goBYOND('temp=1;rank=captain');">Captain</a>
					<br>
					"})
					else
						alert(usr, "You do not have the required rank to do this!")

		else if (href_list["rank"])
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


		else if (href_list["criminal2"])
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


		else if (href_list["del_r"])
			if (src.active_record_security)
				src.temp = text({"
					Are you sure you wish to delete the record (Security Portion Only)?
					<br>
					<br>&emsp;<a href="javascript:goBYOND('temp=1;del_r2=1');">Yes</a>
					<br>
					<br>&emsp;<a href="javascript:goBYOND('temp=1');">No</a>
					<br>
					"})

		else if (href_list["del_r2"])
			if (src.active_record_security)
				//src.active_record_security = null
				data_core.security -= src.active_record_security
				qdel(src.active_record_security)

		else if (href_list["dela_r"])
			if (src.active_record_general)
				src.temp = text({"
					Are you sure you wish to delete the record (ALL)?
					<br>
					<br>&emsp;<a href="javascript:goBYOND('temp=1;dela_r2=1');">Yes</a>
					<br>
					<br>&emsp;<a href="javascript:goBYOND('temp=1');">No</a>
					<br>
					"})

		else if (href_list["dela_r2"])
			for(var/datum/data/record/R in data_core.medical)
				if ((R.fields["name"] == src.active_record_general.fields["name"] || R.fields["id"] == src.active_record_general.fields["id"]))
					//R = null
					data_core.medical -= R
					qdel(R)
			if (src.active_record_security)
				//src.active_record_security = null
				data_core.security -= src.active_record_security
				qdel(src.active_record_security)
			if (src.active_record_general)
				//src.active_record_general = null
				data_core.general -= src.active_record_general
				qdel(src.active_record_general)

		else if (href_list["d_rec"])
			var/datum/data/record/R = locate(href_list["d_rec"])
			var/S = locate(href_list["d_rec"])
			if (!( data_core.general.Find(R) ))
				src.temp = "Record Not Found!"
				return
			for(var/datum/data/record/E in data_core.security)
				if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
					S = E
			src.active_record_general = R
			src.active_record_security = S
			src.screen = SECREC_VIEW_RECORD

		else if (href_list["new_r"])
			var/datum/data/record/G = new /datum/data/record(  )
			G.fields["name"] = "New Record"
			G.fields["id"] = num2hex(rand(1, 1.6777215E7), 6)
			G.fields["rank"] = "Unassigned"
			G.fields["sex"] = "Male"
			G.fields["age"] = "Unknown"
			G.fields["fingerprint"] = "Unknown"
			G.fields["p_stat"] = "Active"
			G.fields["m_stat"] = "Stable"
			data_core.general += G
			src.active_record_general = G
			src.active_record_security = null

		else if (href_list["new"])
			if ((istype(src.active_record_general, /datum/data/record) && !( istype(src.active_record_security, /datum/data/record) )))
				var/datum/data/record/R = new /datum/data/record(  )
				R.fields["name"] = src.active_record_general.fields["name"]
				R.fields["id"] = src.active_record_general.fields["id"]
				R.name = text({"
					Security Record #[]
					"}, R.fields["id"])
				R.fields["criminal"] = "None"
				R.fields["mi_crim"] = "None"
				R.fields["mi_crim_d"] = "No minor crime convictions."
				R.fields["ma_crim"] = "None"
				R.fields["ma_crim_d"] = "No major crime convictions."
				R.fields["notes"] = "No notes."
				data_core.security += R
				src.active_record_security = R
				src.screen = SECREC_VIEW_RECORD

		else if (href_list["add_c"])
			if (!( istype(src.active_record_security, /datum/data/record) ))
				return
			var/a2 = src.active_record_security
			var/t1 = input("Add Comment:", "Secure. records", null, null)  as message
			t1 = copytext(adminscrub(t1), 1, MAX_MESSAGE_LEN)
			if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!usr_is_robot)) || src.active_record_security != a2))
				return
			var/counter = 1
			while(src.active_record_security.fields[text({"com_[]"}, counter)])
				counter++
			src.active_record_security.fields[text({"com_[]"}, counter)] = text({"Made by [] ([]) on [], [CURRENT_SPACE_YEAR]
					<br>[]
					"}, src.authenticated, src.rank, time2text(world.realtime, "DDD MMM DD hh:mm:ss"), t1)

		else if (href_list["del_c"])
			if ((istype(src.active_record_security, /datum/data/record) && src.active_record_security.fields[text({"com_[]"}, href_list["del_c"])]))
				src.active_record_security.fields[text({"com_[]"}, href_list["del_c"])] = "<b>Deleted</b>"

		else if (href_list["search_f"])
			var/t1 = input("Search String: (Fingerprint)", "Secure. records", null, null)  as text
			t1 = copytext(adminscrub(t1), 1, MAX_MESSAGE_LEN)
			if ((!( t1 ) || usr.stat || !( src.authenticated ) || usr.restrained() || (!in_range(src, usr)) && (!usr_is_robot)))
				return
			src.active_record_general = null
			src.active_record_security = null
			t1 = lowertext(t1)
			for(var/datum/data/record/R in data_core.general)
				if (lowertext(R.fields["fingerprint"]) == t1)
					src.active_record_general = R
			if (!( src.active_record_general ))
				src.temp = text({"
					Could not locate record [].
					"}, t1)
			else
				for(var/datum/data/record/E in data_core.security)
					if ((E.fields["name"] == src.active_record_general.fields["name"] || E.fields["id"] == src.active_record_general.fields["id"]))
						src.active_record_security = E
				src.screen = SECREC_VIEW_RECORD

		else if (href_list["search"])
			var/t1 = input("Search String: (Name, DNA, or ID)", "Secure. records", null, null)  as text
			t1 = copytext(adminscrub(t1), 1, MAX_MESSAGE_LEN)
			if ((!( t1 ) || usr.stat || !( src.authenticated ) || usr.restrained() || !in_range(src, usr)))
				return
			src.active_record_general = null
			src.active_record_security = null
			t1 = lowertext(t1)
			for(var/datum/data/record/R in data_core.general)
				if ((lowertext(R.fields["name"]) == t1 || t1 == lowertext(R.fields["dna"]) || t1 == lowertext(R.fields["id"])))
					src.active_record_general = R
			if (!( src.active_record_general ))
				src.temp = text({"
					Could not locate record [].
					"}, t1)
			else
				for(var/datum/data/record/E in data_core.security)
					if ((E.fields["name"] == src.active_record_general.fields["name"] || E.fields["id"] == src.active_record_general.fields["id"]))
						src.active_record_security = E
				src.screen = SECREC_VIEW_RECORD

		else if (href_list["print_p"])
			if (!( src.printing ))
				src.printing = 1
				sleep(5 SECONDS)
				var/obj/item/paper/P = new /obj/item/paper( src.loc )
				P.info = "<center><b>Security Record</b></center><br>"
				src.validate_records()
				if (src.active_record_general)
					P.info += text({"
					Name: [] ID: []
					<br>
					<br>Sex: []
					<br>
					<br>Age: []
					<br>
					<br>Fingerprint: []
					<br>
					<br>Physical Status: []
					<br>
					<br>Mental Status: []
					<br>
					"}, src.active_record_general.fields["name"], src.active_record_general.fields["id"], src.active_record_general.fields["sex"], src.active_record_general.fields["age"], src.active_record_general.fields["fingerprint"], src.active_record_general.fields["p_stat"], src.active_record_general.fields["m_stat"])
				else
					P.info += "<b>General Record Lost!</b><br>"
				if (src.active_record_security)
					P.info += text({"
					<br>
					<br><center><b>Security Data</b></center>
					<br>
					<br>Criminal Status: []
					<br>
					<br>
					<br>
					<br>Minor Crimes: []
					<br>
					<br>Details: []
					<br>
					<br>
					<br>
					<br>Major Crimes: []
					<br>
					<br>Details: []
					<br>
					<br>
					<br>
					<br>Important Notes:
					<br>
					<br>&emsp;[]
					<br>
					<br>
					<br>
					<br><center><b>Comments/Log</b></center>
					<br>
					"}, src.active_record_security.fields["criminal"], src.active_record_security.fields["mi_crim"], src.active_record_security.fields["mi_crim_d"], src.active_record_security.fields["ma_crim"], src.active_record_security.fields["ma_crim_d"], src.active_record_security.fields["notes"])
					var/counter = 1
					while(src.active_record_security.fields[text({"com_[]"}, counter)])
						P.info += text({"
					[]
					<br>"}, src.active_record_security.fields[text("com_[]", counter)])
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
