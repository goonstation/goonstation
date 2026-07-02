////////////////////////////////////////// Scrap weapons parent //////////////////////////////////////////////////
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

/* Scrap weapons
Cobbled together pieces of junk that make barely passable weapons.
Ideally they're weaker than some of the other common station weapons such as fire extinguishers or decon devices but still viable as weapons.
Meant to be a weapon you make if you can't find anything else.
*/


/*Abstract Types for Scrap Weapons */
ABSTRACT_TYPE(/obj/item/scrapweapons)
ABSTRACT_TYPE(/obj/item/scrapweapons/parts)
ABSTRACT_TYPE(/obj/item/scrapweapons/weapons)

/* Base object */
/obj/item/scrapweapons
	name = "youshouldntseeme basescrapweapon"
	icon = 'icons/obj/items/scrapweapons.dmi' //codersprites. improve if you want or feel the need
	inhand_image_icon = 'icons/mob/inhand/hand_scrapweapons.dmi'
	flags = TABLEPASS | NOSHIELD | USEDELAY
	object_flags = NO_GHOSTCRITTER // blanket ban on all scrapweapon items for ghost critters
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	can_arcplate = FALSE


/* Scrap weapon parts/in construction states */
/obj/item/scrapweapons/parts
	name = "youshouldntseethis scrapweaponbase"
	hit_type = DAMAGE_BLUNT
	w_class = W_CLASS_SMALL
	force = 1
	throwforce = 1
	attack_verbs = "whacks"

/obj/item/scrapweapons/parts/handle // base of all/most scrap weapons just as an easy starting point
	name = "scrap handle"
	desc = "A handle for a yet unmade weapon. Try attaching something to it."
	icon_state = "handle"
	material_amt = 0.1
	HELP_MESSAGE_OVERRIDE("You may attach the following items while holding a <b>lit welding tool</b> in your offhand to this handle to create a weapon:<br> A <b>scrap blade, shaft, or pole</b> which can be made with some metal sheets to make a machete, club, or spear, respectively. <br> Or a shard of <b>glass, plasmaglass, or scrap metal</b> to create a dagger")

	attackby(obj/item/W, mob/user)
		. = ..()
		var/successful	//Whether we successfully built something or not
		for	(var/obj/item/E in user.equipped_list())
			if (isweldingtool(E) && E:try_weld(user,0,0,0,0))
				if (istype(W, /obj/item/scrapweapons/parts/blade))
					qdel(W)
					var/machete = new/obj/item/scrapweapons/weapons/melee/machete
					SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, machete, user)
					qdel(src)
					user.put_in_hand_or_drop(machete)
					boutput(user, SPAN_NOTICE("You fuse the handle and blade into a scrap machete."))
					successful = TRUE

				if (istype(W, /obj/item/scrapweapons/parts/shaft))
					qdel(W)
					var/club = new/obj/item/scrapweapons/weapons/melee/club
					SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, club, user)
					qdel(src)
					user.put_in_hand_or_drop(club)
					boutput(user, SPAN_NOTICE("You fuse the handle and shaft into a scrap club."))
					successful = TRUE


				if (istype(W, /obj/item/scrapweapons/parts/pole))
					qdel(W)
					var/spear = new/obj/item/scrapweapons/weapons/melee/spear
					SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, spear, user)
					qdel(src)
					user.put_in_hand_or_drop(spear)
					boutput(user, SPAN_NOTICE("You fuse the handle and pole into a blunt scrap spear."))
					successful = TRUE


				if (istype(W, /obj/item/raw_material/scrap_metal))
					W.change_stack_amount(-1)
					var/dagger = new/obj/item/scrapweapons/weapons/melee/dagger
					SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, dagger, user)
					qdel(src)
					user.put_in_hand_or_drop(dagger)
					boutput(user, SPAN_NOTICE("You fuse the handle and scrap metal into a scrap dagger."))
					successful = TRUE

				else if (istype(W, /obj/item/raw_material/shard))
					if (istype(W.material, /datum/material/crystal/glass))
						W.change_stack_amount(-1)
						var/glassdagger = new/obj/item/scrapweapons/weapons/melee/dagger/glass
						SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, glassdagger, user)
						qdel(src)
						user.put_in_hand_or_drop(glassdagger)
						boutput(user, SPAN_NOTICE("You fuse the handle and glass shard into a scrap dagger."))
						successful = TRUE

					else if (istype(W.material, /datum/material/crystal/plasmaglass))
						W.change_stack_amount(-1)
						var/plasmaglassdagger = new/obj/item/scrapweapons/weapons/melee/dagger/plasmaglass
						SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, plasmaglassdagger, user)
						qdel(src)
						user.put_in_hand_or_drop(plasmaglassdagger)
						boutput(user, SPAN_NOTICE("You fuse the handle and plasmaglass shard into a scrap dagger."))
						successful = TRUE
				if (successful == TRUE)
					E:try_weld(user,2,-1,1,1)

/obj/item/scrapweapons/parts/blade
	name = "scrap blade"
	desc = "A flat and sharp piece of metal. Might work as a weapon in a pinch but you should try attaching it to something."
	icon_state = "blade"
	material_amt = 0.3
	HELP_MESSAGE_OVERRIDE("Attach this to a <b>scrap handle</b> while holding a <b>lit welding tool</b> in your <b>offhand</b> to create a <b>scrap machete</b>.")
	force = 5 // it's still a blade, just not a very good one yet
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'

/obj/item/scrapweapons/parts/shaft // im 12 years old and saying shaft makes me giggle
	name = "metal shaft"
	desc = "A long and round piece of metal. Try attaching it to something."
	icon_state = "shaft"
	material_amt = 0.2
	HELP_MESSAGE_OVERRIDE("Attach this to a <b>scrap handle</b> while holding a <b>lit welding tool</b> in your <b>offhand</b> to create a <b>scrap club</b>. <br> Or attach this to another <b>metal shaft</b> while holding a <b>lit welding tool</b> in your <b>offhand</b> to create a <b>metal pole</b>.")
	force = 4

	attackby(obj/item/W, mob/user)
		. = ..()
		for	(var/obj/item/E in user.equipped_list())
			if (isweldingtool(E) && E:try_weld(user,2,-1,1,1))
				if (istype(W, /obj/item/scrapweapons/parts/shaft))
					qdel(W)
					var/pole = new/obj/item/scrapweapons/parts/pole
					SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, pole, user)
					qdel(src)
					user.put_in_hand_or_drop(pole)
					boutput(user, SPAN_NOTICE("You fuse the two shafts together into a <b>metal pole</b>."))

/obj/item/scrapweapons/parts/pole
	name = "metal pole"
	desc = "Two metal shafts attached together. Try attaching it to something."
	icon_state = "pole"
	HELP_MESSAGE_OVERRIDE("Attach this to a <b>scrap handle</b> while holding a <b>lit welding tool</b> in your <b>offhand</b> to create a <b>scrap spear</b>.")
	force = 5
