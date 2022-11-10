
/* ================================================= */
/* -------------------- Beakers -------------------- */
/* ================================================= */

/obj/item/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. Can hold up to 50 units."
	icon = 'icons/obj/chemical.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	initial_volume = 50
	var/image/fluid_image
	var/icon_style = "beaker"
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	object_flags = NO_GHOSTCRITTER

	on_reagent_change()
		..()
		src.UpdateIcon()

	update_icon()
		src.underlays = null
		if (reagents.total_volume)
			var/fluid_state = round(clamp((src.reagents.total_volume / src.reagents.maximum_volume * 5 + 1), 1, 5))
			if (!src.fluid_image)
				src.fluid_image = image(src.icon, "fluid-[src.icon_style][fluid_state]", -1)
			else
				src.fluid_image.icon_state = "fluid-[src.icon_style][fluid_state]"
			src.icon_state = "[src.icon_style][fluid_state]"
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.underlays += src.fluid_image
		else
			src.icon_state = src.icon_style

		if (istype(src.master,/obj/item/assembly))
			var/obj/item/assembly/A = src.master
			A.c_state(1)
		signal_event("icon_updated")

	attackby(obj/A, mob/user)
		if (istype(A, /obj/item/assembly/time_ignite) && !(A:status))
			var/obj/item/assembly/time_ignite/W = A
			if (!W.part3)
				W.part3 = src
				src.master = W
				src.layer = initial(src.layer)
				user.u_equip(src)
				src.set_loc(W)
				W.c_state(0)

				boutput(user, "You attach [W.name] to [src].")
			else
				boutput(user, "You must remove [W.part3] from the assembly before transferring chemicals to it!")
			return

		if (istype(A, /obj/item/assembly/prox_ignite) && !(A:status))
			var/obj/item/assembly/prox_ignite/W = A
			if (!W.part3)
				W.part3 = src
				src.master = W
				src.layer = initial(src.layer)
				user.u_equip(src)
				src.set_loc(W)
				W.c_state(0)

				boutput(user, "You attach [W.name] to [src].")
			else boutput(user, "You must remove [W.part3] from the assembly before transferring chemicals to it!")
			return

		if (istype(A, /obj/item/assembly/rad_ignite) && !(A:status))
			var/obj/item/assembly/rad_ignite/W = A
			if (!W.part3)
				W.part3 = src
				src.master = W
				src.layer = initial(src.layer)
				user.u_equip(src)
				src.set_loc(W)
				W.c_state(0)

				boutput(user, "You attach [W.name] to [src].")
			else boutput(user, "You must remove [W.part3] from the assembly before transferring chemicals to it!")
			return

		..(A, user)

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/glass/beaker/cryoxadone
	name = "beaker (cryoxadone)"
	icon_state = "roundflask"
	icon_style = "roundflask"
	initial_reagents = list("cryoxadone"=40)

/obj/item/reagent_containers/glass/beaker/epinephrine
	name = "beaker (epinephrine)"
	initial_reagents = "epinephrine"

/obj/item/reagent_containers/glass/beaker/antitox
	name = "beaker (anti-toxin)"
	initial_reagents = "charcoal"

/obj/item/reagent_containers/glass/beaker/brute
	name = "beaker (styptic powder)"
	initial_reagents = "styptic_powder"

/obj/item/reagent_containers/glass/beaker/burn
	name = "beaker (silver sulfadiazine)"
	initial_reagents = "silver_sulfadiazine"

/* ======================================================= */
/* -------------------- Large Beakers -------------------- */
/* ======================================================= */

/obj/item/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 100 units."
	icon_state = "beakerlarge"
	initial_volume = 100
	icon_style = "beakerlarge"

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/glass/beaker/large/epinephrine
	name = "epinephrine reserve tank"
	initial_reagents = "epinephrine"

/obj/item/reagent_containers/glass/beaker/large/antitox
	name = "anti-toxin reserve tank"
	initial_reagents = "charcoal"

/obj/item/reagent_containers/glass/beaker/large/brute
	name = "styptic powder reserve tank"
	initial_reagents = "styptic_powder"

/obj/item/reagent_containers/glass/beaker/large/burn
	name = "silver sulfadiazine reserve tank"
	initial_reagents = "silver_sulfadiazine"

/obj/item/reagent_containers/food/drinks/reserve
	name = "reserve tank"
	desc = "A specialized reserve tank."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "largebottle"
	w_class = W_CLASS_NORMAL
	initial_volume = 400
	amount_per_transfer_from_this = 25
	incompatible_with_chem_dispensers = 1
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	rc_flags = RC_SCALE

/obj/item/reagent_containers/food/drinks/reserve/brute
	name = "high capacity styptic powder reserve tank"
	desc = "A high capacitiy reserve tank filled with styptic powder."
	icon_state = "largebottle-brute"
	initial_reagents = "styptic_powder"

/obj/item/reagent_containers/food/drinks/reserve/burn
	name = "high capacity silver sulfadiazine reserve tank"
	desc = "A high capacity reserve tank filled with silver sulfadiazine."
	icon_state = "largebottle-burn"
	initial_reagents = "silver_sulfadiazine"

/*  Now found in hydroponics.dm!

/obj/item/reagent_containers/glass/beaker/large/happy_plant //I have to test too many fucking plant-related issues atm so I'm adding this just to make my life less annoying
	name = "Happy Plant Mixture"
	desc = "160 units of things that make plants grow happy!"
	amount_per_transfer_from_this = 50
	initial_volume = 250
	initial_reagents = list("saltpetre"=50, "ammonia"=50, "potash"=50, "poo"=50, "space_fungus"=50) */

/* ================================================================= */
/* -------------------- Reagent Extractor Tanks -------------------- */
/* ================================================================= */

/obj/item/reagent_containers/glass/beaker/extractor_tank
	name = "reagent extractor tank"
	desc = "A large tank used in the reagent extractors. You probably shouldn't be able to see this!"
	initial_volume = 500

/* ================================================= */
/* -------------------- Flasks -------------------- */
/* ================================================= */

/obj/item/reagent_containers/glass/flask
	name = "flask"
	desc = "Looks pretty fragile, better not drop this."
	icon = 'icons/obj/chemical.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "eflask"
	item_state = "flask"
	var/icon_style = "eflask"
	rc_flags = RC_SPECTRO | RC_FULLNESS | RC_VISIBLE
	initial_volume = 15
	var/smashed = 0
	var/shard_amt = 1
	var/image/fluid_image

	on_reagent_change()
		..()
		src.UpdateIcon()

	update_icon() //updates icon based on fluids inside
		src.underlays = null
		if (src.reagents && src.reagents.total_volume)
			var/fluid_state = round(clamp((src.reagents.total_volume / src.reagents.maximum_volume * 5 + 1), 1, 5))
			var/datum/color/average = reagents.get_average_color()
			var/average_rgb = average.to_rgba()
			src.icon_state = "[src.icon_style][fluid_state]"
			if (!src.fluid_image)
				src.fluid_image = image('icons/obj/chemical.dmi', "fluid-[icon_style][fluid_state]", -1)
			else
				src.fluid_image.icon_state = "fluid-[src.icon_style][fluid_state]"
			src.fluid_image.color = average_rgb
			src.underlays += fluid_image
		else
			src.icon_state = src.icon_style

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		..()
		src.smash(T)

/obj/item/reagent_containers/glass/flask/round
	name = "round flask"
	icon_state = "roundflask"
	icon_style = "roundflask"

/obj/item/reagent_containers/glass/flask/black_powder //prefab shit
	initial_reagents = "blackpowder"

/obj/item/reagent_containers/glass/flask/heartbottle //goes in Jan's admin office
	name = "The Secret Ingredient"
	desc = "You feel strangely warm and relaxed just looking at it."
	icon = 'icons/misc/janstuff.dmi'
	icon_state = "heartbottle"
	icon_style = "heartbottle"
	initial_volume = 50
	initial_reagents = "love"

	update_icon() //updates icon based on fluids inside
		src.underlays = null
		if (src.reagents && src.reagents.total_volume)
			var/fluid_state = round(clamp((src.reagents.total_volume / src.reagents.maximum_volume * 5 + 1), 1, 5))
			var/datum/color/average = reagents.get_average_color()
			var/average_rgb = average.to_rgba()
			src.icon_state = "[src.icon_style][fluid_state]"
			if (!src.fluid_image)
				src.fluid_image = image('icons/misc/janstuff.dmi', "fluid-[icon_style][fluid_state]", -1)
			else
				src.fluid_image.icon_state = "fluid-[src.icon_style][fluid_state]"
			src.fluid_image.color = average_rgb
			src.underlays += fluid_image
		else
			src.icon_state = src.icon_style
