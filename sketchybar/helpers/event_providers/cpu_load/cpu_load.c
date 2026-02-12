#include "cpu.h"
#include "../sketchybar.h"

int main (int argc, char** argv) {
  float update_freq;
  if (argc < 3 || (sscanf(argv[2], "%f", &update_freq) != 1)) {
    printf("Usage: %s \"<event-name>\" \"<event_freq>\"\n", argv[0]);
    exit(1);
  }

  alarm(0);
  struct cpu cpu;
  cpu_init(&cpu);

  // Setup the event in sketchybar
  char event_message[512];
  snprintf(event_message, 512, "--add event '%s'", argv[1]);
  sketchybar(event_message);

  // Larger buffer for per-core data
  char trigger_message[4096];
  for (;;) {
    // Acquire new info
    cpu_update(&cpu);

    // Build per-core string: "core0=12,core1=45,core2=..."
    char cores_str[2048] = "";
    int offset = 0;
    for (natural_t i = 0; i < cpu.num_cores && i < MAX_CORES; i++) {
      offset += snprintf(cores_str + offset, sizeof(cores_str) - offset,
                         "%s%d", i > 0 ? "," : "", cpu.core_total_load[i]);
    }

    // Prepare the event message
    snprintf(trigger_message,
             sizeof(trigger_message),
             "--trigger '%s' user_load='%d' sys_load='%02d' total_load='%02d' num_cores='%d' core_loads='%s'",
             argv[1],
             cpu.user_load,
             cpu.sys_load,
             cpu.total_load,
             cpu.num_cores,
             cores_str);

    // Trigger the event
    sketchybar(trigger_message);

    // Wait
    usleep(update_freq * 1000000);
  }
  return 0;
}
