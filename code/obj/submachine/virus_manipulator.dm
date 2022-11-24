// disease reagent manipulator thing

/obj/submachine/virus_manipulator
	name = "Virus Manipulator"
	desc = "A device which alters bacteria and virii."
	icon = 'icons/obj/objects.dmi'
	icon_state = "DAn-off"
	flags = NOSPLASH
	anchored = 1
	density = 1
	var/obj/item/reagent_containers/glass/vial/active_vial = null
	var/datavial = "No Vial Inserted"
	var/datareagent = "N/A"
	var/dataspread = "N/A"
	var/datacurable = "N/A"
	var/dataregress = "N/A"
	var/datavaccine = "N/A"
	var/datacure = "N/A"
	var/dataprob = "N/A"
	var/working = 0

	New()
		..()
		src.overlays += image('icons/obj/objects.dmi', "DAn-Oe")

	attack_ai(mob/user as mob)
		return src.Attackhand(user)

	attack_hand(var/mob/user)
		src.add_dialog(user)
		if (!src.working)
			var/dat = {"<B>Virus Manipulator</B><BR>
			<HR><BR>
			<B>Vial:</B> [datavial]<BR>
			<B>Vial Contents:</B> [datareagent]<BR>
			<HR><BR>
			<B>Contagion Vector:</B> [dataspread]<BR>
			<B>Strain Vulnerability:</B> [datacure]<BR>
			<B>Antibiotic Resistance:</B> [datacurable]<BR>
			<B>Immune System Resistance:</B> [dataregress]<BR>
			<B>Infection Development Rate:</B> [dataprob]<BR>
			<B>Crippled Infectiousness:</B> [datavaccine]<BR><BR>
			<HR><BR>
			<A href='?src=\ref[src];ops=1'>Attempt to Create Vaccine<BR>
			<A href='?src=\ref[src];ops=2'>Mutate<BR>
			<A href='?src=\ref[src];ops=3'>Refresh Report<BR>
			<A href='?src=\ref[src];ops=4'>Eject Vial"}
			user << browse(dat, "window=virusmanip;size=400x500")
			onclose(user, "virusmanip")
		else
			var/dat = {"<B>Virus Manipulator</B><BR>
			<HR><BR>
			<B>Please wait. Work in progress.</B><BR>"}
			user << browse(dat, "window=virusmanip;size=450x500")
			onclose(user, "virusmanip")

	Topic(href, href_list)
		if(href_list["ops"])
			var/operation = text2num_safe(href_list["ops"])
			if(operation == 1) // Attempt to Create Vaccine
				if (src.datareagent == "N/A" || src.datareagent == "No virii detected")
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<b>[]</b> states, 'Unable to begin process. No reagent detected.'", src), 1)
					return
				else if (src.datareagent == "Multiple virii detected")
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<b>[]</b> states, 'Unable to begin process. Excess reagents detected.'", src), 1)
					return
				src.working = 1
				src.icon_state = "DAn-on"
				for(var/mob/O in hearers(src, null))
					O.show_message(text("<b>[]</b> states, 'Commencing work.'", src), 1)
				if(src.active_vial.reagents && length(src.active_vial.reagents.reagent_list))
					for(var/current_id in src.active_vial.reagents.reagent_list)
						var/datum/reagent/disease/current_disease = src.active_vial.reagents.reagent_list[current_id]
						if(istype(current_disease))
							if(prob(50))
								current_disease.Rvaccine = rand(0,1)
								if (current_disease.Rvaccine) src.datavaccine = "Yes"
								else src.datavaccine = "No"

				SPAWN(rand(100,150))
					src.working = 0
					src.icon_state = "DAn-off"
					var/vacannounce
					if (src.datavaccine == "Yes") vacannounce = "Vaccine created successfully"
					else vacannounce = "Failed to create vaccine"
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<b>[]</b> states, '[].'", src, vacannounce), 1)
					src.updateUsrDialog()
			if(operation == 2) // Mutate
				if (src.datareagent == "N/A" || src.datareagent == "No virii detected")
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<b>[]</b> states, 'Unable to begin process. No reagent detected.'", src), 1)
					return
				else if (src.datareagent == "Multiple virii detected")
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<b>[]</b> states, 'Unable to begin process. Excess reagents detected.'", src), 1)
					return
				src.working = 1
				src.icon_state = "DAn-on"
				for(var/mob/O in hearers(src, null))
					O.show_message(text("<b>[]</b> states, 'Commencing work.'", src), 1)
				if(src.active_vial.reagents.reagent_list.len)
					for(var/current_id in active_vial.reagents.reagent_list)
						var/datum/reagent/disease/current_disease = active_vial.reagents.reagent_list[current_id]

						if(istype(current_disease))
							if(prob(40))
								current_disease.Rspread = "Non-Contagious"
								if (prob(20)) current_disease.Rspread = "Contact"
								if (prob(10)) current_disease.Rspread = "Airborne"
								src.dataspread = current_disease.Rspread
							if(prob(40))
								current_disease.Rcure = pick("Sleep", "Antibiotics", "Self-Curing")
								if(prob(10)) current_disease.Rcure = pick("Beatings", "Burnings", "Electric Shock")
								if(rand(1,5000) == 1) current_disease.Rcure = "Incurable"
								src.datacure = current_disease.Rcure
							if(prob(50))
								current_disease.Rcurable = rand(0,1)
								if (current_disease.Rcurable) src.datacurable = "No"
								else src.datacurable = "Yes"
							if(prob(50))
								current_disease.Rregress = rand(0,1)
								if (current_disease.Rregress) src.dataregress = "No"
								else src.dataregress = "Yes"
							if(prob(50))
								current_disease.Rprob = rand(-3,3)
								src.dataprob = current_disease.Rprob
				SPAWN(rand(100,150))
					src.working = 0
					src.icon_state = "DAn-off"
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<b>[]</b> states, 'Work complete.'", src), 1)
					src.updateUsrDialog()
			if(operation == 3) // Refresh Report
				if (src.active_vial) src.datavial = src.active_vial.name
				else
					src.datavial = "No Vial Inserted"
					src.datareagent = "N/A"
					src.dataspread = "N/A"
					src.datacure = "N/A"
					src.datacurable = "N/A"
					src.dataregress = "N/A"
					src.datavaccine = "N/A"
					src.dataprob = "N/A"
					src.updateUsrDialog()
					return
				var/reagcount = 0
				if(src.active_vial.reagents.reagent_list.len)
					for(var/current_id in active_vial.reagents.reagent_list)
						var/datum/reagent/disease/current_disease = active_vial.reagents.reagent_list[current_id]

						if(istype(current_disease))
							reagcount++

							src.datareagent = current_disease.name
							src.dataspread = current_disease.Rspread
							src.datacure = current_disease.Rcure
							if (current_disease.Rcurable) src.datacurable = "No"
							else src.datacurable = "Yes"
							if (current_disease.Rregress) src.dataregress = "No"
							else src.dataregress = "Yes"
							if (current_disease.Rvaccine) src.datavaccine = "Yes"
							else src.datavaccine = "No"

					if (reagcount > 1)
						src.datareagent = "Multiple virii detected"
						src.dataspread = "N/A"
						src.datacure = "N/A"
						src.dataprob = "N/A"
						src.datacurable = "N/A"
						src.dataregress = "N/A"
						src.datavaccine = "N/A"
				else
					src.datareagent = "No virii detected"
					src.dataspread = "N/A"
					src.datacure = "N/A"
					src.dataprob = "N/A"
					src.datacurable = "N/A"
					src.dataregress = "N/A"
					src.datavaccine = "N/A"
				src.updateUsrDialog()
			if(operation == 4) // Eject Vial
				var/log_reagents = ""
				if(src.active_vial && src.active_vial.reagents)
					for(var/reagent_id in src.active_vial.reagents.reagent_list)
						log_reagents += " [reagent_id]"

				logTheThing(LOG_CHEMISTRY, usr, "modified <i>(<b>[log_reagents]</b>)</i> to [src.dataspread], cure = [src.datacure], curable = [src.datacurable], regress = [src.dataregress], speed =[src.dataprob], vaccine = [src.datavaccine]")
				for(var/obj/item/reagent_containers/glass/vial/V in src.contents)
					V.set_loc(get_turf(src))
				src.active_vial = null
				src.datavial = "No Vial Inserted"
				src.datareagent = "N/A"
				src.dataspread = "N/A"
				src.datacure = "N/A"
				src.dataprob = "N/A"
				src.datacurable = "N/A"
				src.dataregress = "N/A"
				src.datavaccine = "N/A"
				src.overlays -= image('icons/obj/objects.dmi', "DAn-Of")
				src.overlays += image('icons/obj/objects.dmi', "DAn-Oe")
				src.updateUsrDialog()
			src.updateUsrDialog()

	attackby(var/obj/item/W, var/mob/user)
		if (src.working)
			boutput(user, "<span class='alert'>The manipulator is busy!</span>")
			return
		if(istype(W, /obj/item/reagent_containers/glass/vial))
			if(src.active_vial)
				boutput(user, "<span class='alert'>A vial is already loaded into the manipulator.</span>")
				return
			boutput(user, "<span class='notice'>You add the [W] to the manipulator!</span>")
			src.datavial = W.name
			src.active_vial = W
			user.drop_item()
			W.set_loc(src)
			src.overlays -= image('icons/obj/objects.dmi', "DAn-Oe")
			src.overlays += image('icons/obj/objects.dmi', "DAn-Of")
			src.updateUsrDialog()
			var/reagcount = 0
			if(src.active_vial.reagents.reagent_list.len)
				for(var/current_id in active_vial.reagents.reagent_list)
					var/datum/reagent/disease/current_disease = active_vial.reagents.reagent_list[current_id]

					if(istype(current_disease))
						reagcount++

						src.datareagent = current_disease.name
						src.dataspread = current_disease.Rspread
						src.datacure = current_disease.Rcure
						src.dataprob = current_disease.Rprob
						if (current_disease.Rcurable) src.datacurable = "No"
						else src.datacurable = "Yes"
						if (current_disease.Rregress) src.dataregress = "No"
						else src.dataregress = "Yes"
						if (current_disease.Rvaccine) src.datavaccine = "Yes"
						else src.datavaccine = "No"
				if (reagcount > 1)
					src.datareagent = "Multiple virii detected"
					src.dataspread = "N/A"
					src.datacurable = "N/A"
					src.dataregress = "N/A"
					src.datavaccine = "N/A"
			else
				src.datareagent = "No virii detected"
				src.dataspread = "N/A"
				src.datacure = "N/A"
				src.dataprob = "N/A"
				src.datacurable = "N/A"
				src.dataregress = "N/A"
				src.datavaccine = "N/A"
		else
			boutput(user, "<span class='alert'>The manipulator cannot accept that!</span>")
			return
