/datum/custom_soup
	var/name
	var/amount = 3
	var/heal_amt = 0
	var/desc = null
	var/initial_volume = 60
	var/list/initial_reagents = list()
	var/list/food_effects = list()

/obj/item/reagent_containers/food/snacks/soup/custom
	icon = 'icons/obj/soup_pot.dmi'
	icon_state = "soup_custom"
	name = null
	desc = "Ah, the, uh, wonders of the kitchen stove."
	amount = null
	heal_amt = null
	initial_volume = null
	initial_reagents = null
	food_effects = null
	var/image/fluid_icon

	New(var/datum/custom_soup/S)
		if(!S)
			qdel(src)
			return
		src.name = S.name
		src.amount = S.amount
		if(S.desc)
			src.desc = S.desc
		src.heal_amt = S.heal_amt
		src.initial_volume = S.initial_volume
		src.initial_reagents = S.initial_reagents

		if(S.food_effects.len <= 4)
			src.food_effects = S.food_effects
		else
			var/list/temp = S.food_effects
			for(var/i, i<4, i++)
				var/effect = pick(temp)
				src.food_effects += effect
				temp -= effect


		fluid_icon = image("icon" = 'icons/obj/soup_pot.dmi', "icon_state" = "soup_custom-f")

		..()

		src.overlays = null
		if(reagents.total_volume)
			var/datum/color/average = reagents.get_average_color()
			fluid_icon.color = average.to_rgba()
			src.overlays += fluid_icon

/obj/stove
	name = "stove"
	desc = "A perfectly ordinary kitchen stove; not that you'll be doing anything ordinary with it.<br>It seems this model doesn't have a built in igniter, so you'll have to light it manually."
	icon = 'icons/obj/soup_pot.dmi'
	icon_state = "stove0"
	anchored = 1
	density = 1
	mats = 18
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	var/obj/item/soup_pot/pot
	var/on = 0
	flags = NOSPLASH

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W,/obj/item/soup_pot))
			if(src.pot)
				boutput(user,"<span class='alert'><b>There's already a pot on the stove, dummy!</span>")
			else
				src.icon_state = "stove1"
				src.pot = W
				user.u_equip(W)
				W.set_loc(src)

		if (!src.on && src.pot)

			if (isweldingtool(W) && W:try_weld(user,0,-1,0,0))
				src.light(user, "<span class='alert'><b>[user]</b> casually lights [src] with [W], what a badass.</span>")
				return

			else if (istype(W, /obj/item/clothing/head/cakehat) && W:on)
				src.light(user, "<span class='alert'>Did [user] just light \his [src] with [W]? Holy Shit.</span>")
				return

			else if (istype(W, /obj/item/device/igniter))
				src.light(user, "<span class='alert'><b>[user]</b> fumbles around with [W]; a small flame erupts from [src].</span>")
				return

			else if (istype(W, /obj/item/device/light/zippo) && W:on)
				src.light(user, "<span class='alert'>With a single flick of their wrist, [user] smoothly lights [src] with [W]. Damn they're cool.</span>")
				return

			else if ((istype(W, /obj/item/match) || istype(W, /obj/item/device/light/candle)) && W:on)
				src.light(user, "<span class='alert'><b>[user] lights [src] with [W].</span>")
				return

			else if (W.burning)
				src.light(user, "<span class='alert'><b>[user]</b> lights [src] with [W]. Goddamn.</span>")
				return

			else
				pot.attackby(W,user)
				if(!pot.my_soup)
					W.afterattack(pot,user) // ????

	attack_hand(mob/user as mob)
		if(src.on)
			boutput(user,"<span class='alert'><b>Cooking soup takes time, be patient!</span>")
			return
		if(src.pot)
			src.icon_state = "stove0"
			src.pot.set_loc(src.loc)
			user.put_in_hand_or_drop(src.pot)
			src.pot = null

	proc/light(var/mob/user, var/message as text)
		if(pot.my_soup)
			boutput(user,"<span class='alert'><b>There's still soup in the pot, dummy!</span>")
			return
		if(!pot.total_wclass)
			boutput(user,"<span class='alert'><b>You can't have a soup with no ingredients, dummy!</span>")
			return
		if(!pot.reagents.total_volume)
			boutput(user,"<span class='alert'><b>You can't have a soup with no broth, dummy!</span>")
			return
		user.visible_message(message)
		src.on = 1
		src.icon_state = "stove2"
		spawn(pot.total_wclass SECONDS)
			src.on = 0
			src.icon_state = "stove1"
			src.generate_soup()

	proc/generate_soup()
		if(!pot)
			return
		if(!pot.total_wclass)
			return
		if(!pot.reagents.total_volume)
			return

		var/datum/custom_soup/S = new()

		S.amount = pot.total_wclass

		var/soup_name_i = ""
		var/soup_name_b = ""

		// look at this gross shit; if you can think of a better way, please fix this!

		var/obj/item/biggest = null
		var/obj/item/biggester = null
		var/obj/item/biggestest = null

		for(var/obj/item/I in pot)
			if(biggestest)
				if(I.w_class >= biggestest.w_class)
					if(biggester)
						biggest = biggester
					biggester = biggestest
					biggestest = I

				else if(biggester)
					if(I.w_class >= biggester.w_class)
						biggest = biggester
						biggester = I

					else if(biggest)
						if(I.w_class >= biggest.w_class)
							biggest = I

					else
						biggest = I
				else
					biggester = I
			else
				biggestest = I

			var/obj/item/reagent_containers/food/snacks/F = I
			if(istype(F))
				S.food_effects |= F.food_effects
				S.heal_amt += F.heal_amt/pot.total_wclass
				S.amount += F.amount/pot.total_wclass
			else
				S.amount += F.w_class/pot.total_wclass/2
				S.heal_amt -= F.w_class/pot.total_wclass/2

			if(I.reagents)
				for(var/id in I.reagents.reagent_list)
					if(S.initial_reagents[id])
						S.initial_reagents[id] += I.reagents.reagent_list[id].volume/pot.total_wclass
					else
						S.initial_reagents += id
						S.initial_reagents[id] = I.reagents.reagent_list[id].volume/pot.total_wclass

		S.amount = max(1,round(S.amount))

		if(biggester)
			if(biggest)
				soup_name_i = "[biggestest.name], [biggester.name], and [biggest.name]"
			else
				soup_name_i = "[biggestest.name] and [biggester.name]"
		else
			soup_name_i = "[biggestest.name]"

		var/datum/reagent/most = null
		var/datum/reagent/moster = null
		var/datum/reagent/mostest = null
		var/list/datum/reagent/chems = pot.reagents.reagent_list
		for(var/id in chems)
			var/datum/reagent/current_reagent = chems[id]
			if(mostest)
				if(current_reagent.volume >= mostest.volume)
					if(moster)
						most = moster
					moster = mostest
					mostest = current_reagent

				else if(moster)
					if(current_reagent.volume >= moster.volume)
						most = moster
						moster = current_reagent

					else if(most)
						if(current_reagent.volume >= most.volume)
							most = current_reagent

					else
						most = current_reagent
				else
					moster = current_reagent
			else
				mostest = current_reagent

			if(S.initial_reagents[id])
				S.initial_reagents[id] += chems[id].volume/pot.total_wclass
			else
				S.initial_reagents += id
				S.initial_reagents[id] = chems[id].volume/pot.total_wclass


		if(moster)
			if(most)
				soup_name_b = "[mostest.name], [moster.name], and [most.name]"
			else
				soup_name_b = "[mostest.name] and [moster.name]"
		else
			soup_name_b = "[mostest.name]"


		S.name = "[soup_name_i] soup in [soup_name_b] broth"

		if(length(S.name) > MAX_MESSAGE_LEN)
			S.name = "A fuckton of things soup in [soup_name_b] broth"
			soup_name_i = copytext(html_encode(soup_name_i), 1, MAX_MESSAGE_LEN)
			S.desc = "So you really want to know what the fuckton of things are? Ugh. Fine. Here they are, but I warned you:<br>[soup_name_i] -- Actually, you know what? I'm bored now. Go away."

		pot.my_soup = S

		for(var/x in pot.contents)
			qdel(x)
		pot.reagents.clear_reagents()

		return S


/obj/item/soup_pot
	name = "soup pot"
	desc = "Well, for a very broad definition of \"soup\", anyways."
	icon = 'icons/obj/soup_pot.dmi'
	icon_state = "souppot"
	inhand_image_icon = 'icons/obj/soup_pot.dmi'
	item_state = "souppot"
	two_handed = 1
	var/max_wclass = 3
	var/total_wclass_max = 15
	var/total_wclass = 0
	var/max_reagents = 150
	flags = FPRINT | TABLEPASS | OPENCONTAINER | SUPPRESSATTACK
	w_class = 5.0
	var/image/fluid_icon
	var/datum/custom_soup/my_soup
	tooltip_flags = REBUILD_DIST

	New()
		..()
		fluid_icon = image("icon" = 'icons/obj/soup_pot.dmi', "icon_state" = "souppot-f")
		var/datum/reagents/R = new/datum/reagents(max_reagents)
		reagents = R
		R.my_atom = src
		return

	get_desc(var/dist)
		if(dist>1)
			return
		if (src.total_wclass)
			var/fullness = round((src.total_wclass / total_wclass_max)*10)
			if (src.total_wclass == total_wclass_max)
				. += "[src] is totally full of ingredients"
			else if (fullness >= 0)
				. += "[src] has a few ingredients"
			else if (fullness >= 2)
				. += "[src] is less than half full of ingredients"
			else if (fullness >= 5)
				. += "[src] is over half full of ingredients"
			else if (fullness >= 8)
				. += "[src] is nearly full of ingredients"

		else
			. += "[src] has no ingredients"

		. += " and "

		if (src.reagents.total_volume)
			var/fullness = round((src.reagents.total_volume / max_reagents)*10)
			if (src.reagents.total_volume == max_reagents)
				. += "is totally full of broth"
			else if (fullness >= 0)
				. += "has some broth"
			else if (fullness >= 2)
				. += "is less than half full of broth"
			else if (fullness >= 5)
				. += "is over half full of broth"
			else if (fullness >= 8)
				. += "is nearly full of broth"

		else
			. += "has no broth"

		. += "."

	on_reagent_change()
		if(my_soup)
			return
		src.overlays = null
		if(reagents.total_volume)
			var/datum/color/average = reagents.get_average_color()
			fluid_icon.color = average.to_rgba()
			src.overlays += fluid_icon

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W) && !istype(W,/obj/item/ladle))
			if(src.my_soup)
				boutput(user,"<span class='alert'><b>There's still soup in the pot, dummy!</span>")
				return
			if(W.w_class <= max_wclass)
				if(!(W.flags & OPENCONTAINER)) // is it a reagent container?
					if((W.w_class + src.total_wclass) > src.total_wclass_max)
						boutput(user,"There's not enough room in [src] for [W]!")
						return
					else
						W.set_loc(src)
						user.u_equip(W)
						user.visible_message("[user] puts [W] in [src].", "You put [W] in [src]")
						src.update_wclass_total()
						return
				else if (!W.reagents.total_volume) // if is a container, is it empty?
					if((W.w_class + src.total_wclass) > src.total_wclass_max)
						boutput(user,"There's not enough room in [src] for [W]!")
						return
					else
						W.set_loc(src)
						user.u_equip(W)
						user.visible_message("[user] puts [W] in [src].", "You put [W] in [src]")
						src.update_wclass_total()
						return
		else if (istype(W,/obj/item/ladle))
			var/obj/item/ladle/L = W
			if(!src.my_soup)
				if(src.total_wclass || src.reagents.total_volume)
					boutput(user,"<span class='alert'><b>That's not ready to serve!</span>")
				else
					boutput(user,"<span class='alert'><b>There's nothing in there to serve!</span>")

			else if (L.my_soup)
				if(L.my_soup == src.my_soup)
					src.total_wclass++
					tooltip_rebuild = 1
					L.my_soup = null
					L.overlays = null
					user.visible_message("[user] empties [L] into [src].", "You empty [L] into [src]")
				else
					boutput(user,"<span class='alert'><b>You can't mix soups! That'd be ridiculous!</span>")
			else
				src.total_wclass--
				tooltip_rebuild = 1
				L.my_soup = src.my_soup
				L.add_soup_overlay(fluid_icon.color)
				if(src.total_wclass <= 0)
					src.my_soup = null
					src.on_reagent_change()

			return
		..()

	MouseDrop(atom/over_object, src_location, over_location)
		if (usr.is_in_hands(src))
			var/turf/T = over_object
			if (!(usr in range(1, T)))
				return
			if (istype(T)) //pouring it out
				for (var/obj/O in T)
					if (O.density && !istype(O, /obj/table) && !istype(O, /obj/rack))
						return
				if (!T.density)
					if(src.my_soup)
						usr.visible_message("<span class='alert'>[usr] dumps the soup out of [src] and onto [T]!</span>")
						src.total_wclass = 0
						tooltip_rebuild = 1
						src.my_soup = null
						src.on_reagent_change()
						return
					usr.visible_message("<span class='alert'>[usr] dumps the contents of [src] onto [T]!</span>")
					src.reagents.reaction(T,TOUCH)
					src.reagents.clear_reagents()
					for (var/obj/item/I in src)
						I.set_loc(T)
						//I.layer = initial(I.layer)
					src.update_wclass_total()
					return

		if(over_object == usr) // taking items out
			if(src.contents.len)
				var/obj/item/I = src.contents[src.contents.len]
				usr.put_in_hand_or_drop(I)
				src.update_wclass_total()
				return
		..()

	proc/update_wclass_total()
		tooltip_rebuild = 1
		src.total_wclass = 0
		for(var/obj/item/I in src.contents)
			src.total_wclass += I.w_class


/obj/item/ladle
	name = "ladle"
	desc = "You'll need this to serve your soup; don't lose it!"
	icon = 'icons/obj/soup_pot.dmi'
	icon_state = "ladle"
	var/datum/custom_soup/my_soup
	var/image/fluid_icon

	New()
		..()
		fluid_icon = image("icon" = 'icons/obj/soup_pot.dmi', "icon_state" = "ladle-f")
		if(prob(1))
			src.name = "Soup sword" //https://discordapp.com/channels/182249960895545344/469379618168897538/698632230851051552
			src.setItemSpecial(/datum/item_special/swipe)

	proc/add_soup_overlay(var/new_color)
		fluid_icon.color = new_color
		src.overlays += fluid_icon
