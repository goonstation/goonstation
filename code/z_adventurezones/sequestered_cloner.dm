/*
    MarkNstein's Sequestered Cloner prefab code
    Took a lot of code-inspiration from Hemera.
    Contains in order:
        APC area for the puzzle
        Quick-On APC for the puzzle
        New-sleeper-agent paper instructions
        Mainframe lore tape
        and lore entries
*/

//Quickly turns everything back on as soon as there's a little bit of power
/obj/machinery/power/apc/puzzle_apc
	name = "Puzzle APC"
	dir = WEST
	autoname_on_spawn = 1
	noalerts = 1
	aidisabled = 1

	initialize()
		. = ..()
		for(var/obj/cable/C in src.loc)
			C.update_network()
			break

	// set channels depending on how much charge we have left
	check_channel_thresholds()
		if(cell.charge <= 0) // zero charge, turn all off
			equipment = autoset(equipment, 0)
			lighting = autoset(lighting, 0)
			environ = autoset(environ, 0)
			if (!noalerts)
				area.poweralert(0, src)
		else // otherwise all can be on
			equipment = autoset(equipment, 1)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
			if(cell.percent() > 75)
				if (!noalerts)
					area.poweralert(1, src)



/obj/item/paper/new_agent_note
	name = "Congradulations!"
	info = {"Congradulations!<br>
			You've completed your training.<br>
			You are a sleeper agent for the Syndicate.<br>
			Your activation code is:<br>
			-------------------------------------------<br>
			<font face='System' size='3'>YOUR WINNING LOTTERY NUMBERS ARE:<br>
			   79  85  99  00  47<br>
			THANK YOU FOR CHOOSING EZ-LOTTO</font><br>
			-------------------------------------------<br>
			During your education, we embeded a memetic mission.<br>
			You are to blend in with the engineering crew in the nearby Nanotrasen station.<br>
			You will be activated at a later time through the station's broadcast system, whenapon your mission will be remembered.<br>
			Until then do your best to fit in, do not rock the boat, do not harm your "fellow employees".<br>
			Grab your gear from the neigboring locker and ID dispenser.<br>
			Destroy this message. Supplies are in the fridge to aid in it's destruction.<br>
			Make us proud, agent.
			"}



/obj/item/disk/data/tape/seq_cloner_logs
	name = "ThinkTape-'Logs'"
	desc = "A reel of magnetic data tape containing various log files."

	New()
		..()
		src.root.add_file( new /datum/computer/file/record/seq_cloner_instructions(src) )
		src.root.add_file( new /datum/computer/file/record/seq_cloner_memo1(src) )
		src.root.add_file( new /datum/computer/file/record/seq_cloner_memo2(src) )
		src.root.add_file( new /datum/computer/file/record/seq_cloner_memo3(src) )
		src.root.add_file( new /datum/computer/file/record/seq_cloner_memo4(src) )


/datum/computer/file/record/seq_cloner_instructions
	name = "instructions"

	New()
		..()
		src.fields = list("Welcome Agent.",
    "Your goal here it to produce more",
    "sleeper agents for our cause.",
    "This is an experiment in cloning tech.",
    "We hope you can iterate on a DNA pattern,",
    "and produce agents that excel in their",
    "engineering skills, and killing skills.",
    "Educationl and prooving materials are",
    "already setup.",
    "Keep us updated on your progress.",
    "We'll periodically send biomass.")

/datum/computer/file/record/seq_cloner_memo1
	name = "1306"

	New()
		..()
		src.fields = list("-----------------|HEAD|-----------------",
    "MEMORANDUM 1.306 - WE JUN 08 2050",
    "TO: HQ",
    "FROM: Richard Segway",
    "SUBJECT: First Sleeper",
    "-----------------|BODY|-----------------",
    "I'm happy to report a success!",
    "The monkey proved no match, though they",
    "struggled with the engine test.",
    "Here's hoping he flies under the radar.",
    "----------------------------------------")

/datum/computer/file/record/seq_cloner_memo2
	name = "1312"

	New()
		..()
		src.fields = list("-----------------|HEAD|-----------------",
    "MEMORANDUM 1.312 - WE JUN 13 2050",
    "TO: HQ",
    "FROM: Richard Segway",
    "SUBJECT: Recent Clones: Poor",
    "-----------------|BODY|-----------------",
    "My good progress has slumped.",
    "Where each iteration was an improvement,",
    "the latest spent the whole test slowly",
    "dissasembling the floors until they",
    "starved.",
    "I've been recycling the bodies, but then",
    "reclaimer is running low.",
    "I'll revert back to a previous iteration.",
    "Please send more biomass.")

/datum/computer/file/record/seq_cloner_memo3
	name = "1314"

	New()
		..()
		src.fields = list("-----------------|HEAD|-----------------",
    "MEMORANDUM 1.314 - WE JUN 15 2050",
    "TO: HQ",
    "FROM: Richard Segway",
    "SUBJECT: BIOMASS, Not Food!",
    "-----------------|BODY|-----------------",
    "You can send me dead monkies if you need",
    "to. I've certainly been getting my hands",
    "bloody over here. But don't send me a ",
    "fridge expecting me to use it in the ",
    "biomass reclaimer! I was able to recycle",
    "the butter and make another successful",
    "agent. NT might find them out though,",
    "they left a stink in their wake.",
    "Please send more biomass. BIOMASS.")

/datum/computer/file/record/seq_cloner_memo4
	name = "1315"

	New()
		..()
		src.fields = list("-----------------|HEAD|-----------------",
    "MEMORANDUM 1.315 - WE JUN 16 2050",
    "TO: HQ",
    "FROM: Richard Segway",
    "SUBJECT: Local Fauna Troubles!",
    "-----------------|BODY|-----------------",
    "Thought the post had been comprimised!",
    "I've been hearing some scratching outside.",
    "It's rythmic though, I suspect a space ant",
    "looking for a new home.",
    "I'll go dispatch it. But if an ant has",
    "found its way here, more may arrive.",
    "It may be time to pack up shop.")



//Mainframe stuff for the H7 spacejunk.
/obj/machinery/networked/mainframe/seq_cloner
	setup_drive_type = /obj/item/disk/data/memcard/seq_cloner

/obj/item/disk/data/memcard/seq_cloner
	file_amount = 1024

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
		//subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/printer(src) )
		//subfolder.add_file( new /datum/computer/file/mainframe_program/driver/nuke(src) )
		//subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/guard_dock(src) )
		//subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/radio(src) )
		//subfolder.add_file( new /datum/computer/file/mainframe_program/driver/secdetector(src) )
		//subfolder.add_file( new /datum/computer/file/mainframe_program/driver/apc(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/user_terminal(src) )

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
		//newfolder.add_file( new /datum/computer/file/mainframe_program/guardbot_interface(src) )

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
		testR.fields += "Glory to the Syndicate!"
		newfolder.add_file( testR )

		newfolder.add_file( new /datum/computer/file/record/dwaine_help(src) )

		newfolder = new /datum/computer/folder
		newfolder.name = "etc"
		newfolder.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER
		src.root.add_file( newfolder )

		return
