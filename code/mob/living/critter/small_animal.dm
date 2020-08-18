/* -=-= What's here =-=-
 - small_critter parent
  - mice
   - Remy
  - cats
   - Jones
  - dogs (default is pug)
  	- corgi
  	- George
  	- shiba
  - birds (default is parrots)
   - owls
    - large owls
     - Hooty
   - turkeys
   - timberdoodles
   - seagulls
    - gannets
   - crows
   - geese
  - cockroaches
  - ferrets
  - possums
   - Morty
  - floating eye
  - pigs
  - clownspiders
   - cluwnespiders
  - bats
   - angry bats
   - Dr. Acula
  - wasps
  - raccoons
  - slugs
   - snails
  - butterflies
  - moths
  - flies
  - lobsters
  - boogiebots
  - figures
todo: add more small animals!
*/
/mob/living/critter/small_animal
	name = "critter"
	real_name = "critter"
	desc = "you shouldn't be seeing this!"
	density = 0
	custom_gib_handler = /proc/gibs
	hand_count = 1
	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	butcherable = 1
	name_the_meat = 1
	max_skins = 1
	var/health_brute = 20 // moved up from birds since more than just they can use this, really
	var/health_brute_vuln = 1
	var/health_burn = 20
	var/health_burn_vuln = 1

	var/fur_color = 0
	var/eye_color = 0

	var/is_pet = null // null = autodetect



	New(loc)
		if(isnull(src.is_pet))
			src.is_pet = (copytext(src.name, 1, 2) in uppercase_letters)
		if(in_centcom(loc) || current_state >= GAME_STATE_PLAYING)
			src.is_pet = 0
		if(src.is_pet)
			pets += src
		..()

		src.add_stam_mod_max("small_animal", -(STAMINA_MAX*0.5))

	disposing()
		if(src.is_pet)
			pets -= src
		..()

	setup_healths()
		add_hh_flesh(-(src.health_brute), src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(-(src.health_burn), src.health_burn, src.health_burn_vuln)
		add_health_holder(/datum/healthHolder/toxin)
		add_health_holder(/datum/healthHolder/brain)

	CanPass(atom/mover, turf/target, height=0, air_group=0)
		if (!src.density && istype(mover, /obj/projectile))
			return prob(50)
		else
			return ..()

	death(var/gibbed)
		if (!gibbed)
			src.unequip_all()
		..()

	canRideMailchutes()
		return src.fits_under_table

	proc/reduce_lifeprocess_on_death() //used for AI mobs we dont give a dang about them after theyre dead
		remove_lifeprocess(/datum/lifeprocess/blood)
		remove_lifeprocess(/datum/lifeprocess/canmove)
		remove_lifeprocess(/datum/lifeprocess/disability)
		remove_lifeprocess(/datum/lifeprocess/fire)
		remove_lifeprocess(/datum/lifeprocess/hud)
		remove_lifeprocess(/datum/lifeprocess/mutations)
		remove_lifeprocess(/datum/lifeprocess/organs)
		remove_lifeprocess(/datum/lifeprocess/sight)
		remove_lifeprocess(/datum/lifeprocess/skin)
		remove_lifeprocess(/datum/lifeprocess/statusupdate)

/* =============================================== */
/* -------------------- Mouse -------------------- */
/* =============================================== */

/mob/living/critter/small_animal/mouse
	name = "space mouse"
	real_name = "space mouse"
	desc = "A mouse.  In space."
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1
	hand_count = 2
	icon_state = "mouse_white"
	icon_state_dead = "mouse_white-dead"
	speechverb_say = "squeaks"
	speechverb_exclaim = "squeals"
	speechverb_ask = "squeaks"
	health_brute = 8
	health_burn = 8


	New()
		..()
		fur_color =	pick("#101010", "#924D28", "#61301B", "#E0721D", "#D7A83D","#D8C078", "#E3CC88", "#F2DA91", "#F21AE", "#664F3C", "#8C684A", "#EE2A22", "#B89778", "#3B3024", "#A56b46")
		eye_color = "#FFFFF"

	setup_overlays()
		fur_color = src.client?.preferences.AH.customization_first_color
		eye_color = src.client?.preferences.AH.e_color
		var/image/overlay = image('icons/misc/critter.dmi', "mouse_colorkey")
		overlay.color = fur_color
		src.UpdateOverlays(overlay, "hair")

		var/image/overlay_eyes = image('icons/misc/critter.dmi', "mouse_eyes")
		overlay_eyes.color = eye_color
		src.UpdateOverlays(overlay_eyes, "eyes")

	death()
		src.ClearAllOverlays()
		var/image/overlay = image('icons/misc/critter.dmi', "mouse_colorkey-dead")
		overlay.color = fur_color
		src.UpdateOverlays(overlay, "hair")
		..()

	full_heal()
		..()
		src.ClearAllOverlays()
		src.setup_overlays()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/mouse_squeak.ogg", 80, 1)
					return "<span class='emote'><b>[src]</b> squeaks!</span>"
			if ("smile")
				if (src.emote_check(voluntary, 50))
					return "<span class='emote'><b>[src]</b> wiggles [his_or_her(src)] tail happily!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
			if ("smile")
				return 1
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	attackby(obj/item/I, mob/M)
		if(istype(I, /obj/item/reagent_containers/food/snacks/ingredient/cheese) && ishuman(M))
			src.visible_message("[M] feeds \the [src] some [I].", "[M] feeds you some [I].")
			for(var/damage_type in src.healthlist)
				var/datum/healthHolder/hh = src.healthlist[damage_type]
				hh.HealDamage(5)
			qdel(I)
			return
		. = ..()

/mob/living/critter/small_animal/mouse/weak
	health_brute = 2
	health_burn = 2

/* -------------------- Remy -------------------- */

/mob/living/critter/small_animal/mouse/remy
	name = "Remy"
	desc = "A rat.  In space... wait, is it wearing a chefs hat?"
	icon_state = "remy"
	icon_state_dead = "remy-dead"
	health_brute = 33
	health_burn = 33
	pull_w_class = 3

	setup_overlays()
		return

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

/* ============================================= */
/* -------------------- Cat -------------------- */
/* ============================================= */

/mob/living/critter/small_animal/cat
	name = "space cat"
	real_name = "space cat"
	desc = "A cat. In space."
	icon_state = "cat1"
	icon_state_dead = "cat1-dead"
	hand_count = 2
	speechverb_say = "meows"
	speechverb_exclaim = "yowls"
	speechverb_ask = "mews"
	health_brute = 15
	health_burn = 15
	flags = TABLEPASS
	fits_under_table = 1
	add_abilities = list(/datum/targetable/critter/pounce)
	var/cattype = 1
	var/randomize_name = 1
	var/randomize_look = 1
	var/catnip = 0

	New()
		..()
		if (src.randomize_name)
			src.name = pick(cat_names)
			src.real_name = src.name
		if (src.randomize_look)
#ifdef HALLOWEEN
			src.cattype = 3 //Black cats for halloween.
#else
			src.cattype = rand(1,9)
#endif
			src.icon_state = "cat[cattype]"
			src.icon_state_alive = src.icon_state
			src.icon_state_dead = "cat[cattype]-dead"

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (!isdead(src) && istype(W, /obj/item/plant/herb/catnip))
			user.visible_message("<b>[user]</b> gives [src] \the [W]!",\
			"You give [src] \the [W].")
			src.catnip_effect()
			user.u_equip(W)
			qdel(W)
		else
			..()

	proc/catnip_effect()
		if (src.catnip)
			return
		src.catnip = 45
		src.visible_message("[src]'s eyes dilate.")

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (getStatusDuration("burning"))
			return ..()

		if (isdead(src))
			return 0

		if (src.catnip)
			SPAWN_DBG(0)
				var/x = rand(2,4)
				while (x-- > 0)
					src.pixel_x = rand(-6,6)
					src.pixel_y = rand(-6,6)
					sleep(0.2 SECONDS)

			if (prob(10))
				src.visible_message("[src] [pick("purrs","frolics","rolls about","does a cute cat thing of some sort")]!")

			if (src.catnip-- < 1)
				src.visible_message("[src] calms down.")
		..()

	death(var/gibbed)
		if (!gibbed && prob(5))
			SPAWN_DBG(3 SECONDS)
				if (src && isdead(src))
					src.visible_message("<b>[src]</b> comes back to life, good thing [he_or_she(src)] has 9 lives!")
					src.full_heal()
					src.icon_state = "cat[cattype]"
					return
		else
			return ..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","meow")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/cat.ogg", 80, 1)
					return "<span class='emote'><b>[src]</b> meows!</span>"
			if ("smile","purr")
				if (src.emote_check(voluntary, 30))
					return "<span class='emote'><b>[src]</b> purrs.</span>"
			if ("frown","tail")
				if (src.emote_check(voluntary, 30))
					return "<span class='emote'><b>[src]</b>'s tail swishes back and forth aggressively!</span>" // cat do dis when mad.  mad catte
			if ("snap","hiss")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/cat_hiss.ogg", 80, 1)
					return "<span class='emote'><b>[src]</b> hisses!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","meow")
				return 2
			if ("smile","purr")
				return 2
			if ("frown","tail")
				return 1
			if ("snap","hiss")
				return 2
		return ..()

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(10))
			src.visible_message("[src] purrs!",\
			"You purr!")

/mob/living/critter/small_animal/cat/weak
	add_abilities = list()
	health_brute = 10
	health_burn = 10

/* -------------------- Jones -------------------- */

/mob/living/critter/small_animal/cat/jones
	name = "Jones"
	desc = "Jones the cat."
	health = 30
	randomize_name = 0
	randomize_look = 0
	health_brute = 30
	health_burn = 30
	var/swiped = 0

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (isdead(src) || cattype == "-emagged")
			return 0
		src.cattype = "-emagged"
		src.icon_state = "cat-emagged"
		src.icon_state_alive = src.icon_state
		src.icon_state_dead = "cat-emagged-dead"
		if (user)
			user.show_text("You swipe down [src]'s back in a petting motion...")
			src.show_text("[user] swipes the card down your back in a petting motion...")
		return 1

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (istype(W, /obj/item/card/emag))
			emag_act(usr, W)
		if (istype(W, /obj/item/card/id/blank_deluxe))
			if (W.desc == "Some type of microchipped payment card. Looks like it's designed to deal with catcoins.")//Can't change descs
				if (!swiped && W.stamina_cost == 1)
					if (user)
						user.show_text("You swipe down [src]'s back in a petting motion...")
						src.show_text("[user] swipes the card down your back in a petting motion...")
					src.visible_message("<span class='combat'>[src] vomits out a wad of paper!</span>",\
					"<span class='combat'>You vomit out a wad of paper!</span>") //Jones City Puzzle
					make_cleanable(/obj/decal/cleanable/vomit, src.loc)
					new /obj/item/paper/jones_note(src.loc)
					swiped++
					W.stamina_cost = 2 //Can only use the card once.
		else
			..()

/* ============================================= */
/* -------------------- Dog -------------------- */
/* ============================================= */

/mob/living/critter/small_animal/dog
	name = "space dog"
	real_name = "space dog"
	desc = "A dog. In space."
	icon_state = "pug"
	icon_state_dead = "pug-lying"
	hand_count = 2
	add_abilities = list(/datum/targetable/critter/pounce)
	speechverb_say = "barks"
	speechverb_exclaim = "howls"
	speechverb_ask = "yips"
	health_brute = 30
	health_burn = 30
	var/dogtype = "pug"
	var/sound/sound_bark = "sound/voice/animal/dogbark.ogg"
	var/gabe = 0 //sniff. bark bork. brork.
	pull_w_class = 4

	OnMove()
		if(client && client.player && client.player.shamecubed)
			loc = client.player.shamecubed
			return

		makeWaddle(src)
		.=..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","bark")
				if (src.emote_check(voluntary, 50))
					if (src.gabe == 1) //sniff. bark bork. brork.
						playsound (get_turf(src), "gabe", 80, 1)
						return "<span class='emote'><b>[src]</b> barks??</span>"
					playsound(get_turf(src), "sound/voice/animal/dogbark.ogg", 80, 1)
					return "<span class='emote'><b>[src]</b> barks!</span>"
			if ("smile","tail")
				if (src.emote_check(voluntary, 30))
					return "<span class='emote'><b>[src]</b> wags [his_or_her(src)] tail happily!</span>"
			if ("frown","growl")
				if (src.emote_check(voluntary, 30))
					return "<span class='emote'><b>[src]</b>'s growls!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","bark")
				return 2
			if ("smile","tail")
				return 1
			if ("frown","growl")
				return 2
		return ..()

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(30))
			src.icon_state = "[src.dogtype]-lying"
			src.setStatus("paralysis", 100)
			src.setStatus("stunned", 100)
			src.setStatus("weakened", 100)
			src.visible_message("<span class='notice'>[src] flops on [his_or_her(src)] back! Scratch that belly!</span>",\
			"<span class='notice'>You flop on your back!</span>")
			SPAWN_DBG(3 SECONDS)
				if (src && !isdead(src))
					src.delStatus("paralysis")
					src.changeStatus("stunned", 10 SECONDS)
					src.delStatus("weakened")
					src.icon_state = src.dogtype


	pug
		weak
			add_abilities = list()
			health_brute = 10
			health_burn = 10

/* -------------------- Reverse Pug -------------------- */
// the people demanded it
/mob/living/critter/small_animal/dog/reverse
	name = "god ecaps"
	real_name = "god ecaps"
	icon_state = "gup"
	icon_state_dead = "pug-lying"
	dogtype = "gup"
	speechverb_say = "skrab"
	speechverb_exclaim = "slwoh"
	speechverb_ask = "spiy"
	speechverb_stammer = "sremmats"
	speechverb_gasp = "spsag"

	mob_flags = SPEECH_REVERSE
	/*
	say(var/message)
		message = strip_html(trim(copytext(sanitize_noencode(message), 1, MAX_MESSAGE_LEN)))
		if (!message)
			return
		if (dd_hasprefix(message, "*") && !src.stat)
			return ..()
		message = reverse_text(message)
		..(message)*/
	visible_message(var/msg, var/self, var/blind, var/group)
		msg = "<span style='-ms-transform: rotate(180deg)'>[msg]</span>"
		if(self)
			self = "<span style='-ms-transform: rotate(180deg)'>[self]</span>"
		if(blind)
			blind = "<span style='-ms-transform: rotate(180deg)'>[blind]</span>"
		return ..(msg,self,blind,group)

	audible_message(var/msg)
		msg = "<span style='-ms-transform: rotate(180deg)'>[msg]</span>"
		return ..(msg)



	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","bark")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/dogbark.ogg", 80, 0, 0, -1)
					return "<span class='emote'><b>[src]</b> bark bark bark!</span>"

/* -------------------- Corgi -------------------- */

/mob/living/critter/small_animal/dog/corgi
	icon_state = "corgi"
	icon_state_dead = "corgi-lying"
	dogtype = "corgi"

	weak
		add_abilities = list()
		health_brute = 10
		health_burn = 10

/* -------------------- George -------------------- */

/mob/living/critter/small_animal/dog/george
	name = "George"
	real_name = "George"
	desc = "Good dog."
	icon_state = "george"
	icon_state_dead = "george-lying"
	butcherable = 0
	health_brute = 100
	health_burn = 100
	dogtype = "george"
	var/playing_dead = 0 // code mostly just c/p from possums, I'll shove this up on the parent somewhere at some point

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","bark","howl")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/howl[rand(1,6)].ogg", 80, 1)
					return "<span class='emote'><b>[src]</b> [pick("barks","howls")]!</span>"
		return ..()

	specific_emote_type(var/act)
		switch (act)
			if ("scream","bark","howl")
				return 2
		return ..()

	Life(datum/controller/process/mobs/parent)
		src.play_dead()
		. = ..(parent)

	death(var/gibbed)
		if (gibbed)
			return ..()
		else if (src.playing_dead)
			return
		else
			src.play_dead(rand(40,60))

	attackby(var/obj/item/I, var/mob/M)
		..()
		if (I.force && src.playing_dead)
			src.playing_dead = 1
			src.play_dead()

	proc/play_dead(var/addtime = 0)
		if (addtime > 0) // we're adding more time
			if (src.playing_dead <= 0) // we don't already have time on the clock
				src.icon_state = icon_state_dead ? icon_state_dead : "[icon_state]-dead" // so we gotta show the message + change icon + etc
				src.visible_message("<span class='alert'><b>[src]</b> [pick("tires","tuckers out","gets pooped")] and lies down!!</span>",\
				"<span class='alert'><b>You get [pick("tired","tuckered out","pooped")] and lie down!!</b></span>")
				src.set_density(0)
			src.playing_dead = clamp((src.playing_dead + addtime), 0, 100)
		if (src.playing_dead <= 0)
			return
		if (src.playing_dead == 1)
			src.playing_dead = 0
			src.set_density(1)
			src.full_heal()
			src.visible_message("<span class='notice'><b>[src]</b> wags [his_or_her(src)] tail and gets back up!</span>")
			boutput(src, "<span class='notice'><b>You wag your tail and get back up!</b></span>") // visible_message doesn't go through when this triggers
			src.hud.update_health()
			return
		else
			setunconscious(src)
			src.setStatus("paralysis", 100)
			src.setStatus("stunned", 100)
			src.setStatus("weakened", 100)
			src.sleeping = 10
			src.playing_dead--
			src.hud.update_health()

	proc/howl()
		if (prob(60))
			for (var/mob/O in hearers(src, null))
				O.show_message("<span class='combat'><b>[src]</b> [pick("howls","bays","whines","barks","croons")] to the music! [capitalize(he_or_she(src))] thinks [he_or_she(src)]'s singing!</span>")
			playsound(get_turf(src), "sound/voice/animal/howl[rand(1,6)].ogg", 100, 0)

/* -------------------- Shiba -------------------- */

/mob/living/critter/small_animal/dog/shiba
	icon_state = "shiba"
	icon_state_dead = "shiba-lying"
	dogtype = "shiba"
	var/randomize_shiba = 1

	New()
		..()
		if (src.randomize_shiba)
			src.name = pick(shiba_names)
			src.real_name = src.name

	weak
		add_abilities = list()
		health_brute = 10
		health_burn = 10

/* -------------------- Illegal -------------------- */

/mob/living/critter/small_animal/dog/illegal
	name = "highly illegal dog"
	real_name = "highly illegal dog"
	desc = "A highly illegal dog. In space."
	icon_state = "illegal"
	icon_state_dead = "illegal-lying"
	dogtype = "illegal"

/* -------------------- Vaguely Illegal -------------------- */

/mob/living/critter/small_animal/dog/patrick
	name = "patrick"
	real_name = "patrick"
	desc = "patrick. In space."
	icon_state = "patrick"
	icon_state_dead = "patrick-dead"
	dogtype = "patrick"

/* ============================================== */
/* -------------------- Bird -------------------- */
/* ============================================== */

/mob/living/critter/small_animal/bird
	name = "space parrot"
	real_name = "space parrot"
	desc = "A spacefaring species of parrot."
	icon = 'icons/misc/bird.dmi'
	icon_state = "parrot"
	icon_state_dead = "parrot-dead"
	speechverb_say = "chirps"
	speechverb_exclaim = "shrieks"
	speechverb_ask = "squawks"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "cackles"
	death_text = "%src% lets out a final weak squawk and keels over."
	flags = TABLEPASS
	fits_under_table = 1
	hand_count = 2
	pet_text = list("pets","cuddles","snuggles","scritches")
	add_abilities = list(/datum/targetable/critter/peck)
	var/species = "parrot"
	var/hops = 0
	var/hat_offset_y = -5
	var/hat_offset_x = 0
	var/feather_color = "#ba1418"
	var/last_feather_time = 0
	var/bird_call_msg = list("squawks", "shrieks")
	var/bird_call_sound = list("sound/voice/animal/squawk1.ogg","sound/voice/animal/squawk2.ogg", "sound/voice/animal/squawk3.ogg")
	var/icon_state_poof = null // atm used for male turkeys and nothing else
	var/good_grip = 1 // they can hold any sized item because they are stronk birbs, otherwise small_critter limb
	health_brute = 15
	health_burn = 15
	pull_w_class = 4

	New(loc, nspecies)
		..()
		if (nspecies)
			src.apply_species(nspecies, 0)

	get_desc()
		..()
		if (src.equipped())
			. += "<br>[src] is holding \a [src.equipped()]."

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		if (src.good_grip >= 1)
			HH.limb = new /datum/limb
		else if (src.good_grip > 0) //values of 0.5 will give us medium strength
			HH.limb = new /datum/limb/small_critter/med
		else
			HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "claw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "beak"					// name for the dummy holder
		HH.can_hold_items = 0

	update_inhands()
		return // stop taping things to bird face, unwanted.  do not.

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears(src)
		equipment += new /datum/equipmentHolder/head/bird(src)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					if (bird_call_sound)
						playsound(get_turf(src), bird_call_sound, 80, 1)
					return "<span class='emote'><b>[src]</b> [islist(src.bird_call_msg) ? pick(src.bird_call_msg) : src.bird_call_msg]!</span>"
			if ("smile","wink","poof")
				if (src.emote_check(voluntary, 30))
					if (src.icon_state_poof)
						src.icon_state = src.icon_state_poof
						SPAWN_DBG(3 SECONDS)
							if (src && !isdead(src))
								src.icon_state = src.species
					if (prob(3))
						SPAWN_DBG(0)
							src.create_feather()
					return "<span class='emote'><b>[src]</b> [pick("poofs", "fluffs")] up!</span>"
			if ("snap","click")
				if (src.emote_check(voluntary, 50))
					if (src.species == "goose" || src.species == "swan") // hardcoded thing because im loaf 2day.
						playsound(get_turf(src), "sound/voice/animal/cat_hiss.ogg", 80, 1)
						return "<span class='emote'><b>[src]</b> hisses!</span>"
					else
						return "<span class='emote'><b>[src]</b> clicks [his_or_her(src)] beak!</span>"
			if ("dance","flap")
				if (src.emote_check(voluntary, 50))
					if (prob(20))
						src.icon_state = "[src.species]-flap"
						if (prob(3))
							SPAWN_DBG(0)
								src.create_feather()
						SPAWN_DBG(3.8 SECONDS)
							if (src && !isdead(src))
								src.icon_state = src.species
						return "<span class='emote'><b>[src]</b> dances!</span>"
					else
						flick("[src.species]-flaploop", src)
						if (prob(3))
							SPAWN_DBG(0)
								src.create_feather()
						return "<span class='emote'><b>[src]</b> flaps and bobs happily!</span>"
			if ("hiss")
				if ((src.species == "goose" || src.species == "swan") && src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/cat_hiss.ogg", 80, 1)
					return "<span class='emote'><b>[src]</b> hisses!</span>"
			if ("wave","fuss","fussle")
				if (src.emote_check(voluntary, 50))
					var/holding_thing = src.equipped()
					if (holding_thing)
						if (prob(3))
							SPAWN_DBG(0)
								src.create_feather()
						return "<span class='emote'><b>[src]</b> [pick("fusses with", "picks at", "pecks at", "throws around", "waves around", "nibbles on", "chews on", "tries to pry open")] [holding_thing].</span>"

		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
			if ("smile","wink","poof")
				return 1
			if ("snap","click")
				return 2
			if ("dance","flap")
				return 1
			if ("hiss")
				return 2
			if ("wave","fuss","fussle")
				return 1
		return ..()

	proc/apply_species(var/new_species = null, var/apply_random = 0)
		if (!(istext(new_species) || ispath(new_species)) || !islist(parrot_species)) // farrrrrtttt
			return

		if (islist(mob_bird_species) && mob_bird_species.Find(new_species))
			var/mob/living/critter/small_animal/bird/B = mob_bird_species[new_species]

			if ((src.species != "goose" && src.species != "swan") && (new_species == "goose" || new_species == "swan")) // add a tackle
				abilityHolder.addAbility(/datum/targetable/critter/tackle)
			else if ((src.species == "goose" || src.species == "swan") && (new_species != "goose" && new_species != "swan"))
				abilityHolder.removeAbility(/datum/targetable/critter/tackle) // remove a tackle
			abilityHolder.updateButtons()

			src.name = initial(B.name)
			src.real_name = initial(B.real_name)
			src.desc = initial(B.desc)
			src.species = initial(B.species)
			src.gender = initial(B.gender)
			src.icon = initial(B.icon)
			src.icon_state = initial(B.icon_state)
			src.icon_state_alive = initial(B.icon_state_alive)
			src.icon_state_dead = initial(B.icon_state_dead)
			src.icon_state_poof = initial(B.icon_state_poof)
			src.flags = initial(B.flags)
			src.fits_under_table = initial(B.fits_under_table)
			src.hops = initial(B.hops)
			src.hat_offset_y = initial(B.hat_offset_y)
			src.hat_offset_x = initial(B.hat_offset_x)
			src.feather_color = initial(B.feather_color)
			src.good_grip = initial(B.good_grip)
			src.bird_call_msg = initial(B.bird_call_msg)
			src.bird_call_sound = initial(B.bird_call_sound)
			src.health_brute = initial(B.health_brute)
			src.health_burn = initial(B.health_burn)
			src.update_clothing()
			return

		var/datum/species_info/parrot/info = ispath(new_species) ? new_species : parrot_species[new_species]
		if (!ispath(info))
			info = special_parrot_species[new_species]
			if (!ispath(info))
				return

		if (apply_random)
			var/list/rand_s = initial(info.subspecies)
			if (islist(rand_s) && rand_s.len)
				info = pick(rand_s)

		src.name = initial(info.name)
		src.real_name = src.name
		src.desc = initial(info.desc)
		src.species = initial(info.species)
		src.gender = initial(info.gender)
		src.icon = initial(info.icon)
		src.icon_state = src.species
		src.icon_state_alive = src.species
		src.icon_state_dead = "[src.species]-dead"
		src.pixel_x = initial(info.pixel_x)
		src.hops = initial(info.hops)
		src.hat_offset_y = initial(info.hat_offset_y)
		src.hat_offset_x = initial(info.hat_offset_x)
		src.feather_color = params2list(initial(info.feather_color))
		src.update_clothing()

	Move(var/atom/NewLoc, direct)
		.=..()
		if (prob(1) && prob(22) && (src.last_feather_time + 3000) <= world.time)
			src.create_feather()
		if (src.hops)
			var/opy = pixel_y
			animate( src )
			animate( src, pixel_y = 10, easing = SINE_EASING, time = ((NewLoc.y-y)>0)?3:1 )
			animate( pixel_y = opy, easing = SINE_EASING, time = 3 )
			playsound( get_turf(src), "sound/misc/boing/[rand(1,6)].ogg", 20, 1 )

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

var/list/mob_bird_species = list("smallowl" = /mob/living/critter/small_animal/bird/owl,
	"owl" = /mob/living/critter/small_animal/bird/owl/large,
	"hooty" = /mob/living/critter/small_animal/bird/owl/large/hooty,
	"then" = /mob/living/critter/small_animal/bird/turkey/hen,
	"ttom" = /mob/living/critter/small_animal/bird/turkey/gobbler,
	"gull" = /mob/living/critter/small_animal/bird/seagull,
	"gannet" = /mob/living/critter/small_animal/bird/seagull/gannet,
	"crow" = /mob/living/critter/small_animal/bird/crow,
	"goose" = /mob/living/critter/small_animal/bird/goose,
	"swan" = /mob/living/critter/small_animal/bird/goose/swan,
	"cassowary" = /mob/living/critter/small_animal/bird/cassowary,
	"penguin" = /mob/living/critter/small_animal/bird/penguin)

/* -------------------- Random Parrot -------------------- */

/mob/living/critter/small_animal/bird/random
	species = null
	New()
		..()
		if (!src.species)
			if (prob(1) && prob(10))
				src.apply_species(pick(special_parrot_species))
				return
			src.apply_species(pick(parrot_species))
			return

/* -------------------- Selectable Parrot -------------------- */

/mob/living/critter/small_animal/bird/selected
	species = null
	New()
		..()
		SPAWN_DBG(0)
			if (!src.species && src.client && islist(parrot_species) && islist(special_parrot_species))
				var/new_species = input(src, "Select Species", "Select Species") as anything in (parrot_species + special_parrot_species)
				if (new_species)
					src.apply_species(new_species)

/* -------------------- Cassowary -------------------- */

/mob/living/critter/small_animal/bird/cassowary
	name = "cassowary"
	real_name = "cassowary"
	desc = "An exotic bird from the far away land of Space Australia."
	icon_state = "cassowary"
	icon_state_dead = "cassowary-dead"
	death_text = "%src% lets out a final squawk and keels over."
	good_grip = 0.5
	flags = null
	fits_under_table = 0
	species = "cassowary"

/* -------------------- Penguin -------------------- */

/mob/living/critter/small_animal/bird/penguin
	name = "penguin"
	real_name = "penguin"
	desc = "Its a penguin. They like the cold."
	icon_state = "penguin"
	icon_state_dead = "penguin-dead"
	death_text = "%src% lets out a final squawk and keels over."
	good_grip = 0
	flags = null
	fits_under_table = 0
	species = "penguin"

/* -------------------- Owl -------------------- */

/mob/living/critter/small_animal/bird/owl
	name = "space owl"
	real_name = "space owl"
	desc = "Did you know? By 2063, it is expected that there will be more owls on Earth than human beings."
	icon_state = "smallowl"
	icon_state_dead = "smallowl-dead"
	speechverb_say = "hoos"
	speechverb_exclaim = "shrieks"
	speechverb_ask = "warbles"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "cackles"
	death_text = "%src% lets out a final weak hoot and keels over."
	feather_color = list("#803427","#7d5431")
	good_grip = 0
	species = "smallowl"
	bird_call_msg = list("hoots", "hoos")
	bird_call_sound = "sound/voice/animal/hoot.ogg"

	attackby(obj/item/W as obj, mob/M as mob)
		if(istype(W, /obj/item/plutonium_core/hootonium_core)) //Owls interestingly are capable of absorbing hootonium into their bodies harmlessly. This is the only safe method of removing it.
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
						playsound(get_turf(T), pick('sound/impact_sounds/Slimy_Splat_1.ogg','sound/misc/meat_plop.ogg'), 100, 1)
						make_cleanable( /obj/decal/cleanable/greenpuke,T)

				new /obj/item/power_stones/Owl(src.loc)
		else
			. = ..()


/* -------------------- Large Owl -------------------- */

/mob/living/critter/small_animal/bird/owl/large
	icon_state = "owl"
	icon_state_dead = "owl-dead"
	species = "owl"
	feather_color = list("#b59b76","#87683d","#632c0c")
	flags = null
	fits_under_table = 0
	health_brute = 30
	health_burn = 30
	good_grip = 0.5

	attackby(obj/item/W as obj, mob/M as mob)
		if(istype(W, /obj/item/plutonium_core/hootonium_core)) //Owls interestingly are capable of absorbing hootonium into their bodies harmlessly. This is the only safe method of removing it.
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


/* -------------------- Hooty -------------------- */

/mob/living/critter/small_animal/bird/owl/large/hooty
	icon_state = "hooty"
	icon_state_dead = "hooty-dead"
	species = "hooty"
	feather_color = "#806055"

/* -------------------- Hooter -------------------- */

/mob/living/critter/small_animal/bird/owl/large/hooter
	icon_state = "bhooty"
	icon_state_dead = "bhooty-dead"
	species = "bhooty"
	desc = "A space owl wearing a bikini. Hang on. That's not a bikini! That's just pink feathers!"
	feather_color = list("#806055","#ff0066")
	add_abilities = list(/datum/targetable/critter/hootat)

/* -------------------- Turkey -------------------- */

/mob/living/critter/small_animal/bird/turkey
	name = "space turkey"
	real_name = "space turkey"
	desc = "A turkey that came from space. Or maybe went to space. Who knows how it got here?"
	icon_state = "then"
	icon_state_dead = "then-dead"
	speechverb_say = "gobbles"
	speechverb_exclaim = "calls"
	speechverb_ask = "warbles"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "cackles"
	death_text = "%src% lets out a final weak gobble and keels over."
	feather_color = "#632c0c"
	flags = null
	fits_under_table = 0
	bird_call_msg = "gobbles"
	bird_call_sound = "sound/voice/animal/turkey.ogg"
	good_grip = 0.5
	health_brute = 20
	health_burn = 20
	species = null
	gender = FEMALE

	New()
		..()
		var/set_gender = initial(src.gender)
		if (!src.species)
			src.species = pick("then", "ttom")
			src.apply_species(src.species)
			if (src.species == "ttom")
				set_gender = MALE
			else
				set_gender = FEMALE
		SPAWN_DBG(0)
			src.gender = set_gender // stop changing!!  stay how I set you!!!!

/* -------------------- Turkey Hen -------------------- */

/mob/living/critter/small_animal/bird/turkey/hen
	species = "then"
	feather_color = "#632c0c"

/* -------------------- Turkey Gobbler -------------------- */

/mob/living/critter/small_animal/bird/turkey/gobbler
	icon_state = "ttom"
	species = "ttom"
	icon_state_dead = "ttom-dead"
	icon_state_poof = "ttom-poof"
	health_brute = 30
	health_burn = 30
	gender = MALE

/* -------------------- Timberdoodle -------------------- */

/mob/living/critter/small_animal/bird/timberdoodle
	name = "space timberdoodle"
	real_name = "space timberdoodle"
	desc = "More commonly known as a woodcock, the timberdoodle is a small bird within the <i>scolopacidae</i> family. It is commonly hunted for sport."
	species = "doodle"
	icon_state = "doodle"
	icon_state_dead = "doodle-dead"
	icon_state_poof = "doodle-poof"
	speechverb_say = "eents"
	speechverb_exclaim = "calls"
	speechverb_ask = "peents"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "chirps"
	death_text = "%src% lets out a final weak eent and keels over."
	feather_color = list("#ffd0a4","#cc9475","#b85a39","#572c26")
	bird_call_msg = list("peents", "eents")
	bird_call_sound = "sound/voice/animal/woodcock.ogg"
	good_grip = 0
	health_brute = 20
	health_burn = 20

/mob/living/critter/small_animal/bird/timberdoodle/strong
	health_brute = 50
	health_burn = 50
	good_grip = 1

/* -------------------- Seagull -------------------- */

/mob/living/critter/small_animal/bird/seagull
	name = "space gull"
	real_name = "space gull"
	desc = "A spacefaring species of bird from the <i>Laridae</i> family."
	icon_state = "gull"
	icon_state_dead = "gull-dead"
	speechverb_say = "laughs"
	speechverb_exclaim = "calls"
	speechverb_ask = "caws"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "cackles"
	death_text = "%src% lets out a final weak caw and keels over."
	feather_color = list("#ffffff","#949494","#353535")
	good_grip = 0
	species = "gull"

/* -------------------- Gannet -------------------- */

/mob/living/critter/small_animal/bird/seagull/gannet // they're technically not gulls but they're gunna use basically all the same var settings so, um
	name = "space gannet"
	real_name = "space gannet"
	desc = "A spacefaring species of <i>morus bassanus</i>."
	icon_state = "gannet"
	icon_state_dead = "gannet-dead"
	species = "gannet"
	feather_color = list("#ffffff","#d4bb2f","#414141")

/* -------------------- Crow -------------------- */

/mob/living/critter/small_animal/bird/crow
	name = "space crow"
	real_name = "space crow"
	desc = "A spacefaring species of bird from the <i>Corvidae</i> family."
	icon_state = "crow"
	icon_state_dead = "crow-dead"
	speechverb_say = "caws"
	speechverb_exclaim = "calls"
	speechverb_ask = "caws"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "cackles"
	death_text = "%src% lets out a final weak caw and keels over."
	feather_color = "#212121"
	good_grip = 1
	species = "crow"
	add_abilities = list(/datum/targetable/critter/peck/crow)

	New()
		..()
		if (prob(5))
			src.name = replacetext(src.name, "crow", "raven")
			if (src.name != initial(src.name))
				src.real_name = src.name

/* -------------------- Goose -------------------- */

/mob/living/critter/small_animal/bird/goose
	name = "space goose"
	real_name = "space goose"
	desc = "An offshoot species of <i>branta canadensis</i> adapted for space."
	icon_state = "goose"
	icon_state_dead = "goose-dead"
	speechverb_say = "honks"
	speechverb_exclaim = "calls"
	speechverb_ask = "warbles"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "cackles"
	death_text = "%src% lets out a final weak honk and keels over."
	feather_color = list("#393939","#f2ebd5","#68422a","#ffffff")
	flags = null
	fits_under_table = 0
	good_grip = 0.5
	bird_call_msg = "honks"
	bird_call_sound = "sound/voice/animal/goose.ogg"
	species = "goose"
	health_brute = 30
	health_burn = 30
	add_abilities = list(/datum/targetable/critter/peck,
						/datum/targetable/critter/tackle)

/* -------------------- Goose -------------------- */

/mob/living/critter/small_animal/bird/goose/swan
	name = "space swan"
	real_name = "space swan"
	desc = "An offshoot species of <i>cygnus olor</i> adapted for space."
	icon_state = "swan"
	icon_state_dead = "swan-dead"
	feather_color = "#FFFFFF"
	species = "swan"

/* =================================================== */
/* -------------------- Cockroach -------------------- */
/* =================================================== */

/mob/living/critter/small_animal/cockroach
	name = "cockroach"
	real_name = "cockroach"
	desc = "An unpleasant insect that lives in filthy places."
	icon_state = "roach"
	icon_state_dead = "roach-dead"
	speechverb_say = "clicks"
	speechverb_exclaim = "screeches"
	speechverb_ask = "chitters"
	health_brute = 5
	health_burn = 5
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1

	setup_overlays()
		fur_color = src.client?.preferences.AH.customization_first_color
		eye_color = src.client?.preferences.AH.e_color

		var/image/overlay = image('icons/misc/critter.dmi', "roach_colorkey")
		overlay.color = fur_color
		src.UpdateOverlays(overlay, "hair")

		var/image/overlay_eyes = image('icons/misc/critter.dmi', "roach_eyes")
		overlay_eyes.color = eye_color
		src.UpdateOverlays(overlay_eyes, "eyes")

	death()
		src.ClearAllOverlays()
		//appears to be missing a dead colorkey
		//var/image/overlay = image('icons/misc/critter.dmi', "roach_colorkey-dead")
		//overlay.color = fur_color
		//src.UpdateOverlays(overlay, "hair")
		..()


	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "weird grabby foot thing"
		HH.limb_name = "foot"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","chitter")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/bugchitter.ogg", 80, 1)
					return "<span class='emote'><b>[src]</b> chitters!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","chitter")
				return 2
		return ..()

/* =================================================== */
/* -------------------- Scorpion --------------------- */
/* =================================================== */

/mob/living/critter/small_animal/scorpion
	name = "scorpion"
	real_name = "scorpion"
	desc = "Ack! Get it away! AAAAAAAA."
	icon_state = "scorpion"
	icon_state_dead = "scorpion-dead"
	speechverb_say = "clicks"
	speechverb_exclaim = "screeches"
	speechverb_ask = "chitters"
	health_brute = 5
	health_burn = 5
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "weird grabby foot thing"
		HH.limb_name = "foot"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","chitter")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/bugchitter.ogg", 80, 1)
					return "<span class='emote'><b>[src]</b> chitters!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","chitter")
				return 2
		return ..()

/mob/living/critter/small_animal/cockroach/weak
	health_brute = 1
	health_burn = 1

/mob/living/critter/small_animal/cockroach/robo
	name = "roboroach"
	real_name = "roboroach"
	desc = "The vermin of the future!"
	health_brute = 10
	health_burn = 10
	icon_state = "robot_roach"
	icon_state_dead = "robot_roach-dead"
	pull_w_class = 3
	meat_type = /obj/item/reagent_containers/food/snacks/burger/roburger

	base_move_delay = 1.6
	base_walk_delay = 2.1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "weird grabby foot thing"
		HH.limb_name = "foot"

	setup_overlays()
		return


	weak
		health_brute = 5
		health_burn = 5

/* ================================================ */
/* -------------------- Ferret -------------------- */
/* ================================================ */

/mob/living/critter/small_animal/meatslinky // ferrets for wire
	name = "space ferret"
	real_name = "space ferret"
	desc = "A ferret that came from space. Or maybe went to space. Who knows how it got here?"
	icon_state = "ferret"
	icon_state_dead = "ferret-dead"
	hand_count = 2
	speechverb_say = "chatters"
	speechverb_exclaim = "squeaks"
	flags = TABLEPASS
	fits_under_table = 1
	var/freakout = 0
	add_abilities = list(/datum/targetable/critter/trip)

	New()
		..()

		//50% chance to be a dark-colored ferret
		if (prob(50))
			src.icon_state = "ferret-dark"
			src.icon_state_dead = "ferret-dark-dead"

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (getStatusDuration("burning"))
			return ..()

		if (isdead(src))
			return 0

		if (src.freakout)
			SPAWN_DBG(0)
				var/x = rand(2,4)
				while (x-- > 0)
					src.pixel_x = rand(-6,6)
					src.pixel_y = rand(-6,6)
					sleep(0.2 SECONDS)

			if (prob(5))
				animate_spin(src, pick("L","R"))

			if (prob(10))
				src.visible_message("[src] [pick("wigs out","frolics","rolls about","freaks out","goes wild","wiggles","wobbles")]!")

			if (src.freakout-- < 1)
				src.visible_message("[src] calms down.")
		else if (!src.client && prob(2))
			src.freakout = rand(30,40)
		..()


/* ================================================ */
/* -------------------- Frog ---------------------- */
/* ================================================ */

/mob/living/critter/small_animal/frog
	name = "frog"
	real_name = "frog"
	desc = "Ribbit."
	icon_state = "frog"
	icon_state_dead = "frog-dead"
	hand_count = 2
	speechverb_say = "croaks"
	speechverb_exclaim = "croaks"
	butcherable = 0
	health_brute = 15
	health_burn = 15
	pet_text = list("gently baps", "pets", "cuddles")

	New()
		if (prob(80))
			if (prob(1))
				src.icon_state = "frog-space"
				src.icon_state_dead = "frog-space-dead"
			else
				src.icon_state = "frog[pick("-blue","-gold","-red","-straw","-tree","-glass")]"
				src.icon_state_dead = "[src.icon_state]-dead"
		..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "foot"
		HH.limb_name = "pads"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "mouth"
		HH.can_hold_items = 0


	weak
		health_brute = 10
		health_burn = 10

/* ================================================ */
/* -------------------- Possum -------------------- */
/* ================================================ */

/mob/living/critter/small_animal/opossum
	name = "space opossum"
	real_name = "space opossum"
	desc = "A possum that came from space. Or maybe went to space. Who knows how it got here?"
	icon_state = "possum"
	icon_state_dead = "possum-dead"
	hand_count = 2
	speechverb_say = "hisses"
	speechverb_exclaim = "barks"
	butcherable = 0
	health_brute = 15
	health_burn = 15
	pet_text = list("gently baps", "pets", "cuddles")
	var/playing_dead = 0

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	setup_hands()
		..() // both of these do no damage (in return, possums are basically immortal)
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/possum
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small/possum
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0

	Life(datum/controller/process/mobs/parent)
		src.play_dead()
		. = ..(parent)

	death(var/gibbed)
		if (gibbed)
			return ..()
		else if (src.playing_dead)
			return
		else
			src.play_dead(rand(40,60))

	attackby(var/obj/item/I, var/mob/M)
		..()
		if (I.force && src.playing_dead)
			src.playing_dead = 1
			src.play_dead()

	proc/play_dead(var/addtime = 0)
		if (addtime > 0) // we're adding more time
			if (src.playing_dead <= 0) // we don't already have time on the clock
				src.icon_state = icon_state_dead ? icon_state_dead : "[icon_state]-dead" // so we gotta show the message + change icon + etc
				src.visible_message("<span class='alert'><b>[src]</b> dies!</span>",\
				"<span class='alert'><b>You play dead!</b></span>")
				src.set_density(0)
			src.playing_dead = clamp((src.playing_dead + addtime), 0, 100)
		if (src.playing_dead <= 0)
			return
		if (src.playing_dead == 1)
			src.playing_dead = 0
			src.set_density(1)
			src.full_heal()
			src.visible_message("<span class='notice'><b>[src]</b> stops playing dead and gets back up!</span>")
			boutput(src, "<span class='notice'><b>You stop playing dead and get back up!</b></span>") // visible_message doesn't go through when this triggers
			src.hud.update_health()
			return
		else
			setunconscious(src)
			src.setStatus("paralysis", 60)
			src.setStatus("stunned", 60)
			src.setStatus("weakened", 60)
			src.sleeping = 10
			src.playing_dead--
			src.hud.update_health()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					return "<span class='emote'><b>[src]</b> shrieks!</span>"
			if ("snap","hiss")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/cat_hiss.ogg", 80, 1)
					return "<span class='emote'><b>[src]</b> hisses!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","snap","hiss")
				return 2
		return ..()

/* -------------------- Morty -------------------- */

/mob/living/critter/small_animal/opossum/morty
	name = "Morty"
	real_name = "Morty"

/* ====================================================== */
/* -------------------- Floating Eye -------------------- */
/* ====================================================== */
// vOv  it's in pets_small_animals.dm so it gets to live here too!
/mob/living/critter/small_animal/floateye
	name = "floating thing"
	real_name = "floating thing"
	desc = "You have never seen something like this before."
	icon_state = "floateye"
	icon_state_dead = "floateye-dead"
	health_brute = 10
	health_burn = 10

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "weird tentacle things"
		HH.limb_name = "tentacles"

	on_pet(mob/user)
		if (..())
			return 1
		src.visible_message("<span class='alert'>You feel uncomfortable now.</span>")

/* ============================================= */
/* -------------------- Pig -------------------- */
/* ============================================= */

/mob/living/critter/small_animal/pig
	name = "space pig"
	real_name = "space pig"
	desc = "A pig. In space."
	icon_state = "pig"
	icon_state_dead = "pig-dead"
	density = 1
	speechverb_say = "oinks"
	speechverb_exclaim = "squeals"
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	name_the_meat = 0

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					return "<span class='emote'><b>[src]</b> squeals!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(10))
			src.visible_message("[src] purrs![prob(20) ? " Wait, what?" : null]",\
			"You purr!")


/* ============================================= */
/* -------------------- Bat -------------------- */
/* ============================================= */

/mob/living/critter/small_animal/bat // in objcritter form this is a large animal but I don't care I'm making it a small thing now
	name = "bat"
	real_name = "bat"
	desc = "skreee!"
	hand_count = 2
	icon_state = "bat"
	icon_state_dead = "bat-dead"
	speechverb_say = "squeaks"
	speechverb_exclaim = "shrieks"
	speechverb_ask = "squeaks"
	health_brute = 8
	health_burn = 8

	New()
		..()
		if (prob(1))
			src.name = replacetext(src.name, "bat", "bart")
			if (src.name != initial(src.name))
				src.real_name = src.name

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					return "<span class='emote'><b>[src]</b> shrieks!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	Move()
		.=..()
		if (prob(15))
			playsound(get_turf(src), "rustle", 10, 1)

	death(gibbed)
		if (!gibbed && src.reagents)
			src.reagents.add_reagent("woolofbat", 50, null)
		..()

/* -------------------- Angry Bat -------------------- */

/mob/living/critter/small_animal/bat/angry
	name = "angry bat"
	real_name = "angry bat"
	desc = "It doesn't look too happy!"
	icon_state = "scarybat"
	health_brute = 25
	health_burn = 25

/* -------------------- Dr. Acula -------------------- */

/mob/living/critter/small_animal/bat/doctor
	name = "Dr. Acula"
	real_name = "Dr. Acula"
	desc = "If you ask nicely he might even write you a preskreeeption!"
	icon_state = "batdoctor"
	icon_state_dead = "batdoctor-dead"
	health_brute = 30
	health_burn = 30

/* ============================================== */
/* -------------------- Wasp -------------------- */
/* ============================================== */

/mob/living/critter/small_animal/wasp
	name = "space wasp"
	real_name = "space wasp"
	desc = "A wasp in space."
	icon_state = "spacebee"
	icon_state_dead = "spacebee-dead"
	speechverb_say = "buzzes"
	speechverb_exclaim = "screeches"
	speechverb_ask = "hums"
	health_brute = 10
	health_burn = 10
	reagent_capacity = 100
	flags = TABLEPASS
	fits_under_table = 1
	add_abilities = list(/datum/targetable/critter/wasp_sting)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "weird grabby foot thing"
		HH.limb_name = "foot"

	death(var/gibbed)
		if (!gibbed)
			src.reagents.add_reagent("toxin", 50, null)
			src.reagents.add_reagent("histamine", 50, null)
		return ..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("flip","dance")
				if (src.emote_check(voluntary, 50) && !src.shrunk)
					SPAWN_DBG(1 SECOND)
						animate_bumble(src)
					return null
			if ("snap","buzz")
				if (src.emote_check(voluntary, 30))
					return "<span class='emote'><b>[src]</b> buzzes!</span>" // todo?: find buzz noise
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("flip","dance")
				return 1
			if ("snap","buzz")
				return 2
		return ..()

/* ================================================= */
/* -------------------- Raccoon -------------------- */
/* ================================================= */

/mob/living/critter/small_animal/raccoon
	name = "space raccoon"
	real_name = "space raccoon"
	desc = "A raccoon that came from space. Or maybe went to space. Who knows how it got here?"
	icon_state = "raccoon"
	icon_state_dead = "raccoon-dead"
	hand_count = 2
	health_brute = 25
	health_burn = 25
	speechverb_say = "chatters"
	speechverb_exclaim = "barks"
	speechverb_ask = "squeaks"
	pet_text = list("pets","cuddles","snuggles","pats")
	flags = TABLEPASS
	fits_under_table = 1
	add_abilities = list(/datum/targetable/critter/pounce)

	butcherable = 1
	skinresult = /obj/item/clothing/head/raccoon
	max_skins = 1

	pull_w_class = 4

	New()
		..()
		if (prob(1))
			src.name = replacetext(src.name, "raccoon", "washbear")
			src.desc = replacetext(src.desc, "raccoon", "washbear")
			if (src.name != initial(src.name))
				src.real_name = src.name

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					return "<span class='emote'><b>[src]</b> [pick("shriek","yowl","bark")]s!</span>"
			if ("shriek","yowl","bark")
				if (src.emote_check(voluntary, 50))
					return "<span class='emote'><b>[src]</b> [act]s!</span>"
			if ("snap","hiss")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/cat_hiss.ogg", 80, 1)
					return "<b>[src]</b> hisses!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","shriek","yowl","bark","snap","hiss")
				return 2
		return ..()

/* =============================================== */
/* -------------------- Snail -------------------- */
/* =============================================== */

/mob/living/critter/small_animal/slug
	name = "slug"
	real_name = "slug"
	desc = "It doesn't have any arms or legs so it's kind of like a snake, but it's gross and unthreatening instead of cool and dangerous."
	icon_state = "slug"
	icon_state_dead = "slug-dead"
	speechverb_say = "blorps"
	speechverb_exclaim = "bloops"
	speechverb_ask = "burbles"
	health_brute = 5
	health_burn = 5
	flags = TABLEPASS
	fits_under_table = 1
	hand_count = 1
	base_move_delay = 6
	base_walk_delay = 8
	var/slime_chance = 22

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "mouth thing"			// name for the dummy holder
		HH.can_hold_items = 0

	Move(var/atom/NewLoc, direct)
		.=..()
		if (prob(src.slime_chance) && (istype(src.loc, /turf/simulated/floor) || istype(src.loc, /turf/unsimulated/floor)))
			if (locate(/obj/decal/cleanable/slime) in src.loc)
				return
			else
				make_cleanable(/obj/decal/cleanable/slime,src.loc)

/* -------------------- Snail -------------------- */

/mob/living/critter/small_animal/slug/snail
	name = "snail"
	real_name = "snail"
	desc = "It's basically just a slug with a shell on it. This makes it less gross."
	icon_state = "snail"
	icon_state_dead = "snail-dead"
	health_brute = 10
	health_burn = 10
	slime_chance = 11

/* =============================================== */
/* ------------------ Butterfly ------------------ */
/* =============================================== */

/mob/living/critter/small_animal/butterfly
	name = "butterfly"
	real_name = "butterfly"
	desc = "It's a beautiful butterfly! How did it get here?"
	hand_count = 2
	icon_state = "butterfly1"
	icon_state_dead = "butterfly1-dead"
	speechverb_say = "whispers"
	speechverb_exclaim = "hums"
	speechverb_ask = "muses"
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/butter
	name_the_meat = 0
	death_text = "%src% disintegrates."
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1
	health_brute = 8
	health_burn = 8
	var/butterflytype = 1

	New()
		..()
		butterflytype = rand(1,5)
		src.icon_state = "butterfly[butterflytype]"
		src.icon_state_dead = "butterfly[butterflytype]-dead"

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "delicate limb things"
		HH.limb_name = "legs"


		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "proboscis"
		HH.limb_name = "mouth"
		HH.can_hold_items = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/butterflyscream.ogg", 80, 1)
					return "<span class='emote'><b>[src]</b> cheeps.</span>"
			if ("flutter","dance")
				if (src.emote_check(voluntary, 50)) //copied from moonwalk code
					SPAWN_DBG(0)
						for (var/i = 0, i < 4, i++)
							src.pixel_x+= 2
							sleep(0.2 SECONDS)
						for (var/i = 0, i < 4, i++)
							src.pixel_x-= 2
							sleep(0.2 SECONDS)
					return "<span class='emote'><b>[src]</b> flutters.</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","flutter","dance")
				return 2
		return ..()

/mob/living/critter/small_animal/butterfly/weak
	health_brute = 2
	health_burn = 2


/* =============================================== */
/* ------------------ Moth ----------------------- */
/* =============================================== */
// What do you mean moths arent butterflies. SHUT UP. GO AWAY.
/mob/living/critter/small_animal/butterfly/moth
	name = "moth"
	real_name = "moth"
	desc = "Ew a moth. Hope it doesn't get into the wardrobe."

	New()
		..()
		var/type = pick("silk","cecropia","deathshead","rosymaple")
		icon_state = "moth-[type]"
		icon_state_dead = "moth-[type]-dead"

/* =============================================== */
/* ------------------ Fly	   ------------------- */
/* =============================================== */


/mob/living/critter/small_animal/fly
	name = "fly"
	real_name = "fly"
	desc = "It's a pesky housefly! How'd it get into space? No clue."
	hand_count = 2
	icon_state = "fly"
	icon_state_dead = "fly-dead"
	speechverb_say = "bzzs"
	speechverb_exclaim = "bzzts"
	speechverb_ask = "pesters"
	death_text = "%src% splats."
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1
	base_move_delay = 1.3
	base_walk_delay = 1.8
	health_brute = 8
	health_burn = 8

	New()
		..()
		abilityHolder = new /datum/abilityHolder/critter(src)
		//todo : move to add_abilities list because its cleaner that way
		abilityHolder.addAbility(/datum/targetable/critter/vomit)
		abilityHolder.updateButtons()

	Move()
		..()
		misstep_chance = 23

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "conniving crawlers"
		HH.limb_name = "arms"


		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "proboscis"
		HH.limb_name = "mouth"
		HH.can_hold_items = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/fly_buzz.ogg", 90, 1)
					return "<span class='emote'><b>[src]</b> bzzts annoyingly.</span>"

/mob/living/critter/small_animal/fly/weak
	health_brute = 2
	health_burn = 2

/* =============================================== */
/* ------------------- mosquite ------------------- */
/* =============================================== */


/mob/living/critter/small_animal/mosquito
	name = "mosquito"
	real_name = "mosquito"
	desc = "It's a pesky mosquito! How'd it get into space? No clue."
	hand_count = 2
	icon_state = "sqwibby"
	icon_state_dead = "sqwibby-dead"
	speechverb_say = "bzzs"
	speechverb_exclaim = "bzzts"
	speechverb_ask = "pesters"
	death_text = "%src% splats."
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1
	base_move_delay = 1.3
	base_walk_delay = 1.8
	health_brute = 8
	health_burn = 8

	New()
		..()
		abilityHolder = new /datum/abilityHolder/critter(src)
		//todo : move to add_abilities list because its cleaner that way
		abilityHolder.addAbility(/datum/targetable/critter/blood_bite)
		abilityHolder.updateButtons()

	Move()
		..()
		misstep_chance = 23

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "conniving crawlers"
		HH.limb_name = "arms"


		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "proboscis"
		HH.limb_name = "mouth"
		HH.can_hold_items = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/fly_buzz.ogg", 90, 1)
					return "<span class='emote'><b>[src]</b> bzzts annoyingly.</span>"

/mob/living/critter/small_animal/mosquito/weak
	health_brute = 2
	health_burn = 2

/mob/living/critter/small_animal/lobsterman
	name = "lobster"
	real_name = "lobster"
	desc = "An unpleasantly humanoid lobster."
	icon_state = "lobsterman"
	var/start_icon = "lobsterman"
	icon_state_dead = "lobsterman-dead"

	speechverb_say = "clicks"
	speechverb_exclaim = "screeches"
	speechverb_ask = "chitters"
	hand_count = 2
	health_brute = 20
	health_burn = 20
	pull_w_class = 4

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/claw
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "lobster claw"
		HH.limb_name = "lobster claw"


		HH = hands[2]
		HH.limb = new /datum/limb/claw
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "lobster claw"
		HH.limb_name = "lobster claw"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","chitter")
				if (src.emote_check(voluntary, 50))
					src.icon_state = "lobsterman-screech"
					SPAWN_DBG(1.5 SECONDS)
						if (src && !isdead(src))
							src.icon_state = start_icon
					playsound(get_turf(src), "sound/voice/animal/bugchitter.ogg", 80, 1,0,0,0.8)
					return "<span class='emote'><b>[src]</b> screeches!</span>"

			if ("dance","flap")
				if (src.emote_check(voluntary, 50))
					src.icon_state = "lobsterman-clack"
					SPAWN_DBG(3 SECONDS)
						if (src && !isdead(src))
							src.icon_state = start_icon
					return "<span class='emote'><b>[src]</b> clacks their claws!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","chitter")
				return 2
			if ("dance","flap")
				return 1
		return ..()

/mob/living/critter/small_animal/lobsterman/rock
	name = "rock lobster"
	real_name = "rock lobster"
	icon_state = "lobsterman-rock"
	start_icon = "lobsterman-rock"
	icon_state_dead = "lobsterman-dead"
	desc = "Not a rock."


/mob/living/critter/small_animal/boogiebot
	name = "Boogiebot"
	real_name = "Boogiebot"
	desc = "A robot that looks ready to get down at any moment."
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1
	hand_count = 1
	icon_state = "boogie"
	icon_state_dead = "boogie-dead"
	speechverb_say = "sings"
	speechverb_exclaim = "yells"
	speechverb_ask = "asks"
	health_brute = 20
	health_burn = 20

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/screams/Robot_scream_2.ogg", 50, 1, 0.1, 2.6)
					return "<span class='emote'><b>[src]</b> squeaks!</span>"
			if ("dance")
				if (src.emote_check(voluntary, 50))
					src.icon_state = pick("boogie-d1","boogie-d2","boogie-d3")
					SPAWN_DBG(3 SECONDS)
						if (src && !isdead(src))
							src.icon_state = initial(icon_state)
					var/msg = pick("beeps and boops","does a little dance","gets down tonight","is feeling funky","is out of control","gets up to get down","busts a groove","begins clicking and whirring","emits an excited bloop","can't contain itself","can dance if it wants to")
					return "<span class='emote'><b>[src]</b> [msg]!</span>"
			if ("birdwell", "burp")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), 'sound/vox/birdwell.ogg', 50, 1)
					return "<span class='emote'><b>[src]</b> birdwells.</span>"
			if ("flip")
				var/mode = pick("honk", "fart", "burp", "squeak", "cat", "harmonica", "vuvuzela", "bang", "buzz", "gunshot", "siren", "coo", "rimshot", "trombone")
				switch(mode)
					if ("honk") playsound(src.loc, "sound/musical_instruments/Bikehorn_1.ogg", 50, 1)
					if ("fart")
						if (farting_allowed)
							playsound(src.loc, "sound/voice/farts/poo2_robot.ogg", 50, 1)
					if ("burp") playsound(src.loc, "sound/voice/burp_alien.ogg", 50, 1)
					if ("squeak") playsound(src.loc, "sound/misc/clownstep1.ogg", 50, 1)
					if ("cat") playsound(src.loc, "sound/voice/animal/cat.ogg", 50, 1)
					if ("harmonica")
						var/which = rand(1,3)
						switch(which)
							if(1) playsound(src.loc, "sound/musical_instruments/Harmonica_1.ogg", 50, 1)
							if(2) playsound(src.loc, "sound/musical_instruments/Harmonica_2.ogg", 50, 1)
							if(3) playsound(src.loc, "sound/musical_instruments/Harmonica_3.ogg", 50, 1)
					if ("vuvuzela") playsound(src.loc, "sound/musical_instruments/Vuvuzela_1.ogg", 45, 1)
					if ("bang") playsound(src.loc, "sound/impact_sounds/Metal_Hit_Heavy_1.ogg", 40, 1)
					if ("buzz") playsound(src.loc, "sound/machines/warning-buzzer.ogg", 50, 1)
					if ("gunshot") playsound(src.loc, "sound/weapons/Gunshot.ogg", 50, 1)
					if ("siren") playsound(src.loc, "sound/machines/siren_police.ogg", 50, 1)
					if ("coo") playsound(src.loc, "sound/voice/babynoise.ogg", 50, 1)
					if ("rimshot") playsound(src.loc, "sound/misc/rimshot.ogg", 50, 1)
					if ("trombone") playsound(src.loc, "sound/musical_instruments/Trombone_Failiure.ogg", 50, 1)
					else playsound(src.loc, "sound/machines/buzz-two.ogg", 50, 1)

		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
			if ("dance")
				return 1
			if ("birdwell", "burp")
				return 2
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "tiny hand"
		HH.limb_name = "tiny hand"

/mob/living/critter/small_animal/boogiebot/weak
	health_brute = 4
	health_burn = 4

/mob/living/critter/small_animal/figure
	name = "collectable figure"
	real_name = "collectable figure"
	desc = "<b><span class='alert'>WARNING:</span> CHOKING HAZARD</b> - Small parts. Not for children under 3 years."
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1
	hand_count = 2
	icon = 'icons/obj/items/figures.dmi'
	icon_state = "fig-"
	icon_state_dead = "fig-"
	health_brute = 20
	health_burn = 20
	var/datum/figure_info/info = 0
	var/voice_gender = "male"

	New()
		..()

		if (prob(50))
			voice_gender = "male"
		else
			voice_gender = "female"

		var/datum/figure_info/randomInfo
		if (prob(1))
			randomInfo = pick(figure_patreon_rarity)
		else if (prob(10))
			randomInfo = pick(figure_high_rarity)
		else
			randomInfo = pick(figure_low_rarity)
		src.info = new randomInfo(src)
		src.name = "[src.info.name] figure"
		src.real_name = src.name
		src.icon_state = "fig-[src.info.icon_state]"
		if (src.info.rare_varieties.len && prob(5))
			src.icon_state = "fig-[pick(src.info.rare_varieties)]"
		else if (src.info.varieties.len)
			src.icon_state = "fig-[pick(src.info.varieties)]"
		icon_state_dead = src.icon_state

		if (prob(1)) // rarely give a different material
			if (prob(1)) // VERY rarely give a super-fancy material
				var/list/rare_material_varieties = list("gold", "spacelag", "diamond", "ruby", "garnet", "topaz", "citrine", "peridot", "emerald", "jade", "aquamarine",
				"sapphire", "iolite", "amethyst", "alexandrite", "uqill", "uqillglass", "telecrystal", "miracle", "starstone", "flesh", "blob", "bone", "beeswax", "carbonfibre")
				src.setMaterial(getMaterial(pick(rare_material_varieties)))
			else // silly basic "rare" varieties of things that should probably just be fancy paintjobs or plastics, but whoever made these things are idiots and just made them out of the actual stuff.  I guess.
				var/list/material_varieties = list("steel", "glass", "silver", "quartz", "rosequartz", "plasmaglass", "onyx", "jasper", "malachite", "lapislazuli")
				src.setMaterial(getMaterial(pick(material_varieties)))

	death(var/gibbed)
		if (!gibbed)
			new /obj/item/toy/figure(src.loc, info)
			ghostize()
			playsound(src.loc, "sound/effects/suck.ogg", 40, 1, -1, 0.6)
			qdel(src)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), (voice_gender == "male" ? "sound/voice/screams/male_scream.ogg" : "sound/voice/screams/female_scream.ogg"), 40, 1, 0.1, 3)
					return "<span class='emote'><b>[src]</b> squeaks!</span>"
			if ("burp")
				if (src.emote_check(voluntary, 30))
					playsound(get_turf(src), 'sound/voice/burp.ogg', 40, 1, 0.1, 3)
					return "<span class='emote'><b>[src]</b> burps.</span>"
			if ("fart")
				if (src.emote_check(voluntary))
					playsound(get_turf(src), 'sound/voice/farts/poo2.ogg', 40, 1, 0.1, 3)
					return "<span class='emote'><b>[src]</b> farts!</span>"

		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
			if ("burp")
				return 2
			if ("fart")
				return 2
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "tiny hand"
		HH.limb_name = "tiny hand"

		HH = hands[2]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "tiny hand"
		HH.limb_name = "tiny hand"

/mob/living/critter/small_animal/figure/weak
	health_brute = 4
	health_burn = 4


/* mentor & admin ghost critters */

/mob/living/critter/small_animal/mouse/weak/mentor
	name = "mentor mouse"
	real_name = "mentor mouse"
	desc = "A helpful mentor in the form of a mouse. Click to put them in your pocket so they can help you."
	var/status_name = "mentor_mouse"
	var/is_admin = 0
	var/mob/last_poked = null
	var/colorkey_overlays = 0
	icon_state = "mouse-mentor"
	icon_state_dead = "mouse-mentor-dead"
	var/icon_state_exclaim = "mouse-mentor-exclaim"
	health_brute = 35
	health_burn = 35

	New()
		..()
		/*src.fur_color = "#c486ec"
		src.eye_color = "#000000"
		src.setup_overlays()*/
		src.real_name = "[pick_string("mentor_mice_prefixes.txt", "mentor_mouse_prefix")] [src.name]"
		src.name = src.real_name

	setup_overlays()
		if(!src.colorkey_overlays)
			return
		eye_color = src.client?.preferences.AH.e_color

		var/image/overlay = image('icons/misc/critter.dmi', "mouse_colorkey")
		overlay.color = fur_color
		src.UpdateOverlays(overlay, "hair")

		var/image/overlay_eyes = image('icons/misc/critter.dmi', "mouse_eyes")
		overlay_eyes.color = eye_color
		src.UpdateOverlays(overlay_eyes, "eyes")

	death()
		..()
		if(!src.colorkey_overlays)
			src.UpdateOverlays(null, "hair")

	attack_hand(mob/living/M)
		src.into_pocket(M)

	proc/into_pocket(mob/M, var/voluntary = 1)
		if(M == src || isdead(src))
			return // no recursive pockets, thank you. Also no dead mice in pockets
		if(locate(/mob/dead/target_observer/mentor_mouse_observer) in M)
			if(voluntary)
				boutput(M, "You already have a mouse helping you, don't be greedy.")
			else
				boutput(src, "[M] already has a mouse in [his_or_her(M)] pocket.")
			return
		if(voluntary && M != src.last_poked) // if we poked that person it means we implicitly agree
			boutput(M, "You extend your hand to the mouse, waiting for it to accept.")
			if (alert(src, "[M] wants to pick you up and put you in their pocket. Is that okay with you?", "Hop in the pocket", "Yes", "No") != "Yes")
				boutput(M, "\The [src] slips out as you try to pick it up.")
				return
		if(!src || !src.mind || !src.client)
			return
		if(voluntary)
			M.visible_message("[M] picks up \the [src] and puts it in [his_or_her(M)] pocket.", "You pick up \the [src] and put it in your pocket.")
		else
			M.visible_message("\The [src] jumps into [M]'s pocket.", "\The [src] jumps into your pocket.")
		boutput(M, "You can click on the status effect in the top right to kick the mouse out.")
		boutput(src, "<span style='color:red; font-size:1.5em'><b>You are now in someone's pocket and can talk to them and click on their screen to ping in the place where you're ctrl+clicking. This is a feature meant for teaching and helping players. Do not abuse it by using it to just chat with your friends!</b></span>")
		var/mob/dead/target_observer/mentor_mouse_observer/obs = new(M, src.is_admin)
		obs.set_observe_target(M)
		obs.my_mouse = src
		src.set_loc(obs)
		if(src.mind)
			src.mind.transfer_to(obs)
		else if(src.client)
			obs.client = src.client
		M.setStatus(src.status_name, duration = null)

	hand_attack(atom/target, params, location, control, origParams)
		if(istype(target, /mob/living) && target != src)
			boutput(src, "<span class='game' class='mhelp'>You poke [target] in a way that clearly indicates you want to help them.</span>")
			boutput(target, "<span class='game' class='mhelp'>\The [src] seems willing to help you. Click on it with an empty hand if you want to accept the offer.</span>")
			src.last_poked = target
			if(src.icon_state_exclaim)
				flick(src.icon_state_exclaim, src)
		else
			return ..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/mouse_squeak.ogg", 80, 1)
					if(src.icon_state_exclaim)
						flick(src.icon_state_exclaim, src)
					return "<span class='emote'><b>[src]</b> squeaks!</span>"
		return ..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("fart")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), 'sound/voice/farts/poo2.ogg', 40, 1, 0.1, 3)
					var/obj/item/storage/bible/B = locate(/obj/item/storage/bible) in get_turf(src)
					if(B)
						SPAWN_DBG(1) // so that this message happens second
							playsound(get_turf(src), 'sound/voice/farts/poo2.ogg', 7, 0, 0, src.get_age_pitch() * 0.4)
							B.visible_message("<span class='notice'>[B] toots back [pick("grumpily","complaintively","indignantly","sadly","annoyedly","gruffly","quietly","crossly")].</span>")
					return "<span class='emote'><b>[src]</b> toots helpfully!</span>"
		return ..()

	specific_emote_type(var/act)
		switch (act)
			if ("fart")
				return 2
		return ..()

/mob/living/critter/small_animal/mouse/weak/mentor/admin
	name = "admin mouse"
	real_name = "mentor mouse"
	desc = "A helpful (?) admin in the form of a mouse. Click to put them in your pocket so they can help you."
	status_name = "admin_mouse"
	is_admin = 1
	icon_state = "mouse-admin"
	icon_state_dead = "mouse-admin-dead"
	icon_state_exclaim = "mouse-admin-exclaim"

	New()
		..()
		/*src.fur_color = "#d43b3b"
		src.setup_overlays()*/

	hand_attack(atom/target, params, location, control, origParams)
		if(istype(target, /mob/living))
			var/mob/living/M = target
			src.into_pocket(M, 0)
		else
			return ..()
	
	understands_language(language)
		if(language == "animal") // by default admin mice speak english but we want them to understand animal-ese
			return 1
		return ..()

/mob/living/critter/small_animal/crab
	name = "crab"
	real_name = "crab"
	desc = "Snip snap"
	icon_state = "crab_party"
	hand_count = 2
	speechverb_say = "snips"
	speechverb_exclaim = "snaps"
	butcherable = 1
	health_brute = 15
	health_burn = 15
	pet_text = list("gently snips", "rubs with a soft claw", "cuddles")

	New()
		..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "beak"
		HH.name = "left claw"
		HH.limb_name = "claw"

		HH = hands[2]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "beak"
		HH.name = "right claw"
		HH.limb_name = "claw"



/mob/living/critter/small_animal/trilobite
	name = "trilobite"
	real_name = "trilobite"
	desc = "This is an alien trilobite."
	icon_state = "trilobite"
	icon_state_dead = "trilobite-dead"
	speechverb_say = "clicks"
	speechverb_exclaim = "screeches"
	speechverb_ask = "chitters"
	health_brute = 6
	health_burn = 6
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1

	density = 1

	base_move_delay = 4
	base_walk_delay = 5

//	var/mob/living/target = null

	New()
		..()
		src.remove_stam_mod_max("small_animal")
		src.add_stam_mod_max("trilobite", -(STAMINA_MAX-10))
		abilityHolder.addAbility(/datum/targetable/critter/bury_hide)
		SPAWN_DBG(1 SECOND)
			animate_bumble(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med/dash
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "mouth"
		HH.limb_name = "mouth"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","chitter")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/bugchitter.ogg", 80, 1, pitch = 1.3)
					return "<span class='emote'><b>[src]</b> chitters!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","chitter")
				return 2
		return ..()

	death(var/gibbed)
		playsound(get_turf(src), "sound/voice/animal/bugchitter.ogg", 80, 1, pitch = 1.7)
		new /obj/item/raw_material/claretine(src.loc)
		new /obj/item/raw_material/chitin(src.loc)
		if (prob(70))
			new /obj/item/raw_material/claretine(src.loc)
			new /obj/item/raw_material/chitin(src.loc)
		..()

	ai_controlled
		is_npc = 1
		New()
			..()
			src.ai = new /datum/aiHolder/trilobite(src)
			//todo later : move this lifeprocess stuff to a component
			remove_lifeprocess(/datum/lifeprocess/blindness)
			remove_lifeprocess(/datum/lifeprocess/viruses)

		death(var/gibbed)
			qdel(src.ai)
			src.ai = null
			reduce_lifeprocess_on_death()
			..()



/mob/living/critter/small_animal/hallucigenia
	name = "hallucigenia"
	real_name = "hallucigenia"
	desc = "This is an alien hallucigenia."
	icon_state = "hallucigenia"
	icon_state_dead = "hallucigenia-dead"
	speechverb_say = "clicks"
	speechverb_exclaim = "screeches"
	speechverb_ask = "chitters"
	health_brute = 4
	health_burn = 4
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1

	density = 1

	base_move_delay = 13
	base_walk_delay = 15

//	var/mob/living/target = null

	New()
		..()
		src.remove_stam_mod_max("small_animal")
		src.add_stam_mod_max("hallucigenia", -(STAMINA_MAX-100))
		src.add_sm_light("hallucigenia\ref[src]", list(255,100,100,0.8 * 255))

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/spike
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handzap"
		HH.name = "spikes"
		HH.limb_name = "spikes"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","chitter")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/bugchitter.ogg", 80, 1, pitch = 0.7)
					return "<span class='emote'><b>[src]</b> chitters!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","chitter")
				return 2
		return ..()

	death(var/gibbed)
		playsound(get_turf(src), "sound/voice/animal/bugchitter.ogg", 80, 1, pitch = 0.6)
		new /obj/item/reagent_containers/food/snacks/healgoo(get_turf(src))

		..()

	ai_controlled
		is_npc = 1
		New()
			..()
			src.ai = new /datum/aiHolder/spike(src)
			remove_lifeprocess(/datum/lifeprocess/blindness)
			remove_lifeprocess(/datum/lifeprocess/viruses)

		death(var/gibbed)
			qdel(src.ai)
			src.ai = null
			reduce_lifeprocess_on_death()
			..()


/mob/living/critter/small_animal/pikaia
	name = "pikaia"
	real_name = "pikaia"
	desc = "This is an alien pikaia."
	icon_state = "pikaia"
	icon_state_dead = "pikaia-dead"
	speechverb_say = "bloops"
	speechverb_exclaim = "blips"
	speechverb_ask = "blups"
	health_brute = 24
	health_burn = 24
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1

	density = 1

	base_move_delay = 2.3
	base_walk_delay = 4

//	var/mob/living/target = null

	New()
		..()
		src.remove_stam_mod_max("small_animal")
		src.add_stam_mod_max("pikaia", -(STAMINA_MAX-140))
		abilityHolder.addAbility(/datum/targetable/critter/bury_hide)
		SPAWN_DBG(1 SECOND)
			animate_bumble(src)

	is_hulk()
		.= 1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "body"
		HH.limb_name = "body"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","chitter")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), 'sound/misc/talk/buwoo_exclaim.ogg', 90, 1, pitch = 0.8)
					return "<span class='emote'><b>[src]</b> squeals!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","chitter")
				return 2
		if (act == "flip")
			for (var/obj/item/grab/G in src.equipped_list(check_for_magtractor = 0))
				var/mob/living/M = G.affecting
				if (M == src)
					continue
				if (!G.affecting)
					continue
				animate_spin(src, prob(50) ? "L" : "R", 1, 0)
				if (G.state >= 1 && isturf(src.loc) && isturf(G.affecting.loc))
					src.emote("scream")
					logTheThing("combat", src, G.affecting, "crunches [constructTarget(G.affecting,"combat")] [log_loc(src)]")
					M.lastattacker = src
					M.lastattackertime = world.time
					G.affecting.TakeDamage("head", rand(2,8), 0, 0, DAMAGE_BLUNT)
					playsound(src.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 50, 1, pitch = 1.3)
					src.visible_message("<span class='alert'><B>[src] crunches [G.affecting]!</B></span>")
		return ..()

	death(var/gibbed)
		playsound(get_turf(src), 'sound/misc/talk/blub.ogg', 80, 1, pitch = 0.6)
		new /obj/item/reagent_containers/food/snacks/greengoo(get_turf(src))

		..()

	ai_controlled
		is_npc = 1
		New()
			..()
			src.ai = new /datum/aiHolder/pikaia(src)
			remove_lifeprocess(/datum/lifeprocess/blindness)
			remove_lifeprocess(/datum/lifeprocess/viruses)

		death(var/gibbed)
			qdel(src.ai)
			src.ai = null
			reduce_lifeprocess_on_death()
			..()
