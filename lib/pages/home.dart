import 'package:blog/config.dart';
import 'package:blog/pages/add-edit-blog.dart';
import 'package:blog/pages/view-blog.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController searchTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kPrimaryHorizontalPadding,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildSearchTextBox(searchTextEditingController),
              buildPostsList(screenHeight)
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => BlogAddEdit(
                        isAdd: true,
                      ))));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Container buildSearchTextBox(
      TextEditingController searchTextEditingController) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 32),
      child: TextField(
        controller: searchTextEditingController,
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
            suffixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            labelText: 'Search'),
      ),
    );
  }

  SizedBox buildPostsList(double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.87,
      child: ListView.builder(
          itemCount: 4,
          itemBuilder: ((context, index) {
            return buildBlogCard(
                'Title - $index',
                'https://thumbs.dreamstime.com/b/landscape-nature-mountan-alps-rainbow-76824355.jpg',
                '2023-04-08',
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.",
                3 == index);
          })),
    );
  }

  InkWell buildBlogCard(String title, String imageUrl, String date,
      String description, bool isExtraMargin) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: ((context) => ViewBlog(
                    date: date,
                    imageUrl: imageUrl,
                    title: title,
                    description: description))));
      },
      child: Container(
        height: 200,
        margin: EdgeInsets.only(bottom: isExtraMargin ? 80 : 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4), BlendMode.colorBurn),
              image: NetworkImage(imageUrl)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Center(
                child: Text(
              title,
              style: const TextStyle(
                  color: kTitleTextColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            )),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.date_range,
                    color: kTitleTextColor,
                    size: 18,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                        color: kTitleTextColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
