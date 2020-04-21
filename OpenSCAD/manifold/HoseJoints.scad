$fn = 20;

epsilon = 0.1;

jointOuterDiameter = 13;
jointInnerDiameter = 8;
jointFlaredDiameter = 15;

spigotLength = 15;
module Spigot()
{
    difference()
    {
        union()
        {
            cylinder(h=spigotLength,d=jointOuterDiameter);
            translate([0,0,7])
            cylinder(h=6,d1=jointFlaredDiameter,d2=jointOuterDiameter);
            
        }
        union()
        {
            translate([0,0,-epsilon])
            cylinder(h=spigotLength+2*epsilon,d=jointInnerDiameter);
        }
        
    }
    
}

bendRadius = 12;


module LittleH(diameter, bendRadius, armLength, addBarbs, barbDiameter, barbHeight, barbInset)
{

    
    
    rotate([90,0,0])
        rotate_extrude(convexity=10, angle=90) translate(v=[bendRadius,0,0]) circle(d=diameter); 

    translate([0,0,bendRadius*2])
        rotate([-90,0,0])
            rotate_extrude(convexity=10, angle=180) translate(v=[bendRadius,0,0]) circle(d=diameter); 
    translate([bendRadius,0,-armLength])
            cylinder(h=bendRadius*2+2*armLength,d=diameter);
    translate([-bendRadius,0,2*bendRadius])
            cylinder(h=armLength,d=diameter);
    
    if (addBarbs)
    {
        translate([bendRadius,0,-(armLength-barbInset)])
            cylinder(d1=diameter, d2=barbDiameter,  h=barbHeight);
        
        translate([bendRadius,0,2*bendRadius + armLength-barbInset-barbHeight])
            cylinder(d2=diameter, d1=barbDiameter,  h=barbHeight);
        
        translate([-bendRadius,0,2*bendRadius + armLength-barbInset-barbHeight])
            cylinder(d2=diameter, d1=barbDiameter,  h=barbHeight);
    }
}



module BigH(diameter, bendRadius, armLength, addBarbs, barbDiameter, barbHeight, barbInset)
{
    difference()
    {
        union()
        {
            translate([-bendRadius,-diameter/2,0])
                cube([2*bendRadius,diameter,bendRadius]);
        }
        union()
        {
            translate([0,(diameter+2*epsilon)/2,0])
            rotate([90,0,0])
                cylinder(r=bendRadius,h=diameter+2*epsilon);
        }
    }

    translate([0,0,2*bendRadius])
    rotate([0,180,0])
    difference()
    {
        union()
        {
            translate([-bendRadius,-diameter/2,0])
                cube([2*bendRadius,diameter,bendRadius]);
        }
        union()
        {
            translate([0,(diameter+2*epsilon)/2,0])
            rotate([90,0,0])
                cylinder(r=bendRadius,h=diameter+2*epsilon);
        }
    }

    
    rotate([90,0,0])
        rotate_extrude(convexity=10, angle=180) translate(v=[bendRadius,0,0]) circle(d=diameter); 

    translate([0,0,bendRadius*2])
        rotate([-90,0,0])
            rotate_extrude(convexity=10, angle=180) translate(v=[bendRadius,0,0]) circle(d=diameter); 
    translate([bendRadius,0,-armLength])
            cylinder(h=bendRadius*2+2*armLength,d=diameter);
    translate([-bendRadius,0,-armLength])
            cylinder(h=bendRadius*2+2*armLength,d=diameter);
    
    if (addBarbs)
    {
        translate([bendRadius,0,-(armLength-barbInset)])
            cylinder(d1=diameter, d2=barbDiameter,  h=barbHeight);
        
        translate([-bendRadius,0,-(armLength-barbInset)])
            cylinder(d1=diameter, d2=barbDiameter,  h=barbHeight);
        
        translate([bendRadius,0,2*bendRadius + armLength-barbInset-barbHeight])
            cylinder(d2=diameter, d1=barbDiameter,  h=barbHeight);
        
        translate([-bendRadius,0,2*bendRadius + armLength-barbInset-barbHeight])
            cylinder(d2=diameter, d1=barbDiameter,  h=barbHeight);
    }
}


module HJoint()
{
    intersection()
    {
        difference()
        {
            union()
            {
                rotate([90,0,0])
                     rotate_extrude(convexity=10, angle=90) translate(v=[bendRadius,0,0]) circle(d=jointOuterDiameter); 

                translate([0,0,bendRadius*2])
                    rotate([-90,0,0])
                        rotate_extrude(convexity=10, angle=180) translate(v=[bendRadius,0,0]) circle(d=jointOuterDiameter); 
 //               translate([-15,0,0])
  //                  cylinder(h=30,d=jointOuterDiameter);
                translate([bendRadius,0,0])
                    cylinder(h=30,d=jointOuterDiameter);
                
                
            }
            union()
            {
                rotate([90,0,0])
                     rotate_extrude(convexity=10, angle=90) translate(v=[bendRadius,0,0]) circle(d=jointInnerDiameter); 

                translate([0,0,bendRadius*2])
                    rotate([-90,0,0])
                        rotate_extrude(convexity=10, angle=180) translate(v=[bendRadius,0,0]) circle(d=jointInnerDiameter); 
                
                                
  //              translate([-15,0,0])
  //                  cylinder(h=30,d=jointInnerDiameter);
                translate([bendRadius,0,0])
                    cylinder(h=30,d=jointInnerDiameter);
            }
        }
        translate([-30,-30,0])
            cube([60,60,30]);
    }
    
//    translate([-15,0,0])
//    rotate([180,0,0])
 //       Spigot();
    translate([bendRadius,0,0])
        rotate([180,0])
        Spigot();
    
    translate([-bendRadius,0,bendRadius*2])
    
        Spigot();
    translate([bendRadius,0,bendRadius*2])
        Spigot();
}

module LittleHJoint()
{
    difference()
    {
    
        LittleH(jointOuterDiameter,12,12,true, jointFlaredDiameter,4,2);
        LittleH(jointInnerDiameter,12,12+epsilon,false, jointFlaredDiameter,4,2);
    }
}

module BigHJoint()
{
    difference()
    {
    
        BigH(jointOuterDiameter,12,12,true, jointFlaredDiameter,4,2);
        BigH(jointInnerDiameter,12,12+epsilon,false, jointFlaredDiameter,4,2);
    }
}


/*
intersection()
{
LittleHJoint();
//translate([0,5,15])
//rotate([-90,0,0])
//cylinder(d=3,h=10);

//translate([0,25,15])
//rotate([-90,0,0])
//cylinder(d=3,h=10);


//HJoint();
//translate([0,20,0])
//HJoint();
//translate([0,40,0])
//HJoint();
   // HJoint();
    translate([-50,0,-50])
    cube([100,100,100]);
}
*/


module LittleHJointPairForPrinting()
{
    rotate([0,180,0])
    LittleHJoint();
}

BigHJoint();