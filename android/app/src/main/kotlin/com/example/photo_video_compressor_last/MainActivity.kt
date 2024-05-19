package com.example.photo_video_compressor_last


import android.os.Build
import android.os.Environment
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.*

//import android.provider.MediaStore
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel





class MainActivity: FlutterActivity() {
    private val CHANNEL = "NativeChannel"

    @RequiresApi(Build.VERSION_CODES.Q)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if(call.method=="STARTPROCESS") {

                }else if (call.method == "STOPPROCESS") {

                } else if (call.method == "giveMEcameraData") {
                    val dataReturn = getCameraData()
                    
                    println("code 45756847967")
                    println("SUCCESS")
                    result.success(dataReturn)
                }else if (call.method=="giveMEThisFolderData"){
                val folderPath = call.argument<String>("Folderpath")
                if (folderPath != null) {
                    val dataReturn = getFolderData(folderPath)
                    result.success(dataReturn)
                } else {
                    result.error("INVALID_ARGUMENT", "Folderpath is null", null)
                }
            } else if (call.method=="deleteSource"){
                val file_path = call.argument<String>("filepath")
                val filePathAsString = file_path?.toString() ?: ""
                deleteSource(filePathAsString)
            }



            else if (call.method =="moveScours"){

//                println("moveScours CODE SLDKFJSOI3445")
                val file_path = call.argument<String>("filepath")
                val filePathAsString = file_path?.toString() ?: ""


                val folder_path_move_to = call.argument<String>("folderpath")
                val folderPathAsString = folder_path_move_to?.toString() ?: ""

                val fileMovedPath = moveFile(filePathAsString,folderPathAsString)
                result.success(fileMovedPath)
            } else if (call.method =="moveScoursVideo"){
//                println("moveScours CODE SLDKFJSOI3445")
                val file_path = call.argument<String>("filepath")
                val filePathAsString = file_path?.toString() ?: ""

                val mainFileName = call.argument<String>("mainFileName")


                val folder_path = call.argument<String>("folder-path")
                val folder_pathtring = folder_path?.toString() ?: ""

                if (mainFileName != null && filePathAsString.isNotBlank()) {
                    val fileMovedPath = moveFileVideo(mainFileName,filePathAsString,folder_pathtring)
                    result.success(fileMovedPath)
                } else {
                    result.error("INVALID_ARGUMENTS", "mainFileName or filePathAsString is null or blank", null)
                }



//                println("this is the file path")
//                println(filePathAsString)
//                result.success(fileMovedPath)
            }else {

            }
        }
    }
    //    private fun openImagePicker() {
//        println("in open image picker id 453_34534")
//        val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
//        startActivityForResult(intent, REQUEST_IMAGE_PICKER)
//    }
//
//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        super.onActivityResult(requestCode, resultCode, data)
//
//        if (requestCode == REQUEST_IMAGE_PICKER && resultCode == RESULT_OK) {
//            val selectedImageUri: Uri? = data?.data
//            if (selectedImageUri != null) {
//                val filePath = getRealPathFromURI(selectedImageUri)
//                // Communicate the file path back to Flutter
//                val methodChannel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "your_channel_name")
//                methodChannel.invokeMethod("onImagePicked", mapOf("filePath" to filePath))
//            }
//        }
//    }
    @RequiresApi(Build.VERSION_CODES.Q)
    private fun createTheFolder(to : String): Boolean {

//        println("inside the function")
//        val extStoragePath = Environment.getExternalStorageDirectory ().absolutePath
        // Create a folder name
//        val folderName = "Compressed_media_RM"
        // Create a File object with the folder path
        val folder = File (to)

        // Check if the folder exists and create it if not
//        println("i will check if the folder created or no")
        if (!folder.exists ()) {
            val result = folder.mkdirs ()
            if (result) {
                // The folder was created successfully
                Log.d ("TAG", "Folder created: $folder")
                return true
            } else {
                // The folder creation failed
                Log.e ("TAG", "Folder creation failed")
                return false
            }
        }else{
            println("the app folder is already existed")
            return true
        }
    }


    fun moveFile(from: String, to: String) : String {
        val folderCreated = createTheFolder(to)

        if (folderCreated) {
            // result.success("Folder created successfully")
            // Get the source file from the internal storage
            val parts = from.split(File.separator)

            // Get the last part, which should be the file name
            val fileName = parts.last()
            val directoryPath = parts.dropLast(1).joinToString(File.separator)
            val sourceFile = File(directoryPath, fileName)


            // Get the destination directory from the external storage
            val destinationDir = to

            if (destinationDir != null) {
                // Check if the destination directory exists, and create it if not
//            if (!destinationDir.exists()) {
//                destinationDir.mkdirs()
//            }

                // Create the destination file with the same name as the source file
                val destinationFile = File(destinationDir, sourceFile.name)

                // Move the source file to the destination file using renameTo()
                val result = sourceFile.renameTo(destinationFile)

                // Check if the operation was successful or not
                if (result) {
                    // The file was moved successfully
//                    println("The file was moved successfully to ${destinationFile.path}")
                    return destinationFile.path
                } else {
                    // The file could not be moved
                    println("The file could not be moved")
                    return "failed"
                }
            } else {
                // Handle the case where getExternalFilesDir returned null
                println("External storage directory is null. File move operation failed.")
                return "failed"
            }
        } else {
//            result.error("CREATE_FOLDER_ERROR", "Failed to create folder", null)
            return "failed"
        }


    }


    fun moveFileVideo(mainFileNname : String,from: String, to: String) : String {
        val folderCreated = createTheFolder(to)

        if (folderCreated) {
            // result.success("Folder created successfully")
            // Get the source file from the internal storage
            val parts = from.split(File.separator)

            // Get the last part, which should be the file name
            val fileName = parts.last()
//            print(fileName)
            print("step 1 ")
            val directoryPath = parts.dropLast(1).joinToString(File.separator)

            print("step 2 ")
            val sourceFile = File(directoryPath, fileName)
            print("step 3 ")

            // Get the destination directory from the external storage
            val destinationDir = to

            if (destinationDir != null) {
                // Check if the destination directory exists, and create it if not
//            if (!destinationDir.exists()) {
//                destinationDir.mkdirs()
//            }
                print("step 4 ")
                // Create the destination file with the same name as the source file
                val destinationFile = File(destinationDir, mainFileNname)
                print("step 5 ")
                // Move the source file to the destination file using renameTo()
                val result = sourceFile.renameTo(destinationFile)
                print("step 6 ")
                // Check if the operation was successful or not
                if (result) {
                    // The file was moved successfully
//                    println("The file was moved successfully to ${destinationFile.path}")
                    return destinationFile.path
                } else {
                    // The file could not be moved
                    println("The file could not be moved")
                    return "failed"
                }
            } else {
                // Handle the case where getExternalFilesDir returned null
                println("External storage directory is null. File move operation failed.")
                return "failed"
            }
        } else {
//            result.error("CREATE_FOLDER_ERROR", "Failed to create folder", null)
            return "failed"
        }


    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun getFolderData(FolderPath: String): Map<String, String> {
        val resultMap = mutableMapOf<String, String>()
        try {
            // Ensure FolderPath is not nullable
            val workingDirectory = File(FolderPath)
            if (workingDirectory.exists()) {
                println("sdklfjsdl folder existed")

                if (workingDirectory.exists() && workingDirectory.isDirectory) {
                    val subfolderFiles = workingDirectory.listFiles()
                    println("at 9238745_3458909")
                    println(subfolderFiles)

                    subfolderFiles?.forEach { file ->
                        if (file.isFile) {
                            val path = file.absolutePath
                            val lastModified = file.lastModified().toString()
                            resultMap[path] = lastModified
                        }
                    }
                }
            }
        } catch (e: Exception) {
            throw e
        }
        println("resultMapfdfd")
        println(resultMap)
        return resultMap
    }


    @RequiresApi(Build.VERSION_CODES.Q)
    private fun getCameraData(): Map<String, String>? {
//        println("inside the native fun get camera files")
        val resultMap = mutableMapOf<String, String>()
        try {
            val dcimDirectory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM)
            if (dcimDirectory != null && dcimDirectory.isDirectory) {
                // Specify the subfolder name where camera files are located
                val subfolderName = "Camera"

                // Create a File object for the subfolder
                val subfolder = File(dcimDirectory, subfolderName)
                println("code 39487_34534")
                println(subfolder)


                if (subfolder.exists() && subfolder.isDirectory) {
                    val subfolderFiles = subfolder.listFiles()
                   println("at 9238745_3458909")
                   println(subfolderFiles)
                    if (subfolderFiles == null){
                        resultMap["error"] = "cannot get the permission"
                        return resultMap
                     }
                    subfolderFiles?.forEach { file ->
                        if (file.isFile) {
                            val path = file.absolutePath
                           println(path)
                            val lastModified = file.lastModified().toString()
                           println(lastModified)
                            resultMap[path] = lastModified
                        }
                    }
                }
            }
        } catch (e: Exception) {
            throw e
        }
        println("resultMapfdfd")
        println(resultMap)
        return resultMap
    }

    fun deleteSource(file_path :String ) {
//        println("in delete source ")
//        println(file_path)

        val file = File(file_path)

        try {
            // Attempt to delete the file
            if (file.delete()) {
                println("File deleted successfully.")
            } else {
                println("Failed to delete the file.")
            }
        } catch (e: SecurityException) {
            println("Error: Permission denied to delete the file.")
        } catch (e: Exception) {
            println("An error occurred while deleting the file: ${e.message}")
        }
    }


}