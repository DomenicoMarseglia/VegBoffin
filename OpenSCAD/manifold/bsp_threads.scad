

include <BOSL/constants.scad>
use <BOSL/threading.scad>


epsilon = 0.01;


module HalfInchBspThread(length, internal)
{
    mmPerInch = 25.4;
    threadsPerInch = 14;
    majorThreadDiameterInches = 0.8250;
    minorThreadDiameterInches = 0.7335;
    majorDiameter = majorThreadDiameterInches * mmPerInch;
    minorDiameter = minorThreadDiameterInches * mmPerInch;
    pitch = mmPerInch / threadsPerInch;
    threadDepth = (majorDiameter - minorDiameter)/2;

    threaded_rod(d=majorDiameter, l=length,pitch = pitch, align = V_TOP, internal = internal);
}

module ThreeQuaterInchBspThread(length, internal)
{
    mmPerInch = 25.4;
    threadsPerInch = 14;
    majorThreadDiameterInches = 1.0410;
    minorThreadDiameterInches = 0.9495;
    majorDiameter = majorThreadDiameterInches * mmPerInch;
    minorDiameter = minorThreadDiameterInches * mmPerInch;
    pitch = mmPerInch / threadsPerInch;
    threadDepth = (majorDiameter - minorDiameter)/2;

    threaded_rod(d=majorDiameter, l=length,pitch = pitch, align = V_TOP, internal = internal);
}

