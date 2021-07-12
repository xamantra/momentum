# MomentumService
An abstract class used for marking any classes you create as a `service` class. Services can by anything. It can be a class that wraps all your HTTP calls (API service), notifications, file watcher, cloud downloader, email handler, etc.

- This class doesn't have any property, methods, or behaviors.
- Only used for marking really.

The most common service in a project is an `ApiService`.
```dart
class ApiService extends MomentumService {

  // ...

  Future<AuthResponse> auth({String username, String password}) async {
    final response = await http.post(link, body: {'username': username, 'password': password});
    final parsed = AuthResponse.fromJson(response.data);
    return parsed;
  }

  Future<UserProfile> getProfile({int userId}) async {
    final response = await http.get(link, body: {'userId': userId});
    final parsed = UserProfile.fromJson(response.data);
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
    final apiService = service<ApiService>();
    final response = await apiService.auth(
      username: model.username, 
      password: model.password
    );
    if (response.success) {
      final profile = await apiService.getProfile(userId: response.userId);
      model.update(profile: profile);
    }
  }

  // ...
}
```

!> Head to this [section](/momentum?id=services) to know how to set up a service.

<hr>

## .service\<T\>()
- Category: `Method`
- Type: `T` extends `MomentumService`

Dependency injection between services. Get a specific service from inside another service.

```dart
class ServiceA extends MomentumService {
  int increment(int value) => value + 1;

  double times2(double value) {
    final serviceB = service<ServiceB>();
    return serviceB.times2(value);
  }
}

class ServiceB extends MomentumService {
  double times2(double value) => value * 2;
}
```

If you are using the new `InjectService` to add your services. You can also use the `alias` parameter to get a specific service with matching alias.
```dart
final serviceB = service<ServiceB>(alias: ServiceAlias.noLogs);
```
`alias` is dynamic type which means you can use any values here as long as it matches with the one you want to grab. It is highly recommended to use an `enum`.

Refer to the full documentation for `InjectService` [here](https://www.xamantra.dev/momentum/#/inject_service).