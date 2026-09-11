/datum/component/tameable
	var/list/signals = list()
	var/mob/living/critter/owner = null
	var/obj/item/reagent_containers/food/treat = /obj/item/reagent_containers/food/snacks
	var/tame_chance = 20
	var/emote_happy = null // live critter reactions
	var/emote_angry = null
	var/toggle_behavours = null // for a behaviour that turns on and off on petting

/datum/component/tameable/Initialize(atom/target)
	. = ..()
	if(!istype(src.parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	src.owner = parent
	RegisterSignal(parent, COMSIG_ATTACKBY, PROC_REF(pass_on_attackby))
	RegisterSignal(parent, COMSIG_ATTACKHAND, PROC_REF(pass_on_attackhand))

/datum/component/tameable/proc/pass_on_attackby(atom/movable/parent, obj/item/item, mob/user, params)
	if(istype(item, /obj/item/reagent_containers/food/snacks) && ishuman(user) && !isdead(owner))
		owner.visible_message("[user] feeds \the [owner] some [item].", "[user] feeds you some [item].")
		for(var/damage_type in owner.healthlist)
			var/datum/healthHolder/hh = owner.healthlist[damage_type]
			hh.HealDamage(5)
		owner.health_brute = min(60, owner.health_brute + 6)
		owner.health_burn = min(60, owner.health_burn + 6)
		item.Eat(owner, owner, TRUE)
		if(user in owner.friends)
			owner.emote(emote_happy)
		else
			if(prob(tame_chance) && istype(item, treat))
				owner.friends += user
				owner.tamed = TRUE
				owner.visible_message("[owner] with a [emote_happy] happily eats up the \the [item], and seems a little friendlier with [user].")
				owner.emote(emote_happy)
			else
				owner.visible_message(SPAN_NOTICE("[owner] hated \the [item] and bit [user]'s hand!"))
				random_brute_damage(user, rand(6,12),1)
				owner.emote(emote_angry)
				user.emote("scream")
		return

/datum/component/tameable/proc/pass_on_attackhand(atom/source, mob/M)
	if ((M.a_intent != INTENT_HARM) && (M in owner.friends))
		if(M.a_intent == INTENT_HELP && owner.aggressive)
			owner.visible_message(SPAN_NOTICE("[M] pats [owner] on the head in a soothing way. It won't attack anyone now."))
			owner.aggressive = FALSE
			owner.ai_retaliates = FALSE
			return
		else if((M.a_intent == INTENT_DISARM) && !owner.aggressive)
			owner.visible_message(SPAN_NOTICE("[M] shakes [owner] to awaken [his_or_her(owner)] killer instincts!"))
			owner.aggressive = TRUE
			owner.ai_retaliates = TRUE
			return
