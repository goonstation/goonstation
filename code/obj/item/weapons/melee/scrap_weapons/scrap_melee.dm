////////////////////////////////////////// Scrap melee child //////////////////////////////////////////////////
// To be completed refactores file location for weapons pre-2026-era code here. All weapons code parents should be placed inside the primary folders as primary directives.
// All files secondary to such must be placed in a new secondary folder within the primary folder. This is to ensure that all weapons code is properly-
// organized and as easy to navigate for future development and maintenance. Ensure they are named appropriately.
//
// Contains:
// - Primary Folder
// -- example_parent.dm
// -- Secondary Folder
// --- example_child.dm
//

////////////////////////////////////////// Scrap melee parent //////////////////////////////////////////////////
// Completely refactored the ca. 2009-era code here. Powered batons also use power cells now (Convair880).
// Contains:
// - Baton parent
// - Subtypes

/* Scrap weapons */
/obj/item/scrapweapons/weapons
	name = "youshouldntseemee scrapweapon"
	force = 5
	contraband = 4

	New()
		..()
		src.setItemSpecial(/datum/item_special/simple)

/obj/item/scrapweapons/weapons/melee/spear
	name = "scrap spear"
	desc = "A long rod without anything on the end. Still effective as a blunt instrument, but maybe you should attach something to the end."
	HELP_MESSAGE_OVERRIDE("To create a pointed spear you should first attach some <b>wires</b> to the spear, then attach a piece of <b>scrap metal, glass, or plasmaglass</b> as the tip.")
	icon_state = "spear"
	item_state = "spear"
	w_class = W_CLASS_NORMAL
	hit_type = DAMAGE_BLUNT
	force = 6
	throwforce = 10
	custom_suicide = 1
	attack_verbs = "impales"
	hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
	custom_suicide = 1
	var/wireadded = FALSE

	New()
		..()
		src.setItemSpecial(/datum/item_special/rangestab)

	attackby(obj/item/W, mob/user)
		if (!src.wireadded)
			if (istype(W, /obj/item/cable_coil))
				var/obj/item/cable_coil/coil = W
				if (coil.use(2))
					src.wireadded = TRUE
					boutput(user, SPAN_NOTICE("You attach the wire to the spear, now you just need a tip."))
					src.help_message = "Now attach a piece of <b>scrap metal, glass, or plasmaglass</b> to complete the spear."
					src.icon_state = "spear-wire"
					src.item_state = "spear-wire"
			else
				boutput(user, "<span class='alert'>You need to attach some wires before you stick anything on the spear!</span>")
				. = ..()
		else if (istype(W, /obj/item/raw_material/scrap_metal))
			W.change_stack_amount(-1)
			var/scrapmetalspear = new/obj/item/scrapweapons/weapons/melee/spear/scrapmetal
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, scrapmetalspear, user)
			qdel(src)
			user.put_in_hand_or_drop(scrapmetalspear)
			boutput(user, SPAN_NOTICE("You combine the blunt spear with the piece of scrap metal to add a sharp point."))

		else if (istype(W, /obj/item/raw_material/shard))
			if (istype(W.material, /datum/material/crystal/glass))
				W.change_stack_amount(-1)
				var/glassspear = new/obj/item/scrapweapons/weapons/melee/spear/glass
				SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, glassspear, user)
				qdel(src)
				user.put_in_hand_or_drop(glassspear)
				boutput(user, SPAN_NOTICE("You combine the blunt spear with the shard of glass to add a sharp point."))

			else if (istype(W.material, /datum/material/crystal/plasmaglass))
				W.change_stack_amount(-1)
				var/plasmaglassspear = new/obj/item/scrapweapons/weapons/melee/spear/plasmaglass
				SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, plasmaglassspear, user)
				qdel(src)
				user.put_in_hand_or_drop(plasmaglassspear)
				boutput(user, SPAN_NOTICE("You combine the blunt spear with the shard of scrap metal to add a sharp point."))

			else
				boutput(user, SPAN_ALERT("That just doesn't fit on the spear! Try glass or plasmaglass or scrap metal!"))
		else
			. = ..()



	scrapmetal
		desc = "A sharp pointy bit of metal strapped to a metal rod. Devastatingly simple."
		icon_state = "spear-scrapmetal"
		item_state = "spear-scrapmetal"
		force = 8
		hit_type = DAMAGE_STAB
		hitsound = 'sound/impact_sounds/Flesh_Stab_3.ogg'
		HELP_MESSAGE_OVERRIDE(null)

	glass
		desc = "A sharp pointy bit of glass strapped to a metal rod. Devastatingly simple."
		icon_state = "spear-glass"
		item_state = "spear-glass"
		force = 8
		hit_type = DAMAGE_STAB
		hitsound = 'sound/impact_sounds/Flesh_Stab_3.ogg'
		HELP_MESSAGE_OVERRIDE(null)

	plasmaglass
		desc = "A sharp pointy bit of plasmaglass strapped to a metal rod. Devastatingly simple."
		icon_state = "spear-pglass"
		item_state = "spear-pglass"
		force = 9 // plasmaglass is just a bit more damage dealing for scrap weapons
		hit_type = DAMAGE_STAB
		hitsound = 'sound/impact_sounds/Flesh_Stab_3.ogg'
		HELP_MESSAGE_OVERRIDE(null)

/obj/item/scrapweapons/weapons/melee/spear/suicide(var/mob/living/carbon/human/user as mob)
	if (!istype(user) || !user.organHolder || !src.user_can_suicide(user))
		return 0
	else
		user.visible_message(SPAN_ALERT("<b>[user] impales [himself_or_herself(user)] with the [src], straight through the heart! </b>"))
		user.organHolder.drop_and_throw_organ("heart", dist = 5, speed = 1, showtext = 1)
		playsound(src.loc, 'sound/impact_sounds/Blade_Small_Bloody.ogg', 50, 1)
		user.TakeDamage("chest", 100, 0)
		SPAWN(10 SECONDS)
		if (user)
			user.suiciding = 0
		return 1

/obj/item/scrapweapons/weapons/melee/machete
	name = "scrap machete"
	desc = "A few pieces of metal scraps cobbled together in the form of a machete. Looks deadly, to both the victim and the user..."
	icon_state = "machete"
	item_state = "machete"
	w_class = W_CLASS_NORMAL
	hit_type = DAMAGE_CUT
	tool_flags = TOOL_CUTTING | TOOL_CHOPPING
	force = 9
	attack_verbs = "hacks"
	hitsound = 'sound/impact_sounds/Flesh_Stab_3.ogg'
	custom_suicide = 1

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)

/obj/item/scrapweapons/weapons/melee/machete/suicide(var/mob/living/carbon/human/user as mob)
	if (!istype(user) || !user.organHolder || !src.user_can_suicide(user))
		return 0
	else
		var/organtokill = pick("liver", "spleen", "appendix", "stomach", "intestines")
		user.visible_message(SPAN_ALERT("<b>[user] stabs the [src] into [his_or_her(user)] own chest, disemboweling [himself_or_herself(user)] and ripping out [his_or_her(user)] [organtokill]! [pick("Brutal", "Holy fucking SHIT", "Why would [he_or_she(user)] do that?")]!</b>"))
		user.organHolder.drop_and_throw_organ(organtokill, dist = 5, speed = 1, showtext = 1)
		playsound(src.loc, 'sound/impact_sounds/Blade_Small_Bloody.ogg', 50, 1)
		user.TakeDamage("chest", 150, 0)
		SPAWN(10 SECONDS)
		if (user)
			user.suiciding = 0
		return 1

/obj/item/scrapweapons/weapons/melee/club
	name = "scrap club"
	desc = "A metal shaft attached to a handle. You might be able to improve it a bit."
	HELP_MESSAGE_OVERRIDE("To improve the club you should first attach some <b>wires</b> to the club, then attach a piece of <b>scrap metal, glass, or plasmaglass</b> as the studs.")
	icon_state = "club"
	item_state = "club"
	w_class = W_CLASS_NORMAL
	hit_type = DAMAGE_BLUNT
	force = 9
	throwforce = 6
	custom_suicide = 1
	attack_verbs = "smashes"
	hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
	custom_suicide = 1
	var/wireadded = FALSE

	scrapmetal
		desc = "A horrifyingly heavy amalgamation of scrap metal vaguely resembling a club or a bat."
		icon_state = "club-scrapmetal"
		item_state = "club-scrapmetal"
		HELP_MESSAGE_OVERRIDE(null)
		w_class = W_CLASS_NORMAL
		force = 11
		stamina_cost = 30
		stamina_damage = 35

	glass
		desc = "A horrifying amalgamation of scrap metal and glass vaguely resembling a club or a bat."
		icon_state = "club-glass"
		item_state = "club-glass"
		HELP_MESSAGE_OVERRIDE(null)
		w_class = W_CLASS_NORMAL
		hit_type = DAMAGE_CUT
		force = 11
		stamina_cost = 20
		stamina_damage = 25
		hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'

	plasmaglass
		desc = "A horrifying amalgamation of scrap metal and plasmaglass vaguely resembling a club or bat."
		icon_state = "club-pglass"
		item_state = "club-pglass"
		HELP_MESSAGE_OVERRIDE(null)
		w_class = W_CLASS_NORMAL
		hit_type = DAMAGE_CUT
		force = 12
		stamina_cost = 20
		stamina_damage = 25
		hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'

	attackby(obj/item/W, mob/user)
		. = ..()
		if (!src.wireadded)
			if (istype(W, /obj/item/cable_coil))
				var/obj/item/cable_coil/coil = W
				if (coil.use(2))
					src.wireadded = TRUE
					boutput(user, SPAN_NOTICE("You attach the wire to the club, now you just need some extra material."))
					src.desc = "A metal shaft attached to a handle with wire wrapped around it. You should be able to improve it further."
					src.help_message = "Now attach a piece of <b>scrap metal, glass, or plasmaglass</b>. to complete the club."
					src.icon_state = "club-wire"
					src.item_state = "club-wire"
		else if (istype(W, /obj/item/raw_material/scrap_metal))
			W.change_stack_amount(-1)
			var/scrapmetalclub = new/obj/item/scrapweapons/weapons/melee/club/scrapmetal
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, scrapmetalclub, user)
			qdel(src)
			user.put_in_hand_or_drop(scrapmetalclub)
			boutput(user, SPAN_NOTICE("You combine the club with the piece of scrap metal to add some extra weight."))

		else if (istype(W, /obj/item/raw_material/shard))
			if (istype(W.material, /datum/material/crystal/glass))
				W.change_stack_amount(-1)
				var/glassclub = new/obj/item/scrapweapons/weapons/melee/club/glass
				SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, glassclub, user)
				qdel(src)
				user.put_in_hand_or_drop(glassclub)
				boutput(user, SPAN_NOTICE("You combine the club with the glass shard."))

			else if (istype(W.material, /datum/material/crystal/plasmaglass))
				W.change_stack_amount(-1)
				var/plasmaglassclub = new/obj/item/scrapweapons/weapons/melee/club/plasmaglass
				SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, plasmaglassclub, user)
				qdel(src)
				user.put_in_hand_or_drop(plasmaglassclub)
				boutput(user, SPAN_NOTICE("You combine the club with the glass shard"))

/obj/item/scrapweapons/weapons/melee/club/suicide(var/mob/living/carbon/human/user as mob)
	if (!istype(user) || !user.organHolder || !src.user_can_suicide(user))
		return 0
	else
		user.visible_message(SPAN_ALERT("<b>[user] swings [his_or_her(user)] [src] in a mighty arc around [his_or_her(user)] head faster and faster until it hits [his_or_her(user)] head and knocks it clean off! [pick("Holy fucking shit", "Jesus christ what a show", "How is that even possible?", "Nice")]! </b>"))
		user.organHolder.drop_and_throw_organ("head", dist = 5, speed = 1, showtext = 1)
		playsound(src.loc, 'sound/impact_sounds/Blade_Small_Bloody.ogg', 50, 1)
		SPAWN(10 SECONDS)
		if (user)
			user.suiciding = 0
		return 1

/obj/item/scrapweapons/weapons/melee/dagger
	name = "scrap dagger"
	desc = "A tiny bit of pointy scrap attached to a handle. Looks like it will give you tetanus just holding it."
	icon_state = "dagger"
	item_state = "dagger"
	hit_type = DAMAGE_STAB
	w_class = W_CLASS_SMALL
	tool_flags = TOOL_CUTTING
	event_handler_flags = USE_GRAB_CHOKE
	force = 7
	throwforce = 7
	attack_verbs = "stabs"
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
	custom_suicide = 1

	New()
		..()
		src.setItemSpecial(/datum/item_special/jab)

	glass
		desc = "A tiny bit of glass attached to a handle. You might cut yourself just holding it."
		icon_state = "dagger-glass"
		item_state = "dagger-glass"

	plasmaglass
		desc = "A tiny bit of plasmaglass attached to a handle. You might cut yourself just holding it."
		icon_state = "dagger-pglass"
		item_state = "dagger-pglass"
		force = 8

/obj/item/scrapweapons/weapons/melee/dagger/suicide(var/mob/living/carbon/human/user as mob)
	if (!istype(user) || !user.organHolder || !src.user_can_suicide(user))
		return 0
	else
		user.visible_message(SPAN_ALERT("<b>[user] slashes [his_or_her(user)] own throat with [src]!</b>"))
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		playsound(src.loc, 'sound/impact_sounds/Flesh_Cut_1.ogg', 50, 1)
		SPAWN(10 SECONDS)
		if (user)
			user.suiciding = 0
		return 1
