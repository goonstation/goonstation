
//debris field buddy factory

/obj/machinery/buddyfactory
	name = "robot arm"
	desc = "Some sort of stationary factory robot."
	icon = 'icons/misc/exploration.dmi'
	icon_state = "factory_arm_sleep"
	var/input_stage = 1 //What stage of buddy frame we operate on.
	var/input_model = 4 //Model of buddy we can build.

	proc/drop_item()
		return

	process()
		if (status & NOPOWER)
			return

		var/obj/item/guardbot_frame/frame = locate() in get_step(src,src.dir)
		if (istype(frame, /obj/item/guardbot_frame))
			if (frame.buddy_model != input_model || frame.stage != input_stage)
				return

			switch (input_stage)
				if (1)
					var/obj/item/cell/cell_to_add = locate() in range(src, 1)
					if (istype(cell_to_add))
						frame.Attackby(cell_to_add, src)
						if (frame.stage > 1)
							src.visible_message("[src] inserts [cell_to_add] into [frame].")
							FLICK("factory_arm_active",src)

				if (2)
					var/obj/item/device/guardbot_tool/tool_to_add = locate() in range(src, 1)
					if (!frame.created_module && istype(tool_to_add))
						frame.Attackby(tool_to_add, src)
						if (frame.created_module)
							src.visible_message("[src] attaches [tool_to_add] into [frame].")
							FLICK("factory_arm_active",src)
					else
						var/obj/item/guardbot_core/core = locate() in range(src, 1)
						if (istype(core))
							frame.Attackby(core, src)
							if (frame.stage == 3)
								src.visible_message("[src] attaches [core] into [frame].")
								FLICK("factory_arm_active",src)

				if (3)
					var/obj/item/parts/robot_parts/arm/arm = locate() in range(src,1)
					if (istype(arm))
						frame.Attackby(arm,src)
						FLICK("factory_arm_active",src)
			//todo
			return

	power_change()
		if(powered())
			src.name = initial(src.name)
			icon_state = "factory_arm"
			status &= ~NOPOWER
		else
			SPAWN(rand(0, 15))
				src.name = "inactive [initial(src.name)]"
				icon_state = "factory_arm_sleep"
				status |= NOPOWER

/obj/machinery/networked/mainframe/robot_factory
	setup_drive_type = /obj/item/disk/data/memcard/robot_factory

/obj/item/disk/data/memcard/robot_factory
	file_amount = 2048

	New()
		..()
		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "sys"
		newfolder.metadata["permission"] = COMP_HIDDEN
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/mainframe_program/os/kernel(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/shell(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/login(src) )
		//newfolder.add_file( new /datum/computer/file/mainframe_program/h7init(src) )

		var/datum/computer/folder/subfolder = new /datum/computer/folder
		subfolder.name = "drvr" //Driver prototypes.
		newfolder.add_file( subfolder )
		//subfolder.add_file ( new FILEPATH GOES HERE )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/databank(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/printer(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/nuke(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/guard_dock(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/radio(src) )
		//subfolder.add_file( new /datum/computer/file/mainframe_program/driver/secdetector(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/apc(src) )
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
		newfolder.add_file( new /datum/computer/file/mainframe_program/guardbot_interface(src) )

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
		testR.fields += "Industrial Process System Distribution"
		newfolder.add_file( testR )

		newfolder.add_file( new /datum/computer/file/record/dwaine_help(src) )

		newfolder = new /datum/computer/folder
		newfolder.name = "etc"
		newfolder.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER
		src.root.add_file( newfolder )

		newfolder.add_file( new /datum/computer/file/guardbot_task/bodyguard(src) )
		newfolder.add_file( new /datum/computer/file/guardbot_task/security(src) )

		return




/datum/computer/file/record/tds_basketball
	name = "journal1103"

	New()
		..()
		fields = list("Personal Log - 11/03/51",
			"Toczylowski has gone completely mad.",
			"He wants a new task program for the PR-6 Robuddies.",
			"Not just any task though, he wants them to play basketball.",
			"",
			"I've tried talking to him, telling him just how ill-advised that would be.  Robuddies are short.  They cannot dunk. They cannot slam.  They cannot even jump.",
			"But he's made it clear that he wants basketball robots, and if I can't give him that I'm out of a job.",
			"Terrific.")

/datum/computer/file/record/tds_desperate
	name = "journal1107"

	New()
		..()
		fields = list("Personal Log - 11/07/51",
			"I have nothing and Toczylowski is coming back.",
			"It's been \"long enough\" and he wants results.",
			"None of them can jump. I've tried, and that fucking asshole James keeps undoing all my progress.",
			"",
			"",
			"q!",
			"rm journal1107",
			"ls logs",
			"ls /logs",
			"LS ./logs/",
			"FUCK")

/datum/computer/file/record/tds_repairlog1
	name = "servlog47"

	New()
		..()
		fields = list("File ID: 51-47",
			"Technician: J. Wilhelm",
			"Date: 10/17/2051",
			"",
			"Description: Fabrication Unit G emitted a loud banging noise and ceased to function.",
			"Summary: Fabrication unit G had a critical malfunction in its articulator control circuit that",
			"ended up tearing apart most of the assembly mechanism. Inspection determined that the entire mechanism was completely unsalvageable.",
			"",
			"Resolution: Unit removed from working area, new fabrication unit ordered.")

/datum/computer/file/record/tds_repairlog2
	name = "servlog48"

	New()
		..()
		fields = list("File ID: 51-48",
			"Technician: J. Wilhelm",
			"Date: 10/25/2051",
			"",
			"Description: Databank 2 was unable to read tapes.",
			"Summary: Staff filed multiple complaints that volumes on USR databank, databank 2, could not be accessed from any account.",
			"However, the databank's profile on the DWAINE system was properly configured.  Physical inspection of the databank revealed that the cover had been opened and the tape had been physically removed from the drive.",
			"",
			"Resolution: Tape replaced, drive functionality restored.")

/datum/computer/file/record/tds_repairlog3
	name = "servlog49"

	New()
		..()
		fields = list("File ID: 51-49",
			"Technician: J. Wilhelm",
			"Date: 11/03/2051",
			"",
			"Description: Robuddy PR-6-02002111 could not jump.",
			"Summary: Factory Manager Volkheim reported that none of the robuddy systems in the facility could jump and thus \"could not play basketball.\"",
			"",
			"Resolution: No action taken, jump functionality not in specifications.")

/datum/computer/file/record/tds_repairlog4
	name = "servlog50"

	New()
		..()
		fields = list("File ID: 51-50",
			"Technician: J. Wilhelm",
			"Date: 11/05/2051",
			"",
			"Description: Robuddy PR-6-0200212b was unable to move..",
			"Summary: Unit 0200212b encountered a motivation failure and automatically reported its condition to the control system.  0200212b was located two meters from its charge dock.",
			"The Unit was then shut down and disassembled.  Cursory inspection discovered a crude hydraulic mechanism grafted to the motor assembly.",
			"",
			"Resolution: Unauthorized modification reversed, unit functionality restored.")

/datum/computer/file/record/tds_repairlog5
	name = "servlog51"

	New()
		..()
		fields = list("File ID: 51-51",
			"Technician: J. Wilhelm",
			"Date: 11/07/2051",
			"",
			"Description: Robuddies cannot jump..",
			"Summary: They cannot jump.  They CANNOT JUMP.  STOP TRYING TO MAKE THEM JUMP THEY CANNOT JUMP.  VOLKHEIM I KNOW IT'S YOU.  STOP IT.",
			"",
			"Resolution: UNABLE TO JUMP")


/obj/item/disk/data/tape/tds_journaltape

	New()
		..()
		src.root.add_file( new /datum/computer/file/record/tds_basketball(src))
		src.root.add_file( new /datum/computer/file/record/tds_desperate(src))

/obj/item/disk/data/tape/tds_replogtape

	New()
		..()
		src.root.add_file( new /datum/computer/file/record/tds_repairlog1(src))
		src.root.add_file( new /datum/computer/file/record/tds_repairlog2(src))
		src.root.add_file( new /datum/computer/file/record/tds_repairlog3(src))
		src.root.add_file( new /datum/computer/file/record/tds_repairlog4(src))
		src.root.add_file( new /datum/computer/file/record/tds_repairlog5(src))

/obj/storage/secure/filing_cabinet
	name = "filing cabinet"
	real_name = "filing cabinet"
	desc = "A filing cabinet with a little lock, one of those circular key kinds."
	radio_control = null
	icon_state = "filecabinet"
	icon_closed = "filecabinet"
	icon_opened = "filecabinet-open"
	icon_redlight = null
	icon_greenlight = null
	secure = 2
	can_leghole = FALSE

	close()
		..()
		if(!src.locked)
			src.locked = 1
			src.name_prefix("locked")
			src.UpdateName()

	receive_signal()
		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		boutput(user, SPAN_ALERT("You...realize that this is just a key lock, right?  It isn't electronic.  Emags aren't magic."))

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/device/key/filing_cabinet))
			if (src.open)
				return
			src.locked = !src.locked
			if (locked)
				src.name_prefix("locked")
			else
				src.remove_prefixes("locked")

			src.UpdateName()

			user.visible_message("<b>[user]</b> [src.locked ? "" : "un"]locks [src].", "You [src.locked ? "" : "un"]lock [src].")
			return

		return ..()

	allowed(mob/user)
		return user && istype(user.equipped(), /obj/item/device/key/filing_cabinet)


/obj/storage/secure/filing_cabinet/lunarium
	locked = 1
	var/stuffHasBeenSpawned = 0

	attackby(obj/item/I, mob/user)
		var/oldlocked = src.locked	//This is all to stop them from just blowing the cabinet open or something.
		. = ..()
		if (!stuffHasBeenSpawned && oldlocked && !src.locked)
			stuffHasBeenSpawned = 1
			new /obj/item/paper/lunarium1 (src)
			new /obj/item/paper/lunarium2 (src)

//Myserious!! documents for said nerdazoids
/obj/item/paper/lunarium1
	name = "paper- 'listing #5'"
	info = {"<tt>PR4 ROM LISTING -- PAGE 5
<br>0119+  E09A A9 10       	LDA #ROM_VERSION
<br>0120+  E09C 20 36 E8    	JSR VOICE_OUTPUT_HEX
<br>0121+  E09F
<br>0122+  E09F             	;Check if there's an existing task to return to.
<br>0123+  E09F A5 1C       	LDA ZP_BATRAM_SET0	;Can't have an existing task if the battery-capable RAM isn't even set up.
<br>0124+  E0A1 C9 AA       	CMP #$AA
<br>0125+  E0A3 D0 1F       	BNE _NO_EXISTING_MODEL
<br>0126+  E0A5 A5 1D       	LDA ZP_BATRAM_SET1
<br>0127+  E0A7 C9 55       	CMP #$55
<br>0128+  E0A9 D0 19       	BNE _NO_EXISTING_MODEL
<br>0129+  E0AB
<br>0130+  E0AB A5 1A       	LDA ZP_OS_STATA
<br>0131+  E0AD 89 10       	BIT #OS_STAT_TASK_ACTIVE
<br>0132+  E0AF F0 03       	BEQ _NO_EXISTING_TASK
<br>0133+  E0B1 6C 18 40    	JMP (TASK_MAIN_ENTRY)
<br>0134+  E0B4
<br>0135+  E0B4             _NO_TASK:
<br>0136+  E0B4             _NO_EXISTING_TASK:
<br>0137+  E0B4 89 04       	BIT #OS_STAT_MODEL_PRESENT 	;Or a model task to load up.
<br>0138+  E0B6 F0 0C       	BEQ _NO_EXISTING_MODEL
<br>0139+  E0B8
<br>0140+  E0B8 20 3A E6    	JSR TASK_RELOAD_FROM_MODEL ;Attempt to load the task...
<br>0141+  E0BB
<br>0142+  E0BB A9 40       	LDA #OS_STAT_ERROR 	;Did it load properly?
<br>0143+  E0BD 14 1A       	TRB ZP_OS_STATA
<br>0144+  E0BF D0 03       	BNE _NO_EXISTING_MODEL;Branch if it didn't load properly.
<br>0145+  E0C1
<br>0146+  E0C1 6C 18 40    	JMP (TASK_MAIN_ENTRY)
<br>0147+  E0C4
<br>0148+  E0C4             _NO_EXISTING_MODEL:
<br>0149+  E0C4             	;Initialize OS STAT by clearing it.  RAM tests will handle the bank information.
<br>0150+  E0C4 64 1A       	STZ ZP_OS_STATA
<br>0151+  E0C6 A9 AA       	LDA #$AA
<br>0152+  E0C8 85 1C       	STA ZP_BATRAM_SET0
<br>0153+  E0CA 46 00       	LSR ;$AA>>1 = $55
<br>0154+  E0CC 85 1D       	STA ZP_BATRAM_SET1
<br>0155+  E0CE
<br>0156+  E0CE A9 FD       	SAY(msg_test_mem)
<br>0156+  E0D0 85 11
<br>0156+  E0D2 A9 9B
<br>0156+  E0D4 85 10
<br>0156+  E0D6 20 ED E7"}

/obj/item/paper/lunarium2
	name = "paper- 'memo #913'"
	info = {"<h3 style="border-bottom: 1px solid black; width: 80%;">Thinktronic Data Systems</h3>
<tt>
<strong>MEMORANDUM &nbsp; &nbsp; * CONFIDENTIAL *</strong><br>
<br><strong>DATE:</strong> 02/18/45
<br><strong>FROM:</strong> TOCZYLOWSKI, J.
<br><strong>TO:&nbsp&nbsp;</strong> VOLKHEIM, L
<br><strong>SUBJ:</strong> SOLAR OBSERVATION PROJECT CHANGE
<br>
<br>Owing to recent revelations on the nature of the recovered devices,
<br>further study has been reassigned to a more capable and secure facility.
<br>Equipment will be moved within the next two weeks and normal operation will resume.
<br>
<br>NT is pleased with the results of your work and has renewed their contract.
<br>TDS thanks the research and engineering teams for their hard work.
</tt>"}
