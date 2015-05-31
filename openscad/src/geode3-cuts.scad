// 3-geode parts for laser cutter

include <geode-shell.scad>;

degree = 3;

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
	echo("Edge A length", norm(a - b));
	edge2d(a, b);
}

module edgeB() {
	a = normalize((2 * points[0] + points[1]) / 3) * radius;
	b = normalize((points[0] + 2 * points[1]) / 3) * radius;
	echo("Edge B length", norm(a - b));
	edge2d(a, b);
}

module edgeC() {
	a = normalize((2 * points[0] + points[1]) / 3) * radius;
	b = normalize((points[0] + points[1] + points[2]) / 3) * radius;
	echo("Edge C length", norm(a - b));
	edge2d(a, b);
}

// Joints 


function joint_dir(p, n) = let(k = normalize(p), j = normalize(cross(k, n)), i = cross(j, k)) i;

module joint2d(p, neighbors) {
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
	}
}

module test_joint(p, neighbors) {
	k = normalize(p);
	j = normalize(cross(k, neighbors[0]));
	i = cross(j, k);
	t = k * radius;
	change_coord(i, j, k, t) linear_extrude(height = thickness) joint2d(p, neighbors);
	% for (n = neighbors) edge(p, n);
}

module joint(p, neighbors, test = false) {
	if (test)
		test_joint(p, neighbors);
	else
		joint2d(p, neighbors);
}


module jointA(test = false) {
	p = points[4];
	neighbors = [for(i = [3, 5, 11, 10, 8]) (2 * p + points[i]) / 3];
	joint(p, neighbors, test);
}

module jointB(test = false) {
	p = (2 * points[4] + points[8]) / 3;
	neighbors = [
		points[4] + 2 * points[8],
		points[4] + points[8] + points[3],
		2 * points[4] + points[3],
		3 * points[4],
		2 * points[4] + points[10],
		points[4] + points[10] + points[8]
	] / 3;
	joint(p, neighbors, test);
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



edgeA();
translate([0, width + 1]) edgeB();
translate([0, 2 * (width + 1)]) edgeC();
translate([-2*(delta + width) - 1, 3 * (width + 1) + delta + width]) jointA();
translate([0, 3 * (width + 1) + delta + width]) jointB();
translate([2*(delta + width) + 1, 3 * (width + 1) + delta + width]) jointC();

// jointA(true);
// jointB(true);
// jointC(true);

