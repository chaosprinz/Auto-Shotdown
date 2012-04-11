#!/usr/bin/env ruby
#encoding: utf-8

$0 = "autoshotdown"

@test_time = 240
@critic_time = 20
@min_battery_work = 10
@min_battery_critic = 4

def acpi_down_test
  acpi = `acpi`
  [acpi.match(/Discharging/),acpi.match(/[\d]+%/).to_s.gsub('%','').to_i]
end

def on_low_discharge
  fork {system " zenity --info --text 'akku ist bei #{acpi_down_test[1]}% Leistung. Das System wird demnächst heruntergefahren."}
end

def on_critic_discharge
  fork {system("sudo shutdown -h now")}
end

def acpi_test_loop
  loop do
    charge,offstate = acpi_down_test[1],acpi_down_test[0]
    sleep_time = charge> @min_battery_work ? @test_time : @critic_time
    sleep sleep_time
    if offstate && charge<= @min_battery_work
      on_low_discharge
    elsif offstate && charge <= @critic_time
      on_critic_discharge
    end
  end
end

acpi_test_loop
