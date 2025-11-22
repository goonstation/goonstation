TYPEINFO(/datum/component/hallucination/trippy_colors)
	initialization_args = list(
		ARG_INFO("timeout", DATA_INPUT_NUM, "how long this hallucination lasts in seconds. -1 for permanent", 30),
	)

TYPEINFO(/datum/component/hallucination/fake_singulo)
	initialization_args = list(
		ARG_INFO("timeout", DATA_INPUT_NUM, "how long this hallucination lasts in seconds. -1 for permanent", 30),
	)


TYPEINFO(/datum/component/hallucination/random_sound)
	initialization_args = list(
		ARG_INFO("timeout", DATA_INPUT_NUM, "how long this hallucination lasts in seconds. -1 for permanent", 30),
		ARG_INFO("sound_list", DATA_INPUT_LIST_BUILD, "List of sounds that the mob can hallucinate appearing."),
		ARG_INFO("sound_prob", DATA_INPUT_NUM, "probability of a sound being played per mob life tick", 10),
		ARG_INFO("min_distance", DATA_INPUT_NUM, "minimum distance to the mob the sound will play from", 0)
	)

TYPEINFO(/datum/component/hallucination/random_image)
	initialization_args = list(
		ARG_INFO("timeout", DATA_INPUT_NUM, "how long this hallucination lasts in seconds. -1 for permanent", 30),
		ARG_INFO("image_list", DATA_INPUT_LIST_BUILD, "List of images that the mob can hallucinate appearing"),
		ARG_INFO("image_prob", DATA_INPUT_NUM, "probability of an image being displayed per mob life tick", 10),
		ARG_INFO("image_time", DATA_INPUT_NUM, "seconds the displayed image hangs around", 20),
	)

TYPEINFO(/datum/component/hallucination/fake_attack)
	initialization_args = list(
		ARG_INFO("timeout", DATA_INPUT_NUM, "how long this hallucination lasts in seconds. -1 for permanent", 30),
		ARG_INFO("image_list", DATA_INPUT_LIST_BUILD, "List of images that the mob can hallucinate attacking, leave null for default"),
		ARG_INFO("name_list", DATA_INPUT_LIST_BUILD, "List of names that the mob can hallucinate attacking, leave null for default"),
		ARG_INFO("attacker_prob", DATA_INPUT_NUM, "probability of an attacker being spawned per mob life tick", 10),
		ARG_INFO("max_attackers", DATA_INPUT_NUM, "number of attackers that can be active at one time", 5),
	)

TYPEINFO(/datum/component/hallucination/random_image_override)
	initialization_args = list(
		ARG_INFO("timeout", DATA_INPUT_NUM, "how long this hallucination lasts in seconds. -1 for permanent", 30),
		ARG_INFO("image_list", DATA_INPUT_LIST_BUILD, "List of images that the mob can hallucinate attached to things"),
		ARG_INFO("target_list", DATA_INPUT_LIST_BUILD, "List of target types that the mob can hallucinate images attached to in range"),
		ARG_INFO("range", DATA_INPUT_NUM, "distance from mob to search for target types", 5),
		ARG_INFO("image_prob", DATA_INPUT_NUM, "probability of an image being displayed per mob life tick", 10),
		ARG_INFO("image_time", DATA_INPUT_NUM, "seconds the displayed image hangs around", 20),
		ARG_INFO("override", DATA_INPUT_BOOL, "Does this hallucination replace the target's icon?", TRUE),
		ARG_INFO("visible_creation", DATA_INPUT_BOOL, "Should the displayed image appear in line of sight?", TRUE),
	)

TYPEINFO(/datum/component/hallucination/distant_explosion)
	initialization_args = list(
		ARG_INFO("timeout", DATA_INPUT_NUM, "how long this hallucination lasts in seconds. -1 for permanent", 30),
		ARG_INFO("explosion_prob", DATA_INPUT_NUM, "probability of a fake explosion per mob life tick", 15),
		ARG_INFO("cooldown_time", DATA_INPUT_NUM, "minimum time between fake explosions in deciseconds", 7 SECONDS),
		ARG_INFO("shake_duration", DATA_INPUT_NUM, "how long the screen shake lasts in deciseconds", 8),
		ARG_INFO("shake_strength", DATA_INPUT_NUM, "how much screenshaking should occur", 24),
		ARG_INFO("sound_volume", DATA_INPUT_NUM, "volume of the fake explosion sound", 70),
	)

//#########################################################
//                HALLUCINATION COMPONENTS
//#########################################################


///Generic hallucination effects - subclass for fancy effects
ABSTRACT_TYPE(/datum/component/hallucination)
/datum/component/hallucination
	dupe_mode = COMPONENT_DUPE_SELECTIVE//you can have lots of hallucinations, from different sources, but maybe not duplicates from the same source (unless you wanna)
	///expiry time, -1 means never
	var/ttl = -1
	///Instead of typecasting every tick, let's just hold a nice ref
	var/mob/parent_mob

/datum/component/hallucination/Initialize(timeout=30)
	. = ..()
	if (!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	parent_mob = parent
	ttl = timeout
	if(ttl != -1)
		ttl = world.time + timeout SECONDS
	RegisterSignal(parent, COMSIG_LIVING_LIFE_TICK, PROC_REF(do_mob_tick))

/datum/component/hallucination/proc/do_mob_tick(mob, mult)
	if(ttl != -1 && world.time > ttl)
		UnregisterFromParent()
		qdel(src)

/datum/component/hallucination/CheckDupeComponent(timeout)
	if(timeout == -1)
		src.ttl = timeout
	else if(src.ttl != -1)
		src.ttl = world.time + timeout SECONDS //reset timeout

	return FALSE //false means create a new component, true means this is a dupe so don't create it
//#########################################################
//                    TRIPPY COLORS
//#########################################################


/// Trippy colors - apply an RGB swap to client's vision
/datum/component/hallucination/trippy_colors
	var/current_color_pattern = 0
	var/pattern1 = list(0,0,1,0, 1,0,0,0, 0,1,0,0, 0,0,0,1, 0,0,0,0)
	var/pattern2 = list(0,1,0,0, 0,0,1,0, 1,0,0,0, 0,0,0,1, 0,0,0,0)

	do_mob_tick(mob, mult)
		if(parent_mob.client && (current_color_pattern == 0 || probmult(20))) //trippy colours
			if(src.current_color_pattern == 1)
				parent_mob.client.animate_color(pattern2, time=40, easing=SINE_EASING)
				src.current_color_pattern = 2
			else
				parent_mob.client.animate_color(pattern1, time=40, easing=SINE_EASING)
				src.current_color_pattern = 1
		..()

	UnregisterFromParent()
		. = ..()
		UnregisterSignal(parent, COMSIG_LIVING_LIFE_TICK)
		if(parent_mob?.client)
			animate(parent_mob.client, color = null, time = 2 SECONDS, easing = SINE_EASING)


//#########################################################
//                    RANDOM SOUNDS
//#########################################################

/// Random sound - play a sound from a list with a prob per life tick
/datum/component/hallucination/random_sound
	var/list/sound_list
	var/sound_prob = 10
	var/min_distance = 0

	Initialize(timeout=30, sound_list=null, sound_prob=10, min_distance = 0)
		.=..()
		if(. == COMPONENT_INCOMPATIBLE || length(sound_list) == 0)
			return .
		src.sound_list = sound_list
		src.sound_prob = sound_prob
		src.min_distance = min_distance


	do_mob_tick(mob, mult)
		if(probmult(src.sound_prob))
			var/atom/origin = parent_mob.loc
			var/turf/mob_turf = get_turf(parent_mob)
			if (mob_turf)
				origin = locate(mob_turf.x + pick(rand(-10,-src.min_distance),rand(src.min_distance,10)), mob_turf.y + pick(rand(-10,-src.min_distance),rand(src.min_distance,10)), mob_turf.z)
			//wacky loosely typed code ahead
			var/datum/hallucinated_sound/chosen = pick(src.sound_list)
			if (istype(chosen)) //it's a datum
				chosen.play(parent_mob, origin)
			else //it's just a path directly
				parent_mob.playsound_local(origin, chosen, 100, 1)
		. = ..()

	CheckDupeComponent(timeout, sound_list, sound_prob, min_distance)
		if(sound_list ~= src.sound_list) //this is the same hallucination, just update timeout and prob
			if(timeout == -1)
				src.ttl = timeout
			else if(src.ttl != -1)
				src.ttl = world.time + timeout SECONDS //reset timeout
			src.sound_prob = sound_prob
			return TRUE //no duplicate
		else
			return FALSE //create a new hallucination

//#########################################################
//                    RANDOM IMAGE
//#########################################################

/// Random image - hallucinate an image on a visible tile with prob per life tick
/datum/component/hallucination/random_image
	var/list/image_list
	var/image_prob = 10
	var/image_time = 20

	Initialize(timeout=30, image_list=null, image_prob=10, image_time=20 SECONDS)
		. = ..()
		if(. == COMPONENT_INCOMPATIBLE || length(image_list) == 0)
			return .
		src.image_list = image_list
		src.image_prob = image_prob
		src.image_time = image_time

	do_mob_tick(mob, mult)
		if(probmult(image_prob))
			//pick a non dense turf in view
			var/list/turf/potentials = list()
			for(var/turf/T in view(parent_mob))
				if(!T.density)
					potentials += T
			var/turf/halluc_loc = pick(potentials)
			var/image/halluc = new /image()
			var/image/copyfrom = pick(src.image_list)
			halluc.appearance = copyfrom.appearance
			halluc.loc = halluc_loc
			parent_mob.client?.images += halluc
			SPAWN(src.image_time SECONDS)
				qdel(halluc)
		. = ..()

	CheckDupeComponent(timeout, image_list, image_prob, image_time)
		if(image_list ~= src.image_list) //this is the same hallucination, just update timeout and prob, time
			if(timeout == -1)
				src.ttl = timeout
			else if(src.ttl != -1)
				src.ttl = world.time + timeout SECONDS //reset timeout
			src.image_prob = image_prob
			src.image_time = image_time
			return TRUE //no duplicate
		else
			return FALSE //create a new hallucination

//#########################################################
//                    FAKE ATTACK
//#########################################################

/// Fake attack - hallucinate being attacked by something
/datum/component/hallucination/fake_attack
	var/list/image_list
	var/list/name_list
	var/attacker_prob = 10
	var/max_attackers = 5
	var/attacker_list = list()

	Initialize(timeout=30, image_list=null, name_list=null, attacker_prob=10, max_attackers=5)
		.=..()
		if(. == COMPONENT_INCOMPATIBLE)
			return .
		src.image_list = image_list
		src.name_list = name_list
		src.attacker_prob = attacker_prob
		src.max_attackers = max_attackers

	do_mob_tick(mob, mult)
		//I know it's kinda gross, but whatever
		for(var/obj/fake_attacker/fakey in src.attacker_list)
			if(fakey.disposed)
				src.attacker_list -= fakey
		if(length(attacker_list) >= src.max_attackers)
			return
		if(probmult(attacker_prob))
			var/obj/fake_attacker/F
			var/image/halluc
			if(isnull(image_list)) //if not specified, let's do a 50/50 of critters or humans
				var/list/possible_clones = new/list()
				for(var/mob/living/carbon/human/H in mobs)
					if (H.stat || H.lying || H.dir == NORTH || isrestrictedz(get_z(H))) continue
					possible_clones += H
				if(prob(50) && length(possible_clones)) //try for a human fake attacker
					var/mob/living/carbon/human/clone = null
					var/clone_weapon = null
					clone = pick(possible_clones)

					if (clone.l_hand)
						clone_weapon = clone.l_hand.name
					else if (clone.r_hand)
						clone_weapon = clone.r_hand.name

					F = new/obj/fake_attacker(parent_mob.loc, parent_mob)

					F.name = clone.name
					F.weapon_name = clone_weapon
					halluc = image(clone,F)
					F.client_image = halluc
					parent_mob.client?.images += halluc
				else //try for a predefined critter fake attacker
					var/faketype = pick(concrete_typesof(/obj/fake_attacker) - /obj/fake_attacker) //all but the base type
					F = new faketype(parent_mob.loc, parent_mob)

			else //image list isn't null, so create a fake attacker with that image
				F = new /obj/fake_attacker(parent_mob.loc, parent_mob)
				F.name = "attacker"
				halluc = image(pick(image_list), F)
				F.client_image = halluc
				parent_mob.client?.images += halluc

			if(!isnull(name_list))
				F.name = pick(name_list)
			src.attacker_list += F
		..()

	CheckDupeComponent(timeout, image_list, name_list, attacker_prob, max_attackers)
		if(image_list ~= src.image_list && name_list ~= src.name_list) //this is the same hallucination, just update timeout and prob
			if(timeout == -1)
				src.ttl = timeout
			else if(src.ttl != -1)
				src.ttl = world.time + timeout SECONDS //reset timeout
			src.attacker_prob = attacker_prob
			src.max_attackers = max_attackers
			return TRUE //no duplicate
		else
			return FALSE //create a new hallucination

//#########################################################
//                 RANDOM IMAGE OVERRIDE
//#########################################################

/// Random image override - hallucinate an image on a filtered atom either in or out of view in range with prob per life tick, with an option to add as overlay or replace the icon
/datum/component/hallucination/random_image_override
	var/list/image_list
	var/image_prob = 10
	var/image_time = 20
	var/list/target_list
	var/range = 5
	var/override = TRUE
	var/visible_creation = TRUE

	Initialize(timeout=30, image_list=null, target_list=null, range=5, image_prob=10, image_time=20 SECONDS, override=TRUE, visible_creation=TRUE)
		. = ..()
		if(. == COMPONENT_INCOMPATIBLE || length(image_list) == 0 || length(target_list) == 0)
			return .
		src.image_list = image_list
		src.image_prob = image_prob
		src.image_time = image_time
		src.range = range
		src.target_list = target_list
		src.override = override
		src.visible_creation = visible_creation

	do_mob_tick(mob,mult)
		if (!src.parent_mob.client)
			return ..()
		if(probmult(image_prob))
			//pick a non dense turf in view
			var/list/atom/potentials = list()
			if(src.visible_creation)
				for(var/atom/A in oview(parent_mob, src.range))
					for(var/type in src.target_list)
						if(istype(A, type))
							potentials += A
			else
				for(var/atom/A in (orange(parent_mob, src.range) - oview(parent_mob, src.range)))
					for(var/type in src.target_list)
						if(istype(A, type))
							potentials += A
			if(!length(potentials))
				return
			var/atom/halluc_loc = pick(potentials)
			var/image/copyfrom = pick(src.image_list)
			var/datum/component/halluc_image/component = halluc_loc.AddComponent(/datum/component/halluc_image, parent_mob.client, copyfrom, src.override)
			SPAWN(src.image_time SECONDS)
				component.RemoveComponent()
		. = ..()

	CheckDupeComponent(timeout, image_list, target_list, range, image_prob, image_time, override, visible_creation)
		if(image_list ~= src.image_list && src.target_list ~= target_list) //this is the same hallucination, just update timeout and prob, time
			if(timeout == -1)
				src.ttl = timeout
			else if(src.ttl != -1)
				src.ttl = world.time + timeout SECONDS //reset timeout
			src.range = range
			src.image_prob = image_prob
			src.image_time = image_time
			src.override = override
			return TRUE //no duplicate
		else
			return FALSE //create a new hallucination

/datum/component/halluc_image
	var/image/copyfrom
	var/client/viewer_client
	var/override = TRUE

	var/image/current_image

	Initialize(viewer_client, image/copyfrom, override = TRUE)
		. = ..()
		if(. == COMPONENT_INCOMPATIBLE)
			return .
		src.viewer_client = viewer_client
		src.copyfrom = copyfrom
		src.override = override

	RegisterWithParent()
		RegisterSignal(src.parent, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup_drop))
		RegisterSignal(src.parent, COMSIG_ITEM_DROPPED, PROC_REF(on_pickup_drop))
		src.make_image()

	UnregisterFromParent()
		UnregisterSignal(src.parent, COMSIG_ITEM_PICKUP)
		UnregisterSignal(src.parent, COMSIG_ITEM_DROPPED)

	proc/on_pickup_drop()
		SPAWN(0)
			src.make_image()

	proc/make_image()
		qdel(src.current_image)
		src.current_image = new /image()
		src.current_image.appearance = copyfrom.appearance
		src.current_image.loc = src.parent
		var/atom/movable/AM_parent = src.parent
		src.current_image.plane = AM_parent.plane
		src.current_image.layer = AM_parent.layer
		src.current_image.override = src.override
		src.viewer_client.images += src.current_image



//#########################################################
//                     FAKE SINGULO
//#########################################################

/// Fake singulo - hallucinate a loose singularity approaching you and eating the station
/datum/component/hallucination/fake_singulo
	var/obj/fake_singulo/my_singulo = null

	do_mob_tick(mob, mult)
		if(parent_mob.client && (QDELETED(my_singulo)) && prob(50))
			//pick a turf at the edge of the player's screen. Either all the way left/right + rand up/down, or all the way up/down + rand left/right
			var/start_turf = null
			var/bad_turf_count = 0
			var/viewsize = parent_mob.client.view
			if(!isnum(viewsize))
				viewsize = splittext(viewsize,"x")
				viewsize[1] = round(text2num(viewsize[1])/2)+1
				viewsize[2] = round(text2num(viewsize[2])/2)+1
			else
				viewsize = round(viewsize/2)+1
				viewsize = list(viewsize, viewsize)
			while(isnull(start_turf) && bad_turf_count < 10) //just in case we pick an invalid turf a bunch, don't hang the server
				var/x_offset = prob(50) ? (prob(50) ? -viewsize[1] : viewsize[1]) : rand(-viewsize[1],viewsize[1])
				var/y_offset = abs(x_offset) != viewsize[1] ? (prob(50) ? -viewsize[2] : viewsize[2]) : rand(-viewsize[2],viewsize[2])
				start_turf = locate(parent_mob.x + x_offset, parent_mob.y + y_offset, parent_mob.z)
				bad_turf_count++
			if(bad_turf_count >= 10)
				//failed to spawn, call that a runtime cos it's weird
				throw EXCEPTION("Failed to find a valid turf for fake singulo hallucination. That's weird, someone should investigate that. Hallucinator: [parent_mob] loc: [parent_mob?.loc]")
			my_singulo = new(start_turf,parent_mob,ttl)

		..()

	UnregisterFromParent()
		. = ..()
		UnregisterSignal(parent, COMSIG_LIVING_LIFE_TICK)
		if(parent_mob?.client && (!QDELETED(my_singulo)))
			qdel(my_singulo)



	CheckDupeComponent(timeout)
		..()
		return TRUE //only one of these please, just reset timeout

//#########################################################
//                    DISTANT EXPLOSION
//#########################################################

///Fake distant explosion and shake
/datum/component/hallucination/distant_explosion
	var/explosion_prob = 15
	var/cooldown_time = 7 SECONDS
	var/shake_duration = 8
	var/shake_strength = 24
	var/sound_volume = 70

	var/boom_cooldown = 0 //! Stored timestamp after which we can trigger a new boom

	Initialize(timeout, explosion_prob = 15, cooldown_time = 7 SECONDS, shake_duration = 8, shake_strength = 24, sound_volume = 70)
		. = ..()
		if(. == COMPONENT_INCOMPATIBLE)
			return .
		src.explosion_prob = explosion_prob
		src.cooldown_time = cooldown_time
		src.shake_duration = shake_duration
		src.shake_strength = shake_strength
		src.sound_volume = sound_volume

		src.boom_cooldown = world.time

	do_mob_tick(mob, mult)
		. = ..()
		if (world.time < boom_cooldown)
			return
		if(probmult(explosion_prob))
			boom_cooldown = world.time + src.boom_cooldown
			shake_camera(mob, src.shake_duration, src.shake_strength)
			parent_mob.playsound_local(parent_mob.loc, explosions.distant_sound, src.sound_volume, 0)

	CheckDupeComponent(timeout)
		..()
		return TRUE // do not stack these

//#########################################################
//                    SUPPORTING CAST
//#########################################################


/datum/hallucinated_sound
	///The sound file to play
	var/path
	///Max number of times to play it
	var/max_count
	///Min number of times to play it
	var/min_count
	///Delay between each play
	var/delay
	///Pitch to play it at
	var/pitch

	New(path, min_count = 1, max_count = 1, delay = 0, pitch = 1)
		..()
		src.path = path
		src.min_count = min_count
		src.max_count = max_count
		src.delay = delay
		src.pitch = pitch

	///Play the sound to a mob from a location
	proc/play(var/mob/mob, var/atom/location)
		SPAWN(0)
			for (var/i = 1 to rand(src.min_count, src.max_count))
				mob.playsound_local(location, src.path, 100, 1, pitch = src.pitch)
				sleep(src.delay)

/obj/fake_attacker
	icon = null
	icon_state = null
	var/fake_icon = 'icons/misc/critter.dmi'
	var/fake_icon_state = ""
	name = "thing"
	desc = ""
	density = 0
	anchored = ANCHORED
	opacity = 0
	var/mob/living/carbon/human/my_target = null
	var/weapon_name = null
	///Does this hallucination constantly whack you
	var/should_attack = TRUE
	event_handler_flags = USE_FLUID_ENTER
	var/stop_processing = FALSE
	var/image/client_image = null

	proc/get_name()
		return src.fake_icon_state

	pig
		fake_icon = 'icons/effects/hallucinations.dmi'
		fake_icon_state = "pig"
		get_name()
			return pick("pig", "DAT FUKKEN PIG")
	spider
		fake_icon = 'icons/effects/hallucinations.dmi'
		fake_icon_state = "spider"
		get_name()
			return pick("giant black widow", "aw look a spider", "OH FUCK A SPIDER")
	slime
		fake_icon = 'icons/effects/hallucinations.dmi'
		fake_icon_state = "slime"
		get_name()
			return pick("red slime", "some gooey thing", "ANGRY CRIMSON POO")
	shambler
		fake_icon = 'icons/effects/hallucinations.dmi'
		fake_icon_state = "shambler"
		get_name()
			return pick("shambler", "strange creature", "OH GOD WHAT THE FUCK IS THAT THING?")
	legworm
		fake_icon_state = "legworm"
	handspider
		fake_icon_state = "handspider"

	eyespider
		fake_icon_state = "eyespider"
	buttcrab
		fake_icon_state = "buttcrab"
		should_attack = FALSE
	bat
		fake_icon_state = "bat"
		get_name()
			return pick("bat", "batty", "the roundest possible bat", "the giant bat that makes all of the rules")
	snake
		fake_icon_state = "rattlesnake"
		get_name()
			return pick("snek", "WHY DID IT HAVE TO BE SNAKES?!", "rattlesnake", "OH SHIT A SNAKE")
	scorpion
		fake_icon_state = "spacescorpion"
		get_name()
			return "space scorpion"
	aberration
		fake_icon_state = "aberration"
		should_attack = FALSE
		get_name()
			return "transposed particle field"
	capybara
		fake_icon_state = "capybara"
		should_attack = FALSE
	frog
		fake_icon_state = "frog"
		should_attack = FALSE
	realistic_pig
		fake_icon_state = "pig"
		should_attack = FALSE
		get_name()
			return pick("pogg borbis", "oinkers", "mr pig", "pig", "space pig", "sir baconsly von hampton")
	hogg_vorbis
		fake_icon_state = "hogg"
		should_attack = TRUE
		get_name()
			return "hogg vorbis"

	disposing()
		my_target = null
		. = ..()

/obj/fake_attacker/New(location, target)
	..()
	SPAWN(30 SECONDS)
		qdel(src)
	src.name = src.get_name()
	src.my_target = target
	if (src.fake_icon && src.fake_icon_state)
		src.client_image = image(icon = src.fake_icon, loc = src, icon_state = src.fake_icon_state)
		src.client_image.override = TRUE
		target << src.client_image
	step_away(src,my_target,2)
	process()

/obj/fake_attacker/disposing()
	if(src.client_image && my_target)
		my_target.client?.images -= src.client_image
	qdel(src.client_image)
	. = ..()


/obj/fake_attacker/proc/process()
	if (!my_target)
		qdel(src)
		return
	if(stop_processing)
		return
	if (BOUNDS_DIST(src, my_target) > 0)
		step_towards(src,my_target)
	else
		if (src.should_attack && prob(70) && !ON_COOLDOWN(src, "fake_attack_cooldown", 1.5 SECONDS))
			if (weapon_name)
				my_target.playsound_local(my_target.loc, "sound/impact_sounds/Generic_Hit_[rand(1, 3)].ogg", 40, 1)
				my_target.show_message(SPAN_COMBAT("<B>[my_target] has been attacked with [weapon_name] by [src.name] </B>"), 1)
				if (prob(20)) my_target.change_eye_blurry(3)
				if (prob(33))
					if (!locate(/obj/overlay) in my_target.loc)
						fake_blood(my_target)
			else
				my_target.playsound_local(my_target.loc, pick(sounds_punch), 40, 1)
				my_target.show_message(SPAN_COMBAT("<B>[src.name] has punched [my_target]!</B>"), 1)
				if (prob(33))
					if (!locate(/obj/overlay) in my_target.loc)
						fake_blood(my_target)
			attack_twitch(src)

	if (src.should_attack && prob(10)) step_away(src,my_target,2)
	SPAWN(0.3 SECONDS)
		src.process()

/obj/fake_attacker/attack_hand(mob/M)
	src.attackby(null, M)

/obj/fake_attacker/attackby(obj/item/W, mob/M)
	playsound(loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 50, TRUE, 1) //the swishy sound of swinging your fist through air
	for(var/mob/witness in oviewers(world.view,my_target))
		boutput(witness, SPAN_ALERT("<B>[my_target] flails around wildly[W ? " with [W]" : ""].</B>"))
	if(stop_processing)
		return
	if(prob(50))
		//wibbly mirage fade
		my_target.show_message(SPAN_ALERT("<B>[W ? "[W]":"Your hand"] passes through [src] as it disappears."))
		src.stop_processing = TRUE
		mirage_fadeout(2 SECONDS)
		SPAWN(5 SECONDS) //this gives a few extra seconds between fadeout and delete so you get a respite from a new one spawning
			qdel(src)
	else
		step_away(src,my_target,2)
		my_target.show_message(SPAN_COMBAT("<b>[src] narrowly dodges [my_target]'s attack!"))

/obj/fake_attacker/proc/mirage_fadeout(time=2 SECONDS)
	if(src.client_image)
		//gotta do it like this because /image is not /atom and so filter management no work
		var/filter_params = wave_filter(x=0, size=2, flags=WAVE_BOUNDED|WAVE_SIDEWAYS)
		src.client_image.filters += filter(arglist(filter_params))
		animate(src.client_image.filters[length(src.client_image.filters)], x=5, time=time, loop=-1, flags=ANIMATION_PARALLEL)
		animate(src, time=time, loop=-1, alpha=0, flags=ANIMATION_PARALLEL)

/obj/fake_attacker/Crossed(atom/movable/M)
	..()
	if(stop_processing)
		return
	if (M == my_target)
		step_away(src,my_target,2)
		if (prob(30))
			for(var/mob/O in oviewers(world.view , my_target))
				boutput(O, SPAN_ALERT("<B>[my_target] stumbles around.</B>"))

/obj/fake_singulo
	name = "gravitational singularity"
	desc = "Perhaps the densest thing in existence, except for you."
	icon = null
	icon_state = null
	density = 0
	var/list/my_image_overrides = list()
	var/list/eaten_atoms = list()
	var/mob/my_target = null
	var/spaget_count = 0
	var/right_spinning = 0

/obj/fake_singulo/New(var/loc, var/mob/target, var/ttl = 60 SECONDS)
	..()
	SPAWN(ttl)
		qdel(src)
	src.right_spinning = prob(50)
	src.my_target = target
	var/image/client_image = image(icon = 'icons/effects/64x64.dmi', icon_state = "whole", loc = src)
	client_image.override = TRUE
	client_image.plane = PLANE_DEFAULT_NOWARP
	var/image/lense = image(icon='icons/effects/overlays/lensing.dmi', icon_state="lensing_med_hole", pixel_x = -208, pixel_y = -208, loc = src)
	lense.plane = PLANE_DISTORTION
	lense.blend_mode = BLEND_OVERLAY
	lense.appearance_flags = RESET_ALPHA | RESET_COLOR
	src.my_image_overrides += client_image
	src.my_image_overrides += lense
	target << client_image
	target << lense
	process()

/obj/fake_singulo/disposing()
	if(src.my_image_overrides && my_target?.client)
		for(var/client_image in src.my_image_overrides)
			my_target.client?.images -= client_image
			qdel(client_image)
	qdel(src.my_image_overrides) //not really necessary, but why not
	qdel(src.eaten_atoms)
	. = ..()


/obj/fake_singulo/proc/process()
	var/target_dist = get_dist(src, src.my_target)
	if(target_dist > 20) //if offscreen by a good amount
		qdel(src)
		return
	else if(target_dist < 6)
		//oh no you're being pulled into the singularity!
		if(prob(50))
			src.my_target.step_towards_movedelay(src) //respect standard movements, this isn't actual gravity, you're just stepping cos you're hallucinating

	//otherwise, we're pretending to be a singularity
	if(prob(30))
		step(src, pick(cardinal))
	else
		step_towards(src, src.my_target) //oh god it's chasing me!

	//"eat" stuff by overriding its icon with a blank icon state
	for (var/atom/A in range(3, src))
		if (!A)
			continue
		if (A == src)
			continue

		if (A.event_handler_flags & IMMUNE_SINGULARITY)
			continue

		if (A.event_handler_flags & IMMUNE_SINGULARITY_INACTIVE)
			continue

		if (!isarea(A))
			if(IN_EUCLIDEAN_RANGE(src, A, 2.5))
				if (A == src.my_target) //gotcha!
					if(!ON_COOLDOWN(src.my_target, "fake_singulo_scream", 5 SECONDS))
						src.my_target.emote("scream", FALSE)
					src.my_target.changeStatus("knockdown", 2 SECONDS)
					src.my_target.changeStatus("stunned", 2 SECONDS)
					SPAWN(5 SECONDS)
						qdel(src)

				if(A in src.eaten_atoms)
					continue
				//this is a thing we're going to eat, so blank client image override for you
				var/image/blank_image = image(loc = A)
				blank_image.override = TRUE
				src.my_image_overrides += blank_image
				src.eaten_atoms += A
				src.my_target << blank_image
				//for the spinny falling in animations. low count for performance
				//this is almost a straight copy/paste from singulo code
				if(src.spaget_count < 3 || A == src.my_target) //always show the mob getting spaget'd
					src.spaget_count++
					animate_spaghettification(A, src, 15 SECONDS, right_spinning, src.my_target.client)
					SPAWN(16 SECONDS)
						src.spaget_count--

	SPAWN(1 SECOND)
		process()

/obj/fake_singulo/Move(NewLoc, direct)
	. = ..()
	if (NewLoc) //we can always move, because we're not real
		src.set_dir(get_dir(loc, NewLoc))
		src.set_loc(NewLoc)

///Helper procs

/proc/fake_blood(var/mob/target)
	var/obj/overlay/O = new/obj/overlay(target.loc)
	O.name = "blood"
	var/image/I = image('icons/obj/decals/blood/blood.dmi',O,"floor[rand(1,7)]",O.dir,1)
	target << I
	SPAWN(30 SECONDS)
		qdel(O)

/proc/fake_attack(var/mob/target)
	var/list/possible_clones = new/list()
	var/mob/living/carbon/human/clone = null
	var/clone_weapon = null

	for(var/mob/living/carbon/human/H in mobs)
		if (H.stat || H.lying || H.dir == NORTH) continue
		possible_clones += H

	if (!possible_clones.len) return
	clone = pick(possible_clones)

	if (clone.l_hand)
		clone_weapon = clone.l_hand.name
	else if (clone.r_hand)
		clone_weapon = clone.r_hand.name

	var/obj/fake_attacker/F = new/obj/fake_attacker(target.loc, target)

	F.name = clone.name
	F.weapon_name = clone_weapon

	var/image/O = image(clone,F)
	target << O

