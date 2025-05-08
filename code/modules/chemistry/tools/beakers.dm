
/* ================================================= */
/* -------------------- Beakers -------------------- */
/* ================================================= */

/obj/item/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. Can hold up to 50 units."
	icon = 'icons/obj/items/chemistry_glassware.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	initial_volume = 50
	accepts_lid = TRUE
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	item_function_flags = /obj/item/reagent_containers/glass::item_function_flags | ASSEMBLY_NEEDS_MESSAGING
	object_flags = NO_GHOSTCRITTER
	fluid_overlay_states = 7
	container_style = "beaker"

	New()
		..()
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, PROC_REF(assembly_setup))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_REMOVAL, PROC_REF(assembly_removal))

	disposing()
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_REMOVAL)
		..()


	/// ----------- Trigger/Applier/Target-Assembly-Related Procs -----------

	assembly_get_admin_log_message(var/mob/user, var/obj/item/assembly/parent_assembly)
		return " [log_reagents(src)]"


	proc/assembly_setup(var/manipulated_bomb, var/obj/item/assembly/parent_assembly, var/mob/user, var/is_build_in)
		//we need to displace the icon a bit more with beakers than with other items
		if (is_build_in && parent_assembly.target == src)
			parent_assembly.icon_base_offset = 4


	proc/assembly_removal(var/manipulated_bomb, var/obj/item/assembly/parent_assembly, var/mob/user)
		//we need to reset the base icon offset
		parent_assembly.icon_base_offset = 0

	/// ----------------------------------------------

	update_icon()
		. = ..()
		signal_event("icon_updated")


/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/glass/beaker/cryoxadone
	name = "beaker (cryoxadone)"
	icon_state = "round_flask"
	initial_reagents = list("cryoxadone" = 40)
	fluid_overlay_states = 8
	container_style = "round_flask"
	fluid_overlay_scaling = RC_REAGENT_OVERLAY_SCALING_SPHERICAL

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

/obj/item/reagent_containers/glass/beaker/egg
	name = "Beaker of Eggs"
	desc = "Eggs; fertile ground for some microbes."

	New()
		..()
		src.reagents.add_reagent("egg", 50)

/obj/item/reagent_containers/glass/beaker/stablemut
	name = "Beaker of Stable Mutagen"
	desc = "Stable Mutagen; fertile ground for some microbes."

	New()
		..()
		src.reagents.add_reagent("dna_mutagen", 50)

/* ======================================================= */
/* -------------------- Large Beakers -------------------- */
/* ======================================================= */

/obj/item/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 100 units."
	icon_state = "large_beaker"
	initial_volume = 100
	fluid_overlay_states = 9
	container_style = "large_beaker"

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/glass/beaker/large/round
	name = "round-bottom flask"
	desc = "A large round-bottom flask, for all your chemistry needs."
	icon_state = "large_flask"
	item_state = "large_flask"
	fluid_overlay_states = 11
	container_style = "large_flask"
	fluid_overlay_scaling = RC_REAGENT_OVERLAY_SCALING_SPHERICAL

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
	flags = TABLEPASS | OPENCONTAINER
	rc_flags = RC_SCALE

/obj/item/reagent_containers/food/drinks/reserve/brute
	name = "high capacity styptic powder reserve tank"
	desc = "A high capacity reserve tank filled with styptic powder."
	icon_state = "largebottle-brute"
	initial_reagents = "styptic_powder"

/obj/item/reagent_containers/food/drinks/reserve/burn
	name = "high capacity silver sulfadiazine reserve tank"
	desc = "A high capacity reserve tank filled with silver sulfadiazine."
	icon_state = "largebottle-burn"
	initial_reagents = "silver_sulfadiazine"

/obj/item/reagent_containers/glass/beaker/large/cyborg
	shatter_immune = TRUE

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
	shatter_immune = TRUE

/* ================================================= */
/* -------------------- Flasks -------------------- */
/* ================================================= */

/obj/item/reagent_containers/glass/flask
	name = "flask"
	desc = "Looks surprisingly robust."
	icon = 'icons/obj/items/chemistry_glassware.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "conical_flask"
	item_state = "flask"
	rc_flags = RC_SPECTRO | RC_FULLNESS | RC_VISIBLE
	initial_volume = 15
	accepts_lid = TRUE
	fluid_overlay_states = 8
	container_style = "conical_flask"
	var/smashed = 0
	var/shard_amt = 1

/obj/item/reagent_containers/glass/flask/round
	name = "round flask"
	icon_state = "round_flask"
	fluid_overlay_states = 8
	container_style = "round_flask"
	fluid_overlay_scaling = RC_REAGENT_OVERLAY_SCALING_SPHERICAL

/obj/item/reagent_containers/glass/flask/black_powder //prefab shit
	initial_reagents = "blackpowder"

/obj/item/reagent_containers/glass/flask/heartbottle //goes in Jan's admin office
	name = "The Secret Ingredient"
	desc = "You feel strangely warm and relaxed just looking at it."
	icon = 'icons/misc/janstuff.dmi'
	icon_state = "heartbottle"
	initial_volume = 50
	initial_reagents = "love"
	container_icon = 'icons/misc/janstuff.dmi'
	container_style = "heartbottle"
	fluid_overlay_states = 5
