//all switched objects in ID-based switched object groups should have an ID var. please ensure this is the case. *please*

#define ADD_SWITCHED_OBJ(cat) if(!switched_objs[cat]) { switched_objs[cat] = list() }; \
if(!switched_objs[cat][src:id]) { switched_objs[cat][src:id] = list() }; \
switched_objs[cat][src:id] += src

#define REMOVE_SWITCHED_OBJ(cat) switched_objs[cat][src:id] -= src
