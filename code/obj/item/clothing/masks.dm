// MASK WAS THAT MOVIE WITH THAT GUY WITH THE MESSED UP FACE. WHAT'S HIS NAME . . . JIM CARREY, I THINK.

/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/item_masks.dmi'
	wear_image_icon = 'icons/mob/clothing/mask.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	var/obj/item/voice_changer/vchange = 0
	body_parts_covered = HEAD
	compatible_species = list("human", "cow", "werewolf")
	wear_layer = MOB_HEAD_LAYER1
	var/is_muzzle = 0
	var/use_bloodoverlay = 1
	var/stapled = 0
	var/allow_staple = 1
	var/path_prot = 1 // protection from airborne pathogens, multiplier for chance to be infected

	New()
		..()
		if (c_flags & COVERSMOUTH | MASKINTERNALS)
			special_grab = /obj/item/grab/force_mask
			event_handler_flags |= USE_GRAB_CHOKE

	setupProperties()
		..()
		setProperty("coldprot", 5)
		setProperty("heatprot", 5)
		setProperty("meleeprot_head", 2)

/obj/item/clothing/mask/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/voice_changer))
		if (src.see_face)
			user.show_text("You can't find a way to attach [W] where it isn't really, really obvious. That'd kinda defeat the purpose of putting [W] in there, wouldn't it?", "red")
			return
		else if (src.vchange)
			user.show_text("[src] already has a voice changer in it!", "red")
			return
		else if (!src.see_face && !src.vchange)
			user.show_text("You begin installing [W] into [src].", "blue")
			if (!do_after(user, 2 SECONDS))
				user.show_text("You were interrupted!", "red")
				return
			user.show_text("You install [W] into [src].", "green")
			src.vchange = W
			W.set_loc(src)
			user.u_equip(W)
			return
	else if (issnippingtool(W))
		if (src.vchange)
			user.show_text("You begin removing [src.vchange] from [src].", "blue")
			if (!do_after(user, 2 SECONDS))
				user.show_text("You were interrupted!", "red")
				return
			user.show_text("You remove [src.vchange] from [src].", "green")
			user.put_in_hand_or_drop(src.vchange)
			src.vchange = null
			return
		else
			return ..()
	else
		return ..()

/obj/item/clothing/mask/proc/staple()
	if (src.stapled <=0)
		src.cant_self_remove = 1
		src.stapled = max(src.stapled, 0)
	src.stapled += 1

/obj/item/clothing/mask/proc/unstaple()
	. = 0
	if (stapled && allow_staple )	//Did an unstaple operation take place?
		if ( --src.stapled <= 0 ) //Got all the staples
			src.cant_self_remove = 0
			src.stapled = 0
		. = 1
		allow_staple = 0
		SPAWN(5 SECONDS)
			allow_staple = 1

/obj/item/clothing/mask/handle_other_remove(var/mob/source, var/mob/living/carbon/human/target)
	. = ..() && !src.stapled
	if (!source || !target) return
	if( src.unstaple()) //Try a staple if it worked, yay
		if (!src.stapled) //That's the last staple!
			source.visible_message("<span class='alert'><B>[source] rips out the staples from [src]!</B></span>", "<span class='alert'><B>You rip out the staples from [src]!</B></span>", "<span class='alert'>You hear a loud ripping noise.</span>")
			. = 1
		else //Did you get some of them?
			source.visible_message("<span class='alert'><B>[source] rips out some of the staples from [src]!</B></span>", "<span class='alert'><B>You rip out some of the staples from [src]!</B></span>", "<span class='alert'>You hear a loud ripping noise.</span>")
			. = 0

		//Commence owie
		take_bleeding_damage(target, null, rand(8, 16), DAMAGE_BLUNT)	//My
		playsound(target, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1) //head,
		target.emote("scream") 									//FUCKING
		target.TakeDamage("head", rand(12, 18), 0) 				//OW!
		target.changeStatus("weakened", 4 SECONDS)

		logTheThing(LOG_COMBAT, source, "rips out the staples on [constructTarget(target,"combat")]'s [src]") //Crime

/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A close-fitting mask that can filter some environmental toxins or be connected to an air supply."
	icon_state = "gas_mask"
	c_flags =  COVERSMOUTH | COVERSEYES | MASKINTERNALS | BLOCKSMOKE
	w_class = W_CLASS_NORMAL
	see_face = 0
	item_state = "gas_mask"
	color_r = 0.8 // green tint
	color_g = 1
	color_b = 0.8
	path_prot = 0

	setupProperties()
		..()
		setProperty("coldprot", 7)
		setProperty("heatprot", 7)
		setProperty("disorient_resist_eye", 10)

/obj/item/clothing/mask/gas/NTSO
	name = "NT gas mask"
	desc = "A close-fitting CBRN mask with dual filters and a tinted lens, designed to protect Nanotrasen security personnel from environmental threats."
	icon_state = "gas_mask_NT"
	item_state = "gas_mask_NT"
	color_r = 0.8 // cool blueberry nanotrasen tint provides disorientation resist
	color_g = 0.8
	color_b = 1

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 20)

TYPEINFO(/obj/item/clothing/mask/moustache)
	mats = 2

/obj/item/clothing/mask/moustache
	name = "fake moustache"
	desc = "Nobody will know who you are if you put this on. Nobody."
	icon_state = "moustache"
	item_state = "moustache"
	see_face = 0
	w_class = W_CLASS_TINY
	is_syndicate = 1

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("meleeprot_head", 3)

/obj/item/clothing/mask/moustache/safe
	name = "discount fake moustache"
	desc = "Almost as good as a REAL fake moustache."
	icon_state = "moustache"
	item_state = "moustache"
	see_face = 1

/obj/item/clothing/mask/moustache/Italian
	name = "fake Italian moustache"
	desc = "For those who can't cut the lasagna."
	icon_state = "moustache-i"
	item_state = "moustache-i"
	see_face = 1


/obj/item/clothing/mask/gas/emergency
	name = "emergency gas mask"
	icon_state = "gas_alt"
	item_state = "gas_alt"

	unremovable
		name = "slasher's gas mask"
		desc = "A close-fitting sealed gas mask, this one seems to be protruding some kind of dark aura."
		cant_self_remove = 1
		cant_other_remove = 1
		icon_state = "slasher_mask"
		item_state = "slasher_mask"
		item_function_flags = IMMUNE_TO_ACID
		see_face = 1
		setupProperties()
			..()
			setProperty("meleeprot_head", 6)
			setProperty("disorient_resist_eye", 100)
			setProperty("movespeed", 0.2)
			setProperty("exploprot", 40)

		equipped(mob/user, slot)
			. = ..()
			APPLY_ATOM_PROPERTY(user, PROP_MOB_THERMALVISION_MK2, src)

		unequipped(mob/user)
			. = ..()
			REMOVE_ATOM_PROPERTY(user, PROP_MOB_THERMALVISION_MK2, src)

	postpossession
		name = "worn gas mask"
		desc = "A close-fitting sealed gas mask, from the looks of it, it's well over a hundred years old."
		icon_state = "slasher_mask"
		item_state = "slasher_mask"
		see_face = 1
		setupProperties()
			..()
			setProperty("movespeed", 0.2)

/obj/item/clothing/mask/gas/swat
	name = "SWAT mask"
	desc = "A close-fitting tactical mask that can filter some environmental toxins or be connected to an air supply."
	icon_state = "swat"
	item_state = "swat"
	color_r = 1
	color_g = 0.8
	color_b = 0.8

	syndicate
		name = "syndicate field protective mask"
		item_function_flags = IMMUNE_TO_ACID

		New()
			..()
			START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)

		disposing()
			STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
			..()

TYPEINFO(/obj/item/clothing/mask/gas/voice)
	mats = 6

/obj/item/clothing/mask/gas/voice
	name = "gas mask"
	desc = "A close-fitting mask that can filter some environmental toxins or be connected to an air supply."
	icon_state = "gas_alt"
	item_state = "gas_alt"
	//vchange = 1
	is_syndicate = 1

	New()
		..()
		src.vchange = new(src)

TYPEINFO(/obj/item/voice_changer)
	mats = 6

/obj/item/voice_changer
	name = "voice changer"
	desc = "This voice-modulation device will dynamically disguise your voice to that of whoever is listed on your identification card, via incredibly complex algorithms. Discretely fits inside most masks, and can be removed with wirecutters."
	icon_state = "voicechanger"
	is_syndicate = 1

TYPEINFO(/obj/item/clothing/mask/monkey_translator)
	mats = 12	// 2x voice changer cost. It's complicated ok

/obj/item/clothing/mask/monkey_translator
	name = "vocal translator"
	desc = "Nanotechnology and questionable science combine to make a face-hugging translator, capable of making monkeys speak human language. Or whoever wears this."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "voicechanger"
	item_state = "muzzle"			// @TODO new sprite ok
	w_class = W_CLASS_SMALL
	c_flags = COVERSMOUTH	// NOT usable for internals.
	compatible_species = list("human", "cow", "werewolf", "martian")
	var/new_language = "english"	// idk maybe you can varedit one so that humans speak monkey instead. who knows

/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply but does not work very well in hard vacuum without a helmet."
	name = "breath mask"
	icon_state = "breath"
	item_state = "breath"
	c_flags = COVERSMOUTH | MASKINTERNALS
	w_class = W_CLASS_SMALL


	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/tank))
			src.auto_setup(W,user)
		else
			..()

	proc/auto_setup(atom/target_tank, mob/user as mob)
		if (istype(target_tank,/obj/item/tank))
			var/obj/item/tank/T = target_tank

			if (user.find_in_hand(src))
				if ((user.hand && user.r_hand == src) || (!user.hand && user.l_hand == src))
					user.swap_hand(!user.hand)
				user.hotkey("equip")	//wear mask
			else if (can_reach(user,src))
				if (user.equipped())
					user.swap_hand(!user.hand)
					if (!user.equipped())
						src.Attackhand(user)
						user.hotkey("equip")


			if (!user.find_in_hand(T))		//pickup tank
				T.Attackhand(user)

			if (!T.using_internal())//set tank ON
				T.toggle_valve()


	setupProperties()
		..()
		setProperty("coldprot", 5)
		setProperty("heatprot", 5)

/obj/item/clothing/mask/gas/death_commando
	name = "Death Commando mask"
	icon_state = "death_commando_mask"
	item_state = "death_commando_mask"
	setupProperties()
		..()
		setProperty("meleeprot_head", 4)


/obj/item/clothing/mask/clown_hat
	name = "clown wig and mask"
	desc = "A mask depicting the grinning facial expression of a prototypical clown. There's a place to tuck the attached wig in if you don't want it interfering with your own hair."
	icon_state = "clown"
	item_state = "clown_hat"
	see_face = 0

	var/spam_flag = 0
	var/spam_timer = 100
	var/list/sounds_instrument = list('sound/musical_instruments/Bikehorn_1.ogg')
	var/volume = 50
	var/randomized_pitch = 1
	var/mask_bald = FALSE
	var/bald_desc_state = "For clowns who want to show off their hair!"

	proc/honk_nose(mob/user as mob)
		if (!spam_flag)
			spam_flag = 1
			src.add_fingerprint(user)
			user?.visible_message("<B>[user]</B> honks the nose on [his_or_her(user)] [src.name]!")
			playsound(src, islist(src.sounds_instrument) ? pick(src.sounds_instrument) : src.sounds_instrument, src.volume, src.randomized_pitch)
			SPAWN(src.spam_timer)
				spam_flag = 0
			return 1
		return 0

	attack_self(mob/user as mob)
		if(!src.mask_bald)
			src.mask_bald = TRUE
			src.name = "wigless clown mask"
			src.desc = bald_desc_state
			src.icon_state = "[src.icon_state]_bald"
			src.item_state = "clown_bald"
			user.show_text("You tuck back the wig on the [src].")
		else
			src.mask_bald = FALSE
			src.name = initial(src.name)
			src.desc = initial(src.desc)
			src.icon_state = initial(src.icon_state)
			src.item_state = "clown_hat"
			user.show_text("You untuck the wig from the [src].")

/obj/item/clothing/mask/gas/syndie_clown
	name = "clown wig and mask"
	desc = "I AM THE ONE WHO HONKS."
	icon_state = "clown"
	item_state = "clown_hat"
	item_function_flags = IMMUNE_TO_ACID
	burn_possible = 0
	color_r = 1
	color_g = 1
	color_b = 1
	w_class = W_CLASS_SMALL
	var/mob/living/carbon/human/victim

	equipped(var/mob/user, var/slot)
		. = ..()
		var/mob/living/carbon/human/H = user
		if(istype(H) && slot == SLOT_WEAR_MASK)
			if ( user.mind && user.mind.assigned_role=="Clown" && istraitor(user) )
				src.cant_other_remove = 1
				src.cant_self_remove = 0
			else
				boutput (user, "<span class='alert'>[src] latches onto your face! It burns!</span>")
				src.victim = H
				src.cant_other_remove = 0
				src.cant_self_remove = 1
				src.victim.change_misstep_chance(25)
				src.victim.emote("scream")
				src.victim.TakeDamage("head",0,15,0,DAMAGE_BURN)
				src.victim.changeStatus("stunned", 2.5 SECONDS)
				processing_items.Add(src)

	unequipped(mob/user)
		. = ..()
		if (src.victim)
			src.victim.change_misstep_chance(-25)
			src.victim = null
			processing_items -= src

	process()
		if (src.victim)
			if ( src.victim.health <= 0 )
				return
			if (prob(45))
				boutput (src.victim, "<span class='alert'>[src] burns your face!</span>")
				if (prob(25))
					src.victim.emote("scream")
				src.victim.TakeDamage("head",0,3,0,DAMAGE_BURN)
			if (prob(20))
				src.victim.take_brain_damage(3)
			if (prob(10))
				src.victim.changeStatus("stunned", 2 SECONDS)
			if (prob(10))
				src.victim.changeStatus("slowed", 4 SECONDS)
			if (prob(60))
				src.victim.emote("laugh")

	afterattack(atom/target, mob/user, reach, params)
		if ( reach <= 1 && user.mind && user.mind.assigned_role == "Clown" && istraitor(user) && istype(user,/mob/living/carbon/human) && istype(target,/mob/living/carbon/human) )
			var/mob/living/carbon/human/U = user
			var/mob/living/carbon/human/T = target
			if ( U.a_intent != INTENT_HELP && U.zone_sel.selecting == "head" && T.can_equip(src,T.slot_wear_mask) )
				U.visible_message("<span class='alert'>[src] latches onto [T]'s face!</span>","<span class='alert'>You slap [src] onto [T]'s face!'</span>")
				logTheThing(LOG_COMBAT, user, "forces [T] to wear [src] (cursed clown mask) at [log_loc(T)].")
				U.u_equip(src)

				// If we don't empty out that slot first, it could blip the mask out of existence
				T.drop_from_slot(T.wear_mask)

				T.equip_if_possible(src,T.slot_wear_mask)


/obj/item/clothing/mask/medical
	name = "medical mask"
	desc = "This mask does not work very well in low pressure environments."
	icon_state = "medical"
	item_state = "medical"
	c_flags = COVERSMOUTH | MASKINTERNALS
	w_class = W_CLASS_SMALL
	protective_temperature = 420

/obj/item/clothing/mask/muzzle
	name = "muzzle"
	icon_state = "muzzle"
	item_state = "muzzle"
	c_flags = COVERSMOUTH
	w_class = W_CLASS_SMALL
	desc = "You'd probably say something like 'Hello Clarice.' if you could talk while wearing this."
	is_muzzle = 1

/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "Helps protect from viruses and bacteria."
	icon_state = "sterile"
	item_state = "s_mask"
	w_class = W_CLASS_TINY
	c_flags = COVERSMOUTH
	path_prot = 0

	setupProperties()
		..()
		setProperty("viralprot", 50) // fashion reasons, they're *space* masks, ok?
		setProperty("chemprot", 5)

/obj/item/clothing/mask/surgical_shield
	name = "surgical face shield"
	desc = "For those really, <i>really</i> messy surgeries."
	icon_state = "surgicalshield"
	item_state = "surgicalshield"
	w_class = W_CLASS_SMALL
	c_flags = COVERSMOUTH | COVERSEYES
	var/bee = FALSE
	var/randcol

	setupProperties()
		..()
		setProperty("meleeprot_head", 1)
		setProperty("chemprot", 7)
		setProperty("disorient_resist_eye", 10)

	New()
		..()
		var/image/inventory = image('icons/obj/clothing/item_masks.dmi', "")
		var/image/onhead = image('icons/mob/clothing/mask.dmi', "")

		if (prob(1))
			bee = TRUE
			name = "surgical face bee-ld"
			inventory.icon_state = "surgicalshield-bee"
			onhead.icon_state = "surgicalshield-bee"
			desc = "For those really, <i>really</i> messy surgeries where you also want to look like a dork."
		else
			inventory.icon_state = "surgicalshield-overlay"
			onhead.icon_state = "surgicalshield-overlay"
			randcol = random_hex(6)
			inventory.color = "#[randcol]"
			onhead.color = "#[randcol]"

		src.UpdateOverlays(inventory, "surgmaskcolour")
		src.wear_image.overlays += onhead

	update_wear_image(mob/living/carbon/human/H, override)
		var/image/onhead
		if(bee)
			onhead = image(src.wear_image.icon,"[override ? "mask-" : ""]surgicalshield-bee")
		else
			onhead = image(src.wear_image.icon,"[override ? "mask-" : ""]surgicalshield-overlay")
			onhead.color = "#[randcol]"
		src.wear_image.overlays = list(onhead)


/obj/item/paper_mask
	name = "unfinished paper mask"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "domino"
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	item_state = "domino"
	desc = "A little mask, made of paper. It isn't gunna stay on anyone's face like this, though."
	burn_point = 220
	burn_output = 900
	burn_possible = 1
	health = 3

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/pen))
			var/obj/item/pen/P = W
			if (P.font_color)
				boutput(user, "<span class='notice'>You scribble on the mask until it's filled in.</span>")
				if (P.font_color)
					src.color = P.font_color
		else if (istype(W,/obj/item/cable_coil/))
			boutput(user, "<span class='notice'>You attach the cable to the mask. Looks like you can wear it now.</span>")
			var/obj/item/cable_coil/C = W
			C.use(1)
			var/obj/item/clothing/mask/paper/M = new /obj/item/clothing/mask/paper(src.loc)
			user.put_in_hand_or_drop(M)
			//M.set_loc(get_turf(src)) // otherwise they seem to just vanish into the aether at times
			if (src.color)
				M.color = src.color
			qdel(src)

/obj/item/clothing/mask/paper
	name = "paper mask"
	desc = "A little mask, made of paper."
	icon_state = "domino"
	item_state = "domino"
	see_face = 0
	burn_point = 220
	burn_output = 900
	burn_possible = 1

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/pen))
			var/obj/item/pen/P = W
			if (P.font_color)
				boutput(user, "<span class='notice'>You scribble on the mask until it's filled in.</span>")
				src.color = P.font_color

/obj/item/clothing/mask/melons
	name = "flimsy 'George Melons' mask"
	desc = "Haven't seen that fellow in a while."
	icon_state = "melons"
	item_state = "melons"
	see_face = 0

/obj/item/clothing/mask/wrestling
	name = "wrestling mask"
	desc = "A mask that will greatly enhance your wrestling prowess! Not, like, <i>physically</i>, but mentally. In your heart. In your soul. Something like that."
	icon_state = "silvermask"
	item_state = "silvermask"
	see_face = 0

	black
		icon_state = "blackmask"
		item_state = "blackmask"

	green
		icon_state = "greenmask"
		item_state = "greenmask"

	blue
		icon_state = "bluemask"
		item_state = "bluemask"

/obj/item/clothing/mask/anime
	name = "moeblob mask"
	desc = "Looking at this thing gives you the heebie-jeebies. And a weird urge to go rob a bank, for some reason."
	icon_state = "anime"
	item_state = "anime"
	see_face = 0

/obj/item/clothing/mask/gas/plague
	name = "plague doctor mask"
	desc = "A beak-shaped mask filled with pleasant-smelling herbs to help protect you from miasma, the leading cause of the spread of disease*.<br><small><i>*This information may be slightly outdated, please use caution if using mask later than the 17th century.</i></small>"
	icon_state = "plague"
	item_state = "plague"
	color_r = 0.95 // darken just a little
	color_g = 0.95
	color_b = 0.95
	path_prot = 0

/obj/item/clothing/mask/chicken
	name = "chicken mask"
	desc = "Just your ordinary chicken mask that induces no violent feelings towards anyone or anything."
	icon_state = "chicken"
	item_state = "chicken"
	see_face = 0

/obj/item/clothing/mask/jester
	name = "jester's mask"
	desc = "The mask of a not-so-funny-clown."
	icon_state = "jester"
	item_state = "jester"
	see_face = 0

/obj/item/clothing/mask/hastur
	name = "cultist mask"
	desc = "The mask of a cultist who has seen the yellow sign and answered its call.."
	icon_state = "hasturmask"
	item_state = "hasturmask"
	see_face = 0

/obj/item/clothing/mask/kitsune
	name = "kitsune mask"
	desc = "The mask of a mythical fox creature from folklore."
	icon_state = "kitsune"
	item_state = "kitsune"
	see_face = 0

/obj/item/clothing/mask/blossommask
	name = "cherryblossom mask"
	desc = "A mask. Specifically for masquerades."
	icon_state = "cherryblossom"
	item_state = "cherryblossom"
	see_face = 0

/obj/item/clothing/mask/peacockmask
	name = "peacock mask"
	desc = "A mask. Specifically for masquerades."
	icon_state = "peacock"
	item_state = "peacock"
	see_face = 0

ABSTRACT_TYPE(/obj/item/clothing/mask/bandana)
/obj/item/clothing/mask/bandana
	name = "bandana"
	desc = "The desperado's choice."
	see_face = 0
	var/is_pulled_down = FALSE
	var/obj/item/cloth/handkerchief/handkerchief = null

	show_buttons()	//Hide the button from non-human mobs
		if (ishuman(the_mob))
			..()

/obj/item/clothing/mask/bandana/abilities = list(/obj/ability_button/toggle_bandana)

/obj/item/clothing/mask/bandana/attack_self(mob/user)
	if (!src.handkerchief)
		return
	var/obj/item/cloth/handkerchief/the_handkerchief = new src.handkerchief
	the_handkerchief.setMaterial(src.material)
	the_handkerchief.color = src.color
	src.copy_filters_to(the_handkerchief)
	qdel(src)
	user.put_in_hand_or_drop(the_handkerchief)
	boutput(user, "<span class='notice'>You unfold \the [src] into \a [the_handkerchief].</span>")

/obj/item/clothing/mask/bandana/white
	icon_state = "bandana_white"
	item_state = "bandana_white"
	handkerchief = /obj/item/cloth/handkerchief/white

/obj/item/clothing/mask/bandana/yellow
	name = "yellow bandana"
	item_state = "bandana_yellow"
	icon_state = "bandana_yellow"
	handkerchief = /obj/item/cloth/handkerchief/yellow

/obj/item/clothing/mask/bandana/red
	name = "red bandana"
	item_state = "bandana_red"
	icon_state = "bandana_red"
	handkerchief = /obj/item/cloth/handkerchief/red

/obj/item/clothing/mask/bandana/purple
	name = "purple bandana"
	item_state = "bandana_purple"
	icon_state = "bandana_purple"
	handkerchief = /obj/item/cloth/handkerchief/purple

/obj/item/clothing/mask/bandana/pink
	name = "pink bandana"
	item_state = "bandana_pink"
	icon_state = "bandana_pink"
	desc = "The fashionable bandit's choice."
	handkerchief = /obj/item/cloth/handkerchief/pink

/obj/item/clothing/mask/bandana/orange
	name = "orange bandana"
	item_state = "bandana_orange"
	icon_state = "bandana_orange"
	handkerchief = /obj/item/cloth/handkerchief/orange

/obj/item/clothing/mask/bandana/nt
	name = "nt bandana"
	item_state = "bandana_nt"
	icon_state = "bandana_nt"
	desc = "The rebel outlaw's choice."
	handkerchief = /obj/item/cloth/handkerchief/nt

/obj/item/clothing/mask/bandana/green
	name = "green bandana"
	item_state = "bandana_green"
	icon_state = "bandana_green"
	handkerchief = /obj/item/cloth/handkerchief/green

/obj/item/clothing/mask/bandana/blue
	name = "blue bandana"
	item_state = "bandana_blue"
	icon_state = "bandana_blue"
	handkerchief = /obj/item/cloth/handkerchief/blue

/obj/item/clothing/mask/bandana/random
	var/list/possible_bandana = list(/obj/item/clothing/mask/bandana/white,
										/obj/item/clothing/mask/bandana/yellow,
										/obj/item/clothing/mask/bandana/red,
										/obj/item/clothing/mask/bandana/purple,
										/obj/item/clothing/mask/bandana/pink,
										/obj/item/clothing/mask/bandana/orange,
										/obj/item/clothing/mask/bandana/green,
										/obj/item/clothing/mask/bandana/blue)

/obj/item/clothing/mask/bandana/random/New()
	..()
	var/obj/item/clothing/mask/bandana/bandana_to_spawn = pick(possible_bandana)
	new bandana_to_spawn(src.loc)
	qdel(src)
