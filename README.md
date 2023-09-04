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
import { compressPhoto, getSizeInBytes } from 'react-native-photo-compressor';

// ...

const compressedPhoto = await compressPhoto('file://some/photo.png', 50);
const photoSize = await getSizeInBytes('file://some/photo.png');
```

## compressPhoto arguments

| Argument | Info                                                             |
|----------|------------------------------------------------------------------|
| uri      | string, path to the photo, must contain *file://* prefix         |
| quality  | number, value from 0 to 100 (smaller number -> more compression) |


## Work in progress

- [x] Implement turbo module for Android
- [x] Implement turbo module for iOS
- [ ] Refactor Android turbo module
- [ ] Add more configuration for Android turbo module (like deleting photos, specific urls and etc.)

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
