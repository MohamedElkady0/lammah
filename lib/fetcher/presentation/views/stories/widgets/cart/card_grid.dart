import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class CardGrid extends StatelessWidget {
  const CardGrid({super.key, this.isShow, this.isUpShop, this.addItems});

  final bool? isShow;
  final bool? isUpShop;
  final int? addItems;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: FadeInImage(
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: MemoryImage(kTransparentImage),
              image: NetworkImage(
                'https://ae01.alicdn.com/kf/Se3fe3522af0d4ba1901fa5f033432ac6W.jpg',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'كمبيوتر محمول للألعاب OneXPlayer G1 AMD Ryzen AI 9 HX 370 & Intel Core Ultra 7 255H محمول 8.8 بوصة 144 هرتز كمبيوتر لوحة مفاتيح ثنائي الوضع',
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(color: Colors.red[800]),
                child: Text(
                  'عرض',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 12),
                  Text(
                    '4.0',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Text(
                'مباع 5000',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary.withAlpha(200),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Text(
                'EGP82,705.03',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '42% - الان',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),
              Text(
                'العرض',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),
              Icon(Icons.arrow_downward, color: Colors.red[800], size: 14),
            ],
          ),
        ],
      ),
    );
  }
}
