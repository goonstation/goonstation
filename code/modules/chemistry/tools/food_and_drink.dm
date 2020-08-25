
/* ============================================== */
/* -------------------- Food -------------------- */
/* ============================================== */

/obj/item/reagent_containers/food
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	var/heal_amt = 0
	var/needfork = 0
	var/needspoon = 0
	var/food_color = "#FF0000" //Color for various food items
	var/custom_food = 1 //Can it be used to make custom food like for pizzas
	var/festivity = 0
	var/brewable = 0 // will hitting a still with it do anything?
	var/brew_result = null // what will it make if it's brewable?
	var/unlock_medal_when_eaten = null // Add medal name here in the format of e.g. "That tasted funny".
	var/from_emagged_oven = 0 // to prevent re-rolling of food in emagged ovens
	var/doants = 1
	var/made_ants = 0
	rc_flags = 0

	New()
		..()

	pooled()
		..()

	unpooled()
		made_ants = 0
		..()

	proc/on_table()
		if (!isturf(src.loc)) return 0
		for (var/atom/movable/M in src.loc) //Arguably more elegant than a million locates. I don't think locate works with derived classes.
			if (istype(M, /obj/table))
				return 1
		return 0

	proc/heal(var/mob/living/M)
		var/healing = src.heal_amt

		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.sims)
				H.sims.affectMotive("Hunger", heal_amt * 2)
				H.sims.affectMotive("Bladder", -heal_amt * 0.2)

		if (quality >= 5)
			boutput(M, "<span class='notice'>That tasted amazing!</span>")
			healing *= 2

		if (src.reagents && src.reagents.has_reagent("THC"))
			boutput(M, "<span class='notice'>Wow this tastes really good man!!</span>")
			healing *= 2


		if (quality <= 0.5)
			boutput(M, "<span class='alert'>Ugh! That tasted horrible!</span>")
			if (prob(20))
				M.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1) // path, name, strain, bypass resist
			healing = 0

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

/* ================================================ */
/* -------------------- Snacks -------------------- */
/* ================================================ */

/obj/item/reagent_containers/food/snacks
	name = "snack"
	desc = "yummy"
	icon = 'icons/obj/foodNdrink/food.dmi'
	icon_state = null
	amount = 3
	heal_amt = 1
	initial_volume = 100
	festivity = 0
	rc_flags = 0
	edible = 1
	module_research = list("cuisine" = 6)
	module_research_type = /obj/item/reagent_containers/food/snacks
	rand_pos = 1

	var/use_bite_mask = 1
	var/current_mask = 5
	var/start_amount = 0
	var/start_icon = 0
	var/start_icon_state = 0
	var/list/food_effects = list()
	var/create_time = 0

	var/dropped_item = null

	New()
		..()
		start_amount = amount
		start_icon = icon
		start_icon_state = icon_state
		if (doants)
			processing_items.Add(src)
		create_time = world.time

	unpooled()
		..()
		src.icon = start_icon
		src.icon_state = start_icon_state
		amount = initial(amount)
		current_mask = 5
		if (doants)
			processing_items.Add(src)
		create_time = world.time

//	pooled()
//		if(!made_ants)
//			processing_items -= src
//		..()

	disposing()
		if(!made_ants)
			processing_items -= src
		..()

	process()
		if (world.time - create_time >= 1 MINUTES)
			create_time = world.time
			if (!src.pooled && isturf(src.loc) && !on_table())
				if (prob(50))
					made_ants = 1
					processing_items -= src
					if (!(locate(/obj/reagent_dispensers/ants) in src.loc))
						new/obj/reagent_dispensers/ants(src.loc)


	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W,/obj/item/kitchen/utensil/fork) || istype(W,/obj/item/kitchen/utensil/spoon))
			if (prob(20) && (istype(W,/obj/item/kitchen/utensil/fork/plastic) || istype(W,/obj/item/kitchen/utensil/spoon/plastic)))
				var/obj/item/kitchen/utensil/S = W
				S.break_utensil(user)
				user.visible_message("<span class='alert'>[user] stares glumly at [src].</span>")
				return

			src.Eat(user,user)
		else
			..()
		/*
		if (istype(W, /obj/item/shaker))
			var/obj/item/shaker/shaker = W
			src.reagents.add_reagent("[shaker.stuff]", 2)
			shaker.shakes ++
			boutput(user, "You put some [shaker.stuff] onto [src].")
		else return ..()
		*/

	attack_self(mob/user as mob)
		if (!src.Eat(user, user))
			return ..()

	attack(mob/M as mob, mob/user as mob, def_zone)
		if(isghostcritter(user)) return
		if (!src.Eat(M, user))
			return ..()

	Eat(var/mob/M as mob, var/mob/user, var/bypass_utensils = 0)
		// in this case m is the consumer and user is the one holding it
		if (!src.edible)
			return 0
		if (M == user && user.mob_flags & IS_RELIQUARY)
			boutput(user, "<span class='alert'>You don't come equipped with a digestive system, there would be no point in eating this.</span>")
			return 0
		if (!src.amount)
			boutput(user, "<span class='alert'>None of [src] left, oh no!</span>")
			user.u_equip(src)
			qdel(src)
			return 0
		if (iscarbon(M) || ismobcritter(M))
			if (M == user)
				if (!bypass_utensils)
					if (src.needfork && !user.find_type_in_hand(/obj/item/kitchen/utensil/fork))
						boutput(M, "<span class='alert'>You need a fork to eat [src]!</span>")
						M.visible_message("<span class='alert'>[user] stares glumly at [src].</span>")
						return
					if (src.needfork && user.find_type_in_hand(/obj/item/kitchen/utensil/fork/plastic) && prob(20))
						// this can be kinda fucky if they're eating with two forks in hand.
						// basically, the fork in their left hand will always be chosen
						// I guess people in space are all left handed
						for (var/obj/item/kitchen/utensil/fork/plastic/F in user.equipped_list(check_for_magtractor = 0))
							F.break_utensil(M)
							M.visible_message("<span class='alert'>[user] stares glumly at [src].</span>")
							return
					if (src.needspoon && !user.find_type_in_hand(/obj/item/kitchen/utensil/spoon))
						boutput(M, "<span class='alert'>You need a spoon to eat [src]!</span>")
						M.visible_message("<span class='alert'>[user] stares glumly at [src].</span>")
						return
					if (src.needspoon && user.find_type_in_hand(/obj/item/kitchen/utensil/spoon/plastic) && prob(20))
						// this can be kinda fucky if they're eating with two forks in hand.
						// basically, the fork in their left hand will always be chosen
						// I guess people in space are all left handed
						for (var/obj/item/kitchen/utensil/spoon/plastic/S in user.equipped_list(check_for_magtractor = 0))
							S.break_utensil(M)
							M.visible_message("<span class='alert'>[user] stares glumly at [src].</span>")
							return

				//no or broken stomach
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					var/obj/item/organ/stomach/tummy = H.get_organ("stomach")
					if (!istype(tummy) || (tummy.broken || tummy.get_damage() > tummy.MAX_DAMAGE))
						M.visible_message("<span class='notice'>[M] tries to take a bite of [src], but can't swallow!</span>",\
						"<span class='notice'>You try to take a bite of [src], but can't swallow!</span>")
						return 0
				M.visible_message("<span class='notice'>[M] takes a bite of [src]!</span>",\
				"<span class='notice'>You take a bite of [src]!</span>")
				logTheThing("combat", user, M, "takes a bite of [src] [log_reagents(src)] at [log_loc(user)].")

				src.amount--
				M.nutrition += src.heal_amt * 10
				src.heal(M)
				playsound(M.loc,"sound/items/eatfood.ogg", rand(10,50), 1)
				on_bite(M)
				if (src.festivity)
					modify_christmas_cheer(src.festivity)
				if (!src.amount)
					//M.visible_message("<span class='alert'>[M] finishes eating [src].</span>",\
					//"<span class='alert'>You finish eating [src].</span>")
					boutput(M, "<span class='alert'>You finish eating [src].</span>")
					if (istype(src, /obj/item/reagent_containers/food/snacks/plant/) && prob(20))
						var/obj/item/reagent_containers/food/snacks/plant/P = src
						var/doseed = 1
						var/datum/plantgenes/SRCDNA = P.plantgenes
						if (!SRCDNA || HYPCheckCommut(SRCDNA,"Seedless")) doseed = 0
						if (doseed)
							var/datum/plant/stored = P.planttype
							if (istype(stored) && !stored.isgrass)
								var/obj/item/seed/S
								if (stored.unique_seed)
									S = unpool(stored.unique_seed)
									S.set_loc(user.loc)
								else
									S = unpool(/obj/item/seed)
									S.set_loc(user.loc)
									S.removecolor()

								var/datum/plantgenes/DNA = P.plantgenes
								var/datum/plantgenes/PDNA = S.plantgenes
								S.generic_seed_setup(stored)
								HYPpassplantgenes(DNA,PDNA)
								if (stored.hybrid)
									var/datum/plant/hybrid = new /datum/plant(S)
									for (var/V in stored.vars)
										if (issaved(stored.vars[V]) && V != "holder")
											hybrid.vars[V] = stored.vars[V]
									S.planttype = hybrid
								user.visible_message("<span class='notice'><b>[user]</b> spits out a seed.</span>",\
								"<span class='notice'>You spit out a seed.</span>")
					if(src.dropped_item)
						drop_item(dropped_item)
					user.u_equip(src)
					on_finish(M, user)
					qdel(src)
				return 1
			if (M.mob_flags & IS_RELIQUARY)
				boutput(user, "<span class='alert'>They don't come equipped with a digestive system, so there is no point in trying to feed them.</span>")
				return
			else if (check_target_immunity(M))
				user.visible_message("<span class='alert'>You try to feed [M] [src], but fail!</span>")
			else
				user.tri_message("<span class='alert'><b>[user]</b> tries to feed [M] [src]!</span>",\
				user, "<span class='alert'>You try to feed [M] [src]!</span>",\
				M, "<span class='alert'><b>[user]</b> tries to feed you [src]!</span>")
				logTheThing("combat", user, M, "attempts to feed [constructTarget(M,"combat")] [src] [log_reagents(src)] at [log_loc(user)].")

				if (!do_mob(user, M))
					if (user && ismob(user))
						user.show_text("You were interrupted!", "red")
					return
				//no or broken stomach
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					var/obj/item/organ/stomach/tummy = H.get_organ("stomach")
					if (!istype(tummy) || (tummy.broken || tummy.get_damage() > tummy.MAX_DAMAGE))
						user.tri_message("<span class='alert'><b>[user]</b>tries to feed [M] [src], but can't make [him_or_her(M)] swallow!</span>",\
						user, "<span class='alert'>You try to feed [M] [src], but can't make [him_or_her(M)] swallow!</span>",\
						M, "<span class='alert'><b>[user]</b> tries to feed you [src], but you can't swallow!!</span>")
						return 0

				user.tri_message("<span class='alert'><b>[user]</b> feeds [M] [src]!</span>",\
				user, "<span class='alert'>You feed [M] [src]!</span>",\
				M, "<span class='alert'><b>[user]</b> feeds you [src]!</span>")
				logTheThing("combat", user, M, "feeds [constructTarget(M,"combat")] [src] [log_reagents(src)] at [log_loc(user)].")


				on_bite(M)
				src.amount--
				M.nutrition += src.heal_amt * 10
				src.heal(M)
				playsound(M.loc, "sound/items/eatfood.ogg", rand(10,50), 1)
				if (!src.amount)
					M.visible_message("<span class='alert'>[M] finishes eating [src].</span>",\
					"<span class='alert'>You finish eating [src].</span>")
					if(src.dropped_item)
						drop_item(dropped_item)
					user.u_equip(src)
					on_finish(M, user)
					qdel(src)
				return 1

// I don't know if this was used for something but it was breaking my important "shake salt and pepper onto things" feature
// so it's getting commented out until I get yelled at for breaking something
//	attackby(obj/item/I as obj, mob/user as mob)
//		return
	afterattack(obj/target, mob/user , flag)
		return

	proc/on_bite(mob/eater)
		//if (reagents && reagents.total_volume)
		//	reagents.reaction(M, INGEST)
		//	reagents.trans_to(M, reagents.total_volume/(src.amount ? src.amount : 1))

		if (isliving(eater))
			if (src.reagents && src.reagents.total_volume) //only create food chunks for reagents
				var/obj/item/reagent_containers/food/snacks/bite/B = unpool(/obj/item/reagent_containers/food/snacks/bite)
				B.set_loc(eater)
				B.reagents.maximum_volume = reagents.total_volume/(src.amount ? src.amount : 1) //MBC : I copied this from the Eat proc. It doesn't really handle the reagent transfer evenly??
				src.reagents.trans_to(B,B.reagents.maximum_volume,1,0)						//i'll leave it tho because i dont wanna mess anything up
				var/mob/living/L = eater
				L.stomach_process += B

			if (src.food_effects.len && isliving(eater) && eater.bioHolder)
				var/mob/living/L = eater
				for (var/effect in src.food_effects)
					L.add_food_bonus(effect, src)

		if (use_bite_mask)
			var/desired_mask = (amount / start_amount) * 5
			desired_mask = round(desired_mask)
			desired_mask = max(1,desired_mask)
			desired_mask = min(desired_mask, 5)

			if (desired_mask != current_mask)
				current_mask = desired_mask
				src.filters = list(filter(type="alpha", icon=icon('icons/obj/foodNdrink/food.dmi', "eating[desired_mask]")))

		eat_twitch(eater)

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
	icon_state = "scotchegg"
	amount = 1
	heal_amt = 0
	initial_volume = 100
	festivity = 0
	rc_flags = 0
	edible = 1
	module_research = list("cuisine" = 6)
	module_research_type = /obj/item/reagent_containers/food/snacks
	rand_pos = 1
	var/did_react = 0

	unpooled()
		..()
		did_react = 0

	pooled()
		..()
		did_react = 0

	proc/process_stomach(mob/living/owner, var/process_rate = 5)
		if (owner && src.reagents)
			if (!src.did_react)
				src.reagents.reaction(owner, INGEST, src.reagents.total_volume)
				src.did_react = 1

			src.reagents.trans_to(owner, process_rate, HAS_MOB_PROPERTY(owner, PROP_DIGESTION_EFFICIENCY) ? GET_MOB_PROPERTY(owner, PROP_DIGESTION_EFFICIENCY) : 1)

			if (src.reagents.total_volume <= 0)
				owner.stomach_process -= src
				pool(src)



/* ================================================ */
/* -------------------- Drinks -------------------- */
/* ================================================ */

/obj/item/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'icons/obj/foodNdrink/drinks.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	icon_state = null
	flags = FPRINT | TABLEPASS | OPENCONTAINER | SUPPRESSATTACK
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.
	var/splash_all_contents = 1
	doants = 0
	var/can_recycle = 1

	New()
		..()
		update_gulp_size()

	proc/update_gulp_size()
		//gulp_size = round(reagents.total_volume / 5)
		//if (gulp_size < 5) gulp_size = 5
		return

	on_reagent_change()
		update_gulp_size()
		doants = src.reagents && src.reagents.total_volume > 0

	on_spin_emote(var/mob/living/carbon/human/user as mob)
		. = ..()
		if (src.reagents && src.reagents.total_volume > 0)
			user.visible_message("<span class='alert'><b>[user] spills the contents of [src] all over [him_or_her(user)]self!</b></span>")
			logTheThing("combat", user, null, "spills the contents of [src] [log_reagents(src)] all over [him_or_her(user)]self at [log_loc(user)].")
			src.reagents.reaction(get_turf(user), TOUCH)
			src.reagents.clear_reagents()

	//Wow, we copy+pasted the heck out of this... (Source is chemistry-tools dm)
	attack_self(mob/user as mob)
		if (src.splash_all_contents)
			boutput(user, "<span class='notice'>You tighten your grip on the [src].</span>")
			src.splash_all_contents = 0
		else
			boutput(user, "<span class='notice'>You loosen your grip on the [src].</span>")
			src.splash_all_contents = 1
		return

	attack(mob/M as mob, mob/user as mob, def_zone)
		// in this case m is the consumer and user is the one holding it
		if (istype(src, /obj/item/reagent_containers/food/drinks/bottle))
			var/obj/item/reagent_containers/food/drinks/bottle/W = src
			if (W.broken)
				return
		if (M == user && user.mob_flags & IS_RELIQUARY)
			boutput(user, "<span class='alert'>You don't come equipped with a digestive system, there would be no point in drinking this.</span>")
			return 0
		if (!src.reagents || !src.reagents.total_volume)
			boutput(user, "<span class='alert'>Nothing left in [src], oh no!</span>")
			return 0

		if (iscarbon(M) || ismobcritter(M))
			if (M == user)
				M.visible_message("<span class='notice'>[M] takes a sip from [src].</span>")
			else if (M.mob_flags & IS_RELIQUARY)
				boutput(user, "<span class='alert'>They don't come equipped with a digestive system, so there is no point in trying to make them drink.</span>")
				return 0
			else
				user.visible_message("<span class='alert'>[user] attempts to force [M] to drink from [src].</span>")
				logTheThing("combat", user, M, "attempts to force [constructTarget(M,"combat")] to drink from [src] [log_reagents(src)] at [log_loc(user)].")

				if (!do_mob(user, M))
					if (user && ismob(user))
						user.show_text("You were interrupted!", "red")
					return
				if (!src.reagents || !src.reagents.total_volume)
					boutput(user, "<span class='alert'>Nothing left in [src], oh no!</span>")
					return
				user.visible_message("<span class='alert'>[user] makes [M] drink from the [src].</span>")

			if (M.mind && M.mind.assigned_role == "Barman")
				var/reag_list = ""
				for (var/current_id in reagents.reagent_list)
					var/datum/reagent/current_reagent = reagents.reagent_list[current_id]
					if (reagents.reagent_list.len > 1 && reagents.reagent_list[reagents.reagent_list.len] == current_id)
						reag_list += " and [current_reagent.name]"
						continue
					reag_list += ", [current_reagent.name]"
				reag_list = copytext(reag_list, 3)
				boutput(M, "<span class='notice'>Tastes like there might be some [reag_list] in this.</span>")
/*			else
				var/reag_list = ""

				for (var/current_id in reagents.reagent_list)
					var/datum/reagent/current_reagent = reagents.reagent_list[current_id]
					reag_list += "[current_reagent.taste], "

				boutput(M, "<span class='notice'>You taste [reag_list]in this.</span>")
*/
			if (src.reagents.total_volume)
				logTheThing("combat", user, M, "[user == M ? "takes a sip from" : "makes [constructTarget(M,"combat")] drink from"] [src] [log_reagents(src)] at [log_loc(user)].")
				src.reagents.reaction(M, INGEST, gulp_size)
				SPAWN_DBG (5)
					if (src && src.reagents && M && M.reagents)
						src.reagents.trans_to(M, min(reagents.total_volume, gulp_size))

			playsound(M.loc,"sound/items/drink.ogg", rand(10,50), 1)
			M.urine += 0.1
			eat_twitch(M)

			return 1

		return 0

	//bleck, i dont like this at all. (Copied from chemistry-tools reagent_containers/glass/ definition w minor adjustments)
	afterattack(obj/target, mob/user , flag)
		user.lastattacked = target
		if (istype(target, /obj/fluid)) // fluid handling : If src is empty, fill from fluid. otherwise add to the fluid.
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
				logTheThing("combat", user, null, "transfers chemicals from [src] [log_reagents(src)] to [F] at [log_loc(user)].") // Added reagents (Convair880).
				var/trans = src.reagents.trans_to(T, src.splash_all_contents ? src.reagents.total_volume : src.amount_per_transfer_from_this)
				boutput(user, "<span class='notice'>You transfer [trans] units of the solution to [T].</span>")

		else if (istype(target, /obj/reagent_dispensers) || (target.is_open_container() == -1 && target.reagents) || (istype(target, /obj/fluid) && !src.reagents.total_volume)) //A dispenser. Transfer FROM it TO us.
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

			logTheThing("combat", user, null, "transfers chemicals from [src] [log_reagents(src)] to [target] at [log_loc(user)].") // Added reagents (Convair880).
			var/trans = src.reagents.trans_to(target, 10)
			boutput(user, "<span class='notice'>You transfer [trans] units of the solution to [target].</span>")

		else if (istype(target, /obj/item/sponge)) // dump contents onto it
			if (!reagents.total_volume)
				boutput(user, "<span class='alert'>[src] is empty.</span>")
				return

			if (target.reagents.total_volume >= target.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[target] is full.</span>")
				return

			logTheThing("combat", user, null, "transfers chemicals from [src] [log_reagents(src)] to [target] at [log_loc(user)].")
			var/trans = src.reagents.trans_to(target, 10)
			boutput(user, "<span class='notice'>You dump [trans] units of the solution to [target].</span>")

		else if (reagents.total_volume)

			if (ismob(target)) return
			if (isobj(target)) //Have to do this in 2 lines because byond is shit.
				if (target:flags & NOSPLASH) return
			can_mousedrop = 0
			boutput(user, "<span class='notice'>You [src.splash_all_contents ? "pour all of" : "apply [amount_per_transfer_from_this] units of"] the solution onto [target].</span>")
			logTheThing("combat", user, target, "pours [src] onto [constructTarget(target,"combat")] [log_reagents(src)] at [log_loc(user)].") // Added location (Convair880).
			if (reagents)
				reagents.physical_shock(14)

			if (src.splash_all_contents) src.reagents.reaction(target,TOUCH)
			else src.reagents.reaction(target, TOUCH, src.amount_per_transfer_from_this)
			SPAWN_DBG(0.5 SECONDS)
				if (src.splash_all_contents) src.reagents.clear_reagents()
				else src.reagents.remove_any(src.amount_per_transfer_from_this)
				can_mousedrop = 1
			return


	/*
	afterattack(obj/target, mob/user , flag)
		if (istype(target, /obj/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if (!target.reagents.total_volume)
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

			logTheThing("combat", user, null, "transfers chemicals from [src] [log_reagents(src)] to [target] at [log_loc(user)].") // Brought in line with beakers (Convair880).
			var/trans = src.reagents.trans_to(target, 10)
			boutput(user, "<span class='notice'>You transfer [trans] units of the solution to [target].</span>")
		return
	*/

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
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO

	var/image/fluid_image = null

	on_reagent_change()
		//src.overlays = null
		if (reagents.total_volume)
			ENSURE_IMAGE(src.fluid_image, src.icon, "fluid")
			//if (!src.fluid_image)
				//src.fluid_image = image('icons/obj/kitchen.dmi', "fluid")
			var/datum/color/average = reagents.get_average_color()
			fluid_image.color = average.to_rgba()
			src.UpdateOverlays(src.fluid_image, "fluid")
			//src.overlays += src.fluid_image
		else
			src.UpdateOverlays(null, "fluid")

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/cereal_box))
			var/obj/item/reagent_containers/food/snacks/cereal_box/cbox = W

			var/obj/newcereal = new /obj/item/reagent_containers/food/snacks/soup/cereal(get_turf(src), cbox.prize)
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
			cbox.amount--
			if (cbox.amount < 1)
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

			var/obj/item/reagent_containers/food/snacks/soup/custom/S = new(L.my_soup)

			S.pixel_x = src.pixel_x
			S.pixel_y = src.pixel_y
			L.my_soup = null
			L.overlays = null

			user.visible_message("<b>[user]</b> pours [L] into [src].", "You pour [L] into [src].")

			S.set_loc(get_turf(src))
			qdel(src)



		else
			..()

/* ======================================================= */
/* -------------------- Drink Bottles -------------------- */
/* ======================================================= */

/obj/item/reagent_containers/food/drinks/bottle
	name = "bottle"
	icon = 'icons/obj/foodNdrink/bottle.dmi'
	icon_state = "bottle"
	desc = "A stylish bottle for the containment of liquids."
	var/label = "none" // Look in bottle.dmi for the label names
	var/labeled = 0 // For writing on the things with a pen
	//var/static/image/bottle_image = null
	var/static/image/image_fluid = null
	var/static/image/image_label = null
	// var/static/image/image_ice = null
	// var/ice = null
	var/unbreakable = 0
	var/broken = 0
	var/bottle_style = "clear"
	var/fluid_style = "bottle"
	var/alt_filled_state = null // does our icon state gain a 1 if we've got fluid? put that 1 in this here var if so!
	var/shatter = 0
	initial_volume = 50
	g_amt = 60
	rc_flags = RC_VISIBLE | RC_FULLNESS | RC_SPECTRO

	New()
		..()
		src.update_icon()

	on_reagent_change()
		src.update_icon()

	unpooled()
		..()
		src.broken = 0
		src.shatter = 0
		src.labeled = 0
		src.update_icon()

	pooled()
		..()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (src.broken)
			user.visible_message("<span class='alert'><b>[user] slashes [his_or_her(user)] own throat with [src]!</b></span>")
			blood_slash(user, 25)
			user.TakeDamage("head", 150, 0, 0, DAMAGE_CUT)
			SPAWN_DBG(50 SECONDS)
				if (user && !isdead(user))
					user.suiciding = 0
			return 1
		else return ..()

	proc/update_icon()
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
			else
				src.icon_state = "bottle-[src.bottle_style][src.alt_filled_state]"
				ENSURE_IMAGE(src.image_fluid, src.icon, "fluid-[src.fluid_style]")
				//if (!src.image_fluid)
					//src.image_fluid = image('icons/obj/foodNdrink/bottle.dmi')
				var/datum/color/average = reagents.get_average_color()
				image_fluid.color = average.to_rgba()
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
			// if (src.reagents.has_reagent("ice"))
				// ENSURE_IMAGE(src.image_ice, src.icon, "ice-[src.fluid_style]")
				// src.underlays += src.image_ice
		signal_event("icon_updated")

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/pen) && !src.labeled)
			var/t = input(user, "Enter label", "Label", src.name) as null|text
			t = copytext(strip_html(t), 1, 24)
			if (isnull(t) || !length(t) || t == " ")
				return
			if (!in_range(src, usr) && src.loc != usr)
				return

			src.name = t
			src.labeled = 1
		else
			..()
			return

	attack(target as mob, mob/user as mob)
		if (src.broken && !src.unbreakable)
			force = 5.0
			throwforce = 10.0
			throw_range = 5
			w_class = 2.0
			stamina_damage = 15
			stamina_cost = 15
			stamina_crit_chance = 50
			tooltip_rebuild = 1

			if (src.shatter >= rand(2,12))
				var/turf/U = user.loc
				user.visible_message("<span class='alert'>[src] shatters completely!</span>")
				playsound(U, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
				var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
				G.set_loc(U)
				qdel(src)
				if (prob (25))
					user.visible_message("<span class='alert'>The broken shards of [src] slice up [user]'s hand!</span>")
					playsound(U, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
					var/damage = rand(5,15)
					random_brute_damage(user, damage)
					take_bleeding_damage(user, damage)
			else
				src.shatter++
				user.visible_message("<span class='alert'><b>[user]</b> [pick("shanks","stabs","attacks")] [target] with the broken [src]!</span>")
				logTheThing("combat", user, target, "attacks [constructTarget(target,"combat")] with a broken [src] at [log_loc(user)].")
				playsound(target, "sound/impact_sounds/Flesh_Stab_1.ogg", 60, 1)
				var/damage = rand(1,10)
				random_brute_damage(target, damage)//shiv that nukie/secHoP
				take_bleeding_damage(target, damage)
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

		if (user.reagents && user.reagents.has_reagent("ethanol") && user.mind && user.mind.assigned_role == "Barman")
			success_prob = 75
			hurt_prob = 25

		else if (user.mind && user.mind.assigned_role == "Barman")
			success_prob = 50
			hurt_prob = 10

		else if (user.reagents && user.reagents.has_reagent("ethanol"))
			success_prob = 75
			hurt_prob = 75

		//have to do all this stuff anyway, so do it now
		playsound(U, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
		var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
		G.set_loc(U)

		if (src.reagents)
			src.reagents.reaction(U)

		DEBUG_MESSAGE("[src].smash_on_thing([user], [target]): success_prob [success_prob], hurt_prob [hurt_prob]")
		if (!src.broken && prob(success_prob))
			user.visible_message("<span class='alert'><b>[user] smashes [src] on [target], shattering it open![prob(50) ? " [user] looks like they're ready for a fight!" : " [src] has one mean edge on it!"]</span>")
			src.item_state = "broken_beer" // shattered beer inhand sprite
			user.update_inhands()
			src.broken = 1
			src.update_icon() // handles reagent holder stuff

		else
			user.visible_message("<span class='alert'><b>[user] smashes [src] on [target]! \The [src] shatters completely!</span>")
			if (prob(hurt_prob))
				user.visible_message("<span class='alert'>The broken shards of [src] slice up [user]'s hand!</span>")
				playsound(U, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
				random_brute_damage(user, damage)
				take_bleeding_damage(user, user, damage)
			SPAWN_DBG(0)
				qdel(src)

/* ========================================================== */
/* -------------------- Drinking Glasses -------------------- */
/* ========================================================== */

/obj/item/reagent_containers/food/drinks/drinkingglass
	name = "drinking glass"
	desc = "Caution - fragile."
	icon = 'icons/obj/foodNdrink/drinks.dmi'
	icon_state = "glass-drink"
	item_state = "drink_glass"
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	g_amt = 30
	var/glass_style = "drink"
	var/salted = 0
	var/obj/item/reagent_containers/food/snacks/plant/wedge = null
	var/obj/item/cocktail_stuff/drink_umbrella/umbrella = null
	var/obj/item/cocktail_stuff/in_glass = null
	initial_volume = 50
	var/smashed = 0
	var/shard_amt = 1

	var/image/fluid_image
	var/image/image_ice
	var/image/image_salt
	var/image/image_wedge
	var/image/image_doodad

	unpooled()
		..()
		src.salted = 0
		src.wedge = 0
		src.umbrella = 0
		src.in_glass = 0
		src.smashed = 0

	pooled()
		..()

	on_reagent_change()
		..()
		src.update_icon()

	proc/update_icon()
		if (src.reagents.total_volume <= 0)
			icon_state = "glass-[glass_style]"
			src.UpdateOverlays(null, "fluid")
		else
			icon_state = "glass-[glass_style]1"

			var/datum/color/average = reagents.get_average_color()
			if (!src.fluid_image)
				src.fluid_image = image(src.icon, "fluid-[glass_style]", layer = FLOAT_LAYER + 0.3)
			src.fluid_image.color = average.to_rgba()
			src.UpdateOverlays(src.fluid_image, "fluid")

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

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/raw_material/ice))
			if (src.reagents.total_volume >= (src.reagents.maximum_volume - 5))
				if (user.bioHolder.HasEffect("clumsy") && prob(50))
					user.visible_message("[user] adds [W] to [src].<br><span class='alert'>[src] is too full and spills!</span>",\
					"You add [W] to [src].<br><span class='alert'>[src] is too full and spills!</span>")
					src.reagents.reaction(get_turf(user), TOUCH, src.reagents.total_volume / 2)
					src.reagents.add_reagent("ice", 5, null, (T0C - 1))
					JOB_XP(user, "Clown", 1)
					pool(W)
					return
				else
					boutput(user, "<span class='alert'>[src] is too full!</span>")
				return
			else
				user.visible_message("[user] adds [W] to [src].",\
				"You add [W] to [src].")
				src.reagents.add_reagent("ice", 5, null, (T0C - 1))
				pool(W)
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
			src.update_icon()
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
			src.update_icon()
			return

		else if (istype(W, /obj/item/shaker/salt))
			var/obj/item/shaker/salt/S = W
			if (S.shakes >= 15)
				boutput(user, "<span class='alert'>There isn't enough salt in here to salt the rim!</span>")
				return
			else
				boutput(user, "<span class='notice'>You salt the rim of [src].</span>")
				src.salted = 1
				src.update_icon()
				S.shakes ++
				return

		else if (istype(W, /obj/item/reagent_containers) && W.is_open_container() && W.reagents.has_reagent("salt"))
			if (src.salted)
				return
			else if (W.reagents.get_reagent_amount("salt") >= 5)
				boutput(user, "<span class='notice'>You salt the rim of [src].</span>")
				W.reagents.remove_reagent("salt", 5)
				src.salted = 1
				src.update_icon()
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
		else if (!user && !usr) // buh?
			return ..()

		if (!ishuman(user))
			boutput(user, "<span class='notice'>You don't know what to do with the glass.</span>")
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
			choices += "remove [src.wedge] wedge"
			choices += "eat [src.wedge] wedge"
		if (!choices.len)
			boutput(user, "<span class='notice'>You can't think of anything to do with the glass.</span>")
			return

		var/selection = input(user, "What do you want to do with the glass?") as null|anything in choices
		if (isnull(selection) || get_dist(src, user) > 1)
			return

		var/obj/item/remove_thing
		var/obj/item/eat_thing

		if (selection == "pee in it")
			bladder = H.sims?.getValue("Bladder")
			if ((!isnull(bladder) && (bladder <= 65)) || (isnull(bladder) && (H.urine >= 2)))
				H.visible_message("<span class='alert'><B>[H] pees in [src]!</B></span>")
				playsound(get_turf(H), "sound/misc/pourdrink.ogg", 50, 1)
				if (!H.sims)
					H.urine -= 2
				else
					H.sims.affectMotive("Bladder", 100)
				src.reagents.add_reagent("urine", 20)
			else
				boutput(H, "<span class='alert'>You don't feel like you need to go.</span>")
			return

		else if (selection == "remove [src.in_glass]")
			remove_thing = src.in_glass
			src.in_glass = null

		else if (selection == "remove [src.wedge] wedge")
			remove_thing = src.wedge
			src.wedge = null

		else if (selection == "eat [src.in_glass]")
			eat_thing = src.in_glass
			src.in_glass = null

		else if (selection == "eat [src.wedge] wedge")
			eat_thing = src.wedge
			src.wedge = null

		if (remove_thing)
			H.visible_message("[H] removes [remove_thing] from [src].",\
			"<span class='notice'>You remove [remove_thing] from [src].</span>")
			H.put_in_hand_or_drop(remove_thing)
			src.update_icon()
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
			playsound(get_turf(H), "sound/items/eatfood.ogg", rand(10,50), 1)
			qdel(eat_thing)
			src.update_icon()
			return

	ex_act(severity)
		src.smash()

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
		if (src.reagents) // haine fix for cannot execute null.reaction()
			src.reagents.reaction(A)

		T.visible_message("<span class='alert'>[src] shatters!</span>")
		playsound(T, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
		for (var/i=src.shard_amt, i > 0, i--)
			var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
			G.set_loc(src.loc)
		if (src.in_glass)
			src.in_glass.set_loc(src.loc)
			src.in_glass = null
		if (src.wedge)
			src.wedge.set_loc(src.loc)
			src.wedge = null
		qdel(src)

	MouseDrop(atom/over_object)
		..()
		if(!(usr == over_object)) return
		if(!istype(usr, /mob/living/carbon)) return
		var/mob/living/carbon/C = usr

		var/maybe_too_clumsy = FALSE
		var/maybe_too_tipsy = FALSE
		var/too_drunk = FALSE
		if(C.bioHolder)
			maybe_too_clumsy = C.bioHolder.HasEffect("clumsy") && prob(50)
		if(C.reagents.reagent_list["ethanol"])
			maybe_too_tipsy = (C.reagents.reagent_list["ethanol"].volume >= 50) && prob(50)
			too_drunk = C.reagents.reagent_list["ethanol"].volume >= 150

		if(too_drunk || maybe_too_tipsy || maybe_too_clumsy)
			C.visible_message("[C.name] was too energetic, and threw the [src.name] backwards instead of chugging it!")
			src.set_loc(get_turf(C))
			C.u_equip(src)
			var/target = get_steps(C, turn(C.dir, 180), 7) //7 tiles seems appropriate.
			src.throw_at(target, 7, 1)
			if (!C.hasStatus("weakened"))
				//Make them fall over, they lost their balance.
				C.changeStatus("weakened", 2 SECONDS)
		else
			actions.start(new /datum/action/bar/icon/drinkingglass_chug(C, src), C)
		return

	throw_impact(var/atom/A)
		..()
		src.smash(A)

//this action accepts a target that is not the owner, incase we want to allow forced chugging.
/datum/action/bar/icon/drinkingglass_chug
	duration = 0.5 SECONDS
	id = "drinkingglass chugging"
	var/mob/glassholder
	var/mob/target
	var/obj/item/reagent_containers/food/drinks/drinkingglass/glass

	New(mob/Target, obj/item/reagent_containers/food/drinks/drinkingglass/Glass)
		target= Target
		glass = Glass
		icon = glass.icon
		icon_state = glass.icon_state
		return

	proc/checkContinue()
		if (glass.reagents.total_volume <= 0 || !isalive(glassholder) || !glassholder.find_in_hand(glass))
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
		logTheThing("combat", glassholder, target, "[glassholder == target ? "starts chugging from" : "makes [constructTarget(target,"combat")] chug from"] [glass] [log_reagents(glass)] at [log_loc(target)].")
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
			glass.reagents.reaction(target, INGEST, glass.gulp_size)
			glass.reagents.trans_to(target, min(glass.reagents.total_volume, glass.gulp_size))
			playsound(target.loc,"sound/items/drink.ogg", rand(10,50), 1)
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

/obj/item/reagent_containers/food/drinks/drinkingglass/random_style
	rand_pos = 1
	New()
		..()
		pick_style()

	unpooled()
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
		SPAWN_DBG(0)
			if (src.reagents)
				src.fill_it_up()

	unpooled()
		..()
		SPAWN_DBG(0)
			if (src.reagents)
				src.fill_it_up()

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
	var/image/fluid_image

	New()
		..()
		fluid_image = image(src.icon, "fluid-duo")
		update_icon()

	on_reagent_change()
		src.update_icon()

	proc/update_icon()
		src.overlays = null
		if (src.reagents.total_volume == 0)
			icon_state = "duo"
		if (src.reagents.total_volume > 0)
			var/datum/color/average = reagents.get_average_color()
			if (!fluid_image)
				fluid_image = image(src.icon, "fluid-duo")
			fluid_image.color = average.to_rgba()
			src.overlays += src.fluid_image

/* ============================================== */
/* -------------------- Misc -------------------- */
/* ============================================== */

/obj/item/reagent_containers/food/drinks/skull_chalice
	name = "skull chalice"
	desc = "A thing which you can drink fluids out of. Um. It's made from a skull. Considering how many holes are in skulls, this is perhaps a questionable design."
	icon_state = "skullchalice"
	item_state = "skullchalice"
	rc_flags = RC_SPECTRO

/obj/item/reagent_containers/food/drinks/mug
	name = "mug"
	desc = "A standard mug, for coffee or tea or whatever you wanna drink."
	icon_state = "mug"
	item_state = "mug"
	rc_flags = RC_SPECTRO

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

/obj/item/reagent_containers/food/drinks/mug/random_color
	New()
		..()
		src.color = random_saturated_hex_color(1)

/obj/item/reagent_containers/food/drinks/paper_cup
	name = "paper cup"
	desc = "A cup made of paper. It's not that complicated."
	icon_state = "paper_cup"
	item_state = "drink_glass"
	rc_flags = RC_SPECTRO
	initial_volume = 15

/obj/item/reagent_containers/food/drinks/espressocup
	name = "espresso cup"
	desc = "A fancy espresso cup, for sipping in the finest establishments." //*tip
	icon_state = "fancycoffee"
	item_state = "coffee"
	rc_flags = RC_SPECTRO | RC_FULLNESS | RC_VISIBLE //see _setup.dm
	initial_volume = 20
	gulp_size = 2.5
	g_amt = 2.5 //might be broken still, Whatever
	var/glass_style = "fancycoffee"

	var/image/fluid_image
	on_reagent_change()
		src.update_icon()

	proc/update_icon() //updates icon based on fluids inside
		src.overlays = null
		icon_state = "[glass_style]"

		var/datum/color/average = reagents.get_average_color()
		if (!src.fluid_image)
			src.fluid_image = image('icons/obj/foodNdrink/drinks.dmi', "fluid-[glass_style]", -1)
		src.fluid_image.color = average.to_rgba()
		src.overlays += src.fluid_image

/obj/item/reagent_containers/food/drinks/carafe
	name = "coffee carafe"
	desc = null
	icon_state = "carafe-eng"
	item_state = "carafe-eng"
	rc_flags = RC_SPECTRO | RC_FULLNESS | RC_VISIBLE
	initial_volume = 80
	var/smashed = 0
	var/shard_amt = 1
	var/image/fluid_image

	on_reagent_change()
		src.update_icon()

	proc/update_icon() //updates icon based on fluids inside
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
			var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
			G.set_loc(src.loc)
		qdel(src)

	throw_impact(var/atom/A)
		var/turf/T = get_turf(A)
		..()
		src.smash(T)

/obj/item/reagent_containers/food/drinks/carafe/attack(mob/M as mob, mob/user as mob)
	if (user.a_intent == INTENT_HARM)
		if (M == user)
			boutput(user, "<span class='alert'><B>You smash the [src] over your own head!</b></span>")
		else
			M.visible_message("<span class='alert'><B>[user] smashes [src] over [M]'s head!</B></span>")
			logTheThing("combat", user, M, "smashes [src] over [constructTarget(M,"combat")]'s head! ")
		M.TakeDamageAccountArmor("head", force, 0, 0, DAMAGE_BLUNT)
		M.changeStatus("weakened", 2 SECONDS)
		playsound(M, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
		var/obj/O = unpool(/obj/item/raw_material/shard/glass)
		O.set_loc(get_turf(M))
		if (src.material)
			O.setMaterial(copyMaterial(src.material))
		if (src.reagents)
			src.reagents.reaction(M)
			qdel(src)
		else
			M.visible_message("<span class='alert'>[user] taps [M] over the head with [src].</span>")
			logTheThing("combat", user, M, "taps [constructTarget(M,"combat")] over the head with [src].")

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

/obj/item/reagent_containers/food/drinks/coconut
	name = "Coconut"
	desc = "Must be migrational."
	icon = 'icons/obj/foodNdrink/drinks.dmi'
	icon_state = "coconut"
	item_state = "drink_glass"
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	g_amt = 30
	initial_volume = 50
	initial_reagents = list("coconut_milk"=20)

/obj/item/reagent_containers/food/drinks/energyshake
	name = "Brotien Shake - Dragon Balls flavor"
	desc = {"Do you want to get PUMPED UP? Try this 100% NATURAL shake FRESH from the press!
	We guarantee FULL ACTIVATION of midi-whatevers to EHNANCE your performance on and off the field.
	Embrace the STRENGTH and POWER of the dragon WITHIN YOU! Spread your newfound wings and ELEVATE your soul!
	When you are off on your long journey, who do you turn to? Brotien Shake's brand new flavor: DRAGON BALLS!"}
	icon_state = "energy"
	item_state = "drink_glass"
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	g_amt = 10
	initial_volume = 25
	initial_reagents = list("energydrink"=20)


/obj/item/reagent_containers/food/drinks/detflask
	name = "detective's flask"
	desc = "Must be migrational."
	icon = 'icons/obj/foodNdrink/bottle.dmi'
	icon_state = "detflask"
	item_state = "detflask"
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	g_amt = 5
	initial_volume = 40
	initial_reagents = list("bojack"=40)

/obj/item/reagent_containers/food/drinks/cocktailshaker
	name = "cocktail shaker"
	desc = "A stainless steel tumbler with a top, used to mix cocktails. Can hold up to 120 units."
	icon = 'icons/obj/foodNdrink/bottle.dmi'
	icon_state = "GannetsCocktailer"
	initial_volume = 120
	can_recycle = 0

	New()
		..()
		src.reagents.inert = 1

	attack_self(mob/user)
		if (src.reagents.total_volume > 0)
			user.visible_message("<b>[user.name]</b> shakes the container [pick("rapidly", "thoroughly", "carefully")].")
			playsound(get_turf(src), "sound/items/CocktailShake.ogg", 25, 1, -6)
			sleep (0.3 SECONDS)
			src.reagents.inert = 0
			src.reagents.handle_reactions()
			src.reagents.inert = 1
		else
			user.visible_message("<b>[user.name]</b> shakes the container, but it's empty!.")
