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
	. = ..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	RegisterSignals(parent, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_PICKUP), PROC_REF(on_drop_or_pickup))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(toggle_force_use_as_tool))

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
	var/list/all_hairs = list()
	var/list/all_hair_types = list()

TYPEINFO_NEW(/datum/component/barber)
	. = ..()

	// just so we get a special icon sprite for no hair
	src.all_hairs += list("None" = list("hair_id" = "none", "hair_icon" = "data:image/png;base64," + icon2base64(icon('icons/map-editing/landmarks.dmi', "x", SOUTH)), "hair_type" = /datum/customization_style/none))

	for (var/datum/customization_style/style as anything in all_hair_types)
		var/hair_icon = "data:image/png;base64," + icon2base64(icon(initial(style.icon), initial(style.id), SOUTH, 1)) // yeah, sure, i'll keep it white. the user can preview the hair style anyway.
		src.all_hairs += list(initial(style.name) = list("hair_id" = initial(style.id), "hair_icon" = hair_icon, "hair_type" = style))

ABSTRACT_TYPE(/datum/component/barber)
/datum/component/barber
	var/datum/appearanceHolder/new_AH
	var/datum/movable_preview/character/preview
	var/mob/living/carbon/human/barbee
	var/mob/barber
	var/hair_portion = "bottom"
	var/actionbar_type = null
	var/cutting_names = list()

/datum/component/barber/Initialize()
	. = ..()

	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE

TYPEINFO(/datum/component/barber/haircut)
TYPEINFO_NEW(/datum/component/barber/haircut)
	all_hair_types = get_available_custom_style_types(filter_type=/datum/customization_style/hair)
	. = ..()

/datum/component/barber/haircut
	actionbar_type = /datum/action/bar/barber/haircut

/datum/component/barber/haircut/Initialize()
	. = ..()
	if (. == COMPONENT_INCOMPATIBLE)
		return .

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_PRE, PROC_REF(do_haircut))

TYPEINFO(/datum/component/barber/shave)
TYPEINFO_NEW(/datum/component/barber/shave)
	all_hair_types = get_available_custom_style_types(filter_type=/datum/customization_style/beard) \
					+ get_available_custom_style_types(filter_type=/datum/customization_style/moustache) \
					+ get_available_custom_style_types(filter_type=/datum/customization_style/sideburns) \
					+ get_available_custom_style_types(filter_type=/datum/customization_style/eyebrows)
	. = ..()

/datum/component/barber/shave
	actionbar_type = /datum/action/bar/barber/shave

/datum/component/barber/shave/Initialize()
	. = ..()
	if (. == COMPONENT_INCOMPATIBLE)
		return .

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_PRE, PROC_REF(do_shave))

/datum/component/barber/proc/do_haircut(var/obj/item/thing, mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)
	if(!M || !user || (user.a_intent != INTENT_HELP && !thing.force_use_as_tool))
		return 0 // Who's cutting whose hair, now?

	var/non_murderous_failure = 0
	var/mob/living/carbon/human/H = M
	if(ishuman(M) && ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES) || (H.glasses && H.glasses.c_flags & COVERSEYES)))
		// you can't stab someone in the eyes wearing a mask!
		boutput(user, SPAN_NOTICE("You're going to need to remove that mask/helmet/glasses first."))
		non_murderous_failure = BARBERY_FAILURE

	if(H.is_bald())
		boutput(user, SPAN_ALERT("There is nothing to cut!"))
		non_murderous_failure = BARBERY_FAILURE

	if(!mutant_barber_fluff(M, user, "haircut"))
		logTheThing(LOG_COMBAT, user, "tried to cut [constructTarget(M,"combat")]'s hair but failed at [log_loc(user)].")
		return ATTACK_PRE_DONT_ATTACK

	if(non_murderous_failure)
		if (thing.force_use_as_tool || (user.a_intent == INTENT_HELP && (istype(M.buckled, /obj/stool/chair/comfy/barber_chair) || istype(get_area(M), /area/station/crew_quarters/barber_shop))))
			boutput(user, SPAN_NOTICE("You poke [M] with your [thing]. If you want to attack [M], you'll need to remove [him_or_her(M)] from the barber shop or set your intent to anything other than 'help', first."))
			return ATTACK_PRE_DONT_ATTACK
		else
			return 0

	if (!isnull(src.barbee) && src.barbee != M) // If we are already cutting someone's hair...
		user.show_text("You are already cutting someone's hair.", "red")
		return

	SPAWN(0)
		src.barber = user
		src.barbee = M

		src.ui_interact(user)

	return ATTACK_PRE_DONT_ATTACK

/datum/component/barber/proc/do_shave(var/obj/item/thing, mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)
	if(!M || !user || (user.a_intent != INTENT_HELP && !thing.force_use_as_tool))
		return 0 // Who's cutting whose hair, now?

	var/non_murderous_failure = 0
	var/mob/living/carbon/human/H = M
	if(ishuman(M) && ((H.head && H.head.c_flags & COVERSMOUTH) || (H.wear_mask &&  H.wear_mask.c_flags & COVERSMOUTH) || (H.glasses && H.glasses.c_flags & COVERSMOUTH)))
		// you can't stab someone in the eyes wearing a mask!
		boutput(user, SPAN_NOTICE("You're going to need to remove that mask/helmet/glasses first."))
		non_murderous_failure = BARBERY_FAILURE

	if(issilicon(M))
		boutput(user, SPAN_ALERT("Shave a robot? Shave a robot!?? SHAVE A ROBOT?!?!??"))
		non_murderous_failure = BARBERY_FAILURE

	if(!ishuman(M))
		boutput(user, SPAN_ALERT("You don't know how to shave that! At least without cutting its face off."))
		non_murderous_failure = BARBERY_FAILURE

	if(non_murderous_failure != BARBERY_FAILURE && iswizard(M))
		if (user == M)
			boutput(user, "<span style='font-size: 1.5em; font-weight:bold; color:red'>And just what do you think you're doing?</span>\
							<br>It took you [SPAN_ALERT("years")] to grow that <span style='font-family: Dancing Script, cursive;'>majestic</span> thing!\
							<br>To even <span style='font-family: Dancing Script, cursive;'>fathom</span> an existence without it fills the [voidSpeak("void")] where your soul used to be with [SPAN_ALERT("RAGE.")]")
			non_murderous_failure = BARBERY_FAILURE
		if (istype(M.bioHolder.mobAppearance.customizations["hair_middle"].style, /datum/customization_style/none))
			boutput(user, SPAN_ALERT("[M]'s beard is already gone!"))
		else
			thing.visible_message(SPAN_ALERT("<b>[user]</b> quickly shaves off [M]'s beard!"))
			M.bioHolder.AddEffect("arcane_shame", timeleft = 120)
			M.bioHolder.mobAppearance.customizations["hair_middle"].style = new /datum/customization_style/none
			M.set_face_icon_dirty()
			M.emote("cry")
			M.emote("scream")
			if (M.organHolder?.head)
				M.organHolder.head.UpdateIcon()
		return ATTACK_PRE_DONT_ATTACK // gottem

	if(non_murderous_failure != BARBERY_FAILURE && H.is_bald())
		boutput(user, SPAN_ALERT("There is nothing to cut!"))
		non_murderous_failure = BARBERY_FAILURE

	if(non_murderous_failure != BARBERY_FAILURE && !mutant_barber_fluff(M, user, "shave"))
		if (istype(H))
			logTheThing(LOG_COMBAT, user, "tried to shave [constructTarget(H,"combat")]'s hair but failed due to target's [H?.mutantrace?.name] mutant race at [log_loc(user)].")
		non_murderous_failure = BARBERY_FAILURE

	if(non_murderous_failure)
		if (thing.force_use_as_tool)
			boutput(user, SPAN_NOTICE("You poke [M] with your [thing]. If you want to attack [M], you'll need to wield \the [thing] as a weapon first."))
			return ATTACK_PRE_DONT_ATTACK
		else if (user.a_intent == INTENT_HELP && (istype(M.buckled, /obj/stool/chair/comfy/barber_chair) || istype(get_area(M), /area/station/crew_quarters/barber_shop)))
			boutput(user, SPAN_NOTICE("You poke [M] with your [thing]. If you want to attack [M], you'll need to remove [him_or_her(M)] from the barber shop or set your intent to anything other than 'help', first."))
			return ATTACK_PRE_DONT_ATTACK
		else
			return 0

	if (!isnull(src.barbee) && src.barbee != M) // If we are already cutting someone's hair...
		user.show_text("You are already cutting someone's hair.", "red")
		return

	SPAWN(0)
		src.barber = user
		src.barbee = M

		src.ui_interact(user)

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

/datum/component/barber/proc/mutant_barber_fluff(mob/living/carbon/human/M, mob/living/carbon/human/user, var/barbery_type)
	if(!ishuman(M))
		if(issilicon(M))
			if(barbery_type == "haircut")
				playsound(M, 'sound/items/Scissor.ogg', 100, TRUE)
				M.tri_message(user, "[user] waves [his_or_her(user)] scissors around [M]'s [isAI(M) ? "core" : "metallic upper housing"], snipping at nothing!",\
											"[user] snips [his_or_her(user)] scissors around your [isAI(M) ? "core" : "head"].",\
									"You snip at a piece of lint stuck in a seam on [M]'s [isAI(M) ? "core" : "head"] plates.")
			else
				M.tri_message(user, "[user] slides [his_or_her(user)] razor scross [M]'s [isAI(M) ? "screen" : "cold metal face analogue"], cutting at nothing!",\
											"[user] slides [his_or_her(user)] razor across [isAI(M) ? "your screen" : "the front of your head"].",\
									"You shave off a small patch of [isAI(M) ? "dust stuck to [M]'s screen" : "rust on [M]'s face"].")
		return 0 // runtimes violate law 1, probably
	else if((M.mutantrace.mutant_appearance_flags & HAS_HUMAN_HAIR) || M.hair_override)
		return 1 // has human hair or mutant forced to be hairy, should be fine
	else
		var/datum/mutantrace/mutant = M.mutantrace.name
		var/datum/mutantrace/mutant_us = "human"
		if (ishuman(user) && user?.mutantrace)
			mutant_us = user.mutantrace.name
		switch(mutant)
			if("blob")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, TRUE)
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
				boutput(user, SPAN_ALERT("[M]'s bright, flashing skin hurts your eyes."))
				user.take_eye_damage(1)
				return 1
			if("virtual")
				boutput(user, SPAN_HINT("You prepare to modify M.bioHolder.mobAppearance.customization_[barbery_type == "haircut" ? "first" : "second"]."))
				return 1
			if("blank", "humanoid")
				boutput(user, SPAN_HINT("You somehow correctly guess which end of [M] is forward."))
				return 1
			if("grey")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, TRUE)
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
					playsound(M, 'sound/items/Scissor.ogg', 100, TRUE)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head.",\
											"[user] gives your scales a trim.",\
									 "You find a few overgrown scales on [M] head and give them a trim.")
				return 0
			if("zombie")
				boutput(user, SPAN_HINT("Hair is hair, even if it is mashed full of rotted skin and attached to someone who wants to eat your brain."))
				return 1
			if("vampiric thrall")
				boutput(user, SPAN_HINT("Hair is hair, even if it is attached to someone who wants to drink your blood."))
				return 1
			if("skeleton")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, TRUE)
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
					playsound(M, 'sound/items/Scissor.ogg', 100, TRUE)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s writhing, monstrous form!",\
											"[user] patronizes us by trying to alter our appearance.",\
									 "You muster your courage and manage to give one of the many scraggly, wriggling, <i>familiar</i> patches of hair scattered across [M] a trim!")
				return 0
			if("werewolf")
				M.emote("scream")
				playsound(M, 'sound/impact_sounds/Slimy_Cut_1.ogg', 100, TRUE)
				M.tri_message(user, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] [M]'s ear trying to [barbery_type == "haircut" ? "trim its hair" : "shave it"]!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] your ear! [SPAN_ALERT("FUCK")]",\
									 "You try to [barbery_type == "haircut" ? "snip" : "cut"] some of the fur on [M]'s head, but end up cutting its ear!")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			if("hunter")
				M.emote("scream")
				playsound(M, 'sound/impact_sounds/Slimy_Cut_1.ogg', 100, TRUE)
				M.tri_message(user, "[user] cuts one of [M]'s dreads too deep!",\
											"[user] cuts off one of your head protrusions! [SPAN_ALERT("FUCK")]",\
									 "You try to cut [M]'s hair, but find that much of it is part of their head! Gross.")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			if("ithillid")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, TRUE)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head.",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something on your head.",\
									 "You wave your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s fishy head, knocking loose some space barnnacles.")
				return 0
			if("monkey", "sea monkey")
				M.emote("scream")
				playsound(M, 'sound/impact_sounds/Slimy_Cut_1.ogg', 100, TRUE)
				M.tri_message(user, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] [M]'s ear trying to trim [his_or_her(user)] hair!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] your ear! [SPAN_ALERT("FUCK")]",\
									 "You try to [barbery_type == "haircut" ? "snip" : "cut"] some of the fur on the top of [M]'s head, but end up slicing its ear!")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			if("martian")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, TRUE)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head, [barbery_type == "haircut" ? "snipping" : "slashing"] at nothing!",\
											"You can sense the [mutant_us] judging your lack of hair and head-shape as it pretends to do its job.",\
									 "You wave your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s bald, oddly-shaped head, ignoring the fact that it is very, very bald.")
				return 0
			if("stupid alien baby")
				M.emote("scream")
				playsound(M, 'sound/impact_sounds/Slimy_Cut_1.ogg', 100, TRUE)
				M.tri_message(user, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] one of [M]'s antenna-things!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] your stupid alien dealie-bobbers! [SPAN_ALERT("FUCK")]",\
									 "You nick one of the things sticking out of [M]'s head while pretending to cut at nothing!")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			if("premature clone")
				boutput(user, SPAN_HINT("You try to cut [M]'s hair very carefully, lest [he_or_she(M)] fall over and explode."))
				return 1
			if("mutilated")
				M.emote("scream")
				user.vomit()
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, TRUE)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s horrible, disgusting, head-shaped mass of gore, [barbery_type == "haircut" ? "snipping" : "cutting"] at nothing!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something on your head.",\
									 "You suppress waves of nausea trying to [barbery_type == "haircut" ? "snip" : "cut"] your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head-shaped clump of decayed meat.")
				return 0
			if("cyclops")
				boutput(user, SPAN_HINT("You mind [M]'s enormous fucking eyeball."))
			if("cat")
				M.emote("scream")
				playsound(M.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1)
				M.tri_message(user, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] [M]'s ear trying to trim its hair!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] your ear! [SPAN_ALERT("FUCK")]",\
									 "You try to [barbery_type == "haircut" ? "snip" : "cut"] some of the fur on [M]'s head, but end up slicing its ear!")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			if("amphibian", "Shelter Amphibian")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, TRUE)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head, snipping at nothing!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something around your head.",\
									 "You wave your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s massive frog head, knocking loose some... dead spaceflies?")
				return 0
			if("kudzu")
				boutput(user, SPAN_HINT("You take a brief moment to figure out what part of [M]'s head isn't vines."))
			if("cow")
				if(barbery_type == "haircut")
					playsound(M, 'sound/items/Scissor.ogg', 100, TRUE)
				M.tri_message(user, "[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head, snipping at nothing!",\
											"[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something around your head, obviouly pretending to be a hairstylist.",\
									 "You perform a one-sided LARP with [M], pretending to be an experienced barber working on someone who actually has hair.")
				return 0
			if("roach")
				M.emote("scream")
				playsound(M, 'sound/impact_sounds/Slimy_Cut_1.ogg', 100, TRUE)
				M.tri_message(user, "[user] cuts one of [M]'s antennae!",\
											"[user] cuts into your stupid insect dealie-bobbers! [SPAN_ALERT("FUCK")]",\
									 "You slice one of the things sticking out of [M]'s head while pretending to cut at nothing!")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			else
				boutput(user, SPAN_HINT("You're not quite sure what that is, but decide to cut its hair anyway. If it has any."))
	return 1



/datum/component/barber/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BarberingMenu")
		ui.open()

/datum/component/barber/ui_data(mob/user)
	if (isnull(src.new_AH))
		src.new_AH = new /datum/appearanceHolder/()
		src.new_AH.CopyOther(src.barbee.bioHolder.mobAppearance)

	if (isnull(src.preview))
		var/preview_id = src.barber.name + "_" + src.barbee.name + "_" + "[src.parent.type]" // To avoid mixing up preview IDs, we gotta be *really* specific
		src.preview = new /datum/movable_preview/character(src.barber.client, "barber", preview_id)

		if (src.barbee.hud.layout_style == "tg")
			var/mob/living/carbon/human/preview_mob = src.preview.preview_thing // So the game understands we are manipulating a human
			preview_mob.hud.layout_style = "tg"

		src.preview.add_background("#242424", 2)
		src.reference_clothes(src.barbee, src.preview.preview_thing)
		src.preview.update_appearance(src.new_AH, direction=SOUTH, name=src.barbee.name)

	var/list/current_hair_style = list("bottom" = new_AH.customizations["hair_bottom"].style.name, "middle" = new_AH.customizations["hair_middle"].style.name, "top" = new_AH.customizations["hair_top"].style.name)
	. = list("preview" = src.preview.preview_id, "selected_hair_portion" = hair_portion, "current_hair_style" = current_hair_style)

/datum/component/barber/ui_static_data(mob/user)
	var/typeinfo/datum/component/barber/typeinfo = src.get_typeinfo()
	. = list("available_styles" = typeinfo.all_hairs)

/datum/component/barber/ui_act(var/action, var/params)
	. = ..()
	if (.)
		return TRUE

	switch(action)

		if("change_hair_portion")
			src.hair_portion = params["new_portion"]
			return TRUE

		if("update_preview")
			switch(params["action"])
				if("new_hair")
					var/typeinfo/datum/component/barber/typeinfo = src.get_typeinfo()

					var/datum/customization_style/new_hairstyle = new /datum/customization_style/none // If we don't find any styles, we are probably trying to use the "none" style.

					for (var/list/hair_listing as anything in typeinfo.all_hairs)
						if (typeinfo.all_hairs[hair_listing]["hair_id"] == params["style_id"])
							var/hair_style_type = typeinfo.all_hairs[hair_listing]["hair_type"]
							new_hairstyle = new hair_style_type
							break

					src.new_AH.CopyOther(src.barbee.bioHolder.mobAppearance) // To avoid confusion and kind of nerf this feature, let's completely reset the hair when the client tries to view another style.

					switch (src.hair_portion)
						if ("bottom")
							src.new_AH.customizations["hair_bottom"].style = new_hairstyle
						if ("middle")
							src.new_AH.customizations["hair_middle"].style = new_hairstyle
						if ("top")
							src.new_AH.customizations["hair_top"].style = new_hairstyle
					src.reference_clothes(src.barbee, src.preview.preview_thing)
					src.preview.update_appearance(src.new_AH)

				if("change_direction")
					src.preview.update_appearance(src.new_AH, src.new_AH.mutant_race, turn(src.preview.preview_thing.dir, params["direction"]))

				if("reset")
					src.new_AH.CopyOther(src.barbee.bioHolder.mobAppearance)
					src.reference_clothes(src.barbee, src.preview.preview_thing)
					src.preview.update_appearance(src.new_AH)

			return TRUE
		if("do_hair")
			if (ON_COOLDOWN(src.barber, "cut_hair", 1 SECOND))
				return

			if (isnull(params["style_id"])) // It means we are making a wig
				actions.start_and_wait(new src.actionbar_type(src.barbee, src.barber, get_barbery_conditions(src.barbee, src.barber), null, ALL_HAIR), src.barber)

				if (!barber || !barbee)
					return // If there's no barber, it's safe to say we've been disposed of

				src.new_AH.CopyOther(src.barbee.bioHolder.mobAppearance)
				src.reference_clothes(src.barbee, src.preview.preview_thing)
				src.preview.update_appearance(src.new_AH)
				src.ui_close(src.barber)
				return

			var/hair_portion_list = list(
				"bottom" = BOTTOM_DETAIL,
				"middle" = MIDDLE_DETAIL,
				"top" = TOP_DETAIL
			)

			var/hair_portion_selected = hair_portion_list[src.hair_portion]
			var/datum/customization_style/new_hairstyle = null

			var/typeinfo/datum/component/barber/typeinfo = src.get_typeinfo()

			for (var/list/hair_listing as anything in typeinfo.all_hairs)
				if (typeinfo.all_hairs[hair_listing]["hair_id"] == params["style_id"])
					var/hair_style_type = typeinfo.all_hairs[hair_listing]["hair_type"]
					new_hairstyle = new hair_style_type
					break

			actions.start_and_wait(new src.actionbar_type(src.barbee, src.barber, get_barbery_conditions(src.barbee, src.barber), new_hairstyle, hair_portion_selected), src.barber)

			if (!barber || !barbee) // If either don't exist anymore, it's safe to say we have been disposed of.
				return

			if(barbee.is_bald())
				src.ui_close(src.barber) // There is nothing more to cut.

			if (!barber || !barbee)
				return // If there's no barber, it's safe to say we've been disposed of

			src.new_AH.CopyOther(src.barbee.bioHolder.mobAppearance)
			src.reference_clothes(src.barbee, src.preview.preview_thing)
			src.preview.update_appearance(src.new_AH)
			return TRUE


// Safer than manually changing appearance var.
/datum/component/barber/proc/reference_clothes(var/mob/living/carbon/human/to_copy, var/mob/living/carbon/human/to_paste)
	src.nullify_clothes(to_paste) // Better safe than runtiming 57 times

	to_paste.wear_suit = to_copy.wear_suit
	to_paste.w_uniform = to_copy.w_uniform
	to_paste.shoes = to_copy.shoes
	to_paste.belt = to_copy.belt
	to_paste.gloves = to_copy.gloves
	to_paste.glasses = to_copy.glasses
	to_paste.head = to_copy.head
	to_paste.wear_id = to_copy.wear_id
	to_paste.r_store = to_copy.r_store
	to_paste.l_store = to_copy.l_store

/datum/component/barber/proc/nullify_clothes(var/mob/living/carbon/human/to_nullify)
	to_nullify.wear_suit = null
	to_nullify.w_uniform = null
	to_nullify.shoes = null
	to_nullify.belt = null
	to_nullify.gloves = null
	to_nullify.glasses = null
	to_nullify.head = null
	to_nullify.wear_id = null
	to_nullify.r_store = null
	to_nullify.l_store = null

/datum/component/barber/ui_status(mob/user, datum/ui_state/state)
	. = user.find_in_hand(src.parent) // If our parent is on the barber's hands, then the barber can still cut hair, otherwise, close the window immediately.
	. = . && (src.barbee in range(1, src.barber)) // If the previous condition was true, and the barbee is still within barber range, we're good to go.
	. = . ? UI_INTERACTIVE : UI_CLOSE // If, after checking the previous conditions, return is true, then the user can still cut hair. Otherwise, close the window.

/datum/component/barber/ui_close(mob/user) // Disposing code for all important variables
	if (src.preview)
		src.nullify_clothes(src.preview.preview_thing)
	qdel(src.new_AH)
	qdel(src.preview)
	src.new_AH = null
	src.preview = null
	src.barber = null
	src.barbee = null

/datum/component/barber/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_ATTACKED_PRE)
	. = ..()

ABSTRACT_TYPE(/datum/action/bar/barber)
/datum/action/bar/barber
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
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

	proc/spawn_hair_clipping(var/mob/living/carbon/human/M, var/color, var/old_style)
		if (!M || !M.loc)
			return
		if (!color)
			return
		if (istype(old_style, /datum/customization_style/none))
			return

		var/obj/decal/cleanable/hair/hair = new(M.loc)
		hair.color = color
		hair.update_color()

	New(var/mob/living/carbon/human/barbee, var/mob/living/carbon/human/barber, var/succ, var/nustyle, var/whichp)
		src.M = barbee
		src.user = barber
		src.degree_of_success = succ
		src.new_style = nustyle
		src.which_part = whichp
		M.tri_message(user, "[user] begins [cutting] [M]'s hair.",\
			SPAN_NOTICE("[user] begins [cutting] your hair."),\
			SPAN_NOTICE("You begin [cutting] [M]'s hair."))
		playsound(user, 'sound/items/Scissor.ogg', 100, TRUE)
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
				playsound(M, 'sound/impact_sounds/Flesh_Cut_1.ogg', 100, TRUE)
				logTheThing(LOG_COMBAT, user, "mangles (barbery failure with moderate damage) [constructTarget(M,"combat")]'s head at [log_loc(user)].")
				M.tri_message(user, SPAN_ALERT("[user] mangles the absolute fuck out of [M]'s head!."),\
					SPAN_ALERT("[user] mangles the absolute fuck out of your head!"),\
					SPAN_ALERT("You mangle the absolute fuck out of [M]'s head!"))
				spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_bottom"].color, M.bioHolder.mobAppearance.customizations["hair_bottom"].style)
				spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_middle"].color, M.bioHolder.mobAppearance.customizations["hair_middle"].style)
				spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_top"].color, M.bioHolder.mobAppearance.customizations["hair_top"].style)
				M.bioHolder.mobAppearance.customizations["hair_bottom"].style = new /datum/customization_style/none
				M.bioHolder.mobAppearance.customizations["hair_middle"].style = new /datum/customization_style/none
				M.bioHolder.mobAppearance.customizations["hair_top"].style = new /datum/customization_style/none
				M.TakeDamage("head", rand(10,20), 0)
				take_bleeding_damage(M, user, 2, DAMAGE_CUT, 1)
				M.emote("scream")
			if (1) // same, but it makes a wig
				playsound(M, 'sound/impact_sounds/Slimy_Cut_1.ogg', 100, TRUE)
				logTheThing(LOG_COMBAT, user, "cuts all of [constructTarget(M,"combat")]'s hair off (barbery failure with small damage) at [log_loc(user)].")
				M.tri_message(user, SPAN_ALERT("[user] [cuts] all of [M]'s hair off!."),\
					SPAN_ALERT("[user] [cuts] all of your hair off!"),\
					SPAN_ALERT("You [cut] all of [M]'s hair off!"))
				spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_bottom"].color, M.bioHolder.mobAppearance.customizations["hair_bottom"].style)
				spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_middle"].color, M.bioHolder.mobAppearance.customizations["hair_middle"].style)
				spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_top"].color, M.bioHolder.mobAppearance.customizations["hair_top"].style)
				var/obj/item/wig = M.create_wig()
				wig.set_loc(M.loc)
				M.bioHolder.mobAppearance.customizations["hair_bottom"].style = new /datum/customization_style/none
				M.bioHolder.mobAppearance.customizations["hair_middle"].style = new /datum/customization_style/none
				M.bioHolder.mobAppearance.customizations["hair_top"].style = new /datum/customization_style/none
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				M.emote("scream")
			if (2) // you cut their hair into something else
				playsound(M, 'sound/items/Scissor.ogg', 100, TRUE)
				logTheThing(LOG_COMBAT, user, "cuts [constructTarget(M,"combat")]'s hair into a random one at [log_loc(user)].")
				var/hair_type = pick(hair_list)
				new_style = new hair_type
				switch(rand(1,3))
					if(1)
						spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_bottom"].color, M.bioHolder.mobAppearance.customizations["hair_bottom"].style)
						M.bioHolder.mobAppearance.customizations["hair_bottom"].style = new_style
					if(2)
						spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_middle"].color, M.bioHolder.mobAppearance.customizations["hair_middle"].style)
						M.bioHolder.mobAppearance.customizations["hair_middle"].style = new_style
					if(3)
						spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_top"].color, M.bioHolder.mobAppearance.customizations["hair_top"].style)
						M.bioHolder.mobAppearance.customizations["hair_top"].style = new_style
				M.tri_message(user, "[user] [cuts] [M]'s hair.",\
											SPAN_NOTICE("[user] [cuts] your hair."),\
																					SPAN_NOTICE("You [cut] [M]'s hair, but it doesn't quite look like what you had in mind! Maybe they wont notice?"))
			if (3) // you did it !!
				playsound(M, 'sound/items/Scissor.ogg', 100, TRUE)
				if (src.which_part == ALL_HAIR)
					logTheThing(LOG_COMBAT, user, "cuts all of [constructTarget(M,"combat")]'s hair into a wig at [log_loc(user)].")
					M.tri_message(user, "[user] [cuts] all of [M]'s hair off and makes it into a wig.",\
						SPAN_NOTICE("[user] [cuts] all your hair off and makes it into a wig."),\
						SPAN_NOTICE("You [cut] all of [M]'s hair off and make it into a wig."))
					spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_bottom"].color, M.bioHolder.mobAppearance.customizations["hair_bottom"].style)
					spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_middle"].color, M.bioHolder.mobAppearance.customizations["hair_middle"].style)
					spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_top"].color, M.bioHolder.mobAppearance.customizations["hair_top"].style)
					var/obj/item/wig = M.create_wig()
					wig.set_loc(M.loc)
					M.bioHolder.mobAppearance.customizations["hair_bottom"].style = new /datum/customization_style/none
					M.bioHolder.mobAppearance.customizations["hair_middle"].style = new /datum/customization_style/none
					M.bioHolder.mobAppearance.customizations["hair_top"].style = new /datum/customization_style/none
				else
					logTheThing(LOG_COMBAT, user, "cuts [constructTarget(M,"combat")]'s hair at [log_loc(user)].")
					M.tri_message(user, "[user] [cuts] [M]'s hair.",\
						SPAN_NOTICE("[user] [cuts] your hair."),\
						SPAN_NOTICE("You [cut] [M]'s hair."))
					switch(which_part)
						if (BOTTOM_DETAIL)
							spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_bottom"].color, M.bioHolder.mobAppearance.customizations["hair_bottom"].style)
							M.bioHolder.mobAppearance.customizations["hair_bottom"].style = new_style
						if (MIDDLE_DETAIL)
							spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_middle"].color, M.bioHolder.mobAppearance.customizations["hair_middle"].style)
							M.bioHolder.mobAppearance.customizations["hair_middle"].style = new_style
						if (TOP_DETAIL)
							spawn_hair_clipping(M, M.bioHolder.mobAppearance.customizations["hair_top"].color, M.bioHolder.mobAppearance.customizations["hair_top"].style)
							M.bioHolder.mobAppearance.customizations["hair_top"].style = new_style

		M.set_clothing_icon_dirty() // why the fuck is hair updated in clothing
		M.update_colorful_parts()
		..()

	onInterrupt()
		boutput(owner, SPAN_ALERT("You were interrupted!"))
		..()

/datum/action/bar/barber/haircut
	cut = "cut"
	cuts = "cuts"
	cutting = "cutting"

	getHairStyles()
		return get_available_custom_style_types(filter_type=/datum/customization_style/hair)

/datum/action/bar/barber/shave
	cut = "shave"
	cuts = "shaves"
	cutting = "shaving"

	getHairStyles()
		return get_available_custom_style_types(filter_type=/datum/customization_style/beard) \
					+ get_available_custom_style_types(filter_type=/datum/customization_style/moustache) \
					+ get_available_custom_style_types(filter_type=/datum/customization_style/sideburns) \
					+ get_available_custom_style_types(filter_type=/datum/customization_style/eyebrows)

#undef HAIRCUT
#undef SHAVE
#undef BARBERY_FAILURE
#undef TOOLMODE_DEACTIVATED
#undef TOOLMODE_ACTIVATED

#undef BOTTOM_DETAIL
#undef MIDDLE_DETAIL
#undef TOP_DETAIL
#undef ALL_HAIR
