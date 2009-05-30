#!/usr/bin/python
# -*- coding: UTF-8 -*-
###########################################################################
#    Copyright (C) 2006 by Sebastian Kügler                                      
#    <sebas@kde.org>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# An API for changing the powerstate of a notebook
###########################################################################
#
# Joel Agnel Fernandes (agnel.joel@gmail.com)
# Stolen from KDE's guidance power system, adapted (severely) for Stumpwm
# to change Brightness of Laptop Panel.
#
###########################################################################

import dbus
import os, xf86misc

class BrightAdjust:
    def __init__(self):
        self._initHAL()
        self._initBrightness()

    def _initHAL(self):
        self.bus = dbus.SystemBus()
        hal_manager_obj = self.bus.get_object("org.freedesktop.Hal", "/org/freedesktop/Hal/Manager")
        self.hal_manager = dbus.Interface(hal_manager_obj, "org.freedesktop.Hal.Manager")

    def _initBrightness(self):
        """ Search HAL for a screen with brightness controls."""
        brightnessDevice = self.hal_manager.FindDeviceByCapability("laptop_panel")
        if len(brightnessDevice) >= 1:
            self.brightnessObject = self.bus.get_object("org.freedesktop.Hal", brightnessDevice[0])
            self.brightness_properties = self.brightnessObject.GetAllProperties(
                                                dbus_interface="org.freedesktop.Hal.Device")

    def getBrightness(self):
        """ Read brightness from HAL. """
        b = self.brightnessObject.GetBrightness(dbus_interface="org.freedesktop.Hal.Device.LaptopPanel")
        return b

    def adjustBrightness(self, level):
        """ Adjust the brightness via HAL. """
        self.brightnessObject.SetBrightness(level,
                                            dbus_interface="org.freedesktop.Hal.Device.LaptopPanel")


