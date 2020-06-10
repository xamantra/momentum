# MomentumService
An abstract class used for marking any classes you create as a `service` class. Services can by anything. It can be a class that wraps all your HTTP calls (api service), notifications, file watcher, cloud downloader, email handler, etc.

- This class doesn't have any property, methods, or behaviors.
- Only used for marking really.

The most common service in a project is an `ApiService`.
```dart
class ApiService extends MomentumService {

  // ...

  Future<AuthResponse> auth({String username, String password}) async {
    var response = await http.post(link, body: {'username': username, 'password': password});
    var parsed = AuthResponse.fromJson(response.data);
    return parsed;
  }

  Future<UserProfile> getProfile({int userId}) async {
    var response = await http.get(link, body: {'userId': userId});
    var parsed = UserProfile.fromJson(response.data);
    return parsed;
  }

  // ...
}
```
Down the widget tree, you can use it like this inside a controller:
```dart
class AuthController extends MomentumController<AuthModel> {

  // ...

  Future<void> login() async {
    var apiService = getService<ApiService>();
    var response = await apiService.auth(
      username: model.username, 
      password: model.password
    );
    if (response.success) {
      var profile = await apiService.getProfile(userId: response.userId);
      model.update(profile: profile);
    }
  }

  // ...
}
```

!> Head to this [section](/momentum?id=services) to know how to setup a service.