import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class CardFashion extends StatelessWidget {
  const CardFashion({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FadeInImage(
            width: MediaQuery.of(context).size.width * .4,
            fit: BoxFit.cover,
            placeholder: MemoryImage(kTransparentImage),
            image: NetworkImage(
              'https://ae-pic-a1.aliexpress-media.com/kf/Sb00ddd29d8ea448c97642037073cdba4I.jpg?width=800&height=800&hash=1600',
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: MediaQuery.of(context).size.width * .4,
            decoration: BoxDecoration(color: Colors.black54),
            child: Text(
              'جديد الشتاء الرجال لامعة الأبيض بطة أسفل معاطف مقنعين سترات منتفخة غير رسمية جودة الذكور في الهواء الطلق يندبروف سترات دافئة 3XL',
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,

              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
