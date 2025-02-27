/*
Hemera VII Stuff
Contents:
Hemera Areas
Hemera Mainframe stuff
Obsidian Crown
*/

/area/h7
	name = "Hemera VII"
	icon_state = "yellow"
	sound_environment = 12
	teleport_blocked = 1
	skip_sims = 1
	sims_score = 30

/area/h7/computer_core
	name = "Aged Computer Core"
	icon_state = "ai"
	sound_environment = 3
	skip_sims = 1
	sims_score = 30

/area/h7/control
	name = "Control Room"
	icon_state = "purple"
	sound_environment = 3
	skip_sims = 1
	sims_score = 30

/area/h7/lab
	name = "Anomalous Materials Laboratory"
	icon_state = "toxlab"
	sound_environment = 10
	skip_sims = 1
	sims_score = 30

/area/h7/crew
	name = "Living Quarters"
	icon_state = "crewquarters"
	sound_environment = 2
	skip_sims = 1
	sims_score = 30

/area/h7/storage
	name = "Equipment Storage"
	icon_state = "storage"
	sound_environment = 2
	skip_sims = 1
	sims_score = 30

/area/h7/asteroid
	name = "Shattered Asteroid"
	icon_state = "green"
	skip_sims = 1
	sims_score = 30

//Mainframe stuff for the H7 spacejunk.
/obj/machinery/networked/mainframe/h7
	setup_drive_type = /obj/item/disk/data/memcard/h7

/obj/item/disk/data/memcard/h7
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
		newfolder.add_file( new /datum/computer/file/mainframe_program/h7init(src) )

		var/datum/computer/folder/subfolder = new /datum/computer/folder
		subfolder.name = "drvr" //Driver prototypes.
		newfolder.add_file( subfolder )
		//subfolder.add_file ( new FILEPATH GOES HERE )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/databank(src) )
		//subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/printer(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/nuke(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/guard_dock(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/radio(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/secdetector(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/apc(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/hept_emitter(src) )
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
		newfolder.add_file( new /datum/computer/file/mainframe_program/hept_interface(src) )
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
		testR.fields += "Hemera Research System Distribution"
		newfolder.add_file( testR )

		newfolder.add_file( new /datum/computer/file/record/dwaine_help(src) )

		newfolder = new /datum/computer/folder
		newfolder.name = "etc"
		newfolder.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER
		src.root.add_file( newfolder )

		newfolder.add_file( new /datum/computer/file/guardbot_task/bodyguard(src) )
		newfolder.add_file( new /datum/computer/file/guardbot_task/security(src) )

		return

/obj/item/disk/data/tape/h7_logs
	name = "ThinkTape-'Logs'"
	desc = "A reel of magnetic data tape containing various log files."

	New()
		..()
		src.root.add_file( new /datum/computer/file/record/h7_analysislog(src) )
		src.root.add_file( new /datum/computer/file/record/h7_memo1(src) )
		src.root.add_file( new /datum/computer/file/record/h7_memo2(src) )
		src.root.add_file( new /datum/computer/file/record/h7_memo3(src) )

/obj/item/disk/data/tape/nuke
	name = "ThinkTape-'CAUTION'"
	desc = "A reel of magnetic data tape with a big warning on the label."

	New()
		..()
		src.root.add_file( new /datum/computer/file/mainframe_program/nuke_interface(src) )

//
/datum/computer/file/record/h7_analysislog
	name = "analysis_log"

	New()
		..()
		src.fields = list("-----------------|HEAD|-----------------",
"Object Analysis Log - TH JUN 09 2050",
"SITE: 1801-VM HEMERA VII",
"SUBJECT: 1801-VM MA-1",
"-------------|TEST RESULTS|-------------",
"FALD-MS: Inconclusive",
"EBSD: Orientation recorded in doc 3901-A",
"Electroanalysis: Insulative.",
"GOOD LOOK-OVER: Sorta resembles a crown.",
"HEPT: Scheduled JUN 11 2050",
"--------------|MISC NOTES|--------------",
"1801-VM MA-1 resembles a black crown, it",
"looks almost manufactured, but the odd",
"properties it exhibits and the relative",
"complexity of design fully elimate the",
"possibility of it having been fabricated",
"by the miners here.",
"Analysis results thus far have been",
"frustratingly inconclusive, though it is",
"speculated that it is similar in compos-",
"ition to highly-refined FAAE composites.",
"----------------------------------------")

/datum/computer/file/record/h7_memo1
	name = "1281"

	New()
		..()
		src.fields = list("-----------------|HEAD|-----------------",
"MEMORANDUM 1.281 - MO MAY 30 2050",
"TO: H7 Research Staff",
"FROM: Jack Tott, Stations Manager",
"SUBJECT: Settling In",
"-----------------|BODY|-----------------",
"Good Morning, Team! I'm sure that by now",
"you've settled into your new workspace.",
"I'm sure you'll find the analysis lab",
"well-stocked and accomodating. A rather",
"fascinating object has revealed itself,",
"and I trust no-one more with uncovering",
"its worth than you.",
"",
"HARC put the telecrystal to work, I have",
"no doubt you can do the same here!",
"----------------------------------------")

/datum/computer/file/record/h7_memo2
	name = "1306"

	New()
		..()
		src.fields = list("-----------------|HEAD|-----------------",
"MEMORANDUM 1.306 - WE JUN 08 2050",
"TO: H7 Research Staff",
"FROM: Jack Tott, Stations Manager",
"SUBJECT: Urgency",
"-----------------|BODY|-----------------",
"Though I personally have only the utmost",
"faith in your collective abilities to",
"study this rare and fantastic find in",
"materials science, I must stress the",
"importance of determining a profitable",
"application for the 1801 artifact for",
"the Hemera Astral Research Corporation.",
"Nanotrasen's recent developments in the",
"way of matter transposition are, though",
"greatly inferior to our own telecrystal",
"products, alarmingly competitive w/r/t",
"unit cost.",
"",
"I do not mean to imply that a failure to",
"quickly find a use for this could leave",
"us all unemployed, but",
"well no that is exactly it. Good luck.",
"----------------------------------------")

/datum/computer/file/record/h7_memo3
	name = "1307"

	New()
		..()
		src.fields = list("-----------------|HEAD|-----------------",
"MEMORANDUM 1.307 - WE JUN 08 2050",
"TO: Doug Welker",
"FROM: Jack Tott, Stations Manager",
"SUBJECT: Promotion!",
"-----------------|BODY|-----------------",
"Congratulations, Doug! I am ecstatic to",
"say that your years of dedication to the",
"company have not gone unnoticed, and as",
"such, you have been assigned as the lead",
"manager for the Advertising and Design",
"division!",
"The first department project under your",
"lead is as follows: Creation of print ad",
"and associated campaign for our new Mk15",
"Rapid-Construction Device! The Mk15 is",
"being released on the tenth anniversary",
"of the release of our flagship RCD line.",
"(Should probably work that in!)",
"The contact information for the rest of",
"the department will be appended to this",
"memo! Good luck!",
"-------------|CONTACTS|-----------------",
"ERR 2 - No Other Personnel in Dept.",
"----------------------------------------")

//H7 Audiolog
/obj/item/device/audio_log/h7
	audiolog_messages = list("*harsh static*",
"-bringing the emitter online...now. Raising it up to full power. The crown is in position.",
"Can't call it that, Jack, go by the book.",
"Right, right, fine. Eighteen-Oh-One Vee-Em Em-Ay-One is in position. That better?",
"Alright, crown. Crissakes, Jack.",
"*harsh static*",
"I'm getting some bad harmonics on the readout here, either the sensors are out or-",
"*electrical crackle*",
"holy mother of God, what is th-",
"*static*")
	audiolog_speakers = list("???",
"Unknown Man",
"Other Man",
"Jack",
"Other Man",
"???",
"Jack",
"???",
"Jack",
"???")

/obj/item/paper/hept_qr
	name = "paper- 'HEPT Quick-Reference'"
	info = {"<center><h3>HEPT Interface Quick Reference</h3></center><hr>
<h4>Basics</h4>
<ul>
<li>HEPT Interface Program "HEPTMAN" is located in the /bin directory, as such, it is treated as basic command and may be invoked from any position in the filesystem.</li>
<li>"HEPTMAN STATUS" will list activation status of emitter.</li>
<li>"HEPTMAN ACTIVATE" will send activation signal to emitter.</li>
<li>"HEPTMAN DEACTIVATE" will send deactivation signal to emitter.</li>
</ul>
<hr>
<h4>Activation Procedure</h4>
<ol>
<li>Insert 1-5 <b>Precut Telecrystal Modules</b> into inactive HEPT emitter.</li>
<li>Confirm that analysis equipment is in place and all emission lines are evacuated of personnel.</li>
<li>Log in to mainframe system on local terminal.</li>
<li>Enter command "HEPTMAN ACTIVATE"</li>
<li>Record results, etc.</li>
<li>Enter command "HEPTMAN DEACTIVATE"</li>
</ol>"}

//This is the Obsidian Crown. It just wants to be your friend and protect you :)
//Unfortunately, the crazy void energy or whatever it emits is lethal.
/obj/item/clothing/head/void_crown
	name = "obsidian crown"
	desc = "A crown, apparently made of obsidian, and also apparently very bad news."
	icon_state = "obcrown"
	blocked_from_petasusaphilic = TRUE
	magical = 1
	var/processing = 0
	var/armor_paired = 0
	var/max_damage = 0

	equipped(var/mob/user, var/slot)
		..()
		logTheThing(LOG_COMBAT, user, "equipped [src] at [log_loc(src)].")
		cant_self_remove = 1
		cant_other_remove = 1
		if (!src.processing)
			src.processing++
			processing_items |= src

		if (istype(user.reagents)) //Protect them from poisions! (And coincidentally healing chems OH WELL)
			user.reagents.maximum_volume = 0

		hear_voidSpeak("Hello, friend.")
		hear_voidSpeak("Your world is so dangerous! Let me help you.")

		user.bioHolder?.AddEffect("accent_void")

	unequipped(mob/user) //idk if this can even happen but :iiam:
		user.bioHolder?.RemoveEffect("accent_void")
		. = ..()

	process()
		var/mob/living/host = src.loc
		if (!istype(host))
			processing_items.Remove(src)
			processing = 0
			return

		if(isrestrictedz(host.z) && prob(0.5))
			hear_voidSpeak("...the sun...", "<small>", "</small>")
		var/area/A = get_area(src)
		if(A.type == /area/solarium && prob(3))
			if(prob(10))
				hear_voidSpeak("Let them touch the sun.")
			else
				hear_voidSpeak("THE SUN")

		if (armor_paired)
			if (armor_paired < 4 && prob(15))
				switch (armor_paired++)
					if (1)
						hear_voidSpeak("Greetings, new traveler!  My Friend and I, not wishing to pry, wonder what has brought you to our jolly band!")
					if (2)
						hear_voidSpeak("How wonderous!  Our newest friend shares our appetite for adventure!  I dub thee \"Journeyman.\"")
					if (3)
						hear_voidSpeak("How lucky you are, Friend, how truly blessed!  Companions guarding your form entirely from the risks of the material!")

		else if (ishuman(host) && istype(host:wear_suit, /obj/item/clothing/suit/armor/ancient))
			armor_paired = 1
			hear_voidSpeak("My, my, my, who is this?  A new companion on our pilgrimage?")

		var/obj/item/storage/toolbox/memetic/that_jerk = locate(/obj/item/storage/toolbox/memetic) in host
		if (istype(that_jerk)) //We do not like His Grace!!
			hear_voidSpeak("Oh dear, Friend! Why would you associate with such a Beast as that?  Let me help you--that Fiend seeks only your destruction!")
			host.u_equip(that_jerk)
			if (that_jerk)
				that_jerk.dropped(host)
				that_jerk.layer = initial(that_jerk.layer)
				elecflash(host,power = 3)
				if (isrestrictedz(host.z))
					return
				var/list/randomturfs = new/list()
				for(var/turf/T in orange(host, 25))
					if(!T.can_crossed_by(host))
						continue
					randomturfs.Add(T)
				boutput(host, SPAN_COMBAT("[that_jerk] is warped away!"))
				playsound(host.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)
				that_jerk.set_loc(pick(randomturfs))

		if (host.get_damage() < 0)
			src.abandonHost()
			return
		else if (prob(4) && (host.get_damage() < 50))
			hear_voidSpeak( pick("Carry on through the pain, Friend! Carry on through the pain! I shall protect always!","Have no fear, Friend! No fear, for only a fool would raise their hand against you!","Why do you slow, Friend? We still have much to see!") )
		else if (prob(4))
			hear_voidSpeak( pick("Be spry, Friend, be nimble! We shall visit all there is to visit and do all there is to do!","Let no ache delay you, for pain is transient! Luminous beings are not held back by such mortal things!","How fantastic this space is! I had grown so tired of immaterial things.") )

		//The crown takes retribution on attackers -- while slowly killing the host.
		if (host.lastattacker?.deref() && (host.lastattackertime + 40) >= world.time)
			if(host.lastattacker.deref() != host)
				hear_voidSpeak( pick("I shall aid, Friend!","No fear, Friend, no fear! I shall assist!","No need to raise your hand, I shall defend!") )

				var/mob/M = host.lastattacker.deref()
				if (!istype(M))
					return

				host.lastattacker = null
				elecflash(M,power = 4)
				var/list/randomturfs = new/list()

				if(isrestrictedz(M.z))
					for(var/turf/T in view(M, 4))
						if (!istype(get_area(M), /area/solarium)) //If we're in a telesci area and this is a change in area.
							continue
						if(T.density)
							continue
						for(var/atom/AT in T)
							if(AT.density)
								continue
						randomturfs.Add(T)
				else
					for(var/turf/T in orange(M, 25))
						if(T.density)
							continue
						for(var/atom/AT in T)
							if(AT.density)
								continue
						randomturfs.Add(T)

				if(length(randomturfs))
					boutput(M, SPAN_NOTICE("You are caught in a magical warp field!"))
					M.visible_message(SPAN_COMBAT("[M] is warped away!"))
					playsound(M.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)
					M.set_loc(pick(randomturfs))
					logTheThing(LOG_COMBAT, M, "is warped away by [constructTarget(host,"combat")]'s obsidian crown to [log_loc(M)].")

		if (armor_paired != -1 && prob(50) && host.max_health > 10)
			host.max_health--
			//Away with ye, all hope of healing.
			//random_brute_damage(host, 1)

		host.remove_stuns()
		host.dizziness = max(0,host.dizziness-10)
		host.changeStatus("drowsy", -20 SECONDS)
		host.sleeping = 0

		health_update_queue |= host
		return

	proc/hear_voidSpeak(var/message, var/prefix, var/suffix)
		if (!message)
			return
		var/mob/wearer = src.loc
		if (!istype(wearer))
			return
		var/voidMessage = voidSpeak(message)
		if (voidMessage)
			boutput(wearer, "[prefix][voidMessage][suffix]")
		return

	proc/abandonHost()
		var/mob/living/host = src.loc
		if (!istype(host))
			return

		if (armor_paired != 0 && ishuman(host))
			if (armor_paired != -1)
				armor_paired = -1
				host.is_npc = TRUE
				host.ghostize()
				if (istype(host.ghost))
					var/mob/dead/observer/theGhost = host.ghost
					theGhost.corpse = null
					host.ghost = null

			var/mob/living/carbon/human/humHost = host

			humHost.HealDamage("All", 1000, 1000)
			humHost.take_toxin_damage(-INFINITY)
			humHost.take_oxygen_deprivation(-INFINITY)
			humHost.remove_stuns()
			humHost.delStatus("radiation")
			humHost.take_radiation_dose(-INFINITY)
			humHost.take_eye_damage(-INFINITY)
			humHost.take_ear_damage(-INFINITY)
			humHost.take_ear_damage(-INFINITY, 1)
			humHost.health = 100
			humHost.buckled = initial(humHost.buckled)
			humHost.bodytemperature = humHost.base_body_temp

			humHost.stat=0

			humHost.full_heal()

			humHost.decomp_stage = DECOMP_STAGE_SKELETONIZED
			humHost.bioHolder.RemoveEffect("eaten")
			humHost.set_body_icon_dirty()
			humHost.set_face_icon_dirty()

			humHost.ai_init()

			return

		hear_voidSpeak("Time to leave already? Shame, shame, but what a time we had!")

		for(var/mob/N in viewers(host, null))
			N.flash(3 SECONDS)
			if(N.client)
				shake_camera(N, 6, 32)
				N.show_message(SPAN_COMBAT("<b>A blinding light envelops [host]!</b>"))

		playsound(src.loc, 'sound/weapons/flashbang.ogg', 50, 1)

		src.set_loc(get_turf(host))
		processing_items.Remove(src)
		processing = 0
		cant_self_remove = 1
		cant_other_remove = 1

		host.vaporize()

		return
