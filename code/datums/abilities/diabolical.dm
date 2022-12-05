/* 	/		/		/		/		/		/		Setup		/		/		/		/		/		/		/		/		*/

/mob/proc/make_merchant()
	if (ishuman(src))
		var/datum/abilityHolder/merchant/A = src.get_ability_holder(/datum/abilityHolder/merchant)
		if (A && istype(A))
			return
		var/datum/abilityHolder/merchant/W = src.add_ability_holder(/datum/abilityHolder/merchant)
		W.addAbility(/datum/targetable/merchant/summon_contract)
		if (src.mind)
			if (!isdiabolical(src))
				src.mind.diabolical = 1
			else
				return

	else return

/* 	/		/		/		/		/		/		Ability Holder		/		/		/		/		/		/		/		/		*/
/atom/movable/screen/ability/topBar/merchant
	clicked(params)
		var/datum/targetable/merchant/spell = owner
		if (!istype(spell))
			return
		if (!spell.holder)
			return
		if (!isturf(owner.holder.owner.loc))
			boutput(owner.holder.owner, "<span class='alert'>You can't use this ability here.</span>")
			return
		if (spell.targeted && usr.targeting_ability == owner)
			usr.targeting_ability = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			owner.holder.owner.targeting_ability = owner
			owner.holder.owner.update_cursor()
		else
			SPAWN(0)
				spell.handleCast()
		return


/datum/abilityHolder/merchant
	usesPoints = 0
	regenRate = 0
	tabName = "Souls"
	notEnoughPointsMessage = "<span class='alert'>You need more souls to use this ability!</span>"

	onAbilityStat() // In the "Souls" tab.
		..()
		.= list()
		.["Souls:"] = total_souls_value
		.["Total Collected:"] = total_souls_sold
		return

/////////////////////////////////////////////// Merchant spell parent ////////////////////////////

/datum/targetable/merchant
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "template"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/merchant
	var/when_stunned = 1 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0

	New()
		var/atom/movable/screen/ability/topBar/merchant/B = new /atom/movable/screen/ability/topBar/merchant(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/merchant()
			object.icon = src.icon
			object.owner = src
		if (src.last_cast > world.time)
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt] ([round((src.last_cast-world.time)/10)])"
			object.icon_state = src.icon_state + "_cd"
		else
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt]"
			object.icon_state = src.icon_state
		return

	proc/incapacitation_check(var/stunned_only_is_okay = 0)
		if (!holder)
			return 0

		var/mob/living/M = holder.owner
		if (!M || !ismob(M))
			return 0

		switch (stunned_only_is_okay)
			if (0)
				if (!isalive(M) || M.hasStatus(list("stunned", "paralysis", "weakened")))
					return 0
				else
					return 1
			if (1)
				if (!isalive(M) || M.getStatusDuration("paralysis") > 0)
					return 0
				else
					return 1
			else
				return 1

	castcheck()
		if (!holder)
			return 0

		var/mob/living/M = holder.owner

		if (!M)
			return 0

		if (!ishuman(M))
			boutput(M, "<span class='alert'>You cannot use any powers in your current form.</span>")
			return 0

		if (M.transforming)
			boutput(M, "<span class='alert'>You can't use any powers right now.</span>")
			return 0

		if (incapacitation_check(src.when_stunned) != 1)
			boutput(M, "<span class='alert'>You can't use this ability while incapacitated!</span>")
			return 0

		if (src.not_when_handcuffed == 1 && M.restrained())
			boutput(M, "<span class='alert'>You can't use this ability when restrained!</span>")
			return 0

		if (!(isdiabolical(M)))
			boutput(M, "<span class='alert'>You aren't evil enough to use this power!</span>")
			boutput(M, "<span class='alert'>Also, you should probably contact a coder because something has gone horribly wrong.</span>")
			return 0

		if (!(total_souls_value >= CONTRACT_COST))
			boutput(M, "<span class='alert'>You don't have enough souls in your satanic bank account to buy another contract!</span>")
			boutput(M, "<span class='alert'>You need [CONTRACT_COST - total_souls_value] more to afford a contract!</span>")
			return 0

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return

/////////////////////////////////////////////// Contract Summoning Spell ////////////////////////////

/datum/targetable/merchant/summon_contract
	icon_state = "clairvoyance"
	name = "Summon Contract"
	desc = "Spend PLACEHOLDER (you shouldn't see this) souls to summon a random new contract to your location"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 0
	pointCost = CONTRACT_COST
	when_stunned = 1
	not_when_handcuffed = 0

	New()
		..()
		desc = "Spend [CONTRACT_COST] souls to summon a random new contract to your location"

	cast(mob/target)
		if (!holder)
			return 1
		var/mob/living/M = holder.owner
		if (!M)
			return 1
		if (!(total_souls_value >= CONTRACT_COST))
			boutput(M, "<span class='alert'>You don't have enough souls in your satanic bank account to buy another contract!</span>")
			boutput(M, "<span class='alert'>You need [CONTRACT_COST - total_souls_value] more to afford a contract!</span>")
			return 1
		if (!isdiabolical(M))
			boutput(M, "<span class='alert'>You aren't evil enough to use this power!</span>")
			boutput(M, "<span class='alert'>Also, you should probably contact a coder because something has gone horribly wrong.</span>")
			return 1
		souladjust(-CONTRACT_COST)
		boutput(M, "<span class='alert'>You spend [CONTRACT_COST] souls and summon a brand new contract along with a pen! However, losing the power of those souls has weakened your weapons.</span>")
		spawncontract(M, 1, 1) //strong contract + pen
		soulcheck(M)
		return 0

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
	targeted = 1
	max_range = 5
	cooldown = 300

	cast(mob/target)
		var/mob/living/carbon/human/H = target
		if (!istype(H))
			boutput(holder.owner, "Your target must be human!")
			return 1

		holder.owner.visible_message("<span class='alert'><b>[holder.owner] shoots finger guns in [target]s direction.</b></span>")
		playsound(holder.owner.loc, 'sound/effects/fingersnap.ogg', 50, 0, -1)

		if (H.traitHolder.hasTrait("training_chaplain"))
			boutput(holder.owner, "<span class='alert'>[H] has divine protection from magic.</span>")
			H.visible_message("<span class='alert'>The spell has no effect on [H]!</span>")
			JOB_XP(H, "Chaplain", 2)
			return

		holder.owner.say("See you in hell.")
		H.mind?.damned = 1
		animate_blink(H)
		sleep(0.5 SECONDS)
		H.implode()

/datum/targetable/gimmick/go2hell
	icon_state = "blink"
	name = "Visit Hell."
	desc = "Take a visit to hell or return to the living realm."
	targeted = 0
	cooldown = 50
	var/turf/spawnturf = null

	cast(atom/T)
		holder.owner.say("So long folks!")
		playsound(holder.owner.loc, 'sound/voice/wizard/BlinkGrim.ogg', 50, 0, -1)
		sleep(0.5 SECONDS)

		if(!spawnturf)
			spawnturf = get_turf(usr)
			usr.set_loc(pick(get_area_turfs(/area/afterlife/hell/hellspawn)))

		else
			if(usr.mind.damned) //Backup plan incase Satan gets himself stuck in hell.
				usr.set_loc(pick(get_area_turfs(/area/station/chapel)))
			else
				usr.set_loc(spawnturf)
				spawnturf = null

/datum/targetable/gimmick/spawncontractsatan
	icon_state = "clairvoyance"
	name = "Summon Contract"
	desc = "Summon a devilish contract and pen."
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 0

	cast(mob/target)
		if (!holder)
			return 1
		var/mob/living/M = holder.owner
		if (!M)
			return 1
		spawncontract(usr, 0, 1)
		return 0

////////////////////////Kill Jesta///////////////////////////////
/datum/targetable/gimmick/Jestershift
	icon_state = "doppelganger"
	name = "Planeshift"
	desc = "Toggle your ability to shift between dimensions and become invisible."
	var/original = null
	cooldown = 0

	cast(atom/T)
		if(!isliving(usr))
			return
		if(usr.alpha == 0)
			usr.alpha = 255
		else
			usr.alpha = 0

		usr.client.flying = !usr.client.flying

/datum/targetable/gimmick/spooky
	icon_state = "corruption"
	name = "Be Spooky"
	desc = "Break some lights and laugh a bit."
	cooldown = 5

	cast(atom/T)
		sonic_attack_environmental_effect(usr, 5, list("light"))
		playsound(holder.owner.loc, 'sound/misc/jester_laugh.ogg', 125)

//////////////////////////Dumb Floorclown stuff//////////////////////////
/datum/targetable/gimmick/reveal
	icon_state = "doppelganger"
	name = "Toggle Reveal"
	desc = "Toggle your ability to hide under the floor."
	targeted = 0
	cooldown = 0

	tryCast()
		if (is_incapacitated(holder.owner))
			boutput(holder.owner, "<span class='alert'>You cannot cast this ability while you are incapacitated.</span>")
			src.holder.locked = 0
			return 999
		. = ..()

	cast(atom/T)
		var/floorturf = get_turf(usr)
		var/x_coeff = rand(0, 1)	// open the floor horizontally
		var/y_coeff = !x_coeff // or vertically but not both - it looks weird
		var/slide_amount = 22 // around 20-25 is just wide enough to show most of the person hiding underneath

		if(usr.plane == PLANE_UNDERFLOOR)
			APPLY_ATOM_PROPERTY(usr, PROP_MOB_HIDE_ICONS, "underfloor")
			usr.flags &= ~(NODRIFT | DOORPASS | TABLEPASS)
			APPLY_ATOM_PROPERTY(usr, PROP_MOB_CANTMOVE, "floorswitching")
			REMOVE_ATOM_PROPERTY(usr, PROP_MOB_NO_MOVEMENT_PUFFS, "floorswitching")
			REMOVE_ATOM_PROPERTY(usr, PROP_ATOM_NEVER_DENSE, "floorswitching")
			usr.set_density(initial(usr.density))
			animate_slide(floorturf, x_coeff * -slide_amount, y_coeff * -slide_amount, 4)
			SPAWN(0.4 SECONDS)
				if(usr)
					usr.plane = PLANE_DEFAULT
					usr.layer = 4
					REMOVE_ATOM_PROPERTY(usr, PROP_MOB_CANTMOVE, "floorswitching")
				if(floorturf)
					animate_slide(floorturf, 0, 0, 4)

		else
			APPLY_ATOM_PROPERTY(usr, PROP_MOB_HIDE_ICONS, "underfloor")
			APPLY_ATOM_PROPERTY(usr, PROP_MOB_CANTMOVE, "floorswitching")
			animate_slide(floorturf, x_coeff * -slide_amount, y_coeff * -slide_amount, 4)
			SPAWN(0.4 SECONDS)
				if(usr)
					REMOVE_ATOM_PROPERTY(usr, PROP_MOB_CANTMOVE, "floorswitching")
					APPLY_ATOM_PROPERTY(usr, PROP_MOB_NO_MOVEMENT_PUFFS, "floorswitching")
					APPLY_ATOM_PROPERTY(usr, PROP_ATOM_NEVER_DENSE, "floorswitching")
					usr.flags |= NODRIFT | DOORPASS | TABLEPASS
					usr.set_density(0)
					usr.layer = 4
					usr.plane = PLANE_UNDERFLOOR
				if(floorturf)
					animate_slide(floorturf, 0, 0, 4)

/datum/targetable/gimmick/movefloor
	icon_state = "pandemonium"
	name = "Move Floors"
	desc = "Move floors to scream at your foes more personally."
	targeted = 0
	cooldown = 5
	max_range = 50

	cast(atom/T)
		if (!holder)
			return 1

		var/movedistX = input(usr,"How far would you like to move the floor tile.","How far to move left or right.","4") as num
		var/movedistY = input(usr,"How far would you like to move the floor tile.","How far to move up or down.","4") as num
		var/movetime = input(usr,"How fast would you like to move it.","How long it takes to move it.","4") as num
		animate_slide(get_turf(usr), movedistX, movedistY, movetime)

/datum/targetable/gimmick/floorgrab
	icon_state = "clownrevenge"
	name = "Capture target"
	desc = "Drag a target into the eternal void."
	targeted = 1
	cooldown = 300
	max_range = 1
	var/grabtime = 65

	cast(mob/target)
		usr.plane = PLANE_UNDERFLOOR
		target.cluwnegib(grabtime)

//// Crayon-related stuff ////

/datum/targetable/gimmick/scribble // some hacky crayon ability
	icon = 'icons/mob/wraith_ui.dmi'
	icon_state = "bloodwriting"
	name = "Scribble"
	desc = "Write on a tile with questionable intent."
	targeted = 1
	target_anything = 1
	cooldown = 0
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

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return 1

		var/turf/T = get_turf(target)
		if (isturf(T))
			write_on_turf(T, holder.owner, params)

	proc/write_on_turf(var/turf/T as turf, var/mob/user as mob, params)
		if (!T || !user)
			return
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
