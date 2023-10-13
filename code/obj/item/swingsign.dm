//1. /obj/swingsign
//	Inherited procs
//	tgui procs
//	procs
//2. /obj/item/swingsignfolded

TYPEINFO(/obj/swingsign)//No idea what TYPEINFO is, I just know it lets me disable the brown overcoat when crafting signs
	mat_appearances_to_ignore = list("wood")
/obj/swingsign
	name = "swing sign"
	desc = "A foldable sign for writing annoucements or advertisements."
	icon = 'icons/obj/furniture/swingsign.dmi'
	icon_state = "blank"
	throwforce = 10
	density = 1
	custom_suicide = TRUE
	/// Stored message
	var/message = ""
	var/defaultdesc = "A foldable sign for writing annoucements or advertisements."
	/// Text inserted before the actual message
	var/descpreamble = "It says:<br><div style='text-align:center'>"// There's a /div in SetMessage. If changing the preamble remember to respect it.
	/// Damage when thrown into a swing sign
	var/maxcrashdamage = 5
	/// Max length of the message
	var/maxmessagerows = 10
	/// Max width of the message
	var/maxmessagecols = 40
	/// Regex that detects '\n' signs
	//var/static/regex/fixBreaklinesRegex = new(@{"/\n/"}, "g")
	/// Regex that detects '<br>' tags
	//var/static/regex/fixBreaklinesRegex = new(@{"<br>"}, "g")

	New()
		..()
		//if(message)
		//	setmessage(message)
		//src.AddComponent(/datum/component/foldable, /obj/item/swingsignfolded)

	proc/setmessage(var/newmessage)
		message = newmessage
		if(message == "")
			desc = defaultdesc
		else
			desc = descpreamble + message + "</div>"
		UpdateIcon()

	update_icon(...)
		if(message == "")
			icon_state = "blank"
		else
			icon_state = "written"

	proc/fold()
		var/obj/item/swingsignfolded/newSwingsign = new/obj/item/swingsignfolded(src.loc)

		if (src.material)
			newSwingsign.setMaterial(src.material)
		//if (src.icon_state)
		//	newSwingsign.icon_state = "folded"
		if (src.message)
			newSwingsign.message = src.message

		qdel(src)

	attack_hand(mob/user)
		if (!isliving(user)) return
		if(anchored == UNANCHORED)
			user.visible_message("<b>[user.name] folds [src].</b>")
			playsound(src, 'sound/impact_sounds/Clock_slap.ogg',50,1)
			fold()//
		else
			boutput(user, "<span alert='notice'>Sign is too tightly secured to fold!</span>")
		return

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/pen))
			ui_interact(user)
			return
		else if (isscrewingtool(W))
			if(anchored == ANCHORED)
				boutput(user, "<span class='notice'>You unsecure the swing sign.</span>")
				anchored = UNANCHORED
			else
				boutput(user, "<span class='notice'>You secure the swing sign.</span>")
				anchored = ANCHORED
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			return
		..()

	hitby(atom/movable/M, datum/thrown_thing/thr)
		if (isliving(M) && M.throwing)
			var/mob/living/L = M
			var/area/T = get_area(src)
			if(T?.sanctuary)
				return
			random_brute_damage(M, rand(1,maxcrashdamage),1)
			L.do_disorient(10, 0, 1 SECOND, 0, disorient = 0, stack_stuns = FALSE)
			L.force_laydown_standup()
			//L.changeStatus("stunned", 1 SECONDS)
			src.visible_message("<b><font color=red>[M] is people-stopped by [src]!</font></b>")
			playsound(src, 'sound/impact_sounds/Wood_Hit_1.ogg',50,1)
			fold() //Change to item
			return
		..()


	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] puts [his_or_her(user)] head between [src]'s legs and clamps them shut!</b></span>")
		user.TakeDamage("head", 250, 0)
		playsound(src, 'sound/items/woodbat.ogg',50,1)
		fold()
		return 1


/obj/swingsign/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SwingSign")
		ui.open()

/obj/swingsign/ui_data(mob/user)
	. = list(
		"message" = newline_html_decode(src.message),//Decodes the message for the UI component and replaces all <br> with \n (text.dm)
		"maxRows" = src.maxmessagerows,
		"maxCols" = src.maxmessagecols
	)

/obj/swingsign/ui_act(action, params)
	. = ..()
	if (.)
		return
	if(action == "save_message")
		var/new_message = params["message"]
		if(length(new_message)>(src.maxmessagerows * src.maxmessagecols) + src.maxmessagerows - 1)//src.maxmessagerows - 1 - max possible amount of \n signs
			new_message = copytext(new_message, 1, ((src.maxmessagerows) * src.maxmessagecols) + src.maxmessagerows)
		setmessage(newline_html_encode(new_message))//Encodes the message for safety and replaces all \n with <br> (text.dm)
		. = TRUE
		UpdateIcon()


//Heldable folded sign ==============
TYPEINFO(/obj/item/swingsignfolded)
	mat_appearances_to_ignore = list("wood")
/obj/item/swingsignfolded
	name = "swing sign"
	desc = "A foldable sign for writing annoucements and advertisements"
	icon = 'icons/obj/furniture/swingsign.dmi'
	icon_state = "folded"
	inhand_image_icon = 'icons/obj/furniture/swingsign.dmi'
	item_state = "folded_held"
	w_class = W_CLASS_BULKY
	throwforce = 10
	flags = FPRINT | TABLEPASS
	force = 5
	stamina_damage = 45
	stamina_cost = 21
	stamina_crit_chance = 10
	material_amt = 0.1
	hitsound = 'sound/impact_sounds/folding_chair.ogg'

	/// Stored message for the deployed object
	var/message = ""

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_LARGE)

	///*
	attack_self(mob/user as mob)
		if(cant_drop == 1)
			boutput(user, "You can't unfold the [src] when its attached to your arm!")
			return
		var/obj/swingsign/newSwingsign = null
		newSwingsign = new/obj/swingsign/(user.loc)

		if (src.material)
			newSwingsign.setMaterial(src.material)
		if (src.message)
			newSwingsign.setmessage(src.message)//Pass the message onto the object. Calling swingsign.message directly won't update the desc.

		boutput(user, "You unfold the [newSwingsign].")

		playsound(user, 'sound/impact_sounds/Clock_slap.ogg',50,1)
		user.drop_item()
		qdel(src)
		return
	//*/
	/// Basically copied this from stool.dm /obj/item/chair/folded/attack
	attack(atom/target as mob, mob/user as mob, params)
		var/oldcrit = src.stamina_crit_chance
		if(iswrestler(user))
			src.stamina_crit_chance = 100
		..()
		src.stamina_crit_chance = oldcrit
