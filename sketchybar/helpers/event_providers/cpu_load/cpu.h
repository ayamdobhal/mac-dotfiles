#include <mach/mach.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#define MAX_CORES 128

struct cpu {
  host_t host;
  mach_msg_type_number_t count;
  host_cpu_load_info_data_t load;
  host_cpu_load_info_data_t prev_load;
  bool has_prev_load;

  int user_load;
  int sys_load;
  int total_load;

  // Per-core data
  natural_t num_cores;
  processor_cpu_load_info_t core_load;
  processor_cpu_load_info_t prev_core_load;
  bool has_prev_core_load;
  int core_total_load[MAX_CORES];
};

static inline void cpu_init(struct cpu* cpu) {
  cpu->host = mach_host_self();
  cpu->count = HOST_CPU_LOAD_INFO_COUNT;
  cpu->has_prev_load = false;
  cpu->has_prev_core_load = false;
  cpu->prev_core_load = NULL;
  cpu->core_load = NULL;
  cpu->num_cores = 0;
}

static inline void cpu_update(struct cpu* cpu) {
  // Aggregate load
  kern_return_t error = host_statistics(cpu->host,
                                        HOST_CPU_LOAD_INFO,
                                        (host_info_t)&cpu->load,
                                        &cpu->count                );

  if (error != KERN_SUCCESS) {
    printf("Error: Could not read cpu host statistics.\n");
    return;
  }

  if (cpu->has_prev_load) {
    uint32_t delta_user = cpu->load.cpu_ticks[CPU_STATE_USER]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_USER];

    uint32_t delta_system = cpu->load.cpu_ticks[CPU_STATE_SYSTEM]
                            - cpu->prev_load.cpu_ticks[CPU_STATE_SYSTEM];

    uint32_t delta_idle = cpu->load.cpu_ticks[CPU_STATE_IDLE]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_IDLE];

    uint32_t total = delta_system + delta_user + delta_idle;
    if (total > 0) {
      cpu->user_load = (double)delta_user / (double)total * 100.0;
      cpu->sys_load = (double)delta_system / (double)total * 100.0;
      cpu->total_load = cpu->user_load + cpu->sys_load;
    }
  }

  cpu->prev_load = cpu->load;
  cpu->has_prev_load = true;

  // Per-core load
  if (cpu->prev_core_load) {
    vm_deallocate(mach_task_self(),
                  (vm_address_t)cpu->prev_core_load,
                  cpu->num_cores * sizeof(processor_cpu_load_info_data_t));
  }
  cpu->prev_core_load = cpu->core_load;

  natural_t num_cores;
  mach_msg_type_number_t core_count;
  error = host_processor_info(cpu->host,
                              PROCESSOR_CPU_LOAD_INFO,
                              &num_cores,
                              (processor_info_array_t*)&cpu->core_load,
                              &core_count);

  if (error != KERN_SUCCESS) {
    printf("Error: Could not read per-core cpu statistics.\n");
    return;
  }

  cpu->num_cores = num_cores;

  if (cpu->has_prev_core_load && cpu->prev_core_load) {
    for (natural_t i = 0; i < num_cores && i < MAX_CORES; i++) {
      uint32_t du = cpu->core_load[i].cpu_ticks[CPU_STATE_USER]
                    - cpu->prev_core_load[i].cpu_ticks[CPU_STATE_USER];
      uint32_t ds = cpu->core_load[i].cpu_ticks[CPU_STATE_SYSTEM]
                    - cpu->prev_core_load[i].cpu_ticks[CPU_STATE_SYSTEM];
      uint32_t di = cpu->core_load[i].cpu_ticks[CPU_STATE_IDLE]
                    - cpu->prev_core_load[i].cpu_ticks[CPU_STATE_IDLE];

      uint32_t total = du + ds + di;
      cpu->core_total_load[i] = total > 0
                                ? (int)((double)(du + ds) / (double)total * 100.0)
                                : 0;
    }
  }

  cpu->has_prev_core_load = true;
}
