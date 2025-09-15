/obj/item/toy/figure
	name = "collectable figure"
	desc = SPAN_ALERT("<b>WARNING: CHOKING HAZARD</b> - Small parts. Not for children under 3 years.")
	icon = 'icons/obj/items/figures.dmi'
	icon_state = "fig-"
	w_class = W_CLASS_TINY
	throwforce = 1
	throw_speed = 4
	throw_range = 7
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0
	//mat_changename = 0
	rand_pos = 1
	var/patreon_prob = 9
	var/rare_prob = 12
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
		if (!length(donator_ckeys)) //creates a list of existing donator Ckeys if one does not already exist
			for (var/datum/figure_info/patreon/fig as anything in concrete_typesof(/datum/figure_info/patreon))
				donator_ckeys += initial(fig.ckey)

		if (istype(newInfo))
			src.info = newInfo
		else if (!istype(src.info))
			var/datum/figure_info/randomInfo

			var/potential_donator_ckey = usr?.mind?.ckey
			var/donator_fig_ckey = null
			var/list/online_donator_ckeys_nouser = online_donator_ckeys.Copy()

			if (online_donator_ckeys.Find(potential_donator_ckey))
				donator_fig_ckey = potential_donator_ckey
				online_donator_ckeys_nouser -= donator_fig_ckey
				src.patreon_prob *= 2	// x2 chance of getting patreon figure

			if (prob(src.patreon_prob))
				var/fig_ckey = null
				switch (rand(1,100))
					if (1 to 20)
						fig_ckey = donator_fig_ckey
					if (20 to 40)
						if (length(online_donator_ckeys_nouser))
							fig_ckey = pick(online_donator_ckeys_nouser)
					if (40 to 100)
						if (length(donator_ckeys))
							fig_ckey = pick(donator_ckeys)
				if (!fig_ckey) fig_ckey = pick(donator_ckeys)

				//Now that we've picked the ckey to look for, find its randomInfo
				for (var/datum/figure_info/patreon/fig as anything in concrete_typesof(/datum/figure_info/patreon))
					if (initial(fig.ckey) == fig_ckey)
						randomInfo = fig
						break

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
			src.create_reagents(30)

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
		user.visible_message(SPAN_ALERT("<b>[user] shoves [src] down [his_or_her(user)] throat and chokes on it!</b>"))
		user.take_oxygen_deprivation(175)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		qdel(src)
		return 1

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/toy/figure))
			if(user:a_intent == INTENT_HELP)
				playsound(src, 'sound/items/toys/figure-kiss.ogg', 15, TRUE)
				user.visible_message(SPAN_ALERT("[user] makes the [W.name] and the [src.name] kiss and kiss and kiss!"))
			else if(user:a_intent == INTENT_DISARM)
				playsound(src, 'sound/items/toys/figure-knock.ogg', 15, TRUE)
				user.visible_message(SPAN_ALERT("[user] makes the [W.name] knock over and fart on the [src.name]!"))
			else if(user:a_intent == INTENT_GRAB)
				playsound(src, 'sound/items/toys/figure-headlock.ogg', 15, TRUE)
				user.visible_message(SPAN_ALERT("[user] has [W.name] put the [src.name] in a headlock!"))
			else if(user:a_intent == INTENT_HARM)
				playsound(src, 'sound/impact_sounds/Flesh_Break_1.ogg', 15, TRUE, 0.1, 2.5)
				user.visible_message(SPAN_ALERT("[user] bangs the [W.name] into the [src.name] over and over!"))
		else if (W.force > 1 && src.icon_state == "fig-shelterfrog" || src.icon_state == "fig-shelterfrog-dead")
			playsound(src.loc, W.hitsound, 50, 1, -1)
			if (src.icon_state != "fig-shelterfrog-dead")
				make_cleanable(/obj/decal/cleanable/blood,get_turf(src))
				src.icon_state = "fig-shelterfrog-dead"
		user.lastattacked = get_weakref(src)
		return 0

	attack_self(mob/user as mob)
		if (!ishuman(user))
			return
		var/message = input("What should [src] say?")
		message = trimtext(copytext(sanitize(html_encode(message)), 1, MAX_MESSAGE_LEN))
		if (!message || BOUNDS_DIST(src, user) > 0)
			return
		logTheThing(LOG_SAY, user, "makes [src] say,  \"[message]\"")
		user.audible_message(SPAN_EMOTE("[src] says, \"[message]\""))
		var/mob/living/carbon/human/H = user
		if (H.sims)
			H.sims.affectMotive("fun", 1)

	afterattack(atom/target, mob/user, reach, params)
		..()

		if (istype(target,/obj/stool/bed))
			user.visible_message(SPAN_ALERT("[user] tucks the [src.name] into [target]."))
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

proc/add_to_donator_list(var/potential_donator_ckey)
	if (donator_ckeys.Find(potential_donator_ckey))
		online_donator_ckeys += potential_donator_ckey

var/list/figure_low_rarity = list(\
/datum/figure_info/assistant,
/datum/figure_info/chef,
/datum/figure_info/chaplain,
/datum/figure_info/bartender,
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
/datum/figure_info/mailcourier,
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
/datum/figure_info/father_grife,
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

var/list/figure_patreon_rarity = concrete_typesof(/datum/figure_info/patreon)

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

	bartender
		name = "bartender"
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

	mailcourier
		name = "mail courier"
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

	father_grife
		name = "\improper Father Grife"
		icon_state = "grife"

#ifdef XMAS
	santa
		name = "\improper Santa Claus"
		icon_state = "santa"
#endif


ABSTRACT_TYPE(/datum/figure_info/patreon)
/datum/figure_info/patreon
	/// ckey this figure is associated with
	var/ckey = null

	shelterfrog
		name = "\improper Sheltered Frog"
		icon_state = "shelterfrog"
		ckey = "flourish"

	dottyspud
		name = "\improper Dotty Spud"
		icon_state = "dottyspud"
		ckey = "mybluecorners"

	emilyclaire
		name = "\improper Emily Claire"
		icon_state = "emilyclaire"
		ckey = "ursulamejor"

	drsingh
		name = "\improper Dr. Singh"
		icon_state = "drsingh"
		ckey = "magicmountain"

	hubcapwillie
		name = "\improper Hubcap Willie"
		icon_state = "hubcapwillie"
		ckey = "simianc"

	smallbart
		name = "\improper Small Bart"
		icon_state = "smallbart"
		ckey = "reginaldhj"

	nolanstone
		name = "\improper Nolan Stone"
		icon_state = "nolanstone"
		ckey = "thegorog"

	jenidenton
		name = "\improper Jeni Denton"
		icon_state = "jenidenton"
		ckey = "ryumi"

	fredcooper
		name = "\improper Frederick Cooper"
		icon_state = "fredcooper"
		ckey = "pali6"

	spark
		name = "\improper S.P.A.R.K."
		icon_state = "spark"
		ckey = "gerhazo"

	jamesnowak
		name = "\improper James Nowak"
		icon_state = "jamesnowak"
		ckey = "thenicked"

	floorpills
		name = "\improper Dr. Floorpills"
		icon_state = "floorpills"
		ckey = "sartorius7"

	stephaniemir
		name = "\improper Stephanie Mir"
		icon_state = "stephaniemir"
		ckey = "zamujasa"

	fletcherhenderson
		name = "\improper Fletcher Henderson"
		icon_state = "fletcherhenderson"
		ckey = "pacra"

	adaohara
		name = "\improper Ada O'Hara"
		icon_state = "adaohara"
		ckey = "adharainspace"

	oranges
		name = "\improper The Tangerine"
		icon_state = "oranges"
		ckey = "optimumtact"

	sam
		name = "\improper S.A.M."
		icon_state = "sam"
		ckey = "recursor"

	beebo
		name = "\improper Beebo"
		icon_state = "beebo"
		ckey = "scaltra"

	romillybartlesby
		name = "\improper Romilly Bartlesby"
		icon_state = "romillybartlesby"
		ckey = "erinexx"

	dillbehrt
		name = "\improper Dill Behrt"
		icon_state = "dillbehrt"
		ckey = "tdhooligan"

	listelsheerfield
		name = "\improper Listel Sheerfield"
		icon_state = "listelsheerfield"
		ckey = "couturier"

	raphaelzahel
		name = "\improper Raphael Zahel"
		icon_state = "raphaelzahel"
		ckey = "kamades"

	derekclarke
		name = "\improper Derek Clarke"
		icon_state = "derekclarke"
		ckey = "heisenbee"

	fartcan
		name = "\improper Fart Canister"
		icon_state = "fartcan"
		ckey = "warcrimes"

	tomato
		name = "\improper Tomato"
		icon_state = "tomato"
		ckey = "tomatogaming"

	zooblarskrippus
		name = "\improper Zooblar Skrippus"
		icon_state = "zooblarskrippus"
		ckey = "stush"

	vivi
		name = "\improper Vivi"
		icon_state = "vivi"
		ckey = "zadenae"

	giggles
		name = "\improper Giggles"
		icon_state = "giggles"
		ckey = "grizzlybutch"

	mavericksabre
		name = "\improper Maverick Sabre"
		icon_state = "mavericksabre"
		ckey = "wrench1"

	anguishedenglish
		name = "\improper Whitney Blanchet"
		icon_state = "whitneyblanchet"
		ckey = "anguishedenglish"

	fleur
		name = "\improper Fleur DeLaCreme"
		icon_state = "fleur"
		ckey = "janantilles"

	joaquinfry
		name = "\improper Joaquin Fry"
		icon_state = "joaquinfry"

	carolineaudibert
		name = "\improper Caroline Audibert"
		icon_state = "carolineaudibert"
		ckey = "tterc"

	helgergunnink
		name = "\improper Helger Gunnink"
		icon_state = "helgergunnink"
		ckey = "Ssaintsblizzard"

	hex
		name = "\improper HEX"
		icon_state = "hex"
		ckey = "luxizzle"

	tray
		name = "\improper Tray"
		icon_state = "tray"
		ckey = "awarriorbunny"

	smellstosee
		name = "\improper Smells to See"
		icon_state = "smellstosee"
		ckey = "zergspower"

	bunnyfriendsmen
		name = "\improper Bunny Friendsmen"
		icon_state = "bunnyfriendsmen"
		ckey = "bunnykimber"

	retrino
		name = "\improper Mallow Rhosin"
		icon_state = "mallowrhosin"
		ckey = "retrino"

		New()
			..()
			if(prob(50))
				src.name = "\improper Matcha Usucha" //retrino's second character
				src.icon_state = "matchausucha"

	hazel
		name = "\improper Hazel Adenine"
		icon_state = "hazel"
		ckey = "hazelmaecry"

	vicky
		name = "\improper Vicky Hudson"
		icon_state = "vicky"
		ckey = "mrprogamer96"

	camrynstern
		name = "\improper Camryn Stern"
		icon_state = "camrynstern"
		ckey = "richardgere"

	edwardly
		name = "\improper Newt Treitor"
		icon_state = "newttreitor"
		ckey = "edwardly"

	ook
		name = "\improper Ook"
		icon_state = "ook"
		ckey = "taocat"

	brucemcafee
		name = "\improper Bruce McAfee"
		icon_state = "brucemcafee"
		ckey = "mysticmidgit"

	chefbot
		name = "\improper ChefBot"
		icon_state = "chefbot"
		ckey = "skeletondoot"

	flyntloach
		name = "\improper Flynt Loach"
		icon_state = "flyntloach"
		ckey = "profomii"

	dennismccreary
		name = "\improper Dennis McCreary"
		icon_state = "dennismccreary"
		ckey = "lordvoxelrot"

	stinko
		name = "\improper Stinko"
		icon_state = "stinko"
		ckey = "dataerr0r"

	gabr
		name = "\improper Jayson Rodgers"
		icon_state = "jaysonrodgers"
		ckey = "gabr"

	wivernshy
		name = "\improper Fern Barker"
		icon_state = "fernbarker"
		ckey = "wivernshy"

	kingmorshu552
		name = "\improper David Cain"
		icon_state = "davidcain"
		ckey = "kingmorshu552"

	telareti
		name = "\improper Gael Yamikurai"
		icon_state = "gaelyamikurai"
		ckey = "telareti"

	averyquill
		name = "\improper Miss Helper"
		icon_state = "misshelper"
		ckey = "averyquill"

	slashsync
		name = "\improper Snark"
		icon_state = "snark"
		ckey = "slashsync"

	zigguratx
		name = "\improper Zoya Wagner"
		icon_state = "zoyawagner"
		ckey = "zigguratx"

	badshot
		name = "\improper Lydia Aivoras"
		icon_state = "lydiaaivoras"
		ckey = "badshot"

	ezio334
		name = "\improper Ezio Dane"
		icon_state = "eziodane"
		ckey = "ezio334"

	ryeanbread
		name = "\improper Neo Ryder"
		icon_state = "neoryder"
		ckey = "ryeanbread"

	twobraids
		name = "\improper Nurse Dee Ceased"
		icon_state = "nursedeeceased"
		ckey = "twobraids"

	mikethewalldweller
		name = "\improper Mikey"
		icon_state = "mikey"
		ckey = "mikethewalldweller"

	ladygeartheart
		name = "\improper Piffany Boudle"
		icon_state = "piffany"
		ckey = "ladygeartheart"

	snowkeith
		name = "\improper SC077Y"
		icon_state = "sc077y"
		ckey = "snowkeith"

	ihaveteeth
		name = "\improper Teeth Rattletail"
		icon_state = "teeth"
		ckey = "ihaveteeth"

	walpvrgis
		name = "\improper Cygnus Gwyllion"
		icon_state = "cygnus"
		ckey = "walpvrgis"

	froggitdogget
		name = "\improper Investigangster Klutz"
		icon_state = "froggit"
		ckey = "froggitdogget"

	munien
		name = "\improper Elijah Caldwell"
		icon_state = "elijahcaldwell"
		ckey = "munien"

	calliopesoups
		name = "\improper Grup Guppy"
		icon_state = "grupguppy"
		ckey = "calliopesoups"

	eggcereal
		name = "\improper Litol Guy"
		icon_state = "litol"
		ckey = "eggcereal"

	yourdadthesquid
		name = "\improper Roxy"
		icon_state = "roxy"
		ckey = "yourdadthesquid"

	dumbnewguy
		name = "\improper Cackles Maniacally"
		icon_state = "cackles"
		ckey = "dumbnewguy"

	avimour
		name = "\improper Siva Fata"
		icon_state = "sivafata"
		ckey = "avimour"

	aft2001
		name = "\improper NEX-13"
		icon_state = "nex"
		ckey = "aft2001"

	improvedname
		name = "\improper Latex Lizard"
		icon_state = "latexlizard"
		ckey = "improvedname"

	haydus
		name = "\improper Sonya Azazel"
		icon_state = "sonyaazazel"
		ckey = "haydus"

	largeamountsofscreaming
		name = "\improper Mavis Moovenheimer"
		icon_state = "mavis"
		ckey = "largeamountsofscreaming"

	rockinend
		name = "\improper Rooke Ennen"
		icon_state = "rookeennen"
		ckey = "rockingend"

	rycool
		name = "\improper Neo Politan"
		icon_state = "neopolitan"
		ckey = "rycool"

	konamaco
		name = "\improper Johnathan Pepper"
		icon_state = "jonathanpepper"
		ckey = "konamaco"

	coolcrow420
		name = "\improper Niko Balthazar"
		icon_state = "nikobalthazar"
		ckey = "coolcrow420"

	comradeinput
		name = "\improper Ezra Callison"
		icon_state = "ezracallison"
		ckey = "comradeinput"

	goosime
		name = "\improper James Crowley"
		icon_state = "jamescrowley"
		ckey = "gooisme"

	folty
		name = "\improper Derrick Sholl"
		icon_state = "derricksholl"
		ckey = "folty"

	evaevaevaeva
		name = "\improper Alma Lowry"
		icon_state = "almalowry"
		ckey = "evaevaevaeva"

	fredric_80100
		name = "\improper Pearl Shess"
		icon_state = "pearlshess"
		ckey = "fredric_80100"

	seththecleric
		name = "\improper Stephen Sawer"
		icon_state = "stephensawer"
		ckey = "seththecleric"

	jugularWhale
		name = "\improper Norm AlMann"
		icon_state = "normalmann"
		ckey = "jugularWhale"

	carton171
		name = "\improper Andrew Pieter"
		icon_state = "andrewpieter"
		ckey = "carton171"

	jebsvs
		name = "\improper Snart Blast"
		icon_state = "snartblast"
		ckey = "jebsvs"

	lazy_shyguy
		name = "\improper Bjeurn Seuz"
		icon_state = "bjeurnseuz"
		ckey = "lazy_shyguy"

	mrmora
		name = "\improper Loyd Xiphos"
		icon_state = "loydxiphos"
		ckey = "mrmora"

	mintyphresh
		name = "\improper Arp Davale"
		icon_state = "arpdavale"
		ckey = "mintyphresh"

	fourfourfourexplorer
		name = "\improper Minty"
		icon_state = "minty"
		ckey = "444explorer"

	jonaleia
		name = "\improper Arcas Lake-Younger"
		icon_state = "arcas"
		ckey = "jonaleia"
	huskymaru
		name = "\improper Neo Lycan"
		icon_state = "neolycan"
		ckey = "huskymaru"
	bowlofnuts
		name = "\improper Argile Pratt"
		icon_state = "argile"
		ckey = "bowlofnuts"

	joeled
		name = "\improper Tank Transfer"
		icon_state = "tanktransfer"
		ckey = "joeled"

	firekestrel
		name = "\improper Merryn Morse"
		icon_state = "morse"
		ckey = "firekestrel"

	lyy
		name = "\improper Jelly Fish"
		icon_state = "jellyfish"
		ckey = "lyy"

	avanth
		name = "\improper Sally MacCaa"
		icon_state = "sallymaccaa"
		ckey = "avanth"

	rukert
		name = "\improper Rupert Crimehanson"
		icon_state = "rupertcrimehanson"
		ckey = "rukert"

	kirdy2
		name = "\improper Old Longbert"
		icon_state = "oldlongbert"
		ckey = "kirdy2"

	O514
		name = "\improper Emma Nureni"
		icon_state = "emmanureni"
		ckey = "O514"

	sockssq
		name = "\improper Hot Fudge"
		icon_state = "hotfudge"
		ckey = "sockssq"

	torchwick
		name = "\improper Sam Relius"
		icon_state = "samrelius"
		ckey = "torchwick"
	klushy225
		name = "\improper Munches Paper"
		icon_state = "munchespaper"
		ckey = "klushy225"
	linkey
		name = "\improper Kate Smith"
		icon_state = "katesmith"
		ckey = "linkey"
	gibusgame
		name = "\improper Harper Costache"
		icon_state = "harpercostache"
		ckey = "gibusgame"
	lazybones123
		name = "\improper Normal Human"
		icon_state = "normalhuman"
		ckey = "lazybones123"
	emeraldcrow
		name = "\improper Caitlin"
		icon_state = "caitlin"
		ckey = "emeraldcrow"
	kikimofo
		name = "\improper Kiki Kolana"
		icon_state = "kikikolana"
		ckey = "kikimofo"
	fffootloose
		name = "\improper Leeland Ponds"
		icon_state = "leelandponds"
		ckey = "fffootloose"
	tamedevil
		name = "\improper Vaughn Guy"
		icon_state = "vaughnguy"
		ckey = "tamedevil"
	laticauda
		name = "\improper Tommy Guillaume"
		icon_state = "tommyguillaume"
		ckey = "laticauda"
	brainrot
		name = "\improper Latte Cappuccino"
		icon_state = "lattecappuccino"
		ckey = "brainrot"
	outbackcatgirl
		name = "\improper Catherine McFluffums"
		icon_state = "catherinemcfluffums"
		ckey = "outbackcatgirl"
	superbongotime
		name = "\improper Laylith Blackwing"
		icon_state = "laylithblackwing"
		ckey = "superbongotime"
	raccoonpope
		name = "\improper Cynthia Xeonyr"
		icon_state = "cynthiaxeonyr"
		ckey = "raccoonpope"
	ovaiggy
		name = "\improper Sachie Blunt"
		icon_state = "sachieblunt"
		ckey = "ovaiggy"
	ithebinman
		name = "\improper The Mucus Man"
		icon_state = "themucusman"
		ckey = "ithebinman"

/obj/item/item_box/figure_capsule
	name = "capsule"
	desc = "A little plastic ball for keeping stuff in. Woah! We're truly in the future with technology like this."
	icon = 'icons/obj/items/figures.dmi'
	icon_state = "cap-y"
	contained_item = /obj/item/toy/figure
	item_amount = 1
	max_item_amount = 1
	//reusable = 0
	rand_pos = 1
	var/ccolor = "y"
	var/image/cap_image = null
	var/itemstate = "cap-fig"

	New()
		..()
		src.ccolor = pick("y", "r", "g", "b")
		src.UpdateIcon()

	update_icon()

		if (src.icon_state != "cap-[src.ccolor]")
			src.icon_state = "cap-[src.ccolor]"
		if (!src.cap_image)
			src.cap_image = image(src.icon, "cap-cap[src.item_amount ? 1 : 0]")
		if (src.open)
			if (src.item_amount)
				src.cap_image.icon_state = itemstate
				src.UpdateOverlays(src.cap_image, "cap")
			else
				src.UpdateOverlays(null, "cap")
		else
			src.cap_image.icon_state = "cap-cap[src.item_amount ? 1 : 0]"
			src.UpdateOverlays(src.cap_image, "cap")

	attack_self(mob/user as mob)
		if (!ON_COOLDOWN(user, "capsule_pop", 1 SECOND) && open == 0)
			playsound(user.loc, 'sound/items/capsule_pop.ogg', 30, 1)
		else if (open && item_amount == 0)
			user.playsound_local(user, 'sound/items/can_crush-3.ogg', 50, 1)
			boutput(user, SPAN_NOTICE("You crush the empty capsule into an insignificant speck."))
			qdel(src)
			return
		..()

/obj/machinery/vending/capsule
	name = "capsule machine"
	desc = "A little figure in every capsule, guaranteed*!"
	pay = 1
	vend_delay = 15
	icon = 'icons/obj/items/figures.dmi'
	icon_state = "machine1"
	icon_panel = "machine-panel"
	var/sound_vend = 'sound/machines/capsulebuy.ogg'
	var/base_icon_state = "machine1"
	var/image/capsule_image = null

	create_products(restocked)
		product_list += new/datum/data/vending_product(/obj/item/item_box/figure_capsule, 35, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/satchel/figurines, 2, cost=PAY_UNTRAINED*3)
		product_list += new/datum/data/vending_product(/obj/item/item_box/figure_capsule/gaming_capsule, rand(4,10), cost=PAY_UNTRAINED/3, hidden=1)
		src.base_icon_state = "machine[rand(1,6)]"
		src.icon_state = src.base_icon_state
		src.capsule_image = image(src.icon, "m_caps26")
		src.UpdateOverlays(src.capsule_image, "capsules")

	prevend_effect()
		playsound(src.loc, sound_vend, 80, 1)
		SPAWN(1 SECOND)
			var/datum/data/vending_product/R = src.product_list[1]
			src.capsule_image.icon_state = "m_caps[R.product_amount]"
			src.UpdateOverlays(src.capsule_image, "capsules")

	set_broken()
		. = ..()
		if (.) return
		if (src.fallen)
			src.icon_state = "[src.base_icon_state]-fallen-broken"
		else
			src.icon_state = "[src.base_icon_state]-broken"

	fall()
		..()
		src.capsule_image.pixel_x = src.pixel_x - 4
		src.capsule_image.pixel_y = src.pixel_y - 8
		src.UpdateOverlays(src.capsule_image, "capsules")
		if (src.status & BROKEN)
			src.icon_state = "[src.base_icon_state]-fallen-broken"
		else
			src.icon_state = "[src.base_icon_state]-fallen"

	right()
		..()
		src.capsule_image.pixel_x = src.pixel_x
		src.capsule_image.pixel_y = src.pixel_y
		src.UpdateOverlays(src.capsule_image, "capsules")
		src.icon_state = src.base_icon_state

	powered()
		return

	use_power()
		return

	power_change()
		return
