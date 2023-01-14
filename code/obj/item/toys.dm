
/obj/item/toy/sword
	name = "toy sword"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "sword1"
	inhand_image_icon = 'icons/mob/inhand/hand_cswords.dmi'
	desc = "A sword made of cheap plastic. Contains a colored LED. Collect all five!"
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 5
	contraband = 3
	stamina_damage = 1
	stamina_cost = 7
	stamina_crit_chance = 1
	var/bladecolor = "G"
	var/sound_attackM1 = 'sound/weapons/male_toyattack.ogg'
	var/sound_attackM2 = 'sound/weapons/male_toyattack2.ogg'
	var/sound_attackF1 = 'sound/weapons/female_toyattack.ogg'
	var/sound_attackF2 = 'sound/weapons/female_toyattack2.ogg'

	New()
		..()
		src.bladecolor = pick("R","O","Y","G","C","B","P","Pi","W")
		if (prob(1))
			bladecolor = null
		icon_state = "sword1-[bladecolor]"
		item_state = "sword1-[bladecolor]"
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_SWORD)

	attack(target, mob/user)
		..()
		if (ishuman(user))
			var/mob/living/carbon/human/U = user
			if (U.gender == MALE)
				playsound(U, pick(src.sound_attackM1, src.sound_attackM2), 100, 0, 0, U.get_age_pitch())
			else
				playsound(U, pick(src.sound_attackF1, src.sound_attackF2), 100, 0, 0, U.get_age_pitch())

/obj/item/toy/judge_gavel
	name = "judge's gavel"
	desc = "A judge's best friend."
	icon = 'icons/obj/items/courtroom.dmi'
	icon_state = "gavel"
	w_class = W_CLASS_SMALL
	force = 5
	throwforce = 7
	stamina_damage = 25
	stamina_cost = 10
	stamina_crit_chance = 5

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		playsound(loc, 'sound/items/gavel.ogg', 75, 1)
		user.visible_message("<span class='alert'><b> Sweet Jesus! [user] is bashing their head in with [name]!</b></span>")
		user.TakeDamage("head", 150, 0)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/obj/item/toy/judge_block
	name = "block"
	desc = "bang bang bang Bang Bang Bang Bang BANG BANG BANG BANG BANG!!!"
	icon = 'icons/obj/items/courtroom.dmi'
	icon_state = "block"
	flags = SUPPRESSATTACK
	w_class = W_CLASS_TINY
	throwforce = 1
	throw_speed = 4
	throw_range = 7
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	var/cooldown = 0

/obj/item/toy/judge_block/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/toy/judge_gavel))
		if(cooldown > world.time)
			return
		else
			playsound(loc, 'sound/items/gavel.ogg', 75, 1)
			user.say("Order, order in the court!")
			cooldown = world.time + 40
			return
	return ..()

/obj/item/toy/judge_block/attack()
	return

/obj/item/toy/diploma
	name = "diploma"
	icon = 'icons/obj/writing.dmi'
	icon_state = "diploma"
	w_class = W_CLASS_SMALL
	throwforce = 3
	throw_speed = 3
	throw_range = 5
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	var/redeemer = null
	var/receiver = null

/obj/item/toy/diploma/New()
	..()
	src.desc = "This is Clown College diploma, a Bachelor of Farts Degree for the study of [pick("slipology", "jugglemancy", "pie science", "bicycle horn accoustics", "comic sans calligraphy", "gelotology", "flatology", "nuclear physics", "goonstation coder")]. It appears to be written in crayon."

/obj/item/toy/diploma/attack(mob/M, mob/user)
	if (isliving(user))
		var/mob/living/L = user
		if (L.mind && L.mind.assigned_role == "Clown")
			L.visible_message("<span class='alert'><B>[L] bonks [M] [pick("kindly", "graciously", "helpfully", "sympathetically")].</B></span>")
			playsound(M, "sound/misc/boing/[rand(1,6)].ogg", 20, 1)
			M.say("[pick("Wow", "Gosh dangit", "Aw heck", "Oh gosh", "Damnit")], [L], [pick("why are you so", "it's totally unfair that you're so", "how come you're so", "tell me your secrets to being so")] [pick("cool", "smart", "worldly", "funny", "wise", "drop dead hilarious", "incredibly likeable", "beloved by everyone", "straight up amazing", "devilishly handsome")]!")

/obj/item/toy/gooncode
	name = "gooncode hard disk drive"
	desc = "The prized, sought after spaghetti and pooballs code, and the only known cure to apiphobia. Conveniently on a fancy hard drive that connects to PDAs. \
	The most stealable thing in the universe."
	icon = 'icons/obj/items/disks.dmi' // sprite is an altered harddisk
	icon_state = "gooncode"
	flags = SUPPRESSATTACK
	throwforce = 3
	w_class = W_CLASS_SMALL
	throw_speed = 2
	throw_range = 3
	rand_pos = 1
	var/cooldown = 0
	var/stationfirst = "go"
	var/stationlast = "on"
	var/prfirst = "very"
	var/prmiddle = "smelly"
	var/prlast = "farts"

/obj/item/toy/gooncode/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/pda2))
		if(cooldown > world.time)
			return
		else
			stationfirst = pick("tee", "bee", "fart", "yoo", "poo", "gee", "ma", "honk", "badmin", "terry", "rubber", "fruity", "war", "de")
			stationlast = pick("gee", "bee", "butt", "goo", "pee", "se", "cho", "clown", "bus", "bugger", "frugal", "illegal", "crime", "row")
			prfirst = pick("high", "cool", "beloved", "crappy", "interesting", "worthless", "random", "horribly coded", "butt", "low", "extremely", "soul", "outdated")
			prmiddle = pick("octane", "spooky", "quality", "secret", "crap", "chatty", "butt", "energetic", "diarrhea inducing", "confusing", "magical", "relative pathed", "stealing", "ridiculous")
			prlast = pick("functions", "bugfixes", "features", "items", "weapons", "the entire goddamn chat", "antagonist", "job", "sprites", "butts", "artifacts", "cars")
			playsound(loc, 'sound/machines/ding.ogg', 75, 1)
			user.visible_message("<span class='alert'><B>[user] uploads the Gooncode to their PDA.</B></span>")
			I.audible_message("<i>New pull request opened on [stationfirst][stationlast]station: <span class='emote'>\"Ports [prfirst] [prmiddle] [prlast] from Goonstation.\"</i></span>")
			cooldown = world.time + 40
			return
	return ..()

/obj/item/toy/gooncode/attack()
	return

/obj/item/toy/cellphone
	name = "flip phone"
	desc = "Wow! You've always wanted one of these charmingly clunky doodads!"
	icon = 'icons/obj/cellphone.dmi'
	icon_state = "cellphone-on"
	w_class = W_CLASS_SMALL
	var/datum/game/tetris
	var/datum/mail

	New()
		src.contextLayout = new /datum/contextLayout/instrumental(16)
		src.contextActions = childrentypesof(/datum/contextAction/cellphone)
		//Email was never even coded so ???
		..()
		START_TRACKING
		src.tetris = new /datum/game/tetris(src)

	disposing()
		..()
		STOP_TRACKING

	attack_self(mob/user as mob)
		..()
		user.showContextActions(contextActions, src)

/obj/machinery/computer/arcade/handheld
	desc = "You shouldn't see this, I exist for typechecks"

TYPEINFO(/obj/item/toy/handheld)
	mats = 2

/obj/item/toy/handheld
	name = "arcade toy"
	desc = "These high tech gadgets compress the full arcade experience into a large, clunky handheld!"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "arcade-generic"
	var/arcademode = FALSE
	//The arcade machine will typecheck if we're this type
	var/obj/machinery/computer/arcade/handheld/arcadeholder = null
	var/datum/game/gameholder = null
	var/datum/gametype = /datum/game/tetris

	New()
		. = ..()
		if (!arcademode)
			gameholder = new gametype(src)
			return
		//I wanted to make this the first time it's used
		//But then I don't have a name
		arcadeholder = new(src)
		name = arcadeholder.name

	attack_self(mob/user as mob)
		. = ..()
		if (!arcademode)
			src.gameholder.new_game(user)
			return

		arcadeholder.show_ui(user)


/obj/item/toy/handheld/robustris
	icon_state = "arcade-robustris"
	name = "Robustris Pro"

/obj/item/toy/handheld/arcade
	arcademode = TRUE
	icon_state = "arcade-adventure"

/obj/item/item_box/figure_capsule/gaming_capsule
	name = "game capsule"

	New()
		contained_item = pick(30;/obj/item/toy/handheld/arcade, 70;/obj/item/toy/handheld/robustris)
		. = ..()
		if (ispath(contained_item, /obj/item/toy/handheld/robustris))
			itemstate = "robustris-fig"
		else if (ispath(contained_item, /obj/item/toy/handheld/arcade))
			itemstate = "arcade-fig"
		else
			itemstate = "game-fig"

/obj/item/toy/ornate_baton
	name = "ornate baton"
	desc = "Twirly."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "ornate-baton"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "ornate_baton"
	w_class = W_CLASS_NORMAL
	throwforce = 1
	throw_speed = 3
	throw_range = 7
	stamina_damage = 25
	stamina_cost = 10
	stamina_crit_chance = 5

/obj/item/rubberduck
	name = "rubber duck"
	desc = "Awww, it squeaks!"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "rubber_duck"
	item_state = "sponge"
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 3
	throw_range = 15

/obj/item/rubberduck/attack_self(mob/user as mob)
	if (!ON_COOLDOWN(src,"quack",2 SECONDS))
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.sims)
				H.sims.affectMotive("fun", 1)
		if (narrator_mode)
			playsound(user, 'sound/vox/duct.ogg', 50, 1)
		else
			playsound(user, 'sound/items/rubberduck.ogg', 50, 1)
		if(prob(1))
			user.drop_item()
			playsound(user, 'sound/ambience/industrial/AncientPowerPlant_Drone3.ogg', 50, 1) // this is gonna spook some people!!
			var/wacka = 0
			while (wacka++ < 50)
				sleep(0.2 SECONDS)
				pixel_x = rand(-6,6)
				pixel_y = rand(-6,6)
				sleep(0.1 SECONDS)
				pixel_y = 0
				pixel_x = 0
		src.add_fingerprint(user)
	return

/obj/item/ghostboard
	name = "\improper Ouija board"
	desc = "A wooden board that allows for communication with spirits and such things. Or that's what the company that makes them claims, at least."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "lboard"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "ouijaboard"
	w_class = W_CLASS_NORMAL
	var/emoji_prob = 30
	var/emoji_min = 1
	var/emoji_max = 3
	var/words_prob = 100
	var/words_min = 7
	var/words_max = 10

	New()
		. = ..()
		START_TRACKING
		BLOCK_SETUP(BLOCK_BOOK)

	disposing()
		. = ..()
		STOP_TRACKING

	proc/generate_words()
		var/list/words = list()
		if(prob(words_prob))
			words |= get_ouija_word_list(src, words_min, words_max)
		if(prob(emoji_prob))
			for(var/i in 1 to rand(emoji_min, emoji_max))
				words |= random_emoji()
		return words

	Click(location,control,params)
		if(isobserver(usr) || iswraith(usr) || isAIeye(usr)) //explicitly added AIeye because AIeye is no longer dead and AI's are ghosts trapped in metal boxes.
			if(isAIeye(usr))
				boutput(usr, "<span class='notice'>Whoa, you can use this as an AI? Are you actually just a ghost trapped in a metal box??</span>")

			if(ON_COOLDOWN(src, usr, 3 SECONDS))
				usr.show_text("Please wait a moment before using the board again.", "red")
				return

			var/selected
			do
				var/list/words = list("*REFRESH*") + src.generate_words()
				selected = tgui_input_list(usr, "Select a word:", src.name, words, allowIllegal=TRUE)
			while(selected == "*REFRESH*")

			if(!selected)
				return

			animate_float(src, 1, 5, 1)
			if(prob(20) && !ON_COOLDOWN(src, "bother chaplains", 1 MINUTE))
				var/area/AR = get_area(src)
				for(var/mob/M in by_cat[TR_CAT_CHAPLAINS])
					if(M.client)
						boutput(M, "<span class='notice'>You sense a disturbance emanating from \a [src] in \the [AR.name].</span>")
			for (var/mob/O in observersviewers(7, src))
				O.show_message("<B><span class='notice'>The board spells out a message ... \"[selected]\"</span></B>", 1)
			#ifdef HALLOWEEN
			if (istype(usr.abilityHolder, /datum/abilityHolder/ghost_observer))
				var/datum/abilityHolder/ghost_observer/GH = usr.abilityHolder
				GH.change_points(30)
			#endif
		else
			return ..(location,control,params)

/obj/item/ghostboard/emouija
	name = "Emouija board"
	desc = "A wooden board that allows for communication with spirits and such things. Wait, this one doesn't even have proper letters on it."
	emoji_prob = 100
	emoji_min = 5
	emoji_max = 10
	words_prob = 0


/proc/fartes()
	for(var/imageToLoad in flist("images/"))
		usr << browse_rsc(file("images/[imageToLoad]"))
		boutput(world, "[imageToLoad] - [file("images/[imageToLoad]")]")
	return
