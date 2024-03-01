import 'dart:io'; // Importing dart:io for File operations
import 'dart:math'; // Importing dart:math for random number generation

import 'package:dio/dio.dart'; // Importing dio for network operations
import 'package:flutter/material.dart'; // Importing flutter material package for UI components
import 'package:get/get.dart'; // Importing get for state management
import 'package:path_provider/path_provider.dart'; // Importing path_provider for file paths
import 'package:permission_handler/permission_handler.dart'; // Importing permission_handler for handling permissions
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart'; // Importing dashed_circular_progress_bar for circular progress indicator

class ShowStatusDownloading extends StatefulWidget {
  const ShowStatusDownloading({super.key});
  static RxDouble valueDownloading =
      0.0.obs; // Reactive variable to track download progress

  @override
  State<ShowStatusDownloading> createState() => _ShowStatusDownloadingState();
}

class _ShowStatusDownloadingState extends State<ShowStatusDownloading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(
          28, 28, 28, 1), // Setting background color of the scaffold
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Nima Shamsi', // Setting app bar title
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        backgroundColor: const Color.fromRGBO(
            28, 28, 28, 1), // Setting app bar background color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: Obx(() => DashedCircularProgressBar.aspectRatio(
                    // Circular progress bar to show download status
                    aspectRatio: 1,
                    valueNotifier: ValueNotifier(100),
                    progress: ShowStatusDownloading.valueDownloading.value,
                    startAngle: 225,
                    sweepAngle: 360,
                    foregroundColor:
                        ShowStatusDownloading.valueDownloading.value == 100
                            ? const Color.fromARGB(255, 0, 255, 8)
                            : const Color.fromARGB(255, 255, 0, 0),
                    backgroundColor: const Color.fromARGB(255, 95, 95, 95),
                    foregroundStrokeWidth: 13,
                    backgroundStrokeWidth: 13,
                    animation: true,
                    seekSize: 10,
                    seekColor: const Color(0xffeeeeee),
                    child: Center(
                      child: ValueListenableBuilder(
                        valueListenable: ValueNotifier(
                          ShowStatusDownloading.valueDownloading.value,
                        ),
                        builder: (_, double value, __) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${value.toInt()}%', // Showing download percentage
                              style: const TextStyle(
                                color: Color(0xffeeeeee),
                                fontWeight: FontWeight.w300,
                                fontSize: 58,
                              ),
                            ),
                            const Text(
                              'Downloaded', // Displaying 'Downloaded' text
                              style: TextStyle(
                                color: Color(0xffeeeeee),
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            ),
            const SizedBox(height: 70),
            Obx(
              () => Container(
                width: 300,
                height: 50,
                padding: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: ShowStatusDownloading.valueDownloading.value == 100
                      ? const Color.fromARGB(255, 0, 255, 8)
                      : const Color.fromARGB(255, 255, 52, 38),
                  boxShadow: [
                    BoxShadow(
                      color: ShowStatusDownloading.valueDownloading.value == 100
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      blurRadius: 8,
                      spreadRadius: 0.5,
                    ),
                  ],
                  borderRadius: const BorderRadius.all(Radius.circular(22)),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'enter url video',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) async => await downloadVideo(value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> downloadVideo(String url) async {
  Dio dio = Dio(); // Creating Dio instance for network operations
  File fileName = File(
      '${Random().nextInt(1000)}.mp4'); // Generating a random file name for the downloaded video

  if (fileName.exists() == true) {
    fileName = File(
        '${Random().nextInt(1000)}.mp4'); // If file already exists, generate a new random name
  }
  try {
    String? directoryPath =
        await getDownloadFolderDirectory(); // Getting the download directory path

    if (directoryPath != null) {
      await dio.download(
        url,
        '$directoryPath/${fileName.path}', // Downloading the video to the specified path
        onReceiveProgress: (count, total) {
          if (total != -1) {
            ShowStatusDownloading.valueDownloading.value =
                (count / total) * 100; // Updating download progress
          }
        },
      );
    }
  } catch (e) {
    print('Error downloading video: $e'); // Handling download errors
  }
}

Future<String?> getDownloadFolderDirectory() async {
  Directory? directory;
  try {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        directory =
            await getExternalStorageDirectory(); // Getting the external storage directory
        String newPath = "";
        List<String> folders = directory!.path.split("/");
        for (int x = 1; x < folders.length; x++) {
          String folder = folders[x];
          if (folder != "Android") {
            newPath += "/$folder";
          } else {
            break;
          }
        }
        newPath = "$newPath/Download";
        directory =
            Directory(newPath); // Creating a new directory for downloads
      }
    }
  } catch (e) {
    print('$e');
    return null;
  }
  return directory?.path; // Returning the download directory path
}
