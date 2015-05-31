// 3-geode parts for laser cutter

include <geode-shell.scad>;

degree = 3;

// Parts needed for a complete geode :
// edgeA x  60
// edgeB x  90
// edgeC x 120
// Total   270 

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

edgeA();
translate([0, width + 1]) edgeB();
translate([0, 2 * (width + 1)]) edgeC();

