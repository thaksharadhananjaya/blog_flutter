import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blog/config.dart';
import 'package:blog/pages/add-edit-blog.dart';
import 'package:blog/pages/view-blog.dart';
import 'package:flutter/material.dart';

import '../db-helper.dart';
import '../models/blog.model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController searchTextEditingController =
      TextEditingController();
  List<int> selectedList = [];
  DBHelper dbHelper = DBHelper();
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
              selectedList.isNotEmpty
                  ? SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedList.length == 1
                                ? '${selectedList.length} item Selected'
                                : '${selectedList.length} items Selected',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    animType: AnimType.rightSlide,
                                    title: 'Dialog Blog(s)',
                                    desc: 'Are you sure delete ?',
                                    btnOkColor: Colors.orange,
                                    btnCancelColor: ThemeData().primaryColor,
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () async {
                                      for (int id in selectedList) {
                                        await dbHelper.deleteBlog(id);
                                      }
                                      setState(() {
                                        selectedList.clear();
                                      });
                                    },
                                  ).show();
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'Delete selected',
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  : const SizedBox(),
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
        onChanged: (text) {
          setState(() {});
        },
        decoration: const InputDecoration(
            suffixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            labelText: 'Search'),
      ),
    );
  }

  SizedBox buildPostsList(double screenHeight) {
    return SizedBox(
      height: selectedList.isEmpty ? screenHeight * 0.88 : screenHeight * 0.80,
      child: FutureBuilder<List<Blog>>(
          future: searchTextEditingController.text.isEmpty
              ? dbHelper.getBlogs()
              : dbHelper.getBlogByTitle(searchTextEditingController.text),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Blog> data = snapshot.data!;
              if (data.isEmpty) {
                return const Center(
                  child: Text(
                    'Blogs Not Found !',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                );
              }
              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: ((context, index) {
                    return buildBlogCard(
                        data[index].title,
                        data[index].imgPath,
                        data[index].date!,
                        data[index].description,
                        data.length - 1 == index,
                        data[index].id!);
                  }));
            }
            return const CircularProgressIndicator();
          }),
    );
  }

  InkWell buildBlogCard(String title, String imageUrl, String date,
      String description, bool isExtraMargin, int id) {
    return InkWell(
      onLongPress: () {
        setState(() {
          selectedList.add(id);
        });
      },
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: ((context) => ViewBlog(
                    id: id,
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
              colorFilter: selectedList.contains(id)
                  ? ColorFilter.mode(
                      const Color.fromARGB(255, 77, 132, 177).withOpacity(0.8),
                      BlendMode.colorBurn)
                  : ColorFilter.mode(
                      Colors.black.withOpacity(0.4), BlendMode.colorBurn),
              image: FileImage(File(imageUrl))),
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 2, right: 8),
                    child: Icon(
                      Icons.date_range,
                      color: kTitleTextColor,
                      size: 18,
                    ),
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
            selectedList.contains(id)
                ? Align(
                    alignment: Alignment.bottomLeft,
                    child: InkWell(
                      child: const Icon(
                        Icons.done,
                        color: Colors.blue,
                        size: 32,
                      ),
                      onTap: () {
                        setState(() {
                          selectedList.remove(id);
                        });
                      },
                    ))
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
