/**
Meat Zone
Contents:
	Meaty areas
	Stomach acid turf & such
	Meat lights.  Not to be confused with Spam Lite reduced fat meat-like protein product.
	Grumpy meat-infested monster doors, monster floors, mutant cosmonauts, and a very sad giant head.
	Various log files.
	Audio logs
	Fancy items in the land of meat
	Puzzle elements
	Gross mutant limbs
**/


/*
meaty thoughts from cogwerks to his spacepal aibm:
- meat lights oughta blink more slowly but set luminosity off and on when they do, slowly flickering lights are scary
- those grotesquerie things that look like they have mouths should be a subset of the martian crevice code OK
- and should occasionally devour arms and/or puke up acid into the face of whoever digs around in there
- acid pits could use more sound / user feedback / screaming / hissing / facemelting / usr << OH GOD IT STINGS sorta stuff	OK YES
- add a subtype of landmines that look like a gib pile and just hideously burst (into blood fog???? or just gibs) when stepped on	DONE
- add a horrible distorted wet gurgly scream for the cosmonauts when they attack	DONE
*/

/area/meat_derelict
	icon_state = "red"
	force_fullbright = 0
	sound_group = "meat"
	sound_loop = 'sound/ambience/spooky/Meatzone_BreathingSlow.ogg'
	sound_loop_vol = 60

/area/meat_derelict/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_AREA_PROCESS)

/area/meat_derelict/disposing()
	STOP_TRACKING_CAT(TR_CAT_AREA_PROCESS)
	. = ..()

/area/meat_derelict/area_process()
	if(prob(20))
		src.sound_fx_2 = pick('sound/ambience/spooky/Meatzone_Squishy.ogg',\
			'sound/ambience/spooky/Meatzone_Gurgle.ogg',\
			'sound/ambience/spooky/Meatzone_Howl.ogg',\
			'sound/ambience/spooky/Meatzone_Rumble.ogg')

		for(var/mob/living/carbon/human/H in src)
			H.client?.playAmbience(src, AMBIENCE_FX_2, 60)

/area/meat_derelict/entry
	name = "Teleportation Lab"
	icon_state = "telelab"

/area/meat_derelict/main
	name = "Primary corridor"

/area/meat_derelict/guts
	name = "The Guts"
	icon_state = "green"

/area/meat_derelict/soviet
	name = "Samostrel patrol craft"
	icon_state = "purple"
	sound_loop = 'sound/ambience/spooky/Meatzone_BreathingAndAnthem.ogg'

/area/meat_derelict/boss
	name = "The Heart"
	icon_state = "security"
	sound_loop = 'sound/ambience/spooky/Meatzone_BreathingFast.ogg'
	irradiated = 0.1

/turf/unsimulated/floor/setpieces/bloodfloor/stomach
	name = "acid"
	density = 0
	desc = "A pool of stomach acid.  Lovely."
	icon = 'icons/misc/meatland.dmi'
	icon_state = "acid_floor"
	New()
		..()
		set_dir(pick(NORTH,SOUTH))

/obj/crevice/meatland
	name = "macabre grotesquerie"
	density = 1
	desc = "It keeps pulsing.  Ew.  Probably shouldn't put your hand in the..mouth?"
	icon = 'icons/misc/meatland.dmi'
	icon_state = "meatlumps"
	dir = EAST

/obj/stomachacid
	name = "acid"
	density = 0
	anchored = ANCHORED
	icon = 'icons/misc/meatland.dmi'
	icon_state = "acid_depth"
	layer = EFFECTS_LAYER_UNDER_1
	plane = PLANE_NOSHADOW_ABOVE
	mouse_opacity = 0

	New()
		..()
		src.create_reagents(25)
		reagents.add_reagent("acid",20)
		reagents.add_reagent("vomit",5)

	Crossed(atom/movable/A)
		..()
		if(!istype(A, /obj/item/skull))
			reagents.reaction(A, TOUCH, 2)
		if (prob(50) && isliving(A))
			boutput(A, pick(SPAN_ALERT("This stings!"), SPAN_ALERT("Oh jesus this burns!!"), SPAN_ALERT("ow ow OW OW OW OW"), SPAN_ALERT("oh cripes this isn't the fun kind of acid"), SPAN_ALERT("ow OW OUCH FUCK OW")))
			if (ishuman(A) && prob(80))
				A:emote("scream")
		return

/obj/meatlight
	name = "luminous lumplette"
	desc = "The masons inscribed the all-seeing eye of providence on the dollar bill as part of a great conspiracy.  Ha ha, nah, I'm lying. The symbol was added years before the masons started using it by an artist who probably just thought it looked cool.  Anyway, this sure is a gross blobby thing, ain't it?"
	icon = 'icons/misc/meatland.dmi'
	icon_state = "light"
	anchored = ANCHORED
	density = 1
	var/health = 10
	var/alive = 1
	var/brightness = 3
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.attach(src)
		light.set_color(0.87, 0.937, 0.42)
		light.set_brightness(src.brightness / 5)
		light.enable()

	attackby(obj/item/O, mob/user)
		if (src.alive && O.force)
			src.health -= O.force / 4
			src.visible_message(SPAN_ALERT("<b>[user] bops [src] with [O]!</b>"))
			if (src.health <= 0)
				src.alive = 0
				src.visible_message(SPAN_ALERT("<b>[src]</b> dies!"))
				src.icon_state = "light-dead"
				light.disable()

		else
			..()

/obj/critter/monster_door
	name = "airlock"
	icon = 'icons/misc/meatland.dmi'
	icon_state = "eatdoor"
	desc = "A hydraulic door capable of withstanding multiple atmospheres of pressure. Oh, except this one. This one is all broken and covered in blood."
	wanderer = 0
	opacity = 1
	anchored = ANCHORED
	seekrange = 1
	attack_range = 1
	butcherable = BUTCHER_NOT_ALLOWED
	density = 1
	aggressive = 1
	atkcarbon = 1
	atksilicon = 1
	health = 40
	brutevuln = 0.6
	firevuln = 0.15
	angertext = "bares jagged fangs at"
	generic = 0
	is_pet = 0


	floor
		name = "floor"
		desc = ""
		icon_state = "eatfloor"
		attack_range = 0
		density = 0
		opacity = 0
		layer = FLOOR_EQUIP_LAYER1
		plane = PLANE_FLOOR

		New()
			..()
			if (src.loc)
				src.loc.invisibility = INVIS_ALWAYS_ISH //Hide the floor below us so people don't just right click and see two floors.

		attackby(obj/item/O, mob/user)
			if (src.alive && ispryingtool(O))
				user.visible_message(SPAN_ALERT("<b>[user] jabs [src] with [O]!</b>"), SPAN_ALERT("You jab [src] with [O] and begin to pull!  Hold on!"))
				if (do_after(user, 2 SECONDS))
					playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
					gibs(src.loc)
					if (src.loc)
						new /obj/item/tile/steel (src.loc)
						src.loc.invisibility = INVIS_NONE

					qdel(src)
					return

			else
				return ..()

	attack_hand(mob/user)
		if (src.alive)
			if (!attacking)
				return ai_think()

			else if(aggressive && user.a_intent == "help")
				return

		return ..()

	CritterAttack(mob/M)
		if(ismob(M))
			src.attacking = 1
			src.visible_message(SPAN_ALERT("<B>[src]</B> chomps down on [M]!"))
			playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
			random_brute_damage(M, rand(10,35), 1)
			SPAWN(1 SECOND)
				src.attacking = 0

	ai_think()
		if(task == "chasing")
			if (src.frustration >= 8)
				src.target = null
				src.last_found = world.time
				src.frustration = 0
				src.task = "thinking"

			src.icon_state = "[initial(src.icon_state)]-attack"
			src.set_opacity(0)
			if (target)
				if (GET_DIST(src, src.target) <= src.attack_range)
					var/mob/living/carbon/M = src.target
					if (M)
						CritterAttack(M)
						src.task = "attacking"
						src.anchored = ANCHORED
						src.target_lastloc = M.loc
				else
					if ((GET_DIST(src, src.target)) >= src.attack_range)
						src.frustration++
					else
						src.frustration = 0
			else
				src.task = "thinking"
		else if (task == "attacking")
			src.icon_state = "[initial(src.icon_state)]-attack"
			src.set_opacity(0)
			return ..()
		else
			src.icon_state = initial(src.icon_state)
			src.set_opacity(initial(src.opacity))
			return ..()

	proc/update_meat_head_dialog(var/new_text)
		if (!new_text || !length(ckey(new_text)))
			return
		var/obj/critter/monster_door/meat_head/main_meat_head = by_type[/obj/critter/monster_door/meat_head][1]
		main_meat_head.update_meat_head_dialog(new_text)

#define MEATHEAD_MAX_CUSTOM_UTTERANCES 32

TYPEINFO(/obj/critter/monster_door/meat_head)
	start_listen_effects = list(LISTEN_EFFECT_MEAT_HEAD)
	start_listen_modifiers = null
	start_listen_inputs = list(LISTEN_INPUT_OUTLOUD)
	start_listen_languages = list(LANGUAGE_ALL)
	start_speech_modifiers = null
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_LOCAL)

/obj/critter/monster_door/meat_head //Clash at Meathead
	name = "Something"
	desc = "jesus fuck"
	density = 1
	defensive = 1
	opacity = 0
	anchored = ANCHORED
	aggressive = 0
	health = 4000
	icon = 'icons/effects/64x64.dmi'
	icon_state = "meatboss_sad"
	bound_height = 64
	bound_width = 64
	angertext = "shakes and wobbles furiously at"

	speech_verb_say = list("mutters", "gurgles", "whimpers")
	default_speech_output_channel = SAY_CHANNEL_OUTLOUD
	say_language = LANGUAGE_ENGLISH

	var/list/dialog = null
	var/obj/item/clothing/head/hat = null
	var/static/list/meathead_noises = list('sound/misc/meat_gargle.ogg', 'sound/misc/meat_hork.ogg', 'sound/misc/meat_plop.ogg', 'sound/misc/meat_splat.ogg')
	var/static/list/default_meat_head_dialog = list("hello hello", "... it's not viral, it's some kind of ... stress ... hello", "what is that ...", "... hurts ...",
"...FACILITY IS ON RED ALERT...","...why...","...proper safety precautions were not....","...is it...", "...this isn't...")

	New()
		..()
		dialog = default_meat_head_dialog.Copy()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	CritterDeath()
		if (!src.alive) return
		..()
		src.icon_state = "meatboss_dead" // why can't you just use a - like everyone else

	ai_think()
		if(task == "chasing")
			if (src.frustration >= 4)
				src.target = null
				src.last_found = world.time
				src.frustration = 0
				src.task = "thinking"

			src.icon_state = "[initial(src.icon_state)]-attack"
			src.set_opacity(0)
			if (target)
				if(prob(30))
					playsound(src.loc, pick(meathead_noises), 40, 1)
				if (GET_DIST(src, src.target) <= src.attack_range)
					var/mob/living/carbon/M = src.target
					if (M)
						CritterAttack(M)
						src.task = "attacking"
						src.anchored = ANCHORED
						src.target_lastloc = M.loc
				else
					if ((GET_DIST(src, src.target)) >= src.attack_range)
						src.frustration++
					else
						src.frustration = 0
			else
				src.task = "thinking"
		else if (task == "chasing")
			src.icon_state = "[initial(src.icon_state)]-attack"
			return ..()
		else
			src.icon_state = initial(src.icon_state)
			if (prob(10) && length(src.dialog) && src.alive)
				FLICK("meatboss_chatter", src)
				playsound(src.loc, pick(src.meathead_noises), 40, 1)
				src.say(pick(src.dialog))

			return ..()

	CritterAttack(mob/M)
		if (!ismob(M))
			return

		src.attacking = 1
		src.visible_message(SPAN_ALERT("[src] slaps [M] with a meaty tendril!"))
		playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
		M.changeStatus("knockdown", 10 SECONDS)
		random_brute_damage(M, 10, 1)
		M.throw_at(get_edge_target_turf(M, get_dir(src, get_step_away(M, src))), 200, 4)

		src.target = null
		src.last_found = world.time
		src.frustration = 0
		src.task = "thinking"

		SPAWN(3 SECONDS)
			src.attacking = 0

	update_meat_head_dialog(var/message)
		if (!message)
			return 1

		. = ckey(message)
		for (var/test_string in dialog)
			if (. == ckey(test_string))
				return 1

		var/list/exploded_sentence = splittext(message, " ")
		if (!exploded_sentence || !length(exploded_sentence))
			return 1

		if (length(exploded_sentence) > 1)
			if (prob(50))
				exploded_sentence.Cut( rand(1, round(exploded_sentence.len / 2)))
				exploded_sentence.len = max(5, exploded_sentence.len - rand(1,4))

			else
				for (var/i = 1, i <= exploded_sentence.len, i++)
					if (prob(10))
						exploded_sentence[i] = "..."

		. = jointext(exploded_sentence, " ")
		dialog += .

		if ((dialog.len - default_meat_head_dialog.len) > MEATHEAD_MAX_CUSTOM_UTTERANCES)
			dialog.Cut(MEATHEAD_MAX_CUSTOM_UTTERANCES, MEATHEAD_MAX_CUSTOM_UTTERANCES+1)

		return 0

	attackby(obj/item/O, mob/user)
		if (istype(O, /obj/item/clothing/head))
			user.visible_message("[user] tosses [O] onto [src]!", "You toss [O] onto [src].")

			user.drop_item()
			O.set_loc( user.loc )

			O.layer = src.layer+0.1
			animate(O, pixel_x = 11 + (16 * (src.x - O.x)), pixel_y = (32 * (1 + src.y - O.y)), time = 2, loop = 1, easing = SINE_EASING)
			animate(pixel_x = 11 + (32 * (src.x - O.x)), pixel_y = (32 * (src.y - O.y)) + 45, time = 3, loop = 1, easing = SINE_EASING)

			SPAWN(1 SECOND)
				if (O)
					O.set_loc( src )
					O.pixel_x = 11
					O.pixel_y = 45
					src.overlays += O
			if (src.hat)
				src.hat.set_loc( src.loc )
				src.overlays -= src.hat
				animate(src.hat, pixel_x = 13, pixel_y = 27, transform = matrix(180, MATRIX_ROTATE), time = 2, loop = 1, easing = SINE_EASING)
				animate(pixel_x = 0, pixel_y = 0, transform = null, time = 30, loop = 3, easing = SINE_EASING)
				var/obj/item/clothing/head/old_hat = src.hat
				SPAWN(0.5 SECONDS)
					if (old_hat)
						old_hat.layer = initial(old_hat.layer)

			src.hat = O

		else
			return ..()

#undef MEATHEAD_MAX_CUSTOM_UTTERANCES

/obj/item/disk/data/fixed_disk/meatland

	New()
		..()

		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "logs"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/c3help(src))

		newfolder = new /datum/computer/folder
		newfolder.name = "bin"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/terminal_program/writewizard(src))

		newfolder = new /datum/computer/folder
		newfolder.name = "doc"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/meatland/clueless (src))
		newfolder.add_file( new /datum/computer/file/record/iomoon_corrupt {name = "log_00000000";} (src))
		newfolder.add_file( new /datum/computer/file/record/meatland/solarium_ha_ha_ha (src))
		newfolder.add_file( new /datum/computer/file/record/iomoon_corrupt {name = "log_aaaaaaa";} (src))
		newfolder.add_file( new /datum/computer/file/record/meatland/technobabble_bs (src))
		newfolder.add_file( new /datum/computer/file/record/meatland/david_is_dead (src))

/obj/item/disk/data/fixed_disk/meatland_medical

	New()
		..()

		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "logs"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/c3help(src))

		newfolder = new /datum/computer/folder
		newfolder.name = "bin"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/terminal_program/writewizard(src))

		newfolder = new /datum/computer/folder
		newfolder.name = "doc"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/meatland/whiskerdeath0 (src))
		newfolder.add_file( new /datum/computer/file/record/iomoon_corrupt {name = "MEDLOG08";} (src))
		newfolder.add_file( new /datum/computer/file/record/meatland/whiskerdeath1 (src))

/obj/machinery/computer3/generic/personal/meatland
	setup_drive_type = /obj/item/disk/data/fixed_disk/meatland

/obj/machinery/computer3/generic/personal/meatland_medical
	setup_drive_type = /obj/item/disk/data/fixed_disk/meatland_medical

//Computer logs
/datum/computer/file/record/meatland

	clueless
		name = "log_20510321"

		New()
			..()
			fields = strings("meatland/meatland_records.txt","log_20510321")
			/*list("Even with the recent acquisition of Hemera",
					"technical documents and some working material,",
					"I cannot help but feel as though we aren't",
					"any closer to a functional teleportation system",
					"than we were months ago.  There is a fundamental",
					"gulf in understanding here.  They have extensively",
					"and finely shaped the telecrystals; there are",
					"detailed patterns over nearly the entire surface",
					"of the crystal, with individual lines only a few",
					"nanometers thick.  We might as well be cavemen",
					"trying to understand a microprocessor.")*/

	solarium_ha_ha_ha
		name = "log_20510324"

		New()
			..()
			fields = strings("meatland/meatland_records.txt","log_20510324")
			/*list("The patterns on the acquired telecrystal core",
						"perplex me more the more I look at them, not less.",
						"",
						"After examining a section of them, Garret made a",
						"discovery that I find unnerving: the patterns",
						"contain symbols that he has identified as cuneiform",
						"script.  I thought Hemera's mythology gimmick was",
						"Greek, why are they putting Sumerian text on this?",
						"Moreover, the symbols don't look to be aesthetic.")*/

	david_is_dead
		name = "mail_20510415"

		New()
			..()
			fields = strings("meatland/meatland_records.txt","mail_20510415")

		/*list("Dear Research Staff,",
				"It is with great sadness that we share the loss of junior lab technician David Weller.",
				"Weller activated the research pad without authorization and is assumed deceased.",
				"The reason for his actions is unknown.",
				"Weller was a valuable member of the lab family and will be missed.",
				"Funeral services will be held on the 25th in the main conference room",
				"",
				"Department Head Wilson Kay")*/

	whiskerdeath0
		name = "MEDLOG07"

		New()
			..()
			fields = strings("meatland/meatland_records.txt","MEDLOG07")
			/*list("The degradation effect has continued to",
					"affect everything sent through the pad, organic or",
					"not. I suspect that it is some kind of residual",
					"stress, a form inherent to the translocation",
					"process. This is the first time anything has",
					"been moved this way, forced directly between",
					"points with no regard for time or distance.",
					"Perhaps the universe takes a dim view of our work.")*/

	whiskerdeath1
		name = "MEDLOG09"

		New()
			..()
			fields =  strings("meatland/meatland_records.txt","MEDLOG09")
			/*list("Patient's condition has continued to worsen. Same",
				"way as the others.  Body continues to splinter.",
				"Looks like tiny hairs in random patches, but are",
				"present inside body as well, even through organs or",
				"bone. No causative agent has been discovered.  We",
				"have been reduced to providing palliative care.")*/

	technobabble_bs
		name = "system_brief"

		New()
			..()
			fields = strings("meatland/meatland_records.txt","system_brief")
			/*list("The heart of the teleportation system is",
				"the formed telecrystal. The crystal is wrapped",
				"by a set of three control coils. Below this",
				"is an array of strontium-vapor lasers.",
				"By adjusting the magnetic field produced by",
				"the coils in conjunction with the pulse rate of",
				"the laser array, a targeted translocation effect",
				"may be produced directly above the pad.",
				"The intensity, quality, and destination of the",
				"translocation is heavily dependent on the",
				"geometry of the crystal, making precision crystal",
				"fabrication paramount. Additionally, extremely",
				"minor field variations can result in destination",
				"drift of tens or hundreds of meters.")*/

//Audio logs
/obj/item/device/audio_log/meatland_00
	continuous = 0

	New()
		..()
		audiolog_messages = strings("meatland/meatland_audiologs.txt","meatland_00_audio")
		/*list("*indistinct muttering*",
				"ohhh Christ.",
				"They're like tin whiskers.  They're goddamn tin whiskers",
				"but they're in our flesh instead",
				"I thought Ted had a stroke but",
				"oh god it was this it was all this")*/

		audiolog_speakers = strings("meatland/meatland_audiologs.txt","meatland_00_speakers")
					/*list("Male voice",
						"Male voice",
						"Male voice",
						"Male voice",
						"Male voice",
						"Male voice")*/


/obj/item/device/audio_log/meatland_01

	continuous = 0
	New()
		..()
		audiolog_messages = strings("meatland/meatland_audiologs.txt","meatland_01_audio")
		/*list("*brushing noises*",
			"Who's my little Pudding Cup?  You are, yes you are",
			"*buzzing*",
			"*brushing continues*",
			"Hmm, you've got some dandruff here.  I'll pick up something for that ne-",
			"Ugh, alert light is on for the main lab again.  Hold on Pud, I'll be right back.",
			"*bumbling*")*/

		audiolog_speakers = strings("meatland/meatland_audiologs.txt","meatland_01_speakers")
						/*list("???",
						"Male voice",
						"Space bee",
						"???",
						"Male voice",
						"Male voice",
						"Space bee")*/

/obj/item/device/audio_log/meatland_02
	continuous = 0

	New()
		..()
		audiolog_messages = strings("meatland/meatland_audiologs.txt","meatland_02_audio")
					/*list("Progress log for the tenth of March, 2051",
						"Corporate has been wanting us to expand our application range to include supply transport pads and a beacon-locked base station.",
						"I've explained at length that that isn't viable.  We still don't have the full scale teleport pad working.",
						"They don't want to hear it.  So then, more teleports!  Who cares if they leave half of you behind!  Certainly not corporate!",
						"I just can't believe the-",
						"...",
						"Fuck's sake, is he wearing a telecrystal as a hat?",
						"*footsteps, airlock whoosh*",
						"*unintelligible*",
						"You are hallucinating! She does not exist!  She DOES. NOT. EXIST!",
						"*unintelligible; yelling*",
						"*airlock noises, intercom click*",
						"Security to overview room C.",
						"Christ, David.",
						"...",
						"Aw, hell.")*/

		audiolog_speakers = strings("meatland/meatland_audiologs.txt","meatland_02_speakers")
						/*list("Male voice",
								"Male voice",
								"Male voice",
								"Male voice",
								"Male voice",
								"???",
								"Male voice",
								"???",
								"Multiple voices",
								"Male voice",
								"Multiple voices",
								"???",
								"Male voice",
								"Male voice",
								"???",
								"Male voice")*/

/obj/item/device/audio_log/meatland_03
	continuous = 0

	New()
		..()
		audiolog_messages = strings("meatland/meatland_audiologs.txt","meatland_03_audio")
			/*list("I saw an angel in them.  In the crystals.  She's been talking to me.  About a lot of things.",
				"Why do you think she only speaks to you?",
				"I don't. She speaks everyone really, but I'm the only one who listens.",
				"Everyone else here is so closed...so damned closed minded.  Don't they know what's at stake?",
				"What is at stake, David?  I want to learn.",
				"Salvation!  Not that bullshit some old crank on television promises for money.  Real salvation!",
				"That's interesting, David.  When did--",
				"Everyone's trying to damn themselves, everyone, I keep trying to spread her message and nobody else wants to hear it.",
				"Sorry, what were you asking?",
				"When did this begin?  When did you start hearing these messages?",
				"When I looked into the crystal.  The one in the lab.  She spoke to me then.",
				"What are you writing?  You can't let them keep me in here!  I have to help people before it's too late!",
				"Something terrible is coming, I know that sounds dumb but something really is!  There isn't much time!  PLEASE!")*/

		audiolog_speakers = strings("meatland/meatland_audiologs.txt","meatland_03_speakers")
						/*list("David",
								"Therapist",
								"David",
								"David",
								"Therapist",
								"David",
								"Therapist",
								"David",
								"David",
								"Therapist",
								"Dvaid",
								"David",
								"David")*/

/obj/item/device/audio_log/meatland_04
	continuous = 0

	New()
		..()
		audiolog_messages = strings("meatland/meatland_audiologs.txt","meatland_04_audio")
						/*list("*thunk noise*",
								"Agh, who left this on the floor--",
								"Jesus God, that stink",
								"What the hell is that?",
								"*gagging*",
								"Oh God, I'm going to barf.",
								"Why is the power out?  What the fuck is this?",
								"*hollow moaning*",
								"Who's there? Is this some prank shit?",
								"...",
								"Hello?",
								"*loud moaning, metal buckling*",
								"*screams*",
								"...",
								"...")*/

		audiolog_speakers = strings("meatland/meatland_audiologs.txt","meatland_04_speakers")
						/*list("???",
								"Female voice",
								"Female voice",
								"Female voice",
								"Female voice",
								"Female voice",
								"Female voice",
								"???",
								"Female voice",
								"???",
								"Female Voice",
								"???",
								"Female voice",
								"???",
								"???")*/

/obj/item/device/audio_log/meatland_grody
	name = "grody doodad"
	desc = "What the hell is that?"
	icon = 'icons/misc/meatland.dmi'
	icon_state = "audiolung"
	self_destruct = 1
	continuous = 0

	New()
		..()
		audiolog_messages = strings("meatland/meatland_audiologs.txt","meatland_grody_audio")
					/*list("*wheezing*",
						"*splutch noises*",
						"kill meeee")*/

		audiolog_speakers = strings("meatland/meatland_audiologs.txt","meatland_grody_speakers")
			//list("???","???","???")

	attack_self()
		src.name = "Audio lung"
		return ..()


	Topic(href, href_list)
		if (href_list["command"] == "eject")
			boutput(usr, SPAN_ALERT("You can't get it open, it's all overgrown!"))
			return
		else
			return ..()

	explode()
		. = isturf(src.loc) ? src.loc : get_turf(src)
		playsound(., 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
		gibs(.)
		qdel(src)


/obj/item/clothing/suit/space/soviet
	name = "Lastochka-19 space suit"
	desc = "A bulky space suit used by the current Soviet space program.  This one smells like fart bologna."
	icon_state = "sovspace"
	item_state = "sov_suit"

/obj/item/clothing/head/helmet/space/soviet
	name = "cosmonaut helmet"
	desc = "Korolyov's pride."
	icon_state = "cosmonaut"
	item_state = "cosmonaut"

/obj/item/luggable_computer/cheget
	name = "important-looking briefcase"
	desc = "A lockable briefcase that looks really important.  It has insignias with cyrillic lettering on them."
	icon = 'icons/misc/meatland.dmi'
	icon_state = "cheget_closed"
	luggable_type = /obj/machinery/computer3/luggable/cheget
	var/locked = 1
	var/code = "heh"

	New()
		..()

		src.code = ""
		. = "[num2hex(rand(4096, 65535), 0)]"
		for (var/i = 1, i < 5, i++)
			switch (copytext(., i, i+1))
				if ("c","C")
					code += "v"
				if ("f","F")
					code += "g"
				else
					code += copytext(., i, i+1)

		src.code = uppertext(src.code)

	unfold()
		set src in view(1)

		if (usr.stat)
			return

		if (locked)
			boutput(usr, SPAN_ALERT("It's locked!"))
			return

		src.deploy(usr)
		return

	attack_self(mob/user as mob)
		src.add_dialog(user)
		add_fingerprint(user)
		return show_lock_panel(user)

	proc/show_lock_panel(mob/user as mob)
		var/dat = {"
<!DOCTYPE html>
<head>
<title>LOCK PANEL</title>
<style type="text/css">
	table.keypad, td.key
	{
		text-align:center;
		color:#1F1F1F;
		background-color:#7F7F7F;
		border:2px solid #1F1F1F;
		padding:10px;
		font-size:24px;
		font-weight:bold;
	}
	a
	{
		text-align:center;
		color:#1F1F1F;
		background-color:#7F7F7F;
		font-size:24px;
		font-weight:bold;
		border:2px solid #1F1F1F;
		text-decoration:none;
		display:block;
	}
</style>

</head>


<body bgcolor=#2F2F2F>
	<table border = 2 bgcolor=#7F3030 width = 150px>
		<tr><td><font face='system' size = 6 color=#FF0000 id = \"readout\">&nbsp;</font></td></tr>
	</table>
	<br>
	<table class = "keypad">
		<tr><td><a href='javascript:keypadIn(7);'>7</a></td><td><a href='javascript:keypadIn(8);'>8</a></td><td><a href='javascript:keypadIn(9);'>9</a></td></td><td><a href='javascript:keypadIn("A");'>A</a></td></tr>
		<tr><td><a href='javascript:keypadIn(4);'>4</a></td><td><a href='javascript:keypadIn(5);'>5</a></td><td><a href='javascript:keypadIn(6)'>6</a></td></td><td><a href='javascript:keypadIn("B");'>&#x0411;</a></td></tr>
		<tr><td><a href='javascript:keypadIn(1);'>1</a></td><td><a href='javascript:keypadIn(2);'>2</a></td><td><a href='javascript:keypadIn(3)'>3</a></td></td><td><a href='javascript:keypadIn("V");'>&#x0412;</a></td></tr>
		<tr><td><a href='javascript:keypadIn(0);'>0</a></td><td><a href='javascript:keypadIn("E");'>&#x0415;</a></td><td><a href='javascript:keypadIn("D");'>&#x0414;</a></td></td><td><a href='javascript:keypadIn("G");'>&#x0413;</a></td></tr>

		<tr><td colspan=2 width = 100px><a id = "enterkey" href='byond://?src=\ref[src];enter=0;'>&#x041F;&#x0423;&#x0421;&#x041A;</a></td><td colspan = 2 width = 100px><a href='javascript:keypadIn("reset");'>&#x0421;&#x0411;&#x0420;&#x041E;&#x0421;</a></td></tr>
	</table>

<script language="JavaScript">
	var currentVal = "";

	function updateReadout(t, additive)
	{
		if ((additive != 1 && additive != "1") || currentVal == "")
		{
			document.getElementById("readout").innerHTML = "&nbsp;";
			currentVal = "";
		}
		var i = 0
		while (i++ < 4 && currentVal.length < 4)
		{
			if (t.length)
			{

				switch (t.substr(0,1))
				{
					case "B":
						document.getElementById("readout").innerHTML += "&#x0411;&nbsp;";
						break;

					case "V":
						document.getElementById("readout").innerHTML += "&#x0412;&nbsp;";
						break;

					case "G":
						document.getElementById("readout").innerHTML += "&#x0413;&nbsp;";
						break;

					case "D":
						document.getElementById("readout").innerHTML += "&#x0414;&nbsp;";
						break;

					case "K":
						document.getElementById("readout").innerHTML += "&#x041A;&nbsp;";
						break;

					default:
						document.getElementById("readout").innerHTML += t.substr(0,1) + "&nbsp;";
						break;
				}
				currentVal += t.substr(0,1);
				t = t.substr(1);
			}
		}

		document.getElementById("enterkey").setAttribute("href","byond://?src=\ref[src];enter=" + currentVal + ";");
	}

	function keypadIn(num)
	{
		switch (num)
		{
			case 0:
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
				updateReadout(num.toString(), 1);
				break;

			case "A":
			case "B":
			case "V":
			case "G":
			case "D":
			case "E":
				updateReadout(num, 1);
				break;

			case "reset":
				updateReadout("", 0);
				break;
		}
	}

</script>

</body>"}

		user << browse(dat, "window=cheget;size=270x300;can_resize=0;can_minimize=0")

	Topic(href, href_list)
		..()
		if ((usr.stat || usr.restrained()) || (BOUNDS_DIST(src, usr) > 0))
			return

		if ("enter" in href_list)

			if (uppertext(href_list["enter"]) == src.code)
				usr << output("!OK!&0", "cheget.browser:updateReadout")


				if (locked)
					locked = 0
					src.icon_state = "cheget_unlocked"
					src.visible_message(SPAN_ALERT("[src]'s lock mechanism clicks unlocked."))
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 65, 1)
					if (prob(50))
						src.visible_message(SPAN_ALERT("[src] emits a happy bleep."))
						playsound(src.loc, 'sound/machines/cheget_goodbloop.ogg', 30, 1)

				else
					locked = 1
					src.icon_state = "cheget_closed"
					src.visible_message(SPAN_ALERT("[src]'s lock mechanism clunks locked."))
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 65, 1)
			else if (href_list["enter"] == "")
				if (locked)
					return
				locked = 1
				src.icon_state = "cheget_closed"

				src.visible_message(SPAN_ALERT("[src]'s lock mechanism clunks locked."))
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 65, 1)

			else
				usr << output("HET!&0", "cheget.browser:updateReadout")
				if (prob(33))
					var/any_of_them_right = 0
					for (var/i = 1, i <= 4, i++)
						if (cmptext( copytext(href_list["enter"], i,i+1), copytext(src.code, i, i+1)))
							any_of_them_right++

					src.visible_message(SPAN_ALERT("[src] emits a[(any_of_them_right > 1) ? "couple" : null] grumpy boop[(any_of_them_right > 1) ? "s" : null]."))
					playsound(src.loc, 'sound/machines/cheget_grumpbloop.ogg', 30, 1)

/obj/machinery/computer3/luggable/cheget
	name = "\improper Cheget"
	desc = "It certainly looks important.  Isn't this the Soviet version of the nuclear football?"
	icon = 'icons/misc/meatland.dmi'
	icon_state = "cheget"
	base_icon_state = "cheget"
	setup_starting_os = /datum/computer/file/terminal_program/os/cheget
	temp = ""
	setup_idscan_path = null
	setup_has_internal_disk = 0
	setup_starting_peripheral1 = /obj/item/peripheral/cheget_key
	setup_starting_peripheral2 = /obj/item/peripheral/cheget_key

/datum/computer/file/terminal_program/os/cheget
	name = "AUTH2"
	var/tmp/list/knownKeys = list()
	var/tmp/inPasswordRequestMode = 0

	initialize()
		if (..())
			return TRUE
		src.master.temp = ""
		src.master.temp_add = ""
		src.print_text("&#x041F;&#x043E;&#x0436;a&#x043B;y&#x0439;c&#x0442;a, &#x0432;c&#x0442;a&#x0432;&#x044C;&#x0442;e &#x043A;&#x043B;&#x044E;&#x0447;&#x0438; a&#x0432;&#x0442;o&#x0440;&#x0438;&#x044D;a&#x0446;&#x0438;&#x0438;.")

	input_text(text)
		if(..() || !inPasswordRequestMode)
			return

		src.print_text("&#x41D;&#x415;&#x412;&#x415;&#x420;&#x41D;&#x42B;&#x419; &#x041F;&#x410;&#x0420;&#x41E;&#x41B;&#x42C;")

	disposing()
		knownKeys = null

		..()

	receive_command(obj/source, command, datum/signal/signal)
		if((..()))
			return

		if (command == "key_auth")
			if (signal?.data["authcode"] && !(signal.data["authcode"] in src.knownKeys))
				knownKeys += signal.data["authcode"]

				if (length(knownKeys) >= 2 && !inPasswordRequestMode)
					inPasswordRequestMode = 1
					src.print_text("&#x041F;&#x410;&#x0420;&#x41E;&#x41B;&#x42C;?")


		else if (command == "key_deauth")
			if (signal?.data["authcode"] && (signal.data["authcode"] in src.knownKeys))
				knownKeys -= signal.data["authcode"]

				if (length(knownKeys) < 2)
					inPasswordRequestMode = 0

/obj/item/peripheral/cheget_key
	name = "lock card"
	desc = "A card with an electronic lock attached to it.  The kind with a keyhole.  Wonder what this is for."
	setup_has_badge = 1
	func_tag = "KEY_LOCK"
	var/obj/item/device/key/cheget/inserted_key = null

	return_status_text()
		return src.inserted_key ? "UNLOCKED" : "LOCKED"

	return_badge()
		. = list("label" = "Key","icon" = "key","contents" = src.inserted_key)

/turf/unsimulated/floor/key_floor
	var/found_thing = 0
	attack_hand(var/mob/user)
		if(!found_thing)
			found_thing = 1
			user.show_text("Huh, one of these tiles is a bit loose.  Underneath it is... a key?", "red")
			new /obj/item/device/key/cheget(src)
		else
			user.show_text("Nothing out of the ordinary.", "blue")

/obj/meatland_obelisk
	name = "Onyx Obelisk"
	desc = "\"WHO PUT BELLA IN THE WYCH ELM?\"<br>There is a small keyhole on the front."
	icon = 'icons/misc/halloween.dmi'
	icon_state = "tombstone"
	anchored = ANCHORED
	density = 1
	var/opened = 0

	attackby(obj/item/O, mob/user)
		if (istype(O, /obj/item/device/key))
			if (opened)
				boutput(user, SPAN_ALERT("It's already been used, ok."))
				return

			if (findtext(O.name, "onyx"))
				opened = 1
				user.visible_message(SPAN_ALERT("<b>[user] inserts [O] into [src]!</b>"))
				playsound(src.loc, 'sound/impact_sounds/Generic_Click_1.ogg', 60, 1)
				qdel(O)

				src.visible_message(SPAN_ALERT("Something pops out of [src]!"))
				new /obj/item/skull/crystal(get_turf(src))

			else
				boutput(user, SPAN_ALERT("It doesn't fit.  Dang."))
				return

		else if (istype(O, /obj/item/iomoon_key))
			boutput(user, SPAN_ALERT("Okay, that isn't the right answer to this puzzle either.<br>Good thinking, though!"))

		else if (istype(O, /obj/item/reagent_containers/food/snacks/pie/lime))
			boutput(user, SPAN_ALERT("You can just barely hear a hollow voice say \"ugh.\"[prob(20) ? " Phillip Farmer??" : null]"))

		else
			return ..()
/*
 *	Puzzle elements and doors
 */

/obj/machinery/door/unpowered/martian/meat
	name = "Sphincter"
	desc = "Do you really want to go through that?  Really?"
	icon = 'icons/misc/meatland.dmi'

/obj/iomoon_puzzle/meat_ganglion
	name = "ginormous ganglion"
	desc = "It's a big ol' ball of nerves.  Normally, these aren't the size of patio furniture, but.  um.  <i>future.</i>"
	icon = 'icons/misc/meatland.dmi'
	icon_state = "ganglion0"
	anchored = ANCHORED
	density = 1
	var/timer = 0 //Seconds to toggle back off after activation.  Zero to just act as a toggle.
	var/active = 0
	var/latching = 0 //Remain on indefinitely.
	var/open_mode = 0 //0 for closed->open, 1 for open->closed
	var/datum/light/light

	New()
		..()

		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.4)
		light.set_color(0.97, 0.837, 0.32)

		if (findtext(id, ";"))
			id = params2list(id)

	attack_ai(mob/user as mob)
		if (isrobot(user))
			return attack_hand(user)

	attack_hand(mob/user)
		if (user.stat || user.getStatusDuration("knockdown") || BOUNDS_DIST(user, src) > 0 || !user.can_use_hands())
			return

		user.visible_message(SPAN_ALERT("[user] presses against [src]."), SPAN_ALERT("You press against [src].  Ew."))
		return toggle()

	proc
		toggle()
			if (timer)
				if (active)
					return 1

				return src.activate()

			if (active)
				return src.deactivate()
			else
				return src.activate()

	activate()
		if (active)
			return 1

		playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
		src.icon_state = "ganglion[++active]"
		light.enable()

		if (timer)
			if (timer > 3)
				src.icon_state = "ganglion_blink_slow"
				SPAWN((timer - 3) * 10)
					src.icon_state = "ganglion_blink_fast"
					sleep(3 SECONDS)
					src.deactivate()

			else
				src.icon_state = "ganglion_blink_fast"
				SPAWN(timer * 10)
					src.deactivate()

		if (id)
			if (istype(id, /list))
				for (var/sub_id in id)
					var/obj/iomoon_puzzle/target = locate(sub_id)
					if (istype(target))
						if (src.open_mode)
							target.deactivate()
						else
							target.activate()
			else
				var/obj/iomoon_puzzle/target = locate(id)
				if (istype(target))
					if (src.open_mode)
						target.deactivate()
					else
						target.activate()

		return 0

	deactivate()
		if (!active || latching)
			return 1

		playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
		src.icon_state = "ganglion[--active]"
		light.disable()

		if (id)
			if (istype(id, /list))
				for (var/sub_id in id)
					var/obj/iomoon_puzzle/target_doodad = locate(sub_id)
					if (istype(target_doodad))
						if (src.open_mode)
							target_doodad.activate()
						else
							target_doodad.deactivate()
			else
				var/obj/iomoon_puzzle/target_doodad = locate(id)
				if (istype(target_doodad))
					if (src.open_mode)
						target_doodad.activate()
					else
						target_doodad.deactivate()

		return 0

/obj/iomoon_puzzle/ancient_robot_door/meat
	name = "enormous mandibles"
	desc = "There's no getting past these jaws when they're closed.  Ideally, one would not be between them when they close."
	icon = 'icons/misc/meatland.dmi'
	icon_state = "fangdoor1"
	density = 1
	anchored = ANCHORED
	opacity = 1

	open()
		if (opened || changing_state == 1)
			return

		opened = 1
		changing_state = 1
		active = (opened != default_state)

		FLICK("fangdoorc0",src)
		src.icon_state = "fangdoor0"
		set_density(0)
		set_opacity(0)
		src.name = "unsealed door"
		SPAWN(1.3 SECONDS)
			changing_state = 0
		return


	close()
		if (!opened || changing_state == -1)
			return

		opened = 0
		changing_state = -1
		active = (opened != default_state)

		set_density(1)
		set_opacity(1)
		FLICK("fangdoorc1",src)
		for (var/mob/living/L in src.loc)
			if (prob(10))
				boutput(L, SPAN_NOTICE("You just barely slip by the clenching teeth unharmed!"))
			else if (prob(80))
				L.visible_message(SPAN_ALERT("<b>[src] slams shut on [L]!</b>"))
				if (ishuman(L))
					L:sever_limb(pick("l_arm", "r_arm", "L_leg", "r_leg"))
				else
					random_brute_damage(L, 25, 1)
			else
				L.visible_message(SPAN_ALERT("<b>[L] is gored by [src]!</b>"), SPAN_ALERT("<b>OH SHIT</b>"))
				playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
				logTheThing(LOG_COMBAT, L, "was gibbed by [src] ([src.type]) at [log_loc(L)].")
				L.gib()

		src.icon_state = "fangdoor1"
		SPAWN(1.3 SECONDS)
			changing_state = 0
		return

/obj/iomoon_puzzle/generic_logic_element
	name = "generic puzzle logic element"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	invisibility = INVIS_ALWAYS
	var/output_ids = null //legacy
	var/inputs_required = 1
	var/input_counter = 0

	New()
		..()

		id = output_ids

	activate()
		input_counter++
		if (input_counter == inputs_required)
			if (id)
				if (istype(id, /list))
					for (var/sub_id in id)
						var/obj/iomoon_puzzle/target_doodad = locate(sub_id)
						if (istype(target_doodad))
							target_doodad.activate()
				else
					var/obj/iomoon_puzzle/target_doodad = locate(id)
					if (istype(target_doodad))
						target_doodad.activate()

	deactivate()
		input_counter = max(0, input_counter - 1)
		if (input_counter < inputs_required)
			if (id)
				if (istype(id, /list))
					for (var/sub_id in id)
						var/obj/iomoon_puzzle/target_doodad = locate(sub_id)
						if (istype(target_doodad))
							target_doodad.deactivate()
				else
					var/obj/iomoon_puzzle/target_doodad = locate(id)
					if (istype(target_doodad))
						target_doodad.deactivate()

//Meat limbs: probably not a desirable prize
/obj/item/parts/human_parts/arm/meat_mutant
	partIconModifier = "mutated"

	left
		name = "weird left arm"
		desc = "A weirdo blob of tumors and tendons in the crude form of an arm."
		icon_state = "arm_left_mutant"
		slot = "l_arm"
		side = "left"
		handlistPart = "l_hand_mutated"

	right
		name = "grody right arm"
		desc = "A weirdo blob of tumors and tendons in the crude form of an arm."
		icon_state = "arm_right_mutant"
		slot = "r_arm"
		side = "right"
		handlistPart = "r_hand_mutated"

//Gib gun.  Maybe a prize??? except for the whole "firing your internal organs as projectiles is not healthy" thing.
/obj/item/gun/gibgun
	name = "grody gizmo"
	desc = "Some kind of weirdo metal-laden meat tube.  Oh gosh, what would Freud say about this?"
	icon = 'icons/obj/items/guns/gimmick.dmi'
	icon_state = "gibgun"
	cant_self_remove = 1
	cant_other_remove = 1
	cant_drop = 1
	c_flags = null // not on belt
	var/last_shot = 0

	pickup(var/mob/user)
		if (ishuman(user))
			boutput(user, SPAN_ALERT("[src] clamps down on your arm!  Mercy sakes!"))
			src.w_class = W_CLASS_BUBSIAN
		return ..()

	dropped()
		src.w_class = initial(src.w_class)
		return ..()

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if (!istype(target, /turf) || !istype(start, /turf))
			return
		if (target == user.loc || target == loc)
			return

		if((last_shot + 15) <= world.time)
			if (user.health <= 0)
				boutput(user, SPAN_ALERT("You try to fire, but just feel woozy, bolts of pain shooting up your arm."))
				return

			last_shot = world.time

			var/turf/T = get_turf(src)
			var/obj/item/reagent_containers/food/snacks/ingredient/meatpaste/theGib = new /obj/item/reagent_containers/food/snacks/ingredient/meatpaste {throwforce = 8;name="ambiguous organ";desc = "Some kind of human organ, probably.";icon = 'icons/misc/meatland.dmi'} (T)
			theGib.icon_state = "meatproj[rand(1,3)]"
			SPAWN(1.5 SECONDS)
				if (theGib)
					theGib.throwforce = 1

			theGib.throw_at(target, 8, 2)
			random_brute_damage(user, rand(5,15))
			playsound(T, 'sound/impact_sounds/Flesh_Break_1.ogg', 40, TRUE)

			user.visible_message(SPAN_ALERT("<b>[user]</b> blasts a lump of flesh at [target]!"))
			if (prob(15))
				user.emote("scream")

/obj/fakeobject/core
	name = "reactor core"
	desc = "It looks pretty well ruined."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "meat_reactor"
	anchored = ANCHORED
	opacity = 0
	density = 0
