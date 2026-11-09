cmake_minimum_required(VERSION 3.10)

set(CMAKE_TOOLCHAIN_FILE "util/arm-gcc-toolchain.cmake")
set(BASE_DIR "${CMAKE_CURRENT_LIST_DIR}/")
set(CMAKE_BINARY_DIR "${BASE_DIR}build")
project(GPIO_EXTI_CM33_NonSecure C ASM)

add_definitions()
include(util/cortex-m33-stm32mp2.cmake)
include(util/color.cmake)
message("-- Starting Cmake compilation ${LINKER_SCRIPT} ${CMAKE_BINARY_DIR}")

set(DEFINITIONS "-DSTM32MP257Fxx \
				-DSTM32MP25xxxx \
				-DLOGLEVEL=3 \
				-DUSE_STM32MP257F_EV1 \
				-DNO_ATOMIC_64_SUPPORT \
				-DMETAL_INTERNAL \
				-DCORE_CM33 \
				-DUSE_HAL_DRIVER \
				-DVERTIO_DEVICE_ONLY \
				-DMETAL_MAX_DEVICE_REGIONS=2 \
				-DLINUX_RPROC_MASTER")

set(TARGET GPIO_EXTI_CM33_NonSecure)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CFLAGS} ${COMMON_COMPILE_FLAGS} -T${LINKER_SCRIPT} ${WARNING_FLAGS} ${DEFINITIONS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COMMON_COMPILE_FLAGS} ${WARNING_FLAGS} ${DEFINITIONS}")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} ${COMMON_COMPILE_FLAGS} -DSTM32MP257Cxx -DSTM32MP25xxxx")
set(CMAKE_C_FLAGS_INIT "${COMMON_FLAGS}")

set(HAL_SRC_FILES ${HAL_SRC_FILES}
						${BASE_DIR}/../../../../../Drivers/STM32MP2xx_HAL_Driver/Src/stm32mp2xx_hal.c
						${BASE_DIR}/../../../../../Drivers/STM32MP2xx_HAL_Driver/Src/stm32mp2xx_hal_cortex.c
						${BASE_DIR}/../../../../../Drivers/STM32MP2xx_HAL_Driver/Src/stm32mp2xx_hal_dma.c
						${BASE_DIR}/../../../../../Drivers/STM32MP2xx_HAL_Driver/Src/stm32mp2xx_hal_dma_ex.c
						${BASE_DIR}/../../../../../Drivers/STM32MP2xx_HAL_Driver/Src/stm32mp2xx_hal_exti.c
						${BASE_DIR}/../../../../../Drivers/STM32MP2xx_HAL_Driver/Src/stm32mp2xx_hal_gpio.c
						${BASE_DIR}/../../../../../Drivers/STM32MP2xx_HAL_Driver/Src/stm32mp2xx_hal_icache.c
						${BASE_DIR}/../../../../../Drivers/STM32MP2xx_HAL_Driver/Src/stm32mp2xx_hal_ipcc.c
						${BASE_DIR}/../../../../../Drivers/STM32MP2xx_HAL_Driver/Src/stm32mp2xx_hal_pwr.c
						${BASE_DIR}/../../../../../Drivers/STM32MP2xx_HAL_Driver/Src/stm32mp2xx_hal_pwr_ex.c
						${BASE_DIR}/../../../../../Drivers/STM32MP2xx_HAL_Driver/Src/stm32mp2xx_hal_rcc.c
						${BASE_DIR}/../../../../../Drivers/STM32MP2xx_HAL_Driver/Src/stm32mp2xx_hal_rcc_ex.c
						${BASE_DIR}/../../../../../Drivers/STM32MP2xx_HAL_Driver/Src/stm32mp2xx_hal_uart.c
						)
set(BSP_SRC_FILES ${BSP_SRC_FILES}
						${BASE_DIR}/../../../../../Drivers/BSP/STM32MP257F-EV1/stm32mp257f_eval.c
						)
set(UTILS_SRC_FILES ${UTILS_SRC_FILES}
						${BASE_DIR}/../../../../../Utilities/CoproSync/copro_sync.c
						${BASE_DIR}/../../../../../Utilities/ResourcesManager/res_mgr.c
						)
set(CMSIS_SRC_FILES ${CMSIS_SRC_FILES}
						${BASE_DIR}/../../../../../Drivers/CMSIS/Device/ST/STM32MP2xx/Source/Templates/system_stm32mp2xx_m33_ns.c
						)
# Set application source files
set(APPLICATION_SRC ${APPLICATION_SRC} ${HAL_SRC_FILES} ${BSP_SRC_FILES} ${UTILS_SRC_FILES} ${CMSIS_SRC_FILES}
						${BASE_DIR}/CM33/NonSecure/Src/main.c
						${BASE_DIR}/CM33/NonSecure/Src/syscalls.c
						${BASE_DIR}/CM33/NonSecure/Src/stm32mp2xx_hal_msp.c
						${BASE_DIR}/CM33/NonSecure/Src/stm32mp2xx_it.c
						${BASE_DIR}/startup_stm32mp257cxx_m33.s
                                                )

include_directories(APPLICATION_INCLUDE ${BASE_DIR}/CM33/NonSecure/Inc)
include_directories(APPLICATION_INCLUDE ${BASE_DIR}/../../../../../Drivers/CMSIS/Device/ST/STM32MP2xx/Include )
include_directories(APPLICATION_INCLUDE ${BASE_DIR}/../../../../../Drivers/CMSIS/Core/Include )
include_directories(APPLICATION_INCLUDE ${BASE_DIR}/../../../../../Utilities/CoproSync )
include_directories(APPLICATION_INCLUDE ${BASE_DIR}/../../../../../Utilities/ResourcesManager )
include_directories(APPLICATION_INCLUDE ${BASE_DIR}/../../../../../Drivers/BSP/STM32MP257F-EV1 )
include_directories(APPLICATION_INCLUDE ${BASE_DIR}/../../../../../Drivers/STM32MP2xx_HAL_Driver/Inc )

set(SOURCE_FILES ${APPLICATION_SRC} ${LINKER_SCRIPT} )

add_executable(${PROJECT_NAME}.elf ${SOURCE_FILES} ${LINKER_SCRIPT})
#target_link_libraries(${PROJECT_NAME}.elf PUBLIC)
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-Map=${PROJECT_BINARY_DIR}/${PROJECT_NAME}.map -Wl,--gc-sections -static  -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -Wl,--start-group -z max-page-size=4096 -lc -lm -Wl,--end-group")
add_custom_command(TARGET ${TARGET}.elf POST_BUILD
     COMMAND ${TOOLCHAIN_PREFIX}objcopy -Oihex ${TARGET}.elf ${TARGET}.hex
     COMMAND ${TOOLCHAIN_PREFIX}objcopy -Obinary ${TARGET}.elf ${TARGET}.bin
     COMMAND ${TOOLCHAIN_PREFIX}size --format=berkeley ${TARGET}.elf
     COMMAND ${TOOLCHAIN_PREFIX}objcopy -S ${TARGET}.elf ${TARGET}_stripped.elf
     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
