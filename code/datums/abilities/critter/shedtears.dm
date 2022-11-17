// Eyespider puddle maker, pretty simple
/datum/targetable/critter/shedtears
  name = "Shed Tears"
  desc = "Truly, the plight of the noble eyespider is a tragic one."
  cooldown = 150
  start_on_cooldown = 0
  icon_state = "tears"

/datum/targetable/critter/shedtears/cast(atom/target)
  if (..())
    return 1

  var/turf/T = get_turf(holder.owner)
  if(istype(T))
    playsound(T, 'sound/effects/bubbles_short.ogg', 80, 1)
    holder.owner.visible_message("<span class='notice'><b>[holder.owner]</b> drips a puddle of teardrops onto the floor!</span>",
                                 "<span class='notice'>You drip a puddle of tears onto the floor.</span>")

    make_cleanable(/obj/decal/cleanable/water,holder.owner.loc)
