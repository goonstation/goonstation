
/obj/item/toy/sword
	name = "toy sword"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "sword1"
	inhand_image_icon = 'icons/mob/inhand/hand_cswords.dmi'
	desc = "A sword made of cheap plastic. Contains a colored LED. Collect all five!"
	throwforce = 1
	w_class = 1.0
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

	attack(target as mob, mob/user as mob)
		..()
		if (ishuman(user))
			var/mob/living/carbon/human/U = user
			if (U.gender == MALE)
				playsound(get_turf(U), pick(src.sound_attackM1, src.sound_attackM2), 100, 0, 0, U.get_age_pitch())
			else
				playsound(get_turf(U), pick(src.sound_attackF1, src.sound_attackF2), 100, 0, 0, U.get_age_pitch())

/obj/item/toy/judge_gavel
	name = "judge's gavel"
	desc = "A judge's best friend."
	icon = 'icons/obj/items/courtroom.dmi'
	icon_state = "gavel"
	w_class = 2
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
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/obj/item/toy/judge_block
	name = "block"
	desc = "bang bang bang Bang Bang Bang Bang BANG BANG BANG BANG BANG!!!"
	icon = 'icons/obj/items/courtroom.dmi'
	icon_state = "block"
	flags = SUPPRESSATTACK
	w_class = 1
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
	w_class = 2
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

/obj/item/toy/diploma/attack(mob/M as mob, mob/user as mob)
	if (isliving(user))
		var/mob/living/L = user
		if (L.mind && L.mind.assigned_role == "Clown")
			L.visible_message("<span class='alert'><B>[L] bonks [M] [pick("kindly", "graciously", "helpfully", "sympathetically")].</B></span>")
			playsound(get_turf(M), "sound/misc/boing/[rand(1,6)].ogg", 20, 1)
			M.say("[pick("Wow", "Gosh dangit", "Aw heck", "Oh gosh", "Damnit")], [L], [pick("why are you so", "it's totally unfair that you're so", "how come you're so", "tell me your secrets to being so")] [pick("cool", "smart", "worldly", "funny", "wise", "drop dead hilarious", "incredibly likeable", "beloved by everyone", "straight up amazing", "devilishly handsome")]!")



/obj/item/toy/gooncode
	name = "gooncode hard disk drive"
	desc = "The prized, sought after spaghetti and pooballs code, and the only known cure to apiphobia. Conveniently on a fancy hard drive that connects to PDAs. \
	The most stealable thing in the universe."
	icon = 'icons/obj/cloning.dmi' // sprite is an altered harddisk
	icon_state = "gooncode"
	flags = SUPPRESSATTACK
	throwforce = 3
	w_class = 2.0
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
	w_class = 2
	var/datum/game/tetris
	var/datum/mail

	New()
		src.contextLayout = new /datum/contextLayout/instrumental(16)
		src.contextActions = childrentypesof(/datum/contextAction/cellphone)
		..()
		START_TRACKING
		src.tetris = new /datum/game/tetris(src)

	disposing()
		..()
		STOP_TRACKING

	attack_self(mob/user as mob)
		..()
		user.showContextActions(contextActions, src)
