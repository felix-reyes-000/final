import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewRequestDialogWidget extends StatefulWidget {
  final int orderId;

  const NewRequestDialogWidget({super.key, required this.orderId});

  @override
  State<NewRequestDialogWidget> createState() => _NewRequestDialogWidgetState();
}

class _NewRequestDialogWidgetState extends State<NewRequestDialogWidget> {
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _startAlarm();
  }

  @override
  void dispose() {
    _stopAlarm();
    super.dispose();
  }

  Future<void> _startAlarm() async {
    try {
      await _audioPlayer.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.notificationRingtone,
          audioFocus: AndroidAudioFocus.gainTransientExclusive,
        ),
      ));

      _isPlaying = true;
      await _audioPlayer.play(AssetSource('order_notification.wav'));
      
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        if (_isPlaying) {
          await _audioPlayer.play(AssetSource('order_notification.wav'));
        }
      });
    } catch (e) {
      print('Error playing audio: $e');
      // Fallback to default audio output
      try {
        await _audioPlayer.setAudioContext(AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.notificationRingtone,
            audioFocus: AndroidAudioFocus.gainTransientExclusive,
          ),
        ));
        _isPlaying = true;
        await _audioPlayer.play(AssetSource('order_notification.wav'));
      } catch (fallbackError) {
        print('Error playing audio through default output: $fallbackError');
      }
    }
  }

  Future<void> _stopAlarm() async {
    _isPlaying = false;
    _timer?.cancel();
    try {
      await _audioPlayer.stop();
      await _audioPlayer.dispose();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(Images.notificationIn, height: 60, color: Theme.of(context).primaryColor),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Text(
                'new_order_placed'.tr,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
            ),
            CustomButtonWidget(
              height: 40,
              buttonText: 'accept'.tr,
              onPressed: () async {
                await _stopAlarm();
                if(Get.isDialogOpen!) {
                  Get.back();
                }
                Get.offAllNamed(RouteHelper.getOrderDetailsRoute(widget.orderId, fromNotification: true));
              },
            ),
          ]),
        ),
      ),
    );
  }
}
