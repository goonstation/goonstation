// hey look at me I'm changing a file
// again, again, again

// How 2 use: run /proc/test_disposal_system via Advanced ProcCall
// locate the X and Y where normally disposed stuff should end up (usually the last bit of conveyor belt in front of the crusher door
// wait and see what comes up!
/proc/test_disposal_system(var/expected_x, var/expected_y, var/sleep_time = 600, var/include_mail = 1)
	if (!usr && (isnull(expected_x) || isnull(expected_y)))
		return
	if (isnull(expected_x))
		expected_x = input(usr,"Please enter X coordinate") as null|num
		if (isnull(expected_x))
			return
	if (isnull(expected_y))
		expected_y = input(usr,"Please enter Y coordinate") as null|num
		if (isnull(expected_y))
			return

	var/list/dummy_list = list()
	for (var/obj/machinery/disposal/D in world)
		if (D.z != 1)
			break
		/*
		if (D.type != text2path(test_path))
			continue
		*/
		var/obj/item/disposal_test_dummy/TD
		// Mail chute test
		if(istype(D, /obj/machinery/disposal/mail))
			if(include_mail)
				var/obj/machinery/disposal/mail/mail_chute = D

				mail_chute.Topic("?rescan=1", params2list("rescan=1"))
				SPAWN_DBG(2 SECONDS)
					for(var/dest in mail_chute.destinations)
						var/obj/item/disposal_test_dummy/mail_test/MD = new /obj/item/disposal_test_dummy/mail_test(mail_chute, sleep_time)
						MD.source_disposal = mail_chute
						MD.destination_tag = dest
						mail_chute.destination_tag = dest
						//dummy_list.Add(MD)
						mail_chute.flush()

		else
			//Regular chute
			TD = new /obj/item/disposal_test_dummy(D)
			TD.expected_x = expected_x
			TD.expected_y = expected_y
			dummy_list.Add(TD)
			TD.source_disposal = D
			SPAWN_DBG(0)
				D.flush()

	message_coders("test_disposal_system() sleeping [sleep_time] and spawned [dummy_list.len] dummies")
	sleep(sleep_time)

	var/successes = 0
	for (var/obj/item/disposal_test_dummy/TD in dummy_list)
		if (!TD.report_fail())
			successes ++

		qdel(TD)

	message_coders("Disposal test completed with [successes] successes")

/obj/item/disposal_test_dummy
	icon = 'icons/misc/bird.dmi'
	icon_state = "bhooty"
	name = "wtf"
	var/obj/machinery/disposal/source_disposal = null
	var/expected_x = 0
	var/expected_y = 0


	New(var/atom/loc, var/TTL=0)
		..(loc)
		if(TTL)
			SPAWN_DBG(TTL)
				die()

	proc/report_fail()
		if(src.x != expected_x || src.y != expected_y)
			message_coders("test dummy misrouted at [log_loc(src)][src.source_disposal ? " from [log_loc(src.source_disposal)]" : " (source disposal destroyed)"]")
			return 1

		return 0

	proc/die()
		report_fail()
		qdel(src)

/obj/item/disposal_test_dummy/mail_test
	var/obj/machinery/disposal/mail/destination_disposal = null
	var/destination_tag = null
	var/success = 0

/obj/item/disposal_test_dummy/mail_test/pipe_eject()
	destination_disposal = locate(/obj/machinery/disposal/mail) in src.loc
	if(destination_disposal && destination_disposal.mail_tag == destination_tag)
		success = 1
	SPAWN_DBG(5 SECONDS)
		die()
	..()

/obj/item/disposal_test_dummy/mail_test/report_fail()
	if(!success)
		message_coders("mail dummy misrouted at [log_loc(src)] from [log_loc(source_disposal)], destination: [destination_tag], reached: [log_loc(destination_disposal)]")
		return 1
	return 0

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-ADMIN-STUFF-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/atom/proc/add_star_effect(var/remove = 0)
	if (remove)
		if (particleMaster.CheckSystemExists(/datum/particleSystem/warp_star, src))
			particleMaster.RemoveSystem(/datum/particleSystem/warp_star, src)
	else if (!particleMaster.CheckSystemExists(/datum/particleSystem/warp_star, src))
		particleMaster.SpawnSystem(new /datum/particleSystem/warp_star(src))

/proc/toggle_clones_for_cash()
	if (!wagesystem)
		return
	wagesystem.clones_for_cash = !(wagesystem.clones_for_cash)
	logTheThing("admin", usr, null, "toggled monetized cloning [wagesystem.clones_for_cash ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled monetized cloning [wagesystem.clones_for_cash ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled monetized cloning [wagesystem.clones_for_cash ? "on" : "off"]")
	boutput(world, "<b>Cloning now [wagesystem.clones_for_cash ? "requires" : "does not require"] money.</b>")

/area/haine_party_palace
	name = "haine's rad hangout place"
	icon_state = "purple"
	requires_power = 0
	sound_environment = 4

/proc/report_times()
	DEBUG_MESSAGE("[world.time]")
	DEBUG_MESSAGE(time2text(world.realtime, "DDD MMM DD hh:mm:ss"))
	DEBUG_MESSAGE(time2text(world.timeofday, "DDD MMM DD hh:mm:ss"))

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-GUM-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/obj/item/clothing/mask/bubblegum
	name = "bubblegum"
	desc = "Some chewable gum. You can blow bubbles with it!"
	icon_state = "anime"	// todo: decent sprites
	var/mob/chewer = null
	var/chew_size = 0.2		// unit amount transferred when gum is chewed
	var/spam_flag = 0		// counts down from spam_timer after each time the chew message is shown
	var/spam_timer = 8		// time used to determine how long spam_flag is active
	var/initial_reagent = null

	New()
		..()
		if (!src.reagents && src.initial_reagent)
			var/datum/reagents/R = new /datum/reagents(5)
			src.reagents = R
			R.my_atom = src
			src.reagents.add_reagent(src.initial_reagent, 5)

	equipped(var/mob/user, var/slot)
		if (slot == SLOT_WEAR_MASK && istype(user))
			src.chewer = user
			processing_items |= src
			if (src.reagents && !src.reagents.total_volume)
				user.show_text("Looks like [src] has lost its flavor, darn.")
		return ..()

	unequipped(var/mob/user)
		src.chewer = null
		src.spam_flag = 0
		processing_items.Remove(src)
		return ..()

	process()
		DEBUG_MESSAGE("[src] processing: chewer [chewer], spam_flag [spam_flag]")
		if (istype(src.chewer) && src.loc == src.chewer && src.chewer.wear_mask == src)
			if (!src.spam_flag && prob(33))
				src.chewer.visible_message("<span style='color:#888888;font-size:80%'>[src.chewer] chews [his_or_her(src.chewer)] [src.name].</span>")
				src.spam_flag = src.spam_timer
				if (src.reagents && src.reagents.total_volume)
					src.reagents.reaction(src.chewer, INGEST, chew_size)
					SPAWN_DBG(0)
						if (src?.reagents && src.chewer?.reagents)
							src.reagents.trans_to(src.chewer, min(reagents.total_volume, chew_size))
			else if (src.spam_flag)
				src.spam_flag--
		else
			src.chewer = null
			src.spam_flag = 0
			processing_items.Remove(src)
			return

/obj/item/clothing/mask/bubblegum/test
	initial_reagent = "styptic_powder"

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-=-=BIRDS=-=-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/obj/item/feather
	name = "feather"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "feather"
	w_class = 1
	p_class = 1
	burn_point = 220
	burn_output = 300
	burn_possible = 1
	rand_pos = 1

var/list/parrot_species = list("eclectus" = /datum/species_info/parrot/eclectus,
	"eclectusf" = /datum/species_info/parrot/eclectus/female,
	"agrey" = /datum/species_info/parrot/grey,
	"bcaique" = /datum/species_info/parrot/caique,
	"wcaique" = /datum/species_info/parrot/caique/white,
	"gbudge" = /datum/species_info/parrot/budgie,
	"bbudge" = /datum/species_info/parrot/budgie/blue,
	"bgbudge" = /datum/species_info/parrot/budgie/bluegreen,
	"tiel" = /datum/species_info/parrot/cockatiel,
	"wtiel" = /datum/species_info/parrot/cockatiel/white,
	"luttiel" = /datum/species_info/parrot/cockatiel/lutino,
	"blutiel" = /datum/species_info/parrot/cockatiel/face,
	"too" = /datum/species_info/parrot/cockatoo,
	"utoo" = /datum/species_info/parrot/cockatoo/umbrella,
	"mtoo" = /datum/species_info/parrot/cockatoo/mitchells,
	"toucan" = /datum/species_info/parrot/toucan,
	"kbtoucan" = /datum/species_info/parrot/toucan/keel,
	"smacaw" = /datum/species_info/parrot/macaw,
	"bmacaw" = /datum/species_info/parrot/macaw/bluegold,
	"mmacaw" = /datum/species_info/parrot/macaw/military,
	"hmacaw" = /datum/species_info/parrot/macaw/hyacinth,
	"love" = /datum/species_info/parrot/lovebird,
	"lovey" = /datum/species_info/parrot/lovebird/pfyellow,
	"lovem" = /datum/species_info/parrot/lovebird/masked,
	"loveb" = /datum/species_info/parrot/lovebird/masked/blue,
	"lovef" = /datum/species_info/parrot/lovebird/fischer,
	"kea" = /datum/species_info/parrot/kea)

var/list/special_parrot_species = list("ikea" = /datum/species_info/parrot/kea/ikea,
	"space" = /datum/species_info/parrot/space)

/datum/species_info // this can totally be used for more than just parrots, totally
	var/name = "critter"
	var/desc = "Something."
	var/species = "critter"

/datum/species_info/parrot
	name = "space parrot" // ....................................... obj|mob
	desc = "A spacefaring species of parrot." // ................... obj|mob
	species = "parrot" // .......................................... obj|mob
	var/list/subspecies = null // .................................. obj|mob
	var/icon = 'icons/misc/bird.dmi' // ............................ obj|mob
	var/gender = PLURAL // ............................................. mob
	var/learned_words = null // .................................... obj ...
	var/learned_phrases = null // .................................. obj ...
	var/learn_words_chance = 33 // ................................. obj ...
	var/learn_phrase_chance = 10 // ................................ obj ...
	var/learn_words_max = 64 // .................................... obj ...
	var/learn_phrase_max = 32 // ................................... obj ...
	var/chatter_chance = 2 // ...................................... obj ...
	var/find_treasure_chance = 2 // ................................ obj ...
	var/destroys_treasure = 0 // ................................... obj ...
	var/sells_furniture = 0 // ..................................... obj ...
	var/hops = 0 // ................................................ obj|mob
	var/pixel_x = 0 // ............................................. obj|mob
	var/hat_offset_y = -5 // ....................................... obj|mob
	var/hat_offset_x = 0 // ........................................ obj|mob
	var/feather_color = "#ba1418" // ................................obj|mob

/datum/species_info/parrot/eclectus
	name = "space eclectus"
	desc = "A spacefaring species of <i>eclectus roratus</i>."
	species = "eclectus"
	subspecies = list(/datum/species_info/parrot/eclectus,
					  /datum/species_info/parrot/eclectus/female)
	gender = MALE
	feather_color = "#338e1c;#167ee7;#ba1418"
/datum/species_info/parrot/eclectus/female
	species = "eclectusf"
	gender = FEMALE
	feather_color = "#ba1418;#167ee7"

/datum/species_info/parrot/grey
	name = "space grey"
	desc = "A spacefaring species of <i>psittacus erithacus</i>."
	species = "agrey"
	feather_color = "#7c7c7c;#ba1418"

/datum/species_info/parrot/caique
	name = "space caique"
	desc = "A spacefaring species of <i>pionites melanocephalus</i>."
	species = "bcaique"
	subspecies = list(/datum/species_info/parrot/caique,
					  /datum/species_info/parrot/caique/white)
	hops = 1
	hat_offset_y = -6
	feather_color = "#338e1c;#eeaf00;#ee7500;#ffffff;#444444"
/datum/species_info/parrot/caique/white
	desc = "A spacefaring species of <i>pionites leucogaster</i>."
	species = "wcaique"
	feather_color = "#338e1c;#eeaf00;#ee7500;#ffffff"

/datum/species_info/parrot/budgie
	name = "space budgerigar"
	desc = "A spacefaring species of <i>melopsittacus undulatus</i>."
	species = "gbudge"
	subspecies = list(/datum/species_info/parrot/budgie,
					  /datum/species_info/parrot/budgie/blue,
					  /datum/species_info/parrot/budgie/bluegreen)
	hat_offset_y = -6
	feather_color = "#25e300;#dbe300;#0a54af"
/datum/species_info/parrot/budgie/blue
	species = "bbudge"
	feather_color = "#2ea6e3;#ffffff;#0a54af"
/datum/species_info/parrot/budgie/bluegreen
	species = "bgbudge"
	feather_color = "#61e3df;#e3db51;#0a54af"

/datum/species_info/parrot/cockatiel
	name = "space cockatiel"
	desc = "A spacefaring species of <i>nymphicus hollandicus</i>."
	species = "tiel"
	subspecies = list(/datum/species_info/parrot/cockatiel,
					  /datum/species_info/parrot/cockatiel/white,
					  /datum/species_info/parrot/cockatiel/lutino,
					  /datum/species_info/parrot/cockatiel/face)
	hat_offset_y = -6
	feather_color = "#959595;#f2e193;#e34f2d;#ffffff"
/datum/species_info/parrot/cockatiel/white
	species = "wtiel"
	feather_color = "#ffffff"
/datum/species_info/parrot/cockatiel/lutino
	species = "luttiel"
	feather_color = "#ffffff;#f2e193;#e34f2d"
/datum/species_info/parrot/cockatiel/face
	species = "blutiel"
	feather_color = "#959595;#ffffff"

/datum/species_info/parrot/cockatoo
	name = "space cockatoo"
	desc = "A spacefaring species of <i>cacatua galerita</i>."
	species = "too"
	subspecies = list(/datum/species_info/parrot/cockatoo,
					  /datum/species_info/parrot/cockatoo/umbrella,
					  /datum/species_info/parrot/cockatoo/mitchells)
	hat_offset_y = -4
	feather_color = "#ffffff;#ffe777"
/datum/species_info/parrot/cockatoo/umbrella
	desc = "A spacefaring species of <i>cacatua alba</i>."
	species = "utoo"
	feather_color = "#ffffff"
/datum/species_info/parrot/cockatoo/mitchells
	desc = "A spacefaring species of <i>lophochroa leadbeateri</i>."
	species = "mtoo"
	feather_color = "#ffffff;#f0c8d2;#ff4740;#dfc962"

/datum/species_info/parrot/toucan
	name = "space toucan"
	desc = "A spacefaring species of <i>ramphastos toco</i>."
	species = "toucan"
	subspecies = list(/datum/species_info/parrot/toucan,
					  /datum/species_info/parrot/toucan/keel)
	hat_offset_y = -4
	feather_color = "#4d4d4d;#ffffff;#a2171b"
/datum/species_info/parrot/toucan/keel
	desc = "A spacefaring species of <i>ramphastos sulfuratus</i>."
	species = "kbtoucan"
	feather_color = "#4d4d4d;#ffffff;#a2171b;#e8c600"

/datum/species_info/parrot/macaw
	name = "space macaw"
	desc = "A spacefaring species of <i>ara macao</i>."
	species = "smacaw"
	subspecies = list(/datum/species_info/parrot/macaw,
					  /datum/species_info/parrot/macaw/bluegold,
					  /datum/species_info/parrot/macaw/military,
					  /datum/species_info/parrot/macaw/hyacinth)
	icon = 'icons/misc/bigcritter.dmi' // macaws are big oafs
	pixel_x = -16
	hat_offset_y = -3
	hat_offset_x = 16
	feather_color = "#df0f14;#eeaf00;#412eab;#409611"
/datum/species_info/parrot/macaw/bluegold
	desc = "A spacefaring species of <i>ara ararauna</i>."
	species = "bmacaw"
	feather_color = "#0e70e7;#f5c403;#019b26"
/datum/species_info/parrot/macaw/military
	desc = "A spacefaring species of <i>ara militaris</i>."
	species = "mmacaw"
	feather_color = "#3d9f2b;#e8b900;#1699f8;#bd3030"
/datum/species_info/parrot/macaw/hyacinth
	desc = "A spacefaring species of <i>anodorhynchus hyacinthinus</i>."
	species = "hmacaw"
	feather_color = "#383d9c"

/datum/species_info/parrot/lovebird
	name = "space lovebird"
	desc = "A spacefaring species of <i>agapornis roseicollis</i>."
	species = "love"
	subspecies = list(/datum/species_info/parrot/lovebird,
					  /datum/species_info/parrot/lovebird/pfyellow,
					  /datum/species_info/parrot/lovebird/masked,
					  /datum/species_info/parrot/lovebird/masked/blue,
					  /datum/species_info/parrot/lovebird/fischer)
	hat_offset_y = -6
	feather_color = "#68b128;#3991e3;#ea7865;#e33b2a"
/datum/species_info/parrot/lovebird/pfyellow
	species = "lovey"
	feather_color = "#deba2a;#3991e3;#ea7865;#e33b2a"
/datum/species_info/parrot/lovebird/masked
	desc = "A spacefaring species of <i>agapornis personatus</i>."
	species = "lovem"
	feather_color = "#deba2a;#68b128;#297806;#383838"
/datum/species_info/parrot/lovebird/masked/blue
	species = "loveb"
	feather_color = "#ffffff;#80a5d4;#22668e;#383838"
/datum/species_info/parrot/lovebird/fischer
	desc = "A spacefaring species of <i>agapornis fischeri</i>."
	species = "lovef"
	feather_color = "#65ab26;#deba2a;#e5883d;#d0490f;#3991e3"

/datum/species_info/parrot/kea
	name = "space kea"
	desc = "A spacefaring species of <i>nestor notabillis</i>, also known as the 'space mountain parrot,' originating from Space Zealand."
	species = "kea"
	find_treasure_chance = 15
	destroys_treasure = 1
	feather_color = "#bfba95;#505929;#ff7742;#565151"
/datum/species_info/parrot/kea/ikea
	name = "space ikea"
	desc = "You can buy a variety of flat-packed furniture from the space ikea, if you have enough space kronor."
	species = "ikea"
	learned_words = list("Välkommen","Hej","Hejsan","Hallå","Hej då","Varsågod","Hur mår du","Tack så mycket","Kom igen","Ha en bra dag")
	learned_phrases = list("Välkommen!","Hej!","Hejsan!","Hallå!","Hej då!","Varsågod!","Hur mår du?","Tack så mycket!","Kom igen!","Ha en bra dag!")
	learn_words_chance = 0
	learn_phrase_chance = 0
	chatter_chance = 10
	destroys_treasure = 0
	sells_furniture = 1

/datum/species_info/parrot/space
	desc = "A parrot, from space. In space. Made of space? A space parrot."
	species = "space"
	feather_color = "#151628"

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-=PAINTBALL=-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */
/*
/obj/item/gun/kinetic/paintball
	name = "kinetic weapon"
	item_state = "paintball-"
	m_amt = 2000
	ammo = null
	max_ammo_capacity = 10

	auto_eject = 0
	casings_to_eject = 0

	add_residue = 0

/datum/projectile/special/paintball
	name = "red paintball"
	icon_state = "paintball-r"
	icon_turf_hit = "paint-r"
	power = 1
	cost = 1
	dissipation_rate = 1
	dissipation_delay = 0
	ks_ratio = 1.0
	sname = "red"
	shot_sound = 'sound/impact_sounds/Generic_Stab_1.ogg'
	shot_number = 1
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	hit_ground_chance = 50

/obj/item/ammo/bullets/paintball
	sname = "paintball"
	name = "paintball jug"
	icon_state = "357-2"
	amount_left = 4.0
	max_amount = 4.0
	ammo_type = new/datum/projectile/special/paintball
	caliber = 42069
	icon_dynamic = 1
	icon_short = "paintball"
	icon_empty = "paintball-0"

	update_icon()
		if (src.amount_left < 0)
			src.amount_left = 0

		src.desc = "There are [src.amount_left] paintball\s left!"

		if (src.amount_left > 0)
			if (src.icon_dynamic && src.icon_short)
				src.icon_state = "[src.icon_short]1"
		else
			if (src.icon_empty)
				src.icon_state = src.icon_empty
		return
*/

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-+GAMBLING+=-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/obj/item/dice/coin/poker_chip
	name = "poker chip"
	real_name = "poker chip"
	desc = "Place your bets!"
	icon = 'icons/obj/gambling.dmi'
	icon_state = "chip"
	color = "#484857" // black
	var/pip_color = "#FFFFFF" // only set to other colors by white 50c chips atm but may as well make it a var because ~variety~
	var/image/image_pip = null
	var/value = 1
	force = 2.0
	throwforce = 2.0
	throw_speed = 1
	throw_range = 8
	w_class = 1.0
	amount = 1
	max_stack = 20

	New()
		..()
		src.update_stack_appearance()

	UpdateName()
		src.name = "[src.amount > 1 ? "[src.amount] " : null][name_prefix(null, 1)][src.value]-credit [src.real_name][s_es(src.amount)][name_suffix(null, 1)]"

	update_stack_appearance()
		src.UpdateName()
		if (src.amount <= 1)
			src.icon_state = "chip"
			ENSURE_IMAGE(src.image_pip, src.icon, "chip-pip")
		else
			src.icon_state = "chip_stk[src.amount <= 7 ? src.amount : 7]"
			ENSURE_IMAGE(src.image_pip, src.icon, "chip_stk[src.amount <= 7 ? src.amount : 7]-pip")
		src.image_pip.color = src.pip_color
		src.image_pip.appearance_flags |= RESET_COLOR
		src.UpdateOverlays(src.image_pip, "pip")

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] is stacking [src.real_name]s!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish stacking [src.real_name]s.</span>")

	failed_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='alert'>You need another stack!</span>")

	attackby(var/obj/item/I as obj, mob/user as mob)
		if (istype(I, /obj/item/dice/coin/poker_chip) && src.amount < src.max_stack)
			user.visible_message("<span class='notice'>[user] stacks some [src.real_name]s.</span>")
			src.stack_item(I)
		else
			..(I, user)

	attack_hand(mob/user as mob)
		if ((user.l_hand == src || user.r_hand == src) && user.equipped() != src)
			var/amt = src.amount == 2 ? 1 : round(input("How many [src.real_name]s do you want to take from the stack?") as null|num)
			if (amt && src.loc == user && !user.equipped())
				if (amt > src.amount || amt < 1)
					boutput(user, "<span class='alert'>You wish!</span>")
					return
				src.change_stack_amount(0 - amt)
				var/obj/item/dice/coin/poker_chip/P = new src.type(user.loc)
				P.attack_hand(user)
		else
			..(user)

/obj/item/dice/coin/poker_chip/v5
	color = "#DC0E18" // red
	value = 5

/obj/item/dice/coin/poker_chip/v10
	color = "#30BA67" // green
	value = 10

/obj/item/dice/coin/poker_chip/v25
	color = "#3153CE" // blue
	value = 25

/obj/item/dice/coin/poker_chip/v50
	color = "#FFFFFF" // white
	pip_color = "#3153CE" // blue
	value = 50

/obj/item/dice/coin/poker_chip/v100
	color = "#FF7BD2" // pink
	value = 100

/obj/item/dice/coin/poker_chip/v250
	color = "#E78B2E" // orange
	value = 250

/obj/item/dice/coin/poker_chip/v500
	color = "#BE3ED6" // purple
	value = 500

/obj/item/dice/coin/poker_chip/v1000
	color = "#4BE1DD" // aqua
	value = 1000

/*
                    +---------------+
                    ¦m  S N A K E   ¦
+---h---------c-----+-------e-------+-------------------+
¦ 0 ¦ 3 ¦ 6 ¦ 9 ¦12 ¦15 ¦18 ¦21 ¦24 ¦27 ¦30 ¦33 ¦36 ¦2f1¦
¦ 0 ¦---+-b-+---+---d---+---+---+---+---+---+---+---+---¦
¦---¦ 2 ¦ 5 ¦ 8 ¦11 ¦14 ¦17 ¦20 ¦23 ¦26 ¦29 ¦32 ¦35 ¦2:1¦
¦   g---+---+---+---+---+---+---+---+---+---+---+---+---¦
¦ 0 ¦a1 ¦ 4 ¦ 7 ¦10 ¦13 ¦16 ¦19 ¦22 ¦25 ¦28 ¦31 ¦34 ¦2:1¦
+---+---------------+---------------+---------------+---+
    ¦    1st 12     ¦ i  2nd 12     ¦    3rd 12     ¦
    ¦---------------+---------------+---------------¦
    ¦j LOW  ¦ EVEN k¦l RED  ¦ BLACK ¦  ODD  ¦ HIGH  ¦
    +-----------------------------------------------+
- a: Straight-Up --- a bet on one number, example is 1
- b: Split --------- a bet on two numbers next to each other, example is 6+5
- c: Street -------- a bet on three numbers in a line, example is 9+8+7
- d: Square -------- a bet on four numbers that meet at a corner, example is 12+15+11+14
- e: Double Street - a bet on six numbers in two lines next to each other, example is 16 to 21
- f: Column -------- a bet on an entire row of numbers, example is 3+6+9+...+36
- g: Trio ---------- a bet on three numbers, one of which must be either 0 or 00, example is 0+2+1
- h: Top Line ------ a bet on 0+00+3+2+1
- i: Dozen --------- a bet on one of the three sets of dozens, example is 13 to 24
- j: High or Low --- a bet on numbers 1 to 18 (Low) or 19 to 36 (High)
- k: Even or Odd --- a bet on even numbers or odd numbers (I probably shouldn't need to explain this one)
- l: Red or Black -- a bet on numbers of either color (same as above)
- m: Snake --------- a bet on a specific set of numbers: 1+5+9+12+14+16+19+23+27+30+32+34, named because the numbers make a winding pattern on the board
*/
/*
/obj/roulette_table_w // half with the wheel itself
	name = "roulette wheel"
	desc = "A table with a roulette wheel and a little ball."
	icon = 'icons/obj/gambling.dmi'
	icon_state = "roulette_w0"
	anchored = 1
	density = 1
	var/obj/roulette_table_e/partner = null
	var/running = 0
	var/run_time = 40
	var/last_result = null

	New()
		..()
		var/turf/T = get_step(src, EAST)
		src.partner = locate() in T
		if (!src.partner)
			src.partner = new(T)
		if (src.partner)
			src.partner.partner = src

	disposing()
		if (src.partner)
			src.partner.partner = null
			src.partner = null
		..()

	attack_hand(mob/user)
		src.spin(user)

	proc/spin(mob/user)
		set waitfor = 0
		if (src.running)
			if (user)
				user.show_text("[src] is already spinning, be patient!","red")
			return
		if (user)
			src.visible_message("[user] spins [src]!")
		else
			src.visible_message("[src] starts spinning!")
		src.running = 1
		var/real_run_time = rand(max(src.run_time - 10, 1), (src.run_time + 10))
		sleep(real_run_time)
		src.last_result = rand(1,38) // 1-36 are regular numbers to land on, 37 and 38 are 0 and 00 respectively
		src.visible_message("[src] lands on [src.last_result > 37 ? "00" : src.last_result > 36 ? "0" : src.last_result]!")
		if (istype(src.partner))
			src.partner.process_bets(src.last_result)
		src.running = 0

/obj/roulette_table_e // half with the betting area
	name = "roulette layout"
	desc = "A table with a roulette layout, used for placing bets."
	icon = 'icons/obj/gambling.dmi'
	icon_state = "roulette_e"
	anchored = 1
	density = 1
	var/obj/roulette_table_w/partner = null
	var/list/bets = null

	New()
		..()
		var/turf/T = get_step(src, WEST)
		src.partner = locate() in T
		if (!src.partner)
			src.partner = new(T)
		if (src.partner)
			src.partner.partner = src

	disposing()
		if (src.partner)
			src.partner.partner = null
			src.partner = null
		..()

	proc/process_bets(var/result)
		if (!result || !islist(src.bets))
			return
		var/is_zero = result > 36 ? 1 : 0
		var/is_red = nums_red.Find("[result]") ? 1 : 0
		var/is_odd = result%2 ? 1 : 0
		var/is_low = result < 19 ? 1 : 0
		var/is_snake = nums_snake.Find("[result]") ? 1 : 0
		for (var/bet in src.bets)
			LAGCHECK(LAG_HIGH)
			if (!islist(bet))
				src.bets.Remove(bet)
				continue
			var/winnings = src.check_win(bet, result, is_zero, is_red, is_odd, is_low, is_snake)
			if (winnings)
				src.give_winnings(bet, winnings)
			src.bets.Remove(bet)

	proc/check_win(var/list/bet, var/result, var/is_zero, var/is_red, var/is_odd, var/is_low, var/is_snake)
		if (!islist(bet))
			return 0
		var/mob/owner = bet["owner"]
		var/amt = bet["value"]
		if (!istype(owner) || !amt)
			return 0
		switch(bet["style"])
			if ("str8_up") // straight-up
				if (result == text2num(bet["positions"]))
					return (amt * 35) + amt // 35:1

			if ("split")
				var/list/positions = params2list(bet["positions"])
				if (islist(positions) && positions.Find("[result]"))
					return (amt * 17) + amt // 17:1

			if ("street")
				var/position = text2num(bet["positions"])
				if (result == position || result == position+1 || result == position+2)
					return (amt * 11) + amt // 11:1

			if ("square")
				var/list/positions = params2list(bet["positions"])
				if (islist(positions) && positions.Find("[result]"))
					return (amt * 8) + amt // 8:1

			if ("dbl_strt") // double street
			if ("column")
			if ("trio")
			if ("top_line")
			if ("dozen")
			if ("high_low")
			if ("even_odd")
			if ("color")
			if ("snake")
		return 0

	proc/give_winnings(var/list/bet, var/amt)
*/


/datum/roulette_holder
	var/list/nums_red = list("1","3","5","7","9","12","14","16","18","19","21","23","25","27","30","32","34","36")
	var/list/nums_black = list("2","4","6","8","10","11","13","15","17","20","22","24","26","28","29","31","33","35")
	var/list/nums_snake = list("1","5","9","12","14","16","19","23","27","30","32","34")
/*
/obj/submachine/blackjack
	name = "blackjack machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/gambling.dmi'
	icon_state = "BJ1"
	anchored = 1
	density = 1
	mats = 9
	var/on = 1
	var/plays = 0
	var/working = 0
	var/current_bet = 10
	var/obj/item/card/id/ID = null

	var/list/cards = list() // cards in the deck
	var/list/removed_cards = list() // cards already used, to be moved back to src.cards on a new round
	var/list/hand_player = list()
	var/list/hand_dealer = list()

	var/image/overlay_light = null
	var/image/overlay_id = null

	New()
		..()
		var/datum/playing_card/Card
		var/list/card_suits = list("hearts", "diamonds", "clubs", "spades")
		var/list/card_numbers = list("ace" = 1, "two" = 2, "three" = 3, "four" = 4, "five" = 5, "six" = 6, "seven" = 7, "eight" = 8, "nine" = 9, "ten" = 10, "jack" = 10, "queen" = 10, "king" = 10)

		for (var/suit in card_suits)
			for (var/num in card_numbers)
				Card = new()
				Card.card_name = "[num] of [suit]"
				Card.card_face = "large-[suit]-[num]"
				Card.card_data = card_numbers[num]
				src.cards += Card
		src.cards = shuffle(src.cards)

	proc/deal()
		var/datum/playing_card/Card = pick(src.cards)
		src.cards -= Card
		return Card

	proc/reset_cards()
		for (var/datum/playing_card/Card in src.removed_cards)
			src.cards += Card
			src.removed_cards -= Card
		for (var/datum/playing_card/Card in src.hand_player)
			src.cards += Card
			src.hand_player -= Card
		for (var/datum/playing_card/Card in src.hand_dealer)
			src.cards += Card
			src.hand_dealer -= Card
		src.cards = shuffle(src.cards)

	proc/update_icon()
		if (!src.overlay_light)
			src.overlay_light = image('icons/obj/objects.dmi', "BJ-light")
		src.overlays -= src.overlay_light
		src.overlays -= src.overlay_id
		if (src.ID && src.ID.icon_state)
			src.overlay_id = image(src.icon, "BJ-[src.ID.icon_state]")
			src.overlays += src.overlay_id
		if (src.on)
			if (src.working)
				src.icon_state = "BJ-card2"
			else
				src.icon_state = "BJ-card1"
		else
			src.icon_state = "BJ0"
*/
/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-+BARTENDER+-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/mob/living/carbon/human/npc/diner_bartender
	var/im_mad = 0
	var/obj/machinery/chem_dispenser/alcohol/booze = null
	var/obj/machinery/chem_dispenser/soda/soda = null
	var/last_dispenser_search = null
	var/list/glassware = list()

	New()
		..()
		SPAWN_DBG(0)
			randomize_look(src)
			src.equip_new_if_possible(/obj/item/clothing/shoes/black, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/rank/bartender, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/suit/wcoat, slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/glasses/thermal/orange, slot_glasses)
			src.equip_new_if_possible(/obj/item/gun/kinetic/riotgun, slot_in_backpack)
			src.equip_new_if_possible(/obj/item/storage/box/glassbox, slot_in_backpack)
			for (var/obj/item/reagent_containers/food/drinks/drinkingglass/glass in src)
				src.glassware += glass
			// add a random accent
			var/my_mutation = pick("accent_elvis", "stutter", "accent_chav", "accent_swedish", "accent_tommy", "unintelligable", "slurring")
			src.bioHolder.AddEffect(my_mutation)

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		. = ..()
		src.protect_from(M, null, weapon)

	proc/protect_from(var/mob/M as mob, var/mob/customer as mob, var/obj/item/weapon as obj)
		if (!M)
			return

		if (weapon) // someone got hit by something that hurt
			src.im_mad += 50
			if (!customer || customer == src) // they're doing shit to us
				src.im_mad += 50 // we're double mad

		else if (M.a_intent == INTENT_DISARM) // they're shoving someone around
			src.im_mad += 5
			if (!customer || customer == src) // they're doing shit to us
				src.im_mad += 5 // we're double mad

		else if (M.a_intent == INTENT_GRAB) // they're grabbin' up on someone
			src.im_mad += 20
			src.ai_check_grabs()
			if (!customer || customer == src) // they're doing shit to us
				src.im_mad += 20 // we're double mad

		else if (M.a_intent == INTENT_HARM)
			src.im_mad += 50
			if (!customer || customer == src) // they're doing shit to us
				src.im_mad += 50 // we're double mad

		SPAWN_DBG(rand(10, 30))
			src.yell_at(M, customer)

	proc/yell_at(var/mob/M as mob, var/mob/customer as mob) // blatantly stolen from NPC assistants and then hacked up
		if (!M)
			return
		var/target_name = M.name
		var/area/current_loc = get_area(src)
		var/where_I_am = "here"
		if (copytext(current_loc.name, 1, 6) == "Diner")
			where_I_am = "my bar"
		var/complaint
		if (src.im_mad < 100)
			var/insult = pick("fucker", "fuckhead", "shithead", "shitface", "shitass", "asshole")
			var/targ = pick("", ", [target_name]", ", [insult]", ", you [insult]")
			complaint = pick("Hey[targ]!", "Knock it off[targ]!", "What d'you think you're doing[targ]?", "Fuck off[targ]!", "Go fuck yourself[targ]!", "Cut that shit out[targ]!")

			if (customer && (customer != src)  && prob(10))
				complaint += " [customer.name] is [pick("my best customer", "a good customer", "a fucking [pick("idiot", "asshole")], but I still like 'em better than your stupid ass")][pick(", and I ain't lettin' no shithead like you fuck with 'em", "")]!"

		else if (src.im_mad >= 100 && M.health > 0)
			complaint = pick("[target_name], [pick("", "you [pick("better", "best")] ")]get [pick("your ass ", "your ugly [pick("face", "mug")] ", "")]the fuck out of [where_I_am][pick("", " before I make you")]!",\
			"I don't put up with this [pick("", "kinda ")][pick("", "horse", "bull")][pick("shit", "crap")] in [where_I_am], [target_name]!",\
			"I hope you don't like how your face looks, [target_name], cause it's about to get rearranged!",\
			"I told you to [pick("stop that shit", "cut that shit out")], and you [pick("ain't", "didn't", "didn't listen")]! [pick("So now", "It's time", "And now", "Ypu best not be suprised that")] you're gunna [pick("reap what you sewed", "get it", "get what's yours", "get what's comin' to you")]!")
			src.target = M
			src.ai_state = AI_ATTACKING
			src.ai_threatened = world.timeofday
			src.ai_target = M
			src.im_mad = 0

			if (customer && (customer != src) && prob(75))
				complaint += " [customer.name] is [pick("my best customer", "a good customer", "a fucking [pick("idiot", "asshole")], but I still like 'em better than your [pick("stupid ass", "ugly [pick("face", "mug")]")]")][pick(", and I ain't lettin' no shithead like you fuck with 'em", "")]!"

		src.say(complaint)

	proc/done_with_you(var/mob/M as mob)
		if (!M)
			return 0

		var/target_name = M.name
		var/area/current_loc = get_area(src)
		var/where_I_am = "here"
		if (copytext(current_loc.name, 1, 6) == "Diner")
			where_I_am = "my bar"

		if (M.health <= 10)
			var/insult = pick("fucker", "fuckhead", "shithead", "shitface", "shitass", "asshole")
			var/targ = pick("", ", [target_name]", ", [insult]", ", you [insult]")
			var/punct = pick(".", "!")

			var/kicked_their_ass = pick("Damn right, you stay down[targ][punct]",\
			"Try it again[targ], and next time you'll be hurting even more[punct]",\
			"Goddamn [insult][punct]")
			src.say(kicked_their_ass)

			src.target = null
			src.ai_state = 0
			src.ai_target = null
			src.im_mad = 0
			walk_towards(src,null)
			return 1

		else if (src.health <= 10)
			var/kicked_my_ass = pick("Get away from me!",\
			"I give, leave me [pick("", "the hell ", "the fuck ")]alone!",\
			"Fuck, stop!",\
			"No more!",\
			"Enough, please!")
			src.say(kicked_my_ass)

			src.target = null
			src.ai_state = 0
			src.ai_target = null
			src.im_mad = 0
			walk_towards(src,null)
			return 1

		else if (get_dist(src, M) >= 5)
			var/insult = pick("fucker", "fuckhead", "shithead", "shitface", "shitass", "asshole")
			var/targ = pick("", ", [target_name]", ", [insult]", ", you [insult]")

			var/got_away = pick("Yeah, get the fuck outta [where_I_am][targ]!",\
			"Don't [pick("bother coming back", "[pick("", "ever ")]show your [pick("", "ugly ", "stupid ")][pick("face", "mug")] in [where_I_am] again")]",\
			"If I ever catch you in [where_I_am] again, you[pick("'ll regret it", "'ll be diggin' your own grave", "'d best stop by that fancy cloner you fuckers got, first", " won't be leaving in one piece")]!")
			src.say(got_away)

			src.target = null
			src.ai_state = 0
			src.ai_target = null
			src.im_mad = 0
			walk_towards(src,null)
			return 1
		else
			return 0

	ai_action()
		src.ai_check_grabs()
		if (src.ai_state == AI_ATTACKING && src.done_with_you(src.ai_target))
			return
		else
			return ..()

	proc/ai_check_grabs()
		for (var/mob/living/carbon/human/H in all_viewers(7, src))
			var/obj/item/grab/G = H.find_type_in_hand(/obj/item/grab)
			if (!G)
				return 0
/*
			if (G.affecting in npc_protected_mobs)
				if (G.state == 1)
					src.im_mad += 5
				else if (G.state == 2)
					src.im_mad += 20
				else if (G.state == 3)
					src.im_mad += 50
				return 1
*/
			if (G.affecting == src) // we won't put up with shit being done to us nearly as much as we'll put up with it for others
				if (G.state == 1)
					src.im_mad += 20
				else if (G.state == 2)
					src.im_mad += 60
				else if (G.state == 3)
					src.im_mad += 100
				return 1

			return 0
/*
	proc/ai_find_my_bar()
		if (src.booze && src.soda)
			return
		if (ticker.elapsed_ticks < (src.last_dispenser_search + 50))
			return
		src.last_dispenser_search = ticker.elapsed_ticks
		if (!src.booze)
			var/obj/machinery/chem_dispenser/alcohol/new_booze = locate() in view(7, src)
			if (new_booze)
				src.booze = new_booze
		if (!src.soda)
			var/obj/machinery/chem_dispenser/soda/new_soda = locate() in view(7, src)
			if (new_soda)
				src.soda = new_soda

	proc/ai_tend_bar() // :D
		if (!src.booze || !src.soda) // we don't have a place to make drinks  :(
			src.ai_find_my_bar() // look for some dispensers
			if (!src.booze || !src.soda) // we didn't find any!  <:(
				return 0 // let's give up I guess (for now)  :'(
		if (src.booze && src.soda)
*/
/*
/mob/living/carbon/human/attack_hand(mob/M)
	if (src.protected_by_npcs)
		..()
		if (M.a_intent in list(INTENT_HARM,INTENT_DISARM,INTENT_GRAB))
			for (var/mob/living/carbon/human/npc/diner_bartender/BT in all_viewers(7, src))
				BT.protect_from(M, src)
	else
		..()

/mob/living/carbon/human/attackby(obj/item/W, mob/M)
	if (src.protected_by_npcs)
		var/tmp/oldbloss = get_brute_damage()
		var/tmp/oldfloss = get_burn_damage()
		..()
		var/tmp/damage = ((get_brute_damage() - oldbloss) + (get_burn_damage() - oldfloss))
		if ((damage > 0) || W.force)
			for (var/mob/living/carbon/human/npc/diner_bartender/BT in all_viewers(7, src))
				BT.protect_from(M, src)
	else
		..()
*/
/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-+SAILOR MOON+-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

// it was inevitable the minute I sprited those damned sailor moon costumes. this was bound to happen eventually. hooray for gimmick items that are gunna be used like one time I guess
/obj/item/clothing/under/gimmick/sailormoon
	name = "magical sailor uniform"
	desc = "I don't think they'd allow this kind of outfit in most navies."
	icon_state = "sailormoon"
	item_state = "sailormoon"

/obj/item/clothing/head/sailormoon
	name = "hair clips"
	desc = "Shiny red hair clips to keep your hair in a very specific style and are about useless for anything else."
	icon_state = "sailormoon"

/obj/item/clothing/glasses/sailormoon
	name = "tiara"
	desc = "A golden tiara with a pretty red gem on it."
	icon_state = "sailormoon"
	throwforce = 15
	throw_range = 10
	throw_speed = 1
	throw_return = 1
	throw_spin = 0

	throw_begin(atom/target) // all stolen from the boomerang heh
		icon_state = "sailormoon1"
		playsound(src.loc, "swoosh", 50, 1)
		if (usr)
			usr.say("MOON TIARA ACTION!")
		return ..(target)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		icon_state = "sailormoon"
		if (hit_atom == usr)
			if (ishuman(usr))
				var/mob/living/carbon/human/usagi = usr
				if (!usagi.equip_if_possible(src, usagi.slot_glasses))
					usagi.put_in_hand_or_drop(src)
			else
				src.attack_hand(usr)
			return
		return ..(hit_atom)

/obj/item/clothing/gloves/sailormoon
	name = "gloves"
	desc = "Long white gloves with red bands on them."
	icon_state = "sailormoon"

/obj/item/clothing/shoes/sailormoon
	name = "boots"
	desc = "Nice red high-heeled boots."
	icon_state = "sailormoon"

/obj/item/sailormoon_brooch
	name = "transformation brooch"
	desc = "A little golden brooch that makes you feel compelled to yell silly things."
	icon = 'icons/obj/junk.dmi'
	icon_state = "moonbrooch"
	w_class = 1.0
	var/activated = 0

	verb/moon_prism_power()
		set category = "Local"
		set src in usr

		usr.show_text("WIP feature!")
		if (src.activated)
			return
		if (ishuman(usr))
			var/mob/living/carbon/human/usagi = usr
			usagi.say("MOON PRISM POWER, MAKE UP!")
			src.activated = 1
			for (var/i = 0, i < 4, i++)
				usagi.set_dir(turn(usagi.dir, -90))
				sleep(0.2 SECONDS)
			usagi.sailormoon_reshape()
			var/obj/critter/cat/luna = new /obj/critter/cat (usagi.loc)
			luna.name = "Luna"
			luna.desc = "A cat with a little crescent moon on her forehead."
			luna.cattype = 3
			luna.icon_state = "cat3"
			usagi.u_equip(src)
			qdel(src)
		return

/obj/item/sailormoon_wand
	name = "moon stick"
	desc = "Why is it called a moon stick? Well, it's a stick with a crescent moon at the end. Moon, stick. There you go."
	icon = 'icons/obj/junk.dmi'
	icon_state = "moonstick"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "moonstick"
	flags = FPRINT | TABLEPASS | ONBELT
	force = 2.0
	w_class = 2.0
	throwforce = 2.0
	throw_speed = 3
	throw_range = 5
	stamina_damage = 15
	stamina_cost = 3
	stamina_crit_chance = 15
	abilities = list(/obj/ability_button/sailormoon_heal)

/obj/ability_button/sailormoon_heal
	name = "Moon Healing Escalation"
	icon_state = "shieldceon"
	cooldown = 100

	ability_allowed()
		if (!the_mob || the_mob.stat || the_mob.getStatusDuration("paralysis"))
			boutput(the_mob, "<span class='alert'>You are incapacitated.</span>")
			return 0

		if (ishuman(the_mob))
			var/mob/living/carbon/human/usagi = the_mob
			if (!(istype(usagi.w_uniform, /obj/item/clothing/under/gimmick/sailormoon)))
				boutput(the_mob, "<span class='alert'>Your clothes don't feel magical enough to use this.</span>")
				return 0
			if (!usagi.find_in_hand(the_item))
				boutput(the_mob, "<span class='alert'>You have to be holding [the_item] to use this.</span>")
				return 0

		if (!..())
			return 0

		return 1

	execute_ability()
		the_mob.say("MOON HEALING ESCALATION!")
		for (var/mob/living/L in range(4, the_mob))
			L.HealDamage("All", 50, 50)
			blink(get_turf(L))
		icon_state = "shieldceoff"
		return 1

	on_cooldown()
		..()
		icon_state = "shieldceon"

/mob/living/carbon/human/proc/sailormoon_reshape() // stolen from Spy's tommyize stuff
	var/datum/appearanceHolder/AH = new
	AH.gender = "female"
	AH.customization_first = "Sailor Moon"
	AH.customization_first_color = "#FFD700"
	AH.owner = src
	AH.parentHolder = src.bioHolder

	src.gender = "female"
	src.real_name = "Sailor Moon"

	for (var/obj/item/clothing/O in src)
		src.u_equip(O)
		if (O)
			O.set_loc(src.loc)
			O.dropped(src)
			O.layer = initial(O.layer)

	src.equip_new_if_possible(/obj/item/clothing/under/gimmick/sailormoon , slot_w_uniform)
	src.equip_new_if_possible(/obj/item/clothing/glasses/sailormoon , slot_glasses)
	src.equip_new_if_possible(/obj/item/clothing/gloves/sailormoon , slot_gloves)
	src.equip_new_if_possible(/obj/item/clothing/shoes/sailormoon , slot_shoes)
	src.equip_new_if_possible(/obj/item/clothing/head/sailormoon , slot_head)
	src.equip_new_if_possible(/obj/item/sailormoon_wand , slot_in_backpack)

	if (src.bioHolder)
		src.bioHolder.mobAppearance = AH
		src.update_colorful_parts()

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-+MISCSTUFF+-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/obj/item/null_scalpel // really stupid gimmick thing I tried to make ages ago that never worked.  We have the sprite for it, so why not make it now?
	name = "null scalpel"
	desc = "This looks weird and dangerous."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "null_scalpel"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "scalpel"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	tool_flags = TOOL_CUTTING
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
	force = 3.0
	w_class = 1.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 35

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)

	attack(mob/living/carbon/M as mob, mob/user as mob)
		if (!ismob(M) || !M.contents.len)
			return ..()
		var/atom/movable/AM = pick(M.contents)
		if (!AM)
			return ..()
		user.visible_message("<span class='alert'><b>[user] somehow cuts [AM] out of [M] with [src]!</b></span>")
		playsound(get_turf(M), src.hitsound, 50, 1)
		if (istype(AM, /obj/item))
			user.u_equip(AM)
		AM.set_loc(get_turf(M))
		logTheThing("combat", user, M, "uses a null scalpel ([src]) on [M] and removes their [AM.name] at [log_loc(user)].")
		return

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] slashes [his_or_her(user)] own throat with [src]!</b></span>")
		blood_slash(user, 25)
		playsound(user.loc, src.hitsound, 50, 1)
		user.TakeDamage("head", 150, 0)
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/obj/item/gun/bling_blaster
	name = "fancy bling blaster"
	desc = "A big old gun with a slot on the side of it to insert cash. It seems to be made of gold, but isn't gold pretty soft? Is this safe?"
	icon_state = "bling_blaster"
	mat_changename = 0
	mat_changedesc = 0
	mat_appearances_to_ignore = list("gold") // we already look fine ty
	var/last_shot = 0
	var/shot_delay = 15
	var/cash_amt = 1000
	var/cash_max = 1000
	var/shot_cost = 100
	var/possible_bling_common = list(/obj/item/spacecash,/obj/item/spacecash/five,/obj/item/spacecash/ten)
	var/possible_bling_uncommon = list(/obj/item/spacecash/hundred,/obj/item/coin)
	var/possible_bling_rare = list(/obj/item/raw_material/gemstone,/obj/item/raw_material/gold)

	New()
		..()
		src.setMaterial(getMaterial("gold"))

	shoot(var/target,var/start,var/mob/user,var/POX,var/POY)
		if (!istype(target, /turf) || !istype(start, /turf))
			return
		if (target == user.loc || target == loc)
			return

		if ((last_shot + shot_delay) <= world.time)
			if (cash_amt <= 0)
				boutput(user, "<span class='success'>\The [src] beeps, \"I ain't got enough cash for that!\"</span>")
				return

			last_shot = world.time

			var/turf/T = get_turf(src)
			var/chosen_bling// = pick(60;/obj/item/spacecash,20;/obj/item/coin,10;/obj/item/raw_material/gemstone,10;/obj/item/raw_material/gold)
			if (islist(src.possible_bling_rare) && prob(10))
				chosen_bling = pick(src.possible_bling_rare)
			else if (islist(src.possible_bling_uncommon) && prob(20))
				chosen_bling = pick(src.possible_bling_uncommon)
			else if (islist(src.possible_bling_common))
				chosen_bling = pick(src.possible_bling_common)
			else
				chosen_bling = /obj/item/spacecash
			var/obj/item/bling = unpool(chosen_bling)
			bling.set_loc(T)
			bling.throwforce = 8
			src.cash_amt = max(src.cash_amt-src.shot_cost, 0)
			SPAWN_DBG(1.5 SECONDS)
				if (bling)
					bling.throwforce = 1
			bling.throw_at(target, 8, 2)
			playsound(T, "sound/effects/bamf.ogg", 40, 1)
			user.visible_message("<span class='success'><b>[user]</b> blasts some bling at [target]!</span>")

	attackby(var/obj/item/spacecash/C as obj, mob/user as mob)
		if (!istype(C))
			return ..()
		if (C.amount <= 0) // how??
			boutput(user, "<span class='success'>\The [src] beeps, \"Your cash is trash! It ain't worth jack, mack!\"<br>[C] promptly vanishes in a puff of logic.</span>")
			user.u_equip(C)
			pool(C)
			return
		if (src.cash_amt >= src.cash_max)
			boutput(user, "<span class='success'>\The [src] beeps, \"I ain't need no more money, honey!\"</span>")
			return
		var/max_accept = (src.cash_max - src.cash_amt)
		if (C.amount > max_accept)
			C.amount -= max_accept
			C.update_stack_appearance()
			src.cash_amt = src.cash_max
		else
			src.cash_amt += C.amount
			user.u_equip(C)
			pool(C)
		boutput(user, "<span class='success'>\The [src] beeps, \"That's the good stuff!\"</span>")

/obj/item/gun/bling_blaster/cheapo
	name = "bling blaster"
	possible_bling_rare = null

/obj/item/pen/crayon/lipstick // every time I think I've made the stupidest path I could, there's nowhere to go from here, I surpass my own expectations
	name = "lipstick"
	desc = "A tube of wax, oil and pigment that is intended to be used to color a person's lips."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "spacelipstick0"
	color = null
	font_color = "#FF0000"
	font = "Dancing Script, cursive"
	webfont = "Dancing Script"
	uses_handwriting = 1
	var/open = 0
	var/image/image_stick = null

	New()
		..()
		src.choose_random_color()

	proc/choose_random_color()
		if (prob(5)) // small chance to be a non-red/pink tone
			//src.font_color = random_saturated_hex_color()
			src.font_color = HSVtoRGB(hsv(AngleToHue(rand(0,360)), rand(180,255), rand(180,255)))
		else // generate reddish HSV
			src.font_color = HSVtoRGB(hsv(AngleToHue(rand(310,360)), rand(180,255), rand(180,255)))
		src.color_name = hex2color_name(src.font_color)
		src.name = "[src.color_name] lipstick"
		src.update_icon()

	proc/update_icon()
		src.icon_state = "spacelipstick[src.open]"
		if (src.open)
			ENSURE_IMAGE(src.image_stick, src.icon, "spacelipstick")
			src.image_stick.color = src.font_color
			src.UpdateOverlays(src.image_stick, "stick")
		else
			src.UpdateOverlays(null, "stick")

	attack_self(var/mob/user)
		src.open = !src.open
		src.update_icon()

	attack(mob/M as mob, mob/user as mob)
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.makeup == 2) // it's messed up
				user.show_text("Gurl, [H == user ? "you" : H] a hot mess right now. That all needs to be cleaned up first.", "red")
				return
			else
				actions.start(new /datum/action/bar/icon/apply_makeup(M, src, M == user ? 40 : 60), user)
		else
			return ..()

/datum/action/bar/icon/apply_makeup // yee
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "apply_makeup"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "spacelipstick1"
	var/mob/living/carbon/human/target
	var/obj/item/pen/crayon/lipstick/makeup

	New(ntarg, nmake, ndur)
		target = ntarg
		makeup = nmake
		duration = ndur
		..()

	onUpdate()
		..()
		if (get_dist(owner, target) > 1 || target == null || owner == null || makeup == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/ownerMob = owner
		if (makeup != ownerMob.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (get_dist(owner, target) > 1 || target == null || owner == null || makeup == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/ownerMob = owner
		if (makeup != ownerMob.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return

		for (var/mob/O in AIviewers(owner))
			O.show_message("[owner] begins applying [makeup] to [owner == target ? "[him_or_her(owner)]self" : target]!", 1)

	onInterrupt(var/flag)
		..()
		if (prob(owner == target ? 50 : 60))
			target.makeup = 2
			target.makeup_color = makeup.font_color
			target.update_body()
			for (var/mob/O in AIviewers(owner))
				O.show_message("<span class='alert'>[owner] messes up [owner == target ? "[his_or_her(owner)]" : "[target]'s"] makeup!</span>", 1)

	onEnd()
		..()
		var/mob/ownerMob = owner
		if (owner && ownerMob && target && makeup && makeup == ownerMob.equipped() && get_dist(owner, target) <= 1)
			target.makeup = 1
			target.makeup_color = makeup.font_color
			target.update_body()
			for (var/mob/O in AIviewers(ownerMob))
				O.show_message("[owner] applies [makeup] to [target ]!", 1)

/turf/unsimulated/floor/seabed
	name = "seabed"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand"

	New()
		..()
		src.set_dir(pick(cardinal))

//wrongend's bang! gun
/obj/item/bang_gun
	name = "revolver"
	icon_state = "revolver"
	desc = "There are 7 bullets left! Each shot will currently use 1 bullets!"
	flags = FPRINT | TABLEPASS | EXTRADELAY
	var/bangfired = 0 // Checks if the gun has been fired before or not. If it's been fired, no more firing for you
	var/description = "A bang flag pops out of the barrel!" // Used to fuck you and also decide what description is used for the fire text
	icon = 'icons/obj/items/gun.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "gun"

	pixelaction(atom/target, params, mob/user, reach)
		if(reach || src.bangfired)
			..()
		else
			src.bangfired = 1
			user?.visible_message("<span class='alert'><span class='alert'>[user] fires [src][target ? " at [target]" : null]! [description]</span>")
			playsound(get_turf(user), "sound/musical_instruments/Trombone_Failiure.ogg", 50, 1)
			icon_state = "bangflag[icon_state]"
			return

/obj/item/bang_gun/ak47
	name = "ak-477"
	icon_state = "ak47"
	desc = "There are 30 bullets left! Each shot will currently use 3 bullets!"
	description = "A bang flag unfurls out of the barrel!"

/obj/item/bang_gun/hunting_rifle
	name = "Old Hunting Rifle"
	icon_state = "hunting_rifle"
	desc = "There are 4 bullets left! Each shot will currently use 1 bullet!"
	description = "A bang flag unfurls out of the barrel!"

/*
/obj/item // if I accidentally commit this uncommented PLEASE KILL ME tia <3
	var/adj1 = 1
	var/adj2 = 100

/obj/item/scalpel
	attack_self(mob/user as mob)
		..()
		var/new_adj1 = input(user, "adj1", "adj1", src.adj1) as null|num
		var/new_adj2 = input(user, "adj2", "adj2", src.adj2) as null|num
		if (new_adj1)
			src.adj1 = new_adj1
		if (new_adj2)
			src.adj2 = new_adj2

/obj/item/circular_saw
	attack_self(mob/user as mob)
		..()
		var/new_adj1 = input(user, "adj1", "adj1", src.adj1) as null|num
		var/new_adj2 = input(user, "adj2", "adj2", src.adj2) as null|num
		if (new_adj1)
			src.adj1 = new_adj1
		if (new_adj2)
			src.adj2 = new_adj2
*/
/*
	var/num1 = "#FFFFFF"
	var/hexnum = copytext(num1, 2)
	var/num2 = num2hex(hex2num(hexnum) - 554040)
*/

/turf/simulated/tempstuff
	name = "floor"
	icon = 'icons/misc/HaineSpriteDump.dmi'
	icon_state = "gooberything_small"

/obj/item/blessed_ball_bearing
	name = "blessed ball bearing" // fill claymores with them for all your nazi-vampire-protection needs
	desc = "How can you tell it's blessed? Well, just look at it! It's so obvious!"
	icon = 'icons/misc/HaineSpriteDump.dmi'
	icon_state = "ballbearing"
	w_class = 1
	force = 7
	throwforce = 5
	stamina_damage = 25
	stamina_cost = 15
	stamina_crit_chance = 5
	rand_pos = 1

	attack(mob/M as mob, mob/user as mob) // big ol hackery here
		if (M && isvampire(M))
			src.force = (src.force * 2)
			src.stamina_damage = (src.stamina_damage * 2)
			src.stamina_crit_chance = (src.stamina_crit_chance * 2)
			..(M, user)
			src.force = (src.force / 2)
			src.stamina_damage = (src.stamina_damage / 2)
			src.stamina_crit_chance = (src.stamina_crit_chance / 2)
		else
			return ..()

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if (hit_atom && isvampire(hit_atom))
			src.force = (src.force * 2)
			src.stamina_damage = (src.stamina_damage * 2)
			src.stamina_crit_chance = (src.stamina_crit_chance * 2)
			..(hit_atom)
			src.force = (src.force / 2)
			src.stamina_damage = (src.stamina_damage / 2)
			src.stamina_crit_chance = (src.stamina_crit_chance / 2)
		else
			return ..()

/obj/item/space_thing
	name = "space thing"
	desc = "Some kinda thing, from space. In space. A space thing."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "thing"
	flags = FPRINT | CONDUCT | TABLEPASS
	w_class = 1.0
	force = 10
	throwforce = 7
	mats = 50
	contraband = 1
	stamina_damage = 40
	stamina_cost = 23
	stamina_crit_chance = 10

/obj/item/destiny_model
	name = "NSS Destiny model"
	desc = "A little model of the NSS Destiny. How spiffy!"
	icon = 'icons/misc/HaineSpriteDump.dmi'
	icon_state = "destiny"
	w_class = 1

/obj/test_knife_switch_switch
	name = "knife switch switch"
	desc = "This is an object that's just for testing the knife switch art. Don't use it!"
	icon = 'icons/obj/knife_switch.dmi'
	icon_state = "knife_switch1-throw"
	anchored = 1

	verb/change_icon()
		set name = "Change Switch Icon"
		set category = "Debug"
		set src in oview(1)

		var/list/switch_icons = list("switch1", "switch2", "switch3", "switch4", "switch5")

		var/switch_select = input("Switch Icon") as null|anything in switch_icons

		if (!switch_select)
			return
		src.icon_state = "[switch_select]-throw"

	attack_hand(mob/user as mob)
		src.change_icon()
		return

/obj/test_knife_switch_board
	name = "knife switch board"
	desc = "This is an object that's just for testing the knife switch art. Don't use it!"
	icon = 'icons/obj/knife_switch.dmi'
	icon_state = "knife_base1"
	anchored = 1

	verb/change_icon()
		set name = "Change Board Icon"
		set category = "Debug"
		set src in oview(1)

		var/list/board_icons = list("board1", "board2", "board3", "board4", "board5")

		var/board_select = input("Board Icon") as null|anything in board_icons

		if (!board_select)
			return
		src.icon_state = "[board_select]"

	attack_hand(mob/user as mob)
		src.change_icon()
		return

// tOt I ain't agree to no universal corgi ban
// and no one's gunna get it if they just see George and Blair okay!!
// and I can't just rename the pug!!!
/obj/critter/dog/george/orwell
	name = "Orwell"
	icon_state = "corgi"
	doggy = "corgi"

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-=+KALI-MA+=-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */
// shit be all janky and broken atm, gunna come back to it later
/*
Bali Mangthi Kali Ma.
Sacrifice is what Mother Kali desires.
Shakthi Degi Kali Ma.
Power is what Mother Kali will grant.
Kali ma...
Mother Kali...
Kali ma...
Mother Kali...
Kali ma, shakthi deh!
Mother Kali, give me power!
Ab, uski jan meri mutti me hai! AB, USKI JAN MERI MUTTI ME HAI!
Now, his life is in my fist! NOW, HIS LIFE IS IN MY FIST!

/obj/item/clothing/under/mola_ram
	name = "mola ram thing"
	desc = "kali ma motherfuckers"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_gimmick.dmi'
	icon_state = "bedsheet"
	item_state = "bedsheet"
	body_parts_covered = TORSO|LEGS|ARMS
	contraband = 8

	equipped(var/mob/user)
		user.verbs += /mob/proc/kali_ma

	unequipped(var/mob/user)
		user.verbs -= /mob/proc/kali_ma
		user.verbs -= /mob/proc/kali_ma_placeholder

/mob/proc/kali_ma_placeholder(var/mob/living/M in grabbing())
	set category = "Sacrifice"
	set name = "Throw (c)"
	set desc = "Spin a grabbed opponent around and throw them."

	boutput(usr, "<span class='alert'>Kali Ma is appeased for the moment!</span>")
	return

/mob/proc/kali_ma(var/mob/living/M in grabbing())
	set category = "Sacrifice"
	set name = "Throw"
	set desc = "Spin a grabbed opponent around and throw them."

	SPAWN_DBG(0)

		if(!src.stat && !src.transforming && M)
			if(src.getStatusDuration("paralysis") || src.getStatusDuration("weakened") || src.stunned > 0)
				boutput(src, "You can't do that while incapacitated!")
				return

			if(src.restrained())
				boutput(src, "You can't do that while restrained!")
				return

			else
				for(var/obj/item/grab/G in src)

					if(!G)
						boutput(src, "You must be grabbing someone for this to work!")
						return
					if(isliving(G.affecting))
						src.verbs += /mob/proc/kali_ma_placeholder
						src.verbs -= /mob/proc/kali_ma
						src.say("Bali Mangthi Kali Ma.")
						sleep(1 SECOND)
						var/mob/living/H = G.affecting
						if(H.lying)
							H.lying = 0
							H.delStatus("paralysis")
							H.delStatus("weakened")
							H.set_clothing_icon_dirty()
						H.transforming = 1
						src.transforming = 1
						src.set_dir(get_dir(src, H))
						H.set_dir(get_dir(H, src))
						src.visible_message("<span class='alert'><B>[src] menacingly grabs [H] by the neck!</B></span>")
						src.say("Shakthi Degi Kali Ma.")
						var/dir_offset = get_dir(src, H)
						switch(dir_offset)
							if(NORTH)
								H.pixel_y = -24
								H.layer = src.layer - 1
							if(SOUTH)
								H.pixel_y = 24
								H.layer = src.layer + 1
							if(EAST)
								H.pixel_x = -24
								H.layer = src.layer - 1
							if(WEST)
								H.pixel_x = 24
								H.layer = src.layer - 1
						for(var/i = 0, i < 5, i++)
							H.pixel_y += 2
							sleep(0.3 SECONDS)
						src.say("Kali Ma...")
						sleep(2 SECONDS)
						src.say("Kali Ma...")
						sleep(2 SECONDS)
						if (ishuman(H))
							var/mob/living/carbon/human/HU = H
							src.visible_message("<span class='alert'><B>[src] shoves \his hand into [H]'s chest!</B></span>")
							src.say("Kali ma, shakthi deh!")
							if(HU.heart_op_stage <= 3.0)
								HU:heart_op_stage = 4.0
								HU.contract_disease(/datum/ailment/disease/noheart,null,null,1)
								var/obj/item/organ/heart/heart = new /obj/item/organ/heart(src.loc)
								heart.donor = HU
								playsound(src.loc, "sound/impact_sounds/Flesh_Tear_2.ogg", 75)
								HU.emote("scream")
								sleep(2 SECONDS)
								src.say("Ab, uski jan meri mutti me hai! AB, USKI JAN MERI MUTTI ME HAI!")
							else
								playsound(src.loc, "sound/impact_sounds/Flesh_Tear_2.ogg", 75)
								HU.emote("scream")
								src.visible_message("<span class='alert'><B>[src] finds no heart in [H]'s chest! [src] looks kinda [pick(</span>"embarassed", "miffed", "annoyed", "confused", "baffled")]!</B>")
								sleep(2 SECONDS)
							HU.stunned += 10
							HU.weakened += 12
							var/turf/target = get_edge_target_turf(src, src.dir)
							SPAWN_DBG(0)
								playsound(src.loc, "swing_hit", 40, 1)
								src.visible_message("<span class='alert'><B>[src] casually tosses [H] away!</B></span>")
								HU.throw_at(target, 10, 2)
							HU.pixel_x = 0
							HU.pixel_y = 0
							HU.transforming = 0

						var/cooldown = max(100,(300-src.jitteriness))
						SPAWN_DBG(cooldown)
							src.verbs -= /mob/proc/kali_ma_placeholder
							if (istype(src:w_uniform, /obj/item/clothing/under/mola_ram))
								src.verbs += /mob/proc/kali_ma
								boutput(src, "<span class='alert'>Kali Ma desires more!</span>")

						return
*/

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-=+COCAINE+=-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */
/*
// http://en.wikipedia.org/wiki/Cocaine
// http://en.wikipedia.org/wiki/Cocaine_paste
// http://en.wikipedia.org/wiki/Crack_cocaine

/datum/overlayComposition/cocaine
	New()
		var/datum/overlayDefinition/zero = new()
		zero.d_icon_state = "beamout"
		zero.d_blend_mode = 2 //add
		zero.customization_third_color = "#08BFC2"
		zero.d_alpha = 50
		definitions.Add(zero)
/*		var/datum/overlayDefinition/spot = new()
		spot.d_icon_state = "knockout"
		spot.d_blend_mode = 3 //sub
		definitions.Add(spot) */
		return ..()

/datum/overlayComposition/cocaine_minor_od
	New()
		var/datum/overlayDefinition/zero = new()
		zero.d_icon_state = "beamout"
		zero.d_blend_mode = 2
		zero.customization_third_color = "#FFFFFF"
		zero.d_alpha = 50
		definitions.Add(zero)
/*		var/datum/overlayDefinition/spot = new()
		spot.d_icon_state = "knockout"
		spot.d_blend_mode = 3 //sub
		definitions.Add(spot) */
		return ..()

/datum/overlayComposition/cocaine_major_od
	New()
		var/datum/overlayDefinition/zero = new()
		zero.d_icon_state = "beamout"
		zero.d_blend_mode = 2
		zero.customization_third_color = "#C20B08"
		zero.d_alpha = 50
		definitions.Add(zero)
/*		var/datum/overlayDefinition/spot = new()
		spot.d_icon_state = "knockout"
		spot.d_blend_mode = 3 //sub
		definitions.Add(spot) */
		return ..()

/datum/reagent/drug/cocaine_paste
	name = "cocaine paste"
	id = "cocaine_paste"
	description = "A close precursor to cocaine, produced from the leaves of the coca plant. It's not very good for you. Cocaine isn't either, I mean, but at least it's better than this stuff."
	reagent_state = SOLID
	fluid_r = 210
	fluid_g = 220
	fluid_b = 210
	transparency = 255
	addiction_prob = 80
	overdose = 5
	var/remove_buff = 0

/datum/reagent/drug/cocaine
	name = "cocaine"
	id = "cocaine"
	description = "A powerful, dangerous stimulant produced from leaves of the coca plant. It's a fine white powder."
	reagent_state = SOLID
	fluid_r = 250
	fluid_g = 250
	fluid_b = 250
	transparency = 255
	addiction_prob = 75
	overdose = 15
	var/remove_buff = 0

// highly addictive, excellent stimulant.  makes you feel awesome, on top of the world, euphoric, etc.  numbs you a bit.
// as it leaves your system: paranoia, anxiety, restlessness.
// minor OD: paranoid delusions, itching, hallucinations, tachycardia
// major OD: hyperthermia, tremors, convulsions, arrythmia, and sudden cardiac death
// bubs idea (bubdea): medal for injecting someone with epinephrine while they have coke in their system, "Mrs. Wallace"
// <bubs> put the leaves in a thing with some welding fuel
// <bubs> and something analogous to paint thinner
// <bubs> to get cocaine paste
// <bubs> then combine the cocaine paste with sulfuric acid
// <bubs> then for additional fun combine it with baking soda in the kitchen
// <bubs> baking soda, dropper, cocaine in oven makes crack

	on_add()
		if(ismob(holder?.my_atom))
			var/mob/M = holder.my_atom
			APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_cocaine", 200)
			M.addOverlayComposition(/datum/overlayComposition/cocaine)
		return

	on_remove()
		if(ismob(holder?.my_atom))
			var/mob/M = holder.my_atom
			if (remove_buff)
				REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_cocaine")
			M.removeOverlayComposition(/datum/overlayComposition/cocaine)
			M.removeOverlayComposition(/datum/overlayComposition/cocaine_minor_od)
			M.removeOverlayComposition(/datum/overlayComposition/cocaine_major_od)
		return

// grabbing shit from meth, crank and bathsalts for now, cause they do some stuff close to what I want

	on_mob_life(var/mob/M)
		if(!M) M = holder.my_atom
		M.drowsyness = max(M.drowsyness-15, 0)
		if(M.getStatusDuration("paralysis")) M.paralysis-=3
		if(M.stunned) M.stunned-=3
		if(M.weakened) M.weakened-=3
		if(M.sleeping) M.sleeping = 0
		if(prob(15)) M.emote(pick("grin", "smirk", "blink", "blink_r", "nod", "twitch", "twitch_v", "laugh", "chuckle", "stare", "leer", "scream"))
		if(prob(10))
			boutput(M, pick("<span class='alert'><b>You [pick(</span>"feel", "are")] [pick("", "totally ", "utterly ", "completely ", "absolutely ")]fucking [pick("awesome", "rad", "great")]!</b>", "<span class='alert'><b>[pick(</span>"Fuck", "Fucking", "Hell")] [pick("yeah", "yes")]!</b>", "<span class='alert'><b>[pick(</span>"Yes", "YES")]!</b>", "<span class='alert'><b>You've got this shit in the BAG!</b></span>", "<span class='alert'><b>I said god DAMN!!!</b></span>"))
			M.emote(pick("grin", "smirk", "nod", "laugh", "chuckle", "scream"))
/*		if(prob(6))
			boutput(M, "<span class='alert'><b>You feel warm.</b></span>")
			M.bodytemperature += rand(1,10)
		if(prob(4))
			boutput(M, "<span class='alert'><b>You feel kinda awful!</b></span>")
			M.take_toxin_damage(1)
			M.make_jittery(30)
			M.emote(pick("groan", "moan")) */
		..(M)
		return

	do_overdose(var/severity, var/mob/M)
		var/effect = ..(severity, M)
		if (severity == 1)
			if(hascall(holder.my_atom,"removeOverlayComposition"))
				holder.my_atom:removeOverlayComposition(/datum/overlayComposition/cocaine)
				holder.my_atom:removeOverlayComposition(/datum/overlayComposition/cocaine_major_od)
			if(hascall(holder.my_atom,"addOverlayComposition"))
				holder.my_atom:addOverlayComposition(/datum/overlayComposition/cocaine_minor_od)
			if (effect <= 2)
				M.visible_message("<span class='alert'><b>[M.name]</b> looks confused!</span>", "<span class='alert'><b>Fuck, what was that?!</b></span>")
				M.change_misstep_chance(33)
				M.make_jittery(20)
				M.emote(pick("blink", "blink_r", "twitch", "twitch_v", "stare", "leer"))
			else if (effect <= 4)
				M.visible_message("<span class='alert'><b>[M.name]</b> is all sweaty!</span>", "<span class='alert'><b>Did it get way fucking hotter in here?</b></span>")
				M.bodytemperature += rand(10,30)
				M.brainloss++
				M.take_toxin_damage(1)
			else if (effect <= 7)
				M.make_jittery(30)
				M.emote(pick("blink", "blink_r", "twitch", "twitch_v", "stare", "leer"))
		else if (severity == 2)
			if(hascall(holder.my_atom,"removeOverlayComposition"))
				holder.my_atom:removeOverlayComposition(/datum/overlayComposition/cocaine)
				holder.my_atom:removeOverlayComposition(/datum/overlayComposition/cocaine_minor_od)
			if(hascall(holder.my_atom,"addOverlayComposition"))
				holder.my_atom:addOverlayComposition(/datum/overlayComposition/cocaine_major_od)
			if (effect <= 2)
				M.visible_message("<span class='alert'><b>[M.name]</b> is sweating like a pig!</span>", "<span class='alert'><b>Fuck, someone turn on the AC!</b></span>")
				M.bodytemperature += rand(20,100)
				M.take_toxin_damage(5)
			else if (effect <= 4)
				M.visible_message("<span class='alert'><b>[M.name]</b> starts freaking the fuck out!</span>", "<span class='alert'><b>Holy shit, what the fuck was that?!</b></span>")
				M.make_jittery(100)
				M.take_toxin_damage(2)
				M.brainloss += 8
				M.weakened += 3
				M.change_misstep_chance(40)
				M.emote("scream")
			else if (effect <= 7)
				M.emote("scream")
				M.visible_message("<span class='alert'><b>[M.name]</b> nervously scratches at their skin!</span>", "<span class='alert'><b>Fuck, so goddamn itchy!</b></span>")
				M.make_jittery(10)
				random_brute_damage(M, 5)
				M.emote(pick("blink", "blink_r", "twitch", "twitch_v", "stare", "leer"))


/* ----------Info from wikipedia----------
Cocaine is a powerful nervous system stimulant.
Its effects can last from fifteen to thirty minutes, to an hour.
That is all depending on the amount of the intake dosage and the route of administration.
Cocaine can be in the form of fine white powder, bitter to the taste.
When inhaled or injected, it causes a numbing effect.
"Crack" cocaine is a smokeable form of cocaine made into small "rocks" by processing cocaine with sodium bicarbonate (baking soda) and water.

Cocaine increases alertness, feelings of well-being and euphoria, energy and motor activity, feelings of competence and sexuality.
Anxiety, paranoia and restlessness can also occur, especially during the comedown.
With excessive dosage, tremors, convulsions and increased body temperature are observed.
Severe cardiac adverse events, particularly sudden cardiac death, become a serious risk at high doses due to cocaine's blocking effect on cardiac sodium channels.

With excessive or prolonged use, the drug can cause itching, tachycardia, hallucinations, and paranoid delusions.
Overdoses cause hyperthermia and a marked elevation of blood pressure, which can be life-threatening, arrhythmias, and death.
   --------------------------------------- */
*/
/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-MEDICALPROBLEMS-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */
/*
From Ali0en's thread here: https://forum.ss13.co/showthread.php?tid=4332
note: I'm gunna dump a bunch more info than needed in here so it's gunna SOUND like I want to simulate all of these to hell and back
I don't though, simplification of this stuff is important for goonstation, I just like having the info around because I'm a mild medical nerd (fyi (I kno u r shoked))

- Seizures: Makes people flop around like a fish or, in minor cases, stare off into space

- Aneurisms: Some chems to relax veins or surgery to install shunts/grafts. Causes internal bleeding, vomiting, and seizures

- Embolisms: Cause blood problems due to poor circulation

- Internal bleeding: Bleeding inside

- Strokes: Disables use of one side of the body (arms and leg, just as if amputated) until remedied, can be temporary and rather harmless or lethal. Bad cases should give players the mutant face to simulate facial droop
http://en.wikipedia.org/wiki/Stroke
http://en.wikipedia.org/wiki/Transient_ischemic_attack
"Stroke, also known as cerebrovascular accident (CVA), cerebrovascular insult (CVI), or brain attack" lol
two kinds:
	ischemic, due to lack of blood to the brain (due to thromboses, embolisms, general decrease in blood in the body - ex shock)
		types:
			total anterior (TACI)
			partial anterior (PACI)
			lacunar (LACI)
			posterior (POCI)
			all of which have similar but slightly different symptoms
		"Users of stimulant drugs such as cocaine and methamphetamine are at a high risk for ischemic strokes."
	hemorrhagic, due to too much blood accumulating in one place (usually due to injuries to the head)
		major types:
			intra-axial (cerebral hemorrhage/hematoma) (blood in the brain tissue itself)
			extra-axial (intracranial hemorrhage) (blood within the skull, outside the brain)
				epidural (between skull and dura mater)
				subdural (between dura mater and brain)
				subarachnoid (between arachnoid mater and pia mater) (may be considered a subtype of subdural?  may not, not entirely clear on this)
				(I'm sure there's all sorts of combos of meninges for these things but these are the notable ones, apparently)
		"Anticoagulant therapy, as well as disorders with blood clotting can heighten the risk that an intracranial hemorrhage will occur."
		"Factors increasing the risk of a subdural hematoma include very young or very old age."
		"Other risk factors for subdural bleeds include taking blood thinners (anticoagulants), long-term alcohol abuse, and dementia."
"The main risk factor for stroke is high blood pressure."
"Other risk factors include tobacco smoking, obesity, high blood cholesterol, diabetes, previous TIA, and atrial fibrillation among others."
symptoms:
	inability to move or feel on one side of the body
	problems understanding or speaking
	feeling like the world is spinning
	loss of one vision to one side
thoughts: a old-style disease with some vars to determine the kind - ischemic/hemorrhagic, which side it affects, etc.
	don't need to get real involved with the types or anything but maybe minor differences in symptoms
treatments:
	ischemic: aspirin (salicylic acid in our case) helps break down clots, if caused by lack of blood in general a transfusion would help
	hemorrhagic: surgery to drain the blood seems to be about it

- Congestive heart failure: Vomiting blood (or pink vomit) and oxy damage. Requires a new heart (I think something like that is already in but expand on it)

- Type 1 Diabetes: Patient needs insulin injections whenever they eat, make some pumps for advanced robotics stuff

- Pacemakers: Make them implants that auto-defib someone for a limited time, or at a weak amount
*/
