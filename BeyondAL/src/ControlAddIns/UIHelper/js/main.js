function CopyToClipboard(input) {
    var textArea = document.createElement("textarea");
    textArea.value = input;
    textArea.style.top = "0";
    textArea.style.left = "0";
    textArea.style.position = "fixed";
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    try {
        document.execCommand('copy');
    } catch (err) {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnError", [err]);
    }
    document.body.removeChild(textArea);
}

function Ping(timems) {
    setTimeout(function() {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Pong", []);
    }, timems);
}