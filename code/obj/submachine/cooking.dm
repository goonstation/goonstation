/obj/submachine/chef_sink
	name = "kitchen sink"
	desc = "A water-filled unit intended for cookery purposes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "sink"
	anchored = 1
	density = 1
	mats = 12
	deconstruct_flags = DECON_WRENCH | DECON_WELDER
	flags = NOSPLASH

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/flour))
			user.show_text("You add water to the flour to make dough!", "blue")
			if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/flour/semolina))
				new /obj/item/reagent_containers/food/snacks/ingredient/dough/semolina(src.loc)
			else
				new /obj/item/reagent_containers/food/snacks/ingredient/dough(src.loc)
			qdel (W)
		else if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/rice))
			user.show_text("You add water to the rice to make sticky rice!", "blue")
			new /obj/item/reagent_containers/food/snacks/ingredient/sticky_rice(src.loc)
			qdel(W)
		else if (istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/) || istype(W, /obj/item/reagent_containers/balloon/) || istype(W, /obj/item/soup_pot))
			var/fill = W.reagents.maximum_volume
			if (W.reagents.total_volume >= fill)
				user.show_text("[W] is too full already.", "red")
			else
				fill -= W.reagents.total_volume
				W.reagents.add_reagent("water", fill)
				user.show_text("You fill [W] with water.", "blue")
				playsound(src.loc, 'sound/misc/pourdrink.ogg', 100, 1)
		else if (istype(W, /obj/item/mop)) // dude whatever
			var/fill = W.reagents.maximum_volume
			if (W.reagents.total_volume >= fill)
				user.show_text("[W] is too wet already.", "red")
			else
				fill -= W.reagents.total_volume
				W.reagents.add_reagent("water", fill)
				user.show_text("You wet [W].", "blue")
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
		else if (istype(W, /obj/item/grab))
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
			user.visible_message("<span class='notice'>[user] dunks [W:affecting]'s head in the sink!</span>")
		else if (W.burning)
			W.combust_ended()
		else
			user.visible_message("<span class='notice'>[user] cleans [W].</span>")
			W.clean_forensic() // There's a global proc for this stuff now (Convair880).
			if (istype(W, /obj/item/device/key/skull))
				W.icon_state = "skull"
			if (W.reagents)
				W.reagents.clear_reagents()		// avoid null error

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if (istype(W) && in_interact_range(W, user) && in_interact_range(src, user) && isalive(user) && !isintangible(user))
			return src.Attackby(W, user)
		return ..()

	attack_hand(var/mob/user)
		src.add_fingerprint(user)
		user.lastattacked = src
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
			if (H.gloves)
				user.visible_message("<span class='notice'>[user] cleans [his_or_her(user)] gloves.</span>")
				H.gloves.clean_forensic() // Ditto (Convair880).
				H.set_clothing_icon_dirty()
			else
				user.visible_message("<span class='notice'>[user] washes [his_or_her(user)] hands.</span>")
				if (H.sims)
					H.sims.affectMotive("Hygiene", 2)
				H.blood_DNA = null // Don't want to use it here, though. The sink isn't a shower (Convair880).
				H.blood_type = null
				H.set_clothing_icon_dirty()
		..()

/obj/submachine/ice_cream_dispenser
	name = "Ice Cream Dispenser"
	desc = "A machine designed to dispense space ice cream."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "ice_creamer0"
	anchored = 1
	density = 1
	mats = 18
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	flags = NOSPLASH
	var/list/flavors = list("chocolate","vanilla","coffee")
	var/obj/item/reagent_containers/glass/beaker = null
	var/obj/item/reagent_containers/food/snacks/ice_cream_cone/cone = null
	var/doing_a_thing = 0

	attack_hand(var/mob/user)
		src.add_dialog(user)
		var/dat = "<b>Ice Cream-O-Mat 9900</b><br>"
		if(src.cone)
			dat += "<a href='?src=\ref[src];eject=cone'>Eject Cone</a><br>"
			dat += "<b>Select a Flavor:</b><br><ul>"
			for(var/flavor in flavors)
				dat += "<li><a href='?src=\ref[src];flavor=[flavor]'>[capitalize(flavor)]</a></li>"
			if(src.beaker)
				dat += "<li><a href='?src=\ref[src];flavor=beaker'>From Beaker</a></li>"
			dat += "</ul><br>"

		else
			dat += "<b>No Cone Inserted!</b><br>"

		if(src.beaker)
			dat += "<a href='?src=\ref[src];eject=beaker'>Eject Beaker</a><br>"

		user.Browse(dat, "window=icecream;size=400x500")
		onclose(user, "icecream")
		return

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	Topic(href, href_list)
		if (istype(src.loc, /turf) && (( BOUNDS_DIST(src, usr) == 0) || issilicon(usr) || isAI(usr)))
			if (!isliving(usr) || iswraith(usr) || isintangible(usr))
				return
			if (is_incapacitated(usr) || usr.restrained())
				return

			src.add_fingerprint(usr)
			src.add_dialog(usr)

			if(href_list["eject"])
				switch(href_list["eject"])
					if("beaker")
						if(src.beaker)
							src.beaker.set_loc(src.loc)
							usr.put_in_hand_or_eject(src.beaker) // try to eject it into the users hand, if we can
							src.beaker = null
							src.UpdateIcon()

					if("cone")
						if(src.cone)
							src.cone.set_loc(src.loc)
							usr.put_in_hand_or_eject(src.cone) // try to eject it into the users hand, if we can
							src.cone = null
							src.UpdateIcon()

			else if(href_list["flavor"])
				if(doing_a_thing)
					src.updateUsrDialog()
					return
				if(!cone)
					boutput(usr, "<span class='alert'>There is no cone loaded!</span>")
					src.updateUsrDialog()
					return

				var/the_flavor = href_list["flavor"]
				if(the_flavor == "beaker")
					if(!beaker)
						boutput(usr, "<span class='alert'>There is no beaker loaded!</span>")
						src.updateUsrDialog()
						return

					if(!beaker.reagents.total_volume)
						boutput(usr, "<span class='alert'>The beaker is empty!</span>")
						src.updateUsrDialog()
						return

					doing_a_thing = 1
					qdel(src.cone)
					src.cone = null
					var/obj/item/reagent_containers/food/snacks/ice_cream/newcream = new
					beaker.reagents.trans_to(newcream,40)
					newcream.set_loc(src.loc)

				else
					if(the_flavor in src.flavors)
						doing_a_thing = 1
						qdel(src.cone)
						src.cone = null
						var/obj/item/reagent_containers/food/snacks/ice_cream/newcream = new
						newcream.reagents.add_reagent(the_flavor,40)
						newcream.set_loc(src.loc)
					else
						boutput(usr, "<span class='alert'>Unknown flavor!</span>")

				doing_a_thing = 0
				src.UpdateIcon()

			src.updateUsrDialog()
		return

	attackby(obj/item/W, mob/user)
		if (W.cant_drop) // For borg held items
			boutput(user, "<span class='alert'>You can't put that in \the [src] when it's attached to you!</span>")
			return

		if (istype(W, /obj/item/reagent_containers/food/snacks/ice_cream_cone))
			if(src.cone)
				boutput(user, "There is already a cone loaded.")
				return
			else
				user.drop_item()
				W.set_loc(src)
				src.cone = W
				boutput(user, "<span class='notice'>You load the cone into [src].</span>")

			src.UpdateIcon()
			src.updateUsrDialog()

		else if (istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/))
			if(src.beaker)
				boutput(user, "There is already a beaker loaded.")
				return
			else
				user.drop_item()
				W.set_loc(src)
				src.beaker = W
				boutput(user, "<span class='alert'>You load [W] into [src].</span>")

			src.UpdateIcon()
			src.updateUsrDialog()
		else ..()

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if ((istype(W, /obj/item/reagent_containers/food/snacks/ice_cream_cone) || istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/)) && in_interact_range(W, user) && in_interact_range(src, user) && isalive(user) && !isintangible(user))
			return src.Attackby(W, user)
		return ..()

	update_icon()
		if(src.beaker)
			src.overlays += image(src.icon, "ice_creamer_beaker")
		else
			src.overlays.len = 0

		src.icon_state = "ice_creamer[src.cone ? "1" : "0"]"

		return

/// COOKING RECODE ///

var/list/oven_recipes = list()

/obj/submachine/chef_oven
	name = "oven"
	desc = "A multi-cooking unit featuring a hob, grill, oven and more."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "oven_off"
	anchored = 1
	density = 1
	mats = 18
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	flags = NOSPLASH
	var/emagged = 0
	var/working = 0
	var/time = 5
	var/heat = "Low"
	var/list/recipes = null
	//var/allowed = list(/obj/item/reagent_containers/food/, /obj/item/parts/robot_parts/head, /obj/item/clothing/head/butt, /obj/item/organ/brain/obj/item)
	var/allowed = list(/obj/item)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!emagged)
			emagged = 1
			if (user)
				boutput(user, "<span class='notice'>[src] produces a strange grinding noise.</span>")
			return 1
		else
			return 0

	attack_hand(var/mob/user)
		if (isghostdrone(user))
			boutput(user, "<span class='alert'>\The [src] refuses to interface with you, as you are not a properly trained chef!</span>")
			return


		src.add_dialog(user)
		var/dat = {"
			<style type="text/css">
table#cooktime {
	margin: 0 auto;
	border-collapse: collapse;
	border: none;
	}
table#cooktime td {
	padding: 0.1em 0.2em;
	width: 3em;
	text-align: center;
	border: none;
	}
table#cooktime a {
	display: block;
	text-decoration: none;
	width: 100%;
	min-width: 3em;
	color: #ccc;
	background: #333;
	border: 2px solid #999;
	}
table#cooktime a:hover {
	background: #777;
	color: white;
	border: 2px solid #ccc;
	}

table#cooktime a#ct[time], table#cooktime a#h[heat] {
	background: #b85;
	border: 2px solid #db9;
	color: white;
	font-weight: bold;
}

table#cooktime a#start {
	background: #8b5;
	color: white;
	border: 2px solid #ad9;
}



</style>
			<b>Cookomatic Multi-Oven</b><br>
			<hr>
			<b>Time:</b> [time]<br>
			<b>Heat:</b> [heat]<br>
			<hr>
		"}
		if (!src.working)
			var/junk = ""
			for (var/obj/item/I in src.contents)
				junk += "[I]<br>"

			var/timeopts = ""
			for (var/i = 1; i <= 10; i++)
				timeopts += "<td><a id='ct[i]' href='?src=\ref[src];time=[i]'>[i]</a></td>"
				if (i == 5)
					timeopts += "<td><a id='hHigh' href='?src=\ref[src];heat=1'>HIGH</a></td><td rowspan='2' valign='middle'><a id='start' href='?src=\ref[src];cook=1'>START</a></td></tr><tr>"

			timeopts += "<td><a id='hLow' href='?src=\ref[src];heat=2'>LOW</a></td>"

			dat += {"
			<table id='cooktime'>
				<tr>
					[timeopts]
				</tr>
			</table>
			<hr>
			<strong>Contents</strong> <em>(<a href='?src=\ref[src];eject=1'>Eject</a>)</em><br>
			[junk ? junk : "(Empty)"]
			"}
		else
			dat += {"Cooking! Please wait!"}

		user.Browse(dat, "window=oven;size=400x500")
		onclose(user, "oven")

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	New()
		..()
	// Note - The order these are placed in matters! Put more complex recipes before simpler ones, or the way the
	//        oven checks through the recipe list will make it pick the simple recipe and finish the cooking proc
	//        before it even gets to the more complex recipe, wasting the ingredients that would have gone to the
	//        more complicated one and pissing off the chef by giving something different than what he wanted!

		src.recipes = oven_recipes
		if (!src.recipes)
			src.recipes = list()

		if (!src.recipes.len)
			src.recipes += new /datum/cookingrecipe/pizza_shroom(src)
			src.recipes += new /datum/cookingrecipe/pizza_pepper(src)
			src.recipes += new /datum/cookingrecipe/pizza_ball(src)
			src.recipes += new /datum/cookingrecipe/haggass(src)
			src.recipes += new /datum/cookingrecipe/haggis(src)
			src.recipes += new /datum/cookingrecipe/scotch_egg(src)
			src.recipes += new /datum/cookingrecipe/omelette_bee(src)
			src.recipes += new /datum/cookingrecipe/omelette(src)
			src.recipes += new /datum/cookingrecipe/monster(src)
			src.recipes += new /datum/cookingrecipe/c_butty(src)
			src.recipes += new /datum/cookingrecipe/scarewich_h(src)
			src.recipes += new /datum/cookingrecipe/scarewich_p_h(src)
			src.recipes += new /datum/cookingrecipe/scarewich_p(src)
			src.recipes += new /datum/cookingrecipe/scarewich_s(src)
			src.recipes += new /datum/cookingrecipe/scarewich_m(src)
			src.recipes += new /datum/cookingrecipe/scarewich_c(src)
			src.recipes += new /datum/cookingrecipe/scarewich_blt(src)
			src.recipes += new /datum/cookingrecipe/elviswich_m_h(src)
			src.recipes += new /datum/cookingrecipe/elviswich_m_m(src)
			src.recipes += new /datum/cookingrecipe/elviswich_m_s(src)
			src.recipes += new /datum/cookingrecipe/elviswich_c(src)
			src.recipes += new /datum/cookingrecipe/elviswich_p_h(src)
			src.recipes += new /datum/cookingrecipe/elviswich_p(src)
			src.recipes += new /datum/cookingrecipe/elviswich_blt(src)
			src.recipes += new /datum/cookingrecipe/sandwich_mb(src)
			src.recipes += new /datum/cookingrecipe/sandwich_mbalt(src)
			src.recipes += new /datum/cookingrecipe/sandwich_egg(src)
			src.recipes += new /datum/cookingrecipe/sandwich_bm(src)
			src.recipes += new /datum/cookingrecipe/sandwich_bmalt(src)
			src.recipes += new /datum/cookingrecipe/sandwich_m_h(src)
			src.recipes += new /datum/cookingrecipe/sandwich_m_m(src)
			src.recipes += new /datum/cookingrecipe/sandwich_m_s(src)
			src.recipes += new /datum/cookingrecipe/sandwich_c(src)
			src.recipes += new /datum/cookingrecipe/sandwich_p_h(src)
			src.recipes += new /datum/cookingrecipe/sandwich_p(src)
			src.recipes += new /datum/cookingrecipe/sandwich_blt(src)
			src.recipes += new /datum/cookingrecipe/sandwich_custom(src)
			src.recipes += new /datum/cookingrecipe/ramen_bowl(src)
			src.recipes += new /datum/cookingrecipe/udon_bowl(src)
			src.recipes += new /datum/cookingrecipe/curry_udon_bowl(src)
			src.recipes += new /datum/cookingrecipe/coconutcurry(src)
			src.recipes += new /datum/cookingrecipe/chickenpineapplecurry(src)
			src.recipes += new /datum/cookingrecipe/tandoorichicken(src)
			src.recipes += new /datum/cookingrecipe/potatocurry(src)
			src.recipes += new /datum/cookingrecipe/onionchips(src)
			src.recipes += new /datum/cookingrecipe/mint_chutney(src)
			src.recipes += new /datum/cookingrecipe/refried_beans(src)
			src.recipes += new /datum/cookingrecipe/ultrachili(src)
			src.recipes += new /datum/cookingrecipe/aburgination(src)
			src.recipes += new /datum/cookingrecipe/baconator(src)
			src.recipes += new /datum/cookingrecipe/butterburger(src)
			src.recipes += new /datum/cookingrecipe/cheeseburger_m(src)
			src.recipes += new /datum/cookingrecipe/cheeseburger(src)
			src.recipes += new /datum/cookingrecipe/wcheeseburger(src)
			src.recipes += new /datum/cookingrecipe/tikiburger(src)
			src.recipes += new /datum/cookingrecipe/luauburger(src)
			src.recipes += new /datum/cookingrecipe/coconutburger(src)
			src.recipes += new /datum/cookingrecipe/humanburger(src)
			src.recipes += new /datum/cookingrecipe/monkeyburger(src)
			src.recipes += new /datum/cookingrecipe/synthburger(src)
			src.recipes += new /datum/cookingrecipe/baconburger(src)
			src.recipes += new /datum/cookingrecipe/spicychickensandwich(src)
			src.recipes += new /datum/cookingrecipe/chickensandwich(src)
			src.recipes += new /datum/cookingrecipe/mysteryburger(src)
			src.recipes += new /datum/cookingrecipe/buttburger(src)
			src.recipes += new /datum/cookingrecipe/heartburger(src)
			src.recipes += new /datum/cookingrecipe/flockburger(src)
			src.recipes += new /datum/cookingrecipe/brainburger(src)
			src.recipes += new /datum/cookingrecipe/fishburger(src)
			src.recipes += new /datum/cookingrecipe/sloppyjoe(src)
			src.recipes += new /datum/cookingrecipe/superchili(src)
			src.recipes += new /datum/cookingrecipe/chili(src)
			src.recipes += new /datum/cookingrecipe/queso(src)
			src.recipes += new /datum/cookingrecipe/cheeseborger(src)
			src.recipes += new /datum/cookingrecipe/roburger(src)
			src.recipes += new /datum/cookingrecipe/swede_mball(src)
			src.recipes += new /datum/cookingrecipe/honkpocket(src)
			src.recipes += new /datum/cookingrecipe/donkpocket(src)
			src.recipes += new /datum/cookingrecipe/donkpocket2(src)
			src.recipes += new /datum/cookingrecipe/cornbread4(src)
			src.recipes += new /datum/cookingrecipe/cornbread3(src)
			src.recipes += new /datum/cookingrecipe/cornbread2(src)
			src.recipes += new /datum/cookingrecipe/cornbread1(src)
			src.recipes += new /datum/cookingrecipe/elvis_bread(src)
			src.recipes += new /datum/cookingrecipe/banana_bread(src)
			src.recipes += new /datum/cookingrecipe/pumpkin_bread(src)
			src.recipes += new /datum/cookingrecipe/spooky_bread(src)
			src.recipes += new /datum/cookingrecipe/banana_bread_alt(src)
			src.recipes += new /datum/cookingrecipe/honeywheat_bread(src)
			src.recipes += new /datum/cookingrecipe/eggnog(src)
			src.recipes += new /datum/cookingrecipe/brain_bread(src)
			src.recipes += new /datum/cookingrecipe/donut(src)
			src.recipes += new /datum/cookingrecipe/bagel(src)
			src.recipes += new /datum/cookingrecipe/crumpet(src)
			src.recipes += new /datum/cookingrecipe/ice_cream_cone(src)
			src.recipes += new /datum/cookingrecipe/waffles(src)
			src.recipes += new /datum/cookingrecipe/lasagna(src)
			src.recipes += new /datum/cookingrecipe/chickenparm(src)
			src.recipes += new /datum/cookingrecipe/chickenalfredo(src)
			src.recipes += new /datum/cookingrecipe/alfredo(src)
			src.recipes += new /datum/cookingrecipe/spaghetti_pg(src)
			src.recipes += new /datum/cookingrecipe/spaghetti_m(src)
			src.recipes += new /datum/cookingrecipe/spaghetti_s(src)
			src.recipes += new /datum/cookingrecipe/spaghetti_t(src)
			src.recipes += new /datum/cookingrecipe/spaghetti_p(src)
			src.recipes += new /datum/cookingrecipe/breakfast(src)
			src.recipes += new /datum/cookingrecipe/elvischeesetoast(src)
			src.recipes += new /datum/cookingrecipe/elvisbacontoast(src)
			src.recipes += new /datum/cookingrecipe/elviseggtoast(src)
			src.recipes += new /datum/cookingrecipe/cheesetoast(src)
			src.recipes += new /datum/cookingrecipe/bacontoast(src)
			src.recipes += new /datum/cookingrecipe/eggtoast(src)
			src.recipes += new /datum/cookingrecipe/nougat(src)
			src.recipes += new /datum/cookingrecipe/candy_cane(src)
			src.recipes += new /datum/cookingrecipe/cereal_honey(src)
			src.recipes += new /datum/cookingrecipe/b_cupcake(src)
			src.recipes += new /datum/cookingrecipe/beefood(src)
			src.recipes += new /datum/cookingrecipe/zongzi(src)

			src.recipes += new /datum/cookingrecipe/baguette(src)
			src.recipes += new /datum/cookingrecipe/garlicbread_ch(src)
			src.recipes += new /datum/cookingrecipe/garlicbread(src)
			src.recipes += new /datum/cookingrecipe/fairybread(src)
			src.recipes += new /datum/cookingrecipe/danish_apple(src)
			src.recipes += new /datum/cookingrecipe/danish_cherry(src)
			src.recipes += new /datum/cookingrecipe/danish_blueb(src)
			src.recipes += new /datum/cookingrecipe/danish_weed(src)
			src.recipes += new /datum/cookingrecipe/painauchocolat(src)
			src.recipes += new /datum/cookingrecipe/croissant(src)

			src.recipes += new /datum/cookingrecipe/pie_cream(src)
			src.recipes += new /datum/cookingrecipe/pie_anything(src)
			src.recipes += new /datum/cookingrecipe/pie_cherry(src)
			src.recipes += new /datum/cookingrecipe/pie_blueberry(src)
			src.recipes += new /datum/cookingrecipe/pie_blackberry(src)
			src.recipes += new /datum/cookingrecipe/pie_raspberry(src)
			src.recipes += new /datum/cookingrecipe/pie_strawberry(src)
			src.recipes += new /datum/cookingrecipe/pie_apple(src)
			src.recipes += new /datum/cookingrecipe/pie_lime(src)
			src.recipes += new /datum/cookingrecipe/pie_lemon(src)
			src.recipes += new /datum/cookingrecipe/pie_slurry(src)
			src.recipes += new /datum/cookingrecipe/pie_pumpkin(src)
			src.recipes += new /datum/cookingrecipe/pie_custard(src)
			src.recipes += new /datum/cookingrecipe/pie_strawberry(src)
			src.recipes += new /datum/cookingrecipe/pie_bacon(src)
			src.recipes += new /datum/cookingrecipe/pot_pie(src)
			src.recipes += new /datum/cookingrecipe/pie_chocolate(src)
			src.recipes += new /datum/cookingrecipe/pie_ass(src)
			src.recipes += new /datum/cookingrecipe/pie_fish(src)
			src.recipes += new /datum/cookingrecipe/pie_weed(src)
			src.recipes += new /datum/cookingrecipe/candy_apple_poison(src)
			src.recipes += new /datum/cookingrecipe/candy_apple(src)
			src.recipes += new /datum/cookingrecipe/cake_bacon(src)
			src.recipes += new /datum/cookingrecipe/cake_true_bacon(src)
			src.recipes += new /datum/cookingrecipe/cake_meat(src)
			src.recipes += new /datum/cookingrecipe/cake_chocolate(src)
			src.recipes += new /datum/cookingrecipe/cake_cream(src)
			#ifdef XMAS
			src.recipes += new /datum/cookingrecipe/cake_fruit(src)
			#endif
			src.recipes += new /datum/cookingrecipe/cake_custom(src)
			src.recipes += new /datum/cookingrecipe/meatloaf(src)
			src.recipes += new /datum/cookingrecipe/stroopwafel(src)
			src.recipes += new /datum/cookingrecipe/cookie_spooky(src)
			src.recipes += new /datum/cookingrecipe/cookie_jaffa(src)
			src.recipes += new /datum/cookingrecipe/cookie_bacon(src)
			src.recipes += new /datum/cookingrecipe/cookie_oatmeal(src)
			src.recipes += new /datum/cookingrecipe/cookie_chocolate_chip(src)
			src.recipes += new /datum/cookingrecipe/cookie_iron(src)
			src.recipes += new /datum/cookingrecipe/cookie_butter(src)
			src.recipes += new /datum/cookingrecipe/cookie_peanut(src)
			src.recipes += new /datum/cookingrecipe/cookie(src)
			src.recipes += new /datum/cookingrecipe/moon_pie_spooky(src)
			src.recipes += new /datum/cookingrecipe/moon_pie_jaffa(src)
			src.recipes += new /datum/cookingrecipe/moon_pie_bacon(src)
			src.recipes += new /datum/cookingrecipe/moon_pie_chocolate(src)
			src.recipes += new /datum/cookingrecipe/moon_pie_oatmeal(src)
			src.recipes += new /datum/cookingrecipe/moon_pie_chips(src)
			src.recipes += new /datum/cookingrecipe/moon_pie_iron(src)
			src.recipes += new /datum/cookingrecipe/moon_pie(src)
			src.recipes += new /datum/cookingrecipe/granola_bar(src)
			src.recipes += new /datum/cookingrecipe/biscuit(src)
			src.recipes += new /datum/cookingrecipe/dog_biscuit(src)
			src.recipes += new /datum/cookingrecipe/hardtack(src)
			src.recipes += new /datum/cookingrecipe/macguffin(src)
			src.recipes += new /datum/cookingrecipe/eggsalad(src)
			src.recipes += new /datum/cookingrecipe/lipstick(src)
			src.recipes += new /datum/cookingrecipe/friedrice(src)
			src.recipes += new /datum/cookingrecipe/risotto(src)
			src.recipes += new /datum/cookingrecipe/omurice(src)
			src.recipes += new /datum/cookingrecipe/riceandbeans(src)
			src.recipes += new /datum/cookingrecipe/sushi_roll(src)
			src.recipes += new /datum/cookingrecipe/nigiri_roll(src)
			src.recipes += new /datum/cookingrecipe/porridge(src)
			src.recipes += new /datum/cookingrecipe/ratatouille(src)
			// Put all single-ingredient recipes after this point
			src.recipes += new /datum/cookingrecipe/pizza(src)
			src.recipes += new /datum/cookingrecipe/pizza_fresh(src)
			src.recipes += new /datum/cookingrecipe/cake_custom_item(src)
			src.recipes += new /datum/cookingrecipe/pancake(src)
			src.recipes += new /datum/cookingrecipe/bread(src)
			src.recipes += new /datum/cookingrecipe/oatmeal(src)
			src.recipes += new /datum/cookingrecipe/salad(src)
			src.recipes += new /datum/cookingrecipe/tomsoup(src)
			src.recipes += new /datum/cookingrecipe/toast_brain(src)
			src.recipes += new /datum/cookingrecipe/toast_banana(src)
			src.recipes += new /datum/cookingrecipe/toast_elvis(src)
			src.recipes += new /datum/cookingrecipe/toast_spooky(src)
			src.recipes += new /datum/cookingrecipe/toast(src)
			src.recipes += new /datum/cookingrecipe/fries(src)
			src.recipes += new /datum/cookingrecipe/taco_shell(src)
			src.recipes += new /datum/cookingrecipe/bacon(src)
			src.recipes += new /datum/cookingrecipe/steak_h(src)
			src.recipes += new /datum/cookingrecipe/steak_m(src)
			src.recipes += new /datum/cookingrecipe/steak_s(src)
			src.recipes += new /datum/cookingrecipe/steak_ling(src)
			src.recipes += new /datum/cookingrecipe/fish_fingers(src)
			src.recipes += new /datum/cookingrecipe/hardboiled(src)
			src.recipes += new /datum/cookingrecipe/bakedpotato(src)
			src.recipes += new /datum/cookingrecipe/rice_ball(src)
			src.recipes += new /datum/cookingrecipe/hotdog(src)
			src.recipes += new /datum/cookingrecipe/cheesewheel(src)


	Topic(href, href_list)
		if ((BOUNDS_DIST(src, usr) > 0 && (!issilicon(usr) && !isAI(usr))) || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (is_incapacitated(usr) || usr.restrained())
			return
		if (href_list["cook"])
			if (src.working)
				boutput(usr, "<span class='alert'>It's already working.</span>")
				return
			var/amount = length(src.contents)
			if (!amount)
				boutput(usr, "<span class='alert'>There's nothing in \the [src] to cook.</span>")
				return
			var/output = null
			var/cook_amt = src.time
			var/bonus = 0
			var/derivename = 0
			var/recipebonus = 0
			var/recook = 0
			if (src.heat == "High") cook_amt *= 2

			// If emagged produce random output.
			if (emagged)
				// Enforce GIGO and prevent infinite reuse
				var/contentsok = 1
				for(var/obj/item/I in src.contents)
					if(istype(I, /obj/item/reagent_containers/food/snacks/yuck))
						contentsok = 0
						break
					if(istype(I, /obj/item/reagent_containers/food/snacks/yuckburn))
						contentsok = 0
						break
					if(istype(I, /obj/item/reagent_containers/food))
						var/obj/item/reagent_containers/food/F = I
						if (F.from_emagged_oven) // hyphz checked heal_amt but I think this custom var is a nicer solution (also I'm not sure that valid food not from an emagged oven will never have a heal_amt of 0 (because I am lazy and don't want to read the code))
							contentsok = 0
							break
					// Pick a random recipe
				var/datum/cookingrecipe/xrecipe = pick(src.recipes)
				var/xrecipeok = 1
				// Don't choose recipes with human meat since we don't have a name for them
				if (xrecipe.useshumanmeat)
					xrecipeok = 0
				// Don't choose recipes with special outputs since we don't have valid inputs for them
				if (isnull(xrecipe.output))
					xrecipeok = 0
				// Bail out to a mess if we didn't get a valid recipe
				if (xrecipeok && contentsok)
					output = xrecipe.output
				else
					output = /obj/item/reagent_containers/food/snacks/yuck
				// Given the weird stuff coming out of the oven it presumably wouldn't be palatable..
				recipebonus = 0
				bonus = -1
			else
				for (var/datum/cookingrecipe/R in src.recipes)
					if (R.item1)
						if (!OVEN_checkitem(R.item1, R.amt1)) continue
					if (R.item2)
						if (!OVEN_checkitem(R.item2, R.amt2)) continue
					if (R.item3)
						if (!OVEN_checkitem(R.item3, R.amt3)) continue
					if (R.item4)
						if (!OVEN_checkitem(R.item4, R.amt4)) continue

					output = R.specialOutput(src)

					//Complete pizza crew objectives if possible
					if(istype(output,/obj/item/reagent_containers/food/snacks/pizza/))
						var/obj/item/reagent_containers/food/snacks/pizza/P = output
						if (usr.mind?.objectives)
							for (var/datum/objective/crew/chef/pizza/objective in usr.mind.objectives)
								var/list/matching_toppings = P.topping_types & objective.choices
								if(length(matching_toppings) >= PIZZA_OBJ_COUNT)
									objective.completed = TRUE

					if (isnull(output))
						output = R.output

					if (R.useshumanmeat) derivename = 1
					recipebonus = R.cookbonus
					if (cook_amt == R.cookbonus) bonus = 1
					else if (cook_amt == R.cookbonus + 1) bonus = 1
					else if (cook_amt == R.cookbonus - 1) bonus = 1
					else if (cook_amt <= R.cookbonus - 5) bonus = -1
					else if (cook_amt >= R.cookbonus + 5)
						output = /obj/item/reagent_containers/food/snacks/yuckburn
						bonus = 0
					break

			if (isnull(output))
				output = /obj/item/reagent_containers/food/snacks/yuck

			if (amount == 1 && output == /obj/item/reagent_containers/food/snacks/yuck)
				for (var/obj/item/reagent_containers/food/snacks/F in src)
					if(F.quality < 1)
						recook = 1
						if (cook_amt == F.quality) F.quality = 1.5
						else if (cook_amt == F.quality + 1) F.quality = 1
						else if (cook_amt == F.quality - 1) F.quality = 1
						else if (cook_amt <= F.quality - 5) F.quality = 0.5
						else if (cook_amt >= F.quality + 5)
							output = /obj/item/reagent_containers/food/snacks/yuckburn
							bonus = 0
			src.working = 1
			src.icon_state = "oven_bake"
			src.updateUsrDialog()
			SPAWN(cook_amt * 10)

				if(recook && bonus !=0)
					for (var/obj/item/reagent_containers/food/snacks/F in src)
						if (bonus == 1)
							if (F.quality != 1)
								F.quality = 1
						else if (bonus == -1)
							if (F.quality > 0.5)
								F.quality = 0.5
						if (src.emagged)
							F.from_emagged_oven = 1
						F.set_loc(src.loc)
				else
					var/obj/item/reagent_containers/food/snacks/F
					if (ispath(output))
						F = new output(src.loc)
					else
						F = output
						F.set_loc( get_turf(src) )

					if (bonus == 1)
						F.quality = 5
					else
						F.quality = clamp(5 - abs(recipebonus - cook_amt), 0, 5)
					if (src.emagged && istype(F))
						F.from_emagged_oven = 1
					if (derivename)
						var/foodname = F.name
						for (var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/M in src.contents)
							F.name = "[M.subjectname] [foodname]"
							F.desc += " It sort of smells like [M.subjectjob ? M.subjectjob : "pig"]s."
							if(!isnull(F.unlock_medal_when_eaten))
								continue
							else if (M.subjectjob && M.subjectjob == "Clown")
								F.unlock_medal_when_eaten = "That tasted funny"
							else
								F.unlock_medal_when_eaten = "Space Ham" //replace the old fat person method
				src.icon_state = "oven_off"
				src.working = 0
				playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
				for (var/atom/movable/I in src.contents)
					qdel(I)
				src.updateUsrDialog()
				return

		if(href_list["time"])
			if (src.working)
				boutput(usr, "<span class='alert'>It's already working.</span>")
				return
			src.time = clamp(text2num_safe(href_list["time"]), 1, 10)
			src.updateUsrDialog()
			return

		if(href_list["heat"])
			if (src.working)
				boutput(usr, "<span class='alert'>The dials are locked! THIS IS HOW OVENS WORK OK</span>")
				return
			var/operation = text2num_safe(href_list["heat"])
			if (operation == 1) src.heat = "High"
			if (operation == 2) src.heat = "Low"
			src.updateUsrDialog()
			return

		if(href_list["eject"])
			if (src.working)
				boutput(usr, "<span class='alert'>Too late! It's already cooking, ejecting the food would ruin everything forever!</span>")
				return
			for (var/obj/item/I in src.contents)
				I.set_loc(src.loc)
			src.updateUsrDialog()
			return

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] shoves [his_or_her(user)] head in the oven and turns it on.</b></span>")
		src.icon_state = "oven_bake"
		user.TakeDamage("head", 0, 150)
		sleep(5 SECONDS)
		src.icon_state = "oven_off"
		SPAWN(55 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	attackby(obj/item/W, mob/user)
		if (isghostdrone(user))
			boutput(user, "<span class='alert'>\The [src] refuses to interface with you, as you are not a properly trained chef!</span>")
			return
		if (W.cant_drop) //For borg held items
			boutput(user, "<span class='alert'>You can't put that in [src] when it's attached to you!</span>")
			return
		if(W.w_class > W_CLASS_BULKY)
			boutput(user, "<span class='alert'>[W] is far too large and unwieldly to fit in [src]!</span>")
			return
		if (src.working)
			boutput(user, "<span class='alert'>It's already on! Putting a new thing in could result in a collapse of the cooking waveform into a really lousy eigenstate, like a vending machine chili dog.</span>")
			return
		var/amount = length(src.contents)
		if (amount >= 8)
			boutput(user, "<span class='alert'>\The [src] cannot hold any more items.</span>")
			return

		var/proceed = 0
		for(var/check_path in src.allowed)
			if(istype(W, check_path))
				proceed = 1
				break
		if (istype(W, /obj/item/grab))
			proceed = 0
		if (istype(W, /obj/item/card/emag))
			..()
			return
		if (amount == 1)
			var/cakecount
			for (var/obj/item/reagent_containers/food/snacks/cake/cream/C in src.contents) cakecount++
			if (cakecount == 1) proceed = 1
		if (!proceed)
			boutput(user, "<span class='alert'>You can't put that in [src]!</span>")
			return
		user.visible_message("<span class='notice'>[user] loads [W] into [src].</span>")
		user.u_equip(W)
		W.set_loc(src)
		W.dropped(user)
		src.updateUsrDialog()

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if (istype(W) && in_interact_range(W, user) && in_interact_range(src, user) && W.w_class <= W_CLASS_HUGE && !W.anchored && isalive(user) && !isintangible(user))
			return src.Attackby(W, user)
		return ..()

	proc/OVEN_checkitem(var/recipeitem, var/recipecount)
		if (!locate(recipeitem) in src.contents) return 0
		var/count = 0
		for(var/obj/item/I in src.contents)
			if(istype(I, recipeitem))
				count++
		if (count < recipecount)
			return 0
		return 1

#define MIN_FLUID_INGREDIENT_LEVEL 10
/obj/submachine/foodprocessor
	name = "Processor"
	desc = "Refines various food substances into different forms."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor-off"
	anchored = 1
	density = 1
	mats = 18
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	var/working = 0
	var/allowed = list(/obj/item/reagent_containers/food/, /obj/item/plant/, /obj/item/organ/brain, /obj/item/clothing/head/butt)

	attack_hand(var/mob/user)
		if (src.contents.len < 1)
			boutput(user, "<span class='alert'>There is nothing in the processor!</span>")
			return
		if (src.working == 1)
			boutput(user, "<span class='alert'>The processor is busy!</span>")
			return
		src.icon_state = "processor-on"
		src.working = 1
		src.visible_message("The [src] begins processing its contents.")
		sleep(rand(30,70))
		// Dispense processed stuff
		for(var/obj/item/P in src.contents)
			switch( P.type )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = P:subjectname + " meatball"
					F.desc = "Meaty balls taken from the station's finest [P:subjectjob]."
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "monkey meatball"
					F.desc = "Welcome to Space Station 13, where you too can eat a rhesus macaque's balls."
					qdel( P )
				if (/obj/item/organ/brain)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "brain meatball"
					F.desc = "Oh jesus, brain meatballs? That's just nasty."
					qdel( P )
				if (/obj/item/clothing/head/butt)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "buttball"
					F.desc = "The best you can hope for is that the meat was lean..."
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "synthetic meatball"
					F.desc = "Let's be honest, this is probably as good as these things are going to get."
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "mystery meatball"
					F.desc = "A meatball of even more dubious quality than usual."
					qdel( P )
				if (/obj/item/plant/wheat/metal)
					new/obj/item/reagent_containers/food/snacks/condiment/ironfilings/(src.loc)
					qdel( P )
				if (/obj/item/plant/wheat/durum)
					new/obj/item/reagent_containers/food/snacks/ingredient/flour/semolina(src.loc)
					qdel( P )
				if (/obj/item/plant/wheat)
					new/obj/item/reagent_containers/food/snacks/ingredient/flour/(src.loc)
					qdel( P )
				if (/obj/item/plant/oat)
					new/obj/item/reagent_containers/food/snacks/ingredient/oatmeal/(src.loc)
					qdel( P )
				if (/obj/item/plant/oat/salt)
					new/obj/item/reagent_containers/food/snacks/ingredient/salt/(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/rice_sprig)
					new/obj/item/reagent_containers/food/snacks/ingredient/rice(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/tomato)
					new/obj/item/reagent_containers/food/snacks/condiment/ketchup(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/peanuts)
					new/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/egg)
					new/obj/item/reagent_containers/food/snacks/condiment/mayo(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet)
					new/obj/item/reagent_containers/food/snacks/ingredient/spaghetti(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/sheet)
					new/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/ramen(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/chili/chilly)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/condiment/coldsauce/F = new(src.loc)
					F.reagents.add_reagent("cryostylane", DNA.potency)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/chili/ghost_chili)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/condiment/hotsauce/ghostchilisauce/F = new(src.loc)
					F.reagents.add_reagent("ghostchilijuice", 5 + DNA.potency)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/chili)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/condiment/hotsauce/F = new(src.loc)
					F.reagents.add_reagent("capsaicin", DNA.potency)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/coffeeberry/mocha)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/candy/chocolate/F = new(src.loc)
					F.reagents.add_reagent("chocolate", DNA.potency)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/coffeeberry/latte)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/condiment/cream/F = new(src.loc)
					F.reagents.add_reagent("milk", DNA.potency)
					qdel( P )
				if (/obj/item/plant/sugar)
					var/obj/item/reagent_containers/food/snacks/ingredient/sugar/F = new(src.loc)
					F.reagents.add_reagent("sugar", 20)
					qdel( P )
				if (/obj/item/reagent_containers/food/drinks/milk)
					if (P.reagents.get_reagent_amount("milk") >= MIN_FLUID_INGREDIENT_LEVEL)
						new/obj/item/reagent_containers/food/snacks/condiment/cream(src.loc)
						qdel( P )
				if (/obj/item/reagent_containers/food/drinks/milk/soy)
					//so soy milk is just milk it seems, veganism is a lie
					if (P.reagents.get_reagent_amount("milk") >= MIN_FLUID_INGREDIENT_LEVEL)
						new/obj/item/reagent_containers/food/snacks/condiment/cream(src.loc)
						qdel( P )
				if (/obj/item/reagent_containers/food/drinks/milk/rancid)
					new/obj/item/reagent_containers/food/snacks/yoghurt(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/condiment/cream)
					new/obj/item/reagent_containers/food/snacks/ingredient/butter(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/candy/chocolate)
					new/obj/item/reagent_containers/food/snacks/condiment/chocchips(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/corn)
					new/obj/item/reagent_containers/food/snacks/popcorn(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/corn/pepper)
					new/obj/item/reagent_containers/food/snacks/ingredient/pepper(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/avocado)
					new/obj/item/reagent_containers/food/snacks/soup/guacamole(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/soy)
					new/obj/item/reagent_containers/food/drinks/milk/soy(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/coffeeberry)
					new/obj/item/reagent_containers/food/snacks/plant/coffeebean(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meatpaste)
					new/obj/item/reagent_containers/food/snacks/ingredient/pepperoni_log(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/fishpaste)
					new/obj/item/reagent_containers/food/snacks/ingredient/kamaboko_log(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/cucumber)
					new/obj/item/reagent_containers/food/snacks/pickle(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/cherry)
					new/obj/item/cocktail_stuff/maraschino_cherry(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/turmeric)
					new/obj/item/reagent_containers/food/snacks/ingredient/currypowder(src.loc)
					qdel( P )
				if (/obj/item/plant/herb/tea)
					new/obj/item/reagent_containers/food/snacks/condiment/matcha(src.loc)
					qdel( P )
		// Wind down
		for(var/obj/item/S in src.contents)
			S.set_loc(get_turf(src))
		src.working = 0
		src.icon_state = "processor-off"
		playsound(src.loc, 'sound/machines/ding.ogg', 100, 1)
		return

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/satchel/))
			var/obj/item/satchel/S = W
			if (S.contents.len < 1) boutput(user, "<span class='alert'>There's nothing in the satchel!</span>")
			else
				user.visible_message("<span class='notice'>[user] loads [S]'s contents into [src]!</span>")
				var/amtload = 0
				for (var/obj/item/reagent_containers/food/F in S.contents)
					F.set_loc(src)
					amtload++
				for (var/obj/item/plant/P in S.contents)
					P.set_loc(src)
					amtload++
				W:UpdateIcon()
				boutput(user, "<span class='notice'>[amtload] items loaded from satchel!</span>")
				S.desc = "A leather bag. It holds [S.contents.len]/[S.maxitems] [S.itemstring]."
			return
		else
			var/proceed = 0
			for(var/check_path in src.allowed)
				if(istype(W, check_path))
					proceed = 1
					break
			if (!proceed)
				boutput(user, "<span class='alert'>You can't put that in the processor!</span>")
				return
			user.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			W.dropped(user)
			return

	mouse_drop(over_object, src_location, over_location)
		..()
		if (BOUNDS_DIST(src, usr) > 0 || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (is_incapacitated(usr) || usr.restrained())
			return
		if (over_object == usr && (in_interact_range(src, usr) || usr.contents.Find(src)))
			for(var/obj/item/P in src.contents)
				P.set_loc(get_turf(src))
			for(var/mob/O in AIviewers(usr, null))
				O.show_message("<span class='notice'>[usr] empties the [src].</span>")
			return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (BOUNDS_DIST(src, user) > 0 || !isliving(user) || iswraith(user) || isintangible(user) || !isalive(user) || isintangible(user))
			return
		if (is_incapacitated(user) || user.restrained())
			return

		if (istype(O, /obj/storage))
			if (O:locked)
				boutput(user, "<span class='alert'>You need to unlock it first!</span>")
				return
			user.visible_message("<span class='notice'>[user] loads [O]'s contents into [src]!</span>")
			var/amtload = 0
			for (var/obj/item/reagent_containers/food/M in O.contents)
				M.set_loc(src)
				amtload++
			for (var/obj/item/plant/P in O.contents)
				P.set_loc(src)
				amtload++
			if (amtload) boutput(user, "<span class='notice'>[amtload] items of food loaded from [O]!</span>")
			else boutput(user, "<span class='alert'>No food loaded!</span>")
		else if (istype(O, /obj/item/reagent_containers/food/) || istype(O, /obj/item/plant/))
			user.visible_message("<span class='notice'>[user] begins quickly stuffing food into [src]!</span>")
			var/staystill = user.loc
			for(var/obj/item/reagent_containers/food/M in view(1,user))
				M.set_loc(src)
				sleep(0.3 SECONDS)
				if (user.loc != staystill) break
			for(var/obj/item/plant/P in view(1,user))
				P.set_loc(src)
				sleep(0.3 SECONDS)
				if (user.loc != staystill) break
			boutput(user, "<span class='notice'>You finish stuffing food into [src]!</span>")
		else ..()
		src.updateUsrDialog()

var/list/mixer_recipes = list()

/obj/submachine/mixer
	name = "KitchenHelper"
	desc = "A food Mixer."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "blender"
	density = 1
	anchored = 1
	mats = 15
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	var/list/recipes = null
	var/list/to_remove = list()
	var/allowed = list(/obj/item/reagent_containers/food/, /obj/item/parts/robot_parts/head, /obj/item/clothing/head/butt, /obj/item/organ/brain)
	var/working = 0

	New()
		..()
		src.recipes = mixer_recipes
		if (!src.recipes)
			src.recipes = list()

		if (!src.recipes.len)
			src.recipes += new /datum/cookingrecipe/mix_cake_custom(src)
			src.recipes += new /datum/cookingrecipe/pancake_batter(src)
			src.recipes += new /datum/cookingrecipe/cake_batter(src)
			src.recipes += new /datum/cookingrecipe/custard(src)
			src.recipes += new /datum/cookingrecipe/creamofmushroom/amanita(src)
			src.recipes += new /datum/cookingrecipe/creamofmushroom/psilocybin(src)
			src.recipes += new /datum/cookingrecipe/creamofmushroom(src)
			src.recipes += new /datum/cookingrecipe/mashedpotatoes(src)
			src.recipes += new /datum/cookingrecipe/mashedbrains(src)
			src.recipes += new /datum/cookingrecipe/gruel(src)
			src.recipes += new /datum/cookingrecipe/fishpaste(src)
			src.recipes += new /datum/cookingrecipe/meatpaste(src)
			src.recipes += new /datum/cookingrecipe/wonton_wrapper(src)
			src.recipes += new /datum/cookingrecipe/butters(src)

		src.UpdateIcon()
		return

	attackby(obj/item/W, mob/user)
		var/amount = length(src.contents)
		if (amount >= 4)
			boutput(user, "<span class='alert'>The mixer is full.</span>")
			return
		var/proceed = 0
		for(var/check_path in src.allowed)
			if(istype(W, check_path))
				proceed = 1
				break
		if (!proceed)
			boutput(user, "<span class='alert'>You can't put that in the mixer!</span>")
			return
		user.visible_message("<span class='notice'>[user] puts [W] into the [src].</span>")
		user.u_equip(W)
		W.set_loc(src)
		W.dropped(user)

	attack_hand(var/mob/user)
		if (!src.working)
			src.add_dialog(user)
			var/dat = {"<B>KitchenHelper Mixer</B><BR>
			<HR>
			<B>Contents:</B><BR>"}
			for (var/obj/item/I in src.contents)
				dat += "[I]<BR>"
			dat += {"<HR>
			<A href='?src=\ref[src];mix=1'>Mix!</A><BR>
			<A href='?src=\ref[src];eject=1'>Eject Contents</A>"}
			user.Browse(dat, "window=mixer;size=400x500")
			onclose(user, "mixer")
		else
			src.add_dialog(user)
			var/dat = {"<B>KitchenHelper Mixer</B><BR>
			<HR><BR>
			Mixing! Please wait!"}
			user.Browse(dat, "window=mixer;size=400x500")
			onclose(user, "mixer")

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if (istype(W) && in_interact_range(W, user) && in_interact_range(src, user) && isalive(user) && !isintangible(user))
			return src.Attackby(W, user)
		return ..()

	Topic(href, href_list)
		if ((BOUNDS_DIST(src, usr) > 0 && (!issilicon(usr) && !isAI(usr))) || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (is_incapacitated(usr) || usr.restrained())
			return

		if (href_list["mix"])
			if (src.working)
				boutput(usr, "<span class='alert'>It's already working.</span>")
				return
			mix()
		if(href_list["eject"])
			for (var/obj/item/I in src.contents)
				I.set_loc(src.loc)
			src.updateUsrDialog()
			return

	proc/bowl_checkitem(var/recipeitem, var/recipecount)
		if (!locate(recipeitem) in src.contents) return 0
		var/count = 0
		for(var/obj/item/I in src.contents)
			if(istype(I, recipeitem))
				count++
				to_remove += I

		if (count < recipecount)
			return 0
		return 1

	proc/mix()
		var/amount = length(src.contents)
		if (!amount)
			boutput(usr, "<span class='alert'>There's nothing in the mixer.</span>")
			return
		working = 1
		src.UpdateIcon()
		src.updateUsrDialog()
		playsound(src.loc, 'sound/machines/mixer.ogg', 50, 1)
		var/output = null // /obj/item/reagent_containers/food/snacks/yuck
		var/derivename = 0
		for (var/datum/cookingrecipe/R in src.recipes)
			to_remove.len = 0
			if (R.item1)
				if (!bowl_checkitem(R.item1, R.amt1)) continue
			if (R.item2)
				if (!bowl_checkitem(R.item2, R.amt2)) continue
			if (R.item3)
				if (!bowl_checkitem(R.item3, R.amt3)) continue
			if (R.item4)
				if (!bowl_checkitem(R.item4, R.amt4)) continue
			output = R.specialOutput(src)
			if (!output)
				output = R.output
			if (R.useshumanmeat)
				derivename = 1
			break
		SPAWN(2 SECONDS)

			if (!isnull(output))
				var/obj/item/reagent_containers/food/snacks/F
				if (ispath(output))
					F = new output(get_turf(src))
				else
					F = output
					F.set_loc(get_turf(src))

				if (derivename)
					var/foodname = F.name
					for (var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/M in src.contents)
						F.name = "[M.subjectname] [foodname]"
						F.desc += " It sort of smells like [M.subjectjob ? M.subjectjob : "pig"]s."
						if(!isnull(F.unlock_medal_when_eaten))
							continue
						else if (M.subjectjob && M.subjectjob == "Clown")
							F.unlock_medal_when_eaten = "That tasted funny"
						else
							F.unlock_medal_when_eaten = "Space Ham" //replace the old fat person method
				for (var/obj/item/I in to_remove)
					qdel(I)
				to_remove.len = 0

			for (var/obj/I in src.contents)
				I.set_loc(src.loc)
				src.visible_message("<span class='alert'>[I] is tossed out of [src]!</span>")
				var/edge = get_edge_target_turf(src, pick(alldirs))
				I.throw_at(edge, 25, 4)

			working = 0
			src.UpdateIcon()
			src.updateUsrDialog()
			return

	update_icon()
		if (!src || !istype(src))
			return

		if (src.working != 0)
			src.icon_state = "blender_on"
		else
			src.icon_state = "blender"

		return
