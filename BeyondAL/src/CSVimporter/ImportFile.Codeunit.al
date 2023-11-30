codeunit 50005 "BIT Import File"
{
    TableNo = "Data Exch. Def";

    trigger OnRun()
    begin
        ImportFile(Rec);
    end;

    procedure ImportFile(DataExchDef: Record "Data Exch. Def"): Boolean
    var
        DataExch: Record "Data Exch.";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        FinishDateTime: DateTime;
        StartDateTime: DateTime;
        ProgressWindow: Dialog;
        NumberOfLinesImported: Integer;
        ProgressWindowMsg: Label 'Please wait while the operation is being completed.';
    begin
        StartDateTime := CurrentDateTime();
        DataExch."Data Exch. Def Code" := DataExchDef.Code;
        if not DataExch.ImportToDataExch(DataExchDef) then
            exit(false);

        ProgressWindow.Open(ProgressWindowMsg);

        DataExchLineDef.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchLineDef.FindFirst();

        DataExchMapping.setrange("Data Exch. Def Code", DataExchDef.Code);
        DataExchMapping.setrange("Data Exch. Line Def Code", DataExchLineDef.Code);
        DataExchMapping.FindFirst();

        if DataExchMapping."Pre-Mapping Codeunit" <> 0 then
            CODEUNIT.Run(DataExchMapping."Pre-Mapping Codeunit", DataExch);

        DataExchMapping.TestField("Mapping Codeunit");
        CODEUNIT.Run(DataExchMapping."Mapping Codeunit", DataExch);

        if DataExchMapping."Post-Mapping Codeunit" <> 0 then
            CODEUNIT.Run(DataExchMapping."Post-Mapping Codeunit", DataExch);


        NumberOfLinesImported := CountImportedLines(DataExch, NumberOfLinesImported);

        ProgressWindow.Close();
        FinishDateTime := CurrentDateTime();
        SendNotificationAfterImport(DataExchDef, NumberOfLinesImported, StartDateTime, FinishDateTime);
        exit(true);
    end;

    procedure CountImportedLines(var DataExch: Record "Data Exch."; var NumberOfLinesImported: Integer): Integer
    var
        DataExchField: Record "Data Exch. Field";
    begin
        DataExchField.SetRange("Data Exch. No.", DataExch."Entry No.");
        DataExchField.SetRange("Data Exch. Line Def Code", DataExch."Data Exch. Line Def Code");
        DataExchField.SetRange("Data Exch. Def Code", DataExch."Data Exch. Def Code");
        if DataExchField.FindLast() then
            exit(DataExchField."Line No.");
        exit(0);
    end;

    local procedure SendNotificationAfterImport(DataExchDef: Record "Data Exch. Def"; NumberOfLinesImported: Integer; StartDateTime: DateTime; FinishDateTime: DateTime)
    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        NotificationToSend: Notification;
        ImportValues: Dictionary of [Text, Text];
        ImportDuration: Duration;
        ImportValue: Text;
        Msg: Text;
    begin
        NotificationToSend.Id(CreateGuid());
        ImportDuration := FinishDateTime - StartDateTime;
        ImportValues.Add('ImportStartTime', 'Started at: ' + Format(StartDateTime));
        ImportValues.Add('ImportFinishTime', 'Finished at: ' + Format(FinishDateTime));
        ImportValues.Add('ImportDuration', 'Duration: ' + Format(ImportDuration));
        ImportValues.Add('NumberOfLines', 'No. of imported Lines: ' + Format(NumberOfLinesImported));

        foreach ImportValue in ImportValues.Values() do
            if Msg = '' then
                Msg := ImportValue
            else
                Msg += ' | ' + ImportValue;

        NotificationToSend.Message(Msg);
        NotificationToSend.Scope(NOTIFICATIONSCOPE::LocalScope);
        NotificationLifecycleMgt.SendNotification(NotificationToSend, DataExchDef.RecordId());
    end;
}