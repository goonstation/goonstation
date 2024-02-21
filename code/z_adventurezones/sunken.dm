// martian wreck in an ocean floor biolab
// small area to perhaps hold some hints towards things to come


// SUNKEN AREA
/area/sunken
  name = "Underwater Facility"
  icon_state = "blue"
  skip_sims = 1
  sims_score = 15
  ambient_light = rgb(37, 53, 79)
  // some notes on sound_environments used:
  // 3 - bathroom for SUPER enclosed spaces
  // 21 - sewer pipe for enclosed aquatic areas
  // 22 - underwater for actual underwater areas (how i long for a low pass filter)
  sound_environment = 21
  filler_turf = "/turf/space/fluid"
  sound_group = "sunken"

