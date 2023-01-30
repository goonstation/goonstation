//all switched objects in ID-based switched object groups should have:
//- a call to ADD_SWITCHED_OBJECT in initialize, using a switched object category define, and a call to REMOVE_SWITCHED_OBJECT in disposing.
//- an "id" var (typically null by default, and varedit-able in maps; used to group the switchable objects)
//- a "toggle" proc that accepts a true/false state (handled in decorations.dm currently)
//if you miss any of these, things are probably gonna break

#define ADD_SWITCHED_OBJ(cat) if(!switched_objs[cat]) { switched_objs[cat] = list() }; \
	if(!switched_objs[cat][src.id]) { switched_objs[cat][src.id] = list() }; \
	switched_objs[cat][src.id] += src

#define REMOVE_SWITCHED_OBJ(cat) switched_objs[cat][src:id] -= src
