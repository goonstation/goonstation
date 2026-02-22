////////// cogwerks - stuff for the precursor ruins and some other various solarium-related puzzles ///////
///////////////////////////////////////////////////////////////////////////////////////////////////////////
/////// contents: - THERE IS A LOT MORE THAN JUST THIS
/////// --------
/////// horrible saxophone thing
/////// orb-teleporter
/////// sound-reactive doors
/////// sound-reactive artifacts
/////// creepy sound triggers

////////////////////////////////
///////////////////////////////////////putting ice moon stuff in here also

/////////////////// ice moon, hell, and precursor ruins areas

/area/upper_arctic
	filler_turf = "/turf/unsimulated/floor/arctic/snow"
	sound_environment = 8
	skip_sims = 1
	sims_score = 30
	sound_group = "ice_moon"
	area_parallax_render_source_group = /datum/parallax_render_source_group/area/ice_moon
	occlude_foreground_parallax_layers = TRUE

/area/upper_arctic/pod1
	name = "Outpost Theta Pod One Upper Level"
	icon_state = "green"
	sound_environment = 3
	skip_sims = 1
	sims_score = 30

/area/lower_arctic/pod1
	name = "Outpost Theta Pod One Lower Level"
	icon_state = "green"
	sound_environment = 3
	skip_sims = 1
	sims_score = 30
	sound_group = "arctic_caves"

/area/upper_arctic/pod2
	name = "Outpost Theta Pod Two"
	icon_state = "purple"
	sound_environment = 2
	skip_sims = 1
	sims_score = 30

/area/upper_arctic/hall
	name = "Outpost Theta Connecting Hall"
	icon_state = "yellow"
	sound_environment = 12
	sound_environment = 2
	skip_sims = 1
	sims_score = 30

/area/upper_arctic/comms
	name = "Communications Hut"
	icon_state = "storage"
	sound_environment = 2
	sound_environment = 2
	skip_sims = 1
	sims_score = 30

/area/upper_arctic/mining
	name = "Glacier Access Upper Level"
	icon_state = "dk_yellow"
	sound_environment = 2
	sound_environment = 2
	skip_sims = 1
	sims_score = 30

/area/lower_arctic/mining
	name = "Glacier Access Lower Level"
	icon_state = "dk_yellow"
	sound_environment = 2
	sound_environment = 2
	skip_sims = 1
	sims_score = 30

/area/upper_arctic/exterior
	sound_environment = 15
	skip_sims = 1
	sims_score = 30
	occlude_foreground_parallax_layers = FALSE

/area/upper_arctic/exterior/surface
	name = "Ice Moon Surface"
	icon_state = "purple"
	filler_turf = "/turf/unsimulated/floor/arctic/abyss"
	skip_sims = 1
	sims_score = 30

/area/upper_arctic/exterior/abyss
	name = "Ice Moon Abyss"
	icon_state = "dk_yellow"
	filler_turf = "/turf/unsimulated/floor/arctic/snow"
	skip_sims = 1
	sims_score = 30

/area/lower_arctic
	icon_state = "dk_yellow"
	sound_group = "ice_moon"

/area/lower_arctic/lower
	name = "Glacial Abyss"
	icon_state = "purple"
	filler_turf = "/turf/unsimulated/floor/arctic/snow/ice"
	sound_environment = 8
	skip_sims = 1
	sims_score = 30

/area/precursor // stole this code from the void definition
	name = "Peculiar Structure"
	icon_state = "dk_yellow"
	filler_turf = "/turf/unsimulated/floor/setpieces/bluefloor"
	sound_environment = 5
	skip_sims = 1
	sims_score = 30
	sound_group = "precursor"  //Differs from the caves it's in, for a mysterious sound-blocking effect.
	sound_loop = 'sound/ambience/industrial/Precursor_Drone1.ogg'

/area/precursor/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_AREA_PROCESS)

/area/precursor/disposing()
	STOP_TRACKING_CAT(TR_CAT_AREA_PROCESS)
	. = ..()

/area/precursor/area_process()
	if(prob(20))
		src.sound_fx_2 = pick('sound/ambience/industrial/Precursor_Drone2.ogg',\
			'sound/ambience/industrial/Precursor_Choir.ogg',\
			'sound/ambience/industrial/Precursor_Drone3.ogg',\
			'sound/ambience/industrial/Precursor_Bells.ogg')

		for(var/mob/living/carbon/human/H in src)
			H.client?.playAmbience(src, AMBIENCE_FX_2, 60)

/area/precursor/pit
	name = "Ominous Pit"
	icon_state = "purple"
	filler_turf = "/turf/unsimulated/floor/setpieces/bluefloor/pit" // this might fuck something up but it might also be hilarious
	sound_environment = 24
	sound_group = "ominouspit"
	skip_sims = 1
	sims_score = 300

////////////////////// cogwerks - HELL

/area/hell
	name = "????"
	icon_state = "security"
	filler_turf = "/turf/unsimulated/floor/setpieces/bloodfloor"
	sound_environment = 25
	skip_sims = 1
	sims_score = 0


/obj/item/hell_sax
	name = "curious instrument"
	desc = "It appears to be a musical instrument of some sort."
	interesting = "Scans detect: COBRYL | IRIDIUM *** UNUSUAL RESONANT PROPERTIES"
	icon = 'icons/obj/artifacts/artifactsitem.dmi'
	icon_state = "precursor-1" // temp
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "precursor" // temp
	w_class = W_CLASS_NORMAL
	force = 1
	throwforce = 5
	var/spam_flag = 0
	var/pitch = 0

/////////////////////////////////////////////////////////////

/obj/item/hell_sax/attack_self(mob/user as mob)
	if (spam_flag == 0)
		spam_flag = 1

		var/usernum = round(input("Select a note to play: 0-12?") as null|num)
		if (isnull(usernum))
			return
		if(usernum < 0) usernum = 0
		if(usernum > 12) usernum = 12
		if(!usernum) usernum = 0
		pitch = usernum

		if(!(src in user.contents)) // did they drop it while the input was up
			spam_flag = 0
			return

		user.visible_message(SPAN_ALERT("<B>[user]</B> blasts out [pick("a grody", "a horrifying", "an eldritch","a hideous","a jazzy","a funky","a terrifying","an awesome","a deathly")] note on [src]!"))
		var/horn_note = 'sound/musical_instruments/WeirdHorn_0.ogg'

		switch(pitch) // heh
			if(0)
				horn_note = 'sound/musical_instruments/WeirdHorn_0.ogg'
			if(1)
				horn_note = 'sound/musical_instruments/WeirdHorn_1.ogg'
			if(2)
				horn_note = 'sound/musical_instruments/WeirdHorn_2.ogg'
			if(3)
				horn_note = 'sound/musical_instruments/WeirdHorn_3.ogg'
			if(4)
				horn_note = 'sound/musical_instruments/WeirdHorn_4.ogg'
			if(5)
				horn_note = 'sound/musical_instruments/WeirdHorn_5.ogg'
			if(6)
				horn_note = 'sound/musical_instruments/WeirdHorn_6.ogg'
			if(7)
				horn_note = 'sound/musical_instruments/WeirdHorn_7.ogg'
			if(8)
				horn_note = 'sound/musical_instruments/WeirdHorn_8.ogg'
			if(9)
				horn_note = 'sound/musical_instruments/WeirdHorn_9.ogg'
			if(10)
				horn_note = 'sound/musical_instruments/WeirdHorn_10.ogg'
			if(11)
				horn_note = 'sound/musical_instruments/WeirdHorn_11.ogg'
			if(12)
				horn_note = 'sound/musical_instruments/WeirdHorn_12.ogg'

		playsound(src, horn_note, 50, FALSE)
		for(var/atom/A in range(user, 5))
			if(istype(A, /mob/living/critter/small_animal/dog/george))
				var/mob/living/critter/small_animal/dog/george/G = A
				if(prob(60))
					G.howl()
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				H.emote(pick("shiver","shudder"))
				H.change_misstep_chance(5)
				shake_camera(H, 25, 16)
			if(istype(A, /obj/precursor_puzzle/glowing_door))
				var/obj/precursor_puzzle/glowing_door/D = A
				if(src.pitch == D.pitch)
					D.toggle()
			if(istype(A, /obj/precursor_puzzle/machine))
				var/obj/precursor_puzzle/machine/M = A
				if(src.pitch in M.pitches)
					if(M.active)
						M.deactivate()
					if(!M.active)
						M.activate()

		src.add_fingerprint(user)
		SPAWN(6 SECONDS)
			spam_flag = 0
	return


// pedestal for STUFF ///


/obj/rack/precursor
	name = "cold pedestal"
	desc = "It holds stuff. And things."
	icon = 'icons/obj/artifacts/artifacts.dmi'
	icon_state = "precursor-1"
	var/id = 1

	ex_act(severity)
		return

	attackby(obj/item/W, mob/user)
	/*	if (istype(W,/obj/item/skull)) // placeholder
			playsound(src.loc, 'sound/machines/ArtifactPre1.ogg', 50, 1)
			src.visible_message(SPAN_NOTICE("<b>Something activates inside [src]!</b>"))

			if (id)
				if (istype(id, /list))
					for (var/sub_id in id)
						var/obj/precursor_puzzle/glowing_door/target_door = locate(sub_id)
						if (istype(target_door))
							target_door.toggle()
				else
					var/obj/iomoon_puzzle/ancient_robot_door/target_door = locate(id)
					if (istype(target_door))
						target_door.toggle()

			if(!src.overlays.len)
				src.overlays += icon('icons/obj/artifacts/artifacts.dmi',"precursor-1fx")*/
		if (isrobot(user)) return
		user.drop_item()
		if(W?.loc)	W.set_loc(src.loc)
		return

/obj/item/chilly_orb // borb
	name = "chilly orb"
	desc = "Neat."
	icon = 'icons/obj/artifacts/puzzles.dmi'
	icon_state = "orb"
	interesting = "Scans detect: COBRYL | IRIDIUM | BOSE-EINSTEIN CONDENSATE | RHYDBERG MATTER"
	var/id = "ENTRY" // default

/obj/precursor_puzzle/orb_stand
	name = "cold device"
	icon = 'icons/obj/artifacts/puzzles.dmi'
	icon_state = "orb_holder"
	desc = "It seems to be missing something."
	interesting = "Scans detect: COBRYL | IRIDIUM | BOSE-EINSTEIN CONDENSATE | RHYDBERG MATTER"
	density = 1
	anchored = ANCHORED
	var/id = 1
	var/target_id = 1
	var/assembled = 0
	var/ready = 0

	New()
		..()
		if(assembled)
			src.icon_state = "orb_activated"
			src.desc = "Whatever it is, it seems to be active."
			src.ready = 1 // just in case, i guess
		else
			src.icon_state = "orb_holder"
			src.desc = "It seems to be missing something."
			src.ready = 0 // precautionary

		if (!id)
			id = "generic"

		src.tag = "orb_stand_[id]"

	attack_hand(mob/user)
		if (user.stat || user.getStatusDuration("knockdown") || BOUNDS_DIST(user, src) > 0)
			return

		if (!src.assembled)
			boutput(user, SPAN_NOTICE("[src] is missing something."))
			return

		if (!src.ready)
			boutput(user, SPAN_NOTICE("[src] isn't ready yet."))
			return

		var/obj/precursor_puzzle/orb_stand/other = locate("orb_stand_[target_id]")
		if (!istype(other))
			return

		SPAWN(1 DECI SECOND)
			src.ready = 0 // disable momentarily to prevent spamming
			user.visible_message(SPAN_ALERT("<b>[user] is blasted away somewhere by [src]! Holy shit!</b>"))
			var/otherside = get_turf(other)
			user.set_loc(otherside)
			explosion(src,src.loc,-1,-1,1,2)
			playsound(src.loc, "explosion", 60, 1)
			explosion(src,otherside,-1,-1,1,2)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H:update_burning(5) // this isn't a safe way to travel at all!!!
			sleep(5 SECONDS)
			src.ready = 1

	attackby(obj/item/W, mob/user)
		if(src.ready || src.assembled)
			..()
			return

		if(istype(W, /obj/item/chilly_orb))
			var/obj/item/chilly_orb/O = W
			if(O.id == src.id)
				boutput(user, SPAN_NOTICE("<b>[O] attaches neatly to [src]. Oh dear."))
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 60, 1)
				user.drop_item(O)
				O.set_loc(src)
				src.icon_state = "orb_activated"
				src.assembled = 1
				sleep(0.5 SECONDS)
				src.visible_message(SPAN_NOTICE("<b>[src] makes a strange noise!</b>"))
				playsound(src.loc, 'sound/machines/ArtifactPre1.ogg', 60, 1)
				src.ready = 1
				return
			else
				boutput(user, SPAN_NOTICE("<b>[src] don't seem to quite fit together with [O]."))

		else if(istype(W, /obj/item/basketball) && !src.assembled) // sailor dave thinks the bball is the orb, this will really fuck with his day
			user.visible_message(SPAN_NOTICE("<b>[user] slams [W] down onto [src]'s central spike.</b>"))
			sleep(0.1 SECONDS)
			user.visible_message(SPAN_ALERT("<b>[W] violently pops! Way to go, jerk!"))
			user.drop_item(W)
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 75, 1)
			playsound(src.loc, 'sound/machines/hiss.ogg', 75, 1)
			explosion(src, src.loc, -1,-1,1,1)
			user:emote("scream")
			qdel(W)


		else
			..()
			return

/obj/precursor_puzzle/glowing_door
	name = "glowing edifice"
	desc = "You can faintly make out a pattern of fissures and glowing seams along the surface."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "bluedoor_1"
	density = 1
	anchored = ANCHORED
	opacity = 1
	var/active = 0
	var/opened = 0
	var/changing_state = 0
	var/default_state = 0 //0: closed, 1: open
	var/pitch = 0

	New()
		..()
		SPAWN(0.5 SECONDS)
			src.default_state = src.opened
			active = 0
			pitch = rand(0,12)

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/hell_sax) && !src.opened)
			..()
			user.visible_message(SPAN_NOTICE("<B>[src] [pick("rings", "dings", "chimes","vibrates","oscillates")] [pick("faintly", "softly", "loudly", "weirdly", "scarily", "eerily")].</B>"))
			var/door_note = 'sound/musical_instruments/WeirdChime_0.ogg'

			switch(src.pitch) // heh
				if(0)
					door_note = 'sound/musical_instruments/WeirdChime_0.ogg'
				if(1)
					door_note = 'sound/musical_instruments/WeirdChime_1.ogg'
				if(2)
					door_note = 'sound/musical_instruments/WeirdChime_2.ogg'
				if(3)
					door_note = 'sound/musical_instruments/WeirdChime_3.ogg'
				if(4)
					door_note = 'sound/musical_instruments/WeirdChime_4.ogg'
				if(5)
					door_note = 'sound/musical_instruments/WeirdChime_5.ogg'
				if(6)
					door_note = 'sound/musical_instruments/WeirdChime_6.ogg'
				if(7)
					door_note = 'sound/musical_instruments/WeirdChime_7.ogg'
				if(8)
					door_note = 'sound/musical_instruments/WeirdChime_8.ogg'
				if(9)
					door_note = 'sound/musical_instruments/WeirdChime_9.ogg'
				if(10)
					door_note = 'sound/musical_instruments/WeirdChime_10.ogg'
				if(11)
					door_note = 'sound/musical_instruments/WeirdChime_11.ogg'
				if(12)
					door_note = 'sound/musical_instruments/WeirdChime_12.ogg'
			playsound(src.loc, door_note, 60, 0)
			return

		else
			..()
			return

	proc
		open()
			if (opened || changing_state == 1)
				return

			opened = 1
			changing_state = 1
			active = (opened != default_state)
			playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 50, 1)
			src.visible_message("<b>[src] slides open.</b>")
			FLICK("bluedoor_opening",src)
			src.icon_state = "bluedoor_0"
			set_density(0)
			set_opacity(0)
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
			playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 50, 1)
			src.visible_message("<b>[src] slides shut.</b>")
			FLICK("bluedoor_closing",src)
			src.icon_state = "bluedoor_1"
			SPAWN(1.3 SECONDS)
				changing_state = 0
			return

		toggle()
			if (opened)
				return close()
			else
				return open()

		activate()
			if (active)
				return

			if (opened)
				return close()

			return open()

		deactivate()
			if (!active)
				return

			if (opened)
				return close()

			return open()


/obj/precursor_puzzle/machine
	name = "peculiar machine"
	desc = "You're not really sure of what this does."
	icon = 'icons/obj/artifacts/artifacts.dmi'
	icon_state = "precursor-2"
	density = 1
	anchored = ANCHORED
	opacity = 1
	var/active = 0
	var/list/pitches = list()
	var/icon/effect_icon = null
	var/function = "projectile"
	var/obj/linked_object = null
	var/datum/projectile/plaser = new/datum/projectile/laser/precursor
	var/id = 1
	var/datum/light/light

	New()
		..()
		src.name = "[pick("quirky","wierd","strange","cold","odd","janky","metallic","smooth","oblong","swag")] [pick("device","doodad","gizmo","machine","emitter","statue","thingmabob")]"
		effect_icon = icon(icon, "[icon_state]fx") // figure out what to flick ahead of time


		src.pitches += rand(0,3)
		src.pitches += rand(4,8)
		src.pitches += rand(9,12)

		light = new /datum/light/point
		light.attach(src)
		light.set_color(0.3,0.6,0.8)
		light.set_brightness(0.4)

		if(src.active) // does it start on?
			src.activate()

		if(function == "electrical")
			SPAWN(4 SECONDS)
				linked_object = locate("sphere_[id]")

		return

	proc
		activate()
			if(src.active) return

			switch(function)
				if("projectile", null) // copied from singularity emitter code
					src.animate_effect()
					shoot_projectile_DIR(src, plaser, dir)
					src.visible_message(SPAN_ALERT("<b>[src]</b> fires a bolt of energy!"))

					if(prob(35))
						elecflash(src)

				if("electrical")
					if (!linked_object)
						return
					light.enable()
					src.animate_effect()
					playsound(src.loc, 'sound/effects/warp1.ogg', 65, 1)
					src.visible_message(SPAN_ALERT("<b>[src]</b> charges up!"))
					sleep(0.5 SECONDS)
					playsound(src, 'sound/effects/elec_bigzap.ogg', 40, TRUE)

					var/list/lineObjs
					lineObjs = drawLineObj(src, linked_object, /obj/line_obj/elec, 'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",FLY_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

					for (var/mob/living/poorSoul in range(linked_object, 3))
						//lineObjs += drawLineObj(linked_object, poorSoul, /obj/line_obj/elec, 'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",FLY_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

						arcFlash(src, poorSoul, 15000)
						/*poorSoul << sound('sound/effects/electric_shock.ogg', volume=50)
						random_burn_damage(poorSoul, 15) // let's not be too mean
						boutput(poorSoul, SPAN_ALERT("<B>You feel a powerful shock course through your body!</B>"))
						poorSoul.unlock_medal("HIGH VOLTAGE", 1)
						poorSoul:Virus_ShockCure(100)
						poorSoul:shock_cyberheart(100)
						poorSoul:weakened += rand(1,2)*/
						if (isdead(poorSoul) && prob(15))
							poorSoul.gib()

					SPAWN(0.6 SECONDS)
						for (var/obj/O in lineObjs)
							qdel(O)
						light.disable()





			sleep(0.5 SECONDS)
			src.active = 0

		animate_effect()
			if(src.overlays.len)
				return
			src.overlays += src.effect_icon
			sleep(1.5 SECONDS)
			src.overlays -= src.effect_icon

		deactivate()
			if(!src.active) return
			if(src.overlays.len)
				src.overlays = null
			src.active = 0


/obj/precursor_puzzle/rotator
	name = "peculiar machine"
	desc = "It looks like it can be moved somehow."
	interesting = "Scans detect: COBRYL | IRIDIUM | BOSE-EINSTEIN CONDENSATE | RYDBERG MATTER"
	icon = 'icons/obj/artifacts/artifacts.dmi'
	icon_state = "precursor-6"
	density = 1
	anchored = ANCHORED
	opacity = 1
	dir = EAST // facing right or left
	var/active = 0
	var/id = 1
	var/obj/precursor_puzzle/controller/linked_controller = null
	var/setting = "off"
	var/setting_red = 0
	var/setting_green = 0
	var/setting_blue = 0

	New()
		..()
		src.name = "[pick("ominous","tall","bulky","chilly","pointy","spinny","metallic","smooth","oblong","dapper")] [pick("device","doodad","gizmo","machine","column","thing","thingmabob")]"
		//boutput(world, "[src] is checking for controller")
		SPAWN(1 SECOND) // wait for the game to get started, then set up linkages with the controller object
			linked_controller = locate("controller_[id]")
			if(linked_controller)
				if(src.linked_controller) // just in case
					switch(src.dir)
						if(1)
							if(!src.linked_controller.effector_NE)
								src.linked_controller.effector_NE = src
						if(2)
							if(!src.linked_controller.effector_SW)
								src.linked_controller.effector_SW = src
						if(4) // if the rotator is facing right, it's sitting along the left wall
							if(!src.linked_controller.effector_SE)
								src.linked_controller.effector_SE = src
						if(8)
							if(!src.linked_controller.effector_NW)
								src.linked_controller.effector_NW = src
						else
							return // oh good you set it up wrong IDIOT


	attack_hand(mob/user)
		if(src.active)	return
		src.active = 1

		src.visible_message(SPAN_NOTICE("<b>[user] turns [src].</b>"))
		playsound(src.loc, 'sound/effects/stoneshift.ogg', 60, 1)
		src.icon = 'icons/obj/artifacts/puzzles.dmi'
		src.icon_state = "column_spin"
		sleep(1 SECOND)
		src.icon = 'icons/obj/artifacts/artifacts.dmi'
		src.icon_state = "precursor-6"
		playsound(src.loc, 'sound/machines/click.ogg', 60, 1)

		switch(src.setting) // roll to next color
			if("red")
				src.setting = "green"
				setting_red = 0
				setting_green = 1
				setting_blue = 0
			if("green")
				src.setting = "blue"
				setting_red = 0
				setting_green = 0
				setting_blue = 1
			if("blue")
				src.setting = "off"
				setting_red = 0
				setting_green = 0
				setting_blue = 0
			else
				src.setting = "red"
				setting_red = 1
				setting_green = 0
				setting_blue = 0



		src.update_controller()

		src.active = 0

		return

	proc
		update_controller()
			src.linked_controller?.update()
			return



/obj/precursor_puzzle/controller
	name = "peculiar panel"
	desc = "It looks like it's some sort of relay device, maybe."
	icon = 'icons/obj/artifacts/puzzles.dmi'
	icon_state = "controller_on"
	density = 1
	anchored = ANCHORED
	opacity = 1
	var/active = 0
	var/id = 1
	var/list/linked_shields = list()
	var/obj/precursor_puzzle/rotator/effector_NE = null
	var/obj/precursor_puzzle/rotator/effector_NW = null
	var/obj/precursor_puzzle/rotator/effector_SE = null
	var/obj/precursor_puzzle/rotator/effector_SW = null
	var/target_red = 0
	var/target_green = 0
	var/target_blue = 0
	////////////////////////////

	New()
		..()
		src.name = "[pick("little","odd","shiny","janky","quirky","swag")] [pick("indicator","relay","panel","trinket","fixture","whatsit")]"
		src.tag = "controller_[id]"

		// total value across r g b cannot exceed 1 point or the color will be unmixable
		// the goal is to use the four effector columns to reach the target values
		// each effector can assign 0.25 to one color channel, or be off
		/*
		var/limit_left = 4
		target_red = rand(1, prob(50) ? 4 : 3)
		limit_left -= target_red
		target_red *= 0.25

		target_green = (limit_left) ? rand(1, limit_left) : 0
		limit_left -= target_green
		target_green *= 0.25


		target_blue = (limit_left) ? rand(1, limit_left) : 0
		limit_left -= target_blue
		target_blue *= 0.25

		var/limit_check = target_red + target_green + target_blue

		while(limit_check > 1)
			target_red = pick(0,0.25,0.50,0.75,1)
			target_green = pick(0,0.25,0.50,0.75,1)
			target_blue = pick(0,0.25,0.50,0.75,1)
			limit_check = target_red + target_green + target_blue

			// this probably isn't the smartest way to deal with the problem
			// rerolling the results until they are at a safe value
		*/

		// ok so what if instead of that we just like. rolled a die 4 times
		// and counted how many times a number came up. that seems simpler.

		var/rnd = 0
		for (var/i = 1, i <= 4, i++)
			rnd = rand(1, 4)
			switch (rnd)
				if (1)
					target_red++
				if (2)
					target_green++
				if (3)
					target_blue++


		SPAWN(1 SECOND) // set up linkages to the shields
			for(var/obj/precursor_puzzle/shield/S in range(src,7))
				if(S.id == src.id)
					src.linked_shields += S
				else
					return

	proc
		update()
			if(active) return
			src.active = 1
			SPAWN(0.5 SECONDS)
				src.active = 0

			var/setting_red = src.effector_NE.setting_red + src.effector_SE.setting_red + src.effector_SW.setting_red + src.effector_NW.setting_red
			var/setting_green = src.effector_NE.setting_green + src.effector_SE.setting_green + src.effector_SW.setting_green + src.effector_NW.setting_green
			var/setting_blue = src.effector_NE.setting_blue + src.effector_SE.setting_blue + src.effector_SW.setting_blue + src.effector_NW.setting_blue

			if(src.linked_shields.len)
				if(setting_red == target_red)
					src.visible_message(SPAN_NOTICE("<b>[src]</b> beeps oddly."))
					playsound(src.loc, 'sound/machines/twobeep.ogg', 50,1)
					sleep(0.2 SECONDS)
				if(setting_green == target_green)
					src.visible_message(SPAN_NOTICE("<b>[src]</b> beeps strangely."))
					playsound(src.loc, 'sound/machines/twobeep.ogg', 50,1)
					sleep(0.2 SECONDS)
				if(setting_blue == target_blue)
					src.visible_message(SPAN_NOTICE("<b>[src] beeps curiously."))
					playsound(src.loc, 'sound/machines/twobeep.ogg', 50,1)
					sleep(0.2 SECONDS)

				Z_LOG_INFO("Adventure/Precursor", "Puzzle value: [setting_red] [setting_green] [setting_blue] ([target_red] [target_green] [target_blue])")
				if(setting_red == target_red && setting_green == target_green && setting_blue == target_blue)
					for(var/obj/precursor_puzzle/shield/S in src.linked_shields)
						S.update_color(setting_red / 4, setting_green / 4, setting_blue / 4)
						if(S.active)
							S.deactivate()
				else
					for(var/obj/precursor_puzzle/shield/S in src.linked_shields)
						S.update_color(setting_red / 4, setting_green / 4, setting_blue / 4)
						if(!S.active)
							S.activate()


			return


/obj/precursor_puzzle/shield
	name = "rydberg-matter barrier"
	desc = "It's pretty solid, somehow."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield1"
	density = 1
	anchored = ANCHORED
	opacity = 0
	var/active = 0
	var/id = 1
	var/changing_state = 0
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.set_brightness(0.8)
		light.attach(src)
		if(!src.active)
			src.activate()

	proc

		update_color(var/setting_red = 0, var/setting_green = 0, var/setting_blue = 0)
			light.set_color(setting_red,setting_green,setting_blue)


		activate()
			if(changing_state)
				return
			if(!src.active)
				src.active = 1
				src.set_density(1)
				src.invisibility = INVIS_NONE
				changing_state = 1
				playsound(src.loc, 'sound/effects/shielddown.ogg', 60, 1)
				src.visible_message(SPAN_NOTICE("<b>[src] powers up!</b>"))
				light.enable()

				SPAWN(0.4 SECONDS)
					changing_state = 0
			return

		deactivate()
			if(changing_state)
				return
			if(src.active)
				src.active = 0
				src.set_density(0)
				src.invisibility = INVIS_ALWAYS_ISH
				playsound(src.loc, 'sound/effects/shielddown2.ogg', 60, 1)
				src.visible_message(SPAN_NOTICE("<b>[src] powers down!</b>"))
				changing_state = 1
				light.disable()

				SPAWN(0.4 SECONDS)
					changing_state = 0
			return

/obj/precursor_puzzle/sphere
	name = "rydberg-matter sphere"
	desc = "That doesn't look very safe at all."
	interesting = "Scans detect: BOSE-EINSTEIN CONDENSATE | RYDBERG MATTER *** ELECTROMAGNETIC HAZARD"
	icon = 'icons/obj/artifacts/puzzles.dmi'
	icon_state = "sphere"
	anchored = ANCHORED
	density = 1
	opacity = 0
	var/id = 1
	var/datum/light/light

	New()
		..()
		src.tag = "sphere_[id]"
		light = new /datum/light/point
		light.attach(src)
		light.set_color(0.8,0.9,1)
		light.set_brightness(0.9)
		src.AddComponent(/datum/component/proximity)

	EnteredProximity(atom/movable/AM)
		if(iscarbon(AM) && prob(20))
			var/mob/living/carbon/user = AM
			src.shock(user)

	bump(atom/movable/AM as mob)
		if(iscarbon(AM))
			var/mob/living/carbon/user = AM
			src.shock(user)

	proc/shock(var/mob/living/user as mob)
		if(user)
			elecflash(user,power=2)
			var/shock_damage = rand(10,15)

			if (user.bioHolder.HasEffect("resist_electric_heal"))
				var/healing = 0
				if (shock_damage)
					healing = shock_damage / 3
				user.HealDamage("All", shock_damage, shock_damage)
				user.take_toxin_damage(0 - healing)
				boutput(user, SPAN_NOTICE("You absorb the electrical shock, healing your body!"))
				return
			else if (user.bioHolder.HasEffect("resist_electric"))
				boutput(user, SPAN_NOTICE("You feel electricity course through you harmlessly!"))
				return

			user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 0, shock_damage)
			boutput(user, SPAN_ALERT("<B>You feel a powerful shock course through your body sending you flying!</B>"))
			user.unlock_medal("HIGH VOLTAGE", 1)
			user.Virus_ShockCure(100)
			user:shock_cyberheart(100)
			user.changeStatus("stunned", 2 SECONDS)
			user.changeStatus("knockdown", 2 SECONDS)
			var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
			user.throw_at(target, 200, 4)
			for(var/mob/M in AIviewers(src))
				if(M == user)	continue
			user.show_message(SPAN_ALERT("[user.name] was shocked by the [src.name]!"), 3, SPAN_ALERT("You hear a heavy electrical crack"), 2)

//// collecting some junk together for the ice moon


//computer

/obj/machinery/computer3/generic/icemooon
	name = "Computer Console"
	setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
	setup_starting_peripheral2 = /obj/item/peripheral/printer
	setup_drive_type = /obj/item/disk/data/fixed_disk/icemoon_rdrive

/obj/item/disk/data/fixed_disk/icemoon_rdrive
	title = "VR_HDD"

	New()
		..()
		//First off, create the directory for logging stuff
		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "logs"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/c3help(src))
		newfolder = new /datum/computer/folder
		newfolder.name = "bin"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/terminal_program/writewizard(src))

		src.root.add_file( new /datum/computer/file/text/icemoon_log1(src))
		src.root.add_file( new /datum/computer/file/text/icemoon_log2(src))
		src.root.add_file( new /datum/computer/file/text/icemoon_log3(src))
		src.root.add_file( new /datum/computer/file/text/icemoon_log4(src))

// these aren't precursor things but fuck it, i don't feel like making another dm file right now

/obj/portrait_sneaky
	name = "crooked portrait"
	anchored = ANCHORED
	icon = 'icons/obj/decals/wallsigns.dmi'
	icon_state = "portrait"
	desc = "A portrait of a man wearing a ridiculous merchant hat. That must be Discount Dan."

	attack_hand(var/mob/user)
		boutput(user, SPAN_NOTICE("<b>You try to straighten [src], but it won't quite budge.</b>"))
		..()
		return

	attackby(obj/item/W, mob/user)
		if (ispryingtool(W))
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			boutput(user, SPAN_NOTICE("<b>You pry [src] off the wall, destroying it! You jerk!</b>"))
			new /obj/decal/woodclutter(src.loc)
			new /obj/item/storage/secure/ssafe/martian(src.loc)
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 70, 1)
			SPAWN(1 DECI SECOND)
			qdel(src)
			return
		else
			..()
			return

/obj/effects/ydrone_summon //WIP
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	var/range = 5
	var/end_float_effect = 0
	var/horseneigh = 0 //what am I doing with my life

	New(spawnloc)
		..()

		range += rand(-1,2)
		SPAWN(0)
			summon()


	proc/summon()

		var/temp_effect_limiter = 10
		for (var/turf/T in view(range, src))
			var/T_dist = GET_DIST(T, src)
			var/T_effect_prob = 0
			if(T_dist == 2)
				T_effect_prob = 100
			else
				T_effect_prob = 100 * (1 - (max(T_dist-1,1) / range))
			if (prob(8) && limiter.canISpawn(/obj/effects/sparks))
				var/obj/sparks = new /obj/effects/sparks
				sparks.set_loc(T)
				SPAWN(2 SECONDS) if (sparks) qdel(sparks)

			for (var/obj/item/I in T)
				if ( prob(T_effect_prob) )
					animate_float(I, 5, 10)
/*
					SPAWN(rand(0,30))

						var/n = 1
						var/n2 = 0
						var/pixel_y_mod = 0
						var/old_pixel_y = I.pixel_y
						while (I && !end_float_effect)
							if (pixel_y_mod < 24)
								I.pixel_y += 2
								pixel_y_mod += 2
								sleep(pixel_y_mod < 12 ? 6 : 3)
								continue

							n2 = n++ % 18
							if (n2 > 9)
								n2 = 9 - (n2 - 9)
							I.pixel_y = old_pixel_y + pixel_y_mod + n2 - 1
							sleep(0.4 SECONDS)

						while (I && I.pixel_y > old_pixel_y)
							I.pixel_y--
							sleep(0.2 SECONDS)
*/
			if (prob(T_effect_prob))
				SPAWN(rand(80, 100))
					if (T)
						playsound(T, pick('sound/effects/elec_bigzap.ogg', 'sound/effects/elec_bzzz.ogg', 'sound/effects/electric_shock.ogg'), 50, 0)
						var/obj/somesparks = new /obj/effects/sparks
						somesparks.set_loc(T)
						SPAWN(2 SECONDS) if (somesparks) qdel(somesparks)
						var/list/tempEffect
						if (temp_effect_limiter-- > 0)
							tempEffect = drawLineObj(src, somesparks, /obj/line_obj/elec, 'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",FLY_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

						if (T.density)
							for (var/atom/A in T)
								A.ex_act(1)

							if (istype(T, /turf/simulated/wall))
								T.ex_act(1)
							else
								T.ReplaceWithSpaceForce()
						else
							T.ex_act(clamp(T_dist-2,1,3))
							for (var/atom/A in T)
								if(A.z != T.z) continue
								A.ex_act(clamp(T_dist-2,1,3))

						sleep(0.6 SECONDS)
						for (var/obj/O in tempEffect)
							qdel(O)


		sleep (100)
		if (horseneigh == 0)
			new /obj/critter/gunbot/drone/iridium( locate(src.x-1, src.y-1, src.z) ) //Still needs a fancy spawn-in effect.
		else
			new /obj/critter/gunbot/drone/iridium/whydrone/horse( locate(src.x-1, src.y-1, src.z) ) //i am terrible
		end_float_effect = 0
		sleep (50)
		qdel(src)


		return


/datum/projectile/laser/precursor/sphere // for precursor traps
	name = "rydberg-matter sphere"
	icon = 'icons/obj/artifacts/puzzles.dmi'
	icon_state = "sphere"
	damage = 60
	stun = 15
	cost = 75
	sname = "rydberg-matter sphere"
	dissipation_delay = 15
	shot_sound = 'sound/machines/ArtifactPre1.ogg'
	color_red = 0.1
	color_green = 0.3
	color_blue = 1

	on_hit(atom/hit)
		if (istype(hit, /turf))
			hit.ex_act(1 + prob(50))

		return

/obj/effects/ydrone_summon/horseman //a new low/high depending on your point of view
	horseneigh = 1 //neigh

/obj/projectile/precursor_sphere
	var/homing = 1

	New()
		..()
		homing += rand(0,3)

	process()
		SPAWN(0)
			..()
		sleep(homing)
		elec_zap()

	proc/elec_zap()
		playsound(src, 'sound/effects/elec_bigzap.ogg', 40, TRUE)

		var/list/lineObjs
		for (var/mob/living/poorSoul in range(src, 5))
			lineObjs += drawLineObj(src, poorSoul, /obj/line_obj/elec, 'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",FLY_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

			poorSoul << sound('sound/effects/electric_shock.ogg', volume=50)
			random_burn_damage(poorSoul, 45)
			boutput(poorSoul, SPAN_ALERT("<B>You feel a powerful shock course through your body!</B>"))
			poorSoul.unlock_medal("HIGH VOLTAGE", 1)
			poorSoul:Virus_ShockCure(100)
			poorSoul:shock_cyberheart( 100)
			poorSoul:changeStatus("knockdown", 3 SECONDS)
			if (isdead(poorSoul) && prob(25))
				poorSoul.gib()

		for (var/obj/machinery/vehicle/poorPod in range(src, 4))
			lineObjs += drawLineObj(src, poorPod, /obj/line_obj/elec, 'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",FLY_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

			playsound(poorPod.loc, 'sound/effects/elec_bigzap.ogg', 40, 0)
			poorPod.bullet_act(src)


		SPAWN(0.6 SECONDS)
			for (var/obj/O in lineObjs)
				qdel(O)

			dispose()


	die()
		qdel(src)

/obj/creepy_sound_trigger
	icon = 'icons/misc/mark.dmi'
	icon_state = "ydn"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	density = 0
	var/active = 0

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(active) return
		if(ismob(AM))
			if(AM:client)
				if(prob(75))
					active = 1
					SPAWN(1 MINUTE) active = 0
					playsound(AM, pick('sound/ambience/station/Station_SpookyAtmosphere1.ogg','sound/ambience/station/Station_SpookyAtmosphere2.ogg'), 75, 0)

// cogwerks- variant for glaciers

/obj/creepy_sound_trigger_glacier
	icon = 'icons/misc/mark.dmi'
	icon_state = "ydn"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	density = 0
	var/active = 0

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(active) return
		if(ismob(AM))
			if(AM:client)
				if(prob(75))
					active = 1
					SPAWN(1 MINUTE) active = 0
					if(prob(10))
						playsound(AM, pick('sound/voice/animal/brullbar_scream.ogg', 'sound/voice/animal/brullbar_cry.ogg'),25, 1) // play these quietly so as to spook
					else
						playsound(AM, pick('sound/ambience/nature/Glacier_DeepRumbling1.ogg','sound/ambience/nature/Glacier_DeepRumbling1.ogg', 'sound/ambience/nature/Glacier_DeepRumbling1.ogg', 'sound/ambience/nature/Glacier_IceCracking.ogg', 'sound/ambience/nature/Glacier_DeepRumbling1.ogg', 'sound/ambience/nature/Glacier_Scuttling.ogg'), 75, 0)
////////////

/obj/ydrone_panel
	name = "access panel"
	desc = "It seems to be part of the satellite. The interface is locked. You see a small circular port below the keypad."
	icon = 'icons/obj/airtunnel.dmi'
	icon_state = "airbr0"
	anchored = ANCHORED
	pixel_y = 32
	var/activated = FALSE

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/dongle))
			if (activated)
				boutput(user, SPAN_ALERT("There's already one plugged in!"))
				return

			activated = TRUE
			user.visible_message(SPAN_ALERT("<b>[user]</b> plugs [W] into [src]."))
			qdel (W)

			summon_drone()
		else
			return ..()

	proc/summon_drone()
		src.icon_state = "airbr-alert"
		var/turf/spawn_turf = get_turf(src)
		for (var/obj/overlay/overlay in orange(5,src))
			if (findtext(overlay.name, "relay"))
				spawn_turf = get_turf(overlay)
				break

		new /obj/effects/ydrone_summon( spawn_turf )


/obj/item/device/dongle
	name = "syndicate security dongle"
	desc = "A form of secure, electronic identification with a round port connector and a funny name."
	w_class = W_CLASS_SMALL
	icon_state = "rfid"

var/global/list/scarysounds = list('sound/machines/engine_alert3.ogg',
'sound/effects/creaking_metal1.ogg',
'sound/machines/glitch1.ogg',
'sound/machines/glitch2.ogg',
'sound/machines/glitch3.ogg',
'sound/misc/automaton_tickhum.ogg',
'sound/misc/automaton_ratchet.ogg',
'sound/misc/automaton_scratch.ogg',
'sound/musical_instruments/Gong_Rumbling.ogg',
'sound/ambience/industrial/Precursor_Drone2.ogg',
'sound/ambience/industrial/Precursor_Choir.ogg',
'sound/ambience/industrial/Precursor_Drone3.ogg',
'sound/ambience/industrial/Precursor_Bells.ogg',
'sound/ambience/industrial/Precursor_Drone1.ogg',
'sound/ambience/industrial/AncientPowerPlant_Creaking1.ogg',
'sound/ambience/industrial/AncientPowerPlant_Creaking2.ogg',
'sound/ambience/industrial/AncientPowerPlant_Drone2.ogg',
'sound/ambience/industrial/AncientPowerPlant_Drone1.ogg',
'sound/machines/romhack1.ogg',
'sound/machines/romhack2.ogg',
'sound/machines/romhack3.ogg',
'sound/ambience/industrial/LavaPowerPlant_FallingMetal1.ogg',
'sound/ambience/industrial/LavaPowerPlant_FallingMetal2.ogg',
'sound/ambience/industrial/LavaPowerPlant_Rumbling3.ogg',
'sound/ambience/spooky/Evilreaver_Ambience.ogg',
'sound/ambience/spooky/Void_Song.ogg',
'sound/ambience/spooky/Void_Hisses.ogg',
'sound/ambience/spooky/Void_Screaming.ogg',
'sound/ambience/spooky/Void_Wail.ogg',
'sound/ambience/spooky/Void_Calls.ogg')


/obj/machinery/computer3/generic/dronelab
	name = "Design Office Console"
	setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
	setup_starting_peripheral2 = /obj/item/peripheral/printer
	setup_drive_type = /obj/item/disk/data/fixed_disk/dronelab

/obj/item/disk/data/fixed_disk/dronelab
	title = "DRONE_HDD"

	New()
		..()
		//First off, create the directory for logging stuff
		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "logs"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/c3help(src))
		//This is the bin folder. For various programs I guess sure why not.
		newfolder = new /datum/computer/folder
		newfolder.name = "bin"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/terminal_program/writewizard(src))

		src.root.add_file( new /datum/computer/file/record/dronefact_log1(src))
		src.root.add_file( new /datum/computer/file/record/dronefact_log2(src))
		src.root.add_file( new /datum/computer/file/record/dronefact_log3(src))

//stupid WIP shit here
/obj/beam/sine
	name = "strange energy"
	desc = "A glowing beam of something.  Neat."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "sinebeam1"
	density = 0
	var/harmonic = 1

	Crossed(atom/movable/Obj)
		if (istype(Obj))
			if (dir == NORTH || dir == SOUTH)
				animate(Obj, pixel_x=8, time = 8 - (2 * harmonic), loop=-1, easing = SINE_EASING)
				animate(pixel_x = -8, time = 8 - (2 * harmonic), loop=-1, easing = SINE_EASING)
			else
				animate(Obj, pixel_y=8, time = 8 - (2 * harmonic), loop=-1, easing = SINE_EASING)
				animate(pixel_y = -8, time = 8 - (2 * harmonic), loop=-1, easing = SINE_EASING)

		return ..()

	Uncrossed(atom/movable/Obj)
		if (istype(Obj))
			animate(Obj)
			Obj.pixel_x = initial(Obj.pixel_x)
			Obj.pixel_y = initial(Obj.pixel_y)

		return ..()

#define MAX_BONES 10 //Max Bones, skeleton P.I.
/obj/critter/bone_king
	name = "Bone King"
	generic = 0

	icon_state = "bone_king"
	var/list/bones = list()

	New()
		..()

		animate(src, pixel_y = 16, time = 6, loop=-1, easing = SINE_EASING)
		animate(pixel_y = -16, time = 6, loop=-1, easing = SINE_EASING)

#undef MAX_BONES
