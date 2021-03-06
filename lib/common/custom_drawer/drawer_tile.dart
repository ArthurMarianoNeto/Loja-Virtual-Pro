import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {

  const DrawerTile({this.iconData, this.title, this.page});

  final IconData iconData;
  final String title;
  final int page;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        debugPrint('Apertei $page');
      },
      child: SizedBox(
        height: 60,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Icon(
                iconData,
                size: 32,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 32,),
            Text(
              title,
              style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700]
            ),
           )
          ],
        ),
      ),
    );
  }
}
