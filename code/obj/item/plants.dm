#define HERB_SMOKE_TRANSFER_HARDCAP 20
#define HERB_HOTBOX_MULTIPLIER 1.2

ABSTRACT_TYPE(/obj/item/plant)
/// Inedible Produce
/obj/item/plant
	name = "plant"
	var/crop_suffix = ""
	var/crop_prefix = ""
	desc = "You shouldn't be able to see this item ingame!"
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	rand_pos = 1

	New()
		..()
		make_reagents()

	proc/make_reagents()
		if (!src.reagents)
			src.create_reagents(100)

	HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
		HYPadd_harvest_reagents(src,origin_plant,passed_genes,quality_status)
		return src


ABSTRACT_TYPE(/obj/item/plant/herb)
/obj/item/plant/herb
	name = "herb base"
	health = 4
	burn_point = 330
	burn_output = 800
	burn_possible = TRUE
	item_function_flags = COLD_BURN
	crop_suffix	= " leaf"

	attackby(obj/item/W, mob/user)
		if (!src.reagents)
			src.make_reagents()

		if (istype(W, /obj/item/currency/spacecash) || istype(W, /obj/item/paper))
			boutput(user, SPAN_ALERT("You roll up [W] into a cigarette."))
			var/obj/item/clothing/mask/cigarette/custom/P = new(user.loc)
			if(istype(W, /obj/item/currency/spacecash))
				P.icon_state = "cig-[W.icon_state]"
				P.item_state = "cig-[W.icon_state]"
				P.litstate = "ciglit-[W.icon_state]"
				P.buttstate = "cigbutt-[W.icon_state]"
			P.name = build_name(W)
			P.transform = src.transform
			P.reagents.maximum_volume = src.reagents.total_volume
			src.reagents.trans_to(P, src.reagents.total_volume)
			W.force_drop(user)
			src.force_drop(user)
			qdel(W)
			qdel(src)
			user.put_in_hand_or_drop(P)
			JOB_XP(user, "Botanist", 1)

		else if (istype(W, /obj/item/bluntwrap))
			boutput(user, SPAN_ALERT("You roll [src] up in [W] and make a fat doink."))
			var/obj/item/clothing/mask/cigarette/cigarillo/doink = new(user.loc)
			var/obj/item/bluntwrap/B = W
			if(B.flavor)
				doink.flavor = B.flavor
			doink.name = "[reagent_id_to_name(doink.flavor)]-flavored [src.name] [pick("doink","'Rillo","cigarillo","brumbpo")]"
			doink.transform = src.transform
			doink.reagents.clear_reagents()
			doink.reagents.maximum_volume = (src.reagents.total_volume + 50)
			W.reagents.trans_to(doink, W.reagents.total_volume)
			src.reagents.trans_to(doink, src.reagents.total_volume)
			W.force_drop(user)
			src.force_drop(user)
			qdel(W)
			qdel(src)
			user.put_in_hand_or_drop(doink)
			JOB_XP(user, "Botanist", 2)

	combust_ended()
		// Prevent RP shuttle hotboxing
		#ifdef RP_MODE
		var/area/A = get_area(src)
		if (A)
			if (emergency_shuttle.location == SHUTTLE_LOC_STATION)
				if (istype(A, /area/shuttle/escape/station))
					return
			else if (emergency_shuttle.location == SHUTTLE_LOC_TRANSIT)
				if (istype(A, /area/shuttle/escape/transit))
					return
		#endif
		var/turf/T = get_turf(src)
		if (T.allow_unrestricted_hotbox) // traitor hotboxing
			src.reagents.maximum_volume *= HERB_HOTBOX_MULTIPLIER
			for (var/reagent_id in reagents.reagent_list)
				src.reagents.add_reagent(reagent_id, (src.reagents.get_reagent_amount(reagent_id) * (HERB_HOTBOX_MULTIPLIER - 1)))
			smoke_reaction(src.reagents, 1, get_turf(src), do_sfx = 0)
		else
			smoke_reaction(src.reagents.remove_any_to(HERB_SMOKE_TRANSFER_HARDCAP), 1, get_turf(src), do_sfx = 0)
		..()

	proc/build_name(obj/item/W)
		return "[istype(W, /obj/item/currency/spacecash) ? "[W.amount]-credit " : ""][pick("joint","doobie","spliff","roach","blunt","roll","fatty","reefer")]"

/obj/item/plant/herb/cannabis
	name = "cannabis leaf"
	desc = "Leafs for reefin'!"
	icon_state = "cannabisleaf"
	brew_result = list("THC"=20, "CBD"=20)
	contraband = 1
	w_class = W_CLASS_TINY

/obj/item/plant/herb/cannabis/spawnable
	make_reagents()
		src.create_reagents(85)
		reagents.add_reagent("THC", 60)
		reagents.add_reagent("CBD", 20)

/obj/item/plant/herb/cannabis/mega
	name = "cannabis leaf"
	crop_prefix = "rainbow "
	desc = "Is it supposed to be glowing like that...?"
	icon_state = "megaweedleaf"
	brew_result = list("THC"=20, "LSD"=20)

/obj/item/plant/herb/cannabis/mega/spawnable
	make_reagents()
		src.create_reagents(85)
		reagents.add_reagent("THC", 40)
		reagents.add_reagent("LSD", 40)

/obj/item/plant/herb/cannabis/black
	name = "cannabis leaf"
	crop_prefix = "black "
	desc = "Looks a bit dark. Oh well."
	icon_state = "blackweedleaf"
	brew_result = list("THC"=20, "cyanide"=20)

/obj/item/plant/herb/cannabis/black/spawnable
	make_reagents()
		src.create_reagents(85)
		reagents.add_reagent("THC", 40)
		reagents.add_reagent("cyanide", 40)

/obj/item/plant/herb/cannabis/white
	name = "cannabis leaf"
	crop_prefix = "white "
	desc = "It feels smooth and nice to the touch."
	icon_state = "whiteweedleaf"
	brew_result = list("THC"=20, "omnizine"=20)

/obj/item/plant/herb/cannabis/white/spawnable
	make_reagents()
		src.create_reagents(85)
		reagents.add_reagent("THC", 40)
		reagents.add_reagent("omnizine", 40)

/obj/item/plant/herb/cannabis/omega
	name = "glowing cannabis leaf"
	crop_prefix = "glowing "
	desc = "You feel dizzy looking at it. What the fuck?"
	icon_state = "Oweedleaf"
	brew_result = list("THC"=20, "LSD"=20, "suicider"=20, "space_drugs"=20, "mercury"=20, "lithium"=20, "atropine"=20, "haloperidol"=20,\
	"methamphetamine"=20, "capsaicin"=20, "psilocybin"=20, "hairgrownium"=20, "ectoplasm"=20, "bathsalts"=20, "itching"=20, "crank"=20,\
	"krokodil"=20, "catdrugs"=20, "histamine"=20)

/obj/item/plant/herb/cannabis/omega/spawnable
	make_reagents()
		src.create_reagents(800)
		reagents.add_reagent("THC", 40)
		reagents.add_reagent("LSD", 40)
		reagents.add_reagent("suicider", 40)
		reagents.add_reagent("space_drugs", 40)
		reagents.add_reagent("mercury", 40)
		reagents.add_reagent("lithium", 40)
		reagents.add_reagent("atropine", 40)
		reagents.add_reagent("haloperidol", 40)
		reagents.add_reagent("methamphetamine", 40)
		reagents.add_reagent("THC", 40)
		reagents.add_reagent("capsaicin", 40)
		reagents.add_reagent("psilocybin", 40)
		reagents.add_reagent("hairgrownium", 40)
		reagents.add_reagent("ectoplasm", 40)
		reagents.add_reagent("bathsalts", 40)
		reagents.add_reagent("itching", 40)
		reagents.add_reagent("crank", 40)
		reagents.add_reagent("krokodil", 40)
		reagents.add_reagent("catdrugs", 40)
		reagents.add_reagent("histamine", 40)

/obj/item/plant/herb/tobacco
	name = "tobacco leaf"
	desc = "A leaf from a tobacco plant. This could probably be smoked..."
	icon_state = "tobacco"
	brew_result = list("nicotine"=20)

	build_name(obj/item/W)
		return "[istype(W, /obj/item/currency/spacecash) ? "[W.amount]-credit " : ""]rolled cigarette"

/obj/item/plant/herb/tobacco/twobacco
	name = "twobacco leaf"
	desc = "A leaf from the twobacco plant. This could probably be smoked- wait, is it already smoking?"
	icon_state = "twobacco"
	brew_result = list("nicotine2"=20)

/obj/item/plant/wheat
	name = "wheat"
	desc = "Never eat shredded wheat."
	icon_state = "wheat"
	brew_result = list("beer"=20)

/obj/item/plant/wheat/durum
	name = "durum wheat"
	desc = "A harder wheat for a harder palate."
	icon_state = "wheat"
	brew_result = list("beer"=20)

/obj/item/plant/wheat/metal
	name = "steelwheat"
	desc = "Never eat iron filings."
	icon_state = "metalwheat"
	brew_result = list("ironbrew"=20)

	make_reagents()
		..()
		src.setMaterial(getMaterial("steel"))

/obj/item/plant/oat
	name = "oat"
	desc = "A bland but healthy cereal crop. Good source of fiber."
	icon_state = "oat"

/obj/item/plant/oat/salt
	name = " salted oat"
	desc = "A salty but healthy cereal crop. Just don't eat too much without water."
	icon_state = "saltedoat"

/obj/item/plant/sugar
	name = "sugar cane"
	crop_suffix	= " cane"
	desc = "Grown lovingly in our space plantations."
	icon_state = "sugarcane"
	brew_result = list("rum"=20)

/obj/item/plant/herb/grass
	name = "grass"
	desc = "Fresh free-range spacegrass."
	icon_state = "grass"

	attack_hand(mob/user)
		. = ..()
		game_stats.Increment("grass_touched")

/obj/item/plant/herb/contusine
	name = "contusine leaves"
	crop_suffix	= " leaves"
	desc = "Dry, bitter leaves known for their wound-mending properties."
	icon_state = "contusine"

/obj/item/plant/herb/contusine/shivering
	name = "contusine leaves"
	crop_suffix	= " leaves"
	desc = "Dry, bitter leaves known for their wound-mending properties. The leaves almost appear to be breathing."
	icon_state = "contusine-s"

/obj/item/plant/herb/contusine/quivering
	name = "contusine leaves"
	crop_suffix	= " leaves"
	desc = "Dry, bitter leaves known for their wound-mending properties. The squirming leaves make your skin crawl."
	icon_state = "contusine-q"

/obj/item/plant/herb/nureous
	name = "nureous leaves"
	crop_suffix	= " leaves"
	desc = "Chewy leaves often manufactured for use in radiation treatment medicine."
	icon_state = "nureous"

/obj/item/plant/herb/nureous/fuzzy
	name = "nureous leaves"
	crop_suffix = " leaves"
	desc = "Chewy leaves often manufactured for use in radiation treatment medicine. They seem strangely hairy."
	icon_state = "nureousfuzzy"

/obj/item/plant/herb/asomna
	name = "asomna bark"
	crop_suffix	= " bark"
	desc = "Often regarded as a delicacy when used for tea, Asomna also has stimulant properties."
	icon_state = "asomna"
	brew_result = list("tea"=20)

/obj/item/plant/herb/asomna/robust
	name = "asomna bark"
	crop_suffix = " bark"
	desc = "Often regarded as a delicacy when used for tea, Asomna also has stimulant properties. This particular chunk looks extra spicy."
	icon_state = "asomnarobust"
	brew_result = list("tea"=20)

/obj/item/plant/herb/commol
	name = "commol root"
	crop_suffix	= " root"
	desc = "A tough and waxy root. It is well-regarded as an ingredient in burn salve."
	icon_state = "commol"

/obj/item/plant/herb/commol/burning
	name = "commol root"
	crop_suffix	= " root"
	desc = "A tough and waxy root. It is well-regarded as an ingredient in burn salve. This variation feels warm to the touch."
	icon_state = "commolburn"

/obj/item/plant/herb/ipecacuanha
	name = "ipecacuanha root"
	crop_suffix	= " root"
	desc = "This thick root is covered in abnormal ammounts of bark. A powerful emetic can be extracted from it."
	icon_state = "ipecacuanha"

/obj/item/plant/herb/ipecacuanha/invigorating
	name = "ipecacuanha root"
	crop_suffix	= " root"
	desc = "This thick root is covered in abnormal ammounts of bark. A powerful emetic can be extracted from it. This one is strangely veinous"
	icon_state = "ipecacuanhainvigorating"

/obj/item/plant/herb/ipecacuanha/bilious
	name = "ipecacuanha root"
	crop_suffix = " root"
	desc = "This thick root is covered in abnormal ammounts of bark. A powerful emetic can be extracted from it. This one looks particularly revolting"
	icon_state = "ipecacuanhabilious"
	brew_result = list("gvomit"=20)

/obj/item/plant/herb/sassafras
	name = "sassafras root"
	crop_suffix	= " root"
	desc = "Roots from a Sassafras tree. Can be fermented into delicious sarsaparilla."
	icon_state = "sassafras"
	brew_result = list("sarsaparilla"=20)

/obj/item/plant/herb/venne
	name = "venne fibers"
	crop_suffix	= " fibers"
	desc = "Fibers from the stem of a Venne vine. Though tasting foul, it has remarkable anti-toxic properties."
	icon_state = "venne"

/obj/item/plant/herb/venne/toxic
	name = "black venne fibers"
	crop_prefix	= "black "
	desc = "It's black and greasy. Kinda gross."
	icon_state = "venneT"

/obj/item/plant/herb/venne/curative
	name = "dawning venne fibers"
	crop_prefix	= "dawning "
	desc = "It has a lovely sunrise coloration to it."
	icon_state = "venneC"

/obj/item/plant/herb/mint
	name = "mint leaves"
	crop_suffix	= " leaves"
	desc = "Aromatic leaves with a clean flavor."
	icon_state = "mint"
	brew_result = list("menthol"=20)

/obj/item/plant/herb/nettle
	name = "nettle leaves"
	crop_suffix	= " leaves"
	desc = "Stinging leaves that hurt to touch."
	icon_state = "nettle"

	attack_hand(mob/user)
		var/mob/living/carbon/human/H = user
		if (H.hand)//gets active arm - left arm is 1, right arm is 0
			if (istype(H.limbs.l_arm,/obj/item/parts/robot_parts) || istype(H.limbs.l_arm,/obj/item/parts/human_parts/arm/left/synth))
				..()
				return
		else
			if (istype(H.limbs.r_arm,/obj/item/parts/robot_parts) || istype(H.limbs.r_arm,/obj/item/parts/human_parts/arm/right/synth))
				..()
				return
		if(istype(H))
			if(H.gloves)
				..()
				return
		if(ON_COOLDOWN(src, "itch", 1 SECOND))
			return
		boutput(user, SPAN_ALERT("Your hands itch from touching [src]!"))
		random_brute_damage(user, 1)
		H.changeStatus("knockdown", 1 SECONDS)

/obj/item/plant/herb/nettle/smooth
	name = "smooth nettle leaves"
	crop_suffix	= " leaves"
	desc = "Nettle leaves that somehow don't seem to cause allergies."
	icon_state = "nettle"

/obj/item/plant/herb/catnip
	name = "nepeta cataria"
	crop_suffix	= ""
	desc = "Otherwise known as catnip or catswort.  Cat drugs."
	icon_state = "catnip"
	brew_result = list("catdrugs"=20)

/obj/item/plant/herb/poppy
	name = "poppy"
	crop_suffix	= ""
	desc = "A distinctive red flower."
	icon_state = "poppy"

/obj/item/plant/herb/poppy/spawnable
	make_reagents()
		src.create_reagents(85)
		reagents.add_reagent("morphine", 40)

/obj/item/plant/herb/tea
	name = "tea leaves"
	crop_suffix = " leaves"
	desc = "Leaves from a green tea plant, which can be used to create matcha."
	icon_state = "tealeaves"
	brew_result = list("matcha"=20)

/obj/item/plant/herb/aconite
	name = "aconite"
	crop_suffix	= ""
	desc = "A professor once asked, \"What is the difference, Mr. Potter, between monkshood and wolfsbane?\"\n  \"Aconite\", answered Hermione. And all was well."
	icon_state = "aconite"
	event_handler_flags = USE_FLUID_ENTER
	// module_research_type = /obj/item/plant/herb/cannabis
	attack_hand(var/mob/user)
		if (iswerewolf(user))
			user.changeStatus("knockdown", 4 SECONDS)
			user.TakeDamage("All", 0, 10, 0, DAMAGE_BURN)
			boutput(user, SPAN_ALERT("You try to pick up [src], but it hurts and you fall over!"))
			return
		else ..()
	//stolen from glass shard
	Crossed(atom/movable/AM as mob|obj)
		var/mob/M = AM
		if(iswerewolf(M))
			var/stun_duration
			if (!GET_COOLDOWN(M, "aconite_stun"))
				var/datum/statusEffect/stun_effect = M.changeStatus("knockdown", 4 SECONDS)
				M.TakeDamage("All", 0, 10, 0, DAMAGE_BURN)
				M.visible_message(SPAN_ALERT("The [M] steps too close to [src] and falls down!"))
				if (stun_effect)
					stun_duration = stun_effect.duration //makes cooldown last the same as stun because the actual duration of applied effect is lower
				ON_COOLDOWN(M, "aconite_stun", stun_duration)
				return
		..()
	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		//if a wolf attacks with this, which they shouldn't be able to, they'll just drop it
		if (iswerewolf(user))
			user.u_equip(src)
			user.drop_item()
			boutput(user, SPAN_ALERT("You drop the aconite, you don't think it's a good idea to hold it!"))
			return
		if (iswerewolf(target))
			target.take_toxin_damage(rand(5,10))
			user.visible_message("[user] attacks [target] with [src]! It's super effective!")
			if (prob(50))
				//Wraith does stamina damage this way, there is probably a better way, but I can't find it
				target:stamina -= 40
			return
		..()
		return
	//stolen from dagger, not much too it
	throw_impact(atom/A, datum/thrown_thing/thr)
		if(iswerewolf(A))
			if (istype(usr, /mob))
				A:lastattacker = usr
				A:lastattackertime = world.time
			A:weakened += 15

	pull(mob/user)
		if (!istype(user))
			return
		if (!iswerewolf(user))
			return ..()
		else
			boutput(user, SPAN_ALERT("You can't drag that aconite! It burns!"))
			user.take_toxin_damage(10)
			return

// FLOWERS //

ABSTRACT_TYPE(/obj/item/plant/flower)
/obj/item/plant/flower
	// PLACEHOLDER FOR FLOURISH'S PLANT PLOT STUFF

/obj/item/plant/flower/rose
	name = "rose"
	desc = "By any other name, would smell just as sweet. This one likes to be called "
	icon_state = "rose"
	var/thorned = TRUE
	var/backup_name_txt = "names/first.txt"

	proc/possible_rose_names()
		var/list/possible_names = list()
		for(var/mob/M in mobs)
			if(!M.mind)
				continue
			if(ishuman(M))
				if(iswizard(M))
					continue
				if(isnukeop(M))
					continue
				possible_names += M
		return possible_names

	New()
		..()
		var/list/possible_names = possible_rose_names()
		var/rose_name
		if(!length(possible_names))
			rose_name = pick_string_autokey(backup_name_txt)
		else
			var/mob/chosen_mob = pick(possible_names)
			rose_name = chosen_mob.real_name
		desc = desc + rose_name + "."

	attack_hand(mob/user)
		var/mob/living/carbon/human/H = user
		if(istype(H) && src.thorned)
			if (src.thorns_protected(H))
				..()
				return
			if(ON_COOLDOWN(src, "prick_hands", 1 SECOND))
				return
			src.prick(user)
		else
			..()

	proc/thorns_protected(mob/living/carbon/human/H)
		if (H.hand)//gets active arm - left arm is 1, right arm is 0
			if (istype(H.limbs.l_arm,/obj/item/parts/robot_parts) || istype(H.limbs.l_arm,/obj/item/parts/human_parts/arm/left/synth))
				return TRUE
		else
			if (istype(H.limbs.r_arm,/obj/item/parts/robot_parts) || istype(H.limbs.r_arm,/obj/item/parts/human_parts/arm/right/synth))
				return TRUE
		if(H.gloves)
			return TRUE

	proc/prick(mob/M)
		boutput(M, SPAN_ALERT("YOWCH! You prick yourself on [src]'s thorns trying to pick it up! Maybe you should've used gloves..."))
		random_brute_damage(M, 3)
		take_bleeding_damage(M, null, 3, DAMAGE_STAB)

	attackby(obj/item/W, mob/user)
		if (issnippingtool(W) && src.thorned)
			boutput(user, SPAN_NOTICE("You snip off [src]'s thorns."))
			src.thorned = FALSE
			src.desc += " Its thorns have been snipped off."
			return
		..()

	attack(mob/living/carbon/human/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (istype(target) && !(target.head?.c_flags & BLOCKCHOKE) && def_zone == "head")
			target.tri_message(user, SPAN_ALERT("[user] holds [src] to [target]'s nose, letting [him_or_her(target)] take in the fragrance."),
				SPAN_ALERT("[user] holds [src] to your nose, letting you take in the fragrance."),
				SPAN_ALERT("You hold [src] to [target]'s nose, letting [him_or_her(target)] take in the fragrance.")
			)
			return TRUE
		..()

	pickup(mob/user)
		. = ..()
		if(ishuman(user) && src.thorned && !src.thorns_protected(user))
			src.prick(user)
			SPAWN(0.1 SECONDS)
				user.drop_item(src, FALSE)

/obj/item/plant/flower/rose/poisoned
	///Trick roses don't poison on attack, only on pickup
	var/trick = FALSE
	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (!..() || is_incapacitated(target) || src.trick)
			return
		src.poison(target)

	prick(mob/user)
		..()
		src.poison(user)

	proc/poison(mob/M)
		if (!M.reagents?.has_reagent("capulettium"))
			if (M.mind?.assigned_role == "Mime")
				//since this is used for faking your own death, have a little more reagent
				M.reagents?.add_reagent("capulettium_plus", 20)
				//mess with medics a little
				M.bioHolder.AddEffect("dead_scan", timeleft = 40 SECONDS, do_stability = FALSE, magical = TRUE)
			else
				M.reagents?.add_reagent("capulettium", 13)
		//DO NOT add the SECONDS define to this, bioHolders are cursed and don't believe in ticks
		M.bioHolder?.AddEffect("mute", timeleft = 40, do_stability = FALSE, magical = TRUE)

/obj/item/plant/flower/rose/holorose
	name = "holo rose"
	desc = "A holographic display of a Rose. This one likes to be called "
	icon_state = "holorose"
	backup_name_txt = "names/ai.txt"

	possible_rose_names()
		var/list/possible_names = list()
		for(var/mob/living/silicon/M in mobs)
			possible_names += M
		return possible_names

/obj/item/plant/flower/sunflower
	name = "sunflower"
	desc = "A rather large sunflower.  Legends speak of the tasty seeds."
	icon_state = "sunflower"
	var/initial_seed_count = 0 //! how many seeds the flower started with
	var/current_seed_count = 0 //! how many seeds the flower has left

	attack_self(mob/user)
		. = ..()
		disperse_seeds(user,user)

	attackby(var/obj/item/W, mob/user)
		. = ..()
		disperse_seeds(src,user)

	afterattack(var/atom/target, var/mob/user)
		. = ..()
		disperse_seeds(target,user)

	proc/disperse_seeds(var/atom/target, var/mob/user)
		var/obj/item/reagent_containers/food/snacks/plant/seeds = locate() in src
		if(seeds)
			boutput(user, SPAN_NOTICE("You notice some [seeds] fall out of [src]!"))
			seeds.set_loc(get_turf(target))
			// that's the result if you want to keep 50% of the initial chems in the sunflower at the end.
			// This accomodates partially for chems injected in the sunflower if some seeds are already missing
			var/chem_amount = src.reagents.total_volume / (current_seed_count + initial_seed_count)
			seeds.reagents.maximum_volume = max(chem_amount, seeds.reagents.maximum_volume)
			src.reagents.trans_to(seeds, chem_amount)
			src.current_seed_count -= 1


	HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
		. = ..()
		var/seed_count = 1
		switch(quality_status)
			if("jumbo")
				seed_count += 3
			if("rotten")
				seed_count = rand(0,1)
			if("malformed")
				seed_count += rand(-1,2)
		if(seed_count < 0)
			seed_count = 0

		for(var/seed_num in 1 to seed_count)
			var/obj/item/reagent_containers/food/snacks/plant/sunflower/P = new(src)
			P.HYPsetup_DNA(passed_genes, harvested_plantpot, origin_plant, quality_status)
			P.reagents.clear_reagents() //no chem duping by getting seeds out of sunflowers. We will transfer the chems from the flower onto the seeds in disperse_seeds.
			src.initial_seed_count += 1
			src.current_seed_count += 1

/obj/item/plant/herb/hcordata
	name = "houttuynia cordata"
	desc = "Also known as fish mint or heart leaf, used in cuisine for its distinct fishy flavor."
	icon_state = "hcordata"

#undef HERB_SMOKE_TRANSFER_HARDCAP
#undef HERB_HOTBOX_MULTIPLIER
