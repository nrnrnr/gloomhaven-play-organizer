include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

epsilon = 0.001;   // help avoid issues with floating-point rounding error

outer_diameter = 50;
wall_thickness = 1.8;
thread_wall_thickness = 2.4;  // thicker walls for threaded sections
inner_diameter = outer_diameter - 2 * wall_thickness;
thread_inner_diameter = outer_diameter - 2 * thread_wall_thickness;

cylinder_height = 67;
thread_height = 11;  // height of threaded section
thread_pitch = 3;   // distance between adjacent threads
thread_depth = 1.2; // depth of thread groove
thread_gap = 0.2;   // clearance between male and female threads

// Nut calculations (external component with outer_diameter)
nut_inner_thread_diameter = outer_diameter - 2 * thread_depth;
nut_bore_diameter = nut_inner_thread_diameter - 2 * thread_wall_thickness;

// Base calculations (this component's external threads)
base_external_thread_diameter = nut_inner_thread_diameter - thread_gap;
base_diameter = base_external_thread_diameter - 2 * thread_depth;


// Perforation parameters
hole_diameter = 2;
hole_spacing = 8;   // center-to-center distance between holes

module hollow_cylinder(height, outer_d, thickness) {
    difference() {
        cylinder(h = height, d = outer_d);
        translate([0, 0, -epsilon])
            cylinder(h = height + 2*epsilon, d = outer_d - 2*thickness);
    }
}

module main_cylinder() {
    // 1. Base (solid bottom)
    cylinder(h = wall_thickness + epsilon, d = base_diameter);
    
    // 2. External thread support section
    translate([0, 0, wall_thickness])
        hollow_cylinder(
            height = thread_height - wall_thickness + epsilon,
            outer_d = base_diameter,
            thickness = thread_wall_thickness
        );
    
    // 3. Main cylinder body
    translate([0, 0, thread_height])
        hollow_cylinder(
            height = cylinder_height - 2 * thread_height + epsilon,
            outer_d = outer_diameter,
            thickness = wall_thickness
        );
    
    // 4. Internal thread support section
//    translate([0, 0, cylinder_height - thread_height])
//        hollow_cylinder(
//            height = thread_height + epsilon,
//            outer_d = outer_diameter,
//            thickness = thread_wall_thickness
//
//        );
}

module perforate_cylinder() {
    // Calculate number of holes around circumference
    circumference = PI * (outer_diameter - wall_thickness);
    holes_around = floor(circumference / hole_spacing);
    
    // Calculate number of vertical rows
    vertical_rows = floor((cylinder_height - thread_height - wall_thickness) / hole_spacing);
    
    for (row = [1:vertical_rows]) {
        z_pos = wall_thickness + row * hole_spacing;
        
        for (i = [0:holes_around-1]) {
            angle = i * 360 / holes_around;
            // Offset alternate rows by half spacing for better coverage
            offset_angle = (row % 2 == 0) ? angle + (180 / holes_around) : angle;
            
            rotate([0, 0, offset_angle])
                translate([outer_diameter/2, 0, z_pos])
                rotate([0, 90, 0])
                cylinder(h = wall_thickness + epsilon, d = hole_diameter);
        }
    }
}

module internal_threads() {
    // Internal threads on open end (top) using BOSL2 threaded_nut - intersected with cylinder
    translate([0, 0, cylinder_height - thread_height - epsilon])
        intersection() {
            threaded_nut(nutwidth=outer_diameter + 10,  // oversized hex nut for intersection
                        id=thread_inner_diameter + 2*thread_depth,
                        h=thread_height + 2*epsilon,
                        pitch=thread_pitch,
                         blunt_start=false,
                         anchor=BOTTOM,
                        $fn=64);
            
            // Cylinder to limit the nut to our desired area
            cylinder(h=thread_height + 2*epsilon, 
                    d=outer_diameter+epsilon);
        }
}

module external_threads() {
    // External threads on closed end (bottom) using BOSL2 - hollowed to match base
    difference() {
        threaded_rod(d=base_external_thread_diameter, 
                    l=thread_height, 
                    pitch=thread_pitch, 
                    internal=false,
                    anchor=BOTTOM,
                    $fn=64);
        
        // Hollow out to match the cylinder it's mounted on
        translate([0, 0, -epsilon])
            cylinder(h=thread_height + 2*epsilon, 
                    d=base_diameter - 2*thread_wall_thickness);
    }
}

difference() {
    union() {
        main_cylinder();
        external_threads();
        internal_threads();
    }
}
