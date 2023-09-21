
/* ==================================================== */
/* -------------------- Dispensers -------------------- */
/* ==================================================== */

/obj/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = UNANCHORED
	flags = FPRINT | FLUID_SUBMERGE | ACCEPTS_MOUSEDROP_REAGENTS
	object_flags = NO_GHOSTCRITTER
	pressure_resistance = 2*ONE_ATMOSPHERE
	p_class = 1.5

	var/amount_per_transfer_from_this = 10
	var/capacity

	New()
		..()
		// TODO enable when I do leaking
		// src.AddComponent(/datum/component/bullet_holes, 10, 5)
		src.create_reagents(4000)


	get_desc(dist, mob/user)
		if (dist <= 2 && reagents)
			. += "<br><span class='notice'>[reagents.get_description(user,RC_SCALE)]</span>"

	proc/smash()
		var/turf/T = get_turf(src)
		T.fluid_react(src.reagents, min(src.reagents.total_volume,10000))
		src.reagents.clear_reagents()
		qdel(src)

	ex_act(severity)
		switch(severity)
			if (1)
				smash()
				return
			if (2)
				if (prob(50))
					smash()
					return
			if (3)
				if (prob(5))
					smash()
					return
			else
		return

	blob_act(var/power)
		if (prob(25))
			smash()

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		..()
		if (reagents)
			for (var/i = 0, i < 9, i++) // ugly hack
				reagents.temperature_reagents(exposed_temperature, exposed_volume)

	attackby(obj/item/W, mob/user)
		// prevent attacked by messages
		if(istype(W, /obj/item/reagent_containers/hypospray) || istype(W, /obj/item/reagent_containers/mender))
			return
		..(W, user)

	mouse_drop(atom/over_object as obj)
		if (!(over_object.flags & ACCEPTS_MOUSEDROP_REAGENTS))
			return ..()

		if (BOUNDS_DIST(usr, src) > 0 || BOUNDS_DIST(usr, over_object) > 0)
			boutput(usr, "<span class='alert'>That's too far!</span>")
			return

		src.transfer_all_reagents(over_object, usr)

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */
/obj/reagent_dispensers/cleanable
	flags = FPRINT | FLUID_SUBMERGE

/obj/reagent_dispensers/cleanable/ants
	name = "space ants"
	desc = "A bunch of space ants."
	icon = 'icons/effects/effects.dmi'
	icon_state = "spaceants"
	layer = MOB_LAYER
	density = 0
	anchored = ANCHORED
	amount_per_transfer_from_this = 5

	New()
		..()
		var/scale = (rand(2, 10) / 10) + (rand(0, 5) / 100)
		src.Scale(scale, scale)
		src.set_dir(pick(NORTH, SOUTH, EAST, WEST))
		reagents.add_reagent("ants",20)

	get_desc(dist, mob/user)
		return null

	attackby(obj/item/W, mob/user)
		..(W, user)
		SPAWN(1 SECOND)
			if (src?.reagents)
				if (src.reagents.total_volume <= 1)
					qdel(src)
		return

/obj/reagent_dispensers/cleanable/spiders
	name = "spiders"
	desc = "A bunch of spiders."
	icon = 'icons/effects/effects.dmi'
	icon_state = "spaceants"
	layer = MOB_LAYER
	density = 0
	anchored = ANCHORED
	amount_per_transfer_from_this = 5
	color = "#160505"

	New()
		..()
		var/scale = (rand(2, 10) / 10) + (rand(0, 5) / 100)
		src.Scale(scale, scale)
		src.set_dir(pick(NORTH, SOUTH, EAST, WEST))
		src.pixel_x = rand(-8,8)
		src.pixel_y = rand(-8,8)
		reagents.add_reagent("spiders", 5)

	get_desc(dist, mob/user)
		return null

	attackby(obj/item/W, mob/user)
		..(W, user)
		SPAWN(1 SECOND)
			if (src?.reagents)
				if (src.reagents.total_volume <= 1)
					qdel(src)
		return

/obj/reagent_dispensers/foamtank
	name = "foamtank"
	desc = "A massive tank full of firefighting foam, for refilling extinguishers."
	icon = 'icons/obj/objects.dmi'
	icon_state = "foamtank"
	amount_per_transfer_from_this = 25

	New()
		..()
		reagents.add_reagent("ff-foam",1000)

/obj/reagent_dispensers/watertank
	name = "watertank"
	desc = "A watertank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 25
	capacity = 1000

	New()
		..()
		reagents.add_reagent("water",capacity)

/obj/reagent_dispensers/watertank/big
	name = "high-capacity watertank"
	desc = "A specialised high-pressure water tank for holding large amounts of water."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertankbig"
	anchored = UNANCHORED
	amount_per_transfer_from_this = 25

	attackby(obj/item/W, mob/user)
		if(istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			if(!src.anchored)
				user.visible_message("<b>[user]</b> secures the [src] to the floor!")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				src.anchored = ANCHORED
			else
				user.visible_message("<b>[user]</b> unbolts the [src] from the floor!")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				src.anchored = UNANCHORED
			return

	New()
		..()
		src.create_reagents(10000)
		reagents.add_reagent("water",10000)

TYPEINFO(/obj/reagent_dispensers/watertank/fountain)
	mats = 8

/obj/reagent_dispensers/watertank/fountain
	name = "water cooler"
	desc = "A popular gathering place for NanoTrasen's finest bureaucrats and pencil-pushers."
	icon_state = "coolerbase"
	anchored = ANCHORED
	deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR
	capacity = 500

	var/has_tank = 1

	var/cup_max = 12
	var/cup_amount

	var/image/cup_sprite = null
	var/image/fluid_sprite = null
	var/image/tank_sprite = null

	New()
		..()

		src.cup_sprite = new /image(src.icon, "coolercup")
		src.fluid_sprite = new /image(src.icon,"fluid-coolertank")
		src.tank_sprite = new /image(src.icon,"coolertank", layer=src.fluid_sprite.layer + 0.1)
		src.tank_sprite.alpha = 180

		src.cup_amount = src.cup_max

		src.UpdateIcon()

	//on_reagent_change()
	//	src.UpdateIcon()

	update_icon()
		if (src.has_tank)
			if (src.reagents.total_volume)
				var/datum/color/average = reagents.get_average_color()
				src.fluid_sprite.color = average.to_rgba()
				src.UpdateOverlays(fluid_sprite, "fluid_overlay")
			src.UpdateOverlays(tank_sprite, "tank_overlay")
		else
			src.UpdateOverlays(null, "fluid_overlay")
			src.UpdateOverlays(null, "tank_overlay")
		if (cup_amount > 0)
			src.UpdateOverlays(cup_sprite, "cup_overlay")
		else
			src.UpdateOverlays(null, "cup_overlay")

	get_desc(dist, mob/user)
		. += "There's [cup_amount] paper cup[s_es(src.cup_amount)] in [src]'s cup dispenser."
		if (dist <= 2 && reagents)
			. += "<br><span class='notice'>[reagents.get_description(user,RC_SCALE)]</span>"

	attackby(obj/W, mob/user)
		if (has_tank)
			if (iswrenchingtool(W))
				user.show_text("You disconnect the bottle from [src].", "blue")
				var/obj/item/reagent_containers/food/drinks/P = new /obj/item/reagent_containers/food/drinks/coolerbottle(src.loc)
				P.reagents.maximum_volume = max(P.reagents.maximum_volume, src.reagents.total_volume)
				src.reagents.trans_to(P, reagents.total_volume)
				src.reagents.clear_reagents()
				src.has_tank = 0
				src.UpdateIcon()
				return
		else if (istype(W, /obj/item/reagent_containers/food/drinks/coolerbottle))
			user.show_text("You connect the bottle to [src].", "blue")
			W.reagents.trans_to(src, W.reagents.total_volume)
			user.u_equip(W)
			qdel(W)
			src.has_tank = 1
			src.UpdateIcon()
			return

		if (isscrewingtool(W))
			if (src.anchored)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user.show_text("You start unscrewing [src] from the floor.", "blue")
				if (do_after(user, 3 SECONDS))
					user.show_text("You unscrew [src] from the floor.", "blue")
					src.anchored = UNANCHORED
					return
			else
				var/turf/T = get_turf(src)
				if (istype(T, /turf/space))
					user.show_text("What exactly are you gunna secure [src] to?", "red")
					return
				else
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					user.show_text("You start securing [src] to [T].", "blue")
					if (do_after(user, 3 SECONDS))
						user.show_text("You secure [src] to [T].", "blue")
						src.anchored = ANCHORED
						return
		..()

	attack_hand(mob/user)
		if (src.cup_amount <= 0)
			user.show_text("\The [src] doesn't have any cups left, damnit.", "red")
			return
		else
			src.visible_message("<b>[user]</b> grabs a paper cup from [src].",\
			"You grab a paper cup from [src].")
			src.cup_amount --
			var/obj/item/reagent_containers/food/drinks/paper_cup/P = new /obj/item/reagent_containers/food/drinks/paper_cup(src)
			user.put_in_hand_or_drop(P)
			if (src.cup_amount <= 0)
				user.show_text("That was the last cup!", "red")
				src.UpdateIcon()

	piss
		New()
			..()
			src.create_reagents(4000)
			reagents.add_reagent("urine",400)
			reagents.add_reagent("water",600)
			src.UpdateIcon()
		name = "discolored water fountain"
		desc = "It's called a fountain, but it's not very decorative or interesting. You can get a drink from it, though seeing the color you feel you shouldn't"
		color = "#ffffcc"

	juicer
		New()
			..()
			src.create_reagents(4000)
			reagents.add_reagent(pick("CBD","THC","urine","refried_beans","coffee","methamphetamine"),100)
			reagents.add_reagent(pick("CBD","THC","urine","refried_beans","coffee","methamphetamine"),100)
			reagents.add_reagent(pick("CBD","THC","urine","refried_beans","coffee","methamphetamine"),100)
			reagents.add_reagent(pick("CBD","THC","urine","refried_beans","coffee","methamphetamine"),100)
			reagents.add_reagent("water",600)
			src.UpdateIcon()
		name = "discolored water fountain"
		desc = "It's called a fountain, but it's not very decorative or interesting. You can get a drink from it, though seeing the color you feel you shouldn't"
		color = "#ccffcc"



/obj/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A high-pressure tank full of welding fuel. Keep away from open flames and sparks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"
	amount_per_transfer_from_this = 25
	var/isburst = FALSE

	New()
		..()
		reagents.add_reagent("fuel",4000)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (!src.reagents.has_reagent("fuel",20))
			return 0
		user.visible_message("<span class='alert'><b>[user] drinks deeply from [src]. [capitalize(he_or_she(user))] then pulls out a match from somewhere, strikes it and swallows it!</b></span>")
		src.reagents.remove_any(20)
		playsound(src.loc, 'sound/items/drink.ogg', 50, 1, -6)
		user.TakeDamage("chest", 0, 150)
		if (isliving(user))
			var/mob/living/L = user
			L.changeStatus("burning", 10 SECONDS)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1


	electric_expose(var/power = 1) //lets throw in ANOTHER hack to the temp expose one above
		if (reagents)
			for (var/i = 0, i < 3, i++)
				reagents.temperature_reagents(power*500, power*400, 1000, 1000, 1)

	Bumped(AM)
		. = ..()
		if (ismob(AM))
			add_fingerprint(AM, TRUE)
		else if (ismob(usr))
			add_fingerprint(usr, TRUE)

	ex_act(severity)
		..()
		icon_state = "weldtank-burst" //to ensure that a weldertank's always going to be updated by their own explosion
		isburst = TRUE

	is_open_container()
		return isburst

/obj/reagent_dispensers/heliumtank
	name = "heliumtank"
	desc = "A tank of helium."
	icon = 'icons/obj/objects.dmi'
	icon_state = "heliumtank"
	amount_per_transfer_from_this = 25

	New()
		..()
		reagents.add_reagent("helium",4000)

/obj/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "Full of delicious alcohol, hopefully."
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"
	amount_per_transfer_from_this = 25

	New()
		..()
		reagents.add_reagent("beer",1000)

/obj/reagent_dispensers/chemicalbarrel
	name = "chemical barrel"
	desc = "For storing medical chemicals and less savory things. It can be labeled with a pen."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrel-blue"
	amount_per_transfer_from_this = 25
	p_class = 3
	flags = FPRINT | FLUID_SUBMERGE | OPENCONTAINER | ACCEPTS_MOUSEDROP_REAGENTS
	var/base_icon_state = "barrel-blue"
	var/funnel_active = TRUE //if TRUE, allows players pouring liquids from beakers with just one click instead of clickdrag, for convenience
	var/image/fluid_image = null
	var/image/lid_image = null
	var/image/spout_image = null
	var/obj/machinery/chem_master/linked_machine = null

	New()
		..()
		src.UpdateIcon()

	update_icon()
		var/fluid_state = round(clamp((src.reagents.total_volume / src.reagents.maximum_volume * 9 + 1), 1, 9))
		if (!src.fluid_image)
			src.fluid_image = image(src.icon)
		if (src.reagents && src.reagents.total_volume)
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.fluid_image.icon_state = "fluid-barrel-[fluid_state]"
		else
			fluid_image.icon_state = "fluid-barrel-0"
		src.UpdateOverlays(src.fluid_image, "fluid")

		if (!src.lid_image)
			src.lid_image = image(src.icon)
			src.lid_image.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
		if(!src.is_open_container())
			src.lid_image.icon_state = "[base_icon_state]-lid"
			src.UpdateOverlays(src.lid_image, "lid")
		else
			src.lid_image.layer = src.fluid_image.layer + 0.1
			src.lid_image.icon_state = null
			src.UpdateOverlays(null, "lid")

		if (!src.spout_image)
			src.spout_image = image(src.icon)
			src.spout_image.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
		if(src.funnel_active)
			src.spout_image.icon_state = "[base_icon_state]-funnel"
		else
			src.spout_image.icon_state = "[base_icon_state]-spout"
		src.UpdateOverlays(src.spout_image, "spout")

		..()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/pen) && (src.name == initial(src.name)))
			var/t = tgui_input_text(user, "Enter a label for the barrel.", "Label", "chemical", 24)
			if(t && t != src.name)
				phrase_log.log_phrase("barrel", t, no_duplicates=TRUE)
			t = copytext(strip_html(t), 1, 24)
			if (isnull(t) || !length(t) || t == " ")
				return
			if (!findtext(t, "barrel"))     //so we don't see lube barrel barrel
				t += " barrel"          	//so it's clear it's a barrel, and not just "lube"
			if (!in_interact_range(src, user) && src.loc != user)
				return

			src.name = t

			src.desc = "For storing medical chemicals and less savory things."

		if (istype(W, /obj/item/reagent_containers/synthflesh_pustule))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[src] is full.</span>")
				return

			boutput(user, "<span class='notice'>You squeeze the [W] into the [src]. Gross.</span>")
			playsound(src.loc, pick('sound/effects/splort.ogg'), 100, 1)

			W.reagents.trans_to(src, W.reagents.total_volume)
			user.u_equip(W)
			qdel(W)

		if (istool(W, TOOL_WRENCHING))
			if(src.flags & OPENCONTAINER)
				user.visible_message("<b>[user]</b> wrenches the [src]'s lid closed!")
			else
				user.visible_message("<b>[user]</b> wrenches the [src]'s lid open!")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			src.set_open_container(!src.is_open_container())
			UpdateIcon()
		else
			..()

	mouse_drop(atom/over_object, src_location, over_location)
		if (istype(over_object, /obj/machinery/chem_master))
			var/obj/machinery/chem_master/chem_master = over_object
			chem_master.try_attach_barrel(src, usr)
			return
		..()

	bullet_act()
		..()
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 30, 1)

	attack_hand(var/mob/user)
		if(funnel_active)
			funnel_active = FALSE
			boutput(user, "<span class='notice'>You flip the funnel into spout mode on the [src.name].</span>")
		else
			funnel_active = TRUE
			boutput(user, "<span class='notice'>You flip the spout into funnel mode on the [src.name].</span>")
		UpdateIcon()
		..()

	on_reagent_change()
		..()
		src.UpdateIcon()

	shatter_chemically(var/projectiles = FALSE) //needs sound probably definitely for sure
		for(var/mob/M in AIviewers(src))
			boutput(M, "<span class='alert'>The <B>[src.name]</B> breaks open!</span>")
		if(projectiles)
			var/datum/projectile/special/spreader/uniform_burst/circle/circle = new /datum/projectile/special/spreader/uniform_burst/circle/(get_turf(src))
			circle.shot_sound = null //no grenade sound ty
			circle.spread_projectile_type = /datum/projectile/bullet/shrapnel/shrapnel_implant
			circle.pellet_shot_volume = 0
			circle.pellets_to_fire = 10
			shoot_projectile_ST_pixel_spread(get_turf(src), circle, get_step(src, NORTH))
		var/obj/shattered_barrel/shattered_barrel = new /obj/shattered_barrel
		shattered_barrel.icon_state = "[src.base_icon_state]-shattered"
		shattered_barrel.set_loc(get_turf(src))
		src.smash()
		return TRUE

	disposing()
		src.linked_machine?.eject_beaker(null)
		. = ..()

	get_chemical_effect_position()
		return 10
	red
		icon_state = "barrel-red"
		base_icon_state = "barrel-red"
	yellow
		icon_state = "barrel-yellow"
		base_icon_state = "barrel-yellow"
	oil
		icon_state = "barrel-flamable"
		base_icon_state = "barrel-flamable"
		name = "oil barrel"
		desc = "A barrel for storing large amounts of oil."

		New()
			..()
			reagents.add_reagent("oil", 4000)

/obj/shattered_barrel
	name = "shattered chemical barrel"
	desc = "It's been totally wrecked. Just unbarrelable. Fuck."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrel-blue-shattered"
	anchored = UNANCHORED

/obj/reagent_dispensers/beerkeg/rum
	name = "barrel of rum"
	desc = "It better not be empty."
	icon_state = "rum_barrel"

	New()
		..()
		reagents.remove_reagent("beer",1000)
		reagents.add_reagent("rum",1000)

/obj/reagent_dispensers/compostbin
	name = "compost tank"
	desc = "A device that mulches up unwanted produce into usable fertiliser."
	icon = 'icons/obj/objects.dmi'
	icon_state = "compost"
	anchored = UNANCHORED
	amount_per_transfer_from_this = 30
	event_handler_flags = NO_MOUSEDROP_QOL
	New()
		..()

	get_desc(dist, mob/user)
		if (dist > 2)
			return
		if (!reagents)
			return
		. = "<br><span class='notice'>[reagents.get_description(user,RC_FULLNESS)]</span>"
		return

	attackby(obj/item/W, mob/user)
		if(istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			if(!src.anchored)
				user.visible_message("<b>[user]</b> secures the [src] to the floor!")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				src.anchored = ANCHORED
			else
				user.visible_message("<b>[user]</b> unbolts the [src] from the floor!")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				src.anchored = UNANCHORED
			return
		var/load = 1
		if (istype(W,/obj/item/reagent_containers/food/snacks/plant/)) src.reagents.add_reagent("poo", 20)
		else if (istype(W,/obj/item/reagent_containers/food/snacks/mushroom/)) src.reagents.add_reagent("poo", 25)
		else if (istype(W,/obj/item/seed/)) src.reagents.add_reagent("poo", 2)
		else if (istype(W,/obj/item/plant/) || istype(W,/obj/item/clothing/head/flower/)) src.reagents.add_reagent("poo", 15)
		else if (istype(W,/obj/item/organ/)) src.reagents.add_reagent("poo", 35)
		else load = 0

		if(load)
			boutput(user, "<span class='notice'>[src] mulches up [W].</span>")
			playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 30, 1)
			user.u_equip(W)
			W.dropped(user)
			qdel( W )
			return
		else ..()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!isliving(user))
			boutput(user, "<span class='alert'>Excuse me you are dead, get your gross dead hands off that!</span>")
			return
		if (BOUNDS_DIST(user, src) > 0)
			boutput(user, "<span class='alert'>You need to move closer to [src] to do that.</span>")
			return
		if (BOUNDS_DIST(O, src) > 0 || BOUNDS_DIST(O, user) > 0)
			boutput(user, "<span class='alert'>[O] is too far away to load into [src]!</span>")
			return
		if (istype(O, /obj/item/reagent_containers/food/snacks/plant/) || istype(O, /obj/item/reagent_containers/food/snacks/mushroom/) || istype(O, /obj/item/seed/) || istype(O, /obj/item/plant/) || istype(O, /obj/item/clothing/head/flower/))
			user.visible_message("<span class='notice'>[user] begins quickly stuffing [O] into [src]!</span>")
			var/itemtype = O.type
			var/staystill = user.loc
			for(var/obj/item/P in view(1,user))
				if (src.reagents.total_volume >= src.reagents.maximum_volume)
					boutput(user, "<span class='alert'>[src] is full!</span>")
					break
				if (user.loc != staystill) break
				if (P.type != itemtype) continue
				var/amount = 20
				if (istype(P,/obj/item/reagent_containers/food/snacks/mushroom/))
					amount = 25
				else if (istype(P,/obj/item/seed/))
					amount = 2
				else if (istype(P,/obj/item/plant/))
					amount = 15
				playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 30, 1)
				src.reagents.add_reagent("poo", amount)
				qdel( P )
				sleep(0.3 SECONDS)
			boutput(user, "<span class='notice'>You finish stuffing [O] into [src]!</span>")
		else ..()

/obj/reagent_dispensers/still
	name = "still"
	desc = "A piece of equipment for brewing alcoholic beverages."
	icon = 'icons/obj/objects.dmi'
	icon_state = "still"
	amount_per_transfer_from_this = 25
	event_handler_flags = NO_MOUSEDROP_QOL

	// returns whether the inserted item was brewed
	proc/brew(var/obj/item/W as obj)
		if (!istype(W))
			return FALSE
		var/list/brew_result = W.brew_result
		var/list/brew_amount = 20 // how much brew could a brewstill brew if a brewstill still brewed brew?

		if(istype(W, /obj/item/reagent_containers/food/snacks/plant))
			var/obj/item/reagent_containers/food/snacks/plant/P = W
			var/datum/plantgenes/DNA = P.plantgenes
			brew_amount = max(DNA?.get_effective_value("potency"), 5) //always produce SOMETHING

		if (!brew_result)
			return FALSE

		if (islist(brew_result))
			for(var/I in brew_result)
				var/result = I
				var/amount = brew_result[I]
				if (!amount)
					amount = brew_amount
				src.reagents.add_reagent(result, amount)
		else
			src.reagents.add_reagent(brew_result, brew_amount)

		src.visible_message("<span class='notice'>[src] brews up [W]!</span>")
		return TRUE

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/reagent_containers/food) || istype(W, /obj/item/plant))
			var/load = 0
			if (src.brew(W))
				load = 1
			else
				load = 0

			if (load)
				user.u_equip(W)
				W.dropped(user)
				qdel(W)
				return
			else  ..()
		else ..()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!isliving(user))
			user.show_text("It's probably a bit too late for you to drink your problems away.", "red")
			return
		if (BOUNDS_DIST(user, src) > 0)
			user.show_text("You need to move closer to [src] to do that.", "red")
			return
		if (BOUNDS_DIST(O, src) > 0 || BOUNDS_DIST(O, user) > 0)
			user.show_text("[O] is too far away to load into [src]!", "red")
			return

		if (istype(O, /obj/storage/crate/))
			user.visible_message("<span class='notice'>[user] loads [O]'s contents into [src]!</span>",\
			"<span class='notice'>You load [O]'s contents into [src]!</span>")
			var/amtload = 0
			for (var/obj/item/P in O.contents)
				if (src.reagents.is_full())
					user.show_text("[src] is full!", "red")
					break
				if (src.brew(P))
					amtload++
					qdel(P)
				else
					continue
			if (amtload)
				user.show_text("[amtload] items loaded from [O]!", "blue")
			else
				user.show_text("Nothing was loaded!", "red")
		else if (istype(O, /obj/item/reagent_containers/food) || istype(O, /obj/item/plant))
			user.visible_message("<span class='notice'><b>[user]</b> begins quickly stuffing items into [src]!</span>",\
			"<span class='notice'>You begin quickly stuffing items into [src]!</span>")
			var/staystill = user.loc
			for (O in view(1,user))
				if (src.reagents.is_full())
					user.show_text("[src] is full!", "red")
					break
				if (user.loc != staystill)
					user.show_text("You were interrupted!", "red")
					break
				if (src.brew(O))
					qdel(O)
				else
					continue
			user.visible_message("<span class='notice'><b>[user]</b> finishes stuffing items into [src].</span>",\
			"<span class='notice'>You finish stuffing items into [src].</span>")
		else
			return ..()

/* ==================================================== */
/* --------------- Water Cooler Bottle ---------------- */
/* ==================================================== */

/obj/item/reagent_containers/food/drinks/coolerbottle
	name = "water cooler bottle"
	desc = "A water cooler bottle. Can hold up to 500 units."
	icon = 'icons/obj/chemical.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "itemtank"
	item_state = "flask"
	initial_volume = 500
	w_class = W_CLASS_BULKY
	incompatible_with_chem_dispensers = 1
	can_chug = 0

	var/image/fluid_image

	New()
		..()
		fluid_image = image(src.icon, "fluid-[src.icon_state]")

	on_reagent_change()
		..()
		src.UpdateIcon()

	update_icon()
		src.underlays = null
		if (reagents.total_volume)
			var/fluid_state = round(clamp((src.reagents.total_volume / src.reagents.maximum_volume * 5 + 1), 1, 5))
			src.icon_state = "itemtank[fluid_state]"
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.fluid_image.icon_state = "fluid-itemtank[fluid_state]"
			src.underlays += src.fluid_image
		else
			src.icon_state = initial(src.icon_state)
