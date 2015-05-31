phi = (1 + sqrt(5)) / 2; // golden ratio

radius = 300; // of the circumscribed sphere
width = 20; // of the edges
thickness = 6; // of the edges
degree = 3; // number of segments on each original icosahedron edge.
// Thus each icosahedron face is divided on degree^2 triangles.
delta = 7; // gap at edge ends (radius of the gray spere that touches edges)
curved_edges = false;

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
	if (curved_edges)
		edge2d_curved(p1, p2);
	else
		edge2d_straight(p1, p2);
}

module edge2d_straight(p1, p2) {
	a = norm(p1 - p2) / 2;
	b = norm(p1 + p2) / 2;
	x = delta * radius / b;
	y = a * width / b;
	alpha = atan2(a, b);
	translate([0, -b]) difference() {
		polygon(
			points = [[-a + x - y, b + width], [a - x + y, b + width], [a - x, b], [-a + x, b]],
			paths = [[0, 1, 2, 3]]
		);
		for (i = [-1, 1])
			translate([ i * a, b]) rotate(-i * alpha) translate([0, thickness / 2]) square([2 * delta + width, thickness], center = true);
	}
}

module edge2d_curved(p1, p2) {
	a = norm(p1 - p2) / 2;
	b = norm(p1 + p2) / 2;
	h = radius + width + 1;
	c = h * a / b;
	alpha = atan2(a, b);
	translate([0, -b]) difference() {
		intersection() {
			circle(r = radius + width, $fa = 1);
			polygon(points = [[-c, h], [c, h], [0, 0]], paths = [[0, 1, 2]]);
		}
		circle(r = radius, $fa = 1);
		rotate(alpha) translate([-delta, 0]) square([2 * delta, h]);
		rotate(-alpha) translate([-delta, 0]) square([2 * delta, h]);
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



module vertex2d(sides) {
	difference() {
		circle(r = width + delta, $fn = sides);
		rotate(180 / sides) circle(r = delta, $fn = sides);
		for (i = [0 : sides - 1])
			rotate(i * 360 / sides) translate([delta + width / 2, - thickness / 2]) square([width, thickness]);
	}
}

module vertex(sides, p1, p2) {
	k = normalize(p1);
	j = normalize(cross(k, p2));
	i = cross(j, k);
	t = normalize(p1) * (radius + thickness / 2);
	change_coord(i, j, k, t) {
		translate([0, 0, -thickness / 2]) linear_extrude(height = thickness) vertex2d(sides);
		// cube([30, thickness, thickness], center = true);
	}
}


module vertices(a, b, c) {
	ab = (b - a) / degree;
	ac = (c - a) / degree;
	vertex(5, a, b);
	vertex(5, b, c);
	vertex(5, c, a);
	for (j = [1:degree - 1])
		vertex(6, a + j * ab, a + (j + 1) * ab);
	for (i = [1:degree - 1], j = [0:degree - i]) {
		p = a + i * ac + j * ab;
		vertex(6, p, p + ab);
	}
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
	for(f = faces)
		if (f[0] != 6 && f[1] != 6 && f[2] != 6)
			divide_face(points[f[0]], points[f[1]], points[f[2]]);

}


//rotate([atan(1 / phi), 0, 0]) dome();

// geode();
// for (i = [0:4]) v5(points[i], points[i + 1]);

// geode();
// for (f = faces)
// 	vertices(points[f[0]], points[f[1]], points[f[2]]);

divide_face(points[0], points[1], points[2]);
% vertices(points[0], points[1], points[2]);


// edge2d(normalize(points[0]) * radius, normalize((2 * points[0] + points[1]) / 3) * radius);

