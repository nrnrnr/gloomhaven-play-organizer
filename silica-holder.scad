include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

epsilon = 0.001;   // help avoid issues with floating-point rounding error

outer_diameter = 50;    // fits inside a standard reel
cylinder_height = 67;   // width of a standard reel

wall_thickness = 1.8;   // sufficient for structural integrity

thread_depth = 1.2;     // depth of thread groove --- a bit of a guess
thread_height = 11;  // height of threaded section
thread_pitch = 3;   // distance between adjacent threads
thread_wall_thickness = 2.4;  // thicker walls for threaded sections,
                              // ensures structural integrity of those sections
thread_gap = 0.2;   // clearance between male and female threads (guess)

cylinder_inner_diameter = outer_diameter - 2 * wall_thickness;


max_bridge_length = 8.5;  // measured from existing perforations
rib_width = 2;            // ditto



// THREAD DIAMETER CALCULATIONS
// Structural parameters: outer_diameter and thread_wall_thickness
// All thread diameters calculated to ensure proper mating

// Female cap threads - primary calculation from structural parameters
// Outer diameter ensures female cap threaded cylinder = outer_diameter
female_cap_thread_outer_diameter = outer_diameter - 2 * thread_wall_thickness;
female_cap_thread_inner_diameter = female_cap_thread_outer_diameter - 2 * thread_depth;

// Main cylinder external threads (bottom) - sized to mate with female cap
// Must be thread_gap smaller than female cap threads for clearance
cylinder_external_thread_outer_diameter = female_cap_thread_outer_diameter - thread_gap;
cylinder_external_thread_inner_diameter = cylinder_external_thread_outer_diameter - 2 * thread_depth;

// Main cylinder base (solid bottom) - diameter inside the external threads
base_diameter = cylinder_external_thread_inner_diameter;

// Main cylinder internal threads (top opening) - matches female cap threads
cylinder_internal_thread_outer_diameter = female_cap_thread_outer_diameter;
cylinder_internal_thread_inner_diameter = 
    cylinder_internal_thread_outer_diameter - 2 * thread_depth;


module hollow_cylinder(height, outer_d, thickness) {
    difference() {
        cylinder(h = height, d = outer_d);
        translate([0, 0, -epsilon])
            cylinder(h = height + 2*epsilon, d = outer_d - 2*thickness);
    }
}

module rounded_cube_xy(size, radius) {
    // Handle both single value and vector size like cube()
    dims = is_list(size) ? size : [size, size, size];
    x = dims[0];
    y = dims[1];
    z = dims[2];
    
    union() {
        // Main body (reduced by radius on x and y)
        translate([radius, radius, 0])
            cube([x - 2*radius, y - 2*radius, z]);
        
        // Four corner cylinders
        translate([radius, radius, 0])
            cylinder(h = z, r = radius);
        translate([x - radius, radius, 0])
            cylinder(h = z, r = radius);
        translate([radius, y - radius, 0])
            cylinder(h = z, r = radius);
        translate([x - radius, y - radius, 0])
            cylinder(h = z, r = radius);
        
        // Side rectangles to connect corners
        translate([0, radius, 0])
            cube([x, y - 2*radius, z]);
        translate([radius, 0, 0])
            cube([x - 2*radius, y, z]);
    }
}

module perforated_cylinder(height, outer_d, thickness) {
    // Calculate number of ribs
    circumference = PI * outer_d;
    num_ribs = ceil(circumference / (max_bridge_length + rib_width));
    
    union() {
        // Stack of hollow cylinders (1mm high, 2mm spacing)
        for (z = [0 : 2 : height - 1]) {
            if (z + 1 <= height) {
                translate([0, 0, z])
                    hollow_cylinder(
                        height = min(1, height - z), 
                        outer_d = outer_d, 
                        thickness = thickness
                    );
            }
        }
        
        // Vertical ribs for reinforcement
        for (i = [0 : num_ribs - 1]) {
            angle = i * 360 / num_ribs;
            rotate([0, 0, angle])
                translate([outer_d/2 - thickness, -rib_width/2, 0])
                    cube([thickness, rib_width, height]);
        }
    }
}

module perforated_base(d, id, h=wall_thickness+epsilon) {
  diameter = d;
  perforation_diameter = id;
    union() {
        // 1. Outer hollow cylinder
        hollow_cylinder(height = h, 
                       outer_d = diameter, 
                       thickness = (diameter - perforation_diameter) / 2);
        
        // 2. Concentric cylinders spaced 2mm apart (circumference to circumference)
        core_radius = 7.5 / 2;
        perforation_radius = perforation_diameter / 2;
        
        // Calculate radii for concentric cylinders
        for (r = [core_radius + 2 + 1.2 : 2 + 1.2 : perforation_radius + 1.2]) {
            hollow_cylinder(height = h, 
                           outer_d = 2 * (r + 0.6), 
                           thickness = 1.2);
        }
        
        // 3. Solid core cylinder (7.5mm diameter)
        cylinder(h = h, d = 7.5);
        
        // 4. Four radial ribs spaced at equal intervals
        for (angle = [0, 90, 180, 270]) {
            rotate([0, 0, angle])
                translate([-1.2, 0, 0])  // 2.4mm wide tangentially, centered on radius
                cube([2.4, perforation_radius, h]);
        }
    }
}



extra_bottom_support = 5;

module main_cylinder() {
    // 1. Base (solid bottom)
   perforated_base(h = wall_thickness + epsilon, d = base_diameter - thread_depth,
                   id = cylinder_external_thread_inner_diameter -
                          2 * thread_wall_thickness - 2);

    
    // 2. External thread support section
    translate([0, 0, thread_height - epsilon])
        hollow_cylinder(
            height = extra_bottom_support, 
            outer_d = outer_diameter, //cylinder_external_thread_outer_diameter,
            thickness = thread_wall_thickness + outer_diameter - 
                        cylinder_external_thread_outer_diameter
        );
    
    // 3. Main cylinder body
    translate([0, 0, thread_height])
        perforated_cylinder(
            height = cylinder_height - 2 * thread_height + epsilon,
            outer_d = outer_diameter,
            thickness = wall_thickness
        );
    
}

// Parameters for perforating cylinder walls
hole_diameter = 2;
hole_spacing = 8;   // center-to-center distance between holes


module perforate_cylinder() {
    // Calculate number of holes around circumference
    circumference = PI * (outer_diameter - wall_thickness);
    holes_around = floor(circumference / hole_spacing);
    
    // Calculate number of vertical rows
    vertical_rows = floor(
        (cylinder_height - thread_height - wall_thickness) / hole_spacing
    );
    
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
    // Internal threads on open end (top) using BOSL2 threaded_nut - 
    // intersected with cylinder
    translate([0, 0, cylinder_height - thread_height - epsilon])
        intersection() {
            threaded_nut(
                nutwidth=outer_diameter + 10,  // oversized hex nut for intersection
                        id=cylinder_internal_thread_outer_diameter,
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
    // threaded_rod expects outer diameter
    difference() {
        threaded_rod(d=cylinder_external_thread_outer_diameter, 
                    l=thread_height + epsilon, 
                    pitch=thread_pitch, 
                    internal=false,
                    anchor=BOTTOM,
                    $fn=64);
        
        // Hollow out to match the cylinder it's mounted on
        translate([0, 0, -epsilon])
            cylinder(h=thread_height + 3*epsilon, 
                    d=base_diameter - 2*thread_wall_thickness);
    }
}

////////////////////////////////////////////

male_cap_base_diameter = 66;

// Male cap thread diameter calculation:
// The cylinder's internal threads have ID = 
// cylinder_internal_thread_inner_diameter + 2*thread_depth
// For proper mating, the male cap's external threads should be slightly smaller
// Male thread diameter = internal thread ID - thread_gap for clearance
male_cap_thread_diameter = 
    cylinder_internal_thread_inner_diameter + 2*thread_depth - thread_gap;

module male_cap() {
    union() {
        // Solid base
//        cylinder(h = wall_thickness, d = male_cap_base_diameter);
        perforated_base(male_cap_base_diameter,
                        cylinder_external_thread_inner_diameter - 2 * thread_wall_thickness - 2);
        
        // Hollow male threads extending upward from base
        // threaded_rod expects outer diameter
        translate([0, 0, wall_thickness])
            difference() {
                threaded_rod(d = male_cap_thread_diameter,
                           l = thread_height,
                           pitch = thread_pitch,
                           internal = false,
                           anchor = BOTTOM,
                           $fn = 64);
                
                // Hollow out with standard thread wall thickness
                translate([0, 0, -epsilon])
                    cylinder(h = thread_height + 2*epsilon,
                           d = male_cap_thread_diameter - 2*thread_wall_thickness);
            }
    }
}

// Female cap base diameter (structural)
female_cap_base_diameter = 66;

module maybe_shift_y(gate, distance) {
  if (gate < 0) {
    translate([0, distance, 0])
      children();
  } else {
    children();
  }
}

module female_cap() {
    tab_width = 19;     // tangential width
    tab_extension = 6;  // radial extension beyond base
    
    union() {
        // Hollow base - completely open from threads inward
        hollow_cylinder(
            height = wall_thickness,
            outer_d = female_cap_base_diameter,
            thickness = (female_cap_base_diameter - 
                        female_cap_thread_outer_diameter - 
                        2*thread_wall_thickness) / 2
        );
        
        // Four tabs at compass directions with rounded corners
        for (angle = [0, 90, 180, 270]) {
            fudge = 0.4; // gets circles close to tangent with base
            rotate([0, 0, angle]) {
                translate([female_cap_base_diameter/2 - 6, -tab_width/2, 0])
                    rounded_cube_xy(
                        [tab_extension + 6, tab_width, wall_thickness], 
                        radius = 2.5
                    );
                
                // Inside corner rounding where tab meets circular base
                for (side = [-1, 1]) {
                    translate([
                        female_cap_base_diameter/2 - 2.5, 
                        side * (tab_width/2), 
                        0
                    ]) {
                        difference() {
//color([0, 0, 1, 1])
                            maybe_shift_y(side, -2.5/2)
                            cube([2.5, 2.5 / 2, wall_thickness]);
//color([1, 1, 0, 1])
                            translate([
                                2.5 + 2.5 * (tab_width/2) / 
                                (female_cap_base_diameter/2) - fudge, 
                                side * 2.5, 
                                -epsilon
                            ])
                                cylinder(h = wall_thickness + 2*epsilon, r = 2.5);
                        }
                    }
                }
            }
        }
        
        // Internal threads using threaded_nut
        translate([0, 0, wall_thickness])
            intersection() {
                threaded_nut(
                    nutwidth = female_cap_thread_outer_diameter + 
                               2*thread_wall_thickness + 10,
                           id = female_cap_thread_outer_diameter,
                           h = thread_height,
                           pitch = thread_pitch,
                           blunt_start = false,
                           anchor = BOTTOM,
                           $fn = 64);
                
                // Cylinder to limit the nut to our desired area
                cylinder(
                    h = thread_height,
                    d = female_cap_thread_outer_diameter + 
                        2*thread_wall_thickness + epsilon
                );
            }
    }
}


module central_cylinder() {
  difference() {
      union() {
          main_cylinder();
  //color([0,0,1,0.5])
          external_threads();
          internal_threads();
      }
  }
}

//translate([80,0,0])
//  male_cap();
//
//translate([-80,0,0])
//  female_cap();

central_cylinder();

translate([0,0,-15])
% female_cap();




