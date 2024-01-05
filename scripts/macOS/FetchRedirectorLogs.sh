#!/bin/zsh
sudo log stream --predicate "subsystem = 'com.ZorusTech.Filtering.Redirectors.macOS.Extension' or subsystem == 'com.apple.networkextension' or subsystem == 'com.apple.network'" --debug --info > ~/Desktop/MSP-Filtering_$(date +"%Y_%m_%d_%I_%M_%p").log