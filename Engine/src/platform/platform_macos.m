#include "platform/platform.h"

#if defined(SLN_PLATFORM_MACOS)
#include "core/logger.h"

#include <mach/mach_time.h>

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@class Window;

@interface WindowDelegate : NSObject {
    Window* window;
@public
    b8 quit;
}

- (instancetype)initWithWindow:(Window*)initWindow;

@end // WindowDelegate

@implementation WindowDelegate

- (instancetype)initWithWindow:(Window*)initWindow {
    self = [super init];
    quit = FALSE;
    if (self != nil)
        window = initWindow;
    
    return self;
}

- (BOOL)windowShouldClose:(id)sender {
    quit = TRUE;
    return YES;
}

@end // WindowDelegate

@interface Window : NSWindow {}

@end // Window

@implementation Window

@end // Window

@interface ApplicationDelegate : NSObject <NSApplicationDelegate> {}

@end // ApplicationDelegate

@implementation ApplicationDelegate

@end // ApplicationDelegate

typedef struct internal_state {
    ApplicationDelegate* appDelegate;
    WindowDelegate* wndDelegate;
    Window* window;
} internal_state;

b8 platform_startup(
    platform_state *plat_state,
    const char *application_name,
    i32 x,
    i32 y,
    i32 width,
    i32 height) {
    plat_state->internal_state = malloc(sizeof(internal_state));
    internal_state* state = (internal_state*)plat_state->internal_state;

    // App delegate creation
    state->appDelegate = [[ApplicationDelegate alloc] init];
    if (state->appDelegate == nil) {
        SLN_ERROR("macOS Platform Layer: Failed to create application delegate")
        return FALSE;
    }
    [NSApp setDelegate:state->appDelegate];

    // Window delegate creation
    state->wndDelegate = [[WindowDelegate alloc] initWithWindow:state->window];
    if (state->wndDelegate == nil) {
        SLN_ERROR("macOS Platform Layer: Failed to create window delegate")
        return FALSE;
    }

    // Window creation
    state->window = [[Window alloc]
        initWithContentRect:NSMakeRect(x, y, width, height)
        styleMask:NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskTitled|NSWindowStyleMaskClosable
        backing:NSBackingStoreBuffered
        defer:NO];
    if (state->window == nil) {
        SLN_ERROR("macOS Platform Layer: Failed to create window");
        return FALSE;
    }

    // Setting window properties
    [state->window setLevel:NSMainMenuWindowLevel];
    [state->window setTitle:@(application_name)];
    [state->window setDelegate:state->wndDelegate];
    [state->window setAcceptsMouseMovedEvents:YES];
    [state->window setRestorable:NO];
    [state->window orderFront:nil];

    // Running the app on its own thread
    NSOperationQueue* opQueue = [[NSOperationQueue alloc] init]; 
    [opQueue addOperationWithBlock:^ 
    { 
        [NSApp run];
    }];

    return TRUE;
}

void platform_shutdown(platform_state *plat_state) {
    // Simply cold-cast to the known type.
    internal_state* state = (internal_state*)plat_state->internal_state;

    if (state->appDelegate) {
        [NSApp setDelegate:nil];
        state->appDelegate = nil;
    }
}

b8 platform_pump_messages(platform_state *plat_state) {
    // Simply cold-cast to the known type.
    internal_state* state = (internal_state*)plat_state->internal_state;
    
    NSEvent* event;

    for (;;) {
        event = [NSApp 
            nextEventMatchingMask:NSEventMaskAny
            untilDate:[NSDate distantPast]
            inMode:NSDefaultRunLoopMode
            dequeue:YES];

        if (event == nil) 
            break;
        
        [NSApp sendEvent:event];
    }

    return !state->wndDelegate->quit;
}

void* platform_allocate(u64 size, b8 aligned) {
    return malloc(size);
}

void platform_free(void *block, b8 aligned) {
    free(block);
}

void* platform_zero_memory(void *block, u64 size) {
    return memset(block, 0, size);
}

void* platform_copy_memory(void *dest, const void *source, u64 size) {
    return memcpy(dest, source, size);
}

void* platform_set_memory(void *dest, i32 value, u64 size) {
    return memset(dest, value, size);
}

void platform_console_write(const char *message, u8 colour) {
    // FATAL,ERROR,WARN,INFO,DEBUG,TRACE
    const char* colour_strings[] = {"0;41", "1;31", "1;33", "1;32", "1;34", "1;30"};
    printf("\033[%sm%s\033[0m", colour_strings[colour], message);
}

void platform_console_write_error(const char *message, u8 colour) {
    // FATAL,ERROR,WARN,INFO,DEBUG,TRACE
    const char* colour_strings[] = {"0;41", "1;31", "1;33", "1;32", "1;34", "1;30"};
    printf("\033[%sm%s\033[0m", colour_strings[colour], message);
}

f64 platform_get_absolute_time() {
    return mach_absolute_time();
}

void platform_sleep(u64 ms) {
#if _POSIX_C_SOURCE >= 199309L
    struct timespec ts;
    ts.tv_sec = ms / 1000;
    ts.tv_nsec = (ms % 1000) * 1000 * 1000;
    nanosleep(&ts, 0);
#else
    if (ms >= 1000) {
        sleep(ms / 1000);
    }
    usleep((ms % 1000) * 1000);
#endif
}

#elif SLN_PLATFORM_IOS
// TODO Implement iOS platform layer
#endif