/**
Centcom / Earth Stuff
Contents:
	Areas:
		Main Area
		Outside
		Offices
		Lobby
		Lounge
		Garden
		Power Supply

	Turfs: Outside Concrete & Grass
**/

var/global/Z4_ACTIVE = 0 //Used for mob processing purposes

/area/centcom
	name = "Centcom"
	icon_state = "purple"
	requires_power = 0
	sound_environment = 4
	teleport_blocked = 2
	skip_sims = 1
	sims_score = 25
	sound_group = "centcom"
	filler_turf = "/turf/unsimulated/nicegrass/random"
	is_centcom = 1
	var/static/list/entered_ckeys = list()

	Entered(atom/movable/A, atom/oldloc)
		. = ..()
		if (current_state < GAME_STATE_FINISHED)
			if(istype(A, /mob/living))
				var/mob/living/M = A
				if(!M.client)
					return
				if(M.client.holder)
					return
				if(M.client.ckey in entered_ckeys)
					return
				entered_ckeys += M.client.ckey
				logTheThing(LOG_DEBUG, M, "entered Centcom before round end [log_loc(M)].")

/area/centcom/outside
	name = "Earth"
	icon_state = "nothing_earth"
	//force_fullbright = 1
	ambient_light = CENTCOM_LIGHT

/area/centcom/gallery
	name = "NT Art Gallery"
	icon_state = "green"

/area/centcom/offices
	name = "NT Offices"
	icon_state = "red"
	var/ckey = ""


	a69
		ckey = ""
		name = "Office of Dixon Balls"
	adhara
		ckey = "adharainspace"
		name = "Office of Adhara"
	aibm
		ckey = "angriestibm"
		name = "Office of AngriestIBM"
	aphtonites
		ckey = ""
		name = "Office of Aphtonites"
	atomicthumbs
		ckey = ""
		name = "Office of Atomicthumbs"
	azrun
		ckey = "azrun"
		name = "Office of Azrun"
	beejail
		ckey = ""
		name = "Bee Jail"
	bubs
		ckey = "insanoblan"
		name = "Office of bubs"
	burntcornmuffin
		ckey = ""
		name = "Office of BurntCornMuffin"
	cal
		ckey = "mexicat"
		name = "Office of Cal"
	cogwerks
		ckey = "drcogwerks"
		name = "Office of Cogwerks"
	crimes
		ckey = "warc"
		name = "Office of Warcrimes"
	darkchis
		ckey = "darkchis"
		name = "Office of Walter Poehl"
	dions
		ckey = "dionsu"
		name = "Office of Dions"
	drsingh
		ckey = "magicmountain"
		name = "Office of DrSingh"
	edad
		ckey = ""
		name = "Office of Edad"
	efrem
		ckey = "captainbravo"
		name = "Office of Vaughn Moon"
	enakai
		ckey = "enakai"
		name = "Office of Enakai"
	flaborized
		ckey = "flaborized"
		name = "Office of Flaborized"
	flourish
		ckey = "flourish"
		name = "Office of Flourish"
	freshlemon
		ckey = ""
		name = "Office of Belkis Tekeli"
	gannets
		ckey = "gannets"
		name = "Office of Hannah Strawberry"
	gerhazo
		ckey = "gerhazo"
		name = "Office of Casey Spark"
	gibbed
		ckey = "gibbed"
		name = "Office of Rick"
	grayshift
		ckey = "grayshift"
		name = "Office of Grayshift"
	grifflez
		ckey = "grifflez"
		name = "Office of Grifflez"
	hazoflabs
		// ckey = ""
		name = "Shared Office Space of Gerhazo and Flaborized"
	hufflaw
		ckey = "hufflaw"
		name = "Office of Hufflaw"
	hukhukhuk
		ckey = "hukhukhuk"
		name = "Office of HukHukHuk"
	hydro
		ckey = "hydrofloric"
		name = "Office of HydroFloric"
	ines
		ckey = "hokie"
		name = "Office of Ines"
	janantilles
		ckey = "janantilles"
		name = "Office of Fleur DeLaCreme"
	katzen
		ckey = "flappybat"
		name = "Office of Katzen"
	kyle
		ckey = "kyle2143"
		name = "Office of Kyle"
	leah
		ckey = "leahthetech"
		name = "Office of Leah"
	lyra
		ckey = "lison"
		name = "Office of Lyra"
	maid
		ckey = "housekeep"
		name = "Office of Maid"
	marknstein
		ckey = "marknstein"
		name = "Office of MarkNstein"
	mbc
		ckey = "mybluecorners"
		name = "Office of Dotty Spud"
	mordent
		ckey = "mordent"
		name = "Office of Mordent"
	mrfishstick
		ckey = "mrfishstick"
		name = "Office of Mr Fishstick"
	nakar
		ckey = ""
		name = "Office of Nakar"
	pacra
		ckey = "pacra"
		name = "Office of Pacra"
	pali
		ckey = "pali6"
		name = "Office of Pali"
	patrickstar
		ckey = ""
		name = "Office of Patrick Star"
	pope
		ckey = "popecrunch"
		name = "Office of Popecrunch"
	questx
		ckey = "questx"
		name = "Office of Boris Bubbleton"
	reginaldhj
		ckey = "reginaldhj"
		name = "Office of ReginaldHJ"
	rodney
		ckey = "rodneydick"
		name = "Office of Lily"
	sageacrin
		ckey = "sageacrin"
		name = "Office of Escha Thermic"
	shotgunbill
		ckey = "shotgunbill"
		name = "Office of Shotgunbill"
	simianc
		ckey = "simianc"
		name = "Office of C.U.T.I.E."
	sord
		ckey="sord213"
		name = "Office of Sord"
	souricelle
		ckey = "souricelle"
		name = "Office of Souricelle"
	sovexe
		ckey = "sovexe"
		name = "Office of Sov Extant"
	studenterhue
		ckey = "studenterhue"
		name = "Office of Studenterhue"
	supernorn
		ckey = "supernorn"
		name = "Office of Supernorn"
	sydne66
		ckey = "sydne66"
		name = "Office of Throrvardr Finvardrardson"
	tarmunora
		ckey = "tarmunora"
		name = "Office of yass"
	tterc
		ckey = "tterc"
		name = "Office of Caroline Audibert"
	urs
		ckey = "ursulamajor"
		name = "Office of UrsulaMajor"
	varshie
		ckey = "varshie"
		name = "Office of Varshie"
	virvatuli
		ckey = "virvatuli"
		name = "Office of Virvatuli"
		sound_loop = 'sound/ambience/music/v_office_beats.ogg'
		sound_loop_vol = 90
		sound_group = "virva_office"
	walpvrgis
		ckey = "walpvrgis"
		name = "Office of Walpvrgis"
	wire
		ckey = "wirewraith"
		name = "Office of Wire"
	zamujasa
		ckey = "zamujasa"
		name = "Office of Zamujasa"
	zewaka
		ckey = "zewaka"
		name = "Office of Shitty Bill Jr."

/area/centcom/lobby
	name = "NT Offices Lobby"
	icon_state = "blue"

/area/centcom/lounge
	name = "NT Recreational Lounge"
	icon_state = "yellow"

/area/centcom/garden
	name = "NT Business Park"
	icon_state = "orange"

/area/centcom/power
	name = "NT Power Supply"
	icon_state = "green"
	blocked = 1

/area/centcom/datacenter
	name = "NT Data Center"
	icon_state = "pink"

/area/centcom/reconstitutioncenter
	name = "NT Reconstitution Center"
	icon_state = "purple"

/area/retentioncenter
	name = "NT Retention Center"
	icon_state = "dk_yellow"

/area/retentioncenter/teleblocked
	name = "NT Retention Center (teleblocked)"
	icon_state = "death"
	teleport_blocked = 2

/area/retentioncenter/depot
	name = "NT Retention Center (depot)"
	icon_state = "green"

/area/retentioncenter/blue
	name = "NT Retention Center (BLU)"
	icon_state = "blue"

/area/retentioncenter/green
	name = "NT Retention Center (GRN)"
	icon_state = "green"

/area/retentioncenter/yellow
	name = "NT Retention Center (YLW)"
	icon_state = "yellow"

/area/retentioncenter/orange
	name = "NT Retention Center (ORG)"
	icon_state = "orange"

/area/retentioncenter/red
	name = "NT Retention Center (RED)"
	icon_state = "red"

/area/retentioncenter/black
	name = "NT Retention Center (BLK)"
	icon_state = "purple"

/area/retentioncenter/restricted
	name = "NT Retention Center (Restricted)"
	icon_state = "death"

/area/retentioncenter/disposals
	name = "NT Retention Center (disposals)"
	icon_state = "red"

/area/retentioncenter/substation
	name = "NT Retention Center (substation)"
	icon_state = "pink"

/area/retentioncenter/office
	name = "NT Retention Center (office)"
	icon_state = "orange"

/area/retentioncenter/recycling
	name = "NT Retention Center (Recycling)"
	icon_state = "pink"

////////////////////////////

/turf/unsimulated/outdoors
	icon = 'icons/turf/outdoors.dmi'

	snow
		name = "snow"
		New()
			..()
			set_dir(pick(cardinal))
		icon_state = "grass_snow"
	grass
		name = "grass"
		New()
			..()
			set_dir(pick(cardinal))
		icon_state = "grass"
		dense
			name = "dense grass"
			desc = "whoa, this is some dense grass. wow."
			density = 1
			opacity = 1
			color = "#AAAAAA"
	concrete
		name = "concrete"
		icon_state = "concrete"

//sord office

/obj/machinery/door/unpowered/wood/sordBloodDoor
	open()
		. = ..()
		if(.)
			var/const/fluid_amount = 50
			var/datum/reagents/R = new /datum/reagents(fluid_amount)
			R.add_reagent("blood", fluid_amount)

			var/turf/T = get_turf(src)
			if (istype(T))
				T.fluid_react(R,fluid_amount)
				R.clear_reagents()

//adhara office

//adhara herself....?
/mob/living/critter/small_animal/cat/cathara
	name = "Cathara"
	desc = "...is this really her?? Do they let cats be admins??"
	icon_state = "cat1"
	randomize_name = FALSE
	randomize_look = FALSE

	New()
		..()
		var/randx = (rand(7, 20) / 10)
		var/randy = (rand(7, 20) / 10)
		src.transform = src.transform.Scale(randx, randy) //make em weird lookin (mood)

//adhara comp stuff - very ugly and big code
/obj/item/disk/data/fixed_disk/adharas_laptop
	file_amount = 512 //very big

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
		newfolder.name = "diary"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/adhara_office/diary_goals (src))
		newfolder.add_file( new /datum/computer/file/record/adhara_office/prs (src))
		newfolder.add_file( new /datum/computer/file/record/adhara_office/kyle (src))
		newfolder.add_file( new /datum/computer/file/record/adhara_office/mhelps (src))
		newfolder.add_file( new /datum/computer/file/record/adhara_office/macncheese (src))

/obj/machinery/computer3/luggable/personal/adhara_laptop //due to jank system, this isnt the one that gets put in the map. but it is used internally by the other
	setup_drive_type = /obj/item/disk/data/fixed_disk/adharas_laptop

/obj/item/luggable_computer/personal/adhara_laptop //hi i go into the map
	name = "cute laptop"
	desc = "Isn't this a cute little laptop?"
	luggable_type = /obj/machinery/computer3/luggable/personal/adhara_laptop

	New() //lets set up our stickers
		..()
		var/obj/item/sticker/sticker_heart = new /obj/item/sticker/heart
		sticker_heart.stick_to(src, -6, -4)
		sleep(0.5 SECONDS)
		var/obj/item/sticker/sticker_rainbow = new /obj/item/sticker/rainbow
		sticker_rainbow.stick_to(src, -3, 1)
		sleep(0.5 SECONDS)
		var/obj/item/sticker/sticker_robuddy = new /obj/item/sticker/robuddy
		sticker_robuddy.stick_to(src, 2, -3)


/datum/computer/file/record/adhara_office

	diary_goals
		name = "diary_goals"

		New()
			..()
			src.fields = list("im gonna try to store these",\
			"notes on my computer. update it",\
			"once a week, maybe once every 2.",\
			"depends on how this all works out <3")

	prs
		name = "prs"

		New()
			..()
			src.fields = list("i always have so many ideas!",\
			"youd think that maybe id manage to get",\
			"some of these down and coded and,",\
			"submitted but its really hard actually!!!",\
			"i just wish it was easier to get stuff",\
			"out of my head, typed down, and submitted.",\
			"but idk. if it was easy, then i wouldnt",\
			"feel good when i submitted one, would i?",\
			"ill just count my blessings. at least",\
			"i can code, right? <3")

	kyle
		name = "kyle"

		New()
			..()
			src.fields = list("kyle asked me to fix my code today.",\
			"but im lazy and i dont really want to fix",\
			"it tbh but if i dont will it get done?",\
			"who knows. ill think later after some food.")

	mhelps
		name = "mhelps"

		New()
			..()
			src.fields = list("so i guess im hired as an admin now.",\
			"kinda crazy. lotta new responsibilities.",\
			"one thing i guess is that i dont have as",\
			"much time to answer mhelps as i did before",\
			"i feel a bit bad on one hand, but on the",\
			"other hand, i helped a lot of people and",\
			"theres always going to be more mentors",\
			"who can help people with questions.",\
			"now instead answering questions,",\
			"i get to tell people to stop being",\
			"racist haha. idk which is more rewarding.")

	macncheese
		name = "mac_n_cheese"

		New()
			..()
			src.fields = list("i fuckin love this stuff")

//ada o hara hat
/obj/item/clothing/head/centhat/ada
	name = "scottish captain's hat"
	desc = "you can literally feel the scottishness emanatinig from this hat... or maybe thats radiation."
	var/list/rejected_mobs = list()

	equipped(var/mob/user)
		..()
		boutput(user, "<span class='alert'>You can feel a proud and angry presence probing your mind...</span>")
		src.cant_self_remove = TRUE
		src.cant_other_remove = TRUE
		SPAWN(1 SECOND)
			if (user.bioHolder && user.bioHolder.HasEffect("accent_scots"))
				boutput(user, "<span class='notice'>YE AR' ALREADY BLESSED!!!</span>")
			else if (prob(50) && user.bioHolder && !src.rejected_mobs.Find(user))
				boutput(user, "<span class='notice'>OCH, CAN YE 'EAR TH' HIELAN WINDS WHISPERIN' MY NAME??</span>")
				sleep(1 SECOND)
				boutput(user, "<span class='notice'>I AM ADA O'HARA! MA SPIRIT IS INDOMITABLE! I'LL MAKE YE INDOMITABLE TAE...</span>")
				sleep(1 SECOND)
				user.bioHolder.AddEffect("accent_scots")
				boutput(user, "<span class='notice'>HEED FORTH, AYE? FECHT LANG AN' HAURD!!</span>")
			else
				boutput(user, "<span class='alert'>YE AR' NO' WORTHY OF ADA O'HARA'S BLESSIN'! FECK AFF!!!!</span>")
				src.rejected_mobs.Add(user)
			src.cant_self_remove = TRUE
			src.cant_other_remove = FALSE


/area/centcom/offices/enakai
	Entered(atom/movable/Obj,atom/OldLoc)
		. = ..()
		if (isliving(Obj))
			var/mob/living/L = Obj
			if (down_under_verification(L))		//The aussies are immune due to constant exposure
				return
			var/matrix/M = L.transform
			animate(L, transform = matrix(M, 90, MATRIX_ROTATE | MATRIX_MODIFY), time = 3)
			animate( transform = matrix(M, 90, MATRIX_ROTATE | MATRIX_MODIFY), time = 3)

	Exited(atom/movable/Obj, atom/newloc)
		if (isliving(Obj))
			var/mob/living/L = Obj
			if (down_under_verification(L))
				return
			var/matrix/M = L.transform
			animate(L, transform = matrix(M, -90, MATRIX_ROTATE | MATRIX_MODIFY), time = 3)
			animate( transform = matrix(M, -90, MATRIX_ROTATE | MATRIX_MODIFY), time = 3)

	proc/down_under_verification(var/mob/living/L)
		return L.ckey in list("enakai", "rodneydick", "walpvrgis", "chrisb340")



proc/get_centcom_mob_cloner_spawn_loc()
	RETURN_TYPE(/turf)
	if(length(landmarks[LANDMARK_CHARACTER_PREVIEW_SPAWN]))
		shuffle_list(landmarks[LANDMARK_CHARACTER_PREVIEW_SPAWN])
		for(var/turf/T in landmarks[LANDMARK_CHARACTER_PREVIEW_SPAWN])
			if(isnull(locate(/mob/living) in T))
				return T

/obj/centcom_clone_wrapper
	density = 1
	anchored = UNANCHORED
	mouse_opacity = 0
	var/bumping = FALSE

	New(atom/loc, mob/living/clone)
		..()
		src.vis_contents += clone

	set_loc(newloc)
		. = ..()
		if(isnull(newloc) && !QDELETED(src))
			src.vis_contents = null
			qdel(src)

	bump(atom/O)
		. = ..()
		if(bumping || !ismovable(O))
			return
		var/atom/movable/AM = O
		bumping = TRUE
		var/t = get_dir(src, AM)
		AM.animate_movement = SYNC_STEPS
		AM.glide_size = src.glide_size
		step(AM, t)
		step(src, t)
		bumping = FALSE

proc/put_mob_in_centcom_cloner(mob/living/L, indirect=FALSE)
	var/atom/movable/clone = indirect ? new/obj/centcom_clone_wrapper(get_centcom_mob_cloner_spawn_loc(), L) : L
	clone.name = L.name
	var/area/AR = get_area(clone)
	if(!istype(AR, /area/centcom/reconstitutioncenter))
		clone.set_loc(get_centcom_mob_cloner_spawn_loc())
	if(!indirect)
		L.set_density(TRUE)
		L.set_a_intent(INTENT_HARM)
		L.dir_locked = TRUE
	playsound(clone, 'sound/machines/ding.ogg', 50, 1)
	clone.visible_message("<span class='notice'>[L.name || "A clone"] pops out of the cloner.</span>")
	var/static/list/obj/machinery/conveyor/conveyors = null
	var/static/conveyor_running_count = 0
	if(isnull(conveyors))
		conveyors = list()
		for(var/obj/machinery/conveyor/C as anything in machine_registry[MACHINES_CONVEYORS])
			if(C.id == "centcom cloning")
				conveyors += C
	if(conveyor_running_count == 0)
		for(var/obj/machinery/conveyor/conveyor as anything in conveyors)
			conveyor.operating = 1
			conveyor.setdir()
	conveyor_running_count++
	SPAWN(8 SECONDS)
		conveyor_running_count--
		if(conveyor_running_count == 0)
			for(var/obj/machinery/conveyor/conveyor as anything in conveyors)
				conveyor.operating = 0
				conveyor.setdir()

/obj/item/reagent_containers/food/drinks/drinkingglass/shot/normal
	name = "very normal drink"
	desc = "Will not blow your leg off."
	gulp_size = 25
	initial_volume = 25

	New()
		. = ..()
		src.create_reagents(src.initial_volume)
		src.reagents.add_reagent("ice", 5, temp_new = T0C - 1)
		src.reagents.add_reagent("potassium", 5, temp_new = T0C - 1)
		src.reagents.add_reagent("LSD", 15, temp_new = T0C - 1)

/obj/item/reagent_containers/food/drinks/drinkingglass/pitcher/gnesis
	initial_reagents = "flockdrone_fluid"
	New()
		. = ..()
		src.setMaterial(getMaterial("gnesisglass"))

/mob/living/critter/small_animal/crab/responsive
