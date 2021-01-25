#define HAIRCUT 1
#define SHAVE 2
#define BARBERY_FAILURE 2 // if barbering is not successful, but gives a message
#define TOOLMODE_DEACTIVATED SOUTH // points the thing to its default direction when not-tool
#define TOOLMODE_ACTIVATED WEST // flips around the grip to point this way when tool

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
	if(ishuman(M) && ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES) || (H.glasses && H.glasses.c_flags & COVERSEYES)))
		// you can't stab someone in the eyes wearing a mask!
		boutput(user, "<span class='notice'>You're going to need to remove that mask/helmet/glasses first.</span>")
		non_murderous_failure = BARBERY_FAILURE

	if(M.bioHolder.mobAppearance.customization_first == "None")
		boutput(user, "<span class='alert'>There is nothing to cut!</span>")
		non_murderous_failure = BARBERY_FAILURE

	if(!mutant_barber_fluff(M, user, "haircut"))
		return ATTACK_PRE_DONT_ATTACK

	if(non_murderous_failure)
		if (thing.force_use_as_tool || (user.a_intent == INTENT_HELP && (istype(M.buckled, /obj/stool/chair/comfy/barber_chair) || istype(get_area(M), /area/station/crew_quarters/barber_shop))))
			boutput(user, "<span class='notice'>You poke [M] with your [thing]. If you want to attack [M], you'll need to remove [him_or_her(M)] from the barber shop or set your intent to anything other than 'help', first.</span>")
			return ATTACK_PRE_DONT_ATTACK
		else
			return 0

	SPAWN_DBG(0)
		var/list/region = list("First Hairea" = 1, "Second Hairea" = 2, "Third Hairea" = 3)

		var/which_part = input(user, "Which clump of hair?", "Clump") as null|anything in region

		if (!which_part)
			boutput(user, "Never mind.")
			return

		var/new_style = input(user, "Please select style", "Style")  as null|anything in customization_styles + customization_styles_gimmick

		if (!new_style) // I'd prefer not to go through all of the hair styles and rank them based on hairiness
			boutput(user, "Never mind.") // So I guess it'll be on the honor system for now not to give balding folk rockin' 'fros
			return

		actions.start(new/datum/action/bar/haircut(M, user, get_barbery_conditions(M, user), new_style, region[which_part]), user)
	return ATTACK_PRE_DONT_ATTACK

/datum/component/barber/proc/do_shave(var/obj/item/thing, mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)
	if(!M || !user || (user.a_intent != INTENT_HELP && !thing.force_use_as_tool))
		return 0 // Who's cutting whose hair, now?

	var/non_murderous_failure = 0
	var/mob/living/carbon/human/H = M
	if(ishuman(M) && ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES) || (H.glasses && H.glasses.c_flags & COVERSEYES)))
		// you can't stab someone in the eyes wearing a mask!
		boutput(user, "<span class='notice'>You're going to need to remove that mask/helmet/glasses first.</span>")
		non_murderous_failure = BARBERY_FAILURE

	if(M.bioHolder.mobAppearance.customization_second == "None")
		boutput(user, "<span class='alert'>You can't get a closer shave than that!</span>")
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
		M.bioHolder.mobAppearance.customization_second = "None"
		M.cust_two_state = "None"
		M.set_face_icon_dirty()
		M.emote("cry")
		M.emote("scream")
		if (M.organHolder?.head)
			M.organHolder.head.update_icon()
		return ATTACK_PRE_DONT_ATTACK // gottem


	if(!mutant_barber_fluff(M, user, "shave"))
		non_murderous_failure = BARBERY_FAILURE

	if(non_murderous_failure)
		if (thing.force_use_as_tool || (user.a_intent == INTENT_HELP && (istype(M.buckled, /obj/stool/chair/comfy/barber_chair) || istype(get_area(M), /area/station/crew_quarters/barber_shop))))
			boutput(user, "<span class='notice'>You poke [M] with your [thing]. If you want to attack [M], you'll need to remove [him_or_her(M)] from the barber shop or set your intent to anything other than 'help', first.</span>")
			return ATTACK_PRE_DONT_ATTACK
		else
			return 0

	SPAWN_DBG(0)

		var/list/region = list("First Hairea" = 1, "Second Hairea" = 2, "Third Hairea" = 3)

		var/which_part = input(user, "Which clump of hair?", "Clump") as null|anything in region

		if (!which_part)
			boutput(user, "Never mind.")
			return

		var/list/facehair = list("none", "Watson", "Chaplin", "Selleck", "Van Dyke", "Hogan",\
		"Neckbeard", "Elvis", "Abe", "Chinstrap", "Hipster", "Wizard",\
		"Goatee", "Full Beard", "Long Beard")
		var/new_style = input(user, "Please select facial style", "Facial Style")  as null|anything in facehair

		if (!new_style) // otherwise it alternates between non-functional and fucking useless
			boutput(user, "Never mind.")
			return
		actions.start(new/datum/action/bar/shave(M, user, get_barbery_conditions(M, user), new_style, region[which_part]), user)

	return ATTACK_PRE_DONT_ATTACK

/datum/component/barber/proc/get_barbery_conditions(mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)
	if(!ishuman(M))
		return 0 // shouldn't happen, but just in case someone manages to shave a rat or something
	var/barbery_conditions = 0
	// let's see how ideal the haircutting conditions are
	if(M.stat || issilicon(user))
		barbery_conditions = 100
	else
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

	var/degree_of_success = 0 // 0 - 3, 0 being failure, 3 being catastrophic hair success
	if(prob(clamp(barbery_conditions, 10, 100)))
		degree_of_success = 3
	else // oh no we fucked up!
		if(prob(50))
			degree_of_success = 2
		else
			degree_of_success = rand(0,1)
	//and then just jam all the vars into the action bar and let it handle the rest!

	return degree_of_success

/datum/component/barber/proc/mutant_barber_fluff(mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob, var/barbery_type)
	if (!M || !user)
		return null

	if(!ishuman(M))
		if(issilicon(M))
			if(barbery_type == "haircut")
				playsound(M, "sound/items/Scissor.ogg", 100, 1)
				user.tri_message("[user] waves [his_or_her(user)] scissors around [M]'s [isAI(M) ? "core" : "metallic upper housing"], snipping at nothing!",\
											M, "[user] snips [his_or_her(user)] scissors around your [isAI(M) ? "core" : "head"].",\
									user, "You snip at a piece of lint stuck in a seam on [M]'s [isAI(M) ? "core" : "head"] plates.")
			else
				user.tri_message("[user] slides [his_or_her(user)] razor scross [M]'s [isAI(M) ? "screen" : "cold metal face analogue"], cutting at nothing!",\
											M, "[user] slides [his_or_her(user)] razor across [isAI(M) ? "your screen" : "the front of your head"].",\
									user, "You shave off a small patch of [isAI(M) ? "dust stuck to [M]'s screen" : "rust on [M]'s face"].")
		return 0 // runtimes violate law 1, probably
	else if(!M.mutantrace || M.hair_override)
		return 1 // is human or mutant forced to be hairy, should be fine
	else
		var/datum/mutantrace/mutant = M.mutantrace.name
		var/datum/mutantrace/mutant_us = "human"
		if (user?.mutantrace)
			mutant_us = user.mutantrace.name
		switch(mutant)
			if("blob")
				if(barbery_type == "haircut")
					playsound(M, "sound/items/Scissor.ogg", 100, 1)
					user.tri_message("[user] waves [his_or_her(user)] scissors around [M]'s head, snipping at nothing!",\
												M, "[user] snips at something on the upper hemisphere of your macrocellular structure!",\
										user, "You snip at a patch of fuzz stuck to [M]'s gooey outer membrane... thing.")
				else
					user.tri_message("[user] waves [his_or_her(user)] razor around [M]'s head, slashing at nothing!",\
												M, "[user] cuts at something on the upper hemisphere of your macrocellular structure!",\
										user, "You razor at a patch of fuzz stuck to [M]'s gooey outer membrane... thing.")
				return 0
			if("flubber")
				playsound(M, "sound/misc/boing/[rand(1,6)].ogg", 20, 1)
				user.drop_item_throw()
				user.tri_message("[M]'s flubbery body flings [user]'s [barbery_type == "haircut" ? "scissors" : "razor"] out of [his_or_her(user)] hand!",\
											M, "[user] pokes you with [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"], flinging them out of their hand",\
									 user, "[M]'s flubbery body flings the [barbery_type == "haircut" ? "scissors" : "razor"] out of your hand!")
				return 0
			if("flashy")
				boutput(user, "[M]'s bright, flashing skin hurts your eyes.")
				user.take_eye_damage(1)
				return 1
			if("virtual")
				boutput(user, "You prepare to modify M.bioHolder.mobAppearance.customization_[barbery_type == "haircut" ? "first" : "second"].")
				return 1
			if("blank" || "humanoid")
				boutput(user, "You somehow correctly guess which end of [M] is forward.")
				return 1
			if("grey")
				if(barbery_type == "haircut")
					playsound(M, "sound/items/Scissor.ogg", 100, 1)
					user.tri_message("[user] waves [his_or_her(user)] scissors around [M]'s head, snipping at nothing!",\
												M, "You can sense the [mutant_us]'s polite intentions as it pretends that you are not completely bald.",\
										user, "You snip your scissors around [M]'s bald head, ignoring the fact that [he_or_she(user)] is very, very bald.")
				else
					user.tri_message("[user] waves [his_or_her(user)] razor around [M]'s head, cutting at nothing!",\
												M, "You can sense the [mutant_us]'s polite intentions as it pretends that you are completely incapable of having facial hair.",\
										user, "You wave your razor around [M]'s hairless face, ignoring the fact that [he_or_she(user)] is very, very hairless.")
				return 0
			if("lizard")
				if(barbery_type == "haircut")
					playsound(M, "sound/items/Scissor.ogg", 100, 1)
				user.tri_message("[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head.",\
											M, "[user] gives your scales a trim.",\
									 user, "You find a few overgrown scales on [M] head and give them a trim.")
				return 0
			if("zombie")
				boutput(user, "Hair is hair, even if it is mashed full of rotted skin and attached to someone who wants to eat your brain.")
				return 1
			if("vampiric zombie")
				boutput(user, "Hair is hair, even if it is attached to someone who wants to drink your blood.")
				return 1
			if("skeleton")
				if(barbery_type == "haircut")
					playsound(M, "sound/items/Scissor.ogg", 100, 1)
				user.tri_message("[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s skull, [barbery_type == "haircut" ? "snipping" : "cutting"] at nothing!",\
											M, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something on your skull.",\
									 user, "You wave your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s exposed skull, knocking loose some space dust.")
				return 0
			if("Homo nostalgius")
				user.tri_message("[user] tries to cut [M]'s hair, years before that feature was implemented!",\
											M, "[user] tries to violate your vow of oldest-school existence, but fails!",\
									 user, "You try to cut [M]'s hair, but suddenly realize that it could cause a temporal-runtime paradox that would erase all of history!")
				return 0
			if("abomination")
				user.emote("scream")
				if(barbery_type == "haircut")
					playsound(M, "sound/items/Scissor.ogg", 100, 1)
				user.tri_message("[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s writhing, monstrous form!",\
											M, "[user] patronizes us by trying to alter our appearance.",\
									 user, "You muster your courage and manage to give one of the many scraggly, wriggling, <i>familiar</i> patches of hair scattered across [M] a trim!")
				return 0
			if("werewolf")
				M.emote("scream")
				playsound(M, "sound/impact_sounds/Slimy_Cut_1.ogg", 100, 1)
				user.tri_message("[user] [barbery_type == "haircut" ? "snips" : "cuts"] [M]'s ear trying to [barbery_type == "haircut" ? "trim its hair" : "shave it"]!",\
											M, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] your ear! <span class='alert'>FUCK</span>",\
									 user, "You try to [barbery_type == "haircut" ? "snip" : "cut"] some of the fur on [M]'s head, but end up cutting its ear!")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			if("hunter")
				M.emote("scream")
				playsound(M, "sound/impact_sounds/Slimy_Cut_1.ogg", 100, 1)
				user.tri_message("[user] cuts one of [M]'s dreads too deep!",\
											M, "[user] cuts off one of your head protrusions! <span class='alert'>FUCK</span>",\
									 user, "You try to cut [M]'s hair, but find that much of it is part of their head! Gross.")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			if("ithillid")
				if(barbery_type == "haircut")
					playsound(M, "sound/items/Scissor.ogg", 100, 1)
				user.tri_message("[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head.",\
											M, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something on your head.",\
									 user, "You wave your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s fishy head, knocking loose some space barnnacles.")
				return 0
			if("dwarf")
				boutput(user, "You duck down slightly to cut [M]'s hair.")
				return 1
			if("monkey" || "sea monkey")
				M.emote("scream")
				playsound(M, "sound/impact_sounds/Slimy_Cut_1.ogg", 100, 1)
				user.tri_message("[user] [barbery_type == "haircut" ? "snips" : "cuts"] [M]'s ear trying to trim [his_or_her(user)] hair!",\
											M, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] your ear! <span class='alert'>FUCK</span>",\
									 user, "You try to [barbery_type == "haircut" ? "snip" : "cut"] some of the fur on the top of [M]'s head, but end up slicing its ear!")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			if("martian")
				if(barbery_type == "haircut")
					playsound(M, "sound/items/Scissor.ogg", 100, 1)
				user.tri_message("[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head, [barbery_type == "haircut" ? "snipping" : "slashing"] at nothing!",\
											M, "You can sense the [mutant_us] judging your lack of hair and head-shape as it pretends to do its job.",\
									 user, "You wave your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s bald, oddly-shaped head, ignoring the fact that it is very, very bald.")
				return 0
			if("stupid alien baby")
				M.emote("scream")
				playsound(M, "sound/impact_sounds/Slimy_Cut_1.ogg", 100, 1)
				user.tri_message("[user] [barbery_type == "haircut" ? "snips" : "cuts"] one of [M]'s antenna-things!",\
											M, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] your stupid alien dealie-bobbers! <span class='alert'>FUCK</span>",\
									 user, "You nick one of the things sticking out of [M]'s head while pretending to cut at nothing!")
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
					playsound(M, "sound/items/Scissor.ogg", 100, 1)
				user.tri_message("[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s horrible, disgusting, head-shaped mass of gore, [barbery_type == "haircut" ? "snipping" : "cutting"] at nothing!",\
											M, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something on your head.",\
									 user, "You suppress waves of nausea trying to [barbery_type == "haircut" ? "snip" : "cut"] your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head-shaped clump of decayed meat.")
				return 0
			if("cyclops")
				boutput(user, "You mind [M]'s enormous fucking eyeball.")
			if("cat")
				M.emote("scream")
				playsound(M.loc, "sound/voice/animal/cat_hiss.ogg", 50, 1)
				user.tri_message("[user] [barbery_type == "haircut" ? "snips" : "cuts"] [M]'s ear trying to trim its hair!",\
											M, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] your ear! <span class='alert'>FUCK</span>",\
									 user, "You try to [barbery_type == "haircut" ? "snip" : "cut"] some of the fur on [M]'s head, but end up slicing its ear!")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			if("amphibian" || "Shelter Amphibian")
				if(barbery_type == "haircut")
					playsound(M, "sound/items/Scissor.ogg", 100, 1)
				user.tri_message("[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head, snipping at nothing!",\
											M, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something around your head.",\
									 user, "You wave your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s massive frog head, knocking loose some... dead spaceflies?")
				return 0
			if("kudzu")
				boutput(user, "You take a brief moment to figure out what part of [M]'s head isn't vines.")
			if("cow")
				if(barbery_type == "haircut")
					playsound(M, "sound/items/Scissor.ogg", 100, 1)
				user.tri_message("[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head, snipping at nothing!",\
											M, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something around your head, obviouly pretending to be a hairstylist.",\
									 user, "You perform a one-sided LARP with [M], pretending to be an experienced barber working on someone who actually has hair.")
				return 0
			if("roach")
				M.emote("scream")
				playsound(M, "sound/impact_sounds/Slimy_Cut_1.ogg", 100, 1)
				user.tri_message("[user] cuts one of [M]'s antennae!",\
											M, "[user] cuts into your stupid insect dealie-bobbers! <span class='alert'>FUCK</span>",\
									 user, "You slice one of the things sticking out of [M]'s head while pretending to cut at nothing!")
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				return 0
			else
				boutput(user, "You're not quite sure what that is, but decide to cut its hair anyway. If it has any.")
	return 1




/datum/component/barber/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_ATTACKED_PRE)
	. = ..()

/datum/action/bar/haircut
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "haircut"
	var/mob/living/carbon/human/M
	var/mob/living/carbon/human/user
	var/degree_of_success
	var/new_style
	var/which_part


	New(var/mob/living/carbon/human/barbee, var/mob/living/carbon/human/barber, var/succ, var/nustyle, var/whichp)
		src.M = barbee
		src.user = barber
		src.degree_of_success = succ
		src.new_style = nustyle
		src.which_part = whichp
		user.tri_message("[user] begins cutting [M]'s hair.",\
		user, "<span class='notice'>You begin cutting [M]'s hair.</span>",\
		M, "<span class='notice'>[user] begins cutting your hair.</span>")
		playsound(user, "sound/items/Scissor.ogg", 100, 1)
		..()

	onUpdate()
		..()
		if(get_dist(owner, M) > 1 || M == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, M) > 1 || M == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		var/list/hair_list = customization_styles + customization_styles_gimmick
		switch (degree_of_success)
			if (0) // cut their head up and hair off
				playsound(M, "sound/impact_sounds/Flesh_Cut_1.ogg", 100, 1)
				user.tri_message("<span class='alert'>[user] mangles the absolute fuck out of [M]'s head!.</span>",\
				M, "<span class='alert'>[user] mangles the absolute fuck out of your head!</span>",\
				user, "<span class='alert'>You mangle the absolute fuck out of [M]'s head!</span>")
				M.bioHolder.mobAppearance.customization_first = "None"
				M.bioHolder.mobAppearance.customization_second = "None"
				M.bioHolder.mobAppearance.customization_third = "None"
				M.TakeDamage("head", rand(10,20), 0)
				take_bleeding_damage(M, user, 2, DAMAGE_CUT, 1)
				M.emote("scream")
			if (1) // same, but it makes a wig
				playsound(M, "sound/impact_sounds/Slimy_Cut_1.ogg", 100, 1)
				user.tri_message("<span class='alert'>[user] cuts all of [M]'s hair off!.</span>",\
				M, "<span class='alert'>[user] cuts all of your hair off!</span>",\
				user, "<span class='alert'>You cut all of [M]'s hair off!</span>")
				var/obj/item/wig = M.create_wig()
				wig.set_loc(M.loc)
				M.bioHolder.mobAppearance.customization_first = "None"
				M.bioHolder.mobAppearance.customization_second = "None"
				M.bioHolder.mobAppearance.customization_third = "None"
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				M.emote("scream")
			if (2) // you cut their hair into something else
				playsound(M, "sound/items/Scissor.ogg", 100, 1)
				new_style = pick(hair_list)
				M.cust_one_state = hair_list[new_style] || hair_list[new_style]
				M.bioHolder.mobAppearance.customization_first = new_style
				user.tri_message("[user] cuts [M]'s hair.",\
											M, "<span class='notice'>[user] cuts your hair.</span>",\
										user, "<span class='notice'>You cut [M]'s hair, but it doesn't quite look like what you had in mind! Maybe they wont notice?</span>")
			if (3) // you did it !!
				if (new_style == "None")
					var/obj/item/wig = M.create_wig()
					wig.set_loc(M.loc)
					M.bioHolder.mobAppearance.customization_first = "None"
					M.bioHolder.mobAppearance.customization_second = "None"
					M.bioHolder.mobAppearance.customization_third = "None"
				else
					user.tri_message("[user] cuts [M]'s hair.",\
					M, "<span class='notice'>[user] cuts your hair.</span>",\
					user, "<span class='notice'>You cut [M]'s hair.</span>")
					switch(which_part)
						if (1)
							M.cust_one_state = customization_styles[new_style] || customization_styles_gimmick[new_style]
							M.bioHolder.mobAppearance.customization_first = new_style
						if (2)
							M.cust_two_state = customization_styles[new_style] || customization_styles_gimmick[new_style]
							M.bioHolder.mobAppearance.customization_second = new_style
						if (3)
							M.cust_three_state = customization_styles[new_style] || customization_styles_gimmick[new_style]
							M.bioHolder.mobAppearance.customization_third = new_style

		M.set_clothing_icon_dirty() // why the fuck is hair updated in clothing
		M.update_colorful_parts()
		..()

	onInterrupt()
		boutput(owner, "You were interrupted!")
		..()

/datum/action/bar/shave
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "shave"
	var/mob/living/carbon/human/M
	var/mob/living/carbon/human/user
	var/degree_of_success
	var/new_style
	var/which_part

	New(var/mob/living/carbon/human/barbee, var/mob/living/carbon/human/barber, var/succ, var/nustyle, var/whichp)
		src.M = barbee
		src.user = barber
		src.degree_of_success = succ
		src.new_style = nustyle
		src.which_part = whichp
		user.tri_message("[user] begins shaving [M].",\
		user, "<span class='notice'>You begin shaving [M].</span>",\
		M, "<span class='notice'>[user] begins shaving you.</span>")
		..()

	onUpdate()
		..()
		if(get_dist(owner, M) > 1 || M == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, M) > 1 || M == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		var/list/mustaches =list("Watson", "Chaplin", "Selleck", "Van Dyke", "Hogan")
		var/list/beards  = list("Neckbeard", "Elvis", "Abe", "Chinstrap", "Hipster", "Wizard")
		var/list/full = list("Goatee", "Full Beard", "Long Beard")
		var/list/hair_list = mustaches + beards + full
		switch (degree_of_success)
			if (0) // cut their head up and hair off
				playsound(M, "sound/impact_sounds/Flesh_Cut_1.ogg", 100, 1)
				user.tri_message("<span class='alert'>[user] mangles the absolute fuck out of [M]'s head!.</span>",\
				M, "<span class='alert'>[user] mangles the absolute fuck out of your head!</span>",\
				user, "<span class='alert'>You mangle the absolute fuck out of [M]'s head!</span>")
				M.bioHolder.mobAppearance.customization_first = "None"
				M.bioHolder.mobAppearance.customization_second = "None"
				M.bioHolder.mobAppearance.customization_third = "None"
				M.TakeDamage("head", rand(10,20), 0)
				take_bleeding_damage(M, user, 2, DAMAGE_CUT, 1)
				M.emote("scream")
			if (1) // same, but it makes a wig
				playsound(M, "sound/impact_sounds/Slimy_Cut_1.ogg", 100, 1)
				user.tri_message("<span class='alert'>[user] cuts all of [M]'s hair off!.</span>",\
				M, "<span class='alert'>[user] cuts all of your hair off!</span>",\
				user, "<span class='alert'>You cut all of [M]'s hair off!</span>")
				var/obj/item/wig = M.create_wig()
				wig.set_loc(M.loc)
				M.bioHolder.mobAppearance.customization_first = "None"
				M.bioHolder.mobAppearance.customization_second = "None"
				M.bioHolder.mobAppearance.customization_third = "None"
				M.TakeDamage("head", rand(5,10), 0)
				take_bleeding_damage(M, user, 1, DAMAGE_CUT, 1)
				M.emote("scream")
			if (2) // you cut their hair into something else
				playsound(user, "sound/items/Scissor.ogg", 100, 1)
				new_style = pick(hair_list)
				M.cust_two_state = hair_list[new_style] || hair_list[new_style]
				M.bioHolder.mobAppearance.customization_second = new_style
				user.tri_message("[user] finishes shaving [M].",\
											M, "<span class='notice'>[user] shaves you.</span>",\
									user, "<span class='notice'>You shave [M], but it doesn't quite look like what you had in mind! Maybe they wont notice?</span>")
			if (3) // you did it !!
				user.tri_message("[user] finishes shaving [M].",\
											M, "<span class='notice'>[user] shaves you.</span>",\
										user, "<span class='notice'>You shave [M].</span>")
				if (new_style == "None")
					var/obj/item/wig = M.create_wig()
					wig.set_loc(M.loc)
					M.bioHolder.mobAppearance.customization_first = "None"
					M.bioHolder.mobAppearance.customization_second = "None"
					M.bioHolder.mobAppearance.customization_third = "None"
				else
					switch(which_part)
						if (1)
							M.cust_one_state = customization_styles[new_style] || customization_styles_gimmick[new_style]
							M.bioHolder.mobAppearance.customization_first = new_style
						if (2)
							M.cust_two_state = customization_styles[new_style] || customization_styles_gimmick[new_style]
							M.bioHolder.mobAppearance.customization_second = new_style
						if (3)
							M.cust_three_state = customization_styles[new_style] || customization_styles_gimmick[new_style]
							M.bioHolder.mobAppearance.customization_third = new_style
		M.set_clothing_icon_dirty() // why the fuck is hair updated in clothing
		M.update_colorful_parts()
		..()

	onInterrupt()
		boutput(owner, "You were interrupted!")
		..()

#undef HAIRCUT
#undef SHAVE
#undef BARBERY_FAILURE
#undef TOOLMODE_DEACTIVATED
#undef TOOLMODE_ACTIVATED
