#include <stdio.h>
#include <algorithm>
#include <limits>
#include "geom.hpp"
#include "num.hpp"
namespace gpumagi {

	struct AABB {
		Point max_pt;
		Point min_pt;
	};

	// bounding box (AABB) and all the primitives inside or intersecting it.
	struct BB { 
		AABB aabb;
		Triangle* primitives;
		int count; // # of primitives in this BB
	};

	// for given triangle, it will return the AABB
	inline AABB generate_AABB(Triangle t) {
		// t.o is point a
		Point b = t.o + t.u; // add point and vector to get the other points of the triangle
		Point c = t.o + t.v;
		Point max_pt = make_pt(std::max(t.o.x, b.x, c.x), std::max(t.o.y, b.y, c.y), std::max(t.o.z, b.z, c.z));
		Point min_pt = make_pt(std::min(t.o.x, b.x, c.x), std::min(t.o.y, b.y, c.y), std::min(t.o.z, b.z, c.z));
		return AABB{ max_pt, min_pt };
	}

	// true if 2 AABBs are intersecting
	inline bool intersect(AABB a, AABB b) {
		return (a.min_pt.x <= b.max_pt.x && a.max_pt.x >= b.min_pt.x) &&
			(a.min_pt.y <= b.max_pt.y && a.max_pt.y >= b.min_pt.y) &&
			(a.min_pt.z <= b.max_pt.z && a.max_pt.z >= b.min_pt.z);
	}


	// given the min pt and max pt of the entire scene (root node), divide the scene into div^3 cubes 
	//		and create empty bounding box for each.
	inline BB* generate_empty_BBs(int div, Point min, Point max) {
		
		// calculate each step to take in each axis
		f32 x_step = (max.x - min.x)/div;
		f32 y_step = (max.y - min.y)/div;
		f32 z_step = (max.z - min.z)/div;

		// total of div^3 bounding boxes. e.g. divide axis by 4 -> 64 cubes
		BB BBs[div*div*div];

		// index
		int i = 0;
		for (int z = 0; z < div; ++z) {
			for (int y = 0; y < div; ++y) {
				for (int x = 0; x < div; ++x) {
					Point min_pt = make_pt(min.x + x*x_step, min.y + y*y_step, min.z + z*z_step);
					Point max_pt = make_pt(min.x + (x+1)*x_step, min.y + (y+1)*y_step, min.z + (z+1)*z_step);
					BBs[i++] = BB{ AABB{min_pt, max_pt} , Triangle* p, 0 };
				}
			}
		}
		return BBs;
	}


	inline BB* VBH(Triangle* t_list) {
		int bb_div = 4;
		
		// total number of triangles in the given list
		int tri_num = sizeof(t_list) / sizeof(t_list[0])

		// generate array for triangle AABBs
		AABB tri_AABBs[sizeof(t_list) / sizeof(t_list[0])];

		// find each triangle's AABB to test intersection later
		for (int i = 0; i < tri_num; ++i) {
			tri_AABBs[i] = generate_AABB[t_list[i]];
		}

		f32 min_x, min_y, min_z = std::numeric_limits<T>::max();
		f32 max_x, max_y, max_z = std::numeric_limits<T>::min();
		for (int i = 0; i < tri_num; ++i) {
			// find min pt of the entire scene from tri_AABBs (minimum x,y,z of all tri_AABB's min_pt)
			if (tri_AABBs[i].min_pt.x < min_x)
				min_x = tri_AABBs[i].min_pt.x;
			if (tri_AABBs[i].min_pt.y < min_y)
				min_y = tri_AABBs[i].min_pt.y;
			if (tri_AABBs[i].min_pt.z < min_z)
				min_z = tri_AABBs[i].min_pt.z;

			// find max pt of the entire scene from tri_AABBs (maximum x,y,z of all tri_AABB's max_pt)
			if (tri_AABBs[i].max_pt.x > max_x)
				max_x = tri_AABBs[i].max_pt.x;
			if (tri_AABBs[i].max_pt.y > max_y)
				max_y = tri_AABBs[i].max_pt.y;
			if (tri_AABBs[i].max_pt.z > max_z)
				max_z = tri_AABBs[i].max_pt.z;
		}
		
		// make scene's min pt and max pt to create BBs
		Point min = make_pt(min_x, min_y, min_z);
		Point max = make_pt(max, x, max_y, max_z);

		// get all the cubes
		BB* BBs = generate_empty_BBs(bb_div, min, max);

		// build VBH
		for (int i = 0; i < bb_div * bb_div * bb_div; ++i) {
			for (int j = 0; j < tri_num; ++j) {
				if( intersect(BBs[i].aabb, tri_AABBs[j])

					// if the triangle's AABB intersects with BB's AABB, put the triangle
					//		in the BB as one of its primitive.
					BBs[i].primitives[BBs[i].count++] = t_list[j];
			}
		}
		return BBs;
	}



} //gpumagi