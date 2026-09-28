/datum/component/throw_eat
	var/mob/eater

/datum/component/throw_eat/Initialize(mob/eater)
	. = ..()
	src.eater = eater
	src.RegisterSignal(src.parent, COMSIG_MOVABLE_HIT_THROWN, PROC_REF(hit))
	src.RegisterSignal(src.parent, COMSIG_MOVABLE_THROW_END, PROC_REF(throw_end))

/datum/component/throw_eat/proc/hit(thrown_atom, hit_target, datum/thrown_thing/throw_datum)
	if (hit_target == src.eater)
		if (src.try_eat())
			src.RemoveComponent()
			return TRUE

/datum/component/throw_eat/proc/try_eat()
	if (isitem(src.parent))
		var/obj/item/snack = src.parent
		if (snack.Eat(src.eater, src.eater))
			return TRUE
	return FALSE

/datum/component/throw_eat/proc/throw_end()
	if (src.parent)
		src.RemoveComponent()

/datum/component/throw_eat/UnregisterFromParent()
	. = ..()
	src.UnregisterSignal(src.parent, COMSIG_MOVABLE_HIT_THROWN)
	src.UnregisterSignal(src.parent, COMSIG_MOVABLE_THROW_END)

/datum/component/throw_eat/insects

/datum/component/throw_eat/insects/try_eat()
	if (..())
		return TRUE
	if (!istype(src.parent, /mob/living/critter/small_animal))
		return FALSE
	var/mob/living/critter/small_animal/cool_bug = src.parent
	if (!cool_bug.edible_insect)
		return FALSE
	cool_bug.reagents?.trans_to(src.eater)
	cool_bug.death()
	eat_twitch(src.eater)
	playsound(src.eater.loc,'sound/misc/gulp.ogg', 80, 1)
	src.eater.visible_message(SPAN_ALERT("[src.eater] swallows [src.parent] in one bite!"))
	qdel(cool_bug)
	if (ishuman(src.eater))
		var/mob/living/carbon/human/human = src.eater
		human.sims?.affectMotive("Hunger", 20) //the same as a picky eater eating their favourite food
	SPAWN(2 SECONDS)
		src.eater.emote("burp")
	return TRUE

