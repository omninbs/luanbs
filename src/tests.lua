local song = require("init").read("../test_files/Megalovania.nbs")

require("init").write(song, "../test_files/MegalovaniaTest.nbs", song.header.version)

if table.concat(song) ~= table.concat(require("init").read("../test_files/Megalovania.nbs")) then print("not equal man") else print("succes!") end
