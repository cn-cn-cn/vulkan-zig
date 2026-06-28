const xr = @import("openxr");

pub extern fn xrGetInstanceProcAddr(instance: xr.Instance, procname: [*:0]const u8, function: *xr.PfnVoidFunction) xr.Result;
pub extern fn xrCreateInstance(info: *const xr.InstanceCreateInfo, instance: *xr.Instance) xr.Result;
