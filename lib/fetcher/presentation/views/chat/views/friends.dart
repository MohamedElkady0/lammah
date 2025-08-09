import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/chat/widget/pop_chats.dart';

class Friends extends StatefulWidget {
  const Friends({super.key, required this.index});

  final int index;

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  bool isSearch = false;
  bool newCollection = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        appBar: appBarFriends(context),
        body: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) {
            return ListTile(
              trailing: newCollection
                  ? IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    )
                  : null,
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/128/9985/9985721.png',
                ),
              ),
              title: Text(
                'Friend ${index + 1}',
                // style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                //   color: Theme.of(context).colorScheme.onTertiary,
                // ),
              ),
              subtitle: Text(
                'نبذه نبذه نبذه نبذه نبذه نبذه نبذه ${index + 1}',
                // style: Theme.of(context).textTheme.bodySmall!.copyWith(
                //   color: Theme.of(context).colorScheme.onTertiary,
                // ),
              ),
              onTap: () {
                // Handle friend tap
              },
            );
          },
        ),
      ),
    );
  }

  AppBar appBarFriends(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          onPressed: () => setState(() => isSearch = !isSearch),
          icon: const Icon(Icons.search),
        ),
        isSearch
            ? SizedBox()
            : PopChats(
                index: widget.index,
                title: ['مجموعه جديده', 'الاصدقاء', 'تسجيل الخروج'],
                isMenu: true,
                color: Theme.of(context).colorScheme.tertiaryFixedDim,
                offset: Offset(0, 50),
                onTap: [
                  () {
                    setState(() {
                      newCollection = true;
                    });
                  },
                  () {},
                  () {},
                ],
              ),
      ],
      title: isSearch
          ? TextField(
              onChanged: (value) {},
              autofocus: true,
              decoration: InputDecoration(
                hintText: '...ابحث عن صديق',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18),
            )
          : Text('الاصدقاء'),
      centerTitle: true,
    );
  }
}
