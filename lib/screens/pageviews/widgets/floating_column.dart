import 'package:flutter/material.dart';
import 'package:skype/utils/universal_variables.dart';

class FloatingColumn extends StatelessWidget {
  const FloatingColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: UniversalVariables.fabGradient,
          ),
          child: const Icon(
            Icons.dialpad,
            color: Colors.white,
            size: 25,
          ),
          padding: const EdgeInsets.all(15),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                width: 2, color: UniversalVariables.gradientColorEnd),
            color: Colors.black,
          ),
          child: const Icon(
            Icons.add_call,
            color: UniversalVariables.gradientColorEnd,
            size: 25,
          ),
          padding: const EdgeInsets.all(15),
        )
      ],
    );
  }
}
