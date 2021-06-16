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

/datum/customization_style
	var/name = null
	var/id = null
	var/gender = 0
	/// Which mob icon layer this should go on (under or over glasses)
	var/default_layer = MOB_HAIR_LAYER1 //Under by default, more direct subtypes where that makes sense

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
			afroHR
				name = "Afro: Left Half"
				id = "afroHR"
			afroHL
				name = "Afro: Right Half"
				id = "afroHL"
			afroST
				name = "Afro: Top"
				id = "afroST"
			afroSM
				name = "Afro: Middle Band"
				id = "afroSM"
			afroSB
				name = "Afro: Bottom"
				id = "afroSB"
			afroSL
				name = "Afro: Left Side"
				id = "afroSL"
			afroSR
				name = "Afro: Right Side"
				id = "afroSR"
			afroSC
				name = "Afro: Center Streak"
				id = "afroSC"
			afroCNE
				name = "Afro: NE Corner"
				id = "afroCNE"
			afroCNW
				name = "Afro: NW Corner"
				id = "afroCNW"
			afroCSE
				name = "Afro: SE Corner"
				id = "afroCSE"
			afroCSW
				name = "Afro: SW Corner"
				id = "afroCSW"
			afroSV
				name = "Afro: Tall Stripes"
				id = "afroSV"
			afroSH
				name = "Afro: Long Stripes"
				id = "afroSH"
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
			clownM
				name = "Clown: Middle Band"
				id = "clownM"
			clownB
				name = "Clown: Bottom"
				id = "clownB"
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
			floof
				name = "Floof"
				id = "floof"
				gender = FEMININE
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
			long
				name = "Mullet"
				id = "long"
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
			shortflip
				name = "Punky Flip"
				id = "shortflip"
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
		long
			chub2_s
				name = "Bang: Left"
				id = "chub2_s"
			chub_s
				name = "Bang: Right"
				id = "chub_s"
			twobangs_long
				name = "Two Bangs: Long"
				id = "2bangs_long"
			twobangs_short
				name = "Two Bangs: Short"
				id = "2bangs_short"
			bedhead
				name = "Bedhead"
				id = "bedhead"
				gender = MASCULINE | FEMININE
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
			kingofrockandroll
				name = "Kingmetal"
				id = "king-of-rock-and-roll"
				gender = MASCULINE
			froofy_long
				name = "Long and Froofy"
				id = "froofy_long"
				gender = FEMININE
			longbraid
				name = "Long Braid"
				id = "longbraid"
				gender = FEMININE
			longsidepart_s
				name = "Long Flip"
				id = "longsidepart_s"
				gender = FEMININE
			pulledb
				name = "Pulled Back"
				id = "pulledb"
				gender = FEMININE
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
		hairup
			bun
				name = "Bun"
				id = "bun"
				gender = FEMININE
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
		hogan
			name = "Hogan"
			id = "hogan"
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
		fullbeard
			name = "Full Beard"
			id = "fullbeard"
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

proc/select_custom_style(list/datum/customization_style/customization_types, mob/living/carbon/human/user as mob)
	var/list/datum/customization_style/options = list()
	for (var/datum/customization_style/styletype as anything in customization_types)
		var/datum/customization_style/CS = new styletype
		options[CS.name] = CS
	var/new_style = input(user, "Please select style", "Style")  as null|anything in options
	return options[new_style]

proc/find_style_by_name(var/target_name)
	for (var/datum/customization_style/styletype as anything in concrete_typesof(/datum/customization_style))
		var/datum/customization_style/CS = new styletype
		if(CS.name == target_name)
			return CS
	return new /datum/customization_style/none

proc/find_style_by_id(var/target_id)
	for (var/datum/customization_style/styletype as anything in concrete_typesof(/datum/customization_style))
		var/datum/customization_style/CS = new styletype
		if(CS.id == target_id)
			return CS
	return new /datum/customization_style/none
