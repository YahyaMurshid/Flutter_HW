import 'package:flutter/material.dart';
import 'package:sync_sqflit_and_core/Config/constants.dart';
import 'package:get/get.dart';

import '../Controllers/CourseController.dart';
import '../Models/CourseModel.dart';
import '../Themes/Colors.dart';


class CourseDetailsPage extends StatelessWidget {
  final CourseController _controller = Get.put(CourseController());
  final int courseID;

  CourseDetailsPage(this.courseID);

  @override
  Widget build(BuildContext context) {
    _controller.getCourseDetails(courseID);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Course Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 10,
        shadowColor: primaryColor.withOpacity(0.5),
      ),
      body: Obx(() => _controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : _buildCourseDetails(_controller.courseDetail)),
    );
  }

  Widget _buildCourseDetails(CourseModel? course) {
    if (course == null) {
      return const Center(child: Text("No course available"));
    }

    return Container(
      width: 500,
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
        color: Colors.black12,
      ),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: course.photo != null
                      ? Image.network(
                          "${baseAPIUrl}${course.photo}",
                          width: 512,
                          height: 256,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            course.title,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          course.created,
                          style: const TextStyle(
                            fontSize: 14,
                            color: textColor,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.subject,
                      style: const TextStyle(
                        fontSize: 24,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        course.overview,
                        style: const TextStyle(
                          fontSize: 18,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 512,
      height: 256,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: primaryColor,
        size: 128,
      ),
    );
  }
}