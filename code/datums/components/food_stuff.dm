/// handles various overrides regarding eating things, like making certain inedible things edible, or eaten organs restore health
/datum/component/consume
	var/static/list/flock_adjectives_1 = list("Syrupy", "Tangy", "Schlumpy", "Viscous", "Grumpy")
	var/static/list/flock_adjectives_2 = list("pulsating", "jiggling", "quivering", "flapping")
	var/static/list/flock_adjectives_3 = list("<span style=\"color: teal; font-family: Fixedsys, monospace;\"><i>teal</i></span>", "electric", "ferrofluid", "assimilatory")
TYPEINFO(/datum/component/consume)
	initialization_args = list()

/datum/component/consume/Initialize()
	. = ..()
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
	RegisterSignal(parent, COMSIG_MOB_ITEM_CONSUMED_PRE, PROC_REF(is_it_organs))

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
	RegisterSignal(parent, COMSIG_MOB_ITEM_CONSUMED, PROC_REF(eat_organ_get_points))

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
			boutput(L, SPAN_ALERT("<i>Agh!</i> That [I] was made of metal! <i>Metal!</i> Your entire body hates you for this."))
			return

	else if (istype(I, /obj/item/clothing/head/butt/cyberbutt))
		L.vomit()
		bleed(L, 5, 5)
		L.abilityHolder.deductPoints(2, target_abilityholder)
		boutput(L, SPAN_ALERT("<i>Agh!</i> That [I] was made of metal! <i>Metal!</i> Your entire body hates you for this."))
		return

	var/add_these_points = 0
	for(var/thing_i_ate in organ2points)
		if(istype(I, thing_i_ate))
			add_these_points = src.organ2points[thing_i_ate]
			switch(I.type)
				if (/obj/item/organ/head)
					boutput(M, "[SPAN_NOTICE("Tasty! While the hair on [I] was absolutely")] [SPAN_ALERT("<i>revolting</i>")][SPAN_NOTICE(", the headmeat within wasn't half bad.")]")
				if (/obj/item/skull)
					boutput(L, SPAN_ALERT("Ugh. Nothing but bone."))
					return
				if (/obj/item/skull/hunter)
					boutput(L, SPAN_ALERT("Ugh. Nothing but bone. Pretty spooky though."))
					return
				if (/obj/item/skull/wizard)
					playsound(L, 'sound/misc/meat_plop.ogg', 100, TRUE)
					L.visible_message(SPAN_ALERT("[M] vomits <i>everywhere</i>."), SPAN_ALERT("<b>UUAAAUGGHHH...</b> The wizard's skull was cursed."))
					L.emote("scream")
					L.changeStatus("unconscious", 10 SECONDS)
					L.abilityHolder.deductPoints(10, target_abilityholder)
					for (var/turf/T in range(L, rand(1, 3)))
						if (prob(20))
							make_cleanable( /obj/decal/cleanable/greenpuke,T)
						else
							make_cleanable( /obj/decal/cleanable/vomit,T)
					return
				if (/obj/item/skull/cluwne)
					L.vomit()
					L.abilityHolder.deductPoints(2, target_abilityholder)
					boutput(L, SPAN_ALERT("Eugh, that skull was so sickeningly <i>sweet</i>."))
					return
				if (/obj/item/skull/omnitraitor)
					add_these_points = 10
					L.emote("scream")
					L.changeStatus("unconscious", 30 SECONDS)
					boutput(L, "<span style=\"color: red; font-family: Fixedsys, monospace; text-align: center; vertical-align: top; -dm-text-outline: 1 black;\">YOU HAVE TASTED ALL THAT THE UNIVERSE HAS TO HOLD OF EVIL.</span>")
					SPAWN(rand(5 SECONDS, 10 SECONDS))
						L.vomit()
				if (/obj/item/skull/macho)
					L.emote("scream")
					L.changeStatus("knockdown", 10 SECONDS)
					boutput(L, SPAN_ALERT("The moment it reaches your stomach, the skull headbutts you right in the solar plexus! Oof..."))
					SPAWN(rand(1 SECOND, 3 SECONDS))
						L.emote(pick("groan", "moan"))
					return
				if (/obj/item/skull/changeling)
					add_these_points = 4
					boutput(L, SPAN_NOTICE("Delicious, with an oddly familiar aftertaste."))
					boutput(L, SPAN_NOTICE("You feel a slight wriggling in your gut."))
					SPAWN(rand(3 SECONDS, 10 SECONDS))
						boutput(L, SPAN_NOTICE("The wriggling passes."))
						L.emote("fart")
				if (/obj/item/organ/brain)
					boutput(L, SPAN_NOTICE("Delicious! The creamy, savory taste of [I] leaves you with a big dumb grin."))
				if (/obj/item/organ/brain/synth)
					boutput(L, SPAN_NOTICE("Not quite as tasty as a <i>real</i> brain, but it tastes a lot less... kuru-y."))
				if (/obj/item/organ/chest)
					boutput(L, SPAN_NOTICE("Bland, but there was a lot of it."))
				if (/obj/item/organ/heart)
					boutput(L, SPAN_NOTICE("Full of iron!"))
				if (/obj/item/organ/heart/synth)
					boutput(L, SPAN_NOTICE("Full of pharosium!"))
				if (/obj/item/organ/heart/flock)
					boutput(L, SPAN_NOTICE("Tastes like chicken. [pick(flock_adjectives_1)], [pick(flock_adjectives_2)], [pick(flock_adjectives_3)] chicken."))
				if (/obj/item/organ/appendix)
					boutput(L, SPAN_ALERT("Urgh, that tasted like a thumb made out of Discount Dan's."))
				if (/obj/item/clothing/head/butt)
					boutput(L, SPAN_ALERT("<i>Eugh</i>, you know <i>exactly</i> where that's been."))
					L.vomit()
			break

	if(!add_these_points && (istype(I, /obj/item/organ) || istype(I, /obj/item/clothing/head/butt/synth)))
		add_these_points = 1
		boutput(L, SPAN_NOTICE("That [I] wasn't half bad."))

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
	RegisterSignal(parent, COMSIG_MOB_ITEM_CONSUMED, PROC_REF(eat_organ_get_heal))

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
			boutput(M, SPAN_ALERT("<i>Augh!</i> That chewed-up [I] turned to shrapnel in your stomach!"))
			return
	else if (istype(I, /obj/item/clothing/head/butt/cyberbutt))
		M.vomit()
		bleed(M, 5, 5)
		M.TakeDamage("All", base_HPup * 2 * mod_mult, 0, base_HPup * 2 * mod_mult)
		boutput(M, SPAN_ALERT("<i>Augh!</i> That disgusting metal ass turned to shrapnel in your stomach!"))
		return

	for(var/thing_i_ate in organ2hp)
		if(istype(I, thing_i_ate))
			heal_this_much = src.organ2hp[thing_i_ate]
			switch(I.type)
				if (/obj/item/organ/head)
					boutput(M, "[SPAN_NOTICE("Tasty! While the hair on [I] was absolutely")] [SPAN_ALERT("<i>revolting</i>")][SPAN_NOTICE(", the headmeat within wasn't half bad.")]")
				if (/obj/item/skull)
					boutput(M, SPAN_ALERT("Ugh. Nothing but bone."))
				if (/obj/item/skull/hunter)
					boutput(M, SPAN_ALERT("Ugh. Nothing but bone. Pretty spooky though."))
				if (/obj/item/skull/wizard)
					playsound(M, 'sound/misc/meat_plop.ogg', 100, TRUE)
					M.visible_message(SPAN_ALERT("[M] vomits <i>everywhere</i>."), SPAN_ALERT("<b>UUAAAUGGHHH...</b> The wizard's skull was cursed."))
					M.emote("scream")
					M.changeStatus("unconscious", 10 SECONDS)
					for (var/turf/T in range(M, rand(1, 3)))
						if (prob(20))
							make_cleanable( /obj/decal/cleanable/greenpuke,T)
						else
							make_cleanable( /obj/decal/cleanable/vomit,T)
					return
				if (/obj/item/skull/cluwne)
					M.vomit()
					boutput(M, SPAN_ALERT("Eugh, that skull was so sickeningly <i>sweet</i>."))
				if (/obj/item/skull/omnitraitor)
					M.emote("scream")
					M.changeStatus("unconscious", 30 SECONDS)
					boutput(M, "<span style=\"color: red; font-family: Fixedsys, monospace; text-align: center; vertical-align: top; -dm-text-outline: 1 black;\">YOU HAVE TASTED ALL THAT THE UNIVERSE HAS TO HOLD OF EVIL.</span>")
					SPAWN(rand(5 SECONDS, 10 SECONDS))
						M.vomit()
					return
				if (/obj/item/skull/macho)
					M.emote("scream")
					M.changeStatus("knockdown", 10 SECONDS)
					boutput(M, SPAN_ALERT("The moment it reaches your stomach, the skull headbutts you right in the solar plexus! Oof..."))
					SPAWN(rand(1 SECOND, 3 SECONDS))
						M.emote(pick("groan", "moan"))
				if (/obj/item/skull/changeling)
					heal_this_much = base_HPup * 2
					boutput(M, SPAN_NOTICE("Delicious, with an oddly familiar aftertaste."))
					boutput(M, SPAN_NOTICE("You feel a slight wriggling in your gut."))
					SPAWN(rand(3 SECONDS, 10 SECONDS))
						boutput(M, SPAN_NOTICE("The wriggling passes."))
						M.emote("fart")
				if (/obj/item/organ/brain)
					boutput(M, SPAN_NOTICE("Delicious! The creamy, savory taste of [I] leaves you with a big dumb grin."))
				if (/obj/item/organ/brain/synth)
					boutput(M, SPAN_NOTICE("Not quite as tasty as a <i>real</i> brain, but it tastes a lot less... kuru-y."))
				if (/obj/item/organ/chest)
					boutput(M, SPAN_NOTICE("Bland, but there was a lot of it."))
				if (/obj/item/organ/heart)
					boutput(M, SPAN_NOTICE("Full of iron!"))
				if (/obj/item/organ/heart/synth)
					boutput(M, SPAN_NOTICE("Full of pharosium!"))
				if (/obj/item/organ/heart/flock)
					boutput(M, SPAN_NOTICE("Tastes like chicken. [pick(flock_adjectives_1)], [pick(flock_adjectives_2)], [pick(flock_adjectives_3)] chicken."))
				if (/obj/item/organ/appendix)
					boutput(M, SPAN_ALERT("Urgh, that tasted like a thumb made out of Discount Dan's."))
				if (/obj/item/clothing/head/butt)
					boutput(M, "[SPAN_ALERT("<i>Eugh</i>, you can <i>taste</i>")] [SPAN_NOTICE("where that's been. At least it's kind of meaty...")]")
			M.HealDamage("All", heal_this_much * mod_mult * 0.5, heal_this_much * mod_mult * 0.5)
			return

	if(istype(I, /obj/item/organ) || istype(I, /obj/item/clothing/head/butt/synth))
		M.HealDamage("All", base_HPup * mod_mult, base_HPup * mod_mult)
		boutput(M, SPAN_NOTICE("Mmmmm, tasty organs. How refreshing"))
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
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED), PROC_REF(apply_food_effects))

/datum/component/consume/food_effects/InheritComponent(datum/component/consume/food_effects/C, i_am_original, _new_status_effects)
	if(C?.status_effects)
		src.status_effects = C.status_effects


/datum/component/consume/food_effects/proc/apply_food_effects(var/obj/item/I, var/mob/M)
	if (src.status_effects.len && isliving(M) && M.bioHolder)
		var/mob/living/L = M
		for (var/effect in src.status_effects)
			L.add_food_bonus(effect, food_parent)

/datum/component/consume/food_effects/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED))
	. = ..()

/// Eating rocks

/datum/component/consume/can_eat_raw_materials
	var/can_eat_scrap = FALSE // Glass shards and metal scrap

TYPEINFO(/datum/component/consume/can_eat_raw_materials)
	initialization_args = list(
		ARG_INFO("can_eat_scrap", DATA_INPUT_BOOL, "If scrap is also valid food", FALSE)
	)
/datum/component/consume/can_eat_raw_materials/Initialize(var/can_eat_scrap)
	..()
	src.can_eat_scrap = can_eat_scrap
	RegisterSignal(parent, COMSIG_MOB_ITEM_CONSUMED_PRE, PROC_REF(is_a_raw_material))

/datum/component/consume/can_eat_raw_materials/proc/is_a_raw_material(var/mob/M, var/mob/user, var/obj/item/I)
	if (istype (I, /obj/item/raw_material) || (istype (I, /obj/item/raw_material/shard) || istype(I, /obj/item/raw_material/scrap_metal)) && can_eat_scrap)
		return FORCE_EDIBILITY
	else
		return FALSE

/datum/component/consume/can_eat_raw_materials/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_ITEM_CONSUMED_PRE)
	. = ..()
