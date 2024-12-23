var/datum/hydroponics_controller/hydro_controls

//some things (mostly items places on the map) call procs on this datum before it exists, queue them instead
var/global/list/hydro_controller_queue = list(
	"species" = list(),
	"mutation" = list(),
	"strain" = list()
)

/datum/hydroponics_controller/
	// global variable name is currently "hydro_controls"
	var/max_harvest_cap = 10          // How many items can be harvested at once.
	var/delay_between_harvests = 300  // How long between harvests, in spawn ticks.
	var/list/plant_species = list()
	var/list/mutations = list()
	var/list/strains = list()
	var/list/vendable_plants = list()

	var/image/pot_death_display = null
	var/image/pot_health_display = null
	var/image/pot_harvest_display = null


	proc/set_up()
		pot_death_display = image('icons/obj/hydroponics/machines_hydroponics.dmi', "led-dead")
		pot_health_display = image('icons/obj/hydroponics/machines_hydroponics.dmi', "led-health")
		pot_harvest_display = image('icons/obj/hydroponics/machines_hydroponics.dmi', "led-harv")

		for (var/B in concrete_typesof(/datum/plantmutation))
			src.mutations += new B(src)

		for (var/C in concrete_typesof(/datum/plant_gene_strain))
			src.strains += new C(src)

		// You need to do plants after the others or they won't set up properly due to mutations and strains
		// not having been set up yet
		for (var/A in concrete_typesof(/datum/plant))
			src.plant_species += new A(src)

		SPAWN(0)
			for (var/datum/plant/P in src.plant_species)
				for (var/X in P.mutations)
					if (ispath(X))
						P.mutations += HY_get_mutation_from_path(X)
						P.mutations -= X

				for (var/X in P.commuts)
					if (ispath(X))
						P.commuts += HY_get_strain_from_path(X)
						P.commuts -= X

				if (P.vending)
					vendable_plants += P

			src.process_queue()


	//clear any entries in queue
	proc/process_queue()
		//clear species lookups
		for (var/key in hydro_controller_queue["species"])
			var/list/entry = hydro_controller_queue["species"][key]
			var/species_path = entry["path"]
			var/obj/item/thing = entry["thing"]
			var/datum/plant/species

			for (var/datum/plant/P in src.plant_species)
				if (species_path == P.type)
					species = P
					break

			thing.HY_set_species(species)
			hydro_controller_queue["species"] -= key

		//clear mutation lookups
		for (var/key in hydro_controller_queue["mutation"])
			var/list/entry = hydro_controller_queue["mutation"][key]
			var/mutation_path = entry["path"]
			var/obj/item/thing = entry["thing"]
			var/datum/plantmutation/mutation

			for (var/datum/plantmutation/M in src.mutations)
				if (mutation_path == M.type)
					mutation = M
					break

			thing.HY_set_mutation(mutation)
			hydro_controller_queue["mutation"] -= key

		//clear strain lookups
		for (var/key in hydro_controller_queue["strain"])
			var/list/entry = hydro_controller_queue["strain"][key]
			var/strain_path = entry["path"]
			var/obj/item/thing = entry["thing"]
			var/datum/plant_gene_strain/strain

			for (var/datum/plant_gene_strain/S in src.strains)
				if (strain_path == S.type)
					strain = S
					break

			thing.HY_set_strain(strain)
			hydro_controller_queue["strain"] -= key


/proc/HY_get_species_from_path(var/species_path, var/obj/item/thing)
	if (!hydro_controls)
		if (thing)
			hydro_controller_queue["species"]["[length(hydro_controller_queue["species"])]"] = list("path" = species_path, "thing" = thing)
		else
			logTheThing(LOG_DEBUG, null, "<b>Hydro Controller:</b> Attempt to find species before controller setup")
		return null
	if (!species_path)
		logTheThing(LOG_DEBUG, null, "<b>Hydro Controller:</b> Attempt to find species with null path in controller")
		return null
	if (!hydro_controls.plant_species.len)
		logTheThing(LOG_DEBUG, null, "<b>Hydro Controller:</b> Cant find species due to empty species list in controller")
		return null
	for (var/datum/plant/P in hydro_controls.plant_species)
		if (species_path == P.type)
			return P
	logTheThing(LOG_DEBUG, null, "<b>Hydro Controller:</b> Species \"[species_path]\" not found")
	return null

/proc/HY_get_mutation_from_path(var/mutation_path, var/obj/item/thing)
	if (!hydro_controls)
		if (thing)
			hydro_controller_queue["mutation"]["[length(hydro_controller_queue["mutation"])]"] = list("path" = mutation_path, "thing" = thing)
		else
			logTheThing(LOG_DEBUG, null, "<b>Hydro Controller:</b> Attempt to find mutation before controller setup")
		return null
	if (!mutation_path)
		logTheThing(LOG_DEBUG, null, "<b>Hydro Controller:</b> Attempt to find mutation with null path in controller")
		return null
	if (!hydro_controls.mutations.len)
		logTheThing(LOG_DEBUG, null, "<b>Hydro Controller:</b> Cant find mutation due to empty mutation list in controller")
		return null
	for (var/datum/plantmutation/M in hydro_controls.mutations)
		if (mutation_path == M.type)
			return M
	logTheThing(LOG_DEBUG, null, "<b>Hydro Controller:</b> Mutation \"[mutation_path]\" not found")
	return null

/proc/HY_get_strain_from_path(var/strain_path, var/obj/item/thing)
	if (!hydro_controls)
		if (thing)
			hydro_controller_queue["strain"]["[length(hydro_controller_queue["strain"])]"] = list("path" = strain_path, "thing" = thing)
		else
			logTheThing(LOG_DEBUG, null, "<b>Hydro Controller:</b> Attempt to find strain before controller setup")
		return null
	if (!strain_path)
		logTheThing(LOG_DEBUG, null, "<b>Hydro Controller:</b> Attempt to find strain with null path in controller")
		return null
	if (!hydro_controls.strains.len)
		logTheThing(LOG_DEBUG, null, "<b>Hydro Controller:</b> Cant find strain due to empty strain list in controller")
		return null
	for (var/datum/plant_gene_strain/S in hydro_controls.strains)
		if (strain_path == S.type)
			return S
	logTheThing(LOG_DEBUG, null, "<b>Hydro Controller:</b> Strain \"[strain_path]\" not found")
	return null
