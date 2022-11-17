// A blood slide, used by the centrifuge.
/obj/item/bloodslide
	name = "Blood Slide"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "slide0"
	desc = "An item used by scientists and serial killers operating in the Miami area to store blood samples."

	var/datum/reagent/blood/blood = null

	flags = TABLEPASS | CONDUCT | FPRINT | NOSPLASH

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
	name = "Petri Dish"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "petri0"
	desc = "A dish tailored hold pathogen cultures."
	initial_volume = 40
	var/stage = 0

	var/dirty = 0
	var/dirty_reason = ""
	var/datum/reagent/medium = null
	var/list/nutrition = list()

	var/ctime = 8
	var/starving = 5
	rc_flags = 0

	New()
		..()
		for (var/nutrient in pathogen_controller.nutrients)
			nutrition += nutrient
			nutrition[nutrient] = 0

	examine()
		if (src.dirty || src.dirty_reason)
			. = ..()
			. += "<span class='alert'>The petri dish appears to be incapable of growing any pathogen, and must be cleaned.</span><br/>"
			return

		. = list("This is [src]<br/>")
		if (src.reagents.reagent_list["pathogen"])
			var/datum/reagent/blood/pathogen/P = src.reagents.reagent_list["pathogen"]
			. += "<span class='notice'>It contains [P.volume] unit\s of harvestable pathogen.</span><br/>"
		if (src.medium)
			. += "<span class='notice'>The petri dish is coated with [src.medium.name].</span><br/>"
		. += "Nutrients in the dish:<br/>"
		var/count = 0
		for (var/N in nutrition)
			if (nutrition[N])
				. += "<span class='notice'>[nutrition[N]] unit\s of [N]</span><br/>"
				count++
		if (!count)
			. += "<span class='notice'>None.</span><br/>"

	afterattack(obj/target, mob/user , flag)
		if (istype(target, /obj/machinery/microscope))
			return
		var/amount = src.reagents.total_volume
		..(target, user, flag)
		if (amount && !src.reagents.total_volume)
			processing_items.Remove(src)
			for (var/N in nutrition)
				nutrition[N] = 0
			reagents.clear_reagents()
			if (src.medium)
				del src.medium
			src.medium = null
			ctime = 8
			starving = 5

	process()
		if (dirty && (src in processing_items))
			processing_items -= src
		ctime--
		if (!src.reagents || !src.reagents.reagent_list["pathogen"] )
			set_dirty("All viable pathogen has been harvested from the petri dish.")
		else
			var/datum/reagent/blood/pathogen/P = src.reagents.reagent_list["pathogen"]
			var/uid = P.pathogens[1]
			var/datum/pathogen/PT = P.pathogens[uid]
			if (medium && medium.id != PT.body_type.growth_medium)
				set_dirty("The pathogen is unable to cultivate on the growth medium.")
		if (ctime <= 0)
			ctime = 8
			var/datum/reagent/blood/pathogen/P = src.reagents.reagent_list["pathogen"]
			var/uid = P.pathogens[1]
			var/datum/pathogen/PT = P.pathogens[uid]
			// Integration notes etc. stablemutagen reagent ID
			var/starvation = 0
			for (var/N in PT.body_type.nutrients)
				if (src.nutrition[N] < PT.body_type.amount * P.volume)
					starvation = 1
					src.nutrition[N] = 0
				else
					starving = 5
					src.nutrition[N] -= PT.body_type.amount * P.volume
			if (starvation && starving > 0)
				starving--
			if (starving == 5)
				if (stage < 4)
					stage++
					update_dish_icon()
				else
					P.volume = min(P.volume + 5, 30)
					src.reagents.update_total()
			else if (starving == 0)
				if (stage > 1)
					stage--
					update_dish_icon()
				else
					P.volume = max(P.volume - 5, 0)
					if (P.volume == 0)
						src.reagents.del_reagent("pathogen")
					src.reagents.update_total()
					set_dirty("The pathogen in the petri dish starved to death.")

	on_reagent_change()
		..()
		if (reagents.total_volume < 0.5)
			return
		if (dirty)
			return

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
					if (P.pathogens.len > 1)
						// Too many pathogens. This culture is dead.
						set_dirty("The presence of multiple pathogens makes them unable to grow.")
				else if (R in pathogen_controller.media)
					if (R == medium?.id)
						if (RE.pathogen_nutrition)
							for (var/N in RE.pathogen_nutrition)
								if (N in nutrition)
									nutrition[N] += RE.volume / length(RE.pathogen_nutrition)
								else
									nutrition[N] = RE.volume / length(RE.pathogen_nutrition)
						src.reagents.reagent_list -= R
						src.reagents.update_total()
					else
						// Malnutrition, a medium that normally rejects the grown pathogen type has been introduced.
						set_dirty("A growth medium incompatible with the pathogen is killing the culture.")
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

	proc/update_dish_icon()
		if (stage == 0)
			if (src.reagents && src.reagents.total_volume > 0)
				icon_state = "petri1"
			else
				icon_state = "petri0"
		else
			icon_state = "petri[stage]"

	proc/set_dirty(var/reason)
		processing_items.Remove(src)
		dirty = 1
		stage = 0
		ctime = 8
		starving = 5
		dirty_reason = reason
		update_dish_icon()

	flags = TABLEPASS | CONDUCT | FPRINT | OPENCONTAINER


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
	name = "Totally Safe(tm) pathogen sample"
	desc = "A vial. Can hold up to 5 units."
	icon = 'icons/obj/pathology.dmi'
	icon_state = "vial0"
	item_state = "vial"
	var/datum/microbody/FM = null

	New()
		..()
		SPAWN(2 SECONDS)
			#ifdef CREATE_PATHOGENS // PATHOLOGY REMOVAL
			var/datum/pathogen/P = new /datum/pathogen
			if(FM)
				P.forced_microbody = FM
			P.create_weak()
			P.setup(1)
			var/datum/reagents/RE = src.reagents
			RE.add_reagent("pathogen", 5)
			var/datum/reagent/blood/pathogen/R = RE.get_reagent("pathogen")
			R.pathogens[P.pathogen_uid] = P
			#else
			var/datum/reagents/RE = src.reagents
			RE.add_reagent("water", 5)
			#endif

/obj/item/reagent_containers/glass/vial/prepared/virus
	FM = /datum/microbody/virus

/obj/item/reagent_containers/glass/vial/prepared/parasite
	FM = /datum/microbody/parasite

/obj/item/reagent_containers/glass/vial/prepared/bacterium
	FM = /datum/microbody/bacteria

/obj/item/reagent_containers/glass/vial/prepared/fungus
	FM = /datum/microbody/fungi

/obj/item/reagent_containers/glass/beaker/parasiticmedium
	name = "Beaker of Parasitic Medium"
	desc = "A mix of blood and flesh; fertile ground for some microbes."

	icon_state = "beaker"

	New()
		..()
		src.reagents.add_reagent("parasiticmedium", 50)

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

/obj/item/reagent_containers/glass/beaker/bacterial
	name = "Beaker of Bacterial Growth Medium"
	desc = "Bacterial Growth Medium; fertile ground for some microbes."

	icon_state = "beaker"

	New()
		..()
		src.reagents.add_reagent("bacterialmedium", 50)

/obj/item/reagent_containers/glass/beaker/fungal
	name = "Beaker of Fungal Growth Medium"
	desc = "Fungal Growth Medium; fertile ground for some microbes."

	icon_state = "beaker"

	New()
		..()
		src.reagents.add_reagent("fungalmedium", 50)

/obj/item/reagent_containers/glass/beaker/antiviral
	name = "Beaker of Antiviral Agent"
	desc = "A beaker of a weak anti-viral agent."

	icon_state = "beaker"

	New()
		..()
		src.reagents.add_reagent("antiviral", 50)

/obj/item/reagent_containers/glass/beaker/biocides
	name = "Beaker of Biocides"
	desc = "A beaker of biocides. The label says 'do not feed to worms or mushrooms'. Curious."

	icon_state = "beaker"

	New()
		..()
		src.reagents.add_reagent("biocide", 50)

/obj/item/reagent_containers/glass/beaker/spaceacillin
	name = "Beaker of Spaceacillin"
	desc = "It's penicillin in space."

	icon_state = "beaker"

	New()
		..()
		src.reagents.add_reagent("spaceacillin", 50)

/obj/item/reagent_containers/glass/beaker/inhibitor
	name = "Beaker of Inhibition Agent"
	desc = "It's green, that's for sure."

	icon_state = "beaker"

	New()
		..()
		src.reagents.add_reagent("inhibitor", 50)

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
				logTheThing(LOG_PATHOLOGY, user, "injects [constructTarget(target,"pathology")] with the cure for [src.pathogen.name].")
				target.remission(src.pathogen)
			else
				logTheThing(LOG_PATHOLOGY, user, "injects [constructTarget(target,"pathology")] with a vaccine for [src.pathogen.name].")
				target.immunity(src.pathogen)
		else
			if (target.infected(src.pathogen))
				logTheThing(LOG_PATHOLOGY, user, "injects [constructTarget(target,"pathology")] with pathogen [src.pathogen.name] from a bad cure injector and infects them.")
			else
				logTheThing(LOG_PATHOLOGY, user, "injects [constructTarget(target,"pathology")] with pathogen [src.pathogen.name] from a bad cure injector but they were unaffected.")
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

/obj/item/reagent_containers/glass/beaker
	afterattack(obj/target, mob/user , flag)
		if (istype(target, /obj/machinery/synthomatic))
			return
		..()
