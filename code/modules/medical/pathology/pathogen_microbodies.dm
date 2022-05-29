
/**
 * Microbody notes
 *
 * A pathogen microbody sets intrinsic modifiers for the pathogen.
 *
 *
 *
 */

// A microscopic body, acting as a pathogen.
datum/microbody
	var/name = "Microscopic body"
	var/singular = "microscopic body"
	var/plural = "microscopic bodies"

	// The strength of the microbody. Used for randomization.
	var/strength = 2

	// The amount of stages a pathogen with this microbody has.
	// Technically, this means there are less aggressive and more aggressive infections depending on the microbody.
	// Keep this value between 3 and 5.
	var/stages = 3

	// Activity determines the probability of symptoms manifesting in each stage for a particular microbody.
	var/activity = list(20, 20, 20, 20, 20)

	///// GROWTH VARS /////

	// The growth medium is the reagent whose presence will make pathogens of this microbody grow in petri dishes.
	// DO NOT set this to "blood" or "pathogen", only to a derivative.
	var/growth_medium = "water"

	// A list of reagent IDs, each of which is required for the growth of a pathogen.
	var/list/nutrients = list("water", "sugar", "sodium", "iron", "nitrogen")

	// The amount of nutrition of each type required per unit of pathogen to continue cultivation.
	var/amount = 0.07

	// If 1, curing also immunizes to re-infection. Should always be 1.
	var/auto_immunize = 0

	///// MODIFIERS /////

	// Final multiplier for the total natural duration of infection. If -1, the disease is chronic.
	var/modifier_duration = 1

	// Final multiplier for the total value of a generated pathogen.
	var/modifier_bountyvalue = 1

	// Final multiplier for the cost to create an artificial pathogen.
	var/modifier_creationcost = 1

	// Final multiplier for the spread probability calculations.
	var/modifier_spreadprob = 1

	// Final multiplier for the stage advancement rate calculations.
	var/modifier_advancerate = 1

	// Final multiplier for the cure requirement of a pathogen.
	var/modifier_curerequirement = 1

	// Numeric modifier to the maximum number of infections a pathogen may make.
	var/modifier_maxinfections = 0


	//// TRACKING/LOGGING VARS ////

	//uniqueid is used in the pathogen controller for indexing.
	var/uniqueid = 0

	disposing()
		SHOULD_CALL_PARENT(FALSE) //Looks like these should never be deleted.
		CRASH("ALERT MICROBODY IS BEING DELETED")


datum/microbody/virus
	name = "Virus"
	singular = "virus"
	plural = "viruses"

	stages = 3

	activity = list(50, 40, 30, 20, 10)

	// Grows in eggs.
	growth_medium = "egg"

	auto_immunize = 1

	modifier_duration = 0.8 //-20% duration of max stage symptoms before natural immunity
	modifier_spreadprob = 1.2 //+20% to the final roll for infecting other people.

	uniqueid = 1

datum/microbody/bacteria
	name = "Bacteria"
	singular = "bacterium"
	plural = "bacteria"

	activity = list(30, 30, 30, 30, 30)

	stages = 4

	growth_medium = "egg"

	auto_immunize = 1

	modifier_creationcost = 0.75 //-25% creation cost!
	modifier_bountyvalue = 0.75  //-25% bounty value!

	uniqueid = 2

datum/microbody/fungi
	name = "Fungi"
	singular = "fungus"
	plural = "fungi"

	stages = 5

	activity = list(10, 10, 10, 10, 10)

	growth_medium = "egg"

	auto_immunize = 1

	modifier_advancerate = 0.7 // -30% on final chance to advance stages
	modifier_creationcost = 0.85 // -15% final creation cost

	uniqueid = 3

datum/microbody/parasite
	name = "Parasites"
	singular = "parasite"
	plural = "parasites"

	stages = 4

	activity = list(1, 5, 20, 30, 40)

	growth_medium = "egg"

	auto_immunize = 1

	modifier_curerequirement = 2 //Doubles the cure requirement!
	modifier_maxinfections = -2 //-2 total infections
	modifier_bountyvalue = 1.1
	modifier_creationcost = 1.1

	uniqueid = 4

/*datum/microbody/gmcell // TODO: I kind of removed mutations so I should really rename this, I guess
	name = "Great Mutatis cell"
	singular = "great mutatis cell"
	plural = "great mutatis cells"

	strength = 10
	commonness = 2

	activity = list(20, 20, 20, 20, 20)

	stages = 5

	// Grows in stable mutagen.
	// INTEGRATION NOTES: stable mutagen reagent ID.
	growth_medium = "dna_mutagen"

	cure_base = "inhibitor"

	uniqueid = 5
	module_id = "gmcell"

	nutrients = list("dna_mutagen")
	auto_immunize = 1
	amount = 0.35
	*/

