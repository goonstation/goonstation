/// handles various overrides regarding eating things, like making certain inedible things edible, or eaten organs restore health
/// Also eating stuff in general

/// M = mob eating the thing
/// user = mob using the thing
/// I = thing being eaten -- only does anything on components with a mob parent

/* CONTENTS:
* Can-eat inedible organs          - mob parent  - pre-eat check            - (Can it eat heads too?)
* Eat-organ get-points             - mob parent  - post-eat all/part effect - (which abilityholder to give points to)
* Eat-organ get-healed             - mob parent  - post-eat all/part effect - (Multiplier against amount healed)
* Which utensils are needed        - item parent - pre-eat check            - (Which utensil bitflags to check)
* Eat-food get-healed              - item parent - post-eat all/part effect - (Amount to heal on nibble)
* Make things look partially eaten - item parent - post-eat all/part effect - (No vars)
* Add a food chunk when eaten      - item parent - post-eat all/part effect - (No vars)
* Status effects granted on nibble - item parent - post-eat all/part effect - (list of effects)
* Alter festivity on nibble        - item parent - post-eat all/part effect - (Amount to alter festivity)
* Drop and hand the eater an item  - item parent - post-eat all effect      - (Path of thing to drop)
* Unlock a medal when eaten        - item parent - post-eat all effect      - (Medal to unlock)
 */

/datum/component/consume
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/static/list/flock_adjectives_1 = list("Syrupy", "Tangy", "Schlumpy", "Viscous", "Grumpy")
	var/static/list/flock_adjectives_2 = list("pulsating", "jiggling", "quivering", "flapping")
	var/static/list/flock_adjectives_3 = list("</span><span style=\"color: teal; font-family: Fixedsys, monospace;\"><i>teal</i></span><span class='notice'>", "electric", "ferrofluid", "assimilatory")
/datum/component/consume/Initialize()
	if(!istype(parent, /atom))
		return COMPONENT_INCOMPATIBLE

/// These require a mob as the parent
/// Overrides inedibility when eating skulls and maybe heads
/datum/component/consume/can_eat_inedible_organs
	var/can_eat_heads = 0
/datum/component/consume/can_eat_inedible_organs/Initialize(var/can_eat_heads)
	if(!istype(parent, /mob))
		return COMPONENT_INCOMPATIBLE
	src.can_eat_heads = can_eat_heads
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PRE), .proc/is_it_organs)

/datum/component/consume/can_eat_inedible_organs/proc/is_it_organs(var/mob/M, var/mob/user, var/obj/item/I)
	if (istype(I, /obj/item/skull) || (istype(I, /obj/item/organ/head) && can_eat_heads)) // skulls, heads
		return THING_IS_EDIBLE
	else
		return 0

/datum/component/consume/can_eat_inedible_organs/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_CONSUMED_PRE)
	. = ..()


/// Gives points to a mob's abilityholder when eating some kind of organ
/datum/component/consume/organpoints
	var/target_abilityholder = /datum/abilityHolder/lizard
	var/static/list/organ2points = list(/obj/item/organ/head=4,/obj/item/skull=0,/obj/item/organ/brain=3,/obj/item/organ/chest=5,/obj/item/organ/heart=2,/obj/item/organ/appendix=0,/obj/item/clothing/head/butt=0)

/datum/component/consume/organpoints/Initialize(var/target_abilityholder)
	..()
	if(!istype(parent, /mob))
		return COMPONENT_INCOMPATIBLE
	src.target_abilityholder = target_abilityholder
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED_ALL), .proc/eat_organ_get_points)

/datum/component/consume/organpoints/proc/eat_organ_get_points(var/mob/M, var/mob/user, var/obj/item/I)
	if (!I || !M || !ishuman(M) || !user)
		return 0

	var/mob/living/carbon/human/L = M

	if (istype(I, /obj/item/organ))
		var/obj/item/organ/O = I
		if(O.robotic)
			L.vomit()
			bleed(L, 5, 5)
			L.abilityHolder.deductPoints(2, target_abilityholder)
			boutput(L, "<span class='alert'><i>Agh!</i> That [I] was made of metal! <i>Metal!</i> Your entire body hates you for this.</span>")
			return

	else if (istype(I, /obj/item/clothing/head/butt/cyberbutt))
		L.vomit()
		bleed(L, 5, 5)
		L.abilityHolder.deductPoints(2, target_abilityholder)
		boutput(L, "<span class='alert'><i>Agh!</i> That [I] was made of metal! <i>Metal!</i> Your entire body hates you for this.</span>")
		return

	var/add_these_points = 0
	for(var/thing_i_ate in organ2points)
		if(istype(I, thing_i_ate))
			add_these_points = src.organ2points[thing_i_ate]
			switch(I.type)
				if (/obj/item/organ/head)
					boutput(L, "<span class='notice'>Tasty! While the hair on [I] was absolutely </span><span class='alert'><i>revolting</i></span><span class='notice'>, the headmeat within wasn't half bad.</span>")
				if (/obj/item/skull)
					boutput(L, "<span class='alert'>Ugh. Nothing but bone.</span>")
					return
				if (/obj/item/skull/strange)
					boutput(L, "<span class='alert'>Ugh. Nothing but bone. Pretty spooky though.</span>")
					return
				if (/obj/item/skull/peculiar)
					playsound(L, "sound/misc/meat_plop.ogg", 100, 1)
					L.visible_message("<span class='alert'>[M] vomits <i>everywhere</i>.</span>", "<span class='alert'><b>UUAAAUGGHHH...</b> The wizard's skull was cursed.</span>")
					L.emote("scream")
					L.changeStatus("paralysis", 10 SECONDS)
					L.abilityHolder.deductPoints(10, target_abilityholder)
					for (var/turf/T in range(L, rand(1, 3)))
						if (prob(20))
							make_cleanable( /obj/decal/cleanable/greenpuke,T)
						else
							make_cleanable( /obj/decal/cleanable/vomit,T)
					return
				if (/obj/item/skull/noface)
					L.vomit()
					L.abilityHolder.deductPoints(2, target_abilityholder)
					boutput(L, "<span class='alert'>Eugh, that skull was so sickeningly <i>sweet</i>.</span>")
					return
				if (/obj/item/skull/crystal)
					add_these_points = 10
					L.emote("scream")
					L.changeStatus("paralysis", 30 SECONDS)
					boutput(L, "<span style=\"color: red; font-family: Fixedsys, monospace; text-align: center; vertical-align: top; -dm-text-outline: 1 black;\">YOU HAVE TASTED ALL THAT THE UNIVERSE HAS TO HOLD OF EVIL.</span>")
					SPAWN_DBG(rand(5 SECONDS, 10 SECONDS))
						L.vomit()
				if (/obj/item/skull/gold)
					L.emote("scream")
					L.changeStatus("weakened", 10 SECONDS)
					boutput(L, "<span class='alert'>The moment it reaches your stomach, the skull headbutts you right in the solar plexus! Oof...</span>")
					SPAWN_DBG(rand(1 SECOND, 3 SECONDS))
						L.emote(pick("groan", "moan"))
					return
				if (/obj/item/skull/odd)
					add_these_points = 4
					boutput(L, "<span class='notice'>Delicious, with an oddly familiar aftertaste.</span>")
					boutput(L, "<span class='notice'>You feel a slight wriggling in your gut.</span>")
					SPAWN_DBG(rand(3 SECONDS, 10 SECONDS))
						boutput(L, "<span class='notice'>The wriggling passes.</span>")
						L.emote("fart")
				if (/obj/item/organ/brain)
					boutput(L, "<span class='notice'>Delicious! The creamy, savory taste of [I] leaves you with a big dumb grin.</span>")
				if (/obj/item/organ/brain/synth)
					boutput(L, "<span class='notice'>Not quite as tasty as a <i>real</i> brain, but it tastes a lot less... kuru-y.</span>")
				if (/obj/item/organ/chest)
					boutput(L, "<span class='notice'>Bland, but there was a lot of it.</span>")
				if (/obj/item/organ/heart)
					boutput(L, "<span class='notice'>Full of iron!</span>")
				if (/obj/item/organ/heart/synth)
					boutput(L, "<span class='notice'>Full of pharosium!</span>")
				if (/obj/item/organ/heart/flock)
					boutput(L, "<span class='notice'>Tastes like chicken. [pick(flock_adjectives_1)], [pick(flock_adjectives_2)], [pick(flock_adjectives_3)] chicken.</span>")
				if (/obj/item/organ/appendix)
					boutput(L, "<span class='alert'>Urgh, that tasted like a thumb made out of Discount Dan's.</span>")
				if (/obj/item/clothing/head/butt)
					boutput(L, "<span class='alert'><i>Eugh</i>, you know <i>exactly</i> where that's been.</span>")
					L.vomit()
			break

	if(!add_these_points && (istype(I, /obj/item/organ) || istype(I, /obj/item/clothing/head/butt/synth)))
		add_these_points = 1
		boutput(L, "<span class='notice'>That [I] wasn't half bad.</span>")

	if(add_these_points)
		if(prob(30 * add_these_points))
			L.abilityHolder.addPoints(add_these_points, target_abilityholder)
		else
			boutput(L, "<span class='alert'>...that wasn't particularly satisfying, though.</span>")

/datum/component/consume/organpoints/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED_ALL))
	. = ..()

/// Heals the mob when they eat organs
/datum/component/consume/organheal
	var/static/list/organ2hp = list(/obj/item/organ/head=10,/obj/item/skull=0,/obj/item/organ/brain=20,/obj/item/organ/chest=30,/obj/item/organ/heart=20,/obj/item/organ/appendix=0,/obj/item/clothing/head/butt=6)
	var/base_HPup = 5
	var/mod_mult = 1

/datum/component/consume/organheal/Initialize(var/mod_mult)
	..()
	if(!istype(parent, /mob))
		return COMPONENT_INCOMPATIBLE
	src.mod_mult = mod_mult
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED_ALL), .proc/eat_organ_get_heal)

/datum/component/consume/organheal/proc/eat_organ_get_heal(var/mob/M, var/mob/user, var/obj/item/I)
	if (!I || !M || !user)
		return 0

	var/heal_this_much = 0

	if (istype(I, /obj/item/organ))
		var/obj/item/organ/O = I
		if(O.robotic)
			M.vomit()
			bleed(M, 5, 5)
			M.TakeDamage("All", base_HPup * mod_mult, 0, base_HPup * mod_mult)
			boutput(M, "<span class='alert'><i>Augh!</i> That chewed-up [I] turned to shrapnel in your stomach!</span>")
			return
	else if (istype(I, /obj/item/clothing/head/butt/cyberbutt))
		M.vomit()
		bleed(M, 5, 5)
		M.TakeDamage("All", base_HPup * 2 * mod_mult, 0, base_HPup * 2 * mod_mult)
		boutput(M, "<span class='alert'><i>Augh!</i> That disgusting metal ass turned to shrapnel in your stomach!</span>")
		return

	for(var/thing_i_ate in organ2hp)
		if(istype(I, thing_i_ate))
			heal_this_much = src.organ2hp[thing_i_ate]
			switch(I.type)
				if (/obj/item/organ/head)
					boutput(M, "<span class='notice'>Tasty! While the hair on [I] was absolutely </span><span class='alert'><i>revolting</i></span><span class='notice'>, the headmeat within wasn't half bad.</span>")
				if (/obj/item/skull)
					boutput(M, "<span class='alert'>Ugh. Nothing but bone.</span>")
				if (/obj/item/skull/strange)
					boutput(M, "<span class='alert'>Ugh. Nothing but bone. Pretty spooky though.</span>")
				if (/obj/item/skull/peculiar)
					playsound(M, "sound/misc/meat_plop.ogg", 100, 1)
					M.visible_message("<span class='alert'>[M] vomits <i>everywhere</i>.</span>", "<span class='alert'><b>UUAAAUGGHHH...</b> The wizard's skull was cursed.</span>")
					M.emote("scream")
					M.changeStatus("paralysis", 10 SECONDS)
					for (var/turf/T in range(M, rand(1, 3)))
						if (prob(20))
							make_cleanable( /obj/decal/cleanable/greenpuke,T)
						else
							make_cleanable( /obj/decal/cleanable/vomit,T)
					return
				if (/obj/item/skull/noface)
					M.vomit()
					boutput(M, "<span class='alert'>Eugh, that skull was so sickeningly <i>sweet</i>.</span>")
				if (/obj/item/skull/crystal)
					M.emote("scream")
					M.changeStatus("paralysis", 30 SECONDS)
					boutput(M, "<span style=\"color: red; font-family: Fixedsys, monospace; text-align: center; vertical-align: top; -dm-text-outline: 1 black;\">YOU HAVE TASTED ALL THAT THE UNIVERSE HAS TO HOLD OF EVIL.</span>")
					SPAWN_DBG(rand(5 SECONDS, 10 SECONDS))
						M.vomit()
					return
				if (/obj/item/skull/gold)
					M.emote("scream")
					M.changeStatus("weakened", 10 SECONDS)
					boutput(M, "<span class='alert'>The moment it reaches your stomach, the skull headbutts you right in the solar plexus! Oof...</span>")
					SPAWN_DBG(rand(1 SECOND, 3 SECONDS))
						M.emote(pick("groan", "moan"))
				if (/obj/item/skull/odd)
					heal_this_much = base_HPup * 2
					boutput(M, "<span class='notice'>Delicious, with an oddly familiar aftertaste.</span>")
					boutput(M, "<span class='notice'>You feel a slight wriggling in your gut.</span>")
					SPAWN_DBG(rand(3 SECONDS, 10 SECONDS))
						boutput(M, "<span class='notice'>The wriggling passes.</span>")
						M.emote("fart")
				if (/obj/item/organ/brain)
					boutput(M, "<span class='notice'>Delicious! The creamy, savory taste of [I] leaves you with a big dumb grin.</span>")
				if (/obj/item/organ/brain/synth)
					boutput(M, "<span class='notice'>Not quite as tasty as a <i>real</i> brain, but it tastes a lot less... kuru-y.</span>")
				if (/obj/item/organ/chest)
					boutput(M, "<span class='notice'>Bland, but there was a lot of it.</span>")
				if (/obj/item/organ/heart)
					boutput(M, "<span class='notice'>Full of iron!</span>")
				if (/obj/item/organ/heart/synth)
					boutput(M, "<span class='notice'>Full of pharosium!</span>")
				if (/obj/item/organ/heart/flock)
					boutput(M, "<span class='notice'>Tastes like chicken. [pick(flock_adjectives_1)], [pick(flock_adjectives_2)], [pick(flock_adjectives_3)] chicken.</span>")
				if (/obj/item/organ/appendix)
					boutput(M, "<span class='alert'>Urgh, that tasted like a thumb made out of Discount Dan's.</span>")
				if (/obj/item/clothing/head/butt)
					boutput(M, "<span class='alert'><i>Eugh</i>, you can </span><span class='alert'><i>taste</i></span><span class='notice'> where that's been. At least it's kind of meaty...</span>")
			M.HealDamage("All", heal_this_much * mod_mult * 0.5, heal_this_much * mod_mult * 0.5)
			return

	if(istype(I, /obj/item/organ) || istype(I, /obj/item/clothing/head/butt/synth))
		M.HealDamage("All", base_HPup * mod_mult, base_HPup * mod_mult)
		boutput(M, "<span class='notice'>Mmmmm, tasty organs. How refreshing</span>")
	return


/datum/component/consume/organheal/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED_ALL))
	. = ..()

/// Makes it need a utensil
/datum/component/consume/need_utensil
	var/obj/item/food_parent
	var/utensils_needed = 0

/datum/component/consume/need_utensil/Initialize(var/utensil_bitmask)
	..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	src.food_parent = parent
	src.utensils_needed = utensil_bitmask
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PRE), .proc/utensil_check)

/datum/component/consume/need_utensil/proc/utensil_check(var/obj/item/I, var/mob/M, var/mob/user)
	if ((iscarbon(M) || ismobcritter(M)) && M == user)
		var/remaining_flags = src.utensils_needed

		if (HAS_FLAG(remaining_flags, EATING_NEEDS_A_FORK))
			var/obj/item/kitchen/utensil/fork/Y = user.find_type_in_hand(/obj/item/kitchen/utensil/fork)
			if(prob(20) && istype(Y, /obj/item/kitchen/utensil/fork/plastic))
				Y.break_utensil(user)
			if(istype(Y))
				REMOVE_FLAG(remaining_flags, EATING_NEEDS_A_FORK)

		if (HAS_FLAG(remaining_flags, EATING_NEEDS_A_SPOON))
			var/obj/item/kitchen/utensil/spoon/P = user.find_type_in_hand(/obj/item/kitchen/utensil/spoon)
			if(prob(20) && istype(P, /obj/item/kitchen/utensil/spoon/plastic))
				P.break_utensil(user)
			if(istype(P))
				REMOVE_FLAG(remaining_flags, EATING_NEEDS_A_SPOON)

		return remaining_flags

/datum/component/consume/need_utensil/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_CONSUMED_PRE)
	. = ..()

/// Makes the food heal you every bite
/datum/component/consume/foodheal
	var/obj/item/food_parent
	var/base_heal = 1

/datum/component/consume/foodheal/Initialize(var/_base_heal)
	..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	src.food_parent = parent
	src.base_heal = _base_heal
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED_ALL, COMSIG_ITEM_CONSUMED_PARTIAL), .proc/eat_stuff_get_heal)

/datum/component/consume/foodheal/InheritComponent(datum/component/consume/foodheal/C, i_am_original, _new_base_heal)
	if(C?.base_heal)
		src.base_heal = C.base_heal
	else
		if (isnum_safe(_new_base_heal)) // C(duplicate component) wasn't initialized, so we don't know if the raw argument _new_base_heal is actually a number
			src.base_heal = _new_base_heal

/datum/component/consume/foodheal/proc/eat_stuff_get_heal(var/obj/item/I, var/obj/item/I, var/mob/M)
	var/healing = src.base_heal

	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (H.sims)
			H.sims.affectMotive("Hunger", base_heal * 2)
			H.sims.affectMotive("Bladder", -base_heal * 0.2)

	if (food_parent.quality >= 5)
		boutput(M, "<span class='notice'>That tasted amazing!</span>")
		healing *= 2

	if (food_parent.reagents && food_parent.reagents.has_reagent("THC"))
		boutput(M, "<span class='notice'>Wow this tastes really good man!!</span>")
		healing *= 2


	if (food_parent.quality <= 0.5)
		boutput(M, "<span class='alert'>Ugh! That tasted horrible!</span>")
		if (prob(20) && isliving(M))
			var/mob/living/L = M
			L.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1) // path, name, strain, bypass resist
		healing = 0

	M.nutrition += healing * 10
	var/cutOff = round(M.max_health / 1.8) // 100 / 1.8 is about 55.555...6 so this should work out to be around the original value of 55 for humans and the equivalent for mobs with different max_health
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (H.traitHolder && H.traitHolder.hasTrait("survivalist"))
			cutOff = round(H.max_health / 10) // originally 10

	if (M.health < cutOff)
		boutput(M, "<span class='alert'>Your injuries are too severe to heal by nourishment alone!</span>")
	else
		M.HealDamage("All", healing, healing)

/datum/component/consume/foodheal/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED_ALL))
	. = ..()

/// Makes thing look like it had some bites taken out of it
/datum/component/consume/bitemask
	var/obj/item/food_parent
	var/start_amount = 1
	var/current_mask = 5
	var/list/original_filters = list()
	var/desired_mask = 5

/datum/component/consume/bitemask/Initialize()
	..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	src.food_parent = parent
	src.start_amount = food_parent.amount
	src.original_filters = food_parent.filters
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL), .proc/apply_bitemask)

/datum/component/consume/bitemask/proc/apply_bitemask()
	if(istype(src.food_parent, /obj/item/organ))
		var/obj/item/organ/O = src.food_parent
		var/damorg = max(O.MAX_DAMAGE - O.get_damage(), 1)
		desired_mask = (damorg / O.MAX_DAMAGE) * 5
	else
		desired_mask = (food_parent.amount / src.start_amount) * 5
	desired_mask = round(desired_mask)
	desired_mask = clamp(desired_mask, 1, 5)
	if (desired_mask != current_mask)
		current_mask = desired_mask
		food_parent.filters = list(filter(type="alpha", icon=icon('icons/obj/foodNdrink/food.dmi', "eating[desired_mask]")))

/datum/component/consume/bitemask/UnregisterFromParent()
	food_parent?.filters = src.original_filters
	UnregisterSignal(parent, COMSIG_ITEM_CONSUMED_PARTIAL)
	. = ..()

/// Puts partially digested chunks in your mob
/datum/component/consume/food_chunk
	var/obj/item/food_parent

/datum/component/consume/food_chunk/Initialize()
	..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	src.food_parent = parent
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED_ALL), .proc/make_food_chunk)

/datum/component/consume/food_chunk/proc/make_food_chunk(var/obj/item/I, var/mob/M)
	if (isliving(M))
		if (food_parent.reagents && food_parent.reagents.total_volume) //only create food chunks for reagents
			var/obj/item/reagent_containers/food/snacks/bite/B = unpool(/obj/item/reagent_containers/food/snacks/bite)
			B.set_loc(M)
			B.reagents.maximum_volume = food_parent.reagents.total_volume/(food_parent.amount ? food_parent.amount : 1) //MBC : I copied this from the Eat proc. It doesn't really handle the reagent transfer evenly??
			food_parent.reagents.trans_to(B,B.reagents.maximum_volume,1,0)						//i'll leave it tho because i dont wanna mess anything up
			var/mob/living/L = M
			L.stomach_process += B

/datum/component/consume/food_chunk/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED_ALL))
	. = ..()

/// Applies some status effects when eaten
/datum/component/consume/food_effects
	var/obj/item/food_parent
	var/list/status_effects = list()

/datum/component/consume/food_effects/Initialize(var/list/_status_effects)
	..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	src.food_parent = parent
	src.status_effects = _status_effects
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED_ALL), .proc/apply_food_effects)

/datum/component/consume/food_effects/InheritComponent(datum/component/consume/food_effects/C, i_am_original, _new_status_effects)
	if(C?.status_effects)
		src.status_effects = C.status_effects
	else
		if (islist(_new_status_effects)) // C(duplicate component) wasn't initialized, so we don't know if the raw argument _new_status_effects is a string / list
			src.status_effects |= _new_status_effects
		else if(istext(_new_status_effects))
			var/list/new_sfx = list(_new_status_effects)
			src.status_effects |= new_sfx


/datum/component/consume/food_effects/proc/apply_food_effects(var/obj/item/I, var/mob/M)
	if (src.status_effects.len && isliving(M) && M.bioHolder)
		var/mob/living/L = M
		for (var/effect in src.status_effects)
			L.add_food_bonus(effect, food_parent)

/datum/component/consume/food_effects/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED_ALL))
	. = ..()

/// Alters spacefestivity when eaten
/datum/component/consume/festive_food
	var/obj/item/food_parent
	var/festiveness = 1

/datum/component/consume/festive_food/Initialize(var/_festiveness)
	..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	src.food_parent = parent
	src.festiveness = _festiveness
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED_ALL), .proc/alter_festivity)

/datum/component/consume/festive_food/InheritComponent(datum/component/consume/festive_food/C, i_am_original, _new_festivity)
	if(C?.festiveness)
		src.festiveness = C.festiveness
	else
		if (isnum_safe(_new_festivity))
			src.festiveness = _new_festivity

/datum/component/consume/festive_food/proc/alter_festivity(var/obj/item/I, var/mob/M)
	if (src.festiveness)
		modify_christmas_cheer(src.festiveness)

/datum/component/consume/festive_food/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED_ALL))
	. = ..()

/// Drops a thing when eaten and tries to force it into your hand
/datum/component/consume/drop_on_eaten
	var/obj/item/food_parent
	var/obj/item/thing_to_drop
	var/festiveness = 1

/datum/component/consume/drop_on_eaten/Initialize(var/obj/thing_to_drop)
	..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	src.food_parent = parent
	if(istype(thing_to_drop))
		src.thing_to_drop = thing_to_drop.type
	else if(ispath(thing_to_drop))
		src.thing_to_drop = thing_to_drop
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED_ALL), .proc/drop_thing)

/datum/component/consume/drop_on_eaten/InheritComponent(datum/component/consume/drop_on_eaten/C, i_am_original, var/obj/item/_new_thing)
	if(C?.thing_to_drop)
		src.thing_to_drop = C.thing_to_drop
	else
		if(istype(_new_thing))
			src.thing_to_drop = _new_thing.type
		else if(ispath(_new_thing))
			src.thing_to_drop = _new_thing

/datum/component/consume/drop_on_eaten/proc/drop_thing(var/obj/item/I, var/mob/M, var/mob/user)
	var/obj/item/drop = new thing_to_drop
	if(istype(drop))
		drop.pixel_x = food_parent.pixel_x
		drop.pixel_y = food_parent.pixel_y
		var/obj/item/R = drop
		if(istype(R) && ismob(user))
			var/item_slot = user.get_slot_from_item(food_parent)
			if(item_slot)
				user.u_equip(food_parent)
				food_parent.set_loc(null)
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					H.force_equip(R,item_slot) // mobs don't have force_equip
					return
		drop.set_loc(get_turf(food_parent.loc))

/datum/component/consume/drop_on_eaten/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_CONSUMED_ALL)
	. = ..()

/// Unlocks some kind of medal when eaten
/datum/component/consume/unlock_medal_on_eaten
	var/obj/item/food_parent
	var/medal

/datum/component/consume/unlock_medal_on_eaten/Initialize(var/_medal)
	..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	src.food_parent = parent
	src.medal = _medal
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED_ALL), .proc/give_medal)

/datum/component/consume/unlock_medal_on_eaten/InheritComponent(datum/component/consume/unlock_medal_on_eaten/C, i_am_original, _new_medal)
	if(C?.medal)
		src.medal = C.medal
	else
		if (_new_medal)
			src.medal = _new_medal

/datum/component/consume/unlock_medal_on_eaten/proc/give_medal(var/obj/item/I, var/mob/M)
	M.unlock_medal(src.medal, 1)

/datum/component/consume/unlock_medal_on_eaten/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_CONSUMED_ALL)
	. = ..()
