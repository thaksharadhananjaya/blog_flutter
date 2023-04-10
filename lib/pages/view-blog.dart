// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../config.dart';
import '../db-helper.dart';
import 'add-edit-blog.dart';
import 'home.dart';

class ViewBlog extends StatelessWidget {
  final String imageUrl, title, description, date;
  final int? id;
  const ViewBlog({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.date,
    required this.id,
  });
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kPrimaryHorizontalPadding,
            vertical: kPrimaryVerticalPadding),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              buildImage(screenHeight),
              Row(
                children: [
                  const Icon(
                    Icons.date_range,
                    size: 22,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 28,
              ),
              SizedBox(
                width: double.maxFinite,
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(
                height: 100,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "btn0",
            onPressed: () {
              Share.shareXFiles([XFile(imageUrl)],
                  subject: title, text: description);
            },
            child: const Icon(Icons.share),
          ),
          const SizedBox(
            width: 8,
          ),
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => BlogAddEdit(
                            id: id,
                            isAdd: false,
                            imageUrl: imageUrl,
                            title: title,
                            description: description,
                          ))));
            },
            child: const Icon(Icons.edit),
          ),
          const SizedBox(
            width: 8,
          ),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.warning,
                animType: AnimType.rightSlide,
                title: 'Dialog Blog',
                desc: 'Are you sure delete this ?',
                btnOkColor: Colors.orange,
                btnCancelColor: ThemeData().primaryColor,
                btnCancelOnPress: () {},
                btnOkOnPress: () => delete(context),
              ).show();
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  Container buildImage(double screenHeight) {
    return Container(
      height: screenHeight * 0.4,
      margin: const EdgeInsets.only(bottom: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
              image: FileImage(File(imageUrl)), fit: BoxFit.cover)),
    );
  }

  void delete(BuildContext context) async {
    DBHelper dbHelper = DBHelper();

    await dbHelper.deleteBlog(id!);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: ((context) => const Home())));
  }
}
