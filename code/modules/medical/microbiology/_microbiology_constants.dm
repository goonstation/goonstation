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
#define MB_FATS_CATAGORY list("badgrease", "grease", "porktonium", "cholesterol")

#define MB_HOT_REAGENTS list("phlogiston", "infernite")
#define MB_COLD_REAGENTS list("cryostylane", "cryoxadone")

// Inspection Responses

#define MICROBIO_INSPECT_LIKES "The pathogens are moving towards the area affected by the " // + "[R]."

#define MICROBIO_INSPECT_DISLIKES "The pathogens are attemping to escape from the area affected by the " // + "[R]."

#define MICROBIO_INSPECT_DISLIKES_GENERIC "One of the glands of the pathogen seems to shut down in the presence of the solution."
