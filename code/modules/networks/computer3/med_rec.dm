


#define MENU_MAIN 0 //Byond. Enums.  Lacks them. Etc
#define MENU_INDEX 1
#define MENU_IN_RECORD 2
#define MENU_FIELD_INPUT 3
#define MENU_SEARCH_INPUT 4
#define MENU_VIRUS_INDEX 5
#define MENU_VIRUS_RECORD 6

#define FIELDNUM_NAME 1
#define FIELDNUM_FULLNAME 2
#define FIELDNUM_SEX 3
#define FIELDNUM_AGE 4
#define FIELDNUM_PRINT 5
#define FIELDNUM_DNA 6
#define FIELDNUM_PSTAT 7
#define FIELDNUM_MSTAT 8
#define FIELDNUM_BLOODTYPE 9
#define FIELDNUM_MINDIS 10
#define FIELDNUM_MINDET 11
#define FIELDNUM_MAJDIS 12
#define FIELDNUM_MAJDET 13
#define FIELDNUM_ALLERGY 14
#define FIELDNUM_ALGDET 15
#define FIELDNUM_DISEASE 16
#define FIELDNUM_DISDET 17
#define FIELDNUM_TRAITS 18
#define FIELDNUM_NOTES  19

#define FIELDNUM_DELETE "d"
#define FIELDNUM_NEWREC 99

/datum/computer/file/terminal_program/medical_records
	name = "MedTrak"
	size = 12
	req_access = list(access_medical)
	var/tmp/menu = MENU_MAIN
	var/tmp/field_input = 0
	var/tmp/authenticated = null //Are we currently logged in?
	var/datum/computer/file/user_data/account = null
	var/list/record_list = list()  //List of records, for jumping direclty to a specific ID
	var/datum/data/record/active_general = null //General record
	var/datum/data/record/active_medical = null //Medical record
	var/log_string = null //Log usage of record system, can be dumped to a text file.

	var/setup_acc_filepath = "/logs/sysusr"//Where do we look for login data?
	var/setup_logdump_name = "medlog" //What name do we give our logdump textfile?

	initialize()
/*
		var/title_art = {"<pre>
  __  __        _     _____          _
 |  \\/  |___ __| |___|_   _|_ _ __ _| |__
 | |\\/| / -_) _` |___| | | | '_/ _` | / /
 |_|  |_\\___\\__,_|     |_| |_| \\__,_|_\\_\\</pre>"}
*/
		src.authenticated = null
		src.record_list = data_core.general.Copy() //Initial setting of record list.
		src.master.temp = null
		src.menu = MENU_MAIN
		src.field_input = 0
		//src.print_text(" [title_art]")
		if(!src.find_access_file()) //Find the account information, as it's essentially a ~digital ID card~
			src.print_text("<b>Error:</b> Cannot locate user file.  Quitting...")
			src.master.unload_program(src) //Oh no, couldn't find the file.
			return

		if(!src.check_access(src.account.access))
			src.print_text("User [src.account.registered] does not have needed access credentials.<br>Quitting...")
			src.master.unload_program(src)
			return

		src.authenticated = src.account.registered
		src.log_string += "<br><b>LOGIN:</b> [src.authenticated]"

		src.print_text(mainmenu_text())
		return


	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = command_list[1]
		command_list -= command_list[1]

		switch(menu)
			if (MENU_MAIN)
				switch (command)
					if ("0") //Exit program
						src.print_text("Quitting...")
						src.master.unload_program(src)
						return

					if ("1") //View records
						src.record_list = data_core.general

						src.menu = MENU_INDEX
						src.print_index()

					if ("2") //Search records
						src.print_text("Please enter target name, ID, DNA, or fingerprint.")

						src.menu = MENU_SEARCH_INPUT
						return

					if ("3") //Viral records.

						src.master.temp = null
						src.print_text(virusmenu_text())

						src.menu = MENU_VIRUS_INDEX
						return

			if (MENU_INDEX)
				var/index_number = round( max( text2num(command), 0) )
				if (index_number == 0)
					src.menu = MENU_MAIN
					src.master.temp = null
					src.print_text(mainmenu_text())
					return

				if (!istype(record_list) || index_number > record_list.len)
					src.print_text("Invalid record.")
					return

				var/datum/data/record/check = src.record_list[index_number]
				if(!check || !istype(check))
					src.print_text("<b>Error:</b> Record Data Invalid.")
					return

				src.active_general = check
				src.active_medical = null
				if (data_core.general.Find(check))
					for (var/datum/data/record/E in data_core.medical)
						if ((E.fields["name"] == src.active_general.fields["name"] || E.fields["id"] == src.active_general.fields["id"]))
							src.active_medical = E
							break

				src.log_string += "<br>Log loaded: [src.active_general.fields["id"]]"

				if (src.print_active_record())
					src.menu = MENU_IN_RECORD
				return

			if (MENU_IN_RECORD)
				switch(lowertext(command))
					if ("r")
						src.print_active_record()
						return
					if ("d")
						src.print_text("Are you sure? (Y/N)")
						src.field_input = FIELDNUM_DELETE
						src.menu = MENU_FIELD_INPUT
						return
					if ("p")
						var/obj/item/peripheral/printcard = find_peripheral("LAR_PRINTER")
						if(!printcard)
							src.print_text("<b>Error:</b> No printer detected.")
							return

						//Okay, let's put together something to print.
						var/info = "<center><B>Medical Record</B></center><br>"
						if (istype(src.active_general, /datum/data/record) && data_core.general.Find(src.active_general))
							info += {"
							Full Name: [src.active_general.fields["full_name"]] ID: [src.active_general.fields["id"]]
							<br><br>Sex: [src.active_general.fields["sex"]]
							<br><br>Age: [src.active_general.fields["age"]]
							<br><br>Rank: [src.active_general.fields["rank"]]
							<br><br>Fingerprint: [src.active_general.fields["fingerprint"]]
							<br><br>DNA: [src.active_general.fields["dna"]]
							<br><br>Photo: [istype(src.active_general.fields["file_photo"], /datum/computer/file/image) ? "On File" : "None"]
							<br><br>Physical Status: [src.active_general.fields["p_stat"]]
							<br><br>Mental Status: [src.active_general.fields["m_stat"]]"}
						else
							info += "<b>General Record Lost!</b><br>"
						if ((istype(src.active_medical, /datum/data/record) && data_core.medical.Find(src.active_medical)))
							info += {"
							<br><br><center><b>Medical Data</b></center><br>
							<br><br>Current Health: [src.active_medical.fields["h_imp"]]
							<br>Blood Type: [src.active_medical.fields["bioHolder.bloodType"]]
							<br><br>Minor Disabilities: [src.active_medical.fields["mi_dis"]]
							<br><br>Details: [src.active_medical.fields["mi_dis_d"]]
							<br><br><br>Major Disabilities: [src.active_medical.fields["ma_dis"]]
							<br><br>Details: [src.active_medical.fields["ma_dis_d"]]
							<br><br><br>Allergies: [src.active_medical.fields["alg"]]
							<br><br>Details: [src.active_medical.fields["alg_d"]]
							<br><br><br>Current Diseases: [src.active_medical.fields["cdi"]] (per disease info placed in log/comment section)
							<br>Details: [src.active_medical.fields["cdi_d"]]<br><br><br>
							<br>Traits: [src.active_medical.fields["traits"]]<br><br><br>
							Important Notes:<br>
							<br>&emsp;[src.active_medical.fields["notes"]]<br>"}

						else
							info += "<br><center><b>Medical Record Lost!</b></center><br>"

						var/datum/signal/signal = get_free_signal()
						signal.data["data"] = info
						signal.data["title"] = "Medical Record"
						src.peripheral_command("print",signal, "\ref[printcard]")

						src.print_text("Printing...")
						return

				var/field_number = round( max( text2num(command), 0) )
				if (field_number == 0)
					src.menu = MENU_INDEX
					src.print_index()
					return

				src.field_input = field_number
				switch(field_number)
					if (FIELDNUM_SEX)
						src.print_text("Please select: (1) Female (2) Male (3) Other (0) Back")
						src.menu = MENU_FIELD_INPUT
						return

					if (FIELDNUM_BLOODTYPE)
						src.print_text("Please select: (1) A+ (2) A- (3) B+ (4) B-<br> (5) AB+ (6) AB- (7) O+ (8) O- (0) Back")
						src.menu = MENU_FIELD_INPUT
						return

					if (FIELDNUM_NEWREC)
						if (src.active_medical)
							return

						var/datum/data/record/R = new /datum/data/record(  )
						R.fields["name"] = src.active_general.fields["name"]
						R.fields["full_name"] = src.active_general.fields["full_name"]
						R.fields["id"] = src.active_general.fields["id"]
						R.name = "Medical Record #[R.fields["id"]]"
						R.fields["bioHolder.bloodType"] = "Unknown"
						R.fields["mi_dis"] = "None"
						R.fields["mi_dis_d"] = "No minor disabilities have been declared."
						R.fields["ma_dis"] = "None"
						R.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
						R.fields["alg"] = "None"
						R.fields["alg_d"] = "No allergies have been detected in this patient."
						R.fields["cdi"] = "None"
						R.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
						R.fields["notes"] = "No notes."
						R.fields["h_imp"] = "No health implant detected."
						R.fields["traits"] = "No known traits."
						data_core.medical += R
						src.active_medical = R

						src.log_string += "<br>New medical record created."
						src.print_active_record()
						return

					else
						src.print_text("Please enter new value.")
						src.menu = MENU_FIELD_INPUT
						return

			if (MENU_FIELD_INPUT)
				if (!src.active_general)
					src.print_text("<b>Error:</b> Record invalid.")
					src.menu = MENU_INDEX
					return

				var/inputText = strip_html(text)
				switch (field_input)
					if (FIELDNUM_NAME)
						if (ckey(inputText))
							src.active_general.fields["name"] = copytext(inputText, 1, FULLNAME_MAX)
						else
							return

					if (FIELDNUM_FULLNAME)
						if (ckey(inputText))
							src.active_general.fields["full_name"] = copytext(inputText, 1, FULLNAME_MAX)
						else
							return

					if (FIELDNUM_SEX)
						switch (round( max( text2num(command), 0) ))
							if (1)
								src.active_general.fields["sex"] = "Female"
							if (2)
								src.active_general.fields["sex"] = "Male"
							if (3)
								src.active_general.fields["sex"] = "Other"
							if (0)
								src.menu = MENU_IN_RECORD
								return
							else
								return

					if (FIELDNUM_AGE)
						var/newAge = round( min( text2num(command), 99) )
						if (newAge < 1)
							src.print_text("Invalid age value. Please re-enter.")
							return

						src.active_general.fields["age"] = newAge
						return

					if (FIELDNUM_PSTAT)
						if (ckey(inputText))
							src.active_general.fields["p_stat"] = copytext(inputText, 1, 33)
						else
							return

					if (FIELDNUM_MSTAT)
						if (ckey(inputText))
							src.active_general.fields["m_stat"] = copytext(inputText, 1, 33)
						else
							return

					if (FIELDNUM_PRINT)
						if (ckey(inputText))
							src.active_general.fields["fingerprint"] = copytext(inputText, 1, 33)
						else
							return

					if (FIELDNUM_DNA)
						if (ckey(inputText))
							src.active_general.fields["dna"] = copytext(inputText, 1, 40)
						else
							return


					if (FIELDNUM_BLOODTYPE)
						if (!src.active_medical)
							src.print_text("No medical record loaded!")
							src.menu = MENU_IN_RECORD
							return

						switch (round( max( text2num(command), 0) ))
							if (1)
								src.active_medical.fields["bioHolder.bloodType"] = "A+"
							if (2)
								src.active_medical.fields["bioHolder.bloodType"] = "A-"
							if (3)
								src.active_medical.fields["bioHolder.bloodType"] = "B+"
							if (4)
								src.active_medical.fields["bioHolder.bloodType"] = "B-"
							if (5)
								src.active_medical.fields["bioHolder.bloodType"] = "AB+"
							if (6)
								src.active_medical.fields["bioHolder.bloodType"] = "AB-"
							if (7)
								src.active_medical.fields["bioHolder.bloodType"] = "O+"
							if (8)
								src.active_medical.fields["bioHolder.bloodType"] = "O-"
							if (9)
								src.active_medical.fields["bioHolder.bloodType"] = "Zesty Ranch"
							if (0)
								src.menu = MENU_IN_RECORD
								return
							else
								return

					if (FIELDNUM_MINDIS)
						if (!src.active_medical)
							src.print_text("No medical record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_medical.fields["mi_dis"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_MINDET)
						if (!src.active_medical)
							src.print_text("No medical record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_medical.fields["mi_dis_d"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_MAJDIS)
						if (!src.active_medical)
							src.print_text("No medical record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_medical.fields["ma_dis"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_MAJDET)
						if (!src.active_medical)
							src.print_text("No medical record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_medical.fields["ma_dis_d"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_ALLERGY)
						if (!src.active_medical)
							src.print_text("No medical record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_medical.fields["alg"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_ALGDET)
						if (!src.active_medical)
							src.print_text("No medical record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_medical.fields["alg_d"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_DISEASE)
						if (!src.active_medical)
							src.print_text("No medical record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_medical.fields["cdi"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_DISDET)
						if (!src.active_medical)
							src.print_text("No medical record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_medical.fields["cdi_d"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_TRAITS)
						if (!src.active_medical)
							src.print_text("No medical record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_medical.fields["traits"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_NOTES)
						if (!src.active_medical)
							src.print_text("No medical record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_medical.fields["notes"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_DELETE)
						switch (ckey(inputText))
							if ("y")
								if (src.active_medical)
									src.log_string += "<br>M-Record [src.active_medical.fields["id"]] deleted."
									data_core.medical -= src.active_medical
									qdel(src.active_medical)
									src.print_active_record()
									src.menu = MENU_IN_RECORD

								else if (src.active_general)
									data_core.general -= src.active_general

									src.log_string += "<br>Record [src.active_general.fields["id"]] deleted."
									qdel(src.active_general)
									src.menu = MENU_INDEX
									src.print_index()

							if ("n")
								src.menu = MENU_IN_RECORD
								src.print_text("Record preserved.")

						return

				src.print_text("Field updated.")
				src.menu = MENU_IN_RECORD
				return

			if (MENU_SEARCH_INPUT)
				var/searchText = ckey(strip_html(text))
				if (!searchText)
					return

				var/datum/data/record/result = null
				for(var/datum/data/record/R in data_core.general)
					if((ckey(R.fields["name"]) == searchText) || (ckey(R.fields["dna"]) == searchText) || (ckey(R.fields["id"]) == searchText) || (ckey(R.fields["fingerprint"]) == searchText))
						result = R
						break

				if(!result)
					src.print_text("No results found.")
					src.menu = MENU_MAIN
					return

				src.active_general = result
				src.active_medical = null //Time to find the accompanying medical record, if it even exists.
				for (var/datum/data/record/E in data_core.medical)
					if ((E.fields["name"] == src.active_general.fields["name"] || E.fields["id"] == src.active_general.fields["id"]))
						src.active_medical = E
						break

				src.menu = MENU_IN_RECORD
				src.print_active_record()
				return

			if (MENU_VIRUS_INDEX)
				var/entrydat = null
				switch (copytext(text, 1,2))
					if ("0")
						src.menu = MENU_MAIN
						src.master.temp = null
						src.print_text(virusmenu_text())
						return
					if ("1")
						entrydat = {"<b>Name:</b> GBS
						<br><b>Number of stages:</b> 5
						<br><b>Spread:</b> Airborne Transmission
						<br><b>Possible Cure:</b> Spaceacillin
						<br><b>Affected Species:</b> Human
						<br>
						<br><b>Notes:</b> If left untreated death will occur.
						<br>
						<br><b>Severity:</b> Major"}
					if ("2")
						entrydat = {"<b>Name:</b> Common Cold
						<br><b>Number of stages:</b> 3
						<br><b>Spread:</b> Airborne Transmission
						<br><b>Possible Cure:</b> Rest
						<br><b>Affected Species:</b> Human
						<br>
						<br><b>Notes:</b> If left untreated the subject will contract the flu.
						<br>
						<br><b>Severity:</b> Minor"}
					if ("3")
						entrydat = {"<b>Name:</b> The Flu
						<br><b>Number of stages:</b> 3
						<br><b>Spread:</b> Airborne Transmission
						<br><b>Possible Cure:</b> Rest
						<br><b>Affected Species:</b> Human
						<br>
						<br><b>Notes:</b> If left untreated the subject will feel quite unwell.
						<br>
						<br><b>Severity:</b> Medium"}

					if ("4")
						entrydat = {"<b>Name:</b> Jungle Fever
						<br><b>Number of stages:</b> 1
						<br><b>Spread:</b> Airborne Transmission
						<br><b>Possible Cure:</b> None
						<br><b>Affected Species:</b> Monkey
						<br>
						<br><b>Notes:</b> Monkies with this disease will bite humans, causing humans to spontaneously to mutate into a monkey.
						<br>
						<br><b>Severity:</b> Medium"}

					if ("5")
						entrydat = {"<b>Name:</b> Clowning Around
						<br><b>Number of stages:</b> 4
						<br><b>Spread:</b> Contact Transmission
						<br><b>Possible Cure:</b> Spaceacillin
						<br><b>Affected Species:</b> Human
						<br>
						<br><b>Notes:</b> Subjects are affected by rampant honking and a fondness for shenanigans. They may also spontaneously phase through closed airlocks.
						<br>
						<br><b>Severity:</b> Laughable"}

					if ("6")
						entrydat = {"<b>Name:</b> Space Rhinovirus
						<br><b>Number of stages:</b> 4
						<br><b>Spread:</b> Airborne Transmission
						<br><b>Possible Cure:</b> Spaceacillin
						<br><b>Affected Species:</b> Human
						<br>
						<br><b>Notes:</b> This disease transplants the genetic code of the intial vector into new hosts.
						<br>
						<br><b>Severity:</b> Medium"}

					if ("7")
						entrydat = {"<b>Name:</b> Robot Transformation
						<br><b>Number of stages:</b> 5
						<br><b>Spread:</b> Infected food
						<br><b>Possible Cure:</b> Electric shock.
						<br><b>Affected Species:</b> Human
						<br>
						<br><b>Notes:</b> This disease, actually acute nanomachine infection, converts the victim into a cyborg.
						<br>
						<br><b>Severity:</b> Major"}

					if ("8")
						entrydat = {"<b>Name:</b> Teleportitis
						<br><b>Number of stages:</b> 1
						<br><b>Spread:</b> Unknown
						<br><b>Possible Cure:</b> Unknown
						<br><b>Affected Species:</b> Human
						<br>
						<br><b>Notes:</b> Means of transmission are currently unknown,
						may be related to contents of teleporter emissions.  Causes violent shifts
						in physical position of subject.  Keep patients away from active engines.<br>
						<br><b>Severity:</b> Unknown"}

					if ("9")
						entrydat = {"<b>Name:</b> Berserker
						<br><b>Number of stages:</b> 2
						<br><b>Spread:</b> Contact Transmission
						<br><b>Possible Cure:</b> Spaceacillin
						<br><b>Affected Species:</b> Human
						<br>
						<br><b>Notes:</b> This disease causes fits of extreme rage and violence in the victim.
						Due to its ability to spread, it is considered extremely dangerous.
						Do not attempt to reason with infected persons.<br>
						<br><b>Severity:</b> Major"}

					else

						return

				src.master.temp = null
				src.print_text("[entrydat]<br>Enter 0 to return.")
				src.menu = MENU_VIRUS_RECORD

			if (MENU_VIRUS_RECORD)
				if (copytext(text, 1,2) == "0")
					src.master.temp = null
					src.menu = MENU_MAIN
					src.print_text(mainmenu_text())
				return

		return


	proc
		mainmenu_text()
			var/dat = {"<center>M E D T R A K</center><br>
			Welcome to Medtrak 5.1<br>
			<b>Commands:</b>
			<br>(1) View medical records.
			<br>(2) Search for a record.
			<br>(3) View viral database.
			<br>(0) Quit."}

			return dat

		virusmenu_text()
			var/dat = {"<b>Known Diseases:</b><br>
					(01) GBS<br>
					(02) Common Cold<br>
					(03) Flu<br>
					(04) Jungle Fever<br>
					(05) Clowning Around<br>
					(06) Space Rhinovirus<br>
					(07) Robot Transformation<br>
					(08) Teleportitis<br>
					(09) Berserker<br>
					Enter virus number or 0 to return."}

			return dat

		print_active_record()
			if (!src.active_general)
				src.print_text("<b>Error:</b> General record data corrupt.")
				return 0
			src.master.temp = null

			var/view_string = {"
			\[01]Name: [src.active_general.fields["name"]] ID: [src.active_general.fields["id"]]
			<br>\[02]Full Name: [src.active_general.fields["full_name"]]
			<br>\[03]<b>Sex:</b> [src.active_general.fields["sex"]]
			<br>\[04]<b>Age:</b> [src.active_general.fields["age"]]
			<br>\[__]<b>Rank:</b> [src.active_general.fields["rank"]]
			<br>\[05]<b>Fingerprint:</b> [src.active_general.fields["fingerprint"]]
			<br>\[06]<b>DNA:</b> [src.active_general.fields["dna"]]
			<br>\[__]Photo: [istype(src.active_general.fields["file_photo"], /datum/computer/file/image) ? "On File" : "None"]
			<br>\[07]Physical Status: [src.active_general.fields["p_stat"]]
			<br>\[08]Mental Status: [src.active_general.fields["m_stat"]]"}

			if ((istype(src.active_medical, /datum/data/record) && data_core.medical.Find(src.active_medical)))
				view_string += {"<br><center><b>Medical Data:</b></center>
				<br>\[__]Current Health: [src.active_medical.fields["h_imp"]]
				<br>\[09]Blood Type: [src.active_medical.fields["bioHolder.bloodType"]]
				<br>\[10]Minor Disabilities: [src.active_medical.fields["mi_dis"]]
				<br>\[11]Details: [src.active_medical.fields["mi_dis_d"]]
				<br>\[12]<br>Major Disabilities: [src.active_medical.fields["ma_dis"]]
				<br>\[13]Details: [src.active_medical.fields["ma_dis_d"]]
				<br>\[14]<br>Allergies: [src.active_medical.fields["alg"]]
				<br>\[15]Details: [src.active_medical.fields["alg_d"]]
				<br>\[16]<br>Current Diseases: [src.active_medical.fields["cdi"]] (per disease info placed in log/comment section)
				<br>\[17]Details: [src.active_medical.fields["cdi_d"]]
				<br>\[18]Traits: [src.active_medical.fields["traits"]]
				<br>\[19]Important Notes:
				<br>&emsp;[src.active_medical.fields["notes"]]"}
			else
				view_string += "<br><br><b>Medical Record Lost!</b>"
				view_string += "<br>\[99] Create New Medical Record.<br>"

			view_string += "<br>Enter field number to edit a field<br>(R) Redraw (D) Delete (P) Print (0) Return to index."

			src.print_text("<b>Record Data:</b><br>[view_string]")
			return 1

		print_index()
			src.master.temp = null
			var/dat = ""
			if(!src.record_list || !length(src.record_list))
				src.print_text("<b>Error:</b> No records found in database.")

			else
				dat = "Please select a record:"
				var/leadingZeroCount = length("[src.record_list.len]")
				for(var/x = 1, x <= src.record_list.len, x++)
					var/datum/data/record/R = src.record_list[x]
					if(!R || !istype(R))
						dat += "<br><b>\[[add_zero("[x]",leadingZeroCount)]]</b><font color=red>ERR: REDACTED</font>"
						continue

					dat += "<br><b>\[[add_zero("[x]",leadingZeroCount)]]</b>[R.fields["id"]]: [R.fields["name"]]"

			dat += "<br><br>Enter record number, or 0 to return."

			src.print_text(dat)
			return 1

		find_access_file() //Look for the whimsical account_data file
			var/datum/computer/folder/accdir = src.holder.root
			if(src.master.host_program) //Check where the OS is, preferably.
				accdir = src.master.host_program.holder.root

			var/datum/computer/file/user_data/target = parse_file_directory(setup_acc_filepath, accdir)
			if(target && istype(target))
				src.account = target
				return 1

			return 0

#undef MENU_MAIN
#undef MENU_INDEX
#undef MENU_IN_RECORD
#undef MENU_FIELD_INPUT
#undef MENU_SEARCH_INPUT
#undef MENU_VIRUS_INDEX
#undef MENU_VIRUS_RECORD

#undef FIELDNUM_NAME
#undef FIELDNUM_FULLNAME
#undef FIELDNUM_SEX
#undef FIELDNUM_AGE
#undef FIELDNUM_PRINT
#undef FIELDNUM_DNA
#undef FIELDNUM_PSTAT
#undef FIELDNUM_MSTAT
#undef FIELDNUM_BLOODTYPE
#undef FIELDNUM_MINDIS
#undef FIELDNUM_MINDET
#undef FIELDNUM_MAJDIS
#undef FIELDNUM_MAJDET
#undef FIELDNUM_ALLERGY
#undef FIELDNUM_ALGDET
#undef FIELDNUM_DISEASE
#undef FIELDNUM_DISDET
#undef FIELDNUM_TRAITS
#undef FIELDNUM_NOTES

#undef FIELDNUM_DELETE
#undef FIELDNUM_NEWREC
