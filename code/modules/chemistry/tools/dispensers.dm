
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
	var/rc_flags = RC_SCALE | RC_SPECTRO
	flags = FLUID_SUBMERGE | ACCEPTS_MOUSEDROP_REAGENTS
	object_flags = NO_GHOSTCRITTER
	pressure_resistance = 2*ONE_ATMOSPHERE
	p_class = 1.5

	var/amount_per_transfer_from_this = 10
	var/capacity = 4000

	New()
		..()
		// TODO enable when I do leaking
		// src.AddComponent(/datum/component/bullet_holes, 10, 5)
		src.create_reagents(src.capacity)


	get_desc(dist, mob/user)
		if (dist <= 2 && reagents)
			. += "<br>[SPAN_NOTICE("[reagents.get_description(user,src.rc_flags)]")]"

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

	blob_act(var/power)
		if (prob(25))
			smash()

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume, cannot_be_cooled = FALSE)
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
			boutput(usr, SPAN_ALERT("That's too far!"))
			return

		src.transfer_all_reagents(over_object, usr)

	is_open_container(input)
		if (input)
			return TRUE
		return ..()

	proc/bolt_unbolt(mob/user)
		if(!src.anchored)
			var/turf/T = get_turf(src)
			if (istype(T, /turf/space))
				boutput(user, SPAN_ALERT("What exactly are you gonna secure [src] to?"))
				return
			user.visible_message("<b>[user]</b> secures [src] to the floor!")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			src.anchored = ANCHORED
		else
			user.visible_message("<b>[user]</b> unbolts [src] from the floor!")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			src.anchored = UNANCHORED

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */
/obj/reagent_dispensers/cleanable
	flags = FLUID_SUBMERGE

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
		START_TRACKING_CAT(TR_CAT_BUGS)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_BUGS)
		..()

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
		START_TRACKING_CAT(TR_CAT_BUGS)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_BUGS)
		..()

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
				user.visible_message("<b>[user]</b> secures [src] to the floor!")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				src.anchored = ANCHORED
			else
				user.visible_message("<b>[user]</b> unbolts [src] from the floor!")
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
	rc_flags = RC_SPECTRO | RC_FULLNESS | RC_VISIBLE
	capacity = 500
	_health = 250
	_max_health = 250

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
			. += "<br>[SPAN_NOTICE("[reagents.get_description(user, src.rc_flags)]")]"

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
			var/turf/T = get_turf(src)
			if (!src.anchored && istype(T, /turf/space))
				user.show_text("What exactly are you gunna secure [src] to?", "red")
				return
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			user.show_text("You begin to [src.anchored ? "unscrew" : "secure"] [src].", "blue")
			SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, PROC_REF(toggle_bolts), list(user, T), W.icon, W.icon_state, null, INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
			return
		..()

	proc/toggle_bolts(mob/user, turf/T)
		user.show_text("You [src.anchored ? "unscrew" : "secure"] [src] [src.anchored ? "from" : "to"] [T].", "blue")
		src.anchored = !src.anchored

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

	bullet_act(obj/projectile/P)
		src.changeHealth(-P.power * P.proj_data.ks_ratio)

	onDestroy()
		src.smash()

	drugged
		New()
			..()
			src.create_reagents(4000)
			reagents.add_reagent("LSD",400)
			reagents.add_reagent("water",600)
			src.UpdateIcon()
		name = "discolored water fountain"
		desc = "It's called a fountain, but it's not very decorative or interesting. You can get a drink from it, though seeing the color you feel you shouldn't"
		color = "#ffffcc"

	juicer
		New()
			..()
			src.create_reagents(4000)
			reagents.add_reagent(pick("CBD","THC","refried_beans","coffee","methamphetamine"),100)
			reagents.add_reagent(pick("CBD","THC","refried_beans","coffee","methamphetamine"),100)
			reagents.add_reagent(pick("CBD","THC","refried_beans","coffee","methamphetamine"),100)
			reagents.add_reagent(pick("CBD","THC","refried_beans","coffee","methamphetamine"),100)
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
		user.visible_message(SPAN_ALERT("<b>[user] drinks deeply from [src]. [capitalize(he_or_she(user))] then pulls out a match from somewhere, strikes it and swallows it!</b>"))
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
	desc = "For storing medical chemicals and less savory things."
	icon = 'icons/obj/chemical_barrel.dmi'
	icon_state = "barrel-blue"
	amount_per_transfer_from_this = 25
	p_class = 3
	rc_flags = RC_SCALE | RC_SPECTRO | RC_VISIBLE
	flags = FLUID_SUBMERGE | OPENCONTAINER | ACCEPTS_MOUSEDROP_REAGENTS
	HELP_MESSAGE_OVERRIDE({"\
		Click the barrel with an <b>empty hand</b> to flip the barrel's funnel into a spout or vice versa. \
		Use a <b>reagent container</b> to add/remove reagents from the barrel, depending on the funnel/spout. \
		Use a <b>pen</b> to add a label to the barrel. \
		Use a <b>wrench</b> to open or close the barrel's lid. \
		Click and drag the barrel to a <b>CheMaster 3000</b> to allow the CheMaster to draw from the barrel's contents.\
	"})
	var/base_icon_state = "barrel-blue"
	var/funnel_active = TRUE //if TRUE, allows players pouring liquids from beakers with just one click instead of clickdrag, for convenience
	var/image/lid_image = null
	var/image/spout_image = null
	var/obj/machinery/chem_master/linked_machine = null

	New()
		. = ..()

		src.AddComponent( \
			/datum/component/reagent_overlay, \
			reagent_overlay_icon = 'icons/obj/chemical_barrel.dmi', \
			reagent_overlay_icon_state = "barrel", \
			reagent_overlay_states = 9, \
			reagent_overlay_scaling = RC_REAGENT_OVERLAY_SCALING_LINEAR, \
		)
		src.UpdateIcon()

	update_icon()
		if (!src.lid_image)
			src.lid_image = image(src.icon)
			src.lid_image.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
		if(!src.is_open_container())
			src.lid_image.icon_state = "[base_icon_state]-lid"
			src.UpdateOverlays(src.lid_image, "lid")
		else
			src.lid_image.layer = FLOAT_LAYER
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
			return

		if (istype(W, /obj/item/reagent_containers/synthflesh_pustule))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, SPAN_ALERT("[src] is full."))
				return

			boutput(user, SPAN_NOTICE("You squeeze the [W] into [src]. Gross."))
			playsound(src.loc, pick('sound/effects/splort.ogg'), 100, 1)

			W.reagents.trans_to(src, W.reagents.total_volume)
			user.u_equip(W)
			qdel(W)
			return

		if (src.is_open_container() &&\
			istypes(W, list(/obj/item/sheet, /obj/item/material_piece)) &&\
			(W.material?.isSameMaterial(getMaterial("wood")) || W.material?.isSameMaterial(getMaterial("bamboo")))
		)
			if (W.amount < 5)
				boutput(user, SPAN_ALERT("You need at least 5 pieces to fill the barrel."))
				return
			W.change_stack_amount(-5)
			var/obj/burning_barrel/woodbarrel = new /obj/burning_barrel{on = FALSE}(src.loc)
			woodbarrel.anchored = src.anchored
			boutput(user, SPAN_NOTICE("The barrel follows narrative causality and instantly becomes shabbier as you shove the wood into it."))
			qdel(src)
			return
		if (istool(W, TOOL_WRENCHING))
			if(src.flags & OPENCONTAINER)
				user.visible_message("<b>[user]</b> wrenches [src]'s lid closed!")
			else
				user.visible_message("<b>[user]</b> wrenches [src]'s lid open!")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			src.set_open_container(!src.is_open_container())
			UpdateIcon()
			return

		. = ..()

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
			boutput(user, SPAN_NOTICE("You flip the funnel into spout mode on the [src.name]."))
		else
			funnel_active = TRUE
			boutput(user, SPAN_NOTICE("You flip the spout into funnel mode on the [src.name]."))
		UpdateIcon()
		..()

	on_reagent_change()
		..()
		src.UpdateIcon()

	is_open_container(input)
		if (src.funnel_active && input) //Can pour stuff down the funnel even if the lid is closed
			return TRUE
		. = ..()

	shatter_chemically(var/projectiles = FALSE) //needs sound probably definitely for sure
		for(var/mob/M in AIviewers(src))
			boutput(M, SPAN_ALERT("The <B>[src.name]</B> breaks open!"))
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
		. = "<br>[SPAN_NOTICE("[reagents.get_description(user,RC_FULLNESS)]")]"
		return

	attackby(obj/item/W, mob/user)
		if(istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			bolt_unbolt(user)
			return
		var/load = 1
		if (istype(W,/obj/item/reagent_containers/food/snacks/plant/)) src.reagents.add_reagent("poo", 20)
		else if (istype(W,/obj/item/reagent_containers/food/snacks/mushroom/)) src.reagents.add_reagent("poo", 25)
		else if (istype(W,/obj/item/seed/)) src.reagents.add_reagent("poo", 2)
		else if (istype(W,/obj/item/plant/) \
				|| istype(W,/obj/item/clothing/head/flower/) \
				|| istype(W,/obj/item/reagent_containers/food/snacks/ingredient/rice_sprig)) src.reagents.add_reagent("poo", 15)
		else if (istype(W,/obj/item/organ/)) src.reagents.add_reagent("poo", 35)
		else load = 0

		if(load)
			boutput(user, SPAN_NOTICE("[src] mulches up [W]."))
			playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 30, 1)
			user.u_equip(W)
			W.dropped(user)
			qdel( W )
			return
		else ..()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!isliving(user))
			boutput(user, SPAN_ALERT("Excuse me you are dead, get your gross dead hands off that!"))
			return
		if (BOUNDS_DIST(user, src) > 0)
			// You have to be adjacent to the compost bin
			boutput(user, SPAN_ALERT("You need to move closer to [src] to do that."))
			return
		if (BOUNDS_DIST(O, user) > 0)
			// You have to be adjacent to the seeds also
			boutput(user, SPAN_ALERT("[O] is too far away to load into [src]!"))
			return
		if (istype(O, /obj/item/reagent_containers/food/snacks/plant/) \
			|| istype(O, /obj/item/reagent_containers/food/snacks/mushroom/) \
			|| istype(O, /obj/item/seed/) || istype(O, /obj/item/plant/) \
			|| istype(O, /obj/item/clothing/head/flower/) \
			|| istype(O, /obj/item/reagent_containers/food/snacks/ingredient/rice_sprig))
			user.visible_message(SPAN_NOTICE("[user] begins quickly stuffing [O] into [src]!"))
			var/itemtype = O.type
			var/staystill = user.loc
			for(var/obj/item/P in view(1,user))
				if (src.reagents.total_volume >= src.reagents.maximum_volume)
					boutput(user, SPAN_ALERT("[src] is full!"))
					break
				if (user.loc != staystill) break
				if (P.type != itemtype || P.equipped_in_slot) continue
				var/amount = 20
				if (istype(P,/obj/item/reagent_containers/food/snacks/mushroom/))
					amount = 25
				else if (istype(P,/obj/item/seed/))
					amount = 2
				else if (istype(P,/obj/item/plant/) || istype(P,/obj/item/reagent_containers/food/snacks/ingredient/rice_sprig))
					amount = 15
				playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 30, 1)
				src.reagents.add_reagent("poo", amount)
				qdel( P )
				sleep(0.3 SECONDS)
			boutput(user, SPAN_NOTICE("You finish stuffing [O] into [src]!"))
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

		if (!brew_result)
			return FALSE

		if(istype(W, /obj/item/reagent_containers/food/snacks/plant))
			var/obj/item/reagent_containers/food/snacks/plant/P = W
			var/datum/plantgenes/DNA = P.plantgenes
			brew_amount = max(HYPfull_potency_calculation(DNA), 5) //always produce SOMETHING

		if (islist(brew_result))
			for(var/I in brew_result)
				var/result = I
				var/amount = brew_result[I]
				if (!amount)
					amount = brew_amount
				src.reagents.add_reagent(result, amount)
		else
			src.reagents.add_reagent(brew_result, brew_amount)

		src.visible_message(SPAN_NOTICE("[src] brews up [W]!"))
		return TRUE

	attackby(obj/item/W, mob/user)
		if(istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			bolt_unbolt(user)
			return

		var/isfull = src.reagents.is_full()
		if (W && W.brew_result && !isfull)
			var/load = 0
			if (src.brew(W))
				load = 1
			else
				load = 0

			if (load)
				user.u_equip(W)
				W.dropped(user)
				qdel(W)
				playsound(src.loc, 'sound/effects/bubbles_short.ogg', 30, 1)
				return
			else  ..()
		// create feedback for items which don't produce attack messages
		// but not for chemistry containers, because they have their own feedback
		if (W && (W.flags & (SUPPRESSATTACK | OPENCONTAINER)) == SUPPRESSATTACK)
			if (isfull)
				boutput(user, SPAN_ALERT("[src] is already full."))
			else
				boutput(user, SPAN_ALERT("Can't brew anything from [W]."))
		..()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!isliving(user))
			boutput(user, SPAN_ALERT("It's probably a bit too late for you to drink your problems away!"))
			return
		if (BOUNDS_DIST(user, src) > 0)
			// You have to be adjacent to the still
			boutput(user, SPAN_ALERT("You need to move closer to [src] to do that."))
			return
		if (BOUNDS_DIST(O, user) > 0)
			// You have to be adjacent to the brewables also
			boutput(user, SPAN_ALERT("[O] is too far away to load into [src]!"))
			return
		// loading from crate
		if (istype(O, /obj/storage/crate/))
			user.visible_message(SPAN_NOTICE("[user] charges [src] with [O]'s contents!"))
			var/amtload = 0
			for (var/obj/item/Produce in O.contents)
				if (src.reagents.is_full())
					boutput(user, SPAN_ALERT("[src] is full!"))
					break
				if (src.brew(Produce))
					amtload++
					qdel(Produce)
			if (amtload)
				boutput(user, SPAN_NOTICE("Charged [src] with [amtload] items from [O]!"))
				playsound(src.loc, 'sound/effects/bubbles_short.ogg', 40, 1)
			else
				boutput(user, SPAN_ALERT("Nothing was put into [src]!"))
		// loading from the ground
		else if (istype(O, /obj/item))
			var/obj/item/item = O
			if (!item.brew_result)
				return ..()
			// "charging" is for sure correct terminology, I'm an expert because I asked chatgpt AND read the first result on google. Mhm mhm.
			user.visible_message(SPAN_NOTICE("[user] begins quickly charging [src] with [O]!"))

			var/staystill = user.loc
			var/itemtype = O.type
			for(var/obj/item/Produce in view(1,user))
				if (src.reagents.total_volume >= src.reagents.maximum_volume)
					boutput(user, SPAN_ALERT("[src] is full!"))
					break
				if (user.loc != staystill) break
				if (Produce.type != itemtype) continue
				if (src.brew(Produce))
					qdel(Produce)
					playsound(src.loc, 'sound/effects/bubbles_short.ogg', 30, 1)
					sleep(0.3 SECONDS)
			boutput(user, SPAN_NOTICE("You finish charging [src] with [O]!"))

		else
			return ..()

/* ==================================================== */
/* --------------- Water Cooler Bottle ---------------- */
/* ==================================================== */

/obj/item/reagent_containers/food/drinks/coolerbottle
	name = "water cooler bottle"
	desc = "A water cooler bottle. Can hold up to 500 units."
	icon = 'icons/obj/items/chemistry_glassware.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "cooler_bottle"
	item_state = "flask"
	initial_volume = 500
	w_class = W_CLASS_BULKY
	incompatible_with_chem_dispensers = 1
	can_chug = 0

	New()
		. = ..()
		src.AddComponent( \
			/datum/component/reagent_overlay, \
			reagent_overlay_icon = src.icon, \
			reagent_overlay_icon_state = src.icon_state, \
			reagent_overlay_states = 15, \
			reagent_overlay_scaling = RC_REAGENT_OVERLAY_SCALING_LINEAR, \
		)
