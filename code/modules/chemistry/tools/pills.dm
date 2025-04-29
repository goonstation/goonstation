
/* =============================================== */
/* -------------------- Pills -------------------- */
/* =============================================== */

/obj/item/reagent_containers/pill
	name = "pill"
	desc = "a pill."
	icon = 'icons/obj/items/pills.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "pill0"
	item_state = "pill"
	rc_flags = RC_SPECTRO		// only spectroscopic analysis
	flags = NOSPLASH | TABLEPASS
	rand_pos = 1
	var/random_icon = 0
	var/image/color_overlay
	var/color_overlay_alpha = 180

	New()
		..()
		init()

	proc/init()
		reagents = new/datum/reagents(100)
		reagents.my_atom = src
		if (src.random_icon)
			src.create_random_icon()


	attack_self(mob/user as mob)
		if (!src.reagents || !src.reagents.total_volume)
			user.show_text("[src] doesn't contain any reagents.", "red")
			return
		src.pill_action(user, user)
		return

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (!src.reagents || !src.reagents.total_volume)
			user.show_text("[src] doesn't contain any reagents.", "red")
			return

		if (iscarbon(target) || ismobcritter(target))
			if (target == user)
				src.pill_action(target, user)
			else if(check_target_immunity(target))
				user.show_message( SPAN_ALERT("You try to force [target] to swallow [src], but can't!"))
				return
			else
				user.visible_message(SPAN_ALERT("[user] attempts to force [target] to swallow [src]."),\
				SPAN_ALERT("You attempt to force [target] to swallow [src]."))
				logTheThing(LOG_COMBAT, user, "tries to force-feed a [src.name] [log_reagents(src)] to [constructTarget(target,"combat")] at [log_loc(user)].")
				actions.start(new/datum/action/bar/icon/pill(target, src, src.icon, src.icon_state), user)
			return 1

		return 0

	attackby(obj/item/I, mob/user)
		if (!I)
			return
		if (I.is_open_container(TRUE) && I.reagents)
			if (istype(I, /obj/item/clothing/mask/cigarette)) //Apparently you can smush a lit cigarette into a pill and destroy both
				return
			src.AfterAttack(I, user)	//Probably weird but afterattack contains the dissolving code
		return

	proc/create_random_icon()
		src.icon_state = "pill[rand(1,20)]"
		return

	afterattack(var/atom/target, mob/user, flag)
		if (!isobj(target))
			return ..()
		if (target.is_open_container(TRUE) && target.reagents)
			if (!src.reagents || !src.reagents.total_volume)
				boutput(user, SPAN_ALERT("[src] doesn't contain any reagents."))
				return
			if (target.reagents.is_full())
				boutput(user, SPAN_ALERT("[target] is full!"))
				return

			if (istype(target, /obj/item/pen/sleepypen))
				boutput(user, SPAN_NOTICE("You cram the pill into the [target.name]. Elegant."))
			else
				user.visible_message(SPAN_ALERT("[user] puts something in [target]."),\
				SPAN_SUCCESS("You dissolve [src] in [target]."))

			logTheThing(LOG_CHEMISTRY, user, "dissolves a [src.name] [log_reagents(src)] in [target] at [log_loc(user)].")
			reagents.trans_to(target, src.reagents.total_volume)
			user.u_equip(src)
			qdel(src)
			return
		else
			return ..()

	on_reagent_transfer()
		..()
		qdel(src)

	proc/pill_action(mob/user, mob/target)
		if (iscarbon(target) || ismobcritter(target))
			if (target == user)
				user.visible_message("[user] swallows [src].",\
				SPAN_NOTICE("You swallow [src]."))
			else if(check_target_immunity(target))
				user.show_message( SPAN_ALERT("You try to force [target] to swallow [src], but fail!"))
				return
			else
				user.visible_message(SPAN_ALERT("[user] forces [target] to swallow [src]."),\
				SPAN_ALERT("You force [target] to swallow [src]."))

			logTheThing(user == target ? LOG_CHEMISTRY : LOG_COMBAT, user, "[user == target ? "swallows" : "makes [constructTarget(target,"combat")] swallow"] a [src.name] [log_reagents(src)] at [log_loc(user)].")

			if (src.reagents.total_volume)
				src.reagents.reaction(target, INGEST)
				sleep(0.1 SECONDS)
				reagents?.trans_to(target, src.reagents.total_volume)
			user.u_equip(src)
			qdel(src)



/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/pill/uranium
	name = "Uranium nugget"
	icon_state = "pill22"
	init()
		..()
		reagents.clear_reagents()
		reagents.add_reagent("uranium", rand(4,6))

/obj/item/reagent_containers/pill/antitox
	name = "charcoal pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"

	New()
		..()
		reagents.add_reagent("charcoal", 20)

/obj/item/reagent_containers/pill/calomel
	name = "calomel pill"
	desc = "Can be used to purge impurities, but is highly toxic itself."
	icon_state = "pill3"

	New()
		..()
		reagents.add_reagent("calomel", 15)

/obj/item/reagent_containers/pill/tox
	name = "cyanide pill"
	desc = "Highly lethal."
	icon_state = "pill5"

	New()
		..()
		reagents.add_reagent("cyanide", 50)

/obj/item/reagent_containers/pill/toxlite // Small pill for the trader that sells cyanide. So as to not be offgassed instantly.
	name = "small cyanide pill"
	desc = "Smaller but still Highly lethal."
	icon_state = "pill5"

	New()
		..()
		reagents.add_reagent("cyanide", 30)

/obj/item/reagent_containers/pill/stox
	name = "morphine pill"
	desc = "Used to treat severe pain. Highly addictive."
	icon_state = "pill8"

	New()
		..()
		reagents.add_reagent("morphine", 30)

/obj/item/reagent_containers/pill/salicylic_acid
	name = "analgesic pill"
	desc = "A painkiller used to treat minor injuries."
	icon_state = "pill4"

	New()
		..()
		reagents.add_reagent("salicylic_acid", 10)

/obj/item/reagent_containers/pill/menthol
	name = "menthol pill"
	desc = "This pill looks kinda cool. It's used to treat moderate burns and fevers."
	icon_state = "pill21"

	New()
		..()
		reagents.add_reagent("menthol", 10)

/obj/item/reagent_containers/pill/silver_sulfadiazine
	name = "silver sulfadiazine pill" //wtf
	desc = "Used to treat burns, but it's not meant to be ingested. Welp."
	icon_state = "pill11"

	New()
		..()
		reagents.add_reagent("silver_sulfadiazine", 30)

/obj/item/reagent_containers/pill/epinephrine
	name = "epinephrine pill"
	desc = "Used to stabilize patients in crisis."
	icon_state = "pill20"

	New()
		..()
		reagents.add_reagent("epinephrine", 10)

/obj/item/reagent_containers/pill/salbutamol
	name = "salbutamol pill"
	desc = "Used to treat respiratory distress."
	icon_state = "pill16"

	New()
		..()
		reagents.add_reagent("salbutamol", 20)

/obj/item/reagent_containers/pill/mutadone
	name = "mutadone pill"
	desc = "Used to cure genetic abnormalities."
	icon_state = "pill18"

	New()
		..()
		reagents.add_reagent("mutadone", 20)

/obj/item/reagent_containers/pill/mannitol
	name = "mannitol pill"
	desc = "Used to treat cranial swelling."
	icon_state = "pill19"

	New()
		..()
		reagents.add_reagent("mannitol", 20)

/obj/item/reagent_containers/pill/antirad
	name = "potassium iodide pill"
	desc = "Used to treat radiation poisoning."
	icon_state = "pill9"

	New()
		..()
		reagents.add_reagent("anti_rad", 20)

/obj/item/reagent_containers/pill/hairgrownium
	name = "\improper EZ-Hairgrowth pill"
	desc = "The #1 hair growth product on the market! WARNING: Some side effects may occur."
	icon_state = "pill6"

	New()
		..()
		reagents.add_reagent("hairgrownium", 5)

// drugs 420 all day

/obj/item/reagent_containers/pill/CBD
	name = "cannabidiol pill"
	desc = "An alternative painkiller with no psychoactive effects."
	icon_state = "pill23"

	New()
		. = ..()
		reagents.add_reagent("CBD", 20)

/obj/item/reagent_containers/pill/methamphetamine
	name = "methamphetamine pill"
	desc = "Methamphetamine is a highly effective and dangerous stimulant drug."
	icon_state = "pill9"

	New()
		..()
		reagents.add_reagent("methamphetamine", 10)

/obj/item/reagent_containers/pill/crank
	name = "crank pill"
	desc = "A cheap and dirty stimulant drug, commonly used by space biker gangs."
	icon_state = "pill4"

	New()
		..()
		reagents.add_reagent("crank", 10)

/obj/item/reagent_containers/pill/bathsalts
	name = "bath salts pill"
	desc = "Sometimes packaged as a refreshing bathwater additive, these crystals are definitely not for human consumption."
	icon_state = "pill1"

	New()
		..()
		reagents.add_reagent("bathsalts", 10)

/obj/item/reagent_containers/pill/catdrugs
	name = "cat drugs pill"
	desc = "Uhhh..."
	icon_state = "pill5"

	New()
		..()
		reagents.add_reagent("catdrugs", 10)

/obj/item/reagent_containers/pill/cyberpunk
	name = "cyberpunk pill"
	desc = "A cocktail of illicit designer drugs, who knows what might be in here."
	random_icon = 1

	New()
		..()
		name = "[pick_string("chemistry_tools.txt", "CYBERPUNK_drug_prefixes")] [pick_string("chemistry_tools.txt", "CYBERPUNK_drug_suffixes")]"

		var/primaries = rand(1,3)
		var/adulterants = rand(2,4)



		while(primaries > 0)
			primaries--
			reagents.add_reagent(pick_string("chemistry_tools.txt", "CYBERPUNK_drug_primaries"), 6)
		while(adulterants > 0)
			adulterants--
			reagents.add_reagent(pick_string("chemistry_tools.txt", "CYBERPUNK_drug_adulterants"), 3)

/obj/item/reagent_containers/pill/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/reagent_containers/pill/vr/mannitol
	name = "mannitol pill"
	desc = "Used to treat cranial swelling."
	icon_state = "pill1"

	New()
		..()
		reagents.add_reagent("mannitol", 20)

/obj/item/reagent_containers/pill/vr/antitox
	name = "anti-toxins pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill2"

	New()
		..()
		reagents.add_reagent("charcoal", 20)

/obj/item/reagent_containers/pill/vr/salicylic_acid
	name = "analgesic pill"
	desc = "Commonly used to treat moderate pain and fevers."
	icon_state = "pill3"

	New()
		..()
		reagents.add_reagent("salicylic_acid", 10)

/obj/item/reagent_containers/pill/vr/salbutamol
	name = "salbutamol pill"
	desc = "Used to treat respiratory distress."
	icon_state = "pill4"

	New()
		..()
		reagents.add_reagent("salbutamol", 20)

/obj/item/reagent_containers/pill/ipecac
	name = "space ipecac pill"
	desc = "Used to induce emesis. In space."
	icon_state = "pill13"
	initial_volume = 5

	New()
		..()
		reagents.add_reagent("ipecac", 5)
