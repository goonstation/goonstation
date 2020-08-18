#define HAIR_1 1
#define HAIR_2 2
#define HAIR_3 3
#define ALL_HAIR 4
#define EYES 5
#define HAIR_1_FUCKED 1
#define HAIR_2_FUCKED 2
#define HAIR_3_FUCKED 4
#define EYES_FUCKED 8
#define BARBERY_FAILURE 0	// if barbering is not successful and does not display a message
#define BARBERY_SUCCESSFUL 1 // if barbering is successful, don't attack em
#define BARBERY_RESOLVABLE 2 // if barbering is not successful, but gives a message

/obj/item/clothing/head/wig
	name = "toupée"
	desc = "You can't tell the difference, Honest!"
	icon_state= "wig"

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
	flags = FPRINT | TABLEPASS | CONDUCT
	tool_flags = TOOL_SNIPPING
	force = 8.0
	w_class = 1.0
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	g_amt = 5000

	New()
		..()
		src.setItemSpecial(/datum/item_special/double) // should be doable even in barbermode
		AddComponent(/datum/component/transfer_on_attack)
		BLOCK_KNIFE

	attack(mob/M as mob, mob/user as mob)
		if(scissor_action(M, user))
			return
		else
			..()

	attack_self(mob/user)
		. = ..()
		toggle_force_use_as_tool(user, 0)

	dropped()
		. = ..()
		toggle_force_use_as_tool(null, 1, 1)

	throw_begin(atom/target)
		toggle_force_use_as_tool(null, 1, 1)
		return ..(target)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] slashes [his_or_her(user)] own throat with [src]!</b></span>")
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/obj/item/razor_blade
	name = "razor blade"
	desc = "Used to cut facial hair"
	icon = 'icons/obj/barber_shop.dmi'
	icon_state = "razorblade"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	tool_flags = TOOL_CUTTING
	force = 7.0
	w_class = 1.0
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	g_amt = 5000

	New()
		..()
		src.setItemSpecial(/datum/item_special/double) // should be doable even in barbermode
		BLOCK_KNIFE

	attack(mob/M as mob, mob/user as mob)
		if(razor_action(M, user))
			return
		else
			..()

	attack_self(mob/user)
		. = ..()
		toggle_force_use_as_tool(user, 0)

	dropped()
		toggle_force_use_as_tool(null, 1, 1)
		. = ..()

	throw_begin(atom/target)
		toggle_force_use_as_tool(null, 1, 1)
		return ..(target)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] slashes [his_or_her(user)] own throat with [src]!</b></span>")
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/obj/item/dye_bottle
	name = "hair dye bottle"
	desc = "Used to dye hair a different color. Seems to be made of tough, unshatterable plastic."
	icon = 'icons/obj/barber_shop.dmi'
	icon_state = "dye-e"
	flags = FPRINT | TABLEPASS
	//Default Colors
	var/customization_first_color = "#FFFFFF"
	uses_left = 3
	var/hair_group = 1

	attack(mob/M as mob, mob/user as mob)
		if(dye_hair(M, user, src))
			return
		else // I dunno, hit them with it?
			..()

	attack_self(mob/user)
		. = ..()
		src.hair_group = hair_group >= 5 ? 1 : hair_group + 1
		var/which_part
		switch (hair_group)
			if (HAIR_1)
				which_part = "first group of hair"
			if (HAIR_2)
				which_part = "middle group of hair"
			if (HAIR_3)
				which_part = "last group of hair"
			if (ALL_HAIR)
				which_part = "entire coiffure"
			if (EYES)
				which_part = "eyes"
		boutput(user, "<span class='hint'>You change your grip on the [src] to one that'll aim for the recipient's [which_part].</span>")

/obj/item/reagent_containers/food/drinks/hairgrowth
	name = "\improper EZ-Hairgrowth"
	desc = "The #1 hair growth product on the market! WARNING: Some side effects may occur."
	icon = 'icons/obj/barber_shop.dmi'
	icon_state = "tonic1"
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("hairgrownium", 40)

	on_reagent_change()
		src.icon_state = "tonic[src.reagents.total_volume ? "1" : "0"]"

/obj/stool/barber_chair //there shouldn't be any of these, here in case there's a secret map that has one, replace with /obj/stool/chair/comfy/barber_chair if you see one
	name = "You shouldn't see me!"
	desc = "You shouldn't be looking at this thing!"

/obj/stool/chair/comfy/barber_chair
	name = "barber chair"
	desc = "A special chair designed for haircutting. You don't feel like any other chair would be good enough, it HAS to be one like this. You don't know why."
	icon_state = "barberchair"
	anchored = 1
	arm_icon_state = "arm-barber"
	parts_type = /obj/item/furniture_parts/barber_chair

/obj/barber_pole
	name = "barber pole"
	icon = 'icons/obj/barber_shop.dmi'
	icon_state = "pole"
	density = 1
	anchored = 1
	desc = "Barber poles historically were signage used to convey that the barber would perform services such as blood letting and other medical procedures, with the red representing blood, and the white representing the bandaging. In America, long after the time when blood-letting was offered, a third colour was added to bring it in line with the colours of their national flag. This one is in space."


/obj/item/dye_bottle/proc/dye_hair(mob/living/carbon/human/M as mob, mob/user as mob, obj/item/dye_bottle/bottle as obj)
	if(!ishuman(M) || !user.mind)	return 0
	if(!istype(src, /obj/item/dye_bottle))
		boutput(user, "Hi! The thing you're using is trying to dye someone's hair, despite it not being a thing that's supposed to do that!")
		boutput(user, "Please call 1-800-CODER and tell us what's going on!")
		return 0
	if(src.uses_left <= 0)
		boutput(user, "<span class='alert'>\The [src] is empty!</span>")
		return 0
	if(!M?.organHolder?.head)
		boutput(user, "<span class='alert'>[M] has no head, and you're all out of stump dye!</span>")
		return 0
	else //if(istype(M.buckled, /obj/stool/chair/comfy/barber_chair))
		var/mob/living/carbon/human/H = M
		if(ishuman(M) && ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES)))
			// you can't stab someone in the eyes wearing a mask! - please do not stab people in the eyes with a dye bottle tia
			boutput(user, "<span class='hint'>You're going to need to remove that mask/helmet first.</span>")
			return 0
		var/result_msg1 = "[user] dyes [M]'s hair."
		var/result_msg2 = "<span class='notice'>You dye [M]'s hair.</span>"
		var/result_msg3 = "<span class='notice'>[user] dyes your hair.</span>"
		var/is_barber = user.mind.assigned_role == "Barber"
		var/passed_dye_roll = 1

		if(user.bioHolder.HasEffect("clumsy" && prob(40)))
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
				famtofuckup.bioHolder.mobAppearance.customization_first_color = bottle.customization_first_color
			if (recolor_these_hair_layers_instead & HAIR_2_FUCKED)
				famtofuckup.bioHolder.mobAppearance.customization_second_color = bottle.customization_first_color
			if (recolor_these_hair_layers_instead & HAIR_3_FUCKED)
				famtofuckup.bioHolder.mobAppearance.customization_third_color = bottle.customization_first_color
			if (recolor_these_hair_layers_instead & EYES_FUCKED)
				famtofuckup.bioHolder.mobAppearance.e_color = bottle.customization_first_color
				famtofuckup.emote("scream")
			boutput(user, "And now you're out of dye. Well done.")
			src.uses_left = 0
			src.icon_state= "dye-e"

		if(passed_dye_roll)
			switch(bottle.hair_group)
				if(HAIR_1)
					if(is_barber || prob(60))
						M.bioHolder.mobAppearance.customization_first_color = bottle.customization_first_color
					else
						boutput(M, "<span class='alert'>Oh no, you dyed the wrong thing!</span> Maybe they won't notice?")
						if(prob(50))
							M.bioHolder.mobAppearance.customization_second_color = bottle.customization_first_color
						else
							M.bioHolder.mobAppearance.customization_third_color = bottle.customization_first_color

				if(HAIR_2)
					if(is_barber || prob(60))
						M.bioHolder.mobAppearance.customization_second_color = bottle.customization_first_color
					else
						boutput(M, "<span class='alert'>Oh no, you dyed the wrong thing!</span> Maybe they won't notice?")
						if(prob(50))
							M.bioHolder.mobAppearance.customization_first_color = bottle.customization_first_color
						else
							M.bioHolder.mobAppearance.customization_third_color = bottle.customization_first_color

				if(HAIR_3)
					if(is_barber || prob(60))
						M.bioHolder.mobAppearance.customization_third_color = bottle.customization_first_color
					else
						boutput(M, "<span class='alert'>Oh no, you dyed the wrong thing!</span> Maybe they won't notice?")
						if(prob(50))
							M.bioHolder.mobAppearance.customization_second_color = bottle.customization_first_color
						else
							M.bioHolder.mobAppearance.customization_first_color = bottle.customization_first_color

				if(ALL_HAIR)
					if(src.uses_left < 3)
						boutput(M, "<span class='notice'>This dyejob's going to need a full bottle!</span>")
						return
					else
						M.bioHolder.mobAppearance.customization_first_color = bottle.customization_first_color
						M.bioHolder.mobAppearance.customization_second_color = bottle.customization_first_color
						M.bioHolder.mobAppearance.customization_third_color = bottle.customization_first_color

				if(EYES)
					M.bioHolder.mobAppearance.e_color = bottle.customization_first_color
					result_msg1 ="[user] dumps the [src] into [M]'s eyes!"
					result_msg2 ="<span class='notice'>You dump the [src] in [M]'s eyes.</span>"
					result_msg3 ="<span class='alert'>[user] dumps the [src] into your eyes!</span>"
					if(user.mind.assigned_role == "Barber")
						SPAWN_DBG(20)
							boutput(M, "Huh, that actually didn't hurt that much. What a great [pick("barber", "stylist", "bangmangler")]!")
					else
						M.emote("scream", 0)
						boutput(M, "<span class='alert'>IT BURNS!</span> But the pain fades quickly. Huh.")
			user.tri_message(result_msg1,\
												user, result_msg2,\
												M,result_msg3)
			if (bottle.hair_group == ALL_HAIR)
				boutput(user, "That was a big dyejob! It used the whole bottle!")
				src.uses_left = 0
				src.icon_state= "dye-e"
			else if(src.uses_left > 1 && is_barber && bottle.hair_group != ALL_HAIR)
				boutput(user, "Hey, there's still some dye left in the bottle! Looks about ")
				src.uses_left --
			else
				boutput(user, "You used the whole bottle!")
				src.uses_left = 0
				src.icon_state= "dye-e"

		M.set_face_icon_dirty()
		M.set_body_icon_dirty()
		M.update_clothing()
	return 1

//////////////////////////////
/////Dye Bottle Dispenser/////
//////////////////////////////
/obj/machinery/hair_dye_dispenser
	name = "Hair Dye Mixer 3000"
	desc = "Mixes hair dye for whatever color you want"
	icon = 'icons/obj/barber_shop.dmi'
	icon_state = "dyedispenser"
	density = 1
	anchored = 1.0
	mats = 15
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL

	var/obj/item/dye_bottle/bottle = null

	New()
		..()
		UnsubscribeProcess()

	ex_act(severity)
		switch(severity)
			if(1.0)
				//SN src = null
				qdel(src)
				return
			if(2.0)
				if (prob(50))
					//SN src = null
					qdel(src)
					return
			else
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
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(status & BROKEN)
			return
		src.add_dialog(user)

		var/dat = "<TT><B>Dye Bottle Dispenser Unit</B><BR><HR><BR>"

		if(src.bottle)
			dat += {"Dye Bottle Loaded: <A href='?src=\ref[src];eject=1'>(Eject)</A><BR><BR><BR>Dye Color:<BR>"}

			if(src.bottle.uses_left)
				dat += "<A href='?src=\ref[src];emptyb=1'>Empty Dye Bottle</A><BR>"
			else
				dat += {"<A href='?src=\ref[src];fillb=1'>Fill Dye Bottle</A>"}
		else
			dat += "No Dye Bottle Loaded<BR>"

		user.Browse(dat, "window=dye_dispenser")
		onclose(user, "dye_dispenser")
		return

	attackby(obj/item/W, mob/user as mob)
		if(istype(W, /obj/item/dye_bottle))
			if(src.bottle)
				boutput(user, "<span class='notice'>The dispenser already has a dye bottle in it.</span>")
			else
				boutput(user, "<span class='notice'>You insert the dye bottle into the dispenser.</span>")
				if(W)
					user.drop_item(W)
					W.set_loc(src)
					src.bottle = W
			return
		..()
		return


	Topic(href, href_list)
		if(status & BROKEN)
			return
		if(usr.stat || usr.restrained())
			return
		if (isAI(usr))
			boutput(usr, "<span class='alert'>You are unable to dispense anything, since the controls are physical levers which don't go through any other kind of input.</span>")
			return

		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))))
			src.add_dialog(usr)

			if (href_list["eject"])
				if(src.bottle)
					src.bottle.set_loc(src.loc)
					usr.put_in_hand_or_eject(src.bottle) // try to eject it into the users hand, if we can
					src.bottle = null

			if(href_list["fillb"])
				if(src.bottle)
					var/new_dye = input(usr, "Please select hair color.", "Dye Color") as color
					if(new_dye)
						bottle.customization_first_color = new_dye
						bottle.uses_left = 3
						bottle.icon_state = "dye-f"
					src.updateDialog()
			if(href_list["emptyb"])
				if(src.bottle)
					bottle.uses_left = 0
					bottle.icon_state = "dye-e"
				src.updateDialog()

			src.add_fingerprint(usr)
			for(var/mob/M in viewers(1, src))
				if (M.using_dialog_of(src))
					src.attack_hand(M)
		else
			usr.Browse(null, "window=dye_dispenser")
			return
		return


// Barber stuff
/obj/item/scissors/proc/scissor_action(mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)
	if (src.remove_bandage(M, user))
		return 1
	if (snip_surgery(M, user))
		return 1
	var/cut_result = do_haircut(M, user)
	if (cut_result == BARBERY_SUCCESSFUL)
		return 1
	if (src.force_use_as_tool || (user.a_intent == INTENT_HELP && (istype(M.buckled, /obj/stool/chair/comfy/barber_chair) || istype(get_area(M), /area/station/crew_quarters/barber_shop))))
		if (cut_result == BARBERY_FAILURE) // failure doesnt return a message, less-than-successes do
			boutput(user, "<span class='notice'>You poke [M] with your [src]. If you want to attack [M], you'll need to remove [him_or_her(M)] from the barber shop or set your intent to anything other than 'help', first.</span>")
		return 1
	if (src.reagents && src.reagents.total_volume)//ugly but this is the sanest way I can see to make the surgical use 'ignore' armor
		src.reagents.trans_to(M,5)
		logTheThing("combat", user, M, "used [src] on [constructTarget(M,"combat")] (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>) [log_reagents(src)]")
	return


/obj/item/razor_blade/proc/razor_action(mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)
	if (scalpel_surgery(M, user))
		return 1
	var/shave_result = do_shave(M, user)
	if (shave_result == BARBERY_SUCCESSFUL)
		return 1
	if (src.force_use_as_tool || (user.a_intent == INTENT_HELP && (istype(M.buckled, /obj/stool/chair/comfy/barber_chair) || istype(get_area(M), /area/station/crew_quarters/barber_shop))))
		if (shave_result == BARBERY_FAILURE) // failure doesnt return a message, less-than-successes do
			boutput(user, "<span class='notice'>You poke [M] with your [src]. If you want to attack [M], you'll need to remove [him_or_her(M)] from the barber shop or set your intent to anything other than 'help', first.</span>")
		return 1
	if (src.reagents && src.reagents.total_volume)//ugly but this is the sanest way I can see to make the surgical use 'ignore' armor
		src.reagents.trans_to(M,5)
		logTheThing("combat", user, M, "used [src] on [constructTarget(M,"combat")] (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>) [log_reagents(src)]")
	return

/obj/item/proc/do_shave(mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)
	if(!M || !user || (user.a_intent != INTENT_HELP && !src.force_use_as_tool))
		return BARBERY_FAILURE // Who's cutting whose hair, now?

	var/mob/living/carbon/human/H = M
	if(ishuman(M) && ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES) || (H.glasses && H.glasses.c_flags & COVERSEYES)))
		// you can't stab someone in the eyes wearing a mask!
		boutput(user, "<span class='notice'>You're going to need to remove that mask/helmet/glasses first.</span>")
		return BARBERY_RESOLVABLE

	if(M.bioHolder.mobAppearance.customization_second == "None")
		boutput(user, "<span class='alert'>You can't get a closer shave than that!</span>")
		return BARBERY_RESOLVABLE

	if(issilicon(M))
		boutput(user, "<span class='alert'>Shave a robot? Shave a robot!?? SHAVE A ROBOT?!?!??</span>")
		return BARBERY_RESOLVABLE

	if(!ishuman(M))
		boutput(user, "You don't know how to shave that! At least without cutting its face off.")
		return BARBERY_RESOLVABLE

	if(iswizard(M))
		if (user == M)
			boutput(user, "<span style='font-size: 1.5em; font-weight:bold; color:red'>And just what do you think you're doing?</span>\
							<br>It took you <span class='alert'>years</span> to grow that <span style='font-family: Dancing Script, cursive;'>majestic</span> thing!\
							<br>To even <span style='font-family: Dancing Script, cursive;'>fathom</span> an existence without it fills the [voidSpeak("void")] where your soul used to be with <span class='alert'>RAGE.</span>")
			return BARBERY_RESOLVABLE
		src.visible_message("<span class='alert'><b>[user]</b> quickly shaves off [M]'s beard!</span>")
		M.bioHolder.AddEffect("arcane_shame", timeleft = 120)
		M.bioHolder.mobAppearance.customization_second = "None"
		M.cust_two_state = "None"
		M.set_face_icon_dirty()
		M.emote("cry")
		M.emote("scream")
		return BARBERY_SUCCESSFUL


	if(!mutant_barber_fluff(M, user, "shave"))
		return BARBERY_RESOLVABLE
	var/list/mustaches =list("Watson", "Chaplin", "Selleck", "Van Dyke", "Hogan")
	var/list/beards  = list("Neckbeard", "Elvis", "Abe", "Chinstrap", "Hipster", "Wizard")
	var/list/full = list("Goatee", "Full Beard", "Long Beard")
	var/new_style = input(user, "Please select facial style", "Facial Style")  as null|anything in mustaches + beards + full
	if (new_style)

		if((new_style in full) && (!(M.bioHolder.mobAppearance.customization_second in full)))
			boutput(user, "<span class='alert'>[M] doesn't have enough facial hair!</span>")
			return BARBERY_RESOLVABLE

		if((new_style in beards) && (M.bioHolder.mobAppearance.customization_second in mustaches))
			boutput(user, "<span class='alert'>[M] doesn't have a beard!</span>")
			return BARBERY_RESOLVABLE

		if((new_style in mustaches) && (M.bioHolder.mobAppearance.customization_second in beards))
			boutput(user, "<span class='alert'>[M] doesn't have a mustache!</span>")
			return BARBERY_RESOLVABLE
	else
		boutput(user, "Never mind.")
		return BARBERY_SUCCESSFUL

	actions.start(new/datum/action/bar/shave(M, user, get_barbery_conditions(M, user), new_style), user)
	return BARBERY_SUCCESSFUL

/obj/item/proc/do_haircut(mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)
	if(!M || !user || (user.a_intent != INTENT_HELP && !src.force_use_as_tool))
		return BARBERY_FAILURE // Who's cutting whose hair, now?

	var/mob/living/carbon/human/H = M
	if(ishuman(M) && ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES) || (H.glasses && H.glasses.c_flags & COVERSEYES)))
		// you can't stab someone in the eyes wearing a mask!
		boutput(user, "<span class='notice'>You're going to need to remove that mask/helmet/glasses first.</span>")
		return BARBERY_RESOLVABLE

	if(M.bioHolder.mobAppearance.customization_first == "None")
		boutput(user, "<span class='alert'>There is nothing to cut!</span>")
		return BARBERY_RESOLVABLE

	if(!mutant_barber_fluff(M, user, "haircut"))
		return BARBERY_SUCCESSFUL

	var/new_style = input(user, "Please select style", "Style")  as null|anything in customization_styles + customization_styles_gimmick

	if (new_style)
		if(M.bioHolder.mobAppearance.customization_first == "Balding" && new_style != "None")
			boutput(user, "<span class='alert'>Not enough hair!</span>")
			return BARBERY_SUCCESSFUL

	if(!new_style)
		boutput(user, "Never mind.")
		return BARBERY_SUCCESSFUL

	actions.start(new/datum/action/bar/haircut(M, user, get_barbery_conditions(M, user), new_style), user)
	return BARBERY_SUCCESSFUL

/proc/get_barbery_conditions(mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)
	if(!ishuman(M))
		return 0 // shouldn't happen, but just in case someone manages to shave a rat or something
	var/barbery_conditions = 0
	// let's see how ideal the haircutting conditions are
	if(M.stat || issilicon(user))
		return 100
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

/obj/item/proc/mutant_barber_fluff(mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob, var/barbery_type)
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
	else if(!M.mutantrace)
		return 1 // is human, not mutant, should be fine
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
			if("reliquary_soldier")
				if(barbery_type == "haircut")
					playsound(M, "sound/items/Scissor.ogg", 100, 1)
				user.tri_message("[user] waves [his_or_her(user)] [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s head, snipping at nothing!",\
											M, "[user] [barbery_type == "haircut" ? "snips" : "cuts"] at something around your head.",\
									 user, "You wave your [barbery_type == "haircut" ? "scissors" : "razor"] around [M]'s robot cyborg mechanical metal... head?")
				return 0
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

// this proc is supposed to make certain tools less accidentally deadly for inexperienced players to use
// when force_use_as_tool is set, all intents will try to do their tool-thing, and if it can't, return a message saying they're using it wrong
// if not set, help intent will still attempt tool, but you'll shank them if it doesn't work out
/obj/item/proc/toggle_force_use_as_tool(mob/user, var/be_quiet = 1, var/quiet_reset)
	if(quiet_reset)
		src.force_use_as_tool = 0
		src.dir = SOUTH
		return
	src.force_use_as_tool = !src.force_use_as_tool
	if (src.force_use_as_tool)
		src.dir = WEST
	else
		src.dir = SOUTH
	if(be_quiet || !user)
		return

	var/list/cool_grip_adj = list("a sick", "a wicked", "a deadly", "a menacing", "an edgy", "a tacticool", "a sweaty", "an awkward")
	var/list/cool_grip1 = list("combat", "fightlord", "guerilla", "hidden", "space", "syndie", "double-reverse", "\"triple-dog-dare-ya\"", "stain-buster's")
	var/list/cool_grip2a = list("blade", "cyber", "street", "assistant", "comedy", "butcher", "edge", "beast", "heck", "crud", "ass")
	var/list/cool_grip2b = list("master", "slayer", "fighter", "militia", "space", "syndie", "lord", "blaster", "beef", "tyrannosaurus")
	var/list/wheredWeSeeIt = list("saw the clown do", "saw the captain do", "saw the head of security do",\
														"saw someone in a red spacesuit do", "saw a floating saw do", "saw on TV",\
														"saw one of the diner dudes do", "saw just about every assistant do")
	var/cool_grip3 = "[pick(wheredWeSeeIt)] [pick("once", "once or twice")]"

	if(src.force_use_as_tool)
		user.visible_message("[user] assumes a less hostile grip on the [src].",\
													"You change your grip on the [src], so as to use it more as a tool than a weapon.")
	else
		user.visible_message("[user] wields the [src] a with [pick(cool_grip_adj)] [pick(cool_grip1)] [pick(cool_grip2a)][pick(cool_grip2b)] [pick("style", "grip")] that they probably [pick(cool_grip3)]!",\
													"You wield the [src] with [pick(cool_grip_adj)] [pick(cool_grip1)] [pick(cool_grip2a)][pick(cool_grip2b)] [pick("style", "grip")] that you [pick(cool_grip3)]! It makes it just about impossible to use as a tool!")
/datum/action/bar/haircut
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "haircut"
	var/mob/living/carbon/human/M
	var/mob/living/carbon/human/user
	var/degree_of_success
	var/new_style


	New(var/mob/living/carbon/human/barbee, var/mob/living/carbon/human/barber, var/succ, var/nustyle)
		M = barbee
		user = barber
		degree_of_success = succ
		new_style = nustyle
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
				var/obj/item/I = M.create_wig()
				I.set_loc(M.loc)
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
					var/obj/item/I = M.create_wig()
					I.set_loc(user.loc)
				else
					user.tri_message("[user] cuts [M]'s hair.",\
					M, "<span class='notice'>[user] cuts your hair.</span>",\
					user, "<span class='notice'>You cut [M]'s hair.</span>")
					M.cust_one_state = customization_styles[new_style] || customization_styles_gimmick[new_style]
					M.bioHolder.mobAppearance.customization_first = new_style

		M.set_clothing_icon_dirty() // why the fuck is hair updated in clothing
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

	New(var/mob/living/carbon/human/barbee, var/mob/living/carbon/human/barber, var/succ, var/nustyle)
		M = barbee
		user = barber
		degree_of_success = succ
		new_style = nustyle
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
				var/obj/item/I = M.create_wig()
				I.set_loc(M.loc)
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
				M.cust_two_state = customization_styles[new_style] || customization_styles_gimmick[new_style]
				M.bioHolder.mobAppearance.customization_first = new_style
		M.set_clothing_icon_dirty() // why the fuck is hair updated in clothing
		..()

	onInterrupt()
		boutput(owner, "You were interrupted!")
		..()

#undef HAIR_1
#undef HAIR_2
#undef HAIR_3
#undef ALL_HAIR
#undef EYES
#undef HAIR_1_FUCKED
#undef HAIR_2_FUCKED
#undef HAIR_3_FUCKED
#undef EYES_FUCKED
#undef BARBERY_FAILURE
#undef BARBERY_SUCCESSFUL
#undef BARBERY_RESOLVABLE
