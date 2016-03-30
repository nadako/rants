# C# unmanaged function pointers for iOS

Just a reminder to myself when I need this thing next time for making Unity work with native code:

- delegate method should be static to please AOT compiler required for iOS
- method should have have `[MonoPInvokeCallback(typeof(YourDelegate))]` attribute. its code is as simple as this:

        [AttributeUsage (AttributeTargets.Method)]
        public sealed class MonoPInvokeCallbackAttribute : Attribute
        {
            public MonoPInvokeCallbackAttribute (Type t) {}
        }

- for other platforms, delegate should have `[UnmanagedFunctionPointer(YourCallingConvention)]` attribute, but for iOS it prevents AOT compilation for some reason, so we need to `#if` it
