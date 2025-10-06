import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';

class CartNews extends StatelessWidget {
  const CartNews({super.key, this.onTap});
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    var width = ConfigApp.width;
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.all(width * 0.02),
        clipBehavior: Clip.hardEdge,

        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AA1zWmaM.img?w=768&h=513&m=6&x=430&y=168&s=112&d=112 ',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: Colors.black45,
                ),
                child: Text(
                  'يخاطبني السفيه بكل قبح رسائل نارية من خالد الغندور بعد تصريحات سيد عبدالحفيظ',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.04,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
