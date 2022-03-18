var placeholder;

function main() {
    placeholder = document.getElementById("controlAddIn");
}

function LoadFile(url) {
    var fileObject = document.getElementById("fileObject");
    if (fileObject) {
        placeholder.removeChild(fileObject);
    }

    fileObject = document.createElement("img");
    fileObject.id = "fileObject";
    fileObject.style.height = 'auto';
    fileObject.style.width = '100%';
    fileObject.setAttribute('src', url);

    placeholder.appendChild(fileObject);
}