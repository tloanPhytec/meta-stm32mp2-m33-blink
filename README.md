# meta-stm32mp2-m33-blink

[![Platforms](https://img.shields.io/badge/Platform-phyFLEX--STM32MP25x-teal)](https://www.phytec.com/product/phyflex-stm32mp25x/)

STM32CubeMP2 GPIO_EXTI example ported to the phyFLEX-STM32MP25x Development Kit. 

With the phyFLEX-STM32MP25x Cortex-A35 cluster running Linux, the firmware introduced by this Yocto meta layer runs on the Cortex-M33 co-processor in parallel. This is a reference for off-loading critical, real-time tasks from Linux to the on-chip MCU. In this example, pressing a push-button (falling edges) triggers an External Interrupt to the Cortex-M33 co-processor, which enables/disables its blinking LED. 

* Verified with the following HW revisions:

  * 1633.1 SOM
  * 1618.2 Libra CB

* Requires the following additional hardware in order to evaluate:

  * 4x M-M Jumper Cables
  * Push Button
  * LED and current-limiting series resistor (~100 Ohm)
  * Bread Board for circuit prototyping

This was tested with BSP-Yocto-OpenSTLinux-STM32MP2-PD26.1.0 and was based on STM32CubeMP2 v1.3.2.

>[!NOTE]
> **The Cortex-M33 firmware introduced by this example cannot be used while a PEB-AV-10 device tree overlay is enabled at the same time (these are disabled by default in BSP-Yocto-OpenSTLinux-STM32MP2-PD26.1.0) due to a pin mux conflict.**

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

Prepare a bootable SD Card for your phyFLEX-STM32MP25x Development Kit with the resulting image.

## Hardware Hookup

On the X50 Connector (located on the 1618.2 phyFLEX Carrier Board), you must:

* wire a Push Button between pins 14 and 16
* wire the LED and series resistor between pins 18 and 26

<img width="986" height="1051" alt="STM32MP2-blink-wire-diagram" src="https://github.com/user-attachments/assets/f5f920d9-d483-4086-8b9f-5ad97bf6d16b" />

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

## Verbose Description

This meta-stm32mp2-m33-blink Yocto Meta Layer serves to improve an M33 GPIO_EXTI example included by default in the BSP-Yocto-OpenSTLinux-STM32MP2-PD26.1.0 release. That default example works but there are a couple quality-of-life issues for developers using it as a basis for development:

* the default GPIO_EXTI example configures the Cortex-M33's input interrupt GPIO on a Fan Connector (X68) pin, thus it's not very safe or convenient to access and pull low.
* the default GPIO_EXTI example lacked debounce logic, where one button press could look like nothing happened due to the bounce in the contact (when two button presses occur very quickly, the second one can cancel the first).
* the default GPIO_EXTI example comes from [PHYTEC's fork of STM32CubeMP2](https://github.com/phytec/STM32CubeMP2/tree/v1.2.0-phy). It lags ST's upstream development and does not port a majority of interface examples (WIP). Most developers will probably want to start from ST's latest examples since there are more examples available to help address more use cases. 

This meta layer improved the default GPIO_EXTI example in the following ways:

* The GPIO input and output pins were moved to the AV Connectors in order to be more easily accesible.
* Debounce magic was added to avoid multiple button presses from being triggered too quickly.

    * The LED behavior was changed from toggling solid-on/solid-off to blinking/solid-off (for pizazz).
 
* The upstream source for the example was changed from PHYTEC's fork to the [upstream STM32CubeMP2](https://github.com/STMicroelectronics/STM32CubeMP2) (tag=v1.3.2) repository (that is no longer the latest but it was when this development began).
 
    * The patch introduced by this layer's .bbappend along with a side-by-side comparison of the PHYTEC phyFLEX Development Kit and ST STM32MP257-EV1 kit schematics helps clarify how the GPIO_EXTI example, and by extension others like it, must be modified in order to work on PHYTEC's phyFLEX-STM32MP25x Development Kit (in order to account for Soc implementation/pin muxing differences of the two platforms).
