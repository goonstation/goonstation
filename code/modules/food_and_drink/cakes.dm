//defines used later for custom cake utility procs
#define CAKE_MODE_CAKE 1
#define CAKE_MODE_SLICE 2
#define CAKE_MODE_STACK 4
#define CAKE_MODE_BUILD 9

/obj/item/reagent_containers/food/snacks/yellow_cake_uranium_cake
	name = "yellow cake"
	desc = "A decent yellow cake that seems to be glowing a bit. Is this safe?"
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	icon_state = "yellowcake"
	w_class = 1
	amount = 1
	heal_amt = 2
	initial_volume = 5
	initial_reagents = "uranium"

/obj/item/reagent_containers/food/snacks/cake
	name = "sponge cake"
	desc = "A plain sponge cake. Could be better, could be worse."
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	icon_state = "cake_batter"
	amount = 12
	heal_amt = 2
	custom_food = 0
	w_class = 3
	food_effects = list("food_energized", "food_cold")

/obj/item/reagent_containers/food/snacks/cake/custom
	name = "cake"
	desc = "a cake"
	icon_state = "cake_batter"
	amount = 10
	heal_amt = 2
	use_bite_mask = 0
	flags = FPRINT | TABLEPASS | NOSPLASH
	object_flags = IGNORE_CONTEXT_CLICK_HELD
	initial_volume = 100
	w_class = 4.0
	var/sliced = FALSE
	var/static/list/frostingstyles = list("classic","top swirls","bottom swirls","spirals","rose spirals")
	var/clayer = 1
	var/amount2 //holds the amount of slices in cake 2 (not entirely, but its used for a bit of math later)
	var/amount3 //same for cake 3
	var/cake_candle
	var/litfam = FALSE //is the cake lit (candle)

	New()
		..()
		contextLayout = new /datum/contextLayout/default()

	/*_______*/
	/*Utility*/
	/*‾‾‾‾‾‾‾*/
	proc/check_for_topping(var/obj/item/W)
		var/tag = null
		var/pendinglight = 0
		if(istype(W,/obj/item/device/light/candle)) //special handling for candles because they need to send unique information
			var/obj/item/device/light/candle/candle = W
			if(candle.on)
				pendinglight = 1
				tag = "cake[clayer]-candle_lit"
			else
				tag = "cake[clayer]-candle"
			cake_candle = tag
		else
			switch(W.type)
				if(/obj/item/reagent_containers/food/snacks/condiment/chocchips) //checks for item paths and assigns an overlay tag to it
					tag = "cake[clayer]-chocolate"
				if(/obj/item/reagent_containers/food/snacks/ingredient/sugar)
					tag = "cake[clayer]-sprinkles"
				if(/obj/item/reagent_containers/food/snacks/plant/cherry)
					tag = "cake[clayer]-cherry"
				if(/obj/item/cocktail_stuff/maraschino_cherry)
					tag = "cake[clayer]-cherry"
				if(/obj/item/reagent_containers/food/snacks/plant/orange/wedge)
					tag = "cake[clayer]-orange"
				if(/obj/item/reagent_containers/food/snacks/plant/lemon/wedge)
					tag = "cake[clayer]-lemon"
				if(/obj/item/reagent_containers/food/snacks/plant/lime/wedge)
					tag = "cake[clayer]-lime"
				if(/obj/item/reagent_containers/food/snacks/plant/strawberry)
					tag = "cake[clayer]-strawberry"
		return list(tag,pendinglight) //returns a list consisting of the new overlay tag and candle data


	proc/frost_cake(var/obj/item/reagent_containers/food/drinks/drinkingglass/icing/tube,var/mob/user)
		if(tube.reagents.total_volume < 25)
			user.show_text("The icing tube isn't full enough to frost the cake!","red")
			return
		var/frostingtype
		frostingtype = input("Which frosting style would you like?", "Frosting Style", null) as null|anything in frostingstyles
		if(frostingtype && (get_dist(src, usr) <= 1))
			var/tag
			var/datum/color/average = tube.reagents.get_average_color()
			switch(frostingtype)
				if("classic")
					tag = "cake[clayer]-classic"
				if("top swirls")
					tag = "cake[clayer]-swirl_top"
				if("bottom swirls")
					tag = "cake[clayer]-swirl_bottom"
				if("spirals")
					tag = "cake[clayer]-spiral"
				if("rose spirals")
					tag = "cake[src.clayer]-spiral_rose"
			if(!src.GetOverlayImage(tag))
				if(src.sliced)
					tag = replacetext(tag,"cake[clayer]","slice")
				var/image/frostingoverlay = new /image('icons/obj/foodNdrink/food_dessert.dmi',tag)
				frostingoverlay.color = average.to_rgba()
				frostingoverlay.alpha = 255
				src.UpdateOverlays(frostingoverlay,tag)
				tube.reagents.trans_to(src,25)

	proc/overlay_number_convert(var/original_clayer,var/mode,var/singlecake) //original - original clayer value, mode - which math we're using
		switch(mode)
			if(CAKE_MODE_STACK)
				if(original_clayer==2)
					. = list(1,2)
				else if(original_clayer==3 && singlecake)
					. = list(1,3)
				else
					. = list(2,3)
			if(CAKE_MODE_BUILD)
				if(original_clayer==2)
					. = list(2,1)
				else if(original_clayer==3)
					. = list(3,1)


	proc/slice_cake(var/obj/item/W,var/mob/user)
		if (src.sliced)
			user.show_text("This cake has already been sliced!","red")
			return
		user.show_text("You cut the cake into slices.")
		var/layer_tag
		var/replacetext
		var/obj/item/reagent_containers/food/snacks/cake/custom/s = new /obj/item/reagent_containers/food/snacks/cake/custom //temporary reference item to paste overlays onto child items
		var/slices
		var/slice_candle
		switch(src.clayer) //checking the current layer of the cake
			if(1)
				layer_tag = "base" //the tag of the future overlay
				replacetext = "cake1" //used in replacetext below to assign overlays
				slices = src.amount //defaults to the amount of the base cake because no additional cakes are present
			if(2)
				layer_tag = "second"
				replacetext = "cake2"
				slices = src.amount2 //one of the cases amount2 and amount3 are used
			if(3)
				layer_tag = "third"
				replacetext = "cake3"
				slices = src.amount3

		var/list/returns = build_cake(s,user,CAKE_MODE_SLICE,layer_tag,replacetext)
		slices = returns[1]
		slice_candle = returns[2]

		var/transferamount = (src.amount/src.clayer)/slices //amount of reagent to transfer to slices
		var/deletionqueue //is the source cake deleted after slicing?
		if(src.clayer == 1) //qdel(src) if there was only one layer to the cake, otherwise, decrement the layer
			deletionqueue = 1
		else
			src.clayer--
			src.update_cake_context()
		for(var/i=1,i<=slices,i++) //generating child slices of the parent template
			var/obj/item/reagent_containers/food/snacks/cake/custom/schild = new /obj/item/reagent_containers/food/snacks/cake/custom
			schild.icon_state = "slice-overlay"
			for(var/overlay_ref in s.overlay_refs) //looping through parent overlays and copying them over to the children
				schild.UpdateOverlays(s.GetOverlayImage(overlay_ref), overlay_ref)
			if(slice_candle) //making sure there's only one candle :)
				if(slice_candle == 1)
					schild.UpdateOverlays(new /image('icons/obj/foodNdrink/food_dessert.dmi',"slice-candle"),"slice-candle")
				if(slice_candle == 2)
					schild.UpdateOverlays(new /image('icons/obj/foodNdrink/food_dessert.dmi',"slice-candle_lit"),"slice-candle_lit")
				slice_candle = 0
				cake_candle = 0 
				schild.cake_candle = 1
				if(src.litfam) //light update
					src.put_out()
					schild.ignite()
			src.reagents.trans_to(schild,transferamount) //setting up the other properties of the slice
			schild.pixel_x = rand(-6, 6)
			schild.pixel_y = rand(-6, 6)
			for(var/food_effect in src.food_effects)
				if(food_effect in schild.food_effects)
					continue
				schild.food_effects += food_effect
			schild.w_class = 1
			schild.quality = src.quality
			schild.name = "slice of [src.name]"
			schild.desc = "a delicious slice of cake!"
			schild.food_color = src.food_color
			schild.sliced = TRUE
			schild.amount = 1

			schild.set_loc(get_turf(src.loc))
		qdel(s) //cleaning up the template slice
		if(deletionqueue)
			qdel(src)
			


	proc/stack_cake(var/obj/item/reagent_containers/food/snacks/cake/custom/c,var/mob/user)
		if(!(src.clayer<3) || (c.clayer>=3) || (c.sliced))
			return

		user.u_equip(c)
		c.set_loc(user)
		src.clayer++
		src.reagents.maximum_volume += 100
		src.amount += 10
		c.reagents.trans_to(src,c.reagents.total_volume)

		for(var/food_effect in c.food_effects) //adding food effects to the src that arent already present
			src.food_effects |= food_effect

		var/singlecake //logging the clayer before changing it later
		if(c.clayer == 1)
			singlecake = 1

		if(src.cake_candle)	//looking for candles and if you set a cake on top of it, it pops off!
			src.ClearSpecificOverlays("[src.cake_candle]")
			var/obj/item/device/light/candle/can = new /obj/item/device/light/candle/small
			can.set_loc(get_turf(src.loc))
			user.show_text("<b>The candle pops off! Oh no!</b>","red")
			cake_candle = 0
			if(src.litfam)
				src.put_out()

		for(var/overlay_ref in c.overlay_refs) //the handling for actually adding the toppings to the cake
			if(("[overlay_ref]" == "base") || ("[overlay_ref]" == "second")) //setting up base layer overlay
				var/overlay_layer
				if("[overlay_ref]" == "base")
					if(src.clayer == 2)
						overlay_layer = "second"
						src.amount2 = c.amount
					else if(src.clayer == 3)
						overlay_layer = "third"
						src.amount3 = c.amount
				else if("[overlay_ref]" == "second")
					overlay_layer = "third"
					src.amount3 = c.amount
					src.clayer++
					src.reagents.maximum_volume += 100
					src.amount += 10
				var/image/stack = new /image('icons/obj/foodNdrink/food_dessert.dmi',"cake[src.clayer]-overlay")
				var/image/ov_image = c.GetOverlayImage(overlay_ref)
				stack.color = ov_image.color
				src.UpdateOverlays(stack, overlay_layer)
				continue
			var/image/buffer = c.GetOverlayImage("[overlay_ref]") //generating the topping reference from the original cake to be stacked
			var/list/tag
			var/list/newnumbers = c.overlay_number_convert(src.clayer,CAKE_MODE_STACK,singlecake)
			tag = replacetext("[overlay_ref]","[newnumbers[1]]","[newnumbers[2]]")
			if(c.cake_candle)
				src.cake_candle = replacetext("[c.cake_candle]","[newnumbers[1]]","[newnumbers[2]]")
				c.cake_candle = 0
			var/image/newoverlay = new /image('icons/obj/foodNdrink/food_dessert.dmi',tag)
			if(buffer.color)
				newoverlay.color = buffer.color
			src.UpdateOverlays(newoverlay,tag)
		if(c.litfam)
			src.ignite()
		src.update_cake_context()
		qdel(c)


	proc/build_cake(var/obj/item/cake_transfer,var/mob/user,var/mode,var/layer_tag,var/replacetext)//cake_transfer : passes a reference to the cake that we are building //layer_tag and replacetext : references used with slicing //decompiles a full cake into slices or other cakes
		if((mode != CAKE_MODE_CAKE) && (mode != CAKE_MODE_SLICE))
			return
		var/staticiterator = src.overlays.len
		var/toggleswitch
		var/slices
		var/candle //cute little wax stick that people light on fire for their own enjoyment <3
		var/obj/item/reagent_containers/food/snacks/cake/custom/cake
		if(istype(cake_transfer,/obj/item/reagent_containers/food/snacks/cake/custom))
			cake = cake_transfer
		for(var/i=1,i<=staticiterator,i++)
			if(mode == CAKE_MODE_CAKE)
				if("[src.overlay_refs[i]]" == "base")
					continue
				if(("[src.overlay_refs[i]]" == "second") || ("[src.overlay_refs[i]]" == "third"))
					if(("[src.overlay_refs[i]]" == "second") && (src.clayer == 2))
						toggleswitch = 1
						cake.amount = src.amount2
						src.amount2 = 0
					else if(("[src.overlay_refs[i]]" == "third") && (src.clayer == 3))
						toggleswitch = 1
						cake.amount = src.amount3
						src.amount3 = 0
					if(toggleswitch)
						var/image/stack = new /image('icons/obj/foodNdrink/food_dessert.dmi',"cake1-overlay")
						var/image/warningsuppression = src.GetOverlayImage(src.overlay_refs[i])
						stack.color = warningsuppression.color
						cake.UpdateOverlays(stack,"base")
						src.ClearSpecificOverlays("[src.overlay_refs[i]]")
						staticiterator--
						i--
						continue
				if(toggleswitch)
					var/tag
					var/image/buffer = src.GetOverlayImage("[src.overlay_refs[i]]")
					var/list/newnumbers = src.overlay_number_convert(src.clayer,CAKE_MODE_BUILD)
					tag = replacetext("[src.overlay_refs[i]]","[newnumbers[1]]","[newnumbers[2]]")
					if(src.cake_candle)
						cake.cake_candle = replacetext("[src.cake_candle]","[newnumbers[1]]","[newnumbers[2]]")
						src.cake_candle = 0
					var/image/newoverlay = new /image('icons/obj/foodNdrink/food_dessert.dmi',tag)
					if(buffer.color)
						newoverlay.color = buffer.color
					cake.UpdateOverlays(newoverlay,tag)
					src.ClearSpecificOverlays("[src.overlay_refs[i]]")
					staticiterator--
					i--
					continue
			else if(mode == CAKE_MODE_SLICE)
				if("[src.overlay_refs[i]]" == layer_tag) //if it finds the identifying tag for the current layer (base,second,third) it flips the toggle and starts pulling overlays
					toggleswitch = 1
					var/image/buffer = src.GetOverlayImage("[src.overlay_refs[i]]")
					var/image/slicecolor = new /image('icons/obj/foodNdrink/food_dessert.dmi',"slice-overlay")
					if(buffer.color)
						slicecolor.color = buffer.color
					cake.UpdateOverlays(slicecolor,"base") //setting the base overlay of the temporary slice object
					src.ClearSpecificOverlays(layer_tag)
					staticiterator--
					i--
					continue
				if(toggleswitch) //after setting the base layer, all subsequent overlays are registered as toppings and applied to the slice
					var/image/buffer = src.GetOverlayImage("[src.overlay_refs[i]]")
					var/toppingpath = replacetext("[src.overlay_refs[i]]","[replacetext]","slice")

					if((toppingpath == "slice-candle") || (toppingpath == "slice-candle_lit")) //special case for candles :D
						if(toppingpath == "slice-candle")
							candle = 1
						else
							candle = 2
							staticiterator--
							i--
						src.ClearSpecificOverlays("[src.overlay_refs[i]]")
						continue

					var/image/toppingimage = new /image('icons/obj/foodNdrink/food_dessert.dmi',toppingpath)
					if(buffer.color)
						toppingimage.color = buffer.color
					cake.UpdateOverlays(toppingimage,toppingpath)
					src.ClearSpecificOverlays("[src.overlay_refs[i]]")
					staticiterator--
					i--
			else
				break
		if(src.amount > 10)
			src.amount -= 10
			switch(src.clayer)
				if(2)
					src.amount2 = 0
				if(3)
					src.amount3 = 0
			if(mode == CAKE_MODE_CAKE)
				cake.amount = 10
			else
				slices = 10
		else if((mode == CAKE_MODE_SLICE) && (src.clayer == 1))
			slices = src.amount
		else
			qdel(cake) //this will happen if someone eats a cake without slicing it and the amount math has to recalculate past an entire layer (i.e. someone takes 11 bites)
			user.show_text("<b>OH NO! The cake was a lie!</b>","red")
			src.clayer--
			src.reagents.maximum_volume -= 100
			return

		src.reagents.maximum_volume -= 100
		if(mode == CAKE_MODE_SLICE)
			return list(slices,candle)
		else
			src.clayer--
			src.update_cake_context()

	/*_______________*/
	/*Light stuffs :D*/
	/*‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/

	proc/ignite(var/mob/user as mob, var/message as text)
		if (!src)
			return
		if (!src.litfam)
			src.firesource = TRUE
			src.litfam = TRUE
			src.hit_type = DAMAGE_BURN
			src.force = 3
			src.add_simple_light("cake_light", list(0.5*255, 0.3*255, 0, 100))
			if (!(src in processing_items))
				processing_items.Add(src)
			src.update_cake_context()
		else
			return

		if(src.sliced && src.GetOverlayImage("slice-candle"))
			src.ClearSpecificOverlays("slice-candle")
			src.UpdateOverlays(image('icons/obj/foodNdrink/food_dessert.dmi',"slice-candle_lit"), "slice-candle_lit")
		else if(src.GetOverlayImage("cake[src.clayer]-candle"))
			src.ClearSpecificOverlays("cake[src.clayer]-candle")
			src.UpdateOverlays(image('icons/obj/foodNdrink/food_dessert.dmi',"cake[src.clayer]-candle_lit"), "cake[src.clayer]-candle_lit")
		return


	proc/put_out(var/mob/user as mob)
		if (!src) return
		if (src.litfam)
			src.firesource = FALSE
			src.litfam = FALSE
			hit_type = DAMAGE_BLUNT
			src.force = 0
			src.remove_simple_light("cake_light")
			if (src in processing_items)
				processing_items.Remove(src)
			src.update_cake_context()
		return

	/*__________________*/
	/*Context Actions :D*/
	/*‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/

	proc/update_cake_context()
		src.contextActions = list()

		var/pickup = FALSE
		if(clayer>1)
			contextActions += new /datum/contextAction/cake/unstack
			pickup = TRUE
		if(litfam)
			contextActions += new /datum/contextAction/cake/candle
			pickup = TRUE
		if(pickup)
			contextActions += new /datum/contextAction/cake/pickup

	proc/unstack(var/mob/user)
		var/obj/item/reagent_containers/food/snacks/cake/custom/s = new /obj/item/reagent_containers/food/snacks/cake/custom

		src.reagents.trans_to(s,(src.reagents.total_volume/3))
		for(var/food_effect in src.food_effects)
			if(food_effect in s.food_effects)
				continue
			s.food_effects += food_effect
		s.quality = src.quality
		s.food_color = src.food_color

		build_cake(s,user,CAKE_MODE_CAKE)

		if(istype(user,/mob/living/carbon/human))
			user.put_in_hand_or_drop(s)
		else
			s.set_loc(get_turf(user))
		if(src.litfam)
			src.put_out()
			s.ignite()

	proc/extinguish(var/mob/user)
		var/blowout = FALSE
		if(src.sliced && src.GetOverlayImage("slice-candle_lit"))
			src.ClearSpecificOverlays("slice-candle_lit")
			src.UpdateOverlays(new /image('icons/obj/foodNdrink/food_dessert.dmi',"slice-candle"), "slice-candle")
			blowout = TRUE
		else if(src.GetOverlayImage("cake[src.clayer]-candle_lit"))
			src.ClearSpecificOverlays("cake[src.clayer]-candle_lit")
			src.UpdateOverlays(new /image('icons/obj/foodNdrink/food_dessert.dmi',"cake[src.clayer]-candle"), "cake[src.clayer]-candle")
			blowout = TRUE
		if(blowout)
			src.put_out()
			user.visible_message("<b>[user.name]</b> blows out the candle!")

	attackby(obj/item/W as obj, mob/user as mob) //ok this proc is entirely a mess, but its *hopfully* better on the server than the alternatives
		var/topping //the topping the player is adding (stored as a string reference to an icon_state)
		var/pendinglight //a variable referenced later to check if the light source on a cake needs to be updated
		if(istool(W, TOOL_CUTTING | TOOL_SAWING))
			if(!src.sliced)
				slice_cake(W,user)
				return
			else
				..()
		else if(istype(W,/obj/item/reagent_containers/food/drinks/drinkingglass/icing))
			frost_cake(W,user)
			return
		else if(istype(W,/obj/item/reagent_containers/food/snacks/cake/custom))
			stack_cake(W,user)
			return
		else if(cake_candle && !(litfam) && (W.firesource))
			src.ignite()
			W.firesource_interact()
			return
		else
			var/list/returns = check_for_topping(W) //if the item used on the cake wasn't handled previously, check for valid toppings next
			if(returns[1] == 0) //if the item wasn't a valid topping, perfom the default action
				..()
				return
			topping = returns[1]
			pendinglight = returns[2]

			//adding topping overlays to the cake. Yay :D
			if(src.sliced) //if you add a topping to a sliced cake, it updates the icon_state to the sliced version.
				topping = replacetext(topping,"cake[clayer]","slice")
			if(topping && !(src.GetOverlayImage(topping))) //actually adding the topping overlay to the cake
				var/image/toppingoverlay = new /image('icons/obj/foodNdrink/food_dessert.dmi',topping)
				toppingoverlay.alpha = 255
				src.UpdateOverlays(toppingoverlay,topping)
				user.u_equip(W)
				qdel(W)
				if(pendinglight)
					src.ignite()
				return


	attack_hand(mob/user as mob)
		if(length(contextActions))
			user.showContextActions(contextActions, src)
		else
			..()

	attack(mob/M as mob, mob/user as mob, def_zone) //nom nom nom
		if (!src.sliced)
			if (user == M)
				user.show_text("You can't just cram that in your mouth, you greedy beast!","red")
				user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
				return
			else
				user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
				return
		else
			..()

/obj/item/reagent_containers/food/snacks/cake/batter
	name = "cake batter"
	desc = "An uncooked bit of cake batter. Eating it like this won't be very nice."
	icon_state = "cake_batter"
	amount = 12
	heal_amt = 1
	var/obj/item/reagent_containers/custom_item
	initial_volume = 50

/obj/item/reagent_containers/food/snacks/b_cupcake
	name = "birthday cupcake"
	desc = "A little birthday cupcake for a bee. May not taste good to non-bees. This doesn't seem to be homemade; maybe that's why it looks so generic."
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	icon_state = "b_cupcake"
	amount = 4
	heal_amt = 1
	doants = 0

	New()
		..()
		reagents.add_reagent("nectar", 10)
		reagents.add_reagent("honey", 10)
		reagents.add_reagent("cornstarch", 5)
		reagents.add_reagent("pollen", 20)

/obj/item/reagent_containers/food/snacks/cake/cream
	name = "cream sponge cake"
	desc = "Mmm! A delicious-looking cream sponge cake!"
	icon_state = "cake_cream"
	amount = 12
	heal_amt = 2
	initial_volume = 50
	initial_reagents = list("sugar"=30)

/obj/item/reagent_containers/food/snacks/cake/chocolate
	name = "chocolate sponge cake"
	desc = "Mmm! A delicious-looking chocolate sponge cake!"
	icon_state = "cake_chocolate"
	amount = 12
	heal_amt = 3
	initial_volume = 50
	initial_reagents = "chocolate"

/obj/item/reagent_containers/food/snacks/cake/meat
	name = "meat cake"
	desc = "Uh... well... wow. What is this?"
	var/hname = ""
	var/job = null
	icon_state = "cake_meat"
	amount = 12
	heal_amt = 3
	initial_volume = 50
	initial_reagents = "blood"

#ifdef XMAS

/obj/item/reagent_containers/food/snacks/cake/fruit
	name = "fruitcake"
	desc = "The most disgusting dessert ever devised. Legend says there's only one of these in the galaxy, passed from location to location by vengeful deities."
	icon_state = "cake_fruit"
	amount = 12
	heal_amt = 3
	initial_volume = 50
	initial_reagents = "yuck"
	festivity = 10

	on_finish(mob/eater)
		..()
		eater.show_text("It's so hard it breaks one of your teeth AND it tastes disgusting! Why would you ever eat this?","red")
		random_brute_damage(eater, 3)
		eater.emote("scream")
		return

#endif

/obj/item/reagent_containers/food/snacks/cake/bacon
	name = "bacon cake"
	desc = "This...this is just terrible."
	icon_state = "cake_bacon"
	amount = 12
	heal_amt = 4
	initial_volume = 250
	initial_reagents = "porktonium"

	heal(var/mob/M)
		M.nutrition += 500
		return

/obj/item/cake_item
	name = "cream sponge cake"
	desc = "Mmm! A delicious-looking cream sponge cake! There's a lump in it..."
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	icon_state = "cake_cream"

/obj/item/cake_item/attack(target as mob, mob/user as mob)
	var/iteminside = src.contents.len
	if(!iteminside)
		user.show_text("The cake crumbles away!","red")
		qdel(src)
	user.show_text("You bite down on something odd! You open up the cake...","red")
	for(var/obj/item/I in src.contents)
		I.set_loc(user.loc)
		I.add_fingerprint(user)
	qdel(src)
	return
