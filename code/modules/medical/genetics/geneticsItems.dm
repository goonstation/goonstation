/obj/item/genetics_injector
	name = "genetics injector"
	desc = "A special injector designed to interact with one's genetic structure."
	icon = 'icons/obj/syringe.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "syringe_0"
	icon_state = "injector_1"
	force = 3
	throwforce = 3
	w_class = W_CLASS_SMALL
	var/uses = 1

	attack(mob/M, mob/user)
		if(!M || !user)
			return

		if(src.uses < 1)
			boutput(user, "<span class='alert'>The injector is expended and has no more uses.</span>")
			return

		if(M == user)
			user.visible_message("<span class='alert'><b>[user.name] injects [himself_or_herself(user)] with [src]!</b></span>")
			src.injected(user,user)
		else
			logTheThing(LOG_COMBAT, user, "tries to inject [constructTarget(M,"combat")] with [src.name] at [log_loc(user)]")
			actions.start(new/datum/action/bar/icon/genetics_injector(M,src), user)

	proc/injected(var/mob/living/carbon/user,var/mob/living/carbon/target)
		if(!istype(user) || !istype(target))
			return 1
		if(!istype(target.bioHolder))
			return 1
		logTheThing(LOG_COMBAT, user, "injects [constructTarget(target,"combat")] with [src.name] at [log_loc(user)]")
		return 0

	proc/update_appearance()
		if(src.uses < 1)
			src.icon_state = "injector_2"
			src.desc = "A [src] that has been used up. It should be recycled or disposed of."
			src.name = "expended " + src.name

	dna_injector
		name = "dna injector"
		desc = "A syringe designed to safely insert or remove genetic structures to and from a living organism."
		var/datum/bioEffect/BE = null

		injected(var/mob/living/carbon/user,var/mob/living/carbon/target)
			if (..())
				return

			target.bioHolder.AddEffectInstance(BE,1)
			src.uses--
			src.update_appearance()

	dna_activator
		name = "dna activator"
		desc = "A syringe designed to safely stimulate a living organism's genes into activation."
		var/gene_to_activate = null
		var/expended_properly = 0
		icon_state = "activator_1"

		injected(var/mob/living/carbon/user,var/mob/living/carbon/target)
			if (..())
				return

			var/datum/bioEffect/BE
			for(var/X in target.bioHolder.effectPool)
				BE = target.bioHolder.effectPool[X]
				if (BE && BE.id == gene_to_activate)
					if (target.bioHolder.ActivatePoolEffect(BE,overrideDNA = 1,grant_research = 0) && !isnpcmonkey(target) && target.client)
						src.expended_properly = 1
					break
			src.uses--
			src.update_appearance()

		update_appearance()
			if(src.uses < 1)
				if (expended_properly)
					src.icon_state = "activator_3"
					src.desc = "A [src] that has been filled with useful genetic information."
					src.name = "filled " + src.name
				else
					src.icon_state = "activator_2"
					src.desc = "A [src] that has been used up. It should be disposed of."
					src.name = "expended " + src.name

/datum/action/bar/icon/genetics_injector
	duration = 20
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "genetics_injector"
	icon = 'icons/obj/syringe.dmi'
	icon_state = "injector_1"
	var/mob/living/carbon/target = null
	var/obj/item/genetics_injector/injector = null

	New(Target,Injector)
		target = Target
		injector = Injector
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || injector == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/living/ownerMob = owner
		if(ownerMob.r_hand != injector && ownerMob.l_hand != injector)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || injector == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/living/ownerMob = owner
		if(ownerMob.r_hand != injector && ownerMob.l_hand != injector)
			interrupt(INTERRUPT_ALWAYS)
			return
		owner.visible_message("<span class='alert'><b>[owner.name] begins to inject [target.name] with [injector]!</b></span>")

	onEnd()
		..()
		owner.visible_message("<span class='alert'><b>[owner.name] injects [target.name] with [injector].</b></span>")
		injector.injected(owner,target)

// Traitor item
/obj/item/speed_injector
	name = "screwdriver"
	desc = "A hollow tool used to turn slotted screws and other slotted objects."
	icon = 'icons/obj/items/tools/screwdriver.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/screwdriver.dmi'
	icon_state = "screwdriver"
	flags = FPRINT | TABLEPASS | CONDUCT
	object_flags = NO_GHOSTCRITTER
	w_class = W_CLASS_TINY
	hide_attack = ATTACK_FULLY_HIDDEN
	tool_flags = TOOL_SCREWING
	var/obj/item/genetics_injector/dna_injector/payload = null

	attack_self(var/mob/user as mob)
		if (istype(payload))
			boutput(user, "You unload [payload].")
			payload.set_loc(get_turf(user))
			payload = null
		return

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/genetics_injector/dna_injector/))
			if (payload)
				boutput(user, "<span class='alert'>The injector is already loaded.</span>")
				return
			var/obj/item/genetics_injector/dna_injector/DI = W
			if (!istype(DI.BE) || DI.uses < 1)
				boutput(user, "<span class='alert'>The injector is rejecting [DI]. It mustn't be usable.</span>")
				return
			user.drop_item()
			DI.set_loc(src)
			src.payload = DI
			DI.BE.msgGain = ""
			DI.BE.msgLose = ""
			DI.BE.add_delay = 100
			boutput(user, "You slot [DI] into the injector.")
		else
			..()
		return

	attack(mob/M, mob/user)
		if (!iscarbon(M))
			return
		if (payload)
			boutput(user, "<span class='alert'>You stab [M], injecting them.</span>")
			logTheThing(LOG_COMBAT, user, "stabs [constructTarget(M,"combat")] with the speed injector (<b>Payload:</b> [payload.name]).")
			payload.injected(user,M)
			qdel(payload)
			payload = null
		else
			boutput(user, "<span class='alert'>You stab [M], but nothing happens.</span>")
		return

#define SCRAMBLER_MODE_COPY "copy"
#define SCRAMBLER_MODE_PASTE "paste"
#define SCRAMBLER_MODE_DEPLETED "depleted"

/obj/item/dna_scrambler
	name = "dna scrambler"
	desc = "An illegal retroviral genetic serum designed to randomize the user's identity, store it, and apply it later."
	icon = 'icons/obj/syringe.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "syringe_0"
	icon_state = "dna_scrambler_1"
	force = 3
	throwforce = 3
	w_class = W_CLASS_SMALL
	var/use_mode = SCRAMBLER_MODE_COPY
	var/datum/bioHolder/bioHolder = new/datum/bioHolder
	var/stored_name
	contraband = 2

	attack(mob/M, mob/user)
		if(!M || !user)
			return

		if(src.use_mode == SCRAMBLER_MODE_DEPLETED)
			boutput(user, "<span class='alert'>The [name] is expended and has no more uses.</span>")
			return

		if(M == user)

			if(use_mode == SCRAMBLER_MODE_COPY)
				src.copy_identity(user,user)
				user.visible_message("<span class='alert'><b>You inject yourself with the [src]! Your appearance has been copied to the [src].</b></span>")
				return

			if(use_mode == SCRAMBLER_MODE_PASTE)
				src.paste_identity(user,user)
				user.visible_message("<span class='alert'><b>You inject yourself with the [src]! The [src] has been totally used up.</b></span>")
				return

		else
			logTheThing(LOG_COMBAT, user, "injects [constructTarget(M,"combat")] with [src.name] at [log_loc(user)]")

			if(use_mode == SCRAMBLER_MODE_COPY)
				src.copy_identity(user,M)
				user.visible_message("<span class='alert'><b>You stab [M] with the DNA injector. [M]'s appearance has been copied to the [src].</b></span>")
				return

			if(use_mode == SCRAMBLER_MODE_PASTE)
				src.paste_identity(user,M)
				user.visible_message("<span class='alert'><b>You stab [M] with the DNA injector. The [src] has been totally used up.</b></span>")
				return

	proc/copy_identity(var/mob/living/carbon/user,var/mob/living/carbon/target)
		if (ishuman(target))
			src.use_mode = SCRAMBLER_MODE_PASTE
			boutput(target, "<span class='alert'>Your body changes! You feel completely different!</span>")
			src.bioHolder.CopyOther(target.bioHolder)
			stored_name = target.name
			randomize_look(target)
			UpdateIcon()

	proc/paste_identity(var/mob/living/carbon/user,var/mob/living/carbon/target)
		if (ishuman(target))
			src.use_mode = SCRAMBLER_MODE_DEPLETED
			boutput(target, "<span class='alert'>Your body changes! You feel completely different!</span>")
			target.bioHolder.CopyOther(src.bioHolder)
			target.name = src.stored_name
			target.real_name = src.stored_name
			UpdateIcon()

			if(src.bioHolder?.mobAppearance?.mutant_race)
				target.set_mutantrace(src.bioHolder.mobAppearance.mutant_race.type)
			else
				target.set_mutantrace(null)

	update_icon()
		if (src.use_mode == SCRAMBLER_MODE_COPY)
			src.icon_state = "dna_scrambler_1"

		if (src.use_mode == SCRAMBLER_MODE_PASTE)
			src.icon_state = "dna_scrambler_2"

		if (src.use_mode == SCRAMBLER_MODE_DEPLETED)
			src.icon_state = "dna_scrambler_3"

#undef SCRAMBLER_MODE_COPY
#undef SCRAMBLER_MODE_PASTE
#undef SCRAMBLER_MODE_DEPLETED
