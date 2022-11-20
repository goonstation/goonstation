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

/obj/item/cloth/attack(mob/living/M, mob/user)
	if (user.a_intent != INTENT_HELP)
		return ..()
	return TRUE

/obj/item/cloth/New()
	..()
	src.create_reagents(10)

/obj/item/cloth/disposing()
	..()
	if(reagents)
		reagents.clear_reagents()

/obj/item/cloth/process_grab(var/mult = 1)
	..()
	if (src.chokehold && src.reagents && src.reagents.total_volume > 0 && chokehold.state == GRAB_CHOKE && iscarbon(src.chokehold.affecting))
		src.reagents.reaction(chokehold.affecting, INGEST, 0.5 * mult)
		src.reagents.trans_to(chokehold.affecting, 0.5 * mult)

/obj/item/cloth/is_open_container()
	.= 1

ABSTRACT_TYPE(/obj/item/cloth/towel)
/obj/item/cloth/towel
	name = "towel"
	desc = "About the most massively useful thing a spacefaring traveler can have."
	w_class = W_CLASS_SMALL

/obj/item/cloth/towel/attack(mob/living/M, mob/user)
	if (!..())
		return
	user.visible_message("<span class='notice'>[user] wipes [M] down with [src].</span>")
	M.clean_forensic()
	src.reagents.reaction(M, TOUCH, 5)
	src.reagents.remove_any(5)
	JOB_XP(user, "Janitor", 3)
	if (M.reagents)
		M.reagents.trans_to(src, 5)
	playsound(src, 'sound/items/towel.ogg', 20, 1)
	animate_smush(M)

/obj/item/cloth/towel/afterattack(atom/target, mob/user as mob)
	if (istype(target, /obj/item/reagent_containers/food/drinks) || istype(target, /obj/item/reagent_containers/food/drinks/bowl) || istype(target, /obj/item/plate))
		if (target.reagents?.total_volume || length(target.contents))
			boutput(user, "<span class='alert'>[target] needs to be emptied first.</span>")
			return
		user.visible_message("<span class='notice'>[user] [pick("polishes", "shines", "cleans", "wipes")] [target] with [src].</span>")

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

/obj/item/cloth/towel/clown/attack(mob/living/M, mob/user)
	if (M != user || user.mind?.assigned_role != "Clown")
		return ..()
	user.visible_message("<span class='alert'>[user] rolls [src] into a ball and eats it!</span>")
	playsound(user, 'sound/misc/gulp.ogg', 30, 1)
	eat_twitch(user)
	user.drop_item(src)
	src.set_loc(user)
	SPAWN(1 SECOND)
		user.emote("burp")
	var/mob/living/carbon/human/H = user
	H.stomach_process += src

/obj/item/cloth/towel/clown/attackby(obj/item/I, mob/user)
	if (I.w_class != W_CLASS_TINY || user.mind?.assigned_role != "Clown")
		return ..()
	if (!isnull(hidden_pocket))
		boutput(user, "<span class='alert'>You already have an item stored in the towel!</span>")
		return
	animate_storage_rustle(src)
	playsound(src, "rustle", 50, 1, -5)
	user.visible_message("<span class='notice'>[user] [pick("surreptitiously", "sneakily", "awkwardly")] stows [I] away in one of [src]'s many hidden pockets.</span>")
	user.drop_item(I)
	I.set_loc(src)
	hidden_pocket = I

/obj/item/cloth/towel/clown/attack_self(mob/user)
	if (!hidden_pocket)
		return ..()
	animate_storage_rustle(src)
	playsound(src, "rustle", 50, 1, -5)
	user.visible_message("<span class='notice'>[user] rummages through [src] and retrieves [hidden_pocket] from one of its many hidden pockets!</span>")
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

ABSTRACT_TYPE(/obj/item/cloth/handkerchief)
/obj/item/cloth/handkerchief
	name = "handkerchief"
	desc = "Probably bought from an upscale boutique somewhere."
	w_class = W_CLASS_TINY
	var/obj/item/clothing/mask/bandana/bandana = null

/obj/item/cloth/handkerchief/attack(mob/living/M, mob/user)
	if (!..())
		return
	user.visible_message("<span class='notice'>[user] [pick("dabs at", "blots at", "wipes")] [M == user ? his_or_her(user) : "[M]'s"] face with [src].</span>")

/obj/item/cloth/handkerchief/attack_self(mob/user)
	if (!src.bandana)
		return
	qdel(src)
	var/obj/item/clothing/mask/bandana/the_bandana = new src.bandana
	user.put_in_hand_or_drop(the_bandana)
	boutput(user, "<span class='notice'>You tie the handkerchief together to make [the_bandana].</span>")

/obj/item/cloth/handkerchief/white
	name = "white handkerchief"
	icon_state = "hanky_white"
	bandana = /obj/item/clothing/mask/bandana/white

/obj/item/cloth/handkerchief/yellow
	name = "yellow handkerchief"
	icon_state = "hanky_yellow"
	bandana = /obj/item/clothing/mask/bandana/yellow

/obj/item/cloth/handkerchief/red
	name = "red handkerchief"
	icon_state = "hanky_red"
	bandana = /obj/item/clothing/mask/bandana/red

/obj/item/cloth/handkerchief/purple
	name = "purple handkerchief"
	icon_state = "hanky_purple"
	bandana = /obj/item/clothing/mask/bandana/purple

/obj/item/cloth/handkerchief/pink
	name = "pink handkerchief"
	icon_state = "hanky_pink"
	bandana = /obj/item/clothing/mask/bandana/pink

/obj/item/cloth/handkerchief/orange
	name = "orange handkerchief"
	icon_state = "hanky_orange"
	bandana = /obj/item/clothing/mask/bandana/orange

/obj/item/cloth/handkerchief/nt
	name = "NT handkerchief"
	desc = "The handkerchief of an esteemed NanoTrasen official."
	icon_state = "hanky_nt"
	bandana = /obj/item/clothing/mask/bandana/nt

/obj/item/cloth/handkerchief/green
	name = "green handkerchief"
	icon_state = "hanky_green"
	bandana = /obj/item/clothing/mask/bandana/green

/obj/item/cloth/handkerchief/blue
	name = "blue handkerchief"
	icon_state = "hanky_blue"
	bandana = /obj/item/clothing/mask/bandana/blue

/obj/item/cloth/handkerchief/random
	var/list/possible_handkerchief = list(/obj/item/cloth/handkerchief/white,
										/obj/item/cloth/handkerchief/yellow,
										/obj/item/cloth/handkerchief/red,
										/obj/item/cloth/handkerchief/purple,
										/obj/item/cloth/handkerchief/pink,
										/obj/item/cloth/handkerchief/orange,
										/obj/item/cloth/handkerchief/green,
										/obj/item/cloth/handkerchief/blue)

/obj/item/cloth/handkerchief/random/New()
	..()
	var/obj/item/cloth/handkerchief/handkerchief_to_spawn = pick(possible_handkerchief)
	new handkerchief_to_spawn(src.loc)
	qdel(src)
