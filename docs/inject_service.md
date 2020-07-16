# InjectService
Use this class to inject multiple services of the same type with different configurations using alias. An example use case for this is with `ApiService` in some part of your code, you want to call an api endpoint with logs and sometimes without logs. Or maybe you want to use the same service in different ways in each part of your app. This class allows you to inject multiple services of the same type using alias as unique id.

Setup Example:
```dart
Momentum(
  services: [
    DatabaseService(),
    DownloadService(),
    InjectService(ApiAlias.withoutLogs, ApiService()),
    InjectService(ApiAlias.withLogs, ApiService(enableLogs: true)),
  ],
);
```
- This example uses an `enum` as alias. You can use strings but be sure to declare it globally as a constant variable.
- The first parameter is the alias which is `dynamic` so you can specify any values as alias.
- The second parameter is the actual service you want to inject and use down the tree.

<hr>

## Getting from Widget
You can get a service with alias using context from your widgets.
```dart
var apiService = Momentum.service<ApiService>(context, alias: ApiAlias.withLogs);
```

<hr>

## Getting from Controller
You can get a service with alias from your controllers.
```dart
var apiService = getService<ApiService>(alias: ApiAlias.withLogs);
```

<hr>

## Getting from Service
You can also get a service with alias from a service itself.
```dart
class DownloadService extends MomentumService {
  
  // Assuming you are calling this from your controllers...
  Future<File> download(String url) async {
    var apiService = getService<ApiService>(alias: ApiAlias.withLogs);
    var file = await apiService.downloadFile(url);
    return file;
  }
}
```

## Getting Default
If you accidentally, or forget that you've used `InjectService` to add your services. And then you grabbed a service without an alias like this:
```dart
var apiService = getService<ApiService>();
```
It will still work. Momentum will return the first instance from the `services` list in your `Momentum` root config.

Remember this code from above?
```dart
InjectService(ApiAlias.withoutLogs, ApiService()),
InjectService(ApiAlias.withLogs, ApiService(enableLogs: true)),
```
Momentum will just basically return the one tagged with `ApiAlias.withoutLogs` because it if the first instance.

!> `InjectService` is also a built in `MomentumService` like the `Router`.