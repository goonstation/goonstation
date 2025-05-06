#define PARROT_MAX_WORDS 64		// may as well try and be careful I guess
#define PARROT_MAX_PHRASES 32	// doesn't hurt, does it?

TYPEINFO(/obj/critter/parrot)
	start_listen_effects = list(LISTEN_EFFECT_PARROT)
	start_listen_inputs = list(LISTEN_INPUT_OUTLOUD)
	start_speech_modifiers = null
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN)

/obj/critter/parrot // if you didn't want me to make a billion dumb parrot things you shouldn't have let me anywhere near the code so this is YOUR FAULT NOT MINE - Haine
	name = "space parrot"
	desc = "A spacefaring species of parrot."
	icon = 'icons/misc/bird.dmi'
	icon_state = "parrot"
	dead_state = "parrot-dead"
	density = 0
	health = 15
	aggressive = 0
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE // this was funny for a while but now is less so
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	angertext = "squawks angrily at"
	death_text = "%src% lets out a final weak squawk and keels over."
	chase_text = "flails into"
	butcherable = BUTCHER_ALLOWED
	flying = 1
	health_gain_from_food = 2
	feed_text = "chirps happily!"
	flags = CONDUCT | USEDELAY | TABLEPASS | FLUID_SUBMERGE

	speech_verb_say = list("chatters", "chirps", "squawks", "mutters", "cackles", "mumbles")
	default_speech_output_channel = SAY_CHANNEL_OUTLOUD

	var/species = "parrot"						// the species, used to update icon
	var/list/learned_words = null				// the single words that the bird knows
	var/list/learned_phrases = null				// ^^^ for complete phrases
	var/learn_words_chance = 33					// chance to learn new single words each time speech is heard
	var/learn_phrase_chance = 10				// ^^^ for complete phrases
	var/signing_learn_boost = 33				// increased chance for learning word or phrase when sung
	var/learn_words_max = PARROT_MAX_WORDS		// max amount of single words the learned_words list can have, if this limit is reached the bird will have a random chance to replace some of its old words to learn the new ones, set to -1 for infinite
	var/learn_phrase_max = PARROT_MAX_PHRASES	// ^^^ for complete phrases
	var/chatter_chance = 6						// chance to say something per ai cycle
	var/obj/item/treasure = null				// currently held item
	var/obj/item/new_treasure = null			// item sought to hold
	var/turf/treasure_loc = null				// location of sought item
	var/find_treasure_chance = 2				// chance to look for items to hold
	var/destroys_treasure = 0					// does the bird do excessive violence upon the thing it's holding and break it sometimes?  for keas atm
	var/being_offered_treasure = 0				// is someone already trying to give the bird something?  this is used so you can't sit there and do weird shit with the SPAWN(0) that happens when trying to give the bird something  :v
	var/impatience = 0							// used when looking for items, so birds don't wander across the entire map trying to find a thing they saw ages ago
	var/can_fussle = 1							// can they mess with items?
	var/hops = 0								// bouncy bird
	var/sells_furniture = 0						// this is the stupidest var I've ever had to make I think. only for the space ikea
	var/hat_offset_y = -5						// how far to offset hats by to have them show up on birb
	var/hat_offset_x = 0						// same as above but for x axis
	var/feather_color = "#ba1418"				// color(s) of feathers the bird can randomly spawn
	var/last_feather_time = 0					// last world time a feather was spawned

	New(loc, nspecies)
		..()
		if (nspecies)
			src.apply_species(nspecies, 0)

	get_desc()
		..()
		if (src.treasure)
			. += "<br>[src] is holding \a [src.treasure]."

	proc/learn_stuff(var/message, var/learn_phrase = 0)
		if (!message)
			return
		if (!islist(src.learned_words))
			src.learned_words = list()
		if (!islist(src.learned_phrases))
			src.learned_phrases = list()

		if (!learn_phrase && src.learn_words_max > 0 && length(src.learned_words) >= src.learn_words_max)
			if (prob(5))
				var/dump_word = pick(src.learned_words)
				src.learned_words -= dump_word
			else
				return
		if (learn_phrase && src.learn_phrase_max > 0 && length(src.learned_phrases) >= src.learn_phrase_max)
			if (prob(5))
				var/dump_phrase = pick(src.learned_phrases)
				src.learned_phrases -= dump_phrase
			else
				return

		if (learn_phrase)
			src.learned_phrases += message
		var/list/heard_stuff = splittext(message, " ")
		DEBUG_MESSAGE("[src]: list of words is: [english_list(heard_stuff)]")

		for (var/word in heard_stuff)
			DEBUG_MESSAGE("[src] processing word: [word]")
			if (copytext(word, -1) in list(".", ",", "!", "?"))
				word = copytext(word, 1, -1)
			if (word in src.learned_words)
				heard_stuff -= word
			if (!length(word)) // idk how things were ending up with blank words but um
				heard_stuff -= word // hopefully this will stop that??
		DEBUG_MESSAGE("[src]: list of words after processing is: [english_list(heard_stuff)]")

		if (!heard_stuff.len)
			return
		var/learning_word = pick(heard_stuff)
		src.learned_words += learning_word
		DEBUG_MESSAGE("[src]: chosen word: [learning_word]")

	proc/chatter(var/sing=0)
		var/thing_to_say = ""
		if (islist(src.learned_phrases) && src.learned_phrases.len && prob(20))
			thing_to_say = pick(src.learned_phrases)
		else if (islist(src.learned_words) && length(src.learned_words))
			thing_to_say = pick(src.learned_words) // :monocle:
			thing_to_say = "[capitalize(thing_to_say)][pick(".", "!", "?", "...")]"

		src.say(thing_to_say, (sing ? SAYFLAG_SINGING : 0))

	proc/take_stuff()
		if (src.treasure)
			if (prob(2))
				src.visible_message("\The [src] drops its [src.treasure.name]!")
				src.treasure.set_loc(src.loc)
				src.treasure = null
				src.impatience = 0
				walk_to(src, 0)
			else
				return
		if (src.new_treasure && src.treasure_loc)
			if ((BOUNDS_DIST(src, src.treasure_loc) == 0) && (src.new_treasure.loc == src.treasure_loc))
				src.visible_message("\The [src] picks up [src.new_treasure]!")
				src.new_treasure.set_loc(src)
				src.treasure = src.new_treasure
				src.new_treasure = null
				src.treasure_loc = null
				src.impatience = 0
				walk_to(src, 0)
				return
			else if (src.new_treasure.loc == src.treasure_loc)
				if (GET_DIST(src, src.treasure_loc) > 4 || src.impatience > 8)
					src.new_treasure = null
					src.treasure_loc = null
					src.impatience = 0
					walk_to(src, 0)
					return
				else
					walk_to(src, src.treasure_loc)
					src.impatience ++

			else if (src.new_treasure.loc != src.treasure_loc)
				if (GET_DIST(src.new_treasure, src) > 4 || src.impatience > 8 || !isturf(src.new_treasure.loc))
					src.new_treasure = null
					src.treasure_loc = null
					src.impatience = 0
					walk_to(src, 0)
					return
				else
					walk_to(src, src.treasure_loc)
					src.impatience ++

	proc/find_stuff()
		var/list/stuff_near_me = list()
		for (var/obj/item/I in view(4, src))
			if (!isturf(I.loc))
				continue
			if (I.anchored || I.density)
				continue
			if(I.w_class >= W_CLASS_GIGANTIC || IS_NPC_ILLEGAL_ITEM(I))
				continue
			stuff_near_me += I
		if (stuff_near_me.len)
			src.new_treasure = pick(stuff_near_me)
			src.treasure_loc = get_turf(new_treasure.loc)
		else
			src.new_treasure = null
			src.treasure_loc = null

	proc/fussle()
		if (!src.can_fussle)
			return
		if (src.treasure && prob(10))
			if (!src.muted)
				src.visible_message("\The [src] [pick("fusses with", "picks at", "pecks at", "throws around", "waves around", "nibbles on", "chews on", "tries to pry open")] [src.treasure].")
			if (prob(5))
				src.visible_message("\The [src] drops its [src.treasure.name]!")
				src.treasure.set_loc(src.loc)
				src.treasure = null
				return
			else if (src.destroys_treasure && prob(1))
				src.visible_message(SPAN_COMBAT("<b>\The [src.treasure] breaks!</b>"))
				make_cleanable( /obj/decal/cleanable/machine_debris,src.loc)
				qdel(src.treasure)
				src.treasure = null
				return
		else if (!src.treasure && src.new_treasure)
			src.take_stuff()
			return
		else if (!src.treasure && !src.new_treasure && prob(src.find_treasure_chance))
			src.find_stuff()
			if (src.new_treasure)
				src.take_stuff()
			return

	proc/create_feather(var/turf/T)
		if (!T)
			T = src.loc
		var/obj/item/feather/F = new(T)
		if (islist(src.feather_color))
			F.color = pick(src.feather_color)
		else
			F.color = src.feather_color
		src.visible_message("A feather falls off of [src].")
		src.last_feather_time = world.time
		return F

	CritterDeath()
		..()
		if (src.treasure)
			src.treasure.set_loc(src.loc)
			src.treasure = null
		for (var/obj/critter/parrot/P in view(7,src))
			if (P.alive && !P.sleeping)
				P.aggressive = 1
				SPAWN(0.7 SECONDS)
					if (P)
						P.aggressive = 0

	on_revive()
		if (src.icon_state != src.species)
			src.icon_state = src.species // so birds revived with SR get the proper icon again
		return ..()

	ai_think()
		src.wanderer = !(src.wrangler && src.wrangler.pulling == src)
		if (task == "thinking" || task == "wandering")
			src.fussle()
			if (prob(src.chatter_chance) && !src.muted)
				src.chatter(rand(1))
			if (prob(5) && !src.muted)
				src.audible_message(SPAN_NOTICE("<b>[src]</b> [pick("chatters", "chirps", "squawks", "mutters", "cackles", "mumbles", "fusses", "preens", "clicks its beak", "fluffs up", "poofs up")]!"))
			if (prob(15))
				FLICK("[src.species]-flaploop", src)
			//if (prob(1) && prob(22) && (src.last_feather_time + 3000) <= world.time)
				//src.create_feather()
		return ..()

	seek_target()
		..()
		if (src.target)
			FLICK("[src.species]-flaploop", src)

	patrol_to(var/turf/towhat)
		.=..()
		if (prob(1) && prob(22) && (src.last_feather_time + 3000) <= world.time)
			src.create_feather()
		if (src.hops)
			var/opy = pixel_y
			animate( src )
			animate( src, pixel_y = 10, easing = SINE_EASING, time = ((towhat.y-y)>0)?3:1 )
			animate( pixel_y = opy, easing = SINE_EASING, time = 3 )
			playsound( get_turf(src), "sound/misc/boing/[rand(1,6)].ogg", 10, 1 )

	CritterAttack(mob/M as mob)
		src.attacking = 1
		FLICK("[src.species]-flaploop", src)
		if (iscarbon(M))
			if (prob(60)) //Go for the eyes!
				src.visible_message(SPAN_COMBAT("<B>[src]</B> pecks [M] in the eyes!"))
				playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_2.ogg', 30, 1)
				M.take_eye_damage(rand(2,10)) //High variance because the bird might not hit well
				if (prob(75) && !M.stat)
					M.emote("scream")
			else
				src.visible_message(SPAN_COMBAT("<B>[src]</B> bites [M]!"))
				playsound(src.loc, "swing_hit", 30, 0)
				random_brute_damage(M, 3,1)
			if (isliving(M))
				var/mob/living/H = M
				H.was_harmed(src)
		else if (isrobot(M))
			if (prob(10))
				src.visible_message(SPAN_COMBAT("<B>[src]</B> bites [M] and snips an important-looking cable!"))
				M:compborg_take_critter_damage(null, 0 ,rand(40,70))
				M.emote("scream")
			else
				src.visible_message(SPAN_COMBAT("<B>[src]</B> bites [M]!"))
				M:compborg_take_critter_damage(null, rand(1,5),0)

		if (prob(3))
			src.create_feather()

		SPAWN(rand(1,10))
			src.attacking = 0

	ChaseAttack(mob/M)
		..()
		playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, -1)

		if (prob(3))
			src.create_feather()

		if (ismob(M))
			M.changeStatus("stunned", 2 SECONDS)
			M.changeStatus("knockdown", 2 SECONDS)

	attack_ai(mob/user as mob)
		if (GET_DIST(user, src) < 2 && user.a_intent != INTENT_HARM)
			return attack_hand(user)
		else
			return ..()

	attack_hand(mob/user)
		if (src.alive)
			if (user.a_intent == INTENT_HARM)
				..()
				if (prob(3))
					src.create_feather()
				return

			else if (user.a_intent == "disarm")
				user.visible_message ("<b>[user]</b> puts their hand up to [src] and says, \"Step up!\"")
				if (src.task == "attacking" && src.target)
					src.visible_message("<b>[user]</b> can't get [src]'s attention!")
					return
				if (prob(25))
					src.visible_message("[src] [pick("ignores","pays no attention to","warily eyes","turns away from")] [user]!")
					return
				else
					user.set_pulling(src)
					src.wanderer = 0
					if (src.task == "wandering")
						src.task = "thinking"
					src.wrangler = user
					src.visible_message("[src] steps onto [user]'s hand!")
			else if (user.a_intent == "grab" && src.treasure)
				if (prob(25))
					src.visible_message(SPAN_COMBAT("<b>[user]</b> [pick("takes", "wrestles", "grabs")] [treasure] from [src]!"))
					user.put_in_hand_or_drop(src.treasure)
					src.treasure = null
				else
					src.visible_message(SPAN_COMBAT("<b>[user]</b> tries to [pick("take", "wrestle", "grab")] [treasure] from [src], but [src] won't let go!"))
				if (prob(3))
					src.create_feather()
			else
				src.visible_message("<b>[user]</b> [pick("gives [src] a scritch", "pets [src]", "cuddles [src]", "snuggles [src]")]!", group="animalhug")
				if (prob(15))
					src.visible_message(SPAN_NOTICE("<b>[src]</b> chirps happily!"))
				return
		else
			..()
		return

	attackby(obj/item/W, mob/user)
		if (src.sells_furniture && istype(W, /obj/item/currency/spacecash)) // this is hella dumb
			var/obj/item/currency/spacecash/C = W
			if (C.amount < 25)
				user.visible_message("[src] stares blankly at [user]'s [C].",\
				"[src] stares blankly at your [C]. Maybe it's not enough?")
				return

			var/FP
			var/FP_name

			if (C.amount >= 3000) // coffins
				FP = /obj/storage/closet/coffin
				FP_name = "Likkista"
				C.amount -= 3000

			else if (C.amount >= 1700) // segways
				FP = /obj/vehicle/segway
				FP_name = "Fart"
				C.amount -= 1700

			else if (C.amount >= 330) // chem tables
				FP = /obj/item/furniture_parts/table/reinforced/chemistry
				FP_name = "Arbetsplatsolycka"
				C.amount -= 330

			else if (C.amount >= 320) // bar tables
				FP = /obj/item/furniture_parts/table/reinforced/bar
				FP_name = "Fyllehund"
				C.amount -= 320

			else if (C.amount >= 300) // reinforced glass tables
				FP = /obj/item/furniture_parts/table/glass/reinforced
				FP_name = "Sköld"
				C.amount -= 300

			else if (C.amount >= 280) // armchairs
				FP = pick(/obj/stool/chair/comfy, /obj/stool/chair/comfy/blue, /obj/stool/chair/comfy/red, /obj/stool/chair/comfy/green, /obj/stool/chair/comfy/purple)
				FP_name = "Avkoppling"
				C.amount -= 280

			else if (C.amount >= 250) // reinforced tables
				FP = /obj/item/furniture_parts/table/reinforced
				FP_name = "Stark"
				C.amount -= 250

			else if (C.amount >= 230) // roller beds
				FP = /obj/item/furniture_parts/bed/roller
				FP_name = "Återhämtning"
				C.amount -= 230

			else if (C.amount >= 220) // glass tables
				FP = /obj/item/furniture_parts/table/glass
				FP_name = "Transparens"
				C.amount -= 220

			else if (C.amount >= 200) // beds
				FP = /obj/item/furniture_parts/bed
				FP_name = "Vilostund"
				C.amount -= 200

			else if (C.amount >= 130) // round tables
				FP = pick(/obj/item/furniture_parts/table/round, /obj/item/furniture_parts/table/wood/round)
				FP_name = "Samkväm"
				C.amount -= 130

			else if (C.amount >= 100) // regular tables
				FP = pick(/obj/item/furniture_parts/table, /obj/item/furniture_parts/table/wood)
				FP_name = "Bruksvallarna"
				C.amount -= 100

			else if (C.amount >= 80) // racks
				FP = /obj/item/furniture_parts/rack
				FP_name = "Stapla"
				C.amount -= 80

			else if (C.amount >= 70) // office chairs
				FP = pick(/obj/item/furniture_parts/office_chair, /obj/item/furniture_parts/office_chair/red, /obj/item/furniture_parts/office_chair/green, /obj/item/furniture_parts/office_chair/blue, /obj/item/furniture_parts/office_chair/yellow, /obj/item/furniture_parts/office_chair/purple)
				FP_name = "Kontorist"
				C.amount -= 70

			else if (C.amount >= 50) // wooden chairs
				FP = /obj/item/furniture_parts/dining_chair/wood
				FP_name = "Bredsjö"
				C.amount -= 50

			else if (C.amount >= 40) // bar stools
				FP = /obj/item/furniture_parts/stool/bar
				FP_name = "Kröka"
				C.amount -= 40

			else if (C.amount >= 35) // stools
				FP = /obj/item/furniture_parts/stool
				FP_name = "Avlastning"
				C.amount -= 35

			else if (C.amount >= 30) // benches
				FP = pick(/obj/item/furniture_parts/bench, /obj/item/furniture_parts/bench/red, /obj/item/furniture_parts/bench/blue, /obj/item/furniture_parts/bench/green, /obj/item/furniture_parts/bench/yellow)
				FP_name = "Benke"
				C.amount -= 30

			else // 25, folding chairs
				FP = /obj/item/chair/folded
				FP_name = "Sittplats"
				C.amount -= 25

			if (!ispath(FP))
				return
			user.visible_message("[src] takes some of [user]'s money and produces some furniture from under its wing!",\
			"[src] takes some of your money and produces some furniture from under its wing!")
			src.say(pick("Ha en bra dag!", "Kom igen!"))
			if (C.amount <= 0) // no mo monay
				user.u_equip(C)
				qdel(C)
			else
				C.UpdateStackAppearance()

			FP = new FP(get_turf(src))
			if (istype(FP, /atom))
				var/atom/A = FP
				A.name = FP_name
			else
				return
			if (istype(FP, /obj/stool))
				var/obj/stool/S = FP
				S.anchored = UNANCHORED
			else if (istype(FP, /obj/item/chair/folded))
				var/obj/item/chair/folded/F = FP
				F.c_color = "chair[pick("","-b","-y","-r","-g")]"
				F.icon_state = "folded_[F.c_color]"
				F.item_state = F.icon_state
			return

		else if (user.a_intent != INTENT_HARM && !istype(W, /obj/item/reagent_containers/food/snacks) && !istype(W, /obj/item/seed))
			if (src.being_offered_treasure)
				src.visible_message(SPAN_COMBAT("[src] is distracted by [src.being_offered_treasure] and ignores [user]!"))
				return
			else
				src.visible_message(SPAN_NOTICE("<b>[user]</b> offers [W] to [src]!"))
				var/turf/T = get_turf(src) // we'll path back here to grab it if we have to
				src.wanderer = 0
				src.being_offered_treasure = "[user]'s [W]"
				SPAWN(rand(10,30)) // 1-3 seconds
					if (src)
						src.wanderer = initial(src.wanderer)
						src.being_offered_treasure = 0
						if (src.alive && !src.sleeping && user && W && user.find_in_hand(W)) // we have to do so many checks for such a short wait
							if (GET_DIST(user, T) > 2 || (src.treasure && prob(80)) || prob(50) || (src.loc != T && !step_to(src,T))) // too far, already has a thing and doesn't wanna switch, just doesn't like the thing offered, or we can't get to where we need to be
								src.visible_message(SPAN_COMBAT("[src] doesn't take [W] from [user]!"))
								return
							else
								if (src.treasure)
									src.visible_message("\The [src] drops its [src.treasure.name]!")
									src.treasure.set_loc(src.loc)
									src.treasure = null
									src.new_treasure = null
									src.treasure_loc = null
									src.impatience = 0
								walk_to(src, 0)
								src.visible_message(SPAN_NOTICE("\The [src] takes [W] from [user]!"))
		else
			return ..()

	proc/dance_response()
		if (!src.alive || src.sleeping)
			return
		if (prob(20))
			src.visible_message(SPAN_NOTICE("\The [src] responds with a dance of its own!"))
			src.dance()
		else
			src.visible_message(SPAN_NOTICE("\The [src] flaps and bobs [pick("to the beat", "in tune", "approvingly", "happily")]."))
			FLICK("[src.species]-flaploop", src)
		if (prob(3))
			src.create_feather()

	proc/dance()
		if (!src.alive || src.sleeping)
			return
		src.icon_state = "[src.species]-flap"
		SPAWN(3.8 SECONDS)
			src.icon_state = src.species
		return

	proc/apply_species(var/new_species = null)
		if (!(istext(new_species) || ispath(new_species)) || !islist(parrot_species)) // farrrrrtttt
			logTheThing(LOG_DEBUG, null, "One of haine's stupid parrot things is broken, go whine at her until she fixes it (deets: type = [src.type], new_species = [isnull(new_species) ? "null" : new_species], parrot_species = [islist(parrot_species) ? "list" : "not list"])")
			return

		var/datum/species_info/parrot/info = ispath(new_species) ? new_species : parrot_species[new_species]
		if (!ispath(info))
			DEBUG_MESSAGE("[src].apply_species([new_species]): info is not a path when looking in parrot_species: [isnull(info) ? "null" : info]")
			info = special_parrot_species[new_species]
			if (!ispath(info))
				DEBUG_MESSAGE("[src].apply_species([new_species]): info is not a path when looking in special_parrot_species: [isnull(info) ? "null" : info]")
				return

		src.name = initial(info.name)
		src.desc = initial(info.desc)
		src.species = initial(info.species)
		src.icon = initial(info.icon)
		src.icon_state = src.species
		src.dead_state = "[src.species]-dead"
		src.pixel_x = initial(info.pixel_x)
		src.learned_words = initial(info.learned_words)
		src.learned_phrases = initial(info.learned_phrases)
		src.learn_words_chance = initial(info.learn_words_chance)
		src.learn_phrase_chance = initial(info.learn_phrase_chance)
		src.learn_words_max = initial(info.learn_words_max)
		src.learn_phrase_max = initial(info.learn_phrase_max)
		src.find_treasure_chance = initial(info.find_treasure_chance)
		src.destroys_treasure = initial(info.destroys_treasure)
		src.hops = initial(info.hops)
		src.sells_furniture = initial(info.sells_furniture)
		src.feather_color = params2list(initial(info.feather_color)) // can't get a list when using initial() on a var of a thing that doesn't actually exist in-game APPARENTLY!!  I don't want to spawn instances of these datums so we're doing this instead, bleh
		DEBUG_MESSAGE("[initial(info.feather_color)]")

		if (src.sells_furniture)
			src.treasure = new /obj/item/paper/ikea_catalogue(src)

/obj/critter/parrot/eclectus
	name = "space eclectus"
	desc = "A spacefaring species of <i>eclectus roratus</i>."
	species = null

	New()
		..()
		if (!src.species)
			src.apply_species(pick("eclectus","eclectusf"))

/obj/critter/parrot/eclectus/dominic
	name = "Dominic"
	desc = "Who's a green chicken? It's him, the stinkosaurous rex, he's the green chicken! He's kissin', that bird is. He thought he could get away with it, but he was wrong."
	species = "eclectus"
	icon_state = "eclectus"
	dead_state = "eclectus-dead"
	health = 50
	generic = 0

	New()
		already_a_dominic = 1
		..()

/obj/critter/parrot/grey
	name = "space grey"
	desc = "A spacefaring species of <i>psittacus erithacus</i>."
	species = "agrey"
	icon_state = "agrey"
	dead_state = "agrey-dead"

/obj/critter/parrot/caique
	name = "space caique"
	desc = "A spacefaring species of parrot from the <i>pionites</i> genus."
	species = null
	hops = 1
	hat_offset_y = -6

	New()
		..()
		if (!src.species)
			src.apply_species(pick("bcaique","wcaique"))

/obj/critter/parrot/budgie
	name = "space budgerigar"
	desc = "A spacefaring species of <i>melopsittacus undulatus</i>."
	species = null
	hat_offset_y = -6

	New()
		..()
		if (!src.species)
			src.apply_species(pick("gbudge","bbudge","bgbudge"))

/obj/critter/parrot/cockatiel
	name = "space cockatiel"
	desc = "A spacefaring species of <i>nymphicus hollandicus</i>."
	species = null
	hat_offset_y = -6

	New()
		..()
		if (!src.species)
			src.apply_species(pick("tiel","wtiel","luttiel","blutiel"))

/obj/critter/parrot/cockatoo
	name = "space cockatoo"
	desc = "A spacefaring species of parrot from the <i>cacatuidae</i> family."
	species = null
	hat_offset_y = -4

	New()
		..()
		if (!src.species)
			src.apply_species(pick("too","too","utoo","mtoo"))

/obj/critter/parrot/toucan
	name = "space toucan"
	desc = "A spacefaring species of parrot from the <i>ramphastos</i> genus."
	species = null
	hat_offset_y = -4

	New()
		..()
		if (!src.species)
			src.apply_species(pick("toucan","kbtoucan"))

/obj/critter/parrot/macaw
	name = "space macaw"
	desc = "A spacefaring species of parrot from the <i>arini</i> tribe."
	species = null
	icon = 'icons/misc/bigcritter.dmi' // macaws are big oafs
	pixel_x = -16
	hat_offset_y = -3
	hat_offset_x = 16

	New()
		..()
		if (!src.species)
			src.apply_species(pick("smacaw","bmacaw","mmacaw","hmacaw"))

	pirate
		name = "Sharkbait"
		species = "smacaw"
		learn_phrase_chance = 0
		learn_words_chance = 0
		learned_phrases = list("YARR!")
		learned_words = list("YARR!")
		icon_state = "smacaw"
		dead_state = "smacaw"

/obj/critter/parrot/lovebird
	name = "space lovebird"
	desc = "A spacefaring species of parrot from the <i>agapornis</i> genus."
	species = null
	hat_offset_y = -6

	New()
		..()
		if (!src.species)
			src.apply_species(pick("love","lovey","lovem","loveb","lovef"))

/obj/critter/parrot/kea
	name = "space kea" // and its swedish brother space ikea
	desc = "A spacefaring species of <i>nestor notabillis</i>, also known as the 'space mountain parrot,' originating from Space Zealand."
	species = "kea"
	icon_state = "kea"
	dead_state = "kea-dead"
	find_treasure_chance = 15
	destroys_treasure = 1

/obj/critter/parrot/kea/ikea
	name = "space ikea" // yes
	desc = "You can buy a variety of flat-packed furniture from the space ikea, if you have enough space kronor."
	species = "ikea"
	icon_state = "ikea"
	dead_state = "ikea-dead"
	learned_words = list("Välkommen","Hej","Hejsan","Hallå","Hej då","Varsågod","Hur mår du","Tack så mycket","Kom igen","Ha en bra dag")
	learned_phrases = list("Välkommen!","Hej!","Hejsan!","Hallå!","Hej då!","Varsågod!","Hur mår du?","Tack så mycket!","Kom igen!","Ha en bra dag!")
	learn_words_chance = 0
	learn_phrase_chance = 0
	chatter_chance = 10
	destroys_treasure = 0
	sells_furniture = 1

	New()
		..()
		src.treasure = new /obj/item/paper/ikea_catalogue(src)

/obj/critter/parrot/space
	desc = "A parrot, from space. In space. Made of space? A space parrot."
	icon_state = "space"
	dead_state = "space-dead"
	species = "space"

/obj/critter/parrot/random
	species = null
	New()
		..()
		if (!src.species)
			if (prob(1) && prob(10))
				src.apply_species(pick(special_parrot_species))
				return
			src.apply_species(pick(parrot_species))
			return

/obj/critter/parrot/random/testing
	New() // the apply_species() call in /obj/critter/parrot/random/New() will override these if we set them as the initial vars on /obj/critter/parrot/random/testing, so we set them here after apply_species() has already run
		..()
		src.learn_words_chance = 100
		src.learn_phrase_chance = 100
		src.chatter_chance = 100
		src.find_treasure_chance = 100

#undef PARROT_MAX_WORDS
#undef PARROT_MAX_PHRASES

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/parrot
	name = "parrot egg"
	critter_type = /obj/critter/parrot/random
	critter_reagent = "flaptonium"

/obj/item/paper/ikea_catalogue
	name = "space ikea catalogue"
	desc = "Some kind of bird furniture catalogue?"
	sealed = 1
	info = {"<small<i>This looks quite tattered and ripped up. You can't read everything around the edges because of all the holes and tears in the paper.</i></small<br><br>
<b><i>Produkt</i></b> - <i>Pris</i><br>
<b>Likkista</b> - 3000<small>SSEK</small><br>
<b>Fart</b> - 1700<small>SSEK</small><br>
<b>Arbetsplatsolycka</b> - 330<small>SSEK</small><br>
<b>Fyllehund</b> - 320<small>SSEK</small><br>
<b>Sköld</b> - 300<small>SSEK</small><br>
<b>Avkoppling</b> - 280<small>SSEK</small> - <small><i>Tillgängliga i flera färger</i></small><br>
<b>Stark</b> - 250<small>SSEK</small><br>
<b>Återhämtning</b> - 230<small>SSEK</small><br>
<b>Transparens</b> - 200<small>SSEK</small><br>
<b>Vilostund</b> - 200<small>SSEK</small><br>
<b>Samkväm</b> - 130<small>SSEK</small><br>
<b>Bruksvallarna</b> - 100<small>SSEK</small><br>
<b>Stapla</b> - 80<small>SSEK</small><br>
<b>Kontorist</b> - 70<small>SSEK</small> - <small><i>Tillgängliga i flera färger</i></small><br>
<b>Bredsjö</b> - 50<small>SSEK</small><br>
<b>Kröka</b> - 40<small>SSEK</small><br>
<b>Avlastning</b> - 35<small>SSEK</small><br>
<b>Benke</b> - 30<small>SSEK</small> - <small><i>Tillgängliga i flera färger</i></small><br>
<b>Sittplats</b> - 25<small>SSEK</small>"}

/obj/critter/seagull
	name = "space gull"
	desc = "A spacefaring species of bird from the <i>Laridae</i> family."
	icon = 'icons/misc/bird.dmi'
	icon_state = "gull"
	dead_state = "gull-dead"
	density = 0
	health = 15
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	angertext = "caws angrily at"
	death_text = "%src% lets out a final weak caw and keels over."
	butcherable = BUTCHER_ALLOWED
	flying = 1
	chases_food = 1
	health_gain_from_food = 2
	feed_text = "caws happily!"
	flags = CONDUCT | USEDELAY | TABLEPASS | FLUID_SUBMERGE
	var/feather_color = list("#ffffff","#949494","#353535")
	var/last_feather_time = 0

	patrol_to(var/turf/towhat)
		.=..()
		if (prob(1) && prob(22) && (src.last_feather_time + 3000) <= world.time)
			src.create_feather()

	proc/create_feather(var/turf/T)
		if (!T)
			T = src.loc
		var/obj/item/feather/F = new(T)
		if (islist(src.feather_color))
			F.color = pick(src.feather_color)
		else
			F.color = src.feather_color
		src.visible_message("A feather falls off of [src].")
		src.last_feather_time = world.time
		return F

/obj/critter/seagull/gannet // they're technically not gulls but they're gunna use basically all the same var settings so, um
	name = "space gannet"
	desc = "A spacefaring species of <i>morus bassanus</i>."
	icon = 'icons/misc/bird.dmi'
	icon_state = "gannet"
	dead_state = "gannet-dead"
	feather_color = list("#ffffff","#d4bb2f","#414141")

/obj/critter/crow // copied from seagulls, idk
	name = "space crow"
	desc = "A spacefaring species of bird from the <i>Corvidae</i> family."
	icon = 'icons/misc/bird.dmi'
	icon_state = "crow"
	dead_state = "crow-dead"
	density = 0
	health = 15
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	scavenger = 1 //carrion birds
	angertext = "caws angrily at"
	death_text = "%src% lets out a final weak caw and keels over."
	chase_text = "flails into"
	butcherable = BUTCHER_ALLOWED
	flying = 1
	chases_food = 1
	health_gain_from_food = 2
	feed_text = "caws happily!"
	flags = CONDUCT | USEDELAY | TABLEPASS | FLUID_SUBMERGE
	var/feather_color = "#212121"
	var/last_feather_time = 0

	New()
		..()
		if (prob(5))
			src.name = replacetext(src.name, "crow", "raven")

	CritterAttack(mob/M as mob)
		src.attacking = 1
		FLICK("crow-flaploop", src)
		if (iscarbon(M))
			if (prob(60)) //Go for the eyes!
				src.visible_message(SPAN_COMBAT("<B>[src]</B> pecks [M] in the eyes!"))
				playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_2.ogg', 30, 1)
				M.take_eye_damage(rand(2,10)) //High variance because the bird might not hit well
				if (prob(75) && !M.stat)
					M.emote("scream")
				if (ishuman(M) && prob(10))
					var/mob/living/carbon/human/H = M
					var/chosen_eye = prob(50) ? "left_eye" : "right_eye"
					var/obj/item/organ/eye/E = H.get_organ(chosen_eye)
					if (!E)
						if (chosen_eye == "left_eye")
							chosen_eye = "right_eye"
						else
							chosen_eye = "left_eye"
						E = H.get_organ(chosen_eye)
					if (E)
						src.visible_message(SPAN_COMBAT("<B>[src] [pick("tears","yanks","rips")] [M]'s eye out! <i>Holy shit!!</i></B>"))
						E = H.drop_organ(chosen_eye)
						playsound(M, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, TRUE)
						E.set_loc(src.loc)
			if (isliving(M))
				var/mob/living/H = M
				H.was_harmed(src)
			else
				src.visible_message(SPAN_COMBAT("<B>[src]</B> bites [M]!"))
				playsound(src.loc, "swing_hit", 30, 0)
				random_brute_damage(M, 3,1)

		else if (isrobot(M))
			if (prob(10))
				src.visible_message(SPAN_COMBAT("<B>[src]</B> bites [M] and snips an important-looking cable!"))
				M:compborg_take_critter_damage(null, 0 ,rand(40,70))
				M.emote("scream")
			else
				src.visible_message(SPAN_COMBAT("<B>[src]</B> bites [M]!"))
				M:compborg_take_critter_damage(null, rand(1,5),0)

		SPAWN(rand(1,10))
			src.attacking = 0

	ChaseAttack(mob/M)
		..()
		playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, -1)

		if (ismob(M))
			M.changeStatus("stunned", 2 SECONDS)
			M.changeStatus("knockdown", 2 SECONDS)

	patrol_to(var/turf/towhat)
		.=..()
		if (prob(1) && prob(22) && (src.last_feather_time + 3000) <= world.time)
			src.create_feather()

	proc/create_feather(var/turf/T)
		if (!T)
			T = src.loc
		var/obj/item/feather/F = new(T)
		if (islist(src.feather_color))
			F.color = pick(src.feather_color)
		else
			F.color = src.feather_color
		src.visible_message("A feather falls off of [src].")
		src.last_feather_time = world.time
		return F

/obj/critter/meatslinky // ferrets for wire
	name = "space ferret"
	desc = "A ferret that came from space. Or maybe went to space. Who knows how it got here?"
	icon_state = "ferret"
	dead_state = "ferret-dead"
	density = 0
	health = 20
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	butcherable = BUTCHER_YOU_MONSTER
	angertext = "wigs out at"
	atk_text = "flails itself into"
	atk_brute_amt = 3
	crit_text = "flips and flails itself into"
	crit_brute_amt = 5
	pet_text = list("pets", "cuddles", "pats", "snuggles")
	var/lying = 0
	var/freakout = 0
	var/base_state = "ferret"
	var/lazy_state = "ferret-lazy"
	var/lock_color = 0

	New()
		..()

		//50% chance to be a dark-colored ferret
		if (!src.lock_color && prob(50))
			src.icon_state = src.base_state = "ferret-dark"
			src.dead_state = "ferret-dark-dead"
			src.lazy_state = "ferret-dark-lazy"

	ai_think()
		if (src.alive && src.lying && prob(10))
			src.visible_message("<b>[src]</b> gets up!</span>")
			src.icon_state = src.base_state
			src.lying = 0
			src.wanderer = initial(src.wanderer)
		else if (src.alive && !src.sleeping && src.freakout)
			SPAWN(0)
				var/x = rand(2,4)
				while (x-- > 0)
					src.pixel_x = rand(-6,6)
					src.pixel_y = rand(-6,6)
					sleep(0.2 SECONDS)

				src.pixel_x = 0
				src.pixel_y = 0

			if (prob(5))
				animate_spin(src, pick("L","R"), 1, 0)

			if (prob(10))
				src.visible_message("\The [src] [pick("wigs out","frolics","rolls about","freaks out","goes wild","wiggles","wobbles","dooks")]!")

			src.freakout--
			if (!src.freakout)
				src.visible_message("\The [src] calms down.")

		else
			..()
			if (task == "thinking" || task == "wandering")
				if (src.alive && !src.sleeping && prob(2) && !src.lying && !src.freakout)
					if (prob(50))
						src.freakout = rand(10,20) //x * 1.6 (critter loop tickrate) = duration in seconds
						return
					else
						src.lying = 1
						src.wanderer = 0
						src.task = "thinking"
						src.icon_state = src.lazy_state
						src.visible_message("<b>[src]</b> [pick("lies down", "flops onto the floor", "plops down")]!</span>")
						return

	ChaseAttack(mob/M)
		src.visible_message(SPAN_COMBAT("<B>[src]</B> weaves around [M]'s legs!"))
		if (ismob(M))
			var/tostun = rand(0,3)
			var/toweak = rand(0,3)
			if (toweak)
				M.visible_message(SPAN_COMBAT("<B>[M]</B> trips!"))
			M.changeStatus("stunned", tostun SECONDS)
			M.changeStatus("knockdown", toweak SECONDS)

	CritterAttack(mob/M)
		..()

	attack_hand(mob/user)
		if (src.alive && (user.a_intent == INTENT_HARM)) // ferrets are quick so you might miss!!
			if (prob(80))
				..()
				if (src.lying)
					src.visible_message("<b>[src]</b> gets up!</span>")
					src.icon_state = src.base_state
					src.lying = 0
					src.wanderer = initial(src.wanderer)
				return
			if (src.lying)
				src.visible_message("<b>[src]</b> gets up!</span>")
				src.icon_state = src.base_state
				src.lying = 0
				src.wanderer = initial(src.wanderer)
			src.visible_message(SPAN_COMBAT("<b>[user]</b> swings at [src], but misses!"))
			playsound(src, 'sound/impact_sounds/Generic_Swing_1.ogg', 50, FALSE)
			return
		else
			return ..()

//Wire: special ferret based on my poor dead IRL ferret perhaps paradoxically named Piggy
//		as a sidenote if you touch this code i may skewer you alive
/obj/critter/meatslinky/piggy
	name = "Piggy"
	desc = "A ferret that came from space. Or maybe went to space. Who knows how it got here? It seems skinny but especially feisty."
	health = 50
	generic = 0 // no let's not have "vile Piggy" or "busted Piggy" tia
	lock_color = 1

//Wire: Another special ferret based on my OTHER now dead IRL ferret. Has similar paradox naming.
/obj/critter/meatslinky/monkey
	name = "Monkey"
	desc = "A ferret that came from space. Or maybe went to space. Who knows how it got here? This one is fatter than most, but playful."
	health = 50
	generic = 0
	lock_color = 1

//Gerhazo: another special ferret per wire's request
/obj/critter/meatslinky/alfredo
	name = "Alfredo"
	desc = "A ferret that came from space. Or maybe went to space. Who knows how it got here? This one has a friendlier vibe than you would've expected, how cute."
	health = 50
	generic = 0
	lock_color = 1

/obj/critter/meatslinky/gizmo
	name = "Gizmo"
	desc = "A ferret that came from space. Or maybe went to space. Who knows how it got here? This one is old and distinguished, but still has a playful glint in his eye."
	health = 50
	generic = 0
	lock_color = 1
	icon_state = "ferret-dark"
	base_state = "ferret-dark"
	dead_state = "ferret-dark-dead"
	lazy_state = "ferret-dark-lazy"

/obj/critter/raccoon
	name = "space raccoon"
	desc = "A raccoon that came from space. Or maybe went to space. Who knows how it got here?"
	icon_state = "raccoon"
	dead_state = "raccoon-dead"
	density = 0
	health = 25
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	butcherable = BUTCHER_ALLOWED
	health_gain_from_food = 2
	feed_text = "happily begins washing its food!"
	pet_text = list("pets", "cuddles", "pats", "snuggles")
	flags = CONDUCT | USEDELAY | TABLEPASS | FLUID_SUBMERGE

	skinresult = /obj/item/clothing/head/raccoon
	max_skins = 1

	New()
		..()
		if (prob(10))
			src.atk_diseases = list(/datum/ailment/disease/berserker, /datum/ailment/disease/space_madness)
			src.atk_disease_prob = 10
			src.atkcarbon = 1
		if (prob(1))
			src.name = "space washbear"
			src.desc = "A washbear that came from space. Or maybe went to space. Who knows how it got here?"

/obj/item/clothing/head/raccoon
	name = "coonskin cap"
	desc = "You'll feel ready to take on anything the wild frontier of space can throw at you with this cap on your head!"
	icon_state = "raccoon"
	item_state = "raccoon"

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("heatprot", 10)
