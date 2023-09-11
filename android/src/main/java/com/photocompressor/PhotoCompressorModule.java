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
  public void compressPhoto(String uri, double quality, String fileName, Boolean forceRewrite, Promise promise) {
    CompressStrategy compressStrategy = new CompressStrategy(
      mContext,
      uri,
      quality,
      fileName,
      forceRewrite,
      promise
    );

    compressStrategy.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
  }

  @Override
  public void getSizeInBytes(String uri, String size, Promise promise) {
    SizeStrategy sizeStrategy = new SizeStrategy(
      mContext,
      uri,
      size,
      promise
    );

    sizeStrategy.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
  }

  @Override
  public void deletePhoto(String uri, Promise promise) {
    DeleteStrategy deleteStrategy = new DeleteStrategy(
      mContext,
      uri,
      promise
    );

    deleteStrategy.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
  }

  private static class SizeStrategy extends GuardedAsyncTask<Void, Void> {
    final ReactApplicationContext mContext;
    final Promise mPromise;
    final String mUri;
    final String mSize;

    private SizeStrategy(
      ReactApplicationContext context,
      String uri,
      String size,
      Promise promise
    ) {
      super(context);
      mContext = context;
      mPromise = promise;
      mUri = uri;
      mSize = size;
    }

    enum SizeType {
      b,
      kb,
      mb
    }

    @Override
    protected void doInBackgroundGuarded(Void... params) {
      try {
        File file = new File(mUri.replace("file://", ""));

        if (!file.exists()) {
          throw new Exception("File does not exist");
        }

        long fileSizeInBytes = file.length();

        SizeType sizeType = SizeType.valueOf(mSize);

        switch (sizeType) {
          case kb:
            mPromise.resolve((double) fileSizeInBytes / 1024);
            break;
          case mb:
            mPromise.resolve((double) fileSizeInBytes / 1024 / 1024);
            break;
          default:
            mPromise.resolve((double) fileSizeInBytes);
            break;
        }
      } catch (Exception e) {
        mPromise.reject(e);
      }
    }
  }

  private static class DeleteStrategy extends GuardedAsyncTask<Void, Void> {
    final ReactApplicationContext mContext;
    final Promise mPromise;
    final String mUri;

    private DeleteStrategy(
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
        if (!mUri.contains("/RNPhotoCompressorImages/")) {
          throw new Exception("Incorrect directory.");
        }

        File file = new File(mUri.replace("file://", ""));

        if (!file.exists()) {
          throw new Exception("File does not exist");
        }

        file.delete();
        mPromise.resolve(null);
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
    final String mFileName;
    final Boolean mForceRewrite;

    private CompressStrategy(
      ReactApplicationContext context,
      String uri,
      double quality,
      String fileName,
      boolean forceRewrite,
      Promise promise
      ) {
      super(context);
      mContext = context;
      mPromise = promise;
      mUri = uri;
      mQuality = quality;
      mFileName = fileName;
      mForceRewrite = forceRewrite;
    }

    @Override
    protected void doInBackgroundGuarded(Void... params) {
      Bitmap bitmap;

      try {
        Uri imageUri = Uri.parse(mUri);

        bitmap = MediaStore.Images.Media.getBitmap(mContext.getContentResolver(), imageUri);

        File cacheDir = mContext.getExternalCacheDir();

        File folder = new File(cacheDir, "/RNPhotoCompressorImages/");
        if (!folder.exists()) {
            folder.mkdirs();
        }

        File fileName;
        if (mFileName instanceof String) {
          fileName = new File(folder, "/" + mFileName + ".jpeg");
        } else {
          String uniqueID = UUID.randomUUID().toString();
          fileName = new File(folder, "/" + uniqueID + ".jpeg");
        }

        if (fileName.exists() && !mForceRewrite) {
          throw new Exception("File with this name already exists");
        }

        FileOutputStream out = new FileOutputStream(String.valueOf(fileName));
        bitmap.compress(Bitmap.CompressFormat.JPEG, (int) mQuality, out);
        out.close();

        mPromise.resolve("file://" + String.valueOf(fileName));
      } catch (Exception e) {
        mPromise.reject(e);
      }
    }
  }
}
