// Lets @USER@ start/stop ONLY battery-full-charge.service without a password.
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.systemd1.manage-units" &&
        action.lookup("unit") == "battery-full-charge.service" &&
        (action.lookup("verb") == "start" || action.lookup("verb") == "stop") &&
        subject.user == "@USER@") {
        return polkit.Result.YES;
    }
});
