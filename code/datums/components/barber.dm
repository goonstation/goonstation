#define HAIRCUT 1
#define SHAVE 2
#define BARBERY_FAILURE 2 // if barbering is not successful, but gives a message
#define TOOLMODE_DEACTIVATED SOUTH // points the thing to its default direction when not-tool
#define TOOLMODE_ACTIVATED WEST // flips around the grip to point this way when tool

// hairea options
#define BOTTOM_DETAIL 1
#define MIDDLE_DETAIL 2
#define TOP_DETAIL 3
#define ALL_HAIR 4


TYPEINFO(/datum/component/toggle_tool_use)
	initialization_args = list()

/datum/component/toggle_tool_use
/datum/component/toggle_tool_use/Initialize()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_PICKUP), .proc/on_drop_or_pickup)
	RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF), .proc/toggle_force_use_as_tool)

	// this proc is supposed to make certain tools less accidentally deadly for inexperienced players to use
	// when force_use_as_tool is set, all intents will try to do their tool-thing, and if it can't, return a message saying they're using it wrong
	// if not set, help intent will still attempt tool, but you'll shank them if it doesn't work out
/datum/component/toggle_tool_use/proc/on_drop_or_pickup(var/obj/item/thing, mob/user)
	thing.force_use_as_tool = 0
	thing.set_dir(TOOLMODE_DEACTIVATED)

/datum/component/toggle_tool_use/proc/toggle_force_use_as_tool(var/obj/item/thing, mob/user)
	thing.force_use_as_tool = !thing.force_use_as_tool
	if (thing.force_use_as_tool)
		thing.set_dir(TOOLMODE_ACTIVATED) // We're just flipping the tool around to we don't hurt anyone
	else
		thing.set_dir(TOOLMODE_DEACTIVATED) // Flip it back around so we can actually hurt people if we want to

	var/list/cool_grip_adj = list("a sick", "a wicked", "a deadly", "a menacing", "an edgy", "a tacticool", "a sweaty", "an awkward")
	var/list/cool_grip1 = list("combat", "fightlord", "guerilla", "hidden", "space", "syndie", "double-reverse", "\"triple-dog-dare-ya\"", "stain-buster's")
	var/list/cool_grip2a = list("blade", "cyber", "street", "assistant", "comedy", "butcher", "edge", "beast", "heck", "crud", "ass")
	var/list/cool_grip2b = list("master", "slayer", "fighter", "militia", "space", "syndie", "lord", "blaster", "beef", "tyrannosaurus")
	var/list/wheredWeSeeIt = list("saw the clown do", "saw the captain do", "saw the head of security do",\
														"saw someone in a red spacesuit do", "saw a floating saw do", "saw on TV",\
														"saw one of the diner dudes do", "saw just about every assistant do")
	var/cool_grip3 = "[pick(wheredWeSeeIt)] [pick("once", "once or twice")]"

	if(thing.force_use_as_tool)
		user.visible_message("[user] assumes a less hostile grip on the [thing].",\
													"You change your grip on the [thing], so as to use it more as a tool than a weapon.")
	else
		user.visible_message("[user] wields the [thing] a with [pick(cool_grip_adj)] [pick(cool_grip1)] [pick(cool_grip2a)][pick(cool_grip2b)] [pick("style", "grip")] that they probably [pick(cool_grip3)]!",\
													"You wield the [thing] with [pick(cool_grip_adj)] [pick(cool_grip1)] [pick(cool_grip2a)][pick(cool_grip2b)] [pick("style", "grip")] that you [pick(cool_grip3)]! It makes it just about impossible to use as a tool!")

/datum/component/toggle_tool_use/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	UnregisterSignal(parent, COMSIG_ITEM_PICKUP)
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED)
	. = ..()

TYPEINFO(/datum/component/barber)
	initialization_args = list()

/datum/component/barber
/datum/component/barber/Initialize()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE

/datum/component/barber/haircut
/datum/component/barber/haircut/Initialize()
	RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_PRE), .proc/do_haircut)

/datum/component/barber/shave
/datum/component/barber/shave/Initialize()
	RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_PRE), .proc/do_shave)

/datum/component/barber/proc/do_haircut(var/obj/item/thing, mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)
	if(!M || !user || (user.a_intent != INTENT_HELP && !thing.force_use_as_tool))
		return 0 // Who's cutting whose hair, now?

	var/non_murderous_failure = 0
	var/mob/living/carbon/human/H = M
	var/datum/appearanceHolder/AH = M.bioHolder.mobAppearance
	if(ishuman(M) && ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES) || (H.glasses && H.glasses.c_flags & COVERSEYES)))
		// you can't stab someone in the eyes wearing a mask!
		boutput(user, "<span class='notice'>You're going to need to remove that mask/helmet/glasses first.</span>")
		non_murderous_failure = BARBERY_FAILURE

	if(istype(AH.customization_first,/datum/customization_style/none) && istype(AH.customization_second,/datum/customization_style/none) && istype(AH.customization_third,/datum/customization_style/none))
		boutput(user, "<span class='alert'>There is nothing to cut!</span>")
		non_murderous_failure = BARBERY_FAILURE

	if(!mutant_barber_fluff(M, user, "haircut"))
		logTheThing(LOG_COMBAT, user, "tried to cut [constructTarget(M,"combat")]'s hair but failed at [log_loc(user)].")
		return ATTACK_PRE_DONT_ATTACK

	if(non_murderous_failure)
		if (thing.force_use_as_tool || (user.a_intent == INTENT_HELP && (istype(M.buckled, /obj/stool/chair/comfy/barber_chair) || istype(get_area(M), /area/station/crew_quarters/barber_shop))))
			boutput(user, "<span class='notice'>You poke [M] with your [thing]. If you want to attack [M], you'll need to remove [him_or_her(M)] from the barber shop or set your intent to anything other than 'help', first.</span>")
			return ATTACK_PRE_DONT_ATTACK
		else
			return 0

	SPAWN(0)
		var/list/region = list(
			"Top Detail ([M.bioHolder.mobAppearance.customization_third.name])" = TOP_DETAIL,
			"Middle Detail ([M.bioHolder.mobAppearance.customization_second.name])" = MIDDLE_DETAIL,
			"Bottom Detail ([M.bioHolder.mobAppearance.customization_first.name])" = BOTTOM_DETAIL,
			"Create Wig" = ALL_HAIR)

		var/which_part = input(user, "Which clump of hair?", "Clump") as null|anything in region

		if (!which_part)
			return

		if(region[which_part] != ALL_HAIR)
			var/list/customization_types = list(/datum/customization_style/none) + concrete_typesof(/datum/customization_style/hair) + concrete_typesof(/datum/customization_style/eyebrows)
			var/new_style = select_custom_style(customization_types, user)

			if (!new_style)
				return

			actions.start(new/datum/action/bar/barber/haircut(M, user, get_barbery_conditions(M, user), new_style, region[which_part]), user)
		else
			actions.start(new/datum/action/bar/barber/haircut(M, user, get_barbery_conditions(M, user), null, region[which_part]), user)
	return ATTACK_PRE_DONT_ATTACK

/datum/component/barber/proc/do_shave(var/obj/item/thing, mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)
	if(!M || !user || (user.a_intent != INTENT_HELP && !thing.force_use_as_tool))
		return 0 // Who's cutting whose hair, now?

	var/non_murderous_failure = 0
	var/mob/living/carbon/human/H = M
	var/datum/appearanceHolder/AH = M.bioHolder.mobAppearance
	if(ishuman(M) && ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES) || (H.glasses && H.glasses.c_flags & COVERSEYES)))
		// you can't stab someone in the eyes wearing a mask!
		boutput(user, "<span class='notice'>You're going to need to remove that mask/helmet/glasses first.</span>")
		non_murderous_failure = BARBERY_FAILURE

	if(issilicon(M))
		boutput(user, "<span class='alert'>Shave a robot? Shave a robot!?? SHAVE A ROBOT?!?!??</span>")
		non_murderous_failure = BARBERY_FAILURE

	if(!ishuman(M))
		boutput(user, "You don't know how to shave that! At least without cutting its face off.")
		non_murderous_failure = BARBERY_FAILURE

	if(iswizard(M))
		if (user == M)
			boutput(user, "<span style='font-size: 1.5em; font-weight:bold; color:red'>And just what do you think you're doing?</span>\
							<br>It took you <span class='alert'>years</span> to grow that <span style='font-family: Dancing Script, cursive;'>majestic</span> thing!\
							<br>To even <span style='font-family: Dancing Script, cursive;'>fathom</span> an existence without it fills the [voidSpeak("void")] where your soul used to be with <span class='alert'>RAGE.</span>")
			non_murderous_failure = BARBERY_FAILURE
		thing.visible_message("<span class='alert'><b>[user]</b> quickly shaves off [M]'s beard!</span>")
		M.bioHolder.AddEffect("arcane_shame", timeleft = 120)
		M.bioHolder.mobAppearance.customization_second = new /datum/customization_style/none
		M.set_face_icon_dirty()
		M.emote("cry")
		M.emote("scream")
		if (M.organHolder?.head)
			M.organHolder.head.UpdateIcon()
		return ATTACK_PRE_DONT_ATTACK // gottem

	if(istype(AH.customization_first,/datum/customization_style/none) && istype(AH.customization_second,/datum/customization_style/none) && istype(AH.customization_third,/datum/customization_style/none))
		boutput(user, "<span class='alert'>There is nothing to cut!</span>")
		non_murderous_failure = BARBERY_FAILURE

	if(!mutant_barber_fluff(M, user, "shave"))
		logTheThing(LOG_COMBAT, user, "tried to shave [constructTarget(M,"combat")]'s hair but failed due to target's [M?.mutantrace?.name] mutant race at [log_loc(user)].")
		non_murderous_failure = BARBERY_FAILURE

	if(non_murderous_failure)
		if (thing.force_use_as_tool || (user.a_intent == INTENT_HELP && (istype(M.buckled, /obj/stool/chair/comfy/barber_chair) || istype(get_area(M), /area/station/crew_quarters/barber_shop))))
			boutput(user, "<span class='notice'>You poke [M] with your [thing]. If you want to attack [M], you'll need to remove [him_or_her(M)] from the barber shop or set your intent to anything other than 'help', first.</span>")
			return ATTACK_PRE_DONT_ATTACK
		else
			return 0

	SPAWN(0)

		var/list/region = list(
			"Top Detail ([M.bioHolder.mobAppearance.customization_third.name])" = TOP_DETAIL,
			"Middle Detail ([M.bioHolder.mobAppearance.customization_second.name])" = MIDDLE_DETAIL,
			"Bottom Detail ([M.bioHolder.mobAppearance.customization_first.name])" = BOTTOM_DETAIL,
			"Create Wig" = ALL_HAIR)

		var/which_part = input(user, "Which clump of hair?", "Clump") as null|anything in region

		if (!which_part)
			return

		if (region[which_part] != ALL_HAIR)
			var/list/facehair = list(/datum/customization_style/none) + concrete_typesof(/datum/customization_style/beard) + concrete_typesof(/datum/customization_style/moustache) + concrete_typesof(/datum/customization_style/sideburns)
			var/new_style = select_custom_style(facehair, user)

			if (!new_style)
				return
			actions.start(new/datum/action/bar/barber/shave(M, user, get_barbery_conditions(M, user), new_style, region[which_part]), user)
		else
			actions.start(new/datum/action/bar/barber/shave(M, user, get_barbery_conditions(M, user), null, region[which_part]), user)

	return ATTACK_PRE_DONT_ATTACK

/datum/component/barber/proc/get_barbery_conditions(mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)
	if(!ishuman(M))
		return 0 // shouldn't happen, but just in case someone manages to shave a rat or something
	var/barbery_conditions = 0
	// let's see how ideal the haircutting conditions are
	if(M.stat || issilicon(user))
		barbery_conditions = 100
	else
		if (M.buckled)
			barbery_conditions += 10
		if(istype(M.buckled, /obj/stool/chair/comfy/barber_chair))
			barbery_conditions += 30

		if(istype(get_area(M), /area/station/crew_quarters/barber_shop))
			if(get_area(M) == get_area(user))
				barbery_conditions += 30
			else	// you should ideally be in the same room as whoever's hair you're cutting
				barbery_conditions += 5

		if(M.jitteriness)
			barbery_conditions -= 20

		if(ishuman(user))
			if(istype(user.w_uniform, /obj/item/clothing/under/misc/barber))
				barbery_conditions += 30
			if(user.jitteriness && !M.jitteriness) // your jitteriness kind of... syncs up
				barbery_conditions -= 20
			if(user.mind.assigned_role == "Barber") // 60% chance just for being you, 90 if you're wearing pants
				barbery_conditions += 60
			else if(M == user)
				barbery_conditions -= 30
			if(user.bioHolder.HasEffect("clumsy"))
				barbery_conditions -= 20

	var/degree_of_success = 0
	if(prob(clamp(barbery_conditions, 10, 100)))
		degree_of_success = 3 // success
	else
		switch(max(barbery_conditions, 0))
			if (0 to 20)
				degree_of_success = 0 // destroy all hair
			if (20 to 50)
				degree_of_success = 1 // cut hair off as wig
			else
				degree_of_success = 2 // fine haircut, but wrong style

	return degree_of_success

/datum/component/barber/proc/mutant_barber_fluff(mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob, var/barbery_type)
	if (!M || !user)
		return null

	if(!ishuman(M))
		if(issilicon(M))
			if(barbery_type == "haircut")
				playsound(M, 'sound/items/Scissor.ogg', 100, 1)
				M.tri_message(user, "[user] waves [his_or_her(user)] scissors around [M]'s [isAI(M) ? "core" : "metallic upper housing"], snipping at nothing!",\
											"[user] snips [his_or_her(user)] scissors around your [isAI(M) ? "core" : "head"].",\
									"You snip at a piece of lint stuck in a seam on [M]'s [isAI(M) ? "core" : "head"] plates.")
			else
				M.tri_message(user, "[user] slides [his_or_her(user)] razor scross [M]'s [isAI(M) ? "screen" : "cold metal face analogue"], cutting at nothing!",\
											"[user] slides [his_or_her(user)] razor across [isAI(M) ? "your screen" : "the front of your head"].",\
									"You shave off a small patch of [isAI(M) ? "dust stuck to [M]'s screen" : "rust on [M]'s face"].")
		return 0 // runtimes violate law 1, probably
	else if(!M.mutantrace || M.hair_override)
		return 1 // is human or mutant forced to be hairy, should be fine
	else
		var/datum/mutantrace/mutant = M.mutantrace.name
		var/datum/mutantrace/mutant_us = "human"
		if (ishuman(user) && user?.mutantrace)
			mutant_us = user.mutantrace.name
		switch(mutant)
			if("blob")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, 1)
					M.tri_message(user, "[user] waves [his_or_her(user)] scissors around [M]'s head, snipping at nothing!",\
												"[user] snips at something on the upper hemisphere of your macrocellular structure!",\
										"You snip at a patch of fuzz stuck to [M]'s gooey outer membrane... thing.")
				else
					M.tri_message(user, "[user] waves [his_or_her(user)] razor around [M]'s head, slashing at nothing!",\
												"[user] cuts at something on the upper hemisphere of your macrocellular structure!",\
										"You razor at a patch of fuzz stuck to [M]'s gooey outer membrane... thing.")
				return 0
			if("flubber")
				playsound(M, "sound/misc/boing/[rand(1,6)].ogg", 20, 1)
				user.drop_item_throw()
				M.tri_message(user, "[M]'s flubbery body flings [user]'s [barbery_type == "haircut" ? "scissors" : "razor"] out of [his_or_her(user)] hand!",\
											"[user] pokes you with [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"], flinging them out of their hand",\
									 "[M]'s flubbery body flings the [barbery_type == "haircut" ? "scissors" : "razor"] out of your hand!")
				return 0
			if("flashy")
				boutput(user, "[M]'s bright, flashing skin hurts your eyes.")
				user.take_eye_damage(1)
				return 1
			if("virtual")
				boutput(user, "You prepare to modify M.bioHolder.mobAppearance.customization_[barbery_type == "haircut" ? "first" : "second"].")
				return 1
			if("blank", "humanoid")
				boutput(user, "You somehow correctly guess which end of [M] is forward.")
				return 1
			if("grey")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, 1)
					M.tri_message(user, "[user] waves [his_or_her(user)] scissors around [M]'s head, snipping at nothing!",\
												"You can sense the [mutant_us]'s polite intentions as it pretends that you are not completely bald.",\
																					"You snip your scissors around [M]'s bald head, ignoring the fact that [he_or_she(user)] is very, very bald.")
				else
					M.tri_message(user, "[user] waves [his_or_her(user)] razor around [M]'s head, cutting at nothing!",\
												"You can sense the [mutant_us]'s polite intentions as it pretends that you are completely incapable of having facial hair.",\
																					"You wave your razor around [M]'s hairless face, ignoring the fact that [he_or_she(user)] is very, very hairless.")
				return 0
			if("lizard")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, 1)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head.",\
											"[user] gives your scales a trim.",\
									 "You find a few overgrown scales on [M] head and give them a trim.")
				return 0
			if("zombie")
				boutput(user, "Hair is hair, even if it is mashed full of rotted skin and attached to someone who wants to eat your brain.")
				return 1
			if("vampiric thrall")
				boutput(user, "Hair is hair, even if it is attached to someone who wants to drink your blood.")
				return 1
			if("skeleton")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, 1)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s skull, [barbery_type == "haircut" ? "snipping" : "cutting"] at nothing!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something on your skull.",\
									 "You wave your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s exposed skull, knocking loose some space dust.")
				return 0
			if("Homo nostalgius")
				M.tri_message(user, "[user] tries to cut [M]'s hair, years before that feature was implemented!",\
											"[user] tries to violate your vow of oldest-school existence, but fails!",\
									 "You try to cut [M]'s hair, but suddenly realize that it could cause a temporal-runtime paradox that would erase all of history!")
				return 0
			if("abomination")
				user.emote("scream")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, 1)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s writhing, monstrous form!",\
											"[user] patronizes us by trying to alter our appearance.",\
									 "You muster your courage and manage to give one of the many scraggly, wriggling, <i>familiar</i> patches of hair scattered across [M] a trim!")
				return 0
			if("werewolf")
				M.emote("scream")
				playsound(M, 'sound/impact_sounds/Slimy_Cut_1.ogg', 100, 1)
				M.tri_message(user, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] [M]'s ear trying to [barbery_type == "haircut" ? "trim its hair" : "shave it"]!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] your ear! <span class='alert'>FUCK</span>",\
									 "You try to [barbery_type == "haircut" ? "snip" : "cut"] some of the fur on [M]'s head, but end up cutting its ear!")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			if("hunter")
				M.emote("scream")
				playsound(M, 'sound/impact_sounds/Slimy_Cut_1.ogg', 100, 1)
				M.tri_message(user, "[user] cuts one of [M]'s dreads too deep!",\
											"[user] cuts off one of your head protrusions! <span class='alert'>FUCK</span>",\
									 "You try to cut [M]'s hair, but find that much of it is part of their head! Gross.")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			if("ithillid")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, 1)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head.",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something on your head.",\
									 "You wave your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s fishy head, knocking loose some space barnnacles.")
				return 0
			if("monkey", "sea monkey")
				M.emote("scream")
				playsound(M, 'sound/impact_sounds/Slimy_Cut_1.ogg', 100, 1)
				M.tri_message(user, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] [M]'s ear trying to trim [his_or_her(user)] hair!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] your ear! <span class='alert'>FUCK</span>",\
									 "You try to [barbery_type == "haircut" ? "snip" : "cut"] some of the fur on the top of [M]'s head, but end up slicing its ear!")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			if("martian")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, 1)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head, [barbery_type == "haircut" ? "snipping" : "slashing"] at nothing!",\
											"You can sense the [mutant_us] judging your lack of hair and head-shape as it pretends to do its job.",\
									 "You wave your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s bald, oddly-shaped head, ignoring the fact that it is very, very bald.")
				return 0
			if("stupid alien baby")
				M.emote("scream")
				playsound(M, 'sound/impact_sounds/Slimy_Cut_1.ogg', 100, 1)
				M.tri_message(user, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] one of [M]'s antenna-things!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] your stupid alien dealie-bobbers! <span class='alert'>FUCK</span>",\
									 "You nick one of the things sticking out of [M]'s head while pretending to cut at nothing!")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			if("premature clone")
				boutput(user, "You try to cut [M]'s hair very carefully, lest they fall over and explode.")
				return 1
			if("mutilated")
				M.emote("scream")
				user.vomit()
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, 1)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s horrible, disgusting, head-shaped mass of gore, [barbery_type == "haircut" ? "snipping" : "cutting"] at nothing!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something on your head.",\
									 "You suppress waves of nausea trying to [barbery_type == "haircut" ? "snip" : "cut"] your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head-shaped clump of decayed meat.")
				return 0
			if("cyclops")
				boutput(user, "You mind [M]'s enormous fucking eyeball.")
			if("cat")
				M.emote("scream")
				playsound(M.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1)
				M.tri_message(user, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] [M]'s ear trying to trim its hair!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] your ear! <span class='alert'>FUCK</span>",\
									 "You try to [barbery_type == "haircut" ? "snip" : "cut"] some of the fur on [M]'s head, but end up slicing its ear!")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			if("amphibian", "Shelter Amphibian")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, 1)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head, snipping at nothing!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something around your head.",\
									 "You wave your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s massive frog head, knocking loose some... dead spaceflies?")
				return 0
			if("kudzu")
				boutput(user, "You take a brief moment to figure out what part of [M]'s head isn't vines.")
			if("cow")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, 1)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head, snipping at nothing!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something around your head, obviouly pretending to be a hairstylist.",\
									 "You perform a one-sided LARP with [M], pretending to be an experienced barber working on someone who actually has hair.")
				return 0
			if("roach")
				M.emote("scream")
				playsound(M, 'sound/impact_sounds/Slimy_Cut_1.ogg', 100, 1)
				M.tri_message(user, "[user] cuts one of [M]'s antennae!",\
											"[user] cuts into your stupid insect dealie-bobbers! <span class='alert'>FUCK</span>",\
									 "You slice one of the things sticking out of [M]'s head while pretending to cut at nothing!")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			else
				boutput(user, "You're not quite sure what that is, but decide to cut its hair anyway. If it has any.")
	return 1




/datum/component/barber/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_ATTACKED_PRE)
	. = ..()

ABSTRACT_TYPE(/datum/action/bar/barber)
/datum/action/bar/barber
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "barb" // idk it's barber work
	var/mob/living/carbon/human/M
	var/mob/living/carbon/human/user
	var/degree_of_success
	var/datum/customization_style/new_style
	var/which_part
	// for text output
	var/cut = "cut"
	var/cuts = "cuts"
	var/cutting = "cutting"

	proc/getHairStyles()
		return list()

	New(var/mob/living/carbon/human/barbee, var/mob/living/carbon/human/barber, var/succ, var/nustyle, var/whichp)
		src.M = barbee
		src.user = barber
		src.degree_of_success = succ
		src.new_style = nustyle
		src.which_part = whichp
		M.tri_message(user, "[user] begins [cutting] [M]'s hair.",\
			"<span class='notice'>[user] begins [cutting] your hair.</span>",\
			"<span class='notice'>You begin [cutting] [M]'s hair.</span>")
		playsound(user, 'sound/items/Scissor.ogg', 100, 1)
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, M) > 0 || M == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, M) > 0 || M == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		var/list/hair_list = src.getHairStyles()
		switch (degree_of_success)
			if (0) // cut their head up and hair off
				playsound(M, 'sound/impact_sounds/Flesh_Cut_1.ogg', 100, 1)
				logTheThing(LOG_COMBAT, user, "mangles (barbery failure with moderate damage) [constructTarget(M,"combat")]'s head at [log_loc(user)].")
				M.tri_message(user, "<span class='alert'>[user] mangles the absolute fuck out of [M]'s head!.</span>",\
					"<span class='alert'>[user] mangles the absolute fuck out of your head!</span>",\
					"<span class='alert'>You mangle the absolute fuck out of [M]'s head!</span>")
				M.bioHolder.mobAppearance.customization_first = new /datum/customization_style/none
				M.bioHolder.mobAppearance.customization_second = new /datum/customization_style/none
				M.bioHolder.mobAppearance.customization_third = new /datum/customization_style/none
				M.TakeDamage("head", rand(10,20), 0)
				take_bleeding_damage(M, user, 2, DAMAGE_CUT, 1)
				M.emote("scream")
			if (1) // same, but it makes a wig
				playsound(M, 'sound/impact_sounds/Slimy_Cut_1.ogg', 100, 1)
				logTheThing(LOG_COMBAT, user, "cuts all of [constructTarget(M,"combat")]'s hair off (barbery failure with small damage) at [log_loc(user)].")
				M.tri_message(user, "<span class='alert'>[user] [cuts] all of [M]'s hair off!.</span>",\
					"<span class='alert'>[user] [cuts] all of your hair off!</span>",\
					"<span class='alert'>You [cut] all of [M]'s hair off!</span>")
				var/obj/item/wig = M.create_wig()
				wig.set_loc(M.loc)
				M.bioHolder.mobAppearance.customization_first = new /datum/customization_style/none
				M.bioHolder.mobAppearance.customization_second = new /datum/customization_style/none
				M.bioHolder.mobAppearance.customization_third = new /datum/customization_style/none
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				M.emote("scream")
			if (2) // you cut their hair into something else
				playsound(M, 'sound/items/Scissor.ogg', 100, 1)
				logTheThing(LOG_COMBAT, user, "cuts [constructTarget(M,"combat")]'s hair into a random one at [log_loc(user)].")
				var/hair_type = pick(hair_list)
				new_style = new hair_type
				switch(rand(1,3))
					if(1)
						M.bioHolder.mobAppearance.customization_first = new_style
					if(2)
						M.bioHolder.mobAppearance.customization_second = new_style
					if(3)
						M.bioHolder.mobAppearance.customization_third = new_style
				M.tri_message(user, "[user] [cuts] [M]'s hair.",\
											"<span class='notice'>[user] [cuts] your hair.</span>",\
																					"<span class='notice'>You [cut] [M]'s hair, but it doesn't quite look like what you had in mind! Maybe they wont notice?</span>")
			if (3) // you did it !!
				playsound(M, 'sound/items/Scissor.ogg', 100, 1)
				if (src.which_part == ALL_HAIR)
					logTheThing(LOG_COMBAT, user, "cuts all of [constructTarget(M,"combat")]'s hair into a wig at [log_loc(user)].")
					M.tri_message(user, "[user] [cuts] all of [M]'s hair off and makes it into a wig.",\
						"<span class='notice'>[user] [cuts] all your hair off and makes it into a wig.</span>",\
						"<span class='notice'>You [cut] all of [M]'s hair off and make it into a wig.</span>")
					var/obj/item/wig = M.create_wig()
					wig.set_loc(M.loc)
					M.bioHolder.mobAppearance.customization_first = new /datum/customization_style/none
					M.bioHolder.mobAppearance.customization_second = new /datum/customization_style/none
					M.bioHolder.mobAppearance.customization_third = new /datum/customization_style/none
				else
					logTheThing(LOG_COMBAT, user, "cuts [constructTarget(M,"combat")]'s hair at [log_loc(user)].")
					M.tri_message(user, "[user] [cuts] [M]'s hair.",\
						"<span class='notice'>[user] [cuts] your hair.</span>",\
						"<span class='notice'>You [cut] [M]'s hair.</span>")
					switch(which_part)
						if (BOTTOM_DETAIL)
							M.bioHolder.mobAppearance.customization_first = new_style
						if (MIDDLE_DETAIL)
							M.bioHolder.mobAppearance.customization_second = new_style
						if (TOP_DETAIL)
							M.bioHolder.mobAppearance.customization_third = new_style

		M.set_clothing_icon_dirty() // why the fuck is hair updated in clothing
		M.update_colorful_parts()
		..()

	onInterrupt()
		boutput(owner, "You were interrupted!")
		..()

/datum/action/bar/barber/haircut
	id = "haircut"
	cut = "cut"
	cuts = "cuts"
	cutting = "cutting"

	getHairStyles()
		return concrete_typesof(/datum/customization_style/hair) + concrete_typesof(/datum/customization_style/eyebrows)

/datum/action/bar/barber/shave
	id = "shave"
	cut = "shave"
	cuts = "shaves"
	cutting = "shaving"

	getHairStyles()
		return concrete_typesof(/datum/customization_style/beard) + concrete_typesof(/datum/customization_style/moustache) + concrete_typesof(/datum/customization_style/sideburns)

#undef HAIRCUT
#undef SHAVE
#undef BARBERY_FAILURE
#undef TOOLMODE_DEACTIVATED
#undef TOOLMODE_ACTIVATED

#undef BOTTOM_DETAIL
#undef MIDDLE_DETAIL
#undef TOP_DETAIL
#undef ALL_HAIR
