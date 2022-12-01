codeunit 50007 "BIT Import Record Links"
{
    var
        UseRegExValue: Label '(?:;"|^")(""|[\w\W]*?)(?=";|"$)|(?:;(?!")|^(?!"))([^;]*?)(?=$|;)', Locked = true;

    trigger OnRun()
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        ReadStream: InStream;
        LineNo: Integer;
        ReadLen: Integer;
        ReadText: Text;
    begin
        FileManagement.BLOBImport(TempBlob, '');
        TempBlob.CreateInStream(ReadStream, TextEncoding::UTF8);
        LineNo := 1;
        repeat
            ReadLen := ReadStream.ReadText(ReadText);
            if ReadLen > 0 then
                ParseLine(ReadText, LineNo);
        until ReadLen = 0;
    end;

    local procedure ParseLine(Line: Text; var LineNo: Integer)
    begin
        InsertRec(Line, LineNo);
        LineNo += 1;
    end;

    procedure InsertRec(NewValue: Text; LineNo: Integer)
    var
        TempGroups: Record Groups temporary;
        TempMatches: Record Matches temporary;
        RecordLink: Record "Record Link";
        RecordLinkManagement: Codeunit "Record Link Management";
        RegEx: Codeunit Regex;
        RecID: RecordId;
        TextValue: Text;
    begin
        RegEx.Match(NewValue, UseRegExValue, TempMatches);

        TempMatches.Get(0);
        RegEx.Groups(TempMatches, TempGroups);
        evaluate(RecID, TempGroups.ReadValue());
        TempGroups.Get(2);

        TempMatches.Get(1);
        RegEx.Groups(TempMatches, TempGroups);
        TempGroups.Get(2);

        TextValue := TempGroups.ReadValue();

        RecordLink.SetRange(Company, CompanyName());
        RecordLink.SetRange("Record ID", RecID);
        RecordLink.SetRange(Description, Format(LineNo));
        if RecordLink.IsEmpty() then begin
            Clear(RecordLink);
            RecordLink."Record ID" := RecID;
            RecordLink."Type" := RecordLink."Type"::Note;
            RecordLink.Description := Format(LineNo);
            RecordLinkManagement.WriteNote(RecordLink, TextValue);
            RecordLink.Company := CompanyName();
            RecordLink.Insert();
        end;
    end;
}