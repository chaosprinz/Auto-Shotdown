#!/usr/bin/env ruby
#encoding: utf-8

$0 = "autoshotdown"

@test_time = 240
@critic_time = 20
@min_battery_work = 10
@min_battery_critic = 4

#=acpi_down_test
#uses acpi to test the battery-state
#@@return [Array] An array of two elements:
#   -the first says if the battery is discharging or not
#   -the second tells the charging-state in percent
def acpi_down_test
  acpi = `acpi`
  [acpi.match(/Discharging/).nil? ? false : true,acpi.match(/[\d]+%/).to_s.gsub('%','').to_i]
end

#=on_low_discharge
#callback for discharging low-battery-event
#@@return [TrueClass] makes a syscall, which uses zenity to throw a 
#   window with a warning-message.
def on_low_discharge
  fork {system "zenity --info --text 'akku ist bei #{acpi_down_test[1]}% Leistung. Das System wird demnächst heruntergefahren.'"}
end

#=on_critic_discharge
#callback for critic charging-state-event
#@@return [TrueClass] makes a syscall, which shutdown the pc using sudo shutdown
def on_critic_discharge
  fork {system("sudo shutdown -h now")}
end

#=acpi_test_loop
#endless loop whih uses acpi_down_test to get the time to run, and uses the correct
#callback-methods
def acpi_test_loop
  message_shown = false
  loop do
    charge,offstate = acpi_down_test[1],acpi_down_test[0]
    sleep_time = charge> @min_battery_work ? @test_time : @critic_time
    sleep sleep_time
    if offstate && charge <= @min_battery_work && charge >= @min_battery_critic && !message_shown
      on_low_discharge
      message_shown = true
    elsif offstate && charge <= @min_battery_critic
      on_critic_discharge
    elsif !offstate && message_shown
      message_shown = false
    end
  end
end

acpi_test_loop
