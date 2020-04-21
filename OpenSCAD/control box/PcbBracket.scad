include <NopSCADlib/lib.scad>

$fn=100;
epsilon = 0.1;




module layoutXY(xoffset,yoffset)
{
    translate([xoffset,yoffset,0])
        children();
    translate([-xoffset,yoffset,0])
        children();
    translate([xoffset,-yoffset,0])
        children();
    translate([-xoffset,-yoffset,0])
        children();
}

module layoutX(xoffset)
{
    translate([xoffset,0,0])
        children();
    translate([-xoffset,0,0])
        children();
}

// This is the clerance cutout needed for a 3.5mm diameter wood screw
// These screws are used to mount the various arms and brackets to the wooden backplane
// As modelled here, the screw points down with the top of the scre head flush with the z=0 plane
module MountingScrewClearanceHole(depth)
{
    // The pilot hole
    cylinder(d=3.3,h=depth);
    
    // The countersink for the head
    cylinder(d2=3.3,d1=7,h=2.5);    
}

module PcbMountingFrame(xPillarSpacing, yPillarSpacing)
{
    frameThickness = 4;
    frameStripWidth = 8;
    pillarHeight = 8;
    pcbScrewPilotHoleDiameter = 2.5;
    
    difference() 
    {
        union()
        {
            layoutXY(xPillarSpacing/2,frameStripWidth+yPillarSpacing/2)
                cylinder(d=frameStripWidth,h=frameThickness);
            
            translate([-frameStripWidth/2,-frameStripWidth-yPillarSpacing/2,0])
                layoutX(xPillarSpacing/2)
                    cube([frameStripWidth,yPillarSpacing+2*frameStripWidth,frameThickness]);
            translate([-frameStripWidth/2-xPillarSpacing/2,-frameStripWidth/2,0])
                cube([xPillarSpacing+frameStripWidth,frameStripWidth,frameThickness]);
            
            layoutXY(xPillarSpacing/2,yPillarSpacing/2)
                cylinder(d=frameStripWidth,h=pillarHeight);
        }
        union()
        {
            translate([0,0,-epsilon])
                layoutXY(xPillarSpacing/2,yPillarSpacing/2)
                    cylinder(d=pcbScrewPilotHoleDiameter,h=pillarHeight+2*epsilon);
            translate([0,0,frameThickness+epsilon])
                layoutXY(xPillarSpacing/2,yPillarSpacing/2+frameStripWidth)
                    rotate([180,0,0])    
                        MountingScrewClearanceHole(frameThickness+2*epsilon);
        }
    }
}

module VeroPcbMountingFrame()
{
    PcbMountingFrame( inch(34 * 0.1), inch(21 * 0.1));
}




module Hyp332BracketBase()
{
    boxWallThickness = 3;
    pcbLength = 32;
    pcbWidth = 30;
    pcbGripLength = 2;
    baseWidth = pcbWidth + 2 * 1.5;
    cutoutwidth = pcbWidth +1;
    
    difference()
    {
        union()
        {
            // A shape to fill in the gap in the panel
            cube([33,boxWallThickness,10]);
            
            // something to connect to the far end and supply support whilst printing
            cube([33,44,5]);
            
            // an end stop
            translate([0,pcbLength + boxWallThickness -2*pcbGripLength,0])
                cube([33,13,7+1.5]);
            
            translate([-10,10,0])
                cube([33+20,10,5]);
        }
        union()
        {
            // These are holes into which pegs from the cap will locate
            translate([6,38,-epsilon])
                cylinder(d=4.5,h=12,$fn=20);
            translate([27,38,-epsilon])
                cylinder(d=4.5,h=12,$fn=20);

            // a cutout for the power socket
            translate([20,-epsilon,8])
                cube([10,5+2*epsilon,12]);

            // a cutout for the pcb
            translate([(baseWidth - cutoutwidth)/2,boxWallThickness-pcbGripLength+epsilon,7])
                cube([cutoutwidth,pcbLength+1,2]);    
            
            // This is a hole into which as self tapping screw will fit
            translate([33/2,38,-epsilon])
                cylinder(d=2.5,h=12,$fn=20);
            
            translate([-5,15,5+epsilon])
                rotate([180,0,0])    
                        MountingScrewClearanceHole(5+2*epsilon);
            translate([33+5,15,5+epsilon])
                rotate([180,0,0])    
                        MountingScrewClearanceHole(5+2*epsilon);
        }
    }
}



module Hyp332BracketTop()
{
    difference()
    {
        union()
        {
            translate([0,33,0])
                cube([33,12,7]);
            translate([6,39,-5])
                cylinder(d=4,h=10+2*epsilon);
            translate([27,39,-5])
                cylinder(d=4,h=10+2*epsilon);
        }
        union()
        {

            translate([33/2,39,7+epsilon])
                rotate([180,0,0]) 
                MountingScrewClearanceHole(7+2*epsilon);
        }
    }
}

//Hyp332BracketBase();

Hyp332BracketTop();
//VeroPcbMountingFrame();