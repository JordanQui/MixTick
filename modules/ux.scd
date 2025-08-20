~createUX = {
    var window, bufferNames,
    textDeck1, textDeck2, textDeck3, textDeck4,
    listDeck1, listDeck2, listDeck3, listDeck4,
    loopSlider1, loopLabel1, loopSlider2, loopLabel2,
    loopSlider3, loopLabel3, loopSlider4, loopLabel4,
    freqscope;

    var applyDarkStyle = { |view|
        view.background_(Color.black).stringColor_(Color.white);
    };

    bufferNames = ~files.collect { |file| file.fileName };

    // Tableau de flags pour savoir si un morceau a été joué
    ~playedFlags = Array.fill(bufferNames.size, { false });

    // Fonction qui renvoie la liste avec les points
    ~getDisplayNames = {
        bufferNames.collect { |name, i|
            if (~playedFlags[i]) { "• " ++ name } { name }
        }
    };

    // Fonction pour rafraîchir toutes les listes
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

    // --- Deck 1 ---
    textDeck1 = StaticText(window).string_("Player X Buffer:"); applyDarkStyle.(textDeck1);
    listDeck1 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black)
        .stringColor_(Color.white);
    listDeck1.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck1);
    };
    loopLabel1 = StaticText(window).string_("Loop OFF"); applyDarkStyle.(loopLabel1);
    loopSlider1 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            Routine({ ~deck1.set(\trig, 1); 0.01.wait; ~deck1.set(\trig, 0); }).play;
            ~deck1.set(\loopOn, val);
            loopLabel1.string = if(val == 1) { "Loop ON" } { "Loop OFF" };
        });

    // --- Deck 2 ---
    textDeck2 = StaticText(window).string_("Player Y Buffer:"); applyDarkStyle.(textDeck2);
    listDeck2 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black)
        .stringColor_(Color.white);
    listDeck2.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck2);
    };
    loopLabel2 = StaticText(window).string_("Loop OFF"); applyDarkStyle.(loopLabel2);
    loopSlider2 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            Routine({ ~deck2.set(\trig, 1); 0.01.wait; ~deck2.set(\trig, 0); }).play;
            ~deck2.set(\loopOn, val);
            loopLabel2.string = if(val == 1) { "Loop ON" } { "Loop OFF" };
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
        ~loadTrack.(idx, ~deck3);
    };
    loopLabel3 = StaticText(window).string_("Loop OFF"); applyDarkStyle.(loopLabel3);
    loopSlider3 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            Routine({ ~deck3.set(\trig, 1); 0.01.wait; ~deck3.set(\trig, 0); }).play;
            ~deck3.set(\loopOn, val);
            loopLabel3.string = if(val == 1) { "Loop ON" } { "Loop OFF" };
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
        ~loadTrack.(idx, ~deck4);
    };
    loopLabel4 = StaticText(window).string_("Loop OFF"); applyDarkStyle.(loopLabel4);
    loopSlider4 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            Routine({ ~deck4.set(\trig, 1); 0.01.wait; ~deck4.set(\trig, 0); }).play;
            ~deck4.set(\loopOn, val);
            loopLabel4.string = if(val == 1) { "Loop ON" } { "Loop OFF" };
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

    window.onClose = { window.close; freqscope.kill };
    window.front;
};

~createUX.value;
