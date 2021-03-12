/**
 * Microbody notes
 *
 * A pathogen microbody identifies the cause of the disease.
 * Most of the real life causes for diseases have been added already.
 * Each microbody defines a specific characteristic for a pathogen:
 * - How powerful is a disease caused by the microbody (stages).
 * - What is a fertile soil to cultivate this pathogen? (growth medium)
 *
 *
 * We differentiate between two types of cures:
 * - Serum. Every microbody has a serum; there is nothing that is currently incurable. Of course not adding a cure for a specific
 *   microbody will make all pathogens of that microbody incurable.
 * - Vaccine. Currently, only virii have vaccines; injecting someone with a vaccine for a pathogen will make them immune to said
 *   pathogen and all its mutations. A traitor would use this for his very deadly airbourne pathogen to avoid getting infected
 *   by it.
 */

// A microscopic body, acting as a pathogen.
datum/microbody
	var/name = "Microscopic body"
	var/singular = "microscopic body"
	var/plural = "microscopic bodies"

	// The strength of the microbody. Used for randomization.
	var/strength = 2

	// An inverse of rarity. A value of 10 means a ten times relative chance to a value of 1.
	var/commonness = 10

	// The amount of stages a pathogen with this microbody has.
	// Technically, this means there are less aggressive and more aggressive infections depending on the microbody.
	// Keep this value between 3 and 5.
	var/stages = 3

	// Activity determines the probability of symptoms manifesting in each stage for a particular microbody.
	var/activity = list(20, 20, 20, 20, 20)

	// The growth medium is the reagent whose presence will make pathogens of this microbody grow in petri dishes.
	// DO NOT set this to "blood" or "pathogen", only to a derivative.
	var/growth_medium = "water"

	// The base reagent for cures to this specific microbody type. Will be used by the synth-o-matic. Keep this null for an incurable microbody.
	var/cure_base = "serum"

	// Can you make a vaccine for this microbody? (Instant immunity)
	var/vaccination = 0

	// The unique ID for this microbody. Used in public DNA.
	var/uniqueid = 0

	// If specified, a special module is needed for the Synth-O-Matic to synthesize a cure for this microbody.
	var/module_id = null

	// A list of reagent IDs, each of which is required for the growth of a pathogen.
	var/list/nutrients = list("water", "sugar", "sodium", "iron", "nitrogen")

	// If 1, curing also immunizes to re-infection.
	var/auto_immunize = 0

	// The amount of nutrition of each type required per unit of pathogen to continue cultivation.
	var/amount = 0.07

	/// The amount of sequences worth of symptoms the microbody can support. -1 is unlimited
	var/seqMax = -1

	/// The maximum amount of points that can be spread over the various stats
	var/maxStats = 100

	disposing()
		SHOULD_CALL_PARENT(FALSE) //Looks like these should never be deleted.
		CRASH("ALERT MICROBODY IS BEING DELETED")


datum/microbody/virus
	name = "Virus"
	singular = "virus"
	plural = "viruses"

	stages = 5

	activity = list(1, 5, 20, 30, 40)

	seqMax = 12

	// Grows in eggs.
	growth_medium = "egg"

	cure_base = "antiviral"
	vaccination = 1
	auto_immunize = 1

	uniqueid = 1
	module_id = "virii"

datum/microbody/bacteria
	name = "Bacteria"
	singular = "bacterium"
	plural = "bacteria"

	activity = list(30, 30, 30, 30, 30)

	stages = 3

	seqMax = 25

	growth_medium = "bacterialmedium"

	cure_base = "spaceacillin"
	vaccination = 1
	auto_immunize = 1

	uniqueid = 2
	module_id = "bacteria"

datum/microbody/fungi
	name = "Fungi"
	singular = "fungus"
	plural = "fungi"

	stages = 1

	activity = list(10, 10, 10, 10, 10)

	growth_medium = "fungalmedium"

	cure_base = "biocide"
	vaccination = 1

	uniqueid = 3
	module_id = "fungi"
	auto_immunize = 1

datum/microbody/parasite
	name = "Parasites"
	singular = "parasite"
	plural = "parasites"

	stages = 5

	activity = list(50, 40, 30, 20, 10)

	seqMax = 18

	growth_medium = "parasiticmedium"

	cure_base = "biocide"

	uniqueid = 4
	module_id = "parasite"
	auto_immunize = 1

datum/microbody/gmcell // TODO: I kind of removed mutations so I should really rename this, I guess
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
