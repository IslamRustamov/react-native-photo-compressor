import * as React from 'react';

import {
  StyleSheet,
  View,
  Text,
  Image,
  Button,
} from 'react-native';
import { compressPhoto, getSizeInBytes } from 'react-native-photo-compressor';
import { useState } from 'react';
import { launchCamera } from 'react-native-image-picker';

export default function App() {
  const [image, setImage] = useState<string>();
  const [compressedImage, setCompressedImage] = useState<string>();

  async function openCamera() {
    const response = await launchCamera({ mediaType: 'photo' });

    if (response.assets && response.assets[0]) {
      const photo = response.assets[0].uri;
      const photoSize = await getSizeInBytes(photo!.replace('file://', ''));
      setImage(photo);

      console.log({ photo });
      console.log({ photoSize });

      const compressedPhoto = await compressPhoto(response.assets[0].uri!, 1);
      const compressedPhotoSize = await getSizeInBytes(compressedPhoto.replace('file://', ''));
      setCompressedImage(compressedPhoto);

      console.log({ compressedPhoto });
      console.log({ compressedPhotoSize });
    }
  }

  return (
    <View style={styles.container}>
      <View style={styles.block}>
        <Text>Uncompressed image:</Text>
        {!!image && <Image source={{ uri: image }} style={styles.image} />}
      </View>
      <View style={styles.separator} />
      <Button title={'Make a photo'} onPress={openCamera} />
      <View style={styles.separator} />
      <View style={styles.block}>
        <Text>Compressed image:</Text>
        {!!compressedImage && (
          <Image
            source={{ uri: 'file://' + compressedImage }}
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
    justifyContent: 'center',
  },
  block: {
    flex: 1,
    alignItems: 'center',
  },
  separator: {
    height: 50,
  },
  image: {
    width: 200,
    height: 200,
  },
});
