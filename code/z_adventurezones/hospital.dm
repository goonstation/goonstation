
#define SAMOSTREL_LIVE 1	//On broadway!!

/area/hospital
	name = "Ainley Staff Retreat Center"
	icon_state = "purple"
	ambient_light = rgb(0.5 * 255, 0.5 * 255, 0.5 * 255)
	sound_group = "ainley"
	sound_loop = 'sound/ambience/spooky/Hospital_Drone1.ogg'

/area/hospital/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_AREA_PROCESS)

/area/hospital/disposing()
	STOP_TRACKING_CAT(TR_CAT_AREA_PROCESS)
	. = ..()

/area/hospital/area_process()
	if(prob(20))
		src.sound_fx_2 = pick('sound/ambience/spooky/Hospital_Chords.ogg',\
		'sound/ambience/spooky/Hospital_Haunted1.ogg',\
		'sound/ambience/spooky/Hospital_Haunted2.ogg',
		'sound/ambience/spooky/Hospital_Drone3.ogg',\
		'sound/ambience/spooky/Hospital_Haunted3.ogg',\
		'sound/ambience/spooky/Hospital_Feedback.ogg',\
		'sound/ambience/spooky/Hospital_Drone2.ogg',\
		'sound/ambience/spooky/Hospital_ScaryChimes.ogg')

		for(var/mob/living/carbon/human/H in src)
			H.client?.playAmbience(src, AMBIENCE_FX_2, 50)

/area/hospital/underground
	name = "utility tunnels"
	icon_state = "green"
	sound_group = "hospital_basement"

/area/hospital/somewhere
	name = "forest"

/area/hospital/samostrel
	name = "Akademik Igor Novikov"
	icon_state = "green"
	requires_power = 0
	luminosity = 0
	force_fullbright = 0
	sound_group = "samostrel"

/area/adventure/channel
	name = "Channel"
	desc = "Better not try and change it!"
	icon_state = "purple"
	requires_power = 0
	luminosity = 1
	force_fullbright = 1

	flingy
		name = "Unstable Channel"

		Entered(atom/movable/Obj,atom/OldLoc)
			..()

			if (Obj && (!Obj.anchored || isliving(Obj)))
				Obj.throw_at(get_edge_target_turf(Obj, NORTH), 100, 1)

			return

	teleport
		name = "Extremely Unstable Channel"

		Entered(atom/movable/Obj, atom/OldLoc)
			..()

			if (Obj)
				var/turf/T = locate(Obj.x, 4, 1)
				Obj.set_loc(T)
				playsound(T, pick('sound/effects/elec_bigzap.ogg', 'sound/effects/elec_bzzz.ogg', 'sound/effects/electric_shock.ogg'), 50, 0)
				var/obj/somesparks = new /obj/effects/sparks
				somesparks.set_loc(T)
				SPAWN(2 SECONDS)
					if (somesparks) qdel(somesparks)

				Obj.throw_at(get_edge_target_turf(T, NORTH), 200, 1)

/turf/unsimulated/wall/setpieces/hospital
	name = "panel wall"
	desc = ""
	icon = 'icons/misc/hospital.dmi'
	icon_state = "panelwall"

/turf/unsimulated/wall/setpieces/hospital/window
	name = "panel window"
	desc = ""
	icon_state = "panelwindow"
	opacity = 0

/turf/unsimulated/wall/setpieces/hospital/cavern
	name = "asteroid"
	desc = ""
	icon_state = "cavern1"

/turf/unsimulated/floor/setpieces/hospital/cavern
	name = "asteroid floor"
	desc = ""
	icon = 'icons/misc/hospital.dmi'
	icon_state = "crust"

/obj/stool/bed/moveable/hospital
	name = "gurney"
	desc = "A sturdy hospital gurney."
	density = 1
	p_class = 1.5

/obj/stool/bed/moveable/hospital/halloween
	desc = "A sturdy hospital gurney.  With skeletal remains in a straightjacket tied to it.  And tooth marks on the straps.   u h h"
	security = 1
	icon = 'icons/misc/hospital.dmi'
	icon_state = "gurney"

/obj/chaser/hospital_trigger
	name = "malevolent thing trigger"
	icon = 'icons/misc/hospital.dmi'
	icon_state = "specter"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	density = 0

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(!maniac_active)
			if(isliving(AM))
				if(AM:client)
					if(prob(75))
						maniac_active |= 2
						SPAWN(1 MINUTE) maniac_active &= ~2
						SPAWN(rand(10,30))
							var/obj/chaser/hospital/C = new /obj/chaser/hospital(src.loc)
							C.target = AM


/obj/chaser/hospital
	name = "? ? ?"
	icon = 'icons/misc/hospital.dmi'
	icon_state = "specter"
	desc = "&#9617;????&#9617;&#9617;&#9617;&#9617;"
	density = 1
	anchored = ANCHORED
	var/targeting = 0


	New()
		..()
		SPAWN(1 DECI SECOND)
			process()

	proximity_act()
		..()
		if(prob(40))
			src.visible_message("<span class='alert'><B>[src] passes its arm through [target]!</B></span>")
			//playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
			target.change_eye_blurry(10)
			boutput(target, "<span><B>no no no no no no no no no no no no non&#9617;NO&#9617;NNnNNO</B></span>")
			if (LANDMARK_SAMOSTREL_WARP in landmarks)
				var/target_original_loc = target.loc
				target.setStatusMin("paralysis", 10 SECONDS)
				do_teleport(target, pick_landmark(LANDMARK_SAMOSTREL_WARP), 0, 0)

				if (ishuman(target))
					var/atom/movable/overlay/animation = new(target_original_loc)
					animation.icon_state = "blank"
					animation.icon = 'icons/mob/mob.dmi'
					animation.master = target_original_loc
					flick("disintegrated", animation)

					if (prob(20))
						make_cleanable(/obj/decal/cleanable/ash,target_original_loc)

				else
					gibs(target_original_loc)

			else
				target.vaporize(,1)

			maniac_active &= ~2
			qdel(src)

	process()
		if(!targeting)
			targeting = 1
			//target<< 'sound/misc/chefsong_start.ogg'
			SPAWN(8 SECONDS)
				playsound(target, 'sound/ambience/loop/Static_Horror_Loop.ogg', 100)
				sleep(rand(100,400))
				if(target)
					playsound(target, 'sound/ambience/loop/Static_Horror_Loop_End.ogg', 100)
				qdel(src)
			walk_towards(src, src.target, 3)

		..()

/obj/gurney_trap
	icon = 'icons/misc/mark.dmi'
	icon_state = "x4"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	density = 0
	var/ready = 1

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(ready && ismob(AM) && isliving(AM))
			if(AM:client)
				ready = 0
				//Some kinda better noise could go here ???
				playsound(AM.loc, 'sound/effects/ghost.ogg', 50, 1)
				var/turf/spawnloc = src.loc
				var/turf/tempTurf
				var/step_over_counter = 8
				while (step_over_counter--)
					tempTurf = get_step(spawnloc, EAST)
					if (!isturf(tempTurf) || tempTurf.density)
						break

					spawnloc = tempTurf

				var/obj/stool/bed/gurney = new /obj/stool/bed/moveable/hospital/halloween (spawnloc)
				playsound(src, 'sound/machines/squeaky_rolling.ogg', 40, 0) //Maybe a squeaky wheel metal noise??

				gurney.throw_at(get_edge_target_turf(src, WEST), 20, 1)

/obj/item/reagent_containers/food/drinks/bottle/hospital
	name = "Ham Brandy"
	desc = "Uh.   Uhh"
	//icon = 'icons/obj/foodNdrink/bottle.dmi'
	icon_state = "bottle-spicedrum"
	bottle_style = "bottle-spicedrum"
	fluid_style = "spicedrum"
	label = "spicedrum"//"brandy"
	heal_amt = 1
	g_amt = 60
	initial_volume = 250

/*	New()
		..()
		reagents.add_reagent("porktonium", 30)
		reagents.add_reagent("ethanol", 30)
*/
/obj/item/storage/secure/ssafe/hospital
	configure_mode = 0
	code = "5555"

	New()
		..()

		new /obj/item/reagent_containers/food/drinks/bottle/hospital (src)
		new /obj/item/device/audio_log/hospital_01 (src)

/obj/item/device/audio_log/hospital_01

	New()
		..()
		src.tape = new /obj/item/audio_tape/hospital_01(src)

/obj/item/audio_tape/hospital_01
	New()
		..()
		speakers = list("Female voice","Male voice","Female voice","Male voice","Female voice", "???", "Male voice", "Female voice", "Female voice", "Male voice", "Male voice", "Male voice", "Female voice", "Male voice", "Male voice")
		messages = list("Who the hell do you think you are?",

"Excuse me?",

"I know what you're doing to the patients.",

"And what, exactly, is it that I am doing?",

"Don't play dumb!  You are testing drugs on them!  Give me just one reason not to report you to Oakland.",

"...",
"Well, for one, he already knows.",

"He....what?",
"No.  Wayne Oakland is a professional.  And a good man.  He wouldn't violate the trust-",

"Perhaps you do not know him as well as you think.",
"Did you know that his wife is dying of a rare cancer?  Did you know that FAAE may be instrumental in finding a cure?",
"And even if it isn't, it is still what is paying for treatment.  And your salary.",

"That doesn't make this right.",

"The company disagrees.",
"As they control all transportation and communication lines here, I would advise against doing anything...rash.")

/obj/item/device/audio_log/hospital_02

	New()
		..()
		src.tape = new /obj/item/audio_tape/hospital_02(src)

/obj/item/audio_tape/hospital_02
	New()
		..()
		speakers = list("Male voice", "Male voice", "Male voice", "Distant voice", "Male voice", "Distant voice (Sir ?)", "Male Voice", "Distant voice that isn't really distant but relative to a really little, bad microphone it is", "Male voice", "Distant voice", "Male voice", "Male voice", "Male voice", "Male voice")
		messages = list("*panicked breaths*",
		"...ffuck.   ffffuckk.",
		"Sir!  No, no, most systems are still down.",
		"...",
		"Whatever it was, it crippled reactor two, we were forced to SCRAM it.  Reactor one was still down for service--",
		"...",
		"No, I don't know how long until we can get either of them online.  We've also had to shed as many non-critical loads as possible--",
		"...",
		"I understand, but...I'll report as soon as anything develops.  Thank you sir.",
		"...",
		"Jesus christ.  What an ass...hole...",
		"aw fuck, you're kidding me.",
		"Did I record over my goddamn mixtape?",
		"Holy sht, fuck these stupid fucking tape players, goddamn, the record button is supposed to be harder to press than play")


/obj/item/device/audio_log/hospital_03
	desc = "A portable audio tape recorder.  This one looks pretty beat up, like somebody tried to scratch the tape door open.  Like a lion man or something.  (Note:  lion men do not exist)"

	New()
		..()
		src.tape = new /obj/item/audio_tape/hospital_03(src)

/obj/item/audio_tape/hospital_03
	New()
		..()
		speakers = list("???"  )
		messages = list("*static*")

/obj/item/device/audio_log/hospital_04

	New()
		..()
		src.tape = new /obj/item/audio_tape/hospital_04(src)

/obj/item/audio_tape/hospital_04
	New()
		..()
		src.speakers = list("Male voice","Different male voice", "Myron Roberts", "Myron Roberts",
		"Myron Roberts", "Myron Roberts", "Myron Roberts", "Myron Roberts", "???","Tape cut",
		"Myron Roberts", "Jerry", "Myron Roberts", "Myron Roberts, loudly whispering",
		"Jerry", "Myron Roberts, loudly whispering", "?????", "Myron Roberts", "Myron Roberts", "Jerry", "Jerry", "?????", "???")
		src.messages = list("Welcome, horror fans to GHOST WATCH, with your host, Myron Roberts!",
		"It's not really a ghost \"watch\" if it's just audio, now is it?",

		"...I told you, Jerry, it's for my cassette magazine.",
		"It's not my fault they don't have any video tapes here....",
		"Today, we are seeking out the AINLEY PHANTOM, the cruel spirit haunting the halls of the Ainley Staff Retreat Center!",
		"As the legend goes, back during the construction of the asylum, when it was still going to be a military base, a contractor was DRIVEN MAD by the strange voices in the void!",
		"He then killed everyone else there before committing suicide, and that is the real reason the US government ceased construction and sold the site to Nanotrasen.",
		"Don't believe the line that they just wanted to focus resources on the other site!",
		"...",
		"*click*",
		"It's only a matter of time until the phantom reveals itself!  This is its hour!",
		"You said that an hour ago.  Don't you have work to do?",
		"Finishing won't take long, jeez, just give a little longer and we're bound to--",
		"Do you see that?  I think it's the phantom!  Down the hall!",
		"It's probably just a patient going to take a leak. Christ, you're going to scare the guy.",
		"SSH, Jerry, its--",
		"*Horrible static*",
		"Jesus fuck, did the recorder break, what the hell",
		"Jerry?",

		"That",
		"That isn't a patient",
		"*Horrible static*",
		"*tape hiss*")

/obj/storage/crate/freezer/hospital
	var/keySpawned = 0

	open(entanglelogic, mob/user)
		if (!keySpawned)
			var/obj/item/device/key/hospital/theKey = new (src)
			keySpawned = 1
			var/image/O = image(icon = 'icons/misc/aprilfools.dmi', loc = theKey, icon_state = "key", layer = 20)
			user << O


		..()

/obj/trigger/spooky_emote
	var/last_emote_time = 0
	on_trigger(var/mob/living/somebody)
		if (!istype(somebody))
			return

		if (last_emote_time && (last_emote_time + 300 > world.time))
			return

		if (prob(5))
			var/list/stuff_around = list()
			for (var/obj/a_thing in view(somebody))
				if (!a_thing.name)
					continue
				stuff_around += a_thing

			if (!stuff_around.len)
				return

			boutput(somebody, "<b>[pick(stuff_around)]</b> [pick("whimpers!", "whispers...","cries!","gently sings.", "stares.","shrieks!","shakes.","shudders.","laughs.","mutters.")]")

			last_emote_time = world.time


/turf/unsimulated/floor/void/channel
	name = "wormhole distortion"
	desc = "It's a breach in time and space.  Like the inside of the Channel (the wormhole).  Actually it's probably exactly that."
	fullbright = 0
	icon = 'icons/misc/worlds.dmi'
	icon_state = "timehole"
	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000
	pathable = 0
	mat_changename = 0
	mat_changedesc = 0


/obj/machinery/bot/guardbot/soviet
	name = "Evgeny-12"
	desc = "A &#x411;&#x420;-86 (&#x411;&#x44b;&#x442;&#x43e;&#x432;&#x43e;&#x439; &#x420;&#x43e&#x431;&#x43e;&#x442;-86), one of the latest in a series of robuddy clones produced in the Eastern Bloc.  They copied the general frame of the PR-3 and never really changed from that, I guess."
	icon = 'icons/misc/hospital.dmi'
	setup_unique_name = 1
	setup_no_costumes = 1
	no_camera = 1
	setup_charge_maximum = 800
	setup_default_tool_path = /obj/item/device/guardbot_tool/flash
	hat_x_offset = 2
	hat_y_offset = 10
	setup_default_startup_task = /datum/computer/file/guardbot_task/soviet

	beacon_freq = 1440
	control_freq = FREQ_AINLEY_BUDDY

	New()
		..()
#ifndef SAMOSTREL_LIVE
		del(src)
#endif
		SPAWN(1 SECOND)
			if (src.botcard)
				src.botcard.access += FREQ_AINLEY_BUDDY

	speak(var/message)
		return ..("<font face=Consolas>[russify( uppertext(message) )]</font>")

	turn_on()
		if(!src.cell || src.cell.charge <= 0)
			return
		src.on = 1
		src.idle = 0
		src.moving = 0
		src.task = null
		src.wakeup_timer = 0
		src.last_dock_id = null
		icon_needs_update = 1
		if(!warm_boot)
			src.scratchpad.len = 0
			src.speak("Bytovoj Robot v6 aktivirovan.")
			if (src.health < initial(src.health))
				src.speak("Obnaruzhena oshibka, [src.health < (initial(src.health) / 2) ? "Tyazhelyye" : "Umerennyye"] travmy nashli!")

			if(!src.tasks.len && (src.model_task || src.setup_default_startup_task))
				if(!src.model_task)
					src.model_task = new src.setup_default_startup_task

				src.tasks.Add(src.model_task.copy_file())
			src.warm_boot = 1
		src.wakeup()

	explode()
		if(src.exploding) return
		src.exploding = 1
		//some of the death lines are just transliterated normal death lines, because parts of the soviet buddy rom were just copied from the original buds wholesale.
		var/death_message = pick("A muzhiki-to, muzhiki, kak umirayut!","Malfunction!","Neispravnost'!","I had a good run.")
		speak(death_message)
		src.visible_message("<span class='combat'><b>[src] blows apart!</b></span>")
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

		var/list/throwparts = list()
		throwparts += new /obj/item/parts/robot_parts/arm/left(T)
		throwparts += new /obj/item/device/flash(T)
		//throwparts += core
		throwparts += src.tool
		if(src.hat)
			throwparts += src.hat
			src.hat.set_loc(T)
		for(var/obj/O in throwparts)
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


#define SB_SAW_BUD		1
#define SB_SOLARIUM		2
#define SB_FAKEBEE		4
#define SB_CHEGET		8

/datum/computer/file/guardbot_task/soviet
	name = "evgeny"
	task_id = "COMRADE"
	handle_beacons = 1
	var/static/list/idle_dialog = list("Ya ne znayu vas.", "Eto mesto ne yavlyaetsya bezopasnym.", "Pozhalujsta, bud' ostorozhen.","Ya lyublyu yabloki.","Ya pytalsya im pomoch', no net nikakoj yedy.  Ya proshu proshcheniya.")
	var/tmp/dialogChecklist = 0
	var/tmp/last_idle_dialog = 0

	var/tmp/new_destination		// pending new destination (waiting for beacon response)
	var/tmp/destination			// destination description tag
	var/tmp/next_destination	// the next destination in the patrol route
	var/tmp/nearest_beacon			// the nearest beacon's tag
	var/tmp/turf/nearest_beacon_loc	// the nearest beacon's location
	var/tmp/awaiting_beacon = 0
	var/tmp/patrol_delay = 5

	task_act()
		if (..())
			return

		var/mob/living/somebody_to_talk_to = null
		for (var/mob/living/maybe_that_somebody in view(7, master)) //We don't want to talk to the dead.

			if (!maybe_that_somebody.stat)
				somebody_to_talk_to = maybe_that_somebody
				break

		if (somebody_to_talk_to)
			var/talk_prob = (world.time - last_idle_dialog) / 20
			if (prob(talk_prob))
				src.master.speak( pick(idle_dialog) )
				last_idle_dialog = world.time
				return

			if (istype(get_area(src.master), /area/solarium) && !(dialogChecklist & SB_SOLARIUM))
				dialogChecklist |= SB_SOLARIUM

				src.master.speak( "Pochemu ty vernul menya k etomu mestu?")

				return

			if (!(dialogChecklist & SB_SAW_BUD))
				for (var/obj/machinery/bot/guardbot/aBuddy in view(7,master))
					if (aBuddy != src.master)
						src.master.visible_message("<b>[master]</b> waves at [aBuddy].")
						dialogChecklist |= SB_SAW_BUD
						break

			else if (!(dialogChecklist & SB_FAKEBEE))
				var/obj/critter/fake_bee/theFake = locate() in view(7, master)
				if (istype(theFake))
					dialogChecklist |= SB_FAKEBEE

					src.master.speak("Smotrite, kosmos pchela! Etot blagorodnyj rabotnik yavlyaetsya rezul'tatom mnogoletnikh issledovanij.")

			else if (!(dialogChecklist & SB_CHEGET))
				var/obj/machinery/computer3/luggable/cheget/cheget = locate() in view(7, master)
				if (istype(cheget))
					dialogChecklist |= SB_CHEGET

					src.master.visible_message("<b>[master]</b> repeatedly points at [cheget]!  They look rather concerned!")

			if(patrol_delay)
				patrol_delay--
				return

			if(master.moving)
				return

			find_patrol_target()


		return

	proc/find_patrol_target()
		if(awaiting_beacon)			// awaiting beacon response
			awaiting_beacon--
			if(awaiting_beacon <= 0)
				find_nearest_beacon()
			return

		if(next_destination)
			set_destination(next_destination)
			if(!master.moving && target && (target != master.loc))
				master.navigate_to(target)
			return
		else
			find_nearest_beacon()
		return

	proc/find_nearest_beacon()
		nearest_beacon = null
		new_destination = "__nearest__"
		master.post_find_beacon("patrol")
		awaiting_beacon = 5
		SPAWN(1 SECOND)
			if(!master || !master.on || master.stunned || master.idle)
				return
			if(master.task != src)
				return
			awaiting_beacon = 0
			if(nearest_beacon && !master.moving)
				master.navigate_to(nearest_beacon_loc)
			else
				patrol_delay = 8
				target = null
				return

	proc/set_destination(var/new_dest)
		new_destination = new_dest
		master.post_find_beacon(new_dest || "patrol")
		awaiting_beacon = 5

	receive_signal(datum/signal/signal)
		if(..())
			return

		var/recv = signal.data["beacon"]
		var/valid = signal.data["patrol"]
		if(!awaiting_beacon || !recv || !valid || patrol_delay)
			return

		if(recv == new_destination)	// if the recvd beacon location matches the set destination
									// then we will navigate there
			destination = new_destination
			target = signal.source.loc
			next_destination = signal.data["next_patrol"]
			awaiting_beacon = 0
			patrol_delay = rand(3,5) //So a patrol group doesn't bunch up on a single tile.

		// if looking for nearest beacon
		else if(new_destination == "__nearest__")
			var/dist = GET_DIST(master,signal.source.loc)
			if(nearest_beacon)

				// note we ignore the beacon we are located at
				if(dist>1 && dist<GET_DIST(master,nearest_beacon_loc))
					nearest_beacon = recv
					nearest_beacon_loc = signal.source.loc
					next_destination = signal.data["next_patrol"]
					target = signal.source.loc
					destination = recv
					awaiting_beacon = 0
					patrol_delay = 5
					return
				else
					return
			else if(dist > 1)
				nearest_beacon = recv
				nearest_beacon_loc = signal.source.loc
				next_destination = signal.data["next_patrol"]
				target = signal.source.loc
				destination = recv
				awaiting_beacon = 0
				patrol_delay = 5
		return

#undef SB_SAW_BUD
#undef SB_SOLARIUM
#undef SB_FAKEBEE
#undef SB_CHEGET
