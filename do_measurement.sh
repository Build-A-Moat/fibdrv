#!/bin/bash

CPUID=7
ORIG_ASLR=`cat /proc/sys/kernel/randomize_va_space`
ORIG_GOV=`cat /sys/devices/system/cpu/cpu$CPUID/cpufreq/scaling_governor`
ORIG_TURBO=`cat /sys/devices/system/cpu/intel_pstate/no_turbo`
ORIG_SMP=`cat /proc/irq/default_smp_affinity`

for file in `find /proc/irq -name "smp_affinity"`
do
    sudo bash -c "echo 7f > ${file}"
    #`cat $file` 
done

`cat /proc/interrupts`
sudo bash -c "echo 0 > /proc/sys/kernel/randomize_va_space"
sudo sh -c "echo -n performance > /sys/devices/system/cpu/cpu$CPUID/cpufreq/scaling_governor"
sudo bash -c "echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo"
sudo bash -c "echo 7f > /proc/irq/default_smp_affinity"

#measure the performance of fibdrv
make client_plot
make client_statistic
make unload
make load
rm -f plot_input_statistic
sudo taskset -c 7 ./client_statistic
sudo taskset -c 7 ./client_plot > plot_input
gnuplot scripts/plot-statistic.gp
gnuplot scripts/plot.gp
make unload

# restore the original system settings
sudo bash -c "echo $ORIG_ASLR >  /proc/sys/kernel/randomize_va_space"
sudo sh -c "echo -n $ORIG_GOV > /sys/devices/system/cpu/cpu$CPUID/cpufreq/scaling_governor"
sudo bash -c "echo $ORIG_TURBO > /sys/devices/system/cpu/intel_pstate/no_turbo"
sudo bash -c "echo $ORIG_SMP > /proc/irq/default_smp_affinity"

for file in `find /proc/irq -name "smp_affinity"`
do
    sudo bash -c "echo ff > ${file}"
    #`cat $file` 
done