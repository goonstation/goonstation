//for trait / genetics checks
#define isalcoholresistant(x) ((x.bioHolder && x.bioHolder.HasEffect("resist_alcohol")) || (x.traitHolder && x.traitHolder.hasTrait("training_drinker")))
#define ishandy(x) (x.traitHolder && (x.traitHolder.hasTrait("training_engineer") || x.traitHolder.hasTrait("carpenter")))
