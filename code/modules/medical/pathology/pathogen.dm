#define COOLDOWN_MULTIPLIER 1

#define INFECT_NONE 0
#define INFECT_TOUCH 1
#define INFECT_AREA 3
#define INFECT_AREA_LARGE 5

// --SYMPTOM RARITIES--
// All symptom contains a rarity value. Use these constants to describe their rarity.
// For malevolent symptoms:
// RARITY_VERY_COMMON: The symptoms are barely noticable. Should not affect gameplay significantly or infect in a large area.
// RARITY_COMMON: The symptoms are noticeable, and may cause occasional inconveniences. May infect in a large area (instead).
// RARITY_UNCOMMON: The symptoms may do occasional damage or longer stuns.
// RARITY_RARE: The symptoms have a ramp in stages from relatively mundane to rather deadly.
// RARITY_VERY_RARE: You are fucked.
// For benevolent symptoms:
// RARITY_VERY_COMMON: As for malevolents, except in the positive direction obviously.
// RARITY_COMMON: The symptom may heal slightly or give an insignificant boost to any statistic.
// RARITY_UNCOMMON: Commonly symptoms which may give you an upper hand in a fight.
// RARITY_RARE: Power-healing and heavy offense/defense symptoms. May contain downsides.
// RARITY_VERY_RARE: God complex with actual godlike powers, traitor items infused in body. Should contain flipsides.
// And for all:
// RARITY_ABSTRACT: Used strictly for categorization. ABSTRACT symptoms will never appear.
//                  ie. if lingual is a symptom category with multiple subsymptoms (for easy mutex), it should be abstract.
#define RARITY_VERY_COMMON 1
#define RARITY_COMMON 2
#define RARITY_UNCOMMON 3
#define RARITY_RARE 4
#define RARITY_VERY_RARE 5
#define RARITY_ABSTRACT 0

datum/pathogen_cdc
	var/uid = null
	var/patient_zero = null
	var/patient_zero_kname = ""
	var/creation_time = null
	var/microbody_type = null

	var/list/infections = list()
	var/list/mutations = list()

	New(var/pathogen_uid)
		..()
		creation_time = world.time / 600
		src.uid = pathogen_uid

datum/controller/pathogen
	var/list/next_mutation = new/list()
	var/list/pathogen_trees = new/list()
	var/next_uid = 1

	var/list/UID_to_symptom
	var/list/symptom_to_UID
	var/list/UID_to_suppressant
	var/list/suppressant_to_UID
	var/list/microbody_to_UID
	var/list/UID_to_carrier
	var/list/carrier_to_UID

	var/list/path_to_symptom = list()
	var/list/path_to_microbody = list()
	var/list/path_to_suppressant = list()
	var/list/path_to_mutation = list()
	var/list/disabled_mutations = list()

	var/list/pathogen_affected_reagents = list("blood", "pathogen", "bloodc")

	var/list/microbody_choices = list()
	var/choicemax = 0

	var/list/l_vc
	var/list/l_c
	var/list/l_u
	var/list/l_r
	var/list/l_vr

	var/list/lnums = list()
	var/list/lalph = list()

	var/list/nutrients = list()
	var/list/media = list()
	var/list/cure_bases = list()

	proc/get_microbody(var/strength)
		var/datum/microbody/M
		var/finished = 0
		var/tried = 0
		while (!finished)
			var/choice = rand(1, choicemax)
			for (var/datum/choice/C in microbody_choices)
				if (C.min <= choice && choice <= C.max)
					M = C.target
			if (M.strength <= strength)
				finished = 1
			else
				tried++
				if (tried > 10)
					return M
		return M

	proc/mob_infected(var/datum/pathogen/P, var/mob/living/carbon/human/H)
		var/datum/pathogen_cdc/CDC = src.pathogen_trees[P.name_base]
		if (!CDC)
			return
		if (!CDC.patient_zero)
			CDC.patient_zero = H
			CDC.patient_zero_kname = "[H]"
		if (!(P.name in CDC.mutations))
			CDC.mutations += P.name
			var/datum/pathogen/template = new /datum/pathogen
			template.setup(0, P, 0)
			CDC.mutations[P.name] = template
		if (!(H in CDC.infections))
			CDC.infections += H
		CDC.infections[H] = P.name

	proc/mob_cured(var/datum/pathogen/P, var/mob/living/carbon/human/H)
		var/datum/pathogen_cdc/CDC = src.pathogen_trees[P.name_base]
		if (!CDC)
			return
		if (H in CDC.infections)
			CDC.infections -= H
		P.oncured()

	proc/patient_zero(var/datum/pathogen_cdc/CDC, var/topic_holder)
		if (CDC.patient_zero)
			return replacetext(CDC.patient_zero_kname, "%holder%", "\ref[topic_holder]")

	Topic(href, href_list)
		USR_ADMIN_ONLY
		var/key = usr.ckey
		var/th = locate(href_list["topic_holder"])
		switch(href_list["action"])
			if ("setstate")
				cdc_state[key] = text2num_safe(href_list["state"])
			if ("strain_cure")
				var/strain = href_list["strain"]
				var/datum/pathogen_cdc/CDC = pathogen_trees[strain]
				var/count = 0
				for (var/mob/living/carbon/human/H in mobs)
					LAGCHECK(LAG_LOW)
					if (CDC.uid in H.pathogens)
						H.cured(H.pathogens[CDC.uid])
						count++
				message_admins("[key_name(usr)] cured [count] humans from pathogen strain [strain].")
			if ("strain_details")
				cdc_state[key] = href_list["strain"]
			if ("pathogen_creator")
				var/datum/pathogen/P = src.cdc_creator[usr.ckey]
				switch (href_list["do"])
					if ("reset")
						src.gen_empty(usr.ckey)

					if ("body_type")
						var/list/types = list()
						for (var/btpath in src.path_to_microbody)
							var/datum/microbody/MB = src.path_to_microbody[btpath]
							types += MB.name
							types[MB.name] = MB
						var/chosen = input("Which microbody?", "Microbody", types[1]) in types
						P.body_type = types[chosen]
						P.advance_speed = 25
						P.suppression_threshold = 25
						P.spread = 25
						P.symptomatic = 1
						P.generation = 1
						P.stages = P.body_type.stages

					if ("suppressant")
						var/list/types = list()
						for (var/spath in src.path_to_suppressant)
							var/datum/suppressant/S = src.path_to_suppressant[spath]
							types += S.name
							types[S.name] = S
						var/chosen = input("Which suppressant?", "Suppressant", types[1]) in types
						P.suppressant = types[chosen]
						P.desc = "[P.suppressant.color] dodecahedrical [P.body_type.plural]"

					if ("add")
						var/list/types = list()
						for (var/efpath in src.path_to_symptom)
							var/datum/pathogeneffects/EF = src.path_to_symptom[efpath]
							types += EF.name
							types[EF.name] = EF
						var/chosen = input("Which symptom?", "Add new symptom", types[1]) in types
						if (!(types[chosen] in P.effects))
							P.effects += types[chosen]
							var/datum/pathogeneffects/EF = types[chosen]
							EF.onadd(P)

					if ("remove")
						var/datum/pathogeneffects/EF = locate(href_list["which"])
						if (EF in P.effects)
							P.effects -= EF

					if ("advance_speed")
						P.advance_speed = text2num_safe(input("New advance speed?", "Advance speed", P.advance_speed) as num) || P.advance_speed
					if ("suppression_threshold")
						P.suppression_threshold = text2num_safe(input("New suppression threshold?", "Suppression threshold", P.suppression_threshold) as num) || P.suppression_threshold
					if ("spread")
						P.spread = text2num_safe(input("New spread?", "Spread", P.spread) as num) || P.spread
					if ("symptomatic")
						P.symptomatic = !P.symptomatic
					if ("stages")
						var/value = P.stages
						var/newval = text2num_safe(input("New stages (3-5)?", "Stages", value) as num) || value
						if (newval >= 3 && newval <= 5)
							P.stages = newval
					if ("create")
						P.dnasample = new/datum/pathogendna(P)
						P.pathogen_uid = "p[next_uid]"
						next_uid++

						pathogen_trees += P.name_base
						var/datum/pathogen_cdc/CDC = new /datum/pathogen_cdc(P.pathogen_uid)
						pathogen_trees[P.name_base] = CDC
						next_mutation[P.pathogen_uid] = P.mutation + 1
						CDC.microbody_type = "[P.body_type]"
						CDC.mutations += P.name
						CDC.mutations[P.name] = P

						message_admins("[key_name(usr)] created a new pathogen ([P]) via the creator.")
						src.gen_empty(usr.ckey)

			if ("strain_data")
				var/datum/pathogen_cdc/CDC = locate(href_list["which"])
				var/name = href_list["name"]
				var/datum/pathogen/reference = CDC.mutations[name]
				switch (href_list["data"])
					if ("advance_speed")
						var/value = reference.advance_speed
						var/newval = text2num_safe(input("New advance speed?", "Advance speed", value) as num) || value
						for (var/mob/living/carbon/human/H in CDC.infections)
							if (CDC.uid in H.pathogens)
								var/datum/pathogen/target = H.pathogens[CDC.uid]
								if (target.name == name)
									target.advance_speed = newval
						reference.advance_speed = newval
						message_admins("[key_name(usr)] set the advance speed on pathogen strain mutation [name] to [newval].")
					if ("suppression_threshold")
						var/value = reference.suppression_threshold
						var/newval = text2num_safe(input("New suppression threshold?", "Suppression threshold", value) as num) || value
						for (var/mob/living/carbon/human/H in CDC.infections)
							if (CDC.uid in H.pathogens)
								var/datum/pathogen/target = H.pathogens[CDC.uid]
								if (target.name == name)
									target.suppression_threshold = newval
						reference.suppression_threshold = newval
						message_admins("[key_name(usr)] set the suppression threshold on pathogen strain mutation [name] to [newval].")
					if ("spread")
						var/value = reference.spread
						var/newval = text2num_safe(input("New spread?", "Spread", value) as num) || value
						for (var/mob/living/carbon/human/H in CDC.infections)
							if (CDC.uid in H.pathogens)
								var/datum/pathogen/target = H.pathogens[CDC.uid]
								if (target.name == name)
									target.spread = newval
						reference.spread = newval
						message_admins("[key_name(usr)] set the spread on pathogen strain mutation [name] to [newval].")
					if ("symptomatic")
						var/value = reference.symptomatic
						var/newval = !value
						for (var/mob/living/carbon/human/H in CDC.infections)
							if (CDC.uid in H.pathogens)
								var/datum/pathogen/target = H.pathogens[CDC.uid]
								if (target.name == name)
									target.symptomatic = newval
						reference.symptomatic = newval
						message_admins("[key_name(usr)] set the symptomaticity for pathogen strain mutation [name] to [newval ? "Yes" : "No"].")
					if ("stages")
						var/value = reference.stages
						var/newval = text2num_safe(input("New stages (3-5)?", "Stages", value) as num) || value
						if (newval >= 3 && newval <= 5)
							for (var/mob/living/carbon/human/H in CDC.infections)
								if (CDC.uid in H.pathogens)
									var/datum/pathogen/target = H.pathogens[CDC.uid]
									if (target.name == name)
										target.stages = newval
							reference.stages = newval
							message_admins("[key_name(usr)] set the stages on pathogen strain mutation [name] to [newval].")
					if ("cure")
						var/count = 0
						for (var/mob/living/carbon/human/H in mobs)
							LAGCHECK(LAG_LOW)
							if (CDC.uid in H.pathogens)
								var/datum/pathogen/P = H.pathogens[CDC.uid]
								if (P.name == name)
									H.cured(P)
									count++
						message_admins("[key_name(usr)] cured [count] humans from pathogen strain mutation [name].")
					if ("infect")
						var/mob/living/carbon/human/target = input("Who would you like to infect with this mutation?", "Infect") as mob in mobs//world
						if (!istype(target))
							boutput(usr, "<span class='alert'>Cannot infect that. Must be human.</span>")
						else
							target.infected(reference)
							message_admins("[key_name(usr)] infected [target] with [name].")
					if ("spawn")
						var/obj/item/reagent_containers/glass/vial/V = new /obj/item/reagent_containers/glass/vial(get_turf(usr))
						var/datum/reagent/blood/pathogen/RE = new /datum/reagent/blood/pathogen()
						RE.volume = 5
						RE.pathogens += reference.pathogen_uid
						RE.pathogens[reference.pathogen_uid] = reference
						RE.holder = V.reagents
						V.reagents.reagent_list += RE.id
						V.reagents.reagent_list[RE.id] = RE
						V.reagents.update_total()
			if ("microbody_data")
				var/datum/microbody/MB = locate(href_list["which"])
				switch (href_list["data"])
					if ("stages")
						var/new_stages = text2num_safe(input("Stage cap for [MB] microbodies? (3-5)", "Stage cap", MB.stages) as num) || MB.stages
						if (new_stages >= 3 && new_stages <= 5)
							MB.stages = new_stages
							message_admins("[key_name(usr)] set the initial stage cap for pathogen microbody [MB.plural] to [new_stages].")
					if ("vaccinable")
						MB.vaccination = !MB.vaccination
						message_admins("[key_name(usr)] set the vaccinability for pathogen microbody [MB.plural] to [MB.vaccination ? "On" : "Off"].")
					if ("activity")
						var/stage = text2num_safe(href_list["stage"])
						var/new_act = text2num_safe(input("New activity percentage for stage [stage] of [MB] (0-100)?", "Activity", MB.activity[stage]) as num) || MB.activity[stage]
						if (new_act >= 0 && new_act <= 100)
							MB.activity[stage] = new_act
							message_admins("[key_name(usr)] set the activity for pathogen microbody [MB.plural] on stage [stage] to [new_act].")
			if ("symptom_data")
				var/datum/pathogeneffects/EF = locate(href_list["which"])
				switch (href_list["data"])
					if ("info")
						alert(usr, EF.desc)
		cdc_main(th)

	var/list/cdc_creator = list()
	var/list/cdc_state = list()
	var/static/list/states = list("strains", "symptoms", "microbodies", "suppressants", "mutations", "pathogen creator")
	proc/severity_color(var/datum/pathogeneffects/EF)
		if (EF.rarity == RARITY_ABSTRACT)
			return "[EF]"
		var/color_value = round(255 / EF.rarity)
		if (istype(EF, /datum/pathogeneffects/malevolent))
			return "<span style='color: rgb([color_value], 0, 0)'>[EF]</span>"
		else
			return "<span style='color: rgb(0, [color_value], 0)'>[EF]</span>"

	proc/cdc_main(var/topic_holder)
		if (!usr || !usr.client)
			return
		if (!usr.client.holder)
			boutput(usr, "<span class='alert'>Visitors of the CDC are not allowed to interact with the equipment!</span>")
			return
		if (usr.client.holder.level < LEVEL_SA)
			boutput(usr, "<span class='alert'>I'm sorry, you require a security clearance of Primary Researcher to go in there. Protocol and all. You know.</span>")
			return
		var/state = 1
		if (usr.ckey in cdc_state)
			state = cdc_state[usr.ckey]
		else
			cdc_state += usr.ckey
			cdc_state[usr.ckey] = 1
		var/stylesheet = {"<style>
.pathology-table { width: 100%; text-align: left; border-spacing: 0; border-collapse: collapse; }
.pathology-table thead th { background-color: #000066; color: white; font-weight: bold; border: none; }
.pathology-table td { border: none; border-bottom: 1px solid black; }
.pathology-table .small { font-size: 0.75em; }
.pathology-table .name { font-weight: bold; }
		</style>"}
		var/output = "<html><title>Center for Disease Control</title><head>[stylesheet]</head><body><h2>Center for Disease Control</h2>"
		for (var/i = 1, i <= src.states.len, i++)
			if (i != 1)
				output += " - "
			if (state != i)
				output += "<a href='?src=\ref[src];action=setstate;state=[i];topic_holder=\ref[topic_holder]'>[states[i]]</a>"
			else
				output += "<span style='color:#dd0000; font-weight:bold'>[states[i]]</span>"
		output += "<br>"
		if (istext(state))
			output += "<h3>Details for pathogen strain [state]</h3>"
			if (state in pathogen_trees)
				var/datum/pathogen_cdc/CDC = pathogen_trees[state]
				output += "<table class='pathology-table'><thead><tr><th>Mutation name</th><th>Symptoms</th><th class='small'>Primary attributes</th><th>Symptomatic</th><th>Stages</th><th>Infected</th><th>Actions</th></thead><tbody>"
				for (var/name in CDC.mutations)
					output += "<tr>"
					var/datum/pathogen/P = CDC.mutations[name]
					output += "<td>[name]</td>"
					var/symptoms = ""
					var/first = 1
					for (var/datum/pathogeneffects/EF in P.effects)
						if (first)
							symptoms = severity_color(EF)
							first = 0
						else
							symptoms += "<BR>[severity_color(EF)]"
					output += "<td>[symptoms]</td>"

					output += "<td>"
					output += "Advance speed: <a href='?src=\ref[src];action=strain_data;which=\ref[CDC];name=[name];data=advance_speed;topic_holder=\ref[topic_holder]'>[P.advance_speed]</a><BR>"
					output += "Suppression: <a href='?src=\ref[src];action=strain_data;which=\ref[CDC];name=[name];data=suppression_threshold;topic_holder=\ref[topic_holder]'>[P.suppression_threshold]</a><BR>"
					output += "Spread: <a href='?src=\ref[src];action=strain_data;which=\ref[CDC];name=[name];data=spread;topic_holder=\ref[topic_holder]'>[P.spread]</a><BR>"
					output += "</td>"

					output += "<td><a href='?src=\ref[src];action=strain_data;which=\ref[CDC];name=[name];data=symptomatic;topic_holder=\ref[topic_holder]'>[P.symptomatic ? "Yes" : "No"]</a></td>"
					output += "<td><a href='?src=\ref[src];action=strain_data;which=\ref[CDC];name=[name];data=stages;topic_holder=\ref[topic_holder]'>[P.stages]</a></td>"

					var/infected = 0
					for (var/mob/living/carbon/human/H in CDC.infections)
						var/pname = CDC.infections[H]
						if (pname == P.name)
							infected++
					output += "<td>[infected]</td>"
					output += "<td>"
					output += "<a href='?src=\ref[src];action=strain_data;which=\ref[CDC];name=[name];data=spawn;topic_holder=\ref[topic_holder]'>(SPAWN)</a><br>"
					output += "<a href='?src=\ref[src];action=strain_data;which=\ref[CDC];name=[name];data=infect;topic_holder=\ref[topic_holder]'>(INFECT)</a><br>"
					output += "<a href='?src=\ref[src];action=strain_data;which=\ref[CDC];name=[name];data=cure;topic_holder=\ref[topic_holder]'>(CURE)</a><br>"
					output += "<a href='?src=\ref[topic_holder];action=view_logs_pathology_strain;presearch=[P.name]'>(LOGS)</a>"
					output += "</td>"
					output += "</tr>"
			else
				output += "<h3>This pathogen no longer exists.</h3>"
		else
			switch (states[state])
				if ("strains")
					output += "<table class='pathology-table'><thead><tr><th>Created</th><th>Strain name</th><th>UID</th><th>Patient Zero</th><th>Infected</th><th>Immune</th><th>Microbody</th><th>Cure all</th><th>Details</th><th>Logs</th></thead><tbody>"
					for (var/pathogen_name in pathogen_trees)
						var/datum/pathogen_cdc/CDC = pathogen_trees[pathogen_name]
						output += "<tr>"
						output += "<td class='name'>[round(CDC.creation_time)]M</td>"
						output += "<td class='name'>[pathogen_name]</td>"
						output += "<td>[CDC.uid]</td>"
						if (CDC.patient_zero)
							output += "<td>[CDC.patient_zero_kname]</td>"
						else
							output += "<td>No infections yet</td>"
						var/infections = 0
						var/immunities = 0
						for (var/mob/living/carbon/human/M in mobs)
							LAGCHECK(LAG_LOW)
							if (CDC.uid in M.pathogens)
								infections++
							else if (CDC.uid in M.immunities)
								immunities++
						output += "<td>[infections]</td>"
						output += "<td>[immunities]</td>"
						output += "<td>[CDC.microbody_type]</td>"
						output += "<td><a href='?src=\ref[src];action=strain_cure;strain=[pathogen_name];topic_holder=\ref[topic_holder]'>(CURE)</a></td>"
						output += "<td><a href='?src=\ref[src];action=strain_details;strain=[pathogen_name];topic_holder=\ref[topic_holder]'>(VIEW)</a></td>"
						output += "<td><a href='?src=\ref[topic_holder];action=view_logs_pathology_strain;presearch=[pathogen_name]'>(LOGS)</a></td>"
						output += "</tr>"
					output += "</tbody></table>"
				if ("microbodies")
					output += "<h3>Changes to stage cap only affects future pathogens.</h3>"
					output += "<table class='pathology-table'><thead><tr><th>Name</th><th>Medium</tħ><th>Nutrition</th><th>Stages</th><th>Vaccinable</th><th>Activity</th></thead><tbody>"
					for (var/microbody_path in src.path_to_microbody)
						output += "<tr>"
						var/datum/microbody/MB = src.path_to_microbody[microbody_path]
						output += "<td class='name'>[MB]</td>"
						output += "<td class='small'>[MB.growth_medium]</td>"
						var/nutrition = ""
						var/first = 1
						for (var/nutrient in MB.nutrients)
							if (first)
								first = 0
							else
								nutrition += "<BR>"
							nutrition += "[nutrient]"
						output += "<td>[nutrition]</td>"
						output += "<td><a href='?src=\ref[src];action=microbody_data;which=\ref[MB];data=stages;topic_holder=\ref[topic_holder]'>[MB.stages]</a></td>"
						output += "<td><a href='?src=\ref[src];action=microbody_data;which=\ref[MB];data=vaccinable;topic_holder=\ref[topic_holder]'>[MB.vaccination ? "Yes" : "No"]</a></td>"
						output += "<td>"
						for (var/stage = 1, stage <= 5, stage++)
							if (stage != 1)
								output += "<br>"
							output += "<a href='?src=\ref[src];action=microbody_data;which=\ref[MB];data=activity;stage=[stage];topic_holder=\ref[topic_holder]'>[MB.activity[stage]]%</a>"
						output += "</td>"
						output += "</tr>"
					output += "</tbody></table>"
				if ("symptoms")
					output += "<table class='pathology-table'><thead><tr><th>Name</th><th>Info</th><th>Infection range</th><th>Infection coefficient</th><th>Rarity</th><th>DNA</th></thead><tbody>"
					for (var/sym_path in src.path_to_symptom)
						var/datum/pathogeneffects/EF = src.path_to_symptom[sym_path]
						output += "<tr>"
						output += "<td>[EF]</td>"
						output += "<td><a href='?src=\ref[src];action=symptom_data;which=\ref[EF];data=info;topic_holder=\ref[topic_holder]'>Show information</a></td>"
						output += "<td>[EF.infect_type]</td>"
						output += "<td>[EF.infection_coefficient]</td>"
						switch (EF.rarity)
							if (RARITY_ABSTRACT)
								output += "<td>Non-existent</td>"
							if (RARITY_VERY_COMMON)
								output += "<td>Very common</td>"
							if (RARITY_COMMON)
								output += "<td>Common</td>"
							if (RARITY_UNCOMMON)
								output += "<td>Uncommon</td>"
							if (RARITY_RARE)
								output += "<td>Rare</td>"
							if (RARITY_VERY_RARE)
								output += "<td>Very Rare</td>"
						var/DNA = src.symptom_to_UID[EF.type]
						output += "<td>[DNA]</td>"
						output += "</tr>"
				if ("suppressants")
					output += "<table class='pathology-table'><thead><tr><th>Name</th><th>Suppression reagents</th></thead><tbody>"
					for (var/sup_path in src.path_to_suppressant)
						output += "<tr>"
						var/datum/suppressant/S = src.path_to_suppressant[sup_path]
						output += "<td>[S]</td>"
						var/first = 1
						var/supp = ""
						for (var/reagent in S.cure_synthesis)
							if (first)
								first = 0
							else
								supp += "<BR>"
							supp += "[reagent]"
						output += "<td>[supp]</td>"
						output += "</tr>"
				if ("pathogen creator")
					if (!(usr.ckey in src.cdc_creator))
						src.gen_empty(usr.ckey)
					var/datum/pathogen/P = src.cdc_creator[usr.ckey]
					output += "<h3>Pathogen Creator</h3>"
					output += "<b>Strain: </b> [P.name_base]<br>"
					output += "<b>Base mutation:</b> [P.mutation]<br>"
					output += "<b>Name: </b> [P.name]<br>"
					if (P.suppressant)
						output += "<b>Description: </b> [P.desc]<br>"

					if (!P.body_type)
						output += "<a href='?src=\ref[src];action=pathogen_creator;do=body_type;topic_holder=\ref[topic_holder]'>Assign microbody</a><br>"
					else
						output += "<b>Microbody:</b> [P.body_type]<br>"
						output += "<b>Stages:</b> <a href='?src=\ref[src];action=pathogen_creator;do=stages;topic_holder=\ref[topic_holder]'>[P.stages]</a><br>"
						output += "<b>Advance speed:</b> <a href='?src=\ref[src];action=pathogen_creator;do=advance_speed;topic_holder=\ref[topic_holder]'>[P.advance_speed]</a><br>"
						output += "<b>Symptomatic:</b> <a href='?src=\ref[src];action=pathogen_creator;do=symptomatic;topic_holder=\ref[topic_holder]'>[P.symptomatic ? "Yes" : "No"]</a><br>"
						output += "<b>Suppression threshold:</b> <a href='?src=\ref[src];action=pathogen_creator;do=suppression_threshold;topic_holder=\ref[topic_holder]'>[P.suppression_threshold]</a><br>"
						output += "<b>Spread:</b> <a href='?src=\ref[src];action=pathogen_creator;do=spread;topic_holder=\ref[topic_holder]'>[P.spread]</a><br>"
						if (!P.suppressant)
							output += "<a href='?src=\ref[src];action=pathogen_creator;do=suppressant;topic_holder=\ref[topic_holder]'>Assign suppressant</a><br>"
						else
							output += "<b>Suppressant: </b>[P.suppressant]<br><br>"
							output += "<b>Effects: </b><br>"
							if (P.effects.len)
								for (var/datum/pathogeneffects/EF in P.effects)
									output += "- [EF] <a href='?src=\ref[src];action=pathogen_creator;do=remove;which=\ref[EF];topic_holder=\ref[topic_holder]'>(remove)</a><br>"
							else
								output += " -- None -- <br>"
							output += "<a href='?src=\ref[src];action=pathogen_creator;do=add;topic_holder=\ref[topic_holder]'>Add effect</a><br><br>"
					output += "<a href='?src=\ref[src];action=pathogen_creator;do=reset;topic_holder=\ref[topic_holder]'>Reset pathogen</a>"
					if (P.body_type && P.suppressant && length(P.effects))
						output += " -- <a href='?src=\ref[src];action=pathogen_creator;do=create;topic_holder=\ref[topic_holder]'>Create pathogen</a>"
				else
					output += "<h1>NOTHING TO SEE HERE YET</h1>"
		output += "</body></html>"
		usr.Browse(output, "window=cdc;size=800x480")

	proc/gen_empty(var/key)
		if (!(key in src.cdc_creator))
			src.cdc_creator += key
		var/datum/pathogen/P = new /datum/pathogen
		P.mutation = pick(lnums)
		do
			P.name_base = pick(lalph) + pick(lnums) + pick(lalph)
		while (P.name_base in pathogen_trees)
		P.name = P.name_base + P.mutation
		P.mutation = text2num_safe(P.mutation)
		P.base_mutation = 0
		src.cdc_creator[key] = P

	New()
		..()
		UID_to_symptom = list()
		symptom_to_UID = list()
		UID_to_suppressant = list()
		suppressant_to_UID = list()
		UID_to_carrier = list()
		carrier_to_UID = list()
		microbody_to_UID = list()

		for (var/T in childrentypesof(/datum/microbody))
			var/datum/microbody/B = new T()
			microbody_to_UID[T] = B.uniqueid
			path_to_microbody[T] = B

			if (!(B.growth_medium in media))
				media += B.growth_medium
			if (!(B.cure_base in cure_bases))
				cure_bases += B.cure_base
			for (var/nutrient in B.nutrients)
				if (!(nutrient in nutrients))
					nutrients += nutrient

			var/datum/choice/C = new
			C.target = B
			C.min = choicemax + 1
			choicemax += B.commonness
			C.max = choicemax
			microbody_choices += C

		var/list/eff = typesof(/datum/pathogeneffects)
		l_vc = list()
		l_c = list()
		l_u = list()
		l_r = list()
		l_vr = list()
		for (var/E in eff)
			var/datum/pathogeneffects/inst = new E()
			if (inst.rarity == RARITY_ABSTRACT)
				continue
			path_to_symptom[E] = inst
			switch (inst.rarity)
				if (RARITY_VERY_COMMON)
					l_vc += E

				if (RARITY_COMMON)
					l_c += E

				if (RARITY_UNCOMMON)
					l_u += E

				if (RARITY_RARE)
					l_r += E

				if (RARITY_VERY_RARE)
					l_vr += E

		var/list/used = list()
		var/list/vc = list()
		var/list/cp = list()
		var/list/cu = list()
		var/list/up = list()
		var/list/uu = list()
		var/list/rp = list()
		var/list/ru = list()
		var/list/vrp = list()
		var/list/vru = list()

		for (var/T in childrentypesof(/datum/suppressant))
			var/r
			do
				r = num2hex(rand(0, 4095), 3)
			while (r in used)
			suppressant_to_UID[T] = r
			UID_to_suppressant[r] = T
			path_to_suppressant[T] = new T()
			used += r

		/*for (var/T in typesof(/datum/pathogen_carrier))
			var/r
			do
				r = num2hex(rand(0, 4095), 3)
			while (r in used)
			carrier_to_UID[T] = r
			UID_to_carrier[r] = new T()
			used += r*/

		// Assemble VERY_COMMON
		for (var/T in l_vc)
			var/r
			do
				r = num2hex(rand(0, 4095), 3)
			while (r in used)
			symptom_to_UID[T] = r
			UID_to_symptom[r] = T
			used += r
			vc += r

		// Create COMMON possibilities
		for (var/p1 in vc)
			for (var/p2 in vc)
				if (!((p1 + p2) in cp))
					cp += p1 + p2
				if (!((p2 + p1) in cp))
					cp += p2 + p1

		// Assemble COMMON
		for (var/T in l_c)
			var/r
			if (cp.len)
				r = pick(cp)
			else
				do
					r = pick(vc) + num2hex(rand(0, 4095), 3)
				while (r in cu)
			cp -= r
			symptom_to_UID[T] = r
			UID_to_symptom[r] = T
			cu += r

		// Create UNCOMMON possibilities
		for (var/p1 in cu)
			for (var/p2 in vc)
				if (!((p1 + p2) in cp))
					up += p1 + p2
				if (!((p2 + p1) in cp))
					up += p2 + p1

		// Assemble UNCOMMON
		for (var/T in l_u)
			var/r
			if (up.len)
				r = pick(up)
			else
				do
					r = pick(cu) + num2hex(rand(0, 4095), 3)
				while (r in uu)
			up -= r
			symptom_to_UID[T] = r
			UID_to_symptom[r] = T
			uu += r

		// Create RARE possibilities
		for (var/p1 in uu)
			for (var/p2 in vc)
				if (!((p1 + p2) in cp))
					rp += p1 + p2
				if (!((p2 + p1) in cp))
					rp += p2 + p1

		// Assemble RARE
		for (var/T in l_r)
			var/r
			if (rp.len)
				r = pick(rp)
			else
				do
					r = pick(uu) + num2hex(rand(0, 4095), 3)
				while (r in ru)
			rp -= r
			symptom_to_UID[T] = r
			UID_to_symptom[r] = T
			ru += r

		// Create VERY_RARE possibilities
		for (var/p1 in ru)
			for (var/p2 in vc)
				if (!((p1 + p2) in cp))
					vrp += p1 + p2
				if (!((p2 + p1) in cp))
					vrp += p2 + p1

		// Assemble VERY_RARE
		for (var/T in l_vr)
			var/r
			if (vrp.len)
				r = pick(vrp)
			else
				do
					r = pick(ru) + num2hex(rand(0, 4095), 3)
				while (r in vru)
			vrp -= r
			symptom_to_UID[T] = r
			UID_to_symptom[r] = T
			vru += r

		for (var/i = 1, i <= 99, i++)
			lnums += "[i]"
		for (var/i = text2ascii("A"), i <= text2ascii("Z"), i++)
			lalph += ascii2text(i)

var/global/datum/controller/pathogen/pathogen_controller = new()

// A choice assistant datum
datum/choice
	var/target

	var/min = 0
	var/max = 10

// todo: remove this, port.
// A wrapper record returned by the onshocked event of a pathogen symptom.
datum/shockparam
	var/amt
	var/wattage
	var/skipsupp

// A pathogen. How surprising.
datum/pathogen
	var/name										// The full 'scientific' name for the pathogen (eg. H5N1)
	var/name_base									// The 'scientific' name without the mutation part (eg. H5N)
	var/pathogen_uid								// The unique identifier of the pathogen family. All pathogens with the same UID are cured by the same vaccine.
	var/mutation									// The mutation identifier of the pathogen (eg. for H5N1: 1). Unique for each mutation. Sequential.
	var/desc										// What a scientist might see when he looks at this pathogen through a microscope (eg. blue stringy viruses)
	var/stages										// How far the pathogen may advance? Higher stages allow for more malicious/benevolent effects of symptoms. (3 to 5)
													// The amount of stages is determined by the body type. The most potent of all are viruses and parasites.
	var/list/carriers = list()						// A list of carriers to this pathogen. Currently unused.
	var/list/effects = list()						// A list of symptoms exhibited by those infected with this pathogen.
	var/stage										// The current stage of the pathogen.
	var/advance_speed								// The speed at which this pathogen advances stages. An advance speed of N means a flat N/100% chance to advance each tick.
	var/base_mutation								// Currently unused.
	var/datum/microbody/body_type					// The body type of the pathogen, which determines the capacity, maximum stat points, activity, and
	var/mob/infected								// The mob that is infected with this pathogen.
	var/cooldown = 3								// An internal 'cooldown' so that the pathogen doesn't instantly advance to stage 5.
	var/suppression_threshold						// The pathogen's resistance to suppression. The higher this value, the more extreme conditions are required to suppress the pathogen.
	var/spread								// This determines how easily the pathogen spreads. How this affects spreading symptoms is up to each symptom to determine.
														// For instance, a symptom that makes pathogen smoke might make more smoke
														// while a pathogen that infects when hugging might have a higher chance to infect on each hug

	var/list/mutex = list()							// These symptoms are explicitly disallowed by a mutex.
	var/symptomatic = 1 							// If 0, the pathogen is mostly dormant on the mob. Symptoms may still decide to ignore this.
	var/generation = 1 								// Higher generation pathogens may replace lower generation pathogens on mobs.

	var/datum/pathogendna/dnasample = null			// A reference of what the pathogen's DNA looks like. This reference is passed around
													// and copied only when coming into contact with something that directly works with
													// the DNA itself.

	var/datum/suppressant/suppressant				// The method of suppression for the pathogen. This is picked from all children of /datum/suppressant with an equal
													// probability. I might try to work out a system for rarities once, but it's very low on the priority list. To add a suppression method,
													// just define a child for /datum/suppressant and please make sure it's not an already existing colour.

	var/suppressed = 0								// A suppression indicator. After every roll for advancement, suppression is reset to 0 and a cooldown is set. Processes of the pathogen
													// and the symptoms both may decide to set this flag during this cooldown. The pathogen immediately fails the advance roll if it is suppressed.
													// With this being available, symptoms may define their own resistances and vulnerabilities. Setting this to -1 will make all current symptoms'
													// vulnerability checks immediately fail - ie. the symptoms' weaknesses will not suppress the pathogen. On the flipside, setting this to 2 will
													// make all current symptoms' resistance check immediately fail, ie. the symptoms' resistances will not prevent suppression. It would be good
													// practice to build all symptoms consistently with this concept.
													// Each disease has their primary suppression method, which provides their colour. The primary suppression method is relevant only if after
													// all the symptoms acting, suppressed does not equal -1. Primary suppression methods may suppress the pathogen further: Even if a symptom
													// has a weakness powerful enough to force it back a stage, a primary suppression method is also such a weakness that it may be pushed back
													// yet another stage.
													// A pathogen that cannot be currently suppressed (ie. is strengthened somehow) may advance regardless of advance speed.
													// Be sensible when defining suppressions for symptoms. It shouldn't cure the pathogen, and it seldom should push the pathogen back below stage 3.
													// TL;DR
													// -1: Cannot be suppressed. May cause a negative advance speed pathogen to advance anyway.
													//  0: Will not be suppressed.
													//  1: Will be suppressed.
													//  2: Will surely be suppressed.

	var/in_remission = 0							// Pathogens in remission are being cured by the body. Set by the curing reagent.
	var/forced_microbody = null						// If not null, this pathogen will be generated with a specific microbody.
	var/curable_by_suppression = 10	// If not 0, represents a probability of becoming regressive through suppression. If negative, randomly generated.
	var/ticked = 0

	var/list/symptom_data = list()					// Symptom data container.

	disposing()
		clear()
		..()

	proc/clear()
		name = ""
		name_base = ""
		pathogen_uid = null
		mutation = null
		desc = ""
		stages = 1
		carriers = list()
		effects = list()
		stage = 1
		generation = 1
		symptomatic = 1
		advance_speed = 0
		spread = 0
		base_mutation = null
		body_type = null
		infected = null
		cooldown = 3
		suppression_threshold = 0
		mutex = list()
		dnasample = null
		suppressant = null
		suppressed = 0
		in_remission = 0
		ticked = 0
		symptom_data = list()

		forced_microbody = initial(forced_microbody)
		curable_by_suppression = initial(curable_by_suppression)

	proc/clone()
		var/datum/pathogen/P = new /datum/pathogen
		P.setup(0, src, 0)
		return P

	proc/do_prefab(var/strength = 0)
		clear()
		var/cdc = generate_name()
		generate_components(cdc)
		generate_attributes(strength)

	New()
		..()
		setup(0, null, 0)

	proc/create_weak()
		randomize(0)
		if (!dnasample)
			dnasample = new/datum/pathogendna(src)

	proc/cdc_announce(var/mob/M)
		var/datum/pathogen_cdc/CDC = null
		if (name_base in pathogen_controller.pathogen_trees)
			CDC = pathogen_controller.pathogen_trees[name_base]
		else
			CDC = new /datum/pathogen_cdc(pathogen_uid)
			pathogen_controller.pathogen_trees[name_base] = CDC
			pathogen_controller.next_mutation[pathogen_uid] = mutation + 1
			CDC.microbody_type = body_type
		CDC.mutations += name
		CDC.mutations[name] = clone()
		return

	proc/generate_name()
		src.mutation = pick(pathogen_controller.lnums)
		do
			src.name_base = pick(pathogen_controller.lalph) + pick(pathogen_controller.lnums) + pick(pathogen_controller.lalph)
		while (src.name_base in pathogen_controller.pathogen_trees)
		src.name = name_base + mutation
		src.mutation = text2num_safe(mutation)
		src.base_mutation = 0

		src.pathogen_uid = "p[pathogen_controller.next_uid]"
		pathogen_controller.next_uid++

		pathogen_controller.pathogen_trees += src.name_base
		var/datum/pathogen_cdc/cdc = new /datum/pathogen_cdc(src.pathogen_uid)
		pathogen_controller.pathogen_trees[src.name_base] = cdc
		pathogen_controller.next_mutation[src.pathogen_uid] = mutation + 1

//		if (ticker)
//			if (current_state == GAME_STATE_PLAYING)
//				message_admins("Pathogen tree [src.name_base] entering play.")

		return cdc

	proc/generate_components(var/datum/pathogen_cdc/cdc, var/strength)
		var/supp_t = pick(pathogen_controller.path_to_suppressant)
		suppressant = pathogen_controller.path_to_suppressant[supp_t]
		suppressant.onadd(src)

		if (!forced_microbody)
			src.body_type = pathogen_controller.get_microbody(strength + 5)
			cdc.microbody_type = "[src.body_type]"
		else
			src.body_type = pathogen_controller.path_to_microbody[forced_microbody]
			cdc.microbody_type = "[src.body_type]"

	proc/generate_randomized_effects(var/strength)
		var/adj_strength = strength - 8
		if (strength != -1)
			var/effcount = pick(1, prob(50); 2, prob(25); 3, prob(10); 4, prob(10); 5)
			for (var/i = 0, i < effcount, i++)
				var/val = rand(adj_strength, adj_strength + 8)
				if (val < 6)
					generate_weak_effect()
				else if (val < 14)
					generate_effect()
				else
					generate_strong_effect()

	proc/generate_attributes(var/strength)
		var/adj_strength = strength - 8

		src.suppression_threshold = 25 + rand(adj_strength - 8, adj_strength + 8)
		src.advance_speed = 25 + rand(adj_strength - 8, adj_strength + 8)
		src.spread = 25 + rand(adj_strength - 8, adj_strength + 8)

		if (src.curable_by_suppression < 0 && strength < 10)
			src.curable_by_suppression = rand(-10 + strength, 10 - strength)
			if (src.curable_by_suppression < 0)
				src.curable_by_suppression = 0
		else
			src.curable_by_suppression = 10

		src.stages = src.body_type.stages

		var/shape = pick("stringy", "snake", "blob", "spherical", "tetrahedral", "star shaped", "tesselated")
		src.desc = "[src.suppressant.color] [shape] [src.body_type.plural]"

		src.symptomatic = 1
		src.generation = 1
		src.stage = 1

	proc/randomize(var/strength)
		var/datum/pathogen_cdc/cdc = generate_name()
		cdc.mutations += src.name
		cdc.mutations[src.name] = src
		generate_randomized_effects(strength)
		generate_components(cdc, strength)
		generate_attributes(strength)

		logTheThing(LOG_PATHOLOGY, null, "Pathogen [name] created by randomization.")

	proc/setup(status, var/datum/pathogen/origin, may_mutate, var/datum/pathogendna/sample = null)
		if (status == 0 && !origin)
			return
		src.in_remission = 0
		if (origin)
			src.mutation = origin.mutation
			src.name = origin.name
			src.name_base = origin.name_base
			src.stages = origin.stages
			src.desc = origin.desc
			src.carriers = list()
			src.effects = origin.effects.Copy()
			for (var/datum/pathogeneffects/E in src.effects)
				E.onadd(src)
			src.pathogen_uid = origin.pathogen_uid
			src.suppressant = new origin.suppressant.type()
			src.suppressant.onadd(src)
			src.stage = 1
			src.generation = origin.generation
			src.symptomatic = origin.symptomatic
			src.advance_speed = origin.advance_speed
			src.spread = origin.spread
			src.body_type = origin.body_type
			src.suppression_threshold = origin.suppression_threshold
			if (sample)
				src.dnasample = sample
			else
				src.dnasample = origin.dnasample
			src.curable_by_suppression = origin.curable_by_suppression
		else if (status == 1)
			src.randomize(8)
			if (sample)
				src.dnasample = sample
			else
				src.dnasample = new/datum/pathogendna(src)
		else if (!origin && status == 2)
			src.do_prefab()
			if (sample)
				src.dnasample = sample
			else
				src.dnasample = new/datum/pathogendna(src)
		processing_items.Add(src)


	proc/generate_weak_effect()
		switch(rand(1,100))
			if (1 to 70)
				return src.add_new_symptom(pathogen_controller.l_vc)
			if (71 to 97)
				return src.add_new_symptom(pathogen_controller.l_c)
			if (98 to 100)
				return src.add_new_symptom(pathogen_controller.l_u)

	proc/generate_effect()
		switch(rand(1,100))
			if (1 to 60) // 60%
				return src.add_new_symptom(pathogen_controller.l_vc)
			if (61 to 85) // 25%
				return src.add_new_symptom(pathogen_controller.l_c)
			if (86 to 94) // 8%
				return src.add_new_symptom(pathogen_controller.l_u)
			if (95 to 98) // 4%
				return src.add_new_symptom(pathogen_controller.l_r)
			if (99 to 100) // 2%
				return src.add_new_symptom(pathogen_controller.l_vr)

	proc/generate_strong_effect()
		switch(rand(1,100))
			if (1 to 40) // 40%
				return src.add_new_symptom(pathogen_controller.l_vc)
			if (41 to 70) // 30%
				return src.add_new_symptom(pathogen_controller.l_c)
			if (71 to 85) // 15%
				return src.add_new_symptom(pathogen_controller.l_u)
			if (86 to 93) // 8%
				return src.add_new_symptom(pathogen_controller.l_r)
			if (94 to 100) // 7%
				return src.add_new_symptom(pathogen_controller.l_vr)

	proc/process()
		if (ticked)
			ticked = 0
			suppressed = 0

	// handles pathogen advancing or receding in stage and also being cured
	proc/progress_pathogen()
		if (!cooldown)
			if (in_remission)
				if (prob(advance_speed/10))
					if (stage == 1)
						infected.cured(src)
					else
						reduce()
				return
			if (suppressed != -1)
				var/result = suppressant.suppress_act(src)
				if (suppressed == 0)
					suppressed = result
			if (advance_speed)
				if (prob(advance_speed/10))
					if (suppressed < 1)
						advance()
					else if (stage > 3)
						reduce()
			if (suppressed > 0)
				if (curable_by_suppression && prob(curable_by_suppression))
					in_remission = 1
			ticked = 1
		else
			cooldown--

	// This is the real thing, wrapped by process().
	proc/disease_act()
		var/list/acted = list()
		var/order = pick(0,1)
		if (order)
			for (var/datum/effect in src.effects)
				if (effect.type in acted)
					continue
				acted += effect.type
				if (prob(body_type.activity[stage]))
					effect:disease_act(infected, src)
		else
			for (var/i = src.effects.len, i > 0, i--)
				var/datum/effect = src.effects[i]
				if (effect.type in acted)
					continue
				acted += effect.type
				if (prob(body_type.activity[stage]))
					effect:disease_act(infected, src)
		progress_pathogen()

	// it's like disease_act, but for dead people!
	proc/disease_act_dead()
		var/list/acted = list()
		var/order = pick(0,1)
		if (order)
			for (var/datum/effect in src.effects)
				if (effect.type in acted)
					continue
				acted += effect.type
				if (prob(body_type.activity[stage]))
					effect:disease_act_dead(infected, src)
		else
			for (var/i = src.effects.len, i > 0, i--)
				var/datum/effect = src.effects[i]
				if (effect.type in acted)
					continue
				acted += effect.type
				if (prob(body_type.activity[stage]))
					effect:disease_act_dead(infected, src)
		progress_pathogen()

	// A safe method for advancing the pathogen's stage.
	proc/advance()
		if (stage != stages)
			stage++
			cooldown = COOLDOWN_MULTIPLIER * 3 + 2 * stage

	// The polar opposite of advance(). It causes the pathogen to safely reduce a stage if it can.
	proc/reduce()
		if (stage > 1)
			stage--
			cooldown = COOLDOWN_MULTIPLIER * 3 + 2 * stage
		else
			infected.cured(src)

	// Carrier query. Currently unused.
	proc/is_carried_by(var/reagent)
		return (reagent in pathogen_controller.pathogen_affected_reagents)

	proc/remission()
		in_remission = 1

	//=============================================================================
	//	Events
	//=============================================================================
	// In the following chapter you will encounter the definition for event handlers.
	// Event handlers are available for both pathogens and symptoms.
	//
	//  Defining new events
	// ---------------------
	// 1) Add your event handler here. The event handler should call the event handlers of all symptoms.
	// 2) Define a default event handler in /datum/pathogeneffects. This is necessary so that all symptoms continue working, even if they don't respond to that event.
	// 3) Define a default event handler in /datum/suppressant. This is necessary so that all suppression methods continue working, even if they don't respond to that event.
	// 4) Override the event handler in the symptoms where you want it to react.
	// 5) Call each affecting pathogen's event handler when the event is triggered.
	//
	//  Defining existing events for symptoms
	// ---------------------------------------
	// All events are structured, so that if they take X arguments in the pathogen, they take X+2 arguments in the pathogen effect, so the first argument is always the
	// affected mob, while the last argument is always the affecting pathogen. The equivalent event of the pathogen symptoms has the same name as the pathogen's wrapper
	// event.
	// A good practice is to follow these standards.
	// To define an event for an effect, simply override the appropriate event handler. The pathogen code automatically handles calling these events at the appropriate time.
	//

	// Act when grabbing a mob. Does not return anything, the grab always happens.
	// This event is only fired when the PASSIVE grab comes into play.
	// @TODO: Extend this event to all grab levels. Add the possibility of vetoing.
	proc/ongrab(var/mob/target as mob)
		for (var/effect in src.effects)
			effect:ongrab(infected, target, src)
		suppressant.ongrab(target, src)

	// Act when punched by a mob. Returns a multiplier for the damage done by the punch.
	// A hardened skin symptom might make good use of it one day (AT THE TIME OF WRITING THIS COMMENT THAT DID NOT EXIST OKAY)
	proc/onpunched(var/mob/origin as mob, zone)
		var/ret = 1
		for (var/effect in src.effects)
			ret *= effect:onpunched(infected, origin, zone, src)
		suppressant.onpunched(origin, zone, src)
		return ret

	// Act when punching a mob. Returns a multipier for the damage done by the punch.
	// This opens up the availability for both hulk (quad-damage anyone?) and muscle deficiency diseases.
	// Returning 0 from any symptom vetoes the punch.
	proc/onpunch(var/mob/target as mob, zone)
		var/ret = 1
		for (var/effect in src.effects)
			ret *= effect:onpunch(infected, target, zone, src)
		suppressant.onpunch(target, zone, src)
		return ret

	// Act when successfully disarming or pushing down a mob. Returns whether this may happen.
	// This indicates that ondisarm is a veto event - any of the symptoms has a right to veto the occurrence of the disarm or pushdown.
	// Think of it this way. Suppose you have a muscle disease that makes you weak. When your puny body finally hits the target...
	// ...nothing actually happens because you're a weak mess and failed to even scratch him.
	// Returning 0 from ANY of the symptoms' disarm events will make disarming fail.
	proc/ondisarm(var/mob/target as mob, isPushDown)
		var/ret = 1
		for (var/effect in src.effects)
			ret = min(effect:ondisarm(infected, target, isPushDown, src), ret)
		suppressant.ondisarm(target, isPushDown, src)
		return ret

	// Act when shocked. Returns the amount of damage the shocked mob should actually take (which leaves place for both amplification and suppression)
	// The return system here is more complex than for most other events. The symptoms' onshocked may not only modify the amount of shock damage, but
	// also decide that the presence of the symptom makes the a muscle-event vulnerable pathogen resistant to suppression through shocking.
	proc/onshocked(var/amt, var/wattage)
		var/datum/shockparam/ret = new
		ret.amt = amt
		ret.wattage = wattage
		ret.skipsupp = 0
		for (var/effect in src.effects)
			ret = effect:onshocked(infected, ret, src)
		suppressant.onshocked(ret, src)
		return ret.amt

	// Act when saying something. Returns the message that should be said after the diseases make the appropriate modifications.
	proc/onsay(message)
		for (var/effect in src.effects)
			message = effect:onsay(infected, message, src)
		suppressant.onsay(message, src)
		return message

	// Act on emoting. Vetoing available by returning 0.
	proc/onemote(act, voluntary, param)
		suppressant.onemote(infected, act, voluntary, param, src)
		for (var/effect in src.effects)
			. *= effect:onemote(infected, act, voluntary, param, src)

	// Act when dying. Returns nothing.
	proc/ondeath()
		for (var/effect in src.effects)
			effect:ondeath(infected, src)
		suppressant.ondeath(src)
		return

	// Act when pathogen is cured. Returns nothing.
	proc/oncured()
		for (var/effect in src.effects)
			effect:oncured(infected, src)
		suppressant.oncured(src)
		return

	proc/add_new_symptom(var/list/allowed, var/allow_duplicates = 0)
		for (var/i = 0, i < 10, i++)
			var/T = pick(allowed)
			var/datum/pathogeneffects/E = pathogen_controller.path_to_symptom[T]
			if (add_symptom(E, allow_duplicates))
				return 1
		return 0

	proc/add_symptom(var/datum/pathogeneffects/E, var/allow_duplicates = 0)
		if (allow_duplicates || !(E in effects))
			for (var/mutex in E.mutex)
				for (var/T in typesof(mutex))
					if (!(T in mutex))
						mutex += T
			effects += E
			E.onadd(src)
			return 1
		return 0

	proc/remove_symptom(var/datum/pathogeneffects/E, var/all = 0)
		if (all)
			var/rem = 0
			while (E in src.effects)
				src.effects -= E
				rem = 1
			if (rem)
				rebuild_mutex()
		else
			if (E in src.effects)
				src.effects -= E
				rebuild_mutex()

	proc/rebuild_mutex()
		src.mutex = list()
		for (var/datum/pathogeneffects/E in src.effects)
			for (var/mutex in E.mutex)
				for (var/T in typesof(mutex))
					if (!(T in mutex))
						mutex += T

	proc/getHighestTier()
		. = 0
		for(var/datum/pathogeneffects/E in src.effects)
			. = max(., E.rarity)


proc/dig2hex(num)
	switch (num)
		if (0 to 9)
			return num
		if (10)
			return "A"
		if (11)
			return "B"
		if (12)
			return "C"
		if (13)
			return "D"
		if (14)
			return "E"
		if (15)
			return "F"
		else
			return ""

// One's complement num2hex - converts numbers to their hexadecimal one's complement representation (along with the padding).
proc/num2hexoc(num, pad)
	if (pad == null)
		pad = 4
	if (pad <= 0)
		return ""
	var/max = 1

	var/neg = 0
	if (num < 0)
		num = -num
		neg = 1

	for (var/i = 1; i < pad; i++)
		max *= 16
	max *= 8
	max -= 1

	var/ret = ""
	if (num > max)
		if (neg)
			for (var/i = 1; i < pad; i++)
				ret = "0[ret]"
			return "8[ret]"
		else
			for (var/i = 1; i < pad; i++)
				ret = "F[ret]"
			return "7[ret]"
	else
		var/digs = 1
		var/cnum = num
		while (cnum)
			if (digs != pad)
				var/digit = cnum % 16
				if (neg)
					digit = 15 - digit
				ret = "[dig2hex(digit)][ret]"
				cnum = round(cnum / 16)
				digs++
			else
				var/digit = num
				if (digit > 7)
					logTheThing(LOG_PATHOLOGY, null, "Num2hexoc error: overflow on [num].")
				if (neg)
					digit += 8
				return "[num2hex(digit,0)][ret]"
		while (digs <= pad)
			if (neg)
				ret = "F[ret]"
			else
				ret = "0[ret]"
			digs++
		return ret

// One's complement reverse engineering of a hexadecimal one's complement representation to a base 10 signed number
proc/hex2numoc(var/num)
	var/len = length(num)
	var/max = 7
	for (var/i = len - 1, i > 0, i--)
		max = max * 16 + 15
	var/rnum = hex2num(num)
	if (rnum > max)
		rnum = rnum - (16 ** len - 1)
	return rnum

// generates a random 3-sequence (rand(0, 4095) is unreliable)
proc/rand3seq()
	return num2hex(rand(0, 15), 1) + num2hex(rand(0, 15), 1) + num2hex(rand(0, 15), 1)
