// zamu's "mail".
//
// mail in this case is actually just timed gifts sent to the crew,
// through the cargo system.
//
// mail is "locked" to the mob that should receive it,
// via dna (or whatever. todo: update me)
//
// ideally, the amount of mail "per cycle" would vary depending on
// how long since the last one and how many players are online
// ideally every player would get a few pieces of mail over the
// course of an hour (say, every 20 minutes)

/obj/item/random_mail
	name = "mail"
	desc = "A package!"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "mail-1"
	item_state = "gift"
	pressure_resistance = 70
	var/random_icons = TRUE
	var/spawn_type = null
	var/tmp/target_dna = null

	// this is largely copied from /obj/item/a_gift

	New()
		..()
		if (src.random_icons)
			src.icon_state = "mail-[rand(1,3)]"

	attack_self(mob/M as mob)
		if (!ishuman(M))
			boutput(M, SPAN_NOTICE("You aren't human, you definitely can't open this!"))

		if (src.target_dna)
			var/dna = M?.bioHolder?.Uid

			if (!dna || dna != src.target_dna)
				boutput(M, SPAN_NOTICE("This isn't addressed to you! Opening it would be <em>illegal!</em> Also, the DNA lock won't open."))
				return

		if (!src.spawn_type)
			boutput(M, SPAN_NOTICE("[src] was empty! What a rip!"))
			qdel(src)
			return

		var/atom/movable/prize = new src.spawn_type
		logTheThing(LOG_STATION, M, "opened their [src] and got \a [prize] ([src.spawn_type]).")
		game_stats.Increment("mail_opened")
		// 50 credits + 5 more for every successful delivery after the first,
		// capping at 500 each
		shippingmarket.mail_delivery_payout += 45 + 5 * min(91, game_stats.GetStat("mail_opened"))

		if (prize && istype(prize, /obj/item))
			boutput(M, SPAN_NOTICE("You open the package and pull out \a [prize]."))
			var/obj/item/P = prize
			M.u_equip(src)
			M.put_in_hand_or_drop(P)

		else if (prize)
			boutput(M, SPAN_NOTICE("You somehow pull \a [prize] out of \the [src]!"))
			prize.set_loc(get_turf(M))

		else
			boutput(M, SPAN_NOTICE("You have no idea what it is you did, but \the [src] collapses in on itself!"))
			logTheThing(LOG_STATION, M, "opened their [src] but nothing was there, how the fuck did this happen? It was supposed to be \a [src.spawn_type]!.")


		qdel(src)
		return


	attackby(obj/item/I, mob/user)
		// You know, like a letter opener. It opens letters.
		if (istype(I, /obj/item/kitchen/utensil/knife) && src.target_dna)
			actions.start(new /datum/action/bar/icon/mail_lockpick(src, I, 5 SECONDS), user)
			return
		..()


/datum/action/bar/icon/mail_lockpick
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 5 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/item/random_mail/the_mail
	var/obj/item/the_tool

	New(var/obj/item/random_mail/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			src.the_mail = O
		if (tool)
			src.the_tool = tool
			src.icon = src.the_tool.icon
			src.icon_state = src.the_tool.icon_state
		if (duration_i)
			src.duration = duration_i

	onUpdate()
		..()
		if (src.the_mail == null || src.the_tool == null || owner == null || BOUNDS_DIST(owner, src.the_mail) > 0 || !src.the_mail.target_dna)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && src.the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return
		if (prob(8))
			owner.visible_message(SPAN_ALERT("[owner] messes up while disconnecting \the [src.the_mail]'s DNA lock!"))
			playsound(the_mail, 'sound/items/Screwdriver2.ogg', 50, TRUE)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		owner.visible_message(SPAN_ALERT("[owner] begins disconnecting \the [src.the_mail]'s lock..."))
		playsound(src.the_mail, 'sound/items/Screwdriver2.ogg', 50, 1)

	onEnd()
		..()
		src.the_mail.target_dna = null
		src.the_mail.desc += " Or at least, at one point, it did."
		owner.visible_message(SPAN_ALERT("[owner] disconnects \the [src.the_mail]'s DNA lock!"))
		playsound(src.the_mail, 'sound/items/Screwdriver2.ogg', 50, 1)

		// I TOLD YOU IT WAS ILLEGAL!!!
		// I WARNED YOU DOG!!!
		if (ishuman(owner) && seen_by_camera(owner))
			var/perpname = owner.name
			if (owner:wear_id && owner:wear_id:registered)
				perpname = owner:wear_id:registered

			var/datum/db_record/sec_record = data_core.security.find_record("name", perpname)
			if(sec_record && sec_record["criminal"] != "*Arrest*")
				sec_record["criminal"] = "*Arrest*"
				sec_record["mi_crim"] = "Mail fraud."



// Creates a bunch of random mail for crewmembers
// Check shippingmarket.dm for the part that actually calls this.
/proc/create_random_mail(where, how_many = 1)

	// [mob] =  (name, rank, dna)
	var/list/crew = list()

	// get a list of all living, connected players
	// that are not in the afterlife bar
	// and which are on the manifest
	for (var/client/C)
		if (!isliving(C.mob) || isdead(C.mob) || !ishuman(C.mob) || inafterlife(C.mob))
			continue

		var/mob/living/carbon/human/M = C.mob
		if (!istype(M)) continue	// this shouldn't be possible given ishuman, but lol

		var/datum/db_record/manifest_record = data_core.general.find_record("id", M.datacore_id)
		if (!manifest_record) continue	// must be on the manifest to get mail, sorry

		// these are all things we will want later
		crew[M] = list(
			name = manifest_record.get_field("name"),
			job = manifest_record.get_field("rank"),
			dna = manifest_record.get_field("dna"),
			)

	// nobody here
	if (crew.len == 0)
		return list()


	// put created items here
	var/list/mail = list()
	var/list/already_picked = list()
	var/retry_count = 20	// arbitrary amount of how many times to try rerolling if we got someone already

	for (var/i in 1 to how_many)
		// get one of our living, on-manifest crew members

		// make an attempt to not mail the same person 5 times in a row.
		// key word: *attempt*
		// if we already generated mail for someone, try again, but only so many times
		// in case we ran out of people or they're just really (un?)lucky
		var/recipient = null
		var/picked = null
		do
			picked = pick(crew)
			recipient = crew[picked]
		while (already_picked[picked] && retry_count-- > 0)
		already_picked[picked] = TRUE

		var/datum/job/J = find_job_in_controller_by_string(recipient["job"])

		// make a gift for this person
		var/obj/item/random_mail/package = null
		var/package_color = "#FFFFFF"

		// the probability here can go up as the number of items for jobs increases.
		// right now the job pools are kind of small for some, so only use it sometimes.
		if (prob(50) && length(mail_types_by_job[J.type]))
			var/spawn_type = weighted_pick(mail_types_by_job[J.type])
			package = new(where)
			package.spawn_type = spawn_type
			package_color = J.linkcolor ? J.linkcolor : "#FFFFFF"
		else
			// if there are no job specific items or we aren't doing job-specific ones,
			// just throw some random crap in there, fuck it. who cares. not us
			var/spawn_type = weighted_pick(mail_types_everyone)
			package = new(where)
			package.spawn_type = spawn_type
			package.name = "mail for [recipient["name"]]"
			package_color = pick("#FFFFAA", "#FFBB88", "#FF8800", "#CCCCFF", "#FEFEFE")

		package.name = "mail for [recipient["name"]] ([recipient["job"]])"
		var/list/color_list = rgb2num(package_color)
		for(var/j in 1 to 3)
			color_list[j] = 127 + (color_list[j] / 2) + rand(-10, 10)
		package.color = rgb(color_list[1], color_list[2], color_list[3])
		package.pixel_x = rand(-2, 2)
		package.pixel_y = rand(-2, 2)

		// packages are dna-locked so you can't just swipe everyone's mail like a jerk.
		package.target_dna = recipient["dna"]
		package.desc = "A package for [recipient["name"]]. It has a DNA-based lock, so only [recipient["name"]] can open it."

		mail += package

	return mail













// =======================================================
// Various random items jobs can get via the "mail" system

var/global/mail_types_by_job = list(
	/datum/job/command/captain = list(
		/obj/item/clothing/suit/bedsheet/captain = 2,
		/obj/item/item_box/gold_star = 1,
		/obj/item/stamp/cap = 2,
		/obj/item/cigarbox/gold = 2,
		/obj/item/paper/book/from_file/captaining_101 = 1,
		/obj/item/disk/data/floppy/read_only/communications = 1,
		/obj/item/reagent_containers/food/drinks/bottle/champagne = 3,
		/obj/item/reagent_containers/food/drinks/bottle/thegoodstuff = 3,
		/obj/item/pinpointer/category/pets = 2,
		/obj/item/device/flash = 2,
		),

	/datum/job/command/head_of_personnel = list(
		/obj/item/toy/judge_gavel = 3,
		/obj/item/storage/box/id_kit = 2,
		/obj/item/stamp/hop = 3,
		/obj/item/storage/box/trackimp_kit = 1,
		/obj/item/pinpointer/category/pets = 1,
		/obj/item/reagent_containers/food/drinks/rum_spaced = 2,
		/obj/item/device/flash = 2,
		),

	/datum/job/command/head_of_security = list(
		),

	/datum/job/command/chief_engineer = list(
		/obj/item/rcd_ammo = 10,
		),

	/datum/job/command/research_director = list(
		/obj/item/disk/data/tape/master/readonly = 2,
		/obj/item/aiModule/random = 3,
		/obj/item/reagent_containers/food/snacks/beefood = 4,
		/obj/item/stamp/rd = 2,
		/obj/item/device/flash = 2,
		),

	/datum/job/command/medical_director = list(
		),


	/datum/job/security/security_officer = list(
		/obj/item/reagent_containers/food/drinks/coffee = 5,
		/obj/item/reagent_containers/food/snacks/donut/custom/random = 5,
		/obj/item/reagent_containers/food/snacks/donut/custom/robust = 1,
		/obj/item/reagent_containers/food/snacks/donut/custom/robusted = 1,
		/obj/item/device/flash = 3,
		/obj/item/clothing/head/helmet/siren = 2,
		/obj/item/handcuffs = 2,
		/obj/item/device/ticket_writer = 2,
		/obj/item/device/prisoner_scanner = 2,
		/obj/item/clothing/head/helmet/camera/security = 2,
		),

	/datum/job/security/security_officer/assistant = list(
		/obj/item/reagent_containers/food/drinks/coffee = 5,
		/obj/item/reagent_containers/food/snacks/donut/custom/random = 5,
		/obj/item/reagent_containers/food/snacks/donut/custom/robust = 1,
		/obj/item/reagent_containers/food/snacks/donut/custom/robusted = 1,
		/obj/item/device/flash = 3,
		/obj/item/clothing/head/helmet/siren = 2,
		/obj/item/device/ticket_writer = 2,
		/obj/item/device/prisoner_scanner = 2,
		/obj/item/clothing/head/helmet/camera/security = 2,
		),

	/datum/job/security/detective = list(
		/obj/item/device/detective_scanner = 4,
		/obj/item/cigpacket = 4,
		/obj/item/cigpacket/nicofree = 4,
		/obj/item/cigpacket/menthol = 4,
		/obj/item/cigpacket/propuffs = 4,
		/obj/item/cigpacket/cigarillo = 2,
		/obj/item/reagent_containers/vape = 2,
		/obj/item/reagent_containers/ecig_refill_cartridge = 3,
		/obj/item/device/light/zippo = 3,
		/obj/item/cigpacket/random = 1,
		),



	/datum/job/research/scientist = list(
		/obj/item/parts/robot_parts/arm/right/light = 5,
		/obj/item/cargotele = 5,
		/obj/item/disk/data/tape = 5,
		/obj/item/pinpointer/category/artifacts/safe = 8,
		/obj/item/pinpointer/category/artifacts = 1,
		/obj/item/device/gps = 3,
		/obj/item/clothing/head/helmet/camera = 3,
		),

	/datum/job/research/medical_doctor = list(
		/obj/item/reagent_containers/mender/brute = 5,
		/obj/item/reagent_containers/mender/burn = 5,
		/obj/item/reagent_containers/mender/both = 3,
		/obj/item/reagent_containers/mender_refill_cartridge/brute = 6,
		/obj/item/reagent_containers/mender_refill_cartridge/burn = 6,
		/obj/item/reagent_containers/mender_refill_cartridge/both = 5,
		/obj/item/item_box/medical_patches/mini_styptic = 10,
		/obj/item/item_box/medical_patches/mini_silver_sulf = 10,
		/obj/item/medicaldiagnosis/stethoscope = 5,
		/obj/item/reagent_containers/hypospray = 2,
		/obj/item/reagent_containers/food/snacks/candy/lollipop/random_medical = 5,
		/obj/item/reagent_containers/emergency_injector/epinephrine = 3,
		/obj/item/reagent_containers/emergency_injector/saline = 3,
		/obj/item/reagent_containers/emergency_injector/charcoal = 3,
		/obj/item/reagent_containers/emergency_injector/random = 2,
		),

	/datum/job/research/roboticist = list(
		/obj/item/reagent_containers/mender/brute = 5,
		/obj/item/reagent_containers/mender/burn = 5,
		/obj/item/reagent_containers/mender/both = 3,
		/obj/item/reagent_containers/mender_refill_cartridge/brute = 6,
		/obj/item/reagent_containers/mender_refill_cartridge/burn = 6,
		/obj/item/reagent_containers/mender_refill_cartridge/both = 5,
		/obj/item/robot_module = 5,
		/obj/item/parts/robot_parts/robot_frame = 4,
		/obj/item/cell/supercell/charged = 3,
		/obj/item/cable_coil = 5,
		/obj/item/sheet/steel/fullstack = 2,
		),

	/datum/job/research/geneticist = list(
		),



	/datum/job/engineering/engineer = list(
		/obj/item/chem_grenade/firefighting = 5,
		/obj/item/old_grenade/oxygen = 7,
		/obj/item/chem_grenade/metalfoam = 4,
		/obj/item/cable_coil = 6,
		/obj/item/lamp_manufacturer/organic = 5,
		/obj/item/pen/infrared = 7,
		/obj/item/sheet/steel/fullstack = 2,
		/obj/item/sheet/glass/fullstack = 2,
		/obj/item/rods/steel/fullstack = 2,
		/obj/item/tile/steel/fullstack = 2,
		),

	/datum/job/engineering/quartermaster = list(
		/obj/item/currency/spacecash/hundred = 10,
		/obj/item/currency/spacecash/fivehundred = 7,
		/obj/item/currency/spacecash/tourist = 3,
		/obj/item/stamp/qm = 5,
		/obj/item/cargotele = 3,
		/obj/item/device/appraisal = 4,
		),

	/datum/job/engineering/miner = list(
		/obj/item/device/gps = 4,
		/obj/item/satchel/mining = 3,
		/obj/item/satchel/mining/large = 2,
		/obj/item/storage/pill_bottle/antirad = 2,
		),



	/datum/job/civilian/chef = list(
		/obj/item/kitchen/utensil/knife/bread = 5,
		/obj/item/kitchen/utensil/knife/cleaver = 5,
		/obj/item/kitchen/utensil/knife/pizza_cutter = 5,
		/obj/item/reagent_containers/food/drinks/mug = 5,
		/obj/item/reagent_containers/food/drinks/tea = 5,
		/obj/item/reagent_containers/food/drinks/coffee = 5,
		/obj/item/reagent_containers/food/snacks/ingredient/egg = 5,
		/obj/item/reagent_containers/food/snacks/plant/tomato = 5,
		/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = 5,
		),

	/datum/job/civilian/bartender = list(
		/obj/item/reagent_containers/food/drinks/drinkingglass = 2,
		/obj/item/reagent_containers/food/drinks/drinkingglass/cocktail = 2,
		/obj/item/reagent_containers/food/drinks/drinkingglass/shot = 2,
		/obj/item/reagent_containers/food/drinks/drinkingglass/flute = 2,
		/obj/item/reagent_containers/food/drinks/drinkingglass/wine = 2,
		/obj/item/reagent_containers/food/drinks/drinkingglass/oldf = 2,
		/obj/item/reagent_containers/food/drinks/drinkingglass/pitcher = 2,
		/obj/item/reagent_containers/food/drinks/drinkingglass/round = 2,
		/obj/item/reagent_containers/food/drinks/drinkingglass/random_style/filled/sane = 5,
		/obj/item/reagent_containers/food/drinks/bottle/hobo_wine = 4,
		),

	/datum/job/civilian/botanist = list(
		/obj/item/reagent_containers/food/snacks/ingredient/egg/bee = 10,
		/obj/item/plant/herb/cannabis/spawnable = 3,
		/obj/item/seed/alien = 10,
		/obj/item/satchel/hydro = 7,
		/obj/item/satchel/hydro/large = 5,
		/obj/item/reagent_containers/glass/bottle/powerplant = 5,
		/obj/item/reagent_containers/glass/bottle/fruitful = 5,
		/obj/item/reagent_containers/glass/bottle/topcrop = 5,
		/obj/item/reagent_containers/glass/bottle/groboost = 5,
		/obj/item/reagent_containers/glass/bottle/mutriant = 5,
		/obj/item/reagent_containers/glass/bottle/weedkiller = 5,
		/obj/item/reagent_containers/glass/compostbag = 5,
		/obj/item/reagent_containers/glass/happyplant = 4,
		),

	/datum/job/civilian/rancher = list(
		),

	/datum/job/civilian/janitor = list(
		/obj/item/chem_grenade/cleaner = 5,
		/obj/item/sponge = 7,
		/obj/item/spraybottle/cleaner = 6,
		/obj/item/caution = 5,
		/obj/item/reagent_containers/glass/bottle/acetone/janitors = 3,
		/obj/item/mop = 5,
		),

	/datum/job/civilian/chaplain = list(
		/obj/item/bible = 2,
		/obj/item/device/light/candle = 4,
		/obj/item/device/light/candle/small = 5,
		/obj/item/device/light/candle/spooky = 2,
		/obj/item/ghostboard = 5,
		/obj/item/ghostboard/emouija = 2,
		/obj/item/card_box/tarot = 2,
		/obj/item/reagent_containers/glass/bottle/holywater = 3,
		),

	/datum/job/civilian/clown = list(
		/obj/item/reagent_containers/food/snacks/plant/banana = 15,
		/obj/item/storage/box/balloonbox = 5,
		/obj/item/canned_laughter = 15,
		/obj/item/bananapeel = 10,
		/obj/item/toy/sword = 3,
		/obj/item/rubber_hammer = 1,
		/obj/item/balloon_animal/random = 3,
		/obj/item/pen/crayon/rainbow = 2,
		/obj/item/pen/crayon/random = 1,
		/obj/item/storage/goodybag = 3,
		),

	/datum/job/civilian/staff_assistant = list(
		/obj/item/football = 7,
		/obj/item/clothing/gloves/boxing = 4,
		/obj/item/basketball = 7,
		/obj/item/device/light/zippo = 5,
		/obj/item/plant/herb/cannabis/spawnable = 5,
		/obj/item/toy/figure = 5,
		/obj/item/reagent_containers/emergency_injector/epinephrine = 3,
		)
	)


// =========================================================================
// Items given out to anyone, either when they have no job items or randomly
var/global/mail_types_everyone = list(
#ifdef XMAS
    /obj/item/spacemas_card = 25,
#endif
	/obj/item/a_gift/festive = 2,
	/obj/item/reagent_containers/food/drinks/drinkingglass/random_style/filled/sane = 3,
	/obj/item/reagent_containers/food/snacks/donkpocket_w = 4,
	/obj/item/reagent_containers/food/drinks/cola = 5,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 5,
	/obj/item/reagent_containers/food/snacks/chips = 5,
	/obj/item/reagent_containers/food/snacks/popcorn = 5,
	/obj/item/reagent_containers/food/snacks/candy/lollipop/random_medical = 4,
	/obj/item/tank/emergency_oxygen = 5,
	/obj/item/wrench = 5,
	/obj/item/crowbar = 5,
	/obj/item/screwdriver = 5,
	/obj/item/weldingtool = 5,
	/obj/item/device/radio = 5,
	/obj/item/currency/spacecash/small = 5,
	/obj/item/currency/spacecash/tourist = 2,
	/obj/item/coin = 5,
	/obj/item/pen/fancy = 2,
	/obj/item/toy/plush = 3,
	/obj/item/toy/figure = 3,
	/obj/item/toy/gooncode = 2,
	/obj/item/toy/cellphone = 3,
	/obj/item/toy/handheld/robustris = 3,
	/obj/item/toy/handheld/arcade = 3,
	/obj/item/toy/ornate_baton = 3,
	/obj/item/paint_can/rainbow = 3,
	/obj/item/device/light/glowstick = 3,
	/obj/item/clothing/glasses/vr/arcade = 2,
	/obj/item/device/light/zippo = 3,
	/obj/item/reagent_containers/emergency_injector/epinephrine = 2,
	/obj/item/clothing/head/mushroomcap/random = 2,
	)

