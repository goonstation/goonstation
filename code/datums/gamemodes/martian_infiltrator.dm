// NOTE: THIS IS DISTINCT FROM THE PLANNED "MARTIAN MODE", WHICH I HAVE INTERNALLY LABELLED AS "MARTIAN INVASION"
// THIS IS A POTENTIAL GAME MODE THAT REVOLVES AROUND ESTABLISHING A BASE ON THE STATION
// AS OPPOSED TO HAVING AN ESTABLISHED BASE AND NEEDING TO FLY IT AROUND THE STATION
// FIXME: THIS IS BROKE AS FUCK DON'T USE IT
/datum/game_mode/martian_infiltrator
  name = "martian infiltration"
  config_tag = "martian_infiltration"
  shuttle_available = 2

  var/list/datum/mind/martians = list()
  var/const/martians_possible = 3

  var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
  var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

  var/outcome = 0

/datum/game_mode/martian_infiltrator/announce()
  boutput(world, "<B>The current game mode is - Martian Infiltration!</B>")
  boutput(world, "<B>Martian agents have infiltrated [station_name(1)]! They intend to turn the [station_or_ship()] into a staging area for a full invasion.</B>")


/datum/game_mode/martian_infiltrator/pre_setup()
