/* ---------------------- RANDOMIZER PROC STUFF */

/proc/random_blood_type(var/weighted = 1)
	var/return_type
	// set a default one so that, if none of the weighted ones happen, they at least have SOME kind of blood type
	return_type = pick("O", "A", "B", "AB") + pick("+", "-")
	if (weighted)
		var/list/types_and_probs = list(\
		"O" = 40,\
		"A" = 30,\
		"B" = 15,\
		"AB" = 5)
		for (var/i in types_and_probs)
			if (prob(types_and_probs[i]))
				return_type = i
				if (prob(80))
					return_type += "+"
				else
					return_type += "-"

	if (prob(1))
		return_type = "Zesty Ranch"

	return return_type

/proc/random_saturated_hex_color()
	return pick(rgb(255, rand(0, 255), rand(0, 255)), rgb(rand(0, 255), 255, rand(0, 255)), rgb(rand(0, 255), rand(0, 255), 255))

/proc/randomize_hair_color(var/hcolor)
	if (!hcolor)
		return
	var/list/rgb_list = rgb2num(hcolor)
	return rgb(
		rgb_list[1] + rand(-25, 25),
		rgb_list[2] + rand(-5, 5),
		rgb_list[3] + rand(-10, 10)
	)

/proc/randomize_eye_color(var/ecolor)
	if (!ecolor)
		return
	var/list/rgb_list = rgb2num(ecolor)
	return rgb(
		rgb_list[1] + rand(-10, 10),
		rgb_list[2] + rand(-10, 10),
		rgb_list[3] + rand(-10, 10)
	)

proc/isfem(datum/customization_style/style)
	return !!(initial(style.gender) & FEMININE)

proc/ismasc(datum/customization_style/style)
	return !!(initial(style.gender) & MASCULINE)

// this is weird but basically: a list of hairstyles and their appropriate detail styles, aka hair_details["80s"] would return the Hairmetal: Faded style
// further on in the randomize_look() proc we'll see if we've got one of the styles in here and if so, we have a chance to add the detailing
// if it's a list then we'll pick from the options in the list
var/global/list/hair_details = list("einstein" = /datum/customization_style/hair/short/einalt,\
	"80s" = /datum/customization_style/hair/long/eightiesfade,\
	"glammetal" = /datum/customization_style/hair/long/glammetalO,\
	"lionsmane" = /datum/customization_style/hair/long/lionsmane_fade,\
	"longwaves" = list(/datum/customization_style/hair/long/longwaves_fade, /datum/customization_style/hair/long/longwaves_half),\
	"ripley" = /datum/customization_style/hair/long/ripley_fade,\
	"violet" = list(/datum/customization_style/hair/long/violet_fade, /datum/customization_style/hair/long/violet_half),\
	"willow" = /datum/customization_style/hair/long/willow_fade,\
	"rockponytail" = list(/datum/customization_style/hair/hairup/rockponytail_fade, /datum/customization_style/hair/hairup/rockponytail_half),\
	"pompompigtail" = list(/datum/customization_style/hair/long/flatbangs, /datum/customization_style/hair/long/twobangs_long),\
	"breezy" = /datum/customization_style/hair/long/breezy_fade,\
	"flick" = list(/datum/customization_style/hair/short/flick_fade, /datum/customization_style/hair/short/flick_half),\
	"mermaid" = /datum/customization_style/hair/long/mermaidfade,\
	"smoothwave" = list(/datum/customization_style/hair/long/smoothwave_fade, /datum/customization_style/hair/long/smoothwave_half),\
	"longbeard" = /datum/customization_style/beard/longbeardfade,\
	"pomp" = /datum/customization_style/hair/short/pompS,\
	"mohawk" = list(/datum/customization_style/hair/short/mohawkFT, /datum/customization_style/hair/short/mohawkFB, /datum/customization_style/hair/short/mohawkS),\
	"emo" = /datum/customization_style/hair/short/emoH,\
	"clown" = list(/datum/customization_style/hair/short/clownT, /datum/customization_style/hair/short/clownM, /datum/customization_style/hair/short/clownB),\
	"dreads" = /datum/customization_style/hair/long/dreadsA,\
	"afro" = list(/datum/customization_style/hair/short/afroHR, /datum/customization_style/hair/short/afroHL, /datum/customization_style/hair/short/afroST, /datum/customization_style/hair/short/afroSM, \
	/datum/customization_style/hair/short/afroSB, /datum/customization_style/hair/short/afroSL, /datum/customization_style/hair/short/afroSR, /datum/customization_style/hair/short/afroSC, \
	/datum/customization_style/hair/short/afroCNE, /datum/customization_style/hair/short/afroCNW, /datum/customization_style/hair/short/afroCSE, /datum/customization_style/hair/short/afroCSW, \
	/datum/customization_style/hair/short/afroSV, /datum/customization_style/hair/short/afroSH),\
	"combedfront" = /datum/customization_style/hair/short/combedfrontbangs,\
	"combedfrontshort" = /datum/customization_style/hair/short/combedfrontshortbangs,\
	"longfront" = /datum/customization_style/hair/short/longfrontbangs,\
	"spoon" = /datum/customization_style/hair/short/spoonbangs,\
	"messy_waves" = /datum/customization_style/hair/short/messy_waves_half,\
	"longtwintail" = /datum/customization_style/hair/hairup/longtwintail_half,\
	"glamponytail" = /datum/customization_style/hair/hairup/glamponytail_half,\
	"pig" = /datum/customization_style/hair/hairup/pig_half,\
	"wavy_tail" = /datum/customization_style/hair/hairup/wavy_tail_half\
	)

// all these icon state names are ridiculous
var/global/list/feminine_ustyles = list("No Underwear" = "none",\
	"Bra and Panties" = "brapan",\
	"Tanktop and Panties" = "tankpan",\
	"Bra and Boyshorts" = "braboy",\
	"Tanktop and Boyshorts" = "tankboy",\
	"Panties" = "panties",\
	"Boyshorts" = "boyshort")
var/global/list/masculine_ustyles = list("No Underwear" = "none",\
	"Briefs" = "briefs",\
	"Boxers" = "boxers",\
	"Boyshorts" = "boyshort")

var/global/list/male_screams = list("male", "malescream4", "malescream5", "malescream6", "malescream7")
var/global/list/female_screams = list("female", "femalescream1", "femalescream2", "femalescream3", "femalescream4")

/proc/randomize_look(to_randomize, change_gender = 1, change_blood = 1, change_age = 1, change_name = 1, change_underwear = 1, remove_effects = 1, optional_donor)
	if (!to_randomize)
		return

	var/mob/living/carbon/human/H
	var/datum/appearanceHolder/AH

	if (ishuman(to_randomize))
		H = to_randomize
		if (H.bioHolder && H.bioHolder.mobAppearance)
			AH = H.bioHolder.mobAppearance
		else if (H.bioHolder)
			H.bioHolder.mobAppearance = new /datum/appearanceHolder()
			H.bioHolder.mobAppearance.owner = H
			H.bioHolder.mobAppearance.parentHolder = H.bioHolder
			AH = H.bioHolder.mobAppearance
		else
			H.bioHolder = new /datum/bioHolder()
			H.initializeBioholder()

			H.bioHolder.mobAppearance = new /datum/appearanceHolder()
			H.bioHolder.mobAppearance.owner = H
			H.bioHolder.mobAppearance.parentHolder = H.bioHolder
			AH = H.bioHolder.mobAppearance

	else if (istype(to_randomize, /datum/appearanceHolder))
		AH = to_randomize
		if (ishuman(AH.owner))
			H = AH.owner
		else
			H = optional_donor
	else
		return

	if (H?.bioHolder && remove_effects)
		H.bioHolder.RemoveAllEffects()
		H.bioHolder.BuildEffectPool()

	if (change_gender)
		AH.gender = pick(MALE, FEMALE)
	if (H && AH.gender)
		H.sound_scream = AH.screamsounds[pick(AH.gender == MALE ? male_screams : female_screams)]
	if (H && change_name)
		if (AH.gender == FEMALE)
			H.real_name = pick_string_autokey("names/first_female.txt")
		else
			H.real_name = pick_string_autokey("names/first_male.txt")
		H.real_name += " [pick_string_autokey("names/last.txt")]"
		H.on_realname_change()

	AH.voicetype = RANDOM_HUMAN_VOICE
	var/datum/customizationHolder/customization_first = AH.customizations["hair_bottom"]
	var/datum/customizationHolder/customization_second = AH.customizations["hair_middle"]
	var/datum/customizationHolder/customization_third = AH.customizations["hair_top"]

	var/list/hair_colors = list("#101010", "#924D28", "#61301B", "#E0721D", "#D7A83D",\
	"#D8C078", "#E3CC88", "#F2DA91", "#664F3C", "#8C684A", "#EE2A22", "#B89778", "#3B3024", "#A56b46")
	var/hair_color1
	var/hair_color2
	var/hair_color3
	if (prob(75))
		hair_color1 = randomize_hair_color(pick(hair_colors))
		hair_color2 = prob(50) ? hair_color1 : randomize_hair_color(pick(hair_colors))
		hair_color3 = prob(50) ? hair_color1 : randomize_hair_color(pick(hair_colors))
	else
		hair_color1 = randomize_hair_color(random_saturated_hex_color())
		hair_color2 = prob(50) ? hair_color1 : randomize_hair_color(random_saturated_hex_color())
		hair_color3 = prob(50) ? hair_color1 : randomize_hair_color(random_saturated_hex_color())

	customization_first.color = hair_color1
	customization_second.color = hair_color2
	customization_third.color = hair_color3

	var/stone = rand(34,-184)
	if (stone < -30)
		stone = rand(34,-184)
	if (stone < -50)
		stone = rand(34,-184)

	AH.s_tone = blend_skintone(stone, stone, stone)
	AH.s_tone_original = AH.s_tone

	if (H?.limbs)
		H.limbs.reset_stone()

	var/list/eye_colors = list("#101010", "#613F1D", "#808000", "#3333CC")
	AH.e_color = randomize_eye_color(pick(eye_colors))

	var/has_second = 0
	var/type_first
	if (AH.gender == MALE)
		if (prob(5)) // small chance to have a hairstyle more geared to the other gender
			type_first = pick(get_available_custom_style_types(H?.client, no_gimmick_hair=TRUE, filter_gender=FEMININE, for_random=TRUE))
			customization_first.style = new type_first
		else // otherwise just use one standard to the current gender
			type_first = pick(get_available_custom_style_types(H?.client, no_gimmick_hair=TRUE, filter_gender=MASCULINE, for_random=TRUE))
			customization_first.style = new type_first

		if (prob(33)) // since we're a guy, a chance for facial hair
			var/type_second = pick(get_available_custom_style_types(H?.client, no_gimmick_hair=TRUE, filter_type=/datum/customization_style/beard) \
								+ get_available_custom_style_types(H?.client, no_gimmick_hair=TRUE, filter_type=/datum/customization_style/moustache))
			customization_second = new type_second
			has_second = TRUE // so the detail check doesn't do anything - we already got a secondary thing!!

	else // if FEMALE
		if (prob(8)) // same as above for guys, just reversed and with a slightly higher chance since it's ~more appropriate~ for ladies to have guy haircuts than vice versa  :I
			type_first = pick(get_available_custom_style_types(H?.client, no_gimmick_hair=TRUE, filter_gender=MASCULINE, for_random=TRUE))
			customization_first.style = new type_first
		else // ss13 is coded with gender stereotypes IN ITS VERY CORE
			type_first = pick(get_available_custom_style_types(H?.client, no_gimmick_hair=TRUE, filter_gender=FEMININE, for_random=TRUE))
			customization_first.style = new type_first

	if (!has_second)
		var/hair_detail = hair_details[customization_first.style.name] // check for detail styles for our chosen style

		if (hair_detail && prob(50)) // found something in the list
			customization_second = new hair_detail // default to being whatever we found

			if (islist(hair_detail)) // if we found a bunch of things in the list
				var/type_second = pick(hair_detail) // let's choose just one (we don't need to assign a list as someone's hair detail)
				customization_second = new type_second
				if (prob(20)) // with a small chance for another detail thing
					var/type_third = pick(hair_detail)
					customization_third = new type_third
					customization_third.color = random_saturated_hex_color()
					if (prob(5))
						customization_third.color = randomize_hair_color(pick(hair_colors))
				else
					customization_third = new /datum/customization_style/none

			customization_second.color = random_saturated_hex_color() // if you have a detail style you're likely to want a crazy color
			if (prob(15))
				customization_second.color = randomize_hair_color(pick(hair_colors)) // but have a chance to be a normal hair color

		else if (prob(5)) // chance for a special eye color
			var/type_second = pick(/datum/customization_style/biological/hetcroL, /datum/customization_style/biological/hetcroR)
			customization_second.style = new type_second
			if (prob(75))
				customization_second.color = random_saturated_hex_color()
			else
				customization_second.color = randomize_eye_color(pick(eye_colors))
			customization_third.style = new /datum/customization_style/none

		else // otherwise, nada
			customization_second.style = new /datum/customization_style/none
			customization_third.style = new /datum/customization_style/none

	if (change_underwear)
		if (AH.gender == MALE)
			if (prob(1))
				AH.underwear = pick(feminine_ustyles)
			else
				AH.underwear = pick(masculine_ustyles)
		else
			if (prob(5))
				AH.underwear = pick(masculine_ustyles)
			else
				AH.underwear = pick(feminine_ustyles)
		AH.u_color = random_saturated_hex_color()

	if (H && change_blood)
		H.bioHolder.bloodType = random_blood_type(1)

	if (H && change_age)
		H.bioHolder.age = rand(20,80)

	if (H?.organHolder?.head?.donor_appearance) // aaaa
		H.organHolder.head.donor_appearance.CopyOther(AH)
	AH.flavor_text = null //random characters don't have flavor text and disguised ones shouldn't show theirs
	SPAWN(1 DECI SECOND)
		H?.update_colorful_parts()
