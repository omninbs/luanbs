# luanbs

[![GitHub Actions](https://github.com/omninbs/luanbs/workflows/Lua/badge.svg)](https://github.com/omninbs/luanbs/actions)
![Lua](https://img.shields.io/badge/Lua-5.1%2C%205.2%2C%205.3-blue)
![LuaJIT](https://img.shields.io/badge/LuaJIT-2.0%2C%202.1-blue)
![CC:T](https://img.shields.io/badge/CC%3AT-1.89.2-blue)
![Code Style](https://img.shields.io/badge/code%20style-luacheck-brightgreen)

> A simple lua(JIT) library to read and write [.nbs files](https://opennbs.org/nbs)
> from [Open Note Block Studio](https://opennbs.org/).
> Also works with CC:T.

`luanbs` has all the functionality `pynbs` has, like iterating over Note Block Studio songs
``` lua
local luanbs = require "luanbs"

for _, note in pairs(luanbs.read("example.nbs").notes) do
  print("tick:", note.tick, "instrument:", note.instrument)
end
```
or generating new songs programmatically
```lua
local luanbs = require "luanbs"

let song = {header = {}, layers = {{}}, notes = {}, instruments = {}}
for i in 1 .. 10 do
  table.insert(song.notes, {tick: i, velocity: 30, key: i+35})
end
```
the main difference is that every non-table field can be nil, where nil acts as 0/"".

## Installation

The package can be installed with `luarocks`
```bash
$ luarocks install rsnbs
```
or src can be copied into your computer and renamed to luanbs if you're using CC:T.

## Reading / Writing
You can use the luanbs.read function to read an parse a specific NBS file of any version.
```rust
let song = rsnbs::read_nbs("song.nbs");
```
This returns a table wich can then be written using luanbs.save
```rust
luanbs.save("song.nbs", song, version);
```
where version = nil saves it in the newest version.

## Fields

#### Header

The first field is `header`, the file header. It contains information about
the file.

Attribute                   | Type    | Details
:---------------------------|:--------|:------------------------------------------------
`header.version`            | `int`   | The NBS version this file was saved on.
`header.default_instruments`| `int`   | The amount of instruments from vanilla Minecraft in the song.
`header.song_length`        | `int`   | The length of the song, measured in ticks.
`header.song_layers`        | `int`   | The ID of the last layer with at least one note block in it.
`header.song_name`          | `str`   | The name of the song.
`header.song_author`        | `str`   | The author of the song.
`header.original_author`    | `str`   | The original song author of the song.
`header.description`        | `str`   | The description of the song.
`header.tempo`              | `float` | The tempo of the song.
`header.auto_save`          | `bool`  | Whether auto-saving has been enabled.
`header.auto_save_duration` | `int`   | The amount of minutes between each auto-save.
`header.time_signature`     | `int`   | The time signature of the song.
`header.minutes_spent`      | `int`   | The amount of minutes spent on the project.
`header.left_clicks`        | `int`   | The amount of times the user has left-clicked.
`header.right_clicks`       | `int`   | The amount of times the user has right-clicked.
`header.blocks_added`       | `int`   | The amount of times the user has added a block.
`header.blocks_removed`     | `int`   | The amount of times the user has removed a block.
`header.song_origin`        | `str`   | The file name of the original MIDI or schematic.
`header.loop`               | `bool`  | Whether the song should loop back to the start after ending.
`header.max_loop_count`     | `int`   | The amount of times to loop. 0 = infinite.
`header.loop_start`         | `int`   | The tick the song will loop back to at the end of playback.

#### Notes

The `notes` attribute holds a list of all the notes of the song in order.

Attribute         | Type  | Details
:---------------- |:------|:------------------------------------------------
`note.tick`       | `int` | The tick at which the note plays.
`note.layer`      | `int` | The ID of the layer in which the note is placed.
`note.instrument` | `int` | The ID of the instrument.
`note.key`        | `int` | The key of the note. (between 0 and 87)
`note.velocity`   | `int` | The velocity of the note. (between 0 and 100)
`note.panning`    | `int` | The stereo panning of the note. (between -100 and 100)
`note.pitch`      | `int` | The detune of the note, in cents. (between -1200 and 1200)

#### Layers

The `layers` attribute holds a list of all the layers of the song in order.

Attribute         | Type  | Details
:-----------------|:------|:------------------------
`layer.id`        | `int` | The ID of the layer.
`layer.name`      | `str` | The name of the layer.
`layer.lock`      | `bool`| Whether the layer is locked.
`layer.volume`    | `int` | The volume of the layer.
`layer.panning`   | `int` | The stereo panning of the layer.

#### Instruments

The `instruments` attribute holds a list of all the custom instruments of the
song in order.

Attribute              | Type   | Details
:----------------------|:-------|:----------------------------------------------------------
`instrument.id`        | `int`  | The ID of the instrument.
`instrument.name`      | `str`  | The name of the instrument.
`instrument.file`      | `str`  | The name of the sound file of the instrument.
`instrument.pitch`     | `int`  | The pitch of the instrument. (between 0 and 87)
`instrument.press_key` | `bool` | Whether the piano should automatically press keys with the instrument when the marker passes them.
