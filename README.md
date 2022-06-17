<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

[![codecov](https://codecov.io/gh/OpenVisu/openvisu_bloc/branch/main/graph/badge.svg?token=FZH5WMDI0Y)](https://codecov.io/gh/OpenVisu/openvisu_bloc)


A Dart Package wich handels all Bloc, State, Event related code used by OpenVisu. Furthermore some custom state handling widgets are provided.

This Package is not yet stable and things might change without prior notice!

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

Import package:
```dart
import 'package:openvisu_bloc/openvisu_bloc.dart';
```

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
const like = 'sample';
```

## Run tests

Start the test environment and import test data:
```bash
docker compose -f "test/docker-compose.yaml" up -d
docker compose -f "test/docker-compose.yaml" cp test/data/mysql/init.sql db:/init.sql
docker compose -f "test/docker-compose.yaml" exec -T db sh -c 'exec mariadb -u root --password=yi5S7LHWONx0qWhd openvisu ' < test/data/mysql/init.sql
```

Run the tests:
```bash
flutter test
```

### To update the test data set run 
```bash
docker compose -f "test/docker-compose.yaml" exec db /usr/bin/mysqldump -u root --password=yi5S7LHWONx0qWhd openvisu > test/data/mysql/init.sql
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
