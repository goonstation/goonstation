/// If a creature is to be tameable, slap this component on it.
TYPEINFO(/datum/component/tameable)
	initialization_args = list(
		ARG_INFO("taming_foods", DATA_INPUT_LIST_VAR, "Type of food to tame this critter", list(/obj/item/reagent_containers/food/snacks)),
		ARG_INFO("food_blacklist", DATA_INPUT_LIST_VAR, "What food types in taming_foods should NOT work?", null),
		ARG_INFO("tame_chance", DATA_INPUT_NUM, "Prob chance for the tame to be successful \[0-100\]", 20),
		ARG_INFO("passive_mode", DATA_INPUT_BOOL, "Is this for a aggressive creature?", FALSE),
		ARG_INFO("emote_happy", DATA_INPUT_TEXT, "What emote does this creature do when happy?", "flip"),
		ARG_INFO("emote_angry", DATA_INPUT_TEXT, "What emote does this creature do when angry?", "scream")
	)


/datum/component/tameable
	var/list/signals = list()
	var/mob/living/critter/owner = null
	var/list/obj/item/taming_foods = list(/obj/item/reagent_containers/food/snacks) // What people use to tame
	var/food_blacklist = null // what's in the treat's subtype but doesn't count?
	var/tame_chance = 20 // prob percentage
	var/emote_happy = null // live critter reactions
	var/emote_angry = null
	var/toggle_behavours = null // for a behaviour that turns on and off on petting
	var/passive_mode = FALSE

/datum/component/tameable/Initialize(atom/target)
	. = ..()
	if(!istype(src.parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	src.owner = parent
	RegisterSignal(parent, COMSIG_ATTACKBY, PROC_REF(pass_on_attackby))
	RegisterSignal(parent, COMSIG_ATTACKHAND, PROC_REF(pass_on_attackhand))
	RegisterSignal(parent, COMSIG_MOB_VALIDATE_TARGET, PROC_REF(pass_on_validtarget))

/datum/component/tameable/proc/pass_on_attackby(atom/movable/parent, obj/item/item, mob/user, params)
	if(!isdead(owner) && passive_mode)
		return
	if(istypes(item, taming_foods))
		if((istypes(item, food_blacklist)))
			owner.visible_message("[user] tries to feed [owner] but they won't take it!")
			return
		if (owner.tamed)
			owner.visible_message("[user] tries to feed [owner] but they seem full...")
			return
		if(prob(tame_chance))
			owner.tamed = TRUE
			owner.ai_retaliates = FALSE
			owner.visible_message("[owner] enjoyed the [item] and seems more docile!")
			owner.emote("burp")
		if(istype(owner, /mob/living/critter/rockworm))
			var/mob/living/critter/rockworm/RW = owner
			RW.aftereat()
		item.Eat(owner, owner)
		return
	if(istypes(item, taming_foods) && ishuman(user) && !isdead(owner) && !passive_mode)
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
			if(prob(tame_chance) && istypes(item, taming_foods))
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
	if ((M.a_intent == INTENT_HARM) && !(M in owner.friends))
		return
	if(!passive_mode)
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

/datum/component/tameable/proc/pass_on_validtarget(mob/M)
	if(!passive_mode)
		if(M in owner.friends)
			return FALSE
