#!/usr/bin/env ruby
#encoding: utf-8

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
  while acpi_down_test[1] > 10 do
    sleep 240
  end
  if acpi_down_test[0] == true
    system "zenity --info --text 'akku ist bei #{acpi_down_test[1]}% Leistung'"
    acpi_critic_loop
  else
    acpi_test_loop
  end
end

def acpi_critic_loop
  while acpi_down_test[1] > 4 && acpi_down_test[0]
    sleep 25
  end
  if acpi_down_test[0] == true
    puts "welt"
    system("sudo shutdown -h now")
  else
    acpi_test_loop
  end
end

acpi_test_loop
