// 3-geode parts for laser cutter

include <geode-shell.scad>;

mark_size = 3;
mark_points = [[0, -mark_size], [mark_size, 0], [0, mark_size]];
board_size = [1200, 800];
board_gap = 2;

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
			rotate(sign(d[1]) * acos(d[0])) translate([delta + width / 2, -(thickness - eps) / 2]) square([width, thickness - eps]);
		if (mark) translate([delta - mark_size / 2, 0]) polygon(mark_points);
	}
}

module test_joint(p, neighbors, mark = false) {
	k = normalize(p);
	j = normalize(cross(k, neighbors[0]));
	i = cross(j, k);
	t = k * radius;
	// intersection() {
		change_coord(i, j, k, t) linear_extrude(height = thickness) joint2d(p, neighbors, mark);
		% for (n = neighbors) edge(p, n);
	// }
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

module in_grid(xsize, ysize, xcount, ycount, gap = board_gap) {
	for(x = [0 : xcount - 1], y = [0 : ycount - 1])
		translate([x * (xsize + gap), y * (ysize + gap)]) children();
}

module in_3grid(r, xcount, ycount) {
	for(y = [0 : ycount - 1], x = [0 : xcount - 1])
		translate([(y % 2 + 2 * x), y * sqrt(3)] * r) children();
}


// parts needed for one icosahedron face
module board_test() {
	la = edge_length(points[0], (2 * points[0] + points[1]) / 3);
	lb = edge_length(2 * points[0] + points[1], (points[0] + 2 * points[1]) / 3);
	lc = edge_length((2 * points[0] + points[1]) / 3, (points[0] + points[1] + points[2]) / 3);
	echo(la, lb, lc);
	% square(board_size);
	translate([la / 2, 0]) in_grid(la, width, 1, 6) edgeA();
	translate([lb / 2, 6 * (width + board_gap)]) in_grid(lb, width, 1, 6) edgeB();
	translate([lc / 2, 12 * (width + board_gap)]) in_grid(lc, width, 1, 6) edgeC();
	r = delta + width;
	translate([r, r + 18 * (width + board_gap)]) {
		in_grid(2 * r, 2 * r, 3, 1, 0) jointA();
		translate([6 * r, 0]) jointC();
		translate([8 * r, 0]) jointB();
		translate([0, 2 * r]) in_grid(2 * r, 2 * r, 5, 1) jointB();
	}
}

module board_edges() {
	la = edge_length(points[0], (2 * points[0] + points[1]) / 3);
	lb = edge_length(2 * points[0] + points[1], (points[0] + 2 * points[1]) / 3);
	lc = edge_length((2 * points[0] + points[1]) / 3, (points[0] + points[1] + points[2]) / 3);
	echo(la, lb, lc);
	% square(board_size);
	// 90 x edgeB
	translate([lb / 2, 0]) in_grid(lb, width, 2, 45) edgeB();
	// 120 x edgeC
	translate([lc / 2 + 2 * (lb + board_gap), 0]) in_grid(lc, width, 3, 40) edgeC();
	// 60 x edgeA
	translate([la / 2 + 2 * (lb + board_gap) + 3 * (lc + board_gap), 0]) in_grid(la, width, 1, 40) edgeA();
	translate([la / 2 + 2 * (lb + board_gap), 40 * (width + board_gap)]) in_grid(la, width, 4, 5) edgeA();
}

module board_joints() {
	% square(board_size);
	r = delta + width;
	translate([r, r]) {
		// 12 x jointA
		in_3grid(r, 6, 2) jointA();
		// 60 x jointB
		translate([0, 2 * r * sqrt(3), 0]) in_3grid(r, 6, 10) jointB();
		// 20 x jointC
		translate([0, 12 * r * sqrt(3), 0]) in_3grid(r, 5, 4) jointC();
	}
}


// sample();
// board_test();
// board_edges();
// board_joints();


jointA(true);
jointB(true);
jointC(true);
