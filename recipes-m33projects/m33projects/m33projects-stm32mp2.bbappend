# Applied after PHYTEC by layer priority; reuse ST's build/sign/install tasks.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
PV = "1.3.2"
SRCREV = "7daa1f4efa18bb177c93c06051e6b55b76ccedce"
SRC_URI = "git://github.com/STMicroelectronics/STM32CubeMP2.git;protocol=https;nobranch=1 \
           file://0001-phyflex-stm32mp2-m33-blink-example.patch \
           file://build-glue \
           file://st-m33firmware-load-default.sh \
           file://st-m33firmware-load.service \
           file://shutdown-stm32mp2-m33.sh \
           file://fw_cortex_m33.sh"
LIC_FILES_CHKSUM = "file://License.md;md5=012a8d78c6f636371ad889eadb15885c"
M33_BOARDS = "STM32MP257F-EV1"
PROJECTS_LIST_M33 = "STM32MP257F-EV1/Examples/GPIO/GPIO_EXTI"

# Add build support to the patched upstream example without copying its sources.
python do_patch:append() {
    import shutil
    from pathlib import Path
    target = Path(d.getVar("S")) / "Projects/STM32MP257F-EV1/Examples/GPIO/GPIO_EXTI"
    shutil.copytree(Path(d.getVar("WORKDIR")) / "build-glue",
                    target, dirs_exist_ok=True)
}

do_install:append() {
    src="${D}${M33_OUTPUT_4USERFS}/STM32MP257F-EV1/Examples/GPIO/GPIO_EXTI"
    dst="${D}${M33_OUTPUT_4USERFS}/STM32MP257F-PHYFLEX/Examples/GPIO/GPIO_EXTI_CM33_tloan"
    install -d "$(dirname "$dst")"
    mv "$src" "$dst"
    for firmware in "$dst"/lib/firmware/GPIO_EXTI_CM33_NonSecure*.elf; do
        [ -f "$firmware" ] || continue
        name=$(basename "$firmware")
        mv "$firmware" "$dst/lib/firmware/GPIO_EXTI_CM33_tloan_${name#GPIO_EXTI_}"
    done
    # Remove the empty installation hierarchy left by the inherited task.
    rmdir "${D}${M33_OUTPUT_4USERFS}/STM32MP257F-EV1/Examples/GPIO" \
           "${D}${M33_OUTPUT_4USERFS}/STM32MP257F-EV1/Examples" \
           "${D}${M33_OUTPUT_4USERFS}/STM32MP257F-EV1"
}
