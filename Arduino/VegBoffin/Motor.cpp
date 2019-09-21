#include <Arduino.h>
#include "Motor.h"

const int Motor::_fullTravelPulses = 1600;

Motor::Motor(int dirPinIndex, int stepPinIndex, int enPinIndex, bool reverseDirection, uint16_t * pOutputImages)
{
  _stepPinIndex = stepPinIndex;
  _dirPinIndex=dirPinIndex;
  _enPinIndex=enPinIndex;
  _currentStepState = false;    
  _reverseDirection = reverseDirection;
  _targetPosition = 0;
  _currentPosition = _fullTravelPulses;
  _seekingInitialHome = true;
//  _last_step_time = 0;
  _pOutputImages = pOutputImages;
}

void Motor::setup()
{
}

void Motor::loop()
{
//    unsigned long currentMicros = micros();
//    if((currentMicros-_last_step_time>=7000))
//    { 
      if (_seekingInitialHome)
      {
          StepBackwards();
          if (_currentPosition>0)
          {
            --_currentPosition;
          }
          else
          {
            _seekingInitialHome = false;
            SetIdle();
          }
      }
      else
      {
        if (_currentPosition > _targetPosition)
        {
          StepBackwards();
          --_currentPosition;
        }
        else if (_currentPosition < _targetPosition)
        {
          StepForwards();
          ++_currentPosition;
        }
        else
        {
          SetIdle();
        }
      }
      
  //    _last_step_time=micros();
  //  }
    
      
}

void Motor::Open()
{
  if (!_seekingInitialHome)
  {
    _targetPosition = 0;
  }
}

void Motor::Close()
{
  if (!_seekingInitialHome)
  {
    _targetPosition = _fullTravelPulses;
  }
}

void Motor::StepForwards()
{

  SetOutputInImage(_enPinIndex, LOW);
  SetOutputInImage(_dirPinIndex, !_reverseDirection);
  _currentStepState = !_currentStepState;
  SetOutputInImage(_stepPinIndex, _currentStepState);

}

void Motor::StepBackwards()
{
  SetOutputInImage(_enPinIndex, LOW);
  SetOutputInImage(_dirPinIndex, _reverseDirection);
  _currentStepState = !_currentStepState;
  SetOutputInImage(_stepPinIndex, _currentStepState);
}
 
void Motor::SetIdle()
{
  SetOutputInImage(_enPinIndex, HIGH);
}

void Motor::SetPosition(float percentOpen)
{
  if (!_seekingInitialHome)
  {
    _targetPosition = (int)(_fullTravelPulses * percentOpen / 100.0F);
  }
}
void Motor::SetOutputInImage(int index, bool state)
{
  uint16_t mask = 1 << index;
  if (state)
  {
    * _pOutputImages |= mask;
  }
  else
  {
    * _pOutputImages &= (~mask);
  }

}
