
// Macros with abilityHolder or mutantrace defines are used for more than antagonist checks, so don't replace them with mind.special_role.
#define istraitor(x) (istype(x, /mob/living/carbon/human) && x:mind && x:mind:special_role == "traitor")
#define ischangeling(x) (istype(x, /mob/living/carbon/human) && x:get_ability_holder(/datum/abilityHolder/changeling) != null)
#define isabomination(x) (istype(x, /mob/living/carbon/human) && x:mutantrace && istype(x:mutantrace, /datum/mutantrace/abomination))
#define isnukeop(x) (istype(x, /mob/living/carbon/human) && x:mind && x:mind:special_role == "nukeop")
#define isvampire(x) ((istype(x, /mob/living/carbon/human) || istype(x, /mob/living/critter)) && x:get_ability_holder(/datum/abilityHolder/vampire) != null)
#define isvampiriczombie(x) (istype(x, /mob/living/carbon/human) && x:get_ability_holder(/datum/abilityHolder/vampiric_zombie) != null)
#define iswizard(x) ((istype(x, /mob/living/carbon/human) || istype(x, /mob/living/critter)) && x:get_ability_holder(/datum/abilityHolder/wizard) != null)
#define ishunter(x) (istype(x, /mob/living/carbon/human) && x:mutantrace && istype(x:mutantrace, /datum/mutantrace/hunter))
#define iswerewolf(x) (istype(x, /mob/living/carbon/human) && x:mutantrace && istype(x:mutantrace, /datum/mutantrace/werewolf))
#define iswrestler(x) ((istype(x, /mob/living/carbon/human) || istype(x, /mob/living/critter)) && x:get_ability_holder(/datum/abilityHolder/wrestler) != null)
#define iswraith(x) istype(x, /mob/wraith)
#define isblob(x) istype(x, /mob/living/intangible/blob_overmind)
#define isspythief(x) (istype(x, /mob/living/carbon/human) && x:mind && x:mind:special_role == "spy_thief")

// Why the separate mask check? NPCs don't use assigned_role and we still wanna play the cluwne-specific sound effects.
#define iscluwne(x) ((x?.job == "Cluwne") || istype(x.wear_mask, /obj/item/clothing/mask/cursedclown_hat))
#define ishorse(x) (istype(x, /mob/living/carbon/human) && ((x.mind?.assigned_role == "Horse") || istype(x.wear_mask, /obj/item/clothing/mask/horse_mask/cursed)))
#define isdiabolical(x) (istype(x, /mob/living/carbon/human) && x:mind && x:mind:diabolical == 1)
#define iswelder(x) istype(x, /mob/living/carbon/human/welder)
#define ismartian(x) (istype(x, /mob/living/critter/martian) || (istype(x, /mob/living/carbon/human) && x:mutantrace && istype(x:mutantrace, /datum/mutantrace/martian)))
#define isprematureclone(x) (istype(x, /mob/living/carbon/human) && x:mutantrace && istype(x:mutantrace, /datum/mutantrace/premature_clone))
#define iskudzuman(x) (istype(x, /mob/living/carbon/human) && x:mutantrace && istype(x:mutantrace, /datum/mutantrace/kudzu))
