# Initialization Order
`Updated on v1.2.8`

You might be confused a lot about which gets initialized first. Like does `bootstrap()` gets called before `bootstrapAsync()`?

Here's the correct intialization order for Momentum.

1. Services
2. MomentumController.init()
3. MomentumController.bootstrap()
4. MomentumController.bootstrapAsync()


- The services gets initialized first to activate the `getservice<T>()` method. Refer to [docs](/#/momentum-service?id=getservicelttgt).
- The `init()` method which returns the initial value of a model is initialized before bootstraps to make the default values available for use inside `bootstrap()` and `bootstrapAsync()`.
- There's no special reason why `bootstrap()` gets called first before `boostrapAsync()`. But consider it as part of momentum's code convention.

The only difference from previous versions is that services gets initialized last. `init()`, `bootstrap()`, and `bootstrapAsync()` are in the same order.

You don't have to worry about your current project that much. During testing, this update didn't break any existing codes. If somehow it broke something in your projects, please immediately file an issue on [GitHub](https://github.com/xamantra/momentum/issues).
