
include <BOSL/constants.scad>
use <BOSL/threading.scad>
use <BOSL/nema_steppers.scad>


$fn = 40;

use <valve1908F.scad>
use <bsp_threads.scad>


epsilon = 0.01;

// This is the width of a Nema17 motor
motorBodyWidth = 42;

// This is the gap between motors. 
// It is big enough to get an assembly screw comfortably between the motors
motorGap = 8;

motorShaftSpacing = motorBodyWidth + motorGap;


// The gap between the water connectors must be enough to fit the hose adapters
waterConnectorSpacing = 40;

// This is the diameter of the internal pipes that carry water between the connecotrs and the valves
boreDiameter = 6;

// This is the radius of the bends in the internal plumbing
bendRadius = 5; 

// This is the height above the outside bottom of the manifold at which the middle of
// the plumbing bores lies.
boreCenterHeight = 6;

// This is the thickness of the majority of the plate on which the motors are mounted
motorPlateThickness = 3;

// The intended screw is a 3x12 countersunk wood screw 
assemblyScrewTapHoleDiameter = 2.5;
assemblyScrewClearHoleDiameter = 3.2;
assemblyScrewLength = 12;

// The intended screw is a 5x50 countersunk wood screw 
mountingScrewTapHoleDiameter = 3;
mountingScrewClearHoleDiameter = 5;
mountingScrewLength = 50;


screwHoleInset = 4;

assemblyScrewHoleTapDepth = assemblyScrewLength - motorPlateThickness + 1;

bracketToShaftXYOffset = 12;

// Each cartridge is screwed into a turret that is this height above the XY plane
turretHeight = 32;

// This is the diamter of the main cylindrical shape into which the cardtidge screws
turretOuterDiameter = 30;

outletDownpipeY = 2*boreCenterHeight;


function manifoldMidX(numOutlets) = motorShaftSpacing * (numOutlets-1) / 2;

function motorX(outletNumber) = outletNumber * motorShaftSpacing;

function hoseX(hoseNumber, numOutlets) = hoseNumber * waterConnectorSpacing + manifoldMidX(numOutlets) - waterConnectorSpacing * numOutlets /2;

function outletHoseX(outletNumber, totalOutlets, motorSpacing, outletSpacing) = 
    outletNumber >=  totalOutlets / 2 ? hoseX(outletNumber+1,totalOutlets) : hoseX(outletNumber,totalOutlets);



module Tooth(height,width,depth)
{
    polyhedron(
               points=[[-width/2,0,0], [width/2,0,0], [0,depth,0], [-width/2,0,height], [width/2,0,height], [0,depth,height]],
               faces=[[0,1,2],[3,5,4],[0,2,5,3],[1,4,5,2],[0,3,4,1]]
               );
}

module SplinedCylinder(h,d1,d2,numSplines)
{

    theta = 360/(2*numSplines);
    y=cos(theta)*d1/2;
    toothWidth = d1*sin(theta);
    toothHeight = d2-d1;
    cylinder(d=d1,h=h,$fn=numSplines);
    for(i=[0:numSplines-1])
    {
        rotate([0,0,theta+i*2*theta])
            translate([0,y-epsilon,0])
                Tooth(h,toothWidth,toothHeight+epsilon);
        
    }
    
}


module NemaMotorShaft(height)
{
    fitTolerance = 0.2;
    intersection()
    {
        cylinder(d=5+fitTolerance,h=height);
            translate([-2,-2.5-fitTolerance,0])
                cube([4.5+fitTolerance,5+2*fitTolerance,height]);
    }
    translate([0,0,height-0.5])
        cylinder(d1=3,d2=6,h=0.5);
}



module NemaMotorTapJoint()
{
    jointLength = 25;
    nemaShaftLength = 20;
    splineLength = 9;
    
    difference()
    {
        union()
        {
            // A hex outer cylinder
            cylinder(d=13/cos(30),h=jointLength,$fn=6);
        }
        union()
        {
            translate([0,0,-epsilon])
                SplinedCylinder(h=splineLength+epsilon,d1=7.0,d2=7.8,numSplines=20);
            
            translate([0,0,jointLength-nemaShaftLength-epsilon])
                NemaMotorShaft(nemaShaftLength+2*epsilon);
        }
    }

}


// A simple elbow sticks up from the origin, and bends 90 degrees to line up with the X axis
module SimpleElbow(diameter, bendRadius)
{
    translate([bendRadius,0,-bendRadius])
        rotate([90,0,180])
            rotate_extrude(convexity=10, angle=90) 
                translate(v=[bendRadius,0,0]) 
                    circle(d=diameter); 
}

// This is a cutout for an assembly screw in the part that is to be attached.
// This creates a countersunk hole which is loose on the screw shank.
module AssemblyScrewClearanceHole()
{
    translate([0,0,-assemblyScrewLength])
        cylinder(d=assemblyScrewClearHoleDiameter,h=assemblyScrewLength+epsilon);
    translate([0,0,-5.5])
        cylinder(d1=0,d2=5.5,h=5.5+epsilon);
}

// This is a cutout for a mounting screw in the part that is to be attached.
// This creates a countersunk hole which is loose on the screw shank.
module MountingScrewClearanceHole()
{
    translate([0,0,-mountingScrewLength])
        cylinder(d=mountingScrewClearHoleDiameter,h=mountingScrewLength+epsilon);
    translate([0,0,-10])
        cylinder(d1=0,d2=10,h=10+epsilon);
}



module ManifoldInletPlumbing(numOutlets, ioY)
{
    ioHeight = 2*boreCenterHeight;
    
    // first inlet downpipe and elbow
    translate([0 ,0, boreCenterHeight])
        rotate([0,-90,0])
            SimpleElbow(boreDiameter, bendRadius);
    translate([0,0,boreCenterHeight-epsilon+bendRadius])
        cylinder(d=boreDiameter, h=50+epsilon);
    
    // last inlet downpipe and elbow
    translate([(numOutlets-1)*motorShaftSpacing,0,0])
    {
        translate([0 ,0, boreCenterHeight])
            rotate([0,180,0])
                SimpleElbow(boreDiameter, bendRadius);    
        translate([0,0,boreCenterHeight-epsilon+bendRadius])
            cylinder(d=boreDiameter, h=ioHeight+epsilon);
    }

    if (numOutlets > 2)
    {
        
        // down pipes for inner inlets
        for (inletNumber = [1:numOutlets-2])
        {
            x = motorX(inletNumber);
            translate([x,0,boreCenterHeight-epsilon])
                cylinder(d=boreDiameter, h=50+epsilon);
        }
   
    }
    // connector pipe between inlets
    translate([bendRadius ,0,boreCenterHeight])
        rotate([0,90,0])
            cylinder(d=boreDiameter, h=(numOutlets-1)*motorShaftSpacing-2*bendRadius+2*epsilon);
    
    inletX =  manifoldMidX(numOutlets);
    

    translate([inletX,ioY,boreCenterHeight])
        rotate([0,180,90])
            SimpleElbow(boreDiameter, bendRadius);
    translate([inletX,ioY,bendRadius+boreCenterHeight-epsilon])
        cylinder(d=boreDiameter, h=ioHeight+epsilon);
    translate([inletX,-epsilon,boreCenterHeight])
        rotate([-90,0,0])
        cylinder(d=boreDiameter, h=ioY-bendRadius+2*epsilon);
}

module ManifoldOuletPlumbing(outletNumber, totalOutlets)
{
    ioY = turretOuterDiameter +  waterConnectorSpacing/2;
    ioHeight = 2*boreCenterHeight;
    
    x1 = outletHoseX(outletNumber, totalOutlets, motorShaftSpacing, waterConnectorSpacing);
    x2 = motorX(outletNumber);
    y1 = ioY;
    y2 = turretOuterDiameter/2;
    
    totalLength = sqrt( (x1-x2) * (x1-x2) + (y1-y2) * (y1-y2));
    
    innerLength = totalLength - 2*bendRadius;
    
    angle = atan ((x1-x2) / (y1-y2));

    translate([0,0,boreCenterHeight])
    {
        translate([x2,y2,0])
            rotate([0,0,-angle])
            {
                rotate([0,-90,90])
                    SimpleElbow(boreDiameter, bendRadius);
                translate([0,bendRadius,0])
                    rotate([-90,0,0])
                        cylinder(d=boreDiameter,h=innerLength);
                translate([0,totalLength,0])
                    rotate([0,180,90])
                        SimpleElbow(boreDiameter, bendRadius);
            }
    }
    
    translate([x1,y1,boreCenterHeight-epsilon+bendRadius])
        cylinder(d=boreDiameter, h=ioHeight+epsilon);


    translate([x2,0,boreCenterHeight-epsilon+2*bendRadius])
        rotate([-90,0,0])
            cylinder(d=boreDiameter,h=turretOuterDiameter/2-bendRadius);

    translate([x2,y2,boreCenterHeight-epsilon+2*bendRadius])
        rotate([0,0,-90])
            SimpleElbow(boreDiameter, bendRadius);
}

module CardridgeCavity()
{
    // Thread into which cartridge screws
    translate([0,0,turretHeight-8-epsilon])
        HalfInchBspThread(length=8+2*epsilon,internal = true);

    // Wide cavity around outlet of cartridge
    translate([0,0,turretHeight-16])
        cylinder(h=5,d=25);                        
    translate([0,0,turretHeight-11-epsilon])
        cylinder(h=5,d1=25,d2=18.5);

    // Cavity for main body of cartridge
    translate([0,0,turretHeight-21])
    cylinder(h=21+epsilon,d=18.5); 


    translate([0,0,15])
        cylinder(h=turretHeight,d=boreDiameter);
    
}

module TurretOuter(addInitialSupportLugs, addFinalSupportLugs)
{

    for(i = [0:3])
    {
        if  ( (addInitialSupportLugs && ( (i==1) || (i==2))) || (addFinalSupportLugs && ((i==0) || (i==3))) )
        {
            rotate([0,0,i*90])
            {
                translate([bracketToShaftXYOffset,bracketToShaftXYOffset,turretHeight-assemblyScrewHoleTapDepth])
                    difference()
                    {
                        cylinder(d=8,h=assemblyScrewHoleTapDepth);
                        translate([0,0,-epsilon])    
                        cylinder(d=assemblyScrewTapHoleDiameter,h=assemblyScrewHoleTapDepth+2*epsilon);
                    }
                
                hull()
                {
                    translate([bracketToShaftXYOffset,bracketToShaftXYOffset,turretHeight-assemblyScrewHoleTapDepth])
                        cylinder(d=8,h=epsilon);
                    translate([bracketToShaftXYOffset/2,bracketToShaftXYOffset/2,0])
                        cylinder(d=epsilon,h=epsilon);
                    
                }
            }
        }
    }
    translate([0,0,outletDownpipeY/2])
        cylinder(d=turretOuterDiameter,h=turretHeight-outletDownpipeY/2);
    
    translate([0,0,outletDownpipeY/2])
            rotate_extrude(convexity=10, angle=360) 
                translate(v=[turretOuterDiameter/2-outletDownpipeY/2,0,0]) 
                    circle(d=outletDownpipeY); 
    translate([0,0,0])
        cylinder(d=turretOuterDiameter-outletDownpipeY,h=outletDownpipeY/2);
    
    
    
    translate([0,turretOuterDiameter/2,boreCenterHeight])
        cylinder(d=2*boreCenterHeight,h=2*bendRadius);
    translate([0,turretOuterDiameter/2,boreCenterHeight+2*bendRadius])
        sphere(d=2*boreCenterHeight);

    
}

module NWayManifold(numOutlets)
{
    ioHeight = 2*boreCenterHeight;
    
    hoseThreadLength = 11;
    
    ioY = turretOuterDiameter +  waterConnectorSpacing/2;
    
    difference()
    {
        union()
        {
            if (1)
            {
            
            for (outlet = [0:numOutlets-1])
            {
                addInitialSupportLugs = (outlet!=0) || (numOutlets < 4);
                addFinalSupportLugs = (outlet != (numOutlets-1)) || (numOutlets < 4);
                x = motorX(outlet);

                translate([x,0,0])
                    TurretOuter(addInitialSupportLugs,addFinalSupportLugs);
            }


            translate([0,0,outletDownpipeY/2])
            
            hull()
            {
                translate([motorX(0),0,0])
                    sphere(d=outletDownpipeY);
                translate([motorX(numOutlets-1),0,0])
                    sphere(d=outletDownpipeY);

                translate([motorX(0),outletDownpipeY,0])
                    sphere(d=outletDownpipeY);
                translate([motorX(numOutlets-1),outletDownpipeY,0])
                    sphere(d=outletDownpipeY);
                translate([hoseX(0,numOutlets),ioY,0])
                    sphere(d=outletDownpipeY);
                translate([hoseX(numOutlets,numOutlets),ioY,0])
                    sphere(d=outletDownpipeY);
            }

            // hose connectors,
            // note n+1 count since this is n outlets + 1 inlet
            for (hose = [0:numOutlets])
            {
                x = hoseX(hose, numOutlets);
                translate([x,ioY,ioHeight])
                    ThreeQuaterInchBspThread(hoseThreadLength, internal=false);
                translate([x,ioY,0])
                    cylinder(d2=25, d1=0,h=ioHeight);
            }
            }
        }
        union()
        {
            ManifoldInletPlumbing(numOutlets, ioY);
            
            
            for (outlet = [0:numOutlets-1])
            {
                ManifoldOuletPlumbing(outlet, numOutlets);
            }
            
           
            
            // cones in hose connectors,
            // note n+1 count since this is n outlets + 1 inlet
            for (hose = [0:numOutlets])
            {
                x = hose * waterConnectorSpacing + manifoldMidX(numOutlets) - waterConnectorSpacing * numOutlets /2;
                translate([x,ioY,ioHeight+epsilon])
                    cylinder(h=hoseThreadLength/2+2*epsilon, d1=boreDiameter, d2=20);
                translate([x,ioY,ioHeight+epsilon+hoseThreadLength/2])
                    cylinder(h=hoseThreadLength/2+2*epsilon, d=20);
            }
            for (cavity = [0:numOutlets-1])
            {
                x = cavity * motorShaftSpacing;
                
                translate([x,0,0])
                {
                    CardridgeCavity();    
                }
            }
            
            for (hole =  [0:numOutlets-1])
            {
                x = hoseX(hole, numOutlets) + waterConnectorSpacing/2;
                translate([x,30,outletDownpipeY])
                MountingScrewClearanceHole();
            }
        }
    }
}


module MotorStandoffBracket(addLeftFoot, addRightFoot)
{
    bracketHeight = 52;
    
    difference()
    {
        union()
        {
            if (addLeftFoot)
            {
                translate([-18,-4,0])
                    cube([22,15,motorPlateThickness]);
            }
            if (addRightFoot)
            {
                translate([-4,-4,0])
                    cube([22,15,motorPlateThickness]);
            }
            
            
            translate([-4,-4,0])
                cube([8,4,bracketHeight]);
            translate([-4,-4,bracketHeight-10])
                cube([8,8,10]);
        }
        union()
        {
            {
                holeDepth = assemblyScrewLength - motorPlateThickness +1;
                translate([0,0,bracketHeight-holeDepth+epsilon])
                    cylinder(d=assemblyScrewTapHoleDiameter,h=holeDepth+epsilon);


                x1 = motorShaftSpacing/2;
                translate([x1,-(screwHoleInset-motorBodyWidth/2),-epsilon])
                    cylinder(d=25,h=motorPlateThickness+2*epsilon);
                translate([-x1,-(screwHoleInset-motorBodyWidth/2),-epsilon])
                    cylinder(d=25,h=motorPlateThickness+2*epsilon);
            }

            {
                x2 = motorShaftSpacing/2-bracketToShaftXYOffset;
                y2 = -(screwHoleInset-motorBodyWidth/2+bracketToShaftXYOffset);
            
            
                translate([x2,y2,motorPlateThickness])
                    AssemblyScrewClearanceHole();
                translate([-x2,y2,motorPlateThickness])
                    AssemblyScrewClearanceHole();
            }
        }
        
    }
}

module Nema17MotorPlate(numOutlets)
{
    
    difference()
    {
        union()
        {
            if (numOutlets > 2)
            {
                translate([-motorBodyWidth/2,-motorBodyWidth/2,0])
                {
                    w = numOutlets*motorBodyWidth + (numOutlets-1) * motorGap;
                    d = motorBodyWidth;
                    h = motorPlateThickness;
                    cornerRadius = 4;
                    translate([cornerRadius,cornerRadius,0])
                        cylinder(r=cornerRadius,h=motorPlateThickness);
                    translate([w-cornerRadius,cornerRadius,0])
                        cylinder(r=cornerRadius,h=motorPlateThickness);
                    translate([w-cornerRadius,d-cornerRadius,0])
                        cylinder(r=cornerRadius,h=motorPlateThickness);
                    translate([cornerRadius,d-cornerRadius,0])
                        cylinder(r=cornerRadius,h=motorPlateThickness);
                    translate([cornerRadius,0,0])
                        cube([w-2*cornerRadius,d,h]);
                    translate([0,cornerRadius,0])
                        cube([w,d-2*cornerRadius,h]);
                }
            }
            else
            {
                translate([-(motorBodyWidth/2 + motorGap),-motorBodyWidth/2,0])
                    cube([numOutlets*motorBodyWidth + (numOutlets-1) * motorGap + 2* motorGap,motorBodyWidth,motorPlateThickness]);
            }
        }
        union()
        {
            numBracketHolePairs = numOutlets-1 +( (numOutlets > 2) ? 0 : 2);
            firstBracketX = (numOutlets > 2) ? motorShaftSpacing/2 : - motorShaftSpacing/2;
            for (bracket = [0:numBracketHolePairs-1])
            {
                bracketHoleX = bracket * motorShaftSpacing + firstBracketX;
                bracketHoleY = motorBodyWidth/2-4;
                translate([bracketHoleX,bracketHoleY,motorPlateThickness])
                    AssemblyScrewClearanceHole();
                translate([bracketHoleX,-bracketHoleY,motorPlateThickness])
                    AssemblyScrewClearanceHole();
            }

            for (motor = [0:numOutlets-1])
            {
                motorX = motor * motorShaftSpacing;
                translate([motorX,0,motorPlateThickness/2])
                    nema_mount_holes(size=17, depth=motorPlateThickness+2*epsilon, l=0);
            }
        }
    }
    
}

module Assembly(numOutlets = 2)
{
    color("cyan")
        NWayManifold(numOutlets);
    
    translate([0,0,84])
        color("cyan")
            Nema17MotorPlate(numOutlets);
    
    
    for (bracket = [0:numOutlets-2])
    {
        x = bracket *  motorShaftSpacing + motorShaftSpacing/2;
        translate([x,screwHoleInset-motorBodyWidth/2,turretHeight])
            MotorStandoffBracket(true,true);
        translate([x,-(screwHoleInset-motorBodyWidth/2),turretHeight])
            rotate([0,0,180])
                MotorStandoffBracket(true,true);
    }
    
    if ( ! (numOutlets > 2))
    {
        x1 = - motorShaftSpacing/2;
        translate([x1,screwHoleInset-motorBodyWidth/2,turretHeight])
            MotorStandoffBracket(false,true);
        translate([x1,-(screwHoleInset-motorBodyWidth/2),turretHeight])
            rotate([0,0,180])
                MotorStandoffBracket(true,false);
    
        x2 = 2* motorShaftSpacing- motorShaftSpacing/2;
        translate([x2,screwHoleInset-motorBodyWidth/2,turretHeight])
            MotorStandoffBracket(true,false);
        translate([x2,-(screwHoleInset-motorBodyWidth/2),turretHeight])
            rotate([0,0,180])
                MotorStandoffBracket(false,true);
    }
    
    
    for (outlet = [0:numOutlets-1])
    {
        motorX = outlet * motorShaftSpacing;
        
        translate([motorX,0,87])
            rotate([0,180,0])
                nema17_stepper(shaft_len=22);

        translate([motorX,0,54])
            color("cyan")
                NemaMotorTapJoint();

        translate([motorX,0,11])
                Valve1908F();

    }
}

Assembly();


// TODO:
// Simplify turret body as single rotation
// Add spacers to motor bracket to account for long screws
// Make seal for hose adapters thinner
// Add rotated-for-print bits
// Allow for case numOutlets = 1 or other odd value
// Optionaly combine motor brackets for smaller manifolds
// Model assembly and mounting screws
// Model hose adapters


