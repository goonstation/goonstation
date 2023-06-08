/datum/action/bar/icon/maneater_devour
	duration = 8 SECONDS
	//no cancelling by moving the maneater. You gotta rip the person right out of their hands!
	interrupt_flags =  INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "maneater_devour"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	bar_icon_state = "bar"
	border_icon_state = "border"
	color_active = "#d73715"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/target
	var/datum/targetable/critter/maneater_devour/originating_ability

	New(victim, devour_ability)
		src.target = victim
		src.originating_ability = devour_ability
		..()

	onUpdate()
		..()

		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !originating_ability)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/ownerMob = owner
		var/obj/item/grab/G = ownerMob.equipped()

		if (!istype(G) || G.affecting != target || G.state == GRAB_PASSIVE)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !originating_ability)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/ownerMob = owner
		ownerMob.show_message("<span class='notice'>We must hold still for a moment...</span>", 1)

	onEnd()
		..()

		var/mob/ownerMob = owner
		if(owner && ownerMob && target && BOUNDS_DIST(owner, target) == 0 && originating_ability)
			boutput(ownerMob, "<span class='notice'>You devour [target]!</span>")
			ownerMob.visible_message(text("<span class='alert'><B>[ownerMob] hungrily devours [target]!</B></span>"))
			playsound(ownerMob.loc, 'sound/voice/burp_alien.ogg', 50, 1)
			logTheThing(LOG_COMBAT, ownerMob, "devours [constructTarget(target,"combat")] as a maneater [log_loc(owner)].")

			target.ghostize()
			qdel(target)

	onInterrupt()
		..()
		boutput(owner, "<span class='alert'>Our feasting on [target] has been interrupted!</span>")

/datum/targetable/critter/maneater_devour
	name = "Devour"
	desc = "Almost instantly devour a human."
	icon_state = "maneater_munch"
	cooldown = 20 SECONDS
	targeted = 1
	target_anything = 1

	cast(atom/target)
		if (..())
			return 1
		var/mob/living/caster = holder.owner

		var/obj/item/grab/G = src.grab_check(null, 1, 1)
		if (!G || !istype(G))
			return 1
		var/mob/living/carbon/human/victim = G.affecting

		if (!istype(victim))
			boutput(caster, "<span class='alert'>This creature isn't suitable for your stomach.</span>")
			return 1

		actions.start(new/datum/action/bar/icon/maneater_devour(victim, src), caster)
		return 0
