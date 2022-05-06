// Copyright (c) 2022 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical
// or instructional purposes related to programming, coding, application
// development, or information technology.  Permission for such use, copying,
// modification, merger, publication, distribution, sublicensing, creation of
// derivative works, or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

package com.raywenderlich.photos_keyboard

import io.flutter.embedding.android.FlutterFragmentActivity
import android.Manifest
import android.content.ContentResolver
import android.content.ContentUris
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import com.bumptech.glide.Glide
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : FlutterFragmentActivity() {
    private var methodResult: MethodChannel.Result? = null
    private var queryLimit: Int = 0

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, "com.raywenderlich.photos_keyboard")
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "getPhotos" -> {
                            methodResult = result
                            queryLimit = call.arguments()
                            getPhotos()
                        }
                        "fetchImage" -> fetchImage(call.arguments(), result)
                        else -> result.notImplemented()
                    }
                }
    }

    private fun getCursor(limit: Int): Cursor? {
        //1
        val uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(MediaStore.Images.Media._ID)

        //2
        return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            val sort = "${MediaStore.Images.ImageColumns.DATE_MODIFIED} DESC LIMIT $limit"
            contentResolver.query(uri, projection, null, null, sort)
        } else {
            //3
            val args = Bundle().apply {
                putInt(ContentResolver.QUERY_ARG_LIMIT, limit)
                putStringArray(
                        ContentResolver.QUERY_ARG_SORT_COLUMNS,
                        arrayOf(MediaStore.Images.ImageColumns.DATE_MODIFIED)
                )
                putInt(
                        ContentResolver.QUERY_ARG_SORT_DIRECTION,
                        ContentResolver.QUERY_SORT_DIRECTION_DESCENDING
                )
            }
            contentResolver.query(uri, projection, args, null)
        }
    }

    private fun getImageBytes(uri: Uri?, width: Int, height: Int, onComplete: (ByteArray) -> Unit) {
        lifecycleScope.launch(Dispatchers.IO) {
            try {
                val r = Glide.with(this@MainActivity)
                        .`as`(ByteArray::class.java)
                        .load(uri)
                        .submit(width, height).get()
                onComplete(r)
            } catch (t: Throwable) {
                onComplete(byteArrayOf())
            }
        }
    }

    private fun getPhotos() {
        if (queryLimit == 0 || !hasStoragePermission()) return

        lifecycleScope.launch(Dispatchers.IO) {
            val ids = mutableListOf<String>()
            val cursor = getCursor(queryLimit)
            cursor?.use {
                while (cursor.moveToNext()) {
                    val columnIndex = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
                    val long = cursor.getLong(columnIndex)
                    ids.add(long.toString())
                }
            }
            methodResult?.success(ids)
        }
    }

    private fun fetchImage(args: Map<String, Any>, result: MethodChannel.Result) {
        // 1
        val id = (args["id"] as String).toLong()
        val width = (args["width"] as Double).toInt()
        val height = (args["height"] as Double).toInt()

        // 2
        val uri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)
        getImageBytes(uri, width, height) {
            result.success(it)
        }
    }

    private val permissionLauncher =
            registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
                if (granted) {
                    getPhotos()
                } else {
                    methodResult?.error("0", "Permission denied", "")
                }
            }

    private fun hasStoragePermission(): Boolean {
        // 1
        val permission = Manifest.permission.READ_EXTERNAL_STORAGE
        // 2
        val state = ContextCompat.checkSelfPermission(this, permission)
        if (state == PackageManager.PERMISSION_GRANTED) return true

        // 3
        permissionLauncher.launch(permission)
        return false
    }
}
