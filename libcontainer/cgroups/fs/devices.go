// +build linux

package fs

import (
	"github.com/opencontainers/runc/libcontainer/cgroups"
	"github.com/opencontainers/runc/libcontainer/configs"
	"os"
)

type DevicesGroup struct {
}

func (s *DevicesGroup) Name() string {
	return "devices"
}

func (s *DevicesGroup) Apply(d *cgroupData) error {
	path, err := d.path("devices")
	if err != nil {
		return err
	}
	externalCgroup := false
	if _, err = os.Stat(path); err == nil {
		externalCgroup = true
	}

	dir, err := d.join("devices")

	if err != nil {
		// We will return error even it's `not found` error, devices
		// cgroup is hard requirement for container's security.
		return err
	}
	if externalCgroup {
		return nil
	}

	if err := s.Set(dir, d.config); err != nil {
		return err
	}

	return nil
}

func (s *DevicesGroup) Set(path string, cgroup *configs.Cgroup) error {
	if !cgroup.Resources.AllowAllDevices {
		if err := writeFile(path, "devices.deny", "a"); err != nil {
			return err
		}

		for _, dev := range cgroup.Resources.AllowedDevices {
			if err := writeFile(path, "devices.allow", dev.CgroupString()); err != nil {
				return err
			}
		}
		return nil
	}

	if err := writeFile(path, "devices.allow", "a"); err != nil {
		return err
	}

	for _, dev := range cgroup.Resources.DeniedDevices {
		if err := writeFile(path, "devices.deny", dev.CgroupString()); err != nil {
			return err
		}
	}

	return nil
}

func (s *DevicesGroup) Remove(d *cgroupData) error {
	return removePath(d.path("devices"))
}

func (s *DevicesGroup) GetStats(path string, stats *cgroups.Stats) error {
	return nil
}
