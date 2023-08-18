package com.photocompressor;

import android.content.Context;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.Promise;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.bridge.GuardedAsyncTask;

import java.io.File;
import java.io.FileOutputStream;
import java.util.UUID;

@ReactModule(name = PhotoCompressorModule.NAME)
public class PhotoCompressorModule extends NativePhotoCompressorSpec {
  public static final String NAME = "PhotoCompressor";
  final ReactApplicationContext mContext;

  public PhotoCompressorModule(ReactApplicationContext reactContext) {
    super(reactContext);
    mContext = reactContext;
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  @Override
  public void compressPhoto(String uri, double quality, Promise promise) {
    CompressStrategy compressStrategy = new CompressStrategy(
      mContext,
      uri,
      quality,
      promise
    );

    compressStrategy.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
  }

  @Override
  public void getSizeInBytes(String uri, Promise promise) {
    SizeStrategy sizeStrategy = new SizeStrategy(
      mContext,
      uri,
      promise
    );

    sizeStrategy.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
  }

  private static class SizeStrategy extends GuardedAsyncTask<Void, Void> {
    final ReactApplicationContext mContext;
    final Promise mPromise;
    final String mUri;

    private SizeStrategy(
      ReactApplicationContext context,
      String uri,
      Promise promise
    ) {
      super(context);
      mContext = context;
      mPromise = promise;
      mUri = uri;
    }

    @Override
    protected void doInBackgroundGuarded(Void... params) {
      try {
        File file = new File(mUri);

        long fileSizeInBytes = file.length();

        mPromise.resolve((double) fileSizeInBytes);
      } catch (Exception e) {
        mPromise.reject(e);
      }
    }
  }

  private static class CompressStrategy extends GuardedAsyncTask<Void, Void> {
    final ReactApplicationContext mContext;
    final Promise mPromise;
    final String mUri;
    final double mQuality;

    private CompressStrategy(
      ReactApplicationContext context,
      String uri,
      double quality,
      Promise promise
      ) {
      super(context);
      mContext = context;
      mPromise = promise;
      mUri = uri;
      mQuality = quality;
    }

    @Override
    protected void doInBackgroundGuarded(Void... params) {
      Bitmap bitmap;

      try {
        Uri imageUri = Uri.parse(mUri);

        bitmap = MediaStore.Images.Media.getBitmap(mContext.getContentResolver(), imageUri);

        String root = Environment.getExternalStorageDirectory().toString();

        String uniqueID = UUID.randomUUID().toString();

        FileOutputStream out = new FileOutputStream(root + "/" + uniqueID + ".jpeg");

        bitmap.compress(Bitmap.CompressFormat.JPEG, (int) mQuality, out);

        out.close();

        mPromise.resolve("file://" + root + "/" + uniqueID + ".jpeg");
      } catch (Exception e) {
        mPromise.reject(e);
      }
    }
  }
}
