#pragma once

#include "defines.h"

// Returns the length of the given string.
SLN_API u64 string_length(const char *str);

SLN_API char *string_duplicate(const char *str);

// Case-sensitive string comparison. True if the same, otherwise false.
SLN_API b8 strings_equal(const char *str0, const char *str1);

// Performs string formatting to dest given format string and parameters.
SLN_API i32 string_format(char *dest, const char *format, ...);

//
/**
 * Performs variadic string formatting to dest given format string and va_list.
 * @param dest The destination for the formatted string.
 * @param format The string to be formatted.
 * @param va_list The variadic argument list.
 * @returns The size of the data written.
 */
SLN_API i32 string_format_v(char *dest, const char *format, void *va_list);