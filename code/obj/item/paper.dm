#define PAPER_MODE_READING 0
#define PAPER_MODE_WRITING 1
#define PAPER_MODE_STAMPING 2
#define PAPER_MAX_LENGTH 5000
#define PAPER_MAX_STAMPS 30
#define PAPER_MAX_STAMPS_OVERLAYS 4

#define STAMP_IDS list(\
	"Clown" = "stamp-sprite-clown",\
	"Denied" = "stamp-sprite-deny" ,\
	"Granted" = "stamp-sprite-ok",\
	"Head of Personnel" = "stamp-sprite-hop",\
	"Medical Director" = "stamp-sprite-md",\
	"Chief Engineer" = "stamp-sprite-ce",\
	"Head of Security" = "stamp-sprite-hos",\
	"Research Director" = "stamp-sprite-rd",\
	"Captain" = "stamp-sprite-cap",\
	"Quartermaster" = "stamp-sprite-qm",\
	"Security" = "stamp-sprite-law",\
	"Chaplain" = "stamp-sprite-chap",\
	"Mime" = "stamp-sprite-mime",\
	"Centcom" = "stamp-sprite-centcom",\
	"Syndicate" = "stamp-sprite-syndicate",\
	"Void" = "stamp-sprite-void",\
	"Your Name" = "stamp-text-name",\
	"Current Time" = "stamp-text-time",)

/obj/item/paper
	name = "paper"
	icon = 'icons/obj/writing.dmi'
	icon_state = "paper_blank"
	uses_multiple_icon_states = 1
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	var/info = ""
	var/stampable = 1
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 3
	throw_range = 15
	layer = OBJ_LAYER
	//cogwerks - burning vars
	burn_point = 220
	burn_output = 900
	burn_possible = 2
	var/list/form_startpoints
	var/list/form_endpoints
	var/font_css_crap = null
	var/list/fonts = list()

	var/stampNum = 0
	var/sizex = 0
	var/sizey = 0
	var/offset = 0

	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0

	var/sealed = 0 //Can you write on this with a pen?
	var/list/stamps = null
	var/list/form_fields = list()
	var/field_counter = 1

/obj/item/paper/New()
	..()
	src.create_reagents(10)
	reagents.add_reagent("paper", 10)
	SPAWN(0)
		if (src.info && src.icon_state == "paper_blank")
			icon_state = "paper"
	if (!src.rand_pos)
		return
	else
		src.pixel_y = rand(-8, 8)
		src.pixel_x = rand(-9, 9)

/obj/item/paper/examine(mob/user)
	. = ..()
	ui_interact(user)

/obj/item/paper/custom_suicide = 1
/obj/item/paper/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	user.visible_message("<span class='alert'><b>[user] cuts [him_or_her(user)]self over and over with the paper.</b></span>")
	user.TakeDamage("chest", 150, 0)
	return 1

/obj/item/paper/attack_self(mob/user as mob)
	var/menuchoice = tgui_alert(user, "What would you like to do with [src]?", "Use paper", list("Fold", "Read", "Nothing"))
	if (!menuchoice || menuchoice == "Nothing")
		return
	else if (menuchoice == "Read")
		src.examine(user)
	else
		var/fold = tgui_alert(user, "What would you like to fold [src] into?", "Fold paper", list("Paper hat", "Paper plane", "Paper ball"))
		if(src.disposed || !fold) //It's possible to queue multiple of these menus before resolving any.
			return
		user.u_equip(src)
		if (fold == "Paper hat")
			user.show_text("You fold the paper into a hat! Neat.", "blue")
			var/obj/item/clothing/head/paper_hat/H = new()
			user.put_in_hand_or_drop(H)
		else
			var/obj/item/paper/folded/F = null
			if (fold == "Paper plane")
				user.show_text("You fold the paper into a plane! Neat.", "blue")
				F = new /obj/item/paper/folded/plane(user)
			else
				user.show_text("You crumple the paper into a ball! Neat.", "blue")
				F = new /obj/item/paper/folded/ball(user)
			F.info = src.info
			F.old_desc = src.desc
			F.old_icon_state = src.icon_state
			user.put_in_hand_or_drop(F)

		qdel(src)

/obj/item/paper/attack_ai(var/mob/AI as mob)
	var/mob/living/silicon/ai/user
	if (isAIeye(AI))
		var/mob/living/intangible/aieye/E = AI
		user = E.mainframe
	else
		user = AI
	if (!isAI(user) || (user.current && GET_DIST(src, user.current) < 2)) //Wire: fix for undefined variable /mob/living/silicon/robot/var/current
		var/font_junk = ""
		for (var/i in src.fonts)
			font_junk += "<link href='http://fonts.googleapis.com/css?family=[i]' rel='stylesheet' type='text/css'>"
		usr.Browse("<HTML><HEAD><TITLE>[src.name]</TITLE>[font_junk]</HEAD><BODY><TT>[src.info]</TT></BODY></HTML>", "window=[src.name]")
		onclose(usr, "[src.name]")
	return

/obj/item/paper/proc/stamp(x, y, r, stamp_png, icon_state)
	if(length(stamps) < PAPER_MAX_STAMPS)
		var/list/stamp_info = list(list(stamp_png, x, y, r))
		LAZYLISTADD(stamps, stamp_info)
	if(icon_state)
		var/image/stamp_overlay = image('icons/obj/writing.dmi', "paper_[icon_state]");
		var/matrix/stamp_matrix = matrix()
		stamp_matrix.Scale(1, 1)
		stamp_matrix.Translate(rand(-2, 2), rand(-3, 2))
		stamp_overlay.transform = stamp_matrix
		src.UpdateOverlays(stamp_overlay, "stamps_[length(stamps) % PAPER_MAX_STAMPS_OVERLAYS]")

/obj/item/paper/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaperSheet")
		ui.open()

/obj/item/paper/ui_status(mob/user,/datum/ui_state/state)
	if(!user.literate)
		boutput(user, "<span class='alert'>You don't know how to read.</span>")
		return UI_CLOSE
	if(istype(src.loc, /obj/item/clipboard))
		if (isliving(user))
			var/mob/living/L = user
			return L.shared_living_ui_distance(src, viewcheck = FALSE)
		else
			return UI_UPDATE // ghosts always get updates
	. = max(..(), UI_DISABLED)
	if(IN_RANGE(user, src, 8))
		. = max(., UI_UPDATE)

/obj/item/paper/ui_act(action, params,datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(src.sealed)
		boutput(usr, "<span class='alert'>You can't do that while [src] is folded up.</span>")
		return
	switch(action)
		if("stamp")
			if(!src.stampable)
				boutput(usr, "<span class='alert'>You can't stamp [src].</span>")
				return
			var/stamp_x = text2num_safe(params["x"])
			var/stamp_y = text2num_safe(params["y"])
			var/stamp_r = text2num_safe(params["r"])	// rotation in degrees
			var/obj/item/stamp/stamp = ui.user.equipped()

			if(length(stamps) < PAPER_MAX_STAMPS)
				stamp(stamp_x, stamp_y, stamp_r, stamp.current_state, stamp.icon_state)
				update_static_data(usr, ui)
				boutput(usr, "<span class='notice'>[ui.user] stamps [src] with \the [stamp.name]!</span>")
				playsound(usr.loc, 'sound/misc/stamp_paper.ogg', 50, 0.5)
			else
				boutput(usr, "There is no where else you can stamp!")
			. = TRUE

		if("save")
			if (src.icon_state == "paper_blank" && params["text"])
				src.icon_state = "paper"
			var/in_paper = params["text"]
			var/paper_len = length(in_paper)

			field_counter = params["fieldCounter"] ? text2num_safe(params["fieldCounter"]) : field_counter

			if(paper_len > PAPER_MAX_LENGTH)
				// Side note, the only way we should get here is if
				// the javascript was modified, somehow, outside of
				// byond.  but right now we are logging it as
				// the generated html might get beyond this limit
				logTheThing(LOG_DEBUG, src, "PAPER: [key_name(ui.user)] writing to paper [name], and overwrote it by [paper_len-PAPER_MAX_LENGTH]")
			if(paper_len == 0)
				boutput(ui.user, pick("Writing block strikes again!", "You forgot to write anthing!"))
			else
				if(info != in_paper)
					boutput(ui.user, "You write on \the [src]!");
					info = in_paper
					update_static_data(usr,ui)
			. = TRUE

/obj/item/paper/ui_static_data(mob/user)
	. = list(
		"name" = src.name,
		"sizeX" = src.sizex,
		"sizeY" = src.sizey,
		"text" = src.info,
		"max_length" = PAPER_MAX_LENGTH,
		"paperColor" = src.color || "white",	// color might not be set
		"stamps" = src.stamps,
		"stampable" = src.stampable,
		"sealed" = src.sealed,
	)

/obj/item/paper/ui_data(mob/user)
	. = list(
		"editUsr" = "[user]",
		"fieldCounter" = field_counter,
		"formFields" = form_fields,
	)

	var/obj/O = user.equipped()
	var/time_type = istype(O, /obj/item/stamp/clown) ? "HONK O'CLOCK" : "SHIFT TIME"
	var/T = ""
	T = time_type + ": [time2text(world.timeofday, "DD MMM 2053, hh:mm:ss")]"

	// TODO: change this awful array name & stampAssetType
	var/stamp_assets = list(
		"stamp-sprite-clown" = "[resource("images/tgui/stamp_icons/stamp-clown.png")]",
		"stamp-sprite-deny" = "[resource("images/tgui/stamp_icons/stamp-deny.png")]",
		"stamp-sprite-ok" = "[resource("images/tgui/stamp_icons/stamp-ok.png")]",
		"stamp-sprite-hop" = "[resource("images/tgui/stamp_icons/stamp-hop.png")]",
		"stamp-sprite-md" = "[resource("images/tgui/stamp_icons/stamp-md.png")]",
		"stamp-sprite-ce" = "[resource("images/tgui/stamp_icons/stamp-ce.png")]",
		"stamp-sprite-hos" = "[resource("images/tgui/stamp_icons/stamp-hos.png")]",
		"stamp-sprite-rd" = "[resource("images/tgui/stamp_icons/stamp-rd.png")]",
		"stamp-sprite-cap" = "[resource("images/tgui/stamp_icons/stamp-cap.png")]",
		"stamp-sprite-qm" = "[resource("images/tgui/stamp_icons/stamp-qm.png")]",
		"stamp-sprite-law" = "[resource("images/tgui/stamp_icons/stamp-law.png")]",
		"stamp-sprite-chap" = "[resource("images/tgui/stamp_icons/stamp-chap.png")]",
		"stamp-sprite-mime" = "[resource("images/tgui/stamp_icons/stamp-mime.png")]",
		"stamp-sprite-centcom" = "[resource("images/tgui/stamp_icons/stamp-centcom.png")]",
		"stamp-sprite-syndicate" = "[resource("images/tgui/stamp_icons/stamp-syndicate.png")]",
		"stamp-sprite-void" = "[resource("images/tgui/stamp_icons/stamp-void.png")]",
		"stamp-text-time" =  T,
		"stamp-text-name" = user.name
	)

	if(!istype(O, /obj/item/pen))
		if(istype(src.loc, /obj/item/clipboard))
			var/obj/item/clipboard/C = src.loc
			if(istype(C.pen, /obj/item/pen))
				O = C.pen
		if(istype(src.loc, /obj/item/portable_typewriter))
			var/obj/item/portable_typewriter/typewriter = src.loc
			if(istype(typewriter.pen, /obj/item/pen))
				O = typewriter.pen
	if(istype(O, /obj/item/pen))
		var/obj/item/pen/PEN = O
		. += list(
			"penFont" = PEN.font,
			"penColor" = PEN.color,
			"editMode" = PAPER_MODE_WRITING,
			"isCrayon" = FALSE,
			"stampClass" = "FAKE",
		)
	else if(istype(O, /obj/item/stamp))
		var/obj/item/stamp/stamp = O
		stamp.current_state = stamp_assets[stamp.current_mode]
		. += list(
			"stampClass" = stamp_assets[stamp.current_mode],
			"editMode" = PAPER_MODE_STAMPING,
			"penFont" = "FAKE",
			"penColor" = "FAKE",
			"isCrayon" = FALSE,
		)
	else
		. += list(
			"editMode" = PAPER_MODE_READING,
			"penFont" = "FAKE",
			"penColor" = "FAKE",
			"isCrayon" = FALSE,
			"stampClass" = "FAKE",
		)

/obj/item/paper/attackby(obj/item/P, mob/living/user, params)
	if(istype(P, /obj/item/portable_typewriter))
		return // suppress attack sound, the typewriter will load the paper in afterattack
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/pen/crayon))
		if(src.sealed)
			boutput(user, "<span class='alert'>You can't write on [src].</span>")
			return
		if(length(info) >= PAPER_MAX_LENGTH) // Sheet must have less than 1000 charaters
			boutput(user, "<span class='warning'>This sheet of paper is full!</span>")
			return
		ui_interact(user)
		return
	else if(istype(P, /obj/item/stamp))
		if(src.sealed)
			boutput(user, "<span class='alert'>You can't stamp [src].</span>")
			return
		boutput(user, "<span class='notice'>You ready your stamp over the paper! </span>")
		ui_interact(user)
		return // Normaly you just stamp, you don't need to read the thing
	else if (issnippingtool(P))
		boutput(user, "<span class='notice'>You cut the paper into a mask.</span>")
		playsound(src.loc, 'sound/items/Scissor.ogg', 30, 1)
		var/obj/item/paper_mask/M = new /obj/item/paper_mask(get_turf(src.loc))
		user.put_in_hand_or_drop(M)
		user.u_equip(src)
		qdel(src)
	else if (istype(P, /obj/item/paper))
		var/obj/item/staple_gun/S = user.find_type_in_hand(/obj/item/staple_gun)
		if (S?.ammo)
			var/obj/item/paper_booklet/booklet = new(src.loc)
			user.drop_item()
			booklet.pages += src
			src.set_loc(booklet)
			booklet.Attackby(P, user, params)
			return
		else
			boutput(user, "<span class='alert'>You need a loaded stapler in hand to staple the sheets into a booklet.</span>")
	else
		// cut paper?  the sky is the limit!
		ui_interact(user)	// The other ui will be created with just read mode outside of this

	return ..()

/obj/item/paper/proc/build_fields(var/length)
	var/pixel_width = (14 + (12 * (length-1)))
	src.field_counter++
	return {"\[<input type="text" style="font:'12x Georgia';color:'null';min-width:[pixel_width]px;max-width:[pixel_width]px;" id="paperfield_[field_counter]" maxlength=[length] size=[length] />\]"}


/obj/item/paper/thermal
	name = "thermal paper"
	stampable = 0
	icon_state = "thermal_paper"
	sealed = 1
	item_function_flags = SMOKELESS

/obj/item/paper/thermal/portable_printer
	sealed = 0

/obj/item/paper/alchemy/
	name = "'Chemistry Information'"

/*
 *	Cloning Manual -- A big ol' manual.
 */

/obj/item/paper/Cloning
	name = "'H-87 Cloning Apparatus Manual"
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
	info = "Equipment:<BR>\n\t1+ Tank(s) with appropriate atmosphere<BR>\n\t1 Gas Mask w regulator (standard issue)<BR>\n<BR>\nProcedure:<BR>\n\t1. Wear mask<BR>\n\t2. Attach oxygen tank pipe to regulater (automatic))<BR>\n\t3. Set internal!<BR>\n<BR>\nNotes:<BR>\n\tDon't forget to stop internal when tank is low by<BR>\n\tremoving internal!<BR>\n<BR>\n\tDo not use a tank that has a high concentration of toxins.<BR>\n\tThe filters shut down on internal mode!<BR>\n<BR>\n\tWhen exiting a high danger environment it is advised<BR>\n\tthat you exit through a decontamination zone!<BR>\n<BR>\n\tRefill a tank at a oxygen canister by equiping the tank (Double Click)<BR>\n\tthen 'attacking' the canister (Double Click the canister)."

/obj/item/paper/Court
	name = "'Judgement'"
	info = "For crimes against the station, the offender is sentenced to:<BR>\n<BR>\n"

/obj/item/paper/HangarGuide
	name ="'Ship Basics'"
	info ={"In order to open the hangar doors, either look-up the password via the hangar control computer, or use the handy button near every hangar to get it.<BR>
		In order to uninstall and install parts use a crowbar on a ship to open the maintenance panel, If you want to install a part, simply use the part on the ship.
		If you want to uninstall a part simply use an empty hand on the maintenance panel. Make sure to close the panel when you are done.<br>
		In order to use the cargo loader on a crate, simply make ensure the crate is behind the ship, and the loader will handle the rest."}

/obj/item/paper/Map
	name = "'Station Blueprint'"

	New()
		..()
		src.info = {"<IMG SRC="[resource("images/map.png")]">
<BR>
CQ: Crew Quarters<BR>
L: Lounge<BR>
CH: Chapel<BR>
ENG: Engine Area<BR>
EC: Engine Control<BR>
ES: Engine Storage<BR>
GR: Generator Room<BR>
MB: Medical Bay<BR>
MR: Medical Research<BR>
TR: Toxin Research<BR>
TS: Toxin Storage<BR>
AC: Atmospheric Control<BR>
SEC: Security<BR>
SB: Shuttle Bay
SA: Shuttle Airlock<BR>
S: Storage<BR>
CR: Control Room<BR>
EV: EVA Storage<BR>
AE: Aux. Engine<BR>
P: Podbay<BR>
NA: North Airlock<BR>
SC: Solar Control<BR>
ASC: Aux. Solar Control<BR>
"}

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
	anchored = 1

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
	info = {"<h3 style="border-bottom: 1px solid black; width: 80%;">Nanotrasen Toxins Research</h3>
<tt>
<strong>MEMORANDUM &nbsp; &nbsp; * CONFIDENTIAL *</strong><br>
<br><strong>DATE:</strong> 02/19/53
<br><strong>FROM:</strong> NT Research Division.
<br><strong>TO:&nbsp&nbsp;</strong> Space Station 13's Research Director
<br><strong>SUBJ:</strong> Toxins Research Project #08-A
<br>
<p>
The enclosed samples are to be used in continued plasma research.  Our current understanding is that the gas released from "Molitz Beta" in the presence of
sufficient temperatures and plasma cause an unusual phenomenon. The gas, Oxygen Agent B, seems to disrupt the typical equilibrium formed in exothermic oxidation
allowing for temperatures we have been unable to fully realize. This only seems to occur when combustion is incomplete and can be observed visually as a gentle swirling of the flame.
</p>
<p>
Please exercise caution in your testing, the result can best be described as a hellfire.  Ensure adequate safety messures are in place to purge the fire.
</p>
<p>All findings and documents related to Project #08-A are to be provided in triplicate to CentComm on physical documents only. <b>DO NOT</b> provide this data digitally
as it may become compromised.
</p>
</tt>
<center><span style="font-family: 'Dancing Script';">Is this a Hellburn???!!?</span></center>"}

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
	info = {"Some fucking asshole broke into our vault all by themselves! How the hell did they even manage that?<br>
			<br>
			They messed with the <b><i>Ouroboros Engine</i></b> and those dumb fucks blew up most of the vault too. Nearly blinded myself looking at all that gold.
			They must have tried using that alchemy stone without a conduit, damn lucky the damage wasn't spread any further<br>
			<br>
			Sent the NTSOs off to the remains of Site Tempus on that dead planet again to hopefully recover the artifact. Gunna need it to revert this place back
			to how it was. Thank god we were able to recover the Engine.<br>
			<br>
			Up your bloody security before this happens again. You know how dangerous using that artifact is. We'll be the ones blowing up next time. Or worse!"}

/obj/item/paper/stay_out_of_my_office
	name = "Go Away!"
	info = {"Don't touch my stuff dork!<br>"}


/obj/item/paper/ACNote
	name = "hastily scribbled note"
	info = {"I still don't understand the drawings I drew or the words I wrote... or the words you whisper to me.<br>
			<br>
			 Even now on my journey to understand I still see your face looking at me from the shadows.<br>
			 <br>
			 Maybe I was just around you for too long...And your unchanging face.<br>
			 <br>
			 I will be back to save you soon. We promised to escape together, remember?<br>
			 <br>
			 -A.C"}

/obj/item/paper/mantasegways
    name = "paper - Where are the security segways?"
    icon_state = "paper"
    info = {"<h4>Where are the security segways?</h4><br>
    Many of you have asked "where are the security segways?". Well let me tell you that we finally got rid of those filthy stains on the cover of the Space Law
	and permanently brigged them in some warehouse on the ship.
    <br>
    Now quit bothering us with your nonsensical questions and get back to work!
    <br>
    <font size=1>- Head of Security </font>"}

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

/obj/item/paper/cdc_pamphlet
	name = "So you've contracted a pathogen!"
	icon_state = "paper"
	info = {"<center><h2>So you've contracted a pathogen!</h2></center>
	Hello, dear customer!<hr>
	Pathogens can be scary! But you can rest easy knowing that your health is in safe hands now that you have contacted the CDC. Simply place a pathogen
	sample into the biohazard crate and send it back to us and we will have you cured in no time!<hr>
	<h3>How to send a pathogen sample</h3><hr>
	<ul style='list-style-type:disc'>
		<li>1) Fill a reagent container with a blood sample from a person afflicted with the pathogen you are seeking to cure. (For instance, you could use the syringe we sent you!)</li>
		<li>2) Deposit reagent container into the received biohazard crate and close it.</li>
		<li>3) Send the biohazard crate back to us.</li>
		<li>4) As soon as we receive your sample, you can contact us using your Quartermaster's Console to ask us to start analyzing it.</li>
		<li>5) Once we are done analyzing your sample, we will offer to sell you cures. Buying a pack of multiple cures at a time will be cheaper for you!</li>
	</ul>
	We hope that you have found this pamphlet enlightening and we look forward to receiving your sample soon!<hr>
	Remember, only you can prevent deadly pathogens!
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
	desc = "Scibbled rhymes...and thoughts."
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

/obj/item/paper/fortune
	name = "fortune"
	info = {"<center>YOUR FORTUNE</center>"}
	desc = "A slip of paper with a life-changing prophecy printed on it."
	icon_state = "fortune"

	var/static/list/action = list("Beware of", "Keep an eye on", "Seek out", "Be wary of", "Make friends with", "Aid", "Talk to", "Avoid")
	var/static/list/who = list("Officer Beepsky", "Shambling Abomination", "Remy", "Dr. Acula", "Morty", "Sylvester", "Jones", "the staff assistant next to you", "the clown")
	var/static/list/thing = list("are in possession of highly dangerous contraband.", "murdered a bee.", "kicked George.", "are a Syndicate operative.", "are a murderer.", "have disguised themselves from their true form.",
	"are not who they claim to be.", "know Shitty Bill's secret.", "are lonely.", "hugged a space bear and survived to tell the tale.", "know the legendary double-fry technique.", "have the power to reanimate the dead.",
	"consort with wizards.", "sell really awesome drugs.", "have all-access.", "know the king.", "make amazing pizza.", "have a toolbox and are not afraid to use it.")
	var/static/list/general = list("NanoTrasen locked me to this desk and is forcing me to make fortunes for these cookies please help!", "Help I'm trapped in this cookie!", "Buy Discount Dan's today!")
	var/static/list/sol = list("He plunged into the sea.", "Follow the NSS Polaris.", "Across the Channel.", "It's in the Void.")
	var/static/initialized = FALSE

	New()
		var/randme = rand(1,10)
		var/fortune = "Blah."

		if(!initialized)
			initialized = TRUE
			for(var/datum/db_record/t as anything in data_core.general.records)
				who += "[t["name"]]"

		switch(randme)
			if(1)
				fortune = "[pick(sol)]"
			if(2)
				fortune = "[pick(general)]"
			else
				fortune = "[pick(action)] [pick(who)] for they [pick(thing)]"

		info = {"<font face='System' size='3'><center>YOUR FORTUNE</center><br><br>
		Discount Dan's is the proud sponsor of your magical fortune. Whether good or bad, delightful or alarming, know it to be true.<br><br>
		[fortune]</font>"}
		..()


/obj/item/paper/thermal/fortune
	name = "fortune"
	info = {"<center>YOUR FORTUNE</center>"}
	desc = "A thermal print."

	var/list/fortune_mystical = list("fortunes","fate","doom","life","death","rewards","secrets","omens",
	"portents","aura","heart","soul","mind","mysteries","destiny","signs","essence","runes")

	var/list/fortune_nouns = list("curse","crime", "wizard", "station","traitor", "treasure","gold","monster",
	"beast","machine","ghost","spirit","station","friend","enemy","captain","doctor","assistant","chef","priest",
	"cat","skull","skeleton","phantasm","aeon","cenotaph","monument","planet","ritual","ceremony","sound","color",
	"reward","owl","key","buddy","bee","god","gods","sun","stars","crypt","cave","grave","potion","elixir","spectre",
	"clown","moon","crystals","keys","robot","cyborg","book","orb","cube","apparition","oracle","king","crown","rumpus",
	"throne","light","darkness","abyss","void","fire","entity","horde","swarm","horrors","legions","nightmare","vampire",
	"ossuary","portal","shade","stone","talisman","statue","artifact","tomb","urn","pit","depths","blood","ruckus","abomination",
	"tome","relic","serum","instrument","fungus","garden","cult","implement","device","engine","manuscript","tablet","ambrosia",
	"watcher","asteroid","drone","servant","blade","coins","amulet","sigil","symbol","coven","pact","sanctuary","grove",
	"ruin","guide","mirror","pool","chalice","bones","ashes")

	var/list/fortune_verbs = list("murder","kill","hug","meet","greet","punish","devour","exsanguinate","find","destroy","sacrifice",
	"dehumanize","reveal","cuddle","haunt","frighten","harm","sass","respect","obey","worship","revere",
	"fear","smash","banish","corrupt","profane","exhume","purge","torment","betray","eradicate","obliterate",
	"immolate","slay","confront","exalt","sing praises to","abhor","denounce","condemn","venerate","glorify",
	"deface","debase","consecrate","desecrate","summon","expunge","invoke","rebuke","awaken","consume","vilify",
	"forsake","consecrate","mourn","butcher","illuminate")

	var/list/fortune_adjectives = list("grumpy","zesty","omniscient","golden","mystical","forgotten","lost","ancient","metal","brass",
	"eldritch","warped","frozen","martian","robotic","burning","copper","dead","undying","unholy","fabulous","mighty",
	"elder","hellish","heavenly","antiquated","automated","mechanical","dread","grotesque","mysterious","auspicious",
	"screaming","rusted","iron","scary","terrifying","horrid","antique","austere","burly","dapper","dutiful",
	"enlightened","fearless","gleaming","glowing","grim","gray","gruesome","handsome","hideous","horrible",
	"ill-fated","star-crossed","impure","jaunty","nocturnal","metallic","monstrous","marvelous","prestigious",
	"quaint","radiant","robust","regal","shameful","shimmering","silent","silver","sinful","smug","tragic",
	"terrible","terrific","vast","weird","electrical","technicolor","quantum","heroic","villainous","dastardly","evil",
	"enchanted","accursed","haunted","malicious","macabre","sinister","mortal","immortal","sacred","eerie",
	"ethereal","inscrutable","lewd","stygian","tarnished","odd","subterranean","cthonic","alien","aberrant","ashen",
	"baleful","beastly","anomalous","angular","colorless","cosmic","cyclopean","dank","diabolical","elusive","solemn",
	"endless","enigmatical","festering","faceless","strange","foetid","ghoulish","infernal","kaleidoscopic",
	"nameless","obscene","pagan","holy","pallid","pale","putrid","quivering","reptilian","sepulchral","sightless",
	"unseen","doomed","loathsome","demonic","luminous","spooky","eternal","saintly","benighted","beautiful","skeletal",
	"magical","arcane","rotted","rude","crusty","divine","mercurial","blasted","damned","blessed","blazing","bumbling",
	"wailing","unspeakable","melancholy","insectoid","infested","lurid","incomprehensible","vile","amorphous","antediluvian",
	"weeping","moist","grody","unutterable","lurking","immemorial","blasphemous","nebulous","shadowy","obscure","outer","tenebrous",
	"gloomy","murky","lightless","dismal","unlit","attuned","ghastly","lugubrious","desolate","doleful","baleful","menacing",
	"dark","cold","lumpy","rotund","burly","buff","fleshy","ornate","imposing","false","fancy","elegant","creepy",
	"quirky","unnerving","abnormal","peculiar","astral","chaotic","spherical","swirling","deathless","archaic",
	"atomic","elemental","invisible","awesome","awful","apocalyptic","righteous")

	var/list/fortune_read = list("read","seen","foreseen","inscribed","beheld","witnessed")

	New()
		var/sentence_1 = "You shall soon [pick(fortune_verbs)] the [pick(fortune_adjectives)] [pick(fortune_nouns)]"
		var/sentence_2 = "remember to drink more grones"
		var/sentence_3 = "for reals"

		var/rand2 = rand(1,3)
		var/rand3 = rand(1,3)

		switch(rand2)
			if(1)
				sentence_2 = "but beware, lest the [pick(fortune_adjectives)] [pick(fortune_nouns)] [pick(fortune_verbs)] you"
			if(2)
				sentence_2 = "but take heed, for the [pick(fortune_adjectives)] [pick(fortune_nouns)] might [pick(fortune_verbs)] you"
			else
				sentence_2 = "but rejoice, for the [pick(fortune_adjectives)] [pick(fortune_nouns)] shall [pick(fortune_verbs)] you"

		switch(rand3)
			if(1)
				sentence_3 = "Seek the [pick(fortune_mystical)] of the [pick(fortune_adjectives)] [pick(fortune_nouns)] and [pick(fortune_verbs)] yourself"
			if(2)
				sentence_3 = "Remember to [pick(fortune_verbs)] the [pick(fortune_adjectives)] [pick(fortune_nouns)] and you will surely [pick(fortune_verbs)] your [pick(fortune_adjectives)] [pick(fortune_mystical)]"
			else
				sentence_3 = "You must [pick(fortune_verbs)] the [pick(fortune_adjectives)] [pick(fortune_nouns)] or the [pick(fortune_nouns)] will surely [pick(fortune_verbs)] your [pick(fortune_adjectives)] [pick(fortune_mystical)]"

		info = {"<font face='System' size='3'><center>YOUR FORTUNE</center><br><br>
		The great and [pick(fortune_adjectives)] Zoldorf has [pick(fortune_read)] your [pick(fortune_mystical)]!<br><br>
		[sentence_1]... [sentence_2]! [sentence_3].</font>"}
		return ..() // moving the

// PHOTOGRAPH

/obj/item/paper/photograph
	name = "photo"
	icon_state = "photo"
	var/photo_id = 0
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"

/obj/item/paper/photograph/New()

	..()
	src.pixel_y = 0
	src.pixel_x = 0
	return

/obj/item/paper/photograph/attack_self(mob/user as mob)

	var/n_name = input(user, "What would you like to label the photo?", "Paper Labelling", null) as null|text
	if (!n_name)
		return
	n_name = copytext(html_encode(n_name), 1, 32)
	if ((src.loc == user && isalive(user)))
		src.name = "photo[n_name ? text("- '[]'", n_name) : null]"
	src.add_fingerprint(user)
	return


// cogwerks - creepy picture things

/obj/item/paper/printout
	name = "Printed Image"
	desc = "Fancy."
	var/print_icon = 'icons/effects/sstv.dmi'
	var/print_icon_state = "sstv_1"

	New()
		..()
		src.info = {"<IMG SRC="sstv_cachedimage.png">"}
		return

	examine()
		usr << browse_rsc(icon(print_icon,print_icon_state), "sstv_cachedimage.png")
		. = ..()

	satellite
		print_icon_state = "sstv_2"
		desc = "Looks like a satellite view of a research base."

	group1
		print_icon_state = "sstv_3"
		desc = "A group photo of a research team."

	group2
		print_icon_state = "sstv_4"
		desc = "A group photo of a research team."

	group3
		print_icon_state = "sstv_6"
		desc = "A group of scientists working in a lab."

	researcher1
		print_icon_state = "sstv_5"
		desc = "A scientist handling what looks like an ice core."

	researcher2
		print_icon_state = "sstv_9"
		desc = "The image is badly distorted, but it seems to be a researcher carrying a lab monkey."

	slide1
		print_icon_state = "sstv_7"
		desc = "A microscopic slide. Seems to be some sort of biological cell structure."

	slide2
		print_icon_state = "sstv_8"
		desc = "A dissection report of some kind of arachnid."

	slide3
		print_icon_state = "sstv_10"
		desc = "A dissection report of... something. What the hell is that?"

	emerg1
		print_icon_state = "sstv_11"
		desc = "A coded emergency broadcast."

	crewlog1
		print_icon_state = "sstv_12"
		desc = "A blurry image of something approaching the photographer."

	crewlog2
		print_icon_state = "sstv_13"
		desc = "Oh god."

/obj/item/paper_bin
	name = "paper bin"
	icon = 'icons/obj/writing.dmi'
	icon_state = "paper_bin1"
	uses_multiple_icon_states = 1
	amount = 10
	item_state = "sheet-metal"
	throwforce = 1
	w_class = W_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7

	//cogwerks - burn vars
	burn_point = 600
	burn_output = 800
	burn_possible = 1

	/// the item type this bin contains, should always be a subtype for /obj/item for reasons...
	var/bin_type = /obj/item/paper

/obj/item/paper_bin/artifact_paper
	name = "artifact analysis form tray"
	desc = "A tray full of forms for classifying alien artifacts."
	icon = 'icons/obj/writing.dmi'
	icon_state = "artifact_form_tray"
	amount = INFINITY
	bin_type = /obj/item/sticker/postit/artifact_paper

	update()
		tooltip_rebuild = 1

/obj/item/paper_bin/proc/update()
	tooltip_rebuild = 1
	src.icon_state = "paper_bin[(src.amount || locate(bin_type, src)) ? "1" : null]"
	return

/obj/item/paper_bin/mouse_drop(mob/user as mob)
	if (user == usr && !user.restrained() && !user.stat && (user.contents.Find(src) || in_interact_range(src, user)))
		if (!user.put_in_hand(src))
			return ..()

/obj/item/paper_bin/attack_hand(mob/user)
	src.add_fingerprint(user)
	var/obj/item/paper = locate(bin_type) in src
	if (paper)
		user.put_in_hand_or_drop(paper)
	else
		if (src.amount >= 1 && user) //Wire: Fix for Cannot read null.loc (&& user)
			src.amount--
			var/obj/item/P = new bin_type
			P.set_loc(src)
			user.put_in_hand_or_drop(P)
			if (rand(1,100) == 13 && istype(P, /obj/item/paper))
				var/obj/item/paper/PA = P
				PA.info = "Help me! I am being forced to code SS13 and It won't let me leave."
	src.update()
	return

/obj/item/paper_bin/attack_self(mob/user as mob)
	..()
	src.Attackhand(user)

/obj/item/paper_bin/attackby(obj/item/P, mob/user) // finally you can write on all the paper AND put it back in the bin to mess with whoever shows up after you ha ha
	if (istype(P, bin_type))
		user.drop_item()
		P.set_loc(src)
		boutput(user, "You place [P] into [src].")
		src.update()
	else return ..()

/obj/item/paper_bin/get_desc()
	var/n = src.amount
	for(var/obj/item/paper/P in src)
		n++
	return "There's [(n > 0) ? n : "no" ] paper[s_es(n)] in \the [src]."

/obj/item/paper_bin/robot
	name = "semi-automatic paper bin"
	var/next_generate = 0

	attack_self(mob/user as mob)
		if (src.amount < 1 && isnull(locate(bin_type) in src))
			if (src.next_generate < ticker.round_elapsed_ticks)
				boutput(user, "The [src] generates another sheet of paper using the power of [pick("technology","science","computers","nanomachines",5;"magic",5;"extremely tiny clowns")].")
				src.amount++
				src.update()
				src.next_generate = ticker.round_elapsed_ticks + 5 SECONDS
				return

			boutput(user, "Nothing left in the [src]. Maybe you should check again later.")
			return

		boutput(user, "You remove a piece of paper from the [src].")
		return attack_hand(user)

/obj/item/stamp
	name = "rubber stamp"
	desc = "A no-nonsense National Notary rubber stamp for stamping important documents. It has a simple acrylic handle."
	icon = 'icons/obj/writing.dmi'
	icon_state = "stamp"
	item_state = "stamp"
	flags = FPRINT | TABLEPASS
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 7
	throw_range = 15
	m_amt = 60
	stamina_damage = 0
	stamina_cost = 0
	rand_pos = 1
	var/special_mode = null
	var/is_reassignable = 1
	var/assignment = null
	var/available_modes = list("Granted", "Denied", "Void", "Current Time", "Your Name");
	var/current_mode = "stamp-sprite-ok"
	var/current_state = null

/obj/item/stamp/New()
	..()
	if(special_mode)
		available_modes += special_mode
		current_mode = (STAMP_IDS[special_mode])

/obj/item/stamp/proc/set_assignment(A)
	if (istext(A))
		src.assignment = A
		src.desc = "A rubber stamp for stamping important documents. It is assigned to: \"[A]\"."
		return
	else
		src.assignment = null
		src.desc = "A rubber stamp for stamping important documents."
		return
/obj/item/stamp/attackby(obj/item/C, mob/user)// assignment with ID
	if (istype(C, /obj/item/card/id))
		var/obj/item/card/id/ID = C
		if (!src.is_reassignable)
			boutput(user, "<span class='alert'>This rubber stamp cannot be reassigned!</span>")
			return
		if (!isnull(src.assignment))
			boutput(user, "<span class='alert'>This rubber stamp has already been assigned!</span>")
			return
		else if (!ID.assignment)
			boutput(user, "<span class='alert'>This ID isn't assigned to a job!</span>")
			return
		src.set_assignment(ID.assignment)
		boutput(user, "<span class='notice'>You update the assignment of the rubber stamp.</span>")
		return

/obj/item/stamp/attack_self() // change current mode
	var/NM = input(usr, "Configure \the [src]?", "[src.name]", src.current_mode) in src.available_modes
	if (!NM || !length(NM) || !(NM in src.available_modes))
		return
	src.current_mode = (STAMP_IDS[NM])
	boutput(usr, "<span class='notice'>You set \the [src] to '[NM]'.</span>")
	return

/obj/item/stamp/examine()
	. = ..()
	. += "It is set to '[current_mode]' mode."

/obj/item/stamp/reagent_act(reagent_id, volume)
	if (..())
		return
	switch(reagent_id)
		if ("acetone") // allow reassigning with acetone
			if (isnull(src.assignment) || !src.is_reassignable)
				return
			var/turf/T = get_turf(src)
			T.visible_message("<span>The acetone eats away at the rubber stamp's structure; it is now unassigned.</span>")
			src.set_assignment(null)
	return

/obj/item/stamp/custom_suicide = 1
/obj/item/stamp/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	user.visible_message("<span class='alert'><b>[user] stamps 'VOID' on [his_or_her(user)] forehead!</b></span>")
	user.TakeDamage("head", 250, 0)
	return 1


/obj/item/stamp // static staff stamps
	cap
		name = "\improper captain's rubber stamp"
		desc = "The Captain's rubber stamp for stamping important documents. Ooh, it's the really fancy National Notary 'Congressional' model with the fine ebony handle."
		icon_state = "stamp-cap"
		special_mode = "Captain"
		is_reassignable = 0
		assignment = "stamp-cap"
	hop
		name = "\improper head of personnel's rubber stamp"
		desc = "The Head of Personnel's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'Continental' models with the kingwood handle."
		icon_state = "stamp-hop"
		special_mode = "Head of Personnel"
		is_reassignable = 0
		assignment = "stamp-hop"
	hos
		name = "\improper head of security's rubber stamp"
		desc = "The Head of Security's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'Bancroft' models with the bloodwood handle."
		icon_state = "stamp-hos"
		special_mode = "Head of Security"
		is_reassignable = 0
		assignment = "stamp-hos"
	ce
		name = "\improper chief engineer's rubber stamp"
		desc = "The Chief Engineer's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'St. Mary' models with the ironwood handle."
		icon_state = "stamp-ce"
		special_mode = "Chief Engineer"
		is_reassignable = 0
		assignment = "stamp-ce"
	md
		name = "\improper medical director's rubber stamp"
		desc = "The Medical Director's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'St. Anne' models with the rosewood handle."
		icon_state = "stamp-md"
		special_mode = "Medical Director"
		is_reassignable = 0
		assignment = "stamp-md"
	rd
		name = "\improper research director's rubber stamp"
		desc = "The Research Director's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'St. John' models with the purpleheart handle."
		icon_state = "stamp-rd"
		special_mode = "Research Director"
		is_reassignable = 0
		assignment = "stamp-rd"
	clown
		name = "\improper clown's rubber stamp"
		desc = "The Clown's rubber stamp for stamping whatever important documents they've gotten their hands on. It doesn't seem very legit."
		icon_state = "stamp-honk"
		special_mode = "Clown"
		is_reassignable = 0
		assignment = "stamp-honk"
	centcom
		name = "\improper centcom executive rubber stamp"
		desc = "Some bureaucrat from Centcom probably lost this. Dang, is that National Notary's 'Admiral Sampson' model with the exclusive blackwood handle?"
		icon_state = "stamp-centcom"
		special_mode = "Centcom"
		is_reassignable = 0
		assignment = "stamp-centcom"
	mime
		name = "\improper mime's rubber stamp"
		desc = "The Mime's rubber stamp for stamping whatever important documents they've gotten their hands on. It doesn't seem very legit."
		icon_state = "stamp-mime"
		special_mode = "Mime"
		is_reassignable = 0
		assignment = "stamp-mime"
	chap
		name = "\improper chaplain's rubber stamp"
		desc = "The Chaplain's rubber stamp for stamping whatever important documents they've gotten their hands on. It's the National Notary 'Chesapeake' model in varnished oak."
		icon_state = "stamp-chap"
		special_mode = "Chaplain"
		is_reassignable = 0
		assignment = "stamp-chap"
	qm
		name = "\improper quartermaster's rubber stamp"
		desc = "The Quartermaster's rubber stamp for stamping whatever important documents they've gotten their hands on. A classic National Notary 'Eastport' model in oiled black walnut."
		icon_state = "stamp-qm"
		special_mode = "Quartermaster"
		is_reassignable = 0
		assignment = "stamp-qm"
	syndicate
		name = "\improper syndicate rubber stamp"
		desc = "Syndicate rubber stamp for stamping whatever important documents they've gotten their hands on. Surprisingly, it's also a National Notary 'Continental'. Not many choices out here."
		icon_state = "stamp-syndicate"
		special_mode = "Syndicate"
		is_reassignable = 0
		assignment = "stamp-syndicate"
	law
		name = "\improper security's rubber stamp"
		desc = "Security's rubber stamp for stamping whatever important documents they've gotten their hands on. It's the rugged National Notary 'Severn' model with the rock maple handle."
		icon_state = "stamp-syndicate"
		special_mode = "Security"
		is_reassignable = 0
		assignment = "stamp-law"

/obj/item/paper/folded
	name = "folded paper"
	icon_state = "paper"
	burn_possible = 1
	sealed = 1
	var/old_desc = null
	var/old_icon_state = null

/obj/item/paper/folded/attack_self(mob/user as mob)
	if (src.sealed)
		user.show_text("You unfold the [src] back into a sheet of paper! It looks pretty crinkled.", "blue")
		src.name = "crinkled paper"
		src.desc = src.old_desc
		if(src.old_icon_state)
			src.icon_state = src.old_icon_state
		else
			if(src.info)
				src.icon_state = "paper"
			else
				src.icon_state = "paper_blank"
		src.sealed = 0
	else
		..()

/obj/item/paper/folded/examine()
	if (src.sealed)
		return list(desc)
	else
		return ..()

/obj/item/paper/folded/plane
	name = "paper plane"
	desc = "If you throw it in space is it a paper spaceship?"
	icon_state = "paperplane"
	throw_speed = 1
	throw_spin = 0

/obj/item/paper/folded/plane/hit_check(datum/thrown_thing/thr)
	if(src.throwing && src.sealed)
		src.throw_unlimited = 1

/obj/item/paper/folded/plane/attack_self(mob/user as mob)
	if (src.sealed) //Set throwing vars when unfolding (mostly in the parent call) so that an unfolded paper "plane" behaves like regular paper
		throw_speed = 3 //default for paper
		throw_spin = 1
	..()

/obj/item/paper/folded/ball
	name = "paper ball"
	desc = "It's really fun pelting your coworkers with these."
	icon_state = "paperball"

/obj/item/paper/folded/ball/attack(mob/M, mob/user)
	if (iscarbon(M) && M == user && src.sealed)
		M.visible_message("<span class='notice'>[M] stuffs [src] into [his_or_her(M)] mouth and eats it.</span>")
		playsound(M, 'sound/misc/gulp.ogg', 30, 1)
		eat_twitch(M)
		var/obj/item/paper/P = src
		user.u_equip(P)
		qdel(P)
	else
		..()

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
<td>Turn your Lawbringer™ into your favourite sidearm with these .38 Full Metal Jacket rounds!</td>
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
<td><b>"Bigshot" / "High Explosive" / "HE"</b></td>
<td>170 PU</td>
<td>You'll be the talk of the station when you bust down a wall with one of these explosive rounds! May cause loss of limbs or life.</td>
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
	sizex = 1066
	sizey = 735

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/mushroom_station.png")]'></body></html>"

/obj/item/paper/botany_guide
	name = "Botany Field Guide"
	desc = "Some kinda informative poster. Or is it a pamphlet? Either way, it wants to teach you things. About plants."
	icon_state = "botany_guide"
	sizex = 970
	sizey = 690

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)
		info = "<html><body style='margin:2px'><img src='[resource("images/pocket_guides/botanyguide.png")]'></body></html>"

/obj/item/paper/ranch_guide
	name = "Ranch Field Guide"
	desc = "Some kinda informative poster. Or is it a pamphlet? Either way, it wants to teach you things. About chickens."
	icon_state = "ranch_guide"
	sizex = 1100
	sizey = 800

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)
		info = "<html><body><style>img {width: 100%; height: auto;}></style><img src='[resource("images/pocket_guides/ranchguide.png")]'></body></html>"

/obj/item/paper/iou
	name = "IOU"
	desc = "Somebody took whatever was in here."
	icon_state = "postit-writing"
	info = {"<h2>IOU</h2>"}

/obj/item/paper/shooting_range_note1 //shooting range prefab junk
	name = "secure safe note"
	desc = "Someone left a reminder in neat cursive. The post-it looks nearly new."
	icon_state = "postit-writing"
	info = {"*Experimental ray gun - DO NOT FIRE IN A CLOSED SPACE. Waiting for Olwen to fix... whenever she's back...<br><b><u>*Dinner date is on <s>Tuesday</s>  <s>Fri.</s></s><br>
<s>Thurs.</s><br><s>Sunday</s><br></u><br>???"}

/obj/item/paper/shooting_range_note2
	name = "secure safe note"
	desc = "This note is creased and ripped and tattered. The writing on it is scribbled in near-indecipherable chickenscratch."
	icon_state = "postit-writing"
	info = {"-non-stable battery; keeps popping on use.<br>-design work (not final)<br>-battery capacity??? maybe?<br>Cheers,<br>O"}

/obj/item/paper/bee_love_letter //For lesbeeans prefab
	name = "bee love letter"
	desc = "This smells as sweet as the prose on it."
	icon_state = "paper_caution"
	info = {"<i>You have no hope of deciphering the weird marks on this paper, nor are you entirely certain it's even actual writing, but the splotchy heart with prints of bee pretarsi at the bottom kindles a warmth deep within your heart.</i>"}

/obj/item/paper/folded/ball/bee_farm_note //Idem, let's see if anyone thinks to unfold this
	name = "wadded-up note"
	desc = "A crumpled, chewed-on wad of paper. A bee appears to have tried eating this."
	info = {"Janus, I can see why you're so fond of these two and spend so much time on them. It's adorable watching those two together at work, and I think we're seeing new and unique behaviour here!<br><br>
But please, please do something about the fact it's hanging on by just the data cables, they're not remotely capable of tugging this kind of mass.<br><br>
That clump of dirt has a metal substrate, we can just ask Rachid to weld it to the station while we keep the lovebirds at a safe distance. A little wrangling never hurt a bee."}

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
	We're stuck with only a few flasks, along with some shitty prototype chemi-something or other, which quite frankly we'd be better off with another pair of beakers, fuck, it can't even produce chemicals!
	I'm trying anything at this point, even port, of all things.<br><br>
	I'd better get back to it, I'm not being paid by the hour here."}

/obj/item/paper/synd_lab_note2
	name = "scribbled note"
	info = {"I've been working on these faux, exploding 'telecrystals' for a while now, and I'm starting to think I got the better end of a rotten deal.<br><br>
	I've been, as of yet, completely unable to emulate any of the teleporting aspects of regular telecrystals, which means these things can certainly feel fake if you give 'em enough testing.
	Needless to say, I'm not a fan.<br>
	I mean, just making these telecrystals the right color is a pain in the ass, requiring this bulky machine I hardly know how to operate take HOURS per crystal!<br><br>
	Well, here's to hoping infusing these things with black powder won't blow up in my face."}

/obj/item/paper/recipe_tandoori
	name = "stained recipe clipping"
	desc = "It's creased and worn, and smells a little like dried blood."
	icon_state = "paper_caution_bloody"
	info = {"<i>In just nine seconds, treat your family to a meal that tastes like it took hours to roast!</i><br><h3>Tandoori Chicken</h3><br><h4>Ingredients:</h4><br> -chicken meat <br> -a heaping helping of curry powder <br> -a nice, hot chili pepper <br> -a head of garlic <br><br><i>Don't even waste your time slashing the meat or slathering it in spices! Just toss it all in your standard-issue industrial oven and set it to high. Your dinner guests can't even tell the difference!</i>"}

/obj/item/paper/recipe_potatocurry
	name = "tattered recipe clipping"
	desc = "It's very old, and nearly falls apart in your hand."
	icon_state = "paper_burned"
	info = {"<i>Rich and full of vegetables, this hearty curry will satisfy any palate!</i><br><h3>Potato Curry</h3><br><h4>Ingredients:</h4><br> -plenty of curry powder <br> -a fresh potato <br> -chopped carrots <br> -a handful of peas <br><br><i>Simply toss the ingredients into a standard-issue industrial oven and let them simmer on low. Treat anyone to the flavor of a home-cooked stew in a fraction of the time!</i>"}

/obj/item/paper/recipe_coconutcurry
	name = "creased recipe clipping"
	desc = "Irreperably creased from years of being folded-up. Luckily, you can still make out the text on it."
	icon_state = "paper_caution_crumple"
	info = {"<i>In the mood for something spicy yet mild? Have extra coconuts to burn? Asking yourself why you grew so many coconuts in the first place? dear god we need to do something with these things</i><br><h3>Coconut Curry</h3><br><h4>Ingredients:</h4><br> -as much curry powder as you need to make it not taste like 100% coconut <br> -coconut meat <br> -a carrot to add texture <br> -a bed of rice <br><br><i>Set the oven for 7 seconds, put the heat on low, add the ingredients, and hit start. Tell the botanists that they can go back to growing weed now. Beg them to, really.</i>"}

/obj/item/paper/recipe_chickenpapplecurry
	name = "worn recipe clipping"
	desc = "An old recipe clipped from a lifestyle magazine for space station chefs. Aw, the color's faded from the layout..."
	icon_state = "paper_caution"
	info = {"<i>Facing threats from the crew for putting pineapple on your pizzas and letting your chicken corpses spill out into the hall? Turn those trials into smiles when you serve up this scrumptious dish!</i><br><h3>Chicken Pineapple Curry</h3><br><h4>Ingredients:</h4><br> -a bag of curry powder <br> -some fresh chicken meat <br> -a tasty ring of pineapple <br> -a nice spicy chili pepper <br><br><i>With your oven, you don't even have to mix! Just add everything, set the heat to low, and let it all cook for 7 seconds!</i>"}

/obj/item/paper/reinforcement_info
	name = "Reinforcement Disclaimer"
	icon_state = "paper"
	info = {"<b>Thank you for buying a Syndicate brand reinforcement!</b><br>To deploy the reinforcement, simply activate it somewhere on station, set it down, and wait. If a reinforcement is found, they'll be deployed within the minute. The nearby Listening Post should do you well, but it cannot be activated on the Cairngorm!<br><br><i>Disclaimer: Capability of reinforcement not guaranteed. The beacon may pose a choking hazard to those under 3 years old.<br>If no reinforcement is available, you may simply hit your uplink with the beacon to return it for a full refund.</i>"}

/obj/item/paper/designator_info
	name = "Laser Designator Pamphlet"
	icon_state = "paper"
	info = {"<b>So, you've purchased a Laser Designator!</b><br><br>The operation of one is simple, the first step is to ensure the Cairngorm has an in-tact, working gun. Once you've done this, you can just pull out the designator, hold shift and move if you want to do longer-range designation, and point at anywhere to designate a target, at which point the Cairngorm will fire the artillery weapon, and the designated area will shortly explode."}

/obj/item/paper/deployment_info
	name = "Deployment Remote Note"
	icon_state = "paper"
	info = {"<b>Congratulations for purchasing the Syndicate Rapid-Deployment Remote (SRDR)!</b><br><br>To use it, first of all, you need to either be onboard the Cairngorm or at the Listening Post. <br>Once you're there, activate the SRDR in-hand to choose a location, then once more to teleport everyone (along with any nuclear devices you possess) within 4 tiles of you to the forward assault pod, at which point it will begin head to the station, taking about one minute. During this time, Space Station 13's sensors will indicate the quickly-arriving pod, and will likely warn the crew.<br> Once the minute ends, everyone will be deployed to the specified area through personnel missiles."}

/obj/item/paper/nukeop_uplink_purchases
	name = "Shipping Manifest"
	icon_state = "paper"

	New()
		. = ..()
		if(!length(syndi_buylist_cache))
			SPAWN(30 SECONDS) //This spawns empty on-map otherwise, 30s is a safe bet
				build_paper()
		else
			build_paper()

	proc/build_paper()
		var/placeholder_info
		placeholder_info += "<b>Syndicate Shipping Manifest</b><br>"
		for(var/datum/syndicate_buylist/commander/commander_item in syndi_buylist_cache)
			var/item_info = world.load_intra_round_value("NuclearCommander-[commander_item]-Purchased")
			if(isnull(item_info))
				item_info = 0
			placeholder_info += "<br><br><b>[commander_item.name]</b>: [item_info]"
		info = placeholder_info

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

	sizex = 640
	sizey = 400


	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_blank.png")]'></body></html>"


/obj/item/paper/businesscard/banjo
	name = "business card - Tum Tum Phillips"
	icon_state = "businesscard"
	desc = "A business card for the famous Tum Tum Phillips, Frontier banjoist."

	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_banjo.png")]'></body></html>"


/obj/item/paper/businesscard/biteylou
	name = "business card - Bitey Lou's Bodyshop"
	icon_state = "businesscard"
	desc = "A business card for some sorta mechanic's shop."
	color = "gray"

	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_biteylou.png")]'></body></html>"


/obj/item/paper/businesscard/bonktek
	name = "business card - Bonktek Shopping Pyramid"
	icon_state = "businesscard"
	desc = "A business card for the Bonktek Shopping Pyramid of New Memphis."

	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_bonktek.png")]'></body></html>"

/obj/item/paper/businesscard/clowntown
	name = "business card - Clown Town"
	icon_state = "businesscard"
	desc = "A business card for the Bonktek Shopping Pyramid of New Memphis."
	color = "blue"

	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_clowntown.png")]'></body></html>"

/obj/item/paper/businesscard/cosmicacres
	name = "business card - Cosmic Acres"
	icon_state = "businesscard-alt"
	desc = "A business card for a retirement community on Earth's moon."

	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_cosmicacres.png")]'></body></html>"

/obj/item/paper/businesscard/ezekian
	name = "business card - Ezekian Veterinary Clinic"
	icon_state = "businesscard"
	desc = "A business card for a Frontier veterinarian's office."
	color = "gray"

	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_ezekian.png")]'></body></html>"

/obj/item/paper/businesscard/gragg1
	name = "business card - Amantes Mini Golf"
	icon_state = "businesscard-alt"
	desc = "A business card for a mini golf course."

	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_gragg1.png")]'></body></html>"

/obj/item/paper/businesscard/gragg2
	name = "business card - Amantes Rock Shop"
	icon_state = "businesscard-alt"
	desc = "A business card for a rock collector's shop."

	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_gragg2.png")]'></body></html>"

/obj/item/paper/businesscard/josh
	name = "business card - Josh"
	icon_state = "businesscard"
	desc = "A business card for someone's personal business. Looks like it's based at a flea market, in space. Hopefully there aren't any space fleas there."
	color = "green"

	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_josh.png")]'></body></html>"

/obj/item/paper/businesscard/lawyers
	name = "business card - Hogge & Wylde"
	icon_state = "businesscard-alt"
	desc = "A business card for a personal injury law firm. You've heard their ads way, way too many times."

	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_law.png")]'></body></html>"

/obj/item/paper/businesscard/hemera_rcd
	name = "info card - Rapid Construction Device"
	icon_state = "businesscard-alt"
	desc = "An information card for the Mark III Rapid Construction Device from Hemera Astral Research Corporation."

	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_RCD.png")]'></body></html>"


/obj/item/paper/businesscard/skulls
	name = "business card - Skulls for Cash"
	icon_state = "businesscard"
	desc = "A business card for someone's personal business. Looks like it's based at a flea market, in space. Hopefully there aren't any space fleas there."

	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_skulls.png")]'></body></html>"

/obj/item/paper/businesscard/taxi
	name = "business card - Old Fortuna Taxi Company"
	icon_state = "businesscard"
	desc = "A business card for a Frontier space-taxi and shuttle company."
	color = "yellow"

	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_taxi.png")]'></body></html>"

/obj/item/paper/businesscard/vurdulak
	name = "business card - Emporium Vurdulak"
	icon_state = "businesscard"
	desc = "A business card for someone's personal business. Looks like it's based at a flea market, in space. Hopefully there aren't any space fleas there."
	color = "purple"

	New()
		..()
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/business_vurdulak.png")]'></body></html>"

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

/obj/item/paper/gallery
	name = "Gallery submission guide"
	info = {"
		<span style="color:null;font-family:Georgia;"><p>Thank you for your interest in making a submission to the Nanotrasen Applied Paints Art Gallery!</p>
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
