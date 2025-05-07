/datum/targetable/spell/blind
	name = "Blind"
	desc = "Makes the victim temporarily unable to see."
	icon_state = "blind"
	targeted = 1
	cooldown = 100
	requires_robes = 1
	requires_being_on_turf = TRUE
	offensive = 1
	sticky = 1
	voice_grim = 'sound/voice/wizard/BlindGrim.ogg'
	voice_fem = 'sound/voice/wizard/BlindFem.ogg'
	voice_other = 'sound/voice/wizard/BlindLoud.ogg'
	maptext_colors = list("#ffffff", "#9c9fa2", "#585c68")

	cast(mob/target)
		if(!holder)
			return
		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("YSTIGG MITAZIM", flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))
		..()

		elecflash(target)

		if (target.traitHolder.hasTrait("training_chaplain"))
			boutput(holder.owner, SPAN_ALERT("[target] has divine protection from magic."))
			target.visible_message(SPAN_ALERT("The spell fails to work on [target]!"))
			JOB_XP(target, "Chaplain", 2)
			return

		if (iswizard(target))
			target.visible_message(SPAN_ALERT("The spell fails to work on [target]!"))
			return

		var/obj/overlay/B = new /obj/overlay(target.loc)
		B.icon_state = "blspell"
		B.icon = 'icons/obj/wizard.dmi'
		B.name = "spell"
		B.anchored = ANCHORED
		B.set_density(0)
		B.layer = MOB_EFFECT_LAYER
		target.canmove = 0
		SPAWN(0.5 SECONDS)
			qdel(B)
			target.canmove = 1
		boutput(target, SPAN_NOTICE("Your eyes cry out in pain!"))
		target.visible_message(SPAN_ALERT("Sparks fly out of [target]'s eyes!"))

		//Wire: People wearing cure-blindness glasses should get a LITTLE protection from the blind spell
		var/blindProtected = 0
		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (istype(H.glasses, /obj/item/clothing/glasses))
				var/obj/item/clothing/glasses/G = H.glasses
				if (G.allow_blind_sight)
					blindProtected = 1

		if (holder.owner.wizard_spellpower(src))
			target.changeStatus("knockdown", 2 SECONDS)
			if (!blindProtected)
				target.bioHolder.AddEffect("bad_eyesight")
				SPAWN(45 SECONDS)
					if (target) target.bioHolder.RemoveEffect("bad_eyesight")
			target.take_eye_damage(blindProtected ? 5 : 10, 1)
			target.change_eye_blurry(blindProtected ? 10 : 20)
		else
			boutput(holder.owner, SPAN_ALERT("Your spell doesn't last as long without a staff to focus it!"))
			target.changeStatus("knockdown", 1 SECOND)
			if (!blindProtected)
				target.bioHolder.AddEffect("bad_eyesight")
				SPAWN(30 SECONDS)
					target.bioHolder.RemoveEffect("bad_eyesight")
			target.take_eye_damage(blindProtected ? 2 : 4, 1)
			target.change_eye_blurry(blindProtected ? 5 : 10)
