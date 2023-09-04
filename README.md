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

Don't forget to change `newArchEnabled` to `true` in *android/gradle.properties* and run `./gradlew generateCodegenArtifactsFromSchema
` if needed.

## Usage


```js
import { compressPhoto, getSizeInBytes } from 'react-native-photo-compressor';

// ...

const compressedPhoto = await compressPhoto('file://some/photo.png', 50);
await getSizeInBytes('file://some/photo.png');
```

## compressPhoto arguments

| Argument | Info                                                             |
|----------|------------------------------------------------------------------|
| uri      | string, path to the photo, must contain *file://* prefix         |
| quality  | number, value from 0 to 100 (smaller number -> more compression) |


## Work in progress

- [x] Implement turbo module for Android
- [ ] Refactor Android turbo module
- [ ] Add more configuration for Android turbo module (like deleting photos, specific urls and etc.)
- [ ] Implement turbo module for iOS

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
