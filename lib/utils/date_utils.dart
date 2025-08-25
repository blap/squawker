import 'dart:core';

/// Converts a Twitter date string to a DateTime object with proper error handling.
///
/// This function provides robust error handling for date parsing to prevent crashes
/// when malformed date strings are encountered. It's designed to handle Twitter's
/// RFC 2822 date format.
///
/// Returns null if the input is null or if parsing fails.
DateTime? convertTwitterDateTime(String? dateString) {
  if (dateString == null) return null;

  try {
    // Twitter API typically uses RFC 2822 format
    return DateTime.parse(dateString).toUtc();
  } catch (e) {
    // If parsing fails, return null to prevent crashes
    return null;
  }
}
