//CONTENTS:
//Base filesharing thing
#define MODE_MAIN 0
#define MODE_HELP 1
#define MODE_HOST 2

/datum/computer/file/pda_program/fileshare
	name = "SpaceWire v1.1.2"
	var/mode = 0
	///
	var/list/file_list = list()

	return_text()
		. = src.return_text_header()
		. += " | <a href='byond://?src=\ref[src];add_host=1'>Host</a>"
		if(!src.master.fileshare_program)
			. += " | <a href='byond://?src=\ref[src];install=1'>Install</a>"
		. += " | <a href='byond://?src=\ref[src];readme=1'>Help</a><br>"
		. += "<h4>[src.name]</h4><hr>"

		if(!src.master.host_program)
			. += "ERROR 404: File not found."
		switch(src.mode)
			if(MODE_MAIN)
				var/datum/computer/file/pda_program/os/main_os/masterOS = src.master.host_program
				. += "<h4>Hosted Files</h4><br>"
				if(length(masterOS.hosted_files) < 1)
					. += "None!"
				else
					for(var/P in masterOS.hosted_files)
						var/datum/computer/file/F = masterOS.hosted_files[P]
						if(!istype(F, /datum/computer/file))
							continue
						. += {"<table cellspacing=5>
						<tr>
						<td><a href='byond://?src=\ref[src];target=\ref[F];browse_func=open'>[F.name]</a></td>
						<td>Size: [F.size] - [F.extension]</td></tr>
						<tr>
						<td>Passkey:</td>
						<td><a href='byond://?src=\ref[src];change_passkey=[P]'>[P]</a></td>
						</tr>
						<tr>
						<td><a href='byond://?src=\ref[src];unhost=[P]'>Stop Hosting?</a></td>
						<td></td>
						</tr>
						</table><hr>"}

			if(MODE_HELP)
				. += src.return_help_text()

			if(MODE_HOST)
				var/datum/computer/file/pda_program/os/main_os/masterOS = src.master.host_program
				. += "<h4>Select a File</h4><br>"
				. += "<table cellspacing=5>"
				for(var/datum/computer/file/mainfile in masterOS.browse_folder.contents)
					if(mainfile == masterOS)
						continue
					else if(mainfile.dont_copy)
						. += {"<tr><td><strike>[mainfile.name]</strike></td>
						<td>ERROR</td>
						<td>CANNOT SHARE</td>
						</tr>"}
					else
						src.file_list[mainfile.name] = mainfile
						. += {"<tr><td><a href='byond://?src=\ref[src];host_file=[mainfile.name]'>[mainfile.name]</a></td>
						<td>Size: [mainfile.size]</td>
						<td>[mainfile.extension]</td>
						</tr>"}

				var/datum/computer/folder/other_drive_folder
				for (var/obj/item/disk/data/D in src.master)
					if (D != masterOS.browse_folder.holder && D.root)
						other_drive_folder = D.root
						break

				if (other_drive_folder)
					for(var/datum/computer/file/morefile in other_drive_folder.contents)
						if(morefile == masterOS)
							continue
						else if(morefile.dont_copy)
							. += {"<tr><td><strike>[morefile.name]</strike></td>
							<td>ERROR</td>
							<td>CANNOT SHARE</td>
							</tr>"}
						else
							src.file_list[morefile.name] = morefile
							. += {"<tr><td><a href='byond://?src=\ref[src];host_file=[morefile.name]'>[morefile.name]</a></td>
							<td>Size: [morefile.size]</td>
							<td>[morefile.extension]</td>
							</tr>"}
				. += "</table><br>"
				. += "<a href='byond://?src=\ref[src];add_host=1'>Go Back</a>"

	Topic(href, href_list)
		if(..())
			return

		if (href_list["readme"])
			if(src.mode == MODE_HELP)
				src.mode = MODE_MAIN
			else
				src.mode = MODE_HELP

		if (href_list["add_host"])
			if(src.mode == MODE_HOST)
				src.mode = MODE_MAIN
			else
				src.mode = MODE_HOST

		if (href_list["host_file"])
			src.master.host_program.HostFile(src.file_list[href_list["host_file"]])

		if (href_list["unhost"])
			src.master.host_program.hosted_files -= href_list["unhost"]

		if (href_list["install"])
			src.master.fileshare_program = src
			var/alert_beep = null
			if(!src.master.host_program.message_silent)
				alert_beep = src.master.host_program.message_tone
			src.master.display_alert(alert_beep)
			var/displayMessage = "[bicon(master)] SpaceWire's SpaceMessenger Groupchat integration complete! You can now share files with your mailgroups."
			src.master.display_message(displayMessage)

		if (href_list["change_passkey"])
			if(src.master.host_program.hosted_files[href_list["change_passkey"]])
				var/list/hosted = src.master.host_program.hosted_files
				var/datum/computer/file/hostedfile = hosted[href_list["change_passkey"]]
				var/pass = input(usr, "Please enter a passkey", hostedfile, href_list["change_passkey"]) as text
				if (!pass || !isalive(usr))
					pass = src.GenerateFilesharePasskey(3)
				else if(pass == href_list["change_passkey"])
					pass = ckey(pass)

				if(pass != href_list["change_passkey"])
					if(pass in hosted)
						for(var/i in 1 to 5)
							pass = src.GenerateFilesharePasskey(3)
							if(!(pass in hosted))
								break
						if(pass in hosted) // still??
							pass = "[TIME][rand(999999999)]"
					hosted -= href_list["change_passkey"]
					hosted[pass] = hostedfile

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

	proc/return_help_text()
		. = {"
<h4>SpaceWire Semi-Automated Fileserver</h4><br>
READMEPLZ.TXT<hr>
SpaceWire allows the home cyber-entrepreneur to transform any Thinktronic 5150 Personal Data Assistant into a powerful Datafile Distribution Terminal (DDT), regardless of the user's technical skill or interest.<br>
<br>
To host a file through this program:<br>
<ol>
<li>Open the <b>SpaceWire Semi-Automated Fileserver</b>.</li>
<li>Scroll down and click <b>Host a File</b>.</li>
<li><b>Click</b> on the file you want to host. Make sure you are licensed to distribute this file!</li>
<li>Enter a <b>File Index String Hash</b>. While it can be anything, try to keep it short, unique, and memorable!</li>
<li>Instruct others to send a message to this device containing only this <b>FISH</b>. Anything else will not work!</li>
</ol>
<br>
To host a file through SpaceWire's SpaceMessenger Groupchat integration:<br>
<ol>
<li>Open the PDA's <b>File Browser</b>.</li>
<li><b>Copy</b> the file you want to host.</li>
<li>Back out of the File browser and open <b>SpaceMessenger</b>.</li>
<li>Open <b>Groups</b> and find the mailgroup you want to notify about your file</li>
<li>Click <b>Send File</b>. You will be prompted to enter a FISH, as well as a message to be inlcuded.</li>
<li>SpaceWire will send a message to everyone in this group with your message, the FISH, and instructions on how to use it.</li>
</ol>
<font size=1>This program is for informational purposes only.<br>
StarShare DataWorx, Infreedom LTD, and Space Wire LLC claim no responsibility for any illegal activities facilicated by this program.<br><br></font>
<a href='byond://?src=\ref[src];readme=1'>Close</a>
"}

#undef MODE_MAIN
#undef MODE_HELP
#undef MODE_HOST
