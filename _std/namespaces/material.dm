CREATE_NAMESPACE(MATERIAL)

/// Constants used to set material amounts in relative terms
CREATE_NAMESPACE(MATERIAL, AMOUNT)

ADD_TO_NAMESPACE(MATERIAL, AMOUNT)(var/const/TILE = 0.025)
ADD_TO_NAMESPACE(MATERIAL, AMOUNT)(var/const/ROD = 0.05)
ADD_TO_NAMESPACE(MATERIAL, AMOUNT)(var/const/SHEET = 0.1)
ADD_TO_NAMESPACE(MATERIAL, AMOUNT)(var/const/DEFAULT = 1)


/// Constants used to tell materials how they are hitting or being hit by things
CREATE_NAMESPACE(MATERIAL, IMPACT)
// Should only be using one of the following: MELEE, THROW, PROJECTILE
ADD_TO_NAMESPACE(MATERIAL, IMPACT)(var/const/MELEE = (1 << 0))
ADD_TO_NAMESPACE(MATERIAL, IMPACT)(var/const/THROW = (1 << 1))
ADD_TO_NAMESPACE(MATERIAL, IMPACT)(var/const/PROJECTILE = (1 << 2))

ADD_TO_NAMESPACE(MATERIAL, IMPACT)(var/const/CUT = (1 << 3)) // Flag indicates that the impact is with a sharp object (such as a blade or spear)
