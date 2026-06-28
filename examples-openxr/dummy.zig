const std = @import("std");
const xr = @import("openxr");
const c = @import("c.zig");
const Allocator = std.mem.Allocator;

pub const VkInstance = *opaque {};
pub const VkPhysicalDevice = *opaque {};
pub const VkResult = *opaque {};
pub const VkDevice = *opaque {};
pub const wchar_t = u16;

// const BaseDispatch = xr.BaseWrapper;
const InstanceDispatch = xr.InstanceWrapper;

fn getProcAddr(instance: xr.Instance, name: [*:0]const u8) xr.PfnVoidFunction {
    if (std.mem.eql(u8, std.mem.span(name), "xrCreateInstance")) {
        return @ptrCast(&c.xrCreateInstance);
    }

    var out: xr.PfnVoidFunction = undefined;
    const result = c.xrGetInstanceProcAddr(instance, name, &out);
    return switch (result) {
        .success => out,
        else => null,
        // .error_handle_invalid => error.HandleInvalid,
        // .error_instance_lost => error.InstanceLost,
        // .error_runtime_failure => error.RuntimeFailure,
        // .error_out_of_memory => error.OutOfMemory,
        // .error_function_unsupported => error.FunctionUnsupported,
        // .error_validation_failure => error.ValidationFailure,
        // else => error.Unknown,
    };
}

pub fn main() !void {
    var name: [128]u8 = undefined;
    std.mem.copyForwards(u8, name[0..], "openxr-zig-test" ++ [_]u8{0});

    // const xrb = BaseDispatch.load(getProcAddr);

    var inst: xr.Instance = undefined;
    _ = c.xrCreateInstance(
        &.{
            .application_info = .{
                .application_name = name,
                .application_version = 0,
                .engine_name = name,
                .engine_version = 0,
                .api_version = xr.makeApiVersion(1, 0, 0),
            },
        },
        &inst,
    );

    const xri = InstanceDispatch.load(inst, getProcAddr);
    defer xri.destroyInstance(inst) catch {};

    const system = try xri.getSystem(inst, &.{ .form_factor = .head_mounted_display });

    const system_properties = try xri.getSystemProperties(inst, system);

    std.debug.print(
        \\system {}:
        \\  vendor Id: {}
        \\  systemName: {s}
        \\  gfx
        \\    max swapchain image resolution: {}x{}
        \\    max layer count: {}
        \\  tracking
        \\    orientation tracking: {}
        \\    positional tracking: {}
    , .{
        system,
        system_properties.vendor_id,
        system_properties.system_name,
        system_properties.graphics_properties.max_swapchain_image_width,
        system_properties.graphics_properties.max_swapchain_image_height,
        system_properties.graphics_properties.max_layer_count,
        system_properties.tracking_properties.orientation_tracking,
        system_properties.tracking_properties.position_tracking,
    });

    _ = try xri.createSession(inst, &.{
        .system_id = system,
    });
}
