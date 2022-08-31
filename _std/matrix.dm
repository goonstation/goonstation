//Matrix extensions.
/matrix/proc/Shear()
	//THIS IS WHERE SOMEPOTATO WILL PUT HIS SHEAR STUFF. RIGHT HERE.
	return src

/matrix/proc/Pivot( var/x, var/y, var/rot, var/w = 32, var/h = 32 )
    src.Translate( w/2 + x, -h/2 + y )
    src.Turn( rot )
    src.Translate( -w/2 + x, h/2 + y )
    return src

//Scales a matrix while keeping 0,0 of the icon stationary. Think progress-bars.
/matrix/proc/StaticScale( var/scale_x, var/scale_y, var/width, var/height )
	var/adj_x = ((width * scale_x) - width) / 2
	var/adj_y = ((height * scale_y) - height) / 2

	src.Scale(scale_x, scale_y)
	src.Translate(round(adj_x), round(adj_y))
	return src

/matrix/proc/Reset()
	src.a = 1
	src.b = 0
	src.c = 0
	src.d = 0
	src.e = 1
	src.f = 0
	src.disposed = 0
	return src

/matrix/proc/is_identity()
	return \
		src.a == 1 && \
		src.b == 0 && \
		src.c == 0 && \
		src.d == 0 && \
		src.e == 1 && \
		src.f == 0
