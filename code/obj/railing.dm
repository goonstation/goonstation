// this is such a dumb joke
/obj/meme
	name = "glorious"
	desc = "FUCK WHAT THE JESUS IS THAT"
	icon = 'icons/obj/160x160.dmi'
	icon_state = "dumb-joke-left"
	layer = 100
	plane = 100
	opacity = 0
	density = 0
	pixel_x = -64
	pixel_y = -64

	right
		icon_state = "dumb-joke-right"

/obj/railing
	name = "railing"
	desc = "Two sets of bars shooting onward with the sole goal of blocking you off. They can't stop you from vaulting over them though!"
	anchored = 1
	density = 1
	icon = 'icons/obj/objects.dmi'
	icon_state = "railing"
	layer = OBJ_LAYER - 0.1
	color = "#ffffff"
	flags = FPRINT | USEDELAY | ON_BORDER | ALWAYS_SOLID_FLUID
	event_handler_flags = USE_FLUID_ENTER | USE_CHECKEXIT | USE_CANPASS
	dir = SOUTH
	custom_suicide = 1

	proc/layerify()
		SPAWN_DBG(1 DECI SECOND) // why are you like this why is this necessary
		if (dir == SOUTH)
			layer = MOB_LAYER + 0.1
		else
			layer = OBJ_LAYER - 0.1

	New()
		..()
		layerify()

	Turn()
		..()
		layerify()

	CanPass(atom/movable/O as mob|obj, turf/target, height=0, air_group=0)
		if (O == null)
			logTheThing("debug", src, O, "Target is null! CanPass failed.")
			return 0
		if (!src.density || (O.flags & TABLEPASS) || istype(O, /obj/newmeteor) || istype(O, /obj/lpt_laser) )
			return 1
		if(air_group || (height==0))
			return 1
		if(get_dir(loc, O) == dir)
			return !density
		else
			return 1

	CheckExit(atom/movable/O as mob|obj, target as turf)
		if (!src.density)
			return 1
		else if (!src.density || (O.flags & TABLEPASS || istype(O, /obj/newmeteor)) || istype(O, /obj/lpt_laser) )
			return 1
		else if (get_dir(O.loc, target) == src.dir)
			return 0
		else
			return 1

	attackby(obj/item/W as obj, mob/user)
		if (isweldingtool(W))
			actions.start(new /datum/action/bar/icon/railing_tool_interact(user, src, W, RAILING_DISASSEMBLE, 3 SECONDS), user)
		if (isscrewingtool(W))
			if (anchored)
				actions.start(new /datum/action/bar/icon/railing_tool_interact(user, src, W, RAILING_UNFASTEN, 2 SECONDS), user)
			else
				actions.start(new /datum/action/bar/icon/railing_tool_interact(user, src, W, RAILING_FASTEN, 2 SECONDS), user)

	attack_hand(mob/user)
		actions.start(new /datum/action/bar/icon/railing_jump(user, src), user)

	orange
		color = "#ff7b00"

	red
		color = "#ff0000"

	green
		color = "#09ff00"

	yellow
		color = "#ffe600"

	cyan
		color = "#00f7ff"

	purple
		color = "#cc00ff"

	blue
		color = "#0026ff"


/datum/action/bar/icon/railing_jump
	duration = 1 SECOND
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "railing_deconstruct"
	icon = 'icons/ui/actions.dmi'
	icon_state = "railing_jump"
	var/mob/ownerMob
	var/obj/railing/the_railing
	var/turf/jump_target //where the mob will move to when they complete the jump!
	var/is_athletic_jump //if the user has the athletic trait, and therefore does the BEEG HARDCORE PARKOUR YUMP
	var/no_no_zone //if the user is trying to jump over railing onto somewhere they couldn't otherwise move through...

	New(The_Owner, The_Railing)
		..()
		if (The_Owner)
			owner = The_Owner
			ownerMob = The_Owner
			if (ishuman(owner))
				var/mob/living/carbon/human/H = owner
				if (H.traitHolder.hasTrait("athletic"))
					duration = round(duration / 2)
					is_athletic_jump = 1
		if (The_Railing)
			the_railing = The_Railing
			if (get_dist(ownerMob, the_railing) == 0)
				jump_target = get_step(the_railing, the_railing.dir)
			else
				jump_target = get_turf(the_railing)

	onUpdate()
		..()
		if (get_dist(ownerMob, the_railing) > 1)
			interrupt(INTERRUPT_ALWAYS)
			ownerMob.show_text("Your jump was interrupted!", "red")
			return

	onStart()
		..()
		if (get_dist(ownerMob, the_railing) > 1 || the_railing == null || ownerMob == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		for(var/mob/O in AIviewers(ownerMob))
			O.show_text("[ownerMob] begins to pull [himself_or_herself(ownerMob)] over [the_railing].", "red")

	onEnd()
		var/bunp //bunp'd thing's name
		if (jump_target.density)
			bunp = jump_target.name
			no_no_zone = 1
		else
			for(var/obj/o in jump_target.contents)
				if(istype(o,/obj/railing))
					continue
				if(o.density)
					bunp = o.name
					no_no_zone = 1
					break

		if(no_no_zone)
			if (istype(ownerMob, /mob/living))
				if (!ownerMob.hasStatus("weakened"))
					ownerMob.changeStatus("weakened", 4 SECONDS)
					playsound(the_railing, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1, -1)
					for(var/mob/O in AIviewers(ownerMob))
						O.show_text("[ownerMob] tries to climb straight into \the [bunp]. What a goof!!", "red")
				if (prob(25))
					ownerMob.changeStatus("weakened", 4 SECONDS)
					ownerMob.TakeDamage("head", 0, 10)
					playsound(the_railing, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1, -1)
					for(var/mob/O in AIviewers(ownerMob))
						O.show_text("[ownerMob] bumps [his_or_her(ownerMob)] head on \the [bunp]. What a goof!!", "red")

			return

		ownerMob.set_loc(jump_target)
		for(var/mob/O in AIviewers(ownerMob))
			var/the_text = null
			if (is_athletic_jump)
				the_text = "[ownerMob] swooces right over [the_railing]!"
			else
				the_text = "[ownerMob] pulls [himself_or_herself(ownerMob)] over [the_railing]."
			O.show_text("[the_text]", "red")
		logTheThing("combat", ownerMob, the_railing, "[is_athletic_jump ? "leaps over %the_railing% with [his_or_her(ownerMob)] athletic trait" : "crawls over %the_railing%"].")


/datum/action/bar/icon/railing_tool_interact
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "railing_deconstruct"
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"
	var/obj/railing/the_railing
	var/mob/ownerMob
	var/obj/item/tool
	var/interaction = RAILING_DISASSEMBLE

	New(The_Owner, The_Railing, var/obj/item/The_Tool, The_Interaction, The_Duration)
		..()
		if (The_Railing)
			the_railing = The_Railing
		if (The_Owner)
			owner = The_Owner
			ownerMob = The_Owner
		if (The_Tool)
			tool = The_Tool
			icon = The_Tool.icon
			icon_state = The_Tool.icon_state
		if (The_Duration)
			duration = The_Duration
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter"))
				duration = round(duration / 2)
		if (The_Interaction)
			interaction = The_Interaction

	onUpdate()
		..()
		if (tool == null || the_railing == null || owner == null || get_dist(owner, the_railing) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		//featuring code shamelessly copypasted from table.dm because fuuuuuuuck
		..()
		if (get_dist(ownerMob, the_railing) > 1 || the_railing == null || ownerMob == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (!tool)
			interrupt(INTERRUPT_ALWAYS)
			logTheThing("debug", src, the_railing, "tried to interact with %the_railing% using a null tool... somehow.")
			return
		var/verbing = "doing something to"
		switch (interaction)
			if (RAILING_DISASSEMBLE)
				verbing = "to disassemble"
				playsound(get_turf(the_railing), "sound/items/Welder.ogg", 50, 1)
			if (RAILING_FASTEN)
				verbing = "fastening"
				playsound(get_turf(the_railing), "sound/items/Screwdriver.ogg", 50, 1)
			if (RAILING_UNFASTEN)
				verbing = "unfastening"
				playsound(get_turf(the_railing), "sound/items/Screwdriver.ogg", 50, 1)
		for(var/mob/O in AIviewers(ownerMob))
			O.show_text("[owner] begins [verbing] [the_railing].", "red")

	onEnd()
		..()
		var/verbens = "does something to"
		switch (interaction)
			if (RAILING_DISASSEMBLE)
				verbens = "disassembles"
				tool:try_weld(ownerMob, 2)
				deconstruct()
				playsound(get_turf(the_railing), "sound/items/Welder.ogg", 50, 1)
			if (RAILING_FASTEN)
				verbens = "fastens"
				the_railing.anchored = 1
				playsound(get_turf(the_railing), "sound/items/Screwdriver.ogg", 50, 1)
			if (RAILING_UNFASTEN)
				verbens = "unfastens"
				the_railing.anchored = 0
				playsound(get_turf(the_railing), "sound/items/Screwdriver.ogg", 50, 1)
		for(var/mob/O in AIviewers(ownerMob))
			O.show_text("[owner] [verbens] [the_railing].", "red")
			logTheThing("station", ownerMob, the_railing, "[verbens] %the_railing%.")

	proc/deconstruct()
		var/obj/item/sheet/steel/S
		S = new (the_railing.loc)
		if (S && the_railing.material)
			S.setMaterial(the_railing.material)
		qdel(the_railing)
