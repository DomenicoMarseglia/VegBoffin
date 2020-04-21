use <bsp_threads.scad>

$fn = 200;

epsilon = 0.1;

jointOuterDiameter = 12;
jointInnerDiameter = 8;
jointFlaredDiameter = 14;
spigotShoulderHeight = 4;

module Spigot()
{
    difference()
    {
        union()
        {
            for (i=[0:2])
            {
                translate([0,0,(i*8)])
                    cylinder(h=15,d=jointOuterDiameter);
                translate([0,0,15+(i*8)])
                    cylinder(h=6,d1=jointFlaredDiameter,d2=jointOuterDiameter);
            }
            cylinder(h=spigotShoulderHeight,d=23);
            translate([0,0,spigotShoulderHeight])
                cylinder(h=2,d1=jointFlaredDiameter+2,d2=jointFlaredDiameter);
        }
        union()
        {
            translate([0,0,-epsilon])
            {
                cylinder(d=jointInnerDiameter,h=50+2*epsilon);
            }
        }
    }
    
}

module BackNut()
{
    maleThreadLength = 11;
    capThickness = 4;
    washerThickness = 2;

    nutHeight = maleThreadLength+spigotShoulderHeight+capThickness;
    difference()
    {
        union()
        {
            cylinder(h=nutHeight,d=34);
            
            //cylinder(h=nutHeight,d=40,$fn=6);
        }
        union()
        {
            translate([0,0,-epsilon])
            {
                numGrips = 12;
                for (i=[0:numGrips-1])
                {
                    rotate([0,0,i*360/numGrips])
                        translate([18,0,0])
                            cylinder(d=4,h=nutHeight+2*epsilon);
                }
                
                ThreeQuaterInchBspThread(maleThreadLength+spigotShoulderHeight, internal=true);
                cylinder(d=jointFlaredDiameter+1,h=nutHeight+2*epsilon);
            }
            translate([0,0,maleThreadLength+spigotShoulderHeight])
                cylinder(h=2,d1=jointFlaredDiameter+2,d2=jointFlaredDiameter);
        }
    }
}

module BlankingCap()
{
    maleThreadLength = 11;
    capThickness = 4;
    washerThickness = 2;

    nutHeight = maleThreadLength+capThickness;
    difference()
    {
        union()
        {
            cylinder(h=nutHeight,d=34);
            
            //cylinder(h=nutHeight,d=40,$fn=6);
        }
        union()
        {
            translate([0,0,-epsilon])
            {
                numGrips = 12;
                for (i=[0:numGrips-1])
                {
                    rotate([0,0,i*360/numGrips])
                        translate([18,0,0])
                            cylinder(d=4,h=nutHeight+2*epsilon);
                }
                
                ThreeQuaterInchBspThread(maleThreadLength+spigotShoulderHeight, internal=true);
            }
        }
    }
}

BlankingCap();

//BackNut();

//translate([0,0,-50])
//Spigot();

//translate([0,0,-70])
//Washer6039J();