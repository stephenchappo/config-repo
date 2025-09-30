# Hardware & Platform Inventory

This file captures the host’s hardware, storage, and service inventory for disaster recovery.

## 1. Hardware Overview

- CPU:  
  ```bash
  lscpu > hardware-cpu.txt
  ```
- Memory:  
  ```bash
  free -h > hardware-memory.txt
  ```
- Disk layout:  
  ```bash
  lsblk -f > hardware-disks.txt
  blkid > hardware-blkid.txt
  ```
- Network interfaces:  
  ```bash
  ip -br a > network-interfaces.txt
  ip r > network-routes.txt
  ```
- PCI devices:  
  ```bash
  lspci > hardware-pci.txt
  ```

## 2. Storage Pools & Filesystems

- RAID / MDADM:  
  ```bash
  cat /etc/mdadm/mdadm.conf > storage-mdadm.conf
  mdadm --detail --scan > storage-mdadm-scan.txt
  ```
- LVM:  
  ```bash
  vgdisplay > storage-vg.txt
  lvdisplay > storage-lv.txt
  ```
- ZFS (if used):  
  ```bash
  zpool status > storage-zpool-status.txt
  zfs list > storage-zfs-list.txt
  ```

## 3. Services & Containers

- System services (enabled):  
  ```bash
  systemctl list-unit-files --state=enabled > services-enabled.txt
  ```
- Docker runtime snapshot: (refer to `scripts/collect.sh`)  
- Kubernetes resources (if any):  
  ```bash
  kubectl get all --all-namespaces > services-k8s-all.txt
  ```

## 4. User & Group Accounts

- Users list:  
  ```bash
  cut -d: -f1 /etc/passwd > users-list.txt
  ```
- Groups list:  
  ```bash
  cut -d: -f1 /etc/group > groups-list.txt
  ```

---

**Note:** To populate these files, run `scripts/collect.sh` or execute the commands above manually in Act mode. The generated outputs belong under `system_snapshot/{timestamp}/` and can then be committed to version control.
