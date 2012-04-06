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

