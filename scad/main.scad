include <NopSCADlib/utils/core/core.scad>
include <NopSCADlib/utils/horiholes.scad>
include <NopSCADlib/vitamins/screws.scad>
include <NopSCADlib/vitamins/stepper_motors.scad>
include <NopSCADlib/vitamins/extrusions.scad>
include <lib/bead_chain_sprocket/bead_chain_sprockets.scad>

use <NopSCADlib/vitamins/ball_bearing.scad>
BB625_2RS =  ["625",  5,  16, 5, "orange", 1, 1];
//                                                  name,  link l,   ball r, teeth, link r
BEAD_CHAIN_3x1_5x25 = ["bead_chain_sprocket_3_1x1_5x25",        1.4,    3.1/2,    20,     .9];
BEAD_CHAIN_3x1_5x100= ["bead_chain_sprocket_3_1x1_5x100",       1.4,    3.1/2,   100,     .9];


SIZE = 200;
THICKNESS = 20;
BEARING = BB625_2RS;
MOTOR = NEMA17M;


module bearing_block(l = l) {
    d = bb_diameter(BEARING) * 2;
    th = THICKNESS;
    difference() {
        union() {
            cylinder(d = d, h = THICKNESS, center = true);
            translate([d / 3, 0, 0])
                cube([d / 2, 20, 20], center = true);
        }
        cylinder(d = bb_diameter(BEARING), h = THICKNESS * 2, center = true);
    }
    translate([l / 2 + bb_diameter(BEARING), 0, 0])
    difference() {
        cube([l, th, th], center = true);
        translate([l/2,0,th*cos(45)/4])
        rotate([0,45,0])
        cube([th*2,th*2,th], center = true);
    }

    difference() {
        translate([l + bb_diameter(BEARING) / 2 + 6 - th * cos(45) / 2, 0, 0])
            rotate([0, - 45, 0])
                cube([6, th * 3, th / cos(45) * 2], center = true);

        translate([l + bb_diameter(BEARING) / 2 + 6 - th * cos(45) / 2, 0, 0])
            rotate([0, -45, 0])
                translate_z(-th/2-6)
                cube([th * 4, th*4, 6], center = true);

        translate([l + bb_diameter(BEARING) / 2 + 6 - th * cos(45) / 2, 0, th]) {
            cube([th * 4, th * 4, th], center = true);
            translate_z(-th*2)
            cube([th * 4, th * 4, th], center = true);
        }

        translate([l + bb_diameter(BEARING) / 2 + 6 - th * cos(45) / 2, 0, 0]) {
            for(x = [-1,1])
            translate([0,x*th,0])
            rotate([0, - 45 + 90, 0])
            cylinder(d = 5.5, h = th, center = true);

            translate([5.5*cos(45),0,0])
            rotate([0, - 45, 0])
            translate_z(15)
            nut_trap(M5_cap_screw, M5_nut);
        }

    }
}

module holder_horizontal_stl() {
    stl("holder_horizontal");
    difference() {
        union() {
            bearing_block(l = SIZE);
            rounded_cube_xy([100, 17, 20], r = 3, xy_center = true, z_center = true);
        }
        cylinder(d = NEMA_shaft_dia(MOTOR), h = 100, center = true);


        translate_z(-5)
        rotate([90,0,0])
        horihole(r = 2, z = .2, h = 100);


        translate([-20,0,0])
        rotate([90,0,0])
            horihole(r = 5/2, z = .2, h = 100);
        translate([-40,0,0])
        rotate([90,0,0])
            horihole(r = 5/2, z = .2, h = 100);
    }

}
module holder_horizontal() {
    holder_horizontal_stl();
}

module holder_vertical_stl() {
    stl("holder_vertical");
    bearing_block(l = SIZE);
}
module holder_vertical() {
    bb_spacing = 8;

    translate_z(-bb_spacing)
    ball_bearing(BB625_2RS);
    translate_z(bb_spacing)
    ball_bearing(BB625_2RS);

    holder_vertical_stl();
}


module bead_chain_sprocket_x_axis() {
    render() {
        bead_chain_sprocket_x_axis_stl();
        vflip()
        bead_chain_sprocket_x_axis_stl();
    }
}
module bead_chain_sprocket_x_axis_stl() {
    stl("bead_chain_sprocket_x_axis");
    difference() {
        bead_chain_sprocket_half(BEAD_CHAIN_3x1_5x100);
        cylinder(r = screw_radius(M5_cap_screw), h = THICKNESS * 2, center = true);
    }
}

KNEE_WIDTH = 70;
module holder_sprocket_knee_place() {
translate([SIZE+26, 0, 15])
    rotate([0,0,0])
    rotate([90,0,0])
        children();
}
module holder_sprocket_knee_assembly() {

    // sprockets
    translate_z(-KNEE_WIDTH/2)
    bead_chain_sprocket_knee();

    translate_z(KNEE_WIDTH/2)
    bead_chain_sprocket_knee();

    color("gray")
    rotate([0,90,0])
    holder_sprocket_knee_stl();
}

module holder_sprocket_knee_stl() {
    stl("holder_sprocket_knee");
    LEN = KNEE_WIDTH-5;
    CYL_TRANS = [2,0,0];
    translate_z(2)
    rotate([0,90,0])
    difference() {
        union() {
            translate(CYL_TRANS)
            cylinder(d = 10, h = LEN, center = true);
            hull() {
                translate(CYL_TRANS)
                cylinder(d = 10, h = LEN-4, center = true);

                rounded_cube_xy([14,18,(LEN-5) / PI*2], r=3, xy_center = true, z_center = true);
            }
        }
        translate(CYL_TRANS)
        rotate([0,0,90])
            horihole(r = 5/2, z=.2, h =KNEE_WIDTH);

        rotate([0,90,0])
            cylinder(d = 5, h = KNEE_WIDTH*2, center = true);

        for(z = [-1,1])
        translate([0,0,z*LEN/4])
        cube([20,8.5,5], center = true);
    }

}

module bead_chain_sprocket_knee() {
    ball_bearing(BB625_2RS);
    bead_chain_sprocket_knee_stl();
    vflip()
    bead_chain_sprocket_knee_stl();
}

module bead_chain_sprocket_knee_stl() {
    stl("bead_chain_sprocket_knee");
    render()
    difference() {
        bead_chain_sprocket_half(BEAD_CHAIN_3x1_5x25);
        cylinder(d = bb_diameter(BEARING), h = THICKNESS * 2, center = true);
    }
}

module holder_assembly() {
    holder_horizontal();

    translate([SIZE+11,0,0])
    rotate([0,90,180])
    translate([-SIZE-11,0,0])
    holder_vertical();

    holder_sprocket_knee_place()
        holder_sprocket_knee_assembly();

    translate([SIZE+34,0,SIZE+11]) {
        rotate([0, 90, 0])
            bead_chain_sprocket_x_axis();

        // between bearings
        translate([-23.25,0,0])
            x_axis_spacer_stl();

        translate([-7.3,0,0])
            x_axis_spacer_stl();

        translate([-38.5,0,0]) {
            x_axis_spacer_stl();
            translate([-10,0,0])
            x_axis_hook_stl();
        }
    }

}

module x_axis_hook_stl() {
    stl("x_axis_hook");
    render()
    difference() {
        union() {
            rotate([0, 90, 0])
                cylinder(d = 10, h = 10, center = true);
            translate([0,0,-5])
                rounded_cube_yz([10,50,20], r = 3, xy_center = true, z_center=true);

            translate([-22.5,0,-11])
            rounded_cube_xy([55,50,8], r = 3, xy_center = true, z_center=true);

        }

        rotate([0,90,0])
        translate_z(-5) {
            nut_trap(screw = M5_cap_screw, nut = M5_nut, h=1);
            rotate([0,0,90])
                horihole(r = 5/2, z=.2, h = 20);
        }

        for(x = [-1,1])
            for(y = [-1,1])
                translate([x*11.5-32.5,y*20,0])
                    cylinder(d = 5, h = 200, center = true);
    }
}

module x_axis_spacer_stl() {
    stl("x_axis_spacer");
    rotate([0,90,0]) {
        difference() {
            cylinder(d = 10, h = 10, center = true);
            cylinder(d = 5, h = 20, center = true);
        }
    }
}
//holder_sprocket_knee_assembly();
//render()
//    bead_chain_sprocket_knee_stl();
//bead_chain_sprocket_x_axis_stl();
//bead_chain_sprocket_x_axis();

module case_sprocket_stl() {
    stl("case_sprocket");
    render()
        difference() {
            union() {
                bead_chain_sprocket_half(BEAD_CHAIN_3x1_5x25);
                cylinder(r = NEMA_big_hole(MOTOR)-.1, h = 2.5);
            }
            cylinder(d = bb_diameter(BEARING), h = THICKNESS * 2, center = true);
        }
}

CASE_W = 120;
CASE_H = 150;
CASE_D = 40;



module case_wall_side_stl() {
    stl("case_wall_side");
    translate([CASE_D/2-1,1,0])
    rounded_cube_xz([CASE_D, 2, CASE_H], r = 3, xy_center = true, z_center = true);

    for(z = [-1,1])
    translate([8,-10, z*(CASE_H/2-10)])
    difference() {
        rounded_cube_xz([13.5, 20, 20], r = 3, xy_center = true, z_center = true);
        rotate([0,90,0])
        horihole(r = 5/2, z=.2, h = 100, center = true);
    }
}

module case_wall_front_stl() {
    stl("case_wall_front");
    difference() {
        union() {
            translate([4,0,-40])
            rounded_cube_yz([8, CASE_W, CASE_H], r = 3, xy_center = true, z_center = true);
            rotate([0,-90,0])
            cylinder(r = bead_chain_sprocket_radius(BEAD_CHAIN_3x1_5x25), h = 3.5-bead_chain_sprocket_h(BEAD_CHAIN_3x1_5x25)/2);
            translate([-3.5,0,0])
            rotate([0,-90,0])
            bead_chain_sprocket_half(BEAD_CHAIN_3x1_5x25);
        }
        // screws
        translate_z(-40)
        for(y = [-1,1])
        for(z = [-1,1])
        translate([0,y*(CASE_W/2-10), z*(CASE_H/2-10)])
            rotate([0,90,0]) {
                cylinder(d = 5, h = 20, center = true);

                hull(){
                    cylinder(r = 10 / 2, h = .1, center = true);
                    translate_z(3)
                    cylinder(r = 5 / 2, h = .1, center = true);
                }
            }

        rotate([0,90,0])
        cylinder(r = NEMA_big_hole(MOTOR), h=10, center = true);

        rotate([0,90,0]) {
            NEMA_screw_positions(MOTOR){
                cylinder(r = 3 / 2, h = 10, center = true);
                hull(){
                    cylinder(r = 6 / 2, h = .1, center = true);
                    translate_z(2)
                    cylinder(r = 3 / 2, h = .1, center = true);
                }
            }

            translate_z(3)
            linear_extrude(10)
                scale([1.02,1.02,1])
                NEMA_outline(MOTOR);
        }
    }

}

module case_assembly() {
    case_wall_front_stl();

//    for(y = [-1,1])
//        translate([7,y*CASE_W/2, -40])
//            if(y > 0)
//                case_wall_side_stl();
//            else {
//                vflip()
//                case_wall_side_stl();
//            }

    color("gray")
    translate([-8,0,0])
    rotate([0,-90,0])
    vflip()
    case_sprocket_stl();

    translate([2,0,0])
    rotate([0,-90,0])
        NEMA(MOTOR);
}

module mc_rotacaster_assembly() {
    rotate([0,0,0])
    rotate([0, - 90, 0])
        holder_assembly();

    translate([24,0,0])
        case_assembly();


    translate([6,0,0]) {
        //vertical
        for (x = [- 1, 1])
        translate([45, x * 50, - 115])
            extrusion(E2020, 300);

        //horizontal
        for (x = [- 1, 1])
        translate([- 150 + 35, x * 160, - 115 - 150 + 10])
            rotate([0, 90, 0])
                extrusion(E2020, 300);

        translate([25, 0, - 115 - 150 + 10])
            rotate([90, 0, 0])
                extrusion(E2020, 300);
    }

}

mc_rotacaster_assembly();

//holder_sprocket_knee_stl();
//case_wall_front_stl();
//case_wall_side_stl();
//case_sprocket_stl();

//holder_vertical_stl();
//holder_horizontal_stl();


//x_axis_spacer_stl();
//x_axis_hook_stl();
