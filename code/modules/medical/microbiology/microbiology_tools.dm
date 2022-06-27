// A blood slide, used by the centrifuge.
/obj/item/bloodslide
	name = "Blood Slide"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "slide0"
	desc = "An item used by scientists and serial killers operating in the Miami area to store blood samples."

	var/datum/reagent/blood/blood = null

	flags = TABLEPASS | CONDUCT | FPRINT | NOSPLASH | OPENCONTAINER

	New()
		..()
		var/datum/reagents/R = new /datum/reagents(5)
		src.reagents = R

	attackby(obj/item/I, mob/user)
		return

	on_reagent_change()
		..()
		reagents.maximum_volume = reagents.total_volume // This should make the blood slide... permanent.
		if (reagents.has_reagent("blood") || reagents.has_reagent("bloodc"))
			icon_state = "slide1"
			desc = "The blood slide contains a drop of blood."
			if (reagents.has_reagent("blood"))
				blood = reagents.get_reagent("blood")
			else if (reagents.has_reagent("bloodc"))
				blood = reagents.get_reagent("bloodc")
			if (blood == null)
				boutput(usr, "<span class='alert'>Blood slides are not working. This is an error message, please page 1-800-555-MARQUESAS.</span>")
				return
		else
			desc = "This blood slide is contaminated and useless."

/obj/item/reagent_containers/glass/petridish
	name = "petri dish"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "petri0"
	desc = "A dish tailored hold microbial cultures."
	initial_volume = 40

	examine()
		. = list("This is a [src].<br/>")
		if (src.reagents.reagent_list["pathogen"])
			var/datum/reagent/blood/pathogen/P = src.reagents.reagent_list["pathogen"]
			. += "<span class='notice'>It contains [P.volume] unit\s of microbial fluid.</span><br/>"

	afterattack(obj/target, mob/user, flag)
		if (istype(target, /obj/machinery/microscope) || istype(target, /obj/machinery/incubator))
			return
		var/amount = src.reagents.total_volume
		..(target, user, flag)
		if (amount && !src.reagents.total_volume)
			processing_items.Remove(src)
			reagents.clear_reagents()

	on_reagent_change()
		..()
		if (reagents.total_volume < 0.5)
			return
/*
		// Cultivation is already in progress in this dish. Depending on what reagent(s) were introduced, the process
		// halts, or reverses entirely.
		if (stage > 0)
			// At this stage, only the pathogen should be in the reagents list.
			for (var/R in src.reagents.reagent_list)
				var/datum/reagent/RE = src.reagents.reagent_list[R]
				// Sanity check the pathogen. Only a single type of pathogen can be cultivated in a petri dish.
				// Multiple types of reagents will immediately make the dish dirty.
				if (R == "pathogen")
					var/datum/reagent/blood/pathogen/P = src.reagents.reagent_list["pathogen"]
					if (P.microbes.len > 1)
						// Too many pathogens. This culture is dead.
						set_dirty("The presence of multiple pathogens makes them unable to grow.")
				else if (R == "egg")
					if (RE.pathogen_nutrition)
						for (var/N in RE.pathogen_nutrition)
							if (N in nutrition)
								nutrition[N] += RE.volume / length(RE.pathogen_nutrition)
							else
								nutrition[N] = RE.volume / length(RE.pathogen_nutrition)
					src.reagents.reagent_list -= R
					src.reagents.update_total()
				else if (RE.pathogen_nutrition)
					for (var/N in RE.pathogen_nutrition)
						if (N in nutrition)
							nutrition[N] += RE.volume / length(RE.pathogen_nutrition)
						else
							nutrition[N] = RE.volume / length(RE.pathogen_nutrition)
					src.reagents.reagent_list -= R
					src.reagents.update_total()
				else
					// Foreign chemical, murdering the culture.
					set_dirty("The pathogen culture is unable to cultivate in the environment due to foreign chemicals.")
		else
			if (src.reagents.reagent_list.len == 1 && src.reagents.reagent_list[1] == "pathogen")
				return
			for (var/R in src.reagents.reagent_list)
				var/datum/reagent/RE = src.reagents.reagent_list[R]
				if (R == "pathogen")
					if (src.medium)
						processing_items |= src
				else if (R in pathogen_controller.media)
					if (src.medium && src.medium.id != R)
						set_dirty("There are multiple, incompatible growth media in the petri dish.")
					else if (!src.medium)
						src.medium = src.reagents.reagent_list[R]
						if (RE.pathogen_nutrition)
							for (var/N in RE.pathogen_nutrition)
								if (N in nutrition)
									nutrition[N] += RE.volume / length(RE.pathogen_nutrition)
								else
									nutrition[N] = RE.volume / length(RE.pathogen_nutrition)
						src.reagents.reagent_list -= R
						src.reagents.update_total()
						if (src.reagents.has_reagent("pathogen"))
							processing_items |= src
					else
						if (RE.pathogen_nutrition)
							for (var/N in RE.pathogen_nutrition)
								if (N in nutrition)
									nutrition[N] += RE.volume / length(RE.pathogen_nutrition)
								else
									nutrition[N] = RE.volume / length(RE.pathogen_nutrition)
						src.reagents.reagent_list -= R
						src.reagents.update_total()
				else if (RE.pathogen_nutrition)
					for (var/N in RE.pathogen_nutrition)
						if (N in nutrition)
							nutrition[N] += RE.volume / length(RE.pathogen_nutrition)
						else
							nutrition[N] = RE.volume / length(RE.pathogen_nutrition)
					src.reagents.reagent_list -= R
					src.reagents.update_total()
				else
					set_dirty("Foreign chemicals in the petri dish.")
*/
/*	proc/update_dish_icon()
		if (stage == 0)
			if (src.reagents && src.reagents.total_volume > 0)
				icon_state = "petri1"
			else
				icon_state = "petri0"
		else
			icon_state = "petri[stage]"*/
/*
	proc/set_dirty(var/reason)
		processing_items.Remove(src)
		dirty = 1
		stage = 0
		dirty_reason = reason
		update_dish_icon()
*/

/obj/item/reagent_containers/glass/vial
	name = "vial"
	desc = "A vial. Can hold up to 5 units."
	icon = 'icons/obj/pathology.dmi'
	icon_state = "vial0"
	item_state = "vial"
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO

	on_reagent_change()
		..()
		if (reagents.total_volume < 0.05)
			icon_state = "vial0"
		else
			icon_state = "vial1"

	New()
		var/datum/reagents/R = new /datum/reagents(5)
		R.my_atom = src
		src.reagents = R
		..()

/obj/item/reagent_containers/glass/vial/plastic
	name = "plastic vial"
	desc = "A 3D-printed vial. Can hold up to 5 units. Barely."
	can_recycle = FALSE

	New()
		. = ..()
		AddComponent(/datum/component/biodegradable)

/obj/item/reagent_containers/glass/vial/prepared
	name = "Totally Safe(tm) microbe sample"
	desc = "A vial. Can hold up to 5 units."
	icon = 'icons/obj/pathology.dmi'
	icon_state = "vial0"
	item_state = "vial"

	New()
		..()
		SPAWN(2 SECONDS)
			#ifdef CREATE_PATHOGENS // PATHOLOGY REMOVAL
			var/datum/microbe/P = new /datum/microbe
			P.randomize()
			var/datum/reagents/RE = src.reagents
			RE.add_reagent("pathogen", 5)
			var/datum/reagent/blood/pathogen/R = RE.get_reagent("pathogen")
			R.microbes[P.name] = P
			#else
			var/datum/reagents/RE = src.reagents
			RE.add_reagent("water", 5)
			#endif

/obj/item/reagent_containers/glass/beaker/egg
	name = "Beaker of Eggs"
	desc = "Eggs; fertile ground for some microbes."

	icon_state = "beaker"

	New()
		..()
		src.reagents.add_reagent("egg", 50)

/obj/item/reagent_containers/glass/beaker/stablemut
	name = "Beaker of Stable Mutagen"
	desc = "Stable Mutagen; fertile ground for some microbes."

	icon_state = "beaker"

	New()
		..()
		src.reagents.add_reagent("dna_mutagen", 50)

/obj/item/reagent_containers/glass/beaker/spaceacillin
	name = "Beaker of Spaceacillin"
	desc = "It's penicillin in space."

	icon_state = "beaker"

	New()
		..()
		src.reagents.add_reagent("spaceacillin", 50)

/obj/item/reagent_containers/glass/beaker
	afterattack(obj/target, mob/user , flag)
		if (istype(target, /obj/machinery/synthomatic))
			return
		..()

/*
/obj/item/serum_injector
	name = "Pathological Injector"
	desc = "A specialized injector for injecting patients with serums and vaccines."
	icon = 'icons/obj/pathology.dmi'
	icon_state = "serum"
	var/datum/pathogen/pathogen = null
	var/used = 1
	var/is_cure = 0
	var/is_vaccine = 0

	New(Location, var/datum/pathogen/P, cure, vaccine)
		if (P && istype(P))
			src.name = "[src.name] (strain [P.name_base])"
			icon_state = "serum"
			src.pathogen = P
			src.is_cure = cure
			src.is_vaccine = vaccine
			used = 0
		else
			src.name = "empty [src.name]"
			icon_state = "serum0"
			used = 1
		..()

	attack_self()
		return

	proc/inject(var/mob/living/carbon/human/target, var/mob/user)
		if (is_cure)
			if (!is_vaccine)
				logTheThing("pathology", user, target, "injects [constructTarget(target,"pathology")] with the cure for [src.pathogen.name].")
				target.remission(src.pathogen)
			else
				logTheThing("pathology", user, target, "injects [constructTarget(target,"pathology")] with a vaccine for [src.pathogen.name].")
				target.immunity(src.pathogen)
		else
			if (target.infected(src.pathogen))
				logTheThing("pathology", user, target, "injects [constructTarget(target,"pathology")] with pathogen [src.pathogen.name] from a bad cure injector and infects them.")
			else
				logTheThing("pathology", user, target, "injects [constructTarget(target,"pathology")] with pathogen [src.pathogen.name] from a bad cure injector but they were unaffected.")
		src.pathogen = null
		used = 1

	attack(mob/M, mob/user, def_zone)
		if (used)
			boutput(user, "<span class='alert'>The [src.name] is empty.</span>")
			return
		if (ishuman(M))
			if (M != user)
				for (var/mob/V in viewers(M))
					boutput(V, "<span class='alert'><b>[user] is trying to inject [M] with the [src.name]!</b></span>")
				var/ML = M.loc
				var/UL = user.loc
				SPAWN(3 SECONDS)
					if (used)
						return
					if (user.equipped() == src && M.loc == ML && user.loc == UL)
						used = 1
						for (var/mob/V in viewers(M))
							boutput(V, "<span class='alert'><b>[user] is injects [M] with the [src.name]!</b></span>")
						src.name = "empty [src.name]"
						icon_state = "serum0"
						inject(M, user)
			else
				used = 1
				for (var/mob/V in viewers(M))
					boutput(V, "<span class='alert'><b>[user] injects [M] with the [src.name]!</b></span>")
				icon_state = "serum0"
				src.name = "empty [src.name]"
				inject(user, user)
*/
