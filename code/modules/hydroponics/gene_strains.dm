/datum/plant_gene_strain
	var/name = null                 // self-explanatory
	var/desc = null                 // this too
	var/strain_type = "gene strain" // is this a gene strain? a disease? a parasite?
	var/chance = 10                 // base chance of this mutation developing
	var/negative = 0                // is this mutation something you shouldn't want?
	var/process_proc_chance = 100   // on_process's chance of actually occurring per call

	proc/on_process(var/obj/machinery/plantpot/PP)
		if (!PP)
			return 1
		if (!PP.current)
			return 1
		if (!prob(process_proc_chance))
			return 1

	//This proc is called when a commut does modify a stat. This lets more plants be affected by stuff like superior quality
	//and move some magic numbers out of plantpot.dm
	//This proc takes the base value of the stat and returns a modifier that is added/subtracted from the plant
	proc/get_plant_stat_modifier(var/datum/plantgenes/gene_pool, var/gene_stat as text, var/value_base)
		if (!gene_pool || !gene_stat)
			return 0

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

/datum/plant_gene_strain/metabolism_slow
	name = "Slow Metabolism"
	desc = "This gene slows the growth of a plant, but reduces water consumption."

/datum/plant_gene_strain/growth_fast
	name = "Rapid Growth"
	desc = "This gene causes a plant to grow more rapidly with no drawbacks."

	on_process(var/obj/machinery/plantpot/PP)
		if (..())
			return
		PP.growth += 2

/datum/plant_gene_strain/growth_slow
	name = "Stunted Growth"
	desc = "This gene slows down a plant's growth rate."
	negative = 1

	on_process(var/obj/machinery/plantpot/PP)
		if (..())
			return
		if (PP.growth > 1)
			PP.growth--

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
			return max(0, value_base * src.quality_mult)

/datum/plant_gene_strain/quality/inferior
	name = "Inferior Quality"
	desc = "Produce harvested from this plant will be of much worse quality than usual."
	quality_mult = -0.2
	negative = 1

	get_plant_stat_modifier(var/datum/plantgenes/gene_pool, var/gene_stat as text, var/value_base)
		if (!gene_pool || !gene_stat)
			return 0
		if (gene_stat == "potency")
			return min(0, value_base * src.quality_mult)

/datum/plant_gene_strain/splicing
	name = "Splice Enabler"
	desc = "Chromosomal alterations enable seeds from this plant to be spliced with others more easily."
	var/splice_mod = 20

/datum/plant_gene_strain/splicing/bad
	name = "Splice Blocker"
	desc = "Chromosomal alterations prevent seeds from this plant from being spliced as easily."
	negative = 1

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
	process_proc_chance = 24

	on_process(var/obj/machinery/plantpot/PP)
		if (..())
			return
		PP.HYPdamageplant("frailty",1)

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

	on_process(var/obj/machinery/plantpot/PP)
		if (..())
			return
		PP.HYPkillplant()

/datum/plant_gene_strain/unstable
	name = "Unstable"
	desc = "Weakening of the genetic structure will cause this plant to mutate by itself."
	process_proc_chance = 18

	on_process(var/obj/machinery/plantpot/PP)
		if (..())
			return
		PP.HYPmutateplant(1)

/datum/plant_gene_strain/stabilizer
	name = "Stabilizer"
	desc = "A strengthened genetic structure prevents mutations from occurring."

/datum/plant_gene_strain/accelerator
	name = "Accelerator"
	desc = "A highly rare gene strain that will cause the plant to gradually improve its own growth rate."
	process_proc_chance = 10

	on_process(var/obj/machinery/plantpot/PP)
		if (..())
			return
		var/datum/plantgenes/DNA = PP.plantgenes
		DNA.growtime++
		DNA.harvtime++

/datum/plant_gene_strain/photosynthesis
	name = "Advanced Photosynthesis"
	desc = "A chlorophyll mutation causing the plant to respond very well to high amounts of light."

	on_process(var/obj/machinery/plantpot/PP)
		if (..())
			return
		var/turf/T = PP.loc
		if (istype(T,/turf/) && T.RL_GetBrightness() >= 1)
			PP.growth += 2

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
