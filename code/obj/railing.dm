/obj/railing
	name = "railing"
	desc = "Two sets of bars shooting onward with the sole goal of blocking you off. They can't stop you from vaulting over them though!"
	anchored = 1
	density = 1
	icon = 'icons/obj/objects.dmi'
	icon_state = "railing"
	layer = OBJ_LAYER
	color = "#ffffff"
	flags = FPRINT | USEDELAY | ON_BORDER | ALWAYS_SOLID_FLUID
	event_handler_flags = USE_FLUID_ENTER | USE_CHECKEXIT | USE_CANPASS
	dir = SOUTH
	custom_suicide = 1
	var/broken = 0

	proc/layerify()
		SPAWN_DBG(3 DECI SECONDS)
		if (dir == SOUTH)
			layer = MOB_LAYER + 0.1
		else
			layer = OBJ_LAYER

	proc/railing_is_broken(obj/railing/The_Railing)
		if(The_Railing.broken)
			return 1
		else
			return 0

	proc/railing_break(obj/railing/The_Railing)
		if(!(railing_is_broken(The_Railing)))
			The_Railing.broken = 1
			The_Railing.density = 0
			var/random_sprite = rand(1, 4)
			The_Railing.icon_state = "railing-broken-" + "[random_sprite]"

	proc/railing_fix(obj/railing/The_Railing)
		if(railing_is_broken(The_Railing))
			The_Railing.density = 1
			The_Railing.broken = 0


	//break it apart into the sheets that made it up!
	proc/railing_deconstruct()
		var/obj/item/sheet/steel/S
		S = new (src.loc)
		if (S && src.material)
			S.setMaterial(src.material)
		qdel(src)

	ex_act(severity)
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0)
				if (prob(50))
					railing_deconstruct(src)
					return
			if(3.0)
				if (prob(25))
					railing_break(src)
					return
			else
				return

	blob_act(var/power)
		if(prob(power * 2.5))
			railing_deconstruct(src)
			return
		else if(prob(power * 2.5))
			railing_break(src)
			return


	New()
		..()
		layerify()

	Turn()
		..()
		layerify()

	CanPass(atom/movable/O as mob|obj, turf/target, height=0, air_group=0)
		if (O == null)
			//logTheThing("debug", src, O, "Target is null! CanPass failed.")
			return 0
		if (!src.density || (O.flags & TABLEPASS) || istype(O, /obj/newmeteor) || istype(O, /obj/lpt_laser) )
			return 1
		if (air_group || (height==0))
			return 1
		if (get_dir(loc, O) == dir)
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
			if(W:try_weld(user, 1))
				actions.start(new /datum/action/bar/icon/railing_tool_interact(user, src, W, RAILING_DISASSEMBLE, 3 SECONDS), user)
		else if (railing_is_broken(src))
			user.show_text("[src] is broken! All you can really do is break it down...", "red")
		else if (isscrewingtool(W))
			if (anchored)
				actions.start(new /datum/action/bar/icon/railing_tool_interact(user, src, W, RAILING_UNFASTEN, 2 SECONDS), user)
			else
				actions.start(new /datum/action/bar/icon/railing_tool_interact(user, src, W, RAILING_FASTEN, 2 SECONDS), user)

	attack_hand(mob/user)
		if (railing_is_broken(src))
			user.show_text("[src] is broken! All you can really do is break it down...", "red")
		else
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
			jump_target = getLandingLoc()

	proc/getLandingLoc()
		if (get_dist(ownerMob, the_railing) == 0)
			return get_step(the_railing, the_railing.dir)
		else
			return get_turf(the_railing)

	onUpdate()
		..()
		// you gotta hold still to jump!
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
		..()
		var/bunp //the name of the thing we have bunp'd into when trying to jump the railing
		var/list/bunp_whitelist = list(/obj/railing, /obj/decal/stage_edge) // things that we cannot bunp into
		if (jump_target.density)
			bunp = jump_target.name
			no_no_zone = 1
		else
			for (var/obj/o in jump_target.contents)
				for (var/i=1, i <= bunp_whitelist.len + 1, i++) //+1 so we can actually go past the whitelist len check
					if (!(i > bunp_whitelist.len))
						// if it's an exception to the bunp rule...
						if (istype (o, bunp_whitelist[i]))
							break

					// don't proceed just yet if we aren't done going through the whitelist!
					else if (i <= bunp_whitelist.len)
						continue

					// otherwise, if it's a dense thing...
					else if (o.density)
						bunp = o.name
						no_no_zone = 1
						break

		if(no_no_zone)
			// if they are a living mob, make them TASTE THE PAIN
			if (istype(ownerMob, /mob/living))
				if (!ownerMob.hasStatus("weakened"))
					ownerMob.changeStatus("weakened", 4 SECONDS)
					playsound(the_railing, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1, -1)
					for(var/mob/O in AIviewers(ownerMob))
						O.show_text("[ownerMob] tries to climb straight into \the [bunp].[prob(30) ? pick(" What a goof!!", " A silly [ownerMob.name].", " <b>HE HOO HE HA</b>", " Good thing [he_or_she(ownerMob)] didn't bump [his_or_her(ownerMob)] head!") : null]", "red")
				// HE HE U BUNPED YOUR HEAD
				if (prob(25))
					ownerMob.changeStatus("weakened", 4 SECONDS)
					ownerMob.TakeDamage("head", 10, 0, 0, DAMAGE_BLUNT)
					playsound(the_railing, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1, -1)
					for(var/mob/O in AIviewers(ownerMob))
						O.show_text("[ownerMob] bumps [his_or_her(ownerMob)] head on \the [bunp].[prob(30) ? pick(" Oof, that looked like it hurt!", " Is [he_or_she(ownerMob)] okay?", " Maybe that wasn't the wisest idea...", " Don't do that!") : null]", "red")

			return

		// otherwise, the user jumps over without issue!
		sendOwner()

	proc/sendOwner()
		ownerMob.set_loc(jump_target)
		for(var/mob/O in AIviewers(ownerMob))
			var/the_text = null
			if (is_athletic_jump) // athletic jumps are more athletic!!
				the_text = "[ownerMob] swooces right over [the_railing]!"
			else
				the_text = "[ownerMob] pulls [himself_or_herself(ownerMob)] over [the_railing]."
			O.show_text("[the_text]", "red")
		logTheThing("combat", ownerMob, the_railing, "[is_athletic_jump ? "leaps over [the_railing] with [his_or_her(ownerMob)] athletic trait" : "crawls over [the_railing]"].")


/datum/action/bar/icon/railing_tool_interact
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "railing_deconstruct"
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"
	var/obj/railing/the_railing
	var/mob/ownerMob
	var/obj/item/tool // the tool the owner is using on the railing
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
			//carpenter people can fiddle with railings faster!
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
			logTheThing("debug", src, the_railing, "tried to interact with [the_railing] using a null tool... somehow.")
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
				the_railing.railing_deconstruct()
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
			logTheThing("station", ownerMob, the_railing, "[verbens] [the_railing].")

