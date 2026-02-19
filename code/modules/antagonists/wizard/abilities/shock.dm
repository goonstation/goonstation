/datum/targetable/spell/shock
	name = "Shocking Touch"
	desc = "Shocks the victim with electrical power, which can arc to nearby people and stun them. Takes a few seconds to cast."
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
	var/wattage = 100000
	var/burn_damage = 100
	var/target_damage_modifier = 1.95
	var/arc_range = 3
	maptext_colors = list("#ebb02b", "#fcf574", "#ebb02b", "#fcf574", "#ebf0f2")

	cast(mob/target)
		if(!holder)
			return
		if(!istype(target))
			return 1
		if(!IN_RANGE(target, holder.owner, max_range))
			return 1
		playsound(holder.owner.loc, 'sound/effects/elec_bzzz.ogg', 25, 1, -1)
		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("EI NATH", flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))
		..()

		playsound(holder.owner.loc, 'sound/effects/elec_bigzap.ogg', 25, 1, -1)

		if (ishuman(target))
			if (target.traitHolder.hasTrait("training_chaplain"))
				boutput(holder.owner, SPAN_ALERT("[target] has divine protection from magic."))
				target.visible_message(SPAN_ALERT("The electric charge courses through [target] harmlessly!"))
				JOB_XP(target, "Chaplain", 2)
				return
			else if (iswizard(target))
				target.visible_message(SPAN_ALERT("The electric charge somehow completely misses [target]!"))
				return

		if (holder.owner.wizard_spellpower(src))
			elecflash(target,power = 4, exclude_center = 0)
			//target.elecgib()
			arcFlash(holder.owner, target, 0) // we just want the effect, the damage is taken care of below
			var/target_damage = burn_damage / target_damage_modifier
			target.TakeDamage("chest", 0, target_damage, 0, DAMAGE_BURN)
			var/count = 0
			for (var/mob/living/L in oview(src.arc_range, target))
				if (iswizard(L))
					continue
				count++
			for (var/mob/living/L in oview(src.arc_range, target))
				if (iswizard(L))
					continue
				arcFlash(target, L, max(src.wattage / count, 1)) // adds some randomness to the damage
				L.TakeDamage("chest", 0, min(burn_damage / count, target_damage), 0, DAMAGE_BURN)
		else
			elecflash(target,power = 2)
			boutput(holder.owner, SPAN_ALERT("Your spell is weak without a staff to focus it!"))
			target.visible_message(SPAN_ALERT("[target] is severely burned by an electrical charge!"))
			target.lastattacker = get_weakref(holder.owner)
			target.lastattackertime = world.time
			target.TakeDamage("chest", 0, 40, 0, DAMAGE_BURN)
			target.changeStatus("stunned", 6 SECONDS)
			target.changeStatus("knockdown", 6 SECONDS)
			target.stuttering += 10
