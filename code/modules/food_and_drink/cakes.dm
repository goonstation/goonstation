//defines used later for custom cake utility procs
#define CAKE_MODE_CAKE 1
#define CAKE_MODE_SLICE 2
#define CAKE_MODE_STACK 3
#define CAKE_MODE_BUILD 4
#define CAKE_SLICES 10

/obj/item/reagent_containers/food/snacks/cake_batter
	name = "cake batter"
	desc = "An uncooked bit of cake batter. Eating it like this won't be very nice."
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	icon_state = "cake_batter"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	bites_left = 12
	heal_amt = 1
	var/obj/item/reagent_containers/custom_item
	initial_volume = 50

/obj/item/reagent_containers/food/snacks/yellow_cake_uranium_cake
	name = "yellow cake"
	desc = "A decent yellow cake that seems to be glowing a bit. Is this safe?"
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	icon_state = "yellowcake"
	w_class = W_CLASS_TINY
	object_flags = NO_GHOSTCRITTER
	bites_left = 1
	heal_amt = 2
	initial_volume = 5
	initial_reagents = "uranium"

/obj/item/reagent_containers/food/snacks/cake
	name = "cake"
	desc = "a cake"
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	icon_state = "cake1-base_custom"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	bites_left = 0
	heal_amt = 2
	use_bite_mask = FALSE
	flags = FPRINT | TABLEPASS | NOSPLASH
	initial_volume = 100
	w_class = W_CLASS_BULKY
	var/list/cake_bases //stores the name of the base types of each layer of cake i.e. ("custom","gateau","meat")
	var/list/cake_types = list()
	var/sliced = FALSE
	var/static/list/frostingstyles = list("classic","top swirls","bottom swirls","spirals","rose spirals")
	var/clayer = 1
	var/list/cake_candle = list()
	var/litfam = FALSE //is the cake lit (candle)
	var/list/datum/contextAction/cakeActions

	New()
		..()
		contextLayout = new /datum/contextLayout/default()

	/*_______*/
	/*Utility*/
	/*‾‾‾‾‾‾‾*/

	proc/check_for_topping(var/obj/item/W)
		var/tag = null //the name of the overlay (corresponds to the icon_state name)
		var/overlay_color //does the overlay need a color passed to it?
		if(istype(W,/obj/item/device/light/candle)) //istype check for candles because there are maaaany types of candles to choose from
			tag = "cake[clayer]-candle" //which cake layer is this candle going to?
			cake_candle = list(tag,"[W.type]") //what type of candle is it?
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
				if(/obj/item/reagent_containers/food/snacks/plant/blackberry)
					tag = "cake[clayer]-blackberry"
				if(/obj/item/reagent_containers/food/snacks/plant/raspberry)
					tag = "cake[clayer]-raspberry"
				if(/obj/item/reagent_containers/food/snacks/plant/blueraspberry)
					tag = "cake[clayer]-braspberry"

		if(tag && src.GetOverlayImage(tag)) //if there's a duplicate non-generic overlay, return a list of empty data
			return list(0,0)

		if(istype(W,/obj/item/reagent_containers/food/snacks))
			var/obj/item/reagent_containers/food/snacks/F = W
			if(!tag)
				var/generic_number //which generic overlay are we using?
				var/sliced_or_cake = sliced?"slice":"cake[clayer]"
				if(!src.GetOverlayImage("[sliced_or_cake]-generic[1]")) //check for no generics first to save resources
					generic_number = 1
				else if(src.GetOverlayImage("[sliced_or_cake]-generic[3]")) //check for maxed cake next to save more resources
					return list(0,0)
				else if(src.GetOverlayImage("[sliced_or_cake]-generic[2]"))
					generic_number = 3
				else
					generic_number = 2
				tag = "cake[clayer]-generic[generic_number]"
				overlay_color = F.get_food_color()

			for(var/food_effect in F.food_effects)
				src.food_effects |= food_effect

		. = list(tag,overlay_color) //returns a list consisting of the new overlay tag


	proc/frost_cake(var/obj/item/reagent_containers/food/drinks/drinkingglass/icing/tube,var/mob/user)
		if(tube.reagents.total_volume < 25)
			user.show_text("The icing tube isn't full enough to frost the cake!","red")
			return
		var/frostingtype
		frostingtype = input("Which frosting style would you like?", "Frosting Style", null) as null|anything in frostingstyles
		if(frostingtype && (BOUNDS_DIST(src, user) == 0))
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
				var/image/frostingoverlay = new /image(src.icon,tag)
				frostingoverlay.color = average.to_rgba()
				frostingoverlay.alpha = 255
				src.UpdateOverlays(frostingoverlay,tag)
				tube.reagents.trans_to(src,25)
				JOB_XP(user, "Chef", 1)

	proc/overlay_number_convert(var/original_clayer,var/mode,var/singlecake) //original - original clayer value, mode - which math we're using
		switch(mode)
			if(CAKE_MODE_STACK)
				if(original_clayer==2) //if the cake is two cakes high now
					. = list(1,2) //replacetext all instances of 1 with 2, updating the first layer overlays with second layer overlays
				else if(original_clayer==3 && singlecake) //if the cake is three cakes high now and the player is adding a single cake to it
					. = list(1,3) //replace all instances of 1 with 3, updating the first layer overlays with third layer overlays
				else //fringe case catch yay math
					. = list(2,3)
			if(CAKE_MODE_BUILD) //same idea, but different math
				if(original_clayer==2)
					. = list(2,1)
				else if(original_clayer==3)
					. = list(3,1)


	proc/slice_cake(var/obj/item/W,var/mob/user)
		if (src.sliced)
			user.show_text("This cake has already been sliced!","red")
			return
		user.show_text("You cut the cake into slices.")
		var/layer_tag //passes layer information to the build_cake function
		var/replacetext //used to change layer identifiers to reformat from cake overlays to slice overlays
		var/obj/item/reagent_containers/food/snacks/cake/s = new /obj/item/reagent_containers/food/snacks/cake //temporary reference item to paste overlays onto child items
		var/candle_lit
		switch(src.clayer) //checking the current layer of the cake
			if(1)
				layer_tag = "first" //the tag of the future overlay
				replacetext = "cake1" //used in replacetext below to assign overlays
			if(2)
				layer_tag = "second"
				replacetext = "cake2"
			if(3)
				layer_tag = "third"
				replacetext = "cake3"

		candle_lit = build_cake(s,user,CAKE_MODE_SLICE,layer_tag,replacetext)

		var/transferamount = (src.reagents.total_volume/CAKE_SLICES)/clayer //amount of reagent to transfer to slices
		var/deletionqueue //is the source cake deleted after slicing?
		if(src.clayer == 1) //qdel(src) if there was only one layer to the cake, otherwise, decrement the layer
			deletionqueue = 1
		else
			src.clayer--
			src.update_cake_context()
		for(var/i in 1 to CAKE_SLICES) //generating child slices of the parent template
			var/obj/item/reagent_containers/food/snacks/cake/schild = new /obj/item/reagent_containers/food/snacks/cake
			schild.icon_state = "slice-base_custom"
			for(var/overlay_ref in s.overlay_refs) //looping through parent overlays and copying them over to the children
				schild.UpdateOverlays(s.GetOverlayImage(overlay_ref), overlay_ref)
			if(cake_candle.len) //making sure there's only one candle :)
				if(candle_lit)
					schild.UpdateOverlays(new /image(src.icon,"slice-candle_lit"),"slice-candle")
					candle_lit = FALSE
				else
					schild.UpdateOverlays(new /image(src.icon,"slice-candle"),"slice-candle")
				schild.cake_candle = cake_candle
				cake_candle = list()
				if(src.litfam) //light update
					src.put_out()
					schild.ignite()
			src.reagents.trans_to(schild,transferamount) //setting up the other properties of the slice
			schild.pixel_x = rand(-6, 6)
			schild.pixel_y = rand(-6, 6)
			for(var/food_effect in src.food_effects)
				schild.food_effects |= food_effect
			schild.w_class = W_CLASS_TINY
			schild.quality = src.quality
			schild.name = "slice of [src.name]"
			schild.desc = "a delicious slice of cake!"
			schild.food_color = src.food_color
			schild.sliced = TRUE
			schild.bites_left = 1

			schild.set_loc(get_turf(src.loc))
		qdel(s) //cleaning up the template slice
		if(deletionqueue)
			qdel(src)



	proc/stack_cake(var/obj/item/reagent_containers/food/snacks/cake/c,var/mob/user)
		if(!(src.clayer<3) || (c.clayer>=3) || (c.sliced))
			return

		user.u_equip(c)
		c.set_loc(user)
		src.clayer++
		src.reagents.maximum_volume += 100
		c.reagents.trans_to(src,c.reagents.total_volume)

		src.cake_bases += c.cake_bases //woooo base sprites

		for(var/food_effect in c.food_effects) //adding food effects to the src that arent already present
			src.food_effects |= food_effect

		var/singlecake //logging the clayer before changing it later
		if(c.clayer == 1)
			singlecake = 1

		if(src.cake_candle.len)	//looking for candles and if you set a cake on top of it, it pops off!
			src.ClearSpecificOverlays("[src.cake_candle[1]]")
			var/candle_path = text2path(src.cake_candle[2])
			var/obj/item/device/light/candle/can = new candle_path
			can.set_loc(get_turf(src.loc))
			user.show_text("<b>The candle pops off! Oh no!</b>","red")
			cake_candle = list()
			if(src.litfam)
				src.put_out()

		for(var/overlay_ref in c.overlay_refs) //the handling for actually adding the toppings to the cake
			if(("[overlay_ref]" == "first") || ("[overlay_ref]" == "second")) //setting up base layer overlay
				var/overlay_layer
				var/src_base //which base sprite are we adding to src?
				if("[overlay_ref]" == "first")
					if(src.clayer == 2)
						overlay_layer = "second"
						src_base = src.cake_bases[2]
					else if(src.clayer == 3)
						overlay_layer = "third"
						src_base = src.cake_bases[3]
				else if("[overlay_ref]" == "second")
					overlay_layer = "third"
					src_base = src.cake_bases[3]
					src.reagents.maximum_volume += 100
					src.clayer++
				var/image/stack
				if(src_base == "base_custom")
					stack = new /image(src.icon,"cake[src.clayer]-base_custom")
					var/image/buffer = c.GetOverlayImage(overlay_ref)
					stack.color = buffer.color
				else
					stack = new /image(src.icon,"cake[src.clayer]-[src_base]")
				src.UpdateOverlays(stack, overlay_layer)
				continue
			var/image/buffer = c.GetOverlayImage("[overlay_ref]") //generating the topping reference from the original cake to be stacked
			var/list/tag
			var/list/newnumbers = c.overlay_number_convert(src.clayer,CAKE_MODE_STACK,singlecake)
			tag = replacetext("[overlay_ref]","[newnumbers[1]]","[newnumbers[2]]")
			if(length(c.cake_candle))
				src.cake_candle = c.cake_candle
				src.cake_candle[1] = replacetext("[c.cake_candle[1]]","[newnumbers[1]]","[newnumbers[2]]")
				c.cake_candle = list()
			var/image/newoverlay = new /image(src.icon,tag)
			if(buffer.color)
				newoverlay.color = buffer.color
			src.UpdateOverlays(newoverlay,tag)
		if(c.litfam)
			src.ignite()
		src.update_cake_context()

		//Complete cake crew objectives if possible
		src.cake_types += c.cake_types
		if (user.mind && user.mind.objectives)
			for (var/datum/objective/crew/chef/cake/objective in user.mind.objectives)
				var/list/matching_types = src.cake_types & objective.choices
				if(length(matching_types) >= CAKE_OBJ_COUNT)
					objective.completed = TRUE
		qdel(c)


	proc/build_cake(var/obj/item/cake_transfer,var/mob/user,var/mode,var/layer_tag,var/replacetext)//cake_transfer : passes a reference to the cake that we are building //layer_tag and replacetext : references used with slicing //decompiles a full cake into slices or other cakes
		if((mode != CAKE_MODE_CAKE) && (mode != CAKE_MODE_SLICE))
			return
		var/normal_topping = FALSE //there are special cases in rendering cake overlays that should only ever trigger once, afterward the toggle is switched to true, initiating the normal topping overlay handling
		var/candle_light //cute little wax stick that people light on fire for their own enjoyment <3
		var/obj/item/reagent_containers/food/snacks/cake/cake
		if(istype(cake_transfer,/obj/item/reagent_containers/food/snacks/cake))
			cake = cake_transfer
		for(var/overlay_ref in src.overlay_refs)
			if(mode == CAKE_MODE_CAKE)
				if("[overlay_ref]" == "base")
					continue
				if(("[overlay_ref]" == "second") || ("[overlay_ref]" == "third"))
					if(("[overlay_ref]" == "second") && (src.clayer == 2))
						normal_topping = TRUE
					else if(("[overlay_ref]" == "third") && (src.clayer == 3))
						normal_topping = TRUE
					if(normal_topping)
						var/image/stack
						if(src.cake_bases[src.clayer]=="base_custom")
							stack = new /image(src.icon,"cake1-base_custom")
							var/image/warningsuppression = src.GetOverlayImage(overlay_ref)
							stack.color = warningsuppression.color
						else
							stack = new /image(src.icon,"cake1-[src.cake_bases[src.clayer]]")
						cake.cake_bases = list(src.cake_bases[src.clayer])
						src.cake_bases.Remove(src.cake_bases[src.clayer])
						cake.UpdateOverlays(stack,"first")
						src.ClearSpecificOverlays("[overlay_ref]")
						continue
				if(normal_topping)
					var/tag
					var/image/buffer = src.GetOverlayImage("[overlay_ref]")
					var/list/newnumbers = src.overlay_number_convert(src.clayer,CAKE_MODE_BUILD)
					tag = replacetext("[overlay_ref]","[newnumbers[1]]","[newnumbers[2]]")
					if(src.cake_candle.len)
						cake.cake_candle = src.cake_candle
						cake.cake_candle[1] = replacetext("[src.cake_candle[1]]","[newnumbers[1]]","[newnumbers[2]]")
						src.cake_candle = list()
					var/image/newoverlay = new /image(src.icon,tag)
					if(buffer.color)
						newoverlay.color = buffer.color
					cake.UpdateOverlays(newoverlay,tag)
					src.ClearSpecificOverlays("[overlay_ref]")
					continue
			else if(mode == CAKE_MODE_SLICE)
				if("[overlay_ref]" == layer_tag) //if it finds the identifying tag for the current layer (base,second,third) it flips the toggle and starts pulling overlays
					normal_topping = TRUE
					var/image/slice_base
					if(src.cake_bases[src.clayer]=="base_custom")
						slice_base = new /image(src.icon,"slice-base_custom")
						var/image/buffer = src.GetOverlayImage("[overlay_ref]")
						if(buffer.color)
							slice_base.color = buffer.color
					else
						slice_base = new /image(src.icon,"slice-[src.cake_bases[src.clayer]]")
						src.cake_bases.Remove(src.cake_bases[src.clayer])
					cake.UpdateOverlays(slice_base,"first") //setting the base overlay of the temporary slice object
					src.ClearSpecificOverlays(layer_tag)
					continue
				if(normal_topping) //after setting the base layer, all subsequent overlays are registered as toppings and applied to the slice
					var/image/buffer = src.GetOverlayImage("[overlay_ref]")
					var/toppingpath = replacetext("[overlay_ref]","[replacetext]","slice")

					if((toppingpath == "slice-candle")) //special case for candles :D
						if(litfam)
							candle_light = TRUE
						else
							candle_light = FALSE
						src.ClearSpecificOverlays("[overlay_ref]")
						continue

					var/image/toppingimage = new /image(src.icon,toppingpath)
					if(buffer.color)
						toppingimage.color = buffer.color
					cake.UpdateOverlays(toppingimage,toppingpath)
					src.ClearSpecificOverlays("[overlay_ref]")
			else
				break

		src.reagents.maximum_volume -= 100
		if(mode == CAKE_MODE_SLICE)
			return candle_light
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
			src.firesource = FIRESOURCE_OPEN_FLAME
			src.litfam = TRUE
			src.hit_type = DAMAGE_BURN
			src.force = 3
			src.add_simple_light("cake_light", list(0.5*255, 0.3*255, 0, 100))
			processing_items |= src
			src.update_cake_context()
		else
			return

		if(src.sliced && src.GetOverlayImage("slice-candle"))
			src.UpdateOverlays(image(src.icon,"slice-candle_lit"), "slice-candle")
		else if(src.GetOverlayImage("cake[src.clayer]-candle"))
			src.UpdateOverlays(image(src.icon,"cake[src.clayer]-candle_lit"), "cake[src.clayer]-candle")


	proc/put_out(var/mob/user as mob)
		if (!src) return
		if (src.litfam)
			src.firesource = FALSE
			src.litfam = FALSE
			hit_type = DAMAGE_BLUNT
			src.force = 0
			src.remove_simple_light("cake_light")
			processing_items -= src
			src.update_cake_context()

	/*__________________*/
	/*Context Actions :D*/
	/*‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/

	proc/update_cake_context()
		src.cakeActions = list()

		var/pickup = FALSE
		if(clayer > 1)
			cakeActions += new /datum/contextAction/cake/unstack
			pickup = TRUE
		if(litfam)
			cakeActions += new /datum/contextAction/cake/candle
			pickup = TRUE
		if(pickup)
			cakeActions += new /datum/contextAction/cake/pickup

	proc/unstack(var/mob/user)
		var/obj/item/reagent_containers/food/snacks/cake/s = new /obj/item/reagent_containers/food/snacks/cake

		src.reagents.trans_to(s,(src.reagents.total_volume/src.clayer))
		for(var/food_effect in src.food_effects)
			s.food_effects |= food_effect
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
		if(src.sliced && src.litfam)
			src.UpdateOverlays(new /image(src.icon,"slice-candle"), "slice-candle")
			blowout = TRUE
		else if(litfam)
			src.UpdateOverlays(new /image(src.icon,"cake[src.clayer]-candle"), "cake[src.clayer]-candle")
			blowout = TRUE
		if(blowout)
			src.put_out()
			user.visible_message("<b>[user.name]</b> blows out the candle!")

	attackby(obj/item/W, mob/user) //ok this proc is entirely a mess, but its *hopfully* better on the server than the alternatives
		if(istool(W, TOOL_CUTTING | TOOL_SAWING))
			if(!src.sliced)
				slice_cake(W,user)
				return
			else
				..()
		else if(isspooningtool(W))
			if(!src.sliced)
				return
			else
				..()
		else if(istype(W,/obj/item/reagent_containers/food/drinks/drinkingglass/icing))
			frost_cake(W,user)
			return
		else if(istype(W,/obj/item/reagent_containers/food/snacks/cake))
			stack_cake(W,user)
			return
		else if(cake_candle.len && !(litfam) && (W.firesource))
			src.ignite()
			W.firesource_interact()
			return
		else
			var/list/topping = check_for_topping(W) //if the item used on the cake wasn't handled previously, check for valid toppings next
			if(!topping[1]) //if the item wasn't a valid topping, perfom the default action
				return ..()

			//adding topping overlays to the cake. Yay :D
			if(src.sliced) //if you add a topping to a sliced cake, it updates the icon_state to the sliced version.
				topping[1] = replacetext(topping[1],"cake[clayer]","slice")
			if(topping[1]) //actually adding the topping overlay to the cake
				var/image/toppingoverlay = new /image(src.icon,topping[1])
				toppingoverlay.alpha = 255
				if(topping[2])
					toppingoverlay.color = topping[2]
				src.UpdateOverlays(toppingoverlay,topping[1])
				user.u_equip(W)
				if(istype(W,/obj/item/device/light/candle))
					var/obj/item/device/light/candle/candle = W
					if(candle.on)
						src.ignite()
				qdel(W)

	attack_hand(mob/user)
		if(length(cakeActions))
			user.showContextActions(cakeActions, src)
		else
			..()

	attack_self(mob/user)
		if(src.sliced)
			..()
		else
			return


	attack(mob/M, mob/user, def_zone) //nom nom nom
		if(!src.sliced)
			if(user == M)
				user.show_text("You can't just cram that in your mouth, you greedy beast!","red")
				user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
				return
			else
				user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
				return
		else
			..()

/obj/item/reagent_containers/food/snacks/b_cupcake
	name = "birthday cupcake"
	desc = "A little birthday cupcake for a bee. May not taste good to non-bees. This doesn't seem to be homemade; maybe that's why it looks so generic."
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	icon_state = "b_cupcake"
	bites_left = 4
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
	heal_amt = 2
	initial_volume = 50
	initial_reagents = list("sugar"=30)

	New()
		..()
		UpdateOverlays(new /image(src.icon,"cake1-base_cream"),"first")
		cake_bases = list("base_cream")

/obj/item/reagent_containers/food/snacks/cake/chocolate
	name = "chocolate cake"
	desc = "Mmm! A delicious-looking chocolate sponge cake!"
	heal_amt = 3
	initial_volume = 50
	initial_reagents = "chocolate"

	New()
		..()
		UpdateOverlays(new /image(src.icon,"cake1-base_gateau"),"first")
		cake_bases = list("base_gateau")

/obj/item/reagent_containers/food/snacks/cake/chocolate/gateau
	name = "Extravagant Chocolate Gateau"
	desc = "Holy shit! This cake probably costs more than the gross domestic product of Bulgaria!"

	New()
		..()
		UpdateOverlays(new /image(src.icon,"cake1-base_gateau"),"first")
		UpdateOverlays(new /image(src.icon,"cake1-cherry"),"cake1-cherry")
		UpdateOverlays(new /image(src.icon,"cake2-base_gateau"),"second")
		UpdateOverlays(new /image(src.icon,"cake2-cherry"),"cake2-cherry")
		UpdateOverlays(new /image(src.icon,"cake3-base_gateau"),"third")
		UpdateOverlays(new /image(src.icon,"cake3-cherry"),"cake3-cherry")
		UpdateOverlays(new /image(src.icon,"cake3-strawberry"),"cake3-strawberry")
		cake_bases = list("base_gateau","base_gateau","base_gateau")
		clayer = 3
		update_cake_context()

/obj/item/reagent_containers/food/snacks/cake/meat
	name = "meat cake"
	desc = "Uh... well... wow. What is this?"
	var/hname = ""
	var/job = null
	heal_amt = 3
	initial_volume = 50
	initial_reagents = "blood"

	New()
		..()
		UpdateOverlays(new /image(src.icon,"cake1-base_meat"),"first")
		cake_bases = list("base_meat")

/obj/item/reagent_containers/food/snacks/cake/bacon
	name = "bacon cake"
	desc = "This...this is just terrible."
	heal_amt = 4
	initial_volume = 250
	initial_reagents = "porktonium"

	New()
		..()
		UpdateOverlays(new /image(src.icon,"cake1-base_bacon"),"first")
		cake_bases = list("base_bacon")

/obj/item/reagent_containers/food/snacks/cake/true_bacon
	name = "True Bacon (TM)"
	desc = "this bacon is too dense for the universe to contain..."
	initial_reagents = list("badgrease"=20,"msg"=40)

	New()
		..()
		UpdateOverlays(new /image(src.icon,"cake1-base_true"),"first")
		cake_bases = list("base_true")
		food_effects.Add("food_fireburp")
		food_effects.Add("food_deep_burp")

#ifdef XMAS

/obj/item/reagent_containers/food/snacks/fruit_cake
	name = "fruitcake"
	desc = "The most disgusting dessert ever devised. Legend says there's only one of these in the galaxy, passed from location to location by vengeful deities."
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	icon_state = "cake_fruit"
	bites_left = 12
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

/obj/item/cake_item
	name = "cream sponge cake"
	desc = "Mmm! A delicious-looking cream sponge cake! There's a lump in it..."
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	icon_state = "cake1-base_cream"

/obj/item/cake_item/attack(target, mob/user)
	var/iteminside = length(src.contents)
	if(!iteminside)
		user.show_text("The cake crumbles away!","red")
		qdel(src)
	user.show_text("You bite down on something odd! You open up the cake...","red")
	for(var/obj/item/I in src.contents)
		I.set_loc(user.loc)
		I.add_fingerprint(user)
	qdel(src)
	return
