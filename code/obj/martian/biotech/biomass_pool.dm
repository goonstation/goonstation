///////////////////////////
// MARTIAN BIOMASS POOL
///////////////////////////
// converts organic matter into martian usable biomatter/biomass (name suggestions welcome)

/obj/martianBiotech/biomassPool
  name = "bubbling pool"
  desc = "It smells sharp and acrid, and looks like some kind of acid pit. Better not touch it."
  // TODO: icon_state
  martianName = "biomass pool"
  martianDesc = "Converts organic matter into biomatter, used for developing further technology. Inserted mass will take time to convert to biomatter."
  var/meatAmount = 0
  var/biomatterAmount = 0
  var/conversionRate = 5
  var/list/victims = list()
  var/static/list/meatValues = null // list instantiated on first attempt to access (hooray lazy init)
  var/static/list/biomassPoolReagents = list("synthflesh"=0.05, "blood"=0.02, "martian_flesh"=0.1, "beff" = 0.01, "pepperoni" = 0.01, "meat_slurry" = 0.05, "bloodc" = 0.03) // alien blood processed better? ALIEN CONSPIRACY

/obj/martianBiotech/biomassPool/New()
  ..()
  src.create_reagents(100)

/obj/martianBiotech/biomassPool/attack_hand(var/mob/user)
  if(ismartian(user))
    src.martianInteract(user)
    return
  // you idiot!!
  user.TakeDamage("All", 2, 2)
  user.visible_message("<span class='alert'><b>[user]</b> burns themselves on the acid of the pool! What a moron!</span>", "<span class='alert'>You burn yourself on the acidic contents! Ouch!</span>")
  if(prob(50))
    user.emote("scream")

/obj/martianBiotech/biomassPool/process()
  var/turf/T = get_turf(src)
  // process things trapped
  if(victims.len > 0)
    var/list/toRemove = list()
    for(var/mob/living/M in victims)
      if(!isdead(M))
        // DEVOUR, etc.
        M.TakeDamage("All", 5, 5)
        if(prob(40)) // you poor bastard
          M.emote("scream")
          boutput(M, "<span style='color:red; font-weight: bold;'>[pick("OH GOD IT BURNS! THE PAIN!!", "FUCK! FUCK! AGH!!", "MAKE IT STOP!", "AUGH!!")]</span>")
      else
        // welp, they're just meat now
        toRemove += M
        meatAmount += calcMeatValue(M)
        if(M.client)
          M.ghostize()
        qdel(M)
        playsound(T, 'sound/impact_sounds/Slimy_Hit_4.ogg', 50, 1)
    victims -= toRemove
  // process meat to biomatter
  if(meatAmount > 0)
    var/amount = conversionRate
    if(conversionRate > meatAmount)
      amount = meatAmount
    meatAmount -= amount
    biomatterAmount += amount

/obj/martianBiotech/biomassPool/gib(atom/location)
  ..(location)
  // eject those victims fortunate enough to be alive and rescued
  if(victims.len > 0)
    for(var/mob/living/M in victims)
      M.set_loc(location)

/obj/martianBiotech/biomassPool/attackby(obj/item/W, mob/user)
  var/obj/item/grab/G = W
  var/meatValue = 0
  var/atom/movable/meat = null
  if(istype(G))
    meat = G.affecting
    meatValue = src.calcMeatValue(G.affecting)
  else
    meat = W
    meatValue = src.calcMeatValue(W)

  if(meatValue <= 0)
    boutput(user, "<span class='alert'><b>[src]</b> can't process [meat].</span>")
    return

  if(ismob(meat))
    // there should be a bit more time given for other people to rescue whoever
    actions.start(new /datum/action/bar/icon/put_in_biomass_pool(G.affecting, meatValue, src, G, 40), user)
  else
    user.visible_message("<span class='alert'><b>[user]</b> dips [meat] in [src]!</span>", "<span class='alert'>You dip [meat] in [src]!</span>")
    if(G)
      qdel(G)
    qdel(meat)
    meatAmount += meatValue
    var/turf/T = get_turf(src)
    playsound(T, 'sound/effects/plop_dissolve.ogg', 50, 1)


/obj/martianBiotech/biomassPool/proc/calcMeatValue(var/atom/movable/M)
  if(!M) return
  // check to see if the provided meat atom or "meatom" matches any of the paths in the meat values list
  // a hash map would be more efficient but this list is not gonna be THAT long so whatevs
  if(!istype(src.meatValues))
    src.meatValues = src.getMeatValues()

  . = 0 // by default the meat value is 0, ie. inedible

  for(var/datum/martianMeatValue/V in src.meatValues)
    // check to see if M matches any of the paths of these meats
    if(istype(M, V.meatPath))
      . = V.getValue(M)
      break

/obj/martianBiotech/biomassPool/proc/addVictim(var/mob/M)
  if(!M) return
  if(!(M in victims))
    victims += M

/obj/martianBiotech/biomassPool/on_reagent_change()
  ..()
  for(var/reagentId in src.reagents.reagent_list)
    if(reagentId in src.biomassPoolReagents)
      var/datum/reagent/R = src.reagents.reagent_list[reagentId]
      if(R)
        // schlurp
        src.meatAmount += R.volume * biomassPoolReagents[reagentId]
        src.meatAmount = round(src.meatAmount) // if this ends up meaning your tiny amount of meat chemicals was useless, that ain't my problem
        src.reagents.del_reagent(reagentId)
    else
      // the biomass pool doesn't want this garbage
      // quietly delete it
      src.reagents.del_reagent(reagentId)

/obj/martianBiotech/biomassPool/martianInteract(var/mob/user)
  boutput(user, "<span class='notice'>Pool contents: [src.meatAmount] meat, [src.biomatterAmount] biomatter.</span>")

/////////////////////////////////////////////////////////////////////////////////
// PUT-INTO-POOL ACTION
/////////////////////////////////////////////////////////////////////////////////

/datum/action/bar/icon/put_in_biomass_pool
  id = "put_in_biomass_pool"
  interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
  duration = 40
  icon = 'icons/mob/screen1.dmi'
  icon_state = "grabbed"

  var/mob/living/target
  var/obj/martianBiotech/biomassPool/pool
  var/obj/item/grab/grab
  var/meatValue

  New(var/mob/living/ntarg, var/nmeatValue, var/obj/martianBiotech/biomassPool/npool, var/obj/item/grab/ngrab, var/duration_i)
    ..()
    if (ntarg)
      target = ntarg
    if(nmeatValue)
      meatValue = nmeatValue
    if (npool)
      pool = npool
    if (ngrab)
      grab = ngrab
    if (duration_i)
      duration = duration_i

  onUpdate()
    ..()
    if (grab == null || target == null || pool == null || owner == null || BOUNDS_DIST(owner, pool) > 0 || BOUNDS_DIST(owner, target) > 0 || BOUNDS_DIST(target, pool) > 0)
      interrupt(INTERRUPT_ALWAYS)
      return

  onStart()
    ..()
    owner.visible_message("<span class='alert'><b>[owner]</b> starts dipping [target] in [pool]!</span>", "<span class='alert'>You starting dipping [target] in [pool]!</span>")

  onEnd()
    ..()
    owner.visible_message("<span class='alert'><b>[owner] dips [target] into [pool]!</b></span>", "<span class='alert'>You dip [target] in [pool]!</span>")
    logTheThing(LOG_COMBAT, owner, "forced [constructTarget(target,"combat")] ([isdead(target) ? "dead" : "alive"]) into \an [pool] at [log_loc(pool)].")
    if (!isdead(target))
      message_admins("[key_name(owner)] forced [key_name(target, 1)] ([target == 2 ? "dead" : "alive"]) into \an [pool] at [log_loc(pool)].")
    target.set_loc(pool)
    pool.addVictim(target)
    qdel(grab)
    var/turf/T = get_turf(pool)
    playsound(T, 'sound/effects/plop_dissolve.ogg', 50, 1)



/////////////////////////////////////////////////////////////////////////////////
// MEAT VALUES
// this object gets to own this proc because nothing else is gonna use it
/obj/martianBiotech/biomassPool/proc/getMeatValues()
  if(!istype(src.meatValues))
    var/list/types = childrentypesof(/datum/martianMeatValue)
    src.meatValues = list()
    for(var/T in types)
      src.meatValues |= new T()
  . = src.meatValues

/datum/martianMeatValue
  var/atom/movable/meatPath = null // if the thing being checked matches the meat path, use this datum's value proc to determine the value (this is some weird variation on the Command pattern, I think)
  // default to null, which would be an issue but this root value is excluded
  var/meatValue = 0 // and just to be sure, the value is 0 anyway

/datum/martianMeatValue/proc/getValue(var/atom/movable/M) // some of the logic will be more complex than others
// the parameter passed by this value should be the instance of the meat path specified for the datum
  . = src.meatValue

/////////////////////////////////////////////////////
// HUMAN BODIES
/////////////////////////////////////////////////////

/datum/martianMeatValue/human
  meatPath = /mob/living/carbon/human
  meatValue = 100
  var/decompAmount = 20
  var/monkeyMultiplier = 0.5
  var/missingLimbPercent = 5
  var/missingOrganPercent = 5
  var/maxLimbs = 4
  var/maxOrgans = 6

/datum/martianMeatValue/human/getValue(var/mob/living/carbon/human/M)
  if(!M)
    return 0
  // oh boy
  // first, start with meat value
  . = meatValue
  // for each stage of decomposition, reduce
  // max stage is 4
  . -= M.decomp_stage * src.decompAmount
  // if the human is a monkey, adjust value
  if(ismonkey(M))
    . *= monkeyMultiplier
  // for each missing body part, remove a percentage of the final value
  // at present, the numbers have been fudged so that loss of all limbs and organs will provide 50%, which for a non-decomposed human means 50 biomass, and the sum total of the parts individually will be 50 biomass
  // this does mean there's room for an exploit with martians individually removing all parts from a rotting corpse but eh, that's more effort for them, they don't get surgical tools
  var/percent = 100
  // first, remove 5% for each missing limb
  // please god let there be an easier way to do this in future
  if(M.limbs)
    var/intactLimbs = 0
    if(istype(M.limbs.l_leg))
      intactLimbs++
    if(istype(M.limbs.r_leg))
      intactLimbs++
    if(istype(M.limbs.l_arm))
      intactLimbs++
    if(istype(M.limbs.r_arm))
      intactLimbs++
    percent -= (src.maxLimbs - intactLimbs) * src.missingLimbPercent
  else
    // assume they're all gone
    percent -= src.maxLimbs * src.missingLimbPercent

  var/datum/organHolder/O = M.organHolder
  if(O)
    var/lostOrgans = 0
    if(!istype(O.head))
      lostOrgans += 4 // skull, brain, and eyes!
    else
      // check for skull, brain and eyes individually
      if(!istype(O.skull))
        lostOrgans++
      if(!istype(O.brain))
        lostOrgans++
      if(!istype(O.left_eye))
        lostOrgans++
      if(!istype(O.right_eye))
        lostOrgans++
    if(!istype(O.chest) || !istype(O.heart))
      lostOrgans++ // currently we only care about the heart
    if(!istype(O.butt))
      lostOrgans++
    // not currently caring about lungs
    percent -= lostOrgans * src.missingOrganPercent
  else
    // assume they're all missing
    percent -= src.maxOrgans * src.missingOrganPercent

  // as a failsafe, percentage is capped to 10% minimum
  percent = max(10, percent)
  // multiply final value
  . *= (percent/100)

/////////////////////////////////////////////////////
// CRITTER BODIES
/////////////////////////////////////////////////////

/datum/martianMeatValue/mobcritter
  meatPath = /mob/living/critter

/datum/martianMeatValue/mobcritter/getValue(var/mob/living/critter/C)
  if(!C)
    return 0
  . = max(10, round(C.max_health/2, 10))

/datum/martianMeatValue/objcritter
  meatPath = /obj/critter

/datum/martianMeatValue/mobcritter/getValue(var/obj/critter/C)
  if(!C)
    return 0
  . = max(10, round(initial(C.health)/2, 10))

/////////////////////////////////////////////////////
// ORGANS AND LIMBS
/////////////////////////////////////////////////////

/datum/martianMeatValue/limb
  meatPath = /obj/item/parts/human_parts
  meatValue = 5

/datum/martianMeatValue/organ
  meatPath = /obj/item/organ
  meatValue = 5

/datum/martianMeatValue/butt
  meatPath = /obj/item/clothing/head/butt
  meatValue = 5

/////////////////////////////////////////////////////
// MEAT FOODS
/////////////////////////////////////////////////////

/datum/martianMeatValue/meatfood
  meatPath = /obj/item/reagent_containers/food
  meatValue = 5

/datum/martianMeatValue/meatfood/getValue(var/obj/item/reagent_containers/food/F)
  if(!F)
    return 0
  // is the food meat?
  if(istype(F, /obj/item/reagent_containers/food/snacks/ingredient/meat) || findtext(F.name, "meat") || findtext(F.name, "bacon"))
    . = src.meatValue
  else
    . = 0 // it's not meat

/////////////////////////////////////////////////////
// VISCERITE
/////////////////////////////////////////////////////

/datum/martianMeatValue/rawviscerite
  meatPath = /obj/item/raw_material/martian
  meatValue = 3

/datum/martianMeatValue/rawviscerite/getValue(var/obj/item/raw_material/martian/V)
  if(!V)
    return 0
  . = V.amount * src.meatValue

/datum/martianMeatValue/refinedviscerite
  meatPath = /obj/item/material_piece/wad
  meatValue = 3

/datum/martianMeatValue/refinedviscerite/getValue(var/obj/item/material_piece/wad/W)
  if(!W)
    return 0
  // is this wad made of viscerite?
  if(W.material && istype(W.material, /datum/material/organic/viscerite))
    . = W.amount * src.meatValue
  else
    . = 0 // it's not viscerite
