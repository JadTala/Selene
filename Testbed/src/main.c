#include <core/logger.h>
#include <core/asserts.h>

#include <platform/platform.h>

int main(void) {
    SLN_FATAL("A test message: %f", 3.14f);
    SLN_ERROR("A test message: %f", 3.14f);
    SLN_WARN("A test message: %f", 3.14f);
    SLN_INFO("A test message: %f", 3.14f);
    SLN_DEBUG("A test message: %f", 3.14f);
    SLN_TRACE("A test message: %f", 3.14f);

    platform_state state;
    if(platform_startup(&state, "Selene Engine Testbed", 100, 100, 1280, 720)) {
        while(TRUE) {
            platform_pump_messages(&state);
        }
    }
    platform_shutdown(&state);

    return 0;
}