ABSTRACT_TYPE(/datum/geneticsrecipe)
/datum/geneticsrecipe
	var/list/required_effects = list()
	var/result = null

// Beneficial

/datum/geneticsrecipe/breathless
	required_effects = list("adrenaline","ithillid")
	result = /datum/bioEffect/breathless

/datum/geneticsrecipe/hulk // Discovered
	required_effects = list("strong","radioactive")
	result = /datum/bioEffect/hulk

/datum/geneticsrecipe/xray // Discovered
	required_effects = list("eyebeams","blind")
	result = /datum/bioEffect/xray

/datum/geneticsrecipe/regenerator // Discovered
	required_effects = list("adrenaline","healing_touch")
	result = /datum/bioEffect/regenerator

/datum/geneticsrecipe/toxic_farts
	required_effects = list("farty","stinky")
	result = /datum/bioEffect/toxic_farts

/datum/geneticsrecipe/thermal_res
	required_effects = list("fire_resist","cold_resist")
	result = /datum/bioEffect/thermalres

/datum/geneticsrecipe/fire_resist // Discovered
	required_effects = list("immolate","glowy")
	result = /datum/bioEffect/fireres

/datum/geneticsrecipe/cold_resist // Discovered
	required_effects = list("cryokinesis","glowy")
	result = /datum/bioEffect/coldres

/datum/geneticsrecipe/rad_resist // Discovered
	required_effects = list("radioactive","glowy")
	result = /datum/bioEffect/rad_resist

/datum/geneticsrecipe/alch_resist
	required_effects = list("drunk","detox")
	result = /datum/bioEffect/alcres

/datum/geneticsrecipe/radio_brain
	required_effects = list("psy_resist","loud_voice")
	result = /datum/bioEffect/radio_brain

/datum/geneticsrecipe/blood_overdrive
	required_effects = list("anemia","polycythemia")
	result = /datum/bioEffect/blood_overdrive

// Detrimental

/datum/geneticsrecipe/unintelligable // Discovered
	required_effects = list("loud_voice","quiet_voice")
	result = /datum/bioEffect/speech/unintelligable

/datum/geneticsrecipe/unintelligable_two
	required_effects = list("accent_swedish","accent_elvis")
	result = /datum/bioEffect/speech/unintelligable

/datum/geneticsrecipe/vowels
	required_effects = list("accent_swedish","accent_chav")
	result = /datum/bioEffect/speech/vowelitis

/datum/geneticsrecipe/coprolalia
	required_effects = list("accent_chav","accent_tommy")
	result = /datum/bioEffect/coprolalia

/datum/geneticsrecipe/blind
	required_effects = list("bad_eyesight","narcolepsy")
	result = /datum/bioEffect/blind

/datum/geneticsrecipe/mute // Discovered
	required_effects = list("quiet_voice","screamer")
	result = /datum/bioEffect/mute

/datum/geneticsrecipe/drunk // Discovered
	required_effects = list("detox","stinky")
	result = /datum/bioEffect/drunk

/datum/geneticsrecipe/radioactive
	required_effects = list("aura","stinky")
	result = /datum/bioEffect/radioactive

/datum/geneticsrecipe/mutagenic_field
	required_effects = list("radioactive","involuntary_teleporting")
	result = /datum/bioEffect/mutagenic_field

/datum/geneticsrecipe/buzz
	required_effects = list("bee","stinky")
	result = /datum/bioEffect/buzz

// Useless

/datum/geneticsrecipe/glowy_one
	required_effects = list("shiny","albinism")
	result = /datum/bioEffect/glowy

/datum/geneticsrecipe/glowy_two
	required_effects = list("shiny","melanism")
	result = /datum/bioEffect/glowy

/datum/geneticsrecipe/glowy_three
	required_effects = list("aura","shiny")
	result = /datum/bioEffect/glowy

/datum/geneticsrecipe/shiny
	required_effects = list("glowy","aura")
	result = /datum/bioEffect/particles

/datum/geneticsrecipe/aura
	required_effects = list("glowy","shiny")
	result = /datum/bioEffect/aura

/datum/geneticsrecipe/fire_aura_one
	required_effects = list("aura","immolate")
	result = /datum/bioEffect/fire_aura

/datum/geneticsrecipe/fire_aura_two
	required_effects = list("aura","fire_breath")
	result = /datum/bioEffect/fire_aura

/datum/geneticsrecipe/strong
	required_effects = list("fitness_debuff","detox")
	result = /datum/bioEffect/strong

/datum/geneticsrecipe/stinky
	required_effects = list("farty","dead_scan")
	result = /datum/bioEffect/stinky

/datum/geneticsrecipe/bee
	required_effects = list("roach","detox")
	result = /datum/bioEffect/bee

/datum/geneticsrecipe/dwarf
	required_effects = list("strong","resist_alcohol")
	result = /datum/bioEffect/dwarf

/datum/geneticsrecipe/dwarf_two
	required_effects = list("strong","drunk")
	result = /datum/bioEffect/dwarf

/datum/geneticsrecipe/dwarf_three
	required_effects = list("strong","stinky")
	result = /datum/bioEffect/dwarf

// Powers

/datum/geneticsrecipe/telekinesis // Discovered
	required_effects = list("telepathy","radio_brain")
	result = /datum/bioEffect/power/telekinesis_drag

/datum/geneticsrecipe/eyebeams // Discovered
	required_effects = list("bad_eyesight","glowy")
	result = /datum/bioEffect/power/eyebeams

/datum/geneticsrecipe/superfart // Discovered
	required_effects = list("loud_voice","farty")
	result = /datum/bioEffect/power/superfart

/datum/geneticsrecipe/cryokinesis
	required_effects = list("chime_snaps","fire_resist")
	result = /datum/bioEffect/power/cryokinesis

/datum/geneticsrecipe/adrenaline
	required_effects = list("detox","strong")
	result = /datum/bioEffect/power/adrenaline

/datum/geneticsrecipe/jumpy
	required_effects = list("strong","monkey")
	result = /datum/bioEffect/power/jumpy

/datum/geneticsrecipe/telepath
	required_effects = list("psy_resist","quiet_voice")
	result = /datum/bioEffect/power/telepathy

/datum/geneticsrecipe/midas
	required_effects = list("chime_snaps","drunk")
	result = /datum/bioEffect/power/midas

/datum/geneticsrecipe/midas_two // Discovered
	required_effects = list("chime_snaps","shiny")
	result = /datum/bioEffect/power/midas

/datum/geneticsrecipe/healing_touch // Discovered
	required_effects = list("midas","detox")
	result = /datum/bioEffect/power/healing_touch

/datum/geneticsrecipe/healing_touch_two
	required_effects = list("midas","melt")
	result = /datum/bioEffect/power/healing_touch

/datum/geneticsrecipe/dimension_shift // Discovered
	required_effects = list("radio_brain","involuntary_teleporting")
	result = /datum/bioEffect/power/dimension_shift

/datum/geneticsrecipe/fire_breath
	required_effects = list("cough","immolate")
	result = /datum/bioEffect/power/fire_breath

/datum/geneticsrecipe/bigpuke
	required_effects = list("cough","drunk")
	result = /datum/bioEffect/power/bigpuke

/datum/geneticsrecipe/bigpuke_two
	required_effects = list("cough","stinky")
	result = /datum/bioEffect/power/bigpuke

/datum/geneticsrecipe/bigpuke_three
	required_effects = list("sneeze","drunk")
	result = /datum/bioEffect/power/bigpuke

/datum/geneticsrecipe/bigpuke_four
	required_effects = list("sneeze","stinky")
	result = /datum/bioEffect/power/bigpuke

/datum/geneticsrecipe/ink_one
	required_effects = list("ithillid","melanism")
	result = /datum/bioEffect/power/ink

/datum/geneticsrecipe/ink_two
	required_effects = list("ithillid","shiny")
	result = /datum/bioEffect/power/ink

/datum/geneticsrecipe/ink_three
	required_effects = list("ithillid","sneeze")
	result = /datum/bioEffect/power/ink

/datum/geneticsrecipe/photokinesis // Discovered
	required_effects = list("glowy","psy_resist")
	result = /datum/bioEffect/power/photokinesis

/datum/geneticsrecipe/photokinesis_two
	required_effects = list("shiny","psy_resist")
	result = /datum/bioEffect/power/photokinesis

/datum/geneticsrecipe/photokinesis_three
	required_effects = list("aura","psy_resist")
	result = /datum/bioEffect/power/photokinesis

/datum/geneticsrecipe/erebokinesis_one
	required_effects = list("cloak_of_darkness","psy_resist")
	result = /datum/bioEffect/power/erebokinesis

/datum/geneticsrecipe/erebokinesis_two
	required_effects = list("chameleon","psy_resist")
	result = /datum/bioEffect/power/erebokinesis

/datum/geneticsrecipe/erebokinesis_three
	required_effects = list("uncontrollable_cloak","psy_resist")
	result = /datum/bioEffect/power/erebokinesis

/datum/geneticsrecipe/brown_note
	required_effects = list("farty","loud_voice")
	result = /datum/bioEffect/power/brown_note

/datum/geneticsrecipe/brown_note_two
	required_effects = list("stinky","loud_voice")
	result = /datum/bioEffect/power/brown_note

/datum/geneticsrecipe/cloak_of_darkness // Discovered
	required_effects = list("uncontrollable_cloak","melanism")
	result = /datum/bioEffect/power/darkcloak

/datum/geneticsrecipe/chameleon // Discovered
	required_effects = list("uncontrollable_cloak","albinism")
	result = /datum/bioEffect/power/chameleon

/datum/geneticsrecipe/chameleon_two
	required_effects = list("uncontrollable_cloak","examine_stopper")
	result = /datum/bioEffect/power/chameleon

/datum/geneticsrecipe/shoot_limb
	required_effects = list("farty","bigpuke")
	result = /datum/bioEffect/power/shoot_limb

// Mutantraces

/datum/geneticsrecipe/seenoevil
	required_effects = list("blind","deaf","mute")
	result = /datum/bioEffect/mutantrace/monkey
	// since the station starts with monkey already researched we dont really need multiple recipes
	// this one's just for comedy's sake =v

/datum/geneticsrecipe/squid // Discovered
	required_effects = list("chime_snaps","stinky")
	result = /datum/bioEffect/mutantrace/ithillid

/datum/geneticsrecipe/squid_two
	required_effects = list("strong","melt")
	result = /datum/bioEffect/mutantrace/ithillid

/datum/geneticsrecipe/roach // Discovered
	required_effects = list("stinky","bee")
	result = /datum/bioEffect/mutantrace/roach

/datum/geneticsrecipe/roach_two
	required_effects = list("radioactive","bee")
	result = /datum/bioEffect/mutantrace/roach

/datum/geneticsrecipe/flashy
	required_effects = list("glowy","radioactive")
	result = /datum/bioEffect/mutantrace/flashy

/datum/geneticsrecipe/flashy_two
	required_effects = list("glowy","chameleon")
	result = /datum/bioEffect/mutantrace/flashy

/datum/geneticsrecipe/lizard
	required_effects = list("horns","chameleon")
	result = /datum/bioEffect/mutantrace

/datum/geneticsrecipe/lizard_two
	required_effects = list("horns","fire_resist")
	result = /datum/bioEffect/mutantrace

/datum/geneticsrecipe/blank // Discovered
	required_effects = list("albinism","melanism")
	result = /datum/bioEffect/color_changer/blank

/datum/geneticsrecipe/skeleton // Discovered
	required_effects = list("screamer","dead_scan")
	result = /datum/bioEffect/mutantrace/skeleton

/datum/geneticsrecipe/skeleton_two
	required_effects = list("cloak_of_darkness","dead_scan")
	result = /datum/bioEffect/mutantrace/skeleton

/datum/geneticsrecipe/skeleton_three
	required_effects = list("xray","dead_scan")
	result = /datum/bioEffect/mutantrace/skeleton

/datum/geneticsrecipe/reversed_sounds
	required_effects = list("slow_sounds","fast_sounds")
	result = /datum/bioEffect/reversedSounds

/datum/geneticsrecipe/radioactive_farts
	required_effects = list("radioactive","farty")
	result = /datum/bioEffect/radioactive_farts
