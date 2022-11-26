
/* ============================================== */
/* -------------------- Food -------------------- */
/* ============================================== */

ABSTRACT_TYPE(/obj/item/reagent_containers/food)
/obj/item/reagent_containers/food
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	var/heal_amt = 0
	var/needfork = 0
	var/needspoon = 0
	/// Color for various food items
	var/food_color = null
	var/custom_food = 1 //Can it be used to make custom food like for pizzas
	var/festivity = 0
	var/brew_result = null // what will it make if it's brewable?
	var/unlock_medal_when_eaten = null // Add medal name here in the format of e.g. "That tasted funny".
	var/from_emagged_oven = 0 // to prevent re-rolling of food in emagged ovens
	var/doants = 1
	var/made_ants = 0
	/// for if a food is intended to be able to be sliced
	var/sliceable = FALSE
	/// what product to spawn when sliced
	var/slice_product = null
	/// how much product to spawn when sliced
	var/slice_amount = 1
	/// if the produce is inert while being sliced
	var/slice_inert = FALSE
	/// When we want to name them slices or wedges or what-have-not. Default is slice
	var/slice_suffix = "slice"
	rc_flags = 0

	proc/on_table()
		if (!isturf(src.loc)) return 0
		for (var/atom/movable/M in src.loc) //Arguably more elegant than a million locates. I don't think locate works with derived classes.
			if (istype(M, /obj/table))
				return 1
		return 0

	proc/get_food_color()
		if (food_color) // keep manually defined food colors
			return food_color
		var/icon/I = istype(src.icon, /icon) ? src.icon : icon(src.icon, src.icon_state)
		food_color = get_average_color(I)
		return food_color

	proc/heal(var/mob/living/M)
		SHOULD_CALL_PARENT(TRUE)
		var/healing = src.heal_amt

		if (quality <= 0.5)
			boutput(M, "<span class='alert'>Ugh! That tasted horrible!</span>")
			if (prob(20))
				M.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1) // path, name, strain, bypass resist
			healing = 0

		if (healing > 0)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.sims)
					H.sims.affectMotive("Hunger", healing * 6)
					H.sims.affectMotive("Bladder", -healing * 0.2)

			if (quality >= 5)
				boutput(M, "<span class='notice'>That tasted amazing!</span>")
				healing *= 2

			if (src.reagents && src.reagents.has_reagent("THC"))
				boutput(M, "<span class='notice'>Wow this tastes really good man!!</span>")
				healing *= 2

		if (!isnull(src.unlock_medal_when_eaten))
			M.unlock_medal(src.unlock_medal_when_eaten, 1)

		var/cutOff = round(M.max_health / 1.8) // 100 / 1.8 is about 55.555...6 so this should work out to be around the original value of 55 for humans and the equivalent for mobs with different max_health
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.traitHolder && H.traitHolder.hasTrait("survivalist"))
				cutOff = round(H.max_health / 10) // originally 10

		if (M.health < cutOff)
			boutput(M, "<span class='alert'>Your injuries are too severe to heal by nourishment alone!</span>")
		else
			M.HealDamage("All", healing, healing)

	//slicing food can be done here using sliceable == TRUE, slice_amount, and slice_product
	attackby(obj/item/W, mob/user)
		if (src.sliceable && istool(W, TOOL_CUTTING | TOOL_SAWING))
			var/turf/T = get_turf(src)
			user.visible_message("[user] cuts [src] into [src.slice_amount] [src.slice_suffix][s_es(src.slice_amount)].", "You cut [src] into [src.slice_amount] [src.slice_suffix][s_es(src.slice_amount)].")
			var/amount_to_transfer = round(src.reagents.total_volume / src.slice_amount)
			src.reagents?.inert = 1 // If this would be missing, the main food would begin reacting just after the first slice received its chems
			for (var/i in 1 to src.slice_amount)
				var/obj/item/reagent_containers/food/slice = new src.slice_product(T)
				src.process_sliced_products(slice, amount_to_transfer)
			qdel (src)
		else
			..()

	//This proc handles all the actions being done to the produce. use this proc to work with your slices after they were created (looking at all these slice code at plant produce...)
	proc/process_sliced_products(var/obj/item/reagent_containers/food/slice, var/amount_to_transfer)
		slice.transform = src.transform // for botany crops
		slice.reagents.clear_reagents() // dont need initial_reagents when you're inheriting reagents of another obj (no cheese duping >:[ )
		slice.reagents.maximum_volume = amount_to_transfer
		if (src.slice_inert)
			if (!slice.reagents)
				slice.reagents = new //when the created produce didn't spawned with some reagents in them, we need that
			var/Temp_Inert = slice.reagents.inert
			slice.reagents.inert = 1 //when we got produce that shouldn't explode while being cut
			src.reagents.trans_to(slice, amount_to_transfer)
			slice.reagents.inert = Temp_Inert
		else
			src.reagents.trans_to(slice, amount_to_transfer)

/* ================================================ */
/* -------------------- Snacks -------------------- */
/* ================================================ */

ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks)
/obj/item/reagent_containers/food/snacks
	name = "snack"
	desc = "yummy"
	icon = 'icons/obj/foodNdrink/food.dmi'
	icon_state = null
	heal_amt = 1
	initial_volume = 100
	festivity = 0
	rc_flags = 0
	edible = 1
	rand_pos = 1
	var/has_cigs = 0

	var/use_bite_mask = TRUE
	var/current_mask = 5
	var/list/food_effects = list()
	var/create_time = 0
	var/bites_left = 3

	var/dropped_item = null

	// Used in Special Order events
	var/meal_time_flags = 0

	New()
		..()
		if (doants)
			processing_items.Add(src)
		create_time = world.time
		if (src.amount != 1)
			stack_trace("[src] of type [src.type] is spawning with an amount other than 1. That's bad. Ping Aloe.")

	disposing()
		if(!made_ants)
			processing_items -= src
		..()

	process()
		if (world.time - create_time >= 3 MINUTES)
			create_time = world.time
			if (!src.disposed && isturf(src.loc) && !on_table())
				if (prob(50))
					made_ants = 1
					processing_items -= src
					if (!(locate(/obj/reagent_dispensers/cleanable/ants) in src.loc))
						new/obj/reagent_dispensers/cleanable/ants(src.loc)


	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/kitchen/utensil/fork) || isspooningtool(W))
			if (prob(20) && (istype(W,/obj/item/kitchen/utensil/fork/plastic) || istype(W,/obj/item/kitchen/utensil/spoon/plastic)))
				var/obj/item/kitchen/utensil/S = W
				S.break_utensil(user)
				user.visible_message("<span class='alert'>[user] stares glumly at [src].</span>")
				return

			src.Eat(user,user)
		else if (istype(W, /obj/item/tongs))
			if (istype(src.loc, /obj/item/storage))
				boutput(user, "You take [src] out of [src.loc].")
				user.put_in_hand_or_drop(src)
			else
				src.AttackSelf(user)
		else
			..()

	attack_self(mob/user as mob)
		if (!src.Eat(user, user))
			return ..()

	attack(mob/M, mob/user, def_zone)
		if(isghostcritter(user)) return
		if (!src.Eat(M, user))
			return ..()

	Eat(var/mob/M as mob, var/mob/user, var/bypass_utensils = 0)
		// in this case m is the consumer and user is the one holding it
		if (!src.edible)
			return 0
		if(!M?.bioHolder.HasEffect("mattereater") && ON_COOLDOWN(M, "eat", EAT_COOLDOWN))
			return 0
		if (!src.bites_left)
			boutput(user, "<span class='alert'>None of [src] left, oh no!</span>")
			user.u_equip(src)
			qdel(src)
			return 0
		if (iscarbon(M) || ismobcritter(M))
			if (M == user)
				//can this person eat this food?
				if(!M.can_eat(src))
					boutput(M, "<span class='alert'>You can't eat [src]!</span>")
					return 0
				if (!bypass_utensils)
					var/utensil = null

					if (src.needfork && user.find_type_in_hand(/obj/item/kitchen/utensil/fork))
						utensil = user.find_type_in_hand(/obj/item/kitchen/utensil/fork)
					else if (src.needspoon && isspooningtool(user.equipped()))
						utensil = user.equipped()

					// If it's a plastic fork we've found then test if we've broken it
					var/obj/item/kitchen/utensil/fork/plastic/plastic_fork = utensil
					if (istype(plastic_fork))
						if (prob(20))
							plastic_fork.break_utensil(M)
							utensil = null

					// If it's a plastic spoon we've found then test if we've broken it
					var/obj/item/kitchen/utensil/spoon/plastic/plastic_spoon = utensil
					if (istype(plastic_spoon))
						if (prob(20))
							plastic_spoon.break_utensil(M)
							utensil = null

					if (!utensil && (needfork || needspoon))
						if (needfork && needspoon)
							boutput(M, "<span class='alert'>You need a fork or spoon to eat [src]!</span>")
						else if (needfork)
							boutput(M, "<span class='alert'>You need a fork to eat [src]!</span>")
						else if (needspoon)
							boutput(M, "<span class='alert'>You need a spoon to eat [src]!</span>")

						M.visible_message("<span class='alert'>[user] stares glumly at [src].</span>")
						return

				//no or broken stomach
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					var/obj/item/organ/stomach/tummy = H.get_organ("stomach")
					if (!istype(tummy) || (tummy.broken || tummy.get_damage() > tummy.max_damage) || M?.bioHolder.HasEffect("rot_curse"))
						M.visible_message("<span class='notice'>[M] tries to take a bite of [src], but can't swallow!</span>",\
						"<span class='notice'>You try to take a bite of [src], but can't swallow!</span>")
						return 0
					if (!H.organHolder.head)
						M.visible_message("<span class='notice'>[M] tries to take a bite of [src], but they have no head!</span>",\
						"<span class='notice'>You try to take a bite of [src], but you have no head to chew with!</span>")
						return 0

				src.take_a_bite(M, user)
				return 1
			if (check_target_immunity(M))
				user.visible_message("<span class='alert'>[user] tries to feed [M] [src], but fails!</span>", "<span class='alert'>You try to feed [M] [src], but fail!</span>")
				return 0
			else if(!M.can_eat(src))
				user.tri_message(M, "<span class='alert'><b>[user]</b> tries to feed [M] [src], but they can't eat that!</span>",\
					"<span class='alert'>You try to feed [M] [src], but they can't eat that!</span>",\
					"<span class='alert'><b>[user]</b> tries to feed you [src], but you can't eat that!</span>")
				return 0
			else
				user.tri_message(M, "<span class='alert'><b>[user]</b> tries to feed [M] [src]!</span>",\
					"<span class='alert'>You try to feed [M] [src]!</span>",\
					"<span class='alert'><b>[user]</b> tries to feed you [src]!</span>")
				logTheThing(LOG_COMBAT, user, "attempts to feed [constructTarget(M,"combat")] [src] [log_reagents(src)] at [log_loc(user)].")

				//no or broken stomach
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					var/obj/item/organ/stomach/tummy = H.get_organ("stomach")
					if (!istype(tummy) || (tummy.broken || tummy.get_damage() > tummy.max_damage) || M?.bioHolder.HasEffect("rot_curse"))
						user.tri_message(M, "<span class='alert'><b>[user]</b>tries to feed [M] [src], but can't make [him_or_her(M)] swallow!</span>",\
							"<span class='alert'>You try to feed [M] [src], but can't make [him_or_her(M)] swallow!</span>",\
							"<span class='alert'><b>[user]</b> tries to feed you [src], but you can't swallow!!</span>")
						return 0
					if (!H.organHolder.head)
						user.tri_message(M, "<span class='alert'><b>[user]</b>tries to feed [M] [src], but [he_or_she(M)] has no head!!</span>",\
							"<span class='alert'>You try to feed [M] [src], but [he_or_she(M)] has no head!</span>",\
							"<span class='alert'><b>[user]</b> tries to feed you [src], but you don't have a head!</span>")
						return 0

				actions.start(new/datum/action/bar/icon/forcefeed(M, src, src.icon, src.icon_state), user)
				return 1

	///Called when we successfully take a bite of something (or make someone else take a bite of something)
	proc/take_a_bite(var/mob/consumer, var/mob/feeder)
		if (consumer == feeder)
			consumer.visible_message("<span class='notice'>[consumer] takes a bite of [src]!</span>",\
			  "<span class='notice'>You take a bite of [src]!</span>")
			logTheThing(LOG_CHEMISTRY, consumer, "takes a bite of [src] [log_reagents(src)] at [log_loc(consumer)].")
		else
			feeder.tri_message(consumer, "<span class='alert'><b>[feeder]</b> feeds [consumer] [src]!</span>",\
				"<span class='alert'>You feed [consumer] [src]!</span>",\
				"<span class='alert'><b>[feeder]</b> feeds you [src]!</span>")
			logTheThing(LOG_COMBAT, feeder, "feeds [constructTarget(consumer,"combat")] [src] [log_reagents(src)] at [log_loc(feeder)].")

		src.bites_left--
		consumer.nutrition += src.heal_amt * 10
		src.heal(consumer)
		playsound(consumer.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
		on_bite(consumer, feeder)
		if (src.festivity)
			modify_christmas_cheer(src.festivity)
		if (!src.bites_left)
			if (istype(src, /obj/item/reagent_containers/food/snacks/plant/) && prob(20))
				var/obj/item/reagent_containers/food/snacks/plant/P = src
				var/doseed = 1
				var/datum/plantgenes/SRCDNA = P.plantgenes
				if (!SRCDNA || HYPCheckCommut(SRCDNA, /datum/plant_gene_strain/seedless)) doseed = 0
				if (doseed)
					var/datum/plant/stored = P.planttype
					if (istype(stored) && !stored.isgrass)
						var/obj/item/seed/S
						if (stored.unique_seed)
							S = new stored.unique_seed
							S.set_loc(consumer.loc)
						else
							S = new /obj/item/seed
							S.set_loc(consumer.loc)
							S.removecolor()

						var/datum/plantgenes/DNA = P.plantgenes
						var/datum/plantgenes/PDNA = S.plantgenes
						if (!stored.hybrid && !stored.unique_seed)
							S.generic_seed_setup(stored)
						HYPpassplantgenes(DNA,PDNA)
						if (stored.hybrid)
							var/plantType = stored.type
							var/datum/plant/hybrid = new plantType(S)
							for (var/V in stored.vars)
								if (issaved(stored.vars[V]) && V != "holder")
									hybrid.vars[V] = stored.vars[V]
							S.planttype = hybrid
							S.plant_seed_color(stored.seedcolor)
						consumer.visible_message("<span class='notice'><b>[consumer]</b> spits out a seed.</span>",\
						"<span class='notice'>You spit out a seed.</span>")
			if(src.dropped_item)
				drop_item(dropped_item)
			feeder.u_equip(src)
			on_finish(consumer, feeder)
			qdel(src)

	afterattack(obj/target, mob/user, flag)
		return

	MouseDrop_T(obj/item/reagent_containers/food/snacks/O, mob/living/user)
		if (istype(O) && istype(user) && in_interact_range(O, user) && in_interact_range(src, user))
			return src.Attackby(O, user)
		return ..()

	get_desc(dist, mob/user)
		if(!user.traitHolder?.hasTrait("training_chef"))
			return

		if(src.quality >= 5)
			. += "<br><span class='notice'>This is of great quality! The gained buffs will last longer! </span>"

		if(length(food_effects) > 0)
			. += "<br><span class='notice'> This food has the following effects: "
			for(var/id in src.food_effects)
				var/datum/statusEffect/S = getStatusPrototype(id)
				if(isnull(S))
					stack_trace("the foodstuff [src] returned with a statusEffect ID that does not exist in the global prototype list! status_id : [id]") //This really shouldnt happen except for var editing, typos or other wierdness, but this is here just in case.
					continue
				var/Sdesc = S.getChefHint()
				. += "<a href='byond://?src=\ref[src];action=chefhint;name=[url_encode(S.name)];txt=[url_encode(Sdesc)]'>[S.name]</a>" + "; "
			. += "</span>"


	Topic(href, href_list)
		..()
		if(!usr)
			return
		switch(href_list["action"]) // future proofing incase someone else wants to add something to this Topic(), will remove if it noticeably slows down execution of this proc.
			if("chefhint")
				if(href_list["txt"] && href_list["name"])
					boutput(usr,"<span class='notice'><b>[href_list["name"]]:</b></span> [href_list["txt"]]")





	proc/on_bite(mob/eater, mob/feeder)

		if (isliving(eater))
			if (src.reagents && src.reagents.total_volume) //only create food chunks for reagents
				var/obj/item/reagent_containers/food/snacks/bite/B = new /obj/item/reagent_containers/food/snacks/bite
				B.set_loc(eater)
				B.reagents.maximum_volume = reagents.total_volume/(src.bites_left+1 || 1) //MBC : I copied this from the Eat proc. It doesn't really handle the reagent transfer evenly??
				src.reagents.trans_to(B,B.reagents.maximum_volume,1,0)						//i'll leave it tho because i dont wanna mess anything up
				var/mob/living/L = eater
				L.stomach_process += B

			if (length(src.food_effects) && isliving(eater) && eater.bioHolder)
				var/mob/living/L = eater
				for (var/effect in src.food_effects)
					L.add_food_bonus(effect, src)

		if (use_bite_mask && initial(bites_left))
			var/desired_mask = (bites_left / initial(bites_left)) * 5
			desired_mask = round(desired_mask)
			desired_mask = max(1,desired_mask)
			desired_mask = min(desired_mask, 5)

			if (desired_mask != current_mask)
				current_mask = desired_mask
				src.add_filter("bite", 0, alpha_mask_filter(icon=icon('icons/obj/foodNdrink/food.dmi', "eating[desired_mask]")))

		eat_twitch(eater)
		eater.on_eat(src, feeder)

	proc/on_finish(mob/eater)
		return

	proc/drop_item(var/path)
		var/obj/drop = new path
		if(istype(drop))
			drop.pixel_x = src.pixel_x
			drop.pixel_y = src.pixel_y
			var/obj/item/I = drop
			if(istype(I))
				var/mob/M = src.loc
				if(istype(M))
					var/item_slot = M.get_slot_from_item(src)
					if(item_slot)
						M.u_equip(src)
						src.set_loc(null)
						if(ishuman(M))
							var/mob/living/carbon/human/H = M
							H.force_equip(I,item_slot) // mobs don't have force_equip
							return
			drop.set_loc(get_turf(src.loc))
/obj/item/reagent_containers/food/snacks/bite
	name = "half-digested food chunk"
	desc = "This is a chunk of partially digested food."
	icon = 'icons/obj/foodNdrink/food.dmi'
	icon_state = "foodchunk"
	heal_amt = 0
	initial_volume = 100
	festivity = 0
	rc_flags = 0
	edible = 1
	rand_pos = 1
	bites_left = 1
	var/did_react = 0

	proc/process_stomach(mob/living/owner, var/process_rate = 5)
		if (owner && src.reagents)
			if (!src.did_react)
				src.reagents.reaction(owner, INGEST, src.reagents.total_volume)
				src.did_react = 1

			src.reagents.trans_to(owner, process_rate, HAS_ATOM_PROPERTY(owner, PROP_MOB_DIGESTION_EFFICIENCY) ? GET_ATOM_PROPERTY(owner, PROP_MOB_DIGESTION_EFFICIENCY) : 1)

			if (src.reagents.total_volume <= 0)
				owner.stomach_process -= src
				qdel(src)



/* ================================================ */
/* -------------------- Drinks -------------------- */
/* ================================================ */

/obj/item/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'icons/obj/foodNdrink/drinks.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	icon_state = null
	flags = FPRINT | TABLEPASS | OPENCONTAINER | SUPPRESSATTACK | ACCEPTS_MOUSEDROP_REAGENTS
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.
	var/splash_all_contents = 1
	doants = 0
	throw_speed = 1
	var/can_recycle = 1
	var/can_chug = 1

	New()
		..()
		update_gulp_size()

	proc/update_gulp_size()
		//gulp_size = round(reagents.total_volume / 5)
		//if (gulp_size < 5) gulp_size = 5
		return

	on_reagent_change()
		..()
		update_gulp_size()
		doants = src.reagents && src.reagents.total_volume > 0

	on_spin_emote(var/mob/living/carbon/human/user as mob)
		. = ..()
		if (src.reagents && src.reagents.total_volume > 0)
			if(user.mind.assigned_role == "Bartender")
				. = ("You deftly [pick("spin", "twirl")] [src] managing to keep all the contents inside.")
				if(!ON_COOLDOWN(user, "bartender spinning xp", 180 SECONDS)) //only for real cups
					JOB_XP(user, "Bartender", 1)
			else
				user.visible_message("<span class='alert'><b>[user] spills the contents of [src] all over [him_or_her(user)]self!</b></span>")
				logTheThing(LOG_CHEMISTRY, user, "spills the contents of [src] [log_reagents(src)] all over [him_or_her(user)]self at [log_loc(user)].")
				src.reagents.reaction(get_turf(user), TOUCH)
				src.reagents.clear_reagents()

	mouse_drop(atom/over_object)
		..()
		if(!(usr == over_object)) return
		if(!istype(usr, /mob/living/carbon)) return
		var/mob/living/carbon/C = usr

		var/maybe_too_clumsy = FALSE
		var/maybe_too_tipsy = FALSE
		var/too_drunk = FALSE
		if(!can_chug)
			boutput(C, "<span class='alert'>You can't seem to chug from [src.name]! How odd.</span>")
			return
		if(C.bioHolder)
			maybe_too_clumsy = C.bioHolder.HasEffect("clumsy") && prob(50)
		if(C.reagents.reagent_list["ethanol"])
			maybe_too_tipsy = (C.reagents.reagent_list["ethanol"].volume >= 50) && prob(50)
			too_drunk = C.reagents.reagent_list["ethanol"].volume >= 150

		if(!in_interact_range(src, C))
			boutput(usr, "<span class='alert'>That's too far!</span>")
			return

		if(C.restrained()) // Can't chug if your arms are not available
			if(prob(1)) // Actually you can if you're really lucky
				C.visible_message("<span class='alert'>Holy shit! [C] grabs the [src] with their teeth and prepares to chug!</span>")
			else
				boutput(C, "<span class='alert'>You can't grab the [src] with your arms to chug it.</span>")
				return

		if(too_drunk || maybe_too_tipsy || maybe_too_clumsy)
			C.visible_message("[C.name] was too energetic, and threw the [src.name] backwards instead of chugging it!")
			src.set_loc(get_turf(C))
			C.u_equip(src)
			var/target = get_steps(C, turn(C.dir, 180), 7) //7 tiles seems appropriate.
			src.throw_at(target, 7, 1)
			if (!C.hasStatus("weakened"))
				//Make them fall over, they lost their balance.
				C.changeStatus("weakened", 2 SECONDS)
			return

		actions.start(new /datum/action/bar/icon/chug(C, src), C)

	//Wow, we copy+pasted the heck out of this... (Source is chemistry-tools dm)
	attack_self(mob/user as mob)
		if (src.splash_all_contents)
			boutput(user, "<span class='notice'>You tighten your grip on the [src].</span>")
			src.splash_all_contents = 0
		else
			boutput(user, "<span class='notice'>You loosen your grip on the [src].</span>")
			src.splash_all_contents = 1
		return

	attack(mob/M, mob/user, def_zone)
		// in this case m is the consumer and user is the one holding it
		if (istype(src, /obj/item/reagent_containers/food/drinks/bottle/soda))
			var/obj/item/reagent_containers/food/drinks/bottle/W = src
			if (W.broken)
				return
		if (!src.reagents || !src.reagents.total_volume)
			boutput(user, "<span class='alert'>Nothing left in [src], oh no!</span>")
			return 0

		if (M == user)
			src.take_a_drink(M, user)
			return 1
		else
			user.visible_message("<span class='alert'>[user] attempts to force [M] to drink from [src].</span>")
			logTheThing(LOG_COMBAT, user, "attempts to force [constructTarget(M,"combat")] to drink from [src] [log_reagents(src)] at [log_loc(user)].")
			if (check_target_immunity(M))
				user.visible_message("<span class='alert'>[user] attempts to force [M] to drink from [src], but fails!.</span>", "<span class='alert'>You try to force [M] to drink [src], but fail!</span>")
				return 0
			if (!src.reagents || !src.reagents.total_volume)
				boutput(user, "<span class='alert'>Nothing left in [src], oh no!</span>")
				return 0

			actions.start(new/datum/action/bar/icon/forcefeed(M, src, src.icon, src.icon_state), user)
			return 1

	///Called when we successfully take a drink of something (or make someone else take a drink of something)
	proc/take_a_drink(var/mob/consumer, var/mob/feeder)
		var/tasteMessage
		if (iscarbon(consumer) || ismobcritter(consumer))
			if (consumer.mind && consumer.mind.assigned_role == "Bartender")
				var/reag_list = ""
				for (var/current_id in reagents.reagent_list)
					var/datum/reagent/current_reagent = reagents.reagent_list[current_id]
					if (reagents.reagent_list.len > 1 && reagents.reagent_list[reagents.reagent_list.len] == current_id)
						reag_list += " and [current_reagent.name]"
						continue
					reag_list += ", [current_reagent.name]"
				reag_list = copytext(reag_list, 3)
				tasteMessage = "<span class='notice'>Tastes like there might be some [reag_list] in this.</span>"
			else
				var/tastes = src.reagents.get_prevalent_tastes(3)
				switch (length(tastes))
					if (0)
						tasteMessage = "<span class='notice'>Tastes pretty bland.</span>"
					if (1)
						tasteMessage = "<span class='notice'>Tastes kind of [tastes[1]].</span>"
					if (2)
						tasteMessage = "<span class='notice'>Tastes kind of [tastes[1]] and [tastes[2]].</span>"
					else
						tasteMessage = "<span class='notice'>Tastes kind of [tastes[1]], [tastes[2]], and a little bit [tastes[3]].</span>"
		if (consumer == feeder)
			consumer.visible_message("<span class='notice'>[consumer] takes a sip from [src].</span>","<span class='notice'>You take a sip from [src].</span>\n[tasteMessage]", group = "drinkMessages")
		else
			consumer.visible_message("<span class='alert'>[feeder] makes [consumer] drink from the [src].</span>",
			"<span class='alert'>[feeder] makes you drink from the [src].</span>\n[tasteMessage]",
				group = "drinkMessages")
		if (src.reagents.total_volume)
			logTheThing(LOG_CHEMISTRY, feeder, "[feeder == consumer ? "takes a sip from" : "makes [constructTarget(consumer,"combat")] drink from"] [src] [log_reagents(src)] at [log_loc(feeder)].")
			src.reagents.reaction(consumer, INGEST, clamp(reagents.total_volume, CHEM_EPSILON, min(src.gulp_size, (consumer.reagents?.maximum_volume - consumer.reagents?.total_volume))))
			SPAWN(0.5 SECONDS)
				if (src?.reagents && consumer?.reagents)
					src.reagents.trans_to(consumer, min(reagents.total_volume, src.gulp_size))

		playsound(consumer.loc,'sound/items/drink.ogg', rand(10,50), 1)
		consumer.urine += 0.1
		eat_twitch(consumer)

	//bleck, i dont like this at all. (Copied from chemistry-tools reagent_containers/glass/ definition w minor adjustments)
	// still copy paste btw
	afterattack(obj/target, mob/user , flag)
		user.lastattacked = target
		if (istype(target, /obj/fluid) && !istype(target, /obj/fluid/airborne)) // fluid handling : If src is empty, fill from fluid. otherwise add to the fluid.
			var/obj/fluid/F = target
			if (!src.reagents.total_volume)
				if (!F.group || !F.group.reagents.total_volume)
					boutput(user, "<span class='alert'>[target] is empty. (this is a bug, whooops!)</span>")
					F.removed()
					return

				if (reagents.total_volume >= reagents.maximum_volume)
					boutput(user, "<span class='alert'>[src] is full.</span>")
					return
				//var/transferamt = min(src.reagents.maximum_volume - src.reagents.total_volume, F.amt)

				F.group.reagents.skip_next_update = 1
				F.group.update_amt_per_tile()
				var/amt = min(F.group.amt_per_tile, reagents.maximum_volume - reagents.total_volume)
				boutput(user, "<span class='notice'>You fill [src] with [amt] units of [target].</span>")
				F.group.drain(F, amt / F.group.amt_per_tile, src) // drain uses weird units

			else //trans_to to the FLOOR of the liquid, not the liquid itself. will call trans_to() for turf which has a little bit that handles turf application -> fluids
				var/turf/T = get_turf(F)

				logTheThing(LOG_CHEMISTRY, user, "transfers chemicals from [src] [log_reagents(src)] to [F] at [log_loc(user)].") // Added reagents (Convair880).
				var/trans = src.reagents.trans_to(T, src.splash_all_contents ? src.reagents.total_volume : src.amount_per_transfer_from_this)
				boutput(user, "<span class='notice'>You transfer [trans] units of the solution to [T].</span>")

		else if (is_reagent_dispenser(target)|| (target.is_open_container() == -1 && target.reagents) || (istype(target, /obj/fluid) && !istype(target, /obj/fluid/airborne) && !src.reagents.total_volume)) //A dispenser. Transfer FROM it TO us.
			if (!target.reagents.total_volume && target.reagents)
				boutput(user, "<span class='alert'>[target] is empty.</span>")
				return

			if (reagents.total_volume >= reagents.maximum_volume)
				boutput(user, "<span class='alert'>[src] is full.</span>")
				return

			var/transferamt = src.reagents.maximum_volume - src.reagents.total_volume
			var/trans = target.reagents.trans_to(src, transferamt)
			boutput(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

		else if (target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
			if (!reagents.total_volume)
				boutput(user, "<span class='alert'>[src] is empty.</span>")
				return

			if (target.reagents.total_volume >= target.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[target] is full.</span>")
				return

			logTheThing(LOG_CHEMISTRY, user, "transfers chemicals from [src] [log_reagents(src)] to [target] at [log_loc(user)].") // Added reagents (Convair880).
			var/trans = src.reagents.trans_to(target, 10)
			boutput(user, "<span class='notice'>You transfer [trans] units of the solution to [target].</span>")

		else if (istype(target, /obj/item/sponge)) // dump contents onto it
			if (!reagents.total_volume)
				boutput(user, "<span class='alert'>[src] is empty.</span>")
				return

			if (target.reagents.total_volume >= target.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[target] is full.</span>")
				return

			logTheThing(LOG_CHEMISTRY, user, "transfers chemicals from [src] [log_reagents(src)] to [target] at [log_loc(user)].")
			var/trans = src.reagents.trans_to(target, 10)
			boutput(user, "<span class='notice'>You dump [trans] units of the solution to [target].</span>")

		else if (reagents.total_volume)

			if (ismob(target) || (isobj(target) && target:flags & NOSPLASH))
				return
			boutput(user, "<span class='notice'>You [src.splash_all_contents ? "pour all of" : "apply [amount_per_transfer_from_this] units of"] the solution onto [target].</span>")
			logTheThing(LOG_CHEMISTRY, user, "pours [src] onto [constructTarget(target,"combat")] [log_reagents(src)] at [log_loc(user)].") // Added location (Convair880).
			reagents.physical_shock(14)

			var/splash_volume
			if (src.splash_all_contents)
				splash_volume = src.reagents.maximum_volume
			else
				splash_volume = src.amount_per_transfer_from_this

			splash_volume = min(splash_volume, src.reagents.total_volume)

			src.reagents.reaction(target, TOUCH, splash_volume)

			var/turf/T
			if (!isturf(target) && !target.density) // if we splashed on something other than a turf or a dense obj, it goes on the floor as well
				T = get_turf(target)
			else if (target.density)
				// if we splashed on a wall or a dense obj, we still want to flow out onto the floor we're pouring from (avoid pouring under windows and on walls)
				T = get_turf(user)

			if (T && !T.density) // if the user AND the target are on dense turfs or the user is on a dense turf and the target is a dense obj then just give up. otherwise pour on the floor
				src.reagents.reaction(T, TOUCH, splash_volume)

			src.reagents.remove_any(splash_volume)

/* =============================================== */
/* -------------------- Bowls -------------------- */
/* =============================================== */

/obj/item/reagent_containers/food/drinks/bowl
	name = "bowl"
	desc = "A bowl is a common open-top container used in many cultures to serve food, and is also used for drinking and storing other items."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "bowl"
	item_state = "zippo"
	initial_volume = 50

	var/image/fluid_image = null

	New()
		..()
		ENSURE_IMAGE(src.fluid_image, src.icon, src.icon_state + "_fluid")

	on_reagent_change()
		..()
		if (reagents.total_volume)
			var/datum/color/average = reagents.get_average_color()
			fluid_image.color = average.to_rgba()
			src.UpdateOverlays(src.fluid_image, "fluid")
		else
			src.UpdateOverlays(null, "fluid")

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/cereal_box))
			var/obj/item/reagent_containers/food/snacks/cereal_box/cbox = W

			var/obj/newcereal = new /obj/item/reagent_containers/food/snacks/soup/cereal(get_turf(src), cbox.prize, src)
			newcereal.pixel_x = src.pixel_x
			newcereal.pixel_y = src.pixel_y
			cbox.prize = 0
			newcereal.reagents = src.reagents

			if (newcereal.reagents)
				newcereal.reagents.my_atom = newcereal
				src.reagents = null
			else
				newcereal.reagents = new /datum/reagents(50)
				newcereal.reagents.my_atom = newcereal

			newcereal.on_reagent_change()

			user.visible_message("<b>[user]</b> pours [cbox] into [src].", "You pour [cbox] into [src].")
			cbox.bites_left--
			if (cbox.bites_left < 1)
				boutput(user, "<span class='alert'>You finish off the box!</span>")
				qdel(cbox)

			qdel(src)

		else if (istype(W, /obj/item/reagent_containers/food/snacks/tortilla_chip))
			if (reagents.total_volume)
				boutput(user, "You dip [W] into the bowl.")
				reagents.trans_to(W, 10)
			else
				boutput(user, "<span class='alert'>There's nothing in the bowl to dip!</span>")

		else if (istype(W, /obj/item/ladle))
			var/obj/item/ladle/L = W
			if(!L.my_soup)
				boutput(user,"<span class='alert'>There's nothing in the ladle to serve!</span>")
				return
			if(src.reagents.total_volume)
				boutput(user,"<span class='alert'>There's already something in the bowl!</span>")
				return

			var/obj/item/reagent_containers/food/snacks/soup/custom/S = new(L.my_soup, src)
			S.pixel_x = src.pixel_x
			S.pixel_y = src.pixel_y
			for(var/obj/surgery_tray/target_tray in src.loc)
				target_tray.attach(S)
				break

			L.my_soup = null
			L.UpdateOverlays(null, "fluid")

			user.visible_message("<b>[user]</b> pours [L] into [src].", "You pour [L] into [src].")

			S.set_loc(get_turf(src))
			qdel(src)



		else
			..()

/obj/item/reagent_containers/food/drinks/bowl/pumpkin
	name = "pumpkin bowl"
	desc = "Aww, it's all hallowed out."
	icon = 'icons/obj/foodNdrink/drinks.dmi'
	icon_state = "pumpkin"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "pumpkin"
	can_recycle = FALSE


/* ======================================================= */
/* -------------------- Drink Bottles -------------------- */
/* ======================================================= */

/obj/item/reagent_containers/food/drinks/bottle //for alcohol-related bottles specifically
	name = "bottle"
	icon = 'icons/obj/foodNdrink/bottle.dmi'
	icon_state = "bottle"
	desc = "A stylish bottle for the containment of liquids."
	var/label = "none" // Look in bottle.dmi for the label names
	var/labeled = 0 // For writing on the things with a pen
	//var/static/image/bottle_image = null
	var/static/image/image_fluid = null
	var/static/image/image_label = null
	var/static/image/image_ice = null
	var/ice = null
	var/unbreakable = 0
	var/broken = 0
	var/bottle_style = "clear"
	var/fluid_style = "bottle"
	var/alt_filled_state = null // does our icon state gain a 1 if we've got fluid? put that 1 in this here var if so!
	var/fluid_underlay_shows_volume = FALSE // determines whether this bottle is special and shows reagent volume
	var/shatter = 0
	initial_volume = 50
	g_amt = 60

	New()
		..()
		src.UpdateIcon()

	on_reagent_change()
		..()
		src.UpdateIcon()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (src.broken)
			user.visible_message("<span class='alert'><b>[user] slashes [his_or_her(user)] own throat with [src]!</b></span>")
			blood_slash(user, 25)
			user.TakeDamage("head", 150, 0, 0, DAMAGE_CUT)
			SPAWN(50 SECONDS)
				if (user && !isdead(user))
					user.suiciding = 0
			return 1
		else return ..()

	update_icon()
		src.underlays = null
		if (src.broken)
			src.reagents.clear_reagents()
			src.reagents.total_volume = 0
			src.reagents.maximum_volume = 0
			src.icon_state = "broken-[src.bottle_style]"
			if (src.label)
				ENSURE_IMAGE(src.image_label, src.icon, "label-broken-[src.label]")
				//if (!src.image_label)
					//src.image_label = image('icons/obj/foodNdrink/bottle.dmi')
				//src.image_label.icon_state = "label-broken-[src.label]"
				src.UpdateOverlays(src.image_label, "label")
			else
				src.UpdateOverlays(null, "label")
		else
			if (!src.reagents || src.reagents.total_volume <= 0) //Fix for cannot read null/volume. Also FUCK YOU REAGENT CREATING FUCKBUG!
				src.icon_state = "bottle-[src.bottle_style]"
			else if(!src.fluid_underlay_shows_volume)
				src.icon_state = "bottle-[src.bottle_style][src.alt_filled_state]"
				ENSURE_IMAGE(src.image_fluid, src.icon, "fluid-[src.fluid_style]")
				//if (!src.image_fluid)
					//src.image_fluid = image('icons/obj/foodNdrink/bottle.dmi')
				var/datum/color/average = reagents.get_average_color()
				image_fluid.color = average.to_rgba()
				src.underlays += src.image_fluid
			else
				if (reagents.total_volume)
					var/fluid_state = round(clamp((src.reagents.total_volume / src.reagents.maximum_volume * 3 + 1), 1, 3))
					if (!src.image_fluid)
						src.image_fluid = image(src.icon, "fluid-bottle[fluid_state]", -1)
					else
						src.image_fluid.icon_state = "fluid-bottle[fluid_state]"
					src.icon_state = "bottle-[src.bottle_style][fluid_state]"
					var/datum/color/average = reagents.get_average_color()
					src.image_fluid.color = average.to_rgba()
					src.underlays += src.image_fluid
			if (src.label)
				ENSURE_IMAGE(src.image_label, src.icon, "label-[src.label]")
				//if (!src.image_label)
					//src.image_label = image('icons/obj/foodNdrink/bottle.dmi')
				//src.image_label.icon_state = "label-[src.label]"
				src.UpdateOverlays(src.image_label, "label")
			else
				src.UpdateOverlays(null, "label")
			// Ice is implemented below; we just need sprites from whichever poor schmuck that'll be willing to do all that ridiculous sprite work
			if (src.reagents.has_reagent("ice"))
				ENSURE_IMAGE(src.image_ice, src.icon, "ice-[src.fluid_style]")
				src.underlays += src.image_ice
		signal_event("icon_updated")

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/pen) && !src.labeled)
			var/t = input(user, "Enter label", "Label", src.name) as null|text
			if(t && t != src.name)
				phrase_log.log_phrase("bottle", t, no_duplicates=TRUE)
			t = copytext(strip_html(t), 1, 24)
			if (isnull(t) || !length(t) || t == " ")
				return
			if (!in_interact_range(src, user) && src.loc != user)
				return

			src.name = t
			src.labeled = 1
		else
			..()
			return

	attack(target, mob/user)
		if (src.broken && !src.unbreakable)
			force = 5
			throwforce = 10
			throw_range = 5
			w_class = W_CLASS_SMALL
			stamina_damage = 15
			stamina_cost = 15
			stamina_crit_chance = 50
			tooltip_rebuild = 1

			if (src.shatter >= rand(2,12))
				var/turf/U = user.loc
				user.visible_message("<span class='alert'>[src] shatters completely!</span>")
				playsound(U, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
				var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
				G.set_loc(U)
				qdel(src)
				if (prob (25))
					user.visible_message("<span class='alert'>The broken shards of [src] slice up [user]'s hand!</span>")
					playsound(U, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
					var/damage = rand(5,15)
					random_brute_damage(user, damage)
					take_bleeding_damage(user, null, damage)
			else
				src.shatter++
				user.visible_message("<span class='alert'><b>[user]</b> [pick("shanks","stabs","attacks")] [target] with the broken [src]!</span>")
				logTheThing(LOG_COMBAT, user, "attacks [constructTarget(target,"combat")] with a broken [src] at [log_loc(user)].")
				playsound(target, 'sound/impact_sounds/Flesh_Stab_1.ogg', 60, 1)
				var/damage = rand(1,10)
				random_brute_damage(target, damage)//shiv that nukie/secHoP
				take_bleeding_damage(target, null, damage)
		..()

	proc/smash_on_thing(mob/user as mob, atom/target as turf|obj|mob) // why did I have this as a proc on tables?  jeez, babbycoder haine, you really didn't know shit about nothin
		if (!user || !target || user.a_intent != "harm" || issilicon(user))
			return

		if (src.unbreakable)
			boutput(user, "[src] bounces uselessly off [target]!")
			return

		var/turf/U = user.loc
		var/damage = rand(5,15)
		var/success_prob = 25
		var/hurt_prob = 50

		if (user.reagents && user.reagents.has_reagent("ethanol") && user.mind && user.mind.assigned_role == "Bartender")
			success_prob = 75
			hurt_prob = 25

		else if (user.mind && user.mind.assigned_role == "Bartender")
			success_prob = 50
			hurt_prob = 10

		else if (user.reagents && user.reagents.has_reagent("ethanol"))
			success_prob = 75
			hurt_prob = 75

		//have to do all this stuff anyway, so do it now
		playsound(U, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
		var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
		G.set_loc(U)

		if (src.reagents)
			src.reagents.reaction(U)

		DEBUG_MESSAGE("[src].smash_on_thing([user], [target]): success_prob [success_prob], hurt_prob [hurt_prob]")
		if (!src.broken && prob(success_prob))
			user.visible_message("<span class='alert'><b>[user] smashes [src] on [target], shattering it open![prob(50) ? " [user] looks like they're ready for a fight!" : " [src] has one mean edge on it!"]</span>")
			src.item_state = "broken_beer" // shattered beer inhand sprite
			user.update_inhands()
			src.broken = 1
			src.UpdateIcon() // handles reagent holder stuff

		else
			user.visible_message("<span class='alert'><b>[user] smashes [src] on [target]! \The [src] shatters completely!</span>")
			if (prob(hurt_prob))
				user.visible_message("<span class='alert'>The broken shards of [src] slice up [user]'s hand!</span>")
				playsound(U, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
				random_brute_damage(user, damage)
				take_bleeding_damage(user, user, damage)
			SPAWN(0)
				qdel(src)

/obj/item/reagent_containers/food/drinks/bottle/soda //for soda bottles and bottles from the glass recycler specifically
	fluid_underlay_shows_volume = TRUE


/* ========================================================== */
/* -------------------- Drinking Glasses -------------------- */
/* ========================================================== */

/obj/item/reagent_containers/food/drinks/drinkingglass
	name = "drinking glass"
	desc = "Caution - fragile."
	icon = 'icons/obj/foodNdrink/drinks.dmi'
	icon_state = "glass-drink"
	item_state = "drink_glass"
	var/icon_style = "drink"
	g_amt = 30
	var/glass_style = "drink"
	var/salted = 0
	var/obj/item/reagent_containers/food/snacks/plant/wedge = null
	var/obj/item/cocktail_stuff/drink_umbrella/umbrella = null
	var/obj/item/cocktail_stuff/in_glass = null
	initial_volume = 50
	var/smashed = 0
	var/shard_amt = 1
	var/splash_on_smash = FALSE

	var/image/fluid_image
	var/image/image_ice
	var/image/image_salt
	var/image/image_wedge
	var/image/image_doodad

	on_reagent_change()
		..()
		src.UpdateIcon()

	update_icon()

		src.underlays = null
		if (reagents.total_volume)
			var/fluid_state = round(clamp((src.reagents.total_volume / src.reagents.maximum_volume * 3 + 1), 1, 3))
			if (!src.fluid_image)
				src.fluid_image = image(src.icon, "fluid-[src.glass_style][fluid_state]", -1)
			else
				src.fluid_image.icon_state = "fluid-[src.glass_style][fluid_state]"
			src.icon_state = "glass-[src.glass_style][fluid_state]"
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.underlays += src.fluid_image
		else
			src.icon_state = "glass-[src.glass_style]"

		if (src.salted)
			if (!src.image_salt)
				src.image_salt = image(src.icon, "[glass_style]-salted", layer = FLOAT_LAYER)
			else
				src.image_salt.icon_state = "[glass_style]-salted"
			src.UpdateOverlays(src.image_salt, "salt")
		else
			src.UpdateOverlays(null, "salt")

		if (istype(src.in_glass))
			var/new_layer = FLOAT_LAYER - 0.2
			if (istype(in_glass, /obj/item/cocktail_stuff/drink_umbrella))
				new_layer = FLOAT_LAYER + 0.2
			if (!src.image_doodad)
				src.image_doodad = image(src.icon, "[glass_style]-[src.in_glass.icon_state]", layer = new_layer)
			else
				src.image_doodad.icon_state = "[glass_style]-[src.in_glass.icon_state]"
				src.image_doodad.layer = new_layer
			src.UpdateOverlays(src.image_doodad, "doodad")
		else
			src.UpdateOverlays(null, "doodad")

		if (src.reagents.has_reagent("ice"))
			if (!src.image_ice)
				src.image_ice = image(src.icon, "[glass_style]-ice", layer = FLOAT_LAYER - 0.1)
			else
				src.image_ice.icon_state = "[glass_style]-ice"
			src.UpdateOverlays(src.image_ice, "ice")
		else
			src.UpdateOverlays(null, "ice")

		if (istype(src.wedge))
			if (!src.image_wedge)
				src.image_wedge = image(src.icon, "[glass_style]-[src.wedge.icon_state]", layer = FLOAT_LAYER + 0.1)
			else
				src.image_wedge.icon_state = "[glass_style]-[src.wedge.icon_state]"
			src.UpdateOverlays(src.image_wedge, "wedge")
		else
			src.UpdateOverlays(null, "wedge")

		signal_event("icon_updated")
		return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/raw_material/ice))
			if (src.reagents.total_volume >= (src.reagents.maximum_volume - 5))
				if (user.bioHolder.HasEffect("clumsy") && prob(50))
					user.visible_message("[user] adds [W] to [src].<br><span class='alert'>[src] is too full and spills!</span>",\
					"You add [W] to [src].<br><span class='alert'>[src] is too full and spills!</span>")
					src.reagents.reaction(get_turf(user), TOUCH, src.reagents.total_volume / 2)
					src.reagents.add_reagent("ice", 10, null, (T0C - 50))
					JOB_XP(user, "Clown", 1)
					qdel(W)
					return
				else
					boutput(user, "<span class='alert'>[src] is too full!</span>")
				return
			else
				user.visible_message("[user] adds [W] to [src].",\
				"You add [W] to [src].")
				src.reagents.add_reagent("ice", 10, null, (T0C - 50))
				qdel(W)
				if ((user.mind.assigned_role == "Bartender") && (prob(40)))
					JOB_XP(user, "Bartender", 1)
				return

		else if (istype(W, /obj/item/reagent_containers/food/snacks/plant/orange/wedge) || istype(W, /obj/item/reagent_containers/food/snacks/plant/lime/wedge) || istype(W, /obj/item/reagent_containers/food/snacks/plant/lemon/wedge) || istype(W, /obj/item/reagent_containers/food/snacks/plant/grapefruit/wedge))
			if (src.wedge)
				boutput(user, "<span class='alert'>You can't add another wedge to [src], that would just look silly!!</span>")
				return
			user.visible_message("[user] adds [W] to the lip of [src].",\
			"<span class='notice'>You add [W] to the lip of [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			src.wedge = W
			src.UpdateIcon()
			if ((user.mind.assigned_role == "Bartender") && (prob(40)))
				JOB_XP(user, "Bartender", 1)
			return

		else if (istype(W, /obj/item/reagent_containers/food/snacks/plant/orange) || istype(W, /obj/item/reagent_containers/food/snacks/plant/lime) || istype(W, /obj/item/reagent_containers/food/snacks/plant/lemon) || istype(W, /obj/item/reagent_containers/food/snacks/plant/grapefruit))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[src] is full.</span>")
				return
			user.visible_message("[user] squeezes [W] into [src].",\
			"<span class='notice'>You squeeze [W] into [src].</span>")
			W.reagents.trans_to(src, W.reagents.total_volume)
			qdel(W)
			return

		else if (istype(W, /obj/item/cocktail_stuff))
			if (src.umbrella || src.in_glass)
				boutput(user, "<span class='alert'>There's not enough room to put that in [src]!</span>")
				return
			user.visible_message("[user] adds [W] to [src].",\
			"<span class='notice'>You add [W] to [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			src.in_glass = W
			src.UpdateIcon()
			return

		else if (istype(W, /obj/item/shaker/salt))
			var/obj/item/shaker/salt/S = W
			if (S.shakes >= 15)
				boutput(user, "<span class='alert'>There isn't enough salt in here to salt the rim!</span>")
				return
			else
				boutput(user, "<span class='notice'>You salt the rim of [src].</span>")
				src.salted = 1
				src.UpdateIcon()
				S.shakes ++
				return

		else if (istype(W, /obj/item/reagent_containers) && W.is_open_container() && W.reagents.has_reagent("salt"))
			if (src.salted)
				return
			else if (W.reagents.get_reagent_amount("salt") >= 5)
				boutput(user, "<span class='notice'>You salt the rim of [src].</span>")
				W.reagents.remove_reagent("salt", 5)
				src.salted = 1
				src.UpdateIcon()
				if ((user.mind.assigned_role == "Bartender") && (prob(40)))
					JOB_XP(user, "Bartender", 1)
				return
			else
				boutput(user, "<span class='alert'>There isn't enough salt in here to salt the rim!</span>")
				return

		else if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/egg))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[src] is full.</span>")
				return

			boutput(user, "<span class='notice'>You crack [W] into [src].</span>")

			W.reagents.trans_to(src, W.reagents.total_volume)
			qdel(W)

		else
			return ..()

	attack_self(var/mob/user as mob)
		if (!user && usr)
			user = usr
		else if (!user)
			return ..()

		if (!ishuman(user))
			boutput(user, "<span class='notice'>You don't know what to do with [src].</span>")
			return
		var/mob/living/carbon/human/H = user
		var/list/choices = list()

		var/bladder = H.sims?.getValue("Bladder")
		if ((!isnull(bladder) && (bladder <= 65)) || (isnull(bladder) && (H.urine >= 2)))
			choices += "pee in it"
		if (src.in_glass)
			choices += "remove [src.in_glass]"
			if (!istype(src.in_glass, /obj/item/cocktail_stuff/drink_umbrella) || (H.bioHolder && (H.bioHolder.HasEffect("clumsy") || H.bioHolder.HasEffect("mattereater"))))
				choices += "eat [src.in_glass]"
		if (src.wedge)
			choices += "remove [src.wedge]"
			choices += "eat [src.wedge]"
		if (reagents.total_volume > 0)
			if (!length(choices))
				if (!ON_COOLDOWN(src, "hotkey_drink", 0.6 SECONDS))
					attack(user, user) //Most glasses people use won't have fancy cocktail stuff, so just skip the crap and drink for dear life
				return
			choices += "drink from it"
		if (!choices.len)
			boutput(user, "<span class='notice'>You can't think of anything to do with [src].</span>")
			return

		var/selection = tgui_input_list(user, "What do you want to do with [src]?", "Selection", choices)
		if (isnull(selection) || BOUNDS_DIST(src, user) > 0)
			return

		var/obj/item/remove_thing
		var/obj/item/eat_thing

		if (selection == "pee in it")
			bladder = H.sims?.getValue("Bladder")
			if ((!isnull(bladder) && (bladder <= 65)) || (isnull(bladder) && (H.urine >= 2)))
				H.visible_message("<span class='alert'><B>[H] pees in [src]!</B></span>")
				playsound(H, 'sound/misc/pourdrink.ogg', 50, 1)
				if (!H.sims)
					H.urine -= 2
				else
					H.sims.affectMotive("Bladder", 100)
				src.reagents.add_reagent("urine", 8)
			else
				boutput(H, "<span class='alert'>You don't feel like you need to go.</span>")
			return

		else if (selection == "drink from it")
			if (!ON_COOLDOWN(src, "hotkey_drink", 0.6 SECONDS))
				attack(user, user)

		else if (selection == "remove [src.in_glass]")
			remove_thing = src.in_glass
			src.in_glass = null

		else if (selection == "remove [src.wedge]")
			remove_thing = src.wedge
			src.wedge = null

		else if (selection == "eat [src.in_glass]")
			eat_thing = src.in_glass
			src.in_glass = null

		else if (selection == "eat [src.wedge]")
			eat_thing = src.wedge
			src.wedge = null

		if (remove_thing)
			H.visible_message("[H] removes [remove_thing] from [src].",\
			"<span class='notice'>You remove [remove_thing] from [src].</span>")
			H.put_in_hand_or_drop(remove_thing)
			src.UpdateIcon()
			return

		if (eat_thing)
			H.visible_message("[H] plucks [eat_thing] out of [src] and eats it.",\
			"<span class='notice'>You pluck [eat_thing] out of [src] and eat it.</span>")
			if (istype(eat_thing, /obj/item/cocktail_stuff/drink_umbrella) && !(H.bioHolder && H.bioHolder.HasEffect("mattereater")))
				H.visible_message("<span class='alert'><b>[H] chokes on [eat_thing]!</b></span>",\
				"<span class='alert'>You choke on [eat_thing]! <b>That was a terrible idea!</b></span>")
				H.losebreath += max(H.losebreath, 5)
			else if (eat_thing.reagents && eat_thing.reagents.total_volume)
				eat_thing.reagents.trans_to(H, eat_thing.reagents.total_volume)
			playsound(H, 'sound/items/eatfood.ogg', rand(10,50), 1)
			qdel(eat_thing)
			src.UpdateIcon()
			return

	ex_act(severity)
		src.smash()


	Crossed(atom/movable/mover) //Makes barfights cooler
		if(istype(mover, /obj/projectile))
			if(prob(30))
				src.smash()
		. = ..()

	proc/smash(var/atom/A)
		if (src.smashed)
			return
		src.smashed = 1

		var/turf/T = get_turf(A)
		if (!T)
			T = get_turf(src)
		if (!T)
			qdel(src)
			return
		if(src.reagents && splash_on_smash)
			var/amt = max(10, src.gulp_size)
			src.reagents.reaction(A, react_volume = min(amt, src.reagents.total_volume))
			src.reagents.remove_any(amt)
			src.reagents.reaction(T)
		T.visible_message("<span class='alert'>[src] shatters!</span>")
		playsound(T, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
		for (var/i=src.shard_amt, i > 0, i--)
			var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
			G.set_loc(src.loc)
		if (src.in_glass)
			src.in_glass.set_loc(src.loc)
			src.in_glass = null
		if (src.wedge)
			src.wedge.set_loc(src.loc)
			src.wedge = null
		qdel(src)

	throw_impact(atom/A, datum/thrown_thing/thr)
		..()
		src.smash(A)

	pixelaction(atom/target, list/params, mob/living/user, reach)
		if(!istype(target, /obj/table) || src.cant_drop)
			return ..()
		var/obj/table/target_table = target
		var/obj/table/source_table = locate() in get_step(user, user.dir)
		if(isnull(source_table))
			for(var/dir in cardinal)
				source_table = locate() in get_step(user, dir)
				if(!isnull(source_table))
					user.set_dir(dir)
					break
		if(isnull(source_table))
			return
		if(!can_reach(user, source_table))
			return
		if("icon-x" in params)
			src.pixel_x = text2num(params["icon-x"]) - 16
		if("icon-y" in params)
			src.pixel_y = text2num(params["icon-y"]) - 16
		user.weapon_attack(source_table, src, TRUE, list())
		var/list/turf/path = raytrace(get_turf(source_table), get_turf(target_table))
		var/turf/last_turf = get_turf(source_table)
		SPAWN(0)
			var/max_iterations = 20
			for(var/turf/T in path)
				if(max_iterations-- <= 0)
					break
				if(src.loc != last_turf)
					break
				if(!(locate(/obj/table) in src.loc))
					src.smash(T)
					break
				step_towards(src, T, 0.1 SECONDS)
				last_turf = T
				sleep(0.1 SECONDS)

//this action accepts a target that is not the owner, incase we want to allow forced chugging.
/datum/action/bar/icon/chug
	duration = 0.5 SECONDS
	id = "chugging"
	var/mob/glassholder
	var/mob/target
	var/obj/item/reagent_containers/food/drinks/glass

	New(mob/Target, obj/item/reagent_containers/food/drinks/Glass)
		..()
		target = Target
		glass = Glass
		icon = glass.icon
		icon_state = glass.icon_state

	proc/checkContinue()
		if (glass.reagents.total_volume <= 0 || !isalive(glassholder) || !glassholder.find_in_hand(glass) || \
				glassholder.reagents.total_volume >= glassholder.reagents.maximum_volume - CHEM_EPSILON)
			return FALSE
		return TRUE

	onStart()
		..()
		glassholder = src.owner
		loopStart()
		if(glassholder == target)
			glassholder.visible_message("[glassholder.name] starts chugging the [glass.name]!")
		else
			glassholder.visible_message("[glassholder.name] starts forcing [target.name] to chug the [glass.name]!")
		logTheThing(glassholder == target ? LOG_CHEMISTRY : LOG_COMBAT, glassholder, "[glassholder == target ? "starts chugging from" : "makes [constructTarget(target,"combat")] chug from"] [glass] [log_reagents(glass)] at [log_loc(target)].")
		return

	loopStart()
		..()
		if(!checkContinue()) interrupt(INTERRUPT_ALWAYS)
		return

	onUpdate()
		..()
		if(!checkContinue()) interrupt(INTERRUPT_ALWAYS)
		return

	onInterrupt(flag)
		..()
		target.visible_message("[target.name] couldn't drink everything in the [glass.name].")

	onEnd()

		if (glass.reagents.total_volume) //Take a sip
			glass.reagents.reaction(target, INGEST, clamp(glass.reagents.total_volume, CHEM_EPSILON, min(glass.gulp_size, (target.reagents?.maximum_volume - target.reagents?.total_volume))))
			glass.reagents.trans_to(target, min(glass.reagents.total_volume, glass.gulp_size))
			playsound(target.loc,'sound/items/drink.ogg', rand(10,50), 1)
			target.urine += 0.1
			eat_twitch(target)

		if(glass.reagents.total_volume <= 0)
			..()
			target.visible_message("[target.name] chugged everything in the [glass.name]!")
		else if(!checkContinue())
			..()
			target.visible_message("[target.name] stops chugging.")
		else
			onRestart()
		return


/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/food/drinks/drinkingglass/shot
	name = "shot glass"
	icon_state = "glass-shot"
	glass_style = "shot"
	amount_per_transfer_from_this = 15
	gulp_size = 15
	initial_volume = 15

/obj/item/reagent_containers/food/drinks/drinkingglass/shot/syndie
	amount_per_transfer_from_this = 50
	gulp_size = 50
	initial_volume = 50
	splash_on_smash = TRUE

/obj/item/reagent_containers/food/drinks/drinkingglass/oldf
	name = "old fashioned glass"
	icon_state = "glass-oldf"
	glass_style = "oldf"
	initial_volume = 20

/obj/item/reagent_containers/food/drinks/drinkingglass/round
	name = "round glass"
	icon_state = "glass-round"
	glass_style = "round"
	initial_volume = 100

/obj/item/reagent_containers/food/drinks/drinkingglass/wine
	name = "wine glass"
	icon_state = "glass-wine"
	glass_style = "wine"
	initial_volume = 30

/obj/item/reagent_containers/food/drinks/drinkingglass/cocktail
	name = "cocktail glass"
	icon_state = "glass-cocktail"
	glass_style = "cocktail"
	initial_volume = 20

/obj/item/reagent_containers/food/drinks/drinkingglass/flute
	name = "champagne flute"
	icon_state = "glass-flute"
	glass_style = "flute"
	initial_volume = 20

/obj/item/reagent_containers/food/drinks/drinkingglass/pitcher
	name = "glass pitcher"
	desc = "A big container for holding a lot of liquid that you then serve to people. Probably alcohol, let's be honest."
	icon_state = "glass-pitcher"
	glass_style = "pitcher"
	initial_volume = 120
	shard_amt = 2

/obj/item/reagent_containers/food/drinks/drinkingglass/icing
	name = "icing tube"
	desc = "Used to put icing on cakes."
	icon = 'icons/obj/foodNdrink/food.dmi'
	icon_state = "icing_tube"
	initial_volume = 50
	amount_per_transfer_from_this = 5
	can_recycle = FALSE
	var/image/chem = new /image('icons/obj/foodNdrink/food.dmi',"icing_tube_chem")

	on_reagent_change()
		..()
		src.underlays = null
		if (reagents.total_volume >= 0)
			if(reagents.total_volume == 0)
				src.icon_state = "icing_tube"
			else
				src.icon_state = "icing_tube_2"
			if(length(src.underlays))
				src.underlays = null
			var/datum/color/average = reagents.get_average_color()
			chem.color = average.to_rgba()
			src.underlays += chem
		signal_event("icon_updated")

	attackby(obj/item/W, mob/user)
		return

	attack_self(var/mob/user as mob)
		return

	update_icon()

		return

	throw_impact(var/turf/T)
		return

	ex_act(severity)
		qdel(src)

/obj/item/reagent_containers/food/drinks/drinkingglass/random_style
	rand_pos = 1
	New()
		..()
		pick_style()

	proc/pick_style()
		src.glass_style = pick("drink","shot","wine","cocktail","flute")
		switch(src.glass_style)
			if ("shot")
				src.name = "shot glass"
				src.icon_state = "glass-shot"
				src.amount_per_transfer_from_this = 15
				src.gulp_size = 15
				src.initial_volume = 15
			if ("wine")
				src.name = "wine glass"
				src.icon_state = "glass-wine"
				src.initial_volume = 30
			if ("cocktail")
				src.name = "cocktail glass"
				src.icon_state = "glass-cocktail"
				src.initial_volume = 20
			if ("flute")
				src.name = "champagne flute"
				src.icon_state = "glass-flute"
				src.initial_volume = 20


/obj/item/reagent_containers/food/drinks/drinkingglass/random_style/filled
	var/list/whitelist = null
	var/list/blacklist = list("big_bang_precursor", "big_bang", "nitrotri_parent", "nitrotri_wet", "nitrotri_dry")

	New()
		..()
		SPAWN(0)
			if (src.reagents)
				src.fill_it_up()
				src.decorate()

	proc/fill_it_up()
		var/flavor = null

		if (islist(src.whitelist) && src.whitelist.len > 0)
			if (islist(src.blacklist) && src.blacklist.len > 0)
				flavor = pick(src.whitelist - src.blacklist)
			else
				flavor = pick(src.whitelist)

		else if (islist(all_functional_reagent_ids) && all_functional_reagent_ids.len > 0)
			if (islist(src.blacklist) && src.blacklist.len > 0)
				flavor = pick(all_functional_reagent_ids - src.blacklist)
			else
				flavor = pick(all_functional_reagent_ids)

		else
			flavor = "water"

		src.reagents.add_reagent(flavor, src.initial_volume)
		src.whitelist = null // save a tiny bit of memory I guess
		src.blacklist = null // same as above  :V

	proc/decorate()
		if (prob(33))
			var/P = pick(/obj/item/reagent_containers/food/snacks/plant/orange/wedge,\
			/obj/item/reagent_containers/food/snacks/plant/grapefruit/wedge,\
			/obj/item/reagent_containers/food/snacks/plant/lime/wedge,\
			/obj/item/reagent_containers/food/snacks/plant/lemon/wedge)
			src.wedge = new P(src)
		if (prob(33))
			src.umbrella = new /obj/item/cocktail_stuff/drink_umbrella(src)
		if (prob(33))
			var/P = pick(/obj/item/cocktail_stuff/maraschino_cherry,\
			/obj/item/cocktail_stuff/cocktail_olive,\
			/obj/item/cocktail_stuff/celery)
			src.in_glass = new P(src)
		if (prob(5))
			src.salted = TRUE
		src.update_icon()

/obj/item/reagent_containers/food/drinks/drinkingglass/random_style/filled/sane
	// well, relatively sane, the dangerous drinks are still here but at least people won't be drinking initropidril again
	whitelist = list("bilk", "milk", "chocolate_milk", "strawberry_milk", "beer", "cider",
	                 "mead", "wine", "white_wine", "champagne", "rum", "vodka", "bourbon",
	                 "tequila", "boorbon", "beepskybeer", "bojack", "screwdriver",
	                 "bloody_mary", "bloody_scary", "suicider", "grog", "port", "gin",
	                 "vermouth", "bitters", "whiskey_sour", "daiquiri", "martini",
	                 "v_martini", "murdini", "mutini", "manhatten", "libre",
	                 "ginfizz", "gimlet", "v_gimlet", "w_russian", "b_russian",
	                 "irishcoffee", "cosmo", "beach", "gtonic", "vtonic", "sonic",
	                 "gpink", "eraser", "dbreath", "squeeze", "hunchback", "madmen",
	                 "planter", "maitai", "harlow", "gchronic", "margarita",
	                 "tequini", "pfire", "bull", "longisland", "longbeach",
	                 "pinacolada", "mimosa", "french75", "negroni", "necroni",
	                 "ectocooler", "cola", "coffee", "espresso", "decafespresso",
	                 "energydrink", "tea", "honey_tea", "chocolate", "nectar", "honey",
	                 "royal_jelly", "eggnog", "chickensoup", "gravy", "egg", "juice_lime",
	                 "juice_cran", "juice_orange", "juice_lemon", "juice_tomato",
	                 "juice_strawberry", "juice_cherry", "juice_pineapple", "juice_apple",
	                 "coconut_milk", "juice_pickle", "cocktail_citrus", "lemonade",
	                 "halfandhalf", "swedium", "caledonium", "essenceofevlis", "pizza",
									 "mint_tea", "tomcollins", "sangria", "peachschnapps", "mintjulep",
									 "mojito", "cremedementhe", "grasshopper", "freeze", "limeade", "juice_peach")

/obj/item/reagent_containers/food/drinks/duo
	name = "red duo cup"
	desc = "Can't imagine a party without a few dozen these on the lawn afterward."
	icon_state = "duo"
	item_state = "duo"
	initial_volume = 30
	can_recycle = FALSE
	var/image/fluid_image

	New()
		..()
		fluid_image = image(src.icon, "fluid-duo")
		UpdateIcon()

	on_reagent_change()
		..()
		src.UpdateIcon()

	update_icon()
		if (src.reagents.total_volume == 0)
			icon_state = "duo"
		if (src.reagents.total_volume > 0)
			var/datum/color/average = reagents.get_average_color()
			if (!fluid_image)
				fluid_image = image(src.icon, "fluid-duo")
			fluid_image.color = average.to_rgba()
			src.UpdateOverlays(src.fluid_image, "fluid")
		else
			src.UpdateOverlays(null, "fluid")

/* ============================================== */
/* -------------------- Misc -------------------- */
/* ============================================== */

/obj/item/reagent_containers/food/drinks/skull_chalice
	name = "skull chalice"
	desc = "A thing which you can drink fluids out of. Um. It's made from a skull. Considering how many holes are in skulls, this is perhaps a questionable design."
	icon_state = "skullchalice"
	item_state = "skullchalice"
	can_recycle = FALSE

/obj/item/reagent_containers/food/drinks/mug
	name = "mug"
	desc = "A standard mug, for coffee or tea or whatever you wanna drink."
	icon_state = "mug"
	item_state = "mug"

	dan
		name = "odd mug"
		desc = "A nondescript ceramic mug. Something about it seems a bit strange."
		icon_state = "dan_mug"
		item_state = "dan_mug"
		initial_volume = 120

	dan_drunk
		name = "odd mug"
		desc = "A nondescript ceramic mug. Something about it seems a bit strange."
		icon_state = "dan_mug"
		item_state = "dan_mug"
		initial_volume = 120
		initial_reagents = list("coffee" = 80, "vodka" = 40)

/obj/item/reagent_containers/food/drinks/mug/HoS
	name = "Head of Security's mug"
	desc = ""
	icon_state = "HoSMug"
	item_state = "mug"

	get_desc(var/dist, var/mob/user)
		if (user.mind?.assigned_role == "Head of Security")
			. = "Its your favourite mug! It reads 'Galaxy's Number One HoS!' on the front. You remember when you got it last Spacemas from a secret admirer."
		else
			. = "It reads 'Galaxy's Number One HoS!' on the front. You remember finding the receipt for it in disposals when the HoS bought it for themselves last Spacemas."

/obj/item/reagent_containers/food/drinks/mug/HoS/blue
	icon_state = "HoSMugBlue"
	item_state = "mug"

/obj/item/reagent_containers/food/drinks/mug/random_color
	New()
		..()
		src.color = random_saturated_hex_color(1)

/obj/item/reagent_containers/food/drinks/paper_cup
	name = "paper cup"
	desc = "A cup made of paper. It's not that complicated."
	icon_state = "paper_cup"
	item_state = "drink_glass"
	initial_volume = 15
	can_recycle = 0

/obj/item/reagent_containers/food/drinks/espressocup
	name = "espresso cup"
	desc = "A fancy espresso cup, for sipping in the finest establishments." //*tip
	icon_state = "fancycoffee"
	item_state = "coffee"
	initial_volume = 20
	gulp_size = 2.5
	g_amt = 2.5 //might be broken still, Whatever
	var/glass_style = "fancycoffee"

	var/image/fluid_image
	on_reagent_change()
		..()
		src.UpdateIcon()

	update_icon() //updates icon based on fluids inside
		icon_state = "[glass_style]"

		var/datum/color/average = reagents.get_average_color()
		if (!src.fluid_image)
			src.fluid_image = image('icons/obj/foodNdrink/drinks.dmi', "fluid-[glass_style]", -1)
		src.fluid_image.color = average.to_rgba()
		src.UpdateOverlays(src.fluid_image, "fluid")

/obj/item/reagent_containers/food/drinks/pinkmug //for Jan's office
	name = "pink latte mug"
	desc = "Whoever owns this drinks a lot of lattes."
	icon = 'icons/misc/janstuff.dmi'
	icon_state = "pinkmug_full"
	initial_volume = 50
	initial_reagents = list("espresso"=40, "milk"=5, "chocolate"=5)

	on_reagent_change()
		..()
		src.UpdateIcon()

		if (src.reagents.total_volume == 0)
			update_icon()
			icon_state = "pinkmug_empty"
		else
			update_icon()
			icon_state = "pinkmug_full"
		return

/obj/item/reagent_containers/food/drinks/carafe
	name = "coffee carafe"
	desc = null
	icon_state = "carafe-gen"
	item_state = "carafe-gen"
	initial_volume = 100
	can_chug = 0
	var/smashed = 0
	var/shard_amt = 1
	var/image/fluid_image

	on_reagent_change()
		..()
		src.UpdateIcon()

	update_icon() //updates icon based on fluids inside
		if (src.reagents && src.reagents.total_volume)
			var/datum/color/average = reagents.get_average_color()
			var/average_rgb = average.to_rgba()
			if (!src.fluid_image)
				src.fluid_image = image('icons/obj/foodNdrink/drinks.dmi', "fluid-carafe", -1)
			src.fluid_image.color = average_rgb
			src.UpdateOverlays(src.fluid_image, "fluid")
			if (istype(src.loc, /obj/machinery/coffeemaker))
				var/obj/machinery/coffeemaker/CM = src.loc
				CM.update(average_rgb)
		else
			src.UpdateOverlays(null, "fluid")

	proc/smash(var/turf/T)
		if (src.smashed)
			return
		src.smashed = 1
		if (!T)
			T = get_turf(src)
		if (!T)
			qdel(src)
			return
		if (src.reagents) // haine fix for cannot execute null.reaction()
			src.reagents.reaction(T)
		T.visible_message("<span class='alert'>[src] shatters!</span>")
		playsound(T, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
		for (var/i=src.shard_amt, i > 0, i--)
			var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
			G.set_loc(src.loc)
		qdel(src)

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		..()
		src.smash(T)

/obj/item/reagent_containers/food/drinks/carafe/attack(mob/M, mob/user)
	if (user.a_intent == INTENT_HARM)
		if (M == user)
			boutput(user, "<span class='alert'><B>You smash the [src] over your own head!</b></span>")
		else
			M.visible_message("<span class='alert'><B>[user] smashes [src] over [M]'s head!</B></span>")
			logTheThing(LOG_COMBAT, user, "smashes [src] over [constructTarget(M,"combat")]'s head! ")
		M.TakeDamageAccountArmor("head", force, 0, 0, DAMAGE_BLUNT)
		M.changeStatus("weakened", 2 SECONDS)
		playsound(M, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
		var/obj/O = new /obj/item/raw_material/shard/glass
		O.set_loc(get_turf(M))
		if (src.material)
			O.setMaterial(copyMaterial(src.material))
		if (src.reagents)
			src.reagents.reaction(M)
			qdel(src)
	else
		M.visible_message("<span class='alert'>[user] taps [M] over the head with [src].</span>")
		logTheThing(LOG_COMBAT, user, "taps [constructTarget(M,"combat")] over the head with [src].")

/obj/item/reagent_containers/food/drinks/carafe/medbay
	icon_state = "carafe-med"
	item_state = "carafe-med"

/obj/item/reagent_containers/food/drinks/carafe/botany
	icon_state = "carafe-hyd"
	item_state = "carafe-hyd"

/obj/item/reagent_containers/food/drinks/carafe/security
	icon_state = "carafe-sec"
	item_state = "carafe-sec"

/obj/item/reagent_containers/food/drinks/carafe/research
	icon_state = "carafe-sci"
	item_state = "carafe-sci"

/obj/item/reagent_containers/food/drinks/carafe/engineering
	icon_state = "carafe-eng"
	item_state = "carafe-eng"

/obj/item/reagent_containers/food/drinks/coconut
	name = "Coconut"
	desc = "Must be migrational."
	icon = 'icons/obj/foodNdrink/drinks.dmi'
	icon_state = "coconut"
	item_state = "drink_glass"
	g_amt = 30
	initial_volume = 50
	can_recycle = FALSE
	initial_reagents = list("coconut_milk"=20)

/obj/item/reagent_containers/food/drinks/pumpkinlatte
	name = "Spiced Pumpkin"
	desc = "Oh, a delicious, mysterious pumpkin spice latte!"
	icon = 'icons/obj/foodNdrink/drinks.dmi'
	icon_state = "pumpkinlatte"
	item_state = "drink_glass"
	g_amt = 30
	initial_volume = 50
	can_recycle = FALSE
	initial_reagents = list("pumpkinspicelatte"=30)

/obj/item/reagent_containers/food/drinks/energyshake
	name = "Brotein Shake - Dragon Balls flavor"
	desc = {"Do you want to get PUMPED UP? Try this 100% NATURAL shake FRESH from the press!
	We guarantee FULL ACTIVATION of midi-whatevers to EHNANCE your performance on and off the field.
	Embrace the STRENGTH and POWER of the dragon WITHIN YOU! Spread your newfound wings and ELEVATE your soul!
	When you are off on your long journey, who do you turn to? Brotien Shake's brand new flavor: DRAGON BALLS!"}
	icon_state = "energy"
	item_state = "drink_glass"
	g_amt = 10
	initial_volume = 25
	initial_reagents = list("energydrink"=20)


/obj/item/reagent_containers/food/drinks/flask
	name = "flask"
	desc = "For the busy alcoholic."
	icon = 'icons/obj/foodNdrink/bottle.dmi'
	icon_state = "flask"
	item_state = "flask"
	g_amt = 5
	initial_volume = 40
	can_recycle = FALSE

/obj/item/reagent_containers/food/drinks/flask/det
	name = "detective's flask"
	desc = "Must be migrational."
	icon = 'icons/obj/foodNdrink/bottle.dmi'
	icon_state = "detflask"
	item_state = "detflask"
	initial_reagents = list("bojack"=40)

/obj/item/reagent_containers/food/drinks/cocktailshaker
	name = "cocktail shaker"
	desc = "A stainless steel tumbler with a top, used to mix cocktails. Can hold up to 120 units."
	icon = 'icons/obj/foodNdrink/bottle.dmi'
	icon_state = "cocktailshaker"
	initial_volume = 120
	can_recycle = 0
	can_chug = 0

	New()
		..()
		src.reagents.inert = 1

	attack_self(mob/user)
		if (src.reagents.total_volume > 0)
			user.visible_message("<b>[user.name]</b> shakes the container [pick("rapidly", "thoroughly", "carefully")].")
			playsound(src, 'sound/items/CocktailShake.ogg', 25, 1, -6)
			sleep (0.3 SECONDS)
			src.reagents.inert = 0
			src.reagents.physical_shock(rand(5, 20))
			src.reagents.handle_reactions()
			src.reagents.inert = 1
			if ((user.mind.assigned_role == "Bartender") && !ON_COOLDOWN(user, "bartender shaker xp", 180 SECONDS))
				JOB_XP(user, "Bartender", 2)
			if (user.mind && user.mind.objectives)
				for (var/datum/objective/crew/bartender/drinks/O in user.mind.objectives)
					for (var/i in 1 to length(O.ids))
						if(src.reagents.has_reagent(O.ids[i]))
							O.completed |= 1 << i-1
		else
			user.visible_message("<b>[user.name]</b> shakes the container, but it's empty!.")

/obj/item/reagent_containers/food/drinks/cocktailshaker/golden
	name = "golden cocktail shaker"
	desc = "A golden plated tumbler with a top, used to mix cocktails. Can hold up to 120 units. So rich! So opulent! So... tacky."
	icon_state = "golden_cocktailshaker"

/obj/item/reagent_containers/food/drinks/creamer
	name = "coffee creamer"
	desc = "A bottle of dairy-based coffee creamer. It's been left out at room temperature for a bit too long, don't you think?"
	icon = 'icons/obj/foodNdrink/espresso.dmi'
	icon_state = "creamer"
	item_state = "creamer"
	initial_volume = 50
	initial_reagents = list("milk"=50)
	can_recycle = 0
