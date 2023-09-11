# react-native-photo-compressor

React Native Turbo Modules that allow you to compress your photos by given URI and quality parameter

## Installation

```sh
npm install react-native-photo-compressor
```
or
```sh
yarn add react-native-photo-compressor
```

### Android

Android configuration requires to enable the New Architecture:

1. Open the android/gradle.properties file
2. Scroll down to the end of the file and switch the newArchEnabled property from false to true.

### iOS

```
bundle install
cd ios
RCT_NEW_ARCH_ENABLED=1 bundle exec pod install
```

## Usage

```js
import { compressPhoto, getSizeInBytes, deletePhoto } from 'react-native-photo-compressor';

// ...

const compressedPhoto = await compressPhoto('file://some/photo.png', 50);
const remoteCompressedPhoto = await compressPhoto('http://remote/photo.png', 50);
const namedCompressedPhoto = await compressPhoto('file://some/photo.png', 50, 'myFileName', true);

const photoSize = await getSizeInBytes('file://some/photo.png');
await deletePhoto('file://some/photo.png');
```

## API

### ```compressPhoto(uri: string, quality: number, fileName?: string, forceRewrite?: boolean): Promise<string>```
Creates a compressed copy of the image at the given ```uri``` inside a ```/RNPhotoCompressorImages``` directory.</br>
Also supports images from web url. In this case ```uri``` should start with ```"http"```.

| Argument      | Info                                                                                                    |
|---------------|---------------------------------------------------------------------------------------------------------|
| uri           | string, path to the photo, must contain *file://* prefix                                                |
| quality       | number, value from 0 to 100 (smaller number -> more compression)                                        |
| fileName?     | string, optional name of the compressed photo                                                           |
| forceRewrite? | boolean, optional flag to force the file to be overwritten if a file with the given name already exists |

### ```getSizeInBytes(uri: string, size?: SizeType): Promise<number>```
Returns the size of the file in bytes at the given ```uri```.
```SizeType``` defines the format of the return value and can be either ```"kb"``` or ```"mb"```(default: ```"b"```).

### ```deletePhoto(uri: string): Promise<void>;```
Deletes a compressed image at a given ```uri```.</br>
Note: Only works for files inside a ```/RNPhotoCompressorImages``` directory.


## Troubleshooting

If you get this error when building iOS:
```
/Users/user/Desktop/testApp/ios/Pods/../../node_modules/react-native/scripts/codegen/generate-legacy-interop-components.js: Permission denied
```
1. Open a terminal, run this command and copy the result
```
command -v node
```
2. Open ```.xcode.env``` file in ios directory and replace
```
export NODE_BINARY=$(command -v node)
```
to
```
export NODE_BINARY=~/your/node/path
```

## Work in progress

- [x] Implement turbo module for Android
- [x] Implement turbo module for iOS
- [x] Add more configuration for turbo module (like deleting photos, specific urls and etc.)
- [ ] Refactor Android turbo module

## Contributing

If you want to add more functionality to this:
1. Fork repo
2. Implement wanted feature
3. Create a PR into master

Or
1. Create an issue
2. Describe the feature you want
3. Tag author

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
