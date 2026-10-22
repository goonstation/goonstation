/// Namespace for all things Medals.
CREATE_NAMESPACE(MEDAL)

/// Rewards given for medals
CREATE_NAMESPACE(MEDAL, REWARD)

/// Categories for Rewards given for medals
CREATE_NAMESPACE(MEDAL, REWARD, CATEGORY)

ADD_TO_NAMESPACE(MEDAL, REWARD, CATEGORY)(var/const/ITEM = "Item")
ADD_TO_NAMESPACE(MEDAL, REWARD, CATEGORY)(var/const/CLOTHING = "Clothing")
ADD_TO_NAMESPACE(MEDAL, REWARD, CATEGORY)(var/const/SILICON = "Silicon")
ADD_TO_NAMESPACE(MEDAL, REWARD, CATEGORY)(var/const/MISCELLANEOUS = "Miscellaneous")
