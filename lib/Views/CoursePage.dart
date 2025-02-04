import 'package:flutter/material.dart';
import 'package:sync_sqflit_and_core/Config/constants.dart';
import 'package:sync_sqflit_and_core/Models/SubjectModels.dart';
import 'package:sync_sqflit_and_core/Views/CourseDetailsPage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../Controllers/CourseController.dart';
import '../Controllers/HomeController.dart';
import '../Models/CourseModel.dart';
import '../Themes/Colors.dart';

class CoursesPage extends StatelessWidget {
  final CourseController _controller = Get.put(CourseController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Courses",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(onPressed: (){
            _controller.getCourseList();
          }, icon: Icon(Icons.refresh))
        ],
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 10,
        shadowColor: primaryColor.withOpacity(0.5),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (_controller.courseList.isEmpty) {
          return const Center(child: Text('No courses available'));
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = _controller.courseList[index];
                    return Card(
                      child: ListTile(
                        leading: _buildCourseImage(course),
                        title: Text(course.title),
                        subtitle: Text(course.subject),
                        onTap: () => Get.to(() => CourseDetailsPage(course.id)),
                      ),
                    );
                  },
                  childCount: _controller.courseList.length,
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCourseDialog(null);
        },
        child: const Icon(Icons.add),
        backgroundColor: primaryColor,
        foregroundColor: backgroundColor,
        elevation: 10,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCourseImage(CourseModel course) {
    if (course.photo == null || course.photo!.isEmpty) {
      return const Icon(Icons.book);
    }

    String imageUrl = course.photo!.startsWith('http') 
        ? course.photo! 
        : '$baseAPIUrl${course.photo}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image: $error');
          return const Icon(Icons.image_not_supported);
        },
      ),
    );
  }

  void _showAddCourseDialog(CourseModel? course) {
    var subjects = Get.find<HomeController>().subjects;
    final _formKey = GlobalKey<FormState>();
    Rx<File?> courseImage = Rx<File?>(null);
    
    if(subjects.isEmpty) {
      subjects.add(SubjectModel(title: 'Flutter', slug: 'Programming', photo: '', totalCourses: 1));
    }
    
    var titleController = TextEditingController();
    var overviewController = TextEditingController();
    String selectedSubject = subjects.first.slug;

    if (course != null) {
      titleController.text = course.title;
      overviewController.text = course.overview;
      selectedSubject = subjects
          .firstWhere(
            (element) => element.title == course.subject,
            orElse: () => subjects.first,
          )
          .slug;
    }

    Get.defaultDialog(
      title: course == null ? 'New Course' : 'Edit Course',
      backgroundColor: backgroundColor,
      content: Container(
        width: Get.width * 0.8,
        constraints: BoxConstraints(maxHeight: Get.height * 0.7),
        child: Obx(() {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedSubject,
                    items: subjects
                        .map((e) => DropdownMenuItem(
                              value: e.slug,
                              child: Text(e.title),
                            ))
                        .toList(),
                    onChanged: (value) {
                      selectedSubject = value!;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select Subject',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select a subject'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a course name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: overviewController,
                    decoration: InputDecoration(
                      labelText: 'Overview',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final pickedFile = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        courseImage.value = File(pickedFile.path);
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: Text(course == null ? 'Choose Photo' : 'Change Photo'),
                  ),
                  const SizedBox(height: 10),
                  if (courseImage.value != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        courseImage.value!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (course?.photo != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        "${baseAPIUrl}${course!.photo}",
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
      textCancel: 'Cancel',
      textConfirm: course == null ? 'Add' : 'Update',
      onCancel: () => Get.back(),
      onConfirm: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          
          if (course == null) {
            _controller.addCourse(
              title: titleController.text,
              overview: overviewController.text,
              subject: selectedSubject,
              photo: courseImage.value,
            );
          } else {
            _controller.updateCourse(
              course.id,
              title: titleController.text,
              overview: overviewController.text,
              subject: selectedSubject,
              photo: courseImage.value,
            );
          }
          Get.back();
        }
      },
    );
  }

  void _showDeleteCourseDialog(int courseId) {
    Get.defaultDialog(
      title: 'Delete Course',
      content: Text('Are you sure you want to delete this course?'),
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      onCancel: () {},
      onConfirm: () {
        _controller.deleteCourse(courseId);
        Get.back();
      },
    );
  }
}