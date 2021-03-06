phi = (1 + sqrt(5)) / 2; // golden ratio

radius = 500; // of the circumscribed sphere
width = 15; // of the edges
thickness = 6; // of the edges
degree = 3; // number of segments on each original icosahedron edge.
// Thus each icosahedron face is divided on degree^2 triangles.
delta = 7; // gap at edge ends (radius of the gray spere that touches edges)
eps = 0.1; // holes in edges and joints are eps smaller than thickness. May help for better fit.

function normalize(v) = v / norm(v);

module change_coord(i, j, k, t) {
	multmatrix(m = [
		[i[0], j[0], k[0], t[0]],
		[i[1], j[1], k[1], t[1]],
		[i[2], j[2], k[2], t[2]],
		[0, 0, 0, 1]
	]) children();
}

module edge(p1, p2) {
	proj1 = normalize(p1) * radius;
	proj2 = normalize(p2) * radius;
	diff = (proj1 - proj2);
	mid = (proj1 + proj2) / 2;
	length = norm(diff);
	i = normalize(diff);
	j = normalize(mid);
	k = cross(i, j);
	// % translate(proj1) sphere(delta);
	// % translate(proj2) sphere(delta);
	change_coord(i, j, k, mid)
		translate([0, 0, -thickness / 2]) linear_extrude(height = thickness) edge2d(proj1, proj2);
}

// we suppose that p1 and p2 are already projected on the sphere
module edge2d(p1, p2) {
	a = norm(p1 - p2) / 2;
	b = norm(p1 + p2) / 2;
	x = delta * radius / b;
	y = a * width / b;
	alpha = atan2(a, b);
	translate([0, -b]) difference() {
		polygon([[-a + x - y, b + width], [a - x + y, b + width], [a - x, b], [-a + x, b]]);
		for (i = [-1, 1])
			translate([ i * a, b]) rotate(-i * alpha) translate([0, thickness / 2]) square([2 * delta + width, thickness - eps], center = true);
	}
}

module divide_face_helper(a, b, c) {
	ab = (b - a) / degree;
	ac = (c - a) / degree;
	for (i = [0 : degree - 1], j = [0 : degree - 1 - i]) {
		p = a + i * ac + j * ab;
		edge(p, p + ab);
	}
}

module divide_face(a, b, c) {
	divide_face_helper(a, b, c);
	divide_face_helper(b, c, a);
	divide_face_helper(c, a, b);
}


points = [
	[   0,    1, -phi],
	[   1,  phi,    0],
	[  -1,  phi,    0],
	[   0,    1,  phi],
	[   0,   -1,  phi],
	[-phi,    0,    1],
	[   0,   -1, -phi],
	[ phi,    0,   -1],
	[ phi,    0,    1],
	[-phi,    0,   -1],
	[   1, -phi,    0],
	[  -1, -phi,    0]
];
faces = [
	[ 0,    1,    2],
	[ 3,    2,    1],
	[ 3,    4,    5],
	[ 3,    8,    4],
	[ 0,    6,    7],
	[ 0,    9,    6],
	[ 4,   10,   11],
	[ 6,   11,   10],
	[ 2,    5,    9],
	[11,    9,    5],
	[ 1,    7,    8],
	[10,    8,    7],
	[ 3,    5,    2],
	[ 3,    1,    8],
	[ 0,    2,    9],
	[ 0,    7,    1],
	[ 6,    9,   11],
	[ 6,   10,    7],
	[ 4,   11,    5],
	[ 4,    8,   10]
];


// note that subedges on the original edges are rendered twice
module geode() {
	for(f = faces)
		divide_face(points[f[0]], points[f[1]], points[f[2]]);

}

module dome() {
	rotate([atan(1 / phi)]) {
		for(f = faces)
			if (f[0] != 6 && f[1] != 6 && f[2] != 6)
				divide_face(points[f[0]], points[f[1]], points[f[2]]);
	}
}


//rotate([atan(1 / phi), 0, 0]) dome();

// geode();
// for (i = [0:4]) v5(points[i], points[i + 1]);

// geode();
// for (f = faces)
// 	vertices(points[f[0]], points[f[1]], points[f[2]]);

// divide_face(points[0], points[1], points[2]);
// % vertices(points[0], points[1], points[2]);


// edge2d(normalize(points[0]) * radius, normalize((2 * points[0] + points[1]) / 3) * radius);

