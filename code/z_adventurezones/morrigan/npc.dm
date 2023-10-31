////▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Dialogue NPC ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/obj/dialogueobj/hobo
	icon = 'icons/obj/trader.dmi'
	icon_state = "hoboman"
	density = TRUE
	anchored = ANCHORED_ALWAYS
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/hobo(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/hobo
	dialogueName = "Hobo"
	start = /datum/dialogueNode/hobo_start
	maxDistance = 1

/datum/dialogueNode/hobo_start
	linkText = "..."
	links = list(/datum/dialogueNode/hobo_who,/datum/dialogueNode/hobo_question,/datum/dialogueNode/hobo_where)

	getNodeText(var/client/C)
		return pick("I haven't seen my wife in 30 years, only the drugs bring her back.", "Fuck off already.", "I need me drugs...")

/datum/dialogueNode/hobo_who
	linkText = "Who are you?"
	links = list()

	getNodeText(var/client/C)
		return "None of your fucking business is who I am yeah ? Just call me 'John'."

/datum/dialogueNode/hobo_question
	linkText = "How do I leave?"
	links = list(/datum/dialogueNode/hobo_thank)
	nodeText = "Bloody scammed yeah."

	getNodeText(var/client/C)
		return "If you can get past the addicts and the creepy shit out there, I hear there's some old id hidden in some bum middle of here. Us sane few barricaded ourselves in, if you go out there you're on your own."
/datum/dialogueNode/hobo_where
	linkText = "Where am I ?"
	links = list(/datum/dialogueNode/hobo_thank)
	nodeText = "Bloody scammed yeah."

	getNodeText(var/client/C)
		return "Where do you think ? Fuckin' paradise. You're on Lero you bumbling ape. Otherwise known as the slammer. Don't know what you've done, don't care either just keep away from me and my mates' shit."

/datum/dialogueNode/hobo_thank
	linkText = "Thank you."
	links = list()

	getNodeText(var/client/C)
		return pick("Whatever.", "Just bugger off already will you?", "Fuck off already.", "Cool, mate.")

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Corpses ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
/obj/mapping_helper/mob_spawn/corpse/human/hobo
	spawn_type = /mob/living/carbon/human/hobo

/obj/mapping_helper/mob_spawn/corpse/human/ntop
	spawn_type = /mob/living/carbon/human/morriganntop

/obj/mapping_helper/mob_spawn/corpse/human/morrigansec
	spawn_type = /mob/living/carbon/human/morrigansec

/obj/mapping_helper/mob_spawn/corpse/human/morrigan_executive
	spawn_type = /mob/living/carbon/human/morrigan_executive

/obj/mapping_helper/mob_spawn/corpse/human/morrigan_rnd
	spawn_type = /mob/living/carbon/human/morrigan_rnd

/obj/mapping_helper/mob_spawn/corpse/human/morrigan_quality
	spawn_type = /mob/living/carbon/human/morrigan_quality

/obj/mapping_helper/mob_spawn/corpse/human/morrigan_doctor
	spawn_type = /mob/living/carbon/human/morrigan_doctor

/obj/mapping_helper/mob_spawn/corpse/human/morrigan_prisoner
	spawn_type = /mob/living/carbon/human/morrigan_prisoner

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ No AI NPC ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
/mob/living/carbon/human/syndicatemorrigan
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/head/morrigan/swarden), SLOT_HEAD)
		src.equip_new_if_possible((/obj/item/clothing/mask/gas/swat), SLOT_WEAR_MASK)
		src.equip_new_if_possible((/obj/item/clothing/under/rank/head_of_security/fancy_alt), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/clothing/suit/armor/vest), SLOT_WEAR_SUIT)
		src.equip_new_if_possible((/obj/item/clothing/gloves/black), SLOT_GLOVES)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/carbon/human/syndicatemorrigan/rowdy

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(10) && !src.stat)
			src.say(pick( "Got us a few visitors!", "Looking forward to lunch time...", "Ha, you're in our turf now.", "Unit 78 requesting orders.",
			"Hey! Who took my gum?"))

/mob/living/carbon/human/syndicatemorrigan/cautious

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(10) && !src.stat)
			src.say(pick( "Have you double checked them for contraband?", "We should place them in handcuffs.", "Hey, quit slacking off!", "Unit 25C confirming prisoners.",
			"Rumor has it, there's trouble stiring on Morrigan."))

/mob/living/carbon/human/syndicatemorrigan/eager

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(10) && !src.stat)
			src.say(pick( "Unit 90A reporting for duty!", "I got this!", "Logging them in now!", "Aw yeah, we got ourself another one !",
			"I'm up for promotion! Think I'll get it ?"))

/mob/living/carbon/human/syndicatemorrigan/veteran

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(10) && !src.stat)
			src.say(pick( "Same old, same old.", "I'm due for a nap, get me a coffee.", "Any of you got a lighter?", "I'm not paid enough to care.",
			"Just create a new record."))
/mob/living/carbon/human/syndicatemorrigan/sleepy

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.stat)
			return

		src.setStatusMin("unconscious", 10 SECONDS)

		if (prob(2) && !src.stat)
			src.emote("snore")

/mob/living/carbon/human/syndicatemorriganeng
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/head/helmet/hardhat), SLOT_HEAD)
		src.equip_new_if_possible((/obj/item/clothing/glasses/toggleable/meson), SLOT_GLASSES)
		src.equip_new_if_possible((/obj/item/clothing/under/misc/casualjeansyel), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/clothing/suit/hi_vis), SLOT_WEAR_SUIT)
		src.equip_new_if_possible((/obj/item/clothing/gloves/yellow), SLOT_GLOVES)
		src.equip_new_if_possible((/obj/item/clothing/shoes/magnetic), SLOT_SHOES)


	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(0) && !src.stat)
			src.emote("scream")

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/carbon/human/syndicatemorrigandoc
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/glasses/nightvision/sechud), SLOT_GLASSES)
		src.equip_new_if_possible((/obj/item/clothing/mask/surgical), SLOT_WEAR_MASK)
		src.equip_new_if_possible((/obj/item/clothing/under/scrub), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/clothing/suit/space/syndicate/specialist/medic), SLOT_WEAR_SUIT)
		src.equip_if_possible((/obj/item/clothing/gloves/black), SLOT_GLOVES)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(0) && !src.stat)
			src.emote("scream")

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)
/mob/living/carbon/human/hobo
	New()
		..()
		src.equip_new_if_possible(pick(/obj/item/clothing/head/apprentice, /obj/item/clothing/head/beret/random_color, /obj/item/clothing/head/black, /obj/item/clothing/head/chav,
		/obj/item/clothing/head/fish_fear_me/emagged, /obj/item/clothing/head/flatcap, /obj/item/clothing/head/party/random, /obj/item/clothing/head/plunger,
		/obj/item/clothing/head/towel_hat, /obj/item/clothing/head/wizard/green, /obj/item/clothing/head/snake, /obj/item/clothing/head/raccoon,
		/obj/item/clothing/head/bandana/random_color), SLOT_HEAD)
		src.equip_new_if_possible(pick(/obj/item/clothing/under/gimmick/yay, /obj/item/clothing/under/misc/casualjeansgrey, /obj/item/clothing/under/misc/dirty_vest,
		/obj/item/clothing/under/misc/yoga/communist, /obj/item/clothing/under/patient_gown, /obj/item/clothing/under/shorts/random_color,
		/obj/item/clothing/under/misc/flannel), SLOT_W_UNIFORM)
		src.equip_new_if_possible(pick(/obj/item/clothing/suit/walpcardigan, /obj/item/clothing/suit/gimmick/hotdog, /obj/item/clothing/suit/loosejacket,
		/obj/item/clothing/suit/torncloak/random, /obj/item/clothing/suit/gimmick/guncoat/dirty, /obj/item/clothing/suit/bathrobe, /obj/item/clothing/suit/apron,
		/obj/item/clothing/suit/apron/botanist, /obj/item/clothing/suit/bedsheet/random), SLOT_WEAR_SUIT)
		src.equip_new_if_possible((/obj/item/clothing/shoes/tourist), SLOT_SHOES)

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(2) && !src.stat)
			src.emote("scream")

	initializeBioholder()
		. = ..()
		randomize_look(src, FALSE, FALSE, TRUE, TRUE, TRUE, FALSE, src)
		bioHolder.mobAppearance.gender = "male"
		bioHolder.age = rand(50, 90)
		bioHolder.mobAppearance.customization_first_color = pick("#292929", "#504e00" , "#1a1016")
		bioHolder.mobAppearance.customization_second_color = pick("#292929", "#504e00" , "#1a1016")
		var/beard = pick(/datum/customization_style/hair/gimmick/shitty_beard, /datum/customization_style/hair/gimmick.wiz, /datum/customization_style/beard/braided,
		/datum/customization_style/beard/abe, /datum/customization_style/beard/fullbeard, /datum/customization_style/beard/longbeard, /datum/customization_style/beard/trampstains)
		bioHolder.mobAppearance.customization_second = new beard

/mob/living/carbon/human/hobo/vladimir
	real_name = "Vladimir Dostoevsky"

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(10) && !src.stat)
			src.say(pick( "I neeeda zzrink...", "Fugh...", "Where me am...", "I pischd on duh floor...","Why duh bluee ann sen how...","AAAAAAAAAAAAAAAAH CHOOO!"))

	initializeBioholder()
		. = ..()
		randomize_look(src, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, src)

/mob/living/carbon/human/hobo/laraman
	real_name = "The Lara Man"

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.stat)
			return

		src.setStatusMin("weakened", 10 SECONDS)
		if (prob(10))
			src.say(pick( "Don't look for Lara...", "Lara??", "Lara the oven!", "Please don't talk to Lara", "LAAAAARRRAAAAAAAA!!!" ,"L-Lara.","Do you know where Lara is?"))

	initializeBioholder()
		. = ..()
		randomize_look(src, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, src)


/mob/living/carbon/human/morrigansec
	New()
		..()
		src.equip_new_if_possible(pick(/obj/item/clothing/head/morrigan/sberet), SLOT_HEAD)
		src.equip_new_if_possible((/obj/item/clothing/mask/gas/swat), SLOT_WEAR_MASK)
		src.equip_new_if_possible((/obj/item/clothing/under/rank/morrigan/sec), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/clothing/suit/armor/vest), SLOT_WEAR_SUIT)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/carbon/human/morriganntop
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/under/rank/morrigan/robofab), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/storage/backpack/brown), SLOT_BACK)
		src.equip_new_if_possible((/obj/item/card/id/morrigan/captain), SLOT_IN_BACKPACK)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)

	initializeBioholder()
		. = ..()
		randomize_look(src, FALSE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/carbon/human/morrigan_prisoner
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/under/misc/prisoner), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/storage/backpack/brown), SLOT_BACK)
		src.equip_new_if_possible((/obj/item/weldingtool), SLOT_IN_BACKPACK)
		src.equip_new_if_possible((/obj/item/clothing/shoes/orange), SLOT_SHOES)

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)
/mob/living/carbon/human/morrigan_rnd
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/under/rank/morrigan/robofab), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/storage/backpack/engineering), SLOT_BACK)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/carbon/human/morrigan_quality
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/under/rank/morrigan/quality), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/storage/backpack/green), SLOT_BACK)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/carbon/human/morrigan_executive
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/under/rank/morrigan/executive), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/clothing/suit/morrigan/executive), SLOT_WEAR_SUIT)
		src.equip_new_if_possible((/obj/item/clothing/mask/swat/haf), SLOT_WEAR_MASK)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)
		src.equip_new_if_possible((/obj/item/card/id/morrigan/all_access), SLOT_WEAR_ID)

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/carbon/human/morrigan_doctor
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/under/rank/medical/april_fools), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/storage/backpack/blue), SLOT_BACK)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ NPC Critters ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
/mob/living/critter/human/hobo
	name = "Derange Addict"
	desc = "They have a crazed look in their eyes"
	health_brute = 20
	health_burn = 20
	faction = FACTION_GENERIC
	ai_type = /datum/aiHolder/aggressive
	human_to_copy = /mob/living/carbon/human/hobo

/mob/living/critter/human/morrigan_quality
	name = "Quality Assurance Worker"
	desc = "You don't recognize them"
	health_brute = 20
	health_burn = 20
	faction = FACTION_DERELICT
	ai_type = /datum/aiHolder/ranged
	human_to_copy = /mob/living/carbon/human/morrigan_quality

	seek_target(range)
		. = ..()

		if (length(.) && prob(10))
			src.say(pick("Who...who are you?!", "Get away from here!", "SECURITY, HELP!", "You aren't meant to be here!", "It's because of people like you!", "You caused this!"))

/mob/living/critter/human/morrigan_quality/knife
	ai_type = /datum/aiHolder/aggressive
	hand_count = 2

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb/sword
		HH.name = "left hand"
		HH.suffix = "-L"
		HH.icon_state = "blade"
		HH.limb_name = "combat knife"
		HH.can_hold_items = FALSE
		HH.object_for_inhand = /obj/item/dagger

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right arm"

/mob/living/critter/human/morrigan_quality/bat
	ai_type = /datum/aiHolder/aggressive
	hand_count = 2

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb
		HH.name = "left hand"
		HH.suffix = "-L"
		HH.icon_state = "blade"
		HH.limb_name = "scrap club"
		HH.can_hold_items = FALSE
		HH.object_for_inhand = /obj/item/scrapweapons/weapons/club

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right arm"
/mob/living/critter/human/morrigan_rnd
	name = "R&D Worker"
	desc = "You don't recognize them"
	health_brute = 20
	health_burn = 20
	faction = FACTION_DERELICT
	ai_type = /datum/aiHolder/ranged
	human_to_copy = /mob/living/carbon/human/morrigan_rnd

	seek_target(range)
		. = ..()

		if (length(.) && prob(10))
			src.say(pick("Who...who are you?!", "Get away from here!", "SECURITY, HELP!", "You aren't meant to be here!", "It's because of people like you!", "You caused this!"))

/mob/living/critter/human/morrigan_rnd/knife
	ai_type = /datum/aiHolder/aggressive
	hand_count = 2

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb/sword
		HH.name = "left hand"
		HH.suffix = "-L"
		HH.icon_state = "blade"
		HH.limb_name = "combat knife"
		HH.can_hold_items = FALSE
		HH.object_for_inhand = /obj/item/dagger

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right arm"
/mob/living/critter/human/morrigan_rnd/bat
	ai_type = /datum/aiHolder/aggressive
	hand_count = 2

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb
		HH.name = "left hand"
		HH.suffix = "-L"
		HH.icon_state = "blade"
		HH.limb_name = "scrap club"
		HH.can_hold_items = FALSE
		HH.object_for_inhand = /obj/item/scrapweapons/weapons/club

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right arm"

/mob/living/critter/human/hobo/dagger
	hand_count = 2

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "left hand"
		HH.suffix = "-L"
		HH.icon_state = "handl"
		HH.limb_name = "left arm"

		HH = hands[2]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb/sword
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "scrap dagger"
		HH.can_hold_items = FALSE
		HH.object_for_inhand = /obj/item/scrapweapons/weapons/dagger

	seek_target(range)
		. = ..()

		if (length(.) && prob(10))
			src.say(pick("FUCK FUCK FUCK!", "CR-CRANK BABY!", "MORMGHRMGINIAD!", "YOU WERE THERE!!", "Ohh...oohhh....", "BUTTER THEY HAD MY BUTTER!!!", "Shrughaldin...AAAAAH!", "SPIDER FACE!!"))


/mob/living/critter/human/hobo/club
	hand_count = 2

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb
		HH.name = "left hand"
		HH.suffix = "-L"
		HH.icon_state = "blade"
		HH.limb_name = "scrap club"
		HH.can_hold_items = FALSE
		HH.object_for_inhand = /obj/item/scrapweapons/weapons/club

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right arm"

	seek_target(range)
		. = ..()

		if (length(.) && prob(10))
			src.say(pick("WOOOOOSHHH WEEEEEEE!", "ORDER 3 SANDWICHES, 3 OF THEM!", "IS THAT YOU MOM ??!", "Urgh...piss...", "If you are injured, I advise applying pressure to the wound until the medics arrive.", "KAAAAAAAWAAAAAAAAAAAAA!", "Rat FOOD!!", "XDEOBLD....EOWA"))


/mob/living/critter/human/hobo/machete
	hand_count = 2

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb/sword
		HH.name = "left hand"
		HH.suffix = "-L"
		HH.icon_state = "blade"
		HH.limb_name = "scrap machete"
		HH.can_hold_items = FALSE
		HH.object_for_inhand = /obj/item/scrapweapons/weapons/machete

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right arm"

	seek_target(range)
		. = ..()

		if (length(.) && prob(10))
			src.say(pick("WEEEEWOOOOOWEEEEWOOOOO.", "A B C D E ....", "LOOK AT ME, I AM THE CAPTAIN NOW.", "Fuckers got my cash...", "WANNA SCRAP YOU WIMP?", "TOENAILS, TOENAILS...", "Mmmmerghh...mmm....", "OWNED??"))




