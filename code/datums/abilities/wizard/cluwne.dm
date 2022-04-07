/datum/targetable/spell/cluwne
	name = "Clown's Revenge"
	desc = "Turns the target into a cursed clown."
	icon_state = "clownrevenge"
	targeted = 1
	max_range = 1
	cooldown = 1350
	requires_robes = 1
	offensive = 1
	sticky = 1
	voice_grim = "sound/voice/wizard/CluwneGrim.ogg"
	voice_fem = "sound/voice/wizard/CluwneFem.ogg"
	voice_other = "sound/voice/wizard/CluwneLoud.ogg"

	cast(mob/target)
		if(!holder)
			return 1

		if (!ishuman(target))
			boutput(holder.owner, "Your target must be human!")
			return 1

		var/mob/living/carbon/human/H = target

		if (targetSpellImmunity(H, TRUE, 2))
			return 1

		holder.owner.visible_message("<span class='alert'><b>[holder.owner] begins to cast a spell on [H]!</b></span>")
		actions.start(new/datum/action/bar/icon/cluwne_spell(usr, target, src), holder.owner)

/datum/action/bar/icon/cluwne_spell
	duration = 1.5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "cluwne_spell"
	icon = 'icons/ui/actions.dmi'
	icon_state = "cluwne"

	var/datum/targetable/spell/cluwne/spell
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

		if (isnull(A) || get_dist(M, target) > spell.max_range || isnull(M) || !ishuman(target) || !M.wizard_castcheck(spell))
			interrupt(INTERRUPT_ALWAYS)

	onUpdate()
		..()

		if (isnull(A) || get_dist(M, target) > spell.max_range || isnull(M) || !ishuman(target) || !M.wizard_castcheck(spell))
			interrupt(INTERRUPT_ALWAYS)

	onEnd()
		..()

		if(!istype(get_area(M), /area/sim/gunsim))
			M.say("NWOLC EGNEVER")
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(spell.voice_grim && H && istype(H.wear_suit, /obj/item/clothing/suit/wizrobe/necro) && istype(H.head, /obj/item/clothing/head/wizard/necro))
				playsound(H.loc, spell.voice_grim, 50, 0, -1)
			else if(spell.voice_fem && H.gender == "female")
				playsound(H.loc, spell.voice_fem, 50, 0, -1)
			else if (spell.voice_other)
				playsound(H.loc, spell.voice_other, 50, 0, -1)

		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(5, 0, target.loc)
		smoke.attach(target)
		smoke.start()
		logTheThing("combat", M, target, "casts a Cluwne spell on [constructTarget(target,"combat")] at [log_loc(target)].")
		if (target.job != "Cluwne")
			boutput(target, "<span class='alert'><B>You HONK painfully!</B></span>")
			target.take_brain_damage(50)
			target.stuttering = 120
			target.contract_disease(/datum/ailment/disability/clumsy/cluwne,null,null,1)
			target.contract_disease(/datum/ailment/disease/cluwneing_around/cluwne,null,null,1)
			target.job = "Cluwne"
			target.real_name = "cluwne"
			target.UpdateName()
			playsound(target, pick("sound/voice/cluwnelaugh1.ogg","sound/voice/cluwnelaugh2.ogg","sound/voice/cluwnelaugh3.ogg"), 35, 0, 0, clamp(1.0 + (30 - target.bioHolder.age)/50, 0.7, 1.4))
			target.change_misstep_chance(60)

			animate_clownspell(target)
			//target.unequip_all()
			target.drop_from_slot(target.w_uniform)
			target.drop_from_slot(target.shoes)
			target.drop_from_slot(target.wear_mask)
			target.drop_from_slot(target.gloves)
			target.equip_if_possible(new /obj/item/clothing/under/gimmick/cursedclown(target), target.slot_w_uniform)
			target.equip_if_possible(new /obj/item/clothing/shoes/cursedclown_shoes(target), target.slot_shoes)
			target.equip_if_possible(new /obj/item/clothing/mask/cursedclown_hat(target), target.slot_wear_mask)
			target.equip_if_possible(new /obj/item/clothing/gloves/cursedclown_gloves(target), target.slot_gloves)
			SPAWN(2.5 SECONDS) // Don't remove.
				if (target) target.assign_gimmick_skull() // The mask IS your new face, my friend (Convair880).
		else
			boutput(target, "<span class='alert'><b>You don't feel very funny.</b></span>")
			target.take_brain_damage(-120)
			target.stuttering = 0
			if (target.mind)
				target.mind.assigned_role = "Lawyer"
			target.change_misstep_chance(-INFINITY)

			animate_clownspell(target)
			for(var/datum/ailment_data/AD in target.ailments)
				if(istype(AD.master,/datum/ailment/disability/clumsy))
					target.cure_disease(AD)
			var/obj/old_uniform = target.w_uniform
			var/obj/item/the_id = target.wear_id

			if(target.w_uniform && findtext("[target.w_uniform.type]","clown"))
				target.w_uniform = new /obj/item/clothing/under/suit(target)
				qdel(old_uniform)

			if(target.shoes && findtext("[target.shoes.type]","clown"))
				qdel(target.shoes)
				target.shoes = new /obj/item/clothing/shoes/black(target)

			if(the_id && the_id:registered == target.real_name)
				if (istype(the_id, /obj/item/card/id))
					the_id:assignment = "Lawyer"
					the_id:name = "[target.real_name]'s ID Card (Lawyer)"
				else if (istype(the_id, /obj/item/device/pda2))
					the_id:assignment = "Lawyer"
					the_id:ID_card:assignment = "Lawyer"
					the_id:ID_card:name = "[target.real_name]'s ID Card (Lawyer)"
				target.wear_id = the_id

			for(var/obj/item/W in target)
				if (findtext("[W.type]","clown"))
					target.u_equip(W)
					if (W)
						W.set_loc(target.loc)
						W.dropped(target)
						W.layer = initial(W.layer)
