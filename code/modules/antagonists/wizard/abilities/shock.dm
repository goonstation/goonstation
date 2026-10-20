/datum/targetable/spell/shock
	name = "Shocking Touch"
	desc = "Shocks the victim with electrical power."
	icon_state = "grasp"
	targeted = 1
	max_range = 2
	cooldown = 450
	requires_robes = 1
	requires_being_on_turf = TRUE
	offensive = 1
	sticky = 1
	voice_grim = 'sound/voice/wizard/ShockingGraspGrim.ogg'
	voice_fem = 'sound/voice/wizard/ShockingGraspFem.ogg'
	voice_other = 'sound/voice/wizard/ShockingGraspLoud.ogg'
	maptext_colors = list("#ebb02b", "#fcf574", "#ebb02b", "#fcf574", "#ebf0f2")
	voice_on_cast_start = FALSE

	cast(mob/target)
		if(!holder)
			return 1

		if (!ishuman(target))
			boutput(holder.owner, "Your target must be human!")
			return 1

		if(!can_act(holder.owner))
			boutput(holder.owner, "You can't cast this whilst incapacitated!")
			return 1

		. = ..()
		var/mob/living/carbon/human/H = target

		if (targetSpellImmunity(H, TRUE, 2))
			return 1

		holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] begins to cast a spell on [H]!</b>"))
		actions.start(new/datum/action/bar/shocking_touch(usr, target, src), holder.owner)

/datum/action/bar/shocking_touch
	duration = 0.6 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION

	var/datum/targetable/spell/shock/spell
	var/mob/living/carbon/human/target
	var/datum/abilityHolder/A
	var/mob/living/M

	New(Source, Target, Spell)
		target = Target
		spell = Spell
		A = spell.holder
		M = Source
		..()


	onStart()
		..()

		if (isnull(A) || GET_DIST(M, target) > spell.max_range || isnull(M) || !ishuman(target) || !M.wizard_castcheck(spell))
			interrupt(INTERRUPT_ALWAYS)

	onUpdate()
		..()

		if (isnull(A) || GET_DIST(M, target) > spell.max_range || isnull(M) || !ishuman(target) || !M.wizard_castcheck(spell))
			interrupt(INTERRUPT_ALWAYS)

	onEnd()
		..()

		if(!istype(get_area(M), /area/sim/gunsim))
			M.say("EI NATH", flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = spell.maptext_style, "maptext_animation_colours" = spell.maptext_colors))

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(spell.voice_grim && H && istype(H.wear_suit, /obj/item/clothing/suit/wizrobe/necro) && istype(H.head, /obj/item/clothing/head/wizard/necro))
				playsound(H.loc, spell.voice_grim, 50, 0, -1)
			else if(spell.voice_fem && H.gender == "female")
				playsound(H.loc, spell.voice_fem, 50, 0, -1)
			else if (spell.voice_other)
				playsound(H.loc, spell.voice_other, 50, 0, -1)

		playsound(M.loc, 'sound/effects/elec_bigzap.ogg', 35, 1, -1)

		if (M.wizard_spellpower(src))
			elecflash(target, power = 4, exclude_center = 0)
			arcFlash(M, target, 0) // aesthetic
			target.TakeDamage("chest", 0, 101, 0, DAMAGE_BURN)
			target.changeStatus("stunned", 3 SECONDS)
			target.changeStatus("knockdown", 3 SECONDS)
			target.stuttering += 6 SECONDS

		else
			elecflash(target, power = 4, exclude_center = 0)
			boutput(M, SPAN_ALERT("Your spell is weak without a staff to focus it!"))
			target.TakeDamage("chest", 0, 40, 0, DAMAGE_BURN)

