import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/routes.dart';

enum MenuActions { logout }

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    title: const Text("Main View"),
    actions: [
      PopupMenuButton<MenuActions>(
        onSelected: (value) async {
          switch (value) {
            case MenuActions.logout:
              final shouldLogout = await showLogoutDialog(context);
              if (shouldLogout) {
                await FirebaseAuth.instance.signOut();
                // ignore: use_build_context_synchronously
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (_) => false);
              }
              break;
          }
        },
        itemBuilder: (context) {
          return const [
            PopupMenuItem(
              value: MenuActions.logout,
              child: Text("Logout"),
            ),
          ];
        },
      )
    ],
  );
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sign Out?"),
          content: const Text("Are you sure to signout"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Yes")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel")),
          ],
        );
      }).then((value) => value ?? false);
}
