//for trait / genetics checks
#define isalcoholresistant(x) (x?.bioHolder?.HasEffect("resist_alcohol") || x?.traitHolder?.hasTrait("training_drinker"))
#define checkonomatopoeic(x) ((x?.bioHolder?.HasEffect("onomatopoeic") || x?.traitHolder?.hasTrait("onomatopoeic")) && !ON_COOLDOWN(x, "onomatopoeic", 2 SECONDS))
