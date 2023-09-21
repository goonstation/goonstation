/datum/limb/singularity
  var/grav_range = 6

/datum/limb/singularity/attack_range(atom/target, var/mob/user, params)
  var/atom/movable/T = target
  var/mob/living/critter/singularity/S = user
  if(!istype(T) || !istype(S))
    return
  if(!S.affects_mobs && ismob(T))
    S.show_message("<span class='alert'>You can't seem to exert enough attractive force to budge it.</span>")
    return
  if(GET_DIST(T, user) <= grav_range)
    if(!T.anchored)
      if(!T.throwing)
        S.visible_message("<span style='color:red; font-weight:bold'>[S] [pick("sucks", "draws", "pulls", "yanks", "tugs", "flings")] [T] towards itself!</span>")
        T.throw_at(S, grav_range, 2)
    else
      S.show_message("<span class='alert'>You can't seem to exert enough attractive force to budge it.</span>")
  else
    S.show_message("<span class='alert'>It's too far away, your gravitational drop-off is too severe.[prob(10) ? " Curse you, general relativity!" : ""]</span>")

/mob/living/critter/singularity
  name = "singularity"
  real_name = "singularity"
  desc = "A tiny, sentient singularity. If there was ever more proof needed of malevolent gods or other cosmic forces, this is it."
  density = 1
  icon_state = "sing"
  icon_state_dead = "sing-dead"
  custom_gib_handler = /proc/gibs
  hand_count = 1
  can_throw = 1
  can_grab = 1
  can_disarm = 1
  speechverb_say = "sucks"
  speechverb_exclaim = "roars"
  speechverb_ask = "pulls"
  blood_id = "ldmatter"
  metabolizes = 0
  add_abilities = list(/datum/targetable/critter/zzzap, /datum/targetable/critter/bholerip, /datum/targetable/critter/toxmob, /datum/targetable/critter/mezzer)
  var/datum/light/glow
  var/grav_pull = 3
  var/stabilized = 0 // bullshit magic var to make it possible to shut off the constant pull
  var/affects_mobs = 0 // weaker singularities ought to not gib mobs i think

/mob/living/critter/singularity/mobkiller
  affects_mobs = 1

/mob/living/critter/singularity/New()
  ..()
  src.glow = new /datum/light/point
  src.glow.set_brightness(0.8)
  src.glow.set_color(0.38, 0.0, 0.53)
  src.glow.attach(src)
  src.glow.enable()

/mob/living/critter/singularity/full_heal()
  ..()
  anchored = initial(anchored)

/mob/living/critter/singularity/death(gibbed)
  ..(gibbed)
  if(src)
    src.glow.disable()
    src.anchored = ANCHORED
    src.set_density(0)
    src.name = "weird purple rock thing"
    src.desc = "A weird ultra-dense rock that doesn't want to budge. Huh. Is it plasma?"

/mob/living/critter/singularity/setup_hands()
  ..()
  var/datum/handHolder/HH = hands[1]
  HH.limb = new /datum/limb/singularity
  HH.icon = 'icons/mob/critter_ui.dmi'
  HH.icon_state = "handzap"
  HH.name = "gravitational pull"
  HH.limb_name = "gravitational pull"
  HH.can_range_attack = 1

/mob/living/critter/singularity/attackby(var/obj/item/I, var/mob/user)
  if (istype(I, /obj/item/clothing/mask/cigarette))
    var/obj/item/clothing/mask/cigarette/C = I
    if (!C.on)
      C.light(user, "<span class='alert'><b>[user]</b> lights [C] on [src]. Mildly impressive!</span>")
    else
      return ..()
  else
    return ..()

/mob/living/critter/singularity/Life(datum/controller/process/mobs/parent)
  if (..(parent))
    return 1
  // SUCK IT ALL IN, EAT EAT EAT
  if(!src.stabilized)
    suck()
  for(var/atom/movable/M in get_turf(src))
    eat()

/mob/living/critter/singularity/proc/suck()
  // it's a weak babby singularity, so it won't eat turfs or pull in anchored objects
  for (var/atom/movable/M in orange(grav_pull,src))
    LAGCHECK(LAG_LOW)
    if (!M)
      continue
    if(ismob(M) && !src.affects_mobs)
      continue // weak singularities shouldn't suck in mobs
    if(istype(M, /mob/living/critter/singularity))
      continue // singularities shouldn't suck in other singularities
    if(!M.anchored)
      step_towards(M, src)

/mob/living/critter/singularity/proc/eat(atom/movable/A)
	// TODO: heal based on consumption?
	if(src.affects_mobs && isliving(A))
		var/mob/living/M = A
		if(M && !istype(M, /mob/living/critter/singularity))
			logTheThing(LOG_COMBAT, M, "was gibbed by [src] ([src.type]) at [log_loc(M)].")
			M.gib()
	else if(isobj(A) && A.anchored != 2)
		A.ex_act(1)
		if(A)
			qdel(A)


/mob/living/critter/singularity/Crossed(atom/movable/A)
  ..(A)
  eat(A)

/mob/living/critter/singularity/Bumped(atom/A)
  ..(A)
  if(istype(A, /atom/movable))
    eat(A)


// TODO: better emotes
/mob/living/critter/singularity/specific_emotes(var/act, var/param = null, var/voluntary = 0)
  switch (act)
    if ("scream", "twirl", "snap")
      if (src.emote_check(voluntary, 50))
        return "<b>[src]</b> [act]s!"
  return null

/mob/living/critter/singularity/specific_emote_type(var/act)
  switch (act)
    if ("scream", "twirl", "snap")
      return 2
  return ..()

/mob/living/critter/singularity/setup_healths()
  add_hh_robot(150, 1.15)
