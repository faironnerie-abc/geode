// 3-geode parts for laser cutter

include <geode-shell.scad>;

mark_size = 3;
mark_points = [[0, -mark_size], [mark_size, 0], [0, mark_size]];
board_size = [1200, 800];

// Parts needed for a complete geode :
// edgeA x  60
// edgeB x  90
// edgeC x 120
// Total   270 

// jointA x 12
// jointB x 60
// jointC x 20
// Total    92

// Edges

module edgeA() {
	a = normalize(points[0]) * radius;
	b = normalize((2 * points[0] + points[1]) / 3) * radius;
	edge2d(a, b);
}

module edgeB() {
	a = normalize((2 * points[0] + points[1]) / 3) * radius;
	b = normalize((points[0] + 2 * points[1]) / 3) * radius;
	difference() {
		edge2d(a, b);
		translate([0, - mark_size / 2]) rotate(90) polygon(mark_points);
	}
}

module edgeC() {
	a = normalize((2 * points[0] + points[1]) / 3) * radius;
	b = normalize((points[0] + points[1] + points[2]) / 3) * radius;
	difference() {
		edge2d(a, b);
		translate([-mark_size / 2, - mark_size / 2]) rotate(90) polygon(mark_points);
		translate([mark_size / 2, - mark_size / 2]) rotate(90) polygon(mark_points);
	}
}

// Joints 

function joint_dir(p, n) = let(k = normalize(p), j = normalize(cross(k, n)), i = cross(j, k)) i;

module joint2d(p, neighbors, mark = false) {
	dirs = [for (n = neighbors) joint_dir(p, n)];
	i = dirs[0];
	k = normalize(cross(dirs[0], dirs[1]));
	j = cross(k, i);
	dirs2d = [for (d = dirs) let(dn = [i, j, k] * d) [dn[0], dn[1]]];
	difference() {
		polygon((delta + width) * dirs2d);
		circle(r = delta);
		for (d = dirs2d)
			rotate(sign(d[1]) * acos(d[0])) translate([delta + width / 2, -thickness / 2]) square([width, thickness]);
		if (mark) translate([delta - mark_size / 2, 0]) polygon(mark_points);
	}
}

module test_joint(p, neighbors, mark = false) {
	k = normalize(p);
	j = normalize(cross(k, neighbors[0]));
	i = cross(j, k);
	t = k * radius;
	change_coord(i, j, k, t) linear_extrude(height = thickness) joint2d(p, neighbors, mark);
	% for (n = neighbors) edge(p, n);
}

module joint(p, neighbors, test = false, mark = false) {
	if (test)
		test_joint(p, neighbors, mark);
	else
		joint2d(p, neighbors, mark);
}


module jointA(test = false) {
	p = points[4];
	neighbors = [for(i = [3, 5, 11, 10, 8]) (2 * p + points[i]) / 3];
	joint(p, neighbors, test);
}

module jointB(test = false) {
	p = (2 * points[4] + points[8]) / 3;
	neighbors = [
		3 * points[4],
		2 * points[4] + points[10],
		points[4] + points[10] + points[8],
		points[4] + 2 * points[8],
		points[4] + points[8] + points[3],
		2 * points[4] + points[3]
	] / 3;
	joint(p, neighbors, test, mark = true);
}

module jointC(test = false) {
	p = (points[4] + points[8] + points[3]) / 3;
	neighbors = [
		2 * points[4] + points[8],
		points[4] + 2 * points[8],
		2 * points[8] + points[3],
		points[8] + 2 * points[3],
		2 * points[3] + points[4],
		points[3] + 2 * points[4],
	] / 3;
	joint(p, neighbors, test);
}

// Boards

function edge_length(p1, p2) =
	let(
		proj1 = normalize(p1) * radius,
		proj2 = normalize(p2) * radius,
		a = norm(proj1 - proj2) / 2,
		b = norm(proj1 + proj2) / 2,
		x = delta * radius / b,
		y = a * width / b
	) 2 * (a - x + y);

// one copy of each part
module sample() {
	edgeA();
	translate([0, width + 2]) edgeB();
	translate([0, 2 * (width + 2)]) edgeC();
	translate([-2*(delta + width) - 1, 3 * (width + 2) + delta + width]) jointA();
	translate([0, 3 * (width + 2) + delta + width]) jointB();
	translate([2*(delta + width) + 1, 3 * (width + 2) + delta + width]) jointC();
}

// parts needed for one icosahedron face
module board_test() {
	la = edge_length(points[0], (2 * points[0] + points[1]) / 3);
	lb = edge_length(2 * points[0] + points[1], (points[0] + 2 * points[1]) / 3);
	lc = edge_length((2 * points[0] + points[1]) / 3, (points[0] + points[1] + points[2]) / 3);
	echo(la, lb, lc);
	% square(board_size);
	for (i = [0:5]) translate([la / 2, i * (width + 2)]) edgeA();
	for (i = [0:5]) translate([lb / 2, (i + 6) * (width + 2)]) edgeB();
	for (i = [0:5]) translate([lc / 2, (i + 12) * (width + 2)]) edgeC();
	s = 2 * (delta + width);
	for(j = [0:2]) translate([s / 2 + j * s, s / 2 + 18 * (width + 2)]) jointA();
	translate([s / 2 + 3 * s, s / 2 + 18 * (width + 2)]) jointC();
	translate([s / 2 + 4 * s, s / 2 + 18 * (width + 2)]) jointB();
	for (j = [0:4]) translate([s / 2 + j * s, s / 2 + 18 * (width + 2) + s]) jointB();
}

module board1() {
	la = edge_length(points[0], (2 * points[0] + points[1]) / 3);
	lb = edge_length(2 * points[0] + points[1], (points[0] + 2 * points[1]) / 3);
	lc = edge_length((2 * points[0] + points[1]) / 3, (points[0] + points[1] + points[2]) / 3);
	s = 2 * (delta + width);
	echo(la, lb, lc);
	% square(board_size);
	// 120 x edgeC
	for (i = [0:39], j = [0:2]) translate([lc / 2 + j * (lc + 2), i * (width + 2)]) edgeC();
	// 40 x edgeB
	for(i = [0:39]) translate([lb / 2 + 3 * (lc + 2), i * (width + 2)]) edgeB();
	// 40 x edgeA
	for(i = [0:39]) translate([la / 2 + 3 * (lc + 2) + (lb + 2), i * (width + 2)]) edgeA();
	// 52 x jointB
	for(i = [0:1], j = [0:25]) translate([s / 2 + j * s, s / 2 + 40 * (width + 2) + i * s]) jointB();	
}

module board2() {
	la = edge_length(points[0], (2 * points[0] + points[1]) / 3);
	lb = edge_length(2 * points[0] + points[1], (points[0] + 2 * points[1]) / 3);
	lc = edge_length((2 * points[0] + points[1]) / 3, (points[0] + points[1] + points[2]) / 3);
	s = 2 * (delta + width);
	echo(la, lb, lc);
	% square(board_size);
	// 50 x edgeB
	for(i = [0:34]) translate([lb / 2, i * (width + 2)]) edgeB();
	for(i = [0:14]) translate([lb / 2 + (lb + 2), i * (width + 2)]) edgeB();
	// 20 x edgeA
	for (i = [0:19]) translate([la / 2 + (lb + 2), (15 + i) * (width + 2)]) edgeA();
	// 20 x edgeC
	for(i = [0:9], j = [0:1]) translate([s / 2 + i * s, s / 2 + 35 * (width + 2) + j * s]) jointC();
	// 12 x jointA
	for (i = [0:9]) translate([s / 2 + i * s, s / 2 + 35 * (width + 2) + 2 * s]) jointA();
	for (i = [0:1]) translate([s / 2 + i * s, s / 2 + 35 * (width + 2) + 3 * s]) jointA();
	// 8 jointB
	for (i = [0:7]) translate([s / 2 + 2 * s + i * s, s / 2 + 35 * (width + 2) + 3 * s]) jointB();
}

// sample();
// board_test();
board1();
// board2();

// jointA(true);
// jointB(true);
// jointC(true);

