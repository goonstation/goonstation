// GENERAL DEFINES, REPORTING FOR DUTY!

#define MICROBIO_NAMINGLIST list("Disease", "Strain", "Plague", "Syndrome", "Virions")

#define MICROBIO_LOWERDURATIONVALUE 120
#define MICROBIO_UPPERDURATIONVALUE 240

#define MICROBIO_INDIVIDUALMICROBELIMIT 3

// Probability Factors
#define MICROBIO_DEFAULTPROBABILITYDIVIDEND 5
#define MICROBIO_MAXIMUMPROBABILITY 5
#define MICROBIO_MICROBEWEIGHTEDPROBABILITYDIVIDEND 2

// EFFECT-RELATED DEFINES

// More Probability Factors, effectively the old rarity system
#define MICROBIO_EFFECT_PROBABILITY_FACTOR_OHGODHELP 0.01
#define MICROBIO_EFFECT_PROBABILITY_FACTOR_HORRIFYING 0.1
#define MICROBIO_EFFECT_PROBABILITY_FACTOR_RARE 0.2
#define MICROBIO_EFFECT_PROBABILITY_FACTOR_UNCOMMON 0.5

// Transmission Types
#define MICROBIO_TRANSMISSION_TYPE_PHYSICAL 1
#define MICROBIO_TRANSMISSION_TYPE_AEROBIC 2

// CURE-RELATED DEFINES

#define REAGENT_CURE_THRESHOLD 10

#define MICROBIO_CURE_PROBABILITY_FACTOR 100	//Fuck RNG! Let the people be cured!

//Reagent Catagories

#define MB_BRUTE_MEDS_CATAGORY list("styptic_powder", "synthflesh", "analgesic")
#define MB_BURN_MEDS_CATAGORY list("silver_sulfadiazine", "synthflesh", "menthol")
#define MB_TOX_MEDS_CATAGORY list("anti_rad", "penteticacid", "charcoal", "antihol")
#define MB_OXY_MEDS_CATAGORY list("iron", "salbutamol", "epinephrine", "atropine", "perfluorodecalin")

#define MB_SEDATIVES_CATAGORY list("haloperidol", "morphine", "neurotoxin", "ethanol", "lithium", "ether", "ketamine")
#define MB_STIMULANTS_CATAGORY list("smelling_salt", "epinephrine", "sugar", "ephedrine", "synaptizine", "methamphetamine")
//#define MB_FATS_CATAGORY list("badgrease", "grease", "porktonium", "cholesterol")

#define MB_HOT_REAGENTS list("phlogiston", "infernite")
#define MB_COLD_REAGENTS list("cryostylane", "cryoxadone")

#define MB_ACID_REAGENTS list("acid", "clacid", "pacid")
//yoinked from the artifact injector code
#define MB_TOXINS_REAGENTS list("chlorine","fluorine","lithium","mercury","plasma","radium","uranium","strange_reagent",\
"amanitin","coniine","cyanide","curare","formaldehyde","lipolicide","initropidril","cholesterol","itching","pancuronium","polonium",\
"sodium_thiopental","ketamine","sulfonal","toxin","venom","neurotoxin","mutagen","wolfsbane","toxic_slurry","histamine","sarin")

#define MB_BRAINDAMAGE_REAGENTS list("mercury","neurotoxin","haloperidol","sarin")

// MACHINE DEFINES

// Inspection Responses

#define MICROBIO_INSPECT_LIKES "The microbes are moving towards the area affected by the reagent!"

#define MICROBIO_INSPECT_DISLIKES "The microbes are attemping to escape from the area affected by the reagent!"

#define MICROBIO_INSPECT_DISLIKES_GENERIC "The microbes seem to shut down in the presence of the solution."

#define MICROBIO_INSPECT_HIT_CURE "The microbes in the test reagent are rapidly withering away!"

// Other constants
#define MICROBIO_SHAKESPEARE list("Expectation is the root of all heartache.",\
"A fool thinks himself to be wise, but a wise man knows himself to be a fool.",\
"Love all, trust a few, do wrong to none.",\
"Hell is empty and all the devils are here.",\
"Better a witty fool than a foolish wit.",\
"The course of true love never did run smooth.",\
"Come, gentlemen, I hope we shall drink down all unkindness.",\
"Suspicion always haunts the guilty mind.",\
"No legacy is so rich as honesty.",\
"Alas, I am a woman friendless, hopeless!",\
"The empty vessel makes the loudest sound.",\
"Words without thoughts never to heaven go.",\
"This above all; to thine own self be true.",\
"An overflow of good converts to bad.",\
"It is a wise father that knows his own child.",\
"Listen to many, speak to a few.",\
"Boldness be my friend.",\
"Speak low, if you speak love.",\
"Give thy thoughts no tongue.",\
"The devil can cite Scripture for his purpose.",\
"In time we hate that which we often fear.",\
"The lady doth protest too much, methinks.")
