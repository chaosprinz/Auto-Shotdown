#!/usr/bin/env ruby
#encoding: utf-8
test_time = 240
critic_time = 20
min_battery_work = 10
min_battery_critic = 4

def acpi_down_test
  acpi = `acpi`
  if acpi.match /Discharging/
    dis = true
  else
    dis = false
  end
  bat = acpi.match(/[\d]+%/).to_s.gsub('%','').to_i
  [dis,bat]
end

def acpi_test_loop
  while acpi_down_test[1] > min_battery do
    sleep test_time
  end
  if acpi_down_test[0] == true
    fork do
      system "zenity --info --text 'akku ist bei #{acpi_down_test[1]}% Leistung'"
    end
    acpi_critic_loop
  else
    acpi_test_loop
  end
end

def acpi_critic_loop
  while acpi_down_test[1] min_battery_critic > && acpi_down_test[0]
    sleep critic_time
  end
  if acpi_down_test[0] == true
    puts "welt"
    system("sudo shutdown -h now")
  else
    acpi_test_loop
  end
end

acpi_test_loop
