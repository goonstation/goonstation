CREATE_NAMESPACE(FOOD)

/// What kind of kitchen utensil is this / is needed to eat this.
CREATE_NAMESPACE(FOOD, UTENSIL)
ADD_TO_NAMESPACE(FOOD, UTENSIL)(var/const/FORK = (1<<0))
ADD_TO_NAMESPACE(FOOD, UTENSIL)(var/const/SPOON = (1<<1))
ADD_TO_NAMESPACE(FOOD, UTENSIL)(var/const/KNIFE = (1<<2))

// Meal Times used to identify when a food product might TYPICALLY be consumed
CREATE_NAMESPACE(FOOD, MEAL)
ADD_TO_NAMESPACE(FOOD, MEAL)(var/const/BREAKFAST = (1<<0))
ADD_TO_NAMESPACE(FOOD, MEAL)(var/const/LUNCH = (1<<1))
ADD_TO_NAMESPACE(FOOD, MEAL)(var/const/DINNER = (1<<2))
ADD_TO_NAMESPACE(FOOD, MEAL)(var/const/SNACK = (1<<3))
ADD_TO_NAMESPACE(FOOD, MEAL)(var/const/FORBIDDEN_TREAT = (1<<4))
