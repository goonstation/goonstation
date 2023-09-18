/* 	/		/		/		/		/		/		Setup		/		/		/		/		/		/		/		/		*/

/mob/proc/make_merchant()
	if (ishuman(src))
		var/datum/abilityHolder/merchant/existing_holder = src.get_ability_holder(/datum/abilityHolder/merchant)
		if (istype(existing_holder))
			return
		var/datum/abilityHolder/merchant/AH = src.add_ability_holder(/datum/abilityHolder/merchant)
		AH.addAbility(/datum/targetable/merchant/summon_contract)
		if (src.mind)
			if (!isdiabolical(src))
				src.mind.diabolical = TRUE

/* 	/		/		/		/		/		/		Ability Holder		/		/		/		/		/		/		/		/		*/
/datum/abilityHolder/merchant
	tabName = "Souls"
	notEnoughPointsMessage = "<span class='alert'>You need more souls to use this ability!</span>"

	onAbilityStat() // In the "Souls" tab.
		..()
		. = list()
		.["Souls:"] = total_souls_value
		.["Total Collected:"] = total_souls_sold

/////////////////////////////////////////////// Merchant spell parent ////////////////////////////

/datum/targetable/merchant
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "template"
	preferred_holder_type = /datum/abilityHolder/merchant
	incapacitation_restriction =  ABILITY_CAN_USE_WHEN_STUNNED

	castcheck(atom/target)
		. = ..()
		var/mob/living/M = holder.owner

		if (!(isdiabolical(M)))
			boutput(M, "<span class='alert'>You aren't evil enough to use this power!</span>")
			return FALSE

		if (!(total_souls_value >= CONTRACT_COST))
			boutput(M, "<span class='alert'>You don't have enough souls in your satanic bank account to buy another contract!</span>")
			boutput(M, "<span class='alert'>You need [CONTRACT_COST - total_souls_value] more to afford a contract!</span>")
			return FALSE

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return

/////////////////////////////////////////////// Contract Summoning Spell ////////////////////////////

/datum/targetable/merchant/summon_contract
	icon_state = "clairvoyance"
	name = "Summon Contract"
	desc = "Spend PLACEHOLDER (you shouldn't see this) souls to summon a random new contract to your location"
	pointCost = CONTRACT_COST

	onAttach(datum/abilityHolder/H)
		. = ..()
		desc = "Spend [CONTRACT_COST] souls to summon a random new contract to your location"

	cast(mob/target)
		. = ..()
		var/mob/living/M = holder.owner
		souladjust(-CONTRACT_COST)
		boutput(M, "<span class='alert'>You spend [CONTRACT_COST] souls and summon a brand new contract along with a pen! However, losing the power of those souls has weakened your weapons.</span>")
		spawncontract(M, strong=TRUE, pen=TRUE)
		soulcheck(M)

	castcheck()
		. = ..()
		var/mob/living/M = holder.owner
		if (!(total_souls_value >= CONTRACT_COST))
			boutput(M, "<span class='alert'>You don't have enough souls in your satanic bank account to buy another contract!</span>")
			boutput(M, "<span class='alert'>You need [CONTRACT_COST - total_souls_value] more to afford a contract!</span>")
			return FALSE
		if (!isdiabolical(M))
			boutput(M, "<span class='alert'>You aren't evil enough to use this power!</span>")
			boutput(M, "<span class='alert'>Also, you should probably contact a coder because something has gone horribly wrong.</span>")
			return FALSE

/////////////////////////Random Satan Gimmick Spells/////////////////////////////////////////////
/datum/abilityHolder/gimmick

/datum/targetable/gimmick
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "revenant_button_template"
	preferred_holder_type = /datum/abilityHolder/gimmick

/datum/targetable/gimmick/highway2hell
	icon_state = "grasp"
	name = "Send to hell"
	desc = "Sends the target straight to hell."
	targeted = TRUE
	max_range = 5
	cooldown = 30 SECONDS

	cast(mob/target)
		. = ..()
		var/mob/living/carbon/human/H = target
		if (!istype(H))
			boutput(holder.owner, "<span class='alert'>Your target must be human!</span>")
			return TRUE

		holder.owner.visible_message("<span class='alert'><b>[holder.owner] shoots finger guns in [target]s direction.</b></span>")
		playsound(holder.owner.loc, 'sound/effects/fingersnap.ogg', 50, 0, -1)

		if (H.traitHolder.hasTrait("training_chaplain"))
			boutput(holder.owner, "<span class='alert'>[H] has divine protection from magic.</span>")
			H.visible_message("<span class='alert'>The spell has no effect on [H]!</span>")
			JOB_XP(H, "Chaplain", 2)
			return
		holder.owner.say("See you in hell.")
		H.mind?.damned = TRUE
		animate_blink(H)

		SPAWN(0.5 SECONDS)
			H.implode()

/datum/targetable/gimmick/go2hell
	icon_state = "blink"
	name = "Visit Hell."
	desc = "Take a visit to hell or return to the living realm."
	cooldown = 5 SECONDS
	var/turf/spawnturf = null

	cast(atom/target)
		. = ..()
		holder.owner.say("So long folks!")
		playsound(holder.owner.loc, 'sound/voice/wizard/BlinkGrim.ogg', 50, FALSE, -1)

		SPAWN(0.5 SECONDS)
			var/mob/user = src.holder?.owner
			if (user)
				if(!spawnturf)
					spawnturf = get_turf(user)
					user.set_loc(pick(get_area_turfs(/area/afterlife/hell/hellspawn)))

				else
					if(user.mind.damned) //Backup plan incase Satan gets himself stuck in hell.
						user.set_loc(pick(get_area_turfs(/area/station/chapel)))
					else
						user.set_loc(spawnturf)
						spawnturf = null

/datum/targetable/gimmick/spawncontractsatan
	icon_state = "clairvoyance"
	name = "Summon Contract"
	desc = "Summon a devilish contract and pen."

	cast(mob/target)
		. = ..()
		spawncontract(src.holder.owner, 0, 1)

////////////////////////Kill Jesta///////////////////////////////
/datum/targetable/gimmick/Jestershift
	icon_state = "doppelganger"
	name = "Planeshift"
	desc = "Toggle your ability to shift between dimensions and become invisible."

	cast(atom/T)
		var/mob/user = src.holder.owner
		if(!isliving(user))
			return
		if(user.alpha == 0)
			user.alpha = 255
		else
			user.alpha = 0

		user.client.flying = !user.client.flying

/datum/targetable/gimmick/spooky
	icon_state = "corruption"
	name = "Be Spooky"
	desc = "Break some lights and laugh a bit."
	cooldown = 0.5 SECONDS

	cast(atom/T)
		. = ..()
		sonic_attack_environmental_effect(src.holder.owner, 5, list("light"))
		playsound(src.holder.owner.loc, 'sound/misc/jester_laugh.ogg', 125)

//////////////////////////Dumb Floorclown stuff//////////////////////////
/datum/targetable/gimmick/reveal
	icon_state = "doppelganger"
	name = "Toggle Reveal"
	desc = "Toggle your ability to hide under the floor."

	tryCast()
		if (is_incapacitated(holder.owner))
			boutput(holder.owner, "<span class='alert'>You cannot cast this ability while you are incapacitated.</span>")
			src.holder.locked = FALSE
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		. = ..()

	cast(atom/T)
		var/mob/user = src.holder.owner
		var/floorturf = get_turf(user)
		var/x_coeff = rand(0, 1)	// open the floor horizontally
		var/y_coeff = !x_coeff // or vertically but not both - it looks weird
		var/slide_amount = 22 // around 20-25 is just wide enough to show most of the person hiding underneath

		if(user.plane == PLANE_UNDERFLOOR)
			APPLY_ATOM_PROPERTY(user, PROP_MOB_HIDE_ICONS, "underfloor")
			user.flags &= ~(NODRIFT | DOORPASS | TABLEPASS)
			APPLY_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, "floorswitching")
			REMOVE_ATOM_PROPERTY(user, PROP_MOB_NO_MOVEMENT_PUFFS, "floorswitching")
			REMOVE_ATOM_PROPERTY(user, PROP_ATOM_NEVER_DENSE, "floorswitching")
			user.set_density(initial(user.density))
			animate_slide(floorturf, x_coeff * -slide_amount, y_coeff * -slide_amount, 4)
			SPAWN(0.4 SECONDS)
				if(user)
					user.plane = PLANE_DEFAULT
					user.layer = 4
					REMOVE_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, "floorswitching")
				if(floorturf)
					animate_slide(floorturf, 0, 0, 4)

		else
			APPLY_ATOM_PROPERTY(user, PROP_MOB_HIDE_ICONS, "underfloor")
			APPLY_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, "floorswitching")
			animate_slide(floorturf, x_coeff * -slide_amount, y_coeff * -slide_amount, 4)
			SPAWN(0.4 SECONDS)
				if(user)
					REMOVE_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, "floorswitching")
					APPLY_ATOM_PROPERTY(user, PROP_MOB_NO_MOVEMENT_PUFFS, "floorswitching")
					APPLY_ATOM_PROPERTY(user, PROP_ATOM_NEVER_DENSE, "floorswitching")
					user.flags |= NODRIFT | DOORPASS | TABLEPASS
					user.set_density(0)
					user.layer = 4
					user.plane = PLANE_UNDERFLOOR
				if(floorturf)
					animate_slide(floorturf, 0, 0, 4)

/datum/targetable/gimmick/movefloor
	icon_state = "pandemonium"
	name = "Move Floors"
	desc = "Move floors to scream at your foes more personally."
	cooldown = 0.5 SECONDS

	cast(atom/T)
		. = ..()
		var/mob/user = src.holder.owner
		var/movedistX = input(user,"How far would you like to move the floor tile.","How far to move left or right.","4") as num
		var/movedistY = input(user,"How far would you like to move the floor tile.","How far to move up or down.","4") as num
		var/movetime = input(user,"How fast would you like to move it.","How long it takes to move it.","4") as num
		animate_slide(get_turf(user), movedistX, movedistY, movetime)

/datum/targetable/gimmick/floorgrab
	icon_state = "clownrevenge"
	name = "Capture target"
	desc = "Drag a target into the eternal void."
	targeted = TRUE
	cooldown = 30 SECONDS
	var/grabtime = 6.5 SECONDS

	cast(mob/target)
		. = ..()
		src.holder.owner.plane = PLANE_UNDERFLOOR
		target.cluwnegib(grabtime)

//// Crayon-related stuff ////

/datum/targetable/gimmick/scribble // some hacky crayon ability
	icon = 'icons/mob/wraith_ui.dmi'
	icon_state = "bloodwriting"
	name = "Scribble"
	desc = "Write on a tile with questionable intent."
	targeted = TRUE
	target_anything = TRUE
	max_range = 5
	var/in_use = 0
	var/list/symbol_setting = list()
	var/list/c_default = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "Exclamation Point", "Question Mark", "Period", "Comma", "Colon", "Semicolon", "Ampersand", "Left Parenthesis", "Right Parenthesis",
		"Left Bracket", "Right Bracket", "Percent", "Plus", "Minus", "Times", "Divided", "Equals", "Less Than", "Greater Than")
	var/list/c_char_to_symbol = list(
		"!" = "Exclamation Point",
		"?" = "Question Mark",
		"." = "Period",
		"," = "Comma",
		":" = "Colon",
		";" = "Semicolon",
		"&" = "Ampersand",
		"(" = "Left Parenthesis",
		")" = "Right Parenthesis",
		"\[" = "Left Bracket",
		"]" = "Right Bracket",
		"%" = "Percent",
		"+" = "Plus",
		"-" = "Minus",
		"*" = "Times",
		"/" = "Divided",
		"=" = "Equals",
		"<" = "Less Than",
		">" = "Greater Than"
	)

	cast(atom/target, params)
		. = ..()
		var/turf/T = get_turf(target)
		if (isturf(T))
			write_on_turf(T, holder.owner, params)

	proc/write_on_turf(var/turf/T, var/mob/user, params)
		var/list/t // t is for what we're drawing

		if (!length(src.symbol_setting))
			var/inp = input(user, "Type letters you want to write.", "Letter Queue", null)
			inp = uppertext(inp)
			t = list()
			for(var/i = 1 to min(length(inp), 100))
				var/c = copytext(inp, i, i + 1)
				if(c != " " || (c in src.c_default) || (c in src.c_char_to_symbol))
					t += c

			if(!isnull(t) || !length(t))
				src.symbol_setting = t

		t = src.symbol_setting

		if(isnull(t) || !length(t))
			return

		if(length(t) == 1)
			src.symbol_setting = null
			t = t[1]
		else
			src.symbol_setting = t.Copy(2) // remove first
			t = t[1]

		if(t in src.c_char_to_symbol)
			t = src.c_char_to_symbol[t]

		var/obj/decal/cleanable/writing/spooky/G = make_cleanable(/obj/decal/cleanable/writing/spooky,T)
		G.artist = user.key

		logTheThing(LOG_STATION, user, "writes on [T] with [src] [log_loc(T)]: [t]")
		G.icon_state = t
		G.words = t
		if (islist(params) && params["icon-y"] && params["icon-x"])
			// playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 0)

			G.pixel_x = text2num(params["icon-x"]) - 16
			G.pixel_y = text2num(params["icon-y"]) - 16
		else
			G.pixel_x = rand(-4,4)
			G.pixel_y = rand(-4,4)
