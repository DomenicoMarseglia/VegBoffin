// This is a model of a sealing washer. 
// They are commonly sold for the inlet hoses of washing machines and dish washers
// E.g. Screwfix 6039J
// It is not meant to be 3d printed, is is only meant as a visual aid in assembly models



epsilon = 0.01;

module Washer6039J()
{
    color("grey")
    difference()
    {
        union()
        {
            cylinder(d=23.5,h=2);
        }
        union()
        {
            translate([0,0,-epsilon])
            {
                cylinder(d=12,h=2+2*epsilon);
            }
        }
    }
    
}

Washer6039J();

