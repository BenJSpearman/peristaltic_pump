// Diameter of the pump. Minimum of 60mm.
diam = 60;
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
num_connectors = 4;



// Calculated variables
connector_od = connect_bolt_size + 1;


// ============================ Main ====================================
mounting_plate();



// ++++++++++++++++++++++++++++ Modules +++++++++++++++++++++++++++++++++
// Mounting plate to attach to motor. Includes the spacer between the pump and mount.
module mounting_plate(){
	union(){
		difference(){
			cylinder(h=plate_thickness, r=diam/2);
			cylinder(h=plate_thickness + 1, r=(mount_id/3)*2);
			for(hole_num = [0 : 1 : 4]){
				rotate([0, 0, (hole_num * 90)]){
					translate([bolt_spacing/2, bolt_spacing/2, 0]){
						cylinder(h=plate_thickness+1, d=thread_size, $fn=10);
					}
				}
			}
		}
		connectors_arms();
		all_connectors(true);
	}
}

// Connector arms to attach to the plate or pump.
module connectors_arms(){
	increment = 360 / num_connectors;
	for(count = [0 : num_connectors]){
		rotate([0,  0, count*increment]){
			difference(){
				translate([((diam / 2) + (connector_od/2)),  0,  (plate_thickness/2)]){
					cube([connector_od*3, connector_od*2, plate_thickness], center=true);
				}
				translate([(diam/2) + connector_od,  0,  0]){
					cylinder(h=plate_thickness, d=connector_od, $fn=10);
				}
			}
		}
	}
}

// All x number of connectors.
module all_connectors(is_plate=false){
	increment = 360 / num_connectors;
	for(count = [0 : num_connectors]){
		rotate([0,  0, count*increment]){
			translate([(diam/2) + connector_od,  0,  0]){
				connector(is_plate);
			}
		}
	}
}

// An individual connector cylinder.
module connector(is_plate=false){
	if (is_plate) {
		difference(){
			cylinder(h=plate_thickness + mount_spacing, d=connector_od, $fn=10);
			cylinder(h=plate_thickness + mount_spacing, d=connect_bolt_size, $fn=10);
		}
	} else {
		echo("else")
		difference(){
			cylinder(h=connect_bolt_height - 2, d=connector_od, $fn=10);
			cylinder(h=connect_bolt_height - 2, d=connect_bolt_size, $fn=10);
		}
	}
}