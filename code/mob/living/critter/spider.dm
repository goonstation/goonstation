
/mob/living/critter/spider
	name = "space spider"
	real_name = "space spider"
	desc = "A big ol' spider, from space. In space. A space spider."
	icon_state = "big_spide"
	density = 1
	hand_count = 8 // spiders!!!
	add_abilities = list(/datum/targetable/critter/spider_bite,
						/datum/targetable/critter/spider_flail,
						/datum/targetable/critter/spider_drain)
	var/flailing = 0
	var/feeding = 0
	var/venom1 = "venom"  // making these modular so i don't have to rewrite this gigantic goddamn section for all the subtypes
	var/venom2 = "spiders"
	var/babyspider = 0
	var/adultpath = null
	var/bitesound = "sound/weapons/handcuffs.ogg"
	var/deathsound = "sound/impact_sounds/Generic_Snap_1.ogg"
	death_text = "%src% crumples up into a ball!"
	pet_text = list("pets","hugs","snuggles","cuddles")
	var/encase_in_web = 1 // do they encase people in ice, web, or uh, cotton candy?
	var/reacting = 1 // when they inject their venom, does it react immediately or not?

	var/health_brute = 50
	var/health_brute_vuln = 0.45
	var/health_burn = 50
	var/health_burn_vuln = 0.65
	reagent_capacity = 100

	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	var/good_grip = 1

	butcherable = 1
	skinresult = /obj/item/material_piece/cloth/spidersilk
	max_skins = 4

	blood_id = "black_goop"

	var/bite_transfer_amt = 2

	New()
		..()
		if (src.icon_state == "big_spide")
			src.icon_state = "big_spide[pick("", "-red", "-green", "-blue")]"
			src.icon_state_alive = src.icon_state
			src.icon_state_dead = "[src.icon_state]-dead"

	setup_hands()
		..()
		var/datum/handHolder/HH
		for (var/i=src.hand_count, i>0, i--)
			HH = hands[i]
			if (src.good_grip)
				HH.limb = new /datum/limb // todo: make spider hands. feet? weird spindly bug appendage??
			else
				HH.limb = new /datum/limb/small_critter
			HH.icon = 'icons/mob/hud_human.dmi'
			if (i > (src.hand_count / 2)) // if we're halfway through making our hands, start making right-facing ones
				HH.icon_state = "handr"
				HH.suffix = "-R"
			else
				HH.icon_state = "handl"
			HH.name = "leg [get_english_num(i)]"
			HH.limb_name = "spider leg"

	setup_healths()
		..()
		add_hh_flesh(-health_brute, health_brute, health_brute_vuln)
		add_hh_flesh_burn(-health_burn, health_burn, health_burn_vuln)
		add_health_holder(/datum/healthHolder/toxin)
		add_health_holder(/datum/healthHolder/brain)

	on_pet()
		if (..())
			return 1
		if (prob(33))
			playsound(get_turf(src), "sound/voice/babynoise.ogg", 50, 1)
			src.visible_message("<span class='notice'><b>[src]</b> coos!</span>",\
			"<span class='notice'>You coo!</span>")

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","hiss")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/animal/cat_hiss.ogg", 80, 1)
					return "<b>[src]</b> hisses!"
			if ("smile","coo")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/babynoise.ogg", 50, 1)
					return "<b>[src]</b> coos!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","hiss")
				return 2
			if ("smile","coo")
				return 2
		return ..()

	death(var/gibbed)
		if (!gibbed)
			src.unequip_all()
			playsound(get_turf(src), src.deathsound, 50, 0)
			src.reagents.add_reagent(venom1, 50, null)
			src.reagents.add_reagent(venom2, 50, null)
		return ..()

	proc/venom_bite(mob/M)
		if (src.reagents && istype(M) && M.reagents)
			playsound(get_turf(src), src.bitesound, 50, 1)
			if (issilicon(M))
				var/mob/living/silicon/robot/R = M
				R.compborg_take_critter_damage("[pick("l","r")]_[pick("arm","leg")]", rand(2,4))
			else
				M.TakeDamageAccountArmor("All", rand(1,3), 0, 0, DAMAGE_STAB)
			// now spiders won't poison themselves - cirr
			M.reagents.add_reagent(src.venom1, bite_transfer_amt)
			M.reagents.add_reagent(src.venom2, bite_transfer_amt)


	proc/grow_up()
		if (!src.babyspider || !ispath(src.adultpath))
			return 0
		src.unequip_all()
		src.visible_message("<span class='alert'><b>[src] grows up!</b></span>",\
		"<span class='notice'><b>You grow up!</b></span>")
		SPAWN_DBG(0)
			src.make_critter(src.adultpath)

/mob/living/critter/spider/nice
	name = "bumblespider"
	real_name = "bumblespider"
	desc = "It seems pretty friendly. D'aww."
	icon_state = "bumblespider"
	icon_state_dead = "bumblespider-dead"
	density = 0
	flags = TABLEPASS
	fits_under_table = 1
	health_brute = 30
	health_burn = 30
	good_grip = 0
	max_skins = 1
	venom1 = "toxin"
	venom2 = "black_goop"

/mob/living/critter/spider/baby
	name = "li'l space spider"
	desc = "A li'l tiny spider, from space. In space. A space spider."
	icon_state = "lil_spide"
	icon_state_dead = "lil_spide-dead"
	density = 0
	flags = TABLEPASS
	fits_under_table = 1
	health_brute = 5
	health_burn = 5
	good_grip = 0
	max_skins = 1
	venom1 = "toxin"
	venom2 = "black_goop"
	babyspider = 1
	adultpath = /mob/living/critter/spider/med
	bite_transfer_amt = 0.5

/mob/living/critter/spider/med
	name = "medium space spider"
	desc = "A medium tiny spider, from space. In space. A space spider."
	icon_state = "med_spide"
	icon_state_dead = "med_spide-dead"
	density = 0
	flags = TABLEPASS
	fits_under_table = 1
	can_grab = 0 // Causes issues with tablepass, and doesn't make too much sense
	health_brute = 25
	health_burn = 25
	good_grip = 0
	max_skins = 1
	venom1 = "toxin"
	venom2 = "black_goop"
	babyspider = 1
	adultpath = /mob/living/critter/spider
	bite_transfer_amt = 1.2

/mob/living/critter/spider/ice
	name = "ice spider"
	desc = "It seems to be adapted to a frozen climate."
	icon_state = "icespider"
	icon_state_dead = "icespider-dead"
	health_brute = 10
	health_brute_vuln = 0.5
	health_burn = 10
	health_burn_vuln = 1.5
	good_grip = 0
	venom1 = "toxin"
	venom2 = "cryostylane"
	bitesound = "sound/impact_sounds/Crystal_Hit_1.ogg"
	stepsound = "sound/impact_sounds/Glass_Shards_Hit_1.ogg"
	deathsound = "sound/impact_sounds/Crystal_Shatter_1.ogg"
	encase_in_web = 0
	max_skins = 4
	reacting = 0

/mob/living/critter/spider/ice/baby
	name = "baby ice spider"
	desc = "Dawww."
	icon_state = "babyicespider"
	icon_state_dead = "babyicespider-dead"
	density = 0
	flags = TABLEPASS
	fits_under_table = 1
	health_brute = 2
	health_burn = 2
	babyspider = 1
	max_skins = 1
	adultpath = /mob/living/critter/spider/ice

	New()
		..()
		if (prob(1))
			src.adultpath = /mob/living/critter/spider/ice/queen

/mob/living/critter/spider/ice/baby/queen // guaranteed to turn into a queen
	adultpath = /mob/living/critter/spider/ice/queen

/mob/living/critter/spider/ice/queen
	name = "queen ice spider"
	desc = "AHHHHHHH"
	icon_state = "gianticespider"
	icon_state_dead = "gianticespider-dead"
	health_brute = 100
	health_burn = 100
	venom1 = "morphine"
	venom2 = "spidereggs"
	max_skins = 8
	good_grip = 1

/mob/living/critter/spider/spacerachnid
	name = "spacerachnid"
	desc = "A rather large spider."
	icon_state = "spider"
	icon_state_dead = "spider-dead"
	health_brute = 20
	health_burn = 20
	venom1 = "venom"
	venom2 = "venom"
	death_text = "%src% is squashed!"



/* ====================================================== */
/* -------------------- Clownspiders -------------------- */
/* ====================================================== */

/mob/living/critter/spider/clown
	name = "clownspider"
	desc = "A surprisingly prolific space pest, the common clownspider mostly eats banana peels and cockroaches. Mostly."
	icon_state = "clownspider"
	icon_state_dead = "clownspider"
	custom_gib_handler = /proc/funnygibs
	hand_count = 0
	can_throw = 0
	can_grab = 0
	can_disarm = 0
	butcherable = 0
	health_brute = 5
	health_burn = 5
	babyspider = 1
	flags = TABLEPASS
	fits_under_table = 1
	venom1 = "venom"
	venom2 = "rainbow fluid"
	death_text = "%src% is squashed!"
	stepsound = "clownstep"
	adultpath = /mob/living/critter/spider/clownqueen
	add_abilities = list(/datum/targetable/critter/clownspider_kick,
						/datum/targetable/critter/spider_bite,
						/datum/targetable/critter/spider_drain)
	var/item_shoes = /obj/item/clothing/shoes/clown_shoes
	var/item_mask = /obj/item/clothing/mask/clown_hat

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if (isdead(src))
			// I can't get the ejectables thing to work so for now we're doing this.
			if (ispath(src.item_shoes))
				var/obj/item/I = new src.item_shoes(get_turf(src))
				if (I)
					var/turf/T = get_edge_target_turf(I, pick(alldirs))
					if (T)
						I.throw_at(T, 12, 3)
			if (prob(25) && ispath(src.item_mask))
				var/obj/item/I = new src.item_mask(get_turf(src))
				if (I)
					var/turf/T = get_edge_target_turf(I, pick(alldirs))
					if (T)
						I.throw_at(T, 12, 3)
			src.gib(1)

	cluwne
		name = "cluwnespider"
		desc = "Uhhh. That's not normal. Like, even for clownspiders."
		icon_state = "cluwnespider"
		icon_state_dead = "cluwnespider"
		venom2 = "painbow fluid"
		stepsound = "cluwnestep"
		adultpath = /mob/living/critter/spider/clownqueen/cluwne
		add_abilities = list(/datum/targetable/critter/clownspider_kick/cluwne,
							/datum/targetable/critter/spider_bite/cluwne,
							/datum/targetable/critter/spider_drain/cluwne)
		item_shoes = /obj/item/clothing/shoes/cursedclown_shoes
		item_mask = /obj/item/clothing/mask/cursedclown_hat

/mob/living/critter/spider/clownqueen
	name = "queen clownspider"
	desc = "You see this? This is why people hate clowns. This thing right here."
	icon_state = "clownspider_queen"
	icon_state_dead = "clownspider_queen"
	health_brute = 100
	health_burn = 100
	custom_gib_handler = /proc/funnygibs
	venom1 = "venom"
	venom2 = "rainbow fluid"
	good_grip = 1
	encase_in_web = 2
	stepsound = "clownstep"
	death_text = "%src% explodes into technicolor gore!"
	add_abilities = list(/datum/targetable/critter/clownspider_trample,
						/datum/targetable/critter/vomitegg,
						/datum/targetable/critter/spider_bite,
						/datum/targetable/critter/spider_drain)
	var/item_shoes = /obj/item/clothing/shoes/clown_shoes
	var/item_mask = /obj/item/clothing/mask/clown_hat
	var/list/babies = null
	// var/egg_path = /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/clown
	var/max_defensive_babies = 100

	cluwne
		name = "queen cluwnespider"
		desc = "...I got nothin'."
		icon_state = "cluwnespider_queen"
		icon_state_dead = "cluwnespider_queen"
		stepsound = "cluwnestep"
		add_abilities = list(/datum/targetable/critter/clownspider_trample/cluwne,
							/datum/targetable/critter/vomitegg/cluwne,
							/datum/targetable/critter/spider_bite/cluwne,
							/datum/targetable/critter/spider_drain/cluwne)
		item_shoes = /obj/item/clothing/shoes/cursedclown_shoes
		item_mask = /obj/item/clothing/mask/cursedclown_hat
		// egg_path = /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/cluwne
		max_defensive_babies = 150

	New()
		..()
		babies = list()

	disposing()
		if (islist(babies))
			babies.len = 0
		..()

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if (isdead(src))
			// I can't get the ejectables thing to work so for now we're doing this.
			if (ispath(src.item_shoes))
				var/obj/item/I = new src.item_shoes(get_turf(src))
				if (I)
					var/turf/T = get_edge_target_turf(I, pick(alldirs))
					if (T)
						I.throw_at(T, 12, 3)
			if (prob(25) && ispath(src.item_mask))
				var/obj/item/I = new src.item_mask(get_turf(src))
				if (I)
					var/turf/T = get_edge_target_turf(I, pick(alldirs))
					if (T)
						I.throw_at(T, 12, 3)
			src.gib(1)

	was_harmed(var/atom/T as mob|obj, var/obj/item/weapon = 0, var/special = 0)
		..()

		//clownbabies can't fight clownqueens. but they can fight Cluwnequeens and vice versa
		if (istype(T, src.type))
			return
		var/defenders = 0		//this is the amount of babies that will defend you
		var/count = 0
		for (var/obj/critter/spider/clown/CS in babies)
			count++
			if (count > max_defensive_babies)
				break
			if (get_dist(src, CS) > 7)
				continue
			if (defenders >= 3)
				return
			if (prob(70))
				continue
			CS.target = T
			CS.attack = 1
			CS.task = "chasing"
			defenders++

/proc/funnygibs(atom/location, var/list/ejectables, var/bDNA, var/btype)
	SPAWN_DBG(0)
		playsound(location, "sound/musical_instruments/Bikehorn_1.ogg", 100, 1)
		playsound(location, "sound/impact_sounds/Flesh_Break_2.ogg", 50, 1)
	var/obj/decal/cleanable/blood/splatter/extra/blood = null

	var/list/dirlist = list(list(NORTH, NORTHEAST, NORTHWEST),
		list(SOUTH, SOUTHEAST, SOUTHWEST),
		list(WEST, NORTHWEST, SOUTHWEST),
		list(EAST, NORTHEAST, SOUTHEAST))

	var/list/bloods = list()

	for (var/i = 1, i <= 4, i++)
		blood = make_cleanable(/obj/decal/cleanable/blood/splatter/extra, location)
		blood.blood_DNA = bDNA
		blood.blood_type = btype
		blood.color = random_saturated_hex_color()
		blood.streak(dirlist[i], 1)
		bloods += blood

	var/extra = rand(2,4)
	for (var/i = 1, i <= extra, i++)
		blood = make_cleanable(/obj/decal/cleanable/blood/splatter/extra, location)
		blood.blood_DNA = bDNA
		blood.blood_type = btype
		blood.color = random_saturated_hex_color()
		blood.streak(alldirs, 1)
		bloods += blood

	var/turf/Q = get_turf(location)
	if (!Q)
		return
	if (ejectables && ejectables.len)
		for (var/atom/movable/I in ejectables)
			var/turf/target = null
			var/tries = 0
			while (!target)
				tries = tries + 1
				if (tries == 5)
					target = get_edge_target_turf(location, pick(alldirs))
					break
				var/tx = rand(-6, 6)
				var/ty = rand(-6, 6)
				if (tx == ty && tx == 0)
					continue
				target = locate(Q.x + tx, Q.y + ty, Q.z)

			I.set_loc(location)
			I.layer = initial(I.layer)
			SPAWN_DBG(0)
				I.throw_at(target, 12, 3)

	return bloods
