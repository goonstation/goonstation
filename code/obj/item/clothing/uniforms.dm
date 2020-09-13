// UNDERS AND BY THAT, NATURALLY I MEAN UNIFORMS/JUMPSUITS

/obj/item/clothing/under
	name = "jumpsuit"
	desc = "A serviceable and comfortable jumpsuit used by nearly everyone on the station."
	icon = 'icons/obj/clothing/uniforms/item_js.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js.dmi'
	var/image/wear_image_fat = null
	var/image/wear_image_fat_icon = 'icons/mob/jumpsuits/worn_js_fat.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js.dmi'
	icon_state = "black"
	item_state = "black"
	body_parts_covered = TORSO|LEGS|ARMS
	protective_temperature = T0C + 50
	permeability_coefficient = 0.90
	flags = FPRINT|TABLEPASS
	//cogwerks - burn vars
	burn_point = 400
	burn_output = 800
	burn_possible = 1
	health = 50

	duration_remove = 6.5 SECONDS

	setupProperties()
		..()
		setProperty("coldprot", 5)
		setProperty("heatprot", 5)
		setProperty("meleeprot", 1)

/obj/item/clothing/under/New()
	wear_image_fat = image(wear_image_fat_icon)
	wear_image_fat.icon_state = icon_state
	..()

// Experimental composite jumpsuit

/obj/item/clothing/under/experimental
	name = "experimental hi-tech jumpsuit"
	desc = "The very height of fabric technology."
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_experiment.dmi'
	icon_state = "white"
	item_state = "white"
	var/list/component_images = list("jacket","sleeves","pants", "stripe_sides", "zipper")
	var/list/component_colors = list("#FFFFFF","#FFFFFF","#FFFFFF", "#FFFFFF","#666666")
	var/list/component_alphas = list(255,255,255,255,255)
	var/list/images = list()

	New()
		..()
		update_images()

	proc/update_images()
		var/list_counter = 0
		src.images = list()

		for (var/C as anything in src.component_images)
			list_counter++
			var/image/suit_image = image(icon = src.wear_image_icon, icon_state = C, layer = MOB_CLOTHING_LAYER)
			suit_image.icon_state = C
			suit_image.alpha = src.component_alphas[list_counter]
			suit_image.color = src.component_colors[list_counter]
			src.images += suit_image

		src.color = src.component_colors[1]


/obj/item/clothing/under/crafted
	name = "jumpsuit"
	desc = "A generic jumpsuit with no rank markings."
	c_flags = ONESIZEFITSALL
	icon_state = "white"
	item_state = "white"

// Colors

/obj/item/clothing/under/color
	name = "black jumpsuit"
	desc = "A generic jumpsuit with no rank markings."
	c_flags = ONESIZEFITSALL

	grey
		name = "grey jumpsuit"
		icon_state = "grey"
		item_state = "grey"

	whitetemp
		name = "jumpsuit"
		icon_state = "white"
		item_state = "white"

	white
		name = "white jumpsuit"
		icon_state = "white"
		item_state = "white"

	darkred
		name = "dark red jumpsuit"
		icon_state = "darkred"
		item_state  = "darkred"

	red
		name = "red jumpsuit"
		icon_state = "red"
		item_state = "red"

	lightred
		name = "light red jumpsuit"
		icon_state = "lightred"
		item_state  = "lightred"

	orange
		name = "orange jumpsuit"
		icon_state = "orange"
		item_state = "orange"

	brown
		name = "brown jumpsuit"
		icon_state = "brown"
		item_state  = "brown"

	lightbrown
		name = "tan jumpsuit"
		icon_state = "lightbrown"
		item_state  = "lightbrown"

	yellow
		name = "yellow jumpsuit"
		icon_state = "yellow"
		item_state = "yellow"

	yellowgreen
		name = "olive jumpsuit"
		icon_state = "yellowgreen"
		item_state  = "yellowgreen"

	lime
		name = "lime jumpsuit"
		icon_state = "lightgreen"
		item_state = "lightgreen"

	green
		name = "green jumpsuit"
		icon_state = "green"
		item_state = "green"

	aqua
		name = "cyan jumpsuit"
		icon_state = "aqua"
		item_state  = "aqua"

	lightblue
		name = "sky blue jumpsuit"
		icon_state = "lightblue"
		item_state  = "lightblue"

	blue
		name = "blue jumpsuit"
		icon_state = "blue"
		item_state = "blue"

	darkblue
		name = "indigo jumpsuit"
		icon_state = "darkblue"
		item_state  = "darkblue"

	purple
		name = "purple jumpsuit"
		icon_state = "purple"
		item_state  = "purple"

	lightpurple
		name = "violet jumpsuit"
		icon_state = "lightpurple"
		item_state  = "lightpurple"

	magenta
		name = "magenta jumpsuit"
		icon_state = "magenta"
		item_state = "magenta"

	pink
		name = "pink jumpsuit"
		icon_state = "pink"
		item_state = "pink"
//PRIDE
/obj/item/clothing/under/pride
	name = "pride jumpsuit"
	desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the LGBT flag."
	icon = 'icons/obj/clothing/uniforms/item_js_pride.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_pride.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_pride.dmi'
	icon_state = "gay"
	item_state = "gay"

	ace
		name = "ace pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the asexual pride flag."
		icon_state ="ace"
		item_state = "ace"

	aro
		name = "aro pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the aromantic pride flag."
		icon_state ="aro"
		item_state = "aro"

	bi
		name = "bi pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the bisexual pride flag."
		icon_state ="bi"
		item_state = "bi"

	inter
		name = "inter pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the intersex pride flag."
		icon_state ="inter"
		item_state = "inter"

	lesb
		name = "lesb pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the lesbian pride flag."
		icon_state ="lesb"
		item_state = "lesb"

	nb
		name = "nb pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the non-binary pride flag."
		icon_state ="nb"
		item_state = "nb"

	pan
		name = "pan pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the pansexual pride flag."
		icon_state ="pan"
		item_state = "pan"

	poly
		name = "poly pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the polysexual pride flag."
		icon_state ="poly"
		item_state = "poly"

	trans
		name = "trans pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the transgender pride flag. Wearing this makes you <em>really</em> hate astroterf."
		icon_state ="trans"
		item_state = "trans"

	special
		name = "pride-o-matic jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. This one is made of advanced fibres that can change color."
		var/list/options

		New()
			..()
			options = icon_states(src.icon) // gonna assume that the dmi will only ever have pride jumpsuits

		attack_self(mob/user as mob)
			if (src.options)
				user.show_text("You change [src]'s style.")
				src.icon_state = src.item_state = pick(options)
				user.update_inhands()

// RANKS

/obj/item/clothing/under/rank
	name = "staff assistant's jumpsuit"
	desc = "It's a generic grey jumpsuit. That's about what assistants are worth, anyway."
	icon = 'icons/obj/clothing/uniforms/item_js_rank.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_rank.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_rank.dmi'
	icon_state = "assistant"
	item_state = "assistant"

	april_fools
		icon_state = "assistant-alt"
		item_state = "assistant-alt"

// Heads

/obj/item/clothing/under/rank/captain
	name = "captain's uniform"
	desc = "Would you believe terrorists actually want to steal this jumpsuit? It's true!"
	icon_state = "captain"
	item_state = "captain"

	fancy
		icon_state = "captain-fancy"
		item_state = "captain-fancy"

	red
		icon_state = "captain-red"
		item_state = "captain-red"

	blue
		icon_state = "captain-blue"
		item_state = "captain-blue"

	dress
		icon_state = "captain-dress"
		item_state = "captain-dress"

	dress/red
		icon_state = "captain-dress-red"
		item_state = "captain-dress-red"

	dress/blue
		icon_state = "captain-dress-blue"
		item_state = "captain-dress-blue"

/obj/item/clothing/under/rank/head_of_personnel
	name = "head of personnel's uniform"
	desc = "Rather bland and inoffensive. Perfect for vanishing off the face of the universe."
	icon_state = "hop"
	item_state = "hop"

	fancy
		icon_state = "hop-fancy"
		item_state = "hop-fancy"

	dress
		icon_state = "hop-dress"
		item_state = "hop-dress"

/obj/item/clothing/under/rank/head_of_securityold
	name = "head of security's uniform"
	desc = "It's bright red and rather crisp, much like security's victims tend to be."
	icon_state = "hos"
	item_state = "hos"

	fancy
		icon_state = "hos-fancy"
		item_state = "hos-fancy"

	april_fools
		icon_state = "hos-alt"
		item_state = "hos-alt"

	dress
		icon_state = "hos-dress"
		item_state = "hos-dress"

	fancy_alt
		icon_state = "hos-fancy-alt"
		item_state = "hos-fancy-alt"

/obj/item/clothing/under/misc/head_of_security
	name = "dirty vest"
	desc = "This outfit has seen better days."
	icon_state = "vest"
	item_state = "vest"
	c_flags = SLEEVELESS

/obj/item/clothing/under/rank/chief_engineer
	name = "chief engineer's uniform"
	desc = "It's an old, battered boiler suit with faded oil stains."
	icon_state = "chief"
	item_state = "chief"

	fancy
		icon_state = "chief-fancy"
		item_state = "cheif-fancy"

	april_fools
		icon_state = "chief-alt"
		item_state = "chief-alt"

	dress
		icon_state = "chief-dress"
		item_state = "chief-dress"

/obj/item/clothing/under/rank/research_director
	name = "research director's uniform"
	desc = "This suit is ludicrously cheap. They must be embezzling the research budget again."
	icon_state = "director"
	item_state = "director"

	fancy
		icon_state = "director-fancy"
		item_state = "director-fancy"

	april_fools
		icon_state = "director-alt"
		item_state = "director-alt"

	dress
		icon_state = "director-dress"
		item_state = "director-dress"

/obj/item/clothing/under/rank/medical_director
	name = "medical director's uniform"
	desc = "There's some odd stains on this thing. Hm."
	icon_state = "med_director"
	item_state = "med_director"

	fancy
		icon_state = "med_director-fancy"
		item_state = "med_director-fancy"

	april_fools
		icon_state = "med_director-alt"
		item_state = "med_director-alt"

	dress
		icon_state = "med_director-dress"
		item_state = "med_director-dress"

/obj/item/clothing/under/rank/comm_officer
	name = "\improper Communication Officer's suit"
	desc = "They wanted you as their new recruit and they got what they wanted."
	icon_state = "comm_officer"
	item_state = "comm_officer"

// Security

/obj/item/clothing/under/rank/security
	name = "security uniform"
	desc = "Is anyone who wears a jacket like that EVER good?"
	icon_state = "security"
	item_state = "security"

	april_fools
		icon_state = "security-alt"
		item_state = "security-alt"

/obj/item/clothing/under/rank/det
	name = "hard worn suit"
	desc = "Someone who wears this means business. Either that or they're a total dork."
	icon_state = "detective"
	item_state = "detective"

// Research

/obj/item/clothing/under/rank/medical
	name = "medical doctor's jumpsuit"
	desc = "It's got a red plus on it, that's a good thing right?"
	icon_state = "medical"
	item_state = "medical"
	permeability_coefficient = 0.50

	april_fools
		icon_state = "medical-alt"
		item_state = "medical-alt"

/obj/item/clothing/under/rank/roboticist
	name = "roboticist's jumpsuit"
	desc = "Red and black really helps highlight the cranial fluid stains."
	icon_state = "robotics"
	item_state = "robotics"
	permeability_coefficient = 0.50

	april_fools
		icon_state = "robotics-alt"
		item_state = "robotics-alt"

/obj/item/clothing/under/rank/scientist
	name = "scientist's jumpsuit"
	desc = "A research jumpsuit, supposedly more resistant to biohazards. It had better be!"
	icon_state = "scientist"
	item_state = "scientist"
	permeability_coefficient = 0.50

	april_fools
		icon_state = "scientist-alt"
		item_state = "scientist-alt"

/obj/item/clothing/under/rank/geneticist
	name = "geneticist's jumpsuit"
	desc = "Genetics is very green these days, isn't it?"
	icon_state = "genetics"
	item_state = "genetics"
	permeability_coefficient = 0.50

	april_fools
		icon_state = "genetics-alt"
		item_state = "genetics-alt"

// Engineering

/obj/item/clothing/under/rank/engineer
	name = "engineer's jumpsuit"
	desc = "If this suit was non-conductive, maybe engineers would actually do their damn job."
	icon_state = "engine"
	item_state = "engine"

	april_fools
		icon_state = "engine-alt"
		item_state = "engine-alt"

/obj/item/clothing/under/rank/cargo
	name = "quartermaster's jumpsuit"
	desc = "What can brown do for you?"
	icon_state = "qm"
	item_state = "qm"

	april_fools
		icon_state = "qm-alt"
		item_state = "qm-alt"

/obj/item/clothing/under/rank/mechanic
	name = "mechanic's uniform"
	desc = "Formerly an electrician's uniform, renamed because mechanics are not electricians."
	icon_state = "mechanic"
	item_state = "mechanic"

	april_fools
		icon_state = "mechanic-alt"
		item_state = "mechanic-alt"

/obj/item/clothing/under/rank/overalls
	name = "miner's overalls"
	desc = "Durable overalls for the hard worker who likes to smash rocks into little bits."
	icon_state = "miner"
	item_state = "miner"

	april_fools
		icon_state = "miner-alt"
		item_state = "miner-alt"

/obj/item/clothing/under/rank/orangeoveralls
	name = "construction worker's overalls"
	desc = "Durable overalls for the hard worker who likes to build things."
	wear_image_icon = 'icons/mob/jumpsuits/worn_js.dmi'
	icon = 'icons/obj/clothing/uniforms/item_js.dmi'
	icon_state = "overalls_orange"
	item_state = "overalls_orange"

	yellow
		icon_state = "overalls_yellow"
		item_state = "overalls_yellow"


// Civilian

/obj/item/clothing/under/rank/hydroponics
	name = "botanist's jumpsuit"
	desc = "Has a strong earthy smell to it. Hopefully it's merely dirty as opposed to soiled."
	icon_state = "hydro"
	item_state = "hydro"
	permeability_coefficient = 0.50

	april_fools
		icon_state = "hydro-alt"
		item_state = "hydro-alt"

/obj/item/clothing/under/rank/janitor
	name = "janitor's jumpsuit"
	desc = "You don't really want to think about what those stains are from."
	icon_state = "janitor"
	item_state = "janitor"

	april_fools
		icon_state = "janitor-alt"
		item_state = "janitor-alt"

/obj/item/clothing/under/rank/bartender
	name = "bartender's suit"
	desc = "A nice and tidy outfit. Shame about the bar though."
	icon_state = "barman"
	item_state = "barman"

/obj/item/clothing/under/rank/chef
	name = "chef's uniform"
	desc = "Issued only to the most hardcore chefs in space."
	icon_state = "chef"
	item_state = "chef"

/obj/item/clothing/under/rank/chaplain
	name = "chaplain jumpsuit"
	desc = "A protestant vicar's outfit. Used to be a nun's, but it was a rather bad habit."
	icon_state = "chaplain"
	item_state = "chaplain"

// Not jobs, but not gimmicks

/obj/item/clothing/under/misc
	name = "prisoner's jumpsuit"
	desc = "Busted."
	icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_misc.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_misc.dmi'
	icon_state = "prisoner"
	item_state = "prisoner"

/obj/item/clothing/under/misc/clown
	name = "clown suit"
	desc = "You are likely taking your life into your own hands by wearing this."
	icon_state = "clown"
	item_state = "clown"

	fancy
		icon_state = "clown-fancy"
		item_state = "clown-fancy"

	dress
		name = "clown dress"
		icon_state = "clown-dress"
		item_state = "clown-dress"

/obj/item/clothing/under/misc/vice
	name = "vice officer's suit"
	desc = "This thing reeks of weed."
	icon_state = "viceW"
	item_state = "viceW"

	New()
		..()
		if(prob(50))
			src.icon_state = "viceG"
			src.item_state = "viceG"

/obj/item/clothing/under/misc/atmospheric_technician
	name = "atmospheric technician's jumpsuit"
	desc = "This jumpsuit is comprised of 4% cotton, 96% burn marks."
	icon_state = "atmos"
	item_state = "atmos"

/obj/item/clothing/under/misc/hydroponics
	name = "senior botanist's jumpsuit"
	desc = "Anyone wearing this has probably grown a LOT of weed in their time."
	icon_state = "hydro"
	item_state = "hydro"

/obj/item/clothing/under/misc/mail
	name = "mailman's jumpsuit"
	desc = "The crisp threads of a postmaster."
	icon_state = "mail"
	item_state = "mail"

	syndicate

/obj/item/clothing/under/misc/barber
	name = "barber's uniform"
	desc = "The classic attire of a barber."
	icon_state = "barber"
	item_state = "barber"

/obj/item/clothing/under/misc/tourist
	name = "hawaiian shirt"
	desc = "How gauche."
	icon_state = "tourist"
	item_state = "tourist"

	max_payne
		icon_state = "hawaiian"
		item_state = "hawaiian"

/obj/item/clothing/under/misc/serpico
	name = "poncho and shirt"
	desc = "A perfect ensemble for sunny weather."
	icon_state = "serpico"
	item_state = "serpico"

/obj/item/clothing/under/misc/souschef
	name = "sous-chef's uniform"
	desc = "The uniform of an assistant to the Chef. Maybe as translator."
	icon_state = "souschef"
	item_state = "souschef"

/obj/item/clothing/under/misc/lawyer
	name = "lawyer's suit"
	desc = "A rather objectionable piece of clothing."
	icon_state = "lawyerBl"
	item_state = "lawyerBl"

	black
		icon_state = "lawyerB"
		item_state = "lawyerB"

	red
		icon_state = "lawyerR"
		item_state = "lawyerR"

/obj/item/clothing/under/misc/lawyer/red/demonic
	setupProperties()
		..()
		setProperty("rangedprot", 1)
		setProperty("meleeprot", 6)

/obj/item/clothing/under/misc/syndicate
	name = "tactical turtleneck"
	desc = "Non-descript, slightly suspicious civilian clothing."
	icon_state = "syndicate"
	item_state = "syndicate"

/obj/item/clothing/under/misc/turds
	name = "NT-SO Jumpsuit"
	desc = "A Nanotrasen Special Operations jumpsuit."
	icon_state = "turdsuit"
	item_state = "turdsuit"

/obj/item/clothing/under/misc/NT
	name = "nanotrasen jumpsuit"
	desc = "Corporate higher-ups get some pretty comfy jumpsuits."
	icon_state = "nt"
	item_state = "nt"

/obj/item/clothing/under/misc/chaplain
	name = "priest's robe"
	desc = "A catholic robe."
	icon_state = "catholic"
	item_state = "catholic"

/obj/item/clothing/under/misc/chaplain/rabbi
	name = "rabbi's jacket"
	desc = "A kosher piece of attire."
	icon_state = "rabbi"
	item_state = "rabbi"

/obj/item/clothing/under/misc/chaplain/muslim
	name = "imam's robe"
	desc = "It radiates the glory of Allah."
	icon_state = "muslim"
	item_state = "muslim"

/obj/item/clothing/under/misc/chaplain/buddhist
	name = "buddhist robe"
	desc = "That's a pretty sweet robe there."
	icon_state = "buddhist"
	item_state = "buddhist"

/obj/item/clothing/under/misc/chaplain/siropa_robe
	name = "siropa robe"
	desc = "Moderation in all things. Truth, equality, freedom, justice, and karma."
	icon_state = "siropa"
	item_state = "siropa"

/obj/item/clothing/under/misc/chaplain/rasta
	name = "rastafarian's shirt"
	desc = "It's red, yellow and green. The colors of the Ethiopean national flag."
	icon_state = "rasta"
	item_state = "rasta"

/obj/item/clothing/under/misc/chaplain/atheist
	name = "atheist's sweater"
	desc = "A sweater and slacks that defy God."
	icon_state = "atheist"
	item_state = "atheist"

// Athletic Gear

/obj/item/clothing/under/shorts
	name = "athletic shorts"
	desc = "95% Polyester, 5% Spandex!"
	icon = 'icons/obj/clothing/uniforms/item_js_athletic.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_athletic.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_athletic.dmi'
	icon_state = "shortsGy"
	item_state = "shortsGy"
	compatible_species = list("human", "monkey")
	c_flags = ONESIZEFITSALL

	red
		icon_state = "shortsR"
		item_state = "shortsR"

	green
		icon_state = "shortsG"
		item_state = "shortsG"

	blue
		icon_state = "shortsBl"
		item_state = "shortsBl"

	purple
		icon_state = "shortsP"
		item_state = "shortsP"

	black
		icon_state = "shortsB"
		item_state = "shortsB"

	psyche
		name = "psychedelic shorts"
		desc = "Only wear these if you don't mind people staring at your crotch."
		icon_state = "shortsPs"
		item_state = "shortsPs"

	luchador
		name = "luchador shorts"
		desc = "Taken from that strange uncle's trophy cabinet."
		icon_state = "lucha1"
		item_state = "lucha1"

		green
			icon_state = "lucha2"
			item_state = "lucha2"
		red
			icon_state = "lucha3"
			item_state = "lucha3"

	trashsinglet
		name = "trash bag singlet"
		desc = "It's time for the trashman to eat garbage and smash opponents!"
		icon_state = "literaltrash"
		item_state = "literaltrash"

	random
		New()
			..()
			src.color = random_saturated_hex_color(1)

/obj/item/clothing/under/jersey
	name = "white basketball jersey"
	desc = "An all-white jersey. Be careful not to stain it!"
	icon = 'icons/obj/clothing/uniforms/item_js_athletic.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_athletic.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_athletic.dmi'
	icon_state = "jerseyW"
	item_state = "jerseyW"

	red
		name = "red basketball jersey"
		desc = "A jersey with the Martian Marauders away colors."
		icon_state = "jerseyR"
		item_state = "jerseyR"

	green
		name = "green basketball jersey"
		desc = "A jersey with the Neo-Boston Drunkards away colors."
		icon_state = "jerseyG"
		item_state = "jerseyG"

	blue
		name = "blue basketball jersey"
		desc = "A jersey with the Mississippi Singularities away colors."
		icon_state = "jerseyB"
		item_state = "jerseyB"

	purple
		name = "purple basketball jersey"
		desc = "A jersey with the Mercury Suns away colors."
		icon_state = "jerseyP"
		item_state = "jerseyP"

	black
		name = "black basketball jersey"
		desc = "A jersey banned from professional basketball after the Space Jam 2067 tragedy."
		icon_state = "jerseyB"
		item_state = "jerseyB"

	random
		name = "basketball jersey"
		desc = "A jersey for playing basketball. You can't use it for anything else, only playing basketball. That's how this works."
		New()
			..()
			src.color = random_saturated_hex_color(1)

	dan
		name = "basketball jersey"
		desc = "A jersey worn by Smokin' Sealpups the during the last Space Olympics. It seems to be advertising something."
		icon_state = "dan_jersey"
		item_state = "dan_jersey"

/obj/item/clothing/under/swimsuit
	name = "white swimsuit"
	desc = "This piece of clothing is good for when you want to be in the water, but not wearing your normal clothes, but also not naked."
	icon = 'icons/obj/clothing/uniforms/item_js_athletic.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_athletic.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_athletic.dmi'
	icon_state = "fswimW"
	item_state = "fswimW"

	red
		icon_state = "fswimR"
		item_state = "fswimR"

	green
		icon_state = "fswimG"
		item_state = "fswimG"

	blue
		icon_state = "fswimBl"
		item_state = "fswimBl"

	purple
		icon_state = "fswimP"
		item_state = "fswimP"

	black
		icon_state = "fswimB"
		item_state = "fswimB"

	random
		name = "swimsuit"
		New()
			..()
			src.color = random_saturated_hex_color(1)

/obj/item/clothing/under/referee
	name = "referee uniform"
	desc = "For when yelling at athletes is your job, not just your hobby."
	icon = 'icons/obj/clothing/uniforms/item_js_athletic.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_athletic.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_athletic.dmi'
	icon_state = "referee"
	item_state = "referee"

/obj/item/clothing/under/shirt_pants
	name = "shirt and pants"
	desc = "A button-down shirt and some pants."
	icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_misc.dmi'
	icon_state = "shirt_n_pant-b"
	item_state = "shirt_n_pant-b"

	New()
		..()
		src.icon_state = "shirt_n_pant-[pick("b", "br", "w")][pick("", "_tie-r", "_tie-b", "_tie-bl")]"
		src.item_state = "[src.icon_state]"

// Black Pants
/obj/item/clothing/under/shirt_pants_b
	name = "shirt and black pants"
	desc = "A button-down shirt and some black pants."
	icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_misc.dmi'
	icon_state = "shirt_n_pant-b"
	item_state = "shirt_n_pant-b"

/obj/item/clothing/under/shirt_pants_b/redtie
	name = "shirt and black pants with a red tie"
	desc = "A button-down shirt, some black pants and a red tie."
	icon_state = "shirt_n_pant-b_tie-r"
	item_state = "shirt_n_pant-b_tie-r"

/obj/item/clothing/under/shirt_pants_b/blacktie
	name = "shirt and black pants with a black tie"
	desc = "A button-down shirt, some black pants and a black tie."
	icon_state = "shirt_n_pant-b_tie-b"
	item_state = "shirt_n_pant-b_tie-b"

/obj/item/clothing/under/shirt_pants_b/bluetie
	name = "shirt and black pants with a blue tie"
	desc = "A button-down shirt, some black pants and a blue tie."
	icon_state = "shirt_n_pant-b_tie-bl"
	item_state = "shirt_n_pant-b_tie-bl"

// Brown Pants
/obj/item/clothing/under/shirt_pants_br
	name = "shirt and brown pants"
	desc = "A button-down shirt and some brown pants."
	icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_misc.dmi'
	icon_state = "shirt_n_pant-br"
	item_state = "shirt_n_pant-br"

/obj/item/clothing/under/shirt_pants_br/redtie
	name = "shirt and brown pants with a red tie"
	desc = "A button-down shirt, some brown pants and a red tie."
	icon_state = "shirt_n_pant-br_tie-r"
	item_state = "shirt_n_pant-br_tie-r"

/obj/item/clothing/under/shirt_pants_br/blacktie
	name = "shirt and brown pants with a black tie"
	desc = "A button-down shirt, some brown pants and a black tie."
	icon_state = "shirt_n_pant-br_tie-b"
	item_state = "shirt_n_pant-br_tie-b"

/obj/item/clothing/under/shirt_pants_br/bluetie
	name = "shirt and brown pants with a blue tie"
	desc = "A button-down shirt, some black pants and a blue tie."
	icon_state = "shirt_n_pant-br_tie-bl"
	item_state = "shirt_n_pant-br_tie-bl"

// White Pants
/obj/item/clothing/under/shirt_pants_w
	name = "shirt and white pants"
	desc = "A button-down shirt and some white pants."
	icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_misc.dmi'
	icon_state = "shirt_n_pant-w"
	item_state = "shirt_n_pant-w"

/obj/item/clothing/under/shirt_pants_w/redtie
	name = "shirt and white pants"
	desc = "A button-down shirt and some white pants and red tie."
	icon_state = "shirt_n_pant-w_tie-r"
	item_state = "shirt_n_pant-w_tie-r"

/obj/item/clothing/under/shirt_pants_w/blacktie
	name = "shirt and white pants"
	desc = "A button-down shirt and some white pants and black tie."
	icon_state = "shirt_n_pant-w_tie-b"
	item_state = "shirt_n_pant-w_tie-b"

/obj/item/clothing/under/shirt_pants_w/bluetie
	name = "shirt and white pants"
	desc = "A button-down shirt and some white pants and blue tie."
	icon_state = "shirt_n_pant-w_tie-bl"
	item_state = "shirt_n_pant-w_tie-bl"

// Suits

/obj/item/clothing/under/suit
	name = "black suit"
	desc = "A black suit and red tie. Very formal."
	icon_state = "suitB"
	item_state = "suitB"

	dress
		icon_state = "suitB-dress"
		item_state = "suitB-dress"

/obj/item/clothing/under/suit/pinstripe
	name = "pinstripe suit"
	desc = "I wanna offer you some, eh, protection."
	icon_state = "suitPn"
	item_state = "suitPn"

/obj/item/clothing/under/suit/red
	name = "red suit"
	desc = "A red suit and blue tie. Somewhat formal."
	icon_state = "suitR"
	item_state = "suitR"

	dress
		icon_state = "suitR-dress"
		item_state = "suitR-dress"

/obj/item/clothing/under/suit/purple
	name = "purple suit"
	desc = "A purple suit and pink bowtie. Potentially formal."
	icon_state = "suitP"
	item_state = "suitP"

	dress
		icon_state = "suitP-dress"
		item_state = "suitP-dress"

/obj/item/clothing/under/suit/captain
	name = "\improper Captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "suitG"
	item_state = "suitG"

	blue
		icon_state = "suit-capB"
		item_state = "suit-capB"

	dress
		icon_state = "suitG-dress"
		item_state = "suitG-dress"

	dress/blue
		icon_state = "suit-capB-dress"
		item_state = "suit-capB-dress"

/obj/item/clothing/under/suit/hop
	name = "\improper Head of Personnel's suit"
	desc = "A teal suit and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "suitT"
	item_state = "suitT"

	april_fools
		icon_state = "suitR"
		item_state = "suitR"

	dress
		icon_state = "suitT-dress"
		item_state = "suitT-dress"

/obj/item/clothing/under/suit/hos
	name = "\improper Head of Security's suit"
	desc = "A red suit and black necktie. You're either parking cars for people, or you have no taste."
	icon_state = "suitRb"
	item_state = "suitRb"

	dress
		icon_state = "suitRb-dress"
		item_state = "suitRb-dress"

// Scrubs

/obj/item/clothing/under/scrub
	name = "medical scrubs"
	desc = "A combination of comfort and utility intended to make removing every last organ someone has and selling them to a space robot much more official looking."
	icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_misc.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js.dmi'
	icon_state = "scrub-w"
	item_state = "white"

	teal
		icon_state = "scrub-t"
		item_state = "aqua"

	maroon
		icon_state = "scrub-m"
		item_state = "darkred"

	blue
		icon_state = "scrub-b"
		item_state = "darkblue"

	purple
		icon_state = "scrub-p"
		item_state = "lightpurple"

		New()
			..()
			if(prob(50))
				src.icon_state = "scrub-pr"

	orange
		icon_state = "scrub-o"
		item_state = "orange"

	pink
		icon_state = "scrub-pk"
		item_state = "pink"

	flower
		name = "flower scrubs"
		desc = "Man, these scrubs look pretty nice."
		icon_state = "scrub-f"
		item_state = "lightblue"

/obj/item/clothing/under/patient_gown
	name = "gown"
	desc = "A light cloth gown that ties in the back, given to medical patients when undergoing examinations or medical operations."
	icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_misc.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js.dmi'
	icon_state = "patient"
	item_state = "lightblue"

// Towels

/obj/item/clothing/under/towel
	name = "towel"
	desc = "Made of nice, soft terrycloth. Very important when adventuring."
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'
	icon_state = "towel"
	item_state = "towel"
	layer = MOB_LAYER
	throwforce = 1
	w_class = 1
	throw_speed = 2
	throw_range = 10
	body_parts_covered = TORSO
	burn_point = 450
	burn_output = 800
	burn_possible = 1
	health = 20
	rand_pos = 0

	setupProperties()
		..()
		setProperty("coldprot", 10)

	New()
		..()
		src.setMaterial(getMaterial("cotton"), appearance = 0, setname = 0)

	attack_self(mob/user as mob)
		add_fingerprint(user)
		var/choice = input(user, "What do you want to do with [src]?", "Selection") as null|anything in list("Place", "Fold into hat", "Rip up")
		if (!choice)
			return
		switch (choice)
			if ("Place")
				user.drop_item()
				src.layer = EFFECTS_LAYER_BASE-1
				return

			if ("Fold into hat")
				user.show_text("You fold [src] into a hat! Neat.", "blue")
				user.u_equip(src)
				user.put_in_hand_or_drop(new /obj/item/clothing/head/towel_hat())
				qdel(src)
				return

			if ("Rip up")
				boutput(user, "You begin ripping up [src].")
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				else
					for (var/i=3, i>0, i--)
						var/obj/item/material_piece/cloth/cottonfabric/CF = unpool(/obj/item/material_piece/cloth/cottonfabric)
						CF.set_loc(get_turf(src))
					boutput(user, "You rip up [src].")
					user.u_equip(src)
					qdel(src)
					return

	attackby(obj/item/W as obj, mob/user as mob)
		if (issnippingtool(W))
			boutput(user, "You begin cutting up [src].")
			if (!do_after(user, 30))
				boutput(user, "<span class='alert'>You were interrupted!</span>")
				return
			else
				for (var/i=3, i>0, i--)
					new /obj/item/bandage(get_turf(src))
				playsound(src.loc, "sound/items/Scissor.ogg", 100, 1)
				boutput(user, "You cut [src] into bandages.")
				user.u_equip(src)
				qdel(src)
				return
		else
			return ..()

	attack(mob/M as mob, mob/user as mob, def_zone)
		src.add_fingerprint(user)
		if (user.a_intent != "harm")
			M.visible_message("[user] towels [M == user ? "[him_or_her(user)]self" : M] dry.")
		else
			return ..()

	afterattack(atom/target, mob/user, flag)
		if (target && istype(target, /turf/simulated))
			var/turf/simulated/T = target
			user.drop_from_slot(src, T)
			if (src.dry_turf(T))
				user.visible_message("[user] dries [T] with [src].",\
				"You dry [T] with [src].")
		else
			return ..()

	proc/dry_turf(var/turf/simulated/T as turf)
		if (!istype(T))
			return
		var/dried = 0
		if (T.wet == 1) // water but not lube
			T.wet = 0
			dried ++
		for (var/obj/decal/cleanable/water/W in T)
			pool(W)
			dried ++
		for (var/obj/decal/cleanable/urine/U in T) // ew
			pool(U)
			dried ++
		return dried

// Gimmick Jumpsuits

/obj/item/clothing/under/gimmick
	name = "sailor uniform"
	desc = "What's with these guys?! It's like one of my Japanese animes!"
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'
	icon_state = "sailor"
	item_state = "sailor"

/obj/item/clothing/under/gimmick/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	item_state = "psyche"

/obj/item/clothing/under/gimmick/dolan
	name = "maritime duck suit"
	desc = "pls"
	icon_state = "dolan"
	item_state = "dolan"

/obj/item/clothing/under/gimmick/jetson
	name = "Fifties America Reclamation Team Jumpsuit"
	desc = "The standard uniform of a minor terrorist group."
	icon_state = "jetson"
	item_state = "jetson"

/obj/item/clothing/under/gimmick/princess
	// https://forums.somethingawful.com/showthread.php?threadid=3502448
	name = "party princess uniform"
	desc = "Sparkle sparkle!"
	icon_state = "princess"
	item_state = "princess"

/obj/item/clothing/under/gimmick/cosby
	name = "cosby sweater"
	desc = "Symbol of a legendary 80's sitcom dad."
	icon_state = "cosby1"
	item_state = "cosby1"
	New()
		icon_state = "cosby[pick(1,2,3)]"
		..()

/obj/item/clothing/under/gimmick/chaps
	name = "assless chaps"
	desc = "Now with 95% less chafing!"
	icon_state = "chaps"
	item_state = "chaps"

/obj/item/clothing/under/gimmick/vault13
	name = "Vault 13 Jumpsuit"
	desc = "A svelte jumpsuit strangely similar to station-issued versions."
	icon_state = "vault13"
	item_state = "vault13"

/obj/item/clothing/under/gimmick/murph
	name = "captain's jumpsuit"
	desc = "A jumpsuit colored in Captain's Blue."
	icon_state = "murph"
	item_state = "murph"

/obj/item/clothing/under/gimmick/sealab
	name = "diver jumpsuit"
	desc = "A jumpsuit colored in Diver's Orange."
	icon_state = "sealab"
	item_state = "sealab"

/obj/item/clothing/under/gimmick/rainbow
	name = "rainbow jumpsuit"
	desc = "It's very colorful!"
	icon_state = "rainbow"
	item_state = "rainbow"

/obj/item/clothing/under/gimmick/cloud
	name = "cloudy jumpsuit"
	desc = "Have you ever wanted to wear the sky??"
	icon_state = "cloud"
	item_state = "cloud"

/obj/item/clothing/under/gimmick/yay
	name = "happy jumpsuit"
	desc = "Yay!"
	icon_state = "yay"
	item_state = "yay"

/obj/item/clothing/under/gimmick/mario
	name = "plumber's overalls"
	desc = "Do plumbers actually wear outfits like this?"
	icon_state = "mario"
	item_state = "mario"

	luigi
		desc = "These are some seriously second-rate overalls."
		icon_state = "luigi"
		item_state = "luigi"

	wario
		name = "rancid overalls"
		desc = "Christ, these things stink!"
		icon_state = "wario"
		item_state = "wario"
		c_flags = ONESIZEFITSALL

	waluigi
		name = "total prick's overalls"
		desc = "Only an asshole of immense magnitude would wear something like this."
		icon_state = "waluigi"
		item_state = "waluigi"

/obj/item/clothing/head/mario
	name = "plumber's hat"
	desc = "A red cap with an \"M\" on it. Probably not actually related to plumbing at all."
	icon_state = "mario"
	item_state = "rgloves"

	luigi
		desc = "A green cap with an \"L\" on it. What kind of manchild wears this?"
		icon_state = "luigi"

	wario
		name = "foul yellow hat"
		desc = "A yellow cap with an \"W\" on it. It reeks of sweat and grease."
		icon_state = "wario"

	waluigi
		name = "massive asshole's hat"
		desc = "A purple cap with a tetris block on it. It radiates pure malice."
		icon_state = "waluigi"


/obj/item/clothing/under/misc/hitman
    name = "shirt and tie"
    desc = "A crisp white button down shirt with a bright red tie."
    icon_state = "shirt_n_pant-b_tie-r"
    item_state = "shirt_n_pant-b_tie-r"

/obj/item/clothing/under/gimmick/witchfinder
    name = "witchfinder general's outfit"
    desc = "A rather mean looking outfit."
    icon_state = "witchfinder"
    item_state = "witchfinder"

/obj/item/clothing/under/gimmick/toga
    name = "toga"
    desc = "Toga party! Toga party!"
    icon_state = "toga"
    item_state = "toga"

/obj/item/clothing/under/misc/bandshirt
    var/disturbed = 0
    name = "band shirt"
    desc = "Woah, these guys stopped touring in '37. Vintage!"
    icon_state = "bandshirt"
    item_state = "bandshirt"
    icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
    wear_image_icon = 'icons/mob/jumpsuits/worn_js_misc.dmi'

/obj/item/clothing/under/misc/bandshirt/attack_hand(mob/user as mob)
	if  ( ..() && !disturbed )
		new /obj/item/clothing/mask/cigarette/dryjoint(get_turf(user))
		boutput(user, "Something falls out of the shirt as you pick it up!")
		disturbed = 1

/obj/item/clothing/under/misc/colmob
    name = "columbian mobster suit"
    desc = "I'm a political prisoner from Space Cuba and I want my fucking human rights now!"
    icon_state = "colmob"
    item_state = "colmob"
    icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
    wear_image_icon = 'icons/mob/jumpsuits/worn_js_misc.dmi'

/obj/item/clothing/under/misc/rusmob
    name = "soviet mobster suit"
    desc = "She Swallows Burning Coals."
    icon_state = "rusmob"
    item_state = "rusmob"
    icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
    wear_image_icon = 'icons/mob/jumpsuits/worn_js_misc.dmi'

/obj/item/clothing/under/gimmick/jester
    name = "jester's outfit"
    desc = "Outfit of a not-so-funny-clown."
    icon_state = "jester"
    item_state = "jester"
