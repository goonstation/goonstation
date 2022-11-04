///////////////////////////
// MARTIAN BIOTECH SEED
///////////////////////////
// these things are planted by martian tentacles

// seed as item

/obj/item/martianSeed
  name = "spiky lump"
  desc = "Pointy!"
  icon = 'icons/obj/martian.dmi'
  icon_state = "seed"
  w_class = W_CLASS_TINY
  stamina_damage = 1
  stamina_cost = 1
  rand_pos = 1
  var/martianName = "structural seed"
  var/martianDesc = "Once primed, this seed can be applied to the ground to form a new structure."
  var/obj/martianBiotech/spawn_path = null
  var/active = 0

/obj/item/martianSeed/New(var/atom/loc, var/obj/martianBiotech/thing_to_spawn)
  ..()
  if(thing_to_spawn)
    src.spawn_path = thing_to_spawn
  else
    var/list/possible_spawns = typesof(/obj/martianBiotech) - /obj/martianBiotech
    possible_spawns -= /obj/martianBiotech/structureSpawner // this could go so badly wrong
    src.spawn_path = pick(possible_spawns)
  src.martianName = "[initial(spawn_path.martianName)] seed"

/obj/item/martianSeed/special_desc(dist, mob/user)
  if(ismartian(user))
    var/special_desc = "This is \an [src.martianName]."
    special_desc += "<br>[src.martianDesc]"
    return special_desc
  else
    return null // give the standard description

/obj/item/martianSeed/attack_self(mob/user as mob)
  if(ismartian(user))
    if(active)
      boutput(user, "It's already active, use it on a non-space tile to plant it!")
    else
      playsound(src.loc, pick('sound/machines/ArtifactMar1.ogg', 'sound/machines/ArtifactMar2.ogg'), 60, 1)
      icon_state = "seed_active"
      active = 1
      user.visible_message("<span class='notice'><b>[user]</b> activates the seed!</span>", "<span class='notice'>You activate the seed!</span>")
      src.martianDesc = "It's active. Apply to the ground to form a new structure."
  else
    boutput(user, "<span class='alert'>You have no idea how to use this!</span>")

/obj/item/martianSeed/proc/plant(var/turf/T=null)
  if(!T)
    T = get_turf(src)
  if(istype(T, /turf/space))
    return
  if(src.active)
    playsound(T, 'sound/impact_sounds/Flesh_Stab_2.ogg', 60, 1)
    T.visible_message("<span style='game'>[src] is planted on [T].</span>")
    //T = new /turf/simulated/martian/floor(T)
    new /obj/martianBiotech/structureSpawner(T, src.spawn_path)
    qdel(src)


// seed as structure

/obj/martianBiotech/structureSpawner
  name = "bulging lump"
  desc = "Oh, god, that's gross as fuck."
  icon = 'icons/obj/martian.dmi'
  icon_state = "seed_grow1"
  martianName = "structual sac"
  martianDesc = "Something is growing within this protective sac."
  layer = OBJ_LAYER + 1 // needs to display above the biotech for the final animation
  health = 100
  var/obj/martianBiotech/spawn_path = null
  var/time_elapsed = 0 // in byond deciseconds because ugh
  var/time_started = 0 // the world timeofday when we began for rollover checking purposes (deciseconds)
  var/growth_time = 0 // how long the thing needs to grow for before it's considered complete
  var/active = 0

/obj/martianBiotech/structureSpawner/New(var/atom/loc, var/obj/martianBiotech/thing_to_spawn)
  ..()
  if(thing_to_spawn)
    src.spawn_path = thing_to_spawn
    src.time_started = world.timeofday
    src.growth_time = initial(thing_to_spawn.growthTime) * 10 // growthTime for the biotech is specified in seconds
    src.health = 1 // let's do the zerg thing of growth = health
    src.active = 1
    src.martianDesc = "\A [initial(spawn_path.martianName)] is growing within this protective sac."
  else
    // INVALID
    qdel(src)

/obj/martianBiotech/structureSpawner/process()
  ..()
  if(src.active)
    var/time_of_day = world.timeofday + ((world.timeofday < src.time_started) ? 864000 : 0) // Offset the time of day in case of midnight rollover
    src.time_elapsed = time_of_day - src.time_started
    var/percent = src.time_elapsed/src.growth_time * 100
    src.maxHealth = max(1, round(percent))
    switch(percent)
      if(-INFINITY to 49)
        // we shouldn't really need to get here
        src.icon_state = "seed_grow1"
      if(50 to 99)
        src.icon_state = "seed_grow2"
      if(100 to INFINITY)
        // we're done here
        src.active = 0
        playsound(src, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
        playsound(src, 'sound/impact_sounds/Slimy_Splat_2.ogg', 100, 1)
        src.visible_message("<span style='color: red; font-weight: bold;'>[src] bursts open!</span>")
        new spawn_path(src.loc)
        src.icon_state = "seed_dead"
        flick("seed_burst", src)
        sleep(10 SECONDS)
        qdel(src)
