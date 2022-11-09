
/obj/item/reagent_containers/food/drinks/noodlecup
	name = "Discount Dan's Quik-Noodles"
	desc = "A self-heating cup of noodles. There's enough sodium in these to put the Dead Sea to shame."
	icon = 'icons/obj/foodNdrink/food_discountdans.dmi'
	icon_state = "noodlecup"
	heal_amt = 1
	var/activated = 0
	initial_volume = 60
	can_recycle = FALSE
	initial_reagents = list("chickensoup"=10,"msg"=9,"salt"=10,"nicotine"=8)

	New()
		//..()
		//var/datum/reagents/R = reagents
		//R.add_reagent("chickensoup", 10)
		if (prob(75))
			src.initial_reagents["grease"] = 1
			//R.add_reagent("grease", 1)
		else
			src.initial_reagents["badgrease"] = 1
/*			R.add_reagent("badgrease",1)

		R.add_reagent("msg",9)
		R.add_reagent("salt",10)
		R.add_reagent("nicotine",8)
*/
		switch(rand(1, 14))
			if (1)
				src.real_name = "Discount Dan's Quik-Noodles - Gamer Grubs Flavor"
				src.initial_reagents["yuck"] = 10
				src.initial_reagents["potassium"] = 5
				//R.add_reagent("yuck", 10)
				//R.add_reagent("potassium",5)

			if (2)
				src.real_name = "Discount Deng's Quik-Noodles - Teriyaki TVP Flavor"
				src.initial_reagents["synthflesh"] = 5
				src.initial_reagents["msg"] = 5
				//R.add_reagent("synthflesh",5)
				//R.add_reagent("msg",5)

			if (3)
				src.real_name = "Discount Dan's Quik-Noodles - Macaroni and Imitation Processed Cheese Product Flavor"
				src.initial_reagents["fakecheese"] = 2
				src.initial_reagents["grease"] = 8
				//R.add_reagent("fakecheese",2)
				//R.add_reagent("grease",8)

			if (4)
				src.real_name = "Comrade Dan's Quik-Noodles - Beef Perestroikanoff Flavor"
				src.initial_reagents["milk"] = 3
				src.initial_reagents["denatured_enzyme"] = 3
				src.initial_reagents["beff"] = 4
/*				R.add_reagent("milk",3)
				R.add_reagent("denatured_enzyme",3)
				R.add_reagent("beff",4)
*/
			if (5)
				src.real_name = "Pirate Dan's Quik-Noodles - Spicy Imitation Crab Meat Paste Flavor"
				src.initial_reagents["synthflesh"] = 3
				src.initial_reagents["saltpetre"] = 3
				src.initial_reagents["capsaicin"] = 14
/*				R.add_reagent("synthflesh",3)
				R.add_reagent("saltpetre",3)
				R.add_reagent("capsaicin",14)
*/
			if (6)
				src.real_name = "Frycook Dan's Quik-Noodles - Mushroom-Swiss Burger-Bake Flavor"
				src.initial_reagents["beff"] = 2
				src.initial_reagents["gcheese"] = 2
				src.initial_reagents["psilocybin"] = 6
/*				R.add_reagent("beff",2)
				R.add_reagent("gcheese",2)
				R.add_reagent("psilocybin",6)
*/
			if (7)
				src.real_name = "Discount Deng's Quik-Noodles - Sweet and Sour Lo Mein Flavor"
				src.initial_reagents["acid"] = 3
				src.initial_reagents["VHFCS"] = 7
/*				R.add_reagent("acid",3)
				R.add_reagent("VHFCS",7)
*/
			if (8)
				src.real_name = "Descuento Danito's Quik-Noodles - Tuna Melt Taco Fiesta Flavor"
				src.initial_reagents["fakecheese"] = 3
				src.initial_reagents["mercury"] = 3
				src.initial_reagents["capsaicin"] = 3
/*				R.add_reagent("fakecheese",3)
				R.add_reagent("mercury",3)
				R.add_reagent("capsaicin",4)
*/
			if (9)
				src.real_name = "Sconto Danilo's Quik-Noodles - Italian Strozzapreti Lunare Flavor"
				src.initial_reagents["juice_tomato"] = 4 //I guess the lunar style of pasta is with a tomato wine red sauce
				src.initial_reagents["wine"] = 2
				src.initial_reagents["water_holy"] = 2
				src.initial_reagents["venom"] = 2
/*				R.add_reagent("juice_tomato",4) //I guess the lunar style of pasta is with a tomato wine red sauce
				R.add_reagent("wine",2)
				R.add_reagent("water_holy",2)
				R.add_reagent("venom",2)
*/
			if (10)
				src.real_name = "Rabatt Dan's Snabb-Nudlar - Inkokt Lax Smörgåsbord Smak"
				src.initial_reagents["cleaner"] = 2
				src.initial_reagents["mercury"] = 2
				src.initial_reagents["swedium"] = 6
/*				R.add_reagent("cleaner",2)
				R.add_reagent("mercury",2)
				R.add_reagent("swedium",6)
*/
			if (11)
				src.real_name = "Frycook Dan's Quik-Noodles - Curly Fry Ketchup Hoedown Flavor"
				src.initial_reagents["juice_tomato"] = 3
				src.initial_reagents["mugwort"] = 3
				src.initial_reagents["capsaicin"] = 3
				src.initial_reagents["mashedpotatoes"] = 3
/*				R.add_reagent("juice_tomato",3)
				R.add_reagent("mugwort",3)
				R.add_reagent("capsaicin",3)
				R.add_reagent("mashedpotatoes",3)
*/
			if (12)
				src.real_name = "Morning Dan's Quik-Noodles - Mechanically Reclaimed Sausage Biscuit Flavor"
				src.initial_reagents["ammonia"] = 3
				src.initial_reagents["gravy"] = 4
				src.initial_reagents["badgrease"] = 3
				src.initial_reagents["coffee"] = 3
/*				R.add_reagent("ammonia",3)
				R.add_reagent("gravy",4)
				R.add_reagent("badgrease",3)
				R.add_reagent("coffee",3)
*/
				if (prob(5))
					src.initial_reagents["prions"] = 2.5
					//R.add_reagent("prions",2.5)

			if (13)
				src.real_name = "Devil Dan's Quik-Noodles - Brimstone BBQ Flavor"
				src.initial_reagents["sulfur"] = 5
				src.initial_reagents["beff"] = 5
				src.initial_reagents["el_diablo"] = 5
/*				R.add_reagent("sulfur",5)
				R.add_reagent("beff",5)
				R.add_reagent("ghostchilijuice",5)
*/
			if (14)
				src.real_name = "Dessert Dan's Quik-Noodles - Sweet Sundae Noodle Flavor"
				src.initial_reagents["VHFCS"] = 10
				src.initial_reagents["chocolate"] = 5
				src.initial_reagents["vanilla"] = 2
				src.initial_reagents["milk"] = 3
/*				R.add_reagent("VHFCS", 10)
				R.add_reagent("chocolate", 5)
				R.add_reagent("vanilla", 2)
				R.add_reagent("milk", 3)
*/
		src.UpdateName()
		..()

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	attack_self(mob/user as mob)
		if (activated)
			return

		src.activated = 1
		if (reagents)
			reagents.add_reagent("pyrosium",2)
			reagents.add_reagent("oxygen", 2)
			reagents.handle_reactions()
			SPAWN(10 SECONDS)
				reagents.del_reagent("pyrosium")
		boutput(user, "The cup emits a soft clack as the heater triggers.")
		return

/obj/item/reagent_containers/food/snacks/burrito
	name = "Descuento Danito's Burritos"
	desc = "A self-heating convenience reinterpretation of Mexican cuisine. The exact mechanism used to heat it is probably best left to speculation."
	icon = 'icons/obj/foodNdrink/food_discountdans.dmi'
	icon_state = "burrito"
	bites_left = 3
	heal_amt = 2
	doants = 0 //Ants aren't dumb enough to try to eat these.
	var/activated = 0
	initial_volume = 50
	initial_reagents = list("msg"=9)
	brew_result = list("sewage", "ethanol")
	food_effects = list("food_sweaty")

	New()
		if (prob(75))
			src.initial_reagents["grease"] = 3
		else
			src.initial_reagents["badgrease"] = 3
		switch(rand(1, 9))
			if (1)
				src.real_name = "Descuento Danito's Burritos - Beff and Bean Flavor"
				src.initial_reagents["uranium"] = 2
				src.initial_reagents["beff"] = 4
				src.initial_reagents["fakecheese"] = 4
				src.initial_reagents["refried_beans"] = 10

			if (2)
				src.real_name = "Descuento Danito's Burritos - Strawberrito Churro Flavor"
				src.desc = "There is no way anyone could possibly justify this."
				src.icon_state = "burrito_churro"
				src.initial_reagents["VHFCS"] = 8
				src.initial_reagents["oil"] = 2

			if (3)
				src.real_name = "Descuento Danito's Burritos - Spicy Beans and Wieners Ole! Flavor"
				src.icon_state = "burrito_spicy"
				src.initial_reagents["lithium"] = 4
				src.initial_reagents["capsaicin"] = 6
				src.initial_reagents["refried_beans"] = 10

			if (4)
				src.real_name = "Descuento Danito's Burritos - Pancake Sausage Brunch Flavor"
				src.desc = "A self-heating breakfast burrito with a buttermilk pancake in lieu of a tortilla. A little frightening."
				src.icon_state = "burrito_pancake"
				src.initial_reagents["porktonium"] = 4
				src.initial_reagents["VHFCS"] = 2
				src.initial_reagents["coffee"] = 4

			if (5)
				src.real_name = "Descuento Danito's Burritos - Homestyle Comfort Flavor"
				src.desc = "A self-heating burrito just like Mom used to make, if your mother was a souless, automated burrito production line."
				src.icon_state = "burrito_homestyle"
				src.initial_reagents["mashedpotatoes"] = 5
				src.initial_reagents["gravy"] = 3
				src.initial_reagents["diethylamine"] = 2

			if (6)
				src.real_name = "Spooky Dan's BOO-ritos - Texas Toast Chainsaw Massacre Flavor"
				src.desc = "A self-heating burrito.  Isn't that concept scary enough on its own?"
				src.icon_state = "burrito_texastoast"
				src.initial_reagents["fakecheese"] = 3
				src.initial_reagents["space_drugs"] = 3
				src.initial_reagents["bloodc"] = 4

			if (7)
				src.real_name = "Spooky Dan's BOO-ritos - Nightmare on Elm Meat Flavor"
				src.desc = "A self-heating burrito that purports to contain elm-smoked meat. Of some sort. Probably from an animal."
				src.icon_state = "burrito_elmmeat"
				src.initial_reagents["beff"] = 3
				src.initial_reagents["synthflesh"] = 2
				src.initial_reagents["eyeofnewt"] = 5

			if (8)
				src.real_name = "Sconto Danilo's Burritos - 50% Real Mozzarella Pepperoni Pizza Party Flavor"
				src.desc = "A self-heating pizza burrito."
				src.icon_state = "burrito_pizza"
				src.initial_reagents["fakecheese"] = 3
				src.initial_reagents["cheese"] = 3
				src.initial_reagents["pepperoni"] = 3

			if (9)
				src.real_name = "Descuento Danito's Burritos - Inside Out Burrito"
				src.desc = "You're not even really sure how to eat this."
				src.icon_state = "burrito_rev"
				src.initial_reagents["reversium"] = 5
				src.initial_reagents["refried_beans"] = 10
				src.initial_reagents["beff"] = 3
				src.initial_reagents["fakecheese"] = 3

		src.UpdateName()
		..()

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	attack_self(mob/user as mob)
		if (activated)
			return

		if (prob(10) || user.is_hulk())
			user.visible_message("<span class='alert'><b>[user]</b> snaps the burrito in half!</span>", "<span class='alert'>You accidentally snap the burrito apart. Fuck!</span>")
			src.splat()
			return

		src.activated = 1
		if (reagents)
			reagents.add_reagent("pyrosium",2)
			reagents.add_reagent("oxygen", 2)
			reagents.handle_reactions()
		boutput(user, "You crack the burrito like a glow stick, activating the heater mechanism.")
		return

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		if (prob(10) && T)
			src.splat()
		else
			..()

	heal(var/mob/M)
		..()
		if (prob(5))
			if (M.mind && M.mind.ckey)
				boutput(M, "<span class='notice'>You find a shiny golden ticket in this bite!</span>")
				new /obj/item/ticket/golden(get_turf(M))
			else
				M.emote("choke")

	proc/splat()
		var/turf/T = get_turf(src)
		if(!locate(/obj/decal/cleanable/vomit) in T)
			playsound(T, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
			var/obj/decal/cleanable/vomit/filling = make_cleanable( /obj/decal/cleanable/vomit,src)
			var/icon/fillicon = icon(filling.icon, filling.icon_state)
			fillicon.MapColors(0.5, 0.25, 0)
			filling.icon = fillicon

			filling.name = "burrito filling"
			filling.desc = "The evacuated contents of a burrito."
			filling.reagents = src.reagents
			filling.set_loc(T)

		qdel(src)

/obj/item/reagent_containers/food/snacks/snack_cake
	name = "Little Danny's Snack Cake"
	desc = "A highly-processed miniature cake, coated with a thin layer of solid pseudofrosting."
	icon = 'icons/obj/foodNdrink/food_discountdans.dmi'
	icon_state = "snackcake"
	bites_left = 2
	heal_amt = 2
	var/color_prob = 100
	initial_volume = 50
	initial_reagents = list("badgrease"=3,"VHFCS"=9)
	brew_result = list("sewage", "yuck")
	food_effects = list("food_sweaty")


	golden
		name = "Little Danny's Legally-Distinct Creme-Filled Snack Loaf"
		desc = "A highly-processed miniature sponge cake, filled with some manner of creme."
		icon = 'icons/obj/foodNdrink/food_discountdans.dmi'
		icon_state = "snackcake2"
		color_prob = 10
		brew_result = list("sewage", "mucus")

	New()
		..()
		//reagents.add_reagent("badgrease",3)
		//reagents.add_reagent("VHFCS",9)

		pixel_x = rand(-3,3)
		pixel_y = rand(-3,3)

		var/i = 3
		while(i-- > 0)
			reagents.add_reagent(pick("beff","sugar","eggnog","chocolate","vanilla","cleaner","luminol","poo","urine","nicotine","weedkiller","venom","jenkem","ethanol","ectoplasm","itching","infernite","histamine","foof","pancuronium","cyanide"), 5)

		if (prob(color_prob))
			src.color = random_saturated_hex_color()

	/*heal(var/mob/M)
		if (prob(5))
			if (M.mind && M.mind.ckey)
				boutput(M, "<span class='notice'>You find a shiny platinum ticket in this bite!</span>")
				new /obj/item/ticket/platinum(get_turf(M))
			else
				M.emote("choke")*/

/obj/item/tvdinner
	name = "Hungry Dan's Self-Microwaving Meals"
	desc = "A box containing a self-heating TV dinner."
	icon = 'icons/obj/foodNdrink/food_discountdans.dmi'
	icon_state = "tvdinnerc"
	w_class = W_CLASS_TINY
	throwforce = 2
	var/full = 1
	var/traytype = 0
	flags = ONBELT | TABLEPASS | FPRINT
	stamina_damage = 0
	stamina_cost = 0
	rand_pos = 1

	New()
		src.traytype = rand(1,9)
		switch(src.traytype)
			if (1)
				src.name = "Hungry Dan's Self-Microwaving Meals - Seven Layer Salisbury Steak Flavor"
				src.desc = "A box containing a self-heating TV dinner. There's a picture of a tasty steak on the cover."
			if (2)
				src.name = "Hungry Dan's Self-Microwaving Meals - Partially Baked Spring Chicken Flavor"
				src.desc = "A box containing a self-heating TV dinner. Is this box shaking, or is it just you?"
			if (3)
				src.name = "Hungry Dan's Self-Microwaving Meals - Imported Lo Mein Lasagna Flavor"
				src.desc = "A box containing a self-heating TV dinner. You can't read any of the words on this box!"
			if (4)
				src.name = "Morning Dan's Self-Microwaving Meals - Grand Slam Breakfast Flavor"
				src.desc = "A box containing a self-heating TV dinner. There's a picture of a tasty looking egg, pancake, and sausage breakfast on it"
			if (5)
				src.name = "Corporal Dan's Self-Microwaving Meals - Last Meal Flavor"
				src.desc = "A box containing a self-heating TV dinner. Guaranteed to be your last meal, or else."
			if (6)
				src.name = "Hungry Dan's Self-Microwaving Meals - Macaroni and Cheese Chunks Flavor"
				src.desc = "A box containing a self-heating TV dinner. The bottom of the box says \"may contain research chemicals.\""
			if (7)
				src.name = "Gobbler Dan's Self-Microwaving Meals - Thanksgiving Dinner Flavor"
				src.desc = "A box containing a self-heating TV dinner. Just like your cloning pod used to make."
			if (8)
				src.name = "Hungry Dan's Self-Microwaving Meals - \"Pizza\" Party Flavor"
				src.desc = "A box containing a self-heating TV dinner. There's a picture of a scrumptious pizza on the cover"
			if (9)
				src.name = "Hungry Dan's Self-Microwaving Meals - BBQ Grill Alfredo Noodles Flavor"
				src.desc = "A box containing a self-heating TV dinner. Have \"fusion\" dishes gone too far?"
		return ..()

	attack_hand(mob/user)
		if (user.find_in_hand(src))//r_hand == src || user.l_hand == src)
			if (src.full == 0)
				user.show_text("The box is empty[prob(20) ? " (much like your head)" : null].", "red")
				user.add_karma(-0.1)
				return
			else
				var/obj/item/reagent_containers/food/snacks/tvdinner/W = new /obj/item/reagent_containers/food/snacks/tvdinner(null, src.traytype)
				user.put_in_hand_or_drop(W)
				src.full = 0
				src.icon_state = "tvdinnero"
				src.desc = "An empty TV dinner box."
				return
		else
			return ..()



/obj/item/reagent_containers/food/snacks/tvdinner
	name = "Hungry Dan's Self-Microwaving Meals"
	desc = "A self-heating TV dinner. You should probably use a fork."
	icon = 'icons/obj/foodNdrink/food_discountdans.dmi'
	icon_state = "tvdinnert"
	needfork = 1
	bites_left = 2
	heal_amt = 2
	doants = 0 //Ants aren't dumb enough to try to eat these.
	var/activated = 0
	initial_volume = 50
	food_effects = list("food_hp_up")

	New(loc, var/traytype = 0)

		if(!islist(initial_reagents)) initial_reagents = list()
		if (prob(75))
			src.initial_reagents["grease"] = 3
		else
			src.initial_reagents["badgrease"] = 3
		src.initial_reagents["msg"] = 9
		src.initial_reagents["nicotine"] = 3
		src.initial_reagents["salt"] = 5
		if(!traytype)
			traytype = rand(1, 9)
		switch(traytype)
			if (1)
				src.name = "Hungry Dan's Self-Microwaving Meals - Seven Layer Salisbury Steak Flavor" //Seven layers of reconsituted meat product
				src.desc = "A self-heating TV dinner containing a squashed brown mess. You should probably use a fork."
				src.initial_reagents["beff"] = 7
				src.initial_reagents["bread"] = 3
				src.initial_reagents["juice_tomato"] = 10
				src.initial_reagents["cornstarch"] = 10


			if (2)
				src.name = "Hungry Dan's Self-Microwaving Meals - Partially Baked Spring Chicken Flavor" //So spring it's an egg
				src.desc = "A self-heating TV dinner. Is... this still moving? You should probably use a fork."
				src.initial_reagents["THC"] = 4.20
				src.initial_reagents["oil"] = 10
				if (prob(5))
					src.initial_reagents["flaptonium"] = 5 //the egg hatched
				else
					src.initial_reagents["chickensoup"] = 5
					src.initial_reagents["egg"] = 5 //hadn't hatched yet
				src.initial_reagents["chocolate"] = 5 //chocolate brownie


			if (3)
				src.name = "Hungry Dan's Self-Microwaving Meals - Imported Lo Mein Lasagna Flavor" //Imported from swede-land
				src.desc = "A self-heating TV dinner containing a well-travelled chinese lasagna. You should probably use a fork."
				src.initial_reagents["juice_tomato"] = 5
				src.initial_reagents["swedium"] = 5
				src.initial_reagents["bread"] = 10
				src.initial_reagents["fakecheese"] = 2

			if (4)
				src.name = "Morning Dan's Self-Microwaving Meals - Grand Slam Breakfast Flavor" //A real knockout
				desc = "A self-heating TV dinner that'll knock you out of the park. You should probably use a fork."
				src.initial_reagents["porktonium"] = 4
				src.initial_reagents["VHFCS"] = 2
				src.initial_reagents["coffee"] = 4
				src.initial_reagents["egg"] = 4
				src.initial_reagents["george_melonium"] = 1 //IT'S OUTTA THE PARK

			if (5)
				src.name = "Corporal Dan's Self-Microwaving Meals - Last Meal Flavor" //Your last meal, or else!
				src.desc = "A self-heating TV dinner that's guaranteed to be your last meal, or else. You should probably use a fork."
				src.initial_reagents["gravy"] = 10
				src.initial_reagents["beff"] = 4
				if (prob(5))
					src.initial_reagents["curare"] = 2
				else
					src.initial_reagents["capulettium"] = 5


			if (6)
				src.name = "Hungry Dan's Self-Microwaving Microwaveable Meals - Macaroni and Cheese Flavor"
				src.desc = "A self-heating TV dinner containing a multicolored macaroni and cheese. You should probably use a fork."
				src.initial_reagents["fakecheese"] = 4
				src.initial_reagents["LSD"] = 2
				src.initial_reagents["bread"] = 3


			if (7)
				src.name = "Gobbler Dan's Self-Microwaving Meals - Thanksgiving Dinner Flavor"
				src.desc = "A self-heating TV dinner that looks so filling you're yawning just thinking about it. You should probably use a fork."
				src.initial_reagents["blood"] = 4
				src.initial_reagents["synthflesh"] = 3
				src.initial_reagents["ketamine"] = 1
				src.initial_reagents["VHFCS"] = 4
				src.initial_reagents["mashedpotatoes"] = 5
				src.initial_reagents["gravy"] = 5

			if (8)
				src.name = "Hungry Dan's Self-Microwaving Meals - \"Pizza\" Party Flavor"
				src.desc = "A self-heating TV dinner containing a \"pizza\". You should probably use a fork."
				src.initial_reagents["fakecheese"] = 6
				src.initial_reagents["pepperoni"] = 3
				src.initial_reagents["paper"] = 3
				src.initial_reagents["mercury"] = 1

			if (9)
				src.name = "Hungry Dan's Self-Microwaving Meals - BBQ Grill Alfredo Noodles Flavor"
				src.desc = "A self-heating TV dinner saltier than Lot's wife. You should probably use a fork."
				src.initial_reagents["salt"] = 10
				src.initial_reagents["ectoplasm"] = 1 //Insert joke about deadchat here
				src.initial_reagents["bread"] = 3
				src.initial_reagents["chickensoup"] = 3
				src.initial_reagents["cheese"] = 3
				src.initial_reagents["capsaicin"] = 5
				src.initial_reagents["hydrogen"] = 5
		..()


	attack_self(mob/user as mob)
		if (activated)
			return

		src.activated = 1
		if (reagents)
			reagents.add_reagent("pyrosium",2)
			reagents.add_reagent("oxygen", 2)
			reagents.add_reagent("radium", 1) //Self Microwaving?!
			reagents.handle_reactions()
		boutput(user, "You twist the tray, activating the heater mechanism.")
		user.add_karma(-6)
		return

	heal(var/mob/M)
		..()
		if (prob(8))
			if (M.mind && M.mind.ckey)
				boutput(M, "<span class='notice'>You find a shiny golden ticket in this bite!</span>")
				new /obj/item/ticket/golden(get_turf(M))
			else
				M.emote("choke")

/obj/item/reagent_containers/food/snacks/strudel
	name = "Delectable Dan's Scrumptious Strudel"
	desc = "A gigantic toaster strudel with a fruit filling. It looks pretty decent!"
	icon = 'icons/obj/foodNdrink/food_discountdans.dmi'
	icon_state = "strudel"
	bites_left = 2
	heal_amt = 2
	doants = 0
	initial_volume = 30
	initial_reagents = list("juice_strawberry"=15,"vanilla"=6)
	food_effects = list("food_energized")

	New()
		..()

		var/i = 3
		while(i-- > 0)
			reagents.add_reagent(pick("beff","sugar","eggnog","chocolate","cleaner","luminol","poo","urine","nicotine","mint","tea","juice_lemon","juice_lime","juice_apple","juice_cherry","guacamole","egg","sewage","uranium"), 3)


	heal(var/mob/M)
		..()
		if (prob(5))
			if (M.mind && M.mind.ckey)
				boutput(M, "<span class='notice'>You find a shiny golden ticket in this bite!</span>")
				new /obj/item/ticket/golden(get_turf(M))
			else
				M.emote("choke")
