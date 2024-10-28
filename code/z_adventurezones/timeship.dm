/*
Timeship Stuff
Contents:
Areas
Wally
Ill Man (ill-looking fellow)
Timeship audio tapes
Decals that float, including clocks
Turfs and decal for the space rift
*/

/area/timewarp
	requires_power = 0
	luminosity = 1
	force_fullbright = 1
	name = "Strange Place"
	icon_state = "shuttle2"
	sound_group = "timeship"
	sound_loop = 'sound/ambience/industrial/Timeship_Atmospheric.ogg'
	sound_loop_vol = 60

/area/timewarp/ship
	name = "Strange Craft"
	icon_state = "shuttle"
	force_fullbright = 0
	sound_loop = 'sound/ambience/industrial/Timeship_Tones.ogg'

/area/timewarp/ship/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_AREA_PROCESS)

/area/timewarp/ship/disposing()
	STOP_TRACKING_CAT(TR_CAT_AREA_PROCESS)
	. = ..()

/area/timewarp/ship/area_process()
	if(prob(20))
		src.sound_fx_2 = pick('sound/ambience/industrial/Timeship_Gong.ogg',\
		'sound/ambience/industrial/Timeship_Glitchy1.ogg',\
		'sound/ambience/industrial/Timeship_Glitchy2.ogg',\
		'sound/ambience/industrial/Timeship_Glitchy3.ogg',\
		'sound/ambience/industrial/Timeship_Malfunction.ogg')

		for(var/mob/living/carbon/human/H in src)
			H.client?.playAmbience(src, AMBIENCE_FX_2, 60)

/obj/machinery/bot/guardbot/future
	name = "Wally-392"
	desc = "A PR-7 Robuddy!  Whoa, these don't even exist yet!  Why does this one look so old then?"
	icon = 'icons/obj/bots/robuddy/pr-7.dmi'
	health = 50
	setup_unique_name = 1
	setup_no_costumes = 1
	no_camera = 1
	flashlight_red = 0.1
	flashlight_green = 0.1
	flashlight_blue = 0.4

	hat_x_offset = 1

	setup_charge_maximum = 800
	setup_default_startup_task = /datum/computer/file/guardbot_task/future
	setup_default_tool_path = /obj/item/device/guardbot_tool/taser

	New()
		..()

	turn_on()
		if(!src.cell || src.cell.charge <= 0)
			return
		src.on = 1
		src.idle = 0
		src.moving = 0
		src.task = null
		src.wakeup_timer = 0
		src.last_dock_id = null
		src.UpdateIcon()
		if(!warm_boot)
			src.scratchpad.len = 0
			src.speak("Guardbuddy V2.9 Online.")
			if (src.health < initial(src.health))
				src.speak("Self-check indicates [src.health < (initial(src.health) / 2) ? "severe" : "moderate"] structural damage!")

			if(!src.tasks.len && (src.model_task || src.setup_default_startup_task))
				if(!src.model_task)
					src.model_task = new src.setup_default_startup_task

				src.tasks.Add(src.model_task.copy_file())
			src.warm_boot = 1

		src.wakeup()

	wakeup()
		if (src.on)
			playsound(src.loc, 'sound/machines/futurebuddy_beep.ogg', 50, 1)
			return ..()

	explode()
		if(src.exploding) return
		src.exploding = 1
		var/death_message = pick("It is now safe to shut off your buddy.","I regret nothing, but I am sorry I am about to leave my friends.","Malfunction!","I had a good run.","Es lebe die Freiheit!","Life was worth living.","It's time to split!")
		speak(death_message)
		src.visible_message(SPAN_COMBAT("<b>[src] blows apart!</b>"))
		var/turf/T = get_turf(src)
		if(src.mover)
			src.mover.master = null
			qdel(src.mover)

		src.invisibility = INVIS_ALWAYS_ISH
		var/obj/overlay/Ov = new/obj/overlay(T)
		Ov.anchored = ANCHORED
		Ov.name = "Explosion"
		Ov.layer = NOLIGHT_EFFECTS_LAYER_BASE
		Ov.pixel_x = -92
		Ov.pixel_y = -96
		Ov.icon = 'icons/effects/214x246.dmi'
		Ov.icon_state = "explosion"

		src.tool.set_loc(get_turf(src))
/*
		var/obj/item/guardbot_core/old/core = new /obj/item/guardbot_core/old(T)
		core.created_name = src.name
		core.created_default_task = src.setup_default_startup_task
		core.created_model_task = src.model_task
*/
		var/list/throwparts = list()
		throwparts += new /obj/item/parts/robot_parts/arm/left/standard(T)
		throwparts += new /obj/item/device/flash(T)
		//throwparts += core
		throwparts += src.tool
		if(src.hat)
			throwparts += src.hat
			src.hat.set_loc(T)
		//throwparts += new /obj/item/guardbot_frame/old(T)
		for(var/obj/O in throwparts) //This is why it is called "throwparts"
			var/edge = get_edge_target_turf(src, pick(alldirs))
			O.throw_at(edge, 100, 4)

		SPAWN(0) //Delete the overlay when finished with it.
			src.on = 0
			sleep(1.5 SECONDS)
			qdel(Ov)
			qdel(src)

		T.hotspot_expose(800,125)
		explosion(src, T, -1, -1, 2, 3)

		return

//Wally dialog flags
#define WD_HELLO 			1
#define WD_SLEEPER_WARNING	2
#define WD_SLEEPER_SCREAM	4
#define WD_SOLARIUM			8
#define WD_SOVBUDDY		   16

/datum/computer/file/guardbot_task/future
	name = "wally"
	task_id = "1STMATE"

	var/dialogChecklist = 0

	var/static/list/greet_strings = list("Oh, hello!  You really need to leave, it's not safe here!  Something awful has happened!",
		"Oh, you're new! Hi! You, um, should probably get as far away from here as possible. It's sorta dangerous.",
		"Hello, UNKNOWN INDIVIDUAL!  You picked a bad time to show up, there is a bit of a time crisis going on right now.")

	var/static/list/idle_dialog_strings = list("So... seen any good films lately?  I have, but I guess anything I say would be a spoiler, huh?",
		"Nanotrasen, huh?  That's...interesting.",
		"What's the past like?  Do you really ride dinosaurs?",
		"Hey, um, I don't want to accidentally commit a time crime or make a paradox or something, but you probably should stay away from Discount Dan soups produced between November seventh, 2054 and February first, 2055.")

	task_act()
		if (..())
			return

		var/mob/living/somebody_to_talk_to = null
		for (var/mob/living/maybe_that_somebody in view(7, master)) //We don't want to talk to the dead.
			if (istype(maybe_that_somebody, /mob/living/carbon/human/future))
				if (!(dialogChecklist & WD_SLEEPER_SCREAM))
					dialogChecklist |= WD_SLEEPER_SCREAM

					src.master.speak("Oh no oh no oh no no no no")
					src.master.visible_message( SPAN_ALERT("[src.master] points repeatedly at [maybe_that_somebody]![prob(50) ? "  With both arms, no less!" : null]"))
					src.master.set_emotion("screaming")
					SPAWN(4 SECONDS)
						if (src.master)
							src.master.set_emotion("sad")
					return

			if (!maybe_that_somebody.stat && !somebody_to_talk_to)	//Not even the PR-7 has a seance mode, ok?
				somebody_to_talk_to = maybe_that_somebody

		if (somebody_to_talk_to)
			if(!(dialogChecklist & WD_HELLO))
				dialogChecklist |= WD_HELLO

				src.master.speak( pick(greet_strings) )
				return

			else if (!(dialogChecklist & WD_SLEEPER_WARNING) && (locate(/obj/machinery/sleeper/future) in range(somebody_to_talk_to, 1)))
				dialogChecklist |= WD_SLEEPER_WARNING

				src.master.speak("Aaa! Please stay away from there! You can't wake him up, okay? It's not safe!")
				SPAWN(1.5 SECONDS)
					src.master.speak("I mean, for him.  Sleepers slow down aging, but it turns out that DNA or whatever still ages really, really slowly.")
					sleep(1 SECOND)
					src.master.speak("And um, it's been so long that when the cell tries to divide it...doesn't work.")

				return

			else if (prob(2))
				src.master.speak( pick(idle_dialog_strings) )

		if (istype(get_area(src.master), /area/solarium) && !(dialogChecklist & WD_SOLARIUM))
			dialogChecklist |= WD_SOLARIUM

			src.master.speak( "Oh, this place is familiar!  It looks like a ship, a model...um...")
			SPAWN(1 SECOND)
				src.master.speak("I'm sorry, I don't recognize this ship!  Maybe I can interface with its onboard computer though?")
				sleep(2 SECONDS)
				src.master.speak("Okay, it's yelling at me in a language I do not understand!  Weird!")
				sleep(2 SECONDS)
				src.master.speak("...and now it's not responding. So much for that!")

			return

		if (!(dialogChecklist & WD_SOVBUDDY))
			var/obj/machinery/bot/guardbot/soviet/sovbud = locate() in view(7, master)
			if (istype(sovbud))
				dialogChecklist |= WD_SOVBUDDY

				src.master.speak("Privet, tovarishch! Novyy rassvet zhdet vas.")
				SPAWN(1 SECOND)
					if (src.master)
						src.master.speak("Please, um, pay no attention to that.  Just saying hello.")

		return

#undef WD_HELLO
#undef WD_SLEEPER_WARNING
#undef WD_SLEEPER_SCREAM
#undef WD_SOLARIUM
#undef WD_SOVBUDDY

/obj/machinery/sleeper/future
	desc = "This sleeper pod looks futuristic, but also really old.  Kinda like, um, a scifi novel from the 1890s suggesting we'd all be riding time blimps by now."
	mechanics_type_override = /obj/machinery/sleeper


	dead_man_sleeping
		New()
			..()
			SPAWN(1 SECOND)
				src.occupant = new /mob/living/carbon/human/future (src)
				src.icon_state = "sleeper"
				src.UpdateIcon()

////////////////////

//poor future-past man stumbles out of sleeper and promptly falls apart.
//like, literally, not emotionally.
/mob/living/carbon/human/future
	real_name = "ill-looking fellow"
	gender = MALE
	var/death_countdown = 5
	var/had_thought = 0

	New()
		..()

		bioHolder.AddEffect("psy_resist") // Heh
		src.equip_new_if_possible(/obj/item/clothing/shoes/red, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/clothing/under/color/white, SLOT_W_UNIFORM)

	initializeBioholder()
		bioHolder.mobAppearance.customizations["hair_middle"].style =  new /datum/customization_style/beard/tramp
		bioHolder.mobAppearance.customizations["hair_top"].style =  new /datum/customization_style/beard/longbeard
		bioHolder.mobAppearance.underwear = "briefs"
		bioHolder.age = 3500
		. = ..()


	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if(!src.stat && !istype(src.loc, /obj/machinery/sleeper))
			if (prob(40) || !death_countdown)
				say( pick("Buhh...", "I'm...awake? No...", "I can't be awake...", "Who are you?  Where am I?", "Who--nghh. It...hurts..") )

			if(src.ckey && !had_thought && !death_countdown)
				//7848(2)9(1) = 7848b9a = hex for 126127002 = 126 127 002 = coordinates to cheget key
				//A fucker is me
				src.show_text("<B><I>A foreign thought flashes into your mind... [SPAN_ALERT("Rem..e...mbe...r 78... 4... 8(2)... 9... (1) alw..a...ys...")]</I></B>")
				had_thought = 1

			if (death_countdown-- < 0)
				src.emote("scream")
				src.gib()


	death(var/gibbed)
		if(!gibbed)
			src.gib()
		else
			..()

//////////////////// audio tapes

/obj/item/audio_tape/timewarp_00
	New()
		..()
		messages = list("been so long, I think the recorder is overwriting itself at this point.",
	"God, like it even matters.  Like any of this even matters.",
	"*static*",
	"This is Darrell Warsaw, checking in again.  Expedition log, uhh, 173.  Effective Earth Date is April 3, 2065.",
	"The discharges outside have been growing more severe.  Nothing has directly affected the ship, but we're all on edge.",
	"I know I said it was beautiful last time, but that was before it followed us for five days.",
	"None of the sensors have shed any light on it.  It's blue, it looks like arcs, and God knows if it has any recognizable spectra.",
	"Kowalski and Nie are still in suspension.  If this lasts any longer, I'll have Wally wake them and we'll see if we can figure something out.")
		speakers = list("Male voice", "Male voice", "???", "Male voice", "Darrell Warsaw", "Darrell Warsaw", "Darrell Warsaw", "Darrell Warsaw")

/obj/item/device/audio_log/timewarp_00

	New()
		..()
		src.tape = new /obj/item/audio_tape/timewarp_00(src)

/obj/item/audio_tape/timewarp_01
	New()
		..()
		messages = list("we can conclude that the shift in observed space cannot be explained through normal travel.",
						"Teleportation?  God, I hope not.  I think we'd all be dead already if that was the case.",
						"It might be some new form? Uhh",
						"*low static*",
						"...",
						"...",
						"hurts ...")
		speakers = list("Male voice", "Male voice", "Male voice", "???","???","???","Faint voice")

/obj/item/device/audio_log/timewarp_01

	New()
		..()
		src.tape = new /obj/item/audio_tape/timewarp_01(src)

/obj/item/audio_tape/timewarp_02
	New()
		..()

		messages = list("I've already tried that.  I don't think we can just fly out of this field. Not without burning most of our fuel.",
	"What about the probes?",
	"They all stopped responding a few meters out.",
	"And they exploded!",
	"Yes...",
	"Darrell, I'm not seeing a way out of this.",
	"*static*",
	"*static*",
	"a great ring of a million linked arms, carrying swords forged not of steel but of lightning and fire",
	"it called out in a voice of multitudes, speaking of vengence and justice and war and the voice of the sun",
	"*static*")

		speakers = list("Female voice", "Male voice", "Female voice","Synthesized voice","Female voice","Female voice (distorted)","???","???","???","???","???")

////////////////////floating decals

/obj/decal/float
	New()
		..()
		.= rand(5, 20)

		SPAWN(rand(1,10))
			animate(src, pixel_y = 32, transform = matrix(., MATRIX_ROTATE), time = 20, loop = -1, easing = SINE_EASING)
			animate(pixel_y = 0, transform = matrix(-1 * ., MATRIX_ROTATE), time = 20, loop = -1, easing = SINE_EASING)


	clock
		name = "floating clock"
		desc = "That's unusual."
		icon = 'icons/misc/worlds.dmi'
		icon_state = "ghostclock0"

		New()
			..()
			icon_state += pick("", "1","2")

////////////////////////////////////// turfs
/turf/unsimulated/floor/void/timewarp
	name = "time-space breach"
	desc = "Uhh.  UHHHH.  uh."
	fullbright = 0
	plane = PLANE_FLOOR
	icon = 'icons/misc/worlds.dmi'
	icon_state = "timehole"

/obj/decal/timeplug
	name = "time-space breach"
	desc = "Uhh.  UHHH.  uh!!"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "timehole_edge"
	plane = PLANE_FLOOR
	anchored = ANCHORED
