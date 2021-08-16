#include <core/logger.h>
#include <core/asserts.h>

int main(void) {
    SLN_FATAL("A test message: %f", 3.14f);
    SLN_ERROR("A test message: %f", 3.14f);
    SLN_WARN("A test message: %f", 3.14f);
    SLN_INFO("A test message: %f", 3.14f);
    SLN_DEBUG("A test message: %f", 3.14f);
    SLN_TRACE("A test message: %f", 3.14f);

    SLN_ASSERT(1 == 0);

    return 0;
}