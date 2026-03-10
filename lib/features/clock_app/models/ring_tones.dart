// قائمة النغمات المتاحة
  import 'package:clock_app/core/constants/assets.dart';

final List<Map<String, String>> _ringtones = [
    {'name': 'Default Ringtone', 'path': Assets.assetsAudioAlarm},
    {'name': 'Morning Birds', 'path': Assets.assetsAudioAlarmSound},
    {'name': 'Loud Alarm', 'path': Assets.assetsAudioBasicAlarmRingtone},
    {'name': 'Creep Music', 'path': Assets.assetsAudioCreepMusicForStrictAndHardy},
    {'name': 'Trumpets', 'path': Assets.assetsAudioEveryoneTrumpetsForYouToGetOutOfBed},
    {'name': 'Nature Sounds', 'path': Assets.assetsAudioForThoseWhoLikeToGetUpToTheSoundsOfNatureAndBirds},
    {'name': 'Good Morning', 'path': Assets.assetsAudioGoodMorning},
  
  ];
  
  List<Map<String, String>> get ringtones => _ringtones;