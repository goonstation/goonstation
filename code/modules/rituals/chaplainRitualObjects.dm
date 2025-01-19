//File for objects chaplain rituals use.

/proc/ritualBuffEffect(var/icon_state, var/atom/owner)
	if(owner.render_target == null) owner.render_target = "\ref[owner]"
	var/image/buffImage = image('icons/misc/chaplainRitual.dmi', null, FLOAT_LAYER)
	buffImage.icon_state = icon_state
	buffImage.filters += filter(type="alpha", render_source=owner.render_target)
	buffImage.appearance_flags = KEEP_APART | PIXEL_SCALE
	owner.UpdateOverlays(buffImage, icon_state)
	return buffImage

/proc/ritualEffect(var/aloc, var/istate = "magic", var/duration = 50, var/aoe = 0, var/rPlane = 0)
	if(aoe <= 0)
		var/obj/chaplainStuff/ritualeffect/M = new /obj/chaplainStuff/ritualeffect
		M.dir = pick(NORTH,EAST,SOUTH,WEST)
		M.show(aloc, istate, duration, rPlane)
		return M
	else
		var/obj/chaplainStuff/ritualeffectbig/M = new /obj/chaplainStuff/ritualeffectbig
		M.dir = pick(NORTH,EAST,SOUTH,WEST)
		var/multiplier = ((aoe * 64)+32)+(aoe>2?(aoe-2)*16:(aoe<2?(aoe-2)*-16:0)) / 160 //Good luck if you ever have to change this. 160 is the base size of the aoe icon, +-16 per aoe above/under 2 (2 corresponds to icon size 160) to adjust for the center tile.
		var/matrix/MA = matrix()
		MA.Scale(multiplier,multiplier)
		MA.Translate(-64*multiplier,-64*multiplier)
		M.transform = MA
		M.show(aloc, istate, duration, rPlane)
		return M

/obj/item/storage/box/ritual
	name = "EZ-Magic kit"
	spawn_contents = list(/obj/item/sacdagger,/obj/item/thaumometer,/obj/item/spiritshard/cheatyten,/obj/item/spiritshard/cheatyfive,/obj/item/ritualChalk/randomColor,/obj/item/ritualskull,/obj/item/paper/rituals)
	New()
		animate_rainbow_glow(src)
		..()

/obj/ritual_sprite
	name = "Broken sprite"
	desc = "This sprite is broken garbage. Clearly keelin messed up."
	icon = 'icons/misc/chaplainRitual.dmi'
	icon_state = "sprite-arcane"
	density = 0
	opacity = 0
	anchored = 1
	layer = EFFECTS_LAYER_4
	var/datum/spriteType/spriteType = null
	var/health = 33

	New()
		setType()
		..()

	proc/setType(var/newType = null)
		if(!spriteType && !newType)
			spriteType = new/datum/spriteType/arcane()
			applyType()
		else if(!istype(spriteType, /datum/spriteType/arcane) && newType != null)
			spriteType = new newType()
			applyType()
		else
			spriteType = new /datum/spriteType/chaos()
			applyType()
		return

	proc/applyType()
		if(spriteType)
			src.name = spriteType.name
			src.desc = spriteType.desc
			src.icon_state = spriteType.icon_state
		return

/datum/spriteType
	var/name = ""
	var/desc = ""
	var/icon_state = ""
	var/aoe = 0
	var/corrupted = 0
	var/follows = 0
	var/list/targetTypes = list(/mob)
	var/spell_frequency = 100
	var/sayVerb = "chimes"

	proc/say(var/atom/location, var/text = "")
		for(var/mob/O in all_hearers(5, location))
			O.show_message(SPAN_NAME(src.name) + " [sayVerb], " + SPAN_MESSAGE("\"[text]\""), 2)
		return

	proc/doSomeGodDamnMagic(var/obj/ritual_sprite/source, var/atom/target)
		return

	arcane
		name = "Arcane sprite"
		desc = "A ball of magical energy, minding it's own business. Whatever that may be."
		icon_state = "sprite-arcane"
		doSomeGodDamnMagic(var/obj/ritual_sprite/source, var/atom/target)
			return ..()

	soul //Listen here now. Do you think this is a fucking joke or what.
		name = "DOUBLE SPRITE!!!!11"
		desc = "HOLY CRAP. IT'S A DOUBLE SPRITE. A TRUE GENIUS MUST'VE SUMMONED THAT."
		icon_state = "sprite-double"
		sayVerb = "SCREAMS!!!"
		doSomeGodDamnMagic(var/obj/ritual_sprite/source, var/atom/target)
			if(prob(50))
				//weaken them.
				var/message = pick("IT'S JuST A PRanK BrO.", "LOl PRanKed!!1", "LOlol NeRD!", "LOL", "HaHA PRanKED")
				say(source,message)
				target.setStatus("knockdown", 2 SECONDS)
				var/obj/chaplainStuff/ritualeffect/M = new /obj/chaplainStuff/ritualeffect
				M.show(get_turf(target), "spritemagic")
			else
				var/message = pick("IM A DOuBLE SPRITe WOOO!!!", "DoUBLE ThE SPRITe, DOuBLE tHE PoWEr", "RADICaL!111", "WOoP!", "SWeET STaTION DUDE!!!11", "BoDALIciOUS", "DuDE", "HEy DUDe", "HeY! LIsTEN!!!1", "LIsTEN!!!1")
				say(source,message)
			return ..()
	fire
		name = "Fire sprite"
		desc = "A happy looking ball of fire. Happy ... or mischievous?"
		icon_state = "sprite-fire"
		doSomeGodDamnMagic(var/obj/ritual_sprite/source, var/atom/target)
			var/obj/chaplainStuff/ritualeffect/M = new /obj/chaplainStuff/ritualeffect
			M.show(get_turf(target), "spritemagic")
			return ..()

	water
		name = "Water sprite"
		desc = "A water sprite calmly floats about."
		icon_state = "sprite-water"
		doSomeGodDamnMagic(var/obj/ritual_sprite/source, var/atom/target)
			var/obj/chaplainStuff/ritualeffect/M = new /obj/chaplainStuff/ritualeffect
			M.show(get_turf(target), "spritemagic")
			return ..()

	air
		name = "Air sprite"
		desc = "An air sprite is zipping about nearly invisibly."
		icon_state = "sprite-air"
		doSomeGodDamnMagic(var/obj/ritual_sprite/source, var/atom/target)
			var/obj/chaplainStuff/ritualeffect/M = new /obj/chaplainStuff/ritualeffect
			M.show(get_turf(target), "spritemagic")
			return ..()

	earth
		name = "Earth sprite"
		desc = "An earth sprite bumbles through the air clumsily."
		icon_state = "sprite-earth"
		doSomeGodDamnMagic(var/obj/ritual_sprite/source, var/atom/target)
			var/obj/chaplainStuff/ritualeffect/M = new /obj/chaplainStuff/ritualeffect
			M.show(get_turf(target), "spritemagic")
			return ..()

	dark
		name = "Darkness sprite"
		desc = "A darkness sprite is brooding and grumbling in mid-air here."
		icon_state = "sprite-dark"
		doSomeGodDamnMagic(var/obj/ritual_sprite/source, var/atom/target)
			var/obj/chaplainStuff/ritualeffect/M = new /obj/chaplainStuff/ritualeffect
			M.show(get_turf(target), "spritemagic")
			return ..()

	move
		name = "Movement sprite"
		desc = "A movement sprite is ... moving about."
		icon_state = "sprite-move"
		doSomeGodDamnMagic(var/obj/ritual_sprite/source, var/atom/target)
			var/obj/chaplainStuff/ritualeffect/M = new /obj/chaplainStuff/ritualeffect
			M.show(get_turf(target), "spritemagic")
			return ..()

	bee
		name = "Bee sprite"
		desc = "A ... bee ... sprite is buzzing around here ... Yep."
		icon_state = "sprite-bee"
		doSomeGodDamnMagic(var/obj/ritual_sprite/source, var/atom/target)
			var/obj/chaplainStuff/ritualeffect/M = new /obj/chaplainStuff/ritualeffect
			M.show(get_turf(target), "spritemagic")
			return ..()

	chaos
		name = "Chaos sprite"
		desc = "That sprite doesn't look too healthy. Oh wait, yes it does. No it doesn't. W-huh ..."
		icon_state = "sprite-chaos"
		doSomeGodDamnMagic(var/obj/ritual_sprite/source, var/atom/target)
			var/obj/chaplainStuff/ritualeffect/M = new /obj/chaplainStuff/ritualeffect
			M.show(get_turf(target), "spritemagic")
			return ..()

//SWITCH TO PROCESSING AND POOL/UNPOOL. IMPORTANT. DO NOT FORGET. WILL PROBABLY FORGET.
/obj/chaplainStuff/tentacle
	density = 0
	opacity = 0
	anchored = 1
	layer = EFFECTS_LAYER_4
	name = ""
	icon = 'icons/misc/chaplainRitual.dmi'
	icon_state = "ten1"
	alpha = 0

	New(var/loc,var/d)
		dir = d
		src.set_loc(loc)
		icon_state = pick("ten1","ten2","ten3")
		animate(src, alpha=255, time=10)
		SPAWN(30)
			animate(src, alpha=0, time=10)
		SPAWN(40)
			src.set_loc(null)
			qdel(src)
		..(loc)

/obj/chaplainStuff/ritualeffect
	density = 0
	opacity = 0
	anchored = 1
	name = ""
	icon = 'icons/misc/chaplainRitual.dmi'
	icon_state = "empty"
	layer = EFFECTS_LAYER_4

	proc/show(var/loc, var/istate = "magic", var/duration = 50, var/rPlane = 0)
		src.plane = rPlane
		src.set_loc(loc)
		flick(istate, src)
		SPAWN(duration)
			src.set_loc(null)
			qdel(src)

/obj/chaplainStuff/ritualeffectbig
	density = 0
	opacity = 0
	anchored = 1
	pixel_x = -64
	pixel_y = -64
	name = ""
	icon = 'icons/effects/rituals_160x160.dmi'
	icon_state = "empty"

	proc/show(var/loc, var/istate = "ritualeffect", var/duration = 200, var/rPlane = 0)
		src.plane = rPlane
		src.set_loc(loc)
		flick(istate, src)
		SPAWN(duration)
			src.set_loc(null)
			qdel(src)

/obj/chaplainStuff/darkness/evil
	name = "EVIL darkness"
	desc = "That patch of darkness looks particulary evil. Probably a bad idea to touch it."
	var/list/directions = list()
	var/doNotTentacleEver = 0

	New(var/loc, var/duration = 100)
		SPAWN(20) process()
		..(loc,duration)

	proc/process()
		if(!doNotTentacleEver && prob(30))
			directions.Cut()
			for(var/d in list(NORTH,EAST,SOUTH,WEST))
				if(/obj/chaplainStuff/darkness/evil in get_step(src, d)) continue
				else directions.Add(d)
			if(directions.len)
				var/direction = pick(directions)
				var/turf/T = get_step(src, direction)
				new/obj/chaplainStuff/tentacle(T,direction)
			else
				doNotTentacleEver = 1
		for(var/mob/M in src.loc)
			M.TakeDamage("All", 4, 4, 4, DAMAGE_BLUNT)
		SPAWN(20) process()

/obj/chaplainStuff/darkness
	density = 0
	opacity = 1
	anchored = 1
	layer = NOLIGHT_EFFECTS_LAYER_4

	name = "darkness"
	desc = "This is not just normal darkness. This is even darker than black."

	icon = 'icons/misc/chaplainRitual.dmi'
	icon_state = "black"

	New(var/loc, var/duration = 100)
		src.set_loc(loc)
		filters = null
		//filters += filter(type="blur", size=6)
		filters = filter(type="drop_shadow", x=0, y=0, offset=16, size=8, color="#000000")
		SPAWN(duration)
			src.set_loc(null)
			qdel(src)
		..(loc)

/obj/item/sacdagger
	name = "Sacrifical dagger"
	desc = "Used to trigger sacrifical sigils without triggering the entire ritual."
	icon = 'icons/misc/chaplainRitual.dmi'
	icon_state = "sacdagger0"
	flags = TABLEPASS | USEDELAY | EXTRADELAY
	c_flags = ONBELT
	throwforce = 1
	force = 5
	w_class = W_CLASS_TINY
	hit_type = DAMAGE_CUT

	setupProperties()
		setProperty("vorpal", 8)
		return ..()

	pixelaction(atom/target, params, mob/user, reach)
		if(istype(target, /atom/movable/screen)) return
		var/turf/T = get_turf(target)
		var/used = 0
		//var/prevLen = length(T.contents)
		for(var/atom/A in T)
			if(A.ritualComponent && A.ritualComponent.hasFlags(RITUAL_FLAG_CONSUME))
				A.ritualComponent.flag_consume()
				used = 1
		if(used)// && T.contents.len != prevLen)
			ritualEffect(T, "sac")
		return

/obj/item/ritualskull
	name = "Odd-looking skull"
	desc = "It thrums with evil power."
	icon = 'icons/misc/chaplainRitual.dmi'
	icon_state = "oddskull"
	flags = TABLEPASS | USEDELAY | EXTRADELAY
	throwforce = 0
	w_class = W_CLASS_TINY

	New()
		ritualComponent = new/datum/ritualComponent/corruptus(src)
		ritualComponent.autoActive = 1
		..()

/obj/item/spiritshard
	name = "Spirit shard"
	desc = "Condensed magical energy."
	icon = 'icons/misc/chaplainRitual.dmi'
	icon_state = "spiritshard0"
	flags = TABLEPASS | USEDELAY | EXTRADELAY
	c_flags = ONBELT
	throwforce = 0
	w_class = W_CLASS_TINY
	var/storedPower = 0
	var/storedStrength = 0
	var/corrupted = 0

	cheatycorrupt
		New(var/loc)
			var/datum/ritualVars/V = newRitualVars(75, 75)
			V.corrupted = 1
			return ..(loc,V)

	dontusetheseitstoomuchpower
		New(var/loc)
			return ..(loc,newRitualVars(1000, 1000))

	cheatyfifty
		New(var/loc)
			return ..(loc,newRitualVars(50, 50))

	cheatyten
		New(var/loc)
			return ..(loc,newRitualVars(10, 10))

	cheatyfive
		New(var/loc)
			return ..(loc,newRitualVars(5, 5))

	cheatyone
		New(var/loc)
			return ..(loc,newRitualVars(1, 1))

	proc/setVars(var/datum/ritualVars/V)
		storedPower = V.energy
		storedStrength = V.strength

		if(V.corrupted)
			corrupted = 1
			switch(storedPower+storedStrength)
				if(1 to 9)
					icon_state = "spiritshardC0"
					name = "Fractured Soul shard"
				if(10 to 19)
					icon_state = "spiritshardC1"
					name = "Ghastly soul shard"
				if(20 to INFINITY)
					icon_state = "spiritshardC2"
					name = "Wailing soul shard"
		else
			switch(storedPower+storedStrength)
				if(1 to 9)
					icon_state = "spiritshard0"
					name = "Dull [lowertext(initial(name))]"
				if(10 to 19)
					icon_state = "spiritshard1"
					name = "Glowing [initial(name)]"
				if(20 to INFINITY)
					icon_state = "spiritshard2"
					name = "Vibrant [lowertext(initial(name))]"

		desc = "Condensed magical energy. It contains [storedPower] power and [storedStrength] strength."
		return

	New(var/loc, var/datum/ritualVars/V)
		..()
		set_loc(loc)
		setVars(V)
		return

/obj/item/thaumometer
	name = "Thaumometer"
	desc = "Used to analyze the power and strength of rituals. Will only show the currently stored power/strength of the ritual."
	icon = 'icons/misc/chaplainRitual.dmi'
	icon_state = "thaumometer"
	flags = TABLEPASS | USEDELAY | EXTRADELAY
	c_flags = ONBELT
	throwforce = 0
	w_class = W_CLASS_TINY

	pixelaction(atom/target, params, mob/user, reach)
		if(istype(target, /atom/movable/screen)) return
		var/turf/T = get_turf(target)
		for(var/atom/A in T)
			if(A.ritualComponent)
				var/datum/ritualComponent/anchor/anchor = null
				if(istype(A.ritualComponent, /datum/ritualComponent/anchor))
					anchor = A.ritualComponent
				else if(A.ritualComponent.ownerAnchor)
					anchor = A.ritualComponent.ownerAnchor
				if(anchor)
					var/datum/ritualVars/V = newRitualVars()
					for(var/datum/ritualComponent/C in anchor.getFlagged(RITUAL_FLAG_ENERGY))
						V = C.flag_power(V,0)
					for(var/datum/ritualComponent/C in anchor.getFlagged(RITUAL_FLAG_STRENGTH))
						V = C.flag_strength(V,0)
					boutput(user, SPAN_ALERT("<b>Ritual power:[V.energy] , Ritual strength:[V.strength]</b>"))
				else
					boutput(user, SPAN_ALERT("<b>No ritual anchor found.</b>"))
		return

/obj/item/ritualChalk
	name = "Ritual chalk"
	desc = "Ritual chalk used to draw symbols for rituals."
	icon = 'icons/obj/ritual_writing.dmi'
	icon_state = "ritualchalk"
	flags = TABLEPASS | USEDELAY | EXTRADELAY
	c_flags = ONBELT
	throwforce = 0
	w_class = W_CLASS_TINY
	color = "#931010"
	var/cursed = 0
	var/blessed = 0
	var/uses = -11111

	randomColor
		New()
			randomColor()
			..()

		limited_use_200
			uses = 200

	get_desc()
		if (uses > 0)
			. += "it looks like it only has about [uses] uses left!"

	var/list/buttons = list()
	var/turf/target = null

	proc/setColorHex(var/str)
		var/datum/color/C = new()
		C.from_hex(str)
		setColor(C)
		return

	proc/setColor(var/datum/color/C)
		color = C.to_rgb()
		name = "[capitalize(get_nearest_color(C))] [lowertext(initial(name))]"
		return

	proc/randomColor()
		var/datum/color/C = new()
		C.r = rand(0,255)
		C.g = rand(0,255)
		C.b = rand(0,255)
		C.a = 255
		setColor(C)
		return

	proc/addButton(var/datum/ritualComponent/C)
		var/atom/movable/screen/chalkButton/B = new/atom/movable/screen/chalkButton(null, C, src, src.color)
		return B

	pixelaction(atom/target, params, mob/living/user, reach)
		if (!target || !isturf(target) || !user || !reach || BOUNDS_DIST(target, user) > 0)
			return 0

		if(!buttons.len)
			for(var/datum/ritualComponent/C in globalRitualComponents)
				if(C.selectable)
					buttons += addButton(C)

		var/starting_x = (target.x - user.x)
		var/starting_y = (target.y - user.y)

		var/off_y = starting_y
		var/off_x = -(RITUAL_BUTTON_SCALE*RITUAL_BUTTONS_PER_SIDE) + starting_x

		removeButtons(user)

		for(var/atom/movable/screen/chalkButton/C in buttons)
			C.screen_loc = "CENTER[off_x < 0 ? "[off_x]":"+[off_x]"],CENTER[off_y < 0 ? "[off_y]":"+[off_y]"]"
			var/mob/living/carbon/human/H = user
			if(istype(H)) H.hud.add_screen(C)
			var/mob/living/critter/R = user
			if(istype(R)) R.hud.add_screen(C)

			if(off_x >= (RITUAL_BUTTON_SCALE*RITUAL_BUTTONS_PER_SIDE) + starting_x)
				off_x = -(RITUAL_BUTTON_SCALE*RITUAL_BUTTONS_PER_SIDE) + starting_x
				off_y -= RITUAL_BUTTON_SCALE
			else
				off_x += RITUAL_BUTTON_SCALE

		//set move callback (dismiss buttons when we move)
		if (islist(user.move_laying))
			user.move_laying += src
		else
			if (user.move_laying)
				user.move_laying = list(user.move_laying, src)
			else
				user.move_laying = list(src)

		src.target = target
		return 1

	proc/placeSymbol(var/datum/ritualComponent/C)
		if(locate(/obj/decal/cleanable/ritualSigil) in target)
			var/obj/decal/cleanable/ritualSigil/S = (locate(/obj/decal/cleanable/ritualSigil) in target)

			if (!S.drawn_on_intact_floor &&  S.alpha == 0)
				boutput(usr, SPAN_ALERT("<b>You try to draw a new rune on [target], but the chalk won't make any markings..."))
				return
			else
				boutput(usr, SPAN_ALERT("<b>You replace the [S] ..."))
				del(S)
		if(target && BOUNDS_DIST(target, src) == 0)
			var/obj/decal/cleanable/ritualSigil/R = new/obj/decal/cleanable/ritualSigil(target, C.type)
			R.color = src.color
			R.dir = get_dir(src, target)
			playsound(get_turf(target), pick('sound/effects/chalk1.ogg','sound/effects/chalk2.ogg','sound/effects/chalk3.ogg'), 100, 1)

			//for non-permanent chalks.
			uses--
			if (uses <= 0 && uses >= -10)	//idk, I'm just super paranoid of fpe's
				boutput(usr, SPAN_ALERT("<b>Your [src] breaks apart into an unusable powder devoid of mysticism..."))
				usr.drop_item()
				qdel(src)
		return

	move_callback(var/mob/M, var/turf/source, var/turf/target)
		removeButtons(M)

	proc/removeButtons(var/mob/living/user)
		for(var/atom/movable/screen/chalkButton/C in user.client.screen)
			var/mob/living/carbon/human/H = user
			if(istype(H)) H.hud.remove_screen(C)
			var/mob/living/critter/R = user
			if(istype(R)) R.hud.remove_screen(C)

		if (islist(user.move_laying))
			user.move_laying -= src
		else
			user.move_laying = null

		return

/atom/movable/screen/chalkButton
	name = ""
	icon = 'icons/obj/ritual_writing.dmi'
	icon_state = ""
	var/datum/ritualComponent/component = null
	var/image/bgImage = null
	var/obj/item/ritualChalk/chalice = null

	New(var/cloc, var/datum/ritualComponent/C, var/obj/item/ritualChalk/ch, var/col)
		chalice = ch
		component = C
		src.name = C.name
		icon_state = C.icon_symbol
		src.color = col
		bgImage = image('icons/obj/ritual_writing.dmi', src, C.bg)
		bgImage.appearance_flags = RESET_COLOR | PIXEL_SCALE
		src.underlays += bgImage
		src.transform *= RITUAL_BUTTON_SCALE
		src.add_filter("chalkbutton_drop_shadow", 0, drop_shadow_filter(x=0, y=0, size=3, offset=0, color="#000000"))
		src.add_filter("chalkbutton_outline", 0, outline_filter(size=2, color="#000000"))
		return ..()

	MouseEntered(object,location,control,params)
		src.add_filter("chalkbutton_drop_shadow", 0, drop_shadow_filter(x=0, y=0, size=3, offset=0, color="#FFFFFF"))
		src.add_filter("chalkbutton_outline", 0, outline_filter(size=2, color="#FFFFFF"))

		var/flagStr = ""
		if(!(component.ritualFlags & RITUAL_FLAG_SECRET))
			if(component.ritualFlags & RITUAL_FLAG_CORE) flagStr += " Core"
			if(component.ritualFlags & RITUAL_FLAG_CREATE) flagStr += " Smn"
			if(component.ritualFlags & RITUAL_FLAG_MODIFY) flagStr += " Mod"
			if(component.ritualFlags & RITUAL_FLAG_ENERGY) flagStr += " Enr"
			if(component.ritualFlags & RITUAL_FLAG_SELECT) flagStr += " Trg"
			if(component.ritualFlags & RITUAL_FLAG_STRENGTH) flagStr += " Str"
			if(component.ritualFlags & RITUAL_FLAG_CONSUME) flagStr += " Sac"
			if(component.ritualFlags & RITUAL_FLAG_RANGE) flagStr += " Rng"
			flagStr += " "
		else
			flagStr += " ???"
			flagStr += " "

		if (usr.client.tooltipHolder && (component != null))
			var/turf/T = locate(usr.x-1, usr.y+3, usr.z) //This is so unbelievably fucking stupid. WHY ARE THE PARAMS PASSED INTO THIS NON-EXISTENT ANYWAY. FUCK.
			usr.client.tooltipHolder.showHover(src, list(
				"params" = T ? T.getScreenParams() : usr.getScreenParams(),
				"title" = component.name + " ([flagStr])",
				"content" = component.desc,
				"theme" = "wraith"
			))
		return

	MouseExited(location,control,params)
		src.add_filter("chalkbutton_drop_shadow", 0, drop_shadow_filter(x=0, y=0, size=3, offset=0, color="#000000"))
		src.add_filter("chalkbutton_outline", 0, outline_filter(size=2, color="#000000"))

		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()
		return

	clicked(list/params)
		chalice.removeButtons(usr)
		chalice.placeSymbol(component)

/obj/decal/cleanable/ritualSigil
	name = "Sigil"
	desc = "A sigil of some sort."
	can_fluid_absorb = 0
	icon = 'icons/obj/ritual_writing.dmi'
	icon_state = "(anchor)"
	level = 1			// 0=over floor, 1=under floor
	var/drawn_on_intact_floor = 1


	New(var/cloc, var/C)
		ritualComponent = new C(src)
		icon_state = ritualComponent.icon_symbol
		src.name = ritualComponent.name

		//for drawing underneath topmost tiles
		if (isturf(cloc))
			var/turf/T = cloc
			if (T.intact)
				drawn_on_intact_floor = 1
			else
				drawn_on_intact_floor = 0

		return ..(loc=cloc)

	Del()
		if(ritualComponent)
			del(ritualComponent)
		return ..()

	disposing()
		if(ritualComponent)
			del(ritualComponent)
		return ..()


	//for drawing underneath topmost tiles
	//proc used in from disposalpipe in disposal.dm
	hide(var/intact)
		if (intact)
			if (drawn_on_intact_floor)
				// invisibility = INVIS_NONE
				alpha = 255
				mouse_opacity = 1
			else
				// invisibility = INVIS_ALWAYS
				alpha = 0
				mouse_opacity = 0

		else
			if (drawn_on_intact_floor)
				// invisibility = INVIS_ALWAYS
				alpha = 0
				mouse_opacity = 0
				del(src)
			else
				// invisibility = INVIS_NONE
				alpha = 255
				mouse_opacity = 1


//<B>REDACTED</B> = If you can't find any ritual chalk, just sprinkle some holy water on normal chalk.<br><br>
//Unsurprisingly, putting holy water on a normal knife will produce a ritual knife.<br><br>
//Thaumometers let you gather some data from your ritual and can be made by, again, putting some holy water on a multitool.<br><br>

/obj/item/paper/rituals //NONONONONONONO DONT LOOK AT THIS DONT LOOK PLEASE DONT AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	name = "note on rituals"
	desc = "a hastily scribbled note on rituals"
	icon_state = "paper"

	examine()
		info = {"
	Rituals:<br><br>

		Rituals are a form of magic that can be performed by almost anyone, <br>
		although chaplains have an easier time - more on that later.<br><br>

	Requirements:<br><br>

		At the bare minimum only some ritual chalk is required.<br>
		If you can't find any ritual chalk, just <B>~%$H^$$F</B>.<br><br>

		Sacrificial knifes are used for some specific parts of rituals requiring, surprise, sacrifices.<br>
		Unsurprisingly, putting <B>~FDSG%$EU%$</B> will produce a ritual knife.<br><br>

		Thaumometers let you gather some data from your ritual and can be made by<B>ETJ ^*$$HD$DG</B> .<br><br>

	The Basics:<br><br>

		Any ritual starts with a ritual anchor drawn on the ground using ritual chalk.<br>
		The anchor is the most important part of any ritual and ties together the rest of it.<br><br>

		Directly above the anchor goes the core component of a ritual.<br>
		The core component determines the broader effects of what you're trying to achieve.<br>
		"Evoco" for example will, in a wider sense, summon or create things.<br><br>

		Any components directly adjacent to the core component will directly modify said core component.<br>
		They will not be used for any secondary effects. Components next to the core are core exclusive.<br>
		For example, placing an "Apis" next to your "Evoco" will summon some bees!<br><br>

		Other components that are not directly adjacent to the core will provide secondary effects.<br>
		Such effects might include modifying the power of the ritual or targeting specific things.<br>
		Add a "Hominem" to the bee summoning (*not* adjacent to the evoco) and you'll summon a bee on a nearby human. Not terribly useful but hey.<br><br>

		Once you've arranged all your components it's time to do some magic.<br>
		Simply say the name of every component in your ritual out loud - it's that easy.<br>
		This does not include the anchor, in case you were wondering.<br><br>

		If everything went alright, something will happen. Who knows what. It's magic. Deal with it.<br>
		Chances are however, that not everything went alright. Chances are your first try fizzled. But why?<br><br>

	Power and Energy:<br><br>

		The most important parts of a ritual that you can NOT see (unless you use a thaumometer) are ritual power and energy.<br><br>

		Energy describes the fuel of your ritual. If you don't have enough juice for what you're trying to do then it's not gonna work.<br>
		Some components will use energy, others are free. You can get more energy from such things as sacrifices.<br><br>

		Power is the strength of the effect that you're producing. More power means more dramatic and impressive results.<br>
		Power can mostly be gained in the same ways as Energy.<br><br>

		And here's why a chaplain will have an easier time with this stuff:<br>
		Having a chaplain close to the ritual will automatically provide it with some free power and energy. Neat.<br>
		Specifically, 2 of each, which is enough to easily whip up some minor tricks.<br><br>

	Other things: <br><br>

		Tooltips on the chalk menu will tell you what roles a component can provide.<br>
		In the end it all comes down to experimentation. See what works together and what doesn't.<br>
		On that note, you might find that some objects on the station can be used as ritual components ...<br><br>

	A quick example: <br><br>

		Start by placing down an anchor sigil. Next place your core sigil north of it. This in the only fixed part of a ritual's layout.<br>
		In this case we're going to use "evoco".<br><br>

		<img src="[resource("images/rittut1.png")]"><br><br>

		The tiles directly adjacent to your core, in this case evoco, are reserved for exclusive use by the core sigil.<br>
		Adjacent includes all 8 tiles around the core sigil. Though one will be taken up by the anchor already.<br>
		For clarity, they are the green-colored tiles in the image above.<br><br>

		<img src="[resource("images/rittut2.png")]"><br><br>

		Let's add Apis next to the core - this will cause it to summon a bee. No other part of the ritual will use apis, since it is adjacent to the core.<br>
		Now let's add some secondary effects and modifiers. First let's make our summoned bee a bit fiery.<br>
		Simply add an ignis sigil -outside- the core's range. That is outside the adjacent tiles discussed above.<br>
		An example would be the red-colored tiles in the image.<br>
		If you were to place the ignis next to the core, you might end up summoning fire instead. Ooops.<br>
		The ritual still needs some power and we can use sacrificum for that.<br>
		Simply place it down outside the core range and put some sacrifices on it. People, body parts, money, spirit shards ... I'm sure you can find something.<br>
		Now say the names of all the sigils included in the ritual and with any luck we get ...<br><br>

		<img src="[resource("images/rittut3.png")]"><br><br>

		Well ... It's not a proper bee but it's something. We might have to get some more power next time!
		"}
		return ..()

#ifdef HALLOWEEN
obj/eldritch_altar
	name = "eldritch altar"
	desc = "A strange altar with strangely familiar symbols etched into it.. Seems to have <b>two<b> different symbols on either side of it. It looks, uhh spooky."
	icon = 'icons/obj/spooky.dmi'
	icon_state = "altar-sleep"
	density = 1
	anchored = 0
	flags = NOSPLASH
	event_handler_flags = USE_FLUID_ENTER
	layer = OBJ_LAYER-0.1
	pixel_x = -16
	var/the_guy						//the guy trying to get the chalk
	var/spacebux_value				//How much spacebux they put in for this try
	var/sacrifice_value				//value of the sacrifice to get the

	var/active = 0
	var/uses						//How many times this has been used successfully to get an item this has this round.
	var/const/max_uses = 3
	var/list/used_by				//list of ckeys that have used this successfully this round.
	var/list/reward_item_pool

	var/spacebux_consumed_round		//amount of spacebux consumed this round.
	var/spacebux_consumed_total

	//not very efficient, but hey, it's a gimmick item...
	var/list/left_offerings = list()
	var/list/right_offerings = list()

	New()
		..()
		used_by = list()
		reward_item_pool = list(/obj/item/paper/rituals, /obj/item/sacdagger,/obj/item/thaumometer, /obj/item/ritualskull, /obj/item/ritualChalk/randomColor, /obj/item/ritualChalk)
		spacebux_consumed_total = world.load_intra_round_value("altar_spacebux_consumed")
		src.RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_REBOOT, PROC_REF(save_spacebux_consumed))

	proc/save_spacebux_consumed()
		world.save_intra_round_value("altar_spacebux_consumed", spacebux_consumed_total+spacebux_consumed_round)
		message_admins("spooktober altar destroyed {[spacebux_consumed_round]} spacebux this round. Server Total: {[spacebux_consumed_total+spacebux_consumed_round]}.")
		logTheThing(LOG_DEBUG, null, "kyle - spooktober altar destroyed {[spacebux_consumed_round]} spacebux this round, {[spacebux_consumed_total+spacebux_consumed_round]} total.(On this server)")

	//you can only slam
	attackby(obj/item/W, mob/user, params)
		if(W.cant_drop) return
		if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (!G.affecting || G.affecting.buckled)
				return
			if (G.state == GRAB_PASSIVE)
				boutput(user, SPAN_ALERT("You need a tighter grip!"))
				return
			G.affecting.set_loc(src.loc)

			if (!G.affecting.hasStatus("knockdown"))
				G.affecting.changeStatus("knockdown", 3 SECONDS)
				G.affecting.force_laydown_standup()
			src.visible_message(SPAN_ALERT("<b>[G.assailant] slams [G.affecting] onto \the [src]!</b>"))
			playsound(get_turf(src), 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
			qdel(W)
			return
		else
			handle_offering(W, user, params)


			// place_on(W, user, params)

	attack_hand(mob/user)
		if (user.is_hulk() && user:a_intent != INTENT_HELP)
			user.visible_message(SPAN_ALERT("[user] tries to destroy the table!"))
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
			user.bioHolder.RemoveEffect("hulk")
			user.changeStatus("knockdown", 30 SECONDS)
			boutput(user, SPAN_ALERT("<b>We are not amused [user]..."))
			SPAWN(1 SECONDS)
				playsound(src.loc, 'sound/effects/dramatic.ogg', 100, 1)

			SPAWN(5 SECONDS)
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					H.sever_limb("l_arm")
					H.sever_limb("r_arm")
			message_admins("Someone tried to hulk smash the eldritch altar. Hopefully it was funny. - Kyle")

		else if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.a_intent == INTENT_HARM)
				H.changeStatus("knockdown", 6 SECONDS)
				boutput(user, SPAN_ALERT("<b>[user], this is a sacred altar, show a little respect..."))
				playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_3.ogg', 100, 1)
				take_bleeding_damage(H, H, rand(5,15), DAMAGE_STAB)

				//start taking their organs...
				var/count = 0
				while (BOUNDS_DIST(H, src) == 0)
					sleep(2 SECONDS)
					var/organ
					if (BOUNDS_DIST(H, src) == 0 && count <= 4)
						organ = H.organHolder.drop_organ(pick("left_eye","right_eye","left_lung","right_lung","butt","left_kidney","right_kidney","liver","stomach","intestines","spleen","pancreas","appendix"))
					if (!organ)
						break;
				return
			//attempt to activate the thing
			try{
				attempt_activate(user)
			} catch (var/e){
				. = e
				logTheThing(LOG_DEBUG, null, "kyle - spooktober altar broke: [e].")
				//clear offerings
				for (var/obj/O in left_offerings)
					src.vis_contents -= O
					O.vis_flags = initial(O.vis_flags)
					qdel(O)
				for (var/obj/O in right_offerings)
					src.vis_contents -= O
					O.vis_flags = initial(O.vis_flags)
					qdel(O)

				right_offerings.len = 0
				left_offerings.len = 0
				src.contents.len = 0

				active = 0
			}

		//if (place hand on sacrificum), Start removing organs for the sacrifice. Start with the arms that touches it.



	proc/handle_offering(var/obj/item/W, var/mob/user, var/params)
		var/side = "left"
		if (params)
			var/pixel_coord_x = text2num(params["icon-x"])
			var/vis_x = text2num(params["vis-x"])
			if (!isnull(vis_x))
				pixel_coord_x += vis_x + 16
			side = (pixel_coord_x > 32) ? "right" : "left"		//left is sacrifice, right is spacebux

			W.pixel_x = pixel_coord_x - 16
			W.pixel_y = rand(2, 12)

		user.drop_item()
		W.set_loc(src)
		W.vis_flags = VIS_INHERIT_ID
		// W.transform = matrix(0.75, MATRIX_SCALE)	//idk about scaling em down. would be a weird thing I guess. Even if I think it looks neater
		src.vis_contents += W
		animate_float(W, loopnum = -1, floatspeed = 15)
		switch(side)
			if ("left")
				left_offerings += W
			if ("right")
				right_offerings += W
		boutput(user, SPAN_NOTICE("<b>You place [W] on the [side] side of [src]."))


	proc/attempt_activate(var/mob/M)
		if (active)
			// SPAWN(2 SECONDS)
			// 	active = 0
			return
		flick("altar-awake", src)
		//here we loop through all the offerings and tally them.
		var/tally_strength = 0
		var/tally_spacebux = 0
		//this means nothing on either side.
		if((islist(left_offerings) && !length(left_offerings)) && (islist(right_offerings) && !length(right_offerings)))
			//hurt user maybe
			M.changeStatus("knockdown", 6 SECONDS)
			//todo hitpunch sound. threatening message

			M.throw_at(get_edge_target_turf(src, get_dir(src, M)), 2, 1)
			boutput(M, SPAN_ALERT("<b>Uhhh [M], Stop wasting my time, why are you activating my altar without offering a sacrifice..."))
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 100, 1)
			random_brute_damage(M, rand(10,30))
			return

		active = 1
		for(var/obj/O in left_offerings)
			if(istype(O,/obj/item/currency/spacecash))
				tally_strength += round(O:amount / 1000)

			if(istype(O,/obj/item/parts/human_parts))
				var/obj/item/parts/human_parts/part = O
				if(part.kind_of_limb & (LIMB_PLANT | LIMB_ROBOT)) continue //Can't sacrifice robot or syntharms

				tally_strength += 1

			if(istype(O,/obj/item/organ))
				var/obj/item/organ/organ = O
				if (organ.robotic || organ.synthetic || organ.broken) continue
				var/mult = 1
				if (organ.get_damage() > organ.fail_damage)
					mult = 0.5
				tally_strength += 1*mult

			// if(istype(O,/obj/item/spiritshard))
			// 	var/obj/item/spiritshard/S = O
			// 	tally_strength += S.storedStrength
			//doing this cause of vis_contents bugs. make it be worth a bit less.
			if (istype(O, /obj/item/currency/spacebux))
				var/obj/item/currency/spacebux/S = O
				if (S.spent) continue
				tally_spacebux += (S.amount*0.75)



		for (var/obj/item/currency/spacebux/S in right_offerings)
			if (S.spent) continue
			tally_spacebux += S.amount


		// Here we pick the item based on the tallied numbers
		var/path_to_spawn
		var/chalk_use_mult = 0.25

		var/select_item = tally_spacebux + min(min(tally_strength*300, 1900), tally_spacebux)

		switch(select_item)
			if (-INFINITY to 300)
				//nothing, harm the user for their insolence
				M.changeStatus("knockdown", 10 SECONDS)
				M.throw_at(get_edge_target_turf(src, get_dir(src, M)), 3, 1)
				var/pick = pick("Sickening", "Gross", "Disgraceful", "Boring", "Sad", "Disappointing", "Disgusting", "Weird")
				boutput(M, SPAN_ALERT("<b>You call that an offering [M]? [pick]..."))

				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 100, 1)
				M.throw_at(get_edge_target_turf(src, get_dir(src, M)), 1, 1)

			if (101 to 400)
				path_to_spawn =  /obj/item/ritualskull
			if (401 to 800)
				path_to_spawn = /obj/item/paper/rituals
			if (801 to 1300)
				path_to_spawn = /obj/item/thaumometer
			if (1301 to 1992)
				path_to_spawn =  /obj/item/sacdagger
			if (1993 to 4000)
				path_to_spawn = /obj/item/ritualChalk/randomColor
				chalk_use_mult = 0.5
			if (4001 to 6500)
				path_to_spawn = /obj/item/ritualChalk/randomColor
				chalk_use_mult = 0.75
			if (6501 to INFINITY)
				path_to_spawn = /obj/item/ritualChalk
				chalk_use_mult = 2

		var/obj/obj_to_spawn
		if (!isnull(path_to_spawn))
			obj_to_spawn = new path_to_spawn(src.loc)

		if (!istype(get_area(src), /area/station/chapel))
			tally_strength = tally_strength*0.70
		tally_strength = round(tally_strength)

		var/uses = 0
		switch(tally_strength)
			if (-INFINITY to 0) uses = 30
			if (1 to 3) uses = 90
			if (4 to 6) uses = 180
			if (7 to 13) uses = 300
			if (14 to 21) uses = 270
			if (22 to 29) uses = 220
			if (30 to 49) uses = 190
			if (50 to INFINITY) uses = 500
		if (ispath(path_to_spawn, /obj/item/ritualChalk))
			var/obj/item/ritualChalk/chalk = obj_to_spawn
			uses = round(uses*chalk_use_mult)
			chalk.uses = uses
			var/obj/manual = new/obj/item/paper/rituals(src.loc)
			SPAWN(3 SECONDS)
				manual.throw_at(M, 7, 0.4)

		if (!isnull(obj_to_spawn))
			spawn_animation1(obj_to_spawn)
			SPAWN(2 SECONDS)
				obj_to_spawn.throw_at(M, 7, 2)

		var/shard_power = 1
		if (select_item > 2500)
			if (M.health < 0)
				if (M.health < -100)
					shard_power = 8
				else
					shard_power = 5
			else
				shard_power = min((M.max_health-M.health/M.max_health)*5, 5)

			var/obj/item/spiritshard/shard = new(src.loc,newRitualVars(shard_power, shard_power))
			SPAWN(rand(1,40))
				var/turf/rand_target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))
				shard.throw_at(rand_target, rand(2,7), 1)

		//destroy items in lists.


		//just look through both lists, play an animation and remove em.
		//again, let me be lazy. DON'T LOOK AT THIS CODE, ESPECIALLY THE SLEEPS. DON'T! - Kyle
		for (var/obj/O in left_offerings)
			sleep(rand(0,2))
			SPAWN(-1)
				leaving_animation(O)
				src.vis_contents -= O
				O.vis_flags = initial(O.vis_flags)
				sleep(15)
				qdel(O)
		for (var/obj/O in right_offerings)
			sleep(rand(0,2))
			if (istype(O, /obj/item/currency/spacebux))
				var/obj/item/currency/spacebux/S = O
				S.spent = 1
			SPAWN(-1)
				leaving_animation(O)
				src.vis_contents -= O
				O.vis_flags = initial(O.vis_flags)
				sleep(15)
				qdel(O)
		spacebux_consumed_round += tally_spacebux
		//right_offerings = list()
		//left_offerings = list()
		//src.contents = list()
		right_offerings.len = 0
		left_offerings.len = 0
		src.contents.len = 0


		//if successfull. spawn item and show archive spacebux
		active = 0

	proc/get_spacebux()

	proc/get_sacrifices()

	// hear_talk(mob/M as mob, text, real_name)
	// 	if (lowertext(text) == "sacrificum")
	// 		attempt_activate(M)
	// 	return

	//stolen from talbe, this is kinda a table of sorts...
	Cross(atom/movable/mover)
		if (!src.density || (mover.flags & TABLEPASS || istype(mover, /obj/newmeteor)) )
			return 1
		else
			return 0

	disposing()
		world.save_intra_round_value("altar_spacebux_consumed", spacebux_consumed_total+spacebux_consumed_round)
		UnregisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_REBOOT)
		..()

	//the altar doesn't tolerate getting harmed, it just leaves.
	ex_act(severity)
		if (severity)
			leaving_animation(src)
			SPAWN(1.5 SECONDS)
				qdel(src)

	blob_act(var/power)
		leaving_animation(src)
		SPAWN(1.5 SECONDS)
			qdel(src)

	meteorhit()
		leaving_animation(src)
		SPAWN(1.5 SECONDS)
			qdel(src)

#endif
