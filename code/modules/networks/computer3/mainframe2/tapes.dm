//CONTENTS
//Mainframe 2 memory core
//Mainframe 2 master tape -- TODO
//Mainframe 2 boot tape
//Mainframe 2 artifact research tape.
//Guardbot configuration tape.
//Boot kit box


/*
 *	Mainframe 2 starting memory
 */
/obj/item/disk/data/memcard/main2
	file_amount = 4096

	New()
		..()
		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "sys"
		newfolder.metadata["permission"] = COMP_HIDDEN
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/mainframe_program/os/kernel(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/shell(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/login(src) )

		var/datum/computer/folder/subfolder = new /datum/computer/folder
		subfolder.name = "drvr" //Driver prototypes.
		newfolder.add_file( subfolder )
		//subfolder.add_file ( new FILEPATH GOES HERE )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/databank(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/printer(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/nuke(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/guard_dock(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/radio(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/test_apparatus(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/service_terminal(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/user_terminal(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/telepad(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/comm_dish(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/artifact_console(src) )
		//subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/logreader(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/apc(src) )

		subfolder = new /datum/computer/folder
		subfolder.name = "srv"
		newfolder.add_file( subfolder )
		subfolder.add_file( new /datum/computer/file/mainframe_program/srv/email(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/srv/print(src) )
		//subfolder.add_file( new /datum/computer/file/mainframe_program/srv/accesslog(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/srv/telecontrol(src) )

		newfolder = new /datum/computer/folder
		newfolder.name = "bin" //Applications available to all users.
		newfolder.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/cd(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/ls(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/rm(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/cat(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/mkdir(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/ln(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/chmod(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/chown(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/su(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/cp(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/mv(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/mount(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/grep(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/pwd(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/scnt(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/getopt(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/date(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/tar(src) )

		newfolder = new /datum/computer/folder
		newfolder.name = "var"
		newfolder.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER
		src.root.add_file( newfolder )

		newfolder = new /datum/computer/folder
		newfolder.name = "tmp"
		newfolder.metadata["permission"] = COMP_ALLACC &~(COMP_DOTHER|COMP_DGROUP)
		src.root.add_file( newfolder )
/*
		subfolder = new /datum/computer/folder
		subfolder.name = "log"
		subfolder.metadata["permission"] = COMP_ROWNER|COMP_RGROUP
		newfolder.add_file( subfolder )
*/
		newfolder = new /datum/computer/folder
		newfolder.name = "etc"
		newfolder.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER
		src.root.add_file( newfolder )

		subfolder = new /datum/computer/folder
		subfolder.name = "mail"
		newfolder.add_file( subfolder )

		var/datum/computer/file/record/groupRec = new /datum/computer/file/record( )
		groupRec.name = "groups"
		subfolder.add_file( groupRec )

		var/list/randomMails = get_random_email_list()
		var/typeCount = rand(4,6)
		while (typeCount-- > 0 && length(randomMails))
			var/mailName = pick(randomMails)
			var/datum/computer/file/record/mailfile = new /datum/computer/file/record/random_email(mailName)
			subfolder.add_file(mailfile)
			randomMails -= mailName
/*		var/list/randomMailTypes = childrentypesof(/datum/computer/file/record/random_email)
		var/typeCount = 5
		while (typeCount-- > 0 && length(randomMailTypes))
			var/mailType = pick(randomMailTypes)
			var/datum/computer/file/record/mailfile = new mailType
			subfolder.add_file( mailfile )

			randomMailTypes -= mailType*/

		newfolder = new /datum/computer/folder
		newfolder.name = "mnt"
		newfolder.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER
		src.root.add_file( newfolder )

		newfolder = new /datum/computer/folder
		newfolder.name = "conf"
		newfolder.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER
		src.root.add_file( newfolder )

		var/datum/computer/file/record/testR = new
		testR.name = "motd"
		testR.fields += "Welcome to DWAINE System VI!"
		testR.fields += pick("Better than System V ever was.","GLUEEEE GLUEEEE GLUEEEEE","Only YOU can prevent lp0 fires!","Please try not to kill yourselves today.", "Please don't set the lab facilities on fire.")
		newfolder.add_file( testR )

		newfolder.add_file( new /datum/computer/file/record/dwaine_help(src) )

		return

/obj/item/disk/data/tape/master
	name = "ThinkTape-'Master Tape'"
	//Not sure what all to put here yet.

	New()
		..()
		//First off, buddy stuff.
		src.root.add_file( new /datum/computer/file/guardbot_task/security(src) )
		src.root.add_file( new /datum/computer/file/guardbot_task/security/purge(src) )
		src.root.add_file( new /datum/computer/file/guardbot_task/bodyguard(src) )
		src.root.add_file( new /datum/computer/file/guardbot_task/security/area_guard(src) )
		src.root.add_file( new /datum/computer/file/guardbot_task/bodyguard/heckle(src) )
		src.root.add_file( new /datum/computer/file/guardbot_task/bodyguard/cheer_up(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/guardbot_interface(src))
		src.root.add_file( new /datum/computer/file/record/pr6_readme(src))
		src.root.add_file( new /datum/computer/file/record/patrol_script(src))
		src.root.add_file( new /datum/computer/file/record/bodyguard_script(src))
		src.root.add_file( new /datum/computer/file/record/roomguard_script(src))
		src.root.add_file( new /datum/computer/file/record/bodyguard_conf(src))

		//Nuke interface, because sometimes the nuke is alround.
		src.root.add_file( new /datum/computer/file/mainframe_program/nuke_interface(src) )
		//src.root.add_file( new /datum/computer/file/mainframe_program/srv/telecontrol(src) )

		for (var/datum/computer/file/F in src.root.contents)
			F.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER

	readonly
		desc = "A reel of magnetic data tape.  The casing has been modified so as to prevent write access."
		icon_state = "r_tape"

		New()
			..()
			src.read_only = 1

/obj/item/disk/data/tape/boot2
	name = "ThinkTape-'OS Backup'"
	desc = "A reel of magnetic data tape containing operating software.  The casing has been modified so as to prevent write access."
	icon_state = "r_tape"

	New()
		..()
		src.root.add_file( new /datum/computer/file/mainframe_program/os/kernel(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/shell(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/login(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/driver/mountable/databank(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/driver/mountable/printer(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/driver/nuke(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/driver/mountable/guard_dock(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/driver/mountable/radio(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/driver/test_apparatus(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/driver/mountable/service_terminal(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/driver/mountable/user_terminal(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/driver/telepad(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/driver/mountable/comm_dish(src) )
		//src.root.add_file( new /datum/computer/file/mainframe_program/driver/mountable/logreader(src) )

		src.root.add_file( new /datum/computer/file/mainframe_program/utility/cd(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/ls(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/rm(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/cat(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/mkdir(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/ln(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/chmod(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/chown(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/su(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/cp(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/mv(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/mount(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/grep(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/pwd(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/scnt(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/getopt(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/date(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/utility/tar(src) )
		//src.root.add_file( new /datum/computer/file/mainframe_program/srv/accesslog(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/srv/telecontrol(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/srv/email(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/srv/print(src) )
		src.read_only = 1

/obj/item/disk/data/tape/test
	name = "ThinkTape-'Test'"
	desc = "A reel of magnetic data tape containing various test files."

	New()
		..()
		src.root.add_file( new /datum/computer/file/mainframe_program/shell(src) )
		src.root.add_file( new /datum/computer/file/document(src) )
		src.root.add_file( new /datum/computer/file/record/c3help(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/nuke_interface(src) )
		src.root.add_file( new /datum/computer/file/mainframe_program/test_interface(src) )

/obj/item/disk/data/tape/guardbot_tools
	name = "ThinkTape-'PR-6S Config'"
	desc = "A reel of magnetic data tape containing configuration and support files for PR-6S Guardbuddies."

	New()
		..()
		src.root.add_file( new /datum/computer/file/guardbot_task/security(src) )
		src.root.add_file( new /datum/computer/file/guardbot_task/security/purge(src) )
		src.root.add_file( new /datum/computer/file/guardbot_task/bodyguard(src) )
		src.root.add_file( new /datum/computer/file/guardbot_task/security/area_guard(src) )

		src.root.add_file( new /datum/computer/file/mainframe_program/guardbot_interface(src))
		src.root.add_file( new /datum/computer/file/record/pr6_readme(src))
		src.root.add_file( new /datum/computer/file/record/patrol_script(src))
		src.root.add_file( new /datum/computer/file/record/bodyguard_script(src))
		src.root.add_file( new /datum/computer/file/record/bodyguard_conf(src))
		for (var/datum/computer/file/F in src.root.contents)
			F.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER

/obj/item/disk/data/tape/artifact_research
	name = "ThinkTape-'Artifact Research'"
	desc = "A reel of magnetic data tape containing modern research software."

	New()
		..()
		src.root.add_file( new /datum/computer/file/mainframe_program/test_interface(src)  )
		src.root.add_file( new /datum/computer/file/record/artlab_activate(src))
		src.root.add_file( new /datum/computer/file/record/artlab_deactivate(src))
		src.root.add_file( new /datum/computer/file/record/artlab_read(src))
		src.root.add_file( new /datum/computer/file/record/artlab_info(src))
		src.root.add_file( new /datum/computer/file/record/artlab_xray(src))
		src.root.add_file( new /datum/computer/file/record/artlab_heater(src))
		src.root.add_file( new /datum/computer/file/record/artlab_elecbox(src))
		src.root.add_file( new /datum/computer/file/record/artlab_pitcher(src))
		src.root.add_file( new /datum/computer/file/record/artlab_impactpad(src))
		//src.root.add_file( new /datum/computer/file/mainframe_program/artifact_research(src) )
		for (var/datum/computer/file/F in src.root.contents)
			F.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER
