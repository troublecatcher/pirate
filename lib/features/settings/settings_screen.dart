import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:get/get.dart';
import 'package:pirate/features/shared/widgets/stroke_title.dart';
import 'package:pirate/main.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../../router/router.dart';
import '../../theme.dart';
import '../shared/widgets/back_buttonn.dart';

final settingsController = SettingsController();

@RoutePage()
class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    settingsController.getVibro();
    settingsController.getAppIconIndex();

    return Scaffold(
      body: Container(
        color: blueColor1,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(children: [
              Align(
                alignment: Alignment.topLeft,
                child: Transform.rotate(
                  angle: pi / 2,
                  child: const BackButtonn(isActive: true),
                ),
              ),
              const Align(
                alignment: Alignment.topCenter,
                child: StrokeTitle(text: 'SETTINGS'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Builder(builder: (_) {
                        return SettingsItem(
                            child: Text('Share with friends', style: smallTS),
                            callback: (p0) {
                              final box = _.findRenderObject() as RenderBox?;
                              Share.share('Check out this pirate game!',
                                  sharePositionOrigin:
                                      box!.localToGlobal(Offset.zero) &
                                          box.size);
                            });
                      }),
                      const SizedBox(height: 10),
                      SettingsItem(
                          child: Text('Privacy policy', style: smallTS),
                          callback: (p0) =>
                              context.router.push(const PrivacyPolicyRoute())),
                      const SizedBox(height: 10),
                      SettingsItem(
                          child: Text('Terms of use', style: smallTS),
                          callback: (p0) =>
                              context.router.push(const TermsOfUseRoute())),
                    ],
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text('Vibro', style: smallTS),
                            GetBuilder(
                                init: settingsController,
                                builder: (_) {
                                  if (settingsController.vibro != null) {
                                    return CupertinoSwitch(
                                        activeColor: blueColor2,
                                        value: settingsController.vibro,
                                        onChanged: (value) {
                                          settingsController.toggleVibro();
                                          if (settingsController.vibro) {
                                            Vibration.vibrate();
                                          }
                                        });
                                  } else {
                                    return const CupertinoActivityIndicator();
                                  }
                                })
                          ],
                        ),
                        Row(
                          children: [Text('App icon', style: smallTS)],
                        ),
                        Wrap(
                          direction: Axis.horizontal,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ...List.generate(4, (index) {
                              return GetBuilder(
                                init: settingsController,
                                builder: (_) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (settingsController.appIconIndex ==
                                          index) {
                                        null;
                                      } else {
                                        if (settingsController.vibro) {
                                          Vibration.vibrate();
                                        }
                                        changeAppIcon(index);
                                      }
                                    },
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        border:
                                            settingsController.appIconIndex ==
                                                    index
                                                ? Border.all(
                                                    color: blueColor3, width: 4)
                                                : null,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(16)),
                                        image: const DecorationImage(
                                            image: AssetImage(
                                                'assets/items/frame.png'),
                                            fit: BoxFit.fill,
                                            scale: 0.01,
                                            alignment:
                                                FractionalOffset.bottomLeft),
                                      ),
                                      child: Image.asset(
                                          'assets/items/$index.png'),
                                    ),
                                  );
                                },
                              );
                            })
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }

  changeAppIcon(int index) async {
    try {
      if (await FlutterDynamicIcon.supportsAlternateIcons) {
        await FlutterDynamicIcon.setAlternateIconName('icon${index + 1}');
        settingsController.changeAppIcon(index);
        return;
      }
    } catch (e) {
      // print(e);
    }
  }
}

class SettingsItem extends StatelessWidget {
  final Widget child;
  final Function(dynamic) callback;
  const SettingsItem({
    super.key,
    required this.child,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => callback('Argument'),
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            color: blueColor2,
            border: Border.all(width: 4, color: blueColor3)),
        child: Center(child: child),
      ),
    );
  }
}

class SettingsController extends GetxController {
  var vibro;
  var appIconIndex;
  void getVibro() {
    vibro = locator<SharedPreferences>().getBool('vibro');
    update();
  }

  void getAppIconIndex() {
    appIconIndex = locator<SharedPreferences>().getInt('preferredIconIndex');
    update();
  }

  Future<void> toggleVibro() async {
    vibro = !vibro;
    await locator<SharedPreferences>().setBool('vibro', vibro);
    update();
  }

  Future<void> changeAppIcon(int index) async {
    appIconIndex = index;
    await locator<SharedPreferences>()
        .setInt('preferredIconIndex', appIconIndex);
    update();
  }
}
