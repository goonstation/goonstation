// UNDERS AND BY THAT, NATURALLY I MEAN UNIFORMS/JUMPSUITS

/obj/item/clothing/under
	name = "jumpsuit"
	desc = "A serviceable and comfortable jumpsuit used by nearly everyone on the station."
	icon = 'icons/obj/clothing/uniforms/item_js.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js.dmi'
	icon_state = "black"
	item_state = "black"
	body_parts_covered = TORSO|LEGS|ARMS
	protective_temperature = T0C + 50
	//cogwerks - burn vars
	burn_point = 400
	burn_output = 800
	burn_possible = TRUE
	health = 10
	var/team_num
	var/cutting_product = /obj/item/material_piece/cloth/cottonfabric

	duration_remove = 7.5 SECONDS

	setupProperties()
		..()
		setProperty("coldprot", 5)
		setProperty("heatprot", 5)
		setProperty("meleeprot", 1)
		setProperty("chemprot", 10)

	attackby(obj/item/W, mob/user)
		if ((issnippingtool(W) || iscuttingtool(W)) && src.cutting_product)
			if (istype(src.loc, /mob))
				boutput(user, SPAN_ALERT("You can't cut that unless it's on a flat surface!"))
				return
			SETUP_GENERIC_ACTIONBAR(user, src, 0.5 SECOND, /obj/item/clothing/under/proc/cut_tha_crap, list(user), W.icon, W.icon_state, null, INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)

	proc/cut_tha_crap(mob/user)
		qdel(src)
		var/obj/item/cupr = new src.cutting_product()
		user.put_in_hand_or_drop(cupr)
		user.visible_message(SPAN_NOTICE("<b>[user]</b> cuts \the [src] into \a [cupr]."),SPAN_NOTICE("You cut the [src] into \a [cupr]!"))

/obj/item/clothing/under/crafted
	name = "jumpsuit"
	desc = "A generic jumpsuit with no rank markings."
	icon_state = "white"
	item_state = "white"

// Colors

/obj/item/clothing/under/color
	name = "black jumpsuit"
	desc = "A generic jumpsuit with no rank markings."

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

	unremovable
		cant_self_remove = 1
		cant_other_remove = 1
//PRIDE
/obj/item/clothing/under/pride
	name = "LGBT pride jumpsuit"
	desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the LGBT flag."
	icon = 'icons/obj/clothing/uniforms/item_js_pride.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_pride.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_pride.dmi'
	icon_state = "gay"
	item_state = "gay"
	cutting_product = /obj/item/flag/rainbow
	burn_possible = FALSE

	ace
		name = "ace pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the asexual pride flag."
		icon_state ="ace"
		item_state = "ace"
		cutting_product = /obj/item/flag/ace

	aro
		name = "aro pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the aromantic pride flag."
		icon_state ="aro"
		item_state = "aro"
		cutting_product = /obj/item/flag/aro

	bi
		name = "bi pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the bisexual pride flag."
		icon_state ="bi"
		item_state = "bi"
		cutting_product = /obj/item/flag/bisexual

	inter
		name = "inter pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the intersex pride flag."
		icon_state ="inter"
		item_state = "inter"
		cutting_product = /obj/item/flag/intersex

	lesb
		name = "lesb pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the lesbian pride flag."
		icon_state ="lesb"
		item_state = "lesb"
		cutting_product = /obj/item/flag/lesb

	gaymasc
		name = "MLM pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of vincian pride flag, but can be flipped inside-out to change it to the achillean one."
		icon_state ="mlm"
		item_state = "mlm"
		var/isachily = FALSE
		var/ach_descstate = "A corporate token of inclusivity, made in a sweatshop. It's based off of achillean pride flag, but can be flipped inside-out to change it to the vincian one."
		cutting_product = /obj/item/flag/mlmvinc

		attack_self(mob/user as mob)
			user.show_text("You flip the [src] inside out.")
			if(!src.isachily)
				src.isachily = TRUE
				src.desc = ach_descstate
				src.icon_state = "[src.icon_state]alt"
				src.item_state = "mlmalt"
				src.cutting_product = /obj/item/flag/mlmachi
			else
				src.isachily = FALSE
				src.desc = initial(src.desc)
				src.icon_state = initial(src.icon_state)
				src.item_state = "mlm"
				src.cutting_product = /obj/item/flag/mlmvinc
			src.UpdateIcon()



	nb
		name = "\improper NB pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the non-binary pride flag."
		icon_state ="nb"
		item_state = "nb"
		cutting_product = /obj/item/flag/nb

	pan
		name = "pan pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the pansexual pride flag."
		icon_state ="pan"
		item_state = "pan"
		cutting_product = /obj/item/flag/pan

	poly
		name = "poly pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the polysexual pride flag. Previously mistaken for polyamorous in uniform fabricators - the responsible employee was promptly terminated under all applicable versions of Space Law."
		icon_state ="poly"
		item_state = "poly"
		cutting_product = /obj/item/flag/polysexual

	trans
		name = "trans pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the transgender pride flag. Wearing this makes you <em>really</em> hate astroterf."
		icon_state ="trans"
		item_state = "trans"
		cutting_product = /obj/item/flag/trans

	special
		name = "pride-o-matic jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. This one is made of advanced fibres that can change color."
		var/list/options

		New()
			..()
			options = get_icon_states(src.icon) // gonna assume that the dmi will only ever have pride jumpsuits

		attack_self(mob/user as mob)
			if (src.options)
				user.show_text("You change [src]'s style.")
				src.icon_state = src.item_state = pick(options)
				user.update_inhands()

// RANKS

ABSTRACT_TYPE(/obj/item/clothing/under/rank)
/obj/item/clothing/under/rank
    name = "rank under parent"
    icon = 'icons/obj/clothing/uniforms/item_js_rank.dmi'
    wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_rank.dmi'
    inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_rank.dmi'

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

/obj/item/clothing/under/rank/head_of_security
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

/obj/item/clothing/under/misc/dirty_vest //HoS uniform from the Elite Security era
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
		item_state = "chief-fancy"

	april_fools
		icon_state = "chief-alt"
		item_state = "chief-alt"

	dress
		icon_state = "chief-dress"
		item_state = "chief-dress"

	scarf
		name = "chief engineer's outfit"
		desc = "A brand new fancy outfit, with a scarf! Still somehow covered with faded oil stains."
		icon_state = "chief-engineer-scarf"
		item_state = "chief-engineer-scarf"

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

	assistant
		name = "security assistant uniform"
		desc = "Wait, is that velcro?"
		icon_state = "security-assistant"
		item_state = "security-assistant"

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

	april_fools
		icon_state = "medical-alt"
		item_state = "medical-alt"

/obj/item/clothing/under/rank/roboticist
	name = "roboticist's jumpsuit"
	desc = "Black and white, like ethics."
	icon_state = "robotics"
	item_state = "robotics"

	april_fools
		icon_state = "robotics-alt"
		item_state = "robotics-alt"

/obj/item/clothing/under/rank/scientist
	name = "scientist's jumpsuit"
	desc = "A research jumpsuit, supposedly more resistant to biohazards. It had better be!"
	icon_state = "scientist"
	item_state = "scientist"

	april_fools
		icon_state = "scientist-alt"
		item_state = "scientist-alt"

/obj/item/clothing/under/rank/geneticist
	name = "geneticist's jumpsuit"
	desc = "Genetics is very green these days, isn't it?"
	icon_state = "genetics"
	item_state = "genetics"

	april_fools
		icon_state = "genetics-alt"
		item_state = "genetics-alt"

/obj/item/clothing/under/rank/pathologist
	name = "pathologist's jumpsuit"
	desc = "Scientifically proven to block up to 99% of pathogens."
	icon_state = "pathology"
	item_state = "pathology"

	april_fools
		icon_state = "medical-alt"
		item_state = "medical-alt"

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
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js.dmi'
	icon = 'icons/obj/clothing/uniforms/item_js.dmi'
	icon_state = "overalls_orange"
	item_state = "overalls_orange"

	yellow
		icon_state = "overalls_yellow"
		item_state = "overalls_yellow"


// Civilian

/obj/item/clothing/under/rank/assistant
	name = "staff assistant's jumpsuit"
	desc = "It's a generic grey jumpsuit. That's about what assistants are worth, anyway."
	icon_state = "assistant"
	item_state = "assistant"

/obj/item/clothing/under/rank/assistant/april_fools
	icon_state = "assistant-alt"
	item_state = "assistant-alt"

/obj/item/clothing/under/rank/hydroponics
	name = "botanist's jumpsuit"
	desc = "Has a strong earthy smell to it. Hopefully it's merely dirty as opposed to soiled."
	icon_state = "hydro"
	item_state = "hydro"

	april_fools
		icon_state = "hydro-alt"
		item_state = "hydro-alt"

/obj/item/clothing/under/rank/rancher
	name = "rancher's overalls"
	desc = "Smells like a barn; hopefully its wearer wasn't raised in one."
	icon_state = "rancher"
	item_state = "rancher"

/obj/item/clothing/under/rank/angler
	name = "angler's overalls"
	desc = "Smells fishy; It's wearer must have a keen appreciation for the piscine."
	icon_state = "angler"
	item_state = "angler"

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

	april_fools
		icon_state = "chef-alt"
		item_state = "chef-alt"

/obj/item/clothing/under/rank/chaplain
	name = "chaplain jumpsuit"
	desc = "A protestant vicar's outfit. Used to be a nun's, but it was a rather bad habit."
	icon_state = "chaplain"
	item_state = "chaplain"

// Not jobs, but not gimmicks

ABSTRACT_TYPE(/obj/item/clothing/under/misc)
/obj/item/clothing/under/misc
	name = "under misc parent"
	icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_misc.dmi'

/obj/item/clothing/under/misc/prisoner
	name = "prisoner's jumpsuit"
	desc = "Busted."
	icon_state = "prisoner"
	item_state = "prisoner"

/obj/item/clothing/under/misc/clown
	name = "clown suit"
	desc = "You are likely taking your life into your own hands by wearing this."
	icon_state = "clown"
	item_state = "clown"

	New()
		..()
		AddComponent(/datum/component/clown_disbelief_item)

	fancy
		icon_state = "clown-fancy"
		item_state = "clown-fancy"

	dress
		name = "clown dress"
		icon_state = "clown-dress"
		item_state = "clown-dress"

/obj/item/clothing/under/misc/mimefancy
	name = "fancy mime suit"
	desc = "A suit perfect for more sophisticated mimes. Wait... This isn't just a bleached clown suit, is it?"
	icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
	icon_state = "mime-fancy"
	item_state = "mime-fancy"

/obj/item/clothing/under/misc/mimedress
	name = "mime dress"
	desc = "You may be trapped in an invisible box forever and ever, but at least you look stylish!"
	icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
	icon_state = "mime-dress"
	item_state = "mime-dress"

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
	icon_state = "hydro-senior"
	item_state = "hydro-senior"

/obj/item/clothing/under/misc/mail
	name = "postmaster's jumpsuit"
	desc = "The crisp threads of a postmaster."
	icon_state = "mail"
	item_state = "mail"

	april_fools
		icon_state = "mail-alt"
		item_state = "mail-alt"

	syndicate
		april_fools  // This pathing is weird and I hate it
			icon_state = "mail-alt"
			item_state = "mail-alt"

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

/obj/item/clothing/under/misc/rarestroom
	name = "'I found the rarest room and all I got was this lousy t-shirt.' t-shirt"
	desc = "You did it, but for what?"
	icon_state = "rarest"
	item_state = "rarest"

/obj/item/clothing/under/misc/souschef
	name = "sous-chef's uniform"
	desc = "The uniform of an assistant to the Chef. Maybe as translator."
	icon_state = "souschef"
	item_state = "souschef"

/obj/item/clothing/under/misc/itamae
	name = "itamae uniform"
	desc = "A coat and apron worn commonly worn by Japanese Chefs, waiting to be ruined with the blood you'll inevitably cover it in."
	icon_state = "itamae"
	item_state = "itamae"

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
	item_function_flags = IMMUNE_TO_ACID
	setupProperties()
		..()
		setProperty("coldprot", 40) //slightly worse than a spacesuit
		setProperty("heatprot", 40) //slightly worse than a firesuit
		setProperty("rangedprot", 1.5) //buffed from 1, felt needed, tune up or down as needed
		setProperty("meleeprot", 7) //buffed from 6, felt needed, tune up or down as needed

/obj/item/clothing/under/misc/syndicate
	name = "tactical turtleneck"
	desc = "Non-descript, slightly suspicious civilian clothing."
	icon_state = "syndicate"
	item_state = "syndicate"
	team_num = TEAM_SYNDICATE
	#ifdef MAP_OVERRIDE_POD_WARS
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == team_num)
			..()
		else
			boutput(user, SPAN_ALERT("The jumpsuit <b>explodes</b> as you reach out to grab it!"))
			make_fake_explosion(src)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
	#endif

/obj/item/clothing/under/misc/turds
	name = "NT combat uniform"
	desc = "A Nanotrasen security jumpsuit."
	icon_state = "turdsuit"
	item_state = "turdsuit"
	team_num = TEAM_NANOTRASEN
	#ifdef MAP_OVERRIDE_POD_WARS
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == team_num)
			..()
		else
			boutput(user, SPAN_ALERT("The jumpsuit <b>explodes</b> as you reach out to grab it!"))
			make_fake_explosion(src)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
	#endif

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

/obj/item/clothing/under/misc/chaplain/nun
	name = "nun robe"
	desc = "A long, black robe, traditonally worn by nuns. Ruler not included."
	icon_state = "nun_robe"
	item_state = "nun_robe"

// Athletic Gear

TYPEINFO(/obj/item/clothing/under/shorts)
	random_subtypes = list(/obj/item/clothing/under/shorts,
		/obj/item/clothing/under/shorts/red,
		/obj/item/clothing/under/shorts/green,
		/obj/item/clothing/under/shorts/blue,
		/obj/item/clothing/under/shorts/purple,
		/obj/item/clothing/under/shorts/black)

/obj/item/clothing/under/shorts
	name = "athletic shorts"
	desc = "95% Polyester, 5% Spandex!"
	icon = 'icons/obj/clothing/uniforms/item_js_athletic.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_athletic.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_athletic.dmi'
	icon_state = "shortsGy"
	item_state = "shortsGy"

/obj/item/clothing/under/shorts/red
	icon_state = "shortsR"
	item_state = "shortsR"

/obj/item/clothing/under/shorts/green
	icon_state = "shortsG"
	item_state = "shortsG"

/obj/item/clothing/under/shorts/blue
	icon_state = "shortsBl"
	item_state = "shortsBl"

/obj/item/clothing/under/shorts/purple
	icon_state = "shortsP"
	item_state = "shortsP"

/obj/item/clothing/under/shorts/black
	icon_state = "shortsB"
	item_state = "shortsB"

/obj/item/clothing/under/shorts/psyche
	name = "psychedelic shorts"
	desc = "Only wear these if you don't mind being the center of attention."
	icon_state = "shortsPs"
	item_state = "shortsPs"

TYPEINFO(/obj/item/clothing/under/shorts/luchador)
	random_subtypes = list(/obj/item/clothing/under/shorts/luchador,
		/obj/item/clothing/under/shorts/luchador/red,
		/obj/item/clothing/under/shorts/luchador/green)
/obj/item/clothing/under/shorts/luchador
	name = "luchador shorts"
	desc = "Taken from that strange uncle's trophy cabinet."
	icon_state = "lucha1"
	item_state = "lucha1"

/obj/item/clothing/under/shorts/luchador/green
	icon_state = "lucha2"
	item_state = "lucha2"
/obj/item/clothing/under/shorts/luchador/red
	icon_state = "lucha3"
	item_state = "lucha3"

/obj/item/clothing/under/shorts/random_color
	New()
		..()
		src.color = random_saturated_hex_color(1)

/obj/item/clothing/under/jersey
	name = "white basketball jersey"
	desc = "An all-white jersey. Be careful not to stain it!"
	icon = 'icons/obj/clothing/uniforms/item_js_athletic.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_athletic.dmi'
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
		icon_state = "jerseyBl"
		item_state = "jerseyBl"

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
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_athletic.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_athletic.dmi'
	icon_state = "fswimW"
	item_state = "fswimW"

	red
		name = "red swimsuit"
		icon_state = "fswimR"
		item_state = "fswimR"

	green
		name = "green swimsuit"
		icon_state = "fswimG"
		item_state = "fswimG"

	blue
		name = "blue swimsuit"
		icon_state = "fswimBl"
		item_state = "fswimBl"

	purple
		name = "purple swimsuit"
		icon_state = "fswimP"
		item_state = "fswimP"

	black
		name = "black swimsuit"
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
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_athletic.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_athletic.dmi'
	icon_state = "referee"
	item_state = "referee"

/obj/item/clothing/under/shirt_pants
	name = "shirt and pants"
	desc = "A button-down shirt and some pants."
	icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
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
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
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
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
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
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
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

ABSTRACT_TYPE(/obj/item/clothing/under/suit)
/obj/item/clothing/under/suit

/obj/item/clothing/under/suit/black
	name = "black suit"
	desc = "A black suit and red tie. Very formal."
	icon_state = "suitB"
	item_state = "suitB"

/obj/item/clothing/under/suit/black/dress
	name = "black dress"
	desc = "A black dress. Very formal."
	icon_state = "suitB-dress"
	item_state = "suitB-dress"

/obj/item/clothing/under/suit/mortician
	name = "Mortician's Suit"
	desc = "A drab black suit. Very formal. Fitting for someone who works with bodies."
	icon_state = "suitB"
	item_state = "suitB"

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

/obj/item/clothing/under/suit/red/dress
	icon_state = "suitR-dress"
	item_state = "suitR-dress"

/obj/item/clothing/under/suit/purple
	name = "purple suit"
	desc = "A purple suit and pink bowtie. Potentially formal."
	icon_state = "suitP"
	item_state = "suitP"

/obj/item/clothing/under/suit/purple/dress
	icon_state = "suitP-dress"
	item_state = "suitP-dress"

/obj/item/clothing/under/suit/captain
	name = "\improper Captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "suitG"
	item_state = "suitG"

/obj/item/clothing/under/suit/captain/blue
	icon_state = "suit-capB"
	item_state = "suit-capB"

/obj/item/clothing/under/suit/captain/dress
	icon_state = "suitG-dress"
	item_state = "suitG-dress"

/obj/item/clothing/under/suit/captain/dress/blue
	icon_state = "suit-capB-dress"
	item_state = "suit-capB-dress"

/obj/item/clothing/under/suit/hop
	name = "\improper Head of Personnel's suit"
	desc = "A teal suit and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "suitT"
	item_state = "suitT"

/obj/item/clothing/under/suit/hop/april_fools
	icon_state = "suitR"
	item_state = "suitR"

/obj/item/clothing/under/suit/hop/dress
	icon_state = "suitT-dress"

/obj/item/clothing/under/suit/hos
	name = "\improper Head of Security's suit"
	desc = "A red suit and black necktie. You're either parking cars for people, or you have no taste."
	icon_state = "suitRb"
	item_state = "suitRb"

/obj/item/clothing/under/suit/hos/dress
	icon_state = "suitRb-dress"
	item_state = "suitRb-dress"

// Scrubs

/obj/item/clothing/under/scrub
	name = "medical scrubs"
	desc = "A combination of comfort and utility intended to make removing every last organ someone has and selling them to a space robot much more official looking."
	icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
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
		icon_state = "scrub-n"
		item_state = "darkblue"

	purple
		icon_state = "scrub-v"
		item_state = "lightpurple"

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
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js.dmi'
	icon_state = "patient"
	item_state = "lightblue"

// Towels

TYPEINFO(/obj/item/clothing/under/towel)
	mat_appearances_to_ignore = list("cotton")
/obj/item/clothing/under/towel
	name = "towel"
	desc = "Made of nice, soft terrycloth. Very important when adventuring."
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'
	icon_state = "towel"
	item_state = "towel"
	layer = MOB_LAYER
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 2
	throw_range = 10
	body_parts_covered = TORSO
	burn_point = 450
	burn_output = 800
	burn_possible = TRUE
	rand_pos = 0
	mat_changename = FALSE
	default_material = "cotton"

	setupProperties()
		..()
		setProperty("coldprot", 10)

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
				try_rip_up(user)

	attackby(obj/item/W, mob/user)
		if (issnippingtool(W))
			boutput(user, "You begin cutting up [src].")
			if (!do_after(user, 3 SECONDS))
				boutput(user, SPAN_ALERT("You were interrupted!"))
				return
			else
				for (var/i=3, i>0, i--)
					new /obj/item/bandage(get_turf(src))
				playsound(src.loc, 'sound/items/Scissor.ogg', 100, 1)
				boutput(user, "You cut [src] into bandages.")
				user.u_equip(src)
				qdel(src)
				return
		else
			return ..()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		src.add_fingerprint(user)
		if (user.a_intent != "harm")
			target.visible_message("[user] towels [target == user ? "[him_or_her(user)]self" : target] dry.")
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
			qdel(W)
			dried ++
		return dried

// Gimmick Jumpsuits

ABSTRACT_TYPE(/obj/item/clothing/under/gimmick)
/obj/item/clothing/under/gimmick
	name = "Coder Jumpsuit"
	desc = "This is weird! Report this to a coder!"
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'
	icon_state = "sailor"
	item_state = "sailor"

/obj/item/clothing/under/gimmick/sailor
	name = "sailor uniform"
	desc = "What's with these guys?! It's like one of my Japanese animes!"
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
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

/obj/item/clothing/under/gimmick/sweater
	name = "comfy sweater"
	desc = "A colourful and cozy jumper."
	icon_state = "sweater1"
	item_state = "sweater1"
	New()
		icon_state = "sweater[pick(1,2,3)]"
		..()

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

/obj/item/clothing/under/misc/bandshirt/attack_hand(mob/user)
	if  ( ..() && !disturbed )
		new /obj/item/clothing/mask/cigarette/dryjoint(get_turf(user))
		boutput(user, "Something falls out of the shirt as you pick it up!")
		disturbed = 1

/obj/item/clothing/under/misc/mobster
    name = "mobster suit"
    desc = "Scream."
    icon_state = "mob1"
    item_state = "mob1"

/obj/item/clothing/under/misc/mobster/alt
    name = "mobster suit"
    desc = "She Swallows Burning Coals."
    icon_state = "mob2"
    item_state = "mob2"

/obj/item/clothing/under/gimmick/jester
    name = "jester's outfit"
    desc = "Outfit of a not-so-funny-clown."
    icon_state = "jester"
    item_state = "jester"

/obj/item/clothing/under/misc/spade
    name = "spade jumpsuit"
    desc = "A suit suit. This suit's suit is a spade."
    icon_state = "spade"
    item_state = "spade"

/obj/item/clothing/under/misc/club
    name = "club jumpsuit"
    desc = "A suit suit. This suit's suit is a club."
    icon_state = "club"
    item_state = "club"

/obj/item/clothing/under/misc/heart
    name = "heart jumpsuit"
    desc = "A suit suit. This suit's suit is a heart. D'aww."
    icon_state = "heart"
    item_state = "heart"

/obj/item/clothing/under/misc/diamond
    name = "diamond jumpsuit"
    desc = "A suit suit. This suit's suit is a diamond."
    icon_state = "diamond"
    item_state = "diamond"

/obj/item/clothing/under/misc/tech_shirt
    name = "tech shirt"
    desc = "A shirt with a fancy, vaguely sci-fi pattern on it."
    icon_state = "tech_shirt"
    item_state = "tech_shirt"

/obj/item/clothing/under/misc/flannel
    name = "flannel shirt"
    desc = "Perfect for chopping wood or drinking coffee."
    icon_state = "flannel"
    item_state = "flannel"

/obj/item/clothing/under/misc/fish
    name = "fish shirt"
    desc = "It reads, 'Fish'."
    icon_state = "fish"
    item_state = "fish"

ABSTRACT_TYPE(/obj/item/clothing/under/misc/collar_shirt)
/obj/item/clothing/under/misc/collar_shirt
	name = "collar shirt"
	icon_state = "collar_shirt-white"
	item_state = "collar_shirt-white"
	var/shirt_colour_name = "white"

	New()
		..()
		src.name = "[src.shirt_colour_name] collar shirt"
		src.desc = "A plain [src.shirt_colour_name] collared shirt."

/obj/item/clothing/under/misc/collar_shirt/white
	icon_state = "collar_shirt-white"
	item_state = "collar_shirt-white"
	shirt_colour_name = "white"

/obj/item/clothing/under/misc/collar_shirt/cream
	icon_state = "collar_shirt-cream"
	item_state = "collar_shirt-cream"
	shirt_colour_name = "cream"

/obj/item/clothing/under/misc/collar_shirt/khaki
	icon_state = "collar_shirt-khaki"
	item_state = "collar_shirt-khaki"
	shirt_colour_name = "khaki"

/obj/item/clothing/under/misc/collar_shirt/pink
	icon_state = "collar_shirt-pink"
	item_state = "collar_shirt-pink"
	shirt_colour_name = "pink"

/obj/item/clothing/under/misc/collar_shirt/red
	icon_state = "collar_shirt-red"
	item_state = "collar_shirt-red"
	shirt_colour_name = "red"

/obj/item/clothing/under/misc/collar_shirt/dark_red
	icon_state = "collar_shirt-dred"
	item_state = "collar_shirt-dred"
	shirt_colour_name = "dark red"

/obj/item/clothing/under/misc/collar_shirt/orange
	icon_state = "collar_shirt-orange"
	item_state = "collar_shirt-orange"
	shirt_colour_name = "orange"

/obj/item/clothing/under/misc/collar_shirt/brown
	icon_state = "collar_shirt-brown"
	item_state = "collar_shirt-brown"
	shirt_colour_name = "brown"

/obj/item/clothing/under/misc/collar_shirt/yellow
	icon_state = "collar_shirt-yellow"
	item_state = "collar_shirt-yellow"
	shirt_colour_name = "yellow"

/obj/item/clothing/under/misc/collar_shirt/green
	icon_state = "collar_shirt-green"
	item_state = "collar_shirt-green"
	shirt_colour_name = "green"

/obj/item/clothing/under/misc/collar_shirt/dark_green
	icon_state = "collar_shirt-dgreen"
	item_state = "collar_shirt-dgreen"
	shirt_colour_name = "dark green"

/obj/item/clothing/under/misc/collar_shirt/mint
	icon_state = "collar_shirt-mint"
	item_state = "collar_shirt-mint"
	shirt_colour_name = "mint"

/obj/item/clothing/under/misc/collar_shirt/blue
	icon_state = "collar_shirt-blue"
	item_state = "collar_shirt-blue"
	shirt_colour_name = "blue"

/obj/item/clothing/under/misc/collar_shirt/dark_blue
	icon_state = "collar_shirt-dblue"
	item_state = "collar_shirt-dblue"
	shirt_colour_name = "dark blue"

/obj/item/clothing/under/misc/collar_shirt/purple
	icon_state = "collar_shirt-purple"
	item_state = "collar_shirt-purple"
	shirt_colour_name = "purple"

/obj/item/clothing/under/misc/collar_shirt/black
	icon_state = "collar_shirt-black"
	item_state = "collar_shirt-black"
	shirt_colour_name = "black"

/obj/item/clothing/under/misc/fancy_vest
    name = "fancy vest"
    desc = "It's even got a real flower!"
    icon_state = "fancy_vest"
    item_state = "fancy_vest"

/obj/item/clothing/under/misc/flame_purple
    name = "purple flame shirt"
    desc = "Basic fire colors are so passé."
    icon_state = "flame_purple"
    item_state = "flame_purple"

/obj/item/clothing/under/misc/flame_rainbow
    name = "rainbow flame shirt"
    desc = "Monochromatic fire colors are so démodé."
    icon_state = "flame_rainbow"
    item_state = "flame_rainbow"

/obj/item/clothing/under/misc/bubble
    name = "bubble shirt"
    desc = "Soothing bubbles for a calm shirt."
    icon_state = "bubble"
    item_state = "bubble"

/obj/item/clothing/under/misc/tricolor
    name = "Tricolor Jumpsuit"
    desc = "A jumpsuit that shows your serious about pizza."
    icon_state = "tricolor"
    item_state = "tricolor"

// WALPVRGIS fashion

/obj/item/clothing/under/misc/casdressblk
    name = "Black Tshirt Dress"
    desc = "From the Spring/Summer 2053 collection. This one's for the goths."
    icon_state = "casdress_black"
    item_state = "casdress_black"

/obj/item/clothing/under/misc/casdressblu
    name = "Blue Tshirt Dress"
    desc = "From the Spring/Summer 2053 collection. Like the sky on Earth used to look like!"
    icon_state = "casdress_blue"
    item_state = "casdress_blue"

/obj/item/clothing/under/misc/casdressgrn
    name = "Green Tshirt Dress"
    desc = "From the Spring/Summer 2053 collection. Reminds you of summer."
    icon_state = "casdress_green"
    item_state = "casdress_green"

/obj/item/clothing/under/misc/casdresspnk
    name = "Pink Tshirt Dress"
    desc = "From the Spring/Summer 2053 collection. So neon, it almost hurts to look at."
    icon_state = "casdress_pink"
    item_state = "casdress_pink"

/obj/item/clothing/under/misc/casdresswht
    name = "White Tshirt Dress"
    desc = "From the Spring/Summer 2053 collection. A blank slate, or a minimal look."
    icon_state = "casdress_white"
    item_state = "casdress_white"

/obj/item/clothing/under/misc/casdressbolty
    name = "Bolt Tshirt Dress"
    desc = "Positively electric."
    icon_state = "casdress_bolty"
    item_state = "casdress_bolty"

/obj/item/clothing/under/misc/casdressboltp
    name = "Purple Bolt Tshirt Dress"
    desc = "Striking, just like lightning."
    icon_state = "casdress_boltp"
    item_state = "casdress_boltp"

/obj/item/clothing/under/misc/casdressleoy
    name = "Leopard Tshirt Dress"
    desc = "Leopard print is always in."
    icon_state = "casdress_leoy"
    item_state = "casdress_leoy"

/obj/item/clothing/under/misc/casdressleop
    name = "Pink Leopard Tshirt Dress"
    desc = "Pink leopard print is DEFINITELY always in."
    icon_state = "casdress_leop"
    item_state = "casdress_leop"

/obj/item/clothing/under/misc/sktdress_red
    name = "Red and Black Skirt Dress"
    desc = "Goes perfectly with your clipboard and radio headset!"
    icon_state = "sktdress_red"
    item_state = "sktdress_red"

/obj/item/clothing/under/misc/sktdress_purple
    name = "Purple and Black Skirt Dress"
    desc = "Goes perfectly with your clipboard and radio headset!"
    icon_state = "sktdress_purple"
    item_state = "sktdress_purple"

/obj/item/clothing/under/misc/sktdress_blue
    name = "Blue and Black Skirt Dress"
    desc = "Goes perfectly with your clipboard and radio headset!"
    icon_state = "sktdress_blue"
    item_state = "sktdress_blue"

/obj/item/clothing/under/misc/sktdress_gold
    name = "Gold and Black Skirt Dress"
    desc = "Goes perfectly with your clipboard and radio headset!"
    icon_state = "sktdress_gold"
    item_state = "sktdress_gold"

/obj/item/clothing/under/misc/sfjumpsuitbp
    name = "Black and Purple Sci-Fi Jumpsuit"
    desc = "Wear this to immediately become the ultimate hacker."
    icon_state = "scifi_jump_pb"
    item_state = "scifi_jump_pb"

/obj/item/clothing/under/misc/sfjumpsuitrb
    name = "Black and Red Sci-Fi Jumpsuit"
    desc = "Wear this to immediately become the ultimate hacker."
    icon_state = "scifi_jump_rb"
    item_state = "scifi_jump_rb"

/obj/item/clothing/under/misc/sfjumpsuitpnk
    name = "Pink and Blue Sci-Fi Jumpsuit"
    desc = "Wear this to immediately become the ultimate hacker."
    icon_state = "scifi_jump_pnk"
    item_state = "scifi_jump_pnk"

/obj/item/clothing/under/misc/sfjumpsuitbee
    name = "Bee Sci-Fi Jumpsuit"
    desc = "Wear this to immediately become the ultimate bee hacker."
    icon_state = "scifi_jump_yb"
    item_state = "scifi_jump_yb"

/obj/item/clothing/under/misc/casualjeanswb
    name = "White Shirt and Jeans"
    desc = "Look at those knee tears! You're too cool for school!"
    icon_state = "casual_jeans_wb"
    item_state = "casual_jeans_wb"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeansskr
    name = "Red Skull Shirt and Jeans"
    desc = "You're not evil, just misunderstood."
    icon_state = "casual_jeans_skullr"
    item_state = "casual_jeans_skullr"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeansskb
    name = "Black Skull Shirt and Jeans"
    desc = "You're not evil, just misunderstood."
    icon_state = "casual_jeans_skullb"
    item_state = "casual_jeans_skullb"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeansyel
    name = "Yellow Shirt and Jeans"
    desc = "For when you want to be both a ray of sunshine, and also grunge."
    icon_state = "casual_jeans_yshirt"
    item_state = "casual_jeans_yshirt"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeansacid
    name = "Skull Shirt and Acid Wash Jeans"
    desc = "It's 1993 and you're dressed to start your new grunge garage band."
    icon_state = "casual_jeans_skullbshort"
    item_state = "casual_jeans_skullbshort"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeansgrey
    name = "Grey Shirt and Jeans"
    desc = "Blend into the crowd while still looking cool."
    icon_state = "casual_jeans_grey"
    item_state = "casual_jeans_grey"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeanspurp
    name = "Purple Shirt and White Jeans"
    desc = "A E S T H E T I C."
    icon_state = "casual_jeans_purp"
    item_state = "casual_jeans_purp"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeansblue
    name = "Blue Shirt and Jeans"
    desc = "You patched up the tears in this pair of jeans because your knees got cold."
    icon_state = "casual_jeans_blue"
    item_state = "casual_jeans_blue"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeanskhaki
    name = "Khaki Shirt and Jeans"
    desc = "Perfect for adventuring."
    icon_state = "casual_jeans_khaki"
    item_state = "casual_jeans_khaki"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/racingsuitbee
    name = "Bee Racing Jumpsuit"
    desc = "Sting like a bee... Fly like a bee..."
    icon_state = "racing_jump_yb"
    item_state = "racing_jump_yb"

/obj/item/clothing/under/misc/racingsuitpnk
    name = "Pink and Blue Racing Jumpsuit"
    desc = "Just because you're inside a MiniPutt, doesn't mean you can't still be fashionable."
    icon_state = "racing_jump_pnk"
    item_state = "racing_jump_pnk"

/obj/item/clothing/under/misc/racingsuitrbw
    name = "Blue and White Racing Jumpsuit"
    desc = "You feel like you should wear this while piloting a robot, instead."
    icon_state = "racing_jump_rbw"
    item_state = "racing_jump_rbw"

/obj/item/clothing/under/misc/racingsuitprp
    name = "Purple and Black Racing Jumpsuit"
    desc = "Mysterious, just like you."
    icon_state = "racing_jump_prp"
    item_state = "racing_jump_prp"

//Western Jumpsuit
/obj/item/clothing/under/misc/western
    name = "Western Shirt and Pants"
    desc = "Now comes with a matching belt buckle and leather straps!"
    icon_state = "western"
    item_state = "western"

//Western Saloon Dress
/obj/item/clothing/under/misc/westerndress
	name = "Western Saloon Dress"
	desc = "Featuring a skirt over a skirt!"
	icon_state = "westerndress"
	item_state = "westerndress"

//Crate Loot
/obj/item/clothing/under/misc/tiedye
    name = "tiedye shirt"
    desc = "Featuring a pretty inky pattern."
    icon_state = "tiedye"
    item_state = "tiedye"

/obj/item/clothing/under/misc/neapolitan
    name = "neapolitan shirt"
    desc = "Like the icecream, not made in Naples."
    icon_state = "neapolitan"
    item_state = "neapolitan"

/obj/item/clothing/under/misc/mint_chip
    name = "mint chip shirt"
    desc = "A shirt imbued with the color scheme of the scientifically best icecream flavor."
    icon_state = "mint_chip"
    item_state = "mint_chip"

ABSTRACT_TYPE(/obj/item/clothing/under/misc/blouse_skirt)
/obj/item/clothing/under/misc/blouse_skirt
	name = "blouse and skirt"
	desc = "A space rayon blouse with a pencil skirt. Professional."
	icon_state = "blouse_skirt-white"
	item_state = "blouse_skirt-white"

/obj/item/clothing/under/misc/blouse_skirt/white
	name = "white blouse and skirt"
	icon_state = "blouse_skirt-white"
	item_state = "blouse_skirt-white"

/obj/item/clothing/under/misc/blouse_skirt/cream
	name = "cream blouse and skirt"
	icon_state = "blouse_skirt-cream"
	item_state = "blouse_skirt-cream"

/obj/item/clothing/under/misc/blouse_skirt/khaki
	name = "khaki blouse and skirt"
	icon_state = "blouse_skirt-khaki"
	item_state = "blouse_skirt-khaki"

/obj/item/clothing/under/misc/blouse_skirt/pink
	name = "pink blouse and skirt"
	icon_state = "blouse_skirt-pink"
	item_state = "blouse_skirt-pink"

/obj/item/clothing/under/misc/blouse_skirt/red
	name = "red blouse and skirt"
	icon_state = "blouse_skirt-red"
	item_state = "blouse_skirt-red"

/obj/item/clothing/under/misc/blouse_skirt/dark_red
	name = "dark red blouse and skirt"
	icon_state = "blouse_skirt-dred"
	item_state = "blouse_skirt-dred"

/obj/item/clothing/under/misc/blouse_skirt/orange
	name = "orange blouse and skirt"
	icon_state = "blouse_skirt-orange"
	item_state = "blouse_skirt-orange"

/obj/item/clothing/under/misc/blouse_skirt/brown
	name = "brown blouse and skirt"
	icon_state = "blouse_skirt-brown"
	item_state = "blouse_skirt-brown"

/obj/item/clothing/under/misc/blouse_skirt/yellow
	name = "yellow blouse and skirt"
	icon_state = "blouse_skirt-yellow"
	item_state = "blouse_skirt-yellow"

/obj/item/clothing/under/misc/blouse_skirt/green
	name = "green blouse and skirt"
	icon_state = "blouse_skirt-green"
	item_state = "blouse_skirt-green"

/obj/item/clothing/under/misc/blouse_skirt/dark_green
	name = "dark green blouse and skirt"
	icon_state = "blouse_skirt-dgreen"
	item_state = "blouse_skirt-dgreen"

/obj/item/clothing/under/misc/blouse_skirt/mint
	name = "mint blouse and skirt"
	icon_state = "blouse_skirt-mint"
	item_state = "blouse_skirt-mint"

/obj/item/clothing/under/misc/blouse_skirt/blue
	name = "blue blouse and skirt"
	icon_state = "blouse_skirt-blue"
	item_state = "blouse_skirt-blue"

/obj/item/clothing/under/misc/blouse_skirt/dark_blue
	name = "navy blue blouse and skirt"
	icon_state = "blouse_skirt-dblue"
	item_state = "blouse_skirt-dblue"

/obj/item/clothing/under/misc/blouse_skirt/purple
	name = "purple blouse and skirt"
	icon_state = "blouse_skirt-purple"
	item_state = "blouse_skirt-purple"

/obj/item/clothing/under/misc/blouse_skirt/black
	name = "black blouse and skirt"
	icon_state = "blouse_skirt-black"
	item_state = "blouse_skirt-black"
//Seasonal Stuff

/obj/item/clothing/under/gimmick/clown_autumn
	name = "autumn clown suit"
	desc = "Lets you celebrate the season while still remaining autumnomous."
	icon_state = "clown_autumn"
	item_state = "clown_autumn"

/obj/item/clothing/under/gimmick/clown_winter
	name = "winter clown suit"
	desc = "Lets you stay nice and warm while keeping that festive atmosphere. Actually kinda breezy, not very comfortable for the cold at all, but it still looks festive."
	icon_state = "clown_winter"
	item_state = "clown_winter"

// New chaplain stuff

/obj/item/clothing/under/gimmick/weirdo
	name = "outlander's jumpsuit"
	desc = "The symbols on this teal jumpsuit are entirely alien to you. It almost speaks to you of an ancient belief lost to time"
	icon_state = "weirdo"
	item_state = "weirdo"
