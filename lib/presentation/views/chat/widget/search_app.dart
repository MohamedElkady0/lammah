import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/utils/chat_string.dart';

// تأكد من أن هذه الاستيرادات صحيحة لمشروعك
import 'package:lammah/data/model/user_info.dart';
import 'package:lammah/domian/search/search_cubit.dart';
import 'package:lammah/domian/search/search_state.dart';

class SearchApp extends StatefulWidget {
  const SearchApp({super.key});

  @override
  State<SearchApp> createState() => _SearchAppState();
}

class _SearchAppState extends State<SearchApp> {
  final SearchController _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<SearchCubit>().searchUsers(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SearchAnchor يبقى ثابتًا ولا يتم إعادة بنائه
    return SearchAnchor(
      searchController: _searchController,
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.primary.withAlpha(150),
          ),
          hintText: ChatString.search,
          onTap: () {
            controller.openView();
          },
          leading: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          trailing: <Widget>[
            IconButton(
              icon: Icon(
                Icons.mic,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {},
            ),
          ],
        );
      },

      // *** الحل النهائي والمصحح هنا ***
      // نستخدم BlocBuilder لبناء قائمة الاقتراحات
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        // BlocBuilder هو الطريقة الآمنة للاستماع للتغييرات هنا
        return [
          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              // داخل BlocBuilder، نرجع ويدجت واحدة فقط
              if (state is SearchLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is SearchSuccess) {
                if (state.users.isEmpty && controller.text.isNotEmpty) {
                  return const ListTile(title: Text(ChatString.noItems));
                }

                // ** التصحيح الأهم: لا نستخدم Column **
                // نستخدم ListView.builder لإنشاء قائمة قابلة للتمرير وذات ارتفاع محدد
                return ListView.builder(
                  shrinkWrap:
                      true, // مهم جدًا لجعل ListView يأخذ المساحة التي يحتاجها فقط
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final UserInfoData user = state.users[index];
                    return ListTile(
                      title: Text(user.name ?? ''),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.image ?? ''),
                      ),
                      trailing: Row(
                        mainAxisSize:
                            MainAxisSize.min, // صحيح: لا نستخدم Expanded
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.person_add),
                          ),
                        ],
                      ),
                      onTap: () {
                        controller.closeView(user.name);
                        FocusScope.of(context).unfocus();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('تم اختيار: ${user.name}')),
                        );
                      },
                    );
                  },
                );
              }

              if (state is SearchFailure) {
                return ListTile(title: Text('خطأ: ${state.message}'));
              }

              return Container(); // الحالة الأولية
            },
          ),
        ];
      },
    );
  }
}
