import 'package:flutter/material.dart';
import 'package:skype/utils/universal_variables.dart';

class CustomTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? icon;
  final Widget subtitle;
  final Widget? trailing;
  final EdgeInsets margin;
  final bool mini;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  const CustomTile(
      {required this.leading,
      required this.title,
      required this.icon,
      required this.subtitle,
      required this.trailing,
      this.margin = const EdgeInsets.all(0),
      required this.onTap,
      required this.onLongPress,
      this.mini = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: mini ? 10 : 10),
        margin: margin,
        child: Row(
          children: [
            leading,
            Expanded(
                child: Container(
              margin: EdgeInsets.only(left: mini ? 10 : 15),
              padding: EdgeInsets.symmetric(vertical: mini ? 3 : 20),
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 1, color: UniversalVariables.separatorColor))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: 5),
                      Row(
                        children: [icon ?? Container(), subtitle],
                      ),
                    ],
                  ),
                  trailing ?? Container(),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
