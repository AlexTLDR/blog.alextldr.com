---
title: "I boot Arch btw"
date: 2025-05-05
draft: false
description: "How to repair a broken systemd-boot bootloader"
tags:
  - linux
  - boot-repair
  - systemd-boot
  - grub
  - EndeavourOS
  - Arch Linux
  - dual-boot
  - windows 11
---

## Installing Arch **the right way**

I began my journey with Linux around 2012-2013, and my first distribution was Ubuntu. However, it didn’t quite resonate with me, so I switched to Linux Mint. For me, Mint was a game-changer—it allowed me to easily install .deb files through a graphical interface, much like how you would install .exe files in Windows. I stuck with Mint for about two years while experimenting with various Linux distros in Oracle VirtualBox (which, by the way, was far more user-friendly back then than VMware).

As I continued exploring, I delved into different package managers and philosophies, which eventually led me to Manjaro. This was my introduction to the Arch User Repository (AUR) and, soon after, to vanilla Arch itself. Over time, I learned how to properly install Arch, gaining a deeper understanding of Linux and how to configure my system. The Arch Wiki became an indispensable resource, and it’s something I still reference at least once a week (unless I'm on vacation and away from my laptop).

While Arch is fantastic, I eventually found that when switching between laptops or desktops, I wanted a smoother setup process. That’s when I turned to EndeavourOS, which, in my view, is as close as the Calamares installer can get to the vanilla Arch experience. It strikes a perfect balance between ease of use and customization, providing a near-Arch feel without the complexity of manual installation.

## Old Arch habits

As with many things we learn, I became somewhat set in my ways. Once I figured out how to install Arch, I also adopted GRUB as my boot manager. Back then, GRUB was widely compatible with a variety of backup solutions, and it was the most commonly used and well-documented bootloader. I used it for everything—from dual-booting with Windows to handling EFI systems. I didn’t give it much thought because it worked as expected: it booted my PC and/or laptop. And when something works, why question it, right?

Of course, sometimes Windows updates would mess with my setup. But, in most cases, I could easily fix things. On the rare occasions when I ran into issues, I simply used os-prober from a chroot session via a live CD/USB, and everything would be back to normal.

## Today

Today turned out to be a frustrating day. Yesterday, I played [Kingdom Come: Deliverance](https://kingdomcomerpg.com/) on my Windows setup (I never finished the game, and before buying the new Kingdom Come release, I want to wrap up the original). But then Windows prompted me for updates. As mentioned in previous posts, I’m running Windows 11 in a dual-boot setup with EndeavourOS. Since I installed EndeavourOS the Calamares/Endeavour way, it uses systemd-boot instead of GRUB. I didn’t realize it at the time, but the Windows update messed up my bootloader, and Linux became unbootable (thanks, Microsoft, for assuming my hardware is still under your control even after I’ve paid for a Windows license).

Since bootloaders weren’t something I’d ever focused on, and I was content with GRUB, I had no idea how systemd-boot worked or how to fix the issue.

## How to Fix systemd-boot

I want to start by saying that I believe the solution I’ll outline here is fairly universal, regardless of the Linux distribution. Also, I’ll skip the details about how I spent hours trying different fixes (I even considered switching back to GRUB, but I ultimately decided that systemd-boot works better for me—maybe that’ll be a topic for another blog post). First, I want to give credit to [Der Doktor](https://forum.endeavouros.com/u/joekamprad/summary) from the [EndeavourOS forum](https://forum.endeavouros.com). He responded to this [post](https://forum.endeavouros.com/t/how-to-recover-my-partition-please-help/60224/6) and truly saved the day.

The TL;DR for fixing your boot partition—if you’ve broken or deleted it—is as follows:

1. boot into a live Linux session (I burned an EndeavourOS image on an usb stick)
2. Use lsblk -f or blkid to locate the EFI partition (e.g., /dev/nvme0n1p5)
3. Boot into a live Linux session and mount your partitions:
   ```bash
   sudo mount /dev/nvme0n1p6 /mnt/
   sudo mount /dev/nvme0n1p5 /mnt/efi
   ```
4. Chroot into the mounted system:
   ```bash
   sudo arch-chroot /mnt
   ```
5. Create the k-install script:
   ```bash
   #!/usr/bin/env bash
   
   # Find the configured esp
   esp=$(bootctl -p)
   
   # Prepare the efi partition for kernel-install
   machineid=$(cat /etc/machine-id)
   if [[ ${machineid} ]]; then
       mkdir ${esp}/${machineid}
   else
       echo "Failed to get the machine ID"
   fi
   
   # Run kernel install for all the installed kernels
   reinstall-kernels
   ```

6. Make the script executable:
   ```
   chmod +x /mnt/k-install
   ```

7. Run the script:
   ```
   ./mnt/k-install
   ```

8. Edit the loader configuration:
   ```
   nano /mnt/efi/loader/loader.conf
   ```
   Add a timeout (for multiple boot options like lts and latest kernel or dual booting win and linux):
   ```
   timeout 5
   ```
9. Reinstall the bootloader:
   ```
   bootctl --path=/mnt/efi install
   ```
   if an error like [ Error writing /mnt/efi/loader/loader.conf: No such file or directory ] is encountered:
    * Create the necessary directories:
      ```
       sudo mkdir -p /mnt/efi/loader/entries
      ```
    * Create the loader.conf file:
      ```
      sudo nano /mnt/efi/loader/loader.conf
      ```
      Add the following content to the file:
      ```
      timeout 5
      default EndeavourOS
      ```
    * Reinstall the bootloader:
      ```
      sudo bootctl install
      ```
10. **Very Important**:
    check your fstab: Reboot the system:
      ```
      cat /etc/fstab
      ```
    In my case, Windows was using an efi partition and Linux was using another efi partition. The UUID of /efi was wrong (by default it was using the UUID of the Windows efi partition).

## Simple, isn't it?

Of course, it took me a full day to figure this out. If you're facing the same challenge and the [EndeavourOS forum](https://forum.endeavouros.com) doesn’t have the answer you need, feel free to reach out — I’m happy to help. You can contact me at [alex@alextldr.com](mailto:alex@alextldr.com).

