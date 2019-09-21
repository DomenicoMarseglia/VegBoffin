#include <Arduino.h>
#include "MotorSet.h"

  
MotorSet::MotorSet()
{
    _last_step_time = 0;
}

void MotorSet::setup()
{
#ifdef MCP23017   
  Wire.begin(21,22,100000);
  _mcp.begin(0);
#else
   
#endif
  _outputImages = 0;
  _oldOutputImages = 0;

#ifdef MCP23017 
  for (int i=0;i<16;++i)
  {
    _mcp.pinMode(i, OUTPUT);
  }
#endif

  pMotor[0]=new Motor(0,1,2, false,&_outputImages);
  pMotor[1]=new Motor(3,4,5, true, &_outputImages);
  pMotor[2]=new Motor(6,7,8, false, &_outputImages);
  pMotor[3]=new Motor(9,10,11, true, &_outputImages);
  
  for (int i=0;i<_numMotors;++i)
  {
    pMotor[i]->setup(); 
  }
  Serial.print("MotorSet::MotorSet Complete\n");  
  
}

void MotorSet::loop()
{
    unsigned long currentMicros = micros();
    if((currentMicros-_last_step_time>=2000))
    { 
      for (int i=0;i<_numMotors;++i)
      {
        pMotor[i]->loop(); 
      }
    
#ifdef MCP23017 
    _mcp.writeGPIOAB(_outputImages);
#endif      
      _last_step_time=micros();
    }

  
}

void MotorSet::SetMotorPosition(int motorIndex, float percentPosition)
{
  pMotor[motorIndex]->SetPosition(percentPosition);
}
