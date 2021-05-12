/datum/targetable/spell/shock
	name = "Shocking Touch"
	desc = "Shocks the victim with electrical power, which can arc to nearby people and stun them. Takes a few seconds to cast."
	icon_state = "grasp"
	targeted = 1
	max_range = 2
	cooldown = 450
	requires_robes = 1
	offensive = 1
	sticky = 1
	voice_grim = "sound/voice/wizard/ShockingGraspGrim.ogg"
	voice_fem = "sound/voice/wizard/ShockingGraspFem.ogg"
	voice_other = "sound/voice/wizard/ShockingGraspLoud.ogg"
	var/wattage = 100000
	var/burn_damage = 100
	var/target_damage_modifier = 1.95
	var/arc_range = 3

	cast(mob/target)
		if(!holder)
			return
		if(!istype(target))
			return 1
		playsound(holder.owner.loc, "sound/effects/elec_bzzz.ogg", 25, 1, -1)
		holder.owner.say("EI NATH")
		..()

		playsound(holder.owner.loc, "sound/effects/elec_bigzap.ogg", 25, 1, -1)

		if (ishuman(target))
			if (target.traitHolder.hasTrait("training_chaplain"))
				boutput(holder.owner, "<span class='alert'>[target] has divine protection from magic.</span>")
				target.visible_message("<span class='alert'>The electric charge courses through [target] harmlessly!</span>")
				JOB_XP(target, "Chaplain", 2)
				return
			else if (iswizard(target))
				target.visible_message("<span class='alert'>The electric charge somehow completely misses [target]!</span>")
				return

		if (holder.owner.wizard_spellpower(src))
			elecflash(target,power = 4, exclude_center = 0)
			//target.elecgib()
			arcFlash(holder.owner, target, 0) // we just want the effect, the damage is taken care of below
			target.TakeDamage("chest", 0, burn_damage / target_damage_modifier, 0, DAMAGE_BURN)
			var/count = 0
			for (var/mob/living/L in oview(src.arc_range, target))
				if (iswizard(L))
					continue
				count++
			for (var/mob/living/L in oview(src.arc_range, target))
				if (iswizard(L))
					continue
				arcFlash(target, L, max(src.wattage / count, 1)) // adds some randomness to the damage
				target.TakeDamage("chest", 0, burn_damage / count, 0, DAMAGE_BURN)
		else
			elecflash(target,power = 2)
			boutput(holder.owner, "<span class='alert'>Your spell is weak without a staff to focus it!</span>")
			target.visible_message("<span class='alert'>[target] is severely burned by an electrical charge!</span>")
			target.lastattacker = holder.owner
			target.lastattackertime = world.time
			target.TakeDamage("chest", 0, 40, 0, DAMAGE_BURN)
			target.changeStatus("stunned", 6 SECONDS)
			target.changeStatus("weakened", 6 SECONDS)
			target.stuttering += 10
