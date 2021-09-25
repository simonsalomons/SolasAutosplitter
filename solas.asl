state("SOLAS 128") {
    // The current number of bars
    uint nrOfBars: "UnityPlayer.dll", 0x01678418, 0xD0, 0x20, 0x228, 0xD80, 0x214;
}

init {
    var logPath = "%USERPROFILE%//AppData//LocalLow//AmicableAnimal//SOLAS 128//Player.log";
    logPath = Environment.ExpandEnvironmentVariables(logPath);
    print("Solas log path: " + logPath);
    
    if (File.Exists(logPath)) {
        try { // Wipe the log file to clear out messages from last time
            FileStream fs = new FileStream(logPath, FileMode.Open, FileAccess.Write, FileShare.ReadWrite);
            fs.SetLength(0);
            fs.Close();
        } catch {
            print("Solas logfile couldn't be read");
        }
        vars.reader = new StreamReader(new FileStream(logPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite));
        print("Solas successfully read logfile");
    } else {
        vars.reader = null;
        vars.line = null;
        print("Solas No logfile found");
    }
    vars.updateText = false;
    if (settings["Override first text component with number of beats"]) {
      foreach (LiveSplit.UI.Components.IComponent component in timer.Layout.Components) {
        if (component.GetType().Name == "TextComponent") {
          vars.tc = component;
          vars.tcs = vars.tc.Settings;
          vars.updateText = true;
          print("SOLAS: Found text component");
          break;
        }
      }
    }
    print("SOLAS autosplitter initialized");
}

startup {
    settings.Add("Override first text component with number of beats", false);
}

update {    
    if (vars.updateText) {
        vars.tcs.Text1 = "Bars";
        var beats = current.nrOfBars / 7;
        vars.tcs.Text2 = beats.ToString();
    }

    while (vars.reader != null) {
        vars.line = vars.reader.ReadLine();
        if (vars.line == null || vars.line.Length <= 1) {
            return false;
        } else {
            print("SOLAS LOG: " + vars.line);
            return true;
        }
    }
}

start {
    if (vars.line == null) return false;

    // "Start Track... 0"
    if (vars.line.StartsWith("Start Track... 0") && current.nrOfBars == 0) {
        vars.screenOneActivated = false;
        return true;
    } else {
        return false;
    }
}

split { 
    if (vars.line == null) return false;

    // To split on the credits, we wait for Screen 01|01 to be activated.
    if (vars.line.Contains("Screen 01|01 activated")) {
        vars.screenOneActivated = true;
        vars.pulseCount = 0;
    }
    // Then, on the 3rd Pulse Time message, the game transitions to the credits.
    if (vars.screenOneActivated && vars.line.Contains("Pulse Time")) {
        vars.pulseCount += 1;

        if (vars.pulseCount == 3) {
            return true;
        }
    }

    // Split on every node activation
    // "Node 8 has been activated in 31668 bars..."
    if (vars.line.Contains(" has been activated in")) {
        return true;
    } else {
        return false;
    }
}

reset {
}

isLoading {
}
