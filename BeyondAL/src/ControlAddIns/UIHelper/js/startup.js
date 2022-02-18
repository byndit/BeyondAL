var rootElement = window.frameElement;
var hasParent = true;
while (hasParent) {
    let parentElement = rootElement.parentElement;
    if (parentElement) {
        rootElement = parentElement;
    } else {
        hasParent = false;
    }
}

rootElement.addEventListener('keydown', function(e) {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnKeyPressed", [e.key]);
});

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnControlReady", []);