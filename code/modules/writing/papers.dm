// This file is for premade paper/pamphlet things

//the size of the paper includes the 32px wide bar at the top, so we need to account for that here if we want the image to fit exactly
#define IMAGE_OFFSET_X 0 //x one kept just in case and because I like symmetry :)
#define IMAGE_OFFSET_Y 32

/obj/item/paper/alchemy
	name = "'Chemistry Information'"

/// Cloning Manual -- A big ol' manual.
/obj/item/paper/Cloning
	name = "H-87 Cloning Apparatus Manual"
	info = {"<h4>Getting Started</h4>
	Congratulations, your station has purchased the H-87 industrial cloning device!<br>
	Using the H-87 is almost as simple as brain surgery! Simply insert the target humanoid into the scanning chamber and select the scan option to create a new profile!<br>
	<b>That's all there is to it!</b><br>
	<i>Notice, cloning system cannot scan inorganic life or small primates.  Scan may fail if subject has suffered extreme brain damage.</i><br>
	<p>Clone profiles may be viewed through the profiles menu. Scanning implants a complementary CLONING RECORDS IMPLANT into the subject, which may be viewed from the cloning console.
	Profile Deletion has been restricted to \[Station Head\] level access.</p>
	<h4>Cloning from a profile</h4>
	Cloning is as simple as pressing the CLONE option to the right of the desired profile.<br>
	Per your company's EMPLOYEE PRIVACY RIGHTS agreement, the H-87 has been blocked from cloning crewmembers while they are still alive.<br>
	<br>
	<p>The provided CLONEPOD SYSTEM will produce the desired clone.  Standard clone maturation times (with SPEEDCLONE technology) are roughly 90 seconds.
	The cloning pod may be unlocked early with any \[Medical Researcher\] ID after initial maturation is complete.</p><br>
	<i>Please note that resulting clones may have a small DEVELOPMENTAL DEFECT as a result of genetic drift.</i><br>
	<h4>Profile Management</h4>
	<p>The H-87 (as well as your station's standard genetics machine) can accept STANDARD DATA DISKETTES.
	These diskettes are used to transfer genetic information between machines and profiles.
	A load/save dialog will become available in each profile if a disk is inserted.</p><br>
	<i>A good diskette is a great way to counter aforementioned genetic drift!</i><br>
	<br>
	<font size=1>This technology produced under license from Thinktronic Systems, LTD.</font>"}

/obj/item/paper/Wizardry101
	name = "examine- Wizardry 101"
	info = {"<center>Wizardry 101</center><hr>Essentials:<br><br>
	<li>Wizard's hat</li><dd><i>- Required for spellcasting, snazzy. Don't let others remove it from you!</i></dd>
	<li>Wizard's robe</li><dd><i>- Required for spellcasting, comfy. Don't let others remove it from you!</i></dd>
	<li>Magic sandals</li><dd><i>- Keeps you from slipping on ice and from falling down after being hit by a runaway segway. They also double as galoshes.</i></dd>
	<li>Wizard's staff</li><dd><i>- Your spells will be greatly weakened, not last as long and take longer to recharge if you cast them without one of these. The staff can be easily lost if you are knocked down!</i></dd>
	<li>Teleportation scroll</li><dd><i>- Allows instant teleportation to an area of your choice. The scroll has four charges. Don't lose it though, or you can't get back to the shuttle without knowing the <b><i>teleport</b></i> spell, or dying while <b><i>soulguard</b></i> is active!</i></dd>
	<li>Spellbook</li><dd><i>- This is your personal spellbook that gives you access to the Wizarding Archives, allowing you to choose 4 spells with which to complete your objectives. The spellbook only works for you, and can be discarded after its uses are expended.</i></dd>
	<br><br><br><hr>Spells every wizard starts with:<br><br>
	<li>Magic missile (20 seconds)</li><dd><i>- This spell fires several slow-moving projectiles at nearby targets. If they hit a target, it is stunned and takes minor damage.</i></dd>
	<li>Phase shift (30 seconds)</li><dd><i>- This spell briefly turns your form ethereal, allowing you to pass invisibly through anything.</i></dd>
	<li>Clairvoyance (60 seconds)</li><dd><i>- This spell will tell you the location of those you target with it. It will also inform you if they are hiding inside something, or are dead.</i></dd>
	<br><br><br>Click the question mark in your <b>spellbook</b> to learn more about certain spells.<br>Recommended loadout for beginners: <b><i>ice burst, blink, shocking touch, blind</i></b>
	<br><br><br><center>Remember, the wizard shuttle is your home base.<br>There is a vendor and wardrobe here to dispense backup wizardly apparel and staves, a <b>Magix System IV</b> computer to teleport you into the station, and this is your safe point of return if you are killed while the <b><i>soulguard enchantment</b></i> is active.
	<br><br><br>A good wizard fights cautiously and defensively. Keep your distance from able-bodied enemies whenever possible, and you will survive much longer. Sometimes misdirection is more useful than outright destruction, but don't be afraid to fling a fireball if you're sure it won't explode right in your face!</center><br>"}

/obj/item/paper/Internal
	name = "'Internal Atmosphere Operating Instructions'"
	info = "Equipment:<BR>\n\t1+ Tank(s) with appropriate atmosphere<BR>\n\t1 Gas Mask w regulator (standard issue)<BR>\n<BR>\nProcedure:<BR>\n\t1. Wear mask<BR>\n\t2. Attach oxygen tank pipe to regulator (automatic))<BR>\n\t3. Set internal!<BR>\n<BR>\nNotes:<BR>\n\tDon't forget to stop internal when tank is low by<BR>\n\tremoving internal!<BR>\n<BR>\n\tDo not use a tank that has a high concentration of toxins.<BR>\n\tThe filters shut down on internal mode!<BR>\n<BR>\n\tWhen exiting a high danger environment it is advised<BR>\n\tthat you exit through a decontamination zone!<BR>\n<BR>\n\tRefill a tank at a oxygen canister by equiping the tank (Double Click)<BR>\n\tthen 'attacking' the canister (Double Click the canister)."

/obj/item/paper/Court
	name = "'Judgement'"
	info = "For crimes against the station, the offender is sentenced to:<BR>\n<BR>\n"

/obj/item/paper/HangarGuide
	name ="'Ship Basics'"
	info ={"In order to open the hangar doors, either look-up the password via the hangar control computer, or use the handy button near every hangar to get it.<BR>
		In order to uninstall and install parts use a crowbar on a ship to open the maintenance panel, If you want to install a part, simply use the part on the ship.
		If you want to uninstall a part simply use an empty hand on the maintenance panel. Make sure to close the panel when you are done.<br>
		In order to use the cargo loader on a crate, simply make ensure the crate is behind the ship, and the loader will handle the rest."}

/obj/item/paper/cryo
	name = "'Cryogenics Instruction Manual'"
	fonts = list("Special Elite" = 1)
	info = {"<h4><center><span style='font-family: Special Elite, cursive;'>NanoTrasen Cryogenics Chambers<br>Instruction Manual</span></center></h4>
	All NanoTrasen spaceships are equipped with multiple cryogenics tubes, meant to store and heal critically wounded patients using cryoxadone. Use this guide for proper
	setup and handling instructions.<br><br>
	<h4>Setting Up the Cryogenics Chambers</h4>
	<ol type="1">
	<li>Secure a filled canister of O2 or another suitable air mixture to the attached connector using a wrench.</li>
	<li>Add a 50-unit supply of cryoxadone to each of the two cryogenics chambers. There should be two nearby beakers for this purpose; if they are missing or empty, it is recommended
	that a request be sent to the Research Department to synthesize an additional supply.</li>
	<li>Set the freezer to the lowest possible temperature setting (73.15 K, the default) if necessary.</li>
	<li>Turn on the power on the freezer and leave it on.</li>
	<li>One can add a defibrillator to attempt to revive subjects as well.</li>
	</ol>
	Note that the supply of cryoxadone will not deplete unless there is a patient present in the cryogenics chamber. However, the oxygen slowly depletes if the cryogenics chambers
	themselves are turned on, so it is recommended to leave them switched off unless a patient is present.<br><br>
	<h4>Treating a Patient Using the Cryogenics Chambers</h4>
	<ol type="1">
	<li>Stabilize the patient's health using CPR or cardiac stimulants.</li>
	<li>Remove any exosuit, headgear, and any other insulative materials being worn by the patient. Failure to remove these will deter the effects of the cryoxadone and halt the
	healing process.</li>
	<li>Check to ensure that the gas temperature is at optimal levels and there is no contamination in the system.</li>
	<li>Put the patient in the cryogenics chamber and turn it on.</li>
	</ol>
	The cryogenics chamber will automatically eject patients once their health is back to normal, but post-cryo evaluation is recommended nevertheless.
	"}

/obj/item/paper/cargo_instructions
	name = "'Cargo Bay Setup Instructions'"
	info = "In order to properly set up the cargo computer, both the incoming and outgoing supply pads must be directly or diagonally adjacent to the computer."

/obj/item/paper/efif_disclaimer
	name = "'EFIF-1 Operational Disclaimer'"
	info = {"Congratulations on your new EFIF-1 Construction System!<BR>\n<BR>\n
	Operational modes and EZ Sheet Loading may be accessed from the "EFIF-1 Construction System" entry in your pod's computer console.<BR>\n<BR>\n
	Please be aware that non-repair assembly of walls and standard floors may obstruct your pod's clearance, and should be constructed with caution.<BR>\n<BR>\n
	<B>LOAD ONLY STANDARD, NON-REINFORCED NT-SPEC STEEL SHEETS. EFIF-1 IS CALIBRATED FOR NT-SPEC STEEL. EFIF-1 DOES NOT AND SHOULD NOT ACCEPT OTHER METALS.</B>"}

/obj/item/paper/courtroom
	name = "'A Crash Course in Legal SOP on SS13'"
	info = {"<B>Roles:</B><BR>\nThe Detective is basically the investigator and prosecutor.<BR>\nThe Staff Assistant can perform these functions with written
	authority from the Detective.<BR>\nThe Captain/HoP is the judicial authority.<BR>\nThe Security Officers are responsible for executing warrants,
	security during trial, and prisoner transport.
	<BR>\n<BR>\n<B>Investigative Phase:</B><BR>\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did
	it but what happened. They must take special care to catalogue everything and don't leave anything out.
	Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. If you must ask someone questions, you have permission to confront them.
	If the person refuses, the Detective can ask a judicial authority to write a subpoena for questioning. If again the suspect fails to respond then that person
	is to be jailed as insubordinate and obstructing justice. Said person will be released after they cooperate.
	<BR>\n<BR>\nONCE the Detective has a clear idea as to who the criminal is, they are to write an arrest warrant on the piece of paper.
	IT MUST LIST THE CHARGES. The Detective is to then go to the judicial authority and explain a small version of their case. If the case is moderately
	acceptable the authority should sign it. Security must then execute said warrant.
	<BR>\n<BR>\n<B>Pre-Pre-Trial Phase:</B><BR>\nNow a legal representative must be presented to the defendant if said defendant requests one.
	That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and their lawyer	are then to be given a copy of
	all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions,
	THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO, if the defense will be
	seeking not guilty by mental defect, it must be stated this at this time to allow ample time for examination.
	<BR>\nNow at this time each side is to compile a list of witnesses.
	By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used
	the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.
	<BR>\n<B>Possible Motions:</B><BR>\n1.
	<U>Invalidate Evidence-</U> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt Security.<BR>\n2.
	<U>Free Movement-</U> Basically, the defendant is to be kept uncuffed before and during the trial.<BR>\n3.
	<U>Subpoena Witness-</U> If the defense presents good reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<BR>\n4.
	<U>Drop the Charges-</U> Not enough evidence is there for a trial so the charges are to be dropped. The Detective CAN RETRY but the judicial authority must carefully
	reexamine the new evidence.<BR>\n5.
	<U>Declare Incompetent-</U> The defendant is insane. Once this is granted, a medical official is to examine the patient. If they are indeed insane, they are to be placed
	under care of the medical staff until they are deemed competent to stand trial.
	<BR>\n<BR>\nALL SIDES MOVE TO A COURTROOM<BR>\n
	<B>Pre-Trial Hearings:</B><BR>\nA judicial authority and the 2 sides are to meet in the trial room.
	NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty, then proceed directly to sentencing phase.
	Now the sides each present their motions to the judicial authority. The judicial authority rules on them. Each side can debate each motion. Then the judicial authority
	gets a list of crew members. The judicial authority first gets a chance	to look at them all and pick out acceptable and available jurors. Those jurors are then called over.
	Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER, before dismissal the judicial authority MUST agree to the reasoning.
	<BR>\n<BR>\n<B>The Trial:</B><BR>\nThe trial has three phases.<BR>\n1.
	<B>Opening Arguments</B> - Each side can give a short speech. They may not present ANY evidence.<BR>\n2.
	<B>Witness Calling/Evidence Presentation</B> - The prosecution goes first and is able to call the witnesses on their approved list in any order.
	They can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point.
	After every witness, the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another witness or recall one
	(even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either
	list.<BR>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<BR>\n3.
	<B>Closing Arguments</B>- Same procedure as Opening Arguments.<BR>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict.
	REMEMBER: They can mix between some charges being guilty and others not guilty (IE, if you supposedly killed someone with a gun and you	unfortunately picked up a gun without
	authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry). Once they have agreed, they present	their verdict. If unable to reach
	a verdict and feel they never will, they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.
	<BR>\n<BR>\n<B>Sentencing Phase:</B>
	<BR>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part.
	<BR>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects. The prosecution is to submit a suggested penalty.
	After all the sides are done, then the judicial authority is to give a sentence.
	<BR>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a
	sentence.<BR>\n<BR>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<BR>\n"}

/obj/item/paper/flag
	icon_state = "flag_neutral"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	anchored = ANCHORED

/obj/item/paper/sop
	name = "'Standard Operating Procedure'"
	info = {"Alert Levels:<BR>\nBlue- Emergency<BR>\n\t1. Caused by fire<BR>\n\t2. Caused by manual interaction<BR>\n\tAction:<BR>\n\t\tClose all fire doors. These can
	only be opened by reseting the alarm<BR>\nRed- Ejection/Self Destruct<BR>\n\t1. Caused by module operating computer.<BR>\n\tAction:<BR>\n\t\tAfter the specified time
	the module will eject completely.<BR>\n<BR>\nEngine Maintenance Instructions:<BR>\n\tShut off ignition systems:<BR>\n\tActivate internal power<BR>\n\tActivate orbital
	balance matrix<BR>\n\tRemove volatile liquids from area<BR>\n\tWear a fire suit<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner
	<BR>\n<BR>\nToxin Laboratory Procedure:<BR>\n\tWear a gas mask regardless<BR>\n\tGet an oxygen tank.<BR>\n\tActivate internal atmosphere<BR>\n<BR>\n\tAfter
	<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nDisaster Procedure:<BR>\n\tFire:<BR>\n\t\tActivate sector fire alarm.<BR>\n\t\tMove to a safe area.
	<BR>\n\t\tGet a fire suit<BR>\n\t\tAfter:<BR>\n\t\t\tAssess Damage<BR>\n\t\t\tRepair damages<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tMeteor Shower:<BR>\n\t\tActivate fire alarm
	<BR>\n\t\tMove to the back of ship<BR>\n\t\tAfter<BR>\n\t\t\tRepair damage<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tAccidental Reentry:<BR>\n\t\tActivate fire alrms in front of ship.
	<BR>\n\t\tMove volatile matter to a fire proof area!<BR>\n\t\tGet a fire suit.<BR>\n\t\tStay secure until an emergency ship arrives.<BR>\n<BR>\n\t\tIf ship does not arrive-
	<BR>\n\t\t\tEvacuate to a nearby safe area!"}

/obj/item/paper/martian_manifest
	name = "Tattered paper"
	icon_state = "paper_burned"
	info = {"
	<br>      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>PPIN </b>░█=-<b>IFEST</b><br>
	<br><br>  &nbsp;&nbsp;&nbsp;<b><u>ent:</u></b> Kingsw ░░█tems ░9A
	<br><br>- rate of x4 dat† tap s \[FRAG░LE\]
	<br><br>- EVA equipment f   = ▓  -- ▀█ ency aid
	<br><br>- Prot▓ ▓e= AI- ██░█c▓re \[EXTR█▓░Y FRAGILE\]
	<br><br>- \[CO▓░IDENTIAL\]&nbsp;&nbsp;█▓ ▓
	<br><br>- mergency com░dy resu███ ▓█░
	<br><br>- Pro█░ssio-al cl=wns (x▓)
	<br><br>- Asso ted civil▓n grad▓█ goods
	<br><i>Note: Shipment exp▓▓ted to a███ve no late than J█░▓░20█░</i>
	<br><i>Client wil&nbsp;&nbsp;██rate a late or damaged shipment</i>
	"}

	New()
		. = ..()
		src.stamp(200, 20, rand(-5,5), "stamp-qm.png", "stamp-qm")

/obj/item/paper/engine
	name = "'Generator Startup Procedure'"
	info = {"<B>Startup Procedure for Mark II Thermo-Electric Generators</B><BR>
Standard checklist for thermo-electric generator cold-start:
<HR>
<ol>
<li>Perform visual inspection of the <b>HOT (left)</b> and <b>COLD (right)</b> coolant-exchange pipe loops. Weld any breaks or cracks in the pipes before continuing.
<li>Connect one Plasma canister to a cooling loop supply port with a wrench, and open the adjacent supply valve.
<li>Connect one Plasma canister to a heating loop supply port with a wrench, and open the adjacent supply valve.<BR>
<i>Note:</i> Observe standard canister safety procedures. Additional canisters may be utilized or mixed together for various thermodynamic effects. CO2 and N2 can be effective moderators.
<li>Open the main gas supply valves on both loops, the core inlet and outlet valves on both loops, and the combustion chamber bypass valve on the hot loop.<BR>
<i>If you wish to use the supplemental combustion chamber instead of or in addition to the furnaces, close the bypass and open the inlet and outlet valves above it.</i><BR>
<li>Coolant supply and exchange pump settings can be adjusted from the Control Room.<BR>
<li>Load the furnaces with char ore and activate them. Reload as needed. Plasmastone and various other materials may be used as well.
<li>Heat can be provided by the furnaces, the gas combustion chamber, or in experimental setups, direct combustion of pipe coolant*.<BR>
<b>*Direct combustion of internal coolant may void your engine warranty and result in: fire, explosion, death, and/or property damage.</b><BR>
<li>In the event of hazardous coolant pressure buildup, use the vent valves in maintenance above the engine core to drain line pressure. If the engine is not functioning properly, check your line pressure.
<li>Generator efficiency may suffer if the pressure differential between loops becomes too high. This may be rectified by adding more gas pressure to the low side or draining the high side.
<li>The circulator includes a blower system to help ensure a minimum pressure can be provided to the circulator.  A multitool can be used to override the default setting if additional pressure is required.<BR>
<b>*Power required is proportional to the pressure differential to overcome. Ensure ample power is provided by SMES system, this is critical when an override is active.</b><BR>
<li>Circulator efficiency will suffer if the pressure of the outlet exceeds the inlet*. This issue may also be mitigated by cycling gas from outlet near via auxilary ports or draining line pressure depending on loop configuration.<BR>
<b>*Failure to provide sufficient pressure will inhibit energy production until the problem can be rectified.</b><BR>
<li>Circulators are equipped with a lubrication system to aid with overall efficiency and longevity. Only lubricants with sufficiently high viscosity should be utilized. System should arrive pre-lubricated with a proprietary synthetic heavy hydrocarbon oil blend from the factory. Should additional lubricant be required or need changing carefully unscrew the maintenance panel to gain access.<BR>
<b>*Operation without sufficient lubricant may void your engine warranty but is unlikely to cause fire, explosion or death.</b><BR>
<li>With the power generation rate stable, engage charging of the superconducting magnetic energy storage (SMES) devices in the Power Room. Total charging input rates between all connected SMES cells must not exceed the available generator output.</ol>
<HR>
<i>Warning!</i> Improper engine and generator operation may cause exposure to hazardous gasses, extremes of heat and cold, and dangerous electrical voltages.
Only trained personnel should operate station systems. Follow all procedures carefully. Wear correct personal protective equipment at all times. Ensure that you know the location of all safety equipment before working.
<HR>

"}
	// Provide tracking so training material can be updated by TEG.  This removes reliance on a search criteria that becomes
	// a limitation on map design.  Performant for that one time...
	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

/obj/item/paper/hellburn
	name = "paper- 'memo #R13-08-A'"
	info = {"
		<h3 style="border-bottom: 1px solid black; width: 80%;">Nanotrasen Toxins Research</h3>
		<tt>
		<strong>MEMORANDUM &nbsp; &nbsp; * CONFIDENTIAL *</strong><br>
		<br><strong>DATE:</strong> 02/19/53
		<br><strong>FROM:</strong> NT Research Division.
		<br><strong>TO:&nbsp&nbsp;</strong> Space Station 13's Research Director
		<br><strong>SUBJ:</strong> Toxins Research Project #08-A
		<br>
		<p>
		The enclosed samples are to be used in continued plasma research.  Our current understanding is that the samples enclosed (dubbed molitz beta) in the presence of
		sufficient temperatures and plasma causes an exotic reaction phenomenon. Utiliyzing a yet understood solid catalyst present in moiltz beta,
		the sample undergoes an intense endothermic reaction between the surrounding FAAE and the sample's internal gas pockets.
		</p>
		<p>
		This pressure build up results in significant offgassing.
		The exotic component of the resultant gas, Oxygen Agent B, seems to disrupt the typical equilibrium formed in exothermic oxidation
		allowing the potential for temperatures we have been unable to fully realize.
		</p>
		<p>
		Please exercise caution in your testing, when properly utilized the result can best be described as a hellfire.  Ensure adequate safety messures are in place to purge the fire.
		</p>
		<p>All findings and documents related to Project #08-A are to be provided in triplicate to CentComm on physical documents only. <b>DO NOT</b> provide this data digitally
		as it may become compromised.
		</p>
		</tt>
		<center><span style="font-family: 'Dancing Script';">Is this a Hellburn???!!?</span></center>
		"}

/obj/item/paper/zeta_boot_kit
	name = "Paper-'Instructions'"
	info = {"<center><b>RECOVERY INSTRUCTIONS:</b></center><ul>
			<li>Step One: Ensure that a core memory board is properly inserted into system.</li>
			<li>Step Two: Insert OS tape into connected tape databank.  Cycle mainframe power. If bank is not accessed, try another bank.</li>
			<li>Step Three: Connect to mainframe with a terminal.  If the OS does not respond to commands, see step two.</li></ul>
			<b>DEVICES MAY NEED TO BE RESET BEFORE THEY ARE SEEN BY THE OPERATING SYSTEM</b>"}

/obj/item/paper/note_from_mom
	name = "note from mom"
	desc = "Aw dang, mooom!"
	info = "Good luck on your adventure, sweetie! Love, Mom.<br><i>Whose mom? Yours? Who knows.</i>"

/obj/item/paper/hecate
	name = "Priority - Hecate Incident"
	desc = "You're not sure what to make of this."
	info = "<i>The writing is indecipherable, save for a few scrawled sevens.</i>"

/obj/item/paper/poo
	name = "strange note"
	desc = "What's this doing here?"
	info = "<i>On the other side... 232 09</i>"

/obj/item/paper/torn
	name = "torn note"
	info = "Ok I got the disk lik you askd. Im not stuped lik you so this is safe. Noone will find exept us ok? I will briin moar. - Bores"

/obj/item/paper/hastily
	name = "hastily scrawled note"
	info = "Boris, you dumb fuck, that's not the disk we were going for. In fact, it's not even a disk! It's a record! You idiot. - Daniel"

/obj/item/paper/bores
	name = "smudged note"
	info = "Your a idiot to Daniel. Look I kno its hard but dont be mad. Serisly. I got moar. - Bores"

/obj/item/paper/bores_part_two
	name = "barely decipherable note"
	info = "Hear the green book you askd for. I did my job. They'have a rest for me I need to hide. - Bores"

/obj/item/paper/gauntlet_note
	name = "Re:re: Break-in!"
	info = {"
	Some fucking asshole broke into our vault all by themselves! How the hell did they even manage that?<br>
	<br>
	They messed with the <b><i>Ouroboros Engine</i></b> and those dumb fucks blew up most of the vault too. Nearly blinded myself looking at all that gold.
	They must have tried using that alchemy stone without a conduit, damn lucky the damage wasn't spread any further<br>
	<br>
	Sent the NTSOs off to the remains of Site Tempus on that dead planet again to hopefully recover the artifact. Gunna need it to revert this place back
	to how it was. Thank god we were able to recover the Engine.<br>
	<br>
	Up your bloody security before this happens again. You know how dangerous using that artifact is. We'll be the ones blowing up next time. Or worse!
	"}

/obj/item/paper/stay_out_of_my_office
	name = "Go Away!"
	info = {"Don't touch my stuff dork!<br>"}

/obj/item/paper/ACNote
	name = "hastily scribbled note"
	info = {"
	I still don't understand the drawings I drew or the words I wrote... or the words you whisper to me.<br>
	<br>
	Even now on my journey to understand I still see your face looking at me from the shadows.<br>
	<br>
	Maybe I was just around you for too long...And your unchanging face.<br>
	<br>
	I will be back to save you soon. We promised to escape together, remember?<br>
	<br>
	-A.C
	"}

/obj/item/paper/mantasegways
	name = "paper - Where are the security segways?"
	icon_state = "paper"
	info = {"
	<h4>Where are the security segways?</h4><br>
	Many of you have asked "where are the security segways?". Well let me tell you that we finally got rid of those filthy stains on the cover of the Space Law
	and permanently brigged them in some warehouse on the ship.
	<br>
	Now quit bothering us with your nonsensical questions and get back to work!
	<br>
	<font size=1>- Head of Security </font>
	"}

/obj/item/paper/mantasecscanners
	name = "paper - Security Officers are so dumb!"
	icon_state = "paper"
	info ={"Man, I can't believe how ridiculously dumb those security officers are! It's been weeks since I cut the wires to the security scanners on the left
	and right side of security and yet they still haven't noticed!<br>
	I swear, as soon as I'll get out of here, I'm going to go and snatch that sweet medal that Head of Security has in his office."}

/obj/item/paper/mantanote
	name = "paper - The Sea"
	icon_state = "paper"
	info ={"
	The sea, the darkness, the death and despair- <br>
	all around me all this harkens back to days with air.<br>
	My hands, my arms, my clothes and hair - <br>
	all of this will go to waste in here! <br>

	A fool I was, in days way past, to go enlist - <br>
	a braggard, he was, who convinced me of this! <br>
	I signed the paper and thus am trapped, fuck this! <br>

	The creaking of the ship, the metal closing in - <br>
	ah, the wonderful engineers, smash their shins! <br>
	Jail would be a soft fate for the likes of these! <br>

	The days go by, I hear me sigh, and dread what swam just by - <br>
	I won't survive tonight, or if I do, tomorrow. For I know why, <br>
	the metal creaks in horror. I leave this poem, to you dear reader, <br>
	please excuse the mistakes, for I fear that the pen moves too slow, <br>
	my eyes move too slow, everything is too slow, and I cannot fix the mistakes I made in here, and I cannot fix anything I have done in here. <br>
	Goodbye my reader, if you exist, please don't make my mistakes again. <br>"}

/obj/item/paper/mantahopnote
	name = "paper - Important message"
	icon_state = "paper"
	info ={"
	It has come to our attention that there is an increasing number of<br>
	threats on your life regarding matters of you refusing to hand out all access cards.<br>
	In order to keep your life more secure, we have commissioned a naval style armored coat for your usage. <br>

	We hope that it will keep you alive long enough for us to find a potential replacement candidate to do your job.

	With best regards,<br>Nanotrasen HR Department. <br>"}

/obj/item/paper/antisingularity
	name = "paper - How to properly operate Singularity Buster rocket launcher"
	icon_state = "paper"
	info = {"<center><h2>How to properly operate Singularity Buster rocket launcher</h2></center>
	<h3>Quick word from the manufacturer</h3><hr>
	Please note that this highly experimental weapon is designed to reliably collapse a singularity in order to prevent catastrophic damage to the station.
	The singularity buster rockets are theoretically harmless to humans. Please do not try shooting a rocket at a human.<hr>
	<h3>Operating Singularity Buster rocket launcher</h3><hr>
	<ul style='list-style-type:disc'>
		<li>1) Carefully pick up a singularity buster rocket and load it into the loading chamber of the rocket launcher. Please make sure not to hit the rocket
		on any hard surfaces while doing so as this may lead to matter destabilization. </li>
		<li>2) Pick up the rocket launcher on your shoulders, yet again making sure not to hit the rocket launcher on any hard surfaces as this might accidentally
		disintegrate the weapon.</li>
		<li>3) Point the rocket launcher carefully towards the center of a rogue singularity.</li>
		<li>4) Press the trigger and prepare for the rocket to fly out of the barrel. This might be a good moment to pray for your safety if you are into that
		kind of thing as there is a slight chance for the rocket to destabilize and cause a new singularity to appear in its location. </li>
		<li>5) Singularities' gravitional pull may move the rocket off course, requiring several attempts at collapsing a singularity.</li>
	</ul>
	"}

/obj/item/paper/neonlining
	name = "paper - How to properly install official Nanotrasen neon lining"
	icon_state = "paper"
	info = {"<center><h2>How to properly install official Nanotrasen neon lining</h2></center>
	<h3>Product description</h3><hr>
	Ever wanted to spice up your bar? Build a meditation room? Enhance the station halls in case of an emergency? Then this official Nanotrasen neon lining
	is what you need. Now with color-change modules!<hr>
	<h3>Modifying the neon lining</h3><hr>
	<ul style='list-style-type:disc'>
		<li>1) A wrench can be used to change the shape of the lining. Currently only 6 shapes are officially supported.</li>
		<li>2) To turn an already attached piece of lining back into a coil, carefully use a crowbar to detach it from its attachment point.</li>
		<li>3) Apply a standard multitool to change the pattern of the lining. If upon changing shape, the pattern's value is higher than the maximum for that shape,
		the value gets automatically reset to 0.</li>
		<li>4) As this version is designed to be more flexible and compact, the lining feeds only on an internal power source. Due to this the only way to turn it
		off/on is to cut/mend the wires that connect to said power source.</li>
		<li>5) To adjust the lining's rotation, simply unscrew it from its attachment point. The lining will automatically snap to the next available rotation and
		screw itself into a new attachment point.</li>
		<li>6) Due to safety concerns caused by our previous prototype of the product, the color-change modules are only active when the lining is detached and thus in a coil.</li>
		<li>7) There have been reports that when the lining is in the short line shape, using a multitool to change the pattern sometimes triggers the movement function. This
		essentially shifts the lining a bit. We understand that this might be a bit unintuitive, but since this isn't hazardous we have no intentions of fixing it.</li>
	</ul>
	"}

/obj/item/paper/manta_polarisnote
	name = "paper - Note to myself"
	icon_state = "paper"
	info ={"
	Alright. In case I forget the password again for my personal computer, it should be "Icarus".<br>
	I know it's against protocol to write passwords anywhere but I'll be damned if I have to get one of those techies here again.<br>
	<br>"}

/obj/item/paper/manta_polarisengineernote
	name = "paper - note"
	icon_state = "postit-writing"
	info ={"Congaline"}

/obj/item/paper/telecrystal_update
	name = "email printout"
	info = {"
	=== Internal memo ===<br>
	From: itdirector@donkcorp.org<br>
	To: qm@donkcorp.org<br>
	Subject: Broken uplinks<br><br>

	Morning Blake,<br><br>

	We just got another call from an agent who busted up their uplink.<br>
	Looks like they nabbed an unrefined telecrystal from the local miners.<br>
	Long story short they tried to jam the thing in there and cracked some bit or another and now the thing wont work.<br>
	Any way we could fix this? We can't just send off all our agents for a class in teleportation mechanics, we just dont have the time!<br><br>

	- Karen J.<br><br>

	=== Internal memo ===<br>
	From: qm@donkcorp.org<br>
	To: itdirector@donkcorp.org<br>
	Subject: Re: Broken uplinks<br><br>

	Hi Karen,<br><br>

	Redoing the uplink system would be a hassle. I think an interface change might do the trick though.<br>
	I'll go ahead and relabel their uplinks to show some abstract representation of credits.<br>
	Is it accurate? No - its still telecrystals under the hood. But it should stop any more confusion and<br>
	keep the users from accidentally breaking their uplinks<br><br>

	- B <br>
	"}

/obj/item/paper/shipping_precautions
	name = "Read this and check the cargo!"
	icon_state = "paper_caution_bloody"
	desc = "An ordinary notice about shipping procedures...stained with blood?"
	info = {"<center><h2>Warning</h2></center>
	<hr>
	<h3>Discount Dan contracts you - a healthy and breathing human being to deliver this cargo safely to the nearest Discount Dans fabrication center!</h3>
	<br>
	<br>
	<br>
	So read carefully and heed the precautions! Keep the fridges closed! All of them! Do not look inside...and if you happen to hear any clawing, grumbling,
	or cries for help...<b>ignore them</b>!
	<br>
	<br>
	The freight is extremely valuable! Any light or human flesh exposed to said cargo will cost your pal Discount Dan an arm, a leg and a space-tastic lawsuit!
	<br>
	<br>
	Remain cautious - because it's what's necessary!
	"}

/obj/item/paper/dreamy_rhyme
	name = "Space-Rhymes"
	icon_state = "thermal_paper"
	desc = "Scribbled rhymes...and thoughts."
	info = {" Space duck, I do not give a...I do not give anything about luck, shrug, puck, quack
	<br>
	<br>
	<br>
	<b>Yeah! Yo! Here the quick rhymer goes, clowns convulse!
	<br>
	<br>
	Soon enough your mimes go fold, like a piece of paper!
	<br>
	<br>
	This Emcee did not just meet ya'his thoughts created a - whole universe!
	<br>
	<br>
	Spitting lines like liquid fire as he converse!
	<br>
	<br>
	Transfer ideas from word to mind; not just half-assed like some damn pantomime!
	<br>
	<br>
	Never behind the crime, A-grades as janitor...oh so fine!</b>
	"}

/obj/item/paper/mice_problem
	name = "Fucking space-rats!"
	icon_state = "paper"
	desc = "A scribbled note - created with burning rage."
	info = {"<center><h3>MICE?!</h3></center>
	<hr>
	<i>Ey! Yo! What the hell? You think you can take a day off - relax - and then these hungry n'angry food pirates come along! Damn Thompson McGreasy;
	unable to close his trash-pod he arrived in. Now we gotta deal with some mutant mice problem!</i>
	"}

/obj/item/paper/cruiser_bought
	name = "My very own space cruiser"
	icon_state = "paper"
	desc = "The first entry in a collection of never to be finished memoirs."
	info = {"<center><h2>Finally, my own ship!</h2></center>
	<hr>
	<i>This is the begining of my log, I figured since I made it rich after all this time, I ought to recount my thoughts now in a log of sorts.
	Years of working in a damm cubicle, my only worthwile cash comming from transfering dead crew members credits to my own account.
	But it has all paid off, I got a beautiful ship, my dog, a whole damm vault, and plenty of room for guests!
	I even got this bottle of blue label! I was going to save it for my first cruise with others, but I suppose it wont hurt to dip into a bit of it.</i>
	"}

// adhara thing
/obj/item/paper/janitor_joblist
	name = "job list"
	info = {"<b>JOB LIST FOR THIRD QUARTER - 2051</b><br><br>
	<b>COTTON WAREHOUSE - ASTEROID BELT:</b> CLEAN UP WAREHOUSE AFTER FIREFIGHT, HEAVY CASUALTIES.<br>
	<b>SPECIAL INSTRUCTIONS:</b> DISPOSE OF CORPSES WEARING JUMPSUITS, PUT CORPSES WEARING TURTLENECKS INTO BODYBAGS AND LEAVE THEM.<br>
	<b>STATUS:</b> COMPLETED<br><br>
	<b>NANOTRASEN SPACE STATION 17 - FRONTEIR:</b> FULL DEEP CLEAN OF ALL STATION FACILITIES, NO CASUALTIES.<br>
	<b>SPECIAL INSTRUCTIONS:</b> PLEASE MAKE LOOK AS CLEAN AS POSSIBLE, SEARCH FOR ANY UNDERLYING HYGENIC ISSUES IN STATION THAT MAY EFFECT MORALE AND FIX IF POSSIBLE.<br>
	<b>STATUS:</b> COMPLETED<br><br>
	<b>CHARLIE CHEDDAR'S VIRTUAL REALITY GAME PARLOR - LUNAR ORBIT:</b> FULL DEEP CLEAN OF FRANCHISE FACILITIES, MINOR CASUALTIES.<br>
	<b>SPECIAL INSTRUCTIONS:</b> DON'T DISABLE BREAKER POWER, DON'T INTERACT WITH ANIMATRONICS.<br>
	<b>STATUS:</b> COMPLETED<br><br>
	<b>RESEARCH INSTALLATION YUGGOTH - PLUTO:</b> CLEAN UP RESEARCH INSTALLATION FLOORS 5 THROUGH BASEMENT ONE, HEAVY CASUALTIES.<br>
	<b>SPECIAL INSTRUCTIONS:</b> BRING MEANS OF PERSONAL PROTECTION, INCINERATE ALL BIOLOGICAL MATERIAL FOUND.<br>
	<b>STATUS: COMPLETED</b><br><br>
	<b>PRIVATE ESOTERIC RESEARCH STATION - EUROPA:</b> CLEAN UP RESEARCH FACILITY AND ATTACHED SUBMERSIBLE VEHICLES, MODERATE CASUALTIES.<br>
	<b>SPECIAL INSTRUCTIONS</b> WILL PAY DOUBLE IF SUB-BASEMENT 3 IS CLEARED OF ALL RESEARCH SPECIMENS AND SUBJECTS, ALL SPECIMENS AND SUBJECTS ARE EFFECTIVELY BRAINDEAD, SUPPLY OWN MEANS OF EXECUTION OF SUBJECTS.<br>
	<b>STATUS:</b> BEING CLEANED"}

/obj/item/paper/lawbringer_pamphlet
	name = "Your Lawbringer And You"
	icon_state = "paper"
	info = {"
	<h2>Your Lawbringer And You</h2>
	<i>A Nanotrasen Arms Division Instructional Publication</i>
	<hr>
	<p>Welcome, noble lawperson, to the greatest technological development in policing since the helmet: Your new <b>Lawbringer™</b>!<br>
	The Lawbringer™ is a multi-purpose self-recharging personal armament for our loyal Heads of Security.<br>
	Please take a moment to acquaint yourself with your new colleague's features, and to scan your fingerprints into the provided identity lock system.</p>

	<p>The Lawbringer™ is equipped with eight different Crime Pacification Projectile Synthesization Methods, or "Modes,"
	all of which draw from the central Self-Renewing Energy Capacitance Device, or "Cell."<br> The Cell has a capacity of
	300 Power Units ("PU"), and recharges at a rate of approximately 10 PU per 6 seconds;
	however, due to the exacting measurements used in the Lawbringer™'s foolproof* design, the Cell
	cannot be removed from the unit or externally recharged.<br>
	<small><i><b>*</b>The Lawbringer™ should not be exposed to fools. If this occurs, wash thoroughly under cold water.</i></small></p>

	<p>The greatest feature of the Lawbringer™ is its unique voice control system: To choose your desired Mode, simply speak its name!
	So long as your fingerprints† match those assigned to the identity lock (configured during device setup) the Lawbringer™ will
	automatically adopt your criminal control strategy of choice.<br>
	<small><i><b>†</b>The user is considered responsible for the protection of their own fingerprints and arms.</i></small></p>
	<hr>
	<h3>Provided: A table of all Modes, their power drains, and their purposes.</h3>

	<table border = "1" cellpadding = "3" cellspacing = "3">
	<tr>
	<td><b>"Detain"</b></td>
	<td>50 PU</td>
	<td>The perfect crowd control option, this Mode stuns all your enemies within a close radius, but leaves you untouched!</td>
	</tr>
	<tr>
	<td><b>"Execute" / "Exterminate"</b></td>
	<td>30 PU</td>
	<td>Turn your Lawbringer™ into your favourite sidearm with these only slightly radioactive blaster rounds!</td>
	</tr>
	<tr>
	<td><b>"Hotshot" / "Incendiary"</b></td>
	<td>60 PU</td>
	<td>This handy flare gun/flamethrower option is sure to heat things up! The Lawbringer™ is not certified fireproof. Do not set on fire.</td>
	</tr>
	<tr>
	<td><b>"Smokeshot" / "Fog"</b></td>
	<td>50 PU</td>
	<td>Never use a riot launcher again! These smoke grenades will let you manage line of sight with ease.</td>
	</tr>
	<tr>
	<td><b>"Knockout" /  "Sleepshot"</b></td>
	<td>60 PU</td>
	<td>When you just can't get things to slow down, <i>make 'em</i> slow down with these handy haloperidol tranquilizer darts!</td>
	</tr>
	<tr>
	<td><b>"Bigshot" / "High Power" / "Assault"</b></td>
	<td>170 PU</td>
	<td>You'll be the talk of the station when you bust down a wall with one of these high power assault lasers! May cause small fires and molten metal puddles.</td>
	</tr>
	<tr>
	<td><b>"Clownshot" / "Clown"</b></td>
	<td>15 PU</td>
	<td>Lawbringer™ warranty is voided if exposed to clowns. Keep them at bay.</td>
	</tr>
	<tr>
	<td><b>"Pulse" / "Push" / "Throw"</b></td>
	<td>35 PU</td>
	<td>Just like our patented Pulse Rifle™s, this Mode sends your enemies flying! Keep crime at arm's length!</td>
	</tr>
	</table>
	<hr>
	<p><b>Disclaimer:</b> Nanotrasen Arms Division cannot be held liable in the case of inconvenience, failure or death,
	as per your Nanotrasen Employment Agreement. If any of the Modes are found to be ineffective, underpowered,
	minimally successful at their purpose, or otherwise useless; and in the event that the user survives to do so;
	Nanotrasen Arms Division requests that they submit a formal Suggestion to our company forums,
	so that the Lawbringer™ can be the best it can be. Do not place fingers in path of moving parts, as the Lawbringer™ device
	is solid-state and should not feature moving parts. Note that the Cell may experience spontaneous explosive overload when
	exposed to overconfident outbursts on the part of individuals unqualifed to embody the law; in event of such explosion, run.
	"}

/obj/item/paper/postcard/mushroom
	name = "Mushroom Station postcard"
	desc = "Just four pals hangin' out havin' a good time. Looks like they're welded into the bathroom? Why?!"
	icon_state = "postcard-mushroom"
	sizex = 174 + IMAGE_OFFSET_X
	sizey = 247 + IMAGE_OFFSET_Y
	scrollbar = FALSE

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)
		info = PAPER_IMAGE_RENDER("images/arts/mushroom_station.png")

/obj/item/paper/botany_guide
	name = "Botany Field Guide"
	desc = "Some kinda informative poster. Or is it a pamphlet? Either way, it wants to teach you things. About plants."
	icon_state = "botany_guide"
	sizex = 965 + IMAGE_OFFSET_X
	sizey = 682 + IMAGE_OFFSET_Y
	scrollbar = FALSE

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)
		info = PAPER_IMAGE_RENDER("images/pocket_guides/botanyguide.png")

/obj/item/paper/ranch_guide
	name = "Ranch Field Guide"
	desc = "Some kinda informative poster. Or is it a pamphlet? Either way, it wants to teach you things. About chickens."
	icon_state = "ranch_guide"
	sizex = 1100
	sizey = 800
	scrollbar = FALSE

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)
		//ranch guide actually needs to be scaled down, so we just let it do its own styling here
		info = "<html><body><style>img {width: 100%; height: auto;}></style><img src='[resource("images/pocket_guides/ranchguide.png")]'></body></html>"

/obj/item/paper/siphon_guide
	name = "Harmonic Siphon Brief"
	desc = "A very official-looking sheet full of information you may or may not be able to wrap your head around."
	icon_state = "postcard-owlery"
	sizex = 1192 + IMAGE_OFFSET_X
	sizey = 600 + IMAGE_OFFSET_Y
	scrollbar = FALSE

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/pocket_guides/siphonguide.png")

/obj/item/paper/iou
	name = "IOU"
	desc = "Somebody took whatever was in here."
	icon_state = "postit-writing"
	info = {"<h2>IOU</h2>"}

/obj/item/paper/shooting_range_note1 //shooting range prefab junk
	name = "secure safe note"
	desc = "Someone left a reminder in neat cursive. The post-it looks nearly new."
	icon_state = "postit-writing"
	info = {"
	*Experimental ray gun - DO NOT FIRE IN A CLOSED SPACE. Waiting for Olwen to fix... whenever she's back...<br>
	<b><u>*Dinner date is on <s>Tuesday</s>  <s>Fri.</s></s><br>
	<s>Thurs.</s><br><s>Sunday</s><br></u><br>???
	"}

/obj/item/paper/shooting_range_note2
	name = "secure safe note"
	desc = "This note is creased and ripped and tattered. The writing on it is scribbled in near-indecipherable chickenscratch."
	icon_state = "postit-writing"
	info = {"-non-stable battery; keeps popping on use.<br>-design work (not final)<br>-battery capacity??? maybe?<br>Cheers,<br>O"}

/obj/item/paper/bee_love_letter //For lesbeeans prefab
	name = "bee love letter"
	desc = "This smells as sweet as the prose on it."
	icon_state = "paper_caution"
	info = {"
	<i>You have no hope of deciphering the weird marks on this paper, nor are you entirely certain it's even actual writing,
	but the splotchy heart with prints of bee pretarsi at the bottom kindles a warmth deep within your heart.</i>
	"}

/obj/item/paper/folded/ball/bee_farm_note //Idem, let's see if anyone thinks to unfold this
	name = "wadded-up note"
	desc = "A crumpled, chewed-on wad of paper. A bee appears to have tried eating this."
	info = {"
	Janus, I can see why you're so fond of these two and spend so much time on them.
	It's adorable watching those two together at work, and I think we're seeing new and unique behaviour here!<br><br>
	But please, please do something about the fact it's hanging on by just the data cables, they're not remotely capable of tugging this kind of mass.<br><br>
	That clump of dirt has a metal substrate, we can just ask Rachid to weld it to the station while we keep the lovebirds at a safe distance.
	A little wrangling never hurt a bee.
	"}

/obj/item/paper/artists_anger // for starved artist random maint room
	name = "stained note"
	desc = "This paper is stained yellow from old age."
	icon_state = "paper_caution"
	info = {"God damnit, why is drawing a simple rubber duck so fucking hard?!"}

/obj/item/paper/synd_lab_note
	name = "scribbled note"
	info = {"So, we've been out here for a week already, and our insurmountable task isn't looking any easier.<br><br>
	My colleague and I were asked to figure out a way to refine telecrystals into a version usable in our uplinks, but so far, no luck.
	We were given this 'state of the art' facility to figure out how to make this work, when I keep saying that this fundamentally will not.
	These damn crystals are a pain in the ass to refine normally, when we have a goddamn mining station built to do JUST that!<br>
	And, we were hardly given proper lab equipment.<br>
	We're stuck with only a few flasks, along with some shitty prototype chemi-something or other,
	which quite frankly we'd be better off with another pair of beakers, fuck, it can't even produce chemicals!
	I'm trying anything at this point, even port, of all things.<br><br>
	I'd better get back to it, I'm not being paid by the hour here."}

/obj/item/paper/synd_lab_note2
	name = "scribbled note"
	info = {"I've been working on these faux, exploding 'telecrystals' for a while now, and I'm starting to think I got the better end of a rotten deal.<br><br>
	I've been, as of yet, completely unable to emulate any of the teleporting aspects of regular telecrystals, which means these things can certainly feel fake if you give 'em enough testing.
	Needless to say, I'm not a fan.<br>
	I mean, just making these telecrystals the right color is a pain in the ass, requiring this bulky machine I hardly know how to operate take HOURS per crystal!<br><br>
	Well, here's to hoping infusing these things with black powder won't blow up in my face."}

//is this a bit extra? Yeess but I wanted it on a random table okay!
proc/spawn_kitchen_note()
	for_by_tcl(table, /obj/table)
		if (istype(get_area(table), /area/station/crew_quarters/kitchen) && prob(50))
			var/type = pick(concrete_typesof(/obj/item/paper/recipe) - /obj/item/paper/recipe)
			new type(get_turf(table))
			return

/obj/item/paper/recipe/tandoori
	name = "stained recipe clipping"
	desc = "It's creased and worn, and smells a little like dried blood."
	icon_state = "paper_caution_bloody"
	info = {"<i>In just nine seconds, treat your family to a meal that tastes like it took hours to roast!</i><br><h3>Tandoori Chicken</h3><br><h4>Ingredients:</h4><br> -chicken meat <br> -a heaping helping of curry powder <br> -a nice, hot chili pepper <br> -a head of garlic <br><br><i>Don't even waste your time slashing the meat or slathering it in spices! Just toss it all in your standard-issue industrial oven and set it to high. Your dinner guests can't even tell the difference!</i>"}

/obj/item/paper/recipe/potatocurry
	name = "tattered recipe clipping"
	desc = "It's very old, and nearly falls apart in your hand."
	icon_state = "paper_burned"
	info = {"<i>Rich and full of vegetables, this hearty curry will satisfy any palate!</i><br><h3>Potato Curry</h3><br><h4>Ingredients:</h4><br> -plenty of curry powder <br> -a fresh potato <br> -chopped carrots <br> -a handful of peas <br><br><i>Simply toss the ingredients into a standard-issue industrial oven and let them simmer on low. Treat anyone to the flavor of a home-cooked stew in a fraction of the time!</i>"}

/obj/item/paper/recipe/coconutcurry
	name = "creased recipe clipping"
	desc = "Irreparably creased from years of being folded-up. Luckily, you can still make out the text on it."
	icon_state = "paper_caution_crumple"
	info = {"
	<i>In the mood for something spicy yet mild? Have extra coconuts to burn? Asking yourself why you grew so many coconuts in the first place?
	dear god we need to do something with these things</i><br><h3>Coconut Curry</h3><br>
	<h4>Ingredients:</h4><br> -as much curry powder as you need to make it not taste like 100% coconut <br> -coconut meat <br> -a carrot to add texture <br> -a bed of rice <br><br>
	<i>Set the oven for 7 seconds, put the heat on low, add the ingredients, and hit start.
	Tell the botanists that they can go back to growing weed now. Beg them to, really.</i>
	"}

/obj/item/paper/recipe/chickenpapplecurry
	name = "worn recipe clipping"
	desc = "An old recipe clipped from a lifestyle magazine for space station chefs. Aw, the color's faded from the layout..."
	icon_state = "paper_caution"
	info = {"
	<i>Facing threats from the crew for putting pineapple on your pizzas and letting your chicken corpses spill out into the hall?
	Turn those trials into smiles when you serve up this scrumptious dish!</i><br><h3>Chicken Pineapple Curry</h3><br><h4>Ingredients:</h4> <br>
	-a bag of curry powder <br> -some fresh chicken meat <br> -a tasty ring of pineapple <br> -a nice spicy chili pepper <br><br>
	<i>With your oven, you don't even have to mix! Just add everything, set the heat to low, and let it all cook for 7 seconds!</i>
	"}

/obj/item/paper/reinforcement_info
	name = "Reinforcement Disclaimer"
	icon_state = "paper"
	info = {"
	<b>Thank you for buying a Syndicate brand reinforcement!</b><br>
	To deploy the reinforcement, simply activate it somewhere on station, set it down, and wait.
	If a reinforcement is found, they'll be deployed within the minute.
	The nearby Listening Post should do you well, but it cannot be activated on the Cairngorm!<br><br>
	<i>Disclaimer: Capability of reinforcement not guaranteed. The beacon may pose a choking hazard to those under 3 years old.<br>
	If no reinforcement is available, you may simply hit your uplink with the beacon to return it for a full refund.</i>
	"}

/obj/item/paper/designator_info
	name = "Laser Designator Pamphlet"
	icon_state = "paper"
	info = {"
	<b>So, you've purchased a Laser Designator!</b><br><br>
	The operation of one is simple, the first step is to ensure the Cairngorm has an in-tact, working gun.
	Once you've done this, you can just pull out the designator, hold shift and move if you want to do longer-range designation,
	and point at anywhere to designate a target, at which point the Cairngorm will fire the artillery weapon, and the designated area will shortly explode.
	"}

/obj/item/paper/deployment_info
	name = "Deployment Remote Note"
	icon_state = "paper"
	info = {"
	<b>Congratulations for purchasing the Syndicate Rapid-Deployment Remote (SRDR)!</b><br><br>
	To use it, first of all, you need to either be onboard the Cairngorm or at the Listening Post. <br>
	Once you're there, activate the SRDR in-hand to choose a location, then once more to teleport everyone (along with any nuclear devices you possess)
	within 4 tiles of you to the forward assault pod, at which point it will begin head to the station, taking about one minute.
	During this time, Space Station 13's sensors will indicate the quickly-arriving pod, and will likely warn the crew. <br>
	Once the minute ends, everyone will be deployed to the specified area through personnel missiles.
	"}

/obj/item/paper/band_notice
	name = "Internal Memo - NT Marching Band"
	icon_state = "paper"
	info = {"
	-----------------|HEAD|-----------------<br>
	MAILNET: PUBLIC_NT<br>
	WORKGROUP: *MARCHING_BAND<br>
	FROM: OGOTDAM@NT13<br>
	TO: NTMARCHINGBAND@NT13<br>
	PRIORITY: HIGH<br>
	SUBJECT: Imminent Closure<br>
	----------------------------------------<br>
	Dearest friends,<br><br>

	It is my great displeasure to inform you all of the imminent cessation of financial support from the Station Morale
	Organization to all performing arts activities due to budgetary constraints. This therefore means that the NanoTrasen
	Marching Band will have to close down and stop paying all of its employees.<br><br>

	Off the record, what BUFFOONISH bean-counter cut off our funding?! Do they not know how IMPORTANT the arts are in
	maintaining our collective sanity in this HELLHOLE of a station?! For Capital-G God's sake, I spend forty hours a
	day in the engine room, is it so hard to spare us but one of those hours doing something, ANYTHING to keep us from
	resorting to savagery?! So what if our uniforms make us look like dorks and that half the crew wish to puncture their
	eardrums, music is all I have, all that ANY of us have!<br><br>

	You know what, these bastards don't even deserve us. I'm out of here.<br><br>

	Yours faithfully,<br><br>

	Ovidius Gotdam<br>
	NT Marching Band Director
	"}


/obj/item/paper/businesscard
	name = "business card"
	icon_state = "businesscard"
	desc = "A generic looking business card, offering printing services for more business cards."

	sizex = 600 + IMAGE_OFFSET_X
	sizey = 346 + IMAGE_OFFSET_Y
	scrollbar = FALSE


	New()
		..()
		//note that the margin styling here does not work, I'm just leaving it here to indicate that there is indeed a problem with the margins that someone smarter than me should fix
		info = PAPER_IMAGE_RENDER("images/arts/business_blank.png")


/obj/item/paper/businesscard/banjo
	name = "business card - Tum Tum Phillips"
	icon_state = "businesscard"
	desc = "A business card for the famous Tum Tum Phillips, Frontier banjoist."

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_banjo.png")


/obj/item/paper/businesscard/biteylou
	name = "business card - Bitey Lou's Bodyshop"
	icon_state = "businesscard"
	desc = "A business card for some sorta mechanic's shop."
	color = "gray"

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_biteylou.png")


/obj/item/paper/businesscard/bonktek
	name = "business card - Bonktek Shopping Pyramid"
	icon_state = "businesscard"
	desc = "A business card for the Bonktek Shopping Pyramid of New Memphis."

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_bonktek.png")

/obj/item/paper/businesscard/clowntown
	name = "business card - Clown Town"
	icon_state = "businesscard-clowntown"
	desc = "A business card for the Clown Town Autonomous Collective."
	sizey = 341 + IMAGE_OFFSET_Y

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_clowntown.png")

/obj/item/paper/businesscard/cosmicacres
	name = "business card - Cosmic Acres"
	icon_state = "businesscard-alt"
	desc = "A business card for a retirement community on Earth's moon."

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_cosmicacres.png")

/obj/item/paper/businesscard/ezekian
	name = "business card - Ezekian Veterinary Clinic"
	icon_state = "businesscard"
	desc = "A business card for a Frontier veterinarian's office."
	color = "gray"

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_ezekian.png")

/obj/item/paper/businesscard/gragg1
	name = "business card - Amantes Mini Golf"
	icon_state = "businesscard-alt"
	desc = "A business card for a mini golf course."

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_gragg1.png")

/obj/item/paper/businesscard/gragg2
	name = "business card - Amantes Rock Shop"
	icon_state = "businesscard-alt"
	desc = "A business card for a rock collector's shop."

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_gragg2.png")

/obj/item/paper/businesscard/josh
	name = "business card - Josh"
	icon_state = "businesscard-josh"
	desc = "A business card for someone's personal business. Looks like it's based at a flea market, in space. Hopefully there aren't any space fleas there."

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_josh.png")

/obj/item/paper/businesscard/lawyers
	name = "business card - Hogge & Wylde"
	icon_state = "businesscard-alt"
	desc = "A business card for a personal injury law firm. You've heard their ads way, way too many times."

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_law.png")

/obj/item/paper/businesscard/hemera_rcd
	name = "info card - Rapid Construction Device"
	icon_state = "businesscard-hemera"
	desc = "An information card for the Mark III Rapid Construction Device from Hemera Astral Research Corporation."

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_RCD.png")


/obj/item/paper/businesscard/skulls
	name = "business card - Skulls for Cash"
	icon_state = "businesscard"
	desc = "A business card for someone's personal business. Looks like it's based at a flea market, in space. Hopefully there aren't any space fleas there."

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_skulls.png")

/obj/item/paper/businesscard/taxi
	name = "business card - Old Fortuna Taxi Company"
	icon_state = "businesscard"
	desc = "A business card for a Frontier space-taxi and shuttle company."
	color = "yellow"

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_taxi.png")

/obj/item/paper/businesscard/vurdulak
	name = "business card - Emporium Vurdulak"
	icon_state = "businesscard-vurdulak"
	desc = "A business card for someone's personal business. Looks like it's based at a flea market, in space. Hopefully there aren't any space fleas there."

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_vurdulak.png")

/obj/item/paper/businesscard/seneca
	name = "business card - Seneca Falls"
	desc = "A dog-eared blue and gold business card from a staff recruitment agency."
	icon_state = "businesscard-seneca"
	//slightly smaller because a staffie left it in their pocket and it shrunk in the wash and also cog can't get the original resolution right now
	sizex = 408 + IMAGE_OFFSET_X
	sizey = 233 + IMAGE_OFFSET_Y

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_seneca.png")

/obj/item/paper/businesscard/cans
	name = "business card - Dented Cans"
	desc = "A dodgy looking flyer for what you hope is a scrap metal business."
	sizey = 345 + IMAGE_OFFSET_Y

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_dentedcans.png")

/obj/item/paper/businesscard/mabinogi
	name = "business card - Mabinogi"
	desc = "A sleek red and black business card for the Mabinogi Firearms Company."
	icon_state = "businesscard-mabinogi"
	sizey = 343 + IMAGE_OFFSET_Y

	New()
		..()
		info = PAPER_IMAGE_RENDER("images/arts/business_mabinogi.png")


/obj/item/paper/donut2smesinstructions
	name = "Donut 2 SMES Units and YOU"
	icon_state = "paper"
	info = {"
	----------------------------------------<br><br>
	Donut 2 SMES Units and YOU<br><br>

	A full guide to ensuring the station is powered up properly<br>
	----------------------------------------<br><br>
	Howdy Engineer, so you just set up this here SMES unit and you think you're done? Boy howdy do I have some news for you!<br><br>

	This here station has not just ONE, not just TWO, but FOUR SMES units set up to power up the entire main station. You might be thinking, 'So,
	Ms. Mysterious Engineer Who Knows Way More Than I Do, what does that mean?'<br><br>

	WELL! It means there's four SMES units and four power grids on the station! Finding them is pretty damn simple if I do say so myself, all you
	gotta do is walk around the inner loop of maintenance and find the SMES rooms. There's one just east of medbay, one just below arrivals and QM
	and one direction west of the bridge! Oh, there's also, uhh, you know, the one in Engineering.<br><br>

	Once you've got those four SMES units set you're all good. The singularity is a MARVEL of modern engineering and produces near ENDLESS power!<br><br>

	Oh, couple small things to add. There are a few solar panel groups in outer maintenance, but they're not wired to power the whole station at once
	so you would have to connect the four grids if you wanted, or needed, to run the station that way. Research Outpost Zeta also has its own solar
	panel setup, but it comes preconfigured and should last them well through any single shift, so you don't gotta worry about that none.<br><br><br>

	Keep that power flowing,<br>
	S.L.
	"}

#ifdef NIGHTSHADE
/obj/item/paper/gallery
	name = "Gallery submission guide"
	info = {"
		<span style="color:null;font-family:Georgia;">
		<p>Thank you for your interest in making a submission to the Nanotrasen Applied Paints Art Gallery!</p>
		<p>To make a submission:</p>
		<ol>
		<li>Use your completed canvas in hand on any gallery exhibit</li>
		<li>Pay the fee (see pricing below)</li>
		<li>(Optional) Title your submission and publicly display your BYOND key as the submitter</li>
		</ol>
		<p>Your artwork will remain on display indefinitely unless another artist decides to purchase your exhibit.</p>
		<p>Pricing (in Spacebux):</p>
		<ul>
		<li>Lowend (6x available) - 500</li>
		<li>Midrange (6x available) - 1,000</li>
		<li>Highend (2x available) - 2,500 </li>
		<li>Premium (1x available) - 5,000</li>
		</ul>
		</span>
	"}
#else
/obj/item/paper/gallery
	name = "Gallery submission guide"
	info = {"
		<span style="color:null;font-family:Georgia;">
		<p>Thank you for your interest in making a submission to the Nanotrasen Applied Paints Art Gallery!</p>
		<p>To make a submission:</p>
		<ol>
		<li>Use your completed canvas in hand on any gallery exhibit</li>
		<li>Pay the fee (see pricing below)</li>
		<li>(Optional) Title your submission and publicly display your BYOND key as the submitter</li>
		</ol>
		<p>Your artwork will remain on display indefinitely unless another artist decides to purchase your exhibit.</p>
		<p>Pricing (in Spacebux):</p>
		<ul>
		<li>Lowend (6x available) - 5,000</li>
		<li>Midrange (6x available) - 10,000</li>
		<li>Highend (2x available) - 25,000 </li>
		<li>Premium (1x available) - 50,000</li>
		</ul>
		</span>
	"}
#endif

/obj/item/paper/magnetconstruction
	name = "How to set up a new mining magnet"
	icon_state = "paper"
	info = {"
	----------------------------------------<br><br>
	How to build a set up a new mining magnet<br><br>

	A basic guide to construction a new mineral magnet for your mining operation<br>
	----------------------------------------<br><br>
	Thank you for purchasing your standard Mineral Magnet.<br>
	The following instructions should help you get your new mineral magnet constructed and configured properly.<br>
	If any of these steps are already completed you may skip them.<br><br>

	1. Build a border around the intended mining area with magnet chassis on the edge facing into mining area.<br>
	NOTE: Internal magnet area must be either 7x7 for the small size magnet or 15x15 for normal size magnet. Border must not be part of the internal magnet area.<br><br>


	2. Assemble magnet chassis outside of internal mining area and mining area border, facing the mining area.<br><br>

	3. Use mineral magnet parts on the magnet chassis to construct the mineral magnet.<br><br>

	4. Assemble mineral magnet control computer somewhere nearby that has power available.<br><br>

	5. Retrieve Magnetizer device and ensure it is loaded with raw plasmastone.<br><br>

	6. Link Magnetizer with assembled mineral magnet.<br><br>

	7. Go to bottom left area of internal magnet area and use magnetizer on the bottom left corner<br>
	NOTE: Must be the internal magnet area, not the border of the magnet area.<br><br>

	Congrats! Your mineral magnet is now assembled and ready for use!
	"}

/obj/item/paper/employee_notice
	name = "Employee reminder"
	icon_state = "paper"
	info = {"
	The backroom is currently locked for renovations and is unsafe.<br>
	DO NOT TRY AND ENTER! or ask questions, thats not what im paying you for.<br>
	-Larry
	"}

/obj/item/paper/laundry_purchase
	name = "Purchase confirmation"
	icon_state = "paper"
	info ={"
	Dear Mr. Lard, <br>

	Congratulations on being the proud owner of our new cutting edge portable laundry technology!<br>
	perfect for those long space trips.<br><br>

	<p>Purchase details:</p>
	<ul>
	<li>Port-A-Laundry - 50,000</li>
	<li>Tax - 2,500</li>
	<li>6 month warranty guarantee</li>
	</ul>

	<p>Consumer notice:</p>
	Do not under ANY circimstances put people or money into the machine.<br>
	your warranty will be void, you have been warned.
	"}

/obj/item/paper/final_notice
	name = "PAY UP LARRY"
	icon_state = "paper"
	info ={"
	You have been late on your payments one too many times... <br>
	Flake out this time and you will regret it. <br>
	You know where to find us larry, bring the money, 100,000 credits.
	"}

/obj/item/paper/radshuttle
	name = "bloody note"
	desc = "The bottom half of this paper is soaked in blood."
	icon_state = "paper_caution_bloody"
	info = {"<span style="color:red;font-family:Lucida Handwriting;">
	ten souls aboard<br>
	no food, no water, no medkids, the worst toilet in the universe,<br>
	all crammed into the space of the crew lounge.<br><br>

	Donnovan keeps looking at the engine compartment - hes scared.<br>
	seats by the back are blistering hot; the front is witch-tit cold.<br>
	probably has something to do with why people are throwing up so much.<br><br>

	this shuttle was a damn garbage scow ten hours ago! I dont deserve this! <br>
	I just had a bad performance review for the month! <br>
	station transfer my ass!<br>
	this whole damn thing is a detroit pink slip for ten people!<br><br>

	the others killed the security guard to to vent their anger,<br>
	another guy got beat so bad he crawled out the airlock.<br><br>

	Tonio is playing us farewell on that weird mouth organ. bless the man.<br>
	they took all my space cash before we left.<br>
	so I gave him my old lucky coin for a tip.<br>"}

/obj/item/paper/labdrawertips
	name = "stern lab safety warning"
	icon_state = "paper"
	info ={"
	I've had it with you nincompoops taking shortcuts. For the last
	time, <b> when you open the drawers under the lab counter,
	USE AN EMPTY HAND!</b> There's no excuse for you to be
	melting holes in the floor because you tried to grab a
	handle with the same hand that holds your beloved
	napalm-phlogiston-thermite """hell mix."""
	"}

/obj/item/paper/watchful_eye
	name = "MEMO: Deployment Notice"
	icon_state = "paper_caution_bloody"
	info ={"
	TO: WATCHFUL-EYE SENSOR ARRAY MAINTENANCE <br>
	FROM: OUTPOST OMICRON, NANOTRASEN-THINKTRONIC JOINT PROJECT <br>
	SUBJECT: SCHEDULED MAINTAINENCE <br>
	MESSAGE: <br>
	Reports show that one of the satellites in the array is acting up.
	The eye clusters there are allegedly behaving oddly, reporting
	false events, and there are rumours that someone has recalibrated
	them to track individuals instead of Typhon. Please investigate the
	source of the anomalous readings and let us know whether to decommission
	that satellite. The previous team didn't return, so proceed with caution.
	<br>

	We can still operate the array with only 15 out of the 30 satellites,
	due to safety (redundancy) policy. Still, we'd rather keep as many
	satellites in operation as we can. If the problem can be repaired, do so.

	<br> <br>
	Signed, <br>
	The office of Commodore Roland Yee
	"}

/obj/item/paper/watchful_eye/rev
	name = "Plan of attack."
	icon_state = "paper_singed"
	info ={"
	Steps: <br>
	1. assume control of eye sat 13. murder optional but probably required. implant <br>
	the maintainence crew tooo so we can ask them how it works.<br>
	2. hack the sensors to track non revs. figure it out when we get there with maint crew.<br>
	3. await further instuctions <br> <br>

	PS: turns out the eyes are ACTUAL eyes. Like weird space eyes?? no one told us that!!<br>
	How do you hack an eye?? <br> <br>

	PSS: we hacked the eye. hell yeah. okay technically we just hacked the satellite and <br>
	made the eye point at certain things but that's good enough for me. management can <br>
	do it themselves if they want it done properly. Fight me.<br>
	"}

/obj/item/paper/marionette_implant_readme
	name = "marionette implant readme"
	icon_state = "paper"
	info ={"
	<i>Once you're done reading these instructions, you may activate the provided self-destruct function by using them in your hand.</i>

	<h3>Summary</h3>
	<p>Congratulations on your purchase of our proprietary synaptic marionette implant!
	With these simple instructions, you'll be having the competition dancing to your tune in no time.</p>

	<h3>Control Remote</h3>
	<p>You should have received a control remote for easy convenience of using this implant.
	Using it will bring up a convenient interface capable of sending and receiving data from any linked implants.
	<u>You must use the implanter on the remote (or vice-versa) to link the two together.</u></p>

	<p>Once implanted into a target, simply use the remote to your heart's content! There is a short cooldown period between activations.</p>

	<p>The remote is programmed to interpret response signals sent by activated implants. If the activation triggered an effect successfully, the
	remote will bloop; if it failed -- whether due to the implantee being dead or the conditions for the effect not being met -- then the remote will
	rumble. Only the person holding the remote (hopefully you) and anyone sharing a space with them can hear these bloops and grumbles,
	although the button presses that come from actually using it are audible to anyone within a few tiles!</p>

	<p>When using a remote, the implant's passkey is not required. You don't need this value unless you plan to use packet control, detailed below.</p>

	<h3>Heat</h3>
	<p>Be wary that <u>each activation of an implant will cause heat buildup that may destroy it.</u> The components are delicate and are not built for
	repeated short-term stress. Heat will dissipate slowly over time. Heat will build up upon activation even if the conditions for the provided
	action are not met.</p>

	<h3>Packets</h3>
	<p>The provided remote should allow for easy and convenient use of any number of marionette implants. For power users, however, the implants are
	<b>fully compatible with wireless packets.</b> The implanter should list the frequency and network address of the contained implant,
	as well as a unique <b>passkey</b> that must be provided in the signal under the <code>passkey</code> parameter to authorize most signals.</p>

	<p>Packet functions are as follows. Commands marked with an asterisk function in dead bodies, so long as they're still fresh.</p>
	<ul>
	<li><b>ping</b> - Prompts the implant to send a signal containing information about its status. Passkey not required.
	<li><b>say</b> or <b>speak</b> - The implantee will say a provided phrase out loud, as provided in the <code>data</code> field. Max 45 characters.</li>
	<li><b>emote</b> - As <b>say</b>, but with an emote instead. Many emotes can't be replicated with this function, including but not limited to deathgasps,
	fainting, and tripping.</li>
	<li><b>move, step,</b> or <b>bump</b>* - The implantee will move one tile, with direction provided in the <code>data</code> field.
	These must be cardinals. You can use the full word, or just an abbreviation: <code>EAST</code> and <code>E</code> both work, for instance. Notably,
	this command will function even if the implantee is dead, as long as they haven't decomposed.</li>
	<li><b>shock</b> or <b>zap</b> - Shocks the implantee, disorienting them and draining stamina. This generates high heat.</li>
	<li><b>drop</b> or <b>release</b> - The implantee will release a held item from their hands.
	<li><b>use</b> or <b>activate</b> - The implantee will activate any item held in their hands.
	</ul>
	<p>To reiterate: when using packets to control an implant, you <b>must</b> provide the implant's unique passkey with the <code>passkey</code>
	parameter. An implant's passkey can be found by examining the implanter it comes in; make sure you write it down before using it, because there's
	no way to retrieve it once the implant is applied.</p>

	<p>Each time the implant is triggered, it will send a signal with the <code>activate</code> command to the device that activated it. If the activation was a success,
	the <code>stack</code> parameter will be empty; on a failure, it will provide an error code, detailed below.</p>

	<h4>Error Codes</h4>
	<ul>
	<li><code>TARG_DEAD</code> means that the implantee is deceased.</li>
	<li><code>TARG_NULL</code> means that the implant isn't inside a creature.</li>
	<li><code>INVALID</code> means that the command is invalid, or that the conditions for triggering the provided command were not met.</li>
	<li><code>BADPASS</code> means that the provided passkey is incorrect.</li>
	</ul></p>
	"}

	attack_self(mob/user)
		var/choice = tgui_alert(user, "What would you like to do with [src]?", "Use paper", list("Read", "Self-Destruct"))
		if (choice == "Read")
			src.examine(user)
		else
			var/turf/T = get_turf(src)
			new /obj/effect/supplyexplosion (T)
			playsound(T, 'sound/effects/ExplosionFirey.ogg', 50, TRUE)
			T.visible_message(SPAN_ALERT("\The [src] blows the heck up! Holy dang!!"))
			qdel(src)

/obj/item/paper/xg_tapes
	name = "XIANG|GIESEL Onboarding Course"
	desc = "A cover sheet meant to accompany a set of corporate training materials."
	icon_state = "paper_burned"
	sizex = 718 + IMAGE_OFFSET_X
	sizey = 1023 + IMAGE_OFFSET_Y
	scrollbar = FALSE

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)
		info = PAPER_IMAGE_RENDER("images/arts/xg_tapes.png")

#undef IMAGE_OFFSET_X
#undef IMAGE_OFFSET_Y

/obj/item/paper/wanderpoem
	name = "A freshly written poem"
	icon = 'icons/misc/wander_stuff.dmi'
	icon_state = "paper-red"
	info = {"
	<span style="color:red;font-family:Lucida Handwriting;">
	<p> Winter arrived. <p> <br>
	<p>Winter arrived years ago, <p> <br>
	<p>its frost creeping into that well churned soil. <p> <br>
	<p>My world grew silent as the crystalline cold silenced the birds, <p> <br>
	<p>made fallow the fields. <p> <br>
	<p>Is winter not what one would wish for when aggrieved by that summer of sweltering hysteria. <p> <br>
	<p>Those that bound me to then had wilted into the soil, their flowers turning to drifting dust. <p> <br>
	<p>The fields of chance further grew only that which could harm me, <p> <br>
	<p>the cacophonous cries surrounding served only to create doubt where none could be left. <p> <br>
	<p>Quietus came and offered its hand to me, <p> <br>
	<p>I took it. <p> <br> <br>

	<p>Its hand froze all in perfect peace, <p> <br>
	<p>I looked out into a world of pure white. <p> <br>
	<p>In contradiction, I embraced this death with one hand, <p> <br>
	<p>yet could not tear another from the only warmth that remained. <p> <br>
	<p>That dithering flame wandered among the kindling I had set for it, <p> <br>
	<p>it leaped to and fro from precious branch to branch. <p> <br>
	<p>I came to understand more of myself then, <p> <br>
	<p>I understood that this part of myself could not be excised. <p> <br>
	<p>Peace was more than an end, <p> <br>
	<p>more than the winter of a soul. <p> <br>
	<p>Spring came, <p> <br>
	<p>spring came at last. <p> <br>
	"}

/obj/item/paper/packets
	name = "Frequency reference sheet"
	New()
		..()
		info = {"
			<h2>Nanotrasen wireless technology data reference sheet 8.2</h2>
			<table>
				<tr>
					<th>Category</th>
					<th>Frequency</th>
				</tr>

			<tr><td>PDAs</td><td>[format_frequency(FREQ_PDA)]kHz</td></tr>
			<tr><td>Gas pumps</td><td>[format_frequency(FREQ_PUMP_CONTROL)]kHz</td></tr>
			<tr><td>Airlocks</td><td>[format_frequency(FREQ_AIRLOCK)]kHz</td></tr>
			<tr><td>Designated free frequency</td><td>[format_frequency(FREQ_FREE)]kHz</td></tr>
			<tr><td>Bot navbeacons</td><td>[format_frequency(FREQ_NAVBEACON)]kHz</td></tr>
			<tr><td>Secure storage</td><td>[format_frequency(FREQ_SECURE_STORAGE)]kHz</td></tr>
			<tr><td>Fire and air alarms</td><td>[format_frequency(FREQ_ALARM)]kHz</td></tr>
			<tr><td>Hydroponics trays</td><td>[format_frequency(FREQ_HYDRO)]kHz</td></tr>
			<tr><td>Harmonic siphon</td><td>[format_frequency(FREQ_HARMONIC_SIPHON)]kHz</td></tr>
			<tr><td>Transception interlink</td><td>[format_frequency(FREQ_TRANSCEPTION_SYS)]kHz</td></tr>
			<tr><td>Status displays</td><td>[format_frequency(FREQ_STATUS_DISPLAY)]kHz</td></tr>
			<tr><td>Bot control</td><td>[format_frequency(FREQ_BOT_CONTROL)]kHz</td></tr>
			<tr><td>GPS</td><td>[format_frequency(FREQ_GPS)]kHz</td></tr>
			<tr><td>Ruckingenur kit</td><td>[format_frequency(FREQ_RUCK)]kHz</td></tr>
			<tr><td>Guardbuddies</td><td>[format_frequency(FREQ_BUDDY)]kHz</td></tr>
			<tr><td>Tourbot navbeacons</td><td>[format_frequency(FREQ_TOUR_NAVBEACON)]kHz</td></tr>
			<tr><td>Signalers</td><td>[format_frequency(FREQ_SIGNALER)]kHz</td></tr>
			<tr><td>Pod door controls</td><td>[format_frequency(FREQ_DOOR_CONTROL)]kHz</td></tr>
			<tr><td>Mail chutes</td><td>[format_frequency(FREQ_MAIL_CHUTE)]kHz</td></tr>
			<tr><td>Air alarm control</td><td>[format_frequency(FREQ_AIR_ALARM_CONTROL)]kHz</td></tr>
			<tr><td>Tracking implants</td><td>[format_frequency(FREQ_TRACKING_IMPLANT)]kHz</td></tr>
			<tr><td>Power systems</td><td>[format_frequency(FREQ_POWER_SYSTEMS)]kHz</td></tr>
			<tr><td>Armory authorization \[RESTRICTED\]</td><td>[format_frequency(FREQ_ARMORY)]kHz</td></tr>
			</table>
			<br><br>
			<i>Intelligent data ordering system proprietary, copyright of Nanotrasen (2053)</i>
		"}

//TODO: maybe a stamp for the classified thing?
//also apparently W3schools lied to me and there is no websafe handwriting font, so these just default to Times >:(
/obj/item/paper/pipebombs
	name = "\improper Terra cell improvised explosive manual"
	icon_state = "paper_burned"
	var/detonating = FALSE

	New()
		. = ..()
		RegisterSignal(src, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(turf_changed))
		info = {"
		<h2>\[FOR TERRA EYES ONLY\]</h2>
		<b>Warning: this paper will self destruct if removed from listening outpost [rand(1,19)][pick("A", "B", "θ")].</b><br><br>
		The pipebomb is the workhorse of the syndicate infiltrator on a budget. The... highly explosive workhorse.<br><br>
		<b>Step 1:</b> Form three metal sheets into a pipe frame.<br>
		<b>Step 2:</b> Weld them up nice and tight. Eye protection is <strike>recommended</strike> <span style="color:red;font-family:Brush Script MT;">for NERDS.</span><br>
		<b>Step 3:</b> Add your payload. A lot of mundane things can produce some surprisingly nasty effects when shoved into a pipebomb so creativity is recommended. Here's a list of the more "effective" options:
		<ul>
			<li>Glass shards and metal scrap: Yeah take a guess what these do. Simple but effective at hurting people.</li>
			<li>Glowsticks: splashes victims with a little boiling radium. Nasty.</li>
			<li>Cloth: deadens the explosion, making it five times less powerful. Sounds useless but sometimes you want the attention to be on the other things you've stuck in your pipebomb.</li>
			<li>Detached human butts: ██████ ███ █████, ██ ████ █████ -<span style="color:blue;font-family:Gochi Hand;">what the FUCK? NO! WHY WOULD YOU DO THAT??</span></li>
			<li>Telecrystals: Hemera scientists will tell you blowing up telecrystals can lead to "catastrophically unstable telepositional events". Sounds like fun!</li>
			<li>RCD cartridges: randomly punches holes in the floor and builds grilles out of compressed matter.</li>
			<li>Wires and power cells: putting both wire and a cell in your bomb will cause high voltage arcs from the point of detonation.</li>
			<li>Plasmastone: releases a substantial amount of plasma gas upon detonation. <span style="font-family:Brush Script MT;">NB: this isn't very useful if you just blew a hole in the hull - maybe try combining with cloth?</span></li>
		</ul>
		Remember you can usually only fit three items total into a pipe frame.<br>
		<b>Step 4:</b> Pour something flammable into the frame. Generally the more angrily it burns the bigger the boom you'll make.<br>
		<b>Step 5:</b> Tangle some wires around it. Don't worry about wiring diagrams, this thing only has to work <i>once.</i><br>
		<b>FINAL STEP:</b> Stick a timer on it and resist pressing the button until you're near your target.<br><br>

		Good luck, agent. Try not to blow the bloody doors off the listening post this time.
		"}

	proc/turf_changed(atom/thing, turf/old_turf, turf/new_turf)
		if (!src.detonating && !istype(new_turf?.loc, /area/listeningpost))
			src.detonating = TRUE
			visible_message(SPAN_ALERT("The paper starts to beep. Huh??"))
			SPAWN(-1)
				playsound(src.loc, 'sound/machines/twobeep.ogg', 30, FALSE, pitch = 0.9)
				sleep(1 SECOND)
				playsound(src.loc, 'sound/machines/twobeep.ogg', 30, FALSE, pitch = 1.2)
				sleep(1 SECOND)
				playsound(src.loc, 'sound/machines/twobeep.ogg', 30, FALSE, pitch = 1.4)
				sleep(1 SECOND)
				src.blowthefuckup(0.5)
	disposing()
		. = ..()
		UnregisterSignal(src, XSIG_MOVABLE_TURF_CHANGED)
