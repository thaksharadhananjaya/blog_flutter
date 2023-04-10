// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:blog/models/blog.model.dart';
import 'package:blog/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';

import '../config.dart';
import '../db-helper.dart';

class BlogAddEdit extends StatefulWidget {
  final isAdd;
  final String? title, description;
  final int? id;
  String? imageUrl;
  BlogAddEdit(
      {super.key,
      required this.isAdd,
      this.imageUrl,
      this.title,
      this.description,
      this.id});

  @override
  State<BlogAddEdit> createState() => _BlogAddEditState();
}

class _BlogAddEditState extends State<BlogAddEdit> {
  String selectedDate =
      "${DateTime.now().day.toString().padLeft(2,'0')}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().year}";
  DBHelper dbHelper = DBHelper();
  final ImagePicker picker = ImagePicker();
  File? imageFile;
  final TextEditingController titleTextEditingController =
      TextEditingController();
  final TextEditingController decTextEditingController =
      TextEditingController();

  @override
  void initState() {
    if (!widget.isAdd) {
      titleTextEditingController.text = widget.title!;
      decTextEditingController.text = widget.description!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: Text(widget.isAdd ? 'Add Blog' : 'Edit Blog')),
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
              buildCameraButton(screenHeight),
              buildTextBox('Title', titleTextEditingController),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: pickDateDialog,
                    child: Container(
                      height: 50,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width*0.9,
                      padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey)),
                        child: Text(selectedDate)),
                  ),
                ],
              ),
              buildTextBox('Description', decTextEditingController,
                  height: 130),
              SizedBox(
                  width: 120,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      String imgPath =
                          widget.imageUrl == null ? '' : widget.imageUrl!;
                      if (imageFile != null) {
                        final Directory directory =
                            await getApplicationDocumentsDirectory();
                        final String path = directory.path;
                        var rng = Random();
                        final File newImage = await imageFile!.copy(
                            '$path/${DateTime.now().toString()}${rng.nextInt(100)}.jpg');
                        imgPath = newImage.path;
                      }
                      print(imgPath);
                      bool isSuccess;
                      if (widget.isAdd) {
                        isSuccess = await dbHelper.saveBlog(Blog(
                            title: titleTextEditingController.text,
                            description: decTextEditingController.text,
                            imgPath: imgPath,
                            date: selectedDate));
                      } else {
                        isSuccess = await dbHelper.updateBlog(Blog(
                            id: widget.id!,
                            title: titleTextEditingController.text,
                            description: decTextEditingController.text,
                            imgPath: imgPath,
                            date: selectedDate));
                      }
                      if (isSuccess) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => const Home())));
                      }
                    },
                    child: Text(
                      widget.isAdd ? 'Save' : 'Update',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void pickDateDialog() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        selectedDate =
            "${pickedDate.day.toString().padLeft(2,'0')}-${pickedDate.month.toString().padLeft(2,'0')}-${pickedDate.year}";
      });
    });
  }

  InkWell buildCameraButton(double screenHeight) {
    return InkWell(
      onTap: () => showBottomSheet(),
      child: Container(
        height: screenHeight * 0.3,
        alignment: Alignment.center,
        decoration: imageFile == null && widget.imageUrl == null
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color.fromARGB(255, 199, 197, 197))
            : BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: widget.imageUrl == null
                    ? DecorationImage(
                        image: FileImage(imageFile!), fit: BoxFit.cover)
                    : DecorationImage(
                        image: FileImage(File(widget.imageUrl!)),
                        fit: BoxFit.cover)),
        child: imageFile == null && widget.imageUrl == null
            ? Icon(
                Icons.image,
                size: 100,
                color: ThemeData().primaryColor,
              )
            : const SizedBox(),
      ),
    );
  }

  Container buildTextBox(
      String label, TextEditingController searchTextEditingController,
      {double height = 50}) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(top: 32),
      child: TextField(
        maxLines: height > 50 ? 4 : 1,
        controller: searchTextEditingController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            border: const OutlineInputBorder(), labelText: label),
      ),
    );
  }

  Future<dynamic> showBottomSheet() {
    return showMaterialModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            bottomButton('Camera', Icons.camera_alt, () => pickImage(true)),
            bottomButton('Gallery', Icons.photo, () => pickImage(false)),
          ],
        ),
      ),
    );
  }

  InkWell bottomButton(String label, IconData iconData, Function onClick) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onClick();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 50,
            color: ThemeData().primaryColor,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeData().primaryColor,
            ),
          )
        ],
      ),
    );
  }

  void pickImage(bool isCamera) async {
    XFile? pikedPhoto = await picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);
    if (pikedPhoto != null) {
      widget.imageUrl = null;
      setState(() {
        imageFile = File(pikedPhoto.path);
      });
    }
  }
}
