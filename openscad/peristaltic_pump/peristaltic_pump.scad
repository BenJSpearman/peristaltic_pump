// Nema Mounted Parametric Peristaltic Pump (customizable)
// by Ben Spearman 2024
//
//
// Modified version of:
// Planetary peristaltic pump (customizable)
// by Drmn4ea (drmn4ea at google's mail)
// https://www.thingiverse.com/thing:454702
//
// Adapted from Emmett Lalish's Planetary Gear Bearing at
// http://www.thingiverse.com/thing:53451
//
// Released under the Creative Commons - Attribution - Share Alike license
// (http://creativecommons.org/licenses/by-sa/3.0/)


// -------- Render and output options --------

// Output option. Options are: pump, plate, crank. Case sensitive.
output = "plate";

// --------  Printer-related settings ------------

// Clearance to generate between the gears within the pump. If the gears print 'stuck together' or are difficult to separate, try increasing this value. If there is excessive play between them, try lowering it. (default: 0.15mm)
gear_tolerance = 0.19;

// Allowed overhang for overhang removal, between 0 and 0.999 (0 = none, 0.5 = 45 degrees, 1 = infinite)
allowed_overhang = 0.75;


// --------  Details of the stepper motor used, in mm -------------

// width of motor shaft
shaft_size = 5.5;

// The spacing between the mounting holes on the stepper motor. Measure from the center of the holes.
bolt_spacing = 31;

// The space between the mounting plate and the pump gears.
mount_spacing = 2.5;

// How thick the mounting plate should be.
plate_thickness = 2.5;

// Mount inner diameter. The hole that will be in the center of the mounting plate.
mount_id = 22;

// The size of the mounting holes. Standard Nema 17 is an M3 (3mm).
thread_size = 3;

// -------------------- Connector settings ---------------------------------
// The thread size for the connector bolts you want, in mm (i.e. M3 is 3.0)
connect_bolt_size = 3.0;

// The lenght of the connector bolts, in mm (i.e M3x10 is 10.0)
connect_bolt_height = 10.0;

// Number of connectors you want.
num_connectors = 2;


// --------  Details of the tubing used in the pump, in mm ------------

// Outer diameter of your tubing in mm TO DO: make this separate from hole diam
tubing_od = 3;

// Extra mm to add to the exit holes for the tubing. Suggested is 0.3mm
tubing_exit_tolerance=0.3;

// Wall thickness of your tubing
tubing_wall_thickness = 1.6;

// Amount the tubing should be compressed by the rollers, as a proportion of total thickness (0 = no squish, 1.0 = complete squish)
tubing_squish_ratio = 0.4;


// --------  Part geometry settings ------------

// Diameter of the pump. Minimum of 60mm.
diam = 60;

// Thickness i.e. height in mm
thick = 15;

// Number of planet gears
number_of_planets = 3;

// Number of teeth on planet gears
number_of_teeth_on_planets = 7;

// Number of teeth on sun gear (approximate)
approximate_number_of_teeth_on_sun = 9;

// pressure angle
press_ang = 45;//[30:60]

// number of teeth to twist across
n_twist = 1;




// ----------------Calculated values -----------------
	// TODO: Rename variables to be more useful/legible.

dr = 0.5*1;// maximum depth ratio of teeth
m = round(number_of_planets);
num_p_teeth = round(number_of_teeth_on_planets);
ns1 = approximate_number_of_teeth_on_sun;
k1 = round(2 / m * (ns1 + num_p_teeth));
k =  k1 * m % 2 != 0 ? k1 + 1 : k1;
ns = k * m / 2 - num_p_teeth;
echo(ns=ns);
nr = ns + 2 * num_p_teeth;
pitchD = 0.9 * diam / (1 + min(PI / ( 2 * nr * tan(press_ang)), PI * dr / nr));
pitch = pitchD * PI / nr;
echo(pitch=pitch);
helix_angle = atan(2 * n_twist * pitch / thick);
echo(helix_angle=helix_angle);

phi = $t * 360 / m;

// compute some parameters related to the tubing
tubing_squished_width = tubing_od * (PI / 2);
tubing_depth_clearance = 2 * (tubing_wall_thickness * (1 - tubing_squish_ratio));

// actual pump diameter after adding tubing_depth_clearance
pump_rad = diam / 2;


// temporary variables for computing the outer radius of the outer ring gear teeth
// used to make the clearance for the peristaltic squeezer feature on the planets
outerring_pitch_radius = nr * pitch / (2 * PI);
outerring_depth = pitch / (2 * tan(press_ang));
outerring_outer_radius = gear_tolerance < 0 ? outerring_pitch_radius + outerring_depth / 2 - gear_tolerance : outerring_pitch_radius + outerring_depth / 2;

// temporary variables for computing the outer radius of the planet gear teeth
// used to make the peristaltic squeezer feature on the planets
planet_pitch_radius = num_p_teeth * pitch / (2 * PI);
planet_depth = pitch / (2 * tan(press_ang));
planet_outer_radius = gear_tolerance < 0 ? planet_pitch_radius + planet_depth / 2 - gear_tolerance : planet_pitch_radius + planet_depth / 2;

// temporary variables for computing the inside & outside radius of the sun gear teeth
// used to make clearance for planet squeezers
sun_pitch_radius = ns * pitch / (2 * PI);
sun_base_radius = sun_pitch_radius * cos(press_ang);
echo(sun_base_radius=sun_base_radius);
sun_depth = pitch / (2 * tan(press_ang));
sun_outer_radius = gear_tolerance < 0 ? sun_pitch_radius + sun_depth / 2 - gear_tolerance : sun_pitch_radius + sun_depth / 2;
sun_root_radius1 = sun_pitch_radius - sun_depth / 2 - gear_tolerance / 2;
sun_root_radius = (gear_tolerance < 0 && sun_root_radius1 < sun_base_radius) ? sun_base_radius : sun_root_radius1;
sun_min_radius = max (sun_base_radius, sun_root_radius);


min_connector_od = 7;
// Connectors have a minimum outer diameter to ensure printability.
connector_od = (connect_bolt_size + 2) < min_connector_od ? min_connector_od : connect_bolt_size + 2;
connector_dist_from_pump = connector_od/1.9;


// ========================= MAIN  ===============================================================================

/* Run with true to see mounting plate and pump stacked on top of each other
	for ease of designing.*/ 
if (output == "pump"){
	pump();
} else if (output == "plate"){
	mounting_plate();
} else if (output == "crank"){
	hand_crank();
}

//pump_and_mount(false);
//test_motor_shaft_mount();

// ==============================================================================================================
// +++++++++++++++++++++ MODULES +++++++++++++++++++++

/* The pump and mount, positioned either ready for printing, or stacked to
	help during design.
*/
module pump_and_mount(stacked=false){
	pump();
	if(stacked){
		// Floating underneath
		translate([0,  0,  -(plate_thickness+mount_spacing)]){
				mounting_plate();
		}
	} else {
		// To the side
		translate([(diam + (connector_od*3)),  0,  0]){
				mounting_plate();
		}
	}
}

/*
The whole pump, sitting at 0, 0, 0.
*/
module pump(){
	translate([0, 0, thick / 2]){
		outer_ring();
		sun_gear();
		planet_gears();
	}
}

/* 
Full mounting plate object to attach to both the pump and the motor.
Includes the mount_spacing amount of space between the pump and mount for
clearance.
*/
module mounting_plate(){
	union(){
		difference(){
			cylinder(h=plate_thickness, r=pump_rad, $fn=100);
			cylinder(h=plate_thickness + 1, r=(mount_id/3)*2);
			for(hole_num = [0 : 1 : 4]){
				rotate([0, 0, (hole_num * 90)]){
					translate([bolt_spacing/2, bolt_spacing/2, 0]){
						cylinder(h=plate_thickness+1, d=thread_size, $fn=10);
					}
				}
			}
		}
		all_connectors(true);
	}
}

module hand_crank(){
	union(){
		// the gear with band cut out of the middle
		difference(){
			cylinder(h=thick, r=15, center=true);
			// center hole
			motor_shaft();
		}
		translate([0, 0, 5]){
			gear(number_of_teeth=15, circular_pitch=10, pressure_angle=60, depth_ratio=0.5, clearance=0, helix_angle=0, gear_thickness=10, flat=false);
		}
	}
}

/* 
The outer ring of the pump. Has some hacky code done by previous devs,
and needs cleaning up.
*/
module outer_ring(){
	union(){
		difference(){
			cylinder(r=pump_rad, h=thick, center=true, $fn=100);
			exitholes(len=100);
				
			union(){
				// HACK: On my printer, it seems to need extra clearance for the outside gear, trying double...
				herringbone(nr,pitch, press_ang, dr, -2 * gear_tolerance, helix_angle, thick + 0.2);
				cylinder(r=outerring_outer_radius + tubing_depth_clearance, h=tubing_squished_width, center=true, $fn=100);
				// overhang removal for top teeth of outer ring: create a frustum starting at the top surface of the "roller" cylinder 
				// (which will actually be cut out of the outer ring) and shrinking inward at the allowed overhang angle until it reaches the
				// gear root diameter.
				translate([0, 0, tubing_squished_width / 2]){
					cylinder(r1=outerring_outer_radius + tubing_depth_clearance, r2=outerring_depth, h=abs(outerring_outer_radius + tubing_depth_clearance - outerring_depth) / tan(allowed_overhang * 90), center=false, $fn=100);
				}
			}
		}
		translate([0, 0, -(thick/2)]){
			all_connectors();
		}
	}
}

/*
The sun gear (middle gear) for the pump.
*/
module sun_gear(){
    rotate([0, 0, (num_p_teeth + 1) * 180 / ns + phi * (ns + num_p_teeth) * 2 / ns])
	
	difference(){
		// the gear with band cut out of the middle
		difference(){
			mirror([0, 1, 0]){
				herringbone(ns, pitch, press_ang, dr, gear_tolerance, helix_angle, thick);
			}
			// center hole
			motor_shaft();
			// gap for planet squeezer surface
			difference(){
				cylinder(r=sun_outer_radius, h=tubing_squished_width, center=true, $fn=100);
				cylinder(r=sun_min_radius - gear_tolerance, h=tubing_squished_width, center=true, $fn=100);
			}
		}
		// on the top part, cut an angle on the underside of the gear teeth to keep the overhang to a feasible amount
		translate([0, 0, tubing_squished_width / 2]){
			difference(){
				// in height, numeric constant sets the amount of allowed overhang after trim.
				//h=abs((sun_min_radius-gear_tolerance)-sun_outer_radius)*(1-allowed_overhang)
				// h=tan(allowed_overhang*90)
				cylinder(r=sun_outer_radius, h=abs((sun_min_radius - gear_tolerance) - sun_outer_radius) / tan(allowed_overhang * 90), center=false, $fn=100);
				cylinder(r1=sun_min_radius - gear_tolerance, r2=sun_outer_radius, h=abs((sun_min_radius - gear_tolerance) - sun_outer_radius) / tan(allowed_overhang * 90), center=false, $fn=100);
			}
		}
	}
}

/*
All planet gears (outer gears) based on number_of_planets.
*/
module planet_gears(){
    for(i=[1:m]){
		rotate([0, 0, i * 360 / m + phi]){
			translate([pitchD / 2 * (ns + num_p_teeth) / nr, 0, 0]){
				rotate([0, 0, i * ns / m * 360 / num_p_teeth - phi * (ns + num_p_teeth) / num_p_teeth - phi]){
					union(){
						herringbone(num_p_teeth, pitch, press_ang, dr, gear_tolerance, helix_angle, thick);
						// Add a roller cylinder in the center of the planet gears.
						// But also constrain overhangs to a sane level, so this is kind of a mess...
						intersection(){
							// the cylinder itself
							cylinder(r=planet_outer_radius, h=tubing_squished_width - gear_tolerance, center=true, $fn=100);

							// Now deal with overhang on the underside of the planets' roller cylinders.
							planet_overhangfix(pitch, press_ang, dr, gear_tolerance, helix_angle, thick, tubing_squished_width, allowed_overhang);
						}
					}
				}
			}
		}
	}
}

/*
Deals with the overhang on the underside of the planets' roller cylinders by doing the following:
 - Create the outline of a gear where the herringbone meets the cylinder;
 - Make its angle match the twist at this point.
 - Then difference this flat gear from a slightly larger cylinder, extrude it with an
	outward-growing angle, and cut the result from the cylinder.
*/
module planet_overhangfix(circular_pitch=10, 	pressure_angle=28, depth_ratio=1, clearance=0,
											 helix_angle=0, gear_thickness=5, tubing_squished_width, allowed_overhang){

	height_from_bottom =  (gear_thickness / 2) - (tubing_squished_width / 2);
	pitch_radius = num_p_teeth*circular_pitch / (2  *PI);
												 
	// The total rotation angle at that point - should match that of the gear itself
	twist=tan(helix_angle) * height_from_bottom / pitch_radius * 180 / PI; 

	// Relative to center height, where this is used
	translate([0,0, -tubing_squished_width/2]) {
		// FIXME: This calculation is most likely wrong...
		//rotate([0, 0, helix_angle * ((tubing_squished_width-(2*gear_tolerance))/2)])
		rotate([0, 0, twist]){
			// want to extrude to a height proportional to the distance between the root of the gear teeth
			// and the outer edge of the cylinder
			linear_extrude(height=tubing_squished_width - clearance, twist=0, slices=6, scale=1 + (1 / (1 - allowed_overhang))){
				gear2D(num_p_teeth, circular_pitch, pressure_angle, depth_ratio, clearance);
			}
		}
	}
}

/*
Makes the tubing exit holes through the outerring of the pump.
*/
module exitholes(){
	// HACK: Add tubing depth clearance value to the total OD, otherwise the outer part may be too thin.
	// FIXME: This is a quick n dirty way and makes the actual OD not match what the user entered...
	distance_apart = outerring_outer_radius;
	exit_hole_size = tubing_od+tubing_exit_tolerance;

	translate([distance_apart, len/2, 0]){
		rotate([90, 0, 0]){
			cylinder(d=exit_hole_size, h=len, center=true, $fn=100);
		}
	}
	mirror([1,0,0]){
		translate([distance_apart, len/2, 0]){
			rotate([90, 0, 0]){
				cylinder(d=tubing_od, h=len, center=true, $fn=100);
			}
		}
	}
}


module test_motor_shaft_mount(){
	difference(){
		cylinder(d=(shaft_size*2), h=thick, center=true);
		motor_shaft();
	}
}

/* An object the size of the stepper motors' motor shaft. Used for creating
	the mounting hole in the center of the pump. Is not influenced by gear_tolerance
	parameter.
*/
module motor_shaft(){
    difference(){
        cylinder(d=shaft_size, h=thick + 1,center=true, $fn=100);
        translate([0, (shaft_size/2), 0]){
			cube([(shaft_size), (thick/10), thick + (thick / 10)], center=true);
		}
    }
}


/*  Creates all num_connectors number of connectors for either the pump or plate.
	Needs to be called once for the pump, and once for the plate.
	
	Args:
		is_plate: Whether the connectors are attaching to the mounting plate or not.
*/
module all_connectors(is_plate=false){
	union(){
		increment = 360 / num_connectors;
		for(count = [0 : num_connectors]){
			rotate([0,  0, count*increment]){
				translate([pump_rad +connector_dist_from_pump,  0,  0]){
					connector(is_plate);
				}
			}
		}
	}
}


/*  Creates an individual connector. Changes it's height and attachment size 
	depending on if the connector is for the pump or mounting plate.
	
	Args:
		is_plate: Whether the connector is attaching to the mounting plate or not.
*/
module connector(is_plate=false){
	if (is_plate) {
		difference(){
			union(){
				cylinder(h=plate_thickness + mount_spacing, d=connector_od, $fn=80);
				translate([-connector_od/1.5,  -connector_od/2,  0]){
					cube([connector_od/1.5, connector_od, plate_thickness]);
				}
			}
			cylinder(h=plate_thickness + mount_spacing, d=connect_bolt_size, $fn=30);
		}
	} else {
		difference(){
			cylinder(h=connect_bolt_height - 2, d=connector_od, $fn=80);
			cylinder(h=connect_bolt_height - 2, d=connect_bolt_size, $fn=80);
		}
		difference(){
			union(){
				cylinder(h=connect_bolt_height - 2, d=connector_od, $fn=80);
				translate([-connector_od/1.5,  -connector_od/2,  0]){
					cube([connector_od/1.5, connector_od, connect_bolt_height - 2]);
				}
			}
			cylinder(h=connect_bolt_height - 2, d=connect_bolt_size, $fn=30);
		}
	}
}


module herringbone(number_of_teeth=15, circular_pitch=10, pressure_angle=28, depth_ratio=1,
								clearance=0, helix_angle=0, gear_thickness=5){
	union(){
		//translate([0,0,10])
		gear(number_of_teeth, circular_pitch, pressure_angle, depth_ratio, clearance, helix_angle, gear_thickness/2);
		mirror([0,0,1]){
			gear(number_of_teeth, circular_pitch, pressure_angle, depth_ratio, clearance, helix_angle, gear_thickness/2);
		}
	}
}

/*
Creates a single gear.
*/
module gear(number_of_teeth=15, circular_pitch=10, pressure_angle=28, depth_ratio=1,
						clearance=0, helix_angle=0, gear_thickness=5, flat=false){

	pitch_radius = number_of_teeth * circular_pitch / (2 * PI);
	twist=tan(helix_angle) * gear_thickness / pitch_radius * 180 / PI;

	flat_extrude(h=gear_thickness,twist=twist,flat=flat){
		gear2D (number_of_teeth, circular_pitch, pressure_angle, depth_ratio, clearance);
	}
}


module flat_extrude(h, twist, flat){
	if(flat==false)
		linear_extrude(height=h, twist=twist, slices=twist / 6, scale=1)children(0);
	else
		children(0);
}


module gear2D (number_of_teeth,	circular_pitch, pressure_angle, depth_ratio, clearance){
	pitch_radius = number_of_teeth*circular_pitch / (2  *PI);
	base_radius = pitch_radius * cos(pressure_angle);
	depth=circular_pitch / (2 * tan(pressure_angle));
	outer_radius = clearance < 0 ? pitch_radius + depth / 2 - clearance : pitch_radius + depth / 2;
	root_radius1 = pitch_radius - depth / 2 - clearance / 2;
	root_radius = (clearance < 0 && root_radius1 < base_radius) ? base_radius : root_radius1;
	backlash_angle = clearance / (pitch_radius * cos(pressure_angle)) * 180 / PI;
	half_thick_angle = 90 / number_of_teeth - backlash_angle / 2;
	pitch_point = involute (base_radius, involute_intersect_angle (base_radius, pitch_radius));
	pitch_angle = atan2 (pitch_point[1], pitch_point[0]);
	min_radius = max (base_radius, root_radius);

	intersection(){
		rotate(90 / number_of_teeth)
			circle($fn=number_of_teeth * 3, r=pitch_radius + (((depth_ratio * circular_pitch) / 2) - clearance) / 2);
		union(){
			rotate(90 / number_of_teeth)
				circle($fn=number_of_teeth * 2, r=max(root_radius, pitch_radius - depth_ratio * circular_pitch / 2 - clearance / 2));
			for (i = [1:number_of_teeth])rotate(i * 360 / number_of_teeth){
				halftooth (
					pitch_angle,
					base_radius,
					min_radius,
					outer_radius,
					half_thick_angle);		
				mirror([0,1])halftooth (
					pitch_angle,
					base_radius,
					min_radius,
					outer_radius,
					half_thick_angle);
			}
		}
	}
}


module halftooth (pitch_angle, base_radius, min_radius, outer_radius, half_thick_angle){
	index=[0,1,2,3,4,5];
	start_angle = max(involute_intersect_angle (base_radius, min_radius)-5,0);
	stop_angle = involute_intersect_angle (base_radius, outer_radius);
	angle = index * (stop_angle - start_angle) / index[len(index)-1];
	point_array=[
		[0,0],
		involute(base_radius, angle[0] + start_angle),
		involute(base_radius, angle[1] + start_angle),
		involute(base_radius, angle[2] + start_angle),
		involute(base_radius, angle[3] + start_angle),
		involute(base_radius, angle[4] + start_angle),
		involute(base_radius, angle[5] + start_angle)
	];

	difference(){
		rotate(-pitch_angle - half_thick_angle) polygon(points=point_array);
		square(2 * outer_radius);
	}
}

// Mathematical Functions
//===============

// Finds the angle of the involute about the base radius at the given distance (radius) from it's center.
//source: http://www.mathhelpforum.com/math-help/geometry/136011-circle-involute-solving-y-any-given-x.html

function involute_intersect_angle (base_radius, radius) = sqrt (pow (radius/base_radius, 2) - 1) * 180 / PI;

// Calculate the involute position for a given base radius and involute angle.

function involute (base_radius, involute_angle) =
[
	base_radius*(cos (involute_angle) + involute_angle*PI/180*sin (involute_angle)),
	base_radius*(sin (involute_angle) - involute_angle*PI/180*cos (involute_angle))
];

