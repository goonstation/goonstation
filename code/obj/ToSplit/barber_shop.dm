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
	force = 6.0
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
		src.setItemSpecial(/datum/item_special/double)
		AddComponent(/datum/component/transfer_on_attack)
		BLOCK_KNIFE

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
		src.setItemSpecial(/datum/item_special/double)
		BLOCK_KNIFE

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
	var/empty = 1

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

///////////////////////////////////////////////////
//////Hair Dye Bottle Code					///////
///////////////////////////////////////////////////
/obj/item/dye_bottle/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	if(!ishuman(M))	return
	if(user.zone_sel.selecting != "head" || user.a_intent != "help")
		..()
		return
	if(src.empty)
		boutput(user, "<span class='alert'>\The [src] is empty!</span>")
	else //if(istype(M.buckled, /obj/stool/chair/comfy/barber_chair))
		var/mob/living/carbon/human/H = M
		if(ishuman(M) && ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES)))
			// you can't stab someone in the eyes wearing a mask! - please do not stab people in the eyes with a dye bottle tia
			boutput(user, "<span class='hint'>You're going to need to remove that mask/helmet first.</span>")
			return
		/*
		var/turf/T = M.loc
		var/turf/TM = user.loc
		boutput(user, "<span class='notice'>You begin dying [M]'s hair.</span>")
		boutput(M, "<span class='notice'>[user] begins dying your hair.</span>")
		sleep(3 SECONDS)
		if(M.loc == T && TM.loc == user.loc  && (user.equipped() == src || issilicon(user)))
			return
		*/
		user.tri_message("[user] dyes [M]'s hair.",\
		user, "<span class='notice'>You dye [M]'s hair.</span>",\
		M, "<span class='notice'>[user] dyes your hair.</span>")
		M.bioHolder.mobAppearance.customization_first_color = src.customization_first_color
		M.bioHolder.mobAppearance.customization_second_color = src.customization_first_color
		M.set_face_icon_dirty()
		M.set_body_icon_dirty()
		M.update_clothing()
		src.empty = 1
		src.icon_state= "dye-e"
	//else
	//	boutput(user, "<span class='alert'>They need to be in a barber chair!</span>")

/////////////////////////////////////////////////////
//////Scissors Code								/////
////////////////////////////////////////////////////
/obj/item/scissors/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	if (src.remove_bandage(M, user))
		return

	//If the haircut
	if (do_haircut(M, user))
		return

	if (src.reagents && src.reagents.total_volume)
		logTheThing("combat", user, M, "used [src] on %target% (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>) [log_reagents(src)]")
	else
		logTheThing("combat", user, M, "used [src] on %target% (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>)")

	if (!snip_surgery(M, user))
		return ..()
	else
		if (src.reagents && src.reagents.total_volume)//ugly but this is the sanest way I can see to make the surgical use 'ignore' armor
			src.reagents.trans_to(M,5)
		return


//should really be moved to progressbar but w/e
// returns true on success, false on failure
/obj/item/scissors/proc/do_haircut(mob/living/carbon/human/M as mob, mob/user as mob)
	if(user.zone_sel.selecting != "head" || user.a_intent != "help")
		return 0

	if (user == M)
		boutput(user, "<span class='alert'>You can't cut your own hair!</span>")
		return 0
	if(istype(M.buckled, /obj/stool/chair/comfy/barber_chair))

		var/mob/living/carbon/human/H = M
		if(ishuman(M) && ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES) || (H.glasses && H.glasses.c_flags & COVERSEYES)))
			// you can't stab someone in the eyes wearing a mask!
			boutput(user, "<span class='notice'>You're going to need to remove that mask/helmet/glasses first.</span>")
			return 0

		if(M.bioHolder.mobAppearance.customization_first == "None")
			boutput(user, "<span class='alert'>There is nothing to cut!</span>")
			return 0

		var/new_style = input(user, "Please select style", "Style")  as null|anything in customization_styles + customization_styles_gimmick

		if (new_style)
			if(M.bioHolder.mobAppearance.customization_first == "Balding" && new_style != "None")
				boutput(user, "<span class='alert'>Not enough hair!</span>")
				return 0

		if(!new_style)
			return 0

		var/turf/T = M.loc
		var/turf/TM = user.loc
		user.tri_message("[user] begins cutting [M]'s hair.",\
		user, "<span class='notice'>You begin cutting [M]'s hair.</span>",\
		M, "<span class='notice'>[user] begins cutting your hair.</span>")
		playsound(src.loc, "sound/items/Scissor.ogg", 100, 1)
		sleep(7 SECONDS)
		if(M.loc == T && TM.loc == user.loc  && (user.equipped() == src || issilicon(user)))
			return  0

		if (new_style == "None")
			var/obj/item/I = M.create_wig()
			I.set_loc(user.loc)

		M.bioHolder.mobAppearance.customization_first = new_style
		user.tri_message("[user] cuts [M]'s hair.",\
		M, "<span class='notice'>[user] cuts your hair.</span>",\
		user, "<span class='notice'>You cut [M]'s hair.</span>")

		M.cust_one_state = customization_styles[new_style] || customization_styles_gimmick[new_style]
		M.set_clothing_icon_dirty() // why the fuck is hair updated in clothing
		return 1

//////////////////////////////////////////////////////////
////Razor Blade										/////
/////////////////////////////////////////////////////////
/obj/item/razor_blade/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	if(scalpel_surgery(M,user)) return

	if(user.zone_sel.selecting != "head" || user.a_intent != "help")
		..()
		return

	if( issilicon(M))
		boutput(user, "<span class='alert'>Shave a robot? Shave a robot!?? SHAVE A ROBOT?!?!??</span>")
		return

	if(M.cust_two_state == "wiz")
		if (user == M)
			boutput(user, "<span class='alert'>No!!! This is the worst idea you've ever had!</span>")
			return
		src.visible_message("<span class='alert'><b>[user]</b> quickly shaves off [M]'s beard!</span>")
		M.bioHolder.AddEffect("arcane_shame", timeleft = 120)
		M.bioHolder.mobAppearance.customization_second = "None"
		M.cust_two_state = "None"
		M.set_face_icon_dirty()
		M.emote("cry")
		return

	if(istype(M.buckled, /obj/stool/chair/comfy/barber_chair))

		var/mob/living/carbon/human/H = M
		if(ishuman(M) && ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES) || (H.glasses && H.glasses.c_flags & COVERSEYES)))
			// you can't stab someone in the eyes wearing a mask!
			boutput(user, "<span class='notice'>You're going to need to remove that mask/helmet/glasses first.</span>")
			return


		if(M.bioHolder.mobAppearance.customization_second == "None")
			boutput(user, "<span class='alert'>There is nothing to shave!</span>")
			return

		var/new_style = input(user, "Please select facial style", "Facial Style")  as null|anything in customization_styles + customization_styles_gimmick

		if (new_style)
			var/list/mustaches =list("Watson", "Chaplin", "Selleck", "Van Dyke", "Hogan")
			var/list/beards  = list("Neckbeard", "Elvis", "Abe", "Chinstrap", "Hipster", "Wizard")
			var/list/full = list("Goatee", "Full Beard", "Long Beard")

			if((new_style in full) && (!(M.bioHolder.mobAppearance.customization_second in full)))
				boutput(user, "<span class='alert'>[M] doesn't have enough facial hair!</span>")
				return

			if((new_style in beards) && (M.bioHolder.mobAppearance.customization_second in mustaches))
				boutput(user, "<span class='alert'>[M] doesn't have a beard!</span>")
				return

			if((new_style in mustaches) && (M.bioHolder.mobAppearance.customization_second in beards))
				boutput(user, "<span class='alert'>[M] doesn't have a mustache!</span>")
				return

		var/turf/T = M.loc
		var/turf/TM = user.loc
		boutput(user, "<span class='notice'>You begin shaving [M].</span>")
		boutput(M, "<span class='notice'>[user] begins shaving you.</span>")
		//playsound(src.loc, "Scissor.ogg", 100, 1)
		sleep(7 SECONDS)
		if(M.loc == T && TM.loc == user.loc  && (user.equipped() == src || issilicon(user)))
			return


		M.bioHolder.mobAppearance.customization_second = new_style
		boutput(M, "<span class='notice'>[user] shaves your face</span>")
		boutput(user, "<span class='notice'>You shave [M]'s face.</span>")

		M.cust_two_state = customization_styles[new_style] || customization_styles_gimmick[new_style]
		M.set_face_icon_dirty()

//////////////////////////////////////////////////////////////////
/////Dye Bottle Dispenser									/////
/////////////////////////////////////////////////////////////////
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

			if(!src.bottle.empty)
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
						bottle.empty = 0
						bottle.icon_state = "dye-f"
					src.updateDialog()
			if(href_list["emptyb"])
				if(src.bottle)
					bottle.empty = 1
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
