#define rand_pyramid( _L, _H) ((rand(_L,_H)+rand(_L,_H))/2)

#define rand_bell( _L, _H) ((rand( _L, _H)+rand( _L, _H)+rand( _L, _H))/3)

#define rand_half_pyramid( _L, _H) ((2/3) * (rand(_L,_H)) + (1/3) * (rand(_L,_H)))
