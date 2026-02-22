
/obj/item/storage/box/glassbox
	name = "glassware box"
	icon_state = "glassware"
	desc = "A box with glass cups for drinking liquids from."
	spawn_contents = list(/obj/item/reagent_containers/food/drinks/drinkingglass = 7)

/obj/item/storage/box/glassbox/syndie
	name = "glassware box"
	icon_state = "glassware"
	desc = "A box with glass cups for drinking liquids from."
	spawn_contents = list(/obj/item/reagent_containers/food/drinks/drinkingglass/shot/syndie = 7)

/obj/item/storage/box/cutlery
	name = "cutlery set"
	icon_state = "cutlery"
	desc = "Knives, forks, and spoons."
	spawn_contents = list(/obj/item/kitchen/utensil/fork = 2,\
	/obj/item/kitchen/utensil/knife = 2,\
	/obj/item/kitchen/utensil/spoon = 2)

/obj/item/storage/box/plates
	name = "dinnerware box"
	icon_state = "dinnerware"
	desc = "A box with some plates and bowls."
	spawn_contents = list(/obj/item/plate = 4,\
	/obj/item/reagent_containers/food/drinks/bowl = 3)

/obj/item/storage/box/donkpocket_kit
	name = "\improper Donk-Pockets box"
	desc = "Remember to fully heat prior to serving.  Product will cool if not eaten within seven minutes."
	icon_state = "donk_kit"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box-red"
	spawn_contents = list(/obj/item/reagent_containers/food/snacks/donkpocket = 7)

/obj/item/storage/box/bacon_kit
	name = "bacon strips"
	desc = "A box of Farmer Jeff brand uncooked bacon strips."
	icon_state = "bacon"
	spawn_contents = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw = 7)

/obj/item/storage/box/sushi_box
	name = "sushi box"
	desc = "A box full of supplies for crafting sushi!"
	icon_state = "sushibox"
	spawn_contents = list(/obj/item/kitchen/sushi_roller,/obj/item/reagent_containers/food/snacks/ingredient/seaweed=3,/obj/item/reagent_containers/food/snacks/ingredient/rice = 3)

/obj/item/storage/box/cookie_tin
	name = "cookie tin"
	desc = "Full of fresh cookies, picked ripe from the Danish cookie farms in Space Denmark."
	icon_state = "cookie_tin"
	spawn_contents = list(/obj/item/reagent_containers/food/snacks/cookie/butter = 7)

/obj/item/storage/box/cookie_tin/sugar
	spawn_contents = list(/obj/item/reagent_containers/food/snacks/cookie = 7)

/obj/item/storage/box/stroopwafel_tin
	name = "stroopwafel bag"
	desc = "Full of fresh Dutch stroopwafels, picked ripe from the Dutch stroopwafel trees in Space Holland. There apears to be a lable on the back saying something about microwaves, the rest is in Dutch."
	icon_state = "cookie_tin"
	spawn_contents = list(/obj/item/reagent_containers/food/snacks/stroopwafel = 7)

/obj/item/storage/box/beer
	name = "beer in a box"
	icon_state = "beer"
	desc = "It's some beer, conveniently stored in a box! Dang!"
	spawn_contents = list(/obj/item/reagent_containers/food/drinks/bottle/fancy_beer = 6)

/obj/item/storage/box/cocktail_umbrellas
	name = "cocktail umbrella box"
	icon_state = "umbrellas"
	desc = "Ooh, little tiny umbrellas! Wow!"
	spawn_contents = list(/obj/item/cocktail_stuff/drink_umbrella = 7)

/obj/item/storage/box/cocktail_doodads
	name = "cocktail doodad box"
	icon_state = "doodads"
	desc = "Some neat stuff to put in fancy drinks. Woah!"
	spawn_contents = list(/obj/item/cocktail_stuff/maraschino_cherry = 2,\
	/obj/item/cocktail_stuff/cocktail_olive = 2,\
	/obj/item/cocktail_stuff/celery = 2)

/obj/item/storage/box/fruit_wedges
	name = "fruit wedge kit"
	icon_state = "wedges"
	desc = "All you need to make fruit wedges to put on drinks, for extra fanciness. Gosh!"
	spawn_contents = list(/obj/item/reagent_containers/food/snacks/plant/orange,\
	/obj/item/reagent_containers/food/snacks/plant/lemon,\
	/obj/item/reagent_containers/food/snacks/plant/lime,\
	/obj/item/kitchen/utensil/knife)

/obj/item/storage/box/ic_cones
	name = "ice cream cone box"
	icon_state = "ic_cones"
	desc = "A box full of delicious ice cream cones, a brittle pastry in a convenient hollow \
	 cone shape. When held, the cone provides an insulative, absorbent, and edible layer between \
	 the holder's hands and the ice cream (with a temperature difference of about 30C), \
	 allowing the ice cream to be eaten in comfort without worry of accelerated melting, \
	 or sticky hands. Because of this ease of use, as well as the precarious position \
	 that the often overfilled cones hold the ice cream in, ice cream stored in this\
	 way is often eaten without the help of utensils, such as spoons. The edibility\
	 of the cone solves logistical issues with discarded packaging, and provides a \
	 new texture to the classic treat that many eaters find quite delightful. \
	 All in all, if you're looking to serve some ice cream, the humble ice cream \
	 cone is the premier choice for carrying your ice cream!"
	spawn_contents = list(/obj/item/reagent_containers/food/snacks/ice_cream_cone = 7)

/obj/item/storage/box/butter
	name = "butter tray"
	icon_state = "buttertray"
	desc = "A homely little tray for keeping butter fresh."
	spawn_contents = list(/obj/item/reagent_containers/food/snacks/ingredient/butter = 5)

/obj/item/storage/box/cheese
	name = "cheese box"
	icon_state = "cheesebox"
	desc = "A cheap box for storing cheese."

	make_my_stuff()
		..()
		var/made_sponge = FALSE
		for (var/i = 1 to src.storage.slots)
			if(prob(5) && !made_sponge)
				src.storage.add_contents(new /obj/item/sponge/cheese(src))
				made_sponge = TRUE
			else
				src.storage.add_contents(new /obj/item/reagent_containers/food/snacks/ingredient/cheese(src))

/obj/item/storage/goodybag
	name = "goodybag"
	desc = "A bag designed to store Halloween candy."
	icon_state = "goodybag"

	make_my_stuff()
		..()
		var/list/candytypes = concrete_typesof(/obj/item/reagent_containers/food/snacks/candy)
		for (var/i=6, i>0, i--)
			var/newcandy_path = pick(candytypes)
			var/obj/item/reagent_containers/food/snacks/candy/newcandy = new newcandy_path(src)
			src.storage.add_contents(newcandy)
			if (prob(5))
				newcandy.has_razor_blade = TRUE

/obj/item/storage/box/popsicles
	name = "popsicles"
	desc = "A box of generic unbranded popsicles."
	icon_state = "popsiclebox"
	spawn_contents = list(/obj/item/popsicle = 7)

/obj/item/storage/box/popsicle_sticks
	name = "popsicle sticks"
	desc = "A box of popsicle sticks, used for making various kinds of sweets."
	icon_state = "sticks"
	spawn_contents = list(/obj/item/stick = 7)
