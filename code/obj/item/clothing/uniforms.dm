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
	var/hide_underwear = FALSE
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

	equipped(mob/user, slot)
		. = ..()
		if(src.hide_underwear)
			user.update_body()

	unequipped(mob/user)
		. = ..()
		if(src.hide_underwear)
			SPAWN(0) //uniform still counts as worn as unequipped() is called
			user.update_body()

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
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the vincian pride flag, but can be flipped inside-out to change it to the achillean one."
		icon_state ="mlm"
		item_state = "mlm"
		var/isachily = FALSE
		var/ach_descstate = "A corporate token of inclusivity, made in a sweatshop. It's based off of the achillean pride flag, but can be flipped inside-out to change it to the vincian one."
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

/obj/item/clothing/under/misc/clown
	name = "clown suit"
	desc = "You are likely taking your life into your own hands by wearing this."
	icon_state = "clown"
	item_state = "clown"

	New()
		..()
		AddComponent(/datum/component/clown_disbelief_item)

/obj/item/clothing/under/misc/mimefancy
	name = "fancy mime suit"
	desc = "A suit perfect for more sophisticated mimes. Wait... This isn't just a bleached clown suit, is it?"
	icon_state = "mime-fancy"
	item_state = "mime-fancy"

/obj/item/clothing/under/misc/mimedress
	name = "mime dress"
	desc = "You may be trapped in an invisible box forever and ever, but at least you look stylish!"
	icon_state = "mime-dress"
	item_state = "mime-dress"

/obj/item/clothing/under/misc/lawyer/red/demonic
	item_function_flags = IMMUNE_TO_ACID
	setupProperties()
		..()
		setProperty("coldprot", 40) //slightly worse than a spacesuit
		setProperty("heatprot", 40) //slightly worse than a firesuit
		setProperty("rangedprot", 1.5) //buffed from 1, felt needed, tune up or down as needed
		setProperty("meleeprot", 7) //buffed from 6, felt needed, tune up or down as needed

// Athletic Gear

TYPEINFO(/obj/item/clothing/under/shorts)
	random_subtypes = list(/obj/item/clothing/under/shorts,
		/obj/item/clothing/under/shorts/red,
		/obj/item/clothing/under/shorts/green,
		/obj/item/clothing/under/shorts/blue,
		/obj/item/clothing/under/shorts/purple,
		/obj/item/clothing/under/shorts/black)

/obj/item/clothing/under/shorts/psyche
	name = "psychedelic shorts"
	desc = "Only wear these if you don't mind being the center of attention."
	icon_state = "shortsPs"
	item_state = "shortsPs"

/obj/item/clothing/under/swimsuit
	name = "white swimsuit"
	desc = "This piece of clothing is good for when you want to be in the water, but not wearing your normal clothes, but also not naked."
	icon = 'icons/obj/clothing/uniforms/item_js_athletic.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_athletic.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_athletic.dmi'
	icon_state = "fswimW"
	item_state = "fswimW"
	hide_underwear = TRUE

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

// Towels

TYPEINFO(/obj/item/clothing/under/towel)
	mat_appearances_to_ignore = list("cotton")
/obj/item/clothing/under/towel
	name = "towel"
	desc = "Made of nice, soft terrycloth. Very important when adventuring."
	icon = 'icons/obj/clothing/jumpsuits/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuits/hand_js_gimmick.dmi'
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
	icon = 'icons/obj/clothing/jumpsuits/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuits/hand_js_gimmick.dmi'
	icon_state = "sailor"
	item_state = "sailor"

/obj/item/clothing/under/gimmick/sailor
	name = "sailor uniform"
	desc = "What's with these guys?! It's like one of my Japanese animes!"
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

/obj/item/clothing/under/gimmick/jester
    name = "jester's outfit"
    desc = "Outfit of a not-so-funny clown."
    icon_state = "jester"
    item_state = "jester"

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
	hide_underwear = TRUE

//Swimsuits, by RubberRats
//Please don't wear a bikini as a work uniform on the RP servers, it would make me very unhappy.
ABSTRACT_TYPE(/obj/item/clothing/under/misc/bikini)
/obj/item/clothing/under/misc/bikini
	name = "bikini"
	icon_state = "bikini_w"
	item_state = "bikini_w"
	desc = "A stylish two-piece swimsuit. Well suited for a day at the beach, less so the cold depths of space."
	hide_underwear = TRUE

	white
		name = "white bikini"
		icon_state = "bikini_w"
		item_state = "bikini_w"

	yellow
		name = "yellow bikini"
		icon_state = "bikini_y"
		item_state = "bikini_y"

	red
		name = "red bikini"
		icon_state = "bikini_r"
		item_state = "bikini_r"

	blue
		name = "blue bikini"
		icon_state = "bikini_u"
		item_state = "bikini_u"

	pink
		name = "pink bikini"
		icon_state = "bikini_p"
		item_state = "bikini_p"

	black
		name = "black bikini"
		icon_state = "bikini_b"
		item_state = "bikini_b"

	pdot_red
		name = "red polka-dot bikini"
		icon_state = "bikini_pdotr"
		item_state = "bikini_pdotr"

	pdot_yellow
		name = "yellow polka-dot bikini"
		icon_state = "bikini_pdoty"
		item_state = "bikini_pdoty"
		desc = "An itsy-bisty, teeny-weeny swimsuit. What's it doing out here in space?"

	strawberry
		name = "strawberry bikini"
		icon_state = "bikini_strawb"
		item_state = "bikini_strawb"

	bee
		name = "beekini"
		icon_state = "beekini"
		item_state = "beekini"
		desc = "A stylish two-piece swimsuit. It even has little wings! Aww."

ABSTRACT_TYPE(/obj/item/clothing/under/misc/onepiece)
/obj/item/clothing/under/misc/onepiece
	name = "white one-piece swimsuit"
	icon_state = "onepiece_w"
	item_state = "onepiece_w"
	desc = "A fashionable swimsuit. Well-suited for a day at the beach, less so the cold depths of space."
	hide_underwear = TRUE

	white
		name = "white one-piece swimsuit"
		icon_state = "onepiece_w"
		item_state = "onepiece_w"

	red
		name = "red one-piece swimsuit"
		icon_state = "onepiece_r"
		item_state = "onepiece_r"

	orange
		name = "orange one-piece swimsuit"
		icon_state = "onepiece_o"
		item_state = "onepiece_o"

	yellow
		name = "yellow one-piece swimsuit"
		icon_state = "onepiece_y"
		item_state = "onepiece_y"

	green
		name = "green one-piece swimsuit"
		icon_state = "onepiece_g"
		item_state = "onepiece_g"

	blue
		name = "blue one-piece swimsuit"
		icon_state = "onepiece_u"
		item_state = "onepiece_u"

	purple
		name = "purple one-piece swimsuit"
		icon_state = "onepiece_p"
		item_state = "onepiece_p"

	black
		name = "black one-piece swimsuit"
		icon_state = "onepiece_b"
		item_state = "onepiece_b"

ABSTRACT_TYPE(/obj/item/clothing/under/misc/frillyswimsuit)
/obj/item/clothing/under/misc/frillyswimsuit
	name = "frilly swimsuit"
	icon_state = "frillyswimsuit_w"
	item_state = "frillyswimsuit_w"
	desc = "A playful swimsuit with a ruffled top. How did it get all the way out here?"
	hide_underwear = TRUE

	white
		name = "frilly white swimsuit"
		icon_state = "frillyswimsuit_w"
		item_state = "frillyswimsuit_w"


	yellow
		name = "frilly yellow swimsuit"
		icon_state = "frillyswimsuit_y"
		item_state = "frillyswimsuit_y"

	blue
		name = "frilly blue swimsuit"
		icon_state = "frillyswimsuit_u"
		item_state = "frillyswimsuit_u"

	pink
		name = "frilly pink swimsuit"
		icon_state = "frillyswimsuit_p"
		item_state = "frillyswimsuit_p"

	bubblegum
		name = "frilly bubblegum swimsuit"
		icon_state = "frillyswimsuit_pu"
		item_state = "frillyswimsuit_pu"

	circus
		name = "frilly circus swimsuit"
		icon_state = "frillyswimsuit_circus"
		item_state = "frillyswimsuit_circus"
		desc = "A playful swimsuit with a ruffled top. This one has an alarming polka-dot pattern."

ABSTRACT_TYPE(/obj/item/clothing/under/misc/swimtrunks)
/obj/item/clothing/under/misc/swimtrunks
	name = "swim trunks"
	icon_state = "swimtrunks_w"
	item_state = "swimtrunks_w"
	desc = "A pair of swim trunks. Well-suited for a day at the beach, less so the cold depths of space."

	white
		name = "white swim trunks"
		icon_state = "swimtrunks_w"
		item_state = "swimtrunks_w"

	red
		name = "red swim trunks"
		icon_state = "swimtrunks_r"
		item_state = "swimtrunks_r"

	orange
		name = "orange swim trunks"
		icon_state = "swimtrunks_o"
		item_state = "swimtrunks_o"

	green
		name = "green swim trunks"
		icon_state = "swimtrunks_g"
		item_state = "swimtrunks_g"

	blue
		name = "blue swim trunks"
		icon_state = "swimtrunks_u"
		item_state = "swimtrunks_u"

	black
		name = "black swim trunks"
		icon_state = "swimtrunks_b"
		item_state = "swimtrunks_b"

	circus
		name = "circus swim trunks"
		icon_state = "swimtrunks_circus"
		item_state = "swimtrunks_circus"
		desc = "A pair of swim trunks. This one has an alarming polka-dot pattern."

/obj/item/clothing/under/misc/wetsuit
	name = "wetsuit"
	icon_state = "wetsuit"
	item_state = "wetsuit"
	desc = "A skin-tight, flexible suit meant to keep divers warm underwater. Unfortunately, the material on this one is too thin to provide any real protection."

	red
		name = "red wetsuit"
		icon_state = "wetsuit_r"
		item_state = "wetsuit_r"

	orange
		name = "orange wetsuit"
		icon_state = "wetsuit_o"
		item_state = "wetsuit_o"

	yellow
		name = "yellow wetsuit"
		icon_state = "wetsuit_y"
		item_state = "wetsuit_y"

	purple
		name = "purple wetsuit"
		icon_state = "wetsuit_pu"
		item_state = "wetsuit_pu"

	cyan
		name = "cyan wetsuit"
		icon_state = "wetsuit_u"
		item_state = "wetsuit_u"

	pink
		name = "pink wetsuit"
		icon_state = "wetsuit_p"
		item_state = "wetsuit_p"

ABSTRACT_TYPE(/obj/item/clothing/under/misc/oldswimsuit)
/obj/item/clothing/under/misc/oldswimsuit
	name = "old-timey swimsuit"
	icon_state = "oldswimsuit_rw"
	item_state = "oldswimsuit_rw"
	desc = "A mildly tacky bathing suit in a style nearly 200 years old. Can't fault the classics."

	red
		icon_state = "oldswimsuit_rw"
		item_state = "oldswimsuit_rw"

	blue
		icon_state = "oldswimsuit_uw"
		item_state = "oldswimsuit_uw"

	black
		icon_state = "oldswimsuit_bw"
		item_state = "oldswimsuit_bw"

	bee
		icon_state = "oldswimsuit_by"
		item_state = "oldswimsuit_by"

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
