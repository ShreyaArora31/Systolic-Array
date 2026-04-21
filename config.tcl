# OpenLane config tuned for small designs (systolic_uart)
set ::env(DESIGN_NAME) "systolic_uart_top"

set ::env(VERILOG_FILES) "
    $::env(DESIGN_DIR)/src/systolic_uart_top.v
    $::env(DESIGN_DIR)/src/systolic_array_4x4.v
    $::env(DESIGN_DIR)/src/pe.v
    $::env(DESIGN_DIR)/src/uart_rx.v
    $::env(DESIGN_DIR)/src/uart_tx.v
"

# CORE / DIE area (safe/balanced)
set ::env(DIE_AREA) "0 0 1400 1400"
set ::env(CORE_AREA) "50 50 1350 1350"
set ::env(FP_CORE_UTIL) 20

# Routing / placement safety
set ::env(PL_TARGET_DENSITY) 0.25
set ::env(RT_MIN_LAYER) "met1"
set ::env(RT_MAX_LAYER) "met4"
set ::env(ROUTING_CORES) 4

# Clock
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "9.4"

# Antenna/diode heuristics
set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1
set ::env(GRT_REPAIR_ANTENNAS) 1
set ::env(DIODE_ON_PORTS) "in"

# Outputs
set ::env(RUN_MAGIC) 1
set ::env(RUN_KLAYOUT) 1
set ::env(RUN_LVS) 0
set ::env(RUN_CVC) 0

set ::env(HOLD_SLACK_MARGIN) "0.20"
