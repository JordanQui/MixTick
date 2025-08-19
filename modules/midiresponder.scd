// ~reset = {|synth|
//     Routine {
//         synth.set(\trig, 1);  // Redémarre la lecture
//         0.05.wait;  // Attendre 50 ms avant de remettre à 0
//         synth.set(\trig, 0);  // Réinitialiser le trigger
//     }.play;
// };

MIDIdef.cc(\ampDeckOne, { |val, num, chan, src|
    ~deck1.set(\amp, (val / 127).squared * 1);
	val.postln;
}, 0, chan: 0);

MIDIdef.cc(\ampDeckTwo, { |val, num, chan, src|
    ~deck2.set(\amp, (val / 127).squared * 1);
}, 0, chan: 1);

MIDIdef.cc(\ampDeckThree, { |val, num, chan, src|
    ~deck3.set(\amp, (val / 127).squared * 1);
	val.postln;
}, 0, chan: 2);

MIDIdef.cc(\ampDeckFour, { |val, num, chan, src|
    ~deck4.set(\amp, (val / 127).squared * 1);
}, 0, chan: 3);



//
// MIDIdef.cc(\nudgeDeckOne, { |val, num, chan, src|
//     ~deck1.set(\pitch, ~pitch + val.linlin(0,127, -0.02, 0.02));
//     val.postln;
// }, 6, chan: 0);
//
// MIDIdef.cc(\nudgeDeckTwo, { |val, num, chan, src|
//     ~deck2.set(\pitch, ~pitch + val.linlin(0,127, -0.02, 0.02));
//     val.postln;
// }, 6, chan: 1);
//
// MIDIdef.cc(\nudgeDeckThree, { |val, num, chan, src|
//     ~deck3.set(\pitch, ~pitch + val.linlin(0,127, -0.02, 0.02));
//     val.postln;
// }, 6, chan: 2);
//
// MIDIdef.cc(\nudgeDeckFour, { |val, num, chan, src|
//     ~deck4.set(\pitch, ~pitch + val.linlin(0,127, -0.02, 0.02));
//     val.postln;
// }, 6, chan: 3);


// MIDIdef.cc(\pitchDeckOne, { |val, num, chan, src|
// 	var pitch = val.linlin(0,127, 0.95, 1.025);
//     ~deck1.set(\pitch, ~pitch1 * pitch);
// 	~pitch1 = pitch;
// }, 6, chan: 0);
//
// MIDIdef.cc(\pitchDeckTwo, { |val, num, chan, src|
// 	var pitch = val.linlin(0,127, 0.95, 1.025);
//     ~deck2.set(\pitch, ~pitch2 * pitch);
// 	~pitch2 = pitch;
// }, 6, chan: 1);
//
// MIDIdef.cc(\pitchDeckThree, { |val, num, chan, src|
// 	var pitch = val.linlin(0,127, 0.95, 1.025);
//     ~deck1.set(\pitch, ~pitch1 * pitch);
// 	~pitch1 = pitch;
// }, 6, chan: 2);
//
// MIDIdef.cc(\pitchDeckFour, { |val, num, chan, src|
// 	var pitch = val.linlin(0,127, 0.95, 1.025);
//     ~deck2.set(\pitch, ~pitch2 * pitch);
// 	~pitch2 = pitch;
// }, 6, chan: 3);



MIDIdef.cc(\lowEQ1, { |val, num, chan, src|
    ~deck1.set(\low, val.linlin(0,127,-30,0));
	val.postln;
}, 1, chan: 0);

MIDIdef.cc(\mid1EQ1, { |val, num, chan, src|
    ~deck1.set(\mid1, val.linlin(0,127,-30,10));
	val.postln;
}, 2, chan: 0);

MIDIdef.cc(\mid2EQ1, { |val, num, chan, src|
    ~deck1.set(\mid2, val.linlin(0,127,-30,10));
	val.postln;
}, 3, chan: 0);

MIDIdef.cc(\highEQ1, { |val, num, chan, src|
    ~deck1.set(\high, val.linlin(0,127,-30,0));
	val.postln;
}, 4, chan: 0);


MIDIdef.cc(\lowEQ2, { |val, num, chan, src|
    ~deck2.set(\low, val.linlin(0,127,-30,0));
	val.postln;
}, 1, chan: 1);

MIDIdef.cc(\mid1EQ2, { |val, num, chan, src|
    ~deck2.set(\mid1, val.linlin(0,127,-30,10));
	val.postln;
}, 2, chan: 1);

MIDIdef.cc(\mid2EQ2, { |val, num, chan, src|
    ~deck2.set(\mid2, val.linlin(0,127,-30,10));
	val.postln;
}, 3, chan: 1);

MIDIdef.cc(\highEQ2, { |val, num, chan, src|
    ~deck2.set(\high, val.linlin(0,127,-30,0));
	val.postln;
}, 4, chan: 1);


MIDIdef.cc(\lowEQ3, { |val, num, chan, src|
    ~deck3.set(\low, val.linlin(0,127,-30,0));
	val.postln;
}, 1, chan: 2);

MIDIdef.cc(\mid1EQ3, { |val, num, chan, src|
    ~deck3.set(\mid1, val.linlin(0,127,-30,10));
	val.postln;
}, 2, chan: 2);

MIDIdef.cc(\mid2EQ3, { |val, num, chan, src|
    ~deck3.set(\mid2, val.linlin(0,127,-30,10));
	val.postln;
}, 3, chan: 2);

MIDIdef.cc(\highEQ3, { |val, num, chan, src|
    ~deck3.set(\high, val.linlin(0,127,-30,0));
	val.postln;
}, 4, chan: 2);


MIDIdef.cc(\lowEQ4, { |val, num, chan, src|
    ~deck4.set(\low, val.linlin(0,127,-30,0));
	val.postln;
}, 1, chan: 3);

MIDIdef.cc(\mid1EQ4, { |val, num, chan, src|
    ~deck4.set(\mid1, val.linlin(0,127,-30,10));
	val.postln;
}, 2, chan: 3);

MIDIdef.cc(\mid2EQ4, { |val, num, chan, src|
    ~deck4.set(\mid2, val.linlin(0,127,-30,10));
	val.postln;
}, 3, chan: 3);

MIDIdef.cc(\highEQ4, { |val, num, chan, src|
    ~deck4.set(\high, val.linlin(0,127,-30,0));
	val.postln;
}, 4, chan: 3);



// MIDIdef.cc(\cue1, { |val, num, chan, src|
//     ~deck1.set(\cue, val / 127);
// }, 8, chan: 0);
//
// MIDIdef.cc(\cue2, { |val, num, chan, src|
//     ~deck2.set(\cue, val / 127);
// }, 8, chan: 1);
//
// MIDIdef.cc(\cue3, { |val, num, chan, src|
//     ~deck3.set(\cue, val / 127);
// }, 8, chan: 2);
//
// MIDIdef.cc(\cue4, { |val, num, chan, src|
//     ~deck4.set(\cue, val / 127);
// }, 8, chan: 3);
