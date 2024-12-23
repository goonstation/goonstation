ABSTRACT_TYPE(/datum/plant_gene_strain)
/datum/plant_gene_strain
	var/name = null                 // self-explanatory
	var/desc = null                 // this too
	var/strain_type = "gene strain" // is this a gene strain? a disease? a parasite?
	var/chance = 10                 // base chance of this mutation developing
	var/negative = 0                // is this mutation something you shouldn't want?
	var/process_proc_chance = 100   // on_process's chance of actually occurring per call

	proc/on_process(var/obj/machinery/plantpot/PP, var/datum/plantgrowth_tick/growth_tick)
		if (!PP)
			return 1
		if (!PP.current)
			return 1
		if (!growth_tick)
			return 1
		if (!prob(process_proc_chance))
			return 1

	/// This proc is called when a commut does modify a stat. This lets more plants be affected by stuff like superior quality
	/// and move some magic numbers out of plantpot.dm
	/// This proc takes the base value of the stat and returns a modifier that is added/subtracted from the plant
	proc/get_plant_stat_modifier(var/datum/plantgenes/gene_pool, var/gene_stat as text, var/value_base)
		if (!gene_pool || !gene_stat)
			return 0

	/// This proc is called after a seed is created and received all changes associated with being spliced
	/// This should also be called whenever you have changes that need to be done whenever this commut touches a seed
	proc/changes_after_splicing(var/datum/plantgenes/gene_pool)
		if (gene_pool)
			return TRUE

	/// This proc is called when a plant or seed firstly receives the gene strain in question e.g. through HYPaddCommut, HYPnewcommutcheck.
	/// Use this if you want to manipulate the plantgenes if its the first time the generation of seeds gains it
	/// This is not called when a seed receive this plant gene through passing along the generation e.g. splicing or HYPpassplantgenes.
	proc/on_addition(var/datum/plantgenes/gene_pool)
		if (gene_pool)
			return TRUE

	/// This proc is called when a plant or seed firstly receives the gene strain in question e.g. throught splicing or HYPpassplantgenes.
	/// call this if you want a certain effect to happen multiple times each generation.
	proc/on_passing(var/datum/plantgenes/gene_pool)
		if (gene_pool)
			return TRUE

	/// This proc is called when a plant or seed removes the gene strain in question e.g. through HYPremoveCommut
	/// This may be usefull for some whacky gene strains that do something when added and decides at some point to remove themselves and e.g. tank stats as a result
	proc/on_removal(var/datum/plantgenes/gene_pool)
		if (gene_pool)
			return TRUE

/datum/plant_gene_strain/temporary_splice_stabilizer
	name = "Temporary Spliceability"
	desc = "This seed was stabilized using advanced technology to be spliced once and won't be able to be spliced afterwards."

	changes_after_splicing(var/datum/plantgenes/gene_pool)
		. = ..()
		if (.)
			//we remove this commut and add splice disabler
			HYPremoveCommut(gene_pool, /datum/plant_gene_strain/temporary_splice_stabilizer)
			HYPaddCommut(gene_pool, /datum/plant_gene_strain/splicing/disabled)

/datum/plant_gene_strain/overpowering_genome
	name = "Overpowering Genome"
	desc = "This seed's genomes are all dominant at all times"

	on_addition(var/datum/plantgenes/gene_pool)
		. = ..()
		if (.)
			gene_pool.d_species = 1
			gene_pool.d_growtime = 1
			gene_pool.d_harvtime = 1
			gene_pool.d_cropsize = 1
			gene_pool.d_harvests = 1
			gene_pool.d_potency = 1
			gene_pool.d_endurance = 1

	on_passing(var/datum/plantgenes/gene_pool)
		. = ..()
		if (.)
			gene_pool.d_species = 1
			gene_pool.d_growtime = 1
			gene_pool.d_harvtime = 1
			gene_pool.d_cropsize = 1
			gene_pool.d_harvests = 1
			gene_pool.d_potency = 1
			gene_pool.d_endurance = 1


/datum/plant_gene_strain/accepting_genome
	name = "Accepting Genome"
	desc = "This seed's genomes are all recessive at all times"

	on_addition(var/datum/plantgenes/gene_pool)
		. = ..()
		if (. && !HYPCheckCommut(gene_pool, /datum/plant_gene_strain/overpowering_genome))
			gene_pool.d_species = 0
			gene_pool.d_growtime = 0
			gene_pool.d_harvtime = 0
			gene_pool.d_cropsize = 0
			gene_pool.d_harvests = 0
			gene_pool.d_potency = 0
			gene_pool.d_endurance = 0

	on_passing(var/datum/plantgenes/gene_pool)
		. = ..()
		if (. && !HYPCheckCommut(gene_pool, /datum/plant_gene_strain/overpowering_genome))
			gene_pool.d_species = 0
			gene_pool.d_growtime = 0
			gene_pool.d_harvtime = 0
			gene_pool.d_cropsize = 0
			gene_pool.d_harvests = 0
			gene_pool.d_potency = 0
			gene_pool.d_endurance = 0

/datum/plant_gene_strain/immunity_toxin
	name = "Toxin Immunity"
	desc = "This genetic strain enables a plant to wholly resist damage from toxic substances."

/datum/plant_gene_strain/immunity_radiation
	name = "Radiation Immunity"
	desc = "Strengthening the gene structure, this mutation eliminates all radiation damage to the plant."

/datum/plant_gene_strain/resistance_drought
	name = "Drought Resistance"
	desc = "Enhanced fluid retention enables this genetic strain to protect the plant from drought."

/datum/plant_gene_strain/metabolism_fast
	name = "Fast Metabolism"
	desc = "This gene causes a plant to grow faster, but also consume water more rapidly."

	on_process(var/obj/machinery/plantpot/PP, var/datum/plantgrowth_tick/growth_tick)
		if (..())
			return
		growth_tick.tick_multiplier += 0.5
		growth_tick.water_consumption += 1

/datum/plant_gene_strain/inert
	name = "Inert"
	desc = "This gene causes the plants produce to spawn, most of the time, without additional chemicals."

/datum/plant_gene_strain/metabolism_slow
	name = "Slow Metabolism"
	desc = "This gene slows the growth of a plant, but reduces water consumption."

	on_process(var/obj/machinery/plantpot/PP, var/datum/plantgrowth_tick/growth_tick)
		if (..())
			return
		growth_tick.tick_multiplier -= 0.25
		growth_tick.water_consumption -= 0.5

/datum/plant_gene_strain/growth_fast
	name = "Rapid Growth"
	desc = "This gene causes a plant to grow more rapidly with no drawbacks."

	on_process(var/obj/machinery/plantpot/PP, var/datum/plantgrowth_tick/growth_tick)
		if (..())
			return
		growth_tick.growth_rate += 2

/datum/plant_gene_strain/growth_slow
	name = "Stunted Growth"
	desc = "This gene slows down a plant's growth rate."
	negative = 1

	on_process(var/obj/machinery/plantpot/PP, var/datum/plantgrowth_tick/growth_tick)
		if (..())
			return
		if (PP.growth > 1)
			growth_tick.growth_rate -= 1

/datum/plant_gene_strain/invasive
	name = "Invasive Growth"
	desc = "This gene causes the plant to take over other trays and grow onto other plants."
	chance = 4 //this is a rare gene that is worth hunting for

	on_process(var/obj/machinery/plantpot/carrying_plantpot, var/datum/plantgrowth_tick/growth_tick)
		if (..())
			return
		var/damage_to_other_plants = 10 // the amount of damage the plant deals to other plants
		var/chance_to_damage = 20 // the chance per tick to damage plants or spread per tick.
		var/health_treshold_for_spreading = 50 // percentage amount of starting health of the plant needed to be able to spread

		var/datum/plant/current_planttype = carrying_plantpot.current
		var/datum/plantgenes/current_plantgenes = carrying_plantpot.plantgenes
		//This is normal behaviour on the creeper, we don't need to let it run twice. Instead, we improve the base behaviour of the creeper in it's respectable logic
		if (istype(current_planttype, /datum/plant/artifact/creeper))
			return
		// We check for the health treshold and if we have grown sufficiently
		if (carrying_plantpot.get_current_growth_stage() >= HYP_GROWTH_MATURED && carrying_plantpot.health > round(current_planttype.starthealth * health_treshold_for_spreading / 100) && prob(chance_to_damage))
			for (var/obj/machinery/plantpot/checked_plantpot in range(1,carrying_plantpot))
				var/datum/plant/growing = checked_plantpot.current
				// We don't try to destroy plants of our own type and cannot attack crystals
				if (!checked_plantpot.dead && growing && !istype(growing,/datum/plant/crystal) && !istype(growing, current_planttype))
					checked_plantpot.HYPdamageplant("physical", damage_to_other_plants, 1)
				else if (checked_plantpot.dead)
					checked_plantpot.HYPdestroyplant()
				//Seedless prevents the plant from replanting. And inhibited potential as well.... no infinite maneaters, folks
				else if (!growing && !HYPCheckCommut(current_plantgenes, /datum/plant_gene_strain/seedless) && !HYPCheckCommut(current_plantgenes, /datum/plant_gene_strain/reagent_blacklist))
					//we create a new seed now
					var/obj/item/seed/temporary_seed = HYPgenerateseedcopy(current_plantgenes, current_planttype, carrying_plantpot.generation)
					// now we are able to plant the seed
					checked_plantpot.HYPnewplant(temporary_seed)
					spawn(0.5 SECONDS)
						qdel(temporary_seed)
					break

/datum/plant_gene_strain/yield
	name = "Enhanced Yield"
	desc = "This gene allows a plant to grow a greater number of items without any harm done."
	var/yield_mod = 0
	var/yield_mult = 2

/datum/plant_gene_strain/yield/stunted
	name = "Stunted Yield"
	desc = "This gene reduces the amount of viable items a plant will produce."
	negative = 1

/datum/plant_gene_strain/quality
	name = "Superior Quality"
	desc = "Produce harvested from this plant will be of a greater quality than usual."
	var/quality_mult = 0.2
	var/quality_mod = 5

	get_plant_stat_modifier(var/datum/plantgenes/gene_pool, var/gene_stat as text, var/value_base)
		if (!gene_pool || !gene_stat)
			return 0
		if (gene_stat == "potency")
			return max(value_base * src.quality_mult * -1, value_base * src.quality_mult)

/datum/plant_gene_strain/quality/inferior
	name = "Inferior Quality"
	desc = "Produce harvested from this plant will be of much worse quality than usual."
	quality_mult = -0.2
	negative = 1

	get_plant_stat_modifier(var/datum/plantgenes/gene_pool, var/gene_stat as text, var/value_base)
		if (!gene_pool || !gene_stat)
			return 0
		if (gene_stat == "potency")
			return min(value_base * src.quality_mult * -1, value_base * src.quality_mult)

/datum/plant_gene_strain/splicing
	name = "Splice Enabler"
	desc = "Chromosomal alterations enable seeds from this plant to be spliced with others more easily."
	var/splice_mod = 20

/datum/plant_gene_strain/splicing/bad
	name = "Splice Blocker"
	desc = "Chromosomal alterations prevent seeds from this plant from being spliced as easily."
	negative = 1

/datum/plant_gene_strain/splicing/disabled
	name = "Splice Disabler"
	desc = "Chromosomal alterations prevent seeds from this plant from being spliced at all."
	negative = 1
	splice_mod = 100

/datum/plant_gene_strain/damage_res
	name = "Damage Resistance"
	desc = "Enables the plant to take less damage from anything that would harm it."
	var/damage_mod = 0
	var/damage_mult = 2

/datum/plant_gene_strain/damage_res/bad
	name = "Vulnerability"
	desc = "Frail growth makes this plant much more susceptible to any kind of damage."
	negative = 1

/datum/plant_gene_strain/mutations
	name = "Mutagenic"
	desc = "Quirks in the plant's genetic structure cause mutations to occur more easily than usual."
	var/chance_mod = 15

/datum/plant_gene_strain/mutations/bad
	name = "Anti-Mutagenic"
	desc = "This plant's genetic structure makes mutations less likely to occur."
	negative = 1

/datum/plant_gene_strain/health_poor
	name = "Poor Health"
	desc = "A harmful gene strain that will cause gradual and continuous damage to the plant."
	negative = 1

	on_process(var/obj/machinery/plantpot/PP, var/datum/plantgrowth_tick/growth_tick)
		if (..())
			return
		growth_tick.health_change -= 0.24

/datum/plant_gene_strain/seedless
	name = "Seedless"
	desc = "A gene strain that renders the plant infertile. It will not produce any seeds."
	negative = 1

/datum/plant_gene_strain/immortal
	name = "Immortal"
	desc = "A rare and valued gene strain that allows infinite harvests from fruiting plants."

/datum/plant_gene_strain/terminator
	name = "Terminator"
	desc = "A drastic genetic fault which can rarely cause plants to suddenly die."
	process_proc_chance = 1
	negative = 1

	on_process(var/obj/machinery/plantpot/PP, var/datum/plantgrowth_tick/growth_tick)
		if (..())
			return
		PP.HYPkillplant()

/datum/plant_gene_strain/unstable
	name = "Unstable"
	desc = "Weakening of the genetic structure will cause this plant to mutate by itself."

	on_process(var/obj/machinery/plantpot/PP, var/datum/plantgrowth_tick/growth_tick)
		if (..())
			return
		growth_tick.mutation_severity += 0.18

/datum/plant_gene_strain/stabilizer
	name = "Stabilizer"
	desc = "A strengthened genetic structure prevents mutations from occurring."

/datum/plant_gene_strain/accelerator
	name = "Accelerator"
	desc = "A highly rare gene strain that will cause the plant to gradually improve its own growth rate."

	on_process(var/obj/machinery/plantpot/PP, var/datum/plantgrowth_tick/growth_tick)
		if (..())
			return
		growth_tick.growtime_bonus += 0.1
		growth_tick.harvtime_bonus += 0.1

/datum/plant_gene_strain/photosynthesis
	name = "Advanced Photosynthesis"
	desc = "A chlorophyll mutation causing the plant to respond very well to high amounts of light."

	on_process(var/obj/machinery/plantpot/PP, var/datum/plantgrowth_tick/growth_tick)
		if (..())
			return
		var/turf/T = PP.loc
		if (istype(T,/turf/) && T.RL_GetBrightness() >= 1)
			growth_tick.growth_rate += 2

/datum/plant_gene_strain/variable_harvest
	name = "Variable Harvest"
	desc = "This gene causes the plant to produce a variable number of harvests."
	chance = 50

/datum/plant_gene_strain/reagent_adder
	name = "Hyperaquacity"
	desc = "Produce harvested from this plant will contain a higher than usual amount of water."
	var/list/reagents_to_add = list("water")

/datum/plant_gene_strain/reagent_adder/toxic
	name = "Toxic"
	desc = "Produce harvested from this plant may contain toxic substances."
	reagents_to_add = list ("toxin")

/datum/plant_gene_strain/reagent_adder/lasher
	name = "Enzymatic"
	desc = "Produce harvested from this plant may contain powerful enzymes."
	reagents_to_add = list ("booster_enzyme")

/datum/plant_gene_strain/reagent_blacklist
	name = "Inhibited Potential"
	desc = "Produce harvested from this plant won't contain special dangerous chemicals"
	var/list/reagents_to_remove = list("ghostchilijuice", "potassium", "lithium")
