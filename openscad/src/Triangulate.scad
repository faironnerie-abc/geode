phi = (1+sqrt(5))/2;

/** Dessine trois sphères sur les points d'un triangle */
module points(pts) {
	translate(pts[0]) { sphere(0.02); }
	translate(pts[1]) { sphere(0.02); }
	translate(pts[2]) { sphere(0.02); } 	
}

/** Point médian. */
function midpoint(p0, p1) = p0 + ((p1 - p0) / 2);

/** Projette un point sur la sphère centrée en (0,0,0) le long du rayon. */
function onsphere(v, r) = (v / norm(v)) * r;

/** Dessine un triangle si `depth` == 0, sinon subdivise le triangle en 4,
  * récursivement jusqu'à `depth` == 0. */
module triangle(pts, depth, r) {
	if(depth == 0) {
		//points(pts);
		polyhedron(pts, faces = [ [ 0, 1, 2 ] ]);
	} else {
		mpts = [
			onsphere(midpoint(pts[0], pts[1]), r),
			onsphere(midpoint(pts[1], pts[2]), r),
			onsphere(midpoint(pts[2], pts[0]), r)
		];
		
		triangle([pts[0], mpts[0], mpts[2] ], depth-1, r);
		triangle([mpts[0], pts[1], mpts[1] ], depth-1, r);
		triangle([mpts[0], mpts[1], mpts[2] ], depth-1, r);
		triangle([mpts[2], mpts[1], pts[2] ], depth-1, r);
	}
}
