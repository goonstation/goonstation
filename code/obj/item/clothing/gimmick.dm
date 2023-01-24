
// -------------------- VR --------------------
/obj/item/clothing/under/virtual
	name = "virtual jumpsuit"
	desc = "These clothes are unreal."
	icon_state = "virtual"
	item_state = "virtual"

/obj/item/clothing/shoes/virtual
	name = "virtual shoes"
	desc = "How can you simulate the sole?"
	icon_state = "virtual"
// --------------------------------------------

// -------------------- Hunter --------------------
/obj/item/clothing/mask/hunter
	name = "Hunter Mask"
	desc = "It has some kind of heat tracking and voice modulation equipment built into it."
	icon_state = "hunter"
	item_state = "helmet"
	c_flags = COVERSMOUTH | COVERSEYES | MASKINTERNALS
	see_face = 0
	item_function_flags = IMMUNE_TO_ACID

	New()
		..()
		src.vchange = new(src) // Built-in voice changer (Convair880).
		if(istype(src.loc, /mob/living))
			var/mob/M = src.loc
			src.AddComponent(/datum/component/self_destruct, M)

	equipped(mob/user)
		. = ..()
		APPLY_ATOM_PROPERTY(user, PROP_MOB_THERMALVISION_MK2, src)

	unequipped(mob/user)
		REMOVE_ATOM_PROPERTY(user, PROP_MOB_THERMALVISION_MK2, src)
		. = ..()

/obj/item/clothing/under/gimmick/hunter
	name = "Hunter Suit"
	desc = "Fishnets, bandoliers and plating? What the hell?"
	icon_state = "hunter"
	item_state = "hunter"
	item_function_flags = IMMUNE_TO_ACID

/obj/item/clothing/shoes/cowboy/hunter
	name = "Space Cowboy Boots"
	desc = "Fashionable alien footwear. The sole appears to be rubberized,  preventing slipping on wet surfaces."
	c_flags = NOSLIP // Don't slip on gibs all the time, d'oh (Convair880).
	item_function_flags = IMMUNE_TO_ACID
// --------------------------------------------------

/obj/item/clothing/head/helmet/space/santahat
	name = "2k13 vintage santa hat"
	desc = "Uhh, how long has this even been here? It looks kinda grubby and, uhh, singed. Wait, is that blood?"
	icon_state = "santa"
	item_state = "santahat"

	noslow
		setupProperties()
			..()
			setProperty("space_movespeed", 0.0)

/obj/item/clothing/suit/space/santa
	name = "santa suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES

	noslow
		setupProperties()
			..()
			setProperty("space_movespeed", 0.0)

/obj/item/clothing/mask/owl_mask
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"
	item_state = "owl_mask"
	see_face = 0

	equipped(var/mob/user)
		..()
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under/gimmick/owl))
				user.unlock_medal("Wonk", 1)

	custom_suicide = 1
	suicide_in_hand = 0
	suicide(var/mob/user as mob)
		if (!user || user.wear_mask != src || !src.user_can_suicide(user))
			return 0
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.w_uniform, /obj/item/clothing/under/gimmick/owl) && !(user.stat || user.getStatusDuration("paralysis")))
				user.visible_message("<span class='alert'><b>[user] hoots loudly!</b></span>")
				user.owlgib()
				return 1
			else
				user.visible_message("[user] hoots softly.")
				user.suiciding = 0
				return 0
		else
			return 0

/obj/item/clothing/under/gimmick/owl
	name = "owl suit"
	desc = "Twoooo!"
	icon_state = "owl"
	item_state = "owl"

	equipped(var/mob/user)
		..()
		if (!user)
			return 0
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.w_uniform != src)
				return 0
			if (H.wear_mask && istype(H.wear_mask, /obj/item/clothing/mask/owl_mask))
				user.unlock_medal("Wonk", 1)

	custom_suicide = 1
	suicide_in_hand = 0
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.head, /obj/item/clothing/mask/owl_mask))
				user.visible_message("<span class='alert'><b>[user] hoots loudly!</b></span>")
				user.owlgib()
				return 1
			else
				user.visible_message("[user] hoots softly.")
				user.suiciding = 0
				return 0
		else
			return 0

/obj/item/clothing/mask/smile
	name = "Smiling Face"
	desc = ":)"
	icon_state = "smiles"
	see_face = 0

/obj/item/clothing/under/gimmick/waldo
	name = "striped shirt and jeans"
	desc = "A very distinctive outfit."
	icon_state = "waldo"
	item_state = "waldo"

/obj/item/clothing/under/gimmick/odlaw
	name = "yellow-striped shirt and jeans"
	desc = "A rather sinister outfit."
	icon_state = "odlaw"
	item_state = "odlaw"

/obj/item/clothing/under/gimmick/fake_waldo
	name = "striped shirt and jeans"
	desc = "A very odd outfit."
	icon_state = "waldont1"
	item_state = "waldont1"
	New()
		..()
		icon_state = "waldont[rand(1,6)]"
		item_state = "waldont[rand(1,6)]"

/obj/item/clothing/head/waldohat
	name = "Bobble Hat and Glasses"
	desc = "A funny-looking hat and glasses."
	icon_state = "waldo"
	item_state = "santahat"

/obj/item/clothing/head/odlawhat
	name = "Black-striped Bobble Hat and Glasses"
	desc = "An evil-looking hat and glasses."
	icon_state = "odlaw"
	item_state = "o_shoes"

/obj/item/clothing/head/fake_waldohat
	name = "Bobble Hat and Glasses"
	desc = "An odd-looking hat and glasses."
	icon_state = "waldont1"
	item_state = "santahat"
	New()
		..()
		icon_state = "waldont[rand(1,5)]"

/obj/item/clothing/gloves/cyborg
	desc = "beep boop borp"
	name = "cyborg gloves"
	icon_state = "black"
	item_state = "r_hands"
	material_prints = "circuit shards"
	setupProperties()
		..()
		setProperty("conductivity", 1)

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	icon_state = "boots"

/obj/item/clothing/suit/cyborg_suit
	name = "cyborg costume"
	desc = "A costume of a standard-weight NanoTrasen cyborg unit. Suspiciously accurate."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_armor.dmi'
	icon_state = "cyborg"
	item_state = "cyborg"
	flags = FPRINT | TABLEPASS | CONDUCT
	hides_from_examine = C_UNIFORM|C_GLOVES

/obj/item/clothing/under/gimmick/johnny
	name = "Johnny~~"
	desc = "Johnny~~"
	icon_state = "johnny"
	item_state = "johnny"

/obj/item/clothing/suit/johnny_coat
	name = "Johnny~~"
	desc = "Johnny~~"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "johnny"
	item_state = "johnny"
	flags = FPRINT | TABLEPASS

// UNUSED COLORS

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	item_state = "headset" // lol

/obj/item/clothing/under/gimmick/police
	name = "police uniform"
	desc = "Move along, nothing to see here."
	icon_state = "police"
	item_state = "police"

/obj/item/clothing/head/helmet/bobby
	name = "constable's helmet"
	desc = "Heh. Lookit dat fukken helmet."
	icon_state = "policehelm"
	item_state = "helmet"

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "flat_cap"
	item_state = "detective"

/obj/item/clothing/head/devil
	name = "devil horns"
	desc = "Plastic devil horns attached to a headband as part of a Halloween costume."
	icon_state = "devil"
	item_state = "devil"

// Donk clothes

/obj/item/clothing/head/helmet/space/donk
	name = "\improper Donk space helmet"
	desc = "A helmet with a self-contained pressurized environment. Kinda resembles a motorcycle helmet."
	icon_state = "EOD"

/obj/item/clothing/under/gimmick/donk
	name = "\improper Donk space suit"
	desc = "Some Donk brand spacewear. It's uncomfortable and made out of some really crinkly, metallic materials. Amazingly, this seems to be vacuum sealed."
	icon_state = "donk"
	item_state = "donk"
	c_flags = SPACEWEAR
	body_parts_covered = TORSO|LEGS|ARMS
	protective_temperature = 1000

	setupProperties()
		..()
		setProperty("heatprot", -20)//it's made out of foil, that would make fire a LOT worse
		setProperty("coldprot", 20)
		setProperty("radprot", 5)

// Donkini

/obj/item/clothing/under/gimmick/donkini
	name = "\improper Donkini"
	desc = "A Donk suit that appears to have been gussied and repurposed as a space bikini. Snazzy, but utterly useless for space travel."
	icon_state = "donkini"
	item_state = "donkini"

// Duke Nukem

/obj/item/clothing/under/gimmick/duke
	name = "the duke's suit"
	desc = "You have come here to chew bubblegum and kick ass...and you're all out of bubblegum."
	icon_state = "duke"
	item_state = "duke"

/obj/item/clothing/suit/armor/vest/abs
	name = "the duke's armor"
	desc = "Always bet on Duke. Just don't expect the bet to pay off anytime soon. Or at all, really."
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	icon_state = "dukeabs"
	item_state = "dukeabs"

/obj/item/clothing/head/biker_cap
	name = "Biker Cap"
	desc = "It looks pretty fabulous, to be honest."
	icon_state = "bikercap"
	item_state = "bgloves"

// Batman

/obj/item/clothing/suit/armor/batman
	name = "batsuit"
	desc = "THE SYMBOL ON MY CHEST IS THAT OF A BAT"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "batsuit"
	item_state = "batsuit"
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES

/obj/item/clothing/mask/batman
	name = "batmask and batcape"
	desc = "I'M THE GODDAMN BATMAN."
	icon_state = "batman"
	item_state = "bl_suit"
	c_flags = SPACEWEAR | COVERSEYES | COVERSMOUTH | MASKINTERNALS //The bat respirator is a real thing. See also: Batman can breathe in space.
	see_face = 0

/obj/item/clothing/head/helmet/batman
	name = "batcowl"
	desc = "I AM THE BAT"
	icon_state = "batcowl"
	item_state = "batcowl"

// see procitizen.dm for batman verbs

/// Cluwne

/obj/item/clothing/mask/cursedclown_hat
	name = "cursed clown mask"
	desc = "This is a very, very odd looking mask."
	icon_state = "cursedclown"
	item_state = "cclown_hat"
	//MBC : cluwne mask starts as removable because it makes click+drag inventory management work until the mask sticks on
	//undo if bug
	cant_self_remove = 0
	cant_other_remove = 0
	var/infectious = 0

/obj/item/clothing/mask/cursedclown_hat/equipped(var/mob/user, var/slot)
	..()
	var/mob/living/carbon/human/Victim = user
	if(istype(Victim) && slot == SLOT_WEAR_MASK)
		boutput(user, "<span class='alert'><B> The mask grips your face!</B></span>")
		src.desc = "This is never coming off... oh god..."
		// Mostly for spawning a cluwne car and clothes manually.
		// Clown's Revenge and Cluwning Around take care of every other scenario (Convair880).
		src.cant_self_remove = 1
		src.cant_other_remove = 1
		if(src.infectious && user.reagents)
			user.reagents.add_reagent("painbow fluid",10)
	return

/obj/item/clothing/mask/cursedclown_hat/custom_suicide = 1
/obj/item/clothing/mask/cursedclown_hat/suicide_in_hand = 0
/obj/item/clothing/mask/cursedclown_hat/suicide(var/mob/user, var/slot)
	if (user.wear_mask == src)
		boutput(user, "<span class='alert'>You can't get the mask off to look into its eyes!</span>")

	if (!user || GET_DIST(user, src) > 0)
		return 0
	user.visible_message("<span class='alert'><b>[user] gazes into the eyes of the [src.name]. The [src.name] gazes back!</b></span>") //And when you gaze long into an abyss, the abyss also gazes into you.
	SPAWN(1 SECOND)
		playsound(src.loc, 'sound/voice/chanting.ogg', 25, 0, 0)
		playsound(src.loc, pick('sound/voice/cluwnelaugh1.ogg','sound/voice/cluwnelaugh2.ogg','sound/voice/cluwnelaugh3.ogg'), 35, 0, 0)
		sleep(1.5 SECONDS)
		user.emote("scream")
		sleep(1.5 SECONDS)
		user.implode()
	return 1

/obj/item/clothing/shoes/cursedclown_shoes
	name = "cursed clown shoes"
	desc = "Moldering clown flip flops. They're neon green for some reason."
	icon_state = "cursedclown"
	item_state = "cclown_shoes"
	step_sound = "cluwnestep"
	compatible_species = list("human", "cow")
	cant_self_remove = 1
	cant_other_remove = 1
	step_lots = 1
	step_priority = 999

/obj/item/clothing/under/gimmick/cursedclown
	name = "cursed clown suit"
	desc = "It wasn't already?"
	icon_state = "cursedclown"
	item_state = "cursedclown"
	cant_self_remove = 1
	cant_other_remove = 1

	New()
		..()
		AddComponent(/datum/component/clown_disbelief_item)

/obj/item/clothing/gloves/cursedclown_gloves
	name = "cursed white gloves"
	desc = "These things smell terrible, and they're all lumpy. Gross."
	icon_state = "latex"
	item_state = "lgloves"
	cant_self_remove = 1
	cant_other_remove = 1
	material_prints = "greasy polymer fibers"

	setupProperties()
		..()
		setProperty("conductivity", 1) //i mean it's for cluwnes

// blue clown thing
// it was called the blessed clown for the like half week it existed before

/obj/item/clothing/mask/clown_hat/blue
	name = "blue clown mask"
	desc = "Hey, still looks pretty happy for being so blue."
	icon_state = "blessedclown"
	item_state = "bclown_hat"
	bald_desc_state = "For sad clowns who want to show off their hair!"

/obj/item/clothing/under/misc/clown/blue
	name = "blue clown suit"
	desc = "Proof that if you truly believe in yourself, you can accomplish anything. Honk."
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'
	icon_state = "blessedclown"
	item_state = "blessedclown"

/obj/item/clothing/shoes/clown_shoes/blue
	name = "blue clown shoes"
	desc = "Normal clown shoes, just blue instead of red."
	icon_state = "blessedclown"
	item_state = "bclown_shoes"

// purple, pink, and yellow clowns!
// TODO: inhand sprites (item_state)

/obj/item/clothing/mask/clown_hat/purple
	name = "purple clown mask"
	desc = "Purple is a very flattering color on almost everyone."
	icon_state = "purpleclown"
	//item_state = "purpleclown"
	bald_desc_state = "For fancy clowns who want to show off their hair!"

/obj/item/clothing/under/misc/clown/purple
	name = "purple clown suit"
	desc = "What kind of clown are you for wearing this color? It's a good question, honk."
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
	icon_state = "purpleclown"
	//item_state = "purpleclown"

/obj/item/clothing/shoes/clown_shoes/purple
	name = "purple clown shoes"
	desc = "Normal clown shoes, just purple instead of red."
	icon_state = "purpleclown"
	//item_state = "purpleclown"

/obj/item/clothing/mask/clown_hat/pink
	name = "pink clown mask"
	desc = "This reminds you of cotton candy."
	icon_state = "pinkclown"
	//item_state = "pinkclown"
	bald_desc_state = "For sweet clowns who want to show off their hair!"

/obj/item/clothing/under/misc/clown/pink
	name = "pink clown suit"
	desc = "The color pink is the embodiment of love and hugs and nice people. Honk."
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
	icon_state = "pinkclown"
	//item_state = "pinkclown"

/obj/item/clothing/shoes/clown_shoes/pink
	name = "pink clown shoes"
	desc = "Normal clown shoes, just pink instead of red."
	icon_state = "pinkclown"
	//item_state = "pinkclown"

/obj/item/clothing/mask/clown_hat/yellow
	name = "yellow clown mask"
	desc = "A ray of sunshine."
	icon_state = "yellowclown"
	//item_state = "yellowclown"
	bald_desc_state = "For bright clowns who want to show off their hair!"

/obj/item/clothing/under/misc/clown/yellow
	name = "yellow clown suit"
	desc = "Have a happy honk!"
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
	icon_state = "yellowclown"
	//item_state = "yellowclown"

/obj/item/clothing/shoes/clown_shoes/yellow
	name = "yellow clown shoes"
	desc = "Normal clown shoes, just yellow instead of red."
	icon_state = "yellowclown"
	//item_state = "yellowclown"

// SHAMONE

/obj/item/clothing/under/gimmick/mj_clothes
	name = "Smooth Criminal's Jumpsuit"
	desc = "You've been hit by..."
	icon_state = "moonwalker"
	item_state = "moonwalker"

/obj/item/clothing/suit/mj_suit
	name = "Smooth Criminal's Suit"
	desc = "You've been struck by..."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "mjsuit"
	item_state = "mjsuit"

/obj/item/clothing/head/mj_hat
	name = "Smooth Criminal's Hat"
	desc = "Suave."
	icon_state = "mjhat"

/obj/item/clothing/shoes/mj_shoes
	name = "Moonwalkers"
	desc = "The perfect shoes if you want to moonwalk like a champ."
	icon_state = "mjshoes"

// Vikings

/obj/item/clothing/under/gimmick/viking
	name = "TN-HEIMALIS-1 Hauberk"
	desc = "A shirt of flexible cobryl-alloy mail armor with excellent cold protection, bearing the insignia of the Terra Nivium company."
	icon_state = "viking"
	item_state = "viking"

	setupProperties()
		..()
		setProperty("coldprot", 40)

/obj/item/clothing/head/helmet/viking
	name = "TN-HEIMALIS-2 Helmet"
	desc = "A cobryl-alloy armored helmet with excellent cold protection, bearing the insignia of the Terra Nivium company."
	icon_state = "viking"
	item_state = "vhelmet"

	setupProperties()
		..()
		setProperty("coldprot", 40)


/obj/item/device/energy_shield/viking
	name = "TN-FIDEI Energy Shield"
	desc = "A handheld projected energy barrier for personal protection, bearing the insignia of the Terra Nivium company."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "viking_shield"
	flags = FPRINT | TABLEPASS| CONDUCT
	c_flags = ONBELT
	item_state = "vshield"
	throwforce = 7
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL

	New()
		. = ..()
		AddComponent(/datum/component/cell_holder, new /obj/item/ammo/power_cell/self_charging/disruptor, TRUE, 100, FALSE)
		AddComponent(/datum/component/wearertargeting/energy_shield, list(SLOT_BELT, SLOT_L_HAND, SLOT_R_HAND), 0.75, 1, TRUE, 5) //blocks 75% of damage taken, up to 100 damage total


// Merchant

/obj/item/clothing/under/gimmick/merchant
	name = "Salesman's Uniform"
	desc = "A thrifty outfit for mercantile individuals."
	icon_state = "merchant"
	item_state = "merchant"

/obj/item/clothing/suit/merchant
	name = "Salesman's Jacket"
	desc = "Delightfully tacky."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "merchant"
	item_state = "merchant"

/obj/item/clothing/head/merchant_hat
	name = "Salesman's Hat"
	desc = "A big funny-looking sombrero."
	icon_state = "merchant"
	item_state = "chefhat"

/obj/item/clothing/mask/balaclava
	name = "balaclava"
	desc = "Hold hostages, rob a bank, shoot up an airport, the primitive yet flexible balaclava does it all!"
	icon_state = "balaclava"
	item_state = "balaclava"
	see_face = 0

// Sweet Bro and Hella Jeff

/obj/item/clothing/under/gimmick/sbahj
	name = "<font face='Comic Sans MS' size='3'><span class='notice'>blue janpsuit...</font>"
	desc = "<font face='Comic Sans MS' size='3'>looks like somethein to wear.........<br><br>in spca</font>"
	icon_state = "sbahjB"
	item_state = "sbahjB"

	red
		name = "<font face='Comic Sans MS' size='3'><span class='alert'><b><u>read</u></b></span><span class='notice'> jumsut</span></font>"
		desc = "<font face='Comic Sans MS' size='3'>\"samething to ware for <span class='alert'><i><u>studid fuckasses</u></i></span></font>"
		icon_state = "sbahjR"
		item_state = "sbahjR"

	yellow
		name = "<font face='Comic Sans MS' size='3'><span style=\"color:yellow\"><strike>yello  jamsuuit</strike><b><u><i>GEROMY</i></u></b></span></font>"
		desc = "<font face='Comic Sans MS' size='3'>the big man HASS the jumpsiut</font>"
		icon_state = "sbahjY"
		item_state = "sbahjY"

// Spiderman

/obj/item/clothing/mask/spiderman
	name = "spider-man mask"
	desc = "WARNING: Provides no protection from falling bricks."
	icon_state = "spiderman"
	item_state = "bogloves"
	see_face = 0

/obj/item/clothing/under/gimmick/spiderman
	name = "spider-man Suit"
	desc = "FAPPO!"
	icon_state = "spiderman"
	item_state = "spiderman"
	see_face = 0

/obj/item/clothing/mask/horse_mask
	name = "horse mask"
	desc = "Neigh."
	icon_state = "horse"
	c_flags = COVERSMOUTH | COVERSEYES | MASKINTERNALS
	see_face = 0

	cursed
		cant_drop = 1
		cant_other_remove = 1
		cant_self_remove = 1

	cursed/monkey
		name = "horse mask?"
		desc = "Neigh?"

/obj/item/clothing/head/genki
	name = "super happy funtime cat head"
	desc = "This cat head was built to the highest ethical standards.  50% less child labor used in production than competing novelty cat heads."
	icon_state = "genki"
	c_flags = COVERSEYES | COVERSMOUTH | MASKINTERNALS

//birdman for nieks

/obj/item/clothing/head/birdman
	name = "birdman helmet"
	desc = "bird bird bird"
	icon_state = "birdman"
	see_face = 0
	c_flags = SPACEWEAR | COVERSEYES | COVERSMOUTH | MASKINTERNALS //FACT: space birds can breathe in space

/obj/item/clothing/under/gimmick/birdman
	name = "birdman suit"
	desc = "It has wings!"
	icon_state = "birdman"
	item_state = "b_mask"

//WARHAMS STUFF

/obj/item/clothing/mask/gas/inquis
	name = "inquisitor mask"
	desc = "MY WARHAMS"
	icon_state = "inquis"
	item_state = "swat_hel"

/obj/item/clothing/suit/adeptus
	name = "adeptus mechanicus robe"
	desc = "A robe of a member of the adeptus mechanicus."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "adeptus"
	item_state = "adeptus"
	over_hair = TRUE
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES|C_EARS
	wear_layer = MOB_OVERLAY_BASE

	setupProperties()
		..()
		setProperty("chemprot", 10)

//power armor

/obj/item/clothing/head/power // placeholder icons until someone sprites an unpainted helmet
	name = "plastic power helmet"
	desc = "Wow this really looks like a noise marine helmet. But it's not!"
	icon_state = "nm_helm"

/obj/item/clothing/suit/power
	name = "unpainted cardboard space marine armor"
	desc = "Wow, what kind of dork fields an unpainted army? Gauche."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_armor.dmi'
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES
	icon_state = "unp_armor"
	item_state = "unp_armor"

/obj/item/clothing/suit/power/ultramarine
	name = "cardboard ultramarine armor"
	desc = "Oh sure, Ultramarines. That's real creative. Nerd."
	icon_state = "um_armor"
	item_state = "um_armor"

/obj/item/clothing/head/power/ultramarine
	name = "plastic ultramarine helmet"
	desc = "Darth Vader is feeling a bit blue today apparently."
	icon_state = "um_helm"

/obj/item/storage/backpack/ultramarine
	name = "novelty ultramarine backpack"
	desc = "How is this janky piece of shit supposed to work anyway?"
	icon_state = "um_back"

/obj/item/clothing/suit/power/noisemarine
	name = "cardboard noise marine armor"
	desc = "Slaanesh is for fucking freaks, man."
	icon_state = "nm_armor"
	item_state = "nm_armor"

/obj/item/clothing/head/power/noisemarine
	name = "plastic noise marine helmet"
	desc = "A bright pink space mans helmet. Whether it's more or less tacky than a fedora is indeterminable at this time."
	icon_state = "nm_helm"

/obj/item/storage/backpack/noisemarine
	name = "novelty noise marine backpack"
	desc = "Shame this doesn't have real loudspeakers built into it."
	icon_state = "nm_back"

/obj/item/clothing/under/gimmick/dawson
	name = "Aged hipster clothes"
	desc = "A worn-out brown coat with acid-washed jeans and a yellow-stained shirt. The previous owner must've been a real klutz."
	icon_state = "dawson"
	item_state = "dawson"
	cant_self_remove = 1
	cant_other_remove = 1
	equipped(var/mob/user, var/slot)
		..()
		if(slot == SLOT_W_UNIFORM && ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.shoes != null)
				var/obj/item/clothing/shoes/c = H.shoes
				if(!istype(c, /obj/item/clothing/shoes/white))
					H.u_equip(c)
					if(c)
						c.set_loc(H.loc)
						c.dropped(H)
						c.layer = initial(c.layer)
			var/obj/item/clothing/shoes/white/newshoes = new /obj/item/clothing/shoes/white(H)
			newshoes.cant_self_remove = 1
			newshoes.cant_other_remove = 1
			newshoes.name = "Dirty sneakers"
			newshoes.desc = "A pair of dirty white sneakers. Fortunately they don't have any blood stains."
			H.equip_if_possible(newshoes, H.slot_shoes)

			boutput(H, "<span class='alert'><b>You suddenly feel whiny and ineffectual.</b></span>")
			H.real_name = "Mike Dawson"
			H.bioHolder.mobAppearance.customization_first = new /datum/customization_style/hair/long/bedhead
			H.bioHolder.mobAppearance.customization_second = new /datum/customization_style/moustache/selleck
			H.bioHolder.mobAppearance.e_color = "#321E14"
			H.bioHolder.mobAppearance.customization_first_color = "#412819"
			H.bioHolder.mobAppearance.customization_second_color = "#412819"
			H.bioHolder.mobAppearance.s_tone = "#FAD7D0"
			H.bioHolder.AddEffect("clumsy")
			H.update_colorful_parts()

/obj/item/clothing/under/gimmick/chav
	name = "blue tracksuit"
	desc = "Looks good on yew innit?"
	icon_state = "chav1"
	item_state = "chav1"
	New()
		..()
		desc = pick("Looks good on yew innit?", "Aww yeah that jackets sick m8")
		if(prob(50))
			name = "Burberry plaid jacket"
			icon_state = "chav2"
			item_state = "lb_suit"

/obj/item/clothing/head/chav
	name = "burberry cap"
	desc = "Sick flatbrims m8"
	icon_state = "chavcap"
	item_state = "caphat"

/obj/item/clothing/under/gimmick/safari
	name = "safari clothing"
	desc = "'ello gents! Cracking time to hunt an elephant!"
	icon_state = "safari"
	item_state = "safari"
	item_function_flags = IMMUNE_TO_ACID

/obj/item/clothing/head/safari
	name = "safari hat"
	desc = "Keeps you cool in the hot savannah."
	icon_state = "safari"
	item_state = "caphat"
	item_function_flags = IMMUNE_TO_ACID

/obj/item/clothing/mask/skull
	name = "skull mask"
	desc = "A spooky skull mask. You're getting the heebie-jeebies just looking at it!"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "skull"
	item_state = "death"
	see_face = 0

/obj/item/clothing/suit/robuddy
	name = "guardbuddy costume"
	desc = "A costume that loosely resembles the PR-6 Guardbuddy. How adorable!"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "robuddy"
	item_state = "robuddy"
	wear_layer = MOB_BACK_LAYER + 0.2
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES

/obj/item/clothing/suit/bee
	name = "bee costume"
	desc = "A costume that loosely resembles a domestic space bee. Buzz buzz!"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "bee"
	item_state = "bee"
	wear_layer = MOB_BACK_LAYER + 0.2
	body_parts_covered = TORSO|ARMS

/obj/item/clothing/suit/monkey
	name = "monkey costume"
	desc = "A costume that loosely resembles a monkey. Ook Ook!"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "monkey"
	item_state = "monkey"
	over_hair = TRUE
	body_parts_covered = TORSO|LEGS|ARMS
	c_flags = COVERSMOUTH | COVERSEYES
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES|C_MASK|C_GLASSES|C_EARS

/obj/item/clothing/mask/niccage
	name = "Nicolas Cage mask"
	desc = "An eerily realistic mask of 20th century film actor Nicolas Cage."
	icon_state = "niccage"
	c_flags = COVERSMOUTH | COVERSEYES | MASKINTERNALS
	see_face = 0

/obj/item/clothing/mask/waltwhite
	name = "meth scientist mask"
	desc = "A crappy looking mask that you swear you've seen a million times before. 'Spook*Corp Costumes' is embedded on the side of it."
	icon_state = "waltwhite"
	c_flags = COVERSMOUTH | COVERSEYES | MASKINTERNALS //| SPACEWEAR Walter White is like Batman in many ways. Breathing in space is not one of them.
	see_face = 0

/obj/item/clothing/mask/mmyers
	name = "murderer mask"
	desc = "This looks strangely like another mask you've seen somewhere else, but painted white. Huh."
	icon_state = "mmyers"
	c_flags = COVERSMOUTH | COVERSEYES | MASKINTERNALS
	see_face = 0


/obj/item/clothing/suit/gimmick
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'

/obj/item/clothing/suit/gimmick/light_borg //YJHGHTFH's light borg costume
	name = "light cyborg costume"
	desc = "A costume that looks like a light-body cyborg. Suprisingly, it's quite comfortable!"
	icon_state = "light_borg"
	item_state = "light_borg"
	body_parts_covered = TORSO|LEGS|ARMS
	c_flags = COVERSMOUTH | COVERSEYES
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES|C_MASK|C_GLASSES|C_EARS
	over_hair = TRUE
	see_face = 0

/obj/item/clothing/under/gimmick/utena //YJHTGHTFH's utena suit
	name = "revolutionary suit"
	desc = "May give you the power to revolutionize the world! Probably not, though."
	icon_state = "utena"
	item_state = "utena"

/obj/item/clothing/shoes/utenashoes //YJHGHTFH's utena shoes
	name = "revolutionary shoes"
	desc = "Have you done some stretches today?  You should do some stretches."
	icon_state = "utenashoes"
	item_state = "utenashoes"

/obj/item/clothing/under/gimmick/anthy //AffableGiraffe's anthy dress
	name = "revolutionary dress"
	desc = "If you experience unexpected magical swords appearing from your body, please see a doctor."
	icon_state = "anthy"
	item_state = "anthy"

// Gundam Costumes

/obj/item/clothing/suit/gimmick/mobile_suit
	name = "mobile suit"
	desc = "A blocky looking armor suit, it's made of plastic."
	icon_state = "mobile_suit"
	item_state = "mobile_suit"
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES

/obj/item/clothing/head/mobile_suit
	name = "mobile suit headpiece"
	desc = "A familiar, yet legally distinct helmet."
	icon_state = "mobile_suit"
	item_state = "mobile_suit"

/obj/item/clothing/suit/armor/sneaking_suit
	name = "sneaking suit"
	desc = "I spy with my little eye..."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_armor.dmi'
	icon_state = "sneakmans"
	item_state = "sneakmans"
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES

/obj/item/clothing/suit/armor/sneaking_suit/costume
	desc = "On closer inspection this is a cheap cosplay outfit with an obvious zipper."

	setupProperties()
		..()
		setProperty("meleeprot", 2)
		delProperty("rangedprot")

/obj/item/clothing/suit/bio_suit/beekeeper
	name = "apiculturist's suit"
	desc = "A suit that protects against bees. Not space bees, but like the tiny, regular kind. This thing doesn't do <i>shit</i> to protect you from space bees."

/obj/item/clothing/head/bio_hood/beekeeper
	name = "apiculturist's hood"
	desc = "This hood has a special mesh on it to keep bees from your eyes and other face stuff."
	icon_state = "beekeeper"
	item_state = "beekeeper"

/obj/item/clothing/under/rank/beekeeper
	name = "apiculturist's overalls"
	desc = "Really, they're just regular overalls, but they have a little bee patch on them. Aww."
	icon_state = "beekeeper"
	item_state = "beekeeper"

/obj/item/clothing/under/gimmick/butler
	name = "butler suit"
	desc = "Tea, sir?"
	icon_state = "butler"
	item_state = "butler"

/obj/item/clothing/under/gimmick/maid
	name = "maid dress"
	desc = "Tea, ma'am?"
	icon_state = "maid"
	item_state = "maid"

/obj/item/clothing/head/maid
	name = "maid headwear"
	desc = "A little ruffle with lace, to wear on the head. It gives you super cleaning powers*!<br><small>*Does not actually bestow any powers.</small>"
	icon_state = "maid"
	item_state = "maid"

/obj/item/clothing/under/gimmick/dinerdress_mint
	name = "Mint Diner Waitress's Dress"
	desc = "Can I getcha somethin', sugar?"
	icon_state = "dinerdress-mint"
	item_state = "dinerdress-mint"

/obj/item/clothing/under/gimmick/dinerdress_pink
	name = "Pink Diner Waitress's Dress"
	desc = "Y'all come back now, ya hear?"
	icon_state = "dinerdress-pink"
	item_state = "dinerdress-pink"

/obj/item/clothing/under/gimmick/kilt
	name = "kilt"
	desc = "Traditional Scottish clothing. A bit drafty in here, isn't it?"
	icon_state = "kilt"
	item_state = "kilt"

/obj/item/clothing/under/gimmick/ziggy
	name = "familiar jumpsuit"
	desc = "A bold jumpsuit, reminiscent of a long lost, but very loved celebrity from long ago."
	icon_state = "ziggy"
	item_state = "ziggy"

/obj/item/clothing/head/mime_beret
	name = "beret"
	desc = "Are you the beatnik kind of beret wearer or the revolutionary kind?"
	icon_state = "mime_beret"

/obj/item/clothing/head/mime_bowler
	name = "bowler"
	desc = "Head-gear befitting a sophisticated performer. Just like Chaplin, Hardy & Laurel."
	icon_state = "mime_bowler"

/obj/item/clothing/mask/mime
	name = "mime mask"
	desc = "The charming mask of the mime. Very emotive! Wait, isn't this usually face-paint?"
	icon_state = "mime"
	see_face = 0

/obj/item/clothing/under/misc/mime
	name = "mime suit"
	desc = "The signature striped uniform of the mime. Not necessarily French."
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
	icon_state = "mime1"
	item_state = "mime1"

/obj/item/clothing/under/misc/mime/alt
	icon_state = "mime2"
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
	item_state = "mime2"
	desc = "A mime outfit with a pair of dungarees. The front pocket is all stitched up, jeez."

/obj/item/clothing/suit/scarf
	name = "scarf"
	desc = "A stylish red scarf, to add some colour to the monochrome mime get-up."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "scarf"

	setupProperties()
		..()
		setProperty("coldprot", 10)

/obj/item/clothing/suit/suspenders
	name = "suspenders"
	desc = "An important mime accessory, you don't want your trousers falling down mid-performance, do you?"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "suspenders"

/obj/item/clothing/under/misc/flame
	name = "flame shirt"
	desc = "A fiery flame shirt even Guy Fieri would be envious of."
	icon_state = "flame"
	item_state = "flame"
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'

/obj/item/clothing/under/misc/america
	name = "american pride shirt"
	desc = "I am a REAL AMERICAN, I fight for the rights of every man!"
	icon_state = "america"
	item_state = "america"
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'

/obj/item/clothing/under/gimmick/wedding_dress
	name = "wedding dress"
	desc = "A very fancy and very expensive white dress which one is supposed to wear to be married, or while going insane post-marriage. Boy, it sure would be terrible if this got covered in blood and gore or something, someone would be out a lot of money!"
	icon_state = "weddress"
	item_state = "weddress"
	c_flags = SLEEVELESS

/obj/item/clothing/gloves/ring
	name = "ring"
	desc = "A little ring, worn on the ring finger. You absolutely can't wear rings on any other fingers. It's just not possible."
	icon_state = "ring"
	item_state = "ring"
	material_prints = "sharp scratches"
	hide_prints = 0
	rand_pos = 1

	setupProperties()
		..()
		setProperty("conductivity", 1)

	attack(mob/M, mob/user, def_zone)
		if ((user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(40)) || prob(1)) // honk
			user.visible_message("<span class='alert'><b>[user] fumbles and drops [src]!</b></span>",\
			"<span class='alert'><b>You fumble and drop [src]!</b></span>")
			user.u_equip(src)
			JOB_XP(user, "Clown", 2)
			src.set_loc(get_turf(user))
			src.oh_no_the_ring()
			return

		else if (user.a_intent == "harm") // dude chill it's your wedding or something, probably
			return ..()

		else if (user.zone_sel)
			DEBUG_MESSAGE("[user].zone_sel.selecting == \"[user.zone_sel.selecting]\"")
			if (user.zone_sel.selecting == "l_arm" || user.zone_sel.selecting == "r_arm") // the ring always ends up on the left hand because I cba to let people dynamically choose the hand it goes on. yet. later, maybe.
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.gloves)
						boutput(user, "<span class='alert'>You can't put [src] on [H]'s finger while they're wearing [H.gloves], you oaf!</span>")
						return
					if (user == H) // is this some form of masturbation?? giving yourself a wedding ring???? or are you too lazy to just equip it like a normal person????????
						user.visible_message("<b>[user]</b> slips [src] onto [his_or_her(user)] own finger. Legally, [he_or_she(user)] is now married to [him_or_her(user)]self. Congrats.",\
						"You slip [src] onto your own finger. Legally, you are now married to yourself. Congrats.")
					else
						user.visible_message("<b>[user]</b> slips [src] onto [H]'s finger.",\
						"You slip [src] onto [H]'s finger.")
					user.u_equip(src)
					H.force_equip(src, H.slot_gloves)
					return

				else if (isobserver(M) || isintangible(M) || iswraith(M))
					user.visible_message("<b>[user]</b> tries to give [src] to [M], but [src] falls right through [M]!",\
					"You try to give [src] to [M], but [src] falls right through [M]!")
					user.u_equip(src)
					src.set_loc(get_turf(M))
					src.oh_no_the_ring()
					return

				else if (issilicon(M))
					user.visible_message("<b>[user]</b> tries to give [src] to [M], but [M] has no fingers to put [src] on!",\
					"You try to give [src] to [M], but [M] has no fingers to put [src] on!")
					return

				else if (ismobcritter(M))
					var/mob/living/critter/C = M
					if (C.hand_count > 0) // we got hands!  hands that things can be put onto!  er, into, I guess.
						if (C.put_in_hand(src))
							user.u_equip(src)
							user.visible_message("<b>[user]</b> slips [src] onto [C]'s finger.",\
							"You slip [src] onto [C]'s finger.")
							return
						else
							user.visible_message("<b>[user]</b> tries to give [src] to [C], but [C] has no fingers to put [src] on!",\
							"You try to give [src] to [C], but [C] has no fingers to put [src] on!")
							return
					else
						user.visible_message("<b>[user]</b> tries to give [src] to [C], but [C] has no fingers to put [src] on!",\
						"You try to give [src] to [C], but [C] has no fingers to put [src] on!")
						return
				else
					user.visible_message("<b>[user]</b> tries to give [src] to [M], but [he_or_she(user)] can't really find a hand to put [src] on!",\
					"You try to give [src] to [M], but you can't really find a hand to put [src] on!")
					return

			else if (user.zone_sel.selecting == "head" || user.zone_sel.selecting == "chest")
				user.visible_message("<b>[user]</b> excitedly shoves [src] in [M]'s face!",\
				"You excitedly shove [src] in [M]'s face!")
				return

			else if (user.zone_sel.selecting == "l_leg" || user.zone_sel.selecting == "r_leg") // look we aren't Guillermo del Toro and they aren't Uma Thurman so there's no need for this kinda nonsense
				user.visible_message("<b>[user]</b> tries to put [src] on [M]'s... toe? That's weird. You're weird, [user].",\
				"You try to put [src] on [M]'s... toe? That's weird. You're weird, [user].")
				return

			else
				return ..()

	proc/oh_no_the_ring()
		if (!isturf(src.loc))
			return
		src.layer = initial(src.layer)
		playsound(src.loc, 'sound/items/coindrop.ogg', 30, 1, null, 2)
		SPAWN(rand(2,5))
			if (src && isturf(src.loc))
				var/obj/table/T = locate(/obj/table) in range(3,src)
				if (prob(66) && T)
					for (var/i=rand(2,4), i>0, i--)
						if (!src || !T || !isturf(src.loc))
							break
						if (src.loc == T.loc)
							src.visible_message("<span class='alert'>\The [src] rolls under [T]!</span>")
							playsound(src.loc, 'sound/items/coindrop.ogg', 530, 1, null, 2)
							if (prob(30))
								qdel(src)
								return
							else
								src.layer = T.layer-0.1
								break
						else
							step_towards(src, T)
							src.visible_message("<span class='alert'>\The [src] bounces!</span>")
							playsound(src.loc, 'sound/items/coindrop.ogg', 30, 1, null, 2)
							sleep(rand(2,5))
				else
					for (var/i=rand(0,4), i>0, i--)
						if (!src || !isturf(src.loc))
							break
						step(src, pick(alldirs))
						src.visible_message("<span class='alert'>\The [src] bounces!</span>")
						playsound(src.loc, 'sound/items/coindrop.ogg', 30, 1, null, 2)
						sleep(rand(2,5))

/obj/item/clothing/gloves/ring/gold
	name = "gold ring"
	icon_state = "gring"
	item_state = "gring"
	material_prints = "shallow scratches"
	mat_changename = 0 // okay let's just be "gold ring" and not "flimsy soft good gold ring" tia
	mat_appearances_to_ignore = list("gold") // we already look fine ty
	New()
		..()
		src.setMaterial(getMaterial("gold"))

/obj/item/clothing/gloves/ring/titanium // fancy loot crate ring that gives you hulk, basically. real overpowered?  :T
	name = "titanium ring"
	desc = "A little ring with a strange green gem, worn on the ring finger. You absolutely can't wear rings on any other fingers. It's just not possible."
	icon_state = "titanring"
	item_state = "titanring"
	material_prints = "deep scratches"

	equipped(var/mob/user, var/slot)
		if (slot == SLOT_GLOVES)
			if (!user.bioHolder || !user.bioHolder.HasEffect("hulk"))
				boutput(user, "You feel your muscles swell to an immense size.")
			APPLY_MOVEMENT_MODIFIER(user, /datum/movement_modifier/hulkstrong, src.type)
		return ..()

	unequipped(var/mob/user)
		REMOVE_MOVEMENT_MODIFIER(user, /datum/movement_modifier/hulkstrong, src.type)
		if (!user.bioHolder || !user.bioHolder.HasEffect("hulk"))
			boutput(user, "Your muscles shrink back down.")
		return ..()

/obj/item/clothing/head/veil
	name = "lace veil"
	desc = "A delicate veil made of white lace, with a little flower on the band."
	icon_state = "wedveil"
	item_state = "wedveil"
/*
/obj/item/clothing/gloves/latex/long // mehh may as well
	name = "long gloves"
	desc = "Long, thin gloves, for that elegant ballroom look."
	icon_state = "wedgloves"
	item_state = "lgloves"
*/
/obj/item/clothing/shoes/heels
	name = "white heels"
	desc = "A pair of high-heeled shoes. Not very practical for working in space, or anywhere else, really. But damn do they make your legs look good."
	icon_state = "wheels"
	item_state = "w_shoes"
	step_sound = "footstep"
	step_priority = STEP_PRIORITY_LOW
	laces = LACES_NONE

/obj/item/clothing/shoes/heels/black
	name = "black heels"
	icon_state = "bheels"
	item_state = "feet"

/obj/item/clothing/shoes/heels/red
	name = "red heels"
	icon_state = "rheels"
	item_state = "r_shoes" // doesn't match perfectly but I cba to make perfect inhand states for all this shit

/obj/item/clothing/shoes/heels/dancin // add unique sprites sometime
	name = "dancin shoes"
	desc = "Guilty feet have got no rhythm, but slip on a pair of dancin shoes, and voila!"

/obj/item/clothing/suit/tuxedo_jacket
	name = "tuxedo jacket"
	desc = "A formal jacket with satin lapels. "
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "tuxjacket"

/obj/item/clothing/suit/guards_coat
	name = "guard's coat"
	desc = "A formal double breasted overcoat of British origin."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "guardscoat"

	setupProperties()
		..()
		setProperty("coldprot", 35)

/obj/item/clothing/under/gimmick/black_wcoat
	name = "dress shirt and waistcoat"
	desc = "A formal waistcoat meant to be worn alongside an overcoat."
	icon_state = "black_wcoat"
	item_state = "black_wcoat"

/obj/item/clothing/under/gimmick/red_wcoat
	name = "dress shirt and red waistcoat"
	desc = "A formal red waistcoat meant to be worn alongside an overcoat."
	icon_state = "red_wcoat"
	item_state = "red_wcoat"

/obj/item/clothing/under/gimmick/blue_wcoat
	name = "dress shirt and blue waistcoat"
	desc = "A formal blue waistcoat meant to be worn alongside an overcoat."
	icon_state = "blue_wcoat"
	item_state = "blue_wcoat"

/obj/item/clothing/under/rank/bartender/tuxedo // look I really want to make the clothes vendor just produce clothing directly and not have to spawn this in a box with a custom name or something
	name = "dress shirt and bowtie"
	desc = "A nice, crisp shirt, dress pants and a black bowtie. Fancy."

/obj/item/clothing/shoes/dress_shoes
	name = "dress shoes"
	desc = "A pair of nice dress shoes."
	icon_state = "dress"
	item_state = "bl_shoes"
	step_sound = "footstep"
	step_priority = STEP_PRIORITY_LOW

/obj/item/clothing/under/misc/yoga
	name = "\improper T-shirt and yoga pants"
	desc = "A big, comfy T-shirt and some yoga pants that will turn heads."
	icon_state = "yoga"
	item_state = "yoga"

/obj/item/clothing/under/misc/yoga/red
	name = "red T-shirt and yoga pants"
	icon_state = "yoga-r"
	item_state = "yoga-r"

/obj/item/clothing/under/misc/yoga/communist // I dunno, the dude made these sprites and I guess it doesn't hurt to use them? :v
	name = "\improper Red T-shirt and yoga pants"
	icon_state = "yoga-c"
	item_state = "yoga-c"

/obj/item/clothing/under/misc/dress
	name = "little black dress"
	desc = "Every girl needs one, you know, but this is very, very little. Yeesh."
	icon_state = "blackdress"
	item_state = "blackdress"
	c_flags = SLEEVELESS

/obj/item/clothing/under/misc/dress/red
	name = "little red dress"
	desc = "Every girl needs one, you know, but would your grandma approve of this one?"
	icon_state = "reddress"
	item_state = "reddress"
	c_flags = SLEEVELESS

/obj/item/clothing/under/misc/dress/hawaiian
	name = "hawaiian dress"
	desc = "A vibrantly colored Hawaiian dress."
	icon_state = "hawaiiandress"
	item_state = "hawaiiandress"
	c_flags = SLEEVELESS

/obj/item/clothing/suit/poncho
	name = "poncho"
	desc = "This thing looks painful to wear. It smells bad, feels gross and makes you feel kinda weirded out."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "painful"

/obj/item/clothing/suit/rando
	name = "red skull mask and cloak"
	desc = "Looking at this fills you with joy! You're not sure why. That's kind of a weird thing to feel about something that looks like this."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "joyful"
	body_parts_covered = TORSO|LEGS|ARMS
	wear_layer = MOB_OVERLAY_BASE
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES|C_MASK|C_GLASSES|C_EARS
	over_hair = TRUE

/obj/item/clothing/head/rando
	name = "red skull mask and cowl"
	desc = "Looking at this fills you with joy! You're not sure why. That's kind of a weird thing to feel about something that looks like this."
	icon_state = "joyful"
	seal_hair = 1

/obj/item/clothing/under/rotten
	name = "suit and vest"
	desc = "You feel like you could sing a real catchy tune in this getup!"
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
	icon_state = "rotten"
	item_state = "rotten"

/obj/item/clothing/under/gimmick/frog
	name = "frog jumpsuit"
	desc = "A jumpsuit with a cute frog pattern on it. Get it? <i>Jump</i>suit? Ribbit!"
	icon_state = "frogsuit"
	item_state = "lightgreen"
	equipped(var/mob/user, var/slot)
		if (slot == SLOT_W_UNIFORM && user.bioHolder)
			user.bioHolder.AddEffect("jumpy_suit", 0, 0, 0, 1) // id, variant, time left, do stability, magical
			SPAWN(0) // bluhhhhhhhh this doesn't work without a spawn
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					if (H.hud)
						H.hud.update_ability_hotbar()
		..()

	unequipped(var/mob/user)
		if (user.bioHolder)
			user.bioHolder.RemoveEffect("jumpy_suit")
			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				if (H.hud)
					H.hud.update_ability_hotbar()
		..()

/obj/item/clothing/under/gimmick/pajamas
	name = "pajamas"
#ifdef UNDERWATER_MAP //gimmick jumpsuit descriptions are serious business
	desc = "Going outside when in an ocean is kinda wet, so why bother getting dressed?"
#else
	desc = "Going outside when in space is kinda dangerous, so why bother getting dressed?"
#endif
	icon_state = "pajamas"
	item_state = "pajamas"

/obj/item/clothing/under/gimmick/shirtnjeans
	name = "shirt and jeans"
	desc = "A white shirt and a pair of torn jeans."
	icon_state = "shirtnjeans"
	item_state = "white"

/obj/item/clothing/suit/jacketsjacket
	name = "baseball jacket"
	desc = "Do you like hurting other people?"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "jacketsjacket"

/obj/item/clothing/suit/dressb
	name = "dress"
	desc ="Just your ordinary long dress!"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	body_parts_covered = TORSO|LEGS|ARMS
	icon_state = "dressb"
	item_state = "dress"

	dressr
		icon_state ="dressr"

	dressg
		icon_state ="dressg"

	dressbl
		icon_state ="dressbl"

/obj/item/clothing/suit/greek
	name = "greek armor"
	desc ="Come and take them!"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	body_parts_covered = TORSO|SLEEVELESS
	icon_state = "gr_armor"

/obj/item/clothing/suit/gimmick/h
	name = "h"
	desc = "h"

/obj/item/clothing/suit/gimmick/werewolf
	name = "werewolf suit"
	desc = "The suit of a werewolf costume. Given the amount of moons in and around the station, it's a surprise there isn't a real one about."
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES
	icon_state = "wwsuit"

/obj/item/clothing/head/werewolf
	name = "werewolf mask"
	desc = "The mask of a wolfman getup."
	c_flags = COVERSMOUTH | COVERSEYES | MASKINTERNALS
	seal_hair = 1
	icon_state = "wwmask"

/obj/item/clothing/suit/gimmick/werewolf/odd
	name = "odd werewolf suit"
	desc = "The suit of a strangely colored werewolf costume with a ludicrous price tag."
	icon_state = "gwsuit"

/obj/item/clothing/head/werewolf/odd
	name = "odd werewolf mask"
	desc = "The mask of a peculiarly tinted wolfman getup with an outrageous price tag."
	icon_state = "gwmask"

/obj/item/clothing/head/werewolf/taxidermy
	name = "werewolf mask"
	desc = "The pelt of a flayed werewolf's head formed into a wearable taxidermy mask. Wonderful."
	icon_state = "gwmask"

/obj/item/clothing/suit/gimmick/abomination
	name = "abomination suit"
	desc =  "The abomination suit straight out of the studio of Jon Woodworker's horror thriller, <i>The Whaddyacallit</i>"
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM
	icon_state = "abomcostume"

/obj/item/clothing/head/abomination
	name = "abomination mask"
	desc =  "The abomination mask straight out of the studio of Jon Woodworker's horror thriller, <i>The Whaddyacallit</i>"
	c_flags = COVERSMOUTH | COVERSEYES | MASKINTERNALS
	seal_hair = 1
	icon_state = "abommask"

/obj/item/clothing/head/zombie
	name = "zombie mask"
	desc = "The mask of a zombie. Man, they really captured the discolouration of rotten flesh."
	c_flags = COVERSMOUTH | COVERSEYES | MASKINTERNALS
	seal_hair = 1
	icon_state = "zombmask"

/obj/item/clothing/suit/gimmick/hotdog
	name = "hotdog suit"
	desc = "On close inspection, you notice a small collection of bones caught in the fabric of the suit. Spooky."
	body_parts_covered = HEAD|TORSO|LEGS|ARMS
	wear_layer = MOB_OVERLAY_BASE
	hides_from_examine = C_UNIFORM|C_EARS
	icon_state = "hotdogsuit"
	over_hair = TRUE

/obj/item/clothing/under/gimmick/vampire
	name = "absurdly stylish suit and vest"
	desc = "You can<i>count</i> on this suit and vest to make you look real suave, yeah."
	icon_state = "vampcostume"

/obj/item/clothing/suit/gimmick/vampire
	name = "absurdly stylish cape"
	desc = "Dracula who?"
	body_parts_covered = TORSO
	icon_state = "vampcape"

/obj/item/clothing/under/gimmick/superhero
	name = "crimefighting costume"
	desc = "Definitely not just a pair of pajamas."
	body_parts_covered = TORSO|LEGS|ARMS
	icon_state = "superhero"

/obj/item/clothing/under/gimmick/mummy
	name = "linen body wrappings"
	desc = "I used to be the star of horror movies, now I'm just a tottering extra."
	body_parts_covered = TORSO|LEGS|ARMS
	icon_state = "mumwraps"

/obj/item/clothing/mask/mummy
	name = "linen head wrappings"
	desc = "This smells a lot like dead people."
	c_flags = COVERSMOUTH
	icon_state = "mummask"

/obj/item/clothing/under/gimmick/elvis
	name = "bell bottoms"
	desc = "Pristine white bell bottoms with red kick pleats and a snazzy gold belt."
	icon_state = "elivissuit"

/obj/item/clothing/under/gimmick/eightiesmens
	name = "flashy vest"
	desc = "A confident pair of clothes guaranteed to get you into a stride."
	icon_state = "80smens"

/obj/item/clothing/under/gimmick/eightieswomens
	name = "flashy shirt"
	desc = "A confident pair of clothes guaranteed to get you into a stride."
	icon_state = "80swomens"

/obj/item/clothing/under/gimmick/rollerdisco
	name = "disco getup"
	desc = "A funky shirt straight out of the 70s and a pair of athletic shorts for maximum agility."
	icon_state = "rollerdisco"

/obj/item/clothing/shoes/rollerskates
	name = "rollerskates"
	desc = "A pair of rollerskates, invented when experimental teleportation technology fused a pair of tacky boots and a shopping cart."
	icon_state = "rollerskates"

/obj/item/clothing/under/gimmick/itsyourcousin
	name = "tacky shirt and slacks"
	desc = "A perfect set of clothes to go bowling in."
	icon_state = "itsyourcousin"

/obj/item/clothing/under/gimmick/adidad
	name = "black tracksuit"
	desc = "The result of outsourcing jumpsuit production to Russian companies."
	icon_state = "adidad"

// Sart's scifi clothing

/obj/item/clothing/under/gimmick/cwfashion
    name = "Commonwealth fashionista's outfit"
    desc = "An incredibly garish outfit that is in vogue in a far-off, independently governed sector."
    icon_state = "cwfashion"
    item_state = "cwfashion"

/obj/item/clothing/under/gimmick/ftuniform
    name = "free trader's outfit"
    desc = "An orange-scarfed jumpsuit with a single sleeve missing, worn by independent traders operating beyond NT space."
    icon_state = "ftuniform"
    item_state = "ftuniform"

/obj/item/clothing/shoes/cwboots
	name = "Macando boots"
	desc = "These imported boots from the Commonwealth of Free Worlds are incredibly comfy."
	icon_state = "cwboots"

/obj/item/clothing/head/cwhat
	name = "Moebius-brand headwear"
	desc = "This hat looks patently ridiculous. Is this what passes for fashionable in the Commonwealth of Free Worlds?"
	icon_state = "cwhat"
	item_state = "cwhat"
	seal_hair = 1

/obj/item/clothing/head/fthat
	name = "trader's headwear"
	desc = "Why in the name of space would anyone trade with someone who wears a hat that looks this dumb? Yuck."
	icon_state = "fthat"
	item_state = "fthat"
	seal_hair = 1

/obj/item/clothing/gloves/handcomp
	name = "Compudyne 0451 Handcomp"
	desc = "This is some sort of hand-mounted computer. Or it would be if it wasn't made out of cheap plastic and LEDs."
	icon_state = "handcomp"
	item_state = "handcomp"
	hide_prints = 0

	setupProperties()
		..()
		setProperty("conductivity", 0.8)

/obj/item/clothing/glasses/ftscanplate
	name = "FTX-480 Scanner Plate"
	icon_state = "ftscanplate"
	item_state = "ftscanplate"
	desc = "This eyewear looks incredibly advanced, as do most things that come from the Commonwealth of Free Worlds. Unfortunately, this is a non-functioning replica sold to tourists."
	wear_layer = MOB_GLASSES_LAYER2

/obj/item/clothing/under/blossomdress
	name = "cherryblossom dress"
	desc = "A dress. Specifically for masquerades."
	icon_state = "blossomdress"
	item_state = "blossomdress"

/obj/item/clothing/under/peacockdress
	name = "peacock dress"
	desc = "A dress. Specifically for masquerades."
	icon_state = "peacockdress"
	item_state = "peacockdress"

/obj/item/clothing/under/collardressbl
	name = "collar dress"
	desc = "a dress made for casual wear"
	icon_state = "collardressbl"
	item_state = "collardressbl"

/obj/item/clothing/under/collardressr
	name = "collar dress"
	desc = "a dress made for casual wear"
	icon_state = "collardressr"
	item_state = "collardressr"

/obj/item/clothing/under/collardressg
	name = "collar dress"
	desc = "a dress made for casual wear"
	icon_state = "collardressg"
	item_state = "collardressg"

/obj/item/clothing/under/collardressb
	name = "collar dress"
	desc = "a dress made for casual wear"
	icon_state = "collardressb"
	item_state = "collardressb"

/obj/item/clothing/under/redtie
	name = "collar shirt and red tie"
	desc = "a pale dress shirt with a nice red tie to go with it"
	icon_state = "red-tie"
	item_state = "red-tie"

/obj/item/clothing/suit/loosejacket
	name = "loose jacket"
	desc = "a loose and stylish jacket"
	icon_state = "loose"
	item_state = "loose"
	body_parts_covered = TORSO|ARMS

/obj/item/clothing/shoes/floppy
	name = "floppy boots"
	desc = "a pair of boots with very floppy design around the ankles"
	icon_state = "floppy"
	item_state = "floppy"

/obj/item/clothing/suit/labcoatlong
	name = "off-brand lab coat"
	desc = "a long labcoat from some sort of supermarket"
	icon_state = "labcoat-long"
	item_state = "labcoat-long"
	body_parts_covered = TORSO|LEGS|ARMS

//monkey island reference

/obj/item/clothing/under/gimmick/guybrush
	name = "wannabe pirate outfit"
	desc = "It smells like monkeys."
	icon_state = "guybrush"
	item_state = "guybrush"

//fake lizard stuff

/obj/item/clothing/suit/gimmick/dinosaur
	name = "dinosaur pajamas"
	desc = "It has a little hood you can flip up and down. Rawr!"
	icon_state = "dinosaur"
	item_state = "dinosaur"
	hides_from_examine = C_UNIFORM

	New()
		..()
		src.AddComponent(/datum/component/toggle_hood, hood_style="dinosaur")

	setupProperties()
		..()
		setProperty("coldprot", 25)

/obj/item/clothing/head/biglizard
	name = "giant novelty lizard head"
	desc = "Wow! It's just like the real thing!"
	icon_state = "big_lizard"
	item_state = "big_lizard"

//sock hats

/obj/item/clothing/head/link
	name = "hero hat"
	desc = "What kind of hero would wear this dumb thing?"
	icon_state = "link"
	item_state = "link"

//Western Coats

/obj/item/clothing/suit/gimmick/guncoat
	name = "Shotgun Coat"
	desc = "A coat that does not hinder you when shooting from horseback, how neat!"
	icon_state = "guncoat"
	item_state = "guncoat"

/obj/item/clothing/suit/gimmick/guncoat/black
	name = "Black Shotgun Coat"
	icon_state = "guncoat_black"
	item_state = "guncoat_black"

/obj/item/clothing/suit/gimmick/guncoat/tan
	name = "Tan Shotgun Coat"
	icon_state = "guncoat_tan"
	item_state = "guncoat_tan"

/obj/item/clothing/suit/gimmick/guncoat/dirty
	name = "Dirty Shotgun Coat"
	icon_state = "guncoat_dirty"
	item_state = "guncoat_dirty"

//western Ponchos

/obj/item/clothing/suit/poncho/flower
	name = "Flower Poncho"
	desc = "A handwoven poncho, it has an insignia of a flower!"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "westflower"

/obj/item/clothing/suit/poncho/leaf
	name = "Leaf Poncho"
	desc = "A handwoven poncho, it has the pattern of multiple leaves!"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "westleaf"

//Witchy Capes

/obj/item/clothing/suit/witchcape_purple
	name = "Purple Witch Cape"
	desc = "Magical, but the friendship and imagination kind, not the remove-your-butt kind."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "witchcape_purple"

/obj/item/clothing/suit/witchcape_mint
	name = "Mint Witch Cape"
	desc = "Magical, but the friendship and imagination kind, not the remove-your-butt kind."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "witchcape_mint"

// marching band stuff
/obj/item/clothing/under/gimmick/marchingband
	name = "Marching Band Outfit"
	desc = "Band, ten-hut! For-ward harch!" // this isn't a typo, honest -disturbherb
	icon_state = "marchingband"
	item_state = "marchingband"

/obj/item/clothing/head/shako
	name = "Marching Band Shako"
	desc = "It's hard to resist playing with the plume on this thing."
	icon_state = "shako"
	item_state = "shako"

// deus ex reference
/obj/item/clothing/under/gimmick/jcdenton
	name = "nano-augmented agent outfit"
	desc = "JC stands for Jesus Christ."
	icon_state = "jcdenton"
	item_state = "jcdenton"
