ABSTRACT_TYPE(/datum/customization_style)
ABSTRACT_TYPE(/datum/customization_style/hair)
ABSTRACT_TYPE(/datum/customization_style/hair/short)
ABSTRACT_TYPE(/datum/customization_style/hair/long)
ABSTRACT_TYPE(/datum/customization_style/hair/hairup)
ABSTRACT_TYPE(/datum/customization_style/hair/gimmick)
ABSTRACT_TYPE(/datum/customization_style/moustache)
ABSTRACT_TYPE(/datum/customization_style/beard)
ABSTRACT_TYPE(/datum/customization_style/sideburns)
ABSTRACT_TYPE(/datum/customization_style/eyebrows)
ABSTRACT_TYPE(/datum/customization_style/makeup)
ABSTRACT_TYPE(/datum/customization_style/biological)




#define FEMININE 1
#define MASCULINE 2

TYPEINFO(/datum/customization_style)
	/// Does this hair have some special unlock condition? (medal, rank, etc.)
	var/special_criteria = FALSE
	/// Is this a gimmick hairstyle? (available to genetics/barbers, not to char setup)
	var/gimmick = FALSE

// typeinfo macro doesn't play nice with absolute pathed types so here we are
TYPEINFO(/datum/customization_style/hair/gimmick)
	gimmick = TRUE
/datum/customization_style
	var/name = null
	var/id = null
	var/gender = 0
	/// Which mob icon layer this should go on (under or over glasses)
	var/default_layer = MOB_HAIR_LAYER1 //Under by default, more direct subtypes where that makes sense
	/// Icon file this hair should be pulled from
	var/icon = 'icons/mob/human_hair.dmi'
	/// For blacklisting the weird partial hairstyles that just look broken on random characters
	var/random_allowed = TRUE
	/// Only used if typeinfo.special_criteria is TRUE
	proc/check_available(client/C)
		return TRUE

	none
		name = "None"
		id = "none"
		gender = MASCULINE
	hair
		default_layer = MOB_HAIR_LAYER2

		short
			afro
				name = "Afro"
				id = "afro"
				gender = MASCULINE | FEMININE
			afro_fade
				name = "Afro: Faded"
				id = "afro_fade"
				random_allowed = FALSE
			afroHR
				name = "Afro: Left Half"
				id = "afroHR"
				random_allowed = FALSE
			afroHL
				name = "Afro: Right Half"
				id = "afroHL"
				random_allowed = FALSE
			afroST
				name = "Afro: Top"
				id = "afroST"
				random_allowed = FALSE
			afroSM
				name = "Afro: Middle Band"
				id = "afroSM"
				random_allowed = FALSE
			afroSB
				name = "Afro: Bottom"
				id = "afroSB"
				random_allowed = FALSE
			afroSL
				name = "Afro: Left Side"
				id = "afroSL"
				random_allowed = FALSE
			afroSR
				name = "Afro: Right Side"
				id = "afroSR"
				random_allowed = FALSE
			afroSC
				name = "Afro: Center Streak"
				id = "afroSC"
				random_allowed = FALSE
			afroCNE
				name = "Afro: NE Corner"
				id = "afroCNE"
				random_allowed = FALSE
			afroCNW
				name = "Afro: NW Corner"
				id = "afroCNW"
				random_allowed = FALSE
			afroCSE
				name = "Afro: SE Corner"
				id = "afroCSE"
				random_allowed = FALSE
			afroCSW
				name = "Afro: SW Corner"
				id = "afroCSW"
				random_allowed = FALSE
			afroSV
				name = "Afro: Tall Stripes"
				id = "afroSV"
				random_allowed = FALSE
			afroSH
				name = "Afro: Long Stripes"
				id = "afroSH"
				random_allowed = FALSE
			balding
				name = "Balding"
				id = "balding"
				gender = MASCULINE
			bangs
				name = "Bangs"
				id = "bangs"
				gender = MASCULINE
			bieb
				name = "Bieber"
				id = "bieb"
				gender = MASCULINE | FEMININE
			bloom
				name = "Bloom"
				id = "bloom"
				gender = MASCULINE | FEMININE
			bobcut
				name = "Bobcut"
				id = "bobcut"
				gender = FEMININE
			baum_s
				name = "Bobcut Alt"
				id = "baum_s"
				gender = FEMININE
			bowl
				name = "Bowl Cut"
				id = "bowl"
				gender = MASCULINE
			cut
				name = "Buzzcut"
				id = "cut"
				gender = MASCULINE
			clown
				name = "Clown"
				id = "clown"
			clownT
				name = "Clown: Top"
				id = "clownT"
				random_allowed = FALSE
			clownM
				name = "Clown: Middle Band"
				id = "clownM"
				random_allowed = FALSE
			clownB
				name = "Clown: Bottom"
				id = "clownB"
				random_allowed = FALSE
			combed_s
				name = "Combed"
				id = "combed_s"
				gender = MASCULINE
			combedbob_s
				name = "Combed Bob"
				id = "combedbob_s"
				gender = FEMININE
			chop_short
				name = "Choppy Short"
				id = "chop_short"
				gender = MASCULINE | FEMININE
			einstein
				name = "Einstein"
				id = "einstein"
				gender = MASCULINE
			einalt
				name = "Einstein: Alternating"
				id = "einalt"
			emo
				name = "Emo"
				id = "emo"
				gender = MASCULINE | FEMININE
			emoH
				name = "Emo: Highlight"
				id = "emoH"
			flattop
				name = "Flat Top"
				id = "flattop"
				gender = MASCULINE
			flick
				name = "Flick"
				id = "flick"
				gender = MASCULINE | FEMININE
			flick_fade
				name = "Flick: Faded"
				id = "flick_fade"
			flick_half
				name = "Flick: Split"
				id = "flick_half"
				random_allowed = FALSE
			floof
				name = "Floof"
				id = "floof"
				gender = FEMININE
			ignite
				name = "Ignite"
				id = "ignite"
				gender = MASCULINE
			igniteshaved
				name = "Ignite: Shaved"
				id = "igniteshaved"
			streak
				name = "Hair Streak"
				id = "streak"
			mohawk
				name = "Mohawk"
				id= "mohawk"
				gender = MASCULINE | FEMININE
			mohawkFT
				name = "Mohawk: Fade from End"
				id = "mohawkFT"
			mohawkFB
				name = "Mohawk: Fade from Root"
				id = "mohawkFB"
			mohawkS
				name = "Mohawk: Stripes"
				id = "mohawkS"
			mysterious
				name = "Mysterious"
				id = "mysterious"
				gender = FEMININE
			long
				name = "Mullet"
				id = "long"
				gender = MASCULINE | FEMININE
			suave
				name = "Suave Mullet"
				id = "suave_mullet"
				gender = MASCULINE | FEMININE
			part
				name = "Parted Hair"
				id = "part"
				gender = MASCULINE | FEMININE
			pomp
				name = "Pompadour"
				id = "pomp"
				gender = MASCULINE | FEMININE
			pompS
				name = "Pompadour: Greaser Shine"
				id = "pompS"
				random_allowed = FALSE
			scruffy
				name = "Scruffy"
				id = "scruffy"
				gender = MASCULINE | FEMININE
			shavedhead
				name = "Shaved Head"
				id = "shavedhead"
			shortflip
				name = "Punky Flip"
				id = "shortflip"
				gender = MASCULINE | FEMININE
			sparks
				name = "Sparks"
				id = "sparks"
				gender = MASCULINE | FEMININE
			spiky
				name = "Spiky"
				id = "spiky"
				gender = MASCULINE
			subtlespiky
				name = "Subtle Spiky"
				id = "subtlespiky"
				gender = MASCULINE
			temsik
				name = "Temsik"
				id = "temsik"
				gender = MASCULINE
			tonsure
				name = "Tonsure"
				id = "tonsure"
				gender = MASCULINE
			short
				name = "Trimmed"
				id = "short"
				gender = MASCULINE
			tulip
				name = "Tulip"
				id = "tulip"
				gender = MASCULINE | FEMININE
			visual
				name = "Visual"
				id = "visual"
				gender = MASCULINE
			combedfront
				name = "Combed Front"
				id = "combedfront"
			combedfrontbangs
				name = "Bangs: Combed Front"
				id = "combedfrontbangs"
				random_allowed = FALSE
			combedfrontshort
				name = "Combed Front Short"
				id = "combedfrontshort"
			combedfrontshortbangs
				name = "Bangs: Combed Front Short"
				id = "combedfrontshortbangs"
				random_allowed = FALSE
			longfront
				name = "Long Front"
				id = "longfront"
			longfrontbangs
				name = "Bangs: Long Front"
				id = "longfrontbangs"
				random_allowed = FALSE
			salty
				name = "Salty"
				id = "salty"
			wolfcut
				name = "Wolfcut"
				id = "wolfcut"
			brushed
				name = "Brushed"
				id = "brushed"
			walnut
				name = "Walnut"
				id = "walnut"
			mop
				name = "Mop"
				id = "mop"
			acorn
				name = "Acorn"
				id = "acorn"
			curtain
				name = "Curtain"
				id = "curtain"
			scott
				name = "Scott"
				id = "scott"
			curly_bob
				name = "Curly Bob"
				id = "curly_bob"
			curly_bob_fade
				name = "Curly Bob: Faded"
				id = "curly_bob_fade"
				random_allowed = FALSE
			charming
				name = "Charming"
				id = "charming"
			spoon
				name = "Spoon"
				id = "spoon"
			spoonbangs
				name = "Bangs: Spoon"
				id = "spoonbangs"
				random_allowed = FALSE
			messy_waves
				name = "Messy Waves"
				id = "messy_waves"
			messy_waves_half
				name = "Messy Waves: Split"
				id = "messy_waves_half"
				random_allowed = FALSE
			blunt_bob
				name = "Blunt Bob"
				id = "blunt_bob"

			jelly
				name = "Jelly"
				id = "jelly"

			cockatiel
				name = "Cockatiel"
				id = "cockatiel"

			combed_fringe
				name = "Combed Fringe"
				id = "combed_fringe"

			slicked_back
				name = "Slicked Back"
				id = "slicked_back"

			asym_bob
				name = "Asymmetrical Bob"
				id = "asym_bob"

			side_curls
				name = "Side-Part Curls"
				id = "side_curls"

			messy_fringe
				name = "Messy Fringe"
				id = "messy_fringe"

			aristocrat
				name = "Aristocrat"
				id = "aristocrat"

			brushed_bob
				name = "Brushed Bob"
				id = "brushed_bob"

			short_shag
				name = "Short Shag"
				id = "short_shag"

			luxury_bob
				name = "Luxurious Bob"
				id = "luxury_bob"

			wavy_front
				name = "Wavy Front"
				id = "wavy_front"

			poofy_bob
				name = "Poofy Bob"
				id = "poofy_bob"

			short_dreads
				name = "Short Dreads"
				id = "short_dreads"

			Shaggy
				name = "Shaggy"
				id = "shaggy"
		long
			chub2_s
				name = "Bang: Left"
				id = "chub2_s"
				random_allowed = FALSE
			chub_s
				name = "Bang: Right"
				id = "chub_s"
				random_allowed = FALSE
			twobangs_long
				name = "Two Bangs: Long"
				id = "2bangs_long"
				random_allowed = FALSE
			twobangs_short
				name = "Two Bangs: Short"
				id = "2bangs_short"
				random_allowed = FALSE
			flatbangs
				name = "Bangs: Flat"
				id = "flatbangs"
				random_allowed = FALSE
			shortflatbangs
				name = "Bangs: Flat Shorter"
				id = "shortflatbangs"
				random_allowed = FALSE
			longwavebangs
				name = "Bangs: Long Wavy"
				id = "longwavebangs"
				random_allowed = FALSE
			shortwavebangs
				name = "Bangs: Short Wavy"
				id = "shortwavebangs"
				random_allowed = FALSE
			sidebangs
				name = "Bangs: Sides"
				id = "sidebangs"
				random_allowed = FALSE
			mysterybangs
				name = "Bangs: Mysterious"
				id = "mysterybangs"
				random_allowed = FALSE
			vbangs
				name = "V-Bangs"
				id = "v_bangs"
				random_allowed = FALSE
			bedhead
				name = "Bedhead"
				id = "bedhead"
				gender = MASCULINE | FEMININE
			breezy
				name = "Breezy"
				id = "breezy"
				gender = MASCULINE | FEMININE
			breezy_fade
				name = "Breezy: Faded"
				id = "breezy_fade"
			disheveled
				name = "Disheveled"
				id = "disheveled"
				gender = FEMININE
			doublepart
				name = "Double-Part"
				id = "doublepart"
			shoulders
				name = "Draped"
				id = "shoulders"
				gender = FEMININE
			dreads
				name = "Dreadlocks"
				id = "dreads"
				gender = MASCULINE
			dreadsA
				name = "Dreadlocks: Alternating"
				id = "dreadsA"
				random_allowed = FALSE
			fabio
				name = "Fabio"
				id = "fabio"
				gender = FEMININE
			glammetal
				name = "Glammetal"
				id = "glammetal"
				gender = FEMININE
			glammetalO
				name = "Glammetal: Faded"
				id = "glammetalO"
			eighties
				name = "Hairmetal"
				id = "80s"
				gender = FEMININE
			eightiesfade
				name = "Hairmetal: Faded"
				id = "80sfade"
			halfshavedR
				name = "Half-Shaved: Left"
				id = "halfshavedR"
				gender = MASCULINE | FEMININE
			halfshaved_s
				name = "Half-Shaved: Long"
				id = "halfshaved_s"
				gender = FEMININE
			halfshavedL
				name = "Half-Shaved: Right"
				id = "halfshavedL"
				gender = MASCULINE | FEMININE
			streakbangR
				name = "Bang: Streak Right"
				id = "streakbangR"
				random_allowed = FALSE
			streakbangL
				name = "Bang: Streak Left"
				id = "streakbangL"
				random_allowed = FALSE
			kingofrockandroll
				name = "Kingmetal"
				id = "king-of-rock-and-roll"
				gender = MASCULINE
			froofy_long
				name = "Long and Froofy"
				id = "froofy_long"
				gender = FEMININE
			lionsmane
				name = "Lionsmane"
				id = "lionsmane"
				gender = MASCULINE
			lionsmane_fade
				name = "Lionsmane: Faded"
				id = "lionsmane_fade"
			pinion
				name = "Pinion"
				id = "pinion"
				gender = MASCULINE
			longbraid
				name = "Long Braid"
				id = "longbraid"
				gender = FEMININE
			looselongbraid
				name = "Loose Long Braid"
				id = "looselongbraid"
				gender = FEMININE
			looselongbraidtwincolor
				name = "Loose Long Braid: Twin Color"
				id = "looselongbraidfaded"
				gender = FEMININE
			looselongbraidshoulder
				name = "Loose Long Braid Over Shoulder"
				id = "looselongbraidshoulder"
				gender = FEMININE
			longsidepart_s
				name = "Long Flip"
				id = "longsidepart_s"
				gender = FEMININE
			longwaves
				name = "Waves"
				id = "longwaves"
				gender = FEMININE
			longwaves_fade
				name = "Waves: Faded"
				id = "longwaves_fade"
			longwaves_half
				name = "Waves: Split"
				id = "longwaves_half"
				random_allowed = FALSE
			pulledb
				name = "Pulled Back"
				id = "pulledb"
				gender = FEMININE
			ripley
				name = "Ripley"
				id = "ripley"
				gender = FEMININE
			ripley_fade
				name = "Ripley: Faded"
				id = "ripley_fade"
			sage
				name = "Sage"
				id = "sage"
				gender = FEMININE
			scraggly
				name = "Scraggly"
				id = "scraggly"
				gender = MASCULINE
			pulledf
				name = "Shoulder Drape"
				id = "pulledf"
				gender = FEMININE
			shoulderl
				name = "Shoulder-Length"
				id = "shoulderl"
				gender = FEMININE
			slightlymess_s
				name = "Shoulder-Length Mess"
				id = "slightlymessy_s"
				gender = FEMININE
			smoothwave
				name = "Smooth Waves"
				id = "smoothwave"
				gender = FEMININE
			smoothwave_fade
				name = "Smooth Waves: Faded"
				id = "smoothwave_fade"
			smoothwave_half
				name = "Smooth Waves: Split"
				id = "smoothwave_half"
				random_allowed = FALSE
			mermaid
				name = "Mermaid"
				id = "mermaid"
				gender = FEMININE
			mermaidfade
				name = "Mermaid: Faded"
				id = "mermaidfade"
			midb
				name = "Mid-Back Length"
				id = "midb"
				gender = MASCULINE | FEMININE
			bluntbangs_s
				name = "Mid-Length Curl"
				id = "bluntbangs_s"
				gender = FEMININE
			vlong
				name = "Very Long"
				id = "vlong"
				gender = FEMININE
			violet
				name = "Violet"
				id = "violet"
				gender = FEMININE
			violet_fade
				name = "Violet: Faded"
				id = "violet_fade"
			violet_half
				name = "Violet: Split"
				id = "violet_half"
				random_allowed = FALSE
			willow
				name = "Willow"
				id = "willow"
				gender = MASCULINE | FEMININE
			willow_fade
				name = "Willow: Faded"
				id = "willow_fade"
		hairup
			bun
				name = "Bun"
				id = "bun"
				gender = FEMININE
			bundercut
				name = "Bun Undercut"
				id = "bundercut"
				gender = MASCULINE
			sakura
				name = "Captor"
				id = "sakura"
				gender = FEMININE
			croft
				name = "Croft"
				id = "croft"
				gender = FEMININE
			indian
				name = "Double Braids"
				id = "indian"
				gender = FEMININE
			doublebun
				name = "Double Buns"
				id = "doublebun"
				gender = FEMININE
			drill
				name = "Drill"
				id = "drill"
			fun_bun
				name = "Fun Bun"
				id = "fun_bun"
				gender = FEMININE
			charioteers
				name = "High Flat Top"
				id = "charioteers"
				gender = MASCULINE
			spud
				name = "High Ponytail"
				id = "spud"
				gender = FEMININE
			longtailed
				name = "Long Mini Tail"
				id = "longtailed"
				gender = FEMININE
			longtwintail
				name = "Long Twin Tails"
				id = "longtwintail"
				gender = FEMININE
			longtwintail_half
				name = "Long Twin Tails: Split"
				id = "longtwintail_half"
				random_allowed = FALSE
			glamponytail
				name = "Glam Ponytail"
				id = "glamponytail"
			glamponytail_half
				name = "Glam Ponytail: Split"
				id = "glamponytail_half"
				random_allowed = FALSE
			rockponytail
				name = "Rock Ponytail"
				id = "rockponytail"
				gender = FEMININE
			rockponytail_fade
				name = "Rock Ponytail: Faded"
				id = "rockponytail_fade"
			rockponytail_half
				name = "Rock Ponytail: Split"
				id = "rockponytail_half"
				random_allowed = FALSE
			spikyponytail
				name = "Spiky Ponytail"
				id = "spikyponytail"
				gender = MASCULINE | FEMININE
			messyponytail
				name = "Messy Ponytail"
				id = "messyponytail"
				gender = MASCULINE | FEMININE
			untidyponytail
				name = "Untidy Ponytail"
				id = "untidyponytail"
				gender = MASCULINE | FEMININE
			lowpig
				name = "Low Pigtails"
				id = "lowpig"
				gender = FEMININE
			band
				name = "Low Ponytail"
				id = "band"
				gender = FEMININE
			minipig
				name = "Mini Pigtails"
				id = "minipig"
				gender = MASCULINE | FEMININE
			pig
				name = "Pigtails"
				id = "pig"
				gender = FEMININE
			pig_half
				name = "Pigtails: Split"
				id = "pig_half"
				random_allowed = FALSE
			pompompigtail
				name = "Pompom Pigtails"
				id = "pompompigtail"
				gender = FEMININE
			ponytail
				name = "Ponytail"
				id = "ponytail"
				gender = MASCULINE | FEMININE
			geisha_s
				name = "Shimada"
				id = "geisha_s"
				gender = FEMININE
			twotail
				name = "Split-Tails"
				id = "twotail"
				gender = MASCULINE
			wavy_tail
				name = "Wavy Ponytail"
				id = "wavy_tail"
				gender = FEMININE
			wavy_tail_half
				name = "Wavy Ponytail: Split"
				id = "wavy_tail_half"
				random_allowed = FALSE

		gimmick
			afroHA
				name = "Afro: Alternating Halves"
				id = "afroHA"
			afroRB
				name = "Afro: Rainbow"
				id = "afroRB"
			bart
				name = "Bart"
				id = "bart"
			ewave_s
				name = "Elegant Wave"
				id = "ewave_s"
			flames
				name = "Flame Hair"
				id = "flames"
			goku
				name = "Goku"
				id = "goku"
			super
				name = "Super"
				id = "super"
			homer
				name = "Homer"
				id = "homer"
			jetson
				name = "Jetson"
				id = "jetson"
			sailor_moon
				name = "Sailor Moon"
				id = "sailor_moon"
			sakura
				name = "Sakura"
				id = "sakura"
			wiz
				name = "Wizard"
				id = "wiz"
			xcom
				name = "X-COM Rookie"
				id = "xcom"
			zapped
				name = "Zapped"
				id = "zapped"
			shitty_hair
				name = "Shitty Hair"
				id = "shitty_hair"
			shitty_beard
				name = "Shitty Beard"
				id = "shitty_beard"
			shitty_beard_stains
				name = "Shitty Beard Stains"
				id = "shitty_beard_stains"
	moustache
		fu
			name = "Biker"
			id = "fu"
		chaplin
			name = "Chaplin"
			id = "chaplin"
		dali
			name = "Dali"
			id = "dali"
		handlebar
			name = "Handlebar"
			id = "handlebar"
		devil
			name = "Old Nick"
			id = "devil"
		robo
			name = "Robotnik"
			id = "robo"
		selleck
			name = "Selleck"
			id = "selleck"
		villain
			name = "Twirly"
			id = "villain"
		vandyke
			name = "Van Dyke"
			id = "vandyke"
		watson
			name = "Watson"
			id = "watson"
	beard
		abe
			name = "Abe"
			id = "abe"
		bstreak
			name = "Beard Streaks"
			id = "bstreak"
		braided
			name = "Braided Beard"
			id = "braided"
		chin
			name = "Chinstrap"
			id = "chin"
		dwarfbeard
			name = "Dwarven Beard"
			id = "dwarfbeard"
		dwarfbraided
			name = "Dwarven Braided Beard"
			id = "dwarfbraided"
		fullbeard
			name = "Full Beard"
			id = "fullbeard"
		fiveoclock
			name = "Five O'Clock Shadow"
			id = "fiveoclock"
		gt
			name = "Goatee"
			id = "gt"
		hip
			name = "Hipster"
			id = "hip"
		longbeard
			name = "Long Beard"
			id = "longbeard"
		longbeardfade
			name = "Long Beard: Faded"
			id = "longbeardfade"
		motley
			name = "Motley"
			id = "motley"
		neckbeard
			name = "Neckbeard"
			id = "neckbeard"
		puffbeard
			name = "Puffy Beard"
			id = "puffbeard"
		tramp
			name = "Tramp"
			id = "tramp"
		trampstains
			name = "Tramp: Beard Stains"
			id = "trampstains"
	sideburns
		elvis
			name = "Elvis"
			id = "elvis"
	eyebrows
		eyebrows
			name = "Eyebrows"
			id = "eyebrows"
		thufir
			name = "Huge Eyebrows"
			id  = "thufir"
	makeup
		eyeshadow
			name = "Eyeshadow"
			id = "eyeshadow"
		lipstick
			name = "Lipstick"
			id = "lipstick"
	biological
		hetcroL
			name = "Heterochromia: Left"
			id = "hetcroL"
		hetcroR
			name = "Heterochromia: Right"
			id = "hetcroR"

proc/select_custom_style(mob/living/carbon/human/user, no_gimmick_hair = FALSE)
	var/list/datum/customization_style/options = list()
	for (var/datum/customization_style/styletype as anything in get_available_custom_style_types(user.client, no_gimmick_hair))
		options[initial(styletype.name)] = styletype
	var/new_style = tgui_input_list(user, "Please select style", "Style", options)
	var/selected_type = options[new_style]
	if (selected_type)
		return new selected_type

proc/find_style_by_name(var/target_name, client/C, no_gimmick_hair = FALSE)
	for (var/datum/customization_style/styletype as anything in get_available_custom_style_types(C, no_gimmick_hair))
		if(cmptext(initial(styletype.name), target_name))
			return new styletype
	stack_trace("Couldn't find a customization_style with the name \"[target_name]\".")
	return new /datum/customization_style/none

proc/find_style_by_id(var/target_id, client/C, no_gimmick_hair = FALSE)
	for (var/datum/customization_style/styletype as anything in get_available_custom_style_types(C, no_gimmick_hair))
		if(initial(styletype.id) == target_id)
			return new styletype
	stack_trace("Couldn't find a customization_style with the id \"[target_id]\".")
	return new /datum/customization_style/none

/// Gets all the customization_styles which are available to a given client. Can be filtered by providing a gender flag or a type
proc/get_available_custom_style_types(client/C, no_gimmick_hair = FALSE, filter_gender=0, filter_type=null, for_random=FALSE)
	// Defining static vars with no value doesn't overwrite them with null if we call the proc multiple times
	// Styles with no restriction
	var/static/list/always_available
	// Styles which aren't available in char setup but are available everywhere else
	var/static/list/gimmick_styles
	// Styles which have special unlock requirements
	var/static/list/locked_styles

	// only one check since the 3 lists are built at the same time
	if (!always_available)
		always_available = list()
		gimmick_styles = list()
		locked_styles = list()
		for (var/datum/customization_style/styletype as anything in concrete_typesof(/datum/customization_style))
			var/typeinfo/datum/customization_style/typeinfo = get_type_typeinfo(styletype)
			if (!typeinfo.special_criteria)
				if (!typeinfo.gimmick)
					always_available += styletype
				else
					gimmick_styles += styletype
			else
				locked_styles += styletype

	var/list/available = always_available.Copy()
	if (!no_gimmick_hair)
		available += gimmick_styles

	if (C)
		for (var/style in locked_styles)
			var/datum/customization_style/instance = new style()
			if (instance.check_available(C))
				available += style

	for (var/datum/customization_style/style as anything in available)
		if (filter_gender && !(initial(style.gender) & filter_gender))
			available -= style
			continue
		if (filter_type && !ispath(style, filter_type))
			available -= style
			continue
		if (for_random && !(initial(style.random_allowed)))
			available -= style
			continue

	return available
