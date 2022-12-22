TYPEINFO(/obj/submachine/seed_manipulator)
	mats = 10

/obj/submachine/seed_manipulator
	name = "PlantMaster Mk4"
	desc = "An advanced machine used for manipulating the genes of plant seeds. It also features an inbuilt seed extractor."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/objects.dmi'
	icon_state = "geneman-on"
	flags = NOSPLASH | TGUI_INTERACTIVE | FPRINT
	event_handler_flags = NO_MOUSEDROP_QOL
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	var/mode = "overview"
	var/list/seeds = list()
	var/seedoutput = FALSE
	var/sort = "name"
	var/sortAsc = FALSE
	var/obj/item/seed/splicing1 = null
	var/obj/item/seed/splicing2 = null
	var/list/extractables = list()
	var/obj/item/reagent_containers/glass/inserted = null

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	ui_static_data(mob/user)
		var/exlist = list()
		var/seedlist = list()
		var/geneout = null//tmp var for storing analysis results
		var/splice_chance = 100
		var/splice1_geneout
		var/splice2_geneout

		if (src.splicing1 && src.splicing2)
			splice_chance = src.SpliceChance(src.splicing1, src.splicing2)

		switch(src.mode)
			if("extractables")
				for(var/exItem in src.extractables)
					if (istype(exItem, /obj/item/seed))
						var/obj/item/seed/S = exItem
						geneout = QuickAnalysisRow(S, S.planttype, S.plantgenes)
					else if (istype(exItem, /obj/item/reagent_containers/food/snacks/plant))
						var/obj/item/reagent_containers/food/snacks/plant/S = exItem
						geneout = QuickAnalysisRow(S, S.planttype, S.plantgenes)
					exlist += list(geneout)

			if("seedlist")
				for (var/obj/item/seed/S in src.seeds)
					if((S == src.splicing1) || (S == src.splicing2)) continue;
					geneout = QuickAnalysisRow(S, S.planttype, S.plantgenes)
					geneout["damage"] = list(S.seeddamage, FALSE)
					geneout["splicing"] = list("splicing", (S == src.splicing1) || (S == src.splicing2))
					geneout["allow_infusion"]= list("allow_infusion", src.inserted?.reagents?.total_volume > 0)
					seedlist += list(geneout)

		var/list/thisContainerData = null

		if (src.inserted)
			var/obj/item/reagent_containers/glass/thisContainer = src.inserted
			if(thisContainer)
				var/datum/reagents/R = thisContainer.reagents
				thisContainerData = list(
					name = thisContainer.name,
					maxVolume = R.maximum_volume,
					totalVolume = R.total_volume,
					contents = list(),
					finalColor = "#000000"
				)

				var/list/contents = thisContainerData["contents"]
				if(istype(R) && R.reagent_list.len>0)
					thisContainerData["finalColor"] = R.get_average_rgb()
					// Reagent data
					for(var/reagent_id in R.reagent_list)
						var/datum/reagent/current_reagent = R.reagent_list[reagent_id]

						contents.Add(list(list(
							name = reagents_cache[reagent_id],
							id = reagent_id,
							colorR = current_reagent.fluid_r,
							colorG = current_reagent.fluid_g,
							colorB = current_reagent.fluid_b,
							volume = current_reagent.volume
						)))

		if(src.splicing1)
			splice1_geneout = QuickAnalysisRow(src.splicing1, src.splicing1.planttype, src.splicing1.plantgenes)
			splice1_geneout["damage"] = list(src.splicing1.seeddamage, FALSE)
			splice1_geneout["splicing"] = list("splicing", TRUE)
			splice1_geneout["allow_infusion"]= list("allow_infusion", src.inserted?.reagents?.total_volume > 0)
		if(src.splicing2)
			splice2_geneout = QuickAnalysisRow(src.splicing2, src.splicing2.planttype, src.splicing2.plantgenes)
			splice2_geneout["damage"] = list(src.splicing2.seeddamage, FALSE)
			splice2_geneout["splicing"] = list("splicing", TRUE)
			splice2_geneout["allow_infusion"]= list("allow_infusion", src.inserted?.reagents?.total_volume > 0)

		return list(
			"extractables" = exlist,
			"seeds" = seedlist,
			"category" = src.mode,
			"category_lengths" = list(length(src.extractables),length(src.seeds)),
			"inserted" =  src.inserted ? "[src.inserted.reagents.total_volume]/[src.inserted.reagents.maximum_volume] [src.inserted.name]" : "No reagent vessel",
			"inserted_container" = thisContainerData,
			"seedoutput" = src.seedoutput,
			"splice_chance" = splice_chance,
			"show_splicing" = src.splicing1 || src.splicing2,
			"splice_seeds" = list(splice1_geneout, splice2_geneout),
			"sortBy" = src.sort,
			"sortAsc" = src.sortAsc,
		)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Plantmaster")
			ui.open()

	ui_act(action, list/params, datum/tgui/ui)
		. = ..()
		if(.)
			return
		switch(action)
			if("change_tab")
				src.mode = params["tab"]
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
				update_static_data(ui.user, ui)

			if("ejectbeaker")
				var/obj/item/I = src.inserted
				if (!I)
					boutput(usr, "<span class='alert'>No receptacle found to eject.</span>")
				else
					if (I.cant_drop) // cyborg/item arms
						src.inserted = null
					else
						I.set_loc(src.loc) // causes Exited proc to be called
						usr.put_in_hand_or_eject(I) // try to eject it into the users hand, if we can
				update_static_data(ui.user, ui)

			if("insertbeaker")
				if (src.inserted)
					return
				var/obj/item/inserting = usr.equipped()
				if(istype(inserting, /obj/item/reagent_containers/glass/) || istype(inserting, /obj/item/reagent_containers/food/drinks/))
					if (isrobot(ui.user))
						boutput(ui.user, "This machine does not accept containers from robots!")
						return
					if(src.inserted)
						boutput(ui.user, "<span class='alert'>A container is already loaded into the machine.</span>")
						return
					src.inserted =  inserting
					ui.user.drop_item()
					inserting.set_loc(src)
					boutput(ui.user, "<span class='notice'>You add [inserted] to the machine!</span>")
					update_static_data(ui.user, ui)

			if("ejectseeds")
				for (var/obj/item/seed/S in src.seeds)
					src.seeds.Remove(S)
					S.set_loc(src.loc)
					usr.put_in_hand_or_eject(S) // try to eject it into the users hand, if we can
				update_static_data(ui.user, ui)

			if("ejectextractables")
				for (var/obj/item/I in src.extractables)
					src.extractables.Remove(I)
					I.set_loc(src.loc)
					usr.put_in_hand_or_eject(I) // try to eject it into the users hand, if we can
				update_static_data(ui.user, ui)

			if("eject")
				var/obj/item/I = locate(params["eject_ref"]) in src
				if (!istype(I))
					return
				if (istype(I,/obj/item/seed)) src.seeds.Remove(I)
				else src.extractables.Remove(I)
				if(I == src.splicing1)
					src.splicing1 = null
				if(I == src.splicing2)
					src.splicing2 = null
				I.set_loc(src.loc)
				ui.user.put_in_hand_or_eject(I) // try to eject it into the users hand, if we can
				update_static_data(ui.user, ui)


			if("sort")
				src.sort = params["sortBy"]
				src.sortAsc = text2num(params["asc"])
				update_static_data(ui.user, ui)

			if("analyze")
				var/obj/item/I = locate(params["analyze_ref"]) in src
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

				if (istype(I,/obj/item/seed/))
					var/obj/item/seed/S = I
					if (!istype(S.planttype,/datum/plant/) || !istype(S.plantgenes,/datum/plantgenes/))
						boutput(ui.user, "<span class='alert'>Genetic structure of seed corrupted. Cannot scan.</span>")
					else
						HYPgeneticanalysis(ui.user,S,S.planttype,S.plantgenes)

				else if (istype(I,/obj/item/reagent_containers/food/snacks/plant/))
					var/obj/item/reagent_containers/food/snacks/plant/P = I
					if (!istype(P.planttype,/datum/plant/) || !istype(P.plantgenes,/datum/plantgenes/))
						boutput(ui.user, "<span class='alert'>Genetic structure of item corrupted. Cannot scan.</span>")
					else
						HYPgeneticanalysis(ui.user,P,P.planttype,P.plantgenes)
				else
					boutput(ui.user, "<span class='alert'>Item cannot be scanned.</span>")

			if("outputmode")
				src.seedoutput = !src.seedoutput
				update_static_data(ui.user, ui)

			if("label")
				var/obj/item/I = locate(params["label_ref"]) in src
				var/newname = sanitize(strip_html(params["label_new"]))
				if(istype(I) && I.name != newname)
					phrase_log.log_phrase("seed", newname, TRUE)
					I.name = newname
				update_static_data(ui.user, ui)

			if("extract")
				var/obj/item/I = locate(params["extract_ref"]) in src
				if (istype(I,/obj/item/reagent_containers/food/snacks/plant/))
					var/obj/item/reagent_containers/food/snacks/plant/P = I
					var/datum/plant/stored = P.planttype
					var/datum/plantgenes/DNA = P.plantgenes
					var/give = rand(2,5)

					if (!stored || !DNA)
						give = 0
					else if (HYPCheckCommut(DNA,/datum/plant_gene_strain/seedless))
						give = 0
					else if(stored.no_extract)
						give = 0

					if (!give)
						boutput(ui.user, "<span class='alert'>No viable seeds found in [I].</span>")
					else
						boutput(ui.user, "<span class='notice'>Extracted [give] seeds from [I].</span>")
						while (give > 0)
							var/obj/item/seed/S
							if (stored.unique_seed) S = new stored.unique_seed(src)
							else S = new /obj/item/seed(src,0)
							var/datum/plantgenes/SDNA = S.plantgenes
							if (!stored.unique_seed && !stored.hybrid)
								S.generic_seed_setup(stored)
							HYPpassplantgenes(DNA,SDNA)

							S.name = stored.name
							S.plant_seed_color(stored.seedcolor)
							if (stored.hybrid)
								var/hybrid_type = stored.type
								var/datum/plant/hybrid = new hybrid_type(S)
								for(var/V in stored.vars)
									if (issaved(stored.vars[V]) && V != "holder")
										hybrid.vars[V] = stored.vars[V]
								S.planttype = hybrid
								S.name = hybrid.name

							var/seedname = S.name
							if (DNA.mutation && istype(DNA.mutation,/datum/plantmutation/))
								var/datum/plantmutation/MUT = DNA.mutation
								if (!MUT.name_prefix && !MUT.name_prefix && MUT.name)
									seedname = "[MUT.name]"
								else if (MUT.name_prefix || MUT.name_suffix)
									seedname = "[MUT.name_prefix][seedname][MUT.name_suffix]"

							S.name = "[seedname] seed"

							S.generation = P.generation
							if (!src.seedoutput) src.seeds.Add(S)
							else S.set_loc(src.loc)
							give -= 1
					src.extractables.Remove(I)
					qdel(I)
					update_static_data(ui.user, ui)
				else
					boutput(ui.user, "<span class='alert'>This item is not viable extraction produce.</span>")

			if("splice_select")
				playsound(src, 'sound/machines/keypress.ogg', 50, 1)
				var/obj/item/I = locate(params["splice_select_ref"]) in src
				if (!istype(I))
					return

				if (I == src.splicing1)
					src.splicing1 = null
				else if(I == src.splicing2)
					src.splicing2 = null
				else if(!src.splicing1)
					src.splicing1 = I
				else if(!src.splicing2)
					src.splicing2 = I

				update_static_data(ui.user, ui)

			if("infuse")
				var/obj/item/seed/S = locate(params["infuse_ref"]) in src
				if (!istype(S))
					return
				if (!src.inserted)
					boutput(ui.user, "<span class='alert'>No reagent container available for infusions.</span>")
				else
					if (src.inserted.reagents.total_volume < 10)
						boutput(ui.user, "<span class='alert'>You require at least ten units of a reagent to infuse a seed.</span>")
					else
						var/list/usable_reagents = list()
						var/list/usable_reagents_names = list()
						usable_reagents_names += "All"

						for(var/current_id in src.inserted.reagents.reagent_list)
							var/datum/reagent/current_reagent = src.inserted.reagents.reagent_list[current_id]
							if (current_reagent.volume >= 10)
								usable_reagents += current_reagent
								usable_reagents_names += capitalize(current_reagent.name)

						if (length(usable_reagents) < 1)
							boutput(ui.user, "<span class='alert'>You require at least ten units of a reagent to infuse a seed.</span>")
						else
							var/requested = "All"
							if(length(usable_reagents) > 1)
								requested = tgui_input_list(ui.user, "Use which reagent to infuse the seed?", "[src.name]", usable_reagents_names)
							if (!requested || !S)
								return
							if(requested != "All")
								//if not all, pull all but the chosen one out of the list
								for(var/datum/reagent/R in usable_reagents)
									if(lowertext(R.name) != lowertext(requested))
										usable_reagents -= R
							for(var/datum/reagent/R in usable_reagents)
								switch(S.HYPinfusionS(R.id,src))
									if (1)
										playsound(src, 'sound/machines/seed_destroyed.ogg', 50, 1)
										boutput(usr, "<span class='alert'>ERROR: Seed has been destroyed.</span>")
										break
									if (2)
										playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 1)
										boutput(usr, "<span class='alert'>ERROR: Reagent lost.</span>")
										break
									if (3)
										playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 1)
										boutput(usr, "<span class='alert'>ERROR: Unknown error. Please try again.</span>")
										break
									else
										playsound(src, 'sound/effects/zzzt.ogg', 50, 1)
										boutput(usr, "<span class='notice'>Infusion of [R.name] successful.</span>")
								src.inserted.reagents.remove_reagent(R.id,10)
					update_static_data(ui.user, ui)

			if("splice")
				// Get the seeds being spliced first
				var/obj/item/seed/seed1 = src.splicing1
				var/obj/item/seed/seed2 = src.splicing2

				// How the fuck
				if (!seed1 || !seed2)
					return

				// Now work out whether we fail to splice or not based on species compatability
				// And the health of the two seeds you're using
				var/splice_chance = 100
				var/datum/plant/P1 = seed1.planttype
				var/datum/plant/P2 = seed2.planttype
				// Sanity check - if something's wrong, just fail the splice and be done with it
				if (!P1 || !P2) splice_chance = 0
				else
					splice_chance = src.SpliceChance(src.splicing1, src.splicing2)
				if (prob(splice_chance)) // We're good, so start splicing!
					var/datum/plantgenes/P1DNA = seed1.plantgenes
					var/datum/plantgenes/P2DNA = seed2.plantgenes

					var/dominance = P1DNA.d_species - P2DNA.d_species
					var/datum/plant/dominantspecies = null
					var/datum/plant/submissivespecies = null
					var/datum/plantgenes/dominantDNA = null
					var/datum/plantgenes/submissiveDNA = null

					// Establish which species allele is dominant
					// If neither, we pick randomly unlike the rest of the allele resolutions
					if (dominance > 0 || (dominance == 0 && prob(50)))
						dominantspecies = P1
						submissivespecies = P2
						dominantDNA = P1DNA
						submissiveDNA = P2DNA
					else
						dominantspecies = P2
						submissivespecies = P1
						dominantDNA = P2DNA
						submissiveDNA = P1DNA

					// Create the new seed
					var/obj/item/seed/S = new /obj/item/seed
					S.set_loc(src)
					var/dominantType = dominantspecies.type
					var/datum/plant/P = new dominantType(S)
					var/datum/plantgenes/DNA = new /datum/plantgenes(S)
					S.planttype = P
					S.plantgenes = DNA
					P.hybrid = 1
					S.generation = max(seed1.generation, seed2.generation) + 1

					if (dominantspecies.name != submissivespecies.name)
						var/part1 = copytext(dominantspecies.name, 1, round(length(dominantspecies.name) * 0.65 + 1.5))
						var/part2 = copytext(submissivespecies.name, round(length(submissivespecies.name) * 0.45 + 1), 0)
						P.name = "[part1][part2]"
					else
						P.name = dominantspecies.name

					P.sprite = dominantspecies.sprite
					if(dominantspecies.override_icon_state)
						P.override_icon_state = dominantspecies.override_icon_state
					else
						P.override_icon_state = dominantspecies.name
					P.plant_icon = dominantspecies.plant_icon
					P.crop = dominantspecies.crop
					P.force_seed_on_harvest = dominantspecies.force_seed_on_harvest
					P.harvestable = dominantspecies.harvestable
					P.harvests = dominantspecies.harvests
					P.isgrass = dominantspecies.isgrass
					P.cantscan = dominantspecies.cantscan
					P.nectarlevel = dominantspecies.nectarlevel
					S.name = "[P.name] seed"

					P.seedcolor = rgb(round((GetRedPart(P1.seedcolor) + GetRedPart(P2.seedcolor)) / 2), round((GetGreenPart(P1.seedcolor) + GetGreenPart(P2.seedcolor)) / 2), round((GetBluePart(P1.seedcolor) + GetBluePart(P2.seedcolor)) / 2))
					S.plant_seed_color(P.seedcolor)

					var/newgenome = P1.genome + P2.genome
					if (newgenome)
						newgenome = round(newgenome / 2)
					P.genome = newgenome

					for (var/datum/plantmutation/MUT in dominantspecies.mutations)
						// Only share the dominant species mutations or else shit might get goofy
						P.mutations += new MUT.type(P)

					if (dominantDNA.mutation)
						DNA.mutation = new dominantDNA.mutation.type(DNA)

					P.commuts = P1.commuts | P2.commuts // We merge these and share them
					DNA.commuts = P1DNA.commuts | P2DNA.commuts
					if(submissiveDNA.mutation)
						P.assoc_reagents = P1.assoc_reagents | P2.assoc_reagents | submissiveDNA.mutation.assoc_reagents // URS EDIT -- BOTANY UNLEASHED?
					else
						P.assoc_reagents = P1.assoc_reagents | P2.assoc_reagents

					// Now we start combining genetic traits based on allele dominance
					// If one is dominant and the other recessive, use the dominant value
					// If both are dominant or recessive, average the values out

					P.growtime = SpliceMK2(P1DNA.d_growtime,P2DNA.d_growtime,P1.vars["growtime"],P2.vars["growtime"])
					DNA.growtime = SpliceMK2(P1DNA.d_growtime,P2DNA.d_growtime,P1DNA.vars["growtime"],P2DNA.vars["growtime"])

					P.harvtime = SpliceMK2(P1DNA.d_harvtime,P2DNA.d_harvtime,P1.vars["harvtime"],P2.vars["harvtime"])
					DNA.harvtime = SpliceMK2(P1DNA.d_harvtime,P2DNA.d_harvtime,P1DNA.vars["harvtime"],P2DNA.vars["harvtime"])

					P.cropsize = SpliceMK2(P1DNA.d_cropsize,P2DNA.d_cropsize,P1.vars["cropsize"],P2.vars["cropsize"])
					DNA.cropsize = SpliceMK2(P1DNA.d_cropsize,P2DNA.d_cropsize,P1DNA.vars["cropsize"],P2DNA.vars["cropsize"])

					P.harvests = SpliceMK2(P1DNA.d_harvests,P2DNA.d_harvests,P1.vars["harvests"],P2.vars["harvests"])
					DNA.harvests = SpliceMK2(P1DNA.d_harvests,P2DNA.d_harvests,P1DNA.vars["harvests"],P2DNA.vars["harvests"])

					DNA.potency = SpliceMK2(P1DNA.d_potency,P2DNA.d_potency,P1DNA.vars["potency"],P2DNA.vars["potency"])

					P.endurance = SpliceMK2(P1DNA.d_endurance,P2DNA.d_endurance,P1.vars["endurance"],P2.vars["endurance"])
					DNA.endurance = SpliceMK2(P1DNA.d_endurance,P2DNA.d_endurance,P1DNA.vars["endurance"],P2DNA.vars["endurance"])

					boutput(usr, "<span class='notice'>Splice successful.</span>")
					playsound(src, 'sound/machines/ping.ogg', 50, 1)
					//0 xp for a 100% splice, 4 xp for a 10% splice
					JOB_XP(usr, "Botanist", clamp(round((100 - splice_chance) / 20), 0, 4))
					if (!src.seedoutput) src.seeds.Add(S)
					else S.set_loc(src.loc)

				else
					// It fucked up - we don't need to do anything else other than tell the user
					boutput(usr, "<span class='alert'>Splice failed.</span>")
					playsound(src, 'sound/machines/seed_destroyed.ogg', 50, 1)

				// Now get rid of the old seeds and go back to square one
				src.seeds.Remove(seed1)
				src.seeds.Remove(seed2)
				src.splicing1 = null
				src.splicing2 = null
				qdel(seed1)
				qdel(seed2)
				src.mode = "seedlist"
				update_static_data(ui.user, ui)



	attackby(var/obj/item/W, var/mob/user)
		if(istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/))
			if(src.inserted)
				boutput(user, "<span class='alert'>A container is already loaded into the machine.</span>")
				return
			src.inserted =  W
			user.drop_item()
			W.set_loc(src)
			boutput(user, "<span class='notice'>You add [W] to the machine!</span>")
			for(var/datum/tgui/ui in tgui_process.open_uis_by_src["\ref[src]"]) //this is basically tgui_process.update_uis for static data
				if(ui?.src_object && ui.user && ui.src_object.ui_host(ui.user))
					update_static_data(ui.user, ui)
			tgui_process.update_uis(src)


		else if(istype(W, /obj/item/reagent_containers/food/snacks/plant/) || istype(W, /obj/item/seed/))
			boutput(user, "<span class='notice'>You add [W] to the machine!</span>")
			user.u_equip(W)
			W.set_loc(src)
			if (istype(W, /obj/item/seed/)) src.seeds += W
			else src.extractables += W
			W.dropped(user)
			for(var/datum/tgui/ui in tgui_process.open_uis_by_src["\ref[src]"]) //this is basically tgui_process.update_uis for static data
				if(ui?.src_object && ui.user && ui.src_object.ui_host(ui.user))
					update_static_data(ui.user, ui)
			tgui_process.update_uis(src)
			return

		else if(istype(W,/obj/item/satchel/hydro))
			var/obj/item/satchel/S = W
			var/select = input(user, "Load what from the satchel?", "[src.name]", 0) in list("Everything","Fruit Only","Seeds Only","Never Mind")
			if (select != "Never Mind")
				var/loadcount = 0
				for (var/obj/item/I in S.contents)
					if (istype(I,/obj/item/seed/) && (select == "Everything" || select == "Seeds Only"))
						I.set_loc(src)
						src.seeds += I
						loadcount++
						continue
					if (istype(I,/obj/item/reagent_containers/food/snacks/plant/) && (select == "Everything" || select == "Fruit Only"))
						I.set_loc(src)
						src.extractables += I
						loadcount++
						continue
				if (loadcount)
					boutput(user, "<span class='notice'>[loadcount] items were loaded from the satchel!</span>")
				else
					boutput(user, "<span class='alert'>No items were loaded from the satchel!</span>")
				S.UpdateIcon()
				for(var/datum/tgui/ui in tgui_process.open_uis_by_src["\ref[src]"]) //this is basically tgui_process.update_uis for static data
					if(ui?.src_object && ui.user && ui.src_object.ui_host(ui.user))
						update_static_data(ui.user, ui)
				tgui_process.update_uis(src)
		else ..()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!O || !user)
			return
		if (!isliving(user) || isintangible(user) || !in_interact_range(src, user)  || BOUNDS_DIST(O, user) > 0)
			return
		if (!isitem(O))
			return
		if (istype(O, /obj/item/reagent_containers/glass/) || istype(O, /obj/item/reagent_containers/food/drinks/) || istype(O,/obj/item/satchel/hydro))
			return src.Attackby(O, user)
		if (istype(O, /obj/item/reagent_containers/food/snacks/plant/) || istype(O, /obj/item/seed/))
			user.visible_message("<span class='notice'>[user] begins quickly stuffing [O] into [src]!</span>")
			var/itemtype = O.type
			var/staystill = user.loc
			for(var/obj/item/P in view(1,user))
				if (user.loc != staystill) break
				if (P.type != itemtype) continue
				playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 30, 1)
				if (istype(O, /obj/item/seed/))
					src.seeds.Add(P)
				else
					src.extractables.Add(P)
				if (P.loc == user)
					user.u_equip(P)
					P.dropped(user)
				P.set_loc(src)
				sleep(0.3 SECONDS)
			boutput(user, "<span class='notice'>You finish stuffing [O] into [src]!</span>")
			for(var/datum/tgui/ui in tgui_process.open_uis_by_src["\ref[src]"]) //this is basically tgui_process.update_uis for static data
				if(ui?.src_object && ui.user && ui.src_object.ui_host(ui.user))
					update_static_data(ui.user, ui)
			tgui_process.update_uis(src)
		else ..()

	proc/SpliceChance(var/obj/item/seed/seed1, var/obj/item/seed/seed2)
		if (seed1 && seed2)
			var/datum/plant/P1 = seed1.planttype
			var/datum/plant/P2 = seed2.planttype
			var/splice_chance = 100
			var/genome_difference = abs(P1.genome - P2.genome)
			splice_chance -= genome_difference * 10

			splice_chance -= seed1.seeddamage
			splice_chance -= seed2.seeddamage

			if (seed1.plantgenes.commuts)
				for (var/datum/plant_gene_strain/splicing/S in seed1.plantgenes.commuts)
					if (S.negative)
						splice_chance -= S.splice_mod
					else
						splice_chance += S.splice_mod

			if (seed2.plantgenes.commuts)
				for (var/datum/plant_gene_strain/splicing/S in seed2.plantgenes.commuts)
					if (S.negative)
						splice_chance -= S.splice_mod
					else
						splice_chance += S.splice_mod

			return clamp(splice_chance, 0, 100)

	proc/SpliceMK2(var/allele1,var/allele2,var/value1,var/value2)
		var/dominance = allele1 - allele2

		if (dominance > 0)
			return value1
		else if (dominance < 0)
			return value2
		else
			return round((value1 + value2)/2)

	proc/QuickAnalysisRow(var/obj/scanned, var/datum/plant/P, var/datum/plantgenes/DNA)
		if (!DNA) return

		var/generation = 0

		if (P.cantscan)
			return list()

		if (istype(scanned, /obj/item/seed/))
			var/obj/item/seed/S = scanned
			generation = S.generation
		if (istype(scanned, /obj/item/reagent_containers/food/snacks/plant/))
			var/obj/item/reagent_containers/food/snacks/plant/F = scanned
			generation = F.generation

		var/result = list()
		//list of attributes and their dominance flag
		result["name"] = list(scanned.name, FALSE)
		result["species"] = list(P.name, DNA.d_species)
		result["genome"] = list(P.genome, FALSE) //genome is always averaged
		result["generation"] = list(generation, FALSE)
		result["growtime"] = list(DNA.growtime, DNA.d_growtime)
		result["harvesttime"] = list(DNA.harvtime, DNA.d_harvtime)
		result["lifespan"] = list(DNA.harvests, DNA.d_harvests)
		result["cropsize"] = list(DNA.cropsize, DNA.d_cropsize)
		result["potency"] = list(DNA.potency, DNA.d_potency)
		result["endurance"] = list(DNA.endurance, DNA.d_endurance)
		result["ref"]= list("\ref[scanned]", FALSE)
		return result

	Exited(Obj, newloc)
		if(Obj == src.inserted)
			src.inserted = null
			src.updateUsrDialog()

////// Reagent Extractor

TYPEINFO(/obj/submachine/chem_extractor)
	mats = 6

/obj/submachine/chem_extractor
	name = "reagent extractor"
	desc = "A machine which can extract reagents from matter. Has a slot for a beaker and a chute to put things into."
	density = 1
	anchored = 1
	event_handler_flags = NO_MOUSEDROP_QOL
	deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	icon = 'icons/obj/objects.dmi'
	icon_state = "reex-off"
	flags = NOSPLASH | TGUI_INTERACTIVE
	var/mode = "overview"
	var/autoextract = FALSE
	var/nextingredientkey = 0
	var/obj/item/reagent_containers/glass/extract_to = null
	var/obj/item/reagent_containers/glass/inserted = null
	var/obj/item/reagent_containers/glass/storage_tank_1 = null
	var/obj/item/reagent_containers/glass/storage_tank_2 = null
	var/list/ingredients = list()
	var/list/allowed = list(/obj/item/reagent_containers/food/snacks/,/obj/item/plant/,/obj/item/seashell)

	New()
		..()
		src.storage_tank_1 = new /obj/item/reagent_containers/glass/beaker/extractor_tank(src)
		src.storage_tank_2 = new /obj/item/reagent_containers/glass/beaker/extractor_tank(src)
		var/count = 1
		for (var/obj/item/reagent_containers/glass/beaker/extractor_tank/ST in src.contents)
			ST.name = "Storage Tank [count]"
			count++
		AddComponent(/datum/component/transfer_input/quickloading, allowed, "tryLoading")
		AddComponent(/datum/component/transfer_output)

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	ui_interact(mob/user, datum/tgui/ui)
		remove_distant_beaker()
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ReagentExtractor", src.name)
			ui.open()

	ui_data(mob/user)
		. = list()
		var/list/containers = src.getContainers()

		var/list/containersData = list()
		// Container data
		for(var/container_id in containers)
			var/obj/item/reagent_containers/thisContainer = containers[container_id]
			if (!thisContainer)
				continue
			containersData[container_id] = ui_describe_reagents(thisContainer)
			containersData[container_id]["selected"] = src.extract_to == thisContainer
			containersData[container_id]["id"] = container_id

		.["containersData"] = containersData

		var/list/ingredientsData = list()
		// Ingredient/Extractable data
		for(var/ingredient_id in src.ingredients)
			var/obj/item/thisIngredient = src.ingredients[ingredient_id]
			if(thisIngredient)
				var/list/thisIngredientData = list(
					name = thisIngredient.name,
					id = ingredient_id
				)
				ingredientsData += list(thisIngredientData)

		.["ingredientsData"] = ingredientsData

		.["autoextract"] = src.autoextract



	ui_act(action, params)
		. = ..()
		if(.)
			return
		remove_distant_beaker()
		var/list/containers = src.getContainers()
		switch(action)
			if("ejectcontainer")
				var/obj/item/I = src.inserted
				if (!I)
					return
				if(src.inserted.loc == src)
					TRANSFER_OR_DROP(src, I) // causes Exited proc to be called
					usr.put_in_hand_or_eject(I)
				if (I == src.extract_to) src.extract_to = null
				src.inserted = null
				. = TRUE
			if("insertcontainer")
				if (src.inserted)
					return
				var/obj/item/inserting = usr.equipped()
				if(istype(inserting, /obj/item/reagent_containers/glass/) || istype(inserting, /obj/item/reagent_containers/food/drinks/))
					tryInsert(inserting, usr)
					. = TRUE
			if("ejectingredient")
				var/id = params["ingredient_id"]
				var/obj/item/ingredient = src.ingredients[id]
				if (istype(ingredient))
					src.ingredients.Remove(id)
					TRANSFER_OR_DROP(src, ingredient)
					. = TRUE
			if("autoextract")
				src.autoextract = !src.autoextract
				. = TRUE
			if("flush_reagent")
				var/obj/item/reagent_containers/glass/target = containers[params["container_id"]]
				var/id = params["reagent_id"]
				if (target?.reagents)
					target.reagents.remove_reagent(id, 500)
					. = TRUE
			if("isolate")
				var/obj/item/reagent_containers/glass/target = containers[params["container_id"]]
				var/id = params["reagent_id"]
				if (target?.reagents)
					target.reagents.isolate_reagent(id)
					. = TRUE
			if("flush")
				var/obj/item/reagent_containers/glass/target = containers[params["container_id"]]
				if (target)
					target.reagents.clear_reagents()
					. = TRUE
			if("extractto")
				var/obj/item/reagent_containers/glass/target = containers[params["container_id"]]
				if (target)
					src.extract_to = target
					. = TRUE
			if("extractingredient")
				if (!src.extract_to || src.extract_to.reagents.total_volume >= src.extract_to.reagents.maximum_volume)
					return
				var/id = params["ingredient_id"]
				var/obj/item/ingredient = src.ingredients[id]
				if (!istype(ingredient) || !ingredient.reagents)
					return
				src.doExtract(ingredient)
				src.ingredients.Remove(id)
				qdel(ingredient)
				. = TRUE
			if("chemtransfer")
				var/obj/item/reagent_containers/glass/from = containers[params["container_id"]]
				var/obj/item/reagent_containers/glass/target = src.extract_to
				if (from?.reagents.total_volume && target && from != target)
					from.reagents.trans_to(target, clamp(params["amount"], 1, 500))
					. = TRUE
		src.UpdateIcon()

	attackby(var/obj/item/W, var/mob/user)
		if(istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/))
			tryInsert(W, user)

		..()

	proc/remove_distant_beaker()
		// borgs and people with item arms don't insert the beaker into the machine itself
		// but whenever something would happen to the dispenser and the beaker is far it should disappear
		if(src.inserted && BOUNDS_DIST(src.inserted, src) > 0)
			if (src.inserted == src.extract_to) src.extract_to = null
			src.inserted = null
			src.UpdateIcon()

	proc/tryInsert(var/obj/item/W, var/mob/user)
		remove_distant_beaker()

		if(BOUNDS_DIST(user, src) > 0) // prevent message from appearing in case a borg inserts from afar
			return

		if(src.inserted)
			boutput(user, "<span class='alert'>A container is already loaded into the machine.</span>")
			return
		src.inserted =  W

		if(!W.cant_drop)
			user.drop_item()
			if(!QDELETED(W))
				W.set_loc(src)
		if(QDELETED(W))
			W = null
		else
			if(!src.extract_to) src.extract_to = W
			boutput(user, "<span class='notice'>You add [W] to the machine!</span>")
		src.ui_interact(user)

	Exited(Obj, newloc)
		if(Obj == src.inserted)
			src.inserted = null
			tgui_process.update_uis(src)

/obj/submachine/chem_extractor/proc/getContainers()
	. = list(
		inserted = src.inserted,
		storage_tank_1 = src.storage_tank_1,
		storage_tank_2 = src.storage_tank_2
	)

/obj/submachine/chem_extractor/update_icon()
	if (src.ingredients.len)
		src.icon_state = "reex-on"
	else
		src.icon_state = "reex-off"

/obj/submachine/chem_extractor/proc/doExtract(atom/movable/AM)
	// Welp -- we don't want anyone extracting these. They'll probably
	// feed them to monkeys and then exsanguinate them trying to get at the chemicals.
	if (istype(AM, /obj/item/reagent_containers/food/snacks/candy/jellybean/everyflavor))
		src.extract_to.reagents.add_reagent("sugar", 50)
		return
	AM.reagents.trans_to(src.extract_to, AM.reagents.total_volume)
	qdel(AM)
	src.UpdateIcon()

/obj/submachine/chem_extractor/proc/tryLoading(atom/movable/incoming)
	var/can_autoextract = src.autoextract && src.extract_to
	if (can_autoextract && src.extract_to.reagents.total_volume >= src.extract_to.reagents.maximum_volume)
		playsound(src, 'sound/machines/chime.ogg', 10, 1)
		src.visible_message("<span class='alert'>[src]'s tank over-fill alarm burps!</span>")
		can_autoextract = FALSE

	if (can_autoextract)
		doExtract(incoming)
	else
		src.ingredients["[nextingredientkey++]"] = incoming
		tgui_process.update_uis(src)
		src.UpdateIcon()


TYPEINFO(/obj/submachine/seed_vendor)
	mats = 6

/obj/submachine/seed_vendor
	name = "Seed Fabricator"
	desc = "Fabricates basic plant seeds."
	icon = 'icons/obj/vending.dmi'
	icon_state = "seeds"
	density = 1
	anchored = 1
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WIRECUTTERS | DECON_MULTITOOL
	flags = TGUI_INTERACTIVE
	var/hacked = 0
	var/can_vend = 1
	var/seedcount = 0
	var/maxseed = 25
	var/list/available = list()
	var/static/datum/wirePanel/panelDefintion/panel_def = new /datum/wirePanel/panelDefintion(
		controls=list(WIRE_CONTROL_RESTRICT, WIRE_CONTROL_SAFETY, WIRE_CONTROL_POWER_A, WIRE_CONTROL_INERT),
		color_pool=list("dandelion", "cherry", "pistachio", "blueberry"),
		custom_acts=list(
			WPANEL_CUSTOM_ACT(WIRE_CONTROL_RESTRICT, ~WIRE_ACT_MEND, WIRE_ACT_PULSE),
			WPANEL_CUSTOM_ACT(WIRE_CONTROL_SAFETY, ~WIRE_ACT_CUT, ~WIRE_ACT_MEND),
			WPANEL_CUSTOM_ACT(WIRE_CONTROL_POWER_A, WIRE_ACT_PULSE, ~WIRE_ACT_MEND),
		)
	)

	New()
		..()
		for (var/A in concrete_typesof(/datum/plant)) src.available += new A(src)
		AddComponent(/datum/component/wirePanel, src.panel_def)
		RegisterSignal(src, COMSIG_WPANEL_SET_CONTROL, .proc/set_control)
		RegisterSignal(src, COMSIG_WPANEL_SET_COVER, .proc/set_cover)

	disposing()
		. = ..()

	proc/set_control(obj/parent, mob/user, controls, new_status)
		if (controls == WIRE_CONTROL_RESTRICT)
			if (new_status)
				src.name = "Seed Fabricator"
			else
				src.name = "Feed Sabricator"
			if (user)
				update_static_data(user)

	attack_ai(mob/user as mob)
		return src.Attackhand(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "SeedFabricator", src.name)
			ui.open()

	ui_data(mob/user)
		. = list()
		.["seedCount"] = src.seedcount
		.["canVend"] = src.can_vend
		SEND_SIGNAL(src, COMSIG_WPANEL_UI_DATA, user, .)

	ui_static_data(mob/user)
		. = list()
		.["wirePanelTheme"] = WPANEL_THEME_CONTROLS
		.["maxSeed"] = src.maxseed
		.["name"] = src.name

		var/active_controls = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_CONTROLS)
		// Start with associative list, where each key is a seed category
		var/list/categories = list()
		for(var/datum/plant/A in hydro_controls.vendable_plants)
			if (A.vending == 1 || !HAS_FLAG(active_controls, WIRE_CONTROL_RESTRICT))
				if (!categories[A.category])
					categories[A.category] = list()
				categories[A.category] += list(list(
					name = A.name,
					path = A.type,
					img = A.getBase64Img()
				))
		// Convert to non-associative list holding each category
		var/list/categoriesArray = list()
		for(var/category_name in categories)
			var/category = categories[category_name]
			categoriesArray += list(list(
				name = category_name,
				seeds = category
			))
		.["seedCategories"] = categoriesArray
		SEND_SIGNAL(src, COMSIG_WPANEL_UI_STATIC_DATA, user, .)

	ui_act(action, list/params, datum/tgui/ui)
		. = ..()
		SEND_SIGNAL(src, COMSIG_WPANEL_UI_ACT, action, params, ui)
		var/active_controls = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_CONTROLS)
		if(. || action != "disp" || !src.can_vend || !HAS_FLAG(active_controls, WIRE_CONTROL_POWER_A))
			return
		var/datum/plant/I = locate(text2path(params["path"])) in src.available

		if (!istype(I))
			return

		if(!I.vending)
			trigger_anti_cheat(ui.user, "tried to href exploit vend forbidden seed [I] on [src]")
			return

		var/vend = clamp(params["amount"], 1, 10)

		while(vend > 0)
			var/obj/item/seed/S
			if (I.unique_seed)
				S = new I.unique_seed
				S.set_loc(src.loc)
			else
				S = new /obj/item/seed
				S.set_loc(src.loc)
				S.removecolor()
			S.generic_seed_setup(I)
			vend--
			src.seedcount++

		if(src.seedcount >= src.maxseed)
			src.can_vend = 0
			SPAWN(10 SECONDS)
				src.can_vend = 1
				src.seedcount = 0
		. = TRUE

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.hacked)
			if(user)
				boutput(user, "<span class='notice'>You disable the [src]'s product locks!</span>")
			SEND_SIGNAL(src, COMSIG_WPANEL_SET_CONTROL, WIRE_CONTROL_RESTRICT, FALSE)
			return 1
		else
			if(user)
				boutput(user, "The [src] is already unlocked!")
			return 0

	proc/set_cover(obj/parent, mob/user, status)
		switch(status)
			if (WPANEL_COVER_OPEN)
				src.overlays += image('icons/obj/vending.dmi', "grife-panel")
			if (WPANEL_COVER_CLOSED)
				src.overlays = null
		tgui_process.update_user_uis(user)
TYPEINFO(/obj/submachine/seed_manipulator/kudzu)
	mats = 0

/obj/submachine/seed_manipulator/kudzu
	name = "KudzuMaster V1"
	desc = "A strange \"machine\" that seems to function via fluids and plant fibers."
	deconstruct_flags = null
	icon = 'icons/misc/kudzu_plus.dmi'
	icon_state = "seed-gene-console"
	_health = 1

	disposing()
		var/turf/T = get_turf(src)
		for (var/obj/O in seeds)
			O.set_loc(T)
		src.visible_message("<span class='alert'>All the seeds spill out of [src]!</span>")
		..()
	attack_ai(var/mob/user as mob)
		return 0

	attack_hand(var/mob/user)
		if (iskudzuman(user))
			..()
		else
			boutput(user, "<span class='notice'>You stare at the bit that looks most like a screen, but you can't make heads or tails of what it's saying.!</span>")

	//only kudzumen can understand it.
	attackby(var/obj/item/W, var/mob/user)
		if (!W) return
		if (!user) return

		if (destroys_kudzu_object(src, W, user))
			//Takes at least 2 hits to kill.
			if (_health)
				_health = 0
				return

			if (prob(40))
				user.visible_message("<span class='alert'>[user] savagely attacks [src] with [W]!</span>")
			else
				user.visible_message("<span class='alert'>[user] savagely attacks [src] with [W], destroying it!</span>")
				qdel(src)
				return
		..()
