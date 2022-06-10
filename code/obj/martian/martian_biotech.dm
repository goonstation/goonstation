///////////////////////////
// MARTIAN BIOTECH PARENT
///////////////////////////

// eventually i aim to make more martian tech, so let's prepare for that day - cirr
// this may just be a machinery copy/paste with some variations, god help me
/obj/martianBiotech
  name = "squishy doodad"
  desc = "What the fuck even is this?"
  icon = 'icons/obj/martian.dmi'
  icon_state = "cloner"
  anchored = 1
  density = 1
  var/health = 100
  var/maxHealth
  var/regen = 2
  var/bruteVuln = 0.5 // martian flesh is resilient
  var/fireVuln = 1.0 // martian flesh does not like fire
  var/growthTime = 30 // how many seconds it takes for this biotech to grow from a seed
  var/martianName = "organic machine"
  var/martianDesc = "It doesn't appear to serve any specific function."

/obj/martianBiotech/New()
  ..()
  maxHealth = health
  SubscribeToProcess()

/obj/martianBiotech/disposing()
  UnsubscribeProcess()
  ..()

/obj/martianBiotech/proc/SubscribeToProcess()
  processing_items |= src

/obj/martianBiotech/proc/UnsubscribeProcess()
  processing_items -= src

/obj/martianBiotech/proc/process()
  // slowly regenerate health
  if(health < maxHealth)
    health = min(maxHealth, health + regen)
    // TODO: unique particles
    var/bubbleColor = pick("#b4e1af", "#b297ca", "#4f192b")
    particleMaster.SpawnSystem(new /datum/particleSystem/blobheal(get_turf(src), bubbleColor))
    if(prob(33))
      playsound(src.loc, 'sound/effects/bubbles3.ogg', 60, 1)

/obj/martianBiotech/proc/checkhealth()
  if(src.health <= 0)
    src.UnsubscribeProcess()
    src.gib()

/obj/martianBiotech/proc/gib(atom/location)
  if(!location)
    location = src.loc
  visible_message("<span class='alert'>The [src.name] bursts into gooey sludge!</span>")
  playsound(location, 'sound/impact_sounds/Flesh_Break_2.ogg', 80, 1)
  martiangibs(location)
  qdel(src)

/obj/martianBiotech/proc/takeDamage(var/damageType, var/amount)
  switch(damageType)
    if("brute")
      amount *= bruteVuln
    if("burn")
      amount *= fireVuln
    if("fire")
      amount *= fireVuln
    if("mixed")
      var/half = round(amount/2)
      amount = half * bruteVuln + (amount - half) * fireVuln
  health -= amount
  checkhealth() // die if necessary

/obj/martianBiotech/proc/martianInteract(var/mob/user)
  boutput(user, "<span class='alert'>It doesn't have an obvious function.</span>")

/obj/martianBiotech/attack_hand(var/mob/user)
  if(ismartian(user))
    src.martianInteract(user)
    return
  var/futility = pick("futiley", "uselessly", "aimlessly", "worthlessly", "pointlessly")
  var/action = "errors"
  var/response = "errored"
  switch(user.a_intent)
    if(INTENT_HELP)
      action = pick("pats", "pets", "rubs", "caresses")
      response = pick("calmed", "passive", "neutral", "relaxed", "slimy", "confused")
    if(INTENT_DISARM)
      action = pick("shoves", "pushes", "nudges", "gestures at")
      response = pick("bemused", "annoyed", "confused", "irritated", "ticked off")
    if(INTENT_GRAB)
      action = pick("grabs", "grips", "grasps", "squeezes", "squishes")
      response = pick("offended", "distressed", "concerned", "flinchy", "shaky")
    if(INTENT_HARM)
      action = pick("smacks", "punches", "kicks", "attacks", "jabs")
      response = pick("angry", "hostile", "throbbing", "jerky", "wriggly", "vengeful")
  src.visible_message("<span class='alert'><b>[user]</b> [futility] [action] [src]! It seems vaguely [response].</span>")
  playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_3.ogg', 80, 1)

/obj/martianBiotech/attackby(obj/item/W, mob/user)
  src.visible_message("<span class='alert'><b>[user]</b> attacks [src] with [W]!</span>")
  playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_2.ogg', 80, 1)

  var/damtype = "brute"
  if (W.hit_type == DAMAGE_BURN)
    damtype = "fire"

  takeDamage(damtype, W.force)

// shamelessly stolen from blob
/obj/martianBiotech/ex_act(severity)
  var/damage = 0
  var/damage_mult = 1
  switch(severity)
    if(1)
      damage = rand(30,50)
      damage_mult = 8
    if(2)
      damage = rand(25,40)
      damage_mult = 4
    if(3)
      damage = rand(10,20)
      damage_mult = 2
  src.takeDamage("mixed", damage * damage_mult)

// also stolen from blob
/obj/martianBiotech/bullet_act(var/obj/projectile/P)
  var/damage = round((P.power*P.proj_data.ks_ratio), 1.0) // stuns will do nothing (at present)
  var/damage_mult = 1
  var/damtype = "brute"
  if (damage < 1)
    return

  switch(P.proj_data.damage_type)
    if(D_KINETIC)
      damage_mult = 0.5
      damtype = "brute"
    if(D_PIERCING)
      damage_mult = 0.5
      damtype = "brute"
    if(D_ENERGY)
      damage_mult = 1
      damtype = "burn"
    if(D_BURNING)
      damage_mult = 1.2
      damtype = "burn"
    if(D_SLASHING)
      damage_mult = 1.5
      damtype = "brute"

  src.takeDamage(damtype, damage * damage_mult)
  return


/obj/martianBiotech/blob_act(var/power)
  var/modifier = power / 20
  var/damage = rand(modifier, 12 + 8 * modifier)

  takeDamage("mixed", damage)
  src.visible_message("<span class='alert'>[src] is hit by the blob!/span>")


/obj/martianBiotech/proc/describeCondition()
  var/healthPercent = (health/maxHealth) * 100
  switch(healthPercent)
    if(-INFINITY to 10)
      return "<span class='alert bold'>It's about to burst!</span>"
    if(11 to 25)
      return "<span class='alert bold'>It's splitting and looks smashed to a pulp!</span>"
    if(26 to 50)
      return "<span class='alert'>It's sputtering ichor and convulsing.</span>"
    if(51 to 75)
      return "<span class='alert'>It looks roughed up and gently swaying.</span>"
    if(76 to 95)
      return "<span class='notice'>It looks a little bruised.</span>"
    if(96 to INFINITY)
      return "<span class='notice'>It's in perfect health.</span>"

/obj/martianBiotech/special_desc(dist, mob/user)
  if(ismartian(user))
    var/special_desc = "This is \an [src.martianName]."
    special_desc += "<br>[src.martianDesc]"
    special_desc += "<br>" + describeCondition()
    return special_desc
  else
    return null // give the standard description

// might as well let the human peoples know the status of the thing
/obj/martianBiotech/get_desc(dist, mob/user)
  if(dist < 4)
    return "<br>" + describeCondition()
