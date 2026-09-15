ABSTRACT_TYPE(/datum/db_manager_menu/main)
/datum/db_manager_menu/main
	VAR_PROTECTED/name = null
	VAR_PROTECTED/list/submenus = list()

/datum/db_manager_menu/main/load()
	var/text = src.get_banner()
	text += "<br>Welcome to [src.name]<br><b>Commands:</b>"

	for (var/i in 1 to length(src.submenus))
		text += "<br>([i]) [src.submenus[i]]"

	text += "<br>(0) Quit."
	src.parent.print_text(text)

/datum/db_manager_menu/main/input_text(text)
	var/command = global.text2num_safe(src.parent.parse_string(text)[1])
	var/index_number = round(max(command, 0))
	if (index_number == 0)
		src.parent.print_text("Quitting...")
		src.wait(2 SECONDS)
		src.parent.master.temp = null
		src.parent.master.temp_add = "Screen cleared.<br>"
		src.parent.master.updateUsrDialog()
		src.parent.master.unload_program(src.parent)
		return

	if (index_number > length(src.submenus))
		return

	var/menu_type = src.submenus[src.submenus[index_number]]
	src.parent.switch_menu_to(menu_type)

/datum/db_manager_menu/main/proc/get_banner()
	return


/datum/db_manager_menu/main/secmate
	name = "SecMate 7"
	submenus = list(
		"View security records." = "record_list",
		"Search for a record." = "search_input",
		"Adjust settings." = "settings",
	)

/datum/db_manager_menu/main/secmate/get_banner()
	. = ""
	. += @{"<center> ____________________    ____________________   </center>"}
	. += @{"<center>/\  ___\  ___\  ___\ "-./  \  __ \ _  _\  ___\  </center>"}
	. += @{"<center>\ \___  \  __\\ \___\ \-./\ \ \_\ \/\ \/\  __\  </center>"}
	. += @{"<center> \/\_____\_____\_____\ \-\ \ \ \/\ \ \ \ \_____\</center>"}
	. += @{"<center>  \/_____/_____/_____/_/  \/_/_/\/_/\/_/\/_____/</center>"}


/datum/db_manager_menu/main/medtrak
	name = "MedTrak 5.1"
	submenus = list(
		"View medical records." = "record_list",
		"Search for a record." = "search_input",
		"View viral database." = "disease_list",
		"Adjust settings." = "settings",
	)

/datum/db_manager_menu/main/medtrak/get_banner()
	. = ""
	. += @{"<center> __  __        _       _____          _   </center>"}
	. += @{"<center>|  \/  |___ __| | ___ |_   _|_ _ __ _| |__</center>"}
	. += @{"<center>| |\/| / -_) _` ||___|  | | | '_/ _` | / /</center>"}
	. += @{"<center>|_|  |_\___\__,_|       |_| |_| \__,_|_\_\</center>"}


/datum/db_manager_menu/main/bankboss
	name = "BankBoss 2.1"
	submenus = list(
		"View bank records." = "record_list",
		"Search for a record." = "search_input",
		"View station budget." = "station_budget",
		"Adjust settings." = "settings",
	)

/datum/db_manager_menu/main/bankboss/get_banner()
	. = ""
	. += @{"<center>____    __   ___  _ ___ _ ____   ___   __   __ </center>"}
	. += @{"<center>|||̲_)  ///\  |||\ | |||_/ |||̲_) /// \ (((` (((`</center>"}
	. += @{"<center>||| ) ///——\ ||| \| ||| \ ||| ) \\\ / .))) .)))</center>"}
	. += @{"<center>‾‾‾‾  ‾‾   ‾ ‾‾‾  ‾ ‾‾‾ ‾ ‾‾‾‾   ‾‾‾   ‾‾   ‾‾ </center>"}
