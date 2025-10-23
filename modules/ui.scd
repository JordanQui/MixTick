~createUI = {
    var window, bufferNames,
    textDeck1, textDeck2, textDeck3, textDeck4,
    listDeck1, listDeck2, listDeck3, listDeck4,
    loopSlider1, loopLabel1, loopSlider2, loopLabel2,
    loopSlider3, loopLabel3, loopSlider4, loopLabel4,
    freqscope,
    toggleLoop;

    var applyDarkStyle = { |view|
        view.background_(Color.black).stringColor_(Color.white);
    };

    bufferNames = ~files.collect { |file| file.fileName };

    // Flags → morceaux joués
    ~playedFlags = Array.fill(bufferNames.size, { false });

    // Labels avec point devant si déjà joué
    ~getDisplayNames = {
        bufferNames.collect { |name, i|
            if (~playedFlags[i]) { "• " ++ name } { name }
        }
    };

    // Rafraîchir toutes les listes
    ~refreshAllMenus = {
        var names = ~getDisplayNames.();
        [listDeck1, listDeck2, listDeck3, listDeck4].do { |menu|
            if(menu.notNil) {
                var oldVal = menu.value;
                menu.items = names;
                menu.value = oldVal;
            }
        };
    };

    window = Window.new("Buffer Selector", Rect(100, 100, 500, 400))
        .background_(Color.black);

    // Helper pour toggler une boucle et répercuter l'état sur l'UI + le synth
    toggleLoop = { |slider|
        var current = slider.value.asInteger;
        var newVal = if(current == 0) { 1 } { 0 };
        slider.valueAction_(newVal);
    };

    // --- Deck 1 ---
    textDeck1 = StaticText(window).string_("Player Y Buffer:"); applyDarkStyle.(textDeck1);
    listDeck1 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black)
        .stringColor_(Color.white);
    listDeck1.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck1, \deck1);   // ✅ synchro transport
    };
    loopLabel1 = StaticText(window).string_("Free"); applyDarkStyle.(loopLabel1);
    loopSlider1 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            ~deck1.set(\loopOn, val);
            if(val == 1) {
                ~deck1.set(\loopTrig, 1);
                AppClock.sched(0.01, { ~deck1.set(\loopTrig, 0) });
            };
            loopLabel1.string = if(val == 1) { "Looped" } { "Loop OFF" };
        });

    // --- Deck 2 ---
    textDeck2 = StaticText(window).string_("Player X Buffer:"); applyDarkStyle.(textDeck2);
    listDeck2 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black)
        .stringColor_(Color.white);
    listDeck2.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck2, \deck2);
    };
    loopLabel2 = StaticText(window).string_("Free"); applyDarkStyle.(loopLabel2);
    loopSlider2 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            ~deck2.set(\loopOn, val);
            if(val == 1) {
                ~deck2.set(\loopTrig, 1);
                AppClock.sched(0.01, { ~deck2.set(\loopTrig, 0) });
            };
            loopLabel2.string = if(val == 1) { "Looped" } { "Loop OFF" };
        });

    // --- Deck 3 ---
    textDeck3 = StaticText(window).string_("Player Z Buffer:"); applyDarkStyle.(textDeck3);
    listDeck3 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black)
        .stringColor_(Color.white);
    listDeck3.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck3, \deck3);
    };
    loopLabel3 = StaticText(window).string_("Free"); applyDarkStyle.(loopLabel3);
    loopSlider3 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            ~deck3.set(\loopOn, val);
            if(val == 1) {
                ~deck3.set(\loopTrig, 1);
                AppClock.sched(0.01, { ~deck3.set(\loopTrig, 0) });
            };
            loopLabel3.string = if(val == 1) { "Looped" } { "Loop OFF" };
        });

    // --- Deck 4 ---
    textDeck4 = StaticText(window).string_("Player W Buffer:"); applyDarkStyle.(textDeck4);
    listDeck4 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black)
        .stringColor_(Color.white);
    listDeck4.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck4, \deck4);
    };
    loopLabel4 = StaticText(window).string_("Free"); applyDarkStyle.(loopLabel4);
    loopSlider4 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            ~deck4.set(\loopOn, val);
            if(val == 1) {
                ~deck4.set(\loopTrig, 1);
                AppClock.sched(0.01, { ~deck4.set(\loopTrig, 0) });
            };
            loopLabel4.string = if(val == 1) { "Looped" } { "Loop OFF" };
        });

    // --- Scope ---
    freqscope = FreqScopeView(window);
    freqscope.active_(true);

    // --- Layout ---
    window.layout_(
        VLayout(
            HLayout(
                VLayout(textDeck1, listDeck1, loopLabel1, loopSlider1),
                VLayout(textDeck2, listDeck2, loopLabel2, loopSlider2),
                VLayout(textDeck3, listDeck3, loopLabel3, loopSlider3),
                VLayout(textDeck4, listDeck4, loopLabel4, loopSlider4)
            ),
            freqscope
        )
    );

    window.view.keyDownAction_({ |view, char|
        var lowerChar;

        lowerChar = if(char.isNil) {
            ""
        } {
            char.asString.toLower;
        };

        switch(lowerChar,
            "w", { toggleLoop.(loopSlider1) },
            "z", { toggleLoop.(loopSlider1) }, // Support AZERTY where physical "W" key produces "z"
            "x", { toggleLoop.(loopSlider2) },
            "c", { toggleLoop.(loopSlider3) },
            "v", { toggleLoop.(loopSlider4) }
        );
    });

    window.onClose = { window.close; freqscope.kill };
    window.front;
};

~createUI.value;
