include <Triangulate.scad>;

radius = 1.0;
depth = 2;		// pas cap de faire plus de 12 ...
icosa = [[phi,1.,0],	// 0
         [-phi,1.,0.],	// 1
         [-phi,-1.,0.],	// 2
         [phi,-1.,0.],	// 3
         [1.,0.,phi],	// 4
         [1.,0.,-phi],	// 5
         [-1.,0.,-phi],	// 6
         [-1.,0.,phi],	// 7
         [0.,phi,1.],	// 8
         [0.,-phi,1.],	// 9
         [0.,-phi,-1.],	// 10
         [0.,phi,-1.]];	// 11

module start(a, b, c, depth, radius) {
	triangle([onsphere(icosa[a], radius),
	          onsphere(icosa[b], radius),
              onsphere(icosa[c], radius)], depth, radius);
}

start( 4,  3,  0, depth, radius);
start( 7,  9,  4, depth, radius);
start( 4,  9,  3, depth, radius);
start( 9, 10,  3, depth, radius);
start( 9,  2, 10, depth, radius);
start( 7,  2,  9, depth, radius);
start( 4,  0,  8, depth, radius);
start( 7,  4,  8, depth, radius);
start( 7,  8,  1, depth, radius);
start( 7,  1,  2, depth, radius);
start( 8,  0, 11, depth, radius);
start( 8, 11,  1, depth, radius);
start( 3,  5,  0, depth, radius);
start(10,  5,  3, depth, radius);
start( 0, 11,  5, depth, radius);
start( 2,  6,  1, depth, radius);
start( 2, 10,  6, depth, radius);
start( 1,  6, 11, depth, radius);
start(10,  5,  6, depth, radius);
start( 6,  5, 11, depth, radius);
