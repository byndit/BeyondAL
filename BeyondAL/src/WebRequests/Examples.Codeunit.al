codeunit 50002 "BIT Examples Mgt."
{
    procedure DownloadPDFfromURL()
    var
        Instr: InStream;
        Filename: Text;
        Url: Text;
    begin
        Filename := 'BEYONDCloudConnector.pdf';
        Url := 'https://en.beyond-cloudconnector.de/_files/ugd/96eaf6_16d4b7b24ce249339594fb661dbb7f48.pdf';
        BITWebRequestMgt.ResponseAsInStr(Instr, BITWebRequestMgt.PerformWebRequest(Url, Enum::"BIT Web Request Method"::GET));
        DownloadFromStream(Instr, SaveFileDialogTitleMsg, '', SaveFileDialogFilterMsg, Filename);
    end;

    procedure ViewImagefromURL()
    var
        Base64Convert: Codeunit "Base64 Convert";
        BITEditor: Page "BIT Editor";
        BITViewer: Page "BIT Viewer";
        Instr: InStream;
        Base64: Text;
        Url: Text;
    begin
        Clear(BITEditor);
        BITEditor.LookupMode := true;
        if BITEditor.RunModal() <> Action::LookupOK then
            exit;
        Url := BITEditor.GetText();
        BITWebRequestMgt.ResponseAsInStr(Instr, BITWebRequestMgt.PerformWebRequest(Url, Enum::"BIT Web Request Method"::GET));
        Base64 := Base64Convert.ToBase64(Instr);

        Clear(BITViewer);
        BITViewer.SetVariables(url, Base64);
        BITViewer.Run();
    end;

    var
        BITWebRequestMgt: Codeunit "BIT Web Request Mgt.";
        SaveFileDialogFilterMsg: Label 'PDF Files (*.pdf)|*.pdf';
        SaveFileDialogTitleMsg: Label 'Save PDF file';
}