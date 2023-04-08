import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../config.dart';

class BlogAddEdit extends StatefulWidget {
  final isAdd;
  final String? title, description;
  String? imageUrl;
  BlogAddEdit(
      {super.key,
      required this.isAdd,
      this.imageUrl,
      this.title,
      this.description});

  @override
  State<BlogAddEdit> createState() => _BlogAddEditState();
}

class _BlogAddEditState extends State<BlogAddEdit> {
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
              buildTextBox('Description', decTextEditingController,
                  height: 200),
              SizedBox(
                  width: 120,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
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
                        image: NetworkImage(widget.imageUrl!),
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
        maxLines: height > 50 ? 6 : 1,
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
