ABSTRACT_TYPE(/datum/plantmutation)
/datum/plantmutation
	var/name = null // If this is set, plants will use this instead of regular plant name
	var/crop = null // What crop does it give?
	var/plant_icon = null // same as in base plant thing really
	var/iconmod = null // name of the sprite files in hydro_mutants.dmi
	var/harvest_override = 0 // If 1, you can harvest it irregardless of the plant's base harvestability
	var/harvested_proc_override = 0
	var/harvest_cap = null //if truthy, override the global harvest cap. Set this above the default at your own risk
	var/special_proc_override = FALSE
	// If 0, just use the base plant's settings
	// If 1, use the mutation's special_proc instead
	// If anything else, use both the base and the mutant procs
	var/attacked_proc_override = 0
	var/name_prefix = ""	// Prepend to plant name
	var/name_suffix = ""	// Append to plant name
	/// If the crop should not be renamed based on the plant's mutation.
	var/dont_rename_crop = FALSE

	// Ranges various genes have to be in to get the mutation to appear - lower and upper bound
	var/list/GTrange = list(null,null) // null means there is no limit so an upper bound of 25
	var/list/HTrange = list(null,null) // and no lower bound means the mutation will occur when
	var/list/HVrange = list(null,null) // the plant is below 25 in that gene, but can be as low
	var/list/CZrange = list(null,null) // as it wants otherwise with no consideration
	var/list/PTrange = list(null,null)
	var/list/ENrange = list(null,null)
	var/commut = null // is a paticular common mutation required for this? (keeping it to 1 for now)
	/// Is a particular other mutation required for this? (type not instance)
	var/datum/plantmutation/required_mutation = null
	var/chance = 8 // How likely out of 100% is this mutation to appear when conditions are met?
	var/list/infusion_reagents = list() //! what reagents cause this mutation on infusion
	var/infusion_chance = 100 //! chance of an infusion of one of those reagents producing this mutation
	var/list/assoc_reagents = list() // Used for extractions, harvesting, etc

	var/lasterr = 0

	var/mutation_sfx = 'sound/effects/plant_mutation.ogg'

	///Override the crop's brew result
	var/brew_result = null

	proc/HYPharvested_proc_M(var/obj/machinery/plantpot/POT, var/mob/user)
		lasterr = 0
		if (!POT || !user) return 301
		if (POT.dead || !POT.current) return 302
		if (lasterr)
			logTheThing(LOG_DEBUG, null, "<b>Plant HYP</b> [src] in pot [POT] failed with error [.]")
			harvested_proc_override = 0
		return lasterr

	proc/HYPspecial_proc_M(var/obj/machinery/plantpot/POT)
		lasterr = 0
		if (!POT) lasterr = 401
		if (POT.dead || !POT.current) lasterr = 402
		if (lasterr)
			logTheThing(LOG_DEBUG, null, "<b>Plant HYP</b> [src] in pot [POT] failed with error [.]")
			special_proc_override = FALSE
		return lasterr

	proc/HYPattacked_proc_M(var/obj/machinery/plantpot/POT,var/mob/user)
		lasterr = 0
		if (!POT) lasterr = 501
		if (POT.dead || !POT.current) lasterr = 502
		if (lasterr)
			logTheThing(LOG_DEBUG, null, "<b>Plant HYP</b> [src] in pot [POT] failed with error [.]")
			attacked_proc_override = 0
		return lasterr

	//I'm continuing this bizzare naming convention only because not doing so would be worse
	///When the plant matures
	proc/HYPmatured_proc_M(var/obj/machinery/plantpot/POT)
		return

	///When the plant is destroyed or picked up by a trowel
	proc/HYPdestroyplant_proc_M(var/obj/machinery/plantpot/POT)
		return

	///When the plant is put in a decorative pot
	proc/HYPpotted_proc_M(var/obj/decorative_pot/POT, var/grow_level)
		return

	///When the plant mutates to this mutation and you need to adjusted its stats/commuts (either in seed in plantmaster or pot)
	proc/HYPon_mutation_general(var/datum/plant/parent_plant, var/datum/plantgenes/passed_genes)
		return

	///When the plant mutates to this mutation and you want something special (like mutates with a burst of flames)
	proc/HYPon_mutation_pot(var/datum/plant/parent_plant, var/obj/machinery/plantpot/passed_plantpot, var/datum/plantgenes/passed_genes)
		return

// Tomato Mutations

/datum/plantmutation/tomato/incendiary
	name = "Seething Tomato"
	name_prefix = "Seething "
	crop = /obj/item/reagent_containers/food/snacks/plant/tomato/incendiary
	iconmod = "TomatoExplosive"
	assoc_reagents = list("fuel")
	infusion_chance = 33
	infusion_reagents = list("phlogiston", "infernite", "pyrosium", "sorium")
	chance = 0

/datum/plantmutation/tomato/killer
	name = "Suspicious Tomato"
	name_prefix = "Suspicious "
	crop = /obj/critter/killertomato
	iconmod = "TomatoKiller"
	assoc_reagents = list("blood")
	harvest_cap = 3
	infusion_chance = 50
	infusion_reagents = list("strange_reagent")
	chance = 0

// Corn Mutations

/datum/plantmutation/corn/clear
	crop = /obj/item/reagent_containers/food/snacks/plant/corn/clear
	iconmod = "CornClear"
	name_prefix = "Clear "
	assoc_reagents = list("ethanol")

/datum/plantmutation/corn/pepper
	crop = /obj/item/reagent_containers/food/snacks/plant/corn/pepper
	iconmod = "peppercorn"
	name_prefix = "Pepper "
	assoc_reagents = list("pepper")

// Pea Mutations

/datum/plantmutation/peas/ammonia
	crop = /obj/item/reagent_containers/food/snacks/plant/peas/ammonia
	iconmod = "GoldenPeas"
	name_prefix = "Golden "
	assoc_reagents = list("ammonia")

// Grape Mutations

/datum/plantmutation/grapes/green
	name_prefix = "Green "
	crop = /obj/item/reagent_containers/food/snacks/plant/grape/green
	iconmod = "GrapeGreen"
	assoc_reagents = list("insulin")

/datum/plantmutation/grapes/fruit
	name = "Grapefruit"
	crop = /obj/item/reagent_containers/food/snacks/plant/grapefruit
	iconmod = "GrapeFruit"
	assoc_reagents = list("juice_grapefruit")

// Orange Mutations

/datum/plantmutation/orange/blood
	name = "Blood Orange"
	name_prefix = "Blood "
	crop = /obj/item/reagent_containers/food/snacks/plant/orange/blood
	iconmod = "OrangeBlood"
	assoc_reagents = list("bloodc") // heh

/datum/plantmutation/orange/clockwork
	name = "Clockwork Orange"
	name_prefix = "Clockwork "
	crop = /obj/item/reagent_containers/food/snacks/plant/orange/clockwork
	iconmod = "OrangeClockwork"
	assoc_reagents = list("iron")
	ENrange = list(30,null)
	chance = 20

// Apple Mutations

/datum/plantmutation/apple/poison
	name = "Delicious Apple"
	name_prefix = "Delicious "
	crop = /obj/item/reagent_containers/food/snacks/plant/apple/poison
	iconmod = "ApplePoison"
	assoc_reagents = list("capulettium")
	ENrange = list(40,null)
	chance = 10

// Pear Mutations

/* This is cool and definitely does not belong in the trash, and should probably be legitimately attainable.
/datum/plantmutation/pear/sickly
	name = "Sickly Pear"
	crop = /obj/item/reagent_containers/food/snacks/plant/pear/sickly
	assoc_reagents = list("too much")

*/

// Melon Mutations

/datum/plantmutation/melon/george
	name = "Rainbow Melons"
	name_prefix = "Rainbow "
	crop = /obj/item/reagent_containers/food/snacks/plant/melon/george
	iconmod = "MelonRainbow"
	assoc_reagents = list("george_melonium")

/datum/plantmutation/melon/balloon
	name = "Balloon Melons"
	name_prefix = "Balloon "
	crop = /obj/item/reagent_containers/balloon/naturally_grown
	iconmod = "MelonBalloon"
	assoc_reagents = list("helium")
	infusion_reagents = list("helium")
	infusion_chance = 50
	chance = 0

/datum/plantmutation/melon/hindenballoon
	name = "Balloon... Melons?"
	name_prefix = "Balloon "
	crop = /obj/item/reagent_containers/balloon/naturally_grown
	iconmod = "MelonBalloon"
	assoc_reagents = list("hydrogen")
	infusion_reagents = list("hydrogen")
	infusion_chance = 50
	chance = 0

/datum/plantmutation/melon/bowling
	name = "Bowling Melons"
	name_prefix = "Bowling "
	crop = /obj/item/reagent_containers/food/snacks/plant/melon/bowling
	iconmod = "MelonBowling"
	ENrange = list(12,null)
	chance = 20
	special_proc_override = TRUE

	HYPspecial_proc_M(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plantgenes/DNA = POT.plantgenes

		var/thud_prob = clamp(DNA?.get_effective_value("endurance") / 2, 0, 100)

		if (prob(thud_prob))
			playsound(POT, 'sound/effects/exlow.ogg', 30, TRUE)
			animate_wiggle_then_reset(POT)


// Bean Mutations

/datum/plantmutation/beans/jelly // hehehe
	name = "Jelly Bean"
	name_prefix = "Jelly "
	iconmod = "BeanJelly"
	assoc_reagents = list("VHFCS")
	crop = /obj/item/reagent_containers/food/snacks/candy/jellybean/someflavor

// Coffee Mutations

/datum/plantmutation/coffee/mocha
	name = "Mocha Coffee"
	name_prefix = "Mocha "
	iconmod = "CoffeeMocha"
	crop = /obj/item/reagent_containers/food/snacks/plant/coffeeberry/mocha
	PTrange = list(20,null)
	assoc_reagents = list("chocolate")

/datum/plantmutation/coffee/latte
	name = "Latte Coffee"
	name_prefix = "Latte "
	iconmod = "CoffeeLatte"
	crop = /obj/item/reagent_containers/food/snacks/plant/coffeeberry/latte
	ENrange = list(10,null)
	assoc_reagents = list("milk")

// Chili Mutations

/datum/plantmutation/chili/chilly
	name = "Chilly"
	name_prefix = "Chilly "
	iconmod = "ChiliChilly" // IM SORRY THIS IS ALL IN THE NAME OF A VAGUELY CONSISTENT AND PREDICTABLE NAMING CONVENTION
	crop = /obj/item/reagent_containers/food/snacks/plant/chili/chilly
	assoc_reagents = list("cryostylane")
	infusion_reagents = list("cryostylane", "cryoxadone")
	infusion_chance = 80

/datum/plantmutation/chili/ghost
	name = "Fiery Chili"
	name_prefix = "Fiery "
	iconmod = "ChiliGhost"
	crop = /obj/item/reagent_containers/food/snacks/plant/chili/ghost_chili
	PTrange = list(75,null)
	infusion_chance = 80
	infusion_reagents = list("el_diablo", "phlogiston")
	brew_result = "ghostchilijuice"

// Pumpkin Mutations

/datum/plantmutation/pumpkin/latte
	name = "Spice Pumpkin"
	name_prefix = "Spiced "
	iconmod = "PumpkinLatte"
	crop = /obj/item/reagent_containers/food/snacks/plant/pumpkin/pumpkinlatte
	assoc_reagents = list("pumpkinspicelatte")
	infusion_chance = 80
	chance = 0
	infusion_reagents = list("capsaicin")

// Eggplant Mutations

/datum/plantmutation/eggplant/literal
	name = "Free-Range Eggplant"
	dont_rename_crop = TRUE
	name_prefix = "Free range "
	iconmod = "EggplantEggs"
	crop = /obj/item/reagent_containers/food/snacks/ingredient/egg
	assoc_reagents = list("egg")
	infusion_chance = 80
	infusion_reagents = list("eggnog")

// Wheat Mutations

/datum/plantmutation/wheat/durum
	name = "Durum Wheat"
	name_prefix = "Durum "
	crop = /obj/item/plant/wheat/durum

/datum/plantmutation/wheat/steelwheat
	name = "steel wheat"
	name_prefix = "Steel "
	iconmod = "WheatSteel"
	assoc_reagents = list("iron")
	crop = /obj/item/plant/wheat/metal
	infusion_reagents = list("iron")

// Rice Mutations

/datum/plantmutation/rice/ricein
	name = "ricein"
	name_prefix = "Ricin "
	iconmod = "Rice"
	PTrange = list(60,null)
	brew_result = "ricin"
	crop = /obj/item/reagent_containers/food/snacks/ingredient/rice_sprig
	chance = 0
	infusion_reagents = list("insulin")

// Oat Mutations

/datum/plantmutation/oat/salt
	name = "Salted Oats"
	name_prefix = "Salted "
	iconmod = "OatSalt"
	assoc_reagents = list("salt")
	crop = /obj/item/plant/oat/salt

// Synthmeat Mutations

/datum/plantmutation/synthmeat
	chance = 0 //they're all infusion based

/datum/plantmutation/synthmeat/butt
	name = "Synthbutt"
	iconmod = "SynthButts"
	dont_rename_crop = TRUE
	crop = /obj/item/clothing/head/butt/synth
	special_proc_override = TRUE
	mutation_sfx = 'sound/voice/farts/fart6.ogg'
	infusion_reagents = list("anti_fart")

	HYPspecial_proc_M(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plantgenes/DNA = POT.plantgenes

		var/fart_prob = clamp(100, 0, DNA?.get_effective_value("potency"))

		if (POT.get_current_growth_stage() >= HYP_GROWTH_MATURED && prob(fart_prob))
			POT.visible_message(SPAN_ALERT("<b>[POT]</b> farts!"))
			playsound(POT, 'sound/voice/farts/poo2.ogg', 50, TRUE, channel=VOLUME_CHANNEL_EMOTE)
			// coder.Life()
			// whoops undefined proc

/datum/plantmutation/synthmeat/limb
	name = "Synthlimb"
	dont_rename_crop = TRUE
	iconmod = "SynthLimbs" // im sorry Haine i made a new sprite
	infusion_reagents = list("synthflesh")
	crop = list(/obj/item/parts/human_parts/arm/left/synth, /obj/item/parts/human_parts/arm/right/synth,
	            /obj/item/parts/human_parts/leg/left/synth, /obj/item/parts/human_parts/leg/right/synth,
	            /obj/item/parts/human_parts/arm/left/synth/bloom, /obj/item/parts/human_parts/arm/right/synth/bloom,
	            /obj/item/parts/human_parts/leg/left/synth/bloom, /obj/item/parts/human_parts/leg/right/synth/bloom)

/datum/plantmutation/synthmeat/heart
	name = "Synthheart"
	dont_rename_crop = TRUE
	iconmod = "SynthHearts"
	crop = /obj/item/organ/heart/synth
	infusion_reagents = list("blood")

/datum/plantmutation/synthmeat/eye
	name = "Syntheye"
	dont_rename_crop = TRUE
	iconmod = "SynthEyes"
	crop = /obj/item/organ/eye/synth
	infusion_reagents = list("oculine")

/datum/plantmutation/synthmeat/brain
	name = "Synthbrain"
	dont_rename_crop = TRUE
	iconmod = "SynthBrains"
	crop = /obj/item/organ/brain/synth
	infusion_reagents = list("mannitol")

/datum/plantmutation/synthmeat/butt/buttbot
	name = "Synthbuttbot"
	dont_rename_crop = TRUE
	iconmod = "SynthButts"
	crop = /obj/machinery/bot/buttbot
	mutation_sfx = 'sound/voice/virtual_gassy.ogg'
	harvest_cap = 1
	required_mutation = /datum/plantmutation/synthmeat/butt
	infusion_reagents = list("nanites")

/datum/plantmutation/synthmeat/lung
	name = "Synthlung"
	dont_rename_crop = TRUE
	iconmod = "SynthLungs"
	crop = list(/obj/item/organ/lung/synth/left, /obj/item/organ/lung/synth/right)
	infusion_reagents = list("salbutamol")

/datum/plantmutation/synthmeat/appendix
	name = "Synthappendix"
	dont_rename_crop = TRUE
	iconmod = "SynthAppendixes"
	crop = /obj/item/organ/appendix/synth
	infusion_reagents = list("poo")

/datum/plantmutation/synthmeat/pancreas
	name = "Synthpancreas"
	dont_rename_crop = TRUE
	iconmod = "SynthPancreata"
	crop = /obj/item/organ/pancreas/synth
	infusion_reagents = list("sugar")

/datum/plantmutation/synthmeat/liver
	name = "Synthliver"
	dont_rename_crop = TRUE
	iconmod = "SynthLivers"
	crop = /obj/item/organ/liver/synth
	infusion_reagents = list("ethanol")
/datum/plantmutation/synthmeat/kidney
	name = "Synthkidney"
	dont_rename_crop = TRUE
	iconmod = "SynthKidneys"
	crop = list(/obj/item/organ/kidney/synth/left, /obj/item/organ/kidney/synth/right)
	infusion_reagents = list("water")
/datum/plantmutation/synthmeat/spleen
	name = "Synthspleen"
	dont_rename_crop = TRUE
	iconmod = "SynthSpleens"
	crop = /obj/item/organ/spleen/synth
	infusion_reagents = list("proconvertin")

/datum/plantmutation/synthmeat/stomach
	name = "Synthstomach"
	dont_rename_crop = TRUE
	iconmod = "SynthStomachs"
	crop = list(/obj/item/organ/stomach/synth, /obj/item/organ/intestines/synth)
	infusion_reagents = list("charcoal")

// Soy Mutations

/datum/plantmutation/soy/soylent
	name = "Strange soybean"
	name_prefix = "Strange "
	crop = /obj/item/reagent_containers/food/snacks/plant/soy/soylent
	iconmod = "Soylent"

// Contusine Mutations

/datum/plantmutation/contusine/shivering
	name = "Shivering Contusine"
	name_prefix = "Shivering "
	iconmod = "ContusineShivering"
	crop = /obj/item/plant/herb/contusine/shivering
	assoc_reagents = list("salbutamol")
	chance = 20

/datum/plantmutation/contusine/quivering
	name = "Quivering Contusine"
	name_prefix = "Quivering "
	iconmod = "ContusineQuivering"
	crop = /obj/item/plant/herb/contusine/quivering
	assoc_reagents = list("histamine")
	chance = 10
	mutation_sfx = 'sound/impact_sounds/Bush_Hit.ogg'

// Nureous Mutations

/datum/plantmutation/nureous/fuzzy
	name = "Fuzzy Nureous"
	name_prefix = "Fuzzy "
	crop = /obj/item/plant/herb/nureous/fuzzy
	iconmod = "NureousFuzzy"
	assoc_reagents = list("hairgrownium")

// Asomna Mutations

/datum/plantmutation/asomna/robust
	name = "Robust Asomna"
	name_prefix = "Robust "
	crop = /obj/item/plant/herb/asomna/robust
	iconmod = "AsomnaRobust"
	assoc_reagents = list("synaptizine")
	chance = 10

// Commol Mutations

/datum/plantmutation/commol/burning
	name = "Burning Commol"
	name_prefix = "Burning "
	iconmod = "CommolBurning"
	crop = /obj/item/plant/herb/commol/burning
	assoc_reagents = list("phlogiston")
	chance = 10

// Ipecacuanha Mutations

/datum/plantmutation/ipecacuanha/bilious
	name = "Bilious Ipecacuanha"
	name_prefix = "Bilious "
	iconmod = "IpecacuanhaBilious"
	crop = /obj/item/plant/herb/ipecacuanha/bilious
	assoc_reagents = list("vomit","sewage","bitters")
	chance = 10

/datum/plantmutation/ipecacuanha/invigorating
	name = "Invigorating Ipecacuanha"
	name_prefix = "Invigorating "
	iconmod = "IpecacuanhaInvigorating"
	crop = /obj/item/plant/herb/ipecacuanha/invigorating
	assoc_reagents = list("methamphetamine")
	chance = 10

// Nettle Mutations

/datum/plantmutation/stinging_nettle/smooth
	name = "Dead Nettle"
	name_prefix = "Smooth "
	iconmod = "NettleSmooth"
	crop = /obj/item/plant/herb/nettle/smooth
	chance = 20

// Venne Mutations

/datum/plantmutation/venne/toxic
	name = "Black Venne"
	name_prefix = "Black "
	iconmod = "VenneToxic"
	crop = /obj/item/plant/herb/venne/toxic
	assoc_reagents = list("atropine")
	chance = 10

/datum/plantmutation/venne/curative
	name = "Sunrise Venne"
	name_prefix = "Sunrise "
	iconmod = "VenneCurative"
	crop = /obj/item/plant/herb/venne/curative
	assoc_reagents = list("mannitol","mutadone")
	chance = 5

// Houttuynia Cordata Mutations

/datum/plantmutation/hcordata/fish
	name = "Wholetuna Cordata"
	iconmod = "Wholetuna"
	crop = list(/obj/item/reagent_containers/food/fish/salmon,
				/obj/item/reagent_containers/food/fish/carp,
				/obj/item/reagent_containers/food/fish/bass)
	assoc_reagents = list("fishoil")
	dont_rename_crop = TRUE
	special_proc_override = TRUE

	HYPon_mutation_general(var/datum/plant/parent_plant, var/datum/plantgenes/passed_genes)
		HYPaddCommut(passed_genes, /datum/plant_gene_strain/inert)
		return

	HYPspecial_proc_M(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		if (POT.get_current_growth_stage() >= HYP_GROWTH_HARVESTABLE && prob(10))
			var/list/nerds = list()
			// I know that this seems weird, but consider how many plants clutter botany at any given time. Looping through mobs and checking distance is
			// less of a pain than looping through potentially hundreds of random seeds and crap in view(1) to see if they're mobs.
			for (var/mob/living/L in mobs)
				if (BOUNDS_DIST(L.loc, get_turf(POT)) == 0)
					nerds += L
				else
					continue
			if (length(nerds) >= 1)
				POT.visible_message(SPAN_ALERT("<b>[POT.name]</b> slaps [pick(nerds)] with a fish!"))
				playsound(POT, pick('sound/impact_sounds/Slimy_Hit_1.ogg', 'sound/impact_sounds/Slimy_Hit_2.ogg'), 50, 1, -1)

// Cannabis Mutations

/datum/plantmutation/cannabis/rainbow
	name = "Rainbow Weed"
	name_prefix = "Rainbow "
	iconmod = "CannabisRainbow"
	crop = /obj/item/plant/herb/cannabis/mega
	assoc_reagents = list("LSD")

/datum/plantmutation/cannabis/death
	name = "Deathweed"
	name_prefix = "Black "
	iconmod = "CannabisDeath"
	crop = /obj/item/plant/herb/cannabis/black
	PTrange = list(null,30)
	ENrange = list(10,30)
	chance = 20
	assoc_reagents = list("cyanide")

/datum/plantmutation/cannabis/white
	name = "Lifeweed"
	name_prefix = "White "
	iconmod = "CannabisLife"
	crop = /obj/item/plant/herb/cannabis/white
	PTrange = list(30,null)
	ENrange = list(30,50)
	chance = 20
	assoc_reagents = list("omnizine")

/datum/plantmutation/cannabis/ultimate
	name = "Omega Weed"
	name_prefix = "Glowing "
	iconmod = "CannabisGlowing"
	crop = /obj/item/plant/herb/cannabis/omega
	PTrange = list(420,null)
	chance = 100
	assoc_reagents = list("LSD","suicider","space_drugs","mercury","lithium",
	"atropine", "ephedrine", "haloperidol","methamphetamine","THC","capsaicin","psilocybin","hairgrownium",
	"ectoplasm","bathsalts","itching","crank","krokodil","catdrugs","histamine")

// Fungus Mutations

/datum/plantmutation/fungus/psilocybin
	name = "Magic Mushroom"
	name_prefix = "Magic "
	iconmod = "FungusMagic"
	crop = /obj/item/reagent_containers/food/snacks/mushroom/psilocybin
	assoc_reagents = list("psilocybin")

/datum/plantmutation/fungus/amanita
	name = "Amanita"
	name_prefix = "Amanita "
	iconmod = "FungusAmanita"
	crop = /obj/item/reagent_containers/food/snacks/mushroom/amanita
	ENrange = list(null,10)
	PTrange = list(30,null)
	chance = 20
	assoc_reagents = list("amanitin")

/datum/plantmutation/fungus/cloak
	name = "Cloaked Panellus"
	iconmod = "FungusCloak"
	crop = /obj/item/reagent_containers/food/snacks/mushroom/cloak
	PTrange = list(null,10) //low potency
	CZrange = list(25,null) // high crop size
	chance = 10
	assoc_reagents = list("cloak_juice")


// Lasher Mutations

/datum/plantmutation/lasher/berries
	name = "Blooming Lasher"
	name_prefix = "Blooming "
	dont_rename_crop = TRUE
	iconmod = "LasherBerries"
	harvest_override = 1
	crop = /obj/item/reagent_containers/food/snacks/plant/lashberry
	chance = 20

// Creeper Mutations

/datum/plantmutation/creeper/tumbling
	name = "Tumbling Creeper"
	name_prefix = "Tumbling "
	iconmod = "CreeperTumbling"
	harvest_override = 1
	harvest_cap = 3
	crop = /obj/item/plant/tumbling_creeper
	chance = 20


// Radweed Mutations

/datum/plantmutation/radweed/safeweed
	name = "White Radweed"
	name_prefix = "White "
	iconmod = "RadweedWhite"
	special_proc_override = TRUE
	assoc_reagents = list("penteticacid")

	HYPspecial_proc_M(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		if (POT.get_current_growth_stage() >= HYP_GROWTH_HARVESTABLE && prob(10))
			var/obj/overlay/B = new /obj/overlay( get_turf(POT) )
			B.icon = 'icons/effects/hydroponics.dmi'
			B.icon_state = "radpulse"
			B.name = "radioactive pulse"
			B.anchored = ANCHORED
			B.set_density(0)
			B.layer = 5 // TODO what layer should this be on?
			SPAWN(2 SECONDS)
				qdel(B)
				B=null
			var/radrange = 1
			switch (POT.health)
				if (60 to 159)
					radrange = 2
				if (160 to INFINITY)
					radrange = 3
			for (var/obj/machinery/plantpot/C in range(radrange,POT))
				var/datum/plant/growing = C.current
				if (istype(growing,/datum/plant/weed/radweed)) continue
				if (growing) C.HYPmutateplant(radrange * 2)

/datum/plantmutation/radweed/redweed
	name = "Smoldering Radweed"
	name_prefix = "Smoldering "
	iconmod = "RadweedRed"
	assoc_reagents = list("infernite")
	mutation_sfx = 'sound/effects/redweedpop.ogg'

// Slurrypod Mutations

/datum/plantmutation/slurrypod/omega
	name = "Glowing Slurrypod"
	name_prefix = "Glowing "
	iconmod = "SlurrypodOmega"
	crop = /obj/item/reagent_containers/food/snacks/plant/slurryfruit/omega
	assoc_reagents = list("omega_mutagen")

// Rock Plant Mutations

/datum/plantmutation/rocks/syreline
	name_prefix = "Syreline "
	dont_rename_crop = TRUE
	crop = /obj/item/raw_material/syreline
	chance = 40

/datum/plantmutation/rocks/bohrum
	name_prefix = "Bohrum "
	dont_rename_crop = TRUE
	crop = /obj/item/raw_material/bohrum
	chance = 20

/datum/plantmutation/rocks/mauxite
	name_prefix = "Mauxite "
	dont_rename_crop = TRUE
	crop = /obj/item/raw_material/mauxite
	chance = 10

/datum/plantmutation/rocks/uqill
	name_prefix = "Uqill "
	dont_rename_crop = TRUE
	crop = /obj/item/raw_material/uqill
	chance = 5

// trees. :effort:

/datum/plantmutation/tree/money
	name = "Money Tree"
	dont_rename_crop = TRUE
	name_prefix = "Money "
	iconmod = "TreeCash"
	crop = /obj/item/currency/spacecash
	required_mutation = /datum/plantmutation/tree/paper
	PTrange = list(30, null)
	chance = 50

/datum/plantmutation/tree/paper
	name = "Paper Tree"
	dont_rename_crop = TRUE
	name_prefix = "Paper "
	iconmod = "TreePaper"
	crop = /obj/item/paper
	assoc_reagents = list("paper")
	infusion_reagents = list("paper")

/datum/plantmutation/tree/dog
	name = "Dogwood Tree"
	dont_rename_crop = TRUE
	iconmod = "TreeDogwood"
	special_proc_override = TRUE
	attacked_proc_override = 1
	mutation_sfx = 'sound/voice/animal/dogbark.ogg'
	infusion_reagents = list("wolfsbane")

	HYPspecial_proc_M(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		if (POT.get_current_growth_stage() >= HYP_GROWTH_MATURED && prob(5))
			POT.visible_message(SPAN_COMBAT("<b>[POT.name]</b> [pick("howls","bays","whines","barks","croons")]!"))
			playsound(POT, pick('sound/voice/animal/howl1.ogg','sound/voice/animal/howl2.ogg','sound/voice/animal/howl3.ogg','sound/voice/animal/howl4.ogg','sound/voice/animal/howl5.ogg','sound/voice/animal/howl6.ogg'), 30, 1,-1)

	HYPattacked_proc_M(var/obj/machinery/plantpot/POT,var/mob/user)
		..()
		if (.) return
		if (POT.get_current_growth_stage() >= HYP_GROWTH_MATURED) return 0
		playsound(POT, pick('sound/voice/animal/howl1.ogg','sound/voice/animal/howl2.ogg','sound/voice/animal/howl3.ogg','sound/voice/animal/howl4.ogg','sound/voice/animal/howl5.ogg','sound/voice/animal/howl6.ogg'), 30, 1,-1)
		boutput(user, SPAN_ALERT("[POT.name] angrily bites you!"))
		random_brute_damage(user, 3)
		return prob(50) // fights back, but doesn't always succeed

/datum/plantmutation/tree/rubber
	name = "Rubber Tree"
	dont_rename_crop = TRUE
	name_prefix = "Rubber "
	iconmod = "TreeRubber"
	crop = /obj/item/material_piece/rubber/latex
	assoc_reagents = list("rubber")
	infusion_reagents = list("spaceglue")

/datum/plantmutation/tree/sassafras
	name = "Sassafras Tree"
	dont_rename_crop = TRUE
	name_prefix = "Sassafras "
	iconmod = "TreeSassafras"
	assoc_reagents = list("safrole")
	crop = /obj/item/plant/herb/sassafras

/datum/plantmutation/tree/glowstick
	name = "Glowstick Tree"
	dont_rename_crop = TRUE
	name_prefix = "Glowstick "
	iconmod = "TreeGlow"
	crop = /obj/item/device/light/glowstick
	infusion_reagents = list("radium")
	chance = 0

	proc/add_glow(obj/object)
		object.add_simple_light("glowstick_tree", list(255, 0, 255, 100))
		animate_rainbow_glow(object.simple_light, 5 SECONDS, 10 SECONDS)
		var/image/glowverlay = object.SafeGetOverlayImage("glowverlay", 'icons/obj/hydroponics/plants_crop.dmi', "TreeGlow-glow")
		if (istype(object, /obj/decorative_pot)) //*dies of cringe*
			glowverlay.pixel_x = 2
		glowverlay.plane = PLANE_ABOVE_LIGHTING
		object.UpdateOverlays(glowverlay, "glowverlay", 0, 1)

	proc/remove_glow(obj/object)
		object.remove_simple_light("glowstick_tree")
		object.UpdateOverlays(null, "glowverlay")

	HYPmatured_proc_M(obj/machinery/plantpot/POT)
		. = ..()
		src.add_glow(POT)

	HYPpotted_proc_M(obj/decorative_pot/POT, grow_level)
		. = ..()
		if (grow_level >= 4)
			src.add_glow(POT)

	HYPharvested_proc_M(obj/machinery/plantpot/POT, mob/user)
		. = ..()
		src.remove_glow(POT)

	HYPdestroyplant_proc_M(obj/machinery/plantpot/POT, mob/user)
		. = ..()
		src.remove_glow(POT)

//peanuuts

/datum/plantmutation/peanut/sandwich
	name = "Peanutbutter Sandwich"
	name_suffix = "butter Sandwich"
	crop = /obj/item/reagent_containers/food/snacks/sandwich/pb
	iconmod = "PeanutSandwich"
	assoc_reagents = list("bread")
	infusion_reagents = list("bread")
	infusion_chance = 10
	chance = 0

//Tobacco mutations

/datum/plantmutation/tobacco/twobacco
	name = "Twobacco"
	iconmod = "Twobacco"
	PTrange = list(30,null)
	crop = /obj/item/plant/herb/tobacco/twobacco
	assoc_reagents = list("nicotine2")
	chance = 50

//Dripper mutations
/datum/plantmutation/dripper/leaker
	name = "Leaker"
	iconmod = "Leaker"
	crop = /obj/item/reagent_containers/food/snacks/plant/purplegoop/orangegoop
	assoc_reagents = list("oil")
	chance = 25

//Raspberry Mutations

/datum/plantmutation/raspberry/blackberry
	name = "Blackberry"
	iconmod = "Blackberry"
	dont_rename_crop = TRUE
	crop = /obj/item/reagent_containers/food/snacks/plant/raspberry/blackberry
	assoc_reagents = list("juice_blackberry")

/datum/plantmutation/raspberry/blueraspberry
	name = "Blue Raspberry"
	iconmod = "BlueRaspberry"
	dont_rename_crop = TRUE
	crop = /obj/item/reagent_containers/food/snacks/plant/raspberry/blueraspberry
	assoc_reagents = list("juice_blueraspberry")

// Flower mutations

/datum/plantmutation/rose/holorose
	name = "Holo Rose"
	iconmod = "HoloRose"
	dont_rename_crop = TRUE
	crop = /obj/item/clothing/head/flower/rose/holorose
	chance = 0
	infusion_reagents = list("luminol")

/datum/plantmutation/hydrangea
	var/flower_color

/datum/plantmutation/hydrangea/pink
	name = "Pink Hydrangea"
	name_prefix = "Pink "
	flower_color = "pink"
	crop = /obj/item/clothing/head/flower/hydrangea/pink
	PTrange = list(10,30)
	chance = 25

/datum/plantmutation/hydrangea/blue
	name = "Blue Hydrangea"
	name_prefix = "Blue "
	flower_color = "blue"
	crop = /obj/item/clothing/head/flower/hydrangea/blue
	PTrange = list(30,50)
	chance = 25

/datum/plantmutation/hydrangea/purple
	name = "Purple Hydrangea"
	name_prefix = "Purple "
	flower_color = "purple"
	crop = /obj/item/clothing/head/flower/hydrangea/purple
	PTrange = list(50,null)
	chance = 25
