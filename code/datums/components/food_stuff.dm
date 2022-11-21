/// handles various overrides regarding eating things, like making certain inedible things edible, or eaten organs restore health
/datum/component/consume
	var/static/list/flock_adjectives_1 = list("Syrupy", "Tangy", "Schlumpy", "Viscous", "Grumpy")
	var/static/list/flock_adjectives_2 = list("pulsating", "jiggling", "quivering", "flapping")
	var/static/list/flock_adjectives_3 = list("</span><span style=\"color: teal; font-family: Fixedsys, monospace;\"><i>teal</i></span><span class='notice'>", "electric", "ferrofluid", "assimilatory")
TYPEINFO(/datum/component/consume)
	initialization_args = list()

/datum/component/consume/Initialize()
	if(!istype(parent, /mob))
		return COMPONENT_INCOMPATIBLE

/datum/component/consume/can_eat_inedible_organs
	var/can_eat_heads = 0

TYPEINFO(/datum/component/consume/can_eat_inedible_organs)
	initialization_args = list(
		ARG_INFO("can_eat_heads", DATA_INPUT_BOOL, "If heads are also valid food", FALSE)
	)
/datum/component/consume/can_eat_inedible_organs/Initialize(var/can_eat_heads)
	..()
	src.can_eat_heads = can_eat_heads
	RegisterSignal(parent, COMSIG_MOB_ITEM_CONSUMED_PRE, .proc/is_it_organs)

/datum/component/consume/can_eat_inedible_organs/proc/is_it_organs(var/mob/M, var/mob/user, var/obj/item/I)
	if (istype(I, /obj/item/skull) || (istype(I, /obj/item/organ/head) && can_eat_heads)) // skulls, heads
		return FORCE_EDIBILITY
	else
		return 0

/datum/component/consume/can_eat_inedible_organs/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_ITEM_CONSUMED_PRE)
	. = ..()

/datum/component/consume/organpoints
	var/target_abilityholder = /datum/abilityHolder/lizard
	var/static/list/organ2points = list(/obj/item/organ/head=2,/obj/item/skull=0,/obj/item/organ/brain=3,/obj/item/organ/chest=5,/obj/item/organ/heart=2,/obj/item/organ/appendix=0,/obj/item/clothing/head/butt=0)

TYPEINFO(/datum/component/consume/organpoints)
	initialization_args = list(
		ARG_INFO("target_abilityholder", DATA_INPUT_REF, "Abilityholder to handle points for")
	)
/datum/component/consume/organpoints/Initialize(var/target_abilityholder)
	..()
	src.target_abilityholder = target_abilityholder
	RegisterSignal(parent, COMSIG_MOB_ITEM_CONSUMED, .proc/eat_organ_get_points)

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
					playsound(L, 'sound/misc/meat_plop.ogg', 100, 1)
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
					SPAWN(rand(5 SECONDS, 10 SECONDS))
						L.vomit()
				if (/obj/item/skull/gold)
					L.emote("scream")
					L.changeStatus("weakened", 10 SECONDS)
					boutput(L, "<span class='alert'>The moment it reaches your stomach, the skull headbutts you right in the solar plexus! Oof...</span>")
					SPAWN(rand(1 SECOND, 3 SECONDS))
						L.emote(pick("groan", "moan"))
					return
				if (/obj/item/skull/odd)
					add_these_points = 4
					boutput(L, "<span class='notice'>Delicious, with an oddly familiar aftertaste.</span>")
					boutput(L, "<span class='notice'>You feel a slight wriggling in your gut.</span>")
					SPAWN(rand(3 SECONDS, 10 SECONDS))
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
		L.abilityHolder.addPoints(add_these_points, target_abilityholder)

/datum/component/consume/organpoints/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_ITEM_CONSUMED)
	. = ..()


/datum/component/consume/organheal
	var/static/list/organ2hp = list(/obj/item/organ/head=20,/obj/item/skull=0,/obj/item/organ/brain=30,/obj/item/organ/chest=30,/obj/item/organ/heart=20,/obj/item/organ/appendix=0,/obj/item/clothing/head/butt=6)
	var/base_HPup = 5
	var/mod_mult = 1

TYPEINFO(/datum/component/consume/organheal)
	initialization_args = list(
		ARG_INFO("mod_mult", DATA_INPUT_NUM, "healing multiplier", 1)
	)
/datum/component/consume/organheal/Initialize(var/mod_mult)
	..()
	src.mod_mult = mod_mult
	RegisterSignal(parent, COMSIG_MOB_ITEM_CONSUMED, .proc/eat_organ_get_heal)

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
					playsound(M, 'sound/misc/meat_plop.ogg', 100, 1)
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
					SPAWN(rand(5 SECONDS, 10 SECONDS))
						M.vomit()
					return
				if (/obj/item/skull/gold)
					M.emote("scream")
					M.changeStatus("weakened", 10 SECONDS)
					boutput(M, "<span class='alert'>The moment it reaches your stomach, the skull headbutts you right in the solar plexus! Oof...</span>")
					SPAWN(rand(1 SECOND, 3 SECONDS))
						M.emote(pick("groan", "moan"))
				if (/obj/item/skull/odd)
					heal_this_much = base_HPup * 2
					boutput(M, "<span class='notice'>Delicious, with an oddly familiar aftertaste.</span>")
					boutput(M, "<span class='notice'>You feel a slight wriggling in your gut.</span>")
					SPAWN(rand(3 SECONDS, 10 SECONDS))
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
	UnregisterSignal(parent, COMSIG_MOB_ITEM_CONSUMED)
	. = ..()


/// Applies some status effects when eaten
/datum/component/consume/food_effects
	var/obj/item/food_parent
	var/list/status_effects = list()

TYPEINFO(/datum/component/consume/food_effects)
	initialization_args = list(
		ARG_INFO("status_effects", DATA_INPUT_LIST_BUILD, "List of status effects to apply when eaten")
	)
/datum/component/consume/food_effects/Initialize(var/list/_status_effects)
	..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	src.food_parent = parent
	src.status_effects = _status_effects
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED), .proc/apply_food_effects)

/datum/component/consume/food_effects/InheritComponent(datum/component/consume/food_effects/C, i_am_original, _new_status_effects)
	if(C?.status_effects)
		src.status_effects = C.status_effects
		boutput(world, "[C] was already init'd. heal amt on it was [C.status_effects] is now [src.status_effects], supposed to be [_new_status_effects]")
	else
		if (islist(_new_status_effects)) // C(duplicate component) wasn't initialized, so we don't know if the raw argument _new_status_effects is a string / list
			src.status_effects |= _new_status_effects
			boutput(world, "[_new_status_effects] was list. [src.status_effects]")
		else if(istext(_new_status_effects))
			var/list/new_sfx = list(_new_status_effects)
			src.status_effects |= new_sfx
			boutput(world, "[_new_status_effects] not list. [src.status_effects]")


/datum/component/consume/food_effects/proc/apply_food_effects(var/obj/item/I, var/mob/M)
	if (src.status_effects.len && isliving(M) && M.bioHolder)
		var/mob/living/L = M
		for (var/effect in src.status_effects)
			L.add_food_bonus(effect, food_parent)

/datum/component/consume/food_effects/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED))
	. = ..()
