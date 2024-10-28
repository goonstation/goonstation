/*
TOWELS & HANDKERCHIEFS
SPRITES BY WAFFLEOFFLE

TOWELS:
	* clean drinking glasses
	* clean plates and bowls
	* wipe down tables + chairs
	* wipe people down
	* clown: can eat and vomit

HANDKERCHIEFS:
	* wipe people's faces
	* various emotes into
	* wave
	* tiny secret

BOTH:
	* clean eyeglasses
	* chem gag rag
	* wipe heads
	* TODO: embroider
*/

ABSTRACT_TYPE(/obj/item/cloth)
/obj/item/cloth
	name = "cloth"
	icon = 'icons/obj/items/cloths.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_cloths.dmi'
	throwforce = 0
	throw_speed = 4
	throw_range = 10
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 5
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab/rag_muffle

/obj/item/cloth/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if (user.a_intent != INTENT_HELP)
		return ..()
	return TRUE

/obj/item/cloth/New()
	..()
	src.create_reagents(20)

/obj/item/cloth/disposing()
	..()
	if(reagents)
		reagents.clear_reagents()

/obj/item/cloth/process_grab(var/mult = 1)
	..()
	if (chokehold.transfering_chemicals || chokehold.state > GRAB_AGGRESSIVE) // Having more than an aggressive grab will transfer the chemicals anyway
		if (src.chokehold && src.reagents && src.reagents.total_volume > 0 && chokehold.state >= GRAB_AGGRESSIVE && iscarbon(src.chokehold.affecting))
			//src.reagents.reaction(chokehold.affecting, INGEST, 0.5 * mult) // No more ingesting means no stacking damage horribly and instantly
			src.reagents.trans_to(chokehold.affecting, 2 * mult)
		else
			chokehold.transfering_chemicals = FALSE

/obj/item/cloth/is_open_container()
	.= 1

ABSTRACT_TYPE(/obj/item/cloth/towel)
/obj/item/cloth/towel
	name = "towel"
	desc = "About the most massively useful thing a spacefaring traveler can have."
	w_class = W_CLASS_SMALL

/obj/item/cloth/towel/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if (!..())
		return
	user.visible_message(SPAN_NOTICE("[user] wipes [target] down with [src]."))
	target.clean_forensic()
	src.reagents.reaction(target, TOUCH, 5)
	src.reagents.remove_any(5)
	JOB_XP(user, "Janitor", 3)
	if (target.reagents)
		target.reagents.trans_to(src, 5)
	playsound(src, 'sound/items/towel.ogg', 20, TRUE)
	animate_smush(target)

/obj/item/cloth/towel/afterattack(atom/target, mob/user as mob)
	if (istype(target, /obj/item/reagent_containers/food/drinks) || istype(target, /obj/item/reagent_containers/food/drinks/bowl) || istype(target, /obj/item/plate))
		if (target.reagents?.total_volume || length(target.contents))
			boutput(user, SPAN_ALERT("[target] needs to be emptied first."))
			return
		user.visible_message(SPAN_NOTICE("[user] [pick("polishes", "shines", "cleans", "wipes")] [target] with [src]."))
		playsound(src, 'sound/items/glass_wipe.ogg', 35, TRUE)

/obj/item/cloth/towel/white
	name = "white towel"
	icon_state = "towel_white"

/obj/item/cloth/towel/yellow
	name = "yellow towel"
	icon_state = "towel_yellow"

/obj/item/cloth/towel/sundae
	name = "sundae towel"
	icon_state = "towel_sundae"

/obj/item/cloth/towel/pink
	name = "pink towel"
	icon_state = "towel_pink"

/obj/item/cloth/towel/green
	name = "green towel"
	icon_state = "towel_green"

/obj/item/cloth/towel/clown
	name = "clown towel"
	desc = "About the most massively useful thing a clown can have."
	icon_state = "towel_clown"
	var/hidden_pocket = null // storage components when!

/obj/item/cloth/towel/clown/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if (target != user || user.mind?.assigned_role != "Clown")
		return ..()
	var/mob/living/carbon/human/H = user
	if (!H.organHolder?.stomach)
		user.show_message(SPAN_ALERT("You can't seem to swallow!"))
		return
	user.visible_message(SPAN_ALERT("[user] rolls [src] into a ball and eats it!"))
	playsound(user, 'sound/misc/gulp.ogg', 30, TRUE)
	eat_twitch(user)
	user.drop_item(src)
	H.organHolder.stomach.consume(src)
	SPAWN(1 SECOND)
		user.emote("burp")

/obj/item/cloth/towel/clown/attackby(obj/item/I, mob/user)
	if (I.w_class != W_CLASS_TINY || user.mind?.assigned_role != "Clown")
		return ..()
	if (!isnull(hidden_pocket))
		boutput(user, SPAN_ALERT("You already have an item stored in the towel!"))
		return
	animate_storage_rustle(src)
	playsound(src, "rustle", 50, 1, -5)
	user.visible_message(SPAN_NOTICE("[user] [pick("surreptitiously", "sneakily", "awkwardly")] stows [I] away in one of [src]'s many hidden pockets."))
	user.drop_item(I)
	I.set_loc(src)
	hidden_pocket = I

/obj/item/cloth/towel/clown/attack_self(mob/user)
	if (!hidden_pocket)
		return ..()
	animate_storage_rustle(src)
	playsound(src, "rustle", 50, 1, -5)
	user.visible_message(SPAN_NOTICE("[user] rummages through [src] and retrieves [hidden_pocket] from one of its many hidden pockets!"))
	user.put_in_hand_or_drop(hidden_pocket)
	hidden_pocket = null

/obj/item/cloth/towel/blue
	name = "blue towel"
	icon_state = "towel_blue"

/obj/item/cloth/towel/black
	name = "black towel"
	icon_state = "towel_black"
/obj/item/cloth/towel/janitor
	name = "trusty towel"
	desc = "About the most massively useful thing a janitor can have."

/obj/item/cloth/towel/janitor/New()
	..()
	icon_state = "towel_[pick("yellow", "sundae", "pink", "green", "blue", "grey", "orange")]"

/obj/item/cloth/towel/bar
	name = "bar towel"
	desc = "About the most massively useful thing a bartender can have."
	icon_state = "towel_black"

/obj/item/cloth/towel/security
	name = "security towel"
	icon_state = "towel_security"

ABSTRACT_TYPE(/obj/item/cloth/handkerchief)
/obj/item/cloth/handkerchief
	name = "handkerchief"
	desc = "Probably bought from an upscale boutique somewhere."
	w_class = W_CLASS_TINY
	var/obj/item/clothing/mask/bandana/bandana = null

/obj/item/cloth/handkerchief/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if (!..())
		return
	user.visible_message(SPAN_NOTICE("[user] [pick("dabs at", "blots at", "wipes")] [target == user ? his_or_her(user) : "[target]'s"] face with [src]."))

/obj/item/cloth/handkerchief/attack_self(mob/user)
	if (!src.bandana)
		return
	var/obj/item/clothing/mask/bandana/the_bandana = new src.bandana
	the_bandana.setMaterial(src.material)
	the_bandana.color = src.color
	src.copy_filters_to(the_bandana)
	qdel(src)
	user.put_in_hand_or_drop(the_bandana)
	boutput(user, SPAN_NOTICE("You tie \the [src] together to make \a [the_bandana]."))

ABSTRACT_TYPE(/obj/item/cloth/handkerchief/colored)
/obj/item/cloth/handkerchief/colored

/obj/item/cloth/handkerchief/colored/white
	name = "white handkerchief"
	icon_state = "hanky_white"
	bandana = /obj/item/clothing/mask/bandana/white

/obj/item/cloth/handkerchief/colored/yellow
	name = "yellow handkerchief"
	icon_state = "hanky_yellow"
	bandana = /obj/item/clothing/mask/bandana/yellow

/obj/item/cloth/handkerchief/colored/red
	name = "red handkerchief"
	icon_state = "hanky_red"
	bandana = /obj/item/clothing/mask/bandana/red

/obj/item/cloth/handkerchief/colored/purple
	name = "purple handkerchief"
	icon_state = "hanky_purple"
	bandana = /obj/item/clothing/mask/bandana/purple

/obj/item/cloth/handkerchief/colored/pink
	name = "pink handkerchief"
	icon_state = "hanky_pink"
	bandana = /obj/item/clothing/mask/bandana/pink

/obj/item/cloth/handkerchief/colored/orange
	name = "orange handkerchief"
	icon_state = "hanky_orange"
	bandana = /obj/item/clothing/mask/bandana/orange

/obj/item/cloth/handkerchief/nt
	name = "NT handkerchief"
	desc = "The handkerchief of an esteemed NanoTrasen official."
	icon_state = "hanky_nt"
	bandana = /obj/item/clothing/mask/bandana/nt

/obj/item/cloth/handkerchief/colored/green
	name = "green handkerchief"
	icon_state = "hanky_green"
	bandana = /obj/item/clothing/mask/bandana/green

/obj/item/cloth/handkerchief/colored/blue
	name = "blue handkerchief"
	icon_state = "hanky_blue"
	bandana = /obj/item/clothing/mask/bandana/blue

/obj/item/cloth/handkerchief/random

/obj/item/cloth/handkerchief/random/New()
	..()
	var/obj/item/cloth/handkerchief/handkerchief_to_spawn = pick(concrete_typesof(/obj/item/cloth/handkerchief/colored))
	new handkerchief_to_spawn(src.loc)
	qdel(src)
