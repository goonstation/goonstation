// Ingredients

ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/ingredient)
/obj/item/reagent_containers/food/snacks/ingredient
	name = "ingredient"
	desc = "you shouldnt be able to see this"
	icon = 'icons/obj/foodNdrink/food_ingredient.dmi'
	bites_left = 1
	heal_amt = 0
	custom_food = 0

/obj/item/reagent_containers/food/snacks/ingredient/meat
	name = "raw meat"
	desc = "you shouldnt be able to see this either!!"
	icon_state = "meat"
	heal_amt = 0
	custom_food = 1
	var/blood = 7 //how much blood cleanables we are allowed to spawn

	heal(var/mob/living/M)
		..()
		if (prob(33))
			boutput(M, "<span class='alert'>You briefly think you probably shouldn't be eating raw meat.</span>")
			M.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1) // path, name, strain, bypass resist

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
		if (src.blood <= 0) return ..()

		if (istype(T))
			make_cleanable( /obj/decal/cleanable/blood,T)
			blood--
		..()

/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat
	name = "human meat"
	desc = "A slab of meat from a human."
	var/subjectname = "Human"
	var/subjectjob = "Human Being"

	New(var/turf/newloc,var/mob/living/meatsource)
		. = ..(newloc)
		if(!meatsource)
			return
		src.subjectname = meatsource.disfigured ? "Unknown" : meatsource.real_name
		src.subjectjob = "Stowaway"
		if (meatsource?.mind?.assigned_role)
			src.subjectjob = meatsource.mind.assigned_role
		else if (meatsource?.ghost?.mind?.assigned_role)
			src.subjectjob = meatsource.ghost.mind.assigned_role

		src.name = src.subjectname + " meat"


/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	name = "monkeymeat"
	desc = "A slab of meat from a monkey."

/obj/item/reagent_containers/food/snacks/ingredient/meat/fish
	name = "fish fillet"
	desc = "A slab of meat from a fish."
	icon_state = "fillet-pink"
	food_color = "#F4B4BC"
	real_name = "fish"
	salmon
		name = "salmon fillet"
		icon_state = "fillet-orange"
		food_color = "#F29866"
		real_name = "salmon"
	white
		name = "white fish fillet"
		icon_state = "fillet-white"
		food_color = "#FFECB7"
		real_name = "white fish"
	small
		name = "small fish fillet"
		icon_state = "fillet-small"
		food_color = "#FFECB7"
		real_name = "small fish"

/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	name = "synthmeat"
	desc = "Synthetic meat grown in hydroponics."
	icon_state = "meat-plant"
	initial_volume = 20
	food_color = "#228822"
	initial_reagents = list("synthflesh"=2)

/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat
	name = "mystery meat"
	desc = "What the fuck is this??"
	icon_state = "meat-mystery"
	var/cybermeat = 0

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		if (src.cybermeat == 1)
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
			if (istype(T))
				make_cleanable(/obj/decal/cleanable/oil,T)
				..()
			else
				return..()

/// Meat which is butchered from changeling critters (and gibbered changelings)
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/changeling
	 name = "mutagenic meat"
	 desc = "Are those eyes?"
	 icon_state = "meat-changeling"
	 initial_volume = 30
	 initial_reagents = list("neurotoxin" = 20, "bloodc" = 10)

/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	name = "bacon"
	desc = "A strip of salty cured pork. Many disgusting nerds have a bizarre fascination with this meat, going so far as to construct tiny houses out of it."
	icon_state = "bacon"
	initial_reagents = list("porktonium"=10)
	blood = 0

	New()
		..()
		src.pixel_x += rand(-4,4)
		src.pixel_y += rand(-4,4)

	heal(var/mob/M)
		..()
		M.nutrition += 20
		return

	raw
		name = "raw bacon"
		desc = "A strip of salty raw cured pork. It really should be cooked first."
		icon_state = "bacon-raw"
		blood = 2
		real_name = "bacon"

/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget
	name = "chicken nugget"
	desc = "A breaded wad of poultry, far too processed to have a more specific label than 'nugget.'"
	icon = 'icons/obj/foodNdrink/food_ingredient.dmi'
	icon_state = "nugget0"
	bites_left = 2
	initial_volume = 15
	doants = 0 // imagine 1000 nuggets on one tile all checking the other 999 nuggets if they aren't a table, yeah

	New()
		..()
		src.pixel_x += rand(-4,4)
		src.pixel_y += rand(-4,4)

	heal(var/mob/M)
		if (icon_state == "nugget0")
			icon_state = "nugget1"
		return ..()

/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/spicy
	name = "Windy's spicy chicken nugget"
	desc = "A breaded wad of poultry, far too processed to have a more specific label than 'nugget.' It's spicy. The ones from Windy's are the best."
	color = "#FF6600"
	food_color = "#FF6600"
	heal_amt = 10
	initial_reagents = list("capsaicin"=15)

/obj/item/reagent_containers/food/snacks/ingredient/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	food_color = "#FFFFFF"
	initial_volume = 20
	initial_reagents = list("egg"=5)
	doants = 0 // They're protected by a shell

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		src.visible_message("<span class='alert'>[src] splats onto the floor messily!</span>")
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
		make_cleanable(/obj/decal/cleanable/eggsplat,T)
		qdel (src)

/obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled
	name = "hard-boiled egg"
	desc = "You're a loose cannon, egg. I'm taking you off the menu."
	icon_state = "egg-hardboiled"
	food_color = "#FFFFFF"
	initial_volume = 20
	food_effects = list("food_brute", "food_cateyes")

	New()
		..()
		reagents.add_reagent("egg", 5)

	throw_impact(atom/A, datum/thrown_thing/thr)
		src.visible_message("<span class='alert'>[src] flops onto the floor!</span>")

	attackby(obj/item/W, mob/user)
		if (istool(W, TOOL_CUTTING | TOOL_SNIPPING))
			boutput(user, "<span class='notice'>You cut [src] in half</span>")
			new /obj/item/reagent_containers/food/snacks/deviledegg(get_turf(src))
			new /obj/item/reagent_containers/food/snacks/deviledegg(get_turf(src))
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			qdel(src)
		else ..()

/obj/item/reagent_containers/food/snacks/ingredient/yerba
	name = "yerba mate packet"
	desc = "A packet of yerba mate."
	icon_state = "yerba"
	food_color = "#32d440"

/obj/item/reagent_containers/food/snacks/ingredient/flour
	name = "flour"
	desc = "Some flour."
	icon_state = "flour"
	food_color = "#FFFFFF"

/obj/item/reagent_containers/food/snacks/ingredient/flour/semolina
	name = "semolina"
	desc = "Some semolina flour."
	icon_state = "semolina"
	food_color = "#FFFFEE"

/obj/item/reagent_containers/food/snacks/ingredient/rice_sprig
	name = "rice sprig"
	desc = "A sprig of rice. There's probably a decent amount in it, thankfully."
	icon = 'icons/obj/foodNdrink/food_produce.dmi'
	icon_state = "rice-sprig"
	food_color = "#FFFFAA"
	brew_result = "ricewine"

/obj/item/reagent_containers/food/snacks/ingredient/rice
	name = "rice"
	desc = "Some rice."
	icon_state = "rice"
	food_color = "#E3E3E3"

/obj/item/reagent_containers/food/snacks/ingredient/sugar
	name = "sugar"
	desc = "How sweet."
	icon_state = "sugar"
	food_color = "#FFFFFF"
	custom_food = 1
	initial_volume = 50
	initial_reagents = list("sugar"=25)
	brew_result = "rum"

/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	name = "peanut butter"
	desc = "A jar of GRIF peanut butter."
	icon_state = "peanutbutter"
	bites_left = 3
	heal_amt = 1
	food_color = "#996600"
	custom_food = 1
	food_effects = list("food_deep_burp")

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/candy) && W.reagents && W.reagents.has_reagent("chocolate"))
			if (istype(W, /obj/item/reagent_containers/food/snacks/candy/pbcup))
				return
			boutput(user, "You get chocolate in the peanut butter!  Or maybe the other way around?")

			var/obj/item/reagent_containers/food/snacks/candy/pbcup/A = new /obj/item/reagent_containers/food/snacks/candy/pbcup
			user.u_equip(W)
			user.put_in_hand_or_drop(A)

			qdel(W)
			if (src.bites_left-- < 1)
				qdel(src)

		else
			..()
		return

/obj/item/reagent_containers/food/snacks/ingredient/oatmeal
	name = "oatmeal"
	desc = "A breakfast staple."
	icon_state = "oatmeal"
	food_color = "#CC9966"
	custom_food = 1

/obj/item/reagent_containers/food/snacks/ingredient/salt
	name = "salt"
	desc = "A must have in any kitchen, just don't use too much."
	icon_state = "salt"
	food_color = "#a7927d"
	custom_food = 1

/obj/item/reagent_containers/food/snacks/ingredient/pepper
	name = "pepper"
	desc = "A must have in any kitchen, just don't use too much."
	icon_state = "pepper"
	food_color = "#a7927d"
	custom_food = 1

/obj/item/reagent_containers/food/snacks/ingredient/honey
	name = "honey"
	desc = "A sweet nectar derivative produced by bees."
	icon_state = "honeyblob"
	food_color = "#C0C013"
	custom_food = 1
	doants = 0
	initial_volume = 50
	initial_reagents = list("honey"=15)
	brew_result = "mead"
	New()
		..()
		src.setMaterial(getMaterial("honey"), appearance = 0, setname = 0)

/obj/item/reagent_containers/food/snacks/ingredient/royal_jelly
	name = "royal jelly"
	desc = "A blob of nutritive gel for larval bees."
	icon_state = "jellyblob"
	food_color = "#990066"
	custom_food = 1
	doants = 0
	initial_volume = 50
	initial_reagents = list("royal_jelly"=25)

/obj/item/reagent_containers/food/snacks/ingredient/peeled_banana
	name = "peeled banana"
	icon = 'icons/obj/foodNdrink/food_produce.dmi'
	icon_state = "banana-fruit"

/obj/item/reagent_containers/food/snacks/ingredient/cheese
	name = "cheese"
	desc = "Some kind of curdled milk product."
	icon_state = "cheese"
	bites_left = 2
	heal_amt = 1
	food_color = "#FFD700"
	custom_food = 1
	initial_volume = 5
	initial_reagents = "cheese"
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/ingredient/cheeseslice
	slice_amount = 4

	heal(var/mob/M)
		if (istype(M, /mob/living/critter/wraith/plaguerat))
			boutput(M, "<span class='notice'>The delicious taste of cheese sends your mouth to heaven!</span>")
			M.reagents.add_reagent("saline", 4)
			M.reagents.add_reagent("methamphetamine", 7)
		..()

/obj/item/reagent_containers/food/snacks/ingredient/gcheese
	name = "weird cheese"
	desc = "Some kind of... gooey, messy, gloopy thing. Similar to cheese, but only in the looser sense of the word."
	icon_state = "cheese-green"
	bites_left = 2
	heal_amt = 1
	food_color = "#669966"
	custom_food = 1
	initial_volume = 50
	initial_reagents = list("mercury"=5,"LSD"=5,"ethanol"=5,"gcheese"=5)
	food_effects = list("food_sweaty","food_bad_breath")
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/ingredient/gcheeseslice
	slice_amount = 4

	heal(var/mob/M)
		if (istype(M, /mob/living/critter/wraith/plaguerat))
			boutput(M, "<span class='notice'>This is by far the best thing you ever tasted! You feel buff!</span>")
			M.reagents.add_reagent("Omnizine", 7)
			M.reagents.add_reagent("methamphetamine", 12)
		..()

/obj/item/reagent_containers/food/snacks/ingredient/pancake_batter
	name = "pancake batter"
	desc = "Used for making pancakes."
	icon_state = "pancake"
	food_color = "#FFFFFF"

/obj/item/reagent_containers/food/snacks/ingredient/meatpaste
	name = "meatpaste"
	desc = "A meaty paste"
	icon_state = "meatpaste"
	custom_food = 1
	initial_volume = 50
	initial_reagents = list("meat_slurry"=15)

/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice
	name = "sticky rice"
	desc = "A big lump of sticky rice."
	icon_state = "rice-sticky"
	food_color = "#E3E3E3"
	custom_food = 0

	attack_self(mob/user as mob)
		boutput(user, "You mold the sticky rice into rice balls.")
		for (var/x = 0, x < 3, x++)
			new /obj/item/reagent_containers/food/snacks/rice_ball(user.loc)
		user.u_equip(src)
		qdel(src)

/obj/item/reagent_containers/food/snacks/ingredient/dough
	name = "dough"
	desc = "Used for making bready things."
	icon_state = "dough"
	food_color = "#FFFFFF"
	custom_food = 0

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/sugar))
			boutput(user, "<span class='notice'>You add [W] to [src] to make sweet dough!</span>")
			var/obj/item/reagent_containers/food/snacks/ingredient/dough_s/D = new /obj/item/reagent_containers/food/snacks/ingredient/dough_s(W.loc)
			user.u_equip(W)
			user.put_in_hand_or_drop(D)
			qdel(W)
			qdel(src)
		else if (istype(W, /obj/item/kitchen/rollingpin))
			boutput(user, "<span class='notice'>You flatten out the dough.</span>")
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, 'sound/voice/screams/male_scream.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message("<span class='alert'><B>The [src] screams!</B></span>")
			var/obj/item/reagent_containers/food/snacks/ingredient/pizza1/P = new /obj/item/reagent_containers/food/snacks/ingredient/pizza1(src.loc)
			user.u_equip(src)
			user.put_in_hand_or_drop(P)
			qdel(src)
		else if (istype(W, /obj/item/kitchen/utensil/fork))
			boutput(user, "<span class='notice'>You stab holes in the dough. How vicious.</span>")
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, 'sound/voice/screams/male_scream.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message("<span class='alert'><B>The [src] screams!</B></span>")
			var/obj/item/reagent_containers/food/snacks/ingredient/holey_dough/H = new /obj/item/reagent_containers/food/snacks/ingredient/holey_dough(W.loc)
			user.u_equip(src)
			user.put_in_hand_or_drop(H)
			qdel(src)
		else if (iscuttingtool(W) || issawingtool(W))
			boutput(user, "<span class='notice'>You cut the dough into two strips.</span>")
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, 'sound/voice/screams/male_scream.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message("<span class='alert'><B>The [src] screams!</B></span>")
			for(var/i = 1, i <= 2, i++)
				new /obj/item/reagent_containers/food/snacks/ingredient/dough_strip(get_turf(src))
			qdel(src)
		else if (istype(W, /obj/item/robodefibrillator))
			boutput(user, "<span class='notice'>You defibrilate the dough, yielding a perfect stack of flapjacks.</span>")
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, 'sound/voice/screams/male_scream.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message("<span class='alert'><B>The [src] screams!</B></span>")
			var/obj/item/reagent_containers/food/snacks/pancake/F = new /obj/item/reagent_containers/food/snacks/pancake(src.loc)
			user.u_equip(src)
			user.put_in_hand_or_drop(F)
			qdel(src)
		else if (istype(W, /obj/item/baton))
			var/obj/item/baton/baton = W
			if (baton.is_active) //baton is on
				if (user.a_intent != "harm")
					if (user.traitHolder.hasTrait("training_security"))
						playsound(src, 'sound/impact_sounds/Energy_Hit_3.ogg', 30, 1, -1) //bit quieter than a baton hit
						user.visible_message("<span class='notice'>[user] [pick("expertly", "deftly", "casually", "smoothly")] baton-fries the dough, yielding a tasty donut.</span>", group = "batonfry")
						var/obj/item/reagent_containers/food/snacks/donut/result = new /obj/item/reagent_containers/food/snacks/donut(src.loc)
						user.u_equip(src)
						user.put_in_hand_or_drop(result)
						qdel(src)
					else
						boutput(user, "<span class='alert'>You just aren't experienced enough to baton-fry.</span>")
				else
					user.visible_message("<b class='alert'>[user] tries to baton fry the dough, but fries [his_or_her(user)] hand instead!</b>")
					playsound(src, 'sound/impact_sounds/Energy_Hit_3.ogg', 30, 1, -1)
					user.do_disorient(baton.stamina_damage, weakened = baton.stun_normal_weakened * 10, disorient = 80) //cut from batoncode to bypass all the logging stuff
			else
				boutput(user, "<span class='notice'>You [user.a_intent == "harm" ? "beat" : "prod"] the dough. The dough doesn't react.</span>")
		else ..()

/obj/item/reagent_containers/food/snacks/ingredient/dough/semolina
	name = "semolina dough"
	desc = "Used for making pasta-y things."
	icon_state = "dough-semolina"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/kitchen/rollingpin))
			boutput(user, "<span class='notice'>You flatten out the dough into a sheet.</span>")
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, 'sound/voice/screams/male_scream.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message("<span class='alert'><B>The [src] screams!</B></span>")
			var/obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet/P = new /obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet(src.loc)
			user.u_equip(src)
			user.put_in_hand_or_drop(P)
			qdel(src)
		else ..()

/obj/item/reagent_containers/food/snacks/ingredient/dough_strip
	name = "dough strip"
	desc = "A strand of cut up dough. It looks like you can re-attach two of them back together."
	icon_state = "dough-strip"
	food_color = "#FFFFF"
	custom_food = 0

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/dough_strip))
			boutput(user, "<span class='notice'>You attach the [src]s back together to make a piece of dough.</span>")
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			var/obj/item/reagent_containers/food/snacks/ingredient/dough/D = new /obj/item/reagent_containers/food/snacks/ingredient/dough(W.loc)
			user.u_equip(W)
			user.put_in_hand_or_drop(D)
			qdel(W)
			qdel(src)
		else if (istype(W, /obj/item/kitchen/rollingpin))
			boutput(user, "<span class='notice'>You flatten the [src] into a long sheet.</span>")
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			var/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/noodles = new /obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/sheet(W.loc)
			user.put_in_hand_or_drop(noodles)
			qdel(src)
		else ..()

	attack_self(var/mob/user as mob)
		boutput(user, "<span class='notice'>You twist the [src] into a circle.</span>")
		if (prob(25))
			JOB_XP(user, "Chef", 1)
		if(prob(1))
			playsound(src.loc, 'sound/voice/screams/male_scream.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
			src.visible_message("<span class='alert'><B>The [src] screams!</B></span>")
		new /obj/item/reagent_containers/food/snacks/ingredient/dough_circle(get_turf(src))
		qdel (src)

/obj/item/reagent_containers/food/snacks/ingredient/dough_circle
	name = "dough circle"
	desc = "Used for making torus-shaped things." //I used to eat out with friends, but bagels just torus apart.
	icon_state = "dough-circle"
	food_color = "#FFFFF"
	custom_food = 0

/obj/item/reagent_containers/food/snacks/ingredient/holey_dough
	name = "holey dough" //+1 to chaplain magic skills
	desc = "Some dough with a bunch of holes poked in it. How exotic."
	icon_state = "dough-holey"
	food_color = "#FFFFF"
	custom_food = 0

/obj/item/reagent_containers/food/snacks/ingredient/dough_s
	name = "sweet dough"
	desc = "Used for making cakey things."
	icon_state = "dough-sweet"

	attackby(obj/item/W, mob/user)
		if (iscuttingtool(W) || issawingtool(W))
			boutput(user, "<span class='notice'>You cut [src] into smaller pieces...</span>")
			for(var/i = 1, i <= 4, i++)
				new /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie(get_turf(src))
			qdel(src)
		if (prob(25))
			JOB_XP(user, "Chef", 1)
		else ..()

/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	name = "cookie dough"
	desc = "Probably shouldn't be eaten raw, not that THAT'S ever stopped anyone."
	icon_state = "dough-cookie"
	custom_food = 1

	New()
		..()
		src.pixel_x = rand(-6, 6)
		src.pixel_y = rand(-6, 6)

	heal(var/mob/M)
		if(prob(15))
			M.reagents.add_reagent("salmonella",15)
			boutput(M, "<span class='alert'>That tasted a little bit...off.</span>")
		..()

/obj/item/reagent_containers/food/snacks/ingredient/tortilla
	name = "uncooked tortilla"
	desc = "An uncooked flour tortilla."
	icon_state = "tortillabase"
	food_color = "#FFFFFF"
	New()
		..()
		src.pixel_x = rand(-8, 8)
		src.pixel_y = rand(-8, 8)

/obj/item/reagent_containers/food/snacks/ingredient/pizza1
	name = "unfinished pizza base"
	desc = "You need to add tomatoes..."
	icon_state = "pizzabase"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/condiment/ketchup) || istype(W, /obj/item/reagent_containers/food/snacks/plant/tomato))
			boutput(user, "<span class='notice'>You add [W] to [src].</span>")
			var/obj/item/reagent_containers/food/snacks/ingredient/pizza2/D=new /obj/item/reagent_containers/food/snacks/ingredient/pizza2(W.loc)
			user.u_equip(W)
			user.put_in_hand_or_drop(D)
			qdel(W)
			qdel(src)
		if (prob(25))
			JOB_XP(user, "Chef", 1)
		else if (iscuttingtool(W) || issawingtool(W))
			boutput(user, "<span class='notice'>You cut [src] into smaller pieces...</span>")
			for(var/i = 1, i <= 3, i++)
				new /obj/item/reagent_containers/food/snacks/ingredient/tortilla(get_turf(src))
			qdel(src)
		if (prob(25))
			JOB_XP(user, "Chef", 1)
		else ..()

	attack_self(var/mob/user as mob)
		boutput(user, "<span class='notice'>You knead the [src] back into a blob.</span>")
		new /obj/item/reagent_containers/food/snacks/ingredient/dough(get_turf(src))
		qdel (src)

	attack(mob/M, mob/user, def_zone)
		if (user == M)
			boutput(user, "<span class='alert'>You need to add tomatoes, you greedy beast!</span>")
			user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
			return
		else
			user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
			return

/obj/item/reagent_containers/food/snacks/ingredient/pizza2
	name = "half-finished pizza base"
	desc = "You need to add cheese..."
	icon_state = "pizzabase2"
	custom_food = 0

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/cheese))
			boutput(user, "<span class='notice'>You add [W] to [src].</span>")
			var/obj/item/reagent_containers/food/snacks/ingredient/pizza3/D = new /obj/item/reagent_containers/food/snacks/ingredient/pizza3(W.loc)
			user.u_equip(W)
			user.put_in_hand_or_drop(D)
			qdel(W)
			qdel(src)
		else ..()

	attack(mob/M, mob/user, def_zone)
		if (user == M)
			boutput(user, "<span class='alert'>You need to add cheese, you greedy beast!</span>")
			user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
			return
		else
			user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
			return

/obj/item/reagent_containers/food/snacks/ingredient/pizza3
	name = "uncooked pizza"
	desc = "A plain cheese and tomato pizza. You need to bake it..."
	icon_state = "pizzabase3"
	custom_food = 0
	var/num = null
	var/topping = 0
	var/topping_color = null
	var/list/toppings = list()
	var/list/topping_types = list()
	var/list/topping_colors = list()
	var/toppingstext = null

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/))
			var/obj/item/reagent_containers/food/snacks/F = W
			if(!F.custom_food)
				return
			boutput(user, "<span class='notice'>You add [W] to [src].</span>")
			topping = 1
			food_effects += F.food_effects
			topping_types += W.type
			if (F.real_name)
				toppings += F.real_name
			else
				toppings += W.name
			toppingstext = copytext(html_encode(english_list(toppings)), 1, 512)
			name = "uncooked [toppingstext] pizza"
			desc = "A pizza with [toppingstext] toppings. You need to bake it..."
			if(istype(W,/obj/item/reagent_containers/food/snacks/ingredient/))
				heal_amt += 4
			else
				heal_amt += round((F.heal_amt * F.bites_left)/bites_left) + 1
			topping_color = F.get_food_color()
			if(num < 3)
				num ++
				add_topping(src.num)
			W.reagents.trans_to(src, W.reagents.total_volume)
			user.u_equip(W)
			qdel (W)
		else
			return

	proc/add_topping(var/num)
		var/icon/I
		I = new /icon('icons/obj/foodNdrink/food_meals.dmi',"pizza_topping_[num]")
		I.Blend(topping_color, ICON_ADD)
		src.topping_colors += topping_color
		src.overlays += I

	attack(mob/M, mob/user, def_zone)
		if (user == M)
			boutput(user, "<span class='alert'>You need to bake it, you greedy beast!</span>")
			user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
			return
		else
			user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
			return

/obj/item/reagent_containers/food/snacks/ingredient/pizzam
	name = "uncooked mushroom pizza"
	desc = "A cheese and mushroom pizza. You need to bake it..."
	icon_state = "pizzabasem"

	attack(mob/M, mob/user, def_zone)
		if (user == M)
			boutput(user, "<span class='alert'>You need to bake it, you greedy beast!</span>")
			user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
			return
		else
			user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
			return

/obj/item/reagent_containers/food/snacks/ingredient/pizzab
	name = "uncooked meatball pizza"
	desc = "A cheese and meatball pizza. You need to bake it..."
	icon_state = "pizzabaseb"

	attack(mob/M, mob/user, def_zone)
		if (user == M)
			boutput(user, "<span class='alert'>You need to bake it, you greedy beast!</span>")
			user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
			return
		else
			user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
			return

/obj/item/reagent_containers/food/snacks/ingredient/pizzap
	name = "uncooked pepperoni pizza"
	desc = "A cheese and pepperoni pizza. You need to bake it..."
	icon_state = "pizzabasep"

	attack(mob/M, mob/user, def_zone)
		if (user == M)
			boutput(user, "<span class='alert'>You need to bake it, you greedy beast!</span>")
			user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
			return
		else
			user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
			return

/obj/item/reagent_containers/food/snacks/ingredient/pasta
	// generic uncooked pasta parent
	name = "pasta sheet"
	desc = "Uncooked pasta."
	heal_amt = 0

	heal(var/mob/M)
		boutput(M, "<span class='alert'>... You must be really hungry.</span>")
		..()

/obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet
	name = "pasta sheet"
	desc = "An uncooked sheet of pasta."
	icon_state = "pasta-sheet"

ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles)
/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles
	name = "wheat noodles"
	heal_amt = 0

	heal(var/mob/M)
		boutput(M, "<span class='alert'>Ew, disgusting...</span>")
		..()

	sheet
		name = "wheat noodle sheet"
		desc = "An uncooked sheet of wheat dough, used in noodle-making."
		icon_state = "noodle-sheet"

		attackby(obj/item/W, mob/user)
			if (iscuttingtool(W))
				var/turf/T = get_turf(src)
				user.visible_message("[user] cuts [src] into thick noodles.", "You cut [src] into thick noodles.")
				new /obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/udon(T)
				qdel (src)

	ramen
		name = "ramen noodles"
		desc = "Fresh Japanese ramen noodles. Floppy."
		icon_state = "ramen"

	udon
		name = "udon noodles"
		desc = "Thick wheat noodles."
		icon_state = "udon"

/obj/item/reagent_containers/food/snacks/ingredient/chips
	name = "uncooked chips"
	desc = "Cook them up into some nice fries."
	icon_state = "pchips"
	bites_left = 6
	heal_amt = 0
	food_color = "#FFFF99"

	heal(var/mob/M)
		..()
		boutput(M, "<span class='alert'>Raw potato tastes pretty nasty...</span>") // does it?


/obj/item/reagent_containers/food/snacks/proc/random_spaghetti_name()
	.= pick(list("spagtetti","splaghetti","spaghetty","spagtti","spagheti","spaghettie","spahetti","spetty","pisketti","spagoody","spaget","spagherti","spaceghetti"))

/obj/item/reagent_containers/food/snacks/ingredient/spaghetti
	name = "spaghetti noodles"
	desc = "Original italian noodles."
	icon_state = "spaghetti"
	heal_amt = 0

	New()
		..()
		name = "[random_spaghetti_name()] noodles"

	get_desc()
		..()
		.= "Original italian [name]."


	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/reagent_containers/food/snacks/condiment/ketchup))
			boutput(user, "<span class='notice'>You create [random_spaghetti_name()] with tomato sauce...</span>")
			var/obj/item/reagent_containers/food/snacks/spaghetti/sauce/D
			if (user.mob_flags & IS_BONEY)
				D = new/obj/item/reagent_containers/food/snacks/spaghetti/sauce/skeletal(W.loc)
				boutput(user, "<span class='alert'>... whoa, that felt good. Like really good.</span>")
				user.reagents.add_reagent("boneyjuice",20)
			else
				D = new/obj/item/reagent_containers/food/snacks/spaghetti/sauce(W.loc)
			user.u_equip(W)
			user.put_in_hand_or_drop(D)
			qdel(W)
			qdel(src)

	heal(var/mob/M)
		boutput(M, "<span class='alert'>The noodles taste terrible uncooked...</span>")
		..()

/obj/item/reagent_containers/food/snacks/ingredient/butter //its actually margarine
	name = "butter"
	desc = "Everything's better with it."
	icon_state = "butter"
	heal_amt = 0
	food_color = "#FFFF00"
	initial_volume = 25
	initial_reagents = "butter"

	heal(var/mob/M)
		boutput(M, "<span class='alert'>You feel ashamed of yourself...</span>")
		..()

/obj/item/reagent_containers/food/snacks/ingredient/pepperoni
	name = "pepperoni"
	desc = "A slice of what you believe could possibly be meat."
	icon_state = "pepperoni"
	food_color = "#C90E0E"
	custom_food = 1
	doants = 1
	initial_volume = 10
	initial_reagents = "pepperoni"
	sliceable = FALSE

obj/item/reagent_containers/food/snacks/ingredient/pepperoni_log
	name = "pepperoni log"
	desc = "It's like a forest of pepperoni was felled just for you."
	icon_state = "pepperoni-log"
	custom_food = 1
	food_color = "#C90E0E"
	doants = 0
	initial_volume = 40
	initial_reagents = "pepperoni"
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/ingredient/pepperoni
	slice_amount = 4


/obj/item/reagent_containers/food/snacks/ingredient/fishpaste
	name = "fish paste"
	desc = "An unappetizing clump of mashed fish bits."
	icon_state = "fishpaste"
/obj/item/reagent_containers/food/snacks/ingredient/kamaboko
	name = "kamaboko"
	desc = "A slice of fish cake with a cute little spiral in the center."
	icon_state = "kamaboko"
	custom_food = 1
	food_color = "#ffffff"

/obj/item/reagent_containers/food/snacks/ingredient/kamaboko_log
	name = "kamaboko log"
	desc = "What a strange-looking fish."
	icon_state = "kamaboko-log"
	custom_food = 1
	food_color = "#ffffff"
	doants = 0
	bites_left = 3

	attackby(obj/item/W, mob/user)
		if (iscuttingtool(W))
			var/turf/T = get_turf(src)
			user.visible_message("[user] cuts [src] into slices.", "You cut [src] into slices.")
			for (var/i in 1 to 4)
				new /obj/item/reagent_containers/food/snacks/ingredient/kamaboko(T)
			qdel (src)

/obj/item/reagent_containers/food/snacks/ingredient/seaweed
	name = "seaweed sheets"
	desc = "Dried and salted sheets of seaweed."
	icon_state = "seaweed"
	heal_amt = 1
	food_color = "#4C453E"

/obj/item/reagent_containers/food/snacks/ingredient/currypowder
	name = "curry powder"
	desc = "A bag of curry powder. Smells heavenly."
	icon_state = "currypowder"
	heal_amt = 0
	food_color = "#e0a80c"
	initial_volume = 10
	initial_reagents = "currypowder"

/obj/item/reagent_containers/food/snacks/ingredient/tomatoslice //yes it's not /snacks/ingredients, shut up
	name = "tomato slice"
	desc = "A slice of some kind of tomato, presumably."
	icon_state = "tomatoslice"
	heal_amt = 1
	food_color = "#f2500c"
	custom_food = 1
	initial_volume = 15
	initial_reagents = list("juice_tomato"=4)

/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice
	name = "slice of cheese"
	desc = "A slice of hopefully fresh cheese."
	icon_state = "cheeseslice"
	heal_amt = 1
	food_color = "#FFD700"
	custom_food = 1
	initial_volume = 15
	initial_reagents = list("cheese"=1)

	heal(var/mob/M)
		if (istype(M, /mob/living/critter/wraith/plaguerat))
			boutput(M, "<span class='notice'>This doesnt satisfy your craving for cheese, but its a start.</span>")
			M.reagents.add_reagent("saline", 4)
			M.reagents.add_reagent("methamphetamine", 2.5)
		..()

/obj/item/reagent_containers/food/snacks/ingredient/gcheeseslice
	name = "slice of weird cheese"
	desc = "A slice of what you assume was, at one point, cheese."
	icon_state = "gcheeseslice"
	heal_amt = 1
	food_color = "#669966"
	custom_food = 1
	initial_volume = 15
	initial_reagents = list("mercury"=1,"LSD"=1,"ethanol"=1,"gcheese"=1)
	food_effects = list("food_sweaty","food_bad_breath")

	heal(var/mob/M)
		if (istype(M, /mob/living/critter/wraith/plaguerat))
			boutput(M, "<span class='notice'>This is incredible, but there isnt enough! MORE!</span>")
			M.reagents.add_reagent("omnizine", 3)
			M.reagents.add_reagent("methamphetamine", 3)
		..()
