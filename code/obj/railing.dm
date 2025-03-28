/obj/railing
	name = "railing"
	desc = "Two sets of bars shooting onward with the sole goal of blocking you off. They can't stop you from vaulting over them though!"
	anchored = ANCHORED
	density = 1
	icon = 'icons/obj/objects.dmi'
	icon_state = "railing"
	layer = OBJ_LAYER
	color = "#ffffff"
	flags = USEDELAY | ON_BORDER
	event_handler_flags = USE_FLUID_ENTER
	object_flags = HAS_DIRECTIONAL_BLOCKING
	dir = SOUTH
	custom_suicide = 1
	material_amt = 0.1
	var/broken = 0
	var/is_reinforced = 0
	var/can_reinforce = TRUE

	proc/layerify()
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
			The_Railing.set_density(FALSE)
			var/random_sprite = rand(1, 4)
			The_Railing.icon_state = "railing-broken-" + "[random_sprite]"

	proc/railing_fix(obj/railing/The_Railing)
		if(railing_is_broken(The_Railing))
			The_Railing.set_density(TRUE)
			The_Railing.broken = 0


	//break it apart into the sheets that made it up!
	proc/railing_deconstruct()
		var/obj/item/sheet/steel/S
		S = new (src.loc)
		if (S && src.material)
			S.setMaterial(src.material)
		if(src.is_reinforced)
			var/obj/item/rods/R = new /obj/item/rods(get_turf(src))
			R.amount = 1
			if(src.material)
				R.setMaterial(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				R.setMaterial(M)
		qdel(src)

	ex_act(severity)
		switch(severity)
			if(1)
				qdel(src)
				return
			if(2)
				if (prob(50))
					railing_deconstruct(src)
					return
			if(3)
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
		if(src.is_reinforced)
			src.flags |= ALWAYS_SOLID_FLUID
		layerify()

	Turn()
		..()
		layerify()

	Cross(atom/movable/O as mob|obj)
		if (O == null)
			return 0
		if (!src.density || (O.flags & TABLEPASS && !src.is_reinforced) || istype(O, /obj/newmeteor) || istype(O, /obj/linked_laser) )
			return 1
		if (src.dir & get_dir(loc, O))
			return !density
		return 1

	Uncross(atom/movable/O, do_bump = TRUE)
		if (!src.density || (O.flags & TABLEPASS && !src.is_reinforced)  || istype(O, /obj/newmeteor) || istype(O, /obj/linked_laser) )
			. = 1
		// Second part prevents two same-dir, unanchored railings from infinitely looping and either crashing the server or breaking throwing when they try to cross
		else if ((src.dir & get_dir(O.loc, O.movement_newloc)) && !(isobj(O) && (O:object_flags & HAS_DIRECTIONAL_BLOCKING) && (O.dir & src.dir)))
			. = 0
		else
			. = 1
		UNCROSS_BUMP_CHECK(O)

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
		else if (issnippingtool(W))
			if(src.is_reinforced)
				user.show_text("You cut off the reinforcement on [src].", "blue")
				src.icon_state = "railing"
				src.is_reinforced = 0
				src.flags &= !ALWAYS_SOLID_FLUID
				var/obj/item/rods/R = new /obj/item/rods(get_turf(src))
				R.amount = 1
				if(src.material)
					R.setMaterial(src.material)
				else
					var/datum/material/M = getMaterial("steel")
					R.setMaterial(M)
			else
				user.show_text("There's no reinforcment on [src] to cut off!", "blue")
		else if (istype(W,/obj/item/rods))
			if(!src.is_reinforced && can_reinforce)
				var/obj/item/rods/R = W
				if(R.change_stack_amount(-1))
					user.show_text("You reinforce [src] with the rods.", "blue")
					src.is_reinforced = 1
					src.icon_state = "railing-reinforced"
					src.flags |= ALWAYS_SOLID_FLUID
			else
				user.show_text("[src] is already reinforced!", "red")

	attack_hand(mob/user)
		src.try_vault(user)

	attack_ai(mob/user)
		if(!can_reach(user, src) || isAI(user) || isAIeye(user))
			return
		return src.Attackhand(user)

	Bumped(var/mob/AM as mob)
		. = ..()
		if(!istype(AM)) return
		if(AM.client?.check_key(KEY_RUN) || AM.client?.check_key(KEY_BOLT))
			src.try_vault(AM, TRUE)

	proc/try_vault(mob/user, use_owner_dir = FALSE)
		if (railing_is_broken(src))
			user.show_text("[src] is broken! All you can really do is break it down...", "red")
		else if(!actions.hasAction(user, /datum/action/bar/icon/railing_jump))
			actions.start(new /datum/action/bar/icon/railing_jump(user, src, use_owner_dir), user)

	reinforced
		is_reinforced = 1
		icon_state = "railing-reinforced"

	orange
		color = "#ff7b00"
		reinforced
			is_reinforced = 1
			icon_state = "railing-reinforced"

	red
		color = "#ff0000"
		reinforced
			is_reinforced = 1
			icon_state = "railing-reinforced"

	green
		color = "#09ff00"
		reinforced
			is_reinforced = 1
			icon_state = "railing-reinforced"

	yellow
		color = "#ffe600"
		reinforced
			is_reinforced = 1
			icon_state = "railing-reinforced"

	cyan
		color = "#00f7ff"
		reinforced
			is_reinforced = 1
			icon_state = "railing-reinforced"

	purple
		color = "#cc00ff"
		reinforced
			is_reinforced = 1
			icon_state = "railing-reinforced"

	blue
		color = "#0026ff"
		reinforced
			is_reinforced = 1
			icon_state = "railing-reinforced"

	velvet
		icon = 'icons/obj/velvetrope.dmi'
		icon_state = "velvetrope"
		desc = "A cushy red velvet rope strewn between two golden poles."
		can_reinforce = FALSE

	guard // I'm yoinking this from window.dm and there's nothing you can do to stop me
		name = "guard railing"
		desc = "Doesn't look very sturdy, but it's better than nothing?"
		icon = 'icons/obj/structures.dmi'
		is_reinforced = TRUE
		icon_state = "safetyrail"
		can_reinforce = FALSE

/datum/action/bar/icon/railing_jump
	duration = 1 SECOND
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/ui/actions.dmi'
	icon_state = "railing_jump"
	resumable = FALSE
	var/mob/ownerMob
	var/obj/railing/the_railing
	var/turf/jump_target //where the mob will move to when they complete the jump!
	var/is_athletic_jump //if the user has the athletic trait, and therefore does the BEEG HARDCORE PARKOUR YUMP
	var/no_no_zone //if the user is trying to jump over railing onto somewhere they couldn't otherwise move through...
	var/do_bump = TRUE
	var/use_owner_dir = FALSE
	/// list of types exempt from bump checks when checking landing turf validity
	var/list/collision_whitelist = null

	New(The_Owner, The_Railing, use_owner_dir = FALSE)
		..()
		collision_whitelist = typesof(/obj/railing, /obj/decal/stage_edge, /obj/decal/boxingropeenter, /obj/sec_tape,)
		if (The_Owner)
			owner = The_Owner
			ownerMob = The_Owner
			src.use_owner_dir = use_owner_dir
			if (ishuman(owner))
				var/mob/living/carbon/human/H = owner
				var/modifier = 1
				if (H.traitHolder.hasTrait("athletic"))
					modifier++
					is_athletic_jump = 1
				modifier += GET_ATOM_PROPERTY(H, PROP_MOB_VAULT_SPEED)
				duration = round(duration / modifier)
		if (The_Railing)
			the_railing = The_Railing
			jump_target = getLandingLoc()

	proc/getLandingLoc()
		if (GET_DIST(ownerMob, the_railing) == 0)
			if (use_owner_dir)
				// for handling the multiple ways top hop a corner railing
				return get_step(the_railing, owner.dir)
			else
				return get_step(the_railing, the_railing.dir)
		else
			return get_turf(the_railing)

	onUpdate()
		..()
		// you gotta hold still to jump!
		if (BOUNDS_DIST(ownerMob, the_railing) > 0)
			interrupt(INTERRUPT_ALWAYS)
			ownerMob.show_text("Your jump was interrupted!", "red")
			return

	onStart()
		..()
		if (BOUNDS_DIST(ownerMob, the_railing) > 0 || the_railing == null || ownerMob == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		ownerMob.visible_message(SPAN_ALERT("[ownerMob] begins to pull [himself_or_herself(ownerMob)] over [the_railing]."))

	onEnd()
		..()
		if(do_bump())
			return
		// otherwise, the user jumps over without issue!
		sendOwner()

	proc/do_bump()
		/// obstacle blocking the destination turf
		var/obj/obstacle = null
		var/direction = get_dir(get_turf(owner), jump_target)

		if (jump_target.density) // is it a wall?
			obstacle = jump_target.name
		else
			obstacle = check_turf_obstacles(jump_target) // is the dest blocked?
			if (!obstacle && (direction in ordinal)) // dest was ok, if we are moving in an ordinal what about the corners?
				var/turf/T1 = get_step(get_turf(owner), turn(direction, 45))
				obstacle = check_turf_obstacles(T1)
				if (obstacle) // T1 was blocked, but was T2 also blocked?
					var/turf/T2 = get_step(get_turf(owner), turn(direction, -45))
					obstacle = check_turf_obstacles(T2)


		if(obstacle) // did we end up ever bumping the dest or two corners?
			// if they are a living mob, make them TASTE THE PAIN
			if (istype(ownerMob, /mob/living))
				if (!ownerMob.hasStatus("knockdown"))
					ownerMob.changeStatus("knockdown", 4 SECONDS)
					playsound(the_railing, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, TRUE, -1)
					ownerMob.visible_message(SPAN_ALERT("[ownerMob] tries to climb straight into \the [obstacle].[prob(30) ? pick(" What a goof!!", " A silly [ownerMob.name].", " <b>HE HOO HE HA</b>", " Good thing [he_or_she(ownerMob)] didn't bump [his_or_her(ownerMob)] head!") : null]"))
				// chance for additional head bump damage
				if (prob(25))
					ownerMob.changeStatus("knockdown", 4 SECONDS)
					ownerMob.TakeDamage("head", 10, 0, 0, DAMAGE_BLUNT)
					playsound(the_railing, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, TRUE, -1)
					ownerMob.visible_message(SPAN_ALERT("[ownerMob] bumps [his_or_her(ownerMob)] head on \the [obstacle].[prob(30) ? pick(" Oof, that looked like it hurt!", " Is [he_or_she(ownerMob)] okay?", " Maybe that wasn't the wisest idea...", " Don't do that!") : null]"))
			return TRUE
		return FALSE

	proc/check_turf_obstacles(turf/T)
		for (var/obj/O in T.contents)
			if (!O.density) continue // don't care.
			if (O.type in collision_whitelist) continue
			return O

	proc/sendOwner()
		ownerMob.set_loc(jump_target)
		var/the_text = null
		if (is_athletic_jump) // athletic jumps are more athletic!!
			the_text = "[ownerMob] swooces right over [the_railing]!"
		else
			the_text = "[ownerMob] pulls [himself_or_herself(ownerMob)] over [the_railing]."
		ownerMob.visible_message(SPAN_ALERT("[the_text]"))


/datum/action/bar/icon/railing_tool_interact
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
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
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)
		if (The_Interaction)
			interaction = The_Interaction

	onUpdate()
		..()
		if (tool == null || the_railing == null || owner == null || BOUNDS_DIST(owner, the_railing) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		//featuring code shamelessly copypasted from table.dm because fuuuuuuuck
		..()
		if (BOUNDS_DIST(ownerMob, the_railing) > 0 || the_railing == null || ownerMob == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (!tool)
			interrupt(INTERRUPT_ALWAYS)
			logTheThing(LOG_DEBUG, src, "tried to interact with [the_railing] at [log_loc(the_railing)] using a null tool... somehow.")
			return
		var/verbing = "doing something to"
		switch (interaction)
			if (RAILING_DISASSEMBLE)
				verbing = "to disassemble"
			if (RAILING_FASTEN)
				verbing = "fastening"
				playsound(the_railing, 'sound/items/Screwdriver.ogg', 50, TRUE)
			if (RAILING_UNFASTEN)
				verbing = "unfastening"
				playsound(the_railing, 'sound/items/Screwdriver.ogg', 50, TRUE)
		ownerMob.visible_message(SPAN_ALERT("[owner] begins [verbing] [the_railing]."))

	onEnd()
		..()
		var/verbens = "does something to"
		switch (interaction)
			if (RAILING_DISASSEMBLE)
				verbens = "disassembles"
				tool:try_weld(ownerMob, 2)
				the_railing.railing_deconstruct()
			if (RAILING_FASTEN)
				verbens = "fastens"
				the_railing.anchored = ANCHORED
				playsound(the_railing, 'sound/items/Screwdriver.ogg', 50, TRUE)
			if (RAILING_UNFASTEN)
				verbens = "unfastens"
				the_railing.anchored = UNANCHORED
				playsound(the_railing, 'sound/items/Screwdriver.ogg', 50, TRUE)
		ownerMob.visible_message(SPAN_ALERT("[owner] [verbens] [the_railing]."))
		logTheThing(LOG_STATION, ownerMob, "[verbens] [the_railing] at [log_loc(the_railing)].")

