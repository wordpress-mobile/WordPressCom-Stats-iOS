#import "WPStatsLogging.h"

int ddLogLevel = DDLogLevelWarning;

int WPStatsGetLoggingLevel() {
  return ddLogLevel;
}

void WPStatsSetLoggingLevel(int level) {
  ddLogLevel = level;
}
