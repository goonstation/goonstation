ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/pie)
/obj/item/reagent_containers/food/snacks/pie
	name = "pie"
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	desc = "A null pie. You shouldn't be able to see this!"
	item_state = "pie"
	required_utensil = REQUIRED_UTENSIL_SPOON
	fill_amt = 6
	sliceable = FALSE
	slice_amount = 8
	slice_product = /obj/item/reagent_containers/food/snacks/pieslice
	var/splat = 0 // for thrown pies
	food_effects = list("food_refreshed","food_cold")
	///In the case of a thrown splattered pie, minimum amount of time we remain visually stuck on someone's face.
	var/min_stuck_time = 5 SECONDS
	///In the case of a thrown splattered pie, maximum amount of time we remain visually stuck on someone's face.
	var/max_stuck_time = 10 SECONDS

/obj/item/reagent_containers/food/snacks/pie/throw_impact(atom/hit_atom, datum/thrown_thing/thr)
	//first, try to do item pie behaviour
	if(length(src.contents) && thr.user)
		var/obj/item/contained_item = pick(src.contents)
		if (istype(contained_item))
			src.item_pie(contained_item, thr.user, hit_atom)
			return

	if (!ismob(hit_atom) || !src.splat)
		return ..()

	var/mob/M = hit_atom
	var/mob/thrower = thr.thrown_by
	playsound(src, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, TRUE)
	if (thrower?.mind?.assigned_role == "Clown" && ishuman(M) && (prob(50) || M.mind?.assigned_role == "Captain") && !M.GetOverlayImage("face_pie"))
		src.clown_pie(thrower, M)
		return

	src.visible_message(SPAN_ALERT("[src] splats in [M]'s face!"))
	M.change_eye_blurry(rand(5,10))
	M.take_eye_damage(rand(0, 2), 1)
	if (prob(40))
		JOB_XP(M, "Clown", 2)

///Effect for when pie contains an item, hit the target with that item and call AfterAttack
/obj/item/reagent_containers/food/snacks/pie/proc/item_pie(obj/item/contained_item, mob/user, atom/hit_atom)
	playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
	//for Attackby, we specifically need any atom as target (TIL ID-pies to open doors are a thing and it fills me with joy)
	SPAWN(0)
		hit_atom.Attackby(contained_item, user)
		if (ismob(hit_atom))
			var/mob/hit_mob = hit_atom
			//for AfterAttack, we specifically need a mob as target
			contained_item.AfterAttack(hit_mob, user)
			if (hit_mob == user)
				src.visible_message(SPAN_ALERT("[user] fumbles and smacks the [src] into [his_or_her(user)] own face!"))
			else
				src.visible_message(SPAN_ALERT("[src] smacks into [hit_mob]!"))

///Stick to a person's face comedically when thrown by a clown
/obj/item/reagent_containers/food/snacks/pie/proc/clown_pie(mob/user, mob/living/carbon/human/target)
	var/image/face_pie = image('icons/obj/foodNdrink/food_dessert.dmi', "face_pie")
	src.visible_message(SPAN_NOTICE("[src] splats right in [target]'s face and remains stuck there!"))
	face_pie.layer = MOB_OVERLAY_BASE
	face_pie.appearance_flags = RESET_COLOR | PIXEL_SCALE
	var/overlay_key = "face_pie"
	if(target.mutantrace.head_offset)
		face_pie.pixel_y = target.mutantrace.head_offset
	target.UpdateOverlays(face_pie, overlay_key)
	src.set_loc(target)
	target.bioHolder?.AddEffect("bad_eyesight")
	JOB_XP(user, "Clown", 1)
	SPAWN(rand(src.min_stuck_time, src.max_stuck_time))
		if (QDELETED(target))
			return
		target.bioHolder?.RemoveEffect("bad_eyesight")
		target.UpdateOverlays(null, overlay_key)
		if (QDELETED(src))
			return
		src.visible_message(SPAN_NOTICE("[src] falls off of [target]'s face."))
		src.set_loc(target.loc)
		qdel(face_pie)

/obj/item/reagent_containers/food/snacks/pie/Exited(atom/movable/Obj, newloc)
	. = ..()
	if(!QDELETED(Obj))
		Obj.visible_message(SPAN_ALERT("[Obj] dissolves completely upon leaving [src]!"))
		qdel(Obj)


ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/pieslice)
/obj/item/reagent_containers/food/snacks/pieslice
	name = "slice of pie"
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	desc = "A slice of null pie. You shouldn't be able to see this!"
	food_effects = list("food_refreshed","food_cold")
	bites_left = 1
	heal_amt = 4
	initial_volume = 5
	apple
		name = "slice of apple pie"
		icon_state = "applepie-slice"
		initial_reagents = list("juice_apple"=3)
		desc = "A slice of apple pie. Is there anything more Space-American?"
	lime
		name = "slice of lime pie"
		icon_state = "limepie-slice"
		initial_reagents = list("juice_lime"=3)
		desc = "A slice of key lime pie. Tart, sweet, and with a dollop of cream on top."
	lemon
		name = "slice of lemon pie"
		icon_state = "lemonpie-slice"
		initial_reagents = list("juice_lemon"=3)
		desc = "A slice of lemon meringue pie. A fine use of fruit curd."
	strawberry
		name = "slice of strawberry pie"
		icon_state = "strawberrypie-slice"
		initial_reagents = list("juice_strawberry"=3)
		desc = "A slice of strawberry pie. It smells like summertime memories."
	pumpkin
		name = "slice of pumpkin pie"
		icon_state = "pumpie-slice"
		initial_reagents = list("juice_pumpkin"=3)
		desc = "A slice of pumpkin pie. An autumn favourite."
	chocolate
		name = "slice of chocolate pie"
		icon_state = "chocolatepie-slice"
		initial_reagents = list("sugar"=3, "hugs"=2)
		desc = "Like a slice of chocolate cake, but a slice of pie, and also very different."
	raspberry
		name = "slice of raspberry pie"
		icon_state = "raspberrypie-slice"
		initial_reagents = list("juice_raspberry"=3)
		desc = "A slice of raspberry pie. Those are fresh raspberries, too. Oh man."
	blackberry
		name = "slice of blackberry pie"
		icon_state = "blackberrypie-slice"
		initial_reagents = list("juice_blackberry"=3)
		desc = "A slice of blackberry pie. The stains will be oh so worth it."
	blueberry
		name = "slice of blueberry pie"
		icon_state = "blueberrypie-slice"
		initial_reagents = list("juice_blueberry"=3)
		desc = "A slice of blueberry pie. Blueberries cook up purple, who knew?"
	cherry
		name = "slice of cherry pie"
		icon_state = "cherrypie-slice"
		initial_reagents = list("juice_cherry"=3)
		desc = "A slice of cherry pie. It looks so good, it brings a tear to you eye."

/obj/item/reagent_containers/food/snacks/pie/custard
	name = "custard pie"
	desc = "It smells delicious. You just want to plant your face in it."
	icon_state = "pie"
	splat = 1
	required_utensil = REQUIRED_UTENSIL_SPOON
	bites_left = 3
	throwforce = 0
	force = 0

/obj/item/reagent_containers/food/snacks/pie/apple
	name = "apple pie"
	desc = "Is there anything more Space-American?"
	icon_state = "applepie"
	item_state = "apple_pie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 30
	initial_reagents = list("juice_apple"=24)
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/pieslice/apple

/obj/item/reagent_containers/food/snacks/pie/lime
	name = "key lime pie"
	desc = "Tart, sweet, and with a dollop of cream on top."
	icon_state = "limepie"
	item_state = "lime_pie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 30
	initial_reagents = list("juice_lime"=24)
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/pieslice/lime


/obj/item/reagent_containers/food/snacks/pie/lemon
	name = "lemon meringue pie"
	desc = "A fine use of fruit curd."
	icon_state = "lemonpie"
	item_state = "lemon_pie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 32
	initial_reagents = list("juice_lemon"=24)
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/pieslice/lemon

/obj/item/reagent_containers/food/snacks/pie/strawberry
	name = "strawberry pie"
	desc = "It smells like summertime memories."
	icon_state = "strawberrypie"
	item_state = "strawberry_pie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 32
	initial_reagents = list("juice_strawberry"=24)
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/pieslice/strawberry

/obj/item/reagent_containers/food/snacks/pie/pumpkin
	name = "pumpkin pie"
	desc = "An autumn favourite."
	icon_state = "pumpie"
	item_state = "pumpkin_pie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 32
	initial_reagents = list("juice_pumpkin"=24)
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/pieslice/pumpkin

/obj/item/reagent_containers/food/snacks/pie/cream
	name = "cream pie"
	desc = "More often used in pranks than culinary matters..."
	icon_state = "creampie"
	item_state = "cream_pie"
	splat = 1
	required_utensil = REQUIRED_UTENSIL_SPOON
	throwforce = 0
	force = 0
	bites_left = 2
	heal_amt = 6
	initial_reagents = list("cream"=10)

/obj/item/reagent_containers/food/snacks/pie/anything
	name = "anything pie"
	desc = "An empty anything pie."
	icon_state = "pie"
	bites_left = 3
	heal_amt = 4
	use_bite_mask = FALSE

/obj/item/reagent_containers/food/snacks/pie/slurry
	name = "slurry pie"
	desc = "Though dangerous to eat raw, the slurrypod produces a fine, tart pie noted for its curative properties."
	icon_state = "slurrypie"
	item_state = "slurry_pie"
	bites_left = 3
	heal_amt = 5
	initial_volume = 30
	initial_reagents = list("mutadone"=15)
	food_effects = list("food_bad_breath","food_cold")

/obj/item/reagent_containers/food/snacks/pie/bacon
	name = "bacon pie"
	desc = "Named in honor of Sir Francis Bacon, who tragically died as the result of an early experiment into the field of bacon ice cream."
	icon_state = "baconpie"
	item_state = "bacon_pie"
	bites_left = 3
	heal_amt = 6
	initial_volume = 80
	initial_reagents = list("porktonium"=75)
	food_effects = list("food_sweaty", "food_hp_up_big", "food_cold")


	heal(var/mob/M)
		..()
		M.nutrition += 500
		return

/obj/item/reagent_containers/food/snacks/pie/ass
	name = "moon pie" // it's 2020 jabronis, out with the ableism ;)
	desc = "Thicc."
	icon_state = "asspie"
	item_state = "butt_pie"
	splat = 1
	throwforce = 0
	force = 0
	bites_left = 3
	heal_amt = 2
	food_effects = list("food_sweaty_big","food_refreshed")
	New()
		..()
		if(prob(10))
			name = pick("fart pie","butt pie","mud pie","piesterior","ham pie","dump cake","derri-eclaire")

/obj/item/reagent_containers/food/snacks/pie/chocolate
	name = "chocolate mud pie"
	desc = "Like a chocolate cake, but a pie, and also very different."
	icon_state = "chocolatepie"
	item_state = "chocolate_pie"
	heal_amt = 6
	bites_left = 3
	initial_volume = 30
	initial_reagents = list("sugar"=20,"hugs"=10)
	food_effects = list("food_sweaty","food_refreshed", "food_explosion_resist")
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/pieslice/chocolate

/obj/item/reagent_containers/food/snacks/pie/pot
	name = "space-chicken pot pie"
	desc = "Space-chickens are identical to regular chickens, but in space.  This is a pastry filled with their cooked flesh, some vegetables, and a cream gravy."
	icon_state = "chickenpie"
	item_state = "pot_pie"
	heal_amt = 6
	bites_left = 3
	initial_volume = 30
	initial_reagents = list("chickensoup"=20)
	food_effects = list("food_sweaty","food_hp_up_big","food_refreshed")

/obj/item/reagent_containers/food/snacks/pie/weed
	name = "chicken \"pot\" pie"
	desc = "Something about this pie seems off.  Guaranteed to get you pie-in-the-sky high."
	icon_state = "weedpie"
	item_state = "weed_pie"
	heal_amt = 4
	bites_left = 3
	initial_volume = 30
	initial_reagents = list("THC"=20,"CBD"=20)
	food_effects = list("food_sweaty","food_refreshed")

/obj/item/reagent_containers/food/snacks/pie/fish
	name = "stargazy pie"
	desc = "The snack that stares back."
	icon_state = "fishpie"
	item_state = "fish_pie"
	heal_amt = 4
	bites_left = 3
	initial_volume = 30
	food_effects = list("food_sweaty","food_rad_resist","food_refreshed")

/obj/item/reagent_containers/food/snacks/pie/raspberry
	name = "raspberry pie"
	desc = "Those are fresh raspberries, too. Oh man."
	icon_state = "raspberrypie"
	item_state = "raspberry_pie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 32
	initial_reagents = list("juice_raspberry"=24)
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/pieslice/raspberry

/obj/item/reagent_containers/food/snacks/pie/blackberry
	name = "blackberry pie"
	desc = "The stains will be oh so worth it."
	icon_state = "blackberrypie"
	item_state = "blackberry_pie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 32
	initial_reagents = list("juice_blackberry"=24)
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/pieslice/blackberry

/obj/item/reagent_containers/food/snacks/pie/blueberry
	name = "blueberry pie"
	desc = "Blueberries cook up purple, who knew?"
	icon_state = "blueberrypie"
	item_state = "blueberry_pie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 32
	initial_reagents = list("juice_blueberry"=24)
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/pieslice/blueberry

/obj/item/reagent_containers/food/snacks/pie/cherry
	name = "cherry pie"
	desc = "It looks so good, it brings a tear to you eye."
	icon_state = "cherrypie"
	item_state = "cherry_pie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 32
	initial_reagents = list("juice_cherry"=24)
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/pieslice/cherry
