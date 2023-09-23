//for trait / genetics checks
#define isalcoholresistant(x) ((x.bioHolder && x.bioHolder.HasEffect("resist_alcohol")) || (x.traitHolder && x.traitHolder.hasTrait("training_drinker")))
#define isdwarf(x) ((x.bioHolder && x.bioHolder.HasEffect("dwarf")) || (x.traitHolder && x.traitHolder.hasTrait("dwarf")))
