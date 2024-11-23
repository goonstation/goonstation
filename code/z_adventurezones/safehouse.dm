/*
    Contains code specific to prefab_safehouse.dmm.
	Puzzle spoilers below!
		- MetricDuck

	All resprites/colours specific to this prefab have been located in:
		'icons/obj/adventurezones/safehouse.dmi'
		'icons/obj/large/32x48.dmi'.

	----- TABLE OF CONTENTS ------
		AREAS
		TURFS
        ASTEROID DOOR PUZZLE
		SAFE ROOM PUZZLE
		CLONESCAN HEALTH IMPLANT
		DECORATIVE OBJECTS
		NOTES AND EMAILS

*/
//AREAS

/area/prefab/safehouse
	name = "Safehouse"
	icon_state = "orange"

	asteroiddoors
		name = "Safehouse (asteroid doors)"
		icon_state = "green"

//TURFS

/turf/unsimulated/floor/circuit/green/green_CO2
	icon_state = "circuit-green"
	RL_LumR = 0
	RL_LumG = 0.3
	RL_LumB = 0
	carbon_dioxide = 90
	nitrogen = 7
	oxygen = 3

/turf/unsimulated/floor/circuit/vintage/vintage_CO2
	icon_state = "circuit-vint1"
	RL_LumR = 0.1
	RL_LumG = 0.1
	RL_LumB = 0.1
	carbon_dioxide = 90
	nitrogen = 7
	oxygen = 3

//ASTEROID DOOR PUZZLE

/obj/machinery/door/poddoor/blast/asteroid
	name = "asteroid"
	id = "podbay_saferoom"
	icon = 'icons/obj/adventurezones/safehouse.dmi'
	icon_state = "adoorsingle1"
	desc = "A free-floating mineral deposit from space."
	icon_base = "adoor"
	doordir = "single"
	plane = PLANE_NOSHADOW_BELOW
	color = "#D1E6FF" //To match with asteroid var/stone_color, change if you need it to match something.

	flags = IS_PERSPECTIVE_FLUID | FLUID_DENSE //The poddoors aren't inherently fullbright, need a suitable turf or area underneath.

	podbay_autoclose
		autoclose = TRUE

		asteroid_horizontal
			name = "asteroid"
			id = "podbay_saferoom"
			dir = NORTH

			vertical
				dir = EAST

/obj/machinery/door_control/podbay/suspiciousdebris
	name = "suspicious debris"
	id = "podbay_safehouse"
	icon = 'icons/obj/adventurezones/safehouse.dmi'
	icon_state = "doorctrl0"
	desc = "Someone appears to have bolted this useless heap of junk to an asteroid."
	layer = OBJ_LAYER
	cooldown = 6 DECI SECONDS //To try and sync animation without redefining attack_hand.

//SAFE ROOM PUZZLE

/mob/living/carbon/human/dead_exec
	name = "Jean Rockefeller" //This guy shows up as invisible in StrongDMM, not a clue why.
	real_name = "Jean Rockefeller"
	gender = MALE
	interesting = "This guy seems like he's been through a lot."

	initializeBioholder() //We need bioholder data intialised so we can use it elsewhere.
		bioHolder.ownerName = name
		bioHolder.ownerType = src.type
		bioHolder.mobAppearance.customizations["hair_bottom"].style =  new /datum/customization_style/moustache/vandyke
		bioHolder.mobAppearance.customizations["hair_bottom"].color = "#241200"
		bioHolder.mobAppearance.customizations["hair_middle"].style =  new /datum/customization_style/none
		bioHolder.mobAppearance.customizations["hair_middle"].color = "#241200"
		bioHolder.mobAppearance.customizations["hair_top"].style =  new /datum/customization_style/none
		bioHolder.mobAppearance.customizations["hair_top"].color = "#241200"
		bioHolder.mobAppearance.e_color = "#363978"
		bioHolder.mobAppearance.s_tone = "#FFCC99"
		bioHolder.age = 52
		bioHolder.bloodType = "O+"
		bioHolder.mobAppearance.gender = "male"
		bioHolder.mobAppearance.underwear = "none"
		bioHolder.mobAppearance.u_color = "#FFFFFF"
		bioHolder.Uid = bioHolder.CreateUid()
		bioHolder.build_fingerprints()
		. = ..()

obj/item/reagent_containers/iv_drip/dead_exec
	desc = "A bag filled with someone's blood. It's labelled 'Jean Rockefeller'."
	icon_state = "IV-blood"
	mode = 1
	initial_reagents = "blood"

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

/obj/machinery/bio_handscanner
	name = "Hand Scanner"
	desc = "A biometric hand scanner."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "handscanner"
	var/id = "clone room"
	var/allowed_bioHolders = null
	var/cooldown = 1 SECOND

	New()
		..()
		START_TRACKING
		UnsubscribeProcess()

	disposing()
		STOP_TRACKING
		..()

/obj/machinery/bio_handscanner/attackby(obj/item/W, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	if(ON_COOLDOWN(src, "bio_handscanner_attackby", cooldown)) // To reduce chat spam in case of multi-click
		return
	if(istype(W, /obj/item/parts/human_parts/arm/))
		boutput(user, SPAN_ALERT("ERROR: no pulse detected."))
	if(istype(W, /obj/item/card/emag))
		boutput(user, "You short out the hand scanner's circuits. So much for cutting edge.")
		for(var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
			if(M.id == src.id)
				if(M.density)
					M.open()
				else
					M.close()

/obj/machinery/bio_handscanner/attack_hand(mob/user)
	src.add_fingerprint(user)
	if(ON_COOLDOWN(src, "bio_handscanner_attackhand", cooldown)) // To reduce chat spam in case of multi-click
		return
	playsound(src.loc, 'sound/effects/handscan.ogg', 50, 1)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.bioHolder.Uid == allowed_bioHolders) //Are you the authorised bioHolder (for all intents and purposes)?
			user.visible_message(SPAN_NOTICE("The [src] accepts the biometrics of the hand and beeps."))
			for(var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
				if(M.id == src.id)
					if(M.density)
						M.open()
					else
						M.close()
		else
			boutput(user, SPAN_ALERT("Invalid biometric profile. Access denied."))

/obj/fakeobject/safehouse/cloner
	name = "lazarus H-16 cloning pod"
	desc = "An advanced cloning pod, designed to be operated automatically through packets. What a great idea!"
	icon = 'icons/obj/adventurezones/safehouse.dmi'
	icon_state = "cloner1"
	anchored = ANCHORED
	density = 1
	layer = 3.1
	var/datum/light/light

	New()
		..()

		light = new /datum/light/point
		light.set_brightness(0.5)
		light.set_color(0.1,1.0,0.1)
		light.attach(src)
		light.enable()

		SPAWN(5 SECONDS) //give it a sec
			var/mob/living/carbon/human/dead_exec/M //Setting up the puzzle
			M = new /mob/living/carbon/human/dead_exec(src.loc) //aka Jean
			var/datum/bioHolder/D = new/datum/bioHolder(null)
			D.CopyOther(M.bioHolder)

			for_by_tcl(O, /obj/machinery/bio_handscanner)
				O.allowed_bioHolders = D.Uid //Copy the Uid only, copying and comparing against all bioHolder data is too prone to error.

			for_by_tcl(O, /obj/item/reagent_containers/iv_drip/dead_exec)
				if(!O.reagents.has_reagent("blood"))
					return
				var/datum/reagent/blood/B = O.reagents.reagent_list["blood"]
				B.data = D //Give the blood Jean's bioHolder info.

			sleep(5 SECONDS) //Jean's just here to set up the puzzle, we don't want him sticking around.
			qdel(M)

	attack_hand(mob/user)
		boutput(user, "An advanced cloning pod, designed to be operated automatically through packets. What a great idea!<br>Currently idle.<br>[SPAN_ALERT("Alert: Biomatter reserves are low (5% full).")]")
		playsound(src.loc, 'sound/impact_sounds/Generic_Stab_1.ogg', 25, 1)
		src.add_fingerprint(user)
		return

/obj/item/reagent_containers/food/drinks/bottle/soda/lithiawater
	name = "mineral water"
	desc = "Mineral spring water bottled at source on earth. Shipped out to the frontier at an extortionate, and pointless, cost."
	label = "water"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("water"=40,"lithium"=10)

/obj/item/storage/firstaid/hangover
	name = "hangover survival kit"
	icon_state = "berserk1"
	item_state = "berserk1"
	desc = "A medical kit designed to treat the symptoms of poor decision making. Alas, it can do nothing for the cause."
	kit_styles = list("berserk1", "berserk2", "berserk3")
	spawn_contents = list(/obj/item/reagent_containers/food/drinks/bottle/soda/lithiawater,\
	/obj/item/reagent_containers/emergency_injector/mannitol,\
	/obj/item/reagent_containers/emergency_injector/synaptizine,\
	/obj/item/reagent_containers/pill/salicylic_acid,\
	/obj/item/reagent_containers/pill/mutadone,\
	/obj/item/reagent_containers/pill/antitox,\
	/obj/item/device/analyzer/healthanalyzer)

// CLONESCAN HEALTH IMPLANT

/obj/item/implant/health/exp_health_implant
	name = "experimental health implant"
	desc = ""
	icon_state = "implantpaper-b"
	impcolor = "b"
	var/clonescanned = 0

	activate()
		..()
		clonescanned = 0

	do_process(var/mult = 1) //On do_process so we don't have to worry if the user is dead / in ghostVR.
		if(!ishuman(src.owner))
			return
		if(clonescanned < 11)
			switch(clonescanned++)
				if(1)
					boutput(src.owner,"Life signs detected. Initiating scanning procedure.")
				if(4)
					boutput(src.owner,"Scan complete. Contacting remote server for data upload.")
				if(7)
					boutput(src.owner,"ERROR: Remote server unavailable. Commencing emergency transmisssion protocols. Broadcasting data on all known frequencies.")
				if(10)
					attempt_remote_scan(src.owner)

	on_death()
		if(!ishuman(src.owner))
			return
		attempt_remote_scan(src.owner)

	proc/attempt_remote_scan(mob/living/carbon/human/H)
		for_by_tcl(C, /obj/machinery/computer/cloning) //Scan success or corruption is on a by-computer basis, results allowed to differ.
			C.scan_mob(H) //Take advantage of scan_mob's checks
			var/datum/db_record/R = new /datum/db_record()
			R = C.find_record_by_mind(H.mind)
			if(!isnull(R))// Proceed if scan was a success or user has been scanned previously, our broadcast is interfering with the existing scan.
				boutput(H,"Link to cloning computer establised succesfully.")
				playsound(src.loc, 'sound/machines/ping.ogg', 50, 1)
				var/has_puritan = FALSE
				var/datum/traitHolder/traits = R["traits"]
				if(traits.hasTrait("puritan")) //Does the user's clone record have puritan?
					has_puritan = TRUE
				if(prob(20) && !has_puritan) //If the scan doesn't have puritan, roll a dice. Too uncommon to weaponise too common for general use.
					traits.addTrait("puritan") // Signal has degraded. Did the player learn nothing from the prefab??

//DECORATIVE OBJECTS

/obj/fakeobject/beacon
	name = "broken beacon"
	desc = "A small tracking beacon in fairly poor condition. What's it doing all the way out here?"
	icon = 'icons/obj/adventurezones/safehouse.dmi'
	icon_state = "beaconbroken"
	anchored = ANCHORED

/obj/item/disk/data/fixed_disk/safehouse_rdrive
	New()
		..()
		//First off, create the directory for logging stuff
		var/datum/computer/folder/newfolder = new /datum/computer/folder()

		newfolder.name = "logs"
		src.root.add_file(newfolder)
		newfolder.add_file(new /datum/computer/file/record/c3help(src))

		newfolder = new /datum/computer/folder
		newfolder.name = "bin"
		src.root.add_file(newfolder)
		newfolder.add_file(new /datum/computer/file/terminal_program/writewizard(src))

		newfolder = new /datum/computer/folder
		newfolder.name = "mail"
		src.root.add_file(newfolder)
		newfolder.add_file(new /datum/computer/file/record/saferoom/medical_appointment(src))
		newfolder.add_file(new /datum/computer/file/record/saferoom/handscanner_ceo(src))
		newfolder.add_file(new /datum/computer/file/record/saferoom/package_delivery(src))
		newfolder.add_file(new /datum/computer/file/record/saferoom/party_plans(src))
		newfolder.add_file(new /datum/computer/file/record/saferoom/medical_results(src))

/obj/machinery/computer3/generic/personal/safehouse
	name = "Computer Console"
	setup_drive_type = /obj/item/disk/data/fixed_disk/safehouse_rdrive
	setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card

/obj/item/storage/briefcase/safehouse
	name = "suspicious briefcase"
	desc = "One of those briefcases spies leave at park benches."
	spawn_contents = list(/obj/item/paper/safehouse/cloner_note)

	make_my_stuff()
		..()
		var/obj/item/currency/spacecash/tourist/S1 = new /obj/item/currency/spacecash/tourist
		S1.setup(src, try_add_to_storage = TRUE)
		var/obj/item/currency/spacecash/tourist/S2 = new /obj/item/currency/spacecash/tourist
		S2.setup(src, try_add_to_storage = TRUE)
		var/obj/item/currency/spacecash/tourist/S3 = new /obj/item/currency/spacecash/tourist
		S3.setup(src, try_add_to_storage = TRUE)
		var/obj/item/currency/spacecash/tourist/S4 = new /obj/item/currency/spacecash/tourist
		S4.setup(src, try_add_to_storage = TRUE)

/obj/decal/poster/wallsign/dead_exec_portrait
	name = "executive portrait"
	desc = "A portrait of a man sporting a no-nonsense moustache."
	icon = 'icons/obj/adventurezones/safehouse.dmi'
	icon_state = "deadexecportrait"
	pixel_x = 0;
	pixel_y = 26

	attack_hand(mob/user)
		boutput(user, SPAN_NOTICE("You check behind the [src.name] for a hidden safe, but don't find anything."))
		src.add_fingerprint(user)
		return

/obj/decal/statue/dead_exec_bust
	name = "executive sculpture"
	desc = "A sculpture bearing the likeness of a rather stern-looking man."
	icon = 'icons/obj/adventurezones/safehouse.dmi'
	icon_state = "deadexecbust"
	pixel_x = 0;
	pixel_y = 10

	attack_hand(mob/user)
		boutput(user, SPAN_NOTICE("You rub the sculpture's bald head for luck."))
		src.add_fingerprint(user)
		return

/obj/decal/cleanable/wardrobe_scuff_marks
	name = "scuff mark"
	desc = "Looks like someone's been moving furniture around."
	icon = 'icons/obj/adventurezones/safehouse.dmi'
	icon_state = "scuffmarks"

/obj/fakeobject/recordplayer
	name = "old record player"
	desc = "An old fashioned turntable for playing vinyl. Doesn't appear to be plugged in."
	icon = 'icons/obj/adventurezones/safehouse.dmi'
	icon_state = "recordplayer"
	anchored = ANCHORED
	density = 1

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/record))
			src.visible_message(SPAN_NOTICE("<b>[user] attempts to place the 12 inch record on the 7 inch turntable, but it obviously doesn't fit. How embarassing!</b>"))
		return

	attack_hand(mob/user)
		boutput(user, SPAN_NOTICE("You fiddle with the [src.name] but you can't seem to get it working."))
		src.add_fingerprint(user)
		return

/obj/fakeobject/safehouse/reclaimer
	name = "enzymatic reclaimer"
	desc = "A tank resembling a rather large blender, designed to recover biomatter for use in cloning."
	icon = 'icons/obj/adventurezones/safehouse.dmi'
	icon_state = "reclaimer"
	anchored = ANCHORED
	density = 1
	layer = 3.1 //I mess with layers here & below to help me set-up the clone room. Quite a bit was var-edited in StrongDMM as well.

	attack_hand(mob/user)
		boutput(user, SPAN_NOTICE("You try to activate the [src.name] but nothing happens! Looks like it's jammed"))
		src.add_fingerprint(user)
		return

/obj/fakeobject/safehouse/biomatter_tank
	name = "biomatter reserve tank"
	desc = "A reserve tank for storing large quantities of biomatter. You could clone a small army with a tank that size."
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "biomatter_tank0"
	anchored = ANCHORED
	density = 1
	layer = 3.1

/obj/fakeobject/safehouse/biotube
	name = "biomatter transfer pipe"
	desc = "A large pipe for transporting fluid. It looks very durable."
	icon = 'icons/obj/adventurezones/safehouse.dmi'
	icon_state = "biotube"
	anchored = ANCHORED
	layer = 2.8

/obj/fakeobject/safehouse/conduit
	name = "electrical conduit"
	desc = "An electrical conduit. The casing is welded on"
	icon = 'icons/obj/adventurezones/safehouse.dmi'
	icon_state = "conduit"
	anchored = ANCHORED
	layer = 2.8

/obj/fakeobject/safehouse/mechcomp_cabinet
	name = "component cabinets"
	desc = "A pair of cabinets containing mechanical components, set up to automate operation of the cloner. Technology is incredible!"
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "cabinets1"
	anchored = ANCHORED
	density = 1
	layer = 3.1

/obj/fakeobject/safehouse/cloning_console
	name = "cloning console"
	desc = "A console used to operate a cloning scanner and pod. This one looks like it's seen better days."
	icon = 'icons/obj/computer.dmi'
	icon_state = "scannerb"
	anchored = ANCHORED
	density = 1
	layer = 3.1

/obj/fakeobject/safehouse/dead_exec
	name = "dead clone"
	icon = 'icons/obj/adventurezones/safehouse.dmi'
	icon_state = "deadexecclean"
	anchored = ANCHORED
	layer = 2.9

	bloody
		name = "bloody clone"
		icon_state = "deadexecbloody"

/obj/fakeobject/safehouse/airhandlingunit
	name = "air handling unit"
	desc = "This a recirculating air handling unit designed to keep ambient conditions within comfortable limits."
	icon = 'icons/obj/adventurezones/safehouse.dmi'
	icon_state = "airhandlingunit"
	anchored = ANCHORED
	density = 1

/obj/fakeobject/safehouse/airfilter
	name = "air filter"
	desc = "This is a filter for scrubbing CO2 and other harmful gases out the air. The 'filter clogged' alarm is lit up."
	icon = 'icons/obj/adventurezones/safehouse.dmi'
	icon_state = "filter1"
	anchored = ANCHORED
	density = 1
	var/datum/light/light

	New()
		..()
		light = new/datum/light/point //We want this to stand out in the dark & draw the player to examine it.
		light.set_brightness(0.3)
		light.set_color(1, 0.5, 0.5)
		light.attach(src)
		light.enable()

		var/mutable_appearance/light_ov = mutable_appearance(src.icon, "filterlight") //So it SUPER stands out
		light_ov.plane = PLANE_LIGHTING
		light_ov.alpha = 70

// NOTES AND LOGS

/obj/item/paper/safehouse/delivery_note //The Dancing Script on this is broken (missing "") but I like whatever font it is now so I won't fix it.
	name = "missed delivery"
	desc = "A missed delivery card, typical."
	icon_state= "index_card"
	info = {"<b>Sorry We Missed You!</b>
			<br>We tried to deliver your package today.
			<br>
			<br>-------------------------------------------
			<br>
			<br>Name: <span style='font-family: Dancing Script, cursive;'>Jean Rockefeller</span>
			<br>Tracking number:  <span style='font-family: Dancing Script, cursive;'>9114-9010-7574-2352</span>
			<br>
			<br>-------------------------------------------
			<br>Today we called to deliver your parcels, they were left:
			<br>
			<br>(  ) With your neighbour at:
			<br>(  ) In your shed/outbuilding
			<br>(  ) Secure front hangar
			<br>(  ) Affixed to the hull of your ship/station.
			<br>(X) Returned to mail depot
			<br>(  ) Other:
			<br>
			<br>-------------------------------------------
			<br>We were unable to deliver your parcels because:
			<br>
			<br>(  ) The parcels required a signature
			<br>(  ) There was no safe place to leave your parcel
			<br>(X) Other: <span style='font-family: Dancing Script, cursive;'>Unable to find specified drop-off point</span>
			<br>
			<br>-------------------------------------------
			<br>Additional information<br>
			<br><span style='font-family: Dancing Script, cursive;'> Drop off point was specified as "Private hangar near beacon,
			<br> pull greeter's leg". Instructions are unclear, driver was able to locate the beacon but no greeter was present.
			<br> Additionally, driver does not know any good jokes.</span>
			<br>
			<br>-------------------------------------------
			<br>
			<br><b>TO FIND OUT HOW TO GET YOUR PARCEL PLEASE
			<br>CONTACT A COMPANY REP</b>
			<br>
			"}

/obj/item/paper/safehouse/contractors_note
	name = "crumpled contractor's note"
	desc = "A letter from a construction contractor."
	icon_state= "paper_caution_crumple"
	info = {"Rockefeller,
		<br>
		<br> Took a look at the specifications you sent over and I'm
		<br> confident my crew can get the cloner retrofitted into
		<br> that safe room of yours. Never seen anything quite like
		<br> it before but the documentation seems solid enough - I'll
		<br> send someone over to do a survey and sort out a quote for
		<br> the installation.
		<br>
		<br> Don't worry about discretion - my boys know better than to
		<br> ask questions.
		<br>
		<br> Cheers,
		<br> Dave
		"}

/obj/item/paper/safehouse/cloner_note
	name = "mysterious letter"
	desc = "Looks like an invite to some kind of pilot scheme."
	icon_state= "paper"
	info = {" <span style='font-family: 'Dancing Script', cursive;'>Dear Mr. Rockefeller,
		<br>
		<br> I am delighted to invite you to the new pilot scheme for
		<br> the Lazarus-series cloning pod line.
		<br>
		<br> The company I represent understands that your time is valuable,
		<br> and that the potential time lost accrued from fatal events
		<br> are an overhead you just can't ignore. We want to prove
		<br> ourselves to industry leaders such as yourself by showing you
		<br> first-hand just what our product can do.
		<br>
		<br> Our new range of cloners integrates our HealthScan implant
		<br> line with packet protocols, seamlessly transferring the
		<br> mind from host to clone with near-zero loss of continuity
		<br> in the case of any fatal events.
		<br>
		<br> Please find enclosed a small advance to cover any expenses you
		<br> may have whilst you consider the offer. I hope to hear from
		<br> you soon.
		<br>
		<br> Best regards,
		<br> Jim Molloy
		<br> Head Researcher, VitaNova</span>
		"}

/datum/computer/file/record/saferoom
	New()
		..()
		src.name = "[copytext("\ref[src]", 4, 12)]GENERIC"

	medical_appointment
		New()
			..()
			fields = list("PublicNT", //Mailnet
"*ALL", //Workgroup
"SRUDD@NTMEDICAL", //From
"JROCKEFELLER@DGROUP", //To
"STANDARD", //Importance
"RE: Medical Appointment - Hand tremors", //Subject
"",
"Mr Rockefeller,", //Body
"",
"I'm emailing to confirm your appointment with Dr.",
"Richard McCormack has been set for Tuesday 14th",
"August at 3:00PM. Please plan to arrive at least",
"30 minutes prior to your scheduled appointment",
"in order to allow time for a medical pre-assessment",
"pre-assessment.",
"I understand the MD has waived the usual employee",
"registration  process, so please ask for Dr.",
"McCormack at reception when you arrive.",
"",
"Kind Regards",
"Sarah Rudd")

	handscanner_ceo
		New()
			..()
			fields = list("PublicNT", //Mailnet
"*ALL", //Workgroup
"SUPPORT@SAFESOLUTIONS", //From
"JROCKEFELLER@DGROUP", //To
"STANDARD", //Importance
"Important Product Security Information", //Subject
"",
"Dear Valued Customer,", //Body
"",
"We are writing to you to reassure you regarding some",
"public accusations made by our competitors about the",
"security of our HANDSCAN security product line. We",
"here at SafeSolutions hold our custmer's safety and",
"security in highest regard, and all our products are",
"tested rigorously in-accordance with both industry",
"standards and in cooperation with our corporate",
"partners.",
"",
"Our HANDSCAN line is considered the bleeding-edge",
"of access control technology, using state-of-the art",
"sensors to measure over 40 different biological",
"indicators from a hand signature alone. Indicators", //Wording matches the goonwiki entry on dna_mut. Heart handwaves no loose limbs.
"include but are not limited to: appearance, dna,",
"fingerprints, blood type, latent and manifest genetic",
"mutations, heart signature and many more.",
"",
"To put it simply, nothing short of perfect biological",
"copies of the authorised users are getting in or out",
"of your secure space.",
"",
"For further information on our testing standards and",
"product lines please visit our website.",
"",
"Regards,",
"John Herman-Lee",
"CEO, SafeSolutions Ltd.",
"Your security is our priority.")

	package_delivery
		New()
			..()
			fields = list("PublicNT", //Mailnet
"*ALL", //Workgroup
"ORDERS@EZATMOS", //From
"JROCKEFELLER@DGROUP", //To
"STANDARD", //Importance
"Order ID: 18205791857", //Subject
"",
"Thank you for your order", //Body
"",
"Your order number is 1205791857, and is estimated to",
"arrive in 14-18 standard working days.",
"",
"Here's your order summary:",
"",
"CO2 Filters - 4 off - 1400[CREDIT_SIGN]",
"",
"Subtotal: 1400[CREDIT_SIGN]",
"Shipping: 40[CREDIT_SIGN]",
"Discount 0[CREDIT_SIGN]",
"Grand Total: 1440[CREDIT_SIGN]",
"",
"If you have any queries about your order please log",
"on to our customer portal.",
"",
"EZATMOS")

	party_plans
		New()
			..()
			fields = list("PublicNT", //Mailnet
"*ALL", //Workgroup
"TTANNER@FREENET.FT", //From
"JROCKEFELLER@DGROUP", //To
"STANDARD", //Importance
"That's how it's done, son", //Subject
"",
"Jean Genie!", //Body
"",
"Hell of a bender that was eh? I don't know what was",
"in those pills we found in that bush were but that",
"sure didn't stop you popping them like tic-tacs did",
"it???",
"Party like there's no tomorrow! My kinda guy!!",
"",
"See you next week pal ;)",
"",
"Double T")

	medical_results
		New()
			..()
			fields = list("PublicNT", //Mailnet
"*ALL", //Workgroup
"RMCCORMACK@NTMEDICAL", //From
"JROCKEFELLER@DGROUP", //To
"HIGH", //Importance
"Scan Results", //Subject
"",
"Jean,", //Body
"",
"Mechanics finished their checks of the scanners and",
"they're working fine. This has some deeply concerning",
"implications about the image degradation we saw in",
"your scans.", //Same thing that happens when you scan photocopies over and over.
"Buddy what the hell are you doing out there?",
"",
"Call me ASAP!!",
"",
"Rich")
