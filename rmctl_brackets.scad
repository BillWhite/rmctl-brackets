//
// Base Hook
//

include <BOSL2/std.scad>
include <BOSL2/screws.scad>
use <knurledFinishLib_v2.scad>
$slop=0.3;
$fn=100;

EPSILON=0.01;
module sector(oradius, iradius, from = 0, to = 360, fn) { 
    step_angle = (to - from)/fn;
    origin=[[0,0]];
    pts1 = [for (i = [from+90 : step_angle: to+90])
                      [oradius * cos(i), oradius * sin(i)]
                 ];
    pts2 = [for (i = [to+90 : -step_angle: from+90])
                      [iradius * cos(i), iradius * sin(i)]
                 ];
    pts = concat(origin, pts1, pts2, origin);
    polygon(pts);
}

module arc(oradius, iradius, width, fn) {
    wall_size = oradius-iradius;
    translate([0, 0, -(oradius - wall_size)]) {
        rotate([0, 90, 0]) {
            difference() {
                difference() {
                    cylinder(h=width, r=oradius);
                    translate([0, 0, -EPSILON]) {
                        cylinder(h=width+2*EPSILON, r=iradius);
                    }
                }
                translate([0, -oradius, -EPSILON])
                    cube([oradius, 2*oradius, width+2*EPSILON]);
                translate([-oradius, -oradius, -EPSILON])
                    cube([2*oradius, oradius, width+2*EPSILON]);
            }
        }
    }
}

fanW=58;
fanD=55;
fanH=15;
bedW=50;
bedD=55;
bedH=15;

wall_size=2;
oradius=17.5/2;
iradius=oradius-wall_size;
front_height=3*oradius;
bottom_width=25.0;
width=100;
depth=50;
fn=100;
nut_thickness=5;
nut_diameter=15;

clamp_screwcapH=4;
clamp_screwD=20;
clamp_screw_length=/*6*oradius*/2*oradius;
clamp_innerR=3;

// top and bottom with and height
hn_bottom_W = 22;
hn_bottom_H = 22;
// thickness, top to bottom
hn_thickness = 10;
hn_top_W = 15;
hn_top_H = 15;
// vertigal gap.
hn_vgap = (hn_bottom_H-hn_top_H)/2;
// horizontal gap.
hn_hgap = (hn_bottom_W-hn_top_W)/2;

hn_bottom_minX = 0;
hn_bottom_maxX = hn_bottom_W;
hn_bottom_minY = 0;
hn_bottom_maxY = hn_bottom_H;

hn_top_minX = hn_hgap;
hn_top_maxX = hn_hgap+hn_top_W;
hn_top_minY = hn_vgap;
hn_top_maxY = hn_vgap + hn_top_H;

hn_minZ=0;
hn_maxZ=hn_thickness;

CubePoints = [
  [  0,  0,  0 ],  //0
  [ 10,  0,  0 ],  //1
  [ 10,  7,  0 ],  //2
  [  0,  7,  0 ],  //3
  [  0,  0,  5 ],  //4
  [ 10,  0,  5 ],  //5
  [ 10,  7,  5 ],  //6
  [  0,  7,  5 ]]; //7    

CubeFaces = [
      [0,1,2,3],
      [4,5,1,0],
      [7,6,5,4],
      [5,6,2,1],
      [6,7,3,2],
      [7,4,0,3]
];


module base_hook() {
    union() {
        difference() {
            union() {
                // The top plate.
                cube([width, depth, 2]);
                // The curve from the top plate to the front side.
                translate([0, -oradius+wall_size, -oradius+wall_size])
                    rotate([90, 0, 0])
                        arc(oradius, iradius, width, fn);
                // The front side.
                translate([0, -oradius, -(iradius+front_height)]) {
                    cube([width, wall_size, front_height]);
                }
                // The curve from the front side to the bottom plate.
                translate([0, 0, wall_size-(oradius+front_height+oradius)+wall_size]) {
                    rotate([180, 0, 0])
                        arc(oradius, iradius, width, fn); 
                }
                // The bottom plate itself.
                translate([0, 0, -(front_height+iradius+oradius)]) {
                    cube([width, bottom_width, wall_size]);
                }
            }
            // Subtract off a hole for the nut.
            translate([width/2, bottom_width/2, -(front_height+oradius+iradius+EPSILON)]) {
                cylinder(h=wall_size+2*EPSILON, r=8);
            }
        }
        // Add a nut to the bottom, to clamp this onto the sill.
        translate([width/2, bottom_width/2, -(front_height+iradius+oradius-wall_size)]) {
            hexnut();
        }
    }
}

module clamp_screw_top() {
    difference() {
        union() {
            h0=0;
            translate([0,0,0])
                cylinder(r=2*clamp_outerR, h=wall_size);
            h1=h0+wall_size;
            translate([0,0,h1])
                cylinder(r=clamp_outerR, h=2*wall_size);
            h2=h1+2*wall_size;
            translate([0,0,h2])
                cylinder(r=clamp_innerR, h=clamp_innerH);
            h3 = h2+clamp_innerH;
            translate([0, 0, h3])
                cylinder(r=1.5*clamp_outerR, h=clamp_outerH);
        }
        translate([0, 0, -EPSILON])
            cylinder(h=(0.9*wall_size)+2*EPSILON, r=3.4);
    }
}

module clamp_screw() {
    union() {
        translate([0, 0, 0])
            knurl(k_cyl_od=clamp_screwD,
                  k_cyl_hg=clamp_screwcapH,
                  s_smooth=40);
        
        translate([0, 0, clamp_screwcapH])
            screw("M10", length = clamp_screw_length, tolerance="9e8e");
        
        translate([0, 0, clamp_screwcapH+clamp_screw_length])
            cylinder(h=wall_size, r=3.5);
        
    }
}

clamp_jawW=25.4;
clamp_jawD=clamp_jawW * 0.75;
clamp_jawH=25.4 * 0.5;

module clamp_jaw() {
    shell=[clamp_jawW, clamp_jawD, clamp_jawH];
    difference() {
        cube(shell, center=true);
        translate([0, 0, -(clamp_jawH/2 + wall_size/2+EPSILON)])
            cylinder(h=(clamp_jawH/2)+EPSILON, r=(1+EPSILON)*clamp_innerR);
    }
}


THREAD_EPSILON=0.1;

/*
module hexnut1() {
    pts=[
        [hn_bottom_minX, hn_bottom_minY, hn_minZ],
        [hn_bottom_maxX, hn_bottom_minY, hn_minZ],
        [hn_bottom_maxX, hn_bottom_maxY, hn_minZ],
        [hn_bottom_minX, hn_bottom_maxY, hn_minZ],
        [hn_top_minX, hn_top_minY, hn_maxZ],
        [hn_top_maxX, hn_top_minY, hn_maxZ],
        [hn_top_maxX, hn_top_maxY, hn_maxZ],
        [hn_top_minX, hn_top_maxY, hn_maxZ]
    ];
    union() {
        difference() {
            translate([hn_bottom_H/2, -hn_bottom_W/2, 0])
                rotate([0, 180, 0])
                    polyhedron(pts, CubeFaces, convexity=10);
            translate([0, 0, -(hn_thickness + EPSILON)]) {
                cylinder(h=hn_thickness+2*EPSILON, r=6); 
            }
        }
        translate([0, 0, -hn_thickness]) {
            metric_thread(diameter=10-THREAD_EPSILON,
                          pitch=2,
                          length=nut_thickness); 
        }
    }
}
*/

module hexnut() {
    pts=[
        [hn_bottom_minX, hn_bottom_minY, hn_minZ],
        [hn_bottom_maxX, hn_bottom_minY, hn_minZ],
        [hn_bottom_maxX, hn_bottom_maxY, hn_minZ],
        [hn_bottom_minX, hn_bottom_maxY, hn_minZ],
        [hn_top_minX, hn_top_minY, hn_maxZ],
        [hn_top_maxX, hn_top_minY, hn_maxZ],
        [hn_top_maxX, hn_top_maxY, hn_maxZ],
        [hn_top_minX, hn_top_maxY, hn_maxZ]
    ];
    union() {
        difference() {
            translate([hn_bottom_H/2, -hn_bottom_W/2, 0])
                rotate([0, 180, 0])
                    polyhedron(pts, CubeFaces, convexity=10);
            translate([0, 0, -(hn_thickness+1)]) {
                cylinder(h=hn_thickness+2, r=6);
            }
            translate([0, 0, -nut_thickness+EPSILON]) {
                nut("M8", diameter=13, thickness=nut_thickness);
            }
        }
    }
}

base_hook();

