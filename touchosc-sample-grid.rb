# TouchOSC Sample Grid Application for Sonic Pi
# touchosc-sample-grid.rb


# TouchOSC Semple Grid Sequencer for Sonic Pi
# Filename: touchosc-sample-grid.rb
# Project site and documentation: https://github.com/mbutz/sonic-pi-touchosc-sample-grid
# License: https://github.com/mbutz/sonic-pi-touchosc-sample-grid/blob/master/LICENSE
#
# Copyright 2018 by Martin Butz (http://www.mkblog.org).
# All rights reserved.
# Permission is granted for use, copying, modification, and
# distribution of modified versions of this work as long as this
# notice is included.
#
# Sonic Pi is provided by Sam Aaron:
# https://www.sonic-pi.net
# https://github.com/samaaron/sonic-pi
# Please consider to support Sam financially via https://www.patreon.com/samaaron

# /// Quickstart for Configuration //////////////////////////////////////////////
# Set the following parameters and ...
#
# IP of Device running TouchOSC
set :ip, "[IP]" # e. g. 192.168.2.114
# Port configured on device running TouchOSC
set :port, [PORT] # e. g. 9000

# path to sample folder (at the moment first 8 samples will be taken)
set :path, "Path/to/your/sample/for/grid/control/"
#
# ... leave everything after here as it is.
# \\\ Quickstart for Configuration \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

# default sleep time between sample slices
set :default_time_res, 0.5

# bpm
set :my_bpm, 120

# Initialisation
use_osc get(:ip), get(:port)

time_res =  []
(1..8).each do
  time_res.push([get(:default_time_res), 4])
end
set :time_res, time_res
osc "/sample/time_res/4/1", 1

beat_stretch = [[4, 2], [4, 2], [4, 2], [4, 2], [4, 2], [4, 2], [4, 2], [4, 2]]
set :beat_stretch, beat_stretch
osc "/sample/beat_stretch/1/2", 1

num_slices = [[16, 5], [16, 5], [16, 5], [16, 5], [16, 5], [16, 5], [16, 5], [16, 5]]
set :num_slices, num_slices
osc "/sample/num_slices/1/5", 1

rate = [[1, 10], [1, 10], [1, 10], [1, 10], [1, 10], [1, 10], [1, 10], [1, 10]]
set :rate, rate
osc "/sample/rate/1/10", 1

vol = [1, 1, 1, 1, 1, 1, 1, 1]
set :vol, vol
osc "/sample/rotary/amp", 1

lpf = [130, 130, 130, 130, 130, 130, 130, 130]
set :lpf, lpf
osc "/sample/rotary/lpf", 130

hpf = [0, 0, 0, 0, 0, 0, 0, 0]
set :hpf, hpf
osc "/sample/rotary/hpf", 0

attack = [0, 0, 0, 0, 0, 0, 0, 0]
set :attack, attack
osc "/sample/rotary/attack", 0


sustain = [1, 1, 1, 1, 1, 1, 1, 1, ]
set :sustain, sustain
osc "/sample/rotary/sustain", 1

window_size = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]
set :window_size, window_size
osc "/sample/rotary/window_size", 1

pitch_dis = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]
set :pitch_dis, pitch_dis
osc "/sample/rotary/pitch_dis", 1

time_dis = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]
set :time_dis, time_dis
osc "/sample/rotary/time_dis", 1

pitch = [0, 0, 0, 0, 0, 0, 0, 0]
set :pitch, pitch
osc "/sample/rotary/pitch", 0


rpitch = [0, 0, 0, 0, 0, 0, 0, 0]
set :rpitch, rpitch
osc "/sample/rotary/rpitch", 0

direction = [3, 3, 3, 3, 3, 3, 3, 3]
set :direction, direction
osc "/sample/direction/3/1", 1

mute_row = [1, 1, 1, 1, 1, 1, 1, 1]
set :mute_row, mute_row
(1..8).each do |i|
  osc "/grid/mute_row/" + i.to_s + "/1", 0
end

set :sel, 1
set :seq_toggle, 1
osc "/grid/seq/toggle", 1
osc "/grid/selector/1/1", 1

# Choice of Samples
(1..8).each do |i|
  s = get(:path), i - 1
  set ("sample" + i.to_s), s
end

use_bpm get(:my_bpm)

define :msg do | text, var=" " |
  puts "--------------------"
  puts "#{text} #{var}"
  puts "++++++++++++++++++++"
  puts "                    "
end

define :grid_reset do
  use_real_time
  (1..8).each do |x|
    (1..16).each do |y|
      osc "/grid/grid/" + x.to_s + "/" + y.to_s, 0
      osc "/grid/seq/" + y.to_s, 0

      sleep 0.025
    end
  end
  sleep 0.025
end

grid_reset()
sleep 2

define :parse_osc do |address|
  v = get_event(address).to_s.split(",")[6]
  if v != nil
    return v[3..-2].split("/")
  else
    return ["error"]
  end
end

# Initialize the array to store slice selection per track/y
slices = [[], [], [], [], [], [], [], []] # local
# Initialize global
(1..8).each do |i|
  set ("slices" + i.to_s).to_sym, [] # global
end

define :set_slices do |x, y, mode|
  track = y - 1 # array position starts with 0
  if mode
    slices[track].push(x)
  elsif !mode
    slices[track].delete(x)
  end
  set ("slices" + y.to_s).to_sym, slices[track].sort
end

live_loop :watch_rotaries do
  use_real_time
  option   = "/osc/sample/rotary/*"
  data  = sync option
  seg   = parse_osc option
  i = get(:sel) - 1
  case seg[3].to_s
  when "amp"
    vol[i] = data[0].round(2)
    control get(("s" + get(:sel).to_s).to_sym), amp: data[0] * get(:mute_row)[i]
  when "lpf"
    lpf[i] = data[0].round(2)
    control get(("s" + get(:sel).to_s).to_sym), lpf: data[0]
  when "hpf"
    hpf[i] = data[0].round(2)
    control get(("s" + get(:sel).to_s).to_sym), hpf: data[0]
  when "attack"
    attack[i] = data[0].round(3) / 10.0
  when "sustain"
    sustain[i] = data[0].round(3) / 10.0
  when "pitch"
    pitch[i] = data[0].round(0)
  when "rpitch"
    rpitch[i] = data[0].round(0)
  when "window_size"
    window_size[i] = data[0].round(3) / 100.0
  when "pitch_dis"
    pitch_dis[i] = data[0].round(3) / 100.0
  when "time_dis"
    time_dis[i] = data[0].round(3) / 100.0
  end

  set :vol, vol
  set :lpf, lpf
  set :hpf, hpf
  set :attack, attack
  set :sustain, sustain
  set :window_size, window_size
  set :pitch_dis, pitch_dis
  set :time_dis, time_dis
  set :pitch, pitch
  set :rpitch, rpitch
end

live_loop :watch_multies do
  use_real_time
  option   = "/osc/sample/*/*/*"
  data  = sync option
  seg   = parse_osc option

  if seg[2] == "beat_stretch" and data[0] == 1
    i = get(:sel) - 1
    case seg[4].to_i
    when 1
      beat_stretch[i] = [2, 1] # value , button_num
    when 2
      beat_stretch[i] = [4, 2]
    when 3
      beat_stretch[i] = [8, 3]
    when 4
      beat_stretch[i] = [16, 4]
    when 5
      beat_stretch[i] = [32, 5]
    when 6
      beat_stretch[i] = [64, 6]
    end
    set :beat_stretch, beat_stretch
  end

  if seg[2] == "num_slices" and data[0] == 1
    i = get(:sel) - 1
    case seg[4].to_i
    when 1
      num_slices[i] = [1, 1] # value , button_num
    when 2
      num_slices[i] = [2, 2]
    when 3
      num_slices[i] = [3, 3]
    when 4
      num_slices[i] = [8, 4]
    when 5
      num_slices[i] = [16, 5]
    end
    set :num_slices, num_slices
  end

  if seg[2] == "rate" and data[0] == 1
    i = get(:sel) - 1
    case seg[4].to_i
    when 1
      rate[i] = [-4, 1] # value , button_num
    when 2
      rate[i] = [-2, 2]
    when 3
      rate[i] = [-1, 3]
    when 4
      rate[i] = [-0.5, 4]
    when 5
      rate[i] = [-0.25, 5]
    when 6
      rate[i] = [-0.125, 6]
    when 7
      rate[i] = [0.125, 7]
    when 8
      rate[i] = [0.25, 8]
    when 9
      rate[i] = [0.5, 9]
    when 10
      rate[i] = [1, 10]
    when 11
      rate[i] = [2, 11]
    when 12
      rate[i] = [4, 12]
    end
    set :rate, rate
  end

  if seg[2] == "direction" and data[0] == 1
    i = get(:sel) - 1
    case seg[3].to_i
    when 1
      direction[i] = 1
    when 2
      direction[i] = 2
    when 3
      direction[i] = 3
    end
    set :direction, direction
  end

  if seg[2] == "time_res" and data[0] == 1
    i = get(:sel) - 1
    case seg[3].to_i
    when 1
      time_res[i] = [(get(:default_time_res) * 4).to_f, 1]
    when 2
      time_res[i] = [(get(:default_time_res) * 3).to_f, 2]
    when 3
      time_res[i] = [(get(:default_time_res) * 2.0).to_f, 3]
    when 4
      time_res[i] = [get(:default_time_res).to_f, 4]
    when 5
      time_res[i] = [(get(:default_time_res) / 2.0).to_f, 5]
    end
    set :time_res, time_res
  end
end

live_loop :watch_seq_toggle do
  use_real_time
  option   = "/osc/grid/seq/toggle"
  data  = sync option
  seg   = parse_osc option

  if data[0] == 1
    set :seq_toggle, 1
    osc "/grid/seq/toggle", 1
  elsif data[0] == 0
    set :seq_toggle, 0
    osc "/grid/seq/toggle", 0
  end
end

define :update_interface do |idx|
  i = idx -1
  osc "/grid/selector/" + idx.to_s + "/1", 1
  osc "/sample/time_res/" + (get(:time_res)[i][1]).to_s + "/1", 1
  osc "/sample/direction/" + (get(:direction)[i]).to_s + "/1", 1
  osc "/sample/beat_stretch/1/" + (get(:beat_stretch)[i][1]).to_s, 1
  osc "/sample/num_slices/1/" + (get(:num_slices)[i][1]).to_s, 1
  osc "/sample/rate/1/" + (get(:rate)[i][1]).to_s, 1
  osc "/sample/rotary/amp", get(:vol)[i]
  osc "/sample/rotary/lpf", get(:lpf)[i]
  osc "/sample/rotary/hpf", get(:hpf)[i]
  osc "/sample/rotary/attack", get(:attack)[i]
  osc "/sample/rotary/sustain", get(:sustain)[i]
  osc "/sample/rotary/window_size", get(:window_size)[i]
  osc "/sample/rotary/pitch_dis", get(:pitch_dis)[i]
  osc "/sample/rotary/time_dis", get(:time_dis)[i]
  osc "/sample/rotary/pitch", get(:pitch)[i]
  osc "/sample/rotary/rpitch", get(:rpitch)[i]
  osc "/sample/direction/" + (get(:time_res)[i][1]).to_s + "/1", 1
end

live_loop :watch_selector do
  use_real_time
  option   = "/osc/grid/*/*/*"
  data  = sync option
  seg   = parse_osc option

  if seg[2] == "selector" and data[0] == 1
    i = seg[3].to_i
    update_interface(i)
    case i
    when 1
      set :sel, 1
    when 2
      set :sel, 2
    when 3
      set :sel, 3
    when 4
      set :sel, 4
    when 5
      set :sel, 5
    when 6
      set :sel, 6
    when 7
      set :sel, 7
    when 8
      set :sel, 8
    end
  end
end

live_loop :watch_grid_rows do
  use_real_time
  grid   = "/osc/grid/grid/*/*"
  data  = sync grid
  seg   = parse_osc grid

  y = seg[3].to_i
  x = seg[4].to_i

  if data[0] == 1
    set_slices(x, y, true)
  elsif data[0] == 0
    set_slices(x, y, false)
  end
end

live_loop :watch_mute_row do
  use_real_time
  grid   = "/osc/grid/mute_row/*/*"
  data  = sync grid
  seg   = parse_osc grid

  # FIXME:  Clumsy and long winded
  # rename mute_row to something with "set_master"

  if seg[2] == "mute_row" and data[0] == 1
    case seg[3].to_i
    when 1
      mute_row[0] = 0
    when 2
      mute_row[1] = 0
    when 3
      mute_row[2] = 0
    when 4
      mute_row[3] = 0
    when 5
      mute_row[4] = 0
    when
      mute_row[5] = 0
    when 7
      mute_row[6] = 0
    when 8
      mute_row[7] = 0
    end

  elsif seg[2] == "mute_row" and data[0] == 0
    case seg[3].to_i
    when 1
      mute_row[0] = 1
    when 2
      mute_row[1] = 1
    when 3
      mute_row[2] = 1
    when 4
      mute_row[3] = 1
    when 5
      mute_row[4] = 1
    when
      mute_row[5] = 1
    when 7
      mute_row[6] = 1
    when 8
      mute_row[7] = 1
    end
  end
  set :mute_row, mute_row
  control get(("s" + get(:sel).to_s).to_sym), amp: data[0] * get(:mute_row)[seg[3].to_i - 1]
end

live_loop :sequencer do

  i = get(:sel) - 1

  score = get(("slices" + get(:sel).to_s).to_sym)

  if get(:seq_toggle) == 1

    # FIXME: This is very clumsy:
    # 1. redundant code and
    # 2. same ifs are needed when listening to direction toggle
    # and building the play loops below
    if get(:direction)[i] == 3
      osc "/grid/seq/" + score.ring.tick.to_s, 1
      sleep get(:time_res)[i][0] / 2.0
      osc "/grid/seq/" + score.ring.look.to_s, 0
      sleep get(:time_res)[i][0] / 2.0
    elsif get(:direction)[i] == 2
      osc "/grid/seq/" + score.ring.reverse.tick.to_s, 1
      sleep get(:time_res)[i][0] / 2.0
      osc "/grid/seq/" + score.ring.reverse.look.to_s, 0
      sleep get(:time_res)[i][0] / 2.0
    elsif get(:direction)[i] == 1
      osc "/grid/seq/" + score.ring.choose.to_s, 1
      sleep get(:time_res)[i][0] / 2.0
      rand_back(1)
      osc "/grid/seq/" + score.ring.choose.to_s, 0
      sleep get(:time_res)[i][0] / 2.0
    end
  else
    sleep get(:time_res)[i][0] / 2.0
  end

end

define :build_sample_loop do |idx|
  live_loop ("sample_" + idx.to_s).to_sym do
    i = idx - 1

    if get(("slices" + idx.to_s).to_sym).size != 0

      # FIXME: this should go further up where the touchosc output is set
      if get(:direction)[i] == 3
        score = get(("slices" + idx.to_s).to_sym).ring.tick
      elsif get(:direction)[i] == 2
        score = get(("slices" + idx.to_s).to_sym).ring.reverse.tick
      elsif get(:direction)[i] == 1
        score = get(("slices" + idx.to_s).to_sym).ring.choose
      end

      rand_back(2)
      s = sample get(("sample" + idx.to_s).to_sym),
        beat_stretch: get(:beat_stretch)[i][0],
        num_slices: get(:num_slices)[i][0],
        rate: get(:rate)[i][0],
        amp: get(:vol)[i] * get(:mute_row)[i],
        lpf: get(:lpf)[i],
        hpf: get(:hpf)[i],
        attack: get(:attack)[i],
        sustain: get(:sustain)[i],
        window_size: get(:window_size)[i],
        pitch_dis: get(:pitch_dis)[i],
        time_dis: get(:time_dis)[i],
        pitch: get(:pitch)[i],
        rpitch: get(:rpitch)[i],
        slice: score
      set ("s" + idx.to_s).to_sym, s
    end
    sleep get(:time_res)[i][0]
  end
end

(1..8).each do |i|
  build_sample_loop(i)
end
