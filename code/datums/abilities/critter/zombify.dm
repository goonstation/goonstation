/datum/targetable/critter/zombify
	name = "Zombify"
	desc = "After a short delay, instantly convert a human into a zombie."
	icon_state = "critter_bite"
	cooldown = 200
	cooldown_after_action = TRUE
	disabled = FALSE
	targeted = TRUE

	cast(atom/target)
		if (..())
			return 1
		if (disabled)
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living/) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("Nothing to zombify there."))
				return 1
		if (!ishuman(target))
			boutput(holder.owner, SPAN_ALERT("Invalid target."))
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("That is too far away to zombify."))
			return 1
		var/mob/living/carbon/human/H = target
		if (istype(H.mutantrace, /datum/mutantrace/zombie))
			boutput(holder.owner, SPAN_ALERT("You can't infect another zombie!"))
			return 1
		actions.start(new/datum/action/bar/icon/zombify_ability(target, src), holder.owner)
		return 0


/datum/action/bar/icon/zombify_ability
	duration = 6 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "zomb_over"
	var/mob/living/target
	var/datum/targetable/critter/zombify/zombify

	var/image/mask = null
	var/image/head = null
	var/image/uniform = null
	var/image/back = null
	var/image/suit = null

	New(Target, Zombify)
		target = Target
		zombify = Zombify
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || target == owner || !zombify || !zombify.cooldowncheck())
			zombify.disabled = FALSE
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || target == owner || !zombify || !zombify.cooldowncheck())
			zombify.disabled = FALSE
			interrupt(INTERRUPT_ALWAYS)
			return
		owner.visible_message(SPAN_ALERT("<B>[owner] attempts to gnaw into [target]!</B>"))
		zombify.disabled = TRUE

	onEnd()
		..()
		if (BOUNDS_DIST(owner, target) > 0 || !target || !is_incapacitated(target))
			owner.visible_message(SPAN_ALERT("<B>[owner]</B> gnashes its teeth in fustration!"))
			zombify.disabled = FALSE
			return
		if(iscarbon(target))
			owner.visible_message(SPAN_ALERT("<B>[owner]</B> slurps up [target]'s brain!"))
			playsound(owner.loc, 'sound/items/eatfood.ogg', 30, 1, -2)
			logTheThing(LOG_COMBAT, target, "was critter zombified by [owner] at [log_loc(owner)].") // Some logging for instakill critters would be nice (Convair880).
			APPLY_ATOM_PROPERTY(target, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)
			target.death(TRUE)
			target.ghostize()
			var/mob/living/critter/zombie/zombie = new /mob/living/critter/zombie(target.loc)
			zombie.visible_message(SPAN_ALERT("[target]'s corpse reanimates!"))
			var/stealthy = 0 //High enough and people won't even see it's undead right away.
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				//Uniform
				if(H.w_uniform)
					if (istype(H.w_uniform, /obj/item/clothing/under))
						ENSURE_IMAGE(src.uniform, H.w_uniform.wear_image_icon, H.w_uniform.item_state)
						zombie.UpdateOverlays(src.uniform, "uniform")
						stealthy += 4
				//Suit
				if(H.wear_suit)
					if (istype(H.wear_suit, /obj/item/clothing/suit))
						ENSURE_IMAGE(src.suit, H.wear_suit.wear_image_icon, H.wear_suit.item_state)
						zombie.UpdateOverlays(src.suit, "suit")
						stealthy += 3
				//Back
				if(H.back)
					ENSURE_IMAGE(src.back, H.back.wear_image_icon, H.back.item_state)
					zombie.UpdateOverlays(src.back, "back")
					stealthy++
				//Mask
				if (H.wear_mask)
					if (istype(H.wear_mask, /obj/item/clothing/mask))
						ENSURE_IMAGE(src.mask, H.wear_mask.wear_image_icon, H.wear_mask.item_state)
						zombie.UpdateOverlays(src.mask, "mask")
						if (H.wear_mask.c_flags & COVERSEYES)
							stealthy += 2
						if (H.head.c_flags & COVERSMOUTH)
							stealthy += 2
				//Head
				if (H.head)
					ENSURE_IMAGE(src.head, H.head.wear_image_icon, H.head.icon_state)
					zombie.UpdateOverlays(src.head, "head")
					if (H.head.c_flags & COVERSEYES)
						stealthy += 2
					if (H.head.c_flags & COVERSMOUTH)
						stealthy += 2

			if(stealthy >= 10)
				zombie.name = target.real_name
			else
				zombie.name += " [target.real_name]"

			qdel(target)
			zombify.disabled = FALSE
			zombify.afterAction()
