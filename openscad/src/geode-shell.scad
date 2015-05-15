phi = (1 + sqrt(5)) / 2; // golden ratio

radius = 300; // of the circumscribed sphere
width = 15; // of the edges
thickness = 6; // of the edges
degree = 3; // nuber of segments on each original icosahedron edge.
// Thus each icosahedron face is divided on degree^2 triangles.

function normalize(v) = v / norm(v);

module edge(p1, p2) {
	proj1 = normalize(p1) * radius;
	proj2 = normalize(p2) * radius;
	diff = (proj1 - proj2);
	mid = (proj1 + proj2) / 2;
	length = norm(diff);
	i = normalize(diff);
	j = normalize(mid);
	k = cross(i, j);
	%translate(proj1) sphere(thickness);
	%translate(proj2) sphere(thickness);
	multmatrix(m = [
		[i[0], j[0], k[0], mid[0]],
		[i[1], j[1], k[1], mid[1]],
		[i[2], j[2], k[2], mid[2]],
		[0, 0, 0, 1],
		]) {
		cube([length, width, thickness], center = true);
	}
}

module divide_face_helper(a, b, c) {
	ab = (b - a) / degree;
	ac = (c - a) / degree;
	for (i = [0 : degree - 1]) {
		for (j = [0:degree - 1 - i]) {
			p = a + i * ab + j * ac;
			edge(p, p + ab);
		}
	}
}

module divide_face(a, b, c) {
	divide_face_helper(a, b, c);
	divide_face_helper(b, c, a);
	divide_face_helper(c, a, b);
}

module geode() {
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
	for(f = faces) {
		divide_face(points[f[0]], points[f[1]], points[f[2]]);
	}
}

geode();