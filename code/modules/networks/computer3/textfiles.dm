//CONTENTS
//Computer3 Help Record
//Computer3 Test script config file
//Computer3 halloween event notes.
//Robot Factory notes.
//Old outpost notes.
//Icemoon notes
//Drone factory notes


/datum/computer/file/record/c3help
	name = "helplib"
	size = 2

	New()
		..()
		src.fields["topics"] = "General: cls, cd, dir, root, rename, copy, paste, makedir, title, delete, run, drive, read, print, login, logout, user, time<br>System Functions: help, logging, periph, backprog, accounts, version"
		src.fields["logging"] = "All console commands are logged in /logs/syslog.text by default. Initlogs re-activates logging if it has been disabled."
		src.fields["help"] = "Syntax: help \[topic].  Prints help message on topic, if possible.<br>Information stored on external helplib record file. <br> Getting Started: The DIR command will show you a list of files in your current directory. ROOT will return you to the root directory. CD / name will change to that directory (example: cd / bin). To run programs, use RUN filename (example: run commaster) or just type the filename. <br>Type \"help topics\" to see a listing of commands."
		src.fields["cls"] = "Clears the terminal screen."
		src.fields["initlogs"] = "Re-activates logging system if disabled."
		src.fields["dir"] = "Displays contents of current directory."
		src.fields["version"] = "Display OS version information."
		src.fields["read"] = "Syntax: \"read \[file name].\" Display contents of text file."
		src.fields["print"] = "Syntax: \"print \[text].\" Print text to screen."
		src.fields["rename"] = "Syntax: \"rename \[target file] \[new name].\"<br>Sets name of local file to the new name."
		src.fields["drive"] = "Syntax: \"drive \[drive id].\"<br>Common Valid IDs: (hd0, fd0).<br>Directory will be set to root of chosen drive"
		src.fields["root"] = "Sets working directory to root of current drive."
		src.fields["copy"] = "Syntax: \"copy \[file name].\" File must be in current directory.<br>Marks file for use with Paste command."
		src.fields["paste"] = "Syntax: \"paste \[new name].\"<br>Pastes copy of marked file, copy will have given name."
		src.fields["delete"] = "Syntax: \"delete \[file name].\" Deletes supplied file, if possible.<br>Alternative command: Del."
		src.fields["run"] = "Syntax: \"run \[program name].\" <br>If the string begins with a forward slash /, search will begin at root of current drive.  Otherwise, it will begin within the current directory.<br>Valid executable type: .TPROG"
		src.fields["periph"] = "Syntax: \"periph \[mode] \[ID] \[command] \[signal file]\"<br>Valid modes: (view, command)<br>View or send commands to active peripheral cards."
		src.fields["cd"] = "Syntax: \"cd \[directory string]\"<br>If the string begins with a forward slash /, search will begin at root of current drive.  Otherwise, it will begin within the current directory."
		src.fields["makedir"] = "Syntax: \"makedir \[new directory name]\"<br>Create a new directory with given name in working directory."
		src.fields["title"] = "Syntax: \"title \[title name]\"<br>Set name of active drive to given title."
		src.fields["accounts"] = "This system manages user accounts to support user accountability.  Login to log in, logout to log out. A valid ID is required.<br>User data is stored in /logs/sysusr by default."
		src.fields["login"] = "Syntax: \"login\" Cannot be used with an account still active.<br>This will scan the card(s) in any active card scanner modules."
		src.fields["logout"] = "Syntax: \"logout\" This will clear the active account and place the system on standby."
		src.fields["backprog"] = "Syntax: \"backprog \[mode] \[ID]\"<br>Valid modes: (view, kill, switch)<br>Used to view, switch to, and terminate running programs in memory."
		src.fields["user"] = "Display current user account data, if applicable."
		src.fields["time"] = "Display current system time."


//Halloween Notes:
/datum/computer/file/text/hjam_rlog_1
	name = "Log 489-C"

	data = {"Specimen ID: D078-48-E
			<br>File ID: 489-<u> C</u>
			<br>Researcher: Dr. Horace K Jam
			<br>Date: 11/14/2048
			<br>
			<br>Description: 078-48 is physically a small iron key of unknown
			origin, though dating tests place it as 75 to 100 years old.  078-48 was
			first discovered by a mining team in the vicinity of Nanotrasen Space
			Station #\[REDACTED].  Its anomalous nature was demonstrated upon
			collision with their mining vehicle, at which point it caused a major hull
			breach.
			<br>078-48 has the strange ability to "tunnel" a temporary door through
			the hulls of space vessels.  Upon physical contact with such a structure, if
			used in the manner of an ordinary key being inserted into a lock, 078-48 will
			seem to phase into the solid material.  Upon attempted removal, the structure
			will partially give way, acting as though it is a hinged door with 078-48 as
			its handle.  Once 078-48 is removed and the door is closed, the structure will
			shift back to its initial state as though the door had never existed.
			<br>
			<br>Testing Log:
			<br>Test 01:
			<br>078-48 is given to Agent L. Wilson.  Agent Wilson is instructed to press
			078-48 into a replica external hull module affixed to the center of test chamber
			A.  078-38 behaves as expected and the hull module functions as a door until
			removal.
			<br>Test 02:
			<br>078-48 is again given to Agent L. Wilson.  Agent Wilson is instructed to press
			078-48 into a new replica hull module with the twice the thickness of a standard
			wall.  078-48 successfully creates a doorway, however it only pierces halfway through
			the wall structure, suggesting a range limit to 078-48's capabilities.  Holding the initial
			door open, Agent Wilson is able to create a second doorway, fully extending the passage
			though the module.  Upon closure of both doors, the hull module reintegrates as expected.
			<br>Test 03:
			<br>078-48 is given to Test Subject 0239F.  0239F is instructed to press
			078-48 into the surface of an iron sphere roughly ten feet in diameter.
			Upon use, 078-48 creates a rectangular doorway that does not fully pierce the
			sphere.  0239F is instructed to enter the doorway.  After electro-coercion,
			0239F enters the sphere.  078-48 is then removed by Lab Attendant Moore and
			the doorway is closed.  Upon the reapplication of 078-48, the sphere \[REDACTED].
			<br>
			<br>Addendum A:
			<p>After the events of Test 03, 078-48 has had its hazard rating incremented.
			All further tests of 078-48 are to be authorized by the Extradimensional Hazard Evaluation
			Board before proceeding.</p>
			-Dr. Jam<br>
			<br>Addendum B:
			<p>At the behest of the weapon research division, 078-48 has been
			scheduled for use in a test of the K25 experimental particle emitter.
			078-48 has been chosen due to interest in the effects such particles
			may have on its space-time warping abilities.</p>
			-Dr. Franklin<br>
			<br>Addendum C:
			<p>Since its exposure to the K25 emitter, 078-48 has not regained
			any of the anomalous characteristics warranting its inclusion in study.
			As such, 078-48 has been reclassified as Decommissioned and is to
			be disposed of in a manner befitting of an ordinary iron key.  As an aside,
			Dr. Franklin's remaining limbs have not yet regained sensation or fine motor
			control. Please be more careful when testing E-level objects in the future.</p>
			-Dr. Jam"}

/datum/computer/file/text/hjam_rlog_2
	name = "Log 491-D"

	data = {"Specimen ID: 081-48-K
			<br>File ID: 491-<u> D</u>
			<br>Researcher: Dr. Richard L. Northup
			<br>Date: 12/24/2048
			<br>
			<br>Description: 081-48 consists of a luminescent green liquid. 081-48 is extremely
			toxic if ingested but harmless if correct containment procedures are maintained.
			<br>Please contact <u> Dr. Northup </u> to requisition the use of 081-48 in a controlled test.
			<br>081-48 is remarkable for its effects on deceased biological matter.
			Upon sufficient contact or injection into such matter, 081-48 rapidly \[REDACTED].
			<br>081-48 and all chemical agents related to its creation should be kept in appropriate, clearly-labeled containers.
			CAUTION: Release of 081-48 is grounds for immediate scuttling of the research facility under Directive 7-12.
			<br>
			<br>Testing Log:
			<br>Test 01:
			<br>081-48 is given to Medical Technician F. Jackson.  Technician Jackson is instructed to inject
			081-48 into Test Subject 1013B.  Ten minutes after injection, Subject 1013B experiences servere convulsions, followed
			by clinical death twenty-one minutes later.  1013B's corpse is observered for a period of five hours, 22 minutes, 45 seconds.
			Test chamber purge systems are activated and the chamber is sterilized.
			<br>Test 02:
			<br>081-48 is given to Medical Technician K. Horvitz.  Technician Horvitz is instructed to administer
			25ml of 081-48 solution to Donated Corpse 011-FJ.  Technician Horvitz administers solution as expected and is then
			instructed to leave the chamber.  He does not make to the internal airlock, however, as \[REDACTED].
			Test chamber purge systems are unable to be activated, as the damaged chamber windows could collapse fully.
			Containment team Gamma-11 is dispatched.  Chamber sterilization proceeds as planned.
			<br>
			<br>Addendum A:
			<p>Due to the excessive damages incurred following the escape of 081-48-E-1 and its subsequent discovery of the
			station morgue, I have been forced to
			postpone all further tests of 081-48 indefinitely. Furthermore, 081-48's hazard rating has been elevated to
			the highest possible level.</p>
			-Dr. Northup<br>
			<br>Addendum B:
			<p>This is nothing more than an overreaction. 081-48's potential benefits outweigh its dangers
			by far.  The Institute stands only to gain from this, your attempts at decommissioning such a sample
			have cost days of valuable research.</p>
			-Dr. Jam<br>
			<br>Addendum C:
			<p>Dr. Jam, the fallout of test 02 almost destroyed not only Outpost Gamma's funding,
			but almost the station itself.  081-48 is far too dangerous to retain, a release of even a single drop could
			cause an outbreak and potential EOW scenario.  By the authorization of the council, 081-48 is to be decommissioned.</p>
			-Dr. Northup
			<br>Addendum D:
			<p>Despite the best efforts of the decommissioning teams, one container of 081-48 has not yet been located.
			All personnel are to remain on high alert, contact station HAZSEC teams immediately if 081-48 or its progeny are located.</p>
			-Dr. Northup"}

/datum/computer/file/text/hjam_rlog_3
	name = "Log 492-A"

	data = {"Specimen ID: 082-48-E
			<br>File ID: 492-<u> A</u>
			<br>Researcher: Dr. Richard L. Northup
			<br>Date: 12/25/2048
			<br>
			<br>Description: 082-48 consists of a vintage jukebo3*#0()#($*
			<br><pre>  3893 *#(* $(09 #**** $&&NJFK ,,,11100f4//ief
			<br> 39jf 3kkk <NM<n fr930 f--j,vm +fpkeo ??Fje
			<br> #8r83T930___ro  BU sT erS-3890-
			<br>39.,&&&390--,fe.289498fJAM IS R838f0UNNING-300SCARED</pre>
			<br>
			<br><center>File Corruption Detected</center>"}

/datum/computer/file/text/hjam_passlog
	name = "Passwords"

	data = {"Note to self: Don't let anyone else see this file.
			<br>
			<br>Company Intranet:
			<br>1c3CR34m-1999
			<br>
			<br>Company Email:
			<br>hjam@ntmedrs.org
			<br>pass: eyEceCr34m
			<br>
			<br>Personal Email:
			<br>neowizrad1999@cheapnets.com
			<br>pass: icecream
			<br>
			<br>Company Gun Locker:
			<br>54321
			<br>
			<br>trying to pitch upgrade to 8 character model 51 alphanumeric locker."}

/datum/computer/file/text/outpost_rlog_1
	name = "Log 014"

	data = {"File ID: 014-1-1
			Researcher: Dr. William K. Mutambara
			<br>Date: 08/16/2052
			<br>
			<br>Scenario: Test Subject 11F will be placed within VR simulation 3.2.5 and observed to determine
			competency under such extreme conditions.  To maintain validity of subject reactions, 11F must not be informed of
			3.2.5's scenario parameters, instead being lead to believe that the tested disaster is a minor shuttle docking accident.
			<br>
			<br>Testing Log:
			<br>\[0:00:30] Subject 11F successfully virtualized, taking Head of Personnel role on Nanotrasen Installation 11.
			<br>\[0:08:11] Collision in shuttle bay.  11F moves to mobilize medical response and assess damage.  Performance considered commendable.
			<br>\[0:17:48] Initial sighting of antagonist entities within damaged sector.
			<br>\[0:21:03] 11F receives reports of antagonist entities, but disregards them.  His reaction is disappointing, but expected.
			<br>\[0:00:00] LOG ERR<pre>0102-    A=82 X=5B Y=EF P=B4 S=83
			<br> *
			<br>39.,&&&390--,fe.28949IS R838f0U-300ED</pre>
			\[1:03:29] Simulation terminated due to death of subject.
			<br>\[1:04:55] Subject 11F not responsive to APA-mandated debriefing session."}

/datum/computer/file/text/outpost_rlog_2
	name = "Log 017"

	data = {"File ID: 017-1-4
			<br>Researcher: Dr. William K. Mutambara
			<br>Date: 08/23/2052
			<br>
			<br>Scenario: Test Subject 19Q will be placed within VR simulation 3.2.7 and observed to determine
			effect of new revision on subject behavior.  19Q will have cognitive locks enabled to prevent motivation contamination by
			memories of previous run in simulation.
			<br>
			<br>Testing Log:
			<br>\[0:00:28] Subject virtualized successfully in role of Chief Engineer on Nanotrasen Installation 11.
			<br>\[0:04:39] 19Q trips while exiting office and impacts his head on a table, losing consciousness.
			<br>\[0:08:11] Collision in shuttle bay.  19Q fails to respond.
			<br>\[0:17:48] Initial sighting of antagonist entities within damaged sector.
			<br>\[0:35:02] Station cat begins to sleep on face of Subject 19Q.
			<br>\[1:40:21] Simulation terminated due to suffocation death of subject."}


/datum/computer/file/text/icemoon_log1
	name = "Log 001"

	data = {"File ID: THETA-001
			<br>User: *SYSTEM
			<br>Timestamp: 000001
			<br>
			<br>###########################
			<br>Systems diagnostic complete.
			<br>Computer system booted and ready for usage.
			<br>Network integrated successfully.
			<br>###########################
			<br>"}

/datum/computer/file/text/icemoon_log2
	name = "Log 002"

	data = {"File ID: THETA-002
			<br>User: B.FREDRICKKSEN \[DIRECTOR]
			<br>Timestamp: 000006
			<br>
			<br>Looks like the engineering boys did a pretty good job setting this place up. I don't much care for the lack of decor, but it's not like we're on vacation.
			It's dark as hell out there from the cloud cover and the atmosphere isn't even breathable, not to mention the freezing temperatures and constant high winds.
			A wonder they ever managed to build this little piece of home in the first place.
			<br>
			<br>Tomorrow we'll begin taking ice core samples from the glacial interior. NT wants us to check out some sort of biological scans that their last probe picked up.
			<br>"}

/datum/computer/file/text/icemoon_log3
	name = "Log 003"

	data = {"File ID: THETA-003
			<br>User: R.BROWN \[TECHNICIAN]
			<br>Timestamp: 000006
			<br>
			<br>god what a hellhole
			<br>stuck on this shitty little ice station with 4 other guys and no ladies for six months, oh well at least were being paid creds hand over fist for being here
			<br>plus i managed to smuggle some wiskey in hahaha gonna need it
			<br>"}

/datum/computer/file/text/icemoon_log4
	name = "Log 004"

	data = {"File ID: THETA-004
			<br>User: B.FREDRICKKSEN \[DIRECTOR]
			<br>Timestamp: 000008
			<br>
			<br>We discovered some sort of indigenous arachnid lifeform today. Technician Brown's hazard suit is a total loss and he's sustained major frostbite around several puncture wounds,
			but we've managed to recover something that was caught in his suit. It looks to be a broken-off leg of whatever attacked him, some sort of spider-like creature.
			<br>
			<br>Microscopic analysis reveals a crystalline matrix of living cells, functioning together as a colony instead of a single organism. Not unlike a slime mold.
			<br>They are clearly adapted for living in this environment - they show an extreme tolerance for low temperature environments, though will recoil very quickly from any source of significant heat.
			The genetic structure of these cells is unlike anything we've ever seen before - we're still trying to figure out what exactly to call them.
			<br>Further tests will commence soon. We are planning to separate the cells into various cultures for further research."}


/datum/computer/file/record/dronefact_log1
	name = "SR0210A"

	New()
		..()

		fields = list("Service Request #02-10A",
		"Problem description: DRONE WILL NOT STOP FIRING",
		"IT KEEPS FIRING INTO THE WALL AND IT'S GOING TO BREACH THIS WHOLE DAMN PLACE IF IT DOESN'T STOP",
		"I TRIED CUTTING THE POWER BUT IT'S STILL GOING",
		"IT ISN'T RESPONDING TO COMMANDS",
		"I THINK JENKINS IS DEAD",
		"Problem status: Resolved",
		"Technician notes: Maintenance bay evacuated and drone ejected into space.")

/datum/computer/file/record/dronefact_log2
	name = "SR0220C"

	New()
		..()
		fields = list("Service Request #02-20C",
		"Problem description: Drone unable to identify targets.",
		"A more accurate description is that it is unable to identify enemy targets.",
		"All targets are being mistakenly identified as friendly, even those that",
		"are actively firing upon and damaging it.",
		"Problem status: Resolved (effectively)",
		"Technician notes: Attempts to repair IFF system resulted in all targets",
		"being mis-identified as threats.  Drone destroyed before staff could be",
		"injured.")

/datum/computer/file/record/dronefact_log3
	name = "IRIDIUM"

	New()
		..()
		fields = list(" *** CONFIDENTIAL DOCUMENT *** ",
			" ** TOP EYES ONLY, FOR REAL **",
			"Project IRIDUM is comprised of three core technologies, all of which",
			"have been developed from anomalous archeological findings on moon",
			"LV-0723 (As detailed in incident report 291.53).  These technologies",
			"consist of a powerful projected energy weapon, manifesting as an orb",
			"of plasma which collapses in a threatening electromagnetic burst shortly",
			"after removal from a containment field; a range of advanced propulsion",
			"systems derived from that same form of plasmatic technology; and a",
			"coffee maker that uses an electrostatically-confined plasma field to",
			"successfully keep coffee warm without creating a burned flavor.",
			"",
			"Two of these technologies are utilized in a 'Y Drone' testbed project,",
			"built in the frame of the existing Omega-class superheavy drone.")


/////////////////TEMPUS//////////////////


/datum/computer/file/text/tempus_corruption
	name = "***ERROR***"

	data = {"<center>###ERROR READING FILE###</center>
			 <br><center>DATE AND TIME DATA POINT TO IMPOSSIBLE VALUE</center>
			 <br><center>####################################</center>
			 <br>
			 <br><center>ERROR - SPECIFIED FILE DOES NOT EXIST</center>"}

/datum/computer/file/text/tempus_reception1
	name = "urgent"

	data = {"<center><b>Alert Received 11:57</b></center>
			<br>do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment.
			do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment.
			do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment.
			do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment.
			do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment.
			do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. do not run the experiment. "}

/datum/computer/file/text/tempus_reception2
	name = "experiment"

	data = {"<center><b>Alert Received 12:03</b></center>
			<br>The experiment is about to begin.
			<br>Please seal the building."}

/datum/computer/file/text/tempus_dorms_emma_email1
	name = "Noises in the walls"

	data = {"To: Kennedy Grey
			<br>I keep hearing noises inside the walls late at night.
			<br>Normally I don't care about this stuff but it sometimes sounds like whispering and I'm starting to get worried.
			<br>I know there are rumours going around that the site is haunted but...
			<br>Well can you just check it out to put my mind at ease?"}

/datum/computer/file/text/tempus_dorms_emma_email2
	name = "Re:Re:Noises in the walls"

	data = {"To: Kennedy Grey
			<br>It's not a fucking rat william! Rats don't whisper!
			<br>We don't even have rats on this planet!
			<br>You're supposed to be head of security. Do your damn job!"}

/datum/computer/file/text/testlab3_1
	name = "experiment_1"

	data = {"Subject Status: Deceased
			<br>Subject was instructed to interact with the material
			<br>
			<br>Upon contact, the subject began to age rapidly before collapsing.
			<br>Cause of death: Old Age
			<br>
			<br>Observations: Direct interaction with the material is not advised."}

/datum/computer/file/text/testlab3_3
	name = "experiment_3"

	data = {"Subject Status: Deceased
			<br>Subject was targeted with a direct beam of energy from the material
			<br>
			<br>Subject was terminated instantly and reduced to dust.
			<br>So was everybody in the next lab over.
			<br>
			<br>Observations: Invest in stronger shielding equippment."}
