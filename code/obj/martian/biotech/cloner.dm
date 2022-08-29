///////////////////////////
// MARTIAN CLONER
///////////////////////////

// a brief note from cirr:
// originally i wanted to make it so that this would also clone martian obj critters
// however it is giving me the worst headache and it seems like all it will do is cause outrage from players for adding difficulty to an already difficult area
// ergo, i'm stating that i did have this intention, but then i went "fuck it" and went back to mobs
// thanx for reading

/obj/martianBiotech/cloner
  name = "chunky tube"
  desc = "You have no idea what this is or what it's for. Seems like bad news."
  icon_state = "cloner"
  martianName = "biomass reassembler"
  // martianDesc = "Reprocesses biomass into new martian forces. Able to generate its own servitor to retrieve nearby organic matter for conversion."
  martianDesc = "Reprocesses biomass into new martian forces. It processes bodies left next to it automatically, and will not open while working or resting."

  // TODO: something better than this bunch of state tracking vars, aaaaa

  var/in_use = 0 // is the cloner full of SOMETHING
  var/growing_variant = /mob/living/critter/martian // what are we going to grow
  var/eject_at_health_percent = 100 // how healthy our occupant should be before we eject them
  var/consume_at_health_percent = 0 // how damaged our occupant should be before we kill them
  var/cooldown = 0 // don't just immediately eat the dude we spat out
  var/do_rejection = 0 // should we spit out the current dude?
  var/growing = 0 // are we eating our occupant or regrowing them?
  var/mob/living/occupant = null
  var/can_process_other_species = 0
  var/reject_chance = 15 // will we reject this non-martian brain? now a var for customisation and badminning purposes

  // however, related to the badminning purposes there's only a few martians people should be able to become without fucking things up
  var/static/list/whitelisted_martian_types = list(/mob/living/critter/martian, /mob/living/critter/martian/soldier, /mob/living/critter/martian/warrior, /mob/living/critter/martian/mutant/weak)

/obj/martianBiotech/cloner/proc/reset()
  src.cooldown = 10
  src.in_use = 0
  src.occupant = null
  src.growing = 0
  src.icon_state = "cloner"
  src.do_rejection = 0
  src.color = "#804040"

/obj/martianBiotech/cloner/process()
  ..()
  if(src.cooldown > 0)
    src.cooldown--
    return
  src.color = null
  if(src.in_use)
    if(!src.occupant || src.occupant.loc != src)
      // rip our occupant
      reset()
      return

    var/mob/living/M = src.occupant

    M.changeStatus("paralysis", 6 SECONDS)
    if(prob(33))
      playsound(src.loc, 'sound/effects/bubbles3.ogg', 60, 1)

    if(src.growing)
      // work on cloning the current occupant
      if(src.do_rejection)
        // *price is right losing horn*
        playsound(src, 'sound/impact_sounds/Flesh_Tear_2.ogg', 100, 1)
        M.emote("scream")
        src.visible_message("<span style='color: red;text-weight: bold;'>[src] spits out a pink fleshy lump!</span>")
        // eject martian brain
        var/obj/item/organ/brain/martian/brain = new /obj/item/organ/brain/martian(src.loc)
        brain.setOwner(src.occupant.mind)
        var/edge = get_edge_target_turf(src, pick(alldirs))
        brain.throw_at(edge, 25, 4)
        // destroy mob
        if(M.client)
          M.ghostize()
        qdel(M)
        reset()
      else
        // okay i guess we'll just continue cloning the dude
        // first, do a bunch of checks to see if the occupant is suiciding or dead somehow
        if(M.suiciding || (M.mind && M.mind.dnr))
          src.do_rejection = 1
        else
          // patch up damage
          M.HealDamage("All", 2, 2) // biotech working better than cloner because fuck who knows
          // do you need to get out yet?
          var/health_percent = (M.health / M.max_health) * 100
          if(health_percent >= src.eject_at_health_percent)
            // alright, get out
            playsound(src, 'sound/impact_sounds/Slimy_Splat_2.ogg', 100, 1)
            src.visible_message("<span style='color: red; font-weight: bold;'>[src.occupant] is unceremoniously ejected from [src].</span>")
            setalive(M)
            M.set_loc(src.loc)
            reset()
    else
      // work on eating the current occupant
      M.TakeDamage("All", 2, 2)
      if(!isdead(M) && prob(40)) // you poor bastard
        M.emote("scream")
        boutput(M, "<span style='color:red; font-weight: bold;'>[pick("OH GOD IT BURNS! THE PAIN!!", "FUCK! FUCK! AGH!!", "IT'S LIKE YOUR FLESH IS BEING REMODELLED BY A DRUNK TEAM OF ANGRY MONKEYS!", "AUGH!!")]</span>")
      // can we fully digest?
      var/health_percent = (M.health / M.max_health) * 100
      if(health_percent <= src.consume_at_health_percent)
        src.visible_message("<span style='color: red; font-weight: bold;'>Horrible sounds come from [src]!</span>")
        playsound(src, 'sound/impact_sounds/Flesh_Tear_1.ogg', 100, 1)
        playsound(src, 'sound/effects/bubbles.ogg', 100, 1)
        // if there's a ghost, time to pull them back
        if (M.ghost && M.ghost.mind && !(M.mind && M.mind.dnr)) // if they have dnr set don't bother shoving them back in their body
          boutput(M.ghost, "<span class='notice'>You are dimly aware of bubbling fluid.</span>")
          M.ghost.mind.transfer_to(M)
          qdel(M.ghost)
        M = M.make_critter(src.growing_variant)
        src.occupant = M
        M.set_loc(src) // the value of target has changed, do not edit this/delete this
        M.TakeDamage("All", 30, 30)
        src.growing = 1
  else
    // look around for dead bodies and consume them
    if(!src.in_use)
      if(src.can_process_other_species)
        // if they're human bodies or martian mobcritter bodies or monkey bodies, consume them and either begin processing into martian or harvest the brain
        for(var/mob/living/L in oview(src, 1))
          if(!isalive(L)) // sucks to be unconscious, this thing is not bright enough to distinguish between unconscious and dead
            consume(L, src.reject_chance)
            return
      else
        for(var/mob/living/critter/martian/L in oview(src, 1))
          if(!isalive(L))
            consume(L, 0)
            return

/obj/martianBiotech/cloner/martianInteract(var/mob/user)
  if(src.in_use)
    var/mob/living/M = src.occupant
    var/health_percent = round((M.health / M.max_health) * 100)
    if(src.growing)
      boutput(user, "<span class='notice'>Current occupant is [health_percent]% grown.</span>")
    else
      boutput(user, "<span class='notice'>Current occupant is [100 - health_percent]% consumed.</span>")
  else if(src.cooldown > 0)
    boutput(user, "<span class='notice'>Cloner is resting. Normal function will resume shortly.</span>")
  else
    boutput(user, "<span class='notice'>This device processes Martian bodies that are placed into it or next to it.</span>")

/obj/martianBiotech/cloner/attackby(obj/item/W, mob/user)
  var/obj/item/grab/G = W
  if (ismartian(user) && istype(G) && ismob(G.affecting))
    if(src.in_use)
      boutput(user, "<span class='notice'><B>The cloner is already occupied!</B></span>")
    else if(src.cooldown > 0)
      boutput(user, "<span class='notice'><B>The cloner is resting!</B></span>")
    else
      var/mob/M = G.affecting
      if(src.can_process_other_species || ismartian(M))
        boutput(user, "<span class='notice'><B>The cloner snatches your offering from your tentacles!</B></span>")
        src.consume(M, 0) // yes I know this bypasses the reject chance but who the fuck is going to notice when processing other species is an admin gimmick anyway
        qdel(G)
      else
        boutput(user, "<span class='notice'><B>The cloner's biology is incompatible with this subject's. Perhaps consider putting it into a biomass pool?</B></span>")
    return
  else
    ..(W, user)

/obj/martianBiotech/cloner/proc/consume(var/mob/living/target, var/reject_chance=0)
  if(!target)
    return // always helps to be defensive
  src.growing_variant = /mob/living/critter/martian

  // figure out what type of martian to grow while consuming
  var/is_martian = ismartian(target)
  if((prob(reject_chance) && !is_martian) || (target.mind && target.mind.dnr) || (target.traitHolder && target.traitHolder.hasTrait("puritan")))
    src.do_rejection = 1
  if(is_martian)
    if(target.type in typesof(/mob/living/critter/martian)) // never hurts to double check
      src.growing_variant = target.type
  else
    src.growing_variant = pick(whitelisted_martian_types)
  // now consume
  src.visible_message("<span style='color: red; font-weight: bold;'>[src] [pick("devours", "swallows", "consumes", "gulps down", "snaps up")] [target]![prob(20) ? " Holy shit!" : ""]</span>")
  playsound(src, 'sound/impact_sounds/Flesh_Tear_1.ogg', 100, 1)
  target.set_loc(src)
  src.in_use = 1
  src.occupant = target
  src.icon_state = "cloner-on"


/obj/martianBiotech/cloner/converter
  // a gimmick version that will always convert humans into martians (if they aren't puritans or DNR)
  can_process_other_species = 1
  reject_chance = 0
