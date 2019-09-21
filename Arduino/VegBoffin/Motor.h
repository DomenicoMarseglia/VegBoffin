#ifndef __MOTOR_H__

#define __MOTOR_H__
#include <Arduino.h>

class Motor
{
  private:
    int _enPinIndex;
    int _dirPinIndex;
    int _stepPinIndex;
    bool _currentStepState;
    bool _reverseDirection;
    int _targetPosition;
    int _currentPosition;
    bool _seekingInitialHome;
//    unsigned long _last_step_time;
    uint16_t * _pOutputImages;

    void SetOutputsForStep(byte step);
    static const int _fullTravelPulses;

    void StepForwards();
    void StepBackwards();
    void SetIdle();

  
  public:
    Motor(int Pin1, int Pin2, int Pin3, bool reverseDirection, uint16_t * pOutputImages);  
    void setup();
    void loop();
    void Open();
    void Close();
    void SetPosition(float percentOpen);
    void SetOutputInImage(int index, bool state);
};
#endif
