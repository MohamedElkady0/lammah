import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/presentation/widgets/input_new_item.dart';

class PostShop extends StatelessWidget {
  const PostShop({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);

    double width = ConfigApp.width;

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).colorScheme.onPrimary.withAlpha(50),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: width * .75,
                  child: InputNewItem(title: 'اسم المنتج'),
                ),
                SizedBox(width: width * .006),
                CircleAvatar(
                  radius: width * .06,
                  backgroundImage: NetworkImage(
                    context.read<AuthCubit>().currentUserInfo?.image ?? '',
                  ),
                ),
              ],
            ),
            SizedBox(height: width * .01),
            InputNewItem(title: 'تفاصيل المنتج'),
            SizedBox(height: width * .01),
            Divider(
              thickness: 1,
              color: Theme.of(context).colorScheme.onPrimary,
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: width * .55,
                  child: InputNewItem(title: 'سعر المنتج'),
                ),

                Container(
                  height: width * .12,
                  width: 1,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),

                InkWell(
                  onTap: () {},
                  child: Column(
                    children: [
                      Text(
                        'صوره او فيديو',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: width * .03,
                        ),
                      ),
                      SizedBox(height: width * .01),
                      Icon(
                        Icons.image,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: width * .07,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
