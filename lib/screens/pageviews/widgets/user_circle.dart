import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/screens/pageviews/widgets/user_details_container.dart';
import 'package:skype/utils/universal_variables.dart';
import 'package:skype/utils/utils.dart';

class UserCircle extends StatelessWidget {
  const UserCircle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return GestureDetector(
      onTap: () => showModalBottomSheet(
          context: context,
          builder: (context) => const UserDetailsContainer(),
          backgroundColor: Colors.black,
          isScrollControlled: true),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: UniversalVariables.separatorColor,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                Utils.getInitials(userProvider.getUser!.name!),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: UniversalVariables.lightBlueColor,
                  fontSize: 13,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                    color: UniversalVariables.onlineDotColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}
