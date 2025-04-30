#define HAIRCUT 1
#define SHAVE 2

// hairea options
#define BOTTOM_DETAIL 1
#define MIDDLE_DETAIL 2
#define TOP_DETAIL 3
#define ALL_HAIR 4
#define EYES 5

#define HAIR_1_FUCKED 1
#define HAIR_2_FUCKED 2
#define HAIR_3_FUCKED 4
#define EYES_FUCKED 8

/obj/item/clothing/head/wig
	name = "toupée"
	desc = "You can't tell the difference, Honest!"
	icon_state= "wig"
	wear_layer = MOB_HAIR_LAYER2 //it IS hair afterall
	hat_offset_y = -15 // offsets for hattable component
	hat_offset_x = 0
	compatible_species = list("human", "cow", "werewolf", "flubber") // No wigs for martians / blobs

	///Takes a list of style ids to colors and generates a wig from it
	proc/setup_wig(var/style_list)
		if (!style_list)
			return
		var/actuallyHasHair = FALSE
		for (var/style_id in style_list)
			if (style_id == "none")
				continue
			var/image/h_image = image('icons/mob/human_hair.dmi', style_id) //  aloe TODO make these work with unlockable hair
			h_image.color = style_list[style_id]
			src.overlays += h_image
			src.wear_image.overlays += h_image
			actuallyHasHair = TRUE
		if (!actuallyHasHair)
			src.icon_state = "short"

///A type to allow you to spawn custom wigs from the map editor
/obj/item/clothing/head/wig/spawnable
	icon = 'icons/mob/human_hair.dmi'
	icon_state = "bald"
	var/first_id = "none"
	var/first_color = "#101010"
	var/second_id = "none"
	var/second_color = "#101010"
	var/third_id = "none"
	var/third_color = "#101010"

	New()
		..()
		var/hair_list = list()
		hair_list[first_id] = first_color
		hair_list[second_id] = second_color
		hair_list[third_id] = third_color
		src.setup_wig(hair_list)

///Randomized wig for the cargo crate
/obj/item/clothing/head/wig/spawnable/random

	New()
		src.name = "wig"
		var/list/possible_hairstyles

		if (prob(50))
			possible_hairstyles = pick(get_available_custom_style_types(filter_gender=FEMININE))
		else
			possible_hairstyles = pick(get_available_custom_style_types(filter_gender=MASCULINE))

		var/datum/customization_style/hair_type
		var/picked_color = rgb(rand(0,255),rand(0,255),rand(0,255))
		hair_type = pick(possible_hairstyles)
		first_id = initial(hair_type.id)
		first_color = picked_color
		if (prob(33))
			hair_type = pick(possible_hairstyles)
			second_id = initial(hair_type.id)
			second_color = picked_color
		..()

/obj/item/clothing/head/bald_cap
	name = "bald cap"
	desc = "You can't tell the difference, Honest!"
	icon_state = "baldcap"
	item_state = "baldcap"
	seal_hair = 1

/obj/item/scissors
	name = "scissors"
	desc = "Used to cut hair. Make sure you aim at the head, where the hair is."
	icon = 'icons/obj/barber_shop.dmi'
	icon_state = "scissors"
	flags = TABLEPASS | CONDUCT
	object_flags = NO_GHOSTCRITTER
	tool_flags = TOOL_SNIPPING
	force = 8
	health = 6
	w_class = W_CLASS_TINY
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	g_amt = 5000

	New()
		..()
		src.setItemSpecial(/datum/item_special/double) // should be doable even in barbermode
		AddComponent(/datum/component/barber/haircut)
		AddComponent(/datum/component/toggle_tool_use)
		BLOCK_SETUP(BLOCK_KNIFE)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (is_special)
			return ..()
		if (src.remove_bandage(target, user))
			return 1
		if (snip_surgery(target, user))
			return 1
		..()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] slashes [his_or_her(user)] own throat with [src]!</b>"))
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/obj/item/razor_blade
	name = "razor blade"
	desc = "Used to cut facial hair"
	icon = 'icons/obj/barber_shop.dmi'
	icon_state = "razorblade"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	object_flags = NO_GHOSTCRITTER
	tool_flags = TOOL_CUTTING
	force = 7
	health = 6
	w_class = W_CLASS_TINY
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	g_amt = 5000

	New()
		..()
		src.setItemSpecial(/datum/item_special/double) // should be doable even in barbermode
		AddComponent(/datum/component/barber/shave)
		AddComponent(/datum/component/toggle_tool_use)
		BLOCK_SETUP(BLOCK_KNIFE)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (is_special)
			return ..()
		if (scalpel_surgery(target, user))
			return 1
		..()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] slashes [his_or_her(user)] own throat with [src]!</b>"))
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/obj/item/razor_blade/barberang
	desc = "Used to cut facial hair. This one seems sharper than normal."
	force = 12
	throwforce = 20
	throw_range = 10
	throw_speed = 1
	throw_return = 1
	var/obj/item/clothing/head/wig/stolen_hair

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if( ishuman(thr.user))
			var/mob/living/carbon/human/user = thr.user
			if(hit_atom == user)
				user.put_in_hand_or_drop(src)
				if(stolen_hair)
					var/obj/item/clothing/head/wig/I = stolen_hair
					user.put_in_hand_or_drop(I)
					stolen_hair = null

				return
			else if (ishuman(hit_atom))
				var/mob/living/carbon/human/victim = hit_atom
				playsound(src, 'sound/impact_sounds/Flesh_Stab_3.ogg', 50)
				var/yoinked = FALSE
				if(!stolen_hair)
					if(istype(victim.head, /obj/item/clothing/head/wig))
						//they are wearing a wig
						stolen_hair = victim.head
						victim.u_equip(stolen_hair)
						boutput(victim, SPAN_ALERT("the [src] snatches your wig right off your head!"))
						yoinked = TRUE
					else if(!victim.is_bald())
						//they have hair to yoink
						spawn_hair_clipping(victim, victim.bioHolder.mobAppearance.customizations["hair_bottom"].color, victim.bioHolder.mobAppearance.customizations["hair_bottom"].style)
						spawn_hair_clipping(victim, victim.bioHolder.mobAppearance.customizations["hair_middle"].color, victim.bioHolder.mobAppearance.customizations["hair_middle"].style)
						spawn_hair_clipping(victim, victim.bioHolder.mobAppearance.customizations["hair_top"].color, victim.bioHolder.mobAppearance.customizations["hair_top"].style)
						stolen_hair = victim.create_wig()
						boutput(victim, SPAN_ALERT("the [src] takes your hair clean off!"))
						yoinked = TRUE
				if(yoinked)
					victim.changeStatus("knockdown", 4 SECONDS)
					victim.force_laydown_standup()
				else
					boutput(victim, SPAN_ALERT("the [src] slashes your head really bad!"))
					take_bleeding_damage(victim, user, throwforce)
					throw_return = FALSE
					SPAWN(2 SECONDS)
						throw_return = TRUE

		. = ..()

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

/obj/item/dye_bottle
	name = "hair dye bottle"
	desc = "Used to dye hair a different color. Seems to be made of tough, unshatterable plastic."
	icon = 'icons/obj/barber_shop.dmi'
	icon_state = "dye"
	flags = TABLEPASS
	//Default Colors
	var/customization_first_color = "#FFFFFF"
	var/uses_left
	var/hair_group = ALL_HAIR
	var/image/dye_image

	New()
		dye_image = image(src.icon, "dye_color", -1)
		..()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(dye_hair(target, user, src))
			return
		else // I dunno, hit them with it?
			..()

	attack_self(mob/user)
		. = ..()
		src.hair_group = hair_group >= 5 ? 1 : hair_group + 1
		var/which_part
		switch (hair_group)
			if (BOTTOM_DETAIL)
				which_part = "bottom group of hair"
			if (MIDDLE_DETAIL)
				which_part = "middle group of hair"
			if (TOP_DETAIL)
				which_part = "top group of hair"
			if (ALL_HAIR)
				which_part = "entire coiffure"
			if (EYES)
				which_part = "eyes"
		boutput(user, SPAN_HINT("You change your grip on the [src] to one that'll aim for the recipient's [which_part]."))

	proc/use_dye(all = FALSE)
		if (all)
			src.uses_left = 0
		else
			src.uses_left--
		if (src.uses_left <= 0)
			src.ClearSpecificOverlays("dye_color")

/obj/item/reagent_containers/food/drinks/hairgrowth
	name = "\improper EZ-Hairgrowth"
	desc = "The #1 hair growth product on the market! WARNING: Some side effects may occur."
	icon = 'icons/obj/barber_shop.dmi'
	icon_state = "tonic1"
	initial_volume = 50
	New()
		..()
		reagents.add_reagent("hairgrownium", 40)

	on_reagent_change()
		..()
		src.icon_state = "tonic[src.reagents.total_volume ? "1" : "0"]"

/obj/stool/barber_chair //there shouldn't be any of these, here in case there's a secret map that has one, replace with /obj/stool/chair/comfy/barber_chair if you see one
	name = "You shouldn't see me!"
	desc = "You shouldn't be looking at this thing!"

/obj/stool/chair/comfy/barber_chair
	name = "barber chair"
	desc = "A special chair designed for haircutting. You don't feel like any other chair would be good enough, it HAS to be one like this. You don't know why."
	icon_state = "barberchair"
	anchored = ANCHORED
	arm_icon_state = "arm-barber"
	parts_type = /obj/item/furniture_parts/barber_chair

/obj/barber_pole
	name = "barber pole"
	icon = 'icons/obj/barber_shop.dmi'
	icon_state = "pole"
	density = 1
	anchored = ANCHORED
	desc = "Barber poles historically were signage used to convey that the barber would perform services such as blood letting and other medical procedures, with the red representing blood, and the white representing the bandaging. In America, long after the time when blood-letting was offered, a third colour was added to bring it in line with the colours of their national flag. This one is in space."


/obj/item/dye_bottle/proc/dye_hair(mob/living/carbon/human/M as mob, mob/user as mob, obj/item/dye_bottle/bottle as obj)
	if(!ishuman(M) || !user.mind)	return 0
	if(!istype(src, /obj/item/dye_bottle))
		boutput(user, "Hi! The thing you're using is trying to dye someone's hair, despite it not being a thing that's supposed to do that!")
		boutput(user, "Please call 1-800-CODER and tell us what's going on!")
		return 0
	if(src.uses_left <= 0)
		boutput(user, SPAN_ALERT("\The [src] is empty!"))
		return 0
	if(!M?.organHolder?.head)
		boutput(user, SPAN_ALERT("[M] has no head, and you're all out of stump dye!"))
		return 0
	else //if(istype(M.buckled, /obj/stool/chair/comfy/barber_chair))
		var/mob/living/carbon/human/H = M
		if(ishuman(M) && ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES)))
			// you can't stab someone in the eyes wearing a mask! - please do not stab people in the eyes with a dye bottle tia
			boutput(user, SPAN_HINT("You're going to need to remove that mask/helmet first."))
			return 0
		var/result_msg1 = "[user] dyes [M]'s hair."
		var/result_msg2 = SPAN_NOTICE("You dye [M]'s hair.")
		var/result_msg3 = SPAN_NOTICE("[user] dyes your hair.")
		var/is_barber = user.mind.assigned_role == "Barber"
		var/passed_dye_roll = 1

		if(user.bioHolder.HasEffect("clumsy") && prob(40))
			var/recolor_these_hair_layers_instead = 0
			var/mob/living/carbon/human/famtofuckup = null
			passed_dye_roll = 0
			if(prob(33))
				recolor_these_hair_layers_instead |= HAIR_1_FUCKED
			if(prob(33))
				recolor_these_hair_layers_instead |= HAIR_2_FUCKED
			if(prob(33))
				recolor_these_hair_layers_instead |= HAIR_3_FUCKED
			if(prob(33))
				recolor_these_hair_layers_instead |= EYES_FUCKED
			if (ishuman(user) && prob(50)) // dye your own hair, idiot
				user.visible_message("[user] slips and dumps the [src] onto [his_or_her(user)] own head!")
				famtofuckup = user
			else // dye their hair, idiot
				user.visible_message("[user] slips and dumps the [src] all over [M]'s head!")
				famtofuckup = M
			if (recolor_these_hair_layers_instead & HAIR_1_FUCKED)
				famtofuckup.bioHolder.mobAppearance.customizations["hair_bottom"].color = bottle.customization_first_color
			if (recolor_these_hair_layers_instead & HAIR_2_FUCKED)
				famtofuckup.bioHolder.mobAppearance.customizations["hair_middle"].color = bottle.customization_first_color
			if (recolor_these_hair_layers_instead & HAIR_3_FUCKED)
				famtofuckup.bioHolder.mobAppearance.customizations["hair_top"].color = bottle.customization_first_color
			if (recolor_these_hair_layers_instead & EYES_FUCKED)
				famtofuckup.bioHolder.mobAppearance.e_color = bottle.customization_first_color
				famtofuckup.emote("scream")
			boutput(user, "And now you're out of dye. Well done.")
			src.uses_left = 0
			src.ClearSpecificOverlays("dye_color")

		if(passed_dye_roll)
			switch(bottle.hair_group)
				if(BOTTOM_DETAIL, MIDDLE_DETAIL, TOP_DETAIL)
					if(!is_barber && prob(25))
						boutput(M, "[SPAN_ALERT("Oh no, you dyed the wrong thing!")] Maybe they won't notice?")
						bottle.hair_group = pick(list(BOTTOM_DETAIL, MIDDLE_DETAIL, TOP_DETAIL) - bottle.hair_group)
					switch(bottle.hair_group)
						if(BOTTOM_DETAIL)
							M.bioHolder.mobAppearance.customizations["hair_bottom"].color = bottle.customization_first_color
						if(MIDDLE_DETAIL)
							M.bioHolder.mobAppearance.customizations["hair_middle"].color = bottle.customization_first_color
						if(TOP_DETAIL)
							M.bioHolder.mobAppearance.customizations["hair_top"].color = bottle.customization_first_color
				if(ALL_HAIR)
					if(src.uses_left < 3)
						boutput(M, SPAN_NOTICE("This dyejob's going to need a full bottle!"))
						return
					else
						M.bioHolder.mobAppearance.customizations["hair_bottom"].color = bottle.customization_first_color
						M.bioHolder.mobAppearance.customizations["hair_middle"].color = bottle.customization_first_color
						M.bioHolder.mobAppearance.customizations["hair_top"].color = bottle.customization_first_color

				if(EYES)
					M.bioHolder.mobAppearance.e_color = bottle.customization_first_color
					result_msg1 ="[user] dumps the [src] into [M]'s eyes!"
					result_msg2 =SPAN_NOTICE("You dump the [src] in [M]'s eyes.")
					result_msg3 =SPAN_ALERT("[user] dumps the [src] into your eyes!")
					if(user.mind.assigned_role == "Barber")
						SPAWN(2 SECONDS)
							boutput(M, "Huh, that actually didn't hurt that much. What a great [pick("barber", "stylist", "bangmangler")]!")
					else
						M.emote("scream", 0)
						boutput(M, "[SPAN_ALERT("IT BURNS!")] But the pain fades quickly. Huh.")
			user.tri_message(M, result_msg1,\
												result_msg2,\
												result_msg3)
			if (bottle.hair_group == ALL_HAIR)
				boutput(user, "That was a big dyejob! It used the whole bottle!")
				src.use_dye(TRUE)
			else if(src.uses_left > 1 && is_barber && bottle.hair_group != ALL_HAIR)
				src.use_dye()
				boutput(user, "Hey, there's still some dye left in the bottle! Looks about [get_english_num(src.uses_left)] third\s full!")
			else
				boutput(user, "You used the whole bottle!")
				src.use_dye()

		M.update_colorful_parts()
	return 1

//////////////////////////////
/////Dye Bottle Dispenser/////
//////////////////////////////
TYPEINFO(/obj/machinery/hair_dye_dispenser)
	mats = 15

/obj/machinery/hair_dye_dispenser
	name = "Hair Dye Mixer 3000"
	desc = "Mixes hair dye for whatever color you want"
	icon = 'icons/obj/barber_shop.dmi'
	icon_state = "dyedispenser"
	density = 1
	anchored = ANCHORED
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL

	var/obj/item/dye_bottle/bottle = null

	New()
		..()
		UnsubscribeProcess()

	ex_act(severity)
		switch(severity)
			if(1)
				qdel(src)
				return
			if(2)
				if (prob(50))
					qdel(src)
					return

	blob_act(var/power)
		if (prob(power * 1.25))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	process()
		return

	attack_ai(mob/user as mob)
		return src.Attackhand(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "DyeDispenser", name)
			ui.open()

	ui_data(mob/user)
		. = list()
		.["bottle"] = !!src.bottle
		.["uses_left"] = src.bottle?.uses_left
		.["bottle_color"] = src.bottle?.customization_first_color

	attack_hand(mob/user)
		if(status & BROKEN)
			return

		ui_interact(user)

	attackby(obj/item/I, mob/user as mob)
		if(istype(I, /obj/item/dye_bottle))
			insert_bottle(I, user)
			tgui_process.update_uis(src)
			return
		..()

	proc/insert_bottle(obj/item/dye_bottle/bottle, mob/user)
		if(src.bottle)
			boutput(user, SPAN_NOTICE("The dispenser already has a dye bottle in it."))
		else
			boutput(user, SPAN_NOTICE("You insert the dye bottle into the dispenser."))
			if(bottle)
				user.drop_item(bottle)
				bottle.set_loc(src)
				src.bottle = bottle

	ui_act(action, params)
		. = ..()
		if(status & BROKEN)
			return
		if(usr.stat || usr.restrained())
			return
		if (isAI(usr))
			boutput(usr, SPAN_ALERT("You are unable to dispense anything, since the controls are physical levers which don't go through any other kind of input."))
			return

		if ((usr.contents.Find(src) || ((BOUNDS_DIST(src, usr) == 0) && istype(src.loc, /turf))))
			switch(action)
				if ("eject")
					if(src.bottle)
						src.bottle.set_loc(src.loc)
						usr.put_in_hand_or_eject(src.bottle) // try to eject it into the users hand, if we can
						src.bottle = null

				if("fillb")
					if(src.bottle)
						bottle.customization_first_color = params["selectedColor"]
						bottle.uses_left = 3
						bottle.dye_image.color = bottle.customization_first_color
						bottle.UpdateOverlays(bottle.dye_image, "dye_color")

				if("emptyb")
					if(src.bottle)
						bottle.uses_left = 0
						bottle.customization_first_color = initial(bottle.customization_first_color)
						bottle.ClearSpecificOverlays("dye_color")

				if("insertb")
					var/obj/item/I = usr.equipped()
					if(istype(I, /obj/item/dye_bottle))
						insert_bottle(I, usr)

			. = TRUE


// Barber stuff

#undef BOTTOM_DETAIL
#undef MIDDLE_DETAIL
#undef TOP_DETAIL
#undef ALL_HAIR
#undef EYES
#undef HAIR_1_FUCKED
#undef HAIR_2_FUCKED
#undef HAIR_3_FUCKED
#undef EYES_FUCKED
#undef HAIRCUT
#undef SHAVE
