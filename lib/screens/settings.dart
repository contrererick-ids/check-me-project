import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /* Row(
              /* decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black)
              ), */
              children: [
                Expanded(
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                    ),
                    title: Text('Usuario 1'),
                    subtitle: Text('correo@dummy.com'),
                  )
                )
              ],
            ), */
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color.fromARGB(255,219,215,211))
              ), 
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                ),
                title: Text('User 1'),
                subtitle: Text('email@dummy.com'),
              ),
            ),
            Row(

            )
          ],
        ),
      ),
    );
  }
}
