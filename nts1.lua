-- A library for interfacing with Korg NTS-1.
--
-- The original purpose of this was to get mnemonics in place when
-- live-coding on norns. So rather then saying 
-- "send cc message 42 with value 37", say more like
-- "set NTS-1 filter to two-pole bandpass" instead.
--
-- I have no idea how to write Lua modules. Advice welcome.


local DEBUG = true
local MIDIRANGE = 128

Nts1 = {}

-- Seek the MIDI port of a connected NTS-1.
-- Finds only the first one.
Nts1.get_midi_port = function()
  for i,device in pairs(midi.devices) do
    if device.name == "NTS-1 digital kit" then
      return device.port
    end
  end
end

nts1 = midi.connect(Nts1.get_midi_port())

--

Nts1.SYSEX = {
  HELLO = {0x42, 0x50, 0x00, 0x02}
}

-- Send sysex.
--
-- adapted from zebra's https://llllllll.co/t/how-do-i-send-midi-sysex-messages-on-norns/34359/15?u=xmacex
--
-- @param m: a midi device
-- @param d: a table of systex data, omitting the framing bytes
Nts1.send_sysex = function(d)
  nts1:send{0xf0}
  for i,v in ipairs(d) do
    nts1:send{d[i]}
  end
  nts1:send{0xf7}
end

-- Monitor

nts1.event = function(data)
  local msg = midi.to_msg(data)
  if msg.type ~= "clock" then
    tab.print(msg)
  end
end

-- Oscillator

Nts1.osc = {
  TYPES = {
    SAW = 0,
    TRI    = math.floor(MIDIRANGE / 10) * 1,
    SQR    = math.floor(MIDIRANGE / 10) * 2,
    VPW    = math.floor(MIDIRANGE / 10) * 3,
    WAVES  = math.floor(MIDIRANGE / 10) * 4,
    SOUP   = math.floor(MIDIRANGE / 10) * 5,
    SHAPES = math.floor(MIDIRANGE / 10) * 6,
    CHIPS  = math.floor(MIDIRANGE / 10) * 7,
    DUET   = math.floor(MIDIRANGE / 10) * 8,
    MIST   = math.floor(MIDIRANGE / 10) * 9,
  },
  TYPE = 53,
  SHAPE = 54,
  ALT = 55,
}

Nts1.osc.set_type = function(osc_type) nts1:cc(Nts1.osc.TYPE, osc_type) end

Nts1.osc.saw    = function() Nts1.osc.set_type(Nts1.osc.TYPES.SAW) end
Nts1.osc.tri    = function() Nts1.osc.set_type(Nts1.osc.TYPES.TRI) end
Nts1.osc.sqr    = function() Nts1.osc.set_type(Nts1.osc.TYPES.SQR) end
Nts1.osc.vpw    = function() Nts1.osc.set_type(Nts1.osc.TYPES.VPW) end
Nts1.osc.waves  = function() Nts1.osc.set_type(Nts1.osc.TYPES.WAVES) end
Nts1.osc.soup   = function() Nts1.osc.set_type(Nts1.osc.TYPES.SOUP) end
Nts1.osc.shapes = function() Nts1.osc.set_type(Nts1.osc.TYPES.SHAPES) end
Nts1.osc.chips  = function() Nts1.osc.set_type(Nts1.osc.TYPES.CHIPS) end
Nts1.osc.duet   = function() Nts1.osc.set_type(Nts1.osc.TYPES.DUET) end
Nts1.osc.mist   = function() Nts1.osc.set_type(Nts1.osc.TYPES.MIST) end

Nts1.osc.shape  = function(value) nts1:cc(Nts1.osc.SHAPE, value - 1) end
Nts1.osc.shpe   = Nts1.osc.shape
Nts1.osc.alt    = function(value) nts1:cc(Nts1.osc.ALT, value - 1) end

-- Filter

Nts1.filter = {
  TYPES = {
    LP2 = 0,
    LP4 = math.floor(MIDIRANGE / 7) * 1,
    BP2 = math.floor(MIDIRANGE / 7) * 2,
    BP4 = math.floor(MIDIRANGE / 7) * 3,
    HP2 = math.floor(MIDIRANGE / 7) * 4,
    HP4 = math.floor(MIDIRANGE / 7) * 5,
    OFF = math.floor(MIDIRANGE / 7) * 6
  },
  TYPE = 42,
  CUTF = 43,
  RESO = 44,
}

Nts1.filter.set_type = function(filter_type) nts1:cc(Nts1.filter.TYPE, filter_type) end

Nts1.filter.lp2  = function() Nts1.filter.set_type(Nts1.filter.TYPES.LP2) end
Nts1.filter.lp4  = function() Nts1.filter.set_type(Nts1.filter.TYPES.LP4) end
Nts1.filter.bp2  = function() Nts1.filter.set_type(Nts1.filter.TYPES.BP2) end
Nts1.filter.bp4  = function() Nts1.filter.set_type(Nts1.filter.TYPES.BP4) end
Nts1.filter.hp2  = function() Nts1.filter.set_type(Nts1.filter.TYPES.HP2) end
Nts1.filter.hp4  = function() Nts1.filter.set_type(Nts1.filter.TYPES.HP4) end
Nts1.filter.off  = function() Nts1.filter.set_type(Nts1.filter.TYPES.OFF) end

Nts1.filter.cutoff    = function(value) nts1:cc(Nts1.filter.CUTF, value - 1) end
Nts1.filter.cutf      = Nts1.filter.cutoff
Nts1.filter.resonance = function(value) nts1:cc(Nts1.filter.RESO, value - 1) end
Nts1.filter.reso      = Nts1.filter.resonance

-- Envelope generator

Nts1.eg = {
  TYPES = {
    ADSR = 0,
    AHR  = math.floor(MIDIRANGE / 5) * 1,
    AR   = math.floor(MIDIRANGE / 5) * 2,
    ARL  = math.floor(MIDIRANGE / 5) * 3,
    OPEN = math.floor(MIDIRANGE / 5) * 4
  },
  TYPE = 14,
  ATTACK = 16,
  RELEASE = 19,
}

Nts1.eg.set_type = function(eg_type) nts1:cc(Nts1.eg.TYPE, eg_type) end

Nts1.eg.ahr      = function() Nts1.eg.set_type(Nts1.eg.TYPES.AHR) end
Nts1.eg.ar       = function() Nts1.eg.set_type(Nts1.eg.TYPES.AR) end
Nts1.eg.arl      = function() Nts1.eg.set_type(Nts1.eg.TYPES.ARL) end
Nts1.eg.open     = function() Nts1.eg.set_type(Nts1.eg.TYPES.OPEN) end

Nts1.eg.attack   = function(value) nts1:cc(Nts1.eg.ATTACK, value - 1) end
Nts1.eg.atck     = Nts1.eg.attack
Nts1.eg.release  = function(value) nts1:cc(Nts1.eg.RELEASE, value - 1) end
Nts1.eg.rlse     = Nts1.eg.release

-- Mod

Nts1.mod = {
  TYPES = {
    OFF = 0,
    CHORUS   = math.floor(MIDIRANGE / 5) * 1,
    ENSEMBLE = math.floor(MIDIRANGE / 5) * 2,
    PHASER   = math.floor(MIDIRANGE / 5) * 3,
    FLANGER  = math.floor(MIDIRANGE / 5) * 4,
    NUF22MOD = math.floor(MIDIRANGE / 5) * 5,
  },
  TYPE = 88,
  TIME = 28,
  DEPTH = 29
}

Nts1.mod.set_type = function(mod_type) nts1:cc(Nts1.mod.TYPE, mod_type) end

Nts1.mod.off      = function() Nts1.mod.set_type(Nts1.mod.TYPES.OFF) end
Nts1.mod.chorus   = function() Nts1.mod.set_type(Nts1.mod.TYPES.CHORUS) end
Nts1.mod.ensemble = function() Nts1.mod.set_type(Nts1.mod.TYPES.ENSEMBLE) end
Nts1.mod.phaser   = function() Nts1.mod.set_type(Nts1.mod.TYPES.PHASER) end
Nts1.mod.flanger  = function() Nts1.mod.set_type(Nts1.mod.TYPES.FLANGER) end
Nts1.mod.nuf22mod = function() Nts1.mod.set_type(Nts1.mod.TYPES.NUF22MOD) end

Nts1.mod.time     = function(value) nts1:cc(Nts1.mod.TIME, value) end
Nts1.mod.depth    = function(value) nts1:cc(Nts1.mod.DEPTH, value) end
Nts1.mod.dpth     = Nts1.mod.depth

-- Delay

Nts1.delay = {
  TYPES = {
    OFF = 0,
    STEREO   = math.floor(MIDIRANGE / 7) * 1,
    MONO     = math.floor(MIDIRANGE / 7) * 2,
    PING     = math.floor(MIDIRANGE / 7) * 3,
    HIGHPASS = math.floor(MIDIRANGE / 7) * 4,
    TAPE     = math.floor(MIDIRANGE / 7) * 5,
    GRIT     = math.floor(MIDIRANGE / 7) * 6,
    NUF22DEL = math.floor(MIDIRANGE / 7) * 7
  },
  TYPE  = 89,
  TIME  = 30,
  DEPTH = 31,
  MIX   = 36
}

Nts1.delay.set_type = function(delay_type) nts1:cc(Nts1.delay.TYPE, delay_type) end

Nts1.delay.off      = function() Nts1.delay.set_type(Nts1.delay.TYPES.OFF) end
Nts1.delay.stereo   = function() Nts1.delay.set_type(Nts1.delay.TYPES.STEREO) end
Nts1.delay.mono     = function() Nts1.delay.set_type(Nts1.delay.TYPES.MONO) end
Nts1.delay.ping     = function() Nts1.delay.set_type(Nts1.delay.TYPES.PING) end
Nts1.delay.highpass = function() Nts1.delay.set_type(Nts1.delay.TYPES.HIGHPASS) end
Nts1.delay.tape     = function() Nts1.delay.set_type(Nts1.delay.TYPES.TAPE) end
Nts1.delay.grit     = function() Nts1.delay.set_type(Nts1.delay.TYPES.GRIT) end
Nts1.delay.nuf22del = function() Nts1.delay.set_type(Nts1.delay.TYPES.NUF22DEL) end

Nts1.delay.time     = function(value) nts1:cc(Nts1.delay.TIME, value) end
Nts1.delay.depth    = function(value) nts1:cc(Nts1.delay.DEPTH, value) end
Nts1.delay.dpth     = Nts1.mod.depth
Nts1.delay.mix      = function(value) nts1:cc(Nts1.delay.MIX, value) end

-- Reverb

Nts1.reverb = {
  TYPES = {
    OFF = 0,
    HALL       = math.floor(MIDIRANGE / 11) * 1,
    PLATE      = math.floor(MIDIRANGE / 11) * 2,
    SPACE      = math.floor(MIDIRANGE / 11) * 3,
    RISER      = math.floor(MIDIRANGE / 11) * 4,
    SUBNAR     = math.floor(MIDIRANGE / 11) * 5,
    THEATERPRO = math.floor(MIDIRANGE / 11) * 6,
    THEATERHD  = math.floor(MIDIRANGE / 11) * 7,
    MIST       = math.floor(MIDIRANGE / 11) * 8,
    HAZE       = math.floor(MIDIRANGE / 11) * 9,
    SNIFFHD    = math.floor(MIDIRANGE / 11) * 10,
    BREATHHD   = math.floor(MIDIRANGE / 11) * 11,
  },
  TYPE  = 90,
  TIME  = 34,
  DEPTH = 35,
  MIX   = 36
}

Nts1.reverb.set_type   = function(reverb_type) nts1:cc(Nts1.reverb.TYPE, reverb_type) end
Nts1.reverb.off        = function() Nts1.reverb.set_type(Nts1.reverb.TYPES.OFF) end
Nts1.reverb.hall       = function() Nts1.reverb.set_type(Nts1.reverb.TYPES.HALL) end
Nts1.reverb.plate      = function() Nts1.reverb.set_type(Nts1.reverb.TYPES.PLATE) end
Nts1.reverb.space      = function() Nts1.reverb.set_type(Nts1.reverb.TYPES.SPACE) end
Nts1.reverb.riser      = function() Nts1.reverb.set_type(Nts1.reverb.TYPES.RISER) end
Nts1.reverb.subnar     = function() Nts1.reverb.set_type(Nts1.reverb.TYPES.SUBNAR) end
Nts1.reverb.theaterpro = function() Nts1.reverb.set_type(Nts1.reverb.TYPES.THEATERPRO) end
Nts1.reverb.theaterhd  = function() Nts1.reverb.set_type(Nts1.reverb.TYPES.THEATERHD) end
Nts1.reverb.mist       = function() Nts1.reverb.set_type(Nts1.reverb.TYPES.MIST) end
Nts1.reverb.haze       = function() Nts1.reverb.set_type(Nts1.reverb.TYPES.HAZE) end
Nts1.reverb.sniffhd    = function() Nts1.reverb.set_type(Nts1.reverb.TYPES.SHIFFHD) end
Nts1.reverb.breathhd   = function() Nts1.reverb.set_type(Nts1.reverb.TYPES.BREATHHD) end

Nts1.reverb.time       = function(value) nts1:cc(Nts1.reverb.TIME, value) end
Nts1.reverb.depth      = function(value) nts1:cc(Nts1.reverb.DEPTH, value) end
Nts1.reverb.dpth       = Nts1.reverb.depth
Nts1.reverb.mix        = function(value) nts1:cc(Nts1.reverb.MIX, value) end

-- Arp

Nts1.arp = {
  PATTERNS = {
    UP   = 0,
    DOWN = math.floor(MIDIRANGE / 9) * 1,
    UD   = math.floor(MIDIRANGE / 9) * 2,
    DU   = math.floor(MIDIRANGE / 9) * 3,
    CONV = math.floor(MIDIRANGE / 9) * 4,
    DIV  = math.floor(MIDIRANGE / 9) * 5,
    CD   = math.floor(MIDIRANGE / 9) * 6,
    DC   = math.floor(MIDIRANGE / 9) * 7,
    RAND = math.floor(MIDIRANGE / 9) * 8,
    STOC = math.floor(MIDIRANGE / 9) * 9
  },
  PATTERN   = 117,
  INTERVALS = 118,
  LENGTH    = 119
}

Nts1.arp.set_pattern = function(arp_pattern) nts1:cc(Nts1.arp.PATTERN, arp_pattern) end

Nts1.arp.up   = function() Nts1.arp.set_pattern(Nts1.arp.PATTERNS.UP) end
Nts1.arp.down = function() Nts1.arp.set_pattern(Nts1.arp.PATTERNS.DOWN) end
Nts1.arp.ud   = function() Nts1.arp.set_pattern(Nts1.arp.PATTERNS.UD) end
Nts1.arp.du   = function() Nts1.arp.set_pattern(Nts1.arp.PATTERNS.DU) end
Nts1.arp.conv = function() Nts1.arp.set_pattern(Nts1.arp.PATTERNS.CONV) end
Nts1.arp.div  = function() Nts1.arp.set_pattern(Nts1.arp.PATTERNS.DIV) end
Nts1.arp.cd   = function() Nts1.arp.set_pattern(Nts1.arp.PATTERNS.CD) end
Nts1.arp.dc   = function() Nts1.arp.set_pattern(Nts1.arp.PATTERNS.DC) end
Nts1.arp.rand = function() Nts1.arp.set_pattern(Nts1.arp.PATTERNS.RAND) end
Nts1.arp.stoc = function() Nts1.arp.set_pattern(Nts1.arp.PATTERNS.STOC) end

-- arp speed range is 56 - 240
-- what are intervals?
Nts1.arp.intervals = function(value) nts1:cc(Nts1.arp.INTERVALS, value) end
Nts1.arp.length    = function(value) nts1:cc(Nts1.arp.LENGTH, math.floor(MIDIRANGE / 24 * value - 1)) end

-- LFO

Nts1.lfo = {
  RATE  = 24,
  DEPTH = 26
}

Nts1.lfo.rate  = function(value) nts1:cc(Nts1.lfo.RATE, math.floor(MIDIRANGE / 30) * value) end
Nts1.lfo.depth = function(value) nts1:cc(Nts1.lfo.DEPTH, value) end
Nts1.lfo.pitch = function(value) Nts1.lfo.depth(math.floor((MIDIRANGE/2) - (MIDIRANGE/2/100 * value))) end
Nts1.lfo.shape = function(value) Nts1.lfo.depth(math.floor((MIDIRANGE/2) + (MIDIRANGE/2/100 * value))) end


-- Sweep

Nts1.sweep = {
  RATE  = 45,
  DEPTH = 46
}

Nts1.sweep.rate  = function(value) nts1:cc(Nts1.sweep.RATE, math.floor(MIDIRANGE / 30) * value) end
Nts1.sweep.depth = function(value) nts1:cc(Nts1.sweep.DEPTH, value) end
Nts1.sweep.down = function(value) Nts1.sweep.depth(math.floor((MIDIRANGE/2) - (MIDIRANGE/2/100 * value))) end
Nts1.sweep.up   = function(value) Nts1.sweep.depth(math.floor((MIDIRANGE/2) + (MIDIRANGE/2/100 * value))) end

-- Tremollo

Nts1.tremollo = {
  RATE  = 20,
  DEPTH = 21
}

Nts1.tremollo.rate  = function(value) nts1:cc(Nts1.tremollo.RATE, math.floor(MIDIRANGE / 60) * value) end
Nts1.tremollo.depth = function(value) nts1:cc(Nts1.tremollo.DEPTH, value) end

return Nts1
