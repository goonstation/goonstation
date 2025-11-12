// Ingredients

ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/ingredient)
/obj/item/reagent_containers/food/snacks/ingredient
	name = "ingredient"
	desc = "you shouldn't be able to see this"
	icon = 'icons/obj/foodNdrink/food_ingredient.dmi'
	bites_left = 1
	heal_amt = 0
	custom_food = 0

/obj/item/reagent_containers/food/snacks/ingredient/meat
	name = "raw meat"
	desc = "you shouldn't be able to see this either!!"
	icon_state = "meat"
	heal_amt = 0
	custom_food = 1
	var/blood = 7 //how much blood cleanables we are allowed to spawn

	heal(var/mob/living/M)
		..()
		if (!(istype(M, /mob/living/critter/plant/maneater)) && prob(33))
			boutput(M, SPAN_ALERT("You briefly think you probably shouldn't be eating raw meat."))
			M.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1) // path, name, strain, bypass resist

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
		if (src.blood <= 0) return ..()

		if (istype(T))
			make_cleanable( /obj/decal/cleanable/blood,T)
			blood--
		..()

	on_temperature_cook()
		src.visible_message("[src] begins to brown in the heat!")
		playsound(src.loc, 'sound/impact_sounds/burn_sizzle.ogg', 50, TRUE, pitch = 0.8)


/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat
	name = "human meat"
	desc = "A slab of meat from a human."
	heats_into = /obj/item/reagent_containers/food/snacks/steak/human
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
	heats_into = /obj/item/reagent_containers/food/snacks/steak/monkey

/obj/item/reagent_containers/food/snacks/ingredient/meat/sheep
	name = "sheep meat"
	desc = "A slab of meat from a sheep."
	heats_into = /obj/item/reagent_containers/food/snacks/steak/sheep

/obj/item/reagent_containers/food/snacks/ingredient/meat/lesserSlug
	name = "lesser slug"
	desc = "Chopped up slug that's grown its own head, how talented. It yearns for the microwave."
	icon_state = "lesserSlug"
	fill_amt = 2
	initial_volume = 25
	initial_reagents = "slime"
	food_color = "#A4BC62"
	var/eyes_present = TRUE

	heal(var/mob/M)
		boutput(M, SPAN_ALERT("You can feel it wriggling..."))
		..()

	attackby(obj/item/W, mob/user)
		if (!src.eyes_present)
			user.visible_message(SPAN_NOTICE("You can't possibly cut more than one at a time, company policy."))
			return
		if (issnippingtool(W))
			user.visible_message(SPAN_NOTICE("You snip off an eyestalk. The slug seems unaware."))
			playsound(src.loc, 'sound/items/Scissor.ogg', 50, TRUE)
			var/obj/item/eyes = new /obj/item/cocktail_stuff/eyestalk
			eyes.set_loc(src.loc)
			src.icon_state = "lesserSlug-eyeless"
			src.eyes_present = FALSE
			SPAWN(20 SECONDS)
				src.icon_state = "lesserSlug"
				src.eyes_present = TRUE

/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet
	name = "fish fillet"
	desc = "A slab of meat from a fish."
	icon_state = "fillet-pink"
	food_color = "#F4B4BC"
	real_name = "fish"
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet_slice
	slice_amount = 3
	slice_suffix = "slice"

	salmon
		name = "salmon fillet"
		icon_state = "fillet-orange"
		food_color = "#F29866"
		real_name = "salmon"
		slice_product = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet_slice/salmon
	white
		name = "white fish fillet"
		icon_state = "fillet-white"
		food_color = "#FFECB7"
		real_name = "white fish"
		slice_product = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet_slice/white
	small
		name = "small fish fillet"
		icon_state = "fillet-small"
		food_color = "#FFECB7"
		real_name = "small fish"
		slice_product = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet_slice/small
	pufferfish
		name = "pufferfish fillet"
		icon_state = "fillet-pufferfish"
		food_color = "#eeedec"
		real_name = "pufferfish"
		slice_amount = 2 // Divides the 40u of poison into still lethal slices
		slice_product = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet_slice/pufferfish

/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet_slice
	name = "slice of fish fillet"
	desc = "A carefully cut slice of fish fillet."
	icon_state = "filletslice-pink"
	food_color = "#F4B4BC"
	real_name = "fish"
	salmon
		name = "slice of salmon fillet"
		icon_state = "filletslice-orange"
		food_color = "#F29866"
		real_name = "salmon"
	white
		name = "slice of white fillet"
		icon_state = "filletslice-white"
		food_color = "#FFECB7"
		real_name = "white fish"
	small
		name = "slice of small fish fillet"
		icon_state = "filletslice-small"
		food_color = "#FFECB7"
		real_name = "small fish"
	pufferfish
		name = "slice of pufferfish fillet"
		icon_state = "filletslice-pufferfish"
		food_color = "#e0dbce"
		real_name = "pufferfish"


/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/pufferfish_liver
	name = "pufferfish liver"
	desc = "The most toxic part of pufferfish."
	icon_state = "pufferfish-liver"
	food_color = "#693576"

/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/shrimp
	name = "raw shrimp meat"
	desc = "Meat of a freshly caught shrimp."
	icon_state = "shrimp_meat"
	food_color = "#f0ac98"

/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	name = "synthmeat"
	desc = "Synthetic meat grown in hydroponics."
	icon_state = "meat-plant"
	initial_volume = 20
	food_color = "#228822"
	initial_reagents = list("synthflesh"=2)
	heats_into = /obj/item/reagent_containers/food/snacks/steak/synth

/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat
	name = "mystery meat"
	desc = "What the fuck is this??"
	icon_state = "meat-mystery"
	var/cybermeat = 0
	var/splatted = FALSE

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		if (src.cybermeat)
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
			if (istype(T) && !splatted)
				splatted = TRUE
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
	heats_into = /obj/item/reagent_containers/food/snacks/steak/ling

/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/grody
	name = "meaty bit"
	desc = "grody."
	icon = 'icons/obj/decals/gibs/human.dmi'
	icon_state = "gibmid2"

	New()
		..()
		src.name = pick("meaty bit", "gross organs", "grody thing")
		src.icon_state = pick("gibmid1", "gibmid2", "gibarm", "gibtorso", "gibhead")

/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	name = "bacon"
	desc = "A strip of salty cured pork. Many disgusting nerds have a bizarre fascination with this meat, going so far as to construct tiny houses out of it."
	icon_state = "bacon"
	initial_reagents = list("porktonium"=10)
	blood = 0
	heal_amt = 1
	fill_amt = 0.5 //it's only one strip

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
		heal_amt = 0
		real_name = "bacon"
		heats_into = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon

		on_temperature_cook()
			src.visible_message("The bacon sizzles enticingly!")
			playsound(src.loc, 'sound/impact_sounds/burn_sizzle.ogg', 50, TRUE, pitch = 0.8)

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

/obj/item/reagent_containers/food/snacks/ingredient/turkey
	name = "raw turkey"
	desc = "A raw turkey. It's ready to be roasted!"
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "turkeyraw"

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (user == target)
			boutput(user, SPAN_ALERT("You need to cook it first, you greedy beast!"))
			user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
			return
		else
			user.visible_message(SPAN_ALERT("<b>[user]</b> futilely attempts to shove [src] into [target]'s mouth!"))
			return

	attack_self(mob/user as mob)
		attack(user, user)

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
	brew_result = list("ricewine"=20)

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
	brew_result = list("rum"=20)

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
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, A, user)
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
	initial_volume = 100
	initial_reagents = list("salt"=10)

/obj/item/reagent_containers/food/snacks/ingredient/pepper
	name = "pepper"
	desc = "A must have in any kitchen, just don't use too much."
	icon_state = "pepper"
	food_color = "#a7927d"
	custom_food = 1
	initial_volume = 100
	initial_reagents = list("pepper"=10)

TYPEINFO(/obj/item/reagent_containers/food/snacks/ingredient/honey)
	mat_appearances_to_ignore = list("honey")
/obj/item/reagent_containers/food/snacks/ingredient/honey
	name = "honey"
	desc = "A sweet nectar derivative produced by bees."
	icon_state = "honeyblob"
	food_color = "#C0C013"
	custom_food = 1
	doants = 0
	initial_volume = 50
	initial_reagents = list("honey"=15)
	brew_result = list("mead"=20)
	mat_changename = "honey"
	default_material = "honey"

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
	item_state = "banana-fruit"

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
			boutput(M, SPAN_NOTICE("The delicious taste of cheese sends your mouth to heaven!"))
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
			boutput(M, SPAN_NOTICE("This is by far the best thing you ever tasted! You feel buff!"))
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

	clamp_act(mob/clamper, obj/item/clamp)
		new /obj/item/reagent_containers/food/snacks/ingredient/pizza_base(src.loc)
		qdel(src)
		return TRUE

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/sugar))
			boutput(user, SPAN_NOTICE("You add [W] to [src] to make sweet dough!"))
			var/obj/item/reagent_containers/food/snacks/ingredient/dough_s/D = new /obj/item/reagent_containers/food/snacks/ingredient/dough_s(W.loc)
			user.u_equip(W)
			user.put_in_hand_or_drop(D)
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, D, user)
			qdel(W)
			qdel(src)
		else if (istype(W, /obj/item/kitchen/rollingpin))
			boutput(user, SPAN_NOTICE("You flatten out the dough."))
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, 'sound/voice/screams/male_scream.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message(SPAN_ALERT("<B>[src] screams!</B>"))
			var/obj/item/reagent_containers/food/snacks/ingredient/pizza_base/P = new /obj/item/reagent_containers/food/snacks/ingredient/pizza_base(src.loc)
			user.u_equip(src)
			user.put_in_hand_or_drop(P)
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, P, user)
			qdel(src)
		else if (istype(W, /obj/item/kitchen/utensil/fork))
			boutput(user, SPAN_NOTICE("You stab holes in the dough. How vicious."))
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, 'sound/voice/screams/male_scream.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message(SPAN_ALERT("<B>[src] screams!</B>"))
			var/obj/item/reagent_containers/food/snacks/ingredient/holey_dough/H = new /obj/item/reagent_containers/food/snacks/ingredient/holey_dough(W.loc)
			user.u_equip(src)
			user.put_in_hand_or_drop(H)
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, H, user)
			qdel(src)
		else if (iscuttingtool(W) || issawingtool(W))
			boutput(user, SPAN_NOTICE("You cut the dough into two strips."))
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, 'sound/voice/screams/male_scream.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message(SPAN_ALERT("<B>[src] screams!</B>"))
			var/list/strips = list()
			for(var/i = 1, i <= 2, i++)
				strips.Add(new /obj/item/reagent_containers/food/snacks/ingredient/dough_strip(get_turf(src)))
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, strips, user)
			qdel(src)
		else if (istype(W, /obj/item/robodefibrillator))
			boutput(user, SPAN_NOTICE("You defibrillate the dough, yielding a perfect stack of flapjacks."))
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, 'sound/voice/screams/male_scream.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message(SPAN_ALERT("<B>[src] screams!</B>"))
			var/obj/item/reagent_containers/food/snacks/pancake/F = new /obj/item/reagent_containers/food/snacks/pancake(src.loc)
			user.u_equip(src)
			user.put_in_hand_or_drop(F)
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, F, user)
			qdel(src)
		else if (istype(W, /obj/item/baton))
			var/obj/item/baton/baton = W
			if (baton.is_active) //baton is on
				if (user.a_intent != "harm")
					if (user.traitHolder.hasTrait("training_security"))
						playsound(src, 'sound/impact_sounds/Energy_Hit_3.ogg', 30, TRUE, -1) //bit quieter than a baton hit
						user.visible_message(SPAN_NOTICE("[user] [pick("expertly", "deftly", "casually", "smoothly")] baton-fries the dough, yielding a tasty donut."), group = "batonfry")
						var/obj/item/reagent_containers/food/snacks/donut/result = new /obj/item/reagent_containers/food/snacks/donut(src.loc)
						user.u_equip(src)
						user.put_in_hand_or_drop(result)
						SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, result, user)
						qdel(src)
					else
						boutput(user, SPAN_ALERT("You just aren't experienced enough to baton-fry."))
				else
					user.visible_message("<b class='alert'>[user] tries to baton fry the dough, but fries [his_or_her(user)] hand instead!</b>")
					playsound(src, 'sound/impact_sounds/Energy_Hit_3.ogg', 30, TRUE, -1)
					user.do_disorient(baton.stamina_damage, knockdown = baton.stun_normal_knockdown * 10, disorient = 80) //cut from batoncode to bypass all the logging stuff
			else
				boutput(user, SPAN_NOTICE("You [user.a_intent == "harm" ? "beat" : "prod"] the dough. The dough doesn't react."))
		else ..()

/obj/item/reagent_containers/food/snacks/ingredient/dough/semolina
	name = "semolina dough"
	desc = "Used for making pasta-y things."
	icon_state = "dough-semolina"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/kitchen/rollingpin))
			boutput(user, SPAN_NOTICE("You flatten out the dough into a sheet."))
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			if(prob(1))
				playsound(src.loc, 'sound/voice/screams/male_scream.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message(SPAN_ALERT("<B>[src] screams!</B>"))
			var/obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet/P = new /obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet(src.loc)
			user.u_equip(src)
			user.put_in_hand_or_drop(P)
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, P, user)
			qdel(src)
		else ..()

/obj/item/reagent_containers/food/snacks/ingredient/dough_strip
	name = "dough strip"
	desc = "A strand of cut up dough. It looks like you can re-attach two of them back together."
	icon_state = "dough-strip"
	food_color = "#FFFFF"
	custom_food = 0
	fill_amt = 0.5

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/dough_strip))
			boutput(user, SPAN_NOTICE("You attach the [src]s back together to make a piece of dough."))
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			var/obj/item/reagent_containers/food/snacks/ingredient/dough/D = new /obj/item/reagent_containers/food/snacks/ingredient/dough(W.loc)
			user.u_equip(W)
			user.put_in_hand_or_drop(D)
			qdel(W)
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, D, user)
			qdel(src)
		else if (istype(W, /obj/item/kitchen/rollingpin))
			boutput(user, SPAN_NOTICE("You flatten the [src] into a long sheet."))
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			var/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/noodles = new /obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/sheet(W.loc)
			user.put_in_hand_or_drop(noodles)
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, noodles, user)
			qdel(src)
		else ..()

	attack_self(var/mob/user as mob)
		boutput(user, SPAN_NOTICE("You twist the [src] into a circle."))
		if (prob(25))
			JOB_XP(user, "Chef", 1)
		if(prob(1))
			playsound(src.loc, 'sound/voice/screams/male_scream.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
			src.visible_message(SPAN_ALERT("<B>[src] screams!</B>"))
		var/dough_circle = new /obj/item/reagent_containers/food/snacks/ingredient/dough_circle(get_turf(src))
		SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, dough_circle, user)
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
			boutput(user, SPAN_NOTICE("You cut [src] into smaller pieces..."))
			var/list/cookies = list()
			for(var/i = 1, i <= 4, i++)
				cookies.Add(new /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie(get_turf(src)))
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, cookies, user)
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
			boutput(M, SPAN_ALERT("That tasted a little bit...off."))
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

ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles)
/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles
	name = "wheat noodles"
	heal_amt = 0

	heal(var/mob/M)
		boutput(M, SPAN_ALERT("Ew, disgusting..."))
		..()

	sheet
		name = "wheat noodle sheet"
		desc = "An uncooked sheet of wheat dough, used in noodle-making."
		icon_state = "noodle-sheet"

		attackby(obj/item/W, mob/user)
			if (iscuttingtool(W))
				var/turf/T = get_turf(src)
				user.visible_message("[user] cuts [src] into thick noodles.", "You cut [src] into thick noodles.")
				var/udon = new /obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/udon(T)
				SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, udon, user)
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
		boutput(M, SPAN_ALERT("Raw potato tastes pretty nasty...")) // does it?

// this is cursed on multiple levels, both the placement and the function
/obj/item/reagent_containers/food/snacks/proc/random_spaghetti_name()
	.= pick(list("spagtetti","splaghetti","spaghetty","spagtti","spagheti","spaghettie","spahetti","spetty","pisketti","spagoody","spaget","spagherti","spaceghetti"))

ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/ingredient/pasta)
/obj/item/reagent_containers/food/snacks/ingredient/pasta
	// generic uncooked pasta parent
	name = "pasta sheet"
	desc = "Uncooked pasta."
	heal_amt = 0

	heal(var/mob/M)
		boutput(M, SPAN_ALERT("... You must be really hungry."))
		..()

	spaghetti
		name = "spaghetti noodles"
		desc = "Original italian noodles."
		icon_state = "spaghetti"
		heal_amt = 0

		New()
			..()
			name = "[random_spaghetti_name()] noodles"

		get_desc()
			..()
			.= "Original italian [src.name]."

		attackby(obj/item/W, mob/user)
			if(istype(W,/obj/item/reagent_containers/food/snacks/condiment/ketchup))
				boutput(user, SPAN_NOTICE("You create [random_spaghetti_name()] with tomato sauce..."))
				var/obj/item/reagent_containers/food/snacks/spaghetti/sauce/D
				if (user.mob_flags & IS_BONEY)
					D = new/obj/item/reagent_containers/food/snacks/spaghetti/sauce/skeletal(W.loc)
					boutput(user, SPAN_ALERT("... whoa, that felt good. Like really good."))
					user.reagents.add_reagent("boneyjuice",20)
				else
					D = new/obj/item/reagent_containers/food/snacks/spaghetti/sauce(W.loc)
				user.u_equip(W)
				user.put_in_hand_or_drop(D)
				SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, D, user)
				qdel(W)
				qdel(src)

		heal(var/mob/M)
			boutput(M, SPAN_ALERT("The noodles taste terrible uncooked..."))
			..()

	sheet
		name = "pasta sheet"
		desc = "An uncooked sheet of pasta."
		icon_state = "pasta-sheet"

/obj/item/reagent_containers/food/snacks/ingredient/butter //its actually margarine
	name = "butter"
	desc = "Everything's better with it."
	icon_state = "butter"
	heal_amt = 0
	fill_amt = 2
	food_color = "#FFFF00"
	initial_volume = 25
	initial_reagents = "butter"

	heal(var/mob/M)
		boutput(M, SPAN_ALERT("You feel ashamed of yourself..."))
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
	fill_amt = 2
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
			var/list/slices = list()
			for (var/i in 1 to 4)
				slices.Add(new /obj/item/reagent_containers/food/snacks/ingredient/kamaboko(T))
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, slices, user)
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
	fill_amt = 0.3

/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice
	name = "slice of cheese"
	desc = "A slice of hopefully fresh cheese."
	icon_state = "cheeseslice"
	heal_amt = 1
	food_color = "#FFD700"
	custom_food = 1
	initial_volume = 15
	initial_reagents = list("cheese"=1)
	fill_amt = 0.3

	heal(var/mob/M)
		if (istype(M, /mob/living/critter/wraith/plaguerat))
			boutput(M, SPAN_NOTICE("This doesn't satisfy your craving for cheese, but its a start."))
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
			boutput(M, SPAN_NOTICE("This is incredible, but there isn't enough! MORE!"))
			M.reagents.add_reagent("omnizine", 3)
			M.reagents.add_reagent("methamphetamine", 3)
		..()

/obj/item/reagent_containers/food/snacks/ingredient/melted_sugar
	name = "tray of melted sugar"
	desc = "Sugar that's melted enough to be soft and malleable."
	icon_state = "meltedsugar-sheet"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "sugartray"
	food_color = "#FFFFFF"
	initial_volume = 45
	initial_reagents = list("sugar"=15)
	bites_left = 5
	use_bite_mask = FALSE
	food_color = null
	var/image/image_sugar = null
	var/image/image_tray = null
	event_handler_flags = USE_FLUID_ENTER
	required_utensil = REQUIRED_UTENSIL_SPOON
	w_class = W_CLASS_BULKY
	two_handed = TRUE
	dropped_item = /obj/item/plate/tray
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/ingredient/melted_sugar_strip
	slice_amount = 3
	slice_suffix = "strip"

	New()
		..()
		src.reagents.set_reagent_temp(185 + T0C) //HOT
		src.flags |= OPENCONTAINER

	on_reagent_change()
		..()
		src.UpdateIcon()

	update_icon()
		var/datum/color/average = src.reagents.get_average_color()
		src.food_color = average.to_rgb()
		if (!src.image_sugar)
			src.image_sugar = image(src.icon, "meltedsugar-sheet")
		src.image_sugar.color = src.food_color
		src.image_sugar.alpha = round(average.a / 1.5)
		if (!src.image_tray)
			src.image_tray = image('icons/obj/foodNdrink/food_related.dmi', "tray")
		src.UpdateOverlays(src.image_tray, "tray")
		src.UpdateOverlays(src.image_sugar, "meltedsugar-sheet")

	onSlice()
		new /obj/item/plate/tray(src.loc)

/obj/item/reagent_containers/food/snacks/ingredient/melted_sugar_strip
	name = "melted sugar strips"
	desc = "Sugar that's melted enough to be soft and malleable."
	icon_state = "meltedsugar-strip"
	food_color = "#FFFFFF"
	initial_volume = 15
	initial_reagents = list("sugar"=15)
	food_color = null
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/candy/hard_candy
	slice_amount = 3
	slice_suffix = "piece"
	var/circular = FALSE // if the strip has been made circular
	var/floured = FALSE // if the strip has been covered in flour and is ready to be made into dragon's beard

	New()
		. = ..()
		src.reagents.set_reagent_temp(185 + T0C)

	on_reagent_change()
		..()
		src.UpdateIcon()

	update_icon()
		var/datum/color/average = src.reagents.get_average_color()
		src.food_color = average.to_rgba()
		src.color = average.to_rgb()
		if (src.floured)
			src.alpha = average.a
		else
			src.alpha = round(average.a / 1.5)

	attack_self(mob/user as mob)
		if (!src.circular)
			user.visible_message("[user] folds [src] into a ring.", "You fold [src] into a ring.")
			name = "melted sugar torus"
			src.icon_state = "meltedsugar-circle"
			src.sliceable = FALSE
			src.circular = TRUE
		else if (src.floured)
			user.visible_message("[user] twists [src], folding it in on itself!", "You twist [src] and fold it back into a ring.")
			playsound(src.loc, "rustle", 50, 1)
			var/obj/item/reagent_containers/food/snacks/candy/dragons_beard/beard = new
			beard.reagents.clear_reagents()
			src.reagents.trans_to(beard, 15)
			beard.reagents.set_reagent_temp(20 + T0C) //magically becomes room temperature from folding
			user.u_equip(src)
			user.put_in_hand_or_drop(beard)
			SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, beard, user)
			qdel(src)
			return
		src.UpdateIcon()

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/rods) || istype(W,/obj/item/stick))
			if(istype(W,/obj/item/stick))
				var/obj/item/stick/S = W
				if(S.broken)
					boutput(user, SPAN_ALERT("That stick is broken!"))
					return
			if (circular)
				boutput(user, SPAN_NOTICE("You curl the sugar tighter and put it onto [W]."))
				var/obj/item/reagent_containers/food/snacks/candy/swirl_lollipop/newcandy = new /obj/item/reagent_containers/food/snacks/candy/swirl_lollipop(get_turf(src))
				newcandy.reagents.clear_reagents()
				src.reagents.trans_to(newcandy, 15)
				user.u_equip(src)
				user.put_in_hand_or_drop(newcandy)
				SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, newcandy, user)
			else
				boutput(user, SPAN_NOTICE("The melted sugar solidifies on [W]. You give it a vaguely rocky texture."))
				var/obj/item/reagent_containers/food/snacks/candy/rock_candy/newcandy = new /obj/item/reagent_containers/food/snacks/candy/rock_candy(get_turf(src))
				newcandy.reagents.clear_reagents()
				src.reagents.trans_to(newcandy, 15)
				user.u_equip(src)
				user.put_in_hand_or_drop(newcandy)
				SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, newcandy, user)

			if(istype(W,/obj/item/rods)) W.change_stack_amount(-1)
			if(istype(W,/obj/item/stick)) W.amount--
			if(!W.amount) qdel(W)

			qdel(src)
		else if (src.circular && !src.floured && istype(W,/obj/item/reagent_containers/food/snacks/ingredient/flour))
			boutput(user, SPAN_NOTICE("You flour [src]."))
			src.floured = TRUE
			src.UpdateIcon()
		else
			..()

/obj/item/reagent_containers/food/snacks/ingredient/brownie_batter
	name = "brownie batter"
	desc = "As delicious as it may look, you MUST resist the temptation!"
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	icon_state = "brownie_batter"
	bites_left = 12
	heal_amt = 1
	food_color = "#38130C"
	initial_volume = 40
	initial_reagents = list("chocolate" = 20)
	use_bite_mask = FALSE
	required_utensil = REQUIRED_UTENSIL_SPOON
	w_class = W_CLASS_BULKY

/obj/item/reagent_containers/food/snacks/ingredient/breadcrumbs
	name = "breadcrumbs"
	desc = "Some dried breadcrumbs."
	icon_state = "breadcrumbs"
	bites_left = 1
	heal_amt = 0
	initial_volume = 1
	initial_reagents = list("bread"=1)

/obj/item/reagent_containers/food/snacks/ingredient/vanilla_extract
	name = "vanilla extract"
	desc = "Surely it tastes like vanilla ice cream, right?"
	icon_state = "vanilla-extract"
	initial_volume = 10
	initial_reagents = list("vanilla" = 10)

/obj/item/reagent_containers/food/snacks/ingredient/raw_flan
	name = "uncooked flan"
	desc = "Is this queso, custard or flan?"
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "custard"
	initial_volume = 10
	initial_reagents = list("vanilla" = 10)
