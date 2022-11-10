///////////////////////////
// SERVITOR WORM
///////////////////////////

// TODO: come back to this

/*
/obj/critter/velvet_worm
  name = "velvet worm"
  desc = "Despite being superficially similar to a giant velvet worm, this creature is in fact some kinda alien sometimes seen around martians."
  icon_state = "mouse" // temporary
  density = 0
  health = 10
  aggressive = 1
  defensive = 1
  wanderer = 1
  scavenger = 1
  opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
  atkcarbon = 0
  atksilicon = 0
  atkcritter = 1
  seek_range = 15
  attack_range =
  firevuln = 1.2
  brutevuln = 1
  angertext = "burbles at"
  eat_text = "macerates and swallows some of"
  butcherable = 1
  flags = FPRINT | CONDUCT | USEDELAY | TABLEPASS
  atk_delay = 15

/obj/critter/velvet_worm/process() // override because these dudes need to be more active
  if (!src.alive) return 0

  if(sleeping > 0)
    sleeping--
    return 0

  check_health()

  if(prob(7))
    var/fidgettext = pick("taps its antennae around", "waves its stubby legs about", "wipes its spewer legs", "unfurls and curls its inner jaws")
    src.visible_message("[src] [fidgettext].")

  if(task == "following path")
    follow_path()
  else if(task == "sleeping")
    var/waking = 0
    for(var/mob/M in range(10, src))
      if(M.client)
        waking = 1
        break

    if(waking)
      task = "thinking"
    else
      sleeping = 5
      return 0
  else if(sleep_check <= 0)
    sleep_check = 5

    var/stay_awake = 0
    for(var/mob/M in range(10, src))
      if(M.client)
        stay_awake = 1
        break
    if(!stay_awake)
      sleeping = 5
      task = "sleeping"
      return 0

  else
    sleep_check--

  return ai_think()

/obj/critter/velvet_worm/ai_think() // and again
  switch(task)
    if("thinking")
      src.attack = 0
      src.target = null

      walk_to(src,0)
      if (src.aggressive) seek_target()
      if (src.wanderer && !src.target) src.task = "wandering"
    if("chasing")
      if (src.frustration >= rand(20,40))
        src.target = null
        src.last_found = world.time
        src.frustration = 0
        src.task = "thinking"
        walk_to(src,0)
      if (target)
        if (GET_DIST(src, src.target) <= 7)
          var/mob/living/carbon/M = src.target
          if (M)
            if(!src.attacking) ChaseAttack(M)
            src.task = "attacking"
            src.anchored = 1
            src.target_lastloc = M.loc
        else
          var/turf/olddist = GET_DIST(src, src.target)

          else walk_to(src, src.target,1,4)

          if ((GET_DIST(src, src.target)) >= (olddist))
            src.frustration++

          else
            src.frustration = 0
      else src.task = "thinking"
    if("attacking")
      if ((BOUNDS_DIST(src, src.target) > 0) || ((src.target:loc != src.target_lastloc)))
        src.anchored = 0
        src.task = "chasing"
      else
        if (BOUNDS_DIST(src, src.target) == 0)
          var/mob/living/carbon/M = src.target
          if (!src.attacking) CritterAttack(src.target)
          if (!src.aggressive)
            src.task = "thinking"
            src.target = null
            src.anchored = 0
            src.last_found = world.time
            src.frustration = 0
            src.attacking = 0
          else
            if(M!=null)
              if (M.health < 0)
                src.task = "thinking"
                src.target = null
                src.anchored = 0
                src.last_found = world.time
                src.frustration = 0
                src.attacking = 0
        else
          src.anchored = 0
          src.attacking = 0
          src.task = "chasing"
    if("wandering")
      patrol_step()
  return 1

CritterAttack(atom/M)
  if(target)
    src.attacking = 1
    //playsound(src.loc, 'sound/machines/whistlebeep.ogg', 55, 1)
    src.visible_message("<span class='alert'><b>[src]</b> fires at [M]!</span>")

    var/tturf = get_turf(M)
    Shoot(tturf, src.loc, src)

    if(prob(20)) // break target fixation
      src.target = null
      src.last_found = world.time
      src.frustration = 0
      src.task = "thinking"
      walk_to(src,0)

    SPAWN(attack_cooldown)
      src.attacking = 0
  return


/obj/critter/velvet_worm/ChaseAttack(atom/M)
  if(target)
    src.attacking = 1
    //playsound(src.loc, 'sound/machines/whistlebeep.ogg', 55, 1)
    src.visible_message("<span class='alert'><b>[src]</b> fires at [M]!</span>")

    var/tturf = get_turf(M)
    Shoot(tturf, src.loc, src)

    if(prob(20))
      src.target = null
      src.last_found = world.time
      src.frustration = 0
      src.task = "thinking"
      walk_to(src,0)

    SPAWN(attack_cooldown)
      src.attacking = 0
  return


/obj/critter/velvet_worm/Shoot(var/target, var/start, var/user, var/bullet = 0)
  if(target == start)
    return

  var/obj/projectile/A = new /obj/projectile
  if(!A)  return
  A.set_loc(src.loc)
  if (!current_projectile)
    current_projectile = new projectile_type()
  A.proj_data = new current_projectile.type
  A.proj_data.master = A
  A.set_icon()
  A.power = A.proj_data.power
  if(src.current_projectile.shot_sound)
    playsound(src, src.current_projectile.shot_sound, 60)

  if (!istype(target, /turf))
    A.die()
    return
  A.target = target

  if(istype(target, /obj/machinery/cruiser))
    A.yo = (target:y + 2) - start:y
    A.xo = (target:x + 2) - start:x
  else
    A.yo = target:y - start:y
    A.xo = target:x - start:x

  A.shooter = src
  src.set_dir(get_dir(src, target))
  SPAWN( 0 )
    A.process()
  return
*/
