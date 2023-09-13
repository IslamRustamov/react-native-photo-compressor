import * as React from 'react';

import { StyleSheet, View, Text, Image, Button } from 'react-native';
import {
  compressPhoto,
  compressPhotoArray,
  deletePhoto,
  getSizeInBytes,
} from 'react-native-photo-compressor';
import { useState } from 'react';
import { launchCamera, launchImageLibrary } from 'react-native-image-picker';

export default function App() {
  const [image, setImage] = useState<string>();
  const [compressedImage, setCompressedImage] = useState<string>();

  async function openCamera() {
    try {
      const response = await launchCamera({ mediaType: 'photo' });

      if (response.assets && response.assets[0]) {
        const photo = response.assets[0].uri;
        const photoSize = await getSizeInBytes(photo!);
        setImage(photo);

        console.log({ photo });
        console.log({ photoSize });

        const compressedPhoto = await compressPhoto(
          photo!,
          10,
          'myFileName',
          true
        );
        const compressedPhotoSize = await getSizeInBytes(compressedPhoto);
        setCompressedImage(compressedPhoto);

        console.log({ compressedPhoto });
        console.log({ compressedPhotoSize });
      }
    } catch (e) {
      console.log(e);
    }
  }

  async function openImageLibrary() {
    try {
      const response = await launchImageLibrary({ selectionLimit: 0 });
      if (response.assets) {
        const currentIndex = 0;
        const imageArray: string[] = response.assets.map(
          (img) => img.uri || ''
        );

        const photoSize = await getSizeInBytes(imageArray[currentIndex]);
        setImage(imageArray[currentIndex]);

        console.log(imageArray[currentIndex]);
        console.log({ photoSize });

        const compressedImageArray = await compressPhotoArray(
          imageArray,
          10,
          true,
          (event) => console.log(event)
        );
        const compressedPhotoSize = await getSizeInBytes(
          compressedImageArray[currentIndex]
        );
        setCompressedImage(compressedImageArray[currentIndex]);

        console.log({ compressedImageArray });
        console.log({ compressedPhotoSize });
      }
    } catch (e) {
      console.log(e);
    }
  }

  async function deleteCompressedPhoto() {
    try {
      await deletePhoto(compressedImage!);
      console.log('Photo is deleted');
    } catch (e) {
      console.log(e);
    }
  }

  return (
    <View style={styles.container}>
      <View style={styles.block}>
        <Text>Uncompressed image:</Text>
        {!!image && <Image source={{ uri: image }} style={styles.image} />}
      </View>
      <View>
        <Button title={'Make a photo'} onPress={openCamera} />
        <Button
          title={'Compress images from library'}
          onPress={openImageLibrary}
        />
        <Button
          title={'Delete compressed photo'}
          onPress={deleteCompressedPhoto}
        />
      </View>
      <View style={styles.block}>
        <Text>Compressed image:</Text>
        {!!compressedImage && (
          <Image
            source={{
              uri: compressedImage + '?' + new Date(),
            }}
            style={styles.image}
          />
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'space-around',
    marginVertical: 5,
  },
  block: {
    alignItems: 'center',
  },
  image: {
    width: 200,
    height: 200,
  },
});
