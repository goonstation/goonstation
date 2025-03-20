TYPEINFO(/obj/submachine/seed_manipulator)
	mats = 10

/obj/submachine/seed_manipulator
	name = "PlantMaster Mk4"
	desc = "An advanced machine used for manipulating the genes of plant seeds. It also features an inbuilt seed extractor."
	density = TRUE
	anchored = ANCHORED
	icon = 'icons/obj/objects.dmi'
	icon_state = "geneman-on"
	flags = NOSPLASH | TGUI_INTERACTIVE
	event_handler_flags = NO_MOUSEDROP_QOL
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	var/mode = "overview"
	var/list/seeds = list()
	var/output_externally = FALSE
	var/sort = "name"
	var/sortAsc = FALSE
	var/obj/item/seed/splicing1 = null
	var/obj/item/seed/splicing2 = null
	var/list/extractables = list()
	var/obj/item/reagent_containers/glass/inserted = null

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	ui_data(mob/user)
		var/list/thisContainerData = null
		var/splice_chance = 100
		var/splice1_geneout
		var/splice2_geneout

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

		if (src.splicing1 && src.splicing2)
			splice_chance = src.SpliceChance(src.splicing1, src.splicing2)

		if(src.splicing1)
			splice1_geneout = QuickAnalysisRow(src.splicing1, src.splicing1.planttype, src.splicing1.plantgenes)
			splice1_geneout["damage"] = src.splicing1.seeddamage
			splice1_geneout["splicing"] = TRUE
		if(src.splicing2)
			splice2_geneout = QuickAnalysisRow(src.splicing2, src.splicing2.planttype, src.splicing2.plantgenes)
			splice2_geneout["damage"] = src.splicing2.seeddamage
			splice2_geneout["splicing"] = TRUE

		return list(
			"category" = src.mode,
			"num_extractables" = length(src.extractables),
			"num_seeds" = length(src.seeds),
			"inserted_desc" =  src.inserted ? "[src.inserted.reagents.total_volume]/[src.inserted.reagents.maximum_volume] [src.inserted.name]" : "No reagent vessel",
			"inserted_container" = thisContainerData,
			"output_externally" = src.output_externally,
			"splice_chance" = splice_chance,
			"splice_seeds" = list(splice1_geneout, splice2_geneout),
			"sortBy" = src.sort,
			"sortAsc" = src.sortAsc,
			"allow_infusion" = src.inserted?.reagents?.total_volume > 0
		)

	ui_static_data(mob/user)
		var/exlist = list()
		var/seedlist = list()
		var/geneout = null//tmp var for storing analysis results

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
					geneout["damage"] = S.seeddamage
					geneout["splicing"] = (S == src.splicing1) || (S == src.splicing2)
					seedlist += list(geneout)

		return list(
			"extractables" = exlist,
			"seeds" = seedlist,
		)

	Exited(Obj, newloc)
		. = ..()
		if(Obj in seeds)
			seeds -= Obj
		if(Obj in extractables)
			extractables -= Obj
		if(Obj == inserted)
			inserted = null
		if(Obj == splicing1)
			splicing1 = null
		if(Obj == splicing2)
			splicing2 = null

	ui_interact(mob/user, datum/tgui/ui)
		if (src.mode == "overview" && src.inserted)
			SEND_SIGNAL(src.inserted.reagents, COMSIG_REAGENTS_ANALYZED, user)
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
					boutput(usr, SPAN_ALERT("No receptacle found to eject."))
				else
					if (I.cant_drop) // cyborg/item arms
						src.inserted = null
					else
						I.set_loc(src.loc) // causes Exited proc to be called
						usr.put_in_hand_or_eject(I) // try to eject it into the users hand, if we can
				. = TRUE

			if("insertbeaker")
				if (src.inserted)
					return
				var/obj/item/inserting = usr.equipped()
				if(istype(inserting, /obj/item/reagent_containers/glass/) || istype(inserting, /obj/item/reagent_containers/food/drinks/))
					if (isrobot(ui.user))
						boutput(ui.user, "This machine does not accept containers from robots!")
						return
					if(src.inserted)
						boutput(ui.user, SPAN_ALERT("A container is already loaded into the machine."))
						return
					src.inserted =  inserting
					ui.user.drop_item()
					inserting.set_loc(src)
					boutput(ui.user, SPAN_NOTICE("You add [inserted] to the machine!"))
					. = TRUE

			if("ejectseeds")
				for (var/obj/item/seed/S in src.seeds)
					src.seeds.Remove(S)
					S.set_loc(src.loc)
					usr.put_in_hand_or_eject(S) // try to eject it into the users hand, if we can
				src.splicing1 = null
				src.splicing2 = null
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
				src.sortAsc = params["asc"]
				. = TRUE

			if("analyze")
				var/obj/item/I = locate(params["analyze_ref"]) in src
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

				if (istype(I,/obj/item/seed/))
					var/obj/item/seed/S = I
					if (!istype(S.planttype,/datum/plant/) || !istype(S.plantgenes,/datum/plantgenes/))
						boutput(ui.user, SPAN_ALERT("Genetic structure of seed corrupted. Cannot scan."))
					else
						HYPgeneticanalysis(ui.user,S,S.planttype,S.plantgenes)

				else if (istype(I,/obj/item/reagent_containers/food/snacks/plant/))
					var/obj/item/reagent_containers/food/snacks/plant/P = I
					if (!istype(P.planttype,/datum/plant/) || !istype(P.plantgenes,/datum/plantgenes/))
						boutput(ui.user, SPAN_ALERT("Genetic structure of item corrupted. Cannot scan."))
					else
						HYPgeneticanalysis(ui.user,P,P.planttype,P.plantgenes)
				else
					boutput(ui.user, SPAN_ALERT("Item cannot be scanned."))

			if("toggle-output-mode")
				src.output_externally = !src.output_externally
				. = TRUE

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
						boutput(ui.user, SPAN_ALERT("No viable seeds found in [I]."))
					else
						boutput(ui.user, SPAN_NOTICE("Extracted [give] seeds from [I]."))
						var/obj/item/seed/S = HYPgenerateseedcopy(DNA, stored, P.generation, src, give)
						if (!src.output_externally)
							src.seeds.Add(S)
						else
							S.set_loc(src.loc)
					src.extractables.Remove(I)
					qdel(I)
					update_static_data(ui.user, ui)
				else
					boutput(ui.user, SPAN_ALERT("This item is not viable extraction produce."))

			if("splice_select")
				playsound(src, 'sound/machines/keypress.ogg', 50, TRUE)
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
					boutput(ui.user, SPAN_ALERT("No reagent container available for infusions."))
				else
					if (src.inserted.reagents.total_volume < 10)
						boutput(ui.user, SPAN_ALERT("You require at least ten units of a reagent to infuse a seed."))
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
							boutput(ui.user, SPAN_ALERT("You require at least ten units of a reagent to infuse a seed."))
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
								if(R.volume < 10)
									playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
									boutput(usr, SPAN_ALERT("ERROR: Not enough reagent."))
									break
								switch(S.HYPinfusionS(R.id,src))
									if (1)
										playsound(src, 'sound/machines/seed_destroyed.ogg', 50, TRUE)
										boutput(usr, SPAN_ALERT("ERROR: Seed has been destroyed."))
										break
									if (2)
										playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
										boutput(usr, SPAN_ALERT("ERROR: Reagent lost."))
										break
									if (3)
										playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
										boutput(usr, SPAN_ALERT("ERROR: Unknown error. Please try again."))
										break
									else
										playsound(src, 'sound/effects/zzzt.ogg', 50, TRUE)
										boutput(usr, SPAN_NOTICE("Infusion of [R.name] successful."))
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
					P.innate_commuts = P1.innate_commuts | P2.innate_commuts
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

					// now after our seed is created, we run through each commut the plant currently got and look if they somehow fumble around with our seed
					if (length(DNA.commuts) > 0)
						//since HYPadd/removeCommut create new lists, we take the initial list and only iterate through the commuts that existed at the time of the splice
						var/list/commuts_to_iterate = DNA.commuts
						for (var/datum/plant_gene_strain/checked_strain in commuts_to_iterate)
							checked_strain.on_passing(DNA)
							checked_strain.changes_after_splicing(DNA)

					boutput(usr, SPAN_NOTICE("Splice successful."))
					playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
					//0 xp for a 100% splice, 4 xp for a 10% splice
					JOB_XP(usr, "Botanist", clamp(round((100 - splice_chance) / 20), 0, 4))
					if (!src.output_externally)
						src.seeds.Add(S)
					else
						S.set_loc(src.loc)

				else
					// It fucked up - we don't need to do anything else other than tell the user
					boutput(usr, SPAN_ALERT("Splice failed."))
					playsound(src, 'sound/machines/seed_destroyed.ogg', 50, TRUE)

				// Now remove a charge from each seed, and destroy any seeds which have been totally expended.
				seed1.charges--
				if (seed1.charges < 1)
					src.seeds.Remove(seed1)
					qdel(seed1)
					src.splicing1 = null
				seed2.charges--
				if (seed2.charges < 1)
					src.seeds.Remove(seed2)
					qdel(seed2)
					src.splicing2 = null

				src.mode = "seedlist"
				update_static_data(ui.user, ui)



	attackby(var/obj/item/W, var/mob/user)
		if(istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/))
			if(src.inserted)
				boutput(user, SPAN_ALERT("A container is already loaded into the machine."))
				return
			src.inserted =  W
			user.drop_item()
			W.set_loc(src)
			boutput(user, SPAN_NOTICE("You add [W] to the machine!"))
			tgui_process.update_uis(src)


		else if(istype(W, /obj/item/reagent_containers/food/snacks/plant/) || istype(W, /obj/item/seed/))
			boutput(user, SPAN_NOTICE("You add [W] to the machine!"))
			user.u_equip(W)
			W.set_loc(src)
			if (istype(W, /obj/item/seed/)) src.seeds += W
			else src.extractables += W
			W.dropped(user)
			src.update_static_data_for_all_viewers()
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
					boutput(user, SPAN_NOTICE("[loadcount] items were loaded from the satchel!"))
				else
					boutput(user, SPAN_ALERT("No items were loaded from the satchel!"))
				S.UpdateIcon()
				S.tooltip_rebuild = 1
				src.update_static_data_for_all_viewers()
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
			user.visible_message(SPAN_NOTICE("[user] begins quickly stuffing [O] into [src]!"))
			var/itemtype = O.type
			var/staystill = user.loc
			for(var/obj/item/P in view(1,user))
				if (user.loc != staystill) break
				if (P.type != itemtype) continue
				playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 30, 1)
				if (istype(O, /obj/item/seed/))
					src.seeds |= P
				else
					src.extractables |= P
				if (P.loc == user)
					user.u_equip(P)
					P.dropped(user)
				P.set_loc(src)
				sleep(0.3 SECONDS)
			boutput(user, SPAN_NOTICE("You finish stuffing [O] into [src]!"))
			src.update_static_data_for_all_viewers()
			tgui_process.update_uis(src)
		else ..()

	proc/SpliceChance(var/obj/item/seed/seed1, var/obj/item/seed/seed2)
		if (istype(seed1) && istype(seed2) && seed1.planttype && seed2.planttype)
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
		else
			logTheThing(LOG_DEBUG, src, "Attempt to splice invalid seeds. Object details: seed1: [json_encode(seed1)], seed2: [json_encode(seed2)]")
			return 0

	proc/SpliceMK2(var/allele1,var/allele2,var/value1,var/value2)
		var/dominance = allele1 - allele2

		if (dominance > 0)
			return value1
		else if (dominance < 0)
			return value2
		else
			return round((value1 + value2)/2)

	proc/QuickAnalysisRow(var/obj/scanned, var/datum/plant/P, var/datum/plantgenes/DNA)
		var/result = list()
		if (!scanned || !P || P.cantscan || !DNA) //this shouldn't happen, but if it does, return a valid (if confusing) row, and report the error
			result["name"] = scanned ? scanned.name : "???"
			result["item_ref"]= "\ref[scanned]" //in the event that scanned is somehow null, \ref[null] = [0x0]
			result["charges"] = 0
			result["generation"] = 0
			result["genome"] = 0
			result["species"] = list("???", FALSE)
			result["growtime"] = list("???", FALSE)
			result["harvesttime"] = list("???", FALSE)
			result["lifespan"] = list("???", FALSE)
			result["cropsize"] = list("???", FALSE)
			result["potency"] = list("???", FALSE)
			result["endurance"] = list("???", FALSE)
			logTheThing(LOG_DEBUG, src, "An invalid object was placed in the plantmaster. Error recovery prevents a TGUI bluescreen. Object details: scanned: [json_encode(scanned)], P: [json_encode(P)], DNA: [json_encode(DNA)]")
			return result

		var/generation = 0
		var/charges = 0
		if (istype(scanned, /obj/item/seed))
			var/obj/item/seed/S = scanned
			generation = S.generation
			charges = S.charges
		if (istype(scanned, /obj/item/reagent_containers/food/snacks/plant))
			var/obj/item/reagent_containers/food/snacks/plant/F = scanned
			generation = F.generation
			charges = 1

		result["name"] = scanned.name
		result["item_ref"]= "\ref[scanned]"
		result["charges"] = charges
		result["generation"] = generation
		result["genome"] = P.genome // genome is always averaged when splicing
		// list of attributes and their dominance flag
		result["species"] = list(P.name, DNA.d_species)
		result["growtime"] = list(DNA.growtime, DNA.d_growtime)
		result["harvesttime"] = list(DNA.harvtime, DNA.d_harvtime)
		result["lifespan"] = list(DNA.harvests, DNA.d_harvests)
		result["cropsize"] = list(DNA.cropsize, DNA.d_cropsize)
		result["potency"] = list(DNA.potency, DNA.d_potency)
		result["endurance"] = list(DNA.endurance, DNA.d_endurance)
		return result

	Exited(Obj, newloc)
		if(Obj == src.inserted)
			src.inserted = null
			src.updateUsrDialog()

TYPEINFO(/obj/submachine/seed_vendor)
	mats = 6

/obj/submachine/seed_vendor
	name = "Seed Fabricator"
	desc = "Fabricates basic plant seeds."
	icon = 'icons/obj/vending.dmi'
	icon_state = "seeds"
	density = 1
	anchored = ANCHORED
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WIRECUTTERS | DECON_MULTITOOL
	flags = TGUI_INTERACTIVE
	var/hacked = 0
	var/panelopen = 0
	var/malfunction = 0
	var/working = 1
	var/wires = 15
	var/can_vend = 1
	var/seedcount = 0
	var/maxseed = 25
	var/list/available = list()
	var/const
		WIRE_EXTEND = 1
		WIRE_MALF = 2
		WIRE_POWER = 3
		WIRE_INERT = 4

	New()
		..()
		for (var/A in concrete_typesof(/datum/plant)) src.available += new A(src)

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
		.["isWorking"] = src.working

	ui_static_data(mob/user)
		. = list()

		.["maxSeed"] = src.maxseed
		.["name"] = src.name

		// Start with associative list, where each key is a seed category
		var/list/categories = list()
		for(var/datum/plant/A in hydro_controls.vendable_plants)
			if (A.vending == 1 || src.hacked)
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


	ui_act(action, params)
		. = ..()
		if(. || action != "disp" || !src.can_vend || !src.working)
			return
		var/datum/plant/I = locate(text2path(params["path"])) in src.available

		if (!istype(I))
			return

		if(!I.vending)
			trigger_anti_cheat(usr, "tried to href exploit vend forbidden seed [I] on [src]")
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
			S.generic_seed_setup(I, FALSE)
			vend--
			src.seedcount++

		if(src.seedcount >= src.maxseed)
			src.can_vend = 0
			SPAWN(10 SECONDS)
				src.can_vend = 1
				src.seedcount = 0
		. = TRUE


	attack_hand(var/mob/user)
		. = ..()

		if (src.panelopen || isAI(user))
			src.add_dialog(user)
			var/list/fabwires = list(
			"Puce" = 1,
			"Mauve" = 2,
			"Ochre" = 3,
			"Slate" = 4,
			)
			var/pdat = "<B>[src.name] Maintenance Panel</B><hr>"
			for(var/wiredesc in fabwires)
				var/is_uncut = src.wires & APCWireColorToFlag[fabwires[wiredesc]]
				pdat += "[wiredesc] wire: "
				if(!is_uncut)
					pdat += "<a href='?src=\ref[src];cutwire=[fabwires[wiredesc]]'>Mend</a>"
				else
					pdat += "<a href='?src=\ref[src];cutwire=[fabwires[wiredesc]]'>Cut</a> "
					pdat += "<a href='?src=\ref[src];pulsewire=[fabwires[wiredesc]]'>Pulse</a> "
				pdat += "<br>"

			pdat += "<br>"
			pdat += "The yellow light is [(src.working == 0) ? "off" : "on"].<BR>"
			pdat += "The blue light is [src.malfunction ? "flashing" : "on"].<BR>"
			pdat += "The white light is [src.hacked ? "on" : "off"].<BR>"

			user.Browse(pdat, "window=fabpanel")
			onclose(user, "fabpanel")

	Topic(href, href_list)
		if(BOUNDS_DIST(usr, src) > 0 && !issilicon(usr) && !isAI(usr))
			boutput(usr, SPAN_ALERT("You need to be closer to the vendor to do that!"))
			return

		if ((href_list["cutwire"]) && (src.panelopen || isAI(usr)))
			var/twire = text2num_safe(href_list["cutwire"])
			if (!usr.find_tool_in_hand(TOOL_SNIPPING))
				boutput(usr, "You need a snipping tool!")
				return
			else if (src.isWireColorCut(twire)) src.mend(twire, usr)
			else src.cut(twire, usr)
			src.updateUsrDialog()

		if ((href_list["pulsewire"]) && (src.panelopen || isAI(usr)))
			var/twire = text2num_safe(href_list["pulsewire"])
			if (!usr.find_tool_in_hand(TOOL_PULSING) && !isAI(usr))
				boutput(usr, "You need a multitool or similar!")
				return
			else if (src.isWireColorCut(twire))
				boutput(usr, "You can't pulse a cut wire.")
				return
			else src.pulse(twire, usr)
			src.updateUsrDialog()

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.hacked)
			if(user)
				boutput(user, SPAN_NOTICE("You disable the [src]'s product locks!"))
			src.hacked = 1
			src.name = "Feed Sabricator"
			update_static_data(user)
			src.updateUsrDialog()
			return 1
		else
			if(user)
				boutput(user, "The [src] is already unlocked!")
			return 0

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W))
			if (!src.panelopen)
				src.overlays += image('icons/obj/vending.dmi', "grife-panel")
				src.panelopen = 1
			else
				src.overlays = null
				src.panelopen = 0
			boutput(user, "You [src.panelopen ? "open" : "close"] the maintenance panel.")
			src.updateUsrDialog()
		else if (src.panelopen && (issnippingtool(W) || ispulsingtool(W)))
			src.Attackhand(user)
		else ..()

	proc/isWireColorCut(var/wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		return ((src.wires & wireFlag) == 0)

	proc/isWireCut(var/wireIndex)
		var/wireFlag = APCIndexToFlag[wireIndex]
		return ((src.wires & wireFlag) == 0)

	proc/cut(var/wireColor, var/mob/user as mob)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor]
		src.wires &= ~wireFlag
		switch(wireIndex)
			if(WIRE_EXTEND)
				src.hacked = 0
				src.name = "Seed Fabricator"
				update_static_data(user)
			if(WIRE_MALF) src.malfunction = 1
			if(WIRE_POWER) src.working = 0

	proc/mend(var/wireColor, var/mob/user as mob)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor]
		src.wires |= wireFlag
		switch(wireIndex)
			if(WIRE_MALF) src.malfunction = 0

	proc/pulse(var/wireColor, var/mob/user as mob)
		var/wireIndex = APCWireColorToIndex[wireColor]
		switch(wireIndex)
			if(WIRE_EXTEND)
				if (src.hacked)
					src.hacked = 0
					src.name = "Seed Fabricator"
				else
					src.hacked = 1
					src.name = "Feed Sabricator"
				update_static_data(user)
			if (WIRE_MALF)
				if (src.malfunction) src.malfunction = 0
				else src.malfunction = 1
			if (WIRE_POWER)
				if (src.working) src.working = 0
				else src.working = 1


TYPEINFO(/obj/submachine/seed_manipulator/kudzu)
	mats = 0

/obj/submachine/seed_manipulator/kudzu
	name = "KudzuMaster V1"
	desc = "A strange \"machine\" that seems to function via fluids and plant fibers."
	deconstruct_flags = DECON_NONE
	icon = 'icons/misc/kudzu_plus.dmi'
	icon_state = "seed-gene-console"
	_health = 1

	disposing()
		var/turf/T = get_turf(src)
		for (var/obj/O in seeds)
			O.set_loc(T)
		src.visible_message(SPAN_ALERT("All the seeds spill out of [src]!"))
		..()
	attack_ai(var/mob/user as mob)
		return 0

	attack_hand(var/mob/user)
		if (iskudzuman(user))
			..()
		else
			boutput(user, SPAN_NOTICE("You stare at the bit that looks most like a screen, but you can't make heads or tails of what it's saying.!"))

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
				user.visible_message(SPAN_ALERT("[user] savagely attacks [src] with [W]!"))
			else
				user.visible_message(SPAN_ALERT("[user] savagely attacks [src] with [W], destroying it!"))
				qdel(src)
				return
		..()
