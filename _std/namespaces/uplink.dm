/// Namespace for all things Uplinks.
CREATE_NAMESPACE(UPLINK)

/// The UI categories of the uplinks. Order effects the order of tabs in the ui!
/// Some categories are automatically applied, overriding whatever the set category is
CREATE_NAMESPACE(UPLINK, CATEGORY)

ADD_TO_NAMESPACE(UPLINK, CATEGORY)(var/const/WEAPON = "Weaponry")
ADD_TO_NAMESPACE(UPLINK, CATEGORY)(var/const/AMMO = "Ammunition") //Automatic
ADD_TO_NAMESPACE(UPLINK, CATEGORY)(var/const/EXPLOSIVE = "Explosives")
ADD_TO_NAMESPACE(UPLINK, CATEGORY)(var/const/IMPLANT = "Implants")
ADD_TO_NAMESPACE(UPLINK, CATEGORY)(var/const/JOB = "Job-Specific") //Automatic
ADD_TO_NAMESPACE(UPLINK, CATEGORY)(var/const/OBJECTIVE = "Objective") //Automatic
ADD_TO_NAMESPACE(UPLINK, CATEGORY)(var/const/TELECRYSTAL = "Telecrystals") //Automatic
ADD_TO_NAMESPACE(UPLINK, CATEGORY)(var/const/MISC = "Miscellaneous")

