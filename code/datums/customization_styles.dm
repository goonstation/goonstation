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

/datum/customization_style
	var/name = null
	var/id = null
	var/fem = 0
	var/masc = 0

	none
		name = "None"
		id = "none"
		masc = 1
	hair
		short
			afro
				name = "Afro"
				id = "afro"
				fem = 1
				masc = 1
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
				masc = 1
			bangs
				name = "Bangs"
				id = "bangs"
				masc = 1
			bieb
				name = "Bieber"
				id = "bieb"
				fem = 1
				masc = 1
			bloom
				name = "Bloom"
				id = "bloom"
				fem = 1
				masc = 1
			bobcut
				name = "Bobcut"
				id = "bobcut"
				fem = 1
			baum_s
				name = "Bobcut Alt"
				id = "baum_s"
				fem = 1
			bowl
				name = "Bowl Cut"
				id = "bowl"
				masc = 1
			cut
				name = "Buzzcut"
				id = "cut"
				masc = 1
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
				masc = 1
			combedbob_s
				name = "Combed Bob"
				id = "combedbob_s"
				fem = 1
			chop_short
				name = "Choppy Short"
				id = "chop_short"
				fem = 1
				masc = 1
			einstein
				name = "Einstein"
				id = "einstein"
				masc = 1
			einalt
				name = "Einstein: Alternating"
				id = "einalt"
			emo
				name = "Emo"
				id = "emo"
				fem = 1
				masc = 1
			emoH
				name = "Emo: Highlight"
				id = "emoH"
			flattop
				name = "Flat Top"
				id = "flattop"
				masc = 1
			floof
				name = "Floof"
				id = "floof"
				fem = 1
			streak
				name = "Hair Streak"
				id = "streak"
			mohawk
				name = "Mohawk"
				id= "mohawk"
				fem = 1
				masc = 1
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
				fem = 1
				masc = 1
			part
				name = "Parted Hair"
				id = "part"
				fem = 1
				masc = 1
			pomp
				name = "Pompadour"
				id = "pomp"
				fem = 1
				masc = 1
			pompS
				name = "Pompadour: Greaser Shine"
				id = "pompS"
			shortflip
				name = "Punky Flip"
				id = "shortflip"
				fem = 1
				masc = 1
			spiky
				name = "Spiky"
				id = "spiky"
				masc = 1
			subtlespiky
				name = "Subtle Spiky"
				id = "subtlespiky"
				masc = 1
			temsik
				name = "Temsik"
				id = "temsik"
				masc = 1
			tonsure
				name = "Tonsure"
				id = "tonsure"
				masc = 1
			short
				name = "Trimmed"
				id = "short"
				masc = 1
			tulip
				name = "Tulip"
				id = "tulip"
				fem = 1
				masc = 1
			visual
				name = "Visual"
				id = "visual"
				masc = 1
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
				fem = 1
				masc = 1
			disheveled
				name = "Disheveled"
				id = "disheveled"
				fem = 1
			doublepart
				name = "Double-Part"
				id = "doublepart"
			shoulders
				name = "Draped"
				id = "shoulders"
				fem = 1
			dreads
				name = "Dreadlocks"
				id = "dreads"
				masc = 1
			dreadsA
				name = "Dreadlocks: Alternating"
				id = "dreadsA"
			fabio
				name = "Fabio"
				id = "fabio"
				fem = 1
			glammetal
				name = "Glammetal"
				id = "glammetal"
				fem = 1
			glammetalO
				name = "Glammetal: Faded"
				id = "glammetalO"
			eighties
				name = "Hairmetal"
				id = "80s"
				fem = 1
			eightiesfade
				name = "Hairmetal: Faded"
				id = "80sfade"
			halfshavedR
				name = "Half-Shaved: Left"
				id = "halfshavedR"
				masc = 1
				fem = 1
			halfshaved_s
				name = "Half-Shaved: Long"
				id = "halfshaved_s"
				fem = 1
			halfshavedL
				name = "Half-Shaved: Right"
				id = "halfshavedL"
				fem = 1
				masc = 1
			kingofrockandroll
				name = "Kingmetal"
				id = "king-of-rock-and-roll"
				masc = 1
			froofy_long
				name = "Long and Froofy"
				id = "froofy_long"
				fem = 1
			longbraid
				name = "Long Braid"
				id = "longbraid"
				fem = 1
			longsidepart_s
				name = "Long Flip"
				id = "longsidepart_s"
				fem = 1
			pulledb
				name = "Pulled Back"
				id = "pulledb"
				fem = 1
			sage
				name = "Sage"
				id = "sage"
				fem = 1
			scraggly
				name = "Scraggly"
				id = "scraggly"
				masc = 1
			pulledf
				name = "Shoulder Drape"
				id = "pulledf"
				fem = 1
			shoulderl
				name = "Shoulder-Length"
				id = "shoulderl"
				fem = 1
			slightlymess_s
				name = "Shoulder-Length Mess"
				id = "slightlymessy_s"
				fem = 1
			smoothwave
				name = "Smooth Waves"
				id = "smoothwave"
				fem = 1
			smoothwave_fade
				name = "Smooth Waves: Faded"
				id = "smoothwave_fade"
			mermaid
				name = "Mermaid"
				id = "mermaid"
				fem = 1
			mermaidfade
				name = "Mermaid: Faded"
				id = "mermaidfade"
			midb
				name = "Mid-Back Length"
				id = "midb"
				fem = 1
				masc = 1
			bluntbangs_s
				name = "Mid-Length Curl"
				id = "bluntbangs_s"
				fem = 1
			vlong
				name = "Very Long"
				id = "vlong"
				fem = 1
		hairup
			bun
				name = "Bun"
				id = "bun"
				fem = 1
			sakura
				name = "Captor"
				id = "sakura"
				fem = 1
			croft
				name = "Croft"
				id = "croft"
				fem = 1
			indian
				name = "Double Braids"
				id = "indian"
				fem = 1
			doublebun
				name = "Double Buns"
				id = "doublebun"
				fem = 1
			drill
				name = "Drill"
				id = "drill"
			fun_bun
				name = "Fun Bun"
				id = "fun_bun"
				fem = 1
			charioteers
				name = "High Flat Top"
				id = "charioteers"
				masc = 1
			spud
				name = "High Ponytail"
				id = "spud"
				fem = 1
			longtailed
				name = "Long Mini Tail"
				id = "longtailed"
				fem = 1
			lowpig
				name = "Low Pigtails"
				id = "lowpig"
				fem = 1
			band
				name = "Low Ponytail"
				id = "band"
				fem = 1
			minipig
				name = "Mini Pigtails"
				id = "minipig"
				fem = 1
				masc = 1
			pig
				name = "Pigtails"
				id = "pig"
				fem = 1
			ponytail
				name = "Ponytail"
				id = "ponytail"
				fem = 1
				masc = 1
			geisha_s
				name = "Shimada"
				id = "geisha_s"
				fem = 1
			twotail
				name = "Split-Tails"
				id = "twotail"
				masc = 1
			wavy_tail
				name = "Wavy Ponytail"
				id = "wavy_tail"
				fem = 1
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

proc/select_custom_style(list/customization_types, mob/living/carbon/human/user as mob)
	var/list/options = list()
	for (var/styletype as anything in customization_types)
		var/datum/customization_style/CS = new styletype
		options[CS.name] = CS
	var/new_style = input(user, "Please select style", "Style")  as null|anything in options
	return options[new_style]

proc/find_style_by_name(var/target_name)
	for (var/styletype as anything in concrete_typesof(/datum/customization_style))
		var/datum/customization_style/CS = new styletype
		if(CS.name == target_name)
			return CS
	return new /datum/customization_style/none

proc/find_style_by_id(var/target_id)
	for (var/styletype as anything in concrete_typesof(/datum/customization_style))
		var/datum/customization_style/CS = new styletype
		if(CS.id == target_id)
			return CS
	return new /datum/customization_style/none
