import 'dart:io';
import 'package:sync_sqflit_and_core/Config/constants.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../APIServices/DynamicApiServices.dart';
import '../Helpers/SQliteDbHelper.dart';
import '../Models/CourseModel.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart' as dio;

class CourseController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ApiService _apiService = ApiService();
  var courseList = <CourseModel>[].obs;
  CourseModel? courseDetail;
  var isLoading = true.obs;
  var needsSync = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCourseList();
    // مراقبة حالة الاتصال
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && needsSync.value) {
        syncWithServer();
      }
    });
  }

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> getCourseList() async {
    try {
      isLoading(true);
      bool isConnected = await _checkConnectivity();

      if (isConnected) {
        final response = await _apiService.get('$baseAPIURLV1/courses/');
        if (response.statusCode == 200) {
          // تأكد من أن البيانات تأتي في الشكل الصحيح
          if (response.data is Map && response.data['results'] != null) {
            final List coursesList = response.data['results'];
            final courses = coursesList
                .map((json) => CourseModel.fromMap(json))
                .toList();
            courseList.value = courses;
            
            // تحديث قاعدة البيانات المحلية
            for (var course in courses) {
              try {
                await _databaseHelper.insertCourse(course);
              } catch (e) {
                debugPrint('Failed to sync course ${course.id}: $e');
              }
            }
          } else {
            debugPrint('Invalid response format: ${response.data}');
            // استخدام البيانات المحلية كاحتياطي
            final localCourses = await _databaseHelper.getCourses();
            courseList.value = localCourses;
          }
        }
      } else {
        // استرجاع البيانات من قاعدة البيانات المحلية
        final localCourses = await _databaseHelper.getCourses();
        courseList.value = localCourses;
        Get.snackbar(
          "Info", 
          "No internet connection. Showing local data.",
          snackPosition: SnackPosition.BOTTOM,
        );
        needsSync.value = true;
      }
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      // استخدام البيانات المحلية في حالة الخطأ
      final localCourses = await _databaseHelper.getCourses();
      courseList.value = localCourses;
      Get.snackbar(
        "Error", 
        "Failed to fetch courses. Showing local data.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> getCourseDetails(int courseId) async {
    try {
      isLoading(true);

      // Fetch data from the local database
      final localCourses = await _databaseHelper.getCourses();
      courseDetail = localCourses.firstWhere((course) => course.id == courseId);

    } catch (e) {
      Get.snackbar("Error", "Failed to fetch course details: $e",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addCourse({
    required String title,
    required String overview,
    required String subject,
    File? photo,
  }) async {
    try {
      isLoading(true);
      bool isConnected = await _checkConnectivity();
      
      if (isConnected) {
        // تجهيز البيانات
        final formData = dio.FormData();
        
        // إضافة البيانات الأساسية
        formData.fields.addAll([
          MapEntry('title', title),
          MapEntry('subject', subject),
          MapEntry('overview', overview),
        ]);

        // إضافة الصورة إذا وجدت
        if (photo != null) {
          formData.files.add(
            MapEntry(
              'photo',
              await dio.MultipartFile.fromFile(
                photo.path,
                filename: photo.path.split('/').last,
              ),
            ),
          );
        }

        // إرسال الطلب بدون تحديد Content-Type
        final response = await _apiService.post(
          '$baseAPIURLV1/teachers/courses/create/',
          data: formData,
        );

        if (response.statusCode == 201) {
          final serverCourse = CourseModel.fromMap(response.data);
          await _databaseHelper.insertCourse(serverCourse);
          Get.snackbar(
            'Success', 
            'Course added successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        // حفظ محلياً عند عدم وجود اتصال
        final newCourse = CourseModel(
          id: DateTime.now().millisecondsSinceEpoch,
          owner: 'current_user',
          title: title,
          subject: subject,
          overview: overview,
          photo: photo?.path,
          totalStudents: 0,
          totalModules: 0,
          created: DateTime.now().toIso8601String(),
        );
        
        await _databaseHelper.insertCourse(newCourse);
        Get.snackbar(
          'Info', 
          'Course saved locally. Will sync when online.',
          snackPosition: SnackPosition.BOTTOM,
        );
        needsSync.value = true;
      }
    } catch (e) {
      debugPrint('Error adding course: $e');
      Get.snackbar(
        'Error', 
        'Failed to add course. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
      getCourseList();
    }
  }

  Future<void> updateCourse(
    int courseId, {
    required String title,
    required String overview,
    required String subject,
    File? photo,
  }) async {
    try {
      isLoading(true);
      final updatedCourse = CourseModel(
        id: courseId,
        owner: 'current_user',
        title: title,
        subject: subject,
        overview: overview,
        photo: photo?.path,
        totalStudents: courseDetail?.totalStudents ?? 0,
        totalModules: courseDetail?.totalModules ?? 0,
        created: courseDetail?.created ?? DateTime.now().toIso8601String(),
      );

      bool isConnected = await _checkConnectivity();
      if (isConnected) {
        // تحديث في API أولاً
        final response = await _apiService.put(
          '$baseAPIURLV1/courses/$courseId/',
          data: updatedCourse.toMap(),
        );
        if (response.statusCode == 200) {
          // تحديث قاعدة البيانات المحلية
          await _databaseHelper.updateCourse(updatedCourse);
          Get.snackbar('Success', 'Course updated successfully');
        }
      } else {
        // تحديث محلياً فقط
        await _databaseHelper.updateCourse(updatedCourse);
        Get.snackbar('Info', 'Course updated locally. Will sync when online.');
        needsSync.value = true;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update course: $e');
    } finally {
      isLoading(false);
      getCourseList();
    }
  }

  Future<void> deleteCourse(int courseId) async {
    try {
      isLoading(true);
      bool isConnected = await _checkConnectivity();

      if (isConnected) {
        // حذف من API أولاً
        final response = await _apiService.delete(
          '$baseAPIURLV1/courses/$courseId/',
        );
        if (response.statusCode == 204) {
          // حذف من قاعدة البيانات المحلية
          await _databaseHelper.deleteCourse(courseId);
          Get.snackbar('Success', 'Course deleted successfully');
        }
      } else {
        // حذف محلياً فقط
        await _databaseHelper.deleteCourse(courseId);
        Get.snackbar('Info', 'Course deleted locally. Will sync when online.');
        needsSync.value = true;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete course: $e');
    } finally {
      isLoading(false);
      getCourseList();
    }
  }

  Future<void> syncWithServer() async {
    try {
      isLoading(true);
      final localCourses = await _databaseHelper.getCourses();
      
      // مزامنة كل الدورات مع الخادم
      for (var course in localCourses) {
        try {
          await _apiService.put(
            '$baseAPIURLV1/courses/${course.id}/',
            data: course.toMap(),
          );
        } catch (e) {
          print('Failed to sync course ${course.id}: $e');
        }
      }
      
      needsSync.value = false;
      Get.snackbar('Success', 'All courses synced with server');
    } catch (e) {
      Get.snackbar('Error', 'Failed to sync with server: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> syncCourse(CourseModel course) async {
    try {
      await _databaseHelper.insertCourse(course);
    } catch (e) {
      debugPrint('Failed to sync course ${course.id}: $e');
    }
  }
}
