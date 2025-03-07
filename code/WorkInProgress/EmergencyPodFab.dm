/obj/machinery/vehicle/arrival_pod
	name = "Emergency Pod E-"
	desc = "A small one-person pod designed for emergency short-distance transit.<br>There's a warning on the side that says 'LIMITED LIFESPAN - FOR INTRA-STATION TRANSIT ONLY'."
	icon_state = "escape"
	capacity = 1
	health = 60
	maxhealth = 60
	weapon_class = 1
	speedmod = 0.36
	var/launched = 0
	var/steps_moved = 0
	var/failing = 0

	New()
		. = ..()
		for(var/datum/contextAction/CA in src.contextActions)
			if(istype(CA, /datum/contextAction/vehicle/parts))
				src.contextActions -= CA
				break

	attackby(obj/item/W, mob/living/user)
		if (isweldingtool(W))
			boutput(user, "You can't repair this pod.")
			return
		..()

	board_pod(var/mob/boarder)
		..()
		if (!src.pilot) return //if they were stopped from entering by other parts of the board proc from ..()
		src.escape()
		return

	proc/escape()
		if(!launched)
			launched = 1
			while(!failing)
				var/area/whereweat = get_area(src.loc)
				if (whereweat.name == "Space")
					steps_moved++ // part of the decay only applies if you're in space (allows you some time to figure things out)
				steps_moved++ // constant decay after launch
				if(steps_moved + (rand(steps_moved) * 0.5) > 120) fail()
				sleep(1.5 SECONDS)

	proc/fail()
		failing = 1
		pilot.playsound_local_not_inworld('sound/machines/engine_alert1.ogg', vol=100)
		boutput(pilot, SPAN_ALERT("Your emergency pod is falling apart around you!"))
		while(src)
			step(src,src.dir)
			if(prob(steps_moved * 0.1))
				make_cleanable( /obj/decal/cleanable/robot_debris/gib ,src.loc)
			if(prob(steps_moved * 0.05))
				if(pilot)
					boutput(pilot, SPAN_ALERT("You are ejected from the emergency pod as it disintegrates!"))
					src.eject(pilot)
				new /obj/effects/explosion (src.loc)
				playsound(src.loc, "explosion", 50, 1)
				make_cleanable( /obj/decal/cleanable/machine_debris ,src.loc)
				qdel(src)
			sleep(0.4 SECONDS)

/obj/machinery/macrofab
	name = "Macro-Fabricator"
	desc = "A sophisticated machine that fabricates large objects from a nearby reserve of supplies."
	icon = 'icons/obj/machines/podfab.dmi'
	icon_state = "fab-still"
	anchored = ANCHORED
	density = 0
	layer = 2.9
	var/active = 0
	var/blocked = 0
	var/obj/createdObject = /obj/fireworksbox
	var/obj/framework/holo = null
	var/itemName = null
	var/isSetup = 0
	var/fabTime = 50 // 3 of this is a little over a second, fabrication time is slightly randomized
	var/override_dir = null
	var/turf/outputLoc = null
	var/sound_happy = 'sound/machines/chime.ogg'
	var/sound_volume = 20
	var/static/list/fabsounds = list('sound/machines/computerboot_pc.ogg','sound/machines/glitch3.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/machines/mixer.ogg','sound/machines/pc_process.ogg','sound/machines/rock_drill.ogg','sound/machines/scan.ogg') //holy fuck these were awful sounds, these ones are slightly less awful but i hate the way this works

	attack_hand(var/mob/user)
		if (active)
			boutput(user, SPAN_ALERT("Manufacture in progress, please wait."))
			return

		if (!isSetup) initialAlloc()

		outputLoc = get_turf(src.loc)
		if(outputLoc.density)
			boutput(user, SPAN_ALERT("There's no room to create another [itemName]."))
			return

		blocked = 0
		for (var/obj/block in outputLoc)
			if (block.density) blocked = 1
		if(blocked)
			boutput(user, SPAN_ALERT("There's no room to create another [itemName]."))
			return

		src.visible_message("<b>[user.name]</b> switches on [src].")
		beginFab()

	attack_ai(var/mob/user as mob)
		if (active)
			boutput(user, SPAN_ALERT("Manufacture in progress, please wait."))
			return

		if (!isSetup) initialAlloc()

		outputLoc = get_turf(src.loc)
		if(outputLoc.density)
			boutput(user, SPAN_ALERT("There's no room to create another [itemName]."))
			return

		blocked = 0
		for (var/obj/block in outputLoc)
			if (block.density) blocked = 1
		if(blocked)
			boutput(user, SPAN_ALERT("There's no room to create another [itemName]."))
			return

		src.visible_message("[src] activates itself.")
		beginFab()

	//actual manufacture process
	proc/beginFab()
		active = 1
		icon_state = "fab-mov"
		holo.set_loc(src.loc)
		var/turf/outputLoc = get_turf(src.loc) //this shouldn't be unset going into the proc due to being set prior, but I wanted to be sure
		var/progress = 0
		var/noiseThreshold = (0.8 * fabTime) - 2 //don't play noises all the way till the end as they carry on a bit
		var/alphaDelta = round(250 / fabTime) //automatically calculates fade-in rate based on the assembly speed
		while(progress < fabTime)
			if (progress < noiseThreshold) playsound(src.loc, pick(src.fabsounds), sound_volume, 1)
			progress++
			holo.alpha += alphaDelta
			sleep(rand(6,8))

		outputLoc = get_turf(src.loc)
		for (var/obj/block in outputLoc)
			if (block.density) blocked = 1
		if(!blocked)
			var/obj/f = new createdObject
			if (override_dir)
				f.set_dir(override_dir)
			else
				f.set_dir(src.dir)
			f.set_loc(src.loc)
		holo.set_loc(src)
		holo.alpha = 5
		active = 0
		icon_state = "fab-still"
		playsound(src.loc, src.sound_happy, 50, 1)
		src.visible_message("<b>[src]</b> finishes working and shuts down.")


	//sets up hologram and item name by instantiating a target object
	proc/initialAlloc()
		var/obj/refInstance = new createdObject
		if (holo || !itemName) //short-circuited to permit manually set item names to override auto-generated ones at round start
			itemName = refInstance.name //this ensures that changing the fabricated object and setting isSetup to 0 will work as expected
		if (!holo)
			holo = new /obj/framework
		holo.icon = refInstance.icon
		holo.icon_state = refInstance.icon_state
		holo.name = "semi-constructed [itemName]"
		holo.desc = "A partially constructed [itemName] in the process of being assembled by a fabricator."
		if (override_dir) //fabricator will default to assembling things in the direction it's facing, but can be overridden
			holo.set_dir(override_dir)
		else
			holo.set_dir(src.dir)
		qdel(refInstance)
		isSetup = 1

	disposing()
		if (holo)
			qdel(holo)
		..()

	emergency_pod
		name = "Emergency Pod Fabricator"
		desc = "A sophisticated machine that fabricates short-range emergency pods from a nearby reserve of supplies."
		createdObject = /obj/machinery/vehicle/arrival_pod
		itemName = "emergency pod"

		arrival //the one on the arrival shuttle should not be destructible
			ex_act()
				return

			blob_act()
				return

			meteorhit()
				return

/obj/framework
	name = "semi-constructed object"
	desc = "A thing in the process of being assembled by a fabricator."
	alpha = 5
	anchored = ANCHORED
	density = 0
	opacity = 0
