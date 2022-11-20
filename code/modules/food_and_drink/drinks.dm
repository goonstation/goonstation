
// Drinks

/obj/item/reagent_containers/food/drinks/bottle/soda/red
	name = "Robust-Eez"
	desc = "A carbonated robustness tonic. It has quite a kick."
	label = "robust"
	heal_amt = 1
	labeled = 1
	initial_volume = 50
	initial_reagents = list("methamphetamine"=5,"VHFCS"=10,"cola"=15)

/obj/item/reagent_containers/food/drinks/bottle/soda/blue
	name = "Grife-O"
	desc = "The carbonated beverage of a space generation. Contains actual space dust!"
	label = "grife"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("radium"=3,"ephedrine"=6,"VHFCS"=10,"cola"=11)

/obj/item/reagent_containers/food/drinks/bottle/soda/pink
	name = "Dr. Pubber"
	desc = "The beverage of an original crowd. Tastes like an industrial tranquilizer."
	label = "pubber"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("haloperidol"=4,"morphine"=4,"VHFCS"=10,"cola"=12)

/obj/item/reagent_containers/food/drinks/bottle/soda/lime
	name = "Lime-Aid"
	desc = "Antihol mixed with lime juice. A well-known cure for hangovers."
	label = "limeaid"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("antihol"=20,"juice_lime"=20)

/obj/item/reagent_containers/food/drinks/bottle/soda/spooky
	name = "Spooky Dan's Runoff Cola"
	desc = "A spoooky cola for Halloween!  Rumors that Runoff Cola contains actual industrial runoff are unsubstantiated."
	label = "spooky"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("chlorine"=5,"phosphorus"=5,"mercury"=5,"VHFCS"=10,"cola"=15)

/obj/item/reagent_containers/food/drinks/bottle/soda/spooky2
	name = "Spooky Dan's Horrortastic Cola"
	desc = "A terrifying Halloween soda.  It's especially frightening if you're diabetic."
	label = "spooky"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("ectoplasm"=10,"sulfur"=5,"VHFCS"=5,"cola"=20)

/obj/item/reagent_containers/food/drinks/bottle/soda/xmas
	name = "Happy Elf Hot Chocolate"
	desc = "Surprising to see this here, in a world of corporate plutocrat lunatics."
	label = "choco"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("chocolate"=45)

	New()
		if (prob(10))
			src.initial_reagents["grognardium"] = 5
		..()

/obj/item/reagent_containers/food/drinks/bottle/soda/bottledwater
	name = "Decirprevo Bottled Water"
	desc = "Bottled from our cool natural springs on Europa."
	label = "water"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("iodine"=5,"water"=45)

/obj/item/reagent_containers/food/drinks/bottle/soda/softsoft_pizza
	name = "Soft Soft Pizza"
	desc = "Pizza so soft you can drink it!"
	label= "pizza"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("pizza" = 40, "salt" = 10)

/obj/item/reagent_containers/food/drinks/bottle/soda/grones
	name = "Grones Soda "
	desc = "They make all kinds of flavors these days, good lord."
	label = "grones"
	heal_amt = 1
	labeled = 1
	initial_volume = 50
	initial_reagents = list("cola"=20)

	New()
		switch(rand(1,16))
			if (1)
				src.name += "Crunchy Kidney Stone Lemonade flavor"
				src.initial_reagents["urine"] = 10
			if (2)
				src.name += "Radical Roadkill Rampage flavor"
				src.initial_reagents["bloodc"] = 10 // heh
			if (3)
				src.name += "Awesome Asbestos Candy Apple flavor"
				src.initial_reagents["lithium"] = 10
			if (4)
				src.name += "Salt-Free Senile Dementia flavor"
				src.initial_reagents["mercury"] = 10
			if (5)
				src.name += "High Fructose Traumatic Stress Disorder flavor"
				src.initial_reagents["atropine"] = 10
			if (6)
				src.name += "Tangy Dismembered Orphan Tears flavor"
				src.initial_reagents["epinephrine"] = 10
			if (7)
				src.name += "Chunky Infected Laceration Salsa flavor"
				src.initial_reagents["charcoal"] = 10
			if (8)
				src.name += "Manic Depressive Multivitamin Dewberry flavor"
				src.initial_reagents["ephedrine"] = 10
			if (9)
				src.name += "Anti-Bacterial Air Freshener flavor"
				src.initial_reagents["spaceacillin"] = 10
			if (10)
				src.name += "Old Country Hay Fever flavor"
				src.initial_reagents["antihistamine"] = 10
			if (11)
				src.name += "Minty Restraining Order Pepper Spray flavor"
				src.initial_reagents["capsaicin"] = 10
			if (12)
				src.name += "Cool Keratin Rush flavor"
				src.initial_reagents["hairgrownium"] = 10
			if (13)
				src.name += "Rancher's Rage Whole Chicken Dinner flavor" //by Splints/FireMoose
				src.initial_reagents += (list("chickensoup"=10, "juice_cran"=5, "juice_carrot"=5, "mashedpotatoes"=3,
				 "gravy"=2, "ether"=5))
				src.label = "rancher"
			if (14)
				src.name += "Prismatic Rainbow Punch flavor" //by Genesse
				src.initial_reagents += (list("sparkles"=10, "colors"=10, "space_drugs"=10))
				src.label = "rainbow"
			if (15)
				src.name += "Hearty Hellburn Brew flavor" //by Eagletanker
				src.initial_reagents += (list("oxygen"=18, "plasma"=8, "ghostchilijuice"=1, "carbon"=3))
				src.desc = "9/10 Engineers prefered Grones Hearty Hellburn, find out why yourself!"
				src.label = "engine"
			if (16)
				src.name += "Citrus Circus Catastrophe flavor" //by Coolvape
				src.initial_reagents += (list("juice_lemon"=10, "juice_lime"=10, "honk_fart"=5, "honky_tonic"=5))
				src.label = "clown"

		..()

/obj/item/reagent_containers/food/drinks/bottle/soda/orange
	name = "Orange-Aid"
	desc = "A vitamin tonic that promotes good eyesight and health."
	label = "orangeaid"
	heal_amt = 1
	labeled = 1
	initial_volume = 50
	initial_reagents = list("oculine"=20,"juice_orange"=20)

/obj/item/reagent_containers/food/drinks/bottle/soda/gingerale
	name = "Delightful Dan's Ginger Ale"
	desc = "Ginger ale is known for its soothing, healing, and beautifying properties. So claims this compostable, recycled, and eco-friendly paper label."
	label = "gingerale"
	heal_amt = 1
	labeled = 1
	initial_volume = 50
	initial_reagents = "ginger_ale"

/obj/item/reagent_containers/food/drinks/bottle/soda/drowsy
	name = "Drowsy Dan's Terrific Tonic"
	desc = "You'll be fast asleep in no time!"
	label = "drowsy"
	heal_amt = 1
	labeled = 1
	initial_volume = 50
	initial_reagents = list("lemonade"=25,"ether"=25)

/obj/item/reagent_containers/food/drinks/water
	name = "water bottle"
	desc = "I wonder if this is still fresh?"
	icon_state = "water"
	item_state = "water"
	initial_volume = 25
	initial_reagents = "water"

/obj/item/reagent_containers/food/drinks/mate
	name = "mate gourd"
	desc = "A gourd and a straw for drinking mate"
	icon_state = "mate_empty"
	initial_volume = 20
	var/yerba_left = 0
	var/water_amount

	on_reagent_change()
		if((yerba_left > 1) && reagents.get_reagent_amount("water") > 0)
			changetomate()
		if((yerba_left < 1) && !reagents.get_reagent_amount("mate"))
			yerba_left = 0
			icon_state = "mate_empty"
		..()

	proc/changetomate()
		water_amount = src.reagents.get_reagent_amount("water")
		src.reagents.remove_reagent("water", water_amount)
		src.reagents.add_reagent("mate", water_amount)
		yerba_left -= water_amount
		return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/yerba))
			src.icon_state = "mate"
			yerba_left = 100
			boutput(user, "<span class='notice'>You add [W] to [src]!</span>")
			qdel (W)
		else ..()

/obj/item/reagent_containers/food/drinks/tea
	name = "tea"
	desc = "A fine cup of tea.  Possibly Earl Grey.  Temperature undetermined."
	icon_state = "tea0"
	item_state = "coffee"
	initial_volume = 50
	initial_reagents = "tea"

/obj/item/reagent_containers/food/drinks/tea/mugwort
	name = "mugwort tea"
	desc = "Rumored to have mystical powers of protection.<br>It has a message written on it: 'To the world's greatest wizard - love, Dad'"
	icon_state = "tea1"
	initial_volume = 50
	initial_reagents = list("tea"=30,"mugwort"=20)

/obj/item/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	heal_amt = 1
	initial_volume = 50
	initial_reagents = list("coffee"=30)

/obj/item/reagent_containers/food/drinks/chickensoup
	name = "Chicken Soup"
	desc = "Got something to do with souls. Maybe. Do chickens even have souls?"
	icon_state = "soup"
	heal_amt = 1
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	initial_volume = 50
	can_recycle = FALSE
	initial_reagents = list("chickensoup"=30)

/obj/item/reagent_containers/food/drinks/fruitmilk
	name = "Creaca's Fruit Milk "
	desc = "Milk and 'fruit' of undetermined origin; finally, together at last."
	icon_state = "fruitmilk"
	initial_volume = 50
	can_recycle = FALSE
	initial_reagents = list("milk"=20)

	New()
		switch(rand(1,10))
			if (1)
				src.name += "Synthetic Tropical Dawn flavor"
				src.initial_reagents["juice_pineapple"] = 30
			if (2)
				src.name += "Changing Cherry Red flavor"
				src.initial_reagents["juice_cherry"] = 30
			if (3)
				src.name += "Curdled Lemon Twist flavor"
				src.initial_reagents["juice_lemon"] = 30
			if (4)
				src.name += "Earth Dreamer Lime flavor"
				src.initial_reagents["juice_lime"] = 30
			if (5)
				src.name += "Odyssey Orange flavor"
				src.initial_reagents["juice_orange"] = 30
			if (6)
				src.name += "Strawberry and Cream flavor"
				src.initial_reagents["juice_strawberry"] = 30
			if (7)
				src.name += "Seasonal Peach Blossom flavor"
				src.initial_reagents["juice_peach"] = 30
			if (8)
				src.name += "Surprise Mystery flavor"
				src.initial_reagents["juice_pickle"] = 20
				src.initial_reagents["neurodepressant"] = 5
				src.initial_reagents["msg"] = 5
			if (9)
				src.name += "Little Soups flavor"
				src.initial_reagents["juice_tomato"] = 30
			if (10)
				src.name += "Artifical Autumn flavor"
				src.initial_reagents["juice_pumpkin"] = 30

		..()


/obj/item/reagent_containers/food/drinks/weightloss_shake
	name = "Weight-Loss Shake"
	desc = "A shake designed to cause weight loss.  The package proudly proclaims that it is 'tapeworm free.'"
	icon_state = "shake"
	heal_amt = 1
	rc_flags = RC_FULLNESS
	initial_volume = 50
	initial_reagents = list("lipolicide"=30,"chocolate"=5)

/obj/item/reagent_containers/food/drinks/cola
	name = "space cola"
	desc = "Cola. in space."
	icon = 'icons/obj/foodNdrink/can.dmi'
	icon_state = "cola-1-small"
	item_state = "cola-1"
	heal_amt = 1
	rc_flags = RC_FULLNESS
	initial_volume = 50
	can_chug = 0
	initial_reagents = list("cola"=20,"VHFCS"=10)
	var/is_sealed = 1 //can you drink out of it?
	var/standard_override //is this a random cola or a standard cola (for crushed icons)

	New()
		..()
		setup_soda()

	attack(mob/M, mob/user)
		if (is_sealed)
			boutput(user, "<span class='alert'>You can't drink out of a sealed can!</span>") //idiot
			return
		..()

	attack_self(mob/user as mob)
		var/drop_this_shit = 0 //i promise this is useful
		if (src.is_sealed)
			user.visible_message("[user] pops the tab on \the [src]!", "You pop \the [src] open!")
			is_sealed = 0
			can_chug = 1
			playsound(src.loc, 'sound/items/can_open.ogg', 50, 1)
			return
		if (!src.reagents || !src.reagents.total_volume)
			var/zone = user.zone_sel.selecting
			if (zone == "head")
				user.visible_message("<span class='alert'><b>[user] crushes \the [src] against their forehead!! [pick("Bro!", "Epic!", "Damn!", "Gnarly!", "Sick!",\
				"Crazy!", "Nice!", "Hot!", "What a monster!", "How sick is that?", "That's slick as shit, bro!")]", "You crush the can against your forehead! You feel super cool.")
				drop_this_shit = 1
			else
				user.visible_message("[user] crushes \the [src][pick(" one-handed!", ".", ".", ".")] [pick("Lame.", "Eh.", "Meh.", "Whatevs.", "Weirdo.")]", "You crush the can!")
			var/obj/item/crushed_can/C = new(get_turf(user))
			playsound(src.loc, "sound/items/can_crush-[rand(1,3)].ogg", 50, 1)
			C.crush_can(src.name, src.icon_state)
			user.u_equip(src)
			user.drop_item(src)
			if (!drop_this_shit) //see?
				user.put_in_hand_or_drop(C)
			qdel(src)

	is_open_container()
		return !is_sealed


	proc/setup_soda() // made to be overridden, so that the Spess-Pepsi/Space-Coke debacle can continue
		if (prob(50)) // without having to change the Space-Cola path
			src.icon_state = "cola-2-small"

/obj/item/crushed_can
	name = "crushed can"
	desc = "This can's been totally crushed!"
	icon = 'icons/obj/foodNdrink/can.dmi'
	w_class = W_CLASS_TINY

	proc/crush_can(var/name, var/icon_state)
		src.name = "crushed [name]"
		switch(icon_state)
			if ("cola-1")
				src.icon_state = "crushed-1"
				return
			if ("cola-2")
				src.icon_state = "crushed-2"
				return
		var/list/iconsplit = splittext("[icon_state]", "-")
		src.icon_state = "crushed-[iconsplit[2]]"

/obj/item/reagent_containers/food/drinks/cola/random
	name = "space cola"
	desc = "You don't recognise this cola brand at all."
	icon = 'icons/obj/foodNdrink/can.dmi'
	heal_amt = 1
	rc_flags = RC_FULLNESS
	initial_volume = 50

	New()
		..()
		name = "[pick_string("chemistry_tools.txt", "COLA_prefixes")] [pick_string("chemistry_tools.txt", "COLA_suffixes")]"
		var/n = rand(1,26)
		icon_state = "cola-[n]"
		reagents.add_reagent("cola, 20")
		reagents.add_reagent("VHFCS, 10")
		reagents.add_reagent(pick_string("chemistry_tools.txt", "COLA_flavors"), 5, 3)

/obj/item/reagent_containers/food/drinks/cola/custom
	name = "beverage can"
	desc = "An aluminium can with custom branding."
	icon = 'icons/obj/foodNdrink/can.dmi'
	heal_amt = 1
	icon_state = "cola-13"
	rc_flags = RC_FULLNESS
	initial_reagents = null
	initial_volume = 50

	New()
		..()

	setup_soda()
		return

	small
		icon_state = "cola-13-small"
		initial_volume = 30



/obj/item/reagent_containers/food/drinks/peach
	name = "Delightful Dan's Peachy Punch"
	desc = "A vibrantly colored can of 100% all natural peach juice."
	icon = 'icons/obj/foodNdrink/can.dmi'
	icon_state = "peach"
	rc_flags = RC_FULLNESS
	initial_volume = 50
	initial_reagents = "juice_peach"

/obj/item/reagent_containers/food/drinks/milk
	name = "Creaca's Space Milk"
	desc = "A bottle of fresh space milk from happy, free-roaming space cows."
	icon_state = "milk"
	item_state = "milk"
	var/icon_style = "milk"
	var/glass_style = "milk"
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	heal_amt = 1
	initial_volume = 50
	initial_reagents = "milk"
	var/canberandom = 1

	var/image/fluid_image

	on_reagent_change()
		..()
		src.UpdateIcon()

	update_icon()
		src.underlays = null
		if (src.icon_state == "milk_calcium")
			return
		if (reagents.total_volume)
			var/fluid_state = round(clamp((src.reagents.total_volume / src.reagents.maximum_volume * 3 + 1), 1, 3))
			if (!src.fluid_image)
				src.fluid_image = image(src.icon, "fluid-milk[fluid_state]", -1)
			else
				src.fluid_image.icon_state = "fluid-milk[fluid_state]"
			src.icon_state = "milk[fluid_state]"
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.underlays += fluid_image
		else
			src.icon_state = "milk"

	New()
		..()
		if(canberandom == 1)
			if(prob(10))
				name = "Mootimer's Calcium Drink"
				desc = "Blue-ribbon winning secret family recipe."
				icon_state = "milk_calcium"

/obj/item/reagent_containers/food/drinks/milk/rancid
	name = "Rancid Space Milk"
	desc = "A bottle of rancid space milk. Better not drink this stuff."
	icon_state = "milk"
	heal_amt = 1
	initial_volume = 50
	initial_reagents = list("milk"=25,"toxin"=25)

/obj/item/reagent_containers/food/drinks/milk/clownspider
	name = "Honkey Gibbersons - Clownspider Milk"
	desc = "A bottle of really - really colorful milk? The smell is sweet and looking at this envokes the same thrill as wanting to drink paint!"
	icon_state = "milk"
	heal_amt = 1
	initial_volume = 50
	initial_reagents = list("rainbow fluid" = 7, "milk" = 19)
	canberandom = 0

/obj/item/reagent_containers/food/drinks/milk/cluwnespider
	name = "Honkey Gibbersons - Cluwnespider Milk"
	desc = "A bottle of ... oh no! Do not look at it! Better never drink this colorful milk?!"
	icon_state = "milk"
	heal_amt = 1
	initial_volume = 50
	initial_reagents = list("painbow fluid" = 13, "milk" = 20)
	canberandom = 0

/obj/item/reagent_containers/food/drinks/milk/soy
	name = "Creaca's Space Soy Milk"
	desc = "A bottle of fresh space soy milk from happy, free-roaming space soybean plants. The plant pots just float around untethered."

obj/item/reagent_containers/food/drinks/covfefe
	name = "Wired Dan's Kafe Kick!"
	desc = "Some kind of ersatz drink that can't legally be called coffee. Actually, it's mostly water and whatever they could get cheap that day. Wait, wasn't this banned by the FDA?"
	icon_state = "coffee"
	heal_amt = 1
	initial_volume = 50

	New()
		..()
		if(prob(1)) // hi im cirr i fuck with peoples' patches hurr
			name = "Wired Dan's Chilled Covfefe"
			reagents.add_reagent("cryostylane", 5)
		reagents.add_reagent("water", 25)
		reagents.add_reagent("VHFCS", 5)
		reagents.add_reagent(pick("methamphetamine", "crank", "space_drugs", "cat_drugs", "coffee"), 5)
		for(var/i=0; i<3; i++)
			reagents.add_reagent(pick("beff","ketchup","eggnog","yuck","chocolate","vanilla","cleaner","capsaicin","toxic_slurry","luminol","urine","nicotine","weedkiller","venom","jenkem","ectoplasm"), 5)

/obj/item/reagent_containers/food/drinks/bottle/soda/contest
	name = "Grones Soda Call 1-800-IMCODER flavour"
	desc = "They make all kinds of flavors these days, good lord."
	label = "grones"
	heal_amt = 1
	labeled = 1
	initial_volume = 50

	lizard_tonic
		name = "Grones Soda Lucky Lizard Tonic flavor" //by Rlocks
		label = "lizard"
		initial_reagents = (list("cola"=20, "yee"=5, "chalk"=5, "sangria"=10, "capsaicin"=10))


	babel_blast
		name = "Grones Soda Mountain Grones Babel Blast flavor" //by warcrimes
		label = "babel"
		initial_reagents = (list("cola"=20, "suomium"=5, "quebon"=5, "swedium"=5, "caledonium"=5, "worcestershire_sauce"=5))

	jungle_juice
		name = "Grones Soda Jammin' Jambalaya Jungle Juice flavor" //by Camryn Buttes
		label = "jungle"
		initial_reagents = (list("cola"=20, "strawberry_milk"=1, "ricewine"=1, "boorbon"=1, "diesel"=1, "irishcoffee"=1,
		"vanilla"=1, "harlow"=1, "espressomartini"=1, "ectocooler"=1, "bread"=1, "sarsaparilla"=1, "eggnog"=1,
		"chocolate"=1, "guacamole"=1, "salt"=1, "gravy"=1, "mashedpotatoes"=1, "msg"=1, "mugwort"=1, "juice_cran"=1,
		"juice_blueberry"=1, "juice_grapefruit"=1, "juice_pickle"=1, "worcestershire_sauce"=1, "fakecheese"=1,
		"capsaicin"=1, "urine"=1, "paper"=1, "chalk"=1)) //pain; a little of everything
