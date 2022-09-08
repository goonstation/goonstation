/obj/submachine/seed_manipulator/
	name = "PlantMaster Mk3"
	desc = "An advanced machine used for manipulating the genes of plant seeds. It also features an inbuilt seed extractor."
	density = 1
	anchored = 1
	mats = 10
	icon = 'icons/obj/objects.dmi'
	icon_state = "geneman-on"
	flags = NOSPLASH | FPRINT
	event_handler_flags = NO_MOUSEDROP_QOL
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	var/mode = "overview"
	var/list/seeds = list()
	var/seedfilter = null
	var/seedoutput = 1
	var/dialogue_open = 0
	var/obj/item/seed/splicing1 = null
	var/obj/item/seed/splicing2 = null
	var/list/extractables = list()
	var/obj/item/reagent_containers/glass/inserted = null
	var/const/genes_header = {"
							<th><abbr title="Plant species">Type</abbr></th>
							<th class="genes"><abbr title="Genome">GN</abbr></th>
							<th class="genes"><abbr title="Generation">Gen</abbr></th>
							<th class="genes"><abbr title="Maturity Rate (how fast the plant reaches maturity)">MR<sup>?</sup></abbr></th>
							<th class="genes"><abbr title="Production Rate (how fast the plant produces harvests)">PR<sup>?</sup></abbr></th>
							<th class="genes"><abbr title="Lifespan (how many harvests it gives; higher is better)">LS<sup>?</sup></abbr></th>
							<th class="genes"><abbr title="Yield (how many crops are produced per harvest; higher is better)">Y<sup>?</sup></abbr></th>
							<th class="genes"><abbr title="Potency (how potent crops are; higher is better)">P<sup>?</sup></abbr></th>
							<th class="genes"><abbr title="Endurance (how resilient to damage the plant is; higher is better)">E<sup>?</sup></abbr></th>
							"}
	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	attack_hand(var/mob/user)
		src.add_dialog(user)

		//var/header_thing_chui_toggle = (user.client && !user.client.use_chui) ? "<html><head><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\"><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><meta http-equiv=\"pragma\" content=\"no-cache\"><style type='text/css'>body { font-family: Tahoma, sans-serif; font-size: 10pt; }</style></head><body>" : ""
		var/dat = list()
		dat += {"
			<style type="text/css">.l { text-align: left; } .r { text-align: right; } .c { text-align: center; } .hyp-dominant { font-weight: bold; background-color: rgba(160, 160, 160, 0.33);} .buttonlink { background: #66c; width: 1.1em; height: 1.2em; padding: 0.2em 0.2em; margin-bottom: 2px; border-radius: 4px; font-size: 90%; color: white; text-decoration: none; display: inline-block; vertical-align: middle; } .genes { min-width: 2em; } table { width: 100%; } td, th { border-bottom: 1px solid rgb(160, 160, 160); padding: 0.1em 0.2em; } .splicing { background-color: rgba(0, 255, 0, 0.5); } thead { background: rgba(160, 160, 160, 0.6); } abbr { text-decoration: underline; } .buttonlinks { white-space: nowrap; padding: 0; text-align: center; } </style>
			<h3 style='margin: 0;'>[src.name]</h3>
			<div style="float: right;">
				[src.inserted ? "<a href='?src=\ref[src];ejectbeaker=1' class='buttonlink'>&#9167;</a> [src.inserted] ([src.inserted.reagents.total_volume]/[src.inserted.reagents.maximum_volume]) &bull; " : "" ]
				[src.extractables.len > 0 ? "<a href='?src=\ref[src];ejectextractables=1' class='buttonlink'>&#9167;</a> " : "" ][src.extractables.len] extractable\s &bull;
				[src.seeds.len > 0 ? "<a href='?src=\ref[src];ejectseeds=1' class='buttonlink'>&#9167;</a> " : "" ][src.seeds.len] seed\s
			</div>
			<strong><a href='?src=\ref[src];page=1'>Overview</a> &bull; <a href='?src=\ref[src];page=2'>Seed Extraction</a> &bull; <a href='?src=\ref[src];page=3'>Seed List</a></strong>
			<hr>
		"}
		if (src.mode == "overview")
			dat += "<b><u>Overview</u></b><br><br>"

			if (src.inserted)
				dat += "<B>Receptacle:</B> [src.inserted] ([src.inserted.reagents.total_volume]/[src.inserted.reagents.maximum_volume]) <A href='?src=\ref[src];ejectbeaker=1'>(Eject)</A><BR>"
				dat += "<b>Contents:</b> "
				if(src.inserted.reagents.reagent_list.len)
					for(var/current_id in inserted.reagents.reagent_list)
						var/datum/reagent/current_reagent = inserted.reagents.reagent_list[current_id]
						dat += "<BR><i>[current_reagent.volume] units of [current_reagent.name]</i>"
				else
					dat += "Empty"
			else
				dat += "<B>No receptacle inserted!</B>"

			dat += "<br>"

			if(src.seeds.len)
				dat += "<BR><B>[src.seeds.len] Seeds Ready for Experimentation</B>"
			else
				dat += "<BR><B>No Seeds inserted!</B>"

			dat += "<br>"

			if(src.extractables.len)
				dat += "<BR><B>[src.extractables.len] Items Ready for Extraction</B>"
			else
				dat += "<BR><B>No Extractable Produce inserted!</B>"

		else if (src.mode == "extraction")
			dat += "<b><u>Seed Extraction</u></b><br>"
			if (src.seedoutput)
				dat += "<A href='?src=\ref[src];outputmode=1'>Extracted seeds will be ejected from the machine.</A>"
			else
				dat += "<A href='?src=\ref[src];outputmode=1'>Extracted seeds will be retained within the machine.</A>"
			dat += {"<br><br>
				<table>
					<thead>
					<tr>
						<th colspan="2">Name</th>
						<th colspan='1'>Controls</th>
						[genes_header]
					</tr>
					</thead>
					<tbody>
				"}

			if(src.extractables.len)
				for (var/obj/item/I in src.extractables)
					var/geneout = ""
					if (istype(I, /obj/item/seed))
						var/obj/item/seed/S = I
						geneout = QuickAnalysisRow(S, S.planttype, S.plantgenes)
					else if (istype(I, /obj/item/reagent_containers/food/snacks/plant))
						var/obj/item/reagent_containers/food/snacks/plant/S = I
						geneout = QuickAnalysisRow(S, S.planttype, S.plantgenes)

					dat += {"
					<tr>
						<td class='buttonlinks'><a href='?src=\ref[src];label=\ref[I]' title='Rename' class='buttonlink'>&#9998;</a>
						<a href='?src=\ref[src];analyze=\ref[I]' title='Analyze' class='buttonlink'>&#128269;</a>
						<a href='?src=\ref[src];eject=\ref[I]' title='Eject' class='buttonlink'>&#9167;</a></td>
						<th class='l'>[I.name]</th>
						<td><a href='?src=\ref[src];extract=\ref[I]'>Extract</a></td>
						[geneout]
					</tr>

					"}
			else
				dat += "<tr><th colspan='12'>No extractable produce inserted!</th></tr>"
			dat += "</table>"

		else if (src.mode == "seedlist")
			dat += "<b><u>Seed List</u></b><br>"
			if (src.seedfilter)
				dat += "<b><A href='?src=\ref[src];filter=1'>Filter:</A></b> \"[src.seedfilter]\"<br>"
			else
				dat += "<b><A href='?src=\ref[src];filter=1'>Filter:</A></b> None<br>"
			dat += "<br>"

			var/allow_infusion = 0
			if (src.inserted)
				if (src.inserted.reagents.total_volume) allow_infusion = 1

			dat += {"
				<table>
					<thead>
					<tr>
						<th colspan="2">Name</th>
						<th>Damage</th>
						<th colspan='2'>Controls</th>
						[genes_header]
					</tr>
					</thead>
					<tbody>
					"}
			if(src.seeds.len)
				for (var/obj/item/seed/S in src.seeds)
					if (!src.seedfilter || findtext(src.seedfilter, S.name, 1, null))
						dat += {"
							<tr [S == src.splicing1 ? "class='splicing'" : ""]>
								<td class='buttonlinks'><a href='?src=\ref[src];label=\ref[S]' title='Rename' class='buttonlink'>&#9998;</a>
								<a href='?src=\ref[src];analyze=\ref[S]' title='Analyze' class='buttonlink'>&#128269;</a>
								<a href='?src=\ref[src];eject=\ref[S]' title='Eject' class='buttonlink'>&#9167;</a></td>
								<th class='l'>[S.name]</th>
								<td class='r'>[S.seeddamage]%</td>
								<td class='c'>[S == src.splicing1 ? "<a href='?src=\ref[src];splice_cancel=1'>Cancel</a>" : "<a href='?src=\ref[src];splice_select=\ref[S]'>Splice</a>"]</td>
								<td class='c'>[allow_infusion ? "<a href='?src=\ref[src];infuse=\ref[S]'>Infuse</a>" : "Infuse"]</td>
								[QuickAnalysisRow(S, S.planttype, S.plantgenes)]
							</tr>
						"}
					else
						continue
			else
				dat += "<tr><th colspan='12'>No seeds inserted!</th></tr>"

			dat += "</tbody></table>"

		else if (src.mode == "splicing")
			if (src.splicing1 && src.splicing2)
				dat += {"<b><u>Seed Splicing</u></b><br>
				<table>
					<thead>
					<tr>
						<th>Seed</th>
						[genes_header]
					</tr>
					</thead>
					<tbody>
					<tr>
						<th class='l'><a href='?src=\ref[src];analyze=\ref[src.splicing1]'>[src.splicing1]</a></th>
						[QuickAnalysisRow(src.splicing1, src.splicing1.planttype, src.splicing1.plantgenes)]
					</tr>
					<tr>
						<th class='l'><a href='?src=\ref[src];analyze=\ref[src.splicing2]'>[src.splicing2]</a></th>
						[QuickAnalysisRow(src.splicing2, src.splicing2.planttype, src.splicing2.plantgenes)]
					</tr>
					</tbody>
				</table>
				"}

				var/splice_chance = 100
				var/datum/plant/P1 = src.splicing1.planttype
				var/datum/plant/P2 = src.splicing2.planttype

				var/genome_difference = abs(P1.genome - P2.genome)
				splice_chance -= genome_difference * 10

				splice_chance -= src.splicing1.seeddamage
				splice_chance -= src.splicing2.seeddamage

				if (src.splicing1.plantgenes.commuts)
					for (var/datum/plant_gene_strain/splicing/S in src.splicing1.plantgenes.commuts)
						if (S.negative)
							splice_chance -= S.splice_mod
						else
							splice_chance += S.splice_mod

				if (src.splicing2.plantgenes.commuts)
					for (var/datum/plant_gene_strain/splicing/S in src.splicing2.plantgenes.commuts)
						if (S.negative)
							splice_chance -= S.splice_mod
						else
							splice_chance += S.splice_mod

				splice_chance = clamp(splice_chance, 0, 100)

				dat += "<b>Chance of Successful Splice:</b> [splice_chance]%<br>"
				dat += "<A href='?src=\ref[src];splice=1'>(Proceed)</A> <A href='?src=\ref[src];splice_cancel=1'>(Cancel)</A><BR>"
				if (src.seedoutput)
					dat += "<A href='?src=\ref[src];outputmode=1'>New seeds will be ejected from the machine.</A>"
				else
					dat += "<A href='?src=\ref[src];outputmode=1'>New seeds will be retained within the machine.</A>"

			else
				dat += {"<b>Splice Error.</b><br>
				<A href='?src=\ref[src];page=3'>Please click here to return to the Seed List.</A>"}
		else
			dat += {"<b>Software Error.</b><br>
			<A href='?src=\ref[src];page=1'>Please click here to return to the Overview.</A>"}

		dat += {"<hr>
		Genetic display key: <span class='hyp-dominant'>Dominant</span> / Recessive
		"}

		user.Browse(jointext(dat, ""), "window=plantmaster;size=800x400")
		onclose(user, "rextractor")

	Topic(href, href_list)
		if((BOUNDS_DIST(usr, src) > 0) && !issilicon(usr) && !isAI(usr))
			boutput(usr, "<span class='alert'>You need to be closer to the machine to do that!</span>")
			return
		if(href_list["page"])
			var/ops = text2num_safe(href_list["page"])
			switch(ops)
				if(2) src.mode = "extraction"
				if(3) src.mode = "seedlist"
				else src.mode = "overview"
			playsound(src.loc, "sound/machines/click.ogg", 50, 1)
			src.updateUsrDialog()

		else if(href_list["ejectbeaker"])
			var/obj/item/I = src.inserted
			if (!I) boutput(usr, "<span class='alert'>No receptacle found to eject.</span>")
			else
				I.set_loc(src.loc) // causes Exited proc to be called
				usr.put_in_hand_or_eject(I) // try to eject it into the users hand, if we can

		else if(href_list["ejectseeds"])
			for (var/obj/item/seed/S in src.seeds)
				src.seeds.Remove(S)
				S.set_loc(src.loc)
				usr.put_in_hand_or_eject(S) // try to eject it into the users hand, if we can

			src.updateUsrDialog()

		else if(href_list["ejectextractables"])
			for (var/obj/item/I in src.extractables)
				src.extractables.Remove(I)
				I.set_loc(src.loc)
				usr.put_in_hand_or_eject(I) // try to eject it into the users hand, if we can

			src.updateUsrDialog()

		else if(href_list["eject"])
			var/obj/item/I = locate(href_list["eject"]) in src
			if (!istype(I))
				return
			if (istype(I,/obj/item/seed)) src.seeds.Remove(I)
			else src.extractables.Remove(I)
			if(I == src.splicing1)
				src.splicing1 = null
			if(I == src.splicing2)
				src.splicing2 = null
			I.set_loc(src.loc)
			usr.put_in_hand_or_eject(I) // try to eject it into the users hand, if we can
			src.updateUsrDialog()

		else if(href_list["label"])
			var/obj/item/I = locate(href_list["label"]) in src
			if (istype(I) && !isghostdrone(usr) && !isghostcritter(usr))
				var/newName = copytext(strip_html(input(usr,"What do you want to label [I.name]?","[src.name]",I.name) ),1, 129)
				if(newName && newName != I.name)
					phrase_log.log_phrase("seed", newName, no_duplicates=TRUE)
				if (newName && I && GET_DIST(src, usr) < 2)
					I.name = newName
			src.updateUsrDialog()

		else if(href_list["filter"])
			src.seedfilter = copytext(strip_html(input(usr,"Search for seeds by name? (Enter nothing to clear filter)","[src.name]",null)), 1, 257)
			src.updateUsrDialog()

		else if(href_list["analyze"])
			var/obj/item/I = locate(href_list["analyze"]) in src
			playsound(src.loc, "sound/machines/click.ogg", 50, 1)

			if (istype(I,/obj/item/seed/))
				var/obj/item/seed/S = I
				if (!istype(S.planttype,/datum/plant/) || !istype(S.plantgenes,/datum/plantgenes/))
					boutput(usr, "<span class='alert'>Genetic structure of seed corrupted. Cannot scan.</span>")
				else
					HYPgeneticanalysis(usr,S,S.planttype,S.plantgenes)

			else if (istype(I,/obj/item/reagent_containers/food/snacks/plant/))
				var/obj/item/reagent_containers/food/snacks/plant/P = I
				if (!istype(P.planttype,/datum/plant/) || !istype(P.plantgenes,/datum/plantgenes/))
					boutput(usr, "<span class='alert'>Genetic structure of item corrupted. Cannot scan.</span>")
				else
					HYPgeneticanalysis(usr,P,P.planttype,P.plantgenes)

			else
				boutput(usr, "<span class='alert'>Item cannot be scanned.</span>")
			src.updateUsrDialog()

		else if(href_list["outputmode"])
			src.seedoutput = !src.seedoutput
			src.updateUsrDialog()

		else if(href_list["extract"])
			var/obj/item/I = locate(href_list["extract"]) in src
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
					boutput(usr, "<span class='alert'>No viable seeds found in [I].</span>")
				else
					boutput(usr, "<span class='notice'>Extracted [give] seeds from [I].</span>")
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

			else
				boutput(usr, "<span class='alert'>This item is not viable extraction produce.</span>")
			src.updateUsrDialog()

		else if(href_list["splice_select"])
			playsound(src, "sound/machines/keypress.ogg", 50, 1)
			var/obj/item/I = locate(href_list["splice_select"]) in src
			if (!istype(I))
				return
			if (src.splicing1)
				if (I == src.splicing1)
					src.splicing1 = null
				else
					src.splicing2 = I
					src.mode = "splicing"
			else
				src.splicing1 = I
			src.updateUsrDialog()

		else if(href_list["splice_cancel"])
			playsound(src, "sound/machines/keypress.ogg", 50, 1)
			src.splicing1 = null
			src.splicing2 = null
			src.mode = "seedlist"
			src.updateUsrDialog()

		else if(href_list["infuse"])
			if (dialogue_open)
				return
			var/obj/item/seed/S = locate(href_list["infuse"]) in src
			if (!istype(S))
				return
			if (!src.inserted)
				boutput(usr, "<span class='alert'>No reagent container available for infusions.</span>")
			else
				if (src.inserted.reagents.total_volume < 10)
					boutput(usr, "<span class='alert'>You require at least ten units of a reagent to infuse a seed.</span>")
				else
					var/list/usable_reagents = list()
					var/datum/reagent/R = null
					for(var/current_id in src.inserted.reagents.reagent_list)
						var/datum/reagent/current_reagent = src.inserted.reagents.reagent_list[current_id]
						if (current_reagent.volume >= 10) usable_reagents += current_reagent

					if (!usable_reagents.len)
						boutput(usr, "<span class='alert'>You require at least ten units of a reagent to infuse a seed.</span>")
					else
						dialogue_open = 1
						R = input(usr, "Use which reagent to infuse the seed?", "[src.name]", 0) in usable_reagents
						if (!R || !S)
							return
						switch(S.HYPinfusionS(R.id,src))
							if (1)
								playsound(src, "sound/machines/seed_destroyed.ogg", 50, 1)
								boutput(usr, "<span class='alert'>ERROR: Seed has been destroyed.</span>")
							if (2)
								playsound(src, "sound/machines/buzz-sigh.ogg", 50, 1)
								boutput(usr, "<span class='alert'>ERROR: Reagent lost.</span>")
							if (3)
								playsound(src, "sound/machines/buzz-sigh.ogg", 50, 1)
								boutput(usr, "<span class='alert'>ERROR: Unknown error. Please try again.</span>")
							else
								playsound(src, "sound/effects/zzzt.ogg", 50, 1)
								boutput(usr, "<span class='notice'>Infusion of [R.name] successful.</span>")
						src.inserted.reagents.remove_reagent(R.id,10)
						dialogue_open = 0

			src.updateUsrDialog()

		else if(href_list["splice"])
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
				// Seeds from different families aren't easy to splice
				var/genome_difference = abs(P1.genome - P2.genome)
				splice_chance -= genome_difference * 10

				// Deduct chances if the seeds are damaged from infusing or w/e else
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

			// Cap probability between 0 and 100
			splice_chance = clamp(splice_chance, 0, 100)
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

				// Set up the base variables first
				/*
				if (!dominantspecies.hybrid)
					P.name = "Hybrid [dominantspecies.name]"
				else
					// Just making sure we dont get hybrid hybrid hybrid tomato seed or w/e
					P.name = "[dominantspecies.name]"
					*/
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
				playsound(src, "sound/machines/ping.ogg", 50, 1)
				//0 xp for a 100% splice, 4 xp for a 10% splice
				JOB_XP(usr, "Botanist", clamp(round((100 - splice_chance) / 20), 0, 4))
				if (!src.seedoutput) src.seeds.Add(S)
				else S.set_loc(src.loc)

			else
				// It fucked up - we don't need to do anything else other than tell the user
				boutput(usr, "<span class='alert'>Splice failed.</span>")
				playsound(src, "sound/machines/seed_destroyed.ogg", 50, 1)

			// Now get rid of the old seeds and go back to square one
			src.seeds.Remove(seed1)
			src.seeds.Remove(seed2)
			src.splicing1 = null
			src.splicing2 = null
			qdel(seed1)
			qdel(seed2)
			src.mode = "seedlist"
			src.updateUsrDialog()

		else
			src.updateUsrDialog()

	attackby(var/obj/item/W, var/mob/user)
		if(istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/))
			if(src.inserted)
				boutput(user, "<span class='alert'>A container is already loaded into the machine.</span>")
				return
			src.inserted =  W
			user.drop_item()
			W.set_loc(src)
			boutput(user, "<span class='notice'>You add [W] to the machine!</span>")
			src.updateUsrDialog()

		else if(istype(W, /obj/item/reagent_containers/food/snacks/plant/) || istype(W, /obj/item/seed/))
			boutput(user, "<span class='notice'>You add [W] to the machine!</span>")
			user.u_equip(W)
			W.set_loc(src)
			if (istype(W, /obj/item/seed/)) src.seeds += W
			else src.extractables += W
			W.dropped(user)
			src.updateUsrDialog()
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
		else ..()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!O || !user)
			return
		if (!in_interact_range(src, user)  || BOUNDS_DIST(O, user) > 0)
			return
		if (!isitem(O))
			return
		if (istype(O, /obj/item/reagent_containers/glass/) || istype(O, /obj/item/reagent_containers/food/drinks/) || istype(O,/obj/item/satchel/hydro))
			return src.Attackby(O, user)
		if (istype(O, /obj/item/reagent_containers/food/snacks/plant/) || istype(O, /obj/item/seed/))
			user.visible_message("<span class='notice'>[user] begins quickly stuffing [O.name] into [src]!</span>")
			var/staystill = user.loc
			for(var/obj/item/P in view(1,user))
				sleep(0.2 SECONDS)
				if (!P) continue
				if (user.loc != staystill) break
				if (P.type == O.type)
					if (istype(O, /obj/item/seed/)) src.seeds.Add(P)
					else src.extractables.Add(P)
					P.set_loc(src)
				else continue
			boutput(user, "<span class='notice'>You finish stuffing items into [src]!</span>")
		else ..()

	proc/SpliceMK2(var/allele1,var/allele2,var/value1,var/value2)
		var/dominance = allele1 - allele2

		if (dominance > 0)
			return value1
		else if (dominance < 0)
			return value2
		else
			return round((value1 + value2)/2)

	proc/QuickAnalysisRow(var/obj/scanned, var/datum/plant/P, var/datum/plantgenes/DNA)
		// Largely copied from plantpot.dm
		if (!DNA) return

		var/generation = 0

		if (P.cantscan)
			return "<td colspan='9' class='c'>Can't scan!</td>"

		if (istype(scanned, /obj/item/seed/))
			var/obj/item/seed/S = scanned
			generation = S.generation
		if (istype(scanned, /obj/item/reagent_containers/food/snacks/plant/))
			var/obj/item/reagent_containers/food/snacks/plant/F = scanned
			generation = F.generation

		return {"
		<td class='l [DNA.d_species ? "hyp-dominant" : ""]'>[P.name]</td>
		<td class='r'>[P.genome]</td>
		<td class='r'>[generation]</td>
		<td class='r [DNA.d_growtime ? "hyp-dominant" : ""]'>[DNA.growtime]</td>
		<td class='r [DNA.d_harvtime ? "hyp-dominant" : ""]'>[DNA.harvtime]</td>
		<td class='r [DNA.d_cropsize ? "hyp-dominant" : ""]'>[DNA.harvests]</td>
		<td class='r [DNA.d_harvests ? "hyp-dominant" : ""]'>[DNA.cropsize]</td>
		<td class='r [DNA.d_potency ? "hyp-dominant" : ""]'>[DNA.potency]</td>
		<td class='r [DNA.d_endurance ? "hyp-dominant" : ""]'>[DNA.endurance]</td>
		"}

	Exited(Obj, newloc)
		if(Obj == src.inserted)
			src.inserted = null
			src.updateUsrDialog()

////// Reagent Extractor

/obj/submachine/chem_extractor/
	name = "reagent extractor"
	desc = "A machine which can extract reagents from matter. Has a slot for a beaker and a chute to put things into."
	density = 1
	anchored = 1
	mats = 6
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
			var/obj/item/reagent_containers/glass/thisContainer = containers[container_id]
			if(thisContainer)
				var/datum/reagents/R = thisContainer.reagents
				var/list/thisContainerData = list(
					name = thisContainer.name,
					id = container_id,
					maxVolume = R.maximum_volume,
					totalVolume = R.total_volume,
					selected = src.extract_to == thisContainer,
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
				containersData[container_id] = thisContainerData

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
		var/list/containers = src.getContainers()
		switch(action)
			if("ejectcontainer")
				var/obj/item/I = src.inserted
				if (!I)
					return
				if (I == src.extract_to) src.extract_to = null
				TRANSFER_OR_DROP(src, I) // causes Exited proc to be called
				usr.put_in_hand_or_eject(I)
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

	proc/tryInsert(var/obj/item/W, var/mob/user)
		if (isrobot(user))
			boutput(user, "This machine does not accept containers from robots!")
			return
		if(src.inserted)
			boutput(user, "<span class='alert'>A container is already loaded into the machine.</span>")
			return
		src.inserted =  W
		user.drop_item()
		W.set_loc(src)
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
		playsound(src, "sound/machines/chime.ogg", 10, 1)
		src.visible_message("<span class='alert'>[src]'s tank over-fill alarm burps!</span>")
		can_autoextract = FALSE

	if (can_autoextract)
		doExtract(incoming)
	else
		src.ingredients["[nextingredientkey++]"] = incoming
		tgui_process.update_uis(src)
		src.UpdateIcon()


/obj/submachine/seed_vendor
	name = "Seed Fabricator"
	desc = "Fabricates basic plant seeds."
	icon = 'icons/obj/vending.dmi'
	icon_state = "seeds"
	density = 1
	anchored = 1
	mats = 6
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
			S.generic_seed_setup(I)
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
			boutput(usr, "<span class='alert'>You need to be closer to the vendor to do that!</span>")
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
				boutput(user, "<span class='notice'>You disable the [src]'s product locks!</span>")
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


/obj/submachine/seed_manipulator/kudzu
	name = "KudzuMaster V1"
	desc = "A strange \"machine\" that seems to function via fluids and plant fibers."
	mats = 0
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
