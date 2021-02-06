state("SOLAS 128") {}

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
}

startup {
}

update {
    while (vars.reader != null) {
        vars.line = vars.reader.ReadLine();
        if (vars.line == null || vars.line.Length <= 1) {
            return false;
        } else {
            print("SOLAS: " + vars.line);
            return true;
        }
    }
}

start {
    if (vars.line == null) return false;

    // "New game started in GREEN save slot..."
    if (vars.line.StartsWith("New game started")) {
        return true;
    } else {
        return false;
    }
}

split { 
    if (vars.line == null) return false;

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
