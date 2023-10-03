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
			holder.owner.say("EI NATH", FALSE, maptext_style, maptext_colors)
		..()

		playsound(holder.owner.loc, 'sound/effects/elec_bigzap.ogg', 25, 1, -1)

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
			elecflash(target,power = 1, exclude_center = 1) // this was cool, but ended up backfiring and hitting the wizard, so now it is purely visual
			//target.elecgib()
			arcFlash(holder.owner, target, 0) // we just want the effect, the damage is taken care of below
			target.TakeDamage("chest", 0, burn_damage / target_damage_modifier, 0, DAMAGE_BURN)
			target.changeStatus("stunned", 6 SECONDS)
			target.changeStatus("weakened", 6 SECONDS)
			target.do_disorient(100, disorient = 40, remove_stamina_below_zero = 1)
			target.stuttering += 10
			var/count = 0
			for (var/mob/living/L in oview(src.arc_range, target))
				if (iswizard(L))
					continue
				count++
			for (var/mob/living/L in oview(src.arc_range, target))
				if (iswizard(L))
					continue
				arcFlash(target, L, 0) // this was cool, but ended up backfiring and hitting the wizard, so now it is purely visual and the damage is handled manually
				var/applied_wattage = max(src.wattage / count, 1)
				var/shock_damage = 0
				if (applied_wattage > 7500)
					shock_damage = (max(rand(10,20), round(applied_wattage * 0.00004)))
					L.changeStatus("stunned", 1 SECONDS)
				else if (applied_wattage > 5000)
					shock_damage = 15
				else if (applied_wattage > 2500)
					shock_damage = 5
				else
					shock_damage = 1
				L.TakeDamage("chest", 0, (burn_damage+shock_damage) / count, 0, DAMAGE_BURN)
				L.do_disorient(100, disorient = 40, remove_stamina_below_zero = 1)
		else
			elecflash(target,power = 1)
			boutput(holder.owner, "<span class='alert'>Your spell is weak without a staff to focus it!</span>")
			target.visible_message("<span class='alert'>[target] is severely burned by an electrical charge!</span>")
			target.lastattacker = holder.owner
			target.lastattackertime = world.time
			target.TakeDamage("chest", 0, 40, 0, DAMAGE_BURN)
			target.changeStatus("stunned", 6 SECONDS)
			target.changeStatus("weakened", 6 SECONDS)
			target.stuttering += 10
