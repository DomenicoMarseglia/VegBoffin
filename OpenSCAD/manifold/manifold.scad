
include <BOSL/constants.scad>
use <BOSL/threading.scad>
use <BOSL/nema_steppers.scad>


$fn = 40;

use <valve1908F.scad>
use <bsp_threads.scad>


epsilon = 0.01;

// The intended screw is a 3x12 countersunk wood screw 

assemblyScrewTapHoleDiameter = 2.5;
assemblyScrewClearHoleDiameter = 3.2;
assemblyScrewLength = 12;

screwHoleInset = 6;



manifoldWidth = 30;   
manifoldHeight = 32;


motorBracketWidth = 30;
motorBracketDepth = 42;


sliceWidth = 40;


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


module FourScrewHoleSet(xSpacing,ySpacing,diameter,depth)
{
    translate([xSpacing/2,ySpacing/2,-depth])
        cylinder(d=diameter,h=depth+epsilon);
    translate([-xSpacing/2,ySpacing/2,-depth])
        cylinder(d=diameter,h=depth+epsilon);
    translate([xSpacing/2,-ySpacing/2,-depth])
        cylinder(d=diameter,h=depth+epsilon);
    translate([-xSpacing/2,-ySpacing/2,-depth])
        cylinder(d=diameter,h=depth+epsilon);
}


module BracketScrewHoleSet(xSpacing,ySpacing)
{
    for(i = [ [xSpacing/2,ySpacing/2,  0],
              [-xSpacing/2,ySpacing/2, 0],
              [xSpacing/2,-ySpacing/2, 0],
              [-xSpacing/2,-ySpacing/2, 0] ])
    {
        translate(i)
            translate([0,0,-assemblyScrewLength])
                cylinder(d=assemblyScrewClearHoleDiameter,h=assemblyScrewLength+epsilon);
        translate(i)
            translate([0,0,-5.5])
                cylinder(d1=0,d2=5.5,h=5.5+epsilon);
    }
}


module NWayManifold(numOutlets = 4)
{
    // The turret depth is dictated by the width of the mounting points on the motor
    turretDepth = 42;
    ioSpacing = 40;
    wormHoleZ = 6;
    
    turretWidth =  motorBracketWidth + (numOutlets/2-1) * ioSpacing;
    

    
    
    turretHeight = 32;
    ioHeight = 2*wormHoleZ;
    
    spigotZOffset = 8;

    boreDiameter = 6;
    bendRadius = 5;
    
    manifoldWidth = sliceWidth * (numOutlets +1);
        
    hoseThreadLength = 11;
    
    ioY = turretDepth +  ioSpacing/2;
    outletDrainY = 36;
    
    cavityDrainDepth = 18;
    
    screwHoleDepth = 12;
    
    mainWidth = numOutlets * ioSpacing + motorBracketWidth;
    mainXShift = (ioSpacing - motorBracketWidth)/2;
            
    difference()
    {
        union()
        {

            
            translate([mainXShift,0,0])
            {
                cube ([turretWidth,turretDepth,turretHeight]);
                cube ([turretWidth,turretDepth/2 +  ioSpacing/2 , ioHeight]);
            }
            
            translate([mainXShift,turretDepth/2-wormHoleZ,0])
            {
                cube ([mainWidth,turretDepth/2 +  ioSpacing/2 +wormHoleZ, ioHeight]);
            }
            
            translate([mainWidth + mainXShift - turretWidth,0,0])
            {
                cube ([turretWidth,turretDepth,turretHeight]);
                cube ([turretWidth,turretDepth +  ioSpacing/2 , ioHeight]);
            }
            
            // hose connectors,
            // note n+1 count since this is n outlets + 1 inlet
            for (slice = [0:numOutlets])
            {
                translate([slice * sliceWidth + sliceWidth/2,ioY,ioHeight])
                    ThreeQuaterInchBspThread(hoseThreadLength, internal=false);
                translate([slice * sliceWidth + sliceWidth/2,ioY,0])
                    cylinder(d2=25, d1=0,h=ioHeight);
            }

        }
        union()
        {
            translate([mainXShift-epsilon,turretDepth/2-wormHoleZ,0])
            {
                rotate([120,0,0])
                    cube ([mainWidth+2*epsilon,50, 50]);
            }
            
            // cones in hose connectors,
            // note n+1 count since this is n outlets + 1 inlet
            for (slice = [0:numOutlets])
            {
                translate([slice * sliceWidth + sliceWidth/2,ioY,ioHeight+epsilon])
                    cylinder(h=hoseThreadLength/2+2*epsilon, d1=boreDiameter, d2=20);
                translate([slice * sliceWidth + sliceWidth/2,ioY,ioHeight+epsilon+hoseThreadLength/2])
                    cylinder(h=hoseThreadLength/2+2*epsilon, d=20);
            }

            for (slice = [0:numOutlets-1])
            {
                x = slice * sliceWidth + sliceWidth/2 + ( (slice>= numOutlets/2) ? sliceWidth : 0);
                
                translate([x,turretDepth/2,turretHeight])
                FourScrewHoleSet(motorBracketWidth-2*screwHoleInset,motorBracketDepth-2*screwHoleInset,assemblyScrewTapHoleDiameter,screwHoleDepth);
                
                translate([x,turretDepth/2,0])
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
            }
           
           // Outlet bores 
           for (slice = [0:numOutlets-1])
           {
                x = slice * sliceWidth + sliceWidth/2 + ( (slice>= numOutlets/2) ? sliceWidth : 0);
                
                translate([x,outletDrainY,wormHoleZ])
                    rotate([0,-90,90])
                        SimpleElbow(boreDiameter, bendRadius);
                translate([x,ioY,wormHoleZ])
                    rotate([0,180,90])
                        SimpleElbow(boreDiameter, bendRadius);
                translate([x,ioY,bendRadius+wormHoleZ-epsilon])
                    cylinder(d=boreDiameter, h=50+epsilon);
                translate([x,outletDrainY+bendRadius-epsilon,wormHoleZ])
                    rotate([-90,0,0])
                    cylinder(d=boreDiameter, h=ioY-outletDrainY-2*bendRadius+2*epsilon);
                
                translate([x,outletDrainY,wormHoleZ+bendRadius-epsilon])
                    cylinder(d=boreDiameter, h=turretHeight-2*bendRadius-cavityDrainDepth+2*epsilon);
                translate([x,outletDrainY,turretHeight+bendRadius-cavityDrainDepth])
                    rotate([0,90,90])
                        SimpleElbow(boreDiameter, bendRadius);
            }
            
            // Inlet bore
            
            // first inlet downpipe and elbow
            translate([sliceWidth/2 ,turretDepth/2,0])
            {
                translate([0 ,0, wormHoleZ])
                    rotate([0,-90,0])
                        SimpleElbow(boreDiameter, bendRadius);
                translate([0,0,wormHoleZ-epsilon+bendRadius])
                    cylinder(d=boreDiameter, h=50+epsilon);
            }
            
            // last inlet downpipe and elbow
            translate([sliceWidth/2 + numOutlets*sliceWidth,turretDepth/2,0])
            {
                translate([0 ,0, wormHoleZ])
                    rotate([0,180,0])
                        SimpleElbow(boreDiameter, bendRadius);    
                translate([0,0,wormHoleZ-epsilon+bendRadius])
                    cylinder(d=boreDiameter, h=50+epsilon);
            }
    
            if (numOutlets > 2)
            {
                
                // down pipes for inner inlets
                for (slice = [1:numOutlets-2])
                {
                    x = slice * sliceWidth + sliceWidth/2 + ( (slice>= numOutlets/2) ? sliceWidth : 0);
                    translate([x,turretDepth/2,wormHoleZ-epsilon])
                        cylinder(d=boreDiameter, h=50+epsilon);
                }
           
            }
            // connector pipe between inlets
            translate([sliceWidth/2+bendRadius ,turretDepth/2,wormHoleZ])
                rotate([0,90,0])
                    cylinder(d=boreDiameter, h=numOutlets*sliceWidth-2*bendRadius+2*epsilon);
            
            inletX = sliceWidth/2 +  sliceWidth * numOutlets/2;
            

                translate([inletX,ioY,wormHoleZ])
                    rotate([0,180,90])
                        SimpleElbow(boreDiameter, bendRadius);
                translate([inletX,ioY,bendRadius+wormHoleZ-epsilon])
                    cylinder(d=boreDiameter, h=50+epsilon);
                translate([inletX,turretDepth/2-epsilon,wormHoleZ])
                    rotate([-90,0,0])
                    cylinder(d=boreDiameter, h=ioY-turretDepth/2-bendRadius+2*epsilon);

        }
    }

    
}

module Nema17PlateBracket()
{
 
    bracketHeight = 52;
    
    bracketThickness = 3;
    topShelfWidth = 10;
    
    bodgyOffset = 16;
    
    difference()
    {
        union()
        {
            translate([-motorBracketWidth/2-bodgyOffset,-motorBracketDepth/2,0])
                cube([motorBracketWidth+bodgyOffset,10,bracketThickness]);
            translate([-motorBracketWidth/2-bodgyOffset,-motorBracketDepth/2,0])
                cube([topShelfWidth,bracketThickness,bracketHeight]);
            
            translate([-motorBracketWidth/2-bodgyOffset,motorBracketDepth/2-10,0])
                cube([manifoldWidth+bodgyOffset,10,bracketThickness]);
            translate([-motorBracketWidth/2-bodgyOffset,motorBracketDepth/2-bracketThickness,0])
                cube([topShelfWidth,bracketThickness,bracketHeight]);
            
            translate([-motorBracketWidth/2-bodgyOffset,-motorBracketDepth/2,bracketHeight-bracketThickness])
                cube([topShelfWidth,motorBracketDepth,bracketThickness]);
            
            translate([-motorBracketWidth/2-bodgyOffset,-motorBracketDepth/2,bracketHeight-13])
                cube([topShelfWidth,7,13]);
            
            translate([-motorBracketWidth/2-bodgyOffset,motorBracketDepth/2-7,bracketHeight-13])
                cube([topShelfWidth,7,13]);
        }
        union()
        {
            translate([0,0,-epsilon])
                cylinder(h=bracketThickness + 2*epsilon,d=27);
            
            translate([-26,17,bracketHeight-bracketThickness-epsilon])
                cylinder(d=assemblyScrewTapHoleDiameter,h=10);
            translate([-26,-17,bracketHeight-bracketThickness-epsilon])
                cylinder(d=assemblyScrewTapHoleDiameter,h=10);
            
            screwHoleDepth = 10;
            screwHoleDiameter = 3;
            
            translate([0,0,bracketThickness+epsilon])
            BracketScrewHoleSet(motorBracketWidth-2*screwHoleInset,motorBracketDepth-2*screwHoleInset);
        }
    }
}

module Nema17MotorPlate(numOutlets = 2)
{
    plateThickness = 3;
    difference()
    {
        union()
        {
            translate([-1,0,0])
                cube([122,42,plateThickness]);
        }
        union()
        {
            for (slice = [0:numOutlets-1])
            {
                x = slice * sliceWidth + sliceWidth/2 + ( (slice>= numOutlets/2) ? sliceWidth : 0);
                translate([x,motorBracketDepth/2,plateThickness/2])
                    nema_mount_holes(size=17, depth=plateThickness+2*epsilon, l=0);
            }
            translate([60,21,plateThickness+epsilon])
                BracketScrewHoleSet(28,34);
            
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
    
    for (slice = [0:numOutlets-1])
    {
        x = slice * sliceWidth + sliceWidth/2 + ( (slice>= numOutlets/2) ? sliceWidth : 0);

        theta = (slice>= numOutlets/2) ? 0 : 180;
        
        translate([x,motorBracketDepth/2,54])
            color("cyan")
                NemaMotorTapJoint();

        translate([x,motorBracketDepth/2,11])
            Valve1908F();

        translate([x,motorBracketDepth/2,87])
            rotate([0,180,0])
                nema17_stepper(shaft_len=22);

        translate([x,motorBracketDepth/2,manifoldHeight])
            rotate([0,0,theta])
                color("cyan")
                    Nema17PlateBracket();
    }
}


Assembly();




