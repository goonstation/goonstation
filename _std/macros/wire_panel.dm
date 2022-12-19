#define WPANEL_CUSTOM_ACT(C, F, B) new /datum/wirePanel/wireActs(control=C, to_fix=F, to_break=B)
#define WPANEL_INDICATOR(W, C, A, I) new /datum/wirePanel/indicatorDefintion(control=W, color=C, active=A, inactive=I)
