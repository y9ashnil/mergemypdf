import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_file/open_file.dart';
import 'user_widget.dart';
import 'get_files.dart';
import 'merge_file.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController left = TextEditingController(text: '0');
  TextEditingController right = TextEditingController(text: '0');
  TextEditingController top = TextEditingController(text: '0');
  TextEditingController bottom = TextEditingController(text: '0');

  List<File> files = [];
  bool gotFile = false;
  FocusNode leftFocus = FocusNode();
  FocusNode rightFocus = FocusNode();
  FocusNode topFocus = FocusNode();
  FocusNode bottomFocus = FocusNode();
  bool isLoading = false;

  Future<void> getFilesTap() async {
    files = await getFiles(files);
    if (files.isNotEmpty) {
      setState(() {
        gotFile = true;
      });
    } else {
      setState(() {
        gotFile = false;
      });
    }
  }

  void loading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  bool isDouble(String s) => double.tryParse(s) != null;

  bool checkMargin() {
    if (isDouble(left.text) &&
        isDouble(right.text) &&
        isDouble(top.text) &&
        isDouble(bottom.text)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> pdfMerger() async {
    if (!checkMargin()) {
      showSnackBar(context, "Please enter a valid margin value");
      return;
    }

    if (files.isEmpty || files.length < 2) {
      showSnackBar(context, "Please select at least two PDFs");
      return;
    }

    loading(); // show loading dialog

    try {
      File? mergedPdf = await mergePDFs(
        context: context,
        files: files,
        left: double.parse(left.text),
        right: double.parse(right.text),
        top: double.parse(top.text),
        bottom: double.parse(bottom.text),
      );

      if (isLoading) loading();

      if (mergedPdf == null) {
        if (!mounted) return;
        showSnackBar(context, "Merging cancelled");
        return;
      }

      await OpenFile.open(mergedPdf.path);
    } catch (e) {
      if (isLoading) loading();
      if (!mounted) return;
      showSnackBar(context, "Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  AppBar(
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    title: Column(
                      children: [
                        Text(
                          "Merge My PDF",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Select and combine PDFs",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: IconButton(
                            onPressed: getFilesTap,
                            icon: Icon(Icons.note_add_rounded),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SvgPicture.asset('assets/pdfmergeimage.svg'),
                  customTextIconButton(
                    icon: Icons.note_add_rounded,
                    text: "Select PDFs",
                    fun: getFilesTap,
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Margin",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            buildTextField(
                              hintText: 'Left',
                              controller: left,
                              focusNode: leftFocus,
                              nextFocusNode: rightFocus,
                            ),
                            buildTextField(
                              hintText: 'Right',
                              controller: right,
                              focusNode: rightFocus,
                              nextFocusNode: topFocus,
                            ),
                            buildTextField(
                              hintText: 'Top',
                              controller: top,
                              focusNode: topFocus,
                              nextFocusNode: bottomFocus,
                            ),
                            buildTextField(
                              hintText: 'Bottom',
                              controller: bottom,
                              focusNode: bottomFocus,
                            ),
                          ],
                        ),

                        SizedBox(height: 30),
                        if (gotFile)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.all(
                                Radius.circular(21),
                              ),
                            ),
                            // padding: EdgeInsets.symmetric(vertical: 6),
                            height: 250, // Adjust as needed
                            child: ListView.builder(
                              itemCount: files.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  key: ValueKey(files[index].path),

                                  // Unique key based on file path
                                  margin: EdgeInsets.only(
                                    top: (index == 0) ? 12 : 6,
                                    left: 12,
                                    right: 12,
                                    bottom: (index == files.length - 1)
                                        ? 12
                                        : 6,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(22),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.red.shade300,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.picture_as_pdf_rounded,
                                      color: Colors.red.shade400,
                                    ),
                                    title: Text(
                                      files[index].path.split('/').last,
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          files.removeAt(index);
                                          gotFile = files.isNotEmpty;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.cancel_rounded,
                                        color: Colors.red,
                                      ),
                                      tooltip: "Remove file",
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customTextIconButton(
                  icon: Icons.note_add_rounded,
                  text: "Select PDFs",
                  fun: getFilesTap,
                ),
                customTextIconButton(
                  icon: Icons.merge_type_rounded,
                  text: "Merge PDFs",
                  fun: pdfMerger,
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: isLoading,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              alignment: Alignment.center,
              height: double.infinity,
              width: double.infinity,
              color: Color.fromRGBO(0, 0, 0, 0.7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: CircularProgressIndicator(color: Colors.white)),
                  SizedBox(height: 10),
                  Text("Creating PDF", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}