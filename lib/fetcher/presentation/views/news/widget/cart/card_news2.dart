import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/fetcher/data/model/news.dart';
import 'package:lammah/fetcher/presentation/widgets/pop_app.dart';

class CartNews2 extends StatelessWidget {
  const CartNews2({super.key, required this.news, this.onTap});
  final News news;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    double w = ConfigApp.width;
    double h = ConfigApp.height;
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).colorScheme.primary.withAlpha(200),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: w * 0.3,
                    height: h * 0.17,
                    padding: const EdgeInsets.all(4),

                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AA1M7tJe.img?w=768&h=432&m=6&x=368&y=71&s=69&d=69',
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Text(
                        'وزير المالية: كريم كوجاك شقيقي الأكبر وندين له في تغيير اسم العائلة',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: -12,
                right: 0,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                    SizedBox(width: w * 0.2),
                    Row(
                      children: [
                        Text(
                          '3:00 pm',
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.watch_later,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,

                child: Row(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(160),
                          child: PopApp(
                            icon: Icon(
                              Icons.more_vert,
                              size: 14,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            index: 4,
                            title: [
                              'متابعه ${news.title}',
                              'حظر ${news.category}',
                              'الابلاغ عن مشكله',
                              'اداره الاهتمامات',
                            ],
                            isMenu: true,
                            onTap: [() {}, () {}, () {}, () {}],
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(160),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: w * 0.2),
                    Row(
                      children: [
                        Image.network(
                          'https://img-s-msn-com.akamaized.net/tenant/amp/entityid/BB1q7xgu.img?w=160&h=160',
                          fit: BoxFit.fill,
                          width: w * 0.08,
                          height: h * 0.04,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'المصرى اليوم',
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(width: w * 0.02),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
