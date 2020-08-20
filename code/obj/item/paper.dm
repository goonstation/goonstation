
/obj/item/paper
	name = "paper"
	icon = 'icons/obj/writing.dmi'
	icon_state = "paper_blank"
	uses_multiple_icon_states = 1
	wear_image_icon = 'icons/mob/head.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	var/info = null
	var/stampable = 1
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 15
	layer = OBJ_LAYER
	//cogwerks - burning vars
	burn_point = 220
	burn_output = 900
	burn_possible = 2
	health = 10

	var/list/form_startpoints
	var/list/form_endpoints

	var/font_css_crap = null
	var/list/fonts = list()
	//
	var/see_face = 1
	var/body_parts_covered = HEAD
	var/protective_temperature = T0C + 10
	var/heat_transfer_coefficient = 0.99
	var/permeability_coefficient = 0.99
	var/siemens_coefficient = 0.80

	var/sizex = 0
	var/sizey = 0
	var/offset = 0

	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0

	var/sealed = 0 //Can you write on this with a pen?

/obj/item/paper/New()

	..()
	var/datum/reagents/R = new/datum/reagents(10)
	reagents = R
	R.my_atom = src
	R.add_reagent("paper", 10)
	if (!src.rand_pos)
		return
	else
		src.pixel_y = rand(-8, 8)
		src.pixel_x = rand(-9, 9)
	SPAWN_DBG(0)
		if (src.info && src.icon_state == "paper_blank")
			icon_state = "paper"
	return


/obj/item/paper/pooled()

	..()
	info = 0
	src.icon_state = "paper_blank"
	health = 10

/obj/item/paper/unpooled()

	..()
	info = initial(info)
	icon_state = initial(icon_state)
	health = initial(health)
	sealed = initial(sealed)


	if (src.reagents)
		src.reagents.clear_reagents()
		src.reagents.add_reagent("paper", 10)
	else
		var/datum/reagents/R = new/datum/reagents(10)
		reagents = R
		R.my_atom = src
		R.add_reagent("paper", 10)

	if (!src.offset)
		return
	else
		src.pixel_y = rand(-8, 8)
		src.pixel_x = rand(-9, 9)
	SPAWN_DBG(0)
		if (src.info && src.icon_state == "paper_blank")
			icon_state = "paper"

	return

/obj/item/paper/examine(mob/user)
	. = ..()
	var/windowtext
	if(!user.literate)
		windowtext = html_encode(illiterateGarbleText(src.info)) // deny them ANY useful information
	else
		windowtext = src.info
		if (src.form_startpoints && src.form_endpoints)
			for (var/x = src.form_startpoints.len, x > 0, x--)
				windowtext = copytext(windowtext, 1, src.form_startpoints[src.form_startpoints[x]]) + "<a href='byond://?src=\ref[src];form=[src.form_startpoints[x]]'>" + copytext(windowtext, src.form_startpoints[src.form_startpoints[x]], src.form_endpoints[src.form_endpoints[x]]) + "</a>" + copytext(windowtext, src.form_endpoints[src.form_endpoints[x]])

	var/font_junk = ""
	for (var/i in src.fonts)
		font_junk += "<link href='http://fonts.googleapis.com/css?family=[i]' rel='stylesheet' type='text/css'>"

	usr.Browse("<HTML><HEAD><TITLE>[src.name]</TITLE>[font_junk]</HEAD><BODY><TT>[windowtext]</TT></BODY></HTML>", "window=[src.name][(sizex || sizey) ? {";size=[sizex]x[sizey]"} : ""]")
	onclose(usr, "[src.name]")

//[(sizex || sizey) ? {";size=[sizex]x[sizey]"} : ""]
/obj/item/paper/Map/examine(mob/user)
	. = ..()

	if (!( ishuman(user) || isobserver(user) || issilicon(user) ))
		user.Browse("<HTML><HEAD><TITLE>[src.name]</TITLE></HEAD><BODY><TT>[stars(src.info)]</TT></BODY></HTML>", "window=[src.name]")
		onclose(user, "[src.name]")
	else
		user.Browse("<HTML><HEAD><TITLE>[src.name]</TITLE></HEAD><BODY><TT>[src.info]</TT></BODY></HTML>", "window=[src.name]")
		onclose(user, "[src.name]")

/obj/item/paper/custom_suicide = 1
/obj/item/paper/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	user.visible_message("<span class='alert'><b>[user] cuts [him_or_her(user)]self over and over with the paper.</b></span>")
	user.TakeDamage("chest", 150, 0)
	return 1

/obj/item/paper/attack_self(mob/user as mob)
	var/menuchoice = alert("What would you like to do with [src]?",,"Fold","Read","Nothing")
	if (menuchoice == "Nothing")
		return
	else if (menuchoice == "Read")
		src.examine(user)
	else
		var/fold = alert("What would you like to fold [src] into?",,"Paper hat","Paper plane","Paper ball")
		var/obj/item/paper/P = src
		src = null
		usr.u_equip(P)
		if (fold == "Paper hat")
			usr.show_text("You fold the paper into a hat! Neat.", "blue")
			var/obj/item/clothing/head/paper_hat/H = new()
			usr.put_in_hand_or_drop(H)
		else
			var/obj/item/paper/folded/F = null
			if (fold == "Paper plane")
				usr.show_text("You fold the paper into a plane! Neat.", "blue")
				F = new /obj/item/paper/folded/plane(usr)
			else
				usr.show_text("You crumple the paper into a ball! Neat.", "blue")
				F = new /obj/item/paper/folded/ball(usr)
			F.info = P.info
			F.old_desc = P.desc
			F.old_icon_state = P.icon_state
			F.sealed = 1
			usr.put_in_hand_or_drop(F)
		pool(P)

/obj/item/paper/attack_ai(var/mob/AI as mob)
	var/mob/living/silicon/ai/user
	if (isAIeye(AI))
		var/mob/dead/aieye/E = AI
		user = E.mainframe
	else
		user = AI
	if (!isAI(user) || (user.current && get_dist(src, user.current) < 2)) //Wire: fix for undefined variable /mob/living/silicon/robot/var/current
		var/font_junk = ""
		for (var/i in src.fonts)
			font_junk += "<link href='http://fonts.googleapis.com/css?family=[i]' rel='stylesheet' type='text/css'>"
		usr.Browse("<HTML><HEAD><TITLE>[src.name]</TITLE>[font_junk]</HEAD><BODY><TT>[src.info]</TT></BODY></HTML>", "window=[src.name]")
		onclose(usr, "[src.name]")
	return

/obj/item/paper/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
		return

	if (href_list["form"])
		if (istype(usr.equipped(), /obj/item/pen))
			. = href_list["form"]
			if (. in form_startpoints)
				// fill in field (up to field length)
				var/t = input(usr, "What text do you wish to add?", "[src.name]", null) as null|text
				if (!t)
					return
				if ((!in_range(src, usr) && src.loc != usr && !( istype(src.loc, /obj/item/clipboard) ) && src.loc.loc != usr))
					return
				t = copytext(html_encode(t), 1, (form_endpoints[.] - form_startpoints[.]) + 1)
				t = sign_name(t, usr)
				src.info = copytext(src.info, 1, form_startpoints[.]) + "" + t + "" + copytext(src.info, form_startpoints[.] + length(t))
				build_formpoints()
				usr.examine_verb(src)

		if (istype(usr.equipped(), /obj/item/stamp))
			var/obj/item/stamp/S = usr.equipped()
			. = href_list["form"]
			if (S && (. in form_startpoints))
				switch(input(usr, "Stamp \the [src] with [S.name]?", "[src.name]", "No") in list("Yes", "No"))
					if ("No")
						return
					if ("Yes")
						var/T = S.get_stamp_text()
						if (!T)
							return
						if ((!in_range(src, usr) && src.loc != usr && !(istype(src.loc, /obj/item/clipboard)) && src.loc.loc != usr))
							return
						// replace whole form field with stamp
						src.info = copytext(src.info, 1, form_startpoints[.]) + "" + T + "" + copytext(src.info, form_endpoints[.])
						src.icon_state = "paper_stamped"
						build_formpoints()
						usr.examine_verb(src)

	src.add_fingerprint(usr)

/obj/item/paper/attackby(obj/item/P as obj, mob/user as mob)

	if (istype(P, /obj/item/pen))
		if(!user.literate)
			boutput(user, "<span class='alert'>You don't know how to write.</span>")
			return ..()

		if (isghostdrone(user))
			return ..()

		if (src.sealed)
			boutput(user, "<span class='alert'>You can't write on [src].</span>")
			return

		var/custom_font = "Georgia"
		var/custom_color = "black"
		var/custom_size = 16

		var/obj/item/pen/pen = P
		if (pen.font)
			custom_font = pen.font
		if (pen.font_color)
			custom_color = pen.font_color

		if (pen.uses_handwriting)
			custom_font = "Dancing Script"
			if (user && user.mind && user.mind.handwriting)
				custom_font = user.mind.handwriting
			if (islist(src.fonts) && !src.fonts[custom_font])
				src.fonts[custom_font] = 1
			custom_font += ", cursive"
			custom_size += rand(0,4)

		else if (pen.webfont && islist(src.fonts) && !src.fonts[pen.webfont])
			src.fonts[pen.webfont] = 1

		var/t = input(user, "What text do you wish to add?", "[src.name]", null) as null|message
		if (!t)
			return
		if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/clipboard) ) && src.loc.loc != user && user.equipped() != P))
			return
		//t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)

		t = copytext(html_encode(t), 1, 2*MAX_MESSAGE_LEN)
		t = replacetext(t, "\n", "<BR>")
		t = replacetext(t, "\[b\]", "<B>")
		t = replacetext(t, "\[/b\]", "</B>")
		t = replacetext(t, "\[i\]", "<I>")
		t = replacetext(t, "\[/i\]", "</I>")
		t = replacetext(t, "\[u\]", "<U>")
		t = replacetext(t, "\[/u\]", "</U>")
		t = replacetext(t, "\[hr\]", "<HR>")
		t = replacetext(t, "\[/hr\]", "</HR>")
		t = replacetext(t, "\[sup\]", "<SUP>")
		t = replacetext(t, "\[/sup\]", "</SUP>")
		t = replacetext(t, "\[h1\]", "<H1>")
		t = replacetext(t, "\[/h1\]", "</H1>")
		t = replacetext(t, "\[h2\]", "<H2>")
		t = replacetext(t, "\[/h2\]", "</H2>")
		t = replacetext(t, "\[h3\]", "<H3>")
		t = replacetext(t, "\[/h3\]", "</H3>")
		t = replacetext(t, "\[h4\]", "<H4>")
		t = replacetext(t, "\[/h4\]", "</H4>")
		t = replacetext(t, "\[li\]", "<LI>")
		t = replacetext(t, "\[/li\]", "</LI>")
		t = replacetext(t, "\[ul\]", "<UL>")
		t = replacetext(t, "\[/ul\]", "</UL>")
		t = replacetext(t, "\[bq\]", "<BLOCKQUOTE>")
		t = replacetext(t, "\[/bq\]", "</BLOCKQUOTE>")

		logTheThing("say", user, null, "writes on a piece of paper: [t]")

		t = sign_name(t, user)
		src.info += "<span style='font-family: [custom_font]; color: [custom_color]; font-size: [custom_size]px'>[t]</span>"

		//src.info += "<font face=[custom_font] color=[custom_color] size='3'> [t] </font>" // shit's hard to read at size 2 goddamn
		// bad font arguments don't seem to do much

		build_formpoints()

		if (src.icon_state == "paper_blank" && src.info)
			src.icon_state = "paper"
	else
		if (istype(P, /obj/item/stamp) && src.stampable)
			if ((!in_range(src, usr) && src.loc != user && !(istype(src.loc, /obj/item/clipboard)) && src.loc.loc != user && user.equipped() != P))
				return
			var/obj/item/stamp/S = P
			src.info += "<br>" + S.get_stamp_text() + "<br>"
			src.icon_state = "paper_stamped"
			boutput(user, "<span class='notice'>You stamp the paper.</span>")

		else if (issnippingtool(P))
			boutput(user, "<span class='notice'>You cut the paper into a mask.</span>")
			playsound(src.loc, "sound/items/Scissor.ogg", 30, 1)
			var/obj/item/paper_mask/M = new /obj/item/paper_mask(src.loc)
			user.put_in_hand_or_drop(M)
			//M.set_loc(get_turf(src)) // otherwise they seem to just vanish into the aether at times
			usr.u_equip(src)
			pool(src)

		else if (istype(P, /obj/item/paper) && !istype(P, /obj/item/paper/manufacturer_blueprint))
			var/obj/item/staple_gun/S = user.find_type_in_hand(/obj/item/staple_gun)
			if (S && S.ammo)
				var/obj/item/paper_booklet/B = new
				B.set_loc(src.loc)
				user.drop_item()
				B.pages += src
				B.pages += P
				src.visible_message("[user] staples [P] under [src].")
				src.set_loc(B)
				P.set_loc(B)
				S.ammo--
				playsound(user,"sound/impact_sounds/Generic_Snap_1.ogg", 50, 1)
			else
				boutput(usr, "<span class='alert'>You need a loaded stapler in hand to staple these papers.</span>")

		else
			..()

	src.add_fingerprint(user)
	return

/obj/item/paper/proc/sign_name(var/t as text, mob/user as mob)
	var/writing_style = "Dancing Script"
	if (findtext(t, "\[sign\]") || findtext(t, "\[signature\]"))
		if (user && user.mind && user.mind.handwriting)
			writing_style = user.mind.handwriting
		if (islist(src.fonts) && !src.fonts[writing_style])
			src.fonts[writing_style] = 1
	t = replacetext(t, "\[sign\]", "<span style='font-family: [writing_style], cursive;'>[user.real_name]</span>")
	t = replacetext(t, "\[signature\]", "<span style='font-family: [writing_style], cursive;'>[user.real_name]</span>")
	return t

/obj/item/paper/proc/build_formpoints()
	var/formStart = 1
	var/formEnd = 0

	if (form_startpoints)
		form_startpoints.len = 0
	else
		form_startpoints = list()

	if (form_endpoints)
		form_endpoints.len = 0
	else
		form_endpoints = list()

	. = 0
	while (formStart)
		formStart = findtext(src.info, "__", formStart)
		if (formStart)
			formEnd = formStart + 1
			while (copytext(src.info, formEnd, formEnd+1) == "_")
				formEnd++

			if (!form_startpoints)
				form_startpoints = list()

			if (!form_endpoints)
				form_endpoints = list()

			form_startpoints["[.]"] = formStart
			form_endpoints["[.++]"] = formEnd

			formStart = formEnd+1

/obj/item/paper/thermal
	name = "Thermal Paper"
	stampable = 0
	icon_state = "thermal_paper"
	sealed = 1

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
	<p>Clone profiles may be viewed through the profiles menu. Scanning implants a complementary HEALTH MONITOR IMPLANT into the subject, which may be viewed from each profile.
	Profile Deletion has been restricted to \[Station Head\] level access.</p>
	<h4>Cloning from a profile</h4>
	Cloning is as simple as pressing the CLONE option at the bottom of the desired profile.<br>
	Per your company's EMPLOYEE PRIVACY RIGHTS agreement, the H-87 has been blocked from cloning crewmembers while they are still alive.<br>
	<br>
	<p>The provided CLONEPOD SYSTEM will produce the desired clone.  Standard clone maturation times (With SPEEDCLONE technology) are roughly 90 seconds.
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
		In order to uninstall and install parts use a crowbar on a ship to open the maintenance panel, If you want to install a part, simply use the part on the ship. If you want to uninstall a part simply use an empty hand on the maintenance panel. Make sure to close the panel when you are done.<br>
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
	All NanoTrasen spaceships are equipped with multiple cryogenics tubes, meant to store and heal critically wounded patients using cryoxadone. Use this guide for proper setup and handling instructions.<br><br>
	<h4>Setting Up the Cryogenics Chambers</h4>
	<ol type="1">
	<li>Secure a filled canister of O2 or another suitable air mixture to the attached connector using a wrench.</li>
	<li>Add a 50-unit supply of cryoxadone to each of the two cryogenics chambers. There should be two nearby beakers for this purpose; if they are missing or empty, it is recommended that a request be sent to the research department to synthesize an additional supply.</li>
	<li>Set the freezer to the lowest possible temperature setting (73.15 K, the default) if necessary.</li>
	<li>Turn on the power on the freezer and leave it on.</li>
	<li>One can add a defibrillator to attempt to revive subjects as well.</li>
	</ol>
	Note that the supply of cryoxadone will not deplete unless there is a patient present in the cryogenics chamber. However, the oxygen slowly depletes if the cryogenics chambers themselves are turned on, so it is recommended to leave them switched off unless a patient is present.<br><br>
	<h4>Treating a Patient Using the Cryogenics Chambers</h4>
	<ol type="1">
	<li>Stabilize the patient's health using CPR or cardiac stimulants.</li>
	<li>Remove any exosuit, headgear, and any other insulative materials being worn by the patient. Failure to remove these will deter the effects of the cryoxadone and halt the healing process.</li>
	<li>Check to ensure that the gas temperature is at optimal levels and there is no contamination in the system.</li>
	<li>Put the patient in the cryogenics chamber and turn it on.</li>
	</ol>
	The cryogenics chamber will automatically eject patients once their health is back to normal, but post-cryo evaluation is recommended nevertheless.
	"}

/obj/item/paper/cargo_instructions
	name = "'Cargo Bay Setup Instructions'"
	info = "In order to properly set up the cargo computer, both the incoming and outgoing supply pads must be directly or diagonally adjacent to the computer."

/obj/item/paper/Toxin
	name = "'Chemical Information'"
	info = "Known Onboard Toxins:<BR>\n\tGrade A Semi-Liquid Plasma:<BR>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<BR>\n\t\tA gas mask fails to filter plasma after 50 units.<BR>\n\t\tWill attempt to diffuse like a gas.<BR>\n\t\tFiltered by scrubbers.<BR>\n\t\tThere is a bottled version which is very different<BR>\n\t\t\tfrom the version found in canisters!<BR>\n<BR>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<BR>\n\t\texcept in a enclosed fire area!<BR>\n\t\tWARNING: It is a crime to use this without authorization.<BR>\nKnown Onboard Anti-Toxin:<BR>\n\tAnti-Toxin Type 01P: Works against Grade A Plasma.<BR>\n\t\tBest if injected directly into bloodstream.<BR>\n\t\tA full injection is in every regular Med-Kit.<BR>\n\t\tSpecial toxin Kits hold around 7.<BR>\n<BR>\nKnown Onboard Chemicals (other):<BR>\n\tRejuvenation T#001:<BR>\n\t\tEven 1 unit injected directly into the bloodstream<BR>\n\t\t\twill cure paralysis and sleep toxins.<BR>\n\t\tIf administered to a dying patient it will prevent<BR>\n\t\t\tfurther damage for about units*3 seconds.<BR>\n\t\t\tit will not cure them or allow them to be cured.<BR>\n\t\tIt can be administeredd to a non-dying patient<BR>\n\t\t\tbut the chemicals disappear just as fast.<BR>\n\tSleep Toxin T#054:<BR>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<BR>\n\t\t\tThe effects are cumulative.<BR>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/paper/courtroom
	name = "'A Crash Course in Legal SOP on SS13'"
	info = "<B>Roles:</B><BR>\nThe Detective is basically the investigator and prosecutor.<BR>\nThe Staff Assistant can perform these functions with written authority from the Detective.<BR>\nThe Captain/HoP/Warden is ct as the judicial authority.<BR>\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.<BR>\n<BR>\n<B>Investigative Phase:</B><BR>\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<BR>\n<BR>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<BR>\n<BR>\n<B>Pre-Pre-Trial Phase:</B><BR>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<BR>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<BR>\n<B>Possible Motions:</B><BR>\n1. <U>Invalidate Evidence-</U> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<BR>\n2. <U>Free Movement-</U> Basically the defendant is to be kept uncuffed before and during the trial.<BR>\n3. <U>Subpoena Witness-</U> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<BR>\n4. <U>Drop the Charges-</U> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<BR>\n5. <U>Declare Incompetent-</U> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<BR>\n<BR>\nALL SIDES MOVE TO A COURTROOM<BR>\n<B>Pre-Trial Hearings:</B><BR>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<BR>\n<BR>\n<B>The Trial:</B><BR>\nThe trial has three phases.<BR>\n1. <B>Opening Arguments</B>- Each side can give a short speech. They may not present ANY evidence.<BR>\n2. <B>Witness Calling/Evidence Presentation</B>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<BR>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<BR>\n3. <B>Closing Arguments</B>- Same as opening.<BR>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<BR>\n<BR>\n<B>Sentencing Phase:</B><BR>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <BR>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<BR>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<BR>\n<BR>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<BR>\n"

/obj/item/paper/flag
	icon_state = "flag_neutral"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	anchored = 1.0

/obj/item/paper/jobs
	name = "'Job Information'"
	info = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<BR>\nThe data will be in the following form.<BR>\nGenerally lower ranking positions come first in this list.<BR>\n<BR>\n<B>Job Name</B>   general access>lab access-engine access-systems access (atmosphere control)<BR>\n\tJob Description<BR>\nJob Duties (in no particular order)<BR>\nTips (where applicable)<BR>\n<BR>\n<B>Research Assistant</B> 1>1-0-0<BR>\n\tThis is probably the lowest level position. Anyone who enters the space station after the initial job\nassignment will automatically receive this position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.<BR>\n1. Assist the researchers.<BR>\n2. Clean up the labs.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Staff Assistant</B> 2>0-0-0<BR>\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<BR>\n1. Patrol ship/Guard key areas<BR>\n2. Assist security officer<BR>\n3. Perform other security duties.<BR>\n<BR>\n<B>Technical Assistant</B> 1>0-0-1<BR>\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.<BR>\n1. Assist Station technician and Engineers.<BR>\n2. Perform general maintenance of station.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Medical Assistant</B> 1>1-0-0<BR>\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)<BR>\n1. Assist the medical personnel.<BR>\n2. Update medical files.<BR>\n3. Prepare materials for medical operations.<BR>\n<BR>\n<B>Research Technician</B> 2>3-0-0<BR>\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.<BR>\n1. Inform superiors of research.<BR>\n2. Perform research alongside of official researchers.<BR>\n<BR>\n<B>Detective</B> 3>2-0-0<BR>\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.<BR>\n1. Perform crime-scene investigations/draw conclusions.<BR>\n2. Store and catalogue evidence properly.<BR>\n3. Testify to superiors/inquieries on findings.<BR>\n<BR>\n<B>Station Technician</B> 2>0-2-3<BR>\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.<BR>\n1. Maintain SS13 systems.<BR>\n2. Repair equipment.<BR>\n<BR>\n<B>Atmospheric Technician</B> 3>0-0-4<BR>\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on SS13.<BR>\n1. Maintain atmosphere on SS13<BR>\n2. Research atmospheres on the space station. (safely please!)<BR>\n<BR>\n<B>Engineer</B> 2>1-3-0<BR>\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13\nwork. They are one of the few classes that have unrestricted access to the engine area.<BR>\n1. Upkeep the engine.<BR>\n2. Prevent fires in the engine.<BR>\n3. Maintain a safe orbit.<BR>\n<BR>\n<B>Medical Researcher</B> 2>5-0-0<BR>\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.<BR>\n1. Make sure the station is kept safe.<BR>\n2. Research medical properties of materials studied of Space Station 13.<BR>\n<BR>\n<B>Scientist</B> 2>5-0-0<BR>\n\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.\nTechnically they can also be called Plasma Technicians as plasma is the material they routinly handle.<BR>\n1. Research plasma<BR>\n2. Make sure all plasma is properly handled.<BR>\n<BR>\n<B>Medical Doctor (Officer)</B> 2>0-0-0<BR>\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.<BR>\n1. Heal wounded people.<BR>\n2. Perform examinations of all personnel.<BR>\n3. Moniter usage of medical equipment.<BR>\n<BR>\n<B>Security Officer</B> 3>0-0-0<BR>\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.<BR>\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<BR>\n1. Maintain order.<BR>\n2. Assist others.<BR>\n3. Repair structural problems.<BR>\n<BR>\n<B>Head of Security</B> 4>5-2-2<BR>\n\tPeople assigned as Head of Security should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.<BR>\n1. Oversee security.<BR>\n2. Assign patrol duties.<BR>\n3. Protect the station and staff.<BR>\n<BR>\n<B>Head of Personnel</B> 4>4-2-2<BR>\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.<BR>\n1. Assign duties.<BR>\n2. Moderate personnel.<BR>\n3. Moderate research. <BR>\n<BR>\n<B>Captain</B> 5>5-5-5 (unrestricted station wide access)<BR>\n\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.<BR>\n1. Assign all positions on SS13<BR>\n2. Inspect the station for any problems.<BR>\n3. Perform administrative duties.<BR>\n"

/obj/item/paper/sop
	name = "'Standard Operating Procedure'"
	info = "Alert Levels:<BR>\nBlue- Emergency<BR>\n\t1. Caused by fire<BR>\n\t2. Caused by manual interaction<BR>\n\tAction:<BR>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<BR>\nRed- Ejection/Self Destruct<BR>\n\t1. Caused by module operating computer.<BR>\n\tAction:<BR>\n\t\tAfter the specified time the module will eject completely.<BR>\n<BR>\nEngine Maintenance Instructions:<BR>\n\tShut off ignition systems:<BR>\n\tActivate internal power<BR>\n\tActivate orbital balance matrix<BR>\n\tRemove volatile liquids from area<BR>\n\tWear a fire suit<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nToxin Laboratory Procedure:<BR>\n\tWear a gas mask regardless<BR>\n\tGet an oxygen tank.<BR>\n\tActivate internal atmosphere<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nDisaster Procedure:<BR>\n\tFire:<BR>\n\t\tActivate sector fire alarm.<BR>\n\t\tMove to a safe area.<BR>\n\t\tGet a fire suit<BR>\n\t\tAfter:<BR>\n\t\t\tAssess Damage<BR>\n\t\t\tRepair damages<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tMeteor Shower:<BR>\n\t\tActivate fire alarm<BR>\n\t\tMove to the back of ship<BR>\n\t\tAfter<BR>\n\t\t\tRepair damage<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tAccidental Reentry:<BR>\n\t\tActivate fire alrms in front of ship.<BR>\n\t\tMove volatile matter to a fire proof area!<BR>\n\t\tGet a fire suit.<BR>\n\t\tStay secure until an emergency ship arrives.<BR>\n<BR>\n\t\tIf ship does not arrive-<BR>\n\t\t\tEvacuate to a nearby safe area!"

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
<li>With the power generation rate stable, engage charging of the superconducting magnetic energy storage (SMES) devices in the Power Room. Total charging input rates between all connected SMES cells must not exceed the available generator output.</ol>
<HR>
<i>Warning!</i> Improper engine and generator operation may cause exposure to hazardous gasses, extremes of heat and cold, and dangerous electrical voltages.
Only trained personnel should operate station systems. Follow all procedures carefully. Wear correct personal protective equipment at all times. Ensure that you know the location of all safety equipment before working.
<HR>

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
	info = {"Some fucking asshole broke into our vault all by themselves! How the hell did they even manage that?<br>
			<br>
			They messed with the <b><i>Ouroboros Engine</i></b> and those dumb fucks blew up most of the vault too. Nearly blinded myself looking at all that gold. They must have tried using that alchemy stone without a conduit, damn lucky the damage wasn't spread any further<br>
			<br>
			Sent the NTSOs off to the remains of Site Tempus on that dead planet again to hopefully recover the artifact. Gunna need it to revert this place back to how it was. Thank god we were able to recover the Engine.<br>
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
    Many of you have asked "where are the security segways?". Well let me tell you that we finally got rid of those filthy stains on the cover of the Space Law and permanently brigged them in some warehouse on the ship.
    <br>
    Now quit bothering us with your nonsensical questions and get back to work!
    <br>
    <font size=1>- Head of Security </font>"}

/obj/item/paper/mantasecscanners
	name = "paper - Security Officers are so dumb!"
	icon_state = "paper"
	info ={"Man, I can't believe how ridiculously dumb those security officers are! It's been weeks since I cut the wires to the security scanners on the left and right side of security and yet they still haven't noticed!<br>
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

	With best regards, Nanotrasen HR department. <br>"}

/obj/item/paper/antisingularity
	name = "paper - How to properly operate Singularity Buster rocket launcher"
	icon_state = "paper"
	info = {"<center><h2>How to properly operate Singularity Buster rocket launcher</h2></center>
	<h3>Quick word from the manufacturer</h3><hr>
	Please note that this highly experimental weapon is designed to reliably collapse a singularity in order to prevent catastrophic damage to the station. The singularity buster rockets are theoretically harmless to humans. Please do not try shooting a rocket at a human.<hr>
	<h3>Operating Singularity Buster rocket launcher</h3><hr>
	<ul style='list-style-type:disc'>
		<li>1) Carefully pick up a singularity buster rocket and load it into the loading chamber of the rocket launcher. Please make sure not to hit the rocket on any hard surfaces while doing so as this may lead to matter destabilization. </li>
		<li>2) Pick up the rocket launcher on your shoulders, yet again making sure not to hit the rocket launcher on any hard surfaces as this might accidentally disintegrate the weapon.</li>
		<li>3) Point the rocket launcher carefully towards the center of a rogue singularity.</li>
		<li>4) Press the trigger and prepare for the rocket to fly out of the barrel. This might be a good moment to pray for your safety if you are into that kind of thing as there is a slight chance for the rocket to destabilize and cause a new singularity to appear in it's location. </li>
		<li>5) Singularities gravitional pull may move the rocket off course, requiring several attempts at collapsing the singularity.</li>
	</ul>
	"}

/obj/item/paper/neonlining
	name = "paper - How to properly install official Nanotrasen neon lining"
	icon_state = "paper"
	info = {"<center><h2>How to properly install official Nanotrasen neon lining</h2></center>
	<h3>Product description</h3><hr>
	Ever wanted to spice up your bar? Build a meditation room? Enhance the station halls in case of an emergency? Then this official Nanotrasen neon lining are what you need. Now with color change modules!<hr>
	<h3>Modifying the neon lining</h3><hr>
	<ul style='list-style-type:disc'>
		<li>1) A wrench can be used to change the shape of the lining. Currently only 6 shapes officially supported.</li>
		<li>2) To turn an already attached piece of lining back into a coil, carefully use a crowbar to detach it from the it's attachment point.</li>
		<li>3) Apply a standard multitool to change the pattern of the lining. If upon changing shape the pattern's value is higher than the maximum for that shape, the value gets automatically reset to 0.</li>
		<li>4) As this version is designed to be more flexible and compact, the lining feeds only on an internal power source. Due to this the only way to turn it off/on is to cut/mend the wires that connect to said power source.</li>
		<li>5) To adjust the lining's rotation, simply unscrew it from it's attachment point. The lining will automatically snap to the next available rotation and screw itself into a new attachment point.</li>
		<li>6) Due to safety concerns caused by our previous prototype of the product, the color change modules are only active when the lining is detached and thus in a coil.</li>
		<li>7) There have been reports that when the lining is in the short line shape, using a multitool to change the pattern sometimes triggers the movement function of it's rotation program. This essentially shifts the lining a bit. We understand that this might be a bit unintuitive, but since this isn't hazardous we have no intentions of fixing it.</li>
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
	Pathogens can be scary! But you can rest easy knowing that your health is in safe hands now that you have contacted the CDC. Simply place a pathogen sample into the biohazard crate and send it back to us and we will have you cured in no time!<hr>
	<h3>How to send a pathogen sample</h3><hr>
	<ul style='list-style-type:disc'>
		<li>1) Fill a reagent container with a blood sample from a person afflicted with the pathogen you are seeking to cure. (For instance, you could use the syringe we sent you!)</li>
		<li>2) Deposit reagent container into the received biohazard crate and close it.</li>
		<li>3) Send the biohazard crate back to us.</li>
		<li>4) As soon as we receive your sample, you can contact us using your Quartermaster's Console to ask us to start analyzing it.</li>
		<li>5) Once we are done analyzing your sample, we will offer to sell you cures. Buying a pack of multiple cures at a time will be cheaper for you!</li>
	</ul>
	We hope that you have found this pamphlet enlightening and we hope to receive your sample soon!<hr>
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
	So read carefully and heed the precautions! Keep the fridges closed! All of them! Do not look inside...and if you happen to hear any clawing, grumbling, or cries for help...<b>ignore them</b>!
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
	<i>Ey! Yo! What the hell? You think you can take a day off - relax - and then these hungry n'angry food pirates come along! Damn Thompson McGreasy; unable to close his trash-pod he arrived in. Now we gotta deal with some mutant mice problem!</i>
	"}

/obj/item/paper/fortune
	name = "fortune"
	info = {"<center>YOUR FORTUNE</center>"}
	desc = "A slip of paper with a life-changing prophecy printed on it."
	icon_state = "fortune"

	var/list/action = list("Beware of", "Keep an eye on", "Seek out", "Be wary of", "Make friends with", "Aid", "Talk to", "Avoid")
	var/list/who = list("Zero-G Chem-Co Commander", "Shambling Abomination", "Merlin", "GeneTek Operative Javelin (as Destiny Calls)", "Remy", "Dr. Acula", "Morty")
	var/list/thing = list("are in possession of highly dangerous contraband.", "murdered a bee.", "kicked George.", "are a Syndicate operative.", "are a murderer.", "have disguised themselves from their true form.",
	"are not who they claim to be.", "know Shitty Bill's secret.", "are lonely.", "hugged a space bear and survived to tell the tale.", "know the legendary double-fry technique.", "have the power to reanimate the dead.",
	"consort with wizards.", "sell really awesome drugs.", "have all-access.", "know the king.", "make amazing pizza.", "have a toolbox and are not afraid to use it.")
	var/list/general = list("NanoTrasen locked me to this desk and is forcing me to make fortunes for these cookies please help!", "Help I'm trapped in this cookie!", "Buy Discount Dan's today!")
	var/list/sol = list("He plunged into the sea.", "Follow the NSS Polaris.", "Across the Channel.", "It's in the Void.")

	New()

		var/randme = rand(1,10)
		var/fortune = "Blah."

		for(var/datum/data/record/t in data_core.general)
			who += "[t.fields["name"]]"

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
	var/photo_id = 0.0
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
	amount = 10.0
	item_state = "sheet-metal"
	throwforce = 1
	w_class = 3.0
	throw_speed = 3
	throw_range = 7

	//cogwerks - burn vars
	burn_point = 600
	burn_output = 800
	burn_possible = 1
	health = 100


/obj/item/paper_bin/proc/update()
	tooltip_rebuild = 1
	src.icon_state = "paper_bin[(src.amount || locate(/obj/item/paper, src)) ? "1" : null]"
	return

/obj/item/paper_bin/MouseDrop(mob/user as mob)
	if (user == usr && !usr.restrained() && !usr.stat && (usr.contents.Find(src) || in_range(src, usr)))
		if (!user.put_in_hand(src))
			return ..()

/obj/item/paper_bin/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	var/obj/item/paper = locate(/obj/item/paper) in src
	if (paper)
		user.put_in_hand_or_drop(paper)
	else
		if (src.amount >= 1 && user) //Wire: Fix for Cannot read null.loc (&& user)
			src.amount--
			var/obj/item/paper/P = unpool(/obj/item/paper)
			P.set_loc(src)
			user.put_in_hand_or_drop(P)
			if (rand(1,100) == 13)
				P.info = "Help me! I am being forced to code SS13 and It won't let me leave."
	src.update()
	return

/obj/item/paper_bin/attackby(obj/item/paper/P as obj, mob/user as mob) // finally you can write on all the paper AND put it back in the bin to mess with whoever shows up after you ha ha
	if (istype(P))
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

/*
/obj/item/paper_bin/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/paper))
		user.drop_item()
		W.set_loc(src)
	else
		if (isweldingtool(W))
			if ((T:try_weld(user,0,1,0,0) && T:weldfuel > 0))
				viewers(user, null) << text("[] burns the paper with the welding tool!", user)
				SPAWN_DBG( 0 )
					src.burn(1800000.0)
					return
		else
			if (istype(W, /obj/item/device/igniter))
				viewers(user, null) << text("[] burns the paper with the igniter!", user)
				SPAWN_DBG( 0 )
					src.burn(1800000.0)
					return
	src.update()
	return
*/ //TODO: FIX

/obj/item/stamp
	name = "rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/writing.dmi'
	icon_state = "stamp"
	item_state = "stamp"
	flags = FPRINT | TABLEPASS
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	m_amt = 60
	stamina_damage = 0
	stamina_cost = 0
	rand_pos = 1
	var/is_reassignable = 1
	var/assignment = null
	var/available_modes = list("Approved", "Rejected", "Void", "X", "Current Time");
	var/current_mode = "Approved"

/obj/item/stamp/proc/set_assignment(A)
	if (istext(A))
		src.assignment = A
		src.desc = "A rubber stamp for stamping important documents. It is assigned to: \"[A]\"."
		return
	else
		src.assignment = null
		src.desc = "A rubber stamp for stamping important documents."
		return

/obj/item/stamp/proc/get_stamp_text()
	var/T = null;
	switch (src.current_mode)
		if ("Approved")
			if (src.assignment)
				T = "APPROVED ([src.assignment])"
			else
				T = "APPROVED"
		if ("Rejected")
			if (src.assignment)
				T = "REJECTED ([src.assignment])"
			else
				T = "REJECTED"
		if ("Void")
			T = "VOID"
		if ("X")
			T = "X"
		if ("Current Time")
			if (ticker)
				var/S = round(ticker.round_elapsed_ticks / 10)
				T = "SHIFT TIME: [round(S / 3600)]:[add_zero(round(S % 3600 / 60), 2)]:[add_zero(num2text(S % 60), 2)]"
			else
				T = "SHIFT TIME"
		else
			T = src.current_mode
	return "<span style='font-family: Georgia; font-style: normal; font-weight: normal; font-size: 16px; color: red;'><b>\[</b>[T]<b>\]</b></span>"

/obj/item/stamp/attackby(obj/item/C as obj, mob/user as mob)// assignment with ID
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
	src.current_mode = NM
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
		name = "captain's rubber stamp"
		desc = "The Captain's rubber stamp for stamping important documents."
		icon_state = "stamp-cap"
		is_reassignable = 0
		assignment = "Captain"
	hop
		name = "head of personnel's rubber stamp"
		desc = "The Head of Personnel's rubber stamp for stamping important documents."
		icon_state = "stamp-hop"
		is_reassignable = 0
		assignment = "Head of Personnel"
	hos
		name = "head of security's rubber stamp"
		desc = "The Head of Security's rubber stamp for stamping important documents."
		icon_state = "stamp-hos"
		is_reassignable = 0
		assignment = "Head of Security"
	ce
		name = "chief engineer's rubber stamp"
		desc = "The Chief Engineer's rubber stamp for stamping important documents."
		icon_state = "stamp-ce"
		is_reassignable = 0
		assignment = "Chief Engineer"
	md
		name = "medical director's rubber stamp"
		desc = "The Medical Director's rubber stamp for stamping important documents."
		icon_state = "stamp-md"
		is_reassignable = 0
		assignment = "Medical Director"
	rd
		name = "research director's rubber stamp"
		desc = "The Research Director's rubber stamp for stamping important documents."
		icon_state = "stamp-rd"
		is_reassignable = 0
		assignment = "Research Director"
	clown
		name = "clown's rubber stamp"
		desc = "The Clown's rubber stamp for stamping whatever important documents they've gotten their hands on."
		icon_state = "stamp-honk"
		is_reassignable = 0
		assignment = "Clown"
		get_stamp_text()
			var/T = null;
			switch (src.current_mode)
				if ("Approved")
					T = " :o) "
				if ("Rejected")
					T = html_encode(" >:o( ")
				if ("Void")
					T = "HONK"
				if ("X")
					T = pick("X", "!", "#", "?")
				if ("Current Time")
					if (ticker)
						var/S = round(ticker.round_elapsed_ticks / 10)
						T = "HONK O'CLOCK: [round(S / 3600)]:[add_zero(round(S % 3600 / 60), 2)]:[add_zero(num2text(S % 60), 2)]"
					else
						T = "HONK O'CLOCK"
				else
					T = src.current_mode
			return "<span style='font-family: Georgia; font-style: normal; font-weight: normal; font-size: 24px; color: red;'><b>\[</b><span style='font-family: Comic Sans MS;'>[T]</span><b>\]</b></span>"

/* who did this
/obj/item/stamp/New()

	..()
	return
WHO DID THIS */

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

/obj/item/paper/folded/plane/hit_check()
	if(src.throwing)
		src.throw_unlimited = 1

/obj/item/paper/folded/ball
	name = "paper ball"
	desc = "It's really fun pelting your coworkers with these."
	icon_state = "paperball"

/obj/item/paper/folded/ball/attack(mob/M as mob, mob/user as mob)
	if (iscarbon(M) && M == user)
		M.visible_message("<span class='notice'>[M] stuffs [src] into [his_or_her(M)] mouth and and eats it.</span>")
		eat_twitch(M)
		var/obj/item/paper/P = src
		src = null
		usr.u_equip(P)
		pool(P)
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
<td><b>"Execute"</b></td>
<td>30 PU</td>
<td>Turn your Lawbringer™ into your favourite sidearm with these .38 Full Metal Jacket rounds!</td>
</tr>
<tr>
<td><b>"Hotshot"</b></td>
<td>60 PU</td>
<td>This handy flare gun/flamethrower option is sure to heat things up! The Lawbringer™ is not certified fireproof. Do not set on fire.</td>
</tr>
<tr>
<td><b>"Smokeshot"</b></td>
<td>50 PU</td>
<td>Never use a riot launcher again! These smoke grenades will let you manage line of sight with ease.</td>
</tr>
<tr>
<td><b>"Knockout"</b></td>
<td>60 PU</td>
<td>When you just can't get things to slow down, <i>make 'em</i> slow down with these handy haloperidol tranquilizer darts!</td>
</tr>
<tr>
<td><b>"Bigshot"*</b></td>
<td>170 PU</td>
<td>You'll be the talk of the station when you bust down a wall with one of these explosive rounds! May cause loss of limbs or life.</td>
</tr>
<tr>
<td><b>"Clownshot"</b></td>
<td>15 PU</td>
<td>Lawbringer™ warranty is voided if exposed to clowns. Keep them at bay.</td>
</tr>
<tr>
<td><b>"Pulse"</b></td>
<td>35 PU</td>
<td>Just like our patented Pulse Rifle™s, this Mode sends your enemies flying! Keep crime at arm's length!</td>
</tr>
</table>
<i><b>*</b>Also accepted for this Mode: "High Explosive," "HE."</i>
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

	//sizex = 1066
	//sizey = 735

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/mushroom_station.png")]'></body></html>"
