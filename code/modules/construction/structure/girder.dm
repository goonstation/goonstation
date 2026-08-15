/obj/structure/girder
	icon_state = "girder"
	anchored = ANCHORED
	density = 1
	material_amt = 0.2
	var/state = 0
	projectile_passthrough_chance = 50
	desc = "A metal support for an incomplete wall."
	HELP_MESSAGE_OVERRIDE({"
		You can use a <b>crowbar</b> to displace it,
		use a <b>wrench</b> to deconstruct it,
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
			use a <b>wrench</b> to anchor the girder in place,
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

				var/obj/item/sheet/S = the_tool
				S?.change_stack_amount(-2)
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
