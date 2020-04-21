


// TODO:
// Add rotated-for-print bits
// Allow for case numOutlets = 1 or other odd value
// Optionaly combine motor brackets for smaller manifolds
// Model assembly and mounting screws
// Add vegboffin logo
// Make motor plate work with M3x10 bolts
// Add features to motor plate to stop pillars from twisting
// Fix tap adapter. Splines are too loose, motor connector is too tight


include <BOSL/constants.scad>
use <BOSL/threading.scad>
use <BOSL/nema_steppers.scad>
use <BOSL/transforms.scad>


$fn = 200;

use <TapGland1908F.scad>
use <bsp_threads.scad>


epsilon = 0.01;


inletsOnOppositeSideToOutlets = true;

// This is the width of a Nema17 motor
motorBodyWidth = 42;

// This is the gap between motors. 
// It is big enough to get an assembly screw comfortably between the motors
motorGap = 8;

motorShaftSpacing = motorBodyWidth + motorGap;


// The gap between the water connectors must be enough to fit the hose adapters
waterConnectorSpacing = 40;

// This is the diameter of the internal pipes that carry water between the connectors and the valves
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

// This is the diameter of the main cylindrical shape into which the cartridge screws
turretOuterDiameter = 30;

outletDownpipeY = 2*boreCenterHeight;


function manifoldMidX(numOutlets) = motorShaftSpacing * (numOutlets-1) / 2;

function motorX(outletNumber) = outletNumber * motorShaftSpacing;

function hoseX(hoseNumber, numOutlets) = hoseNumber * waterConnectorSpacing + manifoldMidX(numOutlets) - waterConnectorSpacing * numOutlets /2;

//function outletHoseX(outletNumber, numInlets, numOutlets, motorSpacing, outletSpacing) = 
  //  outletNumber >=  numOutlets / 2 ? hoseX(outletNumber+numInlets,numOutlets) : hoseX(outletNumber,numOutlets);


// The inlets are evenly spaced in the X direction about the mid point of the manifold
function inletHoseX(inletNumber, numInlets, numOutlets) = manifoldMidX(numOutlets) - ((numInlets-1) * waterConnectorSpacing/2)+ (inletNumber-1) * waterConnectorSpacing;

function outletHoseXWithInletsBetweenOutlets(outletNumber, numInlets, numOutlets) = 
    outletNumber <=  numOutlets / 2 ? 
        inletHoseX(outletNumber,numInlets+numOutlets, numOutlets):
        inletHoseX(outletNumber+numInlets,numInlets+numOutlets, numOutlets);

function outletHoseXWithInletsOppositeOutlets(outletNumber, numInlets, numOutlets) = 
        inletHoseX(outletNumber,numOutlets, numOutlets);

function outletHoseX(outletNumber, numInlets, numOutlets) = 
    inletsOnOppositeSideToOutlets ? 
        outletHoseXWithInletsOppositeOutlets(outletNumber, numInlets, numOutlets):
        outletHoseXWithInletsBetweenOutlets(outletNumber, numInlets, numOutlets);

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



module WShapeManifold(numConnections, spacing)
{
    ioHeight = 2*boreCenterHeight;
    
    // first outlet downpipe and elbow
    translate([0 ,0, boreCenterHeight])
        rotate([0,-90,0])
            SimpleElbow(boreDiameter, bendRadius);
    translate([0,0,boreCenterHeight-epsilon+bendRadius])
        cylinder(d=boreDiameter, h=ioHeight+epsilon);
    
    // last outlet downpipe and elbow
    translate([(numConnections-1)*spacing,0,0])
    {
        translate([0 ,0, boreCenterHeight])
            rotate([0,180,0])
                SimpleElbow(boreDiameter, bendRadius);    
        translate([0,0,boreCenterHeight-epsilon+bendRadius])
            cylinder(d=boreDiameter, h=ioHeight+epsilon);
    }

    if (numConnections > 2)
    {
        
        // down pipes for inner inlets
        for (connectorNumber = [1:numConnections-2])
        {
            x = spacing*connectorNumber;
            translate([x,0,boreCenterHeight-epsilon])
                cylinder(d=boreDiameter, h=ioHeight+bendRadius+epsilon);
        }
   
    }
    // connector pipe between outlets
    translate([bendRadius-epsilon ,0,boreCenterHeight])
        rotate([0,90,0])
            cylinder(d=boreDiameter, h=(numConnections-1)*spacing-2*bendRadius+2*epsilon);

}

module HoseConectorFluidPathway(hoseThreadLength)
{
    ioHeight = 2*boreCenterHeight;
    
    translate([0,0,ioHeight+epsilon])
        cylinder(h=hoseThreadLength/2+2*epsilon, d1=boreDiameter, d2=20);
    translate([0,0,ioHeight+epsilon+hoseThreadLength/2])
        cylinder(h=hoseThreadLength/2+2*epsilon, d=20);
}


module CartridgeCavity()
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
        cylinder(h=turretHeight-15,d=boreDiameter);
    
}


// This module is the cutout for the inlet plumbing
// numInlets is the number of inlet connectors. 
// This may be more than one if the manifold is configured to be daisychained with other manifolds
// numOutlets is the number of outlets (the number of valves)
module ManifoldInletPlumbing(numInlets, numOutlets, ioY, hoseThreadLength)
{
    ioHeight = 2*boreCenterHeight;

    x = manifoldMidX(numOutlets);
    y = inletsOnOppositeSideToOutlets ? -ioY : ioY;

    if (numOutlets == 1)
    {
        translate([x,0,boreCenterHeight])
            rotate([0,180,90 ])
                SimpleElbow(boreDiameter, bendRadius);
    }
    else
    {
        WShapeManifold(numOutlets, motorShaftSpacing);

        translate([x,-epsilon,boreCenterHeight])
            rotate([-90,0,inletsOnOppositeSideToOutlets ? 180:0])
                cylinder(d=boreDiameter, h=ioY/2);
    }
    

    if (numInlets == 1)
    {
        hoseX = inletHoseX(1, numInlets, numOutlets);
            translate([hoseX,y,0])
        HoseConectorFluidPathway(hoseThreadLength);
        
        rotate([0,0,0])
        {
            translate([x,y,boreCenterHeight])
                rotate([0,180,-90])
                    SimpleElbow(boreDiameter, bendRadius);
            translate([x,y,bendRadius+boreCenterHeight-epsilon])
                cylinder(d=boreDiameter, h=ioHeight+epsilon);
            translate([x,-epsilon,boreCenterHeight])
                rotate([-90,0,inletsOnOppositeSideToOutlets ? 180:0])
                    cylinder(d=boreDiameter, h=ioY-bendRadius+2*epsilon);
        }
    }
    else
    {
        for (inletNumber=[1:numInlets])
        {
            hoseX = inletHoseX(inletNumber, numInlets, numOutlets);
            translate([hoseX,y,0])
                HoseConectorFluidPathway(hoseThreadLength);
        }            
        

        translate([x - (numInlets-1) * waterConnectorSpacing / 2,y,0])
            WShapeManifold(numInlets, waterConnectorSpacing);

        translate([x,-bendRadius-epsilon,boreCenterHeight])
            rotate([-90,0,inletsOnOppositeSideToOutlets ? 180:0])
                cylinder(d=boreDiameter, h=ioY-bendRadius);
    }
}

module ManifoldOuletPlumbing(outletNumber, numInlets, numOutlets, hoseThreadLength)
{
    ioY = turretOuterDiameter +  waterConnectorSpacing/2;
    ioHeight = 2*boreCenterHeight;
    
    x1 = outletHoseX(outletNumber, numInlets, numOutlets);
    x2 = motorX(outletNumber-1);
    y1 = ioY;
    y2 = turretOuterDiameter/2;
    
    totalLength = sqrt( (x1-x2) * (x1-x2) + (y1-y2) * (y1-y2));
    
    innerLength = totalLength - 2*bendRadius;
    
    angle = atan ((x1-x2) / (y1-y2));

    translate([x2,0,0])
        CartridgeCavity();

    translate([0,0,boreCenterHeight])
    {
        translate([x2,y2,0])
            rotate([0,0,-angle])
            {
                rotate([0,-90,90])
                    SimpleElbow(boreDiameter, bendRadius);
                
                // An angled bore to connect the cavity outlet downpipe to the connector elbow
                translate([0,bendRadius-epsilon,0])
                    rotate([-90,0,0])
                        cylinder(d=boreDiameter,h=innerLength+2*epsilon);
                translate([0,totalLength,0])
                    rotate([0,180,90])
                        SimpleElbow(boreDiameter, bendRadius);
            }
    }
    
    // A bore that goes up into the connector
    translate([x1,y1,boreCenterHeight-epsilon+bendRadius])
        cylinder(d=boreDiameter, h=ioHeight+epsilon);


    // A bore that goes into the center of the cavity
    translate([x2,0,boreCenterHeight-epsilon+2*bendRadius])
        rotate([-90,0,0])
            cylinder(d=boreDiameter,h=turretOuterDiameter/2-bendRadius+epsilon);

    // An elbow that goes horizonally from the cavity outlet down
    translate([x2,y2,boreCenterHeight-epsilon+2*bendRadius])
        rotate([0,0,-90])
            SimpleElbow(boreDiameter, bendRadius);
    
    
    translate([x1,y1,0])
        HoseConectorFluidPathway(hoseThreadLength);
}


module ManifoldOutletPlumbingSet(numInlets, numOutlets, hoseThreadLength)
{
    for (outlet = [1:numOutlets])
    {
        ManifoldOuletPlumbing(outlet, numInlets, numOutlets, hoseThreadLength);
    }
}

module RoundTopCylinder(d,h)
{
    translate([0,0,h-d/2])
        sphere(d=d);
    cylinder(d=d,h=h-d/2);
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
    
    cylinder(d=turretOuterDiameter, h=turretHeight);
    
    translate([0,turretOuterDiameter/2,0])
        RoundTopCylinder(d=2*boreCenterHeight,h = 2*boreCenterHeight + 2*bendRadius);
}


module FluidPathways(numInlets, numOutlets, ioY, hoseThreadLength)
{
    ManifoldInletPlumbing(numInlets, numOutlets, ioY, hoseThreadLength);
    ManifoldOutletPlumbingSet(numInlets, numOutlets, hoseThreadLength);
}

module HoseConnectorOuter(hoseThreadLength)
{
    ioHeight = 2*boreCenterHeight;
    translate([0,0,ioHeight])
        ThreeQuaterInchBspThread(hoseThreadLength, internal=false);
    translate([0,0,0])
        cylinder(d2=25, d1=0,h=ioHeight);
}



module MountingHoleSet(numInlets, numOutlets, ioY)
{
    ioY = turretOuterDiameter +  waterConnectorSpacing/2;
    holeY = ioY/2;
    
    firstConnectorX = outletHoseX(1, numInlets, numOutlets);
    secondConnectorIsInput = ((inletsOnOppositeSideToOutlets == false) && (numOutlets == 2));
    secondConnectorX = secondConnectorIsInput ? inletHoseX(1, numInlets, numOutlets):outletHoseX(2, numInlets, numOutlets);
    
    lastConnectorX = outletHoseX(numOutlets, numInlets, numOutlets);
    penultimateConnectorIsInput = ((inletsOnOppositeSideToOutlets == false) && (numOutlets == 2));
    penultimateConnectorX = penultimateConnectorIsInput ? inletHoseX(numInlets, numInlets, numOutlets):outletHoseX(numOutlets-1, numInlets, numOutlets);
        
    holesDuplicated = (firstConnectorX == penultimateConnectorX) && (secondConnectorX == lastConnectorX);
    
    holeX1 = holesDuplicated ? manifoldMidX(numOutlets) - 10 : (firstConnectorX + secondConnectorX)/2;
    holeX2 = holesDuplicated ? manifoldMidX(numOutlets) + 10 : (penultimateConnectorX + lastConnectorX)/2;

    translate([holeX1,holeY,outletDownpipeY])
        MountingScrewClearanceHole();
    translate([holeX2,holeY,outletDownpipeY])
        MountingScrewClearanceHole();
}

module FlowArrow()
{
    translate([0,40,0])
    linear_extrude(1)
    {
        polygon([ [0,0], [-20,-30], [-10,-30],[-10,-80],[10,-80] , [10,-30], [20,-30] ]);
    }
}


module FlowArrowSet(manifoldThickness, numInlets = 2, numOutlets = 4)
{
    ioY = turretOuterDiameter +  waterConnectorSpacing/2;
    inArrowY = inletsOnOppositeSideToOutlets ? -ioY/2 : ioY/2;
    inArrowZRot = inletsOnOppositeSideToOutlets ? 0: 180;
    translate([motorX(numOutlets-1)/2,inArrowY,manifoldThickness/2])
        rotate([0,0,inArrowZRot])
            scale([0.2,0.2,manifoldThickness/2+1])
                FlowArrow();
    
    for (arrow=[0:numOutlets-1])
    {
        outArrowY = ioY/2;
        outArrowX = (motorX(arrow) + outletHoseX(arrow+1, numInlets, numOutlets)) /2;
        outArrowZRot = atan( (motorX(arrow) - outletHoseX(arrow+1, numInlets, numOutlets)) / ioY);
        translate([outArrowX,outArrowY,manifoldThickness/2])
            rotate([0,0,outArrowZRot])
                scale([0.2,0.2,manifoldThickness/2+1])
                    FlowArrow();
    }
    
}


module NWayManifold(numInlets = 2, numOutlets = 4)
{
    ioHeight = 2*boreCenterHeight;
    
    hoseThreadLength = 11;
    
    ioY = turretOuterDiameter +  waterConnectorSpacing/2;
    
    difference()
    {
        union()
        {
            color("red")
                FlowArrowSet(outletDownpipeY, numInlets, numOutlets);

            for (outlet = [0:numOutlets-1])
            {
                addInitialSupportLugs = (outlet!=0) || (numOutlets < 4);
                addFinalSupportLugs = (outlet != (numOutlets-1)) || (numOutlets < 4);
                x = motorX(outlet);

                translate([x,0,0])
                    TurretOuter(addInitialSupportLugs,addFinalSupportLugs);
            }


            //translate([0,0,outletDownpipeY/2])
            {
            
                hull()
                {
                    translate([motorX(0),0,0])
                        RoundTopCylinder(d=outletDownpipeY, h=outletDownpipeY);
                    translate([motorX(numOutlets-1),0,0])
                        RoundTopCylinder(d=outletDownpipeY, h=outletDownpipeY);

                    translate([motorX(0),outletDownpipeY,0])
                        RoundTopCylinder(d=outletDownpipeY, h=outletDownpipeY);
                    translate([motorX(numOutlets-1),outletDownpipeY,0])
                        RoundTopCylinder(d=outletDownpipeY, h=outletDownpipeY);

                    translate([motorX(0),outletDownpipeY,0])
                        RoundTopCylinder(d=outletDownpipeY, h=outletDownpipeY);
                    translate([motorX(numOutlets-1),outletDownpipeY,0])
                        RoundTopCylinder(d=outletDownpipeY, h=outletDownpipeY);
                    
                    translate([outletHoseX(1, numInlets, numOutlets),ioY,0])
                        RoundTopCylinder(d=outletDownpipeY, h=outletDownpipeY);
                    translate([outletHoseX(numOutlets, numInlets, numOutlets),ioY,0])
                        RoundTopCylinder(d=outletDownpipeY, h=outletDownpipeY);
                    
                }
                if (inletsOnOppositeSideToOutlets)
                {
                    hull()
                    {
                        translate([motorX(0),0,0])
                            RoundTopCylinder(d=outletDownpipeY, h=outletDownpipeY);
                        translate([motorX(numOutlets-1),0,0])
                            RoundTopCylinder(d=outletDownpipeY, h=outletDownpipeY);

                        translate([inletHoseX(1, numInlets, numOutlets),-ioY,0])
                            RoundTopCylinder(d=outletDownpipeY, h=outletDownpipeY);
                        translate([inletHoseX(numInlets, numInlets, numOutlets),-ioY,0])
                            RoundTopCylinder(d=outletDownpipeY, h=outletDownpipeY);
                    }
                }
            }


            for (outletNumber = [1:numOutlets])
            {
                x = outletHoseX(outletNumber, numInlets, numOutlets);
                translate([x,ioY,0])
                    HoseConnectorOuter(hoseThreadLength);
            }

            for (inletNumber = [1:numInlets])
            {
                x = inletHoseX(inletNumber, numInlets, numOutlets);
                y = inletsOnOppositeSideToOutlets ? -ioY:ioY;
                
                translate([x,y,0])
                    HoseConnectorOuter(hoseThreadLength);
            }

        }
        union()
        {
            FluidPathways(numInlets, numOutlets, ioY, hoseThreadLength);
            MountingHoleSet(numInlets, numOutlets, ioY);
        }
    }
}

module RoundedCornerCube(width, height, thickness, cornerRadius)
{
    translate([cornerRadius,cornerRadius,0])
        cylinder(r=cornerRadius,h=thickness);
    translate([width-cornerRadius,cornerRadius,0])
        cylinder(r=cornerRadius,h=thickness);
    translate([width-cornerRadius,height-cornerRadius,0])
        cylinder(r=cornerRadius,h=thickness);
    translate([cornerRadius,height-cornerRadius,0])
        cylinder(r=cornerRadius,h=thickness);
    translate([cornerRadius,0,0])
        cube([width-2*cornerRadius,height,thickness]);
    translate([0,cornerRadius,0])
        cube([width,height-2*cornerRadius,thickness]);
    
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
                    RoundedCornerCube(22, 15, motorPlateThickness, 4);
            }
            if (addRightFoot)
            {
                translate([-4,-4,0])
                    RoundedCornerCube(22, 15, motorPlateThickness, 4);
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
    turretHeight = 4;
    
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
            
            // The tapped holes in the motor are too short for the common screw legths I happen to have
            // Add on turrets for each scre below the plate to pack them out
            
            screw_spacing = nema_motor_screw_spacing(size=17);
            
            for (motor = [0:numOutlets-1])
            {
                motorX = motor * motorShaftSpacing;
                translate([motorX,0,-turretHeight])
                    xspread(screw_spacing) 
                    {
                        yspread(screw_spacing) 
                        {
                            cylinder(h=turretHeight,d=8);
                        }
                    }
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
                translate([motorX,0,0])
                    nema_mount_holes(size=17, depth=motorPlateThickness+2*turretHeight+2*epsilon, l=0, align = V_CENTER);
            }
        }
    }
    
}

module Assembly(numInlets = 2, numOutlets = 2)
{
    color("cyan")
        NWayManifold(numInlets, numOutlets);
    
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
                TapGland1908F();

    }
}

module HoleClashChecker()
{
    numInlets=1;
    numOutlets=2;
    ioY=50;
    hoseThreadLength=11;
    FluidPathways(numInlets, numOutlets, ioY, hoseThreadLength);
    MountingHoleSet(numInlets, numOutlets, ioY);
}

//Assembly();

//HoleClashChecker();


NWayManifold(numInlets = 2, numOutlets = 4);



