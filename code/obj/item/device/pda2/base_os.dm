#define RECENT_CALL_COOLDOWN (1 MINUTE)
#define MODE_MAINMENU 0
#define MODE_NOTE 1
#define MODE_MESSAGE 2
#define MODE_FILEBROWSER 3
#define MODE_ATMOS 4
#define MODE_GROUPS 5
#define MODE_ADDRESSBOOK 6
#define MODE_MODULECONFIG 999

/datum/computer/file/pda_program/os
	proc
		receive_os_command(list/command_list)
			if((!src.holder) || (!src.master) || (!command_list) || !(command_list["command"]))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(!(holder in src.master.contents))
				if(master.active_program == src)
					master.set_active_program(null)
				return 1

			return 0

		pda_message()

//Main os program: Provides old pda interface and four programs including file browser, notes, messenger, and atmos scan
	main_os
		name = "ThinkOS 7"
		size = 8
		var/mode = 0
		//Note vars
		var/note = "Congratulations, your station has chosen the Thinktronic 5150 Personal Data Assistant!"
		var/note_mode = 0 //0 For note editor, 1 for note browser
		var/datum/computer/file/text/note_file = null //If set, save to this file.
		var/datum/computer/folder/note_folder = null //Which folder are we looking in?
		//Messenger vars
		var/expand_departments_list = 1
		var/list/detected_pdas = list()
		var/message_on = 1
		var/message_silent = 0 //To beep or not to beep, that is the question
		var/message_mode = 0 //0 for pda list, 1 for messages
		var/message_tone = "beep" //Custom ring message
		var/message_note = null //Current messages in memory (Store as separate file only later??)
		var/message_last = 0 //world.time of last send for both messages and file sending.
		var/last_filereq_id = null //net id of last dude to request a file transfer
		var/target_filereq_id = null //Who are we trying to send a file to?
		//File browser vars
		var/datum/computer/folder/browse_folder = null
		var/datum/computer/file/clipboard = null //Current file to copy
		/// Files we're hosting. Assoc'd list, (passkey = filedatum)
		var/list/hosted_files = list()
		/// List of messengers we've heard from. Assoc'd list, (address_1 = sendername)
		var/list/all_callers = list()
		/// List of recent callers, so you get the long sound for the first message, and a shorter one for that same person after that
		var/list/recent_callers = list()
		/// List of messengers we don't want to hear from anymore -- set by name, not address_1!
		var/list/blocked_numbers = list()
		/// List of mailgroups we don't want to hear from anymore
		var/list/muted_mailgroups = list()
		/// Whether there's a PDA-report packet-reply-triggered UI update queued
		var/report_refresh_queued = FALSE

		mess_off //Same as regular but with messaging off
			message_on = 0

		disposing()
			if (detected_pdas)
				detected_pdas.len = 0
				detected_pdas = null

			note_folder = null
			note_file = null
			browse_folder = null
			clipboard = null

			..()

		receive_os_command(list/command_list)
			if(..())
				return

			//boutput(world, "[command_list["command"]]")
			return

		return_text()
			if(..())
				return

			. = src.return_text_header()

			switch(src.mode)
				if(MODE_MAINMENU)
					. += {"<h2>PERSONAL DATA ASSISTANT</h2>
					Owner: [src.master.owner]<br>
					Time: [time2text(world.timeofday, "DDD MMM DD, hh:mm:ss")]<br>

					<h4>General Functions</h4>
					<ul>
					<li><a href='byond://?src=\ref[src];mode=[MODE_NOTE]'>Notekeeper</a></li>
					<li><a href='byond://?src=\ref[src];mode=[MODE_MESSAGE]'>Messenger</a></li>
					<li><a href='byond://?src=\ref[src];mode=[MODE_FILEBROWSER]'>File Browser</a></li>
					</ul>

					<h4>Utilities</h4>
					<ul>
					<li><a href='byond://?src=\ref[src];change_backlight_color=1'>Change Backlight Color</a></li>
					<li><a href='byond://?src=\ref[src];mode=[MODE_ATMOS]'>Atmospheric Scan</a></li>
					<li>Scanner: [src.master.scan_program ? "<a href='byond://?src=\ref[src];scanner=1'>[src.master.scan_program.name]</a>" : "None loaded"]</li>"}
#ifdef UNDERWATER_MAP
					. += "<li><a href='byond://?src=\ref[src];trenchmap=1'>Trench Map</a></li>"
#else
					. += "<li><a href='byond://?src=\ref[src];trenchmap=1'>Mining Map</a></li>"
#endif

					if(src.master.module)
						if(src.master.module.setup_allow_os_config)
							. += "<li><a href='byond://?src=\ref[src];mode=[MODE_MODULECONFIG]'>Module Config</a></li>"

						if(src.master.module.setup_use_menu_badge)
							. += "<li>[src.master.module.return_menu_badge()]</li>"

				if(MODE_NOTE)
					//Note Program.  Can save/load note files.
					. += "<h4>Notekeeper V2.5</h4>"

					if(!src.note_mode)
						if ((!isnull(src.master.uplink)) && (src.master.uplink.active))
							. += "<a href='byond://?src=\ref[src];note_func=lock'>Lock</a><br>"
						else
							. += {"<a href='byond://?src=\ref[src];input=note'>Edit</a>
							 | <a href='byond://?src=\ref[src];note_func=new'>New File</a>
							 | <a href='byond://?src=\ref[src];note_func=save'>Save</a>
							 | <a href='byond://?src=\ref[src];note_func=switchmenu'>Load</a><br>"}

						. += src.note
					else
						. += " <a href='byond://?src=\ref[src];note_func=switchmenu'>Back</a>"
						if((!src.note_folder) || !(src.note_folder.holder in src.master))
							src.note_folder = src.holding_folder

						. += {" | \[[src.note_folder.holder.file_amount - src.note_folder.holder.file_used]\] Free
						 \[<a href='byond://?src=\ref[src];note_func=drive'>[src.note_folder.holder == src.master.hd ? "MAIN" : "CART"]</a>\]<br>
						<table cellspacing=5>"}

						for(var/datum/computer/file/text/T in src.note_folder.contents)
							. += {"<tr><td><a href='byond://?src=\ref[src];target=\ref[T];note_func=load'>[T.name]</a></td>
							<td>[T.extension]</td>
							<td>Length: [T.data ? (length(T.data)) : "0"]</td></tr>"}

						. += "</table>"

				if(MODE_MESSAGE)
					//Messenger.  Uses Radio.  Is a messenger.
					src.master.update_overlay("idle") //Remove existing alerts
					. += "<h4>SpaceMessenger V4.0.5</h4>"

					if (!src.message_mode)

						. += {"<a href='byond://?src=\ref[src];message_func=ringer'>Ringer: [src.message_silent == 1 ? "Off" : "On"]</a> |
						<a href='byond://?src=\ref[src];message_func=on'>Send / Receive: [src.message_on == 1 ? "On" : "Off"]</a> |
						<a href='byond://?src=\ref[src];input=tone'>Set Ring Message</a><br>
						<a href='byond://?src=\ref[src];message_mode=1'>Messages</a> |
						<a href='byond://?src=\ref[src];mode=[MODE_GROUPS]'>Groups</a> |
						<a href='byond://?src=\ref[src];mode=[MODE_ADDRESSBOOK]'>Address Book</a><br>

						<font size=2><a href='byond://?src=\ref[src];message_func=scan'>Scan</a></font><br>
						<b>Detected PDAs</b><br>"}

						if (!src.message_on)
							. += "Please turn on Send/Receive to use the scan function."
						else
							. += "<ul>"
							var/count = 0
							if(expand_departments_list)
								. += "<a href='byond://?src=\ref[src];toggle_departments_list=1;refresh=1'>*Collapse DEPT list*</a>"
								for (var/department_id in page_departments)
									. += "<li><a href='byond://?src=\ref[src];input=message;target=[page_departments[department_id]];department=1'>DEPT-[department_id]</a></li>"
							else
								. += "<a href='byond://?src=\ref[src];toggle_departments_list=1;refresh=1'>*Expand DEPT list*</a>"

							var/pdaOwnerNames = list()
							for (var/P_id in src.detected_pdas)
								var/P_name = src.detected_pdas[P_id]
								if (!P_name)
									src.detected_pdas -= P_id
									continue
								else if (P_id == src.master.net_id) //I guess this can happen if somebody copies the system file.
									src.detected_pdas -= P_id
									continue
								pdaOwnerNames += P_name
								pdaOwnerNames[P_name] = P_id
							sortList(pdaOwnerNames, /proc/cmp_text_asc)
							for (var/P_name in pdaOwnerNames)
								var/P_id = pdaOwnerNames[P_name]

								. += {"<li><a href='byond://?src=\ref[src];input=message;target=[P_id]'>PDA-[P_name]</a>
								 (<a href='byond://?src=\ref[src];input=send_file;target=[P_id]'>*Send File*</a>)


								</li>"}
								count++
							. += "</ul>"

							if (count == 0 && !length(page_departments))
								. += "None detected.<br>"

					else if (src.message_mode == 1)
						. += {"<a href='byond://?src=\ref[src];message_func=clear'>Clear</a> |
						<a href='byond://?src=\ref[src];message_mode=0'>Back</a><br>

						<h4>Messages</h4>"}

						. += src.message_note
						. += "<br>"

				if(MODE_FILEBROWSER)
					//File Browser.
					//To-do(?): Setting "favorite" programs to access straight from main menu
					//Not sure how needed it is, not like they have to go through 500 subfolders or whatever
					if((!src.browse_folder) || !(src.browse_folder.holder in src.master))
						src.browse_folder = src.holding_folder

					. += {" | <a href='byond://?src=\ref[src];target=\ref[src.browse_folder];browse_func=paste'>Paste</a><br>

					<b>Contents of [browse_folder] | Drive ID:\[[src.browse_folder.holder.title]]</b><br>
					<b>Used: \[[src.browse_folder.holder.file_used]/[src.browse_folder.holder.file_amount]\]</b><hr>

					<table cellspacing=5>"}
					for(var/datum/computer/file/F in browse_folder.contents)
						var/copyButton = "<a href='byond://?src=\ref[src];target=\ref[F];browse_func=copy'>Copy</a>"
						if(F.dont_copy)
							copyButton = "<strike>Copy</strike>"
						if(F == src)
							. += "<tr><td>System</td><td>Size: [src.size]</td><td>SYSTEM</td></tr>"
							continue
						. += {"<tr><td><a href='byond://?src=\ref[src];target=\ref[F];browse_func=open'>[F.name]</a></td>
						<td>Size: [F.size]</td>

						<td>[F.extension]</td>

						<td><a href='byond://?src=\ref[src];target=\ref[F];browse_func=delete'>Del</a></td>
						<td><a href='byond://?src=\ref[src];target=\ref[F];input=rename'>Rename</a></td>

						<td>[copyButton]</td>

						</tr>"}

					. += "</table>"
					var/datum/computer/folder/other_drive_folder
					for (var/obj/item/disk/data/D in master)
						if (D != src.browse_folder.holder && D.root)
							other_drive_folder = D.root
							break

					if (other_drive_folder)
						. += {"<hr><b>Contents of [other_drive_folder] | Drive ID:\[[other_drive_folder.holder.title]]</b><br>
						<b>Used: \[[other_drive_folder.holder.file_used]/[other_drive_folder.holder.file_amount]\]</b> | <a href='byond://?src=\ref[src];target=\ref[other_drive_folder];browse_func=paste'>Paste</a><hr>

						<table cellspacing=5>"}
						for(var/datum/computer/file/F in other_drive_folder.contents)
							var/copyButton = "<a href='byond://?src=\ref[src];target=\ref[F];browse_func=copy'>Copy</a>"
							if(F.dont_copy)
								copyButton = "<strike>Copy</strike>"
							if(F == src)
								. += "<tr><td>System</td><td>Size: [src.size]</td><td>SYSTEM</td></tr>"
								continue
							. += {"<tr><td><a href='byond://?src=\ref[src];target=\ref[F];browse_func=open'>[F.name]</a></td>
							<td>Size: [F.size]</td>

							<td>[F.extension]</td>

							<td><a href='byond://?src=\ref[src];target=\ref[F];browse_func=delete'>Del</a></td>
							<td><a href='byond://?src=\ref[src];target=\ref[F];input=rename'>Rename</a></td>

							<td>[copyButton]</td>

							</tr>"}
						. += "</table>"

				if(MODE_ATMOS)
					//Atmos Scanner
					. += "<h4>Atmospheric Readings</h4>"

					var/turf/T = get_turf(src.master)
					if (isnull(T))
						. += "Unable to obtain a reading.<br>"
					else
						. += scan_atmospheric(T, 1, visible = 1) // Replaced with global proc (Convair880).

					. += "<br>"

				if(MODE_GROUPS) // Groups and alerts and their ringtones
					if(length(src.master.mailgroups))
						. += "<h4>SpaceMessenger V4.0.5</h4>"
						. += "<a href='byond://?src=\ref[src];mode=[MODE_MESSAGE]'>Back</a><br>"
						. += "<h4>Mailgroups</h4><br>"
						. += "<a href='byond://?src=\ref[src];input=mailgroup'>Join/create group</a>"
						. += "<table cellspacing=5>"

						for(var/mailgrp in src.master.mailgroups)
							var/datum/ringtone/rt = null
							var/rtButton = "Default"
							var/muteButton = "<a href='byond://?src=\ref[src];manageBlock=["add"];type=["mailgroup"];entry=[mailgrp]'>Block</a>"
							var/leaveButton = "<a href='byond://?src=\ref[src];message_func=leave_group;groupname=[mailgrp]'>Leave</a>"
							var/sendButton = "<a href='byond://?src=\ref[src];input=send_file;group=[mailgrp]'>Send File</a>"
							if(!src.master.fileshare_program)
								sendButton = ""
							else if(!src.clipboard || src.clipboard?.dont_copy)
								sendButton = "<strike>Send File</strike>"
							var/msgButton = "<a href='byond://?src=\ref[src];input=message;target=[mailgrp];department=1'>Mail</a>"
							if((mailgrp in src.master.mailgroup_ringtones) && istype(src.master.mailgroup_ringtones[mailgrp], /datum/ringtone))
								rt = src.master.mailgroup_ringtones[mailgrp]
								rtButton = "<a href='byond://?src=\ref[src];delMGTone=[mailgrp]'>[rt.name]</a>"
							if(mailgrp in src.muted_mailgroups)
								muteButton = "<a href='byond://?src=\ref[src];manageBlock=["remove"];type=["mailgroup"];entry=[mailgrp]'>Unblock</a>"
							if(mailgrp in src.master.reserved_mailgroups)
								leaveButton = ""
							. += "<tr><td>[mailgrp]</td><td>[rtButton]</td><td>[msgButton]</td><td>[sendButton]</td><td>[muteButton]</td><td>[leaveButton]</td></tr>"
						. += "</table>"
						. += "<hr><br>"
						. += "<h4>Alert Settings</h4>"
						. += "<table cellspacing=5>"

						for(var/alert in src.master.alertgroups)
							var/datum/ringtone/rt = null
							var/rtButton = "Default"
							var/muteButton = "<a href='byond://?src=\ref[src];manageBlock=["add"];type=["mailgroup"];entry=[alert]'>Mute</a>"
							if(istype(src.master.alert_ringtones[alert], /datum/ringtone))
								rt = src.master.alert_ringtones[alert]
								rtButton = "<a href='byond://?src=\ref[src];delATone=[alert]'>[rt.name]</a>"
							if(alert in src.muted_mailgroups)
								muteButton = "<a href='byond://?src=\ref[src];manageBlock=["remove"];type=["mailgroup"];entry=[alert]'>Unmute</a>"
							. += "<tr><td>[alert]</td><td>[rtButton]</td><td>[muteButton]</td></tr>"

				if(MODE_ADDRESSBOOK) // Specific names sent to us, also ringtones
					. += "<h4>SpaceMessenger V4.0.5</h4>"
					. += "<a href='byond://?src=\ref[src];mode=[MODE_MESSAGE]'>Back</a><br>"
					. += "<h4>Address Book</h4><br>"
					if(length(src.all_callers) < 1)
						. += "Address book is empty!"
					else
						. += "<table cellspacing=5>"
						for(var/caller in src.all_callers)
							var/muteButton = "<a href='byond://?src=\ref[src];manageBlock=["add"];type=["single"];entry=[src.all_callers[caller]]'>Block</a>"
							var/callButton = "<a href='byond://?src=\ref[src];input=message;target=[caller]'>Msg</a>"
							var/sendButton = "<a href='byond://?src=\ref[src];input=send_file;target=[caller]'>Send File</a>"
							if(!src.master.fileshare_program)
								sendButton = ""
							else if(!src.clipboard || src.clipboard?.dont_copy)
								sendButton = "<strike>Send File</strike>"
							var/delButton = "<a href='byond://?src=\ref[src];delAddress=[caller]'>Del</a>"
							if(src.all_callers[caller] in src.blocked_numbers)
								muteButton = "<a href='byond://?src=\ref[src];manageBlock=["remove"];type=["single"];entry=[src.all_callers[caller]]'>Unblock</a>"
							. += "<tr><td>[src.all_callers[caller]]</td><td>[callButton]</td><td>[muteButton]</td><td>[sendButton]</td><td>[delButton]</td></tr>"
						. += "</table>"
					. += "<hr>"
					. += "<h4>Primary Ringtone</h4><br>"
					. += "<table cellspacing=5>"
					. += "<tr><td>[src.master.r_tone ? "[src.master.r_tone.name]</td><td><a href='byond://?src=\ref[src];delTone=1'>Reset</a></td></tr>" : "</td><td>-ERR-</td></tr>"]"
					. += "</table>"


				if(MODE_MODULECONFIG) // Nothing seems to use this, but just in case
					. += "<h4>Module Configuration</h4><br>"
					. += "ERROR: No error."

		Topic(href, href_list)
			if(..())
				return

			if(href_list["mode"])
				var/newmode = text2num_safe(href_list["mode"])
				src.mode = max(newmode, 0)

			if(href_list["delTone"])
				qdel(src.master.r_tone)
				src.master.r_tone = new/datum/ringtone(src.master)

			if(href_list["delATone"])
				qdel(src.master.alert_ringtones[href_list["delATone"]])
				src.master.alert_ringtones[href_list["delATone"]] = null

			if(href_list["delMGTone"])
				qdel(src.master.mailgroup_ringtones[href_list["delMGTone"]])
				src.master.mailgroup_ringtones[href_list["delMGTone"]] = null

			else if(href_list["manageBlock"])
				switch(href_list["type"])
					if("mailgroup")
						if(href_list["manageBlock"] == "add")
							src.muted_mailgroups += href_list["entry"]
						if(href_list["manageBlock"] == "remove")
							src.muted_mailgroups -= href_list["entry"]
					if("single")
						if(href_list["manageBlock"] == "add")
							src.blocked_numbers += href_list["entry"]
						if(href_list["manageBlock"] == "remove")
							src.blocked_numbers -= href_list["entry"]

			else if(href_list["delAddress"])
				src.all_callers -= href_list["delAddress"]

			else if(href_list["scanner"])
				if(src.master.scan_program)
					src.master.set_scan_program(null)

			else if(href_list["trenchmap"])
				if (usr.client && hotspot_controller)
					hotspot_controller.show_map(usr.client)

			else if(href_list["change_backlight_color"])
				var/new_color = input(usr, "Choose a color", "PDA", src.master.bg_color) as color | null
				if (new_color)
					var/list/color_vals = hex_to_rgb_list(new_color);
					src.master.update_colors(new_color, rgb(color_vals[1] * 0.8, color_vals[2] * 0.8, color_vals[3] * 0.8))

			else if(href_list["toggle_departments_list"])
				expand_departments_list = !expand_departments_list

			else if(href_list["input"])
				switch(href_list["input"])
					if("tone")
						var/prompt = "Please enter new ring message."
						var/default = src.message_tone
						if (usr.ckey == src.master?.uplink?.owner_ckey)
							default = src.master.uplink.lock_code
							prompt += " Your uplink code has been pre-entered for your convenience."

						var/t = tgui_input_text(usr, prompt, src.name, default)
						if (!t)
							return

						if (!src.master?.is_user_in_interact_range(usr))
							return

						if(!(src.holder in src.master))
							return

						if (t == src.master?.uplink?.lock_code)
							boutput(usr, "The PDA softly beeps.")
							src.master.uplink.unlock()
						else
							t = copytext(sanitize(strip_html(t)), 1, 20)
							src.message_tone = t
							logTheThing(LOG_PDAMSG, usr, "sets ring message of <b>[src.master]</b> to: [src.message_tone]")

					if("note")
						var/inputtext = html_decode(replacetext(src.note, "<br>", "\n"))
						inputtext = html_decode(replacetext(src.note, "<b>", "\[b\]"))
						inputtext = html_decode(replacetext(src.note, "</b>", "\[/b\]"))
						inputtext = html_decode(replacetext(src.note, "<u>", "\[u\]"))
						inputtext = html_decode(replacetext(src.note, "</u>", "\[/u\]"))
						inputtext = html_decode(replacetext(src.note, "<sup>", "\[sup\]"))
						inputtext = html_decode(replacetext(src.note, "</sup>", "\[/sup\]"))
						inputtext = html_decode(replacetext(src.note, "<h1>", "\[h1\]"))
						inputtext = html_decode(replacetext(src.note, "</h1>", "\[/h1\]"))
						inputtext = html_decode(replacetext(src.note, "<h2>", "\[h2\]"))
						inputtext = html_decode(replacetext(src.note, "</h2>", "\[/h2\]"))
						inputtext = html_decode(replacetext(src.note, "<h3>", "\[h3\]"))
						inputtext = html_decode(replacetext(src.note, "</h3>", "\[/h3\]"))
						inputtext = html_decode(replacetext(src.note, "<h4>", "\[h4]"))
						inputtext = html_decode(replacetext(src.note, "</h4>", "\[/h4\]"))
						inputtext = html_decode(replacetext(src.note, "<blockquote>", "\[blockquote\]"))
						inputtext = html_decode(replacetext(src.note, "</blockquote>", "\[/blockquote\]"))
						inputtext = html_decode(replacetext(src.note, "<li>", "\[li\]"))
						inputtext = html_decode(replacetext(src.note, "</li>", "\[/li\]"))
						inputtext = html_decode(replacetext(src.note, "<hr>", "\[hr\]"))
						inputtext = html_decode(replacetext(src.note, "</hr>", "\[/hr\]"))
						inputtext = html_decode(replacetext(src.note, "<i>", "\[i\]"))
						inputtext = html_decode(replacetext(src.note, "</i>", "\[/i\]"))
						inputtext = html_decode(replacetext(src.note, "<br>", "\[br\]"))
						var/t = input(usr, "Please enter note", src.name, inputtext) as message
						if (!t)
							return

						if (!src.master?.is_user_in_interact_range(usr))
							return

						if(!(src.holder in src.master))
							return
						t = replacetext(t, "\n", "|1|")
						t = replacetext(t, "\[b\]", "|2|")
						t = replacetext(t, "\[/b\]", "|3|")
						t = replacetext(t, "\[u\]", "|4|")
						t = replacetext(t, "\[/u\]", "|5|")
						t = replacetext(t, "\[i\]", "|6|")
						t = replacetext(t, "\[sup\]", "|7|")
						t = replacetext(t, "\[/sup\]", "|8|")
						t = replacetext(t, "\[h1\]", "|9|")
						t = replacetext(t, "\[/h1\]", "|10|")
						t = replacetext(t, "\[h2\]", "|11|")
						t = replacetext(t, "\[/h2\]", "|12|")
						t = replacetext(t, "\[h3\]", "|13|")
						t = replacetext(t, "\[/h3\]", "|14|")
						t = replacetext(t, "\[h4\]", "|15|")
						t = replacetext(t, "\[/h4\]", "|16|")
						t = replacetext(t, "\[bq\]", "|17|")
						t = replacetext(t, "\[/bq\]", "|18|")
						t = replacetext(t, "\[li\]", "|19|")
						t = replacetext(t, "\[/li\]", "|20|")
						t = replacetext(t, "\[hr\]", "|21|")
						t = replacetext(t, "\[/hr\]", "|22|")
						t = replacetext(t, "\[/i\]", "|23|")
						t = replacetext(t, "\[br\]", "|24|")
						t = copytext(adminscrub(t), 1, MAX_MESSAGE_LEN)
						t = replacetext(t, "|1|", "<br>")
						t = replacetext(t, "|2|", "<b>")
						t = replacetext(t, "|3|", "</b>")
						t = replacetext(t, "|4|", "<u>")
						t = replacetext(t, "|5|", "</u>")
						t = replacetext(t, "|6|", "<i>")
						t = replacetext(t, "|7|", "<sup>")
						t = replacetext(t, "|8|", "</sup>")
						t = replacetext(t, "|9|", "<h1>")
						t = replacetext(t, "|10|", "</h1>")
						t = replacetext(t, "|11|", "<h2>")
						t = replacetext(t, "|12|", "</h2>")
						t = replacetext(t, "|13|", "<h3>")
						t = replacetext(t, "|14|", "</h3>")
						t = replacetext(t, "|15|", "<h4>")
						t = replacetext(t, "|16|", "</h4>")
						t = replacetext(t, "|17|", "<blockquote>")
						t = replacetext(t, "|18|", "</blockquote>")
						t = replacetext(t, "|19|", "<li>")
						t = replacetext(t, "|20|", "</li>")
						t = replacetext(t, "|21|", "<hr>")
						t = replacetext(t, "|22|", "</hr>")
						t = replacetext(t, "|23|", "</i>")
						t = replacetext(t, "|24|", "<br>")
						src.note = t


					if("message")
						if(src.message_last + 20 > world.time) //Message sending delay
							return

						//var/obj/item/device/pda2/P = locate(href_list["target"])
						//if(!P || !istype(P) || !P.net_id)
							//return

						var/is_department_page = href_list["department"] == "1"
						var/target_id = href_list["target"]
						var/target_name = is_department_page ? target_id : detected_pdas[target_id]
						if(!is_department_page && !(target_id in src.detected_pdas))
							return

						var/t
						if(href_list["message_send"])
							t = href_list["message_send"]
						else
							t = tgui_input_text(usr, "Please enter message", target_name)
						if (!t || !isalive(usr))
							return

						src.pda_message(target_id, target_name, t, is_department_page)

						if (href_list["norefresh"])
							src.master.add_fingerprint(usr)
							return

					if("rename")
						var/datum/computer/file/F = locate(href_list["target"])
						if(!F || !istype(F))
							return

						var/t = input(usr, "Please enter new name", src.name, F.name) as text
						t = copytext(sanitize(strip_html(t)), 1, 16)
						if (!t)
							return
						if (!src.master.is_user_in_interact_range(usr))
							return
						if(F.holder.read_only)
							return
						F.name = capitalize(lowertext(t))

					if("send_file") //Give a file send request thing for current copied file.
						if(src.message_last + 20 > world.time) //File sending delay.
							return

						src.SendFile(href_list["target"], href_list["group"])

					if ("mailgroup")
						var/groupname = input(usr, "Enter group name", src.name, null) as text
						if (!groupname || !isalive(usr))
							return
						var/cleanGroupname = replacetext(groupname, ";", "")
						cleanGroupname = replacetext(cleanGroupname, "&", "")
						cleanGroupname = replacetext(cleanGroupname, "=", "")
						cleanGroupname = replacetext(cleanGroupname, "|", "")
						cleanGroupname =  sanitize(adminscrub(strip_html(cleanGroupname)))

						if (cleanGroupname in src.master.reserved_mailgroups)
							// You can't join one of these!
							src.master.display_message("You may not join [cleanGroupname] - this group is private")
							return
						src.master.mailgroups += cleanGroupname



			else if(href_list["message_func"]) //Messenger specific topic junk
				switch(href_list["message_func"])
					if("ringer")
						src.message_silent = !src.message_silent
					if("on")
						src.message_on = !src.message_on
					if("clear")
						src.message_note = null
					if("scan")
						if(src.message_on)
							src.detected_pdas = list()
							src.master.pdasay_autocomplete = list()
							var/datum/signal/signal = get_free_signal()
							signal.data["command"] = "report_pda"
							//signal.data["sender"] = src.master.net_id
							src.post_signal(signal)
					if("accfile")
						if(src.message_on)
							var/datum/signal/newsignal = get_free_signal()
							last_filereq_id = href_list["sender"]
							if(!last_filereq_id) return
							newsignal.data["address_1"] = last_filereq_id
							newsignal.data["command"] = "file_send_acc"
							src.post_signal(newsignal)
					if("leave_group")
						var/groupname = href_list["groupname"]
						if (groupname)
							src.master.mailgroups -= groupname
					if("mute_group")
						var/groupname = href_list["groupname"]
						if (groupname in src.muted_mailgroups)
							src.muted_mailgroups -= groupname
						else
							src.muted_mailgroups += groupname


			else if(href_list["note_func"]) //Note program specific topic junk
				switch(href_list["note_func"])
					if("new")
						src.note_file = null
						src.note = null
					if("save")
						if(isnull(src.note_file) || !(src.note_file.holder in src.master) || src.note_file.holder.read_only)
							var/datum/computer/file/text/F = new /datum/computer/file/text
							if(!src.holding_folder.add_file(F))
								//qdel(F)
								F.dispose()
							else
								src.note_file = F
								F.data = src.note
						else
							src.note_file.data = src.note

					if("load")
						var/datum/computer/file/text/T = locate(href_list["target"])
						if(!T || !istype(T))
							return

						src.note_file = T
						src.note = note_file.data
						src.note_mode = 0

					if("switchmenu")
						src.note_mode = !src.note_mode

					if("drive")
						if(src.note_folder.holder == src.master.hd && src.master.cartridge && (src.master.cartridge.root))
							src.note_folder = src.master.cartridge.root
						else
							src.note_folder = src.holding_folder

					if("lock")
						if(src.master.uplink)
							src.master.uplink.active = 0
							src.note = src.master.uplink.orignote
							usr.removeGpsPath(doText = 0)


			else if(href_list["browse_func"]) //File browser specific topic junk
				var/datum/computer/target = locate(href_list["target"])
				switch(href_list["browse_func"])
					if("drive")
						if(src.browse_folder.holder == src.master.hd && src.master.cartridge && (src.master.cartridge.root))
							src.browse_folder = src.master.cartridge.root
						else
							src.browse_folder = src.holding_folder
					if("open")
						if(!target || !istype(target))
							return
						if(istype(target, /datum/computer/file/pda_program))
							if(istype(target,/datum/computer/file/pda_program/os) && (src.master.host_program))
								return
							else
								src.master.run_program(target)
								src.master.updateSelfDialog()
								return

						else if (istype(target, /datum/computer/file/text))
							if(src.master.uplink?.active)
								return
							else
								src.note = target:data
								src.note_file = target
								src.mode = 1
								src.master.updateSelfDialog()
								return

					if("delete")
						if(!target || !istype(target))
							return
						src.master.delete_file(target)

					if("copy")
						if(istype(target,/datum/computer/file) && (!target.holder || (target.holder in src.master.contents)))
							src.clipboard = target

					if("paste")
						if(istype(target,/datum/computer/folder))
							if(!src.clipboard || !src.clipboard.holder || !(src.clipboard.holder in src.master.contents))
								return

							if(!istype(src.clipboard))
								return

							src.clipboard.copy_file_to_folder(target)


			else if(href_list["message_mode"])
				var/newmode = text2num_safe(href_list["message_mode"])
				src.message_mode = max(newmode, 0)

			src.master.add_fingerprint(usr)
			src.master.updateSelfDialog()
			return

		on_set_host(obj/item/device/pda2/pda)
			pda.AddComponent(
				/datum/component/packet_connected/radio, \
				"pda",\
				pda.frequency, \
				pda.net_id, \
				null, \
				FALSE, \
				null, \
				FALSE \
			)
			RegisterSignal(pda, COMSIG_MOVABLE_RECEIVE_PACKET, .proc/receive_signal)

		on_unset_host(obj/item/device/pda2/pda)
			qdel(get_radio_connection_by_id(pda, "pda"))
			UnregisterSignal(pda, COMSIG_MOVABLE_RECEIVE_PACKET)

		proc/receive_signal(obj/item/device/pda2/pda, datum/signal/signal, transmission_method, range, connection_id)
			if(!istype(holder) || !istype(master) || !src.master.owner)
				return
			if(!(holder in src.master.contents))
				if(master.active_program == src)
					master.set_active_program(null)
				return
			if(connection_id != "pda")
				return

			if(signal.data["command"] == "report_pda")
				if(!message_on || !signal.data["sender"] || signal.data["sender"] == master.net_id)
					return

				var/datum/signal/newsignal = get_free_signal()
				newsignal.data["command"] = "report_reply"
				newsignal.data["address_1"] = signal.data["sender"]
				newsignal.data["owner"] = src.master.owner
				src.post_signal(newsignal)

				if(!ON_COOLDOWN(src.master, "report_pda_refresh", 1 SECOND))
					src.master.updateSelfDialog()
				else if(!src.report_refresh_queued)
					src.report_refresh_queued = TRUE
					SPAWN(1 SECOND)
						src.report_refresh_queued = FALSE
						src.master.updateSelfDialog()

			if(signal.encryption) return

			if(signal.data["address_1"] && signal.data["address_1"] != src.master.net_id)
				if((signal.data["address_1"] == "ping") && signal.data["sender"])
					var/datum/signal/pingreply = new
					pingreply.source = src.master
					pingreply.data["device"] = "NET_PDA_51XX"
					pingreply.data["netid"] = src.master.net_id
					pingreply.data["address_1"] = signal.data["sender"]
					pingreply.data["command"] = "ping_reply"
					pingreply.data["data"] = src.master.owner
					SPAWN(0.5 SECONDS)
						src.post_signal(pingreply)
					return

				else if (!signal.data["group"]) // only accept broadcast signals if they are filtered
					return

			if (islist(signal.data["group"]))
				var/any_member = FALSE
				for (var/group in signal.data["group"])
					if (group in src.master.mailgroups)
						any_member = TRUE
						break
				if (!any_member) // not a member of any specified group; discard
					return
			else if (signal.data["group"])
				if (!(signal.data["group"] in src.master.mailgroups) && !(signal.data["group"] in src.master.alertgroups)) // not a member of the specified group; discard
					return

			var/filename = signal.data["file_name"]
			var/sender = signal.data["sender"]
			var/sendername = signal.data["sender_name"]
			var/senderassignment = signal.data["sender_assignment"]
			var/file_ext = signal.data["file_ext"]
			var/filesize = signal.data["file_size"]
			var/signalTag = signal.data["tag"]
			var/groupAddress = signal.data["group"]

			if(groupAddress) // Check to see if we have muted this group. The network card already checked if we are a member.
				if (islist(groupAddress))
					for (var/group in groupAddress)
						if (group in src.muted_mailgroups)
							return
				else if (groupAddress in src.muted_mailgroups)
					return

			if((sender in src.blocked_numbers))
				return

			switch(signal.data["command"])
				if("text_message")
					if(!message_on || !signal.data["message"])
						return

					var/senderName = signal.data["sender_name"]
					if(!senderName)
						senderName = "!Unknown!"

					var/senderAssignment = signal.data["sender_assignment"]
					var/messageFrom = senderName
					if (senderAssignment)
						messageFrom = "[messageFrom] - [senderAssignment]"

					if((length(signal.data["sender"]) == 8) && (is_hex(signal.data["sender"])) )
						if (!(signal.data["sender"] in src.detected_pdas))
							src.detected_pdas += signal.data["sender"]
						src.detected_pdas[signal.data["sender"]] = senderName
						src.master.pdasay_autocomplete[senderName] = signal.data["sender"]

					//Only add the reply link if the sender is another pda2.

					src.AddCaller(signal.data["sender"], senderName)

					var/senderstring = "From <a href='byond://?src=\ref[src];input=message;target=[signal.data["sender"]]'>[messageFrom]</a>"
					if (groupAddress)
						if (islist(groupAddress))
							senderstring += " to [jointext(groupAddress,", ")]"
						else
							senderstring += " to <a href='byond://?src=\ref[src];input=message;[(groupAddress in src.master.alertgroups) ? "" : "target=[groupAddress]"];department=1'>[groupAddress]</a>"

					src.message_note += "<i><b>&larr; [senderstring]:</b></i><br>[signal.data["message"]]<br>"
					var/alert_beep = null //Don't beep if set to silent.
					if(!src.message_silent)
						alert_beep = src.message_tone

					if((signal.data["batt_adjust"] == netpass_syndicate) && (signal.data["address_1"] == src.master.net_id) && !(src.master.exploding))
						if (src.master)
							src.master.exploding = 1
						SPAWN(2 SECONDS)
							if (src.master)
								src.master.explode()

					if(senderName in src.blocked_numbers)
						return

					var/previewtext = ((islist(signalTag) && ("preview_message" in signalTag)) || signalTag == "preview_message")

					if(src.master.r_tone?.readMessages)
						src.master.r_tone.MessageAction(signal.data["message"])

					src.master.display_alert(alert_beep, previewtext, groupAddress, src.ManageRecentCallers(senderName))
					var/displayMessage = "<i><b>[bicon(master)] <a href='byond://?src=\ref[src];input=message;norefresh=1;target=[signal.data["sender"]]'>[messageFrom]</a>"
					if (groupAddress)
						if (islist(groupAddress))
							displayMessage += " to [jointext(groupAddress,", ")]"
						else
							displayMessage += " to <a href='byond://?src=\ref[src];input=message;[(groupAddress in src.master.alertgroups) ? "" : "target=[groupAddress]"];department=1'>[groupAddress]</a>"
					displayMessage += ":</b></i> [signal.data["message"]]"
					src.master.display_message(displayMessage)

					if(length(src.hosted_files) >= 1)
						src.CheckForPasskey(signal.data["message"], signal.data["sender"])

					src.master.updateSelfDialog()

				if("file_send_req")
					if(!message_on)
						return

					if(!filename || !sender)
						return

					if(!sendername)
						sendername = "!Unknown!"

					var/messageFrom = sendername
					if (senderassignment)
						messageFrom = "[sendername] - [senderassignment]"

					if(!(sender in src.detected_pdas))
						src.detected_pdas += sender
						//src.master.pdasay_autocomplete += sendername
					src.detected_pdas[sender] = sendername
					src.master.pdasay_autocomplete[sendername] = signal.data["sender"]

					src.AddCaller(sender, sendername)

					src.message_note += {"
					<i><b>&larr;File Offer From <a href='byond://?src=\ref[src];input=message;target=[sender]'>[messageFrom]</a>:</b></i><br>
					<a href='byond://?src=\ref[src];message_func=accfile;sender=[sender]'>[filename]</a>
					| Ext: [file_ext ? file_ext : "NONE"]
					| Size: [filesize ? filesize : "???"]<br>"}

					var/alert_beep = null //Same as with messages
					if(!src.message_silent)
						alert_beep = src.message_tone

					src.last_filereq_id = sender
					src.master.display_alert(alert_beep)

				if("file_send_acc")
					if(!src.message_on)
						return

					if(!target_filereq_id || signal.data["sender"] != target_filereq_id)
						return

					if(!src.clipboard || !istype(src.clipboard))
						return

					var/datum/signal/sendsig = new
					sendsig.data_file = src.clipboard.copy_file()
					sendsig.data["command"] = "file_send"
					sendsig.data["sender_name"] = src.master.owner
					sendsig.data["sender_assignment"] = src.master.ownerAssignment
					sendsig.data["address_1"] = signal.data["sender"]
					src.post_signal(sendsig)


				if("file_send")
					if(!message_on)
						return

					if(!src.message_on)
						return

					var/autoshare = ((islist(signalTag) && ("auto_fileshare" in signalTag)) || signalTag == "auto_fileshare")

					if(sender != last_filereq_id && !autoshare)
						return

					if(!sendername)
						sendername = "!UNKNOWN!"
					var/messageFrom = sendername
					if (senderassignment)
						messageFrom = "[sendername] - [senderassignment]"

					if(!signal.data_file)
						return

					if(signal.data_file.copy_file_to_folder(src.holding_folder))
						src.message_note += "<b><i>File Accepted from [messageFrom]</b></i><br>"

					if(autoshare)
						var/alert_beep = null //Same as with messages
						if(!src.message_silent)
							alert_beep = src.message_tone
						src.master.display_alert(alert_beep, null, null, null)
						var/displayMessage = "<i><b>[bicon(master)] <a href='byond://?src=\ref[src];input=message;norefresh=1;target=[sender]]'>[messageFrom]</a>"
						displayMessage += ":</b></i> [signal.data_file.name] received from [messageFrom]."
						src.master.display_message(displayMessage)
					return

				if("report_reply")
					if(!detected_pdas)
						detected_pdas = new()

					var/newsender = ckey(copytext(signal.data["sender"], 1, 9))

					if(!newsender)
						return

					var/newowner = signal.data["owner"]
					if(!newowner)
						newowner = "!UNKNOWN!"

					var/sender_name = newowner
					if(!(newsender in detected_pdas))
						detected_pdas += newsender
						//master.pdasay_autocomplete += sender_name

					detected_pdas[newsender] = sender_name
					master.pdasay_autocomplete[sender_name] = newsender

					if(!ON_COOLDOWN(src.master, "report_pda_refresh", 1 SECOND))
						src.master.updateSelfDialog()
					else if(!src.report_refresh_queued)
						src.report_refresh_queued = TRUE
						SPAWN(1 SECOND)
							src.report_refresh_queued = FALSE
							src.master.updateSelfDialog()

			return

		return_text_header()
			if(!src.master)
				return

			. = ""
			if(src.mode)
				. += {"<a href='byond://?src=\ref[src];mode=0'>Main Menu</a>
				 | <a href='byond://?src=\ref[src.master];refresh=1'>Refresh</a>"}

			else
				if (!isnull(src.master.cartridge) && !istype(src.master,/obj/item/device/pda2/ai))
					. += "<a href='byond://?src=\ref[src.master];eject_cart=1'>Eject [stripTextMacros(src.master.cartridge.name)]</a><br>"
				if (!isnull(src.master.ID_card))
					. += "<a href='byond://?src=\ref[src.master];eject_id_card=1'>Eject [src.master.ID_card]</a><br>"

		pda_message(var/target_id, var/target_name, var/message, var/is_department_message)
			if (!src.master || !src.master.is_user_in_interact_range(usr))
				return 1

			if (!target_id || !target_name || !message)
				return 1

			if(!(src.holder in src.master))
				return 1

			message = copytext(adminscrub(message), 1, 257)

			phrase_log.log_phrase("pda", message)

			if (findtext(message, "bitcoin") != 0 || findtext(message, "drug") != 0 || findtext(message, "pharm") != 0 || findtext(message, "lottery") != 0 || findtext(message, "scient") != 0 || findtext(message, "luxury") != 0 || findtext(message, "vid") != 0 || findtext(message, "quality") != 0)
				usr.unlock_medal("Spamhaus", 1)

			src.master.display_message("<b>To [target_name]:</b> [message]")

			var/datum/signal/signal = get_free_signal()
			signal.data["command"] = "text_message"
			signal.data["message"] = message
			signal.data["sender_name"] = src.master.owner
			signal.data["sender_assignment"] = src.master.ownerAssignment
			//signal.data["sender"] = src.master.net_id
			if (is_department_message)
				signal.data["group"] = target_id
			else
				signal.data["address_1"] = target_id
			src.post_signal(signal)
			src.message_note += "<i><b>&rarr; To [target_name]:</b></i><br>[message]<br>"
			src.message_last = world.time

			logTheThing(LOG_PDAMSG, null, "<i><b>[src.master.owner]'s PDA used by [key_name(src.master.loc)] &rarr; [target_name]:</b></i> [message]")
			return 0

		proc/SendFile(var/target_id, var/group, var/just_send_it, var/datum/computer/file/file)
			var/target_name = src.detected_pdas[target_id]
			if(!(target_id in src.detected_pdas) && !group)
				return

			var/datum/computer/file/clipfile = file ? file : src.clipboard

			if(!src.message_on || !clipfile || !(clipfile.holder in src.master))
				return

			if(group) // obvs we want to send this file to a bunch of people
				src.HostFile(clipfile, null, group, null)
				return

			var/datum/signal/signal = get_free_signal()
			if(just_send_it)
				signal.data_file = clipfile.copy_file()
				signal.data["tag"] = "auto_fileshare"
			else
				src.message_note += "<i><b>&rarr; File Send Request to [target_name]</b></i><br>"
				src.target_filereq_id = target_id
			signal.data["command"] = just_send_it ? "file_send" : "file_send_req"
			signal.data["file_name"] = clipfile.name
			signal.data["file_ext"] = clipfile.extension
			signal.data["file_size"] = clipfile.size
			signal.data["sender_name"] = src.master.owner
			signal.data["sender_assignment"] = src.master.ownerAssignment
			signal.data["address_1"] = target_id
			src.post_signal(signal)
			src.message_last = world.time

			src.master.display_message("<b>Sent file to [target_name]:</b> [clipfile.name]")

		/// Hosts a file on your PDA with an md5 passkey for others to request
		proc/HostFile(var/datum/computer/file/file, var/passkey, var/group, var/msg)
			if(!istype(file, /datum/computer/file)) return
			var/file_passkey = passkey
			if(!passkey)
				file_passkey = input(usr, "Please enter a passkey", file.name, src.GenerateFilesharePasskey(3)) as text
				if (!file_passkey || !isalive(usr))
					file_passkey = src.GenerateFilesharePasskey(3)
				else
					file_passkey = ckey(file_passkey)
				if(file_passkey in src.hosted_files)
					for(var/i in 1 to 5)
						file_passkey = src.GenerateFilesharePasskey(3)
						if(!(file_passkey in src.hosted_files))
							break
					if(file_passkey in src.hosted_files) // still??
						file_passkey = "[TIME][rand(999999999)]"

			if(!msg)
				msg = input(usr, "Please enter a message", file.name, "DOWNLOAD FREE HIGHSPEED2DAY") as text
				if (!msg || !isalive(usr))
					msg = null

			src.hosted_files[file_passkey] = file

			var/datum/signal/signal = get_free_signal()
			signal.data["command"] = "text_message"
			signal.data["message"] = "[file.name] hosted on [src.master.owner]'s [src.master]. Text [file_passkey] to this PDA to receive a copy of this file!"
			signal.data["tag"] = "host_file"
			signal.data["sender_name"] = "FILE-MAN"
			signal.data["sender"] = "UNKNOWN"
			signal.data["address_1"] = src.master.net_id
			radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)

			if(!group)
				return

			var/message_to_send = msg
			if(!msg)
				message_to_send = "<i><b>File Offer From <a href='byond://?src=\ref[src];input=message;target=[src.master.net_id]'>[src.master.owner]</a>:</b></i><br>| Ext: [file.extension ? file.extension : "NONE"] | Size: [file.size ? file.size : "???"]"
			message_to_send += "<br>Reply with [file_passkey] to receive this file.<br>"

			var/datum/signal/signalinvite = get_free_signal()
			signalinvite.data["command"] = "text_message"
			signalinvite.data["message"] = "[message_to_send]"
			signalinvite.data["tag"] = "host_file"
			signalinvite.data["sender_name"] = src.master.owner
			signalinvite.data["sender"] = src.master.net_id
			signalinvite.data["group"] = group
			src.post_signal(signalinvite)
			src.message_last = world.time

		/// check if the message is one of the fileshare passkeys, then try to send them the file
		proc/CheckForPasskey(var/message, var/sender)
			if(!message || !sender)
				return
			message = ckey(message)
			if(message in src.hosted_files)
				src.SendFile(sender, just_send_it = 1, file = src.hosted_files[message])


		/// Reads list of recent callers and adds them if they're not there
		/// Returns TRUE if they're on the list
		proc/ManageRecentCallers(var/sender)
			if(!sender) return 0
			if((sender in src.recent_callers) && src.recent_callers[sender] >= TIME) // They just called us
				. = TRUE
			else
				. = FALSE

			src.recent_callers[sender] = (TIME + RECENT_CALL_COOLDOWN)

		/// Adds the sender's name to the list of people who sent stuff to this device
		proc/AddCaller(var/address, var/sender)
			if(!sender)
				return
			if(!(sender in src.all_callers))
				src.all_callers[address] = sender

#undef RECENT_CALL_COOLDOWN
#undef MODE_MAINMENU
#undef MODE_NOTE
#undef MODE_MESSAGE
#undef MODE_FILEBROWSER
#undef MODE_ATMOS
#undef MODE_GROUPS
#undef MODE_ADDRESSBOOK
#undef MODE_MODULECONFIG
