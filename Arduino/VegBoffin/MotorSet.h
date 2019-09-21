#ifndef __MOTOR_SET_H__
#define __MOTOR_SET_H__

#include "Motor.h"
#include <Arduino.h>
#include "Adafruit_MCP23017.h"

#define MCP23017


class MotorSet
{
  private:
    static const int _numMotors = 4;
    uint16_t _outputImages;
    uint16_t _oldOutputImages;
    Motor * pMotor[_numMotors];
#ifdef MCP23017    
    Adafruit_MCP23017 _mcp;
#endif    
    unsigned long _last_step_time;
   static const byte _fullTravelPulses;
  public:
    MotorSet();
    void SetMotorPosition(int motorIndex, float percentPosition);
    void setup();
    void loop();
};
#endif
