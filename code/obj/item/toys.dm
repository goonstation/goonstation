/obj/submachine/claw_machine
	name = "claw machine"
	desc = "Sure we got our health insurance benefits cut, and yeah we don't get any overtime on holidays, but hey - free to play claw machines!"
	icon = 'icons/obj/plushies.dmi'
	icon_state = "claw"
	anchored = 1
	density = 1
	deconstruct_flags = DECON_MULTITOOL | DECON_WRENCH | DECON_CROWBAR
	var/busy = 0
	var/list/prizes = list(/obj/item/toy/plush/small/bee,\
	/obj/item/toy/plush/small/buddy,\
	/obj/item/toy/plush/small/kitten,\
	/obj/item/toy/plush/small/monkey,\
	/obj/item/toy/plush/small/possum,\
	/obj/item/toy/plush/small/wendigo,\
	/obj/item/toy/plush/small/bunny,\
	/obj/item/toy/plush/small/penguin)
	var/list/prizes_rare = list(/obj/item/toy/plush/small/bee/cute,\
	/obj/item/toy/plush/small/buddy/future,\
	/obj/item/toy/plush/small/kitten/wizard,\
	/obj/item/toy/plush/small/monkey/assistant,\
	/obj/item/toy/plush/small/bunny/mask,\
	/obj/item/toy/plush/small/penguin/cool)
	var/list/prizes_ultra_rare = list(/obj/item/toy/plush/small/orca, /obj/item/toy/plush/small/tuba, /obj/item/toy/plush/small/chris)

/obj/submachine/claw_machine/attack_hand(var/mob/user as mob)
	src.add_dialog(user)
	if(src.busy)
		boutput(user, "<span class='alert'>Someone else is currently playing [src]. Be patient!</span>")
	else
		actions.start(new/datum/action/bar/icon/claw_machine(user,src), user)
		return

/datum/action/bar/icon/claw_machine
	duration = 100
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ACTION
	id = "claw_machine"
	icon = 'icons/obj/plushies.dmi'
	icon_state = "claw_action"
	var/mob/M
	var/obj/submachine/claw_machine/CM

/datum/action/bar/icon/claw_machine/New(mob, machine)
	M = mob
	CM = machine
	..()

/datum/action/bar/icon/claw_machine/onUpdate()
	..()
	if(get_dist(M, CM) > 1 || M == null || CM == null)
		interrupt(INTERRUPT_ALWAYS)
		return
	if(prob(10))
		playsound(get_turf(CM), 'sound/machines/claw_machine_fail.ogg', 80, 1)
		M.visible_message("<span class='alert'>[M] flubs up and the claw drops [his_or_her(M)] prize!</spawn>")
		interrupt(INTERRUPT_ALWAYS)
		return

/datum/action/bar/icon/claw_machine/onInterrupt()
	..()
	CM.busy = 0
	CM.icon_state = "claw"

/datum/action/bar/icon/claw_machine/onStart()
	..()
	if(get_dist(M, CM) > 1 || M == null || CM == null)
		interrupt(INTERRUPT_ALWAYS)
		return
	playsound(get_turf(CM), 'sound/machines/capsulebuy.ogg', 80, 1)
	CM.busy = 1
	CM.icon_state = "claw_playing"

/datum/action/bar/icon/claw_machine/onEnd()
	..()
	if(get_dist(M, CM) > 1 || M == null || CM == null)
		interrupt(INTERRUPT_ALWAYS)
		return
	CM.busy = 0
	CM.icon_state = "claw"
	playsound(get_turf(CM), 'sound/machines/claw_machine_success.ogg', 80, 1)
	M.visible_message("<span class='notice'>[M] successfully secures their precious goodie, and it drops into the prize chute with a satisfying <i>plop</i>.</span>")
	var/obj/item/P = pick(prob(10) ? (prob(10) ? CM.prizes_ultra_rare : CM.prizes_rare) : CM.prizes)
	P = new P(get_turf(src.M))
	P.desc = "Your new best friend, rescued from a cold and lonely claw machine."
	P.throw_at(M, 16, 3)

/obj/item/toy/plush
	name = "plush toy"
	icon = 'icons/obj/plushies.dmi'
	icon_state = "bear"
	desc = "A cute and cuddly plush toy!"
	throwforce = 3
	w_class = 4.0
	throw_speed = 2
	throw_range = 3
	rand_pos = 1

/obj/item/toy/plush/attack_self(mob/user as mob)
	if (!ishuman(user))
		return
	var/message = input("What should [src] say?")
	message = trim(copytext(sanitize(html_encode(message)), 1, MAX_MESSAGE_LEN))
	if (!message || get_dist(src, user) > 1)
		return
	logTheThing("say", user, null, "makes [src] say,  \"[message]\"")
	user.audible_message("<span class='emote'>[src] says, \"[message]\"</span>")
	var/mob/living/carbon/human/H = user
	if (H.sims)
		H.sims.affectMotive("fun", 1)

/obj/item/toy/plush/small
	name = "small plush toy"
	desc = "You found a new friend!"
	w_class = 3.0
	throw_speed = 3
	throw_range = 5

/obj/item/toy/plush/small/bee
	name = "bee plush toy"
	icon_state = "bee"

/obj/item/toy/plush/small/bee/cute
	name = "super cute bee plush toy"
	icon_state = "bee_cute"

/obj/item/toy/plush/small/buddy
	name = "buddy plush toy"
	icon_state = "buddy"

/obj/item/toy/plush/small/buddy/future
	name = "future buddy plush toy"
	icon_state = "buddy_future"

/obj/item/toy/plush/small/kitten
	name = "kitten plush toy"
	icon_state = "kitten"

/obj/item/toy/plush/small/kitten/wizard
	name = "wizard kitten plush toy"
	icon_state = "kitten_wizard"

/obj/item/toy/plush/small/monkey
	name = "monkey plush toy"
	icon_state = "monkey"

/obj/item/toy/plush/small/monkey/assistant
	name = "assistant monkey plush toy"
	icon_state = "monkey_assistant"

/obj/item/toy/plush/small/possum
	name = "possum plush toy"
	icon_state = "possum"

/obj/item/toy/plush/small/wendigo
	name = "wendigo plush toy"
	icon_state = "wendigo"

/obj/item/toy/plush/small/bunny
	name = "bunny plush toy"
	icon_state = "bunny"

/obj/item/toy/plush/small/bunny/mask
	name = "gas mask bunny plush toy"
	icon_state = "bunny_mask"

/obj/item/toy/plush/small/penguin
	name = "penguin plush toy"
	icon_state = "penguin"

/obj/item/toy/plush/small/penguin/cool
	name = "super cool penguin plush toy"
	icon_state = "penguin_cool"

/obj/item/toy/plush/small/orca
	name = "Lilac the orca"
	icon_state = "orca"

/obj/item/toy/plush/small/tuba
	name = "Tuba the rat"
	icon_state = "tuba"

/obj/item/toy/plush/small/chris
	name = "Chris the goat"
	icon_state = "chris"

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
		BLOCK_SWORD

	attack(target as mob, mob/user as mob)
		..()
		if (ishuman(user))
			var/mob/living/carbon/human/U = user
			if (U.gender == MALE)
				playsound(get_turf(U), pick(src.sound_attackM1, src.sound_attackM2), 100, 0, 0, U.get_age_pitch())
			else
				playsound(get_turf(U), pick(src.sound_attackF1, src.sound_attackF2), 100, 0, 0, U.get_age_pitch())

/obj/item/toy/figure
	name = "collectable figure"
	desc = "<b><span class='alert'>WARNING:</span> CHOKING HAZARD</b> - Small parts. Not for children under 3 years."
	icon = 'icons/obj/items/figures.dmi'
	icon_state = "fig-"
	w_class = 1.0
	throwforce = 1
	throw_speed = 4
	throw_range = 7
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0
	//mat_changename = 0
	rand_pos = 1
	var/patreon_prob = 8
	var/rare_prob = 11
	var/datum/figure_info/info = null

	// grumble grumble
	patreon
		patreon_prob = 100
		rare_prob = 0

	rare
		patreon_prob = 0
		rare_prob = 100


	New(loc, var/datum/figure_info/newInfo)
		..()
		if (istype(newInfo))
			src.info = newInfo
		else if (!istype(src.info))
			var/datum/figure_info/randomInfo

			if (prob(src.patreon_prob))
				randomInfo = pick(figure_patreon_rarity)
			else if (prob(src.rare_prob))
				randomInfo = pick(figure_high_rarity)
			else
				randomInfo = pick(figure_low_rarity)

			src.info = new randomInfo(src)
		src.name = "[src.info.name] figure"
		src.icon_state = "fig-[src.info.icon_state]"
		if (src.info.rare_varieties.len && prob(5))
			src.icon_state = "fig-[pick(src.info.rare_varieties)]"
		else if (src.info.varieties.len)
			src.icon_state = "fig-[pick(src.info.varieties)]"

		if (prob(1)) // rarely give a different material
			if (prob(1)) // VERY rarely give a super-fancy material
				var/list/rare_material_varieties = list("gold", "spacelag", "diamond", "ruby", "garnet", "topaz", "citrine", "peridot", "emerald", "jade", "aquamarine",
				"sapphire", "iolite", "amethyst", "alexandrite", "uqill", "uqillglass", "telecrystal", "miracle", "starstone", "flesh", "blob", "bone", "beeswax", "carbonfibre")
				src.setMaterial(getMaterial(pick(rare_material_varieties)))
			else // silly basic "rare" varieties of things that should probably just be fancy paintjobs or plastics, but whoever made these things are idiots and just made them out of the actual stuff.  I guess.
				var/list/material_varieties = list("steel", "glass", "silver", "quartz", "rosequartz", "plasmaglass", "onyx", "jasper", "malachite", "lapislazuli")
				src.setMaterial(getMaterial(pick(material_varieties)))

		if (src.icon_state == "fig-floorpills")
			var/datum/reagents/R = new/datum/reagents(30)
			src.reagents = R
			R.my_atom = src

			var/primaries = rand(1,3)
			var/adulterants = rand(2,4)

			while(primaries > 0)
				primaries--
				src.reagents.add_reagent(pick_string("chemistry_tools.txt", "CYBERPUNK_drug_primaries"), 6)
			while(adulterants > 0)
				adulterants--
				src.reagents.add_reagent(pick_string("chemistry_tools.txt", "CYBERPUNK_drug_adulterants"), 3)


	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] shoves [src] down [his_or_her(user)] throat and chokes on it!</b></span>")
		user.take_oxygen_deprivation(175)
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		qdel(src)
		return 1

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/toy/figure))
			if(user:a_intent == INTENT_HELP)
				playsound(get_turf(src), "sound/items/toys/figure-kiss.ogg", 15, 1)
				user.visible_message("<span class='alert'>[user] makes the [W.name] and the [src.name] kiss and kiss and kiss!</span>")
			else if(user:a_intent == INTENT_DISARM)
				playsound(get_turf(src), "sound/items/toys/figure-knock.ogg", 15, 1)
				user.visible_message("<span class='alert'>[user] makes the [W.name] knock over and fart on the [src.name]!</span>")
			else if(user:a_intent == INTENT_GRAB)
				playsound(get_turf(src), "sound/items/toys/figure-headlock.ogg", 15, 1)
				user.visible_message("<span class='alert'>[user] has [W.name] put the [src.name] in a headlock!</span>")
			else if(user:a_intent == INTENT_HARM)
				playsound(get_turf(src), "sound/impact_sounds/Flesh_Break_1.ogg", 15, 1, 0.1, 2.5)
				user.visible_message("<span class='alert'>[user] bangs the [W.name] into the [src.name] over and over!</span>")
		else if (W.force > 1 && src.icon_state == "fig-shelterfrog" || src.icon_state == "fig-shelterfrog-dead")
			playsound(src.loc, W.hitsound, 50, 1, -1)
			if (src.icon_state != "fig-shelterfrog-dead")
				make_cleanable(/obj/decal/cleanable/blood,get_turf(src))
				src.icon_state = "fig-shelterfrog-dead"
		user.lastattacked = src
		return 0

	attack_self(mob/user as mob)
		if (!ishuman(user))
			return
		var/message = input("What should [src] say?")
		message = trim(copytext(sanitize(html_encode(message)), 1, MAX_MESSAGE_LEN))
		if (!message || get_dist(src, user) > 1)
			return
		logTheThing("say", user, null, "makes [src] say,  \"[message]\"")
		user.audible_message("<span class='emote'>[src] says, \"[message]\"</span>")
		var/mob/living/carbon/human/H = user
		if (H.sims)
			H.sims.affectMotive("fun", 1)

	afterattack(atom/target, mob/user, reach, params)
		..()

		if (istype(target,/obj/stool/bed))
			user.visible_message("<span class='alert'>[user] tucks the [src.name] into [target].</span>")
			var/obj/O = target
			O.place_on(src, user, params)
			if (src.icon_state == "fig-beebo")
				src.icon_state = "fig-sleebee"
			else
				src.icon_state = "fig-beebo"



	UpdateName()
		if (istype(src.info))
			src.name = "[name_prefix(null, 1)][src.info.name] figure[name_suffix(null, 1)]"
		else
			return ..()

var/list/figure_low_rarity = list(\
/datum/figure_info/assistant,
/datum/figure_info/chef,
/datum/figure_info/chaplain,
/datum/figure_info/barman,
/datum/figure_info/botanist,
/datum/figure_info/janitor,
/datum/figure_info/doctor,
/datum/figure_info/geneticist,
/datum/figure_info/roboticist,
/datum/figure_info/scientist,
/datum/figure_info/security,
/datum/figure_info/detective,
/datum/figure_info/engineer,
/datum/figure_info/mechanic,
/datum/figure_info/miner,
/datum/figure_info/qm,
/datum/figure_info/monkey)

var/list/figure_high_rarity = list(\
/datum/figure_info/captain,
/datum/figure_info/hos,
/datum/figure_info/hop,
/datum/figure_info/md,
/datum/figure_info/rd,
/datum/figure_info/ce,
/datum/figure_info/boxer,
/datum/figure_info/lawyer,
/datum/figure_info/barber,
/datum/figure_info/mailman,
/datum/figure_info/tourist,
/datum/figure_info/vice,
/datum/figure_info/clown,
/datum/figure_info/traitor,
/datum/figure_info/changeling,
/datum/figure_info/nukeop,
/datum/figure_info/wizard,
/datum/figure_info/wraith,
/datum/figure_info/cluwne,
/datum/figure_info/macho,
/datum/figure_info/cyborg,
/datum/figure_info/ai,
/datum/figure_info/blob,
/datum/figure_info/werewolf,
/datum/figure_info/omnitraitor,
/datum/figure_info/shitty_bill,
/datum/figure_info/don_glabs,
/datum/figure_info/father_jack,
/datum/figure_info/inspector,
/datum/figure_info/coach,
/datum/figure_info/sous_chef,
/datum/figure_info/waiter,
/datum/figure_info/apiarist,
/datum/figure_info/journalist,
/datum/figure_info/diplomat,
/datum/figure_info/musician,
/datum/figure_info/salesman,
/datum/figure_info/union_rep,
/datum/figure_info/vip,
/datum/figure_info/actor,
/datum/figure_info/regional_director,
#ifdef XMAS
/datum/figure_info/santa,
#endif
/datum/figure_info/pharmacist,
/datum/figure_info/test_subject)

var/list/figure_patreon_rarity = list(\
/datum/figure_info/dottyspud,
/datum/figure_info/emilyclaire,
/datum/figure_info/drsingh,
/datum/figure_info/hubcapwillie,
/datum/figure_info/smallbart,
/datum/figure_info/nolanstone,
/datum/figure_info/jenidenton,
/datum/figure_info/fredcooper,
/datum/figure_info/spark,
/datum/figure_info/jamesnowak,
/datum/figure_info/shelterfrog,
/datum/figure_info/floorpills,
/datum/figure_info/stephaniemir,
/datum/figure_info/fletcherhenderson,
/datum/figure_info/adaohara,
/datum/figure_info/oranges,
/datum/figure_info/sam,
/datum/figure_info/beebo,
/datum/figure_info/romillybartlesby,
/datum/figure_info/dillbehrt,
/datum/figure_info/listelsheerfield,
/datum/figure_info/raphaelzahel,
/datum/figure_info/derekclarke,
/datum/figure_info/fartcan,
/datum/figure_info/tomato
)

/datum/figure_info
	var/name = "staff assistant"
	var/icon_state = "assistant"
	var/list/varieties = list() // basic versions that should always be picked between (ex: hos hat/hos beret)
	var/list/rare_varieties = list() // rare versions to be picked sometimes
	var/list/alt_names = list()

	New()
		..()
		if (src.alt_names.len)
			src.name = pick(src.alt_names)

	assistant
		rare_varieties = list("assistant2")

	chef
		name = "chef"
		icon_state = "chef"

	chaplain
		name = "chaplain"
		icon_state = "chaplain"

	barman
		name = "barman"
		icon_state = "barman"

	botanist
		name = "botanist"
		icon_state = "botanist"

	janitor
		name = "janitor"
		icon_state = "janitor"

	clown
		name = "clown"
		icon_state = "clown"

	boxer
		name = "boxer"
		icon_state = "boxer"

	lawyer
		name = "lawyer"
		icon_state = "lawyer"

	barber
		name = "barber"
		icon_state = "barber"

	mailman
		name = "mailman"
		icon_state = "mailman"

	atmos
		name = "atmos technician"
		icon_state = "atmos"

	tourist
		name = "tourist"
		icon_state = "tourist"

	vice
		name = "vice officer"
		icon_state = "vice"

	inspector
		name = "inspector"
		icon_state = "inspector"

	coach
		name = "coach"
		icon_state = "coach"

	sous_chef
		name = "sous-chef"
		icon_state = "sous"

	waiter
		name = "waiter"
		icon_state = "waiter"

	apiarist
		name = "apiarist"
		icon_state = "apiarist"
		alt_names = list("apiarist", "apiculturalist")

	journalist
		name = "journalist"
		icon_state = "journalist"

	diplomat
		name = "diplomat"
		icon_state = "diplomat"
		varieties = list("diplomat", "diplomat2", "diplomat3", "diplomat4")
		alt_names = list("diplomat", "ambassador")

	musician
		name = "musician"
		icon_state = "musician"

	salesman
		name = "salesman"
		icon_state = "salesman"
		alt_names = list("salesman", "merchant")

	union_rep
		name = "union rep"
		icon_state = "union"
		alt_names = list("union rep", "assistants union rep", "cyborgs union rep", "security union rep", "doctors union rep", "engineers union rep", "miners union rep")

	vip
		name = "\improper VIP"
		icon_state = "vip"
		alt_names = list("senator", "president", "\improper CEO", "board member", "mayor", "vice-president", "governor")

	actor
		name = "\improper Hollywood actor"
		icon_state = "actor"

	regional_director
		name = "regional director"
		icon_state = "regd"

	pharmacist
		name = "pharmacist"
		icon_state = "pharma"

	test_subject
		name = "test subject"
		icon_state = "testsub"

	doctor
		name = "medical doctor"
		icon_state = "doctor"

	geneticist
		name = "geneticist"
		icon_state = "geneticist"

	roboticist
		name = "roboticist"
		icon_state = "roboticist"

	scientist
		name = "scientist"
		icon_state = "scientist"
		varieties = list("scientist", "scientist2")

	security
		name = "security officer"
		icon_state = "security"

	detective
		name = "detective"
		icon_state = "detective"

	engineer
		name = "engineer"
		icon_state = "engineer"

	mechanic
		name = "mechanic"
		icon_state = "mechanic"

	miner
		name = "miner"
		icon_state = "miner"
		rare_varieties = list("miner2")

	qm
		name = "quartermaster"
		icon_state = "qm"

	captain
		name = "captain"
		icon_state = "captain"
		rare_varieties = list("captain2")//, "captain3")

	hos
		name = "head of security"
		icon_state = "hos"

	hop
		name = "head of personnel"
		icon_state = "hop"

	md
		name = "medical director"
		icon_state = "md"

	rd
		name = "research director"
		icon_state = "rd"

	ce
		name = "chief engineer"
		icon_state = "ce"

	cyborg
		name = "cyborg"
		icon_state = "borg"
		rare_varieties = list("borg2", "borg3")

	ai
		name = "\improper AI"
		icon_state = "ai"

	traitor
		name = "traitor"
		icon_state = "traitor"

	changeling
		name = "shambling abomination"
		icon_state = "changeling"

	vampire
		name = "vampire"
		icon_state = "vampire"

	nukeop
		name = "syndicate operative"
		icon_state = "nukeop"

	wizard
		name = "wizard"
		icon_state = "wizard"
		rare_varieties = list("wizard2", "wizard3")

	wraith
		name = "wraith"
		icon_state = "wraith"

	blob
		name = "blob"
		icon_state = "blob"

	werewolf
		name = "werewolf"
		icon_state = "werewolf"

	omnitraitor
		name = "omnitraitor"
		icon_state = "omnitraitor"

	cluwne
		name = "cluwne"
		icon_state = "cluwne"

	macho
		name = "macho man"
		icon_state = "macho"
		New()
			..()
			src.name = pick("\improper M", "m") + pick("a", "ah", "ae") + pick("ch", "tch", "tz") + pick("o", "oh", "oe") + " " + pick("M","m") + pick("a","ae","e") + pick("n","nn")

	monkey
		name = "monkey"
		icon_state = "monkey"

	shitty_bill
		name = "\improper Shitty Bill"
		icon_state = "bill"

	don_glabs
		name = "\improper Donald \"Don\" Glabs"
		icon_state = "don"

	father_jack
		name = "\improper Father Jack"
		icon_state = "jack"

	dottyspud
		name = "\improper Dotty Spud"
		icon_state = "dottyspud"

	emilyclaire
		name = "\improper Emily Claire"
		icon_state = "emilyclaire"

	drsingh
		name = "\improper Dr. Singh"
		icon_state = "drsingh"

	hubcapwillie
		name = "\improper Hubcap Willie"
		icon_state = "hubcapwillie"

	smallbart
		name = "\improper Small Bart"
		icon_state = "smallbart"

	nolanstone
		name = "\improper Nolan Stone"
		icon_state = "nolanstone"

	jenidenton
		name = "\improper Jeni Denton"
		icon_state = "jenidenton"


	fredcooper
		name = "\improper Frederick Cooper"
		icon_state = "fredcooper"

	spark
		name = "\improper S.P.A.R.K."
		icon_state = "spark"

	jamesnowak
		name = "\improper James Nowak"
		icon_state = "jamesnowak"

	shelterfrog
		name = "\improper Sheltered Frog"
		icon_state = "shelterfrog"


	floorpills
		name = "\improper Dr. Floorpills"
		icon_state = "floorpills"

	stephaniemir
		name = "\improper Stephanie Mir"
		icon_state = "stephaniemir"

	fletcherhenderson
		name = "\improper Fletcher Henderson"
		icon_state = "fletcherhenderson"

	adaohara
		name = "\improper Ada O'Hara"
		icon_state = "adaohara"

	oranges
		name = "\improper The Tangerine"
		icon_state = "oranges"

	sam
		name = "\improper S.A.M."
		icon_state = "sam"

	beebo
		name = "\improper Beebo"
		icon_state = "beebo"

	romillybartlesby
		name = "\improper Romilly Bartlesby"
		icon_state = "romillybartlesby"

	dillbehrt
		name = "\improper Dill Behrt"
		icon_state = "dillbehrt"

	listelsheerfield
		name = "\improper Listel Sheerfield"
		icon_state = "listelsheerfield"

	raphaelzahel
		name = "\improper Raphael Zahel"
		icon_state = "raphaelzahel"

	derekclarke
		name = "\improper Derek Clarke"
		icon_state = "derekclarke"

	fartcan
		name = "\improper Fart Canister"
		icon_state = "fartcan"

	tomato
		name = "\improper Tomato"
		icon_state = "tomato"

#ifdef XMAS
	santa
		name = "\improper Santa Claus"
		icon_state = "santa"
#endif
/obj/item/item_box/figure_capsule
	name = "capsule"
	desc = "A little plastic ball for keeping stuff in. Woah! We're truly in the future with technology like this."
	icon = 'icons/obj/items/figures.dmi'
	icon_state = "cap-y"
	uses_multiple_icon_states = 1
	contained_item = /obj/item/toy/figure
	item_amount = 1
	max_item_amount = 1
	//reusable = 0
	rand_pos = 1
	var/ccolor = "y"
	var/image/cap_image = null

	New()
		..()
		src.ccolor = pick("y", "r", "g", "b")
		src.update_icon()

	update_icon()
		if (src.icon_state != "cap-[src.ccolor]")
			src.icon_state = "cap-[src.ccolor]"
		if (!src.cap_image)
			src.cap_image = image(src.icon, "cap-cap[src.item_amount ? 1 : 0]")
		if (src.open)
			if (src.item_amount)
				src.cap_image.icon_state = "cap-fig"
				src.UpdateOverlays(src.cap_image, "cap")
			else
				src.UpdateOverlays(null, "cap")
		else
			src.cap_image.icon_state = "cap-cap[src.item_amount ? 1 : 0]"
			src.UpdateOverlays(src.cap_image, "cap")

/obj/machinery/vending/capsule
	name = "capsule machine"
	desc = "A little figure in every capsule, guaranteed*!"
	pay = 1
	vend_delay = 15
	icon = 'icons/obj/items/figures.dmi'
	icon_state = "machine1"
	icon_panel = "machine-panel"
	var/sound_vend = 'sound/machines/capsulebuy.ogg'
	var/image/capsule_image = null

	New()
		..()
		//Products
		product_list += new/datum/data/vending_product(/obj/item/item_box/figure_capsule, 26, cost=100)
		product_list += new/datum/data/vending_product(/obj/item/satchel/figurines, 2, cost=500)
		src.icon_state = "machine[rand(1,6)]"
		src.capsule_image = image(src.icon, "m_caps26")
		src.UpdateOverlays(src.capsule_image, "capsules")

	prevend_effect()
		playsound(src.loc, sound_vend, 80, 1)
		SPAWN_DBG(1 SECOND)
			var/datum/data/vending_product/R = src.product_list[1]
			src.capsule_image.icon_state = "m_caps[R.product_amount]"
			src.UpdateOverlays(src.capsule_image, "capsules")

	powered()
		return

	use_power()
		return

	power_change()
		return

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
