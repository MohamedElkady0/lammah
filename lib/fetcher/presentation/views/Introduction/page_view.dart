import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/core/config/fixed_sizes_app.dart';
import 'package:lammah/core/utils/pageview_string.dart';
import 'package:lammah/fetcher/domian/auth/auth_cubit.dart';
import 'package:lammah/fetcher/presentation/views/Introduction/data/pageview_data.dart';
import 'package:lammah/fetcher/presentation/views/Introduction/widget/anim_image.dart';
import 'package:lammah/fetcher/presentation/views/Introduction/widget/background_page.dart';
import 'package:lammah/fetcher/presentation/views/Introduction/widget/blur_background.dart';

class PageViewMyChat extends StatefulWidget {
  const PageViewMyChat({super.key});

  @override
  State<PageViewMyChat> createState() => _PageViewMyChatState();
}

class _PageViewMyChatState extends State<PageViewMyChat>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController(initialPage: 0);

  int _currentIndex = 0;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    // Timer.periodic(const Duration(seconds: 6), (timer) {
    //   if (_currentIndex < pageViewData.length) _currentIndex++;

    //   _controller.animateToPage(
    //     _currentIndex,
    //     duration: const Duration(milliseconds: 300),
    //     curve: Curves.easeIn,
    //   );
    // });

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    return SafeArea(
      minimum: EdgeInsets.symmetric(vertical: 8),
      child: Scaffold(
        floatingActionButton: _currentIndex < pageViewData.length - 1
            ? FloatingActionButton(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  _controller.animateToPage(
                    _currentIndex + 1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Icon(Icons.arrow_downward),
              )
            : Container(),
        body: PageView.builder(
          scrollDirection: Axis.vertical,
          clipBehavior: Clip.none,
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });

            animationController.reset();

            animationController.repeat(reverse: true);
          },
          itemCount: pageViewData.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                BackgroundPage(),
                BlurBackground(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    SizedBox(height: AppSpacing.vSpaceXXS.height),
                    AnimImagePage(
                      index: index,
                      animationController: animationController,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.horizontalXS.horizontal,
                      ),
                      child: Text(
                        pageViewData[index].title!,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium!
                            .copyWith(color: Colors.white54),
                      ),
                    ),
                    if (index == pageViewData.length - 1)
                      ElevatedButton(
                        style: Theme.of(context).elevatedButtonTheme.style!
                            .copyWith(
                              padding: WidgetStateProperty.all(
                                EdgeInsets.symmetric(
                                  horizontal: AppSpacing.horizontalS.horizontal,
                                  vertical: AppSpacing.verticalS.vertical,
                                ),
                              ),
                            ),
                        onPressed: () =>
                            BlocProvider.of<AuthCubit>(context).onIntroEnd(),
                        child: Text(
                          PageViewString.start,
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                        ),
                      ),
                    SizedBox(height: AppSpacing.vSpaceXXS.height),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
