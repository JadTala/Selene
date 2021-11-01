#include "sln_math.h"
#include "platform/platform.h"

#include <math.h>
#include <stdlib.h>

static b8 rand_seeded = false;

/**
 * Note that these are here in order to prevent having to import the
 * entire <math.h> everywhere.
 */
f32 sln_sin(f32 x)
{
    return sinf(x);
}

f32 sln_cos(f32 x)
{
    return cosf(x);
}

f32 sln_tan(f32 x)
{
    return tanf(x);
}

f32 sln_acos(f32 x)
{
    return acosf(x);
}

f32 sln_sqrt(f32 x)
{
    return sqrtf(x);
}

f32 sln_abs(f32 x)
{
    return fabsf(x);
}

i32 sln_random()
{
    if (!rand_seeded)
    {
        srand((u32)platform_get_absolute_time());
        rand_seeded = true;
    }
    return rand();
}

i32 sln_random_in_range(i32 min, i32 max)
{
    if (!rand_seeded)
    {
        srand((u32)platform_get_absolute_time());
        rand_seeded = true;
    }
    return (rand() % (max - min + 1)) + min;
}

f32 fsln_random()
{
    return (float)sln_random() / (f32)RAND_MAX;
}

f32 fsln_random_in_range(f32 min, f32 max)
{
    return min + ((float)sln_random() / ((f32)RAND_MAX / (max - min)));
}