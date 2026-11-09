# meta-stm32mp2-m33-blink

[![Platforms](https://img.shields.io/badge/Platform-phyFLEX--STM32MP25x-teal)](https://www.phytec.com/product/phyflex-stm32mp25x/)

STM32CubeMP2 GPIO_EXTI example ported to the phyFLEX-STM32MP25x Development Kit.

* Verified with the following HW revisions:

  * 1633.1 SOM
  * 1618.2 Libra CB

* Requires the following additional hardware in order to evaluate:

  * 4x M-M Jumper Cables
  * Push Button
  * LED and current-limiting series resistor (~100 Ohm)
  * Bread Board for circuit prototyping

This was tested with BSP-Yocto-OpenSTLinux-STM32MP2-PD26.1.0 and was based on STM32CubeMP2 v1.3.2.

## BSP Integration

Navigate to your BSP's sources directory:

```sh
cd $BUILDDIR/../layers/
```

Clone this repo and branch:

```sh
git clone https://github.com/tloanPhytec/meta-stm32mp2-m33-blink.git -b scarthgap
```

Add the layers to the PHYTEC BSP:

```sh
cd $BUILDDIR
bitbake-layers add-layer $BUILDDIR/../layers/meta-stm32mp2-m33-blink/
```
Rebuild the phyFLEX-STM32MP25x Development Kit image:

```sh
DISTRO=openstlinux-weston MACHINE=stm32mp25x-phyflex-libra-rdk-3 bitbake st-image-weston
```

Use the resulting image to boot your phyFLEX-STM32MP25x Development Kit.

## Verification on Target at Runtime

Navigate to the install directory for the M33 GPIO example introduced by this meta layer:

```sh
cd /usr/local/Cube-M33-examples/STM32MP257F-PHYFLEX/Examples/GPIO/GPIO_EXTI_CM33_tloan/
```

Start the Cortex-M33:

```sh
./fw_cortex_m33.sh start
```

Stop the Cortex-M33:

```sh
./fw_cortex_m33.sh stop
```
