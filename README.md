# post_rest

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## REST client added

This workspace now includes a small REST client for posts using the Dart `http` package.

Files added/updated:
- `lib/src/models/post.dart` - Post model with JSON (de)serialization.
- `lib/src/client/rest_client.dart` - RestClient using `package:http` for CRUD operations against `/posts`.
- `lib/src/services/post_service.dart` - Thin service wrapper around RestClient.
- `lib/rest_client.dart` - Public exports.
- `test/post_model_test.dart` - Model roundtrip unit test.
- `test/rest_client_test.dart` - Unit tests for RestClient using `MockClient`.

Quick start:

1. Get packages:

```bash
flutter pub get
```

2. Run tests:

```bash
flutter test
```

Usage example (Dart):

```dart
import 'package:post_rest/rest_client.dart';

void main() async {
	final client = RestClient();
	final service = PostService(client);
	final posts = await service.list(limit: 5);
	print('Got \'${posts.length}\' posts');
}
```
