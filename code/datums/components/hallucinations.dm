TYPEINFO(/datum/component/hallucination/trippy_colors)
	initialization_args = list(
		ARG_INFO("timeout", DATA_INPUT_NUM, "how long this hallucination lasts in seconds. -1 for permanent", 30),
	)

TYPEINFO(/datum/component/hallucination/random_sound)
	initialization_args = list(
		ARG_INFO("timeout", DATA_INPUT_NUM, "how long this hallucination lasts in seconds. -1 for permanent", 30),
		ARG_INFO("sound_list", DATA_INPUT_LIST_BUILD, "List of sounds that the mob can hallucinate appearing."),
		ARG_INFO("sound_prob", DATA_INPUT_NUM, "probability of a sound being played per mob life tick", 10),
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
	)


/////////////////////////////////////////////////////////////
//                HALLUCINATION COMPONENTS
/////////////////////////////////////////////////////////////


///Generic hallucination effects - subclass for fancy effects
ABSTRACT_TYPE(/datum/component/hallucination)
/datum/component/hallucination
	dupe_mode = COMPONENT_DUPE_ALLOWED//you can have lots of hallucinations
	///expiry time, -1 means never
	var/ttl = 0
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

/////////////////////////////////////////////////////////////
//                    TRIPPY COLORS
/////////////////////////////////////////////////////////////


/// Trippy colors - apply an RGB swap to client's vision
/datum/component/hallucination/trippy_colors
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS //you can only have one of these, but refresh the timeout
	var/current_color_pattern = 0
	var/pattern1 = list(0,0,1,0, 1,0,0,0, 0,1,0,0, 0,0,0,1, 0,0,0,0)
	var/pattern2 = list(0,1,0,0, 0,0,1,0, 1,0,0,0, 0,0,0,1, 0,0,0,0)

	Initialize(timeout=30)
		if(src.timeout == -1)
			return //if timeout is already infinite and this is a dupe, just do nothing
		else
			.=..()

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


/////////////////////////////////////////////////////////////
//                    RANDOM SOUNDS
/////////////////////////////////////////////////////////////

/// Random sound - play a sound from a list with a prob per life tick
/datum/component/hallucination/random_sound
	var/list/sound_list
	var/sound_prob = 10

	Initialize(timeout=30, sound_list=null, sound_prob=10)
		.=..()
		if(. == COMPONENT_INCOMPATIBLE || length(sound_list) == 0)
			return .
		src.sound_list = sound_list
		src.sound_prob = sound_prob


	do_mob_tick(mob, mult)
		if(probmult(src.sound_prob))
			var/atom/origin = parent_mob.loc
			var/turf/mob_turf = get_turf(parent_mob)
			if (mob_turf)
				origin = locate(mob_turf.x + rand(-10,10), mob_turf.y + rand(-10,10), mob_turf.z)
			//wacky loosely typed code ahead
			var/datum/hallucinated_sound/chosen = pick(src.sound_list)
			if (istype(chosen)) //it's a datum
				chosen.play(parent_mob, origin)
			else //it's just a path directly
				parent_mob.playsound_local(origin, chosen, 100, 1)
		. = ..()

/////////////////////////////////////////////////////////////
//                    RANDOM IMAGE
/////////////////////////////////////////////////////////////

/// Random image - hallucinate an image on a visible tile with prob per life tick
/datum/component/hallucination/random_image
	var/list/image_list
	var/image_prob = 10
	var/image_time = 20 SECONDS
	Initialize(timeout=30, image_list=null, image_prob=10, image_time=20 SECONDS)
		.=..()
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
				if(T.density == 0)
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


/////////////////////////////////////////////////////////////
//                    FAKE ATTACK
/////////////////////////////////////////////////////////////

/// Fake attack - hallucinate being attacked by something
/datum/component/hallucination/fake_attack
	var/list/image_list
	var/list/name_list
	var/attacker_prob = 10
	Initialize(timeout=30, image_list=null, name_list=null, attacker_prob=10)
		.=..()
		if(. == COMPONENT_INCOMPATIBLE)
			return .
		src.image_list = image_list
		src.name_list = name_list
		src.attacker_prob = attacker_prob

	do_mob_tick(mob, mult)
		if(probmult(attacker_prob))
			var/obj/fake_attacker/F
			var/image/halluc
			if(isnull(image_list)) //if not specified, let's do a 50/50 of critters or humans
				var/list/possible_clones = new/list()
				for(var/mob/living/carbon/human/H in mobs)
					if (H.stat || H.lying || H.dir == NORTH) continue
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
					parent_mob.client?.images += halluc
				else //try for a predefined critter fake attacker
					var/faketype = pick(concrete_typesof(/obj/fake_attacker) - /obj/fake_attacker) //all but the base type
					F = new faketype(parent_mob.loc, parent_mob)

			else //image list isn't null, so create a fake attacker with that image
				F = new /obj/fake_attacker(parent_mob.loc, parent_mob)
				F.name = "attacker"
				halluc = image(pick(image_list), F)
				parent_mob.client?.images += halluc

			if(!isnull(name_list))
				F.name = pick(name_list)
		..()


/////////////////////////////////////////////////////////////
//                 RANDOM IMAGE OVERRIDE
/////////////////////////////////////////////////////////////

/// Random image override - hallucinate an image on a filtered atom in view with prob per life tick, with an option to add as overlay or replace the icon
/datum/component/hallucination/random_image_override
	var/list/image_list
	var/image_prob = 10
	var/image_time = 20 SECONDS
	var/list/target_list
	var/range = 5
	var/override = TRUE
	Initialize(timeout=30, image_list=null, target_list=null, range=5, image_prob=10, image_time=20 SECONDS, override=TRUE)
		.=..()
		if(. == COMPONENT_INCOMPATIBLE || length(image_list) == 0 || length(target_list) == 0)
			return .
		src.image_list = image_list
		src.image_prob = image_prob
		src.image_time = image_time
		src.range = range
		src.target_list = target_list
		src.override = override


	do_mob_tick(mob,mult)
		if(probmult(image_prob))
			//pick a non dense turf in view
			var/list/atom/potentials = list()
			for(var/atom/A in view(parent_mob, range))
				if(A.type in src.target_list)
					potentials += A
			var/atom/halluc_loc = pick(potentials)
			var/image/halluc = new /image()
			var/image/copyfrom = pick(src.image_list)
			halluc.appearance = copyfrom.appearance
			halluc.loc = halluc_loc
			halluc.override = src.override
			parent_mob.client?.images += halluc
			SPAWN(src.image_time SECONDS)
				qdel(halluc)
		. = ..()


/////////////////////////////////////////////////////////////
//                    SUPPORTING CAST
/////////////////////////////////////////////////////////////


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
	name = ""
	desc = ""
	density = 0
	anchored = ANCHORED
	opacity = 0
	var/mob/living/carbon/human/my_target = null
	var/weapon_name = null
	///Does this hallucination constantly whack you
	var/should_attack = TRUE
	event_handler_flags = USE_FLUID_ENTER

	proc/get_name()
		return src.fake_icon_state

	pig
		fake_icon = 'icons/effects/hallucinations.dmi'
		fake_icon_state = "pig"
		get_name()
			return pick("pig", "DAT FUKKEN PIG")
	spider
		fake_icon_state = "big_spide"
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

	disposing()
		my_target = null
		. = ..()

/obj/fake_attacker/attackby()
	step_away(src,my_target,2)
	for(var/mob/M in oviewers(world.view,my_target))
		boutput(M, "<span class='alert'><B>[my_target] flails around wildly.</B></span>")
	my_target.show_message("<span class='alert'><B>[src] has been attacked by [my_target] </B></span>", 1) //Lazy.
	return

/obj/fake_attacker/Crossed(atom/movable/M)
	..()
	if (M == my_target)
		step_away(src,my_target,2)
		if (prob(30))
			for(var/mob/O in oviewers(world.view , my_target))
				boutput(O, "<span class='alert'><B>[my_target] stumbles around.</B></span>")


/obj/fake_attacker/New(location, target)
	..()
	SPAWN(30 SECONDS)	qdel(src)
	src.name = src.get_name()
	src.my_target = target
	if (src.fake_icon && src.fake_icon_state)
		var/image/image = image(icon = src.fake_icon, loc = src, icon_state = src.fake_icon_state)
		image.override = TRUE
		target << image
	step_away(src,my_target,2)
	process()

/obj/fake_attacker/proc/process()
	if (!my_target)
		qdel(src)
		return
	if (BOUNDS_DIST(src, my_target) > 0)
		step_towards(src,my_target)
	else
		if (src.should_attack && prob(70) && !ON_COOLDOWN(src, "fake_attack_cooldown", 1 SECOND))
			if (weapon_name)
				if (narrator_mode)
					my_target.playsound_local(my_target.loc, 'sound/vox/weapon.ogg', 40, 0)
				else
					my_target.playsound_local(my_target.loc, "sound/impact_sounds/Generic_Hit_[rand(1, 3)].ogg", 40, 1)
				my_target.show_message("<span class='alert'><B>[my_target] has been attacked with [weapon_name] by [src.name] </B></span>", 1)
				if (prob(20)) my_target.change_eye_blurry(3)
				if (prob(33))
					if (!locate(/obj/overlay) in my_target.loc)
						fake_blood(my_target)
			else
				if (narrator_mode)
					my_target.playsound_local(my_target.loc, 'sound/vox/hit.ogg', 40, 0)
				else
					my_target.playsound_local(my_target.loc, pick(sounds_punch), 40, 1)
				my_target.show_message("<span class='alert'><B>[src.name] has punched [my_target]!</B></span>", 1)
				if (prob(33))
					if (!locate(/obj/overlay) in my_target.loc)
						fake_blood(my_target)
			attack_twitch(src)

	if (src.should_attack && prob(10)) step_away(src,my_target,2)
	SPAWN(0.3 SECONDS) .()

/proc/fake_blood(var/mob/target)
	var/obj/overlay/O = new/obj/overlay(target.loc)
	O.name = "blood"
	var/image/I = image('icons/obj/decals/blood/blood.dmi',O,"floor[rand(1,7)]",O.dir,1)
	target << I
	SPAWN(30 SECONDS)
		qdel(O)
	return

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
	//F.my_target = target
	F.weapon_name = clone_weapon

	var/image/O = image(clone,F)
	target << O

/*
/datum/component/hallucinations/proc/on_mob_life(var/mob/M, var/mult = 1)

				if(probmult(12) && !ON_COOLDOWN(M, "hallucination_spawn", 30 SECONDS)) //spawn a fake critter
					if (prob(20))
						if(prob(60))
							fake_attack(M)
						else
							var/monkeys = rand(1,3)
							for(var/i = 0, i < monkeys, i++)
								fake_attackEx(M, 'icons/mob/monkey.dmi', "monkey_hallucination", pick_string_autokey("names/monkey.txt"))
					else
						var/fake_type = pick(childrentypesof(/obj/fake_attacker))
						new fake_type(M.loc, M)
				//THE VOICES GET LOUDER

				if(probmult(8)) //display a random chat message
					M.playsound_local(M.loc, pick(src.speech_sounds, 100, 1))
					boutput(M, "<b>[pick(src.voice_names)]</b> says, \"[phrase_log.random_phrase("say")]\"")
				if(probmult(10)) //turn someone into a critter

				..()
				return

on_mob_life(var/mob/M, var/mult = 1)
				. = ..()
				var/poison_amount = holder?.get_reagent_amount(src.id) // need to check holder as the reagent could be fully removed in the parent call
				if(poison_amount > 5)
					for(var/obj/item/I in oview(M,5))
						if(probmult(2))
							var/image/mimicface = image(icon('icons/misc/critter.dmi',"mimicface"))
							mimicface.loc = I
							mimicface.blend_mode = BLEND_INSET_OVERLAY
							var/client/client = M.client //hold a reference to the client directly
							client?.images.Add(mimicface)
							if(prob(25))
								M.show_message("[I] suddenly opens eyes that weren't there and sprouts teeth!", 1)
							SPAWN (10 SECONDS)
								client?.images.Remove(mimicface)
								qdel(mimicface)


datum/ailment/disease/space_madness/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	if(affected_mob.job == "Clown")
		if(probmult(6))
			var/icp = pick("Fuckin' magnets!", "Fuckin' rainbows!", "Magic everywhere...", "Pure motherfuckin' miracles!", "Magic all around you and you don't even know it!")
			affected_mob.say("[icp]")
			return
	switch(D.stage)
		if(2)
			if (probmult(10))
				boutput(affected_mob, pick("<span class='alert'><i><b><font face =Tempus Sans ITC>Kill them all!!!!!</b></i></FONT></span>", "<span class='alert'><i><b><font face = Tempus Sans ITC>They are out to get you!</b></FONT></i></span>", "<span class='alert'><i><b><font face = Tempus Sans ITC>They know what you did!!!!</b></FONT></i></span>", "<span class='alert'><i><b><font face = Tempus Sans ITC>They are watching you!!!</b></i></FONT></span>"))
		if(3)
			if (probmult(8))
				for (var/mob/living/M in view(7,affected_mob))
					if(M!= affected_mob)
						boutput(affected_mob, "<b>[M.name]</b> says, \"[pick("I'm going to kill you!","I'm the the traitor.", "TRAITOR!")]\"")
						break
			if (probmult(9))
				boutput(affected_mob, pick("<span class='alert'><i><b><font face =Tempus Sans ITC>Kill them all!!!!!</b></i></FONT></span>", "<span class='alert'><i><b><font face = Tempus Sans ITC>They are out to get you!</b></FONT></i></span>", "<span class='alert'><i><b><font face = Tempus Sans ITC>They know what you did!!!!</b></FONT></i></span>", "<span class='alert'><i><b><font face = Tempus Sans ITC>They are watching you!!!</b></i></FONT></span>"))

		if(4)
			if(probmult(5))
				switch(rand(1,2))
					if(1)
						if(prob(50))
							fake_attack(affected_mob)
						else
							var/monkeys = rand(1,3)
							for(var/i = 0, i < monkeys, i++)
								fake_attackEx(affected_mob, 'icons/mob/monkey.dmi', "monkey1", "monkey ([rand(1, 1000)])")
					if(2)
						var/halluc_state = null
						var/halluc_name = null
						switch(rand(1,5))
							if(1)
								halluc_state = "pig"
								halluc_name = pick("pig", "DAT FUKKEN PIG")
							if(2)
								halluc_state = "spider"
								halluc_name = pick("giant black widow", "aw look a spider", "OH FUCK A SPIDER")
							if(3)
								halluc_state = "dragon"
								halluc_name = pick("dragon", "Lord Cinderbottom", "SOME FUKKEN LIZARD THAT BREATHES FIRE")
							if(4)
								halluc_state = "slime"
								halluc_name = pick("red slime", "some gooey thing", "ANGRY CRIMSON POO")
							if(5)
								halluc_state = "shambler"
								halluc_name = pick("shambler", "strange creature", "OH GOD WHAT THE FUCK IS THAT THING?")
						fake_attackEx(affected_mob, 'icons/effects/hallucinations.dmi', halluc_state, halluc_name)
			if(probmult(9))
				affected_mob.playsound_local(affected_mob.loc, pick("explosion", "punch", 'sound/vox/poo-vox.ogg', "clownstep", 'sound/weapons/armbomb.ogg', 'sound/weapons/Gunshot.ogg'), 50, 1)

			if (probmult(8))
				for (var/mob/living/M in view(7,affected_mob))
					if(M!= affected_mob)
						boutput(affected_mob, "<b>[M.name]</b> says, \"[pick("I'm going to kill you!","I'm the the traitor.", "You are a loser!")]\"")
						break

		if(5)
			if(probmult(5))
				switch(rand(1,2))
					if(1)
						if(prob(50))
							fake_attack(affected_mob)
						else
							var/monkeys = rand(1,3)
							for(var/i = 0, i < monkeys, i++)
								fake_attackEx(affected_mob, 'icons/mob/monkey.dmi', "monkey1", "monkey ([rand(1, 1000)])")
					if(2)
						var/halluc_state = null
						var/halluc_name = null
						switch(rand(1,5))
							if(1)
								halluc_state = "pig"
								halluc_name = pick("pig", "DAT FUKKEN PIG")
							if(2)
								halluc_state = "spider"
								halluc_name = pick("giant black widow", "aw look a spider", "OH FUCK A SPIDER")
							if(3)
								halluc_state = "dragon"
								halluc_name = pick("dragon", "Lord Cinderbottom", "SOME FUKKEN LIZARD THAT BREATHES FIRE")
							if(4)
								halluc_state = "slime"
								halluc_name = pick("red slime", "some gooey thing", "ANGRY CRIMSON POO")
							if(5)
								halluc_state = "shambler"
								halluc_name = pick("shambler", "strange creature", "OH GOD WHAT THE FUCK IS THAT THING?")
						fake_attackEx(affected_mob, 'icons/effects/hallucinations.dmi', halluc_state, halluc_name)
			if(probmult(9))
				affected_mob.playsound_local(affected_mob.loc, pick("explosion", "punch", 'sound/vox/poo-vox.ogg', "clownstep", 'sound/weapons/armbomb.ogg', 'sound/weapons/Gunshot.ogg'), 50, 1)

			if (probmult(8))
				for (var/mob/living/M in view(7,affected_mob))
					if(M!= affected_mob)
						boutput(affected_mob, "<b>[M.name]</b> says, \"[pick("I'm going to kill you!","I'm the the traitor.", "You are a loser!")]\"")
						break


datum/pathogeneffects/malevolent/serious_paranoia
	name = "Serious Paranoia"
	desc = "The infected is seriously suspicious of others, to the point where they might see others do traitorous things."
	infect_type = INFECT_NONE
	rarity = RARITY_RARE
	var/static/list/hallucinated_images = list(/obj/item/sword, /obj/item/card/emag, /obj/item/cloaking_device)
	var/static/list/traitor_items = list("cyalume saber", "Electromagnetic Card", "pen", "mini rad-poison crossbow", "cloaking device", "revolver", "butcher's knife", "amplified vuvuzela", "power gloves", "signal jammer")

	proc/trader(var/mob/M as mob, var/mob/living/O as mob)
		var/action = "says"
		if (issilicon(O))
			action = "states"
		var/what = pick("I am the traitor.", "I will kill you.", "You will die, [M].")
		if (prob(50))
			boutput(M, "<B>[O]</B> points at [M].")
			make_point(M)
		boutput(M, "<B>[O]</B> [action], \"[what]\"")

	proc/backpack(var/mob/M, var/mob/living/O)
		var/item = pick(traitor_items)
		boutput(M, "<span class='notice'>[O] has added the [item] to the backpack!</span>")
		logTheThing(LOG_PATHOLOGY, M, "saw a fake message about an [constructTarget(O,"pathology")] adding [item] to their backpacks due to Serious Paranoia symptom.")

	proc/acidspit(var/mob/M, var/mob/living/O, var/mob/living/O2)
		if (O2)
			boutput(M, "<span class='alert'><B>[O] spits acid at [O2]!</B></span>")
		else
			boutput(M, "<span class='alert'><B>[O] spits acid at you!</B></span>")
		logTheThing(LOG_PATHOLOGY, M, "saw a fake message about an [constructTarget(O,"pathology")] spitting acid due to Serious Paranoia symptom.")

	proc/vampirebite(var/mob/M, var/mob/living/O, var/mob/living/O2)
		if (O2)
			boutput(M, "<span class='alert'><B>[O] bites [O2]!</B></span>")
		else
			boutput(M, "<span class='alert'><B>[O] bites you!</B></span>")
		logTheThing(LOG_PATHOLOGY, M, "saw a fake message about an [constructTarget(O,"pathology")] biting someone due to Serious Paranoia symptom.")

	proc/floor_in_view(var/mob/M)
		var/list/ret = list()
		for (var/turf/simulated/floor/T in view(M, 7))
			ret += T
		return ret

	proc/hallucinate_item(var/mob/M)
		var/item = pick(hallucinated_images)
		var/obj/item_inst = new item()
		var/list/LF = floor_in_view(M)
		if(!LF.len) return
		var/obj/hallucinated_item/H = new /obj/hallucinated_item(pick(floor_in_view(M)), M, item_inst)
		var/image/hallucinated_image = image(item_inst, H)
		M << hallucinated_image
*/
