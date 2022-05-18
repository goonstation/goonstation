var/list/animal_spell_critter_paths = list(/mob/living/critter/small_animal/cat,
/mob/living/critter/small_animal/dog,
/mob/living/critter/small_animal/dog/corgi,
/mob/living/critter/small_animal/dog/shiba,
/mob/living/critter/small_animal/bird/random,
/mob/living/critter/small_animal/bird/owl,
/mob/living/critter/small_animal/bird/turkey,
/mob/living/critter/small_animal/bird/timberdoodle,
/mob/living/critter/small_animal/bird/seagull,
/mob/living/critter/small_animal/sparrow,
/mob/living/critter/small_animal/bird/crow,
/mob/living/critter/small_animal/bird/goose,
/mob/living/critter/small_animal/bird/goose/swan,
/mob/living/critter/small_animal/floateye,
/mob/living/critter/small_animal/pig,
/mob/living/critter/small_animal/bat,
/mob/living/critter/small_animal/bat/angry,
/mob/living/critter/spider/nice,
/mob/living/critter/spider/clown,
/mob/living/critter/small_animal/fly,
/mob/living/critter/small_animal/mosquito,
/mob/living/critter/spider/baby,
/mob/living/critter/spider/ice/baby,
/mob/living/critter/small_animal/wasp,
/mob/living/critter/small_animal/raccoon,
/mob/living/critter/small_animal/seal,
/mob/living/critter/small_animal/walrus,
/mob/living/critter/small_animal/slug,
/mob/living/critter/small_animal/slug/snail,
/mob/living/critter/small_animal/bee,
/mob/living/critter/maneater_polymorph,
/mob/living/critter/fermid_polymorph,
/mob/living/critter/small_animal/crab_polymorph)

/datum/targetable/spell/animal
	name = "Baleful Polymorph" // todo: a decent name - done?
	desc = "Turns the target into a creature of some sort."
	icon_state = "animal"
	targeted = 1
	max_range = 1
	cooldown = 1350
	requires_robes = 1
	offensive = 1
	sticky = 1
	voice_grim = "sound/voice/wizard/FurryGrim.ogg"
	voice_fem = "sound/voice/wizard/FurryFem.ogg"
	voice_other = "sound/voice/wizard/FurryLoud.ogg"

	cast(mob/target)
		if (!holder)
			return 1

		if (!ishuman(target))
			boutput(holder.owner, "Your target must be human!")
			return 1

		var/mob/living/carbon/human/H = target

		if (targetSpellImmunity(H, TRUE, 2))
			return 1

		holder.owner.visible_message("<span class='alert'><b>[holder.owner] begins to cast a spell on [H]!</b></span>")
		actions.start(new/datum/action/bar/polymorph(usr, target, src), holder.owner)

/datum/action/bar/polymorph
	duration = 2 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "polymorph_spell"

	var/datum/targetable/spell/animal/spell
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
			M.say("YORAF UHRY") // AN EMAL? PAL EMORF? TURAN SPHORM?
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

		if (target.mind && (target.mind.assigned_role != "Animal") || (!target.mind || !target.client))
			boutput(target, "<span class='alert'><B>You feel your flesh painfully ripped apart and reformed into something else!</B></span>")
			if (target.mind)
				target.mind.assigned_role = "Animal"
			target.emote("scream", 0)

			target.unequip_all()
			var/mob/living/critter/C = target.make_critter(pick(animal_spell_critter_paths))
			C.real_name = "[target.real_name] the [C.real_name]"
			C.name = C.real_name
			logTheThing("combat", M, target, "casts the Polymorph spell on [constructTarget(target,"combat")] turning them into [constructTarget(C,"combat")] at [log_loc(C)].")
			C.butcherable = 1 // we would like the brain to be recoverable, please
			if (istype(C, /mob/living/critter/small_animal/bee))
				var/mob/living/critter/small_animal/bee/B = C
				B.non_admin_bee_allowed = 1
			if (istype(C))
				C.change_misstep_chance(30)
				C.stuttering = 40
				C.show_antag_popup("polymorph")
