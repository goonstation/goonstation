// Knitting tools

/obj/item/storage/box/knitting
	name = "\improper Knitting Supplies"
	spawn_contents = list(/obj/item/scissors/surgical_scissors/shears,/obj/item/knitting_needles,/obj/item/drop_spindle)

/obj/item/scissors/surgical_scissors/shears
	name = "shears"
	desc = "Shears for shearing sheep."

/obj/item/knitting_needles
	icon = 'icons/obj/ranch/spindle.dmi'
	icon_state = "needles"
	name = "knitting needles"
	desc = "A pair of nice knitting needles for knitting wool into something you can adorn clothes with."
	force = 5.0
	w_class = W_CLASS_TINY
	throwforce = 2.0
	throw_speed = 3
	throw_range = 5
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	stamina_damage = 5
	stamina_cost = 10
	stamina_crit_chance = 15
	var/crochet = FALSE

	get_desc(dist, mob/user)
		if (dist <= 1 && crochet)
			. += "There's a small notch cut into one of the needles making it useful for crochet."

	attackby(obj/item/W, mob/user)
		if (istool(W, TOOL_CUTTING | TOOL_SAWING) && !src.crochet)
			user.visible_message(SPAN_NOTICE("[user] makes a little notch in [src] with [W]."),SPAN_NOTICE("You manage to make one of the needles into a hook!"))
			crochet = TRUE
		else
			. = ..()

/obj/item/drop_spindle
	icon = 'icons/obj/ranch/spindle.dmi'
	icon_state = "spindle"
	name = "drop spindle"
	desc = "A handmade drop spindle for spinning wool into yarn."
	force = 2.0
	w_class = W_CLASS_TINY
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	stamina_damage = 5
	stamina_cost = 10
	stamina_crit_chance = 15

/obj/item/material_piece/cloth/wool
	name = "wool"
	desc = "Some wool."
	icon = 'icons/obj/ranch/yarn_and_wool.dmi'
	icon_state = "wool-white"
	mat_changename = FALSE
	mat_changeappearance = FALSE
	var/ball_icon_state = null
	var/roll_icon_state = null
	var/ball = FALSE
	var/knitting_path = null
	var/list/datum/contextAction/knits

	New()
		. = ..()
		create_reagents(10)

		var/datum/contextLayout/experimentalcircle/context_menu = new
		contextLayout = context_menu
		knits = list()
		for(var/actionType in concrete_typesof(/datum/contextAction/knit))
			var/datum/contextAction/knit = new actionType(src)
			knits += knit

	setup_material()
		..()

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/drop_spindle))
			if(ball)
				boutput(user, SPAN_ALERT("You can't spin it any more than it already is!"))
			else
				var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(user, src, 2 SECONDS,\
				/obj/item/material_piece/cloth/wool/proc/spin, list(user), W.icon, "spindle-threaded", null)
				playsound(src.loc, 'sound/items/Scissor.ogg', 50, 1)
				src.visible_message(SPAN_NOTICE("[user] begins to spin [src] into yarn."), SPAN_NOTICE("You begin to spin [src] into yarn."))
				actions.start(action_bar, user)
			return
		else if(istype(W,/obj/item/knitting_needles))
			if(!ball)
				boutput(user, SPAN_ALERT("You need to spin the wool before you can knit it!"))
			else
				if(!length(src.knits))
					var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(user, src, 2 SECONDS,\
					/obj/item/material_piece/cloth/wool/proc/knit,list(user, null, 1), W.icon, W.icon_state, null)
					playsound(src.loc, 'sound/items/Scissor.ogg', 50, 1)
					src.visible_message(SPAN_NOTICE("[user] begins to knit [src]."), SPAN_NOTICE("You begin to knit [src]."))
					actions.start(action_bar, user)
				else
					var/list/contexts = list()
					for(var/datum/contextAction/C as anything in src.knits)
						if(C.checkRequirements(src, user))
							contexts += C
					if(length(contexts))
						user.showContextActions(contexts, src)
			return
		else if (istype(W,/obj/item/material_piece/cloth/wool))
			var/obj/item/material_piece/cloth/wool/O = W
			if(O.ball != src.ball)
				boutput(user, SPAN_ALERT("You can't combine spun and unspun wool!"))
				return
			else if (!O.material?.isSameMaterial(src.material))
				boutput(user, SPAN_ALERT("You can't combine two different kinds of wool!"))
				return
		. = ..()

	check_valid_stack(atom/movable/O)
		. = ..()
		if(istype(O,/obj/item/material_piece/cloth/wool))
			var/obj/item/material_piece/cloth/wool/W = O
			if(W.ball != src.ball)
				boutput(usr, SPAN_ALERT("You can't combine spun and unspun wool!"))
				. = 0
		if(src.color != O.color)
			boutput(usr, SPAN_ALERT("You can't combine different colors of wool!"))
			. = 0
		if (!O.material?.isSameMaterial(src.material))
			boutput(usr, SPAN_ALERT("You can't combine two different kinds of wool!"))
			. = 0

	split_stack(var/toRemove)
		. = ..()
		if(.)
			var/obj/item/material_piece/cloth/wool/split = .
			split.ball = src.ball
			split.color = src.color
			split.UpdateStackAppearance()

	_update_stack_appearance()
		. = ..()
		if(src.ball)
			if( src.amount <= 3 )
				icon_state = ball_icon_state
				desc = "A ball of yarn"
			else
				icon_state = roll_icon_state
				desc = "A skein of yarn"

	proc/spin(var/mob/M)
		if(amount > 1)
			var/obj/item/material_piece/cloth/wool/W = src.split_stack(1)
			W.spin(M)
			return
		name = "yarn"
		ball = TRUE
		UpdateStackAppearance()
		M.visible_message(SPAN_NOTICE("[M] spins [src] into yarn."), SPAN_NOTICE("You spin [src] into yarn."))
		M.u_equip(src)
		M.put_in_hand_or_drop(src)

	proc/knit(var/mob/M, var/datum/contextAction/knit/K)
		if(amount < K.cost)
			return
		if(amount > K.cost)
			var/obj/item/material_piece/cloth/wool/W = src.split_stack(K.cost)
			W.knit(M, K)
			return

		M.u_equip(src)
		src.set_loc(get_turf(M))
		var/obj/item/property_setter/knitting = new knitting_path
		knitting.color = src.color
		var/obj/item/knitting_project = K.create_knit(knitting)
		M.put_in_hand_or_drop(knitting_project)
		qdel(src)

	setMaterialAppearance()
		var/old_color = src.color
		. = ..()
		if(old_color)
			src.color = old_color

	update_icon()
		if (reagents.total_volume)
			var/datum/color/average = reagents.get_average_color()
			var/list/hsl = rgb2hsl(average.r,average.g,average.b)
			var/new_color = hsl2rgb(hsl[1], clamp(hsl[2],20,75), clamp(hsl[3], 20, 90))
			src.color = new_color

	on_reagent_change(var/add)
		..()
		if(add > 0)
			src.UpdateIcon()
			reagents.remove_any(src.reagents.total_volume-1)

/obj/item/material_piece/cloth/wool/white
	icon_state = "wool-white"
	ball_icon_state = "yarn-ball-white"
	roll_icon_state = "yarn-roll-white"
	knitting_path = /obj/item/property_setter/wool/white
	setup_material()
		src.setMaterial(getMaterial("wool-white"), appearance = 0, setname = 0)
		..()


ABSTRACT_TYPE(/datum/material/fabric/cloth)

ABSTRACT_TYPE(/datum/material/fabric/cloth/wool) //hi emily it's yass here making this pass unit tests by making it abstract
/datum/material/fabric/cloth/wool
	name = "temp"

/datum/material/fabric/cloth/wool/white
	mat_id = "wool-white"
	name = "wool"
	desc = "Wool of adorable fluffy space sheep."
	color = "#E9E5E5"
	material_flags = MATERIAL_CLOTH

	New()
		setProperty("hard", 1)
		setProperty("density", 2)
		setProperty("flammable", 6)
		setProperty("electrical", 3)
		setProperty("thermal", 7)
		return ..()

/obj/item/property_setter/wool
	name = "YOU SHOULDN'T SEE ME"
	desc = "YOU SHOULDN'T SEE ME. You feel confident in that you could apply this to a piece of clothing to make it more resistant to outside force."
	prefix_to_set = "wool reinforced"
	icon = 'icons/obj/ranch/yarn_and_wool.dmi'

	attackby(obj/item/W, mob/user, params)
		if(istype(W,/obj/item/knitting_needles))
			boutput(user, SPAN_ALERT("It's already as knitted as it can be!"))
		else
			. = ..()

/obj/item/property_setter/wool/white
	name = "wool knitting"
	desc = "Some strong wool knitting made from the wool of a space sheep. Can be applied to clothing to reinforce it against blunt force."
	icon_state = "knit-white"
	prefix_to_set = "wool reinforced"
	color_to_set = "#E9E5E5"

	New()
		. = ..()
		properties_to_set = list(new /datum/property_setter_property(incrementative = 1, cap = 2, property_name = "meleeprot", property_value = 1),
		new /datum/property_setter_property(incrementative = 1, cap = 0.2, property_name = "rangedprot", property_value = 0.1))

/datum/contextAction/knit
	icon = 'icons/ui/context16x16.dmi'
	var/knitting_project = null
	var/cost = INFINITY
	var/duration = 2 SECONDS

	checkRequirements(atom/target, mob/user)
		if(!can_act(user) || !in_interact_range(target, user))
			return FALSE
		var/obj/item/material_piece/cloth/wool/W = target
		if(istype(W) && W.amount >= cost)
			. = TRUE

	execute(atom/target, mob/user)
		. = ..()
		var/obj/item/material_piece/cloth/wool/W = target
		if(istype(W) && W.amount >= cost)
			var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(user, target, src.duration,\
			/obj/item/material_piece/cloth/wool/proc/knit,list(user, src), 'icons/obj/ranch/spindle.dmi', "knitting", null)
			playsound(target.loc, 'sound/items/Scissor.ogg', 50, 1)
			target.visible_message(SPAN_NOTICE("[user] begins to knit [target]."), SPAN_NOTICE("You begin to knit [target]."))
			actions.start(action_bar, user)

	proc/create_knit(obj/item/property_setter/knitting)
		var/obj/item/new_knit = new src.knitting_project
		knitting.apply_property(knitting_project)
		new_knit.color = knitting.color
		return new_knit

ABSTRACT_TYPE(/datum/contextAction/knit/amigurumi)
/datum/contextAction/knit/amigurumi
	checkRequirements(atom/target, mob/user)
		if(!can_act(user) || !in_interact_range(target, user))
			return FALSE
		var/obj/item/knitting_needles/crochet_hook = user.equipped()
		if(!istype(crochet_hook) || !crochet_hook.crochet)
			return FALSE
		. = ..()

	create_knit(obj/item/property_setter/knitting)
		. = ..()
		var/obj/item/toy/plush/amigurumi = .
		if(istype(., /obj/item/toy/plush))
			amigurumi.amigurumi()

/datum/contextAction/knit/patch
	name = "wool knitting"
	icon_state = "knit_square"
	knitting_project = null
	cost = 1

	create_knit(obj/item/property_setter/knitting)
		if(knitting.color)
			knitting.color_to_set = knitting.color
		. = knitting

/datum/contextAction/knit/scarf
	name = "wool scarf"
	duration = 10 SECONDS
	icon_state = "knit_scarf"
	cost = 3
	knitting_project = /obj/item/clothing/suit/scarf/cozy

/obj/item/clothing/suit/scarf/cozy
	name = "scarf"

/datum/contextAction/knit/big_scarf
	name = "long wool scarf"
	duration = 20 SECONDS
	icon_state = "knit_big_scarf"
	cost = 5
	knitting_project = /obj/item/clothing/suit/scarf/long

/obj/item/clothing/suit/scarf/long
	name = "long scarf"

/datum/contextAction/knit/sweatercozy
	name = "cozy knit sweater"
	duration = 30 SECONDS
	icon_state = "sweatercozy"
	cost = 10
	knitting_project = /obj/item/clothing/suit/knitsweater

/datum/contextAction/knit/sweaterbubble
	name = "bubble-knit sweater"
	duration = 30 SECONDS
	icon_state = "sweaterbubble"
	cost = 10
	knitting_project = /obj/item/clothing/suit/knitsweater/bubble

/datum/contextAction/knit/sweatercable
	name = "cable-knit sweater"
	duration = 30 SECONDS
	icon_state = "sweatercable"
	cost = 10
	knitting_project = /obj/item/clothing/suit/knitsweater/cable

/datum/contextAction/knit/cardigan
	name = "cardigan sweater"
	duration = 30 SECONDS
	icon_state = "cardigan"
	cost = 10
	knitting_project = /obj/item/clothing/suit/knitsweater/cardigan

/datum/contextAction/knit/amigurumi/bee
	name = "amigurumi bee"
	duration = 8 SECONDS
	icon_state = "knit_bee"
	cost = 2
	knitting_project = /obj/item/toy/plush/small/bee

/datum/contextAction/knit/amigurumi/buddy
	name = "amigurumi buddy"
	duration = 10 SECONDS
	icon_state = "knit_buddy"
	cost = 3
	knitting_project = /obj/item/toy/plush/small/buddy

/datum/contextAction/knit/amigurumi/monkey
	name = "amigurumi monkey"
	duration = 12 SECONDS
	icon_state = "knit_monkey"
	cost = 3
	knitting_project = /obj/item/toy/plush/small/monkey

/obj/item/toy/plush/proc/amigurumi(var/new_color)
	var/add_orig = 0.0
	var/color_intensity = 0.6

	if(!new_color)
		new_color = src.color
	if(!new_color)
		new_color = "#ffffff"

	var/list/color_list = hex_to_rgb_list(new_color)

	var/adjusted_color = list(
		1 - color_intensity + add_orig, 0, 0,
		0, 1 - color_intensity + add_orig, 0,
		0, 0, 1 - color_intensity + add_orig,
		color_intensity * color_list[1]/255, color_intensity * color_list[2]/255, color_intensity * color_list[3]/255)
	adjusted_color = normalize_color_to_matrix(adjusted_color)

	src.color = mult_color_matrix(COLOR_MATRIX_GRAYSCALE, adjusted_color)
	setTexture("knit", BLEND_MULTIPLY, "knit")
