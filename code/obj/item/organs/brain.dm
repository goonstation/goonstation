/*=========================*/
/*----------Brain----------*/
/*=========================*/

/obj/item/organ/brain
	name = "brain"
	organ_name = "brain"
	desc = "A human brain, gross."
	organ_holder_name = "brain"
	organ_holder_location = "head"
	icon_state = "brain2"
	item_state = "brain"
	var/datum/mind/owner = null
	edible = 0
	FAIL_DAMAGE = 120
	MAX_DAMAGE = 120
	tooltip_flags = REBUILD_ALWAYS //fuck it, nobody examines brains that often

	disposing()
		if (owner && owner.brain == src)
			owner.brain = null
		else if (donor && donor.mind && donor.mind.brain == src)
			donor.mind.brain = null
		owner = null
		if (holder)
			holder.brain = null
		..()

	Eat(mob/M, mob/user)
		if(M == user)
			if(alert(user, "Are you sure you want to eat [src]?", "Eat brain?", "Yes", "No") == "Yes")
				logTheThing("combat", user, null, "tries to eat [src] (owner's ckey [owner ? owner.ckey : null]).")
				return ..()
		else
			if(alert(user, "Are you sure you want to feed [src] to [M]?", "Feed brain?", "Yes", "No") == "Yes")
				logTheThing("combat", user, null, "tries to feed [src] (owner's ckey [owner ? owner.ckey : null]) to [M].")
				return ..()
		return 0

	get_desc()
		if (usr?.traitHolder?.hasTrait("training_medical"))
			if (src.owner?.key)
				if (!find_ghost_by_key(src.owner?.key))
					. += "<br><span class='notice'>This brain is slimy.</span>"
				else
					. += "<br><span class='notice'>This brain is still warm.</span>"
			else
				. += "<br><span class='alert'>This brain has gone cold.</span>"

	attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Overrides parent function to handle special case for brains. */
		var/mob/living/carbon/human/H = M
		if (!src.can_attach_organ(H, user))
			return 0

		var/obj/item/organ/organ_location = H.organHolder.get_organ("head")

		if (!organ_location)
			boutput(user, "<span class='notice'>Where are you putting that again? There's no head.</span>")
			return null

		if (!headSurgeryCheck(H))
			boutput(user, "<span class='notice'>You're going to need to remove that mask/helmet/glasses first.</span>")
			return null

		if (!H.organHolder.get_organ("brain") && H.organHolder.head.scalp_op_stage >= 4.0)
			if (!H.organHolder.get_organ("skull"))
				boutput(user, "<span class='notice'>There's no skull in there to hold the brain in place.</span>")
				return null

			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

			H.tri_message("<span class='alert'><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] head!</span>",\
			user, "<span class='alert'>You [fluff] [src] into [user == H ? "your" : "[H]'s"] head!</span>",\
			H, "<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your head!</span>")

			if (user.find_in_hand(src))
				user.u_equip(src)
			H.organHolder.receive_organ(src, "brain", 3.0)
			H.organHolder.head.scalp_op_stage = 3.0
			return 1

		return 0

	proc/setOwner(var/datum/mind/mind)
		if (!mind)
			return
		if(inafterlifebar(mind.current)) // No changing owners af this is happening in the afterlife
			return
		if (mind.brain && mind.brain != src)
			var/obj/item/organ/brain/brain = mind.brain
			brain.owner = null
		mind.brain = src
		owner = mind

/obj/item/organ/brain/synth
	name = "synthbrain"
	item_state = "plant"
	desc = "An artificial mass of grey matter. Not actually, as one might assume, very good at thinking."
	New()
		..()
		src.icon_state = pick("plant_brain", "plant_brain_bloom")

/obj/item/organ/brain/latejoin
	name = "Spontaneous Intelligence Creation Core"
	icon_state = "late_brain"
	item_state = "late_brain"
	desc = "A brain sized pyramid constructed out of silicon and LED lights. It employs complex quantum loopholes to create a consciousness within a decade or less."
	created_decal = /obj/decal/cleanable/oil
	var/activated = 0

	get_desc()
		if (usr?.traitHolder?.hasTrait("training_medical"))
			if (activated)
				if (src.owner?.key)
					if (!find_ghost_by_key(src.owner?.key))
						. += "<br><span class='notice'>[src]'s indicators show that it once had a conciousness installed, but that conciousness cannot be located.</span>"
					else
						. += "<br><span class='notice'>[src]'s indicators show that it is still operational, and can be installed into a new body immediately.</span>"
				else
					. += "<br><span class='alert'>[src] has powered down fully.</span>"
			else
				. += "<br><span class='alert'>[src] has its factory defaults enabled. No conciousness has entered it yet.</span>"

/obj/item/organ/brain/ai
	name = "neural net processor"
	desc = "A heavily augmented human brain, upgraded to deal with the large amount of information an AI unit must process."
	icon_state = "ai_brain"
	item_state = "ai_brain"
	created_decal = /obj/decal/cleanable/oil
	made_from = "pharosium"

/obj/item/organ/brain/martian
	name = "squishy lump"
	desc = "A martian brain. At least, it seems like a brain. It could be a heart for all you know."
	icon_state = "martian_brain"
	item_state = "martian_brain"
	created_decal = /obj/decal/cleanable/martian_viscera/fluid
	made_from = "viscerite"

/obj/item/organ/brain/flockdrone
	name = "odd crystal"
	desc = "Flickers of energy still trace around inside it. It feels oddly warm to the touch."
	icon_state = "flockdrone_brain"
	item_state = "flockdrone_brain"
	created_decal = /obj/decal/cleanable/flockdrone_debris/fluid
	made_from = "gnesis"

	on_life()
		var/mob/living/M = holder.donor
		if(!M || !ishuman(M)) // flockdrones shouldn't have these problems
			return
		if(M.client && (isnull(M.client.color) || M.client.color == "#FFFFFF"))
			animate(M.client, color=COLOR_MATRIX_FLOCKMANGLED, time=900, easing=SINE_EASING) // ~ 1.5 minutes to complete
		if(prob(3))
			var/list/sounds = list("sound/machines/ArtifactFea1.ogg", "sound/machines/ArtifactFea2.ogg", "sound/machines/ArtifactFea3.ogg",
				"sound/misc/flockmind/flockmind_cast.ogg", "sound/misc/flockmind/flockmind_caw.ogg",
				"sound/misc/flockmind/flockdrone_beep1.ogg", "sound/misc/flockmind/flockdrone_beep2.ogg", "sound/misc/flockmind/flockdrone_beep3.ogg", "sound/misc/flockmind/flockdrone_beep4.ogg",
				"sound/misc/flockmind/flockdrone_grump1.ogg", "sound/misc/flockmind/flockdrone_grump2.ogg", "sound/misc/flockmind/flockdrone_grump3.ogg",
				"sound/effects/radio_sweep1.ogg", "sound/effects/radio_sweep2.ogg", "sound/effects/radio_sweep3.ogg", "sound/effects/radio_sweep4.ogg", "sound/effects/radio_sweep5.ogg")
			M.playsound_local(get_turf(M), pick(sounds), 20, 1)
			boutput(M, "<span class='flocksay italics'><i>... [pick_string("flockmind.txt", "brain")] ...</i></span>")

/obj/item/organ/brain/flockdrone/special_desc(dist, mob/user)
	if(isflock(user))
		return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
		<br><span class='bold'>ID:</span> Computational core
		<br><span class='bold'>###=-</span></span>"}
	else
		return null // give the standard description

/datum/manufacture/ghost_brain // Move to manufacturing.dm
	name = "Ghost Intelligence Core"
	item_paths = list("MET-1","CON-1","ALL", "soulsteel")
	item_amounts = list(6,5,3,5)
	item_outputs = list(/obj/item/organ/brain/ghost)
	time = 45 SECONDS
	create = 1
	category = "Component"

/obj/item/organ/brain/ghost // Move to brain.dm
	name = "Ghost Intelligence Core"
	desc = "A brain shaped mass of silicon, soulsteel, and LED lights. Attempts to hold onto soul to give life to something else."
	icon_state = "ghost_brain"
	item_state = "ai_brain"
	created_decal = /obj/decal/cleanable/oil
	made_from = "pharosium"
	var/activated = 0
	var/lastTrigger
	var/datum/movement_controller/ghost_brain/MC

	New()
		..()
		MC = new


	get_desc()
		if (usr?.traitHolder?.hasTrait("training_medical"))
			if (activated)
				if (src.owner?.key)
					if (!find_ghost_by_key(src.owner?.key))
						. += "<br><span class='notice'>[src]'s indicators show that it once had a conciousness installed, but that conciousness cannot be located.</span>"
					else
						. += "<br><span class='notice'>[src]'s indicators show that it is still operational, and can be installed into a new body immediately.</span>"
				else
					. += "<br><span class='alert'>[src] has powered down fully.</span>"
			else
				. += "<br><span class='alert'>[src] is brand new. No conciousness has entered it yet.</span>"

	on_life()
		var/mob/living/M = holder.donor
		if(!ishuman(M)) // silicon shouldn't have these problems
			return

		if(M.client && (isnull(M.client.color) || M.client.color == "#FFFFFF") && !ON_COOLDOWN(src,"ghost_eyes", 5 MINUTES))
			animate(M.client, color=COLOR_MATRIX_GRAYSCALE, time=5 SECONDS, easing=SINE_EASING)
			animate(color=COLOR_MATRIX_IDENTITY, time=30 SECONDS, easing=SINE_EASING)
		if(prob(1))
			boutput(M,"You find you lose control of your body for a moment...")
			M.changeStatus("paralysis", 2 SECONDS)
		if(prob(1))
			boutput(M,"You suddenly feel sluggish as though your connection to your body isn't as strong.")
			M.changeStatus("slowed", 8 SECONDS, 2)

	get_movement_controller()
		.= MC

	Crossed(atom/movable/AM)
		..()

		var/mob/dead/observer/O = AM
		if(istype(O))
			actions.start(new/datum/action/bar/capture_ghost(O), src)

	Entered(atom/movable/A,atom/OldLoc)
		. = ..()
		var/mob/dead/observer/O = A
		if(MC && istype(O) )
			O.use_movement_controller = src
			O.setStatus("bound_ghost", duration = 2 MINUTES, optional=list("anchor"=src, "client"=O.client))
			if (istype(O.abilityHolder, /datum/abilityHolder/ghost_observer))
				var/datum/abilityHolder/ghost_observer/GH = O.abilityHolder
				GH.disable(TRUE)
				GH.updateButtons()

	Exited(atom/movable/A,atom/OldLoc)
		. = ..()
		var/mob/dead/observer/O = A
		if(istype(O) && O.use_movement_controller == src)
			O.use_movement_controller = null

			if (istype(O.abilityHolder, /datum/abilityHolder/ghost_observer))
				var/datum/abilityHolder/ghost_observer/GH = O.abilityHolder
				GH.disable(FALSE)
				GH.updateButtons()

/datum/action/bar/capture_ghost
	id = "capture_ghost"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 5 SECONDS
	var/mob/dead/observer/target
	var/image/pulling

	New(mob/dead/observer/O)
		..()
		if (istype(O))
			target = O
		if(!pulling)
			pulling = image('icons/effects/effects.dmi',"pulling",pixel_y=16)
			pulling.alpha = 200

	onUpdate()
		..()
		if(GET_DIST(target,owner) != 0)
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		boutput(target, "<span class='notice'>You feel yourself being pulled into [owner]!</span>")
		owner.UpdateOverlays(pulling, "pulling")

	onEnd()
		..()
		var/obj/item/organ/brain/ghost/B = owner
		if(target.observe_round) return
		if(B && target.client)
			B.activated = TRUE
			playsound(B, "sound/effects/suck.ogg", 20, TRUE, 0, 0.9)
			B.setOwner(target.mind)
			target.set_loc(B)
			target.changeStatus("ghost_bound", 2 MINUTES, B)

	onDelete()
		..()
		owner.ClearSpecificOverlays("pulling")


/datum/movement_controller/ghost_brain
	keys_changed(mob/user, keys, changed)

		var/obj/O = user.loc
		if(istype(O))
			if (changed & (KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT))
				var/move_x = 0
				var/move_y = 0
				if (keys & KEY_FORWARD)
					move_y += 1
				if (keys & KEY_BACKWARD)
					move_y -= 1
				if (keys & KEY_RIGHT)
					move_x += 1
				if (keys & KEY_LEFT)
					move_x -= 1
				if (move_x || move_y)
					if(!user.move_dir && user.canmove && user.restrained())
						if (user.pulled_by || length(user.grabbed_by))
							boutput(user, "<span class='notice'>You're restrained! You can't move!</span>")

					user.move_dir = angle2dir(arctan(move_y, move_x))
					//attempt_move(user)
					if(!ON_COOLDOWN(user,"ghost_glow", 5 SECONDS))
						O.visible_message("[O] glows brightly momentarily.")
					if(!ON_COOLDOWN(user,"ghost_wiggle", 1 SECONDS))
						animate(O, time=0.5 SECONDS, pixel_x=move_x, pixel_y=move_y, flags=ANIMATION_RELATIVE)
						animate(pixel_x=-move_x, pixel_y=-move_y, time=0.2 SECONDS, flags=ANIMATION_RELATIVE)
				else
					user.move_dir = 0

			if(!user.dir_locked)
				user.set_dir(user.move_dir)
			if (changed & (KEY_THROW|KEY_PULL|KEY_POINT|KEY_EXAMINE|KEY_BOLT|KEY_OPEN|KEY_SHOCK)) // bleh
				user.update_cursor()

/datum/statusEffect/bound_ghost
	id= "bound_ghost"
	var/atom/bound_target
	var/client/target_client
	move_triggered = TRUE
	onAdd(optional)
		..()
		var/list/statusargs = optional
		if(statusargs["anchor"])
			bound_target = statusargs["anchor"]
		if(statusargs["client"])
			target_client = statusargs["client"]

	onUpdate()
		..()
		get_back_here()

	move_trigger(mob/user, ev)
		. = 0
		get_back_here()

	proc/get_back_here()
		var/mob/dead/observer/ghost = owner
		if(istype(ghost) && bound_target && ghost.loc != bound_target)
			boutput(ghost, "You find yourself pulled back into [bound_target]!")
			ghost.set_loc(bound_target)

