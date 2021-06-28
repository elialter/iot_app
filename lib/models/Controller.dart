import 'dart:ui';
typedef VoidCallbackBoolParam = void Function(bool value);


class CoverController {
  VoidCallbackBoolParam changeSwitch;

  void dispose() {
    //Remove any data that's will cause a memory leak/render errors in here
    changeSwitch = null;
  }
}
