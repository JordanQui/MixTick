// ======================
// Options serveur
// ======================
s.options.memSize = 2.pow(21);   // ~8 Mo
s.options.numBuffers = 2048;
s.options.numWireBufs = 64;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;
s.options.maxNodes = 1024;

// ======================
// Pitch de départ
// ======================
// ~pitch = 0.5;            // 67.50 Hz — C
// ~pitch = 0.529732;       // 71.51 Hz — C# / Db
// ~pitch = 0.561231;       // 75.77 Hz — D
// ~pitch = 0.594604;       // 80.27 Hz — D# / Eb
// ~pitch = 0.629961;       // 84.94 Hz — E
// ~pitch = 0.667420;       // 90.09 Hz — F
// ~pitch = 0.707107;       // 95.46 Hz — F# / Gb
// ~pitch = 0.749154;       // 101.23 Hz — G
// ~pitch = 0.793700526;    // 107.15 Hz — Ab
// ~pitch = 0.840896415;    // 113.52 Hz — A
// ~pitch = 0.890898718;    // 120.27 Hz — Bb
// ~pitch = 0.943874313;    // 127.42 Hz — B
~pitch = 1.0;            // 135.00 Hz — C ref
// ~pitch = 1.059463094;    // 142.98 Hz — C#
// ~pitch = 1.122462;       // 151.53 Hz — D

~environementPath = PathName.new(thisProcess.nowExecutingPath).pathOnly;

// ======================
// Routine principale
// ======================
~mixTick = Routine {

    // --- fichiers disponibles ---
    ~files = PathName("/Volumes/BANK/TRACKS").entries;

    // --- dictionnaire : deckName -> buffer actuel ---
    ~deckBuffers = IdentityDictionary.new;

    // --- chargement dynamique ---
    ~loadTrack = { |index, deck, deckName|
        Routine {
            if(index < ~files.size) {
                var key = deckName.asSymbol;
                var oldBuf = ~deckBuffers[key];

                Buffer.read(
                    s,
                    ~files[index].fullPath,
                    action: { |newBuf|
                        // assigner d’abord le nouveau
                        ~deckBuffers[key] = newBuf;
                        deck.set(\bufnum, newBuf.bufnum);

                        // synchro avec le transport (si le synth est actif)
                        if(deck.isPlaying) {
                            deck.set(\trig, 1);
                            AppClock.sched(0.01, {
                                if(deck.isPlaying) { deck.set(\trig, 0) }
                            });
                        };

                        ("[LOAD] Deck % → track % chargé : % (bufnum %, % frames, % canaux)")
                            .format(key, index, ~files[index].fileName, newBuf.bufnum, newBuf.numFrames, newBuf.numChannels)
                            .postln;

                        // libérer l’ancien seulement APRÈS assignation
                        if(oldBuf.notNil) {
                            ("[FREE] Deck % libère ancien buffer bufnum % (fichier: %)")
                                .format(key, oldBuf.bufnum, oldBuf.path).postln;
                            oldBuf.free;
                        };
                    }
                );
            };
        }.play(AppClock);
    };

    // --- connexions MIDI ---
    MIDIIn.connectAll;

    // charger les modules
    PathName(~environementPath++"modules/synths.scd").fullPath.load; s.sync;
    PathName(~environementPath++"modules/ui.scd").fullPath.load; s.sync;
    PathName(~environementPath++"modules/midiresponder.scd").fullPath.load; s.sync;

    // bus et limiter
    ~outputBus = Bus.audio(s, 2);
    ~limiter = Synth(\outputLimiter, [\input, ~outputBus, \out, 0]);

    // decks
    ~deck1 = Synth(\bufferPlayer, [\bufnum, 0, \pitch, ~pitch, \amp, 0, \out, ~outputBus]);
    ~deck2 = Synth(\bufferPlayer, [\bufnum, 0, \pitch, ~pitch, \amp, 0, \out, ~outputBus]);
    ~deck3 = Synth(\bufferPlayer, [\bufnum, 0, \pitch, ~pitch, \amp, 0, \out, ~outputBus]);
    ~deck4 = Synth(\bufferPlayer, [\bufnum, 0, \pitch, ~pitch, \amp, 0, \out, ~outputBus]);
    s.sync;

    // fenêtre audio
    s.makeWindow;

    // ======================
    // Transport global
    // ======================
    ~bpm = 120;
    ~beatDur = 60 / ~bpm;

    ~transport = Routine({
        loop {
            [~deck1, ~deck2, ~deck3, ~deck4].do { |d|
                if(d.notNil and: { d.isPlaying }) {
                    d.set(\trig, 1);
                    AppClock.sched(0.01, {
                        if(d.isPlaying) { d.set(\trig, 0) }
                    });
                };
            };
            ~beatDur.wait;
        }
    }).play(SystemClock);

    // ======================
    // Exemple d’appels
    // ======================
    // ~loadTrack.(0, ~deck1, \deck1);
    // ~loadTrack.(1, ~deck2, \deck2);
    // ~loadTrack.(2, ~deck3, \deck3);
    // ~loadTrack.(3, ~deck4, \deck4);
};

// ======================
// Boot serveur
// ======================
s.waitForBoot({ ~mixTick.play(AppClock) });
