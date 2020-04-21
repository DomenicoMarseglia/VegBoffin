$fn = 100;

epsilon = 0.1;

jointOuterDiameter = 13;
jointInnerDiameter = 8;
jointFlaredDiameter = 15;


module Spigot()
{
            for (i=[0:2])
            {
                translate([0,0,(i*8)])
                    cylinder(h=15,d=jointOuterDiameter);
                translate([0,0,15+(i*8)])
                    cylinder(h=6,d1=jointFlaredDiameter,d2=jointOuterDiameter);
            }
}


module EndCapWithSpike()
{
    difference()
    {
        union()
        {
            Spigot();
            
            translate([-jointOuterDiameter/2,0,0])
                cube([jointOuterDiameter,100,8]);

            intersection()
            {
                translate([-50,0,0])
                    cube([100,150,8]);
                {
                    for (i=[1:5])
                    {
                        translate([0,20*i,0])
                            rotate([-90,0,0])
                                cylinder(h=30,d1=30,d2=5);
                    }
                }
            }
        }
        union()
        {

        }
        
    }
}

module EndCapWithBracket()
{
    standoff = 12;
    
    difference()
    {
        union()
        {
            Spigot();
            
            translate([-jointOuterDiameter /2,0,0])
                cube([jointOuterDiameter,standoff,10]);

            translate([-(jointOuterDiameter + 20)/2,standoff,0])
                cube([jointOuterDiameter+20,5,10]);
            
        }
        union()
        {
            for (i=[0,1])
                translate([-jointOuterDiameter /2 - 5 + (jointOuterDiameter + 10)*i,standoff-epsilon,5])
                    rotate([-90,0,0])
                        {
                            cylinder(d=3.5,h=5+2*epsilon);
                            cylinder(d1=7,d2=3.5,h=5+2*epsilon);
                        }

        }
        
    }
}


EndCapWithSpike();

//EndCapWithBracket();