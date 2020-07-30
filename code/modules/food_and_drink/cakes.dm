
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
	initial_volume = 100
	w_class = 4.0
	var/sliced = 0
	var/list/frostingstyles = list("classic","top swirls","bottom swirls","spirals","rose spirals")
	var/clayer = 1
	var/amount2 //holds the amount of slices in cake 2 (not entirely, but its used for a bit of math later)
	var/amount3 //same for cake 3
	var/litfam //is the cake lit (candle)
	var/datum/light/light

	//Light stuffs :D
	New()
		..()
		light = new /datum/light/point
		light.set_brightness(0.8)
		light.set_color(0.5, 0.3, 0)
		light.attach(src)

	pickup(mob/user)
		..()
		light.attach(user)

	dropped(mob/user)
		..()
		SPAWN_DBG(0)
			if (src.loc != user)
				light.attach(src)

	proc/light(var/mob/user as mob, var/message as text)
		if (!src)
			return
		if (!src.litfam)
			src.litfam = 1
			src.hit_type = DAMAGE_BURN
			src.force = 3
			light.enable()
			if (!(src in processing_items))
				processing_items.Add(src)

			for(var/i=1,i<=src.overlays.len,i++) //searching for an unlit candle overlay, updating it, the enabling the light
				if(src.sliced && ("[src.overlay_refs[i]]" == "slice-candle"))
					src.ClearSpecificOverlays("[src.overlay_refs[i]]")
					src.UpdateOverlays(new /image('icons/obj/foodNdrink/food_dessert.dmi',"slice-candle_lit"), "slice-candle_lit")
					break
				if("[src.overlay_refs[i]]" == "cake[src.clayer]-candle")
					src.ClearSpecificOverlays("[src.overlay_refs[i]]")
					src.UpdateOverlays(new /image('icons/obj/foodNdrink/food_dessert.dmi',"cake[src.clayer]-candle_lit"), "cake[src.clayer]-candle_lit")
					break
		return

	proc/put_out(var/mob/user as mob)
		if (!src) return
		if (src.litfam)
			src.litfam = 0
			hit_type = DAMAGE_BLUNT
			src.force = 0
			light.disable()
			if (src in processing_items)
				processing_items.Remove(src)
		return

	attackby(obj/item/W as obj, mob/user as mob) //ok this proc is entirely a mess, but its *hopfully* better on the server than the alternatives
		var/topping //the topping the player is adding (stored as a string reference to an icon_state)
		var/pendinglight //a variable referenced later to check if the light source on a cake needs to be updated
		if(istool(W, TOOL_CUTTING | TOOL_SAWING))
			if (src.sliced == 1)
				boutput(user, "<span class='alert'>This has already been sliced.</span>")
				return
			boutput(user, "<span class='notice'>You cut the cake into slices.</span>")
			var/layer_tag
			var/replacetext
			var/obj/item/reagent_containers/food/snacks/cake/custom/s = new /obj/item/reagent_containers/food/snacks/cake/custom //temporary reference item to paste overlays onto child items
			var/slices
			var/candle //cute little wax stick that people light on fire for their own enjoyment <3
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
			var/staticiterator = src.overlays.len //declaring the length of the for loop outside the loop as a variable for removing elements from a list while iterating through it
			var/toggleswitch //a trigger variabe that tells the for loop when to start doing the overlay layer_tag when it reaches the current cake layer
			for(var/i=1,i<=staticiterator,i++)
				if("[src.overlay_refs[i]]" == layer_tag) //if it finds the identifying tag for the current layer (base,second,third) it flips the toggle and starts pulling overlays
					toggleswitch = 1
					var/image/buffer = src.GetOverlayImage("[src.overlay_refs[i]]")
					var/image/slicecolor = new /image('icons/obj/foodNdrink/food_dessert.dmi',"slice-overlay")
					if(buffer.color)
						slicecolor.color = buffer.color
					s.UpdateOverlays(slicecolor,"base") //setting the base overlay of the temporary slice object
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
							src.ClearSpecificOverlays("[src.overlay_refs[i]]")
							staticiterator--
							i--
						continue
					var/image/toppingimage = new /image('icons/obj/foodNdrink/food_dessert.dmi',"[toppingpath]")
					if(buffer.color)
						toppingimage.color = buffer.color
					s.UpdateOverlays(toppingimage,toppingpath)
					src.ClearSpecificOverlays("[src.overlay_refs[i]]")
					staticiterator--
					i--

			if(src.amount > 10) //math for making sure there isnt any amount duplication within cakes as people stack, unstack, and slice
				src.amount -= 10
				switch(src.clayer)
					if(2)
						src.amount2 = 0
					if(3)
						src.amount3 = 0
				slices = 10
			else if(src.clayer == 1)
				slices = src.amount
			else
				qdel(s)
				boutput(user, "<span style=\"color:red\"><b>OH NO! The cake was a lie!</b></span>")
				src.clayer--
				src.reagents.maximum_volume -= 100
				return
			src.reagents.maximum_volume -= 100

			var/transferamount = (src.amount/src.clayer)/slices //amount of reagent to transfer to slices
			for(var/i=1,i<=slices,i++) //generating child slices of the parent template
				var/obj/item/reagent_containers/food/snacks/cake/custom/schild = new /obj/item/reagent_containers/food/snacks/cake/custom
				schild.icon_state = "slice-overlay"
				for(var/i2=1,i2<=s.overlays.len,i2++) //looping through parent overlays and copying them over to the children
					schild.UpdateOverlays(s.GetOverlayImage("[s.overlay_refs[i2]]"),"[s.overlay_refs[i2]]")
				if(candle) //making sure there's only one candle :)
					if(candle == 1)
						schild.UpdateOverlays(new /image('icons/obj/foodNdrink/food_dessert.dmi',"slice-candle"),"slice-candle")
					if(candle == 2)
						schild.UpdateOverlays(new /image('icons/obj/foodNdrink/food_dessert.dmi',"slice-candle_lit"),"slice-candle_lit")
					candle = 0
					if(src.litfam) //light update
						src.put_out()
						schild.light()
				src.reagents.trans_to(schild,transferamount) //setting up the other properties of the slice
				schild.pixel_x = rand(-6, 6)
				schild.pixel_y = rand(-6, 6)
				for(var/b=1,b<=src.food_effects.len,b++)
					if(src.food_effects[b] in schild.food_effects)
						continue
					schild.food_effects += src.food_effects[b]
				schild.w_class = 1
				schild.quality = src.quality
				schild.name = "slice of [src.name]"
				schild.desc = "a delicious slice of cake!"
				schild.food_color = src.food_color
				schild.sliced = 1
				schild.amount = 1

				schild.set_loc(get_turf(src.loc))
			qdel(s) //cleaning up the template slice
			if(src.clayer == 1) //qdel(src) if there was only one layer to the cake, otherwise, decrement the layer
				qdel(src)
			else
				src.clayer--
			return
		else if((!(src.litfam)) && (((istype(W,/obj/item/weldingtool) && W:welding)) || (istype(W, /obj/item/device/igniter))) || \
		(((istype(W, /obj/item/match)) || (istype(W, /obj/item/device/light/candle)) || (istype(W, /obj/item/clothing/head/cakehat)) || (istype(W, /obj/item/device/light/zippo))) && (W:on))) //we don't talk about this......
			src.light() //so basically...if the cake doesnt have a light source AND ([the weapon is a welding tool and on, or an igniter] OR [its a bunch of other things AND those things are on])

		switch(W.type) //this is where the mess starts...
			if(/obj/item/reagent_containers/food/drinks/drinkingglass/icing) //handling for frosting overlays. they have a color, so theyre handled a bit differently
				if(!(W.reagents.total_volume >= 25))
					boutput(user, "<span style=\"color:red\">The icing tube isn't full enough to frost the cake!</span>")
					return
				var/frostingtype
				frostingtype = input("Which frosting style would you like?", "Frosting Style", null) as null|anything in frostingstyles
				if(frostingtype && (user in range(1,src)))
					var/overlaytype
					var/datum/color/average = W.reagents.get_average_color()
					switch(frostingtype)
						if("classic")
							overlaytype = "cake[clayer]-classic"
						if("top swirls")
							overlaytype = "cake[clayer]-swirl_top"
						if("bottom swirls")
							overlaytype = "cake[clayer]-swirl_bottom"
						if("spirals")
							overlaytype = "cake[clayer]-spiral"
						if("rose spirals")
							overlaytype = "cake[src.clayer]-spiral_rose"
					if(!src.GetOverlayImage("[overlaytype]"))
						if(src.sliced)
							overlaytype = replacetext("[overlaytype]","cake[clayer]","slice")
						var/image/frostingoverlay = new /image('icons/obj/foodNdrink/food_dessert.dmi',"[overlaytype]")
						frostingoverlay.color = average.to_rgba()
						frostingoverlay.alpha = 255
						src.UpdateOverlays(frostingoverlay,"[overlaytype]")
						W.reagents.trans_to(src,25)
						return
					else
						return
				else
					return
			if(/obj/item/reagent_containers/food/snacks/condiment/chocchips) //checks for general toppings
				topping = "cake[clayer]-chocolate"
			if(/obj/item/reagent_containers/food/snacks/ingredient/sugar)
				topping = "cake[clayer]-sprinkles"
			if(/obj/item/reagent_containers/food/snacks/plant/cherry)
				topping = "cake[clayer]-cherry"
			if(/obj/item/cocktail_stuff/maraschino_cherry)
				topping = "cake[clayer]-cherry"
			if(/obj/item/reagent_containers/food/snacks/plant/orange/wedge)
				topping = "cake[clayer]-orange"
			if(/obj/item/reagent_containers/food/snacks/plant/lemon/wedge)
				topping = "cake[clayer]-lemon"
			if(/obj/item/reagent_containers/food/snacks/plant/lime/wedge)
				topping = "cake[clayer]-lime"
			if(/obj/item/reagent_containers/food/snacks/plant/strawberry)
				topping = "cake[clayer]-strawberry"
			if(/obj/item/device/light/candle) //special handling for candles because they need to send light source information
				var/obj/item/device/light/candle/candle = W
				if(candle.on)
					pendinglight = 1
					topping = "cake[clayer]-candle_lit"
				else
					topping = "cake[clayer]-candle"
			if(/obj/item/device/light/candle/small)
				var/obj/item/device/light/candle/small/candle = W
				if(candle.on)
					pendinglight = 1
					topping = "cake[clayer]-candle_lit"
				else
					topping = "cake[clayer]-candle"
			if(/obj/item/reagent_containers/food/snacks/cake/custom) //cake stacking
				if(src.clayer<3)
					var/obj/item/reagent_containers/food/snacks/cake/custom/c = W
					if(c.sliced)
						return
					if(c.clayer>=3)
						return
					user.u_equip(c)
					c.set_loc(user)

					src.clayer++
					src.reagents.maximum_volume += 100
					src.amount += 10
					c.reagents.trans_to(src,c.reagents.total_volume)

					for(var/i=1,i<=c.food_effects.len,i++) //adding food effects to the src that arent already present
						if(c.food_effects[i] in src.food_effects)
							continue
						src.food_effects += c.food_effects[i]

					var/singlecake //logging the clayer before changing it later
					if(c.clayer == 1)
						singlecake = 1

					for(var/i=1,i<=src.overlays.len,i++) //looking for candles and if you set a cake on top of it, it pops off!
						if(("[src.overlay_refs[i]]" == "cake[(src.clayer)-1]-candle") || ("[src.overlay_refs[i]]" == "cake[(src.clayer)-1]-candle_lit") || ("[src.overlay_refs[i]]" == "cake[(src.clayer)-2]-candle") || ("[src.overlay_refs[i]]" == "cake[(src.clayer)-2]-candle_lit"))
							src.ClearSpecificOverlays("[src.overlay_refs[i]]")
							var/obj/item/device/light/candle/can = new /obj/item/device/light/candle/small
							can.set_loc(get_turf(src.loc))
							boutput(user,"<span style=\"color:red\"><b>The candle pops off! Oh no!</b></span>")
							if(src.litfam)
								src.put_out()
							break

					var/staticiterator = c.overlays.len
					for(var/i=1,i<=staticiterator,i++) //the handling for actually adding the toppings to the cake
						if(("[c.overlay_refs[i]]" == "base") || ("[c.overlay_refs[i]]" == "second")) //setting up base layer overlay
							var/overlay_layer
							if("[c.overlay_refs[i]]" == "base")
								if(src.clayer == 2)
									overlay_layer = "second"
									src.amount2 = c.amount
								else if(src.clayer == 3)
									overlay_layer = "third"
									src.amount3 = c.amount
							else if("[c.overlay_refs[i]]" == "second")
								overlay_layer = "third"
								src.amount3 = c.amount
								src.clayer++
								src.reagents.maximum_volume += 100
								src.amount += 10
							var/image/stack = new /image('icons/obj/foodNdrink/food_dessert.dmi',"cake[src.clayer]-overlay")
							stack.color = (c.GetOverlayImage(c.overlay_refs[i])).color
							src.UpdateOverlays(stack,"[overlay_layer]")
							continue
						var/image/buffer = c.GetOverlayImage("[c.overlay_refs[i]]") //generating the topping reference from the original cake to be stacked
						var/list/tag
						if(src.clayer == 2)
							tag = replacetext("[c.overlay_refs[i]]","1","2")
						else if(src.clayer == 3 && singlecake)
							tag = replacetext("[c.overlay_refs[i]]","1","3")
						else
							tag = replacetext("[c.overlay_refs[i]]","2","3")
						var/image/newoverlay = new /image('icons/obj/foodNdrink/food_dessert.dmi',"[tag]")
						if(buffer.color)
							newoverlay.color = buffer.color
						src.UpdateOverlays(newoverlay,"[tag]")
					if(c.litfam)
						src.light()
					qdel(c)
				else
					return
		if(src.sliced) //if you add a topping to a sliced cake, it updates the icon_state to the sliced version :)
			topping = replacetext("[topping]","cake[clayer]","slice")
		if(topping && !(src.GetOverlayImage("[topping]"))) //actually adding the topping overlay to the cake
			var/image/toppingoverlay = new /image('icons/obj/foodNdrink/food_dessert.dmi',"[topping]")
			toppingoverlay.alpha = 255
			src.UpdateOverlays(toppingoverlay,"[topping]")
			user.u_equip(W)
			qdel(W)
			if(pendinglight)
				src.light()
			return
		else
			..()

	attack_hand(mob/user as mob)
		if((user.a_intent == INTENT_GRAB) && (src.clayer >1)) //removing layers from cakes. most of the code is similar to slicing, but its unique enough to remain separate
			var/obj/item/reagent_containers/food/snacks/cake/custom/s = new /obj/item/reagent_containers/food/snacks/cake/custom

			var/switchtoggle
			var/staticiterator = src.overlays.len
			src.reagents.trans_to(s,(src.reagents.total_volume/3))
			for(var/i=1,i<=src.food_effects.len,i++)
				if(src.food_effects[i] in s.food_effects)
					continue
				s.food_effects += src.food_effects[i]
			s.quality = src.quality
			s.food_color = src.food_color
			for(var/i=1,i<=staticiterator,i++)
				if("[src.overlay_refs[i]]" == "base")
					continue
				if(("[src.overlay_refs[i]]" == "second") || ("[src.overlay_refs[i]]" == "third"))
					if(("[src.overlay_refs[i]]" == "second") && (src.clayer == 2))
						switchtoggle = 1
						s.amount = src.amount2
						src.amount2 = 0
					else if(("[src.overlay_refs[i]]" == "third") && (src.clayer == 3))
						switchtoggle = 1
						s.amount = src.amount3
						src.amount3 = 0
					if(switchtoggle)
						var/image/stack = new /image('icons/obj/foodNdrink/food_dessert.dmi',"cake1-overlay")
						stack.color = (src.GetOverlayImage(src.overlay_refs[i])).color
						s.UpdateOverlays(stack,"base")
						src.ClearSpecificOverlays("[src.overlay_refs[i]]")
						staticiterator--
						i--
						continue
				if(!switchtoggle)
					continue
				var/tag
				var/image/buffer = src.GetOverlayImage("[src.overlay_refs[i]]")
				if(src.clayer == 2)
					tag = replacetext("[src.overlay_refs[i]]","2","1")
				else if(src.clayer == 3)
					tag = replacetext("[src.overlay_refs[i]]","3","1")
				var/image/newoverlay = new /image('icons/obj/foodNdrink/food_dessert.dmi',"[tag]")
				if(buffer.color)
					newoverlay.color = buffer.color
				s.UpdateOverlays(newoverlay,"[tag]")
				src.ClearSpecificOverlays("[src.overlay_refs[i]]")
				staticiterator--
				i--

			if(src.amount > 10)
				s.amount = 10
				src.amount -= 10
				switch(src.clayer)
					if(2)
						src.amount2 = 0
					if(3)
						src.amount3 = 0
			else
				qdel(s) //this will happen if someone eats a cake without slicing it and the amount math has to recalculate past an entire layer (i.e. someone takes 11 bites)
				boutput(user, "<span style=\"color:red\"><b>OH NO! The cake was a lie!</b></span>")
				src.clayer--
				src.reagents.maximum_volume -= 100
				return
			src.clayer--
			src.reagents.maximum_volume -= 100

			if(istype(user,/mob/living/carbon/human))
				user.put_in_hand_or_drop(s)
			else
				s.set_loc(get_turf(user))
			if(src.litfam)
				src.put_out()
				s.light()
		else if(user.a_intent == INTENT_DISARM) //blowing out candles
			//check for candle
			var/blowout
			var/staticiterator = src.overlays.len
			for(var/i=1,i<=staticiterator,i++)
				if(src.sliced && ("[src.overlay_refs[i]]" == "slice-candle_lit"))
					src.ClearSpecificOverlays("[src.overlay_refs[i]]")
					src.UpdateOverlays(new /image('icons/obj/foodNdrink/food_dessert.dmi',"slice-candle"), "slice-candle")
					blowout = 1
					break
				if("[src.overlay_refs[i]]" == "cake[src.clayer]-candle_lit")
					src.ClearSpecificOverlays("[src.overlay_refs[i]]")
					var/tag = "cake[src.clayer]-candle"
					src.UpdateOverlays(new /image('icons/obj/foodNdrink/food_dessert.dmi',tag), tag)
					blowout = 1
					break
			if(blowout)
				src.put_out() //tab in
				user.visible_message("<b>[user.name]</b> blows out the candle!")
			else
				..()
		else
			..()

	attack(mob/M as mob, mob/user as mob, def_zone) //nom nom nom
		if (!src.sliced)
			if (user == M)
				boutput(user, "<span class='alert'>You can't just cram that in your mouth, you greedy beast!</span>")
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
		boutput(eater, "<span class='alert'>It's so hard it breaks one of your teeth AND it tastes disgusting! Why would you ever eat this?</span>")
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

/obj/item/reagent_containers/food/snacks/cake/downs
	name = "droopy cake"
	desc = "This cake looks all weird and droopy."
	icon_state = "cake_downs"
	amount = 12
	heal_amt = 4
	initial_volume = 250
	initial_reagents = "downbrosia"

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
		boutput(user, "<span class='alert'>The cake crumbles away!</span>")
		qdel(src)
	boutput(user, "<span class='notice'>You bite down on something odd! You open up the cake...</span>")
	for(var/obj/item/I in src.contents)
		I.set_loc(user.loc)
		I.add_fingerprint(user)
	qdel(src)
	return
