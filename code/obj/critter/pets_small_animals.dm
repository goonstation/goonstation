/obj/critter/floateye
	name = "floating thing"
	desc = "You have never seen something like this before."
	icon_state = "floateye"
	health = 10
	aggressive = 0
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	butcherable = 1
	flying = 1
	flags = FPRINT | CONDUCT | USEDELAY | TABLEPASS | FLUID_SUBMERGE

/obj/critter/roach
	name = "cockroach"
	desc = "An unpleasant insect that lives in filthy places."
	icon_state = "roach"
	critter_family = BUG
	density = 0
	health = 10
	aggressive = 0
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	butcherable = 1
	flags = FPRINT | CONDUCT | USEDELAY | TABLEPASS | FLUID_SUBMERGE | FLUID_SUBMERGE

	attack_hand(mob/user as mob)
		if (src.alive && (user.a_intent != INTENT_HARM))
			src.visible_message("<span class='combat'><b>[user]</b> pets [src]!</span>")
			return
		if (prob(95))
			if(src.alive)
				src.visible_message("<span class='combat'><B>[user] stomps [src], killing it instantly!</B></span>")
				CritterDeath()
				return
			else
				src.visible_message("<span class='combat'><B>[user] squishes [src] a little more for good measure.</B></span>")
				return
		..()

/obj/critter/mouse
	name = "space mouse"
	desc = "A mouse.  In space."
	icon_state = "mouse"
	density = 0
	health = 2
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	butcherable = 1
	chases_food = 1
	health_gain_from_food = 2
	feed_text = "squeaks happily!"
	flags = FPRINT | CONDUCT | USEDELAY | TABLEPASS | FLUID_SUBMERGE | FLUID_SUBMERGE
	//var/diseased = 0
	atk_delay = 10

	skinresult = /obj/item/material_piece/cloth/leather //YEP
	max_skins = 1

	New()
		..()
		if (prob(10))
			//diseased = 1
			src.atk_diseases = list(/datum/ailment/disease/berserker, /datum/ailment/disease/space_madness)
			src.atk_disease_prob = 10
			src.atkcarbon = 1

/obj/critter/mouse/mad
	name = "rabid space mouse"
	desc = "A mouth-foaming cheese and flesh eating mouse. In space."
	health = 10
	chases_food = 0
	feed_text = "squeaks viciously!"
	atk_delay = 10
	atk_diseases = list(/datum/ailment/disease/berserker, /datum/ailment/disease/space_madness)
	atk_disease_prob = 35
	atkcarbon = 1
/*
	CritterAttack(mob/living/M)
		src.attacking = 1
		src.visible_message("<span class='combat'><B>[src]</B> bites [src.target]!</span>")
		random_brute_damage(src.target, 1)
		SPAWN_DBG(1 SECOND)
			src.attacking = 0
		if(iscarbon(M))
			if(diseased && prob(10))
				if(prob(50))
					M.contract_disease(/datum/ailment/disease/berserker, null, null, 1) // path, name, strain, bypass resist
				else
					M.contract_disease(/datum/ailment/disease/space_madness, null, null, 1) // path, name, strain, bypass resist
*/
/*	seek_target()
		if(src.target)
			src.task = "chasing"
			return
		var/list/visible = new()
		for(var/obj/item/reagent_containers/food/snacks/S in view(src.seekrange,src))
			visible.Add(S)
		if(src.food_target && visible.Find(src.food_target))
			src.task = "chasing food"
			return
		else src.task = "thinking"
		if(visible.len)
			src.food_target = visible[1]
			src.task = "chasing food"
		..()

	ai_think()
		if(task == "chasing food")
			if(src.food_target == null)
				src.task = "thinking"
			else if(get_dist(src, src.food_target) <= src.attack_range)
				src.task = "eating"
			else
				walk_to(src, src.food_target,1,4)
		else if(task == "eating")
			if (get_dist(src, src.food_target) > src.attack_range)
				src.task = "chasing food"
			else
				src.visible_message("<b>[src]</b> nibbles at [src.food_target].")
				playsound(src.loc,"sound/items/eatfood.ogg", rand(10,50), 1)
				if (food_target.reagents.total_volume > 0 && src.reagents.total_volume < 30)
					food_target.reagents.trans_to(src, 5)
				src.food_target.amount--
				SPAWN_DBG(2.5 SECONDS)
				if(src.food_target != null && src.food_target.amount <= 0)
					qdel(src.food_target)
					src.task = "thinking"
					src.food_target = null
		return ..()
*/
/obj/critter/mouse/remy
	name = "Remy"
	desc = "A rat.  In space... wait, is it wearing a chef's hat?"
	icon_state = "remy"
	health = 33
	aggressive = 0
	generic = 0

/obj/critter/opossum
	name = "space opossum"
	desc = "A possum that came from space. Or maybe went to space. Who knows how it got here?"
	icon_state = "possum"
	density = 1
	health = 15
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	butcherable = 1
	pet_text = list("gently baps", "pets", "cuddles")

	skinresult = /obj/item/material_piece/cloth/leather
	max_skins = 1

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	on_revive()
		..()
		src.visible_message("<span class='notice'><b>[src]</b> stops playing dead and gets back up!</span>")
		src.alive = 1
		src.set_density(1)
		src.health = initial(src.health)
		src.icon_state = src.living_state ? src.living_state : initial(src.icon_state)
		src.target = null
		src.task = "wandering"
		return

	CritterDeath()
		..()
		SPAWN_DBG(rand(200,800))
			if (src && !src.alive)
				src.on_revive()
		return

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (!src.alive)
			if (istype(W, /obj/item/knife/butcher) || istype(W, /obj/item/circular_saw) || istype(W, /obj/item/kitchen/utensil/knife) || istype(W, /obj/item/scalpel) || istype(W, /obj/item/raw_material/shard) || istype(W, /obj/item/sword) || istype(W, /obj/item/saw) || issnippingtool(W))
				src.on_revive()
				SPAWN_DBG(0)
					return ..(W, user)
		else
			return ..()

/obj/critter/opossum/morty
	name = "Morty"
	generic = 0

// hi I added my childhood cats' names to the list cause I miss em, they aren't really funny names but they were great cats
// remove em if you want I guess
// - Haine

/obj/critter/cat
	name = "space cat"
	desc = "A cat. In space."
	icon_state = "cat1"
	density = 0
	health = 10
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	angertext = "hisses at"
	chase_text = "pounces on"
	butcherable = 2
	var/cattype = 1
	var/randomize_cat = 1
	var/catnip = 0
	event_handler_flags = USE_HASENTERED | USE_PROXIMITY | USE_FLUID_ENTER

	New()
		if(src.name == "jons the catte")
			src.is_pet = 1
		..()
		if (src.randomize_cat)
			src.name = pick_string_autokey("names/cats.txt")

#ifdef HALLOWEEN
			src.cattype = 3 //Black cats for halloween.
			icon_state = "cat3"
#else
			src.cattype = rand(2,9)
			icon_state = "cat[cattype]"
#endif

	seek_target()
		src.anchored = 0
		//for (var/obj/critter/mouse/C in view(src.seekrange,src))
		var/list/mice_in_area = list()
		for (var/obj/critter/mouse/C in view(src.seekrange,src))
			mice_in_area += C
		for (var/mob/living/critter/small_animal/mouse/C in view(src.seekrange,src))
			mice_in_area += C
		for (var/atom/movable/C in mice_in_area)
			if (src.target)
				src.task = "chasing"
				break
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100))
				continue
			if (isobj(C))
				var/obj/critter/mouse/OC = C
				if (OC.health <= 0)
					continue
			else if (ismob(C))
				var/mob/M = C
				if (isdead(M))
					continue

			src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='combat'><b>[src]</b> [src.angertext] [C.name]!</span>")
				src.task = "chasing"
				break
			else
				continue

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (src.alive && istype(W, /obj/item/plant/herb/catnip))
			user.visible_message("<b>[user]</b> gives [src.name] the [W]!","You give [src.name] the [W].")
			src.catnip_effect()
			pool(W)
		else
			..()

	CritterAttack(mob/M)
		if(istype(M, /mob/living/critter/small_animal/mouse/weak/mentor) && prob(90))
			src.visible_message("<span class='combat'><B>[src]</B> tries to bite [src.target] but \the [src.target] dodges nimbly!</span>")
			return
		src.attacking = 1
		var/attackCount = (src.catnip ? rand(4,8) : 1)
		while (attackCount-- > 0)
			src.visible_message("<span class='combat'><B>[src]</B> bites [src.target]!</span>")
			if (ismob(M))
				random_brute_damage(src.target, 3,1)
			else if (istype(M, /obj/critter)) //robust cat simulation.
				var/obj/critter/C = src.target
				C.health -= 2
				if (C.health <= 0 && C.alive)
					C.CritterDeath()
					src.attacking = 0
			sleep(0.2 SECONDS)
		if (isliving(M))
			var/mob/living/H = M
			H.was_harmed(src)
		SPAWN_DBG(1 SECOND)
		src.attacking = 0
		return

	ChaseAttack(mob/M)
		..()
		playsound(src.loc, "sound/impact_sounds/Generic_Hit_1.ogg", 50, 1, -1)

		if(ismob(M))
			M.changeStatus("stunned", 2 SECONDS)
			M.changeStatus("weakened", 2 SECONDS)

	attack_hand(mob/user as mob)
		if (src.alive && (user.a_intent != INTENT_HARM))
			src.visible_message("<span class='combat'><b>[user]</b> pets [src]!</span>")
			if(prob(10))
				for(var/mob/O in hearers(src, null))
					O.show_message("[src] purrs!",2)
			return
		else
			..()

		return

	CritterDeath()
		..()
		src.icon_state = "cat[cattype]-dead"
		if(prob(5))
			SPAWN_DBG(3 SECONDS)
				src.visible_message("<b>[src]</b> comes back to life, good thing he has 9 lives!")
				src.alive = 1
				set_density(1)
				src.health = 10
				src.icon_state = "cat[cattype]"
				return

	process()
		if(!..())
			return 0
		if (src.alive && src.catnip)

			SPAWN_DBG(0)
				var/x = rand(2,4)
				while (x-- > 0)
					src.pixel_x = rand(-6,6)
					src.pixel_y = rand(-6,6)
					sleep(0.2 SECONDS)

			if (prob(10))
				src.visible_message("[src.name] [pick("purrs","frolics","rolls about","does a cute cat thing of some sort")]!")

			if (src.catnip-- < 1)
				src.visible_message("[src.name] calms down.")

	proc/catnip_effect()
		if (src.catnip)
			return
		src.catnip = 45
		src.visible_message("[src.name]'s eyes dilate.")

	HasEntered(mob/living/carbon/M as mob)
		..()
		if (src.sleeping || !src.alive)
			return
		else if (ishuman(M) && prob(33))
			src.visible_message("<span class='combat'>[src] weaves around [M]'s legs and trips [him_or_her(M)]!</span>")
			M:changeStatus("weakened", 2 SECONDS)
		return

/obj/critter/cat/jones
	name = "Jones"
	desc = "Jones the cat."
	icon_state = "cat1"
	health = 30
	randomize_cat = 0
	generic = 0
	is_pet = 2
	var/swiped = 0

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.alive || cattype == "-emagged")
			return 0
		src.cattype = "-emagged"
		src.icon_state = "cat-emagged"
		if (user)
			user.show_text("You swipe down [src]'s back in a petting motion...")
		return 1

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (istype(W, /obj/item/card/emag))
			emag_act(usr, W)
		if (istype(W, /obj/item/card/id/blank_deluxe))
			var/obj/item/card/id/blank_deluxe/CARD = W
			if (CARD.desc == "Some type of microchipped payment card. Looks like it's designed to deal with catcoins.")//Can't change descs
				if (!swiped && !CARD.jones_swiped)
					if (user)
						user.show_text("You swipe down [src]'s back in a petting motion...")
					src.visible_message("<span class='combat'>[src] vomits out a wad of paper!</span>") //Jones City Puzzle
					make_cleanable( /obj/decal/cleanable/vomit,src.loc)
					new /obj/item/paper/jones_note(src.loc)
					swiped++
					CARD.jones_swiped = 1 //Can only use the card once.
		else
			..()

/obj/critter/cat/goddamnittobba
	aggressive = 1
	New()
		..()
		src.catnip = rand(50,250)

	CritterAttack(mob/M)
		if(ismob(M))
			src.attacking = 1
			var/attackCount = (src.catnip ? rand(4,8) : 1)
			while(attackCount-- > 0)
				src.visible_message("<span class='combat'><B>[src]</B> claws at [src.target]!</span>")
				random_brute_damage(src.target, 6,1)
				sleep(0.2 SECONDS)

			SPAWN_DBG(1 SECOND)
				src.attacking = 0

/obj/critter/cat/synth
	icon_state = "catsynth"
	cattype = "synth"
	randomize_cat = 0
	generic = 0
	desc = "Although this cat is vegan, it's still a carnivore."

	New()
		name = pick_string_autokey("names/cats.txt")
		..()

/obj/critter/dog/george
	name = "George"
	desc = "Good dog."
	icon_state = "george"
	var/doggy = "george"
	density = 1
	health = 100
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0 //set to 1 for robots as space cars
	firevuln = 1
	brutevuln = 1
	angertext = "growls at"
	death_text = null // he's just asleep
	atk_brute_amt = 2
	crit_brute_amt = 4
	chase_text = "jumps on"
	butcherable = 0
	generic = 0

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING
/*
	seek_target()
		src.anchored = 0
		for (var/obj/critter/cat/C in view(src.seekrange,src))
			if (src.target)
				src.task = "chasing"
				break
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (C.health < 0) continue

			src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='combat'><b>[src]</b> [src.angertext] [C.name]!</span>")
				src.task = "chasing"
				break
			else
				continue
*/
	CritterAttack(mob/M)
		..()

	/*	else if(istype(M, /obj/critter/cat)) //uncomment for robust dog simulation.
			src.attacking = 1
			src.visible_message("<span class='combat'><b>[src]</b> bites [src.target]!</span>")
			src.target:health -= 2
			if(src.target:health <= 0 && src.target:alive)
				src.target:CritterDeath()
				src.attacking = 0 */

		return

	ChaseAttack(mob/M)
		..()
		playsound(src.loc, "sound/impact_sounds/Generic_Hit_1.ogg", 50, 1, -1)

		if(ismob(M))
			M.changeStatus("stunned", 2 SECONDS)
			M.changeStatus("weakened", 2 SECONDS)

	attack_hand(mob/user as mob)
		if (src.alive && (user.a_intent != INTENT_HARM))
			src.visible_message("<span class='combat'><b>[user]</b> pets [src]!</span>")
			if(prob(30))
				src.icon_state = "[src.doggy]-lying"
				for(var/mob/O in hearers(src, null))
					O.show_message("<span class='notice'><B>[src]</B> flops on his back! Scratch that belly!</span>",2)
				SPAWN_DBG(3 SECONDS)
				src.icon_state = "[src.doggy]"
			return
		else
			..()

		return

	CritterDeath()
		..()
		src.icon_state = "[src.doggy]-lying"
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='combat'><b>[src]</b> [pick("tires","tuckers out","gets pooped")] and lies down!</span>")
		SPAWN_DBG(1 MINUTE)
			for(var/mob/O in hearers(src, null))
				O.show_message("<span class='notice'><b>[src]</b> wags his tail and gets back up!</span>")
			src.alive = 1
			set_density(1)
			src.health = 100
			src.icon_state = "[src.doggy]"
		return

	proc/howl()
		if(prob(60))
			for(var/mob/O in hearers(src, null))
				O.show_message("<span class='combat'><b>[src]</b> [pick("howls","bays","whines","barks","croons")] to the music! He thinks he's singing!</span>")
			playsound(get_turf(src), pick("sound/voice/animal/howl1.ogg","sound/voice/animal/howl2.ogg","sound/voice/animal/howl3.ogg","sound/voice/animal/howl4.ogg","sound/voice/animal/howl5.ogg","sound/voice/animal/howl6.ogg"), 100, 0)

/obj/critter/dog/george/blair
	name = "Blair"
	icon_state = "pug"
	doggy = "pug"
	is_pet = 2

var/list/shiba_names = list("Maru", "Coco", "Foxtrot", "Nectarine", "Moose", "Pecan", "Daikon", "Seaweed")

// am bad at dog names

/obj/critter/dog/george/shiba
	name = "Shiba Inu"
	icon_state = "shiba"
	doggy = "shiba"
	var/randomize_shiba = 1

	New()
		..()
		if (src.randomize_shiba)
			src.name = pick(shiba_names)

/obj/critter/dog/illegal
	name = "highly illegal dog"
	icon_state = "illegal"
	var/doggy = "illegal"

/obj/critter/pig
	name = "space pig"
	desc = "A pig. In space."
	icon_state = "pig"
	density = 1
	health = 15
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	angertext = "oinks at"
	atk_brute_amt = 4
	crit_brute_amt = 8
	chase_text = "barrels into"
	butcherable = 1
	scavenger = 1 // pig-based body disposal services
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	name_the_meat = 0

	skinresult = /obj/item/material_piece/cloth/leather
	max_skins = 2

	CritterDeath()
		..()
		src.reagents.add_reagent("beff", 50, null)
		return

	seek_target()
		src.anchored = 0
		for (var/obj/critter/mouse/C in view(src.seekrange,src))
			if (src.target)
				src.task = "chasing"
				break
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (C.health < 0) continue

			src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='combat'><b>[src]</b> [src.angertext] [C.name]!</span>")
				src.task = "chasing"
				break
			else
				continue

	CritterAttack(mob/M)
		..()

	ChaseAttack(mob/M)
		..()
		playsound(src.loc, "sound/impact_sounds/Generic_Hit_1.ogg", 50, 1, -1)

		if(ismob(M))
			M.changeStatus("stunned", 4 SECONDS)
			M.changeStatus("weakened", 4 SECONDS)

	on_pet(mob/user)
		..()
		if(prob(10))
			for(var/mob/O in hearers(src, null))
				O.show_message("[src] purrs!",2)

/obj/critter/owl
	name = "space owl"
	desc = "Did you know? By 2063, it is expected that there will be more owls on Earth than human beings."
	icon = 'icons/misc/bird.dmi'
	icon_state = "smallowl"
	density = 1
	health = 10
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	angertext = "hoots at"
	butcherable = 2
	flying = 1
	atk_text = "pecks at"
	atk_brute_amt = 2
	crit_text = "pecks really hard at"
	crit_brute_amt = 4
	chase_text = "swoops down upon"
	var/feather_color = list("#803427","#7d5431")
	var/last_feather_time = 0

	attackby(obj/item/W as obj, mob/M as mob)
		if(istype(W,/obj/item/clothing/head/void_crown))
			/*
			var/data[] = new()
			data["ckey"] = M.ckey
			data["compID"] = M.computer_id
			data["ip"] = M.lastKnownIP
			data["reason"] = "Get out you nerd. Also, stop abusing your access to the commit messages."
			data["mins"] = 1440
			data["akey"] = "NERDBANNER"
			*/

			src.visible_message("<span class='combat'><B>[src]</B> stares at [M], channeling its newfound power!</span>")
			SPAWN_DBG(1 SECOND)
				boutput(M, "<span class='alert'><BIG><B>[voidSpeak("WELP, GUESS YOU SHOULDN'T BELIEVE EVERYTHING YOU READ!")]</B></BIG></span>")
				var/mob/dead/observer/O = M.ghostize()
				if(O)
					O.set_loc(M.loc)
					del(O.client)
				else
					del(M.client)
				M.owlgib()
			//addBan(data)

		if(istype(W, /obj/item/plutonium_core/hootonium_core))//Owls interestingly are capable of absorbing hootonium into their bodies harmlessly. This is the only safe method of removing it.
			playsound(M.loc, "sound/items/eatfood.ogg", 100, 1)
			boutput(M, "<span class='alert'><B>You feed the [src] the [W]. It looks [pick("confused", "annoyed", "worried", "satisfied", "upset", "a tad miffed", "at you and winks")].</B></span>")
			M.drop_item()
			W.set_loc(src)

			SPAWN_DBG(1 MINUTE)
				src.visible_message("<span class='alert'><B>The [src] suddenly regurgitates something!</B></span>")
				playsound(get_turf(src), pick('sound/impact_sounds/Slimy_Splat_1.ogg','sound/misc/meat_plop.ogg'), 100, 1)
				make_cleanable( /obj/decal/cleanable/greenpuke,src.loc)

				for(var/turf/T in range(src, 2))
					if(prob(20))
						playsound(get_turf(src), pick('sound/impact_sounds/Slimy_Splat_1.ogg','sound/misc/meat_plop.ogg'), 100, 1)
						make_cleanable( /obj/decal/cleanable/greenpuke,T)

				new /obj/item/power_stones/Owl(src.loc)

		else
			return ..(W, M)

	CritterAttack(mob/M)
		..()

	ChaseAttack(mob/M)
		..()
		playsound(src.loc, "sound/impact_sounds/Generic_Hit_1.ogg", 50, 1, -1)
		random_brute_damage(src.target, 1)//peck peck

		return

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

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/owl
	name = "owl egg"
	critter_type = /obj/critter/owl

/obj/critter/goose
	name = "space goose"
	desc = "An offshoot species of <i>branta canadensis</i> adapted for space."
	icon = 'icons/misc/bird.dmi'
	icon_state = "goose"
	density = 1
	health = 20
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_PUBLIC
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	angertext = "hisses angrily at"
	atk_brute_amt = 2
	butcherable = 1
	death_text = "%src% collapses and stops moving!"
	chase_text = "tackles"
	var/feather_color = list("#393939","#f2ebd5","#68422a","#ffffff")
	var/last_feather_time = 0

	ai_think()
		..()
		if (task == "thinking" || task == "wandering")
			if (prob(20))
				if (!src.muted)
					src.visible_message("<b>[src]</b> honks!")
				playsound(src.loc, "sound/voice/animal/goose.ogg", 70, 1)
		else
			if (prob(20))
				flick("[src.icon_state]-flap", src)
				playsound(src.loc, "sound/voice/animal/cat_hiss.ogg", 50, 1)

	seek_target()
		..()
		if (src.target)
			flick("[src.icon_state]-flaploop", src)
			src.visible_message("<span class='combat'><b>[src]</b> [src.angertext] [src.target]!</span>")
			playsound(src.loc, "sound/voice/animal/cat_hiss.ogg", 50, 1)

	CritterAttack(mob/M)
		flick("[src.icon_state]-flap", src)
		playsound(src.loc, "swing_hit", 30, 0)
		..()

	ChaseAttack(mob/M)
		flick("[src.icon_state]-flaploop", src)
		playsound(src.loc, "sound/impact_sounds/Generic_Hit_1.ogg", 50, 1, -1)
		..()

		if(ismob(M))
			M.changeStatus("stunned", 2 SECONDS)
			M.changeStatus("weakened", 2 SECONDS)

	on_pet(mob/user)
		..()
		if(prob(10))
			src.visible_message("<b>[src]</b> honks!",2)
			playsound(src.loc, "sound/voice/animal/goose.ogg", 50, 1)

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

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/goose
	name = "goose egg"
	critter_type = /obj/critter/goose

/obj/critter/goose/swan
	name = "space swan"
	desc = "An offshoot species of <i>cygnus olor</i> adapted for space."
	icon_state = "swan"
	feather_color = "#FFFFFF"

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/swan
	name = "swan egg"
	critter_type = /obj/critter/goose/swan

#define PARROT_MAX_WORDS 64		// may as well try and be careful I guess
#define PARROT_MAX_PHRASES 32	// doesn't hurt, does it?

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
	butcherable = 1
	flying = 1
	health_gain_from_food = 2
	feed_text = "chirps happily!"
	flags = FPRINT | CONDUCT | USEDELAY | TABLEPASS | FLUID_SUBMERGE | FLUID_SUBMERGE
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
	var/being_offered_treasure = 0				// is someone already trying to give the bird something?  this is used so you can't sit there and do weird shit with the SPAWN_DBG(0) that happens when trying to give the bird something  :v
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

	hear_talk(mob/M as mob, messages, heardname, lang_id)
		if (!src.alive || src.sleeping || !text)
			return
		var/m_id = (lang_id == "english" || lang_id == "") ? 1 : 2
		if (M.singing)
			if (M.singing & BAD_SINGING || M.singing & LOUD_SINGING)
				spawn(3)
					if(get_dist(src,M) <= 1)
						src.CritterAttack(M)
					else
						flick("[src.species]-flaploop", src)
			else
				spawn(rand(4,10))
					chatter(1)

		var/boost = M.singing ? signing_learn_boost : 0
		if (prob(learn_words_chance + boost))
			src.learn_stuff(messages[m_id])
		if (prob(learn_phrase_chance + boost))
			src.learn_stuff(messages[m_id], 1)

	proc/learn_stuff(var/message, var/learn_phrase = 0)
		if (!message)
			return
		if (!islist(src.learned_words))
			src.learned_words = list()
		if (!islist(src.learned_phrases))
			src.learned_phrases = list()

		if (!learn_phrase && src.learn_words_max > 0 && src.learned_words.len >= src.learn_words_max)
			if (prob(5))
				var/dump_word = pick(src.learned_words)
				src.learned_words -= dump_word
			else
				return
		if (learn_phrase && src.learn_phrase_max > 0 && src.learned_phrases.len >= src.learn_phrase_max)
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
		else if (islist(src.learned_words) && src.learned_words.len)
			thing_to_say = pick(src.learned_words) // :monocle:
			thing_to_say = "[capitalize(thing_to_say)][pick(".", "!", "?", "...")]"
		// format
		var/quote = "\""
		if (sing)
			quote = "<img class=\"icon misc\" style=\"position: relative; bottom: -3px; \" src=\"[resource("images/radio_icons/note.png")]\">"
			thing_to_say = "<span style=\"color: bisque; font-style: italic;\">[thing_to_say]</span>"
		thing_to_say = "[quote][thing_to_say][quote]"
		src.say(thing_to_say)

	proc/say(var/text) // mehhh
		var/my_verb = pick("chatters", "chirps", "squawks", "mutters", "cackles", "mumbles")
		src.visible_message("<span class='game say'><span class='name'>[src]</span> [my_verb], [text]</span>")

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
			if ((get_dist(src, src.treasure_loc) <= 1) && (src.new_treasure.loc == src.treasure_loc))
				src.visible_message("\The [src] picks up [src.new_treasure]!")
				src.new_treasure.set_loc(src)
				src.treasure = src.new_treasure
				src.new_treasure = null
				src.treasure_loc = null
				src.impatience = 0
				walk_to(src, 0)
				return
			else if (src.new_treasure.loc == src.treasure_loc)
				if (get_dist(src, src.treasure_loc) > 4 || src.impatience > 8)
					src.new_treasure = null
					src.treasure_loc = null
					src.impatience = 0
					walk_to(src, 0)
					return
				else
					walk_to(src, src.treasure_loc)
					src.impatience ++

			else if (src.new_treasure.loc != src.treasure_loc)
				if (get_dist(src.new_treasure, src) > 4 || src.impatience > 8 || !isturf(src.new_treasure.loc))
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
				src.visible_message("<span class='combat'><b>\The [src.treasure] breaks!</b></span>")
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
				SPAWN_DBG(0.7 SECONDS)
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
				src.visible_message("<span class='notice'><b>[src]</b> [pick("chatters", "chirps", "squawks", "mutters", "cackles", "mumbles", "fusses", "preens", "clicks its beak", "fluffs up", "poofs up")]!</span>")
			if (prob(15))
				flick("[src.species]-flaploop", src)
			//if (prob(1) && prob(22) && (src.last_feather_time + 3000) <= world.time)
				//src.create_feather()
		return ..()

	seek_target()
		..()
		if (src.target)
			flick("[src.species]-flaploop", src)

	patrol_to(var/turf/towhat)
		.=..()
		if (prob(1) && prob(22) && (src.last_feather_time + 3000) <= world.time)
			src.create_feather()
		if (src.hops)
			var/opy = pixel_y
			animate( src )
			animate( src, pixel_y = 10, easing = SINE_EASING, time = ((towhat.y-y)>0)?3:1 )
			animate( pixel_y = opy, easing = SINE_EASING, time = 3 )
			playsound( get_turf(src), "sound/misc/boing/[rand(1,6)].ogg", 20, 1 )

	CritterAttack(mob/M as mob)
		src.attacking = 1
		flick("[src.species]-flaploop", src)
		if (iscarbon(M))
			if (prob(60)) //Go for the eyes!
				src.visible_message("<span class='combat'><B>[src]</B> pecks [M] in the eyes!</span>")
				playsound(src.loc, "sound/impact_sounds/Flesh_Stab_2.ogg", 30, 1)
				M.take_eye_damage(rand(2,10)) //High variance because the bird might not hit well
				if (prob(75) && !M.stat)
					M.emote("scream")
			else
				src.visible_message("<span class='combat'><B>[src]</B> bites [M]!</span>")
				playsound(src.loc, "swing_hit", 30, 0)
				random_brute_damage(M, 3,1)
			if (isliving(M))
				var/mob/living/H = M
				H.was_harmed(src)
		else if (isrobot(M))
			if (prob(10))
				src.visible_message("<span class='combat'><B>[src]</B> bites [M] and snips an important-looking cable!</span>")
				M:compborg_take_critter_damage(null, 0 ,rand(40,70))
				M.emote("scream")
			else
				src.visible_message("<span class='combat'><B>[src]</B> bites [M]!</span>")
				M:compborg_take_critter_damage(null, rand(1,5),0)

		if (prob(3))
			src.create_feather()

		SPAWN_DBG (rand(1,10))
			src.attacking = 0

	ChaseAttack(mob/M)
		..()
		playsound(src.loc, "sound/impact_sounds/Generic_Hit_1.ogg", 50, 1, -1)

		if (prob(3))
			src.create_feather()

		if (ismob(M))
			M.changeStatus("stunned", 2 SECONDS)
			M.changeStatus("weakened", 2 SECONDS)

	attack_ai(mob/user as mob)
		if (get_dist(user, src) < 2)
			return attack_hand(user)
		else
			return ..()

	attack_hand(mob/user as mob)
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
					user.pulling = src
					src.wanderer = 0
					if (src.task == "wandering")
						src.task = "thinking"
					src.wrangler = user
					src.visible_message("[src] steps onto [user]'s hand!")
			else if (user.a_intent == "grab" && src.treasure)
				if (prob(25))
					src.visible_message("<span class='combat'><b>[user]</b> [pick("takes", "wrestles", "grabs")] [treasure] from [src]!</span>")
					user.put_in_hand_or_drop(src.treasure)
					src.treasure = null
				else
					src.visible_message("<span class='combat'><b>[user]</b> tries to [pick("take", "wrestle", "grab")] [treasure] from [src], but [src] won't let go!</span>")
				if (prob(3))
					src.create_feather()
			else
				src.visible_message("<b>[user]</b> [pick("gives [src] a scritch", "pets [src]", "cuddles [src]", "snuggles [src]")]!")
				if (prob(15))
					src.visible_message("<span class='notice'><b>[src]</b> chirps happily!</span>")
				return
		else
			..()
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.sells_furniture && istype(W, /obj/item/spacecash)) // this is hella dumb
			var/obj/item/spacecash/C = W
			if (C.amount < 25)
				user.visible_message("[src] stares blankly at [user]'s [C].",\
				"[src] stares blankly at your [C]. Maybe it's not enough?")
				return

			var/FP
			var/FP_name

			if (C.amount >= 3000) // coffins
				FP = /obj/storage/closet/coffin
				FP_name = "Slutstation"
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
				FP = /obj/item/furniture_parts/wood_chair
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
				pool(C)
			else
				C.update_stack_appearance()

			FP = new FP(get_turf(src))
			if (istype(FP, /atom))
				var/atom/A = FP
				A.name = FP_name
			else
				return
			if (istype(FP, /obj/stool))
				var/obj/stool/S = FP
				S.anchored = 0
			else if (istype(FP, /obj/item/chair/folded))
				var/obj/item/chair/folded/F = FP
				F.c_color = "chair[pick("","-b","-y","-r","-g")]"
				F.icon_state = "folded_[F.c_color]"
				F.item_state = F.icon_state
			return

		else if (user.a_intent != INTENT_HARM && !istype(W, /obj/item/reagent_containers/food/snacks) && !istype(W, /obj/item/seed))
			if (src.being_offered_treasure)
				src.visible_message("<span class='combat'>[src] is distracted by [src.being_offered_treasure] and ignores [user]!</span>")
				return
			else
				src.visible_message("<span class='notice'><b>[user]</b> offers [W] to [src]!</span>")
				var/turf/T = get_turf(src) // we'll path back here to grab it if we have to
				src.wanderer = 0
				src.being_offered_treasure = "[user]'s [W]"
				SPAWN_DBG(rand(10,30)) // 1-3 seconds
					if (src)
						src.wanderer = initial(src.wanderer)
						src.being_offered_treasure = 0
						if (src.alive && !src.sleeping && user && W && user.find_in_hand(W)) // we have to do so many checks for such a short wait
							if (get_dist(user, T) > 2 || (src.treasure && prob(80)) || prob(50) || (src.loc != T && !step_to(src,T))) // too far, already has a thing and doesn't wanna switch, just doesn't like the thing offered, or we can't get to where we need to be
								src.visible_message("<span class='combat'>[src] doesn't take [W] from [user]!</span>")
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
								src.visible_message("<span class='notice'>\The [src] takes [W] from [user]!</span>")
		else
			return ..()

	proc/dance_response()
		if (!src.alive || src.sleeping)
			return
		if (prob(20))
			src.visible_message("<span class='notice'>\The [src] responds with a dance of its own!</span>")
			src.dance()
		else
			src.visible_message("<span class='notice'>\The [src] flaps and bobs [pick("to the beat", "in tune", "approvingly", "happily")].</span>")
			flick("[src.species]-flaploop", src)
		if (prob(3))
			src.create_feather()

	proc/dance()
		if (!src.alive || src.sleeping)
			return
		src.icon_state = "[src.species]-flap"
		SPAWN_DBG(3.8 SECONDS)
			src.icon_state = src.species
		return

	proc/apply_species(var/new_species = null)
		if (!(istext(new_species) || ispath(new_species)) || !islist(parrot_species)) // farrrrrtttt
			logTheThing("debug", null, null, "One of haine's stupid parrot things is broken, go whine at her until she fixes it (deets: type = [src.type], new_species = [isnull(new_species) ? "null" : new_species], parrot_species = [islist(parrot_species) ? "list" : "not list"])")
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
<b>Slutstation</b> - 3000<small>SSEK</small><br>
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
	butcherable = 1
	flying = 1
	chases_food = 1
	health_gain_from_food = 2
	feed_text = "caws happily!"
	flags = FPRINT | CONDUCT | USEDELAY | TABLEPASS | FLUID_SUBMERGE
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
	butcherable = 1
	flying = 1
	chases_food = 1
	health_gain_from_food = 2
	feed_text = "caws happily!"
	flags = FPRINT | CONDUCT | USEDELAY | TABLEPASS | FLUID_SUBMERGE
	var/feather_color = "#212121"
	var/last_feather_time = 0

	New()
		..()
		if (prob(5))
			src.name = replacetext(src.name, "crow", "raven")

	CritterAttack(mob/M as mob)
		src.attacking = 1
		flick("crow-flaploop", src)
		if (iscarbon(M))
			if (prob(60)) //Go for the eyes!
				src.visible_message("<span class='combat'><B>[src]</B> pecks [M] in the eyes!</span>")
				playsound(src.loc, "sound/impact_sounds/Flesh_Stab_2.ogg", 30, 1)
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
						src.visible_message("<span class='combat'><B>[src] [pick("tears","yanks","rips")] [M]'s eye out! <i>Holy shit!!</i></B></span>")
						E = H.drop_organ(chosen_eye)
						playsound(get_turf(M), "sound/impact_sounds/Flesh_Stab_1.ogg", 50, 1)
						E.set_loc(src.loc)
			if (isliving(M))
				var/mob/living/H = M
				H.was_harmed(src)
			else
				src.visible_message("<span class='combat'><B>[src]</B> bites [M]!</span>")
				playsound(src.loc, "swing_hit", 30, 0)
				random_brute_damage(M, 3,1)

		else if (isrobot(M))
			if (prob(10))
				src.visible_message("<span class='combat'><B>[src]</B> bites [M] and snips an important-looking cable!</span>")
				M:compborg_take_critter_damage(null, 0 ,rand(40,70))
				M.emote("scream")
			else
				src.visible_message("<span class='combat'><B>[src]</B> bites [M]!</span>")
				M:compborg_take_critter_damage(null, rand(1,5),0)

		SPAWN_DBG (rand(1,10))
			src.attacking = 0

	ChaseAttack(mob/M)
		..()
		playsound(src.loc, "sound/impact_sounds/Generic_Hit_1.ogg", 50, 1, -1)

		if (ismob(M))
			M.changeStatus("stunned", 2 SECONDS)
			M.changeStatus("weakened", 2 SECONDS)

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

/obj/critter/boogiebot
	name = "boogiebot"
	desc = "A robot that looks ready to get down at any moment."
	icon_state = "boogie"
	density = 1
	health = 20
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	angertext = "wonks angrily at"
	atk_text = "bashes into"
	atk_brute_amt = 2
	crit_text = "bashes really hard into"
	chase_text = "boogies right into"
	atk_brute_amt = 5
	generic = 0
	var/emagged = 0
	var/dance_forever = 0
	death_text = "%src% stops dancing forever."

	proc/do_a_little_dance()
		if (src.icon_state == "boogie")
			if (!src.muted)
				var/msg = pick("beeps and boops","does a little dance","gets down tonight","is feeling funky","is out of control","gets up to get down","busts a groove","begins clicking and whirring","emits an excited bloop","can't contain itself","can dance if it wants to")
				src.visible_message("<b>[src]</b> [msg]!",2)
			src.icon_state = pick("boogie-d1","boogie-d2","boogie-d3")
			// maybe later make it ambient play a short chiptune here later or at least some new sound effect
			if (emagged)
				SPAWN_DBG(0.5 SECONDS)
					for (var/mob/living/carbon/human/responseMonkey in orange(2, src)) // they don't have to be monkeys, but it's signifying monkey code
						LAGCHECK(LAG_MED)
						if (!can_act(responseMonkey, 0))
							continue
						responseMonkey.emote("dance")
			SPAWN_DBG(20 SECONDS)
				if (src) src.icon_state = "boogie"

	ai_think()
		..()
		if(task == "thinking" || task == "wandering")
			if(dance_forever || prob(2)) do_a_little_dance()

	seek_target()
		..()
		if(src.target)
			src.visible_message("<span class='combat'><b>[src]</b> [src.angertext] [src.target]!</span>")
			playsound(src.loc, 'sound/vox/bizwarn.ogg', 50, 1)

	CritterAttack(mob/M)
		playsound(src.loc, "swing_hit", 30, 0)
		..()

	ChaseAttack(mob/M)
		playsound(src.loc, "sound/impact_sounds/Generic_Hit_1.ogg", 50, 1, -1)
		..()

		if(ismob(M))
			M.changeStatus("stunned", 2 SECONDS)
			M.changeStatus("weakened", 2 SECONDS)

	attack_hand(mob/user as mob)
		if (src.alive && (user.a_intent != INTENT_HARM))
			src.visible_message("<span class='combat'><b>[user]</b> pets [src]!</span>")
			if(prob(10)) do_a_little_dance()
			return
		else
			. = ..()

	emag_act(mob/user, obj/item/card/emag/E)
		if (!src.emagged)
			if(user)
				boutput(user, "<span class='alert'>You short out the [src]'s dancing intensity setting to 'flashmob'.</span>")
			src.visible_message("<span class='alert'><b>[src] lights up with determination!</b></span>")
			src.emagged = TRUE
			return 1
		return 0

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
	butcherable = 2
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
			SPAWN_DBG(0)
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
		src.visible_message("<span class='combat'><B>[src]</B> weaves around [M]'s legs!</span>")
		if (ismob(M))
			var/tostun = rand(0,3)
			var/toweak = rand(0,3)
			if (toweak)
				M.visible_message("<span class='combat'><B>[M]</B> trips!</span>")
			M.changeStatus("stunned", tostun * 10)
			M.changeStatus("weakened", toweak * 10)

	CritterAttack(mob/M)
		..()

	attack_hand(mob/user as mob)
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
			src.visible_message("<span class='combat'><b>[user]</b> swings at [src], but misses!</span>")
			playsound(get_turf(src), "sound/impact_sounds/Generic_Swing_1.ogg", 50, 0)
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
	butcherable = 1
	health_gain_from_food = 2
	feed_text = "happily begins washing its food!"
	pet_text = list("pets", "cuddles", "pats", "snuggles")
	flags = FPRINT | CONDUCT | USEDELAY | TABLEPASS | FLUID_SUBMERGE

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

/obj/critter/slug
	name = "slug"
	desc = "It doesn't have any arms or legs so it's kind of like a snake, but it's gross and unthreatening instead of cool and dangerous."
	icon_state = "slug"
	density = 0
	health = 10
	aggressive = 0
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	butcherable = 1
	flags = FPRINT | CONDUCT | USEDELAY | TABLEPASS | FLUID_SUBMERGE
	var/slime_chance = 22

	attack_hand(mob/user as mob)
		if (src.alive && (user.a_intent != INTENT_HARM))
			src.visible_message("<span class='combat'><b>[user]</b> pets [src]!</span>")
			return
		if (prob(95))
			if(src.alive)
				src.visible_message("<span class='combat'><B>[user] stomps [src], killing it instantly!</B></span>")
				CritterDeath()
				return
			else
				src.visible_message("<span class='combat'><B>[user] squishes [src] a little more for good measure.</B></span>")
				return
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/shaker))
			var/obj/item/shaker/S = W
			if (S.stuff == "salt" && S.shakes < 15)
				src.visible_message("<span class='alert'>[src] shrivels up!</span>")
				src.CritterDeath()
				S.shakes ++
				return
		..()

	Move(var/atom/NewLoc, direct)
		.=..()
		if (prob(src.slime_chance) && (istype(src.loc, /turf/simulated/floor) || istype(src.loc, /turf/unsimulated/floor)))
			if (locate(/obj/decal/cleanable/slime) in src.loc)
				return
			else
				make_cleanable( /obj/decal/cleanable/slime,src.loc)

/obj/critter/slug/snail
	name = "snail"
	desc = "It's basically just a slug with a shell on it. This makes it less gross."
	icon_state = "snail"
	health = 20
	slime_chance = 11



// Urs party crabs
/obj/critter/crab
	name = "crab"
	desc = "Snip Snip."
	icon_state = "crab"
	butcherable = 1
	density = 0
	health = 20
	aggressive = 0
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 1
	atksilicon = 1
	firevuln = 1
	brutevuln = 1
	generic = 1
	angertext = "snips angrily at"
	death_text = "%src% dies."

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (src.alive && istype(W, /obj/item/clothing/head/cowboy))
			user.visible_message("<b>[user]</b> gives \the [src.name] \the [W]!","You give \the [src.name] \the [W].")
			qdel(W)
			src.visible_message("\The [src.name] starts dancing!")
			new /obj/critter/crab/party(get_turf(src))
			qdel(src)
		else
			..()

	seek_target()
		..()
		if(src.target)
			src.visible_message("<span class='combat'><b>[src]</b> [src.angertext] [src.target]!</span>")
			playsound(src.loc, "sound/items/Scissor.ogg", 30, 0, -1)

	CritterAttack(mob/M)
		if(ismob(M))
			src.attacking = 1
			src.visible_message("<span class='combat'><B>[src]</B> snips [src.target] with its claws!</span>")
			random_brute_damage(src.target, 2)
			SPAWN_DBG(0)
				playsound(src.loc, "sound/items/Wirecutter.ogg", 30, 0, -1)
				sleep(0.3 SECONDS)
				playsound(src.loc, "sound/items/Wirecutter.ogg", 30, 0, -1)
			SPAWN_DBG(rand(1,10))
				src.attacking = 0
		return


/obj/critter/crab/party
	name = "party crab"
	desc = "This crab is having way more fun than you."
	icon_state = "crab_party"
	generic = 0
	var/dance_forever = 0
	death_text = "%src% stops dancing forever."

	proc/do_a_little_dance()
		if (!src.muted)
			var/msg = pick("gets down","yee claws", "is feelin' it now", "dances to that song! The one that goes \"beep boo boo bop boo boo beep\"", "does a little dance","dances like no one's watching")
			src.visible_message("<b>[src]</b> [msg]!",2)
		flick(pick("crab_party-getdown","crab_party-hop","crab_party-partyhard"),src)

	ai_think()
		..()
		if(task == "thinking" || task == "wandering")
			if(dance_forever || prob(2)) do_a_little_dance()

	ChaseAttack(mob/M)
		src.visible_message("<span class='combat'><B>[src]</B> parties hard into [M]!</span>")
		playsound(src.loc, pick(sounds_hit), 50, 1, -1)

		if(ismob(M))
			M.changeStatus("stunned", 2 SECONDS)
			M.changeStatus("weakened", 1 SECOND)

	proc/dance_response()
		if (!src.alive || src.sleeping)
			return
		SPAWN_DBG(rand(0, 10))
			src.do_a_little_dance()

obj/critter/frog
	name = "frog"
	desc = "Ribbit."
	icon_state = "frog"
	death_text = "%src% croaks."
	butcherable = 1
	density = 0
	health = 20
	aggressive = 0
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 1
	atksilicon = 1
	firevuln = 1
	brutevuln = 1
	generic = 1
	atk_text = "hops into"
	angertext = "croaks angrily at"
	chase_text = "hops after"
