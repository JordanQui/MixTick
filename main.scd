// Choix du pitch de départ
// ~pitch = 0.793700526; // 107.15 Ab
// ~pitch = 0.840896415; // 113.52 A
// ~pitch = 0,890898718; // 120.27 Bb
~pitch = 0.943874313; // 127.42 B
// ~pitch = 1; // 135 C
// ~pitch = 1.059463094; // 140.03 C#
// ~pitch = 1.122462;  // 151.53 D

~environementPath = PathName.new(thisProcess.nowExecutingPath).pathOnly;

~mixTick = Routine {

    // --- fichiers disponibles ---
    ~files = PathName("/Volumes/DJ/-tracks/-135").entries;

    // --- buffers & bufnums ---
    ~tracksBuffer = Array.newClear(~files.size);
    ~bufnums = Array.newClear(~files.size);

    // --- libérer un track ---
    ~freeTrack = { |index|
        if(index.notNil and: { index < ~files.size }) {
            if(~tracksBuffer[index].notNil) {
                ~tracksBuffer[index].free;
                ~tracksBuffer[index] = nil;
                ~bufnums[index] = nil;
                ("Track % libéré").format(index).postln;
            };
        };
    };

    // --- chargement dynamique ---
    ~loadTrack = { |index, deck|
        if(index < ~files.size) {
            // récupérer l’ancien bufnum du deck
            var oldBufnum = deck.get(\bufnum);
            var oldIndex = ~bufnums.indexOfEqual(oldBufnum);

            // si un ancien buffer est trouvé et qu’il est différent → libérer
            if(oldIndex.notNil and: { oldIndex != index }) {
                ~freeTrack.(oldIndex);
            };

            ~tracksBuffer[index] = Buffer.read(
                s,
                ~files[index].fullPath,
                action: { |buf|
                    ~bufnums[index] = buf.bufnum;
                    deck.set(\bufnum, buf.bufnum);
                    deck.set(\trig, 1);
                    AppClock.sched(0.01, { deck.set(\trig, 0) });
                    ("Track % chargé : %").format(index, ~files[index].fileName).postln;
                }
            );
        };
    };

    // --- connexions MIDI ---
    MIDIIn.connectAll;

    // charger les modules
    PathName(~environementPath++"modules/synths.scd").fullPath.load;
    s.sync;
    PathName(~environementPath++"modules/ux.scd").fullPath.load;
    s.sync;
    PathName(~environementPath++"modules/midiresponder.scd").fullPath.load;
    s.sync;

    // bus et limiter
    ~outputBus = Bus.audio(s, 2);
    ~limiter = Synth(\outputLimiter, [\input, ~outputBus, \out, 0]);

    // decks (bufnum = 0 par défaut → silence tant qu’aucun buffer n’est chargé)
    ~deck1 = Synth(\bufferPlayer, [\bufnum, 0, \pitch, ~pitch, \amp, 0, \out, ~outputBus]);
    ~deck2 = Synth(\bufferPlayer, [\bufnum, 0, \pitch, ~pitch, \amp, 0, \out, ~outputBus]);
    ~deck3 = Synth(\bufferPlayer, [\bufnum, 0, \pitch, ~pitch, \amp, 0, \out, ~outputBus]);
    ~deck4 = Synth(\bufferPlayer, [\bufnum, 0, \pitch, ~pitch, \amp, 0, \out, ~outputBus]);

    s.makeWindow;
};

s.waitForBoot({ ~mixTick.play(AppClock) });
