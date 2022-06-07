datum/microbiology_cdc
	var/uid = null
	var/patient_zero = null
	var/patient_zero_kname = ""
	var/creation_time = null

	//var/list/infections = list()

	New(var/microbio_uid)
		..()
		creation_time = world.time / 600
		src.uid = microbio_uid

datum/controller/microbe

	//var/list/microbe_trees = new/list()				//stores info on a single microbe across different infected players

	var/list/path_to_evil = list()
	var/list/path_to_effect = list()
	var/list/path_to_suppressant = list()

	var/list/pathogen_affected_reagents = list("blood", "pathogen", "bloodc")

	var/list/used = list() 							//list to ensure nomenclature uniquenes

	var/next_uid = 1
	var/next_puid = 1
/*
	//Mark who got infected on the CDC panel
	proc/mob_infected(var/datum/microbe/P, var/mob/living/carbon/human/H)
		var/datum/microbiology_cdc/CDC = src.microbe_trees[P.name]
		if (!CDC)
			return
		if (!CDC.patient_zero)
			CDC.patient_zero = H
			CDC.patient_zero_kname = "[H]"
		if (!(H in CDC.infections))
			CDC.infections += H
		CDC.infections[H] = P.name

	//Mark Patient Zero on the CDC panel
	proc/patient_zero(var/datum/microbe/P, var/topic_holder)
		var/datum/microbiology_cdc/CDC = src.microbe_trees[P.name]
		if (!CDC)
			return
		if (CDC.patient_zero)
			return replacetext(CDC.patient_zero_kname, "%holder%", "\ref[topic_holder]")

	//Mark who is cured on the CDC panel
	proc/mob_cured(var/datum/microbe/P, var/mob/living/carbon/human/H)
		var/datum/microbiology_cdc/CDC = src.microbe_trees[P.name]
		if (!CDC)
			return
		if (H in CDC.infections)
			CDC.infections -= H

	Topic(href, href_list)
		USR_ADMIN_ONLY
		var/key = usr.ckey
		var/th = locate(href_list["topic_holder"])
		switch(href_list["action"])
			//Set CDC access state
			if ("setstate")
				cdc_state[key] = text2num_safe(href_list["state"])
			//Cure every microbe infection
			if ("strain_cure")
				var/strain = href_list["strain"]
				var/datum/microbiology_cdc/CDC = microbe_trees[strain]
				var/count = 0
				for (var/mob/living/carbon/human/H in mobs)
					LAGCHECK(LAG_LOW)
					if (CDC.uid in H.microbes)
						H.cured(H.microbes[CDC.uid])
						count++
				message_admins("[key_name(usr)] cured [count] humans from pathogen strain [strain].")
			//Show microbe data
			if ("strain_details")
				cdc_state[key] = href_list["strain"]
			//Microbe Creator
			if ("pathogen_creator")
				var/datum/microbe/P = src.cdc_creator[usr.ckey]
				switch (href_list["do"])
					//Reset
					if ("reset")
						P.clear()
					//Name
					if ("name")
						P.name = input("Microbe Name: ", "Name")		//No filters?
					//Infection Count
					if ("infection_count")
						P.infectioncount = text2num_safe(input("Infection count: ", "Infection Count") as num)
					//Total Duration
					if ("total_duration")
						P.durationtotal = text2num_safe(input("Total duration: ", "Total Duration") as num)
					//Suppressant/Cure + Description
					if ("suppressant")
						var/list/types = list()
						for (var/spath in src.path_to_suppressant)
							var/datum/suppressant/S = src.path_to_suppressant[spath]
							types += S.name
							types[S.name] = S
						var/chosen = input("Which suppressant?", "Suppressant", types[1]) in types
						P.suppressant = types[chosen]
						P.desc = "[P.suppressant.color] dodecahedrical microbes"
					//Add effect
					if ("add")
						var/list/types = list()
						for (var/efpath in src.path_to_effect)
							var/datum/microbioeffects/EF = src.path_to_effect[efpath]
							types += EF.name
							types[EF.name] = EF
						var/chosen = input("Which symptom?", "Add new symptom", types[1]) in types
						if (!(types[chosen] in P.effects))
							P.effects += types[chosen]
							var/datum/microbioeffects/EF = types[chosen]
							EF.onadd(P)
					//Remove effect
					if ("remove")
						var/datum/microbioeffects/EF = locate(href_list["which"])
						if (EF in P.effects)
							P.effects -= EF
					//Create
					if ("create")
						P.microbio_uid = next_uid
						next_uid++
						microbe_trees += P.name
						var/datum/microbiology_cdc/CDC = new /datum/microbiology_cdc(P.microbio_uid)
						microbe_trees[P.name] = CDC
						message_admins("[key_name(usr)] created a new pathogen ([P]) via the creator.")
						src.admin_germs(usr.ckey)

			//Microbe Data (Manipulate existing microbes)
			if ("strain_data")
				var/datum/microbiology_cdc/CDC = locate(href_list["which"])
				var/name = href_list["name"]
				var/datum/microbe/reference = CDC.infections[name]
				switch (href_list["data"])
					//"Cure all who have this specific microbial culture"
					if ("cure")
						var/count = 0
						for (var/mob/living/carbon/human/H in mobs)
							LAGCHECK(LAG_LOW)
							if (CDC.uid in H.microbes)
								var/datum/microbe/P = H.microbes[CDC.uid]
								if (P.name == name)
									H.cured(P)
									count++
						message_admins("[key_name(usr)] cured [count] humans from pathogen strain mutation [name].")
					//"Infect a selected player with this culture"
					if ("infect")
						var/mob/living/carbon/human/target = input("Who would you like to infect with this mutation?", "Infect") as mob in mobs//world
						if (!istype(target))
							boutput(usr, "<span class='alert'>Cannot infect that. Must be human.</span>")
						else
							target.infected(reference)
							message_admins("[key_name(usr)] infected [target] with [name].")
					//"Spawn a vial containing this microbial culture"
					if ("spawn")
						var/obj/item/reagent_containers/glass/vial/V = new /obj/item/reagent_containers/glass/vial(get_turf(usr))
						var/datum/reagent/blood/pathogen/RE = new /datum/reagent/blood/pathogen()
						RE.volume = 5
						RE.microbes += reference.microbio_uid
						RE.microbes[reference.microbio_uid] = reference
						RE.holder = V.reagents
						V.reagents.reagent_list += RE.id
						V.reagents.reagent_list[RE.id] = RE
						V.reagents.update_total()

			//Effect Data
			if ("effectdata")
				var/datum/microbioeffects/EF = locate(href_list["which"])
				switch (href_list["data"])
					if ("info")
						alert(usr, EF.desc)
		cdc_main(th)
		////////////////////////////////////
		//Ckey checking procs to handle stratae of admins and patho panel access
	var/list/cdc_creator = list()
	var/list/cdc_state = list()
	var/static/list/states = list("strains", "symptoms", "suppressant", "pathogen_creator")
		////
		//CDC HTML Infrastructure
		//All of it will be TGUI, eventually

	proc/cdc_main(var/topic_holder)
		//Check if the user is allowed to view this.
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

		//Set up panel
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
		//The table lists names, effects, suppressant/cure, who is infected, and actions.
		if (istext(state))
			output += "<h3>Details for pathogen strain [state]</h3>"
			if (state in microbe_trees)
				var/datum/microbiology_cdc/CDC = microbe_trees[state]
				output += "<table class='pathology-table'><thead><tr><th>Strain name</th><th>Symptoms</th><th>Suppressant</th><th>Infected</th><th>Actions</th></thead><tbody>"
				for (var/name in CDC.infections)
					output += "<tr>"
					var/datum/microbe/P = CDC.infections[name]
					output += "<td>[P.name]</td>"
					var/symptoms = ""
					for (var/datum/microbioeffects/EF in P.effects)
						symptoms += "[EF]<BR>"
					output += "<td>[symptoms]</td>"
					output += "<td>[P.suppressant.name]</td>"
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
					output += "<table class='pathology-table'><thead><tr><th>Created</th><th>Strain name</th><th>UID</th><th>Patient Zero</th><th>Infected</th><th>Immune</th><th>Cure all</th><th>Details</th><th>Logs</th></thead><tbody>"
					for (var/pathogen_name in microbe_trees)
						var/datum/microbiology_cdc/CDC = microbe_trees[pathogen_name]
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
							if (CDC.uid in M.microbes)
								infections++
							else if (CDC.uid in M.immunities)
								immunities++
						output += "<td>[infections]</td>"
						output += "<td>[immunities]</td>"
						output += "<td><a href='?src=\ref[src];action=strain_cure;strain=[pathogen_name];topic_holder=\ref[topic_holder]'>(CURE)</a></td>"
						output += "<td><a href='?src=\ref[src];action=strain_details;strain=[pathogen_name];topic_holder=\ref[topic_holder]'>(VIEW)</a></td>"
						output += "<td><a href='?src=\ref[topic_holder];action=view_logs_pathology_strain;presearch=[pathogen_name]'>(LOGS)</a></td>"
						output += "</tr>"
					output += "</tbody></table>"
				if ("symptoms")
					output += "<table class='pathology-table'><thead><tr><th>Name</th><th>Info</th></thead><tbody>"
					for (var/sym_path in src.path_to_effect)
						var/datum/microbioeffects/EF = src.path_to_effect[sym_path]
						output += "<tr>"
						output += "<td>[EF]</td>"
						output += "<td><a href='?src=\ref[src];action=effectdata;which=\ref[EF];data=info;topic_holder=\ref[topic_holder]'>Show information</a></td>"
				if ("suppressant")
					output += "<table class='pathology-table'><thead><tr><th>Name</th><th>Suppression reagents</th></thead><tbody>"
					for (var/sup_path in src.path_to_suppressant)
						output += "<tr>"
						var/datum/suppressant/S = src.path_to_suppressant[sup_path]
						output += "<td>[S]</td>"
						var/supp = ""
						for (var/reagent in S.cure_synthesis)
							supp += "[reagent]"
							supp += "<BR>"
						output += "<td>[supp]</td>"
						output += "</tr>"
				if ("pathogen_creator")
					var/datum/microbe/P = new /datum/microbe
					if (!(usr.ckey in src.cdc_creator))
						src.admin_germs(usr.ckey, P)
					output += "<h3>Pathogen Creator</h3>"
					if (P.name)
						output += "<b>Name: </b> [P.name]<br>"
					else
						output += "<a href='?src=\ref[src];action=pathogen_creator;do=name;topic_holder=\ref[topic_holder]'>Assign name</a><br>"
					if (P.suppressant)
						output += "<b>Description: </b> [P.desc]<br>"
						output += "<b>Suppressant: </b>[P.suppressant]<br><br>"
					else
						output += "<a href='?src=\ref[src];action=pathogen_creator;do=suppressant;topic_holder=\ref[topic_holder]'>Assign suppressant</a><br>"
					if (P.infectioncount)
						output += "<b>Infection Count: </b>[P.infectioncount]<br>"
					else
						output += "<a href='?src=\ref[src];action=pathogen_creator;do=infection_count;topic_holder=\ref[topic_holder]'>Set Infection Count</a><br>"
					if (P.durationtotal)
						output += "<b>Total Duration: </b>[P.durationtotal]<br>"
					else
						output += "<a href='?src=\ref[src];action=pathogen_creator;do=total_duration;topic_holder=\ref[topic_holder]'>Set Total Duration</a><br>"
					output += "<b>Effects: </b><br>"
					if (P.effects.len)
						for (var/datum/microbioeffects/EF in P.effects)
							output += "- [EF] <a href='?src=\ref[src];action=pathogen_creator;do=remove;which=\ref[EF];topic_holder=\ref[topic_holder]'>(remove)</a><br>"
					else
						output += " -- None -- <br>"
					output += "<a href='?src=\ref[src];action=pathogen_creator;do=add;topic_holder=\ref[topic_holder]'>Add effect</a><br><br>"
					output += "<a href='?src=\ref[src];action=pathogen_creator;do=reset;topic_holder=\ref[topic_holder]'>Reset pathogen</a>"
					if (P.suppressant && P.effects.len > 1 && P.name && P.infectioncount && P.durationtotal)
						output += " -- <a href='?src=\ref[src];action=pathogen_creator;do=create;topic_holder=\ref[topic_holder]'>Create pathogen</a>"
				else
					output += "<h1>NOTHING TO SEE HERE YET</h1>"
		output += "</body></html>"
		usr.Browse(output, "window=cdc;size=800x480")


	proc/admin_germs(var/key, var/datum/microbe/P)
		if (!(key in src.cdc_creator))
			src.cdc_creator += key
		src.cdc_creator[key] = P		//The key belonging to [this user] made [the microbe] with [this uid].
*/
	//Run on startup
	New()
		..()

		//Set a separate list for bad effects
		for (var/E in concrete_typesof(/datum/microbioeffects/malevolent))
			path_to_evil[E] = new E()

		//Discover all effects
		for (var/E in concrete_typesof(/datum/microbioeffects))
			path_to_effect[E] = new E()

		//Define all paths to suppressants
		for (var/T in childrentypesof(/datum/suppressant))
			path_to_suppressant[T] = new T()


var/global/datum/controller/microbe/microbe_controller = new()	//Callable everywhere.

// todo: remove this, port. (To where?)
// A wrapper record returned by the onshocked event of a pathogen symptom.
datum/shockparam
	var/amt
	var/wattage
	var/skipsupp

// A microbe. How surprising.
datum/microbe
	var/name										// The name of the microbial culture.
	var/desc										// What a scientist might see when he looks at this pathogen through a microscope (eg. blue stringy viruses)

	var/mob/infected								// The mob that is infected with this pathogen.
	var/infectioncount								// Int variable, used to limit transmissible spread for singular cultures

	var/duration									// Counter for durationtotal
	var/durationtotal								// How long a pathogen stays in an infected mob before being naturally immunized.

	var/datum/suppressant/suppressant				// Handles curing

	var/list/effects = list()						// A list of symptoms exhibited by those infected with this pathogen.
	var/list/effectdata = list()					// used for custom var calls
	//var/list/mutex = list()						// These symptoms are explicitly disallowed by a mutex.

	var/microbio_uid								// UID for a microbe.
	var/microbio_playerid							// sub-UID for multiple players with different infection times
	var/ticked										// Stops runtimes.
	var/probability									// Used in the effect probability function.

// PROCS AND FUNCTIONS FOR GENERATION

	disposing()
		clear()
		..()

	proc/clear()
		name = ""
		desc = ""
		infected = null
		infectioncount = null
		duration = 1
		durationtotal = 1
		suppressant = null
		effects = list()
		microbio_uid = 0
		microbio_playerid = 0
		//mutex = list()
		ticked = 0
		probability = 0

	proc/do_prefab()							// for ailments with defined symptoms
		clear()
		generate_name()
		generate_cure(src)
		generate_attributes()

	New()
		..()
		setup(0, null)

	//generate_name
	//Called on setup(1) for randomized generation and setup(2) for predefined ailments
	//Sets a new microbe's UID, PUID, and name
	//UID: Unique ID. Identical across different infected mobs with the same strain.
	//PUID: Player-Unique ID. Starts at 0 for every created microbe.
	proc/generate_name()
		src.microbio_uid = "[microbe_controller.next_uid]"
		microbe_controller.next_uid++
		src.microbio_playerid = 0
		src.name = "Custom Culture UID [src.microbio_uid]"
		return


	//generate_effects
	//Called only on setup(1) for random effects
	//Sets effects.
	//random: Currently uses a rand() to determine the for loop iterations.
	//The for loop uses the add_new_symptom function, which uses pick() to choose an effect and returns 1 if successful.
	proc/generate_effects() //WIP
		var/random = rand(2,5)
		for (var/i = 0, i <= random, i++)
			var/check = 0
			do
				check = add_new_symptom(microbe_controller.path_to_effect, 0)
			while (!check)

	//generate_cure
	//Called on setup 1 and 2 for random and prefab strains.
	//Uses pick() and sets the suppressant path on the microbe datum.
	proc/generate_cure(var/datum/microbe/P) //WIP
		var/S = pick(microbe_controller.path_to_suppressant)
		P.suppressant = microbe_controller.path_to_suppressant[S]

	//generate_attributes
	//Called on setup 1 and 2.
	//MUST BE CALLED AFTER GENERATE_CURE.
	//Sets the description, durations, initial probability, and infection count.
	//durationtotal and duration are values of lifeticks.
	//for 2*rand(60,120), microbes have a lifespan of 4 to 8 minutes.
	//Probability must start at 0.
	//Infection count is explained below.
	proc/generate_attributes() //WIP
		var/shape = pick("stringy", "snake", "blob", "spherical", "tetrahedral", "star shaped", "tesselated")
		src.desc = "[suppressant.color] [shape] microbes" //color determined by average of cure reagent and assigned-effect colors
		src.durationtotal = 2*rand(60,120)					//4 to 8 minute lifespan
		src.duration = src.durationtotal - 1
		src.probability = 0
		src.infectioncount = 3								// See below for explanation.

		//Infection count should be dependent on active player count, balanced at ~5-10% of living serverpop
		//For Goon1 at high pop (90-110), ~10 people per microbial culture
		//INFECTIONCOUNT IS CURRENTLY NOT A GLOBAL COUNT! IT IS A BRANCHING COUNTER!
		///////////////////////////////////////////////////////////////
		/** An infection count of 4 creates a propogation tree, because the count decreases on transmission and is not global.
		 * 4
		 * | \
		 * 3   3
		 * | \ | \
		 * 2 2 2 2
		 * |\|\|\|\
		 * 111111111
		 * ................
		 * 0000000000000000
		 *
		 * At the end, 16 different people could have been infected, assuming all potential transmissions occured.
		 *
		 * The maximum number of infections for a given infectioncount var is 2^(infectioncount).
		 *
		 * I am starting with (3), or 8 maximum infections, because I believe that 8 is a
		 * reasonable value for both highpop and lowpop (20-40) servers.
		 *
		 * I have no idea if this is an adequate implementation in the dev/admin/mentor's opinions.
		*/
		//Taken from the podwars code...
		//for (var/datum/mind/m in pw_team.members)
			//if (m.current?.ckey)
				//active_players ++

	proc/randomize()
		generate_name()
		generate_effects()
		generate_cure(src)
		generate_attributes()
		logTheThing("pathology", null, null, "Microbe culture [name] created by randomization.")
		return

	//setup
	//Inputs:
		//Status: effectively a switch case value.
		//0 + no ref. microbe -> early return. Only used by the New() in initialization.
		//0 + ref. microbe -> create a clone of the microbe with reset duration counters.
		//1 -> make a random strain.
		//2 -> prefab a strain. Effects are manually added using add_symptom after the function call.
		//microbe/origin: used only for status = 0.
	proc/setup(status, var/datum/microbe/origin)
		if (status == 0 && !origin)
			return
		if (origin)
			src.name = origin.name
			src.desc = origin.desc
			src.infectioncount = origin.infectioncount
			src.durationtotal = origin.durationtotal
			src.duration = origin.duration						// Start from the top for new infections/generation
			src.effects = origin.effects.Copy()
			for (var/datum/microbioeffects/E in src.effects)
				E.onadd(src)
			src.suppressant = origin.suppressant
			src.microbio_uid = origin.microbio_uid
			src.microbio_playerid = origin.microbio_playerid			// REMEMBER TO INCREMENT THE PUID EVERY INFECTION!
			src.ticked = 0
			src.probability = 0
		else if (status == 1)
			randomize()
		else if (!origin && status == 2)
			src.do_prefab()
		processing_items.Add(src)

	proc/process()
		if (ticked)
			ticked = 0

	// Handles pathogen duration and natural immunization.
	// It is critical that microbial infections are inherently transient (non-chronic).
	// All old pathology diseases were practically chronic (permanent), which isn't true for
	// most human-contagious diseases at all.
	// Microbiology also used stages to divide effect severity, which caused code bloating.
	/////////////////////////////////////////////////////////////////////////////////
	// progress_pathogen uses a continuous downward parabola function to determine the
	// probability for effects to act. The functionn zeroed at the
	// initial time of infection and at natural immunization.
	// The probability factors manipulate the function to move the apex of the parabola to (5),
	// representing a 5% base effect chance.
	// ceil() wraps the entire function to round probability to the higher integer.
	/////////////////////////////////////////////////////////////////////////////////
	// P(t) = -a*t^2 + b*t
	// Where a = 20/durationtotal**2 and b = 20/durationtotal
	proc/progress_pathogen(var/datum/microbe/P)
		if (P.duration <= 0)
			infected.cured(src)
			return
		var/B = 20/P.durationtotal
		var/A = B/P.durationtotal
		src.probability = ceil(-A*P.duration**2+B*P.duration)
		var/iscured = P.suppressant.suppress_act(src)
		if (iscured)
			P.duration = ceil(P.duration/2) - 1
			return
		else
			P.duration--							//  Wrap into process

//Generalize for objects and turfs [WIP]

	proc/turf_act(var/datum/microbe/P)
		for (var/datum/effect in src.effects)
			effect:turf_act(null, src)
		progress_pathogen(P)

	proc/object_act(var/datum/microbe/P)
		for (var/datum/effect in src.effects)
			effect:object_act(null, src)
		progress_pathogen(P)

	proc/reagent_act(var/datum/microbe/P)
		for (var/datum/effect in src.effects)
			effect:reagent_act(null, src)
		progress_pathogen(P)

	proc/mob_act(var/mob/M as mob, var/datum/microbe/P)
		for (var/datum/effect in src.effects)
			effect:mob_act(infected,src)
		progress_pathogen(P)

	// it's like mob_act, but for dead people!
	proc/mob_act_dead(var/mob/M as mob, var/datum/microbe/P)
		for (var/datum/effect in src.effects)
			effect:mob_act_dead(infected,src)
		progress_pathogen(P)

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

	proc/add_new_symptom(var/list/allowed, var/allow_evil)
		var/T = pick(allowed)
		var/datum/microbioeffects/E = microbe_controller.path_to_effect[T]
		if (add_symptom(E, allow_evil))
			return 1
		else
			return 0

	proc/add_symptom(var/datum/microbioeffects/E, var/allow_evil)
		if (istype(E,/datum/microbioeffects/malevolent) && allow_evil && !(E in effects))
			effects += E
			E.onadd(src)
			logTheThing("pathology", null, null, "Malevolent effect added to [src.name].")
			return 1
		else if ((!istype(E,/datum/microbioeffects/malevolent)) && !(E in effects))
			/*for (var/mutex in E.mutex)
				for (var/T in typesof(mutex))
					if (!(T in mutex))
						mutex += T*/
			effects += E
			E.onadd(src)
			return 1
		else return 0
/*
	proc/remove_symptom(var/datum/microbioeffects/E, var/all = 0)
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
				*/

//Mutex: Mutual exclusivity

/*
	proc/rebuild_mutex()
		src.mutex = list()
		for (var/datum/pathogeneffects/E in src.effects)
			for (var/mutex in E.mutex)
				for (var/T in typesof(mutex))
					if (!(T in mutex))
						mutex += T
*/
