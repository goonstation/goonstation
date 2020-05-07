//////////////////////////////////////////////////////////////
// stupid rassumfrassum no good
//////////////////////////////////////////////////////////////
/proc/uppertext_proxy(match) // FUCKIN' BYOND
		. = uppertext(match)



//////////////////////////////////////////////////////////////
// PATHFINDING STUFF
//////////////////////////////////////////////////////////////
/turf/proc/AllDirsTurfsCritter(var/obj/critter/C)
	var/L[] = new()

	//  for(var/turf/simulated/t in oview(src,1))
	var/CT = get_turf(C)
	for(var/d in alldirs)
		var/turf/simulated/T = get_step(src, d)
		//if(istype(T) && !T.density)
		if (T && T.pathable && !T.density)
			if(!LinkBlockedForCritters(CT, T, C))
				L.Add(T)
	return L

/proc/LinkBlockedForCritters(turf/A, turf/B, obj/critter/C)

	if(A == null || B == null) return 1
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if((adir & (NORTH|SOUTH)) && (adir & (EAST|WEST)))  //  diagonal
		var/iStep = get_step(A,adir&(NORTH|SOUTH))
		if(!LinkBlockedForCritters(A,iStep, C) && !LinkBlockedForCritters(iStep,B,C))
			return 0

		var/pStep = get_step(A,adir&(EAST|WEST))
		if(!LinkBlockedForCritters(A,pStep,C) && !LinkBlockedForCritters(pStep,B,C))
			return 0
		return 1

	if(DirBlockedForCritters(A,adir, C))
		return 1

	if(DirBlockedForCritters(B,rdir, C))
		return 1

	for (var/atom/O in B.contents)
		if (O.density && !(O.flags & ON_BORDER))
			if (istype(O, /obj/machinery/door))
				var/obj/machinery/door/D = O
				if (D.isblocked())
					return 1
				return 0
			if (ismob(O))
				var/mob/M = O
				if (M.anchored)
					return 1
				return 0
			return 1

	return 0

// Returns true if direction is blocked from loc
// If critters can open doors the direction is not considered blocked
/proc/DirBlockedForCritters(turf/loc,var/dir,var/obj/critter/C)
	var/blocked = 0

	for (var/obj/window/D in loc)
		if (D.density && D.dir == dir)
			blocked = 1
		if (D.density && !(D.flags & ON_BORDER))
			blocked = 1

	for (var/obj/machinery/door/D in loc)
		if (D.isblocked())
			blocked = 1
		if (istype(D, /obj/machinery/door/window))
			if (dir & D.dir)
				if (D.density && C.opensdoors == 0)
					blocked = 1
		else
			if (D.density && C.opensdoors == 0)
				blocked = 1

	return blocked

//////////////////////////////////////////////////////////////
// Critter data extension (avoiding pollution of critter vars)
//////////////////////////////////////////////////////////////
// TODO: name this fucker better
var/global/datum/critterDataAccess/intruderCritterDefinitions = new()
/datum/critterDataAccess

	var/list/critterExtraData

	New()
		..()
		critterExtraData = src.getValues()

	proc/getValues()
		. = list()
		var/types = typesof(/datum/critterData)
		DEBUG_MESSAGE("[html_encode(list2params(types))]")
		for(var/T in types)
			var/datum/critterData/instance = new T()
			var/subtypes = typesof(instance.assocPath)
			DEBUG_MESSAGE("[html_encode(list2params(subtypes))]")
			for(var/ST in subtypes)
				.[ST] = instance
				DEBUG_MESSAGE("[ST] - [instance]")

	proc/getCritterData(critterType)
		if(critterType in critterExtraData)
			return critterExtraData[critterType]
		else
			return critterExtraData[/obj/critter]


/datum/critterData
	var/portrait = "temp_portrait_generic"
	var/assocSound = "sound/machines/chime_1.ogg"
	var/assocPath = /obj/critter
	// more data to come

/datum/critterData/roach
	portrait = "temp_portrait_roach"
	assocSound = "sound/intrusion/critter_roach.ogg"
	assocPath = /obj/critter/roach

/datum/critterData/mouse
	portrait = "temp_portrait_mouse"
	//assocSound = "sound/intrusion/critter_mouse.ogg"
	assocPath = /obj/critter/mouse

/datum/critterData/bee
	portrait = "temp_portrait_bee"
	assocSound = "sound/intrusion/critter_bee.ogg"
	assocPath = /obj/critter/domestic_bee

/datum/critterData/wasp
	portrait = "temp_portrait_wasp"
	assocSound = "sound/intrusion/critter_bee.ogg"
	assocPath = /obj/critter/spacebee

/datum/critterData/cat
	portrait = "temp_portrait_cat"
	assocSound = "sound/effects/cat.ogg"
	assocPath = /obj/critter/cat

/datum/critterData/dog
	portrait = "temp_portrait_dog"
	assocSound = "sound/misc/dogbark.ogg"
	assocPath = /obj/critter/dog

/datum/critterData/parrot
	portrait = "temp_portrait_bird"
	assocSound = "sound/intrusion/critter_parrot.ogg"
	assocPath = /obj/critter/parrot

/datum/critterData/plasma_spore
	portrait = "temp_portrait_spore"
	assocSound = "sound/intrusion/critter_plasma_spore.ogg"
	assocPath = /obj/critter/spore

/datum/critterData/spider
	portrait = "temp_portrait_spider"
	assocSound = "sound/intrusion/critter_spider.ogg"
	assocPath = /obj/critter/spider

/datum/critterData/bumblespider
	portrait = "temp_portrait_bumblespider"
	assocSound = "sound/intrusion/critter_spider.ogg"
	assocPath = /obj/critter/nicespider

/datum/critterData/owl
	portrait = "temp_portrait_owl"
	assocSound = "sound/misc/hoot.ogg"
	assocPath = /obj/critter/owl


//////////////////////////////////////////////////////////////
// The actual mob itself!!
//////////////////////////////////////////////////////////////
/mob/living/intangible/intruder
	name = "Eldritch Intruder"
	real_name = "Eldritch Intruder"
	desc = "Weird!"
	icon = 'icons/mob/intruder.dmi'
	icon_state = "intruder"

	layer = NOLIGHT_EFFECTS_LAYER_BASE
	density = 0
	canmove = 1
	blinded = 0
	anchored = 1

	mob_flags = SPEECH_INTRUDER

	var/color1 = rgb(100, 90, 165)
	var/color2 = rgb(100, 220, 175)
	var/image/baseImage
	var/image/accentImage

	var/datum/hud/intruder/hud

	var/obj/critter/selected
	var/image/selectedImage

	var/list/structures = list()
	var/obj/intrusionStructure/spire/spire = null

	// TODO: put this in a textfile
	var/list/nameParts = list("hand", "eye", "tendril", "claw", "extension", "protrusion", "maw", "will")
	var/list/nameAdjectives = list("clear", "clean", "crystalline", "cloudy", "thundering", "lightning",
		"born", "aged", "warped", "ethereal", "alien", "wild", "whispered", "fell",
		"starborne", "known", "coral", "nameless", "voiceless", "shimmering")
	var/list/nameConcepts = list("song", "stanza", "liturgy", "sonnet", "poem", "contemplation", "idea", "home", "hive", "colony", "pool", "voice", "name")
	var/list/nameVerb = list("scry", "delay", "wander", "sing", "watch", "dream", "know", "drift", "seek", "abandon")
	var/list/nameVerbs = list("scries", "delays", "wanders", "sings", "watches", "dreams", "knows", "drifts", "seeks", "abandons")
	var/list/nameVerbing = list("scrying", "delaying", "wandering", "singing", "watching", "dreaming", "knowing", "drifting", "seeking", "abandoning")
	var/list/nameTemplates = list("%ADJ%ADJ %CONCEPT of %VERBING", "%ADJ %ADJ%CONCEPT which %VERBS", "%ADJ %VERB to %ADJ%CONCEPT", "%ADJ%VERBING %ADJ%CONCEPT")



	proc/generateName()
		. = ""
		var/template = pick(nameTemplates)
		for(var/i=1, i<=length(template), i++)
			var/char = copytext(template,i,i+1)
			if(char == "%")
				if(copytext(template, i+1, i+4) == "ADJ")
					. += pick(nameAdjectives)
					i = i+3
					continue
				if(copytext(template, i+1, i+8) == "CONCEPT")
					. += pick(nameConcepts)
					i = i+7
					continue
				if(copytext(template, i+1, i+8) == "VERBING")
					. += pick(nameVerbing)
					i = i+7
					continue
				if(copytext(template, i+1, i+6) == "VERBS")
					. += pick(nameVerbs)
					i = i+5
					continue
				if(copytext(template, i+1, i+5) == "VERB")
					. += pick(nameVerb)
					i = i+4
					continue
			else
				. += char


		//var/list/bag = nameConcepts.Copy()
		//var/words = rand(3,6)
		//for(var/i=0, i<words, i++)
		//  var/word = pick(bag)
		//  . += "[word][prob(50) ? "" : " "]"
		//  bag -= word

		// remove trailing spaces
		. = trim(.)
		// capitalise isolated letters
		var/regex/getWordStarts = new("\\b\\S", "g")
		. = getWordStarts.Replace(., /proc/uppertext_proxy)




	New()
		. = ..()

		src.real_name = generateName()
		src.name = "[pick(nameParts)] of [src.real_name]"

		src.invisibility = 10
		src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
		src.see_invisible = 15
		src.see_in_dark = SEE_DARK_FULL

		src.abilityHolder = new /datum/abilityHolder/intruder(src)
		src.addAllAbilities()

		src.baseImage = image('icons/mob/intruder.dmi', icon_state="intruder-base-1", layer=MOB_LAYER_BASE)
		src.accentImage = image('icons/mob/intruder.dmi', icon_state="intruder-accent-1", layer=MOB_LAYER_BASE)

		hud = new(src)
		src.attach_hud(hud)
		src.updateColors(color1, color2)

		src.blend_mode = BLEND_ADD

		src.selected = null
		src.selectedImage = image('icons/ui/intruder_ui.dmi', icon_state="selected", layer=HUD_LAYER)
		src.selectedImage.color = color1
		src.selectedImage.blend_mode = BLEND_ADD

	proc/updateColors(var/col1, var/col2)
		src.overlays -= baseImage
		src.overlays -= accentImage
		src.color1 = col1
		src.color2 = col2
		src.baseImage.color = col1
		src.accentImage.color = col2
		src.overlays += baseImage
		src.overlays += accentImage
		src.hud.updateColors(col1, col2)

	Login()
		..()
		abilityHolder.updateButtons()
		src.client.show_popup_menus = 0


	Logout()
		if(src)
			if(src.client)
				src.client.show_popup_menus = 1
				src.client.images -= src.selectedImage
		..()

	is_spacefaring()
		return true

	movement_delay()
		return 1

	Life(parent)
		if (..(parent))
			return 1
		if(istype(src.selected))
			src.selectedImage.loc = src.selected.loc
			if(src.selectedImage.color != color1 && src.selected.task == "thinking")
				src.selectedImage.color = color1


	say_quote(var/text)
		var/speechverb = pick("sings", "chimes", "breezes", "flows", "gusts", "crackles", "shines", "echoes", "turns")
		return "[speechverb], [gradientText(color1, color2, "\"[text]\"")]"

	get_heard_name()
		return "<span class='name' data-ctx='\ref[src.mind]'>[src.real_name]</span>"

	// forgive me for duplicating more code unnecessarily
	emote(var/act, var/voluntary = 0)
		var/message = ""
		var/m_type = 0
		if (!message)
			switch (lowertext(act))
				if ("dance")
					if (src.emote_check(voluntary, 50))
						m_type = 1
						message = "<b>[src]</b> waves around a bit, not really understanding dance or rhythm."
						animate_weird(src)
				if ("scream")
					if (src.emote_check(voluntary, 50))
						m_type = 2
						var/descriptor = pick("a weird", "a strange", "an unnatural", "a baffling", "a disconcerting", "a painful",
							"a twisting", "some weird", "an unsettling", "a distorted")
						message = "<b>[src]</b> makes [descriptor] noise!"
						playsound(get_turf(src), "sound/cirr/intruder_scream[rand(1,11)].ogg", 50, 1, 1)
				if ("flip")
					if (src.emote_check(voluntary, 50) && !src.shrunk)
						m_type = 1
						message = "<B>[src]</B> does a flip!"
						if (prob(50))
							animate_spin(src, "R", 1, 0)
						else
							animate_spin(src, "L", 1, 0)
		if (message)
			logTheThing("say", src, null, "EMOTE: [message]")
			if (m_type & 1)
				for (var/mob/O in viewers(src, null))
					O.show_message(message, m_type)
			else if (m_type & 2)
				for (var/mob/O in hearers(src, null))
					O.show_message(message, m_type)
			else if (!isturf(src.loc))
				var/atom/A = src.loc
				for (var/mob/O in A.contents)
					O.show_message(message, m_type)


	click(atom/target, params)
		. = ..()
		if(params["left"])
			if(istype(target, /obj/critter))
				var/obj/critter/C = target
				selectCritter(C)
			else
				deselect()
		if(params["right"])
			giveCommand(target, "moveTo")



	Move(NewLoc, direct)
		src.dir = get_dir(src, NewLoc)
		src.baseImage.dir = src.dir
		src.accentImage.dir = src.dir
		..()


	proc/selectCritter(obj/critter/C, var/play_sound=1)
		var/datum/critterData/CD = intruderCritterDefinitions.getCritterData(C.type)
		//if(istype(src.selected))
			// clean up existing image?
		src.selected = C
		src.selected.selected = 1
		src.selectedImage.loc = src.selected.loc
		src.client.images += src.selectedImage
		hud.changePortrait(CD.portrait)
		if(play_sound)
			playsound_local(src, CD.assocSound, 60, 1, -1)
		if(src.selected.task == "following path")
			src.selectedImage.color = color2

	proc/deselect()
		src.client.images -= src.selectedImage
		if(istype(src.selected))
			src.selected.selected = 0
			src.selected = null
		src.selectedImage.color = color1
		hud.changePortrait("temp_portrait_entity")

	proc/giveCommand(var/atom/target, var/command="move")
		if(!src.selected) return // not sure how we got here, but better safe than sorry
		if(!src.spire)
			boutput(src, "<span class='alert'>Your presence is too weak to command anything, you must place a spire first.</span>")
			return
		var/datum/critterData/CD = intruderCritterDefinitions.getCritterData(src.selected.type)
		switch(command)
			if ("moveTo")
				playsound_local(src, CD.assocSound, 60, 1, -1, 0.8)
				src.selected.followed_path = AStar(get_turf(src.selected), get_turf(target), /turf/proc/AllDirsTurfsCritter, /turf/proc/Distance, adjacent_param = src.selected)
				src.selected.followed_path_retry_target = target.loc
				src.selected.task = "following path"
				src.selectedImage.color = color2
				visualisePath(src.client, src.selected.followed_path)

	proc/addAllAbilities()
		src.addAbility(/datum/targetable/intruderAbility/setColors)
		src.addAbility(/datum/targetable/intruderAbility/createStructure/spire)

	proc/addAbility(var/abilityType)
		abilityHolder.addAbility(abilityType)

	proc/removeAbility(var/abilityType)
		abilityHolder.removeAbility(abilityType)

	ghostize()
		deselect()
		src.client.show_popup_menus = 1
		return ..()


/mob/living/intangible/intruder/proc/build(var/structure_path, var/turf/T)
	if(src.can_build(structure_path, T))
		var/obj/intrusionStructure/S = new structure_path(T)
		src.structures |= S
		S.post_construct(src)

/mob/living/intangible/intruder/proc/can_build(var/structure_path, var/turf/T)
	// if structure isn't freestanding, do orthogonal check
	// TODO: othogonal check

	// if we already have too many, don't build
	var/count = 0
	for (var/obj/intrusionStructure/I in structures)
		if(I.type == structure_path)
			count++
	if(count >= initial(structure_path:max)) // if you can figure out how to typecast a type, let me know ok
		boutput(src, "<span class='alert'>You can't bring any more of these into this reality.</span>")
		return 0

	// check tile is clear
	if (T.density)
		boutput(src, "<span class='alert'>The [T] is too solid to forge through.</span>")
		return 0
	for (var/obj/O in T)
		if (O.density)
			boutput(src, "<span class='alert''>The [O] is too solid to forge through.</span>")
			return 0
	return 1


//////////////////////////////////////////////////////////////
// Intruder UI stuff
//////////////////////////////////////////////////////////////
/datum/hud/intruder
	var/mob/living/intangible/intruder/master

	var/obj/screen/hud/portrait
	var/image/cloud1
	var/image/cloud2

	New(M)
		master = M
		createPortrait()

	proc/createPortrait()
		portrait = create_screen("portrait", "portrait", 'icons/ui/intruder_portrait_ui.dmi', "temp_portrait_entity", "WEST,SOUTH", HUD_LAYER+1, tooltipTheme = "wraith")
		portrait.underlays += image('icons/ui/intruder_portrait_ui.dmi', icon_state="backdrop", layer=FLOAT_LAYER - 3)
		cloud1 = image('icons/ui/intruder_portrait_ui.dmi', icon_state="cloud1", layer=FLOAT_LAYER - 2)
		cloud2 = image('icons/ui/intruder_portrait_ui.dmi', icon_state="cloud2", layer=FLOAT_LAYER - 1)
		portrait.overlays += image('icons/ui/intruder_portrait_ui.dmi', icon_state="frame", layer=FLOAT_LAYER )
		portrait.name = "portrait"
		portrait.desc = "temp_portrait_entity"

	proc/updateColors(var/col1, var/col2)
		portrait.underlays -= cloud1
		portrait.underlays -= cloud2
		cloud1.color = col1
		cloud2.color = col2
		cloud1.blend_mode = BLEND_ADD
		cloud2.blend_mode = BLEND_MULTIPLY
		portrait.underlays += cloud1
		portrait.underlays += cloud2

	proc/changePortrait(var/portrait_name)
		portrait.icon_state = portrait_name
		portrait.desc = portrait_name

	clicked(id, mob/user, list/params)
		boutput("id: [id] - params: [url_decode(list2params(params))]")
		//if(id == "portrait")
			//boutput(url_decode(list2params(params)))






//////////////////////////////////////////////////////////////
// Intruder abilities!
//////////////////////////////////////////////////////////////
/datum/abilityHolder/intruder
	topBarRendered = 1


/obj/screen/ability/topBar/intruder
	tens_offset_x = 19
	tens_offset_y = 7
	secs_offset_x = 23
	secs_offset_y = 7


/datum/targetable/intruderAbility
	icon = 'icons/mob/wraith_ui.dmi'
	icon_state = "template"
	cooldown = 0
	last_cast = 0
	targeted = 1
	target_anything = 1
	preferred_holder_type = /datum/abilityHolder/intruder

	New()
		var/obj/screen/ability/topBar/intruder/B = new /obj/screen/ability/topBar/intruder(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B

	cast(atom/target)
		if (!holder || !holder.owner)
			return 1
		return 0

	doCooldown()
		if (!holder)
			return
		last_cast = world.time + cooldown
		holder.updateButtons()
		SPAWN_DBG(cooldown + 5)
			holder.updateButtons()


/datum/targetable/intruderAbility/setColors
	name = "Set Color"
	desc = "Choose the color your cosmic presence radiates. This will be removed once you place your Spire."
	targeted = 0

	cast(atom/target)
		if(..())
			return 1
		//var/color1 = input("Select your Base Color", "Base") as color
		//var/color2 = input("Select your Accent Color", "Accent") as color
		var/color = input("Select your Color", "Color") as color
		var/mob/living/intangible/intruder/I = holder.owner
		I.updateColors(color, complementarycolor(color))



/datum/targetable/intruderAbility/createStructure
	name = "Forge Structure"
	desc = "You shouldn't see this. Please flag a coder."
	targeted = 1
	var/structure = /obj/intrusionStructure

	cast(atom/target)
		if(..())
			return 1
		var/turf/T = get_turf(target)
		var/mob/living/intangible/intruder/I = holder.owner
		if(structure)
			I.build(structure, T)

/datum/targetable/intruderAbility/createStructure/spire
	name = "Emerge Spire"
	desc = "Manifest the anchor of your presence in this reality."
	structure = /obj/intrusionStructure/spire

//////////////////////////////////////////////////////////////
// Intruder structures
//////////////////////////////////////////////////////////////




// Base ////////////////////////////////////////////////////

/obj/intrusionStructure
	name = "fire cirr into the sun"
	desc = "no seriously fire him into the sun you shouldn't see this"
	icon = 'icons/obj/intruder_structures.dmi'
	var/freestanding = 0 // does this structure need to be aligned with a previous one?
	var/max = -1 // if this is -1, there's no max, otherwise there is a max, and 0 means can't build

/obj/intrusionStructure/proc/post_construct(var/mob/living/intangible/intruder/builder)

// Spire ///////////////////////////////////////////////////

/obj/intrusionStructure/spire
	name = "Spire"
	desc = "The anchor of your material presence."
	icon_state = "spire"
	freestanding = 1 // we kind of need to be able to place the spire anywhere
	max = 1

/obj/intrusionStructure/spire/post_construct(var/mob/living/intangible/intruder/builder)
	// no more colour changes for you, you've begun
	builder.removeAbility(/datum/targetable/intruderAbility/setColors)
	builder.spire = src











//////////////////////////////////////////////////////////////
// Transform procs
//////////////////////////////////////////////////////////////

// GUESS WHO STOLE THIS FROM WRAITH
// IT'S ME CIRR
/mob/proc/intruderize()
	if (src.mind || src.client)
		message_admins("[key_name(usr)] made [key_name(src)] an intruder.")
		logTheThing("admin", usr, src, "made %target% an intruder.")
		return make_intruder()
	return null

/mob/proc/make_intruder()
	if (src.mind || src.client)
		var/mob/living/intangible/intruder/O = new/mob/living/intangible/intruder(src)

		var/turf/T = get_turf(src)
		if (!(T && isturf(T)) || ((isrestrictedz(T.z) || T.z != 1) && !(src.client && src.client.holder)))
			var/OS = observer_start.len ? pick(observer_start) : locate(1, 1, 1)
			if (OS)
				O.set_loc(OS)
			else
				O.z = 1
		else
			O.set_loc(T)

		if (src.mind)
			src.mind.transfer_to(O)
		else
			var/key = src.client.key
			if (src.client)
				src.client.mob = O
			O.mind = new /datum/mind()
			O.mind.key = key
			O.mind.current = O
			ticker.minds += O.mind
		src.loc = null

		var/this = src
		src = null
		qdel(this)

		//W.addAllAbilities()
		boutput(O, "<B>You are an intruder! Click critters to select them and right click to move them!</B>")
		//boutput(W, "Your astral powers enable you to survive one banishment. Beware of salt.")
		//boutput(W, "Use the question mark button in the lower right corner to get help on your abilities.")

		return O
	return null

//////////////////////////////////////////////////////////////
// misc helper procs
//////////////////////////////////////////////////////////////

/proc/complementarycolor(var/color)
	var/r = hex2num(copytext(color, 2, 4))
	var/g = hex2num(copytext(color, 4, 6))
	var/b = hex2num(copytext(color, 6))
	DEBUG_MESSAGE("rgb: [r] [g] [b]")
	var/list/hsv = rgb2hsv(r, g, b)
	DEBUG_MESSAGE("hsv: [hsv[1]] [hsv[2]] [hsv[3]]")
	hsv[1] += 180 // rotate the hue by 180 i think
	if(hsv[1] > 360) hsv[1] -= 360
	DEBUG_MESSAGE("comp hsv: [hsv[1]] [hsv[2]] [hsv[3]]")
	var/list/rgb = hsv2rgblist(hsv[1], hsv[2], hsv[3])
	DEBUG_MESSAGE("comp rgb: [rgb[1]] [rgb[2]] [rgb[3]]")
	. = rgb(rgb[1], rgb[2], rgb[3])





//////////////////////////////////////////////////////////////
// Path visualisation stuff
//////////////////////////////////////////////////////////////


/client/var/list/Visualised_Path
/client/var/list/Pathing_Images
/proc/visualisePath(var/client/C, var/list/path)
	if(!path)
		boutput("No path to show.")
	C.Visualised_Path = path
	C.images -= C.Pathing_Images
	C.Pathing_Images = list()
	SPAWN_DBG(0)
		if(path)
			for(var/i = 2, i < path.len, i++)
				if(!C.Visualised_Path) break
				var/turf/prev = path[i-1]
				var/turf/t = path[i]
				var/turf/next = path[i+1]
				var/image/img = image('icons/obj/power_cond.dmi')
				img.loc = t
				img.layer = 101
				img.color = "#5555ff"
				var/D1=turn(angle2dir(get_angle(next, t)),180)
				var/D2=turn(angle2dir(get_angle(prev,t)),180)
				if(D1>D2)
					D1=D2
					D2=turn(angle2dir(get_angle(next, t)),180)
				img.icon_state = "[D1]-[D2]"
				C.images += img
				C.Pathing_Images[++C.Pathing_Images.len] = img
				img.alpha=0
				var/matrix/xf = matrix()
				img.transform = xf/2
				animate(img,alpha=255,transform=xf,time=2)
				sleep(0.1 SECONDS)
