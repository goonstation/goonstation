// Spread flags. Determines what slots are taken into account during a permeability scan.
#define SPREAD_FACE 1
#define SPREAD_BODY 2
#define SPREAD_HANDS 4
#define SPREAD_AIR 8

#define COOLDOWN_MULTIPLIER 1

#define INFECT_NONE 0
#define INFECT_TOUCH 1
#define INFECT_AREA 3

#define REAGENT_CURE_THRESHOLD 10

// Reagent Catagories

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
// Inspection Responses

#define MICROBIO_INSPECT_LIKES "The microbes are moving towards the area affected by the reagent!"

#define MICROBIO_INSPECT_DISLIKES "The microbes are attemping to escape from the area affected by the reagent!"

#define MICROBIO_INSPECT_DISLIKES_GENERIC "The microbes seem to shut down in the presence of the solution."

#define MICROBIO_INSPECT_HIT_CURE "The microbes in the test reagent are rapidly withering away!"

// Other constants

#define MICROBIO_INDIVIDUALMICROBELIMIT 3
#define MICROBIO_DEFAULTPROBABILITYDIVIDEND 5
#define MICROBIO_MAXIMUMPROBABILITY 5
#define MICROBIO_NAMINGLIST list("Disease", "Strain", "Plague", "Syndrome", "Virions")


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
