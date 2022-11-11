// hey, do you love the ridiculous bullshit the singularity does?
// well now it's critter abilities, enjoy

////////////////////////////////////////////////////////////////////////////////////////
// Zzzzap (EMP) ////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/targetable/critter/zzzap
  name = "Zzzap"
  desc = "Send out an electromagnetic pulse."
  icon_state = "zzzap"
  cooldown = 1200

/datum/targetable/critter/zzzap/cast(atom/target)
  if (..())
    return 1

  var/turf/T = get_turf(holder.owner)

  playsound(T, 'sound/effects/elec_bzzz.ogg', 100, 1)
  holder.owner.visible_message("<span class='combat'><b>[holder.owner] [pick("sparks", "flashes", "buzzes")] [pick("oddly", "worryingly", "powerfully", "loudly", "intensely")]!</b></span>", "<span class='combat'><b>You emit an electromagnetic pulse!</b></span>")
  var/obj/overlay/pulse = new/obj/overlay(T)
  pulse.icon = 'icons/effects/effects.dmi'
  pulse.icon_state = "emppulse"
  pulse.name = "emp pulse"
  pulse.anchored = 1
  SPAWN(2 SECONDS)
    if (pulse)
      qdel(pulse)

  for (var/mob/M in all_viewers(world.view-1, T))
    if (!isliving(M))
      continue
    M.emp_act()
  for (var/obj/machinery/M in range(world.view-1, T))
    M.emp_act()

////////////////////////////////////////////////////////////////////////////////////////
// Bholerip (rip floors & walls to pieces) /////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/targetable/critter/bholerip
  name = "Black-Hole Rip"
  desc = "Tear up floors and walls around you."
  icon_state = "bholerip"
  cooldown = 1000
  var/range = 5

/datum/targetable/critter/bholerip/cast(atom/target)
  if (..())
    return 1

  var/turf/ST = get_turf(holder.owner) // sound turf

  playsound(ST, 'sound/effects/suck.ogg', 100, 1)
  playsound(ST, 'sound/machines/hiss.ogg', 100, 1)
  holder.owner.visible_message("<span class='combat'><b>[holder.owner] [pick("sucks", "pulls", "jerks")] everything towards itself [pick("wildly", "forcefully", "powerfully", "loudly", "intensely")]!</b></span>", "<span class='combat'><b>You concentrate your gravitational pull to an intense extreme!</b></span>")
  // XTREEEEEEM SKATEBOARDS SUNGLASSES 90S WOOOO

  // copy pasted from the singularity because lol more copy paste shoot me
  // default material cached
  var/datum/material/defaultMaterial = getMaterial("steel")
  for (var/turf/T in orange(range,holder.owner))
    LAGCHECK(LAG_LOW)
    if (prob(70))
      continue
    if (T && !istype(T, /turf/space))
      if (istype(T,/turf/simulated/floor) && !istype(T,/turf/simulated/floor/plating))
        var/turf/simulated/floor/F = T
        if (!F.broken)
          if (prob(80))
            var/obj/item/tile/L = new /obj/item/tile(F)
            if(F.material)
              L.setMaterial(F.material)
            else
              L.setMaterial(defaultMaterial)
            F.break_tile_to_plating()
          else
            F.break_tile()
      else if (istype(T, /turf/simulated/wall))
        var/turf/simulated/wall/W = T
        if (istype(W, /turf/simulated/wall/r_wall) || istype(W, /turf/simulated/wall/auto/reinforced))
          new /obj/structure/girder/reinforced(W)
        else
          new /obj/structure/girder(W)
        var/obj/item/sheet/S = new /obj/item/sheet(W)
        if (W.material)
          S.setMaterial(W.material)
        else
          S.setMaterial(defaultMaterial)
        W.ReplaceWithFloor()
      else
        T.ReplaceWithFloor()

////////////////////////////////////////////////////////////////////////////////////////
// Toxmob (irradiate nearby things) ////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/targetable/critter/toxmob
  name = "Toxmob"
  desc = "Irradiate everything around you."
  icon_state = "toxmob"
  cooldown = 1500

/datum/targetable/critter/toxmob/cast(atom/target)
	if (..())
		return 1

  // no visible message for anyone else, but there is a sound clue
	var/turf/T = get_turf(holder.owner)
	playsound(T, 'sound/weapons/ACgun2.ogg', 100, 1)
	holder.owner.show_message("<span class='combat'><b>You emit a wave of radiation!</b></span>")

	for(var/mob/living/L in oviewers(7, holder.owner))
		L.take_radiation_dose(0.1 SIEVERTS)
		L.show_text("You feel odd.", "red")

////////////////////////////////////////////////////////////////////////////////////////
// Mezzer (stun nearby thing) //////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/targetable/critter/mezzer
  name = "Mezzer"
  desc = "Dazzle everyone nearby with your incomprehensible brilliance."
  icon_state = "mezzer"
  cooldown = 1500

/datum/targetable/critter/mezzer/cast(atom/target)
  if (..())
    return 1

  var/turf/T = get_turf(holder.owner)
  playsound(T, 'sound/effects/ghost.ogg', 100, 1)
  holder.owner.show_message("<span class='combat'><b>You compel all to gaze upon your singular magnificence...</b></span>")

  for (var/mob/living/M in oviewers(8, holder.owner))
    if (ishuman(M))
      var/mob/living/carbon/human/H = M
      if (istype(H.glasses,/obj/item/clothing/glasses/meson))
        M.show_text("You look directly into [holder.owner.name], good thing you had your protective eyewear on!", "green")
        return
    M.changeStatus("stunned", 3 SECONDS)
    M.visible_message("<span class='alert'><B>[M] stares blankly at [holder.owner]!</B></span>",\
    "<B>You look directly into [holder.owner]!<br><span class='alert'>You feel weak!</span></B>")
