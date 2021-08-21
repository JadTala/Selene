#include "platform/platform.h"

#if defined(SLN_PLATFORM_MACOS)

#include "core/logger.h"
#include "core/event.h"
#include "core/input.h"

#include "containers/darray.h"

#include <mach/mach_time.h>

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

// For surface creation
#define VK_USE_PLATFORM_METAL_EXT
#include <vulkan/vulkan.h>
#include "renderer/vulkan/vulkan_types.inl"

@class Window;

@interface WindowDelegate : NSObject <NSWindowDelegate> {
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

@interface ContentView : NSView <NSTextInputClient> {
    Window* window;
    NSTrackingArea* trackingArea;
    NSMutableAttributedString* markedText;
}

- (instancetype)initWithWindow:(Window*)initWindow;

@end // ContentView

@implementation ContentView

- (instancetype)initWithWindow:(Window*)initWindow {
    self = [super init];
    if (self != nil) {
        window = initWindow;
        trackingArea = nil;
        markedText = [[NSMutableAttributedString alloc] init];

        [self updateTrackingAreas];
        // NOTE: kUTTypeURL corresponds to NSPasteboardTypeURL but is available
        //       on 10.7 without having been deprecated yet
        [self registerForDraggedTypes:@[(__bridge NSString*) kUTTypeURL]];
    }

    return self;
}

- (BOOL)canBecomeKeyView {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}

- (void)mouseDown:(NSEvent *)event {
    // Handle mouse down event (macOS)
}

- (void)mouseDragged:(NSEvent *)event {
    // Handle mouse dragged event (macOS)
}

- (void)mouseUp:(NSEvent *)event {
    // Handle mouse up event (macOS)
}

- (void)mouseMoved:(NSEvent *)event {
    // Handle mouse moved event (macOS)
}

- (void)rightMouseDown:(NSEvent *)event {
    // Handle right mouse down event (macOS)
}

- (void)rightMouseDragged:(NSEvent *)event  {
    // Handle right mouse dragged event (macOS)
}

- (void)rightMouseUp:(NSEvent *)event {
    // Handle right mouse up event (macOS)
}

- (void)otherMouseDown:(NSEvent *)event {
    // Handle other mouse down event (macOS)
}

- (void)otherMouseDragged:(NSEvent *)event {
    // Handle other mouse dragged event (macOS)
}

- (void)otherMouseUp:(NSEvent *)event {
    // Handle other mouse up event (macOS)
}

- (void)mouseExited:(NSEvent *)event {
    // TODO Handle mouse entered event (macOS)
}

- (void)mouseEntered:(NSEvent *)event {
    // TODO Handle mouse entered event (macOS)
}

- (void)viewDidChangeBackingProperties {
    // TODO Handle framebuffer size change event (macOS)
}

- (void)updateTrackingAreas {
    // TODO Handle tracking areas update event (macOS)
}

- (void)keyDown:(NSEvent *)event {
    // TODO Handle key down event (macOS)
}

- (void)flagsChanged:(NSEvent *)event {
    // TODO Handle flags changed event (macOS)
}

- (void)keyUp:(NSEvent *)event {
    // TODO Handle key up event (macOS)
}

- (void)scrollWheel:(NSEvent *)event {
    // TODO Handle scroll wheel event (macOS)
}

- (void)insertText:(id)string replacementRange:(NSRange)replacementRange {}

- (void)setMarkedText:(id)string selectedRange:(NSRange)selectedRange replacementRange:(NSRange)replacementRange {}

- (void)unmarkText {}

// Defines a constant for empty ranges in NSTextInputClient
//
static const NSRange kEmptyRange = { NSNotFound, 0 };

- (NSRange)selectedRange {return kEmptyRange;}

- (NSRange)markedRange {return kEmptyRange;}

- (BOOL)hasMarkedText {return FALSE;}

- (nullable NSAttributedString *)attributedSubstringForProposedRange:(NSRange)range actualRange:(nullable NSRangePointer)actualRange {return nil;}

- (NSArray<NSAttributedStringKey> *)validAttributesForMarkedText {return [NSArray array];}

- (NSRect)firstRectForCharacterRange:(NSRange)range actualRange:(nullable NSRangePointer)actualRange {return NSMakeRect(0, 0, 0, 0);}

- (NSUInteger)characterIndexForPoint:(NSPoint)point {return 0;}

@end // ContentView

@interface Window : NSWindow {}

@end // Window

@implementation Window

@end // Window

@interface ApplicationDelegate : NSObject <NSApplicationDelegate> {}

@end // ApplicationDelegate

@implementation ApplicationDelegate

@end // ApplicationDelegate

typedef struct internal_state {
    ApplicationDelegate* app_delegate;
    WindowDelegate* wnd_delegate;
    Window* window;
    ContentView* view;
    CAMetalLayer* layer;
    VkSurfaceKHR surface;
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
    state->app_delegate = [[ApplicationDelegate alloc] init];
    if (state->app_delegate == nil) {
        SLN_ERROR("Failed to create application delegate")
        return FALSE;
    }
    [NSApp setDelegate:state->app_delegate];

    // Window delegate creation
    state->wnd_delegate = [[WindowDelegate alloc] initWithWindow:state->window];
    if (state->wnd_delegate == nil) {
        SLN_ERROR("Failed to create window delegate")
        return FALSE;
    }

    // Window creation
    state->window = [[Window alloc]
        initWithContentRect:NSMakeRect(x, y, width, height)
        styleMask:NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskTitled|NSWindowStyleMaskClosable
        backing:NSBackingStoreBuffered
        defer:NO];
    if (state->window == nil) {
        SLN_ERROR("Failed to create window");
        return FALSE;
    }

    // View creation
    state->view = [[ContentView alloc] initWithWindow:state->window];

    // Layer creation    
    state->layer = [CAMetalLayer layer];
    if (!state->layer) {
        SLN_ERROR("Failed to create layer for view");
    }
    [state->view setLayer:state->layer];
    [state->view setWantsLayer:YES];

    // Setting window properties
    [state->window setLevel:NSMainMenuWindowLevel];
    [state->window setTitle:@(application_name)];
    [state->window setDelegate:state->wnd_delegate];
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

    if (state->app_delegate) {
        [NSApp setDelegate:nil];
        state->app_delegate = nil;
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

    return !state->wnd_delegate->quit;
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

void platform_get_required_extension_names(const char ***names_darray) {
    //darray_push(*names_darray, &"VK_MVK_macos_surface"); // Is it even needed?
    darray_push(*names_darray, &"VK_EXT_metal_surface");
}

b8 platform_create_vulkan_surface(platform_state *plat_state, vulkan_context *context) {
    // TODO Implement Vulkan surface creation (macOS)
    // Simply cold-cast to the known type.
    internal_state *state = (internal_state *)plat_state->internal_state;

    VkMetalSurfaceCreateInfoEXT create_info = {VK_STRUCTURE_TYPE_METAL_SURFACE_CREATE_INFO_EXT};
    create_info.pLayer = state->layer;

    VkResult result = vkCreateMetalSurfaceEXT(
        context->instance, 
        &create_info,
        context->allocator,
        &state->surface);
    if (result != VK_SUCCESS) {
        SLN_FATAL("Vulkan surface creation failed.");
        return FALSE;
    }

    context->surface = state->surface;
    return TRUE;
}

keys translate_keycode(u32 ns_keycode) { 
    // TODO Implement keycodes translation (macOS)
    return KEYS_MAX_KEYS;
}

#endif // SLN_PLATFORM_MACOS