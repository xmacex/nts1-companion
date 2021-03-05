# nts1-companion

A little NTS-1 companion for norns.

# Usage

I guess the hope is that you would do

```lua
nts1 = require "nts1-companion/nts1"
```

Then

```lua
nts1.connect()
```

And then proceed with something like

```lua
nts1.filter.bp()
nts.filter.freq(30)
```

I don't honestly know what is best for Lua and norns and live-coding, but
memorizing CC messages isn't it. Hence this thing.
