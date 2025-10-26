ABSTRACT_TYPE(/datum/vampire_ritual)
/datum/vampire_ritual
	/// The name of this ritual.
	var/name = "ritual parent"
	/// This ritual's parent ritual circle.
	var/obj/decal/cleanable/vampire_ritual_circle/parent = null
	/// Whether this ritual is able to be cast multiple times.
	var/repeatable = TRUE
	/// The current stage of the ritual. Corresponds to the index of the last incantation line heard.
	var/ritual_stage = 0
	/// The incantation lines required to start and progress this ritual.
	var/list/incantation_lines = list(
		"ritual parent line #1",
		"ritual parent line #2",
		"ritual parent line #3",
	)
	/// This ritual's major sacrifice, found at the centre of the ritual circle.
	var/atom/movable/major_sacrifice = null
	/// This ritual's minor sacrifices, found around the ritual circle in the smaller sacrificial circles.
	var/list/obj/item/minor_sacrifices = null
	/// The blood cost of this ritual, to be deducted from the coven's shared blood meter.
	var/blood_cost = 0
	/// Any information that should be announced to vampchat on this ritual's completion.
	var/additional_completion_text = ""
	/// Whether this ritual has been completed.
	var/ritual_completed = FALSE
	/// The duration that this ritual should continue to be active for after completion.
	var/ritual_duration = 0 SECONDS

/datum/vampire_ritual/New(obj/decal/cleanable/vampire_ritual_circle/parent)
	. = ..()
	src.parent = parent
	src.parent.current_ritual = src
	src.minor_sacrifices = list()

/datum/vampire_ritual/disposing()
	src.minor_sacrifices = null
	src.parent = null
	. = ..()

/datum/vampire_ritual/proc/unload_ritual()
	src.parent.current_ritual = null
	src.ritual_clean_up()

	// Allocate some time for the ritual to finish special effects.
	SPAWN(5 SECONDS)
		qdel(src)

/datum/vampire_ritual/proc/can_invoke_ritual()
	var/datum/vampire_coven/coven = global.get_singleton(/datum/vampire_coven)
	if (coven.blood < src.blood_cost)
		return FALSE

	if (!src.sacrifice_conditions_met())
		return FALSE

	return TRUE

/datum/vampire_ritual/proc/sacrifice_conditions_met()
	return TRUE

/datum/vampire_ritual/proc/set_major_sacrifice(atom/movable/AM)
	src.major_sacrifice = AM
	src.major_sacrifice.anchored = ANCHORED

	if (isliving(src.major_sacrifice))
		var/mob/living/L = src.major_sacrifice
		L.canbedisarmed = FALSE
		L.canbegrabbed = FALSE

/datum/vampire_ritual/proc/unset_major_sacrifice()
	if (!src.major_sacrifice)
		return

	if (isliving(src.major_sacrifice))
		var/mob/living/L = src.major_sacrifice
		L.canbedisarmed = TRUE
		L.canbegrabbed = TRUE

	src.major_sacrifice.anchored = UNANCHORED
	src.major_sacrifice = null

/datum/vampire_ritual/proc/add_minor_sacrifice(obj/item/I)
	src.minor_sacrifices += I

	var/matrix/M = matrix(I.transform)
	animate(I, time = rand(1, 3), loop = 3, transform = I.transform.Multiply(matrix(rand(10, 20) * pick(-1, 1), MATRIX_ROTATE)), easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	animate(time = rand(1, 3), loop = 3, transform = M, easing = SINE_EASING)

/datum/vampire_ritual/proc/accept_sacrifices()
	if (src.major_sacrifice)
		var/atom/movable/A = src.major_sacrifice
		A.remove_filter("ritual_outline")
		global.animate_shrinking_outline(A)

		SPAWN(2 SECONDS)
			QDEL_NULL(A)

	for (var/atom/movable/A as anything in src.minor_sacrifices)
		A.remove_filter("ritual_outline")
		global.animate_shrinking_outline(A)

		SPAWN(2 SECONDS)
			src.parent.qdel_ritual_item(A)

	if (src.blood_cost)
		var/datum/vampire_coven/coven = global.get_singleton(/datum/vampire_coven)
		coven.blood -= src.blood_cost

		for (var/datum/mind/member as anything in coven.members)
			member.current?.abilityHolder?.updateText()

	src.major_sacrifice = null
	src.minor_sacrifices = list()

/datum/vampire_ritual/proc/increment_progress(mob/caster)
	set waitfor = FALSE

	src.ritual_stage += 1

	var/turf/T = get_turf(src.parent)
	var/sound = pick(
		'sound/voice/wraith/wraithraise1.ogg',
		'sound/voice/wraith/wraithraise2.ogg',
		'sound/voice/wraith/wraithwhisper4.ogg',
	)
	playsound(T, sound, 50)

	switch (src.ritual_stage)
		if (1)
			src.parent.start_ritual_fire()

		if (2)
			if (src.major_sacrifice)
				src.major_sacrifice.add_filter("ritual_outline", 2, outline_filter(1, "#d73715", OUTLINE_SHARP))
				animate(src.major_sacrifice, time = 2 SECOND, pixel_y = 10, flags = ANIMATION_PARALLEL)
				global.animate_levitate(src.major_sacrifice)

			for (var/atom/movable/A as anything in src.minor_sacrifices)
				A.add_filter("ritual_outline", 1, outline_filter(1, "#d73715", OUTLINE_SHARP))
				animate(A, time = 2 SECOND, pixel_y = 5, flags = ANIMATION_PARALLEL)
				global.animate_levitate(A)

		if (3)
			var/datum/vampire_coven/coven = global.get_singleton(/datum/vampire_coven)
			if ((coven.blood < src.blood_cost) || !src.invoke(caster))
				global.VampireRitualManager.StopRitual(src)
				return

			SPAWN(0.5 SECONDS)
				playsound(T, 'sound/musical_instruments/Bell_Huge_1.ogg', 50, pitch = 0.75)
				src.announce_completion(caster)

			src.ritual_completed = TRUE
			src.accept_sacrifices()

			if (src.ritual_duration)
				SPAWN(src.ritual_duration)
					global.VampireRitualManager.CompleteRitual(src)

			else
				global.VampireRitualManager.CompleteRitual(src)

/datum/vampire_ritual/proc/invoke(mob/caster)
	return TRUE

/datum/vampire_ritual/proc/announce_completion(mob/caster)
	global.vampchat_announcer.say("<b>[caster.real_name]</b> has invoked \a <b>[src.name]</b>[src.additional_completion_text]!", flags = SAYFLAG_IGNORE_HTML)

/datum/vampire_ritual/proc/ritual_clean_up()
	if (src.ritual_stage >= 1)
		src.parent.end_ritual_fire()

		if (src.ritual_stage >= 2)
			if (src.major_sacrifice)
				src.major_sacrifice.remove_filter("ritual_outline")
				animate(src.major_sacrifice, time = 2 SECOND, pixel_y = 0, transform = matrix())

			for (var/atom/movable/A as anything in src.minor_sacrifices)
				A.remove_filter("ritual_outline")
				animate(A, time = 2 SECOND, pixel_y = 0, transform = matrix())

	src.ritual_stage = 1
	src.unset_major_sacrifice()
	src.minor_sacrifices = list()





/obj/item/paper/book/from_file/vampire_rituals
	name = "accursed tome"
	desc = "A grand red and black book with gold lettering."
	file_path = "strings/books/vampire_rituals.txt"
	icon_state = "reddarkhb"
	item_state = "reddarkhb"
