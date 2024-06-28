////////////////////////////////////////////////////////////////////////////////
//     _______________  _____________     _____________ ______________  _  __ //
//    / __/_  __/ __/ |/ / ___/  _/ /    / __/_  __/ _ /_  __/  _/ __ \/ |/ / //
//   _\ \  / / / _//    / /___/ // /__  _\ \  / / / __ |/ / _/ // /_/ /    /  //
//  /___/ /_/ /___/_/|_/\___/___/____/ /___/ /_/ /_/ |_/_/ /___/\____/_/|_/   //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//
// Stencil Station © 2024 by Sean Bradly is licensed under CC BY-NC-SA 4.0 
//
//   https://creativecommons.org/licenses/by-nc-sa/4.0/
//
//   BY: Credit must be given if redistributing or remixing.
//   NC: Only noncommercial use is permitted.
//   SA: Adaptations must be shared under these same terms. 
//
////////////////////////////////////////////////////////////////////////////////
//
// Stencil Station is a jig that makes stensils work like screen printing. It 
// uses magnets (or some other means) to provide a precise and repeatable base 
// from which to use one or many 3d printed stensils. It is entirely parametric,
// you can make the frame any size or aspect ratio or thickness you like. You 
// can also select any size or strength of magnet you wish. 
//
// A number of predefined stensils are provided and they're easy to create and
// quick to print if/when you need more.
//
// It can also accomodate multiple types of pens (like wide markers or needle-
// tip pencils. The track of the pen can be customized to your own gear to 
// ensure the final output looks like it is drawn with a plotter.
// 
// In this file are several primitives you'll want to take note of:
// 
//   * StencilBaseBlate: This goes behind the object you wish to draw on. It 
//     provides a hard backing for the pen to draw on and holds magnets to 
//     secure it to the top plate.
//
//   * StencilTopPlate: This is the frame that holds individual stencils. It
//     also contains magnets, but you can also use the tabs on the side as
//     something to clamp onto to anchor it (e.g. binder clips.)
//
//   * StencilBlank: This model the is where you put your custom stencil 
//     outlines. "make_stencil" is a very helpful macro here. Several out of 
//     the box examples are included:
//
//       * CartesianGraphStencil: This is just vertical lines, but if your 
//         frame is square, you can rotate the stencil 90 degrees and draw it 
//         again. This gives you a grid much like graph paper that you can draw 
//         reliably on any surface you wish. Great for math homework (and my 
//         original reason for developing this system.)
//       * PolarGraphCircleStencil and PolarGraphAngleStencil: These are simply
//         circles of various radii and lines at 30 and 45 degrees. The lines 
//         stencil can be rotated or flipped to build out any other multiple of
//         the common angles.
//       * CenterFinder: This bulls-eye looking pattern can be used to locate 
//         (or relocate) the stencil frame precisly. Just pop in the center 
//         finder, line it up using the center, vertical, and horizontal bars.
//         When you're done aligning, pop it out and pop in your stencil. No 
//         more wobbly lines or off-axis drawing errors.
//
//   * Other stuff: 
//
//       * Graphical Multi-part Stencils: These are maybe the coolest bit, but 
//         probably the hardest to customize. You can break apart some complex 
//         figures and recombine them into stencil form. It lets you get around 
//         the most common issues with single stencils like holes in letters or 
//         other "islands" that would otherwise be generated.
//
//       * parametric_function_grapher: This will create a stencil based on an 
//         arbitrary f(x) you pass in as a parameter. It automatically calulates
//         the proper mapping on to the stensil plate from the gx/gy "graphing
//         calculator" parameters in the customizer. So yeah, it basically works
//         just like a TI-83. Several demo graphs are included. Note: perf is
//         not great, esp near asymtotes. You might need to really crank up the
//         resolution and maybe increase the max objects parameters in OpenSCAD.
//
////////////////////////////////////////////////////////////////////////////////
//
// Version 1.0:
//   * Uploaded to MakerWorld
//   * Latest version can be found at https://github.com/rhythmx/stencil-station/
//   * Added a pen testing stencil and new pen types
//   * More graph types
//   * Code quality updates
//
// Version 0.5:
//   * Added a multi-part graphical stencil example
//   * Added two-side pen track mode for flippable plates
//   
// Version 0.4:
//   * Reworked tabs yet again. The top plate requires supports again for best 
//     results.
//   * Added a parametric graphing setup
//   * Added polar coordinate stencils
//   * Refactored to make different coordinate systems explicit to help avoid
//     opportunities for confusion.
//
// Version 0.3:
//   * Reworked alignment tabs and recesses to avoid need for supports. 
//   * Added some extra border area to prevent weakness.
//   * Refactored pen tracks, now are selectable
//
// Version 0.2:
//   * Added finger recesses to aid removal of the stencil plate
//   * Added support for variable sized magnets
//   * Added variable profiles for different pen types/sizes
//
// Version 0.1:
//   * Initial prototype
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// User Parameters
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// These define the outside border of any graphs drawn with the stensil set. It 
// also determines the size of any of the stencil plates that get generated. If 
// possible you should make it square, as that allows rotating the stencil image
// by 90 degrees for some very useful effects.

// Horizontal size of stencil
stencil_window_size_x = 50; // [20:180]
// Veritical size of stencil
stencil_window_size_y = 50; // [20:180]

// Used when generating stencil plates, leave this many mm of space on the edges
stencil_window_margin = 1;

////////////////////////////////////////////////////////////////////////////////
// Magnet parameters. Smaller magnets are ok for thin media like paper. As you
// try mounting to thicker things like cardboard, you'll want to use larger 
// magnets. Try to find a good balance between width and thickness, too thick 
// and the frame becomes harder to get a pen through.

// Thickness of the magnets
magnet_thickness = 2;

// Diameter of the magners
magnet_diameter = 6;


////////////////////////////////////////////////////////////////////////////////
// Stencil border is mostly cosmetic but making it too small will weaken it, 
// especially if it is scaled up to be large.

// Size of the frame border and related structures
stencil_base_border    = 4; //mm

////////////////////////////////////////////////////////////////////////////////
// Extra thickness could be added as a way to drop in Post-It notepads or 
// similar instead of being nearly flat for graphing on larger paper. Note that 
// this thickness must be large enough to accomodate the size of magnets you 
// have configured.

// Overall thickness of the frame
stencil_base_thickness = 2.36; //mm


////////////////////////////////////////////////////////////////////////////////
// "Graphing Calculator" parameters
//
// By default this window is slightly larger than -10,10 so that things graphed
// at x/y == 10 will show up and won't run off the border.


// Minimum plottable X coordinate
gx_min = -11;
// Maximum plottable X coordinate
gx_max = 11;
// Minimum plottable Y coordinate
gy_min = -11;
// Maximum plottable Y coordinate
gy_max = 11;


////////////////////////////////////////////////////////////////////////////////
// Misc parameters

// Global printing tolerance
tolerance = 0.12;
// Level of detail, helps cosmetics but may really impact performace
fn_number = 40;


////////////////////////////////////////////////////////////////////////////////
// Canned Plate Generators

// Pick an auto-generate option, or select "None" to generate your own below
generators = "Base"; // [None, Base, Graphing, Nyan, Parametrics, Misc]


// Selects the current pen type to differentiate between wide and thin pen types.
current_pen = 0; // [0:Normal7mmPen, 1:Default1, 2:Default2, 3:Default3, 4:Default4, 5:XFinePen, 6:XFinePencil]

// Hide the rest of the variables from customizer
module __Customizer_Limit__ () {} 


////////////////////////////////////////////////////////////////////////////////
// Custom pen tracks:
//
// |     |
// |     |
//  \   /
//   | | 
// 
// The shape defines the stensil plate cutout for a given pen type. The widest 
// point at the top is the "max width" and fits the entire tip of the pen. The
// in-sloping area does so at "angle". This is defined separately because to 
// help guide pens with large bevels. The min width is the width at the bottom
// of the figure and represents the narrowest part of the pen. The thickness 
// is the height of the last little bit at the bottom and should be as narrow 
// as possible to prevent the pen tip from being able to move in any other 
// direction.
// 
//       min    max    angle  thickness
//       width  width
pens = [
        [1.3   ,   2.4,   20,       0.8], // Normal (based on .7mm pen, works for fine point sharpie too.
        [1.25  ,   2.0,   21,       0.7],
        [1.2   ,   1.8,   22,       0.6],
        [1.15  ,   1.6,   24,       0.5],
        [1.1   ,   1.4,   26,       0.4],
        [1.05  ,   1.2,   28,       0.35],
        [1.0   ,   1.1,   30,       0.3]  // Extra fine (0.3mm pens)
       ];

// Some aliases for easy reference
Pen_Normal = 0;
Pen_XFine  = 6;

// Accessor functions to simulated structures because OpenSCAD is a woefully underpowered language
function pen_track_min_width(pen) = pens[pen][0];
function pen_track_max_width(pen) = pens[pen][1];
function pen_track_angle(pen) =     pens[pen][2];
function pen_track_thickness(pen) = pens[pen][3];


// Generate a polygon representing the profile of a pen tip
module PenTrackHalf(pen) {

    // angle calcs to determine height at which to stop the bevel
    theta = 90 - pen_track_angle(pen)/2;

    // Calc intersection of the track bevel and the maximum track width
    adj = (pen_track_max_width(pen) - pen_track_min_width(pen))/2;
    height_isect_track_max = adj/cos(theta);

    // Calc intersection of the track bevel with the top of the stencil plate
    opp = stencil_base_thickness-pen_track_thickness(pen);
    height_isect_top = opp/sin(theta);
    
    // Take whichever is lower
    bevel_top = min(height_isect_track_max, height_isect_top);
        
    // draw half the track profile
    polygon([
        [0,-tolerance], // origin
        [pen_track_min_width(pen)/2, -tolerance],
        [pen_track_min_width(pen)/2, pen_track_thickness(pen)],
        [pen_track_max_width(pen)/2, bevel_top+pen_track_thickness(pen)],
        [pen_track_max_width(pen)/2, stencil_base_thickness+tolerance],
        [0, stencil_base_thickness+tolerance]]
    );
}

module PenTrackHalf2Sided(pen) {
    translate([0,(stencil_base_thickness+tolerance)/2,0])
    union() {
        mirror([0,1,0])
            translate([0,-(stencil_base_thickness+tolerance)/2,0])
                    PenTrackHalf(pen);
        translate([0,-(stencil_base_thickness+tolerance)/2,0])
                PenTrackHalf(pen);
    }
}

// The full cross section of a pen tip
module PenTrack2d(pen) {
    PenTrackHalf(pen);
    mirror([1,0,0]) PenTrackHalf(pen);
}

// The full cross section of a pen tip
module PenTrack2d2Sided(pen) {
    PenTrackHalf2Sided(pen);
    mirror([1,0,0]) PenTrackHalf2Sided(pen);
}

// The 3d area of a pen tip
module PenTrack3d(pen) {
    rotate_extrude(angle=360,convexity=10,$fn=fn_number)
        PenTrackHalf(pen);
}

////////////////////////////////////////////////////////////////////////////////
// Helper / Library Routines

// Mirror that also clones and keeps the original target object
module mirror_copy(vec) {
   children();
   mirror(vec)
        children();
}

// Helper function that allows modelling one corner and then mirroring it 4 ways
module mirror_corners() {
    mirror_copy([1,0,0])
        mirror_copy([0,1,0])
            children();
}


////////////////////////////////////////////////////////////////////////////////
// Stencil Frames


// Alignment notches that go onto the stencil plate. Not to be confused with the
// mounting slots which are cutouts that go onto the stencil top plate.
module MountingTabs() {
    difference() {
        // X & Y Alignment guides. Triangular
        union() {
            translate([stencil_window_size_x/2,stencil_window_size_y/20,0])
            linear_extrude(stencil_base_thickness)
            polygon([
                [-tolerance,-stencil_base_border],
                [stencil_base_border/2,0],
                [-tolerance, stencil_base_border]
            ]);                
            translate([stencil_window_size_x/20,stencil_window_size_y/2,0])
            linear_extrude(stencil_base_thickness)
            polygon([
                [-stencil_base_border,-tolerance],
                [0,stencil_base_border/2],
                [stencil_base_border,-tolerance]
            ]);
        }
        // Cutouts provide a notch you can get your fingernails under to lift 
        // the stencil out of the frame
        union() {
            translate([stencil_window_size_x/2 + stencil_base_border/2,stencil_base_border*4,0])
                rotate([90,0,0])
                linear_extrude(stencil_base_border*4)
                polygon([
                    [0,0], 
                    [-stencil_base_thickness/2,stencil_base_thickness/2],
                    [0,stencil_base_thickness]
                ]);
            translate([0,stencil_window_size_y/2 + stencil_base_border/2,stencil_base_thickness])
                rotate([0,90,0])
                linear_extrude(stencil_base_border*4)
                polygon([
                    [0,0], 
                    [stencil_base_thickness/2,-stencil_base_thickness/2],
                    [stencil_base_thickness,0]
                ]);
        }
    }
}


// Mounting Slots
//
// Alignment cutouts that go onto the stencil top plate
module MountingSlots() {
    mirror_corners()
        union() {

            // New X Alignment guide
            translate([stencil_window_size_x/2,stencil_window_size_y/20,0])
            linear_extrude(stencil_base_thickness)
            polygon([
                [0,-stencil_base_border],
                [stencil_base_border/2,0],
                [0, stencil_base_border]
            ]);                
            // New Y Alignment guide
            translate([stencil_window_size_x/20,stencil_window_size_y/2,0])
            linear_extrude(stencil_base_thickness)
            polygon([
                [-stencil_base_border,0],
                [0,stencil_base_border/2],
                [stencil_base_border,0]
            ]);
            
            // New X Finger Recess
            translate([stencil_window_size_x/2,0,stencil_base_thickness])
                scale([1,1,stencil_base_thickness*(2/3)/stencil_base_border])
                    union() {
                        translate([0, stencil_window_size_y/6, 0])
                            sphere(stencil_base_border,$fn=fn_number);
                        rotate([90,0,0])
                            linear_extrude(stencil_window_size_y/6)
                                circle(stencil_base_border,$fn=fn_number);
                    }

            translate([0,stencil_window_size_y/2,stencil_base_thickness])
                scale([1,1,stencil_base_thickness*(2/3)/stencil_base_border])
                    union() {
                        translate([stencil_window_size_x/6, 0, 0])
                            sphere(stencil_base_border,$fn=fn_number);
                        rotate([0,90,0])
                            linear_extrude(stencil_window_size_x/6)
                                circle(stencil_base_border,$fn=fn_number);
                    }
        }
}

// Stencil Template
//
// Shared geometry between top plate and back plate
module StencilTemplate() {
    mirror_corners()
        union() {
            // cuboid for the main frame and border
            cube([
                stencil_window_size_x / 2 + stencil_base_border,
                stencil_window_size_y / 2 + stencil_base_border,
                stencil_base_thickness
            ]);
            
            exspace = 0;
            if(magnet_diameter / 2 > stencil_base_border) {
                exspace = (magnet_diameter / 2) - stencil_base_border + 1; 
            }
            
            // circle for corner strength and magnet holders
            translate([
                stencil_window_size_x/2 + stencil_base_border + exspace, 
                stencil_window_size_y/2 + stencil_base_border + exspace,
            0]) 
                linear_extrude(stencil_base_thickness) 
                    circle(stencil_base_border,$fn=fn_number);
            
            
            // Support for frame middle
            
            translate([stencil_window_size_x/2,0,0])
                union() {
                    translate([0,stencil_window_size_y/6,0])
                        linear_extrude(stencil_base_thickness)
                            circle(stencil_base_border*2,$fn=fn_number);
                    cube([stencil_base_border*2,stencil_window_size_y/6,stencil_base_thickness]);
                }

            translate([0,stencil_window_size_y/2,0])
                union() {
                    translate([stencil_window_size_x/6,0,0])
                        linear_extrude(stencil_base_thickness)
                            circle(stencil_base_border*2,$fn=fn_number);
                    cube([stencil_window_size_x/6,stencil_base_border*2,stencil_base_thickness]);
                }
        }
}


// Stencil Back Plate
//
// Mostly just the template with magnet holes on its top
module StencilBlackPlate() {
    difference() {
        StencilTemplate();
        
        exspace = 0;
        if(magnet_diameter / 2 > stencil_base_border) {
            exspace = (magnet_diameter / 2) - stencil_base_border + 1; 
        }
        
        // Add magnet mounting holes on top
        mirror_corners()
            translate([
                stencil_window_size_x/2 + stencil_base_border + exspace, 
                stencil_window_size_y/2 + stencil_base_border + exspace,
                stencil_base_thickness - magnet_thickness
            ]) 
                linear_extrude(magnet_thickness+tolerance) 
                    circle(magnet_diameter/2+tolerance,$fn=fn_number);
    }
}

// Stencil Top Plate
//
// The main stencil template with a cutout for the stencil plate and holes for the magnets on its bottom. Note that this part is modelled upside down for better printing with no overhangs.
module StencilTopPlate() {
    
    // Rotate and mirror to avoid overhangs when printing
    translate([0, 0, stencil_base_thickness])
    rotate([180,0,0])
    mirror([1,0,0])
    
    // Main geometry
    difference() {
        StencilTemplate();

        // Main cutout for stencil area
        mirror_corners()
            translate([0,0,-tolerance])
            cube([
                stencil_window_size_x / 2,
                stencil_window_size_y / 2,
                stencil_base_thickness+tolerance*2
            ]);

        exspace = 0;
        if(magnet_diameter / 2 > stencil_base_border) {
            exspace = (magnet_diameter / 2) - stencil_base_border + 1; 
        }
        
        // Add magnet mounting holes on bottom
        mirror_corners()
            translate([
                stencil_window_size_x/2 + stencil_base_border + exspace, 
                stencil_window_size_y/2 + stencil_base_border + exspace,
                0
            ]) 
                linear_extrude(magnet_thickness+tolerance) 
                    circle(magnet_diameter/2+tolerance,$fn=fn_number);
        
        // Clear out mounting slots that pair with the stencil plate
        MountingSlots();
    }
}
// Cube that represents anythign that can be cutout of a stencil. Useful for 
// sums and union operations
module StencilDrawableArea() {
    mirror_corners() 
        cube([
            stencil_window_size_x / 2-stencil_window_margin*2,
            stencil_window_size_y / 2-stencil_window_margin*2,
            stencil_base_thickness
        ]);    
}

// Stencil Plate Blank
//
// A stencil plate with no stencil cutouts. Used by any other modules 
module StencilBlank() {
    mirror_corners()
        union() { 
            difference() {
                cube([
                    stencil_window_size_x / 2-tolerance,
                    stencil_window_size_y / 2-tolerance,
                    stencil_base_thickness
                ]);
                StencilDrawableArea();
            }
        MountingTabs();
    }
}

// Macro that sets up a blank stencil and a difference operation for you 
module make_stencil() {
    union() {
        difference() {
            StencilDrawableArea();
            children();
        }
        StencilBlank();
    }
}

////////////////////////////////////////////////////////////////////////////////
// Coordinate Systems
//
function coord_map(in, in_min, in_max, out_min, out_max) = 
    (in - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;

// Virtual (T) coordinates: anything on the drawable stencil plate can be 
//     represented by x/y from -1 to 1
vx_min = -1;
vx_max = 1;
vy_min = -1;
vy_max = 1;
vx_window = 2;
vy_window = 2;

// SX / SY coordinate system: Maps the virtual coordinates ([-1,1]) to the 
//     actual SCAD X/Y coordinates for the drawable space on the stencil plate
sx_min = -stencil_window_size_x/2 + stencil_window_margin;
sx_max = stencil_window_size_x/2 - stencil_window_margin;
sy_min = -stencil_window_size_y/2 + stencil_window_margin;
sy_max = stencil_window_size_y/2 - stencil_window_margin;
sx_window = sx_max - sx_min;
sy_window = sy_max - sy_min;
function sx(x) = coord_map(x, sx_min, sx_max, vx_min, vx_max);
function sy(y) = coord_map(y, sy_min, sy_max, vy_min, vy_max);

// GX / GY coordinate system: Maps the graphing-calculator style x/y min/max 
//     parameters onto the virtual ([-1,1]) coordinate space.
gx_window = gx_max-gx_min;
gy_window = gy_max-gy_min;
function gx(x) = coord_map(x, gx_min, gx_max, vx_min, vx_max);
function gy(y) = coord_map(y, gy_min, gy_max, vy_min, vy_max);

// Map T coords onto G
function vgx(tx) = coord_map(tx, vx_min, vx_max, gx_min, gx_max);
function vgy(ty) = coord_map(ty, vy_min, vy_max, gy_min, gy_max);


// Map T coords onto S
function vsx(tx) = coord_map(tx, vx_min, vx_max, sx_min, sx_max);
function vsy(ty) = coord_map(ty, vy_min, vy_max, sy_min, sy_max);

// Map G coors onto S
function gsx(gx) = coord_map(gx, gx_min, gx_max, sx_min, sx_max);
function gsy(gy) = coord_map(gy, gy_min, gy_max, sy_min, sy_max);


// Iterate from in V-coord space from [-1,1], with N steps, while 
// graphing provided function (V => V) with given pen
module parametric_function_graph(pen, func, steps) {   
    for(t=[-1 : (1/steps) : 1+(1/steps)]) {

        v_last = func(t-(1/steps));
        v = func(t);
                
        // let the range overflow a little but don't waste time if it is way far off
        if( v[0] < 1.9 && v[0] > -1.9 &&
            v[1] < 1.9 && v[1] > -1.9) {

            dx = vsx(v_last[0] - v[0]);
            dy = vsy(v_last[1] - v[1]);
            theta = atan(dx/dy);
            dist = sqrt(dx^2 + dy^2);
                        
            sv = [vsx(v[0]),vsy(v[1]),0];
                
            # translate(sv)
                rotate([90,0,180-theta]) {
                    linear_extrude(dist)
                        PenTrack2d(pen);
                    rotate([-90,0,0]) rotate_extrude(angle=360,$fn=10)
                        PenTrackHalf(pen);                        
                }
        }
    }    
}

////////////////////////////////////////////////////////////////////////////////
// Alignment stencil
//
// Not really used for drawing itself, but for precision alignment of the 
// stencil plate. Once aligned all other stencils will be using the same 
// coordinate system.
module AlignmentStencil() {
    union() {
        StencilBlank();

        intersection() {
            StencilDrawableArea();

            difference() {
                union() {
                    translate([-1.5,sy_max,0])
                        rotate([90,0,0])
                            linear_extrude(sx_max*2)
                                circle(1,$fn=fn_number);    
                    translate([1.5,sy_max,0])
                        rotate([90,0,0])
                            linear_extrude(sx_max*2)
                                circle(1,$fn=fn_number);    

                    translate([-sx_max,-1.5,0])
                        rotate([90,0,90])
                            linear_extrude(sx_max*2)
                                circle(1,$fn=fn_number);    
                    translate([-sx_max,1.5,0])
                        rotate([90,0,90])
                            linear_extrude(sx_max*2)
                                circle(1,$fn=fn_number);    
                }
            
                rotate([0,0,90])
                    linear_extrude(stencil_base_thickness)
                        circle(1.5, $fn=fn_number);
            
            }
        }
    }
}


////////////////////////////////////////////////////////////////////////////////
// Cartesian and Polar Graphing Stencils
//
module cartesian_graph_bar(pen) {
    translate([0,sy_max,0])
        rotate([90,0,0])
            linear_extrude(sx_max*2)
                PenTrack2d(pen);
}

module CartesianGraphStencil(pen) {
    make_stencil() {
        for(x=[-10 : 2 : 10])
            translate([gsx(x),0,0])
                cartesian_graph_bar(pen);
    }
}

module circle_stencil_helper(pen,r) {
    rotate_extrude(angle=310,$fn=fn_number*2)
        translate([r,0,0])
            PenTrack2d(pen);
                rotate([0,0,-5])
                    children();
}

module PolarGraphCircleStencil(pen) {
    make_stencil() {
        rotate([0,0,-45])
        //circle_stencil_helper(pen,gsx(14))
        circle_stencil_helper(pen,gsx(13))
        //circle_stencil_helper(pen,gsx(12))
        //circle_stencil_helper(pen,gsx(11))
        circle_stencil_helper(pen,gsx(10))
        //circle_stencil_helper(pen,gsx(9))
        //circle_stencil_helper(pen,gsx(8))
        circle_stencil_helper(pen,gsx(7))
        //circle_stencil_helper(pen,gsx(6))
        circle_stencil_helper(pen,gsx(5))
        //circle_stencil_helper(pen,gsx(4))
        circle_stencil_helper(pen,gsx(3))
        //circle_stencil_helper(pen,gsx(2))
        circle_stencil_helper(pen,gsx(1));
    }
}

module polar_graph_bar(pen,theta) {
    translate([gsx(cos(theta)),gsy(sin(theta)),0]) // offset by radius of 1
        rotate([0,0,theta]) // rotate ray to given angle
            rotate([90,0,90]) // align pen track with X-axis
                linear_extrude(gsx(10)) // max diag dist
                    PenTrack2d2Sided(pen);  
}

// Plate with 15/30/45 degree angles which can also generate 60/75 degree angles 
// and in any quadrant if the stencil is flipped and rotated. The lines end at 
// r=1 because the origin would become too busy otherwise. 
module PolarGraphAngleStencil(pen) {
    make_stencil() {
         polar_graph_bar(pen,45);  // 45
         polar_graph_bar(pen,105); // 90 + 15
         polar_graph_bar(pen,300); // 270 + 30
    }
}

////////////////////////////////////////////////////////////////////////////////
// Graphing calculator demos

// Graph of y=(x/3)^3 -2x
module y3_demo_graph(pen) {
    myfn = function(t) [t,gy(vgx(t/3)^3-2*vgx(t)),0];
    make_stencil() {
        parametric_function_graph(pen, myfn, 150); 
    }
}

// 2-part Graph of circle with radius x_window-5. Note the bad performance at horizontal asymtotes
module circle_graph_demo(pen) {
    circ_top = function(t) [t, gy(sqrt( (gx_window/2-1)^2 - vgx(t)^2)), 0]; 
    circ_bot = function(t) [t, gy(-sqrt( (gx_window/2-1)^2 - vgx(t)^2)), 0]; 
    make_stencil() {
        parametric_function_graph(pen, circ_top, 20); 
        parametric_function_graph(pen, circ_bot, 20); 
    }
}


// Example parabola plate
module parabola_plate_demo(pen) {
    para0 = function(t) [t, gy(vgx(t)^2*10 + 2), 0];
    para1 = function(t) [t, gy(vgx(t)^2), 0];
    para2 = function(t) [t, gy(vgx(t)^2/10-2), 0];
    para3 = function(t) [t, gy(vgx(t)^2/50-4), 0];
    para4 = function(t) [t, gy(vgx(t)^2/100-6), 0];
    para5 = function(t) [t, gy(vgx(t)^2/500-8), 0];
    make_stencil() {
        steps = 100; // this gets slow quick! You might have to generate in peices or OpenSCAD will bail that or you need to raise the number of rendering elements. render times are long
        parametric_function_graph(pen, para0, steps);
        parametric_function_graph(pen, para1, steps);
        parametric_function_graph(pen, para2, steps);
        parametric_function_graph(pen, para3, steps);
        parametric_function_graph(pen, para4, steps);
        parametric_function_graph(pen, para5, steps);
    }
}

module intersection_graph_demo(pen) {
    fn1 = function(t) [t, gy( vgx(t)^3/4 + vgx(t)^2/10 -4*vgx(t) ), 0];
    fn2 = function(t) [t, gy( vgx(t)^2/10 ), 0];
    make_stencil() {
        steps = 50;
        parametric_function_graph(pen, fn1, steps);
    }
    translate([stencil_window_size_x+magnet_diameter*2+stencil_base_border*2+3,0,0])
    make_stencil() {
        steps = 50;
        parametric_function_graph(pen, fn2, steps);
    }
}


////////////////////////////////////////////////////////////////////////////////
// Graphical Multi-Part Stencils 
//
// The process to generate these stencils can be rather involved. I used 
// Inkscape for this example. Step one is to obtain/create a vector image form 
// of whatever you wish to stencilize. Next, make each part of the image into 
// thier own paths/objects. Then make judicious use of the "difference" 
// operation to get rid of any overlaps and make proper cutouts. 
//
// Using layers and groups can really help organize it all. Once you have each
// cutout, make a few layers named "Stencil 1" (then 2, 3, etc) and put the 
// cutouts into as many difference stencils as is needed. 
//
// After you have the stencils layed out. Union everything and use the "offset"
// path effect to add a tiny bit of extra border to each. This allows for the 
// diameter of the pen you wish to use. Ex, I used 0.35mm offsets for 0.7mm 
// pens.
//
// The result isn't really automatable. You need to match up the Inkscape and 
// OpenSCAD dimensions before hand. If you try to scale things in OpenSCAD 
// after then things like the pen offset will get distorted.

module load_svg_stencil() {
    make_stencil() {
      //  #difference() {
       
               // children() should be an 'import' 
            translate([-24,-24,0])
                linear_extrude(height=stencil_base_thickness+tolerance)
                    children();
        
                    // clip off all but 1mm of thickness
            translate([0,0,1+stencil_base_thickness/2]) 
                cube([stencil_window_size_x, stencil_window_size_y,stencil_base_thickness],center=true);
       //}
    }
}

module NyanStencil() {
    translate([60,60,0])
        load_svg_stencil()
            import("img/nyan - stencil 1.svg",$fn=fn_number, $fa=fn_number);
    translate([0,60,0])
        load_svg_stencil()
            import("img/nyan - stencil 2.svg",$fn=fn_number, $fa=fn_number);
    translate([60,0,0])
        load_svg_stencil()
            import("img/nyan - stencil 3.svg",$fn=fn_number, $fa=fn_number);
    translate([0,0,0])
        load_svg_stencil()
            import("img/nyan - stencil 4.svg",$fn=fn_number, $fa=fn_number);
}


////////////////////////////////////////////////////////////////////////////////
// Other Demos

module RainbowStencil(pen) {
    make_stencil() {
        for(r=[10:-1:4])
        rotate_extrude(angle=180,$fn=fn_number*2)
            translate([gsx(r),0,0])
                PenTrack2d(pen);
    }
}

module PenTrackTester() {
   make_stencil() {
        for(r=[Pen_Normal:1:Pen_XFine]) {
            pennum = Pen_XFine - r; 
            rotate_extrude(angle=180,$fn=fn_number*2)
                translate([gsx(r^1.2),0,0])
                    PenTrack2d(pennum);  
        }  
         for(r=[Pen_Normal:1:Pen_XFine]) {
            pennum = Pen_XFine - r; 
                translate([gsx(gx_min),gsy(-r^1.2)-2,0])
                    rotate([90,0,90])
                    linear_extrude(gsx(gx_window))
                    PenTrack2d(pennum);  
        }     
   }
}

////////////////////////////////////////////////////////////////////////////////
// Outputs
// 
// Nothing up until this point should generate any objects. After this point you
// can select which objects to render for export.

// Space out the models so they don't overlap
x_spacing = stencil_window_size_x+magnet_diameter*2+stencil_base_border*2+3;
y_spacing = stencil_window_size_y+magnet_diameter*2+stencil_base_border*2+3;

if(generators == "Base") {
  translate([x_spacing*0, y_spacing*0, 0]) 
  StencilBlackPlate();

  translate([x_spacing*1, y_spacing*0, 0]) 
  StencilTopPlate();
    

}

if(generators == "Graphing") {
  translate([x_spacing*0, y_spacing*0, 0]) 
  CartesianGraphStencil(current_pen); // current_pen);

  translate([x_spacing*1, y_spacing*0, 0]) 
  PolarGraphCircleStencil(current_pen);

  translate([x_spacing*0, y_spacing*1, 0]) 
  PolarGraphAngleStencil(current_pen); 

  translate([x_spacing*1, y_spacing*1, 0]) 
  AlignmentStencil();

}

if(generators == "Nyan") {
    NyanStencil();
}

if(generators == "Parametrics") {
    translate([y_spacing*0, y_spacing*1, 0]) 
    y3_demo_graph(current_pen);
    
    translate([y_spacing*1, y_spacing*1, 0]) 
    circle_graph_demo(current_pen);

    translate([y_spacing*0, y_spacing*0, 0]) 
    parabola_plate_demo(current_pen); 

    * translate([y_spacing*1, y_spacing*0, 0]) 
    intersection_graph_demo(current_pen);
}

if(generators == "Misc") {
  translate([x_spacing*0, y_spacing*0, 0]) 
  RainbowStencil(current_pen);
    
  translate([x_spacing*1, y_spacing*0, 0]) 
  PenTrackTester();
}

echo("Due to zero-width face artifacts in preview mode, you may have to do a render to see the actual geometry.");