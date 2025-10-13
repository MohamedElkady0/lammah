import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:transparent_image/transparent_image.dart';

class CardFashion extends StatelessWidget {
  const CardFashion({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    var width = ConfigApp.width;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            children: [
              FadeInImage(
                width: width * .3,
                fit: BoxFit.cover,
                placeholder: MemoryImage(kTransparentImage),
                image: NetworkImage(
                  'https://ae-pic-a1.aliexpress-media.com/kf/Sb00ddd29d8ea448c97642037073cdba4I.jpg?width=800&height=800&hash=1600',
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  color: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '-50%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: width * .3,
            decoration: BoxDecoration(color: Colors.black54),
            child: Text(
              'جديد الشتاء الرجال لامعة الأبيض بطة أسفل معاطف مقنعين سترات منتفخة غير رسمية جودة الذكور في الهواء الطلق يندبروف سترات دافئة 3XL',
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,

              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: width * 0.025,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
