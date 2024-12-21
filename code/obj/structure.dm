/obj/structure
	icon = 'icons/obj/structures.dmi'
	var/projectile_passthrough_chance = 0

	girder
		icon_state = "girder"
		anchored = ANCHORED
		density = 1
		material_amt = 0.2
		var/state = 0
		projectile_passthrough_chance = 50
		desc = "A metal support for an incomplete wall."
		HELP_MESSAGE_OVERRIDE({"
			You can use a <b>crowbar</b> to displace it,
			add metal to finish the wall,
			or add reinforced metal to make the girder stronger.
		"})

		displaced
			name = "displaced girder"
			icon_state = "displaced"
			anchored = UNANCHORED
			projectile_passthrough_chance = 70
			desc = "An unsecured support for an incomplete wall."
			HELP_MESSAGE_OVERRIDE({"
				You can use a <b>screwdriver</b> to seperate the metal into sheets,
				or add metal or reinforced metal to turn it into fake wall that can opened by hand.
			"})

		reinforced
			name = "reinforced girder"
			icon_state = "reinforced"
			state = 2
			projectile_passthrough_chance = 30
			desc = "A reinforced metal support for an incomplete wall."
			get_help_message(dist, mob/user)
				if (src.state == 2)
					. = {"You can use a <b>screwdriver</b> to unscrew the support struts,"}
				else if (src.state == 1)
					. = {"You can use a pair of <b>wirecutters</b> to cut the support struts,"}
				. += "\nor add reinforced metal to finish the reinforced wall."

	blob_act(var/power)
		if (prob(power))
			qdel(src)

	meteorhit(obj/O as obj)
		qdel(src)

obj/structure/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if(prob(50))
				qdel(src)
				return
		if(3)
			return
	return

/obj/structure/girder/Cross(obj/projectile/mover)
	if (istype(mover) && !mover.proj_data.always_hits_structures && prob(src.projectile_passthrough_chance))
		return TRUE
	return (!density)

/obj/structure/girder/attack_hand(mob/user)
	if (user.is_hulk())
		if (prob(50))
			playsound(user.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
			src.material_trigger_when_attacked(src, user, 1)
			for (var/mob/N in AIviewers(user, null))
				if (N.client)
					shake_camera(N, 4, 1, 8)
		if (prob(80))
			boutput(user, SPAN_NOTICE("You smash through the girder."))
			logTheThing(LOG_COMBAT, user, "uses hulk to smash a girder at [log_loc(src)].")
			if (istype(src, /obj/structure/girder/reinforced))
				var/atom/A = new /obj/structure/girder(src)
				if (src.material)
					A.setMaterial(src.material)
				else
					var/datum/material/defaultMaterial = getMaterial("steel")
					A.setMaterial(defaultMaterial)
				qdel(src)
			else
				if (prob(30))
					var/atom/A = new /obj/structure/girder/displaced(src)
					if (src.material)
						A.setMaterial(src.material)
					else
						var/datum/material/defaultMaterial = getMaterial("steel")
						A.setMaterial(defaultMaterial)
				else
					qdel(src)

		else
			boutput(user, SPAN_NOTICE("You punch the [src.name]."))
			return
	..()

/obj/structure/girder/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W) && state == 0 && anchored && !istype(src, /obj/structure/girder/displaced))
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_DISASSEMBLE, null, user), user)


	else if (isscrewingtool(W) && state == 2 && istype(src, /obj/structure/girder/reinforced))
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_UNSECURESUPPORT, null, user), user)

	else if (issnippingtool(W) && istype(src, /obj/structure/girder/reinforced) && state == 1)
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_REMOVESUPPORT, null, user), user)

	else if (ispryingtool(W) && state == 0 && anchored )
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_DISLODGE, null, user), user)

	else if (iswrenchingtool(W) && state == 0 && !anchored )
		if (!istype(src.loc, /turf/simulated/floor/))
			boutput(user, SPAN_ALERT("Not sure what this floor is made of but you can't seem to wrench a hole for a bolt in it."))
			return
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_SECURE, null, user), user)
	else if (istype(W, /obj/item/sheet))
		var/obj/item/sheet/S = W
		if (S.amount < 2)
			boutput(user, SPAN_ALERT("You need at least two sheets on the stack to do this."))
			return

		if (src.icon_state != "reinforced" && S.reinforcement)
			actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_REINFORCE, null, user), user)
		else
			actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_PLATE, null, user), user)
	else
		..()

/datum/action/bar/icon/girder_tool_interact
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 3 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/structure/girder/the_girder
	var/obj/item/the_tool
	var/interaction = GIRDER_DISASSEMBLE

	New(var/obj/table/girdr, var/obj/item/tool, var/interact, var/duration_i, var/mob/user)
		..()
		if (girdr)
			the_girder = girdr
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (interact)
			interaction = interact
		if (duration_i)
			duration = duration_i
		if (ishuman(user))
			var/mob/living/carbon/human/H = user

			if (H.traitHolder.hasTrait("training_engineer"))
				duration = duration / 2

			else if (H.traitHolder.hasTrait("carpenter")) // It's so one nullifies the other. Carpenter and engineer training shouldn't stack up.
				duration = duration / 1.5

		var/mob/living/critter/robotic/bot/engibot/E = user
		if(istype(E))
			interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_MOVE
			duration = 1 DECI SECOND

	onUpdate()
		..()
		if (the_girder == null || the_tool == null || owner == null || BOUNDS_DIST(owner, the_girder) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && !equipped_or_holding(the_tool, source))
			interrupt(INTERRUPT_ALWAYS)
			return
		if (istype(source) && !equipped_or_holding(the_tool, source) && the_tool.amount >= 2 && interaction == GIRDER_PLATE)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		var/verbing = ""
		switch (interaction)
			if (GIRDER_DISASSEMBLE)
				verbing = "disassembling"
				playsound(the_girder, 'sound/items/Ratchet.ogg', 100, TRUE)
			if (GIRDER_UNSECURESUPPORT)
				verbing = "unsecuring support struts from"
				playsound(the_girder, 'sound/items/Screwdriver.ogg', 100, TRUE)
			if (GIRDER_REMOVESUPPORT)
				verbing = "removing support struts from"
				playsound(the_girder, 'sound/items/Wirecutter.ogg', 100, TRUE)
			if (GIRDER_DISLODGE)
				verbing = "dislodging"
				playsound(the_girder, 'sound/items/Crowbar.ogg', 100, TRUE)
			if (GIRDER_REINFORCE)
				verbing = "reinforcing"
			if (GIRDER_SECURE)
				playsound(the_girder, 'sound/items/Ratchet.ogg', 100, TRUE)
				verbing = "securing"
			if (GIRDER_PLATE)
				verbing = "plating"
		owner.visible_message(SPAN_NOTICE("[owner] begins [verbing] [the_girder]."))

	onEnd()
		..()
		var/verbens = "does something to"
		switch (interaction)
			if (GIRDER_DISASSEMBLE)
				verbens = "disassembles"
				playsound(the_girder, 'sound/items/Ratchet.ogg', 100, TRUE)
				var/atom/A = new /obj/item/sheet(get_turf(the_girder))
				if (the_girder.material)
					A.setMaterial(the_girder.material)
				else
					var/datum/material/defaultMaterial = getMaterial("steel")
					A.setMaterial(defaultMaterial)
				qdel(the_girder)
			if (GIRDER_UNSECURESUPPORT)
				verbens = "unsecured the support struts of"
				the_girder.state = 1
			if (GIRDER_REMOVESUPPORT)
				verbens = "removed the support struts of"
				var/atom/A = new/obj/structure/girder( the_girder.loc )
				if(the_girder.material) A.setMaterial(the_girder.material)
				qdel(the_girder)
			if (GIRDER_DISLODGE)
				verbens = "dislodged"
				var/atom/A = new/obj/structure/girder/displaced( the_girder.loc )
				if(the_girder.material) A.setMaterial(the_girder.material)
				qdel(the_girder)
			if (GIRDER_REINFORCE)
				verbens = "reinforced"
				var/atom/A = new/obj/structure/girder/reinforced( the_girder.loc )
				if (the_tool.material)
					A.setMaterial(the_girder.material)
				else
					var/datum/material/defaultMaterial = getMaterial("steel")
					A.setMaterial(defaultMaterial)
				qdel(the_girder)
			if (GIRDER_SECURE)
				if (!istype(the_girder.loc, /turf/simulated/floor/))
					owner.visible_message(SPAN_ALERT("You feel like your body is being ripped apart from the inside. Maybe you shouldn't try that again. For your own safety, I mean."))
					return
				verbens = "secured"
				var/atom/A = new/obj/structure/girder( the_girder.loc )
				if(the_girder.material) A.setMaterial(the_girder.material)
				qdel(the_girder)
			if (GIRDER_PLATE)
				verbens = "finishes plating"
				logTheThing(LOG_STATION, owner, "builds a Wall in [owner.loc.loc] ([log_loc(owner)])")
				var/turf/Tsrc = get_turf(the_girder)
				var/turf/simulated/wall/WALL
				var/obj/item/sheet/S = the_tool
				var/datum/material/defaultMaterial = getMaterial("steel")

				if (S.reinforcement)
					WALL = Tsrc.ReplaceWithRWall()
				else
					WALL = Tsrc.ReplaceWithWall()
				WALL.setMaterial(S.material ? S.material : defaultMaterial)
				WALL.girdermaterial = the_girder.material ? the_girder.material : defaultMaterial

				WALL.inherit_area()
				S?.change_stack_amount(-2)

				qdel(the_girder)
		owner.visible_message(SPAN_NOTICE("[owner] [verbens] [the_girder]."))

/obj/structure/girder/displaced/attack_hand(mob/user)
	if (user.is_hulk())
		if (prob(70))
			playsound(user.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
			src.material_trigger_when_attacked(src, user, 1)
			for (var/mob/N in AIviewers(user, null))
				if (N.client)
					shake_camera(N, 4, 1, 8)
		if (prob(70))
			boutput(user, SPAN_NOTICE("You smash through the girder."))
			logTheThing(LOG_COMBAT, user, "uses hulk to smash a girder at [log_loc(src)].")
			qdel(src)
			return
		else
			boutput(user, SPAN_NOTICE("You punch the [src.name]."))
			return
	..()

/obj/structure/girder/displaced/attackby(obj/item/W, mob/user)

	if (istype(W, /obj/item/sheet))
		if (!istype(src.loc, /turf/simulated/floor/))
			boutput(user, SPAN_ALERT("You can't build a false wall there."))
			return

		var/obj/item/sheet/S = W
		var/turf/simulated/floor/T = src.loc

		var/FloorIcon = T.icon
		var/FloorState = T.icon_state
		var/FloorIntact = T.intact
		var/FloorBurnt = T.burnt
		var/FloorName = T.name

		var/target_type = S.reinforcement ? /turf/simulated/wall/false_wall/reinforced : /turf/simulated/wall/false_wall

		T.ReplaceWith(target_type, FALSE, FALSE, FALSE)
		var/atom/A = src.loc
		var/datum/material/defaultMaterial = getMaterial("steel")
		var/turf/simulated/wall/false_wall/FW = A

		FW.setMaterial(S.material ? S.material : defaultMaterial)
		FW.girdermaterial = src.material ? src.material : defaultMaterial
		FW.inherit_area()

		FW.setFloorUnderlay(FloorIcon, FloorState, FloorIntact, 0, FloorBurnt, FloorName)
		if(user.mind)
			FW.known_by |= user.mind
		S.change_stack_amount(-1)
		boutput(user, "You finish building the false wall.")
		logTheThing(LOG_STATION, user, "builds a False Wall in [user.loc.loc] ([log_loc(user)])")
		qdel(src)
		return

	else if (isscrewingtool(W))
		var/obj/item/sheet/S = new /obj/item/sheet(src.loc)
		if(src.material)
			S.setMaterial(src.material)
		else
			var/datum/material/defaultMaterial = getMaterial("steel")
			S.setMaterial(defaultMaterial)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
		qdel(src)
		return
	else
		return ..()

TYPEINFO(/obj/structure/woodwall)
	mat_appearances_to_ignore = list("wood")
/obj/structure/woodwall
	name = "barricade"
	desc = "This was thrown up in a hurry."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodwall"
	anchored = ANCHORED
	density = 1
	opacity = 1
	material_amt = 0.5
	projectile_passthrough_chance = 30
	_health = 30
	_max_health = 30
	flags = ON_BORDER
	var/builtby = null
	var/anti_z = 0
	// for projectile damage component
	var/projectile_gib = TRUE
	var/projectile_gib_streak = FALSE

	New()
		src.AddComponent(/datum/component/obj_projectile_damage, /obj/decal/cleanable/wood_debris, src.projectile_gib, src.projectile_gib_streak)
		. = ..()

	virtual
		icon = 'icons/effects/VR.dmi'
		projectile_gib = FALSE // no virtual debris

	anti_zombie
		name = "anti-zombie barricade"
		anti_z = 1

		get_desc()
			..()
			. += "Looks like normal spacemen can easily pull themselves over or crawl under it."

	changeHealth(var/change = 0)
		var/prevHealth = _health
		_health += change
		_health = min(_health, _max_health)
		if (prevHealth > _health)
			playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', rand(50,90), 1)
		updateHealth(prevHealth)

	updateHealth(var/prevHealth)
		if (_health <= 0)
			src.visible_message(SPAN_ALERT("<b>[src] collapses!</b>"))
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 100, 1)
			src.onDestroy()
			return
		else if (_health <= 5)
			src.projectile_passthrough_chance = 90
			icon_state = "woodwall4"
			set_opacity(0)
		else if (_health <= 10)
			icon_state = "woodwall3"
			src.projectile_passthrough_chance = 70
			set_opacity(0)
		else if (_health <= 20)
			src.projectile_passthrough_chance = 50
			icon_state = "woodwall2"
		else
			src.projectile_passthrough_chance = 30
			icon_state = "woodwall"

	attack_hand(mob/user)
		if (ishuman(user) && !user.is_zombie)
			var/mob/living/carbon/human/H = user
			if (src.anti_z && H.a_intent != INTENT_HARM && isfloor(get_turf(src)))
				H.set_loc(get_turf(src))
				if (_health > 15)
					H.visible_message(SPAN_NOTICE("<b>[H]</b> [pick("rolls under", "jaunts over", "barrels through")] [src] slightly damaging it!"))
					boutput(H, SPAN_ALERT("<b>OWW! You bruise yourself slightly!"))
					playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 100, 1)
					random_brute_damage(H, 5)
					src.changeHealth(rand(0, -2))
				return

		if (ishuman(user))
			user.lastattacked = src
			src.visible_message(SPAN_ALERT("<b>[user]</b> bashes [src]!"))
			playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 100, 1)
			//Zombies do less damage
			var/mob/living/carbon/human/H = user
			if (istype(H.mutantrace, /datum/mutantrace/zombie))
				if(prob(40))
					H.emote("scream")
				src.changeHealth(rand(0, -2))
			else
				src.changeHealth(rand(-1, -3))
			hit_twitch(src)
			return
		else
			return

	attackby(var/obj/item/W, mob/user)
		if (istype(W,/obj/item/sheet/wood))
			actions.start(new /datum/action/bar/icon/wood_repair_wall(W, src, 30), user)
			return
		..()
		user.lastattacked = src
		src.changeHealth(-W.force)
		hit_twitch(src)
		return

/obj/structure/woodwall/Cross(obj/projectile/mover)
	if (istype(mover) && !mover.proj_data.always_hits_structures && prob(src.projectile_passthrough_chance))
		return TRUE
	return (!density)

/datum/action/bar/icon/wood_repair_wall
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	#ifdef HALLOWEEN
	duration = 20
	#else
	duration = 30
	#endif
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/item/sheet/wood/wood
	var/obj/structure/woodwall/wall

	New(var/obj/item/sheet/wood/wood, var/obj/structure/woodwall/wall, var/duration_i)
		..()
		src.wood = wood
		src.wall = wall
		if (!wall)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (wood == null || wood.amount < 1 || owner == null || BOUNDS_DIST(owner, wall) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && wood != source.equipped())
			interrupt(INTERRUPT_ALWAYS)
		if (prob(20))
			hit_twitch(wall)
			playsound(wall.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', rand(50,90), 1)

	onStart()
		..()
		hit_twitch(wall)
		playsound(wall.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', rand(50,90), 1)
		owner.visible_message(SPAN_NOTICE("[owner] begins repairing [wall]!"))

	onEnd()
		..()
		owner.visible_message(SPAN_NOTICE("[owner] uses a [wood] to completely repair the [wall]!"))
		hit_twitch(wall)
		playsound(wall.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', rand(50,90), 1)
		//do repair shit.
		wall._health = wall._max_health
		wall.updateHealth()
		wood.change_stack_amount(-1)
