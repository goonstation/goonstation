
ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/plant)
/obj/item/reagent_containers/food/snacks/plant
	name = "fruit or vegetable"
	icon = 'icons/obj/foodNdrink/food_produce.dmi'
	var/datum/plant/planttype = null
	var/datum/plantgenes/plantgenes = null
	edible = TRUE     // Can this just be eaten as-is?
	var/already_burst = FALSE //! For bowling melons and midair katana slicing
	var/generation = 0 // For genetics tracking.
	var/validforhat = null
	var/crop_prefix = ""	// Prefix for crop name when harvested ("rainbow" melon)
	var/crop_suffix = ""	// Suffix for crop name when harvested (bamboo "shoot")
	food_effects = list("food_cold", "food_disease_resist")

	New()
		..()

		if(ispath(src.planttype))
			var/datum/plant/species = HY_get_species_from_path(src.planttype, src)
			if (species)
				src.planttype = species

		src.plantgenes = new /datum/plantgenes(src)
		src.make_reagents()

	clamp_act(mob/clamper, obj/item/clamp)
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
		if(src.reagents)
			var/turf/T = get_turf(src)
			T.fluid_react(src.reagents, src.reagents.total_volume, FALSE)
		qdel(src)
		return TRUE

	HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
		// If we've got a piece of fruit or veg that contains seeds. More often than
		// not this is fruit but some veg do this too.
		var/datum/plantgenes/new_genes = src.plantgenes

		// Copy the genes from the plant we're harvesting to the new piece of produce.
		HYPpassplantgenes(passed_genes,new_genes)
		src.generation = harvested_plantpot.generation
		src.planttype = HYPgenerateplanttypecopy(src, origin_plant)

		// Now we calculate the effect of quality on the item
		switch(quality_status)
			if("jumbo")
				src.heal_amt *= 2
				src.bites_left *= 2
			if("rotten")
				src.heal_amt = 0
			if("malformed")
				src.heal_amt += rand(-2,2)
				src.bites_left += rand(-2,2)
		if (src.bites_left < 1)
			src.bites_left = 1
		// We also want to put any reagents the plant produces into the new item.
		HYPadd_harvest_reagents(src,origin_plant,passed_genes,quality_status)
		return src


	disposing()
		src.plantgenes = null
		..()

	proc/make_reagents()
		///This proc adds the corresponding reagents to the fruit in question
		return

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (!src.edible)
			if (user == target)
				boutput(user, SPAN_ALERT("You can't just cram that in your mouth, you greedy beast!"))
				user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
			else
				user.visible_message(SPAN_ALERT("<b>[user]</b> futilely attempts to shove [src] into [target]'s mouth!"))
			return
		..()

	streak_object(var/list/directions)
		SPAWN(0)
			var/direction = pick(directions)
			for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
				sleep(0.3 SECONDS)
				if (step_to(src, get_step(src, direction), 0))
					break
			throw_impact(get_turf(src))

	HY_set_species(var/datum/plant/species)
		if (species)
			src.planttype = species
		else
			if (ispath(src.planttype))
				src.planttype = new src.planttype(src)
			else
				qdel(src)
				return

	//for sliceable botany produce, we want to transfer the plantgenes and rename the sliced produce accordingly
	process_sliced_products(var/obj/item/reagent_containers/food/slice, var/amount_to_transfer)
		..()
		slice.name = "[src.name] [src.slice_suffix]"
		if(istype(slice,/obj/item/reagent_containers/food/snacks/plant/)) //because for some reason, tomato slices are not children of plant
			var/obj/item/reagent_containers/food/snacks/plant/M = slice
			var/datum/plantgenes/DNA = src.plantgenes
			var/datum/plantgenes/PDNA = M.plantgenes
			if(DNA)
				HYPpassplantgenes(DNA,PDNA)


	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if (src.midair_slice_check(hit_atom, thr))
			//The check above checks if the user is wielding a sword and is in fact a mob
			var/mob/target = hit_atom
			var/obj/item/swords/wielded_sword = target.equipped()
			//We remove a little bit of stamina
			target.remove_stamina(wielded_sword.midair_fruit_slice_stamina_cost)
			src.already_burst = TRUE
			var/turf/T = get_turf(src)
			playsound(T, wielded_sword.hitsound, 65, 1)
			target.visible_message("[target] cuts the flying [src] with their [wielded_sword] midair!].",\
			"You cut the flying [src] with your [wielded_sword] midair!].")
			var/amount_to_transfer = round(src.reagents.total_volume / src.slice_amount)
			src.reagents?.inert = 1 // If this would be missing, the main food would begin reacting just after the first slice received its chems
			for (var/i in 1 to src.slice_amount)
				var/obj/item/reagent_containers/food/slice = new src.slice_product(T)
				src.process_sliced_products(slice, amount_to_transfer)
				var/target_point = get_turf(pick(orange(4, src)))
				slice.throw_at(target_point, rand(0, 10), rand(1, 4))
			qdel (src)
		else
			..()

	/// This proc checks if the produce that is thrown gets sliced midair, important for produce with special on-throw effects
	/// (e.g. tomatoes, bowling melons)
	/// The conditions are: 1. the produce is sliceable 2. the target is a mob
	/// 3. the target is blocking and 4. the target wields a sword that can cut produce midair
	proc/midair_slice_check(atom/hit_atom, datum/thrown_thing/thr)
		if (hit_atom && ismob(hit_atom) && src.sliceable && !src.already_burst)
			var/mob/target = hit_atom
			if (target.hasStatus("blocking") && target.equipped() && istype(target.equipped(),/obj/item/swords))
				var/obj/item/swords/wielded_sword = target.equipped()
				if (wielded_sword.midair_fruit_slice)
					return TRUE

/obj/item/reagent_containers/food/snacks/plant/bamboo
	name = "bamboo shoot"
	crop_suffix = " shoot"
	desc = "The tender and crunchy edible portion of a bamboo plant."
	icon_state = "shoot"
	food_color = "#B7B675"
	fill_amt = 0.6
	bites_left = 1

/obj/item/reagent_containers/food/snacks/plant/tomato
	name = "tomato"
	desc = "You say tomato, I toolbox you."
	icon_state = "tomato"
	planttype = /datum/plant/fruit/tomato
	bites_left = 1
	heal_amt = 1
	throwforce = 0
	force = 0
	validforhat = 1
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/ingredient/tomatoslice
	slice_amount = 3
	brew_result = list("juice_tomato"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("juice_tomato",5)

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		..()
		if (src && !src.midair_slice_check(A, thr)) //If the tomato gets sliced midair, we don't want it to splat
			src.visible_message(SPAN_ALERT("[src] splats onto the floor messily!"))
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
			var/obj/decal/cleanable/tomatosplat/splat = new
			if(src.reagents)
				src.reagents.handle_reactions()
				splat.create_reagents(src.reagents.total_volume)
				src.reagents.trans_to(splat, src.reagents.total_volume)
			splat.set_loc(T)
			splat.setup(T)
			qdel(src)

/obj/item/reagent_containers/food/snacks/plant/tomato/incendiary
	name = "tomato"
	crop_prefix = "seething "
	desc = "You say tomato, I toolbox you."

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		var/mob/living/carbon/human/H = A
		var/datum/plantgenes/DNA = src.plantgenes
		if(!T) return
		if(!T || src.disposed) return
		fireflash(T,1, checkLos = FALSE, chemfire = CHEM_FIRE_RED)
		if(istype(H))
			var/p = max(DNA?.get_effective_value("potency"), 0) //no vertical aymptote for you, buster
			H.TakeDamage("chest", 0, (max(70 * p / (p + 100) + 5, 0)*(1-H.get_heat_protection()/100)), 0)//approaches 75 as potency approaches infinity
			H.update_burning(p * 0.2)
			boutput(H,SPAN_ALERT("Hot liquid bursts out of [src], scalding you!"))
		src.visible_message(SPAN_ALERT("[src] violently bursts into flames!"))
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
		var/obj/decal/cleanable/tomatosplat/splat = new /obj/decal/cleanable/tomatosplat(T)
		if(istype(splat) && src.reagents)
			src.reagents.trans_to(splat,5) //could be deleted immediately
		qdel(src)
		//..()

/obj/item/reagent_containers/food/snacks/plant/corn
	name = "corn cob"
	crop_suffix = " cob"
	desc = "The assistants call it maize."
	icon_state = "corn"
	planttype = /datum/plant/veg/corn
	bites_left = 3
	heal_amt = 1
	throwforce = 0
	force = 0
	food_color = "#FFFF00"
	var/popping = 0
	brew_result = list("bourbon"=20)

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if ((temperature > T0C + 232) && prob(50)) //Popcorn pops at about 232 degrees celsius.
			src.pop()
		return

	make_reagents()
		..()
		src.reagents.add_reagent("cornstarch",10)

	proc/pop() //Pop that corn!!
		if (popping)
			return

		popping = 1
		src.visible_message(SPAN_ALERT("[src] pops violently!"))
		playsound(src.loc, 'sound/effects/pop.ogg', 50, 1)
		flick("cornsplode", src)
		SPAWN(1 SECOND)
			var/obj/item/reagent_containers/food/snacks/new_popcorn = new /obj/item/reagent_containers/food/snacks/popcorn(get_turf(src))
			new_popcorn.reagents.maximum_volume = max(new_popcorn.reagents.maximum_volume, src.reagents.total_volume)
			src.reagents.trans_to(new_popcorn, src.reagents.total_volume)
			qdel(src)

/obj/item/reagent_containers/food/snacks/plant/corn/clear
	name = "clear corn cob"
	desc = "Pure grain ethanol in a vaguely corn-like shape."
	icon_state = "clearcorn"
	planttype = /datum/plant/veg/corn
	bites_left = 3
	heal_amt = 3
	food_color = "#FFFFFF"
	brew_result = list("ethanol"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("ethanol",10)

/obj/item/reagent_containers/food/snacks/plant/corn/pepper
	name = "Pepper corn cob"
	desc = "Wha? Why's this called corn? It's pepper!"
	icon_state = "peppercorn"
	planttype = /datum/plant/veg/corn
	bites_left = 3
	heal_amt = 3
	food_color = "#373232"
	brew_result = list("pepper"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("pepper",10)

/obj/item/reagent_containers/food/snacks/plant/soy
	name = "soybean pod"
	crop_suffix = " pod"
	desc = "These soybeans are as close as two beans in a pod. Probably because they are <i>literally</i> beans in a pod."
	planttype = /datum/plant/veg/soy
	icon_state = "soy"
	bites_left = 3
	heal_amt = 1
	throwforce = 0
	force = 0
	food_color = "#4A7402"
	food_effects = list("food_space_farts")

	make_reagents()
		..()
		src.reagents.add_reagent("grease",10)

/obj/item/reagent_containers/food/snacks/plant/soy/soylent
	name = "soylent chartreuse"
	crop_suffix = " chartreuse"
	desc = "Contains high-energy plankton!"
	planttype = /datum/plant/veg/soy
	icon_state = "soylent"
	bites_left = 3
	heal_amt = 2
	food_color = "#BBF33D"


/obj/item/reagent_containers/food/snacks/plant/bean
	name = "bean pod"
	crop_suffix = " pod"
	desc = "Aw, beans."
	planttype = /datum/plant/veg/beans
	icon_state = "beanpod"
	bites_left = 1
	heal_amt = 1
	throwforce = 0
	force = 0
	food_color = "#CCFFCC"
	food_effects = list("food_space_farts")

	make_reagents()
		..()
		src.reagents.add_reagent("nitrogen",10)

/obj/item/reagent_containers/food/snacks/plant/peas
	name = "pea pod"
	crop_suffix = " pod"
	desc = "These peas are like peas in a pod. Yeah."
	planttype = /datum/plant/veg/peas
	icon_state = "peapod"
	bites_left = 1
	heal_amt = 1
	throwforce = 0
	force = 0
	food_color = "#77AA77"

/obj/item/reagent_containers/food/snacks/plant/peas/ammonia
	name = "golden pea pod"
	desc = "Golden peas. Like green peas, but not."
	crop_prefix = "golden "
	icon_state = "goldenpeapod"
	food_color = "#bdbd35"
	brew_result = list("ammonia"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("ammonia",10)

/obj/item/reagent_containers/food/snacks/plant/orange
	name = "orange"
	desc = "Bitter."
	icon_state = "orange"
	planttype = /datum/plant/fruit/orange
	bites_left = 3
	heal_amt = 1
	food_color = "#FF8C00"
	validforhat = 1
	food_effects = list("food_cold", "food_refreshed")
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/plant/orange/wedge
	slice_amount = 6
	slice_suffix = "wedge"
	brew_result = list("schnapps"=20)

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat))
			var/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat/forming_meat = W
			boutput(user, SPAN_NOTICE("You combine the [src] and [forming_meat] to create a Synthorange!"))
			var/obj/item/reagent_containers/food/snacks/plant/orange/synth/P = new(W.loc)
			// let's transfer the chemicals next
			P.reagents.clear_reagents()
			P.reagents.maximum_volume = max(P.reagents.maximum_volume, src.reagents.total_volume + forming_meat.reagents.total_volume)
			src.reagents.trans_to(P, src.reagents.total_volume)
			forming_meat.reagents.trans_to(P, forming_meat.reagents.total_volume)
			P.name = "synth[src.name]"
			P.transform = src.transform
			user.u_equip(W)
			user.put_in_hand_or_drop(P)
			var/datum/plantgenes/DNA = src.plantgenes
			var/datum/plantgenes/PDNA = P.plantgenes
			if(DNA)
				HYPpassplantgenes(DNA,PDNA)
			qdel(W)
			qdel(src)
		..()

	make_reagents()
		..()
		src.reagents.add_reagent("juice_orange",15)

/obj/item/reagent_containers/food/snacks/plant/orange/blood
	name = "blood orange"
	desc = "Juicy."

	make_reagents()
		..()
		src.reagents.add_reagent("bloodc",10)

/obj/item/reagent_containers/food/snacks/plant/orange/wedge
	name = "orange wedge"
	icon = 'icons/obj/foodNdrink/bartending_glassware.dmi'
	initial_volume = 6
	throwforce = 0
	w_class = W_CLASS_TINY
	bites_left = 1
	validforhat = 0
	sliceable = FALSE
	brew_result = null

	make_reagents()
		src.reagents.add_reagent("juice_orange",5)

/obj/item/reagent_containers/food/snacks/plant/orange/clockwork
	name = "clockwork orange"
	crop_prefix = "clockwork "
	desc = "You probably shouldn't eat this, unless you happen to be able to eat metal."
	icon_state = "orange-clockwork"
	validforhat = 0
	tooltip_flags = REBUILD_ALWAYS

	make_reagents()
		..()
		src.reagents.add_reagent("iron",5)

	get_desc()
		. += "[pick("The time is", "It's", "It's currently", "It reads", "It says")] [o_clock_time()]."

	heal(var/mob/living/M)
		..()
		boutput(M, SPAN_ALERT("Eating that was a terrible idea!"))
		random_brute_damage(M, rand(5, 15))

/obj/item/reagent_containers/food/snacks/plant/orange/synth
	name = "synthorange"
	crop_prefix = "synth"
	desc = "Bitter. Moreso."
	icon_state = "orange"
	bites_left = 3
	heal_amt = 2

	make_reagents()
		..()
		src.reagents.add_reagent("synthflesh",10)

/obj/item/reagent_containers/food/snacks/plant/grape
	name = "grapes"
	desc = "Not the green ones."
	icon_state = "grapes"
	planttype = /datum/plant/fruit/grape
	bites_left = 5
	heal_amt = 1
	food_color = "#FF00FF"
	brew_result = list("wine"=20)
	validforhat = 1
	food_effects = list("food_cold", "food_refreshed")

/obj/item/reagent_containers/food/snacks/plant/grape/green
	name = "grapes"
	desc = "Not the purple ones."
	icon_state = "Ggrapes"
	bites_left = 5
	heal_amt = 2
	food_color = "#AAFFAA"
	brew_result = list("white_wine"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("insulin",5)

/obj/item/reagent_containers/food/snacks/plant/grapefruit
	name = "grapefruit"
	desc = "A delicious grape fruit."
	icon_state = "grapefruit"
	planttype = /datum/plant/fruit/grape
	bites_left = 3
	heal_amt = 1
	food_color = "#FF9F87"
	brew_result = list("schnapps"=20)
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/plant/grapefruit/wedge
	slice_amount = 6
	slice_suffix = "wedge"

	make_reagents()
		..()
		src.reagents.add_reagent("juice_grapefruit",10)

/obj/item/reagent_containers/food/snacks/plant/grapefruit/wedge
	name = "grapefruit wedge"
	icon = 'icons/obj/foodNdrink/bartending_glassware.dmi'
	throwforce = 0
	w_class = W_CLASS_TINY
	bites_left = 1
	initial_volume = 6
	sliceable = FALSE
	brew_result = null

	make_reagents()
		src.reagents.add_reagent("juice_grapefruit",5)

/obj/item/reagent_containers/food/snacks/plant/cherry
	name = "cherry"
	desc = "Sweet and tart."
	icon_state = "cherry"
	planttype = /datum/plant/fruit/cherry
	bites_left = 5
	heal_amt = 1
	food_color = "#CC0000"
	brew_result = list("wine"=20)
	validforhat = 1
	food_effects = list("food_cold", "food_refreshed")

	make_reagents()
		..()
		src.reagents.add_reagent("juice_grapefruit",10)

/obj/item/reagent_containers/food/snacks/plant/melon
	name = "melon"
	desc = "You should cut it into slices first!"
	icon_state = "melon"
	planttype = /datum/plant/fruit/melon
	throwforce = 8
	w_class = W_CLASS_NORMAL
	edible = FALSE
	food_color = "#7FFF00"
	validforhat = 1
	fill_amt = 3
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/plant/melonslice
	slice_amount = 6
	brew_result = list("schnapps"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("juice_watermelon",20)

/obj/item/reagent_containers/food/snacks/plant/melonslice
	name = "melon slice"
	desc = "That's better!"
	icon_state = "melon-slice"
	planttype = /datum/plant/fruit/melon
	throwforce = 0
	w_class = W_CLASS_TINY
	bites_left = 1
	heal_amt = 2
	food_color = "#7FFF00"
	food_effects = list("food_cold", "food_refreshed")

	make_reagents()
		src.reagents.add_reagent("juice_watermelon",5)

/obj/item/reagent_containers/food/snacks/plant/melon/george
	name = "rainbow melon"
	crop_prefix = "rainbow "
	desc = "Back in 2033, these melons were required to have their name legally changed to protect the not-so-innocent. \
	Also for tax evasion reasons."
	// Dr. George was likely dead by 2033, if the lawsuit was from his estate regarding the use of his name by gardengear.
	// This is just a headcanon for what happened - I don't know the goon lore, ok?
	icon_state = "george-melon"
	throwforce = 0
	w_class = W_CLASS_NORMAL
	edible = FALSE
	initial_volume = 60
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/plant/melonslice/george
	slice_amount = 6

	make_reagents()
		..()
		src.reagents.add_reagent("george_melonium",20)


	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		..()
		if (src && !src.midair_slice_check(hit_atom, thr) && ismob(hit_atom) && prob(50))
			var/mob/M = hit_atom
			hit_atom.visible_message(SPAN_ALERT("[src] explodes from the sheer force of the blow!"))
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 100, 1)
			random_brute_damage(M, 10)//armour won't save you from George Melons
			if (iscarbon(M))
				M.changeStatus("unconscious", 3 SECONDS)
				M.changeStatus("stunned", 6 SECONDS)
				M.take_brain_damage(15)
			qdel(src)

/obj/item/reagent_containers/food/snacks/plant/melonslice/george
	name = "rainbow melon slice"
	desc = "A slice of a particularly special melon. \
	Previously went by a different name but then it got married or something THIS IS HOW MELON NAMES WORK OKAY"
	icon_state = "george-melon-slice"
	throwforce = 5
	w_class = W_CLASS_TINY
	bites_left = 1
	heal_amt = 2
	initial_volume = 30

	make_reagents()
		src.reagents.add_reagent("juice_watermelon",5)
		src.reagents.add_reagent("george_melonium",10)

/obj/item/reagent_containers/food/snacks/plant/melon/bowling
	name = "bowling melon"
	crop_prefix = "bowling "
	desc = "Just keep rollin' rollin'."
	icon_state = "bowling-melon"
	var/base_icon_state = "bowling-melon"
	w_class = W_CLASS_NORMAL
	force = 5
	throw_speed = 1

	proc/damage(var/mob/hitMob, damMin, damMax, var/mob/living/carbon/human/user)
		if(istype(user) && user.w_uniform && istype(user.w_uniform, /obj/item/clothing/under/gimmick/bowling))
			hitMob.do_disorient(stamina_damage = 35, knockdown = 10, stunned = 0, disorient = 50, remove_stamina_below_zero = 0)
			hitMob.TakeDamageAccountArmor("chest", rand(damMin, damMax), 0)
		else
			hitMob.do_disorient(stamina_damage = 35, knockdown = 0, stunned = 0, disorient = 30, remove_stamina_below_zero = 0)
			hitMob.TakeDamageAccountArmor("chest", rand(damMin, damMax), 0)

	throw_at(atom/target, range, speed, list/params, turf/thrown_from, mob/thrown_by, throw_type = 1,
			allow_anchored = UNANCHORED, bonus_throwforce = 0, end_throw_callback = null)
		throw_unlimited = 1
		if(target.x > src.x || (target.x == src.x && target.y > src.y))
			src.icon_state = "[base_icon_state]-spin-right"
		else
			src.icon_state = "[base_icon_state]-spin-left"
		. = ..()

	attack_hand(mob/user)
		..()
		if(user)
			src.icon_state = base_icon_state

	proc/hitWeak(var/mob/hitMob, var/mob/user)
		hitMob.visible_message(SPAN_ALERT("[hitMob] is hit by [user]'s [src]!"))
		// look these numbers are pulled out of my ass, change them if things are too broken / too weak
		var/dmg = min(12, src.plantgenes?.get_effective_value("endurance") / 7)
		src.damage(hitMob, dmg, dmg + 5, user)

	proc/hitHard(var/mob/hitMob, var/mob/user)
		hitMob.visible_message(SPAN_ALERT("[hitMob] is knocked over by [user]'s [src]!"))
		var/dmg = min(20, src.plantgenes?.get_effective_value("endurance") / 5 + 3)
		src.damage(hitMob, dmg, dmg + 5, user)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		var/mob/living/carbon/human/user = usr

		if (src.midair_slice_check(hit_atom, thr))
			..()
		else
			if(hit_atom)
				playsound(src.loc, 'sound/effects/exlow.ogg', 65, 1)
				if (ismob(hit_atom))
					var/mob/hitMob = hit_atom
					if (ishuman(hitMob))
						SPAWN( 0 )
							if (istype(user))
								if (user.w_uniform && istype(user.w_uniform, /obj/item/clothing/under/gimmick/bowling))
									src.hitHard(hitMob, user)

									if(!(hitMob == user))
										user.say(pick("Who's the kingpin now, baby?", "STRIIIKE!", "Watch it, pinhead!", "Ten points!"))
								else
									src.hitWeak(hitMob, user)
							else
								src.hitWeak(hitMob, user)
				if(already_burst)
					return
				already_burst = TRUE
				src.icon_state = "[base_icon_state]-burst"
				SPAWN(0.1 SECONDS)
					var/n_slices = rand(1, 5)
					var/amount_per_slice = 0
					if(src.reagents)
						amount_per_slice = src.reagents.total_volume / 5
						src.reagents.inert = 1
					while(n_slices)
						var/obj/item/reagent_containers/food/snacks/plant/melonslice/slice = new(get_turf(src))
						slice.name = "[src.name] slice"
						if(src.reagents)
							slice.reagents = new
							// temporary inert is here so this doesn't hit people with 5 potassium + water explosions at once
							slice.reagents.inert = 1
							src.reagents.trans_to(slice, amount_per_slice)
							slice.reagents.inert = 0
						var/datum/plantgenes/DNA = src.plantgenes
						var/datum/plantgenes/PDNA = slice.plantgenes
						if(DNA)
							HYPpassplantgenes(DNA,PDNA)
						if(istype(hit_atom, /mob/living) && prob(1))
							var/mob/living/dork = hit_atom
							slice.visible_message("\A [slice] hits [dork] right in the mouth!")
							slice.Eat(dork, dork)
						else
							var/target = get_turf(pick(orange(4, src)))
							slice.throw_at(target, rand(0, 10), rand(1, 4))
						n_slices--
					sleep(0.1 SECONDS)
					qdel(src)

/obj/item/reagent_containers/food/snacks/plant/chili
	name = "chili pepper"
	crop_suffix = " pepper"
	desc = "Caution: May or may not be red hot."
	icon_state = "chili"
	planttype = /datum/plant/fruit/chili
	w_class = W_CLASS_TINY
	bites_left = 1
	heal_amt = 2
	initial_volume = 100
	food_effects = list("food_refreshed")

	make_reagents()
		..()
		src.reagents.add_reagent("capsaicin", 10)

/obj/item/reagent_containers/food/snacks/plant/chili/chilly
	name = "chilly pepper"
	crop_prefix = "chilly "
	desc = "It's cold to the touch."
	icon_state = "chilly"
	//planttype = /datum/plant/fruit/chili
	w_class = W_CLASS_TINY
	bites_left = 1
	heal_amt = 2
	food_color = "#00CED1"
	initial_volume = 100

	make_reagents()
		..()
		src.reagents.add_reagent("cryostylane", 10)

	heal(var/mob/M)
		..()
		M:emote("shiver")
		var/datum/plantgenes/DNA = src.plantgenes
		M.bodytemperature -= DNA?.get_effective_value("potency")
		boutput(M, SPAN_ALERT("You feel cold!"))

/obj/item/reagent_containers/food/snacks/plant/chili/ghost_chili
	name = "ghostlier chili"
	crop_prefix = "ghost "
	desc = "Naga Jolokia, or Ghost Chili, is a chili pepper previously recognized by Guinness World Records as the hottest pepper in the world. \
	This one, found in space, is even hotter."
	icon_state = "ghost_chili"
	//planttype = /datum/plant/fruit/chili
	w_class = W_CLASS_TINY
	bites_left = 1
	heal_amt = 1
	food_color = "#FFFF00"
	initial_volume = 30
	brew_result = list("ghostchilijuice"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("capsaicin",25)

	heal(var/mob/M)
		..()
		M:emote("twitch")
		var/datum/plantgenes/DNA = src.plantgenes
		boutput(M, SPAN_ALERT("Fuck! Your mouth feels like it's on fire!"))
		M.bodytemperature += (DNA?.get_effective_value("potency") * 5)


/obj/item/reagent_containers/food/snacks/plant/lettuce
	name = "lettuce leaf"
	crop_suffix = " leaf"
	desc = "The go-to staple green vegetable in every good space diet, unlike Spinach."
	icon_state = "lettuce-leaf"
	planttype = /datum/plant/veg/lettuce
	w_class = W_CLASS_TINY
	bites_left = 1
	heal_amt = 1
	food_color = "#008000"
	brew_result = list("water"=20)

/obj/item/reagent_containers/food/snacks/plant/cucumber
	name = "cucumber"
	desc = "A widely-cultivated gourd, often served on sandwiches or pickled.  Not actually known for saving any kingdoms."
	icon_state = "cucumber"
	planttype = /datum/plant/fruit/cucumber
	w_class = W_CLASS_TINY
	bites_left = 2
	heal_amt = 1
	food_color = "#008000"
	food_effects = list("food_cold", "food_refreshed")
	brew_result = list("water"=20)

/obj/item/reagent_containers/food/snacks/plant/strawberry
	name = "strawberry"
	desc = "A freshly picked strawberry."
	icon_state = "strawberry"
	planttype = /datum/plant/fruit/strawberry
	bites_left = 1
	heal_amt = 1
	food_color = "#FF2244"
	validforhat = 1
	food_effects = list("food_cold", "food_refreshed")
	brew_result = list("schnapps"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("juice_strawberry", 10)

/obj/item/reagent_containers/food/snacks/plant/blueberry
	name = "blueberry"
	desc = "A freshly picked blueberry."
	icon_state = "blueberry"
	planttype = /datum/plant/fruit/blueberry
	bites_left = 1
	heal_amt = 1
	food_color = "#0000FF"
	food_effects = list("food_cold", "food_refreshed")
	brew_result = list("wine"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("juice_blueberry", 10)


/obj/item/reagent_containers/food/snacks/plant/raspberry
	name = "raspberry"
	desc = "A freshly picked raspberry."
	icon_state = "raspberry"
	planttype = /datum/plant/fruit/raspberry
	bites_left = 1
	heal_amt = 1
	food_color = "#a30325"
	food_effects = list("food_cold", "food_refreshed")
	brew_result = list("wine"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("juice_raspberry", 10)

/obj/item/reagent_containers/food/snacks/plant/raspberry/blackberry
	name = "blackberry"
	desc = "A freshly picked blackberry."
	icon_state = "blackberry"
	food_color = "#1d222f"

	make_reagents()
		..()
		src.reagents.add_reagent("juice_blackberry", 10)

/obj/item/reagent_containers/food/snacks/plant/raspberry/blueraspberry
	name = "blue raspberry"
	desc = "A freshly picked blue raspberry."
	icon_state = "blueraspberry"
	food_color = "#65d8e6"

	make_reagents()
		..()
		src.reagents.add_reagent("juice_blueraspberry", 10)

/obj/item/reagent_containers/food/snacks/plant/pear
	name = "pear"
	desc = "Whether or not you like the taste, its freshness is appearant."
	icon_state = "pear"
	planttype = /datum/plant/fruit/pear
	bites_left = 1
	heal_amt = 2
	brew_result = list("cider"=20) // pear cider is delicious, fuck you.
	food_color = "#3FB929"


/obj/item/reagent_containers/food/snacks/plant/pear/sickly
	name = "sickly pear"
	desc = "You'd definitely become terribly ill if you ate this."
	icon_state = "pear"
	//planttype = ///datum/plant/pear
	bites_left = 1
	heal_amt = 2
	brew_result = list("cider"=20,"rotting"=20) //bad
	food_color = "#3FB929"
	initial_volume = 30

	make_reagents()
		..()
		reagents.add_reagent("too much",25)


/obj/item/reagent_containers/food/snacks/plant/peach
	name = "peach"
	desc = "Feelin' peachy now, but after you eat it it's the pits."
	icon_state = "peach"
	planttype = /datum/plant/fruit/peach
	bites_left = 1
	heal_amt = 2
	food_color = "#DEBA5F"
	brew_result = list("peachschnapps"=20)

	New()
		..()
		if(prob(10))
			src.desc = pick("These peaches do not come from a can, they were not put there by a man.",
			"Millions of peaches, peaches for me. Millions of peaches, peaches for free.",
			"If I had my little way, I'd each peaches every day.", "Nature's candy in my hand, or a can, or a pie")

	make_reagents()
		..()
		src.reagents.add_reagent("juice_peach", 15)

/obj/item/reagent_containers/food/snacks/plant/apple
	name = "apple"
	desc = "Implied by folklore to repel medical staff."
	icon_state = "apple"
	planttype = /datum/plant/fruit/apple
	bites_left = 3
	heal_amt = 1
	food_color = "#40C100"
	brew_result = list("cider"=20)
	validforhat = 1
	food_effects = list("food_cold", "food_refreshed")

	heal(var/mob/M)
		..()
		M.HealDamage("All", src.heal_amt, src.heal_amt)
		M.take_toxin_damage(0 - src.heal_amt)
		M.take_oxygen_deprivation(0 - src.heal_amt)
		M.take_brain_damage(0 - src.heal_amt)

	attackby(obj/item/W, mob/user)
		// Apple on a stick
		if(istype(W,/obj/item/stick) || istype(W,/obj/item/rods))
			// Fail if already an apple on a stick
			if(istype(src,/obj/item/reagent_containers/food/snacks/plant/apple/stick))
				boutput(user, SPAN_ALERT("This apple already has a stick!"))
				return

			// Check for broken sticks
			if(istype(W,/obj/item/stick))
				var/obj/item/stick/S = W
				if(S.broken)
					boutput(user, SPAN_ALERT("You can't use a broken stick!"))
					return

			// Create apple on a stick
			if(istype(src,/obj/item/reagent_containers/food/snacks/plant/apple/poison))
				boutput(user, SPAN_NOTICE("You create an apple on a stick..."))
				new/obj/item/reagent_containers/food/snacks/plant/apple/stick/poison(get_turf(src))
			else
				boutput(user, SPAN_NOTICE("You create a delicious apple on a stick..."))
				new/obj/item/reagent_containers/food/snacks/plant/apple/stick(get_turf(src))

			// Consume a rod or stick
			if(istype(W,/obj/item/rods)) W.change_stack_amount(-1)
			if(istype(W,/obj/item/stick)) W.amount--

			// If no rods or sticks left, delete item
			if(!W.amount) qdel(W)

			// Consume apple
			qdel(src)
		else ..()

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)	//An apple a day, keeps the doctors away
		if (!src.midair_slice_check(hit_atom, thr) && ishuman(hit_atom))
			var/mob/living/carbon/human/H = hit_atom
			if(H.traitHolder.hasTrait("training_medical"))
				random_brute_damage(H, 3)
				boutput(H, SPAN_ALERT("The apple flies true and hits you square in the face, hurting your nose."))
		..()

	make_reagents()
		..()
		src.reagents.add_reagent("juice_apple", 10)

/obj/item/reagent_containers/food/snacks/plant/apple/poison
	name = "delicious-looking apple"
	crop_prefix = "delicious-looking "
	desc = "Woah. This looks absolutely delicious."
	icon_state = "poison"
	food_color = "#AC1515"
	initial_volume = 100
	brew_result = list("capulettium"=5, "cider"=15)

	make_reagents()
		..()
		reagents.add_reagent("capulettium", 10)

//Apple on a stick
/obj/item/reagent_containers/food/snacks/plant/apple/stick
	name = "apple on a stick"
	desc = "An apple on a stick."
	icon_state = "apple stick"
	validforhat = 0
	brew_result = null

	make_reagents()
		..()
		src.reagents.add_reagent("juice_apple", 10)

/obj/item/reagent_containers/food/snacks/plant/apple/stick/poison
	name = "delicious apple on a stick"
	desc = "A delicious apple on a stick."
	icon_state = "poison stick"
	brew_result = null

	make_reagents()
		..()
		reagents.add_reagent("capulettium", 10)

/obj/item/reagent_containers/food/snacks/plant/banana
	name = "unpeeled banana"
	crop_prefix = "unpeeled "
	desc = "Cavendish, of course."
	icon_state = "banana"
	item_state = "banana"
	planttype = /datum/plant/fruit/banana
	bites_left = 2
	heal_amt = 2
	food_color = "#FFFF00"
	validforhat = 1
	food_effects = list("food_cold", "food_refreshed")
	brew_result = list("juice_banana"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("juice_banana", 10)
		src.reagents.add_reagent("potassium", 3)

	heal(var/mob/M)
		if (src.icon_state == "banana")
			M.visible_message(SPAN_ALERT("[M] eats [src] without peeling it. What a dumb beast!"))
			M.take_toxin_damage(5)
			qdel(src)
		else
			..()

	attack_self(var/mob/user as mob)
		if (src.icon_state == "banana")
			if(user.bioHolder.HasEffect("clumsy") && prob(50))
				user.visible_message(SPAN_ALERT("<b>[user]</b> fumbles and pokes [himself_or_herself(user)] in the eye with [src]."))
				user.change_eye_blurry(5)
				user.changeStatus("knockdown", 3 SECONDS)
				JOB_XP(user, "Clown", 2)

				return
			boutput(user, SPAN_NOTICE("You peel [src]."))
			var/index = findtext(src.name, "unpeeled")
			src.name = splicetext(src.name, index, index + 9)
			src.icon_state = "banana-fruit"
			src.item_state = "banana-fruit"
			user.update_inhands()
			var/obj/item/bananapeel/droppeel = new /obj/item/bananapeel(user.loc)
			// Scale peel size to banana size
			// If banana 80% normal size or larger, directly copy banana's size for the peel
			if (src.transform.a >= 0.8)
				droppeel.transform = src.transform
			// Cap at 80% size so no micro peel from rotten bananas
			else
				droppeel.transform = matrix(0.8,0,0,0,0.8,0)
		else
			..()

/obj/item/reagent_containers/food/snacks/plant/carrot
	name = "carrot"
	desc = "Think of how many snowmen were mutilated to power the carrot industry."
	icon_state = "carrot"
	planttype = /datum/plant/veg/carrot
	w_class = W_CLASS_TINY
	bites_left = 3
	heal_amt = 1
	food_color = "#FF9900"
	validforhat = 1
	food_effects = list("food_cateyes", "food_refreshed")
	brew_result = list("juice_carrot"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("juice_carrot",5)
		src.reagents.add_reagent("oculine",5)

/obj/item/reagent_containers/food/snacks/plant/pumpkin
	name = "pumpkin"
	desc = "Spooky!"
	planttype = /datum/plant/fruit/pumpkin
	icon_state = "pumpkin"
	edible = FALSE
	food_color = "#CC6600"
	validforhat = 1
	brew_result = list("juice_pumpkin"= 40)
	var/obj/item/clothing/head/carving_result = /obj/item/clothing/head/pumpkin
	var/obj/item/reagent_containers/food/spoon_result = /obj/item/reagent_containers/food/drinks/bowl/pumpkin
	var/obj/item/ai_plating_kit/wire_result = /obj/item/ai_plating_kit/pumpkin

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/cable_coil))
			var/obj/item/cable_coil/coil = W
			if (coil.use(3))
				user.visible_message(SPAN_NOTICE("[user] adds wiring to the [src]!"))
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
				var/obj/item/ai_plating_kit/result = new src.wire_result(user.loc)
				user.put_in_hand_or_drop(result)
				qdel(src)
				if (coil.amount < 1)
					user.drop_item()
					qdel(coil)
			else
				boutput(user, "You need at least three lengths of cable to add to [src]!")
		if (iscuttingtool(W))
			src.carving_message(W, user)
			var/obj/item/clothing/head/result = new src.carving_result(user.loc)
			result.name = "carved [src.name]"
			result.transform = src.transform
			qdel(src)
		else if (isspooningtool(W))
			src.spoon_message(W, user)
			var/obj/item/reagent_containers/result = new src.spoon_result(user.loc)
			result.reagents.maximum_volume = max(result.reagents.maximum_volume, src.reagents.total_volume)
			src.reagents.trans_to(result, src.reagents.maximum_volume)
			result.transform = src.transform
			qdel(src)

	proc/carving_message(obj/item/knife, mob/user)
		user.visible_message("[user] carefully and creatively carves [src].", "You carefully and creatively carve [src]. Spooky!")

	proc/spoon_message(obj/item/spoon, mob/user)
		user.visible_message("[user] carefully hallows out [src] to make a nice bowl.", "You carefully hallow out [src] to make a nice bowl.")

	make_reagents()
		..()
		src.reagents.add_reagent("juice_pumpkin", 20)

/obj/item/reagent_containers/food/snacks/plant/pumpkin/summon
	New()
		flick("pumpkin_summon", src)
		..()

/obj/item/reagent_containers/food/snacks/plant/pumpkin/pumpkinlatte
	name = "spiced pumpkin"
	desc = "Autumny!"
	icon_state = "pumpkinlatte"
	planttype = /datum/plant/fruit/pumpkin
	brew_result = list("pumpkinspicelatte"= 40)
	carving_result = /obj/item/clothing/head/pumpkinlatte
	spoon_result = /obj/item/reagent_containers/food/drinks/pumpkinlatte

	carving_message(obj/item/knife, mob/user)
		user.visible_message("[user] carefully and creatively carves [src].", "You carefully and creatively carve [src]. Cute!")

	spoon_message(obj/item/spoon, mob/user)
		user.visible_message("[user] carefully opens up [src] to make a drinkable beverage.", \
		"You carefully spoon the top off of [src], mindful of the whipped cream.")

	make_reagents()
		..()
		src.reagents.add_reagent("pumpkinspicelatte",20)


/obj/item/reagent_containers/food/snacks/plant/lime
	name = "lime"
	desc = "A very sour green fruit."
	icon_state = "lime"
	planttype = /datum/plant/fruit/lime
	bites_left = 2
	heal_amt = 1
	food_color = "#008000"
	validforhat = 1
	food_effects = list("food_cold", "food_refreshed")
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/plant/lime/wedge
	slice_amount = 6
	slice_suffix = "wedge"
	brew_result = list("limeade"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("juice_lime",20)

/obj/item/reagent_containers/food/snacks/plant/lime/wedge
	name = "lime wedge"
	icon = 'icons/obj/foodNdrink/bartending_glassware.dmi'
	throwforce = 0
	w_class = W_CLASS_TINY
	bites_left = 1
	initial_volume = 6
	validforhat = 0
	sliceable = FALSE
	brew_result = null

	make_reagents()
		src.reagents.add_reagent("juice_lime", 5)

/obj/item/reagent_containers/food/snacks/plant/lemon
	name = "lemon"
	desc = "Surprisingly not a commentary on the station's workmanship."
	icon_state = "lemon"
	planttype = /datum/plant/fruit/lemon
	bites_left = 2
	heal_amt = 1
	food_color = "#FFFF00"
	validforhat = 1
	food_effects = list("food_cold", "food_refreshed")
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/plant/lemon/wedge
	slice_amount = 6
	slice_suffix = "wedge"
	brew_result = list("lemonade"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("juice_lemon", 20)

/obj/item/reagent_containers/food/snacks/plant/lemon/wedge
	name = "lemon wedge"
	icon = 'icons/obj/foodNdrink/bartending_glassware.dmi'
	throwforce = 0
	w_class = W_CLASS_TINY
	bites_left = 1
	initial_volume = 6
	validforhat = 0
	sliceable = FALSE
	brew_result = null

	make_reagents()
		src.reagents.add_reagent("juice_lemon",5)

/obj/item/reagent_containers/food/snacks/plant/slurryfruit
	name = "slurrypod"
	crop_suffix = "pod"
	desc = "An extremely poisonous, bitter fruit. The slurrypod fruit is regarded as a delicacy in some outer colony worlds."
	icon_state = "slurry"
	planttype = /datum/plant/weed/slurrypod
	bites_left = 1
	heal_amt = -1
	food_color = "#008000"
	initial_volume = 50
	brew_result = list("toxic_slurry"=20)

	make_reagents()
		src.reagents.add_reagent("toxic_slurry", 10)

/obj/item/reagent_containers/food/snacks/plant/slurryfruit/omega
	name = "omega slurrypod"
	crop_prefix = "omega "
	desc = "An extremely poisonous, bitter fruit. A strange light pulses from within."
	icon_state = "slurrymut"
	bites_left = 1
	heal_amt = -1
	initial_volume = 50

	make_reagents()
		..()
		src.reagents.add_reagent("omega_mutagen",5)

/obj/item/reagent_containers/food/snacks/plant/peanuts
	name = "peanuts"
	desc = "A pile of peanuts."
	icon_state = "peanuts"
	planttype = /datum/plant/crop/peanut
	bites_left = 1
	heal_amt = 2
	food_color = "#D2691E"
	food_effects = list("food_energized", "food_brute")

	/* drsingh todo: peanut shells and requiring roasting shelling
	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/kitchen/utensil/knife) || istype(W,/obj/item/knife/butcher))
			if (src.icon_state == "potato")
				user.visible_message("[user] peels [src].", "You peel [src].")
				src.icon_state = "potato-peeled"
				src.desc = "It needs to be cooked."
			else if (src.icon_state == "potato-peeled")
				user.visible_message("[user] chops up [src].", "You chop up [src].")
				new /obj/item/reagent_containers/food/snacks/ingredient/chips(get_turf(src))
				qdel(src)
		else ..()
	*/

/obj/item/reagent_containers/food/snacks/plant/potato
	name = "potato"
	desc = "It needs peeling first."
	icon_state = "potato"
	planttype = /datum/plant/veg/potato
	bites_left = 1
	fill_amt = 2
	heal_amt = 0
	food_color = "#F0E68C"
	brew_result = list("vodka"=20)

	attackby(obj/item/W, mob/user)
		if (iscuttingtool(W))
			if (src.icon_state == "potato")
				user.visible_message("[user] peels [src].", "You peel [src].")
				src.icon_state = "potato-peeled"
				src.desc = "It needs to be cooked."
			else if (src.icon_state == "potato-peeled")
				user.visible_message("[user] chops up [src].", "You chop up [src].")
				new /obj/item/reagent_containers/food/snacks/ingredient/chips(get_turf(src))
				qdel(src)
		var/obj/item/cable_coil/C = W
		if (istype(C)) //kubius potato battery: creation operation
			if (src.icon_state == "potato" && C.use(1))
				user.visible_message("[user] sticks some wire into [src].", "You stick some wire into [src], creating a makeshift power cell.")
				var/datum/plantgenes/DNA = src.plantgenes
				var/obj/item/cell/potato/P = new /obj/item/cell/potato(get_turf(src),DNA?.get_effective_value("potency"),DNA?.get_effective_value("endurance"))
				P.name = "[src.name] battery"
				P.transform = src.transform
				qdel (src)
			else if (src.icon_state == "potato-peeled" && C.use(1))
				user.visible_message("[user] sticks some wire into [src].", "You stick some wire into [src], creating a makeshift battery.")
				var/datum/plantgenes/DNA = src.plantgenes
				var/obj/item/ammo/power_cell/self_charging/potato/P = new /obj/item/ammo/power_cell/self_charging/potato(get_turf(src),DNA?.get_effective_value("potency"),DNA?.get_effective_value("endurance"))
				P.name = "[src.name] battery"
				P.transform = src.transform
				qdel (src)
		else ..()

	heal(var/mob/M)
		boutput(M, SPAN_ALERT("Raw potato tastes pretty nasty..."))
		..()

/obj/item/reagent_containers/food/snacks/plant/onion
	name = "onion"
	desc = "A red onion bulb. This little bundle of fun tends to irritate eyes when cut as a result of a fascinating chemical reaction."
	icon_state = "onion"
	planttype = /datum/plant/veg/onion
	food_color = "#FF9933"
	food_effects = list("food_bad_breath")
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/onion_slice
	slice_amount = 4
	slice_suffix = "ring"

	New()
		..()
		src.slice_amount = rand(3, 5)

	attackby(obj/item/W, mob/user)
		//we check for sliceability for when someone makes a child of that that should not be sliced.
		//This is the same condition for checken slice-ability. So whenever this is true, the onion should be normally sliced as well.
		if (src.sliceable && istool(W, TOOL_CUTTING | TOOL_SAWING))
			for (var/mob/living/carbon/M in range(user, 2))
				if (prob(50) && !isdead(M))
					M.emote("cry")
		..()

/obj/item/reagent_containers/food/snacks/onion_slice
	name = "onion ring"
	desc = "A sliced ring of onion. When fried, makes a side dish perfectly suited to being overlooked in favor of french fries."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "onion-ring"
	food_color = "#B923EB"
	bites_left = 1
	food_effects = list("food_bad_breath")

/obj/item/reagent_containers/food/snacks/plant/garlic
	name = "garlic"
	desc = "The natural enemy of the common Dracula (H. Sapiens Lugosi)."
	icon_state = "garlic"
	planttype = /datum/plant/veg/garlic
	food_color = "#FEFEFE"
	initial_volume = 10
	food_effects = list("food_bad_breath")

	make_reagents()
		..()
		reagents.add_reagent("water_holy", 10)

/obj/item/reagent_containers/food/snacks/plant/avocado
	name = "avocado"
	desc = "The immense berry of a Mexican tree, the avocado is rich in monounsaturated fat, fiber, and potassium. \
	It is also poisonous to birds and horses."
	icon_state = "avocado"
	planttype = /datum/plant/fruit/avocado
	food_color = "#007B1C"
	heal_amt = 2
	food_effects = list("food_refreshed","food_cold")

/obj/item/reagent_containers/food/snacks/plant/eggplant
	name = "eggplant"
	desc = "A close relative of the tomato and potato, the eggplant is notable for being large and purple."
	icon_state = "eggplant"
	planttype = /datum/plant/fruit/eggplant
	food_color = "#420042"
	initial_volume = 50

	make_reagents()
		..()
		reagents.add_reagent("nicotine", 4.58) //EGGPLANT FACT: They contain about 1.1% the nicotine of a cigarette per 100g.

/obj/item/reagent_containers/food/snacks/plant/coconut
	name = "coconut"
	desc = "You should break it open first!"
	icon_state = "coconut"
	planttype = /datum/plant/fruit/coconut
	throwforce = 9
	w_class = W_CLASS_NORMAL
	edible = FALSE
	food_color = "#4D2600"
	validforhat = 1
	event_handler_flags = USE_FLUID_ENTER
	brew_result = list("pinacolada"=20)

	make_reagents()
		..()
		reagents.add_reagent("coconut_milk",30)

	attackby(obj/item/W, mob/user)
		if (istool(W, TOOL_CUTTING | TOOL_SAWING))
			user.visible_message("[user] cracks [src] open.", "You crack open [src].")
			src.split()
		..()

	//Because coconuts create a drink item, we need to put that in seperately
	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if (hit_atom && ismob(hit_atom) && !src.already_burst)
			var/mob/target = hit_atom
			if (target.hasStatus("blocking") && target.equipped() && istype(target.equipped(),/obj/item/swords))
				var/obj/item/swords/wielded_sword = target.equipped()
				if (wielded_sword.midair_fruit_slice)
					target.remove_stamina(wielded_sword.midair_fruit_slice_stamina_cost)
					src.already_burst = TRUE
					var/turf/T = get_turf(src)
					playsound(T, wielded_sword.hitsound, 65, 1)
					target.visible_message("[target] cuts the flying [src] with their [wielded_sword] midair!].", \
					"You cut the flying [src] with your [wielded_sword] midair!].")
					src.split(TRUE)
				else
					..()
			else
				..()
		else
			..()



	proc/split(var/throws_food = FALSE)
		var/turf/T = get_turf(src)
		var/makeslices = 3
		while (makeslices > 0)
			var/obj/item/reagent_containers/food/snacks/plant/coconutmeat/P = new(T)
			P.name = "[src.name] meat"
			P.transform = src.transform
			var/datum/plantgenes/DNA = src.plantgenes
			var/datum/plantgenes/PDNA = P.plantgenes
			if(DNA)
				HYPpassplantgenes(DNA,PDNA)
			makeslices -= 1
			if (throws_food)
				var/target_point = get_turf(pick(orange(4, src)))
				P.throw_at(target_point, rand(0, 10), rand(1, 4))
		var/obj/item/reagent_containers/food/drinks/coconut/drink = new(T)
		src.reagents.trans_to(drink, src.reagents.total_volume)
		if (throws_food)
			var/target_point = get_turf(pick(orange(4, src)))
			drink.throw_at(target_point, rand(0, 10), rand(1, 4))
		qdel(src)

	proc/someone_landed_on_us(mob/living/L, datum/thrown_thing/thr)
		src.UnregisterSignal(L, COMSIG_MOVABLE_THROW_END)
		if(L.loc == src.loc)
			L.visible_message(SPAN_ALERT("[L] lands on the [src] and breaks it!"), SPAN_ALERT("You land on the [src] and break it!"))
			playsound(src, 'sound/impact_sounds/coconut_break.ogg', 70, vary=TRUE)
			var/are_there_other_nuts = FALSE
			for(var/obj/item/reagent_containers/food/snacks/plant/coconut/other_nut in src.loc)
				if(other_nut != src)
					are_there_other_nuts = TRUE
					break
			if(!are_there_other_nuts)
				L.TakeDamage("chest", brute=12)
			src.split()

	Crossed(atom/movable/AM)
		. = ..()
		if(isliving(AM))
			var/mob/living/L = AM
			if(L.throwing)
				src.RegisterSignal(L, COMSIG_MOVABLE_THROW_END, PROC_REF(someone_landed_on_us))

/obj/item/reagent_containers/food/snacks/plant/coconutmeat
	name = "coconut meat"
	desc = "Tropical meat!"
	icon_state = "coconut-meat"
	planttype = /datum/plant/fruit/coconut
	fill_amt = 0.5
	bites_left = 1
	heal_amt = 2
	food_color = "#4D2600"
	food_effects = list("food_refreshed","food_cold")

	make_reagents()
		..()
		reagents.add_reagent("coconut_milk",10)

/obj/item/reagent_containers/food/snacks/plant/pineapple
	name = "pineapple"
	desc = "It looks like some sort of spiky medieval weapon. Who decided to cut one of these open and eat it?"
	icon_state = "pineapple"
	planttype = /datum/plant/fruit/pineapple
	sliceable = TRUE
	slice_amount = 4
	slice_product = /obj/item/reagent_containers/food/snacks/plant/pineappleslice
	throwforce = 7
	w_class = W_CLASS_NORMAL
	edible = FALSE
	food_color = "#F8D016"
	validforhat = 1
	brew_result = list("pinacolada"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("juice_pineapple", 30)

/obj/item/reagent_containers/food/snacks/plant/pineappleslice
	name = "pineapple slice"
	desc = "Juicy!"
	icon = 'icons/obj/foodNdrink/bartending_glassware.dmi'
	icon_state = "pineapple"
	planttype = /datum/plant/fruit/pineapple
	bites_left = 1
	heal_amt = 2
	food_color = "#F8D016"
	food_effects = list("food_refreshed","food_cold")

	make_reagents()
		src.reagents.add_reagent("juice_pineapple", 10)

/obj/item/reagent_containers/food/snacks/plant/coffeeberry
	name = "coffee berries"
	crop_suffix = " berries"
	desc = "They are also called cherries and are found on coffee plants."
	icon_state = "coffeeberries"
	planttype = /datum/plant/crop/coffee
	bites_left = 1
	heal_amt = 3
	food_color = "#302013"
	validforhat = 1
	brew_result = list("coffee_fresh"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("coffee",10)

/obj/item/reagent_containers/food/snacks/plant/coffeeberry/mocha
	name = "mocha coffee berries"
	crop_prefix = "mocha "
	desc = "Smells faintly of rich, bitter cacao. Huh."
	icon_state = "mochaberries"

	make_reagents()
		..()
		src.reagents.add_reagent("chocolate", 10)

/obj/item/reagent_containers/food/snacks/plant/coffeeberry/latte
	name = "latte coffee berries"
	crop_prefix = "latte "
	desc = "The texture of these berries' skin is vaguely... creamy?"
	icon_state = "latteberries"

	make_reagents()
		..()
		src.reagents.add_reagent("milk", 5)

/obj/item/reagent_containers/food/snacks/plant/sunflower
	name = "sunflower seeds"
	crop_suffix = " seeds"
	desc = "A handful of delicous sunflower seeds. The snack that keeps your fingers and mouth busy.  A wonderful portable snack if not a tad messy."
	icon_state = "sunflower"
	planttype = /datum/plant/flower/sunflower
	bites_left = 3
	heal_amt = 0.2
	food_color = "#695b59"
	food_effects = list("food_refreshed")

	HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
		..()
		src.AddComponent(/datum/component/seedy, passed_genes, origin_plant, generation)
		return src

/obj/item/reagent_containers/food/snacks/plant/coffeebean
	name = "coffee beans"
	crop_suffix = " beans"
	desc = "Even though the coffee beans are seeds, they are referred to as 'beans' because of their resemblance to true beans."
	icon_state = "coffeebeans"
	planttype = /datum/plant/crop/coffee
	bites_left = 1
	heal_amt = 1
	food_color = "#302013"
	validforhat = 1

	make_reagents()
		..()
		src.reagents.add_reagent("coffee",20)

/obj/item/reagent_containers/food/snacks/plant/turmeric
	name = "turmeric root"
	crop_suffix = " root"
	desc = "An aromatic root from the turmeric plant, a relative of ginger."
	icon_state = "turmericroot"
	planttype = /datum/plant/veg/turmeric
	edible = FALSE
	validforhat = 1
	food_color = "#e0a80c"

	make_reagents()
		..()
		src.reagents.add_reagent("currypowder",10)

/obj/item/reagent_containers/food/snacks/plant/cinnamon
	name = "cinnamon stick"
	crop_suffix = " stick"
	desc = "A spice known for its sweet and aromatic flavor, often used in cooking and baking."
	icon_state = "cinnamonstick"
	planttype = /datum/plant/veg/cinnamon
	edible = TRUE //who eats cinnamon sticks whole? Are you a beaver???
	validforhat = 1
	food_color = "#C58C66"

	make_reagents()
		..()
		src.reagents.add_reagent("cinnamon", 10)

/obj/item/reagent_containers/food/snacks/plant/lashberry
	name = "lashberry"
	desc = "Not nearly as violent as the plant it came from."
	crop_suffix = " berry"
	icon_state = "lashberry"
	planttype = /datum/plant/weed/lasher
	bites_left = 4
	heal_amt = 2
	food_color = "#FF00FF"
	validforhat = 1
	brew_result = list("wine"=20)

	make_reagents()
		..()
		src.reagents.add_reagent("booster_enzyme", 5)

/obj/item/reagent_containers/food/snacks/plant/mustard
	name = "mustard seed pod"
	crop_suffix = " seed pod"
	desc = "Not as technologically advanced as the name might suggest."
	icon_state = "mustard"
	planttype = /datum/plant/fruit/mustard
	bites_left = 1
	food_color = "#FFCC00"
	food_effects = list("food_warm", "food_disease_resist")
	validforhat = 1

// Weird alien fruit

/obj/item/reagent_containers/food/snacks/plant/purplegoop
	name = "purple goop"
	desc = "Um... okay then."
	crop_prefix = "wad of "
	crop_suffix = " goop"
	icon_state = "yuckpurple"
	planttype = /datum/plant/artifact/dripper
	bites_left = 1
	heal_amt = 0
	food_color = "#9865c5"
	initial_volume = 25
	food_effects = list("food_sweaty","food_bad_breath")

	make_reagents()
		..()
		src.reagents.add_reagent("yuck", 20)

/obj/item/reagent_containers/food/snacks/plant/purplegoop/orangegoop
	name = "orange goop"
	desc = "Some sort of pulsating orange goop..."
	icon_state = "yuckorange"
	food_color = "#ff9900"
	initial_volume = 30

	make_reagents()
		..()
		src.reagents.add_reagent("oil", 10)

/obj/item/reagent_containers/food/snacks/plant/glowfruit
	name = "glowing fruit"
	desc = "This is not a handy light source."
	crop_prefix = "glowing "
	crop_suffix = " fruit"
	icon_state = "glowfruit"
	planttype = /datum/plant/artifact/litelotus
	bites_left = 4
	heal_amt = 1
	food_color = "#ccccff"
	validforhat = 1
	brew_result = list("luminol"=20)
	var/datum/light/light

	make_reagents()
		..()
		src.reagents.add_reagent("luminol", 10)

	spawnable
		make_reagents()
			..()
			src.reagents.add_reagent("omnizine", 10)

