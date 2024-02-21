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
    playsound(T, 'sound/effects/bubbles_short.ogg', 80, TRUE)
    holder.owner.visible_message(SPAN_NOTICE("<b>[holder.owner]</b> drips a puddle of teardrops onto the floor!"),
                                 SPAN_NOTICE("You drip a puddle of tears onto the floor."))

    make_cleanable(/obj/decal/cleanable/water,holder.owner.loc)
