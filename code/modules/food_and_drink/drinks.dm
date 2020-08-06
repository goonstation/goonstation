
// Drinks

/obj/item/reagent_containers/food/drinks/bottle/red
	name = "Robust-Eez"
	desc = "A carbonated robustness tonic. It has quite a kick."
	label = "robust"
	heal_amt = 1
	labeled = 1
	initial_volume = 50
	initial_reagents = list("methamphetamine"=3,"VHFCS"=10,"cola"=17)

/obj/item/reagent_containers/food/drinks/bottle/blue
	name = "Grife-O"
	desc = "The carbonated beverage of a space generation. Contains actual space dust!"
	label = "grife"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("radium"=3,"ephedrine"=6,"VHFCS"=10,"cola"=11)

/obj/item/reagent_containers/food/drinks/bottle/pink
	name = "Dr. Pubber"
	desc = "The beverage of an original crowd. Tastes like an industrial tranquilizer."
	label = "pubber"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("haloperidol"=4,"morphine"=4,"VHFCS"=10,"cola"=12)

/obj/item/reagent_containers/food/drinks/bottle/lime
	name = "Lime-Aid"
	desc = "Antihol mixed with lime juice. A well-known cure for hangovers."
	label = "limeaid"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("antihol"=20,"juice_lime"=20)

/obj/item/reagent_containers/food/drinks/bottle/spooky
	name = "Spooky Dan's Runoff Cola"
	desc = "A spoooky cola for Halloween!  Rumors that Runoff Cola contains actual industrial runoff are unsubstantiated."
	label = "spooky"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("chlorine"=5,"phosphorus"=5,"mercury"=5,"VHFCS"=10,"cola"=15)

/obj/item/reagent_containers/food/drinks/bottle/spooky2
	name = "Spooky Dan's Horrortastic Cola"
	desc = "A terrifying Halloween soda.  It's especially frightening if you're diabetic."
	label = "spooky"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("ectoplasm"=10,"sulfur"=5,"VHFCS"=5,"cola"=20)

/obj/item/reagent_containers/food/drinks/bottle/xmas
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

/obj/item/reagent_containers/food/drinks/bottle/bottledwater
	name = "Decirprevo Bottled Water"
	desc = "Bottled from our cool natural springs on Europa."
	label = "water"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("iodine"=5,"water"=45)

/obj/item/reagent_containers/food/drinks/bottle/softsoft_pizza
	name = "Soft Soft Pizza"
	desc = "Pizza so soft you can drink it!"
	label= "pizza"
	labeled = 1
	initial_volume = 50
	initial_reagents = list("pizza" = 40, "salt" = 10)

/obj/item/reagent_containers/food/drinks/bottle/grones
	name = "Grones Soda"
	desc = "They make all kinds of flavors these days, good lord."
	label = "grones"
	heal_amt = 1
	labeled = 1
	initial_volume = 50
	initial_reagents = list("cola"=20)

	New()
		switch(rand(1,14))
			if (1)
				src.desc = "Wicked Sick Pumpkin Prolapse flavor."
				src.initial_reagents["diarrhea"] = 10
			if (2)
				src.desc = "Ballin' Banana Testicular Torsion flavor."
				src.initial_reagents["urine"] = 10
			if (3)
				src.desc = "Radical Roadkill Rampage flavor."
				src.initial_reagents["bloodc"] = 10 // heh
			if (4)
				src.desc = "Sweet Cherry Brain Haemorrhage flavor."
				src.initial_reagents["impedrezine"] = 10
			if (5)
				src.desc = "Awesome Asbestos Candy Apple flavor."
				src.initial_reagents["lithium"] = 10
			if (6)
				src.desc = "Salt-Free Senile Dementia flavor."
				src.initial_reagents["mercury"] = 10
			if (7)
				src.desc = "High Fructose Traumatic Stress Disorder flavor."
				src.initial_reagents["atropine"] = 10
			if (8)
				src.desc = "Tangy Dismembered Orphan Tears flavor."
				src.initial_reagents["epinephrine"] = 10
			if (9)
				src.desc = "Chunky Infected Laceration Salsa flavor."
				src.initial_reagents["charcoal"] = 10
			if (10)
				src.desc = "Manic Depressive Multivitamin Dewberry flavor."
				src.initial_reagents["ephedrine"] = 10
			if (11)
				src.desc = "Anti-Bacterial Air Freshener flavor."
				src.initial_reagents["spaceacillin"] = 10
			if (12)
				src.desc = "Old Country Hay Fever flavor."
				src.initial_reagents["antihistamine"] = 10
			if (13)
				src.desc = "Minty Restraining Order Pepper Spray flavor."
				src.initial_reagents["capsaicin"] = 10
			if (14)
				src.desc = "Cool Keratin Rush flavor."
				src.initial_reagents["hairgrownium"] = 10
		..()

/obj/item/reagent_containers/food/drinks/bottle/orange
	name = "Orange-Aid"
	desc = "A vitamin tonic that promotes good eyesight and health."
	label = "orangeaid"
	heal_amt = 1
	labeled = 1
	initial_volume = 50
	initial_reagents = list("oculine"=20,"juice_orange"=20)

/obj/item/reagent_containers/food/drinks/bottle/gingerale
	name = "Delightful Dan's Ginger Ale"
	desc = "Ginger ale is known for its soothing, healing, and beautifying properties. So claims this compostable, recycled, and eco-friendly paper label."
	label = "gingerale"
	heal_amt = 1
	labeled = 1
	initial_volume = 50
	initial_reagents = "ginger_ale"

/obj/item/reagent_containers/food/drinks/bottle/drowsy
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
	icon = 'icons/obj/items/items.dmi'
	icon_state = "bottlewater"
	item_state = "contliquid"
	initial_volume = 50
	initial_reagents = "water"

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
	module_research = list("vice" = 5)

/obj/item/reagent_containers/food/drinks/eggnog
	name = "Egg Nog"
	desc = "A festive beverage made with eggs. Please eat the eggs. Eat the eggs up."
	icon_state = "nog"
	heal_amt = 1
	festivity = 1
	rc_flags = RC_FULLNESS
	initial_volume = 50
	initial_reagents = list("eggnog"=40)
	module_research = list("vice" = 5)
	module_research_type = /obj/item/reagent_containers/food/drinks/bottle/beer

/obj/item/reagent_containers/food/drinks/chickensoup
	name = "Chicken Soup"
	desc = "Got something to do with souls. Maybe. Do chickens even have souls?"
	icon_state = "soup"
	heal_amt = 1
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	initial_volume = 50
	initial_reagents = list("chickensoup"=30)

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
	icon_state = "cola"
	item_state = "cola"
	heal_amt = 1
	rc_flags = RC_FULLNESS
	initial_volume = 50
	initial_reagents = list("cola"=20,"VHFCS"=10)
	var/is_sealed = 1 //can you drink out of it?
	var/standard_override //is this a random cola or a standard cola (for crushed icons)

	New()
		..()
		if (prob(50))
			src.icon_state = "cola-blue"

	attack(mob/M as mob, mob/user as mob)
		if (is_sealed)
			boutput(user, "<span class='alert'>You can't drink out of a sealed can!</span>") //idiot
			return
		..()

	attack_self(mob/user as mob)
		var/drop_this_shit = 0 //i promise this is useful
		if (src.is_sealed)
			user.visible_message("[user] pops the tab on \the [src]!", "You pop \the [src] open!")
			is_sealed = 0
			playsound(src.loc, "sound/items/can_open.ogg", 50, 1)
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
			C.set_stuff(src.name, src.icon_state)
			user.u_equip(src)
			user.drop_item(src)
			if (!drop_this_shit) //see?
				user.put_in_hand_or_drop(C)
			qdel(src)

/obj/item/crushed_can
	name = "crushed can"
	desc = "This can's been totally crushed!"
	icon = 'icons/obj/foodNdrink/can.dmi'

	proc/set_stuff(var/name, var/icon_state)
		src.name = "crushed [name]"
		if (icon_state == "cola" || "cola-blue")
			switch(icon_state)
				if ("cola")
					src.icon_state = "crushed-1"
					return
				if ("cola-blue")
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
		name = "[pick(COLA_prefixes)] [pick(COLA_suffixes)]"
		var/n = rand(1,26)
		icon_state = "cola-[n]"
		reagents.add_reagent("cola, 20")
		reagents.add_reagent("VHFCS, 10")
		reagents.add_reagent(pick(COLA_flavors), 5,3)

///////////

/var/list/COLA_prefixes = strings("chemistry_tools.txt", "COLA_prefixes")
/var/list/COLA_suffixes = strings("chemistry_tools.txt", "COLA_suffixes")
/var/list/COLA_flavors = strings("chemistry_tools.txt", "COLA_flavors")

///////////

/obj/item/reagent_containers/food/drinks/peach
	name = "Delightful Dan's Peachy Punch"
	desc = "A vibrantly colored can of 100% all natural peach juice."
	icon_state = "peach"
	rc_flags = RC_FULLNESS
	initial_volume = 50
	initial_reagents = "juice_peach"

/obj/item/reagent_containers/food/drinks/milk
	name = "Creaca's Space Milk"
	desc = "A bottle of fresh space milk from happy, free-roaming space cows."
	icon_state = "milk"
	heal_amt = 1
	initial_volume = 50
	initial_reagents = "milk"
	var/canbequilty = 1

	New()
		..()
		if(canbequilty == 1)
			if( prob(10))
				name = "Quilty Farms Milk"
				desc = "For ages 1[pick("0","8")] and under."
				icon_state = "milk_quilty"

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
	canbequilty = 0

/obj/item/reagent_containers/food/drinks/milk/cluwnespider
	name = "Honkey Gibbersons - Cluwnespider Milk"
	desc = "A bottle of ... oh no! Do not look at it! Better never drink this colorful milk?!"
	icon_state = "milk"
	heal_amt = 1
	initial_volume = 50
	initial_reagents = list("painbow fluid" = 13, "milk" = 20)
	canbequilty = 0

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
