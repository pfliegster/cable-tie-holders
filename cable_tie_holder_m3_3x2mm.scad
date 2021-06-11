///////////////////////////////////////////////////////////////////////////////////////
//
// File: cable_tie_holder_m3_3x2mm.scad
//
// Description:
//      A simple screw-down cable-tie holder to assist with cable management. Screw
//      hole is designed for M3 flat-head (countersunk) screw type and two cable-tie
//      attachment openings will work with Nylon zip ties up to 3 mm wide x 2 mm
//      thick, or other attachment mechanism(s) of choice that will work with this
//      size opening.
//
//      For uses where considerable load or stress will be applied to the holder,
//      consider printing this item with a strong material such as Nylon, ABS, or
//      possibly PETG.
//
// Author:  Keith Pflieger
// github:  pfliegster (https://github.com/pfliegster)
// License: CC BY-NC-SA 4.0
//          (Creative Commons: Attribution-NonCommercial-ShareAlike)
//
///////////////////////////////////////////////////////////////////////////////////////

// These variables define whether or not to display other objects in preview window
// for visualization. Be sure to turn these off (to `false`) before exporting STL for
// printing:
display_zip_tie = false;
display_screw   = false;

// Dimensional variables for models:
opening_width   = 3.2; // slightly oversize for 3 mm wide zip tie
opening_height  = 2.2; // slightly oversize for 2 mm thick zip tie

// Characteristics of the screw hole, based on type/dimensions of screw:
screw_type        = "flat"; // default = "flat"; can also be "round" or "cylinder"
screw_length      = 10;
screw_head_diam   = 6.0;
// Some Socket Head screw types (cylinder) have 3.2 mm head height, otherwise 2.0 mm is good:
screw_head_height         = (screw_type == "cylinder") ? 3.2 : 2.0;
// Oversize a few extra dimensions for screws other than flat-head:
screw_head_hole           = (screw_type == "flat") ? screw_head_diam : screw_head_diam + 0.3;
min_thickness_unser_screw = (screw_type == "flat") ? 0.5 : 1.0;

holder_base_length = screw_head_hole   + 0.7;
holder_base_width  = screw_head_hole   + 0.5;
holder_base_height = screw_head_height + min_thickness_unser_screw;

// Extra solid model dimensions defining the segments that the cable tie(s) go through:
tie_mount_length    = 2;
tie_mount_thickness = 1;
zip_tie_height = holder_base_height + opening_height/2;

// Used for rounding outside edges of holder using `minkowski()`:
rounding_radius = 1;

///////////////////////////////////////////////////////////////////////////////////////
// 
// If you are including and/or referencing the `cable_tie_holder_m3_3x2mm` module from
// a different OpenSCAD design project, please set the $include_cth3mm special variable
// to `true` or `false` (it just needs to be defined) before the actual include reference
// like this:
//
//      $include_cth3mm = false;
//      include <...path.../cable-tie-holder/cable_tie_holder_m3_3x2mm.scad>
// 
///////////////////////////////////////////////////////////////////////////////////////
if ($include_cth3mm == undef) {
    color("slategray") render()
        cable_tie_holder_m3_3x2mm(screw_type = screw_type);
    
    if (display_screw) {
        screw_z_offest = (screw_type == "flat") ?
            holder_base_height - screw_length :
            holder_base_height - screw_length - screw_head_height - 0.1;

        color("dimgray") render() translate([0, 0, screw_z_offest]) {
            generic_screw_model(  screw_diam = 3.0, screw_type = screw_type,
                            head_diam = screw_head_diam, head_height = screw_head_height,
                            length = screw_length, $fn=80     );
        }
    }
    if (display_zip_tie) {
        color("dimgray") translate([0, 0, zip_tie_height]) {
            simple_zip_tie();
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////
//
//  cable_tie_holder_m3_3x2mm
//
//  Parameters:
//      screw_type: can be "round" (panel or button heads), "cylinder" (socket head) or 
//                  "flat" (e.g. 90 deg. inset/flush-mount screws).
//
///////////////////////////////////////////////////////////////////////////////////////
module cable_tie_holder_m3_3x2mm(screw_type = "flat") {

    // First, check parameter(s) for errors:
    assert(((screw_type == "round") || (screw_type == "cylinder") || (screw_type == "flat")),
        "Unsupported screw_type for cable tie holder! Please check spelling.");

    shape_length = holder_base_length + 2*tie_mount_length;
    shape_width  = holder_base_width;
    shape_height = holder_base_height + opening_height + tie_mount_thickness;
    
    echo("Cable tie holder dimensions:");
    echo("  Length = ", shape_length + 2*rounding_radius, " mm");
    echo("  Width  = ", shape_width + 2*rounding_radius, " mm");
    echo("  Height = ", shape_height + rounding_radius, " mm");

    difference() {
        // Create Initial shape, rounded using minkowski():
        translate([0, 0, shape_height/2]) {
            minkowski() {
                cube([shape_length, shape_width, shape_height], center = true);
                sphere(rounding_radius, $fn=100);
            }
        }
        // First make flat cut in bottom of rounded shape:
        translate([0, 0, -shape_height/2]) {
            cube([shape_length + 4*rounding_radius, shape_width + 4*rounding_radius,
                    shape_height], center = true);
        }
        // Cut out notch above screw hole:
        translate([0, 0, holder_base_height + shape_height/2]) {
            cube([holder_base_length, shape_width + 4*rounding_radius,
                    shape_height], center = true);
        }
        // Create screw hole in shape:
        screw_cutout_type = (screw_type == "flat") ? "flat" : "cylinder";
        screw_cutout_z_offest = (screw_type == "flat") ?
            holder_base_height - screw_length :
            holder_base_height - screw_length - screw_head_height;
        
        translate([0, 0, screw_cutout_z_offest]) {
            generic_screw_model(  screw_diam = 3.4,
                        screw_type = screw_cutout_type,
                        head_diam = screw_head_hole + 0.1,
                        head_height = screw_head_height + 0.1,
                        length = screw_length, $fn=80     );
        }
        // Finally, remove sections for zip tie or other attachment object to fit through:
        translate([0, 0, zip_tie_height]) {
            cube([20, opening_width, opening_height], center = true);
        }
        
    }
}

module simple_zip_tie() {
    tie_length = 50;
    tie_width = 2.5;
    tie_height = 1.2;
    latch_length = 4.6;
    latch_width = 4.6;
    latch_height = 3.4;
    
    translate([0, 0, 0]) {
        difference() {
            cube([tie_length, tie_width, tie_height], center = true);
            translate([6 + tie_length/2, tie_width/2, 0]) rotate([0,0,45]) {
                cube([10, 10, 5], center = true);
            }
            translate([6 + tie_length/2, -tie_width/2, 0]) rotate([0,0,45]) {
                cube([10, 10, 5], center = true);
            }
        }
    }
    translate([-(tie_length + latch_length)/2, 0, (tie_height - latch_height)/2]) {
        cube([latch_length, latch_width, latch_height], center = true);
    }
}

///////////////////////////////////////////////////////////////////////////////////////
//
//  Generic Screw Model
//
//  Parameters:
//      screw_diam: Screw Diameter (e.g. set to 3.0 for M3 screw);
//      screw_type: This can be "round" (panel or button heads), "cylinder" 
//                  (socket head) or "flat" (e.g. 90 deg. flush-mount) screws.
//      head_diam:  Widest diameter of head or 'flange' (the top of a "flat" head or
//                  the bottom of "rounded" head types (panel, button, etc.), per convention.
//      head_height: The height of rounded heads, or the inset depth of the flat head type.
//      length:     Length of screw, from the bottom of the screw to either the
//                  a) bottom of "round" and "cylinder" head types, or
//                  b) top of "flat" head screws
//
///////////////////////////////////////////////////////////////////////////////////////
module generic_screw_model(screw_diam = 3.0, screw_type = "round", head_diam = 6,
                    head_height = 1.9, length = 8) {
    // First, some error checking on parameters:
    assert(screw_diam > 0);
    assert(head_diam > 0);
    assert(head_height > 0);
    assert(length > 0);
    assert(((screw_type == "round") || (screw_type == "cylinder") ||
            (screw_type == "flat")),
            "Unsupported screw_type! Please check spelling.");
    
    // Now let's create the screw shaft itself:
    translate([0, 0, length/2])
        cylinder(h = length, d = screw_diam, center = true);
    // Next, create the screw head:
    if (screw_type == "round") {
        translate([0, 0, length]) {
            scale([1, 1, 2*head_height/head_diam]) {
                difference() {
                    sphere(d = head_diam, $fn = 100);
                    translate([0, 0, -head_diam/2]) cube(head_diam, center = true);
                }
            }
        }
    } else if (screw_type == "cylinder") {
        translate([0, 0, length + head_height/2])
            cylinder(h = head_height, d = head_diam, center = true);
    } else if (screw_type == "flat") {
        translate([0, 0, length - head_height/2])
            cylinder(h = head_height, d1 = screw_diam, d2 = head_diam, center = true);
    }
}

