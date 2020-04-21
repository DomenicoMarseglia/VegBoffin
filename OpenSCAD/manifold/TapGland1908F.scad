// This is an OpenSCAD model of a Srewfix Flomasta 1908F Ceramic tap gland
// https://www.screwfix.com/p/flomasta-ceramic-tap-glands-24mm-x-2-pack/1908f
// It is not meant to be 3d printed, is is only meant as a visual aid in assembly models


use <bsp_threads.scad>


epsilon = 0.01;




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


module TapGland1908F()
{
    color("gold")
    difference()
    {
        union()
        {
            translate([0,0,21.5-8])
                HalfInchBspThread(length=8, internal=false);
            
            cylinder(h=21.5,d=18.2);
            
            translate([0,0,21.5])
                cylinder(d=23.75,h=3);
            
            translate([0,0,24.5])
                cylinder(d=22,h=7);
            
            translate([0,0,31.5])
                cylinder(d=19,h=6,$fn=6); 
            
            translate([0,0,37.5])
                cylinder(d=10,h=2);   
            
            cylinder(d=6.4,h=50);
            
            translate([0,0,50-9])
            SplinedCylinder(h=9,d1=7.2,d2=7.6,numSplines=20);
        }
        union()
        {
            translate([6,-10,8])
                cube([5,20,4.5]);
            translate([-6-5,-10,8])
                cube([5,20,4.5]);
            translate([0,0,-epsilon])
                cylinder(d=11,h=12);
        }
    }

    translate([0,0,-1])
        color("red")
            difference()
            {
                union()
                {

                    cylinder(d=18,h=1);

                }
                union()
                {
                    translate([0,0,-epsilon])
                        cylinder(d=11,h=1+2*epsilon);
                }
            }
}


TapGland1908F();

