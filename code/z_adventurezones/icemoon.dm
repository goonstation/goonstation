/**
Ice Moon Adventure Zone (surface)
Contents:
	Turfs:
		Elevator Shaft Fall
		Snow
		Ice Walls
		Ice Lake
		Cold Plating
		Abyss Fall
		Cliff Edges
**/

/turf/simulated/floor/arctic_elevator_shaft
	name = "elevator shaft"
	desc = "It looks like it goes down a long ways."
	icon_state = "void_gray"
	step_material = "step_lattice"
	step_priority = STEP_PRIORITY_MED

	ex_act(severity)
		return

	Entered(atom/movable/A as mob|obj)
		if (istype(A, /obj/overlay/tile_effect) || istype(A, /mob/dead) || istype(A, /mob/wraith) || istype(A, /mob/living/intangible))
			return ..()
		var/turf/T = pick_landmark(LANDMARK_FALL_ICE_ELE)
		if (isturf(T))
			visible_message("<span class='alert'>[A] falls down [src]!</span>")
			if (ismob(A))
				var/mob/M = A
				if(!M.stat && ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.gender == MALE) playsound(H.loc, 'sound/voice/screams/male_scream.ogg', 100, 0, 0, H.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
					else playsound(H.loc, 'sound/voice/screams/female_scream.ogg', 100, 0, 0, H.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
				random_brute_damage(M, 33)
				M.changeStatus("stunned", 10 SECONDS)
			A.set_loc(T)
			return
		else ..()

/turf/unsimulated/floor/arctic/snow
	name = "odd snow"
	desc = "Frozen carbon dioxide. Neat."
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass_snow"
	carbon_dioxide = 100
	nitrogen = 0
	oxygen = 0
	temperature = 100
	fullbright = 0

	New()
		..()
		src.set_dir(pick(cardinal))

//okay these are getting messy as hell, i need to consolidate this shit later
/turf/unsimulated/floor/arctic/snow/ice
	name = "ice floor"
	desc = "A tunnel through the glacier. This doesn't seem to be water ice..."
	icon = 'icons/turf/floors.dmi'
	icon_state = "ice1"
	fullbright = 0

	New()
		..()
		icon_state = "[pick("ice1","ice2","ice3","ice4","ice5","ice6")]"

/turf/unsimulated/floor/arctic/snow/lake
	name = "frozen lake"
	desc = "You can see the lake bubbling away under the ice. Neat."
	icon = 'icons/turf/floors.dmi'
	icon_state = "poolwaterfloor"
	fullbright = 0


/turf/unsimulated/floor/arctic/plating
	name = "plating"
	desc = "It's freezing cold."
	icon_state = "plating"
	carbon_dioxide = 100
	nitrogen = 0
	oxygen = 0
	temperature = 100
	fullbright = 0
	can_replace_with_stuff = 1

/turf/unsimulated/floor/arctic/abyss
	name = "deep abyss"
	desc = "You can't see the bottom."
	icon_state = "void_gray"
	carbon_dioxide = 100
	nitrogen = 0
	oxygen = 0
	temperature = 100
	fullbright = 0
	pathable = 0
	can_replace_with_stuff = 1

	// this is the code for falling from abyss into ice caves
	// could maybe use an animation, or better text. perhaps a slide whistle ogg?
	Entered(atom/A as mob|obj, atom/old_loc)
		if (isobserver(A) || isintangible(A))
			return ..()
		if(isobj(A))
			var/obj/O = A
			if(isnull(old_loc) || O.anchored)
				return ..()

		var/turf/T = pick_landmark(LANDMARK_FALL_ICE)
		if(T)
			fall_to(T, A)
			return
		else ..()

/turf/unsimulated/floor/arctic/cliff
	name = "icy cliff"
	desc = "Looks dangerous."
	icon_state = "snow_cliff1"
	carbon_dioxide = 100
	nitrogen = 0
	oxygen = 0
	temperature = 100
	fullbright = 0
	can_replace_with_stuff = 1

	New()
		..()
		icon_state = "[pick("snow_cliff1","snow_cliff2","snow_cliff3","snow_cliff4")]"

/turf/unsimulated/floor/arctic/cliff_outsidecorner
	name = "icy cliff"
	desc = "Looks dangerous."
	icon_state = "snow_corner"
	dir = 5
	carbon_dioxide = 100
	nitrogen = 0
	oxygen = 0
	temperature = 100
	fullbright = 0
	can_replace_with_stuff = 1

///////////////////////////////////////////////////////////////WALLS////////////////////////////////////////////////

/turf/unsimulated/wall/arctic/abyss
	name = "deep abyss"
	desc = "You can't see the bottom."
	icon_state = "void_gray"
	gas_impermeable = 1
	opacity = 1
	density = 1
	fullbright = 0

/turf/unsimulated/wall/arctic/abyss
	name = "deep abyss"
	desc = "You can't see the bottom."
	icon_state = "void_gray"
	opacity = 1
	density = 1


//this also sucks and needs to be consolidated, just bugtesting right now
/turf/unsimulated/wall/arctic/abyss/ice
	name = "ice wall"
	desc = "You're inside a glacier. Wow."
	icon_state = "ice1"
	fullbright = 0

	New()
		..()
		icon_state = "[pick("ice1","ice2","ice3","ice4","ice5","ice6")]"
