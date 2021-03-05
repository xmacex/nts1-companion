-- A library for interfacing with Korg NTS-1.
--
-- The original purpose of this was to get mnemonics in place when
-- live-coding on norns. So rather then saying 
-- "send cc message 42 with value 37", say more like
-- "set NTS-1 filter to two-pole bandpass" instead.
--
-- I have no idea how to write Lua modules. Advice welcome.

nts1 = midi.connect(2)

Nts1 = {}

local DEBUG = true
local MIDIRANGE = 128

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

Nts1.osc.shape = function(value) nts1:cc(Nts1.osc.SHAPE, value - 1) end
Nts1.osc.alt   = function(value) nts1:cc(Nts1.osc.ALT, value - 1) end

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

Nts1.filter.lp2 = function() Nts1.filter.set_type(Nts1.filter.TYPES.LP2) end
Nts1.filter.lp4 = function() Nts1.filter.set_type(Nts1.filter.TYPES.LP4) end
Nts1.filter.bp2 = function() Nts1.filter.set_type(Nts1.filter.TYPES.BP2) end
Nts1.filter.bp4 = function() Nts1.filter.set_type(Nts1.filter.TYPES.BP4) end
Nts1.filter.hp2 = function() Nts1.filter.set_type(Nts1.filter.TYPES.HP2) end
Nts1.filter.hp4 = function() Nts1.filter.set_type(Nts1.filter.TYPES.HP4) end
Nts1.filter.off = function() Nts1.filter.set_type(Nts1.filter.TYPES.OFF) end

Nts1.filter.cutf = function(value) nts1:cc(Nts1.filter.CUTF, value - 1) end
Nts1.filter.reso = function(value) nts1:cc(Nts1.filter.RESO, value - 1) end

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
Nts1.eg.ahr      = function() EG.set_type(Nts1.eg.TYPES.AHR) end
Nts1.eg.ar       = function() EG.set_type(Nts1.eg.TYPES.AR) end
Nts1.eg.arl      = function() EG.set_type(Nts1.eg.TYPES.ARL) end
Nts1.eg.open     = function() EG.set_type(Nts1.eg.TYPES.OPEN) end

Nts1.eg.attack   = function(value) nts1:cc(Nts1.eg.ATTACK, value - 1) end
Nts1.eg.release  = function(value) nts1:cc(Nts1.eg.RELEASE, value - 1) end

return Nts1